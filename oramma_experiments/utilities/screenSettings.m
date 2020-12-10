function [scrn] = screenSettings(scrn, set)

% screen settings of the ORAMMA tasks
% 1. defines screen settings
% 2. defines object x and y 

%% define screen parameters 

% change these parameters as appropreate 
% screen resolution 
scrn.actscreenRes   = scrn.actscreen; % get screen's actual resolution
scrn.screenRes      = [1280 800]; % this also the windrect in px
scrn.hz             = 60; 
scrn.distview       = 600;
scrn.width          = scrn.actwidth;
scrn.height         = scrn.actheight;

%% define object x and y 

% don't change anything here
angleradn       = 2 * atan(scrn.width / 2 /scrn.distview);
angledeg        = angleradn * (180/pi);
pix             = scrn.screenRes(1) / angledeg;
scrn.objectx    = round(set.stimdeg * pix);
scrn.objecty    = round(set.stimdeg * pix);

end