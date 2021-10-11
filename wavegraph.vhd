library ieee;
library lpm;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use lpm.lpm_components.all;

LIBRARY altera_mf;
USE altera_mf.all;


entity wavegraph is

port(
	  CLK 						: in std_logic ;
	  adc_data_clk 			: in std_logic ;
     RST 						: in std_logic ;
	  
     adc_data					: in std_logic_vector(11 downto 0) ;
	  adc_data2					: in std_logic_vector(11 downto 0) ;
	  
	  fifo_data					: in std_logic_vector(11 downto 0) ; 

	  adc_sample 				: in std_logic ;
	  hpos 						: in integer := 0;
	  vpos 						: in integer := 0;
     videoon 			 		: in std_logic := '0' ;
	  
	  H1							: in std_logic_vector(2 downto 0) ;
  
	  waveon  					: out std_logic := '0' ;
	  waveon2  					: out std_logic := '0' ;
	  triggeron 				: out std_logic := '0' ;
	  m1,m2,m3,m4,m5 			: out integer ;
	  mm1,mm2,mm3,mm4,mm5 	: out integer ;
	  f1,f2,f3,f4,f5 			: out integer ;
	  
	  rdreq 						: out std_logic ;
	  rdreq2 					: out std_logic ;
	  
	  adc_sample_accumulator_LED: out std_logic_vector(6 downto 0);
	  
	  ram_memory_address 	: out integer range 0 to 256 ;
     ram_memory_address2 	: out integer range 0 to 256 ;
	  sadctriggervalue 		: out Std_logic_vector (11 downto 0) ;
	  
	  testadctriggervalue 	: out Std_logic_vector (11 downto 0) ;
	  adc_data_displayout	: out std_logic_vector(11 downto 0) ;
	  
	  functionswitch 			: in std_logic := '0' ;
	  
	  triggerpin 				: in std_logic := '0' 
    );
end wavegraph;

architecture arch of wavegraph is

	SIGNAL stoSQRT 				: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL sfromSQRT 				: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL sRemainder				: STD_LOGIC_VECTOR (16 DOWNTO 0);

	COMPONENT altsqrt
		GENERIC (
						pipeline			: NATURAL;
						q_port_width	: NATURAL;
						r_port_width	: NATURAL;
						width				: NATURAL;
						lpm_type			: STRING
					);
		PORT (
					radical				: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
					q						: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
					remainder			: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
				);
	END COMPONENT;

	------------------------------------------------------------------------------------
	--Type measure is array (0 to 2**9) of Std_logic_vector (11 downto 0);
	Type trig is array (0 to 4) of Std_logic_vector (11 downto 0);
	------------------------------------------------------------------------------------
	constant vertical		: integer := 386;
	constant horizontal	: integer := 580;
	constant hstart		: integer :=  20;
	constant vstart		: integer :=  40;
	-------------- Constants for scaling the outputs to compensate for errors ----------
	constant scaleMinMax : integer := 1000; --1037;
	constant findRMS		: integer := 7071;
	------------------------------------------------------------------------------------

	------------------------------------------------------------------------------------
	--Signal measurement : measure ;
	Signal trigger 		:   trig ;

	signal trigbegin 					: std_logic ;
	signal trigbeginmap 				: std_logic ;
	signal adc_sample_accumulator : integer								:=  0 ;
	signal adc_sample_accumulator_scale : integer						:=  0 ;
	signal memorytoggle				: std_logic								:= '0';
	signal adc_data_display			: std_logic_vector(11 downto 0)	:= (others => '0');
	signal adc_data3, adc_data4	: std_logic_vector(11 downto 0)	:= (others => '0');
	signal adc_data5 ,adc_data6	: std_logic_vector(11 downto 0)	:= (others => '0');
	signal voltagepixeldisp			: std_logic_vector(11 downto 0)	:= (others => '0');
	signal voltagepixeldisp2		: std_logic_vector(11 downto 0)	:= (others => '0');
	signal voltagepixeldisp3		: std_logic_vector(11 downto 0)	:= (others => '0');
	signal count						: integer 	:= 0 ;

	signal trigdisp					: integer;
	signal pinpress					: std_logic	:= '0';
	signal Htotal						: integer	:=  2 ;
	signal Htotal1						: integer	:=  1 ;

begin	 
triggering : process(clk, fifo_data, adc_data_clk, RST, adc_sample, triggerpin, vpos, hpos, videoon, trigdisp, functionswitch) -- ,adctriggervalue,adctriggerconvt)
	variable adctriggervalue		: Std_logic_vector (11 downto 0) ;
	variable adctriggerconvt		: integer;
	variable triggercount			: integer;

begin
	if(RST = '1') then 
		triggercount			:= 0 ;

	elsif (clk'event and clk = '1') then
		if(triggerpin = '0') then
			pinpress				<= '1' ;
		end if;
	  
		if( (triggerpin = '1') and (pinpress = '1') )then
			triggercount		:= triggercount + 1;
			if(triggercount >= 21) then --6)  then
				triggercount	:= 0 ;
			end if;
			pinpress				<= '0' ;    	   
		end if;

		Htotal					<= to_integer(unsigned(H1)) * 40;

		adc_sample_accumulator_LED <= std_logic_vector (to_unsigned(triggercount,7));
		adctriggerconvt		:= (triggercount * 10000000 ) / 48828; --12207; ----------------
		adctriggervalue		:=  std_logic_vector (to_unsigned(adctriggerconvt,12));
		testadctriggervalue	<=  std_logic_vector (to_unsigned(adctriggerconvt,12));
		sadctriggervalue		<=  std_logic_vector (to_unsigned(adctriggerconvt,12));
		trigdisp					<=  vertical - ((84472 * adctriggerconvt ) / 1000000 );

	  --"100110011001" ; --2457-- 3volt
	  --((triggercount / 12207) * 10000000 );
	  
			  
 end if ;
---------------------------------------------------------------------------------------
		 if(videoon = '1') then
			  if ((vpos = trigdisp) and (hpos > hstart and hpos < horizontal) and (functionswitch = '0')   )then
				 triggeron <=  '1';  -----------------------------
			  else
				 triggeron <=  '0';
			  end if ;
		 else
			  triggeron <=  '0';
		 end if; 
   
-----------------------------------------------------------------------------------------------------------------------------  
  
  if (adc_data_clk'event and adc_data_clk = '1' ) then
      if (adc_sample ='1') then
		 
			 count <= count + 1;
			 if(count >= 5) then
				count <= 0 ;
			 end if;
			 
			 trigger(count) <= fifo_data ;
			 if ( trigger(count)  > adctriggervalue ) then 
				  if(trigger(count - 1) = adctriggervalue ) then
						trigbeginmap <= '1';
				  end if;
			 else
				  trigbeginmap <= '0';
			 end if;
		end if ;
  end if;
end process;
----------------------------------------------------------------------------------------------------------------------------------

wave: process(CLK, adc_data_clk, RST, videoon, hpos, vpos, adc_sample, adc_data, adc_data2, trigbegin,fifo_data)
variable  adc_conversion2					: integer;
variable  adc_conversion3					: integer;
variable  adc_conversion4					: integer;
variable  adc_conversion4_temp			: integer;
variable  voltagepixel, voltagepixel2  : integer;
variable  rmsCompAccumulator				: integer:= 0; -- Accumulator for computing the RMS value of readings
variable  rmsCompAccumulated				: integer:= 0; -- Accumulated for computing the RMS value of readings
variable  rmsCompCounter					: integer:= 0; -- Counter for determining when to start and stop accumulating values for RMS accumulator
variable  rmsCompCounterMaxValue			: integer:= 10000000; -- Max value allowed for the Counter for determining RMS
variable  rmsCompAccumulatorReset		: integer:= 0; -- Used to reset the accumulator on the next count
variable  dcCouplingError					: integer:= 0; -- a dc error found during reset and subtracted from all readings.

begin
	-------- Find the Max and Min values of the voltage -----------------
	if(RST = '1') then 
		rdreq 							<= '0';
		rdreq2 							<= '0';
		adc_sample_accumulator		<=  0 ;
		rmsCompAccumulated			:=  0 ;
		rmsCompAccumulator			:=  0 ;
		rmsCompCounter					:=  0 ;
		dcCouplingError				:= (to_integer(unsigned(fifo_data)));
----------------------------------------------------------------------------------
	elsif(  adc_data_clk'event and adc_data_clk = '1'  ) then 
		-------- Accumulate data for the rms = sqrt(sum(V^2) / N) algorithm --------------
		if (rmsCompCounter < rmsCompCounterMaxValue) then
			rmsCompAccumulator		:= rmsCompAccumulator + ((to_integer(unsigned(fifo_data)) * to_integer(unsigned(fifo_data))));
			rmsCompCounter				:= rmsCompCounter + 1;
		else
			rmsCompAccumulated		:= rmsCompAccumulator;
			rmsCompAccumulatorReset := 1;
		end if;
		if (rmsCompAccumulatorReset = 1) then
			rmsCompAccumulator		:= 0;
			rmsCompCounter				:= 0;
			rmsCompAccumulatorReset := 0;
		end if;
		
		if (adc_sample = '1') then

			if( trigbeginmap = '1') then 
				trigbegin						<= '1';
			end if;

			if ( trigbegin = '1') then									            	
				Htotal1 <= Htotal1 - 1 ;
				if(Htotal1 <= 0) then
				  adc_sample_accumulator	<= adc_sample_accumulator + 1 ;
				  Htotal1 <= Htotal ;
				end if;
				
				if(adc_sample_accumulator 	>=  530) then 
					memorytoggle				<= not memorytoggle ;	-------------------------------------------
					adc_sample_accumulator	<=   0;
					trigbegin					<= '0' ;
					rdreq							<= '0';	
					rdreq2						<= '0';
				end if ;
				
				if (memorytoggle = '1') then 
					rdreq 						<= '1';
					rdreq2 						<= '0';
					ram_memory_address 		<= adc_sample_accumulator ;

					adc_data4 					<= (others => '0') ;
					if(fifo_data > adc_data3) then 
						voltagepixeldisp2 	<= fifo_data ;
						adc_data3 				<= fifo_data ;
					end if;

					adc_data6 					<= (others => '1') ;
					if(fifo_data < adc_data5) then 
						voltagepixeldisp3 	<= fifo_data  ;
						adc_data5 				<= fifo_data ;
					end if;
					
				elsif (memorytoggle = '0') then 
					rdreq2 						<= '1';
					rdreq 						<= '0';
					ram_memory_address2 		<= adc_sample_accumulator ;
					--																		
					adc_data3 					<= (others => '0') ;
					if(fifo_data > adc_data4) then 
						voltagepixeldisp2 	<= fifo_data ;
						adc_data4 				<= fifo_data ;
					end if;

					adc_data5 					<= (others => '1') ;
					if(fifo_data < adc_data6) then 
						voltagepixeldisp3 	<= fifo_data ;
						adc_data6 				<= fifo_data ; 
					end if;
					--															 
				end if;
				
			end if ;
		else
			rdreq <= '0';
			rdreq2 <= '0';					
			if (memorytoggle = '1') then 
				 ram_memory_address2 		<= hpos ;
				 adc_data_display 			<= adc_data2;
				 adc_data_displayout 		<= adc_data2;		  
			elsif (memorytoggle = '0') then 
				 ram_memory_address 			<= hpos ;
				 adc_data_display 			<= adc_data;
				 adc_data_displayout 		<= adc_data; 											 
			end if;		
		end if; 
	end if;								
	----------------------------------------------------------------------------------------------------------------------------------------------------------	  
	if(RST = '1') then 
	    voltagepixel  := 0 ;
		 voltagepixel2 := 0 ;
	----------------------------------------------------------------------------------------------------------------------------------------------------------
	elsif (clk'event and clk = '1') then
		if(videoon = '1') then
			if ((vpos = voltagepixel) and (functionswitch = '0')) then
				if ((hpos >= hstart  ) and (hpos <= horizontal) and  (vpos >=vstart) and (vpos <= vertical)) then
					waveon 	<=  '1';  -----------------------------
				else
					waveon 	<=  '0';
				end if;
			else
				waveon 		<=  '0';
			end if;
		else
			waveon 			<=  '0';
		end if;								
	------------------------------------------------------------------------------------------------------------------------
		voltagepixel		:= -((84472 * (to_integer(unsigned( adc_data_display ))) ) / 1000000 ) + 386 ; 	 -- Scaling the display to fill the graph
		--voltagepixeldisp <= voltagepixeldisp2 ;  --max

	------------- Scale the max value --------------------------				
		adc_conversion2 := (((to_integer(unsigned(voltagepixeldisp2))) - dcCouplingError) * scaleMinMax ) /1000 ;---*(12207/10000000));--*10000; 
		m1 <= adc_conversion2 mod 10;
		m2 <= (adc_conversion2/10) mod 10;
		m3 <= (adc_conversion2/100) mod 10;
		m4 <= (adc_conversion2/1000) mod 10;
		m5 <= (adc_conversion2/10000) mod 10;
					
	------------ Scale the min value --------------------------				
		adc_conversion3 := (((to_integer(unsigned(voltagepixeldisp3))) - dcCouplingError) * scaleMinMax ) / 1000  ;---*(12207/10000000));--*10000;
		mm1 <=  adc_conversion3 mod 10;
		mm2 <= (adc_conversion3/10) mod 10;
		mm3 <= (adc_conversion3/100) mod 10;
		mm4 <= (adc_conversion3/1000) mod 10;
		mm5 <= (adc_conversion3/10000) mod 10;
					
	------------ Scale the rms value --------------------------
		adc_conversion4_temp := rmsCompAccumulated / rmsCompCounterMaxValue; --((adc_conversion3 * adc_conversion3) + ((adc_conversion2 * adc_conversion2 ) / 2));
		sToSQRT <= std_logic_vector(to_unsigned(adc_conversion4_temp, 32));
		--adc_conversion4 := to_integer(unsigned(sFromSQRT)); -- formula is vrms = sqrt(vmin^2 + (amax^2 /2)) --
		adc_conversion4 := (adc_conversion3 + ((((adc_conversion2 - adc_conversion3) * findRMS)) / 10000)) ;---*(12207/10000000));--*10000;
		f1 <=  adc_conversion4 mod 10;
		f2 <= (adc_conversion4/10) mod 10;
		f3 <= (adc_conversion4/100) mod 10;
		f4 <= (adc_conversion4/1000) mod 10;
		f5 <= (adc_conversion4/10000) mod 10;
	------------------------------------------------------------------------------------------------------------------------------------------
	end if ;

end process ;

	ALTSQRT_component : ALTSQRT
	GENERIC MAP (
		pipeline => 0,
		q_port_width => 16,
		r_port_width => 17,
		width => 32,
		lpm_type => "ALTSQRT"
	)
	PORT MAP (
		radical => sToSQRT,
		q => sfromSQRT,
		remainder => sRemainder
	);


end architecture;