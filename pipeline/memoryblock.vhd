

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
  use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memoryblock is
    Port ( MemWrite : in STD_LOGIC;
            Alures: in std_logic_vector(15 downto 0);
            rd2: in std_logic_vector(15 downto 0);
            clk: in std_logic;
            MemtoReg: in std_logic;
            MemData: out std_logic_vector(15 downto 0);
            Aluresout: out std_logic_vector(15 downto 0)
          --  finaldataout: out std_logic_vector(15 downto 0)
    
    );
end memoryblock;

architecture Behavioral of memoryblock is
signal ramdata: std_logic_vector(15 downto 0);
type ram_type is array (0 to 63) of std_logic_vector(15 downto 0);
signal RAM : ram_type:=(0=>x"0000",
                        1=>x"0001",
                        2=>x"0002",
                        3=>x"0003",
                        4=>x"0004",
                        5=>x"0005",
                        6=>x"0006",
                        7=>x"0007",
                        8=>x"0008",
                        9=>x"0009",
                        10=>x"000a",
                        11=>x"000b",--jump, not gotten
                        12=>x"000c",
                        13=>x"000d", 
                        14=>x"000e",
                         15=>x"000f",
                         16=>x"0010",
                         17=>x"0011",
                         18=>x"0012",
                         others=>x"0013" );
begin


ramblock:process(clk, MemWrite,Alures,rd2)
begin
if (clk'event and clk = '1') then
if (MemWrite = '1') then
RAM(conv_integer(Alures(5 downto 0) )) <= rd2;
end if;
end if;
end process;
ramdata <= RAM(conv_integer(Alures(5 downto 0) ));

Aluresout<=Alures;
MemData<=ramdata;


end Behavioral;
