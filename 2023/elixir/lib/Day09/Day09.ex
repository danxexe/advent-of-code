defmodule Day09 do
  @moduledoc """
  --- Day 9: Mirage Maintenance ---
  """

  @sample_data_part_1 """
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
  """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils


  @doc ~S"""
  ## Examples

      iex> Day09.sample_solution_part1()
      114
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day09.solution_for_file_part1()
      1725987467
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day09.sample_solution_part2()
      2
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day09.solution_for_file_part2()
      971
  """
  def solution_for_file_part2()

  defmodule History do
    defstruct [sequences: %{}, last: -1, prediction: []]
  end

  defmodule Sequence do
    defstruct [:values, all_zero?: false]
  end

  defp solution_part1(lines) do
    lines
    |> Enum.map(&parse_history/1)
    |> Enum.map(&compute_next_sequence/1)
    |> Enum.map(&predict_sequence/1)
    |> Enum.map(fn history -> history.prediction end)
    |> Enum.sum()
  end

  defp solution_part2(lines) do
    lines
    |> Enum.map(&parse_history/1)
    |> Enum.map(&compute_next_sequence/1)
    |> Enum.map(&predict_sequence_reverse/1)
    |> Enum.map(fn history -> history.prediction end)
    |> Enum.sum()
  end

  defp parse_history(line) do
    values = Regex.scan(~r/-?\d+/, line)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)

    %History{sequences: %{0 => %Sequence{values: values}}, last: 0}
  end

  defp compute_next_sequence(history) do
    {_, difference, zero?} = history.sequences[history.last].values
    |> List.foldl({nil, [], true}, fn b, {a, acc, zero?} ->
      if a == nil do
        {b, acc, true}
      else
        diff = b - a
        {b, [diff | acc], zero? && (diff == 0)}
      end
    end)

    i = history.last + 1
    sequence = %Sequence{values: difference |> Enum.reverse(), all_zero?: zero?}
    sequences = history.sequences |> Map.put(i, sequence)

    next = %History{history | sequences: sequences, last: i}

    if zero? do
      next
    else
      compute_next_sequence(next)
    end
  end

  defp predict_sequence(history) do
    do_predict_sequence(history, history.last - 1, 0)
  end

  defp do_predict_sequence(history, i, prediction) do
    prediction = prediction + (history.sequences[i].values |> List.last())

    if i == 0 do
      %History{history | prediction: prediction}
    else
      do_predict_sequence(history, i - 1, prediction)
    end
  end

  defp predict_sequence_reverse(history) do
    do_predict_sequence_reverse(history, history.last - 1, 0)
  end

  defp do_predict_sequence_reverse(history, i, prediction) do
    prediction = (history.sequences[i].values |> List.first()) - prediction

    if i == 0 do
      %History{history | prediction: prediction}
    else
      do_predict_sequence_reverse(history, i - 1, prediction)
    end
  end
end
