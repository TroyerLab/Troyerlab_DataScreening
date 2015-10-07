function varargout = select_screening_features_2(varargin)
%SELECT_SCREENING_FEATURES_2 M-file for select_screening_features_2.fig
%      SELECT_SCREENING_FEATURES_2, by itself, creates a new SELECT_SCREENING_FEATURES_2 or raises the existing
%      singleton*.
%
%      H = SELECT_SCREENING_FEATURES_2 returns the handle to a new SELECT_SCREENING_FEATURES_2 or the handle to
%      the existing singleton*.
%
%      SELECT_SCREENING_FEATURES_2('Property','Value',...) creates a new SELECT_SCREENING_FEATURES_2 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to select_screening_features_2_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SELECT_SCREENING_FEATURES_2('CALLBACK') and SELECT_SCREENING_FEATURES_2('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SELECT_SCREENING_FEATURES_2.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_screening_features_2

% Last Modified by GUIDE v2.5 17-Jun-2015 21:05:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_screening_features_2_OpeningFcn, ...
                   'gui_OutputFcn',  @select_screening_features_2_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before select_screening_features_2 is made visible.
function select_screening_features_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for select_screening_features_2
handles.output = hObject;


handles=clear_all_plots(handles);
prob_path=pwd;
nargin_min=3+1; % three 'hObject, eventdata, handles' + 'varargin'
in_message1=['Would you like load a batch file or a consolidated .mat file containing the\n'...
             'screening features distributions for all the relevant files.\n'...
             'Enter 1 for batch file and 0 for a consolidated .mat screening file'];
in_message2='Please select the file';

if nargin<nargin_min 
     is_batch=input([in_message1 '\n-->  ']); 
    [fname,fpath]=uigetfile([prob_path filesep '*.*'],in_message2); 

else
    is_batch=varargin{1};
    fname=varargin{2};
    fpath=varargin{3};
end

% setting certain defaults
handles.nbins=100;
handles.default.line_transparency=0.3;
% handles.uitable_default_column_width=100;
set(handles.display_selected_ftrs_uitable,'cellselectioncallback',@register_selected_cells)
handles.uitable_selected_indices=[];
handles.batch_fullfile=[fpath fname];


[screening_ftrs_dists,prc_vec,classification_labels_present]=aggregate_screening_ftrs_dists(is_batch,fname,fpath);
% transferring information from aggregate_screening_ftrs_dists to handles
handles.screening_ftrs_dists=screening_ftrs_dists;
handles.no_files=length(handles.screening_ftrs_dists);
handles.prc_vec=prc_vec;
handles.classification_labels_present=classification_labels_present;

% specifying colors matrix 
colors=[0 0 1;1 0 0;0 1 0];
no_colors=size(colors,1);
no_labels_present=length(classification_labels_present);
if no_labels_present>no_colors
   error('Number of labels is greater than number of colors') 
end
handles.colors=colors(1:no_labels_present,:);
% handles.colors=distinguishable_colors(no_labels_present); % distinguishable_colors
% relies on the the computer running the image processinf toolbox. This  can be activated
% in computers which we know contain the said toobox. 

% listing all the feature distributions
names=fieldnames(screening_ftrs_dists);
ftrs=cell(0);
ftr_str='ftr_dist_';
for i=1:length(names)
    if length(names{i})>=length(ftr_str)
        if strcmpi(names{i}(1:length(ftr_str)),ftr_str)    
           ftrs=[ftrs;names{i}];
        end
    end
end
handles.ftrs=ftrs;


% setting feature selection in all dropdown menus and defaults in edit
% texts
[handles]=set_defaults_on_ui_elements(handles);


% Update handles structure
guidata(hObject, handles);


% UIWAIT makes select_screening_features_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = select_screening_features_2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important internal functions and callbacks: START
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UTILITY FUNCTIONS WITHIN THE GUI: START


function [handles]=set_defaults_on_ui_elements(handles)
set(handles.ftrs_select_popupmenu,'String',['none';handles.ftrs])
set(handles.ftrs_select_popupmenu,'value',1)
set(handles.prc_edittext,'String','')
set(handles.line_transparency_edittext,'string',num2str(handles.default.line_transparency));
% setting uitable stuff
column_headings={'Feature','%-tile'};
% determining longest feature name , computing row_headings,
% column_headings, and init_data
no_ftrs=length(handles.ftrs);
maxlen=0;
for i=1:no_ftrs
     ftrnamelen=length(handles.ftrs{i});
     if ftrnamelen>maxlen
         maxlen=ftrnamelen;
     end
end
len_diff=maxlen-length(column_headings{1});
if len_diff>0
    column_headings{1}=[column_headings{1},repmat(' ',1,2*len_diff)];
end

row_headings={1,2,3};

init_data=cell(length(row_headings),length(column_headings));
% for i=1:size(init_data,2)
%     for j=1:size(init_data,1)
% %         init_data{j,i}=repmat('',1,length(column_headings{i})); 
%           init_data{j,i}=''; 
%     end
% end

set(handles.display_selected_ftrs_uitable,'rowname',row_headings,'columnname',column_headings,'data',init_data);    

% set(handles.display_selected_ftrs_uitable,'data',init_data); 

init_position=get(handles.display_selected_ftrs_uitable,'position');
init_extent=get(handles.display_selected_ftrs_uitable,'extent');
set(handles.display_selected_ftrs_uitable,'position',[init_position(1:2),init_extent(3:4)])

                               


% column_widths=num2cell(ones(size(column_headings))*handles.uitable_default_column_width);
% set(handles.display_selected_ftrs_uitable,'columnwidth',column_widths);

                               


handles=clear_all_plots(handles);
                                      
function [handles]=clear_all_plots(handles)
cla(handles.ftrs_dist_axes,'reset')
handles.ftrs_dist_axes_plot_ok=0;
cla(handles.ftr_prc_axes,'reset')
handles.ftr_prc_axes_plot_ok=0;

function [handles]=register_selected_cells(hObject,callbackdata)
handles=guidata(hObject);
handles.uitable_selected_indices=callbackdata.Indices;
guidata(hObject,handles)



% UTILITY FUNCTIONS WITHIN THE GUI: END


% UI CALLBACKS: START     

function ftrs_select_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ftrs_select_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ftrs_select_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ftrs_select_popupmenu
handles=refresh_ftrs_dist_axes(handles);
handles=refresh_ftr_prc_axes(handles);
guidata(hObject,handles)

function line_transparency_edittext_Callback(hObject, eventdata, handles)
% hObject    handle to line_transparency_edittext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of line_transparency_edittext as text
%        str2double(get(hObject,'String')) returns contents of line_transparency_edittext as a double
handles=refresh_ftrs_dist_axes(handles);
guidata(hObject,handles)


                                      
function prc_edittext_Callback(hObject, eventdata, handles)
% hObject    handle to prc_edittext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of prc_edittext as text
%        str2double(get(hObject,'String')) returns contents of prc_edittext as a double
% handles=refresh_ftrs_dist_axes(handles);
handles=refresh_ftr_prc_axes(handles);
guidata(hObject,handles)



% --- Executes on button press in add_ftr_to_list_pushbutton.
function add_ftr_to_list_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to add_ftr_to_list_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ftrs_dist_axes_plot_ok==0 || handles.ftr_prc_axes_plot_ok==0
    warndlg('The feature information is incorrect or incomplete. Unable to add it to the list.','','modal')
    return
end

% getting new ftr details
contents = cellstr(get(handles.ftrs_select_popupmenu,'String')) ;
selected_ftr=contents{get(handles.ftrs_select_popupmenu,'Value')} ;
prc=get(handles.prc_edittext,'String');


uitable_data=get(handles.display_selected_ftrs_uitable,'data');
no_rows=size(uitable_data,1); 

no_ftrs_added=0;
for i=1:no_rows 
    if ~isempty(uitable_data{i,1}) % it is assumed that if the first column is empty, other columns will be empty
        no_ftrs_added=no_ftrs_added+1;
        if isequal(uitable_data(i,:),{selected_ftr,prc})
            warndlg('This particular feature information has already been entered. Cannot repeat it.','','modal')
            return
        end
    else
        break
    end
end
new_ftr_pos=no_ftrs_added+1;


uitable_data{new_ftr_pos,1}=selected_ftr;
uitable_data{new_ftr_pos,2}=prc;

uitable_data(new_ftr_pos+1:end,:)=[];

set(handles.display_selected_ftrs_uitable,'data',uitable_data)

row_headings=num2cell((1:new_ftr_pos));
set(handles.display_selected_ftrs_uitable,'rowname',row_headings);

curr_position=get(handles.display_selected_ftrs_uitable,'position');
curr_extent=get(handles.display_selected_ftrs_uitable,'extent');
set(handles.display_selected_ftrs_uitable,'position',[curr_position(1:2),curr_extent(3:4)])
% setting selected indices to blank after remaking the table
handles.uitable_selected_indices=[];
guidata(hObject,handles)

% --- Executes on button press in remove_selected_ftr_pushbutton.
function remove_selected_ftr_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to remove_selected_ftr_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inds_to_elim=handles.uitable_selected_indices;
if isempty(inds_to_elim)
     warndlg('No feature has been selected for removal.','','modal')
     return
end
% no_inds_to_elim=size(inds_to_elim,1);
rows_to_elim=unique(inds_to_elim(:,1));
% no_rows_to_elim=length(no_rows_to_elim);
uitable_data=get(handles.display_selected_ftrs_uitable,'data');
uitable_data(rows_to_elim,:)=[];

set(handles.display_selected_ftrs_uitable,'data',uitable_data)

column_widths='auto';
row_headings=num2cell((1:size(uitable_data,1)));
set(handles.display_selected_ftrs_uitable,'columnwidth',column_widths,'rowname',row_headings);

curr_position=get(handles.display_selected_ftrs_uitable,'position');
curr_extent=get(handles.display_selected_ftrs_uitable,'extent');
set(handles.display_selected_ftrs_uitable,'position',[curr_position(1:2),curr_extent(3:4)])
% setting selected indices to blank after remaking the table
handles.uitable_selected_indices=[];
guidata(hObject,handles)

% --- Executes on button press in write_ftr_file_pushbutton.
function write_ftr_file_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to write_ftr_file_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uitable_data=get(handles.display_selected_ftrs_uitable,'data');
no_rows=size(uitable_data,1);
no_ftrs_added=0;
for i=1:no_rows 
    if ~isempty(uitable_data{i,1}) % it is assumed that if the first column is empty, other columns will be empty
        no_ftrs_added=no_ftrs_added+1;        
    else
        break
    end
end


if no_ftrs_added<1
    warndlg('No features have been selected. Will not write an empty file','','modal')
    return
end
no_rows=size(uitable_data,1); 

no_ftrs_added=0;
for i=1:no_rows 
    if ~isempty(uitable_data{i,1}) % it is assumed that if the first column is empty, other columns will be empty
        no_ftrs_added=no_ftrs_added+1;        
    else
        break
    end
end

features={uitable_data(1:no_ftrs_added,1)};
features=features{1,1}';
prc={uitable_data(1:no_ftrs_added,2)};
prc=prc{1,1}';
prc=str2double(prc);
[path,name,~]=fileparts(handles.batch_fullfile);
[out_filename,out_pathname]=uiputfile([path filesep 'selected_features_' name '_*'],'Please select the name and location of the selected features file','');
save([out_pathname out_filename],'features','prc');



% UI CALLBACKS: END                                       


% INTERNAL WORKHORSE FUNCTIONS: START

function [handles]=refresh_ftrs_dist_axes(handles)
handles.ftrs_dist_axes_plot_ok=0;
cla(handles.ftrs_dist_axes,'reset')
contents = cellstr(get(handles.ftrs_select_popupmenu,'String')) ;
selected_ftr=contents{get(handles.ftrs_select_popupmenu,'Value')} ;
if strcmpi(selected_ftr,'none')
    textbp('Not Enough Information For a Plot','fontsize',10,'fontweight','bold','parent',handles.ftrs_dist_axes)
    return
end
line_transparency=str2num(get(handles.line_transparency_edittext,'String'));
line_transparency_error=0;
if length(line_transparency)==1
   if line_transparency>1.0 || line_transparency<0.0
       line_transparency_error=1;
   end       
else
    line_transparency_error=1;
end

if line_transparency_error
    warndlg(['The entered value of line transparency is incorrect. Plotting with the default ' num2str(handles.default.line_transparency)],'','modal')
    line_transparency=handles.default.line_transparency;
    set(handles.line_transparency_edittext,'string',num2str(handles.default.line_transparency));
end

hold(handles.ftrs_dist_axes,'on')

labels_legendized=[];
labels_legend_handles=[];

for i=1:handles.no_files
    curr_label=handles.screening_ftrs_dists(i).classification_label;    
    for j=1:length(handles.classification_labels_present)
        if isequal(handles.classification_labels_present{j},curr_label)
            classification_label_index=j;
        end
    end
    hh=patchline(handles.screening_ftrs_dists(i).(selected_ftr),handles.prc_vec,'edgealpha',line_transparency,...
              'parent',handles.ftrs_dist_axes,'edgecolor',handles.colors(classification_label_index,:),...
              'facecolor','none');  
    if ~ismember(curr_label,labels_legendized)
        labels_legendized=[labels_legendized,curr_label];
        labels_legend_handles=[labels_legend_handles,hh];
    end
end
labels_legendized=mat2cell(labels_legendized,1,ones(1,length(labels_legendized)));
temp_labels_legendized=cell(size(labels_legendized));
for i=1:length(labels_legendized)
    temp_labels_legendized{i}=num2str(labels_legendized{i});    
end
labels_legendized=temp_labels_legendized;

legend(handles.ftrs_dist_axes,labels_legend_handles,labels_legendized)
% axes labels
xlabel(handles.ftrs_dist_axes,selected_ftr,'interpreter','none')
ylabel(handles.ftrs_dist_axes,'Percentile')

hold(handles.ftrs_dist_axes,'off')
handles.ftrs_dist_axes_plot_ok=1;





function [handles]=refresh_ftr_prc_axes(handles)
handles.ftr_prc_axes_plot_ok=0;
cla(handles.ftr_prc_axes,'reset')
plot_error=0;
% checking status of ftrs_dist_axes plot
if handles.ftrs_dist_axes_plot_ok==0
    plot_error=1;    
else
    contents = cellstr(get(handles.ftrs_select_popupmenu,'String')) ;
    selected_ftr=contents{get(handles.ftrs_select_popupmenu,'Value')} ;
end

prc=str2num(get(handles.prc_edittext,'String'));
if isempty(prc) || ~ismember(prc,handles.prc_vec)
    plot_error=1;
end

if plot_error
    textbp('Not Enough Information For a Plot','fontsize',10,'fontweight','bold','parent',handles.ftr_prc_axes)
    return
end

prc_ind=find(handles.prc_vec==prc);

% obtaining ftr_prc_vals
ftr_prc_vals=cell(size(handles.classification_labels_present));
for i=1:handles.no_files
    curr_label=handles.screening_ftrs_dists(i).classification_label;    
    for j=1:length(handles.classification_labels_present)
        if isequal(handles.classification_labels_present{j},curr_label)
            classification_label_index=j;
        end
    end
    curr_val=handles.screening_ftrs_dists(i).(selected_ftr)(prc_ind);
    ftr_prc_vals{classification_label_index}=[ftr_prc_vals{classification_label_index},curr_val];   
end

% histogram plotting
bins_min=Inf;
bins_max=-Inf;

for i=1:length(handles.classification_labels_present)
    bins_min=min(bins_min,min(ftr_prc_vals{i}));
    bins_max=max(bins_max,max(ftr_prc_vals{i}));    
end
bins_size=(bins_max-bins_min)/handles.nbins;
bins=(bins_min:bins_size:bins_max);

hold(handles.ftr_prc_axes,'on')

labels_legend_handles=[];

for i=1:length(handles.classification_labels_present)    
    curr_label=handles.classification_labels_present{i};  
    freqs=hist(ftr_prc_vals{i},bins);
    ff=plot(handles.ftr_prc_axes,bins,freqs,'color',handles.colors(i,:));    
    labels_legend_handles=[labels_legend_handles,ff];    
end

% preparing labels
labels_legendized=handles.classification_labels_present;
% labels_legendized=mat2cell(labels_legendized,1,ones(1,length(labels_legendized)));
temp_labels_legendized=cell(size(labels_legendized));
for i=1:length(labels_legendized)
    temp_labels_legendized{i}=num2str(labels_legendized{i});    
end
labels_legendized=temp_labels_legendized;

legend(handles.ftr_prc_axes,labels_legend_handles,labels_legendized);

% plotting discrete pts
y_offset=(-1:-1:-1*(length(handles.classification_labels_present)));
for i=1:length(handles.classification_labels_present)    
    curr_vals=ftr_prc_vals{i};
    plot(handles.ftr_prc_axes,curr_vals,y_offset(i)*ones(size(curr_vals)),'marker','o','color',handles.colors(i,:),'linestyle','none');    
end

ylims=ylim(handles.ftr_prc_axes);
ylim(handles.ftr_prc_axes,[y_offset(end)-1,ylims(2)]);

xlabel(handles.ftr_prc_axes,selected_ftr,'interpreter','none')
ylabel(handles.ftr_prc_axes,'Frequency')

hold(handles.ftr_prc_axes,'off')
handles.ftr_prc_axes_plot_ok=1;


% INTERNAL WORKHORSE FUNCTIONS: END



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important internal functions and callbacks: END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% The code below is GUI generated. There is no user programmed code below. 
%%%% It should, however, not be deleted.  




% --- Executes on selection change in ftrs_select_popupmenu.



% --- Executes during object creation, after setting all properties.
function ftrs_select_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ftrs_select_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function prc_edittext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prc_edittext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function line_transparency_edittext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line_transparency_edittext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
