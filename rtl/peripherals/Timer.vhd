library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.aux_package.all;

entity Timer is
    generic (n: integer := 8);
    port (
        clk, enable, reset, clear : in std_logic;
        q : out std_logic_vector(n-1 downto 0)
    );
end Timer;

architecture rtl of Timer is
    signal q_int : unsigned(n-1 downto 0) := (others => '0');
begin
    process (clk)
    begin
		if clear = '1' then
			q_int <= (others => '0');
        elsif rising_edge(clk) then
            if reset = '1' then
                q_int <= (others => '0');
            elsif enable = '1' then
                q_int <= q_int + 1;
            end if;
        end if;
    end process;

    q <= std_logic_vector(q_int);
end rtl;
