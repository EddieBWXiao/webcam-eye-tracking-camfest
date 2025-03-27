function parse_et(fname, trial_idx)
% Bowen Xiao (Eddie) 2025, for CamFest demo visuals
%% load the json; gets ntrials x 1 cell array of structs
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
raw = jsondecode(str);

%% select the eye-tracking trials
sel_et = cellfun(@(x) isfield(x,'webgazer_data'),raw);
dET = raw(sel_et);
sel_phase = cellfun(@(x) ~strcmp(x.phase,'CirclesCheck'),dET);
dET = dET(sel_phase);

dtrial = dET{trial_idx};

% extract x-y
x = [dtrial.webgazer_data(:).x];
y = [dtrial.webgazer_data(:).y];

figure;
hold on;

% plot et data
plot(x,y,'r-o')

% extract the target info
the_target = dtrial.webgazer_targets.x_the_view_img;

% Draw the rectangle defined by the target
% Using the rectangle function to draw the target area
rect_x = the_target.left;
rect_y = the_target.top;
rect_width = the_target.width;
rect_height = the_target.height;

% overlay on images
img = imread('unexpected-visitors-compressed.jpg');
% Display the image at the rectangle position
h_img = image([rect_x, rect_x+rect_width], [rect_y, rect_y+rect_height], img);
uistack(h_img, 'bottom'); % Put the image behind the eye tracking data
axis image

% Flip the y-axis
set(gca, 'YDir', 'reverse');

hold off

%% ====== save the image =======
% Create output filename by replacing .json with .png and adding trial_idx suffix
disp('Saving image...');
[~, baseName, ~] = fileparts(fname);
output_filename = strcat(baseName, '_trial', num2str(trial_idx), '.jpg');

% Save the plot as a PNG file
% First resize the figure window to match the desired dimensions
set(gcf, 'Position', [100, 100, round(rect_width/1.8), round(rect_height/1.8)]);
saveas(gcf, output_filename, 'jpg');
end