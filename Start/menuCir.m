function varargout = menuCir(varargin)
% MENUCIR M-file for menuCir.fig
%      MENUCIR, by itself, creates a new MENUCIR or raises the existing
%      singleton*.
%
%      H = MENUCIR returns the handle to a new MENUCIR or the handle to
%      the existing singleton*.
%
%      MENUCIR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MENUCIR.M with the given input arguments.
%
%      MENUCIR('Property','Value',...) creates a new MENUCIR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before menuCir_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to menuCir_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help menuCir

% Last Modified by GUIDE v2.5 23-Jan-2015 15:26:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @menuCir_OpeningFcn, ...
                   'gui_OutputFcn',  @menuCir_OutputFcn, ...
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


% --- Executes just before menuCir is made visible.
function menuCir_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to menuCir (see VARARGIN)

% Choose default command line output for menuCir
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global nvars;
global slash;
global metodos;
global ParDados;
global VarDados;
global NameMenu;
global VarNames;
global circuito;
global BestRes;
global mudamenu;
global caminho;
global family;

% inicializa Nome
set(handles.panel, 'Title', NameMenu);
set(handles.tablePar,'Data', ParDados);
set(handles.tableVar, 'Data', VarDados)
set(handles.tableVar, 'RowName', VarNames)

% set the methods
set(handles.popupmenuRun, 'string', metodos );
set(handles.popupmenuIni, 'string', [metodos 'rand']);
set(handles.editX, 'string', '1.0');   

% coloca as condicoes no circuito
contents = cellstr(get(handles.listboxTop,'String'));
circuito = contents{get(handles.listboxTop,'Value')};
cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'condin.mat'];
aux = ParDados;

if exist(cond)
  load(cond);
  if (exist('ParDados') && (mudamenu == 0))
    for i=1: min(length(aux), length(ParDados(:,1)))
        aux{i, 2} = ParDados{i,2};
    end;
    ParDados = aux;
    set(handles.tablePar,'Data', ParDados);
  else 
    fprintf('Esta Com tabela de Parametros nao Atualizada\n');
  end;
  if exist('VarDados')
      aux=VarDados;
       if (length(VarDados(1, :)) == 4) 
           aux = [VarDados, cell(length(VarDados(:,1)), 1)];
           aux(:, 5) = {'0'};
       end;
      set(handles.tableVar, 'Data', aux); 
  end; 
  if exist('VarNames') set(handles.tableVar, 'RowName', VarNames); end; 
  if exist('score', 'var')   set(handles.editSco, 'String',score); end;
end

%Load Bestresults
cond = [caminho, slash, 'Circuits' slash, family, slash circuito, slash, 'Bestini.mat'];
if exist(cond) 
    load(cond);
end;


% UIWAIT makes menuCir wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = menuCir_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listboxTop.
function listboxTop_Callback(hObject, eventdata, handles)
% hObject    handle to listboxTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxTop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxTop
global slash;
global ParDados;
global circuito;
global BestRes;
global mudamenu;
global caminho;
global family;

% save found BestRes
if exist('BestRes')
    cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash,'Bestini'];
    save(cond, 'BestRes');
end;

contents = cellstr(get(hObject,'String'));
circuito = contents{get(hObject,'Value')};

%Load Bestresults
cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'Bestini.mat'];
if exist(cond) 
    load(cond);
%else BestRes = { [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]};
end;
BestRes;

figureon = get(handles.radiobuttonFig,'Value');

% show the circuit figure
if figureon 
    figure(103); set(103, 'Name', circuito, 'NumberTitle', 'off', 'MenuBar', 'none'); 
    cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'Circuito.png']; 
    if ~(exist(cond, 'file'))
     cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'Circuito.gif']; 
     if ~(exist(cond, 'file'))
       cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'funcTest.gif']; 
       if ~(exist(cond, 'file'))
         cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'funcTest.png']; 
       end;
     end;
    end;
    imshow(cond, 'InitialMagnification', 50, 'Border', 'tight');
    %imshow([caminho, slash, 'Circuits' slash, family, circuito, slash, 'Circuito.png'], 'InitialMagnification', 50, 'Border', 'tight');
end;

% set the default conditions 
set(handles.editX, 'string', '1.0');   
cond = [caminho, slash, 'Circuits' slash, family, slash circuito, slash, 'condin.mat'];
aux = ParDados;
 

if exist(cond)
  load(cond);
  if (exist('ParDados') && (mudamenu == 0))
    for i=1: min(length(aux), length(ParDados(:, 1)))
        aux{i, 2} = ParDados{i,2};
    end;
    ParDados = aux;
    set(handles.tablePar,'Data', ParDados);
  else 
    fprintf('Esta Com tabela de Parametros nao Atualizada\n');
    ParDados = aux;
  end;
  
 % if exist('ParDados') set(handles.tablePar,'Data', ParDados); end;
 % if exist('VarDados') set(handles.tableVar, 'Data', VarDados); end; 
  if exist('VarDados')
     aux=VarDados;
     if (length(VarDados(1, :)) == 4) 
         aux = [VarDados, cell(length(VarDados(:,1)), 1)];
         aux(:, 5) = {'0'};
     end;
     set(handles.tableVar, 'Data', aux); 
  end; 
  if exist('VarNames') set(handles.tableVar, 'RowName', VarNames); end; 
  if exist('score', 'var')   set(handles.editSco, 'String',score); end;
end;
    
% --- Executes during object creation, after setting all properties.
function listboxTop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
a = dir;
u=(cellfun(@(x)(x==1),{a.isdir})==1);
u(1)= 0; u(2)=0; 
s={ a(u).name };
set(hObject, 'String', s);


% --- Executes on button press in pushbuttonSav.
function pushbuttonSav_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global slash;
global circuito;
global caminho;
global family;

cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'condin'];

ParDados = get(handles.tablePar, 'Data');
VarDados = get(handles.tableVar, 'Data');
VarNames = get(handles.tableVar, 'RowName');
score =    get(handles.editSco, 'String');


save (cond, 'ParDados', 'VarDados', 'VarNames', 'score');

% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global modelo;
global genesUB;
global genesLB;
global dif;
global snap;
global inicialSol;
global Best;
global cont;
global nvars;
global modo;
global ParDados;
global fitness;
%global circuito;

cont=0;
Best = struct('score',{Inf('double')},'scoreT',{Inf('double')},'parameters', zeros(1, nvars));

% get the model
contents = cellstr(get(handles.listboxMod,'String'));
modelo = contents{get(handles.listboxMod,'Value')};

% get the method
contents = cellstr(get(handles.popupmenuRun,'String'));
modo= contents{get(handles.popupmenuRun,'Value')};

UBX = str2num(get(handles. editX, 'String'));

% get the variable limits
VarDados = (get(handles.tableVar, 'Data'));
ParDados = (get(handles.tablePar, 'Data'));
dif=0; genesLB=0; genesUB=0; inicialSol=0; snap =0;

nvars=0;

for j=1:length(VarDados(:, 1))
   genesLB(j) = str2num(VarDados{j, 2});
   genesUB(j) = str2num(VarDados{j, 3});
   inicialSol(j) = str2num(VarDados{j, 4});
   snap(j) = str2num(VarDados{j, 5});
% remove variables where LB and Ub are equal
   if (genesLB(j) ~= genesUB(j))  
        nvars = nvars+1;
        dif(j) = (genesUB(j)*UBX - genesLB(j));
    else dif(j) = 0;
    end;
end;

% determina qual metaeuristica será aplicada e faz a chamada
MetaHeu;

% --- Executes on button press in pushbuttonEx.
function pushbuttonEx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonEx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global BestRes;
global slash;
global circuito;
global caminho;
global family;

%save found BestRes
if exist('BestRes')
    cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash,'Bestini'];
    save(cond, 'BestRes');
end;

%delete graphics
delete(handles.figure1);
figure(103);
delete(103);
eval(['cd ..', slash, '.. ']);


% --- Executes on button press in radiobuttonFig.
function radiobuttonFig_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global slash;
global circuito;
global caminho;
global family;

if get(hObject,'Value');
          set(handles.radiobuttonFig, 'string', 'on');
          figure(103); set(103, 'Name', circuito, 'NumberTitle', 'off', 'MenuBar', 'none'); 
          cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'Circuito.png']; 
          if ~(exist(cond, 'file'))
           cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'Circuito.gif']; 
           if ~(exist(cond, 'file'))
             cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'funcTest.gif']; 
             if ~(exist(cond, 'file'))
              cond = [caminho, slash, 'Circuits' slash, family, slash, circuito, slash, 'funcTest.png']; 
             end;
           end;
         end;

         imshow(cond, 'InitialMagnification', 50, 'Border', 'tight');

else
          set(handles.radiobuttonFig, 'string', 'off');
          figure(103);
          delete(103);
end;

% --- Executes on selection change in popupmenuRun.
function popupmenuRun_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuRun contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuRun


% --- Executes during object creation, after setting all properties.
function popupmenuRun_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuIni.
% load the initial condition
function popupmenuIni_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuIni (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuIni contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuIni
global BestRes;
global metodos;

VarDados= (get(handles.tableVar, 'Data'));
nvars = length(VarDados);

contents = cellstr(get(hObject,'String'));
modo = contents{get(hObject,'Value')};

% determina qual é o metodo 
aux = [metodos 'rand'];
for j=1:length(aux)
    if length(modo) == length (aux{j})
        if modo==aux{j}  i=j;
     end;
    end;
 end;
 

% set the inicial values and the score
if i == length(aux)
 % get the variable limits

   for j=1:nvars
    genesLB = str2num(VarDados{j, 2});
    genesUB = str2num(VarDados{j, 3});
    VarDados{j, 4} = num2str(genesLB+ rand*(genesUB-genesLB), 8);
   end;
   set(handles.tableVar, 'Data', VarDados);
   set(handles.editSco, 'String', ' ');
    
elseif exist('BestRes')
     if isfield(BestRes{i}, 'parameters')
      if ( length(BestRes{i}.parameters) ==  nvars)  
         for j=1:nvars VarDados{j, 4} = num2str(BestRes{i}.parameters(j), 8);
         end;
         set(handles.tableVar, 'Data', VarDados);
         set(handles.editSco, 'String', num2str(BestRes{i}.scoreT, 4));
       end;  
     end;
 end;      
 
 
 % --- Executes during object creation, after setting all properties.
function popupmenuIni_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuIni (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSco_Callback(hObject, eventdata, handles)
% hObject    handle to editSco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSco as text
%        str2double(get(hObject,'String')) returns contents of editSco as a double


% --- Executes during object creation, after setting all properties.
function editSco_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editX_Callback(hObject, eventdata, handles)
% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX as text
%        str2double(get(hObject,'String')) returns contents of editX as a double


% --- Executes during object creation, after setting all properties.
function editX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxMod.
function listboxMod_Callback(hObject, eventdata, handles)
% hObject    handle to listboxMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxMod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxMod


% --- Executes during object creation, after setting all properties.
function listboxMod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global slash;
global modelsD;

c = ['..' slash '..' slash modelsD];
a =eval('dir(c)');
u=(cellfun(@(x)(x==1),{a.isdir})~=1);
u(1)= 0; u(2)=0; 
s={ a(u).name };
set(hObject, 'String', s);

% --- Executes on key press with focus on tableVar and none of its controls.
function tableVar_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to tableVar (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

VarDados=get(handles.tableVar,'Data');
VarNames=get(handles.tableVar,'RowName');
tam=length(VarDados(:,1));
eventdata.Key;

%insert a new row in the Variale Description Table
if (strcmp(eventdata.Key,  'insert'))
    VarDados(tam+1, :) = VarDados(tam, :);
    VarNames{tam+1}= ['x' num2str(tam+1)];
 end;

 % remove the last row in the Variale Description Table
 if strcmp(eventdata.Key, 'f1')
    VarDados= VarDados(1: (tam-1), :);
    VarNames= VarNames(1: (tam-1));
end;
set(handles.tableVar,'Data', VarDados);
set(handles.tableVar,'RowName', VarNames);


% --- Executes on button press in pushbuttonCir.
function pushbuttonCir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global slash;
global circuito;
global simpr;
global family;
global caminho;

% Edit the file .sp, for Hspice, or .cir for Eldo
switch simpr
case 'HSP'
  cond = [caminho, slash, 'Circuits' slash, family, slash circuito, slash, 'circuito.sp'];
case 'LTSP'
  cond = [caminho, slash, 'Circuits' slash, family, slash circuito, slash, 'circuito.asc'];
case 'Eldo'
 cond = [caminho, slash, 'Circuits' slash, family, slash circuito, slash, 'circuito.cir'];
end;

cond1 = [caminho, slash, 'Circuits' slash, family, slash circuito, slash, 'funcTest.m']; 
if exist(cond)
  edit(cond); 
else
  edit(cond1);
end;

% --- Executes on button press in pushbuttonPar.
function pushbuttonPar_Callback(hObject, eventdata, handles)

global slash;
global circuito;
global namext;
global family;
global caminho;

% Edit the file paramop
cond = [caminho, slash, 'Circuits', slash, family, slash circuito, slash, 'paramop', namext];
edit(cond);


% --- Executes on button press in pushbuttonParT.
function pushbuttonParT_Callback(hObject, eventdata, handles)

global slash;
global circuito;
global namext;
global family;
global caminho;

% Edit the file paramopT
cond = [caminho, slash, 'Circuits' slash, family, slash circuito, slash, 'paramopT' namext];
edit(cond);


% --- Executes when panel is resized.
function panel_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
