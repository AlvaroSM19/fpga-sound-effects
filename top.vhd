library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity top is
port(
    clk : in std_logic;                                     -- Base 100MHz clk
    dout : out std_logic;                                   --Bit output stream sent to DAC 
    din : in std_logic;                                     -- Bit input stream coming from ADC
    da_mclk : out std_logic;                                --Master Clock DAC
    da_bclk : out std_logic;                                --Bit Clock DAC
    da_lrclk : out std_logic;                               --Left/Right Clock DAC  
    ad_mclk : out std_logic;                                --Master Clock ADC
    ad_bclk : out std_logic;                                --Bit Clock ADC 
    ad_lrclk : out std_logic;                               --Left/Right Clock ADC
    level_up : in std_logic;                                --Input level up button
    level_down : in std_logic;                              --Input level down button
    level_output : out std_logic_vector(3 downto 0);        --Output level LEDS    
    filter_select : in std_logic_vector(3 downto 0);        --Filter Select Input Switches
    uart_output : out std_logic                             --Output UART bit stream
);
end top;

architecture Behavioral of top is
    component rx_tx 
        port(
    datain : in std_logic;   --data coming from input ADC
    dataout : out std_logic; -- data going to output  DAC
    bclk : in std_logic;  --bit clock I2S
    lrclk: in std_logic;  --left/right clock I2S
    clk : in std_logic;   --fundamental clock (100MHz)
    l_in : in signed(23 downto 0);  --left input sample
    r_in : in signed(23 downto 0);  --right input sample
    l_out : out signed(23 downto 0);  --left output sample
    r_out : out signed(23 downto 0) --left output sample
        );
    end component; 
    
    component clk_generator
          port(
      clk : in std_logic;     --(100 MHz)
      mclk_o : out std_logic;  --(22.579 MHz)
      bclk : out std_logic;   --MCLK/8
      lrclk : out std_logic  --SCLK/64
           );
     end component;
    
    component distorsion_filter
            port(
        l_in : in signed(23 downto 0);
        r_in : in signed(23 downto 0);
        l_out : out signed(23 downto 0);
        r_out : out signed(23 downto 0);
        level : in integer;
        clk : in std_logic;
        lrclk : in std_logic;
        reset : in std_logic
            );
        end component;
        
    component lowpass_filter
        port(
    clk : in std_logic; 
    lrclk : in std_logic; 
    l_in : in signed(23 downto 0);
    r_in : in signed (23 downto 0);
    l_out : out signed(23 downto 0);
    r_out : out signed (23 downto 0);
    level : in integer
        );
    end component;
    
    component reverb_filter
        port(
    clk : in std_logic; 
    lrclk : in std_logic;
    l_in : in signed(23 downto 0);
    r_in : in signed(23 downto 0);
    level : in integer;
    fifo_reset : in std_logic;
    l_out : out signed(23 downto 0);
    r_out : out signed(23 downto 0)
        );    
    end component;
    
    component top_uart
        port(
    clk : in std_logic;
    output : out std_logic;
    filter : in std_logic_vector
        );
    end component;
    
    --Left and Right Input Signals coming from RX
    signal l_data_in : signed(23 downto 0);
    signal r_data_in: signed(23 downto 0);
    signal l_data_out : signed(23 downto 0);
    signal r_data_out: signed(23 downto 0);
    
    --Left and Right output signals for each filte
    signal l_dataout_1 : signed(23 downto 0);
    signal l_dataout_2 : signed(23 downto 0);
    signal l_dataout_3 : signed(23 downto 0);
    signal r_dataout_1 : signed(23 downto 0);
    signal r_dataout_2 : signed(23 downto 0);
    signal r_dataout_3 : signed(23 downto 0);
    
    --Copy of filter_select input
    signal filter_selection : std_logic_vector(3 downto 0);
    
    signal mclk : std_logic; 
    signal bclk : std_logic;
    signal lrclk : std_logic;
   
   type state_level is (L0,L1,L2,L3,L4);
   signal state : state_level :=L1;
   signal level : integer := 1;
   signal up_edge: std_logic_vector(1 downto 0);
   signal down_edge : std_logic_vector(1 downto 0);
    
   signal reset_filter : std_logic;
   
begin

a: rx_tx  
    port map(
    clk =>clk,
    lrclk =>lrclk,
    bclk => bclk,
    datain => din,
    dataout => dout,
    l_in =>l_data_out,
    l_out =>l_data_in,
    r_in =>r_data_out,
    r_out =>r_data_in 
    );  
b : clk_generator
    port map(
        clk => clk,
        mclk_o => mclk,
        bclk => bclk,
        lrclk => lrclk
        );
        
c : distorsion_filter
    port map(
    l_in =>l_data_in,
    r_in => r_data_in,
    l_out => l_dataout_1,
    r_out => r_dataout_1,
    level => level,
    clk =>clk,
    lrclk =>lrclk,
    reset =>reset_filter
     );   
     
d : lowpass_filter
     port map(
        clk => clk,
        lrclk =>lrclk,
        l_in => l_data_in,
        r_in => r_data_in,
        l_out =>l_dataout_2,
        r_out =>r_dataout_2,
        level => level
     );
     
 e : reverb_filter
    port map(
        clk => clk,
        lrclk => lrclk,
        l_in =>l_data_in,
        r_in =>r_data_in,
        l_out =>l_dataout_3,
        r_out =>r_dataout_3,
        fifo_reset => reset_filter,
        level => level
        
        );
    
    f : top_uart
        port map(
        clk => clk,
        output => uart_output,
        filter => filter_selection
        );            
    da_mclk <= mclk;
    ad_mclk <= mclk;
    
    
    da_bclk <= bclk;
    ad_bclk <= bclk;  
    
    da_lrclk <= lrclk;
    ad_lrclk <= lrclk;    
    
    filter_selection <= filter_select;
 
 --Level Increase and Dicrease edge detector    
    process(clk)
   begin
        if rising_edge(clk) then
             up_edge <= up_edge(0) & level_up;
             down_edge <= down_edge(0) & level_down; 
        end if;
   end process;
   
   
   -- Level State Machine
    process(clk)
    begin
    
    if rising_edge(clk) then
        case state is 
        
            when L0 =>
                reset_filter <= '0';
                level_output <= "0000";
                level <=0;
                if up_edge = "01" then
                    
                    state <= L1;
                    reset_filter <= '1';
                 end if;
                 
             when L1 =>
             reset_filter <= '0';
                level <=1;
                level_output <= "0001";
                if up_edge = "01" then
                    state <= L2;
                    reset_filter <= '1';
                 end if;
                 if down_edge = "01" then
                    state <= L0;
                    reset_filter <= '1';
                 end if;
                 
                 when L2 =>
                 level <=2;
                 reset_filter <= '0';
                  level_output <= "0011";
                if up_edge = "01" then
                    reset_filter <= '1';
                    state <= L3;
                 end if;
                 if down_edge = "01" then
                    state <= L1;
                    reset_filter <= '1';
                 end if;
                 
                 when L3 =>
                 reset_filter <= '0';
                 level <=3;
              level_output <= "0111";
                if up_edge = "01" then
                    state <= L4;
                    reset_filter <= '1';
                 end if;
                 
                 if down_edge = "01" then
                    state <= L2;
                    reset_filter <= '1';
                 end if;
                 
                 when L4 =>
                 reset_filter <= '0';
                 level <=4;
                  level_output <= "1111";
                 if down_edge = "01" then
                    reset_filter <= '1';
                    state <= L3;
                 end if;
                 
                 end case;
                 end if;
                 end process;
      -- Output selection depending on the switchs  (kind on multiplexor)           
                 process(clk)
                 begin
                 if rising_edge(clk) then
                    if (filter_select = "0001" or filter_select = "1001") then
                        l_data_out <= l_dataout_1;
                        r_data_out <= r_dataout_1;
                    elsif (filter_select = "0010" or filter_select = "1010")  then
                        l_data_out <= l_dataout_2;
                        r_data_out <= r_dataout_2;
                    elsif (filter_select = "0100" or filter_select = "1100") then
                        l_data_out <= l_dataout_3;
                        r_data_out <= r_dataout_3;
                   else    
                        l_data_out <= l_data_in;
                        r_data_out <= l_data_in;
                        
                  
                    end if;
                    
                    
                    end if;
                    end process;
                    
                    
                    
    end behavioral;
    
    
    
