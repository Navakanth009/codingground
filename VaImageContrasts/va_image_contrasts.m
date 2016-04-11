function floatContrast = va_image_contrasts(strImageFile)
% function floatContrast = va_image_contrasts(strImageFile)
%
% Opens image, converts to chromoluminance space and calculates RMS contrast for luminance, x, y
% and L, M and S confusion "rays".
%
% Takes: strImageFile (string) - String containing image file path and name
% Returns: floatContrast (6, 1) - RMS contrast values for luminance, x, y and L, M and S confusion
%                                 "rays"
% Dependencies: vt_convert_RGB_to_xyY.m, vt_convert_Cartesian_to_polar.m, (Variable_Report.m)
%
% Created 2016-03-18 by KCM for Vizzario, Inc.
%
% Updated 2016-03-18 by KCM

%% Check Argument
if ~exist('strImageFile', 'var') || isempty(strImageFile) % ERROR
    fprintf(char(strcat({'\nva_image_contrasts: '}, {'''strImageFile'' must be provided!\n\n'})))
    floatContrast = []; return
end
disp('va_image_contrasts strImageFile')
strImageFile
%% Read Image File
intRGB = imread(strImageFile); clear strImageFile
floatRGB = double(intRGB) ./ 255;

%% Stack
floatRGB = reshape(floatRGB, size(floatRGB, 1) * size(floatRGB, 2), 3);

%% Convert to Chromoluminance
floatxyY = vt_convert_RGB_to_xyY(floatRGB); clear floatRGB

%% Luminance Cutoff (exclude near black / white pixels)
floatYMin = 0.1; floatYMax = 0.9;

%% Mean Chromaticity
floatMeanx = mean(floatxyY(floatxyY(:, 3) > floatYMin & floatxyY(:, 3) < floatYMax, 1));
floatMeany = mean(floatxyY(floatxyY(:, 3) > floatYMin & floatxyY(:, 3) < floatYMax, 2));

%% Bins (0.05:0.005:0.65): N = 121 / (0:0.01:1): N = 101
floatxBin = (0.05:0.005:0.65)'; floatyBin = (0.05:0.005:0.65)'; floatYBin = (0:0.01:1)';
floatBin = zeros(length(floatxBin), length(floatyBin), length(floatYBin));
for intPixel = 1:size(floatxyY, 1)
    if max(floatxyY(intPixel, 3)) > floatYMin && min(floatxyY(intPixel, 3)) < floatYMax
        intIndexx = find(floatxBin > floatxyY(intPixel, 1), 1, 'first');
        intIndexy = find(floatyBin > floatxyY(intPixel, 2), 1, 'first');
        intIndexY = find(floatYBin > floatxyY(intPixel, 3), 1, 'first');
        floatBin(intIndexx, intIndexy, intIndexY) = floatBin(intIndexx, intIndexy, intIndexY) + 1;
        clear intIndexx intIndexy intIndexY
    end
end; clear intPixel
floatBinxy = squeeze(sum(floatBin, 3));
floatBinxY = squeeze(sum(floatBin, 2)); clear floatBin
% Range
floatBinxyStacked = reshape(floatBinxy, numel(floatBinxy), 1);
floatBinxyMin = min(floatBinxyStacked(floatBinxyStacked > 0));
floatBinxyMax = max(floatBinxyStacked); clear floatBinxyStacked
% Range
floatBinxYStacked = reshape(floatBinxY, numel(floatBinxY), 1);
floatBinxYMin = min(floatBinxYStacked(floatBinxYStacked > 0));
floatBinxYMax = max(floatBinxYStacked); clear floatBinxYStacked

%% Luminance Contrast
floatContrast = zeros(6, 1);
floatContrast(1) = std(floatxyY(:, 3), 0, 1);

%% Chromatic Contrast
floatContrast(2:3) = std(floatxyY(:, 1:2), 0, 1);

%% Confusion Ray Polar Spaces
floatPolarL = vt_convert_Cartesian_to_polar(floatxyY(:, 1:2), [0.747, 0.253]);
floatPolarM = vt_convert_Cartesian_to_polar(floatxyY(:, 1:2), [1.080, -0.800]);
floatPolarS = vt_convert_Cartesian_to_polar(floatxyY(:, 1:2), [0.171, 0.000]); clear floatxyY

%% Reference Confusion Lines Angle
floatPolarLMean = vt_convert_Cartesian_to_polar([floatMeanx, floatMeany], [0.747, 0.253]);
floatPolarMMean = vt_convert_Cartesian_to_polar([floatMeanx, floatMeany], [1.080, -0.800]);
floatPolarSMean = vt_convert_Cartesian_to_polar([floatMeanx, floatMeany], [0.171, 0.000]);

%% Confusion Ray Contrast
floatContrast(4) = std(floatPolarL(:, 2), 0, 1); clear floatPolarL
floatContrast(5) = std(floatPolarM(:, 2), 0, 1); clear floatPolarM
floatContrast(6) = std(floatPolarS(:, 2), 0, 1); clear floatPolarS

%% Primaries
floatPrimaryxyY = vt_convert_RGB_to_xyY([1, 0, 0; 0, 1, 0; 0, 0, 1]);

%% Plot
% Initialize
axesP = [0, 1 / 2, 1 / 3, 1 / 2; ... % Image Source
    0, 0, 1 / 3, 1 / 2; ... % Contrasts
    1 / 3, 0, 1 / 3, 1; ... % Chromaticity Plane
    2 / 3, 0, 1 / 3, 1]; % xY Plane
[figH, axesH] = Figure_Build(axesP, [-1920, 0, 1920, 1080], [], 18);
set(figH, 'NumberTitle', 'off', 'Name', 'va_image_contrasts', 'MenuBar', 'none', 'ToolBar', 'none')
for iAxes = 1:length(axesH)
    hold(axesH(iAxes), 'on'); set(axesH(iAxes), 'LineWidth', 2, 'FontWeight', 'bold')
end; clear iAxes
title(axesH(1), 'Image Source', 'FontWeight', 'bold')
title(axesH(2), 'Contrasts', 'FontWeight', 'bold')
title(axesH(3), 'Chromaticity (x, y) Plane', 'FontWeight', 'bold')
title(axesH(4), 'Luminance (x, Y) Plane', 'FontWeight', 'bold')
xlabel(axesH(1), ''); ylabel(axesH(1), '')
xlabel(axesH(2), 'Contrast Dimension', 'FontWeight', 'bold')
set(axesH(2), 'XTick', 1:length(floatContrast), ...
    'XTickLabel', [{'Lum'}; {'x'}; {'y'}; {'L'}; {'M'}; {'S'}])
for iAxes = 3:4
    xlabel(axesH(iAxes), 'x', 'FontWeight', 'bold')
    set(axesH(iAxes), 'XTick', linspace(0.05, 0.65, 7)')
end; clear iAxes
ylabel(axesH(2), 'RMS Contrast', 'FontWeight', 'bold')
set(axesH(2), 'YTick', linspace(min(floatContrast), max(floatContrast), 5)')
ylabel(axesH(3), 'y', 'FontWeight', 'bold')
set(axesH(3), 'YTick', linspace(0.05, 0.65, 7)')
ylabel(axesH(4), 'Y (Luminance)', 'FontWeight', 'bold')
set(axesH(4), 'YTick', linspace(floatYMin, floatYMax, 9)'); clear floatYMin floatYMax
for iAxes = 2:4
    set(axesH(iAxes), 'XLim', ...
        [min(get(axesH(iAxes), 'XTick')) - 0.05 * range(get(axesH(iAxes), 'XTick')), ...
        max(get(axesH(iAxes), 'XTick')) + 0.05 * range(get(axesH(iAxes), 'XTick'))])
    set(axesH(iAxes), 'YLim', ...
        [min(get(axesH(iAxes), 'YTick')) - 0.05 * range(get(axesH(iAxes), 'YTick')), ...
        max(get(axesH(iAxes), 'YTick')) + 0.05 * range(get(axesH(iAxes), 'YTick'))])
end; clear iAxes
% Data
set(figH, 'CurrentAxes', axesH(1)); imshow(intRGB); clear intRGB
plot(axesH(2), 1, floatContrast(1), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 10, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', [0, 0, 0]);
plot(axesH(2), 2, floatContrast(2), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 10, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', [0.5, 0.5, 0.5]);
plot(axesH(2), 3, floatContrast(3), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 10, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', [0.5, 0.5, 0.5]);
plot(axesH(2), 4, floatContrast(4), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 10, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', [1, 0, 0]);
plot(axesH(2), 5, floatContrast(5), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 10, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', [0, 1, 0]);
plot(axesH(2), 6, floatContrast(6), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 10, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', [0, 0, 1]);
floatLightest = 0.95;
set(figH, 'CurrentAxes', axesH(3))
for intx = 1:(length(floatxBin) - 1)
    for inty = 1:(length(floatyBin) - 1)
        if floatBinxy(intx, inty) > 0
            floatColor = floatLightest .* ones(1, 3) - floatLightest .* ones(1, 3) .* ...
                (floatBinxy(intx, inty) - floatBinxyMin) / (floatBinxyMax - floatBinxyMin);
            floatColor(floatColor < 0) = 0; floatColor(floatColor > 1) = 1;
            fill([ones(1, 2) .* floatxBin(intx), ones(1, 2) .* floatxBin(intx + 1)], ...
                [floatyBin(inty), ones(1, 2) .* floatyBin(inty + 1), floatyBin(inty)], ...
                floatColor, 'EdgeColor', 'none'); clear floatColor
        end
    end; clear inty
end; clear intx floatyBin floatBinxy floatBinxyMin floatBinxyMax
set(figH, 'CurrentAxes', axesH(4))
for intx = 1:(length(floatxBin) - 1)
    for intY = 1:(length(floatYBin) - 1)
        if floatBinxY(intx, intY) > 0
            floatColor = floatLightest .* ones(1, 3) - floatLightest .* ones(1, 3) .* ...
                (floatBinxY(intx, intY) - floatBinxYMin) / (floatBinxYMax - floatBinxYMin);
            floatColor(floatColor < 0) = 0; floatColor(floatColor > 1) = 1;
            fill([ones(1, 2) .* floatxBin(intx), ones(1, 2) .* floatxBin(intx + 1)], ...
                [floatYBin(intY), ones(1, 2) .* floatYBin(intY + 1), floatYBin(intY)], ...
                floatColor, 'EdgeColor', 'none'); clear floatColor
        end
    end; clear intY
end; clear intx floatxBin floatYBin floatBinxY floatBinxYMin floatBinxYMax floatLightest
% Reference
set(figH, 'CurrentAxes', axesH(3)); axis square
plot(axesH(3), floatPrimaryxyY([1:3, 1], 1), floatPrimaryxyY([1:3, 1], 2), ...
    'LineWidth', 2, 'Color', [0.75, 0.75, 0.75]); clear floatPrimaryxyY
plot(axesH(3), floatMeanx + [-1, +1] .* cos(floatPolarLMean(1)), ...
    floatMeany + [-1, +1] .* sin(floatPolarLMean(1)), 'Color', [1, 0.75, 0.75]);
clear floatPolarLMean
plot(axesH(3), floatMeanx + [-1, +1] .* cos(floatPolarMMean(1)), ...
    floatMeany + [-1, +1] .* sin(floatPolarMMean(1)), 'Color', [0.75, 1, 0.75]);
clear floatPolarMMean
plot(axesH(3), floatMeanx + [-1, +1] .* cos(floatPolarSMean(1)), ...
    floatMeany + [-1, +1] .* sin(floatPolarSMean(1)), 'Color', [0.75, 0.75, 1]);
clear floatMeanx floatMeany floatPolarSMean
% Arrange
disp('va_image_contrasts axesP axesH')
axesP
axesH
Figure_Arrange(axesP, figH, axesH, [], 1, [0, 0, 0]); clear axesP axesH
% Save
% hgexport(figH, char(strcat({'../'}, get(figH, 'Name'), {'.png'})), hgexport('factorystyle'), ...
%     'Format', 'png'); close(figH)
clear figH

%% Variable Report (Housecleaning: for spotting uncleared variables.  Omit if desired)
%Variable_Report(whos, 'floatContrast')

end