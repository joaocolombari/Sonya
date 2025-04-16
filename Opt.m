function varargout = Opt(varargin)
% CIROP M-file for CirOp.fig
%      CIROP, by itself, creates a new CIROP or raises the existing
%      singleton*.
%
%      H = CIROP returns the handle to a new CIROP or the handle to
%      the existing singleton*.
%
%      CIROP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CIROP.M with the given input arguments.
%
%      CIROP('Property','Value',...) creates a new CIROP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CirOp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CirOp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CirOp

% Last Modified by GUIDE v2.5 23-Jan-2015 13:07:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Opt_OpeningFcn, ...
                   'gui_OutputFcn',  @Opt_OutputFcn, ...
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


% --- Executes just before CirOp is made visible.
function Opt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CirOp (see VARARGIN)
global slash;
% Choose default command line output for CirOp
handles.output = hObject;

% Update handles structure
global caminho;
guidata(hObject, handles);

caminho = pwd;
eval(['addpath ', '''', caminho, '''']);
eval(['addpath ', '''', caminho, '''', slash, 'Start'])
eval(['addpath ', '''', caminho, '''', slash, 'Start', slash, 'PSw']);
eval(['addpath ', '''', caminho, '''', slash, 'Start', slash, 'MEIGO']);
eval(['addpath ', '''', caminho, '''', slash, 'Start', slash, 'MEIGO', slash, 'eSS']);



% --- Outputs from this function are returned to the command line.
function varargout = Opt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% Lista as varias familias de circuitos disponiveis
function list1_Callback(hObject, eventdata, handles)
% hObject    handle to list1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
circuito = contents{get(hObject,'Value')};



% --- Executes during object creation, after setting all properties.
function list1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
a =dir('Circuits');
u=(cellfun(@(x)(x==1),{a.isdir})==1);
u(1)= 0; u(2)=0; 
s={ a(u).name };
set(hObject, 'String', s);


% --- Executes the run.                                                                                                                                                                                                                                                                                                         
function pb1_Callback(hObject, eventdata, handles)
% hObject    handle to pb1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global slash;
global simpr;
global modelsD;
global fitness;
global family;

contents = cellstr(get(handles.list1,'String'));
family = contents{get(handles.list1,'Value')};
contents = cellstr(get(handles.list2,'String'));
simpr = contents{get(handles.list2,'Value')};
switch simpr
    case 'HSP'
      modelsD = 'ModelsHSP';
      fitness = 'fitnessHSP';
    case 'LTSP'
      modelsD = 'ModelsHSP';
      fitness = 'fitnessHSP';
    case 'Eldo'
      modelsD = 'ModelsEldo';
      fitness = 'fitnessEldo';
end;

eval(['cd ', 'Circuits', slash, family]);
menu;


% --- Executes the exit
function pb2_Callback(hObject, eventdata, handles)
% hObject    handle to pb2 (see GCBO)
global slash;
global caminho;

%caminho = pwd;
eval(['rmpath ', '''', caminho, '''']);
eval(['rmpath ', '''', caminho, '''', slash, 'Start'])
eval(['rmpath ', '''', caminho, '''', slash, 'Start', slash, 'PSw']);
eval(['rmpath ', '''', caminho, '''', slash, 'Start', slash, 'MEIGO']);
eval(['rmpath ', '''', caminho, '''', slash, 'Start', slash, 'MEIGO', slash, 'eSS']);
delete(handles.figure1);


% --- Executes on selection change in list2.
function list2_Callback(hObject, eventdata, handles)
% hObject    handle to list2 (see GCBO)


% --- Executes during object creation, after setting all properties.
function list2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel1 is resized.
function uipanel1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global slash;
global caminho;

%caminho = pwd;

system(['start /b "', 'C:\Users\navarro\AppData\Local\Kingsoft\WPS Office\11.2.0.11486\office6\wps.exe" ', caminho, slash, 'Start', slash, 'CirOp.docx']);