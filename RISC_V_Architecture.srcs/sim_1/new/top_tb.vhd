----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2025 15:29:23
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is

    component top 
        port(
            -- INPUTS of the top block
            clk : in std_logic;
            reset : in std_logic
        );
    end component;
    
    signal clk: std_logic;
    signal reset: std_logic;
    
    -- Clock generation process
    constant clk_period : time := 10 ns;

begin

    clock: process
    begin
        clk <= '1';
        wait for clk_period;
        clk <= '0';
        wait for clk_period;
    end process;
    
    uut: top port map(
        clk => clk,
        reset => reset
    );
    
    stim_proc: process
    begin
        -- Test whether all the variables work correctly
        reset <= '0';
        
        wait for 2*clk_period;
        
        reset <= '1';
       
        wait for 2*clk_period;
        
        reset <= '0';
        
        
        wait;
    end process;

end Behavioral;
