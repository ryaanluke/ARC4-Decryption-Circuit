`define BEGIN 3'b000
`define FILL 3'b001
`define DONE 3'b010

module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic init_enable, init_rdy, init_wren;
    logic [7:0] init_addr, init_wrdata, s_mem_q;
    
    s_mem s(init_addr, CLOCK_50, init_wrdata, init_wren, s_mem_q);
    init init_instantiation(CLOCK_50, KEY[3], init_enable, init_rdy, init_addr, init_wrdata, init_wren);
    // your code here


    // state machine controlling event flow
    wire [2:0] present_state;
    logic [2:0] next_state;
    vDFF_async #3 STATE(CLOCK_50, KEY[3], next_state, `BEGIN, present_state);
    logic is_done;

    always@(*)
        begin
            case (present_state)
                `BEGIN: begin
                            if (init_rdy == 1'b1)
                                next_state = `FILL;
                            else
                                next_state = `BEGIN;
                        end             
                `FILL: begin
                            if (is_done == 1'b1)
                                next_state = `DONE;
                            else
                                next_state = `FILL;
                       end               
                `DONE: begin
                            next_state = `DONE;
                       end
                default: next_state = 3'bx;
            endcase       
        end


    always@(*)
        begin
            case (present_state)
                `BEGIN: begin
                            if (init_rdy == 1'b1)
                                init_enable = 1'b1;
                            else
                                init_enable = 1'b0;
                            is_done = 1'b0;
                        end
                
                `FILL: begin
                            if (init_rdy == 1'b1)
                                begin
                                    is_done = 1'b1;
                                    init_enable = 1'b0;
                                end
                            else
                                begin
                                    is_done = 1'b0;
                                    init_enable = 1'b0;
                                end
                       end

                `DONE: begin
                            is_done = 1'b1;
                            init_enable = 1'b0;
                       end

                default: begin 
                            init_enable = 1'bx;
                            is_done = 1'bx;
                         end
            endcase
        end


endmodule: task1
