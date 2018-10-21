function field(PosX,PosY,Int,s)
%Function that plots the vector field, taking in input the position of the
%charges (PosX and PosY), the charge (Int) and the step (s).

    syms x y prob
    
    prob=Int(1)/sqrt((x-PosX(1))^2+(y-PosY(1))^2);%Calculating the electric potential 
    
    for i=2:length(PosX)
        prob=prob+(Int(i)/sqrt((x-PosX(i))^2+(y-PosY(i))^2));
    end
    
    %val=matlabFunction(prob,'vars',[x,y]);
    Fuga=-10*gradient(prob,[x,y]);
    
    bw = imread('nobel.jpg'); %Background image
    [X,Y]=meshgrid(0:s:11,0:s:6);
    
    m1=matlabFunction(Fuga(1),'vars',[x,y]);
    m2=matlabFunction(Fuga(2),'vars',[x,y]);
    FugaX=m1(X,Y);
    FugaY=m2(X,Y);
    
    scl=sqrt(FugaX.^2 + FugaY.^2 + 290*sqrt(max(Int)*abs(min(Int))));%Scale factor
    
    quiver(X,Y,0.*X,0.*Y,2); axis image; %First quiver to obtain the axis limits
    
    hax = gca; %get the axis handle
    image(hax.XLim,hax.YLim,bw); %plot the image within the axis limits
    
    hold on
    grid on
    
    h=quiver(X,Y,FugaX./scl,FugaY./scl,2);%Plot of the vector field
    
    set(h,'AutoScale','on');%Quiver settings
    set(h,'maxheadsize',0.2);
    set(h,'AutoScaleFactor',0.8);
    set(h,'Color',[1,1,1]);
    
    
    for i=1:length(PosX)%Plot of the charges.
        if(Int(i)<0)
            plot(PosX(i),PosY(i),'og','linewidth',4)%Negative charges
        else
            plot(PosX(i),PosY(i),'ow')%Positive charges
        end
    end
    set(gca,'xtick',[])
    set(gca,'ytick',[])
end