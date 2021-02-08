`timescale 1ps / 1ps
module tb_rtl_init();

// Your testbench goes here.

logic clock, reset, enable, ready, writeenable;
logic [7:0] address, writedata;

init DUT(clock, reset, enable, ready, address, writedata, writeenable);

initial begin
    clock = 0;
    reset = 1'b0;
    forever #5 clock = ~clock;
end

initial begin
    #10
    reset = 1'b1;
    enable = 1'b1; 
    $display("testing if reset works");

    #1
    assert (DUT.present_state == 3'b000) $display("Current state: `RESET");
    else $display("Current state not expected");

    assert (DUT.next_state == 3'b001) $display("Next state: `LOOP");
    else $display ("Next state not expected");

    assert (DUT.next_address == 8'bx) $display("Address driver: 8'bx");
    else $display ("Address driver not expected");

    assert (DUT.next_write_data == 8'bx) $display("Data driver: 8'bx");
    else $display ("Data driver not expected");

    assert (DUT.next_write_enable == 1'bx) $display("Write enable driver: 1'bx");
    else $display ("Write enable driver not expected");

    assert (address == 8'bx) $display("Address output: 8'bx");
    else $display ("Address output not expected");

    assert (writedata == 8'bx) $display("Data output: 8'bx");
    else $display ("Data output not expected");

    assert (writeenable == 1'bx) $display("Write enable output: 1'bx");
    else $display ("Write enable output not expected");

    assert (ready == 1'b1) $display("Ready output: 1'b1");
    else $display ("Ready output not expected");

    $display(" ");
    #4
    #1

    $display("testing loop state");
    assert (DUT.present_state == 3'b001) $display("Current state: `LOOP");
    else $display("Current state not expected");

    assert (DUT.next_state == 3'b001) $display("Next state: `LOOP");
    else $display ("Next state not expected");

    assert (DUT.counter_count == 1'b1) $display("Counter count signal: ENABLED");
    else $display ("Counter count signal not expected");

    assert (DUT.next_address == 8'b0) $display("Address driver: 8'b0");
    else $display ("Address driver not expected");

    assert (DUT.next_write_data == 8'b0) $display("Data driver: 8'b0");
    else $display ("Data driver not expected");

    assert (DUT.next_write_enable == 1'b1) $display("Write enable driver: 1'b1");
    else $display ("Write enable driver not expected");

    assert (address == 8'b0) $display("Address output: 8'b0");
    else $display ("Address output not expected");

    assert (writedata == 8'b0) $display("Data output: 8'b0");
    else $display ("Data output not expected");

    assert (writeenable == 1'b1) $display("Write enable output: 1'b1");
    else $display ("Write enable output not expected");

    assert (ready == 1'b0) $display("Ready output: 1'b0");
    else $display ("Ready output not expected");
    #9

    #2650
    $display(" ");
    $display("testing end state");
    assert (DUT.present_state == 3'b010) $display("Current state: `END");
    else $display("Current state not expected");
    
    assert (DUT.next_state == 3'b010) $display("Next state: `END");
    else $display ("Next state not expected");

    assert (DUT.counter_count == 1'b0) $display("Counter count signal: DISABLED");
    else $display ("Counter count signal not expected");

    assert (writeenable == 1'b0) $display("Write enable output: 1'b0");
    else $display ("Write enable output not expected");

    assert (ready == 1'b1) $display("Ready output: 1'b1");
    else $display ("Ready output not expected");





    $stop;

end

endmodule: tb_rtl_init
