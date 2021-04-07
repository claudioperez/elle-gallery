function resp = elle_0021(Ph, I)
% Set up nodes
ft = 12.0;
B = 20.*ft;
H = 10.*ft;
XYZ(1,:) = [  0.,  0.];
XYZ(2,:) = [  0.,  H ];
XYZ(3,:) = [ B/2,  H ];
XYZ(4,:) = [  B ,  H ];
XYZ(5,:) = [  B ,  0.];

CON{1} = [ 1, 2];
CON{2} = [ 2, 3];
CON{3} = [ 3, 4];
CON{4} = [ 4, 5];

BOUN(1,:)= [1,1,1];
BOUN(5,:)= [1,1,1];

nel=4;
for el=1:nel
	ElemName{el} = 'LE2dFrm';
end


% generate Model data structure
Model = Create_Model(XYZ,CON,BOUN,ElemName);

% specify geometry option
Geom = 'linear';
for el = [1:nel]
  ElemData{el}.E = 29e3;
  ElemData{el}.A = 125.0;
  ElemData{el}.I = I;
  ElemData{el}.Geom = Geom;  % linear, PDelta, or corotational
end

ElemData = Structure ('chec',Model,ElemData);

%% 2. Cyclic axial force and horizontal displacement
% specify nodal forces and displacements
clear Pe
Pe(2,1) = Ph;
Loading = Create_Loading(Model,Pe,[]);

% initial solution strategy parameters
SolStrat = Initialize_SolStrat;
%State = Initialize_State(Model,ElemData);
State = Initialize_State(Model,ElemData);
%[State,SolStrat] = Initialize (Model,ElemData,Loading,State,SolStrat);

[State,SolStrat] = Iterate(Model,ElemData,Loading,State,SolStrat);
resp = [];

