defmodule LiveViewCounterWeb.CounterLive do
  use LiveViewCounterWeb, :live_view

  alias LiveViewCounter.Count
  alias Phoenix.PubSub
  alias LiveViewCounter.Presence

  # define module attributes (global constants)
  @topic Count.topic()
  @presence_topic "presence"

  @doc """
    mount/3: mounts the module and returns a tuple (can be used to set any initial state)
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
    {:ok, assign(socket, val: Count.current(), present: initial_present)}
  end

  @doc """
    handle_event/3: handles "inc" event by incrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by calling incr() in API

    handle_event/3: handles "dec" event by decrementing counter and returning a tuple
      - :noreply: "do not send any further messages to the caller of this function"
      - update key :val by calling decr() in API

    handle_event/3: handles "go-boom" event from BOOM button
      - push_patch redirects back to this same LiveView therefore calling into the
        handle_params/3
      - replace is true, meaning the URL will be replaced on the pushState stack
        (just a Modal, we don't want users to be able to navigate directly there)
  """
  def handle_event("inc", _, socket) do
    {:noreply, assign(socket, :val, Count.incr())}
  end

  def handle_event("dec", _, socket) do
    {:noreply, assign(socket, :val, Count.decr())}
  end

  def handle_event("go-boom", _, socket) do
    {:noreply,
     push_patch(
       socket,
       to: Routes.counter_path(socket, :confirm_boom),
       replace: true
     )}
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

    handle_info/2: handle crash message from ModalComponent
      - crash the page by raising an exception
      - is then handled by catch-all handle_params/4 since we are in an invalid state

    handle_info/2: handle cancel-crash message from ModalComponent
      - redirect back to the original counter page
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

  def handle_info(
        {
          LiveViewCounterWeb.Components.ModalComponent,
          :button_clicked,
          %{action: "crash", param: exception}
        },
        socket
      ) do
    raise(exception)
    {:noreply, socket}
  end

  def handle_info(
        {
          LiveViewCounterWeb.Components.ModalComponent,
          :button_clicked,
          %{action: "cancel-crash"}
        },
        socket
      ) do
    {:noreply,
     push_patch(
       socket,
       to: Routes.counter_path(socket, :show),
       replace: true
     )}
  end

  @doc """
    handle_params/3: redirects to apply_action/3 to determine reaction to incoming action
  """
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @doc """
    apply_action/3: match :show live_action atom
      - trying to go to the :show page, so hide the Modal

    apply_action/3: match :confirm_boom live_action atom
      - trying to see the Modal, so show the Modal

    apply_action/3: catch-all that redirects to the base counter path
      - replace the URL on the pushState stack so that any invalid URLs
        will not be preserved in the browsing history
  """
  def apply_action(socket, :show, _params) do
    assign(socket, show_modal: false)
  end

  def apply_action(%{assigns: %{show_modal: _}} = socket, :confirm_boom, _params) do
    assign(socket, show_modal: true)
  end

  def apply_action(socket, _live_action, _params) do
    push_patch(socket,
      to: Routes.counter_path(socket, :show),
      replace: true
    )
  end

  @doc """
    render/1: renders the template using the :val state within the assigns argument
      - renders LiveView templates using the ~L sigil
        (macro included by "use Phoenix.LiveView")
      - conditionally renders Modal
  """
  def render(assigns) do
    ~L"""
    <div>
      <h1>The count is: <%= @val %></h1>
      <button class="alert-danger" phx-click="go-boom">BOOM</button>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
      <h1>Current users: <%= @present %></h1>
    </div>

    <%= if @show_modal do %>
      <%= live_component(
        @socket,
        LiveViewCounterWeb.Components.ModalComponent,
        id: "confirm-boom",
        title: "Go Boom",
        body: "Are you sure you want to crash the counter?",
        right_button: "Sure",
        right_button_action: "crash",
        right_button_param: "boom",
        left_button: "Yikes, No!",
        left_button_action: "cancel-crash",
        left_button_param: nil
      ) %>
    <% end %>
    """
  end
end
