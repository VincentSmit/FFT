--------------------------------------------------------------------------
-- FILE        : MULTIPLIER.VHD
-- VERSION     : 1.00
-- DATE        : 26-06-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Entity and architecture for complex multiplier
--
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.fixed_pkg.all;
USE work.complex_pkg.all;

ENTITY multiplier IS
  PORT (
		-- Clock signal
		clk:		IN  std_logic;
		reset:	IN	std_logic;
		-- Data input and output signals
    in_0:   IN  complex;
    in_1:   IN  complex_2;
    outp: 	OUT complex
	);
END multiplier;

ARCHITECTURE bhv OF multiplier IS
  SIGNAL p,q,r,s: sfixed(19 DOWNTO -38);
  SIGNAL u,v:     sfixed(18 DOWNTO -14);
  SIGNAL w:       complex;
BEGIN
	PROCESS(clk,reset)
	BEGIN
		IF (reset = '0') THEN
			p <= (OTHERS => '0');
			q <= (OTHERS => '0');
			r <= (OTHERS => '0');
			s <= (OTHERS => '0');
			u <= (OTHERS => '0');
			v <= (OTHERS => '0');
			w <= ((OTHERS => '0'),(OTHERS => '0'));
		ELSIF(rising_edge(clk)) THEN
      p <= in_0.r * in_1.r;
      q <= in_0.i * in_1.i;
      r <= in_0.r * in_1.i;
      s <= in_0.i * in_1.r;
      u <= p(17 DOWNTO -14) - q(17 DOWNTO -14);
      v <= r(17 DOWNTO -14) + s(17 DOWNTO -14);
      w <= (u(17 DOWNTO -14),v(17 DOWNTO -14));
		END IF;
	END PROCESS;
  outp <= w;
END bhv;
