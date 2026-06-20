#import "@preview/cmarker:0.1.5"
#import "@preview/mitex:0.2.5": mitex
#import "blog.typ": markup-rules, mathyml-equation-rules, code-block-rules, plain-text
// markup setting
#show: markup-rules
// math setting
#show: mathyml-equation-rules
// code block setting
#show: code-block-rules
#show raw.where(lang: "md-render"): it => cmarker.render(
  raw-typst: false,
  it.text,
  h1-level: 2,
  math: mitex,
  html: (
    userref: (attrs, body) => html.elem(
      "a",
      attrs: (href: "#user-" + plain-text(body), class: "userref"),
      "@" + plain-text(body),
    ),
    commentref: (attrs, body) => html.elem(
      "a",
      attrs: (href: "#comment-" + plain-text(body), class: "commentref"),
      "@comment:" + plain-text(body),
    ),
  ),
)
