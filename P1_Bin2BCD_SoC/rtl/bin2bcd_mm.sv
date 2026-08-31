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

// Binary-to-BCD Memory-Mapped Peripheral.
// Date Created: 16/06/2026.
// Date Updated: 31/08/2026.

// Change(s) made on 31/08/2026:
// - Merged both output data registers in one vector.

// 
// Important Notes:
// A word is 32 bits or 4 bytes in this design.
// The design uses the "addressUnits=WORDS" configuration. This means that
// the "address" input is an index mapped to a word address. For example,
// an address = 0 selects the first word address (configured in Platform
// Designer) and an address = 1 selects the next word address which is equal
// to the previous address + 4. 

// For more information, check the "Altera Avalon Interface Specifications"
// document.

module bin2bcd_mm 
#( parameter int   WORD_LEN = 32,
   parameter int   ADDR_LEN = 3)
 ( input    logic                clk,
   input    logic                rst_n,
   input    logic                write_n,
   input    logic                read_n,
   input    logic [ADDR_LEN-1:0] address,   // Register address (absolute)
   input    logic [WORD_LEN-1:0] writedata, // Data from HPS
   output   logic [WORD_LEN-1:0] readdata); // Data to HPS
   
   // bin2bcd IP parameters and signals   
   localparam int BCD_WIDTH = 4*pkg::ceil(WORD_LEN,3);   
   logic                 valid_in;
   logic  [WORD_LEN-1:0] bin;
   logic [BCD_WIDTH-1:0] bcd;
   logic                 valid_out;
   
   bin2bcd bin2bcd_ip (.clk       (clk),
                       .rst_n     (rst_n),
                       .valid_in  (valid_in),
                       .bin       (bin),
                       .bcd       (bcd),
                       .valid_out (valid_out));  
   
   //////////////////////////////////////////////////////////////////
   // Section: qsys_regs logic   
   typedef enum
   {
      STATUS       = 0,
      CONTROL      = 1,
      INPUT_DATA   = 2,
      OUTPUT_DATA1 = 3,
      OUTPUT_DATA2 = 4
   }address_index;
   address_index addr;

   // Register file
   typedef struct
   {
      logic   [WORD_LEN-1:0] status;
      logic   [WORD_LEN-1:0] control;
      logic   [WORD_LEN-1:0] input_data;
      logic [2*WORD_LEN-1:0] output_data;
   }mmap_t;
   mmap_t mmap_reg;  // Memory-mapped register output
   mmap_t mmap_next; // Memory-mapped register input  
   
   logic [WORD_LEN-1:0] read_reg; // 1-cycle delay register for "readdata" output
   logic [WORD_LEN-1:0] read_next;    
   
   assign addr = address_index'(address); // Cast address to enum type
   
   always_comb begin: hps_write_mmap_regs
      mmap_next.control    = mmap_reg.control;
      mmap_next.input_data = mmap_reg.input_data;
      if(!write_n) begin
         case(addr)
            CONTROL:     mmap_next.control    = writedata;
            INPUT_DATA:  mmap_next.input_data = writedata;
            default: begin
            end
         endcase
      end
   end
   
   always_comb begin: hps_read_mmap_regs
      read_next = read_reg;
      if(!read_n) begin
         case(addr)
            STATUS:       read_next = mmap_reg.status;
            CONTROL:      read_next = mmap_reg.control;
            INPUT_DATA:   read_next = mmap_reg.input_data; 
            OUTPUT_DATA1: read_next = mmap_reg.output_data[  WORD_LEN-1:0];
            OUTPUT_DATA2: read_next = mmap_reg.output_data[2*WORD_LEN-1:WORD_LEN];
            default: begin
            end
         endcase
      end
   end
   //////////////////////////////////////////////////////////////////
   
   //////////////////////////////////////////////////////////////////
   // Section: regs_bin2bcd logic
   logic busy_reg;
   logic busy_next;
   logic new_bin_reg; // Indicate arrival of new binary data from HPS
   logic new_bin_next;
   // Memory-mapped register bits
   logic status_busy;
   logic status_done;
   logic control_en; 
   
   always_comb begin: busy_bit_logic
      if(control_en && new_bin_reg)  busy_next = 1'b1;
      else if(valid_out)             busy_next = 1'b0;
      else                           busy_next = busy_reg;
   end
   
   assign status_busy            =   (valid_out) ? 1'b0: busy_reg;
   assign new_bin_next           =   ~write_n & (addr == INPUT_DATA);  
   assign control_en             =    mmap_reg.control[0];
   assign mmap_next.status       =  {{WORD_LEN-2{1'b0}}, status_done, status_busy};
   assign valid_in               =    control_en & new_bin_reg;
   assign bin                    =    mmap_reg.input_data;
   assign mmap_next.output_data  =  {{2*WORD_LEN-BCD_WIDTH{1'b0}}, bcd};
   assign status_done            =    valid_out;    
   //////////////////////////////////////////////////////////////////
   
   // Top-level output
   assign readdata = read_reg;
   
   always_ff @(negedge rst_n, posedge clk) begin: registers
      if(!rst_n) begin
         mmap_reg     <=   '{default:0};
         new_bin_reg  <=       1'b0;
         busy_reg     <=       1'b0;
         read_reg     <=  {WORD_LEN{1'b0}};
      end
      else begin
         mmap_reg     <=    mmap_next;
         new_bin_reg  <=    new_bin_next;
         busy_reg     <=    busy_next;
         read_reg     <=    read_next;
      end
   end
endmodule 
