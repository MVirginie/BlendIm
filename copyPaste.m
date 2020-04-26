function [im] =  copyPaste(maskS, maskT, imS, imT)
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

maskS.cut_im= maskS.matrix.*imS;
maskS.adjust_size(maskT);
maskS.move_roi();
[k,l] = find(maskS.matrix);
maskS.pos_to_move = [min(l), min(k)];
mask2 = maskS.invert_mask();
maskT2 = mask2.*imT;
im = maskS.cut_im+maskT2;

end
