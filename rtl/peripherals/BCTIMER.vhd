LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;

entity BCTIMER is
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
end BCTIMER;
architecture behavior of BCTIMER is
signal BTCNTeq0_w,clk_w: std_logic;
signal BTCL0_w,BTCL1_w,Q_w: std_logic_vector(reg_size-1 downto 0);
signal HEU0_w,Q24_w,Q28_w,Q32_w: std_logic;
begin

    process(BTCNTeq0_w)
    begin
    if BTCNTeq0_w='1' then 	
	    BTCL0_w<=BTCCR0_i;
	end if;
    end process;
	
	process(BTCNTeq0_w)
    begin
    if BTCNTeq0_w='1' then 	
	    BTCL1_w<=BTCCR1_i;
	end if;
    end process;
	
	clk_w<= MCLK_i when BTSSEL_i="00" else
            MCLK_2_i when BTSSEL_i="01" else    	
			MCLK_4_i when BTSSEL_i="10" else 
			MCLK_8_i; 
			
	BTIFG_o<= HEU0_w when BTIP_i="00" else
            Q24_w when BTIP_i="01" else    	
			Q28_w when BTIP_i="10" else 
			Q32_w; 	
			
	BTCNT: Timer generic map ( n=>reg_size) port map(clk=>clk_w,
													enable=>not BTHOLD_i,
													reset=>BTCLR_i,
													clear=>HEU0_w,
                                                    q=>Q_w);
													
	PWM_gen :PWM generic map ( n=>reg_size) port map(clk_i=>clk_w,
													enable_i=>BTOUTEN_i,
													PWM_Mode_i=>BTOUTMD_i,
													x_i=>BTCL1_w,
													q_i=>Q_w,
													y_i=>BTCL0_w,
                                                    PWM_O=>PWM_o,
													HEU_o=>HEU0_w); 												
    
	Q24_w<=Q_w(23);
	Q28_w<=Q_w(27);
	Q32_w<=Q_w(31);
	
	
	
	

end behavior;			