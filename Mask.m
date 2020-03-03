classdef Mask <handle
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
        function self = Mask()
     
           roi1 = imfreehand;
           mask1 = roi1.createMask();
           mask = zeros(size(mask1));
           mask(mask1(:,:))=1;
           self.associate_roi = roi1;
           self.pos = getPosition(roi1);
           self.matrix = mask;
           self.shift_done = [0,0];
           
        end
       
    function move_roi(self)
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
    i_mask = zeros(size(self.matrix));
    i_mask(self.matrix(:,:)==0)=1;
    end
    

    function im = transform_to_rect(self,I)
    h = self.pos;
    ymin = min(h(:,1))+self.shift_done(1,1);
    xmin = min(h(:,2))+self.shift_done(1,2);
    ymax = max(h(:,1)) +self.shift_done(1,1);
    xmax = max(h(:,2))+self.shift_done(1,2);
    
    rect = zeros(size(I));
    rect(int32(xmin-1):int32(xmax+1), int32(ymin-1):int32(ymax+1)) = I(int32(xmin-1):int32(xmax+1), int32(ymin-1):int32(ymax+1));
    im = rect(int32(xmin-1):int32(xmax+1), int32(ymin-1):int32(ymax+1));
    end
    
    function im =mask_rect(self, I)
    h = self.pos;
    ymin = min(h(:,1))+self.shift_done(1,1);
    xmin = min(h(:,2))+self.shift_done(1,2);
    ymax = max(h(:,1)) +self.shift_done(1,1);
    xmax = max(h(:,2))+self.shift_done(1,2);
    
    im = zeros(size(I));
    im(int32(xmin-1):int32(xmax+1), int32(ymin-1):int32(ymax+1)) = 1;
    temp = self.cut_im;
    self.cut_im = im;
    j= im(int32(xmin-1):int32(xmax+1), int32(ymin-1):int32(ymax+1));
    self.cut_im(int32(xmin-1):int32(xmax+1), int32(ymin-1):int32(ymax+1)) = temp(:,:);
    end
    
    function find_boundaries(self)
        self.boundaries = bwboundaries(self.matrix);
        self.modify_maskval();
        
    end
    function modify_maskval(self)
        pixels = self.boundaries{1,1};
       % self.boundaries = (pixels(:,:));
        self.boundaries = pixels;
       % for k = 1:size(pixels,1)
            %self.matrix(pixels(k,1), pixels(k,2)) = 0.5;
        %self.matrix(self.boundaries(:,:)) = 0.5;
       % end
       
       
       
    end
    function [list_bound_x, list_bound_y] =  transform_boundaries(self)
       list_bound_x = self.boundaries{:,1};
       list_bound_y = self.boundaries{:,2};
    end
    end
    
end

