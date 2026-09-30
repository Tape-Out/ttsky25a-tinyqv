// prism 的锁存器文件只有 SIM 与 sky130 两支，pwl_synth 的存储只有 sky130 与 sg13g2 两支，都没有通用分支；
// 这里按单元的逻辑功能写行为模型，端口名照 sky130_fd_sc_hd，不含电源脚
`default_nettype none

module sky130_fd_sc_hd__dlxtp_1 (input wire D, input wire GATE, output reg Q);
  always @* if (GATE) Q = D;
endmodule

// 门控时钟：CLK 低时锁存 GATE，免得毛刺
module sky130_fd_sc_hd__dlclkp_1 (input wire CLK, input wire GATE, output wire GCLK);
  reg en;
  always @* if (!CLK) en = GATE;
  assign GCLK = CLK & en;
endmodule

module sky130_fd_sc_hd__and2_1 (input wire A, input wire B, output wire X);
  assign X = A & B;
endmodule

module sky130_fd_sc_hd__or2_1 (input wire A, input wire B, output wire X);
  assign X = A | B;
endmodule

module sky130_fd_sc_hd__or2_2 (input wire A, input wire B, output wire X);
  assign X = A | B;
endmodule

module sky130_fd_sc_hd__or2_4 (input wire A, input wire B, output wire X);
  assign X = A | B;
endmodule

`default_nettype wire
