----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: decode - Behavioral
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

entity decode is
    Port (
        --INPUTS
        clk : in std_logic;
        instruction_in : in std_logic_vector(31 downto 0);
        stall: in std_logic;
        
        --OUTPUTS
        opclass : out std_logic_vector(4 downto 0);
        alu_opcode : out std_logic_vector(3 downto 0);
        a_sel : out std_logic; --used to select the first operand in the ALU
        b_sel : out std_logic; --used to select the second operand in the ALU
        cond_opcode : out std_logic_vector(1 downto 0);
        immediate_out: out std_logic_vector(31 downto 0);
        rs1_value: out std_logic_vector(31 downto 0);
        rs2_value: out std_logic_vector(31 downto 0);
        out_rd: out std_logic_vector(4 downto 0);
        
        -- FORWARD SIGNALS
        curr_pc_in : in std_logic_vector(31 downto 0);
        curr_pc_out : out std_logic_vector(31 downto 0);
        
        -- FROM SUBSEQUENT STAGES
        register_write_enable : in std_logic;
        rd_address : in std_logic_vector(4 downto 0);
        write_back_value : in std_logic_vector(31 downto 0)
        
        
        
    );
end decode;

architecture Behavioral of decode is
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal opcode : std_logic_vector(6 downto 0);

    signal rs_1 : std_logic_vector(4 downto 0);
    signal rs_2 : std_logic_vector(4 downto 0);

    
    component register_memory
        Port(
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
    end component;
    
begin

    -- Forward pc
    forward: process(clk)
    begin
        if rising_edge(clk) and stall = '0' then
            curr_pc_out <= curr_pc_in;
        end if;
    end process forward;
    
    -- Decode essential part of the isnstruction
    extract_info: process(clk)
    begin
        if stall = '0' then
            funct3 <= instruction_in(14 downto 12);
            funct7 <= instruction_in(31 downto 25);
            opcode <= instruction_in(6 downto 0);
         end if;
    end process extract_info;
    
    -- Reassable value
    reassamble_values: process(clk)
    begin
        if rising_edge(clk) and stall = '0' then
            case opcode is
                -- I-type instructions
                when "0010011" | "0000011" | "1100111" =>
                    immediate_out <= std_logic_vector(resize(signed(instruction_in(31 downto 20)),32));
                    rs_1 <= instruction_in(19 downto 15);
                    rs_2 <= (others => '0');
                    out_rd <= instruction_in(11 downto 7);
                
                -- S-type instructions
                when "0100011" =>
                    immediate_out <= std_logic_vector(resize(signed(instruction_in(31 downto 25) & instruction_in(11 downto 7)),32));
                    rs_1 <= instruction_in(19 downto 15);
                    rs_2 <= instruction_in(24 downto 20);
                    out_rd <= (others => '0');
                
                -- B-type instructions
                when "1100011" =>
                    immediate_out <= std_logic_vector(resize(signed(instruction_in(31) & instruction_in(7) & instruction_in(30 downto 25) & instruction_in(11 downto 8) & "0"),32));
                    rs_1 <= instruction_in(19 downto 15);
                    rs_2 <= instruction_in(24 downto 20);
                    out_rd <= (others => '0');     
                
                -- U-type instructions
                when "0110111" | "0010111" =>
                    immediate_out <= std_logic_vector(signed(instruction_in(31 downto 12) & "000000000000"));
                    rs_1 <= (others => '0');
                    rs_2 <= (others => '0');
                    out_rd <= instruction_in(11 downto 7);
                
                -- J-type instructions
                when "1101111" =>
                    immediate_out <= std_logic_vector(resize(signed(instruction_in(31) & instruction_in(19 downto 12) & instruction_in(20) & instruction_in(30 downto 21) & "0"),32));
                    rs_1 <= (others => '0');
                    rs_2 <= (others => '0');
                    out_rd <= instruction_in(11 downto 7);
                    
                when others =>
                    immediate_out <= (others => '0'); -- Default case (e.g. used by R-type instructions)
                    rs_1 <= instruction_in(19 downto 15);
                    rs_2 <= instruction_in(24 downto 20);
                    out_rd <= instruction_in(11 downto 7);
            end case;
        end if;
    end process reassamble_values;
    
    
    --Register Memory instantiation
    reg_mem_instantiation : register_memory
        port map (
            -- INPUT
            clk => clk,
            write_enable => register_write_enable,
            read_register_1 => rs_1,
            read_register_2 => rs_2,
            write_register_address => rd_address,
            write_back_value => write_back_value,
            
            r1_out => rs1_value,
            r2_out => rs2_value
        );

    
    -- Decode the instruction   
    decode_instruction: process(clk)
    begin
        if rising_edge(clk) and stall = '0' then
            case opcode is
                ------------------------
                -- R-TYPE INSTRUCTION --
                ------------------------
                when "0110011" =>
                    opclass <= "00001";  --Operational type instruction
                    a_sel <= '0'; --use rs1
                    b_sel <= '0'; --use rs2
                    cond_opcode <= "00";
                    case funct3 is
                        --ADD and SUB and MUL
                        when "000" =>
                            case funct7 is
                                --ADD
                                when "0000000" =>
                                    alu_opcode <= "0000";
                                --SUB
                                when "0100000" =>
                                    alu_opcode <= "0001";
                                --MUL
                                when "0000001" =>
                                    alu_opcode <= "0111";
                                when others =>
                                    alu_opcode <= "0000"; --Default
                            end case;
                        --SLL and MULH
                        when "001" =>
                            case funct7 is
                                --SLL
                                when "0000000" =>
                                    alu_opcode <= "0010";
                                --MULH
                                when "0000001" =>
                                    alu_opcode <= "1000";
                                --DEAFULT
                                when others =>
                                    alu_opcode <= "0010";
                            end case;
                        --SRL and DIVU
                        when "101" =>
                            case funct7 is
                                --SRL
                                when "0000000" =>
                                    alu_opcode <= "0011";
                                --DIVU
                                when "0000001" =>
                                    alu_opcode <= "1010";
                                --DEAFULT
                                when others =>
                                    alu_opcode <= "0011";
                            end case;
                        --XOR and DIV
                        when "100" =>
                            case funct7 is
                                --XOR
                                when "0000000" =>
                                    alu_opcode <= "0010";
                                --DIVs
                                when "0000001" =>
                                    alu_opcode <= "1000";
                                --DEAFULT
                                when others =>
                                    alu_opcode <= "0010";
                            end case;
                        --OR
                        when "110" =>
                            alu_opcode <= "0101";
                        --AND
                        when "111" =>
                            alu_opcode <= "0110";
                        --SLT
                        when "010" =>
                            alu_opcode <= "1011";
                        --IN ALL OTHER CASES
                        when others =>
                            alu_opcode <= "0000"; -- Default behavior
                    end case;
                    
                ------------------------
                -- I-TYPE INSTRUCTION --
                ------------------------
                when "0010011" | "0000011" |  "1100111" =>
                    case opcode is
                        when "0010011" => --Operational instruction 
                            opclass <= "00001";  --Operational instruction 
                            a_sel <= '0';  --use rs1    
                            b_sel <= '1';  --use immediate value 
                            cond_opcode <= "00";
                            
                            case funct3 is
                                --ADDI
                                when "000" =>
                                    alu_opcode <= "0000";
                                --SLLI
                                when "001" =>
                                    alu_opcode <= "0010";
                                --SRLI
                                when "101" =>
                                    alu_opcode <= "0011";
                                --XORI
                                when "100" =>
                                    alu_opcode <= "0010";
                                --ORI
                                when "110" =>
                                    alu_opcode <= "0101";
                                --ANDI
                                when "111" =>
                                    alu_opcode <= "0110";
                                --SLTI
                                when "010" =>
                                    alu_opcode <= "1011";
                                when others =>
                                    alu_opcode <= "0000";
                            end case;
                        
                        when "0000011" => --Load instruction
                            opclass <= "01000";
                            a_sel <= '0';  --use rs1    
                            b_sel <= '1';  --use immediate value
                            alu_opcode <= "0000";
                            cond_opcode <= "00";
                            ---------------------------
                            -- SOMETHING TO ADD HERE --
                            ---------------------------
                            
                        when "1100111" => --JALR instruction
                            opclass <= "10000";
                            a_sel <= '0';  --use rs1   
                            b_sel <= '1';  --use immediate value
                            alu_opcode <= "0000";
                            cond_opcode <= "00";
                            
                        when others =>
                            -- Default behavior for unrecognized opcodes
                            opclass <= "00000";  -- Set the default to no-op
                            alu_opcode <= "0000"; -- Default ALU operation
                            a_sel <= '0';         -- Default selection for ALU operand A
                            b_sel <= '0';         -- Default selection for ALU operand B
                            cond_opcode <= "00";  -- Default condition opcode
                            
                    end case;
                    
                ------------------------
                -- S-TYPE INSTRUCTION --
                ------------------------
                when "0100011" =>
                    opclass <= "00010";  --Store instruction 
                    a_sel <= '0'; --use rs1       
                    b_sel <= '1'; --use immediate value for offset
                    alu_opcode <= "0000";
                    cond_opcode <= "00"; 
                
                ------------------------
                -- B-TYPE INSTRUCTION --
                ------------------------
                when "1100011" =>
                    opclass <= "00100";  --Branch instruction
                    a_sel <= '1'; --use program counter
                    b_sel <= '1'; --use immediate value
                    alu_opcode <= "0000";
                    
                    case funct3 is
                        --BEQ
                        when "000" =>
                            cond_opcode <= "00";
                        --BNE
                        when "001" =>
                            cond_opcode <= "01";
                        --BLT
                        when "100" =>
                            cond_opcode <= "10";
                        --BGE
                        when "101" =>
                            cond_opcode <= "11";
                        when others =>
                            cond_opcode <= "00"; --default
                    end case;
                    
                ------------------------
                -- U-TYPE INSTRUCTION --
                ------------------------
                when "0110111" | "0010111" =>
                
                    if opcode = "0110111" then
                        opclass <= "00000";
                        a_sel <= '0';
                        b_sel <= '0';
                        alu_opcode <= "0000";
                        cond_opcode <= "00";
                    else
                        opclass <= "00000";
                        a_sel <= '1'; --use current pc
                        b_sel <= '1'; --use immediate value
                        alu_opcode <= "0000"; --sum
                        cond_opcode <= "00";
                    end if;
                
                ------------------------
                -- J-TYPE INSTRUCTION --
                ------------------------
                when "1101111" =>
                    opclass <= "10000";
                    a_sel <= '1'; --use program counter
                    b_sel <= '1'; --use immediate
                    alu_opcode <= "0000";
                    cond_opcode <= "00";
                
                ------------------------
                -- DAFAULT INTRUCTION --
                ------------------------
                when others =>
                    opclass <= "00000";  -- Set default values for outputs
                    alu_opcode <= "0000";
                    a_sel <= '0';
                    b_sel <= '0';
                    cond_opcode <= "00";
                    
            end case;
        end if;
    end process decode_instruction;

end Behavioral;