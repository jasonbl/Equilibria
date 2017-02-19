function weight = getFootReading(arduino, foot)

% Send read request for specified foot to Arduino
fprintf(arduino, foot);

% Read value returned via Serial communication
weight = fscanf(arduino, '%f');

end