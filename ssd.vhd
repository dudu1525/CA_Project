

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;

entity ssd is
    Port ( digit : in STD_LOGIC_vector(15 downto 0);
        clk:in std_logic;
        cat: out std_logic_vector(0 to 6);
        an:out std_logic_vector(3 downto 0)   );
end ssd;
    
architecture Behavioral of ssd is
    signal count:std_logic_vector(15 downto 0);
    signal auxcount:std_logic_vector(1 downto 0);
    
    signal outmux1:std_logic_vector(3 downto 0);
 
    
begin

p1: process(clk)
begin
if clk'event and clk='1' then
count<=count+1;
end if;
if count= x"ffff" then
count<=x"0000";
end if;
end process;

auxcount<=count(15 downto 14);

p2mux: process(auxcount, digit)
        begin
    case auxcount is
    when "00" => outmux1<=digit(3 downto 0);
    when "01" => outmux1<=digit(7 downto 4);
    when "10" => outmux1<=digit(11 downto 8);
    when others => outmux1<=digit(15 downto 12);
    end case;
end process;

p3mux: process(auxcount)
begin
case auxcount is
    when "00" => an<="1110";
    when "01" => an<="1101";
    when "10" => an<="1011";
    when others => an<="0111";
    end case;
end process;

p4decoder: process (outmux1)
BEGIN
    case outmux1 is
        when "0000"=> cat <="0000001";  -- '0'
        when "0001"=> cat <="1001111";  -- '1'
        when "0010"=> cat <="0010010";  -- '2'
        when "0011"=> cat <="0000110";  -- '3'
        when "0100"=> cat <="1001100";  -- '4' 
        when "0101"=> cat <="0100100";  -- '5'
        when "0110"=> cat <="0100000";  -- '6'
        when "0111"=> cat <="0001111";  -- '7'
        when "1000"=> cat <="0000000";  -- '8'
        when "1001"=> cat <="0000100";  -- '9'
        when "1010"=> cat <="0001000";  -- 'A'
        when "1011"=> cat <="1100000";  -- 'b'
        when "1100"=> cat <="0110001";  -- 'C'
        when "1101"=> cat <="1000010";  -- 'd'
        when "1110"=> cat <="0110000";  -- 'E'
        when "1111"=> cat <="0111000";  -- 'F'
        when others =>  NULL;
    end case;
end process;

end Behavioral;
