LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;

ENTITY gpio IS
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
END gpio;

architecture rtl of gpio is

  -- ============================================================================
  --  GPIO Address Map Constants
  -- ============================================================================
  -- These constants define memory-mapped I/O register addresses (byte-based).
  -- Must match software-side memory map definitions.
  -- ============================================================================

  constant ADDR_LEDR : std_logic_vector(11 downto 0) := x"800";
  constant ADDR_HEX0 : std_logic_vector(11 downto 0) := x"804";
  constant ADDR_HEX1 : std_logic_vector(11 downto 0) := x"805";
  constant ADDR_HEX2 : std_logic_vector(11 downto 0) := x"808";
  constant ADDR_HEX3 : std_logic_vector(11 downto 0) := x"809";
  constant ADDR_HEX4 : std_logic_vector(11 downto 0) := x"80C";
  constant ADDR_HEX5 : std_logic_vector(11 downto 0) := x"80D";
  constant ADDR_SW   : std_logic_vector(11 downto 0) := x"810";

signal CS : std_logic_vector( 6 downto 0);
signal optimzed_addr : std_logic_vector(3 downto 0);
signal en1: std_logic;
signal Q0: std_logic_vector( 7 downto 0); 
signal Q1: std_logic_vector( 7 downto 0); 
signal Q2: std_logic_vector( 7 downto 0);
signal Q3: std_logic_vector( 7 downto 0);
signal Q4: std_logic_vector( 7 downto 0);
signal Q5: std_logic_vector( 7 downto 0);
signal Q6: std_logic_vector( 7 downto 0);

signal en_hex0: std_logic;
signal en_hex1: std_logic;
signal en_hex2: std_logic;
signal en_hex3: std_logic;
signal en_hex4: std_logic;
signal en_hex5: std_logic;
begin

optimzed_addr <= addr(11)&addr(4 downto 2);

    -- decoder
     with optimzed_addr select
        CS  <=  "0000001" when "1000",
                "0100000" when "1001",
			    "0010000" when "1010",
				"0001000" when "1011",				
                "1000000" when "1100",
                "0000000"  when others;

	-- LEDs
	en1<= (CS(0) and  mem_write);
    process(en1)
    begin 
	if en1='1' then 
	    Q0<=write_data;
	end if;
    end process;
    leds<=Q0;
	
	-- Hex0
	en_hex0<= (CS(5) and (not addr(0)) and mem_write);
    process(en_hex0)
    begin 
	if en_hex0='1' then 
	    Q1<=write_data;
	end if;
    end process;
    hex0<=Q1;
	
    -- Hex1
	en_hex1<= (CS(5) and (addr(0)) and mem_write);
    process(en_hex1)
    begin 
	if en_hex1='1' then 
	    Q2<=write_data;
	end if;
    end process;
    hex1<=Q2;
	
	-- Hex2
	en_hex2<= (CS(4) and (not addr(0)) and mem_write);
    process(en_hex2)
    begin 
	if en_hex2='1' then 
	    Q3<=write_data;
	end if;
    end process;
    hex2<=Q3;
	
	-- Hex3
	en_hex3<= (CS(4) and ( addr(0)) and mem_write);
    process(en_hex3)
    begin 
	if en_hex3='1' then 
	    Q4<=write_data;
	end if;
    end process;
    hex3<=Q4;
	
	-- Hex4
	en_hex4<= (CS(3) and (not addr(0)) and mem_write);
    process(en_hex4)
    begin 
	if en_hex4='1' then 
	    Q5<=write_data;
	end if;
    end process;
    hex4<=Q5;
	
	-- Hex5
	en_hex5<= (CS(3) and ( addr(0)) and mem_write);
    process(en_hex5)
    begin 
	if en_hex5='1' then 
	    Q6<=write_data;
	end if;
    end process;
    hex5<=Q6;
	
	--SW reading
	read_data <=  switches when (CS(6) = '1' and mem_read = '1') else
                  Q0       when (CS(0) = '1' and mem_read = '1') else
				  Q1       when (CS(5) and (not addr(0)) and mem_read) else
                  Q2       when (CS(5) and (addr(0)) and mem_read) else
				  Q3       when (CS(4) and (not addr(0)) and mem_read) else
				  Q4       when (CS(4) and (addr(0)) and mem_read) else
				  Q5       when (CS(3) and (not addr(0)) and mem_read) else
				  Q6       when (CS(3) and (addr(0)) and mem_read) else
				  (others => 'Z');

end architecture;
