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
        --adc_sample_accumulator_LED: out integer RANGE 0 to 9 := 0;
		  stagetest: out std_logic_vector(11 downto 0) ;
		  H1: in std_logic_vector(2 downto 0) ;
		  adc_sample_accumulator_LED: out std_logic_vector(6 downto 0);
		  
		  functionswitch : in std_logic  ;
		  
		  triggerpin : in std_logic 
		  
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
----------------------------------------------------------------------------taking two hours to compile

signal videoon : std_logic; 
signal hpos ,vpos :integer;
signal texton , graphon , paron , par2on,waveon,triggeron : STD_LOGIC;
signal vtexton,vpar2on ,vpar3on ,vpar4on  : STD_LOGIC;
signal  adcclk: std_logic;
signal m1,m2,m3,m4,m5:  integer ;
signal mm1,mm2,mm3,mm4,mm5:  integer ;
signal f1,f2,f3,f4,f5 : integer ;
signal ff1,ff2,ff3,ff4,ff5,ff6 : integer := 0 ;
signal stagetest2 :  std_logic_vector(11 downto 0)  := "000000000000"  ;
--signal adc_sample_accumulator_LED: integer RANGE 0 to 9 := 0;
-----------------------------------------------------------------------------------

	signal adc_clk : std_logic;
	signal adc_clk2 : std_logic;
	
	
	
	signal rdreq : std_logic ;
	signal rdreq2 : std_logic ;
	
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
----------------------------------------------------------------------------------------
	 signal  sadctriggervalue : Std_logic_vector (11 downto 0)  ;
	 signal  adc_data_displayout : Std_logic_vector (11 downto 0)  ;
	-- signal functionswitch :  std_logic := '0' ;
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
	port map( CLK=>CLK,RST=>RST,hpos=>hpos,vpos=>vpos ,videoon =>videoon,graphon=>graphon,functionswitch => functionswitch);
	 
	    
	test: entity work.font_test_gen 
	port map(clk=>CLK,hpos=>hpos,vpos=>vpos ,videoon =>videoon,texton=>texton,paron=>paron,par2on=>par2on,
	          m1=>m1,m2=>m2,m3=>m3,m4=>m4,m5=>m5,mm1=>mm1,mm2=>mm2,mm3=>mm3,mm4=>mm4,mm5=>mm5,f1=>f1,f2=>f2,f3=>f3,f4=>f4,f5=>f5,
				 ff1=>ff1,ff2=>ff2,ff3=>ff3,ff4=>ff4,ff5=>ff5,ff6=>ff6,functionswitch => functionswitch,vtexton => vtexton,vpar2on => vpar2on,
				 vpar3on => vpar3on,vpar4on => vpar4on);
	

	RGB: entity work.RGB 
	port map(R=>R,G=>G,B=>B,texton=>texton,graphon=>graphon,paron=>paron,par2on=>par2on,waveon=>waveon,triggeron=>triggeron,vtexton=>vtexton,vpar2on=>vpar2on,
	vpar3on => vpar3on,vpar4on => vpar4on);
	
	adc: entity work.adc_sampler
	port map(adc_sclk => adc_sclk1 , clock => adc_clk, adc_din => adc_din , adc_dout=>adc_dout,adc_convst=>adc_convst,
	          adc_sample => adc_sample_clk1,reset =>RST , adc_data => fifo_data);

	adcsample: adcpll
	port map(refclk=> clk , outclk_0 => adc_clk ,rst=>RST);
	
	wave: entity work.wavegraph 
	port map(CLK=>CLK,RST=>RST,adc_data_clk => adc_clk ,adc_data=>  memory_data_out , adc_data2=>  memory_data_out2,
	adc_sample=>adc_sample_clk1,hpos=>hpos,vpos=>vpos,videoon=>videoon, m1=>m1,m2=>m2,m3=>m3,m4=>m4,m5=>m5,mm1=>mm1,mm2=>mm2,mm3=>mm3,mm4=>mm4,mm5=>mm5,f1=>f1,f2=>f2,f3=>f3,f4=>f4,f5=>f5,
	waveon=> waveon,triggeron=>triggeron ,rdreq => rdreq, rdreq2 => rdreq2, triggerpin  => triggerpin ,adc_sample_accumulator_LED => adc_sample_accumulator_LED,
	ram_memory_address =>  ram_memory_address , ram_memory_address2 =>  ram_memory_address2 ,fifo_data => fifo_data,
	sadctriggervalue => sadctriggervalue , H1 => H1 , testadctriggervalue => stagetest2, adc_data_displayout => adc_data_displayout,
	functionswitch => functionswitch);
	  
   measure: entity work.measurement 
					port map(clk	=>	clk,
								rst	=>	rst,
								adc_data_clk			=> adc_clk ,
								fifo_data				=>	fifo_data,
								adc_sample				=> adc_sample_clk1,
								ff1						=>	ff1,
								ff2						=>	ff2,
								ff3						=>	ff3,
								ff4						=>	ff4,
								ff5						=>	ff5,
								ff6						=>	ff6,
								stagetest				=>	stagetest,
								adctriggervalue		=>	sadctriggervalue ,
								adc_data_displayout	=>	adc_data_displayout
								);	
	
	memory: entity work.rammem 
					port map(
								clk	=>	adc_clk,
								addr	=>	ram_memory_address_std ,
								wr		=>	rdreq ,
								d		=>	fifo_data,
								q		=>	memory_data_out
								);

	memory2: entity work.rammem 
					port map(clk	=>	adc_clk ,
								addr	=>	ram_memory_address_std2 ,
								wr		=> rdreq2 ,
								d		=>	fifo_data,
								q		=>  memory_data_out2
								);


end behaviour;  