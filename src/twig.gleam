import gleam/list
import gleam/string

/// The core content type representing any Typst element.
///
/// - `Text` holds a raw string value
/// - `Node` represents a Typst function call like `#heading[...]`
/// - `Sequence` groups multiple content elements together
pub type Content {
  Text(String)
  Node(name: String, attrs: List(String), children: List(Content))
  Sequence(List(Content))
}

/// A typed attribute for a specific element type.
///
/// The phantom type `element` ensures attributes can only be used
/// with their intended element. For example, `Attr(HeadingAttr)` cannot
/// be passed to `bullet_list` which expects `Attr(ListAttr)`.
pub opaque type Attr(element) {
  Attr(key: String, value: String)
}

/// Constructs a raw attribute key-value pair.
///
/// This is intended for use by glypst submodules only, not end users.
/// End users should use the typed attribute constructors like `level(1)`
/// or `marker(TextMarker("--"))` instead.
pub fn make_attr(key: String, value: String) -> Attr(a) {
  Attr(key, value)
}

/// Renders a `Content` tree into a Typst source string.
///
/// This is the final step, call this on your document root and
/// write the result to a `.typ` file.
///
/// ## Example
/// ```gleam
/// model.heading([model.level(1)], [text.text("Hello")])
/// |> render()
/// // -> "#heading(level: 1)[Hello]"
/// ```
pub fn render(content: Content) -> String {
  case content {
    Text(s) -> s
    Sequence(children) -> children |> list.map(render) |> string.join("")
    Node(name, attrs, children) -> {
      let params = case attrs {
        [] -> ""
        _ -> "(" <> string.join(attrs, ", ") <> ")"
      }
      let body =
        children
        |> list.map(fn(c) { "[" <> render(c) <> "]" })
        |> string.join("")
      "#" <> name <> params <> body
    }
  }
}

/// Constructs a `Node` from a Typst function name, typed attributes, and children.
///
/// This is the core building block used by all element constructors
/// in glypst submodules. Each element like `heading` or `bullet_list`
/// is just a thin wrapper around this function.
///
/// ## Example
/// ```gleam
/// node("heading", [level(1)], [text("Hello")])
/// // -> "#heading(level: 1)[Hello]"
/// ```
pub fn node(
  name: String,
  attrs: List(Attr(a)),
  children: List(Content),
) -> Content {
  Node(name, list.map(attrs, fn(a) { a.key <> ": " <> a.value }), children)
}
