// 
// systemversion.v
//
// Top level file for the system version IP core.
//
// FPGA version has the format maj.min.build where maj and min are set from the block design and
// build from the build script.
//
// Board type and revision are read from external pins.
//
// MIT License
// Copyright (c) 2025 Starware Design Ltd
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
`timescale 1ns/1ns

module systemversion #(  
  // APB parameters
  parameter integer ADDRWIDTH          = 16,
  // FPGA version
  parameter integer C_VER_MAJ          = 0 ,
  parameter integer C_VER_MIN          = 1 ,
  parameter integer C_VER_BUILD        = 0 ,
  // size board type and board revision
  parameter integer C_BOARD_TYPE_WIDTH = 4 ,
  parameter integer C_BOARD_REV_WIDTH  = 4
) (
  //---------------------------------------------------------------------------
  // APB interface
  //---------------------------------------------------------------------------
  input                               pclk,
  input                               presetn,
  input                               psel,  
  input      [         ADDRWIDTH-1:0] paddr,
  input                               penable,
  input      [                  31:0] pwdata,
  input                               pwrite,
  output reg                          pready,
  output reg [                  31:0] prdata,
  output                              pslverr,
  //---------------------------------------------------------------------------
  // I/O pins
  //---------------------------------------------------------------------------
  input      [C_BOARD_TYPE_WIDTH-1:0] board_type,
  input      [ C_BOARD_REV_WIDTH-1:0] board_rev
);

// FPGA_VER register
`define FPGA_VER_RSVD_SIZE                  16
`define FPGA_VER_RSVD_OFFSET                (`FPGA_VER_MAJ_OFFSET + `FPGA_VER_MAJ_SIZE)
`define FPGA_VER_MAJ_SIZE                   8
`define FPGA_VER_MAJ_OFFSET                 (`FPGA_VER_MIN_OFFSET + `FPGA_VER_MIN_SIZE)
`define FPGA_VER_MIN_SIZE                   8
`define FPGA_VER_MIN_OFFSET                 (0)

`define FPGA_VER       0
`define FPGA_VER_BUILD 1
`define BOARD          2 

//---------------------------------------------------------------------------
// Internal registers bank
//---------------------------------------------------------------------------
wire [31:0] fpga_ver_reg;
wire [31:0] fpga_ver_build_reg;
wire [31:0] board_reg;

//---------------------------------------------------------------------------
// FPGA version
//---------------------------------------------------------------------------
assign fpga_ver_reg[`FPGA_VER_RSVD_OFFSET+:`FPGA_VER_RSVD_SIZE]   = 'b0;
assign fpga_ver_reg[`FPGA_VER_MAJ_OFFSET+:`FPGA_VER_MAJ_SIZE]     = C_VER_MAJ;
assign fpga_ver_reg[`FPGA_VER_MIN_OFFSET+:`FPGA_VER_MIN_SIZE]     = C_VER_MIN;
assign fpga_ver_build_reg[31:0] = C_VER_BUILD;

//---------------------------------------------------------------------------
// Board type and revision
//---------------------------------------------------------------------------

// Since the board type/rev signals are static, just replicating double FF
// will be fine

reg [C_BOARD_TYPE_WIDTH-1:0]     board_type_d1; /* synthesis syn_keep=1 */;
reg [C_BOARD_TYPE_WIDTH-1:0]     board_type_d2; /* synthesis syn_keep=1 */;
reg [ C_BOARD_REV_WIDTH-1:0]     board_rev_d1 ; /* synthesis syn_keep=1 */;
reg [ C_BOARD_REV_WIDTH-1:0]     board_rev_d2 ; /* synthesis syn_keep=1 */;

always @(posedge pclk or negedge presetn)
begin
  if (presetn == 1'b0) begin
    board_type_d1 <= 'b0;
    board_type_d2 <= 'b0;
    board_rev_d1  <= 'b0;
    board_rev_d2  <= 'b0;
  end else begin
    board_type_d1 <= board_type;
    board_type_d2 <= board_type_d1;
    board_rev_d1  <= board_rev;
    board_rev_d2  <= board_rev_d1;
  end
end

assign board_reg[16+:16] = board_type_d2;
assign board_reg[ 0+:16] = board_rev_d2;

//-------------------------------------------------------------
// APB interface
//-------------------------------------------------------------

// always ready and no errors
assign pslverr = 1'b0;

always @(posedge pclk or negedge presetn)
  begin
    if (presetn == 1'b0)
      pready <= 1'b0;
    else 
      pready <= psel;
  end

always @(posedge pclk or negedge presetn)
  begin
    if (presetn == 1'b0)
      prdata <= 0;
    else if (psel == 1'b1)
      case (paddr[ADDRWIDTH-1:2])
        `FPGA_VER       : prdata <= fpga_ver_reg;
        `FPGA_VER_BUILD : prdata <= fpga_ver_build_reg;
        `BOARD          : prdata <= board_reg;
        default         : prdata <= 0;
      endcase
  end

endmodule
