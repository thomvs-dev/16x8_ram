`timescale 1ns/1ps

module ram_16x8_tb;

  reg clk; reg rst; reg we;
  reg re; reg [3:0] addr;
  reg [7:0] din; wire [7:0] dout;
  integer l, m;

  ram_16x8 dut ( .clk(clk), .rst(rst),
    .we(we), .re(re), .addr(addr),
    .din(din), .dout(dout));

initial
    clk = 1'b0;

always
    #10 clk = ~clk;

task initialization;
    begin
        {din, we, re, addr} = 0;
    end
endtask

task value_rst;
    begin
        @(negedge clk)
        rst = 1'b1;
        @(negedge clk)
        rst = 1'b0;
    end
endtask

task value_write(input [7:0] i, input [3:0] j);
    begin
        @(negedge clk)
        we   = 1'b1;
        re   = 1'b0;
        din  = i;
        addr = j;
    end
endtask

task value_read(input [3:0] j);
    begin
        @(negedge clk)
        we   = 1'b0;
        re   = 1'b1;
        addr = j;
    end
endtask

initial begin
    initialization();
    rst = 0;

    value_rst();

    value_write(8'd30, 4'd12);
    #20 we = 1'b0;

    value_read(4'd12);

    for (l = 0; l < 16; l = l + 1) begin
        value_write(l + 1, l);
    end

    #20 we = 1'b0;

    for (m = 0; m < 16; m = m + 1) begin
        value_read(m);
    end

    #20 re = 1'b0;
  
end
  
    initial begin
      $monitor("tme=%0t | clk=%b reset=%b din=%b dout=%b add=%b",
                  $time, clk, rst, din, dout, addr);
    end

initial
    #1000 $finish;

endmodule
