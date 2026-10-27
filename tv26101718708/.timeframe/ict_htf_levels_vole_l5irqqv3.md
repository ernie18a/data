# ICT HTF Levels [vole]

- url: https://www.tradingview.com/script/L5IrqqV3-ICT-HTF-Levels-vole/
- type: indicator
- pine_id: PUB;849548c41b9e4175b8063e5a0edf11eb
- version: 1.0

## Description

[b]OVERVIEW[/b]

ICT HTF Levels draws the open, the high so far, the low so far and the previous close of a higher-timeframe bar on the current chart. It is a reference layer: four horizontal lines that tell you where the higher-timeframe bar stands while you read a lower-timeframe chart.


[b]HOW IT WORKS[/b]

The indicator requests the open, the high, the low and the previous close of a chosen higher timeframe in a single call and draws each as a labelled horizontal line on the last bar. The open is the open of the current higher-timeframe bar. The high and the low are the extremes of that bar so far, so they move while the bar develops. The previous close is the close of the bar before it. The reference timeframe has to be larger than the chart timeframe. If it is not, nothing is drawn. The lines are rebuilt on every update and only the latest set exists.


[image]https://www.tradingview.com/x/XMWb6F4k/[/image]
[i]The daily open, high so far, low so far and previous close drawn on an hourly stock chart.[/i]


[b]WHAT YOU'LL SEE ON THE CHART[/b]

[list]
[*][b]HTF Open[/b] — a line in the accent colour at the open of the current higher-timeframe bar.
[*][b]HTF High[/b] — a line in the bullish colour at the high of that bar so far.
[*][b]HTF Low[/b] — a line in the bearish colour at the low of that bar so far.
[*][b]HTF Previous Close[/b] — a neutral line at the close of the previous higher-timeframe bar.
[*][b]Labels[/b] — each line is labelled with the reference timeframe and its name.
[*][b]Dashboard[/b] — a small table with the reference timeframe.
[/list]

[image]https://www.tradingview.com/x/chRBwtIU/[/image]
[i]The same four levels, read from the daily bar, on a 15-minute crypto chart.[/i]


[b]BEST FOR[/b]

This indicator draws and labels price structure rather than reporting a single event type, so no market or timeframe group is singled out. It was not measured, and it reads the candles of whatever chart it is placed on.


[b]LIMITATIONS[/b]

The script reads the candles of the chart it is placed on, so results on non-standard chart types differ from results on regular candles. Swing points are known only after the chosen number of bars has passed, so swing-based items appear with that delay. It is a drawing and labelling tool, not a forecast. It is weaker in these situations:

[list]
[*]A reference timeframe that is not larger than the chart timeframe, where nothing is drawn
[*]Reading history, since the lines are drawn for the latest bar only
[*]Very long higher-timeframe bars, where the open can be far from price
[*]Crowded charts, where the four lines overlap other levels
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
//  ICT HTF Levels
//  v1.0.0 · 2026-10-05
//  Open source, Mozilla Public License 2.0
//
//  Measures : Open, high, low and previous close of a higher timeframe bar,
//             drawn on the current chart.
//  Not      : This is not investment advice.
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("ICT HTF Levels [vole]", shorttitle="ICT HTF [vole]", overlay=true, behind_chart=false, max_bars_back=300, max_lines_count=500, max_labels_count=500)
// max_bars_back=300 — Pine's own default; deepest explicit history: none beyond the security call itself.
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

i_htfTF          = input.timeframe("D", "Reference Timeframe", group = G_CORE, tooltip = "Higher timeframe the levels are read from; it has to be larger than the chart timeframe.")
i_showHTF        = input.bool(true, "Show HTF Levels", group = G_VISUAL, tooltip = "Draws the higher-timeframe levels selected below.")
i_htfOpen        = input.bool(true, "Show HTF Open", group = G_VISUAL, tooltip = "Draws the open of the current higher-timeframe bar.")
i_htfHigh        = input.bool(true, "Show HTF High", group = G_VISUAL, tooltip = "Draws the high of the current higher-timeframe bar so far.")
i_htfLow         = input.bool(true, "Show HTF Low", group = G_VISUAL, tooltip = "Draws the low of the current higher-timeframe bar so far.")
i_htfClose       = input.bool(true, "Show HTF Previous Close", group = G_VISUAL, tooltip = "Draws the close of the previous higher-timeframe bar.")
i_htfStyle       = input.string("Dashed", "HTF Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_VISUAL, tooltip = "Line style of the higher-timeframe levels.")

i_colUp     = input.color(C_UP, "Bullish Color", group = G_VISUAL, tooltip = "Colour of the HTF high line.")
i_colDown   = input.color(C_DOWN, "Bearish Color", group = G_VISUAL, tooltip = "Colour of the HTF low line.")
i_colAccent = input.color(C_ACCENT, "Accent Color", group = G_VISUAL, tooltip = "Colour of the HTF open line.")

i_showTable      = input.bool(true, "Show Dashboard", group = G_TABLE, tooltip = "Shows the summary table on the chart.")
i_tablePos       = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Bottom Left", "Top Right", "Bottom Right"], group = G_TABLE, tooltip = "Corner of the chart where the dashboard is placed.")

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

// One call for all four levels. Chart timeframe is lower than the reference timeframe;
// lookahead off, so the developing higher-timeframe bar is read as it stands.
[htfOpen, htfHigh, htfLow, htfClose] = request.security(syminfo.tickerid, i_htfTF, [open, high, low, close[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
htfValid = timeframe.in_seconds(i_htfTF) > timeframe.in_seconds(timeframe.period)

// ── STATE / SIGNAL ────────────────────────────────────────────

// ── PLOT ──────────────────────────────────────────────────────
// Higher-timeframe levels: redrawn on every update, only the last drawing survives, so they are built on the last bar only.
var line  s_htfOpenLine  = na
var line  s_htfHighLine  = na
var line  s_htfLowLine   = na
var line  s_htfCloseLine = na
var label s_htfOpenLbl   = na
var label s_htfHighLbl   = na
var label s_htfLowLbl    = na
var label s_htfCloseLbl  = na

htfLineStyle = f_getLineStyle(i_htfStyle)

if barstate.islast and i_showHTF and htfValid
    line.delete(s_htfOpenLine)
    line.delete(s_htfHighLine)
    line.delete(s_htfLowLine)
    line.delete(s_htfCloseLine)
    label.delete(s_htfOpenLbl)
    label.delete(s_htfHighLbl)
    label.delete(s_htfLowLbl)
    label.delete(s_htfCloseLbl)

    int htfLineLen = 30

    if i_htfOpen and not na(htfOpen)
        s_htfOpenLine := line.new(bar_index - htfLineLen, htfOpen, bar_index + 5, htfOpen, color = i_colAccent, style = htfLineStyle, width = 2)
        s_htfOpenLbl  := label.new(bar_index + 6, htfOpen, i_htfTF + " Open", style = label.style_label_left, color = color.new(C_BG, 100), textcolor = i_colAccent, size = size.tiny)

    if i_htfHigh and not na(htfHigh)
        s_htfHighLine := line.new(bar_index - htfLineLen, htfHigh, bar_index + 5, htfHigh, color = i_colUp, style = htfLineStyle, width = 2)
        s_htfHighLbl  := label.new(bar_index + 6, htfHigh, i_htfTF + " High", style = label.style_label_left, color = color.new(C_BG, 100), textcolor = i_colUp, size = size.tiny)

    if i_htfLow and not na(htfLow)
        s_htfLowLine := line.new(bar_index - htfLineLen, htfLow, bar_index + 5, htfLow, color = i_colDown, style = htfLineStyle, width = 2)
        s_htfLowLbl  := label.new(bar_index + 6, htfLow, i_htfTF + " Low", style = label.style_label_left, color = color.new(C_BG, 100), textcolor = i_colDown, size = size.tiny)

    if i_htfClose and not na(htfClose)
        s_htfCloseLine := line.new(bar_index - htfLineLen, htfClose, bar_index + 5, htfClose, color = C_NEUTRAL, style = htfLineStyle, width = 2)
        s_htfCloseLbl  := label.new(bar_index + 6, htfClose, i_htfTF + " PrevC", style = label.style_label_left, color = color.new(C_BG, 100), textcolor = C_NEUTRAL, size = size.tiny)

// ── DASHBOARD ─────────────────────────────────────────────────
// Dashboard. Strings are built on the last bar only.
if barstate.islast and i_showTable
    var table s_dash = table.new(f_getPosition(i_tablePos), 3, 3, bgcolor = C_BG, border_width = 1, border_color = C_BORDER)
    table.cell(s_dash, 0, 0, "ICT HTF Levels", text_color = C_TEXT, text_size = size.small, bgcolor = C_BORDER)
    table.cell(s_dash, 1, 0, "", bgcolor = C_BORDER)
    table.cell(s_dash, 2, 0, timeframe.period, text_color = C_TEXT_DIM, text_size = size.small, bgcolor = C_BORDER)

    string htfInfo = ""
    if htfValid
        htfInfo := "O:" + str.tostring(htfOpen, format.mintick) + " H:" + str.tostring(htfHigh, format.mintick)
    else
        htfInfo := "Chart TF >= HTF"

    table.cell(s_dash, 0, 1, "--- HTF (" + i_htfTF + ") ---", text_color = C_TEXT_DIM, text_size = size.tiny)
    table.cell(s_dash, 1, 1, "", text_color = C_TEXT_DIM, text_size = size.tiny)
    table.cell(s_dash, 2, 1, "", text_color = C_TEXT_DIM, text_size = size.tiny)
    table.cell(s_dash, 0, 2, htfInfo, text_color = C_TEXT_DIM, text_size = size.tiny)
    string htfInfo2 = htfValid ? "L:" + str.tostring(htfLow, format.mintick) + " C:" + str.tostring(htfClose, format.mintick) : ""
    table.cell(s_dash, 1, 2, htfInfo2, text_color = C_TEXT_DIM, text_size = size.tiny)
    table.cell(s_dash, 2, 2, "", text_color = C_TEXT_DIM, text_size = size.tiny)

// ── ALERTS ────────────────────────────────────────────────────
````
