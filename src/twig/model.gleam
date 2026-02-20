import gleam/int
import twig.{type Attr, type Content, make_attr, multi_node, node}

/// Phantom type for heading attributes.
pub type HeadingAttr

/// Controls how a heading is numbered.
///
/// - `NoNumbering` renders as `numbering: none`
/// - `NumberingPattern` accepts a Typst numbering pattern string like `"1.a."`
pub type Numbering {
  NoNumbering
  NumberingPattern(String)
}

/// Sets the level of a heading, from 1 (top) to 6 (lowest).
///
/// ## Example
/// ```gleam
/// heading([level(2)], [text("Introduction")])
/// // -> "#heading(level: 2)[Introduction]"
/// ```
pub fn level(n: Int) -> Attr(HeadingAttr) {
  make_attr("level", int.to_string(n))
}

/// Sets the numbering style of a heading.
///
/// ## Example
/// ```gleam
/// heading([level(1), numbering(NumberingPattern("1.a."))], [text("Hello")])
/// // -> "#heading(level: 1, numbering: "1.a.")[Hello]"
/// ```
pub fn numbering(n: Numbering) -> Attr(HeadingAttr) {
  case n {
    NoNumbering -> make_attr("numbering", "none")
    NumberingPattern(p) -> make_attr("numbering", "\"" <> p <> "\"")
  }
}

/// Creates a heading element.
///
/// ## Example
/// ```gleam
/// heading([level(1)], [text("My Document")])
/// // -> "#heading(level: 1)[My Document]"
/// ```
pub fn heading(
  attrs: List(Attr(HeadingAttr)),
  children: List(Content),
) -> Content {
  node("heading", attrs, children)
}

/// Phantom type for bullet list attributes.
pub type ListAttr

/// Controls the marker style of a bullet list.
///
/// - `DefaultMarker` lets Typst use its default bullet
/// - `TextMarker` accepts any string to use as the bullet marker
pub type Marker {
  DefaultMarker
  TextMarker(String)
}

/// Sets the marker style for a bullet list.
///
/// ## Example
/// ```gleam
/// bullet_list([marker(TextMarker("--"))], [text("item1")])
/// // -> "#list(marker: [--])[item1]"
/// ```
pub fn marker(m: Marker) -> Attr(ListAttr) {
  case m {
    DefaultMarker -> make_attr("marker", "auto")
    TextMarker(s) -> make_attr("marker", "[" <> s <> "]")
  }
}

/// Creates a bullet list element. Each child becomes a list item.
///
/// ## Example
/// ```gleam
/// bullet_list([], [text("item1"), text("item2")])
/// // -> "#list[item1][item2]"
/// ```
pub fn bullet_list(
  attrs: List(Attr(ListAttr)),
  children: List(Content),
) -> Content {
  multi_node("list", attrs, children)
}

/// Phantom type for strong attributes.
pub type StrongAttr

/// Phantom type for emph attributes.
pub type EmphAttr

/// Creates a strong (bold) element.
///
/// ## Example
/// ```gleam
/// strong([], [text("bold")])
/// // -> "#strong[bold]"
/// ```
pub fn strong(attrs: List(Attr(StrongAttr)), children: List(Content)) -> Content {
  node("strong", attrs, children)
}

/// Creates an emphasis (italic) element.
///
/// ## Example
/// ```gleam
/// emph([], [text("italic")])
/// // -> "#emph[italic]"
/// ```
pub fn emph(attrs: List(Attr(EmphAttr)), children: List(Content)) -> Content {
  node("emph", attrs, children)
}
