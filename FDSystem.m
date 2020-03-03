classdef FDSystem <handle
    %Class FDSystem to sole Ax = b, with the following properties : 
    %------------ size_matrix : the size of A
    %------------ matrix : the sparse matrix 'A' in the system : Ax=b
    %------------ vector : the 'b' vector in the system Ax=b
    %------------i_vect : the row indices of the sparse matrix 'matrix"
    %------------j_vect : the col's indices of the sparse matrix A
    %------------v_vect : the value of the sparse matrix : A(i_vect(k),
    %j_vect(k)) = v_vect(k)
    properties
        size_matrix
        matrix
        vector
        i_vect;
        j_vect; 
        v_vect;
        
    end
    
    methods 
        %The constructor
        function obj =  FDSystem(mask)
            [x,y]= size(mask.matrix);
            obj.size_matrix= x*y;
            
            obj.vector = zeros(obj.size_matrix, 1);
            obj.i_vect = [];
            obj.j_vect = [];
            obj.v_vect = [];
            
        end
        
        %Function add_four : 
        % Add the value '-4' in A(i,j)
        function add_four(self, i,j, mask)
%
              self.i_vect = [self.i_vect, i'];
              self.j_vect = [self.j_vect, j'];
              n_vec = ones(1,size(i,1));
              self.v_vect = [self.v_vect, -4.*n_vec];
           
        end
        
        %Function pix_up_is_inside
        %The pixel upside the pixels we wants to compute is inside \Omega
        %Add the value '1' in the correct place
        % A(i,j-1) = 1
        function pix_up_is_inside(self, i_four, j_four)
            n_vec = ones(1, size(i_four,1));
            j_four(:) = j_four(:)-1;
            self.i_vect = [ self.i_vect, i_four'];          
            self.j_vect = [ self.j_vect, j_four'];
             self.v_vect = [ self.v_vect, n_vec];
             
        end
        
        %Function pix_down_is_inside
        %The pixel downside the pixel we want to compute is inside \Omega
        %Add the value '1' in the correct place
        % A(i,j+1) = 1
        function pix_down_is_inside(self, i_four, j_four)

            j_four(:) = j_four(:)+1;
            n_vec = ones(1, size(i_four,1));
            self.i_vect = [ self.i_vect, i_four'];
            self.j_vect = [ self.j_vect, j_four'];
            self.v_vect = [ self.v_vect, n_vec];
        end
        
        %Function pix_right_is_inside
        %The pixel at the rightside of the pixel we want to compute is inside \Omega
        %Add the value '1' in the correct place
        % A(i,j-nb_row(mask)) = 1
        function pix_right_is_inside(self, i_four, j_four, mask)

            j_four(:) = j_four(:)+ size(mask.matrix,1);
            n_vec = ones(1, size(i_four,1));
            self.i_vect = [ self.i_vect, i_four'];
            self.j_vect = [ self.j_vect, j_four'];
            self.v_vect = [ self.v_vect, n_vec];
        end
        
        %Function pix_left_is_inside
        %The pixel at the leftside of the pixel we want to compute is inside \Omega
        %Add the value '1' in the correct place
        % A(i,j-nb_row(mask)) = 1
        function pix_left_is_inside(self, i_four, j_four, mask)
            
            j_four(:)= j_four(:)-size(mask.matrix,1);
            n_vec = ones(1, size(i_four,1));
            self.i_vect = [ self.i_vect, i_four'];
            self.j_vect = [ self.j_vect, j_four'];
            self.v_vect = [ self.v_vect, n_vec];
            
            
        end
        % Function : is_inside 
        %the pixel we want to find is inside so his neighbours too.
        % calls the correct function associated to this condition
        function is_inside(self, i, j, mask)
             self.add_four(i,j, mask);
            self.pix_right_is_inside(i,j,mask);   
             self.pix_left_is_inside(i,j,mask); 
              self.pix_up_is_inside(i,j); 
               self.pix_down_is_inside(i,j); 
               
        end
        
        %Function find_roi
        % find the pixels that are inside the ROI 
        % If their value == 1 then there are inside
        function find_roi(self, mask)
           [row, col]= find(mask.matrix);
           row(:)= (col(:)-1).*size(mask.matrix,1)+row(:);
           col(:) = row(:);
           
           self.is_inside(row(:), col(:), mask);
          
        end
       
        %Function : find_useless
        % Find the pixels that are NOT in the ROI
        % We don't want their Laplacian 
        % SO the equations associated to these pixels are : 
        % I(i,j) = 1
        function find_useless(self, mask)
            [row,col] = find(mask.matrix ==0);
            for i = 1:size(row)
                k = (col(i)-1)*size(mask.matrix,1)+row(i);
                self.vector(k) = mask.cut_im(row(i), col(i));
            end
                row(:)= (col(:)-1).*size(mask.matrix,1)+row(:);
                col(:) = row(:);
                n_vec =ones(1, size(row,1));
                self.i_vect = [self.i_vect, row'];
                self.j_vect = [self.j_vect, col'];
                self.v_vect = [self.v_vect, n_vec];  
        end
                
        
        %TRY FUNCTION(work_on_boundaries) 
        %Check the neighbours and then try to add the known one to the b
        %vector (add Dirichlet)
        function work_on_boundaries(self, mask)
            
            pixminusi = mask.boundaries(:,1)-1;
   
            pixminusj = mask.boundaries(:,2)-1;
            pixplusi = mask.boundaries(:,1)+1;
            pixplusj = mask.boundaries(:,2)+1;
            
            for i = 1: size(mask.boundaries(:,1))
                
                [k, l] = self.add_four(mask.boundaries(i,1),mask.boundaries(i,2), mask);
                if mask.matrix(pixplusi(i),mask.boundaries(i,2)) == 0
                    
                    self.vector(k) = self.vector(k)-mask.cut_im(pixplusi(i),mask.boundaries(i,2));
                else
                    self.pix_down_is_inside(k, l);
                    
                end          
                if mask.matrix(pixminusi(i),mask.boundaries(i,2)) == 0
                   
                    self.vector(k) = self.vector(k)-mask.cut_im(pixminusi(i),mask.boundaries(i,2));
                else
                    self.pix_up_is_inside(k, l);
                end
                
                if mask.matrix(mask.boundaries(i,1), pixplusj(i)) == 0
                  
                    self.vector(k) = self.vector(k)-mask.cut_im(mask.boundaries(i,1), pixplusj(i));
                else
                    self.pix_right_is_inside(k, l, mask);
                 
               
                end
                if mask.matrix(mask.boundaries(i,1), pixminusj(i)) == 0
                   
                    self.vector(k) = self.vector(k)-mask.cut_im(mask.boundaries(i,1), pixminusj(i));
                   
                else
                    self.pix_left_is_inside(k,l, mask);
               
                end
            end
            
           
        end
        
        %Function create_matrix 
        %Construct b_vector
        %Construct A sparse matrix : check if pixels are or not in \Omega
        %and then call the good function according to the answer.
        function create_matrix(self, mask, image)
            self.compute_laplacian(image);
            self.find_roi(mask);
            self.find_useless(mask);
            self.matrix = sparse(self.i_vect, self.j_vect, self.v_vect, self.size_matrix, self.size_matrix);
            
            
        end
        
        %Compute the laplacian of the Source Image \Delta S
        % Construct the correct vector b
        function compute_laplacian(self, image)
            im = circshift(image,1,2)+ circshift(image, -1, 2)+ circshift(image, 1,1)+ circshift(image, -1,1) -4.*image;
            self.vector =im(:);
            
        end
        %Function solve : 
        %Solve Ax = b 
        % x = A^-1 *b 
        % Reshape the  vector solution to a n by m matrix 
        function im =  solve(self, image)
            mat = self.matrix;
            new_vector = self.matrix\self.vector;
            im = reshape(new_vector, size(image,1), size(image,2));
        end
        
        
        end
        
end
