
#import "@preview/fletcher:0.5.7"
#import "target.typ": sys-is-html-target
#import "theme.typ": theme-frame, default-theme
#import "@preview/shiroa:0.2.3": plain-text, templates
#import templates: get-label-disambiguator, label-disambiguator, make-unique-label

#let code-image = if sys-is-html-target {
  (it, ..attrs) => {
    theme-frame.with(..attrs)(theme => {
      set text(fill: theme.main-color)
      set line(stroke: theme.main-color)
      html.frame(if type(it) == function { it(theme) } else { it })
    })
  }
} else {
  (it, ..attrs) => if type(it) == function { it(default-theme) } else { it }
}

/// Alternative resolves all heading as static link
///
/// - `elem`(content): The heading element to resolve
#let static-heading-link(elem, body: "#") = context {
  let id = {
    let title = plain-text(elem).trim()
    "label-"
    str(
      make-unique-label(
        title,
        disambiguator: label-disambiguator.at(elem.location()).at(title, default: 0) + 1,
      ),
    )
  }
  html.elem(
    "a",
    attrs: (
      "href": "#" + id,
      ..if body == "#" { ("id": id, "data-typst-label": id) },
    ),
    body,
  )
}

#let blog-tags = (
  finance: "Finance",
  math: "Math",
  poem: "Poem",
  programming: "Programming",
  software: "Software",
  network: "Network",
  software-engineering: "Software Engineering",
  tooling: "Tooling",
  linux: "Linux",
  dev-ops: "DevOps",
  compiler: "Compiler",
  music-theory: "Music Theory",
  tinymist: "Tinymist",
  golang: "Golang",
  typst: "Typst",
  misc: "Miscellaneous",
)

#let archive-tags = (
  blog-post: "Blog Post",
)
