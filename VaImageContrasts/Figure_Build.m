function [figureHandle, axesHandle] = Figure_Build(axesPosition, figurePosition, figureColor, fontSize)
% function [figureHandle, axesHandle] = ...
%     Figure_Build(axesPosition, figurePosition, figureColor, fontSize)
%
% Build figure at designated position on (default) screen containing one or more axes with
% designated positions
%
% Takes: axesPosition (N, 4) - Axes position(s) within figure (N >= 1), [Left, Right, Width,
%                              Height] in percent
%        figurePosition (1, 4) - (optional) Figure position within screen, [Left, Right, Width,
%                                           Height] in pixels, default fills screen
%        figureColor (1, 3) - (optional) Figure background color
%        fontSize (1, 1) - (optional) Font Size
% Returns: figureHandle (1, 1) - Index for figure
%          axesHandle (N, 1) - Index / Indices for axes
%
% Created 2014-07-07 by KCM
%
% Updated 2015-12-20 by KCM

%% Check Arguments
if nargin < 1
    fprintf(char(strcat({'\nFigure_Builder: '}, {'Function requires at least one argument!\n\n'})))
    figureHandle = -1; axesHandle = -1; return
end
if isempty(axesPosition)
    fprintf(char(strcat({'\nFigure_Builder: '}, ...
        {'At least one axes position must be given!\n\n'})))
    figureHandle = -1; axesHandle = -1; return
else
    if ~ismatrix(axesPosition) || size(axesPosition, 1) < 1 || size(axesPosition, 2) ~= 4
        fprintf(char(strcat({'\nFigure_Builder: '}, ...
            {'Axes position(s) must be a matrix (N, 4)!\n\n'})))
        figureHandle = -1; axesHandle = -1; return
    end
end
if ~exist('figurePosition', 'var') || isempty(figurePosition)
    figurePosition = get(0, 'screensize');
else
    if ~ismatrix(figurePosition) || size(figurePosition, 1) ~= 1 || size(figurePosition, 2) ~= 4
        fprintf(char(strcat({'\nFigure_Builder: '}, ...
            {'Figure position must be a matrix (1, 4)!\n\n'})))
        figureHandle = -1; axesHandle = -1; return
    end
end
if ~exist('figureColor', 'var') || isempty(figureColor)
    figureColor = [1, 1, 1];
else
    if ~ismatrix(figureColor) || size(figureColor, 1) ~= 1 || size(figureColor, 2) ~= 3
        fprintf(char(strcat({'\nFigure_Builder: '}, ...
            {'Figure color must be a matrix (1, 3)!\n\n'})))
        figureHandle = -1; axesHandle = -1; return
    end
end
if ~exist('fontSize', 'var') || isempty(fontSize)
    fontSize = 32;
else
    if numel(fontSize) > 1
        fprintf(char(strcat({'\nFigure_Builder: '}, {'Font Size must be a single value!\n\n'})))
        figureHandle = -1; axesHandle = -1; return
    end
end

%% Create Figure
figureHandle = figure; % Create figure
set(figureHandle, 'Position', figurePosition); clear figurePosition
% Set figure background color and preserve it during figure export
set(figureHandle, 'Color', figureColor, 'InvertHardcopy', 'off'); clear figureColor

%% Create Axes
axesHandle = zeros(size(axesPosition, 1), 1);
for iAxes = 1:length(axesHandle)
    axesHandle(iAxes) = axes; % Create axes
    set(axesHandle(iAxes), 'Color', 'none') % Make transparent
    set(axesHandle(iAxes), 'FontSize', fontSize, 'FontWeight', 'bold') % Font size
    title(axesHandle(iAxes), char(strcat({'Title '}, num2str(iAxes))), 'FontWeight', 'bold')
    xlabel(axesHandle(iAxes), char(strcat({'X Axis '}, num2str(iAxes))), 'FontWeight', 'bold')
    ylabel(axesHandle(iAxes), char(strcat({'Y Axis '}, num2str(iAxes))), 'FontWeight', 'bold')
end; clear iAxes fontSize

%% Fit Axes
for iAxes = 1:length(axesHandle)
    axesInset = get(axesHandle(iAxes), 'TightInset');
    tAxesPosition = ...
        [axesPosition(iAxes, 1) + axesInset(1), ... % Left
        axesPosition(iAxes, 2) + axesInset(2), ... % Bottom
        axesPosition(iAxes, 3) - sum(axesInset([1, 3])), ... % Width
        axesPosition(iAxes, 4) - sum(axesInset([2, 4]))]; clear axesInset % Height
    set(axesHandle(iAxes), 'Position', tAxesPosition); clear tAxesPosition
end; clear iAxes axesPosition

%%
%Variable_Report(whos, [{'figureHandle'}; {'axesHandle'}])

end
