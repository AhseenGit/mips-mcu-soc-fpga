LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;

ENTITY MIPS_SoC IS
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
END MIPS_SoC;

ARCHITECTURE structure OF MIPS_SoC IS
signal MCLK_w :STD_LOGIC;
signal dtcm_data_rd_w :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 downto 0);
signal data_mux_w     :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 downto 0);
signal	   dtcm_addr_w      :STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 downto 0);
signal	   dtcm_data_wr_w   :STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 downto 0);
signal	 	MemRead_ctrl_w  :STD_LOGIC;
signal	 	MemWrite_ctrl_w :STD_LOGIC;	
signal	 	memwr_en :STD_LOGIC;
signal	 	memrd_en :STD_LOGIC;			 					 
signal	 	pc_w		      : STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
signal	 	addr_w      : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
signal	 	read_data1_w      : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
signal	 	read_data2_w      : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
signal	 	write_data_w      : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
signal	 	instruction_top_w : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
signal	 	Branch_ctrl_w     : STD_LOGIC_VECTOR(1 downto 0);
signal	 	Zero_w		      : STD_LOGIC; 
--signal	 	MemWrite_ctrl_w   : STD_LOGIC;
signal	 	RegWrite_ctrl_w   : STD_LOGIC;
signal	 	mclk_cnt_w	      : STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
signal	 	inst_cnt_w 	      : STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);

--gpio signals
signal      read_data_gpio_w  : STD_LOGIC_VECTOR(7 DOWNTO 0);
--signal      leds_w            : STD_LOGIC_VECTOR(7 downto 0);
-- signal      hex0_w            : STD_LOGIC_VECTOR(7 downto 0); 
-- signal      hex1_w            : STD_LOGIC_VECTOR(7 downto 0); 
-- signal      hex2_w            : STD_LOGIC_VECTOR(7 downto 0); 
-- signal      hex3_w            : STD_LOGIC_VECTOR(7 downto 0); 
-- signal      hex4_w            : STD_LOGIC_VECTOR(7 downto 0); 
-- signal      hex5_w            : STD_LOGIC_VECTOR(7 downto 0); 
	    
BEGIN

	-- connect the PLL component
	G0:
	if (MODELSIM = 0) generate
	  MCLK: PLL
		PORT MAP (
			inclk0 	=> clk_i,
			c0 		=> MCLK_w
		);
	else generate
		MCLK_w <= clk_i;
	end generate;

mips_core: MIPS generic map ( 
			WORD_GRANULARITY,
	        MODELSIM,
			DATA_BUS_WIDTH,
			ITCM_ADDR_WIDTH,
			DTCM_ADDR_WIDTH,
			PC_WIDTH,
			FUNCT_WIDTH,
			DATA_WORDS_NUM,
			CLK_CNT_WIDTH,
			INST_CNT_WIDTH
	)
	port map (rst_i => rst_i,		   
			clk_i	=> clk_i,	  
			-- to data MEM                                                
			dtcm_data_rd_i   => data_mux_w,--dtcm_data_rd_w,-- from data mem                
		    dtcm_addr_o      => dtcm_addr_w,                              
		    dtcm_data_wr_o   =>  dtcm_data_wr_w,                          
			MemRead_ctrl_o   =>  MemRead_ctrl_w,                          
			MemWrite_ctrl_o  =>  MemWrite_ctrl_w,                                         				 
							                                            	 
			pc_o		     =>  	pc_w ,                                        	 
			alu_result_o     =>  	addr_w ,                                        	 
			read_data1_o     =>  	read_data1_w ,                                        	 
			read_data2_o     =>  	read_data2_w,                                        	 
			write_data_o     =>  	write_data_w,                                        	 
			instruction_top_o => 	instruction_top_w ,                                        	 
			Branch_ctrl_o    =>  	Branch_ctrl_w     ,                                        	 
			Zero_o		     =>  	Zero_w		      ,                                        	 
			--MemWrite_ctrl_o  =>  	MemWrite_ctrl_w   ,                                        	 
			RegWrite_ctrl_o  =>  	RegWrite_ctrl_w   ,                                        	 
			mclk_cnt_o	     =>  	mclk_cnt_w	      ,                                        	 
			inst_cnt_o 	     =>  	inst_cnt_w                                  
	);	


data_mux_w<= dtcm_data_rd_w when memrd_en='1' else x"000000"&read_data_gpio_w; 
memwr_en <= '1' when (to_integer(unsigned(addr_w(11 downto 0))) < 16#800# and MemWrite_ctrl_w = '1') else '0';

memrd_en <= '1' when (to_integer(unsigned(addr_w(11 downto 0))) < 16#800# and MemRead_ctrl_w = '1') else '0';    
G1: 
	if (WORD_GRANULARITY = True) generate -- i.e. each WORD has a uniqe address
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> MCLK_w,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> dtcm_addr_w, -- increment memory address by 4
				dtcm_data_wr_i 		=> dtcm_data_wr_w,
				MemRead_ctrl_i 		=> memrd_en, 
				MemWrite_ctrl_i 	=> memwr_en,
				dtcm_data_rd_o 		=> dtcm_data_rd_w 
			);	
	elsif (WORD_GRANULARITY = False) generate -- i.e. each BYTE has a uniqe address	
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> MCLK_w,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> dtcm_addr_w(DTCM_ADDR_WIDTH-1 DOWNTO 2)&"00",
				dtcm_data_wr_i 		=> dtcm_data_wr_w,
				MemRead_ctrl_i 		=> memrd_en, 
				MemWrite_ctrl_i 	=> memwr_en,
				dtcm_data_rd_o 		=> dtcm_data_rd_w                               
			);                                                                      
	end generate;                                                                   
   
gpio_init:  gpio
          
    PORT map(
    clk=> MCLK_w,       
    rst=> rst_i,       
    addr=>addr_w(11 downto 0),      
    mem_read=>not memrd_en,	
    mem_write=>not memwr_en,	 
    write_data=>dtcm_data_wr_w( 7 downto 0),
    read_data=> read_data_gpio_w,

    switches => sw_i,
    --keys    
    leds     =>leds_o,  
    hex0     =>hex0_o,    
	hex1     =>hex1_o,  
	hex2    =>hex2_o,   
	hex3    =>hex3_o,   
	hex4   =>hex4_o,    
	hex5   =>hex5_o   
  );			
             



       
                                                                                    
END structure; 