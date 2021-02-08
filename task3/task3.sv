`define T3_BEGIN 2'b00
`define T3_ARC4 2'b01 
`define T3_DONE 2'b10

module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here


    logic [7:0] ct_addr, ct_rddata, ct_wrdata, pt_addr, pt_rddata, pt_wrdata;
    logic pt_wren;
    logic arc4_enable, arc4_rdy, arc4_done;

    ct_mem ct(ct_addr, CLOCK_50, ct_wrdata, 1'b0, ct_rddata);
    pt_mem pt(pt_addr, CLOCK_50, pt_wrdata, pt_wren, pt_rddata);
    arc4 a4(CLOCK_50, KEY[3], arc4_enable, arc4_rdy, {14'b0, SW[9:0]}, ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata, pt_wren);

    // your code here

    wire [1:0] present_state;
    logic [1:0] next_state;
    vDFF_async #2 STATE(CLOCK_50, KEY[3], next_state, `T3_BEGIN, present_state);

    always@(*)
        begin
            case (present_state)
                `T3_BEGIN: begin
                            if (arc4_rdy == 1'b1)
                                next_state = `T3_ARC4;
                            else
                                next_state = `T3_BEGIN;
                        end
                
                `T3_ARC4: begin
                            if (arc4_done == 1'b1)
                                next_state = `T3_DONE;
                            else
                                next_state = `T3_ARC4;
                       end
                
                `T3_DONE: begin
                            next_state = `T3_DONE;
                       end
                default: next_state = 2'bx;
            endcase
        end
    
    always@(*)
        begin
            case (present_state)
                `T3_BEGIN: begin
                                if (arc4_rdy == 1'b1)
                                    arc4_enable = 1'b1;
                                else
                                    arc4_enable = 1'b0;
                                arc4_done = 1'b0;
                           end
                `T3_ARC4: begin
                                if (arc4_rdy == 1'b1)
                                    arc4_done = 1'b1;
                                else
                                    arc4_done = 1'b0;
                                arc4_enable = 1'b0;
                          end
                `T3_DONE: begin
                                arc4_done = 1'b1;
                                arc4_enable = 1'b0;
                          end
                default: {arc4_done, arc4_enable} = 2'bxx;
            endcase
        end

    

endmodule: task3
