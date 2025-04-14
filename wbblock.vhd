

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wbblock is
    Port ( MemtoReg : in STD_LOGIC;
        Alures: in std_logic_vector(15 downto 0);
        ramdata: in std_logic_vector(15 downto 0);
    
    finaldataout: out std_logic_vector(15 downto 0)
    );
end wbblock;

architecture Behavioral of wbblock is

begin
writeback: process(MemtoReg, Alures,ramdata)
begin
if MemtoReg='1' then
finaldataout<=Alures;
else
finaldataout<=ramdata;
end if;
end process;


end Behavioral;
