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

% Last Modified by GUIDE v2.5 14-Mar-2020 19:26:51

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
function poisson_interface_OpeningFcn(hObject, ~, handles, varargin)
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
function varargout = poisson_interface_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openImSButton.
% Choose an image source to open, and display it in axes1
function openImSButton_Callback(~, ~, handles)
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
set(handles.error_text, 'String', 'Image to paste loaded, please select the background image');
hideAxes(handles);



% --- Executes on button press in openImTButton.
%Choose an image Target to open, and display it in axes2
function openImTButton_Callback(~, eventdata, handles)
% hObject    handle to openImTButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file2,path2] = uigetfile('*.jpg; *.png', 'select T image');
imageT = imread(fullfile(path2,file2));
imageT = im2double(imageT(:,:,1));
handles.imageT = imageT;
guidata(gca, handles);

slider3_CreateFcn(handles.slider3, eventdata, handles);
slider4_CreateFcn(handles.slider4, eventdata, handles);

axesIm2 = imshow(handles.imageT, 'Parent', handles.axes2);
set(axesIm2, 'ButtonDownFcn', @axeImT_ButtonDownFcn);
set(handles.error_text, 'String', 'Background image loaded, please select the region to cut in the first image');
hideAxes(handles);


% --- Executes on mouse press over axes background.
% Create a mask Object, with the followed properties : 
% -------------- handles.imageS as the associate image to the mask
%--------------- maskS as the black&white mask
% The mask is created in the class (see the constructor)
%Display the white&black mask created
function axeImS_ButtonDownFcn(~, ~, ~)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
maskS = Mask(handles.imageS);
s_init = maskS.save_mask_settings();
handles.maskS = maskS;
handles.s_init = s_init;
guidata(gca,handles);

imshow(handles.maskS.matrix ,'Parent', handles.axes3);
set(handles.error_text, 'String', 'Region to cut selected, please click on the second image to select the paste region');
hideAxes(handles);


 % --- Executes on mouse press over axes background.
 % Create a mask Object associated to the target im, with the followed properties : 
 % -------------- handles.imageT as the associate image to the mask
 %--------------- maskT as the black&white mask
 % The mask is created in the class (see the constructor)
 %Display the white&black mask created
 %UPDATE : Fill the property "pos_to_move" to maskS. = add the new position
 %to move for the maskS
function axeImT_ButtonDownFcn(~, ~, ~)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
maskT = Mask(handles.imageT);
t_init = maskT.save_mask_settings();

handles.maskT = maskT;
handles.t_init = t_init;

handles.maskS.pos_to_move = maskT.pos;
handles.s_init.pos_to_move = maskT.pos;
guidata(gca,handles);

imshow(handles.maskT.cut_im, 'Parent', handles.axes4);
set(handles.error_text, 'String', 'Paste region selected, you can choose the method & then click on the paste button');
hideAxes(handles);

% --- Executes on button press in pasteButton.
% First : simple cut/paste with copyPaste.
% Then : blend with clonage_v2 function
% Display : 
%---------- on axes3 :the cut image without any modification (cut/paste only)
%---------- on axes4 : applied modifications on the cut image 
%---------- on axes 5: The final result the cut image is paste on the bg
%one
function pasteButton_Callback(~, ~, handles)
% hObject    handle to pasteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.axes5);

if (handles.slider3.Value == 0 && handles.slider4.Value == 1)
    set(handles.slider3, 'Value', -handles.maskT.pos(1,1));
    set(handles.slider4, 'Value', handles.maskS.pos(1,2));
    handles.shift3 = 0;
    handles.shift4 = 0;
    guidata(gca, handles);
end
if(handles.DFButton.Value == 1)
    rect = handles.maskS.transform_to_rect(handles.maskS.associate_im);% resize S into a rect 
    [im] = copyPaste(handles.maskS, handles.maskT, handles.maskS.associate_im, handles.maskT.associate_im);
    [sol, image, new_cut] = clonage_v2(handles, handles.maskS, im, rect, handles.maskT);
    imshow(new_cut, 'Parent', handles.axes3);
    imshow(image, 'Parent', handles.axes5);
    imshow(sol, 'Parent', handles.axes4);
    
elseif (handles.FourierButton.Value == 1)
    [~, ~, sol] = fourier_clonage(handles, handles.maskS, handles.maskT);
    imshow(sol, 'Parent', handles.axes5);
end
hideAxes(handles);


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
function DFButton_Callback(~, ~, handles)
% hObject    handle to DFButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DFButton
size(handles.maskT.associate_im, 2)
if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
    handles.maskS.reload_pdt_mask(handles.s_init);
    handles.maskT.reload_pdt_mask(handles.t_init);
    fprintf('done');
elseif(isfield(handles, 'maskS') && ~isfield(handles, 'maskT'))
    maskS = Mask();
    handles.maskS = maskS;
end
set(handles.error_text, 'String', 'DF method selected');
set(handles.axes4, 'Value', handles.maskT.pos(1,2));

% --- Executes on button press in FourierButton.
function FourierButton_Callback(~, ~, handles)
% hObject    handle to FourierButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % Hint: get(hObject,'Value') returns toggle state of FourierButton
 if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
     handles.maskS.reinitialize_mask(handles.maskT);
     handles.maskT.associate_im = handles.imageT;
     handles.maskS.associate_im = handles.imageS;
     fprintf('done\n');
 end
 set(handles.error_text, 'String', 'Fourier method selected');
 

% --- Executes on button press in zoom_im.
function zoom_im_Callback(~, ~, handles)
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
set(handles.error_text, 'String', 'Zoom mode');


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider           
 handles = guidata(handles.axes5);
        y_1 = handles.maskT.pos(1,2);
        y_2 = get(hObject, 'Value')
        
        handles.shift3 = abs(y_2)-y_1;
        guidata(gca, handles);
        handles.maskT.pos(:,2) = handles.maskT.pos(:,2)+handles.shift3;
        handles.maskS.reinitialize_mask(handles.maskT); 
        set(handles.slider3,'Value', -handles.maskT.pos(1,2));
        pasteButton_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, ~, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
if(isfield(handles, 'imageT'))
[~,height] = size(handles.imageT);
set(hObject, 'Min',-height);
else
    set(hObject, 'Min', -100);
end
set(hObject, 'Max', 0);
set(hObject, 'Value', 0);

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% Find the distance between & then shift all position to the new_one
    handles = guidata(handles.axes5);
%     handles.maskT.reload_pdt_mask(handles.t_init);
    y_1 = handles.maskT.pos(1,1);
    y_2 = get(hObject, 'Value');
    handles.shift4 = y_2-y_1;
    guidata(gca, handles)
    handles.maskT.pos(:,1) = handles.maskT.pos(:,1)+handles.shift4;
    handles.maskS.reinitialize_mask(handles.maskT);
    handles.maskT.associate_im = handles.imageT;
    handles.maskS.associate_im = handles.imageS;
    pasteButton_Callback(hObject, eventdata, handles);
    
% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, ~, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
if(isfield(handles, 'imageT'))
[width, ~] = size(handles.imageT);
set(hObject, 'Max',width);
else
    set(hObject, 'Max', 10);
end
set(hObject, 'Min', 1);
set(hObject, 'Value', 1);


% --- Executes on button press in change_sel.
function change_sel_Callback(~, ~, handles)
% hObject    handle to change_sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of change_sel

 if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
    handles.maskT.reload_pdt_mask(handles.t_init);
elseif(isfield(handles, 'maskS') && ~isfield(handles, 'maskT'))
    maskS = Mask();
    handles.maskS = maskS;
end
 set(handles.error_text, 'String', 'Change selection selected');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sol, img, new_cut] = clonage_v2(handles, maskS, im, rect, maskT)
    %function clonage_v2
    %Create the smallest rectangle around the ROI in the cut_image 
    % Create the smallest rectangle around the ROI in the mask
    % Create a FDSystem object to solve the equation
    %Solve the equation
    % Transform the mask, adjust size & update the actual position of ROI
    set(handles.error_text, 'String', 'Wait please, DF method in progress ');
    new_cut = maskS.transform_to_rect(im); % resize I into a rect (demarcation)
    maskS.cut_im = new_cut;
    maskT.cut_im = maskS.transform_to_rect(maskT.associate_im);
    maskS.matrix = maskS.transform_to_rect(maskS.matrix);   % resize b&w mask
        
    if(handles.change_sel.Value == 1)
    maskS.change_selection(maskT);
    end
    new_system = FDSystem(maskS);
    new_system.create_matrix(maskS, rect, maskT);
    sol = new_system.solve(rect);
    set(handles.error_text, 'String', 'Solution found, we actually try to display the result');
    [row, col] = find(maskS.matrix);
    maskS.pos = [min(row), min(col)];
    img = copyPaste(maskS, maskT,sol, maskT.associate_im);
    set(handles.error_text, 'String', 'New image, done with DF method');

function [im_i, im_j, sol] = fourier_clonage(handles, maskS, maskT)
    set(handles.error_text, 'String', 'Beginning');
    handles.maskS.reinitialize_mask(handles.maskT);
    
    f = Fourier(maskS.associate_im, maskT.associate_im);
    im_i = copyPaste(maskS,maskT, f.grad_S_i, f.grad_T_i);% IMAGE I COLLEE
    
    handles.maskS.reinitialize_mask(handles.maskT);
    
    im_j = copyPaste(maskS, maskT, f.grad_S_j, f.grad_T_j);% IMAGE J COLLE
    
    sol = f.solve(im_i, im_j);
    set(handles.error_text, 'String', 'New image, done with Fourier method');
