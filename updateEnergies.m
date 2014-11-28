function [Sensor_Node_Energy, Energy_Used_This_Round, MessagesTransmittedThisRound] = updateEnergies(Number_Sensor_Nodes, Y, Sensor_Nodes, BS, Threshold_Distance, Packet_Size, Packet_Transmission_Cost, Amplification_Energy_Free_Space, Amplification_Energy_Multi_Path, Energy_Data_Aggregation, Sensor_Node_Energy, Distance, Cluster_Radius, numFrames, Min_Energy)
Energy_Used_This_Round = 0;
MessagesTransmittedThisRound = 0;
%clusterSize = calculateClusterSize (Number_Sensor_Nodes, Y);
clusterHead = findClusterHead (Number_Sensor_Nodes, Y);
numPackets = zeros (Number_Sensor_Nodes, numFrames);

for i = 1 : Number_Sensor_Nodes
    if ((Sensor_Node_Energy (i) > Min_Energy) &&  (Y(i, i) ~= 1))
        Energy_Remaining = Sensor_Node_Energy (i) - Min_Energy;
        d = Distance (i, clusterHead (i));
        if (d > Threshold_Distance)
            Energy_Per_Packet = Packet_Size * (Packet_Transmission_Cost + Amplification_Energy_Free_Space * (d) ^ 2) ;
        else
            Energy_Per_Packet = Packet_Size * (Packet_Transmission_Cost + Amplification_Energy_Multi_Path * (d) ^ 4) ;
        end
        packetsToBeSent = min (numFrames, floor(Energy_Remaining/Energy_Per_Packet));
        Cost = packetsToBeSent * Energy_Per_Packet;
        for j = 1 : packetsToBeSent
            numPackets (clusterHead (i), j) = numPackets (clusterHead (i), j) + 1;
        end
        if (packetsToBeSent == numFrames)
        Sensor_Node_Energy (i) = Sensor_Node_Energy (i) - Cost;
        else 
        Sensor_Node_Energy (i) = Min_Energy;
        end
        Energy_Used_This_Round = Energy_Used_This_Round + Cost;
    end
end

for i = 1 : Number_Sensor_Nodes
    if (Y(i, i) == 1)
        Signal_Size = 0;
        E_Signal  = Signal_Size * (Packet_Transmission_Cost + Amplification_Energy_Free_Space * (Cluster_Radius ^2));
        Energy_Remaining = Sensor_Node_Energy (i) - (Min_Energy + E_Signal) ;
        
        DtoBS = getDistance (Sensor_Nodes(i, 1), Sensor_Nodes(i, 2), BS(1, 1), BS(1, 2));
        
        if (DtoBS > Threshold_Distance)
            CostToBS = Packet_Size * Amplification_Energy_Multi_Path *(DtoBS)^4;
        else
            CostToBS = Packet_Size * Amplification_Energy_Free_Space *(DtoBS)^2;
        end
        
        for j = 1 : numFrames 
            Energy_This_Frame = (numPackets (i, j)+1) * (Packet_Size * (Packet_Transmission_Cost + Energy_Data_Aggregation)) + CostToBS;
            if (Energy_This_Frame <= Energy_Remaining)
                MessagesTransmittedThisRound = MessagesTransmittedThisRound + numPackets (i, j)+1;
                Energy_Remaining = Energy_Remaining - Energy_This_Frame;
                Energy_Used_This_Round = Energy_Used_This_Round + Energy_This_Frame;
                Sensor_Node_Energy (i) = Sensor_Node_Energy (i) - Energy_This_Frame;
            else
                Sensor_Node_Energy (i) = Min_Energy;
                break;
            end
        end 
        Sensor_Node_Energy (i) = Sensor_Node_Energy (i) - E_Signal;
    end
    
end
end






 