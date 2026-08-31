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

// Testbench: Binary-to-BCD Memory-Mapped Peripheral.
// Date Created: 24/06/2026.

// Reference materials:
// 1. Altera Avalon Interface Specifications
// 2. Custom Programmer's Model
// Note: Burst transfers and interrupts aren't supported in the design.

`timescale 1ns / 1ps

module bin2bcd_mm_tb();
   //////////////////////////////////////////////////////////////////
   localparam int CLK_PERIOD        = 10;
   localparam int WORD_LEN          = 32;
   localparam int ADDR_LEN          =  3;
   localparam int NUM_TESTS         =  5;
   // Register address indexes
   localparam int ADDR_STATUS       =  0;
   localparam int ADDR_CONTROL      =  1;
   localparam int ADDR_INPUT_DATA   =  2;
   localparam int ADDR_OUTPUT_DATA1 =  3;
   localparam int ADDR_OUTPUT_DATA2 =  4; 
   //////////////////////////////////////////////////////////////////      
   // Signals: UUT
   logic                clk       =      1'b0;
   logic                rst_n     =      1'b1;
   logic                write_n   =      1'b1;
   logic                read_n    =      1'b1;
   logic [ADDR_LEN-1:0] address   =   ADDR_STATUS;
   logic [WORD_LEN-1:0] writedata = {WORD_LEN{1'b0}};
   logic [WORD_LEN-1:0] readdata;
   // Signals: Simulation
   logic        enable = {{WORD_LEN-1{1'b0}}, 1'b1};
   int unsigned test_data [0:NUM_TESTS-1] = {
      32'd200345, 
      32'd12234555, 
      32'd1278897988, 
      32'd4294967295, 
      32'd123456789};
      
   longint expected [0:NUM_TESTS-1] = {
      64'h200345, 
      64'h12234555, 
      64'h1278897988, 
      64'h4294967295, 
      64'h123456789};
   
   // Brief: Host-to-agent bus write
   task avalon_bus_write(input [ADDR_LEN-1:0] addr,input [WORD_LEN-1:0] data);
      write_n   <= 1'b0;
      address   <= addr;
      writedata <= data;
      @(posedge clk);
      write_n   <= 1'b1;
      @(posedge clk);
   endtask

   // Brief: Host-to-agent bus read
   task avalon_bus_read(input [ADDR_LEN-1:0] addr);
      read_n  <= 1'b0;
      address <= addr;
      @(posedge clk);
      read_n  <= 1'b1;
      @(posedge clk);
   endtask
   
   initial begin: clock_gen
      forever begin
         #(CLK_PERIOD / 2);
         clk <= ~clk;
      end
   end
   
   initial begin: reset_gen
      repeat(5) @(posedge clk);
      rst_n <= 1'b0;
      repeat(5) @(posedge clk);
      rst_n <= 1'b1;
   end
   
   // UUT
   bin2bcd_mm #(.WORD_LEN  (WORD_LEN),
                .ADDR_LEN  (ADDR_LEN)) uut
               (.clk       (clk),
                .rst_n     (rst_n),
                .write_n   (write_n),
                .read_n    (read_n),
                .address   (address), 
                .writedata (writedata),
                .readdata  (readdata));   
   
   // 1. Write to the control register to enable the peripheral
   // 2. Send test data, poll status register, and read output registers
   initial begin: stimuli
      ///////////////////////////////////////////////////////////////
      bit busy;
      bit done;
      bit prev_busy;
      busy      = 1'b0;
      done      = 1'b0;
      prev_busy = 1'b0;
      ///////////////////////////////////////////////////////////////
      wait(rst_n == 1'b0);
      wait(rst_n == 1'b1);
      avalon_bus_write(ADDR_CONTROL, enable);
      for(int i = 0; i < NUM_TESTS; i++) begin
         avalon_bus_write(ADDR_INPUT_DATA, test_data[i]);
         forever begin
            avalon_bus_read(ADDR_STATUS);
            busy = readdata[0];
            done = readdata[1];
            if(busy && !prev_busy) prev_busy = 1'b1;
            if(done &&  prev_busy) begin
               prev_busy = 1'b0;
               break;
            end
         end
         avalon_bus_read(ADDR_OUTPUT_DATA1);
         avalon_bus_read(ADDR_OUTPUT_DATA2);
      end
   end
   
   initial begin: monitor
      ///////////////////////////////////////////////////////////////
      int          num_of_tests;
      int          passed;
      int          failed;
      int unsigned lower_word;
      int unsigned upper_word;
      longint      bcd_concat;
      bit          addr1_loaded;
      bit          addr2_loaded;
      num_of_tests =  0;
      passed       =  0;
      failed       =  0;
      lower_word   =  0;
      upper_word   =  0;
      bcd_concat   =  0;
      addr1_loaded = 1'b0;
      addr2_loaded = 1'b0;
      ///////////////////////////////////////////////////////////////
      $timeformat(-9, 0, " ns");
      wait(rst_n == 1'b0);
      wait(rst_n == 1'b1);
      forever begin
         @(negedge clk);
         if(num_of_tests == NUM_TESTS) begin
            $display("%0t | [DONE]. Passed: %0d, Failed: %0d",
                     $time, passed, failed);
            $finish;
         end
         else begin
            if(address == ADDR_OUTPUT_DATA1 && !addr1_loaded) begin
               addr1_loaded = 1'b1;
            end
            else if(addr1_loaded) begin
               lower_word   = readdata;
               addr1_loaded = 1'b0;
            end
            else if(address == ADDR_OUTPUT_DATA2 && !addr2_loaded) begin
               addr2_loaded = 1'b1;
            end
            else if(addr2_loaded) begin
               upper_word   = readdata;
               bcd_concat   = {upper_word,lower_word};
               if(bcd_concat == expected[num_of_tests]) begin
                  $display("%0t | [PASS]: BCD data = %0x, Expected = %0x",
                           $time, bcd_concat, expected[num_of_tests]);
                  passed = passed + 1;
               end
               else begin
                  $display("%0t | [FAIL]: BCD data = %0x, Expected = %0x",
                           $time, bcd_concat, expected[num_of_tests]);
                  failed = failed + 1;             
               end
               addr2_loaded = 1'b0;
               num_of_tests = num_of_tests + 1;
            end
         end
      end
   end
endmodule 
