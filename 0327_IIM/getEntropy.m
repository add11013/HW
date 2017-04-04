function output = getEntropy(x)
%ENTRO Summary of this function goes here
%   Detailed explanation goes here
    
    pd=fitdist(x,'kernel');
    range=linspace(mean(x)-5*std(x),mean(x)+5*std(x),300);
    r=range(2)-range(1);
    y=pdf(pd,range);
    %plot(range,y);
    
    for i=1:length(y)
        p(i)=y(i)*log(1./y(i));
    end
    output=sum(p)*r;
end

