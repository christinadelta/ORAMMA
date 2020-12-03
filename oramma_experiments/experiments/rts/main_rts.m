% ORAMMA EXPERIMENTS: REACTION TIMES TASK Simple version (version 1)

% For helpful info regarding the psychtoolbox see:
% http://peterscarfe.com/ptbtutorials.html


% ChristinaDelta (christina.delta.k@gmail.com)

% This script runs the reaction times task
% The script is called from the startup file in the root directory

% DEPENDENCIES:
% MATLAB VERSION 2020a
% Psychophysics toolbox 3

%% ------ initial experimental setup ----------- %%

% Initialize the random number generator
rand('state', sum(100*clock)); 

% get participant nb and task name 
answer          = startup.answer;

% initial experimental settings
PNb             = str2num(answer{2}); % participant number
taskName        = answer{1}; 
taskNb          = 1; % task number
basedir         = pwd;

% get directories and add utility functions to the path
workingdir      = fullfile(basedir, 'oramma_experiments');
addpath(genpath(fullfile(workingdir,'utilities')));                         % add subfunctions to the path


%% --------- Set output info and logs file ------------ %%

logs.PNb            = PNb;
logs.task           = taskName;
logs.date           = datestr(now, 'ddmmyy');
logs.time           = datestr(now, 'hhmm');

logs.output         = 'subject_%02d_task_%s_run_%02d_logs.mat';

% % setup study output file
logs.resultsfolder  = fullfile(workingdir, 'results',taskName, sprintf('sub-%02d', PNb));

if ~exist(logs.resultsfolder, 'dir')
    mkdir(logs.resultsfolder)
end


%% --------------- RUN A FEW IMPORTANT UTIL FUNCTIONS ----------------- %%

set                 = TaskSettings(taskNb);                                 % Define the first task specific parameters

keys                = DefineKeys(taskNb);                                   % Define keys of the task

scrn                = screenSettings(set);                                  % Define screen setup

set                 = loadimages(set, workingdir);                          % Load the images and the corresponding files 

trials              = CreateTrialList(set);                                 % create trials, split in runs, etc..

try
    %% ------------ START EXPERIMENT(open screen, etc..) ----------------- %%
  
    % start up screen
    % Screen('Preference', 'SkipSyncTests', 0) % set a Psychtoolbox global preference.
    Screen('Preference', 'SkipSyncTests', 1) % for testing I have set this to 1. When running the actuall task uncomment the above

    screenNumber        = max(Screen('Screens'));
    
    [window, windrect]  = Screen('OpenWindow',screenNumber, scrn.grey);      % open window
    
    AssertOpenGL;                                                           % Break and issue an error message if PTB is not based on OpenGL or Screen() is not working properly.
    Screen('Preference', 'Enable3DGraphics', 1);                            % enable 3d graphics
    Screen('BlendFunction', window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   % Turn on blendfunction for for the screen
    priorityLevel = MaxPriority(window);                                    % query the maximum priority level
    Priority(priorityLevel);
    HideCursor;
    
    [xcenter, ycenter]      = RectCenter(windrect);                         % get the centre coordinate of the window in pixels
    [xpixels, ypixels]      = Screen('WindowSize', window);                 % size of the on-screen window in pixels

    
    % pc actual screen settings
    scrn.actscreen          = Screen('Resolution', screenNumber);
    [actwidth, actheight]   = Screen('DisplaySize', screenNumber);
    scrn.acthz              = Screen('FrameRate', window, screenNumber);
    
    scrn.ifi                = Screen('GetFlipInterval', window);            % frame duration
    
    scrn.slack              = Screen('GetFlipInterval', window)/2;          % Returns an estimate of the monitor flip interval for the specified onscreen window
    
    scrn.frame_rate         = 1/scrn.ifi;
    scrn.actwidth           = actwidth;
    scrn.actheight          = actheight;
    scrn.window             = window;
    scrn.windrect           = windrect;
    scrn.xcenter            = xcenter;
    scrn.ycenter            = ycenter;
    scrn.xpixels            = xpixels;
    scrn.ypixels            = ypixels;
    
    
    %% ------------- INSTRUCTIONS ------------------ %%
    
    % Start instructions
    DrawFormattedText(window,'Pay attentions to the instructions','center','center',scrn.white);
    expstart = Screen('Flip', window);
    duration = expstart + 2;
    
    % display instructions 
    instructions = Screen('OpenOffscreenWindow', window, windrect);
    Screen('TextSize', instructions, scrn.textsize);
    Screen('FillRect', instructions, scrn.grey ,windrect);
    DrawFormattedText(instructions, 'Please maintain your attention at the center of the screen. In every trial,', 'center', scrn.ycenter-100, scrn.white);
    DrawFormattedText(instructions, 'you will be presented with an image (stimulus) at the center of the screen. When the stimulus is gone,', 'center', scrn.ycenter-50, scrn.white);
    DrawFormattedText(instructions, 'press Q if the stimulus was animate, press P if it was inanimate. ', 'center', 'center', scrn.white);
    DrawFormattedText(instructions, 'Press space to continue.','center', scrn.ycenter+50, scrn.white);
    
    % copy the instructions window  and flip.
    Screen('CopyWindow',instructions,window,windrect, windrect);
    Screen('Flip', window, duration);
    
    % WAIT FOR THEM TO PRESS SPACE
    waitforresp = 1;
    while waitforresp
        [~, secs, keycode]= KbCheck;
        WaitSecs(0.001) % delay to prevent CPU logging

        % spacebar is pressed 
        if keycode(1, keys.spacekey)
        waitforresp = 0;
        end
    end

    
    %% --------------- START THE RUN LOOP --------------- %%
    
    abort = 0; % when 1 subject can quit the experiment
    
    for run = 1: set.runs
        
        if run == 1
            
            Screen('OpenOffscreenWindow', window, windrect);
            Screen('TextSize', window, scrn.textsize);
            Screen('FillRect', window, scrn.grey ,windrect);
            DrawFormattedText(window, sprintf('Great! Starting run %d',run), 'center', 'center', scrn.white);
            Screen('Flip', window); 
            WaitSecs(3); % wait for three secs before starting the 1st run
            
            [set, logs]     = RunTrials(set, trials, scrn, run, logs); 
            
        elseif run > 1
            
            Screen('OpenOffscreenWindow', window, windrect);
            Screen('TextSize', window, scrn.textsize);
            Screen('FillRect', window, scrn.grey ,windrect);
            DrawFormattedText(window, 'Time for a break! When ready to continue, press SPACE', 'center', scrn.ycenter-50, scrn.white);
            DrawFormattedText(window, 'If you want to quit, press ESC.', 'center', 'center', scrn.white);
            Screen('Flip', window); 
            
            waitforresp = 1;
            while waitforresp
                
                keyisdown = 0;
                    while ~keyisdown
                        [keyisdown,secs,keycode] = KbCheck;
                        WaitSecs(0.001) % delay to prevent CPU logging
                    end
                if keycode(keys.esckey)
                    abort = 1;
                    waitforresp = 0;
                    break 
                    
                elseif keycode(keys.spacekey)
                    
                    Screen('OpenOffscreenWindow', window, windrect);
                    Screen('TextSize', window, scrn.textsize);
                    Screen('FillRect', window, scrn.grey ,windrect);
                    DrawFormattedText(window, sprintf('Great! Starting run %d',run), 'center', 'center', scrn.white);
                    Screen('Flip', window); 
                    WaitSecs(3)
                    
                    waitforresp = 0;
                    
                    % start next run
                    [set,logs]     = RunTrials(set, trials, scrn, run, logs); 
                end % 
                
            end % end of waiting while loop
                
       
        end % end of run if statement
   
    end % end of run for loop
    
    % show thank you window
    Screen('OpenOffscreenWindow', window, windrect);
    Screen('TextSize', window, scrn.textsize);
    Screen('FillRect', window, scrn.grey ,windrect);
    DrawFormattedText(window, 'This is the end of the experiment. Thank you for your time', 'center', 'center', scrn.white);
    Screen('Flip',window);
    WaitSecs(3);
    
    % clean up at the end of the experiment
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    fclose('all');
    
catch % catch last errors
    
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    psychrethrow(psychlasterror);

end % end of try... catch

