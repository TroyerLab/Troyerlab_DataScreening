function []=label_notmat_from_bmk_lbk(bmk_name,bmk_path,lbl_name,lbl_path)
%% Syntax
%
% []=label_notmat_from_bmk_lbk(bmk_name,bmk_path,lbl_name,lbl_path)s
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
%
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
narg_min=4;

prob_path=pwd;
% prob_path2=pwd;
% options_available={'option1','option2','option3'};
% 
% % Assigning default values to supplementary inputs
% supp_inputs.sinp1=42;
% supp_inputs.sinp2='everything';
% supp_inputs.sinp3='';
% 
% list=[];
% for i=1:length(options_available)
%     list=[list,options_available{i} '\n'];
% end

in_message1='Please select the bmk file';
in_message2='Please select the lbl file';
% in_message3='Please enter a string input';
% in_message4='Please select a non-string input';
% in_message5='Please select among the following options:';
if nargin<narg_min
    % error(['The number of inputs should at least be ' narg_min])
     [bmk_name,bmk_path]=uigetfile([prob_path filesep '*.bmk'],in_message1);   % file input
     [lbl_name,lbl_path]=uigetfile([prob_path filesep '*.lbl'],in_message2); 
%      inp3=uigetdir(prob_path2,in_message2); % directory input
%      inp4=input([in_message3 '\n-->  '],'s'); % string input
%      inp5=input([in_message4 '\n-->  ']); % non string input
%      inp6=input([in_message5 '\n' list '\n-->  '],'s');
%      
%      % sets defaults
%      supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
%      supp_inputs.disk_write_dir=bmk_path;
%      % Processing supplementary inputs
%      [supp_inputs]=process_supplementary_inputs(supp_inputs);   
% else
%      % sets defaults
%      supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
%      supp_inputs.disk_write_dir=bmk_path;
%     % processing supplementary inputs
%     supp_inputs=parse_pv_pairs(supp_inputs,varargin);
end

% packaging the inputs into the inputs structure. This can be useful in
% case you need to store the inputs as meta-data with the output. 
% inputs=struct('inp1',bmk_name,'inp2',bmk_path,'inp3',inp3,'inp4',inp4,'inp5',inp5,'inp6',inp6);

% Checking if output directories need to specified and if they have been specified 

% if supp_inputs.write_to_disk_q
%     if ~exist(supp_inputs.disk_write_dir,'dir')
%         supp_inputs.disk_write_dir=uigetdir(prob_path,'Please select the directory where to store the output mat file. Hit cancel if you don''t want the function to write a mat file');
%         if supp_inputs.disk_write_dir==0
%             supp_inputs.write_to_disk_q=0;
%         end
%     end
% end

% putting file separators at the end of all input paths
% if ~isempty(bmk_path)
%     if ~strcmpi(bmk_path(end),filesep)
%         bmk_path=[bmk_path,filesep];
%     end
% end


% if ~isempty(inp3)
%     if ~strcmpi(inp3(end),filesep)
%         inp3=[inp3,filesep];
%     end
% end
% 
% if supp_inputs.write_to_disk_q
%     if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
%         supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
%     end
% end
% 
% 
% % creating a figure and axes
% fig1=figure;
% axes1=axes('parent',fig1);

%% Body of the function
load([bmk_path bmk_name],'-mat') % loads clips and songs variable
load([lbl_path lbl_name],'-mat')% loads labels
bmk_labels=labels;

for i=1:length(songs.a)
   filename=songs.a(i).filename;
   notmat_file=[songs.datapath filename '.not.mat'];
   load(notmat_file);% loads labels var
   if length(labels)~=songs.a(i).clipnum
       error('unequal clips')
   end
   labels=[bmk_labels.a(songs.a(i).startclip:songs.a(i).endclip).label];
   save(notmat_file,'labels','-append')
    
end




% dummy plotting 
% plot(axes1,1,1,'or')
% 
% %% Processing outputs 
% arch_timestamp=datestr(now,'yyyy-mmm-dd HH:MM:SS');
% inputs=setfield('var1',var1); % any additional inputs collected during the function
% arch_inputs=inputs;
% arch_supp_inputs=supp_inputs;
% 
% if supp_inputs.write_to_disk_q==1
%     matfile='function_output.mat';
%     matfullfile=[supp_inputs.disk_write_dir  matfile];
%     save(matfullfile,'outvar');
%     % alternative save: save(matfullfile,'outvar','arch_inputs','arch_supp_inputs','arch_timestamp');
%     figfile='function_plot.fig';
%     figfullfile={[supp_inputs.disk_write_dir  figfile]};
%     saveas(fig1,figfullfile);
% end

