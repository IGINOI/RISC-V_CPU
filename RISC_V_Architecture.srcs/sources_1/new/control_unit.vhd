----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2025 10:13:54
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

entity control_unit is
    Port ( 
        -- INPUTS
        clk: in std_logic;
        reset: in std_logic;
        instruction: in std_logic_vector(31 downto 0);
        rd_prev: in std_logic_vector(4 downto 0);
        stall_before: in std_logic;
        
        -- OUTPUTS
        program_counter_loader: out std_logic;
        read_write_enable_register: out std_logic;
        read_write_enable_memory: out std_logic;
        stall: out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is

    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal opcode : std_logic_vector(6 downto 0);
    signal prev_pc_enable : std_logic := '0';
    
    signal rs1 : std_logic_vector(4 downto 0);
    signal rs2 : std_logic_vector(4 downto 0);
    signal regwrite_prev : std_logic := '0';
    
    signal stall_counter : integer range 0 to 3 := 0;

begin
    
    -- Decomposing instruction.
    decomposition: process(clk)
    begin
        funct3 <= instruction(14 downto 12);
        funct7 <= instruction(31 downto 25);
        opcode <= instruction(6 downto 0);
        
        rs1 <= instruction(19 downto 15); -- Entering Decode
        rs2 <= instruction(24 downto 20);
    end process;
    
    -- rs1 and rs2 are entering the decode stage
    -- rd is entering the 
   process(clk)
    begin
        if rising_edge (clk) then
            if reset = '1' then
                program_counter_loader <= '0';
                read_write_enable_register <= '0';
                read_write_enable_memory <= '0';
                stall <= '0';
                regwrite_prev <= '0';
                stall_counter <= 0;
            else
                if prev_pc_enable = '0' then
                    prev_pc_enable <= '1';
                    program_counter_loader <= '1';
                else
                    prev_pc_enable <= '0';
                    program_counter_loader <= '0';
                end if;
                stall <= '0';
                -- DETECT DATA HAZARD
--                if stall_before = '1' then
--                    if stall_counter /= 0 then
--                        stall_counter <= stall_counter - 1;
--                    else 
--                        stall <= '0';
--                    end if;
--                else
--                    if (rd_prev = rs1 and rs1 /= "00000") or (rd_prev = rs2 and rs2 /= "00000") then
--                        stall <= '1';
--                        stall_counter <= 20;
--                    end if;
--                end if;
                
--                if stall_counter = 0 then
--                    stall <= '0';
----                    if regwrite_prev = '1' then
--                        if (rd_prev = rs1 and rs1 /= "00000") or (rd_prev = rs2 and rs2 /= "00000") then
--                            -- need to stall
--                            stall <= '1';
--                            stall_counter <= 20;
--                        else
--                            stall <= '0';
--                        end if;
----                    else
----                        stall <= '0';
----                    end if;
--                 else
--                    stall_counter <= stall_counter - 1;
--                 end if;
                 
--                case opcode is -- check needed for false positives
--                    when "0110011" | "0010011" | "0000011" | "0110111" | "0010111" | "1101111" | "1100111" =>
--                        regwrite_prev <= '1';
--                    when others =>
--                        regwrite_prev <= '0';
--                end case;
                
                
                -- DECODE WHETHER THERE IS NEED TO WRITE IN MEMORY OR IN REGISTER IN THE FUTURE
                case opcode is
                    ------------------------
                    -- R-TYPE INSTRUCTION --
                    ------------------------
                    when "0110011" =>
                        read_write_enable_register <= '1'; -- 0 read, 1 write
                        read_write_enable_memory <= '0'; -- 0 read, 1 write
                    
                    ------------------------
                    -- I-TYPE INSTRUCTION --
                    ------------------------
                    when "0010011" | "0000011" |  "1100111" =>
                        read_write_enable_register <= '1';
                        read_write_enable_memory <= '0';
                    
                    ------------------------
                    -- S-TYPE INSTRUCTION --
                    ------------------------
                    when "0100011" =>
                        read_write_enable_register <= '0';
                        read_write_enable_memory <= '1';
                    
                    ------------------------
                    -- B-TYPE INSTRUCTION --
                    ------------------------
                    when "1100011" =>
                        read_write_enable_register <= '0';
                        read_write_enable_memory <= '0';
                        
                    ------------------------
                    -- U-TYPE INSTRUCTION --
                    ------------------------
                    when "0110111" | "0010111" =>
                        read_write_enable_register <= '1';
                        read_write_enable_memory <= '0';
                    
                    ------------------------
                    -- J-TYPE INSTRUCTION --
                    ------------------------
                    when "1101111" =>
                        read_write_enable_register <= '1';
                        read_write_enable_memory <= '0';
                    
                    ------------------------
                    -- DAFAULT INTRUCTION --
                    ------------------------
                    when others =>
                        read_write_enable_register <= '0';
                        read_write_enable_memory <= '0';
                end case;
            end if;
         end if;
     end process;
    
    
--    -- Control Hazard >>> STALL THE PIPELINE
--    control_hazard: process(clk)
--    begin
--        if rising_edge(clk) then
--            if stall_counter = 0 then
--                -- Check for Control Hazards (Branch or Jump)
--                if (opcode = "1100011" or opcode = "1101111" or opcode = "1100111") then
--                    stall <= '1';
--                    stall_counter <= 100;
--                end if;
--            else
--                -- Reduce stall Counter
--                stall <= '1';
--                stall_counter <= stall_counter - 1;  -- Decrease counter each cycle
--            end if;
--        end if;
--    end process control_hazard;
    
    -- Data Hazard >>> STALL THE PIPELINE
--    hazard_detection : process (clk)
--    begin
--        if rising_edge(clk) and reset /= '1' then
--            if regwrite_prev = '1' then
--                if (rd_prev = rs1 and rs1 /= "00000") or (rd_prev = rs2 and rs2 /= "00000") then
--                    stall <= '1';
--                end if;
--            end if;
            
--            rd_prev <= instruction(11 downto 7); -- current rd
--            case opcode is
--                when "0110011" | "0010011" | "0000011" | "0110111" | "0010111" | "1101111" | "1100111" =>
--                    regwrite_prev <= '1';
--                when others =>
--                    regwrite_prev <= '0';
--            end case;
            
--        end if;
--    end process hazard_detection;


end Behavioral;
