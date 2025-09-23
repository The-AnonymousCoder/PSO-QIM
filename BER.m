

% function N=BER(mark_get,mark_prime)
% if size(mark_get)~=size(mark_prime)
%     error('Input vectors must  be the same size!')%mark_get和mark_prime大小不等时，无法计算相关系数，报错！
% else
%     [m,n]=size(mark_get);
%     fenzi=(xor(mark_get,mark_prime));
%     fenzi=sum(sum(fenzi));
%     N=100*fenzi/(m*n);
% end
% end

function N = BER(mark_get, mark_prime)
    % Check if the input vectors are of the same size
    if ~isequal(size(mark_get), size(mark_prime))
        error('Input vectors must be the same size!');
    else
        % Get dimensions of the input vectors
        [m, n] = size(mark_get);
        
        % Calculate the number of bit errors
        num_errors = sum(sum(xor(logical(mark_get), logical(mark_prime))));
        
        % Calculate the Bit Error Rate (BER) as a percentage
        N = num_errors / (m * n);
    end
end
