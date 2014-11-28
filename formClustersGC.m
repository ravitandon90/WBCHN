function Y = formClustersGC (Num_Sensors, Sensor_Node_Energy, Min_Energy, Neighbor_Count, Neighbor, Sensor_Nodes, BS, Amplification_Energy_Multi_Path, Amplification_Energy_Free_Space, Energy_Data_Aggregation, Packet_Size, Threshold_Distance, numFrames, Packet_Transmission_Cost)
is_CH = zeros (Num_Sensors, 1);
is_Member = zeros (Num_Sensors, 1);
Energy_Index_Sensor_Nodes = zeros (Num_Sensors, 2);
Y = zeros (Num_Sensors, Num_Sensors);
neighborHoodEnergy = zeros (Num_Sensors, 1);
energyThisRound = zeros (Num_Sensors, 1);

for i = 1 : Num_Sensors
    if (Sensor_Node_Energy (i) > Min_Energy)        
        DtoBS = getDistance (Sensor_Nodes(i, 1), Sensor_Nodes(i, 2), BS(1, 1), BS(1, 2));        
        if (DtoBS > Threshold_Distance)
            CostToBS = Packet_Size * Amplification_Energy_Multi_Path *(DtoBS)^4;
        else
            CostToBS = Packet_Size * Amplification_Energy_Free_Space *(DtoBS)^2;
        end
        energyPerFrame = Neighbor_Count (i) * (Packet_Transmission_Cost + Energy_Data_Aggregation) + CostToBS;
        energyThisRound (i) = numFrames * energyPerFrame;
    end
end


for i = 1 : Num_Sensors
    sum_Energy = 0;
    max_Energy = 0;
    if (Sensor_Node_Energy (i) > Min_Energy)
          for j = 1 : Neighbor_Count (i)
              n_Index = Neighbor (i, j);
              if (Sensor_Node_Energy (n_Index) > Min_Energy)
                  sum_Energy = sum_Energy + Sensor_Node_Energy(n_Index);                  
                  if (max_Energy < Sensor_Node_Energy (n_Index))
                      max_Energy = Sensor_Node_Energy (n_Index);
                  end
              end
          end
          ave_Energy = sum_Energy / Neighbor_Count (i);
          diff_Energy = max_Energy - ave_Energy;
          if ((Sensor_Node_Energy (i) > (ave_Energy+0.80*diff_Energy)) && (energyThisRound (i) < (Sensor_Node_Energy(i)-Min_Energy)))
              neighborHoodEnergy (i) = 1;
          end
    end
end

for i = 1 : Num_Sensors
    Energy_Index_Sensor_Nodes (i, 1) = Sensor_Node_Energy (i);
    Energy_Index_Sensor_Nodes (i, 2) = i;
end

Energy_Index_Sensor_Nodes = -(sortrows(-Energy_Index_Sensor_Nodes, 1));

for i = 1 : Num_Sensors
    Node_Index = Energy_Index_Sensor_Nodes (i, 2);
    if (Sensor_Node_Energy (Node_Index) > Min_Energy)
        if (is_Member(Node_Index) == 0)
            is_CH (Node_Index) = 1;
            Y (Node_Index, Node_Index) = 1;
            for j = 1 : Neighbor_Count (Node_Index)
                Neighbor_Node_Index = Neighbor (Node_Index, j);
                if (Sensor_Node_Energy (Neighbor_Node_Index) > Min_Energy)
                    if ((is_Member (Neighbor_Node_Index) ~= 1) && (is_CH (Neighbor_Node_Index) ~= 1) && (neighborHoodEnergy (Neighbor_Node_Index) == 0))
                        Y (Neighbor_Node_Index, Node_Index) = 1;
                        is_Member (Neighbor_Node_Index) = 1;
                    end
                end
            end
        end
    else
        break;
    end
end
end