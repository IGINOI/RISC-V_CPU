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
        opcode: in std_logic_vector(6 downto 0);
        
        -- OUTPUTS
        program_counter_loader: out std_logic;
        read_write_enable_register: out std_logic;
        read_write_enable_memory: out std_logic;
        stall: out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is
    signal prev_pc_enable : std_logic := '0';

    signal regwrite_prev : std_logic := '0';

begin
    
    -- Initialize control signals
    control_signals: process(clk)
    begin
        if rising_edge (clk) then
            if reset = '1' then
                program_counter_loader <= '0';
                read_write_enable_register <= '0';
                read_write_enable_memory <= '0';
                stall <= '0';
            else
                if prev_pc_enable = '0' then
                    prev_pc_enable <= '1';
                    program_counter_loader <= '1';
                else
                    prev_pc_enable <= '0';
                    program_counter_loader <= '0';
                end if;
                stall <= '0';     
                
                -- DECODE WHETHER THERE IS NEED TO WRITE IN MEMORY OR IN REGISTER IN THE FUTURE
                case opcode is
                    ------------------------
                    -- R-TYPE INSTRUCTION --
                    ------------------------
                    when "0110011" =>
                        read_write_enable_register <= '1'; -- 0 read, 1 write
                        read_write_enable_memory <= '0'; -- 0 read, 1 write
                    
                    ------------------------
                    -- I-TYPE INSTRUCTION --
                    ------------------------
                    when "0010011" | "0000011" |  "1100111" =>
                        read_write_enable_register <= '1';
                        read_write_enable_memory <= '0';
                    
                    ------------------------
                    -- S-TYPE INSTRUCTION --
                    ------------------------
                    when "0100011" =>
                        read_write_enable_register <= '0';
                        read_write_enable_memory <= '1';
                    
                    ------------------------
                    -- B-TYPE INSTRUCTION --
                    ------------------------
                    when "1100011" =>
                        read_write_enable_register <= '0';
                        read_write_enable_memory <= '0';
                        
                    ------------------------
                    -- U-TYPE INSTRUCTION --
                    ------------------------
                    when "0110111" | "0010111" =>
                        read_write_enable_register <= '1';
                        read_write_enable_memory <= '0';
                    
                    ------------------------
                    -- J-TYPE INSTRUCTION --
                    ------------------------
                    when "1101111" =>
                        read_write_enable_register <= '1';
                        read_write_enable_memory <= '0';
                    
                    ------------------------
                    -- DAFAULT INTRUCTION --
                    ------------------------
                    when others =>
                        read_write_enable_register <= '0';
                        read_write_enable_memory <= '0';
                end case;
            end if;
         end if;
     end process;

end Behavioral;