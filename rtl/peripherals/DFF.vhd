LIBRARY ieee;
USE ieee.std_logic_1164.all;

--------------------------------------------------------
ENTITY DFF IS
    GENERIC (n : INTEGER := 32);  -- Default to 24 bits
    PORT (
        clk_i : IN std_logic;
        rst_i : IN std_logic;
		en_i  : IN std_logic;
        x_i   : IN std_logic_vector(n-1 downto 0);
        y_o   : OUT std_logic_vector(n-1 downto 0)
    );
END DFF;

ARCHITECTURE behave OF DFF IS
BEGIN

    process(clk_i, rst_i)
    begin 
        if rst_i = '1' then
            y_o <= (others => '0'); 
        elsif rising_edge(clk_i) then
            y_o <= x_i;
        end if;
    end process;

END behave;
