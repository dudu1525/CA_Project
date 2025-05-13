
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
  use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity executionblock is
    Port ( pcin : in STD_LOGIC_vector(15 downto 0);
            rd1: in std_logic_vector(15 downto 0); --rs
            rd2: in std_logic_vector(15 downto 0); --rt
            extimm: in std_logic_vector(15 downto 0);
            func: in std_logic_vector( 2 downto 0);
            sa: in std_logic;
            alusrc:in std_logic; --selects between rd2 and extimm
            aluop: in std_logic_vector(2 downto 0); --from main block
            
            branchaddresseq: out std_logic_vector(15 downto 0);
            branchaddressnqe: out std_logic_vector(15 downto 0);
            alures: out std_logic_vector(15 downto 0);
            zeroflag: out std_logic;
            
            pipelinemuxout:out std_logic_vector(2 downto 0);
            instr: in std_logic_vector(15 downto 0);
            regdst: in std_logic
    
    );
end executionblock;

architecture Behavioral of executionblock is
signal muxout: std_logic_vector(15 downto 0);
signal aluctrlout: std_logic_vector(3 downto 0); --signal input for alu block to output certain operation

signal tmpalures: std_logic_vector(15 downto 0);




begin

muxbetweenaddresses: process(instr, regdst)
begin
if regdst='0' then
pipelinemuxout<=instr(9 downto 7);
else
pipelinemuxout<=instr(6 downto 4);
end if;
end process;


mux1: process(alusrc,rd2,extimm)
begin
if alusrc='0' then
muxout<=rd2; --takes rt
else
muxout<=extimm; --takes extended sign signal
end if;
end process;

alusrcprocess: process(func,aluop)
begin
if aluop="000" then--r type function
    case func is
    when "000" =>aluctrlout<="0000";--add
    when "001" =>aluctrlout<="0001";--substract
    when "010" =>aluctrlout<="0010";--sll
    when "011" =>aluctrlout<="0011";--srl
    when "100" =>aluctrlout<="0100";--and
    when "101" =>aluctrlout<="0101";--or
    when "110" =>aluctrlout<="0110";--xor
    when others =>aluctrlout<="0111";--sllv
    end case;
    
elsif aluop="001" then --addi
aluctrlout<="0000";--add

elsif aluop="010" then --lw
aluctrlout<="0000";--add

elsif aluop="011" then --sw
aluctrlout<="0000";--add

elsif aluop="100" then --bqe
aluctrlout<="0001";--substract

elsif aluop="101" then --bne
aluctrlout<="0001";--substract

else --slti
aluctrlout<="1000";
end if;
end process;


mainaluprocess: process(aluctrlout,muxout,sa,rd1,tmpalures)
begin
case aluctrlout is
when "0000" =>alures<=muxout+rd1;

when "0001" =>alures<=rd1-muxout;
tmpalures<=rd1-muxout;
    if tmpalures=x"0000" then
        zeroflag<='1';
        else
        zeroflag<='0';
        end if;
when "0010" =>
        if sa='0' then
        alures<=muxout;
        else
        alures<=muxout(14 downto 0) & '0';
        end if;
when "0011" =>
if sa='0' then
        alures<=muxout;
        else
        alures<=muxout(15) & muxout(15 downto 1);
        end if;
when "0100" =>
        alures<=muxout and rd1;
when "0101" =>
        alures<=muxout or rd1;
when "0110" =>
        alures<=muxout xor rd1;
when "0111" => --sllv
   alures <= std_logic_vector(shift_left(unsigned(rd1), to_integer(unsigned(muxout))));
when others =>--slti
if muxout < rd1 then
alures<=x"0001";
else
alures<=x"0000";
    end if;
end case;
end process;

--branch not equal and branch equal addresses: (pc+1)+extended
branchaddresseq<=pcin+extimm;
branchaddressnqe<=pcin+extimm;

end Behavioral;
