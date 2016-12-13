module testbench (
	input clk,
	input         mem_ready,
	output        mem_valid,
	output        mem_instr,
	output [31:0] mem_addr,
	output [31:0] mem_wdata,
	output [3:0]  mem_wstrb,
	input  [31:0] mem_rdata,

);
	parameter integer N = 20;

	reg resetn = 0;
	wire trap;

	always @(posedge clk)
		resetn <= 1;

	wire        rvfi_valid;
	wire [4:0]  rvfi_rs1;
	wire [4:0]  rvfi_rs2;
	wire [4:0]  rvfi_rd;
	wire [31:0] rvfi_insn;
	wire [31:0] rvfi_pre_pc;
	wire [31:0] rvfi_pre_rs1;
	wire [31:0] rvfi_pre_rs2;
	wire [31:0] rvfi_post_pc;
	wire [31:0] rvfi_post_rd;
	wire        rvfi_post_trap;

	reg enable = 0;
	reg [7:0] cycle = 0;

	always @(posedge clk) begin
		if (~cycle)
			cycle <= cycle + 1;
		enable <= cycle == N;
	end

	riscv_formal_insn_checker #(
		.XLEN(32),
		.NRET(1)
	) checker (
		.clk            (clk                 ),
		.rvfi_valid     (rvfi_valid && enable),
		.rvfi_rs1       (rvfi_rs1            ),
		.rvfi_rs2       (rvfi_rs2            ),
		.rvfi_rd        (rvfi_rd             ),
		.rvfi_insn      (rvfi_insn           ),
		.rvfi_pre_pc    (rvfi_pre_pc         ),
		.rvfi_pre_rs1   (rvfi_pre_rs1        ),
		.rvfi_pre_rs2   (rvfi_pre_rs2        ),
		.rvfi_post_pc   (rvfi_post_pc        ),
		.rvfi_post_rd   (rvfi_post_rd        ),
		.rvfi_post_trap (rvfi_post_trap      )
	);

	picorv32 #(
		.COMPRESSED_ISA(0),
		.BARREL_SHIFTER(1)
	) uut (
		.clk            (clk           ),
		.resetn         (resetn        ),
		.trap           (trap          ),

		.mem_valid      (mem_valid     ),
		.mem_instr      (mem_instr     ),
		.mem_ready      (mem_ready     ),
		.mem_addr       (mem_addr      ),
		.mem_wdata      (mem_wdata     ),
		.mem_wstrb      (mem_wstrb     ),
		.mem_rdata      (mem_rdata     ),

		.rvfi_valid     (rvfi_valid    ),
		.rvfi_rs1       (rvfi_rs1      ),
		.rvfi_rs2       (rvfi_rs2      ),
		.rvfi_rd        (rvfi_rd       ),
		.rvfi_insn      (rvfi_insn     ),
		.rvfi_pre_pc    (rvfi_pre_pc   ),
		.rvfi_pre_rs1   (rvfi_pre_rs1  ),
		.rvfi_pre_rs2   (rvfi_pre_rs2  ),
		.rvfi_post_pc   (rvfi_post_pc  ),
		.rvfi_post_rd   (rvfi_post_rd  ),
		.rvfi_post_trap (rvfi_post_trap)
	);

	reg [4:0] mem_wait = 0;
	always @(posedge clk) begin
		mem_wait <= {mem_wait, mem_valid && !mem_ready};
		// restrict(~mem_wait && !trap);
	end
endmodule

