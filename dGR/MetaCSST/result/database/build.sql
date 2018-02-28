CREATE DATABASE DGR;
use DGR;

create table DGR
(
ID char(100)  primary key,
start int,
end int,
source char(100),
structure char(255)
);

create table TR
(
ID char(100) primary key,
ID_DGR char(100),
start int,
end int,
string char(1)
);

create table RT
(
ID char(100) primary key,
ID_DGR char(100),
start int,
end int,
string char(1)
);


create table PAIR
(
pairID char(100) primary key,
ID_TR char(100) not null,
startTR int,
endTR int,
stringTR char(1),
startVR int,
endVR int,
stringVR char(1),
mutA int,
mutNA int
);

set FOREIGN_KEY_CHECKS = 0;

load data local infile '/export/home/fzyan/dGR/mySQL/DGR2.txt' into table DGR fields terminated by ';';
load data local infile '/export/home/fzyan/dGR/mySQL/TR.txt' into table TR fields terminated by ';';
load data local infile '/export/home/fzyan/dGR/mySQL/RT.txt' into table RT fields terminated by ';';
load data local infile '/export/home/fzyan/dGR/mySQL/PAIR.txt' into table TR2VR fields terminated by ';';
