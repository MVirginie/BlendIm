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
        
        function x = douglas(self, y0, handles)
            y = y0;
            eps = 1;
            x = ones(size(y0,1),size(y0,2));
            i = 1;
            while eps >10^-2
                i = i+1
                xx = self.prox_f(self.maskS.cut_im, y);
                y = y+self.prox_g(2.*xx-y)-xx;
                eps = norm(xx-x, 2)^2;
                x =xx;
            end
%             handles.maskS.cut_im = x;
%             img = copyPaste(handles.maskS, handles.maskT,x, handles.maskT.associate_im);

        end
    end
    
end
