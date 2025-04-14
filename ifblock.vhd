

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 use ieee.std_logic_unsigned.all;


entity ifblock is
    Port (jump : in STD_LOGIC;--signal for jumping
        pcsrc: in std_logic; --signal for branch equal
        pcsrc2: in std_logic;--signal for branch not equal
        jaddress: in std_logic_vector (15 downto 0);
       beqaddress: in std_logic_vector(15 downto 0);
        bneaddress: in std_logic_vector(15 downto 0);
        rst: in std_logic;
        clk: in std_logic;
        enable: in std_logic;
       instr: out std_logic_vector(15 downto 0);--output instruction from the rom memory with instructions
        pcout: out std_logic_vector(15 downto 0)

    );
end ifblock;

architecture Behavioral of ifblock is
signal pcoutput: std_logic_vector(15 downto 0); --output of pc register, without +1
signal inputload: std_logic_vector(15 downto 0); --loaded value for the pc register
type romarray is array (0 to 255) of std_logic_vector(15 downto 0);
signal rom: romarray:= (0=>x"208a",
                        1=>x"210b",
                        2=>x"0530",
                        3=>x"01ca",
                        4=>x"0253",
                        5=>x"6682",---typed 2 at the end instead of 4
                        6=>x"4702",
                        7=>x"ca06",
                        8=>x"2106",
                        9=>x"0621",
                        10=>x"a501",
                        11=>x"208a",--jump, not gotten
                        12=>x"8501",
                        13=>x"08b0", 
                        14=>x"01bb",
                         15=>x"0e37",
                         16=>x"15b6",
                         17=>x"0e34",
                         18=>x"0d25",
                         others=>x"e000" );

signal mux1out,mux2out,mux3out: std_logic_vector(15 downto 0);
signal pcouttemp:std_logic_vector(15 downto 0); --signal used in the first mux between beq and pcoutput+1


begin
 
pcreg:process(clk, rst, enable,inputload)--here input rst, enable, instead of rstin, enablein
begin
if rst='1' then
pcoutput<=x"0000";
end if;
if rising_edge(clk) then
if enable='1' then
pcoutput<=inputload;
end if;
end if;
end process pcreg; 


rommem:process(pcoutput)
begin
instr<=rom(conv_integer(pcoutput(7 downto 0)) );
end process rommem;




pcout<=pcoutput+x"0001";--output of block
pcouttemp<=pcoutput+x"0001";

mux1beq:process(pcsrc,beqaddress, pcouttemp)
begin
if pcsrc='0' then
mux1out<=pcouttemp;
else
mux1out<=beqaddress;
end if;
end process mux1beq;

mux1bne:process(pcsrc2,bneaddress, mux1out)
begin
if pcsrc2='0' then
mux2out<=mux1out;
else
mux2out<=bneaddress;
end if;
end process mux1bne;

mux1j:process(jump,jaddress, mux2out)
begin
if jump='0' then
mux3out<=mux2out;
else
mux3out<=jaddress;
end if;
end process mux1j;
 
 inputload<=mux3out;--output of last mux is the input for the pc register
 
 
 
 


end Behavioral;
