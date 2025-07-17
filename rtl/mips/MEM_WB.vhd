-- MEM_WB.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MEM_WB IS
    PORT (
        clk, rst       : IN  STD_LOGIC;
        -- Inputs from MEM stage
        ALU_Result_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Read_Data_in   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemtoReg_in    : IN  STD_LOGIC;
        RegWrite_in    : IN  STD_LOGIC;
        Write_Reg_in   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Outputs to WB stage
        ALU_Result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Read_Data_out  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemtoReg_out   : OUT STD_LOGIC;
        RegWrite_out   : OUT STD_LOGIC;
        Write_Reg_out  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END MEM_WB;

ARCHITECTURE behavior OF MEM_WB IS
    SIGNAL ALU_Result_reg, Read_Data_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MemtoReg_reg, RegWrite_reg    : STD_LOGIC;
    SIGNAL Write_Reg_reg                 : STD_LOGIC_VECTOR(4 DOWNTO 0);
BEGIN
    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            ALU_Result_reg <= (others => '0');
            Read_Data_reg  <= (others => '0');
            MemtoReg_reg   <= '0';
            RegWrite_reg   <= '0';
            Write_Reg_reg  <= (others => '0');
        ELSIF rising_edge(clk) THEN
            ALU_Result_reg <= ALU_Result_in;
            Read_Data_reg  <= Read_Data_in;
            MemtoReg_reg   <= MemtoReg_in;
            RegWrite_reg   <= RegWrite_in;
            Write_Reg_reg  <= Write_Reg_in;
        END IF;
    END PROCESS;

    -- Output assignments
    ALU_Result_out <= ALU_Result_reg;
    Read_Data_out  <= Read_Data_reg;
    MemtoReg_out   <= MemtoReg_reg;
    RegWrite_out   <= RegWrite_reg;
    Write_Reg_out  <= Write_Reg_reg;
END behavior;
