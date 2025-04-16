function varargout = SAM(varargin)
% SAM M-file for SAM.fig
%      SAM, by itself, creates a new SAM or raises the existing
%      singleton*.
%
%      H = SAM returns the handle to a new SAM or the handle to
%      the existing singleton*.
%
%      SAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAM.M with the given input arguments.
%
%      SAM('Property','Value',...) creates a new SAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAM

% Last Modified by GUIDE v2.5 06-Feb-2013 22:47:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAM_OpeningFcn, ...
                   'gui_OutputFcn',  @SAM_OutputFcn, ...
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


% --- Executes just before SAM is made visible.
function SAM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAM (see VARARGIN)

% Choose default command line output for SAM
handles.output = hObject;
global inicialSol;

set(handles.ed3, 'String', num2str(inicialSol));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SAM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SAM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ed1_Callback(hObject, eventdata, handles)
% hObject    handle to ed1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed1 as text
%        str2double(get(hObject,'String')) returns contents of ed1 as a double


% --- Executes during object creation, after setting all properties.
function ed1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed2_Callback(hObject, eventdata, handles)
% hObject    handle to ed2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed2 as text
%        str2double(get(hObject,'String')) returns contents of ed2 as a double


% --- Executes during object creation, after setting all properties.
function ed2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb1.
function pb1_Callback(hObject, eventdata, handles)
% Inicia a Otimizacao pelo algoritimo SA modificado pelo Tiago Oliveira Weber

global genesLB;
global dif;
global inicialSol;
global nvars;

options = struct(...
    'fitnessfcn', @fitness,...
    'Display', 'crossovers',...  % it can be 'final', 'iter', 'crossovers', or 'none'
    'TolFun', 1e-6,...
    'ObjectiveLimit', -1e+20,...
    'TolCon', 1e-6,...
    'CoolSched',@(T) (.8*T),...
    'InitTemp',10,...                % initial temperature
    'MaxTriesWithoutBest',10000,...  %max number of attempts without a new best before finishing
    'MaxSuccess',200,...
    'MaxTries',300,...
    'StopTemp',1e-8,...
    'StopVal',-Inf,...
    'MaxtoLocal',25,...
    'TimeLimit',inf,...    % time in seconds
    'LockOn',1,...         % lock to variables that are showing progress
    'Crossover',1,...      % able or disable crossovers
    'MaxSim',3000,... 
    'Initial_Sigma',1);
options.fitnessfcn = str2func(get(handles.ed1, 'String'));
options.InitTemp = str2double(get(handles.ed2, 'String'));
get(handles.ed3, 'String')
x0 = str2num(get(handles.ed3, 'String'))
randv= get(handles.rb1,'Value');

options.lb = zeros(1,nvars);
options.ub = ones(1,nvars);

if (randv == 0) 
    j=1;
    for i=1:length(genesLB)
        if (dif(i) ~= 0)  
        options.x0(j) = (x0(i) - genesLB(i))/dif(i);
        j=j+1;
      end;
    end;
else options.x0 = rand(1,nvars);
end;

annealwithcrossovers(options);

% --- Executes on button press in rb1.
function rb1_Callback(hObject, eventdata, handles)
% Controla se a condicao inicial ? escolhida ou randomica

if get(hObject,'Value');
          set(handles.rb1, 'string', 'on');
     else
          set(handles.rb1, 'string', 'off');
 end;

% --- Executes on button press in pb2.
function pb2_Callback(hObject, eventdata, handles)
% hObject    handle to pb2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stop;
stop=0;
quit
stop


function ed3_Callback(hObject, eventdata, handles)
% hObject    handle to ed3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ed3 as text
%        str2double(get(hObject,'String')) returns contents of ed3 as a double


% --- Executes during object creation, after setting all properties.
function ed3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
