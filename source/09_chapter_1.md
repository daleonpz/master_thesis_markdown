# Introduction

## Motivation
Car manufactures want to reduce cost in terms of money and time required to develop, test and validate  a new piece of software due to a change of supplier. 
For that reason, centralized end-to-end architectures are the solution they are aiming to, because for car companies such as BWW and Audi the car of future will be similar to a "data center on wheels" [@Hansen2019]. 

Centralized end-to-end architectures would be the first step stone toward to decoupling software and hardware [@Future2019].
This type of architectures not only will take advantage of  internet connectivity, cloud computing and powerful heterogeneous processing units, but also will allow scalable, hierarchical and highly integrated system.

In other words, car manufactures prefer now a days low-latency, hierarchical and cost effectiveness of centralized end-to-end architectures, because today requirements of computational power,  bandwidth, integration, safety and real-time [@Kanajan2006]. 

However, car manufactures don't forget that at the end, in centralized end-to-end architectures, different types of software would run on top of an heterogeneous hardware supplied by companies such as NVIDIA, Mobileye or Qualcomm.
Thus, it's important to analyze and understand how software will behave under those conditions, in order to ensure a predictable and efficient system. 


## Industrial challenge WATERS 2019 
Predictability is a key property for safety-critical and hard real-time systems [@Henzinger2008].
Analyzing time related characteristics is an important step to design predictable embedded systems.
However, in multi-core or heterogeneous systems based on centralized end-to-end architectures is harder to satisfy timing constrains due to scheduling, caches, pipelines, out-of-order executions, and different kinds of speculation [@Cullmann2010].
Thus, development of timing-analysis methods for these types of architectures has become, nowadays, one of the main focus of research in both industry and academic environment. 

Robert Bosch GmbH or Bosch,  the German multinational engineering and electronics company, and one of the top leaders in development technology for the automotive industry announces every year _the WATERS Challenge_. 
The purpose of the WATERS industrial challenge is to share ideas, experiences and solutions to concrete timing verification problems issued from real industrial case studies [@Water2019Url].

This year, 2019, the challenge focuses on timing-analysis for heterogeneous software-hardware systems based on centralized end-to-end architectures.
The platform chosen for this purpose is the NVIDIA® Jetson™ TX2 platform which has an heterogeneous architecture equipped with a Quad ARM A57 processor, a  Dual  Denver  processor,  8GB  of  LPDDR4  memory  and 256  CUDA  cores  of  NVIDIA’s  Pascal  Architecture.
For the challenge it is available an Amalthea model for this platform to design a solution, and test it later on real hardware. 

## NVIDIA Jetson TX2: Architecture Overview
NVIDIA Jetson TX2 is an embedded system-on-module (SOM). It is ideal for deploying advanced AI to remote field locations with poor or expensive internet connectivity,  Robotics, Gaming Devices, Virtual Reality (VR), Augmented Reality (AR) and Portable Medical Devices.
In addition, it offers near-real-time responsiveness and minimal latency—key for intelligent machines that need mission-critical autonomy [@TX2Intro2017].

The main components of the Jetson TX2 are dual-core ARMv8 based NVIDIA Denver2,  quad-core ARMv8 Cortex-A57, 8GB 128-bit LPDDR4 and integrated 256-core Pascal NVIDIA GPU.
The quad-core Cortex-A57 and dual-core NVIDIA Denver2 can be seen as a cluster of heterogeneous multiprocessors (HMP) [@TX2Datasheet2014].
Both HMP and GPU shares a 8GB SRAM memory as shown in Figure \ref{img:overview_arch}. 
Hereafter, whenever we use the term **host**, we will refer to HMP, similarly we will use **device** to refer to GPU.
 
![Jetson TX2 Architecture Overview \label{img:overview_arch} ](source/figures/overview_arch.png){width=100%}



Any NVIDIA GPU has two types of engines, **Copy Engines** (CE)  and **Execution Engines** (EE). 
The Jetson TX2 has only one CE and two EE also known as **Streaming multiprocessors**.
CE is in charge of data transfers from host to device and viceversa. 
There is, moreover, the possibility that EE and CE can run concurrently. 

The GPU uses **streams** to run applications. 
The number of streams depends on the GPU resources. 
An application can run in one or multiple streams, the GPU scheduler, by default, manages how to application will be allocated on streams in order to maximize throughput. 
In Chapter 2, we will discuss in more detail how the TX2 GPU scheduler behave in case of multiple applications. 

## Jetson TX2 Amalthea Model
AMALTHEA is a platform for engineering multi- and many-core  embedded systems. 
This platform enables the creation and management of complex tool chains including simulation and validation [@Amalthea2019].
In the context of WATERS Challenge 2019, Bosch offers an AMALTHEA model of the Jetson TX2.
In this model, a CPU runnable will read data from memory, execute some computation (Ticks)  and write back data into memory  as shown in Figure \ref{img:amalthea01}.


![Runnable example for a CPU [@Water2019Url] \label{img:amalthea01}](source/figures/amalthea-01.png)

In the case of GPU modeling, the runnable will follow the same pattern as in the CPU case: read, execution, write back.
However, the reading operation is actually to copy memory from host to device, thus it is modelled as _memory reading from host_ and then as  _memory writing to device_.
On the other hand, the writing back operation requires to copy memory from device to host, therefore it  is modelled as _memory reading from device_ and then as _memory writing to host_ as shown in Figure \ref{img:amalthea02}.

![Runnable example for a GPU [@Water2019Url] \label{img:amalthea02}](source/figures/amalthea-02.png)


