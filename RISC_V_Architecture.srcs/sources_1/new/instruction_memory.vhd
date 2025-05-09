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
    
    
    -- ADD VERSION
--    signal mem : memory_type := (
--        0  => x"00000033", -- addi a0, x0, 0   (Fib(0) = 0)
--        1  => x"00000033", -- addi a1, x0, 1   (Fib(1) = 1)
--        2  => x"00000033", -- addi a2, x0, 20  (Set number of terms to 20)
--        3  => x"00000033", -- addi a3, x0, 2   (Counter starts at 2)
--        4  => x"00000033", -- beq a3, a2, end  (Exit if counter == a2)
--        5  => x"00000033", -- add t0, a0, a1   (t0 = Fib(n-1) + Fib(n-2))
--        6  => x"00000033", -- add a0, x0, a1   (a0 = a1)
--        7  => x"00000033", -- add a1, x0, t0   (a1 = t0)
--        8  => x"00000033", -- addi a3, a3, 1   (counter++)
--        9  => x"00000033", -- j loop           (Jump back to loop)
--        10 => x"00000033", -- addi a7, x0, 10  (Exit syscall)
--        11 => x"00000033", -- ecall            (Terminate program)
--        others => x"00000033" -- NOP
--    );
    
    
--    FIRST VERSION FOR FIBONACCI
--    signal mem : memory_type := (
--        0  => x"00000513", -- addi a0, x0, 0   (Fib(0) = 0)
--        1  => x"00000593", -- addi a1, x0, 1   (Fib(1) = 1)
--        2  => x"01400613", -- addi a2, x0, 20  (Set number of terms to 20)
--        3  => x"00200693", -- addi a3, x0, 2   (Counter starts at 2)
--        4  => x"00C68C63", -- beq a3, a2, end  (Exit if counter == a2)
--        5  => x"00B502B3", -- add t0, a0, a1   (t0 = Fib(n-1) + Fib(n-2))
--        6  => x"00058513", -- add a0, x0, a1   (a0 = a1)
--        7  => x"00028593", -- add a1, x0, t0   (a1 = t0)
--        8  => x"00168693", -- addi a3, a3, 1   (counter++)
--        9  => x"FF5FF06F", -- j loop           (Jump back to loop)
--        10 => x"00A00713", -- addi a7, x0, 10  (Exit syscall)
--        11 => x"00000073", -- ecall            (Terminate program)
--        others => x"00000033" -- NOP
--    );

--    SECOND VERSION FOR FIBONACCI
    signal mem : memory_type := (
        5  => x"00100593", -- addi a1, x0, 1   (Fib(0) = 0)
        10  => x"00100613", -- addi a2, x0, 1   (Fib(1) = 1)
        
        -- Compute Fib(2) = Fib(0) + Fib(1)
        15  => x"00C586B3", -- add a3, a1, a2
        20  => x"00C005B3", -- add a1, x0, a2
        25  => x"00D00633", -- add a2, x0, a3
    
        -- Compute Fib(3) = Fib(1) + Fib(2)
        30  => x"00C586B3",
        35  => x"00C005B3",
        40  => x"00D00633",
    
        -- Compute Fib(4) = Fib(2) + Fib(3)
        45  => x"00C586B3",
        50  => x"00C005B3",
        55  => x"00D00633",
    
        -- Compute Fib(5) = Fib(3) + Fib(4)
        60  => x"00C586B3",
        65  => x"00C005B3",
        70  => x"00D00633",
        
        -- Compute Fib(5) = Fib(3) + Fib(4)
        75  => x"00C586B3",
        80  => x"00C005B3",
        85  => x"00D00633",
        
        
        -- Compute Fib(5) = Fib(3) + Fib(4)
        90  => x"00C586B3",
        95  => x"00C005B3",
        100  => x"00D00633",
        
        
        -- Compute Fib(5) = Fib(3) + Fib(4)
        105  => x"00C586B3",
        110  => x"00C005B3",
        115  => x"00D00633",
    
        -- Terminate program
        120  => x"00A00713", -- addi a7, x0, 10  (Exit syscall)
        125  => x"00000073", -- ecall            (Terminate program)
        
        others => x"00000033" -- NOP
    );

    -- SIMPLE SUM TO TEST
--    signal mem : memory_type := (
--        0 => x"00100513",   -- addi a0, x0, 1        x10 - 1
--        1 => x"00200593",   -- addi a1, x0, 2        x11 - 2
--        2 => x"00300613",   -- addi  a2, x0, 3       x12 - 3
--        3 => x"00400693",   -- addi a3, x0, 4        x13 - 4
--        4 => x"00000033",
--        5 => x"00000033",
--        6 => x"00000033",
--        7 => x"00000033",
--        8 => x"00D60733",  -- add a4, a2, a3        x14 - 7
--        9 => x"00000033",
--        10 => x"00000033",
--        11 => x"00000033",
--        12 => x"00000033",
--        13 => x"00D707B3", -- add a5, a4, a3        x14 - 11
--        14 => x"00000033",
--        15 => x"00000033",
--        16 => x"00000033",
--        17 => x"00000033",
--        18 => x"0010A023", -- sw a5, 0(x1)
--        others => x"00000033"
--    );



begin
    -- Output the selected instruction by the input
    process (clk)
    begin
        if rising_edge(clk) then
            instruction_out <= mem(to_integer(unsigned(addr)));
        end if;
    end process;
    
end Behavioral;