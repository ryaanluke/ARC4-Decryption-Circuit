`define SW_2 5
`define RESET_2 5'd0
`define RDY_2 5'd1
`define RDY_DEASSERT_2 5'd2
`define COUNT_2 5'd3
`define READ_S_I_ADDRESS 5'd4
`define READ_S_I 5'd5
`define READ_S_I_WAIT 5'd6
`define GET_S_I 5'd7
`define CALC_J 5'd8
`define CALC_J_WAIT 5'd9
`define READ_S_J_ADDRESS 5'd10
`define READ_S_J 5'd11
`define READ_S_J_WAIT 5'd12
`define GET_S_J 5'd13
`define SWAP_I 5'd14
`define SWAP_I_WAIT 5'd15
`define SWAP_J 5'd16
`define SWAP_J_WAIT 5'd17
`define COUNTER_DONE_2 5'd18

module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    // your code here
    logic start_counter, increment, new_j, counter_done;
    logic read_i, read_j, swap_i, swap_j;
    logic [8:0] j;
    logic [8:0] i_count;
    logic [7:0] s_i, key_i, s_j;
    logic [8:0] key_index;

    assign key_index = (i_count % 9'd3);
    assign counter_done = (i_count == 9'd255) ? 1'b1 : 1'b0;

    counter_9 counter(.clk(clk), .rst_n(rst_n), .start_counter(start_counter), .increment(increment), .next_count(i_count));

    statemachine_2 sm(.clk(clk), .rst_n(rst_n), .counter_done(counter_done), .en(en), 
                      .start_counter(start_counter), .increment(increment), .new_j(new_j), 
                      .swap_i(swap_i), .swap_j(swap_j), .read_i(read_i), .read_j(read_j), .rdy(rdy));
    always_comb 
        case (key_index[1:0])
            2'b00 : key_i = key[23:16];
            2'b01 : key_i = key[15:8];
            2'b10 : key_i = key[7:0];
            default : key_i = 8'bxxxx_xxxx;
        endcase

    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 1'b0)
            j <= 1'b0;
        else if (start_counter == 1'b1)
            j <= 1'b0;
        else if (new_j == 1'b1)
            j <= (j + s_i + key_i) % 9'd256;
        else 
            j <= j;
    
    always_ff @(posedge clk)
        if (swap_i == 1'b1) begin
            s_i <= s_i;
            s_j <= s_j;
            wrdata <= s_j;
            addr <= i_count[7:0];
            wren <= 1'b1;
        end
        else if (swap_j == 1'b1) begin
            s_i <= s_i;
            s_j <= s_j;
            wrdata <= s_i;
            addr <= j[7:0];
            wren <= 1'b1;
        end 
        else if (read_i == 1'b1) begin
            s_i <= rddata;
            s_j <= s_j;
            wrdata <= wrdata;
            addr <= i_count[7:0];
            wren <= 1'b0;
        end
        else if (read_j == 1'b1) begin
            s_i <= s_i;
            s_j <= rddata;
            wrdata <= wrdata;
            addr <= j[7:0];
            wren <= 1'b0;
        end
        else begin
            s_i <= s_i;
            s_j <= s_j;
            wrdata <= 8'bxxxx_xxxx;
            addr <= 8'bxxxx_xxxx;
            wren <= 1'bx;
        end

endmodule: ksa

module statemachine_2(input logic clk, input logic rst_n, input logic counter_done, input logic en, output logic start_counter, 
                      output logic increment, output logic new_j, output logic swap_i, output logic swap_j, 
                      output logic read_i, output logic read_j, output logic rdy);

    logic [`SW_2 - 1: 0] present_state, next_state; 
    logic [`SW_2 + 7:0] next;

    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 1'b0)
            present_state = `RESET_2;
        else 
            present_state = next_state;
    
    always_comb 
        case (present_state)
            `RESET_2 : next = {`RDY_2, 8'b0000_0000};
            `RDY_2 : begin
                if (en == 1'b1)
                    next = {`RDY_DEASSERT_2, 8'b1100_0000}; // START J AND START I
                else 
                    next = {`RDY_2, 8'b1100_0000};
            end
            `RDY_DEASSERT_2 : next = {`COUNT_2, 8'b0000_0000};
            `COUNT_2 : begin
                if (counter_done == 1'b1)
                    next = {`COUNTER_DONE_2, 8'b0010_0000};
                else 
                    next = {`READ_S_I_ADDRESS, 8'b0010_0000};
            end
            `READ_S_I_ADDRESS : next = {`READ_S_I, 8'b0000_1000};
            `READ_S_I : next = {`READ_S_I_WAIT, 8'b0000_1000};
            `READ_S_I_WAIT : next = {`GET_S_I, 8'b0000_1000};
            `GET_S_I : next = {`CALC_J, 8'b0000_1000};
            `CALC_J : next = {`CALC_J_WAIT, 8'b0001_0000};
            `CALC_J_WAIT : next = {`READ_S_J_ADDRESS, 8'b0000_0000};
            `READ_S_J_ADDRESS : next = {`READ_S_J, 8'b0000_0100};
            `READ_S_J : next = {`READ_S_J_WAIT, 8'b0000_0100};
            `READ_S_J_WAIT : next = {`GET_S_J, 8'b0000_0100};
            `GET_S_J : next = {`SWAP_I, 8'b0000_0100};
            `SWAP_I : next = {`SWAP_J, 8'b0000_0010};
            `SWAP_J : next = {`COUNT_2, 8'b0000_0001};
            `COUNTER_DONE_2 : next = {`COUNTER_DONE_2, 8'b1000_0000};
            default : next = {`RESET_2, 8'bxxxx_xxxx};
        endcase
    
    assign {next_state, rdy, start_counter, increment, new_j, read_i, read_j, swap_i, swap_j} = next;

endmodule

module counter_9(input logic clk, input logic rst_n, input logic start_counter, 
                 input logic increment, output logic [8:0] next_count);

    logic [8:0] count;

    always_ff @(posedge clk, negedge rst_n)
        if (rst_n == 1'b0)
            count <= -1;
        else if (start_counter == 1'b1)
            count <= -1;
        else if (increment == 1)
            count <= count + 9'd1;
        else 
            count <= count; 
    
    assign next_count = count; 

endmodule 