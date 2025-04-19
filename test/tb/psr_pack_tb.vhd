library ieee;
use ieee.std_logic_1164.all;

use work.psr_pack.all;

entity psr_pack_tb is
end entity psr_pack_tb;

architecture tb of psr_pack_tb is
  signal clk               : std_ulogic := '0';
  signal psr_pair          : t_psr_pair := INIT_PSR_PAIR;
  signal mask              : std_ulogic_vector(31 downto 0);

  type t_psr_action is (RESET, SET_BITS, CLEAR_BITS, EXCEPTION);
  signal psr_action : t_psr_action := RESET;

  procedure pulse_clock(
    signal io_clk : inout std_ulogic
  ) is begin
    wait for 1 ns;
    io_clk <= '1';
    wait for 1 ns;
    io_clk <= '0';
  end procedure pulse_clock;
begin

  process (all) begin
    case psr_action is
      when RESET      => psr_reset(clk, psr_pair);
      when SET_BITS   => psr_set_bits(clk, psr_pair, mask);
      when CLEAR_BITS => psr_clear_bits(clk, psr_pair, mask);
      when EXCEPTION  => psr_exception(clk, psr_pair);
    end case;
  end process;

  process
    variable word : std_ulogic_vector(31 downto 0);
    variable psr  : t_psr;
  begin
    ----------------------------------------------------------------
    -- word_from_psr
    ----------------------------------------------------------------
    word := word_from_psr(INIT_PSR);
    assert word = X"000000F0"
    report "expected 000000F0, got " & to_hstring(word)
    severity failure;

    ----------------------------------------------------------------
    -- psr_from_word
    ----------------------------------------------------------------
    word := X"000000F5";
    psr := psr_from_word(word);
    word := word_from_psr(psr);
    assert word = X"000000F5"
    report "expected 000000F5, got " & to_hstring(word)
    severity failure;

    ----------------------------------------------------------------
    -- psr_read supervisor
    ----------------------------------------------------------------
    word := psr_read(psr_pair);
    assert word = X"000000F0"
    report "expected 000000F0, got " & to_hstring(word)
    severity failure;

    ----------------------------------------------------------------
    -- psr_clear_bits/psr_set_bits supervisor
    ----------------------------------------------------------------
    psr_action <= CLEAR_BITS;
    -- clear I bit from supervisor bank
    mask <= X"00000015";
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"000000E0"
    report "expected psr_pair.banks(1)=000000E0, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"000000F0"
    report "expected psr_pair.banks(0)=000000F0, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    psr_action <= SET_BITS;
    -- set I, B, and Z bits in supervisor bank
    mask <= X"00000015";
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"000000F5"
    report "expected psr_pair.banks(1)=000000F5, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"000000F0"
    report "expected psr_pair.banks(0)=000000F0, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    ----------------------------------------------------------------
    -- psr_reset
    ----------------------------------------------------------------
    psr_action <= RESET;
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"000000F0"
    report "expected psr_pair.banks(1)=000000F0, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"000000F0"
    report "expected psr_pair.banks(0)=000000F0, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    ----------------------------------------------------------------
    -- psr_clear_bits/psr_set_bits system
    ----------------------------------------------------------------
    psr_action <= CLEAR_BITS;
    -- clear S bit, switching to user/system bank (P bit remains set)
    mask <= X"00000040";
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"000000B0"
    report "expected psr_pair.banks(1)=000000B0, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"000000B0"
    report "expected psr_pair.banks(0)=000000B0, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    psr_action <= CLEAR_BITS;
    -- clear I bit from user/system bank
    mask <= X"00000015";
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"000000B0"
    report "expected psr_pair.banks(1)=000000B0, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"000000A0"
    report "expected psr_pair.banks(0)=000000A0, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    psr_action <= SET_BITS;
    -- set I, V, and Z bits in user/system bank
    mask <= X"00000015";
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"000000B0"
    report "expected psr_pair.banks(1)=000000B0, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"000000B5"
    report "expected psr_pair.banks(0)=000000B5, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    ----------------------------------------------------------------
    -- psr_read system
    ----------------------------------------------------------------
    word := psr_read(psr_pair);
    assert word = X"000000B5"
    report "expected 000000B5, got " & to_hstring(word)
    severity failure;

    psr_action <= RESET;
    pulse_clock(clk);

    ----------------------------------------------------------------
    -- psr_clear_bits/psr_set_bits user
    ----------------------------------------------------------------
    psr_action <= CLEAR_BITS;
    -- clear S bit, switching to user/system bank (P bit remains set)
    mask <= X"00000040";
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"000000B0"
    report "expected psr_pair.banks(1)=000000B0, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"000000B0"
    report "expected psr_pair.banks(0)=000000B0, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;
    pulse_clock(clk);

    psr_action <= CLEAR_BITS;
    -- clear P, (S), and I bits of system/user bank, switching from system to user mode
    mask <= X"000000D0";
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"00000030"
    report "expected psr_pair.banks(1)=00000030, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"00000020"
    report "expected psr_pair.banks(0)=00000020, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    psr_action <= SET_BITS;
    -- set V and Z bits in system/user bank -- ensure protected bits are not updated
    mask <= X"000000E5";
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"00000030"
    report "expected psr_pair.banks(1)=00000030, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"00000025"
    report "expected psr_pair.banks(0)=00000025, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    ----------------------------------------------------------------
    -- psr_read user
    ----------------------------------------------------------------
    word := psr_read(psr_pair);
    assert word = X"00000025"
    report "expected 00000025, got " & to_hstring(word)
    severity failure;

    ----------------------------------------------------------------
    -- psr_exception
    ----------------------------------------------------------------
    psr_action <= EXCEPTION;
    pulse_clock(clk);
    word := word_from_psr(psr_pair.banks(1));
    assert word = X"000000F0"
    report "expected psr_pair.banks(1)=000000F0, got psr_pair.banks(1)=" & to_hstring(word)
    severity failure;
    word := word_from_psr(psr_pair.banks(0));
    assert word = X"000000F5"
    report "expected psr_pair.banks(0)=000000F5, got psr_pair.banks(0)=" & to_hstring(word)
    severity failure;

    report "psr_pack_tb: tests passed!";
    wait;

  end process;
end tb;
