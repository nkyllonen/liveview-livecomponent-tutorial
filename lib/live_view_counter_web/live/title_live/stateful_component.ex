defmodule LiveViewCounterWeb.TitleLive.StatefulComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
    <h2><%= @title %></h2>
    <div id="stateful-<%= @id %>">
      <!-- submit action triggers "set_title" event -->
      <%= f = form_for :heading, "#",
          [phx_submit: :set_title, "phx-target": "#stateful-#{@id}"] %>
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

  def update(%{title: title, id: id}, socket) do
    {:ok, assign(socket, title: title, id: id)}
  end

@doc """
  preload/1: called before component's update/2, receives list of component assigns
              and maps those to a new set of assigns for each component
              (each component's update/2 functions then receive the new assigns)
"""
def preload(list_of_assigns) do
  Enum.map(list_of_assigns, fn %{id: id, title: title} ->
    %{id: id, title: "#{title} #{id}"}
  end)
end

@doc """
  handle_event/3: handles "set_title" event by sending the new title
                  to the parent LiveView
"""
  def handle_event(
      "set_title",
      %{"heading" => %{"title" => updated_title}},
      socket
    ) do
    send(self(), {__MODULE__, :updated_title, %{title: updated_title}})
    {:noreply, socket}
  end
end
