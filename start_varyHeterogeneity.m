% This the main file that starts each code
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
Cluster_Radius_Init = 25;
Cluster_Radius_Step = 5;
current_Cluster_Radius = Cluster_Radius_Init;
numFrames = 15;

Neighbor_Count = zeros (Num_Sensors, 1);
Neighbors = zeros (Num_Sensors, Num_Sensors);
Distance =  zeros (Num_Sensors, Num_Sensors);


Initial_Energy = 0.5;
Min_Energy = 0.01;
Ratio_High_Low_Energy = 5;
Sensor_Node_Energy = ones (Num_Sensors, 1) * Initial_Energy;



count = 0;
maxCount = 12;
Percent_High_Energy_Nodes = 5;
Percent_High_Energy_Nodes_Step = 5;
filePath = '..\Sensor_Network\Sensor_Network_100_100_';

while (count < maxCount)    
    fileName = strcat (filePath, int2str (Percent_High_Energy_Nodes), '.txt');
    Sensor_Nodes = readFromFile(fileName);    
    % Calculating distance between the sensor nodes
for i=1 : Num_Sensors        
    for j=1 : Num_Sensors            
        Distance(i,j) = getDistance(Sensor_Nodes(i,1), Sensor_Nodes(i,2), Sensor_Nodes(j,1), Sensor_Nodes(j,2));
    end
end   
    Number_High_Energy_Nodes = Num_Sensors * Percent_High_Energy_Nodes/100;
    Number_Low_Energy_Nodes = round(Num_Sensors * (1-(Percent_High_Energy_Nodes/100)));
    
    for j = 1 : Number_High_Energy_Nodes
        Sensor_Node_Energy (Number_Low_Energy_Nodes+j) = Initial_Energy * Ratio_High_Low_Energy;
    end
    count = count + 1;
    run_GC (Packet_Size, Packet_Transmission_Cost, Amplification_Energy_Multi_Path, Amplification_Energy_Free_Space, Energy_Data_Aggregation, Num_Sensors, BS, Threshold_Distance, Sensor_Nodes, Distance, Sensor_Node_Energy, current_Cluster_Radius, count, Min_Energy, numFrames);
%     current_Cluster_Radius = current_Cluster_Radius + Cluster_Radius_Step;    
    Percent_High_Energy_Nodes = round(Percent_High_Energy_Nodes + Percent_High_Energy_Nodes_Step);
end




