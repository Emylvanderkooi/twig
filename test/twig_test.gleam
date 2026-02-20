import gleeunit
import gleeunit/should
import twig
import twig/layout.{Cm, Em, In, Mm, Pt, h, v}
import twig/model
import twig/text

pub fn main() {
  gleeunit.main()
}

pub fn text_test() {
  text.text("Hello")
  |> twig.render()
  |> should.equal("Hello")
}

pub fn heading_no_attrs_test() {
  model.heading([], [text.text("Hello")])
  |> twig.render()
  |> should.equal("#heading[Hello]")
}

pub fn heading_with_level_test() {
  model.heading([model.level(2)], [text.text("Hello")])
  |> twig.render()
  |> should.equal("#heading(level: 2)[Hello]")
}

pub fn heading_no_numbering_test() {
  model.heading([model.numbering(model.NoNumbering)], [text.text("Hello")])
  |> twig.render()
  |> should.equal("#heading(numbering: none)[Hello]")
}

pub fn heading_numbering_pattern_test() {
  model.heading([model.numbering(model.NumberingPattern("1.a."))], [
    text.text("Hello"),
  ])
  |> twig.render()
  |> should.equal("#heading(numbering: \"1.a.\")[Hello]")
}

pub fn heading_level_and_numbering_test() {
  model.heading(
    [model.level(1), model.numbering(model.NumberingPattern("1.a."))],
    [text.text("A section")],
  )
  |> twig.render()
  |> should.equal("#heading(level: 1, numbering: \"1.a.\")[A section]")
}

pub fn bullet_list_default_test() {
  model.bullet_list([], [text.text("item1"), text.text("item2")])
  |> twig.render()
  |> should.equal("#list[item1][item2]")
}

pub fn bullet_list_with_marker_test() {
  model.bullet_list([model.marker(model.TextMarker("--"))], [
    text.text("item1"),
    text.text("item2"),
  ])
  |> twig.render()
  |> should.equal("#list(marker: [--])[item1][item2]")
}

pub fn strong_test() {
  model.strong([], [text.text("bold")])
  |> twig.render()
  |> should.equal("#strong[bold]")
}

pub fn emph_test() {
  model.emph([], [text.text("italic")])
  |> twig.render()
  |> should.equal("#emph[italic]")
}

pub fn nested_test() {
  model.strong([], [model.emph([], [text.text("bold and italic")])])
  |> twig.render()
  |> should.equal("#strong[#emph[bold and italic]]")
}

pub fn line_break_test() {
  twig.Sequence([text.text("Hello"), text.line_break(), text.text("World")])
  |> twig.render()
  |> should.equal("Hello\n\nWorld")
}

pub fn v_test() {
  should.equal(twig.render(v(Pt(12.0))), "#v(12.0pt)")
  should.equal(twig.render(v(Mm(10.0))), "#v(10.0mm)")
  should.equal(twig.render(v(Cm(2.5))), "#v(2.5cm)")
  should.equal(twig.render(v(In(1.0))), "#v(1.0in)")
  should.equal(twig.render(v(Em(5.0))), "#v(5.0em)")
}

pub fn h_test() {
  should.equal(twig.render(h(Pt(6.0))), "#h(6.0pt)")
  should.equal(twig.render(h(Mm(5.0))), "#h(5.0mm)")
  should.equal(twig.render(h(Cm(1.5))), "#h(1.5cm)")
  should.equal(twig.render(h(In(0.5))), "#h(0.5in)")
  should.equal(twig.render(h(Em(2.0))), "#h(2.0em)")
}

pub fn align_test() {
  layout.align(layout.Both(layout.Center, layout.Horizon), [
    text.text("Hello World"),
  ])
  |> twig.render()
  |> should.equal("#align(center + horizon)[Hello World]")
}

pub fn grid_test() {
  layout.grid([layout.columns([layout.Fr(1.0), layout.Fr(2.0)])], [
    text.text("Hello"),
    text.text("World"),
  ])
  |> twig.render()
  |> should.equal("#grid(columns: (1.0fr, 2.0fr), \"Hello\", \"World\")")
}

pub fn grid_cell_test() {
  layout.grid_cell([layout.colspan(2), layout.rowspan(2)], [
    text.text("Hello"),
  ])
  |> twig.render()
  |> should.equal("#grid.cell(colspan: 2, rowspan: 2)[Hello]")
}

pub fn grid_with_cells_test() {
  layout.grid([layout.columns([layout.Fr(1.0), layout.Fr(2.0)])], [
    layout.grid_cell([layout.colspan(2), layout.rowspan(2)], [
      text.text("Hello"),
    ]),
    layout.grid_cell([layout.x(1), layout.y(2)], [text.text("World")]),
  ])
  |> twig.render()
  |> should.equal(
    "#grid(columns: (1.0fr, 2.0fr), grid.cell(colspan: 2, rowspan: 2)[Hello], grid.cell(x: 1, y: 2)[World])",
  )
}

pub fn grid_track_sizes_test() {
  layout.grid(
    [
      layout.columns([layout.Auto, layout.Percent(50.0), layout.Fixed(Pt(60.0))]),
    ],
    [
      text.text("Hello"),
    ],
  )
  |> twig.render()
  |> should.equal("#grid(columns: (auto, 50.0%, 60.0pt), \"Hello\")")
}

pub fn align_horizontal_test() {
  layout.align(layout.Horizontal(layout.Right), [text.text("Hello")])
  |> twig.render()
  |> should.equal("#align(right)[Hello]")
}

pub fn align_vertical_test() {
  layout.align(layout.Vertical(layout.Bottom), [text.text("Hello")])
  |> twig.render()
  |> should.equal("#align(bottom)[Hello]")
}

pub fn cell_align_test() {
  layout.grid_cell([layout.cell_align(layout.Horizontal(layout.Left))], [
    text.text("Hello"),
  ])
  |> twig.render()
  |> should.equal("#grid.cell(align: left)[Hello]")
}

pub fn document_test() {
  twig.Sequence([
    model.heading(
      [model.level(1), model.numbering(model.NumberingPattern("1."))],
      [text.text("My Document")],
    ),
    model.heading([model.level(2)], [text.text("Introduction")]),
    model.strong([], [text.text("Welcome to twig. ")]),
    model.emph([], [text.text("This is a Gleam library for Typst.")]),
    model.bullet_list([model.marker(model.TextMarker("--"))], [
      text.text("Type safe"),
      model.strong([], [text.text("Fast")]),
      twig.Sequence([
        text.text("Easy to "),
        model.emph([], [text.text("use")]),
      ]),
    ]),
  ])
  |> twig.render()
  |> should.equal(
    "#heading(level: 1, numbering: \"1.\")[My Document]"
    <> "#heading(level: 2)[Introduction]"
    <> "#strong[Welcome to twig. ]"
    <> "#emph[This is a Gleam library for Typst.]"
    <> "#list(marker: [--])[Type safe][#strong[Fast]][Easy to #emph[use]]",
  )
}
