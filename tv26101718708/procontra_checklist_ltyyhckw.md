# Pro/Contra Checklist

- url: https://www.tradingview.com/script/LtyYhcKw/
- type: indicator
- pine_id: PUB;6a31cee64fbd45d5b6e7920cfdff00fd
- version: 1.0

## Description

checkliste für dein regelwerk. was wägt für deinen trade mehr ?

## Source Code

````pine
//@version=6
indicator("Pro/Contra Checklist", overlay = true)

// ============ PRO ============
gPro = "✅ PRO"
p01 = input.bool(false, "MSB",              group = gPro)
p02 = input.bool(false, "LQ Sweep",         group = gPro)
p03 = input.bool(false, "AB",               group = gPro)
p04 = input.bool(false, "Umgedrehter AB",   group = gPro)
p05 = input.bool(false, "IMB",              group = gPro)
p06 = input.bool(false, "Liq Pool",         group = gPro)
p07 = input.bool(false, "Vibs",             group = gPro)
p08 = input.bool(false, "Makro Zeit",       group = gPro)
p09 = input.bool(false, "Discount/Premium", group = gPro)
p10 = input.bool(false, "Open Preise",      group = gPro)
p11 = input.bool(false, "DR Bestätigung",   group = gPro)
p12 = input.bool(false, "BM Long/Short",    group = gPro)

// ============ CONTRA ============
gCon = "❌ CONTRA"
c01 = input.bool(false, "MSB",              group = gCon)
c02 = input.bool(false, "LQ Sweep",         group = gCon)
c03 = input.bool(false, "AB",               group = gCon)
c04 = input.bool(false, "Umgedrehter AB",   group = gCon)
c05 = input.bool(false, "IMB",              group = gCon)
c06 = input.bool(false, "Liq Pool",         group = gCon)
c07 = input.bool(false, "Vibs",             group = gCon)
c08 = input.bool(false, "Makro Zeit",       group = gCon)
c09 = input.bool(false, "Discount/Premium", group = gCon)
c10 = input.bool(false, "Open Preise",      group = gCon)
c11 = input.bool(false, "DR Bestätigung",   group = gCon)
c12 = input.bool(false, "BM Long/Short",    group = gCon)

// ============ STYLE ============
gSty = "🎨 Style"
posStr  = input.string("bottom_right", "Position",
            options = ["bottom_right","bottom_left","top_right","top_left","middle_right","middle_left"],
            group = gSty)
sizeStr = input.string("normal", "Textgröße",
            options = ["tiny","small","normal","large","huge"],
            group = gSty)
bgCol     = input.color(color.new(#1e222d, 10), "Hintergrund",          group = gSty)
proCol    = input.color(#26a69a,                "Pro-Header",           group = gSty)
conCol    = input.color(#ef5350,                "Contra-Header",        group = gSty)
txtCol    = input.color(color.white,            "Textfarbe",            group = gSty)
checkBg   = input.color(color.new(#26a69a, 70), "Hintergrund abgehakt", group = gSty)
showScore = input.bool(true, "Score-Zeile anzeigen",                    group = gSty)

pos = posStr == "bottom_right" ? position.bottom_right :
      posStr == "bottom_left"  ? position.bottom_left  :
      posStr == "top_right"    ? position.top_right    :
      posStr == "top_left"     ? position.top_left     :
      posStr == "middle_right" ? position.middle_right :
                                 position.middle_left

ts = sizeStr == "tiny"  ? size.tiny  :
     sizeStr == "small" ? size.small :
     sizeStr == "large" ? size.large :
     sizeStr == "huge"  ? size.huge  :
                          size.normal

// ============ DATA ============
proLabels = array.from("MSB","LQ Sweep","AB","Umgedrehter AB","IMB","Liq Pool","Vibs","Makro Zeit","Discount/Premium","Open Preise","DR Bestätigung","BM Long/Short")
proStates = array.from(p01, p02, p03, p04, p05, p06, p07, p08, p09, p10, p11, p12)

conLabels = array.from("MSB","LQ Sweep","AB","Umgedrehter AB","IMB","Liq Pool","Vibs","Makro Zeit","Discount/Premium","Open Preise","DR Bestätigung","BM Long/Short")
conStates = array.from(c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11, c12)

nPro = array.size(proLabels)
nCon = array.size(conLabels)
nMax = math.max(nPro, nCon)

// ============ RENDER ============
if barstate.islast
    var table t = table.new(pos, 2, 20, border_width = 1, border_color = color.new(color.gray, 60))

    // Header
    table.cell(t, 0, 0, "✅  PRO",    text_color = color.white, bgcolor = proCol, text_size = ts)
    table.cell(t, 1, 0, "❌  CONTRA", text_color = color.white, bgcolor = conCol, text_size = ts)

    // Items
    for i = 0 to nMax - 1
        if i < nPro
            pTxt  = array.get(proLabels, i)
            pChk  = array.get(proStates, i)
            pMark = pChk ? "✅" : "⬜"
            pBg   = pChk ? checkBg : bgCol
            table.cell(t, 0, i + 1, pMark + "  " + pTxt, text_color = txtCol, bgcolor = pBg, text_size = ts, text_halign = text.align_left)
        else
            table.cell(t, 0, i + 1, "", bgcolor = bgCol)

        if i < nCon
            cTxt  = array.get(conLabels, i)
            cChk  = array.get(conStates, i)
            cMark = cChk ? "✅" : "⬜"
            cBg   = cChk ? checkBg : bgCol
            table.cell(t, 1, i + 1, cMark + "  " + cTxt, text_color = txtCol, bgcolor = cBg, text_size = ts, text_halign = text.align_left)
        else
            table.cell(t, 1, i + 1, "", bgcolor = bgCol)

    if showScore
        proCount = 0
        for s in proStates
            if s
                proCount += 1
        conCount = 0
        for s in conStates
            if s
                conCount += 1

        sRow = nMax + 1
        table.cell(t, 0, sRow, "Score:  " + str.tostring(proCount) + " / " + str.tostring(nPro),
             text_color = color.white, bgcolor = color.new(proCol, 30), text_size = ts)
        table.cell(t, 1, sRow, "Score:  " + str.tostring(conCount) + " / " + str.tostring(nCon),
             text_color = color.white, bgcolor = color.new(conCol, 30), text_size = ts)
````
