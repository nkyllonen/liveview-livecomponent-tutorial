defmodule LiveViewCounterWeb.Components.BlocksComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def mount(socket) do
    {:ok, socket}
  end

  @doc """
    update/2: invoked with all of the assigns given to live_component/3
      - merge all assigns (that we want) into the socket
  """
  def update(%{title: title, inner_block: inner_block}, socket) do
    {:ok, assign(socket, title: title, render_title: inner_block)}
  end

  def render(assigns) do
    ~L"""
      <%= render_block(@render_title, title_passed_from_component: @title) %>
    """
  end
end
