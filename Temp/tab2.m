function varargout = tab2(varargin)
%TAB2 M-file for tab2.fig
%      TAB2, by itself, creates a new TAB2 or raises the existing
%      singleton*.
%
%      H = TAB2 returns the handle to a new TAB2 or the handle to
%      the existing singleton*.
%
%      TAB2('Property','Value',...) creates a new TAB2 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to tab2_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TAB2('CALLBACK') and TAB2('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TAB2.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tab2

% Last Modified by GUIDE v2.5 11-Jul-2013 20:01:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tab2_OpeningFcn, ...
                   'gui_OutputFcn',  @tab2_OutputFcn, ...
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


% --- Executes just before tab2 is made visible.
function tab2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for tab2
handles.output = hObject;
global Dados;
global Dados1;
global NameMenu

% Update handles structure
guidata(hObject, handles);
%Dados= { ['OutPut Curren (uA)'] ['1.0']; ['Current Precision (%)'] ['10']; ['Power Supply (min max) (V)'] ['1.0 3.0']; ['Output Voltage (V)'] [ '0.6']; ['Power Consumption (uW)'] ['5'] };

RowName= { ['OutPut Curren (uA)']; ['Current Precision (%)']; ['Power Supply (min max) (v)']; ['Output Voltage (V)']; ['Power Consumption (uW)'] };
if exist('Dados') set(handles.tableVar,'Data', Dados); end;

%Dados1= { ['W1 (um)'] [ '1.0'] ['50'] ['5']; ['L1 (um)']  [ '1.0'] ['50'] ['5']; ['W2 (um)'] [ '1.0'] ['50'] ['5']; ['L2 (um)'] [ '1.0'] ['50'] ['5']; 
 %               ['W1 (um)'] [ '1.0'] ['50'] ['5']; ['L1 (um)']  [ '1.0'] ['50'] ['5']; ['W2 (um)'] [ '1.0'] ['50'] ['5']; ['L2 (um)'] [ '1.0'] ['50'] ['5']; };
 if exist('Dados1') set(handles.tablePar, 'Data', Dados1); end;         
 set(handles.panel1, 'Title', NameMenu);
%set(handles.tabletes,'RowName', RowName);

% UIWAIT makes tab2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tab2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when entered data in editable cell(s) in tabletes.
function tabletes_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tabletes (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on tablePar and none of its controls.
function tablePar_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to tablePar (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
%get(handles.tablePar);
MenuCond=get(handles.tablePar,'Data');
RowName=get(handles.tablePar,'RowName');
tam=length(MenuCond);
eventdata.Key;
if (strcmp(eventdata.Key,  'insert'))
    MenuCond(tam+1, :) = MenuCond(tam, :);
    RowName{tam+1}= ['X' num2str(tam)];
    a=1
 end;

 if strcmp(eventdata.Key, 'f1')
    MenuCond= MenuCond(1: (tam-1), :);
    RowName= RowName(1: (tam-1));
end;
set(handles.tablePar,'Data', MenuCond);
set(handles.tablePar,'RowName', RowName);
