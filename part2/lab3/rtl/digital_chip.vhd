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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity digital_chip is
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
end digital_chip;

architecture Structural of digital_chip is
  
  component control is
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
  end component;
  
  component PresentEnc is
    generic (
      w_2:  integer := 2;
      w_4:  integer := 4;
      w_5:  integer := 5;
      w_32: integer := 32;
      w_64: integer := 64;
      w_80: integer := 80
    );
    port(
      plaintext         : in  std_logic_vector(w_64 - 1 downto 0);
      key               : in  std_logic_vector(w_80 - 1 downto 0);
      ciphertext        : out std_logic_vector(w_64 - 1 downto 0);
      key_end           : out std_logic_vector(w_80 - 1 downto 0);		
      start, clk, reset : in  std_logic;
      ready             : out std_logic		
    );
  end component;

  component PresentDec is
    generic (
      w_2: integer := 2;
      w_4: integer := 4;
      w_5: integer := 5;
      w_32: integer := 32;
      w_64: integer := 64;
      w_80: integer := 80
    );
    port(
      plaintext  : in std_logic_vector(w_64 - 1 downto 0);
      key        : in std_logic_vector(w_80 - 1 downto 0);
      ciphertext : out std_logic_vector(w_64 - 1 downto 0);
      start, clk, reset : in std_logic;
      ready : out std_logic		
    );
  end component PresentDec;
  
  component squarer_16b is
    port ( 
      input  : in  signed(15 downto 0);
      output : out signed(31 downto 0)
    );
  end component;
  
  component adder_16b is
    port ( 
      input1 : in  signed(15 downto 0);
      input2 : in  signed(15 downto 0);
      output : out signed(15 downto 0)
    );
  end component;
  
  component comparator_16b is
    port ( 
      input1 : in  std_logic_vector(15 downto 0);
      input2 : in  std_logic_vector(15 downto 0);
      output : out std_logic
    );
  end component;
  
  component release_logic is
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
  end component;
  
  signal enc_1_ready                  : std_logic;
  signal enc_2_ready                  : std_logic;
  signal dec_1_ready                  : std_logic;
  signal dec_2_ready                  : std_logic;
  signal enc_1_start                  : std_logic;
  signal enc_2_start                  : std_logic;
  signal dec_1_start                  : std_logic;
  signal dec_2_start                  : std_logic;
  signal store_data_1                 : std_logic;
  signal store_data_2                 : std_logic;
  signal encryption_input_1           : std_logic_vector(63 downto 0);
  signal encryption_input_2           : std_logic_vector(63 downto 0);
  signal encryption_output_1          : std_logic_vector(63 downto 0);
  signal encryption_output_2          : std_logic_vector(63 downto 0);
  signal key_gen_output_1             : std_logic_vector(79 downto 0);
  signal key_gen_output_2             : std_logic_vector(79 downto 0);
  signal decryption_input_1           : std_logic_vector(63 downto 0);
  signal decryption_input_2           : std_logic_vector(63 downto 0);
  signal decryption_output_1          : std_logic_vector(63 downto 0);
  signal decryption_output_2          : std_logic_vector(63 downto 0);
  signal decryption_output_1_signed   : signed(15 downto 0);
  signal decryption_output_2_signed   : signed(15 downto 0);
  signal squarer_1_output_1_signed    : signed(31 downto 0);
  signal squarer_2_output_2_signed    : signed(31 downto 0);
  signal adder_output_signed          : signed(15 downto 0);
  signal signature_2                  : std_logic_vector(15 downto 0);
  signal signature_in_signed          : signed(15 downto 0);
  signal squarer_3_output_signed      : signed(31 downto 0);
  signal signature_1                  : std_logic_vector(15 downto 0);
  signal comparator_output            : std_logic;

begin
  
  cntl : control port map (
    clk             => clk,
    reset           => reset,
    start           => start,
    enc_1_ready     => enc_1_ready,
    enc_2_ready     => enc_2_ready,
    dec_1_ready     => dec_1_ready,
    dec_2_ready     => dec_2_ready,
    enc_1_start     => enc_1_start,
    enc_2_start     => enc_2_start,
    dec_1_start     => dec_1_start,
    dec_2_start     => dec_2_start,
    store_data_1    => store_data_1,
    store_data_2    => store_data_2,
    system_ready    => system_ready
  );
  
  encryption_input_1 <= X"000000000000" & BCG_HF_in;
  
  enc_1 : PresentEnc port map (
    clk        => clk,
    reset      => reset,
    start      => enc_1_start,
    plaintext  => encryption_input_1,
    key	       => (others => '0'),
    ciphertext => encryption_output_1,
    key_end    => key_gen_output_1,
    ready      => enc_1_ready
  );
  
  decryption_input_1 <= encryption_output_1;

  dec_1 : PresentDec port map(
    plaintext	=> decryption_input_1,
    key		    => key_gen_output_1,
    ciphertext	=> decryption_output_1,
    start       => dec_1_start,
    clk	        => clk,
    reset       => reset,
    ready       => dec_1_ready
  );
  
  decryption_output_1_signed <= signed(decryption_output_1(15 downto 0));
  
  squarer_1 : squarer_16b port map(
    input  => decryption_output_1_signed,
    output => squarer_1_output_1_signed
  );

  encryption_input_2 <= X"000000000000" & BCG_DV_in;

  enc_2 : PresentEnc port map (
    clk        => clk,
    reset      => reset,
    start      => enc_2_start,
    plaintext  => encryption_input_2,
    key	       => (others => '0'),
    ciphertext => encryption_output_2,
    key_end    => key_gen_output_2,
    ready      => enc_2_ready
  );
  
  decryption_input_2 <= encryption_output_2;

  dec_2 : PresentDec port map(
    plaintext	=> decryption_input_2,
    key		    => key_gen_output_2,
    ciphertext	=> decryption_output_2,
    start       => dec_2_start,
    clk	        => clk,
    reset       => reset,
    ready       => dec_2_ready
  );
  
  decryption_output_2_signed <= signed(decryption_output_2(15 downto 0));
  
  squarer_2 : squarer_16b port map(
    input  => decryption_output_2_signed,
    output => squarer_2_output_2_signed
  );

  
  adder : adder_16b port map(
    input1 => squarer_1_output_1_signed(15 downto 0),
    input2 => squarer_2_output_2_signed(15 downto 0),
    output => adder_output_signed
  );
  
  signature_2  <= std_logic_vector(adder_output_signed);
  
  signature_in_signed <= signed(signature_in);
  
  squarer_3 : squarer_16b port map(
    input  => signature_in_signed,
    output => squarer_3_output_signed
  );
  
  signature_1  <= std_logic_vector(squarer_3_output_signed(15 downto 0));

  
  comp : comparator_16b port map(
    input1 => signature_1,
    input2 => signature_2,
    output => comparator_output
  );

                    
  rls_logic : release_logic port map(
    clk               => clk,
    reset             => reset,
    store_data1       => store_data_1,
    store_data2       => store_data_2,
    comparator_result => comparator_output,
    data1_in          => encryption_output_1,
    data2_in          => encryption_output_2,
    sig_in            => signature_in,
    data1_out         => encrypted_BCG_HF_out,
    data2_out         => encrypted_BCG_DV_out,
    sig_out           => signature_out
  );
  
end Structural;
