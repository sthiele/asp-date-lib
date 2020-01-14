%*

# Library for dates

* Dates are represented as tuple terms (D,M,Y).
* Library converts absolute dates into relative dates.
* Library finds out the weekday of a date.
* No need to use Python.
* Day differences are realized using Julian Day Numbers, see http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html .
* Week days are realized using a formula from https://de.wikipedia.org/wiki/Wochentagsberechnung

# Interface: Input Predicates

## date_consider/1( (D,M,Y) )

Dates that need to be considered.
These should be statically defined.

|Argument | Domain                     | Note          |
|:--------|:---------------------------|:--------------|
| D       | number (1-31)              | Day of Month
| M       | number (1-12)              | Month
| Y       | number (1XXX-2XXX)         | Year

## date_origin/1( (D,M,Y) )

Define the origin date for relative date computations.

Arguments are as with date_consider/1.

# Interface: Output Predicates

## date_julian/2( (D,M,Y), JulianDay )

Mapping from considered dates to Julian Day number (number of days since 1st of January -4712).

Remark: the "half day" of Julian Day computation is omitted. This preserves correctness of relative day counts.

|Argument   | Domain                     | Note          |
|:----------|:---------------------------|:--------------|
| D         | number (1-31)              | Day of Month
| M         | number (1-12)              | Month
| Y         | number (1XXX-2XXX)         | Year
| JulianDay | positive number            | Number of Days since 1st of January -4712

## date_relative/2( (D,M,Y), Days )

Mapping from considered dates to relative number of days with respect to the date given via date_origin.

|Argument | Domain                     | Note          | 
|:--------|:---------------------------|:--------------|
| D       | number (1-31)              | Day of Month
| M       | number (1-12)              | Month
| Y       | number (1XXX-2XXX)         | Year
| Days    | number (no restriction)    | Number of Days

## date_weekday/2( (D,M,Y), Weekday )

Mapping from considered dates to weekdays.

|Argument | Domain                     | Note          |
|:--------|:---------------------------|:--------------|
| D       | number (1-31)              | Day of Month
| M       | number (1-12)              | Month
| Y       | number (1XXX-2XXX)         | Year
| Days    | number (0-6)               | Weekday

Weekdays are as follows: 0/Monday, ..., 6/Sunday

*%

%
% Julian Day Numbers
%

% March-December = start months of Julian year
date_julian((DIn,MIn,YIn),Julian) :-
  date_consider((DIn,MIn,YIn)),
  MIn >= 3,
  YEffective = YIn, % same year
  MEffective = MIn, % March = 3, December = 12
  A = YEffective / 100, % century
  B = A/4,
  C = 2-A+B,
  E = (36525*(YEffective+4716))/100,
  F = (306001*(MEffective+1))/10000,
  Julian = C+DIn+E+F-1525.

% January-February = end months of previous Julian year
date_julian((DIn,MIn,YIn),Julian) :-
  date_consider((DIn,MIn,YIn)),
  MIn < 3,
  YEffective = YIn-1, % previous year
  MEffective = MIn+12, % January = 13, February = 14
  A = YEffective / 100, % century
  B = A/4,
  C = 2-A+B,
  E = (36525*(YEffective+4716))/100,
  F = (306001*(MEffective+1))/10000,
  Julian = C+DIn+E+F-1525.

%
% weekday
%

% March-December = start months of Julian year
date_weekday((DIn,MIn,YIn),Weekday) :-
  date_consider((DIn,MIn,YIn)),
  MIn >= 3,
  YEffective = YIn, % same year
  C = YEffective / 100, % century
  Y = (YEffective-1900) \ 100, % year relative to 1900
  M = MIn-2, % March = 1, December = 10
  Weekday = (DIn + (13*M-1)/5 + Y + Y/4 + C/4 - 2*C - 1) \ 7.

% January-February = end months of previous Julian year
date_weekday((DIn,MIn,YIn),Weekday) :-
  date_consider((DIn,MIn,YIn)),
  MIn < 3,
  YEffective = YIn-1, % previous year
  C = YEffective / 100, % century
  Y = (YEffective-1900) \ 100, % year relative to 1900
  M = MIn+10, % January = 11, February = 12
  Weekday = (DIn + (13*M-1)/5 + Y + Y/4 + C/4 - 2*C - 1) \ 7.

%
% relative day numbers
%

% julian day of origin
date_consider((D,M,Y)) :- date_origin((D,M,Y)).
date_relative((D,M,Y),Julian-OJulian) :-
  date_julian((D,M,Y),Julian),
  date_origin((OD,OM,OY)),
  date_julian((OD,OM,OY),OJulian).

%
% Testcases
%

%% Testcase 16.2.2019 = Saturday, Julian Day 2458530.5
%date_consider((16,2,2019)).
%:~ not date_julian((16,2,2019),2458530).[1]
%:~ not date_weekday((16,2,2019),5).[1]

%% Testcase 25.3.2019 = Monday, Julian Day 2458567.5
%date_consider((25,3,2019)).
%:~ not date_julian((25,3,2019),2458567).[1]
%:~ not date_weekday((25,3,2019),0).[1]

%% Testcase Origin 1.1.2018, dates 16.2.2019 (411 days later), 25.3.2019 (448 days later), 19.6.2017 (196 days before). 
%date_origin((1,1,2018)).
%date_consider((16,2,2019)).
%date_consider((25,3,2019)).
%date_consider((19,6,2017)).
%:~ not date_relative((16,2,2019),411).[1]
%:~ not date_relative((25,3,2019),448).[1]
%:~ not date_relative((19,6,2017),-196).[1]
