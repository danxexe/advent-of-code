defmodule Day01Trebuchet do

  @sample_data_part_1 """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """
  @sample_data_part_2 """
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """

  use Aoc.SolutionUtils

  @doc ~S"""
  ## Examples

      iex> Day01Trebuchet.sample_solution_part1()
      142
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day01Trebuchet.solution_for_file_part1()
      54597
  """
  def solution_for_file_part1()

  defp solution_part1(lines) do
    lines
    |> Enum.reject(fn line -> line == "" end)
    |> Enum.map(&digits/1)
    |> Enum.map(&concat_first_and_last_digit/1)
    |> Enum.map(&to_int/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Examples

      iex> Day01Trebuchet.sample_solution_part2()
      281
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day01Trebuchet.solution_for_file_part2()
      54504
  """
  def solution_for_file_part2()

  defp solution_part2(lines) do
    lines
    |> Enum.map(&normalize_textual_digits/1)
    |> Enum.map(&digits/1)
    |> Enum.map(&concat_first_and_last_digit/1)
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

  def normalize_textual_digits(line) do
    line
    |> String.replace("one", "one1one")
    |> String.replace("two", "two2two")
    |> String.replace("three", "three3three")
    |> String.replace("four", "four4four")
    |> String.replace("five", "five5five")
    |> String.replace("six", "six6six")
    |> String.replace("seven", "seven7seven")
    |> String.replace("eight", "eight8eight")
    |> String.replace("nine", "nine9nine")
  end
end
