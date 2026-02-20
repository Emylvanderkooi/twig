import gleam/list
import gleam/string

/// The core content type representing any Typst element.
///
/// - `Text` holds a raw string value
/// - `Node` represents a Typst function call like `#heading[...]`
/// - `Sequence` groups multiple content elements together
pub type Content {
  Text(String)
  Node(name: String, attrs: List(String), children: NodeChildren)
  Sequence(List(Content))
}

/// Controls how a node's children are rendered.
///
/// - `SingleChild` renders all children in one block `[child1child2]`
/// - `MultiChild` renders each child in its own block `[child1][child2]`
/// - `InlineChildren` renders all children in one block `child1, child2`
pub type NodeChildren {
  SingleChild(List(Content))
  MultiChild(List(Content))
  InlineChildren(List(Content))
}

/// A typed attribute for a specific element type.
///
/// The phantom type `element` ensures attributes can only be used
/// with their intended element. For example, `Attr(HeadingAttr)` cannot
/// be passed to `bullet_list` which expects `Attr(ListAttr)`.
pub opaque type Attr(element) {
  Attr(key: String, value: String)
  Positional(value: String)
}

/// Constructs a named attribute key-value pair.
///
/// This is intended for use by twig submodules only, not end users.
/// End users should use the typed attribute constructors like `level(1)`
/// or `marker(TextMarker("--"))` instead.
pub fn make_attr(key: String, value: String) -> Attr(a) {
  Attr(key, value)
}

/// Constructs a positional attribute value.
///
/// This is intended for use by twig submodules only, not end users.
/// Used for Typst functions that take positional arguments like `#v(5em)`.
pub fn make_positional(value: String) -> Attr(a) {
  Positional(value)
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
    Node(name, attrs, children) -> "#" <> render_node(name, attrs, children)
  }
}

fn render_inline(content: Content) -> String {
  case content {
    Text(s) -> "\"" <> s <> "\""
    Sequence(children) -> children |> list.map(render_inline) |> string.join("")
    Node(name, attrs, children) -> render_node(name, attrs, children)
  }
}

fn render_node(
  name: String,
  attrs: List(String),
  children: NodeChildren,
) -> String {
  let body = case children {
    SingleChild([]) -> ""
    SingleChild(cs) ->
      "[" <> { cs |> list.map(render) |> string.join("") } <> "]"
    MultiChild(cs) ->
      cs
      |> list.map(fn(c) { "[" <> render(c) <> "]" })
      |> string.join("")
    InlineChildren(_) -> ""
  }
  let params = case children {
    InlineChildren(cs) -> {
      let rendered_children = cs |> list.map(render_inline) |> string.join(", ")
      case attrs {
        [] -> "(" <> rendered_children <> ")"
        _ -> "(" <> string.join(attrs, ", ") <> ", " <> rendered_children <> ")"
      }
    }
    _ ->
      case attrs {
        [] -> ""
        _ -> "(" <> string.join(attrs, ", ") <> ")"
      }
  }
  name <> params <> body
}

/// Constructs a `Node` where all children are rendered into a single block `[...]`.
///
/// This is the core building block used by most element constructors
/// in twig submodules. Use `multi_node` for elements like `bullet_list`
/// where each child needs its own block.
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
  Node(name, render_attrs(attrs), SingleChild(children))
}

/// Constructs a `Node` where each child gets its own content block `[...]`.
///
/// Use this for elements like `bullet_list` where each child is a separate item.
///
/// ## Example
/// ```gleam
/// multi_node("list", [], [text("item1"), text("item2")])
/// // -> "#list[item1][item2]"
/// ```
pub fn multi_node(
  name: String,
  attrs: List(Attr(a)),
  children: List(Content),
) -> Content {
  Node(name, render_attrs(attrs), MultiChild(children))
}

pub fn inline_node(
  name: String,
  attrs: List(Attr(a)),
  children: List(Content),
) -> Content {
  Node(name, render_attrs(attrs), InlineChildren(children))
}

fn render_attrs(attrs: List(Attr(a))) -> List(String) {
  list.map(attrs, fn(a) {
    case a {
      Attr(key, value) -> key <> ": " <> value
      Positional(value) -> value
    }
  })
}
