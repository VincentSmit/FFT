--------------------------------------------------------------------------
-- FILE        : FFT_TOPENTITY.VHD
-- VERSION     : 1.00
-- DATE        : 16-05-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Top entity and architecture for fft operation
--
--------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.complex_pkg.all;

ENTITY fft_topentity IS
	GENERIC ( -- NOT REALY GENERIC...
		POINTS: 	natural := 256; 
		RADIX: 		natural := 4;
		STAGES: 	natural := 4
	);
	PORT (
		clk: 			IN 	std_logic;
		reset:		IN	std_logic;
    sys_next: IN  std_logic;
		sys_r_en:	IN	std_logic;
		sys_w_en: IN 	std_logic;
		w_data:		IN	complex; 	-- ONE COMPLEX NUMBER AT A TIME
		r_data:		OUT	complex		-- ONE COMPLEX NUMBER AT A TIME
	);
END fft_topentity;

ARCHITECTURE behaviour OF fft_topentity IS
	-- CONTROL
	COMPONENT fft_ctrl
		PORT (
			clk:				IN 	std_logic;
			reset:			IN 	std_logic;
      next_val:   IN  std_logic;
			w_en:				IN	std_logic;
			r_en:				IN 	std_logic;
			d_w_en: 		OUT std_logic;
			bufly_sel:	OUT std_logic;
			d_r_addr:		OUT natural RANGE 0 TO POINTS - 1;
			d_w_addr:		OUT natural RANGE 0 TO POINTS - 1;
			rom_addr: 	OUT natural RANGE 0 TO POINTS - 1;
			t_mem_sel:	OUT	std_logic;
			d_w_mux:		OUT	std_logic_vector(1 DOWNTO 0);
			d_r_mux:		OUT	std_logic_vector(1 DOWNTO 0)
		);
	END COMPONENT;

	-- TWID_MEM
	COMPONENT fft_twid_mem
		PORT (
			clk: 			IN	std_logic;
			reset: 		IN 	std_logic;
			mem_sel:	IN	std_logic;
			r_addr:		IN	natural RANGE 0 TO POINTS - 1;
			r_data: 	OUT	complex			
		);
	END COMPONENT;

	-- DATA_MEM
	COMPONENT fft_data_mem
		PORT (
			clk:		IN	std_logic;
			w_en:		IN 	std_logic;
			r_addr:	IN	natural RANGE 0 TO POINTS - 1;
			w_addr:	IN 	natural RANGE 0 TO POINTS - 1;
			w_data:	IN	complex;
			r_data:	OUT	complex	
		);
	END COMPONENT;

	-- BUTTERFLY
	COMPONENT butterfly_tight
		PORT (
			clk:			IN 	std_logic;
			reset: 		IN	std_logic;
			bufly_sel:IN 	std_logic;
			data_in:	IN	complex;
			twid_in:	IN	complex;
			data_out:	OUT	complex
		);
	END COMPONENT;

	SIGNAL ram_r_addr: natural RANGE 0 TO POINTS - 1;
	SIGNAL ram_w_addr: natural RANGE 0 TO POINTS - 1;
	SIGNAL ram_r_data: complex;
	SIGNAL ram_w_data: complex;
	SIGNAL rom_r_addr: natural RANGE 0 TO POINTS - 1;
	SIGNAL rom_r_data: complex;

	SIGNAL b_data_out: complex;
	SIGNAL b_data_in:	 complex;
	SIGNAL ram_r_hold: complex;

	SIGNAL start: 		std_logic;
	SIGNAL w_en: 			std_logic;
	SIGNAL mem_sel: 	std_logic;
	SIGNAL bufly_sel:	std_logic;
	SIGNAL d_w_mux: 	std_logic_vector(1 DOWNTO 0);
	SIGNAL d_r_mux: 	std_logic_vector(1 DOWNTO 0);
BEGIN
	-- CONTROL
	control: fft_ctrl
		PORT MAP (
			clk 			=> clk,
			reset		 	=> reset,
			next_val  => sys_next,
			r_en			=> sys_r_en,
			w_en			=> sys_w_en,
			bufly_sel => bufly_sel,
			d_w_en 		=> w_en,
			d_r_addr	=> ram_r_addr,
			d_w_addr	=> ram_w_addr,
			rom_addr 	=> rom_r_addr,
			t_mem_sel	=> mem_sel,
			d_w_mux		=> d_w_mux,	-- RAM: write originates from BFY out(0) or from outside of system (1)
			d_r_mux		=> d_r_mux		-- RAM: read data transported to BFY (0) or to outside of system (1)
		); 

	-- TWID_MEM
	twid_mem: fft_twid_mem
		PORT MAP (
			clk 		=> clk,
			reset 	=> reset,
			mem_sel => mem_sel,
			r_addr 	=> rom_r_addr,
			r_data 	=> rom_r_data
		);

	-- DATA_MEM
	data_mem: fft_data_mem
		PORT MAP (
			clk 		=> clk,
			w_en 		=> w_en,
			r_addr 	=> ram_r_addr,
			w_addr  => ram_w_addr,
			w_data 	=> ram_w_data,
			r_data 	=> ram_r_data
		);

	-- BUTTERLFY
	bufly: butterfly_tight
		PORT MAP (
			clk 			=> clk,
			reset			=> reset,
			bufly_sel => bufly_sel,
			data_in 	=> b_data_in,
			twid_in		=> rom_r_data,
			data_out	=> b_data_out
		);

	-- MUXes	
	ram_w_data 	<= 	b_data_out 	WHEN d_w_mux = "00" ELSE 
									w_data			WHEN d_w_mux = "01" ELSE
									ram_r_hold;

	b_data_in		<= 	ram_r_data WHEN d_r_mux = "00" ELSE ((OTHERS => '0'),(OTHERS => '0'));
	r_data			<= 	ram_r_data WHEN d_r_mux = "01" ELSE ((OTHERS => '0'),(OTHERS => '0'));
							
	ram_r_hold	<= 	ram_r_data WHEN d_r_mux = "10" ELSE ((OTHERS => '0'),(OTHERS => '0'));
END behaviour;
