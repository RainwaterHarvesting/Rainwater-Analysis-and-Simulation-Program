%Clear data and screen
clear;
clc;
%Start time recording
tic;
%Add missing dates and hours in rain data
namecity='Miami_F';
date=xlsread(['C:\Users\david\Documents\MATLAB\' namecity '.xlsx'],'Date');%Change the path to that of "Richmond.xlsx" on your PC
datenumber=datenum(date);
datediff=diff(datenumber);
p=xlsread(['C:\Users\david\Documents\MATLAB\' namecity '.xlsx'],'Data');%0.01 inches %Change the path to that of "Richmond.xlsx" on your PC
prcp=zeros(length(p(:,1))+sum(datediff)-length(datediff),length(p(1,:)));
m=zeros();
m(1)=1+datediff(1);
for i=2:length(datediff)-1  
    m(i)=m(i-1)+datediff(i);
end
prcp(1,:)=p(1,:);
prcp(length(prcp(:,1)),:)=p(length(p(:,1)),:);
for j=1:length(m)    
    prcp(m(j),:)=p(j+1,:);
end

%Generate new series of dates and hours
newdatenum=datenumber(1):datenumber(length(datenumber));
newdate=datevec(datestr(newdatenum));
newmonth=newdate(:,2);
newhour=1:numel(prcp);
hourr=(1:24)';
hour=repmat(hourr,floor(numel(prcp)/24),1);
DWTime=48;
DWDay=floor(DWTime/24);
AP=46.60;%inches will be converted to liters;
%http://www.usa.com/
%WASHINGTON REAGAN AP: 42.22
%NORFOLK INTL AP: 46.60
%RICHMOND INTL AP: 43.64;
%LYNCHBURG INTL AP: 44.22
%MONTEBELLO FISH HTCHY: 43.38
%ROANOKE INTL AP: 39.54
%STAR TANNERY: 36.81
%BRISTOL AP: 45.08
Pi3t=zeros();
Pi4t=zeros();
alpha=zeros();
Pi1=zeros();
Pi2=zeros();
Pi3v=zeros();
Pi4v=zeros();
sigmaV=zeros();
sigmaE=zeros();
sigmaQ=zeros();
sigmaD=zeros();
sigmaO=zeros();
sigmaI=zeros();
sigmaU=zeros();
sigmaM=zeros();
sigmaS=zeros();
sigmaY=zeros();
d=zeros();
N=zeros();
s=zeros();

VolTank=[1 20 40 60 80];
VolTankInit=0.5*VolTank;%cubic meters
RoofA=[1000];
IrArea=[1000];
ipe=[0 20 40 60 80 100];
IrDemand=2.54;%centimeters
Co=0.9;
Reserve=0.10;                                                                                             
Dewater=1;
IrHour=16;%o'clock
NPBegin=8;%o'clock
NPEnd=18;%o'clock

for i=1:length(VolTank)
    for j=1:length(RoofA)
        for k=1:length(IrArea)
            for l=1:length(ipe)
%Call the function to run for result of case 1
[Pi3t(i,j,k,l) Pi4t(i,j,k,l) alpha(i,j,k,l) Pi1(i,j,k,l) Pi2(i,j,k,l) Pi3v(i,j,k,l) Pi4v(i,j,k,l) sigmaV(i,j,k,l) sigmaE(i,j,k,l) sigmaQ(i,j,k,l) sigmaD(i,j,k,l) sigmaO(i,j,k,l) sigmaI(i,j,k,l) sigmaU(i,j,k,l) sigmaM(i,j,k,l) sigmaS(i,j,k,l) sigmaY(i,j,k,l) d(i,j,k,l) N(i,j,k,l) s(i,j,k,l)]=Rain(AP,newdate,newmonth,prcp,VolTank(i),VolTankInit(i),IrArea(k),IrDemand,RoofA(j),Co,ipe(l),Reserve,Dewater,DWTime,IrHour,NPBegin,NPEnd);
            end
        end
    end
end
Pi3t=(reshape(Pi3t,1,numel(Pi3t)))';
Pi4t=(reshape(Pi4t,1,numel(Pi4t)))';
alpha=(reshape(alpha,1,numel(alpha)))';
Pi1=(reshape(Pi1,1,numel(Pi1)))';
Pi2=(reshape(Pi2,1,numel(Pi2)))';
Pi3v=(reshape(Pi3v,1,numel(Pi3v)))';
Pi4v=(reshape(Pi4v,1,numel(Pi4v)))';
sigmaV=(reshape(sigmaV,1,numel(sigmaV)))';
sigmaE=(reshape(sigmaE,1,numel(sigmaE)))';
sigmaQ=(reshape(sigmaQ,1,numel(sigmaQ)))';
sigmaD=(reshape(sigmaD,1,numel(sigmaD)))';
sigmaO=(reshape(sigmaO,1,numel(sigmaO)))';
sigmaI=(reshape(sigmaI,1,numel(sigmaI)))';
sigmaU=(reshape(sigmaU,1,numel(sigmaU)))';
sigmaM=(reshape(sigmaM,1,numel(sigmaM)))';
sigmaS=(reshape(sigmaS,1,numel(sigmaS)))';
sigmaY=(reshape(sigmaY,1,numel(sigmaY)))';
d=(reshape(d,1,numel(d)))';
N=(reshape(N,1,numel(N)))';
s=(reshape(s,1,numel(s)))';
%Output results of calculation on parameters for case 1

M=length(VolTank)*length(RoofA)*length(IrArea)*length(ipe);
V=repmat(VolTank',M/length(VolTank),1);
VInit=repmat(VolTankInit',M/length(VolTankInit),1);%cubic meters
RA1=(repmat(RoofA(:,1),length(VolTank),1))';
% RA2=(repmat(RoofA(:,2),length(VolTank),1))';
% RA3=(repmat(RoofA(:,3),length(VolTank),1))';
% RA4=(repmat(RoofA(:,4),length(VolTank),1))';
% RA5=(repmat(RoofA(:,5),length(VolTank),1))';
% RA6=(repmat(RoofA(:,6),length(VolTank),1))';
% RA7=(repmat(RoofA(:,7),length(VolTank),1))';
% RA8=(repmat(RoofA(:,8),length(VolTank),1))';
% RA9=(repmat(RoofA(:,9),length(VolTank),1))';
% RA10=(repmat(RoofA(:,10),length(VolTank),1))';
RAK=[RA1]';
RA=repmat(RAK,M/(length(VolTank)*length(RoofA)),1);
IrA1=(repmat(IrArea(:,1),length(VolTank)*length(RoofA),1))';
% IrA2=(repmat(IrArea(:,2),length(VolTank)*length(RoofA),1))';
% IrA3=(repmat(IrArea(:,3),length(VolTank)*length(RoofA),1))';
% IrA4=(repmat(IrArea(:,4),length(VolTank)*length(RoofA),1))';
% IrA5=(repmat(IrArea(:,5),length(VolTank)*length(RoofA),1))';
% IrA6=(repmat(IrArea(:,6),length(VolTank)*length(RoofA),1))';
IrAK=[IrA1]';
IrA=repmat(IrAK,M/(length(VolTank)*length(RoofA)*length(IrArea)),1);
P1=(repmat(ipe(:,1),length(VolTank)*length(RoofA)*length(IrArea),1))';
P2=(repmat(ipe(:,2),length(VolTank)*length(RoofA)*length(IrArea),1))';
P3=(repmat(ipe(:,3),length(VolTank)*length(RoofA)*length(IrArea),1))';
P4=(repmat(ipe(:,4),length(VolTank)*length(RoofA)*length(IrArea),1))';
P5=(repmat(ipe(:,5),length(VolTank)*length(RoofA)*length(IrArea),1))';
P6=(repmat(ipe(:,6),length(VolTank)*length(RoofA)*length(IrArea),1))';
% P7=(repmat(ipe(:,7),length(VolTank)*length(RoofA)*length(IrArea),1))';
% P8=(repmat(ipe(:,8),length(VolTank)*length(RoofA)*length(IrArea),1))';
% P9=(repmat(ipe(:,9),length(VolTank)*length(RoofA)*length(IrArea),1))';
% P10=(repmat(ipe(:,9),length(VolTank)*length(RoofA)*length(IrArea),1))';
PK=[P1 P2 P3 P4 P5 P6]';
P=repmat(PK,M/(length(VolTank)*length(RoofA)*length(IrArea)*length(ipe)),1);

IrDemand=repmat(IrDemand,M,1);%centimeters
Co=repmat(Co,M,1);
Reserve=repmat(Reserve,M,1);                                                                                             
Dewater=repmat(Dewater,M,1);
IrHour=repmat(IrHour,M,1);%o'clock
NPBegin=repmat(NPBegin,M,1);%o'clock
NPEnd=repmat(NPEnd,M,1);%o'clock
DWTime=repmat(DWTime,M,1);%hours
Wsupply = sigmaY./sigmaD;
Wcapture = 1-(sigmaU./sigmaQ);

name={'Tank Volume','Initial Volume','Roof Area','Runoff Coefficient','Irrigation Area','Irrigation Demand','Irrigation Time','Indoor Population','Nonpotable Use Begin','Nonpotable Use End','Reserve Target','Dewater Target','Dewater Duration'};
xlswrite(['C:\Users\david\Documents\MATLAB\' namecity 'Para.xlsx'],name,'IR','B2:O2');%Change the path to that of "Richmond.xlsx" on your PC
input=[V VInit RA Co IrA IrDemand IrHour P NPBegin NPEnd Reserve Dewater DWTime];
xlswrite(['C:\Users\david\Documents\MATLAB\' namecity 'Para.xlsx'],input,'IR','B3:O5405');%Change the path to that of "Richmond.xlsx" on your PC
parameter={'Pi3t','Pi4t','alpha','Pi1','Pi2','Pi3v','Pi4v','sig(Storage)','sig(Deficit)','sig(Runoff)','sig(Demand)','sig(Outflow)','sig(Inspill)','sig(Spill)','sig(Import)','sig(SupYield)','sig(Yield)','DeficitHours','TotalHours','SpillHours','water Supply','runoff capture'};
xlswrite(['C:\Users\david\Documents\MATLAB\' namecity 'Para.xlsx'],parameter,'IR','P2:AJ2');%Change the path to that of "Richmond.xlsx" on your PC
data=[Pi3t Pi4t alpha Pi1 Pi2 Pi3v Pi4v sigmaV sigmaE sigmaQ sigmaD sigmaO sigmaI sigmaU sigmaM sigmaS sigmaY d N s Wsupply Wcapture];
xlswrite(['C:\Users\david\Documents\MATLAB\' namecity 'Para.xlsx'],data,'IR','P3:AK5405');%Change the path to that of "Richmond.xlsx" on your PC

%Stop time recording
toc;