function numberDead = getNumberOfNodesDead (Energy_Sensor_Nodes, Min_Energy, Number_Sensor_Nodes)
numberDead = 0;
for i = 1: Number_Sensor_Nodes 
if (Energy_Sensor_Nodes(i) <= Min_Energy)
    numberDead = numberDead + 1;
end

end