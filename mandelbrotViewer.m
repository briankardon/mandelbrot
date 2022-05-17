function escape = mandelbrotViewer(clim, N, maxIter, ax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mandelbrotViewer: create a minimalistic GUI to explore the mandelbrot set
% usage:  mandelbrotViewer()
%         mandelbrotViewer(clim)
%         mandelbrotViewer(clim, N)
%         mandelbrotViewer(clim, N, maxIter)
%         escape = mandelbrotViewer(...)
%
% where,
%    clim is a 1x2 complex array of numbers indicating the "lower left" and
%       "upper right" corners of the region of the complex plane to 
%       display. Default is [-2-1i, 1+1i].
%       for the generated image. For example, [-2, 1] would produce an
%       image that ranges from -2 to 1 along the real axis.
%    N is the number of points to calculate along the real axis. The number
%       of points along the imaginary axis will be chosen in proportion to
%       the Rlim and Ilim: 
%           Ny = round(N * diff(real(clim))/diff(imag(clim))
%       Default is 1000.
%    maxIter is the maximum number of iterations of the generating equation
%       z => z^2 + c to run before adding a point to the mandelbrot set.
%       Default is 100. This can also be set using the text box in the GUI.
%    ax is intended for internal use, and should not normally be supplied
%       by the user.
%    escape is the 2D image displayed by the viewer. It is an array of 
%       integers indicating how many iterations it took for each point in 
%       the complex plane to escape. Points that did not escape (and are 
%       thus candidates for the mandelbrot set) will have value equal to 
%       maxIter.
%
% This is a simple mandelbrot set viewer. It will display an image of the 
%   mandelbrot set (and the surrounding escape boundaries) for an
%   arbitrary region of the complex plane. To zoom in, use the native zoom
%   control on the figure, then click the "Recalculate" button. The
%   "engine" that does the calculation is the mandelbrot function.
%
% See also: mandelbrot
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('ax', 'var') || isempty(ax) || ~isvalid(ax)
    % Axes were not provided - create some.
    
    % If paramters are not provided, use defaults.
    if ~exist('clim', 'var') || isempty(clim)
        clim = [-2-1i, 1+1i];
    end
    if ~exist('N', 'var') || isempty(N)
        N = 1000;
    end
    if ~exist('maxIter', 'var') || isempty(maxIter)
        maxIter = 100;
    end
    
    % No axes provided - create a figure
    f = figure;
    f.WindowState = 'fullscreen';
    
    % Create axes
    ax = axes(f);
    ax.Units = 'normalized';
    
    % Store convenient reference to axes in figure UserData
    f.UserData.displayAxes = ax;
    % Add recalc button and store in figure UserData
    buttonPosition = [ax.Position(1), ax.Position(2)/2, 0.3, ax.Position(2)/2.1];
    recalcButton = uicontrol('Parent', f, 'String', 'Recalculate', 'Style', 'pushbutton', 'Units', 'normalized', 'Position', buttonPosition, 'Callback', @refresh);
    f.UserData.recalcButton = recalcButton;
    % Add maxIter field and store in figure UserData
    editPosition = [ax.Position(1) + 0.3 + 0.05, ax.Position(2)/2, 0.3, ax.Position(2)/2.1];
    iterEntry = uicontrol('Parent', f, 'String', num2str(maxIter), 'Style', 'edit', 'Units', 'normalized', 'Position', editPosition);
    f.UserData.iterEntry = iterEntry;
    f.UserData.climHistory = {};
    f.UserData.climHistoryIndex = [];
else
    % Axes were provided
    f = ax.Parent;
    
    % Get clim from the axes xlim and ylim
    clim = xlim(ax) + 1i*ylim(ax);
    
%     if clim ~= f.UserData.climHistory{end}
%         f.UserData.climHistory{end+1} = clim;
%     end
    
    % If not provided, get parameters from figure UserData
    if ~exist('N', 'var') || isempty(N)
        N = f.UserData.N;
    end
    if ~exist('maxIter', 'var') || isempty(maxIter)
        maxIter = f.UserData.maxIter;
    end
end

% Store current parameters in figure UserData
f.UserData.maxIter = maxIter;
f.UserData.N = N;

Rlim = real(clim);
Ilim = imag(clim);

escape = mandelbrot(Rlim, Ilim, N, maxIter, true);

escape = imadjust(escape / maxIter);

cla(ax);

xlim(ax, Rlim);
ylim(ax, Ilim);
axis(ax, 'image');
imagesc(ax, 'XData', Rlim, 'YData', Ilim, 'CData', escape);
colormap(ax, 'jet');

function refresh(source, ~)
disp('Recalculating...')
f = source.Parent;
ax = f.UserData.displayAxes;
maxIter = str2double(f.UserData.iterEntry.String);
mandelbrotViewer([], [], maxIter, ax);