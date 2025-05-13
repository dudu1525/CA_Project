

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 use ieee.std_logic_unsigned.all;

--modifica branch urile, vezi daca regwrite e bine de la ultimul registru din ala,
--ceva la alu nu e ok, face suma dintre a si 1, apoi dintre b si 1, ceva reg file nu e bun

entity topmodule is
  Port ( clk: in std_logic;
         choice: in std_logic_vector(2 downto 0);
           rst: in std_logic;
           enable: in std_logic;
           saout: out std_logic;
           an: out std_logic_vector(3 downto 0);
           cat:out std_logic_vector(0 to 6)
  
  
  );
end topmodule;

architecture Behavioral of topmodule is
component mainblock is
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
end component mainblock;

component ssd is
    Port ( digit : in STD_LOGIC_vector(15 downto 0);
        clk:in std_logic;
        cat: out std_logic_vector(0 to 6);
        an:out std_logic_vector(3 downto 0)   );
end component ssd;
component mpg is
 Port (btn: in std_logic;
        clk: in std_logic;
        enable: out std_logic );
end component mpg;

component ifblock is
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
end component ifblock;

component idblock is
    Port ( RegWrite : in STD_LOGIC;
            Instr:in std_logic_vector(15 downto 0);
            RegDst: in std_logic;
             wa: in std_logic_vector(2 downto 0);--write address
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
end component idblock;

component executionblock is
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
end component executionblock;

component memoryblock is
    Port ( MemWrite : in STD_LOGIC;
            Alures: in std_logic_vector(15 downto 0);
            rd2: in std_logic_vector(15 downto 0);
            clk: in std_logic;
            MemtoReg: in std_logic;
            MemData: out std_logic_vector(15 downto 0);
            Aluresout: out std_logic_vector(15 downto 0)
          --  finaldataout: out std_logic_vector(15 downto 0)
    
    );
end component memoryblock;

component wbblock is
    Port ( MemtoReg : in STD_LOGIC;
        Alures: in std_logic_vector(15 downto 0);
        ramdata: in std_logic_vector(15 downto 0);
    
    finaldataout: out std_logic_vector(15 downto 0)
    );
end component wbblock;
-----------------------------------------------------------------------------------------id block output signals
signal rd1,rd2:std_logic_vector(15 downto 0);
signal func: std_logic_vector(2 downto 0);
signal extimm: std_logic_vector(15 downto 0);
signal sa: std_logic;
-----------------------------------------------------------------------------------------execution unit signals
signal bneaddress: std_logic_vector(15 downto 0);
signal bqeaddress: std_logic_vector(15 downto 0);
signal alures: std_logic_vector(15 downto 0);
signal zeroflag: std_logic:='0';

signal pipelinemuxout: std_logic_vector(2 downto 0);
-----------------------------------------------------------------------------------------memory unit signals
signal finaldatawrite: std_logic_vector(15 downto 0);
signal finalbqeenable, finalbneenable: std_logic:='0';
-----------------------------------------------------------------------------------------main component output signals
signal regdst,extop,bne,bqe,j,memwrite,memtoreg,regwrite,alusrc: std_logic;
signal aluop: std_logic_vector(2 downto 0);

-----------------------------------------------------------------------------------------ifblock component output signals
signal instr,pcout: std_logic_vector(15 downto 0);
signal jaddress: std_logic_vector(15 downto 0);

------------------------------------------------------------------------------------------write back block
signal aluresout, memout: std_logic_vector(15 downto 0);

------------------------------------------------------------------------------------------input, buttons, switches testing signals
signal rstout, enableout:std_logic;


signal ssddisplay: std_logic_vector(15 downto 0);
--signal waddressmock: std_logic_vector(15 downto 0):=x"0001";
--signal writedatamock: std_logic_vector(15 downto 0):=x"0010";
signal enablewritemock,enablewritemockout: std_logic;
--------------------------------------------------------------------------------------------------------------pipeline registers
signal ifid: std_logic_vector(31 downto 0):=x"00000000";
signal idex: std_logic_vector(89 downto 0):=x"0000000000000000000000"&"00";--10main, 16 pc+1, 16rd1,16rd2, 16ext, 16 for instr
signal exmem: std_logic_vector(72 downto 0):=x"000000000000000000"&'0';
signal memwb: std_logic_vector(36 downto 0):=x"000000000"&'0';

-----------------------------------------------------------------------------------------------------
begin

p1: mainblock port map(ifid(15 downto 13), regdst,extop, bne,bqe,j, memwrite,memtoreg,regwrite,aluop,alusrc); --modified instr with ifid

p11: ifblock port map(j,finalbqeenable,finalbneenable, jaddress,  exmem(51 downto 36),exmem(72 downto 57),  rstout, clk, enableout,   instr, pcout);--modify bqe and bne addresses

p111: idblock port map(memwb(35), ifid(15 downto 0), regdst,  memwb(2 downto 0)   , extop,finaldatawrite,clk,rd1,rd2,extimm,func,sa, '1');

p1111: executionblock port map(idex(79 downto 64), idex(63  downto 48),idex(47 downto 32),idex(31 downto 16), idex(2 downto 0),idex(3),idex(81),idex(84 downto 82),   bqeaddress, bneaddress, alures, zeroflag   , pipelinemuxout  ,idex(15 downto 0) , idex(80)  );

p11111: memoryblock port map( exmem(54) ,exmem(34 downto 19),exmem(18 downto 3),clk, memtoreg, memout, aluresout  );

p12: wbblock port map( memwb(36), memwb(34 downto 19), memwb(18 downto 3), finaldatawrite);


finalbqeenable<= exmem(52) and exmem(35);
finalbneenable<=exmem(53) and not exmem(35);
saout<=sa;

jaddress<="000" & ifid(12 downto 0);--instead of instr, put ifid
IF_ID:process (clk,instr,pcout )
begin
if rising_edge(clk) then
ifid(31 downto 16) <=pcout;
ifid(15 downto 0)<=instr;
end if;
end process IF_ID;


ID_EX:process (clk,ifid,rd1,rd2,extimm )
begin
if rising_edge(clk) then
idex(15 downto 0)<=ifid(15 downto 0);
idex(31 downto 16)<=extimm;
idex(47 downto 32)<=rd2;
idex(63  downto 48)<=rd1;
idex(79 downto 64)<=ifid(31 downto 16);
idex(80)<=regdst;
idex(81)<=alusrc;
idex(84 downto 82)<=aluop;
idex(85)<=bqe;
idex(86)<=bne;
idex(87)<=memwrite;
idex(88)<=regwrite;
idex(89)<=memtoreg;
end if;
end process ID_EX;

EX_MEM:process (clk,exmem, idex, pipelinemuxout,zeroflag,alures,bqeaddress,bneaddress)
begin
if rising_edge(clk) then
exmem(2 downto 0)<=pipelinemuxout;
exmem(18 downto 3)<=idex(47 downto 32);
exmem(34 downto 19)<=alures;
exmem(35)<=zeroflag;
exmem(51 downto 36)<=bqeaddress;
exmem(54 downto 52)<=idex(87 downto 85);
exmem(56 downto 55)<=idex(89 downto 88);
exmem(72 downto 57)<=bneaddress;
end if;
end process EX_MEM;


MEM_WB:process (clk,memwb,exmem,memout)
begin
if rising_edge(clk) then
memwb(2 downto 0)<=exmem(2 downto 0);
memwb(18 downto 3)<=exmem(34 downto 19);
memwb(34 downto 19)<=memout;
memwb(36 downto 35)<=exmem(56 downto 55);
end if;
end process MEM_WB;




p2: mpg port  map(rst, clk, rstout);
p3: mpg port  map(enable, clk, enableout);
p5: mpg port map(enablewritemock, clk, enablewritemockout);
p4: ssd port map(ssddisplay, clk, cat,an);


testing: process(choice, rd1,rd2)
begin
if choice="000" then
ssddisplay<=instr;
elsif choice="001" then
ssddisplay<=rd1;
elsif choice="010" then
ssddisplay<=rd2;
elsif choice="011" then
ssddisplay<=exmem(34 downto 19);--alu re
elsif choice="100" then
ssddisplay<=extimm;
elsif choice="101" then
ssddisplay<=pcout;
elsif choice="110" then
ssddisplay<=memout;
else
ssddisplay<=finaldatawrite;
end if;
end process;

end Behavioral;
