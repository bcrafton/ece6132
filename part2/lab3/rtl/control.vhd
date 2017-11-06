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

entity control is
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    start           : in  std_logic;
    enc_1_ready     : in  std_logic;
    enc_2_ready     : in  std_logic;
    dec_1_ready     : in  std_logic;
    dec_2_ready     : in  std_logic;
    enc_1_start     : out std_logic;
    enc_2_start     : out std_logic;
    dec_1_start     : out std_logic;
    dec_2_start     : out std_logic;
    store_data_1    : out std_logic;
    store_data_2    : out std_logic;
    system_ready    : out std_logic
  );
end control;

architecture Behavioral of control is
  
  type state_type is (s0, s1, s2, s3, s4);
  signal state   : state_type;
  
begin
	
	process (clk, reset)
  begin
    if (reset = '1') then
         state <= s0;
    elsif (clk'event and clk = '1') then
      case state is
        -- waiting for start
        when s0 =>
          if (start = '1') then
            state <= s1;
          else
            state <= s0;
          end if;
          
        -- performing encryption
        when s1 =>
            if ((enc_1_ready = '1') and (enc_2_ready = '1')) then
              state <= s4;
            else
              state <= s1;
            end if;
        
        -- performing decryption
        when s2 =>
            if ((dec_1_ready = '1') and (dec_2_ready = '1')) then
              state <= s3;
            else
              state <= s2;
            end if;
          
        when s3 =>
          state <= s2;

        when s4 =>
          state <= s2;
          
      end case;
    end if;
  end process;
   
  process (state)
  begin
    case state is
      when s0 =>
        enc_1_start    <= '0';
        enc_2_start    <= '0';
        dec_1_start    <= '0';
        dec_2_start    <= '0';
        store_data_1   <= '0';
        store_data_2   <= '0';
        system_ready   <= '0';
      when s1 =>
        enc_1_start    <= '1';
        enc_2_start    <= '1';
        dec_1_start    <= '0';
        dec_2_start    <= '0';
        store_data_1   <= '0';
        store_data_2   <= '0';
        system_ready   <= '0';
      when s4 =>
        enc_1_start    <= '0';
        enc_2_start    <= '0';
        dec_1_start    <= '0';
        dec_2_start    <= '0';
        store_data_1   <= '0';
        store_data_2   <= '0';
        system_ready   <= '0';
      when s2 =>
        enc_1_start    <= '1';
        enc_2_start    <= '1';
        dec_1_start    <= '1';
        dec_2_start    <= '1';
        store_data_1   <= '1';
        store_data_2   <= '1';
        system_ready   <= '0';
      when s3 =>
        enc_1_start    <= '0';
        enc_2_start    <= '0';
        dec_1_start    <= '0';
        dec_2_start    <= '0';
        store_data_1   <= '0';
        store_data_2   <= '0';
        system_ready   <= '1';
    end case;
  end process;
	
end Behavioral;
