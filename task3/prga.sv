`define SW_3 6
`define RESET_4 6'd0
`define RDY_3 6'd1
`define RDY_DEASSERT_3 6'd2
`define GET_MESSAGE_LENGTH_ADDRESS 6'd3
`define READ_MESSAGE_LENGTH 6'd4
`define READ_MESSAGE_LENGTH_WAIT 6'd5 
`define GET_MESSAGE_ADDRESS 6'd6
`define WRITE_MESSAGE_LENGTH 6'd7
`define START_LOOP 6'd8
`define INCREMENT_K 6'd9 
`define INCREMENT_I 6'd10
`define GET_I_ADDRESS 6'd11
`define READ_I 6'd12
`define READ_I_WAIT 6'd13
`define GET_I 6'd14 
`define INCREMENT_J 6'd15 
`define GET_J_ADDRESS 6'd16
`define READ_J 6'd17
`define READ_J_WAIT 6'd18
`define GET_J 6'd19
`define SWAP_S_I 6'd20
`define SWAP_S_J 6'd21
`define CALC_PAD_INDEX 6'd22
`define CALC_PAD_INDEX_WAIT 6'd23
`define GET_PAD_ADDRESS 6'd24
`define READ_PAD 6'd25
`define READ_PAD_WAIT 6'd26
`define GET_PAD 6'd27
`define GET_CIPHER_ADDRESS 6'd28
`define READ_CIPHER 6'd29
`define READ_CIPHER_WAIT 6'd30
`define GET_CIPHER 6'd31
`define UPDATE_PLAINTEXT 6'd32
`define DONE_3 6'd33



module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,

            output logic [7:0] s_addr, 
            input logic [7:0] s_rddata, 
            output logic [7:0] s_wrdata, 
            output logic s_wren,

            output logic [7:0] ct_addr, 
            input logic [7:0] ct_rddata,

            output logic [7:0] pt_addr,  
            input logic [7:0] pt_rddata, 
            output logic [7:0] pt_wrdata, 
            output logic pt_wren);

    // your code here
    /*
    logic read_message_length, increment_i, increment_j, increment_k, read_s_i, read_s_j, read_pad, read_cipher, swap_i, swap_j, calc_pad_index, update_plaintext, start_counter, write_message_length;
    logic [8:0] j, i_count, k, pad_index;
    logic [7:0] s_i, s_j, pad_k, cipher_k, message_length;
    */

    logic loop_condition;
    logic read_message_length, write_message_length;
    logic [7:0] message_length;

    logic [7:0] pad_index;
    logic [7:0] i_count, j_count, k_count;
    logic increment_i, increment_j, increment_k;

    logic [7:0] s_i, s_j, s_pad;
    logic [7:0] ciphertext_k;

    logic swap_i, swap_j;
    logic read_s_i, read_s_j, read_pad, read_cipher;

    logic calc_pad_index, update_plaintext;

    logic start_counter;

    assign loop_condition = (k_count == message_length) ? 1 : 0;

    /*
    logic loop_condition;
    assign loop_condition = pad_index == (message_length + 1) ? 1 : 0;
    */

    counter_8_2 k_counter(.clk(clk), .rst_n(rst_n), .increment(increment_k), 
                          .start_counter(start_counter), .next_count(k_count));


    /*
    // controlling i 
    always_ff @(posedge clk or negedge rst_n)
        if (rst_n == 1'b0)
            i_count = 9'd0;
        else if (start_counter == 1'b1)
            i_count = 9'd0;
        else if (increment_i == 1'b1)
            i_count = (i_count + 1) % 9'd256;
        else
            i_count = i_count;
    
    // controlling j 
    always_ff @(posedge clk or negedge rst_n)
        if (rst_n == 1'b0)
            j = 9'd0;
        else if (start_counter == 1'b1)
            j = 9'd0;
        else if (increment_j == 1'b1)
            j = (j + {1'b0, s_i}) % 9'd256; 
        else 
            j = j;
    
    // controlling pad index
    always_ff @(posedge clk or negedge rst_n)
        if (rst_n == 1'b0)
            pad_index = 9'd0;
        else if (start_counter == 1'b0)
            pad_index = 9'd0;
        else if (increment_k == 1'b1)
            pad_index = pad_index + 1;
        else 
            pad_index = pad_index;

    // controlling most ouputs
    always_ff @(*)
        if (read_message_length == 1'b1) begin
            ct_addr = 8'h00;
            message_length = ct_rddata; // message length is 9 bits long

            s_addr = s_addr;
            s_wren = s_wren;
            s_wrdata = s_wrdata;
            s_i = s_i;
            s_j = s_j;

            pad_k = pad_k;
            cipher_k = cipher_k;
            
            pt_addr = pt_addr;
            pt_wrdata = pt_wrdata;
            pt_wren = pt_wren;
            
        end

        else if (read_s_i == 1'b1) begin
            ct_addr = ct_addr;
            message_length = message_length;

            s_addr = i_count[7:0];
            s_wren = 1'b0;
            s_wrdata = s_wrdata;
            s_i = s_rddata;
            s_j = s_j;

            pad_k = pad_k;
            cipher_k = cipher_k;
            
            pt_addr = pt_addr;
            pt_wrdata = pt_wrdata;
            pt_wren = pt_wren;
            
        end

        else if (read_s_j == 1'b1) begin
            ct_addr = ct_addr;
            message_length = message_length;

            s_addr = j[7:0];
            s_wren = 1'b0;
            s_wrdata = s_wrdata;
            s_j = s_rddata;
            s_i = s_i;

            pad_k = pad_k;
            cipher_k = cipher_k;
            
            pt_addr = pt_addr;
            pt_wrdata = pt_wrdata;
            pt_wren = pt_wren;
            
        end

        else if (swap_i == 1'b1) begin
            ct_addr = ct_addr;;
            message_length = message_length;

            s_addr = i_count[7:0];
            s_wrdata = s_j;
            s_wren = 1'b1;
            s_i = s_i;
            s_j = s_j;

            pad_k = pad_k;
            cipher_k = cipher_k;
            
            pt_addr = pt_addr;
            pt_wrdata = pt_wrdata;
            pt_wren = pt_wren;
            
        end

        else if (swap_j == 1'b1) begin
            ct_addr = ct_addr;
            message_length = message_length;

            s_addr = j[7:0];
            s_wrdata = s_i;
            s_wren = 1'b1;
            s_i = s_i;
            s_j = s_j;

            pad_k = pad_k;
            cipher_k = cipher_k;
            
            pt_addr = pt_addr;
            pt_wrdata = pt_wrdata;
            pt_wren = pt_wren;
            
        end

        else if (calc_pad_index == 1'b1) begin
            ct_addr = ct_addr;
            message_length = message_length;

            s_addr = (s_i + s_j)% 8'd256;
            s_wrdata = 8'bx;
            s_wren = 1'b0;
            s_i = s_i;
            s_j = s_j;

            pad_k = pad_k;
            cipher_k = cipher_k;
            
            pt_addr = pt_addr;
            pt_wrdata = pt_wrdata;
            pt_wren = pt_wren;
            
        end

        else if (read_pad == 1'b1) begin
            ct_addr = pad_index[7:0]; 
            message_length = message_length;

            s_addr = s_addr;
            s_wrdata = s_wrdata;
            s_wren = s_wren;
            s_i = s_i;
            s_j = s_j;

            pad_k = s_rddata;
            cipher_k = cipher_k;
            
            pt_addr = pt_addr;
            pt_wrdata = pt_wrdata;
            pt_wren = pt_wren;
            

        end

        else if (read_cipher == 1'b1) begin
            ct_addr = pad_index[7:0];
            message_length = message_length;

            s_addr = s_addr;
            s_wrdata = s_wrdata;
            s_wren = s_wren;
            s_i = s_i;
            s_j = s_j;

            pad_k = s_rddata;
            cipher_k = ct_rddata;
            
            pt_addr = pt_addr;
            pt_wrdata = pt_wrdata;
            pt_wren = pt_wren;
            
        end

        else if (update_plaintext == 1'b1) begin
            ct_addr = ct_addr;
            message_length = message_length;

            s_addr = s_addr;
            s_wrdata = s_wrdata;
            s_wren = s_wren;
            s_i = s_i;
            s_j = s_j;

            pad_k = pad_k;
            cipher_k = cipher_k;

            pt_addr = pad_index;
            pt_wrdata = (pad_k ^ cipher_k);
            pt_wren = 1'b1;

        end

        else begin
            ct_addr = ct_addr;
            message_length = message_length;

            s_addr = s_addr;
            s_wren = s_wren;
            s_wrdata = s_wrdata;
            s_i = s_i;
            s_j = s_j;

            pad_k = pad_k;
            cipher_k = cipher_k;
        end
    
    // writing the message length
    always_ff @(posedge clk)
        if (write_message_length == 1'b1)
            message_length = message_length - 1;
        else 
            message_length = message_length;
    */
    always_ff @(posedge clk)
        if (swap_i == 1) begin
            s_addr <= j_count;
            s_i <= s_i;
            s_wrdata <= s_i;
            s_j <= s_j;
            s_pad <= s_pad;
            s_wren <= 1;
        end
        else if (swap_j) begin
            s_addr <= i_count;
            s_wrdata <= s_j;
            s_i <= s_i;
            s_j <= s_j;
            s_pad <= s_pad;
            s_wren <= 1;
        end
        else if (read_s_i == 1) begin
            s_addr <= i_count;
            s_wrdata <= s_wrdata;
            s_i <= s_rddata;
            s_j <= s_j;
            s_pad <= s_pad;
            s_wren <= 0;
        end
        else if (read_s_j == 1) begin
            s_addr <= j_count;
            s_wrdata <= s_wrdata;
            s_i <= s_i;
            s_j <= s_rddata;
            s_pad <= s_pad;
            s_wren <= 0;
        end
        else if (read_pad == 1) begin
            s_addr <= pad_index;
            s_wrdata <= s_wrdata;
            s_i <= s_i;
            s_j <= s_j;
            s_pad <= s_rddata;
            s_wren <= 0;
        end
        else begin
            s_addr <= 8'bxxxx_xxxx;
            s_wrdata <= 8'bxxxx_xxxx;
            s_i <= s_i;
            s_j <= s_j;
            s_wren <= 1'bx;
        end

    // cipher text combinational logic 
    always_ff @(posedge clk)
        if (read_cipher == 1) begin
            ciphertext_k <= ct_rddata;
            message_length <= message_length;
            ct_addr <= k_count;
        end
        else if (read_message_length == 1) begin
            ciphertext_k <= ciphertext_k;
            message_length <= ct_rddata;
            ct_addr <= 8'd0;
        end
        else begin
            ciphertext_k <= ciphertext_k;
            message_length <= message_length;
            ct_addr <= ct_addr;
        end
    
    // plain text combinational logic 
    always_comb
        if (write_message_length == 1) begin
            pt_wrdata <= message_length;
            pt_addr <= 8'd0;
            pt_wren <= 1'b1;
        end
        else if (update_plaintext == 1) begin
            pt_wrdata <= (s_pad ^ ciphertext_k);
            pt_addr <= k_count;
            pt_wren <= 1'b1;
        end 
        else begin
            pt_wrdata <= 8'bxxxx_xxxx;
            pt_addr <= 8'bxxxx_xxxx;
            pt_wren <= 1'b0;
        end
    
    // pad index calculation
    always_ff @(posedge clk)
        if (calc_pad_index == 1)
            pad_index <= (s_i + s_j) % 9'd256;
        else 
            pad_index <= pad_index;

    // i and j updates
    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 0) begin
            i_count <= 0;
            j_count <= 0;
        end
        else if (start_counter == 1) begin
            i_count <= 0;
            j_count <= 0;
        end
        else if (increment_i == 1) begin
            i_count <= (i_count + 1) % 9'd256;
            j_count <= j_count;
        end 
        else if (increment_j == 1) begin
            i_count <= i_count;
            j_count <= (j_count + s_i) % 9'd256;
        end
        else begin
            i_count <= i_count;
            j_count <= j_count;
        end
        
    /*     
    statemachine_3 STATE(clk, 
                         rst_n,
                         en,
                         loop_condition, 
                         read_message_length, 
                         write_message_length, 
                         start_counter, 
                         increment_i, 
                         increment_j, 
                         increment_k, 
                         ead_s_i,
                         read_s_j, 
                         read_pad, 
                         read_cipher, 
                         calc_pad_index, 
                         swap_i, 
                         swap_j, 
                         update_plaintext, 
                         rdy);
    */
    statemachine_3 sm(.clk(clk), .rst_n(rst_n), .en(en), .loop_condition(loop_condition), .read_message_length(read_message_length), .write_message_length(write_message_length),
                      .start_counter(start_counter), .increment_i(increment_i), .increment_j(increment_j), .increment_k(increment_k), 
                      .read_s_i(read_s_i), .read_s_j(read_s_j), .read_pad(read_pad), .read_cipher(read_cipher), .calc_pad_index(calc_pad_index), 
                      .swap_i(swap_i), .swap_j(swap_j), .update_plaintext(update_plaintext), .rdy(rdy));

endmodule: prga

module statemachine_3(input logic clk, input logic rst_n, input logic en, input logic loop_condition, output logic read_message_length, output logic write_message_length, output logic start_counter, output logic increment_i, output logic increment_j,
                      output logic increment_k, output logic read_s_i, output logic read_s_j, output logic read_pad, output logic read_cipher, output logic calc_pad_index, 
                      output logic swap_i, output logic swap_j, output logic update_plaintext, output logic rdy);

    logic [`SW_3 - 1:0] present_state, next_state; 
    logic [`SW_3 + 14:0] next;

    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 0)
            present_state = `RESET_4;
        else 
            present_state = next_state;
    
    always_comb
        case (present_state)
            `RESET_4 : next = {`RDY_3, 15'b000_000_000_000_000};
            `RDY_3 : begin  
                if (en == 1)
                    next = {`RDY_DEASSERT_3, 15'b000_000_000_000_101};
                else 
                    next = {`RDY_3, 15'b000_000_000_000_101};
            end
            `RDY_DEASSERT_3 : next = {`GET_MESSAGE_LENGTH_ADDRESS, 15'b000_000_000_000_000};
            `GET_MESSAGE_LENGTH_ADDRESS : next = {`READ_MESSAGE_LENGTH, 15'b100_000_000_000_000};
            `READ_MESSAGE_LENGTH : next = {`READ_MESSAGE_LENGTH_WAIT, 15'b100_000_000_000_000};
            `READ_MESSAGE_LENGTH_WAIT : next = {`GET_MESSAGE_ADDRESS, 15'b100_000_000_000_000};
            `GET_MESSAGE_ADDRESS : next = {`WRITE_MESSAGE_LENGTH, 15'b100_000_000_000_000};
            `WRITE_MESSAGE_LENGTH : next = {`START_LOOP, 15'b000_000_000_000_010};
            `START_LOOP : begin
                if (loop_condition == 1)
                    next = {`DONE_3, 15'b000_000_000_000_000};
                else 
                    next = {`INCREMENT_I, 15'b000_000_000_000_000};
            end
            `INCREMENT_K : begin
                if (loop_condition == 1)
                    next = {`DONE_3, 15'b000_100_000_000_000};
                else 
                    next = {`INCREMENT_I, 15'b000_100_000_000_000};
            end
            `INCREMENT_I : next = {`GET_I_ADDRESS, 15'b010_000_000_000_000};
            `GET_I_ADDRESS : next = {`READ_I, 15'b000_010_000_000_000};
            `READ_I : next = {`READ_I_WAIT, 15'b000_010_000_000_000};
            `READ_I_WAIT : next = {`GET_I, 15'b000_010_000_000_000};
            `GET_I : next = {`INCREMENT_J, 15'b000_010_000_000_000};
            `INCREMENT_J : next = {`GET_J_ADDRESS, 15'b001_000_000_000_000};
            `GET_J_ADDRESS : next = {`READ_J, 15'b000_001_000_000_000};
            `READ_J : next = {`READ_J_WAIT, 15'b000_001_000_000_000};
            `READ_J_WAIT : next = {`GET_J, 15'b000_001_000_000_000};
            `GET_J : next = {`SWAP_S_I, 15'b000_001_000_000_000};
            `SWAP_S_I : next = {`SWAP_S_J, 15'b000_000_001_000_000};
            `SWAP_S_J : next = {`CALC_PAD_INDEX, 15'b000_000_000_100_000};
            `CALC_PAD_INDEX : next = {`CALC_PAD_INDEX_WAIT, 15'b000_000_000_010_000};
            `CALC_PAD_INDEX_WAIT : next = {`GET_PAD_ADDRESS, 15'b000_000_000_000_000};
            `GET_PAD_ADDRESS : next = {`READ_PAD, 15'b000_000_100_000_000};
            `READ_PAD : next = {`READ_PAD_WAIT, 15'b000_000_100_000_000};
            `READ_PAD_WAIT : next = {`GET_PAD, 15'b000_000_100_000_000};
            `GET_PAD : next = {`GET_CIPHER_ADDRESS, 15'b000_000_100_000_000};
            `GET_CIPHER_ADDRESS : next = {`READ_CIPHER, 15'b000_000_010_000_000};
            `READ_CIPHER : next = {`READ_CIPHER_WAIT, 15'b000_000_010_000_000};
            `READ_CIPHER_WAIT : next = {`GET_CIPHER, 15'b000_000_010_000_000};
            `GET_CIPHER : next = {`UPDATE_PLAINTEXT, 15'b000_000_010_000_000};
            `UPDATE_PLAINTEXT : next = {`INCREMENT_K, 15'b000_000_000_001_000};
            `DONE_3 : next = {`RDY_3, 15'b000_000_000_000_000};
            default : next = {`RESET_4, 15'bxxxx_xxxx_xxxx_xxx};
        endcase
                             // 1                2             3            4         5         6           7         8           9      10         11                12             13          14                   15
    assign {next_state, read_message_length, increment_i, increment_j, increment_k, read_s_i, read_s_j, read_pad, read_cipher, swap_i, swap_j, calc_pad_index, update_plaintext, start_counter, write_message_length, rdy} = next;
    
endmodule

module counter_8_2(input logic clk, input logic rst_n, input logic start_counter, input logic increment, output logic [7:0] next_count);

    logic [7:0] count;

    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 1'b0)
            count <= 8'd1;
        else if (start_counter == 1'b1)
            count <= 8'd1;
        else if (increment == 1)
            count <= count + 8'd1;
        else 
            count <= count; 
    
    assign next_count = count; 

endmodule