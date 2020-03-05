classdef Fourier<handle
    properties
        grad_S_i
        grad_S_j
        grad_T_i
        grad_T_j
        me 
        symmetric_i
        symmetric_j
    end
    
    methods
        function obj = Fourier(imS, imT)
            %EXTENDS THE IMAGES THEN THE SIZE = (H*2, W*2)
            [imS, imT] = obj.symmetry(imS, imT);
            [H,W] = size(imS);
            [u,v] = obj.compute_indices_matrix(imS);
             u = u - (floor(H/2)+1);
             v = v -(floor(W/2)+1);
            [obj.grad_S_i, obj.grad_S_j] = obj.compute_grad_vect( imS, W, H, u, v);
            obj.grad_S_i = obj.resize_mat( obj.grad_S_i, W, H);
             obj.grad_S_j = obj.resize_mat( obj.grad_S_j, W, H);
            [H,W] = size(imT);
             [u,v] = obj.compute_indices_matrix(imT);
             u = u - (floor(H/2)+1);
            v = v -(floor(W/2)+1);
           [ obj.grad_T_i,obj.grad_T_j ] =  obj.compute_grad_vect(imT, W,H, u, v);
            obj.grad_T_i = obj.resize_mat( obj.grad_T_i, W, H);
            obj.grad_T_j = obj.resize_mat( obj.grad_T_j, W, H);
        end
        
        function[row, col] = compute_indices_matrix(self,imS)
            [H,W] = size(imS);
            [row, col] = meshgrid(1:W, 1:H);
        end
        function[im_x, im_y] = compute_grad_vect(self, im, W,H,x, y)
           im_x= fftshift(fft2(im)).*((2*pi*1i/H).*x);
            im_x = (ifft2(ifftshift(im_x)));
            im_y = fftshift(fft2(im)).*((2*pi*1i/W).*y);
 
            im_y = (ifft2(ifftshift(im_y)));

        end
        function im = resize_mat(self,im, W, H)
            im = im(1:H/2, 1:W/2);
        end
        
        function[i, j] =  symmetry(self, im1, im2)
            new_mat = [im1, -im1];
            h_new = flip(new_mat,1);
            i= [ new_mat; h_new];
            new_mat = [im2, -im2];
            h_new = flip(new_mat,1);
            j= [new_mat; h_new];  
        end
        
        function ok = solve(self, im_i, im_j)
            [im_i, im_j] = self.symmetry(im_i, im_j);
            [H,W] = size(im_i);
            [u, v] = self.compute_indices_matrix(im_i);
            u = u - (ceil(H/2));
            v = v -(ceil(W/2));
            im_i = fftshift(fft2(im_i));
            im_j = fftshift(fft2(im_j));
            
            numerator = ((2*pi*1i/W).*u).*im_i+((2*pi*1i/H).*v).*im_j;
            denominator = ((2*pi*1i/W).*u).^2+((2*pi*1i/H).*v).^2;
            
            sol =numerator./denominator;
            sol(ceil(W/2),ceil(H/2)) =self.me;
            
            ok = (ifft2(ifftshift(sol)));
           
            ok = ok(1:int32(H/2), 1:int32(W/2))
        end
        
        %DO THE CUT & PASTE
 


    end
end
    