# ICT Swing Failure Pattern [vole]

- url: https://www.tradingview.com/script/WIAvLTZi-ICT-Swing-Failure-Pattern-vole/
- type: indicator
- pine_id: PUB;6d7b0aab3ead4f0b98ee73c8d2f4c3c9
- version: 1.0

## Description

[b]OVERVIEW[/b]

ICT Swing Failure Pattern marks the bar on which a wick goes through the latest swing high or swing low and the candle closes back inside it. The break did not hold. By default only patterns against the current market bias are shown: a bearish pattern in a bullish market and a bullish pattern in a bearish market.


[b]HOW IT WORKS[/b]

The indicator finds swings and tracks a market bias from breaks of structure. On every bar it compares the high and low with the latest swing high and swing low. A bearish pattern is a bar whose high goes above the latest swing high while its close stays below that swing high, with the upper wick taking at least a chosen share of the candle's range. A bullish pattern is the mirror at the swing low. With the default trend filter, a bearish pattern is shown only while the bias is bullish, and a bullish pattern only while the bias is bearish. A horizontal line at the swing level extends to the right of each pattern, and a limited number of markers are kept on the chart.


[image]https://www.tradingview.com/x/NbAZALWK/[/image]
[i]Bullish and bearish patterns on a 15-minute chart. Each dashed line marks the swing level that failed.[/i]


[b]WHAT YOU'LL SEE ON THE CHART[/b]

[list]
[*][b]SFP markers[/b] — a label on the bar of the pattern, below the bar for a bullish pattern and above the bar for a bearish pattern.
[*][b]SFP level line[/b] — a short horizontal line at the swing level the pattern formed on.
[*][b]Dashboard[/b] — a small table showing whether a pattern fired on the latest bar.
[/list]

[image]https://www.tradingview.com/x/jaez4zpA/[/image]
[i]A bearish pattern on a 30-minute chart: a bar wicks above the latest swing high and closes back below it.[/i]


[b]BEST FOR[/b]

This indicator draws and labels price structure rather than reporting a single event type, so no market or timeframe group is singled out. It was not measured, and it reads the candles of whatever chart it is placed on.


[b]ALERTS[/b]

[list]
[*]Bullish SFP
[*]Bearish SFP
[*]Any SFP
[/list]


[b]LIMITATIONS[/b]

The script reads the candles of the chart it is placed on, so results on non-standard chart types differ from results on regular candles. Swing points are known only after the chosen number of bars has passed, so swing-based items appear with that delay. It is a drawing and labelling tool, not a forecast. It is weaker in these situations:

[list]
[*]Strong trends, where swing levels are broken for good
[*]Choppy markets, where small swings are probed constantly
[*]Early in a chart, before swings and bias are established
[*]Intrabar use, since a marker can disappear before the bar closes
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
//  ICT Swing Failure Pattern
//  v1.0.0 · 2026-10-05
//  Open source, Mozilla Public License 2.0
//
//  Measures : Swing failure patterns: a wick through the last swing that
//             closes back inside it.
//  Not      : This is not investment advice.
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("ICT Swing Failure Pattern [vole]", shorttitle="ICT SFP [vole]", overlay=true, behind_chart=false, max_bars_back=300, max_lines_count=500, max_labels_count=500)
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
G_FILTER  = "◆━━━━━━━ Filters ━━━━━━━◆"
G_VISUAL  = "◆━━━━━━━ Appearance ━━━━━━━◆"
G_TABLE   = "◆━━━━━━━ Dashboard ━━━━━━━◆"

i_showSFP        = input.bool(true, "Show SFP", group = G_CORE, tooltip = "Detects and marks swing failure patterns: a wick through the last swing that closes back inside it.")
i_sfpLookback    = input.int(50, "Lookback (Bars)", minval = 10, maxval = 200, group = G_CORE, tooltip = "How many bars back to look for the swing high or low.")
i_sfpWickMin     = input.float(0.3, "Min Wick Ratio", minval = 0.1, maxval = 0.9, step = 0.05, group = G_CORE, tooltip = "Minimum share of the candle range taken by the rejecting wick. Higher values keep cleaner patterns, lower values give more of them.")
i_swingLen       = input.int(5, "Swing Sensitivity", minval = 2, maxval = 50, group = G_CORE, tooltip = "Bars required on each side of a pivot for it to count as a swing. Only the structure used by this indicator reads it.")
i_sfpFilterBOS   = input.bool(true, "Use BOS Filter (Invalid MSB)", group = G_FILTER, tooltip = "Skips a pattern when a real BOS formed on the same bar, because that is a valid break and not a trap.")
i_sfpTrendFilter = input.string("Reversals Only", "Trend Filter", options = ["Reversals Only", "Show All"], group = G_FILTER, tooltip = "Reversals Only shows a pattern only against the current bias: bearish SFP in a bullish market, bullish SFP in a bearish market. Show All shows every pattern.")
i_sfpShowLine    = input.bool(true, "Show SFP Level Line", group = G_VISUAL, tooltip = "Draws a horizontal line at the swing level the pattern formed on.")
i_sfpLineLen     = input.int(15, "Line Length (Bars)", minval = 5, maxval = 50, group = G_VISUAL, tooltip = "How many bars the SFP level line extends to the right.")
i_sfpMaxShow     = input.int(5, "Max SFP Markers", minval = 1, maxval = 20, group = G_VISUAL, tooltip = "Most SFP labels on the chart at once; older ones are deleted.")

i_colUp     = input.color(C_UP, "Bullish Color", group = G_VISUAL, tooltip = "Colour of bullish swing failure patterns.")
i_colDown   = input.color(C_DOWN, "Bearish Color", group = G_VISUAL, tooltip = "Colour of bearish swing failure patterns.")

i_showTable      = input.bool(true, "Show Dashboard", group = G_TABLE, tooltip = "Shows the summary table on the chart.")
i_tablePos       = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Bottom Left", "Top Right", "Bottom Right"], group = G_TABLE, tooltip = "Corner of the chart where the dashboard is placed.")

// ── CALC ──────────────────────────────────────────────────────
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

// Alternating swings: two highs in a row update the earlier one instead of creating a new swing.
bool swingHighConfirmed = false
bool swingLowConfirmed  = false

if not na(pivotHigh)
    if s_lastSwingType == 1
        highType = na(s_prevSwingHigh) ? "HH" : (pivotHigh > s_prevSwingHigh ? "HH" : "LH")
        s_lastSwingHigh    := pivotHigh
        s_lastSwingHighBar := pivotHighBar
        s_lastHighType     := highType
        swingHighConfirmed := true
    else
        highType = na(s_lastSwingHigh) ? "HH" : (pivotHigh > s_lastSwingHigh ? "HH" : "LH")
        s_prevSwingHigh    := s_lastSwingHigh
        s_prevSwingHighBar := s_lastSwingHighBar
        s_lastSwingHigh    := pivotHigh
        s_lastSwingHighBar := pivotHighBar
        s_lastHighType     := highType
        s_lastSwingType    := 1
        swingHighConfirmed := true

if not na(pivotLow)
    if s_lastSwingType == -1
        lowType = na(s_prevSwingLow) ? "HL" : (pivotLow > s_prevSwingLow ? "HL" : "LL")
        s_lastSwingLow    := pivotLow
        s_lastSwingLowBar := pivotLowBar
        s_lastLowType     := lowType
        swingLowConfirmed := true
    else
        lowType = na(s_lastSwingLow) ? "HL" : (pivotLow > s_lastSwingLow ? "HL" : "LL")
        s_prevSwingLow    := s_lastSwingLow
        s_prevSwingLowBar := s_lastSwingLowBar
        s_lastSwingLow    := pivotLow
        s_lastSwingLowBar := pivotLowBar
        s_lastLowType     := lowType
        s_lastSwingType   := -1
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
    else
        s_chochUp := true
        s_marketBias := 1
    s_lastBrokenHigh := s_lastSwingHigh

bearBreak = not na(s_lastSwingLow) and (na(s_lastBrokenLow) or s_lastSwingLow != s_lastBrokenLow) and close < s_lastSwingLow and close[1] >= s_lastSwingLow and not bullBreak

if bearBreak
    if s_marketBias == -1 or s_marketBias == 0
        s_bosDn := true
        s_marketBias := -1
    else
        s_chochDn := true
        s_marketBias := -1
    s_lastBrokenLow := s_lastSwingLow

// ── swing failure pattern ──
var bool s_sfpBullSignal = false
var bool s_sfpBearSignal = false
s_sfpBullSignal := false
s_sfpBearSignal := false

var float s_sfpLastHighLevel = na   // swing high that already produced a bearish SFP
var float s_sfpLastLowLevel  = na   // swing low that already produced a bullish SFP

var array<label> s_sfpLabels = array.new<label>()
var array<line>  s_sfpLines  = array.new<line>()

// A swing level that any candle has closed through is never used for an SFP again; reset when a new swing replaces it.
var bool s_swingHighBroken = false
var bool s_swingLowBroken  = false

if not na(s_lastSwingHigh) and (na(s_lastSwingHigh[1]) or s_lastSwingHigh != s_lastSwingHigh[1])
    s_swingHighBroken := false
if not na(s_lastSwingLow) and (na(s_lastSwingLow[1]) or s_lastSwingLow != s_lastSwingLow[1])
    s_swingLowBroken := false

if not na(s_lastSwingHigh) and close > s_lastSwingHigh
    s_swingHighBroken := true
if not na(s_lastSwingLow) and close < s_lastSwingLow
    s_swingLowBroken := true

if i_showSFP
    candleRange  = high - low
    sfpUpperWick = high - math.max(open, close)
    sfpLowerWick = math.min(open, close) - low

    bool bearSFPTrendOK = i_sfpTrendFilter == "Show All" or s_marketBias == 1
    bool bullSFPTrendOK = i_sfpTrendFilter == "Show All" or s_marketBias == -1

    // Bearish SFP: wick above the swing high, close back below it.
    if not na(s_lastSwingHigh) and candleRange > 0 and bearSFPTrendOK
        alreadyFiredHigh = not na(s_sfpLastHighLevel) and s_sfpLastHighLevel == s_lastSwingHigh

        if not alreadyFiredHigh and not s_swingHighBroken
            sweptHigh = high > s_lastSwingHigh
            closedBelow = close < s_lastSwingHigh
            wickRatioOK = (sfpUpperWick / candleRange) >= i_sfpWickMin
            bosFilter = i_sfpFilterBOS ? not s_bosUp : true

            if sweptHigh and closedBelow and wickRatioOK and bosFilter
                s_sfpBearSignal := true
                s_sfpLastHighLevel := s_lastSwingHigh

                sfpLbl = label.new(bar_index + 2, s_lastSwingHigh, "SFP", style = label.style_label_down, color = color.new(i_colDown, 70), textcolor = i_colDown, size = size.small, tooltip = "Bearish SFP\nSwing High: " + str.tostring(s_lastSwingHigh, format.mintick) + "\nHigh: " + str.tostring(high, format.mintick) + "\nClose: " + str.tostring(close, format.mintick) + "\nThe wick crossed the swing but the close stayed below it: failed break.")
                array.push(s_sfpLabels, sfpLbl)

                if i_sfpShowLine
                    sfpLn = line.new(bar_index, s_lastSwingHigh, bar_index + i_sfpLineLen, s_lastSwingHigh, color = i_colDown, style = line.style_dashed, width = 1)
                    array.push(s_sfpLines, sfpLn)

    // Bullish SFP: wick below the swing low, close back above it.
    if not na(s_lastSwingLow) and candleRange > 0 and bullSFPTrendOK
        alreadyFiredLow = not na(s_sfpLastLowLevel) and s_sfpLastLowLevel == s_lastSwingLow

        if not alreadyFiredLow and not s_swingLowBroken
            sweptLow = low < s_lastSwingLow
            closedAbove = close > s_lastSwingLow
            wickRatioOK = (sfpLowerWick / candleRange) >= i_sfpWickMin
            bosFilter = i_sfpFilterBOS ? not s_bosDn : true

            if sweptLow and closedAbove and wickRatioOK and bosFilter
                s_sfpBullSignal := true
                s_sfpLastLowLevel := s_lastSwingLow

                sfpLbl = label.new(bar_index + 2, s_lastSwingLow, "SFP", style = label.style_label_up, color = color.new(i_colUp, 70), textcolor = i_colUp, size = size.small, tooltip = "Bullish SFP\nSwing Low: " + str.tostring(s_lastSwingLow, format.mintick) + "\nLow: " + str.tostring(low, format.mintick) + "\nClose: " + str.tostring(close, format.mintick) + "\nThe wick crossed the swing but the close stayed above it: failed break.")
                array.push(s_sfpLabels, sfpLbl)

                if i_sfpShowLine
                    sfpLn = line.new(bar_index, s_lastSwingLow, bar_index + i_sfpLineLen, s_lastSwingLow, color = i_colUp, style = line.style_dashed, width = 1)
                    array.push(s_sfpLines, sfpLn)

while array.size(s_sfpLabels) > i_sfpMaxShow
    label.delete(array.shift(s_sfpLabels))

while array.size(s_sfpLines) > i_sfpMaxShow
    line.delete(array.shift(s_sfpLines))

// ── PLOT ──────────────────────────────────────────────────────

// ── DASHBOARD ─────────────────────────────────────────────────
// Dashboard. Strings are built on the last bar only.
if barstate.islast and i_showTable
    var table s_dash = table.new(f_getPosition(i_tablePos), 3, 2, bgcolor = C_BG, border_width = 1, border_color = C_BORDER)
    table.cell(s_dash, 0, 0, "ICT Swing Failure Pattern", text_color = C_TEXT, text_size = size.small, bgcolor = C_BORDER)
    table.cell(s_dash, 1, 0, "", bgcolor = C_BORDER)
    table.cell(s_dash, 2, 0, timeframe.period, text_color = C_TEXT_DIM, text_size = size.small, bgcolor = C_BORDER)

    string sfpText = s_sfpBullSignal ? "BULL SFP" : s_sfpBearSignal ? "BEAR SFP" : "—"
    color  sfpClr  = s_sfpBullSignal ? i_colUp : s_sfpBearSignal ? i_colDown : C_NEUTRAL
    table.cell(s_dash, 0, 1, "SFP", text_color = C_TEXT, text_size = size.tiny)
    table.cell(s_dash, 1, 1, sfpText, text_color = sfpClr, text_size = size.tiny)
    table.cell(s_dash, 2, 1, i_showSFP ? "ON" : "OFF", text_color = i_showSFP ? i_colUp : C_NEUTRAL, text_size = size.tiny)

// ── ALERTS ────────────────────────────────────────────────────
alertcondition(s_sfpBullSignal, title = "Bullish SFP", message = "{{ticker}} {{interval}} - Bullish SFP: the swing low was swept but the close stayed above it, a failed break.")
alertcondition(s_sfpBearSignal, title = "Bearish SFP", message = "{{ticker}} {{interval}} - Bearish SFP: the swing high was swept but the close stayed below it, a failed break.")
alertcondition(s_sfpBullSignal or s_sfpBearSignal, title = "Any SFP", message = "{{ticker}} {{interval}} - Swing failure pattern detected.")
````
