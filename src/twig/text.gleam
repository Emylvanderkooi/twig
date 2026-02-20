import twig.{type Content, Text}

/// Creates a plain text element.
///
/// ## Example
/// ```gleam
/// text("Hello, world!")
/// // -> "Hello, world!"
/// ```
pub fn text(s: String) -> Content {
  Text(s)
}

/// Creates a paragraph break by inserting a double newline.
///
/// In Typst, two newlines create a new paragraph, similar to Markdown.
///
/// ## Example
/// ```gleam
/// Sequence([
///   strong([], [text("Hello")]),
///   line_break(),
///   emph([], [text("World")]),
/// ])
/// ```
pub fn line_break() -> Content {
  text("\n\n")
}
