library ieee;
use ieee.std_logic_1164.all;

entity seven_seg is
port 
    (
        input_hex         : in std_logic_vector(3 downto 0);
        output_hex         : out std_logic_vector(6 downto 0)
    );
end entity;

architecture hex of seven_seg is
begin
with input_hex select
    output_hex <= "0000001" when "0000", -- ZERO 0
						"0001000" when "0001", -- ACCIDENT A
						"1100011" when "0010", -- WAITING_FOR_PAYMENT u
						"1111010" when "0011", -- READY_TO_PICK r
						"1101000" when "0100", -- HANDLING_PAYMENT h
						"0011000" when "0101", -- PREPARING_PRODUCT P
						"0010010" when "0110", -- SERVING_DRINK S
						"1001111" when "0111", -- 1
						"0010010" when "1000", -- 2
						"0000110" when "1001", -- 3
						"1001100" when "1010", -- 4
						"0100100" when "1011", -- 5
						"0100000" when "1100", -- 6
						"0001111" when "1101", -- 7
						"0000000" when "1110", -- 8
						"0000100" when "1111", -- 9
						"1111111" when others; 
end hex;