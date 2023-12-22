### STOP & DO THIS FIRST BEFORE READING ON:
Right click whitespace within this file  -> Select 'Render Markdown' 

This formats this markdown file into a prettier version that makes it easier to read, you can Render all markdown files in this course :-)

Kx Developer - Getting Started
=========
This file will go through the key features of KX Developer and how to get the most benefit 
from the IDE as a developer.

## Running kdb+/q code
You can run adhoc queries in the scratchpad by using `CTRL+D` or `CTRL+Enter`. You
will see the display in the console. 

## Remote Scratchpad
You can connect to a remote process by going to `Tools` > `Remote Scratchpad`.

## Importing existing code
Before we get started, you are lucky to have all the code that we will be using during 
this training course pre-loaded for you into Kx Developer. 

When you are starting from scratch, you have two options with import existing code:
* From Github
* Uploading from local/remote server. 

Using Github, we can import a repo. 
1. Right-click on the workspace, click on `git` > `clone`. 
2. Insert the url to the repo that you wish to load in. 
3. Click on pull and you can choose which branch to pull.
4. You will be able to see the repository living in your workspace.

## Importing data using Kx Developer
One of the benefits of using Kx Developer is how easy it is to import files.

Using the [Data Importer](https://code.kx.com/developer/importer/), we can easily import many different file formats.

Open the *Table Importer* from the `Tools` menu. Specify to input into the fields.

With the file selected, the bottom region of the table importer will display a 
preview of the data. With the view option set to `Table`, a tabular view of the
data is presented. To see the underlying textual data, switch the view to `Text`.        

Pressing `Next` takes you to the *Schema* tab where the column names and types
can be manipulated before importing. 

Pressing `Next` takes you to the *Import* tab where a final action can be selected. 

## Loading scripts

You can load in scripts by right clicking on the name of the script in left hand panel and selecting `Code` -> `Run`

  
## Visual inspector 
The [Visual Inspector](https://code.kx.com/developer/inspector/) allows the user to visualize data contained in lists, tables or dictionaries. 
The inspector can be opened by picking *Tools > Visual Inspector* from the main view in Developer.

We can also save plots and reuse the configuration on different data. It saves 
the plot as a kdb+/q function. 

## Creating a function
We organise our code on a modular level. As you can see from the repos that are preloaded, functions live in one module and 
data lives in another one.    

Let's create a new module that will contain all the functions that we will create. 
Right-click on the repo and create a new module. Create a new 
function in the module. 

The function template allows us to document as we code the function. There is a in-built [linting](https://code.kx.com/developer/linting/) tool that will 
give us warnings if we haven't documented the function. Once we have the function 
saved, we can use it in our process. In the scratchpad, you can hover over the function name to see the documentation. 

## Creating a test for a function 
As mentioned above, we recommend to create a new module for all testing files.  On the newly created module, create a new test and call it the same name as the function that you are testing.
This lets Kx Developer know that the test is associated with the function.

For more information about creating a test file, check out this [page](https://code.kx.com/developer/testing/)

## Quick debugger
There is a debugger installed in KX developer which allows the user to see where the error is occuring in the code. 
If a line of code is giving you an error, right-click on that line and run the quick-debugger. 

More information is found [here](https://code.kx.com/developer/quick-debugger/)

## Profiling
Another thing that we can do with a function in Kx Developer is profiling. This will
allow us to investigating memory use and run time of a function. 
Right-click on a function and click on *profile*. 

More information is found [here](https://code.kx.com/developer/profiler/)

## Plotting libraries 
The grammar of graphics library underpins the 
*Visual inspector* and also gives you more freedom to do whatever you want. Let's look
at the documentation associated with this library which can be found under 
the `help` > `Developer User Guide` tab.

These new plots can be saves as functions and can re-run on new data.

## Need more help?

All functionality of the KX Developer IDE is found under the `help` > `Developer User Guide` tab and also check out the free [Introduction to Developer](https://kx.com/academy/courses/introduction-developer/) course on KX Academy.
