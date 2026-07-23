defmodule AHCIP.Commentary do
  @moduledoc """
  Loads per-author commentary markdown files (see `commentary/*.md` and
  CLAUDE.md for the file format) via the vendored `Kodon.Commentary.Parser`,
  and filters/sorts them for a given work section.
  """

  alias Kodon.Commentary.Parser

  @doc """
  All comments for a given work slug (e.g. "tlg0012.tlg001") and section
  number, sorted by starting line.
  """
  @spec for_section(String.t(), integer()) :: [map()]
  def for_section(work_slug, section_number) do
    work_name = work_name(work_slug)

    all()
    |> Enum.filter(fn comment ->
      comment["work"] == work_name and comment["book"] == section_number
    end)
    |> Enum.sort_by(&{&1["start_line"] || 0, &1["end_line"] || 0})
  end

  @doc """
  Loads and parses every commentary file in the configured commentary
  directory (see `Extractor.parse_urn/1` for the `work`/`book`/`start_line`/
  `end_line` fields each comment map carries).
  """
  @spec all() :: [map()]
  def all do
    Parser.load(commentary_dir())
  end

  defp commentary_dir do
    Application.get_env(:ahcip, :commentary_dir, "commentary")
  end

  # Extractor.parse_urn/1 derives a lowercase work name ("iliad", "odyssey",
  # "hymn") from the comment's URN; mirror that mapping from work slug here.
  defp work_name("tlg0012.tlg001"), do: "iliad"
  defp work_name("tlg0012.tlg002"), do: "odyssey"
  defp work_name("tlg0013." <> _), do: "hymn"
  defp work_name(_), do: nil
end
