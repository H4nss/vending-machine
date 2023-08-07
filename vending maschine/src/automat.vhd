library ieee;
use ieee.std_logic_1164.all;

use work.drink_menu.all;
entity automat is
  port (
    clk : in bit;
    reset : in bit;
    service_reset_input : in bit;
    start : in bit;
    product : in std_logic_vector(4 downto 0);
    inserted_coin : inout integer := 0;
	 hex_state: out std_logic_vector(6 downto 0);
	 hex_price: out std_logic_vector(6 downto 0);
	 hex_rest: out std_logic_vector(6 downto 0)
  );
end automat;
architecture a of automat is

	component seven_seg is
		port (
			input_hex: in std_logic_vector(3 downto 0);
			output_hex: out std_logic_vector(6 downto 0)
		);
	end component;

  type STATE_TYPE is (ZERO, ACCIDENT, WAITING_FOR_PAYMENT, READY_TO_PICK, HANDLING_PAYMENT, PREPARING_PRODUCT, SERVING_DRINK, SERVICE_RESET);
  type AMOUNT_OF_SUGAR is (NO_SUGAR, ONE_TEASPOON, TWO_TEASPOONS, THREE_TEASPOONS);
  signal state : STATE_TYPE;
  signal order : drink_option;
  signal sugar : integer;
    -- zasoby jakie posiada automat
  signal r_1_pln_coins : integer := 5;
  signal r_2_pln_coins : integer := 10;
  signal r_5_pln_coins : integer := 15;
  signal r_water : integer := 10;
  signal r_milk : integer := 10;
  signal r_black_tea : integer := 10;
  signal r_green_tea : integer := 10;
  signal r_yellow_tea : integer := 10;
  signal r_coffee : integer := 10;
  signal r_sugar : integer := 10;

  -- ilosc monet wprowadzonych przez uzytkownika
  signal one_pln_coin : integer := 0;
  signal two_pln_coin : integer := 0;
  signal five_pln_coin : integer := 0;
  -- ilosc monet uzyta do sprawdzenia mozliwosci wydania reszty
  signal account_balance : integer := 0;
  
  signal hex_state_int : std_logic_vector(3 downto 0);
  signal hex_price_int : std_logic_vector(3 downto 0);
  signal hex_rest_int : std_logic_vector(3 downto 0);
  
begin
	 hex1: seven_seg port map (input_hex => hex_state_int, output_hex => hex_state);
	 hex2: seven_seg port map (input_hex => hex_price_int, output_hex => hex_price);
	 hex3: seven_seg port map (input_hex => hex_rest_int, output_hex => hex_rest);
	 
  process (clk, reset)
    variable ch_1_coin : integer := 0;
    variable ch_2_coin : integer := 0;
    variable ch_5_coin : integer := 0;
    variable counter : integer range 0 to 10;
    variable change_tmp : integer; -- used to calculate change from available coins
    variable change : integer; -- just stores account_balance - order.price
    variable loop_iterator : integer; -- forced by weird Intel policy 
    variable serving_error : bit := '0';
  begin
  
    if reset = '1' then
      state <= ZERO;
    elsif service_reset_input = '1' then
      state <= SERVICE_RESET;
    elsif (clk'EVENT and clk = '1') then
	 
		case state is

        when SERVICE_RESET =>

          r_1_pln_coins <= 5;
          r_2_pln_coins <= 10;
          r_5_pln_coins <= 15;
          r_water <= 10;
          r_milk <= 10;
          r_black_tea <= 10;
          r_green_tea <= 10;
          r_yellow_tea <= 10;
          r_coffee <= 10;
          r_sugar <= 10;

          state <= ZERO;

        when ZERO =>

			 hex_state_int <= "0000";
			 hex_price_int <= "0000";
			 hex_rest_int <= "0000";
          order <= NOTHING;
          sugar <= 0;
			 one_pln_coin <= 0;
			 two_pln_coin <= 0;
			 five_pln_coin <= 0;
			 ch_1_coin := 0;
			 ch_2_coin := 0;
			 ch_5_coin := 0;
			 counter := 0;
			 account_balance <= 0;
			 
          if start = '1' then
            state <= WAITING_FOR_PAYMENT;
				hex_state_int <= "0010";
          end if;

        when WAITING_FOR_PAYMENT =>
			  
			  case inserted_coin is
             when 1 =>
               one_pln_coin <= one_pln_coin + 1;
               account_balance <= account_balance + 1;
             when 2 =>
               two_pln_coin <= two_pln_coin + 1;
               account_balance <= account_balance + 2;
             when 5 =>
               five_pln_coin <= five_pln_coin + 1;
               account_balance <= account_balance + 5;
             when others => null;
           end case;
           inserted_coin <= 0;
		  
		  
          if (product /= "UUUUU") then
            state <= READY_TO_PICK;
				hex_state_int <= "0011";
			 end if;

        when READY_TO_PICK =>

          case product(4 downto 2) is

            when "000" =>
              order <= NOTHING;
				  hex_price_int <= "0000";
            when "001" =>
              order <= GREEN_TEA;
				  hex_price_int <= "1000";
            when "010" =>
              order <= BLACK_TEA;
				  hex_price_int <= "1000";
            when "011" =>
              order <= YELLOW_TEA;
				  hex_price_int <= "1000";
            when "100" =>
              order <= CAPPUCCINO;
				  hex_price_int <= "1010";
            when "101" =>
              order <= CAFFEE_LATTE;
				  hex_price_int <= "1011";
            when "110" =>
              order <= AMERICANO;
				  hex_price_int <= "1011";
            when "111" =>
              order <= ESPRESSO;
				  hex_price_int <= "1011";
            when others =>
              order <= NOTHING;
				  hex_price_int <= "0000";

          end case;

          case product(1 downto 0) is

            when "00" =>
              sugar <= 0;
            when "01" =>
              sugar <= 1;
            when "10" =>
              sugar <= 2;
            when "11" =>
              sugar <= 3;
            when others =>
              sugar <= 0;

          end case;
          state <= HANDLING_PAYMENT;
   			  hex_state_int <= "0100";

        when HANDLING_PAYMENT =>
		  
          if account_balance = order.price then
            account_balance <= account_balance - order.price;
            state <= PREPARING_PRODUCT;
    				hex_state_int <= "0101";

          elsif account_balance > order.price then
            change := account_balance - order.price;
            change_tmp := 0;

            loop_iterator := 0;
            while (change_tmp /= change and r_5_pln_coins - ch_5_coin > 0 and change - change_tmp >= 5) loop
              if loop_iterator = 10 then
                exit;
              end if;
              change_tmp := change_tmp + 5;
              ch_5_coin := ch_5_coin + 1;
              loop_iterator := loop_iterator + 1;
            end loop;

            loop_iterator := 0;
            while (change_tmp /= change and r_2_pln_coins - ch_2_coin > 0 and change - change_tmp >= 2) loop
              if loop_iterator = 10 then
                exit;
              end if;
              change_tmp := change_tmp + 2;
              ch_2_coin := ch_2_coin + 1;
              loop_iterator := loop_iterator + 1;
            end loop;

            loop_iterator := 0;
            while (change_tmp /= change and r_1_pln_coins - ch_1_coin > 0 and change - change_tmp >= 1) loop
              if loop_iterator = 10 then
                exit;
              end if;
              change_tmp := change_tmp + 1;
              ch_1_coin := ch_1_coin + 1;
              loop_iterator := loop_iterator + 1;
            end loop;
				

            if change = change_tmp then
              state <= PREPARING_PRODUCT;
    				  hex_state_int <= "0101";
					  
				  if change_tmp = 0 then
						hex_rest_int <= "0000";
				  elsif change_tmp = 1 then
						hex_rest_int <= "0111";
				  elsif change_tmp = 2 then
						hex_rest_int <= "1000";
				  elsif change_tmp = 3 then
						hex_rest_int <= "1001";
				  elsif change_tmp = 4 then
						hex_rest_int <= "1010";
				  elsif change_tmp = 5 then
						hex_rest_int <= "1011";
				  elsif change_tmp = 6 then
						hex_rest_int <= "1100";
				  elsif change_tmp = 7 then
						hex_rest_int <= "1101";
				  elsif change_tmp = 8 then
						hex_rest_int <= "1110";
				  elsif change_tmp = 9 then
						hex_rest_int <= "1111";	
				  end if;
						
            else
              state <= ACCIDENT;
			  	  hex_state_int <= "0001";
				  hex_price_int <= "0000";
				  hex_rest_int <= "0000";
            end if;

          else
            state <= ACCIDENT;
				hex_state_int <= "0001";
				hex_price_int <= "0000";
			   hex_rest_int <= "0000";
          end if;

        when PREPARING_PRODUCT =>
          serving_error := '0';
          if counter = 5 then

            if(
				  order /= NOTHING and
              r_water >= order.recipe.water and
              r_milk >= order.recipe.milk and
              r_black_tea >= order.recipe.black_tea and
              r_green_tea >= order.recipe.green_tea and
              r_yellow_tea >= order.recipe.yellow_tea and
              r_coffee >= order.recipe.coffee and
              r_sugar >= sugar              
              ) then
                r_water <= r_water - order.recipe.water;
                r_milk <= r_milk - order.recipe.milk;
                r_black_tea <= r_black_tea - order.recipe.black_tea;
                r_green_tea <= r_green_tea - order.recipe.green_tea;
                r_yellow_tea <= r_yellow_tea - order.recipe.yellow_tea;
                r_sugar <= r_sugar - sugar;
            else
              serving_error := '1';
            end if;
              

            if serving_error = '0' then
              state <= SERVING_DRINK;
              hex_state_int <= "0110";
				  r_5_pln_coins <= r_5_pln_coins - ch_5_coin + five_pln_coin;
				  r_2_pln_coins <= r_2_pln_coins - ch_2_coin + two_pln_coin;
				  r_1_pln_coins <= r_1_pln_coins - ch_1_coin + one_pln_coin;
            else
              state <= ACCIDENT;
				  hex_state_int <= "0001";
				  hex_price_int <= "0000";
				  hex_rest_int <= "0000";
            end if;

          else
            counter := counter + 1;
          end if;

        when SERVING_DRINK =>
          state <= ZERO;
			 hex_state_int <= "0000";
			 hex_price_int <= "0000";
			 hex_rest_int <= "0000";

        when others =>
          state <= ZERO;
			 hex_state_int <= "0000";

      end case;
    end if;
  end process;
end a;