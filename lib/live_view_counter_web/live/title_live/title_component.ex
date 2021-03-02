defmodule LiveViewCounterWeb.TitleLive.TitleComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <h1><%= @title %></h1>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  @doc """
    update/2: take passed in assigns and add values to its own socket assigns
  """
  def update(%{title: title} = _assigns, socket) do
    {:ok, assign(socket, title: title)}
  end
end
