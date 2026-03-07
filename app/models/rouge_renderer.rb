# Custom Redcarpet renderer with Rouge syntax highlighting
class RougeRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    language ||= "text"
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexer.find_fancy(language) || Rouge::Lexers::PlainText.new
    %(<div class="highlight"><pre class="highlight"><code>#{formatter.format(lexer.lex(code))}</code></pre></div>)
  end
end
