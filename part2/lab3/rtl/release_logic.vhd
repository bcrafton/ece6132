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

entity release_logic is
  port (
    clk               : in  std_logic;
    reset             : in  std_logic;
    store_data1       : in  std_logic;
    store_data2       : in  std_logic;
    comparator_result : in  std_logic;
    data1_in          : in  std_logic_vector(63 downto 0);
    data2_in          : in  std_logic_vector(63 downto 0);
    sig_in            : in  std_logic_vector(15 downto 0);
    data1_out         : out std_logic_vector(63 downto 0);
    data2_out         : out std_logic_vector(63 downto 0);
    sig_out           : out std_logic_vector(15 downto 0)
  );
end release_logic;

architecture Behavioral of release_logic is
  
  signal data1_reg    : std_logic_vector(63 downto 0);
  signal data2_reg    : std_logic_vector(63 downto 0);
  
begin
  
  data1_out <= data1_reg when comparator_result = '1' else
               (others => '0');
  
  data2_out <= data2_reg when comparator_result = '1' else
               (others => '0');
  
  sig_out   <= sig_in    when comparator_result = '1' else
               (others => '0');
  
  
  store_data: process(clk)
  begin
    if (rising_edge(clk)) then
      if( reset = '1' )then
        data1_reg <= (others => '0');
   	data2_reg <= (others => '0');
      else
        if (store_data1 = '1') then
          data1_reg <= data1_in;
        end if;
        if (store_data2 = '1') then
          data2_reg <= data2_in;
        end if;
      end if;
    end if;
  end process;
  
end Behavioral;
