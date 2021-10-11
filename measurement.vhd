-- A module that interfaces with the LTC2308 ADC to obtain sampled data.
library ieee;
library lpm;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use lpm.lpm_components.all;

entity measurement is
port(
	    CLK 							: in	std_logic							;
	    adc_data_clk				: in	std_logic							;
       RST 							: in	std_logic							;
		 fifo_data					: in	std_logic_vector(11 downto 0) ;
		 adc_sample 				: in	std_logic							;
	 	 ff1,ff2,ff3,ff4,ff5,ff6: out	integer						:= 0	;
		 stagetest					: out	std_logic_vector(11 downto 0) := "000000000000" ; 
		 adctriggervalue 			: in	Std_logic_vector(11 downto 0) ;
		 adc_data_displayout		: in	std_logic_vector(11 downto 0) 
		-- freqcountled: out integer 
    );
end measurement ;

architecture behavioural of measurement is
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
type	 state_type is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
signal current , next_state : state_type ;
signal freqcount				 : integer 	 :=  0	;
signal freqmeasure			 : integer 	 :=  0	;
signal delaycount				 : integer 	 :=  0	;
signal fifo_data_integer	 : integer 				;
signal counten					 : std_logic := '0' 	;
signal trigmax					 : integer  			;
signal trigmin					 : integer  			;
	
begin	
     process(adc_data_clk)
	  begin
	      if (adc_data_clk'event and adc_data_clk = '1' ) then 
	          current <= next_state ;
	      end if;
	  end process;

	  process( adc_data_clk ,fifo_data,counten,freqcount,trigmin,fifo_data_integer,trigmax ,adctriggervalue ,adc_data_displayout )
	  begin
	  
			if (adc_data_clk'event and adc_data_clk = '1' ) then 
				fifo_data_integer <= to_integer(unsigned(fifo_data))						;
				trigmax 				<= to_integer(unsigned(adctriggervalue)) + (10/100); 
				trigmin 				<= to_integer(unsigned(adctriggervalue)) - (10/100);
				  
				if (counten = '1') then
				  freqcount			<= freqcount + 1;
				--else
				--   freqcount		<= freqcount ;
				  stagetest			<= "100000000000";
				end if ;
				  
				case current is
					when s0 => 
						  fifo_data_integer  <= to_integer(unsigned(fifo_data)) ;
						  trigmax				<= to_integer(unsigned(adctriggervalue)) + (10/100); 
						  trigmin				<= to_integer(unsigned(adctriggervalue)) - (10/100) ;
						--  freqcount 			<= 0;
						  next_state			<= s1 ;
						  stagetest				<= "000000000001";
					when s1 =>
						  if (fifo_data_integer > trigmax) then 
								next_state <= s2 ;
						  else 
								next_state <= s6 ;
						  end if ;
							stagetest <= "000000000010" ;
							
					when s2 => 
						  if(fifo_data_integer < trigmin) then
							  next_state <= s3 ;
						  else 
							  next_state <= s2 ;
						  end if;
						  stagetest <= "000000000100" ;
						  
					when s3 =>
						  --start counting 
						  freqcount <= 0; 
						  counten <= '1';
						  next_state <= s4 ;
						  stagetest <= "000000001000" ;
						  
					when s4 =>
						  if(fifo_data_integer > trigmax) then 
							 next_state <= s5 ;
						  else
							 next_state <= s4 ;
						  end if;
						  stagetest <= "000000010000" ;
						  
					when s5 =>
						 if(fifo_data_integer < trigmin) then
							  --stop counting
							  counten <= '0' ; 
							  next_state <= s10 ;
						 else
							  next_state <= s5 ;
						 end if ;
						 stagetest <= "000000100000" ;		
						 
					when s6 =>
						  if (fifo_data_integer > trigmax) then 
							 next_state <= s7 ;
						  else 
							  next_state <= s6;
						  end if;
						  stagetest <= "000001000000" ;
						  
					when s7 =>		
							--start counting
						  freqcount <= 0; 
						  counten <= '1';
						  next_state <= s8 ;		
						  stagetest <= "000010000000" ;
						  
					when s8 => 
						  if(fifo_data_integer <trigmin) then 
							 next_state <= s9 ;
						  else
							 next_state <= s8 ;
						  end if;
						  stagetest <= "000100000000" ;
						  
					when s9 =>
								  if(fifo_data_integer > trigmax) then 
								  ----stop counting
									  counten <= '0' ; 
									  
									  next_state <= s10 ;
								  else
									  next_state <= s9 ;
								  end if ;
								  stagetest <= "001000000000" ;
								  
					when s10 =>
							  delaycount <= delaycount + 1;		
							  
							  if(delaycount > 1000000) then
								 freqmeasure <= 40000000 / freqcount ;
								 ff1 <= freqmeasure mod 10;
								 ff2 <= (freqmeasure/10) mod 10;
								 ff3 <= (freqmeasure/100) mod 10;
								 ff4 <= (freqmeasure/1000) mod 10;
								 ff5 <= (freqmeasure/10000) mod 10;
								 ff6 <= (freqmeasure/100000) mod 10;
								 next_state <= s0 ;
								 delaycount <= 0 ;
							  end if ;
							  stagetest <= "010000000000" ;
		
				 end case ;
			 
	  end if;

	  end process;

end behavioural;








---- A module that interfaces with the LTC2308 ADC to obtain sampled data.
--library ieee;
--library lpm;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use ieee.math_real.all;
--use lpm.lpm_components.all;
--
--entity measurement is
--port(
--	    CLK : in std_logic ;
--	    adc_data_clk : in std_logic ;
--       RST : in std_logic ;
--		 fifo_data: in std_logic_vector(11 downto 0) ;
--		 adc_sample : in std_logic ;
--		 f1,f2,f3,f4,f5 : out integer ;
--		 freqcountled: out integer 
--    );
--end measurement ;
--
--
--
--architecture behavioural of measurement is
----------------------------------------------------------------------------------------------------------------------------------
--constant adctriggervalue : Std_logic_vector (11 downto 0) :=  "000111110100" ;
----------------------------------------------------------------------------------------------------------------------------------
--type state_type is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
--signal current , next_state : state_type ;
--
--signal freqcount : integer := 0 ;
--signal freqmeasure : integer := 0 ;
--signal fifo_data_integer : integer ;
--signal  counten : std_logic ;
--signal trigmax: integer  ;
--signal trigmin : integer  ;
--	
--
--
--begin	
--    
--     process(clk)
--	  begin
--	      if (clk = '1') then 
--	          current <= next_state ;
--	      end if;
--	  end process;
--	  
--	  
--	  
--	  process( fifo_data )
--	  begin
--	  fifo_data_integer  <= to_integer(unsigned(fifo_data )) ;
--	  freqcountled <= freqcount ;
--	  
--	  
--	       case current is
--			   when s0 => 
--				     trigmax <=  to_integer(unsigned(adctriggervalue )) + (10/100); 
--					  trigmin <=  to_integer(unsigned(adctriggervalue )) - (10/100) ;
--					  next_state <= s1 ;
--				when s1 =>
--				     if (fifo_data > adctriggervalue) then 
--					      next_state <= s2 ;
--					  elsif (fifo_data < adctriggervalue) then
--					      next_state <= s6 ;
--					  end if ;
--				when s2 => 
--				     if(fifo_data < adctriggervalue) then
--					     next_state <= s3 ;
--					  else 
--					     next_state <= s2 ;
--					  end if;
--			   when s3 =>
--							  --start counting  
--							-- if(counten = '1') then   ----------------------------
--								 freqcount <= freqcount + 1;
--								 next_state <= s4 ;
--						    else 
--							    next_state <= s2 ;
--							 end if ;    -------------------------------------
--							  
--				when s4 =>
--				     if(fifo_data >adctriggervalue) then 
--					    next_state <= s5 ;
--					  else
--					    next_state <= s4 ;
--					  end if;
--				when s5 =>
--							  if(fifo_data < adctriggervalue) then 
--								 ----stop counting
--								counten <= '0' ; -----------------------------
--								next_state <= s10 ;
--								else
--								next_state <= s5 ;
--							  end if ;
--							  
--			   when s6 =>
--					  if (fifo_data > adctriggervalue) then 
--					    next_state <= s7 ;
--					  else 
--					     next_state <= s6;
--					  end if;
--				when s7 =>
--							  -- start counting  
--							  if(counten = '1') then -----------------------------------
--								 freqcount <= freqcount + 1;
--								 next_state <= s8 ;
--							  else
--							    next_state <= s6 ;
--							  end if ;   -----------------------------------------
--							  
--				when s8 => 
--				     if(fifo_data < adctriggervalue) then 
--					  next_state <= s9 ;
--					  else
--					  next_state <= s8 ;
--					  end if;
--				when s9 =>
--							  if(fifo_data > adctriggervalue) then 
--							  ----stop counting
--							  counten <= '0' ;  ----------------
--							  next_state <= s10 ;
--							  else
--							  next_state <= s9 ;
--							  end if ;
--			   when s10 =>
--				     freqmeasure <= 40000000 / freqcount ;
--
--						f1 <= freqmeasure mod 10;
--						f2 <= (freqmeasure/10) mod 10;
--						f3 <= (freqmeasure/100) mod 10;
--						f4 <= (freqmeasure/1000) mod 10;
--						f5 <= (freqmeasure/10000) mod 10;
--						
--					  counten <= '1' ;  -----------------
--					  next_state <= s0 ;
--	
--	       end case ;
--	  end process;
--	  
--	  
--
--end behavioural;
--
