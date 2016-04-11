function floatxyY = vt_convert_RGB_to_xyY(floatRGB)
% function floatxyY = vt_convert_RGB_to_xyY(floatRGB)
%
% Takes: floatRGB (N, 3) - Red, green and blue values for N colors in the interval [0, 1].
% Returns: floatxyY (N, 3) - CIE chromaticity (x and y in the interval (0, 1)) and luminance (Y
%                            value in the interval [0, 1]).
% Dependencies: vt_convert_RGB_to_XYZ.m, vt_convert_XYZ_to_xyY.m, (Variable_Report.m)
%
% Created 2016-02-19 by KCM for Vizzario, Inc.
%
% Updated 2016-03-29 by KCM

%% Description
% Converts from display coordinates (RGB) to CIE chromaticity and luminance (xyY).  Calls existing
% functions to go from RGB to XYZ and XYZ to xyY.

try
    %% Check Argument
    % Skipped: Taken care of in called function(s)
    
    %% Convert RGB to XYZ
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
    floatXYZ = vt_convert_RGB_to_XYZ(floatRGB);
    
    %% Convert XYZ to xyY
    % $\hbox{\fontsize{12}{12}\selectfont\(
    % x=\frac{X}{X+Y+Z}
    % \)}$
    %
    % $\hbox{\fontsize{12}{12}\selectfont\(
    % y=\frac{Y}{X+Y+Z}
    % \)}$
    floatxyY = vt_convert_XYZ_to_xyY(floatXYZ); clear floatXYZ
    
catch excpCause
    throw(addCause(MException('vt_convert_RGB_to_xyY:UnabletoConvert', ...
        'Unable to convert from RGB to xyY'), excpCause))
end; clear floatRGB

%% Variable Report (Housecleaning: for spotting uncleared variables.  Omit if desired)
%Variable_Report(whos, 'floatxyY')

end