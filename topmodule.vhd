

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 use ieee.std_logic_unsigned.all;



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
            zeroflag: out std_logic
    
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
signal zeroflag: std_logic;
-----------------------------------------------------------------------------------------memory unit signals
signal finaldatawrite: std_logic_vector(15 downto 0);
signal finalbqeenable, finalbneenable: std_logic;
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

-----------------------------------------------------------------------------------------------------
begin

p1: mainblock port map(instr(15 downto 13), regdst,extop, bne,bqe,j, memwrite,memtoreg,regwrite,aluop,alusrc);

p11: ifblock port map(j,finalbqeenable,finalbneenable, jaddress,  bqeaddress,bneaddress,  rstout, clk, enableout,   instr, pcout);

p111: idblock port map(regwrite, instr, regdst, extop,finaldatawrite,clk,rd1,rd2,extimm,func,sa, '1');

p1111: executionblock port map(pcout, rd1,rd2,extimm, func,sa,alusrc,aluop,   bqeaddress, bneaddress, alures, zeroflag  );

p11111: memoryblock port map( memwrite,alures,rd2,clk, memtoreg, memout, aluresout  );

p12: wbblock port map( memtoreg, memout, aluresout, finaldatawrite);

jaddress<="000" & instr(12 downto 0);
finalbqeenable<= bqe and zeroflag;
finalbneenable<=bne and not zeroflag;
saout<=sa;
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
ssddisplay<=alures;
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
