classdef Douglas<handle
    %TO DO 
        % FIND PROX F
        % FIND PROX G
        %COMPUTE DOUGLAS ALGORITHM
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
        
        function x = descent_grad(f, self)
            eps=1;
            x=[-1;1];
            while eps>10^-7
                d=grad_J(x);
                t=self.newton(x,d);
                xx=x+t*d;
    
                eps=norm(xx-x,2);
                x=xx;
            end
        end
        function t=newton(x,d)
        grad_J=inline('u-2*grad_u-y+2*grad_s','u', 'grad_u', 'y', 'grad_s');
        H_j=inline('[120*x(1).^2+2-40*x(2) -20*x(1) ; -40*x(1) 20]','x');

        eps=10;
        t =0;
        while eps>10.^-5
            h=d'*grad_J(x+d*t);
            k=d'*H_j(x+d*t)*d;
        
            tt=t-h/k;
    
            eps=norm(d*t-d*tt,2);
            t=tt;
        end
        end         
       
        function pf = prox_f(self, S, y)
           new_sys = FDSystem(self.maskS.matrix); %Inversion matrix
           [row, col] = meshgrid(2:size(y,1)-1,2:size(y,2)-1);
           row(:)= (col(:)-1).*size(self.maskS.matrix,1)+row(:);
           col(:) = row(:);
           new_sys.is_inside(row(:), col(:), self.maskS.matrix, [9, -2,-2,-2,-2]);  
           rectangle = zeros(size(y,1), size(y,2));
           rectangle(2:size(y,1)-1, 2:size(y,2)-1) = 1;
           new_sys.find_useless(rectangle, self.maskT)
            
           new_sys.matrix = sparse(new_sys.i_vect, new_sys.j_vect, new_sys.v_vect, new_sys.size_matrix, new_sys.size_matrix);
           new_sys.compute_laplacian(S);
           new_sys.vector = y(:)-2.*new_sys.vector;
           pf = new_sys.matrix\new_sys.vector;
           pf = reshape(pf, size(y,1), size(y,2));
        end
        
        
        function pg = prox_g(self,x)
            %%%%% Indicator function%%%%%%
            pg = x.*(self.maskS.matrix)+(self.maskT.cut_im).*(~self.maskS.matrix);
        end
        
        function img = douglas(self, y0, k, handles)
            y = y0;
            for i = 1:k
                i
                x = self.prox_f(self.maskS.cut_im, y);
                y = y+self.prox_g(2.*x-y)-x;
            end
            handles.maskS.cut_im = x;
            img = copyPaste(handles.maskS, handles.maskT,x, handles.maskT.associate_im);
        end
    end
    
end
