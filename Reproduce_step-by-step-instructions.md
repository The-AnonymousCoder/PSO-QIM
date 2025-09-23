This document outlines the necessary steps to reproduce the results from the paper, including Figures 11-15, Tables 2-6. 
The instructions below guide you through each experiment, starting from data preparation to running the provided MATLAB scripts.

Step-by-Step Reproduction Instructions

Fig. 11. The Negative Probability improvement effects of PSO
  Run the sdwt_embed_pso.m file to embed the watermark using PSO.
  The output will display the negative probability effects of PSO, which you can use for Figure 11.

Fig. 12. Robustness improvement through watermark correction
  Instructions:
  Run the Full_Process_Test_With_Attacks.m file to conduct the robustness tests under different attack scenarios.
  The output will show how watermark correction improves robustness, which corresponds to the visual results in Figure 12.

Table 2. Comparison of the average movement of different methods
  Instructions:
  Run the SuperError.m file to generate the results for Table 2.
  The output will include the comparison of average movements between the methods, which will be used in Table 2.

Fig. 13. Vertex deletion attack results tested on the experimental data
  Purpose: To evaluate the results of vertex deletion attacks on watermarked data.
  Instructions:
  Run the Fig13.m script to simulate and test vertex deletion attacks.
  The output will display the results of these attacks on the experimental data, which corresponds to Figure 13.

Table 3. The NC values under vertex addition attacks of all algorithms
  Instructions:
  Run the Table3.m file to calculate the NC values for each algorithm under vertex addition attacks.
  The output will provide the NC values for each method, which will be used to populate Table 3.

Table 4. The NC values under noise attacks of all algorithms
  Instructions:
  Run the Table4.m file to calculate the NC values under noise attacks for each algorithm.
  The output will present the NC values for each method, corresponding to Table 4.

Fig. 14. Experimental results of object deletion attacks
  Instructions:
  Run the Fig14.m script to simulate and test object deletion attacks.
  The output will display the experimental results of object deletion attacks, which will be used for Figure 14.

Table 5. The experimental results of cropping attacks
  Instructions:
  Run the Table5.m file to generate the experimental results of cropping attacks.
  The output will provide the data needed for Table 5, detailing the effects of cropping attacks.

Fig. 15. Experimental results of geometric attacks
  Instructions:
  Run the Fig15.m script to simulate geometric attacks on the watermarked data.
  The output will show the results of these geometric attacks, which will be presented in Figure 15.

Table 6. The experimental results of compound attacks
  Instructions:
  Run the Table6.m file to conduct tests on compound attacks and gather experimental results.
  The output will present the results of compound attacks, which will be used to populate Table 6.

