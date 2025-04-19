library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity barrel_shifter is
  port (
    i_data       : in  std_ulogic_vector(31 downto 0);
    i_carry      : in  std_ulogic;
    i_shift      : in  std_ulogic_vector( 7 downto 0);
    i_direction  : in  std_ulogic; -- right='1', left='0'
    i_arithmetic : in  std_ulogic; 

    o_data       : out std_ulogic_vector(31 downto 0);
    o_carry      : out std_ulogic
  );
end entity barrel_shifter;

architecture arch of barrel_shifter is
begin
  process (all)
    variable shift : natural;
  begin
    shift := to_integer(unsigned(i_shift));

    if shift = 0 then
      o_carry <= i_carry;
      o_data <= i_data;
    else
      if i_direction = '1' then -- right shift
        if shift > 32 then
          o_carry <= i_arithmetic and i_data(31);
        else
          o_carry <= i_data(shift - 1);
        end if;
        if i_arithmetic then
          o_data <= std_ulogic_vector(signed(i_data) srl shift);
        else
          o_data <= i_data srl shift;
        end if;
      else -- left shift
        if shift > 32 then
          o_carry <= '0';
        else
          o_carry <= i_data(32 - shift);
        end if;
        o_data <= i_data sll shift;
      end if;
    end if;
  end process;
end arch;
