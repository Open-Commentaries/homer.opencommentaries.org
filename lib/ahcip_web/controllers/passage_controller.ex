defmodule AHCIPWeb.PassageController do
  use AHCIPWeb, :controller

  alias AHCIP.{Commentary, FallbackMerge, GreekSource, Texts, Translations}
  alias Kodon.Translation.{Book, Parser}

  def show(conn, %{"urn" => full_urn}) do
    case Texts.get_section(full_urn) do
      {:ok, section} ->
        render_section(conn, section)

      :error ->
        conn
        |> put_status(:not_found)
        |> put_view(AHCIPWeb.ErrorHTML)
        |> render(:"404")
    end
  end

  defp render_section(conn, %{work: work} = section) do
    section_number = String.to_integer(section.section)
    greek_lines = GreekSource.line_map(section.elements)
    comments = Commentary.for_section(work.slug, section_number)

    if work.has_scholar_translations do
      book = scholar_book(section_number)
      content = FallbackMerge.merge(book, greek_lines)
      display_title = FallbackMerge.display_title(book, work)

      render(conn, :show,
        mode: :scholar,
        work: work,
        section: section,
        section_number: section_number,
        display_title: display_title,
        content: content,
        greek_lines: greek_lines,
        comments: comments
      )
    else
      render(conn, :show,
        mode: :greek,
        work: work,
        section: section,
        section_number: section_number,
        display_title: FallbackMerge.display_title(%Book{number: section_number}, work),
        comments: comments
      )
    end
  end

  defp scholar_book(section_number) do
    Translations.iliad_file_mapping()
    |> Enum.find(fn {_filename, n} -> n == section_number end)
    |> case do
      {filename, ^section_number} ->
        translation_dir = Application.get_env(:ahcip, :translation_dir)
        path = Path.join(translation_dir, filename)

        if File.exists?(path) do
          Parser.parse_file(path)
        else
          %Book{number: section_number, title: nil, translators: [], lines: []}
        end

      nil ->
        %Book{number: section_number, title: nil, translators: [], lines: []}
    end
  end
end
