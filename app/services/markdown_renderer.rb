class MarkdownRenderer < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet

  def block_code(code, language)
    language = language.to_s.strip
    lexer = Rouge::Lexer.find_fancy(language.presence || "plaintext", code) || Rouge::Lexers::PlainText.new
    formatter = Rouge::Formatters::HTMLInline.new(Rouge::Themes::Github.new)
    "<pre class=\"highlight\"><code>#{formatter.format(lexer.lex(code))}</code></pre>"
  end
end
