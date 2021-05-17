%function State = elle_0020%(Ph, ColumnArea, GirderArea, Geom)
% Claudio Perez
in = 1.0;
ft = 12.0;

%% -------------------------
% Variables
%---------------------------
E  = ConcMod;
fy = 4.0;
Hk = 0;
% --------------------------
d  =  24*in;
bf =  60*in;
tw =  18*in;
tf =  6*in;
% --------------------------
B = 30.*ft; % Base
H = 13.*ft; % Height
% --------------------------
ColumnE = ConcMod;
GirderE = ConcMod;

GirderNIP = 4;
GirderArea = 684.0;
GirderHomMOI = 34383.8; % Homogeneous section MOI
ColumnArea = 30^2;
ColumnHomMOI = (30^4)/12.0;

% Structural geometry option
GirderGeom = Geom;
ColumnGeom = Geom; % linear, PDelta, or corotational

%% -------------------------
% Material Definitions
%---------------------------
MatName    = 'BilinInel1dMat';
MatData.E  = E;
MatData.fy = fy;
MatData.Eh = Hk;

%% -------------------------
% Section Definitions
%---------------------------
Data.d  = d;
Data.bf = bf;
Data.tw = tw;
Data.tf = tf;
Data.ndm = 2;
ShpName = 'T-Shp';
[Data.MatName{1:4}] = deal(MatName);
[Data.MatData{1:4}] = deal(MatData);

% 1a. ---------------------------------------------------
% generate a section shape with outline and material 
% specification
Shape = Create_MultRectShape(ShpName,Data);

% 1b. ---------------------------------------------------
% generate fiber mesh for section shape
% original modal: 2 layers in the flange and 2 in the web
MeshData.nft = 4;
MeshData.nwl = 8;
MeshData.ndm = 2;
Shape = Create_IPMesh4MultRectShape(Shape,MeshData);

% 1c. ---------------------------------------------------
% Step: assign shape and material data to SecData
% shift of reference axis relative to section centroid 
% (yc is centroid distance in new reference)
% CrdOr.yc =  1.5;
CrdOr.yc =  0;
SecData  = Add_Shape2Section([],Shape,CrdOr);

WinXr = 0.40;
WinYr = 0.80;
Create_Window(WinXr,WinYr);
Plot_SectionGeometry (SecData,[]);
% geometric section properties
Afib = SecData.FibAyz(:,3);
yfib = SecData.FibAyz(:,1)-CrdOr.yc;
A    = sum(Afib);
Zn   = sum(Afib.*abs(yfib));
In   = sum(Afib.*(yfib.^2));

% distance of centroid yc from the top of the section
yc = (bf*tf*tf/2+tw*(d-tf)*(d+tf)/2)/(bf*tf+(d-tf)*tw);
% moment of inertia I
I  = bf*tf^3/12+(bf*tf)*(tf/2-yc)^2+tw*(d-tf)^3/12+tw*(d-tf)*((d+tf)/2-yc)^2;
% plastic modulus Z = Zn
Z  = bf*tf*(yc-tf/2)+tw*(d-tf)*((d+tf)/2-yc);

%% -------------------------
% Element Definitions
%---------------------------
nel=4;
for el = [1,4]
  ElemName{el} = 'LE2dFrm';
  ElemData{el}.E = ColumnE;
  ElemData{el}.A = ColumnArea;
  ElemData{el}.I = ColumnHomMOI;
  ElemData{el}.Geom = ColumnGeom;
end

for el = [2,3]
  ElemName{el} = 'Dinel2dFrm_EBwDF';
  ElemData{el}.nIP = GirderNIP;
  ElemData{el}.IntTyp = 'Lobatto';   % element integration rule
  ElemData{el}.Geom = GirderGeom;
  for ip=1:GirderNIP
    ElemData{el}.SecData{ip} = SecData;
  end
  ElemData{el}.SecName = 'MultRectSecw1dMat';
end

%% -------------------------
% Model Definition
%---------------------------
% Set up nodes
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

% generate Model data structure
Model = Create_Model(XYZ,CON,BOUN,ElemName);
ElemData = Structure ('chec',Model,ElemData);

%% -------------------------
% Loading
%---------------------------
Pe(2,1) = Ph;
Pe(2,2) = Pv;
Pe(4,2) = Pv;
Loading = Create_Loading(Model,Pe,[]);

%% -------------------------
% Solution
%---------------------------
SolStrat = Initialize_SolStrat;
State = Initialize_State(Model,ElemData);
[State,SolStrat] = Initialize(Model,ElemData,Loading,State,SolStrat);
[State,SolStrat] = Increment(Model,ElemData,Loading,State,SolStrat);
[State,SolStrat] = Iterate(Model,ElemData,Loading,State,SolStrat);


