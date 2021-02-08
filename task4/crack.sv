`define SW_CRACK 13
`define RESET_CRACK 5'd0
`define RDY_CRACK 5'd1
`define RDY_DEASSERT_CRACK 5'd2
`define READ_MESSAGE_LENGTH_CT 5'd3
`define READ_MESSAGE_LENGTH_CT_WAIT 5'd4
`define WRITE_MESSAGE_LENGTH_PT 5'd5
`define START_KEY_COUNTER 5'd6
`define INCREMENT_KEY_COUNTER 5'd7
`define CHECK_KEY_COUNTER 5'd8
`define SET_NEXT_KEY 5'd9
`define SET_EN_A4 5'd10
`define WAIT_A4 5'd11
`define DONE_A4 5'd12
`define START_KEY_CHECK 5'd13
`define CHECK_KEY_LOOP 5'd14
`define READ_PT 5'd15
`define READ_PT_WAIT 5'd16
`define CHECK_KEY_VALID 5'd17
`define INCREMENT_MESSAGE_COUNT 5'd18
`define KEY_NOT_VALID 5'd19
`define KEY_VALID 5'd20
`define SET_OUTPUT_KEY 5'd21
`define CRACK_DONE 5'd22
`define GET_PT_ADDRESS 5'd23
`define GET_PT 5'd24

module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    logic [7:0] pt_addr, pt_addr_a4, pt_addr_crack;
    logic [7:0] pt_rddata, pt_wrdata, current_pt_data;
    logic pt_wren, pt_wren_a4, pt_wren_crack;
    logic [1:0] pt_control, ct_control;

    logic [7:0] ct_addr_a4;

    logic a4_en, a4_rdy, set_en_a4;

    logic [7:0] message_count, message_length;
    logic read_message_length, write_message_length;
    logic message_counter_done, start_message_counter, increment_message_count;
    logic pt_valid, read_pt;

    logic [23:0] next_key, current_key;
    logic key_counter_done, start_key_counter, increment_key_count, set_next_key, set_output_key;
    logic set_key_valid;

    crack_statemachine c_sm(.clk(clk), .rst_n(rst_n), .en(en), .key_counter_done(key_counter_done), .message_counter_done(message_counter_done), .a4_rdy(a4_rdy), .a4_en(a4_en), 
                            .pt_valid(pt_valid), .rdy(rdy), .read_message_length(read_message_length), .start_key_counter(start_key_counter),
                            .increment_key_count(increment_key_count), .set_next_key(set_next_key), .set_en_a4(set_en_a4), .start_message_counter(start_message_counter),
                            .read_pt(read_pt), .increment_message_count(increment_message_count),
                            .set_output_key(set_output_key), .set_key_valid(set_key_valid), .pt_control(pt_control), .ct_control(ct_control));


    pt_mem pt(.clock(clk), .address(pt_addr), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata));

    arc4 a4(.clk(clk), .rst_n(rst_n), .en(a4_en), .rdy(a4_rdy), .key(current_key), 
            .ct_addr(ct_addr_a4), .ct_rddata(ct_rddata), 
            .pt_addr(pt_addr_a4), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren_a4));

    counter_24 key_counter(.clk(clk), .rst_n(rst_n), .increment(increment_key_count), .start_counter(start_key_counter), .next_count(next_key));

    counter_8 message_counter(.clk(clk), .rst_n(rst_n), .increment(increment_message_count), .start_counter(start_message_counter), .next_count(message_count));

    always_ff @(posedge clk)
        if (read_message_length == 1)
            message_length <= ct_rddata;
        else
            message_length <= message_length;
            
    always_comb
        if (pt_control == 2'b01) begin
            pt_wren <= pt_wren_a4;
            pt_addr <= pt_addr_a4;
        end
        else if (pt_control == 2'b10) begin
            pt_wren <= pt_wren_crack;
            pt_addr <= pt_addr_crack;
        end
        else begin
            pt_wren <= 1'bx;
            pt_addr <= 8'bxxxx_xxxx;
        end
    
    always_comb
        if (ct_control == 2'b01) begin
            ct_addr <= ct_addr_a4;
        end
        else if (ct_control == 2'b10) begin
            ct_addr <= 8'd0;
        end
        else begin
            ct_addr <= 8'bxxxx_xxxx;
        end

    always_comb 
        if (set_en_a4 == 1) begin
            if (a4_rdy == 1)
                a4_en <= 1;
            else 
                a4_en <= 0;
        end
        else
            a4_en <= 0;

    always_ff @(posedge clk)
        if (read_pt == 1) begin
            current_pt_data <= pt_rddata;
            pt_addr_crack <= message_count;
            pt_wren_crack <= 0;
        end
        else begin
            current_pt_data <= current_pt_data;
            pt_addr_crack <= message_count;
            pt_wren_crack <= pt_wren;
        end
        
    always_ff @(posedge clk)
        if ($signed(current_pt_data) >= 8'h20 && $signed(current_pt_data) <= 8'h7E)
            pt_valid <= 1;
        else 
            pt_valid <= 0;

    assign message_counter_done = (message_count == message_length + 8'd1) ? 1 : 0;

    assign key_counter_done = (current_key == 24'hFFFFFF) ? 1 : 0;

    always_ff @(posedge clk)
        if (set_next_key == 1)
            current_key <= next_key;
        else
            current_key <= current_key;
    
    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 0)
            key_valid <= 0;
        else if (set_key_valid == 1)
            key_valid <= 1;
        else 
            key_valid <= key_valid;
    
    always_ff @(posedge clk)
        if (set_output_key == 1)
            key <= current_key;
        else
            key <= key;

endmodule: crack


module crack_statemachine(input logic clk, input logic rst_n, input logic en, input logic key_counter_done, input logic message_counter_done, input logic a4_en,
                          input logic a4_rdy, input logic pt_valid,
                          output logic rdy, output logic read_message_length, 
                          output logic start_key_counter, output logic increment_key_count, output logic set_next_key, 
                          output logic set_en_a4, output logic start_message_counter, output logic read_pt, output logic [1:0] pt_control, output logic [1:0] ct_control, output logic increment_message_count,
                          output logic set_output_key, output logic set_key_valid);

    logic [`SW_CRACK - 1:0] present_state, next_state; 
    logic [`SW_CRACK + 14:0] next;

    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 0)
            present_state = `RESET_CRACK;
        else 
            present_state = next_state;

    always_comb
        case (present_state)
            `RESET_CRACK : next = {`READ_MESSAGE_LENGTH_CT, 15'b000_000_000_00_00_00};
            `READ_MESSAGE_LENGTH_CT : next = {`READ_MESSAGE_LENGTH_CT_WAIT, 15'b010_000_000_00_00_10};
            `READ_MESSAGE_LENGTH_CT_WAIT : next = {`RDY_CRACK, 15'b010_000_000_00_00_10};
            `RDY_CRACK : begin
                if (en == 1)
                    next = {`RDY_DEASSERT_CRACK, 15'b100_000_000_00_00_00};
                else 
                    next = {`RDY_CRACK, 15'b100_000_000_00_00_00};
            end
            `RDY_DEASSERT_CRACK : next = {`START_KEY_COUNTER, 15'b000_000_000_00_00_00};
            `START_KEY_COUNTER : next = {`SET_NEXT_KEY, 15'b001_000_000_00_00_00}; // START KEY COUNTER HERE
            `INCREMENT_KEY_COUNTER : next = {`CHECK_KEY_COUNTER, 15'b000_100_000_00_00_00};
            `CHECK_KEY_COUNTER : begin
                if (key_counter_done == 1)
                    next = {`CRACK_DONE, 15'b000_000_000_00_00_00};
                else 
                    next = {`SET_NEXT_KEY, 15'b000_000_000_00_00_00};
            end
            `SET_NEXT_KEY : next = {`SET_EN_A4, 15'b000_010_000_00_00_00};
            `SET_EN_A4 : begin
                if (a4_en == 1'b1)
                    next = {`WAIT_A4, 15'b000_001_000_00_01_01};
                else 
                    next = {`SET_EN_A4, 15'b000_001_000_00_01_01};
            end
            `WAIT_A4 : begin
                if (a4_rdy == 1)
                    next = {`DONE_A4, 15'b000_000_000_00_01_01};
                else 
                    next = {`WAIT_A4, 15'b000_000_000_00_01_01};
            end
            `DONE_A4 : next = {`START_KEY_CHECK, 15'b000_000_000_00_01_01}; 
            `START_KEY_CHECK : next = {`INCREMENT_MESSAGE_COUNT, 15'b000_000_100_00_00_00}; // START MESSAGE COUNTER HERE 
            `CHECK_KEY_LOOP : begin
                if (message_counter_done == 1)
                    next = {`KEY_VALID, 15'b000_000_000_00_10_00};
                else
                    next = {`GET_PT_ADDRESS, 15'b000_000_000_00_10_00};
            end
            `GET_PT_ADDRESS : next = {`READ_PT, 15'b000_000_010_00_10_00};
            `READ_PT : next = {`READ_PT_WAIT, 15'b000_000_010_00_10_00};
            `READ_PT_WAIT : next = {`GET_PT, 15'b000_000_010_00_10_00};
            `GET_PT : next = {`CHECK_KEY_VALID, 15'b000_000_010_00_10_00};
            `CHECK_KEY_VALID : begin
                if (pt_valid == 1)
                    next = {`INCREMENT_MESSAGE_COUNT, 15'b000_000_000_00_10_00};
                else 
                    next = {`KEY_NOT_VALID, 15'b000_000_000_00_10_00};
            end
            `INCREMENT_MESSAGE_COUNT : next = {`CHECK_KEY_LOOP, 15'b000_000_001_00_10_00};
            `KEY_NOT_VALID : next = {`INCREMENT_KEY_COUNTER, 15'b000_000_000_00_10_00};
            `KEY_VALID : next = {`SET_OUTPUT_KEY, 15'b000_000_000_10_10_00};
            `SET_OUTPUT_KEY : next = {`CRACK_DONE, 15'b000_000_000_01_00_00};
            `CRACK_DONE : next = {`CRACK_DONE, 15'b100_000_000_00_00_00};
            default : next = {`RESET_CRACK, 15'bxxx_xxx_xxx_xx_xx_xx};
        endcase

    assign {next_state, rdy, read_message_length, start_key_counter, increment_key_count, set_next_key, set_en_a4, start_message_counter, read_pt, increment_message_count, set_key_valid, set_output_key, pt_control, ct_control} = next;

endmodule : crack_statemachine

module counter_24(input logic clk, input logic rst_n, input logic start_counter, input logic increment, output logic [23:0] next_count);
    logic [23:0] count;

    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 1'b0)
            count <= 24'd0;
        else if (start_counter == 1'b1)
            count <= 24'd0;
        else if (increment == 1'b1)
            count <= count + 24'd1;
        else 
            count <= count; 
    
    assign next_count = count; 
endmodule

module counter_8(input logic clk, input logic rst_n, input logic start_counter, input logic increment, output logic [7:0] next_count);
    logic [7:0] count;

    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 1'b0)
            count <= 8'd0;
        else if (start_counter == 1'b1)
            count <= 8'd0;
        else if (increment == 1'b1)
            count <= count + 8'd1;
        else 
            count <= count; 
    
    assign next_count = count; 
endmodule



