classdef Fourier<handle
    properties
        grad_S_i
        grad_S_j
        grad_T_i
        grad_T_j
    end
    
    methods
        %The constructor
        function obj = Fourier(imS, imT)
            %Computes the imageS, imageT gradients  
            %EXTENDS THE IMAGES THEN THE SIZE = (H*2, W*2)
             [imS, imT] = obj.symmetry(imS, imT);
             [H,W] = size(imS);
             [u,v] = obj.compute_indices_matrix(imS);
             [obj.grad_S_i, obj.grad_S_j] = obj.compute_grad_vect( imS, W, H, u, v);
             obj.grad_S_i = obj.resize_mat( obj.grad_S_i, W, H);
             obj.grad_S_j = obj.resize_mat( obj.grad_S_j, W, H);
             %SAME THING FOR IMAGE BACKGROUND
             [H,W] = size(imT);
             [u,v] = obj.compute_indices_matrix(imT);
             [obj.grad_T_i,obj.grad_T_j ] =  obj.compute_grad_vect(imT, W,H, u, v);
             obj.grad_T_i = obj.resize_mat( obj.grad_T_i, W, H);
             obj.grad_T_j = obj.resize_mat( obj.grad_T_j, W, H);
             
        end
        
        function[row, col] = compute_indices_matrix(~,imS)
            %Compute the indexes needed
            [H,W] = size(imS);
            [row,col] = meshgrid(-W/2+1:W/2, -H/2+1:H/2);
        end
        
        function[grad_x, grad_y] = compute_grad_vect(~, im, W,H,x, y)
            %Computes im grad with Fourier
            grad_x= fftshift(fft2(im)).*((2*pi*1i/W).*x);
            grad_x = (ifft2(ifftshift(grad_x)));
            
            grad_y = fftshift(fft2(im)).*((2*pi*1i/H).*y);
            grad_y = (ifft2(ifftshift(grad_y)));
        end
        
        function im = resize_mat(~,im, W, H)
            %Resize the matrix; Needed cause symmetry
            im = im(1:H/2, 1:W/2);
        end
        
        function[i, j] =  symmetry(~, im1, im2)
            %Extends the image by symmetry
            % New dimension : 2*W, 2*H
             b = flip(im1, 2);
             new_mat = [im1, b];
             h_new = flip(new_mat,1);
             i= [ new_mat; h_new];

             b = flip(im2, 2);
             new_mat = [im2, b];
             h_new = flip(new_mat,1);
             j= [ new_mat; h_new];
        end
        
        function I = solve(self, im_x, im_y, maskT)
            %Solve the Poisson equation thanks to Fourier formulas
            [im_x,im_y] = self.symmetry(im_x, im_y);
            [H,W] = size(im_x);
            [u,v] = self.compute_indices_matrix(im_x);
            
            im_x_hat = fftshift(fft2(im_x));
            im_y_hat = fftshift(fft2(im_y));

            cte_1 = (2*pi*1i/W);
            cte_2 = (2*pi*1i/H);
            
            numerator = cte_1.*u.*im_x_hat + cte_2.*v.*im_y_hat;
            denominator = (cte_1.*u).^2 + (cte_2.*v).^2 ;
            
            i_hat = numerator./denominator;
            i_hat((H/2),(W/2)) = mean(maskT.associate_im(:));
            I = real(ifft2(ifftshift(i_hat)));
            I = self.resize_mat(I, W, H); 
           
        end
        function mask = change_sel(self, imi,imj, mask,maskT)
             [H,W] = size(imi);
             [u,v] = self.compute_indices_matrix(imi);
            [gradS_i, gradS_j] = self.compute_grad_vect(imi, W,H, u, v);
            [gradT_i, gradT_j] = self.compute_grad_vect(imj, W,H, u, v);
            
            sol = (abs(gradS_i)<abs(gradT_i) & abs(gradS_j)<abs(gradT_j) );
            mask.matrix = mask.transform_to_rect(mask.matrix, mask.shift_done); 
            mask.matrix(sol) = 0;
        end
    end
    
end
    