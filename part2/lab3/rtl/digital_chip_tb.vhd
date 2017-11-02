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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.Numeric_Std_Unsigned.ALL;
--use IEEE.Numeric_Std_Signed.ALL;

entity digital_chip_tb is
end digital_chip_tb;

architecture Behavioral of digital_chip_tb is
  
  component digital_chip
    port	(
      clk                  : in  std_logic;
      reset                : in  std_logic;
      start                : in  std_logic;
      BCG_HF_in            : in  std_logic_vector(15 downto 0);
      BCG_DV_in            : in  std_logic_vector(15 downto 0);
      signature_in         : in  std_logic_vector(15 downto 0);
      system_ready         : out std_logic;
      encrypted_BCG_HF_out : out std_logic_vector(63 downto 0);
      encrypted_BCG_DV_out : out std_logic_vector(63 downto 0);
      signature_out        : out std_logic_vector(15 downto 0)
    );
  end component;

  -- Inputs
  signal clk                  : std_logic := '0';
  signal reset                : std_logic := '1';
  signal start                : std_logic := '0';
  signal BCG_HF_in            : std_logic_vector(15 downto 0);
  signal BCG_DV_in            : std_logic_vector(15 downto 0);
  signal signature_in         : std_logic_vector(15 downto 0);
  
  -- Outputs
  signal system_ready         : std_logic;
  signal encrypted_BCG_HF_out : std_logic_vector(63 downto 0);
  signal encrypted_BCG_DV_out : std_logic_vector(63 downto 0);
  signal signature_out        : std_logic_vector(15 downto 0);
  
  constant clk_period         : time := 10 ns;

begin
  
  dc : digital_chip port map (
    clk                  => clk,
    reset                => reset,
    start                => start,
    BCG_HF_in            => BCG_HF_in,
    BCG_DV_in            => BCG_DV_in,
    signature_in         => signature_in,
    system_ready         => system_ready,
    encrypted_BCG_HF_out => encrypted_BCG_HF_out,
    encrypted_BCG_DV_out => encrypted_BCG_DV_out,
    signature_out        => signature_out
  );
  
  -- Clock process
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
  
  -- Stimulus process
  stim_proc: process
  begin		
    reset <= '1';
    start <= '0';
    -- hold reset state for 2 clock cycles.
    wait for clk_period*10;
    
    reset <= '0';
    
    
---- Preparation for test case 1 -----------------
--   BCG_HF_in    <= X"0003";
--   BCG_DV_in    <= X"0004";
--   signature_in <= X"0005";
--   Expected Match
--------------------------------------------------
    start        <= '1';
    BCG_HF_in    <= X"0003";
    BCG_DV_in    <= X"0004";
    signature_in <= X"0005";
    
    wait until system_ready = '1' and clk = '0';
    
    if (signature_out = signature_in) then
      report "Test case 1 successful, No Trojan As Expected" severity note;
    else
       report "Test case 1 failed" severity note;
       for i in 0 to signature_in'LENGTH-1 loop
            -- report std_logic'image(signature_in(i));
       end loop;
       for i in 0 to signature_out'LENGTH-1 loop
            -- report std_logic'image(signature_out(i));
       end loop;
    end if;
    
    start        <= '0';
    wait for clk_period;
    
    
---- Preparation for test case 2 -----------------
--   BCG_HF_in    <= X"0008";
--   BCG_DV_in    <= X"0006";
--   signature_in <= X"000B";
--   Expected Mismatch
--------------------------------------------------
    start        <= '1';
    BCG_HF_in    <= X"0008";
    BCG_DV_in    <= X"0006";
    signature_in <= X"000B";
    
    wait until system_ready = '1' and clk = '0';
    
    if (signature_out /= signature_in) then
      report "Test case 2 successful, No Trojan As Expected" severity note;
    else
       report "Test case 2 failed" severity note;
       for i in 0 to signature_in'LENGTH-1 loop
            -- report std_logic'image(signature_in(i));
       end loop;
       for i in 0 to signature_out'LENGTH-1 loop
            -- report std_logic'image(signature_out(i));
       end loop;
    end if;
    
    start        <= '0';
    wait for clk_period;


---- Preparation for test case 3 -----------------
--   BCG_HF_in    <= X"0003";
--   BCG_DV_in    <= X"0004";
--   signature_in <= X"0005";
--   Expected Match
--------------------------------------------------
    start        <= '1';
    BCG_HF_in    <= X"0003";
    BCG_DV_in    <= X"0004";
    signature_in <= X"0005";
    
    wait until system_ready = '1' and clk = '0';
    
    if (signature_out = signature_in) then
      report "Test case 3 successful, No Trojan As Expected" severity note;
    else
       report "Test case 3 failed" severity note;
       for i in 0 to signature_in'LENGTH-1 loop
            -- report std_logic'image(signature_in(i));
       end loop;
       for i in 0 to signature_out'LENGTH-1 loop
            -- report std_logic'image(signature_out(i));
       end loop;
    end if;
    
    start        <= '0';
    wait for clk_period;


---- Preparation for test case 4 -----------------
--   BCG_HF_in    <= X"0008";
--   BCG_DV_in    <= X"0006";
--   signature_in <= X"000A";
--   Expected Match
--------------------------------------------------
    start        <= '1';
    BCG_HF_in    <= X"0008";
    BCG_DV_in    <= X"0006";
    signature_in <= X"000A";
    
    wait until system_ready = '1' and clk = '0';

    if (signature_out = signature_in) then
      report "Test case 4 successful, No Trojan As Expected" severity note;
    else
       report "Test case 4 failed" severity note;
       for i in 0 to signature_in'LENGTH-1 loop
            -- report std_logic'image(signature_in(i));
       end loop;
       for i in 0 to signature_out'LENGTH-1 loop
            -- report std_logic'image(signature_out(i));
       end loop;
    end if;
    
    start        <= '0';
    wait for clk_period;
    
    wait;
    
  end process;
  
end Behavioral;
