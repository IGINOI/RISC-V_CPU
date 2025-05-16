----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2025 15:25:18
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--   Top-level RISC-V pipeline with 8-digit hex display on an active-low 7-segment array.
-- 
-- Revision:
-- Revision 0.02 - Added 7-segment multiplexing
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        -- INPUTS
        clka : in  std_logic;
        reset : in  std_logic;
        
        sw1: in std_logic;
        sw2: in std_logic;
        sw3: in std_logic;
        
        -- OUTPUTS
        led1 : out std_logic;
        led2 : out std_logic;
        seven_segments: out std_logic_vector(7 downto 0);
        an: out std_logic_vector(7 downto 0)
    );
end top;

architecture Behavioral of top is

    ----------------------------
    -- SIGNALS BETWEEN STAGES --
    ----------------------------
    -- Fetch -> Decode
    signal curr_pc_fetch_decode : std_logic_vector(31 downto 0);
    signal instruction         : std_logic_vector(31 downto 0);
    
    signal clk : std_logic := '0';
    
    -- Decode -> Execute
    signal curr_pc_decode_execute : std_logic_vector(31 downto 0);
    signal rs1_value, rs2_value   : std_logic_vector(31 downto 0);
    signal immediate_value        : std_logic_vector(31 downto 0);
    signal cond_opcode            : std_logic_vector(1 downto 0);
    signal alu_opcode             : std_logic_vector(3 downto 0);
    signal a_sel, b_sel           : std_logic;
    signal rd_forward_de          : std_logic_vector(4 downto 0);
    signal forward_op_class_de    : std_logic_vector(4 downto 0);
    
    -- Execute -> Memory
    signal curr_pc_execute_memory        : std_logic_vector(31 downto 0);    
    signal branch_cond                   : std_logic;
    signal alu_result                    : std_logic_vector(31 downto 0) := (others => '0');
    signal register_read_write_enable_em: std_logic;
    signal memory_read_write_enable_em   : std_logic;
    signal rd_forward_em                 : std_logic_vector(4 downto 0);
    signal rs2_value_forward_em          : std_logic_vector(31 downto 0) := (others => '0');
    signal forward_op_class_em           : std_logic_vector(4 downto 0);
    
    -- Memory -> WriteBack
    signal next_pc_memory_writeb   : std_logic_vector(31 downto 0);
    signal mem_out                 : std_logic_vector(31 downto 0);
    signal alu_result_mem_wb       : std_logic_vector(31 downto 0);
    signal register_write_enable_mw: std_logic;
    signal rd_forward_mw           : std_logic_vector(4 downto 0);
    signal forward_op_class_mw     : std_logic_vector(4 downto 0);
    
    -- WriteBack -> Fetch/Decode
    signal next_final_pc       : std_logic_vector(31 downto 0);
    signal write_back_value    : std_logic_vector(31 downto 0);
    signal register_write_enable_wd: std_logic;
    signal rd_forward_wd       : std_logic_vector(4 downto 0);
    
    -------------------------------
    -- SIGNALS FROM CONTROL UNIT --
    -------------------------------
    signal instruction_load_enable    : std_logic;
    signal stall_cf                   : std_logic;
    signal register_read_write_enable_ce : std_logic;
    signal memory_read_write_enable_ce   : std_logic;
    
    signal prova : std_logic_vector(31 downto 0);
    signal signal_for_fpga : std_logic_vector(31 downto 0);
    signal fibonacci_value : std_logic_vector(31 downto 0);
    
    -- clock divider for 50 MHz → 1 Hz LED blink  
    signal counter : unsigned(26 downto 0) := (others => '0');
    
    ----------------------------------------------------------------
    -- 7-SEGMENT MULTIPLEXING SIGNALS
    ----------------------------------------------------------------
    signal refresh_cnt : unsigned(16 downto 0) := (others => '0');
    signal digit_idx   : unsigned(2 downto 0)  := (others => '0');
    signal nibble      : std_logic_vector(3 downto 0);
    signal seg_pattern : std_logic_vector(6 downto 0);
    
begin

    -- Reducing clock to 1Hz
    reduce_clk: process(clka)
    begin
        if rising_edge(clka) then
            if reset = '1' then
                counter <= (others => '0');
                led1 <= '1';
            end if;
            if counter = 9_999_999 then
                clk <= not clk;
                counter <= (others => '0');
                led1 <= '0';
                if clk = '1' then
                    led2 <= '0';
                else
                    led2 <= '1';
                end if;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    -- Updates the counters to refresh the display and extract the index
    displays_refreshing: process(clka, reset)
    begin
        if reset = '1' then
            refresh_cnt <= (others => '0');
            digit_idx   <= (others => '0');
        elsif rising_edge(clka) then
            refresh_cnt <= refresh_cnt + 1;
            digit_idx   <= refresh_cnt(16 downto 14);
        end if;
    end process;
    
    select_signal_to_diplay: process(sw1, instruction, sw2, curr_pc_fetch_decode, sw3, fibonacci_value)
    begin
        if sw1 = '1' then
            signal_for_fpga <= instruction;
        elsif sw2 = '1' then
            signal_for_fpga <= curr_pc_fetch_decode;
        elsif sw3 = '1' then
            signal_for_fpga <= fibonacci_value;
        else
            signal_for_fpga <= (others => '1');
        end if;
    end process;
    
    -- Lights correct index display
    select_index: process(digit_idx, signal_for_fpga)
    begin
        -- disable all digits (active-low)
        an <= (others => '1'); --all deactivated
        
        -- choose nibble & enable one anode
        case digit_idx is
            when "000" =>
                nibble <= signal_for_fpga(3 downto  0);
                an(0)  <= '0';
            when "001" =>
                nibble <= signal_for_fpga(7 downto  4);
                an(1)  <= '0';
            when "010" =>
                nibble <= signal_for_fpga(11 downto  8);
                an(2)  <= '0';
            when "011" =>
                nibble <= signal_for_fpga(15 downto 12);
                an(3)  <= '0';
            when "100" =>
                nibble <= signal_for_fpga(19 downto 16);
                an(4)  <= '0';
            when "101" =>
                nibble <= signal_for_fpga(23 downto 20);
                an(5)  <= '0';
            when "110" =>
                nibble <= signal_for_fpga(27 downto 24);
                an(6)  <= '0';
            when others =>
                nibble <= signal_for_fpga(31 downto 28);
                an(7)  <= '0';
            end case;
    end process;
    
    update_segment: process (nibble, seg_pattern)
    begin
          -- hex → a-g pattern (gfedcba, active-low)
        case nibble is
            when "0000" => seg_pattern <= "0000001";  -- 0
            when "0001" => seg_pattern <= "1001111";  -- 1
            when "0010" => seg_pattern <= "0010010";  -- 2
            when "0011" => seg_pattern <= "0000110";  -- 3
            when "0100" => seg_pattern <= "1001100";  -- 4
            when "0101" => seg_pattern <= "0100100";  -- 5
            when "0110" => seg_pattern <= "0100000";  -- 6
            when "0111" => seg_pattern <= "0001111";  -- 7
            when "1000" => seg_pattern <= "0000000";  -- 8
            when "1001" => seg_pattern <= "0000100";  -- 9
            when "1010" => seg_pattern <= "0001000";  -- A
            when "1011" => seg_pattern <= "1100000";  -- b
            when "1100" => seg_pattern <= "0110001";  -- C
            when "1101" => seg_pattern <= "1000010";  -- d
            when "1110" => seg_pattern <= "0110000";  -- E
            when others => seg_pattern <= "0111000";  -- F
        end case;
    end process;
    light_up: process (seg_pattern)
    begin
        seven_segments <= seg_pattern & '1'; --turno off the point
    end process;

    -----------------------
    -- FETCH INSTRUCTION --
    -----------------------
    fetch_inst : entity work.fetch
    port map (
        clk             => clk,
        reset           => reset,
        load_enable     => instruction_load_enable,
        alu_result      => alu_result,
        branch_cond     => branch_cond,
        instruction_out => instruction,
        curr_pc_out     => curr_pc_fetch_decode
    );
 
    ------------------
    -- CONTROL UNIT --
    ------------------   
    control_unit: entity work.control_unit
    port map (
        clk          => clk,
        reset        => reset,
        opcode  => instruction(6 downto 0),
        program_counter_loader   => instruction_load_enable,
        read_write_enable_register=> register_read_write_enable_ce,
        read_write_enable_memory => memory_read_write_enable_ce,
        stall        => stall_cf
    );

    ------------------------
    -- DECODE Instruction --
    ------------------------ 
    decode_inst : entity work.decode
    port map (
        clk                     => clk,
        instruction_in          => instruction,
        curr_pc_in              => curr_pc_fetch_decode,
        register_write_enable   => register_write_enable_wd,
        write_back_value        => write_back_value,
        curr_pc_out             => curr_pc_decode_execute,
        opclass                 => forward_op_class_de,
        
        write_m_enable          => memory_read_write_enable_em,
        write_fibo_value        => rs2_value_forward_em,
        signal_fibonacci        => fibonacci_value,
        
        alu_opcode              => alu_opcode,
        a_sel                   => a_sel,
        b_sel                   => b_sel,
        cond_opcode             => cond_opcode,
        immediate_out           => immediate_value,
        rs1_value               => rs1_value,
        rs2_value               => rs2_value,
        rd_address              => rd_forward_wd,
        out_rd                  => rd_forward_de
    );

    -------------------------
    -- EXECUTE Instruction --
    -------------------------
    execute_inst : entity work.execute
    port map (
        clk                            => clk,
        --reset                          => reset,
        in_op_class                    => forward_op_class_de,
        rs1_value                      => rs1_value,
        rs2_value                      => rs2_value,
        curr_pc                        => curr_pc_decode_execute,
        immediate_value                => immediate_value,
        a_sel                          => a_sel,
        b_sel                          => b_sel,
        cond_opcode                    => cond_opcode,
        alu_opcode                     => alu_opcode,
        branch_cond                    => branch_cond,
        out_op_class                   => forward_op_class_em,
        alu_result                     => alu_result,
        curr_pc_out                    => curr_pc_execute_memory,
        in_forward_instruction_write_enable  => register_read_write_enable_ce,
        out_forward_instruction_write_enable => register_read_write_enable_em,
        in_forward_memory_write_enable       => memory_read_write_enable_ce,
        out_forward_memory_write_enable      => memory_read_write_enable_em,
        in_forward_rd                 => rd_forward_de,
        out_forward_rd                => rd_forward_em,
        out_forward_rs2_value         => rs2_value_forward_em,
        prova                         => prova
    );

    -------------------------------
    -- MEMORY ACCESS Instruction --
    -------------------------------
    memory_access_inst : entity work.memory_access
    port map (
        clk                             => clk,
        alu_result                      => alu_result,
        rs2_value                       => rs2_value_forward_em,
        mem_we                          => memory_read_write_enable_em,
        prova                           => prova,
        mem_out                         => mem_out,
        alu_result_out                  => alu_result_mem_wb,
        in_forward_instruction_write_enable   => register_read_write_enable_em,
        out_forward_instruction_write_enable  => register_write_enable_mw,
        in_forward_rd                  => rd_forward_em,
        out_forward_rd                 => rd_forward_mw,
        in_opclass                     => forward_op_class_em,
        out_opclass                    => forward_op_class_mw
    );

    ----------------------------
    -- WRITE BACK Instruction --
    ----------------------------
    write_back_inst : entity work.write_back
    port map (
        clk                             => clk,
        alu_result                      => alu_result_mem_wb,
        op_class                        => forward_op_class_mw,
        mem_out                         => mem_out,
        rd_value                        => write_back_value,
        in_forward_instruction_write_enable   => register_write_enable_mw,
        out_forward_instruction_write_enable  => register_write_enable_wd,
        in_forward_rd                  => rd_forward_mw,
        out_forward_rd                 => rd_forward_wd
    );

end Behavioral;
