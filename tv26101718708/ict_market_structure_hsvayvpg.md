# ICT Market Structure

- url: https://www.tradingview.com/script/hSvaYvPg-ICT-Market-Structure/
- type: indicator
- pine_id: PUB;6a235702b3804ea5b36375368065d537
- version: 1.0

## Description

[b]OVERVIEW[/b]

ICT Market Structure maps the skeleton of a chart. It marks confirmed swing points as higher highs, higher lows, lower highs and lower lows, and draws a line where price closes through the last swing. A close through a swing in the direction of the prevailing structure is a break of structure. A close through it against the prevailing structure is a change of character. The bias those breaks leave behind is shown in a small table.


[b]HOW IT WORKS[/b]

A swing high is a bar whose high is the top of the window of a chosen number of bars on each side, and a swing low is the mirror. A swing is known only after that many bars have passed. Swings alternate between highs and lows. Each new swing high is labelled HH if it is above the previous swing high and LH if it is below, and each swing low is labelled HL or LL in the same way. The market bias starts undefined. A bar that closes above the last swing high, after closing below it on the bar before, is a bullish break. If the bias was already bullish or undefined, it is a break of structure. If the bias was bearish, it is a change of character. The bearish case is the mirror. A given swing level can only be broken once, and every break sets the bias to the direction of the break.


[image]https://www.tradingview.com/x/btnXfqJw/[/image]
[i]Swing labels and break lines on a trending chart. BOS marks continuation and CHoCH marks a break against the prevailing structure.[/i]


[b]WHAT YOU'LL SEE ON THE CHART[/b]

[list]
[*][b]Swing labels[/b] — small HH, HL, LH and LL labels on each confirmed swing, coloured by direction.
[*][b]Swing level lines[/b] — a short dotted line extending to the right of each swing point.
[*][b]BOS lines[/b] — a line from the broken swing to the bar that broke it, labelled BOS, in the colour of the direction.
[*][b]CHoCH lines[/b] — the same line in the accent colour, labelled CHoCH, when the break goes against the prevailing structure.
[*][b]Trend background and bar colour[/b] — optional shading and candle colouring by the current bias. Off by default.
[*][b]Info table[/b] — a small table with the market bias, the last high, the last low and the swing sensitivity.
[/list]

[image]https://www.tradingview.com/x/F4LDR8fV/[/image]
[i]The same chart with the trend background switched on to show the bias.[/i]


[b]BEST FOR[/b]

This indicator draws and labels price structure rather than reporting a single event type, so no market or timeframe group is singled out. It was not measured, and it reads the candles of whatever chart it is placed on.


[b]ALERTS[/b]

[list]
[*]Bullish BOS
[*]Bearish BOS
[*]Bullish CHoCH
[*]Bearish CHoCH
[*]Upward Structure Break (BOS or CHoCH)
[*]Downward Structure Break (BOS or CHoCH)
[/list]


[b]LIMITATIONS[/b]

The script reads the candles of the chart it is placed on, so results on non-standard chart types differ from results on regular candles. Swing points are known only after the chosen number of bars has passed, so swing-based items appear with that delay. It is a drawing and labelling tool, not a forecast. It is weaker in these situations:

[list]
[*]Choppy, range-bound markets, where breaks follow each other in both directions
[*]Very low swing sensitivity, which fills the chart with small swings
[*]The first bars of a chart, while no swing has been confirmed
[*]Intrabar use, since events can disappear before the bar closes
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
//  ICT Market Structure
//  v1.0.0 · 2026-10-05
//  Open source, Mozilla Public License 2.0
//
//  Measures : Market structure: confirmed swing points, breaks of structure,
//             changes of character and the bias they leave behind.
//  Not      : This is not investment advice.
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("ICT Market Structure", shorttitle="ICT MS", overlay=true, behind_chart=false, max_bars_back=300, max_lines_count=500, max_labels_count=500)
// max_bars_back=300 — Pine's own default; deepest explicit history: one bar back; the swing size is handled by ta.pivothigh / ta.pivotlow.
// max_lines_count / max_labels_count declared because this script draws line, label objects; the source declared 500 for all three.

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

i_swingLen         = input.int(5, "Swing Sensitivity", minval = 2, maxval = 50, group = G_CORE, tooltip = "Bars required on each side of a pivot for it to count as a swing. Lower values give more swings and faster events, higher values give fewer, firmer swings.")
i_showStructure    = input.bool(true, "Show Market Structure", group = G_VISUAL, tooltip = "Master switch for the structure drawings: swing labels, swing lines, BOS and CHoCH lines. Swing detection itself keeps running.")
i_showSwingPoints  = input.bool(true, "Show Swing Points", group = G_VISUAL, tooltip = "Labels each confirmed swing as HH, HL, LH or LL.")
i_showBOS          = input.bool(true, "Show BOS Lines", group = G_VISUAL, tooltip = "Draws a line and label where price closes through the last swing in the direction of the prevailing structure.")
i_showCHoCH        = input.bool(true, "Show CHoCH Lines", group = G_VISUAL, tooltip = "Draws a line and label where price closes through the last swing against the prevailing structure.")
i_structStyle      = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_VISUAL, tooltip = "Line style of the BOS and CHoCH lines.")
i_showSwingLines   = input.bool(true, "Show Swing Level Lines", group = G_VISUAL, tooltip = "Draws a horizontal line to the right from each swing point.")
i_swingLineLen     = input.int(20, "Swing Line Length (Bars)", minval = 5, maxval = 100, group = G_VISUAL, tooltip = "How many bars a swing level line extends to the right.")
i_swingLineStyle   = input.string("Dotted", "Swing Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_VISUAL, tooltip = "Line style of the swing level lines.")
i_showBiasBG       = input.bool(false, "Show Trend Background", group = G_VISUAL, tooltip = "Shades the chart background by the current market bias.")
i_showBiasCandles  = input.bool(false, "Color Bars", group = G_VISUAL, tooltip = "Colours the candles by the current market bias: bullish shades while the bias is up, bearish shades while it is down.")

i_colUp     = input.color(C_UP, "Bullish Color", group = G_VISUAL, tooltip = "Colour of upward structure: HH/HL swing labels, bullish BOS lines and the bullish bias shading.")
i_colDown   = input.color(C_DOWN, "Bearish Color", group = G_VISUAL, tooltip = "Colour of downward structure: LH/LL swing labels, bearish BOS lines and the bearish bias shading.")
i_colAccent = input.color(C_ACCENT, "Accent Color", group = G_VISUAL, tooltip = "Colour of the CHoCH lines and labels.")

i_showTable      = input.bool(true, "Show Info Table", group = G_TABLE, tooltip = "Shows the market structure summary table.")
i_tablePos       = input.string("Top Right", "Info Table Position", options = ["Top Left", "Bottom Left", "Top Right", "Bottom Right"], group = G_TABLE, tooltip = "Corner of the chart where the structure table is placed.")

// ── CALC ──────────────────────────────────────────────────────
f_getLineStyle(styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

f_getPosition(posStr) =>
    switch posStr
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right

// Swing pivots. A pivot is known i_swingLen bars after it formed.
pivotHigh    = ta.pivothigh(high, i_swingLen, i_swingLen)
pivotLow     = ta.pivotlow(low, i_swingLen, i_swingLen)
pivotHighBar = bar_index - i_swingLen
pivotLowBar  = bar_index - i_swingLen

structLineStyle = f_getLineStyle(i_structStyle)

// ── STATE / SIGNAL ────────────────────────────────────────────
// Signals are evaluated on every tick, as in the source script; they are not gated with barstate.isconfirmed.
// An intrabar event can therefore appear and disappear on the open bar. See the notes in identity.yaml.

// ── swing state ──
var float s_lastSwingHigh     = na
var int   s_lastSwingHighBar  = na
var float s_lastSwingLow      = na
var int   s_lastSwingLowBar   = na
var float s_prevSwingHigh     = na
var int   s_prevSwingHighBar  = na
var float s_prevSwingLow      = na
var int   s_prevSwingLowBar   = na
var string s_lastHighType     = ""    // HH or LH
var string s_lastLowType      = ""    // HL or LL
var int   s_lastSwingType     = 0     // 1 = last swing was a high, -1 = a low (swings alternate)
var label s_lastHighLabel     = na
var label s_lastLowLabel      = na
var line  s_lastHighLine      = na
var line  s_lastLowLine       = na

// Alternating swings: two highs in a row update the earlier one instead of creating a new swing.
bool swingHighConfirmed = false
bool swingLowConfirmed  = false

if not na(pivotHigh)
    if s_lastSwingType == 1
        highType = na(s_prevSwingHigh) ? "HH" : (pivotHigh > s_prevSwingHigh ? "HH" : "LH")
        s_lastSwingHigh    := pivotHigh
        s_lastSwingHighBar := pivotHighBar
        s_lastHighType     := highType
        if i_showStructure
            if not na(s_lastHighLabel)
                label.delete(s_lastHighLabel)
            if not na(s_lastHighLine)
                line.delete(s_lastHighLine)
            if i_showSwingPoints
                lblColor = highType == "HH" ? i_colUp : i_colDown
                s_lastHighLabel := label.new(pivotHighBar, pivotHigh, highType, style = label.style_label_down, color = color.new(lblColor, 70), textcolor = lblColor, size = size.tiny)
            if i_showSwingLines
                swLineColor = highType == "HH" ? i_colUp : i_colDown
                s_lastHighLine := line.new(pivotHighBar, pivotHigh, pivotHighBar + i_swingLineLen, pivotHigh, color = color.new(swLineColor, 50), style = f_getLineStyle(i_swingLineStyle), width = 1)
        swingHighConfirmed := true
    else
        highType = na(s_lastSwingHigh) ? "HH" : (pivotHigh > s_lastSwingHigh ? "HH" : "LH")
        s_prevSwingHigh    := s_lastSwingHigh
        s_prevSwingHighBar := s_lastSwingHighBar
        s_lastSwingHigh    := pivotHigh
        s_lastSwingHighBar := pivotHighBar
        s_lastHighType     := highType
        s_lastSwingType    := 1
        if i_showStructure and i_showSwingPoints
            lblColor = highType == "HH" ? i_colUp : i_colDown
            s_lastHighLabel := label.new(pivotHighBar, pivotHigh, highType, style = label.style_label_down, color = color.new(lblColor, 70), textcolor = lblColor, size = size.tiny)
        if i_showStructure and i_showSwingLines
            swLineColor = highType == "HH" ? i_colUp : i_colDown
            s_lastHighLine := line.new(pivotHighBar, pivotHigh, pivotHighBar + i_swingLineLen, pivotHigh, color = color.new(swLineColor, 50), style = f_getLineStyle(i_swingLineStyle), width = 1)
        swingHighConfirmed := true

if not na(pivotLow)
    if s_lastSwingType == -1
        lowType = na(s_prevSwingLow) ? "HL" : (pivotLow > s_prevSwingLow ? "HL" : "LL")
        s_lastSwingLow    := pivotLow
        s_lastSwingLowBar := pivotLowBar
        s_lastLowType     := lowType
        if i_showStructure
            if not na(s_lastLowLabel)
                label.delete(s_lastLowLabel)
            if not na(s_lastLowLine)
                line.delete(s_lastLowLine)
            if i_showSwingPoints
                lblColor = lowType == "HL" ? i_colUp : i_colDown
                s_lastLowLabel := label.new(pivotLowBar, pivotLow, lowType, style = label.style_label_up, color = color.new(lblColor, 70), textcolor = lblColor, size = size.tiny)
            if i_showSwingLines
                swLineColor = lowType == "HL" ? i_colUp : i_colDown
                s_lastLowLine := line.new(pivotLowBar, pivotLow, pivotLowBar + i_swingLineLen, pivotLow, color = color.new(swLineColor, 50), style = f_getLineStyle(i_swingLineStyle), width = 1)
        swingLowConfirmed := true
    else
        lowType = na(s_lastSwingLow) ? "HL" : (pivotLow > s_lastSwingLow ? "HL" : "LL")
        s_prevSwingLow    := s_lastSwingLow
        s_prevSwingLowBar := s_lastSwingLowBar
        s_lastSwingLow    := pivotLow
        s_lastSwingLowBar := pivotLowBar
        s_lastLowType     := lowType
        s_lastSwingType   := -1
        if i_showStructure and i_showSwingPoints
            lblColor = lowType == "HL" ? i_colUp : i_colDown
            s_lastLowLabel := label.new(pivotLowBar, pivotLow, lowType, style = label.style_label_up, color = color.new(lblColor, 70), textcolor = lblColor, size = size.tiny)
        if i_showStructure and i_showSwingLines
            swLineColor = lowType == "HL" ? i_colUp : i_colDown
            s_lastLowLine := line.new(pivotLowBar, pivotLow, pivotLowBar + i_swingLineLen, pivotLow, color = color.new(swLineColor, 50), style = f_getLineStyle(i_swingLineStyle), width = 1)
        swingLowConfirmed := true

// ── BOS / CHoCH ──
// Market bias: 1 bullish, -1 bearish, 0 undefined. A close through the last swing is a BOS when it
// follows the bias and a CHoCH when it goes against it. A swing level can only be broken once.
var int   s_marketBias     = 0
var bool  s_bosUp          = false
var bool  s_bosDn          = false
var bool  s_chochUp        = false
var bool  s_chochDn        = false
var float s_lastBrokenHigh = na
var float s_lastBrokenLow  = na

s_bosUp   := false
s_bosDn   := false
s_chochUp := false
s_chochDn := false

bullBreak = not na(s_lastSwingHigh) and (na(s_lastBrokenHigh) or s_lastSwingHigh != s_lastBrokenHigh) and close > s_lastSwingHigh and close[1] <= s_lastSwingHigh

if bullBreak
    if s_marketBias == 1 or s_marketBias == 0
        s_bosUp := true
        s_marketBias := 1
        if i_showStructure and i_showBOS and not na(s_lastSwingHighBar)
            line.new(s_lastSwingHighBar, s_lastSwingHigh, bar_index, s_lastSwingHigh, color = i_colUp, style = structLineStyle, width = 2)
            bosLblBar = math.round(math.avg(s_lastSwingHighBar, bar_index))
            label.new(bosLblBar, s_lastSwingHigh, "BOS", style = label.style_label_down, color = color.new(i_colUp, 80), textcolor = i_colUp, size = size.small)
    else
        s_chochUp := true
        s_marketBias := 1
        if i_showStructure and i_showCHoCH and not na(s_lastSwingHighBar)
            line.new(s_lastSwingHighBar, s_lastSwingHigh, bar_index, s_lastSwingHigh, color = i_colAccent, style = structLineStyle, width = 2)
            chochLblBar = math.round(math.avg(s_lastSwingHighBar, bar_index))
            label.new(chochLblBar, s_lastSwingHigh, "CHoCH", style = label.style_label_down, color = color.new(i_colAccent, 80), textcolor = i_colAccent, size = size.small)
    s_lastBrokenHigh := s_lastSwingHigh

bearBreak = not na(s_lastSwingLow) and (na(s_lastBrokenLow) or s_lastSwingLow != s_lastBrokenLow) and close < s_lastSwingLow and close[1] >= s_lastSwingLow and not bullBreak

if bearBreak
    if s_marketBias == -1 or s_marketBias == 0
        s_bosDn := true
        s_marketBias := -1
        if i_showStructure and i_showBOS and not na(s_lastSwingLowBar)
            line.new(s_lastSwingLowBar, s_lastSwingLow, bar_index, s_lastSwingLow, color = i_colDown, style = structLineStyle, width = 2)
            bosLblBar2 = math.round(math.avg(s_lastSwingLowBar, bar_index))
            label.new(bosLblBar2, s_lastSwingLow, "BOS", style = label.style_label_up, color = color.new(i_colDown, 80), textcolor = i_colDown, size = size.small)
    else
        s_chochDn := true
        s_marketBias := -1
        if i_showStructure and i_showCHoCH and not na(s_lastSwingLowBar)
            line.new(s_lastSwingLowBar, s_lastSwingLow, bar_index, s_lastSwingLow, color = i_colAccent, style = structLineStyle, width = 2)
            chochLblBar2 = math.round(math.avg(s_lastSwingLowBar, bar_index))
            label.new(chochLblBar2, s_lastSwingLow, "CHoCH", style = label.style_label_up, color = color.new(i_colAccent, 80), textcolor = i_colAccent, size = size.small)
    s_lastBrokenLow := s_lastSwingLow

// ── PLOT ──────────────────────────────────────────────────────
// Market bias shading and bar colouring (both off by default).
biasBgColor = i_showBiasBG ? (s_marketBias == 1 ? color.new(i_colUp, 93) : s_marketBias == -1 ? color.new(i_colDown, 93) : na) : na
bgcolor(biasBgColor, title = "Market Bias Background")

biasCandleColor = i_showBiasCandles ? (s_marketBias == 1 ? (close >= open ? i_colUp : color.new(i_colUp, 60)) : s_marketBias == -1 ? (close < open ? i_colDown : color.new(i_colDown, 60)) : na) : na
barcolor(biasCandleColor, title = "Bias Candle Color")

// ── DASHBOARD ─────────────────────────────────────────────────
// Structure info table. Strings are built on the last bar only.
if barstate.islast and i_showTable and i_showStructure
    var table s_structTable = table.new(f_getPosition(i_tablePos), 2, 4, bgcolor = C_BG, border_width = 1, border_color = C_BORDER)

    biasText  = s_marketBias == 1 ? "BULLISH" : s_marketBias == -1 ? "BEARISH" : "UNDEFINED"
    biasColor = s_marketBias == 1 ? i_colUp : s_marketBias == -1 ? i_colDown : C_NEUTRAL

    table.cell(s_structTable, 0, 0, "Market Bias", text_color = C_TEXT, text_size = size.small)
    table.cell(s_structTable, 1, 0, biasText, text_color = biasColor, text_size = size.small)

    table.cell(s_structTable, 0, 1, "Last High", text_color = C_TEXT, text_size = size.small)
    table.cell(s_structTable, 1, 1, s_lastHighType + " " + str.tostring(s_lastSwingHigh, format.mintick), text_color = s_lastHighType == "HH" ? i_colUp : i_colDown, text_size = size.small)

    table.cell(s_structTable, 0, 2, "Last Low", text_color = C_TEXT, text_size = size.small)
    table.cell(s_structTable, 1, 2, s_lastLowType + " " + str.tostring(s_lastSwingLow, format.mintick), text_color = s_lastLowType == "HL" ? i_colUp : i_colDown, text_size = size.small)

    table.cell(s_structTable, 0, 3, "Swing Sensitivity", text_color = C_TEXT, text_size = size.small)
    table.cell(s_structTable, 1, 3, str.tostring(i_swingLen), text_color = C_TEXT, text_size = size.small)

// ── ALERTS ────────────────────────────────────────────────────
alertcondition(s_bosUp, title = "Bullish BOS", message = "{{ticker}} {{interval}} - Bullish BOS: price closed above the last swing high, structure continues up.")
alertcondition(s_bosDn, title = "Bearish BOS", message = "{{ticker}} {{interval}} - Bearish BOS: price closed below the last swing low, structure continues down.")
alertcondition(s_chochUp, title = "Bullish CHoCH", message = "{{ticker}} {{interval}} - Bullish CHoCH: price closed above the last swing high against a bearish structure.")
alertcondition(s_chochDn, title = "Bearish CHoCH", message = "{{ticker}} {{interval}} - Bearish CHoCH: price closed below the last swing low against a bullish structure.")
alertcondition(s_bosUp or s_chochUp, title = "Upward Structure Break (BOS or CHoCH)", message = "{{ticker}} {{interval}} - Upward structure break detected.")
alertcondition(s_bosDn or s_chochDn, title = "Downward Structure Break (BOS or CHoCH)", message = "{{ticker}} {{interval}} - Downward structure break detected.")
````
