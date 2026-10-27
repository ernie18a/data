# Behavioral Edge 3D [Neblok]

- url: https://www.tradingview.com/script/yCJbxK9e-Behavioral-Edge-3D-Neblok/
- type: indicator
- pine_id: PUB;7ff526e36b1f4a7e8f06c490717a7bae
- version: 1.0

## Description

BEHAVIORAL EDGE 3D [Neblok]

Markets aren't moved by perfectly rational traders. They're moved by people who overreact, follow the herd, anchor to old prices, and panic-sell to stop the pain of a loss. Behavioral finance studies those mistakes, and this indicator turns that theory into a live, on-chart read of crowd emotion so you can spot when the crowd is most likely to be wrong.

------------------------------------------------------------
THE CROWD EMOTION INDEX (CEI 0-100)
------------------------------------------------------------
The core of the script blends five behavioral components into one score:

- Overreaction: how far price has stretched from the crowd's average cost (a volume-weighted fair value), measured in ATR.
- Momentum: how strongly price is pushing in one direction.
- Herding: whether bars are agreeing in direction on above-average volume, meaning everyone is piling in the same way.
- Panic / FOMO Thrust: the speed of the move. Fast drops read as panic, fast rips read as FOMO.
- Range Anchoring: where price sits versus the recent highs and lows the crowd remembers.

The CEI is grouped into five zones:
PANIC (below 15) | FEAR (15-35) | NEUTRAL (35-65) | GREED (65-85) | EUPHORIA (above 85)

Candles are colored by zone. Neutral candles keep your normal chart colors, so colored candles instantly tell you the crowd is emotional.

You can adjust the weight of each component and the zone thresholds in the Crowd Emotion Index settings.

------------------------------------------------------------
THE 3D CROWD EMOTION METER
------------------------------------------------------------
To the right of price you'll see a 3D meter stacked from PANIC at the bottom to EUPHORIA at the top. The active zone lights up solid, and the CEI pointer shows the exact reading at a glance.

If the meter is off screen, scroll the chart to the right. If labels touch the meter at your zoom level, raise "Meter offset" in the Visuals settings. You can also change the meter's width, height and 3D depth.

------------------------------------------------------------
SIGNALS
------------------------------------------------------------
Every signal is graded Q 1-5 for quality and confirms on bar close, so signals do not repaint. Hover over any signal label to see the CEI reading, relative volume and extension at the moment it fired.

CAPITULATION (long) / EXHAUSTION (short)
The crowd recently hit Fear or Greed and emotion is now turning. Quality points come from:
- A Panic or Euphoria extreme
- A volume climax
- A rejection candle
- Trapped traders nearby
- Emotion divergence (price makes a new extreme, but the crowd's emotion does not)

SELLERS TRAPPED (long) / BUYERS TRAPPED (short)
Price sweeps an anchored level (prior-day high/low or a recent swing high/low) and snaps back inside with a long wick. Traders who chased the breakout are now trapped, and their exits fuel the reversal.

HERD LONG / HERD SHORT
The CEI crosses the midline in the direction of the trend, on volume, before price is overextended. This catches the herd early instead of joining it late.

Each signal family can be turned on or off, and each has its own minimum quality setting.

------------------------------------------------------------
ANCHOR LEVELS
------------------------------------------------------------
- FAIR VALUE (neon glow line): the crowd's approximate average cost. Price far above it means the crowd is greedy and extended. Far below means the crowd is fearful.
- PDH / PDL: prior-day high and low on intraday charts, the levels traders anchor to most.
- ROUND numbers: the nearest psychological levels above and below price. Auto-sized, or set your own step.

------------------------------------------------------------
DASHBOARD
------------------------------------------------------------
- Crowd Emotion: current CEI and zone
- Overreaction: distance from fair value in ATR
- Herding: buying herd, selling herd, or scattered
- Relative Volume: current volume vs average, flags CLIMAX
- Range Anchor: where price sits in its recent range
- Trap Watch: whether buyers or sellers are currently trapped
- Long / Short Quality: the best setup score building on each side
- Last Signal: the most recent signal and how many bars ago
- Signal Expectancy: trade count, win rate and average R for Reversals, Traps and Herd signals on your loaded chart

------------------------------------------------------------
HOW TO USE IT
------------------------------------------------------------
1. Read the CEI zone first. Panic and Euphoria are where the crowd is most emotional and most often wrong.
2. Watch the Long and Short Quality rows on the dashboard. A score building toward 3-5 means a setup is forming before the signal fires.
3. Favor reversal and trap signals that form near anchor levels (Fair Value, PDH/PDL, Round numbers).
4. Favor higher quality scores. Q 4-5 setups have more behavioral evidence stacked behind them than Q 3.
5. Use Herd signals in trending markets, not choppy ranges.
6. Check the Signal Expectancy section before trusting any signal family on a new symbol or timeframe. If a family shows negative average R on your chart, turn it off or raise its minimum quality.
7. Plan your own stop and position size before entering. The expectancy stats use a hidden ATR-based stop and R-multiple target, which you can adjust in the Expectancy Stats settings.

------------------------------------------------------------
ALERTS
------------------------------------------------------------
For full-detail alerts, create an alert and choose "Any alert() function call." Each alert includes the signal name, direction, quality score, CEI reading, and reference entry, stop and target levels.
Individual alert conditions are also available for each signal type.

------------------------------------------------------------
SETTINGS TIPS
------------------------------------------------------------
- Too many signals: raise the minimum quality scores or the signal cooldown.
- Too few signals: lower the minimum quality scores or the volume climax multiplier.
- Faster markets / lower timeframes: try shorter lengths for the fair-value anchor and herding.
- All colors are adjustable in the Neon Colors section. Label and dashboard text can be set to Normal, Large or Huge.

------------------------------------------------------------
NOTES AND LIMITATIONS
------------------------------------------------------------
- Expectancy tracking holds one trade at a time, counts the stop first if the stop and target are both hit on the same bar, and does not include commissions or slippage. Treat it as a guide, not a full backtest.
- On symbols without volume data, fair value falls back to an EMA and volume-based quality points are unavailable.
- The 3D effect is drawn with layered boxes and lines, since TradingView does not support true 3D rendering.

------------------------------------------------------------
DISCLAIMER
------------------------------------------------------------
This script is provided for educational and informational purposes only and is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, option or other instrument. No signal, score, statistic or level shown by this indicator guarantees any outcome. Past performance, including any expectancy figures displayed on the chart, does not guarantee future results.

Trading involves substantial risk of loss and is not suitable for every investor. Leveraged products such as futures and options can result in losses greater than your initial investment. Only trade with money you can afford to lose. Always do your own research, use proper risk management, and consult a licensed financial professional before making trading decisions. The author is not responsible for any losses incurred from the use of this script.

------------------------------------------------------------
TAGS
------------------------------------------------------------
behavioralfinance, sentiment, fearandgreed, crowdpsychology, capitulation, meanreversion, liquidity, volume, riskmanagement

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok
//@version=6
//
// ──────────────────────────────────────────────────────────────────────────────
//  BEHAVIORAL EDGE 3D [Neblok]
//  Behavioral finance turned into a live read of crowd emotion.
//
//  • Crowd Emotion Index (CEI, 0-100): overreaction, momentum, herding,
//    panic/FOMO thrust and range anchoring blended into one score
//  • Capitulation / Exhaustion reversals  (loss aversion + overreaction)
//  • Trapped-trader sweeps                (anchoring on prior highs/lows)
//  • Herd continuation                    (early herding, before overextension)
//  • 3D emotion meter, signal expectancy in R
//  • Signals confirm on bar close (no repainting)
// ──────────────────────────────────────────────────────────────────────────────
indicator("Behavioral Edge 3D [Neblok]", "Behavioral Edge 3D [Neblok]", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500)

// ═══════════════════════════════════ INPUTS ═══════════════════════════════════
string G_CEI  = "Crowd Emotion Index"
string G_SIG  = "Signals"
string G_ANC  = "Anchors"
string G_RISK = "Expectancy Stats"
string G_VIS  = "Visuals"
string G_COL  = "Neon Colors"

int   lenAnchor = input.int(50, "Fair-value anchor (VWMA length)", minval = 5, group = G_CEI, tooltip = "Approximates the crowd's average cost. Falls back to an EMA on symbols with no volume.")
int   lenAtr    = input.int(14, "ATR length", minval = 1, group = G_CEI)
float extCap    = input.float(3.0, "Overreaction cap (ATR)", minval = 0.5, step = 0.25, group = G_CEI, tooltip = "Distance from fair value, in ATR, that counts as maximum overreaction.")
int   lenRsi    = input.int(14, "Momentum length (RSI)", minval = 2, group = G_CEI)
int   lenHerd   = input.int(10, "Herding length", minval = 2, group = G_CEI)
int   lenRange  = input.int(100, "Range anchor lookback", minval = 10, group = G_CEI)
int   lenVol    = input.int(20, "Relative volume length", minval = 2, group = G_CEI)
int   smoothCei = input.int(3, "CEI smoothing", minval = 1, group = G_CEI)
float wExt      = input.float(1.0, "Weight · Overreaction", minval = 0, step = 0.1, group = G_CEI)
float wMom      = input.float(1.0, "Weight · Momentum", minval = 0, step = 0.1, group = G_CEI)
float wHerd     = input.float(1.0, "Weight · Herding", minval = 0, step = 0.1, group = G_CEI)
float wThr      = input.float(0.8, "Weight · Panic/FOMO thrust", minval = 0, step = 0.1, group = G_CEI)
float wAnc      = input.float(0.8, "Weight · Range anchoring", minval = 0, step = 0.1, group = G_CEI)
float lvlPanic  = input.float(15.0, "Panic below", minval = 0, maxval = 100, group = G_CEI)
float lvlFear   = input.float(35.0, "Fear below", minval = 0, maxval = 100, group = G_CEI)
float lvlGreed  = input.float(65.0, "Greed above", minval = 0, maxval = 100, group = G_CEI)
float lvlEuph   = input.float(85.0, "Euphoria above", minval = 0, maxval = 100, group = G_CEI)

bool  showRev    = input.bool(true, "Capitulation / Exhaustion reversals", group = G_SIG)
int   minRevQ    = input.int(3, "Min reversal quality (of 5)", minval = 1, maxval = 5, group = G_SIG)
bool  showTrap   = input.bool(true, "Trapped-trader sweeps", group = G_SIG)
int   minTrapQ   = input.int(3, "Min trap quality (of 5)", minval = 1, maxval = 5, group = G_SIG)
bool  showHerd   = input.bool(true, "Herd continuation", group = G_SIG)
int   minHerdQ   = input.int(4, "Min herd quality (of 5)", minval = 1, maxval = 5, group = G_SIG)
int   gateBars   = input.int(5, "Emotion extreme lookback (bars)", minval = 1, group = G_SIG, tooltip = "A reversal needs the CEI to have reached Fear/Greed within this many bars.")
float climaxMult = input.float(2.0, "Volume climax (x average)", minval = 1.0, step = 0.1, group = G_SIG)
int   divLen     = input.int(20, "Emotion divergence lookback", minval = 5, group = G_SIG)
int   swingLen   = input.int(20, "Trap swing lookback", minval = 3, group = G_SIG)
float trapWick   = input.float(0.5, "Trap minimum wick (ATR)", minval = 0.1, step = 0.1, group = G_SIG)
int   emaFast    = input.int(21, "Herd trend fast EMA", minval = 2, group = G_SIG)
int   emaSlow    = input.int(55, "Herd trend slow EMA", minval = 3, group = G_SIG)
int   cooldown   = input.int(5, "Signal cooldown (bars)", minval = 0, group = G_SIG)

bool  showFair  = input.bool(true, "Fair-value anchor line", group = G_ANC)
bool  showPdl   = input.bool(true, "Prior-day high / low (intraday)", group = G_ANC)
bool  showRound = input.bool(true, "Round-number magnets", group = G_ANC)
float roundStep = input.float(0.0, "Round-number step (0 = auto)", minval = 0, group = G_ANC)

float stopAtr    = input.float(0.5, "Stat stop buffer beyond signal bar (ATR)", minval = 0, step = 0.1, group = G_RISK, tooltip = "Not drawn on the chart. Used only to grade signals in the expectancy stats and in alert messages.")
float tgtR       = input.float(2.0, "Stat target (R multiple)", minval = 0.5, step = 0.25, group = G_RISK, tooltip = "Not drawn on the chart. Used only to grade signals in the expectancy stats and in alert messages.")
bool  trackStats = input.bool(true, "Track signal expectancy", group = G_RISK, tooltip = "One tracked trade at a time. Exits at stop (-1R) or target (+R). If both hit on one bar, the stop is counted first. No commissions or slippage.")

bool   colorBars  = input.bool(true, "Color candles by crowd emotion", group = G_VIS)
bool   showMeter  = input.bool(true, "3D emotion meter", group = G_VIS)
int    meterOff   = input.int(45, "Meter offset (bars right of last bar)", minval = 2, group = G_VIS, tooltip = "Minimum distance from the last bar. Raise it if the anchor labels (Fair Value, PDH/PDL, Round) touch the meter at your zoom level.")
int    meterWidth = input.int(14, "Meter width (bars)", minval = 4, group = G_VIS)
float  meterAtr   = input.float(10.0, "Meter height (ATR)", minval = 2, step = 0.5, group = G_VIS)
float  depth      = input.float(0.25, "3D depth (ATR)", minval = 0, step = 0.05, group = G_VIS)
string lblSizeIn  = input.string("Large", "Label & box text size", options = ["Normal", "Large", "Huge"], group = G_VIS)
bool   showDash   = input.bool(true, "Dashboard", group = G_VIS)
string dashPosIn  = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_VIS)
string dashSizeIn = input.string("Large", "Dashboard text size", options = ["Normal", "Large", "Huge"], group = G_VIS)

color cPanic   = input.color(#FF073A, "Panic", group = G_COL)
color cFear    = input.color(#FF5F1F, "Fear", group = G_COL)
color cNeutral = input.color(#BC13FE, "Neutral", group = G_COL)
color cGreed   = input.color(#39FF14, "Greed", group = G_COL)
color cEuph    = input.color(#00F0FF, "Euphoria", group = G_COL)
color cLong    = input.color(#39FF14, "Long signal", group = G_COL)
color cShort   = input.color(#FF10F0, "Short signal", group = G_COL)
color cTrap    = input.color(#FFF01F, "Trap signal / round numbers", group = G_COL)
color cAnchor  = input.color(#00F0FF, "Fair value", group = G_COL)
color cLevel   = input.color(#FF5F1F, "Prior-day levels", group = G_COL)

color INK = #0A0A12

// ═══════════════════════════════════ HELPERS ══════════════════════════════════
clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

sizeOf(string s) =>
    switch s
        "Normal" => size.normal
        "Huge"   => size.huge
        => size.large

posOf(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

zoneName(int z) =>
    switch z
        0 => "PANIC"
        1 => "FEAR"
        2 => "NEUTRAL"
        3 => "GREED"
        => "EUPHORIA"

zoneColor(int z) =>
    switch z
        0 => cPanic
        1 => cFear
        2 => cNeutral
        3 => cGreed
        => cEuph

// Isometric 3D box: back face (offset up-right) + depth edges + front face
draw3D(array<box> bxs, array<line> lns, int l, int r, float top, float bot, float d, color c, string txt, color tc, string tsz, int bgT) =>
    int   dx   = 2
    color edge = color.new(c, 55)
    bxs.push(box.new(l + dx, top + d, r + dx, bot + d, border_color = edge, border_width = 1, bgcolor = color.new(c, 92)))
    lns.push(line.new(l, top, l + dx, top + d, color = edge, width = 1))
    lns.push(line.new(r, top, r + dx, top + d, color = edge, width = 1))
    lns.push(line.new(r, bot, r + dx, bot + d, color = edge, width = 1))
    bxs.push(box.new(l, top, r, bot, border_color = c, border_width = 2, bgcolor = color.new(c, bgT), text = txt, text_color = tc, text_size = tsz, text_formatting = text.format_bold))

clearAll(array<box> bxs, array<line> lns, array<label> lbs) =>
    for b in bxs
        b.delete()
    for ln in lns
        ln.delete()
    for lb in lbs
        lb.delete()
    bxs.clear()
    lns.clear()
    lbs.clear()

string lblSize  = sizeOf(lblSizeIn)
string dashSize = sizeOf(dashSizeIn)

// ═════════════════════════════ CROWD EMOTION INDEX ════════════════════════════
float atr    = ta.atr(lenAtr)
float vol    = nz(volume)
bool  hasVol = ta.cum(vol) > 0
float volAvg = ta.sma(vol, lenVol)
float relVol = hasVol and volAvg > 0 ? vol / volAvg : 1.0

// 1) Overreaction: distance from the crowd's average cost (anchoring to cost basis)
float vwmaV = ta.vwma(close, lenAnchor)
float emaV  = ta.ema(close, lenAnchor)
float fair  = hasVol and not na(vwmaV) ? vwmaV : emaV
float extZ  = atr > 0 ? nz(close - fair) / atr : 0.0
float cExt  = clamp(extZ / extCap, -1.0, 1.0)

// 2) Momentum: RSI 25..75 mapped to -1..+1
float rsi  = ta.rsi(close, lenRsi)
float cMom = clamp((nz(rsi, 50.0) - 50.0) / 25.0, -1.0, 1.0)

// 3) Herding: volume-weighted agreement in bar direction
float barDir  = close > open ? 1.0 : close < open ? -1.0 : 0.0
float herdRaw = ta.ema(barDir * math.min(relVol, 3.0), lenHerd)
float cHerd   = nz(clamp(herdRaw, -1.0, 1.0))

// 4) Panic / FOMO thrust: speed of the move in ATR
float thrust    = atr > 0 ? nz(close - close[1]) / atr : 0.0
float thrustEma = ta.ema(thrust, 3)
float cThr      = nz(clamp(thrustEma / 1.5, -1.0, 1.0))

// 5) Range anchoring: where price sits vs the highs/lows the crowd remembers
float hiR      = ta.highest(high, lenRange)
float loR      = ta.lowest(low, lenRange)
float cAnc     = hiR > loR ? (close - loR) / (hiR - loR) * 2.0 - 1.0 : 0.0
float rangePct = hiR > loR ? (close - loR) / (hiR - loR) * 100.0 : 50.0

float wSum   = wExt + wMom + wHerd + wThr + wAnc
float ceiRaw = wSum > 0 ? (cExt * wExt + cMom * wMom + cHerd * wHerd + cThr * wThr + cAnc * wAnc) / wSum : 0.0
float ceiEma = ta.ema((ceiRaw + 1.0) * 50.0, smoothCei)
float cei    = nz(ceiEma, 50.0)
int   zone   = cei <= lvlPanic ? 0 : cei <= lvlFear ? 1 : cei < lvlGreed ? 2 : cei < lvlEuph ? 3 : 4

// ═══════════════════════════════════ ANCHORS ══════════════════════════════════
bool newDay = timeframe.isintraday ? timeframe.change("D") : true
var float dHi = na
var float dLo = na
var float pdh = na
var float pdl = na
if newDay
    pdh := dHi
    pdl := dLo
    dHi := high
    dLo := low
else
    dHi := na(dHi) ? high : math.max(dHi, high)
    dLo := na(dLo) ? low : math.min(dLo, low)

// ═══════════════════════════════ BEHAVIOR TRIGGERS ════════════════════════════
float rng        = high - low
float closePos   = rng > 0 ? (close - low) / rng : 0.5
float lowerWick  = math.min(open, close) - low
float upperWick  = high - math.max(open, close)
bool  bullReject = rng > 0 and closePos >= 0.6 and (lowerWick >= rng * 0.35 or close > open)
bool  bearReject = rng > 0 and closePos <= 0.4 and (upperWick >= rng * 0.35 or close < open)

bool climax       = hasVol and relVol >= climaxMult
bool climaxRecent = climax or climax[1] or climax[2]

// Emotion extremes and direction (all ta.* calls kept at top level for v6 lazy evaluation)
float ceiLoG    = ta.lowest(cei, gateBars)
float ceiHiG    = ta.highest(cei, gateBars)
bool  fearGate  = ceiLoG <= lvlFear
bool  greedGate = ceiHiG >= lvlGreed
bool  panicHit  = ceiLoG <= lvlPanic
bool  euphHit   = ceiHiG >= lvlEuph
bool  ceiUp     = cei > cei[1]
bool  ceiDn     = cei < cei[1]
bool  ceiXUp    = ta.crossover(cei, 50.0)
bool  ceiXDn    = ta.crossunder(cei, 50.0)

// Emotion divergence: price makes a new extreme but the crowd's emotion does not (exhaustion)
float llWin   = ta.lowest(low, divLen)
float ll3     = ta.lowest(low, 3)
float hhWin   = ta.highest(high, divLen)
float hh3     = ta.highest(high, 3)
float ceiLoW  = ta.lowest(cei, divLen)
float ceiLo3  = ta.lowest(cei, 3)
float ceiHiW  = ta.highest(cei, divLen)
float ceiHi3  = ta.highest(cei, 3)
bool  bullDiv = ll3 <= llWin and ceiLo3 > ceiLoW + 3.0
bool  bearDiv = hh3 >= hhWin and ceiHi3 < ceiHiW - 3.0

// Trapped traders: sweep of an anchored level, then rejection back inside
float swingHi        = ta.highest(high, swingLen)[1]
float swingLo        = ta.lowest(low, swingLen)[1]
bool  sweepSwHi      = high > swingHi and close < swingHi
bool  sweepSwLo      = low < swingLo and close > swingLo
bool  sweepPdH       = timeframe.isintraday and not na(pdh) and high > pdh and close < pdh
bool  sweepPdL       = timeframe.isintraday and not na(pdl) and low < pdl and close > pdl
bool  buyersTrapped  = (sweepSwHi or sweepPdH) and upperWick >= atr * trapWick
bool  sellersTrapped = (sweepSwLo or sweepPdL) and lowerWick >= atr * trapWick

// Trend for herd continuation
float eF      = ta.ema(close, emaFast)
float eS      = ta.ema(close, emaSlow)
bool  trendUp = eF > eS and close > fair
bool  trendDn = eF < eS and close < fair

// ═════════════════════════════ QUALITY SCORES (0-5) ═══════════════════════════
int qRevL  = (panicHit ? 1 : 0) + (climaxRecent ? 1 : 0) + (bullReject ? 1 : 0) + (sellersTrapped or sellersTrapped[1] ? 1 : 0) + (bullDiv ? 1 : 0)
int qRevS  = (euphHit ? 1 : 0) + (climaxRecent ? 1 : 0) + (bearReject ? 1 : 0) + (buyersTrapped or buyersTrapped[1] ? 1 : 0) + (bearDiv ? 1 : 0)
int qTrapL = (sweepPdL ? 1 : 0) + (sweepSwLo ? 1 : 0) + (bullReject ? 1 : 0) + (climax ? 1 : 0) + (cei <= lvlFear ? 1 : 0)
int qTrapS = (sweepPdH ? 1 : 0) + (sweepSwHi ? 1 : 0) + (bearReject ? 1 : 0) + (climax ? 1 : 0) + (cei >= lvlGreed ? 1 : 0)
int qHerdL = (trendUp ? 1 : 0) + (relVol >= 1.0 ? 1 : 0) + (cHerd >= 0.3 ? 1 : 0) + (extZ < 2.0 ? 1 : 0) + (cAnc > 0 ? 1 : 0)
int qHerdS = (trendDn ? 1 : 0) + (relVol >= 1.0 ? 1 : 0) + (cHerd <= -0.3 ? 1 : 0) + (extZ > -2.0 ? 1 : 0) + (cAnc < 0 ? 1 : 0)

bool revLong   = showRev and fearGate and ceiUp and qRevL >= minRevQ
bool revShort  = showRev and greedGate and ceiDn and qRevS >= minRevQ
bool trapLong  = showTrap and sellersTrapped and bullReject and qTrapL >= minTrapQ
bool trapShort = showTrap and buyersTrapped and bearReject and qTrapS >= minTrapQ
bool herdLong  = showHerd and trendUp and ceiXUp and qHerdL >= minHerdQ
bool herdShort = showHerd and trendDn and ceiXDn and qHerdS >= minHerdQ

// ═════════════════════════════ EXPECTANCY TRACKER ═════════════════════════════
var int          tDir  = 0
var int          tType = 0
var int          tBar  = 0
var float        tStop = na
var float        tTgt  = na
var array<int>   stN   = array.from(0, 0, 0)       // 0 = Reversal, 1 = Trap, 2 = Herd
var array<int>   stW   = array.from(0, 0, 0)
var array<float> stR   = array.from(0.0, 0.0, 0.0)

if trackStats and tDir != 0 and bar_index > tBar and barstate.isconfirmed
    bool hitStop = tDir > 0 ? low <= tStop : high >= tStop
    bool hitTgt  = tDir > 0 ? high >= tTgt : low <= tTgt
    if hitStop or hitTgt
        stN.set(tType, stN.get(tType) + 1)
        stW.set(tType, stW.get(tType) + (hitStop ? 0 : 1))
        stR.set(tType, stR.get(tType) + (hitStop ? -1.0 : tgtR))
        tDir := 0

// ═══════════════════════════════ SIGNAL ENGINE ════════════════════════════════
var int    lastSigBar  = -100000
var string lastSigName = "—"
var int    lastSigDir  = 0

int    sigDir  = 0
int    sigType = -1
int    sigQ    = 0
string sigName = ""
bool   cool    = bar_index - lastSigBar > cooldown

if barstate.isconfirmed and cool
    if revLong
        sigDir  := 1
        sigType := 0
        sigQ    := qRevL
        sigName := "CAPITULATION"
    else if revShort
        sigDir  := -1
        sigType := 0
        sigQ    := qRevS
        sigName := "EXHAUSTION"
    else if trapLong
        sigDir  := 1
        sigType := 1
        sigQ    := qTrapL
        sigName := "SELLERS TRAPPED"
    else if trapShort
        sigDir  := -1
        sigType := 1
        sigQ    := qTrapS
        sigName := "BUYERS TRAPPED"
    else if herdLong
        sigDir  := 1
        sigType := 2
        sigQ    := qHerdL
        sigName := "HERD LONG"
    else if herdShort
        sigDir  := -1
        sigType := 2
        sigQ    := qHerdS
        sigName := "HERD SHORT"

if sigDir != 0
    float entry = close
    float stop  = sigDir > 0 ? low - atr * stopAtr : high + atr * stopAtr
    float risk  = math.abs(entry - stop)
    float tgt   = sigDir > 0 ? entry + risk * tgtR : entry - risk * tgtR
    float d     = nz(atr) * depth
    color sc    = sigType == 1 ? cTrap : sigDir > 0 ? cLong : cShort

    lastSigBar  := bar_index
    lastSigName := sigName
    lastSigDir  := sigDir

    // 3D signal label: translucent extrusion offset down-right, solid neon face on top
    float  yL  = sigDir > 0 ? low - nz(atr) * 0.5 : high + nz(atr) * 0.5
    string txt = (sigDir > 0 ? "▲ " : "▼ ") + sigName + "\nQ " + str.tostring(sigQ) + "/5"
    string tip = "Crowd Emotion: " + str.tostring(cei, "#") + " (" + zoneName(zone) + ")" + "\nRelative volume: " + (hasVol ? str.tostring(relVol, "#.0") + "x" : "n/a") + "\nExtension: " + str.tostring(extZ, "#.0") + " ATR" + "\nEntry " + str.tostring(entry, format.mintick) + " | Stop " + str.tostring(stop, format.mintick) + " | Target " + str.tostring(tgt, format.mintick)
    string sty = sigDir > 0 ? label.style_label_up : label.style_label_down
    label.new(bar_index + 1, sigDir > 0 ? yL - d : yL + d, txt, color = color.new(sc, 60), textcolor = color.new(sc, 100), style = sty, size = lblSize, text_formatting = text.format_bold)
    label.new(bar_index, yL, txt, color = sc, textcolor = INK, style = sty, size = lblSize, tooltip = tip, text_formatting = text.format_bold)

    // Open a tracked trade if flat
    if trackStats and tDir == 0
        tDir  := sigDir
        tType := sigType
        tBar  := bar_index
        tStop := stop
        tTgt  := tgt

    alert(syminfo.ticker + " · " + sigName + (sigDir > 0 ? " (LONG)" : " (SHORT)") + " · Q " + str.tostring(sigQ) + "/5 · CEI " + str.tostring(cei, "#") + " " + zoneName(zone) + " · Entry " + str.tostring(entry, format.mintick) + " · Stop " + str.tostring(stop, format.mintick) + " · Target " + str.tostring(tgt, format.mintick), alert.freq_once_per_bar_close)

alertcondition(sigDir == 1 and sigType == 0, "Capitulation (long)", "Behavioral Edge: CAPITULATION long on {{ticker}} at {{close}}")
alertcondition(sigDir == -1 and sigType == 0, "Exhaustion (short)", "Behavioral Edge: EXHAUSTION short on {{ticker}} at {{close}}")
alertcondition(sigDir == 1 and sigType == 1, "Sellers trapped (long)", "Behavioral Edge: SELLERS TRAPPED long on {{ticker}} at {{close}}")
alertcondition(sigDir == -1 and sigType == 1, "Buyers trapped (short)", "Behavioral Edge: BUYERS TRAPPED short on {{ticker}} at {{close}}")
alertcondition(sigDir == 1 and sigType == 2, "Herd long", "Behavioral Edge: HERD LONG on {{ticker}} at {{close}}")
alertcondition(sigDir == -1 and sigType == 2, "Herd short", "Behavioral Edge: HERD SHORT on {{ticker}} at {{close}}")

// ═══════════════════════════════════ PLOTS ════════════════════════════════════
plot(showFair ? fair : na, "Fair-Value Glow", color = color.new(cAnchor, 80), linewidth = 5)
plot(showFair ? fair : na, "Fair-Value Anchor", color = cAnchor, linewidth = 2)
plot(showPdl and timeframe.isintraday ? pdh : na, "Prior-Day High", color = cLevel, linewidth = 2, style = plot.style_stepline)
plot(showPdl and timeframe.isintraday ? pdl : na, "Prior-Day Low", color = cLevel, linewidth = 2, style = plot.style_stepline)
barcolor(colorBars and zone != 2 ? zoneColor(zone) : na)

plot(cei, "Crowd Emotion Index", display = display.data_window)
plot(qRevL, "Q Reversal Long", display = display.data_window)
plot(qRevS, "Q Reversal Short", display = display.data_window)
plot(qTrapL, "Q Trap Long", display = display.data_window)
plot(qTrapS, "Q Trap Short", display = display.data_window)
plot(qHerdL, "Q Herd Long", display = display.data_window)
plot(qHerdS, "Q Herd Short", display = display.data_window)

// ═══════════════════════════ LAST-BAR DRAWINGS ════════════════════════════════
var array<box>   aBoxes = array.new<box>()
var array<line>  aLines = array.new<line>()
var array<label> aLbls  = array.new<label>()
var array<box>   mBoxes = array.new<box>()
var array<line>  mLines = array.new<line>()
var array<label> mLbls  = array.new<label>()

if barstate.islast
    clearAll(aBoxes, aLines, aLbls)
    clearAll(mBoxes, mLines, mLbls)

    // Round-number magnets (anchoring on psychological levels)
    if showRound
        float stp = roundStep > 0 ? roundStep : math.pow(10, math.floor(math.log10(math.max(close, syminfo.mintick)))) / 20.0
        float rUp = math.ceil(close / stp) * stp
        float rDn = math.floor(close / stp) * stp
        aLines.push(line.new(bar_index - 1, rUp, bar_index, rUp, extend = extend.both, color = color.new(cTrap, 35), width = 1, style = line.style_dotted))
        aLbls.push(label.new(bar_index + 2, rUp, "ROUND " + str.tostring(rUp, format.mintick), style = label.style_label_left, color = cTrap, textcolor = INK, size = lblSize, text_formatting = text.format_bold))
        if rDn != rUp
            aLines.push(line.new(bar_index - 1, rDn, bar_index, rDn, extend = extend.both, color = color.new(cTrap, 35), width = 1, style = line.style_dotted))
            aLbls.push(label.new(bar_index + 2, rDn, "ROUND " + str.tostring(rDn, format.mintick), style = label.style_label_left, color = cTrap, textcolor = INK, size = lblSize, text_formatting = text.format_bold))

    if showPdl and timeframe.isintraday
        if not na(pdh)
            aLbls.push(label.new(bar_index + 2, pdh, "PDH " + str.tostring(pdh, format.mintick), style = label.style_label_left, color = cLevel, textcolor = INK, size = lblSize, text_formatting = text.format_bold))
        if not na(pdl)
            aLbls.push(label.new(bar_index + 2, pdl, "PDL " + str.tostring(pdl, format.mintick), style = label.style_label_left, color = cLevel, textcolor = INK, size = lblSize, text_formatting = text.format_bold))

    if showFair and not na(fair)
        aLbls.push(label.new(bar_index + 2, fair, "FAIR VALUE " + str.tostring(fair, format.mintick), style = label.style_label_left, color = cAnchor, textcolor = INK, size = lblSize, text_formatting = text.format_bold))

    // 3D Crowd Emotion meter
    if showMeter and not na(atr)
        float H    = atr * meterAtr
        float seg  = H / 5.0
        float base = close - H / 2.0
        float d    = atr * depth
        int   x1   = bar_index + meterOff
        int   x2   = x1 + meterWidth
        for z = 0 to 4
            float b0     = base + seg * z
            bool  active = z == zone
            color zc     = zoneColor(z)
            draw3D(mBoxes, mLines, x1, x2, b0 + seg, b0, d, zc, zoneName(z), active ? INK : zc, lblSize, active ? 30 : 88)
        float py = base + H * cei / 100.0
        mLines.push(line.new(x1, py, x2 + 2, py, color = chart.fg_color, width = 3))
        mLbls.push(label.new(x2 + 3, py, "◄ CEI " + str.tostring(cei, "#"), style = label.style_label_left, color = zoneColor(zone), textcolor = INK, size = lblSize, text_formatting = text.format_bold))
        mLbls.push(label.new(math.round(x1 + meterWidth / 2.0), base + H + d * 2, "CROWD EMOTION", style = label.style_label_down, color = INK, textcolor = cEuph, size = lblSize, text_formatting = text.format_bold))

// ═══════════════════════════════════ DASHBOARD ════════════════════════════════
statTxt(array<int> n, array<int> w, array<float> r, int i) =>
    int    cnt = n.get(i)
    string out = "No trades yet"
    if cnt > 0
        float wr = float(w.get(i)) / float(cnt) * 100.0
        float ex = r.get(i) / float(cnt)
        out := str.tostring(cnt) + " · " + str.tostring(wr, "#") + "% · " + (ex >= 0 ? "+" : "") + str.tostring(ex, "#.00") + "R"
    out

statCol(array<int> n, array<float> r, int i) =>
    int cnt = n.get(i)
    cnt == 0 ? cNeutral : r.get(i) / float(cnt) > 0 ? cGreed : cPanic

dcell(table t, int c, int r, string s, color tc, string sz) =>
    table.cell(t, c, r, s, text_color = tc, bgcolor = color.new(INK, 5), text_size = sz, text_halign = text.align_left, text_formatting = text.format_bold)

var table dash = table.new(posOf(dashPosIn), 2, 14, bgcolor = color.new(INK, 5), frame_color = cEuph, frame_width = 2, border_color = color.new(cEuph, 75), border_width = 1)

if barstate.isfirst
    table.merge_cells(dash, 0, 0, 1, 0)
    table.merge_cells(dash, 0, 10, 1, 10)

if showDash and barstate.islast
    color  lc     = #E8E8FF
    color  zc     = zoneColor(zone)
    string herdT  = cHerd >= 0.3 ? "BUYING herd" : cHerd <= -0.3 ? "SELLING herd" : "Scattered"
    color  herdC  = cHerd >= 0.3 ? cGreed : cHerd <= -0.3 ? cPanic : cNeutral
    string volT   = hasVol ? str.tostring(relVol, "#.0") + "x" + (climax ? "  CLIMAX" : "") : "n/a"
    string ancT   = (rangePct >= 80 ? "Near highs " : rangePct <= 20 ? "Near lows " : "Mid-range ") + str.tostring(rangePct, "#") + "%"
    string trapT  = buyersTrapped ? "Buyers trapped" : sellersTrapped ? "Sellers trapped" : "—"
    int    bestL  = math.max(qRevL, math.max(qTrapL, qHerdL))
    int    bestS  = math.max(qRevS, math.max(qTrapS, qHerdS))
    string bestLN = bestL == qRevL ? "Reversal" : bestL == qTrapL ? "Trap" : "Herd"
    string bestSN = bestS == qRevS ? "Reversal" : bestS == qTrapS ? "Trap" : "Herd"
    string lastT  = lastSigDir == 0 ? "—" : lastSigName + " · " + str.tostring(bar_index - lastSigBar) + " bars ago"
    color  lastC  = lastSigDir > 0 ? cLong : lastSigDir < 0 ? cShort : lc

    table.cell(dash, 0, 0, "BEHAVIORAL EDGE 3D [Neblok]", text_color = INK, bgcolor = cEuph, text_size = dashSize, text_formatting = text.format_bold)
    dcell(dash, 0, 1, "Crowd Emotion", lc, dashSize)
    dcell(dash, 1, 1, str.tostring(cei, "#") + " · " + zoneName(zone), zc, dashSize)
    dcell(dash, 0, 2, "Overreaction", lc, dashSize)
    dcell(dash, 1, 2, (extZ >= 0 ? "+" : "") + str.tostring(extZ, "#.0") + " ATR vs fair", math.abs(extZ) >= 2.0 ? cTrap : lc, dashSize)
    dcell(dash, 0, 3, "Herding", lc, dashSize)
    dcell(dash, 1, 3, herdT, herdC, dashSize)
    dcell(dash, 0, 4, "Relative Volume", lc, dashSize)
    dcell(dash, 1, 4, volT, climax ? cTrap : lc, dashSize)
    dcell(dash, 0, 5, "Range Anchor", lc, dashSize)
    dcell(dash, 1, 5, ancT, lc, dashSize)
    dcell(dash, 0, 6, "Trap Watch", lc, dashSize)
    dcell(dash, 1, 6, trapT, trapT == "—" ? lc : cTrap, dashSize)
    dcell(dash, 0, 7, "Long Quality", lc, dashSize)
    dcell(dash, 1, 7, str.tostring(bestL) + "/5 · " + bestLN, bestL >= 3 ? cLong : lc, dashSize)
    dcell(dash, 0, 8, "Short Quality", lc, dashSize)
    dcell(dash, 1, 8, str.tostring(bestS) + "/5 · " + bestSN, bestS >= 3 ? cShort : lc, dashSize)
    dcell(dash, 0, 9, "Last Signal", lc, dashSize)
    dcell(dash, 1, 9, lastT, lastC, dashSize)
    table.cell(dash, 0, 10, trackStats ? "SIGNAL EXPECTANCY  (n · win% · avg R)" : "EXPECTANCY TRACKING OFF", text_color = INK, bgcolor = cNeutral, text_size = dashSize, text_formatting = text.format_bold)
    dcell(dash, 0, 11, "Reversals", lc, dashSize)
    dcell(dash, 1, 11, statTxt(stN, stW, stR, 0), statCol(stN, stR, 0), dashSize)
    dcell(dash, 0, 12, "Traps", lc, dashSize)
    dcell(dash, 1, 12, statTxt(stN, stW, stR, 1), statCol(stN, stR, 1), dashSize)
    dcell(dash, 0, 13, "Herd", lc, dashSize)
    dcell(dash, 1, 13, statTxt(stN, stW, stR, 2), statCol(stN, stR, 2), dashSize)
````
