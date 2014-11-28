function clusterHead = findClusterHead (Number_Sensor_Nodes, Y)
clusterHead = zeros (Number_Sensor_Nodes, 1);
for i = 1 : Number_Sensor_Nodes
    for j = 1 : Number_Sensor_Nodes
        if (Y(i, j) == 1) 
            clusterHead (i) = j;
            break;
        end
    end
end
end