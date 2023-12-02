defmodule Day01Trebuchet do

  @sample_data_part_1 """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """

  @doc ~S"""
  ## Examples

      iex> Day01Trebuchet.sample_solution_part1()
      142
  """
  def sample_solution_part1() do
    @sample_data_part_1
    |> multiline_string_to_lines_stream()
    |> solution_part1()
  end

  @doc ~S"""
  ## Examples

      iex> Day01Trebuchet.solution_for_file_part1()
      54597
  """
  def solution_for_file_part1() do
    "input.txt"
    |> input_file_to_lines_stream()
    |> solution_part1()
  end

  defp solution_part1(lines) do
    lines
    |> Enum.reject(fn line -> String.trim(line) == "" end)
    |> Enum.reject(fn line -> line == "" end)
    |> Enum.map(&digits/1)
    |> Enum.map(&concat_first_and_last_digit/1)
    |> Enum.map(&to_int/1)
    |> Enum.sum()
  end

  @sample_data_part_2 """
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """

  @doc ~S"""
  ## Examples

      iex> Day01Trebuchet.sample_solution_part2()
      281
  """
  def sample_solution_part2() do
    @sample_data_part_2
    |> multiline_string_to_lines_stream()
    |> solution_part2()
  end

  def solution_for_file_part2() do
    "input.txt"
    |> input_file_to_lines_stream()
    |> solution_part2()
  end

  defp solution_part2(lines) do
    lines
    |> Enum.reject(fn line -> String.trim(line) == "" end)
    |> Enum.map(&normalize_textual_digits/1)
    |> Enum.map(&digits/1)
    |> Enum.map(&concat_first_and_last_digit/1)
    |> Enum.map(fn e -> e |> IO.puts; e end)
    |> Enum.map(&to_int/1)
    |> Enum.sum()
  end


  defp digits(line) do
    line
    |> String.replace(~r/[^\d]/, "")
    |> String.codepoints()
  end

  defp concat_first_and_last_digit(digits) do
    first = digits |> hd()
    last = digits |> Enum.reverse |> hd()

    first <> last
  end

  defp to_int(num) when is_binary(num) do
    {num, _} = Integer.parse(num)
    num
  end

  def normalize_textual_digits(line), do: normalize_textual_digits(line, "", "")
  def normalize_textual_digits(_line = "", _acc = "", normalized), do: normalized
  def normalize_textual_digits(line, acc, normalized) do
    {replaced, acc} = replace_digit_match(acc)
    {next, line} = line |> String.split_at(1)

    # {line, acc <> next, normalized <> replaced} |> IO.inspect()

    normalize_textual_digits(line, acc <> next, normalized <> replaced)
  end

  @textual_digits ~w[one two three four five six seven eight nine]

  defp replace_digit_match(acc) do
    {_replaced, _acc} = case acc do
      "one" -> {"1", ""}
      "two" -> {"2", ""}
      "three" -> {"3", ""}
      "four" -> {"4", ""}
      "five" -> {"5", ""}
      "six" -> {"6", ""}
      "seven" -> {"7", ""}
      "eight" -> {"8", ""}
      "nine" -> {"9", ""}
      other -> case {partial_digit_match?(other), String.length(other)} do
        {true, _} -> {"", other}
        {false, 1} -> {other, ""}
        {false, _n} -> other |> String.split_at(1)
      end
    end
  end

  defp partial_digit_match?(partial) do
    Enum.reduce(@textual_digits, false, fn digit, acc ->
      String.starts_with?(digit, partial) || acc
    end)
  end

  defp multiline_string_to_lines_stream(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line -> line <> "\n"  end)
  end

  defp input_file_to_lines_stream(filename) do
    File.stream!(Path.join([Path.dirname(__ENV__.file), filename]))
  end
end
