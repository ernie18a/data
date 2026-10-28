# BTC Map: Range, Liquidity, Scenarios

- url: https://www.tradingview.com/script/82fiFoXu-BTC-Map-Range-Liquidity-Scenarios/
- type: indicator
- pine_id: PUB;aaa565eb0a8a4d85907535469164ed8c
- version: 1.0

## Description

BTCUSD: Compressed at 82–83.6K — Crowd Long, Spot Bid Emerging

📌 SUMMARY
Bitcoin is boxed between 82,015 and 83,600 after last week's ETF-driven flush to 80.3K. Volatility is at a two-week low (1H ADX ~9, ATR ~270). Positioning is long-heavy, but the first spot buying since the sell-off is showing up. I expect a range over the weekend and a range break once US flows return. Direction is not decided yet.

🔎 WHAT HAPPENED
- Oct 7–8: about $729M left US spot BTC ETFs in two sessions. Price fell from ~86.5K to 80.3K on heavy long liquidations.
- The bounce to 83.6K came on falling open interest: short covering, not new demand.
- Macro headwind: the 10Y Treasury yield is at multi-decade highs, and the Fed minutes kept a December hike on the table.

📊 POSITIONING (Binance and aggregated data)
- Aggregated OI is down ~5% from the Oct 7 peak (≈660K → 627K BTC): leverage was flushed.
- Long/Short ratio by accounts rose from 1.0 to 1.54 into the drop: the crowd bought the dip.
- Top-trader L/S by positions fell from ~2.0 to 1.56: large players trimmed longs but stay net long.
- Funding is mildly positive. Spot CVD has turned up from its Oct 8 low.

🗺 KEY LEVELS
- 84,000–86,000: dense short-liquidation cluster (model estimate)
- 84,045: Oct 7 breakdown level
- 83,600: range high
- 82,015: range low
- 80,314: Oct 8 low, with a long-liquidation pool below 82K

🎯 SCENARIOS (rough weights, not a proven edge)
A) Range 82.0–83.6K through the weekend: ~40%
B) Break below 82,015 with rising OI → retest of 81K–80.3K: ~35%
C) Hourly close above 83,600 with rising spot CVD → 84–84.5K into short liquidations: ~25%

✅ WHAT WOULD CHANGE MY VIEW
- Spot CVD keeps rising and price closes above 83.6K → C
- Top-trader L/S falls while account L/S rises → risk of B grows
- Monday ETF flows: inflows ease the pressure, another outflow day confirms it

⚠️ NOTES
The odds are subjective and not backtested. In this compression, 1H stops tighter than ~500 points sit inside normal noise. Not financial advice.

## Source Code

````pine
//@version=6
// BTCUSD idea map — Oct 10, 2026
// Draws: trading range, liquidity zones (Coinglass model estimates), key levels and scenario paths.
// All levels are editable in the indicator settings.
indicator("BTC Map: Range, Liquidity, Scenarios", overlay = true, max_lines_count = 50, max_boxes_count = 20, max_labels_count = 50)

// ---------- Inputs ----------
grpL = "Levels"
rangeHigh   = input.float(83600, "Range high",                 group = grpL)
rangeLow    = input.float(82015, "Range low",                  group = grpL)
breakdown   = input.float(84045, "Oct 7 breakdown level",      group = grpL)
octLow      = input.float(80314, "Oct 8 low",                  group = grpL)
shortLiqTop = input.float(86000, "Short-liq cluster top",      group = grpL)
shortLiqBot = input.float(84000, "Short-liq cluster bottom",   group = grpL)
longLiqTop  = input.float(81500, "Long-liq pool top",          group = grpL)
longLiqBot  = input.float(80000, "Long-liq pool bottom",       group = grpL)

grpS = "Scenarios"
showScen  = input.bool(true,      "Show scenario paths",       group = grpS)
targetUp  = input.float(84400,    "Scenario C target",         group = grpS)
targetDn  = input.float(80400,    "Scenario B target",         group = grpS)
txtA      = input.string("A · Range 82.0–83.6K (~40%)",         "Label A", group = grpS)
txtB      = input.string("B · Break ↓ → 80.4K (~35%)",          "Label B", group = grpS)
txtC      = input.string("C · Break ↑ → 84.4K (~25%)",          "Label C", group = grpS)

grpV = "Layout"
leftBars  = input.int(80, "Zones start (bars back)",           group = grpV, minval = 10)
rightBars = input.int(40, "Zones end (bars forward)",          group = grpV, minval = 10)
pathBars  = input.int(30, "Scenario length (bars forward)",    group = grpV, minval = 5)

// ---------- Colors ----------
cRange   = color.new(color.gray,   85)
cRangeBd = color.new(color.gray,   40)
cShort   = color.new(color.teal,   85)
cShortBd = color.new(color.teal,   50)
cLong    = color.new(color.red,    85)
cLongBd  = color.new(color.red,    50)
cText    = color.new(color.white,  10)
cNone    = color.new(color.black, 100)
cA       = color.new(color.gray,    0)
cB       = color.new(color.red,     0)
cC       = color.new(color.green,   0)

// ---------- Drawing (redrawn on the last bar only) ----------
var array<line>  lns = array.new<line>()
var array<box>   bxs = array.new<box>()
var array<label> lbs = array.new<label>()

if barstate.islast
    for l in lns
        line.delete(l)
    lns.clear()
    for b in bxs
        box.delete(b)
    bxs.clear()
    for lb in lbs
        label.delete(lb)
    lbs.clear()

    x0 = bar_index - leftBars
    x1 = bar_index + rightBars

    // Zones
    bxs.push(box.new(x0, rangeHigh, x1, rangeLow, border_color = cRangeBd, border_style = line.style_dashed, bgcolor = cRange, text = "RANGE  82,015 – 83,600", text_color = cText, text_size = size.small, text_halign = text.align_left, text_valign = text.align_top))
    bxs.push(box.new(x0, shortLiqTop, x1, shortLiqBot, border_color = cShortBd, bgcolor = cShort, text = "Short-liquidation cluster 84–86K (est.)", text_color = cText, text_size = size.small, text_halign = text.align_left, text_valign = text.align_center))
    bxs.push(box.new(x0, longLiqTop, x1, longLiqBot, border_color = cLongBd, bgcolor = cLong, text = "Long-liquidation pool (est.)", text_color = cText, text_size = size.small, text_halign = text.align_left, text_valign = text.align_center))

    // Key levels
    lns.push(line.new(x0, breakdown, x1, breakdown, color = color.new(color.orange, 0), style = line.style_dashed, width = 1))
    lbs.push(label.new(x1, breakdown, "84,045 · Oct 7 breakdown", color = cNone, textcolor = color.orange, style = label.style_label_left, size = size.small))
    lns.push(line.new(x0, octLow, x1, octLow, color = color.new(color.red, 0), style = line.style_dotted, width = 1))
    lbs.push(label.new(x1, octLow, "80,314 · Oct 8 low", color = cNone, textcolor = color.red, style = label.style_label_left, size = size.small))
    lbs.push(label.new(x1, rangeHigh, "83,600 · range high", color = cNone, textcolor = cText, style = label.style_label_left, size = size.small))
    lbs.push(label.new(x1, rangeLow, "82,015 · range low", color = cNone, textcolor = cText, style = label.style_label_left, size = size.small))

    // Scenario paths from the last close
    if showScen
        xe = bar_index + pathBars
        lns.push(line.new(bar_index, close, xe, close, color = cA, style = line.style_dashed, width = 2))
        lbs.push(label.new(xe, close, txtA, color = cNone, textcolor = cA, style = label.style_label_left, size = size.small))
        lns.push(line.new(bar_index, close, xe, targetDn, color = cB, style = line.style_arrow_right, width = 2))
        lbs.push(label.new(xe, targetDn, txtB, color = cNone, textcolor = cB, style = label.style_label_left, size = size.small))
        lns.push(line.new(bar_index, close, xe, targetUp, color = cC, style = line.style_arrow_right, width = 2))
        lbs.push(label.new(xe, targetUp, txtC, color = cNone, textcolor = cC, style = label.style_label_left, size = size.small))
````
