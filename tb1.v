`timescale 1ns/1ps

module tb_spmm_csr;


reg ap_clk;
reg ap_rst;
reg ap_start;
wire ap_done;
wire ap_idle;
wire ap_ready;

reg [31:0] RowA = 4;
reg [31:0] ColA = 4;
reg [31:0] ColB = 4;

// Memory Arrays

reg [31:0] RPA_mem [0:4];
reg [31:0] CIA_mem [0:5];
reg [31:0] NVA_mem [0:5];

reg [31:0] RPB_mem [0:4];
reg [31:0] CIB_mem [0:6];
reg [31:0] NVB_mem [0:6];

reg [31:0] RPC_mem [0:4];
reg [31:0] CIC_mem [0:8];
reg [31:0] NVC_mem [0:8];

// DUT Interface

wire [2:0] RPA_address0;
wire RPA_ce0;
reg  [31:0] RPA_q0;

wire [2:0] RPA_address1;
wire RPA_ce1;
reg  [31:0] RPA_q1;

wire [2:0] CIA_address0;
wire CIA_ce0;
reg  [31:0] CIA_q0;

wire [2:0] NVA_address0;
wire NVA_ce0;
reg  [31:0] NVA_q0;

wire [2:0] RPB_address0;
wire RPB_ce0;
reg  [31:0] RPB_q0;

wire [2:0] RPB_address1;
wire RPB_ce1;
reg  [31:0] RPB_q1;

wire [2:0] CIB_address0;
wire CIB_ce0;
reg  [31:0] CIB_q0;

wire [2:0] NVB_address0;
wire NVB_ce0;
reg  [31:0] NVB_q0;

wire [2:0] RPC_address0;
wire RPC_ce0;
wire RPC_we0;
wire [31:0] RPC_d0;

wire [3:0] CIC_address0;
wire CIC_ce0;
wire CIC_we0;
wire [31:0] CIC_d0;

wire [3:0] NVC_address0;
wire NVC_ce0;
wire NVC_we0;
wire [31:0] NVC_d0;

// Initialize BRAM outputs (avoid X propagation)

initial begin
    RPA_q0 = 0; RPA_q1 = 0;
    CIA_q0 = 0; NVA_q0 = 0;
    RPB_q0 = 0; RPB_q1 = 0;
    CIB_q0 = 0; NVB_q0 = 0;
end

// TRUE SYNCHRONOUS BRAM (1-cycle latency)

always @(posedge ap_clk) begin
    if (RPA_ce0) RPA_q0 <= RPA_mem[RPA_address0];
    if (RPA_ce1) RPA_q1 <= RPA_mem[RPA_address1];

    if (CIA_ce0) CIA_q0 <= CIA_mem[CIA_address0];
    if (NVA_ce0) NVA_q0 <= NVA_mem[NVA_address0];

    if (RPB_ce0) RPB_q0 <= RPB_mem[RPB_address0];
    if (RPB_ce1) RPB_q1 <= RPB_mem[RPB_address1];

    if (CIB_ce0) CIB_q0 <= CIB_mem[CIB_address0];
    if (NVB_ce0) NVB_q0 <= NVB_mem[NVB_address0];
end

// WRITE LOGIC

always @(posedge ap_clk) begin
    if (RPC_we0)
        RPC_mem[RPC_address0] <= RPC_d0;

    if (CIC_we0)
        CIC_mem[CIC_address0] <= CIC_d0;

    if (NVC_we0)
        NVC_mem[NVC_address0] <= NVC_d0;
end

// DUT

spmm_csr dut (
    .ap_local_block(),
    .ap_local_deadlock(),
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),

    .RowA(RowA),
    .ColA(ColA),
    .ColB(ColB),

    .RPA_address0(RPA_address0),
    .RPA_ce0(RPA_ce0),
    .RPA_q0(RPA_q0),
    .RPA_address1(RPA_address1),
    .RPA_ce1(RPA_ce1),
    .RPA_q1(RPA_q1),

    .CIA_address0(CIA_address0),
    .CIA_ce0(CIA_ce0),
    .CIA_q0(CIA_q0),

    .NVA_address0(NVA_address0),
    .NVA_ce0(NVA_ce0),
    .NVA_q0(NVA_q0),

    .RPB_address0(RPB_address0),
    .RPB_ce0(RPB_ce0),
    .RPB_q0(RPB_q0),
    .RPB_address1(RPB_address1),
    .RPB_ce1(RPB_ce1),
    .RPB_q1(RPB_q1),

    .CIB_address0(CIB_address0),
    .CIB_ce0(CIB_ce0),
    .CIB_q0(CIB_q0),

    .NVB_address0(NVB_address0),
    .NVB_ce0(NVB_ce0),
    .NVB_q0(NVB_q0),

    .RPC_address0(RPC_address0),
    .RPC_ce0(RPC_ce0),
    .RPC_we0(RPC_we0),
    .RPC_d0(RPC_d0),

    .CIC_address0(CIC_address0),
    .CIC_ce0(CIC_ce0),
    .CIC_we0(CIC_we0),
    .CIC_d0(CIC_d0),

    .NVC_address0(NVC_address0),
    .NVC_ce0(NVC_ce0),
    .NVC_we0(NVC_we0),
    .NVC_d0(NVC_d0)
);

// FSM DEBUG MONITOR

reg [31:0] prev_state;

initial prev_state = 0;

always @(posedge ap_clk) begin
    if (!ap_rst) begin
        if (prev_state !== dut.ap_CS_fsm) begin
            $display("Time=%0t | FSM=%b | i=%0d | done=%b | ready=%b | idle=%b",
                     $time,
                     dut.ap_CS_fsm,
                     dut.i_fu_78,
                     ap_done,
                     ap_ready,
                     ap_idle);

            prev_state <= dut.ap_CS_fsm;
        end
    end
end

always @(posedge ap_clk) begin
    $display("Time=%0t | FSM=%b | rst=%b | start=%b | idle=%b | ready=%b | done=%b",
             $time,
             dut.ap_CS_fsm,
             ap_rst,
             ap_start,
             ap_idle,
             ap_ready,
             ap_done);
end




// CLOCK

always #5 ap_clk = ~ap_clk;

// STIMULUS

integer i;

initial begin

    ap_clk   = 0;
    ap_rst   = 1;
    ap_start = 0;

    // CSR A
    RPA_mem[0]=0; RPA_mem[1]=2; RPA_mem[2]=3; RPA_mem[3]=5; RPA_mem[4]=6;
    CIA_mem[0]=0; CIA_mem[1]=2; CIA_mem[2]=1;
    CIA_mem[3]=0; CIA_mem[4]=3; CIA_mem[5]=2;
    NVA_mem[0]=1; NVA_mem[1]=2; NVA_mem[2]=3;
    NVA_mem[3]=4; NVA_mem[4]=5; NVA_mem[5]=6;

    // CSR B
    RPB_mem[0]=0; RPB_mem[1]=2; RPB_mem[2]=3; RPB_mem[3]=5; RPB_mem[4]=7;
    CIB_mem[0]=0; CIB_mem[1]=3; CIB_mem[2]=1;
    CIB_mem[3]=0; CIB_mem[4]=2; CIB_mem[5]=1; CIB_mem[6]=3;
    NVB_mem[0]=7; NVB_mem[1]=8; NVB_mem[2]=9;
    NVB_mem[3]=10; NVB_mem[4]=11; NVB_mem[5]=12; NVB_mem[6]=13;

    // Reset aligned to clock
    repeat(5) @(posedge ap_clk);
    ap_rst = 0;

    // Start handshake
    @(posedge ap_clk);
    ap_start = 1;
    @(posedge ap_clk);
    ap_start = 0;

    // Wait for completion
    wait(ap_done == 1);

    repeat(3) @(posedge ap_clk);

    $display("==== RPC ====");
    for(i=0;i<5;i=i+1)
        $display("%d", RPC_mem[i]);

    $display("==== CIC ====");
    for(i=0;i<9;i=i+1)
        $display("%d", CIC_mem[i]);

    $display("==== NVC ====");
    for(i=0;i<9;i=i+1)
        $display("%d", NVC_mem[i]);

    $finish;
end

endmodule
