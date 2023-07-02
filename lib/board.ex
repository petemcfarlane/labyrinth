defmodule Labyrinth.Board do
  @doc """
   A tile can have up to 4 walls on either side
   we can represent this as a 4 bit integer
   1111 NESW all walls
   1010 N S north to south, straight
   1100 NE  north to east, corner
   0111  ESW east, south, west, T shape

  The movable tiles consist of
   - 13 straight tiles
   - 6 T tiles
   - 15 corner tiles
   and 8 of the tiles contain treasures

   Note, there are 34 tiles in total, but only 33 fit on
   the board at any one time, the final tile is the movable tile.
  """
  def shuffle_tiles do
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

  def init(shuffled_tiles) do
    get_tile = fn index -> Enum.at(shuffled_tiles, index) end

    %{
      {0, 0} => gen_tile(:ES, 8),
      {0, 1} => get_tile.(0),
      {0, 2} => gen_tile(:ESW, 9),
      {0, 3} => get_tile.(1),
      {0, 4} => gen_tile(:ESW, 10),
      {0, 5} => get_tile.(2),
      {0, 6} => gen_tile(:SW, 11),
      {1, 0} => get_tile.(3),
      {1, 1} => get_tile.(4),
      {1, 2} => get_tile.(5),
      {1, 3} => get_tile.(6),
      {1, 4} => get_tile.(7),
      {1, 5} => get_tile.(8),
      {1, 6} => get_tile.(9),
      {2, 0} => gen_tile(:NES, 12),
      {2, 1} => get_tile.(10),
      {2, 2} => gen_tile(:NES, 13),
      {2, 3} => get_tile.(11),
      {2, 4} => gen_tile(:ESW, 14),
      {2, 5} => get_tile.(12),
      {2, 6} => gen_tile(:NSW, 15),
      {3, 0} => get_tile.(13),
      {3, 1} => get_tile.(14),
      {3, 2} => get_tile.(15),
      {3, 3} => get_tile.(16),
      {3, 4} => get_tile.(17),
      {3, 5} => get_tile.(18),
      {3, 6} => get_tile.(19),
      {4, 0} => gen_tile(:NES, 16),
      {4, 1} => get_tile.(20),
      {4, 2} => gen_tile(:NEW, 17),
      {4, 3} => get_tile.(21),
      {4, 4} => gen_tile(:NSW, 18),
      {4, 5} => get_tile.(22),
      {4, 6} => gen_tile(:NSW, 19),
      {5, 0} => get_tile.(23),
      {5, 1} => get_tile.(24),
      {5, 2} => get_tile.(25),
      {5, 3} => get_tile.(26),
      {5, 4} => get_tile.(27),
      {5, 5} => get_tile.(28),
      {5, 6} => get_tile.(29),
      {6, 0} => gen_tile(:NE, 20),
      {6, 1} => get_tile.(30),
      {6, 2} => gen_tile(:NEW, 21),
      {6, 3} => get_tile.(31),
      {6, 4} => gen_tile(:NEW, 22),
      {6, 5} => get_tile.(32),
      {6, 6} => gen_tile(:NW, 23)
    }
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

  defp gen_tiles(type, amount) do
    fn -> gen_tile(type) end
    |> Stream.repeatedly()
    |> Enum.take(amount)
  end

  def insert_tile(grid, tile, 0), do: move_column_down(grid, tile, 1)
  def insert_tile(grid, tile, 1), do: move_column_down(grid, tile, 3)
  def insert_tile(grid, tile, 2), do: move_column_down(grid, tile, 5)
  def insert_tile(grid, tile, 3), do: move_row_to_left(grid, tile, 1)
  def insert_tile(grid, tile, 4), do: move_row_to_left(grid, tile, 3)
  def insert_tile(grid, tile, 5), do: move_row_to_left(grid, tile, 5)
  def insert_tile(grid, tile, 6), do: move_column_up(grid, tile, 5)
  def insert_tile(grid, tile, 7), do: move_column_up(grid, tile, 3)
  def insert_tile(grid, tile, 8), do: move_column_up(grid, tile, 1)
  def insert_tile(grid, tile, 9), do: move_row_to_right(grid, tile, 5)
  def insert_tile(grid, tile, 10), do: move_row_to_right(grid, tile, 3)
  def insert_tile(grid, tile, 11), do: move_row_to_right(grid, tile, 1)

  defp move_column_down(grid, tile, column_index) do
    new_spare_tile = Map.get(grid, {6, column_index})

    new_grid =
      grid
      |> Map.replace!({0, column_index}, tile)
      |> Map.replace!({1, column_index}, Map.get(grid, {0, column_index}))
      |> Map.replace!({2, column_index}, Map.get(grid, {1, column_index}))
      |> Map.replace!({3, column_index}, Map.get(grid, {2, column_index}))
      |> Map.replace!({4, column_index}, Map.get(grid, {3, column_index}))
      |> Map.replace!({5, column_index}, Map.get(grid, {4, column_index}))
      |> Map.replace!({6, column_index}, Map.get(grid, {5, column_index}))

    {new_grid, new_spare_tile}
  end

  defp move_column_up(grid, tile, column_index) do
    new_spare_tile = Map.get(grid, {0, column_index})

    new_grid =
      grid
      |> Map.replace!({6, column_index}, tile)
      |> Map.replace!({5, column_index}, Map.get(grid, {6, column_index}))
      |> Map.replace!({4, column_index}, Map.get(grid, {5, column_index}))
      |> Map.replace!({3, column_index}, Map.get(grid, {4, column_index}))
      |> Map.replace!({2, column_index}, Map.get(grid, {3, column_index}))
      |> Map.replace!({1, column_index}, Map.get(grid, {2, column_index}))
      |> Map.replace!({0, column_index}, Map.get(grid, {1, column_index}))

    {new_grid, new_spare_tile}
  end

  defp move_row_to_right(grid, tile, row_index) do
    new_spare_tile = Map.get(grid, {row_index, 6})

    new_grid =
      grid
      |> Map.replace!({row_index, 0}, tile)
      |> Map.replace!({row_index, 1}, Map.get(grid, {row_index, 0}))
      |> Map.replace!({row_index, 2}, Map.get(grid, {row_index, 1}))
      |> Map.replace!({row_index, 3}, Map.get(grid, {row_index, 2}))
      |> Map.replace!({row_index, 4}, Map.get(grid, {row_index, 3}))
      |> Map.replace!({row_index, 5}, Map.get(grid, {row_index, 4}))
      |> Map.replace!({row_index, 6}, Map.get(grid, {row_index, 5}))

    {new_grid, new_spare_tile}
  end

  defp move_row_to_left(grid, tile, row_index) do
    new_spare_tile = Map.get(grid, {row_index, 0})

    new_grid =
      grid
      |> Map.replace!({row_index, 6}, tile)
      |> Map.replace!({row_index, 5}, Map.get(grid, {row_index, 6}))
      |> Map.replace!({row_index, 4}, Map.get(grid, {row_index, 5}))
      |> Map.replace!({row_index, 3}, Map.get(grid, {row_index, 4}))
      |> Map.replace!({row_index, 2}, Map.get(grid, {row_index, 3}))
      |> Map.replace!({row_index, 1}, Map.get(grid, {row_index, 2}))
      |> Map.replace!({row_index, 0}, Map.get(grid, {row_index, 1}))

    {new_grid, new_spare_tile}
  end

  def draw_labyrinth({grid, next_tile}) do
    draw_labyrinth(grid)
    IO.puts("Next tile: #{draw_tile(next_tile)}")
    {grid, next_tile}
  end

  def draw_labyrinth(grid) do
    grid
    |> Enum.group_by(fn {{x, _y}, _} -> x end)
    |> Map.values()
    |> Enum.map(fn row ->
      row |> Enum.sort_by(fn {{_x, y}, _tile} -> y end) |> Enum.map(fn {_xy, tile} -> tile end)
    end)
    |> Enum.map_join("\n", &draw_row/1)
    |> IO.puts()

    grid
  end

  defp draw_row(row), do: Enum.map_join(row, &draw_tile/1)

  defp draw_tile(0b1010), do: "┃"
  defp draw_tile(0b0101), do: "━"
  defp draw_tile(0b1100), do: "┗"
  defp draw_tile(0b0110), do: "┏"
  defp draw_tile(0b0011), do: "┓"
  defp draw_tile(0b1001), do: "┛"
  defp draw_tile(0b1101), do: "┻"
  defp draw_tile(0b1110), do: "┣"
  defp draw_tile(0b0111), do: "┳"
  defp draw_tile(0b1011), do: "┫"
  defp draw_tile({tile, _}), do: draw_tile(tile)

  defp draw_treasure(nil), do: "."
  defp draw_treasure(0), do: "🔑"
  defp draw_treasure(1), do: "🔫"
  defp draw_treasure(2), do: "📱"
  defp draw_treasure(3), do: "💎"
  defp draw_treasure(4), do: "⌛️"
  defp draw_treasure(5), do: "🔪"
  defp draw_treasure(6), do: "🪬"
  defp draw_treasure(7), do: "🪥"
  defp draw_treasure(8), do: "🎈"
  defp draw_treasure(9), do: "✂️"
  defp draw_treasure(10), do: "♟️"
  defp draw_treasure(11), do: "🪃"
  defp draw_treasure(12), do: "🍕"
  defp draw_treasure(13), do: "🐢"
  defp draw_treasure(14), do: "💍"
  defp draw_treasure(15), do: "🍸"
  defp draw_treasure(16), do: "🛹"
  defp draw_treasure(17), do: "🥊"
  defp draw_treasure(18), do: "🪈"
  defp draw_treasure(19), do: "🛴"
  defp draw_treasure(20), do: "🧯"
  defp draw_treasure(21), do: "🧪"
  defp draw_treasure(22), do: "🏹"
  defp draw_treasure(23), do: "🧩"
  defp draw_treasure({_, treasure}), do: draw_treasure(treasure)
end
