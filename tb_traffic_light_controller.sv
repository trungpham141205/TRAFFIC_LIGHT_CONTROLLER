`timescale 1ns/1ps

module tb_traffic_light_controller;

    logic clk;
    logic rstn;
    logic red_light;
    logic green_light;
    logic yellow_light;

    traffic_light_controller dut (
        .clk(clk),
        .rstn(rstn),
        .red_light(red_light),
        .green_light(green_light),
        .yellow_light(yellow_light)
    );
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light_controller);
        clk = 0;
        rstn = 0; 
        #20;
        rstn = 1; 
        #400;

        rstn = 0; 
        #15; 
        rstn = 1; 
        #100;
        
        $finish;
    end

    initial begin
        $monitor("Time=%0t | rstn=%b | RED=%b GREEN=%b YELLOW=%b", 
                 $time, rstn, red_light, green_light, yellow_light);
    end

endmodule
