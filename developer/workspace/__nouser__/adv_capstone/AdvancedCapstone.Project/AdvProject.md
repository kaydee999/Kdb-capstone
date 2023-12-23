# Formula 1 Motorsports Project

# Introduction

This project involves completing three sections of work, focused on common problems that Advanced 
kdb+ developers work on:

* Database Maintainence 
* Query Development & Optimization 
* Infrastructure Management 


Where functions are required to be created, test files have also been created that when run will 
check the function against test cases - when all tests pass that function has been 
created correctly (see AdvancedCapstone.Functions.test). Pseudocode for the requested functions has also been 
included in the function files.


# Final Project Background 
It is Grand Prix weekend and you work for the Formula 1 Racing Team 'KX Racing'!

Every aspect of a Formula 1 car is monitored by hundreds of sensors, measuring lap times, tyre and brake temperatures, air flow and engine performance. As you watch a race, hundreds of stories are playing out behind the scenes, such as tyre wear, engine health and driver responsiveness. 

![](./images/carKX.PNG)

Modern Formula 1 cars are fitted with around 200 sensors that transmit millions of data points over the course of a race weekend.

For this project you will take on three different roles in the organisation including:

### 1. Database Maintainer - Pre Race
As a database maintainer for KX Racing you will be responsible for maintaining and adding to the kdb+ database that houses all sensor data from wind tunnel modelling and race car performance.

Responsibilites include:
* Data Loading & Modification
* Table Derivation
* Saving Data to Disk


### 2. Performance / Pit Stop Engineer - Race Day
You will be responsible for developing high performing queries for real time analysis during pit stops in live races. This is a high pressure role where the emphasis is on high performance fast time series analysis.

Responsibilites include:
* Writing flexible APIs (using Functional Statements)
* Debugging issues using error Trapping & Logging
* Code Profiling & Performance tuning


### 3. Infrastructure Engineer - Post Race
As an infrastructure engineer for KX Racing you are responsible for extending the infrastructure as new needs arise. 
This will involve implementing a high security framework for access of our kdb+ system. Performance results are highly confidential and can't fall into a competitors hands!


Responsibilites include:
* Data Encryption
* Access Authentication/Authorization
* Access Restriction

Let's get started! 

# 1. Pre Race 

Today is Saturday of the Grand Prix weekend. Formula 1’s three practice sessions – two 90-minute periods on a Friday, a final hour on Saturday as well as Saturday's qualifiying race have already taken place.

The data from these races has been saved to disk in a paritioned database. Your team has just supplied you with a new data set that needs to be included in our 
database ahead of the race tomorrow and asked that you do some basic quality assurance (QA) review on the existing data. 

## Data Loading & Modification

Let's start first with the QA of our existing data by loading in the database with the following command:
```q
system["l ",getenv[`AX_WORKSPACE],"/f1" ]
```

You can expect the following tables to be present within our database:

1. `sensor` - contains a records of all the time series sensor data from practice session and our qualifying race 
2. `event` - contains a record of all race laps and details the start and end time for each

Both tables contain a common column "`lapId`" which allows us to link between the two tables.

Running ```tables[]``` we should see that there are two tables loaded on this workspace:
```q
tables[]
```

You can also verify that these tables are present by navigating to the "Process" Tab - these should be visible under Global namespace -> Tables.

Let's take a look at their structure using ```meta``` and size using ```count```:
```q
meta sensor
```
```q
count sensor
```
```q
meta event
```
```q
count event
```

Oh no! There is an error with our ```event``` table on disk - the column "`lapId`" is misspelled as "`lappId`".

**1.1 We need our linking column names to be consistent between tables, so let's rename column "`lappId`" to "`lapId`" in the event table**

*Hint: Remember our [dbmaint](https://github.com/KxSystems/kdb/blob/master/utils/dbmaint.md) functions? That script in available the AdvancedCapstone.Setup module on the left hand Workspace panel, see instructions in DeveloperTips.md on loading scripts.*

*Helper Exercises: Try the exercises in the **Partitioned** module before attempting this exercise* 
```q
//first, lets start with where our current directory is: 
\pwd   //this is our database directory! 
```
```q
// your code here - or work in the scratchpad

```
Great! Once you think you've created the column correct, let test by reloading our modified database.

**1.2 Reload database in our workspace to pick up new changes.**

To do this, you need to load in the top level database directory from where you've made your changes.

```q
// your code here - or work in the scratchpad

```

Let's check our table structure again:
```q
meta event
```
Nice job!


## Table Derivation
Now you have loaded our database and have fixed up the naming annomilies you and the rest of the team are ready to use it. 

You have been asked to combine the sensor data with the event data such that you end up with a new table with an average value per sensor per lap interval.

This is illustrated with the following sample data:

#### Inputs:
##### Event Data

| date       | session | lapId | time         | endTime |
|------------|---------|-------|--------------|---------|
| 2020.01.02 | P3      | 1     | 12:00:00.000 |  12:02:56.325        |
| 2020.01.02 | P3      | 2     |   12:02:56.325            |  12:03:33.564       |

##### Sensor Data

| date       | sensorId             | time         | lapId | units     | sensorValue | session |
|------------|----------------------|--------------|-------|-----------|-------------|---------|
| 2020.01.02 | tempBackLeft         | 12:00:00.000 | 1     | degreeCel | 20.2151     | P3      |
| 2020.01.02 | tempBackLeft         | 12:00:01.000 | 1     | degreeCel | 20.19365    | P3      |
| 2020.01.02 | tempBackLeft         | 12:06:01.000 | 2     | degreeCel | 20.39718    | P3      |
| 2020.01.02 | tempBackRight        | 12:00:00.000 | 1     | degreeCel | 20.87774    | P3      |
| 2020.01.02 | tyrePressureBackLeft | 12:00:00.023 | 1     | pascals   | 204.0164    | P3      |
| 2020.01.02 | tyrePressureBackLeft | 12:00:00.444 | 1     | pascals   | 203.2186    | P3      |

#### Output:
##### New Table to be derived
| session | lapId | time         | endTime       | sensorId             | sensorValue |
|---------|-------|--------------|---------------|----------------------|-------------|
| P3      | 1     | 12:00:00.000 | 12:02:56.325  | tempBackLeft         | 20.20437    |
| P3      | 1     | 12:00:00.000 | 12:02:56.325  | tempBackRight        | 20.87774    |
| P3      | 1     | 12:00:00.000 | 12:02:56.325  | tyrePressureBackLeft | 203.6175    |
| P3      | 2     | 12:02:56.325 | 12:03:33.564  | tempBackLeft         | 20.19365    |
| P3      | 2     | 12:02:56.325 | 12:03:33.564  | tempBackRight        | 20.87774    |
| P3      | 2     | 12:02:56.325 | 12:03:33.564  | tyrePressureBackLeft | 203.2186    |

The derivation of this table should be done in 2 steps:
* Create a 'rack' of all possible events and all unique sensors i.e. table should look like Output table above **without** `sensorValue` (*Hint: the function [cross](https://code.kx.com/q/ref/cross/) may be of benefit*)
* Window Join data from this 'rack' table with the raw sensor data to get average `sensorValue` within each lap interval (```time``` and ```endTime```)


**1.3 Create a new function called ```.f1.createLapTable``` that:**

Takes two inputs - the Event data, and Sensor data tables.

Function Logic:

* Creates a rack of all events (i.e. sessions) with each unique sensor name 
* Window Joins ([`wj`](https://code.kx.com/q/ref/wj/)) data from this new 'rack' table with raw sensor data to return the average sensorValue within each lap interval (lap intervals are the period between ```time``` and ```endTime```)
* Remove date column

*Helper Exercises: Try exercises in the **Joins** module before attempting this exercise* 

We recommend testing on a small subset of data first (e.g. `sensor` & `event` information for the last date and before 13:00) 

Please include your finished code in *Workspace->AdvancedCapstone.Functions->.f1.createLapTable*.
```q
// your code here - or work in the scratchpad

```
Once you think you are complete, you can test your function by right clicking the *.fi.createLapTable* function 
in the Workspace navigation and choosing *Code->Run Tests*. 

## Saving Data to Disk
Now we have our function up and running, we want to calculate this table using the data from 2020.01.02 and save this down to disk.

**1.4 Save down the lap table for the P3 practice session on 2nd January 2020 using [```.Q.dpft```](https://code.kx.com/q4m3/14_Introduction_to_Kdb%2B/#1455-qdpft) to the existing f1
database as `lap`.**

*Note: The `sensorId` column should be specified as the column to be parted - ensure this is appropriately structured for this attribute*

*Hint: Ensure to pass the correct directory path*

*Helper Exercises: Try exercises in **Partitioned** module before attempting this exercise* 
```q
// your code here - or work in the scratchpad 
```

Lets check and see if that worked
```q
get hsym `$getenv[`AX_WORKSPACE],"/f1"
```
We can see lap table has been added for 2020.01.02 only. Good database maintainence requires you to fill in any other days with an empty schema of that same table.

**1.5 Run [```.Q.chk```](https://code.kx.com/q4m3/14_Introduction_to_Kdb%2B/#1457-qchk) on the database 
to fill in any missing tables (we have not saved down any data for lap from 1st January so a lap table 
is missing from that partition)**

*Helper Exercises: Try exercises in **Partitioned** module before attempting this exercise* 
```q
// your code here - or work in the scratchpad
```

Lets check and see if that worked?
```q
get hsym `$getenv[`AX_WORKSPACE],"/f1"
```
Now lap should be added for both dates.

### End of Section testing

Once you have completed this section, you can test all your changes by running the below. 
Ensure there are no Fail's before moving onto the next section. 

```q
testSection[`exercise1]
```

Great job! Now our database is prepped and ready to use for race day analysis!

# 2. Race Day

Because a limited amount of people per team are allowed trackside, much of the pre- and post-race 
analysis work is performed by team members back at the team HQ. They parse the data in real time, 
combining it with GPS, weather information, and what the competition is doing, to give them an 
analytical overview of every race.

As part of your typcial role as senior engineer your job involves developing analytics that will be used
on race day.

![](./images/car.PNG)
## Functional Statements
You are tasked with extending the usability of an existing function ```.f1.checkSensor``` which, when given a new dump 
of sensor data checks the sensor values against average benchmark results to see if the readings are within an 
appropriate threshold: 

* If the values are inside the threshold, this will return flag=1b
* If the values are outside the threshold, this will return flag=0b

Take a look at this function definition in the ```.f1.checkSensor``` function file to see it's logic and expected parameters. (*Workspace->
AdvancedCapstone.Functions->.f1.checkSensor*)

This function requires 2 tables as parameters:
* race day data (we will use the data in file AdvancedCapstone.Data/raceDay.csv)
* lap data (this is the derived lap table data we built and saved down in the previous section)

**2.1. Load in a dump of race day data (AdvancedCapstone.Data/raceDay.csv) and save it as a table 
called `raceDay`**

The schema of the table should be as follows:
|column | Type|
|-----|---|
|sensorId| symbol|
|time | time|
|lapId| long|
|units| symbol |
|sensorValue| float|
|session|symbol| 

*Note: the Modules (e.g. AdvancedCapstone.Data) are located in the directory above the f1 database*

```q
// your code here - or work in the scratchpad or use Table Importer Functionality
```


**2.2 Load in lap table FROM DISK for data for 2nd January and save it to a variable called `lapTable`**

Remember if we want to use our lap table we will need to reload our database for it to show up. The table should have a date column after loading in and look something like:

date    |   sensorId   |    session| lapId| time   |      endTime  |    sensorValue
----------- |---------- |---------- |------ |------ |-------------- |--------------------
2020.01.02  | tempBackLeft   | P3    |   1     | 12:00:42.329 | 12:01:14.042  |20.61488   
2020.01.02  | tempBackLeft   | P3    |  2   |   12:01:14.042  | 12:02:27.094  |20.62392   
2020.01.02  | tempBackLeft   | P3    |   3    |  12:02:27.094 | 12:02:54.318 | 20.61883   

```q
// your code here - or work in the scratchpad
```


Now we can call the ```.f1.checkSensor``` function using our new data and our derived lap data from 2nd January
```q
.f1.checkSensor[raceDay;lapTable]
```

You should see a table similar to the below returned:

| sensorId                 | benchmarkValue | avgValue | stdDevValue | diffValue | diffFlag | stdFlag |
|--------------------------|----------------|----------|-------------|-----------|----------|---------|
| tempBackLeft             | 20.62336       | 20.49837 | 0.3385644   | 0.1249834 | 1        | 1       |
| tempBackRight            | 20.62327       | 20.50499 | 0.3367838   | 0.1182886 | 1        | 1       |
| tempFrontLeft            | 20.62542       | 20.50161 | 0.3302598   | 0.1238097 | 1        | 1       |
| tempFrontRight           | 20.62575       | 20.49948 | 0.3350784   | 0.1262708 | 1        | 1       |
| tyrePressureBackLeft     | 203.8602       | 205.8393 | 2.918442    | 1.979087  | 0        | 0       |
| tyrePressureBackRight    | 203.8611       | 203.611  | 0.3293577   | 0.2500971 | 1        | 1       |
| tyrePressureFrontLeft    | 203.8593       | 203.6135 | 0.3302207   | 0.2458253 | 1        | 1       |
| tyrePressureFrontRight   | 203.8585       | 203.6136 | 0.3382713   | 0.2449038 | 1        | 1       |
| windSpeedBack            | 159.7583       | 159.5975 | 0.3364266   | 0.1608275 | 1        | 1       |
| windSpeedFront           | 159.7597       | 159.6095 | 0.33037     | 0.1501811 | 1        | 1       |

The diffFlag and stdFlag are highlighted to analysts via Dashboards on race day to indicate
any issues and which sensors to check. This function has been well received and proven useful during 
race day. 

The pit stop analysts have asked for the function to be extended to allow them to query for one sensor 
only at a time.

You have a few options here - the short & simple solution would be to leave ```.f1.checkSensor``` in its
current form and add a filter afterwards to restrict the sensors.

For e.g.
```q
select from .f1.checkSensor[raceDay;lapTable] where sensorId in `tempBackLeft
```

However as a senior engineer you recognise this as an opportunity to reconfigure the code into a more 
useful functional form. This has a few benefits over the more simple solution:
* User can dynamically pass only sensors they care about
* Any aggregations & calculations will be carried out on only data of interest - this differs to 
simple solution and if we are querying over a lot of data/days huge performance benefits can be achieved
* For data visualization is it nearly always best to provide data in its most aggregated and 
filtered form as early as possible

**2.3. Modify the function ```.f1.checkSensor``` to change it to its functional form**

This function should takes 3 parameters instead of 2. The additional new parameter ```mysensor```is expected to 
be passed one of the following inputs:


| mysensor      |        What should be returned?                                                                                                                                                                       |
|-------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| temp  | sensorId's like "temp*"                                                                                                        |
| tyre | sensorId's like "tyre*"                                                                          |
| wind  | sensorId's like "wind*"                                                                                                                                            |
| all   | all sensorId's in table |
   

You can define a dictionary within this new function mapping the logic from the table above. 

*Helper Exercises: Try exercises in **Functional Statements** module before attempting this exercise* 
```q
// your code here - or work in the scratchpad
// or function file in AdvancedCapstone.Functions
```

Once defined the following should return only rows for temperature sensors:
```q
.f1.checkSensor[raceDay;lapTable;`temp]
```
and only rows for wind sensors:
```q
.f1.checkSensor[raceDay;lapTable;`wind]
```
and all rows:
```q
.f1.checkSensor[raceDay;lapTable;`all]
```
Nice job! You have just created a modified version of the function that is more elegant and performant 
and meets the users requirements.

To test your code, please ensure your function logic is included in the *Workspace->AdvancedCapstone.Functions->.f1.checkSensor* 
and then you can right click *Code->Run Tests* to verify correctness.

## Error Trapping & Logging
Some pit stop engineers are complaining that when they use this function it doesn't work as they would expect.

They have logged the following bug report:

# 
**Bug Reported:**
*When runing the following code:*
```q
.f1.checkSensor[raceDay;lapTable;`temperature]
```
*Incorrect sensor values returned - we would expect only the rows for temperature to be returned.
This is misleading please resolve ASAP.*
#

What has happened here? You can see that they should be using ```temp``` rather than ```temperature``` 
as a parameter! Rather than going back and telling them this you decide to follow good code practice 
and get the function to tell them instead.

You need to make the function more robust and add some error trapping and logging so that users 
know what are the parameter input options.

**2.4. Augment ```.f1.checkSensor``` to check if the `mysensor` parameter has received one of 
the acceptable options and do:**
* If yes - carry on with function execution
* If no - stop execution of function and return the following message to the user.
```
"temperature is not a valid option for mysensor - valid options include `temp`tyre`wind`all"
```
* where `temperature` is the invalid mysensor parameter passed by user

*Helper Exercises: Try exercises in **Debugging** module before attempting this exercise* 
```q
// your code here - or work in the scratchpad
// or function file in AdvancedCapstone.Functions
```

Let's check that has worked. If we used signal we should now see an orange ribbon popup with the 
above message when running the following:
```q
.f1.checkSensor[raceDay;lapTable;`temperature] // should error
```

```q
.f1.checkSensor[raceDay;lapTable;`wind] // should return
```


Awesome! You rolled out this change and marked this bug as resolved. The users are happy as with this 
new error message it is obvious to them what options they need to pass.

The more error trapping, breakpoints and descriptive logging you add to your code the more robust it 
becomes which ultimately means happier users and less bugs reported! 


## Code Profiling & Performance

Your function has gone down well especially with the recent changes to make it more dynamic and the 
helpful addition of logging. 

It has been requested by the Team Principal that a new Dashboard be created for Race Day using the data
you have curated.

A junior developer was asked to create a wrapper function (```.viz.createDashboard```) and build some 
Visualizations using the data from it.

Here is what the Dashboard looks like:

![](./images/dashboardF1.PNG)

There have been complaints that this Dashboard is running too slowly to be useable during a race. 
You need to investigate the dashboard function the junior developer created and try to improve 
performance!

**2.5. Given the function ```.viz.createDashboard``` - profile it and refactor to improve performance 
so that it completes execution in half the original time**
```q
\t .viz.createDashboard[] 
```

*Hint: select above function in scratch and click 'Profile' to find the bottleneck function* 

```q
// your code here or work in scratchpad
```
This function calls multiple nested functions so your task is to identify the bottleneck function. Then apply what you have learned in this course in order to make it run faster (half the original time).

You may want to make changes to the table format on disk (hint: attributes), changes to the function itself or both!

### End of Section testing

Once you have complete this section, you can test all your changes by running the below. Ensure there are no Fail's before moving onto next section. 
```q
testSection[`exercise2]
```

Great job! You have improved query performance and completed this section.

# 3. Post Race

Up until now KX Racing infrasture has been completely locked down to outside access by firewalling the 
server on which it's running. The FIA has now mandated every Formula 1 Racing Team must provide a 
report summary via API call.

In order to make this available we need to lift the firewall and implement security protocols so that 
only approved users can gain access.

The first thing thing to do is to load our database in a remote process so we can implement 
security on that process. In many real life scenarios you will be accessing data from a seperate 
process to the one you are developing code on.

You need to load the partitioned dataset into the remote process (port=5099) as per diagram below.

![](./images/perms1.PNG)

**3.1 Load f1 database to remote process (port=5099)**

First open a handle to this port and save this to a variable called ```hdbH```. Then you can load the database using this handle.

```q
// your code here - or work in the scratchpad
```

*Note you also have the option to access remote process using Developer's Remote Scratchpad instead of via handle ```hdbH``` - see instructions in DeveloperTips.md.*



## Encryption

In *Workspace->AdvancedCapstone.Data* we have a `users.txt` file that contains all users and their 
passwords. We have noticed that the passwords aren't encrypted and therefore isn't very secure. 
You are tasked to apply a SHA-1 hash on each password. 

**3.2 Load in `users.txt` file and save to local variable `.perm.users` appling SHA-1 hash on the password column, types should be as follows:**

| column name      | type     |
|------------------|----------|
| user             | s        |
| password         | X        |
| api              | s        |

The table should be keyed on the first column user.

*Hint: The function for SHA-1 hash can be found [here](https://code.kx.com/q/ref/dotq/#qsha1-sha-1-encode)*

*Helper Exercises: Try exercises in **Advanced IPC** module before attempting this exercise* 

```q
// your code here or work in remote scratchpad
```
To test your code, run the tests at Workspace->AdvancedCapstone.Functions.test->.perm.users.quke to verify correctness.

**3.3 Save this new table on the HDB process 5099**

*Hint: This can be done by using the remote scratchpad or sending over a handle* 

```q
// your code here or work in remote scratchpad
```


## Authentication

Now that we have the user information for each of the users loaded in `.perm.users`, we need to 
implement an authentication check on our remote process to validate new connections against our 
approved users.

In kdb+ this is done by defining `.z.pw` which acts as the first check that is done when an attempt is made 
to connect to a process. 

![](./images/perms2.PNG)

**3.4 Define `.z.pw` on 5099 to check if the incoming user is authenticated**

The function should have two parameters:
* params 1 should be the user (a symbol)
* params 2 should be the password (a string)

in which it checks if the password matches the password found in .perm.users. 
If it doesn't match, it should return an `'access` error. 

*Helper Exercises: Try exercises in **Advanced IPC** module before attempting this exercise* 
```q
// your code here or work in remote scratchpad
```
 
Let's test if we can access using the different users with the **correct** password. This should fail 
with an `'access` error if we have defined `.z.pw` correctly.

```q
wrongPassword: hopen `::5099:jmurphy:bahrain2021
```


Excellent - this is great, we have now secured our process from unauthorised users!

## Authorization
We can see that everyone should be able to access the data with the new security protocols and that our
users include a mix of internal employees and an external FIA employee. 

The last thing we need to implement is to restrict what the FIA can do. With this in mind, we are 
allowing the FIA to access only one function. 

This is the authorization step that comes after sucessful authentication (`.z.pw`) - we want to introduce 
authorization within the [`.z.pg`](https://code.kx.com/q/ref/dotz/#zpg-get) event handler that is called
when a synchronous request is made to a kdb+ process.

![](./images/perms3.PNG)

**3.5 Define a function on our local process called `.perm.parseQuery`:**

This function should: 
* take one parameter `x` which is a string
* parse this string to return the first element of the parse tree

such that:

```
.perm.parseQuery[".f1.checkSensor[raceTab;lapTab]"]
// returns
`.f1.checkSensor

.perm.parseQuery[".fia.getSummaryReport[`today]"]
// returns
`.fia.getSummaryReport

.perm.parseQuery["select from tab"]
// returns
?
```

*Hint: Something in this [section](https://code.kx.com/q/wp/permissions/#users) might help you!*

You may want to define this locally first and then use `set` to define on remote process once you are 
happy with this function.
```q
// your code here or work in remote scratchpad
```



**3.6 Define `.z.pg` on remote HDB process 5099 to allow the FIA to access only the function 
listed in `users.txt`:**


This is quite advanced, so here are the steps required: 
* Lookup incoming users api access in `.perm.users`
* If they are a user with api access `all` let them run whatever their incoming query is
* If the first element of their query matches permissable api listed in .perm.users 
(Hint: use .perm.parseQuery here) let them run their query
* Otherwise return the symbol `notAuthorized in the Console

*Helper Exercises: Try exercises in **Advanced IPC** module before attempting this exercise* 

```q
// your code here or work in remote scratchpad
```
*NB: You may run into the issue were you defined .z.pg erroneously on first few attempts which 
blocks subsequent calls to the Server. We recommend testing this function locally first to ensure 
the function works before defining it on Server.*

If you end up incorrectly defining `.z.pg` on the remote server (this does happen!) remember you can 
revert `.z.pg` on the Server process by running the expunge command asynchronously:
```q
(neg hdbH)"\\x .z.pg"
```

After defining `.z.pg` correctly you should see the following behaviour:

Calling as user with all access:
```q
jmurphyHandle:hopen `::5099:jmurphy:bahrain22
jmurphyHandle"tables[]"  // works as user jmurphy has access to run anything
```

Calling as fiauser a random query returns:
```q
fiaHandle:hopen `::5099:fiauser:getmeallthedata
fiaHandle"tables[]"  // get `notAuthorized
```

Calling as fiauser with permissable api:
```q
fiaHandle".fia.getSummaryReport[]"  // works as user fiauser is allowed to run this predefined api
```

### End of Section testing

Once you have complete this section, you can test all your changes by running the below.
```q
testSection[`exercise3]
```


Congratulations you've completed all sections! 


![](https://media.giphy.com/media/1X8865dbCf8xNrDPG6/giphy.gif)

# Final Submission 
To be marked complete and receive your certificate there are two final steps: completion of the post course questionnaire and submission of the above project.

1. Fill out the post workshop survey [here](https://forms.gle/1C5Za8xT12cM7MbN8) - This must be filled out in order to receive your certificate!

2. To be marked completed, please run the below which will test the variables and functions you've 
created: 
```q
submitProject["<your email here>"]
```

We hope you enjoyed the course and found it worthwhile! 

# Happy Coding!
