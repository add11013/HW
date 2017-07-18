function output=FeatureSelection(OriginalData)
%get feature
    datapdiff

    %%Get ALL Feature
    %AllFeature=[ ];
    % for i=1:NumberOfTarget
    %     TMP=data(i).value(:,1:Updown-1);
    %     AllFeature=[AllFeature TMP];
    % end
    % for i=1:NumberOfTarget
    %     IIMData(i).value=[AllFeature data(i).value(:,Updown)];
    % end
    % 
    %  for i=1:NumberOfTarget
    %      IIM(i).value=CaculateIIM(IIMData(i).value);
    %  end

    load('IIM')
    %% �p�� gain
    % ��X�Ĥ@�ӳQ��JSelected Pool(SP)��feature
    for jj=1:NumberOfTarget
        IIMmax=-100;
        %�̫�@��N�O�ؼЩҦb�����
        ColOfTarget=length(IIM(jj).value);
        %-1�O�]�����κ��ؼ�
        for i=1:length(IIM(jj).value)-1
            if IIM(jj).value(i,ColOfTarget)>IIMmax
                IIMmax=IIM(jj).value(i,ColOfTarget);
                SP(jj).value(1)=i;
            end
        end
    end

    %��Xgain�j��0���S�x�ܼ�
    for j=1:NumberOfTarget
        NumberOfSP=1;
        %-1�O�]�����κ��ؼ�
        for i=1:length(IIM(jj).value)-1
            %��ثe�bSP�̨C�ӯS�x�y�������l��T�q
            Redundancy=0;
            for ii=1:length(SP(j).value)
                InformationFiTOFii=IIM(j).value(i,SP(j).value(ii));
                InformationFiiTOFi=IIM(j).value(SP(j).value(ii),i);
                Redundancy=Redundancy+(InformationFiTOFii+InformationFiiTOFi)/2;
            end
            %��i�ӯS�x���j�ӥؼЪ���T�q
            InformationFiTOTj=IIM(j).value(i,ColOfTarget);
            %��i�ӯS�x���j�ӥؼЪ��W�q��T�q(gain)
            gain=InformationFiTOTj-Redundancy;
            if gain>=0
                SP(j).gain(NumberOfSP)=gain;
                SP(j).value(NumberOfSP)=i;
                NumberOfSP=NumberOfSP+1;
            end
        end
    end


    %% Omega�AOmega���C��SP�̪��S�x���X(���Ʒ�@�@��)
    %�N�Ĥ@��SP�̪��S�x�����[�JOmega
    Omega=SP(1).value;
    LengthOfOmega=length(Omega);
    %�@�}�l�w�g�NSP(1)�����[�JOmega�ҥH�q2�}�l
    for i=2:NumberOfTarget
        for ii=1:length(SP(i).value)
            %any (x==a)�p�Gx�����@�өΦh��a�^��1�A�S�h�^��0
            %�YOmega���S��SP(i).value(ii)�A�NSP(i).value(ii)�[�JOmega
            if ~any(Omega==SP(i).value(ii))
                LengthOfOmega=LengthOfOmega+1;
                Omega(LengthOfOmega)=SP(i).value(ii);
            end
        end
    end
    %% �p��NOL�ANOL���S�x�ثe�X�{���ֿn����
    NOL(1:LengthOfOmega)=0;
    for i=1:NumberOfTarget
        for ii=1:LengthOfOmega
            %��Omega(ii)���S���bSP(i).value�̡A��NOL�N+1
            if any(SP(i).value==Omega(ii))
                NOL(ii)=NOL(ii)+1;
            end
        end
    end

    %% �p��w�Aw���л\�v
    for i=1:length(NOL)
        w(i)=NOL(i)/NumberOfTarget;
    end
    wMean=mean(w);

    %% �p��gsum�Agsum���S�x�b�C��SP�̪�gain�`�M
    gSum(1:LengthOfOmega)=0;
    for i=1:length(Omega)
        for ii=1:NumberOfTarget
            for iii=1:length(SP(ii).value)
                if Omega(i)==SP(ii).value(iii)
                    gSum(i)=gSum(i)+SP(ii).gain(iii);
                end
            end
        end
    end
    gSumMean=mean(gSum);

    %% �p��p�Ap���`�^�m�q(W*gsum)
    NumberOfFP=0;
    for i=1:LengthOfOmega
        p(i)=w(i)*gSum(i);
        if p(i)>wMean*gSumMean
            NumberOfFP=NumberOfFP+1;
            FP.index(NumberOfFP)=Omega(i);
        end
    end

    %% �w�W�U�ɡA�קKFP��Ӧh�ΤӤ�
    Upper=4;
    lower=2;
    %�N�C��FP�̪��S�x�^�m�ȧ�X�ӵ�FP.p
    for i=1:length(FP.index)
        for ii=1:LengthOfOmega
            if FP.index(i)==Omega(ii)
                FP.p(i)=p(ii);
            end
        end
    end
    %�Ѥj��p�Ƨ�FP������
    %�C�^�X�����i�ӷ��̤j�ȡA�D�X�̤j�ȻP��i�Ӱ��洫�A��i���Y�Ƨǧ���
    for i=1:length(FP.index)-1
        FPMAX=FP.p(i);
        MAXINDEX=i;
        %��X�̤j�Ȫ���m
        for ii=i:length(FP.index)
            if FP.p(ii)>FPMAX
                FPMAX=FP.p(ii);
                MAXINDEX=ii;
            end
        end
        %�o�^�X�̤j�ȻP��i��p�洫
        ptemp=FP.p(i);
        FP.p(i)=FP.p(MAXINDEX);
        FP.p(MAXINDEX)=ptemp;

        indextemp=FP.index(i);
        FP.index(i)=FP.index(MAXINDEX);
        FP.index(MAXINDEX)=indextemp;

    end

    %�N�S�x��output
    if length(FP.index)<lower
    elseif length(FP.index)>Upper
        output=FP.index(1:Upper);
    else
        output=FP.index;
    end
end