//  Copyright (c) 2026 Olaoluwa Raji
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

// Top-level Bin2BCD SoC design.

// Date created: 29/08/2026.

module bin2bcd_soc_top(
   input  logic         CLOCK_50,
   input  logic   [3:0] KEY,
   output logic  [14:0] HPS_DDR3_ADDR,
   output logic   [2:0] HPS_DDR3_BA,
   output logic         HPS_DDR3_CAS_N,
   output logic         HPS_DDR3_CKE,
   output logic         HPS_DDR3_CK_N,
   output logic         HPS_DDR3_CK_P,
   output logic         HPS_DDR3_CS_N,
   output logic   [3:0] HPS_DDR3_DM,
   inout  logic  [31:0] HPS_DDR3_DQ,
   inout  logic   [3:0] HPS_DDR3_DQS_N,
   inout  logic   [3:0] HPS_DDR3_DQS_P,
   inout  logic         HPS_CONV_USB_N,
   output logic         HPS_DDR3_ODT,
   output logic         HPS_DDR3_RAS_N,
   output logic         HPS_DDR3_RESET_N,
   output logic         HPS_DDR3_WE_N,
   input  logic         HPS_DDR3_RZQ);
   
   bin2bcd_soc bin2bcd_soc_inst (
        .clk_clk            (CLOCK_50),         //  .clk_clk
        .reset_reset_n      (KEY[0]),           //  .reset_reset_n
        .memory_mem_a       (HPS_DDR3_ADDR),    //  .memory_mem_a
        .memory_mem_ba      (HPS_DDR3_BA),      //  .memory_mem_ba
        .memory_mem_ck      (HPS_DDR3_CK_P),    //  .memory_mem_ck
        .memory_mem_ck_n    (HPS_DDR3_CK_N),    //  .memory_mem_ck_n
        .memory_mem_cke     (HPS_DDR3_CKE),     //  .memory_mem_cke
        .memory_mem_cs_n    (HPS_DDR3_CS_N),    //  .memory_mem_cs_n
        .memory_mem_ras_n   (HPS_DDR3_RAS_N),   //  .memory_mem_ras_n
        .memory_mem_cas_n   (HPS_DDR3_CAS_N),   //  .memory_mem_cas_n
        .memory_mem_we_n    (HPS_DDR3_WE_N),    //  .memory_mem_we_n
        .memory_mem_reset_n (HPS_DDR3_RESET_N), //  .memory_mem_reset_n
        .memory_mem_dq      (HPS_DDR3_DQ),      //  .memory_mem_dq
        .memory_mem_dqs     (HPS_DDR3_DQS_P),   //  .memory_mem_dqs
        .memory_mem_dqs_n   (HPS_DDR3_DQS_N),   //  .memory_mem_dqs_n
        .memory_mem_odt     (HPS_DDR3_ODT),     //  .memory_mem_odt
        .memory_mem_dm      (HPS_DDR3_DM),      //  .memory_mem_dm
        .memory_oct_rzqin   (HPS_DDR3_RZQ)      //  .memory_mem_oct_rzqin
    );
    
endmodule 
