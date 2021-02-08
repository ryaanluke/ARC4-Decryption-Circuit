`define BEGIN 3'b000
`define FILL 3'b001
`define KEYSCHED 3'b010 
`define PRGA 3'b011
`define DONE 3'b100

module arc4(input logic clk, 
            input logic rst_n,
            input logic en, 
            output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, 
            input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, 
            input logic [7:0] pt_rddata, 
            output logic [7:0] pt_wrdata, 
            output logic pt_wren);

    // your code here

    logic init_enable, init_rdy, init_wren, ksa_enable, ksa_rdy, ksa_wren;
    logic prga_enable, prga_rdy, prga_wren;
    logic [7:0] init_addr, init_wrdata, ksa_addr, ksa_wrdata, ksa_rddata;
    logic [7:0] prga_addr, prga_wrdata, prga_rddata;

    logic [7:0] memory_addr, memory_data, memory_rddata;
    logic memory_enable; 
    logic [16:0] memorybits;

    assign ksa_rddata = memory_rddata;
    assign prga_rddata = memory_rddata;

    s_mem s(memory_addr, clk, memory_data, memory_enable, memory_rddata);
    init i(clk, rst_n, init_enable, init_rdy, init_addr, init_wrdata, init_wren);
    ksa k(clk, rst_n, ksa_enable, ksa_rdy, key, ksa_addr, ksa_rddata, ksa_wrdata, ksa_wren);
    prga p(clk, rst_n, prga_enable, prga_rdy, key, prga_addr, prga_rddata, prga_wrdata, prga_wren, ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata, pt_wren);

    // your code here
    wire [2:0] present_state;
    logic [2:0] next_state;
    vDFF_async #3 STATE(clk, rst_n, next_state, `BEGIN, present_state);
    logic fill_done, ksa_done, prga_done;

    always@(*)
        begin
            case (present_state)
                `BEGIN : memorybits = 17'bx;
                `FILL : memorybits = {init_addr, init_wrdata, init_wren};
                `KEYSCHED : memorybits = {ksa_addr, ksa_wrdata, ksa_wren};
                `PRGA : memorybits = {prga_addr, prga_wrdata, prga_wren};
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
                                    next_state = `PRGA;
                                else
                                    next_state = `KEYSCHED;
                           end
                `PRGA: begin
                            if (prga_done == 1'b1)
                                next_state = `DONE;
                            else 
                                next_state = `PRGA;
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
                            prga_done = 1'b0;
                            prga_enable = 1'b0;
                            rdy = 1'b1;
                        end

                `FILL: begin
                            if (init_rdy == 1'b1)
                                begin
                                    fill_done = 1'b1;
                                    init_enable = 1'b0;
                                    ksa_enable = 1'b1;
                                    prga_done = 1'b0;
                                    prga_enable = 1'b0;
                                end
                            else
                                begin
                                    fill_done = 1'b0;
                                    init_enable = 1'b0;
                                    ksa_enable = 1'b0;
                                    prga_done = 1'b0;
                                    prga_enable = 1'b0;
                                end
                            ksa_done = 1'b0;
                            rdy = 1'b0;
                       end
                
                `KEYSCHED: begin
                                if (ksa_rdy == 1'b1)
                                    begin
                                        ksa_done = 1'b1;
                                        ksa_enable = 1'b0;
                                        prga_done = 1'b0;
                                        prga_enable = 1'b1;
                                    end
                                else
                                    begin
                                        ksa_done = 1'b0;
                                        ksa_enable = 1'b0;
                                        prga_done = 1'b0;
                                        prga_enable = 1'b0;
                                    end
                                fill_done = 1'b1;
                                init_enable = 1'b0;
                                rdy = 1'b0;
                           end
                `PRGA: begin
                            if (prga_rdy == 1'b1)
                                begin
                                    prga_done = 1'b1;
                                    prga_enable = 1'b0;
                                end
                            else 
                                begin
                                    prga_done = 1'b0;
                                    prga_enable = 1'b0;
                                end
                            fill_done = 1'b1;
                            init_enable = 1'b0;
                            ksa_done = 1'b1;
                            ksa_enable = 1'b0;
                            rdy = 1'b0;
                       end

                `DONE: begin
                            init_enable = 1'b0;
                            ksa_enable = 1'b0;
                            fill_done = 1'b1;
                            ksa_done = 1'b1;
                            prga_done = 1'b1;
                            prga_enable = 1'b0;
                            rdy = 1'b1;
                       end

                default: begin
                            init_enable = 1'bx;
                            ksa_enable = 1'bx;
                            fill_done = 1'bx;
                            ksa_done = 1'bx;
                            prga_done = 1'bx;
                            prga_enable = 1'bx;
                            rdy = 1'bx;
                         end
            endcase
        end


endmodule: arc4
