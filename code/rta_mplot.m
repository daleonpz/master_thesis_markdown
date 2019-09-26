function rta_mplot(num_kernels)

m = [8,16,32,64,128];
t = zeros(length(m),num_kernels);
total_blocks = zeros(length(m),num_kernels);
for i = 1:length(m)
    for n = 1:num_kernels
        tic;
        total_blocks(i,n) = run_rta(n,200,2,m(i));
        t(i,n) = toc;
    end
end

figure; 
subplot(131)
hold on;
plot(1:num_kernels,t(1,:),'b--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,t(2,:),'k--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,t(3,:),'r--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,t(4,:),'g--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,t(5,:),'m--*','MarkerSize',10, 'LineWidth',2)
legend('g_max = 8','g_max = 16','g_max = 32','g_max = 64','g_max = 128')
grid on
title('Number of Kernels vs Computation Time')

subplot(132)
hold on;
plot(1:num_kernels,total_blocks(1,:),'b--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,total_blocks(2,:),'k--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,total_blocks(3,:),'r--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,total_blocks(4,:),'g--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,total_blocks(5,:),'m--*','MarkerSize',10, 'LineWidth',2)
legend('g_max = 8','g_max = 16','g_max = 32','g_max = 64','g_max = 128')
grid on
title('Number of Kernels vs  Total blocks')

subplot(133)
hold on;
plot(total_blocks(1,:),t(1,:),'b*','MarkerSize',10, 'LineWidth',2)
plot(total_blocks(2,:),t(2,:),'k*','MarkerSize',10, 'LineWidth',2)
plot(total_blocks(3,:),t(3,:),'r*','MarkerSize',10, 'LineWidth',2)
plot(total_blocks(4,:),t(4,:),'g*','MarkerSize',10, 'LineWidth',2)
plot(total_blocks(5,:),t(5,:),'m*','MarkerSize',10, 'LineWidth',2)
legend('g_max = 8','g_max = 16','g_max = 32','g_max = 64','g_max = 128')
grid on
title('Total blocks vs time')


m = [10,25,50,100];
t = zeros(length(m),num_kernels);
total_blocks = zeros(length(m),num_kernels);
for i = 1:length(m)
    for n = 1:num_kernels
        tic;
        total_blocks(i,n) = run_rta(n,m(i),2,32);
        t(i,n) = toc;
    end
end

figure; 
subplot(131)
hold on;
plot(1:num_kernels,t(1,:),'b--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,t(2,:),'k--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,t(3,:),'r--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,t(4,:),'g--*','MarkerSize',10, 'LineWidth',2)
legend('bmax = 10','bmax = 25','bmax = 50','bmax = 100')
grid on
title('Number of Kernels vs Computation Time')

subplot(132)
hold on;
plot(1:num_kernels,total_blocks(1,:),'b--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,total_blocks(2,:),'k--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,total_blocks(3,:),'r--*','MarkerSize',10, 'LineWidth',2)
plot(1:num_kernels,total_blocks(4,:),'g--*','MarkerSize',10, 'LineWidth',2)
legend('bmax = 10','bmax = 25','bmax = 50','bmax = 100')
grid on
title('Number of Kernels vs  Total blocks')

subplot(133)
hold on;
plot(total_blocks(1,:),t(1,:),'b*','MarkerSize',10, 'LineWidth',2)
plot(total_blocks(2,:),t(2,:),'k*','MarkerSize',10, 'LineWidth',2)
plot(total_blocks(3,:),t(3,:),'r*','MarkerSize',10, 'LineWidth',2)
plot(total_blocks(4,:),t(4,:),'g*','MarkerSize',10, 'LineWidth',2)
legend('bmax = 10','bmax = 25','bmax = 50','bmax = 100')
grid on
title('Total blocks vs time')


end 

function g = run_rta(n,gmax,gmin,g_m)
% [ time, g_i] 
f = zeros( n, 1);
% g_i \in [2,500]
g_i = round( (gmax - gmin).*rand(1,n) + gmin) ;
% c_i \in [20,100]
c_i = round( (100 - 20).*rand(1,n) + 20) ;

g  = sum(g_i);

% Initalization
ta = 0;
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
