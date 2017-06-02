function[Pi3t Pi4t alpha Pi1 Pi2 Pi3v Pi4v sigmaV sigmaE sigmaQ sigmaD sigmaO sigmaI sigmaU sigmaM sigmaS sigmaY d N s]= Rain(AP,newdate,newmonth,prcp,VolTank,VolTankInit,IrArea,IrDemand,RoofA,Co,ipe,Reserve,Dewater,DWTime,IrHour,NPBegin,NPEnd)
%RAIN1 Summary of this function goes here
%   Detailed explanation goes here

%Initial settings on parameters
Runoff=zeros(length(prcp),24);
CisternStorage=zeros(length(prcp),24);
Spill=zeros(length(prcp),24);
InSpill=zeros(length(prcp),24);
Outflow=zeros(length(prcp),24);
SpillSum=zeros(length(prcp),24);%
NPU=zeros(length(prcp),24);
TotalDemand=zeros(length(prcp),24);
IrD=zeros(length(prcp),24);
Deficit=zeros(length(prcp),24);
ID=zeros();
MonthFunction=zeros();
IrrigateRate=zeros();
DWDay=floor(DWTime/24);
gpf=5.678117676;
fpd=4;

%Daily use: indoor nonpotable demand
IND=fpd*gpf*ipe/1000;%cubic meters
NP=IND/(NPEnd-NPBegin);%cubic meters
%Daily use: irrigation demand
IrrigateRate(1)=0;
%Begin the loop on dates, "i" stands for dates
%Omit the last few dates which is equal to dewater duration
CisternStorage(1,1)=VolTankInit;
Vardewater=(VolTank-VolTank*Dewater)/DWTime;
for i=1:(length(newdate)-(DWDay+1))
    if (mod(i+4,7))==2
        IrrigateRate(i)=IrDemand/2;
    elseif (mod(i+4,7))==5
        IrrigateRate(i)=IrDemand/2;
    else
        IrrigateRate(i)=0;
    end
    if newmonth(i)==1
        MonthFunction(i)=0;
    elseif newmonth(i)==2
        MonthFunction(i)=0;
    elseif newmonth(i)==3
        MonthFunction(i)=0;
    elseif newmonth(i)==10
        MonthFunction(i)=0;
    elseif newmonth(i)==11
        MonthFunction(i)=0;
    elseif newmonth(i)==12
        MonthFunction(i)=0;
    else
        MonthFunction(i)=1;
    end
    ID(i)=MonthFunction(i)*(IrArea*IrrigateRate(i)/100);%cubic meters
    IrD(i,IrHour)=ID(i);
%Daily use: total demand
l=NPBegin:NPEnd;
NPU(i,l)=NP;

%Begin the loop on hours, "j" stands for the daily 1st ~ 23rd hours
for j=1:23
Runoff(i,j)=(Co*prcp(i,j)*RoofA*2.54/10000)';%cubic meters
Runoff(i,24)=(Co*prcp(i,24)*RoofA*2.54/10000)';%cubic meters
TotalDemand(i,j)=(NPU(i,j)+IrD(i,j));
TotalDemand(i,24)=(NPU(i,24)+IrD(i,24));
CisternStorage(i,j+1)=CisternStorage(i,j)+Runoff(i,j)-TotalDemand(i,j);
CisternStorage(i+1,1)=CisternStorage(i,24)+Runoff(i,24)-TotalDemand(i,24);
SpillSum(i,j)=Spill(i,j)+InSpill(i,j);
SpillSum(i,24)=Spill(i,24)+InSpill(i,24);

%Cistern storage calculation without total demand
%Outflow is the water taken out of the tank for demand use, it is a part of
%the TotalDemand. Outflow+Deficit=TotalDemand
%Spill is the overflow from the tank due to large quantity of runoff inflow
%InSpill is the water taken out of the tank because of dewater process
DWDay1=floor((DWTime-(24-j))/24);
DWDay2=floor((DWTime-(24-j))/24);
%Cistern storage calculation with total demand
    if CisternStorage(i,j)-TotalDemand(i,j)>VolTank || CisternStorage(i,j)>VolTank
        Outflow(i,j)=TotalDemand(i,j);%as yield
        Spill(i,j)=CisternStorage(i,j)-VolTank;%to be discarded
        InSpill(i,j)=0;%for dewater
        CisternStorage(i,j)=VolTank;%new volume
        Deficit(i,j)=0;
    elseif CisternStorage(i,j)-TotalDemand(i,j)<=VolTank && CisternStorage(i,j)-TotalDemand(i,j)>VolTank*Dewater && Runoff(i,j)~=0
        Outflow(i,j)=TotalDemand(i,j);
        Spill(i,j)=0;
        InSpill(i,j)=0;
        CisternStorage(i,j)=CisternStorage(i,j);
        Deficit(i,j)=0;
    elseif CisternStorage(i,j)-TotalDemand(i,j)<=VolTank && CisternStorage(i,j)-TotalDemand(i,j)>VolTank*Dewater && Runoff(i,j)==0
        Outflow(i,j)=TotalDemand(i,j);
        Spill(i,j)=0;
        InSpill(i,j)=Vardewater;                        
        if DWTime>(24-j) && DWDay1>=1  && Dewater<1            
            k=1:(24-j);
            InSpill(i,j+k)=Vardewater;     
            h=1:DWDay1;
            InSpill(i+h,j)=Vardewater;
            m=1:(DWTime-(24-j)-24*DWDay1);
            InSpill(i+DWDay1+1,m)=Vardewater;
        end
        if DWTime>(24-j) && DWDay1==0 && Dewater<1
            k=1:(24-j);
            InSpill(i,j+k)=Vardewater;
            m=1:(DWTime-(24-j)-24*DWDay1);
            InSpill(i+DWDay1+1,m)=Vardewater;
        end
        if DWTime<=(24-j) && Dewater<1
            k=1:DWTime;
            InSpill(i,j+k)=Vardewater;
        end
        CisternStorage(i,j)=CisternStorage(i,j)-InSpill(i,j);
        Deficit(i,j)=0;
    elseif CisternStorage(i,j)-TotalDemand(i,j)<=VolTank*Dewater && CisternStorage(i,j)-TotalDemand(i,j)>=VolTank*Reserve
        Outflow(i,j)=TotalDemand(i,j);
        Spill(i,j)=0;
        InSpill(i,j)=0;
        CisternStorage(i,j)=CisternStorage(i,j);
        Deficit(i,j)=0;
    elseif CisternStorage(i,j)-TotalDemand(i,j)<VolTank*Reserve && CisternStorage(i,j)>VolTank*Reserve
        Outflow(i,j)=CisternStorage(i,j)-VolTank*Reserve;
        Spill(i,j)=0;
        InSpill(i,j)=0;
        Deficit(i,j)=TotalDemand(i,j)-Outflow(i,j);
        CisternStorage(i,j)=CisternStorage(i,j);
    elseif CisternStorage(i,j)-TotalDemand(i,j)<VolTank*Reserve && CisternStorage(i,j)<=VolTank*Reserve
        Outflow(i,j)=0;
        Spill(i,j)=0;
        InSpill(i,j)=0;
        Deficit(i,j)=TotalDemand(i,j)+VolTank*Reserve-CisternStorage(i,j); 
        CisternStorage(i,j)=VolTank*Reserve;       
    end
CisternStorage(i,j+1)=CisternStorage(i,j)+Runoff(i,j)-TotalDemand(i,j);
SpillSum(i,j)=Spill(i,j)+InSpill(i,j);
%Cistern storage calculation with total demand
    if CisternStorage(i,24)-TotalDemand(i,24)>VolTank || CisternStorage(i,24)>VolTank
        Outflow(i,24)=TotalDemand(i,24);%as yield
        Spill(i,24)=CisternStorage(i,24)-VolTank;%to be discarded
        InSpill(i,24)=0;%for dewater
        CisternStorage(i,24)=VolTank;%new volume
        Deficit(i,24)=0;
    elseif CisternStorage(i,24)-TotalDemand(i,24)<=VolTank && CisternStorage(i,24)-TotalDemand(i,24)>VolTank*Dewater && Runoff(i,24)~=0
        Outflow(i,24)=TotalDemand(i,24);
        Spill(i,24)=0;
        InSpill(i,24)=0;
        CisternStorage(i,24)=CisternStorage(i,24);
        Deficit(i,24)=0;
    elseif CisternStorage(i,24)-TotalDemand(i,24)<=VolTank && CisternStorage(i,24)-TotalDemand(i,24)>VolTank*Dewater && Runoff(i,24)==0
        Outflow(i,24)=TotalDemand(i,24);
        Spill(i,24)=0;
        InSpill(i,24)=Vardewater; 
        if DWTime>24  && Dewater<1
            h=1:DWDay2;       
            InSpill(i+h,24)=Vardewater;
            InSpill(i+h,j)=Vardewater;                
            m=1:(DWTime-24*DWDay2);
            InSpill(i+DWDay2+1,m)=Vardewater;
        end
        if DWTime<=24 && Dewater<1
            k=1:DWTime;
            InSpill(i+1,k)=Vardewater;
        end
        CisternStorage(i,24)=CisternStorage(i,24)-InSpill(i,24);
        Deficit(i,24)=0;
    elseif CisternStorage(i,24)-TotalDemand(i,24)<=VolTank*Dewater && CisternStorage(i,24)-TotalDemand(i,24)>=VolTank*Reserve
        Outflow(i,24)=TotalDemand(i,24);
        Spill(i,24)=0;
        InSpill(i,24)=0;
        CisternStorage(i,24)=CisternStorage(i,24);
        Deficit(i,24)=0;
    elseif CisternStorage(i,24)-TotalDemand(i,24)<VolTank*Reserve && CisternStorage(i,24)>VolTank*Reserve
        Outflow(i,24)=CisternStorage(i,24)-VolTank*Reserve;
        Spill(i,24)=0;
        InSpill(i,24)=0;
        Deficit(i,24)=TotalDemand(i,24)-Outflow(i,24);
        CisternStorage(i,24)=CisternStorage(i,24);
    elseif CisternStorage(i,24)-TotalDemand(i,24)<VolTank*Reserve && CisternStorage(i,24)<=VolTank*Reserve
        Outflow(i,24)=0;
        Spill(i,24)=0;
        InSpill(i,24)=0;         
        Deficit(i,24)=TotalDemand(i,24)+VolTank*Reserve-CisternStorage(i,24);      
        CisternStorage(i,24)=VolTank*Reserve;
    end
CisternStorage(i+1,1)=CisternStorage(i,24)+Runoff(i,24)-TotalDemand(i,24);
SpillSum(i,24)=Spill(i,24)+InSpill(i,24);
    if CisternStorage(i,j)-TotalDemand(i,j)<=VolTank && CisternStorage(i,j)-TotalDemand(i,j)>VolTank*Dewater && Runoff(i,j)==0 && Spill(i,j)==0
        InSpill(i,j)=Vardewater;
        SpillSum(i,j)=InSpill(i,j)+Spill(i,j);
    end
    if CisternStorage(i,24)-TotalDemand(i,24)<=VolTank && CisternStorage(i,24)-TotalDemand(i,24)>VolTank*Dewater && Runoff(i,24)==0 && Spill(i,24)==0
        InSpill(i,24)=Vardewater;
        SpillSum(i,24)=InSpill(i,24)+Spill(i,24);
    end
    if CisternStorage(i,j)-TotalDemand(i,j)<=VolTank*Dewater && CisternStorage(i,j)-TotalDemand(i,j)>VolTank*Reserve
        CisternStorage(i,j+1)=CisternStorage(i,j)-Outflow(i,j)+Runoff(i,j);
    end
    if CisternStorage(i,j)-TotalDemand(i,j)<VolTank*Reserve && CisternStorage(i,j)-TotalDemand(i,j)<=VolTank*Reserve
        CisternStorage(i,j+1)=VolTank*Reserve+Runoff(i,j);
    end
    if CisternStorage(i,24)-TotalDemand(i,24)>VolTank || CisternStorage(i,24)>VolTank
        CisternStorage(i,24)=VolTank;
    end
end
end

%Transpose matrices for display
rain=reshape(prcp',1,numel(prcp))*2.54;%centimeters
runoff=reshape(Runoff',1,numel(Runoff));%cubic meters
cs=reshape(CisternStorage',1,numel(CisternStorage));%cubic meters
spill=reshape(Spill',1,numel(Spill));%cubic meters
inspill=reshape(InSpill',1,numel(InSpill));%cubic meters
%spillsum=reshape(SpillSum',1,numel(SpillSum));%cubic meters
td=reshape(TotalDemand',1,numel(TotalDemand));%cubic meters
deficit=reshape(Deficit',1,numel(Deficit));%cubic meters
out=reshape(Outflow',1,numel(Outflow));%cubic meters
import=td-out;
supyield=min(td,cs);
yield=min(out,cs);
%result=[newhour' hour cs' deficit' runoff' td' out' inspill' spill' spillsum' supyield' yield'];

%Calculation on important parameters
%Pi3_t
d=numel(find(deficit>0));
N=numel(rain);
Pi3t=1-(d/N);
%Pi4_t
s=numel(find(spill>0));
Pi4t=1-(s/N);
%Yield ratio
alpha=sum(yield)/(AP*(2.54/100)*RoofA*numel(prcp)/(365*24));
%Pi1
Pi1=VolTank/(RoofA)^(3/2);
%Pi2
Pi2=sum(out)/(RoofA*(AP*(2.54/100))*numel(prcp)/(365*24));
%Pi3_v
Pi3v=sum(yield)/sum(td);
%Pi4_v
Pi4v=1-(sum(spill)/(sum(runoff)));

sigmaV=sum(cs);
sigmaE=sum(deficit);
sigmaQ=sum(runoff);
sigmaD=sum(td);
sigmaO=sum(out);
sigmaI=sum(inspill);
sigmaU=sum(spill);
sigmaM=sum(import);
sigmaS=sum(supyield);
sigmaY=sum(yield);

end
