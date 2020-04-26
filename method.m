function solve = method()
% Structure containing all the methods needed
        solve.fourier = @fourier_clonage;
        solve.finiteDiff = @clonage_v2;
        solve.color_mode_DF = @color_mode_DF;
        solve.color_mode_Fourier = @color_mode_Fourier;
        solve.douglas = @douglas;
        solve.color_mode_Douglas =@color_mode_Douglas;
end
function [new_T, sol] = fourier_clonage(handles, maskS, maskT,im)
    set(handles.error_text, 'String', 'Beginning');
    f = Fourier(maskS.associate_im, maskT.associate_im);
        if(handles.change_sel.Value == 1)
             maskS.change_selection(maskT);
        end
    im_i = copyPaste(maskS,maskT, f.grad_S_i, f.grad_T_i);% IMAGE I COLLEE
    maskS.reinitialize_mask(maskT);
    if(handles.change_sel.Value == 1)
      maskS.change_selection(maskT);
    end
    im_j = copyPaste(maskS, maskT, f.grad_S_j, f.grad_T_j);% IMAGE J COLLE
    new_T = maskT.associate_im;
    sol = f.solve(im_i, im_j);
    set(handles.error_text, 'String', 'New image, done with Fourier method');
end
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
      imshow(maskS.matrix)
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

function [sol, image, new_cut] = color_mode_DF(handles)
 for i = 1:3
     handles.maskT.reload_pdt_mask(handles.t_init);
     handles.maskS.reload_pdt_mask(handles.s_init);
     handles.maskT.associate_im = handles.maskT.associate_im(:,:,i);
     handles.maskS.associate_im = handles.maskS.associate_im(:,:,i);
     rect(:,:,i) = handles.maskS.transform_to_rect(handles.maskS.associate_im);% resize S into a rect 
     im(:,:,i) = copyPaste(handles.maskS, handles.maskT, handles.maskS.associate_im, handles.maskT.associate_im);
     [sol(:,:,i), image(:,:,i), new_cut(:,:,i)] = clonage_v2(handles, handles.maskS, im(:,:,i), rect(:,:,i), handles.maskT);
 end
end
function [t, sol] = color_mode_Fourier(handles)
 for i = 1:3
     handles.maskT.reload_pdt_mask(handles.t_init);
     handles.maskS.reload_pdt_mask(handles.s_init);
     handles.maskT.associate_im = handles.maskT.associate_im(:,:,i);
     handles.maskS.associate_im = handles.maskS.associate_im(:,:,i);
    [t(:,:,i), sol(:,:,i)] = fourier_clonage(handles, handles.maskS, handles.maskT);
 end
end

function [sol] = color_mode_Douglas(handles)
  for i = 1:3
     handles.maskT.reload_pdt_mask(handles.t_init);
     handles.maskS.reload_pdt_mask(handles.s_init);
     handles.maskT.associate_im = handles.maskT.associate_im(:,:,i);
     handles.maskS.associate_im = handles.maskS.associate_im(:,:,i);
     sol(:,:,i) = douglas(handles.maskS,handles.maskT, handles);
  end
end

function sol = douglas(maskS, maskT, handles)
maskS.cut_im = maskS.transform_to_rect(maskS.associate_im);
maskS.matrix = maskS.transform_to_rect(maskS.matrix);
maskT.cut_im = maskT.accord_rec(maskS.matrix,maskT.associate_im);   
    if(handles.change_sel.Value == 1)
        maskS.change_selection(maskT);
    end
    maskS.pos_to_move(1,1)
    dg = Douglas(maskS, maskT);
    y0 = maskT.cut_im;
    temp = dg.douglas(y0, handles);
    [row, col] = find(maskS.matrix);
    maskS.pos = [min(row), min(col)];
    sol = copyPaste(maskS, maskT,temp, maskT.associate_im);
end