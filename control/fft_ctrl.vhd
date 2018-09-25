--------------------------------------------------------------------------
-- FILE        : FFT_CTRL.VHD
-- VERSION     : 1.00
-- DATE        : 09-06-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Entity and architecture fft controller
--
--------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

LIBRARY work;
USE work.complex_pkg.all;

ENTITY fft_ctrl IS
	GENERIC (
		POINTS:			natural	:= 256
	);
	PORT (
		-- Clock and reset signals
		clk:				IN	std_logic;
		reset:			IN	std_logic;

    next_val:   IN  std_logic;
		r_en:				IN 	std_logic;
		w_en:				IN	std_logic;

		bufly_sel:	OUT	std_logic;
		-- Data memory control signals
		d_w_en: 		OUT std_logic;
		d_r_addr:		OUT natural RANGE 0 TO POINTS - 1;
		d_w_addr:		OUT natural RANGE 0 TO POINTS - 1;

		rom_addr:		OUT natural RANGE 0 TO POINTS - 1;	

		-- Twiddle factor memory control signals
		t_mem_sel:	OUT	std_logic;

		-- MUX signals
		d_w_mux:		OUT std_logic_vector(1 DOWNTO 0);	-- RAM: write originates from BFY out(00) or from outside of system (01) or from self (10)
		d_r_mux:		OUT std_logic_vector(1 DOWNTO 0)	-- RAM: read data transported to BFY mux(00) or to outside of system (01)
	);
END fft_ctrl;

ARCHITECTURE behaviour OF fft_ctrl IS
	-- ADDRESS GENERATOR
	COMPONENT fft_address_gen
		PORT (
			clk:			IN 	std_logic;
			reset:		IN	std_logic;
			chip_sel: IN 	std_logic;
			ram_addr:	OUT natural RANGE 0 TO 255;
			rom_addr: OUT natural RANGE 0 TO 255
		);
	END COMPONENT;

	-- ADDRESS BUFFER
	COMPONENT fft_address_buffer
		PORT (
			clk:			IN 	std_logic;
			reset:		IN	std_logic;
			addr_in:	IN	natural RANGE 0 TO POINTS - 1;
			addr_out: OUT natural RANGE 0 TO POINTS - 1
		);
	END COMPONENT;

	TYPE fft_stages IS (
			DATA_REC,
			CALC,
			UNSCRAMBLE,
			UNSCRAMBLE_1,
			DATA_OUT,
			FINISHED
	);

	SIGNAL state: fft_stages;
	SIGNAL next_state: fft_stages;
	SIGNAL ram_r_addr: natural RANGE 0 TO POINTS - 1;
	SIGNAL ram_w_addr: natural RANGE 0 TO POINTS - 1;	
	SIGNAL rom_r_addr: natural RANGE 0 TO POINTS - 1;
	SIGNAL chip_sel: std_logic;
BEGIN

	-- ADDRESS GENERATOR
	addr_gen: fft_address_gen
		PORT MAP (
			clk 			=> clk,
			reset 		=> reset,
			chip_sel 	=> chip_sel,
			ram_addr 	=> ram_r_addr,
			rom_addr 	=> rom_r_addr
		);

	-- ADDRESS BUFFER
	addr_buf: fft_address_buffer
		PORT MAP (
			clk				=> clk,
			reset			=> reset,
			addr_in		=> ram_r_addr,
			addr_out	=> ram_w_addr
		);

	PROCESS (clk, reset)
		VARIABLE address: natural RANGE 0 TO POINTS;
		VARIABLE rev_address: natural RANGE 0 TO POINTS;
		VARIABLE tmp: unsigned(7 DOWNTO 0);
	BEGIN
		IF (reset = '0') THEN
			next_state <= DATA_REC;
			address := 0;
			bufly_sel <= '0';
			chip_sel <= '0';
			t_mem_sel <= '0';
			bufly_sel <= '0';
		ELSIF (rising_edge(clk)) THEN
			d_w_en <= '0';
			d_w_mux <= "00";
			d_r_mux <= "00";
			CASE state IS	
				WHEN DATA_REC =>
					d_w_mux <= "01";
					IF (next_val = '1') THEN
						d_w_en <= '1';
						d_w_addr <= address;
						address := address + 1;
						IF (address = 256) THEN
							next_state <= CALC;
							address := 0;
						END IF;
					END IF;
				WHEN CALC =>
					d_w_en <= '1'; 
					chip_sel <= '1';
					t_mem_sel <= '1';
					d_w_addr <= ram_w_addr;
					d_r_addr <= ram_r_addr;
					rom_addr <= rom_r_addr;
					IF (ram_w_addr = 255) THEN
						address := address + 1;
						IF (address = 4) THEN
							next_state <= UNSCRAMBLE;
							address := 0;
							tmp := (OTHERS => '0');
						END IF;
					END IF;
					IF (ram_r_addr > 0 or address > 0) THEN
						bufly_sel <= '1';
					END IF;
				WHEN UNSCRAMBLE =>
					chip_sel <= '0';
					t_mem_sel <= '0';
					d_r_mux <= "10";
					d_w_mux <= "10";	
					
					tmp:= to_unsigned(address,8);
					rev_address := to_integer(tmp(1 DOWNTO 0) & tmp(3 DOWNTO 2) & tmp(5 DOWNTO 4) & tmp(7 DOWNTO 6));

					d_r_addr <= rev_address;
					d_w_addr <= rev_address;

					IF ( rev_address > address) THEN	
						d_w_en <= '1';
					END IF;
					address := address + 1;
					next_state <= UNSCRAMBLE_1;
					IF(address = 256) THEN	
						next_state <= DATA_OUT; 
						address := 0;
						d_r_addr <= address;
					END IF;
				WHEN UNSCRAMBLE_1 =>
					d_r_addr <= address;
					d_w_addr <= address - 1;
					d_r_mux <= "10";
					d_w_mux <= "10";
					
					next_state <= UNSCRAMBLE;
					IF ( rev_address > address) THEN	
						d_w_en <= '1';
					END IF;	
				WHEN DATA_OUT =>
					d_r_mux <= "01";
					d_r_addr <= address;
					IF (next_val = '1') THEN
						address := address + 1;
						IF (address = 256) THEN
							next_state <= FINISHED;
							address := 0;
						END IF;
					END IF;
				WHEN OTHERS => 
					next_state <= state;
			END CASE;
		END IF;
	END PROCESS;

	state <= next_state;

END behaviour;