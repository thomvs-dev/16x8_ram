module ram_16x8 (
    input clk, input rst, input we,         
    input re, input [3:0] addr, input [7:0] din,         
    output reg [7:0] dout);

    
    reg [7:0] mem [0:15];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
         
            for (i = 0; i < 16; i = i + 1)
                mem[i] <= 8'd0;
            dout <= 8'd0;
        end
        else begin
            if (we)
                mem[addr] <= din;
            if (re)
                dout <= mem[addr];
        end
    end

endmodule
