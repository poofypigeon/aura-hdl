library ieee;
use ieee.std_logic_1164.all;

entity core is
  port (
    i_clk            : in  std_ulogic;
    i_reset          : in  std_ulogic;

    o_privileged     : out std_ulogic;

    -- instruction fetch signals
    o_if_vaddress    : out std_ulogic(31 downto 0);
    o_if_strobe      : out std_logic;
    i_if_instruction : in  std_ulogic(31 downto 0);
    i_if_stall       : in  std_ulogic;
    i_if_bus_fault   : in  std_ulogic;
   
    -- memory access signals
    o_mem_vaddress   : out std_ulogic(31 downto 0);
    o_mem_cstrobe    : out std_ulogic( 3 downto 0);
    o_mem_rw         : out std_ulogic; -- read='1', write='0'
    o_mem_data       : out std_ulogic(31 downto 0);
    i_mem_data       : in  std_ulogic(31 downto 0);
    i_mem_stall      : in  std_ulogic;
    i_mem_bus_fault  : in  std_ulogic;
  
    i_irq_control    : in  std_ulogic_vector(2 downto 0)
  );
end entity core;

architecture arch of core is
begin
end arch;
