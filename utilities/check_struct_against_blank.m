function []=check_struct_against_blank(test_struct,blank_struct_fun,varargin)
%% Syntax
%
% check_struct_against_blank(test_struct,blank_struct_fun,varargin)
%
%% Inputs  
% test_struct -  the struct created in a function which needs to be tested
% against the blank struct
%
% blank_struct_fun - the function handle of the function that holds the code for creating the
% blank struct
%
%% Computation/Processing     
% compares the test struct against the struct created by the function.
% It throws an error if the test struct does not have all the fields that 
% are present in the true struct. It throws a warning if the test struct
% has more fields than the treu struct and also is it has a different name
% than the true struct. 
%
%
% 
%
%% Outputs  
% throws an error if the test struct and the true struct don't match
% exactly
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
% Last modified by Anand S. Kulkarni on 
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
narg_min=2;


in_message1='Please enter the name of the variable holding the struct';
in_message2='Please enter the function handle of the function that creates the blank version of that struct. e.g. @create_blank_datastruct_template_metadata';

if nargin<narg_min
     test_struct=input([in_message1 '\n-->  ']); 
     blank_struct_fun=input([in_message2 '\n-->  ']); 
end

% packaging the inputs into the inputs structure. This can be useful in
% case you need to store the inputs as meta-data with the output. 
inputs=struct('test_struct',test_struct,'blank_struct_fun',blank_struct_fun);

% processing supplementary inputs

% Assigning default values to supplementary inputs
supp_inputs.write_to_disk_q=0; % should the function write a file to disk containing its output  
supp_inputs.disk_write_dir='';


supp_inputs=parse_pv_pairs(supp_inputs,varargin);

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
if supp_inputs.write_to_disk_q
    if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
        supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
    end
end

%% Body of the function
[true_struct,true_struct_name]=blank_struct_fun();

test_struct=orderfields(test_struct); 
true_struct=orderfields(true_struct); 

true_fields=fieldnames(true_struct);
test_fields=fieldnames(test_struct);

no_true_fields=length(true_fields);

for i=1:no_true_fields
   if isempty(find(strcmpi(true_fields{i},test_fields),1))
       error(['The supplied structure does not contain the field ' true_fields{i}])
   end    
end

if length(true_fields)~=length(test_fields)
   warning('The supplied structure contains all the fields in the blank struct. However it contains additional fields as well.')   
end

test_struct_name=inputname(1);
if ~strcmpi(true_struct_name,test_struct_name)
   warning('The supplied structure does not have the same name as the structure created by the function.')   
end

