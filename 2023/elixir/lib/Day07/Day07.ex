defmodule Day07 do
  @moduledoc """
  --- Day 7: Camel Cards ---
  """

  @sample_data_part_1 """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  @doc ~S"""
  ## Examples

      iex> Day07.sample_solution_part1()
      6440
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day07.solution_for_file_part1()
      250474325
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day07.sample_solution_part2()
      nil
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day07.solution_for_file_part2()
      nil
  """
  def solution_for_file_part2()

  defmodule Hand do
    defstruct [:raw, :cards, :groups, :value, :bet]
  end


  defp solution_part1(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> Enum.sort_by(fn hand -> {hand.value, hand.cards} end)
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> hand.bet * rank end)
    |> Enum.sum()
  end

  defp solution_part2(lines) do
    lines
  end

  defp parse_line(line) do
    [raw_cards, bet] = line |> String.trim() |> String.split(" ")
    cards = raw_cards |> String.codepoints() |> Enum.map(&card_to_power/1)
    bet = bet |> String.to_integer()

    groups = cards
    |> Enum.group_by(fn c -> c end)
    |> Map.values()
    |> Enum.sort_by(fn group -> {-Enum.count(group), -Enum.sum(group)} end)

    value = hand_value(groups)

    %Hand{raw: raw_cards, cards: cards, groups: groups, value: value, bet: bet}
  end

  defp card_to_power(card) do
    ~w[A K Q J T 9 8 7 6 5 4 3 2]a
    |> Enum.reverse()
    |> Enum.with_index()
    |> Keyword.get(String.to_atom(card))
  end

  defp hand_value(cards) do
    sizes = cards |> Enum.map(fn group -> Enum.count(group) end)
    case sizes do
      [5] -> 6
      [4, 1] -> 5
      [3, 2] -> 4
      [3 | _] -> 3
      [2, 2, 1] -> 2
      [2 | _] -> 1
      _ -> 0
    end
  end
end
