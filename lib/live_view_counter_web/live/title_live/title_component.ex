defmodule LiveViewCounterWeb.TitleLive.TitleComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
    <h1><%= @title %></h1>
    <div>
      <!-- submit action triggers "set_title" event -->
      <%= f = form_for :heading, "#", [phx_submit: :set_title] %>
        <%= label f, :title %>
        <%= text_input f, :title %>
        <div>
          <%= submit "Set", phx_disable_with: "Setting..." %>
        </div>
      </form>
    </div>
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
