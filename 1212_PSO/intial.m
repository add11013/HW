clear
clc
%% orginal data
x1=-1+(2).*rand(1,50);
x2=-1+(2).*rand(1,50);

for i=1:50
    for j=1:50
        swarm{i,j}=[x1(i),x2(j)];
        y1(i,j)=swarm{i,j}(1).^2+10;
        y2(i,j)=swarm{i,j}(2).^2+10;
    end
end
y=y1+y2;
figure(2);
mesh(x1,x2,y);

%% initialization

maxIter = 200;                          % maximum number of iterations
inertia = 1;                           % W
correction_factor = 2.0;               % c1,c2
swarmV=cell(50,50);                    % set initial velocity for particles
swarmPbest=cell(50,50);                % Pbest position
Gbest=1000;
for i=1:50
    for j=1:50
        swarmV{i,j}=[0,0];             %initial Velocity
        swarmPbest{i,j}=swarm{i,j};    %initial Pbest position
        Pbest(i,j)=1000;               %initial Pbest distance
    end
end
