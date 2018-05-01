% Beauty Trap
% Perform the most seductive dance

include "regular.mzn";

enum LEGS = {spin, leap, waltz, curtsey, prep, stand};
enum ARMS = {beckon, out, up, wrapped, neutral};
enum FACE = {smile, wink, batt, think, glow, blank};

int: maxlen;
set of int: STEP = 1..maxlen;
array[LEGS] of int: maxlegs;
array[ARMS] of int: maxarms;
array[FACE] of int: maxface;
constraint assert(maxlegs[stand] >= maxlen, "maxlegs[stand] smaller than maxlen");
constraint assert(maxarms[neutral] >= maxlen, "maxarms[neutral] smaller than maxlen");
constraint assert(maxface[blank] >= maxlen, "maxface[blank] smaller than maxlen");
array[LEGS,ARMS] of int: dance_value;
array[ARMS,FACE] of int: entice_value;
constraint assert(dance_value[stand,neutral] = 0, "incorrect dance_value array");
constraint assert(entice_value[neutral,blank] = 0, "incorrect entice_value array");
int: boredom; % how bored each step make the viewer

var STEP: len;
array[STEP] of var LEGS: legs;
array[STEP] of var ARMS: arms;
array[STEP] of var FACE: face;

% length constraints
constraint forall(i in STEP)(i > len -> legs[i] = stand /\ arms[i] = neutral /\ face[i] = blank );
%constraint forall(i in len+1..maxlen) (legs[i] = stand);
%constraint forall(i in len+1..maxlen) (arms[i] = neutral);
%constraint forall(i in len+1..maxlen) (face[i] = blank);

% legs constraints
constraint forall(i in 1..maxlen-3) (
    legs[i] = waltz /\ legs[i+1] = waltz /\ legs[i+2] = waltz -> legs[i+3] != waltz
);
constraint forall(i in 1..maxlen-1) (
    legs[i] = waltz -> forall(j in i+1..maxlen) (
        legs[j] = curtsey -> exists(k in i+1..j-1) (legs[k] = stand)
    )
);
constraint regular(legs, 7, 6, ld, 1, {2,3,4,5,6,7});
array[1..7, LEGS] of 0..7: ld =
    [| 2, 0, 4, 5, 6, 7
     | 0, 0, 0, 5, 6, 7
     | 2, 0, 4, 0, 0, 7
     | 2, 0, 4, 5, 6, 7
     | 2, 0, 4, 5, 0, 7
     | 2, 3, 4, 5, 6, 7
     | 2, 0, 4, 5, 6, 7 |];

% arms constraints
constraint regular(arms, 6, 5, ad, 1, {2,3,4,5,6});
array[1..6, ARMS] of 0..6: ad =
    [|0, 3, 4, 0, 6
     |0, 3, 4, 5, 6
     |2, 0, 4, 0, 6
     |2, 3, 0, 0, 6
     |0, 3, 4, 0, 6
     |0, 3, 4, 5, 6|];

% face constraints
constraint regular(face, 7, 6, fd, 1, {2,3,4,5,6,7});
array[1..7, FACE] of 0..7: fd =
    [|2, 3, 4, 5, 6, 7
     |2, 3, 4, 0, 6, 7
     |2, 3, 4, 5, 6, 7
     |2, 3, 4, 0, 6, 7
     |2, 3, 4, 5, 6, 7
     |2, 3, 4, 5, 6, 7
     |2, 3, 4, 5, 6, 7|];
constraint forall(s in 1..maxlen-2) (face[s] = face[s+1] /\ face[s+1] = face[s+2] -> face[s] = blank);
% 注意题目有误：应为不能连续做3此相同的动作

% non-negative value constraints
constraint forall(s in STEP) (dance_value[legs[s], arms[s]] >= 0);
constraint forall(s in STEP) (entice_value[arms[s], face[s]] >= 0);

% cardinality constraints
% 注意global_cardinality需要与regular协同使用（特别是使用s[i] != s[i+1]条件时），不使用任意一个全局变量都会导致不可接受的运算时长;在此例中可用at_most代替global_cardinality
% 全局势约束为限速步骤
include "globals.mzn";
constraint global_cardinality_low_up(legs, LEGS, [0| i in LEGS], maxlegs);
constraint global_cardinality_low_up(arms, ARMS, [0| i in LEGS], maxarms);
constraint global_cardinality_low_up(face, FACE, [0| i in LEGS], maxface);

% solve
var int: obj = sum(i in 1..len) (
    dance_value[legs[i], arms[i]] + entice_value[arms[i], face[i]]
) - boredom * len;
solve maximize obj;
output ["len = \(len);\nlegs = \(legs);\narms = \(arms);\nface = \(face);\nobj = \(obj);"];
