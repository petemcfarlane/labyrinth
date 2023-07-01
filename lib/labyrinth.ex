defmodule Labyrinth do
  @moduledoc """
  Labyrinth is a board game consisting of a grid with 16 fixed tiles,
  34 movable tiles and 24 treasure cards. Traditionally there are 4
  players, each starting in a corner. The treasure cards are shuffled
  and dealt at the start of the game. The objective of the game is to
  be the first player to collect all of your treasure cards by visiting
  the tile with your treasure.
  On a players go, they must insert the spare tile into the grid,
  sliding the entire row or column along by one. Then they must move
  their pawn but only by 1 square, and only in the directions permitted
  by the current tile and relative surrounding tiles.
  If a pawn is moved off the end of a row or coluumn, it reappears on
  the newly inserted tile on the opposite side of the grid.
  """

  @doc """
  Shuffles the movable tiles and treasures and places them on a grid.

  ## Examples

      iex> Labyrinth.hello()
      :world

  """
  def init do
    shuffled_tiles = shuffle_tiles()
    initial_grid = grid(shuffled_tiles)
    next_tile = Enum.at(shuffled_tiles, 33)
    %{grid: initial_grid, next_tile: next_tile}
  end

  def grid(shuffled_tiles) do
    get_tile = fn index -> Enum.at(shuffled_tiles, index) end

    [
      [
        gen_tile(:ES, 8),
        get_tile.(0),
        gen_tile(:ESW, 9),
        get_tile.(1),
        gen_tile(:ESW, 10),
        get_tile.(2),
        gen_tile(:SW, 11)
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
        gen_tile(:NES, 12),
        get_tile.(10),
        gen_tile(:NES, 13),
        get_tile.(11),
        gen_tile(:ESW, 14),
        get_tile.(12),
        gen_tile(:NSW, 15)
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
        gen_tile(:NES, 16),
        get_tile.(20),
        gen_tile(:NEW, 17),
        get_tile.(21),
        gen_tile(:NSW, 18),
        get_tile.(22),
        gen_tile(:NSW, 19)
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
        gen_tile(:NE, 20),
        get_tile.(30),
        gen_tile(:NEW, 21),
        get_tile.(31),
        gen_tile(:NEW, 22),
        get_tile.(32),
        gen_tile(:NW, 23)
      ]
    ]
  end

  def draw_grid(grid), do: Enum.map_join(grid, "\n", &draw_row/1)

  def draw_row(row), do: Enum.map_join(row, &draw_tile/1)

  def draw_tile(0b1010), do: "┃"
  def draw_tile(0b0101), do: "━"
  def draw_tile(0b1100), do: "┗"
  def draw_tile(0b0110), do: "┏"
  def draw_tile(0b0011), do: "┓"
  def draw_tile(0b1001), do: "┛"
  def draw_tile(0b1101), do: "┻"
  def draw_tile(0b1110), do: "┣"
  def draw_tile(0b0111), do: "┳"
  def draw_tile(0b1011), do: "┫"
  def draw_tile({tile, _}), do: draw_tile(tile)

  def draw_treasure(nil), do: "."
  def draw_treasure(0), do: "🔑"
  def draw_treasure(1), do: "🔫"
  def draw_treasure(2), do: "📱"
  def draw_treasure(3), do: "💎"
  def draw_treasure(4), do: "⌛️"
  def draw_treasure(5), do: "🔪"
  def draw_treasure(6), do: "🪬"
  def draw_treasure(7), do: "🪥"
  def draw_treasure(8), do: "🎈"
  def draw_treasure(9), do: "✂️"
  def draw_treasure(10), do: "♟️"
  def draw_treasure(11), do: "🪃"
  def draw_treasure(12), do: "🍕"
  def draw_treasure(13), do: "🐢"
  def draw_treasure(14), do: "💍"
  def draw_treasure(15), do: "🍸"
  def draw_treasure(16), do: "🛹"
  def draw_treasure(17), do: "🥊"
  def draw_treasure(18), do: "🪈"
  def draw_treasure(19), do: "🛴"
  def draw_treasure(20), do: "🧯"
  def draw_treasure(21), do: "🧪"
  def draw_treasure(22), do: "🏹"
  def draw_treasure(23), do: "🧩"
  def draw_treasure({_, treasure}), do: draw_treasure(treasure)

  defp shuffle_tiles do
    # A tile can have up to 4 walls on either side
    # we can represent this as a 4 bit integer
    # 1111 NESW all walls
    # 1010 N S north to south, straight
    # 1100 NE  north to east, corner
    # 0111  ESW east, south, west, T shape

    # 13 straight tiles
    # 6 T tiles
    # 15 corner tiles
    # 8 treasures
    (gen_tiles(:straight, 13) ++
       gen_tiles(:T, 6) ++
       gen_tiles(:corner, 15))
    |> Enum.shuffle()
    |> Enum.with_index(fn
      tile, index when index < 8 -> {tile, index}
      tile, _index -> {tile, nil}
    end)
    |> Enum.shuffle()
  end

  defp gen_tiles(type, amount) do
    fn -> gen_tile(type) end
    |> Stream.repeatedly()
    |> Enum.take(amount)
  end

  defp gen_tile(dir, treasure), do: {gen_tile(dir), treasure}

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
