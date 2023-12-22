# Options Trading Desk Capstone Project

# Introduction

This project involves completing three sections of work: 
1. Data Loading 
2. Data Cleaning 
3. Data Analysis and Reporting - 3 worked problems:
   - Quality of Execution  
   - Profilability Analysis
   - Profiling and Outlier Analysis 

Where functions are required to be created test files have also been created that when run will 
check the function against test cases - when all tests pass that function has been 
created correctly (see FP.Functions.test). Pseudocode for the requested functions has also been 
included as a commented preface within the testing files (so it only has to been seen if desired).


# Final Project Background 
You are working as a data analyst for the Options trading team of a large investment bank.

![](./images/stock.jpeg) 

Options are financial instruments whose value is derived from the value of underlying 
securities such as stocks - aka Derivatives. An options contract offers the buyer the 
opportunity to either buy or sell the underlying asset. 


 - Call options allow the holder to buy the asset at a stated price within a 
 specific timeframe.
 - Put options allow the holder to sell the asset at a stated price within a 
 specific timeframe.

Each option contract will have a specific expiration date by which the holder must exercise 
their option. The stated price on an option is known as the strike price. 

Financial knowledge is not required for this course but will help provide context. 
[Investopedia](https://www.investopedia.com/terms/o/option.asp) is a great resource if you want to learn more about Options and other financial instruments.



## Dataset

When we first loaded this dataset a series of actions occurred which created a database
for us in this environment.

As part of the initialization we created a partitioned database with the following tables:
1. `trade` - Contains all the trade details
2. `spread` - Contains the option spread definitions
3. `nbbo` - Contains the National Best Bid Offer quotes for each option


In many real-world situations the data you need may not be present on your existing process 
and instead you will need to connect to internal services to get this data. To simulate this 
a separate q process is running (in the background currently) which has the following tables:
1. `inst` - Contains Instrument details (Underlying stock)
2. `option` - Contains the option reference data (strike price, expiry etc.)

Finally, in our `FP.Data` module we have a csv file containing some raw exchange messages - 
`message.csv`


select from spread
# 1. Data Loading
## Loading the database

Let's start with loading in our newly created partitioned database which was created at `getenv[`HOME],"/fundamentals_capstone_dbs/"`.

**1.1  Load into the current process the database that was created**

```q
//your code here - or work in the scratchpad
\l /home/jovyan/fundamentals_capstone_dbs/
//select from nbbo where date=2020.08.03
```

Verify that these tables are present by navigating to the "Process" Tab - these should be visible
under Global namespace -> Tables. 

**1.2 Create a function called `showTableSummary` which takes no inputs and returns a dictionary
of the tables within the process associated to the number of records for each. Call this to
look at the current process tables.**

*Note: A template has been created in FP.Functions if desired. Once defined, run the 
corresponding test file (functionName.quke) to test if working correctly*.

*Help: Try the exercises in [Queries](https://kx.com/academy/modules/queries-qsql/#introduction-qsql) module* 

```q
//your code here - or work in the scratchpad
showTableSummary{
 tables[]!count each value each tables[]
    }
```

**1.3 Now that we know the table is relatively small, we can extract a symbol list of the unique options
present in the `trade` table and store in a variable `uniqueOpts`:**

*Hint: You might want to check the table schema to determine the column namings*

```q
//your code here - or work in the scratchpad
uniqueOpts:exec distinct option_id from select distinct option_id from trade
type uniqueOpts
```


## Extracting remote data 
The reference data for these Options are actually stored on a separate q process that operates
as an internal service. This process is restricted in that it **only allows calls to its APIs.** 

The two available APIs are the following: 
*  `getOptionRef` - This API takes as its only input a symbol list of Options and returns a table with 
the associated Reference data
*  `getInstRef` - This API takes as its only input a list of longs corresponding to Instrument IDs and returns a table with 
the associated Reference data

This Reference data process is a q process which is accessible on port 5010.


**1.4 Using your IPC knowledge, connect to this service and store the open handle in a 
variable `refServiceHandle`**

*Help: Check out this [Introduction to IPC](https://youtu.be/8eoysfqO3UY) and more information [here](https://code.kx.com/q4m3/11_IO/#116-interprocess-communication)* 

```q
//your code here - or work in the scratchpad
refServiceHandle: hopen `::5010
```


**1.5 Using the handle `refServiceHandle` and the `uniqueOpts` variable we created before, call the 
`getOptionRef` API and retrieve the associated Options Reference data. Store the returned table 
in a variable `optRef`.**
```q
//your code here - or work in the scratchpad
optRef: refServiceHandle(`getOptionRef;uniqueOpts)
optRef
```


**1.6 Now, extract the unique instruments in our new `optRef` table, and call the `getInstRef ` API 
to return the Instrument Reference data and store in a table `instRef`:** 
```q
//your code here - or work in the scratchpad
inst: exec distinct inst_id from optRef
instRef:refServiceHandle(`getInstRef;inst)
```


Great! Now we have our referenece data that we can make use of later. 

## Importing data from Files
Finally, we will load in data that is stored in a CSV file. The CSV file is located at the following
directory location : 
```q
csvPath:getenv[`AX_WORKSPACE],"/FP.Data/message.csv"
```
This table has two columns - the `trade_id` column (should be typed as per our `trade` table) and an 
`exch_message` column which stores a string of the exchange message associated with the trade identified.

**1.7 Using the Tables Importer (or otherwise) load into the current process the `message.csv` 
file and store in a table called `messages`. The csv is stored in the `FP.Data` module. The `exch_message`
column should be read in as a string, and the `trade_id` column should be consistent with the `trade`
table column of the same name.**

*Note: the table name is messages with an s, not just message.*

*Help: Try the exercises in [Working With Files](https://kx.com/academy/modules/working-files/#saving-loading-csv). And for a refresher on using Tables Importer refer to DeveloperTips.md or watch [here](https://kx.com/academy/modules/introduction-developer/#importing-data)* 


```q
//your code here - or use the table Importer
messages: ("**"; enlist(","))0:`$get `csvPath
```

Verify that all tables are now present in your process (Process tab->Global->Tables) - you should have the following: 
* nbbo (from database)
* trade (from database) 
* spread (from database) 
* messages (loaded from csv) 
* optRef (retrieved from service)
* instRef (retrieved from service) 

Congratulations! You've completed the Data Loading section of the Final Project!

### End of Section testing

Once you have completed this section, you can test all your changes by running the below. 
Ensure there are no Fail's before moving onto the next section. 

```q
testSection[`exercise1]
```

# 2. Data Cleaning

As any data scientist will tell you, getting the data is sometimes just where the fun begins. Now 
that we have loaded the data, our next step is to clean and parse it. In real-life 
projects, the data is almost never in the desired format. 


For our data, there are a number of places where we need to include additional 
parsing: 
* The `optRef` table has the expiry as a string, we need to change this from string
to date 
* Our `messages` table exch_message field (also a string) encodes some additional 
information that we want to extract. 
   
**2.1 In the `optRef` table, the `expiry` column is in a string format. Convert this into the kdb date format.**

*Help: See [Casting](https://kx.com/academy/modules/casting/#casting-text)* 

```q
//your code here 
update "D"$expiry from `optRef
optRef
```


Once a trade is successfully executed, the exchange sends a string message which 
contains the option name (or spread name in case of spreads), successful trade, 
inst type (option or spread) and broker id. The format differs across exchanges. 
For exchange messages from CME, the format is
    
        “CME-<option name>-<broker id>” 

whereas for exchange messages from ISE, the format is - 
    
        “ISE-<broker id>-<option name>”
       
We want to be able to extract the broker ID from these exchange messages.


**2.2 Create a function `extractBrokerId` that will return the brokerId as a long when 
passed an exchange message.**

`extractBrokerId “CME-TSLA20200920C1700-709”` should return a value of 709, while 
`extractBrokerId “ISE-708-TSLA20200920C1700”` should return a value of 708. 

*Note: A template has been created in FP.Functions if desired. Once defined, run the 
corresponding test file (functionName.quke) to test if working correctly*.

*Help: See [String Manipulation](https://kx.com/academy/modules/string-manipulation/#string-manipulation)* 

```q
//your code here - or work in the scratchpad
extractBrokerId:{[exchMsg]
    splitMsg:vs["-"; exchMsg];
    $[splitMsg[0]~"CME";"J"$splitMsg[2];"J"$splitMsg[1]]
    }
//extractBrokerId["ISE-512-TSLA20200920C1700"]
```



Now we are able to extract this information from the string, we can apply this to 
our message table.

**2.3. Using the `extractBrokerId` function (or otherwise), update the `messages` table
to have a new column `broker_id` which contains the brokerId as per the `exch_message`
column. This change should be kept and reflected in our `messages` table.**

*Hint: you might want to use an iterator to loop the function over all messages 
in the column* 

```q
//your code here - or work in the scratchpad
update broker_id:(extractBrokerId')exch_message from `messages
/messages
```

Verify that the modifications you've made are in place:

* Expected schema for the `optRef` table: 

|Column Name| Column Type
|---------| -----
|option_id| symbol    
|inst_id  | long    
|opt_type | symbol    
|strike   | long    
|expiry   | date
* Expected schema for `messages` tables: 

|Column Name| Column Type
|---------| -----
|trade_id| string (character list)   
|exch_message  | string (character list)     
|broker_id   | long


Congratulations! You've completed the Data Cleaning section of the Final Project! 

### End of Section testing

Once you have completed this section, you can test all your changes by running the below. 
Ensure there are no Fail's before moving onto the next section. 

```q
testSection[`exercise2]
```

# 3. Data Analytics and Reporting

## Quality of Execution
A common area of focus when trading is ensuring "best execution" was received on all trades. This 
involves checking to see if you got the best possible price on the market for each of the 
trades.

The nbbo table contains the best bid and best offer quotes available on all the exchanges for 
every option. This is the data we will use to check our trade price. 


In the case of a purchase (side = B), our price should be less than or equal to the best ask price 
in the market, otherwise we could have bought it at a lower price on the market. Similarly, If we are 
selling (side = S), our price should be greater than or equal to the best bid on the market, or else 
we could have sold it for more on the market at that time.

Examples: 
 - We make a buy trade for 50$ at 10am, when the market best ask was 55$ - Good Trade
 - We make a buy trade for 60$ at 10am, when the market best ask was 55$ - Bad Trade
 - We make a sell trade for 50$ at 10am, when the market best bid was 45$ - Good Trade
 - We make a sell trade for 40$ at 10am, when the market best bid was 45$ - Bad Trade

In order to determine if a trade was "good" or "bad" we first need to contextualise our trade data
with the market information. 

**3.1 Looking only at the last date in our database, create a new table `tradeContext` which has all 
the `trade` table information. This should have two extra columns - `bid` and `ask` - which contain 
the `nbbo` information for that particular trade `option_id` as at that trade time.**

This is illustrated with the following sample data:

#### Sample Inputs:
##### Trade Data

| date       | option_id       | trade_id | time         | price    | qty | side | edge      | exch_id | broker_id |
|------------|-----------------|----------|--------------|----------|-----|------|-----------|---------|-----------|
| 2020.08.06 | FB20200720C230  | "258"    | 13:01:30.268 | 22.82637 | 99  | S    | -230.8243 | 4       | 705       |
| 2020.08.06 | KO20201120P55   | "142"    | 10:52:10.106 | 55.65839 | 68  | B    | 172.7843  | 3       | 703       

##### Nbbo Data

| option_id      | time         | bid   | ask   |
|----------------|--------------|-------|-------|
| KO20201120P55  | 09:30:10.804 | 82.58 | 83.27 |
| KO20201120P55  | 09:30:35.301 | 17.71 | 18.09 |
| KO20201120P55  | 09:31:10.594 | 77.74 | 78.74 |
| FB20200720C230 | 09:30:15.138 | 47.32 | 48.81 |
| FB20200720C230 | 09:33:43.764 | 44.55 | 45.9  |

#### Sample Output:
##### New Table `tradeContext` to be derived
| date       | option_id       | trade_id | time         | price    | qty | side | edge      | exch_id | broker_id | bid   | ask   |
|------------|-----------------|----------|--------------|----------|-----|------|-----------|---------|-----------|-------|-------|
| 2020.08.06 | FB20200720C230  | "258"    | 13:01:30.268 | 22.82637 | 99  | S    | -230.8243 | 4       | 705       | 44.55 | 45.9  |
| 2020.08.06 | KO20201120P55   | "142"    | 10:52:10.106 | 55.65839 | 68  | B    | 172.7843  | 3       | 703       | 77.74 | 78.74 |


*Help: Try the `aj` exercises in [Joins](https://kx.com/academy/modules/tables-joins/#inner-asof)* 

```q
//your code here - or work in the scratchpad
/tradeContext
tradeLastDate:select from trade where date=last date
nbboLastDate:select option_id,time,bid,ask from nbbo where date=last date
tradeContext:aj[`option_id`time;tradeLastDate;nbboLastDate]
```


Now that we have the market context for each trade, we can now begin to classify trades into "good"
and "bad" trades.

**3.2 Create a new function called `classifyTrades` which takes a table that has columns  `price`, 
`side`, `bid` and `ask` (like `tradeContext` for example) and returns that table with a new column 
called `exQuality`. The `exQuality` column stores either good (`1b`) or bad (`0b`) (as boolean values)
depending on the `price`, `side`, `bid` and `ask` prices.**

*Note: A template has been created in FP.Functions if desired. Once defined, run the 
corresponding test file (functionName.quke) to test if working correctly*.

*Help: See [Execution Control](https://kx.com/academy/modules/execution-control/#vector-conditional)* 

```q
//your code here - or work in the scratchpad
classifyTrades:{[table]
    exQuality: ?[table[`side]=`B;
        table[`price]<=table[`ask];
        table[`price]>=table[`bid]];
    update exQuality from table
    }
    
/classifyTrades[tradeContext]    
```

Now we have a means to identify the "bad" trades that is applicable beyond just the `tradeContext` 
table.


**3.3 Using the `classifyTrades` function (or otherwise) retrieve the rows from the last date of 
our `tradeContext` table that had poorer than market execution. Store these trades in a variable `badTrades`.** 
```q
//your code here - or work in the scratchpad
badTrades:select from classifyTrades[tradeContext] where exQuality=0b
```


Now that you've found the trades that are suspect, you may want to share with others.

**3.4 Using the `save` keyword save these `badTrades` to a CSV file called badTrades.csv
at the following `getenv``AX_WORKSPACE` location :**
```q
getenv`AX_WORKSPACE  //execute this to see the folder you need to save the CSV to
```

```q
//your code here - or work in the scratchpad
save `$getenv[`AX_WORKSPACE],"/badTrades.csv"
/read0 `:/opt/kx/developer/workspace/__nouser__/funds_capstone/badTrades.csv
```

We should now see our csv file in that folder: 
```q
//test if successful 
`badTrades.csv in key hsym `$getenv`AX_WORKSPACE
```
And can also verify that all looks ok:
```q
read0 `$getenv[`AX_WORKSPACE],"/badTrades.csv"
```

### End of Sub Section testing

Once you have completed this sub section, you can test all your changes by running the below. 
Ensure there are no Fail's before moving onto the next section. 

```q
testSection[`exercise3]
```


## Profitability Analysis
Edge is a measure of revenue gained from a trade and you have been asked to produce a report analysing
the profitability of the trades in the most recent trading day. A number of specific questions 
have been raised by the business team to help determine the strategy going forward.


**4.1 What is the total edge (as `edge`), total traded volume (as `qty`) and the number of trades (`numTrds`)
in each 15 minute window (`minute`) starting from 0930hrs to the End of day on the latest date? 
Store this in a variable called `edge15`.**

*Help: Check out this video showing [temporal arithmetic](https://kx.com/academy/modules/introductory-workshop/#qsql-4)* 


```q
//your code here - or work in the scratchpad
/trade
edge15:select edge: sum edge, qty:sum qty, numTrds:count i by 15 xbar time.minute from trade where date=last date
```

**4.2 Use the visual Inspector to create a chart of the above `edge15` (right click -> inspector). Choose 
first a chart type (.e.g bar, or scatter), then fill out the right hand side parameters. Choose as 
the x-axis `minute`, the y-axis should show `edge` and then add a fill colour with the `qty`.
When complete save the visualisation as a function called `edgeQtyPerMinute`.**

There is some confusion about which times during the day see the most trade activity or produce the 
most edge.

**4.3 Create a function `returnN` that will extract the top N or bottom N records in a table 
after ordering by a specified column in the table. The function should have the following inputs:** 
 - orderColumn (column to order by)
 - order (either \`top i.e. highest values or \`bottom i.e. lowest)
 - N (number of entries)
 - t (table)
 
Final output returned from function should be in ascending order by the `orderColumn` specified.

*Note: A template has been created in FP.Functions if desired. Once defined, run the 
corresponding test file (functionName.quke) to test if working correctly*.
```q
//your code here - or work in the scratchpad
returnN:{[orderColumn;order;N;t]
    $[order=`bottom; 
        select[N] from orderColumn xasc t; 
        select[-1*N] from orderColumn xasc t]
    }
/returnN[`time;`bottom;10;tradeLastDate]
```


The business team are requesting a breakdown of the top 5 15 minute periods for edge generation, and 
separately for traded quantity.

**4.4 Using the function `returnN` and the table `edge15` (or otherwise) create a new variable 
`top5EdgeTimes` which returns the 5 best (i.e. most profitable) 15 minutes in the last trade date for edge.** 
```q
//your code here - or work in the scratchpad
top5EdgeTimes:returnN[`edge;`top;5;edge15]
```


**4.5 Similarly, create a new variable `bottom5QtyTimes` which returns the 5 worst 15 minutes in the 
last trade date for traded qty volume.**
```q
//your code here - or work in the scratchpad
bottom5QtyTimes:returnN[`qty;`bottom;5;edge15]
```


Finally, to put the questions to rest they have requested that the relationship between the traded
quantity and the edge be quantified. 

**4.6 Extract the 15 minute aggregate series for each of `edge`, `qty` and `numTrds` using `edge15` 
(or otherwise) as a dictionary and store this in a variable `timeSeries`.**
```q
//your code here - or work in the scratchpad
timeSeries:exec edge,qty,numTrds from edge15
```

**4.7 Finally, using `timeSeries` (or otherwise) calculate the correlation between the 15 minute timeseries
for `edge` with each of `qty` and `numTrds`. Store this in a dictionary called `edgeCor` with `edge`,
`qty` and  `numTrds` as the keys and the values as their correlation with the `edge` series. Thus 
the value for `edge` should be 1.**

*Help: Check out this video showing [Iterators](https://kx.com/academy/modules/introductory-workshop/#functions-2)* 


```q
//your code here - or work in the scratchpad
edgeCor:timeSeries[`edge] cor/: timeSeries
```

### End of Sub Section testing

Once you have completed this sub section, you can test all your changes by running the below. 
Ensure there are no Fail's before moving onto the next section. 

```q
testSection[`exercise4]
```

## Profiling and Outlier Analysis

The business team are keen to understand what a "typical trade" looks like for each option and have
requested this information be presented. To generate a profile for each option your team has 
recommended you present the total number of trades, the average edge, and min and max volume. 

**5.1 Create a table called `optProfile` which has the total number of trades (`numTrds`), the average 
edge (`avgEdge`), and min and max volume (`minQty`,`maxQty`) broken down by option for the latest date. The table
should be keyed on the column `option_id`.**
```q
//your code here - or work in the scratchpad
optProfile: select numTrds:count i, avgEdge:avg edge, minQty:min qty, maxQty:max qty by option_id from tradeLastDate
```


Some attendees are curious about what the trades which have greater than average 
edge look like, relative to the overall profile.

**5.2 Using `fby` (or otherwise), create a table `edgeProfile` which contains the same information as 
`optProfile`, but which only includes trades where the edge collected was greater than the average edge 
collected by that option. Again, the table should be keyed on the column `option_id`.**

*Help: Check out this video showing [fby](https://kx.com/academy/modules/introductory-workshop/#qsql-3)* 


```q
//your code here - or work in the scratchpad
edgeProfile:select numTrds:count i, avgEdge:avg edge, minQty:min qty, maxQty:max qty by option_id from tradeLastDate where edge > (avg;edge) fby option_id
```


Not all attendees know the options underlying instruments, and have requested that this information 
be included in the presentation of the higher Edge Profiles. 

**5.3 Create a new table `edgeProfileFull` using the `edgeProfile` table (or otherwise) which has the 
`edgeProfile` information augmented with the underlying instrument information in a readable format.
Again, the table should be keyed on the column `option_id`.** 

*Hint: The `instRef` table contains the readable information and can be linked with the `optRef` table*
#### Sample Input:
##### edgeProfile data
| option_id      | numTrds | avgEdge  | minQty | maxQty |
|----------------|---------|----------|--------|--------|
| FB20200720C230 | 2       | 19.1864  | 31     | 61     | 


#### Sample Output:
##### edgeProfile augmented with data from optRef and instRef
| option_id      | numTrds | avgEdge  | minQty | maxQty | inst_id | opt_type | strike | expiry     | inst_syb | inst_name  |
|----------------|---------|----------|--------|--------|---------|----------|--------|------------|----------|------------|
| FB20200720C230 | 2       | 19.1864  | 31     | 61     | 9       | C        | 230    | 2020.07.20 | FB       | "Facebook" |

*Help: See [Joins](https://kx.com/academy/modules/introductory-workshop/#joins-1)* 

```q
//your code here - or work in the scratchpad
edgeProfileFull:edgeProfile lj 1!(optRef lj (1!instRef))
```
### End of Sub Section testing

Once you have completed this sub section, you can test all your changes by running the below. 
Ensure there are no Fail's before moving onto the next section. 

```q
testSection[`exercise5]
```


Congratulations you've completed all problems in the Data Analytics and Reporting section! 

# Final Submission 
To be marked complete and receive your certificate there are two final steps: completion of the post course questionnaire and submission of the above project. 

1. Fill out the post workshop survey [here](https://forms.gle/Ggxz84KUgvFqCyzZ6) - This must be filled out in order to receive your certificate!

2. To be marked completed, please run the below which will test the variables and functions you've 
created: 
```q
submitProject["kdaniel@kx.com"]
```

We hope you enjoyed the course and found it worthwhile! 

# Happy Coding!
