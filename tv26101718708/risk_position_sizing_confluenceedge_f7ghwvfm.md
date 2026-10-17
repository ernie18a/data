# Risk & Position Sizing [ConfluenceEdge]

- url: https://www.tradingview.com/script/f7ghwvFM-Risk-Position-Sizing-ConfluenceEdge/
- type: indicator
- pine_id: PUB;1c3839422c1941cc8eb58a71e94cad6f
- version: 1.0

## Description

[b]Risk & Position Sizing — the stop first, the size second.[/b]

Most traders pick a setup and ask about risk later. This tool reverses the order: define the risk, set a volatility-aware stop, and read the exact position size off the chart — no external calculator.

[b]What it does[/b]
[list]
[*]ATR-based stop (1.5× default) or manual stop — sized to volatility, not guesswork
[*]Automatic 1R / 2R / 3R target ladder drawn from the same stop distance
[*]Position size computed on chart: risk budget ÷ stop distance × point value
[*]Long or Short; entry from last close or manual price
[/list]

[b]The panel[/b]
Account, risk amount, stop, distance, size and the R-value in money — one glance, nothing else.

[b]How to use it[/b]
[list]
[*]Load it on any timeframe — the ladder appears at the last bar
[*]Set your account size and risk % in the panel settings (1% is the classic starting point)
[*]Switch the entry to "Manual" to test a specific price; "Last Close" keeps the live read
[*]The Size line is contracts or shares for the symbol's point value — check it before you trade, that is the whole point
[/list]

[b]Why it is different[/b]
Position sizing usually lives in a calculator you open after the trade. Here it sits on the chart, next to the levels it belongs to — and because the targets come from the same stop distance, risk and reward stay one equation.

Raw math only — no signals, no interpretation. Works on futures, forex, stocks and indices.

Educational content only. Not investment advice.

## Source Code

````pine
//@version=6
indicator("Risk & Position Sizing [ConfluenceEdge]", shorttitle="Risk Sizing [ConfluenceEdge]", overlay=true, max_labels_count=200, max_lines_count=200)

// ============================================================
//  RISK & POSITION SIZING [ConfluenceEdge]
//  ATR-based stop, 1R/2R/3R ladder and position size on chart.
//  Raw math only — no signals, no interpretation.
// ============================================================

// ---------- Trade setup ----------
tradeSide   = input.string("Long", "Side", options = ["Long", "Short"], group = "Trade Setup")
entrySource = input.string("Last Close", "Entry price", options = ["Last Close", "Manual"], group = "Trade Setup")
manualEntry = input.float(0.0, "Manual entry", group = "Trade Setup", tooltip = "Used when 'Manual' is selected. Falls back to the last close if left at 0.")

// ---------- Stop ----------
stopSource = input.string("ATR Multiple", "Stop mode", options = ["ATR Multiple", "Manual"], group = "Risk Stop")
atrLength  = input.int(14, "ATR length", minval = 1, group = "Risk Stop")
atrMult    = input.float(1.5, "ATR multiple", step = 0.1, minval = 0.1, group = "Risk Stop")
manualStop = input.float(0.0, "Manual stop price", group = "Risk Stop", tooltip = "Used when 'Manual' is selected.")

// ---------- Money ----------
riskMode    = input.string("% of Account", "Risk budget", options = ["% of Account", "Fixed amount"], group = "Risk Budget")
accountSize = input.float(10000.0, "Account size", group = "Risk Budget")
riskPct     = input.float(1.0, "Risk %", step = 0.1, minval = 0.01, group = "Risk Budget")
riskFixed   = input.float(100.0, "Fixed risk amount", group = "Risk Budget")

// ---------- Display ----------
showTargets = input.bool(true, "Show 1R / 2R / 3R targets", group = "Display")
showPanel   = input.bool(true, "Show sizing panel", group = "Display")
showPrices  = input.bool(true, "Prices in labels", group = "Display")
extendRight = input.int(25, "Extend lines right (bars)", minval = 1, group = "Display")
labelSize   = input.string("Large", "Target label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Display")
panelSize   = input.string("Normal", "Panel text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Display")
panelPos    = input.string("Top right", "Panel position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = "Display")

// ---------- Colors ----------
cEntry  = input.color(#42A5F5, "Entry", group = "Colors", tooltip = "Neutral by default: the entry is neither profit nor loss, so it should not read as either.")
cStop   = input.color(#EF5350, "Stop", group = "Colors")
cTarget = input.color(#26A69A, "Targets", group = "Colors")

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

// ENTRY and STOP carry a solid box, so at equal text size they read much heavier
// than the plain target labels. One step down evens that out.
f_size_down(string s) =>
    s == "Huge" ? size.large : s == "Large" ? size.normal : s == "Normal" ? size.small : size.tiny

string szTarget = f_size(labelSize)
string szMarker = f_size_down(labelSize)
string szPanel  = f_size(panelSize)
string szHeader = panelSize == "Tiny" ? size.small : panelSize == "Small" ? size.normal : panelSize == "Normal" ? size.large : size.huge

string tblPos = panelPos == "Top left" ? position.top_left : panelPos == "Bottom right" ? position.bottom_right : panelPos == "Bottom left" ? position.bottom_left : panelPos == "Middle right" ? position.middle_right : position.top_right

// ---------- Calculation ----------
// atrValue, not atr — a variable named like a common function is legal but
// invites confusion in a script other people will read.
float atrValue = ta.atr(atrLength)

// A manual entry of 0 would draw the whole ladder at price 0 and make the chart
// unreadable, so an unset manual entry falls back to the last close.
float entry = math.round_to_mintick(entrySource == "Manual" and manualEntry > 0.0 ? manualEntry : close)

float stop = na
if stopSource == "ATR Multiple"
    stop := math.round_to_mintick(tradeSide == "Long" ? entry - atrValue * atrMult : entry + atrValue * atrMult)
else
    stop := manualStop != 0.0 ? math.round_to_mintick(manualStop) : na

float riskAmount = riskMode == "% of Account" ? accountSize * riskPct / 100.0 : riskFixed
float dist       = math.abs(entry - stop)
float units      = not na(dist) and dist > 0.0 ? riskAmount / (dist * syminfo.pointvalue) : na

// ---------- Palette ----------
color cLong     = color.new(#26A69A, 0)
color cShort    = color.new(#EF5350, 0)
color cText     = color.new(#E8EAF6, 0)
color cPanelBg  = color.new(#0D1B2A, 10)
color cPanelHdr = color.new(#1E88E5, 0)
// Fully transparent — used for the spacer row that keeps the panel off the
// chart edge. The table itself is transparent too, so this really is a gap and
// not just a strip of panel colour.
color cClear    = color.new(color.black, 100)

// ---------- Drawing (last bar) ----------
var line  entryLine = na
var line  stopLine  = na
var line  glowLine  = na
var line  t1Line    = na
var line  t2Line    = na
var line  t3Line    = na
var label entryLbl  = na
var label stopLbl   = na
var label t1Lbl     = na
var label t2Lbl     = na
var label t3Lbl     = na
var table panel     = na

// Only deletes — a function may read globals and call void built-ins, but it
// must not assign to them with :=. That is why every := stays in the main scope.
f_cleanup() =>
    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(glowLine)
    line.delete(t1Line)
    line.delete(t2Line)
    line.delete(t3Line)
    label.delete(entryLbl)
    label.delete(stopLbl)
    label.delete(t1Lbl)
    label.delete(t2Lbl)
    label.delete(t3Lbl)

f_txt(string name, float price) =>
    showPrices ? name + " · " + str.tostring(price, format.mintick) : name

if barstate.islast
    f_cleanup()
    int x1 = bar_index - 8
    int x2 = bar_index + extendRight

    // Every label sits at the RIGHT end of its line, in the empty space beside
    // the last candle. That keeps them off the price action and makes the old
    // "above or below the line?" question disappear — with style_label_left the
    // box is vertically centred on the level, so a short stop above the entry
    // needs no special case.

    // Entry
    entryLine := line.new(chart.point.from_index(x1, entry), chart.point.from_index(x2, entry), color = cEntry, width = 2, style = line.style_dashed)
    entryLbl  := label.new(chart.point.from_index(x2, entry), f_txt(tradeSide == "Long" ? "ENTRY ▲" : "ENTRY ▼", entry), style = label.style_label_left, color = cEntry, textcolor = color.white, size = szMarker)

    // Stop with glow
    if not na(stop)
        glowLine := line.new(chart.point.from_index(x1, stop), chart.point.from_index(x2, stop), color = color.new(cStop, 82), width = 7)
        stopLine := line.new(chart.point.from_index(x1, stop), chart.point.from_index(x2, stop), color = cStop, width = 2)
        stopLbl  := label.new(chart.point.from_index(x2, stop), f_txt("STOP", stop), style = label.style_label_left, color = cStop, textcolor = color.white, size = szMarker)

    // R ladder — dashed, and the further out the target, the more solid
    if showTargets and not na(dist) and dist > 0.0
        float t1 = math.round_to_mintick(tradeSide == "Long" ? entry + dist : entry - dist)
        float t2 = math.round_to_mintick(tradeSide == "Long" ? entry + 2.0 * dist : entry - 2.0 * dist)
        float t3 = math.round_to_mintick(tradeSide == "Long" ? entry + 3.0 * dist : entry - 3.0 * dist)
        t1Line := line.new(chart.point.from_index(x1, t1), chart.point.from_index(x2, t1), color = color.new(cTarget, 55), width = 1, style = line.style_dashed)
        t2Line := line.new(chart.point.from_index(x1, t2), chart.point.from_index(x2, t2), color = color.new(cTarget, 30), width = 1, style = line.style_dashed)
        t3Line := line.new(chart.point.from_index(x1, t3), chart.point.from_index(x2, t3), color = color.new(cTarget, 0),  width = 2, style = line.style_dashed)
        t1Lbl  := label.new(chart.point.from_index(x2, t1), f_txt("1R", t1), style = label.style_label_left, color = color.new(cTarget, 80), textcolor = color.new(cTarget, 0), size = szTarget)
        t2Lbl  := label.new(chart.point.from_index(x2, t2), f_txt("2R", t2), style = label.style_label_left, color = color.new(cTarget, 80), textcolor = color.new(cTarget, 0), size = szTarget)
        t3Lbl  := label.new(chart.point.from_index(x2, t3), f_txt("3R", t3), style = label.style_label_left, color = color.new(cTarget, 80), textcolor = color.new(cTarget, 0), size = szTarget)

    // Panel — row 0 is an invisible spacer so the block does not touch the
    // chart edge. The table has no background of its own; every visible cell
    // carries cPanelBg, which is what makes the spacer a real gap.
    if showPanel
        if na(panel)
            panel := table.new(tblPos, 2, 9, bgcolor = cClear, border_width = 0, frame_width = 0)
        string sizeTxt = na(units) ? "—" : str.tostring(units, "#.##")
        string distTxt = na(dist) ? "—" : str.tostring(dist, "#.##")
        string stopTxt = na(stop) ? "—" : str.tostring(stop, format.mintick)
        table.cell(panel, 0, 0, " ", bgcolor = cClear, text_size = size.tiny)
        table.cell(panel, 1, 0, " ", bgcolor = cClear, text_size = size.tiny)
        table.cell(panel, 0, 1, "RISK & SIZE", text_color = color.white, bgcolor = cPanelHdr, text_size = szHeader)
        table.cell(panel, 1, 1, tradeSide, text_color = color.white, bgcolor = tradeSide == "Long" ? cLong : cShort, text_size = szHeader)
        table.cell(panel, 0, 2, "Account", text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 1, 2, str.tostring(accountSize, "#,##0"), text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 0, 3, "Risk", text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 1, 3, str.tostring(riskAmount, "#,##0.00"), text_color = cTarget, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 0, 4, "Stop", text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 1, 4, stopTxt, text_color = cStop, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 0, 5, "Distance", text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 1, 5, distTxt, text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 0, 6, "Size", text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 1, 6, sizeTxt, text_color = cTarget, bgcolor = cPanelBg, text_size = szHeader)
        table.cell(panel, 0, 7, "1R", text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 1, 7, str.tostring(riskAmount, "#,##0.00"), text_color = cTarget, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 0, 8, "3R", text_color = cText, bgcolor = cPanelBg, text_size = szPanel)
        table.cell(panel, 1, 8, str.tostring(riskAmount * 3.0, "#,##0.00"), text_color = cTarget, bgcolor = cPanelBg, text_size = szPanel)
````
