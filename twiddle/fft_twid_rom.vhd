--------------------------------------------------------------------------
-- FILE        : FFT_TWID_ROM.VHD
-- VERSION     : 1.00
-- DATE        : 01-06-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Entity and architecture fft twiddle factor ROM memory
--
--------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

LIBRARY work;
USE work.complex_pkg.all;

ENTITY fft_twid_rom IS
	GENERIC (
		POINTS:		natural := 256
	);
	PORT (
		-- Clock signal
		clk: 		IN std_logic;
		address:	IN	natural RANGE 0 TO POINTS / 4 - 1;

		-- Data signals
		r_data: 	OUT	complex_2
	);
END fft_twid_rom;

ARCHITECTURE behaviour OF fft_twid_rom IS
	TYPE fft_regs IS ARRAY (0 TO 63) OF complex_2;

	CONSTANT data: fft_regs := (
     0  =>  ("01000000000000000000000000", "00000000000000000000000000") ,
     1  =>  ("00111111111110110001000011", "11111110011011011110101011") ,
     2  =>  ("00111111111011000100001111", "11111100110111000001001110") ,
     3  =>  ("00111111110100111001101101", "11111011010010101011100000") ,
     4  =>  ("00111111101100010001101101", "11111001101110100001011010") ,
     5  =>  ("00111111100001001100100011", "11111000001010100110110010") ,
     6  =>  ("00111111010011101010101011", "11110110100110111111100000") ,
     7  =>  ("00111111000011101100100111", "11110101000011101111011000") ,
     8  =>  ("00111110110001010010111110", "11110011100000111010010000") ,
     9  =>  ("00111110011100011110011101", "11110001111110100011111100") ,
    10  =>  ("00111110000101001111110111", "11110000011100110000001110") ,
    11  =>  ("00111101101011101000000111", "11101110111011100010110111") ,
    12  =>  ("00111101001111101000001010", "11101101011010111111101000") ,
    13  =>  ("00111100110001010001000111", "11101011111011001010001110") ,
    14  =>  ("00111100010000100100001000", "11101010011100000110010111") ,
    15  =>  ("00111011101101100010011101", "11101000111101110111101100") ,
    16  =>  ("00111011001000001101011110", "11100111100000100001110110") ,
    17  =>  ("00111010100000100110100110", "11100110000100001000011011") ,
    18  =>  ("00111001110110101111010111", "11100100101000101111000000") ,
    19  =>  ("00111001001010101001011001", "11100011001110011001000110") ,
    20  =>  ("00111000011100010110010111", "11100001110101001010001100") ,
    21  =>  ("00110111101011111000000101", "11100000011101000101101101") ,
    22  =>  ("00110110111001010000011010", "11011111000110001111000100") ,
    23  =>  ("00110110000100100001010010", "11011101110000101001100110") ,
    24  =>  ("00110101001101101100110001", "11011100011100011000100111") ,
    25  =>  ("00110100010100110100111101", "11011011001001011111010110") ,
    26  =>  ("00110011011001111100000010", "11011001111000000001000001") ,
    27  =>  ("00110010011101000100010010", "11011000101000000000101111") ,
    28  =>  ("00110001011110010000000011", "11010111011001100001100111") ,
    29  =>  ("00110000011101100001110000", "11010110001100100110101011") ,
    30  =>  ("00101111011010111011111001", "11010101000001010010110111") ,
    31  =>  ("00101110010110100001000001", "11010011110111101001000110") ,
    32  =>  ("00101101010000010011110011", "11010010101111101100001101") ,
    33  =>  ("00101100001000010110111010", "11010001101001011110111111") ,
    34  =>  ("00101010111110101101001001", "11010000100101000100000111") ,
    35  =>  ("00101001110011011001010101", "11001111100010011110010000") ,
    36  =>  ("00101000100110011110011001", "11001110100001101111111101") ,
    37  =>  ("00100111010111111111010001", "11001101100010111011101110") ,
    38  =>  ("00100110000111111110111111", "11001100100110000011111110") ,
    39  =>  ("00100100110110100000101010", "11001011101011001011000011") ,
    40  =>  ("00100011100011100111011001", "11001010110010010011001111") ,
    41  =>  ("00100010001111010110011010", "11001001111011011110101110") ,
    42  =>  ("00100000111001110000111100", "11001001000110101111100110") ,
    43  =>  ("00011111100010111010010011", "11001000010100000111111011") ,
    44  =>  ("00011110001010110101110100", "11000111100011101001101001") ,
    45  =>  ("00011100110001100110111010", "11000110110101010110100111") ,
    46  =>  ("00011011010111010001000000", "11000110001001010000101001") ,
    47  =>  ("00011001111011110111100101", "11000101011111011001011010") ,
    48  =>  ("00011000011111011110001010", "11000100110111110010100010") ,
    49  =>  ("00010111000010001000010100", "11000100010010011101100011") ,
    50  =>  ("00010101100011111001101001", "11000011101111011011111000") ,
    51  =>  ("00010100000100110101110010", "11000011001110101110111001") ,
    52  =>  ("00010010100101000000011000", "11000010110000010111110110") ,
    53  =>  ("00010001000100011101001001", "11000010010100010111111001") ,
    54  =>  ("00001111100011001111110010", "11000001111010110000001001") ,
    55  =>  ("00001110000001011100000100", "11000001100011100001100011") ,
    56  =>  ("00001100011111000101110000", "11000001001110101101000010") ,
    57  =>  ("00001010111100010000101000", "11000000111100010011011001") ,
    58  =>  ("00001001011001000000100000", "11000000101100010101010101") ,
    59  =>  ("00000111110101011001001110", "11000000011110110011011101") ,
    60  =>  ("00000110010001011110100110", "11000000010011101110010011") ,
    61  =>  ("00000100101101010100100000", "11000000001011000110010011") ,
    62  =>  ("00000011001000111110110010", "11000000000100111011110001") ,
    63  =>  ("00000001100100100001010101", "11000000000001001110111101")
	);
BEGIN
	
	PROCESS(clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			r_data <= data(address);
		END IF;
	END PROCESS;

END behaviour;