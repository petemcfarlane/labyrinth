defmodule Labyrinth.Player do
  defstruct [
    :name,
    :position,
    :pawn,
    :remaining_treasures,
    found_treasures: []
  ]
end
