classdef Fourier<handle
    properties
        grad_S_i
        grad_S_j
        grad_T_i
        grad_T_j
        symmetric_i
        symmetric_j
    end
    
    methods
        function obj = Fourier(imS, imT)
            %EXTENDS THE IMAGES THEN THE SIZE = (H*2, W*2)
             [imS, imT] = obj.symmetry(imS, imT);
             [H,W] = size(imS);
             [u,v] = obj.compute_indices_matrix(imS, W, H);
             [obj.grad_S_i, obj.grad_S_j] = obj.compute_grad_vect( imS, W, H, u, v);

             obj.grad_S_i = obj.resize_mat( obj.grad_S_i, W, H);
     
             obj.grad_S_j = obj.resize_mat( obj.grad_S_j, W, H);
             
             %SAME THING FOR IMAGE BACKGROUND
             [H,W] = size(imT);
             [u,v] = obj.compute_indices_matrix(imT, W, H);
             [obj.grad_T_i,obj.grad_T_j ] =  obj.compute_grad_vect(imT, W,H, u, v);
             obj.grad_T_i = obj.resize_mat( obj.grad_T_i, W, H);
             obj.grad_T_j = obj.resize_mat( obj.grad_T_j, W, H);
             
        end
        
        function[row, col] = compute_indices_matrix(self,imS, W, H)
            [H,W] = size(imS);
            [row,col] = meshgrid(-W/2+1:W/2, -H/2+1:H/2);
        end
        
        function[im_x, im_y] = compute_grad_vect(self, im, W,H,x, y)
            im_x= fftshift(fft2(im)).*((2*pi*1i/W).*x);
            im_x = (ifft2(ifftshift(im_x)));
            
            im_y = fftshift(fft2(im)).*((2*pi*1i/H).*y);
            im_y = (ifft2(ifftshift(im_y)));
        end
        
        function im = resize_mat(self,im, W, H)
            im = im(1:H/2, 1:W/2);
        end
        
        function[i, j] =  symmetry(self, im1, im2)
              b = flip(im1, 2);
             new_mat = [im1, b];
             h_new = flip(new_mat,1);
             i= [ new_mat; h_new];

            b = flip(im2, 2);
            new_mat = [im2, b];
            h_new = flip(new_mat,1);
            j= [ new_mat; h_new];
 
        end
        
        function I = solve(self, im_x, im_y)
 
            [im_x,im_y] = self.symmetry(im_x, im_y);
            [H,W] = size(im_x);
            [u,v] = self.compute_indices_matrix(im_x, W, H);
            
            im_x_hat = fftshift(fft2(im_x));
            im_y_hat = fftshift(fft2(im_y));

            cte_1 = (2*pi*1i/W);
            cte_2 = (2*pi*1i/H);
            
            numerator = cte_1.*u.*im_x_hat + cte_2.*v.*im_y_hat;
            denominator = (cte_1.*u).^2 + (cte_2.*v).^2 ;
            
            i_hat = numerator./denominator;
            i_hat((H/2),(W/2)) = 0;
            I = real(ifft2(ifftshift(i_hat)));
            I = self.resize_mat(I, W, H);            
        end

    end
end
    