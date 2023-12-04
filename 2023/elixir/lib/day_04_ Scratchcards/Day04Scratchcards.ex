defmodule Day04Scratchcards do

  @sample_data_part_1 """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  defmodule Card do
    defstruct [name: nil, winning: [], owned: [], points: nil]
  end

  @doc ~S"""
  ## Examples

      iex> Day04Scratchcards.sample_solution_part1()
      13
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day04Scratchcards.solution_for_file_part1()
      21158
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day04Scratchcards.sample_solution_part2()
      nil
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day04Scratchcards.solution_for_file_part1()
      nil
  """
  def solution_for_file_part2()

  defp solution_part1(lines) do
    lines
    |> Enum.map(&parse_card/1)
    |> Enum.map(&compute_points/1)
    |> Enum.map(fn card -> card.points end)
    |> Enum.sum()
  end

  defp solution_part2(lines) do
    nil
  end

  defp parse_card(line) do
    [name, numbers] = line |> String.split(":")
    [winning, owned] = numbers |> String.split("|")
    winning = Regex.scan(~r/\d+/, winning) |> Enum.map(&parse_number/1)
    owned = Regex.scan(~r/\d+/, owned) |> Enum.map(&parse_number/1)

    %Card{name: name, winning: winning, owned: owned}
  end

  defp parse_number([num]) do
    num |> Integer.parse() |> elem(0)
  end

  defp compute_points(card) do
    points = card.owned |> Enum.reduce(0, fn number, acc ->
      case {Enum.member?(card.winning, number), acc} do
        {false, acc} -> acc
        {true, 0} -> 1
        {true, p} -> p * 2
      end
    end)

    %Card{card | points: points}
  end
end
