function solve = method()
% Structure containing all the methods needed
        solve.fourier = @fourier_clonage;
        solve.finiteDiff = @clonage_v2;
        solve.color_mode_DF = @color_mode_DF;
        solve.color_mode_Fourier = @color_mode_Fourier;
        solve.douglas = @douglas;
        solve.color_mode_Douglas =@color_mode_Douglas;
end
function [sol] = fourier_clonage(handles, maskS, maskT,im)
    set(handles.error_text, 'String', 'Beginning');
    f = Fourier(maskS.associate_im, maskT.associate_im);
    im_i = copyPaste(maskS,maskT, f.grad_S_i, f.grad_T_i);% IMAGE I COLLEE
    maskS.reinitialize_mask(maskT);
    im_j = copyPaste(maskS, maskT, f.grad_S_j, f.grad_T_j);% IMAGE J COLLE
    sol = f.solve(im_i, im_j, maskT);
    set(handles.error_text, 'String', 'New image, done with Fourier method');
end

function [img] = clonage_v2(handles, maskS, im, rect, maskT)
    %function clonage_v2
    %Create the smallest rectangle around the ROI in the cut_image 
    % Create the smallest rectangle around the ROI in the mask
    % Create a FDSystem object to solve the equation
    %Solve the equation
    % Transform the mask, adjust size & update the actual position of ROI
    set(handles.error_text, 'String', 'Wait please, DF method in progress ');
    maskS.cut_im  = maskS.transform_to_rect(im, maskS.shift_done); % resize I into a rect (demarcation)
    maskT.cut_im = maskS.transform_to_rect(maskT.associate_im, maskS.shift_done);
    maskS.matrix = maskS.transform_to_rect(maskS.matrix, maskS.shift_done);   % resize b&w mask
    if(handles.change_sel.Value == 1)
      maskS.change_selection(maskT);
    end
    new_system = FDSystem(maskS.matrix);
    new_system.create_matrix(maskS, rect, maskT);
    sol = new_system.solve(rect);
    set(handles.error_text, 'String', 'Solution found, we actually try to display the result');
    [row, col] = find(maskS.matrix);
    maskS.pos = [min(row), min(col)];
    img = copyPaste(maskS, maskT,sol, maskT.associate_im);
    set(handles.error_text, 'String', 'New image, done with DF method');
end

function [sol] = color_mode_DF(handles)
if(handles.Vdeo.Value == 0)
 for i = 1:3
     handles.maskT.reload_pdt_mask(handles.t_init);
     handles.maskS.reload_pdt_mask(handles.s_init);
     handles.maskT.associate_im = handles.maskT.associate_im(:,:,i);
     handles.maskS.associate_im = handles.maskS.associate_im(:,:,i);
     rect(:,:,i) = handles.maskS.transform_to_rect(handles.maskS.associate_im,handles.maskS.shift_done);% resize S into a rect 
     im(:,:,i) = copyPaste(handles.maskS, handles.maskT, handles.maskS.associate_im, handles.maskT.associate_im);
     [sol(:,:,i)] = clonage_v2(handles, handles.maskS, im(:,:,i), rect(:,:,i), handles.maskT);
 end
else
    sol = handles.imageT;
    for k = 1:numel(handles.imageT)
        k
     for i = 1:3
     handles.maskT.reload_pdt_mask(handles.t_init);
     handles.maskS.reload_pdt_mask(handles.s_init);
     handles.maskT.associate_im = handles.imageT(k).data(:,:,i);
     handles.maskS.associate_im = handles.maskS.associate_im(:,:,i);
     rect(:,:,i) = handles.maskS.transform_to_rect(handles.maskS.associate_im,handles.maskS.shift_done);% resize S into a rect 
     im(:,:,i) = copyPaste(handles.maskS, handles.maskT, handles.maskS.associate_im, handles.maskT.associate_im);
     img(:,:,i)= clonage_v2(handles, handles.maskS, im(:,:,i), rect(:,:,i), handles.maskT);
     end 
     sol(k).data = img;
    end
end
end

function [sol] = color_mode_Fourier(handles)
if (handles.Vdeo.Value == 0)
 for i = 1:3
     handles.maskT.reload_pdt_mask(handles.t_init);
     handles.maskS.reload_pdt_mask(handles.s_init);
     handles.maskT.associate_im = handles.maskT.associate_im(:,:,i);
     handles.maskS.associate_im = handles.maskS.associate_im(:,:,i);
    [ sol(:,:,i)] = fourier_clonage(handles, handles.maskS, handles.maskT);
 end
else
    sol = handles.imageT;
    for k = 1:numel(handles.imageT)
        k
         for i = 1:3
            handles.maskT.reload_pdt_mask(handles.t_init);
            handles.maskS.reload_pdt_mask(handles.s_init);
            handles.maskT.associate_im = handles.imageT(k).data(:,:,i);
            handles.maskS.associate_im = handles.maskS.associate_im(:,:,i);
            im(:,:,i) = fourier_clonage(handles, handles.maskS, handles.maskT);
         end
         sol(k).data = im;
    end
end
end

function [sol] = color_mode_Douglas(handles)
  for i = 1:3
     handles.maskT.reload_pdt_mask(handles.t_init);
     handles.maskS.reload_pdt_mask(handles.s_init);
     handles.maskT.associate_im = handles.maskT.associate_im(:,:,i);
     handles.maskS.associate_im = handles.maskS.associate_im(:,:,i);
     [sol(:,:,i)] = douglas(handles.maskS,handles.maskT, handles);
  end
end

function [sol] = douglas(maskS, maskT, handles)
maskS.cut_im = maskS.matrix.*maskS.associate_im;
maskS.adjust_size(maskT)
maskS.move_roi();
[k,l] = find(maskS.matrix);
maskS.reinitialize_mask(maskT);
maskS.cut_im = maskS.transform_to_rect(maskS.associate_im, maskS.shift_done);
maskS.matrix = maskS.transform_to_rect(maskS.matrix, maskS.shift_done);
maskT.cut_im = maskS.accord_rec(maskT.associate_im); 
maskS.pos_to_move = [min(l), min(k)];
  if(handles.change_sel.Value == 1)
        maskS.change_selection(maskT);
  end
    dg = Douglas(maskS, maskT);
    y0 = maskT.cut_im;
    temp = dg.douglas(y0, handles);
        [row, col] = find(maskS.matrix);
    maskS.pos = [min(row), min(col)];
    sol = copyPaste(maskS, maskT,temp, maskT.associate_im);
end