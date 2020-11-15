% ORAMMA EXPERIMENTS: REACTION TIMES TASK (version 1)

% ChristinaDelta (christina.delta.k@gmail.com)

% This script runs the reaction times task
% The script is called from the startup file in the root directory

% DEPENDENCIES:
% MATLAB VERSION 2020a
% Psychophysics toolbox 3

%% ------ experiment setup ----------- %%

% Clear the workspace and screen
sca;
close all;
clearvars;
clc;

% create a user input dialog to gather information
prompt      = {'Enter task name (e.g. rts):','Enter subject number (e.g. 01:'};
dlgtitle    = 'Info window';
dims        = [1 30];
definput    = {'rts','01'}; % this is a default input (this should change)
answer      = inputdlg(prompt,dlgtitle,dims,definput);
set.init    = answer;

% Initialize the random number generator
rand('state', sum(100*clock)); 

% experimental settings
basedir         = pwd;
set.PNb         = str2num(answer{2}); % participant number
set.name        = 'rts'; % task name
set.nb          = 1; % task number
set.runs        = 1; % number of blocks (or runs)
set.break       = 5; % default break between runs
set.EEG         = 0; % set to 1 when in testing room
set.MEG         = 0; % set to 1 when in testing room

% stimuli settings
set.stimdeg     = 8;    % stimulus visual angle
set.stimsize    = 220;  % should resize to 220x200 or leave it as 252x252?

% task settings
set.fixation        = '+';
set.duration        = .200; % 200 ms
set.ISI             = 2;    % in seconds
set.jitter          = 0.2;  % 500 ms

% define keys and update setup struct
KbName('UnifyKeyNames');

responsekeys        = {'q','p'}; % q = animate, p = inanimate
KbChecklist         = [KbName('space'),KbName('ESCAPE')];

for i = 1:length(responsekeys)
    KbChecklist     = [KbName(responsekeys{i}),KbChecklist];
end

RestrictKeysForKbCheck(KbChecklist);
set.animatekey      = KbChecklist(1); % 'q'
set.inanimatekey    = KbChecklist(2); % 'p'
set.spacekey        = KbChecklist(3); % 'space'
set.esckey          = KbChecklist(4); % 'escape'


% get directories 
workingdir          = fullfile(basedir, 'oramma_experiments');

% setup study output file
resultsfolder       = fullfile(workingdir, 'results');
outputfile          = fopen([resultsfolder '/resultfile_' num2str(set.PNb) '.txt'],'a');
fprintf(outputfile, 'subID\t imageSet\t trial\t textItem\t imageOrder\t response\t RT\n');

addpath(genpath(fullfile(workingdir,'utilities'))); % add subfunctions to the path

% update the setting structure
set.workingdir      = workingdir;

%% --------------- RUN SOME IMPORTANT UTIL FUNCTIONS ----------------- %%

scrn                = screenSettings(set);  % Define screen setup

set                 = loadimages(set);      % Load the images and the corresponding files 


%% ------------ START EXPERIMENT(open screen, etc..) ----------------- %%

try
  
    % start up screen
    [window, windrect] = Screen('OpenWindow',max(Screen('Screens')), [1 1 1],[0 0 scrn.screenRes]);
    AssertOpenGL;                                                           % check for opengl compatability
    Screen('Preference', 'Enable3DGraphics', 1);                            % enable 3d graphics
    Screen('BlendFunction', window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   % enables alpha blending
    priorityLevel = MaxPriority(window);                                    % set priority 
    Priority(priorityLevel);
    HideCursor;
    
    [xcenter, ycenter]      = RectCenter(windrect);
    
    % pc actual screen settings
    set.actscreen           = Screen('Resolution', max(Screen('Screens')));
    [actwidth, actheight]   = Screen('DisplaySize', max(Screen('Screens')));
    set.slack               = Screen('GetFlipInterval', window)/2; 
    
    set.actwidth            = actwidth;
    set.actheight           = actheight;
    set.window              = window;
    set.xcenter             = xcenter;
    set.ycenter             = ycenter;
    
    %% ------------- INSTRUCTIONS ------------------ %%
    
    % text settings
    set.textfont = 'Verdana';
    set.textsize = 20;
    set.textbold = 1;
    
    set.black    = [0 0 0];
    set.white    = [255 255 255];
    set.grey     = [128 128 128];
    
    Screen('FillRect', window, set.grey);
    Screen('TextSize', window, set.textsize);
    Screen('TextFont', window, set.textfont);
    Screen('TextStyle', window, set.textbold);
    
    % Start instructions
    Screen('DrawText', window,'Press the space bar to begin', 'center', 'center', set.white);
    Screen('Flip', windoww)
    
    % WAIT FOR THEM TO PRESS respKey
    waiting = 1;
    while(waiting)
        [~, secs, keyCode]= KbCheck;
        
        % spacebar is pressed 
        if keyCode(1, set.spacekey)
            waiting = 0;
        end
    end
    
    

   
    
    
    
    
    
    
    
catch % catch last errors
    
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    psychrethrow(psychlasterror);

end % end of try... catch


