function varargout = poisson_interface(varargin)
% POISSON_INTERFACE MATLAB code for poisson_interface.fig
%      POISSON_INTERFACE, by itself, creates a new POISSON_INTERFACE or raises the existing
%      singleton*.
%
%      H = POISSON_INTERFACE returns the handle to a new POISSON_INTERFACE or the handle to
%      the existing singleton*.
%
%      POISSON_INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POISSON_INTERFACE.M with the given input arguments.
%
%      POISSON_INTERFACE('Property','Value',...) creates a new POISSON_INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before poisson_interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to poisson_interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help poisson_interface

% Last Modified by GUIDE v2.5 15-Feb-2020 16:16:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @poisson_interface_OpeningFcn, ...
                   'gui_OutputFcn',  @poisson_interface_OutputFcn, ...
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
h = findall(groot, 'Type', 'figure');
set(h,'Color', [0.5 0.5 0.5]);
% End initialization code - DO NOT EDIT


% --- Executes just before poisson_interface is made visible.
function poisson_interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to poisson_interface (see VARARGIN)

% Choose default command line output for poisson_interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%handles.axes1.XAxis.Visible = 'off';


% UIWAIT makes poisson_interface wait for user response (see UIRESUME)
 %uiwait(handles.figure1);
 

% --- Outputs from this function are returned to the command line.
function varargout = poisson_interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file1,path1] = uigetfile('*.jpg;*.png', 'select an image');
imageS = imread(fullfile(path1,file1));
imageS = im2double(imageS(:,:,1));
handles.imageS = imageS;
guidata(gca, handles);
axesIm = imshow(handles.imageS, 'Parent', handles.axes1);
set(axesIm, 'ButtonDownFcn', @axes1_ButtonDownFcn);
%handles.axes1.XAxis.Visible = 'off';
%handles.axes1.YAxis.Visible = 'off';



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file2,path2] = uigetfile('*.jpg; *.png', 'select T image');
imageT = imread(fullfile(path2,file2));
imageT = im2double(imageT(:,:,1));
handles.imageT = imageT;
guidata(gca, handles);
axesIm2 = imshow(handles.imageT, 'Parent', handles.axes2);
set(axesIm2, 'ButtonDownFcn', @axes2_ButtonDownFcn);
% handles.axes2.XAxis.Visible = 'off';
% handles.axes2.YAxis.Visible = 'off';


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
maskS = Mask();
maskS.associate_im = handles.imageS;
cut = maskS.matrix.*maskS.associate_im ;
handles.cut = cut;
handles.maskS = maskS;
guidata(gca,handles);
imshow(handles.maskS.matrix ,'Parent', handles.axes3);
% handles.axes3.XAxis.Visible = 'off';
% handles.axes3.YAxis.Visible = 'off';



 % --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
maskT = Mask();
maskT.associate_im = handles.imageT;
cutT = maskT.matrix.*handles.imageT;
handles.maskT = maskT;
handles.maskS.pos_to_move = maskT.pos;
guidata(gca,handles);
imshow(cutT, 'Parent', handles.axes4);
% handles.axes4.XAxis.Visible = 'off';
% handles.axes4.YAxis.Visible = 'off';


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.axes5);
[im, rect] = clonage_v1(handles.maskS, handles.maskT);
imshow(handles.maskS.cut_im, 'Parent', handles.axes3);
[sol, image] = clonage_v2(handles.maskS, handles.maskS.associate_im, rect, handles.maskT);
imshow(image, 'Parent', handles.axes5);
imshow(sol, 'Parent', handles.axes4);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sol, img] = clonage_v2(maskS, im, rect, maskT)
        new_system = FDSystem(maskS);
    new_system.create_matrix(maskS, rect);
    sol = new_system.solve(rect);
    
    maskS.cut_im = sol;
    maskS.matrix = maskS.mask_rect(maskS.matrix);
    adjust_size(maskS, maskT);
    maskS.move_roi();
    mask2 = maskS.invert_mask();
    maskT2 = mask2.*maskT.associate_im;
    img = maskS.cut_im+maskT2;
    
function [im, rect] =  clonage_v1(maskS, maskT)
maskS.cut_im= maskS.matrix.*maskS.associate_im;

adjust_size(maskS, maskT);
rect = maskS.transform_to_rect(maskS.associate_im);
maskS.move_roi();
mask2 = maskS.invert_mask();
maskT2 = mask2.*maskT.associate_im;

im = maskS.cut_im+maskT2;
new_cut = maskS.transform_to_rect(im);
maskS.cut_im = new_cut;
new_mask = maskS.transform_to_rect(maskS.matrix);
maskS.matrix = new_mask;
maskS.find_boundaries();



function adjust_size(maskS, maskT)
masko1 = maskS.cut_im;
masko = maskS.matrix;
maskt = maskT.matrix;
[w1, h1]  = size(maskS.matrix);
[w2, h2] = size(maskT.matrix);
d_x = w1-w2;
d_y = h1-h2;
if(d_x<=0)
    new_mat = zeros([abs(d_x), h1]);
    masko = cat(1,maskS.matrix,new_mat);
    masko1 = cat(1,maskS.cut_im,new_mat);
else
    new_mat = zeros([d_x, h2]);
    maskt = cat(1,maskT.matrix, new_mat);
end
[w1, h1] = size(masko);
if(d_y <=0) 
    new_mat = zeros([w1, abs(d_y)]);
    masko = cat(2,masko, new_mat);
    masko1 = cat(2,masko1, new_mat);
else
    new_mat = zeros([w1, d_y]);
    maskt = cat(2,maskt, new_mat);
end
maskS.cut_im = masko1;
maskS.matrix = masko;
maskT.matrix = maskt;

