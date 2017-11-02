-----------------------------------------------------------------------
----                                                               ----
---- Biometrics for signature-based Hardware Trojan Detection      ----
----                                                               ----
----                                                               ----
---- Author(s):                                                    ----
---- - Taimour Wehbe, taimour.wehbe@gatech.edu                     ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
----                                                               ----
---- Hardware/Software Codesign for Security Group                 ----
---- Copyright (C) 2016-17 Georgia Institute of Technology         ----
----                                                               ----
----                                                               ----
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity squarer_16b is
	port ( 
		input  : in  signed(15 downto 0);
		output : out signed(31 downto 0)
	);
end squarer_16b;

architecture Behavioral of squarer_16b is

begin
	output <= input * input;
end Behavioral;
