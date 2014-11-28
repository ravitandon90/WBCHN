% The cluster size includes the cluster head also
function clusterSize = calculateClusterSize (Number_Sensor_Nodes, Y)
clusterSize = zeros (Number_Sensor_Nodes, 1);
for i = 1 : Number_Sensor_Nodes
    if (Y(i, i) == 1)
        for j = 1 : Number_Sensor_Nodes
            if (Y(i, j) == 1)
                clusterSize (i) = clusterSize (i) + 1;
            end
        end
    end
end
end