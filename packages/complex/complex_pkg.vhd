--------------------------------------------------------------------------
-- FILE        : FFT_PKG.VHD
-- VERSION     : 1.00
-- DATE        : 16-05-2017
-- BY          : Vincent Smit
--
-- DESCRIPTION : Package for fft operation
--
--------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

LIBRARY work;
USE work.fixed_pkg.all;

PACKAGE complex_pkg IS
	SUBTYPE sfixed_16 IS sfixed(17 DOWNTO -14);
	SUBTYPE sfixed_2 IS sfixed(1 DOWNTO -24);

	TYPE complex IS
		RECORD
			r: sfixed_16;
			i: sfixed_16;
		END RECORD;

	TYPE complex_2 IS
		RECORD
			r: sfixed_2;
			i: sfixed_2;
		END RECORD;

	FUNCTION "+" (c_0, c_1: complex) RETURN complex;
	FUNCTION "-" (c_0, c_1: complex) RETURN complex;
	FUNCTION "*" (c_0, c_1: complex) RETURN complex;
--  FUNCTION inv (c: complex) RETURN complex;
	
	-- Because ugliness
	FUNCTION "+" (c_0: complex; c_1: complex_2) RETURN complex;
	FUNCTION "-" (c_0: complex; c_1: complex_2) RETURN complex;
	FUNCTION "*" (c_0: complex; c_1: complex_2) RETURN complex;

  
  FUNCTION "+" (c_0: complex_2; c_1: complex_2) RETURN complex_2;
	FUNCTION "-" (c_0: complex_2; c_1: complex_2) RETURN complex_2;
	FUNCTION "*" (c_0: complex_2; c_1: complex_2) RETURN complex_2;
  
	FUNCTION twos_comp(f: sfixed) RETURN sfixed;
END complex_pkg;

PACKAGE BODY complex_pkg IS
	FUNCTION "+" (c_0, c_1: complex) RETURN complex IS
    VARIABLE tmp_0: sfixed(18 DOWNTO -14);
    VARIABLE tmp_1: sfixed(18 DOWNTO -14);
	BEGIN
    tmp_0 := c_0.r + c_1.r;
    tmp_1 := c_0.i + c_1.i;
		RETURN (tmp_0(17 DOWNTO -14), tmp_1(17 DOWNTO -14));
	END FUNCTION;

	FUNCTION "-" (c_0, c_1: complex) RETURN complex IS
    VARIABLE tmp_0: sfixed(18 DOWNTO -14);
    VARIABLE tmp_1: sfixed(18 DOWNTO -14);
	BEGIN
    tmp_0 := c_0.r - c_1.r;
    tmp_1 := c_0.i - c_1.i;
		RETURN (tmp_0(17 DOWNTO -14), tmp_1(17 DOWNTO -14));
	END FUNCTION;

	FUNCTION "*" (c_0, c_1: complex) RETURN complex IS
	BEGIN
		RETURN ((c_0.r * c_1.r) - (c_0.i * c_1.i), (c_0.i * c_1.r) + (c_0.r * c_1.i));
	END FUNCTION;
	
	FUNCTION twos_comp (f: sfixed) RETURN sfixed IS
    VARIABLE tmp: sfixed(f'high + 1 DOWNTO f'low);
		VARIABLE one: sfixed(f'low +1 DOWNTO f'low);
	BEGIN
		one := "01";
		tmp := (not f) + one;
    RETURN tmp(f'high DOWNTO f'low);
	END FUNCTION;

	FUNCTION "+" (c_0: complex; c_1: complex_2) RETURN complex IS
		VARIABLE tmp_0: sfixed(18 DOWNTO -14);
    VARIABLE tmp_1: sfixed(18 DOWNTO -14);
	BEGIN
    tmp_0 := c_0.r + c_1.r;
    tmp_1 := c_0.i + c_1.i;
		RETURN (tmp_0(17 DOWNTO -14), tmp_1(17 DOWNTO -14));
	END FUNCTION;

	FUNCTION "-" (c_0: complex; c_1: complex_2) RETURN complex IS
		VARIABLE tmp_0: sfixed(18 DOWNTO -14);
    VARIABLE tmp_1: sfixed(18 DOWNTO -14);
	BEGIN
    tmp_0 := c_0.r - c_1.r;
    tmp_1 := c_0.i - c_1.i;
		RETURN (tmp_0(17 DOWNTO -14), tmp_1(17 DOWNTO -14));
	END FUNCTION;

	FUNCTION "*" (c_0: complex; c_1: complex_2) RETURN complex IS
	BEGIN
		RETURN (resize((c_0.r * c_1.r) - (c_0.i * c_1.i),17,-14), resize((c_0.i * c_1.r) + (c_0.r * c_1.i),17,-14));
	END FUNCTION;
  
  FUNCTION "+" (c_0: complex_2; c_1: complex_2) RETURN complex_2 IS
		VARIABLE tmp_0: sfixed(2 DOWNTO -24);
    VARIABLE tmp_1: sfixed(2 DOWNTO -24);
	BEGIN
    tmp_0 := c_0.r + c_1.r;
    tmp_1 := c_0.i + c_1.i;
		RETURN (tmp_0(1 DOWNTO -24), tmp_1(1 DOWNTO -24));
	END FUNCTION;

	FUNCTION "-" (c_0: complex_2; c_1: complex_2) RETURN complex_2 IS
		VARIABLE tmp_0: sfixed(2 DOWNTO -24);
    VARIABLE tmp_1: sfixed(2 DOWNTO -24);
	BEGIN
    tmp_0 := c_0.r - c_1.r;
    tmp_1 := c_0.i - c_1.i;
		RETURN (tmp_0(1 DOWNTO -24), tmp_1(1 DOWNTO -24));
	END FUNCTION;

	FUNCTION "*" (c_0: complex_2; c_1: complex_2) RETURN complex_2 IS
	BEGIN
		RETURN ((c_0.r * c_1.r) - (c_0.i * c_1.i), (c_0.i * c_1.r) + (c_0.r * c_1.i));
	END FUNCTION;
END complex_pkg;