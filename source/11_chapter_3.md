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


### Subsection 1 with example code block

This is the first part of the methodology. Cras porta dui a dolor tincidunt placerat. Cras scelerisque sem et malesuada vestibulum. Vivamus faucibus ligula ac sodales consectetur. Aliquam vel tristique nisl. Aliquam erat volutpat. Pellentesque iaculis enim sit amet posuere facilisis. Integer egestas quam sit amet nunc maximus, id bibendum ex blandit.

For syntax highlighting in code blocks, add three "`" characters before and after a code block:

```python
mood = 'happy'
if mood == 'happy':
    print("I am a happy robot")
```

Alternatively, you can also use LaTeX to create a code block as shown in the Java example below:
\lstinputlisting[style=javaCodeStyle, caption=Main.java]{source/code/HelloWorld.java}

If you use `javaCodeStyle` as defined in the `preamble.tex`, it is best to keep the maximum line length in the source code at 80 characters.

### Subsection 2

This is the second part of the methodology. Proin tincidunt odio non sem mollis tristique. Fusce pharetra accumsan volutpat. In nec mauris vel orci rutrum dapibus nec ac nibh. Praesent malesuada sagittis nulla, eget commodo mauris ultricies eget. Suspendisse iaculis finibus ligula.

<!-- 
Comments can be added like this.
--> 

## Results

These are the results. Ut accumsan tempus aliquam. Sed massa ex, egestas non libero id, imperdiet scelerisque augue. Duis rutrum ultrices arcu et ultricies. Proin vel elit eu magna mattis vehicula. Sed ex erat, fringilla vel feugiat ut, fringilla non diam.

## Discussion

This is the discussion. Duis ultrices tempor sem vitae convallis. Pellentesque lobortis risus ac nisi varius bibendum. Phasellus volutpat aliquam varius. Mauris vitae neque quis libero volutpat finibus. Nunc diam metus, imperdiet vitae leo sed, varius posuere orci.

## Conclusion

This is the conclusion to the chapter. Praesent bibendum urna orci, a venenatis tellus venenatis at. Etiam ornare, est sed lacinia elementum, lectus diam tempor leo, sit amet elementum ex elit id ex. Ut ac viverra turpis. Quisque in nisl auctor, ornare dui ac, consequat tellus.

