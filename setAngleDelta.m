function [] = setAngleDelta(actuatorSpeed)

global angleDelta

if (actuatorSpeed >= 95)
    angleDelta = 5;
elseif (actuatorSpeed >= 70)
    angleDelta = 4;
elseif (actuatorSpeed >= 50)
    angleDelta = 3;
else
    angleDelta = 2;
end