LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;

entity FIR is
    generic (reg_size : integer := 32,
	        q: integer := 8,
			W: integer := 24,
			M: integer := 8);
    port (
        FIRIN_i: in std_logic_vector(reg_size-1 downto 0);
        FIFORST_i,FIFOCLK_i : in std_logic;
		FIFOWEN_i,FIFOREN_i : in std_logic;
		FIFOFULL,FIFOEMpTY: out std_logic;
        FIRCLK_i,FIRRST_i: in std_logic;
		FIRENA_i: in std_logic;
		FIRIFG_o: out std_logic;
		COEF0_i,COEF1_i,COEF2_i,COEF3_i:in std_logic_vector(q-1 downto 0);
		COEF4_i,COEF5_i,COEF6_i,COEF7_i:in std_logic_vector(q-1 downto 0);
        FIROUT_o : out std_logic_vector(reg_size-1 downto 0);
    );
end FIR;
architecture behavior of FIR is
begin

end behavior; 