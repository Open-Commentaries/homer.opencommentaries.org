defmodule AHCIP.GreekSource do
  @moduledoc """
  Builds a `%{line_number_string => "greek text"}` map from the JSON-shaped
  element list returned by `AHCIP.Texts.get_section/1`, for use by
  `AHCIP.FallbackMerge` (gap-length calculation, Greek fill-in text, Scaife
  linking).

  Walks the element tree to collect `<l n="N">` text regardless of nesting
  (e.g. lines inside `<q>` or other container elements).
  """

  @doc """
  Collect `<l n="N">` text from a list of top-level elements (as decoded from
  the JSON produced by `mix kodon.parse`).

  Returns `%{line_number_string => "greek text"}`.
  """
  @spec line_map([map()]) :: %{String.t() => String.t()}
  def line_map(elements) do
    Enum.reduce(elements, %{}, &collect/2)
  end

  defp collect(%{"tagname" => "l", "attrs" => %{"n" => n}} = element, acc) when is_binary(n) do
    text = element |> full_text() |> String.trim() |> collapse_whitespace()
    acc = if text == "", do: acc, else: Map.put(acc, n, text)
    Enum.reduce(element["children"] || [], acc, &collect/2)
  end

  defp collect(%{"children" => children}, acc) do
    Enum.reduce(children || [], acc, &collect/2)
  end

  defp collect(_leaf, acc), do: acc

  defp full_text(%{"text" => text}) when is_binary(text), do: text

  defp full_text(%{"children" => children}) do
    children |> Enum.map(&full_text/1) |> Enum.join()
  end

  defp full_text(_), do: ""

  defp collapse_whitespace(text), do: Kodon.TEIParser.collapse_whitespace(text)
end
