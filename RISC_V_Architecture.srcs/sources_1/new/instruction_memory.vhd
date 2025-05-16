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
        addr : in std_logic_vector(31 downto 0);
        
        --OUTPUTS
        instruction_out : out std_logic_vector(31 downto 0)
    );
end instruction_memory;


architecture Behavioral of instruction_memory is

    -- Define a memory array (custom type) for instructions (size: 1024 instructions each of 32bit)
    type memory_type is array(0 to 1023) of std_logic_vector(31 downto 0);
    signal mem : memory_type := (
        0  => x"00000113",  -- addi x2, x0, 0       ; F₀ = 0
    
        3  => x"00100193",  -- addi x3, x0, 1       ; F₁ = 1
    
        6  => x"00000293",  -- addi x5, x0, 0       ; loop counter = 0
    
        9 => x"00500413",  -- addi x8, x0, 20      ; target = 20  01400413 target 5
    
        12 => x"00100313",  -- addi x6, x0, 1       ; x6 = RAM base addr
        -- Loop start
        15 => x"00232023",  -- sw x2, 0(x6)         ; store Fₙ to RAM[x6]
        
        --18 => x"00130313",  -- addi x6, x6, 1       ; increment pointer
    
        18 => x"00310233",  -- add x4, x2, x3       ; x4 = x2 + x3
    
        21 => x"00018113",  -- addi x2, x3, 0       ; x2 ← x3
    
        24 => x"00020193",  -- addi x3, x4, 0       ; x3 ← x4
    
        27 => x"00128293",  -- addi x5, x5, 1       ; x5 = x5 + 1
    
        30 => x"fe82d7e3",  -- bge x5, x8, -18      ; if x5 < x8, jump back to loop  -36   fc82dee3
    
        others => x"00000000"
    );

begin

    -- Output the selected instruction by the input
    fetch_instruction: process (clk)
    begin
        if rising_edge(clk) then
            instruction_out <= mem(to_integer(unsigned(addr)));
        end if;
    end process fetch_instruction;
    
end Behavioral;