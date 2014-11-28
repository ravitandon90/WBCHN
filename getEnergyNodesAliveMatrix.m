function Energy_Nodes_Alive = getEnergyNodesAliveMatrix (nodesAlive, Sensor_Nodes_Energy, Number_Sensor_Nodes, Min_Energy)
Energy_Nodes_Alive = zeros (nodesAlive, 1);
count = 0;
for i = 1 : Number_Sensor_Nodes
if (Sensor_Nodes_Energy (i) > Min_Energy)
    count = count + 1;
    Energy_Nodes_Alive (count) = Sensor_Nodes_Energy (i);
end
end
end