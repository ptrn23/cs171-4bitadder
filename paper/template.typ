// imports
// #import "@preview/rubber-article:0.3.1": *
#import "@preview/zebraw:0.4.3": *

// #import "@preview/cetz:0.3.2": canvas, draw
// #import "@preview/cetz-plot:0.1.1": plot

// constants

#let COURSE = "CS 198"
#let SECTION = "WSL"
#let REQUIREMENT = "Group 3"
#let REQUIREMENT_NAME = "Full Manuscript"
#let DATE = "???"

#let MAIN_COLOR = rgb("#133954")
#let ITEM_COLOR = rgb("#4051B5")
#let FILL_COLOR = rgb("#F2EDFF")
#let QUOTE_COLOR = rgb("#A1AEB1")
#let QUOTE_RAW = read("temp/quote-right-icon.svg")
#let QUOTE_GRAY = QUOTE_RAW.replace("#FF5733", QUOTE_COLOR.to-hex())
#let WARNING_COLOR = rgb("#FF0F0F")

#let WOLFRAM_RED = rgb("#E63320")
#let WOLFRAM_ORANGE = rgb("#FFA32C")

#let SHOW_DEFAULT_OUTLINE = false
#let SHOW_FIGURES_OUTLINE = false

// template

#let item(name, info, body) = {
  rect(
    stroke: (left: 2pt + ITEM_COLOR), 
    fill: FILL_COLOR, 
    inset: 10pt,
    width: 100%,
    
    [
      #text(
        font: "New Computer Modern Sans",
        fill: ITEM_COLOR,
        weight: "extrabold",
        10pt,
        [#name]
      )
      #h(1fr)
      #text(
        font: "New Computer Modern Sans",
        fill: ITEM_COLOR,
        weight: "extrabold",
        10pt,
        [#info]
      )
      #v(-3pt)
      #body 
    ]
  )
}

#let quote(name, body) = {
  rect(
    stroke: (left: 2pt + QUOTE_COLOR),
    inset: 10pt,
    width: 100%,
    [
      #place(
        top + right,
        dx: 10pt,
        dy: -10pt,
        float: false,

        image(bytes(QUOTE_GRAY), width: 3%)
      )
      #body
      #v(-3pt)
      #text(
        font: "New Computer Modern Sans",
        fill: QUOTE_COLOR,
        weight: "extrabold",
        10pt,
        [— from: #emph[#name]]
      )
    ]
  )
}

#let warning(info, body) = {
  rect(
    stroke: (left: 2pt + WARNING_COLOR), 
    fill: WARNING_COLOR.lighten(90%),
    inset: 10pt,
    width: 100%,
    
    [
      #text(
        font: "New Computer Modern Sans",
        fill: WARNING_COLOR,
        weight: "extrabold",
        10pt,
        [#info]
      )
      #v(-3pt)
      #body 
    ]
  )
}

#let answer(body) = (
  rect(
    inset: 10pt,
    stroke: 1pt,

    [#body]
  )
)

#let wolframalpha(body) = (
  rect(
    stroke: 1.5pt + WOLFRAM_ORANGE,
    radius: 5pt,
    inset: 10pt,
    width: 100%,

    [
      #place(
        bottom + right,
        dx: 10pt,
        dy: 10pt,
        float: false,

        image("temp/wolfram_tag.png", width: 8%)
      )
      #body \
    ]
  )
)

#let wolframalpha_link() = (
  link("https://www.wolframalpha.com")[
    #box(
      height: 9pt,
      inset: (x: -1pt, y: -1pt),
      image("temp/wolfram_logo.png", width: 2.5%)
    ) #text(
      weight: "bold",
      fill: WOLFRAM_RED
    )[Wolfram] #text(
      weight: "bold",
      fill: WOLFRAM_ORANGE
    )[Alpha]
  ]
)

#let academic-table(
  columns: auto,
  cell-align: center,
  highlight-row: none,
  caption: none,
  note: none,
  row-height: auto,
  cell-inset: 5pt,
  ..cells
) = {
  block(width: 100%, breakable: true)[
    #set par(justify: false)

    #figure(
      caption: [#caption],
      table(
        columns: columns,
        rows: row-height,
        inset: cell-inset,
        align: cell-align,
        stroke: none, 
        
        fill: (col, row) => if row == highlight-row { rgb("#F4F5F9") } else { none },
        
        table.hline(y: 0, stroke: 1.5pt + black),
        table.hline(y: 1, stroke: 0.7pt + black),
        
        ..cells,
        
        table.hline(stroke: 1.5pt + black)
      ) 
    )
    
    #if note != none [
      #align(left)[
        #v(-0.5em)
        #text(size: 8pt, style: "italic", note)
      ]
    ]
  ]
}

#let algo-counter = counter("algorithm")

#let academic-algorithm(title: none, body) = {
  algo-counter.step()
  block(width: 100%, breakable: true)[
    #line(length: 100%, stroke: 1.5pt)
    #v(-5pt)
    #context [*Algorithm #algo-counter.display()* #title]
    #v(-5pt)
    #line(length: 100%, stroke: 0.7pt)
    #v(-5pt)
    #set align(left)
    #body
    #v(-5pt)
    #line(length: 100%, stroke: 1.5pt)
  ]
}

#let placeholder_image(caption: "This is a placeholder") = (
  figure(
    rect(
      fill: rgb("#F6F6F6"),
      width: 70%,
      height: 25%,
    ),
    caption: [#caption],
    supplement: [Figure]
  )
)

#let template(doc) = {
  set page(
    margin: (x: 1in, y: 1in),
    header: context {
      if counter(page).get().first() > 1 [
        #upper(COURSE) #h(1fr) #emph(upper(REQUIREMENT)): #emph(upper(REQUIREMENT_NAME))
      ]
    },
    footer: context {
      align(center)[
        #text(font: "Linux Libertine", size: 9pt)[
          #counter(page).display(
            "1 of 1",
            both: true,
          )
        ]
      ]
    }
  )
  
  set text(font: "Linux Libertine", size: 9pt)
  set par(justify: true)

  set heading(numbering: "1.1  ")
  show heading: set text(fill: black, font: "Linux Libertine")
  show heading.where(level: 1): set block(above: 2em, below: 1em)
  show heading.where(level: 2): set block(above: 1.5em, below: 0.75em)
  
  show figure.caption: it => [
    #text(weight: "bold")[#it.supplement~#it.counter.display()#it.separator #it.body]
  ]

  /* image("figures/mtpamitinan.jpg")
  v(5pt) */
  align(center)[
    #block(inset: (bottom: 1em))[
      #text(
        font: "New Computer Modern Sans",
        size: 18pt,
        weight: "bold"
      )[Formal Verification of a 4-Bit Minecraft Redstone Adder]
    ]
    
    #block(inset: (bottom: 2em))[
      #text(size: 11pt, font: "Linux Libertine")[ 
      *Paul Timothy R. Necasio* \
      `prnecasio@up.edu.ph` \
        #v(5pt)
        *#COURSE #SECTION* \
        #DATE
      ]
    ]
  ]
  
  show: columns.with(2, gutter: 15pt)

  doc
}