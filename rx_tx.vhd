
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity rx_tx is
   
    port(
    datain : in std_logic := '0';   --data coming from input ADC
    dataout : out std_logic; -- data going to output  DAC
    bclk : in std_logic;  --bit clock I2S
    lrclk: in std_logic;  --left/right clock I2S
    clk : in std_logic;   --fundamental clock (100MHz)
    l_in : in signed(23 downto 0);  --left input sample
    r_in : in signed(23 downto 0);  --right input sample
    l_out : out signed(23 downto 0);  --left output sample
    r_out : out signed(23 downto 0);  --left output sample
    valid : out std_logic    --'1' if data is valid on output
   
    );
end rx_tx;

architecture Behavioral of rx_tx is


signal sample_in : std_logic_vector (63 downto 0) := (others => '0');
signal sample_out : std_logic_vector(63 downto 0) := (others => '0');
signal bclk_edge : unsigned(1 downto 0) :=(others => '0');
signal lrclk_edge : unsigned (1 downto 0) := (others => '0');
signal out_time : std_logic;
begin

--input data processor

process (clk)
begin
    if rising_edge(clk) then
    if bclk_edge = b"10" then  
        sample_in <= sample_in(62 downto 0) & datain;
       
        end if;
            if lrclk_edge = "10" then
                l_out <= signed(sample_in(62 downto 39));
                r_out <= signed(sample_in(30 downto 7));
                valid <= '1';
        else
                valid <= '0';
       
    end if;
    end if;  
   
 end process;      



--output data processor

process (clk)
begin
    if rising_edge(clk) then
    if (out_time = '1' and bclk_edge = "00") then
   
        sample_out <=std_logic_vector(l_in) & x"00" & std_logic_vector(r_in) &x"00";
        dataout <= '0';
        end if;
       
    if bclk_edge = "10" then
   
        dataout <= sample_out(63);  
        sample_out <= sample_out(62 downto 0) & '0';
        end if;
     end if;
     
   end process;
   
 -- bclk and lrclk edge detector
   
   process(clk)
   begin
        if rising_edge(clk) then
             bclk_edge <= bclk_edge(0) & bclk;
             lrclk_edge <= lrclk_edge(0) & lrclk;
        end if;
   end process;
   
   -- frame sync
   
   process(clk)
   begin
        if (rising_edge(clk)) then
           
            if lrclk_edge = "10" then
                out_time <= '1';
            elsif bclk_edge = "01" then
                out_time <= '0';
             end if;
          end if;
             end process;


           
   end Behavioral;
