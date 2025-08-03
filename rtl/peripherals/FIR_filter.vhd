LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;

entity FIR is
    generic (reg_size : integer := 32;
			k : integer := 8;
	        q: integer := 8;
			W: integer := 24;
			M: integer := 8);
    port (
        FIRIN_i: in std_logic_vector(reg_size-1 downto 0);
        FIFORST_i,FIFOCLK_i : in std_logic;
		FIFOWEN_i : in std_logic;
		FIFOFULL,FIFOEMPTY: out std_logic;
		
        FIRCLK_i,FIRRST_i: in std_logic;
		FIRENA_i: in std_logic;
		FIRIFG_o: out std_logic;
		COEF0_i,COEF1_i,COEF2_i,COEF3_i:in std_logic_vector(q-1 downto 0);
		COEF4_i,COEF5_i,COEF6_i,COEF7_i:in std_logic_vector(q-1 downto 0);
        FIROUT_o : out std_logic_vector(reg_size-1 downto 0)
    );
end FIR;
architecture behavior of FIR is
----------------------------- FIFO Signals ----------------------------------
  type mem_array is array(0 to k - 1) of std_logic_vector(reg_size-1 downto 0);
  signal mem : mem_array:= (others => (others => '0'));
  signal wr_ptr : integer range 0 to k-1 := 0;
  signal rd_ptr : integer range 0 to k-1 := 0;
  signal count  : integer range 0 to k := 0;
  signal FIFO_out: std_logic_vector(reg_size-1 downto 0);
  signal FIFOREN_w: std_logic;
  type dff_array_t is array(0 to M - 1) of std_logic_vector(W-1 downto 0);
  signal dff_array : dff_array_t;
  type   coef_array_t is array(0 to M - 1) of std_logic_vector(q-1 downto 0);
  signal coef_array : coef_array_t;
  type   res_array_t is array(0 to M - 1) of std_logic_vector(w+q-1 downto 0);
  signal res_array : res_array_t;
  signal y_w:std_logic_vector(w+q-1 downto 0);
-----------------------------------------------------------------------------

begin

 ----------------------------- FIFO ----------------------------------
  process(FIFOCLK_i)
  begin
    if FIFORST_i = '1' then
        wr_ptr <= 0;
        count  <= 0;
		rd_ptr <= 0;
        FIFO_out <= (others => '0');
	elsif rising_edge(FIFOCLK_i) then
      if FIFOWEN_i = '1' and count < k then -- the FIFO is full
        mem(wr_ptr) <= x"00"&FIRIN_i(23 downto 0);
        wr_ptr <= (wr_ptr + 1) mod k;
        count  <= count + 1;
	  if FIFOREN_w = '1' and count > 0 then -- the FIFO is not empty
        FIFO_out <= mem(rd_ptr);
        rd_ptr <= (rd_ptr + 1) mod k;
        count  <= count - 1;
      end if;
	  end if;
    end if;
  end process;
  
  FIFOFULL  <= '1' when count = k else '0';
  FIFOEMPTY <= '1' when count = 0 else '0';
------------------------------------------------------------------------
    pulse_sync: FIFOREN_w<= '1' when rising_edge(FIFOCLK_i) and rising_edge(FIRCLK_i) and (FIRENA_i='1') else '0'; 

    dff_array(0)<=FIFO_out(W-1 downto 0);
	
    -- Generate DFFs
    rest : for i in 1 to M-1 generate
        chain : DFF generic map (W)
		port map(
            clk_i => FIRCLK_i,
            rst_i => FIRRST_i,
			en_i  => FIRENA_i,
            x_i => dff_array(i-1),
            y_o => dff_array(i)
        );
    end generate;
	
	coef_array(0)<= COEF0_i;
	coef_array(1)<= COEF1_i;
	coef_array(2)<= COEF2_i;
	coef_array(3)<= COEF3_i;
	coef_array(4)<= COEF4_i;
	coef_array(5)<= COEF5_i;
	coef_array(6)<= COEF6_i;
	coef_array(7)<= COEF7_i;
	res_array(0) <= std_logic_vector(unsigned(dff_array(0)) * unsigned(coef_array(0)));
	
    mul_sum : for i in 1 to M-1 generate
       res_array(i) <= std_logic_vector( unsigned(dff_array(i)) * unsigned(coef_array(i)) + unsigned(res_array(i-1)));  
    end generate;
	
	final: DFF generic map (W)
		port map(
            clk_i => FIRCLK_i,
            rst_i => FIRRST_i,
			en_i  => FIRENA_i,
            x_i => res_array(M-1),
            y_o => y_w
        );
		
	FIROUT_o<="00000000"&y_w(w-1 downto 0);
	
end behavior;  