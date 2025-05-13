----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: register_memory - Behavioral
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

entity register_memory is
    Port (
        --inputs
        clk : in std_logic;
        write_enable : in std_logic; -- 0=>read    1=>write
        
        read_register_1 : in std_logic_vector(4 downto 0);
        read_register_2 : in std_logic_vector(4 downto 0);
        write_register_address : in std_logic_vector(4 downto 0);
        write_back_value : in std_logic_vector(31 downto 0);  --write back register from memory
        
        --outputs
        r1_out : out std_logic_vector(31 downto 0);
        r2_out : out std_logic_vector(31 downto 0)
    );
end register_memory;

architecture Behavioral of register_memory is

    -- Define a memory array (custom type) for instructions (size: 31 instructions each of 32bit)
    type memory_type is array(0 to 31) of std_logic_vector(31 downto 0);
    -- Define the signal of memory_type type
    signal register_file : memory_type := (
        -- x"00000033" is the exadecimal code for the NOP (No operation) instruction => (ADD x0, x0, x0)
        0 => x"00000000", -- always 0
        1 => x"00000000",
        2 => x"00000000",
        3 => x"00000000",
        4 => x"00000000",
        5 => x"00000000",
        6 => x"00000000",
        7 => x"00000000",
        8 => x"00000000",
        9 => x"00000000",
        10 => x"00000000",
        others => x"00000000"
    );
    
begin

    --READING PROCESS: not sensitive to the clock since the reading can also be asynchronous
    process(clk)
    begin
        --reading the 1st register
        if read_register_1 = "00000" then
            --if rs1 is "00000" it is reffering to X0 which is always 0
            r1_out <= (others => '0');
        else
            --otherwise I extract the value from the register memory
            r1_out <= register_file(to_integer(unsigned(read_register_1)));
        end if;
        
        --reading the 2nd register
        if read_register_2 = "00000" then
            r2_out <= (others => '0');
        else
            r2_out <= register_file(to_integer(unsigned(read_register_2)));
        end if;
    end process;
    
    --WRITING BACK PROCESS
    process(clk)
    begin
        if write_enable='1' and write_register_address /= "00000" then --different from 0 since I cannot write there
            register_file(to_integer(unsigned(write_register_address))) <= write_back_value;
        end if;
    end process;

end Behavioral;