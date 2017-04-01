function [copX, copY] = getCOP()

global boardWidth boardHeight READ_COP readArduino

% Send read request for COP to arduino
fprintf(readArduino, READ_COP);

% Readings sent back to MATLAB in following order: FL, FR, BL, BR

% Get reading from front left foot
frontLeft = fscanf(readArduino, '%f');
% s = sprintf('Reading: %.1f lbs', frontLeft);
% disp(s);

% Get reading from front right foot
frontRight = fscanf(readArduino, '%f');
% s = sprintf('Reading: %.1f lbs', frontRight);
% disp(s);

% Get reading from back left foot
backLeft = fscanf(readArduino, '%f');
% s = sprintf('Reading: %.1f lbs', backLeft);
% disp(s);

% Get reading from back right foot
backRight = fscanf(readArduino, '%f');
% s = sprintf('Reading: %.1f lbs', backRight);
% disp(s);

totalWeight = frontLeft + frontRight + backLeft + backRight;
% s = sprintf('Reading: %.1f lbs', totalWeight);
% disp(s);

if (totalWeight <= .5)
    copX = 0;
    copY = 0;
else
    copX = boardWidth / 2 * ((frontRight + backRight) - (frontLeft + backLeft)) / totalWeight;
    copY = boardHeight / 2 * ((frontLeft + frontRight) - (backLeft + backRight)) / totalWeight; 
end

end