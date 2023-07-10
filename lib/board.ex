defmodule Labyrinth.Board do
  import Bitwise

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
      tile, index when index < 8 -> {tile, index, []}
      tile, _index -> {tile, nil, []}
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

  def place_players_on_grid(grid, players) do
    Enum.reduce(players, grid, fn
      player, grid -> place_player_on_grid(grid, player)
    end)
  end

  defp place_player_on_grid(grid, player) do
    Map.update!(grid, player.position, fn
      {tile, treasure, players} -> {tile, treasure, [player | players]}
    end)
  end

  defp gen_tile(dir, treasure, players \\ []), do: {gen_tile(dir), treasure, players}

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
    {new_spare_tile, tile} = move_players_from_old_tile_to_new(grid, {column_index, 6}, tile)

    new_grid =
      grid
      |> Map.replace!({column_index, 0}, tile)
      |> Map.replace!({column_index, 1}, Map.get(grid, {column_index, 0}))
      |> Map.replace!({column_index, 2}, Map.get(grid, {column_index, 1}))
      |> Map.replace!({column_index, 3}, Map.get(grid, {column_index, 2}))
      |> Map.replace!({column_index, 4}, Map.get(grid, {column_index, 3}))
      |> Map.replace!({column_index, 5}, Map.get(grid, {column_index, 4}))
      |> Map.replace!({column_index, 6}, Map.get(grid, {column_index, 5}))

    {new_grid, new_spare_tile}
  end

  defp move_column_up(grid, tile, column_index) do
    {new_spare_tile, tile} = move_players_from_old_tile_to_new(grid, {column_index, 0}, tile)

    new_grid =
      grid
      |> Map.replace!({column_index, 6}, tile)
      |> Map.replace!({column_index, 5}, Map.get(grid, {column_index, 6}))
      |> Map.replace!({column_index, 4}, Map.get(grid, {column_index, 5}))
      |> Map.replace!({column_index, 3}, Map.get(grid, {column_index, 4}))
      |> Map.replace!({column_index, 2}, Map.get(grid, {column_index, 3}))
      |> Map.replace!({column_index, 1}, Map.get(grid, {column_index, 2}))
      |> Map.replace!({column_index, 0}, Map.get(grid, {column_index, 1}))

    {new_grid, new_spare_tile}
  end

  defp move_row_to_right(grid, tile, row_index) do
    {new_spare_tile, tile} = move_players_from_old_tile_to_new(grid, {6, row_index}, tile)

    new_grid =
      grid
      |> Map.replace!({0, row_index}, tile)
      |> Map.replace!({1, row_index}, Map.get(grid, {0, row_index}))
      |> Map.replace!({2, row_index}, Map.get(grid, {1, row_index}))
      |> Map.replace!({3, row_index}, Map.get(grid, {2, row_index}))
      |> Map.replace!({4, row_index}, Map.get(grid, {3, row_index}))
      |> Map.replace!({5, row_index}, Map.get(grid, {4, row_index}))
      |> Map.replace!({6, row_index}, Map.get(grid, {5, row_index}))

    {new_grid, new_spare_tile}
  end

  defp move_row_to_left(grid, tile, row_index) do
    {new_spare_tile, tile} = move_players_from_old_tile_to_new(grid, {0, row_index}, tile)

    new_grid =
      grid
      |> Map.replace!({6, row_index}, tile)
      |> Map.replace!({5, row_index}, Map.get(grid, {6, row_index}))
      |> Map.replace!({4, row_index}, Map.get(grid, {5, row_index}))
      |> Map.replace!({3, row_index}, Map.get(grid, {4, row_index}))
      |> Map.replace!({2, row_index}, Map.get(grid, {3, row_index}))
      |> Map.replace!({1, row_index}, Map.get(grid, {2, row_index}))
      |> Map.replace!({0, row_index}, Map.get(grid, {1, row_index}))

    {new_grid, new_spare_tile}
  end

  defp move_players_from_old_tile_to_new(grid, index, tile_to_insert) do
    {tile, treasure, players_to_move} = Map.get(grid, index)
    new_spare_tile = {tile, treasure, []}

    {tile, treasure, _} = tile_to_insert
    tile_to_insert = {tile, treasure, players_to_move}

    {new_spare_tile, tile_to_insert}
  end

  def move_player!(grid, player, direction) do
    # check player is on grid at position
    {tile, treasure, players} = grid[player.position]

    if player not in players do
      raise "Player not on grid at expected position,
      #{inspect(player)},
      players at #{inspect(player.position)}: #{inspect(players)}"
    end

    # can player move in direction based on the tile they are on?
    case {direction, player.position, tile} do
      {:up, {_x, y}, tile} when y == 0 or (tile &&& 0b1000) == 0 ->
        raise "Cannot move up!"

      {:right, {x, _y}, tile} when x == 6 or (tile &&& 0b0100) == 0 ->
        raise "Cannot move right!"

      {:down, {_x, y}, tile} when y == 6 or (tile &&& 0b0010) == 0 ->
        raise "Cannot move down!"

      {:left, {x, _y}, tile} when x == 0 or (tile &&& 0b0001) == 0 ->
        raise "Cannot move left!"

      _ ->
        :ok
    end

    # remove player from old tile
    old_tile = {tile, treasure, players -- [player]}
    grid = Map.replace!(grid, player.position, old_tile)
    # update player position,

    new_position = move_position(player.position, direction)
    player = %{player | position: new_position}
    # place player on new tile
    Map.update!(grid, new_position, fn {tile, treasure, players} ->
      {tile, treasure, [player | players]}
    end)
  end

  defp move_position({x, y}, :up), do: {x, y - 1}
  defp move_position({x, y}, :right), do: {x + 1, y}
  defp move_position({x, y}, :down), do: {x, y + 1}
  defp move_position({x, y}, :left), do: {x - 1, y}

  def draw_labyrinth({grid, next_tile}) do
    draw_labyrinth(grid)
    IO.puts("Next tile: #{draw_tile(next_tile)}")
    {grid, next_tile}
  end

  def draw_labyrinth(grid) do
    grid
    |> Enum.group_by(fn {{_x, y}, _} -> y end)
    |> Map.values()
    |> Enum.map(fn row ->
      row |> Enum.sort_by(fn {{x, _y}, _tile} -> x end) |> Enum.map(fn {_xy, tile} -> tile end)
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
  defp draw_tile({_tile, _treasure, [%{pawn: pawn}]}), do: pawn
  defp draw_tile({tile, _treasure, _players}), do: draw_tile(tile)

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
  defp draw_treasure({_tile, treasure, _players}), do: draw_treasure(treasure)
end
