# KX Fundamentals Final Project

This repo contains the final capstone project associated with the Certified KX 3 day Fundamentals Training Course.

To start using it:

 1. go to the 'Launcher' tab (or open a new JupyterLab tab)
 1. open a 'Terminal'
 1. run the script using `./setup.sh` within `~/course-fundamentals-capstone`
      * ignore warnings (`odbc.k` and `namespace collision`)
 1. (optionally) close the terminal window
 1. open (or refresh) KX Developer
 1. open the 'funds_capstone' workspace


## Modules 
| Module Name                     | Module Description                       |
|---------------------------------|------------------------------------------|
| FP.Data           | Raw data required for project            |
| FP.Functions      | Function files outlined with pseudocode  |
| FP.Functions.test | Test qCumber files                       |
| **FP.Project**        | **Main Project Description & Questions** |
| FP.Setup          | Setup functionality and scripts          |
| DeveloperTips.md                | KX Developer key features & helpful tips |
| README.md                       | Learning Environment considerations      |


## Where to start

Go to kxscm -> module -> FP.Project -> project.md. In here you will find project description and Questions. 

It would be a good idea to add your code to project.md and continue to keep a backup up locally by copy & pasting somewhere. You can also work in the scratchpad and/or FP.Functions.

## Testing your code

### testSection
You will notice at the end of each section an option to run testSection[exercise] where exercise can be one of exercise1 exercise2 exercise3.

This is a chance for you to test code in this section before moving onto the next. 

### submitProject
If all of these pass then submitProject should also return with no Fails. Once you this is done and you have submitted the survey then you are done and should receive a certificate by email confirming this.

### FP.Functions.test
You will also see a module called FP.Functions.test - this contains some tests you can run throughout the project too. 

These are mentioned inline in the appropriate places in project.md. These can be useful if you are stuck on a question and would like to see expected behaviour with some sample data.
