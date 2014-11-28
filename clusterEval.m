function [stdDevCsize, maxClusterSize, aveClusterHeadEnergy] = clusterEval (Y, Sn_Energy, Min_Energy, Sn_length)
numCluster = 0;
clusterHeadEnergy = 0;
aveClusterHeadEnergy = 0;
for i = 1: Sn_length
    if (Sn_Energy(i) > Min_Energy)
        if (Y(i,i) == 1)
            numCluster = numCluster + 1;
            clusterHeadEnergy = clusterHeadEnergy + Sn_Energy(i);
        end
    end
end

if (numCluster > 0) 
    aveClusterHeadEnergy = clusterHeadEnergy / numCluster;
end
clusterSize = zeros (numCluster, 1);
count = 0;
for i = 1: Sn_length
    if (Sn_Energy(i) > Min_Energy)
        if (Y(i,i) == 1)
            count = count + 1;
            for j = 1: Sn_length     
                if (Sn_Energy(j) > Min_Energy)                   
                    if (Y(j, i) == 1)              
                        clusterSize (count) = clusterSize (count) + 1;  
                    end
                end
            end
        end
    end
end

stdDevCsize = std (clusterSize);
maxClusterSize = max (clusterSize);
end