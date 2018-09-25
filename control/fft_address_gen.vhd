--------------------------------------------------------------------------
-- FILE        : FFT_ADDRESS_GEN.VHD
-- VERSION     : 1.00
-- DATE        : 13-06-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Entity and architecture fft address generator
--
--------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

LIBRARY work;
USE work.complex_pkg.all;

ENTITY fft_address_gen IS
	GENERIC (
		RAM_DELAY: natural := 2;
		POINTS: natural := 256
	);
	PORT (
		clk:			IN 	std_logic;
		reset:		IN	std_logic;

		chip_sel: IN 	std_logic;

		ram_addr:	OUT natural RANGE 0 TO POINTS - 1;
		rom_addr: OUT natural RANGE 0 TO POINTS - 1
	);
END fft_address_gen;

ARCHITECTURE behaviour OF fft_address_gen IS
	TYPE ram_regs IS ARRAY (0 TO RAM_DELAY - 1) OF unsigned(7 DOWNTO 0);
	SIGNAL ram_reg: ram_regs;
	SIGNAL n_ram:	unsigned(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL rom:	unsigned(7 DOWNTO 0) := (OTHERS => '0');
BEGIN

	PROCESS(clk,reset,chip_sel)
		VARIABLE selector: unsigned(9 DOWNTO 0); -- 9-8 stage; 7-2 group&bfly; 1-0 bfly input
		VARIABLE ram:	unsigned(7 DOWNTO 0);
	BEGIN
		IF (reset = '0') THEN
			selector 	:= (OTHERS => '0');
			ram_reg 	<= (OTHERS => (OTHERS => '0'));
			n_ram 		<= (OTHERS => '0');
			ram 			:= (OTHERS => '0');
			rom 			<= (OTHERS => '0');
		ELSIF (chip_sel = '1' and rising_edge(clk)) THEN
			CASE selector(9 DOWNTO 8) IS
				WHEN "00" =>
					ram := selector(1 DOWNTO 0) & selector(7 DOWNTO 2);
					rom <= selector(1 DOWNTO 0) * selector(7 DOWNTO 2);
				WHEN "01" =>
					ram := selector(7 DOWNTO 6) & selector(1 DOWNTO 0) & selector(5 DOWNTO 2);
					rom <= (selector(1 DOWNTO 0) * selector(5 DOWNTO 2)) & "00";
				WHEN "10" =>
					ram := selector(7 DOWNTO 4) & selector(1 DOWNTO 0) & selector(3 DOWNTO 2);
					rom <= (selector(1 DOWNTO 0) * selector(3 DOWNTO 2)) & "0000";
				WHEN "11" =>
					ram := selector(7 DOWNTO 0);
					rom <= (OTHERS => '0');
				WHEN OTHERS => 
					-- SOME ERROR?
			END CASE;
			selector := selector + 1;
			n_ram 	<= ram_reg(RAM_DELAY-1);
			ram_reg <= ram & ram_reg(0 TO RAM_DELAY - 2);
		END IF;
	END PROCESS;

	ram_addr <= to_integer(n_ram);
	rom_addr <= to_integer(rom);

END behaviour;