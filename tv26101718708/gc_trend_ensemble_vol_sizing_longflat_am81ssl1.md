# GC Trend Ensemble + Vol Sizing (long/flat)

- url: https://www.tradingview.com/script/am81ssl1-GC-Trend-Ensemble-Vol-Sizing-long-flat/
- type: indicator
- pine_id: PUB;599539b9636f4eb3bf24ba61e4a3d312
- version: 1.0

## Description

OVERVIEW
GC-TE is a slow, rules-based trend filter for COMEX gold futures (GC1! / MGC1!) on the daily chart. It answers two questions every day: should I hold gold, and how much? It is designed as a drawdown filter, not a high-return trading system.

WHY THIS DESIGN
Before building it, I tested common gold ideas on 16 years of CME GC data (June 2010 – September 2026, back-adjusted front month, transaction costs included):
- Intraday bar patterns (volume/candle exhaustion, RSI pullbacks with volume gates) on 15m and 1H showed no edge that survived across market regimes.
- Short-term trend rules (20-day) were mostly noise.
- Shorting gold on trend signals lost money in every variant, including the 2011–2015 bear market.
- The only approach that held up was a slow, multi-lookback trend vote, traded long or flat, with position size scaled to volatility.
This indicator implements exactly that rule, with standard (not optimised) settings.

HOW IT WORKS
1. Four trend votes: today's close vs. the close 20, 60, 120 and 250 trading days ago. Each vote is +1 (higher) or −1 (lower).
2. Trend score = average of the four votes (−1 to +1), shown as columns.
3. Long only when the score is positive; flat otherwise. The indicator never signals shorts.
4. Position size = score × (volatility target ÷ realised 60-day volatility), capped at a maximum leverage. When gold is calm the position is larger; when it is volatile, smaller.
5. The signal is read at the daily close and applies from the next session.

The table shows the current state (LONG/FLAT), each vote, realised volatility, target leverage, notional exposure and the equivalent number of GC and MGC contracts for the account size you enter.

HISTORICAL TEST (hypothetical, June 2011 – September 2026, default settings)
- Indicator rule: about 4.6% per year, worst drawdown about −18%
- Buy & hold GC futures: about 4.0% per year, worst drawdown about −46%
- 2011–2015 gold bear market: about +1.5% per year vs. about −8.1% per year for buy & hold
- 2022–2026 gold bull market: about +8.8% per year vs. about +12.8% per year for buy & hold
Results were similar across 30 nearby parameter variations, so they do not depend on one lucky setting.

LIMITATIONS — PLEASE READ
- The advantage is mainly smaller drawdowns, not higher returns. In strong bull markets it will lag buy & hold because it scales down and exits during pullbacks.
- 15 years is too short to prove the improvement statistically. Treat it as a risk-management tool, not a guaranteed edge.
- Trend rules have long flat or whipsaw periods (for example 2016–2018).
- Futures returns differ from spot XAUUSD because of roll costs. The test used futures.
- Past results do not guarantee future performance.

SETTINGS AND USAGE
- Use a DAILY chart of GC1! or MGC1!. The script stops with a message on other timeframes.
- Turn on back-adjustment for continuous futures (chart settings → "Adjust data for contract changes" / B-ADJ). Without it, contract roll gaps can distort the long-term votes.
- Inputs: the four lookbacks, volatility target (default 15% per year), volatility window (default 60 days), maximum leverage (default 2×) and account equity for the contract calculation.
- Alerts: "go LONG", "go FLAT" and "resize" (target MGC contract count changed). Set alerts to "Once Per Bar Close".
- Most retail accounts will find MGC (10 oz) more practical than GC (100 oz).

This script is for educational and research purposes and is not financial advice.

## Source Code

````pine
//@version=6
// =============================================================================
// GC Trend Ensemble + Volatility Sizing  (LONG / FLAT)          — DAILY chart
//
// Built from 16 years of CME GC data (Databento, Jun-2010 → Sep-2026),
// back-adjusted front month, costs included.
//
// RULE
//   1. Four trend votes: close vs close N days ago, N = 20 / 60 / 120 / 250.
//      Each vote = +1 (up) or -1 (down). Score = average (-1 … +1).
//   2. Only the positive part is traded (long or flat — shorting gold lost
//      money in every test, including the 2011-15 bear market).
//   3. Size = score × (vol target ÷ realised 60-day vol), capped at max lev.
//      Signal is taken at the daily close, position held from the next session.
//
// TESTED RESULT (Jun-2011 → Sep-2026, vs buy & hold GC futures)
//   CAGR 4.6% vs 4.0% | Sharpe 0.50 vs 0.31 | Max DD -18% vs -46%
//   2011-15 bear: +1.5%/yr vs -8.1%/yr | 2022-26 bull: +8.8%/yr vs +12.8%/yr
//   Robust across 30 nearby settings. It is a drawdown filter, not a
//   high-return system: it gives up part of big rallies to avoid big crashes.
//   Sharpe improvement is NOT statistically proven over 15 years.
//
// DATA NOTE: use GC1! (or MGC1!) with back-adjustment ON
//   (chart settings → Symbol → "Adjust data for contract changes" / B-ADJ),
//   otherwise roll gaps distort the 250-day vote.
// =============================================================================
indicator("GC Trend Ensemble + Vol Sizing (long/flat)", shorttitle = "GC-TE", overlay = false, precision = 2)

// ---- inputs -----------------------------------------------------------------
lb1       = input.int(20,  "Lookback 1 (days)", minval = 2)
lb2       = input.int(60,  "Lookback 2 (days)", minval = 2)
lb3       = input.int(120, "Lookback 3 (days)", minval = 2)
lb4       = input.int(250, "Lookback 4 (days)", minval = 2)
volTarget = input.float(15.0, "Volatility target (% per year)", minval = 1) / 100
volWin    = input.int(60, "Realised vol window (days)", minval = 10)
maxLev    = input.float(2.0, "Max leverage (× equity)", minval = 0.1, step = 0.1)
equity    = input.float(100000, "Account equity ($)", minval = 1000)
showTable = input.bool(true, "Show info table")

if not timeframe.isdaily
    runtime.error("GC-TE is designed for the DAILY timeframe. Switch the chart to 1D.")

// ---- trend votes --------------------------------------------------------------
vote(int n) =>
    close > close[n] ? 1.0 : close < close[n] ? -1.0 : 0.0

v1 = vote(lb1)
v2 = vote(lb2)
v3 = vote(lb3)
v4 = vote(lb4)
score  = (v1 + v2 + v3 + v4) / 4.0
longSc = math.max(score, 0.0)

// ---- volatility sizing -------------------------------------------------------
ret    = close / close[1] - 1
vol    = ta.stdev(ret, volWin) * math.sqrt(252)
lev    = na(vol) or vol == 0 ? 0.0 : math.min(longSc * volTarget / vol, maxLev)

notional = lev * equity
gcCtr    = notional / (close * 100)   // GC  = 100 oz
mgcCtr   = notional / (close * 10)    // MGC =  10 oz

// ---- plots -------------------------------------------------------------------
scoreCol = score >= 0.5 ? color.new(color.teal, 0) : score > 0 ? color.new(color.teal, 55) : score == 0 ? color.gray : score > -0.5 ? color.new(color.red, 55) : color.new(color.red, 0)
plot(score, "Trend score (-1…+1)", color = scoreCol, style = plot.style_columns)
plot(lev, "Target leverage (× equity)", color = color.orange, linewidth = 2)
hline(0, "Zero", color = color.new(color.gray, 50))
bgcolor(lev > 0 ? color.new(color.teal, 92) : na)

// ---- alerts (fire on confirmed daily close) ------------------------------------
enterLong = lev > 0 and nz(lev[1]) == 0
goFlat    = lev == 0 and nz(lev[1]) > 0
mgcChange = math.round(mgcCtr) != math.round(nz(mgcCtr[1]))
alertcondition(enterLong, "GC-TE: go LONG",  "GC-TE: trend score turned positive — go long next session")
alertcondition(goFlat,    "GC-TE: go FLAT",  "GC-TE: trend score ≤ 0 — close the long next session")
alertcondition(mgcChange, "GC-TE: resize",   "GC-TE: target MGC contract count changed — rebalance")

// ---- info table --------------------------------------------------------------
var table t = table.new(position.top_right, 2, 8, border_width = 1)
if showTable and barstate.islast
    txt = color.white
    bg  = color.new(color.black, 20)
    table.cell(t, 0, 0, "GC-TE", text_color = txt, bgcolor = bg)
    table.cell(t, 1, 0, lev > 0 ? "LONG" : "FLAT", text_color = txt, bgcolor = lev > 0 ? color.teal : color.gray)
    table.cell(t, 0, 1, "Votes 20/60/120/250", text_color = txt, bgcolor = bg)
    table.cell(t, 1, 1, str.format("{0} {1} {2} {3}", v1 > 0 ? "▲" : "▼", v2 > 0 ? "▲" : "▼", v3 > 0 ? "▲" : "▼", v4 > 0 ? "▲" : "▼"), text_color = txt, bgcolor = bg)
    table.cell(t, 0, 2, "Score", text_color = txt, bgcolor = bg)
    table.cell(t, 1, 2, str.tostring(score, "#.##"), text_color = txt, bgcolor = bg)
    table.cell(t, 0, 3, "Realised vol", text_color = txt, bgcolor = bg)
    table.cell(t, 1, 3, str.tostring(vol * 100, "#.#") + " %", text_color = txt, bgcolor = bg)
    table.cell(t, 0, 4, "Target leverage", text_color = txt, bgcolor = bg)
    table.cell(t, 1, 4, str.tostring(lev, "#.##") + "×", text_color = txt, bgcolor = bg)
    table.cell(t, 0, 5, "Notional $", text_color = txt, bgcolor = bg)
    table.cell(t, 1, 5, str.tostring(notional, "#,###"), text_color = txt, bgcolor = bg)
    table.cell(t, 0, 6, "GC contracts", text_color = txt, bgcolor = bg)
    table.cell(t, 1, 6, str.tostring(gcCtr, "#.##"), text_color = txt, bgcolor = bg)
    table.cell(t, 0, 7, "MGC contracts", text_color = txt, bgcolor = bg)
    table.cell(t, 1, 7, str.tostring(mgcCtr, "#.#"), text_color = txt, bgcolor = bg)
````
