defmodule LiveViewCounterWeb.Counter do
  # use the Phoenix.LiveView behavior
  use Phoenix.LiveView

  alias LiveViewCounter.Count
  alias Phoenix.PubSub
  alias LiveViewCounter.Presence

  # define module attributes (global constants)
  @topic Count.topic
  @presence_topic "presence"

  @doc """
    mount/3: mounts the module and returns a tuple
      - :ok
      - assign a key :val to the socket (initialized to 0)
  """
  def mount(_params, _session, socket) do
    # subscribe to the channel topic
    PubSub.subscribe(LiveViewCounter.PubSub, @topic)

    # subscribe, participate-in, and subscribe to the Presence system
    Presence.track(self(), @presence_topic, socket.id, %{})
    LiveViewCounterWeb.Endpoint.subscribe(@presence_topic)

    initial_present =
      Presence.list(@presence_topic)
      |> map_size

    # make API call to get current value!
    {:ok, assign(socket, val: Count.current(),
        present: initial_present,
        title: "Initial Title")}
  end

  @doc """
    handle_event/3: handles "inc" event by incrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by calling incr() in API

    handle_event/3: handles "dec" event by decrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by calling decr() in API

    handle_event/3: handles "set_title" event by updating title in its socket assigns
  """
  def handle_event("inc", _, socket) do
    {:noreply, assign(socket, :val, Count.incr())}
  end

  def handle_event("dec", _, socket) do
    {:noreply, assign(socket, :val, Count.decr())}
  end

  def handle_event(
      "set_title",
      %{"heading" => %{"title" => updated_title}},
      socket) do
    {:noreply, assign(socket, title: updated_title)}
  end

  @doc """
    handle_info/2: handles Elixir process messages where msg is the received message
                    and socket is the Phoenix.Socket
      - :noreply: "don't send this message to the socket again"
                  (which would cause a recursive loop of updates)
      - add key value pair (val, count) to socket assigns

    handle_info/2: handle Presence updates, adding joiners and subtracting leavers
      - :noreply
      - add key value pair (present, new_present) to socket assigns
  """
  def handle_info({:count, count}, socket) do
    {:noreply, assign(socket, val: count)}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{present: present}} = socket
    ) do
    new_present = present + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :present, new_present)}
  end

  @doc """
    render/1: renders the template using the :val state within the assigns argument
      - renders LiveView templates using the ~L sigil
        (macro included by "use Phoenix.LiveView")
  """
  def render(assigns) do
    ~L"""
    <div>
      <%= live_component(
        @socket,
        LiveViewCounterWeb.TitleLive.TitleComponent,
        title: @title
      )
      %>
      <h1>The count is: <%= @val %></h1>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
      <h1>Current users: <%= @present %></h1>
    </div>
    """
  end
end
