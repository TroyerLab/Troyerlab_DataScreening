% inout specification

paths={''};

inp1='batch_feedback_sample_60';  
inp2='G:\5046\5046_2015_05_12\feedback_files\';
inp3='y';
% inp4=3.1;
% inp5=44150.11;
% inp6=1;
% inp7='5046_baseline_template.dat';
% inp8='G:\5046\4_29_15_experiment_sample\';
% inp7='C:\Users\onh191\Dropbox\wavnotmat_files\';
param1='amplitude_threshold';
val1=5000;
param2='min_syll_dur';
val2=10;
param3='min_gap_dur';
val3=10;
% param4='disk_write_dir';
% val4=inp1;
% param5='write_file_name';
% val5='singing_thru_day.fig';

% function definition and call
func=@write_notmat_from_audio;

func(inp1,inp2,inp3,param1,val1,param2,val2,param3,val3); 

% example function function call
% [op1,op2,op2]=func(inp1,inp2,inp3,inp4,inp5,inp6,inp7,param1,val1,param2,val2,param3,val3); 
