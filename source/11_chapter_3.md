# Jetson TX2's GPU scheduler response time analysis 
 
## Introduction
In this chapter, we present our approach to calculate the response time analysis for Jetson TX2's GPU scheduler based on the set of scheduling rules explained in the last chapter. **Need a better introduction**

## Task model
There is a set of tasks or kernels $\tau$ of $n$ independent kernels $\{\tau_1, \tau_2, \ldots, \tau_n\}$ on a single GPU. 
Each kernel has a period $T_i$ defined as the separatin between two consecutivs releases of $\tau_i$, thread execution time workload $C_i$ and a grid of blocks $g_i$. Each block contains $b_i$ threads. 

\begin{equation} 
\tau = \{ \tau_i \}; \quad i \geq n \wedge n \in \mathbb{N}
\end{equation}

\begin{equation} 
\tau_i = \{ T_i,  C_i,  g_i,  b_i \}
\label{eq:task_def}
\end{equation}

Thus each kernel $\tau_i$ has a total of $g_i\cdot b_i$ threads, and the total execution time workload of $\tau_i$ is $C_i \cdot g_i \cdot b_i$. 
The utilization of each kernel is defined as the total execution time workload divided by the period, as stated in [@yang2019].


\begin{equation} 
u_i = \frac{C_i g_i b_i}{T_i}
\label{eq:task_utilization}
\end{equation}

In addition, the total utilization of the set of tasks $\tau$ is defined as:

\begin{equation} 
U_t = \sum_{\tau_i \in \tau} u_i
\label{eq:task_utilization}
\end{equation}

For a kernel $\tau_i$ we denote the release time as $r_i$, the completion time as $f_i$ and response time as $R_i = f_i - r_i$ 
We assume that a kernel $\tau_i$ has  a deadline equal to its period $T_i$.

![Time chart \label{img:task_timing} ](source/figures/task_timing.png){width=100%}


## Assumptions
For the calculation of the response time we have two assumption:

### All blocks have the same amount of threads
The election of the optimum number of threads for a specific kernel is a hard task, for that reason there have been some efforts towards that direction  [@Mukunoki2016], [@Lim2017], [@Torres2011], [@Kurzak2012].
However, NVIDIA developers recommend,  for practical purposes, on their offical guides [@CCUDA20192] and [@CCUDA2019] to use block sizes equals to either 128, 256,  512 or 1024, because it has been documented that these values are more likely to take full advantage of the GPU resources.
In our case we will assume that all the blocks, regarless the kernel, are the same size.


\begin{equation} 
b_i = b, \quad \forall \tau_i \in \tau
\label{eq:blocksize}
\end{equation}



### One big streaming multiprocessor
This assumption is derived from the previous one. 
Each streaming multiprocessor in the Jetson TX2 has 2048 available threads and since $b_i$ can be either 128, 256, 512 or 1024 ($2048/ b_i = k, k \in \mathbb{N}$), we can think of the two streaming multiprocessors as a big one of 4096 threads. 

It means that it could be allocated $2048/b_i$ blocks per SM or $4096/b_i$ blocks in the big SM. 
Hereafter we will refer the big SM as it were the only SM in the Jetson TX2's GPU. 
Thus, we defined $g_{max}$  as the maximum number of blocks that can be allocated in the SM at some point in time.


\begin{equation} 
g_{max} = \frac{b_{max}}{b}, \quad  g_{max} \in \mathbb{N}
\label{eq:max_grid}
\end{equation}

Where $b_{max}$ is the maximum amount of threads in the GPU, in the case of Jetson TX2 is 4096. 

## Introduction to GPU  Response Time Analysis 
In addition to the variables defined in our assumptions we define $g_{f}$ as the number of blocks that are available at some point in time $t$, and $t_a$ as the point in time in which a block $b_i \in g_i$ can be allocated. 

For example in Figure \ref{img:free_blocks}a is shown that for a $t=t_1$ the amount of free blocks $g_{f}$ is lower than $g_{max}$ while in Figure \ref{img:free_blocks}b for a $t=t_2$, $g_{f} = g_{max}$.

![Free blocks (a) at $t=t_1$, $g_f < g_{max}$ (b) at $t=t_2$, $g_f = g_{max}$ \label{img:free_blocks}](source/figures/free_blocks.png)


In Figure \ref{img:ta_example} we present two cases. Let's assume there is  a new kernel K4 which wants to allocate a block $b_i \in g_i$. In Figure \ref{img:ta_example}a the release time $r_4$ of the kernel 4 is lower than $t_1$, which means that $t_a = t_1$ because $r_4 \leq t_1$ and kernel 3 (K3) was already dequeued.
In Figure \ref{img:ta_example}b  $r_4$ lies between $t_2$ and $t_3$, in that case $t_a = r_4$, because all previous kernels  were already dequeued and there are enough resources.  

![(a) $t_a=t_1 \quad  \forall r_4$ s.t $r_4 \leq t_1$ (b) $t_a=r_4 \quad \forall r_4$ s.t $t_2 \leq r_4 \leq t_3$ \label{img:ta_example}](source/figures/ta_example.png)



Assuming $t_a$ is known, we would need to calculate how many blocks can be allocated at that point of time. 
In other words, we need to know the value of $g_f$ at $t_a$. 
In Figure \ref{img:new_kernel_1}a a new kernel K3 with 6 blocks $g_3 = 6$ is going to be allocation on the Jetson's GPU. 
Each block have 512 threads, which means that $g_{max} = 8$.
The GPU is not executing any kernel at $t=t_a$ as shown in Figure \ref{img:new_kernel_1}b therefore $g_f = g_{max} = 8$ at $t=t_a$. 
Given that $g_3 < g_f$ all the blocks of K3 will be allocated at the same time as shown in Figure \ref{img:new_kernel_1}c. 
The completion time $f_3$ of kernel K3 is $t_a$ plus the thread execution time given by $C_3$, $f_3 = C_3 + t_a$.
If we assume that the release time $r_3$ is the same as $t_a$ then the completion time for K3 is the same as the response time $R_3$, otherwise $R_3 \geq f_3$. 



![(a)New kernel $K3$ with 6 blocks to allocate $g_3 = 6$.  (b) State prior to $K3$ of the GPU (c) state after K3 allocation  \label{img:new_kernel_1}](source/figures/new_kernel_1.png)

Once $f_3$ and $R_3$ are calculated, it's important to update the values of $t_a$ and $g_f$, because these values will be used by the following kernel. 
Let's start with $g_f$, it is easy to notice that after K3 allocation there are two free blocks $g_f - g_3 = 2$ as a result the new value of $g_f = 2$. On the other hand, by definition $t_a$ is the  point in time in which a block $b_i \in g_i$ can be allocated, therefore $t_a$ will not change because $g_f > 0$.  



In Figure \ref{img:new_kernel_2} we analyze another highly probable scenario. We use the same kernel K3 as in the last example ($g_3 = 6$). 
However, as shown in Figure \ref{img:new_kernel_2}b, there were two kernels allocated previously to K3. Kernel K1 with 5 allocated blocks $g_1 = 5$ and K2 with 3 allocated blocks $g_2 = 3$.
Note that these kernels have different completion time $f_2 > f_1$. 
Nevertheless, what matters is not either K1 or K2 completion time but the value of $t_a$ and $g_f$. 
In this example, $t_a$ is the same as K1 completion time and $g_f$ has the same value as $g_1$, $g_f = 5$. 
Thus, 5 blocks from K3 will be allocated first as shown in Figure \ref{img:new_kernel_2}c. 

![(a)New kernel $K3$ with 6 blocks to allocate $g_3 = 6$.  (b) State prior to $K3$ of the GPU. Kernels K1 and K2 were previously allocated (c) state after K3 allocation  \label{img:new_kernel_2}](source/figures/new_kernel_2.png)


The next logic question is where the last block of K3 should be allocated. The answer again is given by the updated values of $t_a$ and $g_f$.
Looking at  Figure \ref{img:new_kernel_2}c is easy to get these new values. 
The new value of $t_a$ is $f_2$ since $f_2 <( t_a + C_3 )$, and for $t=t_a$ the corresponding $g_f$ is $g_2$. Thus, the last K3 block  is allocated at $t=t_a=f_2$ and that give us the completion time for K3 that is $f_3 = f_2+C_3$ or $f_3 = t_a + C_3$. 
In Figure \ref{img:new_kernel_2}c, we defined a new variable $C^{*}_3$ as the total amount of time in which K3 was using GPU resources. 


After K3 allocation, $t_a$ and $g_f$ should be updated again. In this example, the new $g_f$ is the old value of $g_f$ minus the last allocated K3 blocks $g_f = g_f - 1 = 2$, while $t_a$ remains the same $t_a = f_2$ because the conditions are the same as in the later example where there was only one kernel. 




## Response Time Analysis Algorithm
Our algorithm is focused on the calculation of $t_a$ and $g_f$ for each block regarless from which kernel $t_i$ comes. 
In addition, it is important to notice that  $t_a$ and $g_f$ depend on how previous blocks were allocated and on the GPU state at some point in time, as it was described above and illustrated in the Figure \ref{img:new_kernel_1} and Figure \ref{img:new_kernel_2}.  
The output of our algorithm is a set of release times ${f_1, f_2, \cdots, f_n}$ where $n$ is the length of $\tau$ which values $f_i$ depend on $t_a$ and $C_i$.

\begin{equation}
f_i = f(t_a, C_i)
\end{equation}

A basic version of our algorithm is described in Algorithm \ref{alg:basic}. 
This version is derived directly from the examples illustrated in Figure \ref{img:new_kernel_1} and Figure \ref{img:new_kernel_2}, in other words, this basic algorithm is a summary of the section above. 
We have omitted details such as how $t_a$ and $g_f$ are updated in the case that $g_f \geq g_i$, however we still keep the big picture of what is necessary at each step.


\begin{figure}[ht]
\centering
\begin{minipage}{.7\linewidth}
    \begin{algorithm}[H]
        \DontPrintSemicolon
        \SetAlgoLined
        \SetKwInOut{Input}{Input}\SetKwInOut{Output}{Output}
        \Input{$\tau$}
        \Output{${f_1,\cdots, f_n}$}
        \BlankLine
        Initialization: $t_a = 0$, $g_f = g_{max}$, $i=1$ \\
        \While{ $i \leq n$}{
            \eIf{ $g_f \geq g_i$}{
                $f_i = t_a + C_i$; \\
                Update $g_f$ and $t_a$; \\
                i++ ; // Next kernel \\ 
            }{
                $g_i = g_i - g_f$;\\
                Update $g_f$ and $t_a$; \\
            }
        }
        \caption{Basic real time analysis algorithm }
        \label{alg:basic}
    \end{algorithm} 
  \end{minipage}
\end{figure}

In order to analyze a new kernel $\tau_i$ and update $t_a$ and $g_f$ we need to track old values of $g_f\quad \forall t \leq t_a$. 
Fortunately, it is necessary only to track $g_f$ at specific points of time.
Some relevant points of time , as it was shown in the previous example described by Figure \ref{img:new_kernel_2}, are given by completion times of previous kernels, in other words we must track $g_{i-k}$ and $f_{i-k}$ where $k \in {1,2,\dots, i-1}$, because updated values of $g_f$ and $t_a$ depend as well  on these them.

Let's define a set $h$ of pair of values $(t_k, g_k)$ where $g_k$ are the number of free blocks at $t=t_k$ such that  $t_k \geq t_a$. In a further example we will show step by step how this array $h$ is filled and updated in order to have a better understanding. 

A complete version of our algorithm is presented in Algorithm \ref{alg:full}. 


\begin{figure}[ht]
\centering
\begin{minipage}{.7\linewidth}
    \begin{algorithm}[H]
        \DontPrintSemicolon
        \SetAlgoLined
        \SetKwInOut{Input}{Input}\SetKwInOut{Output}{Output}
        \Input{$\tau$}
        \Output{${f_1,\cdots, f_n}$}
        \BlankLine
        Initialization: $t_a = 0$, $g_f = g_{max}$, $i=1$, $h = \{\}$ \\
        \While{ $i \leq n$}{
            \eIf{ $g_f \geq g_i$}{
                $f_i = t_a + C_i$; \\
                $h = \{h; (f_i, g_i )\}$;\\
                $t_a = t_a$;\\ 
                $g_f = g_f - g_i$; \\
                i++ ; // Next kernel \\ 
            }{
                $g_i = g_i - g_f$;\\
                $h = \{ h; (t_a+C_i, g_f) \}$;\\
                $[ t_a, \mathrm{index}] = \mathrm{min}( h[:,1] )$;\\
                $g_f = h[ \mathrm{index}, 2]$;\\
            }
        }
        \caption{Real time analysis algorithm }
        \label{alg:full}
    \end{algorithm} 
  \end{minipage}
\end{figure}


Our algorithm is based on three main updates: $h$, $t_a$ and $g_f$.
The set $h$ can be seen as an array of size Nx2, where $N$ is the number of tracked pairs.
For this reason, when $g_f > g_i$ we used MATLAB notation of `min` function `[value, index] = min(A)`, where `index` is the position of the pair or row $(t_k, g_k) \in h$ that has the minimun of all time values saved in $h$. 
Once we know which pair has the minimun time, we just assign $t_a = t_k$ and $g_f = g_k$.
It is important to mention again that by definition of $h$, all the tracked times should be greater or equal than the current $t_a$, meaning that pairs that have tracked times lower than $t_a$ must be removed. 

## Example 
Let's say there are four kernels we want to allocated, all with the same period $T = 15$ and block size of 512 threads, $b = 512$, which means $g_{max} = 8$.
The four tasks are defined as  $\tau = \{\tau_1 = \{15, 4, 2, 512\} , \tau_2 = \{15, 6,7,512\}, \tau_3 = \{15, 6,2,512\}, \tau_4 =\{ 15, 5,5,512\} \}$.

At the beginning $t_a =0$, $i=1$, $h=\{\}$ and $g_f = g_{max} = 8$. 
Let's start with $\tau_1$. 
Kernel $\tau_1$ and inital state of GPU are shown in Figure \ref{img:ex_1}(a) and Figure \ref{img:ex_1}(b) respectively.  

- $g_f \geq g_1$? yes, because $g_1 = 2$
- $f_1 = t_a + C_1 = 0 + 4 = 4$
- $h = \{h, (f_1, g_1)\} = \{ (4,2) \}$
- $t_a = 0$
- $g_f = g_f - g_i = 8 - 2 = 6$
- $i = 2$

After $\tau_1$ allocation the GPU state is as shown in Figure \ref{img:ex_1}(c), as it is observed, $t_a$ remains the same but $g_f$ now is 6. Furthermore, that is the initial GPU state when $\tau_2$ arrives.

![(a) Kernel $\tau_1$ (b)GPU state prior to $\tau_1$ allocation (c) GPU state after $\tau_1$ allocation \label{img:ex_1}](source/figures/ex_1.jpg)


Since $i=2$, it's time to analyze $\tau_2$.
Figure \ref{img:ex_2}(a) shows the number of blocks that should be allocated for $\tau_2$. 
It this case $t_a = 0$  and $g_f = 6$ as shown in Figure \ref{img:ex_2}(b). 
 
- $g_f \geq g_2$? no, because $g_i = 7$
- $g_2 = g_2 - g_f = 7-6 = 1$
- $h = \{h, (t_a + C_2, g_f)\} = \{ (4,2), (6,6) \}$
- $[ t_a, \mathrm{index} ] = \mathrm{min}(h[:,1]) = \mathrm{min}([4,6])$
- $[ t_a, \mathrm{index} ] = [4,1]$ 
- $g_f = h[ \mathrm{index},2] = h[1,2] = 2$
- $h = h - \{ (4,2) \} = \{ (4,2), (6,6) \} - \{ (4,2) \}$
- $h = \{(6,6)\}$ 

![(a) Kernel $\tau_2$ (b)GPU state prior to $\tau_2$ allocation (c) GPU state after $\tau_2$ allocation \label{img:ex_2}](source/figures/ex_2.jpg)

Values for $t_a$, $g_f$, $g_2$ and $h$ were updated. 
Notice that current value of $t_a$ is the completion time of $\tau_1$ and $g_f$ is $g_1$, that is why, as mention before, it is important to track $f_1$ and $g_1$.
However, completion time for $\tau_2$ is not known yet. Let's continue with the analysis. 


- $g_f \geq g_2$? yes, because $g_2 = 1$
- $f_2 = t_a + C_2 = 4 + 6 = 10$
- $h = \{h, (f_2, g_2)\} = \{ (6,6),(10,1) \}$
- $t_a = 4$
- $g_f = g_f - g_i = 2 - 1 = 1$
- $i = 3$


