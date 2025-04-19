library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util_pack.all;

package psr_pack is
  type t_psr is record
    z : std_ulogic; -- zero
    n : std_ulogic; -- negative
    v : std_ulogic; -- overflow
    c : std_ulogic; -- carry
    i : std_ulogic; -- interrupt mask
    t : std_ulogic; -- trap mask
    s : std_ulogic; -- system mode
    p : std_ulogic; -- privileged mode
  end record t_psr;

  constant INIT_PSR : t_psr := (
    z => '0', n => '0', v => '0', c => '0',
    i => '1', t => '1', s => '1', p => '1'
  );

  type t_psr_array is array (integer range <>) of t_psr;
  type t_psr_pair is record
    banks : t_psr_array(1 downto 0);
    p : std_ulogic;
    s : std_ulogic;
  end record;

  constant INIT_PSR_PAIR : t_psr_pair := (
    banks => (others => INIT_PSR),
    s => '1',
    p => '1'
  );

  function psr_from_word(word : std_ulogic_vector(31 downto 0)) return t_psr;
  function word_from_psr(psr : t_psr) return std_ulogic_vector;

  function psr_read(psr_pair : t_psr_pair) return std_ulogic_vector;

  procedure psr_reset(
    signal i_clk       : in std_ulogic;
    signal io_psr_pair : inout t_psr_pair
  );
  procedure psr_set_bits(
    signal i_clk       : in std_ulogic;
    signal io_psr_pair : inout t_psr_pair;
    signal i_mask      : in std_ulogic_vector(31 downto 0)
  );
  procedure psr_clear_bits(
    signal i_clk       : in std_ulogic;
    signal io_psr_pair : inout t_psr_pair;
    signal i_mask      : in  std_ulogic_vector(31 downto 0)
  );
  procedure psr_exception(
    signal i_clk       : in std_ulogic;
    signal io_psr_pair : inout t_psr_pair
  );

end package psr_pack;

package body psr_pack is
  function psr_from_word(word : std_ulogic_vector(31 downto 0)) return t_psr is
    variable psr : t_psr;
  begin
    psr.z := word(0);
    psr.n := word(1);
    psr.v := word(2);
    psr.c := word(3);
    psr.i := word(4);
    psr.t := word(5);
    psr.s := word(6);
    psr.p := word(7);
    return psr;
  end function psr_from_word;

  function word_from_psr(psr : t_psr) return std_ulogic_vector is
    variable word : std_ulogic_vector(31 downto 0);
  begin
    word := X"00000000";
    word(0) := psr.z;
    word(1) := psr.n;
    word(2) := psr.v;
    word(3) := psr.c;
    word(4) := psr.i;
    word(5) := psr.t;
    word(6) := psr.s;
    word(7) := psr.p;
    return word;
  end function word_from_psr;

  function psr_read(psr_pair : t_psr_pair) return std_ulogic_vector is
    variable bank : natural := to_integer(unsigned(to_slv(psr_pair.s)));
    variable psr  : t_psr;
  begin
    psr.z := psr_pair.banks(bank).z;
    psr.n := psr_pair.banks(bank).n;
    psr.v := psr_pair.banks(bank).v;
    psr.c := psr_pair.banks(bank).c;
    psr.i := psr_pair.banks(bank).i;
    psr.t := psr_pair.banks(bank).t;
    psr.s := psr_pair.s;
    psr.p := psr_pair.p;
    return word_from_psr(psr);
  end function psr_read;

  procedure psr_reset(
    signal i_clk       : in std_ulogic;
    signal io_psr_pair : inout t_psr_pair
  ) is begin
    if rising_edge(i_clk) then
      for i in io_psr_pair.banks'range loop
        io_psr_pair.banks(i).z <= '0';
        io_psr_pair.banks(i).n <= '0';
        io_psr_pair.banks(i).v <= '0';
        io_psr_pair.banks(i).c <= '0';
        io_psr_pair.banks(i).i <= '1';
        if i /= 1 then
          io_psr_pair.banks(i).t <= '1';
        end if;
      end loop;
      io_psr_pair.s <= '1';
      io_psr_pair.p <= '1';
    end if;
    -- coherency of S and P bits between both banks
    for i in io_psr_pair.banks'range loop
      io_psr_pair.banks(i).s <= io_psr_pair.s;
      io_psr_pair.banks(i).p <= io_psr_pair.p;
    end loop;
    -- supervisor T bit is hardcoded to '1'
    io_psr_pair.banks(1).t <= '1';
  end procedure psr_reset;

  procedure psr_set_bits(
    signal i_clk       : in std_ulogic;
    signal io_psr_pair : inout t_psr_pair;
    signal i_mask      : in std_ulogic_vector(31 downto 0)
  ) is
    variable bank : natural := to_integer(unsigned(to_slv(io_psr_pair.s)));
    variable psr  : t_psr := psr_from_word(i_mask);
  begin
    if rising_edge(i_clk) then
      if io_psr_pair.p then -- supervisor/system mode
        io_psr_pair.banks(bank).z <= io_psr_pair.banks(bank).z or psr.z;
        io_psr_pair.banks(bank).n <= io_psr_pair.banks(bank).n or psr.n;
        io_psr_pair.banks(bank).v <= io_psr_pair.banks(bank).v or psr.v;
        io_psr_pair.banks(bank).c <= io_psr_pair.banks(bank).c or psr.c;
        io_psr_pair.banks(bank).i <= io_psr_pair.banks(bank).i or psr.i;
        if bank /= 1 then -- supervisor/system T bit is hardcoded
          io_psr_pair.banks(bank).t <= io_psr_pair.banks(bank).t or psr.t;
        end if;
        io_psr_pair.s <= io_psr_pair.s or psr.s;
      else -- user mode
        io_psr_pair.banks(bank).z <= io_psr_pair.banks(bank).z or psr.z;
        io_psr_pair.banks(bank).n <= io_psr_pair.banks(bank).n or psr.n;
        io_psr_pair.banks(bank).v <= io_psr_pair.banks(bank).v or psr.v;
        io_psr_pair.banks(bank).c <= io_psr_pair.banks(bank).c or psr.c;
      end if;
    end if;
    -- coherency of S and P bits between both banks
    for i in io_psr_pair.banks'range loop
      io_psr_pair.banks(i).s <= io_psr_pair.s;
      io_psr_pair.banks(i).p <= io_psr_pair.p;
    end loop;
    -- supervisor T bit is hardcoded to '1'
    io_psr_pair.banks(1).t <= '1';
  end procedure psr_set_bits;

  procedure psr_clear_bits(
    signal i_clk       : in std_ulogic;
    signal io_psr_pair : inout t_psr_pair;
    signal i_mask      : in  std_ulogic_vector(31 downto 0)
  ) is
    variable bank : natural := to_integer(unsigned(to_slv(io_psr_pair.s)));
    variable psr  : t_psr := psr_from_word(i_mask);
  begin
    if rising_edge(i_clk) then
      if io_psr_pair.p then -- supervisor/system mode
        io_psr_pair.banks(bank).z <= io_psr_pair.banks(bank).z and not psr.z;
        io_psr_pair.banks(bank).n <= io_psr_pair.banks(bank).n and not psr.n;
        io_psr_pair.banks(bank).v <= io_psr_pair.banks(bank).v and not psr.v;
        io_psr_pair.banks(bank).c <= io_psr_pair.banks(bank).c and not psr.c;
        io_psr_pair.banks(bank).i <= io_psr_pair.banks(bank).i and not psr.i;
        if bank /= 1 then -- supervisor T bit is hardcoded
          io_psr_pair.banks(bank).t <= io_psr_pair.banks(bank).t and not psr.t;
        end if;
        io_psr_pair.s <= io_psr_pair.s and not (psr.s or psr.p);
        io_psr_pair.p <= io_psr_pair.p and not psr.p;
      else -- user mode
        io_psr_pair.banks(bank).z <= io_psr_pair.banks(bank).z and not psr.z;
        io_psr_pair.banks(bank).n <= io_psr_pair.banks(bank).n and not psr.n;
        io_psr_pair.banks(bank).v <= io_psr_pair.banks(bank).v and not psr.v;
        io_psr_pair.banks(bank).c <= io_psr_pair.banks(bank).c and not psr.c;
      end if;
    end if;
    -- coherency of S and P bits between both banks
    for i in io_psr_pair.banks'range loop
      io_psr_pair.banks(i).s <= io_psr_pair.s;
      io_psr_pair.banks(i).p <= io_psr_pair.p;
    end loop;
    -- supervisor T bit is hardcoded to '1'
    io_psr_pair.banks(1).t <= '1';
  end procedure psr_clear_bits;

  procedure psr_exception(
    signal i_clk       : in std_ulogic;
    signal io_psr_pair : inout t_psr_pair
  ) is begin
    if rising_edge(i_clk) then
      io_psr_pair.banks(0).i <= '1';
      io_psr_pair.banks(0).t <= '1';
      io_psr_pair.banks(1).i <= '1';
      io_psr_pair.s <= '1';
      io_psr_pair.p <= '1';
    end if;
    -- coherency of S and P bits between both banks
    for i in io_psr_pair.banks'range loop
      io_psr_pair.banks(i).s <= io_psr_pair.s;
      io_psr_pair.banks(i).p <= io_psr_pair.p;
    end loop;
    -- supervisor/system T bit is hardcoded to '1'
    io_psr_pair.banks(1).t <= '1';
  end procedure psr_exception;

end package body psr_pack;
