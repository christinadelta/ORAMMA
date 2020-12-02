function [trials] = CreateTrialList(set)

% Uses the task number to create a list of trials for each task 
% part of the ORAMMA experiments

taskNb = set.taskNb;

if taskNb == 1 % if task is RTs 
    
    itemreps        = 2; % how many times will each item be presented?
    listoftrials    = repmat(cat(2, set.item, set.animacy, set.category),itemreps,1); % create total trial list
    
    runtrials       = length(listoftrials)/set.runs; % how many trials per run? 
    randomizedlist  = listoftrials(randperm(length(listoftrials)),:); % randomize original trial list
    
    temp            = 0; % used to split trials in runs 
       
    % split trials in runs 
    for i = 1:set.runs
        
        trials.list{i}  = randomizedlist(1 + temp:runtrials * i,:); 
        
        temp            = temp + runtrials;
        
    end % end of for loop
    
    trials.runtrials    = runtrials; % add runtrials to the trials struct (we'll use this when running trials)
    
elseif taskNb == 2 % if task is ab
    
    % Create a triallist for the ab task.
    % we control for : t1 is not the same as t2 in trials
    % something to consider: should also make sure that we don't get the
    % same t1s in subsequent trials?
    
    lags            = 2; % lag2 and lag7
    
    targetreps      = 12; % each digit will be presented the same nb of times as t1, t2, lag2 and lag7
   
    targetoptions   = set.Ditems; % digit items (targets) for both lags 
    
    % make seperate lists fo lag2 and lag7 trials
    onelag          = repmat(targetoptions,targetreps/2,1);
    
    for lag = 1:lags
        
        randomize = 1;
        
        while randomize
            
            temp = randperm(length(onelag));
            randt1s = onelag(temp);
            same = (randt1s - onelag) == 0;
            
            if not(any(same))
                randomize = 0;
                templist{lag} = cat(2, randt1s, onelag);
                
            end % end of if statement
            
        end % end of randomization while loop
        
        clear temp randomize same 
        
    end % end of lag for loop
    
    % specify lag lists
    listlag2        = templist{1};
    listlag7        = templist{2};
    
    % concatinate the two temp lists and add lag index (1=lag2, 2=lag7)
    triallist       = cat(1, listlag2, listlag7);
    halflist        = length(onelag);
    
    triallist(:,3)  = cat(1, ones(halflist,1), ones(halflist,1)*2);
    
    runtrials       = length(triallist)/set.runs; % how many trials per run? 
    randomizedlist  = triallist(randperm(length(triallist)),:); % randomize original trial list
    
    temp            = 0; % used to split trials in runs 
    
    % split trials in runs 
    for i = 1:set.runs
        
        trials.list{i}  = randomizedlist(1 + temp:runtrials * i,:); 
        
        temp            = temp + runtrials;
        
    end % end of for loop
    
    trials.runtrials    = runtrials; % add runtrials to the trials struct (we'll use this when running trials)
    
    clear temp randomizedlist  

end % end of if statement 


end