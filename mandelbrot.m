function escape = mandelbrot(Rlim, Ilim, N, maxIter, verbose)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mandelbrot: generate an image of the mandelbrot set
% usage:  escape = mandelbrot(Rlim, Ilim, N, maxIter, verbose)
%
% where,
%    escape is a 2D array of integers indicating how many iterations it
%       took for each point in the complex plane to escape. Points that did
%       not escape (and are thus candidates for the mandelbrot set) will
%       have value equal to maxIter.
%    Rlim is a 1x2 array of numbers indicating the desired real-axis limits
%       for the generated image. For example, [-2, 1] would produce an
%       image that ranges from -2 to 1 along the real axis.
%    Ilim is a 1x2 array of numbers indicating the desired imaginary-axis 
%       limits for the generated image. For example, [-1, 1] would produce 
%       an image that ranges from -1 to 1 along the imaginary axis.
%    N is the number of points to calculate along the real axis. The number
%       of points along the imaginary axis will be chosen in proportion to
%       the Rlim and Ilim: Ny = round(N * diff(Ilim)/diff(Rlim))
%    maxIter is the maximum number of iterations of the generating equation
%       z => z^2 + c to run before adding a point to the mandelbrot set.
%    verbose is an optional boolean flag indicating whether or not to print
%       out progress to the console. Default is false
%
% This is a mandelbrot set calculator. It will generate an image of the 
%   mandelbrot set (and the surrounding escape boundaries) for an
%   arbitrary region of the complex plane. It's as optimized as I could
%   figure out how to make it!
%
% See also: mandelbrotViewer
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('verbose', 'var') || isempty(verbose)
    verbose = false;
end

threshold = 4;

Nx = N;
Ny = round(N * diff(Ilim)/diff(Rlim));

% Create grids of real and imaginary C values
[X, Y] = meshgrid(linspace(Rlim(1), Rlim(2), Nx), linspace(Ilim(1), Ilim(2), Ny));

C = X+1i*Y;

gridSize = size(C);

% Flatten arrays
C = C(:);

% Set up initial Z array
Z = C;

data = [Z, C];

% Set up escape array to accept escape iteration values. By default, set
% all values to maximum iteration value so anything that never escapes is
% already set.
escape = maxIter * ones(size(C));
escapeIdx = 1:length(C);

% Iterate
for iterationNum = 1:maxIter
    if verbose
        displayProgress('Iteration #%d of %d\n', iterationNum, maxIter, 20);
    end
    
    % Get 1D mask of values that have escaped
    escapeMask = data(:, 1).*conj(data(:, 1)) > threshold;
    
    % Assign escape array values based on current iteration number
    escape(escapeIdx(escapeMask)) = iterationNum-1;
    
    % Get mask of unescaped values
    unescapeMask = ~escapeMask;
    
    % Slice down indices, C values, and Z values to eliminate already
    % escaped values, for computing speed.
    data = data(unescapeMask, :);
    escapeIdx = escapeIdx(unescapeMask);

    % If this is not the last iteration, apply the Z transformation
    if iterationNum < maxIter
        data(:, 1) = data(:, 1).^2 + data(:, 2);
    end
end

escape = reshape(escape, gridSize);