<!-- tradingview-pine-id: PUB;78609e55a33247dfbdccfa7d924869f5 -->
<!-- tradingviewscripts-format: 1 -->
# Watermark

Source: https://www.tradingview.com/script/r2nwnaeA-Modern-Watermark/

## Description

Clean corner watermark for screenshots and posts. 

Displays the ticker with its timeframe, plus the company name, industry, and optionally the sector and exchange — pulled automatically from the symbol, so nothing needs updating when you flip charts.

Adjustable position (all nine anchors), text sizes, colors, and transparency. 

Percentage-based side and top padding keeps the block off the chart edge and scales with your screen. 

Monospace toggle for a terminal look, plus uppercase and blank-line spacing options. Sub-lines collapse automatically on symbols without description or industry data, so futures, forex, and crypto stay clean.

---

## Source Code

````pine
//@version=6
indicator("Watermark", overlay = true)

// ================= Inputs =================
grpC     = "Content"
showDesc = input.bool(true,  "Company name", group = grpC)
showInd  = input.bool(true,  "Industry",     group = grpC)
showSec  = input.bool(false, "Sector",       group = grpC)
showTF   = input.bool(true,  "Timeframe next to ticker", group = grpC)
upper    = input.bool(false, "Uppercase sub-lines",      group = grpC)
gapSub   = input.bool(true,  "Blank line between sub-lines", group = grpC)

grpP    = "Padding"
padLeft = input.float(3.0, "Side padding (% of chart width)",  minval = 0, maxval = 40, step = 0.5, group = grpP)
padTop  = input.float(6.0, "Top padding (% of chart height)",  minval = 0, maxval = 40, step = 0.5, group = grpP)
subInd  = input.int(2, "Sub-line indent (spaces)", minval = 0, maxval = 20, group = grpP)

grpS    = "Style"
posIn   = input.string("Top Left", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpS)
symSize = input.string("huge",   "Ticker size",   options = ["tiny", "small", "normal", "large", "huge"], group = grpS)
subSize = input.string("normal", "Sub-line size", options = ["tiny", "small", "normal", "large"], group = grpS)
symCol  = input.color(color.new(#d1d4dc, 25), "Ticker color",   group = grpS)
subCol  = input.color(color.new(#787b86, 20), "Sub-line color", group = grpS)
mono    = input.bool(false, "Monospace", group = grpS)

// ================= Helpers =================
posOf(string s) =>
    s == "Top Left"      ? position.top_left      :
     s == "Top Center"    ? position.top_center    :
     s == "Top Right"     ? position.top_right     :
     s == "Middle Left"   ? position.middle_left   :
     s == "Middle Center" ? position.middle_center :
     s == "Middle Right"  ? position.middle_right  :
     s == "Bottom Left"   ? position.bottom_left   :
     s == "Bottom Center" ? position.bottom_center : position.bottom_right

szOf(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.huge

tfFmt() =>
    int m = timeframe.multiplier
    string out = timeframe.period
    if timeframe.isseconds
        out := str.tostring(m) + "s"
    else if timeframe.isminutes
        out := m >= 60 and m % 60 == 0 ? str.tostring(int(m / 60)) + "H" : str.tostring(m) + "m"
    else if timeframe.isdaily
        out := str.tostring(m) + "D"
    else if timeframe.isweekly
        out := str.tostring(m) + "W"
    else if timeframe.ismonthly
        out := str.tostring(m) + "M"
    out

ok(string s) =>
    not na(s) and s != ""

subTxt() =>
    string sep = gapSub ? "\n\n" : "\n"
    string ind = subInd > 0 ? str.repeat(" ", subInd) : ""
    string t = ""
    if showDesc and ok(syminfo.description)
        t := ind + syminfo.description
    if showInd and ok(syminfo.industry)
        t := t == "" ? ind + syminfo.industry : t + sep + ind + syminfo.industry
    if showSec and ok(syminfo.sector)
        t := t == "" ? ind + syminfo.sector : t + sep + ind + syminfo.sector
    upper ? str.upper(t) : t

// ================= Layout =================
isLeft   = str.contains(posIn, "Left")
isRight  = str.contains(posIn, "Right")
isBottom = str.contains(posIn, "Bottom")

cPad  = isRight ? 1 : 0
cTxt  = isRight ? 0 : 1
rPad  = isBottom ? 2 : 0
rHead = isBottom ? 0 : 1
rSub  = isBottom ? 1 : 2

wPad  = isLeft or isRight ? padLeft : 0.0
align = isRight ? text.align_right : text.align_left
fam   = mono ? font.family_monospace : font.family_default

// ================= Render =================
var table wm = table.new(posOf(posIn), 2, 3, frame_width = 0, border_width = 0)

if barstate.islast
    string head = syminfo.ticker + (showTF ? "," + tfFmt() : "")

    table.cell(wm, cPad, rHead, "", width = wPad,  text_size = size.tiny)
    table.cell(wm, cTxt, rPad,  "", height = padTop, text_size = size.tiny)
    table.cell(wm, cPad, rPad,  "", width = wPad, height = padTop, text_size = size.tiny)
    table.cell(wm, cPad, rSub,  "", width = wPad,  text_size = size.tiny)

    table.cell(wm, cTxt, rHead, head, text_color = symCol, text_size = szOf(symSize), text_halign = align, text_font_family = fam, text_formatting = text.format_bold)
    table.cell(wm, cTxt, rSub,  subTxt(), text_color = subCol, text_size = szOf(subSize), text_halign = align, text_font_family = fam, text_formatting = text.format_bold)
````
