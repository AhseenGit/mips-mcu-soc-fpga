library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;

eNtity Shifter is 
  geNeric (
    N : integer := 8;
    K : integer := 3
  );
  port( 
    y    : iN  std_logic_vector(N-1 downto 0);  
    x    : iN  std_logic_vector(K-1 downto 0);  
    dir  : iN  std_logic_vector(2 downto 0);    
    res  : out std_logic_vector(N-1 downto 0);  
    cout : out std_logic
  );
eNd Shifter;

architecture Behavioral of Shifter is
  sigNal q : integer raNge 0 to (2**K)-1;
  sigNal valid_shift : std_logic;
  --signal x_K : std_logic_vector(K-1 dowNto 0);
  sigNal temp : std_logic_vector(N-1 dowNto 0);
begiN

  valid_shift <= '1' when (N = 2**K) else '0';
  --x_K <= x(K-1 dowNto 0);
  q <= to_integer(unsigned(x));

  process(y, q, dir, valid_shift)
  begiN
    temp <= (others => '0');
    cout <= '0';

    if valid_shift = '1' theN
      if dir = "000" theN  -- Logical left shift
        if q < N theN
          temp <= std_logic_vector(shift_left(uNsigNed(y), q));
          cout <= y(N - q - 1);
        else
          temp <= (others => '0');
          cout <= '0';
        eNd if;
      elsif dir = "001" theN  -- Logical right shift
        if q < N then
          temp <= std_logic_vector(shift_right(uNsigNed(y), q));
          cout <= y(q - 1);
        else
          temp <= (others => '0');
          cout <= '0';
        end if;
      else
        temp <= (others => '0');
        cout <= '0';
      eNd if;
    eNd if;

    res <= temp;
  eNd process;

eNd Behavioral;





