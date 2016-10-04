defmodule Flashcards do

  def parse_data(filename) do
    {:ok, body} = File.read("questions/#{filename}.txt")

    lines = String.split(body, "\n") 
            |> Enum.filter(fn(x) -> x != "" end)

    question = []
    answer   = []

    question_start = Enum.find_index(lines, fn(x) -> x == "<question>" end)
    question_end   = Enum.find_index(lines, fn(x) -> x == "</question>" end)
    answer_start   = Enum.find_index(lines, fn(x) -> x == "<answer>" end)
    answer_end     = Enum.find_index(lines, fn(x) -> x == "</answer>" end)

    questions = Enum.with_index(lines)
                |> Enum.filter(fn({val, idx}) -> idx > question_start && idx < question_end end)
                |> Enum.map(fn({val, idx}) -> val end)


    answers   = Enum.with_index(lines)
                |> Enum.filter(fn({val, idx}) -> idx > answer_start && idx < answer_end end)
                |> Enum.map(fn({val, idx}) -> val end)
    

    {questions, answers}
  end

  def viewport_width(text_lines) do 
    longest_str = text_lines
                  |> Enum.max_by(fn(x) -> String.length(x) end)
                  |> String.length

    width_for_str(longest_str)
  end

  def width_for_str(width) when width <= 10 do
    10
  end

  def width_for_str(width) when width < 140 and width > 10 do
    15/(width/10)
  end

  def width_for_str(width) when width >= 140 do
    1
  end

  def generate_html(question, filename) do
    vw_width = viewport_width(question)

    page = """
    <html>
      <head>
      </head>
      <body role="document" style="position:absolute; width:100%; height:100%;">
        <div style="display:table; width:100%; min-height:100%;">
          <div style="display:table-cell; text-align:center; vertical-align:middle; font-size:#{vw_width}vw;">
            #{ Enum.join(question, "<br/>") }
          </div>
        </div>
      </body>
    </html>
    """

    File.write("./output/#{filename}.html" , page)
    IO.puts page
  end


  def generate_site do

    {_, files} = File.ls("./questions")
    html_files = files
                 |> Enum.reject(fn(x) -> List.last(String.split(x, ".")) != "txt" end)
                 |> Enum.map(fn(x) -> List.first(String.split(x, ".")) end)
    
    Enum.each(html_files, fn(x) ->
      {question, answer} = parse_data(x)
    
      generate_html(question, "q#{x}")
      generate_html(answer, "a#{x}")
    end)

  end
end
