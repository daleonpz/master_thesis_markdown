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

## Calculation of response time 
In addition to the variables defined in our assumptions we define $g_{free}$ as the number of blocks that are available at some point in time $t$, and $t_a$ as the point in time in which a block $b_i \in g_i$ can be allocated. 

