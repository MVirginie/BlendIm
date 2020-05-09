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

% Last Modified by GUIDE v2.5 07-May-2020 19:11:00

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
% handles    structure with handles and user data (see GUIDATA)
    [file1,path1] = uigetfile('*.jpg;*.png;*.jpeg; *.bmp', 'select an image');
    imageS = imread(fullfile(path1,file1));
    imageS = im2double(imageS(:,:,:));
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
if(handles.Vdeo.Value ==0)
[file2,path2] = uigetfile('*.jpg; *.png; *.jpeg; *.bmp', 'select T image');
imageT = imread(fullfile(path2,file2));
imageT = im2double(imageT(:,:,:));
handles.imageT = imageT;
guidata(gca, handles);

slider3_CreateFcn(handles.slider3, eventdata, handles);
slider4_CreateFcn(handles.slider4, eventdata, handles);

axesIm2 = imshow(handles.imageT, 'Parent', handles.axes2);
set(axesIm2, 'ButtonDownFcn', @axeImT_ButtonDownFcn);
set(handles.error_text, 'String', 'Background image loaded, please select the region to cut in the first image');
hideAxes(handles);
else
    path1 = 'video/';
    imageT = dir(fullfile(path1, '*.png'));
    for k = 1:numel(imageT)
        F = fullfile(path1, imageT(k).name);
        I = imread(F);
        I = im2double(I(:,:,:));
        imageT(k).data = I;
        axesIm2 = imshow(imageT(k).data, 'Parent', handles.axes2);
        pause(0.002)
    end
    set(axesIm2, 'ButtonDownFcn', @axeImT_ButtonDownFcn);
    handles.imageT = imageT;
    guidata(gca, handles);
end

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
    if(handles.Vdeo.Value ==0)
        maskT = Mask(handles.imageT);
    else 
        maskT = Mask(handles.imageT(1).data);
    end
    t_init = maskT.save_mask_settings();
    handles.maskT = maskT;
    handles.t_init = t_init;

    handles.maskS.pos_to_move = maskT.pos;
    handles.s_init.pos_to_move = maskT.pos;
    guidata(gca,handles);

    set(handles.error_text, 'String', 'Paste region selected, you can choose the method & then click on the paste button');
    hideAxes(handles);


function hideAxes(handles)
    handles.axes1.XAxis.Visible = 'off';
    handles.axes2.XAxis.Visible = 'off';
    handles.axes3.XAxis.Visible = 'off';
    handles.axes4.XAxis.Visible = 'off';
    handles.axes5.XAxis.Visible = 'off';
    handles.axes6.XAxis.Visible = 'off';
    handles.axes1.YAxis.Visible = 'off';
    handles.axes2.YAxis.Visible = 'off';
    handles.axes3.YAxis.Visible = 'off';
    handles.axes4.YAxis.Visible = 'off';
    handles.axes5.YAxis.Visible = 'off';
    handles.axes6.YAxis.Visible = 'off';

% --- Executes on button press in DFButton.
function DFButton_Callback(~, ~, handles)
% hObject    handle to DFButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DFButton
    if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
        handles.maskS.reload_pdt_mask(handles.s_init);
        handles.maskT.reload_pdt_mask(handles.t_init);
    elseif(isfield(handles, 'maskS') && ~isfield(handles, 'maskT'))
        maskS = Mask();
        handles.maskS = maskS;
    end
    set(handles.error_text, 'String', 'DF method selected');

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(~, ~, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton4
    if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
        handles.maskS.reinitialize_mask(handles.maskT);
        handles.maskT.associate_im = handles.imageT;
        handles.maskS.associate_im = handles.imageS;
    end
    set(handles.error_text, 'String', 'Douglas method selected');

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
        y_2 = get(hObject, 'Value');
        
        handles.shift3 = abs(y_2)-y_1;
        guidata(gca, handles);
        handles.maskT.pos(:,2) = handles.maskT.pos(:,2)+handles.shift3;
        handles.maskS.reinitialize_mask(handles.maskT); 
        set(handles.slider3,'Value', -handles.maskT.pos(1,2));
        handles.s_init.pos_to_move(:,2) = handles.maskT.pos(:,2);
        handles.t_init.pos(:,2) = handles.maskT.pos(:,2);
        guidata(gca,handles);
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
    y_1 = handles.maskT.pos(1,1);
    y_2 = get(hObject, 'Value');
    handles.shift4 = y_2-y_1;
    guidata(gca, handles)
    handles.maskT.pos(:,1) = handles.maskT.pos(:,1)+handles.shift4;
    handles.maskS.reinitialize_mask(handles.maskT);
    handles.s_init.pos_to_move(:,1) = handles.maskT.pos(:,1);
    handles.t_init.pos(:,1) = handles.maskT.pos(:,1);
    guidata(gca,handles);
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

 

% --- Executes on button press in pasteButton.
% Display : 
%---------- on axes3 :DF method result
%---------- on axes4 : Fourier method
%---------- on axes 5: Current method result
%---------- on axes 6 : Douglas method
function pasteButton_Callback(~, ~, handles)
% hObject    handle to pasteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.axes5);
solve = method();
if(handles.Vdeo.Value == 0)
    if (handles.slider3.Value == 0 && handles.slider4.Value == 1)
    set(handles.slider3, 'Value', -handles.maskT.pos(1,1));
    set(handles.slider4, 'Value', handles.maskT.pos(1,2));
    handles.shift3 = 0;
    handles.shift4 = 0;
    guidata(gca, handles);
    end
end
tic
if(handles.DFButton.Value == 1)
    sol = solve.color_mode_DF(handles);
    display(sol, handles, handles.axes3, @axes3_ButtonDownFcn)
    sol1 = sol;
    handles.resultDF = sol1;

elseif (handles.FourierButton.Value == 1)
    [sol]=solve.color_mode_Fourier(handles);
    display(sol, handles, handles.axes4, @axes4_ButtonDownFcn)
    sol2 = sol;
    handles.resultF = sol2;
    
else
    [sol] = solve.color_mode_Douglas(handles);
    display(sol, handles, handles.axes6, @axes6_ButtonDownFcn)
       
end
toc

if (handles.Color_box.Value == 0)
    imshow(sol(:,:,1), 'Parent', handles.axes5);
else
    if(handles.Vdeo.Value == 0)
    imshow(sol, 'Parent', handles.axes5);
    else
        for k = 1: numel(handles.imageT)
            imshow(sol(k).data, 'Parent', handles.axes5)
            pause(0.005)
        end
    end
   
end

  guidata(gca, handles)
hideAxes(handles);

function display(sol, handles, axes, buttondown)
if (handles.Color_box.Value == 0)
    axesIm = imshow(sol(:,:,1), 'Parent', axes);
    set(axesIm, 'ButtonDownFcn', buttondown);
else
    if(handles.Vdeo.Value == 0)
     axesIm = imshow(sol, 'Parent', axes);
    else 
       axesIm = imshow(sol(numel(handles.imageT)).data, 'Parent', axes);
    end
   set(axesIm, 'ButtonDownFcn', buttondown);
end
% --- Executes on button press in pushbutton4. SAVED
function pushbutton4_Callback(~, ~, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(gca, handles)
imsave(handles.axes5)


% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, ~, ~)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
if(handles.Vdeo.Value ==0)
I = getimage(hObject);
imshow(I, 'Parent', handles.axes5)
else 
    for k = 1:numel(handles.imageT)
        imshow(handles.resultDF(k).data, 'Parent', handles.axes5)
        pause(0.005)
    end
end


% --- Executes on mouse press over axes background.
function axes4_ButtonDownFcn(hObject, ~, ~)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
if( handles.Vdeo.Value == 0)
I = getimage(hObject);
imshow(I, 'Parent', handles.axes5)
else
    for k = 1:numel( handles.imageT)
        imshow(handles.resultF(k).data, 'Parent', handles.axes5)
        pause(0.005)
    end
end

% --- Executes on mouse press over axes background.
function axes6_ButtonDownFcn(hObject, ~, ~)
% hObject    handle to axes6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gca);
I = getimage(hObject);
imshow(I, 'Parent', handles.axes5)

