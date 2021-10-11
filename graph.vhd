library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity graph IS 
	port(	  
			CLK				: in  std_logic			;   
			RST				: in  std_logic			;
			hpos				: in  integer		:=  0	;
			vpos				: in  integer		:=  0	;
			videoon			: in  std_logic	:= '0';
			functionswitch : in  std_logic	:= '0';
			graphon			: out std_logic	:= '0' 
		 );
end graph;


architecture behaviour of graph is 
	constant vertical		: integer := 386;
	constant horizontal	: integer := 580;
	constant thickness 	: integer :=   2;
	constant hstart		: integer :=  20;
	constant vstart 		: integer :=  40;

	--constant hmiddle1		: integer := (horizontal  /4) +  5 ;
	constant hmiddle 		: integer := (horizontal  /2) + 10 ;
	--constant hmiddle3		: integer := (3*horizontal/4) +  5 ;
	--constant vmiddle1		: integer := (vertical    /4) + 12 ;
	constant vmiddle 		: integer := (vertical    /2) + 20 ;
	--constant vmiddle3		: integer := (3*vertical  /4) + 10 ;
begin 
	
	boundary: process(CLK,RST,videoon,hpos,vpos)
	begin
		if(RST = '1')then
			graphon <= '0';
		elsif(CLK'event and CLK = '1') then
			if(videoon = '1') then
				if((((hpos >= hstart		 and  hpos <= (hstart + thickness))			 and (vpos >= vstart	   and  vpos <= vertical)) oR ((hpos >= hstart and hpos <= horizontal) and (vpos >= vstart		and vpos <= (vstart + thickness))) OR 
					 ((hpos >= horizontal and  hpos <= (horizontal + thickness))	 and (vpos >= vstart	   and  vpos <= vertical)) OR ((hpos >= hstart and hpos <= horizontal) and (vpos >= vertical	and vpos <= (vertical + thickness))) OR
					 --((vpos  = vmiddle1)	 and (hpos >= hstart and hpos <= horizontal)) OR	 
					 --((vpos  = vmiddle3)  and (hpos >= hstart and hpos <= horizontal)) OR	 
					 ((hpos  = hmiddle)	 and (vpos >= vstart and vpos <= vertical)) OR ((vpos = vmiddle ) and (hpos >= hstart and hpos <= horizontal))) and (functionswitch = '0')) then	 
					graphon	<= '1';
				else 
					graphon	<= '0';
				end if;								
			else
				graphon		<= '0';
			end if;
		end if ;
	end process ;

end behaviour;  