----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: write_back - Behavioral
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
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity write_back is
  Port (
    --INPUTS
    clk : in std_logic;
    alu_result : in std_logic_vector(31 downto 0);
    op_class : in std_logic_vector(4 downto 0);
    mem_out : in std_logic_vector(31 downto 0);
    in_forward_instruction_write_enable: in std_logic;
    in_forward_rd: in std_logic_vector(4 downto 0);
    
    --OUTPUTS
    rd_value : out std_logic_vector(31 downto 0);
    out_forward_instruction_write_enable: out std_logic;
    out_forward_rd: out std_logic_vector(4 downto 0)
  );
end write_back;

architecture Behavioral of write_back is

begin

     compute_write_back_value: process(clk)
     begin
        if rising_edge(clk) then
            --Assign the value to rd_value
            if op_class = "00001" then --ALU operation
                rd_value <= alu_result;      
            elsif op_class = "01000" then --LOAD operation
                rd_value <= mem_out;
            elsif op_class = "10000" then --JUMP operation
                --rd_value <= next_pc;
            else
                rd_value <= (others => '0');  -- STORE & BRANCH
            end if;
            
            -- Forward some signals
            out_forward_instruction_write_enable <= in_forward_instruction_write_enable;
            out_forward_rd <= in_forward_rd;
        end if;
    end process compute_write_back_value;

end Behavioral;