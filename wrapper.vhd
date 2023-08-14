library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.STD_LOGIC_ARITH.ALL;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY seq_mul_div IS
   generic (
      WIDTH: positive := 8
   );
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
END ENTITY seq_mul_div;


architecture integration of seq_mul_div is
    
    SIGNAL En_mul     : std_logic;
    SIGNAL En_div     : std_logic;
    SIGNAL busy_mul   : std_logic;
    SIGNAL busy_div   : std_logic;
    SIGNAL valid_mul  : std_logic;
    SIGNAL valid_div  : std_logic;

    SIGNAL m_mul      : std_logic_vector(WIDTH-1 downto 0);
    SIGNAL r_mul      : std_logic_vector(WIDTH-1 downto 0);
    SIGNAL m_div      : std_logic_vector(WIDTH-1 downto 0);
    SIGNAL r_div      : std_logic_vector(WIDTH-1 downto 0);

    component N_Seq_Mul is
        Generic (
            WIDTH : positive := 8
        );
        Port 
        ( 
            a          : in  std_logic_vector(WIDTH-1 downto 0);
            b          : in  std_logic_vector(WIDTH-1 downto 0);
            En         : in  std_logic;   
            clk        : in  std_logic;
            rst_n      : in  std_logic;
            valid_mul  : out std_logic;
            busy_mul   : out std_logic;
            m          : out std_logic_vector(WIDTH-1 downto 0);
            r          : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component N_Seq_Mul;
    component seq_div is
        generic (
            WIDTH: positive := 8
        );
        PORT
        (  
            clk      : in  std_logic;
            rst_n    : in  std_logic;
            En       : in  std_logic;
            a        : in  std_logic_vector(WIDTH-1 downto 0);
            b        : in  std_logic_vector(WIDTH-1 downto 0);
            m        : out std_logic_vector(WIDTH-1 downto 0);
            r        : out std_logic_vector(WIDTH-1 downto 0);
            busy_div : out std_logic;
            valid_div: out std_logic;
            error_bit: out std_logic
        );
    end component seq_div;
    BEGIN
    -- Integeration
    Multiplier: N_Seq_Mul port map (
        clk       => clk_top,
        rst_n     => rst_n_top,
        En        => En_mul,
        a         => a_top,
        b         => b_top,
        m         => m_mul,
        r         => r_mul,
        busy_mul  => busy_mul,
        valid_mul => valid_mul
    );
    Divider: seq_div port map (
        clk       => clk_top,
        rst_n     => rst_n_top,
        En        => En_div,
        a         => a_top,
        b         => b_top,
        m         => m_div,
        r         => r_div,
        busy_div  => busy_div,
        valid_div => valid_div,
        error_bit => error_bit
    );   

   process (all)
    begin
        if (mode_sel = '0') then
            En_mul    <= En_top;
            En_div    <= '0';
            busy_bit  <= busy_mul;
            valid_bit <= valid_mul;
            m_top     <= m_mul;
            r_top     <= r_mul;
        elsif (mode_sel = '1') then
            En_mul    <= '0';
            En_div    <= En_top;
            busy_bit  <= busy_div;
            valid_bit <= valid_div;
            m_top     <= m_div;
            r_top     <= r_div;
        else 
            En_mul    <= '0';
            En_div    <= '0';
            busy_bit  <= '0';
            valid_bit <= '0';
            m_top     <= (others => '0');
            r_top     <= (others => '0');
        end if;
    end process;

end integration;




