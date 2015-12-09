function plotPOMDP(results)

if isstr(results)
    try
        filename = [results '.mat'] ;
        l = load(filename);
        results = l.results;
        clear l;
    catch
        error('Could not load %s.mat Please run solvePODMP(''%s'') beforehand.',filename,results);
    end
    
elseif ~isstruct(results)
     error('Syntax: r = solveresults.pomdp(filedef); plotresults.pomdp(r);  or plotresults.pomdp(filedef); ');
end

%% ========================================================================
%  PLOTTING THE RESULTS
%  ========================================================================

% figure

figure('Name', filename                 , ...
       'Color',[1 1 1]                  , ...
       'WindowStyle','normal'           , ...
       'DockControls','off'             , ...
       'MenuBar','none'                 , ...
       'ToolBar','none'                 , ...
       'Position', [200 200 600 800]        )

% colors
color.wash    = [0.3 0.3 1  ];
color.check   = [1   0.3 0.3];
color.other   = [0.5 0.8 0.1];

color.clean   = [0.9 0.9 0.9];
color.dirty   = [0.3 0.3 0.3];

color.clean_nothing = [0.7 0.9 0.7];
color.clean_dirt    = [0.7 0.7 0.9];
color.dirty_nothing = [0.3 0.5 0.3];
color.dirty_dirt    = [0.3 0.3 0.5];

%find labels
for i=1:results.pomdp.nrActions
    labels_action{i} = results.pomdp.actions(i,:);
end

for i=1:results.pomdp.nrStates
    labels_state{i} = results.pomdp.states(i,:);
    for j=1:results.pomdp.nrObservations
        labels_observation{(i-1)*results.pomdp.nrObservations+j} = [labels_state{i} '/' results.pomdp.observations(j,:)];
    end
end


% plot Value function
ax_value = subplot(6,2,[1 3]);
plot(results.plot.belief_space, results.plot.action_values','LineWidth',3) ;
title('Value function');
legend(labels_action,'Location','SouthWest');
legend('off')
set(gca,'XTick',[0 1], 'XTickLabel',{'clean','dirty'})
ylabel('action value');
[ax_value.Children.LineWidth] = deal(3);
recolor(ax_value.Children) ;


% plot policy
ax_belief_policy = subplot(6,2,5);
imagesc(flipud(results.plot.policy_belief));
colormap(ax_belief_policy,[1 1 1; color.other; color.check; color.wash]) ;
title('policy')
set(gca,'XTick',[1 numel(results.plot.belief_space)], 'XTickLabel',{'clean','dirty'})
set(gca,'YTick',1:results.bmdp.nrStates)


% plot belief frequency
ax_belief = subplot(6,2,7);
BF = zeros(size(results.plot.policy_belief));
for i=1:results.bmdp.nrStates
    BF(i,:) = BF(i,:) + (results.plot.policy_belief(i,:)>0) * results.stats.belief_frequency(i);
end

imagesc(flipud(BF))
set(ax_belief,'CLim',[0 1]);
colormap(ax_belief,flipud(colormap('bone')))
set(gca,'XTick',[1 numel(results.plot.belief_space)], 'XTickLabel',{'clean','dirty'})
set(gca,'YTick',1:results.bmdp.nrStates)
title('belief frequency')


% plot state frequency
ax_state = subplot(6,2,[2 4]);
h_state = pie(results.stats.state_frequency) ;

l=legend(labels_state,'Orientation','vertical','box','off');

l.Position(1:2) = [.52   .9];
recolor(h_state) ;

title('state frequency')

% plot action frequency
subplot(6,2,[6 8])
h_action = pie(results.stats.action_frequency);
l=legend(labels_action,'Orientation','vertical','box','off');
l.Position(1:2) = [.52   .60];
title('action frequency')
recolor(h_action) ;

% plot observation frequency
ax_cont = subplot(6,2,[9 11]);
scatter(1,1 ,5000*results.stats.observation_frequency(1),color.clean_nothing,'filled','MarkerEdgeColor','none'); hold on
scatter(1,2 ,5000*results.stats.observation_frequency(2),color.clean_dirt   ,'filled','MarkerEdgeColor','none'); 
scatter(2,1 ,5000*results.stats.observation_frequency(3),color.dirty_nothing,'filled','MarkerEdgeColor','none'); 
scatter(2,2 ,5000*results.stats.observation_frequency(4),color.dirty_dirt   ,'filled','MarkerEdgeColor','none'); hold off

xlim([0 3]); 
ylim([0 3]);

grid on
ylabel('observation')
set(gca,'YTick',1:2,'YTickLabel',{'nothing','dirt'},'YTickLabelRotation',90)
xlabel('state')
set(gca,'XTick',1:2,'XTickLabel',{'clean','dirty'})

title('observation contingencies');


% plot action repetions
ax_repet = subplot(6,2,[10 12]);
hold on
max_l = size(results.stats.action_repet,2)-1;
for iA=1:results.pomdp.nrActions
    [xa xb] = stairs(-0.5:max_l+0.5,[results.stats.action_repet(iA,:) 0]);
    fill([xa' fliplr(xa')],[iA+.8*xb' iA*ones(1,numel(xb))],[0 0 0])
end
title('action repetition');
legend(labels_action,'Location','SouthWest');
legend('off')
%set(gca,'XTick',[0 belief_subsampling], 'XTickLabel',{'clean','dirty'})
set(gca,'YTick',[0 .8 1 1.8 2 2.8 3 3.8], 'YTickLabel',[0 1])
xlabel('bout length')
ylabel('proportion');
xlim([-0.6 3.6])
[ax_repet.Children.LineWidth] = deal(3);
recolor(ax_repet.Children) ;
%[ax_repet.Children.FaceColor] = deal('none');


    function recolor(elems)
        for iE =1:numel(elems)
            try
                c = color.(elems(iE).DisplayName) ;
                try, elems(iE).Color = c; end
                try, elems(iE).EdgeColor = c; end
                try, elems(iE).FaceColor = c; end
            end
        end
    end

end
