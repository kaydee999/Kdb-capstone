\S 202001 

refDict:.Q.def[`saveDB`refPort!(hsym `$getenv[`FP_DB];"5010")] .Q.opt .z.x;
@[`refDict;`saveDB;hsym];
key[refDict] set' value[refDict]; //set values globally 

//Overview : This script creates the data set required for the final project
// Function Declarations : 
//volprof takes the number of random values to be generated as an input and generates n random values between 0 and 1. We use this to generate timestamps by doing this - asc 09:30:00.0+floor 23400000*volprof 500. This will generate 500 timestamps in ascending order from 9:30am to 4pm
volprof:{
 p:1.75;
 c:floor x%3;
 b:(c?1.0) xexp p;
 e:2-(c?1.0) xexp p;
 m:(x-2*c)?1.0;
 {(neg count x)?x} m,0.5*b,e};

// pricegenerator generates a logical trade price based on the bid ask quotes at that time
pricegenerator : {[bid;ask] if[bid>ask;t:bid;bid:ask;ask:t]; 
    mult : first 1?(1 -1); 
    mid : (bid+ask)%2; 
    mid*1+mult*first 1?1.1*(ask%mid)-1};

//namegenerator takes the symbol, date, option type and strike price as parameters and returns the option name
namegenerator : {[sy;dt;ot;sp](((string sy),"" sv "." vs string dt),string ot),string sp};

//exchmsg takes the option name, broker id and exchange as parameters and returns the exchange message based on certain rules
exchmsg : {[on;br;ex] $[ex=3; 
        "-" sv ("CME";string on;string br);
        "-" sv ("ISE";string br;string on)]};

//We take 10 instruments as underlyings and create an inst table which contains the details of the instruments such as id, symbol etc
inst : ([]inst_id:1+til 10; 
    inst_syb : `AAPL`MSFT`NFLX`GOOGL`IBM`MCD`KO`TSLA`FB`RACE; 
    inst_name:("Apple";"Microsoft";"Netflix";"Alphabet";"IBM";"Mc Donald's";"Coca-Cola";"Tesla";"Facebook";"Ferrari") );

//Finally, we create an option table which contains 100 options derived from 3 underlyings
option : ([]option_id:1+til 100; 
    inst_id:(30#7),(40#8),(30#9);
    opt_type:100#`P`C);
update strike:30#(40 40 45 45 50 50 55 55 60 60), 
    expiry:((10#enlist "07/20/2020"),(10#enlist "09/20/2020"),(10#enlist"11/20/2020")) 
    from `option where inst_id = 7;
update strike:40#(1400 1400 1500 1500 1600 1600 1700 1700 1800 1800), 
    expiry:((10#enlist "07/20/2020"),(10#enlist "09/20/2020"),(10#enlist"11/20/2020"),(10#enlist"01/20/2021")) 
    from `option where inst_id = 8;
update strike:30#(230 230 240 240 250 250 260 260 270 270), 
    expiry:((10#enlist "07/20/2020"),(10#enlist "09/20/2020"),(10#enlist"11/20/2020")) 
    from `option where inst_id = 9;

//t1 and t2 are temporary tables used to create an exchange message table
t1 : (update exp2:"D"$expiry from option) lj `inst_id xkey inst;
t2 : update optionname : namegenerator ' [inst_syb;exp2;opt_type;strike] from t1;
option : select option_id : `$optionname, inst_id, opt_type, strike, expiry from t2;

//We generate a basic trade table with 500 rows using the following commands.
opt_ids:exec option_id from option;
trade:([]trade_id:string 1+til 500;
    time:(asc 09:30:00.0+floor 23400000*volprof 500);
    option_id:500?opt_ids; 
    price:500?100.0; 
    qty:500?1+til 100; 
    side:500?`B`S);

trade:update edge : (500?(1+til 10),
    neg(1+til 5))*price*0.005*qty 
    from trade;

trade : trade ^ ([]exch_id:500?3 4;broker_id:500?700+til 10);
-1 "Trade Table Created";

//We generate a spread table with specific values using the following command
spread : ([]spread_id:1001 1001 1002 1002 1003 1003 1004 1004 1005 1005; 
        option_id:82 88 74 98 86 88 80 90 72 100; 
        qty:10#(100 -100));
-1 "Spread table created";
spread : spread lj select optionname by option_id from t2;
spread : select spread_id,option_id:`$optionname,qty from spread;
// nbbo: date time sym bid ask bsize asize
//These are some functions used to generate random nbbo quote data
vol:{10+`int$x?90};
rnd:{0.01*floor 0.5+x*100};
qp:(10000?1+ til 100);
t:(asc 09:30:00.0+floor 23400000*volprof 10000);

// Generates nbbo table with random bid ask values.
nbbo:([]option_id:10000?opt_ids;
        time:t;
        bid:qp-((rnd 10000?1.0) & -0.02 + rnd 10000?1.0);
        ask:qp+((rnd 10000?1.0) & -0.02 + rnd 10000?1.0);
        bsize:vol[10000];
        asize:vol[10000]);
-1 "Nbbo table created";
-1 "Updating trade prices";
trade : aj[`option_id`time;trade;nbbo];
trade : update price2:pricegenerator ' [bid;ask] from trade;
trade : update price2:price from trade where price2 = 0N;
trade : select trade_id, option_id, time, price:price2, qty,side,edge, exch_id,broker_id from trade;

meta nbbo

// These commands are used to save the trade, spread and nbbo tables in a partitioned database
.Q.dpft[saveDB;2020.08.03;`option_id;`trade];
.Q.dpft[saveDB;2020.08.03;`spread_id;`spread];
.Q.dpft[saveDB;2020.08.03;`option_id;`nbbo];
.Q.dpft[saveDB;2020.08.04;`option_id;`trade];
.Q.dpft[saveDB;2020.08.04;`spread_id;`spread];
.Q.dpft[saveDB;2020.08.04;`option_id;`nbbo];

//Updating the trade table with new random values 
trade:([]trade_id:string 1+til 500;
        time:(asc 09:30:00.0+floor 23400000*volprof 500);
        option_id:500?opt_ids; 
        price:500?100.0; 
        qty:500?1+til 100; 
        side:500?`B`S);

trade:update edge : (500?(1+til 10),neg(1+til 5))*price*0.005*qty from trade;
trade : trade ^ ([]exch_id:500?3 4;broker_id:500?700+til 10);
-1 "Updating trade prices";

trade : aj[`option_id`time;trade;nbbo];
trade : update price2:pricegenerator ' [bid;ask] from trade;
trade : update price2:price from trade where price2 = 0N;
trade : select trade_id, option_id, time, price:price2, qty,side,edge, exch_id,broker_id from trade;

.Q.dpft[saveDB;2020.08.05;`option_id;`trade];
.Q.dpft[saveDB;2020.08.05;`spread_id;`spread];
.Q.dpft[saveDB;2020.08.05;`option_id;`nbbo];
.Q.dpft[saveDB;2020.08.06;`option_id;`trade];
.Q.dpft[saveDB;2020.08.06;`spread_id;`spread];
.Q.dpft[saveDB;2020.08.06;`option_id;`nbbo];
-1 "Saved Tables to partitioned db";

