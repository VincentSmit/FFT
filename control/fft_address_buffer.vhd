--------------------------------------------------------------------------
-- FILE        : FFT_ADDRESS_BUFFER.VHD
-- VERSION     : 1.00
-- DATE        : 15-06-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Entity and architecture for fft address buffer
--
--------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std;

ENTITY fft_address_buffer IS
	GENERIC (
		POINTS: 		natural := 256;
		BUF_WIDTH:	natural := 12
	);
	PORT (
		clk:			IN	std_logic;
		reset:		IN	std_logic;
		addr_in:	IN	natural RANGE 0 TO POINTS - 1;
		addr_out:	OUT natural RANGE 0 TO POINTS - 1
	);
END fft_address_buffer;

ARCHITECTURE behaviour OF fft_address_buffer IS
	TYPE address_buffer IS ARRAY (0 TO BUF_WIDTH - 1) OF natural RANGE 0 TO POINTS - 1;
	
	SIGNAL address_reg: address_buffer;
BEGIN
	PROCESS (clk,reset) 
	BEGIN
		IF (reset = '0') THEN
			address_reg <= (OTHERS => 0);
		ElSIF (rising_edge(clk)) THEN
			addr_out 		<= address_reg(BUF_WIDTH - 1);
			address_reg <= addr_in & address_reg(0 TO BUF_WIDTH - 2);
		END IF;
	END PROCESS;
END behaviour;
