`timescale 1ps / 1ps
module tb_rtl_crack();

// Your testbench goes here.
// Your testbench goes here.
logic clk, rst_n, enable, rdy;
logic [23:0] key;
logic [7:0] ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;
logic pt_wren;

ct_mem ct(ct_addr, clk, ct_wrdata, 1'b0, ct_rddata);
crack dut(clk, rst_n, enable, rdy, key, key_valid, ct_addr, ct_rddata);


initial begin
        clk = 0;
        forever #1 clk = ~clk;
end

initial begin
    #1
    rst_n = 1'b0;
    // key = 24'h1E4600;
    $readmemh("crack_test2.memh", ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
    #1
    rst_n = 1'b1;
    enable = 1'b1;
    #10
    enable = 1'b0;

    @(posedge rdy)
    $display("test done");
    #100

    /*
    #1
    rst_n = 1'b0;
    key = 24'h000018;
    $readmemh("test2.memh", ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
    #1
    rst_n = 1'b1;
    enable = 1'b1;
    #10
    enable = 1'b0;

    #1000000
    */

    $stop;


end

endmodule: tb_rtl_crack
