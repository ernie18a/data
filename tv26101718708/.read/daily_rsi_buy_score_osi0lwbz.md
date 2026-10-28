# Daily RSI Buy Score

- url: https://www.tradingview.com/script/osI0lWBZ-Daily-RSI-Buy-Score/
- type: indicator
- pine_id: PUB;b246522eceb345ab9e2252d0706823a2
- version: 4.0

## Description

OVERVIEW
This indicator combines daily RSI, the daily 50 and 200 EMAs, and trend direction into a single checklist and a 0–100% "Buy Score". It is designed to help answer one question quickly: is price currently in a reasonable area to consider a buy, or is it stretched?

The RSI is shown in its own pane at the bottom. The checklist and score are displayed as a compact table on the price chart, and the daily EMAs are plotted directly on price.

All calculations use DAILY data by default, even on intraday charts. This lets you time entries on lower timeframes while keeping the daily picture in view.

WHAT'S ON THE CHART
• RSI pane – Daily RSI (14). The line turns green above the overbought level, red below the oversold level, and is purple in between.
• Daily EMA 50 (orange) and EMA 200 (blue) plotted on the price chart.
• Checklist table (top right by default):
  – Uptrend: EMA 50 is above EMA 200
  – Above EMA200: price is above the 200 EMA
  – EMA200 Uptrend: the 200 EMA is rising (higher than it was 10 days ago)
  – RSI (<45): daily RSI is below your buy-zone level
  – EMA50 (±3%): price is within 3% of the 50 EMA
  – EMA200 (±5%): price is within 5% of the 200 EMA
  – Score: the overall Buy Score with a verdict label

HOW THE BUY SCORE IS CALCULATED
The score is a weighted average of four parts (weights are adjustable):

1. RSI (35%) – RSI at or below the oversold level (30) scores 100; RSI at or above the overbought level (70) scores 0; linear in between. Lower RSI = better entry.
2. Trend (25%) – EMA 50 above EMA 200 adds 50 points, price above EMA 200 adds 25, and a rising EMA 200 adds 25.
3. Proximity to EMA 50 (25%) – 100 when price is on the EMA, falling linearly to 0 at 10% away.
4. Proximity to EMA 200 (15%) – 100 when price is on the EMA, falling linearly to 0 at 20% away.

Verdicts:
• 75%+ STRONG
• 55%+ GOOD
• 40%+ NEUTRAL
• Below 40% WAIT

The idea: the best-scoring setups are pullbacks toward the moving averages in an established uptrend, with RSI cooled off, rather than chasing extended price with high RSI.

NEW TICKERS / LIMITED HISTORY
If a ticker doesn't have enough daily history for the 200 or 50 EMA, the script falls back to shorter EMAs (100 and 20 by default). Fallback EMAs are marked with an asterisk in the table (e.g. EMA100*). If even the fallback isn't available, those checks show ➖ and are excluded from the score, and the remaining weights are rescaled. Hover over the table title for a note when this happens. The fallback can be turned off in settings.

SETTINGS
• Analysis timeframe (default: Daily)
• RSI length, oversold / overbought levels, buy-zone level
• Fast / slow EMA lengths and fallback lengths
• "Near EMA" thresholds (0–10%)
• Distance at which proximity scores reach 0
• Score weights for each component
• Table position and text size
• Show/hide EMAs on the price chart

ALERTS
An alert condition is included for when the Buy Score crosses above a chosen level (default 75). Add it via the Alerts menu and select "Buy score high".

NOTES
• Values for the current day update in real time until the daily candle closes. Historical values do not change.
• The score measures how well the current price matches a "pullback in an uptrend" profile. It does not predict future price and does not consider fundamentals, news, volume, or market conditions.
• Default weights and thresholds are a starting point. Adjust them to fit your own style and the assets you trade.

DISCLAIMER
This script is for educational and informational purposes only and is not financial advice. Past behavior of any indicator does not guarantee future results. Always do your own research and manage your risk.

## Source Code

````pine
//@version=6
indicator("Daily RSI Buy Score", shorttitle = "RSI (chart TF) + Daily Buy Score", overlay = false)

// ───────── Inputs ─────────
string grpA = "Analysis"
string tf          = input.timeframe("D", "Analysis timeframe", group = grpA)
int    rsiLen      = input.int(14, "RSI length", minval = 2, group = grpA)
int    fastLen     = input.int(50, "Fast EMA length", minval = 1, group = grpA)
int    slowLen     = input.int(200, "Slow EMA length", minval = 1, group = grpA)
int    slopeBars   = input.int(10, "Slow EMA slope lookback", minval = 1, group = grpA, tooltip = "Slow EMA counts as rising if it is higher than it was this many bars ago.")
bool   useFallback = input.bool(true, "Fall back to shorter EMAs on new tickers", group = grpA)
int    fastFb      = input.int(20, "Fast EMA fallback length", minval = 1, group = grpA)
int    slowFb      = input.int(100, "Slow EMA fallback length", minval = 1, group = grpA)

string grpR = "RSI zones"
int   rsiOS  = input.int(30, "Oversold", minval = 0, maxval = 100, group = grpR)
int   rsiOB  = input.int(70, "Overbought", minval = 0, maxval = 100, group = grpR)
float rsiBuy = input.float(45, "Buy zone (RSI below)", minval = 0, maxval = 100, step = 1, group = grpR)

string grpF = "EMA50 support"
float nearFast = input.float(3.0, "Checkmark zone above line %", minval = 0, maxval = 10, step = 0.5, group = grpF)
float dipFast  = input.float(1.0, "Checkmark zone below line %", minval = 0, maxval = 10, step = 0.5, group = grpF)
float maxFast  = input.float(10.0, "Score reaches 0 at % above", minval = 0.5, step = 0.5, group = grpF)
float brkFast  = input.float(3.0, "Score reaches 0 at % below", minval = 0.5, maxval = 10, step = 0.5, group = grpF)

string grpS = "EMA200 support"
float nearSlow = input.float(5.0, "Checkmark zone above line %", minval = 0, maxval = 10, step = 0.5, group = grpS)
float dipSlow  = input.float(1.5, "Checkmark zone below line %", minval = 0, maxval = 10, step = 0.5, group = grpS)
float maxSlow  = input.float(10.0, "Score reaches 0 at % above", minval = 0.5, step = 0.5, group = grpS)
float brkSlow  = input.float(3.0, "Score reaches 0 at % below", minval = 0.5, maxval = 10, step = 0.5, group = grpS)
float slowCap  = input.float(90, "Max support score at EMA200", minval = 0, maxval = 100, group = grpS, tooltip = "Pullbacks to the slow EMA carry more trend-failure risk than pullbacks to the fast EMA, so they top out slightly lower.")

string grpW = "Score weights"
float wRsi     = input.float(35, "RSI", minval = 0, group = grpW)
float wTrend   = input.float(25, "Trend", minval = 0, group = grpW)
float wSupport = input.float(40, "Support (EMA proximity)", minval = 0, group = grpW)
float notUpCap = input.float(20, "Support cap when fast EMA < slow EMA", minval = 0, maxval = 100, group = grpW)

string grpV = "Display"
bool   showEmas   = input.bool(true, "Plot EMAs on price chart", group = grpV)
bool   paneOnChartTf = input.bool(true, "RSI pane follows the chart timeframe", group = grpV, tooltip = "On (default): the pane matches TradingView's built-in Relative Strength Index on whatever timeframe the chart shows. The score and checklist still use the analysis timeframe. Off: the pane shows the analysis timeframe RSI.")
int    rsiMaLen   = input.int(14, "RSI-based MA length (SMA)", minval = 1, group = grpV)
string tablePos   = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpV)
string txtSizeIn  = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], group = grpV)
float  alertLevel = input.float(75, "Alert when score crosses above", group = grpV)

// ───────── Daily data (with fallback) ─────────
f_data() =>
    float slowFull = ta.ema(close, slowLen)
    float fastFull = ta.ema(close, fastLen)
    float slowAlt  = ta.ema(close, slowFb)
    float fastAlt  = ta.ema(close, fastFb)
    bool  slowOk   = not na(slowFull)
    bool  fastOk   = not na(fastFull)
    float eSlow    = slowOk or not useFallback ? slowFull : slowAlt
    float eFast    = fastOk or not useFallback ? fastFull : fastAlt
    [ta.rsi(close, rsiLen), eFast, eSlow, eSlow[slopeBars], fastOk, slowOk]

[dRsi, dFast, dSlow, dSlowPrev, fastOk, slowOk] = request.security(syminfo.tickerid, tf, f_data())

bool hasFast  = not na(dFast)
bool hasSlow  = not na(dSlow)
bool hasTrend = hasFast and hasSlow
bool fastFallbackActive = useFallback and not fastOk and hasFast
bool slowFallbackActive = useFallback and not slowOk and hasSlow

string fTxt = "EMA" + str.tostring(fastFallbackActive ? fastFb : fastLen) + (fastFallbackActive ? "*" : "")
string sTxt = "EMA" + str.tostring(slowFallbackActive ? slowFb : slowLen) + (slowFallbackActive ? "*" : "")

// ───────── Conditions ─────────
bool upTrend    = hasTrend and dFast > dSlow
bool aboveSlow  = hasSlow and close > dSlow
bool slowRising = hasSlow and not na(dSlowPrev) and dSlow > dSlowPrev

float distFast = hasFast ? (close - dFast) / dFast * 100 : na
float distSlow = hasSlow ? (close - dSlow) / dSlow * 100 : na

// ───────── Support score: best of fast / slow EMA, asymmetric ─────────
asymScore(float d, float maxAbove, float maxBelow) =>
    d >= 0 ? math.max(0.0, 100 - d / maxAbove * 100) : math.max(0.0, 100 + d / maxBelow * 100)

float s50  = hasFast ? asymScore(distFast, maxFast, brkFast) : 0.0
float s200 = hasSlow ? asymScore(distSlow, maxSlow, brkSlow) * slowCap / 100 : 0.0

bool   hasSupport  = hasFast or hasSlow
bool   useFastLine = hasFast and (not hasSlow or s50 > s200 or (s50 == s200 and close >= dFast))
float  supDist     = useFastLine ? distFast : distSlow
string supTxt      = useFastLine ? fTxt : sTxt
bool   supInZone   = useFastLine ? supDist >= -dipFast and supDist <= nearFast : supDist >= -dipSlow and supDist <= nearSlow
bool   supportOk   = hasSupport and supInZone and (not hasTrend or upTrend)

float rawSupport   = math.max(s50, s200)
float supportScore = not hasSupport ? na : hasTrend and not upTrend ? math.min(rawSupport, notUpCap) : rawSupport

// ───────── Total score (0–100), missing parts excluded ─────────
float rsiScore   = na(dRsi) ? na : math.max(0.0, math.min(100.0, (rsiOB - dRsi) / (rsiOB - rsiOS) * 100))
float trendScore = hasTrend ? (upTrend ? 50 : 0) + (aboveSlow ? 25 : 0) + (slowRising ? 25 : 0) : na

float wR   = na(rsiScore)     ? 0 : wRsi
float wT   = na(trendScore)   ? 0 : wTrend
float wP   = na(supportScore) ? 0 : wSupport
float wSum = wR + wT + wP
float score = wSum > 0 ? (nz(rsiScore) * wR + nz(trendScore) * wT + nz(supportScore) * wP) / wSum : na

// ───────── RSI pane ─────────
// Same as TradingView's built-in Relative Strength Index: ta.rsi(close, 14) on the chart's own bars
// (no request.security), an SMA 14 "RSI-based MA", and 70 / 50 / 30 bands with the same fills.
float paneRsi   = paneOnChartTf ? ta.rsi(close, rsiLen) : dRsi
float paneRsiMa = ta.sma(paneRsi, rsiMaLen)
rsiPlot = plot(paneRsi, "RSI", color = #7E57C2)
plot(paneRsiMa, "RSI-based MA", color = color.yellow)
hOB = hline(rsiOB, "RSI Upper Band", color = #787B86)
hline(50, "RSI Middle Band", color = color.new(#787B86, 50))
hOS = hline(rsiOS, "RSI Lower Band", color = #787B86)
fill(hOB, hOS, color = color.rgb(126, 87, 194, 90), title = "RSI Background Fill")
midLinePlot = plot(50, color = na, editable = false, display = display.none)
fill(rsiPlot, midLinePlot, 100, rsiOB, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100), title = "Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, rsiOS, 0, top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0), title = "Oversold Gradient Fill")

// ───────── EMAs on price chart ─────────
plot(showEmas ? dFast : na, "Daily EMA fast", color.orange, 2, force_overlay = true)
plot(showEmas ? dSlow : na, "Daily EMA slow", color.blue, 2, force_overlay = true)

// ───────── Checklist table on price chart ─────────
pos = switch tablePos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

txtSize = switch txtSizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var table t = table.new(pos, 3, 7, bgcolor = color.new(color.black, 15), frame_color = color.gray, frame_width = 1, border_color = color.new(color.gray, 80), border_width = 1, force_overlay = true)

check(bool ok, bool avail) =>
    avail ? (ok ? "✅" : "❌") : "➖"

fmtPct(float v) =>
    na(v) ? "n/a" : str.tostring(v, "+0.0;-0.0") + "%"

addRow(int r, string lbl, string val, bool ok, bool avail) =>
    table.cell(t, 0, r, lbl, text_color = color.white, text_halign = text.align_left, text_size = txtSize)
    table.cell(t, 1, r, val, text_color = color.silver, text_halign = text.align_right, text_size = txtSize)
    table.cell(t, 2, r, check(ok, avail), text_size = txtSize)

if barstate.isfirst
    table.merge_cells(t, 0, 0, 2, 0)

if barstate.islast
    string note = not hasTrend ? "Not enough daily history – missing checks excluded from score" : fastFallbackActive or slowFallbackActive ? "* Short history – using fallback EMAs" : ""
    table.cell(t, 0, 0, "Buy Checklist · " + tf, text_color = color.white, text_size = txtSize, bgcolor = color.new(color.gray, 60), tooltip = note)

    addRow(1, "Uptrend", "", upTrend, hasTrend)
    addRow(2, "Above " + sTxt, "", aboveSlow, hasSlow)
    addRow(3, sTxt + " Uptrend", "", slowRising, hasSlow and not na(dSlowPrev))
    addRow(4, "RSI (<" + str.tostring(rsiBuy) + ")", na(dRsi) ? "n/a" : str.tostring(dRsi, "0.0"), dRsi < rsiBuy, not na(dRsi))
    addRow(5, "Support " + supTxt, fmtPct(supDist), supportOk, hasSupport)

    string verdict = na(score) ? "N/A" : score >= 75 ? "STRONG" : score >= 55 ? "GOOD" : score >= 40 ? "NEUTRAL" : "WAIT"
    color  vColor  = na(score) ? color.gray : score >= 75 ? color.rgb(0, 200, 83) : score >= 55 ? color.rgb(174, 234, 0) : score >= 40 ? color.rgb(255, 171, 0) : color.rgb(255, 82, 82)
    table.cell(t, 0, 6, "Score", text_color = color.white, text_halign = text.align_left, text_size = txtSize)
    table.cell(t, 1, 6, na(score) ? "–" : str.tostring(score, "0") + "%", text_color = vColor, text_halign = text.align_right, text_size = txtSize)
    table.cell(t, 2, 6, verdict, text_color = color.black, bgcolor = vColor, text_size = txtSize)

// ───────── Alert ─────────
alertcondition(ta.crossover(score, alertLevel), "Buy score high", "Buy score crossed above threshold on {{ticker}}")
````
