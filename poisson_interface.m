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

% Last Modified by GUIDE v2.5 10-Mar-2020 10:37:25

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
hideAxes(handles);

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


% --- Executes on button press in openImSButton.
% Choose an image source to open, and display it in axes1
function openImSButton_Callback(hObject, eventdata, handles)
% hObject    handle to openImSButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file1,path1] = uigetfile('*.jpg;*.png', 'select an image');
imageS = imread(fullfile(path1,file1));
imageS = im2double(imageS(:,:,1));
handles.imageS = imageS;
guidata(gca, handles);

axesIm = imshow(handles.imageS, 'Parent', handles.axes1);
set(axesIm, 'ButtonDownFcn', @axeImS_ButtonDownFcn);
hideAxes(handles);



% --- Executes on button press in openImTButton.
%Choose an image Target to open, and display it in axes2
function openImTButton_Callback(hObject, eventdata, handles)
% hObject    handle to openImTButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file2,path2] = uigetfile('*.jpg; *.png', 'select T image');
imageT = imread(fullfile(path2,file2));
imageT = im2double(imageT(:,:,1));
handles.imageT = imageT;
guidata(gca, handles);
axesIm2 = imshow(handles.imageT, 'Parent', handles.axes2);
set(axesIm2, 'ButtonDownFcn', @axeImT_ButtonDownFcn);
hideAxes(handles);


% --- Executes on mouse press over axes background.
% Create a mask Object, with the followed properties : 
% -------------- handles.imageS as the associate image to the mask
%--------------- maskS as the black&white mask
% The mask is created in the class (see the constructor)
%Display the white&black mask created
function axeImS_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
maskS = Mask();
maskS.associate_im = handles.imageS;
handles.maskS = maskS;
s_init = maskS.save_mask_settings();
handles.s_init = s_init;
guidata(gca,handles);
imshow(handles.maskS.matrix ,'Parent', handles.axes3);
hideAxes(handles);


 % --- Executes on mouse press over axes background.
 % Create a mask Object associated to the target im, with the followed properties : 
 % -------------- handles.imageT as the associate image to the mask
 %--------------- maskT as the black&white mask
 % The mask is created in the class (see the constructor)
 %Display the white&black mask created
 %UPDATE : Fill the property "pos_to_move" to maskS. = add the new position
 %to move for the maskS
function axeImT_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
maskT = Mask();
maskT.associate_im = handles.imageT;
maskT.cut_im = maskT.matrix.*handles.imageT;
handles.maskT = maskT;
t_init = maskT.save_mask_settings();
handles.t_init = t_init;
handles.maskS.pos_to_move = maskT.pos;
handles.s_init.pos_to_move = maskT.pos;
guidata(gca,handles);
imshow(handles.maskT.cut_im, 'Parent', handles.axes4);
hideAxes(handles);

% --- Executes on button press in pasteButton.
% First : simple cut/paste with clonage_v1.
% Then : blend with clonage_v2 function
% Display : 
%---------- on axes3 :the cut image without any modification (cut/paste only)
%---------- on axes4 : applied modifications on the cut image 
%---------- on axes 5: The final result the cut image is paste on the bg
%one
function pasteButton_Callback(hObject, eventdata, handles)
% hObject    handle to pasteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.DFButton.Value == 1)
    handles = guidata(handles.axes5);
    [im, rect] = clonage_v1(handles.maskS, handles.maskT);
    [sol, image, new_cut] = clonage_v2(handles.maskS, im, rect, handles.maskT);
    imshow(new_cut, 'Parent', handles.axes3);
    imshow(image, 'Parent', handles.axes5);
    imshow(sol, 'Parent', handles.axes4);
    
elseif (handles.FourierButton.Value == 1)
    [im_i, im_j, sol] = fourier_clonage(handles.imageS, handles.imageT, handles.maskS, handles.maskT);
    imshow(im_i, 'Parent', handles.axes4);
    imshow(im_j, 'Parent', handles.axes3);
    imshow(sol, 'Parent', handles.axes5);
end
hideAxes(handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sol, img, new_cut] = clonage_v2(maskS, im, rect, maskT)
    %function clonage_v2
    %Create the smallest rectangle around the ROI in the cut_image 
    % Create the smallest rectangle around the ROI in the mask
    % Create a FDSystem object to solve the equation
    %Solve the equation
    % Transform the mask, adjust size & update the actual position of ROI
    new_cut = maskS.transform_to_rect(im); % resize I into a rect (demarcation)
    maskS.cut_im = new_cut;
    maskS.matrix = maskS.transform_to_rect(maskS.matrix);% resize b&w mask
    
    new_system = FDSystem(maskS);
    new_system.create_matrix(maskS, rect);
    sol = new_system.solve(rect);
    
    maskS.cut_im = sol.*maskS.matrix;
    maskS.adjust_size(maskT);
    [row, col] = find(maskS.matrix);
    maskS.pos = [min(row), min(col)];
    
    maskS.move_roi();
    mask2 = maskS.invert_mask();
    maskT2 = mask2.*maskT.associate_im;
    img = maskS.cut_im+maskT2;
    
function [im, rect] =  clonage_v1(maskS, maskT)
    %Function clonage_v1 : Does a cut/paste action without any modifications
    %Update properties of the mask (cut_im) 
    % Adjust the size of the smaller mask, then the dimensions of the two
    % agrees
    % Creates the smallest rect around the selection 
    % Move the ROI to the wanted position on the bg image
    % UPDATE  : this new position is now the new pos_to_move
    %Invert the mask to create complementaries masks && create the mask
    %associate to bg image
    % Add the two corresponding masks, perfectly complementary.
maskS.cut_im= maskS.matrix.*maskS.associate_im;
maskS.adjust_size(maskT);
rect = maskS.transform_to_rect(maskS.associate_im);% resize S into a rect 
maskS.move_roi();
[k,l] = find(maskS.matrix);
maskS.pos_to_move = [min(l), min(k)];
mask2 = maskS.invert_mask();
maskT2 = mask2.*maskT.associate_im;
im = maskS.cut_im+maskT2;

function [im_i, im_j, sol] = fourier_clonage(imS, imT, maskS, maskT)
     stockage =maskS.matrix;
     pos = maskS.pos;
     pos_to_move= maskS.pos_to_move;
     f = Fourier(imS, imT);
     maskS.associate_im = f.grad_S_i;
     maskT.associate_im = f.grad_T_i;
     size(maskS.matrix);
     [im_i, ~] = clonage_v1(maskS,maskT);% IMAGE I COLLEE
     fprintf('Image I paste\n');
     maskS.associate_im = f.grad_S_j;
     maskT.associate_im = f.grad_T_j;
     fprintf('Reinitialisation\n');
     maskS.shift_done =[0,0];
     maskS.pos = pos;
     maskS.matrix = stockage;
     maskS.pos_to_move = pos_to_move;
     fprintf('Done\n');
     [im_j, ~] = clonage_v1(maskS, maskT);% IMAGE J COLLEE

     sol = f.solve(im_i, im_j);

function hideAxes(handles)
    handles.axes1.XAxis.Visible = 'off';
    handles.axes2.XAxis.Visible = 'off';
    handles.axes3.XAxis.Visible = 'off';
    handles.axes4.XAxis.Visible = 'off';
    handles.axes5.XAxis.Visible = 'off';
    handles.axes1.YAxis.Visible = 'off';
    handles.axes2.YAxis.Visible = 'off';
    handles.axes3.YAxis.Visible = 'off';
    handles.axes4.YAxis.Visible = 'off';
    handles.axes5.YAxis.Visible = 'off';

% --- Executes on button press in DFButton.
function DFButton_Callback(hObject, eventdata, handles)
% hObject    handle to DFButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DFButton
if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
    handles.maskS.reload_pdt_mask(handles.s_init);
    handles.maskT.reload_pdt_mask(handles.t_init);
    fprintf('done');
elseif(isfield(handles, 'maskS') && ~isfield(handles, 'maskT'))
    maskS = Mask();
    handles.maskS = maskS;
end

% --- Executes on button press in FourierButton.
function FourierButton_Callback(hObject, eventdata, handles)
% hObject    handle to FourierButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % Hint: get(hObject,'Value') returns toggle state of FourierButton
 if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
     handles.maskS.reinitialize_mask(handles.maskT);
     fprintf('done');
 end

% --- Executes on button press in zoom_im.
function zoom_im_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zoom_im
if( handles.zoom_im.Value == 1)
    axes(handles.axes5);
    h =  zoom(handles.axes5);
   h.Enable = 'on';
else
    zoom off
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
