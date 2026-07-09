module traffic_light_controller (
    input  logic clk,
    input  logic rstn,
    output logic red_light,
    output logic green_light,
    output logic yellow_light
);

    // DEFINE STATE
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        RED    = 2'b01,
        GREEN  = 2'b10,
        YELLOW = 2'b11
    } state_t;

    state_t current_state, next_state;

    // COUNTER VARIABLE
    logic [3:0] counter;
    logic       counter_load;
    logic [3:0] counter_load_value;

    localparam logic [3:0] IDLE_COUNT_MAX   = 4'b1001; 
    localparam logic [3:0] RED_COUNT_MAX    = 4'b0100; 
    localparam logic [3:0] GREEN_COUNT_MAX  = 4'b0100; 
    localparam logic [3:0] YELLOW_COUNT_MAX = 4'b0010; 

    // STATE REGISTER
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            current_state <= IDLE;
        end 
        else begin
            current_state <= next_state;
        end
    end

    // NEXT STATE LOGIC
    always_comb begin
        next_state         = current_state;
        counter_load       = 1'b0;
        counter_load_value = IDLE_COUNT_MAX;

        case (current_state)

            IDLE: begin
                if (counter == 4'b0) begin
                    next_state         = RED;
                    counter_load       = 1'b1;
                    counter_load_value = RED_COUNT_MAX;
                end
            end

            RED: begin
                if (counter == 4'b0) begin
                    next_state         = GREEN;
                    counter_load       = 1'b1;
                    counter_load_value = GREEN_COUNT_MAX;
                end
            end

            GREEN: begin
                if (counter == 4'b0) begin
                    next_state         = YELLOW;
                    counter_load       = 1'b1;
                    counter_load_value = YELLOW_COUNT_MAX;
                end
            end

            YELLOW: begin
                if (counter == 4'b0) begin
                    next_state         = RED;
                    counter_load       = 1'b1;
                    counter_load_value = RED_COUNT_MAX;
                end
            end

            default: begin
                next_state         = IDLE;
                counter_load       = 1'b1;
                counter_load_value = IDLE_COUNT_MAX;
            end

        endcase
    end

    // OUTPUT LOGIC
    always_comb begin
        red_light    = 1'b0;
        green_light  = 1'b0;
        yellow_light = 1'b0;

        case (current_state)

            IDLE: begin
                red_light = 1'b1;
            end

            RED: begin
                red_light = 1'b1;
            end

            GREEN: begin
                green_light = 1'b1;
            end

            YELLOW: begin
                yellow_light = 1'b1;
            end

            default: begin
                red_light = 1'b1;
            end

        endcase
    end

    // DATAPATH - DOWN COUNTER
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            counter <= IDLE_COUNT_MAX;
        end
        else if (counter_load) begin
            counter <= counter_load_value;
        end
        else begin
            counter <= counter - 1'b1;
        end
    end

endmodule
