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

entity comparator_16b is
	port ( 
		input1 : in  std_logic_vector(15 downto 0);
		input2 : in  std_logic_vector(15 downto 0);
		output : out std_logic
	);
end comparator_16b;

architecture Behavioral of comparator_16b is

begin
	output <= '1' when input1 = input2 else
            '0';
end Behavioral;
