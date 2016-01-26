defmodule LumPatterns.Parser do
  @moduledoc """
  Parse CSV files describing a Luminous Patterns installation
  """

  def parse(str) do
    str
    |> split_csv
    |> drop_local_fields
    |> cleanup_names
    |> cleanup_numbers
    |> to_tuple
    |> rotate_y_axis
    |> shift_nodes_x
    |> shift_nodes_y
    |> create_data_structure(Map.new)
  end

  defp split_csv(contents) do		
    contents
    |> String.split(["\r", "\n"], trim: true)	
    |> tl
    |> Enum.map(&(String.split(&1, [",", "\t"], trim: true)))				
    |> Enum.map(fn(x) -> Enum.map(x, &String.strip/1) end)
  end

  defp drop_local_fields(list), do: Enum.map(list, fn([n, _l_x, _l_y, g_x, g_y, s, p]) -> [n, g_x, g_y, s, p] end)

  defp cleanup_names(list), do: Enum.map(list, &cleanup_name/1)

  defp cleanup_name([name | rest]) do
    [_match, capture] = Regex.run ~r/Status:(\d+)\(/, name
    [String.to_integer(capture) | rest]
  end

  defp cleanup_numbers(list), do: Enum.map(list, &cleanup_number/1)

  defp cleanup_number([name, x, y, supply, port]) do
    [name, parse_float(x), parse_float(y), String.to_integer(supply), String.to_integer(port)]
  end

  defp parse_float(str) do
    {num, _r} = Float.parse(str)
    num
  end

  defp to_tuple(list), do: Enum.map(list, &List.to_tuple/1)

  defp rotate_y_axis(list), do: Enum.map(list, fn {n, g_x, g_y, s, p} -> {n, -1*g_x, g_y, s, p} end)

  defp shift_nodes_x(list) do
    {_n, min_x, _y, _s, _p} = Enum.min_by(list, fn {_n, x, _y, _s, _p} -> x end)
    if min_x < 0, do: shift_x(list, -1 * min_x), else: list
  end

  defp shift_x(list, amount), do: Enum.map(list, fn {n, x, y, s, p} -> {n, x + amount, y, s, p} end)

  defp shift_nodes_y(list) do
    {_n, _x, min_y, _s, _p} = Enum.min_by(list, fn {_n, _x, y, _s, _p} -> y end)
    if min_y < 0, do: shift_y(list, -1 * min_y), else: list
  end

  defp shift_y(list, amount), do: Enum.map(list, fn {n, x, y, s, p} -> {n, x, y + amount, s, p} end)

  defp create_data_structure(list, map) do
    Enum.reduce(list, map, &insert_supply/2)
  end

  defp insert_supply(node = {_index, _x, _y, supply, _port}, map) do
    map
    |> Map.put_new(supply, Map.new)
    |> Map.update!(supply, &(insert_port(node, &1)))
  end

  defp insert_port(node = {_index, _x, _y, _supply, port}, supply) do
    supply
    |> Map.put_new(port, MapSet.new)
    |> Map.update!(port, &(insert_node(node, &1)))
  end

  defp insert_node({index, x, y, _supply, _port}, port) do
    port
    |> MapSet.put({index, x, y})
  end
end
