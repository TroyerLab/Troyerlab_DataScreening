function []=calc_screening_ftrs_dists(filename,filepath,requested_ftrs,varargin)
%% Syntax
%
% []=calc_screening_ftr_dists(filename,filepath,requested_ftrs,varargin)
%
%% Inputs  
%
%
%
%
%% Computation/Processing     
% 
%
%
% 
%
%% Outputs  
% 
% 
%
%
%% Assumptions
% It is assumed in some later functions that the variable
% classification_label is a number and not a character. 
%
%
%
% % % Triple percentage sign indicates that the code is part of the code
% template and may be activated if necessary in later versions. 
%% Version and Author Identity Notes  
% 
% Last modified by The Big Foot on 1/1/1400
% 
% previous version:
% next version: 
%% Related procedures and functions 
% 
%
%
%
%% Detailed notes
%
%
%
%
%% Processing inputs and beginning stuff

% putting in a stop for easier debugging
dbstop if error

% processing mandatory inputs
narg_min=3;
prob_path=pwd;
ftrs_available={'weiner_entropy','amplitude','note_durations','gap_durations','amplitude_two_channel_difference'};

% Assigning default values to supplementary inputs
% channel specification
supp_inputs.chanspec='0';
supp_inputs.chan2spec='';
% filtering and smoothing specifications
supp_inputs.filter_type='hanningfir';
supp_inputs.bandpass_freq_min=500;
supp_inputs.bandpass_freq_max=10000;
supp_inputs.sm_win=2;
% Spectrogram specifications
supp_inputs.nfft=512;
supp_inputs.olap=0.8;
% segmentation specifications
supp_inputs.amplitude_threshold=10000;
supp_inputs.min_syll_dur=30;
supp_inputs.min_gap_dur=5;
supp_inputs.prc_vec=(0:1:100);
% Feature calculation frequency range
supp_inputs.wentropy_freqrange=[0 20];
supp_inputs.amplitude_freqrange=[0,20];
% should the function write the output as a single consolidated file or
% write a single .mat file for each audio file
supp_inputs.write_consolidated=0;

supp_inputs.write_to_disk_q=0; % should the function write a file to disk containing its output  
supp_inputs.disk_write_dir='';


list=[];
for i=1:length(ftrs_available)
    list=[list,ftrs_available{i} '\n'];
end
in_message1='Please select a batch file containing a list of audio files you want to screen';
in_message2='Please enter the features (from the list given below) you want to calculate for these files. e.g {''weiner_entropy'',''note_durations''}.\nNote that this input is a cell array.';
in_message3='Please enter the channel specification of the other channel';
if nargin<narg_min
     [filename,filepath]=uigetfile([prob_path filesep '*.*'],in_message1);   
     requested_ftrs=input([in_message2 '\n' list '\n-->  ']);
     
     supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
     supp_inputs.disk_write_dir=filepath;
     if ismember('amplitude_two_channel_difference',requested_ftrs)
         supp_inputs.chan2spec=input([in_message3 '\n-->  '],'s');
     end
     % Processing supplementary inputs
     [supp_inputs]=process_supplementary_inputs(supp_inputs); 
else
     supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
     supp_inputs.disk_write_dir=filepath;
     % processing supplementary inputs
    supp_inputs=parse_pv_pairs(supp_inputs,varargin);
     
     if ismember('amplitude_two_channel_difference',requested_ftrs)
         if isempty(supp_inputs.chan2spec)
            error('Chan2spec must be specified when requesting feature amplitude_two_channel_difference')
         end         
     end   
end

% Checking if output directories need to specified and if they have been specified 
if supp_inputs.write_to_disk_q
    if ~exist(supp_inputs.disk_write_dir,'dir')
        supp_inputs.disk_write_dir=uigetdir('Please select the directory where to store the output mat file. Hit cancel if you don''t want the function to write a mat file');
        if supp_inputs.disk_write_dir==0
            supp_inputs.write_to_disk_q=0;
        end
    end
end

% putting file separators at the end of all input paths
if ~isempty(filepath)
    if ~strcmpi(filepath(end),filesep)
        filepath=[filepath,filesep];
    end
end

if supp_inputs.write_to_disk_q
    if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
        supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
    end
end


%% Body of the function

[files]=make_filelist_from_batch(filename,filepath);
no_files=length(files);
no_req_ftrs=length(requested_ftrs);
prc_vec=supp_inputs.prc_vec;
temp_screening_ftrs_dists=[];
yy=waitbar(0,'Calculating screening ftrs');

for i=1:no_files
   
    curr_file=files{i};
    
    % reading data in
    [data,fs,DOFILT,~] = ReadDataFile([filepath curr_file],supp_inputs.chanspec,0);
    
    % filtering, squaring, and smoothing data
    [smooth,spec,~,f]=SmoothData(data,fs,'DOFILT',DOFILT,'filter_type',supp_inputs.filter_type,'nfft',supp_inputs.nfft,...
                                 'olap',supp_inputs.olap,'sm_win',supp_inputs.sm_win,'F_low',supp_inputs.bandpass_freq_min,...
                                 'F_high',supp_inputs.bandpass_freq_max,'specOff',0);
    f = f/1000; % Converts from Hz. to KHz. as needed by ftr_wentropy
    
    % segmenting data
     if ismember('note_durations',requested_ftrs)|| ismember('gap_durations',requested_ftrs)
         [onsets, offsets] = SegmentNotes(smooth,fs,supp_inputs.min_syll_dur,...
                                     supp_inputs.min_gap_dur,supp_inputs.amplitude_threshold);
        onsets=onsets*1e3;
        offsets=offsets*1e3;  
     end
     
     for j=1:no_req_ftrs
         switch requested_ftrs{j}
             case 'weiner_entropy'
                 weiner_entropy = ftr_Wentropy(spec,f,'freqrange',supp_inputs.wentropy_freqrange); % Calculates weiner entropy
                 screening_ftrs_dists.ftr_dist_weiner_entropy=prctile(weiner_entropy,supp_inputs.prc_vec);
             case 'amplitude'
                  amplitude=ftr_amp(spec,f,'freqrange',supp_inputs.amplitude_freqrange); % Calculate Amplitude      
                  screening_ftrs_dists.ftr_dist_amplitude=prctile(amplitude,supp_inputs.prc_vec);
             case 'note_durations'
                   note_durations=offsets-onsets; % calculating note durations
                   screening_ftrs_dists.ftr_dist_note_durations=prctile(note_durations,supp_inputs.prc_vec);                 
             case 'gap_durations'
                 gap_durations=onsets(2:end)-offsets(1:end-1); % calculating gap durations
                 screening_ftrs_dists.ftr_dist_gap_durations=prctile(gap_durations,supp_inputs.prc_vec);
                 
             case 'amplitude_two_channel_difference'                 
                 % reading data in
                [data2,~,~,~] = ReadDataFile([filepath curr_file],supp_inputs.chan2spec,0);
    
                % filtering, squaring, and smoothing data
                [~,spec2,~,~]=SmoothData(data2,fs,'DOFILT',DOFILT,'filter_type',supp_inputs.filter_type,'nfft',supp_inputs.nfft,...
                                 'olap',supp_inputs.olap,'sm_win',supp_inputs.sm_win,'F_low',supp_inputs.bandpass_freq_min,...
                                 'F_high',supp_inputs.bandpass_freq_max,'specOff',0);
                             
                 amplitude=ftr_amp(spec,f,'freqrange',supp_inputs.amplitude_freqrange); % Calculate Amplitude      
                 amplitude2=ftr_amp(spec2,f,'freqrange',supp_inputs.amplitude_freqrange); % Calculate Amplitude      
                 screening_ftrs_dists.ftr_dist_amplitude_two_channel_difference=prctile(amplitude-amplitude2,supp_inputs.prc_vec);       
                 
             otherwise
                 
                error(['The program does not recognize the feature ' requested_ftrs{j}])
         end        
     end
     
    screening_ftrs_dists.filename=curr_file;  
    screening_ftrs_dists.classification_label=0;
    
    if supp_inputs.write_consolidated==0        
        [~,nm,~]=fileparts(curr_file);
        matfile=[nm '_screening_ftrs_dists.mat'];
        matfullfile=[supp_inputs.disk_write_dir  matfile];
        save(matfullfile,'prc_vec','screening_ftrs_dists');   
    elseif supp_inputs.write_consolidated==1
        temp_screening_ftrs_dists=[temp_screening_ftrs_dists;screening_ftrs_dists];
    else
       error('Incorrect value for  supp_inputs.write_consolidated') 
    end   
    
    
    waitbar(i/no_files,yy)
    
end

if supp_inputs.write_consolidated==1
    [nm,pt]=uiputfile([filepath '*.mat'],'What name do you want to give to this screening features ditributions file?',[filename '_screening_ftrs_dists']);
    screening_ftrs_dists=temp_screening_ftrs_dists;
    save([pt nm],'prc_vec','screening_ftrs_dists')     
end

close(yy)

