function [Neighbors, Neighbor_Count] = getNeighbors (Num_Sensors, Sensor_Nodes, Distance, Sensor_Node_Energy, Min_Energy, Cluster_Radius)

Neighbor_Count = zeros (Num_Sensors, 1);
Neighbors = zeros (Num_Sensors, Num_Sensors);

for i=1 : Num_Sensors            
    for j=1 : Num_Sensors            
        if (Sensor_Node_Energy (j) > Min_Energy)
        Distance(i,j) = getDistance(Sensor_Nodes(i,1), Sensor_Nodes(i,2), Sensor_Nodes(j,1), Sensor_Nodes(j,2));
        if (Distance (i, j) <= Cluster_Radius)
            Neighbor_Count (i) = Neighbor_Count (i) + 1;
            Neighbors (i, Neighbor_Count (i)) = j;
        end
        end
    end
end
end