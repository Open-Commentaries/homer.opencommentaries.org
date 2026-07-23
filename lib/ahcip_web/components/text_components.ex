defmodule AHCIPWeb.TextComponents do
  @moduledoc """
  Recursive renderer for TEI elements as exported to JSON by `mix kodon.parse`
  (see `Kodon.TEIParser`). Generic over tagname — no work-specific logic.
  """
  use Phoenix.Component

  # Text run (leaf node with text content)
  def text_container(%{element: %{"text" => text}} = assigns) when is_binary(text) do
    assigns = assign(assigns, :text, text)
    ~H"<%= @text %>"
  end

  # head
  def text_container(%{element: %{"tagname" => "head"}} = assigns) do
    ~H"""
    <header class="tei-head mb-4">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </header>
    """
  end

  # title (inline citation)
  def text_container(%{element: %{"tagname" => "title"}} = assigns) do
    ~H"""
    <cite class="tei-title">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </cite>
    """
  end

  # persName
  def text_container(%{element: %{"tagname" => "persName"}} = assigns) do
    ~H"""
    <span class="tei-persName">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </span>
    """
  end

  # seg
  def text_container(%{element: %{"tagname" => "seg"}} = assigns) do
    ~H"""
    <span class="tei-seg">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </span>
    """
  end

  # date
  def text_container(%{element: %{"tagname" => "date"}} = assigns) do
    ~H"""
    <span class="tei-date">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </span>
    """
  end

  # l (line of verse)
  def text_container(%{element: %{"tagname" => "l"}} = assigns) do
    ~H"""
    <div class="tei-l flex justify-between" id={"line-" <> to_string(@element["attrs"]["n"])}>
      <div class="tei-inner-l">
        <%= for child <- @element["children"] do %>
          <.text_container element={child} />
        <% end %>
      </div>
      <%= if show_line_n?(@element["attrs"]["n"]) do %>
        <span class="select-none text-sm text-base-content/40 ml-4 shrink-0"><%= @element["attrs"]["n"] %></span>
      <% end %>
    </div>
    """
  end

  # milestone — strophic/book division marker
  def text_container(
        %{element: %{"tagname" => "milestone", "attrs" => %{"unit" => "strophe"}}} = assigns
      ) do
    ~H"""
    <div
      class="tei-milestone relative h-4 my-1"
      data-n={@element["attrs"]["n"]}
      data-subtype={@element["attrs"]["subtype"]}
    >
      <span class="select-none text-xs text-base-content/40 absolute right-0">
        <%= milestone_label(@element["attrs"]["subtype"]) %>.&nbsp;<%= @element["attrs"]["n"] %>
      </span>
    </div>
    """
  end

  # milestone — other (e.g. card/section references): invisible anchor
  def text_container(%{element: %{"tagname" => "milestone"}} = assigns) do
    ~H"""
    <span
      class="tei-milestone"
      data-n={@element["attrs"]["n"]}
      data-unit={@element["attrs"]["unit"]}
    ></span>
    """
  end

  # placeName
  def text_container(%{element: %{"tagname" => "placeName"}} = assigns) do
    ~H"""
    <span class="tei-placeName font-medium">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </span>
    """
  end

  # note — dialog footnote
  def text_container(%{element: %{"tagname" => "note"}} = assigns) do
    ~H"""
    <sup class="tei-note">
      <button
        type="button"
        class="cursor-pointer text-blue-600 hover:text-blue-800 font-bold leading-none"
        onclick={"document.getElementById('note-#{@element["index"]}').showModal()"}
        aria-label="Show note"
      >*</button>
    </sup>
    <dialog
      id={"note-#{@element["index"]}"}
      class="tei-note-dialog rounded p-4 shadow-lg max-w-prose w-full mt-16 mx-auto backdrop:bg-black/40"
    >
      <form method="dialog" class="flex justify-end mb-2">
        <button type="submit" class="cursor-pointer font-bold text-lg leading-none" aria-label="Close">&times;</button>
      </form>
      <div class="tei-note-content text-sm prose">
        <%= for child <- @element["children"] do %>
          <.text_container element={child} />
        <% end %>
      </div>
    </dialog>
    """
  end

  # bibl
  def text_container(%{element: %{"tagname" => "bibl"}} = assigns) do
    ~H"""
    <span class="tei-bibl">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </span>
    """
  end

  # p
  def text_container(%{element: %{"tagname" => "p"}} = assigns) do
    ~H"""
    <p class="tei-p prose">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </p>
    """
  end

  # lg (line group)
  def text_container(%{element: %{"tagname" => "lg"}} = assigns) do
    ~H"""
    <div class="tei-lg">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </div>
    """
  end

  # div
  def text_container(%{element: %{"tagname" => "div"}} = assigns) do
    ~H"""
    <div class="tei-div prose mb-4" data-urn={@element["urn"]}>
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </div>
    """
  end

  # quote
  def text_container(%{element: %{"tagname" => "quote"}} = assigns) do
    ~H"""
    <blockquote class="tei-quote prose">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </blockquote>
    """
  end

  # sp (speech)
  def text_container(%{element: %{"tagname" => "sp"}} = assigns) do
    ~H"""
    <h6 class="tei-sp prose">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </h6>
    """
  end

  # speaker
  def text_container(%{element: %{"tagname" => "speaker"}} = assigns) do
    ~H"""
    <div class="tei-speaker font-bold mt-4">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </div>
    """
  end

  # stage
  def text_container(%{element: %{"tagname" => "stage"}} = assigns) do
    ~H"""
    <span class="tei-stage italic text-base-content/60">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </span>
    """
  end

  # s (sentence)
  def text_container(%{element: %{"tagname" => "s"}} = assigns) do
    ~H"""
    <span class="tei-s">
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </span>
    """
  end

  # lb (line break)
  def text_container(%{element: %{"tagname" => "lb"}} = assigns) do
    ~H"<br />"
  end

  # pb (page break)
  def text_container(%{element: %{"tagname" => "pb"}} = assigns) do
    ~H"<br />"
  end

  # fallback — unknown tagname rendered as a classed span
  def text_container(%{element: %{"tagname" => _tagname, "children" => _children}} = assigns) do
    ~H"""
    <span class={"tei-#{@element["tagname"]}"}>
      <%= for child <- @element["children"] do %>
        <.text_container element={child} />
      <% end %>
    </span>
    """
  end

  # empty fallback
  def text_container(assigns) do
    ~H""
  end

  defp show_line_n?(nil), do: false

  defp show_line_n?(n) do
    case Integer.parse(n) do
      {int, _} -> int == 1 or rem(int, 5) == 0
      _ -> false
    end
  end

  defp milestone_label("str."), do: "str"
  defp milestone_label("ant."), do: "ant"
  defp milestone_label("epode"), do: "ep"
  defp milestone_label(subtype), do: subtype
end
