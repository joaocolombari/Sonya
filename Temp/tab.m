function varargout = tab(varargin)
% TAB M-file for tab.fig
%      TAB, by itself, creates a new TAB or raises the existing
%      singleton*.
%
%      H = TAB returns the handle to a new TAB or the handle to
%      the existing singleton*.
%
%      TAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TAB.M with the given input arguments.
%
%      TAB('Property','Value',...) creates a new TAB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tab_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tab_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tab

% Last Modified by GUIDE v2.5 11-Jul-2013 15:10:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tab_OpeningFcn, ...
                   'gui_OutputFcn',  @tab_OutputFcn, ...
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


% --- Executes just before tab is made visible.
function tab_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tab (see VARARGIN)

% Choose default command line output for tab
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tab wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tab_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on key press with focus on uitable2 and none of its controls.
function uitable2_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
get(handles.uitable2);
MenuCond=get(handles.uitable2,'Data');
RowName=get(handles.uitable2,'RowName');
tam=length(MenuCond);
eventdata.Key
if (strcmp(eventdata.Key,  'insert'))
    MenuCond(tam+1, :) = MenuCond(tam, :);
    RowName{tam+1}= ['X' num2str(tam)];
    a=1
 end;

 if strcmp(eventdata.Key, 'f1')
    MenuCond= MenuCond(1: (tam-1), :);
    RowName= RowName(1: (tam-1));
end;
set(handles.uitable2,'Data', MenuCond);
set(handles.uitable2,'RowName', RowName);

%set(handles.uitable2, 'Data', teste)
% --- Executes when entered data in editable cell(s) in uitable2.
function uitable2_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

%get(handles.uitable2);
a=3
b=get(handles.uitable2,'Data');
c=0;
for i=1:length(b) c(i) = str2num(b{i, 2});
end
c
teste= { ['a'] [1] [3 ]; ['b '] [ 3]  [5]; ['c'] [1] [3 ]; ['d '] [ 3]  [5]; ['e'] [1] [3 ]; ['f '] [ 3]  [5]; ['a'] [1] [3 ]; ['f '] [ 3]  [5]; ['a'] [1] [3 ]};


% --- Executes during object deletion, before destroying properties.
function uitable2_DeleteFcn(hObject, eventdata, handles)
% hObjec   handle to uitable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=1
