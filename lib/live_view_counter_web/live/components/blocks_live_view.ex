defmodule LiveViewCounterWeb.Components.BlocksLiveView do
  use LiveViewCounterWeb, :live_view

  def render(assigns) do
    ~L"""
    <div>
    <!-- block that syles the title heading, drawing it in orange -->
    <%= live_component @socket,
                      LiveViewCounterWeb.Components.BlocksComponent,
                      title: "Title" do %>
        <h1 style="color: orange;">
          <%= @title_passed_from_component %>
        </h1>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
