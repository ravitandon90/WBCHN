function [num_Clusters, frac] = calculateNumberOfClusterHeads (Number_Sensor_Nodes, Energy_Sensor_Nodes, Min_Energy, Y, Number_Low_Energy)
num_HighEnergy=0;
num_Clusters = 0;
for i = 1 : Number_Sensor_Nodes
%    if (Energy_Sensor_Nodes(i) > Min_Energy)
        if (Y(i, i) == 1)
            num_Clusters = num_Clusters + 1;
            if (i > Number_Low_Energy)
                num_HighEnergy = num_HighEnergy +1;
            end
        end
 %   end
end
if (num_Clusters > 0)
    frac = num_HighEnergy / num_Clusters;
else
    frac= 0;
end
end