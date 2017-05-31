#Model by Molina-Pariente et al. (2016) from the article:
#A stochastic approach for solving operating room scheduling problem
#date: 17th of may
#/Users/asgeirornsigurpalsson/Desktop/untitled\ folder\ 2/Keyrsla/glpk-4.60/examples/glpsol --check --math SurgeryScheduling.mod
#-d SurgeryData.dat  --wlp SurgeryScheduling.lp

#--------------------------Indices and sets--------------------------------#

#Number of days
param n :=10;

#Planning horizon H for n days
set H:= 1..n;

#Set of patients on waiting list
set I;

#Set of operating rooms
set J;

#Set of surgeons
set K;

#set of Scenarios;
set Z;

#--------------------------Parameters--------------------------------#
#Regular capacity (in minutes) of OR j on day h under scenario Z
param r{j,h,z} default 0;

#Overtime capacity (in minutes) of OR j allowd on day h
param o{j,h} default 0;

#Regular capacity (in minutes) of surgeon K on day h under scneario Z
param a{k,h,z} default 0;

#Surgeon in charge of patient i
param q{i};

#Length of surgery i (in minutes) under scenario Z
param t{i,z} default 0;

#Ratio of the cost of a minute of allowed overtime to the cost of a regular working time

#Ratio of the cost of a minute of exceed overtime to the cost of a regular working minute
#--------------------------Variables--------------------------------#

# The decision variable is to assign an exam to an exam slot (later we may add room assignments)
var X{i,j,h} binary;

#Indicator variable informs us about maximum expected OR cost in OR j on day h under scenario z
var C{i,j,z} >= 0;

#Indicator variable informs us about overtime (in minutes) of surgeon k on day h under scenario z
var Y{k,h,z} >= 0;

#Indicator variable that informs us about OR time (in minutes) allocated to OR j on day h that exceeds the total OR time allowed
#Under scenario z
var E{j,h,z} >= 0;

#--------------------------Constraints--------------------------------#

#This forces the each surgery to be only assigned once in the planning horizone
subject to OnlyOnce{i in I}: sum{j in J, h in H} X[i,j,h] <=1;

#Ensures that patient is scheduled after his realise date
subject to NotAgain{i in I}: sum{j in J, h in H: h <= rd[i]-1} X[i,j,h] =0;

#Ensures that patient is scheduled before his due date
subject to BeforeDue{i in I: d[i] <= card(H)}: sum{j in J, h in H: h <= d[i]} X[i,j,h]=1;

#Maximum expected OR cost due to undertime
subject to MaxExpU{j in J, h in H, z in Z}: C[j,h,z] >= r[j,h,z]-sum{i in I}t[i,z]*X[i,j,h];

#Maximum expected OR cost due to overtime
subject to MaxExpO{j in J, h in H, z in Z}: C_[j,h,z]>= gamma*(sum{i in I}t[i,z]*X[i,j,h]-r[j,k,z]);

#Defines the OR time that exceeds the maximum OR time available for performing elective surgeries in an OR-day under a scenario.
subject to OpTimeExceed{j in J, h in H, z in Z}: E[j,h,z] >= sum{i in I}t[i,z]*X[i,j,h]-(r[j,h,z]-o[j,h]);

#Overtime of surgeons
subject to OverTime{k in K, h in H, z in Z}: Y[k,h,z] >= sum{j in J, i in I: q[i]=k}t[i,z]*X[i,j,k]-a[k,h,z];

#--------------------------Objective function--------------------------------#
#minimize Objective: sum{z in Z}prob[z]*(sum{h in H}(sum{j in J}C[j,h,z]+lambda(E[j,h,z]+sum{k in K}Y[k,h,z])));
