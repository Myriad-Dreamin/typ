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
