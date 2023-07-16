defmodule LabyrinthWeb.LabyrinthLive do
  import Bitwise

  use LabyrinthWeb, :live_view
  use Phoenix.Component

  def mount(_params, _session, socket) do
    game = Labyrinth.init(["Pete", "Lucy", "Sally", "John"])
    {:ok, assign(socket, game: game)}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>Labyrinth</h1>
      <div class="grid grid-cols-7 grid-rows-7 grid-flow-row">
        <%= for {{x, y}, {tile, treasure, players} } <- @game.grid  do %>
          <%!-- <span class={"order-#{rem(y, 7) * 7 + x + 1}"}>
            <%= "{#{x}, #{y}}" %>
            <%= "tile: #{tile}" %>
            <%= "treasure: #{treasure}" %>
          </span> --%>
          <.tile tile={tile} order={rem(x, 7) * 7 + y + 1} x={x} y={y} players={players} />
        <% end %>
      </div>
    </div>
    """
  end

  def tile(assigns) do
    ~H"""
    <svg
      tile={@tile}
      class={"drop-shadow order-#{@order}"}
      width="96"
      height="96"
      x={@x}
      y={@y}
      xmlns="http://www.w3.org/2000/svg"
    >
      <g>
        <rect
          stroke-width="2"
          id="border"
          height="94"
          width="94"
          x="1"
          y="1"
          stroke="#000000"
          fill="transparent"
          rx="8"
          ry="8"
        />
        <%= if (@tile &&& 0b1000) == 0b1000 do %>
          <rect
            stroke-width="10"
            id="N"
            height="48"
            width="38"
            x="30"
            stroke="#ff0000"
            fill="#ff0000"
          />
        <% end %>
        <%= if (@tile &&& 0b0100) == 0b0100 do %>
          <rect
            stroke-width="10"
            id="E"
            height="38"
            width="48"
            x="49"
            y="30"
            stroke="#ff0000"
            fill="#ff0000"
          />
        <% end %>
        <%= if (@tile &&& 0b0010) == 0b0010 do %>
          <rect
            stroke-width="10"
            id="S"
            height="48"
            width="38"
            x="30"
            y="49"
            stroke="#ff0000"
            fill="#ff0000"
          />
        <% end %>
        <%= if (@tile &&& 0b0001) == 0b0001 do %>
          <rect
            stroke-width="10"
            id="W"
            height="38"
            width="48"
            y="30"
            stroke="#ff0000"
            fill="#ff0000"
          />
        <% end %>

        <rect
          stroke-width="10"
          id="S"
          height="38"
          width="38"
          x="30"
          y="30"
          stroke="#ff0000"
          fill="#ff0000"
        />

        <text class="text-xl" x="38" y="55"><%= @players |> Enum.map(& &1.pawn) %></text>
      </g>
    </svg>
    """
  end
end
