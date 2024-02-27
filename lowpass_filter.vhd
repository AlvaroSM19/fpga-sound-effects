library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity lowpass_filter is
    port(
    clk : in std_logic; 
    lrclk : in std_logic; 
    l_in : in signed(23 downto 0);
    r_in : in signed (23 downto 0);
    l_out : out signed(23 downto 0);
    r_out : out signed (23 downto 0); 
    level : in integer
    );
end lowpass_filter;

architecture Behavioral of lowpass_filter is

type signed_array is array(natural range<>) of signed(23 downto 0) ;
signal fifo_left : signed_array (31 downto 0);
signal fifo_right : signed_array (31 downto 0);
signal lrclk_edge : std_logic_vector(1 downto 0);
signal left_temp : signed(28 downto 0);
signal right_temp : signed(28 downto 0);

begin

process(clk)
begin

-- shift register of 30 samples for each channel
if rising_edge(clk) then
    if lrclk_edge = "01" then
        fifo_left <= fifo_left(30 downto 0) & l_in;
        fifo_right <= fifo_right(30 downto 0) & r_in;
     end if;
end if;
end process;

-- edge detector

process(clk)
   begin
        if rising_edge(clk) then
            lrclk_edge <= lrclk_edge(0) & lrclk;
             
        end if;  
   end process;
   
 -- lowpass filter 
 -- sum of the last 2^(level +1 ) samples
 -- there is probably a better way to sum all the samples, I tried with for loop but it wasnt working properly.   
   process(clk)
   begin
   if rising_edge(clk) then
   if lrclk_edge = "10" then
        if level = 0 then
            l_out <= l_in;
            r_out <= r_in;
         end if;
         if level = 1 then
            left_temp <= resize(fifo_left(0),29) + resize(fifo_left(1),29)+resize(fifo_left(2),29) + resize(fifo_left(3),29);
            right_temp <=resize(fifo_right(0),29) + resize(fifo_right(1),29)+resize(fifo_right(2),29) + resize(fifo_right(3),29);
            l_out <=left_temp(25 downto 2);
            r_out <= right_temp(25 downto 2);
            end if;
            if level = 2 then
            left_temp <= resize(fifo_left(0),29) + resize(fifo_left(1),29)+resize(fifo_left(2),29) + resize(fifo_left(3),29)+
                        resize(fifo_left(4),29) + resize(fifo_left(5),29)+resize(fifo_left(6),29) + resize(fifo_left(7),29);
            right_temp <=resize(fifo_right(0),29) + resize(fifo_right(1),29)+resize(fifo_right(2),29) + resize(fifo_right(3),29)+
                        resize(fifo_right(4),29) + resize(fifo_right(5),29)+resize(fifo_right(6),29) + resize(fifo_right(7),29);
            l_out <=left_temp(26 downto 3);
            r_out <= right_temp(26 downto 3);
            end if;
            if level = 3 then
            left_temp <= resize(fifo_left(0),29) + resize(fifo_left(1),29)+resize(fifo_left(2),29) + resize(fifo_left(3),29)+
                        resize(fifo_left(4),29) + resize(fifo_left(5),29)+resize(fifo_left(6),29) + resize(fifo_left(7),29)+
                        resize(fifo_left(8),29) + resize(fifo_left(9),29)+resize(fifo_left(10),29) + resize(fifo_left(11),29)+
                        resize(fifo_left(12),29) + resize(fifo_left(13),29)+resize(fifo_left(14),29) + resize(fifo_left(15),29);
            right_temp <=resize(fifo_right(0),29) + resize(fifo_right(1),29)+resize(fifo_right(2),29) + resize(fifo_right(3),29)+
                        resize(fifo_right(4),29) + resize(fifo_right(5),29)+resize(fifo_right(6),29) + resize(fifo_right(7),29)+
                        resize(fifo_right(8),29) + resize(fifo_right(9),29)+resize(fifo_right(10),29) + resize(fifo_right(11),29)+
                        resize(fifo_right(12),29) + resize(fifo_right(13),29)+resize(fifo_right(14),29) + resize(fifo_right(15),29);
            l_out <=left_temp(27 downto 4);
            r_out <= right_temp(27 downto 4);
      
            end if;
            if level = 4 then
            left_temp <=resize(fifo_left(0),29) + resize(fifo_left(1),29)+resize(fifo_left(2),29) + resize(fifo_left(3),29)+
                        resize(fifo_left(4),29) + resize(fifo_left(5),29)+resize(fifo_left(6),29) + resize(fifo_left(7),29)+
                        resize(fifo_left(8),29) + resize(fifo_left(9),29)+resize(fifo_left(10),29) + resize(fifo_left(11),29)+
                        resize(fifo_left(12),29) + resize(fifo_left(13),29)+resize(fifo_left(14),29) + resize(fifo_left(15),29)+
                        resize(fifo_left(16),29) + resize(fifo_left(17),29)+resize(fifo_left(18),29) + resize(fifo_left(19),29)+
                        resize(fifo_left(20),29) + resize(fifo_left(21),29)+resize(fifo_left(22),29) + resize(fifo_left(23),29)+
                        resize(fifo_left(24),29) + resize(fifo_left(25),29)+resize(fifo_left(26),29) + resize(fifo_left(27),29)+
                        resize(fifo_left(28),29) + resize(fifo_left(29),29)+resize(fifo_left(30),29) + resize(fifo_left(31),29);           
            right_temp <=resize(fifo_right(0),29) + resize(fifo_right(1),29)+resize(fifo_right(2),29) + resize(fifo_right(3),29)+
                        resize(fifo_right(4),29) + resize(fifo_right(5),29)+resize(fifo_right(6),29) + resize(fifo_right(7),29)+
                        resize(fifo_right(8),29) + resize(fifo_right(9),29)+resize(fifo_right(10),29) + resize(fifo_right(11),29)+
                        resize(fifo_right(12),29) + resize(fifo_right(13),29)+resize(fifo_right(14),29) + resize(fifo_right(15),29)+
                        resize(fifo_right(16),29) + resize(fifo_right(17),29)+resize(fifo_right(18),29) + resize(fifo_right(19),29)+
                        resize(fifo_right(20),29) + resize(fifo_right(21),29)+resize(fifo_right(22),29) + resize(fifo_right(23),29)+
                        resize(fifo_right(24),29) + resize(fifo_right(25),29)+resize(fifo_right(26),29) + resize(fifo_right(27),29)+
                        resize(fifo_right(28),29) + resize(fifo_right(29),29)+resize(fifo_right(30),29) + resize(fifo_right(31),29);
            l_out <=left_temp(28 downto 5);
            r_out <= right_temp(28 downto 5);
            end if;
        end if;  
        end if;
   end process;
   
end Behavioral;
