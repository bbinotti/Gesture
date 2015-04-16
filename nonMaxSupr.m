function B = nonMaxSupr(A)
B = zeros(size(A));
for i = 2 : size(A,1) - 1
    for j = 2 : size(A,2) - 1
        if( A(i,j) == 0 )
            continue;
        end
        if( A(i,j) >= A(i-1,j) && A(i,j) >= A(i+1,j) && ...
            A(i,j) >= A(i,j-1) && A(i,j) >= A(i,j+1) )
            B(i,j) = A(i,j);
        end
    end
end