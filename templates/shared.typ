
#import "../packages/zebraw.typ": *
#import "@preview/shiroa:0.2.3": is-html-target, is-pdf-target, is-web-target, plain-text, templates
#import templates: *
#import "mod.typ": *
#import "theme.typ": *

// Settings
// todo: load from env or config?
#let use-mathyml = true

#import "../packages/mathyml.typ": prelude
#import "empty.typ" as _empty
#import if use-mathyml { prelude } else { _empty }: *

// Metadata
#let is-html-target = is-html-target()
#let is-pdf-target = is-pdf-target()
#let is-web-target = is-web-target() or sys-is-html-target
#let is-md-target = target == "md"
#let sys-is-html-target = ("target" in dictionary(std))

#let default-kind = "post"
// #let default-kind = "monthly"

#let build-kind = sys.inputs.at("build-kind", default: default-kind)

#let text-fonts = (
  "Libertinus Serif",
  // todo: exclude it if language is not Chinese.
  "Source Han Serif SC",
)

#let code-font = (
  "DejaVu Sans Mono",
)

// Sizes
#let main-size = if sys-is-html-target {
  16pt
} else {
  10.5pt
}
// ,
#let heading-sizes = (22pt, 18pt, 14pt, 12pt, main-size)
#let list-indent = 0.5em

/// Creates an embedded block typst frame.
#let div-frame(content, attrs: (:), tag: "div") = html.elem(tag, html.frame(content), attrs: attrs)
#let span-frame = div-frame.with(tag: "span")
#let p-frame = div-frame.with(tag: "p")

// defaults
#let (
  style: theme-style,
  is-dark: is-dark-theme,
  is-light: is-light-theme,
  main-color: main-color,
  dash-color: dash-color,
  code-extra-colors: code-extra-colors,
) = default-theme

#let markup-rules(body, lang: none, region: none) = {
  set text(lang: lang) if lang != none
  set text(region: region) if region != none
  set text(font: text-fonts)

  set text(main-size) if sys-is-html-target
  set text(fill: rgb("dfdfd6")) if is-dark-theme and sys-is-html-target
  show link: set text(fill: dash-color)

  show heading: it => {
    set text(size: heading-sizes.at(it.level))

    block(
      spacing: 0.7em * 1.5 * 1.2,
      below: 0.7em * 1.2,
      {
        if is-web-target {
          show link: static-heading-link(it)
          heading-hash(it, hash-color: dash-color)
        }

        it
      },
    )
  }

  body
}

#let equation-rules(body) = {
  show math.equation: set text(weight: 400)
  show math.equation.where(block: true): it => context if shiroa-sys-target() == "html" {
    theme-frame(
      tag: "div",
      theme => {
        set text(fill: theme.main-color)
        p-frame(attrs: ("class": "block-equation", "role": "math"), it)
      },
    )
  } else {
    it
  }
  show math.equation.where(block: false): it => context if shiroa-sys-target() == "html" {
    theme-frame(
      tag: "span",
      theme => {
        set text(fill: theme.main-color)
        span-frame(attrs: (class: "inline-equation"), it)
      },
    )
  } else {
    it
  }
  body
}

// https://codeberg.org/akida/mathyml
#let mathyml-equation-rules(body) = {
  import "../packages/mathyml.typ": try-to-mathml

  // math rules
  show math.equation: set text(weight: 500)
  // show math.equation: to-mathml
  show math.equation: try-to-mathml


  body
}

#let code-block-rules(body) = {
  let init-with-theme((code-extra-colors, is-dark)) = if is-dark {
    zebraw-init.with(
      // should vary by theme
      background-color: if code-extra-colors.bg != none {
        (code-extra-colors.bg, code-extra-colors.bg)
      },
      highlight-color: rgb("#3d59a1"),
      comment-color: rgb("#394b70"),
      lang-color: rgb("#3d59a1"),
      lang: false,
      numbering: false,
    )
  } else {
    zebraw-init.with(
      // should vary by theme
      background-color: if code-extra-colors.bg != none {
        (code-extra-colors.bg, code-extra-colors.bg)
      },
      lang: false,
      numbering: false,
    )
  }

  /// HTML code block supported by zebraw.
  show: init-with-theme(default-theme)


  let mk-raw(
    it,
    tag: "div",
    inline: false,
  ) = theme-frame(
    tag: tag,
    theme => {
      show: init-with-theme(theme)
      let code-extra-colors = theme.code-extra-colors
      let use-fg = not inline and code-extra-colors.fg != none
      set text(fill: code-extra-colors.fg) if use-fg
      set text(fill: if theme.is-dark { rgb("dfdfd6") } else { black }) if not use-fg
      set raw(theme: theme-style.code-theme) if theme.style.code-theme.len() > 0
      set par(justify: false)
      zebraw(
        block-width: 100%,
        // line-width: 100%,
        wrap: false,
        it,
      )
    },
  )

  show raw: set text(font: code-font)
  show raw.where(block: false): it => context if shiroa-sys-target() == "paged" {
    it
  } else {
    mk-raw(it, tag: "span", inline: true)
  }
  show raw.where(block: true): it => context if shiroa-sys-target() == "paged" {
    set raw(theme: theme-style.code-theme) if theme-style.code-theme.len() > 0
    rect(
      width: 100%,
      inset: (x: 4pt, y: 5pt),
      radius: 4pt,
      fill: code-extra-colors.bg,
      [
        #set text(fill: code-extra-colors.fg) if code-extra-colors.fg != none
        #set par(justify: false)
        // #place(right, text(luma(110), it.lang))
        #it
      ],
    )
  } else {
    mk-raw(it)
  }
  body
}

#let visual-rules(body) = {
  import "env.typ": url-base
  // Resolves the path to the image source
  let resolve(path) = (
    path.replace(
      // Substitutes the paths with some assumption.
      // In the astro sites, the assets are store in `public/` directory.
      regex("^[./]*/public/"),
      url-base,
    )
  )

  show image: it => context if shiroa-sys-target() == "paged" {
    it
  } else {
    html.elem("img", attrs: (src: resolve(it.source)))
  }

  body
}

#let default-archive-creator = (indices, body) => {
  indices.map(fname => include "/content/article/" + fname + ".typ").join(pagebreak(weak: true))
}

/// sub-chapters is only used in monthly (archive) build.
#let shared-template(
  title: "Untitled",
  desc: [This is a blog post.],
  date: "2024-08-15",
  tags: (),
  kind: "post",
  lang: none,
  region: none,
  show-outline: true,
  archive-indices: (),
  archive-creator: default-archive-creator,
  body,
) = {
  let is-same-kind = build-kind == kind

  // To ensure that we can nest any pages together with applying the template repeatedly.
  let nest-level = state("nest-level", 0)
  let is-root-level() = is-same-kind and sys-is-html-target and nest-level.get() == 0

  show: it => context if is-same-kind and nest-level.get() == 0 {
    // set basic document metadata
    set document(
      author: ("Myriad-Dreamin",),
      ..if not is-web-target { (title: title) },
    )

    // markup setting
    show: markup-rules.with(
      lang: lang,
      region: region,
    )
    // math setting
    show: if use-mathyml { mathyml-equation-rules } else { equation-rules }
    // code block setting
    show: code-block-rules
    // visualization setting
    show: visual-rules

    show: it => if sys-is-html-target {
      show footnote: it => context {
        let num = counter(footnote).get().at(0)
        link(label("footnote-" + str(num)), super(str(num)))
      }

      it
    } else {
      it
    }

    // Main body.
    set par(justify: true)
    it
  } else {
    it
  }

  show: it => if build-kind == "monthly" and is-same-kind {
    set page(numbering: "i")
    set heading(numbering: "1.1")
    it
  } else if build-kind == "monthly" and kind == "post" {
    set page(
      numbering: "1",
      header: context align(
        if calc.even(here().page()) { right } else { left },
        emph[
          #date -- #title
        ],
      ),
    ) if not sys-is-html-target
    set heading(offset: 1) if not sys-is-html-target // globally increase offset
    it
  } else {
    it
  }

  if is-same-kind and kind == "monthly" {
    align(
      center,
      {
        text(12pt, date)
        linebreak()
        strong(text(26pt, title))
        linebreak()
        text(16pt, desc)
      },
    )
    v(16pt)

    outline()
    pagebreak()
  }

  if build-kind == "monthly" and kind == "post" {
    show heading: set block(above: 0.2em, below: 0em)
    show heading: set text(size: 26pt)
    align(
      center,
      {
        text(12pt, date)
        linebreak()
        heading(numbering: none, title)
        counter(heading).step()
        linebreak()
        text(16pt, desc)
      },
    )
    v(16pt)
  }


  // todo monthly hack
  if kind == "monthly" or is-same-kind [
    #metadata((
      title: plain-text(title),
      author: "Myriad-Dreamin",
      description: plain-text(desc),
      date: date,
      tags: tags,
      lang: lang,
      region: region,
      ..if kind == "monthly" {
        (indices: archive-indices)
      },
    )) <frontmatter>
  ]

  context if show-outline and is-root-level() {
    if query(heading).len() == 0 {
      return
    }

    let outline-counter = counter("html-outline")
    outline-counter.update(0)
    show outline.entry: it => html.elem(
      "div",
      attrs: (
        class: "outline-item x-heading-" + str(it.level),
      ),
      {
        outline-counter.step(level: it.level)
        static-heading-link(it.element, body: [#sym.section#context outline-counter.display("1.") #it.element.body])
      },
    )
    html.elem(
      "div",
      attrs: (
        class: "outline",
      ),
      outline(title: none),
    )
    html.elem("hr")
  }

  nest-level.update(it => it + 1)
  if kind == "monthly" {
    archive-creator(archive-indices, body)
  } else {
    body
  }
  nest-level.update(it => it - 1)

  context if is-root-level() {
    query(footnote)
      .enumerate()
      .map(((idx, it)) => {
        enum.item[
          #html.elem(
            "div",
            attrs: ("data-typst-label": "footnote-" + str(idx + 1)),
            it.body,
          )
        ]
      })
      .join()
  }
}
