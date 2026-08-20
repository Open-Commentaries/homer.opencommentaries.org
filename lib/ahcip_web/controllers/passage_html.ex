defmodule AHCIPWeb.PassageHTML do
  use AHCIPWeb, :html

  embed_templates("passage_html/*")

  def citation_passage(display_title, comment) do
    line_range =
      if comment["start_line"] == comment["end_line"] do
        "line #{comment["start_line"]}"
      else
        "lines #{comment["start_line"]}–#{comment["end_line"]}"
      end

    "#{display_title}, #{line_range}"
  end
end
