function Figure_Arrange(axesPOriginal, figH, axesH, lineStyle, lineWidth, lineColor)
% function Figure_Arrange(axesPOriginal, figH, axesH, lineStyle, lineWidth, lineColor)
%
% Fits axes into their designated regions (based on axesPOriginal) and aligns any horizontal and/or
% vertical axes for sub-plots with shared edges.  This function should be called after all axis
% scaling, number formatting, labeling and sub-plot titles have been set.  Optionally draws lines
% between sub-plots to visually separate them.
%
% Takes: axesPOriginal (N, 4) - Position(s) for all axes with respect to the figure as percent
%                               (from 0 to 1): Left, Right, Width, Height
%        figH (1, 1) - Figure handle (only used if separating lines are requested)
%        axesH (N, 1) - Index / Indices for axes (sub-plots)
%        lineStyle (string - 1, 1) - (optional) Line Style for a line separating sub-plots. (Lines
%                                    omitted if all line parameters omitted) (default '-')
%        lineWidth (1, 1) - (optional) Line Width for separating line (default 1)
%        lineColor (1, 3) - (optional) Line Color for separating line (RGB, 0 to 1) (default black)
% Dependencies: Variable_Report.m
%
% Created 2015-06-22 by KCM
%
% Updated 2015-07-20 by KCM

%% Input Arguments
if ~exist('axesPOriginal', 'var') || ~exist('figH', 'var') || ~exist('axesH', 'var')
    fprintf(char(strcat({'\nFigure_Arrange: '}, ...
        {'Function requres figure and axes arguments!\n\n'})))
    return
end
if isempty(axesPOriginal) || isempty(figH) || isempty(axesH)
    fprintf(char(strcat({'\nFigure_Arrange: '}, ...
        {'Figure and Axes arguments cannot be empty!\n\n'})))
    return
else
    if ~ismatrix(axesPOriginal) || size(axesPOriginal, 2) ~= 4
        fprintf(char(strcat({'\nFigure_Arrange: '}, ...
            {'Axes position(s) must be a matrix (N, 4)!\n\n'})))
        return
    end
    if ~ismatrix(figH) || size(figH, 1) ~= 1 || size(figH, 2) ~= 1
        fprintf(char(strcat({'\nFigure_Arrange: '}, ...
            {'Figure handle must be a matrix (1, 1)!\n\n'})))
        return
    end
    if ~ismatrix(axesH) || size(axesH, 2) ~= 1
        fprintf(char(strcat({'\nFigure_Arrange: '}, ...
            {'Axes handle(s) must be a matrix (N, 1)!\n\n'})))
        return
    end
    if size(axesPOriginal, 1) ~= size(axesH, 1)
        fprintf(char(strcat({'\nFigure_Arrange: '}, ...
            {'Number of axes handles and position vectors must be equal!\n\n'})))
        return
    end
end
if ~exist('lineStyle', 'var') && ~exist('lineWidth', 'var') && ~exist('lineColor', 'var')
    drawLine = false;
else
    if ~exist('lineStyle', 'var') || isempty(lineStyle)
        lineStyle = '-';
    end
    if ~exist('lineWidth', 'var') || isempty(lineWidth)
        lineWidth = 1;
    end
    if ~exist('lineColor', 'var') || isempty(lineColor)
        lineColor = [0, 0, 0];
    end
    drawLine = true;
end

%% Fit Axes within Regions (push titles/labels into region designated by axesPOriginal)
axesPModified = zeros(size(axesPOriginal, 1), 6);
for iAxes = 1:length(axesH)
    % Get Margins
    axesInset = get(axesH(iAxes), 'TightInset');
    % Resize to Fit
    axesPModified(iAxes, 1:4) = [axesPOriginal(iAxes, 1) + axesInset(1), ... % Left
        axesPOriginal(iAxes, 2) + axesInset(2), ... % Bottom
        axesPOriginal(iAxes, 3) - sum(axesInset([1, 3])), ... % Width
        axesPOriginal(iAxes, 4) - sum(axesInset([2, 4]))]; clear axesInset % Height
    % Add Right and Top
    axesPModified(iAxes, 5:6) = [axesPModified(iAxes, 1) + axesPModified(iAxes, 3), ... % Right
        axesPModified(iAxes, 2) + axesPModified(iAxes, 4)]; % Top
    axesPOriginal(iAxes, 5:6) = [axesPOriginal(iAxes, 1) + axesPOriginal(iAxes, 3), ... % Right
        axesPOriginal(iAxes, 2) + axesPOriginal(iAxes, 4)]; % Top
end; clear iAxes

%% Align Axis Lines along Shared Edges
for iFirstAxes = 1:length(axesH) - 1
    for iSecondAxes = 2:length(axesH)
        for iDimension = [1, 2, 5, 6]
            % Check for Aligned Edge
            if axesPOriginal(iFirstAxes, iDimension) == axesPOriginal(iSecondAxes, iDimension)
                % Choose Value to Apply to Both
                switch iDimension
                    case {1, 2} % Use higher value (larger margin)
                        tNew = max([axesPModified(iFirstAxes, iDimension), ...
                            axesPModified(iSecondAxes, iDimension)]);
                    case {5, 6} % Use lower value (larger margin)
                        tNew = min([axesPModified(iFirstAxes, iDimension), ...
                            axesPModified(iSecondAxes, iDimension)]);
                end
                axesPModified(iFirstAxes, iDimension) = tNew;
                axesPModified(iSecondAxes, iDimension) = tNew; clear tNew
                % Update Width / Height
                axesPModified(iFirstAxes, 3) = ... % Width (first axes)
                    axesPModified(iFirstAxes, 5) - axesPModified(iFirstAxes, 1) - 0.005;
                axesPModified(iFirstAxes, 4) = ... % Height (first axes)
                    axesPModified(iFirstAxes, 6) - axesPModified(iFirstAxes, 2) - 0.005;
                axesPModified(iSecondAxes, 3) = ... % Width (second axes)
                    axesPModified(iSecondAxes, 5) - axesPModified(iSecondAxes, 1) - 0.005;
                axesPModified(iSecondAxes, 4) = ... % Height (second axes)
                    axesPModified(iSecondAxes, 6) - axesPModified(iSecondAxes, 2) - 0.005;
            end
        end; clear iDimension
    end; clear iSecondAxes
end; clear iFirstAxes

%% Set Final Position
for iAxes = 1:length(axesH)
    set(axesH(iAxes), 'Position', axesPModified(iAxes, 1:4))
end; clear iAxes axesPModified axesH

%% Draw Separating Lines among Sub-Plots
if drawLine
    for iAxes = 1:size(axesPOriginal, 1)
        tLeft = axesPOriginal(iAxes, 1); tBottom = axesPOriginal(iAxes, 2);
        tRight = axesPOriginal(iAxes, 1) + axesPOriginal(iAxes, 3);
        tTop = axesPOriginal(iAxes, 2) + axesPOriginal(iAxes, 4);
        if tLeft > 0
            annotation(figH, 'line', [tLeft, tLeft], [tBottom, tTop], ...
                'LineStyle', lineStyle, 'LineWidth', lineWidth, 'Color', lineColor)
        end
        if tRight < 1
            annotation(figH, 'line', [tRight, tRight], [tBottom, tTop], ...
                'LineStyle', lineStyle, 'LineWidth', lineWidth, 'Color', lineColor)
        end
        if tBottom > 0
            annotation(figH, 'line', [tLeft, tRight], [tBottom, tBottom], ...
                'LineStyle', lineStyle, 'LineWidth', lineWidth, 'Color', lineColor)
        end; clear tBottom
        if tTop < 1
            annotation(figH, 'line', [tLeft, tRight], [tTop, tTop], ...
                'LineStyle', lineStyle, 'LineWidth', lineWidth, 'Color', lineColor)
        end; clear tLeft tRight tTop
    end; clear iAxes lineStyle lineWidth lineColor
end; clear axesPOriginal figH drawLine

%% Variable Report (Housecleaning: for spotting uncleared variables.  Omit if desired)
%Variable_Report(whos)

end
