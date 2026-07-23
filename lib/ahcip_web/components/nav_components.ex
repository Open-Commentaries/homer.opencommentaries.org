defmodule AHCIPWeb.NavComponents do
  use Phoenix.Component

  alias AHCIP.WorkRegistry

  @doc """
  Renders the sidebar navigation: one collapsible group per work (Iliad,
  Odyssey, Homeric Hymns), each listing its sections as links to
  `/passages/:urn`. `current_urn` is the full URN of the section being
  viewed, if any (nil on the home/about pages).
  """
  attr(:current_urn, :string, default: nil)

  def work_nav(assigns) do
    assigns = assign(assigns, :works, WorkRegistry.works())

    ~H"""
    <ul class="menu menu-sm bg-base-100 rounded-box w-full">
      <.nav_group :for={{title, works} <- grouped(@works)} title={title} works={works} current_urn={@current_urn} />
    </ul>
    """
  end

  attr(:title, :string, required: true)
  attr(:works, :list, required: true)
  attr(:current_urn, :string, default: nil)

  defp nav_group(assigns) do
    open = Enum.any?(assigns.works, &work_active?(&1, assigns.current_urn))
    assigns = assign(assigns, :open, open)

    ~H"""
    <li>
      <details open={@open}>
        <summary class="font-semibold"><%= @title %></summary>
        <ul>
          <%= for work <- @works do %>
            <%= if work.section_type == :hymn do %>
              <.nav_section work={work} n={1} label={work.title} current_urn={@current_urn} />
            <% else %>
              <%= for n <- work.sections do %>
                <.nav_section work={work} n={n} label={"#{work.section_label} #{n}"} current_urn={@current_urn} />
              <% end %>
            <% end %>
          <% end %>
        </ul>
      </details>
    </li>
    """
  end

  attr(:work, :map, required: true)
  attr(:n, :integer, required: true)
  attr(:label, :string, required: true)
  attr(:current_urn, :string, default: nil)

  defp nav_section(assigns) do
    urn = "#{assigns.work.urn}:#{assigns.n}"
    assigns = assign(assigns, :urn, urn)

    ~H"""
    <li>
      <a
        href={"/passages/" <> @urn}
        class={if @urn == @current_urn, do: "menu-active", else: ""}
      >
        <%= @label %>
      </a>
    </li>
    """
  end

  defp grouped(works) do
    iliad = Enum.filter(works, &(&1.slug == "tlg0012.tlg001"))
    odyssey = Enum.filter(works, &(&1.slug == "tlg0012.tlg002"))
    hymns = Enum.filter(works, &(&1.section_type == :hymn))

    [{"The Iliad", iliad}, {"The Odyssey", odyssey}, {"Homeric Hymns", hymns}]
    |> Enum.reject(fn {_title, works} -> works == [] end)
  end

  defp work_active?(work, current_urn) when is_binary(current_urn) do
    String.starts_with?(current_urn, work.urn <> ":")
  end

  defp work_active?(_work, _current_urn), do: false
end
