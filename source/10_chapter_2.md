# CUDA and Jetson TX2

<!--
After the introductory chapter, it seems fairly common to 
include a chapter that reviews the literature and 
introduces methodology used throughout the thesis.
-->
In this chapter we give an overview of the theorical background of  NVIDIA GPU software and hardware model. We introduce the concepts of threads, blocks, kernels and streaming multriprocesor, and how they apply to our study case.
We discuss abour Jetson TX2's memory hierarchy and scheduler. In addition, we describe the rules behind the Jetson TX2's hardware scheduler with an example. 

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
The CUDA architecture is based on **Streaming Multiprocessors** (SM) which perform the actual computation.
Each SM has it own control units, registers, execution pipelines and local memories, but they also have access to global memory as ilustrated in Figure \ref{img:sm_memory}.
A **stream** is a queue of CUDA operations, memory copy and kernel launch.
We will talk more about streams in following sections.

![Memory hierarchy  \label{img:sm_memory} ](source/figures/sm_memory.png){width=60%}


When a kernel grid is launch blocks are enumerated and assigend to the SMs. 
Once the blocks are assigned, threads are managed in **wraps** by the **wrap scheduler**. A wraps is a group of 32 threads that run in parallel. 
Thus, it's highly recommendable to use block sizes of size $32N, N \in \mathbb{N}$, otherwise there would be "inactive" threads.
A example is shown in Figure \ref{img:inactive_thread}, where there is a block of 140 threads but since the wrap scheduler works with wraps, 20 threads are wasted and no other block can make use of them. 


 
![Inactive threads \label{img:inactive_thread} ](source/figures/inactive_thread.png){width=60%}




The amount of  threads and blocks that can run concurrently per SM depends on the number of 32-bit registers and shared memory within SM, as well as the CUDA computing capability of the GPU. Information related to maximum amount of blocks  or threads, as well as the computing capability of the GPU can be display executing `deviceQuery` tool. 
Some information about Jetson TX2 is presented below: 

```sh
CUDA Device Query (Runtime API) version (CUDART static linking)
Detected 1 CUDA Capable device(s)
Device 0: "NVIDIA Tegra X2"
  CUDA Driver Version / Runtime Version     9.0 / 9.0
  CUDA Capability:                          6.2
  Total amount of global memory:            7850 MBytes 
  ( 2) SM, (128) CUDA Cores/SM:             256 CUDA Cores
  L2 Cache Size:                            524288 bytes
  Total amount of shared memory per block:  49152 bytes
  Total number of registers per block:      32768
  Warp size:                                32
  Max. number of threads per SM:            2048
  Max. number of threads per block:         1024
  Max dim. size of a thread block (x,y,z):  (1024, 1024, 64)
  Max dim. size of a grid size    (x,y,z):  (2^31-1, 65535, 65535)
```

## NVIDIA Jetson TX2's GPU Scheduler
It's common to use several kernels in an application.
In order to reduce computation time and maximaze GPU utilization, it's desire to run multiple kernels in parallel. 
CUDA uses streams to achieve this goal. 
As mentioned before, a stream is a queue of CUDA operations, memory copy and kernel launch.
Thus, it  is possible either to launch multiple kernels within one streams or multiple kernels on multiple streams. 
Operations within the same stream are managed in FIFO (First In First Out) fashion, thus, we will also use the term **stream queue** when we talk about FIFO queues within a stream.
The Jeston TX2's GPU assigns resources to streams using its internal scheduler.

Predictability is an important characteristic of safety-critical systems. It requires both functional and timing correctness.
However, a detailed information about the Jetson TX2's GPU scheduler behaviour is not publicly available. 
Without such details, it is imposible to analyze timing constrains. 
Nevertheless, there are some efforts [@amert2017gpu], [@yang2018] and [@bakita2018scaling] aimed at revealing these details through black-box experimentation.

NVIDIA GPU scheduling policies depend on whether the GPU workloads are launched by a CPU executing OS threads or OS processes. 
We will focus on the first case, because GPU computations launched by OS processes have more unpredictable behaviours, as stated in [@amert2017gpu] and [@yang2018]. 
In this section, we will present GPU scheduling policies devired by [@amert2017gpu] and use them in an example to clarify their use. 

Let's start by defining some terms. When one block of a kernel has been scheduled for execution on a SM it's said that the block was **assigned**. Moreover, it's said a kernel was **dispatched** as soon as one of its blocks were assigned, and **fully dispatched** once all its blocks were assigned. 
The same applies to copy operations and CE.  
There are, in addition, FIFO CE queues used to schedule copy operations, and FIFO EE queues used to schedule kernel launches.
Stream queues feed CE and EE queues. Bellow we will present the rules that determine scheduler and queues behaviours.

* **General Scheduling Rules**:
    * **G1** A copy operation or kernel is enqueued on the stream queue for its stream when the associated CUDA API function (memory transfer or kernel launch) is invoked.
    * **G2** A kernel is enqueued on the EE queue when it reaches the head of its stream queue.
    * **G3** A kernel at the head of the EE queue is dequeued from that queue once it becomes fully dispatched.
    * **G4** A kernel is dequeued from its stream queue once all of its blocks complete execution.

* **Non-preemptive execution**:
    * **X1** Only blocks of the kernel at the head of the EE queue are eligible to be assigned.

* **Rules governing thread resources**:
    * **R1** A block of the kernel at the head of the EE queue is eligible to be assigned only if its resource constraints are met.
    * **R2** A block of the kernel at the head of the EE queue is eligible to be assigned only if there are sufficient thread resources available on some SM.

* **Rules governing shared-memory resources**:
    * **R3** A block of the kernel at the head of the EE queue is eligible to be assigned only if there are sufficient shared-memory resources available on some SM.

* **Copy operations**:
    * **C1** A copy operation is enqueued on the CE queue when it reaches the head of its stream queue.
    * **C2** A copy operation at the head of the CE queue is eligible to be assigned to the CE.
    * **C3** A copy operation at the head of the CE queue is dequeued from the CE queue once the copy is
    * **C4** A copy operation is dequeued from its stream queue once the CE has completed the copy.

* **Streams with priorities**:
    * **A1** A kernel can only be enqueued on the EE queue matching the priority of its stream.
    * **A2** A block of a kernel at the head of any EE queue is eligible to be assigned only if all higher-priority EE queues (priority-high over priority-low) are empty.

Authors in [@amert2017gpu] mentioned that rules related to **registry resources** are expected to have exactly the same impact as threads and shared-memory rules. 


![Basic GPU scheduling experiment [@amert2017gpu] \label{img:scheduler_blocks} ](source/figures/scheduler_blocks.png){width=60%}

![Detailed state information at various time points in Fig. \ref{img:scheduler_blocks} [@amert2017gpu] .\label{img:scheduler_queues} ](source/figures/scheduler_queues.png){width=100%}


\newpage

