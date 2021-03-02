defmodule LiveViewCounterWeb.Counter do
  # use the Phoenix.LiveView behavior
  use Phoenix.LiveView

  @doc """
    mount/3: mounts the module and returns a tuple
      - :ok
      - assign a key :val to the socket (initialized to 0)
  """
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :val, 0)}
  end

  @doc """
    handle_event/3: handles "inc" event by incrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by adding 1 to the current value
          &(&1 + 1) is the same as fn val -> val + 1 end
  """
  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  @doc """
    handle_event/3: handles "dec" event by decrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by subtracting 1 from the current value
          &(&1 - 1) is the same as fn val -> val - 1 end
  """
  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
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
