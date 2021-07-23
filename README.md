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
4. DOMD indep. 4 Cycles non-pipelined (src_rtl/sbox8/dom/domd/skinny_sbox8_domd_non_pipelined.v).

### ISW Masking

1. ISW1 8 Cycles non-pipelined (src_rtl/sbox8/isw/isw1/skinny_sbox8_isw1_non_pipelined.v).
2. ISW1 4 Cycles with last register in the gadget bypassed non-pipelined (src_rtl/sbox8/isw/isw1/skinny_sbox8_isw1_bypass_non_pipelined.v).
3. ISW1 12 Cycles PINI-secure for d $leq$ 1 non-pipelined (src_rtl/sbox8/isw/isw1/skinny_sbox8_isw1_pini_non_pipelined.v).
