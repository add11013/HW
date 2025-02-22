clear
close all;
clc
tic
TAIEX;
%% substractive clustering
h1=y(1:point-2);
h2=y(2:point-1);
h1std=std(h1);
h2std=std(h2);
h1Center=subclust(h1,0.3);
h2Center=subclust(h2,0.3);
%% formation matrix
count=1;
for i=1:length(h1Center)
    for ii=1:length(h2Center)
        formationMatrix(count,1)=i;
        formationMatrix(count,2)=ii;
        count=count+1;
    end
end
PrePara=(length(h1Center)+length(h2Center))*2;

%% firing strength
for i=1:point-2
    for rule=1:length(formationMatrix)
        beta(rule,i)=gaussmf(h1(i),[h1Center(formationMatrix(rule,1)),std(h1)])*gaussmf(h2(i),[h2Center(formationMatrix(rule,2)),std(h2)]);
    end
end

%% treshold
bb=1;
delFor=0;
for rule=1:length(formationMatrix)
    treshold=0.3*std(reshape(beta,length(formationMatrix)*(point-2),1));
    if std(beta(rule,:))<treshold
        bye(bb)=rule;
        bb=bb+1;
        delFor=1;
    end
end
if delFor==1
    bb=1;
    i=bye(bb);
    formationMatrix(i,:)=[];
    bye(bb)=[];
    while length(bye)~=0
        i=bye(bb);
        formationMatrix(i-1,:)=[];
        bye(bb)=[];
    end
end


%% RO parameters
  RO.swarm_size=max(3,4*log10(PrePara+1));
  RO.iterations=20*PrePara*1.3;
  %initialize the particles
  for i=1:RO.swarm_size
    for ii=1:PrePara
      swarm(i).Position(ii)=randn*yMean*sqrt(PrePara);
    end
  end
  RO.gBestPosition(1:PrePara)=0;
  RO.gBestDistance=1e12;


%% RLSE parameters
ConsPara=3*length(formationMatrix);
for i=1:RO.swarm_size
    swarm(i).RLSE.theta(1:ConsPara,1)=0;
    swarm(i).RLSE.P=1e7*eye(ConsPara);
end

%% main loop
for ite=1:RO.iterations
    stepsize=max(RO.iterations-ite-15*PrePara)/RO.iterations;
  for i=1:RO.swarm_size
      for iii=1:PrePara
        swarm(i).Position(iii)=RO.gBestPosition(iii)+randn*stepsize*yMean*sqrt(PrePara);
      end
      Iteration(ite).beta=[];
        for jj=1:point-2
            %Firing Strength
            j1=1;
            for number=1:PrePara/4
                termSet{1}(number)={[swarm(i).Position(j1:j1+1)]};
                j1=j1+2;
            end
            for number=1:PrePara/4
                termSet{2}(number)={swarm(i).Position(j1:j1+1)};
                j1=j1+2;
            end
            for rule=1:length(formationMatrix)
                Iteration(ite).beta(rule,jj)=gaussmf(h1(jj),termSet{1}{formationMatrix(rule,1)})*gaussmf(h2(jj),termSet{2}{formationMatrix(rule,2)});
            end
        end

      %Normalization
        for rule=1:length(formationMatrix)
            g(rule)=sum(Iteration(ite).beta(rule,:))/sum(Iteration(ite).beta(:));
        end

        for jj=1:point-2
            TMP0=[];
            for k=1:length(formationMatrix)
                TMP=[g(k) g(k)*y(jj) g(k)*y(jj+1)];
                TMP0=[TMP0 TMP];
            end
             swarm(i).RLSE.A(jj,:)=TMP0;
        end
        b=transpose(swarm(i).RLSE.A);
        for k=0:(point-2)-1
            swarm(i).RLSE.P=swarm(i).RLSE.P-(swarm(i).RLSE.P*b(:,k+1)*transpose(b(:,k+1))*swarm(i).RLSE.P)/(1+transpose(b(:,k+1))*swarm(i).RLSE.P*b(:,k+1));
            swarm(i).RLSE.theta=swarm(i).RLSE.theta+swarm(i).RLSE.P*b(:,k+1)*(y(k+3)-transpose(b(:,k+1))*swarm(i).RLSE.theta);
        end
      %new_yHead(output)
        for jj=1:point-2
            swarm(i).yHead(jj,1)=swarm(i).RLSE.A(jj,:)*swarm(i).RLSE.theta;  %y
           %caculate error
            e(jj,1)=(y(jj+2)-swarm(i).yHead(jj,1))^2;  % target-yHead
        end
      %rmse index
        swarm(i).rmse=sqrt(sum(e)/(point-2));

      %gbest
        if swarm(i).rmse<RO.gBestDistance
            gBest=i;                             %update which one is gbest
            RO.gBestDistance=swarm(i).rmse;         %update distance of gbest
            RO.gBestPosition=swarm(i).Position;
        end

  end
  RO.plotRMSE(ite) = RO.gBestDistance;
end

%% result
% OUTPUT and Target
      figure(2)
      subplot(1,2,1)
          semilogy(RO.plotRMSE);
          legend('Learning Curve');
          xlabel('iterations');
          ylabel('semilogy(rmse)');
      subplot(1,2,2)
          plot(1:RO.iterations,RO.plotRMSE,'x');
          legend('Learning Curve');
          xlabel('iterations');
          ylabel('rmse');
      figure(1);
        x=linspace(x(3),x(point),point-2);
        plot(x,swarm(gBest).yHead,'--');
%% test
        x=linspace(point+2,allpoint+1,testPoint);
        beta=[];
        testh1=y(point-1:allpoint-2);
        testh2=y(point:allpoint-1);
        for jj=1:testPoint
            %IFpart(Rule)
            j1=1;
            for number=1:PrePara/4
                termSet{1}(number)={[swarm(gBest).Position(j1:j1+1)]};
                j1=j1+2;
            end
            for number=1:PrePara/4
                termSet{2}(number)={swarm(gBest).Position(j1:j1+1)};
                j1=j1+2;
            end
            beta=[];
            for rule=1:length(formationMatrix)
                beta(rule,jj)=gaussmf(testh1(jj),termSet{1}{formationMatrix(rule,1)})*gaussmf(testh2(jj),termSet{2}{formationMatrix(rule,2)});
            end
        end
        %new_yHead(output)
        for rule=1:length(formationMatrix)
            g(rule)=sum(beta(rule,:))/sum(beta(:));
        end
        for jj=1:testPoint
            TMP1=[];
            for k=1:length(formationMatrix)
                TMP=[g(k) g(k)*y(point+jj-1) g(k)*y(point+jj)];
                TMP1=[TMP1 TMP];
            end
            A(jj,:)=TMP1;
            output2(jj,1)=A(jj,:)*swarm(gBest).RLSE.theta;  %y
        end
        for jj=1:testPoint
            RO.test.e(jj)=(y(jj+point-1)-output2(jj,1))^2;
        end
            RO.test.rmse=sqrt(sum(RO.test.e)/(testPoint))

        plot(x,output2,'r--');

toc
