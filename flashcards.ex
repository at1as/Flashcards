defmodule Flashcards do

  def parse_data(filename) do
    {:ok, body} = File.read("questions/#{filename}.txt")

    lines = String.split(body, "\n") 
            |> Enum.filter(fn(x) -> x != "" end)

    question_start = Enum.find_index(lines, fn(x) -> x == "<question>" end)
    question_end   = Enum.find_index(lines, fn(x) -> x == "</question>" end)
    answer_start   = Enum.find_index(lines, fn(x) -> x == "<answer>" end)
    answer_end     = Enum.find_index(lines, fn(x) -> x == "</answer>" end)

    questions = Enum.with_index(lines)
                  |> Enum.filter(fn({_val, idx}) -> idx > question_start && idx < question_end end)
                  |> Enum.map(fn({val, _idx}) -> val end)


    answers   = Enum.with_index(lines)
                  |> Enum.filter(fn({_val, idx}) -> idx > answer_start && idx < answer_end end)
                  |> Enum.map(fn({val, _idx}) -> val end)
    

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

  def generate_html(text_lines, filename, file_count) do
    vw_width = viewport_width(text_lines)

    page = """
    <html>
      <head>
      </head>
      <body role="document" style="position:absolute; width:100%; height:100%; background-color:#3F3F5F; color:#FFF">
        <div style="display:table; width:100%; min-height:100%;">
          <div style="display:table-cell; text-align:center; vertical-align:middle; font-size:#{vw_width}vw;">
            #{ Enum.join(text_lines, "<br/>") }
          </div>
        </div>
        <input type="hidden" id="slideCount" value="#{file_count}">
        <script type="text/javascript">
          document.onkeydown = function(e) {
            e = e || window.event;
            switch(e.which || e.keyCode) {
              case 39: //right
                var extensionless_url = location.href.replace(/\.[^/.]+$/, '');
                var slide_num = extensionless_url.slice(-1);
                var slide_limit = #{file_count};

                if (extensionless_url.slice(-2, -1) === 'q'){
                  var slide_path = 'a' + slide_num + '.html';
                  location.replace(extensionless_url.substring(0, extensionless_url.length - 2) + slide_path);
                } else {
                  var next_slide = parseInt(slide_num) + 1
                  if (next_slide > slide_limit){
                    var slide_path = 'q' + 1 + '.html';
                  } else {
                    var slide_path = 'q' + next_slide + '.html';
                  }
                  location.replace(extensionless_url.substring(0, extensionless_url.length - 2) + slide_path);
                }
                break;

              case 37: //left
                var extensionless_url = location.href.replace(/\.[^/.]+$/, '');
                var slide_num = extensionless_url.slice(-1);
                var slide_limit = #{file_count};

                if (extensionless_url.slice(-2, -1) === 'q'){
                  var prev_slide = parseInt(slide_num) - 1;
                  if (prev_slide < 1){
                    var slide_path = 'a' + slide_limit + '.html';
                  } else {
                    var slide_path = 'a' + prev_slide + '.html';
                  }
                  location.replace(extensionless_url.substring(0, extensionless_url.length - 2) + slide_path);
                } else {
                  var slide_path = 'q' + slide_num + '.html';
                  location.replace(extensionless_url.substring(0, extensionless_url.length - 2) + slide_path);
                }
                break;
                
              default: return
            }
            e.preventDefault();
          }
        </script>
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
    
      generate_html(question, "q#{x}", length(html_files))
      generate_html(answer, "a#{x}", length(html_files))
    end)

  end
end
