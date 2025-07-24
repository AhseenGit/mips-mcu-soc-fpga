
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS_tb IS
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
END MIPS_tb ;


ARCHITECTURE struct OF MIPS_tb IS
   -- Internal signal declarations
   SIGNAL rst_tb_i           	: STD_LOGIC;
   SIGNAL clk_tb_i           	: STD_LOGIC;
   
   SIGNAL alu_result_tb_o  		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL Branch_ctrl_tb_o      : STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL instruction_top_tb_o 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL MemWrite_ctrl_tb_o    : STD_LOGIC;
   SIGNAL pc_tb_o              	: STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0 );
   SIGNAL RegWrite_ctrl_tb_o    : STD_LOGIC;
   --SIGNAL Zero_tb_o        		: STD_LOGIC;
   SIGNAL read_data1_tb_o 		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL read_data2_tb_o 		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL write_data_tb_o  		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL mclk_cnt_tb_o			: STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
   SIGNAL inst_cnt_tb_o 		: STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
   --signal gpio
   SIGNAL sw_w,leds_w           : STD_LOGIC_VECTOR(8-1 DOWNTO 0);
   SIGNAL hex0_w,hex1_w,hex2_w,hex3_w,hex4_w,hex5_w           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   
BEGIN
	MIPS_MCU : MIPS_SoC
	generic map(
		WORD_GRANULARITY 			=> WORD_GRANULARITY,
	    MODELSIM 					=> MODELSIM,
		DATA_BUS_WIDTH				=> DATA_BUS_WIDTH,
		ITCM_ADDR_WIDTH				=> ITCM_ADDR_WIDTH,
		DTCM_ADDR_WIDTH				=> DTCM_ADDR_WIDTH,
		PC_WIDTH					=> PC_WIDTH,
		FUNCT_WIDTH					=> FUNCT_WIDTH,
		DATA_WORDS_NUM				=> DATA_WORDS_NUM,
		CLK_CNT_WIDTH				=> CLK_CNT_WIDTH,
		INST_CNT_WIDTH				=> INST_CNT_WIDTH
	)
	PORT MAP (
		rst_i           	=> rst_tb_i,
		clk_i           	=> clk_tb_i,
		sw_i 			    =>sw_w,
	    leds_o              =>leds_w,
        hex0_o=>hex0_w,
		hex1_o=>hex1_w,
		hex2_o=>hex2_w,
		hex3_o=>hex3_w,
		hex4_o=>hex4_w,
		hex5_o =>hex5_w              
	);
sw_w <= "00000001";	
--------------------------------------------------------------------	
	gen_clk : 
	process
        begin
		  clk_tb_i <= '1';
		  wait for 50 ns;
		  clk_tb_i <= not clk_tb_i;
		  wait for 50 ns;
    end process;
	
	gen_rst : 
	process
        begin
		  rst_tb_i <='1','0' after 80 ns;
		  wait;
    end process;
--------------------------------------------------------------------		
END struct;
