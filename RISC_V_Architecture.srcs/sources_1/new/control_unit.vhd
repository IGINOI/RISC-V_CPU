----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2025 10:13:54
-- Design Name: 
-- Module Name: control_unit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
    Port ( 
        -- INPUTS
        clk: in std_logic;
        reset: in std_logic;
        instruction: in std_logic_vector(31 downto 0);
        
        
        -- OUTPUTS
        program_counter_loader: out std_logic;
        read_write_enable_register: out std_logic;
        read_write_enable_memory: out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is

    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal opcode : std_logic_vector(6 downto 0);
    signal stall: std_logic;
    signal stall_counter : integer range 0 to 3 := 0; -- Counter for stall duration
    signal pc_loader_pulse: std_logic := '0';

begin
    
    -- Decomposing instruction.
    funct3 <= instruction(14 downto 12);
    funct7 <= instruction(31 downto 25);
    opcode <= instruction(6 downto 0);
    
    rst: process(clk)
    begin
        if rising_edge (clk) then
            if reset = '1' then
                program_counter_loader <= '0';
                read_write_enable_register <= '1';
                read_write_enable_memory <= '0';
                stall <= '0';
                pc_loader_pulse <= '0';
            else
                if pc_loader_pulse = '0' then
                    pc_loader_pulse <= '1';
                    program_counter_loader <= '1';
                else 
                    pc_loader_pulse <= '0';
                    program_counter_loader <= '0';
                end if;
            end if;
         end if;
     end process;
    
    
    -- Control Hazard >>> STALL THE PIPELINE
    control_hazard: process(clk)
    begin
        if rising_edge(clk) then
            if stall_counter = 0 then
                -- Check for Control Hazards (Branch or Jump)
                if (opcode = "1100011" or opcode = "1101111" or opcode = "1100111") then
                    stall <= '1';
                    stall_counter <= 100;
                end if;
            else
                -- Reduce stall Counter
                stall <= '1';
                stall_counter <= stall_counter - 1;  -- Decrease counter each cycle
            end if;
        end if;
    end process control_hazard;
    
    -- Data Hazard >>> STALL THE PIPELINE


end Behavioral;
