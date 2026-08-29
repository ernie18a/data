<!-- tradingview-pine-id: PUB;0e08c0934d8d42499e4b769f36023b9f -->
<!-- tradingviewscripts-format: 1 -->
# MA Stack — Multi-Timeframe Moving Averages (AMASRS v2)

Source: https://www.tradingview.com/script/szBDToBv-MA-Stack-Multi-Timeframe-Moving-Averages/

## Description

WHAT IT DOES

MA Stack replaces the usual clutter of adding moving averages to a chart one by one. It plots up to five moving averages in a single indicator. Each moving average can have its own type, length, timeframe, offset and color.

The script adds three optional visual layers:

• Fills between adjacent moving averages. The area is green when the faster MA is above the slower MA and orange when it is below. This makes compression, expansion and crossovers of the MA stack easier to recognize.

• Trend background, disabled by default. The background is green when the fastest MA is above every slower MA, red when it is below all of them, and yellow when the stack has a mixed order.

• Slope projections. Each moving average is extended into the future with a dotted line based on its latest one-bar slope. The projection always uses the same color as its moving average. It is a visual extrapolation, not a price forecast or trading signal.

HOW IT WORKS

Each of the five MA slots calculates one moving average using the selected source, type and length. The available types are SMA, EMA, WMA, VWMA, HMA and RMA.

Each slot can use the chart timeframe or a separate higher timeframe. Higher-timeframe calculations use confirmed values with lookahead disabled. In real time, the script uses the previous confirmed higher-timeframe value, so the higher-timeframe lines update after confirmation rather than following an unfinished higher-timeframe bar.

The slope projection takes the latest one-bar change in the moving average and extends that change over the selected projection length, which is 10 bars by default. The script maintains one projection line per moving average and updates it in place, preventing old projection lines from accumulating on the chart.

PRESETS

The presets provide commonly used moving-average combinations:

• Classic 20/50/200 SMA — short-, medium- and long-term simple moving averages.

• EMA Ribbon 8/13/21/34/55 — a Fibonacci-spaced EMA ribbon for observing compression, expansion and changes in trend structure.

• Golden Cross 50/200 SMA — the traditional pair used to identify golden-cross and death-cross conditions. The fill changes color when the averages cross.

• Scalping 9/21 EMA — a fast EMA pair intended for observing short-term momentum.

• Swing 10/20/50 EMA — three exponential moving averages for observing multi-day trend structure.

• Multi-TF Trend (21/50 EMA, D+W) — the 21 and 50 EMA from the Daily timeframe together with the 21 and 50 EMA from the Weekly timeframe. This preset makes it possible to compare price with both higher-timeframe structures on one chart.

• Bitcoin Support Band (20W SMA / 21W EMA) — the 20-week SMA and 21-week EMA, calculated from Weekly data regardless of the chart timeframe.

Select Manual to configure all five MA slots individually. Manual settings include enable or disable, MA type, length, timeframe, offset and color. Colors, offsets, line width and visual controls remain available when a preset is selected.

SETTINGS

• Preset and Source — select a preset and the price source used in all calculations.

• MA 1 to MA 5 — configure each slot's status, type, length, timeframe, offset and color. An empty timeframe uses the chart timeframe. These calculation settings are used when Preset is set to Manual; colors and offsets remain available for presets.

• Visuals — enable or disable fills, the trend background and slope projections; set the projection length and line width. The trend background is disabled by default.

HOW TO USE IT

Use a preset when you want a familiar MA combination without configuring every line manually. Use Manual mode when you need different MA types, periods or timeframes.

The relative order of the moving averages can help organize trend context:

• A faster MA above the slower averages indicates bullish alignment.
• A faster MA below the slower averages indicates bearish alignment.
• A mixed or compressed stack indicates that trend direction is less clearly aligned.

These observations are descriptive, not entry or exit signals. They should be combined with the user's own market analysis and risk management.

LIMITATIONS

• The slope projection is a straight-line extrapolation of the latest change in an MA. It does not predict future prices.

• Higher-timeframe values update only after confirmation. This creates a deliberate delay compared with an unfinished higher-timeframe bar.

• A slot's selected timeframe should normally be equal to or higher than the chart timeframe. For example, a Weekly moving average is not intended for use as a lower-timeframe data source on a Monthly chart.

• Moving averages are lagging calculations derived from past prices. Presets do not guarantee that a particular combination is suitable for every market or timeframe.

MA Stack is an open-source visual organization tool built from standard moving-average calculations. It does not generate automated trade signals or alerts and does not constitute investment advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © myteam

//@version=6
indicator("MA Stack — Multi-Timeframe Moving Averages (AMASRS v2)", overlay = true, shorttitle = "MA Stack", max_lines_count = 20, dynamic_requests = true)

// ═══════════════ PRESETS ═══════════════
// Presets cover common MA playbooks so users don't rebuild them by hand.
// "Manual" unlocks the per-MA settings below.
presetInput = input.string("Classic 20/50/200 SMA", title = "Preset", options = ["Manual", "Classic 20/50/200 SMA", "EMA Ribbon 8/13/21/34/55", "Golden Cross 50/200 SMA", "Scalping 9/21 EMA", "Swing 10/20/50 EMA", "Multi-TF Trend (21/50 EMA, D+W)", "Bitcoin Support Band (20W SMA / 21W EMA)"], group = "Preset", tooltip = "Ready-made MA combinations. Select 'Manual' to configure each MA yourself in the groups below.")

srcInput = input.source(close, title = "Source", group = "Preset")

// ═══════════════ MANUAL MA SLOTS (used when Preset = Manual) ═══════════════
grp1 = "MA 1"
grp2 = "MA 2"
grp3 = "MA 3"
grp4 = "MA 4"
grp5 = "MA 5"

en1In  = input.bool(true,  "Enable", group = grp1, inline = "1a")
tp1In  = input.string("SMA", "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], group = grp1, inline = "1a")
ln1In  = input.int(20, "Length", minval = 1, group = grp1, inline = "1b")
tf1In  = input.timeframe("", "TF", group = grp1, inline = "1b", tooltip = "Empty = chart timeframe. Each MA can use its own timeframe.")
of1In  = input.int(0, "Offset", group = grp1, inline = "1c")
cl1    = input.color(color.aqua, "", group = grp1, inline = "1c")

en2In  = input.bool(true,  "Enable", group = grp2, inline = "2a")
tp2In  = input.string("SMA", "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], group = grp2, inline = "2a")
ln2In  = input.int(50, "Length", minval = 1, group = grp2, inline = "2b")
tf2In  = input.timeframe("", "TF", group = grp2, inline = "2b")
of2In  = input.int(0, "Offset", group = grp2, inline = "2c")
cl2    = input.color(color.fuchsia, "", group = grp2, inline = "2c")

en3In  = input.bool(false, "Enable", group = grp3, inline = "3a")
tp3In  = input.string("SMA", "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], group = grp3, inline = "3a")
ln3In  = input.int(100, "Length", minval = 1, group = grp3, inline = "3b")
tf3In  = input.timeframe("", "TF", group = grp3, inline = "3b")
of3In  = input.int(0, "Offset", group = grp3, inline = "3c")
cl3    = input.color(color.yellow, "", group = grp3, inline = "3c")

en4In  = input.bool(false, "Enable", group = grp4, inline = "4a")
tp4In  = input.string("SMA", "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], group = grp4, inline = "4a")
ln4In  = input.int(200, "Length", minval = 1, group = grp4, inline = "4b")
tf4In  = input.timeframe("", "TF", group = grp4, inline = "4b")
of4In  = input.int(0, "Offset", group = grp4, inline = "4c")
cl4    = input.color(color.orange, "", group = grp4, inline = "4c")

en5In  = input.bool(false, "Enable", group = grp5, inline = "5a")
tp5In  = input.string("EMA", "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], group = grp5, inline = "5a")
ln5In  = input.int(55, "Length", minval = 1, group = grp5, inline = "5b")
tf5In  = input.timeframe("", "TF", group = grp5, inline = "5b")
of5In  = input.int(0, "Offset", group = grp5, inline = "5c")
cl5    = input.color(color.lime, "", group = grp5, inline = "5c")

// ═══════════════ VISUALS ═══════════════
grpV = "Visuals"
showFills = input.bool(true, "Fill between adjacent MAs", group = grpV, tooltip = "Colors the space between neighbouring enabled MAs: bullish tint when the faster MA is above, bearish when below.")
showBg    = input.bool(false, "Trend background", group = grpV, tooltip = "Green: fastest MA above all slower ones. Red: below all. Yellow: mixed.")
showProj  = input.bool(true, "Slope projection", group = grpV, inline = "pj")
projLen   = input.int(10, "bars", minval = 1, maxval = 100, group = grpV, inline = "pj", tooltip = "Dotted continuation of each MA using its current slope. Projection color always matches the MA line color.")
lineW     = input.int(2, "Line width", minval = 1, maxval = 5, group = grpV)

// ═══════════════ PRESET RESOLUTION ═══════════════
// Ternary chains keep these values 'simple', which ta.ema()/request.security() require.
manual   = presetInput == "Manual"
pClassic = presetInput == "Classic 20/50/200 SMA"
pRibbon  = presetInput == "EMA Ribbon 8/13/21/34/55"
pGolden  = presetInput == "Golden Cross 50/200 SMA"
pScalp   = presetInput == "Scalping 9/21 EMA"
pSwing   = presetInput == "Swing 10/20/50 EMA"
pMtf     = presetInput == "Multi-TF Trend (21/50 EMA, D+W)"
pBtc     = presetInput == "Bitcoin Support Band (20W SMA / 21W EMA)"

en1 = manual ? en1In : pClassic or pRibbon or pGolden or pScalp or pSwing or pMtf or pBtc
en2 = manual ? en2In : pClassic or pRibbon or pGolden or pScalp or pSwing or pMtf or pBtc
en3 = manual ? en3In : pClassic or pRibbon or pSwing or pMtf
en4 = manual ? en4In : pRibbon or pMtf
en5 = manual ? en5In : pRibbon

tp1 = manual ? tp1In : pClassic or pGolden or pBtc ? "SMA" : "EMA"
tp2 = manual ? tp2In : pClassic or pGolden ? "SMA" : "EMA"
tp3 = manual ? tp3In : pClassic ? "SMA" : "EMA"
tp4 = manual ? tp4In : "EMA"
tp5 = manual ? tp5In : "EMA"

ln1 = manual ? ln1In : pClassic or pBtc ? 20 : pRibbon ? 8 : pGolden ? 50 : pScalp ? 9 : pSwing ? 10 : 21
ln2 = manual ? ln2In : pClassic ? 50 : pRibbon ? 13 : pGolden ? 200 : pScalp or pBtc ? 21 : pSwing ? 20 : 50
ln3 = manual ? ln3In : pClassic ? 200 : pRibbon ? 21 : pSwing ? 50 : 21
ln4 = manual ? ln4In : pRibbon ? 34 : 50
ln5 = manual ? ln5In : 55

tf1 = manual ? tf1In : pMtf ? "D" : pBtc ? "W" : ""
tf2 = manual ? tf2In : pMtf ? "D" : pBtc ? "W" : ""
tf3 = manual ? tf3In : pMtf ? "W" : ""
tf4 = manual ? tf4In : pMtf ? "W" : ""
tf5 = manual ? tf5In : ""

// ═══════════════ MA CALCULATION ═══════════════
calcMA(float _src, simple int _len, simple string _type) =>
    switch _type
        "SMA"  => ta.sma(_src, _len)
        "EMA"  => ta.ema(_src, _len)
        "WMA"  => ta.wma(_src, _len)
        "VWMA" => ta.vwma(_src, _len)
        "HMA"  => ta.hma(_src, _len)
        "RMA"  => ta.rma(_src, _len)

// Higher-timeframe values are requested WITHOUT lookahead and confirmed on
// bar close of the higher timeframe, so historical and realtime behaviour match
// (no repainting, per TradingView's non-repainting HTF pattern).
getMA(bool _en, simple string _tf, simple int _len, simple string _type) =>
    if not _en
        float(na)
    else if _tf == "" or _tf == timeframe.period
        calcMA(srcInput, _len, _type)
    else
        request.security(syminfo.tickerid, _tf, calcMA(srcInput, _len, _type)[barstate.isrealtime ? 1 : 0], lookahead = barmerge.lookahead_off)

ma1 = getMA(en1, tf1, ln1, tp1)
ma2 = getMA(en2, tf2, ln2, tp2)
ma3 = getMA(en3, tf3, ln3, tp3)
ma4 = getMA(en4, tf4, ln4, tp4)
ma5 = getMA(en5, tf5, ln5, tp5)

// ═══════════════ TREND BACKGROUND ═══════════════
// Fastest (first enabled) MA vs every slower enabled MA; the fast slot itself is excluded.
fastIdx = not na(ma1) ? 1 : not na(ma2) ? 2 : not na(ma3) ? 3 : not na(ma4) ? 4 : not na(ma5) ? 5 : 0
fastMA = fastIdx == 1 ? ma1 : fastIdx == 2 ? ma2 : fastIdx == 3 ? ma3 : fastIdx == 4 ? ma4 : fastIdx == 5 ? ma5 : na
above2 = fastIdx >= 2 or na(ma2) or fastMA > ma2
above3 = fastIdx >= 3 or na(ma3) or fastMA > ma3
above4 = fastIdx >= 4 or na(ma4) or fastMA > ma4
above5 = fastIdx >= 5 or na(ma5) or fastMA > ma5
below2 = fastIdx >= 2 or na(ma2) or fastMA < ma2
below3 = fastIdx >= 3 or na(ma3) or fastMA < ma3
below4 = fastIdx >= 4 or na(ma4) or fastMA < ma4
below5 = fastIdx >= 5 or na(ma5) or fastMA < ma5
aboveAll = above2 and above3 and above4 and above5
belowAll = below2 and below3 and below4 and below5
slowCount = (fastIdx < 2 and not na(ma2) ? 1 : 0) + (fastIdx < 3 and not na(ma3) ? 1 : 0) + (fastIdx < 4 and not na(ma4) ? 1 : 0) + (fastIdx < 5 and not na(ma5) ? 1 : 0)
bgCol = not showBg or na(fastMA) or slowCount == 0 ? na : aboveAll ? color.new(color.green, 92) : belowAll ? color.new(color.red, 92) : color.new(color.yellow, 94)
bgcolor(bgCol, title = "Trend background")

// ═══════════════ PLOTS ═══════════════
p1 = plot(ma1, title = "MA 1", color = cl1, linewidth = lineW, offset = of1In)
p2 = plot(ma2, title = "MA 2", color = cl2, linewidth = lineW, offset = of2In)
p3 = plot(ma3, title = "MA 3", color = cl3, linewidth = lineW, offset = of3In)
p4 = plot(ma4, title = "MA 4", color = cl4, linewidth = lineW, offset = of4In)
p5 = plot(ma5, title = "MA 5", color = cl5, linewidth = lineW, offset = of5In)

// ═══════════════ FILLS (adjacent enabled pairs) ═══════════════
fillCol(float a, float b) => showFills and not na(a) and not na(b) ? (a > b ? color.new(color.lime, 85) : color.new(color.orange, 85)) : na
fill(p1, p2, title = "Fill MA1-MA2", color = fillCol(ma1, ma2))
fill(p2, p3, title = "Fill MA2-MA3", color = fillCol(ma2, ma3))
fill(p3, p4, title = "Fill MA3-MA4", color = fillCol(ma3, ma4))
fill(p4, p5, title = "Fill MA4-MA5", color = fillCol(ma4, ma5))

// ═══════════════ SLOPE PROJECTIONS ═══════════════
// One persistent line per MA, updated in place on the last bar (no accumulation).
// Projection inherits the MA's own color, so line and projection always match.
var line pr1 = na
var line pr2 = na
var line pr3 = na
var line pr4 = na
var line pr5 = na

drawProj(line _ln, float _ma, int _offset, color _col) =>
    line result = _ln
    if barstate.islast and showProj and not na(_ma) and not na(_ma[1])
        slope = _ma - _ma[1]
        x1 = bar_index + _offset
        if na(result)
            result := line.new(x1, _ma, x1 + projLen, _ma + slope * projLen, color = color.new(_col, 40), style = line.style_dotted, width = lineW)
        else
            line.set_xy1(result, x1, _ma)
            line.set_xy2(result, x1 + projLen, _ma + slope * projLen)
            line.set_color(result, color.new(_col, 40))
    else if not na(result) and (not showProj or na(_ma))
        line.delete(result)
        result := na
    result

pr1 := drawProj(pr1, ma1, of1In, cl1)
pr2 := drawProj(pr2, ma2, of2In, cl2)
pr3 := drawProj(pr3, ma3, of3In, cl3)
pr4 := drawProj(pr4, ma4, of4In, cl4)
pr5 := drawProj(pr5, ma5, of5In, cl5)
````
