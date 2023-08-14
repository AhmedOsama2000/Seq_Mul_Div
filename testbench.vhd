LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
Use     ieee.std_logic_Arith.all;
use     ieee.std_logic_signed.all;
use std.textio.all;

ENTITY seq_tb IS 
  generic (
    WIDTH: positive := 8
  );
END ENTITY seq_tb;

ARCHITECTURE testbench OF seq_tb IS
  component seq_mul_div is
    PORT
      (  
        clk_top       : in  std_logic;
        rst_n_top     : in  std_logic;
        En_top        : in  std_logic;
        mode_sel      : in  std_logic;
        a_top         : in  std_logic_vector(WIDTH-1 downto 0);
        b_top         : in  std_logic_vector(WIDTH-1 downto 0);
        m_top         : out std_logic_vector(WIDTH-1 downto 0);
        r_top         : out std_logic_vector(WIDTH-1 downto 0);
        busy_bit      : out std_logic;
        valid_bit     : out std_logic;
        error_bit     : out std_logic
      );
  end component seq_mul_div; 

  SIGNAL clk_tb       : std_logic;
  SIGNAL rst_n_tb     : std_logic;
  SIGNAL En_top_tb    : std_logic;
  SIGNAL mode_sel_tb  : std_logic;
  SIGNAL a_tb         : std_logic_vector(WIDTH-1 downto 0);
  SIGNAL b_tb         : std_logic_vector(WIDTH-1 downto 0);
  SIGNAL m_tb         : std_logic_vector(WIDTH-1 downto 0);
  SIGNAL r_tb         : std_logic_vector(WIDTH-1 downto 0);
  SIGNAL busy_bit_tb  : std_logic;
  SIGNAL valid_bit_tb : std_logic;
  SIGNAL error_bit_tb : std_logic;

  SIGNAL expected_res : std_logic_vector(2*WIDTH-1 downto 0);

BEGIN 
  -- DUT instantiation
  DUT: seq_mul_div port map (
    clk_top   => clk_tb,
    rst_n_top => rst_n_tb,
    En_top    => En_top_tb,
    mode_sel  => mode_sel_tb,
    a_top     => a_tb,
    b_top     => b_tb,
    m_top     => m_tb,
    r_top     => r_tb,
    busy_bit  => busy_bit_tb,
    valid_bit => valid_bit_tb,
    error_bit => error_bit_tb
  );

  process
      file     cases_file     : text open read_mode is "testcases_tb.txt";
      variable test_line      : line;
      variable test_data      : std_logic_vector(16 downto 0); -- test stimulus
  begin

    -- initialize 
    rst_n_tb    <= '0';
    mode_sel_tb <= '0';
    En_top_tb   <= '0';
    a_tb        <= (others => '0');
    b_tb        <= (others => '0');
    wait for 50 ns;

    -- dessert reset 
    rst_n_tb    <= '1';
    wait for 50 ns;

    while not endfile(cases_file) loop

        readline(cases_file, test_line);
        read(test_line, test_data);

        wait until falling_edge(clk_tb);

        -- Begin stimulus
        En_top_tb    <= '1';
        a_tb         <= test_data(16 downto 9);
        b_tb         <= test_data(8 downto 1);
        mode_sel_tb  <= test_data(0);
        wait until falling_edge(clk_tb);
        En_top_tb    <= '0';
 
        wait for 160 ns;

        assert (expected_res(2*WIDTH-1 downto WIDTH) = m_tb and expected_res(WIDTH-1 downto 0) = r_tb) 
        report "Test Case Failed" severity note;

    end loop;
    file_close(cases_file);
    
    wait for 300 ns;
  end process;

  clock: PROCESS IS
  BEGIN
    clk_tb <= '0', '1' AFTER 10 ns;
    WAIT FOR 20 ns;
  END PROCESS clock;

END ARCHITECTURE testbench;

