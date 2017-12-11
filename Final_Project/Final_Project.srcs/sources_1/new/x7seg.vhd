----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2017 04:55:17 PM
-- Design Name: 
-- Module Name: x7seg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity x7seg is
	port (
	        x7: in STD_LOGIC_VECTOR(31 downto 0);
            CLK : in STD_LOGIC;
            A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
            AN : out STD_LOGIC_VECTOR(7 downto 0);
            DP : out STD_LOGIC
	 );
end	 x7seg;

architecture x7seg of x7seg is

signal s: STD_LOGIC_VECTOR(2 downto 0);
signal digit: STD_LOGIC_VECTOR(3 downto 0);
signal clkdiv: STD_LOGIC_VECTOR(19 downto 0);
signal aen : std_logic_vector(7 downto 0);
begin
    s <= clkdiv(19 downto 17);	
    aen <= "11111111";
	DP <= '1';
	
	process(s, x7)
	begin
		case s is
		when "000" => digit <= x7(3 downto 0);
		when "001" => digit <= x7(7 downto 4);
		when "010" => digit <= x7(11 downto 8);
		when "011" => digit <= x7(15 downto 12);		
		when "100" => digit <= x7(19 downto 16);
		when "101" => digit <= x7(23 downto 20);	
		when "110" => digit <= x7(27 downto 24);	
		when others => digit <= x7(31 downto 28);				
		end case;
	end process;
	
	-- Decoder7-segment decoder: hex7seg
	process(digit)
	begin
	   case digit is
		   when X"0" => A_TO_G <= "0000001";	 --0
		   when X"1" => A_TO_G <= "1001111";	 --1
		   when X"2" => A_TO_G <= "0010010";	 --2
		   when X"3" => A_TO_G <= "0000110";	 --3
		   when X"4" => A_TO_G <= "1001100";	 --4
		   when X"5" => A_TO_G <= "0100100";	 --5
		   when X"6" => A_TO_G <= "0100000";	 --6
		   when X"7" => A_TO_G <= "0001101";	 --7
		   when X"8" => A_TO_G <= "0000000";	 --8
		   when X"9" => A_TO_G <= "0000100";	 --9
	   end case;
	end process;

    -- Select a 7-seg display based on s
    process(s, aen)
    begin
        AN <= "11111111";
        if aen(conv_integer(s)) = '1' then
        AN(conv_integer(s)) <= '0';
        end if;
    end process;
    
-- Clock divider
    process(clk)
    begin
        if clk'event and clk = '1' then
            clkdiv <= clkdiv +1;
        end if;
    end process;
end x7seg;