

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
  use ieee.std_logic_unsigned.all;


entity mpg is
 Port (btn: in std_logic;
        clk: in std_logic;
        enable: out std_logic );
end mpg;

architecture Behavioral of mpg is
signal count:std_logic_vector(15 downto 0):=x"0000";
signal enableinterm: std_logic:='0';
signal q1,q2,q3: std_logic:='0';

begin
counter161: process(clk)
begin
if clk'event and clk='1' then
count<=count+1;
if count= x"ffff" then
enableinterm<='1';
count<=x"0000";
else
enableinterm<='0';
end if;
end if;
end process counter161;


d1: process(clk,btn)
begin
if clk'event and clk='1' then
if enableinterm='1' then
    q1<=btn;
end if;
end if;
end process d1;


d2: process(clk)
begin
if clk'event and clk='1' then
q2<=q1;
end if;
end process d2;


d3: process(clk)
begin
if clk'event and clk='1' then
q3<=q2;
end if;
end process d3;


enable<=not q3 and q2;


end Behavioral;
