<!-- tradingview-pine-id: PUB;7c93f7ebc1704dfe9e178ca09f468589 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Session Levels Pro [PineLogic]

Source: https://www.tradingview.com/script/q20SWzgQ-Session-Levels-Pro-PineLogic/

## Description

Session Levels Pro draws the reference prices intraday traders mark up by hand every morning - previous day and previous week extremes, today's open, and the opening range - and keeps them updated on one clean, non-repainting overlay.

WHAT IT PLOTS
PDH / PDL / PDC - previous day high, low and close
OPEN - today's opening price
PWH / PWL - previous week high and low
ORH / ORL - the opening range high and low, measured over a configurable number of minutes from the session open (default 15)

Each level is a single line with a right-hand label showing the level name and its exact price, so you can read the number without hovering.

HOW IT WORKS
Daily and weekly values are pulled with request.security() using lookahead together with a one-bar offset (high[1], low[1], close[1]). That combination is the correct non-repainting idiom: it returns only the completed prior period, so a level never changes after the fact, and what you see on history is what you would have seen live.

The opening range is tracked forward from each new daily bar. While the elapsed time is inside your chosen window the running high and low expand; once the window closes, ORH and ORL are fixed for the rest of the session. The opening range only appears on intraday timeframes, since it has no meaning on daily and above.

Levels are drawn once and repositioned on the last bar rather than redrawn per bar, which keeps the object count flat regardless of history length.

HOW TO USE IT
Most intraday approaches treat these prices as the day's decision points: a clean break and hold above PDH or the opening range high is continuation, a rejection back inside is a fade, and PWH/PWL frame the wider weekly context. The script marks the levels; it does not tell you which way to trade them.

ALERTS
Six alertcondition entries are included - break above/below PDH, PWH and ORH, and their downside equivalents. Create the alert from the chart and pick the condition you want.

SETTINGS
Toggle every level group independently (daily, weekly, opening range)
Opening range length in minutes, 1-240
Colours for high, low, neutral and opening-range levels
How far to the right the lines and labels extend

NOTES
Non-repainting by construction, as described above.
Previous-day and previous-week values depend on the symbol's session definition, so they follow whatever the exchange feed reports.
Works on any symbol; the opening range needs an intraday timeframe.

Open-source - read the code, change it, use it.

---

## Source Code

````pine
//@version=6
indicator("Session Levels Pro [PineLogic]", shorttitle = "SessLvls", overlay = true, max_lines_count = 100, max_labels_count = 100)

// ── Inputs ─────────────────────────────────────────────────────────
grpD = "Daily Levels"
showPDH = input.bool(true,  "Previous Day High",  group = grpD)
showPDL = input.bool(true,  "Previous Day Low",   group = grpD)
showPDC = input.bool(false, "Previous Day Close", group = grpD)
showDO  = input.bool(true,  "Today's Open",       group = grpD)

grpW = "Weekly Levels"
showPWH = input.bool(true, "Previous Week High", group = grpW)
showPWL = input.bool(true, "Previous Week Low",  group = grpW)

grpOR = "Opening Range"
showOR = input.bool(true, "Show Opening Range", group = grpOR)
orMins = input.int(15, "Opening Range Minutes", minval = 1, maxval = 240, group = grpOR)

grpS = "Style"
colHigh    = input.color(color.new(#f23645, 0),  "High levels",   group = grpS)
colLow     = input.color(color.new(#089981, 0),  "Low levels",    group = grpS)
colNeut    = input.color(color.new(#787b86, 0),  "Neutral levels",group = grpS)
colOR      = input.color(color.new(#ff9800, 0),  "Opening range", group = grpS)
extendBars = input.int(15, "Extend labels right (bars)", minval = 5, maxval = 100, group = grpS)

// ── Higher-timeframe levels (prior completed bars → non-repainting) ─
[pdh, pdl, pdc] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl]      = request.security(syminfo.tickerid, "W", [high[1], low[1]],           lookahead = barmerge.lookahead_on)
dOpen           = request.security(syminfo.tickerid, "D", open,                         lookahead = barmerge.lookahead_on)

// ── Opening range tracking ─────────────────────────────────────────
var float orH = na
var float orL = na
var int   dayStartTime  = na
var int   dayStartIndex = na

bool newDay = timeframe.change("D")
if newDay
    dayStartTime  := time
    dayStartIndex := bar_index
    orH := high
    orL := low
else if timeframe.isintraday and not na(dayStartTime) and (time - dayStartTime) < orMins * 60 * 1000
    orH := math.max(orH, high)
    orL := math.min(orL, low)

// ── Drawing (one line + label per level, updated on the last bar) ──
f_level(float price, string txt, color col, bool show) =>
    var line  ln = na
    var label lb = na
    if barstate.islast
        if show and not na(price)
            startIdx = na(dayStartIndex) ? bar_index - 20 : dayStartIndex
            if na(ln)
                ln := line.new(startIdx, price, bar_index + extendBars, price, color = col, width = 1)
                lb := label.new(bar_index + extendBars, price, txt, style = label.style_label_left, color = color.new(col, 85), textcolor = col, size = size.small)
            line.set_xy1(ln, startIdx, price)
            line.set_xy2(ln, bar_index + extendBars, price)
            label.set_xy(lb, bar_index + extendBars, price)
            label.set_text(lb, txt + "  " + str.tostring(price, format.mintick))
            true
        else
            if not na(ln)
                line.delete(ln)
                ln := na
            if not na(lb)
                label.delete(lb)
                lb := na
            true

f_level(pdh,   "PDH",  colHigh, showPDH)
f_level(pdl,   "PDL",  colLow,  showPDL)
f_level(pdc,   "PDC",  colNeut, showPDC)
f_level(dOpen, "OPEN", colNeut, showDO)
f_level(pwh,   "PWH",  colHigh, showPWH)
f_level(pwl,   "PWL",  colLow,  showPWL)
f_level(orH,   "ORH",  colOR,   showOR and timeframe.isintraday)
f_level(orL,   "ORL",  colOR,   showOR and timeframe.isintraday)

// ── Alerts ─────────────────────────────────────────────────────────
alertcondition(ta.crossover(close, pdh),  "Break above PDH", "Price broke above the previous day high")
alertcondition(ta.crossunder(close, pdl), "Break below PDL", "Price broke below the previous day low")
alertcondition(ta.crossover(close, pwh),  "Break above PWH", "Price broke above the previous week high")
alertcondition(ta.crossunder(close, pwl), "Break below PWL", "Price broke below the previous week low")
alertcondition(ta.crossover(close, orH),  "Break above ORH", "Price broke above the opening range high")
alertcondition(ta.crossunder(close, orL), "Break below ORL", "Price broke below the opening range low")
````
