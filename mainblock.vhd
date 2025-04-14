

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mainblock is
    Port ( instr: in STD_LOGIC_vector(2 downto 0);
            RegDst: out std_logic;
            ExtOp: out std_logic;
             bne: out std_logic;
              bqe: out std_logic;
               j: out std_logic;
               MemWrite: out std_logic;
               MemtoReg: out std_logic;
               RegWrite:out std_logic;
               AluOp:out std_logic_vector(2 downto 0);
               AluSrc: out std_logic
            
    );
end mainblock;

architecture Behavioral of mainblock is

begin

process(instr)
begin
case instr is
when "000" =>
RegDst<='1';
RegWrite<='1';
ExtOp<='1';
AluSrc<='0';
MemWrite<='0';
MemtoReg<='0';
AluOp<=instr;
bne<='0';
bqe<='0';
j<='0';

when "001" =>
RegDst<='0';
ExtOp<='0';
RegWrite<='1';
AluSrc<='1';
MemWrite<='0';
MemtoReg<='0';
AluOp<=instr;
bne<='0';
bqe<='0';
j<='0';

when "010" =>
RegDst<='0';
RegWrite<='1';
ExtOp<='0';
AluSrc<='1';
MemWrite<='0';
MemtoReg<='1';
AluOp<=instr;
bne<='0';
bqe<='0';
j<='0';

when "011" =>
RegDst<='0';
RegWrite<='0';
AluSrc<='1';
ExtOp<='0';
MemWrite<='1';
MemtoReg<='0';
AluOp<=instr;
bne<='0';
bqe<='0';
j<='0';

when "100" =>
RegDst<='0';
RegWrite<='0';
AluSrc<='0';
ExtOp<='0';
MemWrite<='0';
MemtoReg<='0';
AluOp<=instr;
bne<='0';
bqe<='1';
j<='0';

when "101" =>

RegDst<='0';
RegWrite<='0';
AluSrc<='0';
ExtOp<='0';
MemWrite<='0';
MemtoReg<='0';
AluOp<=instr;
bne<='1';
bqe<='0';
j<='0';
when "110" =>

RegDst<='0';
RegWrite<='1';
AluSrc<='1';
ExtOp<='0';
MemWrite<='0';
MemtoReg<='0';
AluOp<=instr;
bne<='0';
bqe<='0';
j<='0';

when others =>  --111 case
RegDst<='0';
RegWrite<='0';
AluSrc<='0';
ExtOp<='0';
MemWrite<='0';
MemtoReg<='0';
AluOp<=instr;
bne<='0';
bqe<='0';
j<='1';
end case;
end process;
end Behavioral;
