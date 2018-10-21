%% Clean
clear  
close all
clc; 

%% Data

%Known data useful for the resolution. 

p0=101325;          %Pa
L=0.0065;           
g=9.80665;
R=8.31447;
T0=288.15;          %K
M=0.0289644;


%Variables

m_min = 0.25;
z_min = 1000;
z_max = 1800;
lambda_m = 0.3;
lambda_z = 0.7;

%% First plot of the vector field
%We plot positive charges (battles) knowing thetir position from the study of
%the conflict (the user gives the data). Every battle has his charge based
%on the impact that had.
px=[1.371,1.4,1.739,2.027,2.,2.212,2.396,2.649,2.799,3.133,2.315,3.732,5.425,5.494,4.941,6.473,4.296];
py=[3.882,3.5,4.824,4.041,3.5,3.759,2.988,3.453,3.845,3.245,4.824,3.918,4.971,5.18,2.424,1.861,3.747];
qq=[9,4,5,5,5,4,4,4,4,10,4,7,4,4,4,4,2.5];
s=0.1; %default 0.5; step used to plot the vetor field

figure
field(px,py,qq,s) %function that plots the vector field
title("Field lines, Yemen")


%% Data extraction from satellite
finfo = ncinfo('dati.nc');
pressure  = ncread('dati.nc','Psurf_f_tavg');

moisture  = ncread('dati.nc','SoilMoi100_200cm_tavg');



%% Altitude given the pressure in the point

%Using the pressure data obtained from the satallite to calculate the
%land altitude.


zr =@(pres) -((T0*R)/(M*g)).*log(pres./p0);
height = zr(pressure);



%% Choice of the altitude values

%The only parts of Yemen that are considered intersting are the one between
%1000m and 1800m. In first approssimation it is considered that the
%refugees would escape from armies in a mountain zone, but they wouldn't
%want to reach too high peaks. 

%Matrix size, in this case they are equal.
s=size(height);

for i = 1:s(1,1)
    for j = 1:s(1,2)
        if height(i,j) < z_max      %Maximum altitude
            if height(i,j)> z_min    %Minumum altitude
            else
                height(i,j) = 0;
            end  
            
        else
            height(i,j) = 0;
        
        end
    end
end




%% Choice of the moisture values
%It is aspected that the population will move to an area with an elevated
%moisture value


for i = 1:s(1,1)
    for j = 1:s(1,2)
        if moisture(i,j) >m_min       %Minuimum moisture
        else
            moisture(i,j) = 0;
        
        end
    end
end

%% Yem sizing

%The data from the satellite cover an area way bigger then Yemen. It is
%necessary to resize the table to fit Yemen position.
Yem_height=height(180:294,215:348);
Yem_moisture=moisture(180:294,215:348);


figure
spy(Yem_height)
figure
surf(Yem_moisture)
%% Data usability - 
%Inserting the data directly inside ??? will be equal to consider a
%distribuited charge. Unfortunatly the computational power requested to
%manage a distribuited charge of such dimension is not usually available.
%The data will be rearranged and concentred, and then calculated inside the
%???.



s=size(Yem_height);

%The space will be divided in 100 clusters. For each cluster the center of
%the charge will be found, and the total charge will be the sum of all the
%INFINITESIME charges. 
x_s = floor(linspace(1,s(1,1),10));
y_s = floor(linspace(1,s(1,2),10));


%Creation of data used in the cycles
x_s_0 = 1;
y_s_0 = 1;


X_z = [];
Y_z = [];
Q_z = [];

X_m = [];
Y_m = [];
Q_m = [];


for x_s_i = x_s(2:end)
    for y_s_i = y_s(2:end)
        x_z = [];
        y_z = [];
        q_z = [];
        
        
        x_m = [];
        y_m = [];
        q_m = [];
        for i = x_s_0:x_s_i
            for j =y_s_0:y_s_i
                if Yem_height(i,j) ~= 0
                    x_z = [x_z,i];
                    y_z = [y_z,j];
                    
                    
                    %The charge of the single point will be weighted as a
                    %sinusoid function, in order to have the maximum value
                    %in the middle range, and the minimum at the
                    %extremisis.
                    q_z = [q_z,abs(cos(z_min+(z_max-z_min)/2-Yem_height(i,j))*(pi/(z_max-z_min)))];
                elseif Yem_moisture(i,j) ~= 0
                    x_m = [x_m,i];
                    y_m = [y_m,j];
                    
                    
                    %The charge of the single point will be weighted as a
                    %exponential function. More moisture is present in
                    %the terrain, the better will be.
                    q_m = [q_m,-exp(-Yem_moisture(i,j)+m_min)+1];
                end 
            end
        end
        
        %The center of charge will be calculated with the weight formula. 
        X_z = [X_z, (x_z*q_z')./sum(q_z)];
        Y_z = [Y_z, (y_z*q_z')./sum(q_z)];
        Q_z = [Q_z, sum(q_z)];
        
        X_m = [X_m, (x_m*q_m')./sum(q_m)];
        Y_m = [Y_m, (y_m*q_m')./sum(q_m)];
        Q_m = [Q_m, sum(q_m)];

        
        
        y_s_0 = y_s_i;
         
    end
    x_s_0 =x_s_i;
end

figure
hold on 
grid on 
%plot(X_m,Y_m,'d')
plot(X_z,Y_z,'d')

%The final center of charge will be:


X = [X_m,X_z];
Y = [Y_m,Y_z];
Q = [Q_m*lambda_m,Q_z.*lambda_z];




%% Second plot of the vector field
%First of all we need do scale the position of the negative charges to fit
%them into the vector field plot
Xp=(11.*X)./114;
Yp=6-((6.*Y)./133);

%We create new vectors considering the new data acquired by landsat 8
PX=[px,Xp];
PY=[py,Yp];
Q=[qq,-Q];
s=0.1; %default 0.5

%Plot of the new vetor field
figure
field(PX,PY,Q,s)
title("Field lines, Yemen")
