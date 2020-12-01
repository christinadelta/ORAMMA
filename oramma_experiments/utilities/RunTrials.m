function [set] = RunTrials(set, trials, scrn, keys)

% the script gets various stored information from other subfunctions to run
% one block (run). All the tasks will run in this function. To run the
% correct trial list we need the "task number"

% TODO:
% 1. ADD ABORT OPTION IN RTS TASK
% 2. SAVE TRIAL INFO IN RTS TASK

%% ---- Prepare the "global" information needed for all the tasks ---- %%

% get variables stored in the "settings" structure. Start with the task
% vars
taskNb          = set.taskNb;       % number of task (needed to run the correct task)
runs            = set.runs;         % total runs
run             = set.run;          % current run

allitems        = set.allitems;     % all the stimuli numbers (e.g. 36) 
data            = set.data;         % data (images) to make textures 


isi             = set.isi;          % interstimulus interval
jitter          = set.jitter; 
imgduration     = set.duration;     % stimulus duration
fixation        = set.fixation;     % draw fixation
responsetime    = set.response;     % response time

window          = scrn.window;       % main window
windrect        = scrn.windrect;
xcenter         = scrn.xcenter;
ycenter         = scrn.ycenter;
ifi             = scrn.ifi;          % frame duration
slack           = scrn.slack;        % slack is ifi/2 (important for timing)
white           = scrn.white;
grey            = scrn.grey;
fixsize         = scrn.fixationsize;
textfont        = scrn.textfont;


% get the variables stored in the "screen" structure
imagewidth      = scrn.objectx;
imageheight     = scrn.objecty;

% get "trials" variables
nbtrials        = trials.runtrials; % number of trials per run
triallist       = trials.list;      % trials matrix of the entire experiment 

currentlist     = triallist{run};   % trials matrix of the current run

% make textures of the images
texture         = cell(1,allitems);

for i = 1:allitems

    texture{i} = Screen('MakeTexture', window, data(i).file); 

end

% global keys
esckey          = keys.esckey;      % esc key is used in all tasks


% Compute destination rectangle location
destrect        = [xcenter-imagewidth/2, ycenter-imageheight/2, xcenter+imagewidth/2, ycenter+imageheight/2];

%  create fixation cross offscreen and paste later (faster)
fixationdisplay = Screen('OpenOffscreenWindow',window);
Screen('FillRect', fixationdisplay, grey);
Screen('TextFont',fixationdisplay, textfont);
Screen('TextSize',fixationdisplay, fixsize);
DrawFormattedText(fixationdisplay, fixation, xcenter, ycenter, white);

%% ----- Run the correct task ------ %%

if taskNb == 1 % if the task is RTS 
    
    % store the different image information of the current run in separate arrays
    runitems        = currentlist(:,1);
    animacy         = currentlist(:,2);
    category        = currentlist(:,3);
    
    % get the 'rts' related keys 
    animatekey      = keys.animatekey;
    inanimatekey    = keys.inanimatekey;
    
    % start the run with the fixation cross
    Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
    runstart = Screen('Flip', window); % flip fixation window
    
    objecton = runstart + isi + randperm(jitter*1000,1)/1000 - ifi;
    
    % loop through the current trial list
    for trial = 1:nbtrials
        
        % get the stimulus and the rest of info of the current trial
        thisitem        = runitems(trial,1);
        thisanimacy     = animacy(trial,1);
        thiscategory    = category(trial,1);        
        
        Screen('DrawTexture', window, texture{thisitem}, [], destrect);     % display thisitem
        imageon = Screen('Flip', window, objecton - slack);                 % here the current image (thisitem) is fliped
        
        trialstart  = imageon - runstart; 
        imageoff    = imageon + imgduration - ifi;                          % image on for 200 ms
        
        % show fixation and collect response 
        Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
        fixon = Screen('Flip', window, imageoff - slack);                   % fixation on until response is made or for 1.5 sec
        
        % Get keypress response
        rt      = 0;
        answer  = 0;
        correct = 0;
        input   = 0;
         
        while input == 0 && (GetSecs - fixon) < responsetime 
            [keyisdown, secs, keycode] = KbCheck;
            pressedKeys = find(keycode);
            
            % check the response key
            if isempty(pressedKeys) % if subject didn't press any key
                input       = 0; 
                rt          = nan;
                answer      = nan;
                respmade    = GetSecs;
                
            elseif ~isempty(pressedKeys) % if subjects pressed a valid key
                
                if keycode(1,animatekey) % subject pressed the animate key
                    input       = animatekey;
                    rt          = secs - fixon;
                    answer      = 1; % animate
                    respmade    = secs;
                    
                elseif keycode(1,inanimatekey) % subject pressed the inanimate key
                    input       = inanimatekey;
                    rt          = secs - fixon;
                    answer      = 2; % inanimate
                    respmade    = secs;
                    
                elseif keycode(1,esckey)
                    input       = esckey;
                    rt          = nan;
                    answer      = nan;
                    respmade    = nan;
                    abort       = 1;
                    break
                end % end of key press if statement
           
            end % end of response if statement
        
        end % end of response while loop
        
        correct = answer == thisanimacy; % check if response is correct
        
        objecton = respmade + responsetime - ifi;
        
        % save trial info
    
    end % end of RTS trials loop
    
    
    
 
end % end of task number statement 

WaitSecs(2);




end