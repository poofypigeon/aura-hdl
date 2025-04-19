library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity barrel_shifter_tb is
end entity barrel_shifter_tb;

architecture tb of barrel_shifter_tb is
  signal i_data       : std_ulogic_vector(31 downto 0) := X"00000000";
  signal i_carry      : std_ulogic := '0';
  signal i_shift      : std_ulogic_vector( 7 downto 0) := X"00";
  signal i_direction  : std_ulogic := '0'; -- right='1', left='0'
  signal i_arithmetic : std_ulogic := '0'; 

  signal o_data       : std_ulogic_vector(31 downto 0);
  signal o_carry      : std_ulogic;
begin

  uut : entity work.barrel_shifter
  port map (
    i_data       => i_data,
    i_carry      => i_carry,
    i_shift      => i_shift,
    i_direction  => i_direction,
    i_arithmetic => i_arithmetic,
    o_data       => o_data,
    o_carry      => o_carry
  );

  process
    variable expect : std_ulogic_vector(31 downto 0);
  begin
    -- lsl by 0, cin='0'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"00";
    i_direction  <= '0';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := i_data;
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- lsl by 0, cin='1'
    i_data       <= X"AAAA5555";
    i_carry      <= '1';
    i_shift      <= X"00";
    i_direction  <= '0';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := i_data;
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity error;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity error;

    -- lsl by less than 32, cout='1'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"01";
    i_direction  <= '0';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := std_ulogic_vector(unsigned(i_data) sll 1);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity error;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity error;

    -- lsl by less than 32, cout='0'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"02";
    i_direction  <= '0';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := std_ulogic_vector(unsigned(i_data) sll 2);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity error;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity error;

    -- lsl by 32
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"20";
    i_direction  <= '0';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := std_ulogic_vector(unsigned(i_data) sll 32);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity error;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity error;

    -- lsl by more than 32
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"40";
    i_direction  <= '0';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := std_ulogic_vector(unsigned(i_data) sll 64);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity error;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity error;

    -- lsr by 0, cin='0'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"00";
    i_direction  <= '1';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := i_data;
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- lsr by 0, cin='1'
    i_data       <= X"AAAA5555";
    i_carry      <= '1';
    i_shift      <= X"00";
    i_direction  <= '1';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := i_data;
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- lsr by less than 32 cout='1'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"01";
    i_direction  <= '1';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := std_ulogic_vector(unsigned(i_data) srl 1);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- lsr by less than 32 cout='0'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"02";
    i_direction  <= '1';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := std_ulogic_vector(unsigned(i_data) srl 2);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- lsr by 32
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"20";
    i_direction  <= '1';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := std_ulogic_vector(unsigned(i_data) srl 32);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- lsr by more than 32
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"40";
    i_direction  <= '1';
    i_arithmetic <= '0';
    wait for 2 ns;
    expect := std_ulogic_vector(unsigned(i_data) srl 64);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by 0, cin='0'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"00";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := i_data;
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by 0, cin='1'
    i_data       <= X"AAAA5555";
    i_carry      <= '1';
    i_shift      <= X"00";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := i_data;
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by less than 32, positive, cout='1'
    i_data       <= X"2AAA5555";
    i_carry      <= '0';
    i_shift      <= X"01";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := std_ulogic_vector(signed(i_data) srl 1);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by less than 32, positive, cout='0'
    i_data       <= X"2AAA5555";
    i_carry      <= '0';
    i_shift      <= X"02";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := std_ulogic_vector(signed(i_data) srl 2);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by less than 32 negative, cout='1'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"01";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := std_ulogic_vector(signed(i_data) srl 1);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by less than 32 negative, cout='0'
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"02";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := std_ulogic_vector(signed(i_data) srl 2);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by 32, positive
    i_data       <= X"2AAA5555";
    i_carry      <= '0';
    i_shift      <= X"20";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := std_ulogic_vector(signed(i_data) srl 32);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by 32 negative
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"20";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := std_ulogic_vector(signed(i_data) srl 32);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by more than 32, positive
    i_data       <= X"2AAA5555";
    i_carry      <= '0';
    i_shift      <= X"40";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := std_ulogic_vector(signed(i_data) srl 64);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '0'
    report "expected o_carry=" & std_ulogic'image('0') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    -- asr by more than 32 negative
    i_data       <= X"AAAA5555";
    i_carry      <= '0';
    i_shift      <= X"40";
    i_direction  <= '1';
    i_arithmetic <= '1';
    wait for 2 ns;
    expect := std_ulogic_vector(signed(i_data) srl 64);
    assert o_data = expect
    report "expected o_data=" & to_hstring(expect) & ", " & "found o_data=" & to_hstring(o_data)
    severity failure;
    assert o_carry = '1'
    report "expected o_carry=" & std_ulogic'image('1') & ", " & "found o_carry=" & std_ulogic'image(o_carry)
    severity failure;

    report "barrel_shifter_tb: tests passed!";
    wait;

  end process;

end tb;
