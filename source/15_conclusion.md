# Conclusion

<!-- 
A chapter that concludes the thesis by summarising the learning points
and outlining future areas for research
-->

## Thesis summary
We gave an overview in Chapter 1 of the motivation of this work, the  Bosch WATERS Challenge 2019, explained the architecture of NVIDIA Jetson TX2 platform and its AMALTHEA model. 
Furthermore, in Chapter 2 we introduced key concepts related to NVIDIA's GPU such as kernel definition, block  and threads, as well as its memory hierarchy. 
We described in detail Jetson TX2 hardware architecture, and explained the rules behind hardware scheduler.
In Chapter 3 we introduced our real time analysis algorithm for Jetson TX2's scheduler. In addition we gave some examples to explain in detail  each step.
Finally in Chapter 4 we showed our experimental results. 

## Conclusions 
It has been proved that for purposes of mathematical calculation, the main assumption, due to all blocks have the same thread count we considered all GPU streaming multiprocessors as one big streaming multiprocessor, was correct. 
Our experimental results show the accuracy of our algorithm to estimate completion times for kernels executed on Jetson TX2 platform. 
Moreover, we implemented our algorithm on Eclipse APP4MC, which allows AMALTHEA based response time analysis for NVIDIA's Jetson TX2. 


## Future work

There are several potential directions for extending this thesis. 
First, the possibility to develop a complete model-based development for NVDIA platform using AMALTHEA models, which may include automatic CUDA C code generation for deployment and testing.
Second, there is still no full understanding of how  Jetson TX2's scheduler decides which kernel should run first. 
Thus, developers should either  consider all possible cases when analyzing completion times or reverse engineering Jetson TX2's scheduler.
Finally, we didn't consider memory transaction and other constrains such as amount of shared memory, influence of the _null_ stream  and priorities within scheduler. 
Therefore, there is still room to go deeper into this topic.

