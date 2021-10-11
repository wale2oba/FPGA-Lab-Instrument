library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vgamul IS 
	port(CLK : in std_logic;
		  RST : in std_logic ;
		  HSYNC : out std_logic ;
		  VSYNC  : OUT STD_LOGIC ;
-----------------------------------------------------------------------------------------		  
		  blank : out STD_LOGic := '0' ;
		  sync : out STD_LOGIC  := '0' ;
-----------------------------------------------------------------------------------------		  
		  clk_out_clk : out STD_LOGIC ;   
-----------------------------------------------------------------------------------------		  
 hpos : inout integer := 0;
 vpos : inout integer := 0;
 videoon  :out std_logic := '0' 
 
	);
		  
end vgamul;


architecture behaviour of vgamul is 
----------------------------------------------------------------------------
signal clk25:std_logic := '0' ;
constant HD : integer := 639 ;
constant HFP : integer := 16 ;
constant HSP: integer := 96 ;
constant HBP: integer := 48 ;

constant VD : integer := 479;
constant VFP : integer := 10 ;
constant VSP: integer := 2 ;
constant VBP: integer := 33 ;

begin 
------------------------------------------------------------------------------------------
clk_div: process(clk)
begin
	if(CLK'event AND clk = '1') then 
			clk25 <= not clk25;
			clk_out_clk  <= clk25 ;
	end if ;
end process;

Horizontal_position_counter: process(clk25,RST)
begin 
	if(RST = '1') then 
		hpos <= 0;
	elsif(clk25'event and clk25 = '1') then
		if (hpos = HD + HFP + HSP + HBP) then
			hpos <= 0 ;
			
		else 
			hpos <= hpos + 1 ;  
			
		end if;
	
	end if ;
end process ; 

vertical_position_counter: process(clk25,RST,hpos)
begin 
	if(RST = '1') then 
		vpos <= 0;
		elsif(clk25'event and clk25 = '1') then
			if (hpos = (HD + HFP + HSP + HBP)) then
						if (vpos = (VD + VFP + VSP + VBP)) then
							vpos <= 0 ;
						
						else 
							vpos <= vpos + 1 ;
							
						end if;
	      end if ;
	end if ;
end process ; 

horizontal_synchronisation : process(clk25,RST,hpos)
begin
	if(RST = '1')then
	   HSYNC <= '0';
	elsif(clk25'event and clk25 = '1') then
		if ((hpos <= (HD + HFP )) OR (hpos > HD + HFP + HSP )) then 
		HSYNC <= '1' ;
		
		else 
		HSYNC <= '0'; 
		
		 end if ;
	end if ;
	
end process ;


vertical_synchronisation : process(clk25,RST,vpos)
begin
	if(RST = '1')then
	   VSYNC <= '0';
	elsif(clk25'event and clk25 = '1') then
	if ((vpos <= (VD + VFP )) OR (vpos > VD + VFP + VSP )) then 
		VSYNC <= '1' ;	
		else 
		VSYNC <= '0';		
		end if ;
	end if ;	
end process ;


blanking : process(clk25,RST,vpos,hpos)
begin

  if(RST = '1')then
	   blank <= '0';
	elsif(clk25'event and clk25 = '1') then
		if ((( (hpos >= HD) and (hpos <= HD + HFP) )  or ((hpos >= HD + HFP + HSP) and (hpos <= HD + HFP + HSP + HBP))) OR (((vpos >= VD) and (vpos <= VD + VFP)) or ((vpos >= VD + VFP + VSP) and (vpos <= VD + VFP + VSP + VBP))) ) then 
			blank <= '0';
			sync <= '0' ;	
			else 
			blank <= '1' ;
			sync <= '0';
		end if ;
	end if ;
end process;


video_on:process(clk25, RST , hpos , vpos )
begin
	if(RST = '1')then
	   videoon <= '0';
	elsif(clk25'event and clk25 = '1') then
	if(hpos <= HD and vpos <= VD ) then 
		videoon <= '1';
		else 
		videoon <= '0';
		
		end if;
	end if;
	
end process ;


end behaviour;  