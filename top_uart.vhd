
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity top_uart is
    port (
        Clk : in std_logic;
        output : out std_logic;
        filter : in std_logic_vector(3 downto 0)
    );
end top_uart;

architecture Behavioral of top_uart is
  
  component tx_uart 
    port(
        tx: out std_logic;
        valid: in std_logic;
        clk: in std_logic;
        char : in std_logic_vector(7 downto 0);
        tx_busy : out std_logic
        );
    end component;
    
    
    signal data_valid : std_logic;
    signal data_input : std_logic_vector(7 downto 0) ;
    signal echo : unsigned (63 downto 0) := X"0D0A6F6863450000";
    signal distorsion : unsigned(111 downto 0) := X"0D0A6E6F6973726F747369440000";
    signal lowpass : unsigned(87 downto 0) := X"0D0A73736170776F4C0000";
    signal temp : std_logic_vector(139 downto 0);
    signal none :unsigned(63 downto 0) := X"0D0A656E6F4E0000";
    signal tx_busy : std_logic := '0';
    
    signal temp_filter : std_logic_vector(3 downto 0);
    
begin

    
 b : tx_uart
  port map(
    Clk => clk,
    tx => output,
    valid =>data_valid,
    char => data_input,
    tx_busy => tx_busy
   
    );
    
-- when filter changes, the ASCII vector of the new filter enters a shift register 
--when one character is sent (tx_busy = 0) the shift register moves to next character 
--the first two characters were not transmitted (couldnt find why), so I added x"0000" before the words
    process(clk)
    begin
    if rising_edge(clk) then
     if filter /= temp_filter then
    temp_filter <= filter;
    if filter = "1001" then
           temp <= std_logic_vector(resize(distorsion,140));
     
     elsif filter = "1010" then
            temp <= std_logic_vector(resize(lowpass,140));
          
     elsif filter = "1100" then 
            temp <= std_logic_vector(resize(echo,140));
    elsif filter(3) = '1' then
            temp <= std_logic_vector(resize(none,140));         
    end if;
    end if;
    if tx_busy = '0' then 
            if temp(63 downto 0) /= x"0000000000000000" then
                data_input <= temp(7 downto 0);
                temp <=X"00"&temp(139 downto 8);
                data_valid <= '1';
      else
            data_valid <= '0';       
                    
            end if;
            
        end if;
   
    end if;    
   
end process;
end Behavioral;
