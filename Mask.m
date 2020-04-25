classdef Mask <handle
    %Class Mask : Creates a mask with the floowing properties : 
    %------------ associate_im : the image from which the mask is created
    %------------ associate_roi : the created ROI (imfreehand object)
    %------------ matrix : THE mask : a binary matrix (1 in \Omega, 0
    %outside)
    %------------ pos : the ROI position on the image
    %------------ pos_to_move : the position where the ROI need to move 
    %------------ cut _im : mask.*associate_im : returns associate_im
    %pixels in the ROI and 0 outside
    %------------shift_done : the shift done by the ROI after moving
    %------------ boundaries : the position of the boundaries pixels
    properties
        
        associate_im
        associate_roi
        matrix
        pos
        pos_to_move
        cut_im
        shift_done
        boundaries
        
    end
    
    methods
    
    function self = Mask(image)
        %The constructor : 
        %Use imfreehand to create the ROI & the mask & the pos_vector
        self.associate_im = image;
        roi1 = imfreehand;
           mask1 = roi1.createMask();
           mask = zeros(size(mask1)); %transform the mask into binaries array
           mask(mask1(:,:))=1;
           self.associate_roi = roi1;
           self.pos = getPosition(roi1);
           self.matrix = mask;
           self.shift_done = [0,0];
           
    end
    
    function reinitialize_mask(self, maskT)
        
        self.pos = getPosition(self.associate_roi);
        self.pos_to_move = maskT.pos;
        self.shift_done = [0,0];
        mask1 = self.associate_roi.createMask();
        mask = zeros(size(mask1)); %transform the mask into binaries array
        mask(mask1(:,:))=1;
        self.matrix = mask;
    end
    
    function[struct] =save_mask_settings(self)
        struct.associate_im = self.associate_im;
        struct.pos = self.pos;
        struct.pos_to_move = self.pos_to_move;
        struct.matrix = self.matrix;
        struct.shift_done = self.shift_done;
    end
    
    function reload_pdt_mask(self,s)
        
        self.associate_im = s.associate_im;
        self.pos = s.pos;
        self.pos_to_move = s.pos_to_move;
        self.matrix = s.matrix;
        self.shift_done = s.shift_done;
    end
       
    function move_roi(self)
       %Function move_roi :
       %Find the distance between the mask's pos and the position he has to
       %go 
       % Then cirschift the mask until pixels reach their correct pos
        x_1 = self.pos(1,1);
        y_1 = self.pos(1,2);
        x_2 =self.pos_to_move(1,1);
        y_2 = self.pos_to_move(1,2);
        d_x = int32(x_2-x_1);
        d_y = int32(y_2-y_1);
        
        self.shift_done = [d_x, d_y];
        mat = circshift(self.matrix,d_x,2);
        mat = circshift(mat, d_y,1);
        self.matrix = mat;
        mat1 = circshift(self.cut_im,d_x,2);
        mat1 = circshift(mat1, d_y,1);
        self.cut_im = mat1;
    end

    function i_mask = invert_mask(self)  
        %Function : invert_mask : 
        % Invert binaries in the mask (0 become 1 & 1->0)
        i_mask = zeros(size(self.matrix));
        i_mask(self.matrix(:,:)==0)=1;
    end
    
    function im = transform_to_rect(self,I)
    %Creates the smallest rectangle around the ROI thanks to pos
    %Resize the final image ->rect dimensions
        h = self.pos;
        ymin = min(h(:,1))+self.shift_done(1,1);
        xmin = min(h(:,2))+self.shift_done(1,2);
        ymax = max(h(:,1)) +self.shift_done(1,1);
        xmax = max(h(:,2))+self.shift_done(1,2);
        
        rect = zeros(size(I));
        rect(int32(xmin-1):int32(xmax+1), int32(ymin-1):int32(ymax+1)) =...
            I(int32(xmin-1):int32(xmax+1),int32(ymin-1):int32(ymax+1));
        
        im = rect(int32(xmin-1):int32(xmax+1),...
            int32(ymin-1):int32(ymax+1));
    end
    
    function find_boundaries(self)
        %use bwboundaries to find boundaries of the mask
        % Then modify their value into the mask to "print" them
        self.boundaries = bwboundaries(self.matrix);
        self.modify_maskval();
        
    end
    
    function modify_maskval(self)
       %Function modify_maskval
       % Modifies the boundaires pixels values in the mask to 0.5 (1 before)
        pixels = self.boundaries{1,1};
        self.boundaries = (pixels(:,:));
        self.boundaries = pixels;
        for k = 1:size(pixels,1)
            self.matrix(pixels(k,1), pixels(k,2)) = 0.5;
        self.matrix(self.boundaries(:,:)) = 0.5;
        end 
    end
    
    function adjust_size(self, maskT)
        [w1, h1]  = size(self.matrix);
        [w2, h2] = size(maskT.matrix);
        d_x = w1-w2;
        d_y = h1-h2;
        if(d_x<=0)
            new_mat = zeros([abs(d_x), h1]);
            self.matrix = cat(1,self.matrix,new_mat);
            self.cut_im = cat(1,self.cut_im,new_mat);
        else
            new_mat = zeros([d_x, h2]);
            maskT.matrix = cat(1,maskT.matrix, new_mat);
        end
        [w1, ~] = size(self.matrix);
        if(d_y <=0) 
            new_mat = zeros([w1, abs(d_y)]);
            self.matrix = cat(2,self.matrix, new_mat);
            self.cut_im = cat(2,self.cut_im, new_mat);
        else
            new_mat = zeros([w1, d_y]);
            maskT.matrix = cat(2,maskT.matrix, new_mat);
        end
    end
   
     function [grad, grad1]= compute_grad(self)
         grad.x = zeros(size(self.cut_im));
         grad.y = zeros(size(self.cut_im));
         grad1.x = zeros(size(self.cut_im));
         grad1.y = zeros(size(self.cut_im));
         grad.x(2:end-1, :) = -self.cut_im(2:end-1,:)+self.cut_im(3:end, :);
         grad.y(:, 2:end-1) = -self.cut_im (:, 2:end-1)+self.cut_im(:, 3:end);

         grad1.x(2:end-1,:) = self.cut_im(2:end-1,:)-self.cut_im(1:end-2,:);
         grad1.y(:, 2:end-1) = self.cut_im(:,2:end-1) -self.cut_im(:, 1:end-2);

%grad.x = (circshift(self.cut_im,-1,2)-circshift(self.cut_im,1,2))./2;
      %   grad.y = (circshift(self.cut_im,-1,1) -circshift(self.cut_im, 1, 1))./2;
    
     end
     
     function change_selection(self, maskT)
        [gradT, gradT1] = maskT.compute_grad();
        [gradS, gradS1] = self.compute_grad();
        sol = (abs(gradS.x)<abs(gradT.x) & ...
                abs(gradS.y)<abs(gradT.y)& ...
                 abs(gradS1.x)<abs(gradT1.x) & ...
                abs(gradS1.y)<abs(gradT1.y));
        self.matrix(sol) = 0;
        self.cut_im(sol) = maskT.cut_im(sol);
     end
    end
    
end

