
- Year: M1 IWOCS
- Subject: Data Visualisation
- TP : Project
- Date : May 2021

## Author
|Name|First name|
|--|--|
| *Bourgeaux* | *Maxence* |

## Description
This project was made on Processing, using Java language. It proposes an interactive mapping of Covid 19 vaccine data. I chose to use the file type 'vacsi-tot-dep-xxxx-xx-xx-xxhxx.csv' available here : https://www.data.gouv.fr/fr/datasets/donnees-relatives-aux-personnes-vaccinees-contre-la-covid-19-1/#resource-7969c06d-848e-40cf-9c3c-21b5bd5a874b

I renamed these files 'vacsix' in order to facilitate their use. Given the late date of the project, I don't have many files available. There is currently only the March 28 file given in the project archive, a file from April 25, one from May 4 and finally one from May 12.

I would have liked, if possible, to have one file per week, which seems to me ideal for analyzing data.

## Features
Here are the main features of the program:

  * First of all, via the directional arrows on the keyboard, you can change the date. Also, when you switch between the three displays explained below, it disables the other two.

  * The default display (displayDep() method), when the program is started, displays its name, number and the number of doses performed when the mouse hovers over a department.

  * If you want more information about the department, you can click on it with the mouse and this will activate the detailed information (method displayInfos() and displayInfoFrance()). You will find the name and number of the department, the date, the number of people in the department, the number of doses 1 and 2 and a pie chart showing the distribution of vaccines in percentage.
  In addition, a second information window will appear at the top left of the screen and will give all the information on the country (not the department).

  * Finally, if you wish to have a graph summarizing the vaccinations according to different dates to see the evolution, you just have to press the 'Spacebar' key (method displayCurve()).
