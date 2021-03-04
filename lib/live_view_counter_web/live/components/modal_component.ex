defmodule LiveViewCounterWeb.Components.ModalComponent do
  use Phoenix.LiveComponent

  # define module attributes (global constants)
  @defaults %{
    left_button: "Cancel",
    left_button_action: nil,
    left_button_param: nil,
    right_button: "OK",
    right_button_action: nil,
    right_button_action: nil
  }

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @doc """
    update/2: merges the passed in assigns with a set of defaults,
              giving preference to the passed in assigns
  """
  def update(%{id: _id} = assigns, socket) do
    {:ok, assign(socket, Map.merge(@defaults, assigns))}
  end

  def handle_event(
        "right-button-click",
        _params,
        %{
          assigns: %{
            right_button_action: right_button_action,
            right_button_param: right_button_param
          }
        } = socket
      ) do
    send(
      self(),
      {__MODULE__, :button_clicked, %{action: right_button_action, param: right_button_param}}
    )

    {:noreply, socket}
  end

  def handle_event(
        "left-button-click",
        _params,
        %{
          assigns: %{
            left_button_action: left_button_action,
            left_button_param: left_button_param
          }
        } = socket
      ) do
    send(
      self(),
      {__MODULE__, :button_clicked, %{action: left_button_action, param: left_button_param}}
    )

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="modal-<%= @id %>">
      <!-- Modal Background -->
      <!-- phx-hook registers a JavaScript hook with the background container -->
      <div class="modal-container"
          phx-hook="ScrollLock">
        <div class="modal-inner-container">
          <div class="modal-card">
            <div class="modal-inner-card">
              <!-- Title -->
              <%= if @title != nil do %>
              <div class="modal-title">
                <%= @title %>
              </div>
              <% end %>

              <!-- Body -->
              <%= if @body != nil do %>
              <div class="modal-body">
                <%= @body %>
              </div>
              <% end %>

              <!-- Buttons -->
              <div class="modal-buttons">
                  <!-- Left Button -->
                  <button class="left-button"
                          type="button"
                          phx-click="left-button-click"
                          phx-target="#modal-<%= @id %>">
                    <div>
                      <%= @left_button %>
                    </div>
                  </button>
                  <!-- Right Button -->
                  <button class="right-button"
                          type="button"
                          phx-click="right-button-click"
                          phx-target="#modal-<%= @id %>">
                    <div>
                      <%= @right_button %>
                    </div>
                  </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
