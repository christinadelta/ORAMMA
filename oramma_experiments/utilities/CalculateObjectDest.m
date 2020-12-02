function [x, y, r] = CalculateObjectDest(imw, windrect)

% subfunction that helps calculate the position of objects on the screen
% part of the ORAMMA experiments
% runs through the RunTrials subfunction 

m   = imw*.05;
aw  = min(windrect(3:4));
% ls  = linspace(0,.3,3); % may not need it
r   = aw/2-m-imw/2; % calculate radius 
x   = (sqrt(3)*r)/2;
y   = r/2;

end