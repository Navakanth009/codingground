function floatPolar = vt_convert_Cartesian_to_polar(floatCartesian, floatCenter)
% function floatPolar = vt_convert_Cartesian_to_polar(floatCartesian [, floatCenter = [0, 0]])
%
% Takes: floatCartesian (N, 2) - x and y values (or any pair of orthogonal coordinates) for N
%                                coordinate pairs
%        floatCenter (1, 2) - (Optional) Center point for polar coordinate space
% Returns: floatPolar (N, 2) - Polar coordinates: angle (radians) and radius / distance for N
%                              coordinate pairs
% Dependencies: (Variable_Report.m)
%
% Created 2016-03-18 by KCM for Vizzario, Inc.
%
% Updated 2016-03-30 by KCM

%% Description
% Converts from Cartesian to polar coordinates with the option of providing a center point other
% than [0, 0].

try
    %% Check Arguments
    % floatCartesian must be provided
    assert(exist('floatCartesian', 'var') && ~isempty(floatCartesian), ...
        'vt_convert_Cartesian_to_polar:MissingArgument', '''floatCartesian'' must be provided')
    %%
    % floatCartesian must have size (N, 2)
    assert(ismatrix(floatCartesian) && size(floatCartesian, 2) == 2, ...
        'vt_convert_Cartesian_to_polar:ArgumentSize', '''floatCartesian'' must have size (N, 2)')
    %%
    % floatCartesian must contain real, finite values
    assert(all(isfinite(floatCartesian(:))) && all(isreal(floatCartesian(:))), ...
        'vt_convert_Cartesian_to_polar:ArgumentReal', ...
        '''floatCartesian'' must contain real, finite values')
    
    %%
    % floatCenter (if provided) must have size (1, 2)
    assert((~exist('floatCenter', 'var') || isempty(floatCenter)) || ...
        (ismatrix(floatCenter) && size(floatCenter, 1) == 1 && size(floatCenter, 2) == 2), ...
        'vt_convert_Cartesian_to_polar:ArgumentSize', ...
        '''floatCenter'' (if provided) must have size (1, 2)')
    %%
    % floatCenter (if provided) must contain real, finite values
    assert((~exist('floatCenter', 'var') || isempty(floatCenter)) || ...
        (all(isfinite(floatCenter)) && all(isreal(floatCenter))), ...
        'vt_convert_Cartesian_to_polar:ArgumentReal', ...
        '''floatCenter'' (if provided) must contain real, finite values')
    
    %% Default Center [0, 0]
    if ~exist('floatCenter', 'var') || isempty(floatCenter); floatCenter = [0, 0]; end
    
    %% Convert
    % $\hbox{\fontsize{16}{16}\selectfont\(
    % \theta = tan ^ {-1}(\frac{y - y_c}{x - x_c})
    % \)}$
    %
    % $\hbox{\fontsize{16}{16}\selectfont\(
    % Radius = \sqrt{(y - y_c)^{2} + (x - x_c)^{2}}
    % \)}$
    floatPolar = zeros(size(floatCartesian));
    % Angle
    floatPolar(:, 1) = atan2(...
        floatCartesian(:, 2) - floatCenter(2), ...
        floatCartesian(:, 1) - floatCenter(1));
    % Radius
    floatPolar(:, 2) = sqrt(...
        (floatCartesian(:, 2) - floatCenter(2)) .^ 2 + ...
        (floatCartesian(:, 1) - floatCenter(1)) .^ 2);
    
catch excpCause
    throw(addCause(MException('vt_convert_Cartesian_to_polar:UnabletoConvert', ...
        'Unable to convert from Cartesian to polar'), excpCause))
end; clear floatCartesian floatCenter

%% Variable Report (Housecleaning: for spotting uncleared variables.  Omit if desired)
%Variable_Report(whos, 'floatPolar')

end