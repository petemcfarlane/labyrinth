defmodule Labyrinth do
  @moduledoc """
  Documentation for `Labyrinth`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Labyrinth.hello()
      :world

  """
  def hello do
    :world
  end

  def init do
    shuffled_tiles = shuffle_tiles()
    initial_grid = grid(shuffled_tiles)
    next_tile = Enum.at(shuffled_tiles, 33)
    %{grid: initial_grid, next_tile: next_tile}
  end

  def grid(shuffled_tiles) do
    # A tile can have up to 4 walls on either side
    # we can represent this as a 4 bit integer
    # 1111 NESW all walls
    # 1010 N S north to south, straight
    # 1100 NE  north to east, corner
    # 0111  ESW east, south, west, T shape

    # 13 straight tiles
    # 6 T tiles
    # 15 corner tiles

    get_tile = fn index -> Enum.at(shuffled_tiles, index) end

    [
      [
        gen_tile(:ES),
        get_tile.(0),
        gen_tile(:ESW),
        get_tile.(1),
        gen_tile(:ESW),
        get_tile.(2),
        gen_tile(:SW)
      ],
      [
        get_tile.(3),
        get_tile.(4),
        get_tile.(5),
        get_tile.(6),
        get_tile.(7),
        get_tile.(8),
        get_tile.(9)
      ],
      [
        gen_tile(:NES),
        get_tile.(10),
        gen_tile(:NES),
        get_tile.(11),
        gen_tile(:ESW),
        get_tile.(12),
        gen_tile(:NSW)
      ],
      [
        get_tile.(13),
        get_tile.(14),
        get_tile.(15),
        get_tile.(16),
        get_tile.(17),
        get_tile.(18),
        get_tile.(19)
      ],
      [
        gen_tile(:NES),
        get_tile.(20),
        gen_tile(:NEW),
        get_tile.(21),
        gen_tile(:NSW),
        get_tile.(22),
        gen_tile(:NSW)
      ],
      [
        get_tile.(23),
        get_tile.(24),
        get_tile.(25),
        get_tile.(26),
        get_tile.(27),
        get_tile.(28),
        get_tile.(29)
      ],
      [
        gen_tile(:NE),
        get_tile.(30),
        gen_tile(:NEW),
        get_tile.(31),
        gen_tile(:NEW),
        get_tile.(32),
        gen_tile(:NW)
      ]
    ]
  end

  def draw_grid(grid) do
    grid
    |> Enum.map_join("\n", &draw_row/1)
  end

  def draw_row(row) do
    row
    |> Enum.map_join(&draw_cell/1)
  end

  def draw_cell(0b1010), do: "┃"
  def draw_cell(0b0101), do: "━"
  def draw_cell(0b1100), do: "┗"
  def draw_cell(0b0110), do: "┏"
  def draw_cell(0b0011), do: "┓"
  def draw_cell(0b1001), do: "┛"
  def draw_cell(0b1101), do: "┻"
  def draw_cell(0b1110), do: "┣"
  def draw_cell(0b0111), do: "┳"
  def draw_cell(0b1011), do: "┫"

  defp shuffle_tiles do
    (gen_tiles(:straight, 13) ++
       gen_tiles(:T, 6) ++
       gen_tiles(:corner, 15))
    |> Enum.shuffle()
  end

  defp gen_tiles(type, amount) do
    fn -> gen_tile(type) end
    |> Stream.repeatedly()
    |> Enum.take(amount)
  end

  defp gen_tile(:straight) do
    Enum.random([gen_tile(:NS), gen_tile(:EW)])
  end

  defp gen_tile(:NS), do: 0b1010
  defp gen_tile(:EW), do: 0b0101

  defp gen_tile(:T) do
    Enum.random([
      gen_tile(:NES),
      gen_tile(:ESW),
      gen_tile(:NSW),
      gen_tile(:NEW)
    ])
  end

  defp gen_tile(:NES), do: 0b1110
  defp gen_tile(:ESW), do: 0b0111
  defp gen_tile(:NSW), do: 0b1011
  defp gen_tile(:NEW), do: 0b1101

  defp gen_tile(:corner) do
    Enum.random([
      gen_tile(:NE),
      gen_tile(:ES),
      gen_tile(:SW),
      gen_tile(:NW)
    ])
  end

  defp gen_tile(:NE), do: 0b1100
  defp gen_tile(:ES), do: 0b0110
  defp gen_tile(:SW), do: 0b0011
  defp gen_tile(:NW), do: 0b1001
end
