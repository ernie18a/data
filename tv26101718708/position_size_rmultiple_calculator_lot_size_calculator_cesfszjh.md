# Position Size & R-Multiple Calculator & Lot Size Calculator

- url: https://www.tradingview.com/script/CesFsZjH-Position-Size-R-Multiple-Calculator-Lot-Size-Calculator/
- type: indicator
- pine_id: PUB;10e6ebf6416a4ec08b9b81e3c201a5e8
- version: 1.0

## Description

Calculates your lot size from a fixed percentage of account risk, so position size is never a decision you make in the heat of a setup.

Drag Entry, Stop Loss and Take Profit on the chart. The script returns the exact lot to trade, the dollar and percentage risk, the R:R, and a mechanical exit plan — all recalculating live as you move the levels.

What it shows

Lot size — derived from account balance, risk %, and stop distance. Always rounded down to your broker's lot step, so you can never accidentally size above your limit.
Risk in $ and % — turns red if the trade breaches your hard cap.
R:R — flagged if it falls below your minimum.
1R / 2R / 3R levels drawn on the chart, plus the exact half-lot to close at 1R and the breakeven stop that follows.
Verdict bar — a single green/orange/red line telling you whether the trade meets your own rules before you click buy.

Setup
Set your account balance and risk % once in Settings. Choose a contract preset (gold, silver, FX major) or enter a custom contract size. For non-USD-quoted symbols, set the quote conversion rate.

Why fixed risk
Inconsistent position sizing is what turns a run of small losses into a hole. Sizing every trade to the same percentage means your worst trade costs the same as your best one — and a losing streak stays survivable.

Not financial advice. This is a sizing tool, not a signal generator; it takes no view on whether a trade is worth taking.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  POSITION SIZE CALCULATOR
//  ---------------------------------------------------------------------
//  HOW TO USE
//    1. Add to chart. It loads immediately with auto levels (ATR based)
//       so you can see it working straight away.
//    2. Click the indicator name on the chart — Entry / Stop / TP appear
//       as DRAGGABLE lines. Drag them where you want.
//       (Or type exact prices in Settings › 2 · Levels.)
//    3. Lot size, risk, R:R and the 1R exit all recalculate live.
//
//  The lot size is derived from your account and a FIXED risk %, so
//  position size stops being a decision you make in the moment.
// ═══════════════════════════════════════════════════════════════════════════

indicator("Position Size Calculator", "PosSize", overlay = true,
     max_lines_count = 20, max_boxes_count = 10, max_labels_count = 20)


// ───────────────────────────── 1 · ACCOUNT ─────────────────────────────
gAcc    = "1 · Account"
balance = input.float(4900.0, "Account balance ($)",    minval = 1,    step = 50,   group = gAcc)
riskPct = input.float(0.5,    "Risk per trade (%)",     minval = 0.01, step = 0.05, group = gAcc,
     tooltip = "Every trade sized to this. Change it here, never on the fly.")
capPct  = input.float(0.5,    "Hard cap (%)",           minval = 0.01, step = 0.05, group = gAcc,
     tooltip = "Verdict bar turns red if the trade would risk more than this.")
minRR   = input.float(2.0,    "Minimum acceptable R:R", minval = 0.1,  step = 0.1,  group = gAcc)


// ──────────────────────── 2 · LEVELS (draggable) ───────────────────────
gLvl    = "2 · Levels"
entryIn = input.price(0.0, "Entry",       group = gLvl,
     tooltip = "Leave at 0 to auto-place at current price. Drag on chart to adjust.")
slIn    = input.price(0.0, "Stop loss",   group = gLvl,
     tooltip = "Leave at 0 for an auto stop 1.5 x ATR away.")
tpIn    = input.price(0.0, "Take profit", group = gLvl,
     tooltip = "Leave at 0 for an auto target 3 x ATR away.")
autoDir = input.string("Long", "Auto-level direction", options = ["Long", "Short"], group = gLvl,
     tooltip = "Only used while levels are still on auto.")


// ──────────────────────────── 3 · INSTRUMENT ───────────────────────────
gIns   = "3 · Instrument"
preset = input.string("XAUUSD · Gold — 100 oz per lot", "Contract preset",
     options = ["XAUUSD · Gold — 100 oz per lot",
                "XAGUSD · Silver — 5,000 oz per lot",
                "FX major — 100,000 units per lot",
                "Custom"], group = gIns)
customSize = input.float(100.0, "Custom contract size", minval = 0.000001, group = gIns)
fxRate     = input.float(1.0,   "Quote currency → USD", minval = 0.000001, group = gIns,
     tooltip = "Leave at 1.0 for USD-quoted symbols (XAUUSD, EURUSD, GBPUSD).\nFor USDJPY use 1 / current USDJPY price.")
lotStep = input.float(0.01, "Lot step",    minval = 0.001, step = 0.001, group = gIns)
lotMin  = input.float(0.01, "Minimum lot", minval = 0.001, step = 0.001, group = gIns)
lotMax  = input.float(50.0, "Maximum lot", minval = 0.001,              group = gIns)


// ───────────────────────────── 4 · DISPLAY ─────────────────────────────
gDsp       = "4 · Display"
tblPos     = input.string("Top right", "Table position",
     options = ["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"], group = gDsp)
showZones  = input.bool(true, "Shade risk / reward zones", group = gDsp)
showLadder = input.bool(true, "Draw 1R / 2R / 3R levels",  group = gDsp)
histBars   = input.int(60, "Draw levels back (bars)", minval = 5, maxval = 300, group = gDsp)

cLong  = color.new(#26a69a, 0)
cShort = color.new(#ef5350, 0)
cWarn  = color.new(#ff9800, 0)
cRisk  = color.new(#ef5350, 82)
cRew   = color.new(#26a69a, 82)
cDim   = color.new(#787b86, 0)
cBg    = color.new(#131722, 20)


// ═══════════════════════════ LEVEL RESOLUTION ══════════════════════════

atrVal = ta.atr(14)
goLong = autoDir == "Long"

// Fall back to sensible auto levels until the user drags / types their own
entry = entryIn > 0 ? entryIn : close
sl    = slIn    > 0 ? slIn    : (goLong ? close - atrVal * 1.5 : close + atrVal * 1.5)
tp    = tpIn    > 0 ? tpIn    : (goLong ? close + atrVal * 3.0 : close - atrVal * 3.0)

usingAuto = entryIn <= 0 or slIn <= 0
tpIsAuto  = tpIn <= 0


// ═══════════════════════════════ MATH ══════════════════════════════════

contractSize = switch preset
    "XAUUSD · Gold — 100 oz per lot"     => 100.0
    "XAGUSD · Silver — 5,000 oz per lot" => 5000.0
    "FX major — 100,000 units per lot"   => 100000.0
    => customSize

// $ moved by a 1.00 price change, per 1.00 lot
valuePerPoint = contractSize * fxRate

isLong = entry > sl
slDist = math.abs(entry - sl)
tpDist = math.abs(tp - entry)
valid  = entry > 0 and sl > 0 and slDist > 0

riskCash = balance * riskPct / 100.0

// Always round DOWN to the lot step — you can never accidentally over-risk
rawLot     = valid ? riskCash / (slDist * valuePerPoint) : 0.0
steppedLot = math.floor(rawLot / lotStep) * lotStep
tooSmall   = valid and steppedLot < lotMin
lot        = math.min(steppedLot, lotMax)
lot       := lot < lotMin ? 0.0 : lot

actualRisk = lot * slDist * valuePerPoint
actualPct  = balance > 0 ? actualRisk / balance * 100.0 : 0.0

rr       = valid and tpDist > 0 ? tpDist / slDist : na
profitTP = lot * tpDist * valuePerPoint

// Half position, correctly stepped — for the mechanical partial at 1R
halfLot = math.floor((lot / 2.0) / lotStep) * lotStep

// R ladder
r1 = isLong ? entry + slDist       : entry - slDist
r2 = isLong ? entry + slDist * 2.0 : entry - slDist * 2.0
r3 = isLong ? entry + slDist * 3.0 : entry - slDist * 3.0


// ═════════════════════════════ VERDICT ═════════════════════════════════

string verdict = ""
color  vColor  = cDim

if not valid
    verdict := "Set Entry and Stop Loss"
    vColor  := cDim
else if tooSmall
    verdict := "SL TOO WIDE — min lot exceeds your risk cap"
    vColor  := cShort
else if actualPct > capPct + 0.0001
    verdict := "OVER CAP — " + str.tostring(actualPct, "#.##") + "% vs " + str.tostring(capPct, "#.##") + "%"
    vColor  := cShort
else if usingAuto
    verdict := "AUTO LEVELS — drag Entry / SL to your real plan"
    vColor  := cWarn
else if tpIsAuto
    verdict := "NO TP SET — plan the exit before you click buy"
    vColor  := cWarn
else if rr < minRR
    verdict := "R:R " + str.tostring(rr, "#.##") + " — below your " + str.tostring(minRR, "#.#") + " minimum"
    vColor  := cWarn
else
    verdict := "MEETS YOUR RULES"
    vColor  := cLong


// ═══════════════════════════ CHART DRAWING ═════════════════════════════

var line  lnEntry = na
var line  lnSl    = na
var line  lnTp    = na
var line  lnR1    = na
var line  lnR2    = na
var line  lnR3    = na
var box   bxRisk  = na
var box   bxRew   = na
var label lbLot   = na

if barstate.islast
    line.delete(lnEntry)
    line.delete(lnSl)
    line.delete(lnTp)
    line.delete(lnR1)
    line.delete(lnR2)
    line.delete(lnR3)
    box.delete(bxRisk)
    box.delete(bxRew)
    label.delete(lbLot)

    if valid
        xL = bar_index - histBars
        xR = bar_index + 25

        if showZones
            bxRisk := box.new(xL, math.max(entry, sl), xR, math.min(entry, sl),
                 border_color = color.new(color.white, 100), bgcolor = cRisk)
            bxRew  := box.new(xL, math.max(entry, tp), xR, math.min(entry, tp),
                 border_color = color.new(color.white, 100), bgcolor = cRew)

        lnEntry := line.new(xL, entry, xR, entry, color = color.new(#2962ff, 0),
             width = 2, style = line.style_solid)
        lnSl := line.new(xL, sl, xR, sl, color = cShort,
             width = 2, style = line.style_solid)
        lnTp := line.new(xL, tp, xR, tp, color = cLong,
             width = 2, style = tpIsAuto ? line.style_dashed : line.style_solid)

        if showLadder
            lnR1 := line.new(bar_index, r1, xR, r1, color = color.new(#26a69a, 40),
                 width = 1, style = line.style_dashed)
            lnR2 := line.new(bar_index, r2, xR, r2, color = color.new(#26a69a, 60),
                 width = 1, style = line.style_dotted)
            lnR3 := line.new(bar_index, r3, xR, r3, color = color.new(#26a69a, 70),
                 width = 1, style = line.style_dotted)

        lbLot := label.new(xR, entry, str.tostring(lot, "#.###") + " lot",
             color = isLong ? cLong : cShort, textcolor = color.white,
             style = label.style_label_left, size = size.normal)


// ═══════════════════════════════ TABLE ═════════════════════════════════

tPos = switch tblPos
    "Top right"    => position.top_right
    "Middle right" => position.middle_right
    "Bottom right" => position.bottom_right
    "Top left"     => position.top_left
    => position.bottom_left

var table t = table.new(tPos, 2, 18, border_width = 1,
     frame_color = color.new(#787b86, 60), frame_width = 1)

f_row(int r, string k, string v, color vc) =>
    table.cell(t, 0, r, k, text_size = size.small, text_color = cDim,
         text_halign = text.align_left,  bgcolor = cBg)
    table.cell(t, 1, r, v, text_size = size.small, text_color = vc,
         text_halign = text.align_right, bgcolor = cBg)

if barstate.islast
    table.clear(t, 0, 0, 1, 17)

    hdr = isLong ? cLong : cShort
    table.cell(t, 0, 0, isLong ? "▲  LONG" : "▼  SHORT", text_size = size.normal,
         text_color = color.white, text_halign = text.align_left,  bgcolor = hdr)
    table.cell(t, 1, 0, syminfo.ticker, text_size = size.normal,
         text_color = color.white, text_halign = text.align_right, bgcolor = hdr)

    f_row(1, "Entry",       str.tostring(entry, format.mintick) + (entryIn > 0 ? "" : "  (auto)"), color.white)
    f_row(2, "Stop loss",   str.tostring(sl,    format.mintick) + (slIn    > 0 ? "" : "  (auto)"), cShort)
    f_row(3, "Take profit", str.tostring(tp,    format.mintick) + (tpIn    > 0 ? "" : "  (auto)"), cLong)
    f_row(4, "SL distance", str.tostring(slDist, format.mintick), color.white)

    table.cell(t, 0, 5, "LOT SIZE", text_size = size.normal, text_color = color.white,
         text_halign = text.align_left, bgcolor = color.new(#1e222d, 0))
    table.cell(t, 1, 5, lot > 0 ? str.tostring(lot, "#.###") : "—", text_size = size.large,
         text_color = lot > 0 ? color.white : cShort,
         text_halign = text.align_right, bgcolor = color.new(#1e222d, 0))

    f_row(6, "Risk",         "$" + str.tostring(actualRisk, "#.##"), color.white)
    f_row(7, "Risk %",       str.tostring(actualPct, "#.###") + "%",
         actualPct > capPct + 0.0001 ? cShort : color.white)
    f_row(8, "R:R",          na(rr) ? "—" : str.tostring(rr, "#.##"),
         na(rr) ? cDim : rr >= minRR ? cLong : cWarn)
    f_row(9, "Profit at TP", "$" + str.tostring(profitTP, "#.##"), cLong)

    table.cell(t, 0, 10, "MECHANICAL EXIT", text_size = size.tiny, text_color = cDim,
         text_halign = text.align_left, bgcolor = color.new(#1e222d, 20))
    table.cell(t, 1, 10, "", text_size = size.tiny, bgcolor = color.new(#1e222d, 20))

    f_row(11, "1R price",    str.tostring(r1, format.mintick), color.white)
    f_row(12, "  → close",   halfLot > 0 ? str.tostring(halfLot, "#.###") + " lot" : "—", color.white)
    f_row(13, "  → then SL", str.tostring(entry, format.mintick) + "  (BE)", color.white)
    f_row(14, "2R / 3R",     str.tostring(r2, format.mintick) + " / " + str.tostring(r3, format.mintick), cDim)

    table.cell(t, 0, 15, verdict, text_size = size.small, text_color = color.white,
         text_halign = text.align_left, bgcolor = vColor)
    table.cell(t, 1, 15, "", text_size = size.small, bgcolor = vColor)
````
