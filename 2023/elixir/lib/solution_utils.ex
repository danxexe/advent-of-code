defmodule Aoc.SolutionUtils do

  defmacro __using__(_opts) do
    quote do
      def sample_solution_part1() do
        @sample_data_part_1
        |> multiline_string_to_lines_stream()
        |> solution_part1()
      end

      def sample_solution_part2() do
        @sample_data_part_2
        |> multiline_string_to_lines_stream()
        |> solution_part2()
      end

      def solution_for_file_part1() do
        "input.txt"
        |> input_file_to_lines_stream()
        |> solution_part1()
      end

      def solution_for_file_part2() do
        "input.txt"
        |> input_file_to_lines_stream()
        |> solution_part2()
      end

      defp multiline_string_to_lines_stream(input) do
        input
        |> String.split("\n")
        |> Enum.map(fn line -> line <> "\n"  end)
        |> Enum.reject(fn line -> String.trim(line) == "" end)
      end

      defp input_file_to_lines_stream(filename) do
        File.stream!(Path.join([Path.dirname(__ENV__.file), filename]))
        |> Enum.reject(fn line -> String.trim(line) == "" end)
      end
    end
  end
end
