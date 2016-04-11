function floatXYZ = vt_convert_RGB_to_XYZ(floatRGB)
% function floatXYZ = vt_convert_RGB_to_XYZ(floatRGB)
%
% Takes: floatRGB (N, 3) - RGB coordinates for N colors: interval [0, 1]
% Returns: floatXYZ (N, 3) - XYZ coordinates
% Dependencies: (Variable_Report.m)
%
% Created 2016-02-15 by KCM for Vizzario, Inc.
%
% Updated 2016-03-29 by KCM

%% Description
% Converts from Display RGB (interval [0, 1]) to CIE Tristimulus Values (X, Y and Z)

try
    %% Check Argument
    % floatRGB must be provided
    assert(exist('floatRGB', 'var') && ~isempty(floatRGB), ...
        'vt_convert_RGB_to_XYZ:MissingArgument', '''floatRGB'' must be provided')
    %%
    % floatRGB must have size (N, 3)
    assert(ismatrix(floatRGB) && size(floatRGB, 2) == 3, ...
        'vt_convert_RGB_to_XYZ:ArgumentSize', '''floatRGB'' must have size (N, 3)')
    %%
    % floatRGB must contain real, finite values
    assert(all(isfinite(floatRGB(:))) && all(isreal(floatRGB(:))), ...
        'vt_convert_RGB_to_XYZ:ArgumentReal', '''floatRGB'' must contain real, finite values')
    %%
    % floatRGB must contain values in the interval [0, 1]
    assert(min(floatRGB(:)) >= 0 && max(floatRGB(:)) <= 1, ...
        'vt_convert_RGB_to_XYZ:ArgumentRange', ...
        '''floatRGB'' must contain values in the interval [0, 1]')
    
    %% Convert
    % Conversion constants taken from Open CV function 'cvtColor' based on standard primary
    % chromaticities, a white point at D65, and a maximum, white luminance of 1
    % http://docs.opencv.org/2.4/modules/imgproc/doc/miscellaneous_transformations.html#cvtcolor
    %%
    % $\hbox{\fontsize{12}{12}\selectfont\(
    % \left[\begin{array}{c}
    % X\\Y\\Z
    % \end{array}\right]
    % \leftarrow
    % \left[\begin{array}{ccc}
    % 0.412453 & 0.357580 & 0.180423 \\
    % 0.212671 & 0.715160 & 0.072169 \\
    % 0.019334 & 0.119193 & 0.950227
    % \end{array}\right]
    % \cdot
    % \left[\begin{array}{c}
    % R\\G\\B
    % \end{array}\right]
    % \)}$
    %%
    % Code written out as three equations to facilitate processing lists of colors
    floatXYZ = zeros(size(floatRGB));
    floatXYZ(:, 1) = ... % X
        floatRGB(:, 1) .* 0.412453 + floatRGB(:, 2) .* 0.357580 + floatRGB(:, 3) .* 0.180423;
    floatXYZ(:, 2) = ... % Y
        floatRGB(:, 1) .* 0.212671 + floatRGB(:, 2) .* 0.715160 + floatRGB(:, 3) .* 0.072169;
    floatXYZ(:, 3) = ... % Z
        floatRGB(:, 1) .* 0.019334 + floatRGB(:, 2) .* 0.119193 + floatRGB(:, 3) .* 0.950227;
    
catch excpCause
    throw(addCause(MException('vt_convert_RGB_to_XYZ:UnabletoConvert', ...
        'Unable to convert from RGB to XYZ'), excpCause))
end; clear floatRGB

%% Variable Report (Housecleaning: for spotting uncleared variables.  Omit if desired)
%Variable_Report(whos, 'floatXYZ')

end