function beads_rhul_project(sub, ses);

% addpath('C:\Code\Cogent2000v1.29\Toolbox');
addpath(genpath('C:\Cogent2000v1.32'));

%basic trial info
num_trials = 25;    %per cell!
max_draws = 10;     %per sequence/trial!

%manipulated parameters - factor 1: the odds!
p_cell(1) = 0.7;

%accuracy tracking
balance = 0;
accuracy = struct('cell1',[],'average',[]);
cash = struct('cell1',[],'average',[]);
draws = struct('cell1',[],'average',[]);
reaction_times = struct('cell1',[],'average',[]);

behavior = cell(num_trials,1);

%timing
trial_instructions_duration = 3*1000;
ball_stimulus_duration = 2500; %how long to notify subject of current ball in msec
response_duration = 3500;            %how long subs have to respond after promted in msec, jitter?
feedback_duration = 4500;

%text display
default_text_size = 30;
ball_text_size = 75;
line_spacing = 20;

%configure cogent
config_display( 0, 3, [0.5 0.5 0.5], [1 1 1], 'Arial', 100, 4);

config_keyboard(100,5,'nonexclusive');
logfile = sprintf('beads_project_sub%02d_ses%d.log',sub,ses);
resfile = [ sprintf('beads_project_sub%02d_ses%d_', sub,ses) num2str(datevec(now),'-%02.0f') '.res.txt'];
config_log(logfile); config_results(resfile);
addresults( sprintf( '\ttrial_num\tblue_urn\tdraw\tball_color\tnum_draws\tchoice\tcorrect\t' ));    %write res header

%prepare experiment start
start_cogent;
settextstyle('Arial', 20);
line_start = 300; line_increment = 30;
preparestring('There are two urns:',1,0,line_start);
setforecolour(0,0,1); preparestring('The Blue Urn has more blue balls than green balls',1,0, line_start-line_increment*1);
setforecolour(0,1,0); preparestring('The Green Urn has more green balls than blue balls',1,0, line_start-line_increment*2);
setforecolour(1,1,1); preparestring('On each trial, you will draw a sequence of balls from one of these two urns.',1,0,line_start-line_increment*4);
preparestring('Your job is to decide whether the balls are drawn from the blue urn or the green urn',1,0,line_start-line_increment*5);
preparestring('After each ball is drawn, you may choose:  ',1,0,line_start-line_increment*7);
setforecolour(0,0,1); preparestring('(1) Guess The Blue Urn',1,0,line_start-line_increment*8);
setforecolour(0,1,0); preparestring('(2) Guess The Green Urn',1,0,line_start-line_increment*9);
setforecolour(0,0,0); preparestring('(3) Draw another ball',1,0,line_start-line_increment*10);
setforecolour(1,1,1); preparestring( sprintf(' You may make a decision after any draw but you may not draw more than %d balls', max_draws),1,0,line_start-line_increment*12);
preparestring( 'Please press SPACE BAR when you are ready to begin the first trial',1,0,line_start-line_increment*19);
drawpict( 1 ); waitkeydown(inf, 71); clearpict( 1 ); wait(1000);

logstring(time);

%computes which trials are blue with high prob (1) or green (0)
blue_urn_temp(1,:) = mod(randperm(num_trials),2); %makes a random order of trials

%distribute blue_urn codes and block types into a random sequence
master_order = randperm( numel(blue_urn_temp) );
blue_urn = blue_urn_temp( master_order );
logstring(blue_urn(:,1)');
clear blue_urn_temp block_type_temp;

for trial=1:num_trials; %trial means which sequence, not which draw
    
    clear p amount_win amount_lose amount_sample;
    
    %%%%determine parameters for this block
    p = p_cell(1);
    
    logstring( sprintf('trial %2.2f p: %2.2f', trial, p ));
    
    %make sequence and code as blue or green urn trial (blue=1)
    %new hard coded sequence ensures every trial has expected proportions
    %sequence{trial} = (rand(1,max_draws) > p) + 1;  %code 1 is whichever one is high probability
    if p == p(1); num_maj = ceil( p(1)*max_draws ); %so 0.8 should give 8 out of ten
    else num_maj = ceil( p(2)*max_draws );
    end;
    maj_draws = ones(1, num_maj);
    min_draws = ones(1, max_draws - num_maj)+1;
    temp_seq = [maj_draws min_draws];
    sequence{trial} = temp_seq(1,randperm(max_draws));
    
    logstring( sequence{trial}(:)' );
    temp_accuracy = 0;
    num_draw_choices = 0;
    
    %show new instructions for this sequence
    clearpict( 1 ); clearpict( 2 );  settextstyle('Arial', default_text_size);
    line_start = 90; line_increment = default_text_size + line_spacing;
    setforecolour(1,1,1);
    preparestring(sprintf('Sequence %d', trial),1,0,line_start-line_increment);
    preparestring(sprintf('The urns have a %02d / %02d color split', round(p*100), round((1-p)*100)),1,0,line_start-line_increment*2);
    setforecolour(1,1,1);
    drawpict( 1 ); wait(trial_instructions_duration);
    
    %let the drawing begin!
    for ball = 1:max_draws;
        
        clearpict( 1 ); clearpict( 2 );
        
        %high probability draws
        if sequence{trial}(ball) == 1;  %if a code 1 (high prob) is drawn,
            if blue_urn(trial) == 1;    %code 1 is a blue ball for blue sequences
                logstring( 'blue urn sequence, blue ball drawn');
                setforecolour(0,0,1); settextstyle('Arial', ball_text_size); preparestring( 'BLUE',1);
            else;       %and a green ball for green sequences
                logstring( 'green urn sequence, green ball drawn');
                setforecolour(0,1,0); settextstyle('Arial', ball_text_size); preparestring( 'GREEN',1);
            end;
            
            %low probability draws
        elseif sequence{trial}(ball) == 2;
            if blue_urn(trial) == 1;    %code 0 is a green ball for blue sequences
                logstring( 'blue urn sequence, green ball drawn');
                setforecolour(0,1,0); settextstyle('Arial', ball_text_size); preparestring( 'GREEN',1);
            else;                       %and a blue ball for green sequences
                logstring( 'green urn sequence, blue ball drawn');
                setforecolour(0,0,1); settextstyle('Arial', ball_text_size); preparestring( 'BLUE',1);
            end;
        end;    %ends if then for hi/lo probability outcomes
        
        %show ball color
        drawpict(1); wait(ball_stimulus_duration); setforecolour(1,1,1);
        
        %ISI with fixation -- necessary? jittered? how long?
        %preparestring('+', 2); drawpict( 2 ); wait(fixation_after_draw_duration);
        
        %response prompt
        clearpict( 1 ); clearpict( 2 ); settextstyle( 'Arial', default_text_size );
        if ball == max_draws;
            setforecolour(1,1,1); preparestring('That was your last draw! Now, you must choose:', 1, 0, (default_text_size + line_spacing)*2);
            setforecolour(0,0,1); preparestring('blue?', 1, 0, default_text_size + line_spacing);
            setforecolour(0,1,0); preparestring('green?', 1, 0, 0);
        else
            setforecolour(0,0,1); preparestring('blue?', 1, 0, default_text_size + line_spacing);
            setforecolour(0,1,0); preparestring('green?', 1, 0, 0);
            setforecolour(1,1,1); preparestring('draw?',1,0, -(default_text_size + line_spacing));
        end;
        
        %show prompt
        prompt_time = drawpict(1); wait( response_duration ); clearpict( 1 ); clearpict( 2 ); setforecolour(0,0,0);
        
        %read responses and load feedback into upper part of text buffer
        %assume 2 = blue (code 2) 3 = green 4 = draw
        readkeys; [keypressed, keytime] = lastkeydown; clearkeys;   %get subs response
        keypressed = keypressed(numel(keypressed));
        keytime = keytime(numel(keytime));  %keep only most recent response
        reaction_time = keytime - prompt_time;
        logstring( sprintf('subjects latest response %2.2f with RT %2.2f', keypressed, reaction_time) );
        
        %determine text styles before loading in the text for
        %the feedback display
        settextstyle('Arial', default_text_size+70); setforecolour(1,1,1);
        
        %if subject says draw, draw again
        if keypressed == 30;
            logstring('subject chose draw again');
            behavior{trial}(ball,:) = [0,0,1];
            num_draw_choices = num_draw_choices + 1;
            if ball == max_draws; %workaround to ensure this gives a wrong answer if no more draws
                keypressed = 99; setforecolour(1,0,0); preparestring('wrong',1,0,40);  %setup feedback screen
            end;
            
            %if sub says blue, credit them only if blue trial
        elseif keypressed == 28 & blue_urn(trial) == 1; %if blue urn recognized
            logstring('subject correctly chose blue');
            behavior{trial}(ball,:) = [1,0,0];
            setforecolour(0,1,0); preparestring('Correct!',1,0,40);
            temp_accuracy = 1;
            
            %if sub says green, credit them only if green trial
        elseif keypressed == 29 & blue_urn(trial) == 0;   %if green urn recognized
            logstring('subject correctly chose green');
            behavior{trial}(ball,:) = [0,1,0];
            setforecolour(0,1,0); preparestring('correct!' ,1,0,40);
            temp_accuracy = 1;
            
        elseif keypressed == 28 & blue_urn(trial) == 0; %if blue urn response to green urn
            behavior{trial}(ball,:) = [1,0,0];
            logstring('the subject did not provide a correct response');
            setforecolour(1,0,0); preparestring('wrong',1,0,40);  %setup feedback screen
            
        elseif keypressed == 29 & blue_urn(trial) == 1; %if green urn response to blue urn
            behavior{trial}(ball,:) = [0,1,0];
            logstring('the subject did not provide a correct response');
            setforecolour(1,0,0); preparestring('wrong',1,0,40);  %setup feedback screen
           
        else
            %if somnething weird happens or subject makes no response
            behavior{trial}(ball,:) = zeros(1,3);
            logstring('the subject did not provide a correct response');
            setforecolour(1,0,0); preparestring('wrong',1,0,40);  %setup feedback screen
            
        end;        %ends big if/else statement sorting the responses
        
        addresults( sprintf( '\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t', trial, blue_urn(trial), ball, sequence{trial}(ball), num_draw_choices, keypressed, temp_accuracy));
        
        if keypressed ~= 30;
            
            %give feedback to sub
            logstring( sprintf('subject chose draw %2.2f times, answered %2.2f, the urn was %2.2f so earned %2.2f with balance %2.2f', num_draw_choices, keypressed, blue_urn(trial), sequence_balance, balance));
            preparestring( sprintf('%2.2f dollars this trial', sequence_balance),1,0,0);
            preparestring( sprintf('%2.2f dollars is your balance',balance),1,0,-(default_text_size + line_spacing));         
            drawpict(1); 
            wait( feedback_duration );
            setforecolour(1,1,1);
            
            %write FINAL sequence results to output structures
            
            accuracy.cell1( size( accuracy.cell1,1)+1,1 ) = temp_accuracy;
            draws.cell1( size( draws.cell1,1)+1,1 ) = num_draw_choices;
            reaction_times.cell1( size( reaction_times.cell1,1)+1,1 ) = reaction_time;
            
            
            clearpict( 1 ); clearpict( 2 ); clear keypressed keytime;   %clean up
            
            break;  %start next sequence
            
        end;    %if/then statement that ends trial and generates feedback
        
    end;    %ends loop through draws for this sequence
    
    
end;    %ends loops through trials


%compute final results
accuracy.average(1,1) = mean( accuracy.cell1(:,1) );
draws.average(1,1) = mean( draws.cell1(:,1) );
reaction_times.average(1,1) = mean( reaction_times.cell1(:,1) );
%
stop_cogent;

%results structures
logstring('accuracy.average: ');
logstring( accuracy.average' );
logstring('draws.average:');
logstring(draws.average');
logstring('reaction_times:');
logstring(reaction_times.average');
%
% %run model
% [fitted_output] = bayesbeads_nick_cogent(p_cell(1),p_cell(2),cost_diff(1),cost_diff(2), amount_sample_cell(1), amount_sample_cell(2), sequence, block_type, behavior, blue_urn);

%save results
save([sprintf('sub%02d_ses%d_', sub,ses) num2str(datevec(now),'-%02.0f') '.mat']);
