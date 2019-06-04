# CUDA and Jetson TX2

<!--
After the introductory chapter, it seems fairly common to 
include a chapter that reviews the literature and 
introduces methodology used throughout the thesis.
-->
In this chapter...blablabla 



## NVIDIA GPU Software Model
Now a days computer applications run on heterogeneous hardware and GPUs are important in order to achieve high performance computing. 
Since 2006 running software on NVIDIA GPUs are known as a _CUDA application_ [@CUDAZONE2019].
A CUDA application will run concurrently multiple instances of special functions called **kernels**.Each instance runs on a **thread**. 
Moreover, these threads are arranged in **blocks**, and blocks compose **grids** as shown in Figure \ref{img:sw_model_grids}. 

![Organisation of grids, blocks, threads, and kernels [@CCUDA2010]. \label{img:sw_model_grids} ](source/figures/sw_model_grids.png){width=60%}

It's logical to think that there is also a hierarchical memory structure. 
Threads, blocks and grids have access to different memory spaces as ilustrated in Figure \ref{img:sw_model_memory}.
The types of memory are summarized in Table \ref{tab:memory_hierarchy}.

\newpage

---------------------------------------------------------------------------------------
Memory      Main Characteristics                            Scope   Lifetime
--------    -------------------                             -----   -----------
Global      R/W, Slow and big                               Grid    Application

Texture     ROM, Fast, Optimized for 2D/3D access           Grid    Application

Constant    ROM, Fast, Constants and kernel parameters      Grid    Application
 
Shared      R/W, Fast, it's on-chip                         Block   Block

Local       R/W, Slow as global, when registers are full    Thread  Thread

Registers   R/W, Fast                                       Thread  Thread

---------------------------------------------------------------------------

Table: Types of memories in a GPU \label{tab:memory_hierarchy}




![Memory hierarchy [@CCUDA2010]. \label{img:sw_model_memory} ](source/figures/sw_model_memory.png){width=60%}

In summary, CUDA application solve problems that were modeled based on _divide and conquer_ principle. Moreover, CUDA software model not only allow users to achieve high computational performance, but also CUDA application are highly scalable. 


## NVIDIA GPU Hardware Model
aeouae

## NVIDIA processors inside Jetson TX2

### NVIDIA Denver2
The other ARM cluster is composed of  two NVIDIA Denver2 cores and 2MB of L2 Cache.
Each NVIDIA Denver2 is a custom made 64-bit processing  based on ARMv8, which is optimized for  single-thread performance [@Denver2019url]. 

![Diagram of the Denver Cluster in TX2 \label{img:denver_arch} ](source/figures/denver_arch.png){width=100%}


This custom processor has two main characteristics. First, it has a 7-way superscalar microarchitecture.
It means that a Denver2 core can process 7 operations per clock cycle.
Secondly, it uses _Dynamic Code Optimization_. 
Frequently used software routines are converted into a dense and highly tunned equivalent microcode executable only by Denver2 cores. 
A Denver2 core analyze the ARM code just before execution and look for places where instructions can be handle together to maximize throughput taking in advantage the 7-way superscalar microarchitecture. 
In Figure \ref{img:denver_arch} can be observed that each Denver2 core has  64KB of L1 Data Cache, and  128KB of Instruction Cache. 
The optimized code is stored in the former one, also known as _Optimization Cache_ [@Denver2019url].


## Introduction

This is the introduction. Duis in neque felis. In hac habitasse platea dictumst. Cras eget rutrum elit. Pellentesque tristique venenatis pellentesque. Cras eu dignissim quam, vel sodales felis. Vestibulum efficitur justo a nibh cursus eleifend. Integer ultrices lorem at nunc efficitur lobortis.

## The middle

This is the literature review. Nullam quam odio, volutpat ac ornare quis, vestibulum nec nulla. Aenean nec dapibus in mL/min^-1^. Mathematical formula can be inserted using Latex:

$$f(x) = ax^3 + bx^2 + cx + d$$ {#eq:myeq}

Nunc eleifend, ex a luctus porttitor, felis ex suscipit tellus, ut sollicitudin sapien purus in libero. Nulla blandit eget urna vel tempus. Praesent fringilla dui sapien, sit amet egestas leo sollicitudin at.  

(@eq:myeq) Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Sed faucibus pulvinar volutpat. Ut semper fringilla erat non dapibus. Nunc vitae felis eget purus placerat finibus laoreet ut nibh.

## Conclusion

This is the conclusion. Donec pulvinar molestie urna eu faucibus. In tristique ut neque vel eleifend. Morbi ut massa vitae diam gravida iaculis. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

<!-- Insert an unordered list -->

- first item in the list
- second item in the list
- third item in the list

