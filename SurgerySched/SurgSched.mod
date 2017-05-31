#Model by Molina-Pariente et al. (2016) from the article:
#A stochastic approach for solving operating room scheduling problem
#date: 31th of may
#Randomly generated data
#--------------------------Indices and sets--------------------------------#

#XNumber of days
param n :=2;

#XPlanning horizon H for n days
set H:= 1..n;

#XSet of patients on waiting list
set I;

#XSet of operating rooms
set J;

#XSet of surgeons
set K;

#set of Scenarios;
set Z;

#--------------------------Parameters--------------------------------#
#Regular capacity (in minutes) of OR j on day h under scenario Z
param r{J,H,Z} default 480;

#Length of surgery i (in minutes) under scenario Z
param t{I,Z} default Uniform(30,160);

#Overtime capacity (in minutes) of OR j allowed on day h
param o{J,H} default Uniform(15,80);

#Regular capacity (in minutes) of surgeon K on day h under scneario Z
param a{K,H,Z} default 250;


param prob{z in Z} := 1/card(Z);

#Surgeon in charge of patient i
param q{I} default Uniform(1,3);

#release date
param rd{I} default Uniform(1,5);

#due date
param d{I} default 10;

#--------------------------Variables--------------------------------#

# The decision variable is to assign an exam to an exam slot (later we may add room assignments)
var X{I,J,H} binary;

#Indicator variable informs us about maximum expected OR cost in OR j on day h under scenario z
var C{J,H,Z} >= 0;

#Indicator variable informs us about overtime (in minutes) of surgeon k on day h under scenario z
var Y{K,H,Z} >= 0;

#Indicator variable that informs us about OR time (in minutes) allocated to OR j on day h that exceeds the total OR time allowed
#Under scenario z
var E{J,H,Z} >= 0;


#--------------------------Constraints--------------------------------#


#This forces the each surgery to be only assigned once in the planning horizone
subject to OnlyOnce{i in I}: sum{j in J, h in H} X[i,j,h] <=1;

#Ensures that patient is scheduled after his realise date - ath med thetta rd
subject to NotAgain{i in I}: sum{j in J, h in H: h <= (rd[i]-1)} X[i,j,h] ==0;

#Ensures that patient is scheduled before his due date
subject to BeforeDue{i in I: d[i] <= card(H)}: sum{j in J, h in H: h <= d[i]} X[i,j,h]=1;

#Maximum expected OR cost due to undertime
subject to MaxExpU{j in J, h in H, z in Z}: C[j,h,z] >= r[j,h,z]-sum{i in I}t[i,z]*X[i,j,h];

#Maximum expected OR cost due to overtime
subject to MaxExpO{j in J, h in H, z in Z}: C[j,h,z]>= 1*(sum{i in I}t[i,z]*X[i,j,h]-r[j,h,z]);

#Defines the OR time that exceeds the maximum OR time available for performing elective surgeries in an OR-day under a scenario.
subject to OpTimeExceed{j in J, h in H, z in Z}: E[j,h,z] >= sum{i in I}t[i,z]*X[i,j,h]-(r[j,h,z]-o[j,h]);

#Overtime of surgeons
subject to OverTime{k in K, h in H, z in Z}: Y[k,h,z] >= sum{j in J, i in I}t[i,z]*X[i,j,h]-a[k,h,z];

#--------------------------Objective function--------------------------------#
#minimize Objective: sum{z in Z}prob[z]*(sum{h in H}(sum{j in J}C[j,h,z]#+lambda(E[j,h,z]+sum{k in K}Y[k,h,z])));
minimize Obj:
(sum{z in Z}prob[z]*
(sum{ j in J, h in H} C[j,h,z]
+1*(sum{ j in J, h in H}E[j,h,z]
+sum{ k in K, h in H}a[k,h,z])));

solve;
