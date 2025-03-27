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
        0  => x"00000513", -- addi a0, x0, 0
        1  => x"00000593", -- addi a1, x0, 1
        2  => x"01400613", -- addi a2, x0, 10
        3  => x"00200693", -- addi a3, x0, 2
        4  => x"00C68C63", -- beq a3, a2, end
        5  => x"00B502B3", -- add t0, a0, a1
        6  => x"00058513", -- add a0, x0, a1
        7  => x"00028593", -- add a1, x0, t0
        8  => x"00168693", -- addi a3, a3, 1
        9  => x"FF5FF06F", -- j loop
        10 => x"00A00713", -- addi a7, x0, 10
        11 => x"00000073", -- ecall
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