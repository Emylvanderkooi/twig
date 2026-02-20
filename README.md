# 🌿 Twig - Typst written in Gleam 🌿

[![Package Version](https://img.shields.io/hexpm/v/twig)](https://hex.pm/packages/twig)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/twig/)

A Gleam library for generating [Typst](https://typst.app) documents. Inspired by [Lustre](https://github.com/lustre-labs/lustre), Twig lets you build Typst documents using typed Gleam functions with attributes and content, just like Typst's own function model.

## Installation
```sh
gleam add twig
```

## Usage
```gleam
import gleam/io
import twig
import twig/model
import twig/text

pub fn main() {
  twig.Sequence([
    model.heading([model.level(1)], [text.text("My Document")]),
    model.heading([model.level(2)], [text.text("Introduction")]),
    model.strong([], [text.text("Welcome to Twig. ")]),
    text.line_break(),
    model.bullet_list([model.marker(model.TextMarker("--"))], [
      text.text("Type safe"),
      model.strong([], [text.text("Fast")]),
      model.emph([], [text.text("Easy to use")]),
    ]),
  ])
  |> twig.render()
  |> io.println()
}
```

Which outputs valid Typst markup:
```typst
#heading(level: 1)[My Document]
#heading(level: 2)[Introduction]
#strong[Welcome to Twig. ]

#list(marker: [--])[Type safe][#strong[Fast]][#emph[Easy to use]]
```

## Development
```sh
gleam test  # Run the tests
gleam docs build  # Build the documentation
```
