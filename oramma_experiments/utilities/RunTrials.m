function [set, logs] = RunTrials(set, trials, scrn, run, logs)

% the script gets various stored information from other subfunctions to run
% one block (run). All the tasks will run in this function. To run the
% correct trial list we need the "task number"

% TODO:
% 1. ADD ABORT OPTION IN RTS & AB TASK
% 2. SAVE TRIAL INFO IN RTS TASK
% 3. RESPONSES, ANSWERS ETC IN AB TASK ARE NOT RECORDED (CHECK & FIX ASAP)
% 4. ADD QUESTION ABOUT 1ST AND 2D TARGET IN RESPONSE WINDOWS

%% ---- Prepare the "global" information needed for all the tasks ---- %%

% get variables stored in the "settings" structure. Start with the task
% vars
taskNb          = set.taskNb;       % number of task (needed to run the correct task)
runs            = set.runs;         % total runs

isi             = set.isi;          % interstimulus interval
jitter          = set.jitter; 
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
textsize        = scrn.textsize;


% get the variables stored in the "screen" structure
imagewidth      = scrn.objectx;
imageheight     = scrn.objecty;

% get "trials" variables
nbtrials        = trials.runtrials; % number of trials per run
triallist       = trials.list;      % trials matrix of the entire experiment 

currentlist     = triallist{run};   % trials matrix of the current run


keys            = DefineKeys(taskNb); % run the keys function

% Compute destination rectangle location
destrect        = [xcenter-imagewidth/2, ycenter-imageheight/2, xcenter+imagewidth/2, ycenter+imageheight/2];

% create fixation cross offscreen and paste later (faster)
fixationdisplay = Screen('OpenOffscreenWindow',window);
Screen('FillRect', fixationdisplay, grey);
Screen('TextFont',fixationdisplay, textfont);
Screen('TextSize',fixationdisplay, fixsize);
DrawFormattedText(fixationdisplay, fixation, xcenter, ycenter, white);

%% ----- Run the correct task ------ %%

if taskNb == 1 % if the task is RTS 
    
    
    % get task specific settings 
    allitems        = set.allitems;     % all the stimuli numbers (e.g. 36) 
    data            = set.data;         % data (images) to make textures 
    imgduration     = set.duration;     % stimulus duration
    
    % make textures of the images
    texture         = cell(1,allitems);

    for i = 1:allitems

        texture{i} = Screen('MakeTexture', window, data(i).file); 

    end
    
    set.texture = texture;

    
    % store the different image information of the current run in separate arrays
    runitems        = currentlist(:,1);
    animacy         = currentlist(:,2);
    category        = currentlist(:,3);
    
    %% start the current run
    
    % create a structure to store the trial info     
    runtrials   = [];
    
    % start the run with the fixation cross
    Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
    fliptime    = Screen('Flip', window); % flip fixation window
    runstart    = fliptime;
    
    objectoff = runstart + isi + randperm(jitter*1000,1)/1000 - ifi;
    
    % loop through the current trial list
    for itrial = 1:nbtrials
        
        % get the stimulus and the rest of info of the current trial
        thisitem        = runitems(itrial,1);
        ianimacy        = animacy(itrial,1);
        icategory       = category(itrial,1);     
        
        Screen('DrawTexture', window, texture{thisitem}, [], destrect);     % display thisitem
        fliptime    = Screen('Flip', window, objectoff - slack);            % here the current image (thisitem) is fliped
        objectstart = fliptime;
        
        trialstart  = fliptime - runstart;                                  % timestamp of the begining of the trial
        objectoff   = fliptime + imgduration - ifi;                         % image on for 200 ms
        
        % show fixation and collect response 
        Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
        fliptime = Screen('Flip', window, objectoff - slack);               % fixation on until response is made or for 1.5 sec
        
        fprintf('image was on for %3.4f\n', fliptime - objectstart);        % from the first flip until the next
        
        % Collect keypress response
        resp_input   = 0;
        
        while resp_input == 0 && (GetSecs - fliptime) < responsetime 
            [keyisdown, secs, keycode] = KbCheck;
            pressedKeys = find(keycode);
            
            % check the response key
            if isempty(pressedKeys) % if subject didn't press any key
                resp_input  = 0; 
                rt          = nan;
                answer      = nan;
                respmade    = GetSecs;
                
            elseif ~isempty(pressedKeys) % if subjects pressed a valid key
                
                if keycode(1,keys.animatekey) % subject pressed the animate key
                    resp_input  = keys.animatekey;
                    rt          = secs - fliptime;
                    answer      = 1; % animate
                    respmade    = secs;
                    
                elseif keycode(1,keys.inanimatekey) % subject pressed the inanimate key
                    resp_input  = keys.inanimatekey;
                    rt          = secs - fliptime;
                    answer      = 2; % inanimate
                    respmade    = secs;
                    
                elseif keycode(1,keys.esckey)
                    resp_input  = keys.esckey;
                    rt          = nan;
                    answer      = nan;
                    respmade    = nan;
                    abort       = 1;
                    break
                end % end of key press if statement
           
            end % end of response if statement
        
        end % end of response while loop
        
        correct = answer == ianimacy; % check if response is correct
        
        objectoff = respmade + .200 + randperm(jitter*1000,1)/1000 - ifi;
        
        % save trial info
        runtrials(itrial).trialNb       = itrial;
        runtrials(itrial).item          = thisitem;
        runtrials(itrial).trialstart    = trialstart;
        runtrials(itrial).animacy       = ianimacy;
        runtrials(itrial).category      = icategory;
        runtrials(itrial).rt            = rt;
        runtrials(itrial).answer        = answer;
        runtrials(itrial).correct       = correct;
        runtrials(itrial).run           = run;
    
    end % end of RTS trials loop
    
elseif taskNb == 2 % if it is ab
    
    %  GET TASK SPECIFIC PARAMETERS AND SETTINGS
    
    iti                 = set.iti;      % RSVP duration + responses
    rsvp                = set.rsvp;     % length of the rsvp stream (15)
    post1               = set.post1;    % position of first target in the RSVP
    post2               = set.post2;    % poisitions of the second target
    delay               = set.delay;    % delay between the end of the RSVP and beginning of response window
    respdelay           = set.respdelay;% delay between response windows
    
    % get the stimuli
    distractoritems     = set.Litems; % (1:26) or (A:Z)
    targetitems         = set.Ditems; % (1:10)
    distractortype      = set.Lindex; % 2 for letters/distrctors
    targettype          = set.Dindex; % 1 for digits/targets
    
    % get the target and distractor data
    alldistractors      = set.alldistractors;
    distractordata      = set.distrctordata;
    
    alltargets          = set.alltargets;
    targetdata          = set.targetdata;
    
    % target info from the created triallist
    allt1s              = currentlist(:,1);
    allt2s              = currentlist(:,2);
    alllags             = currentlist(:,3);
    
    %% define the x & y positions of the 3 response options on screen and screate Offscreen windows for flipping
    [x, y, r]   = CalculateObjectDest(imagewidth, windrect);  
    
    % create the 3 destination rectangles 
    leftRect    = [xcenter-x-imagewidth/2 ycenter+y-imageheight/2 xcenter-x+imagewidth/2 ycenter+y+imageheight/2]; % the 4 points on the screen of the left item
    rightRect   = [xcenter+x-imagewidth/2 ycenter+y-imageheight/2 xcenter+x+imagewidth/2 ycenter+y+imageheight/2]; % the 4 points on the screen of the right item
    middleRect  = [xcenter-imagewidth/2 ycenter-r xcenter+imagewidth ycenter-r+imageheight];                       % the 4 points on the screen of the middle item
    allrects    = [leftRect; middleRect; rightRect]';
    
    % CREATE RESPONSE WINDOWS AND PASTE LATER
    t1_responsewindow = Screen('OpenOffscreenWindow',window);
    Screen('FillRect',t1_responsewindow, grey);
    Screen('TextFont',t1_responsewindow, textfont);
    Screen('TextSize',t1_responsewindow, textsize);
    DrawFormattedText(t1_responsewindow, 'Which of these three items appeared as the first target?', 'center', 'center', white);
    
    t2_responsewindow = Screen('OpenOffscreenWindow',window);
    Screen('FillRect',t2_responsewindow, grey);
    Screen('TextFont',t2_responsewindow, textfont);
    Screen('TextSize',t2_responsewindow, textsize);
    DrawFormattedText(t2_responsewindow, 'Which of these three items appeared as the second target?', 'center', 'center', white);
    
    % BLANK SCREEN (GREY WITHOUT FIXATION)
    blankscreen = Screen('OpenOffscreenWindow',window);
    Screen('FillRect', blankscreen, grey);
    
    %%  make textures of the targets and distractors and unpack keys
    targettexture       = cell(1,alltargets);
    dstrcttexture       = cell(1,alldistractors);

    for i = 1:alltargets

        targettexture{i} = Screen('MakeTexture', window, targetdata(i).file); 

    end

    for i = 1:alldistractors

        dstrcttexture{i} = Screen('MakeTexture', window, distractordata(i).file); 

    end
    
   
    %% start the current run 
    
    % create a structure to store the trial info     
    runtrials       = [];
    
    % start the run with the fixation cross
    Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
    fliptime        = Screen('Flip', window); % flip fixation window
    runstart        = fliptime;
    
    objectoff       = fliptime + iti + randperm(jitter*1000,1)/1000 - ifi;
    
    for itrial = 1:nbtrials
        
        % define trial specific variables
        iT1         = allt1s(itrial);
        iT2         = allt2s(itrial);
        ilag        = alllags(itrial);
        
        % randomly choose (without replacement) 15 distractors (letters) from the pool of
        % distractors:
        thisRSVP    = distractoritems(randperm(alldistractors, rsvp));
        
        % get the correct t2 position based of this trial's lag
        if ilag == 1
            
            thist2_pos = post2(1);
            
        else
            
            thist2_pos = post2(2);
            
        end
        
        % add t1 and t2 of itrial in their correspondong positions in the
        % RSVP
        thisRSVP(post1)         = iT1;
        thisRSVP(thist2_pos)    = iT2;
        
        % loop throu the RSVP stream and display stimuli
        for thisitem = 1:rsvp
            
            % check if it is target or distractor
            if thisitem == post1 
                
                Screen('DrawTexture', window, targettexture{thisRSVP(thisitem)}, [], destrect)
                fliptime    = Screen('Flip', window, objectoff - slack); % flip the t1 window
                objectoff   = fliptime + ifi; % t1 on for 1 frame 
                
                t1Start     = fliptime - runstart;
                
                % switch to blank
                Screen('CopyWindow',blankscreen,window,windrect,windrect);
                fliptime    = Screen('Flip', window, objectoff - slack);
                objectoff   = fliptime + (5*ifi); % blank screen for 5 frames
                
                t1End       = fliptime;
                
                % display on command window the ammount of time t1 was on
                fprintf('t1 on for %3.4f\n', t1End - t1Start);
                
            elseif thisitem == thist2_pos
                
                Screen('DrawTexture', window, targettexture{thisRSVP(thisitem)}, [], destrect)
                fliptime = Screen('Flip', window, objectoff - slack); % flip the t2 window
                objectoff   = fliptime + ifi; % t2 on for 1 frame 
                
                t2Start     = fliptime - runstart;
                
                % switch to blank
                Screen('CopyWindow',blankscreen,window,windrect,windrect);
                fliptime    = Screen('Flip', window, objectoff - slack);
                objectoff   = fliptime + (5*ifi); % blank screen for 5 frames
                
                t2End       = fliptime;
                
                % display on command window the ammount of time t2 was on
                fprintf('t2 on for %3.4f\n', t2End - t2Start);
                
            else % if thisitem is a distractor
                
                Screen('DrawTexture', window, dstrcttexture{thisRSVP(thisitem)}, [], destrect)
                fliptime        = Screen('Flip', window, objectoff - slack); % flip the t2 window
                objectoff       = fliptime + ifi; % distractor (letter) on for 1 frame 
                
                distractorStart = fliptime;
                trialstart      = distractorStart - iti - runstart; % onset of the RSVP
                
                % switch to blank
                Screen('CopyWindow',blankscreen,window,windrect,windrect);
                fliptime        = Screen('Flip', window, objectoff - slack);
                objectoff       = fliptime + (5*ifi); % blank screen for 5 frames
                
                distractorEnd   = fliptime;
                % display on command window the ammount of time t2 was on
                fprintf('distractor on for %3.4f\n', distractorEnd - distractorStart);
                
 
            end % end of if statement 

        end % end of RSVP for loop
        
        % gap between t1 and t2?
        fprintf('gap between t1 and t2: %3.4f\n',t2Start-t1Start);
        
        % add the long delay between the end of the RSVP stream and the
        % response windows
        Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
        fliptime    = Screen('Flip', window, objectoff - slack); 
        objectoff   = fliptime + delay + ifi;
        
        %%%% -----------------
        % Response windows and options
        % first randomly sample 2 items from the pool of targets to use in
        % the response screen (for both t1 and t2)
        t1options = randsample(targetitems, 2);
        
        % make sure that none of the selected items is not t1
        while t1options(1)==iT1 | t1options(2) == iT1
            
            t1options   = randsample(targetitems, 2);
            
        end
        
        t1options(3)    = iT1;
        t1options       = t1options(randperm(length(t1options)));
        
        % display t1 resposne window
        Screen('DrawTextures',window, [targettexture{t1options}],[],allrects);
        %Screen('CopyWindow',t1_responsewindow, window, windrect, windrect);
        fliptime = Screen('Flip',window, objectoff); % 
        
        
        resp_input = 0;
        % collect response 
        while resp_input == 0 && (GetSecs - fliptime) < responsetime 
            [keyisdown, secs, keycode] = KbCheck;
            pressedKeys = find(keycode);
            
            % check the response key
            if isempty(pressedKeys) % if subject didn't press any key
                resp_input      = 0; 
                rt              = nan;
                answer          = nan;
                respmade        = GetSecs;
                
            elseif ~isempty(pressedKeys) % if subjects pressed a valid key
                
                if keycode(1,keys.option1) % subject pressed key 1
                    resp_input  = keys.option1;
                    rt          = secs - fliptime;
                    answer      = t1options(1); % left option
                    respmade    = secs;
                    
                elseif keycode(1,keys.option2) % subject pressed key 2
                    resp_input  = keys.option2;
                    rt          = secs - fliptime;
                    answer      = t1options(2); % middle option
                    respmade    = secs;
                    
                elseif keycode(1,keys.option3) % subject pressed key 3
                    resp_input  = keys.option3;
                    rt          = secs - fliptime;
                    answer      = t1options(3); % right option
                    respmade    = secs;
                    
                elseif keycode(1,keys.esckey)
                    resp_input  = keys.esckey;
                    rt          = nan;
                    answer      = nan;
                    respmade    = nan;
                    abort       = 1;
                    break
                end % end of key press if statement
           
            end % end of response if statement
        
        end % end of response while loop
        
        
        t1rt        = rt;
        t1answer    = answer;
        t1correct   = t1answer == iT1;
        
        clear resp_input rt answer 
        
        objectoff = respmade + (isi*2) - ifi; % give one second to respond
        
        % add the short delay between the end of the t1 response window
        % and t2 response window
        Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
        fliptime    = Screen('Flip', window, objectoff - slack); 
        objectoff   = fliptime + respdelay + ifi; % give subject 300 ms  before moving to T2
        
        t2options = randsample(targetitems, 2);
        
        % make sure that none of the selected items is not t1
        while t2options(1)==iT2 | t2options(2) == iT2
            
            t2options   = randsample(targetitems, 2);
            
        end
        
        t2options(3)    = iT2;
        t2options       = t2options(randperm(length(t2options)));
        
        % display t2 resposne window
        Screen('DrawTextures',window, [targettexture{t2options}],[],allrects);
        Screen('CopyWindow',window, window, windrect, windrect);
        fliptime = Screen('Flip',window, objectoff); % 
        
        resp_input = 0;
        % collect response 
        while resp_input == 0 && (GetSecs - fliptime) < responsetime 
            [keyisdown, secs, keycode] = KbCheck;
            pressedKeys = find(keycode);
            
            % check the response key
            if isempty(pressedKeys) % if subject didn't press any key
                resp_input      = 0; 
                rt              = nan;
                answer          = nan;
                respmade        = GetSecs;
                
            elseif ~isempty(pressedKeys) % if subjects pressed a valid key
                
                if keycode(1,keys.option1) % subject pressed key 1
                    resp_input  = keys.option1;
                    rt          = secs - fliptime;
                    answer      = t2options(1); % left option
                    respmade    = secs;
                    
                elseif keycode(1,keys.option2) % subject pressed key 2
                    resp_input  = keys.option2;
                    rt          = secs - fliptime;
                    answer      = t2options(2); % middle option
                    respmade    = secs;
                    
                elseif keycode(1,keys.option3) % subject pressed key 3
                    resp_input  = keys.option3;
                    rt          = secs - fliptime;
                    answer      = t2options(3); % left option
                    respmade    = secs;
                    
                elseif keycode(1,keys.esckey)
                    resp_input  = keys.esckey;
                    rt          = nan;
                    answer      = nan;
                    respmade    = nan;
                    abort       = 1;
                    break
                end % end of key press if statement
           
            end % end of response if statement
        
        end % end of response while loop
        
        t2rt        = rt;
        t2answer    = answer;
        t2correct   = t2answer == iT2;
        
        clear resp_input rt answer % clear workspace a bit
        
        objectoff   = respmade + (isi*2) - ifi; % give one second to respond
        
        % display fixation cross and wait for next trial
        Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
        fliptime    = Screen('Flip', window, objectoff - slack); 
        objectoff   = fliptime + (4*isi) + randperm(jitter*1000,1)/1000 - ifi; % give subject a few miliseconds before moving to the next trial
        
        % save trial info in a mat file
        runtrials(itrial).trialNb   = itrial;
        runtrials(itrial).trialstart = trialstart;
        runtrials(itrial).t1start   = t1Start;
        runtrials(itrial).t2start   = t2Start;
        runtrials(itrial).RSVP      = thisRSVP;
        runtrials(itrial).t1        = iT1;
        runtrials(itrial).t2        = iT2;
        runtrials(itrial).lag       = ilag;
        runtrials(itrial).t1pos     = post1;
        runtrials(itrial).t2pos     = thist2_pos;
        runtrials(itrial).t2pos     = thist2_pos;
        runtrials(itrial).t1rt      = t1rt;
        runtrials(itrial).t2rt      = t2rt;
        runtrials(itrial).t1answer  = t1answer;
        runtrials(itrial).t2answer  = t2answer;
        runtrials(itrial).t1correct = t1correct;
        runtrials(itrial).t2correct = t2correct;
        runtrials(itrial).run       = run;
        
    end % end of trials loop
 
end % end of task number statement 

% save run and trials in the log file
logs.runstart   = runstart;
logs.runtrials  = runtrials;

sublog          = fullfile(logs.resultsfolder,sprintf(logs.output,logs.PNb,logs.task,run));
save(sublog,'logs');

WaitSecs(2);




end