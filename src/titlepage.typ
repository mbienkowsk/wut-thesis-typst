#import "@preview/linguify:0.4.2": *
#let wut-font = "Adagio_Slab"

#let missing-font-placeholder(content) = {
  box(fill: red, outset: 5mm, radius: 5pt, text(
    fill: black,
    weight: "bold",
    size: 24pt,
    content,
  ))
}

#let faculty-box(name, wut-text) = {
  let wut = text(font: wut-font, fallback: false, size: 24pt, wut-text)
  let faculty-text = name.map(x => text(
    font: wut-font,
    fallback: false,
    size: 12pt,
    upper(x),
  ))

  context {
    let max-faculty-width = calc.max(..faculty-text.map(x => measure(x).width))
    let size-delta = measure(wut).width - max-faculty-width
    let max-letters = calc.max(..name.map(x => x.len())) - 1
    let best-tracking = size-delta / max-letters
    let faculty-text-tracked = grid(
      columns: 1,
      row-gutter: .65em,
      ..faculty-text.map(x => text(tracking: best-tracking, x))
    )
    let rows
    let row-gutter
    // Heuristic which accomodates different faculty text sizes
    if faculty-text.len() > 1 {
      rows = (8mm, auto)
      row-gutter = 13pt
    } else {
      row-gutter = 15pt
      rows = 12.5mm - (row-gutter / 2)
    }

    align(center, grid(
      columns: 2,
      column-gutter: 5mm,
      rows: 25mm,
      align(horizon, grid(
        row-gutter: row-gutter,
        rows: rows,
        align(center + bottom, wut),
        align(center + top, faculty-text-tracked),
      )),
      image("../assets/logo_wut.svg", width: 25mm),
    ))
  }
}

#let titlepage(info, author, title, lang, linguify-database, in-print, faculties) = {
  assert(
    faculties.keys().contains(info.faculty),
    message: "Unsupported faculty: "
      + info.faculty
      + "\nSupported faculties: "
      + faculties.keys().join(", "),
  )
  let allowed-thesis-types = ("bachelor", "master", "engineer")
  assert(
    allowed-thesis-types.contains(info.thesis-type),
    message: "Wrong thesis type: "
      + info.thesis-type
      + "\nSupported types: "
      + allowed-thesis-types.join(", "),
  )

  let advisor_present = info.advisor != none
  let l(key) = linguify(key, from: linguify-database, lang: lang)

  set text(size: 12pt, font: "TeX Gyre Heros")
  set par(leading: 0.65em, first-line-indent: 0em, justify: false)
  set block(below: 0em, above: 0em)

  context {
    let thesis-type = text(
      font: wut-font,
      weight: "light",
      fallback: false,
      size: 43pt,
      [#l(info.thesis-type)],
    )
    let faculty
    if measure(thesis-type).width == 0pt {
      thesis-type = missing-font-placeholder[
        Please install _Adagio_Slab_Regular_ and _Adagio_Slab_Light_ fonts, as described in
        the #underline(link("https://typst.app/universe/package/wut-thesis")[template's
          README])
      ]
      faculty = missing-font-placeholder[Logo Placeholder]
    } else {
      faculty = faculty-box(faculties.at(info.faculty), l("wut"))
    }
    align(center, {
      faculty
      v(3em)
      block[#info.institute]
      v(5%)
      thesis-type
      v(5%)
      block[#l("program") #info.program]
      linebreak()
      block[#l("specialisation") #info.specialisation]
      v(4em)
      text(size: 14pt, title)
      v(4em)
      text(size: 21pt, author)
      linebreak()
      v(.8em)
      block[#l("index-number") #info.index-number]
      linebreak()
      v(4em)
      block[#l("supervisor")\ #info.supervisor]
      if advisor_present {
        v(2em)
        block[#l("advisor")\ #info.advisor]
      }
      v(1fr)
      block[#l("city") #info.date.display("[year]")]
    })
  }
  pagebreak(weak: true, to: if in-print { "odd" } else { none })
}
