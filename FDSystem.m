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
        function obj =  FDSystem(im)
            [x,y]= size(im);
            obj.size_matrix= x*y;
            
            obj.vector = zeros(obj.size_matrix, 1);
            obj.i_vect = [];
            obj.j_vect = [];
            obj.v_vect = [];
            
        end
        

        function add_four(self, i,j, ~, val)
        % Add the value '-4' in A(i,j)
              self.i_vect = [self.i_vect, i'];
              self.j_vect = [self.j_vect, j'];
              n_vec = ones(1,size(i,1));
              self.v_vect = [self.v_vect, val.*n_vec];
           
        end
        

        function pix_up_is_inside(self, i_four, j_four, val)
        %The pixel upside the pixel we want to compute is inside \Omega
        %Add the value '1' at the correct position
        % A(i,j-1) = 1
            n_vec = ones(1, size(i_four,1));
            j_four(:) = j_four(:)-1;
            self.i_vect = [ self.i_vect, i_four'];          
            self.j_vect = [ self.j_vect, j_four'];
            self.v_vect = [ self.v_vect, val.*n_vec];
             
        end
        

        function pix_down_is_inside(self, i_four, j_four, val)
        %The pixel downside the pixel we want to compute is inside \Omega
        %Add the value '1' at the correct position
        % A(i,j+1) = 1
            j_four(:) = j_four(:)+1;
            n_vec = ones(1, size(i_four,1));
            self.i_vect = [ self.i_vect, i_four'];
            self.j_vect = [ self.j_vect, j_four'];
            self.v_vect = [ self.v_vect, val.*n_vec];
        end
        

        function pix_right_is_inside(self, i_four, j_four, mask, val)
        %The pixel at the rightside of the pixel we want to compute is inside \Omega
        %Add the value '1' at the correct position
        % A(i,j+nb_row(mask)) = 1
            j_four(:) = j_four(:)+ size(mask,1);
            n_vec = ones(1, size(i_four,1));
            self.i_vect = [ self.i_vect, i_four'];
            self.j_vect = [ self.j_vect, j_four'];
            self.v_vect = [ self.v_vect, val.*n_vec];
        end
        

        function pix_left_is_inside(self, i_four, j_four, mask, val)
        %The pixel at the leftside of the pixel we want to compute is inside \Omega
        %Add the value '1' in the correct place
        % A(i,j-nb_row(mask)) = 1
            j_four(:)= j_four(:)-size(mask,1);
            n_vec = ones(1, size(i_four,1));
            self.i_vect = [ self.i_vect, i_four'];
            self.j_vect = [ self.j_vect, j_four'];
            self.v_vect = [ self.v_vect, val.*n_vec];
            
        end
        
       
        function is_inside(self, i, j, mask, vec)
        %the pixel we want to find is inside \Omega so his neighbours too.
        % calls the correct function associated to this condition
            self.add_four(i,j, mask, vec(1,1));
            self.pix_right_is_inside(i,j,mask,vec(1,2));   
            self.pix_left_is_inside(i,j,mask,vec(1,3)); 
            self.pix_up_is_inside(i,j,vec(1,4)); 
            self.pix_down_is_inside(i,j,vec(1,5)); 
               
        end
        

        function find_roi(self, maskS, maskT)
        % find the pixels that are inside the ROI 
        % If their value == 1 then there are inside
           [row, col]= find(maskS.matrix);
           %%NEW POSITION IN MY VECTOR
           row(:)= (col(:)-1).*size(maskS.matrix,1)+row(:);
           col(:) = row(:);
           self.is_inside(row(:), col(:), maskS.matrix, [-4, 1,1,1,1]);     
        end
        
          
        function find_useless(self, mat, mask)
        % Find the pixels that are NOT in the ROI
        % We don't want their Laplacian 
        % SO the equations associated to these pixels are : 
        % I(i,j) = 1
            [row,col] = find(mat ==0);
            for i = 1:size(row)
                k = (col(i)-1)*size(mat,1)+row(i);
                self.vector(k) = mask.cut_im(row(i), col(i));
            end
            row(:)= (col(:)-1).*size(mat,1)+row(:);
            col(:) = row(:);
            n_vec =ones(1, size(row,1));
            self.i_vect = [self.i_vect, row'];
            self.j_vect = [self.j_vect, col'];
            self.v_vect = [self.v_vect, n_vec];  
        end              
     
       
        function create_matrix(self, maskS, image, maskT)
        %Construct b_vector
        %Construct A sparse matrix : check if pixels are or not in \Omega
        %and then call the good function according to the answer.
            self.compute_laplacian(image);
            self.find_roi(maskS, maskT);
            self.find_useless(maskS.matrix, maskS);
            a = sparse(self.i_vect, self.j_vect, self.v_vect, self.size_matrix, self.size_matrix);
            self.matrix = a;
            
        end
        

        function compute_laplacian(self, image)
        %Compute the laplacian of the Source Image \Delta S
        % Construct the correct vector b
            im = circshift(image,1,2)+ circshift(image, -1, 2)+ circshift(image, 1,1)+ circshift(image, -1,1) -4.*image;
            self.vector =im(:);
            
        end
       
        function im =  solve(self, image)
        %Solve Ax = b 
        % x = A^-1 *b 
        % Reshape the  vector solution to a n by m matrix 
       % new_vector = grad_conj(self.matrix, self.vector, self.vector);
        new_vector = self.matrix\self.vector;
        im = reshape(new_vector, size(image,1), size(image,2));
            
        end
        
        end
        
end
