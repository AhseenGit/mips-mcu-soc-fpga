library IEEE;
use ieee.std_logic_1164.all;
USE work.cond_comilation_package.all;


package aux_package is

component MIPS_SoC IS
	generic( 
			WORD_GRANULARITY : boolean 	:= G_WORD_GRANULARITY;
	        MODELSIM : integer 			:= G_MODELSIM;
			DATA_BUS_WIDTH : integer 	:= 32;
			ITCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			DTCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			PC_WIDTH : integer 			:= 10;
			FUNCT_WIDTH : integer 		:= 6;
			DATA_WORDS_NUM : integer 	:= G_DATA_WORDS_NUM;
			CLK_CNT_WIDTH : integer 	:= 16;
			INST_CNT_WIDTH : integer 	:= 16
	);
		PORT(	rst_i		 		:IN	STD_LOGIC;
			clk_i				:IN	STD_LOGIC;
            sw_i 			    :IN	STD_LOGIC_VECTOR(7 downto 0);
			leds_o              : OUT STD_LOGIC_VECTOR(7 downto 0);
            hex0_o,hex1_o,hex2_o,hex3_o,hex4_o,hex5_o              : OUT STD_LOGIC_VECTOR(7 downto 0)
	);			
END component;

--------------------------------------------------------
component DFF IS
    GENERIC (n : INTEGER := 32);  -- Default to 24 bits
    PORT (
        clk_i : IN std_logic;
        rst_i : IN std_logic;
		en_i  : IN std_logic;
        x_i   : IN std_logic_vector(n-1 downto 0);
        y_o   : OUT std_logic_vector(n-1 downto 0)
    );
END component;
--------------------------------------------------------
component BCTIMER is
    generic (reg_size : integer := 32);
    port (
        BTCCR0_i,BTCCR1_i : in std_logic_vector(reg_size-1 downto 0);
        BTCLR_i,BTHOLD_i : in std_logic;
		BTSSEL_i: in std_logic_vector(1 downto 0);
        MCLK_i,MCLK_2_i,MCLK_4_i,MCLK_8_i: in std_logic;
		BTOUTMD_i,BTOUTEN_i: in std_logic;
		BTIP_i:in std_logic_vector(1 downto 0);
		BTIFG_o : out std_logic;
        PWM_o : out std_logic
    );
end component;



--------------------------------------------------------
component Timer is
    generic (n: integer := 8);
    port (
        clk, enable, reset, clear : in std_logic;
        q : out std_logic_vector(n-1 downto 0)
    );
end component;

--------------------------------------------------------
component PWM is
    generic (n : integer := 16);
    port (
        clk_i, enable_i: in std_logic;
        PWM_Mode_i : in std_logic;
        x_i,q_i, y_i : in std_logic_vector(n-1 downto 0);
        PWM_O,HEU_o : out std_logic
    );
end component;

--------------------------------------------------------
component gpio IS
  PORT (
    clk        : IN  std_logic;
    rst        : IN  std_logic;
    addr       : IN  std_logic_vector(11 downto 0);
    mem_read         : IN  std_logic;
    mem_write         : IN  std_logic;
    write_data : IN  std_logic_vector(7 downto 0);
    read_data  : OUT std_logic_vector(7 downto 0);

    switches   : IN  std_logic_vector(7 downto 0);
    --keys    : IN  std_logic_vector(3 downto 0);
    leds       : OUT std_logic_vector(7 downto 0);
    hex0        : OUT std_logic_vector(7 downto 0); 
	hex1        : OUT std_logic_vector(7 downto 0); 
	hex2        : OUT std_logic_vector(7 downto 0); 
	hex3        : OUT std_logic_vector(7 downto 0); 
	hex4        : OUT std_logic_vector(7 downto 0); 
	hex5        : OUT std_logic_vector(7 downto 0)
  );
END component;
--------------------------------------------------------	
component MIPS IS
	generic( 
			WORD_GRANULARITY : boolean 	:= G_WORD_GRANULARITY;
	        MODELSIM : integer 			:= G_MODELSIM;
			DATA_BUS_WIDTH : integer 	:= 32;
			ITCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			DTCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			PC_WIDTH : integer 			:= 10;
			FUNCT_WIDTH : integer 		:= 6;
			DATA_WORDS_NUM : integer 	:= G_DATA_WORDS_NUM;
			CLK_CNT_WIDTH : integer 	:= 16;
			INST_CNT_WIDTH : integer 	:= 16
	);
	PORT(	rst_i		 		:IN	STD_LOGIC;
			clk_i				:IN	STD_LOGIC; 
			-- to data MEM
			dtcm_data_rd_i 		: IN STD_LOGIC_VECTOR(DATA_BUS_WIDTH downto 0);
		    dtcm_addr_o 		: out STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 downto 0);
		    dtcm_data_wr_o 		: out STD_LOGIC_VECTOR(DATA_BUS_WIDTH downto 0);
			MemRead_ctrl_o 		: out STD_LOGIC;
			MemWrite_ctrl_o 	: out STD_LOGIC;		
			-- Output important signals to pins for easy display in SignalTap
			pc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			alu_result_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data1_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			write_data_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			instruction_top_o	:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			Branch_ctrl_o		:OUT 	STD_LOGIC_VECTOR(1 downto 0);
			Zero_o				:OUT 	STD_LOGIC; 
			--MemWrite_ctrl_o		:OUT 	STD_LOGIC;
			RegWrite_ctrl_o		:OUT 	STD_LOGIC;
			mclk_cnt_o			:OUT	STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
			inst_cnt_o 			:OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0)
	);		
END component;
---------------------------------------------------------  
	component control is
		PORT( 	
		opcode_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct_i             : IN    STD_LOGIC_VECTOR(5 DOWNTO 0);
		RegDst_ctrl_o 		: OUT 	STD_LOGIC;
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC;
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 		: OUT 	STD_LOGIC;
		MemWrite_ctrl_o	 	: OUT 	STD_LOGIC;
		Branch_ctrl_o 		: OUT 	STD_LOGIC_VECTOR(1 downto 0);
		ALUOp_ctrl_o	 	: OUT 	STD_LOGIC_VECTOR(2 DOWNTO 0);
		JUMP_o              : OUT   STD_LOGIC
	);
	end component;
---------------------------------------------------------	
	component dmemory is
		generic(
		DATA_BUS_WIDTH : integer := 32;
		DTCM_ADDR_WIDTH : integer := 8;
		WORDS_NUM : integer := 256
	);
	PORT(	clk_i,rst_i			: IN 	STD_LOGIC;
			dtcm_addr_i 		: IN 	STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 DOWNTO 0);
			dtcm_data_wr_i 		: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			MemRead_ctrl_i  	: IN 	STD_LOGIC;
			MemWrite_ctrl_i 	: IN 	STD_LOGIC;
			dtcm_data_rd_o 		: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
	end component;
	
---------------------------------------------------------
component WB IS
	PORT( 
		ALU_Result, read_data	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		--pc_plus4               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);-- take from EXE
		MemtoReg      			: IN  STD_LOGIC;
		write_data 				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)		
		);
END 	component;
---------------------------------------------------------		
	component Execute is
		generic(
			DATA_BUS_WIDTH : integer := 32;
			FUNCT_WIDTH : integer := 6;
			PC_WIDTH : integer := 10
		);
		PORT(	
			read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			pc_plus4_i 		: IN 	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			OPC_i           : IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			addr_res_o 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			--WB
			JAL_o       	: out 	STD_LOGIC
		);
	end component;
---------------------------------------------------------		
	component Idecode is
		generic(
			DATA_BUS_WIDTH : integer := 32
		);
		PORT(	
			clk_i,rst_i		: IN 	STD_LOGIC;
			instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			dtcm_data_rd_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			alu_result_i	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegWrite_ctrl_i : IN 	STD_LOGIC;
			MemtoReg_ctrl_i : IN 	STD_LOGIC;
			RegDst_ctrl_i 	: IN 	STD_LOGIC;
			read_data1_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_o 	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			write_reg_data_i: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)			
		);
	end component;
---------------------------------------------------------		
	component Ifetch is
		generic(
			WORD_GRANULARITY : boolean 	:= False;
			DATA_BUS_WIDTH : integer 	:= 32;
			PC_WIDTH : integer 			:= 10;
			NEXT_PC_WIDTH : integer 	:= 8; -- NEXT_PC_WIDTH = PC_WIDTH-2
			ITCM_ADDR_WIDTH : integer 	:= 8;
			WORDS_NUM : integer 		:= 256;
			INST_CNT_WIDTH : integer 	:= 16
		);
		PORT(	
			clk_i, rst_i 	: IN 	STD_LOGIC;
			add_result_i 	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
        	Branch_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 downto 0);
        	zero_i 			: IN 	STD_LOGIC;	
			JUMP_i          : IN    STD_LOGIC;
			pc_o 			: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			pc_plus4_o 		: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			instruction_o 	: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			inst_cnt_o 		: OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0)	
		);
	end component;
	
	
---------------------------------------------------------
	COMPONENT PLL port(
	    areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0     		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC );
    END COMPONENT;
---------------------------------------------------------	

COMPONENT Shifter is 
  generic (
    N : integer := 8;
    K : integer := 3
  );
  port( 
    y    : in  std_logic_vector(N-1 downto 0);  
    x    : in  std_logic_vector(K-1 downto 0);  
    dir  : in  std_logic_vector(2 downto 0);    
    res  : out std_logic_vector(N-1 downto 0);  
    cout : out std_logic
  );
end COMPONENT;


-----PIPLINED-----

COMPONENT MEM_WB
    PORT (
        clk, rst       : IN  STD_LOGIC;
        ALU_Result_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Read_Data_in   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemtoReg_in    : IN  STD_LOGIC;
        RegWrite_in    : IN  STD_LOGIC;
        Write_Reg_in   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        ALU_Result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Read_Data_out  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemtoReg_out   : OUT STD_LOGIC;
        RegWrite_out   : OUT STD_LOGIC;
        Write_Reg_out  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
	
END COMPONENT;


end aux_package;

