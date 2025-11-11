interface FIFO_if(input logic clk);
    logic rst;
    logic write_en;
    logic read_en;
    logic [7:0] buf_in, buf_out;
    logic [6:0] count;
    logic buffer_empty;
    logic buffer_full;
endinterface

class transaction;
    rand bit write_en;
    rand bit read_en;
    rand bit [7:0] buf_in;
    
    function void display(string tag = "TRANS");
        $display("[%s] write_en=%0b read_en=%0b buf_in=%0h", 
                 tag, write_en, read_en, buf_in);
    endfunction
endclass

class driver;
    virtual FIFO_if vif;
    
    function new(virtual FIFO_if vif);
        this.vif = vif;
    endfunction
    
    task drive(transaction tr);
        vif.write_en = 0;
        vif.read_en = 0;
        @(posedge vif.clk);
        
        if(tr.write_en) begin
            vif.write_en = 1'b1;
            vif.buf_in = tr.buf_in;
            $display("[DRIVER] Write -> buf_in=%0h", tr.buf_in);
            @(posedge vif.clk);
            vif.write_en = 0;
        end
        
        if (tr.read_en) begin
            vif.read_en = 1;
            @(posedge vif.clk);
            vif.read_en = 0;
            @(posedge vif.clk);  // Wait one more cycle for output to stabilize
            $display("[DRIVER] Read -> buf_out=%0h count=%0d empty=%0b",
                     vif.buf_out, vif.count, vif.buffer_empty);
        end
    endtask
    
    task reset();
        vif.rst = 1;
        vif.write_en = 0;
        vif.read_en = 0;
        vif.buf_in = 8'h00;
        repeat(2) @(posedge vif.clk);
        vif.rst = 0;
        repeat(1) @(posedge vif.clk);
        $display("[DRIVER] Reset complete");
    endtask
endclass

class generator;
  mailbox gen2drv;
  transaction tr;
  function new(mailbox m);
    this.gen2drv=m;
  endfunction
  
  task run();
    repeat (10) begin
      tr=new();
      assert (tr.randomize());
      gen2drv.put(tr);
    end
  endtask
endclass
  
module tb;
    logic clk;
    FIFO_if intf(clk);
  mailbox gen2drv;
    
    FIFO dut (
        .clk(intf.clk),
        .rst(intf.rst),
        .write_en(intf.write_en),
        .read_en(intf.read_en),
        .buf_in(intf.buf_in),
        .buf_out(intf.buf_out),
        .count(intf.count),
        .buffer_empty(intf.buffer_empty),
        .buffer_full(intf.buffer_full)
    );
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    transaction tr;
    driver d;
  generator g;
  
    
    initial begin
      
        // Initialize driver
      gen2drv=new();
      d = new(intf);
      g = new(gen2drv);
      
        // Reset
        d.reset();
        
      fork
        g.run();
        begin
          transaction t;
          forever begin
          gen2drv.get(t);          // driver gets transaction from mailbox
          d.drive(t);
        end
      end
    join_none

    #200;
    $finish;
  end
endmodule
