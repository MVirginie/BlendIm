        function x = grad_conj(A,x, b)
            r = b-A*x;
            p = r;
            while(norm(r,2)^2 > 10^-2)
                alpha = (r'*r)/(p'*A*p);
                xx = x+alpha*p;
                rr= r-alpha*A*p;
                B = (rr'*rr)/(r'*r);
                p = rr+B*p;
                x = xx;
                r = rr;
            end
        end