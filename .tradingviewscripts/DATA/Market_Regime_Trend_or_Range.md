<!-- tradingview-pine-id: PUB;0272c9efbb1f4b5bb246caa9700008c5 -->
<!-- tradingviewscripts-format: 1 -->
# Market Regime — Trend or Range

Source: https://www.tradingview.com/script/aoaLrcvL-Market-Regime-Trend-or-Range/

## Description

WHAT IT DOES

Market Regime — Trend or Range answers one question at a glance: is the current market TRENDING or RANGING? It combines three established, independent regime measures and requires a 2-of-3 majority vote before declaring a verdict, so a single noisy reading cannot flip the classification.

WHY THESE THREE COMPONENTS WORK TOGETHER

Each component measures a different aspect of market character, so their agreement is meaningful rather than redundant:

1) ADX (Wilder) measures directional strength. Vote: Trend above the ADX Trend Threshold (default 25), Range below the ADX Range Threshold (default 20), otherwise neutral.

2) Kaufman Efficiency Ratio measures how efficiently price travels: net change over the lookback divided by the sum of absolute bar-to-bar changes (default length 20). A high ratio means price moved directionally; a low ratio means it churned. Vote: Trend above 0.50, Range below 0.30.

3) Choppiness Index measures sideways versus directional behavior using the log ratio of summed true range to the total high-low range of the lookback (default length 14). Vote: Trend below 38.2, Range above 61.8.

The votes are summed into a score from -3 to +3. TREND requires +2 or more, RANGE requires -2 or less, anything else is MIXED. This 2-of-3 design is the purpose of the combination: ADX alone lags turns, the Efficiency Ratio alone is jumpy, and Choppiness alone ignores direction. Requiring agreement between at least two independent measures filters each one's weakness instead of merely displaying three indicators side by side. The script also derives a 0-100 strength meter by averaging normalized ADX, normalized Efficiency Ratio and inverted Choppiness.

WHAT APPEARS ON THE CHART

- Optional background tint: teal while TREND, orange while RANGE, none while MIXED.
- A dashboard table (corner selectable) showing the verdict, each component's current value with its own vote mark (up arrow = trend vote, down arrow = range vote, dot = neutral), the strength meter, the raw vote score, and a Playbook line that reads Trend tools, Fade tools, or Stand aside.

INPUTS AND DEFAULTS

ADX Length (14), ADX Trend Threshold (25), ADX Range Threshold (20), Efficiency Ratio Length (20), ER Trend Threshold (0.50), ER Range Threshold (0.30), Choppiness Length (14), plus visual toggles for the background tint and the dashboard position. Defaults are the classic reference values for each measure, not optimized settings.

HOW TO USE IT

Read it on your trading timeframe for the live regime, and optionally on a higher timeframe for the session's broader character. On TREND verdicts, continuation methods are generally more appropriate; on RANGE verdicts, mean-reversion and fade methods; on MIXED, caution or smaller size. It works on any symbol and timeframe and makes no claim of special performance on any market.

ALERTS

Two alert conditions are included and fire when the composite verdict changes: "Switched to TREND" and "Switched to RANGE".

BEHAVIOR AND LIMITATIONS

- All calculations run on the chart timeframe with no higher-timeframe requests, so nothing repaints from other timeframes. Values on the live bar update until that bar closes, then are fixed.
- A regime classifier describes current conditions. It does not predict future price and it is not a signal generator.
- Thresholds are configurable; changing them changes how strict each vote is.

This is an informational analysis tool for chart study, not financial advice. Past market behavior does not guarantee future results. Always apply your own risk management.

---

## Source Code

````pine
//@version=6
// Market Regime — Trend or Range
// ----------------------------------------------------------------------
// Tells you whether the current market is TRENDING or RANGING by combining
// three established regime measures (a 2-of-3 vote sets the verdict):
//   1) ADX                  — directional strength
//   2) Efficiency Ratio     — how efficiently price travels (trend vs chop)
//   3) Choppiness Index     — sideways vs directional
// Use it to pick the right playbook: trend tools on trend days, mean-
// reversion / fade tools on range days. Not financial advice.
// ----------------------------------------------------------------------
indicator("Market Regime — Trend or Range", shorttitle="Regime", overlay=true)

g = "Regime Settings"
adxLen   = input.int(14,   "ADX Length",              group=g)
adxTrend = input.float(25, "ADX Trend Threshold",     group=g)
adxRange = input.float(20, "ADX Range Threshold",     group=g)
erLen    = input.int(20,   "Efficiency Ratio Length", group=g)
erTrend  = input.float(0.50,"ER Trend Threshold", step=0.05, group=g)
erRange  = input.float(0.30,"ER Range Threshold", step=0.05, group=g)
chopLen  = input.int(14,   "Choppiness Length",       group=g)

gv = "Visuals"
showBG   = input.bool(true, "Regime Background", group=gv)
showDash = input.bool(true, "Dashboard",         group=gv)
dashPos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gv)

tablePos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right

// 1) ADX
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
adxVote = adx > adxTrend ? 1 : adx < adxRange ? -1 : 0

// 2) Kaufman Efficiency Ratio
erChange = math.abs(close - close[erLen])
erVol    = math.sum(math.abs(close - close[1]), erLen)
er       = erVol != 0 ? erChange / erVol : 0.0
erVote   = er > erTrend ? 1 : er < erRange ? -1 : 0

// 3) Choppiness Index
chopRange = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
chop      = chopRange > 0 ? 100.0 * math.log10(math.sum(ta.tr(true), chopLen) / chopRange) / math.log10(chopLen) : 50.0
chopVote  = chop < 38.2 ? 1 : chop > 61.8 ? -1 : 0   // low choppiness = trending

// Composite verdict (2-of-3 agreement)
score   = adxVote + erVote + chopVote        // -3 .. +3
isTrend = score >= 2
isRange = score <= -2
regime  = isTrend ? "TREND" : isRange ? "RANGE" : "MIXED"

// Trend-strength meter 0-100
adxN     = math.min(adx / 50.0 * 100.0, 100.0)
erN      = math.min(er * 100.0, 100.0)
chopN    = math.max(0.0, 100.0 - chop)
strength = (adxN + erN + chopN) / 3.0

// Colors / background
cTrend = color.teal
cRange = color.orange
cMixed = color.gray
regCol = isTrend ? cTrend : isRange ? cRange : cMixed
bgcolor(showBG ? (isTrend ? color.new(cTrend, 90) : isRange ? color.new(cRange, 90) : na) : na, title="Regime BG")

// Dashboard
if showDash and barstate.islast
    var table t = table.new(tablePos, 2, 7, bgcolor=color.new(#0e1726, 5), border_color=color.new(color.gray, 50), border_width=1)
    table.cell(t, 0, 0, "MARKET REGIME", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 0, regime, text_color=regCol, text_size=size.normal)
    table.cell(t, 0, 1, "ADX", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(adx, "#.0") + (adxVote > 0 ? " ▲" : adxVote < 0 ? " ▼" : " •"), text_color=adxVote > 0 ? cTrend : adxVote < 0 ? cRange : cMixed, text_size=size.small)
    table.cell(t, 0, 2, "Efficiency", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(er, "#.00") + (erVote > 0 ? " ▲" : erVote < 0 ? " ▼" : " •"), text_color=erVote > 0 ? cTrend : erVote < 0 ? cRange : cMixed, text_size=size.small)
    table.cell(t, 0, 3, "Choppiness", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(chop, "#.0") + (chopVote > 0 ? " ▲" : chopVote < 0 ? " ▼" : " •"), text_color=chopVote > 0 ? cTrend : chopVote < 0 ? cRange : cMixed, text_size=size.small)
    table.cell(t, 0, 4, "Strength", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(strength, "#") + "/100", text_color=color.white, text_size=size.small)
    table.cell(t, 0, 5, "Score", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 5, str.tostring(score) + " / 3", text_color=regCol, text_size=size.small)
    table.cell(t, 0, 6, "Playbook", text_color=color.gray, text_size=size.small)
    rec = isTrend ? "Trend tools" : isRange ? "Fade tools" : "Stand aside"
    table.cell(t, 1, 6, rec, text_color=regCol, text_size=size.small)

// Optional alerts on regime change
alertcondition(isTrend and not isTrend[1], "Switched to TREND", "Market regime: TREND")
alertcondition(isRange and not isRange[1], "Switched to RANGE", "Market regime: RANGE")
````
