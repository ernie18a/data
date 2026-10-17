# RSI Predictive Divergence

- url: https://www.tradingview.com/script/1FJootmt-RSI-Predictive-Divergence/
- type: indicator
- pine_id: PUB;cc16681473c248b69c969ebc4d8d4b1c
- version: 1.0

## Description

RSI Predictive Divergence — Forming Divergence Detector

OVERVIEW
This indicator detects RSI divergences in two stages: a forming stage (early warning) and a confirmed stage (classic pivot-based). The forming stage is the unique component — it uses linear regression slope analysis to identify divergence conditions building up in real time, before a pivot is confirmed.

HOW IT WORKS

1. Slope Calculation
The indicator computes linear regression slopes for both RSI and price over a user-defined lookback period (default 5 bars). The price slope is ATR-normalized so that the comparison works consistently across different instruments and timeframes.

2. Slope Angles
Both slopes are converted to angles in degrees using the arctangent function. This gives a normalized way to compare RSI direction against price direction.

3. Opposition Counter
A counter tracks how many consecutive closed bars show opposing slopes (price down + RSI up = potential bullish divergence; price up + RSI down = potential bearish divergence). When the counter reaches the user-defined threshold (default 5 bars), a forming divergence is flagged.

4. Strength Score (0-100)
A composite score is calculated using three factors:
- Angle difference between RSI and price slopes (50% weight)
- Duration of slope opposition (30% weight)
- RSI zone context — oversold/overbought adds weight (20% weight)
Users can set a minimum strength threshold to filter low-quality signals.

5. Confirmed Divergence
Classic pivot-based divergence detection runs in parallel using RSI pivot highs and lows compared against price pivots. An anti-overlap gate prevents same-type labels from clustering too closely (default 8 bars minimum spacing).

NON-REPAINTING DESIGN
- All slope counters update only on confirmed bars (barstate.isconfirmed)
- Forming signals trigger only after bar close
- Confirmed divergence labels are drawn at the pivot bar, naturally 
  lagging by the pivot lookback period
- No lookahead_on, no future data access

INPUTS
- RSI Length, Source, Overbought/Oversold levels
- Slope lookback bars and minimum opposite-slope bars
- Minimum strength threshold for forming signals
- Pivot lookback for confirmed divergence
- Anti-overlap spacing between confirmed labels
- Label style: Compact, Icon Only, or Full
- Dashboard position, size, and compact/full mode
- Color customization for bullish, bearish, forming, and neutral states

DASHBOARD
A status table shows RSI value, RSI zone, slope angle difference, and live forming-divergence status with strength meters for both directions. Two display modes: Compact (7 rows) for minimal footprint or Full (10 rows) with detailed slope angles.

ALERTS
Four alert conditions available:
- Forming Bullish Divergence
- Forming Bearish Divergence
- Confirmed Bullish Divergence
- Confirmed Bearish Divergence

HOW TO USE
Forming divergences are early-warning signals — they indicate that divergence conditions are building. Wait for higher strength readings (60+) before acting, and combine with price-action context such as support/resistance, trend, and volume. Confirmed divergences provide 
classical pivot-based signals after pivot formation. This indicator works across all timeframes.

NOTES
This is a technical analysis tool intended for educational and informational purposes. Past performance of any divergence signal does not guarantee future results. Always apply proper risk management and combine with your own trading methodology.

CREDITS
Original implementation. Uses standard RSI and pivot logic from TradingView's built-in functions combined with original slope-angle analysis methodology.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © darshakssc
// 🐘 RSI Predictive Divergence — Forming Divergence Detector  v1.1
// v1.1 changes: compact labels, anti-overlap logic, fixed dashboard height

//@version=6
indicator("RSI Predictive Divergence", shorttitle="RSI Pred Div", overlay=false, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════
// ▓▓▓  INPUTS  ▓▓▓
// ═══════════════════════════════════════════════════════════════

grpRSI = "━━━ RSI Settings ━━━"
rsiLen      = input.int(14,    "RSI Length",              minval=2,  group=grpRSI)
rsiSrc      = input.source(close, "RSI Source",                       group=grpRSI)
obLevel     = input.int(70,    "Overbought Level",        minval=50, maxval=95, group=grpRSI)
osLevel     = input.int(30,    "Oversold Level",          minval=5,  maxval=50, group=grpRSI)

grpSlope = "━━━ Predictive Slope Engine ━━━"
slopeLen    = input.int(5,     "Slope Lookback (bars)",   minval=3,  maxval=20, group=grpSlope, tooltip="Linear regression length used to measure RSI vs Price slope angles")
minBarsForm = input.int(5,     "Min Bars of Opposite Slope", minval=3, maxval=15, group=grpSlope, tooltip="Minimum consecutive bars where RSI and Price slopes must oppose each other")
minStrength = input.int(40,    "Min Strength to Alert (0-100)", minval=10, maxval=90, group=grpSlope)

grpConf = "━━━ Confirmed Divergence (Classic) ━━━"
pivotLen    = input.int(5,     "Pivot Lookback",          minval=2,  maxval=20, group=grpConf, tooltip="Bars left/right for pivot confirmation")
showConf    = input.bool(true, "Show Confirmed Divergence", group=grpConf)
minBarsBetween = input.int(8,  "Min Bars Between Same-Type Confirmed Labels", minval=3, maxval=30, group=grpConf, tooltip="Prevents overlapping labels for closely-spaced confirmed divergences")

grpVis = "━━━ Visuals ━━━"
showForming = input.bool(true, "Show Forming Divergence Labels", group=grpVis)
showLines   = input.bool(true, "Draw Live Divergence Lines",     group=grpVis)
labelStyle  = input.string("Compact", "Label Style",
                 options=["Compact","Icon Only","Full"], group=grpVis, tooltip="Compact = small text, Icon Only = just symbol, Full = original verbose")
showDash    = input.bool(true, "Show Dashboard",                 group=grpVis)
dashPos     = input.string("Top Right", "Dashboard Position",
                 options=["Top Right","Top Left","Middle Right","Bottom Right","Bottom Left"], group=grpVis)
dashSize    = input.string("Small", "Dashboard Size",
                 options=["Tiny","Small","Normal","Large"], group=grpVis)
dashCompact = input.bool(true, "Compact Dashboard (fewer rows)", group=grpVis, tooltip="Hides slope angle details for more vertical room")

grpColor = "━━━ Colors ━━━"
bullCol  = input.color(color.new(#00e676, 0),  "Bullish Color",  group=grpColor)
bearCol  = input.color(color.new(#ff1744, 0),  "Bearish Color",  group=grpColor)
formCol  = input.color(color.new(#ffeb3b, 0),  "Forming Color",  group=grpColor)
neutCol  = input.color(color.new(#90a4ae, 0),  "Neutral Color",  group=grpColor)

grpAlert = "━━━ Alerts ━━━"
alertForm = input.bool(true, "Alert on Forming Divergence",    group=grpAlert)
alertConf = input.bool(true, "Alert on Confirmed Divergence",  group=grpAlert)

// ═══════════════════════════════════════════════════════════════
// ▓▓▓  CORE CALCULATIONS  ▓▓▓
// ═══════════════════════════════════════════════════════════════

rsi = ta.rsi(rsiSrc, rsiLen)

rsiLR_now   = ta.linreg(rsi,    slopeLen, 0)
rsiLR_prev  = ta.linreg(rsi,    slopeLen, slopeLen - 1)
priceLR_now  = ta.linreg(close, slopeLen, 0)
priceLR_prev = ta.linreg(close, slopeLen, slopeLen - 1)

rsiSlope   = (rsiLR_now   - rsiLR_prev)   / slopeLen
priceSlope = (priceLR_now - priceLR_prev) / slopeLen

atrNorm     = ta.atr(14)
priceSlopeN = atrNorm > 0 ? priceSlope / atrNorm : 0
rsiSlopeN   = rsiSlope / 100.0

rsiAngle   = math.todegrees(math.atan(rsiSlopeN))
priceAngle = math.todegrees(math.atan(priceSlopeN))

var int oppCountBull = 0
var int oppCountBear = 0

bullSlopeOpp = priceSlope < 0 and rsiSlope > 0
bearSlopeOpp = priceSlope > 0 and rsiSlope < 0

if barstate.isconfirmed
    oppCountBull := bullSlopeOpp ? oppCountBull + 1 : 0
    oppCountBear := bearSlopeOpp ? oppCountBear + 1 : 0

angleDiff = math.abs(rsiAngle - priceAngle)
durFactor_b = math.min(oppCountBull / 10.0, 1.0)
durFactor_s = math.min(oppCountBear / 10.0, 1.0)
zoneFactor_b = rsi < osLevel ? 1.0 : rsi < 45 ? 0.7 : 0.4
zoneFactor_s = rsi > obLevel ? 1.0 : rsi > 55 ? 0.7 : 0.4

bullStrength = math.round(math.min(100, (angleDiff / 90.0) * 50 + durFactor_b * 30 + zoneFactor_b * 20))
bearStrength = math.round(math.min(100, (angleDiff / 90.0) * 50 + durFactor_s * 30 + zoneFactor_s * 20))

formingBull = barstate.isconfirmed and oppCountBull == minBarsForm and bullStrength >= minStrength
formingBear = barstate.isconfirmed and oppCountBear == minBarsForm and bearStrength >= minStrength

// ═══════════════════════════════════════════════════════════════
// ▓▓▓  CLASSIC CONFIRMED DIVERGENCE (Pivot-based)  ▓▓▓
// ═══════════════════════════════════════════════════════════════

plFound = not na(ta.pivotlow(rsi, pivotLen, pivotLen))
phFound = not na(ta.pivothigh(rsi, pivotLen, pivotLen))

var float prevRsiPL   = na
var float prevPricePL = na
var int   prevBarPL   = na
var float prevRsiPH   = na
var float prevPricePH = na
var int   prevBarPH   = na

// Anti-overlap: track last label bar for each type
var int lastBullConfBar = na
var int lastBearConfBar = na

confirmedBull = false
confirmedBear = false

if plFound
    curRsiPL   = rsi[pivotLen]
    curPricePL = low[pivotLen]
    if not na(prevRsiPL) and bar_index - prevBarPL <= 50 and bar_index - prevBarPL >= pivotLen
        if curPricePL < prevPricePL and curRsiPL > prevRsiPL
            confirmedBull := true
    prevRsiPL   := curRsiPL
    prevPricePL := curPricePL
    prevBarPL   := bar_index

if phFound
    curRsiPH   = rsi[pivotLen]
    curPricePH = high[pivotLen]
    if not na(prevRsiPH) and bar_index - prevBarPH <= 50 and bar_index - prevBarPH >= pivotLen
        if curPricePH > prevPricePH and curRsiPH < prevRsiPH
            confirmedBear := true
    prevRsiPH   := curRsiPH
    prevPricePH := curPricePH
    prevBarPH   := bar_index

// Anti-overlap gate
canDrawBullConf = confirmedBull and (na(lastBullConfBar) or bar_index - lastBullConfBar >= minBarsBetween)
canDrawBearConf = confirmedBear and (na(lastBearConfBar) or bar_index - lastBearConfBar >= minBarsBetween)

if canDrawBullConf
    lastBullConfBar := bar_index
if canDrawBearConf
    lastBearConfBar := bar_index

// ═══════════════════════════════════════════════════════════════
// ▓▓▓  LABEL TEXT BUILDERS  ▓▓▓
// ═══════════════════════════════════════════════════════════════

formBullTxt = labelStyle == "Icon Only" ? "▲" : labelStyle == "Compact" ? "▲ " + str.tostring(bullStrength) : "▲ Forming Bull Div\nStr: " + str.tostring(bullStrength)
formBearTxt = labelStyle == "Icon Only" ? "▼" : labelStyle == "Compact" ? "▼ " + str.tostring(bearStrength) : "▼ Forming Bear Div\nStr: " + str.tostring(bearStrength)
confBullTxt = labelStyle == "Icon Only" ? "🟢" : labelStyle == "Compact" ? "🟢 Bull" : "🟢 CONFIRMED\nBull Div"
confBearTxt = labelStyle == "Icon Only" ? "🔴" : labelStyle == "Compact" ? "🔴 Bear" : "🔴 CONFIRMED\nBear Div"

labelSz = labelStyle == "Full" ? size.small : size.tiny

// ═══════════════════════════════════════════════════════════════
// ▓▓▓  PLOTTING  ▓▓▓
// ═══════════════════════════════════════════════════════════════

rsiPlotCol = rsiSlope > 0 ? color.new(bullCol, 30) : color.new(bearCol, 30)
plot(rsi, "RSI", color=rsiPlotCol, linewidth=2)

hline(obLevel, "Overbought", color=color.new(bearCol, 70), linestyle=hline.style_dashed)
hline(50,      "Mid",        color=color.new(neutCol, 60), linestyle=hline.style_dotted)
hline(osLevel, "Oversold",   color=color.new(bullCol, 70), linestyle=hline.style_dashed)

bgcolor(rsi > obLevel ? color.new(bearCol, 92) : rsi < osLevel ? color.new(bullCol, 92) : na, title="OB/OS Background")

if showForming and formingBull
    label.new(bar_index, rsi - 3, formBullTxt,
         color=color.new(formCol, 10), textcolor=color.black, style=label.style_label_up, size=labelSz)
    if showLines
        line.new(bar_index - oppCountBull, rsi[oppCountBull], bar_index, rsi,
             color=color.new(bullCol, 0), width=2, style=line.style_dashed)

if showForming and formingBear
    label.new(bar_index, rsi + 3, formBearTxt,
         color=color.new(formCol, 10), textcolor=color.black, style=label.style_label_down, size=labelSz)
    if showLines
        line.new(bar_index - oppCountBear, rsi[oppCountBear], bar_index, rsi,
             color=color.new(bearCol, 0), width=2, style=line.style_dashed)

if showConf and canDrawBullConf
    label.new(bar_index - pivotLen, rsi[pivotLen] - 4, confBullTxt,
         color=color.new(bullCol, 0), textcolor=color.white, style=label.style_label_up, size=labelSz)

if showConf and canDrawBearConf
    label.new(bar_index - pivotLen, rsi[pivotLen] + 4, confBearTxt,
         color=color.new(bearCol, 0), textcolor=color.white, style=label.style_label_down, size=labelSz)

// ═══════════════════════════════════════════════════════════════
// ▓▓▓  DASHBOARD  ▓▓▓
// ═══════════════════════════════════════════════════════════════

posMap(pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        => position.top_right

sizeMap(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// Two table modes — compact (6 rows) and full (10 rows)
dashRows = dashCompact ? 7 : 10

var table dash = table.new(posMap(dashPos), 2, dashRows, bgcolor=color.new(#0a0e27, 10), border_width=1, border_color=color.new(#1e2749, 50), frame_color=color.new(#00e5ff, 40), frame_width=1)

bullStatus = formingBull ? "🟡 TRIGGER" : oppCountBull >= 3 ? "🔵 Build " + str.tostring(oppCountBull) : "⚪ Idle"
bearStatus = formingBear ? "🟡 TRIGGER" : oppCountBear >= 3 ? "🔵 Build " + str.tostring(oppCountBear) : "⚪ Idle"

rsiZone = rsi > obLevel ? "🔴 OB" : rsi < osLevel ? "🟢 OS" : rsi > 55 ? "🟠 Bull" : rsi < 45 ? "🟣 Bear" : "⚪ Neut"

bg = color.new(#1e2749, 30)
hdr = color.new(#00e5ff, 20)

if showDash and barstate.islast
    if dashCompact
        // ━━━ COMPACT MODE: 7 rows ━━━
        table.cell(dash, 0, 0, "🐘 RSI PRED DIV", bgcolor=hdr, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 0, "@darshakssc",    bgcolor=hdr, text_color=color.white, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 1, "RSI",            bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 1, str.tostring(rsi, "#.##"), bgcolor=bg, text_color=rsi > obLevel ? bearCol : rsi < osLevel ? bullCol : color.white, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 2, "Zone",           bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 2, rsiZone,          bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 3, "Angle Δ",        bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 3, str.tostring(angleDiff, "#.#") + "°", bgcolor=bg, text_color=color.new(#ffeb3b, 0), text_size=sizeMap(dashSize))

        table.cell(dash, 0, 4, "▲ Bull",         bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 4, bullStatus,       bgcolor=bg, text_color=formingBull ? formCol : oppCountBull >= 3 ? bullCol : color.gray, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 5, "▲ Str",          bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 5, str.tostring(bullStrength) + "/100", bgcolor=bg, text_color=bullStrength >= 60 ? bullCol : bullStrength >= 40 ? formCol : color.gray, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 6, "▼ Bear",         bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 6, bearStatus + " | " + str.tostring(bearStrength), bgcolor=bg, text_color=formingBear ? formCol : oppCountBear >= 3 ? bearCol : color.gray, text_size=sizeMap(dashSize))
    else
        // ━━━ FULL MODE: 10 rows ━━━
        table.cell(dash, 0, 0, "🐘 RSI PRED DIV", bgcolor=hdr, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 0, "@darshakssc",    bgcolor=hdr, text_color=color.white, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 1, "RSI Value",      bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 1, str.tostring(rsi, "#.##"), bgcolor=bg, text_color=rsi > obLevel ? bearCol : rsi < osLevel ? bullCol : color.white, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 2, "RSI Zone",       bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 2, rsiZone,          bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 3, "RSI Slope",      bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 3, str.tostring(rsiAngle, "#.##") + "°", bgcolor=bg, text_color=rsiSlope > 0 ? bullCol : bearCol, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 4, "Price Slope",    bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 4, str.tostring(priceAngle, "#.##") + "°", bgcolor=bg, text_color=priceSlope > 0 ? bullCol : bearCol, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 5, "Angle Diff",     bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 5, str.tostring(angleDiff, "#.##") + "°", bgcolor=bg, text_color=color.new(#ffeb3b, 0), text_size=sizeMap(dashSize))

        table.cell(dash, 0, 6, "▲ Bull Form",    bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 6, bullStatus,       bgcolor=bg, text_color=formingBull ? formCol : oppCountBull >= 3 ? bullCol : color.gray, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 7, "▲ Bull Str",     bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 7, str.tostring(bullStrength) + " / 100", bgcolor=bg, text_color=bullStrength >= 60 ? bullCol : bullStrength >= 40 ? formCol : color.gray, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 8, "▼ Bear Form",    bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 8, bearStatus,       bgcolor=bg, text_color=formingBear ? formCol : oppCountBear >= 3 ? bearCol : color.gray, text_size=sizeMap(dashSize))

        table.cell(dash, 0, 9, "▼ Bear Str",     bgcolor=bg, text_color=color.white, text_size=sizeMap(dashSize))
        table.cell(dash, 1, 9, str.tostring(bearStrength) + " / 100", bgcolor=bg, text_color=bearStrength >= 60 ? bearCol : bearStrength >= 40 ? formCol : color.gray, text_size=sizeMap(dashSize))

// ═══════════════════════════════════════════════════════════════
// ▓▓▓  ALERTS  ▓▓▓
// ═══════════════════════════════════════════════════════════════

if alertForm and formingBull
    alert("🟢 Forming Bullish Divergence | RSI: " + str.tostring(rsi, "#.##") + " | Strength: " + str.tostring(bullStrength), alert.freq_once_per_bar_close)

if alertForm and formingBear
    alert("🔴 Forming Bearish Divergence | RSI: " + str.tostring(rsi, "#.##") + " | Strength: " + str.tostring(bearStrength), alert.freq_once_per_bar_close)

if alertConf and canDrawBullConf
    alert("✅ CONFIRMED Bullish Divergence | RSI: " + str.tostring(rsi[pivotLen], "#.##"), alert.freq_once_per_bar_close)

if alertConf and canDrawBearConf
    alert("✅ CONFIRMED Bearish Divergence | RSI: " + str.tostring(rsi[pivotLen], "#.##"), alert.freq_once_per_bar_close)

alertcondition(formingBull,    title="Forming Bullish Divergence",   message="🟢 Forming Bullish Divergence on {{ticker}} {{interval}}")
alertcondition(formingBear,    title="Forming Bearish Divergence",   message="🔴 Forming Bearish Divergence on {{ticker}} {{interval}}")
alertcondition(canDrawBullConf,title="Confirmed Bullish Divergence", message="✅ Confirmed Bullish Divergence on {{ticker}} {{interval}}")
alertcondition(canDrawBearConf,title="Confirmed Bearish Divergence", message="✅ Confirmed Bearish Divergence on {{ticker}} {{interval}}")
````
