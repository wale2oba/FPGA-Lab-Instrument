-----Font generating module

 -- Listing 13.2  
 library ieee;  
 use ieee.std_logic_1164.all;  
 use ieee.numeric_std.all;  
 entity font_test_gen is  
   port(  
    clk: in std_logic;  
    videoon: in std_logic;  
    hpos, vpos: in integer;  
	 texton , paron ,par2on: out std_logic;
	 vtexton , vpar2on ,vpar3on  ,vpar4on: out std_logic;
	 m1,m2,m3,m4,m5 : in integer ;
	 mm1,mm2,mm3,mm4,mm5 : in integer ;
	 ff1,ff2,ff3,ff4,ff5,ff6: in integer ;
	 f1,f2,f3,f4,f5 : in integer ;
	 functionswitch : in std_logic := '0' 

      );  
		
		
 end font_test_gen;  
 
 
 architecture arch of font_test_gen is  
   signal rom_addr: std_logic_vector(10 downto 0);  
   signal char_addr,char_addr_t,char_addr_p,char_addr_p2: std_logic_vector(6 downto 0);  
   signal row_addr,row_addr_t,row_addr_p,row_addr_p2: std_logic_vector(3 downto 0);  
   signal bit_addr,bit_addr_t,bit_addr_p,bit_addr_p2: std_logic_vector(2 downto 0);  
	signal text_on, par_on,par2_on : std_logic;
   signal font_word: std_logic_vector(7 downto 0);  
   signal font_bit, text_bit_on: std_logic;  
	signal pix_x,pix_y :  unsigned(9 downto  0) ; 
	
	signal vtext_on , vpar2_on , vpar3_on, vpar4_on : std_logic;
	signal vchar_addr_p2 ,vchar_addr_p3 ,vchar_addr_p4 ,vchar_addr_t : std_logic_vector(6 downto 0);  
	signal vrow_addr_t,vrow_addr_p2,vrow_addr_p3,vrow_addr_p4: std_logic_vector(3 downto 0);  
   signal vbit_addr_t,vbit_addr_p2,vbit_addr_p3,vbit_addr_p4: std_logic_vector(2 downto 0);  
	
	
	--vtext_on , vpar2_on,  vchar_addr_p2 ,vchar_addr_t
	
 begin  
 
 
				 
				 pix_x <= to_unsigned(hpos,10); 
				 pix_y <= to_unsigned(vpos,10); 
				 -- instantiate font ROM 	
				 font_unit: entity work.font_rom  
				 port map(clk=>clk, addr=>rom_addr, data=>font_word);   
				 
				 --------------------------------------------
				 --AN FPGA BASED DIGITAL OSCILLOSCOPE
				 -------------------------------------------	
 
				 text_on  <= 
					 '1'  when  pix_y(9  downto  5 ) = 0   and 
						 (1<= pix_x(9  downto  4) and pix_x(9  downto  4) <=34) and (functionswitch = '0' ) else  
					 '0';
					 
				 row_addr_t <= std_logic_vector(pix_y(4 downto 1)) ;  
				 bit_addr_t <= std_logic_vector(pix_x(3 downto  1)) ;
				 
				 with pix_x(9 downto  4) select
						char_addr_t <= 
							"1000001" when  "000001",  ---A
							"1001110" when  "000010",  ---N
							"0000000" when  "000011",  ---space
							"1000110" when  "000100",  ---F
							"1010000" when  "000101",  ---P
							"1000111" when  "000110",  ---G
							"1000001" when  "000111",  ---A
							"0000000" when  "001000",  ---space
							"1000010" when  "001001",  ---B
							"1000001" when  "001010",  ---A
							"1010011" when  "001011",  --- S
							"1000101" when  "001100",  --- E
							"1000100" when  "001101",  --- D
							"0000000" when  "001110",  --- space
							"1000100" when  "001111",  --- D
							"1001001" when  "010000",  --- I
							"1000111" when  "010001",  --- G
							"1001001" when  "010010",  --- I
							"1010100" when  "010011",  --- T
							"1000001" when  "010100",  --- A
							"1001100" when  "010101",  --- L
							"0000000" when  "010110",  --- space
							"1001111" when  "010111",  --- O
							"1010011" when  "011000",  --- S
							"1000011" when  "011001",  --- C
							"1001001" when  "011010",  --- I
							"1001100" when  "011011",  --- L
							"1001100" when  "011100",  --- L
							"1001111" when  "011101",  --- O
							"1010011" when  "011110",  --- S
							"1000011" when  "011111",  --- C
							"1001111" when  "100000",  --- O
							"1010000" when  "100001",  --- P
							"1000101" when  "100010",  --- E
							"0111000" when others;   ---
				
----------------------------------------------------------------------------------------------------------------------------------------------------------
vtext_on  <= 
    '1'  when  pix_y(9  downto  5 ) = 0   and 
       (3<= pix_x(9  downto  4) and pix_x(9  downto  4) <=37) and (functionswitch = '1' ) else  
    '0';
	 
 vrow_addr_t <= std_logic_vector(pix_y(4 downto 1)) ;  
 vbit_addr_t <= std_logic_vector(pix_x(3 downto  1)) ;
 
 with pix_x(9 downto  4) select
      vchar_addr_t <= 
		   "1000001" when  "000001",  ---A
		   "1001110" when  "000010",  ---N
			"0000000" when  "000011",  ---space
			"1000110" when  "000100",  ---F
			"1010000" when  "000101",  ---P
			"1000111" when  "000110",  ---G
			"1000001" when  "000111",  ---A
			"0000000" when  "001000",  ---space
			"1000010" when  "001001",  --- B
			"1000001" when  "001010",  --- A
			"1010011" when  "001011",  --- S
			"1000101" when  "001100",  --- E
			"1000100" when  "001101",  --- D
			"0000000" when  "001110",  --- space
			"1000100" when  "001111",  --- D
			"1001001" when  "010000",  --- I
			"1000111" when  "010001",  --- G
			"1001001" when  "010010",  --- I
			"1010100" when  "010011",  --- T
			"1000001" when  "010100",  --- A
			"1001100" when  "010101",  --- L
			"0000000" when  "010110",  --- space
			"1010110" when  "010111",  --- V
			"1001111" when  "011000",  --- O
			"1001100" when  "011001",  --- L
			"1010100" when  "011010",  --- T
			"1001101" when  "011011",  --- M
			"1000101" when  "011100",  --- E
			"1010100" when  "011101",  --- T
			"1000101" when  "011110",  --- E
			"1010010" when  "011111",  --- R
			--to_stdlogicvector(x"52")(6 downto 0) when  "011111",  --- R
			"0000000" when others;   ---
			
---------------------------------------------------------------------------------------------------------------------------------			
						
				-------------------------------------------------
				--PARAMETER DISPLAY
				------------------------------------------------
				 
				par_on  <= 
					 '1'  when  pix_y(9  downto  5 ) = 13   and 
						 ( 1<= pix_x(9  downto  4) and pix_x(9  downto  4) <=39 ) and (functionswitch = '0' ) else  
					 '0';
					 
					 
				row_addr_p <= std_logic_vector(pix_y(4 downto 1)) ;  
				bit_addr_p <= std_logic_vector(pix_x(3 downto  1)) ;


				with pix_x(9 downto  4) select
						char_addr_p <= 
							"1010110" when  to_unsigned(1,6),  ---V
							"0110001" when  to_unsigned(2,6),  ---1
							"0101000" when  to_unsigned(3,6),  ---(
							"1010110" when  to_unsigned(4,6),  ---V
							"0101001" when  to_unsigned(5,6),  ---)
							"0111010" when  to_unsigned(6,6),  ---:
							"011" & (std_logic_vector(to_unsigned(m4,4))) when  to_unsigned(7,6),  
							"0101110" when  to_unsigned(8,6),  ---dot
							"011" & (std_logic_vector(to_unsigned(m3,4))) when  to_unsigned(9,6),  
							"011" & (std_logic_vector(to_unsigned(m2,4))) when  to_unsigned(10,6),  
							"011" & (std_logic_vector(to_unsigned(m1,4))) when  to_unsigned(11,6), 
							"1001101" when  to_unsigned(12,6),  ---M
							"1000001" when  to_unsigned(13,6), ---A
							"1011000" when  to_unsigned(14,6),  ---x
							"0000000" when  to_unsigned(15,6),  ---space
							"0000000" when  to_unsigned(16,6), ---space
							"0000000" when  to_unsigned(17,6),  ---space
							"1000110" when  to_unsigned(18,6),---F
							"0110001" when  to_unsigned(19,6),  ---1
							"0101000" when  to_unsigned(20,6), ---(
							"1001000" when  to_unsigned(21,6),  ---H
							"1111010" when  to_unsigned(22,6),  ---z
							"0101001" when  to_unsigned(23,6),  ---)
							"0111010" when  to_unsigned(24,6),--- :
							"011" & (std_logic_vector(to_unsigned(ff6,4))) when  to_unsigned(25,6),
							"011" & (std_logic_vector(to_unsigned(ff5,4))) when  to_unsigned(26,6),
							"011" & (std_logic_vector(to_unsigned(ff4,4))) when  to_unsigned(27,6),
							"011" & (std_logic_vector(to_unsigned(ff3,4))) when  to_unsigned(28,6),
							"011" & (std_logic_vector(to_unsigned(ff2,4))) when  to_unsigned(29,6),
							"011" & (std_logic_vector(to_unsigned(ff1,4))) when  to_unsigned(30,6),
							"0000000" when  to_unsigned(31,6), --- space
							"0000000" when  to_unsigned(32,6),--- space
							"0000000" when  to_unsigned(33,6),--- space
							"0000000" when  to_unsigned(34,6), --- space
							"0000000" when  to_unsigned(35,6), --- space
							"0000000" when  to_unsigned(36,6), --- space		
							"0000000" when others;   ---
					
				-----------------------------------------------------------------------------------------	
							
				par2_on  <= 
					 '1'  when  pix_y(9  downto  5 ) = 14   and 
						 ( 1<= pix_x(9  downto  4) and pix_x(9  downto  4) <=39 ) and (functionswitch = '0' )else  
					 '0';
					 
					 
				row_addr_p2 <= std_logic_vector(pix_y(4 downto 1)) ;  
				bit_addr_p2 <= std_logic_vector(pix_x(3 downto  1)) ;


				with pix_x(9 downto  4) select
						char_addr_p2 <= 
							"1010110" when  to_unsigned(1,6),  ---V
							"0110010" when  to_unsigned(2,6),  ---2
							"0101000" when  to_unsigned(3,6),  ---(
							"1010110" when  to_unsigned(4,6),  ---V
							"0101001" when  to_unsigned(5,6),  ---)
							"0111010" when  to_unsigned(6,6),  ---:
							"011" & (std_logic_vector(to_unsigned(mm4,4))) when  to_unsigned(7,6), 
							"0101110" when  to_unsigned(8,6),  ---dot
							"011" & (std_logic_vector(to_unsigned(mm3,4))) when  to_unsigned(9,6),  
							"011" & (std_logic_vector(to_unsigned(mm2,4))) when  to_unsigned(10,6),  
							"011" & (std_logic_vector(to_unsigned(mm1,4))) when  to_unsigned(11,6),
							"1001101" when  to_unsigned(12,6), ---M
							"1001001" when  to_unsigned(13,6), ---I
							"1001110" when  to_unsigned(14,6), ---N
							"0000000" when  to_unsigned(15,6),  ---space
							"0000000" when  to_unsigned(16,6),  ---space
							"0000000" when  to_unsigned(17,6), ---space
							"1010110" when  to_unsigned(18,6),  ---V
							"0110011" when  to_unsigned(19,6),  ---3
							"0101000" when  to_unsigned(20,6),  ---(
							"1010110" when  to_unsigned(21,6),  ---V
							"0101001" when  to_unsigned(22,6),  ---)
							"0111010" when  to_unsigned(23,6),  ---:
							"011" & (std_logic_vector(to_unsigned(f4,4))) when  to_unsigned(24,6),
							"0101110"  when  to_unsigned(25,6), ----dot
							"011" & (std_logic_vector(to_unsigned(f3,4))) when  to_unsigned(26,6),
							"011" & (std_logic_vector(to_unsigned(f2,4))) when  to_unsigned(27,6),
							"011" & (std_logic_vector(to_unsigned(f1,4)))  when to_unsigned(28,6),
							"1010010"  when  to_unsigned(29,6), --R
							"1001101"  when  to_unsigned(30,6),--M
							"1010011"  when  to_unsigned(31,6), --S
							"0000000"  when  to_unsigned(32,6), -- space
							"0000000"  when  to_unsigned(33,6), --- space
							"0000000"  when  to_unsigned(34,6), --- space
							"0000000"  when  to_unsigned(35,6), --- space		
							"0000000"  when others;   ---
							
--------------------------------------------------------------------------------------------------------------------------------------------------
				vpar2_on  <= 
					 '1'  when  pix_y(9  downto  7 ) = 1   and 
						 ( 0<= pix_x(9  downto  6) and pix_x(9  downto  6) <=9 )  and (functionswitch = '1' )  else  
					 '0';
					 
					 
				vrow_addr_p2 <= std_logic_vector(pix_y(6 downto 3)) ;  
				vbit_addr_p2 <= std_logic_vector(pix_x(5 downto  3)) ;


				with pix_x(9 downto  6) select
						vchar_addr_p2 <= 
							"011" & (std_logic_vector(to_unsigned(m4,4))) when  to_unsigned(0,4),  ---0
							"0101110"  when  to_unsigned(1,4),  ---.
							"011" & (std_logic_vector(to_unsigned(m3,4))) when  to_unsigned(2,4),  ---0
							"011" & (std_logic_vector(to_unsigned(m2,4))) when  to_unsigned(3,4),  ---0
							"011" & (std_logic_vector(to_unsigned(m1,4))) when  to_unsigned(4,4),  ---0
							"1010110" when   to_unsigned(5,4),  ---V
							"1001101" when  to_unsigned(6,4),   ---M
							"1000001" when  to_unsigned(7,4),   ---A
							"1011000" when  to_unsigned(8,4),   ---X
			            "0000000" when others;  
							
				-------------------------------------------------------------------------------------
				vpar3_on  <= 
					 '1'  when  pix_y(9  downto  7 ) = 2   and 
						 ( 0<= pix_x(9  downto  6) and pix_x(9  downto  6) <=9 )  and (functionswitch = '1' )  else  
					 '0';
					 
					 
				vrow_addr_p3 <= std_logic_vector(pix_y(6 downto 3)) ;  
				vbit_addr_p3 <= std_logic_vector(pix_x(5 downto  3)) ;


				with pix_x(9 downto  6) select
						vchar_addr_p3 <= 
							"011" & (std_logic_vector(to_unsigned(mm4,4))) when  to_unsigned(0,4),  ---0
							"0101110"  when  to_unsigned(1,4),  ---.
							"011" & (std_logic_vector(to_unsigned(mm3,4))) when  to_unsigned(2,4),  ---0
							"011" & (std_logic_vector(to_unsigned(mm2,4))) when  to_unsigned(3,4),  ---0
							"011" & (std_logic_vector(to_unsigned(mm1,4))) when  to_unsigned(4,4),  ---0
							"1010110" when   to_unsigned(5,4),  ---V
							"1001101" when  to_unsigned(6,4),   ---M
							"1001001" when  to_unsigned(7,4),   ---I
							"1001110" when  to_unsigned(8,4),   ---N
			            "0000000" when others;  
			--------------------------------------------------------------------------------------------
			vpar4_on  <= 
					 '1'  when  pix_y(9  downto  7 ) = 3   and 
						 ( 0<= pix_x(9  downto  6) and pix_x(9  downto  6) <=9 )  and (functionswitch = '1' )  else  
					 '0';
					 
					 
				vrow_addr_p4 <= std_logic_vector(pix_y(6 downto 3)) ;  
				vbit_addr_p4 <= std_logic_vector(pix_x(5 downto  3)) ;


				with pix_x(9 downto  6) select
						vchar_addr_p4 <= 
							"011" & (std_logic_vector(to_unsigned(f4,4))) when  to_unsigned(0,4),  ---0
							"0101110"  when  to_unsigned(1,4),  ---.
							"011" & (std_logic_vector(to_unsigned(f3,4))) when  to_unsigned(2,4),  ---0
							"011" & (std_logic_vector(to_unsigned(f2,4))) when  to_unsigned(3,4),  ---0
							"011" & (std_logic_vector(to_unsigned(f1,4))) when  to_unsigned(4,4),  ---0
							"1010110" when  to_unsigned(5,4),  ---V
							"1010010" when  to_unsigned(6,4),   ---R
							"1001101" when  to_unsigned(7,4),   ---M
							"1010011" when  to_unsigned(8,4),   ---S
			            "0000000" when others;  
			
			
-----------------------------------------------------------------------------------------------------------------------------------------

					-- rgb multiplexing circuit  
					process(text_on,par_on ,par2_on,pix_x,pix_y,font_bit,char_addr_t,char_addr_p,char_addr_p2,row_addr_t,
								row_addr_p,row_addr_p2,bit_addr_t,bit_addr_p,bit_addr_p2,
								vtext_on , vpar2_on,vpar3_on,vpar4_on ,vchar_addr_p2 ,vchar_addr_t,vrow_addr_p2,vbit_addr_p2,
								vrow_addr_t, vbit_addr_t, vchar_addr_p3, vrow_addr_p3, vbit_addr_p3, vchar_addr_p4, vrow_addr_p4, vbit_addr_p4 )  
								
								
					begin
					
						 char_addr <= (others => '0');
						 row_addr  <= (others => '0');
						 bit_addr  <= (others => '0');
						 
						 paron <= '0';
						 par2on <= '0';
						 vtexton <= '0';
						 vpar2on <= '0';
						 vpar3on <= '0';
						 vpar4on <= '0';

						 if text_on = '1' then  
						 char_addr <= char_addr_t ;
						 row_addr <= row_addr_t ;
						 bit_addr <= bit_addr_t;
							 if font_bit = '1' then 
								 texton <= '1';
							else
							  texton <= '0';
							 end if;		 		 
					elsif par_on = '1' then  
						 char_addr <= char_addr_p ;
						 row_addr <= row_addr_p ;
						 bit_addr <= bit_addr_p;
							 if font_bit = '1' then 
								 paron <= '1';
							 else
								 paron <= '0';
							 end if;
					elsif par2_on = '1' then  
						 char_addr <= char_addr_p2 ;
						 row_addr <= row_addr_p2 ;
						 bit_addr <= bit_addr_p2;
							 if font_bit = '1' then 
								 par2on <= '1';
							 else
								 par2on <= '0';
							 end if;
-----------------------------------------------------------------------------------------------------------------------
					elsif vpar2_on = '1' then  -----------------------------------------------------------
						 char_addr <= vchar_addr_p2 ;
						 row_addr <= vrow_addr_p2 ;
						 bit_addr <= vbit_addr_p2;
							 if font_bit = '1' then 
								 vpar2on <= '1';
							 else
								 vpar2on <= '0';
							 end if;
							 
					elsif vpar3_on = '1' then  -----------------------------------------------------------
						 char_addr <= vchar_addr_p3 ;
						 row_addr <= vrow_addr_p3 ;
						 bit_addr <= vbit_addr_p3;
							 if font_bit = '1' then 
								 vpar3on <= '1';
							 else
								 vpar3on <= '0';
							 end if;
							 
					elsif vpar4_on = '1' then  -----------------------------------------------------------
						 char_addr <= vchar_addr_p4 ;
						 row_addr <= vrow_addr_p4 ;
						 bit_addr <= vbit_addr_p4;
							 if font_bit = '1' then 
								 vpar4on <= '1';
							 else
								 vpar4on <= '0';
							 end if;
			-----------------------------------
              elsif vtext_on = '1' then   -------------------------------------------------------
						 char_addr <= vchar_addr_t ;
						 row_addr <= vrow_addr_t ;
						 bit_addr <= vbit_addr_t;
							 if font_bit = '1' then 
								 vtexton <= '1';
							else
							  vtexton <= '0';
							 end if;		
-------------------------------------------------------------------------------------------------------------------------------------		 
							 
					else
--						 char_addr <= (others => '0');
--						 row_addr  <= (others => '0');
--						 bit_addr  <= (others => '0');
--						 vtexton   <= (others => '0');
--
--						 paron <= '0';
--						 par2on <= '0';
--						 vtexton <= '0';
--						 vpar2on <= '0';
--						 vpar3on <= '0';
--						 vpar4on <= '0';
						
						
					end if;		  		  
					end process;  
					
				rom_addr <= char_addr & row_addr;  
				font_bit <= font_word(to_integer(unsigned(not bit_addr)));  

				
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--     
--						 --------------------------------------------
--						 --AN FPGA BASED DIGITAL OSCILLOSCOPE
--						 -------------------------------------------
--						  
--						  text_on  <= 
--							 '1'  when  pix_y(9  downto  5 ) = 0   and 
--								 (3<= pix_x(9  downto  4) and pix_x(9  downto  4) <=37) else  
--							 '0';
--							 
--						 row_addr_t <= std_logic_vector(pix_y(4 downto 1)) ;  
--						 bit_addr_t <= std_logic_vector(pix_x(3 downto  1)) ;
--						 
--						 with pix_x(9 downto  4) select
--								char_addr_t <= 
--									"1000001" when  "000001",  ---A
--									"1001110" when  "000010",  ---N
--									"0000000" when  "000011",  ---space
--									"1000110" when  "000100",  ---F
--									"1010000" when  "000101",  ---P
--									"1000111" when  "000110",  ---G
--									"1000001" when  "000111",  ---A
--									"0000000" when  "001000",  ---space
--									"1000010" when  "001001",  --- B
--									"1000001" when  "001010",  --- A
--									"1010011" when  "001011",  --- S
--									"1000101" when  "001100",  --- E
--									"1000100" when  "001101",  --- D
--									"0000000" when  "001110",  --- space
--									"1000100" when  "001111",  --- D
--									"1001001" when  "010000",  --- I
--									"1000111" when  "010001",  --- G
--									"1001001" when  "010010",  --- I
--									"1010100" when  "010011",  --- T
--									"1000001" when  "010100",  --- A
--									"1001100" when  "010101",  --- L
--									"0000000" when  "010110",  --- space
--									to_stdlogicvector(x"56")(6 downto 0) when  "010111",  --- V
--									to_stdlogicvector(x"4f")(6 downto 0) when  "011000",  --- O
--									to_stdlogicvector(x"4c")(6 downto 0) when  "011001",  --- L
--									to_stdlogicvector(x"54")(6 downto 0) when  "011010",  --- T
--									to_stdlogicvector(x"4d")(6 downto 0) when  "011011",  --- M
--									to_stdlogicvector(x"45")(6 downto 0) when  "011100",  --- E
--									to_stdlogicvector(x"54")(6 downto 0) when  "011101",  --- T
--									to_stdlogicvector(x"45")(6 downto 0) when  "011110",  --- E
--									to_stdlogicvector(x"52")(6 downto 0) when  "011111",  --- R
--									to_stdlogicvector(x"00")(6 downto 0) when others;   ---
--								
--						-------------------------------------------------
--						--PARAMETER DISPLAY
--						------------------------------------------------
--						 
--						par_on  <= 
--							 '1'  when  pix_y(9  downto  5 ) = 1   and 
--								 ( 12<= pix_x(9  downto  4) and pix_x(9  downto  4) <=23) else  
--							 '0';
--							 
--						row_addr_p <= std_logic_vector(pix_y(4 downto 1)) ;  
--						bit_addr_p <= std_logic_vector(pix_x(3 downto  1)) ;
--
--
--						with pix_x(9 downto  4) select
--								char_addr_p <= 
--									to_stdlogicvector(x"28")(6 downto 0) when  to_unsigned(12,6),  ---(
--									to_stdlogicvector(x"41")(6 downto 0) when  to_unsigned(13,6),  ---A
--									to_stdlogicvector(x"55")(6 downto 0) when  to_unsigned(14,6),  ---U
--									to_stdlogicvector(x"54")(6 downto 0) when  to_unsigned(15,6),  ---T
--									to_stdlogicvector(x"4f")(6 downto 0) when  to_unsigned(16,6),  ---O
--									to_stdlogicvector(x"00")(6 downto 0) when  to_unsigned(17,6),  ----
--									to_stdlogicvector(x"52")(6 downto 0) when  to_unsigned(18,6),  ---R
--									to_stdlogicvector(x"41")(6 downto 0) when  to_unsigned(19,6),  ---A
--									to_stdlogicvector(x"4e")(6 downto 0) when  to_unsigned(20,6),  ---N
--									to_stdlogicvector(x"47")(6 downto 0) when  to_unsigned(21,6),  ---G
--									to_stdlogicvector(x"45")(6 downto 0) when  to_unsigned(22,6),  ---E
--									to_stdlogicvector(x"29")(6 downto 0) when  to_unsigned(23,6),  ---)
--									to_stdlogicvector(x"56")(6 downto 0) when others;   ---
--							
--						-----------------------------------------------------------------------------------------	
--									
--						par2_on  <= 
--							 '1'  when  pix_y(9  downto  7 ) = 2   and 
--								 ( 1<= pix_x(9  downto  6) and pix_x(9  downto  6) <=8 ) else  
--							 '0';
--							 
--							 
--						row_addr_p2 <= std_logic_vector(pix_y(6 downto 3)) ;  
--						bit_addr_p2 <= std_logic_vector(pix_x(5 downto  3)) ;
--
--
--						with pix_x(9 downto  6) select
--								char_addr_p2 <= 
--									"011" & (std_logic_vector(to_unsigned(m5,4))) when  to_unsigned(1,4),  ---0
--									to_stdlogicvector(x"2e")(6 downto 0) when  to_unsigned(2,4),  ---.
--									"011" & (std_logic_vector(to_unsigned(m4,4))) when  to_unsigned(3,4),  ---0
--									"011" & (std_logic_vector(to_unsigned(m3,4))) when  to_unsigned(4,4),  ---0
--									"011" & (std_logic_vector(to_unsigned(m2,4))) when  to_unsigned(5,4),  ---0
--									"011" & (std_logic_vector(to_unsigned(m1,4))) when  to_unsigned(6,4),  ---0
--									to_stdlogicvector(x"56")(6 downto 0) when  to_unsigned(7,4),  ---V
--									to_stdlogicvector(x"56")(6 downto 0) when  to_unsigned(8,4),  ---space
--									to_stdlogicvector(x"00")(6 downto 0) when  others;   ---
--									
--							-- rgb multiplexing circuit  
--							process(text_on,par_on ,par2_on,pix_x,pix_y,font_bit,char_addr_t,char_addr_p,char_addr_p2,row_addr_t,
--										row_addr_p,row_addr_p2,bit_addr_t,bit_addr_p,bit_addr_p2)  
--							begin
--							
--							 if text_on = '1' then  
--								 char_addr <= char_addr_t ;
--								 row_addr <= row_addr_t ;
--								 bit_addr <= bit_addr_t;
--									 if font_bit = '1' then 
--										 texton <= '1';
--									else
--									  texton <= '0';
--									 end if;		 		 
--							elsif par_on = '1' then  
--								 char_addr <= char_addr_p ;
--								 row_addr <= row_addr_p ;
--								 bit_addr <= bit_addr_p;
--									 if font_bit = '1' then 
--										 paron <= '1';
--									 else
--										 paron <= '0';
--									 end if;
--							elsif par2_on = '1' then  
--									 char_addr <= char_addr_p2 ;
--								 row_addr <= row_addr_p2 ;
--								 bit_addr <= bit_addr_p2;
--									 if font_bit = '1' then 
--										 par2on <= '1';
--									 else
--										 par2on <= '0';
--									 end if;
--							end if;		  		  
--							end process;  
--							
--						rom_addr <= char_addr & row_addr;  
--						font_bit <= font_word(to_integer(unsigned(not bit_addr)));  

 
end arch;  



