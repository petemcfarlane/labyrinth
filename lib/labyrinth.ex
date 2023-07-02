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

  alias Labyrinth.{Board, Player}

  @doc """
  Shuffles the movable tiles and treasures and places them on a grid.

  The grid is a multi dimensional list of 7 rows and 7 columns.
  Each position is represented by as a tuple {tile, treasure}.
  Each tile is represented by a binary number, where each bit represents
  the possible directions of travel, north, south, east or west.

  ## Examples

      iex> %{grid: _, next_tile: _} = Labyrinth.init()
  """
  def init(players) when length(players) >= 2 and length(players) <= 24 do
    num_of_players = players |> length()
    amount_of_treasure = div(24, num_of_players)
    shuffled_treasure = 0..23 |> Enum.to_list() |> Enum.shuffle()
    pawns = Enum.shuffle(["🤠", "👽", "👾", "🤖", "🥷", "🦸", "🧙", "🦹", "🧜"])

    players =
      players
      |> Enum.with_index()
      |> Enum.map(fn {name, i} ->
        %Player{
          name: name,
          remaining_treasures:
            Enum.slice(
              shuffled_treasure,
              i * amount_of_treasure,
              amount_of_treasure
            ),
          found_treasures: [],
          pawn: Enum.at(pawns, i),
          position:
            case rem(i, 4) do
              0 -> {0, 0}
              1 -> {6, 0}
              2 -> {6, 6}
              3 -> {0, 6}
            end
        }
      end)

    shuffled_tiles = Board.shuffle_tiles()
    initial_grid = Board.init(shuffled_tiles)
    grid = Board.place_players_on_grid(initial_grid, players)
    next_tile = Enum.at(shuffled_tiles, 33)

    %{
      grid: grid,
      next_tile: next_tile,
      players: players
    }
  end
end
