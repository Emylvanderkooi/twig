import gleeunit
import gleeunit/should
import twig
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
