library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
Use ieee.numeric_std.all;

entity digitaloscilloscope IS 
    generic (
        ADC_DATA_WIDTH : integer := 12
    );
	port(
	     CLK : in std_logic;
		  RST : in std_logic ;
		  RST2 : in std_logic ;
		  HSYNC : out std_logic ;
		  VSYNC  : OUT STD_LOGIC ;
-----------------------------------------------------------------------------------------		  
		  blank : out STD_LOGic := '0' ;
		  sync : out STD_LOGIC  := '0' ;
		  clk_out_clk: out STD_LOGIC  ;
-------------------------------------------------------------------------------------------

        adc_sclk : out std_logic;
        adc_din : out std_logic;
        adc_dout : in std_logic;
        adc_convst : out std_logic;
-----------------------------------------------------------------------------------------		  
		  R: inOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		  G: inOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		  B: inOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
--------------------------------------------------------------------------------------------
        adc_sample_accumulator_LED: out integer RANGE 0 to 256 
		  );
	
		  
end digitaloscilloscope;


architecture behaviour of digitaloscilloscope is 
----------------------------------------------------------------------
component adcpll is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic         -- outclk0.clk
	);
end component;
------------------------------------------------------------------------------
--component fifo IS
--	PORT
--	(
--		aclr		: IN STD_LOGIC  := '0';
--		data		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
--		rdclk		: IN STD_LOGIC ;
--		rdreq		: IN STD_LOGIC ;
--		wrclk		: IN STD_LOGIC ;
--		wrreq		: IN STD_LOGIC ;
--		q		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
--		rdempty		: OUT STD_LOGIC ;
--		wrfull		: OUT STD_LOGIC 
--	);
--END component;
----------------------------------------------------------------------------
signal videoon : std_logic; 
signal hpos ,vpos :integer;
signal texton , graphon , paron , par2on,waveon : STD_LOGIC;
signal  adcclk: std_logic;
signal m1,m2,m3,m4,m5:  integer ;
-----------------------------------------------------------------------------------

	signal adc_clk : std_logic;
	signal rdreq : std_logic ;
	signal rdempty  : std_logic ;
	signal wrfull : std_logic ;
------------------------------
	signal adc_sclk1 : std_logic;
--------------------------------------
	signal adc_sample_clk1 : std_logic;
	signal adc_sample_clk2 : std_logic;

    signal fifo_data : std_logic_vector(ADC_DATA_WIDTH - 1 downto 0);
	 signal fifo_data_out : std_logic_vector(ADC_DATA_WIDTH - 1 downto 0);
------------------------------------------------------------------------------------------------------------------
	 signal memory_data_out : std_logic_vector(ADC_DATA_WIDTH - 1 downto 0);
	 signal memory_data_out2 : std_logic_vector(ADC_DATA_WIDTH - 1 downto 0);
------------------------------------------------------------------------------------------------------------------
	 signal  ram_memory_address : integer range 0 to 512 ;
	 signal  ram_memory_address_std:  std_logic_vector(8 downto 0) ;
-------------------------------------------------------------------------------------------------------------------
	 signal  ram_memory_address2 : integer range 0 to 512 ;
	 signal  ram_memory_address_std2 :  std_logic_vector(8 downto 0) ;
-----------------------------------------------------------------------------------------------------------------

begin 
     ram_memory_address_std <= std_logic_vector(to_unsigned(ram_memory_address,9));
	  ram_memory_address_std2 <= std_logic_vector(to_unsigned(ram_memory_address2,9));
	  adc_sclk <= adc_sclk1 ;
-------------------------------------------------------------------------------------
				
	vgaa: entity work.vgamul
	port map(CLK=>CLK,RST=>RST,HSYNC=>HSYNC,VSYNC=>VSYNC,blank=>blank,sync=>sync,
	         clk_out_clk => clk_out_clk,hpos=>hpos,vpos=>vpos ,videoon =>videoon);
			
   graphh: entity work.graph
	port map( CLK=>CLK,RST=>RST,hpos=>hpos,vpos=>vpos ,videoon =>videoon,graphon=>graphon);
	 
	    
	test: entity work.font_test_gen 
	port map(clk=>CLK,hpos=>hpos,vpos=>vpos ,videoon =>videoon,texton=>texton,paron=>paron,par2on=>par2on,
	          m1=>m1,m2=>m2,m3=>m3,m4=>m4,m5=>m5);
	

	RGB: entity work.RGB 
	port map(R=>R,G=>G,B=>B,texton=>texton,graphon=>graphon,paron=>paron,par2on=>par2on,waveon=>waveon);
	
	adc: entity work.adc_sampler
	port map(adc_sclk => adc_sclk1 , clock => adc_clk, adc_din => adc_din , adc_dout=>adc_dout,adc_convst=>adc_convst,
	          adc_sample => adc_sample_clk1,reset =>RST , adc_data => fifo_data);

	adcsample: adcpll
	port map(refclk=> clk , outclk_0 => adc_clk ,rst=>RST);
	
	wave: entity work.wavegraph 
	port map(CLK=>CLK,RST=>RST,adc_data_clk =>  adc_sclk1 ,adc_data=>  memory_data_out , adc_data2=>  fifo_data ,
	adc_sample=>adc_sample_clk1,hpos=>hpos,vpos=>vpos,videoon=>videoon, m1=>m1,m2=>m2,m3=>m3,m4=>m4,m5=>m5,waveon=>waveon,
	rdreq => rdreq,adc_sample_accumulator_LED => adc_sample_accumulator_LED, 
	ram_memory_address =>  ram_memory_address, graphon => graphon);
	
	
	memory: entity work.rammem 
	port map(clk => adc_sclk1 , addr =>ram_memory_address_std ,wr => rdreq      , d =>  fifo_data, q =>  memory_data_out  );
	
--	memory2: entity work.rammem 
--	port map(clk => CLK , addr =>ram_memory_address_std2 ,wr => rdreq      , d =>  fifo_data, q =>  memory_data_out2  );
--	
	 
--	clock_domain_crossing : fifo
--   port map(aclr => RST2, data => fifo_data, rdclk => CLK, rdreq => rdreq  ,wrclk => adc_clk,
--            wrreq => adc_sample_clk2    ,q => fifo_data_out,  rdempty => rdempty   ,wrfull => wrfull);
--				
			
--	process(wrfull)		
--	begin
--    if(wrfull = '0')  then 
--	    adc_sample_clk2 <= adc_sample_clk1 ;
--	 else 
--	     adc_sample_clk2  <= '0';
--	 end if ;
--	end process ;  
				
				


			

end behaviour;  





-- A module that interfaces with the LTC2308 ADC to obtain sampled data.

library ieee;
library lpm;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use lpm.lpm_components.all;

entity wavegraph is

port(
	  CLK : in std_logic ;
	  adc_data_clk : in std_logic ;
	  graphon : in std_logic ;
     RST : in std_logic ;
	  
     adc_data: in std_logic_vector(11 downto 0) ;
	  adc_data2: in std_logic_vector(11 downto 0) ;
	  
	  adc_sample : in std_logic ;
	  hpos : in integer := 0;
	  vpos : in integer := 0;
     videoon  : in std_logic := '0' ;
	  waveon  : out std_logic := '0' ;
	  m1,m2,m3,m4,m5 : out integer ;
	  rdreq : out std_logic ;
	  adc_sample_accumulator_LED: out integer  RANGE 0 to 256;
	  
	  ram_memory_address :out integer range 0 to 256 
	--  ram_memory_address2 :out integer range 0 to 256 
		 
   
    );
end wavegraph;

architecture arch of wavegraph is
----------------------------------------------------------------------------------------------------------------
constant vertical: integer := 386;
constant horizontal: integer := 580;
constant hstart: integer := 20;
constant vstart : integer :=40;
--------------------------------------------------------------------------------------------------------------
signal trigbegin : std_logic ;
signal  adc_sample_accumulator : integer ;
signal ram_memory_address_accumulator: integer range 0 to 256 ;
signal ram_memory_address_hpos: integer range 0 to 256 ;
begin	  

wave: process(CLK, adc_data_clk, RST, videoon, hpos, vpos, adc_sample, adc_data, adc_data2, trigbegin, 
               ram_memory_address_hpos, ram_memory_address_accumulator)
variable  adc_conversion2 :integer;

variable voltagepixel , voltagepixel2  : integer  ;

begin
  
  if(adc_sample = '1') then
     ram_memory_address <= adc_sample_accumulator ;
  elsif(adc_sample = '0') then
     ram_memory_address <= hpos ;
  end if ;
     


   if(RST = '1') then 
	    rdreq <= '0';
		 adc_sample_accumulator <= 0;
	elsif (adc_data_clk'event and adc_data_clk  = '1') then

----------------------------------------------------------------------------------
	 if (adc_sample = '1') then

				  if(adc_data2 >= "001111101000") then 
							 trigbegin <= '1' ;
						end if ;
-----------------------------------------------------------------------------------------------------				  
								if ( trigbegin = '1') then
										rdreq <= '1';
										adc_sample_accumulator <=  adc_sample_accumulator + 1 ;
										--ram_memory_address <=  adc_sample_accumulator ;
										--ram_memory_address_accumulator <= adc_sample_accumulator;
--										ram_memory_address <= ram_memory_address_accumulator ;
									--	adc_sample_accumulator_LED <= adc_sample_accumulator;
--									  
											if(adc_sample_accumulator >=  512) then  
												rdreq <= '0';
												adc_sample_accumulator <=   0;
												trigbegin <= '0' ;
											--	ram_memory_address_accumulator <= 0 ;
											--	adc_sample_accumulator_LED <= 0 ;	
										  end if ;
								else  
								
									rdreq <= '0';
								--	ram_memory_address_accumulator <= 0 ;
									adc_sample_accumulator <=  0;
									
								--	adc_sample_accumulator_LED <= 0 ;
								end if ;
								
---	else
	    ---    ram_memory_address <= hpos ;
      end if ;
   end if;

---------------------------------------------------------------------------------------------------------------------------------------------------	 
	 
	 
	 
	 if(RST = '1') then 
	    voltagepixel := 0 ;
		 voltagepixel2 := 0 ;
	 elsif (clk'event and clk = '1') then
---------------------------------------------------------------------------------------------------------------------------------------------------
--	                 --   if (adc_sample = '0') then
--							    	ram_memory_address_hpos <= hpos;
--								--	ram_memory_address2 <=hpos + 1;
--							 -- end if;
-------------------------------------------------------------------------------------------------------------------------------------------------			
		      adc_conversion2 := (to_integer(unsigned(adc_data))) *10 ;---*(12207/10000000));--*10000;
				m1 <= adc_conversion2 mod 10;
				m2 <= (adc_conversion2/10) mod 10;
				m3 <= (adc_conversion2/100) mod 10;
				m4 <= (adc_conversion2/1000) mod 10;
				m5 <= (adc_conversion2/10000) mod 10;
				
--------------------------------------------------------------------------------------------------------------------------------- 
	         voltagepixel := -((94238 * (to_integer(unsigned(adc_data))) ) / 1000000 ) + 426 ; 	 
	      -- voltagepixel2 := -((94238 * (to_integer(unsigned(adc_data2))) ) / 1000000 ) + 426 ; 
	 
-------------------------------------------------------------------------------------------------------------------------------------
				 if(videoon = '1') then
						--   if  ((voltagepixel2 > voltagepixel) and (vpos < voltagepixel2 ) and (vpos > voltagepixel)) or  
					--		    ((voltagepixel2 < voltagepixel) and (vpos < voltagepixel ) and (vpos > voltagepixel2)) or
							 if ( vpos = voltagepixel)  then --and (voltagepixel2 = voltagepixel)  )  then
										if (( hpos >=hstart  ) and ( hpos <= horizontal ) and  ( vpos >=vstart  ) and ( vpos <= vertical )) then
											waveon <=  '1';  -----------------------------
										else
											waveon <=  '0';
										end if;
							else
							  waveon <=  '0';
							end if;
				 else
							waveon <=  '0';
				 end if;	


------------------------------------------------------------------------------------------------------------------------------------------
	 end if ;
    

end process ;

end architecture;



















