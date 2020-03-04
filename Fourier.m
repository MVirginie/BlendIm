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
            imS = im2double(imS(:,:,1));
            imT = im2double(imT(:,:,1));
            [w,h] = size(imS);
             mat = ones(w, h);
            [a,b] = find(mat);
            a = reshape(a,w,h);
            b = reshape(b,w,h);
            obj.grad_S_i = ifft2((fft2(imS)).*((2*pi*1i/w).*a));
            obj.grad_S_j = ifft2((fft2(imS)).*((2*pi*1i/h).*b));
            [w,h] = size(imT);
             mat = ones(w, h);
            [a,b] = find(mat);
            a = reshape(a,w,h);
            b = reshape(b,w,h);
            obj.grad_T_i = ifft2((fft2(imT)).*((2*pi*1i/w).*a));
            obj.grad_T_j = ifft2((fft2(imT)).*((2*pi*1i/h).*b));
            

        end
        function change_im_i(self, mask)
            mask.imageS = self.grad_S_i;
            mask.imageT = self.grad_T_i;
        end
        function change_im_j(self, mask)
            mask.imageS = self.grad_S_j;
            mask.imageT =self.grad_T_j;
        end
        
        function[i, j] =  symmetry(self, im1, im2)
            v=flip(im1, 2);
            new_mat = [v, im1];
            h_new = flip(new_mat,1);
            i= [ new_mat; h_new];
             v=flip(im2, 2);
            new_mat = [v, im2];
            h_new = flip(new_mat,1);
            j= [new_mat; h_new];
            imshow(i);
            
        end
        function [im_i, im_j] = compute_fourier(self, im_i, im_j)
            %PN EN A PLUS QUE DEUX POUR I ET J APRES COLLAGE
            im_i = (fft2(im_i));
            im_j= (fft2(im_j));
            
        end
        function ok = solve(self, im_i, im_j)
            [w,h] = size(im_i);
           % [im_i, im_j] = self.symmetry(im_i, im_j);
            [W,H] = size(im_i);
            mat = ones(W, H);
            [a,b] = find(mat);
            i= sqrt(-1);
            a = reshape(a,W,H);
            b = reshape(b,W,H);
            im_i = (fft2(im_i));
            im_j = (fft2(im_j));
            
            numerator = ((2*pi*i/w).*a).*im_i+((2*pi*i/h).*b).*im_j;
            denominator = ((2*pi*i/w).*a).^2+((2*pi*1i/h).*b).^2;
            
            sol =numerator./denominator;
            sol(1,1) = mean(sol(:));
            
            ok = ifft2((sol));
        end
        
        %DO THE CUT & PASTE
        % COMPUTE SYMMETRY
        %COMPUTE FOURIER ON EACH ELEMENT
        % USE FORMULAS
        %INVERT FOURIER
    end
    
end