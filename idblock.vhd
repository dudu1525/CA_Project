
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 use ieee.std_logic_unsigned.all;


entity idblock is
    Port ( RegWrite : in STD_LOGIC;
            Instr:in std_logic_vector(15 downto 0);
            RegDst: in std_logic;
            ExtOp: in std_logic;
            wd: in std_logic_vector(15 downto 0); --write data input for waddress
            clk:in std_logic;
            rd1: out std_logic_vector(15 downto 0);
            rd2: out std_logic_vector(15 downto 0);
            extimm: out std_logic_vector(15 downto 0);
            func: out std_logic_vector(2 downto 0);
            sa: out std_logic;
            
            --for testing
            enableregfile: in std_logic
    );
end idblock;

architecture Behavioral of idblock is

type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
signal reg_file : reg_array:=
                         (0=>x"0000",
                        1=>x"0001",
                        2=>x"0002",
                        3=>x"0003",
                        4=>x"0004",
                        5=>x"0005",
                        6=>x"0006",
                        7=>x"0007");

signal ra1,ra2,wa:std_logic_vector(2 downto 0); --gotten from instruction on 16 bits
begin

ra1<=Instr(12 downto 10);
ra2<=Instr(9 downto 7);
mux1: process(RegDst,Instr)
begin
if RegDst= '0' then
wa<=Instr(9 downto 7);
else
wa<=Instr(6 downto 4);
end if;
end process;

reg_filep: process(clk,RegWrite,wa,ra1,ra2, enableregfile )
begin
if rising_edge(clk) then
if RegWrite = '1' and enableregfile='1' then
reg_file(conv_integer(wa)) <= wd;
end if;
end if;
rd1 <= reg_file(conv_integer(ra1));
rd2 <= reg_file(conv_integer(ra2));
end process;

ext_unit: process(ExtOp,Instr)
begin
if ExtOp='0' then--zero extend
extimm<= ("000000000" & Instr(6 downto 0));
else
if Instr(6)= '0' then
    extimm<= ("000000000" & Instr(6 downto 0));
    else
    extimm<= ("111111111" & Instr(6 downto 0));
    end if;
end if;
end process;
func<=Instr(2 downto 0);
sa<=Instr(3);

end Behavioral;
