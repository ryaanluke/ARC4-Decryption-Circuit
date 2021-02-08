`timescale 1ps / 1ps
module tb_rtl_arc4();

// Your testbench goes here.
logic clk, rst_n, enable, rdy;
logic [23:0] key;
logic [7:0] ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;
logic pt_wren;

ct_mem ct(ct_addr, clk, ct_wrdata, 1'b0, ct_rddata);
pt_mem pt(pt_addr, clk, pt_wrdata, pt_wren, pt_rddata);
arc4 dut(clk, rst_n, enable, rdy, key, ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata, pt_wren);


initial begin
        clk = 0;
        forever #5 clk = ~clk;
end

initial begin
    #1
    rst_n = 1'b0;
    key = 24'h1E4600;
    $readmemh("test1.memh", ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
    #1
    rst_n = 1'b1;
    enable = 1'b1;
    #10
    enable = 1'b0;

    #1000000

    
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
    

    $stop;


end

endmodule: tb_rtl_arc4
