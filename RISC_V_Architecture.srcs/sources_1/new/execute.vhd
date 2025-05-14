----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: execute - Behavioral
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

entity execute is
  Port (
    --INPUTS
    clk : in std_logic;
    reset : in std_logic;
    a_sel : in std_logic;
    rs1_value : in std_logic_vector(31 downto 0);
    immediate_value : in std_logic_vector(31 downto 0);
    b_sel : in std_logic;
    rs2_value : in std_logic_vector(31 downto 0);
    curr_pc : in std_logic_vector(31 downto 0);
    cond_opcode : in std_logic_vector(1 downto 0);
    alu_opcode : in std_logic_vector(3 downto 0);
    
    
    
     
    --OUTPUTS
    branch_cond : out std_logic;
    alu_result : out std_logic_vector(31 downto 0);
      
    -- FORWARD
    curr_pc_out : out std_logic_vector(31 downto 0);
    in_forward_instruction_write_enable : in std_logic;
    out_forward_instruction_write_enable : out std_logic;
    in_forward_memory_write_enable : in std_logic;
    out_forward_memory_write_enable : out std_logic;
    in_forward_rd : in std_logic_vector(4 downto 0);
    out_forward_rd : out std_logic_vector(4 downto 0);
    out_forward_rs2_value : out std_logic_vector(31 downto 0);
    in_op_class : in std_logic_vector(4 downto 0);
    out_op_class: out std_logic_vector(4 downto 0);
    prova: out std_logic_vector(31 downto 0)
    
    
  );
end execute;

architecture Behavioral of execute is
    
    signal alu_in1 : std_logic_vector(31 downto 0);
    signal alu_in2 : std_logic_vector(31 downto 0);
    signal full_result : unsigned(63 downto 0);
    signal branch_condition_result: std_logic;
    
begin
    
    forward: process(clk)
    begin
        if rising_edge(clk) then
            curr_pc_out <= curr_pc;
            out_forward_instruction_write_enable <= in_forward_instruction_write_enable;
            out_forward_memory_write_enable <= in_forward_memory_write_enable;
            out_forward_rd <= in_forward_rd;
            out_forward_rs2_value <= rs2_value;
            out_op_class <= in_op_class;
        end if;
    end process;
    
    -- Input selection for ALU
    select_operand: process(clk)
    begin
        case a_sel is
            when '0' =>
                alu_in1 <= rs1_value;
            when others =>
                alu_in1 <= curr_pc;
        end case;
        
        case b_sel is
            when '0' =>
                alu_in2 <= rs2_value; 
            when others =>
                alu_in2 <= immediate_value;      
        end case;
    end process select_operand;
    
    -- Comparator
    comparator: process(clk)
    begin
        if rising_edge(clk) then
            case cond_opcode is
                when "00" =>  -- rs1==rs2
                    if (unsigned(rs1_value) = unsigned(rs2_value)) then
                        branch_condition_result <= '1';
                    else
                        branch_condition_result <= '0';
                    end if;
                    
                when "01" =>  -- rs1!=rs2
                    if (rs1_value /= rs2_value) then
                        branch_condition_result <= '1';
                    else
                        branch_condition_result <= '0';
                    end if;
                
                when "10" =>  -- rs1<rs2
                    if (rs1_value < rs2_value) then
                        branch_condition_result <= '1';
                    else
                        branch_condition_result <= '0';
                    end if;
                
                when others =>  -- rs1>=rs2
                    if (rs1_value >= rs2_value) then
                        branch_condition_result <= '1';
                    else
                        branch_condition_result <= '0';
                    end if;
            end case;
        end if;
    end process comparator;
    
    -- Control if branching is needed
    branch: process(clk)
    begin
        if rising_edge(clk) then
            if branch_condition_result = '1' then
                if (in_op_class = "00100" or in_op_class = "10000") then
                    branch_cond <= '1';
                else
                    branch_cond <= '0';
                end if;
            else
                branch_cond <= '0';
            end if;
        end if;
    end process branch;
    
    
    -- ALU Logic
    ALU: process(clk) 
    begin
        if rising_edge(clk) then
            case alu_opcode is
                when "0000" => -- ADD
                    alu_result <= std_logic_vector(unsigned(alu_in1) + unsigned(alu_in2));
                    if in_forward_memory_write_enable = '1' then
                        prova <= std_logic_vector(unsigned(alu_in1) + unsigned(alu_in2));
                    end if;
                when "0001" => -- SUB
                    alu_result <= std_logic_vector(unsigned(alu_in1) - unsigned(alu_in2));
                when "0010" => -- SLL
                    alu_result <= std_logic_vector(shift_left(unsigned(alu_in1), to_integer(unsigned(alu_in2))));
                when "0011" => -- SLR
                    alu_result <= std_logic_vector(shift_right(unsigned(alu_in1), to_integer(unsigned(alu_in2))));
                when "0100" => -- XOR
                    alu_result <= std_logic_vector(unsigned(alu_in1) xor unsigned(alu_in2));
                when "0101" => -- OR
                    alu_result <= std_logic_vector(unsigned(alu_in1) or unsigned(alu_in2));
                when "0110" => -- AND
                    alu_result <= std_logic_vector(unsigned(alu_in1) and unsigned(alu_in2));
                when "0111" => -- MUL
                    alu_result <= std_logic_vector(unsigned(alu_in1) * unsigned(alu_in2));
                when "1000" => -- MULH
                    full_result <= unsigned(alu_in1) * unsigned(alu_in2);
                    alu_result <= std_logic_vector(full_result(63 downto 32));
                when "1001" => -- DIV
                    alu_result <= std_logic_vector(signed(alu_in1) / signed(alu_in2));
                when "1010" => -- DIVU
                    alu_result <= std_logic_vector(unsigned(alu_in1) / unsigned(alu_in2));
                when "1011" => -- SLT
                    if (alu_in1 > alu_in2) then
                        alu_result <= (others => '0');
                    else
                        alu_result <= (others => '0');
                        alu_result(0) <= '1';
                    end if;   
                when others => -- ADD
                    alu_result <= std_logic_vector(unsigned(alu_in1) + unsigned(alu_in2));             
            end case;
        end if;
    end process ALU;
end Behavioral;