--------------------------------------------------------------------------
-- FILE        : BUTTERFLY_TIGHT.VHD
-- VERSION     : 1.00
-- DATE        : 08-06-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Entity and architecture for butterfly structure with timing
--								and one data line in and out.
--
--------------------------------------------------------------------------

-- Matrix form
-- +-  -+   +-          -+ +-  -+
-- |X[0]| = | 1  1  1  1 | |x[0]|
-- |X[1]| = | 1 -i -1  i | |x[1]|
-- }X[2]| = | 1 -1  1 -1 | |x[2]|
-- |X[3]| = | 1  i -1 -i | |x[3]|
-- +-  -+   +-          -+ +-  -+

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.fixed_pkg.all;
USE work.complex_pkg.all;


ENTITY butterfly_tight IS
	GENERIC (	
		RADIX: natural := 4
	);
	PORT (
		-- Clock and reset signals
		clk: 				IN	std_logic;
		reset: 			IN	std_logic;

		bufly_sel:	IN  std_logic;
		-- Data inputs
		data_in:		IN	complex;
		twid_in:		IN	complex;

		-- Data inputs
		data_out:		OUT	complex
	);
END butterfly_tight;

ARCHITECTURE behaviour OF butterfly_tight IS
	TYPE regs IS ARRAY (0 to RADIX - 1) OF complex;
	TYPE regs_2 IS ARRAY (0 to RADIX - 1) OF complex_2;
	TYPE data_holder IS ARRAY (0 TO 1) OF regs;
	TYPE data_holder_2 IS ARRAY (0 TO 1) OF regs_2;
	
	COMPONENT multiplier
		PORT (
			clk:		IN  std_logic;
			reset: 	IN 	std_logic;
			in_0:   IN  complex;
    	in_1:   IN  complex_2;
    	outp: 	OUT complex
		);
	END COMPONENT;

	SIGNAL state: 				natural RANGE 0 TO 3;
	SIGNAL n_state:				natural RANGE 0 TO 3;
	SIGNAL data_buf: 			data_holder; -- Data inputholder
	SIGNAL twid_buf:			data_holder_2; -- Twiddle holder
	SIGNAL m_in,m_out:		natural RANGE 0 TO 1;


	SIGNAL m_0:						complex;
	SIGNAL m_1:						complex_2;						

	SIGNAL next_add_0,next_add_1,add_0,add_1: data_holder;
BEGIN
	mult: multiplier
		PORT MAP (
			clk 	=> clk,
			reset	=> reset,
			in_0 	=> m_0,
			in_1 	=> m_1,
			outp 	=> data_out
		);

	PROCESS (clk,reset,bufly_sel)
		VARIABLE data_hold: complex;
		VARIABLE tmp,tmp_1: complex;
	BEGIN
		IF (reset = '0') THEN
			n_state 	<= 0;
			data_buf 	<= (OTHERS => (OTHERS => ((OTHERS => '0'),(OTHERS => '0'))));
			twid_buf 	<= (OTHERS => (OTHERS => ((OTHERS => '0'),(OTHERS => '0'))));
			m_in			<= 0;
			m_out			<= 1;
		
			m_0				<= ((OTHERS => '0'),(OTHERS => '0'));		
			m_1				<= ((OTHERS => '0'),(OTHERS => '0'));

			next_add_0 <= (OTHERS => (OTHERS => ((OTHERS => '0'),(OTHERS => '0'))));
			next_add_1 <= (OTHERS => (OTHERS => ((OTHERS => '0'),(OTHERS => '0'))));
			tmp := ((OTHERS => '0'),(OTHERS => '0'));
		ELSIF (bufly_sel = '1' and rising_edge(clk)) THEN
			twid_buf(m_out)(state) 	<= (twid_in.r(11 DOWNTO -14),twid_in.i(11 DOWNTO -14));
			data_buf(m_out)(state) 	<= data_in;
			--n_out <= n_calc(m_out)(state) * twid_buf(m_out)(state);
		
			next_add_0(m_in)(0) <= data_buf(m_in)(0) + data_buf(m_in)(2);
			next_add_0(m_in)(1) <= data_buf(m_in)(1) + data_buf(m_in)(3);
			next_add_0(m_in)(2) <= data_buf(m_in)(0) - data_buf(m_in)(2);
			-- Performs multiplication met imaginary factor i
			-- (a+bi) * i = -b+ai
			tmp := data_buf(m_in)(1) - data_buf(m_in)(3);
			next_add_0(m_in)(3) <= (twos_comp(tmp.i),tmp.r);

			next_add_1(m_in)(0) <= add_0(m_in)(0) + add_0(m_in)(1);
			next_add_1(m_in)(1) <= add_0(m_in)(2) - add_0(m_in)(3);
			next_add_1(m_in)(2) <= add_0(m_in)(0) - add_0(m_in)(1);
			next_add_1(m_in)(3) <= add_0(m_in)(2) + add_0(m_in)(3);
			
			m_0	<= add_1(m_out)(state);
			m_1 <= twid_buf(m_out)(state);

			IF (state = 3) THEN
				n_state <= 0;
				m_in <= m_out;
				m_out <= m_in;
			ELSE
				n_state <= state + 1;		
			END IF;
		
		END IF;
	END PROCESS;

	add_0 <= next_add_0;
	add_1 <= next_add_1;
	--data_out <= out_reg;
	state 		<= n_state;


END behaviour;