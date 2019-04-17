This directory contains a set of examples from the book
"Guide to FPGA Implementation of Arithmetic Function"
by Jean-Pierre Deschamps, Gustavo D. Sutter and Enrique Cantó.

http://www.arithmetic-circuits.org/guide2fpga/vhdl_codes.htm


VHDL Models and Examples
~~~~~~~~~~~~~~~~~~~~~~~~


Chapter 2: Architecture of Digital Circuits
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Introductory example 2.1 (square_root.vhd). A simple test bench
(square_root_tb.vhd). Algorithm 2.2, square root, version 2
(square_root_2.vhd). A simple test bench square_root_2_tb.vhd).

Introductory example 2.3.1. A 7-to-3 Counter
(seven_to_three.vhd). A simple test bench
(seven_to_three_tb.vhd). It uses a basic carry save adder (CSA)
(csa.vhd). A simple test bench (csa_tb.vhd).

Final example of Elliptic curve scalar product. First using
explicit datapath and control separation (scalar_product.vhd
and scalar_product_data_path.vhd); and a second implementation
not using explicit datapath and control separation
(scalar_product_DF2.vhd). Both implementation uses the
multiplier and squarer (interleaved_mult.vhd;
classic_squarer.vhd).


Chapter 3: Special Topics of Data Path Synthesis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Section 3.1.2 Segmentation. scalar product in GF(2^m) using
pipeline (not a synthesizable circuit) (pipeline_DF2.vhd).

Section 3.1.4 Interconection of pipelined component. Example
3.4 of scalar product in GF(2^m) using self timed pipeline (not
a synthesizable circuit) (pipeline_ST.vhd). A simple test bench
(test_pipeline_ST.vhd). Example 3.5 a self timed ripple carry
adder (adder_ST2.vhd). A test bench for ripple carry adder
(test_adder_ST2.vhd).

Section 3.2 Loop unrolling and digit-serial computation. A
sequential restoring division algorithm (restoring.vhd). The
partially unrolled version of the restoring divider with s=2
(unrolled_divider.vhd). A Digit Serial version of the restoring
algorithm with D=2 (restoringDS.vhd).


Chapter 4: Special Topics of Control Unit Synthesis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Section 4.2 hierarchical control unit. Example 4.2 computes z=
(x^2 + y^2)^0.5 (example4_1.vhd).

Section 4.3 variable latency operations. A scalar product in
GF(2^m) example (not a synthesizable circuit)
(unbounded_DF.vhd).


Chapter 7: Adders
~~~~~~~~~~~~~~~~~
Section 7.3 radix 2^k adder. A behavioral model
(base_2k_adder.vhd), instantiating muxcy component
(base_2k_adder_muxcy.vhd). A test bench for base 2^k adders
(test_base_2k_adder.vhd).

Section 7.4 carry select adders (carry_select_adder.vhd and
carry_select_adder2.vhd). A test bench for carry select adders
(test_carry_select_adder.vhd).

Section 7.5 logarithmic adder. Example 7.1
(carry_select_adder3.vhd, uses also carry_select_adder2.vhd as
component).

Section 7.6 long-operand adder (long_operand_adder.vhd). A test
bench for sequential adders (test_long_operand_adder.vhd).

Section 7.7 multioperand adders:

Section 7.7.1 Sequential multi-operand adder
(multioperand_adder.vhd). Multi-operand addition with
stored-carry encoding (CSA_multioperand_adder.vhd). A test
bench for sequential multi-operand adders
(test_multioperand_adder_seq.vhd).

Section 7.7.2 combination multi-operand adders. Combinational
multi-opernad adder (comb_multioperand_adder.vhd).
Combinational multi-operand addition with stored-carry encoding
(comb_CSA_multioperand_adder.vhd). A test bench for sequential
multioperand adders (test_multioperand_adder_comb.vhd).eight
operand adder (eight_operand_adder.vhd).

Section 7.7.3 parallel counters. Six to three counter
(six_to_three_counter.vhd), a 6 to 3 counter instantiating lut6
component (six_to_three_counter_compinst.vhd). Twenty four
operand adder (twenty_four_operand_adder.vhd). A test bench for
24-operand adder (test_twenty_four_operand_adder.vhd).

Section 7.8 Subtractor and adder subtractor
(two_s_comp_adder.vhd; two_s_comp_subtractor.vhd).


Chapter 8: Multipliers
~~~~~~~~~~~~~~~~~~~~~~
Section 8.2 combinational multipliers:

Section 8.2.1 Ripple carry parallel multiplier
(parallel_multiplier.vhd). A testbench for parallel multipliers
(test_parallel_multiplier.vhd).

Section 8.2.2 carry-save parallel multiplier
(parallel_csa_multiplier.vhd). A testbench for parallel
multipliers (test_parallel_multiplier.vhd).

Section 8.2.3 Multipliers based on multioperand adders. n-bit
by 7-bit multiplier based on multi-operand adders
(N_by_7_multiplier.vhd; uses also seven_to_three.vhd and
csa.vhd). A test bench for Nx7 bits multipler
(test_N_by_7_multiplier.vhd).

Section 8.2.4 radix-2^k and mixed radix multipliers. A radix
2^k multiplier (base_2k_parallel_multiplier.vhd). A radix 2^k
using CSA (base_2k_csa_multiplier.vhd). A test bench for radix
2^k (test_base_2k_parallel_multiplier.vhd).

Section 8.3 sequential multipliers:

Section 8.3.1 Shift and add multipliers
(shift_and_add_multiplier.vhd and
shift_and_add_multiplier2.vhd). The test bench for the shift
and add multipliers (test_shift_and_add_multiplier.vhd and
test_shift_and_add_multiplier2.vhd).

Section 8.3.2 Shift and add multipliers with CSA
(sequential_CSA_multiplier.vhd). The test bench for the shift
and add multipliers (test_shift_and_add_multiplier_CSA.vhd).

Section 8.4 Integer multipliers:

Section 8.4.1 mod 2.B^(m+n) multiplication
(integer_csa_multiplier.vhd). The test bench for for mod
2.B^(m+n) multiplication (test_integer_CSA_multiplier.vhd).

Section 8.4.2 modified parallel shift and add algorithm
(modified_parallel_multiplier.vhd). The test bench for the
modified parallel shift and add multipliers
(test_modified_parallel_multiplier.vhd).

Section 8.4.3 post correction multiplication
(postcorrection_multiplier.vhd). A test bench for post
correction multiplication (test_postcorrection_multiplier.vhd)

Section 8.4.4 Booth multiplier. A radix-2 combinational Booth
multiplier (Booth1_multiplier.vhd). A test bench for radix-2
booth multiplication (test_Booth1_multiplier.vhd). A sequential
booth multiplier (test_Booth2_sequential_multiplier.vhd). A
test bench for sequential booth multiplication
(test_Booth2_sequential_multiplier.vhd).

Section 8.5 constant multipliers. Sequential constant
multiplier (sequential_constant_multiplier.vhd). A test bench
for Sequential constant multiplier
(test_sequential_constant_multiplier.vhd).


Chapter 9: Dividers
~~~~~~~~~~~~~~~~~~~
Section 9.2 radix-2 division:

Section 9.2.1 non-restoring divider (non_restoring.vhd). A
testbench for non-restoring divider
(test_non_restoring_divider.vhd).

Section 9.2.2 restoring divider (restoring.vhd). A testbench
for restoring divider (test_restoring_divider.vhd).

Section 9.2.3 binary SRT divider (srt_divider.vhd). A test
bench for binary SRT divider (test_srt_divider.vhd).

Section 9.2.4 binary SRT divider using carry save adder
(srt_csa_divider.vhd). A test bench for binary SRT CSA divider
(test_srt_csa_divider.vhd).

Section 9.2.5 radix-2^k SRT divider. A radix 4 divider
(radix_four_divider.vhd). A test bench for radix 4 divider
(test_radix_four_divider.vhd).

Section 9.3 Radix B dividers. A decimal (B=10) divider
(decimal_divider.vhd, ). A test bench for decimal divider
(test_decimal_divider.vhd).

Section 9.4 convergence algorithm. A goldschmith divider
(goldschmidt.vhd). A test bench for convergence divider
(test_goldschmidt.vhd).


Chapter 10: Other operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Section 10.1 Binary to radix-B conversion. A binary to decimal
sequential converter (BinaryToDecimal2.vhd, uses ch9 models:
uses: doubling_circuit2.vhd and lut4_behav.vhd). A test bench
for non-restoring divider (Test_BinaryToDecimal2.vhd).

Section 10.2 Binary to radix-B conversion. A binary to decimal
sequential converter (DecimalToBinary2.vhd, uses ch9 models:
uses: multiply_by_five.vhd, and lut4_behav.vhd). A test bench
for non-restoring divider (Test_DecimalToBinary2.vhd).

Section 10.3 Square root

Section 10.3.1 restoring square root (SquareRoot.vhd). A test
bench for restoring square root (Test_SquareRoot.vhd).

Section 10.3.2 non-restoring square root (SquareRoot3.vhd). A
test bench for non-restoring square root (SquareRoot3.vhd).

Section 10.3.3 Newton-Raphson square root (SquareRootNR4.vhd ,
uses: restoring3.vhd). A test bench for NR square root
(Test_SquareRootNR4.vhd)

Section 10.4 Logarithm (Logarithm.vhd). A testbench for
logarithm (Test_Logarithm.vhd).

Section 10.5 Exponential. Exponential models (Exponential.vhd
and Exponential2.vhd). Textbenches for exponential models
(Test_Exponential.vhd and Test_Exponential2.vhd).

Section 10.6 Trigonometric functions. Cordic for Sine cosine
example (cordic2.vhd). Test bench for sine cosine using cordic
(Test_cordic2.vhd). Cordic for distance calculation
(norm_cordic.vhd). Test bench for cordic (x^2+y^2)^0.5
(Test_norm_cordic.vhd)


Chapter 11: Decimal Operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simple decimal ripple carry adder (ripple_carry_adder_BCD.vhd).
A test bench for decimal adders (test_adder_BCD.vhd).

Carry chain adders. Behavioral model (cych_adder_BCD_v1.vhd),
FPGA optimized model (cych_adder_BCD_v2.vhd). A test bench for
decimal adders (test_adder_BCD.vhd).

One digit by one digit multiplication. Binary arithmetic with
correction (bcd_mul_arith1.vhd and bcd_mul_arith2.vhd). ROM
based implementation (bcd_mul_bram.vhd, bcd_mul_mem1.vhd and
bcd_mul_mem2.vhd). A test bench for decimal 1 by 1 digit
multiplication (test_mul_1by1BCD.vhd).

N digits by one digit multiplication. Using LUTs or arithmetic
1x1 multiplication (mult_Nx1_BCD.vhd). Using BRAMs
(mult_Nx1_BCD_bram.vhd). Test bench for N by 1 multiplication
(test_mul_Nx1_simple.vhd and test_mul_Nx1_bram.vhd).

N by M digits multiplication. Sequential implementations
(mult_BCD_seq.vhd and mult_BCD_bram_seq.vhd). A combinational
implementation (mult_BCD_comb.vhd). Test benches for N by M
digits multiplication (test_mult_BCD_seq.vhd and
test_mult_BCD_comb.vhd)

N by N digits division with P digit quotient. non-restoring
like divisor implementation (decimal_divider_nr_norm.vhd, uses
also: decimal_shift_register.vhd, adders and multipliers of
chapter 11). SRT-like divisor implementation
(decimal_divider_SRT_like.vhd, uses also:
decimal_shift_register.vhd, mult_Nx1_BCD_carrysave.vhd,
special_5digit_adder.vhd, range_detection3.vhd,
bcd_csa_addsub_4to2.vhd, decimal_CSAS_4to2.vhd adders and
multipliers of chapter 11)). A test bench for decimal dividers
(test_dec_div_seq.vhd).


Chapter 12: Floating Point
~~~~~~~~~~~~~~~~~~~~~~~~~~
Section 12.5.1 Floating Point Adder/Subtactor (fp_add.vhd;
uses: fp_right_shifter.vhd and fp_leading_zeros_and_shift.vhd).
A test bench for the FP adder with a stimuli file
(fp_add_tb.vhd; dataAdd.txt).

Section 12.5.2 Floating Point Multiplier (fp_mul.vhd). A test
bench for the FP multiplier with a small stimuli file
(fp_mul_tb.vhd; dataMul.txt).

Section 12.5.3 Floating Point Divider (fp_div.vhd; uses:
div_nr_wsticky.vhd and a_s_cell.vhd). A test bench for the FP
divider with a small stimuli file (fp_div_tb.vhd;
dataDivFloat.txt).

Section 12.5.4 Floating Point Square Root (fp_sqrt.vhd; uses:
sqrt_wstiky.vhd, sqrt_cell.vhd, and sqrt_cell_00.vhd). A test
bench for the FP multiplier with a small stimuli file
(fp_sqrt_tb.vhd; dataSqrtFloat.txt).


Chapter 13: Finite Field Arithmetic
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Section 13.1 Operation mod m.

Section 13.1.1 Addition and subtraction mod m (mod_m_as.vhd). A
simple test bench for add sub mod m (test_mod_m_as_simple.vhd)

Section 13.1.2 Multiplication mod m. 13.1.2.1 multiply and
reduce. A mod 2^192-2^64-1 reducer (mod_p192_reducer2.vhd).
13.1.2.2 interleaved multiplier (interleaved_mult.vhd). A
simple test bench for interleaved multiplier
(test_mod_m_multiplier_simple.vhd). 13.1.2.3 Montgomery
multiplier (Montgomery_multiplier.vhd). A simple test bench for
Montgomery multiplier (test_Montgomery_multiplier_simple.vhd).
A behavioral model of mod m exponentiation using montgomery
algorithm (mod_m_exponentiation.vhd). A simple test bench for
exponentiation (test_Montgomery_multiplier_simple.vhd).

Section 13.2 A bahavioural Division mod p
(Montgomery_multiplier.vhd). A test bench for mod p division
(test_Montgomery_multiplier_simple.vhd).

Section 13.3 Operations over Z2[x]/f(x)

Section 13.3.2 Multiplication. 13.3.2.1 Multiply and reduce
multiplier (classic_multiplier.vhd). 13.3.2.2 Interleaved
multiplication (interleaved_mult.vhd). A squarer mod f(x)
(mod_f_squaring.vhd).

Section 13.4 Division over GF(2m). Behavioral models
(mod_f_division2.vhd and mod_f_division3.vhd). Test bench for
behavioral models (test_mod_f_division2.vhd and
test_mod_f_division3.vhd). A synthesizable binary divider
(mod_f_binary_division.vhd).


Chapter 15: Embedded systems development: case studies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
All the example projects of chapter 15 "Embedded systems
development: case studies" are in the preceding link.


Chapter 16: Partial reconfiguration on Xilinx FPGAs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
All the example projects of chapter 16 "Partial reconfiguration
on Xilinx FPGAs" are in the preceding link.
