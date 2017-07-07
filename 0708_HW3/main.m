clear
clc

dataprocess
NumberOfTarget=2;
for j=1:NumberOfTarget
    IIM(j).value=CaculateIIM(data(j).value);
end
%% �p�� gain
% ��X�Ĥ@�ӳQ��JSelected Pool(SP)���A�]��max_index
for j=1:NumberOfTarget
    IIMmax=-100;
    for i=1:Updown
        if IIM(j).value(i,Updown)>IIMmax
            IIMmax=IIM(j).value(i,Updown);
            max_index=i;
        end
    end
end

%��Xgain�j��0���S�x�ܼ�

for j=1:NumberOfTarget
    NumberOfSP=0;
    for i=1:Updown
        gain=IIM(j).value(i,Updown)-IIM(j).value(i,max_index);
        if gain>=0
            NumberOfSP=NumberOfSP+1;
            SP(j).value(NumberOfSP)=i;
        end
    end
end


%% �p���л\�v
nOL=[0];
omega=[1000];
for j=1:NumberOfTarget
    for i=1:length(SP(j).value)
        for ii=1:length(omega)
            if SP(j).value(i)==omega(ii)
                nOL(ii)=nOL(ii)+1;
            end
        end
        nOL(ii+1)=nOL(ii)+1;
        omega(ii+1)=SP(j).value(i);
    end
end

