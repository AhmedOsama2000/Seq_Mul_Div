LIBRARY ieee;
use     ieee.std_logic_1164.all;
Use     ieee.std_logic_Arith.all;
use     ieee.std_logic_unsigned.all;

ENTITY seq_div IS
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
END ENTITY seq_div;

ARCHITECTURE divider_seq OF seq_div IS

   SIGNAL divisor_reg     : std_logic_vector (WIDTH-1 downto 0);

   SIGNAL accumulator_reg : std_logic_vector (2*WIDTH downto 0);
   SIGNAL correct         : std_logic_vector (WIDTH downto 0);

   SIGNAL passed_a        : std_logic_vector(WIDTH-1 downto 0);
   SIGNAL passed_b        : std_logic_vector(WIDTH-1 downto 0);

   SIGNAL accumulator     : std_logic_vector (2*WIDTH downto 0);

   SIGNAL count           : std_logic_vector (2       downto 0); -- Log2 of WIDTH, so that the width should be 2-4-8-16-32-....
   SIGNAL conv_en         : std_logic;
   SIGNAL div_by_zero     : std_logic;
   SIGNAL Q_LSB           : std_logic;

   BEGIN
      detect_err: process (b) is
      begin
         if (b = "00000000") then
            div_by_zero <= '1';
            error_bit   <= '1';
         ELSE 
            div_by_zero <= '0';
            error_bit   <= '0';
         END IF;
      end process;

      conv_a:process (a) is
      begin
         if (a(WIDTH-1) = '1') then
            passed_a <= not(a) + '1';
         else 
            passed_a <= a;
         end if;
      end process;

      conv_b:process (b) is
      begin
         if (b(WIDTH-1) = '1') then
            passed_b <= not(b) + '1';
         else 
            passed_b <= b;
         end if;
      end process;

      conv_out: process (a,b) is
      begin
         if ((a(WIDTH-1) = '1' and b(WIDTH-1) = '0') or (a(WIDTH-1) = '0' and b(WIDTH-1) = '1')) then
            conv_en <= '1';
         else 
            conv_en <= '0';
         end if;
      end process;

      process (clk,rst_n) is
      begin
         if (rst_n = '0') THEN
            divisor_reg     <= (others => '0');
            count           <= (others => '0');
            m               <= (others => '0');
            correct         <= (others => '0');
            accumulator_reg <= (others => '0');  
            busy_div        <= '0';
            valid_div       <= '0'; 

         ELSIF (rising_edge (clk)) THEN

            if (En = '1' and div_by_zero = '0' and busy_div = '0') THEN
               count           <= (others => '0');
               valid_div       <= '0';
               busy_div        <= '1';
               divisor_reg     <= passed_b;
               accumulator_reg <= "00000000" & passed_a & '0';

            ELSIF (conv_integer(count) < WIDTH-1) then
               accumulator_reg <= accumulator(2*WIDTH-1 downto 0) & '0';
               count           <= count + '1';

            ELSIF ((conv_integer(count) = WIDTH-1) and (busy_div = '1')) then
               if (conv_en = '1') then
                  m <= not(accumulator(WIDTH-1 downto 0)) + '1';
               else 
                  m <= accumulator(WIDTH-1 downto 0);
               end if;
               if (accumulator(2*WIDTH) = '1') then
                  correct  <= accumulator(2*WIDTH downto WIDTH) + ('0' & divisor_reg);
               else 
                  correct  <= accumulator(2*WIDTH downto WIDTH);
               end if;
               valid_div <= '1';
               busy_div  <= '0';

            ELSE
               valid_div <= '0';
               busy_div  <= '0';

            END IF; 
         END IF;
      end process;

      process (all) is
      begin
         accumulator(WIDTH-1 downto 0) <= accumulator_reg(WIDTH-1 downto 0);

         if (busy_div = '1') THEN

            if (accumulator_reg(2*WIDTH) = '1') then
               accumulator(2*WIDTH downto WIDTH) <= accumulator_reg(2*WIDTH downto WIDTH) + ('0' & divisor_reg);
            else 
               accumulator(2*WIDTH downto WIDTH) <= accumulator_reg(2*WIDTH downto WIDTH) + ('1' & not divisor_reg) + '1';
            end if;

            if (accumulator(2*WIDTH) = '1') then
               Q_LSB <= '0';
            else 
               Q_LSB <= '1';
            end if;

            accumulator(0) <= Q_LSB;
         ELSE 
            accumulator <= (others => '0');
            Q_LSB       <= '0';

         END IF;

      end process;

      process (all) is
      begin
         if (conv_en = '1') then
            r <= not(correct(WIDTH-1 downto 0)) + '1';
         else 
            r <= correct(WIDTH-1 downto 0);
         end if;
      end process;

END ARCHITECTURE divider_seq;