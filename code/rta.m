 function m= rta()

% [ time, g_i] 
tau = [ 4,2; 6,7; 6,2; 5,5] ;
n = size(tau,1);
f = zeros( n, 1);

T = 15;

% Initalization
ta = 0;
g_m = 8;
h = [];
g_f = g_m; 
i= 1;

g_i = tau(:,2);
c_i = tau(:,1);

%memory
m = zeros(g_m, 2*T);
% i'll paint  with 1 the memory spaces 
% that have been allocated
farbe = randi([100 250]);

while ( i <= n )
    
    ro = min(find ( m(:,ta+1) == 0));
    
    
    
   if (g_f >= g_i(i) )
       f(i) = ta + c_i(i); 
       h = [h; f(i), g_i(i)];
       ta = ta;
       g_f = g_f - g_i(i);
       
       m(ro: ro + g_i(i)-1,ta+1 : ta+c_i(i)) = farbe;
       
       i += 1;
       
       farbe = randi([100 250]);
       
   else
       g_i(i) = g_i(i) - g_f;
       h = [h; ta + c_i(i), g_f];
       
       % summing blocks with similar ta
       [values, ~, ids] = unique(h(:, 1 ));
       c = arrayfun(@(k) sum(h(k==ids,2)),1:max(ids));
       h = [values, c'];
       
       m(ro: ro + g_f-1,ta+1 : ta+c_i(i)) = farbe;
       
       [ta, index] = min(h(:,1));
       g_f = h(index, 2);
    
      % removing lower time
       h(index, :) = [];
     
        
       
    end
 
end

f
imshow(m,[]);

end
