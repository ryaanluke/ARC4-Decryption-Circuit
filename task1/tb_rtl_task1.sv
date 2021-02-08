`timescale 1ps / 1ps
module tb_rtl_task1();

// Your testbench goes here.

logic clock50;
logic [3:0] keys;
logic [9:0] switches, leds;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

task1 dut(.CLOCK_50(clock50), .KEY(keys), .SW(switches), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), 
                    .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(leds));

initial begin
    clock50 = 0;
    forever #5 clock50 = ~clock50;
end



initial begin
    #1
    keys = 4'b0000; // click reset 
    #1
    keys = 4'b1000; // unclick reset

    #2750
   
    

    $stop;
end

endmodule: tb_rtl_task1
