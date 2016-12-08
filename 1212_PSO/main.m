clear
clc
close all;
%% target
point=50;
x1=linspace(-1,1,point);
x2=linspace(-1,1,point);
k=1;
for i=1:point
    for j=1:point
        target(i,j)=x1(i).^2+x2(j).^2+10;        
        y(k)=x1(i).^2+x2(j).^2+10;          
        PP{k}=[x1(i),x2(j)];
        k=k+1;
    end
end

mesh(x1,x2,target);


%% initialization
swarm_size = 100;                       % number of the swarm particles
maxIter = 100;                          % maximum number of iterations
inertia = 1;                           % W
correction_factor = 2.0;               % c1,c2
swarm(:,2,:) = 0;                      % set initial velocity for particles
swarm(:,4,1) = 1000;                   % pbest
gbest=1;

for i=1:swarm_size
            swarm(i,1,:)=-1+2*rand(1);
            swarm(i,1,2)=-1+2*rand(1);
end
    

%% main loop
for i=1:maxIter

    
    %move
    swarm(:,1,1) = swarm(:,1,1) + swarm(:,2,1);
    swarm(:,1,2) = swarm(:,1,2) + swarm(:,2,2);
    
    %caculate error
    for i=1:swarm_size
        for j=1:2375
            yHead(j)=(PP{j}(1)-swarm(i,1,1)).^2+(PP{j}(2)-swarm(i,1,2)).^2+10;
        end
            error=sum((y(1:2375)-yHead)).^2/2375;
        if error<swarm(i,4,1)
            swarm(i,3,:)=swarm(i,1,:);
            swarm(i,4,1)=error;
            if error<swarm(gbest,4,1)
                gbest=i;
            end
        end
        
    end
    
    
    %change velocity
    for i=1:swarm_size
        A=inertia*swarm(i,2,:);%??
        B=correction_factor*rand(1)*0.1*(swarm(i,3,:)-swarm(i,1,:));%pbest
        C=correction_factor*rand(1)*0.1*(swarm(gbest,3,:) - swarm(i,1,:));%gbest
        swarm(i,2,:)=A+B+C;
    end
end

%% result

figure(2)
for i=1:point
    for j=1:point
        result(i,j)=(x1(i)-swarm(gbest,1,1)).^2+(x2(j)-swarm(gbest,1,2)).^2+10;        %mesh z
    end
end
mesh(x1,x2,result);


