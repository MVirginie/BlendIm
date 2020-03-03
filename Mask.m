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
        %The constructor : 
        %Use imfreehand to create the ROI & the mask & the pos_vector
        function self = Mask()
     
           roi1 = imfreehand;
           mask1 = roi1.createMask();
           mask = zeros(size(mask1)); %transform the mask into binaries array
           mask(mask1(:,:))=1;
           self.associate_roi = roi1;
           self.pos = getPosition(roi1);
           self.matrix = mask;
           self.shift_done = [0,0];
           
        end
       %Function move_roi : 
       %Find the distance between the mask's pos and the position he has to
       %go 
       % Then cirschift the mask until pixels reach their correct pos
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
    
    %Function : invert_mask : 
    % Invert binaries in the mask (0 become 1 & 1->0)
    function i_mask = invert_mask(self)
    i_mask = zeros(size(self.matrix));
    i_mask(self.matrix(:,:)==0)=1;
    end
    
    %Function transform_to_rect : 
    %Creates the smallest rectangle around the ROI thanks to pos
    %Resize the final image ->rect dimensions
    
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
    
    %Function find_boundaries
    %use bwboundaries to find boundaries of the mask
    % Then modify their value into the mask to "print" them
    function find_boundaries(self)
        self.boundaries = bwboundaries(self.matrix);
        self.modify_maskval();
        
    end
    %Function modify_maskval 
    % Modifies the boundaires pixels values in the mask to 0.5 (1 before)
    function modify_maskval(self)
        pixels = self.boundaries{1,1};
        self.boundaries = (pixels(:,:));
        self.boundaries = pixels;
        for k = 1:size(pixels,1)
            self.matrix(pixels(k,1), pixels(k,2)) = 0.5;
        self.matrix(self.boundaries(:,:)) = 0.5;
        end 
    end
   
    end
    
end

