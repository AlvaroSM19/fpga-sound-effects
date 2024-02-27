
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity tx_uart is
    port(
        tx: out std_logic;
        valid: in std_logic;
        clk: in std_logic;
        char : in std_logic_vector(7 downto 0);
        tx_busy : out std_logic
        );
end tx_uart;

architecture Behavioral of tx_uart is

    type state_t is (idle,data_valid,start,S0,S1,S2,S3,S4,S5,S6,S7,stop);

    signal baud: std_logic:='0';
    signal baud_couter: integer := 0;
    signal state: state_t;
    signal char2: std_logic_vector(7 downto 0):="01100001";
    signal busy : std_logic := '0';
    
begin 

-- UART STATE MACHINE
    process(clk)
    begin
        if rising_edge(clk) then
            tx_busy <= busy;
            baud_couter <= baud_couter + 1;
            
             
            if baud_couter = 868 then
                
                
                
                baud_couter <= 0;
                baud <= '1';
             else
             baud <= '0';
            
      
            end if;
         case state is 
               
                when idle =>
                            tx <= '1';
                            if valid = '1'  and busy = '0' then
                            state <= data_valid;
                            busy <= '1';
                            end if;
                           
                            
                   
                when data_valid =>
                            
                            if baud = '1' then
                            state <= start;
                            
                        end if;
                          
                when start =>
                        
                        
                            if baud = '1' then
                            state <= S0;
                            end if;
                        tx <= '0';
                 when S0 =>
                         
                            if baud = '1' then
                            state <= S1;
                        end if;
                        tx <= char(0);
                        
                        
                 when S1 =>
                         
                         
                           if baud = '1' then
                            state <= S2;
                        end if;
                        tx <= char(1);
                        
                when S2 =>
                         
                         if baud = '1' then
                            state <= S3;
                        end if;
                        tx <= char(2);
                        
                when S3 =>
                         
                        if baud = '1' then
                            state <= S4;
                        end if;
                        tx <= char(3);
                when S4 =>
                         
                        if baud = '1' then
                            state <= S5;
                        end if;
                        tx <= char(4);
                when S5 =>
                         
                         if baud = '1' then
                            state <= S6;
                        end if;
                        tx <= char(5);
                when S6 =>
                         
                         if baud = '1' then
                            state <= S7;
                        end if;
                        tx <= char(6);
                when S7 =>
                         
                         
                          if baud = '1' then
                            state <= stop;
                        end if;
                        tx <= char(7) ;
               when stop =>
                        
                        if baud = '1' then
                            busy <= '0';
                            state <= idle;
                            
                        end if;
                        tx <= '1';
               when others => state<=idle;
                              busy <= '0';
                            
               
                
          end case;
         
    
    end if;
    
    end process;
        
     

end Behavioral;

