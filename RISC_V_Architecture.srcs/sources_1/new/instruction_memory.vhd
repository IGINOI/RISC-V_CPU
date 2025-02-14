----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: instruction_memory - Behavioral
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

entity instruction_memory is
    port(
        --INPUTS
        clk : in std_logic;
        addr : in std_logic_vector(31 downto 0); --input address (10 bits, for 1024 instructions)
        
        --OUTPUTS
        instruction_out : out std_logic_vector(31 downto 0)  -- Output instruction
    );
end instruction_memory;

-- Architecture Body for Instruction Memory
architecture Behavioral of instruction_memory is

    -- Define a memory array (custom type) for instructions (size: 1024 instructions each of 32bit)
    type memory_type is array(0 to 1023) of std_logic_vector(31 downto 0);
    -- Define the signal of memory_type type
    signal mem : memory_type := (
        -- x"00000033" is the exadecimal code for the NOP (No operation) instruction => (ADD x0, x0, x0)
        0 => x"00000033",
        1 => x"00008563",
        2 => x"00000033",
        3 => x"00000033",
        4 => x"0000000A",
        5 => x"0000000B",
        6 => x"0000000C",
        7 => x"0000000D",
        8 => x"0000000E",
        9 => x"0000000F",
        others => x"00000033"
    );
begin
    -- Output the selected instruction by the input
    process (clk)
    begin
        if rising_edge(clk) then
            instruction_out <= mem(to_integer(unsigned(addr)));
        end if;
    end process;
    
end Behavioral;