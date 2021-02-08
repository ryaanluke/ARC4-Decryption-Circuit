`define BEGIN 3'b000
`define FILL 3'b001
`define KEYSCHED 3'b010
`define DONE 3'b011

module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);
    
    logic init_enable, init_rdy, init_wren, ksa_enable, ksa_rdy, ksa_wren;
    logic [7:0] init_addr, init_wrdata, ksa_addr, ksa_wrdata, ksa_rddata;
    
    logic [7:0] memory_addr, memory_data, memory_rddata;
    logic memory_enable; 
    logic [16:0] memorybits;

    assign ksa_rddata = memory_rddata;
    
    s_mem s(memory_addr, CLOCK_50, memory_data, memory_enable, memory_rddata);
    init init_initialization(CLOCK_50, KEY[3], init_enable, init_rdy, init_addr, init_wrdata, init_wren);
    ksa ksa_initialization(CLOCK_50, KEY[3], ksa_enable, ksa_rdy, {14'b0,SW[9:0]}, ksa_addr, ksa_rddata, ksa_wrdata, ksa_wren);

    // your code here

    wire [2:0] present_state;
    logic [2:0] next_state;
    vDFF_async #3 STATE(CLOCK_50, KEY[3], next_state, `BEGIN, present_state);
    logic fill_done, ksa_done;

    // controlling memory flow
    always@(*)
        begin
            case (present_state)
                `BEGIN : memorybits = 17'bx;
                `FILL : memorybits = {init_addr, init_wrdata, init_wren};
                `KEYSCHED : memorybits = {ksa_addr, ksa_wrdata, ksa_wren};
                `DONE : memorybits = 17'bx;
                default : memorybits = 17'bx;
            endcase
        end
    assign {memory_addr, memory_data, memory_enable} = memorybits;
    
    // controlling event flow
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
                            if (fill_done == 1'b1)
                                next_state = `KEYSCHED;
                            else
                                next_state = `FILL;
                       end
                
                `KEYSCHED: begin
                                if (ksa_done == 1'b1)
                                    next_state = `DONE;
                                else
                                    next_state = `KEYSCHED;
                           end
                `DONE: begin
                            next_state = `DONE;
                       end
                default: next_state = 3'bx;
            endcase
        end

    // controlling enable signal flow 
    always@(*)
        begin
            case (present_state)
                `BEGIN: begin
                            if (init_rdy == 1'b1)
                                init_enable = 1'b1;
                            else
                                init_enable = 1'b0;
                            fill_done = 1'b0;
                            ksa_done = 1'b0;
                            ksa_enable = 1'b0;
                        end

                `FILL: begin
                            if (init_rdy == 1'b1)
                                begin
                                    fill_done = 1'b1;
                                    init_enable = 1'b0;
                                    ksa_enable = 1'b1;
                                end
                            else
                                begin
                                    fill_done = 1'b0;
                                    init_enable = 1'b0;
                                    ksa_enable = 1'b0;
                                end
                            ksa_done = 1'b0;
                       end
                
                `KEYSCHED: begin
                                if (ksa_rdy == 1'b1)
                                    begin
                                        ksa_done = 1'b1;
                                        ksa_enable = 1'b0;
                                    end
                                else
                                    begin
                                        ksa_done = 1'b0;
                                        ksa_enable = 1'b0;
                                    end
                                fill_done = 1'b1;
                                init_enable = 1'b0;
                           end
                `DONE: begin
                            init_enable = 1'b0;
                            ksa_enable = 1'b0;
                            fill_done = 1'b1;
                            ksa_done = 1'b1;
                       end
                default: begin
                            init_enable = 1'bx;
                            ksa_enable = 1'bx;
                            fill_done = 1'bx;
                            ksa_done = 1'bx;
                         end
            endcase
        end

endmodule: task2
