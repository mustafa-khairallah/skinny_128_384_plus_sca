# Skinny-128-384+ SCA-Oriented RTL Implementations
A collection of my implementations of different countermeasures against the SKINNY-128-384+ tweakable block cipher, part of the the NIT lightweight cryptography standardazation finalist: Romulus.

This  page is under-construction with details about Skinny, Romulus and the implementations to follow.

## Available SBox8 Implementations:

### Unprotected

1. LUT (src_rtl/sbox8/golden_unprotected/skinny_sbox8_lut.v).
2. Logic (src_rtl/sbox8/logic_unprotected/skinny_sbox8_logic.v).
3. High-Speed Logic (src_rtl/sbox8/logic_unprotected/skinny_sbox8_hs.v).

### Domain-Oriented Masking

1. DOM1 indep. 4 cycles non-pipelined (src_rtl/sbox8/dom/dom1/skinny_sbox8_dom1_non_pipelined.v).
2. DOM1 indep. 4 Cycles non-pipelined with less FFs (src_rtl/sbox8/dom/dom1/skinny_sbox8_dom1_less_reg_non_pipelined.v).
3. DOM1 indep. 2 Cycles non-pipelined (src_rtl/sbox8/dom/dom1/skinny_sbox8_dom1_rapid_non_pipelined.v).
4. DOM1-SNI indep. 8 cycles non-pipelined (src_rtl/sbox8/dom/dom1/skinny_sbox8_dom1_sni_non_pipelined.v).
5. DOMD indep. 4 Cycles non-pipelined (src_rtl/sbox8/dom/domd/skinny_sbox8_domd_non_pipelined.v).

### Consolidated Masking Scheme

1. CMS1 4 cycles non-pipelined (src_rtl/sbox8/cms/cms1/skinny_sbox8_cms1_non_pipelined.v).
2. CMS1 2 cycles non-pipelined (src_rtl/sbox8/cms/cms1/skinny_sbox8_cms1_rapid_non_pipelined.v).

### Modified ISW Masking (Private Circuits)

1. ISW1 8 Cycles non-pipelined (src_rtl/sbox8/isw/isw1/skinny_sbox8_isw1_non_pipelined.v).
2. ISW1 4 Cycles with last register in the gadget bypassed non-pipelined (src_rtl/sbox8/isw/isw1/skinny_sbox8_isw1_bypass_non_pipelined.v).
3. ISW1 12 Cycles PINI-secure for d <= 1 non-pipelined (src_rtl/sbox8/isw/isw1/skinny_sbox8_isw1_pini_non_pipelined.v).

### Hardware Private Circuits 2 (HPC2)

1. HPC2-1 8 Cycles non-piplined (src_rtl/sbox8/hpc2/hpc2_1/skinny_sbox8_hpc2_1_non_pipelined.v).
2. HPC2-1 12 Cycles strengthened non-piplined (src_rtl/sbox8/hpc2/hpc2_1/skinny_sbox8_hpc2_1_str_non_pipelined.v).

### Threshold Implementation

1. TI-2 4 Cycles 3-share non-pipelined (src_rtl/sbox8/ti/ti2skinny_sbox8_ti2_non_pipelined.v).
2. TI-2 1 Cycle  3-share non-pipelined (src_rtl/sbox8/ti/ti2skinny_sbox8_ti2_nr_non_pipelined.v).
3. TI-2 4 Cycles 3-share with resharing non-pipelined (src_rtl/sbox8/ti/ti2skinny_sbox8_ti2_reshare_non_pipelined.v).

### PARA (Parallel Masking Algorithms)

1. PARA1 8 Cycles (src_rtl/sbox8/para/para1/skinny_sbox8_para1_non_pipelined.v).

---------------------------------
## SILVER Results for SBox8 Implementations

|Version       |Cycles|Possible Probes|Randomness per SBox|Max. Rand. per Cycle|Probing|NI |SNI|PINI|Uniformity|
|--------------|------|---------------|-------------------|--------------------|-------|---|---|----|----------|
|DOM1          |4     |168            |8                  |3                   |+      |yes|yes|no  |yes       |
|DOM1-LR       |4     |152            |8                  |3                   |yes    |yes|yes|no  |yes       |
|DOM1-Rapid    |2     |372            |25                 |19                  |?      |?  |?  |?   |?         |
|DOM1-SNI      |8     |184            |8                  |3                   |+      |+  |+  |no  |yes       |
|CMS1          |4     |240            |32                 |12                  |+      |+  |yes|no  |yes       |
|CMS1-Rapid    |2     |531            |76                 |56                  |?      |?  |?  |?   |?         |
|ISW1          |8     |184            |8                  |3                   |+      |+  |+  |no  |yes       |
|ISW1-BP       |4     |168            |8                  |3                   |yes    |yes|yes|no  |yes       |
|ISW1-PINI     |12    |224            |16                 |6                   |+      |+  |+  |+   |yes       |
|HPC2-1        |12    |256            |8                  |3                   |+      |+  |+  |yes |yes       |
|HPC2-1 Strong |12    |272            |16                 |6                   |+      |+  |yes|+   |yes       |
|TI-2          |4     |280            |0                  |0                   |+      |no |no |no  |yes       |
|TI-2-NR       |1     |256            |0                  |0                   |yes    |no |no |no  |yes       |
|TI-2-Reshare  |4     |352            |23                 |9                   |?      |?  |?  |?   |?         |
|TI-2-Rapid    |2     |?              |0                  |0                   |?      |?  |?  |?   |?         |
|PARA1         |8     |192            |16                 |6                   |+      |+  |+  |no  |yes       |

---------------------------------
## SILVER Results for Auxiliary Gate Built for This Repository

|GATE          |Cycles|Possible Probes|Randomness per Fn. |Max. Rand. per Cycle|Probing|NI |SNI|PINI|Uniformity|
|--------------|------|---------------|-------------------|--------------------|-------|---|---|----|----------|
|AND3-DOM1     |1     |43             |3                  |3                   |+      |+  |yes|no  |yes       |
|AND4-DOM1     |1     |89             |7                  |7                   |+      |+  |yes|no  |yes       |
|A3-DOM1       |1     |186            |14                 |14                  |+      |+  |yes|no  |yes       |
|A4-DOM1       |1     |40             |2                  |2                   |+      |+  |yes|no  |yes       |
|A7-DOM1       |1     |64             |4                  |4                   |+      |+  |yes|no  |yes       |
|AND3-CMS1     |1     |58             |8                  |8                   |+      |+  |+  |no  |yes       |
|AND4-CMS1     |1     |116            |16                 |16                  |+      |+  |+  |no  |yes       |
|A3-CMS1       |1     |252            |36                 |36                  |+      |+  |yes|no  |yes       |
|A4-CMS1       |1     |58             |8                  |8                   |+      |+  |yes|no  |yes       |
|A7-CMS1       |1     |88             |12                 |12                  |+      |+  |yes|no  |yes       |
|AND3-TI2      |1     |72             |5                  |5                   |+      |no |no |no  |yes       |
|AND4-TI2      |1     |182            |9                  |9                   |+      |no |no |no  |yes       |

*Ai is the output (i+1)^th XOR in the Skinny Sbox8 circuit, counted left-to-right, top-to-down.

---------------------------------


