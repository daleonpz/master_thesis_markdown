function rta_plot(num_kernels)

t = zeros(1,num_kernels);
total_blocks = zeros(1,num_kernels);
for n = 1:num_kernels
    tic;
    total_blocks(n) = run_rta(n,8,2);
    t(n) = toc;
end

[total_blocks,i] = sort(total_blocks);
tsort = t(i);
[total_blocks, ids,~] = unique(total_blocks);
tsort = tsort(ids);

figure;
subplot(121)
plot(1:num_kernels,t,'b--*','MarkerSize',10)
p = polyfit(1:num_kernels,t,5)
f = polyval(p,1:num_kernels);
hold on
plot(1:num_kernels,f,'--r')
subplot(122)
plot(total_blocks, tsort,'b*','MarkerSize',10); 
p = polyfit(total_blocks,tsort,2)
f = polyval(p,total_blocks);
hold on
plot(total_blocks,f,'--r')
grid on
end 

function g = run_rta(n,gmax,gmin)
% [ time, g_i] 
f = zeros( n, 1);
% g_i \in [2,500]
g_i = round( (gmax - gmin).*rand(1,n) + gmin) ;
% c_i \in [20,100]
c_i = round( (100 - 20).*rand(1,n) + 20) ;

g  = sum(g_i);

% Initalization
ta = 0;
g_m = 8;
h = [];
g_f = g_m; 
i= 1;

%memory
while ( i <= n )
   if (g_f >= g_i(i) )
       f(i) = ta + c_i(i); 
       h = [h; f(i), g_i(i)];
       ta = ta;
       g_f = g_f - g_i(i);
       i = i+1;
   else
       g_i(i) = g_i(i) - g_f;
       h = [h; ta + c_i(i), g_f];
       
       % summing blocks with similar ta
       [values, ~, ids] = unique(h(:, 1 ));
       c = arrayfun(@(k) sum(h(k==ids,2)),1:max(ids));
       h = [values, c'];
       
       [ta, index] = min(h(:,1));
       g_f = h(index, 2);
    
      % removing lower time
       h(index, :) = [];
    end
 
end

end 
