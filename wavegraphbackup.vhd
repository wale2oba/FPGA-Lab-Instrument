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
     RST : in std_logic ;
	  
     adc_data: in std_logic_vector(11 downto 0) ;
	  adc_data2: in std_logic_vector(11 downto 0) ;
	  
	  fifo_data: in std_logic_vector(11 downto 0) ;
	  

	  
	  adc_sample : in std_logic ;
	  hpos : in integer := 0;
	  vpos : in integer := 0;
     videoon  : in std_logic := '0' ;
	  waveon  : out std_logic := '0' ;
	  waveon2  : out std_logic := '0' ;
	  m1,m2,m3,m4,m5 : out integer ;
	  
	  rdreq : out std_logic ;
	  rdreq2 : out std_logic ;
	  
	  
	  adc_sample_accumulator_LED: out integer  RANGE 0 to 256;
	  
	  ram_memory_address :out integer range 0 to 256 ;
     ram_memory_address2 :out integer range 0 to 256 
		 
   
    );
end wavegraph;

architecture arch of wavegraph is
------------------------------------------------------------------------------------------------
Type measure is array (0 to 2**9) of Std_logic_vector (11 downto 0);
Type trig is array (0 to 4) of Std_logic_vector (11 downto 0);
----------------------------------------------------------------------------------------------------------------
constant vertical: integer := 386;
constant horizontal: integer := 580;
constant hstart: integer := 20;
constant vstart : integer :=40;
--------------------------------------------------------------------------------------------------------------
constant adctriggervalue : Std_logic_vector (11 downto 0) :=  "000111110100" ;
--------------------------------------------------------------------------------------------------------------
Signal measurement : measure ;
Signal trigger :   trig ;

signal trigbegin : std_logic ;
signal trigbeginmap : std_logic ;
signal  adc_sample_accumulator : integer := 0;
signal memorytoggle: std_logic := '0' ;
signal adc_data_display: std_logic_vector(11 downto 0) ;

signal voltagepixeldisp , voltagepixeldisp2, voltagepixeldisp3 : std_logic_vector(11 downto 0) := (others => '0') ;

signal count : integer ;



begin	 


--
--measurementdisp :process( adc_data ,adc_sample_accumulator )
--begin
--   if(  measurement(adc_sample_accumulator  + 1)  >   measurement(adc_sample_accumulator)  ) then 
--	     voltagepixeldisp <= measurement(adc_sample_accumulator  + 1) ;
--	end if ;
--		
--		 
--end process;
  
---- 
--triggering : process(fifo_data , adc_data_clk)
--begin
--  
--  if (adc_data_clk'event and adc_data_clk = '1' ) then
--        if (adc_sample ='1') then
--              q <= fifo_data ;
--		    end if ;
--  end if;
--    		 
--		 if(q < "000111110100" )  then 
--				 if(fifo_data >= "000111110100"  ) then
--					  if(fifo_data = "000111110100" ) then
--							trigbeginmap <= '1' ;
--					  end if;
--				
--				 end if ;
--		 else 
--			   trigbeginmap <= '0' ;
--		 end if ;
--		  
-- 
--end process;


--------------------------



  
triggering : process(fifo_data , adc_data_clk, adc_sample )
begin
  
  if (adc_data_clk'event and adc_data_clk = '1' ) then
      if (adc_sample ='1') then
		    
					 trigger(count) <= fifo_data ;
				    count <= count + 1;
				    if (trigger(count + 1)  > trigger(count)) then 
				   	  if(fifo_data = adctriggervalue ) then
					      trigbeginmap <= '1';
						  end if;
					 else
					     trigbeginmap <= '0';
					 end if;
	
					 if(count >= 4) then
					   count <= 0 ;
			    	 end if;

		end if ;
  end if;
    	
end process;


 

wave: process(CLK, adc_data_clk, RST, videoon, hpos, vpos, adc_sample, adc_data, adc_data2, trigbegin,fifo_data)
variable  adc_conversion2 :integer;
variable voltagepixel , voltagepixel2  : integer  ;
  

begin
  
 


if(RST = '1') then 
	 rdreq <= '0';
	 rdreq2 <= '0';
	 adc_sample_accumulator <= 0;
	 adc_sample_accumulator_LED <= 0;
elsif(  adc_data_clk'event and adc_data_clk = '1'  ) then 
----------------------------------------------------------------------------------
								  if (adc_sample = '1') then
											
																    	if( trigbeginmap = '1') then 
																		   trigbegin <= '1';
															         end if;
															  
	

											   	if ( trigbegin = '1') then
									              	 	
															adc_sample_accumulator <= adc_sample_accumulator + 1 ;
																if(adc_sample_accumulator >=  512) then 
														   	   memorytoggle <= not memorytoggle ;	-------------------------------------------
																	adc_sample_accumulator <=   0;
																	trigbegin <= '0' ;
																	rdreq <= '0';	
																	rdreq2 <= '0';
																end if ;
																
																		if (memorytoggle = '1') then 
																		     rdreq <= '1';	
																			  rdreq2 <= '0';
																			  ram_memory_address <= adc_sample_accumulator ;
																			  
																			  measurement(adc_sample_accumulator ) <= adc_data ;
																			  
																					if(measurement(adc_sample_accumulator  + 1) > measurement(adc_sample_accumulator)) then 
																					   voltagepixeldisp <= measurement(adc_sample_accumulator  + 1) ;
																					end if ;
																					
																					if(measurement(adc_sample_accumulator  + 1) < measurement(adc_sample_accumulator)) then 
																					   voltagepixeldisp2 <= measurement(adc_sample_accumulator  + 1) ;
																					end if ;
																					
voltagepixeldisp3 <= std_logic_vector(to_unsigned(((to_integer(unsigned(voltagepixeldisp2))) + (to_integer(unsigned(voltagepixeldisp)))  / 2 ) ,12)) ;
																					
																				  
																			  ram_memory_address2 <= hpos ;
																			  adc_data_display <= adc_data2;
																			
																		elsif (memorytoggle = '0') then 
																		     rdreq2 <= '1';
																			  rdreq <= '0';
																			  ram_memory_address2 <= adc_sample_accumulator ;
																			  ram_memory_address <= hpos ;
																			  adc_data_display <= adc_data;
																			 
																		end if;
																  
															adc_sample_accumulator_LED <=  adc_sample_accumulator ;
									
												 end if ;
								 else
										rdreq <= '0';
								    	rdreq2 <= '0';	
										if (memorytoggle = '1') then 
											  ram_memory_address2 <= hpos ;
											  adc_data_display <= adc_data2;
										elsif (memorytoggle = '0') then 
											 ram_memory_address <= hpos ;
											 adc_data_display <= adc_data;
										end if;
										
								 end if; 
	
 

								 
end if;								
----------------------------------------------------------------------------------------------------------------------------------------------------------	  
	 if(RST = '1') then 
	    voltagepixel := 0 ;
		 voltagepixel2 := 0 ;
	 elsif (clk'event and clk = '1') then
----------------------------------------------------------------------------------------------------------------------------------------------------------
			

				if(videoon = '1') then
							 if ( vpos = voltagepixel)  then
										--if (( hpos >=hstart  ) and ( hpos <= horizontal ) and  ( vpos >=vstart  ) and ( vpos <= vertical )) then
											waveon <=  '1';  -----------------------------
									--	else
									--		waveon <=  '0';
									--	end if;
							else
							  waveon <=  '0';
							end if;
				 else
							waveon <=  '0';
				 end if;
								


-----------------------------------------------------------------------------------------------------------------------------------------------------
           voltagepixel := -((84472 * (to_integer(unsigned( adc_data_display ))) ) / 1000000 ) + 386 ; 	 

		      adc_conversion2 := (to_integer(unsigned(voltagepixeldisp3))) *10 ;---*(12207/10000000));--*10000;
				m1 <= adc_conversion2 mod 10;
				m2 <= (adc_conversion2/10) mod 10;
				m3 <= (adc_conversion2/100) mod 10;
				m4 <= (adc_conversion2/1000) mod 10;
				m5 <= (adc_conversion2/10000) mod 10;
	

------------------------------------------------------------------------------------------------------------------------------------------
	 end if ;


end process ;

end architecture;



























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
     RST : in std_logic ;
	  
     adc_data: in std_logic_vector(11 downto 0) ;
	  adc_data2: in std_logic_vector(11 downto 0) ;
	  
	  fifo_data: in std_logic_vector(11 downto 0) ;
	  

	  
	  adc_sample : in std_logic ;
	  hpos : in integer := 0;
	  vpos : in integer := 0;
     videoon  : in std_logic := '0' ;
	  waveon  : out std_logic := '0' ;

	  m1,m2,m3,m4,m5 : out integer ;
	  
	  rdreq : out std_logic ;
	  rdreq2 : out std_logic ;
	  

	  ram_memory_address :out integer range 0 to 256 ;
     ram_memory_address2 :out integer range 0 to 256 
		 
   
    );
end wavegraph;

architecture arch of wavegraph is
------------------------------------------------------------------------------------------------
Type trig is array (0 to 4) of Std_logic_vector (11 downto 0);
----------------------------------------------------------------------------------------------------------------
constant vertical: integer := 386;
constant horizontal: integer := 580;
constant hstart: integer := 20;
constant vstart : integer :=40;
--------------------------------------------------------------------------------------------------------------
constant adctriggervalue : Std_logic_vector (11 downto 0) :=  "000111110100" ;
--------------------------------------------------------------------------------------------------------------
Signal trigger :   trig ;

signal trigbegin : std_logic ;
signal trigbeginmap : std_logic ;
signal  adc_sample_accumulator : integer := 0;
signal memorytoggle: std_logic := '0' ;
signal adc_data_display: std_logic_vector(11 downto 0) ;
signal adc_data3: std_logic_vector(11 downto 0) ;

signal voltagepixeldisp  : std_logic_vector(11 downto 0) := (others => '0') ;
--signal voltagepixeldisp , voltagepixeldisp2, voltagepixeldisp3 : std_logic_vector(11 downto 0) := (others => '0') ;
signal count : integer ;



begin	 


  
triggering : process(fifo_data , adc_data_clk, adc_sample )
begin
  
  if (adc_data_clk'event and adc_data_clk = '1' ) then
      if (adc_sample ='1') then
		    
					 trigger(count) <= fifo_data ;
				    count <= count + 1;
				    if (trigger(count + 1)  > trigger(count)) then 
				   	  if(fifo_data = adctriggervalue ) then
					      trigbeginmap <= '1';
						  end if;
					 else
					     trigbeginmap <= '0';
					 end if;
	
					 if(count >= 4) then
					   count <= 0 ;
			    	 end if;

		end if ;
  end if;
    	
end process;


 

wave: process(CLK, adc_data_clk, RST, videoon, hpos, vpos, adc_sample, adc_data, adc_data2, trigbegin,fifo_data)
variable  adc_conversion2 :integer;
variable voltagepixel , voltagepixel2  : integer  ;
  

begin
  
 


if(RST = '1') then 
	 rdreq <= '0';
	 rdreq2 <= '0';
	 adc_sample_accumulator <= 0;

elsif(  adc_data_clk'event and adc_data_clk = '1'  ) then 
----------------------------------------------------------------------------------
								  if (adc_sample = '1') then
											
																    	if( trigbeginmap = '1') then 
																		   trigbegin <= '1';
															         end if;

											   	if ( trigbegin = '1') then
									              	 	
															adc_sample_accumulator <= adc_sample_accumulator + 1 ;
																if(adc_sample_accumulator >=  512) then 
														   	   memorytoggle <= not memorytoggle ;	-------------------------------------------
																	adc_sample_accumulator <=   0;
																	trigbegin <= '0' ;
																	rdreq <= '0';	
																	rdreq2 <= '0';
																end if ;
																
																		if (memorytoggle = '1') then 
																		     rdreq <= '1';	
																			  rdreq2 <= '0';
																			  ram_memory_address <= adc_sample_accumulator ;
																			  ram_memory_address2 <= hpos ;
											                          adc_data_display <= adc_data2;
																			  
--																			  ram_memory_address2 <= (hpos-1);
--																			  adc_data3 <= adc_data2;
--
--																			     
--																					if( adc_data_display > adc_data3) then 
--																					   voltagepixeldisp <= adc_data_display ;
--																					elsif( adc_data_display < adc_data3) then 
--																					   voltagepixeldisp <= adc_data3 ;
--																					end if ;
																	
																		elsif (memorytoggle = '0') then 
																		     rdreq2 <= '1';
																			  rdreq <= '0';
																			  ram_memory_address2 <= adc_sample_accumulator ;
																			  ram_memory_address <= hpos ;
																			  adc_data_display <= adc_data;
																		  
																	
--																			  ram_memory_address <= (hpos-1);
--																			  adc_data3 <= adc_data;
--																			  
--																					if( adc_data_display > adc_data3) then 
--																						voltagepixeldisp <= adc_data_display ;
--																					elsif( adc_data_display < adc_data3) then 
--																						voltagepixeldisp <= adc_data3 ;
--																					end if ;
																			 
																		end if;
																		

															end if ;
--								 else
          
	--     voltagepixeldisp3 <= std_logic_vector(to_unsigned(((to_integer(unsigned(voltagepixeldisp2))) + (to_integer(unsigned(voltagepixeldisp)))  / 2 ) ,12)) ;
			
--										rdreq <= '0';
--								    	rdreq2 <= '0';	
--										if (memorytoggle = '1') then 
--											  ram_memory_address2 <= hpos ;
--											  adc_data_display <= adc_data2;
--										elsif (memorytoggle = '0') then 
--											 ram_memory_address <= hpos ;
--											 adc_data_display <= adc_data;
--										end if;
										
								 end if; 
	
 
--voltagepixeldisp3 <= std_logic_vector(to_unsigned(to_integer(unsigned(voltagepixeldisp2))  ,12)) ;
								 
end if;								
----------------------------------------------------------------------------------------------------------------------------------------------------------	  
	 if(RST = '1') then 
	    voltagepixel := 0 ;
		 voltagepixel2 := 0 ;
	 elsif (clk'event and clk = '1') then
----------------------------------------------------------------------------------------------------------------------------------------------------------
			

				if(videoon = '1') then
							 if ( vpos = voltagepixel)  then
										--if (( hpos >=hstart  ) and ( hpos <= horizontal ) and  ( vpos >=vstart  ) and ( vpos <= vertical )) then
											waveon <=  '1';  -----------------------------
									--	else
									--		waveon <=  '0';
									--	end if;
							else
							  waveon <=  '0';
							end if;
				 else
							waveon <=  '0' ;
				 end if;
								


-----------------------------------------------------------------------------------------------------------------------------------------------------
           voltagepixel := -((84472 * (to_integer(unsigned( adc_data_display ))) ) / 1000000 ) + 386 ; 	 
			 
		      adc_conversion2 := (to_integer(unsigned(voltagepixeldisp))) *10 ;---*(12207/10000000));--*10000;
				m1 <= adc_conversion2 mod 10;
				m2 <= (adc_conversion2/10) mod 10;
				m3 <= (adc_conversion2/100) mod 10;
				m4 <= (adc_conversion2/1000) mod 10;
				m5 <= (adc_conversion2/10000) mod 10;
	

------------------------------------------------------------------------------------------------------------------------------------------
	 end if ;


end process ;

end architecture;


