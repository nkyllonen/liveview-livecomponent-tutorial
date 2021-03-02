defmodule LiveViewCounterWeb.Counter do
  # use the Phoenix.LiveView behavior
  use Phoenix.LiveView

  # define a module attribute (global constant)
  @topic "live"

  @doc """
    mount/3: mounts the module and returns a tuple
      - :ok
      - assign a key :val to the socket (initialized to 0)
  """
  def mount(_params, _session, socket) do
    # subscribe to the channel topic
    LiveViewCounterWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :val, 0)}
  end

  @doc """
    handle_event/3: handles "inc" event by incrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by adding 1 to the current value
          &(&1 + 1) is the same as fn val -> val + 1 end
  """
  def handle_event("inc", _, socket) do
    new_state = update(socket, :val, &(&1 + 1))  # instance of Phoenix.LiveView.Socket
    # send a message from current process self() on the @topic
    # the key is "inc" the value is the new_state.assigns Map
    LiveViewCounterWeb.Endpoint.broadcast_from(self(), @topic, "inc", new_state.assigns)
    {:noreply, new_state}
  end

  @doc """
    handle_event/3: handles "dec" event by decrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by subtracting 1 from the current value
          &(&1 - 1) is the same as fn val -> val - 1 end
  """
  def handle_event("dec", _, socket) do
    new_state = update(socket, :val, &(&1 - 1))
    LiveViewCounterWeb.Endpoint.broadcast_from(self(), @topic, "dec", new_state.assigns)
    {:noreply, new_state}
  end

  @doc """
    handle_info/2: handles Elixir process messages where msg is the received message
                    and socket is the Phoenix.Socket
      - :noreply: "don't send this message to the socket again"
                  which would cause a recursive loop of updates)
      - add key value pair (val, msg.payload.val) to socket assigns
  """
  def handle_info(msg, socket) do
    {:noreply, assign(socket, val: msg.payload.val)}
  end

  @doc """
    render/1: renders the template using the :val state within the assigns argument
      - renders LiveView templates using the ~L sigil
        (macro included by "use Phoenix.LiveView")
  """
  def render(assigns) do
    ~L"""
    <div>
      <h1>The count is: <%= @val %></h1>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    """
  end
end
