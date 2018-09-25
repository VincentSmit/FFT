--------------------------------------------------------------------------
-- FILE        : FFT_DATA_MEM.VHD
-- VERSION     : 1.00
-- DATE        : 01-06-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Entity and architecture fft data memory
--
--------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

LIBRARY work;
USE work.complex_pkg.all;

ENTITY fft_data_mem IS
	GENERIC (
		POINTS:		natural := 256
	);
	PORT (
		-- Clock and reset signals
		clk: 		IN	std_logic;

		-- Write enable
		w_en:		IN std_logic;
		
		-- Address signals
		r_addr:	IN	natural RANGE 0 TO POINTS - 1;
		w_addr:	IN 	natural RANGE 0 TO POINTS - 1;
		
		-- Data signals
		w_data:	IN	complex;
		r_data:	OUT	complex
	);
END fft_data_mem;

ARCHITECTURE behaviour OF fft_data_mem IS
	TYPE fft_regs IS ARRAY (0 TO POINTS - 1) OF complex;
	SIGNAL data: fft_regs := (OTHERS => ((OTHERS => '0'),(OTHERS => '0')));

	BEGIN
	
	PROCESS(clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (w_en = '1') THEN
				data(w_addr) <= w_data;
			END IF;
			r_data <= data(r_addr);
		END IF;
	END PROCESS;
END behaviour;