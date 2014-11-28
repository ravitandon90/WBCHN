% Generic Weight Based Clustering 
clc
Packet_Size = 4000; % packet size 500 Bytes => 4000 bits.
Packet_Transmission_Cost = 50 * (10 ^ -9); % Packet Transmission Cost = 50 nano Joule per Bit per Packet
Amplification_Energy_Multi_Path = 13 * (10 ^ -16);   % Packet Amplification Cost = 0.0013 pico Joule per Bit per metre squared
Amplification_Energy_Free_Space = 10  * (10 ^ (-12)); % 
Energy_Data_Aggregation = 5 * (10 ^ -9);
Num_Sensors = 100;
Area_Net = 100 * 100;
Radius_Net = sqrt(Area_Net/pi);
BS = [1200, 1200];
Threshold_Distance = 75;
Cluster_Radius = 25;
Distance = zeros(Num_Sensors, Num_Sensors);
% We get the position of the sensor nodes
Sensor_Nodes = readFromFile('..\Sensor_Network\Sensor_Network_100_100_10.txt');
% Sensor_Nodes = zeros (Num_Sensors, 2);
% num = rand (Num_Sensors, 2);
% for i = 1 : Num_Sensors
%     radius = num(i, 1)* Radius_Net;
%     theta = num(i, 2)*2*pi;
%     Sensor_Nodes (i, 1) = BS (1, 1) + Radius_Net * cos (theta);
%     Sensor_Nodes (i, 2) = BS (1, 2) + Radius_Net * sin (theta);
% end

collectedDataPerRound = fopen ('C:/Users/RaviHome/Desktop/Results_H/vornoi.txt', 'w');
Percent_High_Energy_Nodes = 10;

Number_High_Energy_Nodes = Num_Sensors * Percent_High_Energy_Nodes/100;
Number_Low_Energy_Nodes = Num_Sensors * (1-(Percent_High_Energy_Nodes/100));

Neighbor_Count = zeros (Num_Sensors, 1);
Neighbors = zeros (Num_Sensors, Num_Sensors);

for i=1 : Num_Sensors        
    for j=1 : Num_Sensors            
        Distance(i,j) = getDistance(Sensor_Nodes(i,1), Sensor_Nodes(i,2), Sensor_Nodes(j,1), Sensor_Nodes(j,2));
        if (Distance (i, j) < Cluster_Radius)
            Neighbor_Count (i) = Neighbor_Count (i) + 1;
            Neighbors (i, Neighbor_Count (i)) = j;
        end
    end
end
Initial_Energy = 0.5;
Min_Energy = 0.01;
Ratio_High_Low_Energy = 5;
Sensor_Node_Energy = ones (Num_Sensors, 1) * Initial_Energy;

for j = 1 : Number_High_Energy_Nodes
    Sensor_Node_Energy (Number_Low_Energy_Nodes + j) = Initial_Energy * Ratio_High_Low_Energy;
end

Initial_Sensor_Node_Energy = Sensor_Node_Energy;


aveClusterHeadEnergySum=0;
eff_num_it = 0;
total_Energy_Used = 0;
total_Messages_Transmitted = 0;
frac_sum=0;
while (1)
%nrounds=nrounds+1;
[Neighbors, Neighbor_Count] = getNeighbors (Num_Sensors, Sensor_Nodes, Distance, Sensor_Node_Energy, Min_Energy,  Cluster_Radius);
Y = formClustersGC (Num_Sensors, Sensor_Node_Energy, Min_Energy, Neighbor_Count, Neighbors,Sensor_Nodes, BS, Amplification_Energy_Multi_Path, Amplification_Energy_Free_Space, Energy_Data_Aggregation, Packet_Size, Threshold_Distance, numFrames, Packet_Transmission_Cost);




%Sensor_Node_Energy = updateEnergies(Num_Sensors, Y, Sensor_Nodes, BS, Threshold_Distance, Packet_Size, Packet_Transmission_Cost, Amplification_Energy_Free_Space, Amplification_Energy_Multi_Path, Energy_Data_Aggregation, Sensor_Node_Energy, Distance);
[stdDev, maxClusterSize, aveClusterHeadEnergy] = clusterEval (Y, Sensor_Node_Energy, Min_Energy, Num_Sensors);

% Updating the energy within the sensor nodes 
[Sensor_Node_Energy, EnergyUsedThisRound, numMessagesTransmittedThisRound] = updateEnergies (Num_Sensors, Y, Sensor_Nodes, BS, Threshold_Distance, Packet_Size, Packet_Transmission_Cost, Amplification_Energy_Free_Space, Amplification_Energy_Multi_Path, Energy_Data_Aggregation, Sensor_Node_Energy, Distance, Cluster_Radius, numFrames, Min_Energy);


NumberDead = getNumberOfNodesDead (Sensor_Node_Energy, Min_Energy, Num_Sensors);

total_Messages_Transmitted = total_Messages_Transmitted + numMessagesTransmittedThisRound;

% Calculating Rounds
eff_num_it = eff_num_it + 1;

% Calculating Nodes Alive
nodesAlive = Num_Sensors - NumberDead; 
% Calculating NumberOfMessages Transmitted

% Calculating Number of cluster heads
[numClusterHead, frac] = calculateNumberOfClusterHeads (Num_Sensors, Sensor_Node_Energy, Min_Energy, Y, Number_Low_Energy_Nodes);

CH = zeros (numClusterHead, 2);
chCount = 0;
for var_i = 1 : Num_Sensors    
        if (Y(var_i, var_i) == 1)
            chCount = chCount+1;
            CH (chCount, 1:2) = Sensor_Nodes (var_i, 1:2);            
        end    
end

    HEN = zeros (Number_High_Energy_Nodes, 2);
for henCount = 1 :Number_High_Energy_Nodes
    HEN (henCount, 1:2) = Sensor_Nodes (henCount+ Number_Low_Energy_Nodes, 1:2);
end
LEN (1:Number_Low_Energy_Nodes, 1:2)= Sensor_Nodes (1:Number_Low_Energy_Nodes, 1:2);


figure (1);
plot (HEN(:,1), HEN(:,2), 'blue .');
hold on;
plot (LEN(:,1), LEN(:,2), 'red .');
hold on;
 plot (CH(:, 1), CH (:, 2), 'square');
hold on;
% voronoi (CH(:,1), CH(:,2), 'square');
for cc = 1 :  numClusterHead
t = linspace(0,2*pi,1000);
r=25;
x = r*cos(t)+CH(cc, 1); 
y = r*sin(t)+CH(cc, 2); 
plot(x,y); 
axis square; 
hold on;
end
break;

frac_sum = frac_sum + frac;
% Calculating Average Energy 
averageEnergy = mean (Sensor_Node_Energy);

% Calculating Std Dev Energy 
stdDevEnergy = std (Sensor_Node_Energy);

% Calculating Total Energy Used
total_Energy_Used = total_Energy_Used + EnergyUsedThisRound;


% Calculating Energy Remaining of Nodes Alive
Energy_Nodes_Alive = getEnergyNodesAliveMatrix (nodesAlive, Sensor_Node_Energy, Num_Sensors, Min_Energy);
stdDevEnergy_alive = std (Energy_Nodes_Alive);
averageEnergy_alive = mean (Energy_Nodes_Alive);
if (~isnan(aveClusterHeadEnergy/averageEnergy_alive))
aveClusterHeadEnergySum= aveClusterHeadEnergySum + aveClusterHeadEnergy/averageEnergy_alive;
end

fprintf(collectedDataPerRound, '%d\t%d\t%f\t%f\t%d\t%f\t%f\t%f\t%f\t%f\t%d\t%f\t%f\t%f\t%f\t%f\t%f\r\n',  eff_num_it, nodesAlive, NumberDead/Num_Sensors, total_Messages_Transmitted/10000, numClusterHead, averageEnergy, stdDevEnergy, total_Energy_Used, EnergyUsedThisRound, stdDev, maxClusterSize, aveClusterHeadEnergy, averageEnergy_alive, numMessagesTransmittedThisRound/10000, stdDevEnergy_alive, frac, aveClusterHeadEnergy/averageEnergy_alive);

if (NumberDead >= 0.95*(Num_Sensors))
    frac_sum/eff_num_it
    aveClusterHeadEnergySum/eff_num_it
    break;
end

end

fclose (collectedDataPerRound);