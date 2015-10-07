function varargout = select_screening_thresholds(varargin)
% SELECT_SCREENING_THRESHOLDS MATLAB code for select_screening_thresholds.fig
%      SELECT_SCREENING_THRESHOLDS, by itself, creates a new SELECT_SCREENING_THRESHOLDS or raises the existing
%      singleton*.
%
%      H = SELECT_SCREENING_THRESHOLDS returns the handle to a new SELECT_SCREENING_THRESHOLDS or the handle to
%      the existing singleton*.
%
%      SELECT_SCREENING_THRESHOLDS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_SCREENING_THRESHOLDS.M with the given input arguments.
%
%      SELECT_SCREENING_THRESHOLDS('Property','Value',...) creates a new SELECT_SCREENING_THRESHOLDS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_screening_thresholds_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_screening_thresholds_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% ASSUMPTIONS
% This code assumes that the ftrs contain just a single number and not a
% vector or a matrix. 
% It also assumes that the classification labels are numbers
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_screening_thresholds

% Last Modified by GUIDE v2.5 02-Jul-2015 15:08:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_screening_thresholds_OpeningFcn, ...
                   'gui_OutputFcn',  @select_screening_thresholds_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before select_screening_thresholds is made visible.
function select_screening_thresholds_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to select_screening_thresholds (see VARARGIN)

% Choose default command line output for select_screening_thresholds
handles.output = hObject;

prob_path=pwd;
nargin_min=3+1; % three 'hObject, eventdata, handles' + 'varargin'
in_message1=['Would you like load a batch file or a .mat file containing the\n'...
             'screening features or their distributions for all the relevant files.\n'...
             'Enter 1 for batch file and 0 for .mat screening file'];
in_message2='Please select the relevant file';
in_message_3='Please select a selected features file. If you don''t want to select one, click cancel';
if nargin<nargin_min 
    is_batch=input([in_message1 '\n-->  ']); 
    [fname,fpath]=uigetfile([prob_path filesep '*.*'],in_message2); 
    [selected_ftrs_file,selected_ftrs_path]=uigetfile([prob_path filesep '*.mat'],in_message_3);
else
    is_batch=varargin{1};
    fname=varargin{2};
    fpath=varargin{3};
    selected_ftrs_file=varargin{4};
    selected_ftrs_path=varargin{5};
end

% calculating screening_ftrs
[screening_ftrs,classification_labels_present]=aggregate_screening_ftrs(is_batch,fname,fpath,selected_ftrs_file,selected_ftrs_path);

% determining ftrs
names=fieldnames(screening_ftrs);
ftrs=cell(0);
ftr_str='ftr_';
for i=1:length(names)
    if length(names{i})>=length(ftr_str)
        if strcmpi(names{i}(1:length(ftr_str)),ftr_str)
            if ~(length(screening_ftrs(1).(names{i}))>1)                
                ftrs=[ftrs;names{i}];
            else
               error(['A feature ' names{i} ' does not have a single value. It may be amatrix or a vector']) 
            end
        end
    end
end

% setting handles fields
handles.primary_label=1; % This is the symbol of the label for which you will specify thresholds
handles.secondary_label=0; % This is the symbol of the label other than the primary label
handles.classification_labels={[handles.primary_label],[handles.secondary_label]};

handles.fname=fname;
handles.fpath=fpath;
[~,handles.fname_raw,~]=fileparts(handles.fname);
handles.ftrs=ftrs;
handles.screening_ftrs=screening_ftrs;
% handles.classification_labels=classification_labels_present;
handles.screening_ftrs(end).thr_based_label=[];
handles.screening_ftrs(end).label_comparison=[];
handles.operators={'>','>=','<','<=','==','~='};
handles.no_bins=50;

% setting callback on the table specifying thresholds
set(handles.threshold_spec_uitable,'celleditcallback',@thr_spec_edited_cells_callback)

% setting defaults on all ui elements
handles=set_defaults_on_ui_elements(handles);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes select_screening_thresholds wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = select_screening_thresholds_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important internal functions and callbacks: START
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% UI CALLBACKS: START  

% --- Executes on button press in resize_table_pushbutton.
function resize_table_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resize_table_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
table_objects=[handles.threshold_spec_uitable,handles.compare_labels_uitable,handles.show_labels_uitable];

for i=1:length(table_objects)
    init_position=get(table_objects(i),'position');
    init_extent=get(table_objects(i),'extent');
    set(table_objects(i),'position',[init_position(1:2),init_extent(3:4)]);
end
guidata(hObject,handles)


function thr_spec_edited_cells_callback(hObject,callbackdata)
if ~isempty(callbackdata.Error)
    warningdlg('There seems to be an error in the changed value in the table','','modal');
    return
end
handles=guidata(hObject);
handles=disable_interactive_elements(handles);

row_no=callbackdata.Indices(1);
col_no=callbackdata.Indices(2);

switch col_no
    case{2,4,6}
        if col_no==2
           handles=thr_type_callback(handles,callbackdata);
        end
        handles=verify_thresholds_params_validity(handles,row_no);
       
    case 8
        handles=ftr_include_callback(handles,callbackdata);

end

handles=refresh_ftr_axes(handles);
handles=enable_interactive_elements(handles);
guidata(hObject,handles)


% --- Executes when selected object is changed in plot_control_uipanel.
function handles=plot_control_uipanel_SelectionChangeFcn(~,~, handles)
% hObject    handle to the selected object in plot_control_uipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles=disable_interactive_elements(handles);
new_obj=get(handles.plot_control_uipanel,'selectedobject');
switch new_obj
    case handles.show_labels_radiobutton
        disable_eles=[(get(handles.compare_labels_uipanel,'Children'))',handles.compare_labels_uitable];
        enable_eles=[(get(handles.show_labels_uipanel,'Children'))',handles.show_labels_uitable];
        handles.show_labels=0;
    case handles.compare_labels_radiobutton
        disable_eles=[(get(handles.show_labels_uipanel,'Children'))',handles.show_labels_uitable];
        enable_eles=[(get(handles.compare_labels_uipanel,'Children'))',handles.compare_labels_uitable];
        handles.show_labels=1;
end
set(disable_eles,'enable','off')
set(enable_eles,'enable','on')

handles=refresh_ftr_axes(handles);
handles=enable_interactive_elements(handles);
guidata(handles.plot_control_uipanel,handles)



% --- Executes when selected object is changed in show_labels_uipanel.
function handles=show_labels_uipanel_SelectionChangeFcn(~, ~, handles)
% hObject    handle to the selected object in show_labels_uipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles=disable_interactive_elements(handles);

new_obj=get(handles.show_labels_uipanel,'selectedobject');
switch new_obj
    case handles.show_file_labels_radiobutton
        handles.show_file_labels=0;
    case handles.show_selected_threshold_based_labels_radiobutton
        handles.show_file_labels=1;
    case handles.show_all_valid_threshold_based_labels_radiobutton
         handles.show_file_labels=2;
end

handles=refresh_ftr_axes(handles);
handles=enable_interactive_elements(handles);
guidata(handles.plot_control_uipanel,handles)


% --- Executes when selected object is changed in compare_labels_uipanel.
function handles=compare_labels_uipanel_SelectionChangeFcn(~, ~, handles)
% hObject    handle to the selected object in compare_labels_uipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles=disable_interactive_elements(handles);

new_obj=get(handles.compare_labels_uipanel,'selectedobject');
switch new_obj
    case handles.use_selected_thresholds_radiobutton
         handles.use_selected_thresholds=0;
    case handles.use_valid_thresholds_radiobutton
        handles.use_selected_thresholds=1;
end

handles=refresh_ftr_axes(handles);
handles=enable_interactive_elements(handles);
guidata(handles.plot_control_uipanel,handles)


% --- Executes on button press in write_thr_file_pushbutton.
function write_thr_file_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to write_thr_file_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valid_thrs_inds=find(handles.thr_setting_validity_info,1);
if isempty(valid_thrs_inds)
   warndlg('No valid thresholds selected','','modal') 
   return
end
threshold_criteria=make_thr_criteria(handles,1);

[out_filename,out_pathname]=uiputfile([fullfile(handles.fpath,handles.fname_raw) '_thresholds_file_*'],'Please select the name and location of the thresholds file','');
save([out_pathname out_filename],'threshold_criteria');



% --- Executes on button press in load_thresholds_file_pushbutton.
function load_thresholds_file_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_thresholds_file_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_str=get(hObject,'String');
if strcmpi(button_str,'Load Thresholds File')
    set(hObject,'string','Exit Threshold Evaluation')
    [filename,filepath]=uigetfile([handles.fpath filesep '*.mat'],'Please select the thresholds file');
    load([filepath filename]) % loads variable called threshold_criteria
    % setting up the table
    spec_thr_col_editable=logical([0,0,0,0,0,0,0,1]);
    spec_threshold_column_formats={'char','char','char','char','char','char','char','logical'};
    set(handles.threshold_spec_uitable,'columneditable',spec_thr_col_editable,...
                                   'columnformat',spec_threshold_column_formats);  
   no_ftrs=length(threshold_criteria);
   for i=1:no_ftrs
       ftr{i,1}=threshold_criteria(i).ftr;
       thr_type{i,1}=threshold_criteria(i).thr_type;
       thr_param_1_desc{i,1}=threshold_criteria(i).thr_param_1_desc;
       thr_param_1{i,1}=num2str(threshold_criteria(i).thr_param_1);
       thr_param_2_desc{i,1}=threshold_criteria(i).thr_param_2_desc;
       thr_param_2{i,1}=num2str(threshold_criteria(i).thr_param_2);     
       validity{i,1}='invalid';
       include_state{i,1}=false;
   end
    spec_thr_data=[ftr,thr_type,thr_param_1_desc,thr_param_1,thr_param_2_desc,thr_param_2,validity,include_state]; 
    set(handles.threshold_spec_uitable,'data',spec_thr_data);
    [handles]=verify_thresholds_params_validity(handles,(1:no_ftrs));
    % setting defaults
    cla(handles.ftr_axes,'reset')
    handles.included_ftrs=false(1,no_ftrs);    
    compare_labels_init_data=cell(3,3);
    set(handles.compare_labels_uitable,'data',compare_labels_init_data)
    no_labels=length(handles.classification_labels);
    if ~iscolumn(handles.classification_labels)
        show_labels_data=[handles.classification_labels',cell(no_labels,1)];
    else
        show_labels_data=[handles.classification_labels;cell(no_labels,1)];
    end    
    
    set(handles.show_labels_uitable,'data',show_labels_data);


    
elseif strcmpi(button_str,'Exit Threshold Evaluation')
    set(hObject,'string','Load Thresholds File')
    [handles]=set_defaults_on_ui_elements(handles);
end
guidata(hObject,handles)






% UI CALLBACKS: END                          






% INTERNAL WORKHORSE FUNCTIONS: START


function [handles]=thr_type_callback(handles,callbackdata)
% setting the thr param descriptions
row_no=callbackdata.Indices(1);
selected_ftr=callbackdata.NewData ;

switch  selected_ftr
    case 'none'
        thr_param1_desc=[];
        thr_param2_desc=[];        
    case 'one bound'
        thr_param1_desc='Bound';
        thr_param2_desc='Relation';
    case 'two bounds within'
        thr_param1_desc='Bound 1';
        thr_param2_desc='Bound 2';
    case 'two bounds outside'
        thr_param1_desc='Bound 1';
        thr_param2_desc='Bound 2';
    case 'distance within'
        thr_param1_desc='Center';
        thr_param2_desc='Distance';
    case 'distance outside'
        thr_param1_desc='Center';
        thr_param2_desc='Distance';
end

refresh_table_data(handles.threshold_spec_uitable,{[row_no,3],[row_no,5]},{thr_param1_desc,thr_param2_desc});

 






function [handles]=verify_thresholds_params_validity(handles,row_nos)

uitable_data=get(handles.threshold_spec_uitable,'data');

for i=1:length(row_nos)
    row_no=row_nos(i);
    

    selected_ftr=uitable_data{row_no,2} ;
    thr_param1=uitable_data{row_no,4} ;
    thr_param2=uitable_data{row_no,6} ;
    thr_param1_num=str2double(thr_param1);
    thr_param2_num=str2double(thr_param2);

    isvalid=0;

    switch  selected_ftr
        case 'one bound'
          if all ([isnumeric(thr_param1_num),~isnan(thr_param1_num),ismember(thr_param2,handles.operators)]) 
               isvalid=1; 
          end
        case 'two bounds within'
            if all([isnumeric([thr_param1_num,thr_param2_num]),~isnan([thr_param1_num,thr_param2_num])]) 
               isvalid=1; 
            end
        case 'two bounds outside'
            if all([isnumeric([thr_param1_num,thr_param2_num]),~isnan([thr_param1_num,thr_param2_num])]) 
               isvalid=1; 
            end
        case 'distance within'
           if all([isnumeric([thr_param1_num,thr_param2_num]),~isnan([thr_param1_num,thr_param2_num])]) 
               isvalid=1; 
            end
        case 'distance outside'
            if all([isnumeric([thr_param1_num,thr_param2_num]),~isnan([thr_param1_num,thr_param2_num])]) 
               isvalid=1; 
            end
    end

    if isvalid
        uitable_data{row_no,7}='valid';
    else
        uitable_data{row_no,7}='invalid';
    end
end

set(handles.threshold_spec_uitable,'data',uitable_data)

handles.thr_setting_validity_info=convert_text_validity_to_logical(uitable_data);






function [handles]=ftr_include_callback(handles,callbackdata)
uitable_data=get(handles.threshold_spec_uitable,'data');
checked_ftrs_info=[uitable_data{:,8}];
edit_new_val=callbackdata.NewData;
edit_ind=callbackdata.Indices;

if edit_new_val==1
   if sum(checked_ftrs_info)>2
       warndlg('Cannot include three features.','','modal')
       uitable_data{edit_ind(1),edit_ind(2)}=false;   
   end   
end
set(handles.threshold_spec_uitable,'data',uitable_data);
handles.included_ftrs=[uitable_data{:,8}];



function handles=refresh_ftr_axes(handles)
cla(handles.ftr_axes,'reset')
% calculating the three things below
vals=[];
leg_strs=[];
axes_labels=[];
thr_line_spec=[];
table_info=[];
if sum(handles.included_ftrs)>0 && sum(handles.included_ftrs)<3
   if handles.show_labels==0 % show labels
       switch handles.show_file_labels           
           case 0 % show file labels                
               [vals,leg_strs,axes_labels,thr_line_spec,table_info]=get_plot_prereqs(handles);
           case 1 % show threshold based labels by using selected thresholds
               thr_criteria=make_thr_criteria(handles,0);
               if isempty(thr_criteria)
                  warndlg('No valid thresholds selected','','modal') 
                  textbp('The selections are not adequate for a plot','parent',handles.ftr_axes)
                  empty_display_tables([handles.show_labels_uitable,handles.compare_labels_uitable],{'show','compare'})
                  return
               end
               [vals,leg_strs,axes_labels,thr_line_spec,table_info]=get_plot_prereqs(handles,thr_criteria,'show');
           case 2 % show threshold based labels by using all valid thresholds
               thr_criteria=make_thr_criteria(handles,1);
               if isempty(thr_criteria)
                  warndlg('No valid thresholds selected','','modal') 
                  textbp('The selections are not adequate for a plot','parent',handles.ftr_axes)
                  empty_display_tables([handles.show_labels_uitable,handles.compare_labels_uitable],{'show','compare'})
                  return
               end
               [vals,leg_strs,axes_labels,thr_line_spec,table_info]=get_plot_prereqs(handles,thr_criteria,'show');
       end           
   else % compare labels
       switch handles.use_selected_thresholds   
           case 0 % use selected thresholds
               thr_criteria=make_thr_criteria(handles,0);
               if isempty(thr_criteria)
                  warndlg('No valid thresholds selected','','modal') 
                  textbp('The selections are not adequate for a plot','parent',handles.ftr_axes)
                  empty_display_tables([handles.show_labels_uitable,handles.compare_labels_uitable],{'show','compare'})
                  return
               end
               [vals,leg_strs,axes_labels,thr_line_spec,table_info]=get_plot_prereqs(handles,thr_criteria,'compare');
           case 1 % use all valid thresholds
               thr_criteria=make_thr_criteria(handles,1);
               if isempty(thr_criteria)
                  warndlg('No valid thresholds selected','','modal') 
                  textbp('The selections are not adequate for a plot','parent',handles.ftr_axes)
                  empty_display_tables([handles.show_labels_uitable,handles.compare_labels_uitable],{'show','compare'})
                  return
               end
               [vals,leg_strs,axes_labels,thr_line_spec,table_info]=get_plot_prereqs(handles,thr_criteria,'compare');
       end         
       
   end    
end

if isempty(vals)
    textbp('The selections are not adequate for a plot','parent',handles.ftr_axes)
    % setting tables to empty
    empty_display_tables([handles.show_labels_uitable,handles.compare_labels_uitable],{'show','compare'})
   
else
    % weeding out empty categories/labels
    colors_avl=[0 0 1;1 0 0;0 1 0;1 0 1;0 0 0];
    no_colors=size(colors_avl,1);
    no_types=length(leg_strs);
    if no_types>no_colors
       error('Number of types greater than number of available colors') 
    end
    colors=colors_avl(1:no_types+1,:);
%     if no_types>=4
%         colors=distinguishable_colors(no_types+2);
%         colors(4,:)=[]; % because 4 gives blackish color which is not really distinguishable
%     else
%         colors=distinguishable_colors(no_types+1);
%     end
    
    temp_vals=cell(0);
    temp_leg_strs=cell(0);
    temp_colors=[];
    for i=1:length(leg_strs)
       if ~isempty(vals{1,i})
           temp_vals=[temp_vals,vals{i}];
           temp_leg_strs=[temp_leg_strs,leg_strs{i}];
           temp_colors=[temp_colors;colors(i,:)];
       end
    end
    temp_colors=[temp_colors;colors(end,:)];
    vals=temp_vals;
    leg_strs=temp_leg_strs;
    colors=temp_colors;
    
   no_ftrs=length(axes_labels);
    no_types=length(leg_strs);
    y_offset=(-1:-1:-1*no_types);
    leg_handles=zeros(1,no_types);
    
   hold(handles.ftr_axes,'on')
   if no_ftrs==1   
       % determining ftr_bins
       ftr_min=Inf;
       ftr_max=-Inf;
       for i=1:no_types
           ftr_min=min([ftr_min,min(vals{1,i})]);
           ftr_max=max([ftr_max,max(vals{1,i})]);
       end
       ftr_bins=ftr_min:(ftr_max-ftr_min)/handles.no_bins:ftr_max;
       
       for i=1:no_types
           freqs=hist(vals{1,i},ftr_bins);
           plot(handles.ftr_axes,ftr_bins,freqs,'color',colors(i,:))
           leg_handles(1,i)=plot(handles.ftr_axes,vals{1,i},y_offset(i).*ones(size(vals{1,i})),'linestyle','none','marker','o','color',colors(i,:));
       end
       
       legend(leg_handles,leg_strs,'location','northeast')
       xlabel(axes_labels,'interpreter','none')
       ylabel('Frequency')
       ylims=ylim(handles.ftr_axes);
       ylim(handles.ftr_axes,[y_offset(end)-1,ylims(2)]);
       
       hold(handles.ftr_axes,'off')
   elseif no_ftrs==2
       for i=1:no_types
           leg_handles(1,i)=plot(handles.ftr_axes,vals{1,i}(:,1),vals{1,i}(:,2),'color',colors(i,:),'linestyle','none','marker','o');
       end
       legend(leg_handles,leg_strs,'location','northeast')
       xlabel(axes_labels{1,1},'interpreter','none')
       ylabel(axes_labels{1,2},'interpreter','none')
       hold(handles.ftr_axes,'off')
   else
       error('The number of features cannot be more than 2');       
   end
   
   % plotting thresholds 
   xlims=xlim(handles.ftr_axes);
   ylims=ylim(handles.ftr_axes);
   hold(handles.ftr_axes,'on')
   % going thru the plotting to get the full limits
   hhs=[];
   for i=1:length(thr_line_spec)
      if isempty(thr_line_spec{1,i})
          continue
      end
      intercepts=thr_line_spec{1,i};
      for j=1:length(intercepts)         
         if i==1
            xpts=[intercepts(j),intercepts(j)];  
            ypts=ylims;           
         elseif i==2
             xpts=xlims;
             ypts=[intercepts(j),intercepts(j)];              
         end
         hh=plot(handles.ftr_axes,xpts,ypts,'linestyle','--','color',colors(end,:));
         xlims=xlim(handles.ftr_axes);
         ylims=ylim(handles.ftr_axes);
         hhs=[hhs,hh]; 
      end       
   end
   delete(hhs)
   
   % now plotting for real   
   
   for i=1:length(thr_line_spec)
      if isempty(thr_line_spec{1,i})
          continue
      end
      intercepts=thr_line_spec{1,i};
      for j=1:length(intercepts)         
         if i==1
            xpts=[intercepts(j),intercepts(j)];  
            ypts=ylims;           
         elseif i==2
             xpts=xlims;
             ypts=[intercepts(j),intercepts(j)];              
         end
         plot(handles.ftr_axes,xpts,ypts,'linestyle','--','color',colors(end,:));         
      end       
   end
   
   hold(handles.ftr_axes,'off')
   
   % populating tables
   if handles.show_labels==0
       table_obj=handles.show_labels_uitable;  
       ui_data=get(table_obj,'data');
       ui_data(:,2)=num2cell(table_info);
       set(table_obj,'data',ui_data);
       % setting the data in the other table to empty
       empty_display_tables(handles.compare_labels_uitable,{'show'})
       
   else
       table_obj=handles.compare_labels_uitable;   
       set(table_obj,'data',num2cell(table_info))
       
       % setting the data in the other table to empty
      empty_display_tables(handles.show_labels_uitable,{'compare'})

   end 
   
end





function thr_criteria=make_thr_criteria(handles,do_all_valid)
ui_table_data=get(handles.threshold_spec_uitable,'data');
thr_criteria=[];
if do_all_valid
    valid_ftrs_inds=find(handles.thr_setting_validity_info);
    for i=1:length(valid_ftrs_inds)
        thr_criteria(i).ftr=ui_table_data{valid_ftrs_inds(i),1};
        thr_criteria(i).thr_type=ui_table_data{valid_ftrs_inds(i),2};
        thr_criteria(i).thr_param_1_desc=ui_table_data{valid_ftrs_inds(i),3};
        thr_criteria(i).thr_param_2_desc=ui_table_data{valid_ftrs_inds(i),5};
        if strcmpi(thr_criteria(i).thr_type,'one bound')
            thr_criteria(i).thr_param_1=str2double(ui_table_data{valid_ftrs_inds(i),4});
            thr_criteria(i).thr_param_2=ui_table_data{valid_ftrs_inds(i),6};
        else
            thr_criteria(i).thr_param_1=str2double(ui_table_data{valid_ftrs_inds(i),4});
            thr_criteria(i).thr_param_2=str2double(ui_table_data{valid_ftrs_inds(i),6});
        end
        thr_criteria(i).rel_to_next_criterion='and';
    end    
else
    included_ftrs_inds=find(handles.included_ftrs);
    valid_ftrs_inds=find(handles.thr_setting_validity_info);
    no_ftrs=1;
    for i=1:length(included_ftrs_inds)
       if ismember(included_ftrs_inds(i),valid_ftrs_inds)
            thr_criteria(no_ftrs).ftr=ui_table_data{included_ftrs_inds(i),1};
            thr_criteria(no_ftrs).thr_type=ui_table_data{included_ftrs_inds(i),2};
            thr_criteria(no_ftrs).thr_param_1_desc=ui_table_data{included_ftrs_inds(i),3};
            thr_criteria(no_ftrs).thr_param_2_desc=ui_table_data{included_ftrs_inds(i),5};
            if strcmpi(thr_criteria(no_ftrs).thr_type,'one bound')
                thr_criteria(no_ftrs).thr_param_1=str2double(ui_table_data{included_ftrs_inds(i),4});
                thr_criteria(no_ftrs).thr_param_2=ui_table_data{included_ftrs_inds(i),6};
            else
                thr_criteria(no_ftrs).thr_param_1=str2double(ui_table_data{included_ftrs_inds(i),4});
                thr_criteria(no_ftrs).thr_param_2=str2double(ui_table_data{included_ftrs_inds(i),6});
            end            
            thr_criteria(no_ftrs).rel_to_next_criterion='and';
            no_ftrs=no_ftrs+1;
       end        
    end
end





function [vals,leg_strs,axes_labels,thr_line_spec,table_info]=get_plot_prereqs(handles,varargin)

all_cats=handles.classification_labels;
no_files=length(handles.screening_ftrs);

% determining inc_ftrs
included_ftrs_inds=find(handles.included_ftrs);
no_included_ftrs=length(included_ftrs_inds);
inc_ftrs=cell(1,no_included_ftrs);

ui_table_data=get(handles.threshold_spec_uitable,'data');
for k=1:no_included_ftrs
    inc_ftrs{1,k}=ui_table_data{included_ftrs_inds(k),1};
end

axes_labels=inc_ftrs; % axes labels determined


if nargin==1 % thresholds not involved
  vals=cell(1,length(all_cats));
  leg_strs=cell(1,length(all_cats));    
  table_info=zeros(length(all_cats),1);
  thr_line_spec=[];
  % generating leg_strs
  for j=1:length(all_cats)
      leg_strs{1,j}=num2str(all_cats{j});        
  end
  
  for i=1:no_files
    for j=1:length(all_cats)
        if isequal(handles.screening_ftrs(i).classification_label,all_cats{j})
            temp_val=zeros(1,no_included_ftrs);
            for k=1:no_included_ftrs
                temp_val(1,k)=handles.screening_ftrs(i).(inc_ftrs{1,k});
            end
            vals{1,j}=[vals{1,j};temp_val];
            break
        end
    end      
  end 
  for j=1:length(all_cats)
      table_info(j,1)=size(vals{1,j},1);
  end                   
  
elseif nargin==3 % thresholds involved
     thr_line_spec=[];
    thr_criteria=varargin{1};
    plot_control=varargin{2};
    
    % specifying thr_line_spec
    for i=1:no_included_ftrs
        for j=1:length(thr_criteria)
            if strcmpi(inc_ftrs{1,i},thr_criteria(j).ftr)
                % determining thr_line_spec_part
                if strcmpi(thr_criteria(j).thr_type,'one bound')
                   thr_line_spec_part=thr_criteria(j).thr_param_1; 
                elseif strcmpi(thr_criteria(j).thr_type,'distance within')||strcmpi(thr_criteria(j).thr_type,'distance outside')
                    thr_line_spec_part=[thr_criteria(j).thr_param_1,thr_criteria(j).thr_param_1-thr_criteria(j).thr_param_2,thr_criteria(j).thr_param_1+thr_criteria(j).thr_param_2]; 
                else
                    thr_line_spec_part=[thr_criteria(j).thr_param_1,thr_criteria(j).thr_param_2]; 
                end
               % no_included_ftrs cannot exceed 
               if i==1
                  thr_line_spec{1,1}=thr_line_spec_part; 
               elseif i==2
                   thr_line_spec{1,2}=thr_line_spec_part; 
               end
               break
            end        
        end
     end
    
    
    if strcmpi(plot_control,'show')
        
         vals=cell(1,length(all_cats));
         leg_strs=cell(1,length(all_cats));        
         table_info=zeros(length(all_cats),1);


          % generating leg_strs
          for j=1:length(all_cats)
              leg_strs{1,j}=num2str(all_cats{j});        
          end

          for i=1:no_files
            for j=1:length(all_cats)
                [threshold_satisfied]=determine_if_file_satisfies_threshold(handles.screening_ftrs(i),thr_criteria);
                if threshold_satisfied
                    thr_based_label=handles.primary_label;
                else
                    thr_based_label=handles.secondary_label;
                end
                if isequal(thr_based_label,all_cats{j})
                    temp_val=zeros(1,no_included_ftrs);
                    for k=1:no_included_ftrs
                        temp_val(1,k)=handles.screening_ftrs(i).(inc_ftrs{1,k});
                    end
                    vals{1,j}=[vals{1,j};temp_val];
                    break
                end
            end      
          end  
          for j=1:length(all_cats)
             table_info(j,1)=size(vals{1,j},1);
          end   
        
    else
         vals=cell(1,4);
         leg_strs={'true neg','false pos','true pos','fals neg'};   
         table_info=zeros(3,3);
          
          for i=1:no_files
              
            [threshold_satisfied]=determine_if_file_satisfies_threshold(handles.screening_ftrs(i),thr_criteria);
            if threshold_satisfied
                thr_based_label=handles.primary_label;
            else
                thr_based_label=handles.secondary_label;
            end
            file_label=handles.screening_ftrs(i).classification_label;
            if isequal(thr_based_label,file_label)
               if isequal(file_label,handles.primary_label)
                  ind=3; 
               else
                   ind=1;
               end                
            else
                if isequal(file_label,handles.primary_label)
                  ind=4; 
               else
                  ind=2;
               end  
                
            end
            
            temp_val=zeros(1,no_included_ftrs);
            for k=1:no_included_ftrs
                temp_val(1,k)=handles.screening_ftrs(i).(inc_ftrs{1,k});
            end
            
            vals{1,ind}=[vals{1,ind};temp_val];             

          end
          table_info(1,1)=size(vals{1,3},1);
          table_info(1,2)=size(vals{1,2},1);
          table_info(1,3)=table_info(1,1)+table_info(1,2);
          
          table_info(2,1)=size(vals{1,1},1);
          table_info(2,2)=size(vals{1,4},1);
          table_info(2,3)=table_info(2,1)+table_info(2,2);
          
          table_info(3,1)=table_info(1,1)+table_info(2,1);
          table_info(3,2)=table_info(1,2)+table_info(2,2);
          table_info(3,3)=table_info(1,3)+table_info(2,3); 
          
          if  table_info(3,3)~=table_info(3,1)+table_info(3,2)
              error('There seems to be an error in label comparison counts');
          end
        
    end       
    
else
    error('Incorrect number of arguments')
    
end


% INTERNAL WORKHORSE FUNCTIONS: END


% UTILITY FUNCTIONS WITHIN THE GUI: START

function [handles]=set_defaults_on_ui_elements(handles)
cla(handles.ftr_axes,'reset')

ftrs=handles.ftrs;
no_ftrs=length(handles.ftrs);

% specifying info for threshold_spec_uitable
thr_types={'none','one bound','two bounds within','two bounds outside','distance within','distance outside'};
spec_thr_col_names={'Feature','Threshold Type','Thr. param.|1 desc.',...
                             'Thr. param.|1','Thr. param.|2 desc.','Thr. param.|2','Thr. Settings|Valid','Display'};
% Adding the | is an officially undocumented feature of adding multiline row/column names       

spec_thr_col_editable=logical([0,1,0,1,0,1,0,1]);
spec_threshold_column_formats={'char',thr_types,'char','char','char','char','char','logical'};

% specifying appropriate length for first and second column
col_no=1;
content_str=handles.ftrs;
maxlen=0;
for i=1:no_ftrs
     namelen=length(content_str{i});
     if namelen>maxlen
         maxlen=namelen;
     end
end
len_diff=maxlen-length(spec_thr_col_names{col_no});
if len_diff>0
    spec_thr_col_names{col_no}=[spec_thr_col_names{col_no},repmat(' ',1,round(2*len_diff))];
end

col_no=2;
content_str=thr_types;
maxlen=0;
for i=1:length(thr_types)
     namelen=length(content_str{i});
     if namelen>maxlen
         maxlen=namelen;
     end
end
len_diff=maxlen-length(spec_thr_col_names{col_no});
if len_diff>0
    spec_thr_col_names{col_no}=[spec_thr_col_names{col_no},repmat(' ',1,round(3*len_diff))];
end


set(handles.threshold_spec_uitable,'columnname',spec_thr_col_names,...
                                   'columneditable',spec_thr_col_editable,...
                                   'columnformat',spec_threshold_column_formats);                                 


% specifying default data
def_thr_type=repmat({thr_types{1}},no_ftrs,1);
def_include_state=mat2cell(false(no_ftrs,1),ones(1,no_ftrs),1);
def_entry=repmat({''},no_ftrs,1);
def_validity=repmat({'invalid'},no_ftrs,1);
spec_thr_data=[ftrs,def_thr_type,def_entry,def_entry,def_entry,def_entry,def_validity,def_include_state];
set(handles.threshold_spec_uitable,'data',spec_thr_data);

handles.thr_setting_validity_info=false(1,no_ftrs);
handles.included_ftrs=false(1,no_ftrs);



% 
new_obj=get(handles.plot_control_uipanel,'selectedobject');
switch new_obj
    case handles.show_labels_radiobutton
        disable_eles=[(get(handles.compare_labels_uipanel,'Children'))',handles.compare_labels_uitable];
        enable_eles=[(get(handles.show_labels_uipanel,'Children'))',handles.show_labels_uitable];
        handles.show_labels=0;
    case handles.compare_labels_radiobutton
        disable_eles=[(get(handles.show_labels_uipanel,'Children'))',handles.show_labels_uitable];
        enable_eles=[(get(handles.compare_labels_uipanel,'Children'))',handles.compare_labels_uitable];
        handles.show_labels=1;
end
set(disable_eles,'enable','off')
set(enable_eles,'enable','on')

new_obj=get(handles.show_labels_uipanel,'selectedobject');
switch new_obj
    case handles.show_file_labels_radiobutton
        handles.show_file_labels=0;
    case handles.show_selected_threshold_based_labels_radiobutton
        handles.show_file_labels=1;
    case handles.show_all_valid_threshold_based_labels_radiobutton
         handles.show_file_labels=2;
end

new_obj=get(handles.compare_labels_uipanel,'selectedobject');
switch new_obj
    case handles.use_selected_thresholds_radiobutton
         handles.use_selected_thresholds=0;
    case handles.use_valid_thresholds_radiobutton
        handles.use_selected_thresholds=1;
end

handles.show_file_labels=0;
handles.use_selected_thresholds=0;

% specifying info for compare_labels_uitable
compare_labels_colnames={'True','False','Row Total'};
compare_labels_rownames={'Positive','Negative','Column Total'};
compare_labels_columnformats={'numeric','numeric','numeric'};
compare_labels_init_data=cell(3,3);
set(handles.compare_labels_uitable,'rowname',compare_labels_rownames,...
                                   'columnname',compare_labels_colnames,...
                                   'data',compare_labels_init_data,...
                                   'columnformat',compare_labels_columnformats)

% specifying info for show_labels_uitable
show_labels_colnames={'Lable/Category','Frequency'};
no_labels=length(handles.classification_labels);
if ~iscolumn(handles.classification_labels)
    show_labels_data=[handles.classification_labels',cell(no_labels,1)];
else
    show_labels_data=[handles.classification_labels,cell(no_labels,1)];
end
show_labels_columnformats={'char','numeric'};
set(handles.show_labels_uitable,'columnname',show_labels_colnames,'data',show_labels_data,'columnformat',show_labels_columnformats);
handles=refresh_ftr_axes(handles);









function refresh_table_data(table_object,changed_indices,new_values)
uitable_data=get(table_object,'data');
no_changes=length(new_values);

for i=1:no_changes
   uitable_data{changed_indices{i}(1),changed_indices{i}(2)}=new_values{i};   
end
set(table_object,'data',uitable_data)




function [valid_ftrs_info]=convert_text_validity_to_logical(uitable_data)
no_rows=size(uitable_data,1);
valid_ftrs_info= false(1,no_rows);
validity_index=7;
for i=1:no_rows
    if strcmpi(uitable_data{i,validity_index},'valid')
        valid_ftrs_info(i)=true;
    else
        valid_ftrs_info(i)=false;
    end
end

function handles=disable_interactive_elements(handles)
interactive_elements=[handles.threshold_spec_uitable,handles.resize_table_pushbutton,...
                      handles.write_thr_file_pushbutton,handles.load_thresholds_file_pushbutton];
first_level_radiobuttons=get(handles.plot_control_uipanel,'children');
first_level_radiobuttons=first_level_radiobuttons(3:4);

second_level_radiobuttons=[get(handles.show_labels_uipanel,'children')...
                    ;get(handles.compare_labels_uipanel,'children')];   
set(interactive_elements,'enable','off')            
set(second_level_radiobuttons,'enable','off')            
set(first_level_radiobuttons,'enable','off')



function handles=enable_interactive_elements(handles)
interactive_elements=[handles.threshold_spec_uitable,handles.resize_table_pushbutton,...
                      handles.write_thr_file_pushbutton,handles.load_thresholds_file_pushbutton];
set(interactive_elements,'enable','on')   

first_level_radiobuttons=get(handles.plot_control_uipanel,'children');
first_level_radiobuttons=first_level_radiobuttons(3:4);
set(first_level_radiobuttons,'enable','on')



new_obj=get(handles.plot_control_uipanel,'selectedobject');
switch new_obj
    case handles.show_labels_radiobutton
        disable_eles=[(get(handles.compare_labels_uipanel,'Children'))',handles.compare_labels_uitable];
        enable_eles=[(get(handles.show_labels_uipanel,'Children'))',handles.show_labels_uitable];
    case handles.compare_labels_radiobutton
        disable_eles=[(get(handles.show_labels_uipanel,'Children'))',handles.show_labels_uitable];
        enable_eles=[(get(handles.compare_labels_uipanel,'Children'))',handles.compare_labels_uitable];
end
set(disable_eles,'enable','off')
set(enable_eles,'enable','on')

function []=empty_display_tables(table_objs,table_type)

no_table_objs=length(table_objs);
for i=1:no_table_objs
    table_obj=table_objs(i);
    curr_table_type=table_type{i};
    switch curr_table_type
        case 'show'
            other_data=get(table_obj,'data');
            other_data(:,2)=cell(size(other_data,1),1);
            set(table_obj,'data',other_data)
        case 'compare'
            other_data=get(table_obj,'data');
            empty_data=cell(size(other_data));
            set(table_obj,'data',empty_data)
        otherwise
            error('Table type is incorrect')
    end
    
end




                  


% UTILITY FUNCTIONS WITHIN THE GUI: END


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important internal functions and callbacks: END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% The code below is GUI generated. There is no user programmed code below. 
%%%% It should, however, not be deleted.  

