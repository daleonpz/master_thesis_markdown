# Experimental Results

## Ground truth generation
Amert et. al [@amert2017gpu] published their code in github. 
They developed a CUDA Scheduling Viewer, which is a tool for examining block-level scheduling behavior and co-scheduling performance on CUDA devices. 
The input are configuration files on the JSON format, and the output can be displayed as figure using a Python script, which is provided as well. 
An example output is shown in  Figure \ref{img:nvidia-base}   


![Output of the CUDA Scheduling Viewer \label{img:nvidia-base}](source/figures/nvidia/base.png)

Our test scenario was similar to the example presented in the last chapter. 
We had four kernels we wanted to allocate. 
The parameters were:  block size = 512 threads, and  $g_{max} = 8$.
The four kernels were defined as  $\tau = \{\tau_1 = \{15, 4, 2, 512\} , \tau_2 = \{15, 6,7,512\}, \tau_3 = \{15, 6,2,512\}, \tau_4 =\{ 15, 5,5,512\} \}$.

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
We implement our algorithm in GNU Octave, a software for scientific programming similar to MATLAB but open source, because it was an easy way to test whether our algorithm was correct.

The first scenario was the one presented in Figure {ref:nvidia-base}. 
The kernels were launched on the following order: K2, K3, K4, K1. 
As it showed in Figure \ref{img:nvidia-base} the completion times were $f = \{8, 12,11,10\}. 
The results in Octave are shown in Figure \ref{img:octave-base}. 

![Scenario 1 \label{img:octave-base}](source/figures/octave/base.png)




