\S 202001

//Overview : This script creates the data set required for the Advanced final project

// Env Variables 
saveDB:hsym `$getenv[`AX_WORKSPACE],"/f1"    // replace for learn



////////// SENSOR ///////////////////////
// 1. Functions for data generation 
// volprof takes the number of random values to be generated as an input and generates n random values between 0 and 1. We use this to generate timestamps by doing this - asc 09:30:00.0+floor 23400000*volprof 500. This will generate 500 timestamps in ascending order from 9:30am to 4pm

volprof:{
 p:1.75;
 c:floor x%3;
 b:(c?1.0) xexp p;
 e:2-(c?1.0) xexp p;
 m:(x-2*c)?1.0;
 {(neg count x)?x} m,0.5*b,e};

/ temp sensor tables
createSensorTable:{[st;dur;sen;u;n;v]
        ([]sensorId:n?sen;
           time:(asc st+floor dur*volprof n);
           lapId:asc n?1+til 20;
           units:u;
           sensorValue:v+volprof n)        
        }


// Grand Prix Times
// Friday 
// practice 1 = 2020.01.01D11:00:00 - 2020.01.01D12:30:00
// practice 2 = 2020.01.01D15:00:00 - 2020.01.01D16:30:00
// Saturday 
// practice 3 = 2020.01.02D12:00:00 - 2020.01.01D13:00:00
// qualifier  = 2020.01.01D15:00:00 - 2020.01.01D16:00:00 // only get 18 mins 
// Sunday 
// race       = 2020.01.02D15:10:00 - 2020.01.01D17:10:00
st11:11:00:00.0
st12:12:00:00.0
st15:15:00:00.0
dur90:5400000
dur60:3600000
n:2000000

// 2. Table Definition 

////////// EVENT ///////////////////////
// 1. Functions for data generation

createEventTable:{[st;dur;n;s]
    t:([]lappId:1+til n;
         time:(asc st +floor dur *volprof n);
         session:s);
    t:update endTime:time[i+1] from t;
    update endTime:st+dur from t where time=(max time)
    }


// 2. Table Definition 
e1:createEventTable[st11;dur90;20;`P1]
e2:createEventTable[st15;dur90;19;`P2]
e3:createEventTable[st12;dur60;21;`P3]
e4:createEventTable[st15;dur60;20;`Q1]


// 3. Save tables to disk
event:e1,e2;
.Q.dpft[saveDB;2020.01.01;`session;`event];
event:e3,e4;
.Q.dpft[saveDB;2020.01.02;`session;`event];


// Create a sensor table
sensorTemp:`tempFrontLeft`tempFrontRight`tempBackLeft`tempBackRight /`tyrePressureFrontLeft`tyrePressureFrontRight`tyrePressureBackLeft`tyrePressureBackRight`windSpeedFront`windSpeedBack
sensorPressure:`tyrePressureFrontLeft`tyrePressureFrontRight`tyrePressureBackLeft`tyrePressureBackRight
sensorWind:`windSpeedFront`windSpeedBack

// Friday 
// practice 1 = 2020.01.01D11:00:00 - 2020.01.01D12:30:00
s1:update session:`P1 from 
    createSensorTable[st11;dur90;sensorTemp;`degreeCel;n;20]
   ,createSensorTable[st11;dur90;sensorPressure;`pascals;n;203.12]
   ,createSensorTable[st11;dur90;sensorWind;`mps;n;159.1]
// practice 2 = 2020.01.01D15:00:00 - 2020.01.01D16:30:00
s2:update session:`P2 from 
    createSensorTable[st15;dur90;sensorTemp;`degreeCel;n;20.1]
   ,createSensorTable[st15;dur90;sensorPressure;`pascals;n;203.58]
   ,createSensorTable[st15;dur90;sensorWind;`mps;n;159.6]
// Saturday 
// practice 3 = 2020.01.02D12:00:00 - 2020.01.01D13:00:00
s3:update session:`P3 from 
    createSensorTable[st12;dur60;sensorTemp;`degreeCel;n;20.12]
   ,createSensorTable[st12;dur60;sensorPressure;`pascals;n;203.31]
   ,createSensorTable[st12;dur60;sensorWind;`mps;n;159.23]
// qualifier  = 2020.01.01D15:00:00 - 2020.01.01D16:00:00
s4:update session:`Q4 from 
    createSensorTable[st15;dur60;sensorTemp;`degreeCel;n;20.13]
   ,createSensorTable[st15;dur60;sensorPressure;`pascals;n;203.41]
   ,createSensorTable[st15;dur60;sensorWind;`mps;n;159.29]

// 3. Save tables to disk

/sensor:s1,s2;
/.Q.dpft[saveDB;2020.01.01;`sensorId;`sensor];
/sensor:s3,s4;
/.Q.dpft[saveDB;2020.01.02;`sensorId;`sensor];

sensor:`sensorId xdesc s1,s2;
path:` sv saveDB,`$"2020.01.01/sensor/"
path set .Q.en[saveDB;sensor]
sensor:`sensorId xdesc s3,s4;
path:` sv saveDB,`$"2020.01.02/sensor/"
path set .Q.en[saveDB;sensor]

delete e1,e2,e3,e4,event,s1,s2,s3,s4,sensor from `.

// Data Creation for Race Day - To Be Exported to CSV for loading later - commenting out but keeping if we need to regenerate 
/r1:update session:`R1 from 
/    createSensorTable[16:10:00.0;90000;sensorTemp;`degreeCel;5000;20]
/   ,createSensorTable[16:10:00.0;90000;sensorPressure;`pascals;5000;203.12]
/   ,createSensorTable[16:10:00.0;90000;sensorWind;`degreeCel;5000;159.1]
// adding in annomily for tyrePressureBackLeft sensor at end of pit stop 
/raceDay:update sensorValue+6 from r1 where sensorId in`tyrePressureBackLeft  , time >16:11:00
/save `:raceDay.csv

