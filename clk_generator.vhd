library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity clk_generator is
   port(
   
    clk : in std_logic;     --(100 MHz)
    mclk_o : out std_logic;  --(22.579 MHz)
    bclk : out std_logic;   --MCLK/8
    lrclk : out std_logic  --BCLK/64
    
    );
    
end clk_generator;


architecture Behavioral of clk_generator is
    
component clk_wiz_0
  port ( 
    mclk : out std_logic;
    clk_in1 : in std_logic;
    reset : in std_logic := '0'
   
  );
    end component;
   signal mclk_i : std_logic;
   signal bclk_couter: unsigned(2 downto 0) :=(others => '0');
   signal lrclk_couter : unsigned(8 downto 0) := (others => '0');
   signal bclk_edge : unsigned(1 downto 0) :=(others => '0');
    signal lrclk_edge : unsigned (1 downto 0) := (others => '0');
    
begin

    mclk_o <= mclk_i;
    bclk <= bclk_couter(2);
    lrclk <= lrclk_couter(8);
    
clk_gen : clk_wiz_0
port map(
    clk_in1 => clk,
    mclk => mclk_i   
    );
    
--generation of bclk (mclk/8) and lrclk (mclk/512)
    process(mclk_i)
    begin
    if rising_edge(mclk_i) then
        bclk_couter <= bclk_couter + to_unsigned(1,3);
        lrclk_couter <= lrclk_couter + to_unsigned(1,9);
    end if;
    end process;

-- rising edge of bclk and lrclk

 process(clk)
   begin
        if rising_edge(clk) then
             bclk_edge <= bclk_edge(0) & bclk_couter(2);
             lrclk_edge <= lrclk_edge(0) & lrclk_couter(8);
        end if;
   end process;
  

end Behavioral;
