----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: data_memory - Behavioral
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

entity data_memory is
  Port (
    --INPUTS
    clk : in std_logic;
    read_write_enable : in std_logic;
    memory_address : in std_logic_vector(31 downto 0); -- alu result
    write_value: in std_logic_vector(31 downto 0); -- register 2
    
    --OUTPUTS
    mem_out : out std_logic_vector(31 downto 0)
  );
end data_memory;

architecture Behavioral of data_memory is



    -- Define a memory array (custom type) for instructions (size: 31 instructions each of 32bit)
    type memory_type is array(0 to 4095) of std_logic_vector(31 downto 0);
    -- Define the signal of memory_type type
    signal data_file : memory_type := (
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
        others => x"00000000"
    );
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if (to_integer(unsigned(memory_address)) > 0 and to_integer(unsigned(memory_address)) <= 4095) then
                if read_write_enable = '0' then --we are reading 
                    mem_out <= data_file(to_integer(unsigned(memory_address)));
                else
                    data_file(to_integer(unsigned(memory_address))) <= write_value;
                end if;
            else
               mem_out <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;