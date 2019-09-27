# Experimental Results
In this chapter we presents our experimental results. 
We compare results from Jetson TX2 platfrom againts our Octave implementation. 
The former are used as ground truth to verify our implementation and assumptions.

## Ground truth generation
Amert et. al [@amert2017gpu] published their code in github. 
They developed a CUDA Scheduling Viewer, which is a tool for examining block-level scheduling behavior and co-scheduling performance on CUDA devices. 
The input are configuration files on the JSON format, and the output can be displayed as figure using a Python script, which is provided as well. 
An example output is shown in  Figure \ref{img:nvidia-base}   



Our test scenario was similar to the example presented in the last chapter. 
We had four kernels we wanted to allocate. 
The parameters were:  block size = 512 threads, and  $g_{max} = 8$.
The four kernels were defined as  $\tau = \{\tau_1 = \{15, 4, 2, 512\} , \tau_2 = \{15, 6,7,512\}, \tau_3 = \{15, 6,2,512\}, \tau_4 =\{ 15, 5,5,512\} \}$.

![Output of the CUDA Scheduling Viewer \label{img:nvidia-base}](source/figures/nvidia/base.png)

An example of a kernel description in the configuration file was  as follows: 

```json
      "filename": "./bin/timer_spin.so",
      "log_name": "k3.json",
      "label": "Kernel 3",
      "thread_count": 512,
      "block_count": 2,
      "additional_info": 6000000000
```

The `filename` is the benchmark binary file  we  used as a kernel. For all the kernels was  `timer_spin.so`.
This file defines a bare-bones CUDA benchmark which spins waiting for a user-specified amount of time to complete. 
The execution time in nanoseconds or $C_i$ was  set as `additional_info`. 
The `log_name` was the JSON file that contained  metadata and results related to a specfied kernel (`label`). 
In addition, `thread_count` and `block_count` were the values of $b_i$ and $g_i$ respectively.


## Implementation results
We implemented our algorithm in GNU Octave, a software for scientific programming similar to MATLAB but open source, because it was an easy way to test whether our algorithm was correct.
The goal was not to test how many kernel the Jetson could manage, instead we focused on verifying our assumptions and therefore our algorithm.

We set up three test scenarios. The four previously described kernels were launched in different order.
The first scenario was the one presented in Figure \ref{img:nvidia-base}. 
The kernels were launched on the following order: K2, K3, K4, K1. 
As showed in Figure \ref{img:nvidia-base} the completion times were $f = \{6, 12,11,10\}$. 
The results from Octave are shown in Figure \ref{img:octave-base}. 

![Octave: Scenario 1 - K2,K3,K4,K1 \label{img:octave-base}](source/figures/octave/base.png){width=100%}

In the second scenario kernels were launched on the following order: K2, K4, K1, K3. 
As observed in Figure \ref{img:nvidia-ex02} the completion times were $f = \{6,11,10,12\}$. 
Notice that *GPUSping: 5* for kernel 4 should be shown, but there is a bug in the code from [@amert2017gpu] in which sometimes the log file doesn't contain all the data. 
On the other hand, results from Octave are shown in Figure \ref{img:octave-ex02}. 
The block allocation differ from Jetson's allocation because our code follows our assumption described in section 3.3.2. 


![JetsonTX2: Scenario 2 - K2,K4,K1,K3 \label{img:nvidia-ex02}](source/figures/nvidia/ex02.png){width=100%}


![Octave: Scenario 2 - K2,K4,K1,K3 \label{img:octave-ex02}](source/figures/octave/ex02.png){width=100%}

In the third scenario kernels were launched on the following order: K2,  K1, K3, K4.
As observed in Figure \ref{img:nvidia-ex05} the completion times were $f = \{6,8,12,11\}$. 
Notice in this case  that *GPUSping:4* from kernel 4 and *GPUSping:1* from kernel 5 overlap in the figure. 
This is again an error on how the log file was created. 
We tested [@amert2017gpu] C implementation using `printf`, and the values were correct. 
Nevertheless, results from Octave shown in Figure \ref{img:octave-ex02}  remain congruent with the results of its counterpart. 

![JetsonTX2: Scenario 3 - K2,K1,K3,K4 \label{img:nvidia-ex05}](source/figures/nvidia/ex05.png){width=100%}


![Octave: Scenario 3 - K2,K1,K3,K4 \label{img:octave-ex05}](source/figures/octave/ex05.png){width=100%}


## More results 
In this section we present more results. 
We focused in this section on the interaction between kernels with several blocks, and kernels with long execution time.

In Figure \ref{img:nvidia-ex06} can be observed the result after executing five kernels. 
The kernels were  defined as follows:

- $\tau_1 = \{15,4,2,512\}$: small block count, short execution time.
- $\tau_2 = \{15, 7,1,512\}$: big block count, short execution time.
- $\tau_3 = \{15,10,4,512\}$:  big block count, long execution time.
- $\tau_4 =\{ 15, 1,11,512\}$: small block count, very long execution time.
- $\tau_5 = \{15,3,6,512\}$: big block count, medium execution time. 

Our result shown in Figure \ref{img:octave-ex06} is still consistent with the ground truth. We obtained the same completion time for each kernel. 

![JetsonTX2  \label{img:nvidia-ex06}](source/figures/nvidia/ex06.png){width=100%}


![Octave \label{img:octave-ex06}](source/figures/octave/ex06.png){width=100%}


In this experiment the setup was as follows:

- $\tau_1 = \{15,5,1.5,512\}$: small block count, small execution time.
- $\tau_2 = \{15,4,1.5,512\}$: small block count, small execution time.
- $\tau_3 = \{15,7,1.5,512\}$: big block count, small execution time.
- $\tau_4 =\{ 15, 1,4,512\}$: very small block count, big execution time.
- $\tau_5 = \{15,8,2.5,512\}$: big block count, large execution time.

As expected completion times shown in Figure \ref{img:nvidia-ex07} and Figure \ref{img:octave-ex07} are the same for each kernel. 

![JetsonTX2 \label{img:nvidia-ex07}](source/figures/nvidia/ex07.png){width=100%}


![Octave \label{img:octave-ex07}](source/figures/octave/ex07.png){width=100%}

## APP4MC Implementation
A complete example using AMALTHEA models can be found in the Appendix 1.
We tested our java implementation against Octave implementation. 
The data set was generated randomly, using block counts between 2 and 100, and execution times between 10 and 20. 
In Figure \ref{img:java_octave} can be found the relative error between both implementation. 
The error is 

![Octave \label{img:java_octave}](source/figures/octave/ex07.png){width=100%}

