function [plot,lme] = LME_andplot(Table, Title, savepath, depvar, fixed_effects, random_effects, grouping, colors)
%Function for making dot + sem plots and LME stats, with annotation.
%currently only functional for 2 total groups
%inputs:
% - table with relevant data
% - Title of figure and stats to be saved (should be descriptive because
% that is how figure and stats will be saved)
% - file path where figure and stats should be saved
% - depvar is what variable you want to see is different between
% groups/ind. var
% - fixed_effects is the ind. vars
% - random_effects is the other variables you want to control for (e.g.
% animalID, etc). Must include any nesting you need (e.g.
% AnimalID:Session), and be formatted for fitlme
% grouping wanted for averaging for figure (e.g. session)
%last 4 variables all need to be strings that match your column titles in
%your table
%colors is a cell array of the colors you want your different ave+error

%stats
formula = [depvar ' ~ ' fixed_effects ' + ' random_effects];

lme = fitlme(Table, formula);
rows = contains(lme.Coefficients.Name, fixed_effects);
pval = lme.Coefficients.pValue(rows);

modelTitle = strrep(Title, ' ', '_');  %remove spaces for safe filenames

filename = fullfile(savepath, 'stats', modelTitle + ".mat");
save(filename, "lme");%saves full lme data to savepath with title from the lme itself as a .mat object
%saving as text file too
modelText = evalc('disp(lme)');
filepath = fullfile(savepath, modelTitle + ".txt");
fid = fopen(filepath, 'w');
fprintf(fid, '%s', modelText);
fclose(fid);


%ok now making figure. basing off of Steph's stats figures from New
%Information Triggers... Nature Communications, 2025
%averaging by session (Steph did not average by animal for her figures,
%just stats)
session_means = groupsummary(Table, {grouping, fixed_effects}, 'mean', depvar);

%95% CI for error bars and ave within grouping
stats = grpstats(session_means, {fixed_effects}, {'mean', 'std', 'numel'}, 'DataVars', ['mean_' depvar]);
n = stats.(['numel_mean_' depvar]);
sd = stats.(['std_mean_' depvar]);

tval = tinv(0.975, n - 1);
stats.CI95 = tval .* (sd ./ sqrt(n));

%setting up plot
x = 1:height(stats);  
y = stats.(['mean_mean_' depvar]);
err = stats.CI95;
xlabels = stats.(fixed_effects);

%creating plot
figure
hold on
for i = 1:numel(x)
    errorbar(x(i), y(i), err(i), 'o', ...
        'MarkerSize', 8, ...
        'LineWidth', 1.5, ...
        'CapSize', 12,...
        'Color', colors{i},...
        'MarkerFaceColor', colors{i});
end
hold off
grid on;

set(gca, 'XTick', x, 'XTickLabel', xlabels);
xlabel(fixed_effects);
ylabel(depvar);
title(Title);
xlim([min(x)-0.5, max(x)+0.5]);

%annotating with Pval
txt = sprintf('p = %.3g', pval);
text(0.05, 0.95, txt, 'Units', 'normalized', 'VerticalAlignment', 'top');

makefigurepretty(gcf, 'ms',1)
savefigALP(savepath, Title, 'type', 'png', 'ms', 1)
end