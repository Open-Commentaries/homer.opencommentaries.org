defmodule AHCIP.Texts do
  @moduledoc """
  Reads the per-work Greek TEI JSON exported by `mix kodon.parse` (see
  `priv/static/json`) and resolves a passage URN to its textpart + elements.
  """

  alias AHCIP.WorkRegistry

  @json_dir "priv/static/json"

  @doc """
  Resolve a full passage URN, e.g. "urn:cts:greekLit:tlg0012.tlg001:5" or
  "urn:cts:greekLit:tlg0013.tlg001:1", to its work, textpart, and elements.
  """
  @spec get_section(String.t()) :: {:ok, map()} | :error
  def get_section(full_urn) do
    with {:ok, work_slug, section_n} <- split_urn(full_urn),
         %{} = work <- WorkRegistry.find_by_slug(work_slug),
         path <- json_path(work),
         true <- File.exists?(path),
         {:ok, raw} <- File.read(path),
         {:ok, decoded} <- Jason.decode(raw),
         textpart when not is_nil(textpart) <-
           find_textpart(decoded["textparts"], work, section_n) do
      elements = Enum.filter(decoded["elements"], &(&1["textpart_index"] == textpart["index"]))

      {:ok,
       %{
         work: work,
         section: section_n,
         urn: full_urn,
         title: decoded["title"],
         textpart: textpart,
         elements: elements
       }}
    else
      _ -> :error
    end
  end

  defp split_urn(full_urn) do
    case String.split(full_urn, "urn:cts:greekLit:", parts: 2) do
      [_, rest] ->
        case String.split(rest, ":", parts: 2) do
          [work_slug, n] -> {:ok, work_slug, n}
          _ -> :error
        end

      _ ->
        :error
    end
  end

  defp find_textpart(textparts, %{section_type: :book}, n) do
    Enum.find(textparts, fn tp ->
      tp["subtype"] != nil and String.downcase(tp["subtype"]) == "book" and tp["n"] == n
    end)
  end

  defp find_textpart(textparts, %{section_type: :hymn}, _n) do
    Enum.find(textparts, &(&1["subtype"] == nil))
  end

  defp json_path(work) do
    Path.join(@json_dir, String.replace_suffix(work.tei_path, ".xml", ".json"))
  end
end
