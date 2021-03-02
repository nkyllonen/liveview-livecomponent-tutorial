defmodule LiveViewCounterWeb.Counter do
  # use the Phoenix.LiveView behavior
  use Phoenix.LiveView

  alias LiveViewCounter.Count
  alias Phoenix.PubSub

  # define a module attribute (global constant)
  @topic "live"

  @doc """
    mount/3: mounts the module and returns a tuple
      - :ok
      - assign a key :val to the socket (initialized to 0)
  """
  def mount(_params, _session, socket) do
    # subscribe to the channel topic
    PubSub.subscribe(LiveViewCounter.PubSub, @topic)

    {:ok, assign(socket, :val, Count.current())}  # make API call to get current value!
  end

  @doc """
    handle_event/3: handles "inc" event by incrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by calling incr() in API
  """
  def handle_event("inc", _, socket) do
    {:noreply, assign(socket, :val, Count.incr())}
  end

  @doc """
    handle_event/3: handles "dec" event by decrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by calling decr() in API
  """
  def handle_event("dec", _, socket) do
    {:noreply, assign(socket, :val, Count.decr())}
  end

  @doc """
    handle_info/2: handles Elixir process messages where msg is the received message
                    and socket is the Phoenix.Socket
      - :noreply: "don't send this message to the socket again"
                  (which would cause a recursive loop of updates)
      - add key value pair (val, count) to socket assigns
  """
  def handle_info({:count, count}, socket) do
    {:noreply, assign(socket, val: count)}
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
