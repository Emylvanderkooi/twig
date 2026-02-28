import gleam/float
import gleam/int
import gleam/list
import gleam/string
import twig.{
  type Attr, type Content, inline_node, make_attr, make_positional, node,
}

/// Represents a length value in various units.
///
/// - `Pt` — points, e.g. `Pt(12.0)` → `12.0pt`
/// - `Mm` — millimeters, e.g. `Mm(10.0)` → `10.0mm`
/// - `Cm` — centimeters, e.g. `Cm(2.5)` → `2.5cm`
/// - `In` — inches, e.g. `In(1.0)` → `1.0in`
/// - `Em` — relative to font size, e.g. `Em(2.0)` → `2.0em`
pub type Length {
  Pt(Float)
  Mm(Float)
  Cm(Float)
  In(Float)
  Em(Float)
}

/// Renders a `Length` value to its Typst string representation.
fn render_length(l: Length) -> String {
  case l {
    Pt(n) -> float.to_string(n) <> "pt"
    Mm(n) -> float.to_string(n) <> "mm"
    Cm(n) -> float.to_string(n) <> "cm"
    In(n) -> float.to_string(n) <> "in"
    Em(n) -> float.to_string(n) <> "em"
  }
}

/// Inserts vertical spacing into the document.
///
/// ## Example
/// ```gleam
/// v(Em(5.0))
/// // -> "#v(5.0em)"
///
/// v(Pt(12.0))
/// // -> "#v(12.0pt)"
/// ```
pub fn v(amount: Length) -> Content {
  node("v", [make_positional(render_length(amount))], [])
}

/// Phantom type for horizontal space attributes.
pub type HAttr

/// Inserts horizontal spacing into the document.
///
/// ## Example
/// ```gleam
/// h(Em(5.0))
/// // -> "#h(5.0em)"
///
/// h(Pt(12.0))
/// // -> "#h(12.0pt)"
/// ```
pub fn h(amount: Length) -> Content {
  node("h", [make_positional(render_length(amount))], [])
}

/// Phantom type for horizontal alignment attributes.
pub type HAlign {
  Start
  End
  Left
  Center
  Right
}

/// Phantom type for vertical alignment attributes.
pub type VAlign {
  Top
  Horizon
  Bottom
}

/// Phantom type for alignment attributes.
pub type Alignment {
  Horizontal(HAlign)
  Vertical(VAlign)
  Both(HAlign, VAlign)
}

fn render_halign(a: HAlign) -> String {
  case a {
    Start -> "start"
    End -> "end"
    Left -> "left"
    Center -> "center"
    Right -> "right"
  }
}

fn render_valign(a: VAlign) -> String {
  case a {
    Top -> "top"
    Horizon -> "horizon"
    Bottom -> "bottom"
  }
}

fn render_alignment(a: Alignment) -> String {
  case a {
    Horizontal(h) -> render_halign(h)
    Vertical(v) -> render_valign(v)
    Both(h, v) -> render_halign(h) <> " + " <> render_valign(v)
  }
}

/// Align content horizontally and vertically.
///
/// ## Example
/// ```gleam
/// align(Both(Center, Horizon), [text("Hello"), text("World")])
/// // -> "#align(center + horizon)[Hello World]"
/// ```
pub fn align(alignment: Alignment, children: List(Content)) -> Content {
  node("align", [make_positional(render_alignment(alignment))], children)
}

/// Phantom type for track size attributes.
pub type TrackSize {
  Auto
  Fr(Float)
  Percent(Float)
  Fixed(Length)
}

fn render_track_size(ts: TrackSize) -> String {
  case ts {
    Auto -> "auto"
    Fr(n) -> float.to_string(n) <> "fr"
    Percent(n) -> float.to_string(n) <> "%"
    Fixed(l) -> render_length(l)
  }
}

/// Phantom type for grid attributes.
pub type GridAttr

/// Sets the column widths of a grid.
///
/// ## Example
/// ```gleam
/// columns([Fr(1.0), Fr(2.0)])
/// // -> "columns: (1.0fr, 2.0fr)"
/// ```
pub fn columns(cs: List(TrackSize)) -> Attr(GridAttr) {
  make_attr(
    "columns",
    "(" <> { cs |> list.map(render_track_size) |> string.join(", ") } <> ")",
  )
}

/// Sets the row heights of a grid.
///
/// ## Example
/// ```gleam
/// rows([Fr(1.0), Fr(2.0)])
/// // -> "rows: (1.0fr, 2.0fr)"
/// ```
pub fn rows(rs: List(TrackSize)) -> Attr(GridAttr) {
  make_attr(
    "rows",
    "(" <> { rs |> list.map(render_track_size) |> string.join(", ") } <> ")",
  )
}

/// Sets the gutter size of a grid.
///
/// ## Example
/// ```gleam
/// gutter([Fr(1.0), Fr(2.0)])
/// // -> "gutter: (1.0fr, 2.0fr)"
/// ```
pub fn gutter(g: List(TrackSize)) -> Attr(GridAttr) {
  make_attr(
    "gutter",
    "(" <> { g |> list.map(render_track_size) |> string.join(", ") } <> ")",
  )
}

/// Creates a grid element.
///
/// ```gleam
/// grid([columns([Fr(1.0), Fr(2.0)])], [text.text("Hello"), text.text("World")])
/// // -> "#grid(columns: (1.0fr, 2.0fr), \"Hello\", \"World\")"
/// ```
pub fn grid(attrs: List(Attr(GridAttr)), children: List(Content)) -> Content {
  inline_node("grid", attrs, children)
}

/// Phantom type for grid cell attributes.
pub type GridCellAttr

/// Sets the number of columns a grid cell spans.
///
/// ## Example
/// ```gleam
/// grid_cell([colspan(2)], [text("Hello")])
/// // -> "#grid.cell(colspan: 2)[Hello]"
/// ```
pub fn colspan(n: Int) -> Attr(GridCellAttr) {
  make_attr("colspan", int.to_string(n))
}

/// Sets the number of rows a grid cell spans.
///
/// ## Example
/// ```gleam
/// grid_cell([rowspan(2)], [text("Hello")])
/// // -> "#grid.cell(rowspan: 2)[Hello]"
/// ```
pub fn rowspan(n: Int) -> Attr(GridCellAttr) {
  make_attr("rowspan", int.to_string(n))
}

/// Sets the x position of a grid cell.
///
/// ## Example
/// ```gleam
/// grid_cell([x(1)], [text("Hello")])
/// // -> "#grid.cell(x: 1)[Hello]"
/// ```
pub fn x(n: Int) -> Attr(GridCellAttr) {
  make_attr("x", int.to_string(n))
}

/// Sets the y position of a grid cell.
///
/// ## Example
/// ```gleam
/// grid_cell([y(2)], [text("Hello")])
/// // -> "#grid.cell(y: 2)[Hello]"
/// ```
pub fn y(n: Int) -> Attr(GridCellAttr) {
  make_attr("y", int.to_string(n))
}

/// Sets the alignment of a grid cell.
///
/// ## Example
/// ```gleam
/// grid_cell([cell_align(Both(Center, Horizon))], [text("Hello")])
/// // -> "#grid.cell(align: center + horizon)[Hello]"
/// ```
pub fn cell_align(a: Alignment) -> Attr(GridCellAttr) {
  make_attr("align", render_alignment(a))
}

/// Creates a grid cell element.
///
/// ## Example
/// ```gleam
/// grid_cell([colspan(2), rowspan(2)], [text("Hello")])
/// // -> "#grid.cell(colspan: 2, rowspan: 2)[Hello]"
/// ```
pub fn grid_cell(
  attrs: List(Attr(GridCellAttr)),
  children: List(Content),
) -> Content {
  node("grid.cell", attrs, children)
}
