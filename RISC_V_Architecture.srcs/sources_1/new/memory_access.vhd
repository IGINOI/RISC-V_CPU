----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: memory_access - Behavioral
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

entity memory_access is
  Port (
    --INPUTS
    clk : in std_logic;
    alu_result : in std_logic_vector(31 downto 0);
    rs2_value : in std_logic_vector(31 downto 0);
    mem_we : in std_logic;
    prova: in std_logic_vector(31 downto 0);
    
    --OUTPUTS
    alu_result_out : out std_logic_vector(31 downto 0);
    mem_out : out std_logic_vector(31 downto 0);
    
    --FORWARD
    in_forward_instruction_write_enable: in std_logic;
    out_forward_instruction_write_enable: out std_logic;
    in_forward_rd : in std_logic_vector(4 downto 0);
    out_forward_rd : out std_logic_vector(4 downto 0);
    in_opclass : in std_logic_vector(4 downto 0);
    out_opclass: out std_logic_vector(4 downto 0)
    
  );
end memory_access;

architecture Behavioral of memory_access is
    
    component data_memory
        Port(
            --INPUTS
            clk : in std_logic;
            read_write_enable : in std_logic;
            memory_address : in std_logic_vector(31 downto 0);
            write_value: in std_logic_vector(31 downto 0);
            
            --OUTPUTS
            mem_out : out std_logic_vector(31 downto 0)
        );
    end component;
    
begin
    
    -- Instantiate and connect the instruction memory
    data_mem_instantiation : data_memory
        port map (
            -- INPUTS
            clk => clk,
            read_write_enable => mem_we,
            memory_address => prova,
            write_value => rs2_value,
            
            --OUTPUTS
            mem_out => mem_out
        );
    
    -- Forward signals
    forward: process(clk)
    begin
        if rising_edge(clk) then
            alu_result_out <= alu_result;
            out_forward_instruction_write_enable <= in_forward_instruction_write_enable;
            out_forward_rd <= in_forward_rd;
            out_opclass <= in_opclass;
        end if;
     end process forward;
end Behavioral;