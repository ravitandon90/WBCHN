function [frac_sum_avg, aveCHE_ratio] = run_GC (Packet_Size, Packet_Transmission_Cost, Amplification_Energy_Multi_Path, Amplification_Energy_Free_Space, Energy_Data_Aggregation, Num_Sensors, BS, Threshold_Distance, Sensor_Nodes, Distance, Sensor_Node_Energy, Cluster_Radius, count, Min_Energy, numFrames)
Number_Low_Energy_Nodes = 80;

path = 'C:/Users/RaviHome/Desktop/Results_H/fraction_energy/Mod-GC/dataPerRound_Mod-GC_';
fileName = strcat (path, int2str(count), '.txt');
collectedDataPerRound = fopen (fileName, 'w');


eff_num_it = 0;
total_Energy_Used = 0;
total_Messages_Transmitted = 0;
frac_sum=0;
aveClusterHeadEnergySum=0;
while (1)
[Neighbors, Neighbor_Count] = getNeighbors (Num_Sensors, Sensor_Nodes, Distance, Sensor_Node_Energy, Min_Energy, Cluster_Radius);

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
aveClusterHeadEnergySum = aveClusterHeadEnergySum + aveClusterHeadEnergy/averageEnergy_alive;
end

fprintf(collectedDataPerRound, '%d\t%d\t%f\t%f\t%d\t%f\t%f\t%f\t%f\t%f\t%d\t%f\t%f\t%f\t%f\t%f\t%f\r\n',  eff_num_it, nodesAlive, NumberDead/Num_Sensors, total_Messages_Transmitted/10000, numClusterHead, averageEnergy, stdDevEnergy, total_Energy_Used, EnergyUsedThisRound, stdDev, maxClusterSize, aveClusterHeadEnergy, averageEnergy_alive, numMessagesTransmittedThisRound/10000, stdDevEnergy_alive, frac, aveClusterHeadEnergy/averageEnergy_alive);

if (NumberDead >= 0.95*(Num_Sensors))
    break;
end

end

frac_sum_avg = frac_sum/eff_num_it;
aveCHE_ratio = aveClusterHeadEnergySum/eff_num_it;
end