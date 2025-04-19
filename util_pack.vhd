library ieee;
use ieee.std_logic_1164.all;

package util_pack is
  function to_slv(b : std_ulogic) return std_ulogic_vector;
end package util_pack;

package body util_pack is
  function to_slv(b : std_ulogic) return std_ulogic_vector is
    variable v : std_ulogic_vector(0 downto 0) := (0 => b);
  begin
    return v;
  end function to_slv;
end package body util_pack;
