% writes three batch files:
% batch_catch_w_feedback
% batch_feedback
% batch_non_feedback

clear all

prob_path=pwd;
wild_card='*.cbin';
files_dir=uigetdir(prob_path,'Please select where the file are located');

tic
files=dir([files_dir filesep wild_card]);
no_files=length(files);

feedback_filelist_catch=cell(0);
feedback_filelist=cell(0);
non_noise_filelist=cell(0);

for i=1:no_files
          
    if any(strcmpi(files(i).name,{'.','..'}))
        continue
    end
    [~,nm,~]=fileparts(files(i).name);
    recfile=[files_dir filesep nm '.rec'];
    recdata=readrecf(recfile);
    
    if recdata.iscatch && ~isempty(recdata.ttimes)
        feedback_filelist_catch=[feedback_filelist_catch;files(i).name];
        non_noise_filelist=[non_noise_filelist;files(i).name];
    elseif ~isempty(recdata.ttimes)
        feedback_filelist=[feedback_filelist;files(i).name];
    else
        non_noise_filelist=[non_noise_filelist;files(i).name];
    end
    
end

fprintf(['Number of catch files with suppressed noise feedback was= ' num2str(length(feedback_filelist_catch)) '\n'])
fprintf(['Number of files with noise feedback was= ' num2str(length(feedback_filelist)) '\n'])
fprintf(['Number of files without any noise feedback was= ' num2str(length(non_noise_filelist)) '\n'])

toc

write_batch_from_filelist(feedback_filelist_catch,'batch_feedback_catch',files_dir,'spawning_func',mfilename('fullpath'))
write_batch_from_filelist(feedback_filelist,'batch_feedback',files_dir,'spawning_func',mfilename('fullpath'))
write_batch_from_filelist(non_noise_filelist,'batch_non_noise',files_dir,'spawning_func',mfilename('fullpath'))


