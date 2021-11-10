PImage map;
Table dataMap;
Table dataVaccine;

Integrator[] interp;
int lines;
float x;
float y;

// Choose display
boolean numDep = true;
boolean info = false;
boolean curve = false;

// Path of files
String path;
String extension;
int n;

// Number of vacsi files in the data repertory
final int nMax = 4;

// Data
int totaldose1;
int totaldose2;
int totalPopulation;

// Data graph
String[] day = new String[nMax];
int[] dose1 = new int[nMax];
int[] dose2 = new int[nMax];
int[] population = new int[nMax];
float[] percentDose1 = new float[nMax];
float[] percentDose2 = new float[nMax];
float value1[] = new float[nMax];
float value2[] = new float[nMax];
String res;
int sizeRect;
int sizeGraph;
int gap;
int gap2;
int posX;
int posY;
int dash;

// Display adjustment
int displayX;
int displayY;

void setup() {
  // Size of the map
  size(1138, 1080);  
  // Set the font used to display hover point information
  textFont(createFont("Serif", 12));

  // Load the different files
  map = loadImage("france_departementale.jpg");
  dataMap = new Table("departements-francais.tsv", TAB);
  path = "vacsi";
  extension = ".csv";
  n = 1;
  dataVaccine = new Table(path + n + extension, ';');
  lines = dataMap.getRowCount();

  // Setup integrator et variables
  interp = new Integrator[lines];
  for (int line = 0; line < lines; line++) {
    interp[line] = new Integrator(dataVaccine.getFloat(line, 1));
  }

  // Initialize the String containing the dates to avoid nullPointerException
  for (int i = 0; i < nMax; i++)
    day[i] = " ";

  smooth();
  frameRate(60);
}

void draw() {
  image(map, 0, 0, width, height);
  noStroke();

  // By default, deactivates when another display is activated
  if (numDep)
    displayDep();
  // Activates or deactivates with a mouse click
  if (info) {
    nameInfo();
    displayInfoFrance();
  }
  // Activates or deactivates when the "Space bar" key is pressed
  if (curve)
    displayCurve();
}

void displayDep() {
  for (int line = 1; line < lines; line++) {
    interp[line].update();

    String numDep = dataVaccine.getRowName(line);
    String nameDep = dataMap.getString(line, 1);
    int nbdose2 = dataVaccine.getInt(line, 3);
    x = dataMap.getFloat(numDep, 2);
    y = dataMap.getFloat(numDep, 3); 

    // Display of brief information when hovering over a department with the mouse
    if (dist(mouseX, mouseY, x, y) < 25) {
      // Position adjustment if the mouse is on the edge of the map
      displayX = 75; 
      if (dist(mouseX, mouseY, x, y) < 40) {
        if (mouseX < width / 4)
          displayX -= displayX / 2;
        else if (mouseX > 4 * width / 5)
          displayX += displayX;
        fill(0);
        text(numDep + " " + nameDep 
          + " | 2e dose: " + nbdose2, 
          mouseX - displayX, mouseY - 10);
      }
    }
  }
}

void nameInfo() {  
  for (int line = 1; line < lines; line++) {
    interp[line].update();

    String numDep = dataVaccine.getRowName(line);
    String nameDep = dataMap.getString(line, 1);
    x = dataMap.getFloat(numDep, 2);
    y = dataMap.getFloat(numDep, 3); 

    String day = dataVaccine.getString(line, 1);
    int nbdose1 = dataVaccine.getInt(line, 2);
    int nbdose2 = dataVaccine.getInt(line, 3);
    int nbPopulation = dataVaccine.getInt(line, 4);
    float percentDose1 = percentage(nbdose1, nbPopulation);
    float percentDose2 = percentage(nbdose2, nbPopulation);

    // Ajustement de position si la souris est sur les bords de la map
    displayX = 130; 
    // Affichage du bloc d'informations lors du survol avec la souris d'un département
    if (dist(mouseX, mouseY, x, y) < 40) {
      if (mouseX < width / 4)
        displayX -= displayX;
      else if (mouseX > 4 * width / 5)
        displayX += 95;

      fill(245, 245, 245);
      rect(mouseX - displayX, mouseY + 20, 275, 100);
      fill(0);
      text(numDep + " | " + nameDep
        + "\nday: " + day
        + "\nPopulation: " + nbPopulation 
        + "\ndose 1: " + nbdose1 + " | " + nf(percentDose1, 0, 2) + "%"
        + "\ndose 2: " + nbdose2 + " | " + nf(percentDose2, 0, 2) + "%", 
        mouseX - (displayX - 5), mouseY + 35);

      int angle1 = round(percentDose1);
      int angle2 = round(percentDose2);
      int angle3 = 360 - (angle1 + angle2);
      int[] angles = {angle1, angle2, angle3};
      camembert(100, angles);
    }
  }
}

void displayInfoFrance() {
  totaldose1 = 0;
  totaldose2 = 0;
  totalPopulation = 0;

  for (int line = 1; line < lines; line++) {
    interp[line].update();

    totaldose1 += dataVaccine.getInt(line, 2);
    totaldose2 += dataVaccine.getInt(line, 3);
    totalPopulation += dataVaccine.getInt(line, 4);

    String day = dataVaccine.getString(line, 1);
    float totalpercentDose1 = percentage(totaldose1, totalPopulation);
    float totalpercentDose2 = percentage(totaldose2, totalPopulation);

    // Display of the general information of France (top left of the map)
    noStroke();
    fill(245, 245, 245);
    rect(5, height / 7, 215, 100);
    fill(0);
    text("Pays: France"
      + "\nDate: " + day
      + "\nPopulation: " + totalPopulation
      + "\nTotal dose 1: " + totaldose1 + " | " + nf(totalpercentDose1, 0, 2) + "%"
      + "\nTotal dose 2: " + totaldose2 + " | " + nf(totalpercentDose2, 0, 2) + "%", 
      10, height / 7 + 15);
  }
}

void displayCurve() {
  n = 1;
  res = "";
  // Recovers all the data in the different files
  for (int i = 0; i < nMax; i ++) {
    dataVaccine = new Table(path + n + extension, ';');
    for (int line = 1; line < lines; line++) {
      interp[line].update();

      String numDep = dataVaccine.getRowName(line);
      String nameDep = dataMap.getString(line, 1);
      x = dataMap.getFloat(numDep, 2);
      y = dataMap.getFloat(numDep, 3); 

      // Ajustement de position si la souris est sur les bords de la map
      displayX = 0; 
      displayY = 0;
      // Affichage du bloc d'informations lors du survol avec la souris d'un département
      if (dist(mouseX, mouseY, x, y) < 40) {
        if (mouseX < width / 4)
          displayX -= 325;
        else if (mouseX > 4 * width / 5)
          displayX += 200;

        if (mouseY < height / 4)
          displayY -= 150;
        else if (mouseY > 3 * height / 5)
          displayY += 200;

        day[i] = dataVaccine.getString(line, 1);
        dose1[i] = dataVaccine.getInt(line, 2);
        dose2[i] = dataVaccine.getInt(line, 3);
        population[i] = dataVaccine.getInt(line, 4);
        res = " (" + numDep + " " + nameDep + ")";

        createGraph();
        drawAxes();
      }
    }

    if (n < nMax)
      n++;
    else if (n == nMax)
      n = 1;
  }
}

void createGraph() {
  sizeRect = 600;
  sizeGraph = 500;
  gap = 50;
  gap2 = 25;
  posX = mouseX - (sizeRect / 2);
  posY = mouseY - (sizeRect / 2);

  // Creation of the graph
  noStroke();
  fill(255);
  rect(posX - displayX, posY - displayY, sizeRect, sizeRect);
  fill(0);
  stroke(0);
  // Dose percentage axis (Y)
  line(posX - displayX + gap, (posY - displayY + sizeRect) - gap, 
    posX - displayX + gap, posY - displayY + gap2);
  // Weeks axis (X)
  line(posX - displayX + gap, (posY - displayY + sizeRect) - gap, 
    (posX - displayX + sizeRect) - gap2, (posY - displayY + sizeRect) - gap);
  // Graph title
  textSize(15);
  text("Evolution des vaccins" + res, 
    mouseX - displayX - (sizeRect / 4), mouseY - displayY - (sizeRect / 3));
  fill(0, 191, 255);
  text("dose 1", 
    mouseX - displayX - (sizeRect / 4), mouseY - displayY + 20 - (sizeRect / 3));
  fill(255, 0, 0);
  text("dose 2", 
    mouseX - displayX - (sizeRect / 4), mouseY - displayY + 40 - (sizeRect / 3));
  fill(0);
  textSize(12);
}

void drawAxes() {
  dash = gap + gap2;
  int percent = 5;
  int offset = sizeGraph / nMax;

  // Dose percentage axis (Y)
  for (int i = 1; i <= 20; i++) {
    if (i % 2 == 0) {
      // Display dashs
      line(posX - displayX + gap + 10, (posY - displayY + sizeRect) - dash, 
        posX - displayX + gap, (posY - displayY + sizeRect) - dash);
      // Percentage display
      text(percent, posX - displayX + gap2, posY - displayY + sizeRect - dash);
    } else
      // Display of secondary dashs
      line(posX - displayX + gap + 5, (posY - displayY + sizeRect) - dash, 
        posX - displayX + gap, (posY - displayY + sizeRect) - dash);
    dash += gap2;
    percent += 5;
  }

  for (int i = 0; i < nMax; i++) {
    // Display of dashs
    line(posX - displayX + offset, (posY - displayY + sizeRect) - gap - 5, 
      posX - displayX + offset, (posY - displayY + sizeRect) - gap);
    // Draw the curve
    percentDose1[i] = percentage(dose1[i], population[i]);
    percentDose2[i] = percentage(dose2[i], population[i]);
    value1[i] = map(percentDose1[i], 0, 100, 0, 500);
    value2[i] = map(percentDose2[i], 0, 100, 0, 500);
    strokeWeight(5);
    if (i == 0) {
      // Dose 1
      stroke(0, 191, 255);
      line(posX - displayX + gap, posY - displayY + sizeRect - gap, 
        posX - displayX + offset, (posY - displayY + sizeRect) - gap - value1[i]);
      // Dose 2
      stroke(255, 0, 0);
      line(posX - displayX + gap, posY - displayY + sizeRect - gap, 
        posX - displayX + offset, (posY - displayY + sizeRect) - gap - value2[i]);
    } else {
      // Dose 1
      stroke(0, 191, 255);
      line(posX - displayX + offset - (sizeGraph / nMax), posY - displayY + sizeRect - gap - value1[i - 1], 
        posX - displayX + offset, (posY - displayY + sizeRect) - gap - value1[i]);
      // Dose 2
      stroke(255, 0, 0);
      line(posX - displayX + offset - (sizeGraph / nMax), posY - displayY + sizeRect - gap - value2[i - 1], 
        posX - displayX + offset, (posY - displayY + sizeRect) - gap - value2[i]);
    }
    strokeWeight(1);
    stroke(0);
    // Date display
    text(day[i], posX - displayX + offset - gap2, (posY - displayY + sizeRect) - gap2); 
    offset += sizeGraph / nMax;
  }
}

float percentage(float dose, float population) {
  if (dose <= 0)
    return 0;
  return (dose / population) * 100;
}

void camembert(float diameter, int[] angles) {
  // Position adjustment if the mouse is on the edge of the map
  int posX = 90;
  if (mouseX < width / 4)
    posX += 130;
  else if (mouseX > 3 * width / 4)
    posX -= posX + 5;

  float lastAngle = 0;
  stroke(0);
  // First doses in blue
  fill(0, 191, 255);
  arc(mouseX + posX, mouseY + 70, diameter, diameter, lastAngle, 
    lastAngle + radians(angles[0]));
  lastAngle += radians(angles[0]);
  // Second dose in red
  fill(255, 0, 0);
  arc(mouseX + posX, mouseY + 70, diameter, diameter, lastAngle, 
    lastAngle + radians(angles[1]));
  lastAngle += radians(angles[1]);
  // The rest in white
  fill(255, 255, 255);
  arc(mouseX + posX, mouseY + 70, diameter, diameter, lastAngle, 
    lastAngle + radians(angles[2]));
  lastAngle += radians(angles[2]);
}

void keyPressed() {
  if (key == ' ') {
    if (!curve) {
      numDep = false;
      info = false;
      curve = true;
    } else {
      curve = false;
      info = false;
      numDep = true;
    }
  } else if (key == CODED) {
    if (keyCode == LEFT) {
      if (n == 1)
        n = nMax;
      else
        n--;
    } else if (keyCode == RIGHT) {
      if (n == nMax)
        n = 1;
      else
        n++;
    }
    dataVaccine = new Table(path + n + extension, ';');
  }
}

void mousePressed() {
  if (!info) {
    numDep = false;
    curve = false;
    info = true;
  } else {
    info = false;
    curve = false;
    numDep = true;
  }
}
