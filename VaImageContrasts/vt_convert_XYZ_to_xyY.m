function floatxyY = vt_convert_XYZ_to_xyY(floatXYZ)
% function floatxyY = vt_convert_XYZ_to_xyY(floatXYZ)
%
% Takes: floatXYZ (N, 3) - XYZ coordinates for N colors
% Returns: floatxyY (N, 3) - Chromaticity and luminance
% Dependencies: vt_convert_RGB_to_XYZ.m, (Variable_Report.m)
%
% Created 2016-02-17 by KCM for Vizzario, Inc.
%
% Updated 2016-03-29 by KCM

%% Description
% Converts from CIE Tristimulus Values (X, Y and Z) to CIE Chromaticity (x and y) and the second
% tristimulus value (Y) corresponding to luminance.

try
    %% Check Argument
    % floatXYZ must be provided
    assert(exist('floatXYZ', 'var') && ~isempty(floatXYZ), ...
        'vt_convert_XYZ_to_xyY:MissingArgument', '''floatXYZ'' must be provided')
    %%
    % floatXYZ must have size (N, 3)
    assert(ismatrix(floatXYZ) && size(floatXYZ, 2) == 3, ...
        'vt_convert_XYZ_to_xyY:ArgumentSize', '''floatXYZ'' must have size (N, 3)')
    %%
    % floatXYZ must contain real, finite values
    assert(all(isfinite(floatXYZ(:))) && all(isreal(floatXYZ(:))), ...
        'vt_convert_XYZ_to_xyY:ArgumentReal', '''floatXYZ'' must contain real, finite values')
    %%
    % floatXYZ must contain values greater than or equal to zero
    assert(min(floatXYZ(:)) >= 0, 'vt_convert_XYZ_to_xyY:ArgumentMinimum', ...
        '''floatXYZ'' must contain values greater than or equal to zero')
    
    %% Convert
    % $\hbox{\fontsize{12}{12}\selectfont\(
    % x=\frac{X}{X+Y+Z}
    % \)}$
    %%
    % $\hbox{\fontsize{12}{12}\selectfont\(
    % y=\frac{Y}{X+Y+Z}
    % \)}$
    floatxyY = zeros(size(floatXYZ));
    floatxyY(:, 1) = floatXYZ(:, 1) ./ sum(floatXYZ, 2); % x
    floatxyY(:, 2) = floatXYZ(:, 2) ./ sum(floatXYZ, 2); % y
    floatxyY(:, 3) = floatXYZ(:, 2); % Y
    
    %% Correct for Black (results in NaN for x and y)
    floatXYZWhite = vt_convert_RGB_to_XYZ([0.5, 0.5, 0.5]); % (presumably D65)
    floatxyWhite = [floatXYZWhite(1) / sum(floatXYZWhite), ...
        floatXYZWhite(2) / sum(floatXYZWhite)]; clear floatXYZWhite
    floatxyY(isnan(floatxyY(:, 1)), 1) = floatxyWhite(1); % x for white
    floatxyY(isnan(floatxyY(:, 2)), 2) = floatxyWhite(2); clear floatxyWhite % y for white
    
catch excpCause
    throw(addCause(MException('vt_convert_XYZ_to_xyY:UnabletoConvert', ...
        'Unable to convert from XYZ to xyY'), excpCause))
end; clear floatXYZ

%% Variable Report (Housecleaning: for spotting uncleared variables.  Omit if desired)
%Variable_Report(whos, 'floatxyY')

end