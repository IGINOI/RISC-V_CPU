----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: fetch - Behavioral
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

entity fetch is
    Port ( 
        --INPUTS
        clk : in std_logic;
        reset : in std_logic;
        load_enable : in std_logic;
        pc_in : in std_logic_vector(31 downto 0); --our memory uses 1024 words (10bits)
        
        --OUTPUTS
        instruction_out : out std_logic_vector(31 downto 0);
        next_pc_out : out std_logic_vector(31 downto 0);
        curr_pc_out : out std_logic_vector(31 downto 0)
    );
end fetch;

architecture Behavioral of fetch is
    
    --Used to address the instruction memory
    signal current_pc : std_logic_vector(31 downto 0);
    
    --Intruction memory component
    component instruction_memory
        Port(
            -- INPUTS
            clk: in std_logic;
            addr: in std_logic_vector(31 downto 0);
            -- OUTPUT
            instruction_out : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    
    load_reset: process (clk)
    begin
        -- I want to make it synchronous. So I check the clk as first thing
        if rising_edge(clk) then
            if reset = '1' then
                current_pc <= (others => '0');  -- If reset is clicked, the pc goes to 0
                curr_pc_out <= (others => '0');   --Also the current pc goes to 0
                next_pc_out <= (others => '0');
                next_pc_out(0) <= '1';   --Next pc instead goes to 1
            else 
                if load_enable = '1' then
                    current_pc <= pc_in;
                    curr_pc_out <= pc_in;
                    next_pc_out <= std_logic_vector(unsigned(pc_in) + 1);                    
                end if;
            end if;
        end if; 
    end process;
    
    -- Instantiate and connect the instruction memory
    instr_mem_instantiation : instruction_memory
        port map (
            clk => clk,
            addr => current_pc,
            instruction_out => instruction_out
        );

end Behavioral;