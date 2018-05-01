% assignment 2
% select a set of raiding warrior
enum WARRIOR;
WARRIOR: dummy; 
enum CLAN; % the clan they belong too

int: l; % minimum raid party size
int: u; % maximum raid party size
int: m; % limit of hatreds

array[WARRIOR] of int: strength;
array[WARRIOR] of CLAN: clan;

array[CLAN,CLAN] of 0..1: hates;

array[1..u] of var WARRIOR: choice;
constraint sum(i in 1..u) (choice[i] != dummy) >= l;
constraint forall(i in 1..u-1) (choice[i] >= (choice[i] != dummy) + choice[i + 1]);
constraint sum(i,j in 1..u where i<j) (hates[clan[choice[i]],clan[choice[j]]]) <= m;

var int: totalStrength;
constraint totalStrength = sum(i in 1..u)(strength[choice[i]]);
solve maximize totalStrength;
output ["raid = {"] ++ [if fix(choice[i]) != dummy then show(choice[i])
    ++ if i < u /\ fix(choice[i+1]) != dummy then ", " else "" endif
    else "" endif | i in 1..u ] ++ ["};\n"] ++ ["obj = \(totalStrength)"];
