classdef Douglas<handle
    properties
      pf
      pg
      maskS
      maskT
    end
    methods
        function obj = Douglas(maskS, maskT)
            obj.maskS = maskS;
            obj.maskT = maskT;
        end
        function  [A,b] = compute_matrix(self, S,y)
           new_sys = FDSystem(self.maskS.matrix); %Inversion matrix
           [row, col] = meshgrid(2:size(y,1)-1,2:size(y,2)-1);
           row(:)= (col(:)-1).*size(self.maskS.matrix,1)+row(:);
           col(:) = row(:);
           new_sys.is_inside(row(:), col(:), self.maskS.matrix, [9, -2,-2,-2,-2]);  
           rectangle = zeros(size(y,1), size(y,2));
           rectangle(2:size(y,1)-1, 2:size(y,2)-1) = 1;
           new_sys.find_useless(rectangle, self.maskT)
            
           A = sparse(new_sys.i_vect, new_sys.j_vect, new_sys.v_vect, new_sys.size_matrix, new_sys.size_matrix);
           new_sys.compute_laplacian(S);
           b = new_sys.vector;
        end
        
        function pf = prox_f(self, A, b, y)
           b = y(:)-2.*b;
           %pf = A\b;
           pf = grad_conj(A, b,b);
           
           pf = reshape(pf, size(y,1), size(y,2));
        end
        
        
        function pg = prox_g(self,x)
            %%%%% Indicator function%%%%%%
            pg = x.*(self.maskS.matrix)+(self.maskT.cut_im).*(~self.maskS.matrix);
        end
        
        function x = douglas(self, y0, handles)
            y = y0;
            [A,b] = self.compute_matrix(self.maskS.cut_im, y0);
            eps = 1;
            x = ones(size(y0,1),size(y0,2));
            i = 1;
            while eps > 10^-3
                xx = self.prox_f(A, b, y);
                y = y+1.89*(self.prox_g(2.*xx-y)-xx);
                eps = norm(xx-x, 2)^2;
                x =xx;
                i = i+1;
               
            end
            
        end
        
    end
    
    
    
end
