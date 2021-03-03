defmodule LiveViewCounterWeb.Components.TitlesLiveView do
  use LiveViewCounterWeb, :live_view

  def render(assigns) do
    ~L"""
    <div>
    <%= live_component(
        @socket,
        LiveViewCounterWeb.Components.TitleComponent,
        title: @title
      ) %>

    <%= live_component(
        @socket,
        LiveViewCounterWeb.Components.StatefulComponent,
        id: "1",
        title: @title
      ) %>
      <%= live_component(
        @socket,
        LiveViewCounterWeb.Components.StatefulComponent,
        id: "2",
        title: @title
      ) %>
      <%= live_component(
        @socket,
        LiveViewCounterWeb.Components.StatefulComponent,
        id: "3",
        title: @title
      ) %>

      <%= live_component(
        @socket,
        LiveViewCounterWeb.Components.StatefulComponent,
        id: "stateful-send-self-component",
        title: @title
      ) %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, title: "Initial Title")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @doc """
    handle_event/3: handles "set_title" event by updating title in its socket assigns
  """
  def handle_event(
      "set_title",
      %{"heading" => %{"title" => updated_title}},
      socket) do
    {:noreply, assign(socket, title: updated_title)}
  end

  @doc """
    handle_info/2: receive messages sent by StatefulComponent
      - :noreply
      - add key value pair (title, updated_title) to socket assigns
        (updates :title values across ALL StatefulComponents and the TitleComponent)
  """
  def handle_info(
      {LiveViewCounterWeb.Components.StatefulComponent,
      :updated_title,
      %{title: updated_title}},
      socket
    ) do
      {:noreply, assign(socket, title: updated_title)}
  end
end
