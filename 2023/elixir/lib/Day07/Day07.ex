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
      5905
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day07.solution_for_file_part2()
      248909434
  """
  def solution_for_file_part2()

  defmodule Hand do
    defstruct [:raw, :bet, :cards, :groups, :value, :jokers]
  end


  defp solution_part1(lines) do
    lines
    |> Stream.map(&parse_line/1)
    |> Stream.map(fn hand -> hand |> compute_power(&card_to_power/1) end)
    |> Stream.map(&compute_groups/1)
    |> Stream.map(&compute_value/1)
    |> Enum.sort_by(fn hand -> {hand.value, hand.cards} end)
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> hand.bet * rank end)
    |> Enum.sum()
  end

  defp solution_part2(lines) do
    lines
    |> Stream.map(&parse_line/1)
    |> Stream.map(fn hand -> hand |> compute_power(&card_to_power_with_joker/1) end)
    |> Stream.map(&extract_jokers/1)
    |> Stream.map(&compute_groups_no_joker/1)
    |> Stream.map(&apply_jokers_to_groups/1)
    |> Stream.map(&compute_value/1)
    |> Enum.sort_by(fn hand -> {hand.value, hand.cards} end)
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> hand.bet * rank end)
    |> Enum.sum()
  end

  defp parse_line(line) do
    [raw_cards, bet] = line |> String.trim() |> String.split(" ")
    bet = bet |> String.to_integer()

    %Hand{raw: raw_cards, bet: bet}
  end

  defp compute_power(hand, power_fn) do
    cards = hand.raw |> String.codepoints() |> Enum.map(power_fn)
    %Hand{hand | cards: cards}
  end

  defp compute_groups(hand) do
    groups = hand.cards
    |> Enum.group_by(fn c -> c end)
    |> Map.values()
    |> Enum.sort_by(fn group -> {-Enum.count(group), -Enum.sum(group)} end)

    %Hand{hand | groups: groups}
  end

  defp compute_groups_no_joker(hand) do
    cards_no_joker = hand.cards |> Enum.reject(fn card -> card == 0 end)
    hand_no_joker = %Hand{hand | cards: cards_no_joker} |> compute_groups()

    groups = case hand_no_joker.groups do
      [] -> [[]]
      groups -> groups
    end

    %Hand{hand | groups: groups}
  end

  defp compute_value(hand) do
    %Hand{hand | value: hand_value(hand.groups)}
  end

  defp card_to_power(card) do
    ~w[A K Q J T 9 8 7 6 5 4 3 2]a
    |> Enum.reverse()
    |> Enum.with_index()
    |> Keyword.get(String.to_atom(card))
  end

  defp card_to_power_with_joker(card) do
    ~w[A K Q T 9 8 7 6 5 4 3 2 J]a
    |> Enum.reverse()
    |> Enum.with_index()
    |> Keyword.get(String.to_atom(card))
  end

  defp hand_value(groups) do
    sizes = groups |> Enum.map(fn group -> Enum.count(group) end)
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

  defp extract_jokers(hand) do
    {jokers, _cards} = hand.cards
    |> Enum.split_with(fn card -> card == 0 end)

    %Hand{hand | jokers: jokers}
  end

  defp apply_jokers_to_groups(hand) do
    [first | rest] = hand.groups
    groups = [first ++ hand.jokers | rest]

    %Hand{hand | groups: groups}
  end
end
