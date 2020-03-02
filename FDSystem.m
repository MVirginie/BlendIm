classdef FDSystem <handle
    properties
        size_matrix
        matrix
        vector
        i_vect;
        j_vect; 
        v_vect;
        indices;
    end
    
    methods 
        function obj =  FDSystem(mask)
            [x,y]= size(mask.matrix);
            obj.size_matrix= x*y;
            obj.matrix = zeros(obj.size_matrix, obj.size_matrix);
            obj.vector = zeros(obj.size_matrix, 1);
            obj.i_vect = [];
            obj.j_vect = [];
            obj.v_vect = [];
            
        end
        
        function base_matrix(self, length)
            x = zeros(1,length);
            x(1) =1;
            x(2) = -4;
            x(3) = 1;
            self.matrix = toeplitz([x(1) fliplr(x(2:end))], x);
        end
        
        function [i_four, j_four] = add_four(self, i,j, mask) 
            i_four = (j-1)*size(mask.matrix,1)+i;
            j_four = i_four;            
            self.i_vect = [self.i_vect, i_four];
            self.j_vect = [self.j_vect,j_four];
            self.v_vect = [self.v_vect, -4];
           
        end
        
        function pix_up_is_inside(self, i_four, j_four)
            self.i_vect = [ self.i_vect, i_four];
            self.j_vect = [ self.j_vect, j_four-1];
            self.v_vect = [ self.v_vect, 1];
             
        end
        
        function pix_down_is_inside(self, i_four, j_four)
            self.i_vect = [ self.i_vect, i_four];
            self.j_vect = [ self.j_vect, j_four+1];
            self.v_vect = [ self.v_vect, 1];
        end
        
        function pix_right_is_inside(self, i_four, j_four, mask)
           
            self.i_vect = [ self.i_vect, i_four];
            self.j_vect = [ self.j_vect, j_four+ size(mask.matrix,1)];
            self.v_vect = [ self.v_vect, 1];
        end
        
        function pix_left_is_inside(self, i_four, j_four, mask)
            
            self.i_vect = [ self.i_vect, i_four];
            self.j_vect = [ self.j_vect, j_four- size(mask.matrix,1)];
            self.v_vect = [ self.v_vect, 1];
        end
        
        function is_inside(self, i, j, mask)
            [i_four, j_four] = self.add_four(i,j, mask);
            self.pix_right_is_inside(i_four,j_four,mask);   
             self.pix_left_is_inside(i_four,j_four,mask); 
              self.pix_up_is_inside(i_four,j_four); 
               self.pix_down_is_inside(i_four,j_four); 
               
        end
        
        function find_roi(self, mask)
           [row, col]= find(mask.matrix==1);
           for k = 1:size(row)
            self.is_inside(row(k), col(k), mask);
           end
        end
        
        function find_bound(self, mask)
            [row, col] = find(mask.matrix==0.5);
            for k = 1:size(row)
                self.is_inside(row(k), col(k), mask);
            end
        end
        function find_useless(self, mask)
            [row,col] = find(mask.matrix ==0);
            for i = 1:size(row)
                k = (col(i)-1)*size(mask.matrix,1)+row(i);
                self.i_vect = [self.i_vect, k];
                self.j_vect = [self.j_vect, k];
                self.v_vect = [self.v_vect, 1];
                self.vector(k) = mask.cut_im(row(i), col(i));
            end
        end
                
        
        
        function work_on_boundaries(self, mask)
            
            pixminusi = mask.boundaries(:,1)-1;
            save('matrix.mat', 'pixminusi');
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
        
        function create_matrix(self, mask, image)
            self.compute_laplacian(image);
            self.find_roi(mask);
            self.find_bound(mask);
            self.find_useless(mask);
            %self.work_on_boundaries(mask);
            self.matrix = sparse(self.i_vect, self.j_vect, self.v_vect, self.size_matrix, self.size_matrix);
            
            
        end
        
        function compute_laplacian(self, image)
            im = circshift(image,1,2)+ circshift(image, -1, 2)+ circshift(image, 1,1)+ circshift(image, -1,1) -4.*image;
            self.vector =im(:);
            
        end
        function im =  solve(self, image)
            mat = self.matrix;
            new_vector = self.matrix\self.vector;
            im = reshape(new_vector, size(image,1), size(image,2));
        end
        
        
        end
        
end
