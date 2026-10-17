# ICT Fair Value Gap [vole]

- url: https://www.tradingview.com/script/qjV8ocww-ICT-Fair-Value-Gap-vole/
- type: indicator
- pine_id: PUB;fb33f72643734fe2b4512a7b1f2d1898
- version: 1.0

## Description

[b]OVERVIEW[/b]

ICT Fair Value Gap finds three-candle gaps, the stretch between the first candle's extreme and the third candle's opposite extreme that the middle candle left untraded. It draws each gap as a box, tracks how far price has filled it and marks the gaps that arrived together with a strong displacement candle as imbalances.


[b]HOW IT WORKS[/b]

For every bar, the indicator compares the current candle with the candle two bars back. A bullish gap exists when the current low is above the high of that earlier candle. A bearish gap exists when the current high is below the low of that earlier candle. A gap smaller than a chosen share of the average true range can be ignored. A displacement is a candle whose body is at least a chosen multiple of the average true range. A gap that comes with a displacement on its middle or third candle is called an imbalance and is labelled IMB instead of FVG. Each gap is drawn as a box extended to the right, with a dotted line at its midpoint, the consequent encroachment. As later bars trade into the gap, the share of it that has been filled is tracked, either on the wick or on the close. When the fill reaches the chosen target the gap counts as filled and is faded or removed. Gaps are tracked for a chosen number of bars.


[image]https://www.tradingview.com/x/3FKVJWnf/[/image]
[i]Gap boxes with their midpoint lines and the fill percentage on each label, on a falling chart that turns up.[/i]


[b]WHAT YOU'LL SEE ON THE CHART[/b]

[list]
[*][b]Gap boxes[/b] — a shaded box for each active gap, in the bullish or bearish colour, extended to the right.
[*][b]Gap labels[/b] — FVG, or IMB for a gap that arrived with a displacement candle, with the current fill percentage.
[*][b]CE line[/b] — a dotted line at the midpoint of each gap.
[*][b]Filled gaps[/b] — faded or removed once the fill target is reached.
[*][b]Dashboard[/b] — a small table summarising the active gaps.
[/list]

[image]https://www.tradingview.com/x/Ub3t5YdK/[/image]
[i]An hourly stock chart: gaps that price has already traded back into are faded, and open gaps stay extended to the right.[/i]


[b]BEST FOR[/b]

This indicator draws and labels price structure rather than reporting a single event type, so no market or timeframe group is singled out. It was not measured, and it reads the candles of whatever chart it is placed on.


[b]ALERTS[/b]

[list]
[*]Bullish FVG Formed
[*]Bearish FVG Formed
[*]Bullish Imbalance
[*]Bearish Imbalance
[*]FVG Filled
[*]FVG CE Touched
[/list]


[b]LIMITATIONS[/b]

The script reads the candles of the chart it is placed on, so results on non-standard chart types differ from results on regular candles. Swing points are known only after the chosen number of bars has passed, so swing-based items appear with that delay. It is a drawing and labelling tool, not a forecast. It is weaker in these situations:

[list]
[*]Quiet, overlapping candles, where few gaps form
[*]Low size filters, which fill the chart with small gaps
[*]Illiquid instruments, where gaps are common but carry little meaning
[*]Intrabar use, since a gap can disappear before the bar closes
[/list]


[b]OPEN SOURCE[/b]

The source code is open. This script is one module of the author's own larger ICT toolkit, published here on its own so it can be read, checked and reused under the Mozilla Public License 2.0.


[b]ACCESS[/b]

Free, open-source script.


[b]DISCLAIMER[/b]

[i]This indicator is a technical analysis tool, not investment advice. The author is not a registered investment adviser, broker or dealer. Nothing here is a recommendation to buy, sell or hold any instrument. What you see on the chart is the output of a calculation you configured. Any decision you take from it is yours. Past behaviour of an indicator — including anything you observe in historical bars or in a backtest, which is a simulation — does not indicate future results. Trading carries a real risk of loss, including your entire capital. Charting uses TradingView® technology. TradingView is unaffiliated with the author. For educational purposes only. Not investment advice.[/i]

## Source Code

````pine
// Split from the author's own "ICT Smart Money Toolkit" (all modules in one script).
// ═══════════════════════════════════════════════════════════════
//  ICT Fair Value Gap
//  v1.0.0 · 2026-10-05
//  Open source, Mozilla Public License 2.0
//
//  Measures : Fair value gaps between candle 1 and candle 3: how far price
//             has filled them and whether the gap arrived with a
//             displacement.
//  Not      : This is not investment advice.
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("ICT Fair Value Gap [vole]", shorttitle="ICT FVG [vole]", overlay=true, behind_chart=false, max_bars_back=300, max_lines_count=500, max_boxes_count=500, max_labels_count=500)
// max_bars_back=300 — Pine's own default; deepest explicit history: the three-candle gap (2 bars back).
// max_lines_count / max_boxes_count / max_labels_count declared because this script draws line, box, label objects; the source declared 500 for all three.

// ── THEME ─────────────────────────────────────────────────────
// [§3.1] design tokens — do not edit per-indicator.
C_UP       = #26A69A
C_DOWN     = #EF5350
C_NEUTRAL  = #787B86
C_ACCENT   = #F0B90B
C_INFO     = #2962FF
C_TEXT     = #D1D4DC
C_TEXT_DIM = #787B86
C_BG       = #131722
C_BORDER   = #2A2E39

// ── INPUTS ────────────────────────────────────────────────────
// [§4.1] Group names and their order are fixed. Unused groups are omitted.
G_CORE    = "◆━━━━━━━ Calculation ━━━━━━━◆"
G_VISUAL  = "◆━━━━━━━ Appearance ━━━━━━━◆"
G_TABLE   = "◆━━━━━━━ Dashboard ━━━━━━━◆"

i_showFVG        = input.bool(true, "Show Fair Value Gaps", group = G_CORE, tooltip = "Detects and draws three-candle gaps between candle 1 and candle 3.")
i_fvgLookback    = input.int(50, "Lookback (Bars)", minval = 10, maxval = 200, group = G_CORE, tooltip = "How many bars a gap stays tracked before it is removed.")
i_fvgMaxShow     = input.int(10, "Max Gaps", minval = 1, maxval = 30, group = G_CORE, tooltip = "Half of the active gaps kept on the chart: both sides together hold up to twice this number and the oldest are removed first.")
i_fvgMinSize     = input.float(0.0, "Min Gap Size (ATR %)", minval = 0.0, maxval = 100.0, step = 5.0, group = G_CORE, tooltip = "Gaps smaller than this percentage of ATR are ignored; 0 keeps every gap.")
i_fvgFillTarget  = input.float(100.0, "Fill Target (%)", minval = 10.0, maxval = 200.0, step = 10.0, group = G_CORE, tooltip = "How much of a gap must be filled for it to count as filled: 100 is the whole gap, 50 is the midpoint.")
i_fvgBreakMode   = input.string("Wick (High/Low)", "Fill Detection", options = ["Bar Close", "Wick (High/Low)"], group = G_CORE, tooltip = "Whether the fill is measured on the wick or on the candle close.")
i_dispMultiplier = input.float(1.5, "Displacement Multiplier (ATR)", minval = 1.0, maxval = 5.0, step = 0.1, group = G_CORE, tooltip = "Minimum candle body, in multiples of ATR, for a candle to count as a displacement.")
i_dispATRLen     = input.int(14, "ATR Length", minval = 5, maxval = 50, group = G_CORE, tooltip = "Length of the ATR used as the volatility reference.")
i_fvgFilled      = input.string("Fade", "Filled FVG", options = ["Fade", "Hide"], group = G_VISUAL, tooltip = "What happens to a gap once it reaches the fill target.")
i_showImbalance  = input.bool(true, "Show Imbalance Label", group = G_VISUAL, tooltip = "Labels gaps that arrive with a displacement candle as IMB.")
i_showFillRatio  = input.bool(true, "Show Fill Percentage", group = G_VISUAL, tooltip = "Shows the current fill percentage on each gap label.")

i_colUp     = input.color(C_UP, "Bullish Color", group = G_VISUAL, tooltip = "Colour of bullish fair value gaps.")
i_colDown   = input.color(C_DOWN, "Bearish Color", group = G_VISUAL, tooltip = "Colour of bearish fair value gaps.")

i_showTable      = input.bool(true, "Show Dashboard", group = G_TABLE, tooltip = "Shows the summary table on the chart.")
i_tablePos       = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Bottom Left", "Top Right", "Bottom Right"], group = G_TABLE, tooltip = "Corner of the chart where the dashboard is placed.")

// ── CALC ──────────────────────────────────────────────────────
f_getPosition(posStr) =>
    switch posStr
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right

atrValue = ta.atr(i_dispATRLen)

// Displacement: candle body larger than a multiple of ATR (aggressive institutional entry).
bullishDisplacement = (close - open) > (atrValue * i_dispMultiplier) and close > open
bearishDisplacement = (open - close) > (atrValue * i_dispMultiplier) and close < open

// ── STATE / SIGNAL ────────────────────────────────────────────
// Signals are evaluated on every tick, as in the source script; they are not gated with barstate.isconfirmed.
// An intrabar event can therefore appear and disappear on the open bar. See the notes in identity.yaml.

// ── fair value gaps ──
type FairValueGap
    int    startBar        // middle candle of the three
    float  top
    float  bottom
    int    direction       // 1 bullish, -1 bearish
    bool   isFilled
    bool   isImbalance     // arrived with a displacement candle
    float  midPoint        // CE (consequent encroachment)
    bool   ceTouched
    float  fillRatio       // 0.0 and up, can exceed 1.0
    float  fillMaxLevel    // deepest level price reached inside the gap
    box    fvgBox
    label  fvgLabel
    line   ceLine

var array<FairValueGap> s_activeFVGs = array.new<FairValueGap>()

// Candle 1 = two bars ago, candle 2 = one bar ago, candle 3 = current bar.
fvgBullTop    = low
fvgBullBottom = high[2]
isBullFVG     = fvgBullTop > fvgBullBottom

fvgBearTop    = low[2]
fvgBearBottom = high
isBearFVG     = fvgBearTop > fvgBearBottom

fvgBullSize = isBullFVG ? (fvgBullTop - fvgBullBottom) : 0.0
fvgBearSize = isBearFVG ? (fvgBearTop - fvgBearBottom) : 0.0
minFVGSize  = atrValue * (i_fvgMinSize / 100.0)

bullFVGValid = isBullFVG and (i_fvgMinSize == 0.0 or fvgBullSize >= minFVGSize)
bearFVGValid = isBearFVG and (i_fvgMinSize == 0.0 or fvgBearSize >= minFVGSize)

// Imbalance: a valid gap together with a displacement on the middle or the third candle.
bullIsImbalance = bullFVGValid and (bullishDisplacement[1] or bullishDisplacement)
bearIsImbalance = bearFVGValid and (bearishDisplacement[1] or bearishDisplacement)

if bullFVGValid and i_showFVG
    fvgMid = (fvgBullTop + fvgBullBottom) / 2.0

    fvgBoxRef = box.new(bar_index - 2, fvgBullTop, bar_index + 5, fvgBullBottom, bgcolor = color.new(i_colUp, 80), border_color = color.new(i_colUp, 50), border_width = 1, extend = extend.right)

    lblText = bullIsImbalance and i_showImbalance ? "IMB" : "FVG"

    fvgLabelRef = label.new(bar_index - 1, fvgBullBottom, lblText, style = label.style_label_up, color = color.new(i_colUp, 90), textcolor = i_colUp, size = size.small)

    ceLineRef = line.new(bar_index - 2, fvgMid, bar_index + 20, fvgMid, color = color.new(i_colUp, 60), style = line.style_dotted, width = 1)

    newFVG = FairValueGap.new(bar_index - 1, fvgBullTop, fvgBullBottom, 1, false, bullIsImbalance, fvgMid, false, 0.0, fvgBullTop, fvgBoxRef, fvgLabelRef, ceLineRef)
    array.push(s_activeFVGs, newFVG)

if bearFVGValid and i_showFVG
    fvgMid = (fvgBearTop + fvgBearBottom) / 2.0

    fvgBoxRef = box.new(bar_index - 2, fvgBearTop, bar_index + 5, fvgBearBottom, bgcolor = color.new(i_colDown, 80), border_color = color.new(i_colDown, 50), border_width = 1, extend = extend.right)

    lblText = bearIsImbalance and i_showImbalance ? "IMB" : "FVG"

    fvgLabelRef = label.new(bar_index - 1, fvgBearTop, lblText, style = label.style_label_down, color = color.new(i_colDown, 90), textcolor = i_colDown, size = size.small)

    ceLineRef = line.new(bar_index - 2, fvgMid, bar_index + 20, fvgMid, color = color.new(i_colDown, 60), style = line.style_dotted, width = 1)

    newFVG = FairValueGap.new(bar_index - 1, fvgBearTop, fvgBearBottom, -1, false, bearIsImbalance, fvgMid, false, 0.0, fvgBearBottom, fvgBoxRef, fvgLabelRef, ceLineRef)
    array.push(s_activeFVGs, newFVG)

// Fill tracking: partial fill, fill target reached, CE touch.
var bool s_fvgFilledBull = false
var bool s_fvgFilledBear = false
var bool s_fvgCEReaction = false

s_fvgFilledBull := false
s_fvgFilledBear := false
s_fvgCEReaction := false

if array.size(s_activeFVGs) > 0
    float fillTargetPct = i_fvgFillTarget / 100.0
    bool  fvgUseClose   = i_fvgBreakMode == "Bar Close"
    float fvgFillHi     = fvgUseClose ? close : high
    float fvgFillLo     = fvgUseClose ? close : low

    for i = array.size(s_activeFVGs) - 1 to 0
        fvg = array.get(s_activeFVGs, i)

        if bar_index - fvg.startBar > i_fvgLookback
            box.delete(fvg.fvgBox)
            label.delete(fvg.fvgLabel)
            line.delete(fvg.ceLine)
            array.remove(s_activeFVGs, i)
            continue

        if fvg.isFilled
            continue

        float fvgSize = fvg.top - fvg.bottom

        if fvg.direction == 1
            if fvgFillLo < fvg.fillMaxLevel
                fvg.fillMaxLevel := fvgFillLo
            fvg.fillRatio := fvgSize > 0 ? (fvg.top - fvg.fillMaxLevel) / fvgSize : 0.0

            // CE touch is always a wick touch.
            if not fvg.ceTouched and low <= fvg.midPoint and high >= fvg.midPoint
                fvg.ceTouched := true
                s_fvgCEReaction := true

            if i_showFillRatio and fvg.fillRatio > 0.0 and not fvg.isFilled
                string baseLbl = fvg.isImbalance and i_showImbalance ? "IMB" : "FVG"
                label.set_text(fvg.fvgLabel, baseLbl + " " + str.tostring(math.round(fvg.fillRatio * 100)) + "%")

            if fvg.fillRatio >= fillTargetPct
                fvg.isFilled := true
                s_fvgFilledBull := true

                if i_fvgFilled == "Hide"
                    box.delete(fvg.fvgBox)
                    label.delete(fvg.fvgLabel)
                    line.delete(fvg.ceLine)
                    array.remove(s_activeFVGs, i)
                    continue
                else
                    box.set_bgcolor(fvg.fvgBox, color.new(i_colUp, 92))
                    box.set_border_color(fvg.fvgBox, color.new(i_colUp, 88))
                    box.set_extend(fvg.fvgBox, extend.none)
                    box.set_right(fvg.fvgBox, bar_index)
                    label.set_text(fvg.fvgLabel, "FVG filled " + str.tostring(math.round(fvg.fillRatio * 100)) + "%")

        if fvg.direction == -1
            if fvgFillHi > fvg.fillMaxLevel
                fvg.fillMaxLevel := fvgFillHi
            fvg.fillRatio := fvgSize > 0 ? (fvg.fillMaxLevel - fvg.bottom) / fvgSize : 0.0

            if not fvg.ceTouched and high >= fvg.midPoint and low <= fvg.midPoint
                fvg.ceTouched := true
                s_fvgCEReaction := true

            if i_showFillRatio and fvg.fillRatio > 0.0 and not fvg.isFilled
                string baseLbl = fvg.isImbalance and i_showImbalance ? "IMB" : "FVG"
                label.set_text(fvg.fvgLabel, baseLbl + " " + str.tostring(math.round(fvg.fillRatio * 100)) + "%")

            if fvg.fillRatio >= fillTargetPct
                fvg.isFilled := true
                s_fvgFilledBear := true

                if i_fvgFilled == "Hide"
                    box.delete(fvg.fvgBox)
                    label.delete(fvg.fvgLabel)
                    line.delete(fvg.ceLine)
                    array.remove(s_activeFVGs, i)
                    continue
                else
                    box.set_bgcolor(fvg.fvgBox, color.new(i_colDown, 92))
                    box.set_border_color(fvg.fvgBox, color.new(i_colDown, 88))
                    box.set_extend(fvg.fvgBox, extend.none)
                    box.set_right(fvg.fvgBox, bar_index)
                    label.set_text(fvg.fvgLabel, "FVG filled " + str.tostring(math.round(fvg.fillRatio * 100)) + "%")

while array.size(s_activeFVGs) > i_fvgMaxShow * 2
    oldestFVG = array.shift(s_activeFVGs)
    box.delete(oldestFVG.fvgBox)
    label.delete(oldestFVG.fvgLabel)
    line.delete(oldestFVG.ceLine)

// ── PLOT ──────────────────────────────────────────────────────

// ── DASHBOARD ─────────────────────────────────────────────────
// Dashboard. Strings are built on the last bar only.
if barstate.islast and i_showTable
    var table s_dash = table.new(f_getPosition(i_tablePos), 3, 2, bgcolor = C_BG, border_width = 1, border_color = C_BORDER)
    table.cell(s_dash, 0, 0, "ICT Fair Value Gap", text_color = C_TEXT, text_size = size.small, bgcolor = C_BORDER)
    table.cell(s_dash, 1, 0, "", bgcolor = C_BORDER)
    table.cell(s_dash, 2, 0, timeframe.period, text_color = C_TEXT_DIM, text_size = size.small, bgcolor = C_BORDER)

    int bullFVGCount = 0
    int bearFVGCount = 0
    if array.size(s_activeFVGs) > 0
        for i = 0 to array.size(s_activeFVGs) - 1
            fvg = array.get(s_activeFVGs, i)
            if not fvg.isFilled
                if fvg.direction == 1
                    bullFVGCount += 1
                else
                    bearFVGCount += 1

    table.cell(s_dash, 0, 1, "FVG", text_color = C_TEXT, text_size = size.tiny)
    table.cell(s_dash, 1, 1, str.tostring(bullFVGCount) + " Bull", text_color = i_colUp, text_size = size.tiny)
    table.cell(s_dash, 2, 1, str.tostring(bearFVGCount) + " Bear", text_color = i_colDown, text_size = size.tiny)

// ── ALERTS ────────────────────────────────────────────────────
alertcondition(bullFVGValid, title = "Bullish FVG Formed", message = "{{ticker}} {{interval}} - Bullish FVG detected.")
alertcondition(bearFVGValid, title = "Bearish FVG Formed", message = "{{ticker}} {{interval}} - Bearish FVG detected.")
alertcondition(bullIsImbalance, title = "Bullish Imbalance", message = "{{ticker}} {{interval}} - Bullish imbalance: displacement and FVG together.")
alertcondition(bearIsImbalance, title = "Bearish Imbalance", message = "{{ticker}} {{interval}} - Bearish imbalance: displacement and FVG together.")
alertcondition(s_fvgFilledBull or s_fvgFilledBear, title = "FVG Filled", message = "{{ticker}} {{interval}} - A fair value gap reached its fill target.")
alertcondition(s_fvgCEReaction, title = "FVG CE Touched", message = "{{ticker}} {{interval}} - Price touched the CE (midpoint) of a fair value gap.")
````
