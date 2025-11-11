module FIFO (
     input logic clk,rst,write_en,read_en,
     input logic [7:0] buf_in,
     output logic [7:0] buf_out,
     output logic [6:0] count,
     output logic buffer_empty,
     output logic buffer_full
);
  logic [5:0] write_ptr;
  logic [5:0] read_ptr;
  logic [7:0] buffer_memory [63:0];
  
  logic buffer_empty_w;
  logic buffer_full_w;
    
  assign buffer_empty_w = (count == 0);
  assign buffer_full_w  = (count == 64);
  
  //increment logic
  always_ff @(posedge clk or posedge rst) begin
    
    if (rst) begin
      count<=7'd0;
      buf_out<=8'b0;
      write_ptr<=6'd0;
      read_ptr<=6'd0;
      buffer_empty  <= 1'b1;
      buffer_full   <= 1'b0;
    end
    
      else begin 
        
        if((read_en  && ~buffer_empty) && (write_en  && ~buffer_full)) begin
      count<=count;
      buffer_memory[write_ptr] <= buf_in;
      buf_out<=buffer_memory[read_ptr];
      read_ptr <= (read_ptr + 1) & 6'b111111;
      write_ptr <= (write_ptr + 1) & 6'b111111;
    end
    
     else if((write_en  && ~buffer_full))begin
      buffer_memory[write_ptr]<=buf_in;
      count<=count+1'b1;
      write_ptr <= (write_ptr + 1) & 6'b111111;
      //read_ptr<=read_ptr;
      //buf_out<=buf_out;
    end
  
    else if((read_en  && ~buffer_empty)) begin
      buf_out<=buffer_memory[read_ptr];
      count<=count-1'b1;
      read_ptr <= (read_ptr + 1) & 6'b111111;
      //write_ptr<=write_ptr;
    end
    
    buffer_empty <= buffer_empty_w;
    buffer_full  <= buffer_full_w; 
    
      end 
  end
endmodule
 
