defmodule LumPatterns.MapCreator do
  @moduledoc """
  Functions to generate the xml for an LSE map
  """
  import XmlBuilder

  def create(controller_map) do
    map(controller_map) |> XmlBuilder.generate
  end

  defp map(controller_map) do
    element(:map, map_elements(controller_map))
  end

  defp map_elements(controller_map) do
    [element(:imagefile, ""), element(:postsync, 0), map_content(controller_map)]
  end

  defp map_content(controller_map) do
    [
      controller_map |> Map.values |> Enum.map(&gen_controller/1),
      controller_map |> Map.values |> all_group
    ] |> List.flatten
  end

  defp gen_controller(controller) do
    [
      controller_element(controller),
      controller.ports |> all_lights |> Enum.map(&light_element/1),
      controller.ports |> all_lights |> Enum.map(&light_group/1)
    ] |> List.flatten
  end

  defp controller_element(controller) do
    element(:c, 
     [ 
       element(:t, 2),
       element(:s, controller.sn |> hex),
       element(:n, controller.name),
       element(:sn, controller.sn |> hex),
       element(:ip, controller.ip),
       element(:mac, "00:0A:C5:01:01:01"),
       element(:d, 12),
       element(:v, 2),
       element(:vs, ""),
       element(:ids, ""),
       ports_element(controller.ports),
       controller.ports |> all_light_sn |> Enum.map(&(element(:l, hex(&1)))) |> List.flatten
     ]
    )
  end

  defp ports_element(ports) do
    port_cnt = Map.keys(ports) |> Enum.max
    ports = for n <- 1..port_cnt, do: port_element(n)
    element(:pl, ports)
  end

  defp port_element(num) do
    element(:p, pn: num, pt: 3, pf: 0)
  end

  defp light_element(light) do
    element(:l,
    [
      element(:t, 1),
      element(:st, 0),
      element(:s, light.sn |> hex),
      element(:n, "Light #{light.port_num}-#{light.index}"),
      element(:pn, light.port_num - 1),
      element(:ln, 0),
      element(:f, light.fix_sn |> hex),
      element(:c, light.controller_sn |> hex),
      element(:fc, 0),
      element(:x, light.x),
      element(:y, light.y),
      element(:z, 0),
      element(:q0, 0),
      element(:q1, 0),
      element(:q2, 0),
      element(:q3, 1),
      element(:ch, (light.index - 1) * 3)
      ])
  end

  defp light_group(%{sn: sn, port_num: port, index: index}) do
    group_element(3, sn, "Light #{port}-#{index}")
  end

  defp all_group(controllers) do
    lights = Enum.map(controllers, fn(c) -> c.ports |> all_lights  end) |> List.flatten
    element(:g,
    [
      element(:t, 1), # 3 for light or 1 for "all" group
      element(:s, 1 |> hex),
      element(:n, "All"),
      lights |> Enum.map(fn(c) -> element(:c, c.sn |> hex) end) |> List.flatten
    ])
  end

  defp group_element(type, sn, name) do
    element(:g,
    [
      element(:t, type), # 3 for light or 1 for "all" group
      element(:s, sn |> hex),
      element(:n, name),
      element(:c, sn |> hex)
    ])
  end

  defp hex(int), do: Integer.to_string(int, 16) |> String.rjust(8, ?0)

  defp all_lights(ports_map) do
    Map.values(ports_map) |> Enum.map(&MapSet.to_list/1) |> List.flatten
  end

  defp all_light_sn(ports_map) do
    ports_map 
    |> all_lights 
    |> Enum.map(fn(%{sn: sn}) -> sn end)
  end

end
