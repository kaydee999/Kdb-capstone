\S 202001 

//Reference Data Creation 
//We create the reference data tables - inst and option over here 
//namegenerator takes the symbol, date, option type and strike price as parameters and returns the option name
namegenerator : {[sy;dt;ot;sp](((string sy),"" sv "." vs string dt),string ot),string sp};
//Creating Instrument table
inst:([]inst_id:1+til 10; inst_syb : `AAPL`MSFT`NFLX`GOOGL`IBM`MCD`KO`TSLA`FB`RACE; inst_name:("Apple";"Microsoft";"Netflix";"Alphabet";"IBM";"Mc Donald's";"Coca-Cola";"Tesla";"Facebook";"Ferrari") );
-1 "Created inst table";
//Creating Option table
option:([]option_id:1+til 100; inst_id:(30#7),(40#8),(30#9); opt_type:100#`P`C);
update strike:30#(40 40 45 45 50 50 55 55 60 60), expiry:((10#enlist "07/20/2020"),(10#enlist "09/20/2020"),(10#enlist"11/20/2020")) from `option where inst_id = 7;
update strike:40#(1400 1400 1500 1500 1600 1600 1700 1700 1800 1800), expiry:((10#enlist "07/20/2020"),(10#enlist "09/20/2020"),(10#enlist"11/20/2020"),(10#enlist"01/20/2021")) from `option where inst_id = 8;
update strike:30#(230 230 240 240 250 250 260 260 270 270), expiry:((10#enlist "07/20/2020"),(10#enlist "09/20/2020"),(10#enlist"11/20/2020")) from `option where inst_id = 9;
option : (update exp2:"D"$expiry from option) lj `inst_id xkey inst;
option : update optionname : namegenerator ' [inst_syb;exp2;opt_type;strike] from option;
option : select option_id : `$optionname, inst_id, opt_type, strike, expiry from option;
-1 "Created option table";


getInstRef:{[insts] select from inst where inst_id in insts};
getOptionRef:{[ops] select from option where option_id in ops};


.z.pg:{if[10h~type x; 
            if[any x like/: ("getInstRef*";"getOptionRef*"); :value x]; 
            ];
       @[{if[x[0] in `getInstRef`getOptionRef;:value x]}; x;{'"Blocked"}]
       };
.z.ps:{};