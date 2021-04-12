%function resp = elle_0021(Ph, ColumnE, GirderE)
clear all;
Ph = 10e3;
Pv = -2e3;
ColumnE = 29e6 ;
GirderE = 29e6;
ft = 12.0;

BeamArea = 38.3;
BeamMOI = 6710.0;
ColumnArea = 46.7;
ColumnMOI = 1900.0;
%%

% Set up nodes
B = 30.*ft; % Base
H = 13.*ft; % Height
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
Geom = 'corotational';
for el = [1,4]
  ElemData{el}.E = ColumnE;
  ElemData{el}.A = ColumnArea;
  ElemData{el}.I = ColumnMOI;
  ElemData{el}.Geom = Geom;  % linear, PDelta, or corotational
end
for el = [2,3]
  ElemData{el}.E = GirderE;
  ElemData{el}.A = BeamArea;
  ElemData{el}.I = BeamMOI;
  ElemData{el}.Geom = Geom;  % linear, PDelta, or corotational
end

ElemData = Structure ('chec',Model,ElemData);

%% 2. Cyclic axial force and horizontal displacement
% specify nodal forces and displacements

Pe(2,1) = Ph;
Pe(2,2) = Pv;
Pe(4,2) = Pv;
Loading = Create_Loading(Model,Pe,[]);

% initial solution strategy parameters
SolStrat = Initialize_SolStrat;
%State = Initialize_State(Model,ElemData);
State = Initialize_State(Model,ElemData);
[State,SolStrat] = Initialize(Model,ElemData,Loading,State,SolStrat);
[State,SolStrat] = Increment(Model,ElemData,Loading,State,SolStrat);
[State,SolStrat] = Iterate(Model,ElemData,Loading,State,SolStrat);
resp = State.U
