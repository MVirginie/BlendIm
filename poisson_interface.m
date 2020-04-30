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

% Last Modified by GUIDE v2.5 24-Apr-2020 17:15:22

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

    [file1,path1] = uigetfile('*.jpg;*.png;*.jpeg', 'select an image');
    imageS = imread(fullfile(path1,file1));
    if( handles.Color_box.Value == 0)
        imageS = im2double(imageS(:,:,1));
    else 
        imageS = im2double(imageS(:,:,:));
    end
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
[file2,path2] = uigetfile('*.jpg; *.png; *.jpeg', 'select T image');
imageT = imread(fullfile(path2,file2));
    if( handles.Color_box.Value == 0)
        imageT = im2double(imageT(:,:,1));
    else 
        imageT = im2double(imageT(:,:,:));
    end
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
if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
    handles.maskS.reload_pdt_mask(handles.s_init);
    handles.maskT.reload_pdt_mask(handles.t_init);
    fprintf('done');
elseif(isfield(handles, 'maskS') && ~isfield(handles, 'maskT'))
    maskS = Mask();
    handles.maskS = maskS;
end
set(handles.error_text, 'String', 'DF method selected');

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
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


% --- Executes on button press in change_sel.
function change_sel_Callback(~, ~, handles)
% hObject    handle to change_sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of change_sel

 if(isfield(handles, 'maskS') && isfield(handles, 'maskT'))
    handles.maskT.reload_pdt_mask(handles.t_init);
     handles.maskS.reinitialize_mask(handles.maskT);
elseif(isfield(handles, 'maskS') && ~isfield(handles, 'maskT'))
    maskS = Mask();
    handles.maskS = maskS;
end
 set(handles.error_text, 'String', 'Change selection selected');

 % --- Executes on button press in Color_box.
function Color_box_Callback(hObject, eventdata, handles)
% hObject    handle to Color_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
solve = method();
if (handles.slider3.Value == 0 && handles.slider4.Value == 1)
    set(handles.slider3, 'Value', -handles.maskT.pos(1,1));
    set(handles.slider4, 'Value', handles.maskT.pos(1,2));
    handles.shift3 = 0;
    handles.shift4 = 0;
    guidata(gca, handles);
end
if(handles.DFButton.Value == 1)
    if (handles.Color_box.Value == 1)
        tic
        [sol, image, new_cut] = solve.color_mode_DF(handles);
        toc
    else
    rect = handles.maskS.transform_to_rect(handles.maskS.associate_im, handles.maskS.shift_done);% resize S into a rect 
    [im] = copyPaste(handles.maskS, handles.maskT, handles.maskS.associate_im, handles.maskT.associate_im);
    [sol, image, new_cut] = solve.finiteDiff(handles, handles.maskS, im, rect, handles.maskT);
    end
    %imshow(new_cut, 'Parent', handles.axes);
    imshow(new_cut, 'Parent', handles.axes3);
    imshow(image, 'Parent', handles.axes5);
    imshow(sol, 'Parent', handles.axes4);
    
elseif (handles.FourierButton.Value == 1)
    if (handles.Color_box.Value == 1)
        tic
        [sol, img]=solve.color_mode_Fourier(handles);
        toc
    else
        [im] = copyPaste(handles.maskS, handles.maskT, handles.maskS.associate_im, handles.maskT.associate_im);
        handles.maskS.reload_pdt_mask(handles.s_init)
        [sol, img] = solve.fourier(handles, handles.maskS, handles.maskT, im);
    end
    imshow(handles.maskT.cut_im, 'Parent', handles.axes3);
    imshow(img, 'Parent', handles.axes5);
    imshow(sol, 'Parent', handles.axes4);
else 
    if(handles.Color_box.Value==1)
        tic
        [cut_im,sol] = solve.color_mode_Douglas(handles);
        toc
    else  
        tic
    [cut_im,sol] = solve.douglas(handles.maskS, handles.maskT, handles);
        toc
    end
    imshow(sol, 'Parent', handles.axes5);
    imshow(handles.maskS.cut_im, 'Parent', handles.axes4);
    imshow(cut_im , 'Parent', handles.axes3); 
end
hideAxes(handles);
