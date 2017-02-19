function [copX, copY] = getCOP(arduino)

global boardWidth boardHeight
readFrontLeft = 'A';
readFrontRight = 'B';
readBackLeft = 'C';
readBackRight = 'D';

% Get reading from front left foot
frontLeft = getFootReading(arduino, readFrontLeft);
    s = sprintf('Reading: %.1f lbs', frontLeft);
    disp(s);

% Get reading from front right foot
frontRight = getFootReading(arduino, readFrontRight);

% Get reading from back left foot
backLeft = getFootReading(arduino, readBackLeft);

% Get reading from back right foot
backRight = getFootReading(arduino, readBackRight);

totalWeight = frontLeft + frontRight + backLeft + backRight;

copX = boardWidth / 2 * ((frontRight + backRight) - (frontLeft + backLeft)) / totalWeight;
copY = boardHeight / 2 * ((frontLeft + frontRight) - (backLeft + backRight)) / totalWeight;

end