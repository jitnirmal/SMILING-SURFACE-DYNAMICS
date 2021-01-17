function varargout = VolSurface(varargin)
% VOLSURFACE M-file for VolSurface.fig
%      VOLSURFACE, by itself, creates a new VOLSURFACE or raises the existing
%      singleton*.
%
%      H = VOLSURFACE returns the handle to a new VOLSURFACE or the handle to
%      the existing singleton*.
%
%      VOLSURFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOLSURFACE.M with the given input arguments.
%
%      VOLSURFACE('Property','Value',...) creates a new VOLSURFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VolSurface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VolSurface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%f
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VolSurface

% Last Modified by GUIDE v2.5 26-Jun-2012 17:08:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @VolSurface_OpeningFcn, ...
    'gui_OutputFcn',  @VolSurface_OutputFcn, ...
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

% --- Executes just before VolSurface is made visible.
function VolSurface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VolSurface (see VARARGIN)

addpath('datasrv','npr','iv','svi');

% Choose default command line output for VolSurface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial5 plot - only do when we are invisible
% so window can get raised using VolSurface.
if strcmp(get(hObject,'Visible'),'off')
    %  plot(rand(5));
end

% UIWAIT makes VolSurface wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global gOptionData;
global gOptionStore;
global gTenors;
global gContract;
global gFileName;
global gDate;
global gRecDateStr;

addpath('iv','datasrv');
disp(' Fetching data... ');
tic
gOptionStore = load('..\db\optiondata.csv');
toc
[~, recDateStr]=xlsread('..\db\recDates.xlsx');
gRecDateStr=cellstr(datestr(datenum(recDateStr)));

disp(' Fetched data... ');

gContract='SPX';
%date=get(handles.dateEditBox, 'String');
gDate='15-Sep-2011';

[gOptionData,gTenors]=getOptiondata(gDate);
set(handles.txtTenor,'String',gTenors);


function [tenors,optionData] = getOptiondata(date)
global gOptionStore;
global gTenors;
global gRecDateStr;
record=find((ismember(gRecDateStr,date))==1);
if(record~=0)
    filter=find(gOptionStore(:,10)==record);
    optionData=gOptionStore(filter,:);
    tenors=unique(optionData(2:end,4));
else
    msg='Please refine your search bw 2-May-11 30-Mar-12';
    msgbox(msg,strcat('NO DATA for ',date));
end


% --- Outputs from this function are returned to the command line.
function varargout = VolSurface_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbuttonNPR.
function pushbuttonNPR_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNPR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes1);
cla(handles.axes2);
date=get(handles.dateEditBox, 'String');
global gContract;
global gOptionData;
global gTenors;


filename=strcat('..\mat\npr\',gContract,'-',date,'.mat')
[gTenors,gOptionData]=getOptiondata(date);
set(handles.txtTenor,'String',gTenors);
[SO]=loadSurface(filename,gOptionData);
axes(handles.axes2);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using VolSurface.


surf(SO.fMon,SO.fMat,SO.fIV)
%colormap hsv
%alpha(0.3)
hold on
iv=SO.fIVf;
%scatter3(iv.fmoneyness(iv.fcallFilter),iv.fmaturity(iv.fcallFilter),iv.fimpliedVol(iv.fcallFilter), '.r')
%scatter3(iv.fmoneyness(iv.fputFilter),iv.fmaturity(iv.fputFilter),iv.fimpliedVol(iv.fputFilter),'.b')

xlabel('Moneyness')
ylabel('Time to Maturity')
zlabel('Implied Volatility')

x=iv.fmoneyness;
y=iv.fmaturity;
z=iv.fimpliedVol;
firstmon=0.8;
lastmon=1.2;
firstmat=0;
lastmat=1;
stepwidth=[0.02 1/52];
lengthmon=ceil((lastmon-firstmon)/stepwidth(1));
lengthmat=ceil((lastmat-firstmat)/stepwidth(2));
xlin=linspace(0.8,1.2,lengthmon+1);
ylin=linspace(0,1,lengthmat+1);

[X,Y] = meshgrid(xlin,ylin);
f = TriScatteredInterp(x,y,z);
Z = f(X,Y);

axes(handles.axes1);
surf(X,Y,Z);
colormap hsv
xlabel('Moneyness')
ylabel('Time to Maturity')
zlabel('Implied Volatility')

hold off

%popup_sel_index = get(handles.volpopupmenu, 'Value');
%switch popup_sel_index
%    case 1
%
%end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in volpopupmenu.
function volpopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to volpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns volpopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from volpopupmenu


% --- Executes during object creation, after setting all properties.
function volpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'SPX'});

% --- Executes on button press in pushbuttonSVI.
function pushbuttonSVI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSVI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes6);


global gOptionData;
global gTenors;
usePrecomputedVol = get(handles.cbUsePCVol,'Value');
date=get(handles.dateEditBox, 'String');
[gTenors,optionData] = getOptiondata(date);
set(handles.txtTenor,'String',gTenors);
tenor = gTenors(get(handles.txtTenor,'Value'));

[optionChain,FitX,FitY] = sviVol(optionData,tenor,usePrecomputedVol);

axes(handles.axes6);
plot(optionChain(:,5),optionChain(:,4),'o',...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',2);
xlabel('Moneyness Log(K/F)');
ylabel('Vol (%)');
hold on;
plot(FitX,FitY,'LineWidth',2);



% --- Executes on selection change in txtTenor.
function txtTenor_Callback(hObject, eventdata, handles)
% hObject    handle to txtTenor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns txtTenor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from txtTenor


% --- Executes during object creation, after setting all properties.
function txtTenor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTenor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbUsePCVol.
function cbUsePCVol_Callback(hObject, eventdata, handles)
% hObject    handle to cbUsePCVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbUsePCVol


% --- Executes on button press in btnCal.
function btnCal_Callback(hObject, eventdata, handles)
% hObject    handle to btnCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uicalendar('Weekend', [1 0 0 0 0 0 1], ...
    'SelectionType', 1, ...
    'OutputDateFormat',1,...
    'DestinationUI', handles.dateEditBox);



function dateEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to dateEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dateEditBox as text
%        str2double(get(hObject,'String')) returns contents of dateEditBox as a double


% --- Executes during object creation, after setting all properties.
function dateEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dateEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',datestr(now,1));
