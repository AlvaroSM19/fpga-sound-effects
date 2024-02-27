library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity distorsion_filter is
    port(
    l_in : in signed(23 downto 0);
    r_in : in signed(23 downto 0);
    l_out : out signed(23 downto 0);
    r_out  :out signed(23 downto 0);
    level : in integer;    
    clk : in std_logic;
    lrclk : in std_logic;
    reset : in std_logic
    );
end distorsion_filter;

architecture Behavioral of distorsion_filter is

signal lrclk_edge : std_logic_vector(1 downto 0);
signal left_temp : signed(23 downto 0);
signal right_temp : signed(23 downto 0);
signal cont : integer := 0;

begin

l_out <= left_temp;
r_out <= right_temp;

--edge detection

process(clk)
   begin
        if rising_edge(clk) then
            lrclk_edge <= lrclk_edge(0) & lrclk;        
        end if;
   end process;
   
  
  --Distorsion filter 
  -- The output will be updated if cont = 5*level  (Decimation)
   process(clk)
   begin
    if rising_edge(clk) then
        
        if reset = '1' then
            cont <= 0;
        end if;
        if lrclk_edge = "10" then
            cont <= cont +1;
            end if;
         if cont = (5*level) then
            cont <= 0;
            left_temp <= l_in;
            right_temp <= r_in;
        end if;
        end if;
        end process;
end Behavioral;
