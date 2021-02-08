`define RESET 3'b000
`define LOOP 3'b001
`define END 3'b010

module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here
/*
    Want to implement:
        for i = 0 to 255:
            s[i] = i;
*/

/*
    inputs:
        clk = clock 
        rst_n = reset
        en = enable protocall. if rdy isasserted, caller may assert en to make a request to the callee. 
    
    outputs:
        rdy = ready protocall. Whenever the callee is ready to acept a request, it asserts its rdy signal
        addr = address you want to access 
        wrdata = the data you want to write 
        wren = write enable signal for SRAM 
*/

// counter register 
logic counter_count;
logic unsigned [8:0] current_count;
logic counter_done;
assign counter_done = (current_count == 9'd256) ? 1 : 0;
always_ff @(posedge clk or negedge rst_n)
    begin
        if (rst_n == 1'b0)
            current_count <= 9'd0;
        
        else if (counter_count == 1'b1)
            current_count <= current_count + 1;
        
        else 
            current_count <= current_count;
    end


// state machine path control
wire [2:0] present_state;
logic [2:0] next_state;
vDFF_async #3 STATE(clk, rst_n, next_state, `RESET, present_state);

logic is_done;
always @(*)
    begin
        case(present_state)
            `RESET: begin 
                        if (en == 1'b1)
                            next_state = `LOOP;
                        else 
                            next_state = `RESET;
                    end

            `LOOP: begin
                        if (is_done == 1'b1)
                            next_state = `END;
                        
                        else
                            next_state = `LOOP;
                   end
            
            `END: begin
                        next_state = `END;
                   end
            
            default: next_state = `RESET;
        endcase
    end

// state machine outputs
logic [7:0] next_address, next_write_data;
logic next_write_enable;
always @(*) 
    begin 
        case(present_state)
            `RESET: begin 
                        next_address = 8'bx;
                        next_write_data = 8'bx;
                        next_write_enable = 8'bx;
                        counter_count = 1'b0;
                        is_done = 1'b0;
                        rdy = 1'b1;
                    end
            
            `LOOP: begin
                        if (counter_done == 1'b0) // if we are still in da loop 
                            begin
                                counter_count = 1'b1;
                                is_done = 1'b0;
                                next_address = current_count [7:0]; // s[i] = i
                                next_write_data = current_count [7:0]; // s[i] = i
                                next_write_enable = 1'b1; // enabled to show we are supplying one address and one data at time 
                            end

                        else // not in da loop
                            begin
                                counter_count = 1'b0;
                                is_done = 1'b1;
                                next_address = 8'bx; // s[i] = i
                                next_write_data = 8'bx; // s[i] = i
                                next_write_enable = 1'b0; // enabled to show we are supplying one address and one data at time 
                            end
                        
                        rdy = 1'b0;
                   end

            `END: begin
                        next_address = 8'bx;
                        next_write_data = 8'bx;
                        next_write_enable = 1'b0;
                        counter_count = 1'b0;
                        is_done = 1'b1;
                        rdy = 1'b1;
                  end 
            
            default:
                  begin
                        next_address = 8'bx;
                        next_write_data = 8'bx;
                        next_write_enable = 1'bx;
                        counter_count = 1'bx;
                        is_done = 1'bx;
                        rdy = 1'bx;
                  end
        endcase

    end

assign addr = next_address;
assign wrdata = next_write_data;
assign wren = next_write_enable;


endmodule: init




module vDFF_async(clk, reset, in, reset_in, out);
     parameter n = 1;
     input clk, reset;
     input [n-1:0] in, reset_in;
     output reg [n-1:0] out;

     always@(posedge clk or negedge reset)
     begin
          if (reset == 1'b0)
               out = reset_in;
          else
               out = in;
     end
endmodule