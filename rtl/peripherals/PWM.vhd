library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
USE work.aux_package.all;

entity PWM is
    generic (n : integer := 8);
    port (
        clk, enable, reset : in std_logic;
        PWM_Mode : in std_logic_vector(1 downto 0);
        x, y : in std_logic_vector(n-1 downto 0);
        PWM_Out : out std_logic
    );
end PWM;
architecture rtl of PWM is
    signal q : std_logic_vector(n-1 downto 0);
    signal Toggle : std_logic := '0';
    signal clear : std_logic := '0';
begin

    counter: entity work.Timer
        generic map(n)
        port map(clk, enable, reset, clear, q);

    process (clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                clear <= '0';  -- Default

                case PWM_Mode is
                    when "00" =>
					    if X>Y then
						   PWM_Out<='0';
                        elsif (unsigned(q) > unsigned(x)-1) and (unsigned(q) < unsigned(y)-1) then
                            PWM_Out <= '1';
                        elsif (unsigned(q) >= unsigned(y)-1) then
                            PWM_Out <= '0';
                            clear <= '1';
                        else
                            PWM_Out <= '0';
                        end if;

                    when "01" =>
					    if X>Y then
						   PWM_Out<='0';
                        elsif (unsigned(q) > unsigned(x)-1) and (unsigned(q) < unsigned(y)-1) then
                            PWM_Out <= '0';
                        elsif (unsigned(q) >= unsigned(y)-1) then
                            PWM_Out <= '1';
                            clear <= '1';
                        else
                            PWM_Out <= '1';
                        end if;

                    when "10" =>
					    if X>Y then
						   PWM_Out<='0';
                        elsif unsigned(q) = unsigned(x)-1 then
                            Toggle <= not Toggle;
                        end if;
                        if (unsigned(q) >unsigned(y)-1) then
                            clear <= '1';
                        end if;
                        PWM_Out <= Toggle;

                    when others =>
                        PWM_Out <= '0';
                end case;
            end if;
        end if;
    end process;

end rtl;
