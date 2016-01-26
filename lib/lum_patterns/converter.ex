defmodule LumPatterns.Converter do
  @moduledoc """
  Functions to convert a csv file to LSE map
  """

  def convert(input_str) do
    input_str
    |> LumPatterns.Parser.parse
    |> preprocess_controllers
    |> LumPatterns.MapCreator.create
  end

  def convert_file(csv_path, output_path) do
    content = File.read!(csv_path) |> convert
    File.write!(output_path, content)
  end

  # controller_map: Map(controller_num -> Map(port_num -> Set({index,x,y})))
  defp preprocess_controllers(controller_map) do
    preprocess_controller(Map.keys(controller_map), controller_map)
  end

  defp preprocess_controller([], map), do: map
  defp preprocess_controller([key | rest], map) do
    preprocess_controller(rest, Map.update!(map, key, &(update_controller(key, &1))))
  end

  @base_supply_serial 0x30002C00

  # for the controller, add controller_sn, controller_ip, controller_name, num_ports
  defp update_controller(controller_num, port_map) do
    sn = @base_supply_serial + controller_num
    new_ports = preprocess_port(Map.keys(port_map), port_map, sn, controller_num)
    %{
      sn: sn,
      ip: "10.1.1.#{controller_num}",
      name: "Supply #{controller_num}",
      ports: new_ports,
      num_ports: max_port(port_map)
    }
  end

  defp max_port(port_map), do: Map.keys(port_map) |> Enum.max

  defp preprocess_port([], map, _controller_sn, _controller_num), do: map
  defp preprocess_port([key | rest], map, controller_sn, controller_num) do
    new_map = Map.update!(map, key, &(update_port(key, &1, controller_sn, controller_num)))
    preprocess_port(rest, new_map, controller_sn, controller_num)
  end

  # for a light, add sn, add fixure_sn (same for whole port), add controller_sn 
  defp update_port(port_num, light_set, controller_sn, controller_num) do
    light_set 
    |> MapSet.to_list 
    |> Enum.map(&(update_light(&1, controller_sn, controller_num, port_num)))
    |> MapSet.new
  end

  defp update_light({index, x, y}, controller_sn, controller_num, port_num) do
    sn = light_sn(controller_num, port_num, index)
    %{
      index: index,
      x: x,
      y: y,
      sn: sn,
      fix_sn: sn + 500000,
      controller_sn: controller_sn,
      port_num: port_num,
    }
  end

  @base_light_serial 1000
  @max_ports_per_supply 16
  @max_lights_per_port 100
  defp light_sn(controller_num, port_num, fixture_num) do
    controller_base = controller_num * @max_ports_per_supply * @max_lights_per_port
    controller_base + ((port_num - 1) * @max_lights_per_port) + fixture_num
  end

end
