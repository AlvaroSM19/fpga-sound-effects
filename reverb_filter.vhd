library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity reverb_filter is
    port(
    clk : in std_logic;
    lrclk : in std_logic;
    l_in : in signed(23 downto 0);
    r_in : in signed(23 downto 0);
    level : in integer;
    l_out : out signed(23 downto 0);
    r_out : out signed(23 downto 0);
    fifo_reset : in std_logic
    );
end reverb_filter;

    architecture Behavioral of reverb_filter is
   
    type signed_array is array(natural range<>) of signed(23 downto 0) ;
    signal fifo : signed_array(6000  downto 0) := (others => x"000000");  
    signal data_out : signed(23 downto 0);
    signal data : signed (24 downto 0);
    signal lrclk_edge : std_logic_vector(1 downto 0);
   
    begin
    
    --edge detector
    process(clk)
   begin
            if rising_edge(clk) then
            lrclk_edge <= lrclk_edge(0) & lrclk;
           
        end if;
   end process;
   
  -- same 6000 samples shift register for left and right channel 
  -- I chose that option to increase the size of the shift register
  -- IIR Filter Echo , output of the system enters the shift register again 
   process(clk)
   begin
        if level = 0 then
            data <= resize(l_in,25);
        elsif level = 1 then    
            data <= resize(l_in,25) + resize(fifo(1500),25);
        elsif level = 2 then
           data <= resize(l_in,25) + resize(fifo(3000),25);
        elsif level = 3 then
            data <= resize(l_in,25) + resize(fifo(4500),25);
        elsif level = 4 then
            data <= resize(l_in,25) + resize(fifo(6000),25);
        end if;
        if rising_edge(clk) then
        if lrclk_edge = "01" then
            fifo <= fifo(5999 downto 0)&resize(data(23 downto 1),24);
        end if;
       
           
            l_out <= data(23 downto 0);
            r_out <= data(23 downto 0);
            end if;
            end process;
           
end Behavioral;