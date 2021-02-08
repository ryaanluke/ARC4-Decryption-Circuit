`define T4_BEGIN 2'd0
`define T4_CRACK 2'd1
`define T4_DONE 2'd2


module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic [7:0] ct_addr, ct_rddata, ct_wrdata;
    logic crack_enable, crack_ready, crack_done;
    logic [23:0] crack_key;
    logic crack_key_valid;

    ct_mem ct(ct_addr, CLOCK_50, ct_wrdata, 1'b0, ct_rddata);
    crack c(CLOCK_50, KEY[3], crack_enable, crack_ready, crack_key, crack_key_valid, ct_addr, ct_rddata);

    // your code here
    wire [1:0] present_state;
    logic [1:0] next_state;
    vDFF_async #2 STATE(CLOCK_50, KEY[3], next_state, `T4_BEGIN, present_state);

    always@(*)
        begin
            case (present_state)
                `T4_BEGIN: begin
                            if (crack_ready == 1'b1)
                                next_state = `T4_CRACK;
                            else
                                next_state = `T4_BEGIN;
                            end
                
                `T4_CRACK: begin
                            if (crack_done == 1'b1)
                                next_state = `T4_DONE;
                            else
                                next_state = `T4_CRACK;
                            end
                
                `T4_DONE: begin
                            next_state = `T4_DONE;
                          end
                default: next_state = 2'bx;
            endcase
        end

    always@(*)
        begin
            case (present_state)
                `T4_BEGIN: begin
                                if (crack_ready == 1'b1)
                                    crack_enable = 1'b1;
                                else
                                    crack_enable = 1'b0;
                                crack_done = 1'b0;

                                HEX0 = 7'b1111111;
                                HEX1 = 7'b1111111;
                                HEX2 = 7'b1111111;
                                HEX3 = 7'b1111111;
                                HEX4 = 7'b1111111;
                                HEX5 = 7'b1111111;
                           end
                `T4_CRACK: begin
                                if (crack_ready == 1'b1)
                                    crack_done = 1'b1;
                                else
                                    crack_done = 1'b0;
                                crack_enable = 1'b0;

                                HEX0 = 7'b1111111;
                                HEX1 = 7'b1111111;
                                HEX2 = 7'b1111111;
                                HEX3 = 7'b1111111;
                                HEX4 = 7'b1111111;
                                HEX5 = 7'b1111111;
                          end
                `T4_CRACK: begin
                                crack_done = 1'b1;
                                crack_enable = 1'b0;

                                if (crack_key_valid == 1'b0) // dashes for invalid key
                                    begin
                                        HEX0 = 7'b0111111;
                                        HEX1 = 7'b0111111;
                                        HEX2 = 7'b0111111;
                                        HEX3 = 7'b0111111;
                                        HEX4 = 7'b0111111;
                                        HEX5 = 7'b0111111;
                                    end
                                else
                                    begin
                                        case(crack_key[3:0])
                                            4'd0: HEX0 = 7'd1000000; 
                                            4'd1: HEX0 = 7'b1111001;
                                            4'd2: HEX0 = 7'b0100100;
                                            4'd3: HEX0 = 7'b0110000;
                                            4'd4: HEX0 = 7'b0011001;
                                            4'd5: HEX0 = 7'b0010010;
                                            4'd6: HEX0 = 7'b0000010;
                                            4'd7: HEX0 = 7'b1111000;
                                            4'd8: HEX0 = 7'b0000000;
                                            4'd9: HEX0 = 7'b0010000;
                                            4'd10: HEX0 = 7'b0001000; // A
                                            4'd11: HEX0 = 7'b0000011; // b
                                            4'd12: HEX0 = 7'b1000110; // C
                                            4'd13: HEX0 = 7'b0100001; // d
                                            4'd14: HEX0 = 7'b0000110; // E
                                            4'd15: HEX0 = 7'b0001110; // F
                                            default: HEX0 = 7'bx;
                                        endcase

                                        case(crack_key[7:4])
                                            4'd0: HEX1 = 7'd1000000; 
                                            4'd1: HEX1 = 7'b1111001;
                                            4'd2: HEX1 = 7'b0100100;
                                            4'd3: HEX1 = 7'b0110000;
                                            4'd4: HEX1 = 7'b0011001;
                                            4'd5: HEX1 = 7'b0010010;
                                            4'd6: HEX1 = 7'b0000010;
                                            4'd7: HEX1 = 7'b1111000;
                                            4'd8: HEX1 = 7'b0000000;
                                            4'd9: HEX1 = 7'b0010000;
                                            4'd10: HEX1 = 7'b0001000; // A
                                            4'd11: HEX1 = 7'b0000011; // b
                                            4'd12: HEX1 = 7'b1000110; // C
                                            4'd13: HEX1 = 7'b0100001; // d
                                            4'd14: HEX1 = 7'b0000110; // E
                                            4'd15: HEX1 = 7'b0001110; // F
                                            default: HEX1 = 7'bx;
                                        endcase

                                        case(crack_key[11:8])
                                            4'd0: HEX2 = 7'd1000000; 
                                            4'd1: HEX2 = 7'b1111001;
                                            4'd2: HEX2 = 7'b0100100;
                                            4'd3: HEX2 = 7'b0110000;
                                            4'd4: HEX2 = 7'b0011001;
                                            4'd5: HEX2 = 7'b0010010;
                                            4'd6: HEX2 = 7'b0000010;
                                            4'd7: HEX2 = 7'b1111000;
                                            4'd8: HEX2 = 7'b0000000;
                                            4'd9: HEX2 = 7'b0010000;
                                            4'd10: HEX2 = 7'b0001000; // A
                                            4'd11: HEX2 = 7'b0000011; // b
                                            4'd12: HEX2 = 7'b1000110; // C
                                            4'd13: HEX2 = 7'b0100001; // d
                                            4'd14: HEX2 = 7'b0000110; // E
                                            4'd15: HEX2 = 7'b0001110; // F
                                            default: HEX2 = 7'bx;
                                        endcase

                                        case(crack_key[15:12])
                                            4'd0: HEX3 = 7'd1000000; 
                                            4'd1: HEX3 = 7'b1111001;
                                            4'd2: HEX3 = 7'b0100100;
                                            4'd3: HEX3 = 7'b0110000;
                                            4'd4: HEX3 = 7'b0011001;
                                            4'd5: HEX3 = 7'b0010010;
                                            4'd6: HEX3 = 7'b0000010;
                                            4'd7: HEX3 = 7'b1111000;
                                            4'd8: HEX3 = 7'b0000000;
                                            4'd9: HEX3 = 7'b0010000;
                                            4'd10: HEX3 = 7'b0001000; // A
                                            4'd11: HEX3 = 7'b0000011; // b
                                            4'd12: HEX3 = 7'b1000110; // C
                                            4'd13: HEX3 = 7'b0100001; // d
                                            4'd14: HEX3 = 7'b0000110; // E
                                            4'd15: HEX3 = 7'b0001110; // F
                                            default: HEX3 = 7'bx;
                                        endcase

                                        case(crack_key[19:16])
                                            4'd0: HEX4 = 7'd1000000; 
                                            4'd1: HEX4 = 7'b1111001;
                                            4'd2: HEX4 = 7'b0100100;
                                            4'd3: HEX4 = 7'b0110000;
                                            4'd4: HEX4 = 7'b0011001;
                                            4'd5: HEX4 = 7'b0010010;
                                            4'd6: HEX4 = 7'b0000010;
                                            4'd7: HEX4 = 7'b1111000;
                                            4'd8: HEX4 = 7'b0000000;
                                            4'd9: HEX4 = 7'b0010000;
                                            4'd10: HEX4 = 7'b0001000; // A
                                            4'd11: HEX4 = 7'b0000011; // b
                                            4'd12: HEX4 = 7'b1000110; // C
                                            4'd13: HEX4 = 7'b0100001; // d
                                            4'd14: HEX4 = 7'b0000110; // E
                                            4'd15: HEX4 = 7'b0001110; // F
                                            default: HEX4 = 7'bx;
                                        endcase

                                        case(crack_key[23:20])
                                            4'd0: HEX5 = 7'd1000000; 
                                            4'd1: HEX5 = 7'b1111001;
                                            4'd2: HEX5 = 7'b0100100;
                                            4'd3: HEX5 = 7'b0110000;
                                            4'd4: HEX5 = 7'b0011001;
                                            4'd5: HEX5 = 7'b0010010;
                                            4'd6: HEX5 = 7'b0000010;
                                            4'd7: HEX5 = 7'b1111000;
                                            4'd8: HEX5 = 7'b0000000;
                                            4'd9: HEX5 = 7'b0010000;
                                            4'd10: HEX5 = 7'b0001000; // A
                                            4'd11: HEX5 = 7'b0000011; // b
                                            4'd12: HEX5 = 7'b1000110; // C
                                            4'd13: HEX5 = 7'b0100001; // d
                                            4'd14: HEX5 = 7'b0000110; // E
                                            4'd15: HEX5 = 7'b0001110; // F
                                            default: HEX5 = 7'bx;
                                        endcase

                                    end
                          end
                default: {crack_done, crack_enable} = 2'bxx;
            endcase
        end



endmodule: task4
