---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
--USE IEEE.NUMERIC_STD.ALL;
USE work.aux_package.all;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;




ENTITY  Execute IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6;
		PC_WIDTH : integer := 10
	);
	PORT(	read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0); --change to 3 bits
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			pc_plus4_i 		: IN 	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			OPC_i           : IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			addr_res_o 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			--
			JAL_o 	        : out 	STD_LOGIC
	);
END Execute;


ARCHITECTURE behavior OF Execute IS
SIGNAL a_input_w, b_input_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL alu_out_mux_w			: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL branch_addr_r 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL alu_ctl_w				: STD_LOGIC_VECTOR(3 DOWNTO 0);
signal shift_result_w           : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
signal cout_w                   : STD_LOGIC;  
signal shamt_w                  : STD_LOGIC_VECTOR(4 downto 0);
signal dir_w                    : STD_LOGIC_VECTOR(2 downto 0);

BEGIN
	a_input_w <= 	read_data1_i;
	-- ALU input mux
	b_input_w <= 	read_data2_i WHEN (ALUSrc_ctrl_i = '0') ELSE-- register
					sign_extend_i(DATA_BUS_WIDTH-1 DOWNTO 0);-- SE for addi,ori...
					
	shamt_w <= sign_extend_i(10 downto 6);  
	dir_w   <= "000" when (funct_i="000000" and ALUOp_ctrl_i="010") else "001" when (funct_i="000010" and ALUOp_ctrl_i="010") else "111" ;
--------------------------------------------------------------------------------------------------------
--  Generate ALU control bits
--------------------------------------------------------------------------------------------------------
process(ALUOp_ctrl_i, funct_i, OPC_i)
begin
  case ALUOp_ctrl_i is
  
    when "000" =>
	    case OPC_i IS
	     
			when "000011"  => alu_ctl_w<= "1011";--JAL
			--when "011100"  => alu_ctl_w<= "1001";--MUL
			when others   => alu_ctl_w<= "0010"; -- SW, LW
		end case;
	when "001"=>
	    alu_ctl_w <= "0110";-- Branch
		 
    when "010" => -- R-type: use funct
      case funct_i is
        when "100000" => alu_ctl_w <= "0010"; -- ADD
        when "100001" => alu_ctl_w <= "0010"; -- ADDU
        when "100010" => alu_ctl_w <= "0110"; -- SUB
        when "100100" => alu_ctl_w <= "0000"; -- AND
        when "100101" => alu_ctl_w <= "0001"; -- OR
        when "100110" => alu_ctl_w <= "0011"; -- XOR
        when "001000" => alu_ctl_w <= "1000"; -- JR
        when "000000" => alu_ctl_w <= "0100"; -- SLL
        when "000010" => alu_ctl_w <= "0101"; -- SRL
		when "101010" => alu_ctl_w <= "0111"; -- SLT
        when others   => alu_ctl_w <= "1111"; -- Illegal funct
      end case;
	  
	when "100" =>
	   case OPC_i IS
	    when "001000" => alu_ctl_w <= "0010"; -- ADDI
		when "001001" => alu_ctl_w <= "0010"; -- ADDIU
	    when "001100" => alu_ctl_w <= "0000"; -- ANDI
		when "001101" => alu_ctl_w <= "0001"; -- ORI
		when "001110" => alu_ctl_w <= "0011"; -- XORI
		when "001010" => alu_ctl_w <= "0111"; -- SLTI
		when "001111" => alu_ctl_w <= "1010"; -- LUI
        when others   => alu_ctl_w <= "1111"; -- Illegal funct
      end case;
    when "110" => 
	     alu_ctl_w <= "1001";--MUTIPY 
	  
    when others =>
      alu_ctl_w <= "1111"; -- Illegal ALUOp

  end case;
end process;


--------------------------------------------------------------------------------------------------------
	
	-- Generate Zero Flag
	zero_o <= 	'1' WHEN (alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0) = X"00000000") ELSE
				'0';    
	
	-- Select ALU output        
	alu_res_o <= 	X"0000000" & B"000"  & alu_out_mux_w(31) WHEN  alu_ctl_w = "0111" ELSE 
					alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0);
					
	-- Adder to compute Branch Address
	branch_addr_r	<= pc_plus4_i(PC_WIDTH-1 DOWNTO 2) + sign_extend_i(7 DOWNTO 0) ;
	addr_res_o 		<= alu_out_mux_w(PC_WIDTH-1 DOWNTO 2) when(ALUOp_ctrl_i="010" and funct_i="001000") ELSE branch_addr_r(7 DOWNTO 0);-- JR


PROCESS (alu_ctl_w, a_input_w, b_input_w)
	variable mul_result_v : STD_LOGIC_VECTOR(63 DOWNTO 0);
	BEGIN		
 	CASE alu_ctl_w IS	-- Select ALU operation
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	alu_out_mux_w 	<= a_input_w AND b_input_w;  -- and/andi
		
						-- ALU performs ALUresult = A_input OR B_input  
     	WHEN "0001" 	=>	alu_out_mux_w 	<= a_input_w OR b_input_w; -- or/ori
		
						-- ALU performs ALUresult = A_input + B_input 
	 	WHEN "0010" 	=>	alu_out_mux_w 	<= a_input_w + b_input_w; --add/addi/sw/lw/addu
		
						-- ALU performs sll/srl
 	 	WHEN "0011" =>   alu_out_mux_w <= shift_result_w;

						-- ALU performs xor
 	 	WHEN "0100" 	=>	alu_out_mux_w 	<= a_input_w xor b_input_w; -- xor/xori
		
						-- ALU performs 
 	 	WHEN "0101" 	=>	alu_out_mux_w <= x"00000000";
		
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	alu_out_mux_w 	<= a_input_w - b_input_w; -- sub reg R-type/branch
		
						-- ALU performs SLT/SLTi
  	 	WHEN "0111" 	=>	alu_out_mux_w 	<= a_input_w - b_input_w ;
		
							-- ALU performs JR
  	 	WHEN "1000" 	=>	alu_out_mux_w 	<= a_input_w;
		
										-- ALU performs MULTIPY
        WHEN "1001" =>
							  mul_result_v := std_logic_vector(unsigned(a_input_w) * unsigned(b_input_w));

							  alu_out_mux_w <= mul_result_v(31 DOWNTO 0);
															-- ALU performs LUI
  	 	WHEN "1010" 	=>	alu_out_mux_w 	<= b_input_w(15 DOWNTO 0) & x"0000";
		
							    -- ALU performs JAL
  	 	WHEN "1011" 	=>	alu_out_mux_w 	<= x"00000" & "00" & pc_plus4_i ;
		
		
 	 	WHEN OTHERS	=>	alu_out_mux_w 	<= X"00000000" ;
  	END CASE;
  END PROCESS;

--- port Shifter------------------------------
Shift: Shifter generic map (DATA_BUS_WIDTH,5) port map (b_input_w,shamt_w,dir_w,shift_result_w,cout_w);

----for WB-----
JAL_o <= '1' when OPC_i="000011" else '0';
END behavior;

