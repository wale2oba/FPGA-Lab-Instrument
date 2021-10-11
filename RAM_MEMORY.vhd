Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;


ENTITY RAM_MEMORY IS
		GENERIC (
		M : natural := 9;
		N : natural := 12
		);
		PORT (
		clk : in std_logic;
		addr : in std_logic_vector(m-1 downto 0);
		wr : in std_logic;
		d : in std_logic_vector (n-1 downto 0);
		q : out std_logic_vector (n-1 downto 0)
		);
END RAM_MEMORY;



Architecture dualport of RAM_MEMORY is
Type sramdata is array (0 to 2**m-1) of Std_logic_vector (n-1 downto 0);
Signal memory : sramdata;
Begin
	Process (clk ) is
	Begin
			If rising_edge(clk) then
			  If wr = '1' then
			    Memory(to_integer(unsigned(addr))) <= d;
			  Else
		       Q <= memory(to_integer(unsigned(addr)));
		     End if;
		   End if;
    End process;
End  dualport;