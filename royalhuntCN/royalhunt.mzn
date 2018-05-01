int: n; % number of court members
set of int: COURT = 1..n;
int: emperor = 1;
array[COURT] of int: rank;
array[COURT] of int: ability;

int: m; % number of horses
set of int: HORSE = 1..m;
array[HORSE] of int: beauty;
array[HORSE] of int: speed;

array[COURT,HORSE] of int: enjoy;

% handle insufficient horse problem
int: len = max([m,n]);
set of int: HORSE1 = 1..len;
set of int: COURT1 = 1..len;
array[HORSE1] of int: beauty1 = beauty ++ [0 | i in 1..len-m];
array[HORSE1] of int: speed1 = speed ++ [0 | i in 1..len-m];
array[COURT1] of int: rank1 = rank ++ [0 | i in 1..len-n];
int: maxAbi = max(ability);
array[COURT1] of int: ability1 = ability ++ [maxAbi+1 | i in 1..len-n];
array[COURT1, HORSE1] of int: enjoy1 = array2d(1..len, 1..len, [if i<= n /\ j <= m then enjoy[i,j] else 0 endif | i in 1..len, j in 1..len]);

% dicision variables & constraints
array[HORSE1] of var COURT1: court;
array[COURT1] of var HORSE1: horse;
include "inverse.mzn";
constraint inverse(court, horse);
var int: empEnj = enjoy[emperor, horse[emperor]];
constraint forall(i in COURT diff {emperor}) (enjoy1[i, horse[i]] < empEnj);
constraint empEnj = max(i in COURT) (enjoy1[i, horse[i]]);

constraint forall(i,j in COURT) (rank[i] > rank[j] -> beauty1[horse[i]] >= beauty1[horse[j]]);
constraint forall(i,j in HORSE) (beauty[i] > beauty[j] -> court[i] > n \/ rank1[court[i]] >= rank1[court[j]]);

constraint forall(i in COURT) (horse[i] <= m -> enjoy1[i, horse[i]] >= 0);
var int: abiPan = sum(i,j in HORSE) (-100 * (speed[i] > speed[j] /\ ability1[court[i]] < ability1[court[j]]));
constraint abiPan = sum(i,j in COURT1) (-100 * (ability1[i] > ability1[j] /\ speed[horse[i]] < speed[horse[j]]));

var int: obj = sum(i in HORSE) (enjoy1[court[i],i]) + abiPan;

solve maximize obj;
array[COURT] of var 0..m: horseOut = [if horse[i] <= m then horse[i] else 0 endif | i in COURT];
output ["horse = \(horseOut);\nobj = \(obj);"];
