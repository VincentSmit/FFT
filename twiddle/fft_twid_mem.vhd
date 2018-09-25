
--------------------------------------------------------------------------
-- FILE        : FFT_TWID_MEM.VHD
-- VERSION     : 1.00
-- DATE        : 01-06-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Entity and architecture fft twiddle factor memory
--
--------------------------------------------------------------------------


-- TODO get all twiddlefactors in binary representation
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

LIBRARY work;
USE work.complex_pkg.all;
USE work.fixed_pkg.all;

ENTITY fft_twid_mem IS
	GENERIC (
		POINTS:		natural := 256
	);
	PORT (
		-- Clock and reset signals
		clk: 			IN	std_logic;
		reset: 		IN 	std_logic;

		-- Control signals
		mem_sel:	IN	std_logic;
		r_addr:	IN	natural RANGE 0 TO POINTS - 1;

		-- Data signals
		r_data: 	OUT	complex
	);
END fft_twid_mem;

ARCHITECTURE behaviour OF fft_twid_mem IS
	COMPONENT fft_twid_rom
		PORT (
			-- Clock signal
			clk: IN std_logic;
			address:	IN	natural RANGE 0 TO POINTS / 4 - 1;

			-- Data signals
			r_data: 	OUT	complex_2
		);
	END COMPONENT;

	SIGNAL n_r_data:		complex;
	SIGNAL rom_r_data:	complex_2;
	SIGNAL rom_address: natural RANGE 0 TO POINTS / 4 - 1;

	SIGNAL calc_delay: std_logic_vector(3 DOWNTO 0);
BEGIN
	
	PROCESS(clk,reset,mem_sel)
		VARIABLE tmp: std_logic_vector(7 DOWNTO 0);
		VARIABLE r,i: sfixed(7 DOWNTO -24);
	BEGIN
		IF (reset = '0') THEN
			tmp					:= (OTHERS => '0');
			calc_delay 	<= (OTHERS => '0');
			rom_address <= 0;
			n_r_data		<= ((OTHERS => '0'),(OTHERS => '0'));
			r						:= (OTHERS => '0');
			i						:= (OTHERS => '0');
		ELSIF (rising_edge(clk) and mem_sel = '1') THEN
			tmp 				:= std_logic_vector(to_unsigned(r_addr, 8));
			rom_address <= to_integer(unsigned(tmp(5 DOWNTO 0)));

			r := resize(rom_r_data.r,7,-24);
			i := resize(rom_r_data.i,7,-24);
			CASE calc_delay(3 DOWNTO 2) IS
				WHEN "11" =>
						r := resize(rom_r_data.i * (-1),7,-24);
						i := resize(rom_r_data.r,7,-24);
				WHEN "10" =>
						r := resize(rom_r_data.r * (-1),7,-24);
						i := resize(rom_r_data.i * (-1),7,-24);
				WHEN "01" =>
						r := resize(rom_r_data.i,7,-24);
						i := resize(rom_r_data.r * (-1),7,-24);
				WHEN "00" =>
						r := resize(rom_r_data.r,7,-24);
						i := resize(rom_r_data.i,7,-24);
				WHEN OTHERS => 
						r := resize(rom_r_data.r,7,-24);
						i := resize(rom_r_data.i,7,-24);
			END CASE;
			n_r_data <= (r,i);

			calc_delay	<= calc_delay(1 DOWNTO 0) & tmp(7 DOWNTO 6);
		END IF;
	END PROCESS;

	r_data <= n_r_data;

	rom: fft_twid_rom 
		PORT MAP (
			clk => clk,
			address => rom_address,
			r_data => rom_r_data
		);
		
END behaviour;