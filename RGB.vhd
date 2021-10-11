library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RGB IS 
   port(texton , graphon ,paron ,par2on,waveon,triggeron: in std_logic := '0' ;
	     vtexton,vpar2on,vpar3on,vpar4on  : in std_logic := '0' ;
	  	  R: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		  G: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		  B: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
		  
end RGB;


architecture behaviour of RGB is 
begin
----------------------------------------------------------------------------
process(texton,graphon,paron,par2on,waveon,triggeron,
        vtexton, vpar2on, vpar3on, vpar4on)
begin


  if( texton = '1') then
     R <= "11001111" ;
     G <= "11111001" ;
     B <= "00111111" ;	 
  elsif(vtexton = '1') then  ----------------------------------------------
	  R <= "11111111" ;
     G <= "11111111" ;
     B <= "11111111" ; 	  
  elsif(graphon = '1') then
	  R <= "11111111" ;
     G <= "11111111" ;
     B <= "11111111" ;
  elsif(waveon = '1') then
	  R <= "00001111" ;
     G <= "11111111" ;
     B <= "11100111" ;
--  elsif(waveon2 = '1') then
--	  R <= "11110000" ;
--     G <= "11000111" ;
--     B <= "11100100" ;
  elsif(paron = '1') then
	  R <= "00111111" ;
     G <= "11111000" ;
     B <= "11000111" ;
  elsif(par2on = '1') then
	  R <= "00111111" ;
     G <= "11111000" ;
     B <= "11000111" ;
  elsif(vpar2on = '1') then ------------------------------------------
	  R <= "00111111" ;
     G <= "11111000" ;
     B <= "11000111" ;
  elsif(vpar3on = '1') then ------------------------------------------
	  R <= "00111111" ;
     G <= "11111000" ;
     B <= "11000111" ;
  elsif(vpar4on = '1') then ------------------------------------------
	  R <= "00111111" ;
     G <= "11111000" ;
     B <= "11000111" ;
  elsif(triggeron = '1') then
	  R <= "10000111" ;
     G <= "11111000" ;
     B <= "00111111" ;
  else
	  R <= "00000000" ;
	  G <= "00000000" ;
	  B <= "00000000" ;
  end if ;


end process;


end behaviour;  