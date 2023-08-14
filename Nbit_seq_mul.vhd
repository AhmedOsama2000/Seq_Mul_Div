library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL; 


entity N_Seq_Mul is
    Generic (
        WIDTH : positive := 8
    );
    Port 
    ( 
        a          : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        b          : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        En         : in  STD_LOGIC;   
        clk        : in  STD_LOGIC;
        rst_n      : in  STD_LOGIC;
        valid_mul  : out STD_LOGIC;
        busy_mul   : out STD_LOGIC;
        m          : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        r          : out STD_LOGIC_VECTOR(WIDTH-1 downto 0) 
    );
end N_Seq_Mul;


architecture Behavioral of N_Seq_Mul is
    
    signal result_mul : STD_LOGIC_VECTOR(2*WIDTH-1 downto 0);
    signal Accumulator_mul : STD_LOGIC_VECTOR(2*WIDTH-1 downto 0);
    signal X : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    signal Y : STD_LOGIC_VECTOR(2*WIDTH-1 downto 0);
    signal j : integer := 0;
    signal busy: STD_LOGIC := '0';
    signal sign: STD_LOGIC ;

    
begin

   process (clk, rst_n)
    begin
        if rst_n = '0' then
            Accumulator_mul <= (OTHERS => '0');
             j <= WIDTH-1;
             valid_mul <= '0';
             X <= (OTHERS => '0');
             Y <= (OTHERS => '0');
             result_mul <= (OTHERS => '0');
             busy <= '0';
        elsif rising_edge(clk) then
            if En = '0' and busy = '0' then
                Accumulator_mul <= (OTHERS => '0');
                X <= (OTHERS => '0');
                Y <= (OTHERS => '0');
                j <= WIDTH-1;
                busy      <= '0';
                valid_mul <= '0';
            elsif En = '1' and busy = '0' then
                   sign <= a(WIDTH-1) xor b(WIDTH-1) ; -- 1 if - 0 if +
                   
                   if a(WIDTH-1) = '0' then
                   X <= a;
                   else 
                     X <= not a + '1';
                   end if;
                  if b(WIDTH-1) = '0' then
                   Y(WIDTH-1 downto 0) <= b;
                   else 
                   Y(WIDTH-1 downto 0) <= not b + '1';
                   end if;
                   Accumulator_mul <= (OTHERS => '0');
                   j <= WIDTH-1;
                   valid_mul <= '0';
                   busy <= '1';
            elsif  busy = '1' then
                    if X(0) = '1' then
                        Accumulator_mul <= Accumulator_mul + Y;
                    end if;
                    Y(2*WIDTH-1 downto 0) <= Y(2*WIDTH-2 downto 0) & '0';
                    X(WIDTH-1 downto 0) <= '0' & X(WIDTH-1 downto 1);
                    j <= j-1;
                    if j = 0 then
                      if sign  = '0' then
                        result_mul      <= Accumulator_mul;
                    else 
                        result_mul <= not Accumulator_mul + '1' ;
                    end if;
                    valid_mul <= '1';
                    busy      <= '0';
                    X         <= (OTHERS => '0');
                    Y         <= (OTHERS => '0');
                    j         <= WIDTH-1;
                    end if;

            end if;
        end if;
    end process;
    busy_mul <= busy ;
    m        <= result_mul(2*WIDTH-1 downto WIDTH);
    r        <= result_mul(WIDTH-1 downto 0);

end Behavioral;





