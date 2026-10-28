# SMC Daily Bias [LuxGonAdn]

- url: https://www.tradingview.com/script/XdV3Ap6H-SMC-Daily-Bias-LuxGonAdn/
- type: indicator
- pine_id: PUB;ae2440b59bdd455bb6f99d230c290f94
- version: 1.0

## Description

[list]
[*]Overview — what it does and why it works on any timeframe
[*]Each method explained (A, B, C, D) — logic, signals, and context
[*]On-chart features — table, PDH/PDL lines, background tint
[*]Settings summary — quick reference for every input
[*]Suggested use — practical trading tips including how to pair it with your OB indicator
[/list]

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════
// SMC Daily Bias [LuxGonAdn]
// ═══════════════════════════════════════════════════════════════════
//
// OVERVIEW
// ────────
// This indicator determines the likely directional bias for the current
// trading day using up to three independent methods. Each method votes
// Bullish, Bearish, or Ranging. The results are displayed in a clean
// on-chart table so you can see all signals at a glance, along with a
// combined overall bias score.
//
// Works on ANY chart timeframe — all calculations are always based on
// daily data via request.security(), so the bias stays consistent
// whether you are viewing a 1-minute chart or a weekly chart.
//
// ═══════════════════════════════════════════════════════════════════
// BIAS METHODS
// ═══════════════════════════════════════════════════════════════════
//
// ┌─ A  ICT / Previous Day Candle ─────────────────────────────────┐
// │  Reads the previous completed daily candle.                    │
// │  • Previous day closed ABOVE its open  →  Bullish bias         │
// │  • Previous day closed BELOW its open  →  Bearish bias         │
// │  Simple and effective — institutional players watch the prev   │
// │  day close as a key directional reference.                     │
// └────────────────────────────────────────────────────────────────┘
//
// ┌─ B  Structure — HH/HL vs LH/LL ───────────────────────────────┐
// │  Detects pivot highs and lows on the Daily timeframe and       │
// │  tracks whether the market is making higher or lower pivots.   │
// │  • Last pivot high = HH AND last pivot low = HL  →  Bullish   │
// │  • Last pivot high = LH AND last pivot low = LL  →  Bearish   │
// │  • Mixed (e.g. HH + LL)                          →  Ranging   │
// │  Pivot length is adjustable in settings (default 5).          │
// └────────────────────────────────────────────────────────────────┘
//
// ┌─ C  Opening Range ─────────────────────────────────────────────┐
// │  Compares the current price to today's daily open.            │
// │  • Price trading ABOVE today's daily open  →  Bullish         │
// │  • Price trading BELOW today's daily open  →  Bearish         │
// │  Updates in real time as price moves during the session.      │
// └────────────────────────────────────────────────────────────────┘
//
// ┌─ D  Combined Score (default) ──────────────────────────────────┐
// │  Adds up the votes from A + B + C  (range: -3 to +3).         │
// │  • Score +2 or +3  →  Bullish                                 │
// │  • Score -2 or -3  →  Bearish                                 │
// │  • Score -1, 0, +1 →  Ranging (conflicting signals)           │
// │  Requires at least 2 of 3 methods to agree before committing  │
// │  to a direction — reduces false signals.                      │
// └────────────────────────────────────────────────────────────────┘
//
// ═══════════════════════════════════════════════════════════════════
// ON-CHART FEATURES
// ═══════════════════════════════════════════════════════════════════
//
// • Bias Table (top-right by default)
//     Shows all three method signals individually, the combined
//     score, and the final OVERALL bias in one compact panel.
//     Position is configurable (Top/Bottom × Left/Right).
//
// • PDH / PDL Lines
//     Dashed horizontal lines marking the Previous Day High (red)
//     and Previous Day Low (teal). These update at the start of
//     each new trading day and extend right across the chart.
//     Labels can be toggled on or off independently.
//
// • Background Tint
//     A very subtle background colour wash — teal for Bullish,
//     red for Bearish, grey for Ranging — to give instant visual
//     context at a glance. Can be toggled off if preferred.
//
// ═══════════════════════════════════════════════════════════════════
// SETTINGS SUMMARY
// ═══════════════════════════════════════════════════════════════════
//
//  Bias Method          — Choose which method drives the OVERALL label
//  Pivot Length         — Controls daily pivot sensitivity (Method B)
//  Show PDH/PDL Lines   — Toggle the previous day level lines
//  Show PDH/PDL Labels  — Toggle the PDH / PDL text labels
//  PDH / PDL Colors     — Customise level line colours
//  Bullish / Bearish /
//  Ranging Colors       — Customise the signal colours in the table
//  Show Bias Table      — Toggle the on-chart table
//  Show Background Tint — Toggle the background colour wash
//  Table Position       — Move the table to any corner
//
// ═══════════════════════════════════════════════════════════════════
// SUGGESTED USE
// ═══════════════════════════════════════════════════════════════════
//
//  1. Use on your entry timeframe (e.g. 15m, 1H) — the bias always
//     reads daily data regardless of your chart timeframe.
//  2. Only take LONG setups when bias is Bullish.
//     Only take SHORT setups when bias is Bearish.
//     Avoid or reduce size when bias is Ranging.
//  3. Combine with the Order Blocks & Breaker Blocks indicator for
//     confluence: OB in bias direction = highest-probability entry.
//  4. PDH and PDL are key intraday magnets — price often targets
//     them early in the session before continuing in bias direction.
//
// ═══════════════════════════════════════════════════════════════════

//@version=5
indicator("SMC Daily Bias [LuxGonAdn]", overlay=true, max_lines_count=20, max_labels_count=20)

// ═══════════════════════════════════════════════════════════════════
//  SETTINGS
// ═══════════════════════════════════════════════════════════════════
grpM = "── Bias Method ──"
biasMethod   = input.string("D - Combined (Score of A+B+C)", "Bias Method",
     options=["A - ICT (Prev Day Candle)",
              "B - Structure (HH/HL/LH/LL)",
              "C - Opening Range (vs Day Open)",
              "D - Combined (Score of A+B+C)"],
     group=grpM)

grpS = "── Structure Settings (Method B) ──"
pivLen = input.int(5, "Pivot Length", minval=2, maxval=20, group=grpS)

grpL = "── PDH / PDL Levels ──"
showPDLevels = input.bool(true,  "Show PDH / PDL Lines",  group=grpL)
showPDLabels = input.bool(true,  "Show PDH / PDL Labels", group=grpL)
pdhCol       = input.color(color.new(#ff4d4d, 20), "PDH Line Color", group=grpL)
pdlCol       = input.color(color.new(#00bcd4, 20), "PDL Line Color", group=grpL)

grpC = "── Colors ──"
bullCol = input.color(color.new(#00bcd4, 0), "Bullish Color", group=grpC)
bearCol = input.color(color.new(#ff4d4d, 0), "Bearish Color", group=grpC)
neutCol = input.color(color.new(#9e9e9e, 0), "Ranging / Neutral Color", group=grpC)

grpT = "── Display ──"
showTable   = input.bool(true,  "Show Bias Table",            group=grpT)
showBgTint  = input.bool(true,  "Show Background Tint",       group=grpT)
tablePos    = input.string("Top Right", "Table Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"],
     group=grpT)

// ═══════════════════════════════════════════════════════════════════
//  DAILY DATA  (safe lookahead for previous-day values)
// ═══════════════════════════════════════════════════════════════════
dOpen  = request.security(syminfo.tickerid, "D", open,    lookahead=barmerge.lookahead_on)
dHigh  = request.security(syminfo.tickerid, "D", high,    lookahead=barmerge.lookahead_on)
dLow   = request.security(syminfo.tickerid, "D", low,     lookahead=barmerge.lookahead_on)
dClose = request.security(syminfo.tickerid, "D", close,   lookahead=barmerge.lookahead_on)

pdHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pdLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pdOpen  = request.security(syminfo.tickerid, "D", open[1],  lookahead=barmerge.lookahead_on)
pdClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

// ═══════════════════════════════════════════════════════════════════
//  METHOD A — ICT / PREVIOUS DAY CANDLE
//  Bullish if prev day closed above its open (bullish candle)
//  Bearish if prev day closed below its open (bearish candle)
// ═══════════════════════════════════════════════════════════════════
biasA = pdClose > pdOpen ? 1 : pdClose < pdOpen ? -1 : 0

// ═══════════════════════════════════════════════════════════════════
//  METHOD B — DAILY STRUCTURE (HH/HL vs LH/LL)
//  Track last pivot high type and last pivot low type on daily TF
// ═══════════════════════════════════════════════════════════════════
[dailyPH, dailyPL] = request.security(syminfo.tickerid, "D",
     [ta.pivothigh(pivLen, pivLen), ta.pivotlow(pivLen, pivLen)],
     lookahead=barmerge.lookahead_off)

var float lastPivHigh  = na
var float lastPivLow   = na
var int   lastHighType = 0   //  1 = HH,  -1 = LH
var int   lastLowType  = 0   //  1 = HL,  -1 = LL

if not na(dailyPH)
    if not na(lastPivHigh)
        lastHighType := dailyPH > lastPivHigh ? 1 : -1
    lastPivHigh := dailyPH

if not na(dailyPL)
    if not na(lastPivLow)
        lastLowType := dailyPL > lastPivLow ? 1 : -1
    lastPivLow := dailyPL

biasB = (lastHighType == 1 and lastLowType == 1) ? 1 : (lastHighType == -1 and lastLowType == -1) ? -1 : 0

// ═══════════════════════════════════════════════════════════════════
//  METHOD C — OPENING RANGE  (current close vs today's day open)
//  Bullish if price is trading above today's daily open
//  Bearish if price is trading below today's daily open
// ═══════════════════════════════════════════════════════════════════
biasC = close > dOpen ? 1 : close < dOpen ? -1 : 0

// ═══════════════════════════════════════════════════════════════════
//  METHOD D — COMBINED SCORE  (A + B + C = -3 to +3)
//  +2 or +3 → Bullish,  -2 or -3 → Bearish,  -1 to +1 → Ranging
// ═══════════════════════════════════════════════════════════════════
score = biasA + biasB + biasC
biasD = score >= 2 ? 1 : score <= -2 ? -1 : 0

// ═══════════════════════════════════════════════════════════════════
//  FINAL BIAS OUTPUT
// ═══════════════════════════════════════════════════════════════════
finalBias = biasMethod == "A - ICT (Prev Day Candle)" ? biasA : biasMethod == "B - Structure (HH/HL/LH/LL)" ? biasB : biasMethod == "C - Opening Range (vs Day Open)" ? biasC : biasD


biasColor = finalBias == 1 ? bullCol : finalBias == -1 ? bearCol : neutCol
biasText  = finalBias == 1 ? "▲  BULLISH" : finalBias == -1 ? "▼  BEARISH" : "◌  RANGING"

// ═══════════════════════════════════════════════════════════════════
//  PDH / PDL LINES
// ═══════════════════════════════════════════════════════════════════
isNewDay = ta.change(time("D")) != 0

var line pdhLine = na
var line pdlLine = na
var label pdhLbl = na
var label pdlLbl = na

if showPDLevels and isNewDay
    line.delete(pdhLine)
    line.delete(pdlLine)
    label.delete(pdhLbl)
    label.delete(pdlLbl)

    pdhLine := line.new(bar_index, pdHigh, bar_index, pdHigh,
         extend=extend.right, color=pdhCol, style=line.style_dashed, width=1)
    pdlLine := line.new(bar_index, pdLow,  bar_index, pdLow,
         extend=extend.right, color=pdlCol, style=line.style_dashed, width=1)

    if showPDLabels
        pdhLbl := label.new(bar_index, pdHigh, "PDH",
             color=color.new(pdhCol, 80), textcolor=pdhCol,
             style=label.style_label_right, size=size.small)
        pdlLbl := label.new(bar_index, pdLow, "PDL",
             color=color.new(pdlCol, 80), textcolor=pdlCol,
             style=label.style_label_right, size=size.small)

// ═══════════════════════════════════════════════════════════════════
//  BACKGROUND TINT
// ═══════════════════════════════════════════════════════════════════
bgcolor(showBgTint ? color.new(biasColor, 94) : na, title="Bias Background Tint")

// ═══════════════════════════════════════════════════════════════════
//  BIAS TABLE
// ═══════════════════════════════════════════════════════════════════
f_bias_color(v) =>
    v == 1 ? bullCol : v == -1 ? bearCol : neutCol

f_bias_text(v) =>
    v == 1 ? "▲ Bull" : v == -1 ? "▼ Bear" : "◌ Range"

f_score_text(v) =>
    v > 0 ? "+" + str.tostring(v) : str.tostring(v)

tPos = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table biasTable = na

if showTable and barstate.islast
    table.delete(biasTable)

    biasTable := table.new(tPos, 2, 7,
         bgcolor      = color.new(#000000, 75),
         border_color = color.new(#ffffff, 75),
         border_width = 1,
         frame_color  = color.new(#ffffff, 50),
         frame_width  = 1)

    // ── Header ──
    table.cell(biasTable, 0, 0, "DAILY BIAS",
         text_color=color.white, text_size=size.normal,
         bgcolor=color.new(#1a1a2e, 30))
    table.cell(biasTable, 1, 0, "",
         bgcolor=color.new(#1a1a2e, 30))

    // ── Separator ──
    table.cell(biasTable, 0, 1, "Method",
         text_color=color.new(#aaaaaa,0), text_size=size.tiny,
         bgcolor=color.new(#000000, 60))
    table.cell(biasTable, 1, 1, "Signal",
         text_color=color.new(#aaaaaa,0), text_size=size.tiny,
         bgcolor=color.new(#000000, 60))

    // ── A ──
    table.cell(biasTable, 0, 2, "A  Prev Day Candle",
         text_color=color.new(#cccccc,0), text_size=size.tiny)
    table.cell(biasTable, 1, 2, f_bias_text(biasA),
         text_color=f_bias_color(biasA), text_size=size.tiny)

    // ── B ──
    table.cell(biasTable, 0, 3, "B  Structure HH/HL",
         text_color=color.new(#cccccc,0), text_size=size.tiny)
    table.cell(biasTable, 1, 3, f_bias_text(biasB),
         text_color=f_bias_color(biasB), text_size=size.tiny)

    // ── C ──
    table.cell(biasTable, 0, 4, "C  Opening Range",
         text_color=color.new(#cccccc,0), text_size=size.tiny)
    table.cell(biasTable, 1, 4, f_bias_text(biasC),
         text_color=f_bias_color(biasC), text_size=size.tiny)

    // ── Score ──
    table.cell(biasTable, 0, 5, "Score  (A+B+C)",
         text_color=color.new(#cccccc,0), text_size=size.tiny)
    table.cell(biasTable, 1, 5, f_score_text(score),
         text_color=f_bias_color(biasD), text_size=size.small)

    // ── Overall ──
    table.cell(biasTable, 0, 6, "▶  OVERALL",
         text_color=color.white, text_size=size.small,
         bgcolor=color.new(biasColor, 70))
    table.cell(biasTable, 1, 6, biasText,
         text_color=biasColor, text_size=size.small,
         bgcolor=color.new(biasColor, 70))
````
