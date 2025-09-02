#import "shared.typ": *



/// A wrapper to attach content to a remige (your component of the entire note).
///
/// - to (label): The label of which content is being attached.
/// - body (content): The body of the content.
/// -> content
#let remige(to: none, body) = {
  show: it => context {
    let offset = if to != none {
      let to-find = query(to)
      assert(to-find.len() > 0, message: "to label is not found")
      to-find.first().level
    } else {
      let to-heading = query(heading.before(here())).at(0, default: none)
      if to-heading != none { to-heading.level } else { 0 }
    }

    set heading(offset: offset)
    it
  }

  body
}



// The default template for notes.
#let main(..args) = {
  // >> shiroa 0.3.0
  let data-url(mime, src) = {
    import "@preview/based:0.2.0": base64
    "data:" + mime + ";base64," + base64.encode(src)
  }

  let virt-slot(name) = figure(kind: "virt-slot:" + name, supplement: "_virt-slot")[]
  let set-slot(name, body) = it => {
    show figure.where(kind: "virt-slot:" + name): slot => body

    it
  }

  let shiroa-assets = state("shiroa:assets", (:))
  let add-assets(global-style, cond: true) = if cond {
    shiroa-assets.update(it => {
      it.insert(global-style.text, global-style)
      it
    })
  }
  let add-scripts(assets, cond: true) = add-assets(assets, cond: cond)
  let add-styles(assets, cond: true) = add-assets(assets, cond: cond)

  let inline-assets(body) = if is-html-target {
    show raw.where(lang: "css"): it => {
      html.elem("link", attrs: (rel: "stylesheet", href: data-url("text/css", it.text)))
    }
    show raw.where(lang: "js"): it => {
      html.elem("script", attrs: (src: data-url("application/javascript", it.text)))
    }

    body
  }

  // << shiroa 0.3.0


  show: it => if sys.inputs.at("x-preview", default: none) != none [
    #set heading(numbering: "1.1") if is-pdf-target
    #inline-assets({
      raw(lang: "css", read("/src/styles/global.css"))
      ```css
      body {
        margin: 4em;
      }
      ```
      ```js
      // dark theme
      document.documentElement.classList.add("dark");
      ```
    })

    #it
  ] else {
    it
  }

  shared-template(kind: "post", lang: "en", ..args)
}
// shortcut for English notes
#let main-en = main
// shortcut for Chinese notes
#let main-zh = main.with(lang: "zh", region: "cn")
