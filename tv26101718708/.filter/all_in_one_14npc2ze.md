# All In One

- url: https://www.tradingview.com/script/14nPc2ZE-All-In-One/
- type: indicator
- pine_id: PUB;d570be4fdb1e46d1be1be3b36fd7c693
- version: 1.0

## Description

#ALL IN ONE. This was developed to take into account all major functions which influence the price and trying to detect trend and reversal as early and as accurately as possible. It takes into account pretty much everything except the options influence and delta. This one tool combined with options data is very powerful. Weeks worth of backtesting has helped to refine this and make it better.

" THIS IS INTENDED FOR DAILY TIMEFRAME"

This is a multi-layered trading indicator that combines market structure analysis, volume profiling, momentum scoring, early reversal detection, and a regime-aware quality grading system into one tool. Here's everything it measures and why each piece matters.

### 1. Market Structure (BOS / CHoCH)
Tracks pivot highs/lows at a configurable length and detects when price breaks structure — a **Bull CHoCH** (Change of Character) when price crosses above the last swing high while not already in an uptrend, and the mirror for bear. Each break also auto-draws an **Order Block** (the last opposing candle before the move) which stays active until "mitigated" (price trades back through it). This tells you where institutional footprints likely sit and whether the prevailing trend has structurally shifted.

### 2. Internal Structure (iBOS / iCHoCH)
Same logic as above but on a tighter pivot length, capturing minor/internal structure shifts inside the larger trend — useful for spotting early continuation or internal pullback completion before the major structure reacts.

### 3. Fair Value Gaps (FVG)
Detects 3-candle price voids (`low > high[2]` for bull, `high < low[2]` for bear) and boxes them as unmitigated liquidity/imbalance zones. They persist until price trades back through the gap, marking areas the market is statistically likely to revisit.

### 4. Premium / Discount Zones
Splits the current swing range at its midpoint (equilibrium) and labels price as trading in Premium (expensive, sell-side bias) or Discount (cheap, buy-side bias) 

### 5. Multi-Timeframe Trend (1H / 4H / 1D)
Independently calculates SMC trend direction on three timeframes using `request.security`, giving you confluence/alignment confirmation rather than relying on a single timeframe's noise.

### 6. Volume Analysis Suite
Includes relative volume vs. a moving average, up/down volume ratio (50-bar cumulative buy vs. sell pressure), VolBuzz (% above/below average), and HVE/HV1 tagging (highest volume ever / highest in the past year) — flags genuine institutional participation vs. routine volume.

### 7. Momentum Score (0-100)
A weighted composite of RSI, EMA stack position, MACD histogram, volume-confirmed candle strength, and body-size-vs-ATR — condensed into a single normalized score so you don't have to read five separate oscillators.

### 8. Early Reversal Detection Engine
The most complex subsystem — combines RSI divergence, liquidity sweeps, wick rejection, volume climax, ATR-extension snapbacks, Williams %R hooks, and MTF trend agreement into a weighted 0-100 reversal score, with cooldowns and CHoCH-based filters to avoid fighting strong trends. Flags both "Early" and "Strong" reversal grades.

### 9. Relative Strength (RS) vs. Benchmarks
Compares the symbol's performance against SPY, QQQ, and a sector ETF (e.g., XLK) over a lookback window — tells you if you're trading a leader or a laggard relative to the market.

### 10. Regime Detection
Classifies the current environment as Bull Trend, Bear Trend, Compression, Expansion, or Range/Chop using MTF trend alignment plus Bollinger Band-width contraction/expansion — context that changes how every other signal should be interpreted.

### 11. Quality Score (the regime-aware grading system we just built)
This is the unifying layer — it takes Trend, Structure, Liquidity/Trend-Health, Volume/Trend-Momentum, Momentum, RS, and Candlestick sub-scores and combines them into a single 0-100 grade (A+ Setup → Avoid). Critically, it **switches scoring logic** depending on whether the market is in a clean trend (rewards trend health and sustained pressure) or a setup/chop phase (rewards sweep + discount + volume climax entry conditions) — so the same dashboard works whether you're trend-following or hunting reversals.

### 12. Dual Dashboard Display
One table gives you the full multi-timeframe/volume/momentum snapshot at a glance; the second breaks down exactly how the quality score was built, sub-score by sub-score, so you can see *why* a setup is graded the way it is rather than trusting a black-box number.

---

### Why it's a full package
Most retail indicators give you structure or FVGs or volume — rarely all of them reconciled into one coherent decision layer. This tool's real value is that the **quality score forces every other module to agree before it tells you something is good** — trend, structure, liquidity, volume, momentum, and relative strength all have to contribute, and the regime switch stops the score from unfairly penalizing a healthy trend just because it doesn't look like a textbook reversal setup. It's built to answer one practical question — "is this actually a good trade right now, and why" — using everything else in the script as supporting evidence rather than standalone signals you'd have to mentally reconcile yourself.


## Operating Notes: Interpreting Reversal Signals in Strong Trends

When multiple timeframe and momentum readings align in one direction, confirm volume support on the lower timeframes (4H and 1H Vol Buzz) before acting on a reversal signal. A reading above +25% on those timeframes adds meaningful confirmation.
Case Study: A High-Score Signal That Failed to Reverse the Trend
In late September, the indicator fired an Early Bear Reversal at a score of 85/100. Price nonetheless continued making higher highs through November and December. Reviewing the dashboard at the signal bar: all three SMC timeframes (1H, 4H, 1D) were Bullish, the Momentum Score read 84/100 (Strong Bull), and RSI stood at 72. Every component of the bear reversal score was technically valid — the engine correctly identified local exhaustion. But local exhaustion within a strong trend typically resolves as a brief pause or shallow pullback, not a structural reversal.
Principles for Evaluating Reversal Signals
A high reversal score indicates conditions for a reversal, not a confirmed trend change. The score reflects exhaustion, not capitulation. In a strong uptrend, even a textbook bear setup often resolves as a 2–5% pullback before the primary trend resumes.
Multi-timeframe alignment is the primary filter. When 1H, 4H, and 1D structure are all bullish, bear reversal signals should be treated with significant skepticism. At minimum, the 4H or 1D trend should flip bearish before a bear reversal signal carries real weight.
RSI divergence loses reliability in strong trends. RSI can remain overbought for extended periods during sustained moves. Divergence frequently fires early and is repeatedly overridden by continued price advance, leading to premature short entries or unwarranted exits from long positions.
ATR band position is a key qualifier. A reversal signal carries limited weight if price is only touching the inner or outer band edge. The signal gains weight when price has pushed deep into the outer ATR zone (Band 2) and begins closing back inside it — indicating an actual mean-reversion event rather than ordinary extension.
Momentum Score should be deteriorating, ideally below 50, before a bear reversal is trusted. A reading of 84/100 indicates the underlying trend engine remains fully intact. A credible reversal candidate shows momentum already declining over several bars, not holding at trend-strength levels.
Vol Buzz and U/D Ratio confirm whether genuine selling pressure is present. A bear reversal signal has substantially more weight when accompanied by elevated Vol Buzz on down candles and a U/D ratio below 0.8. Absent that confirmation, the apparent reversal more likely reflects a temporary pause in buying rather than active distribution.
Structural confirmation is required before acting. A reversal score fires on a single bar, but a credible reversal requires confirmation through an actual structure break — at minimum a Bear CHoCH on the 4H or Daily timeframe. Until that print occurs, the prevailing trend remains intact and reversal signals should be treated as alerts to monitor rather than instructions to trade.
Summary Framework
A high reversal score functions as an early warning, not an entry trigger. It indicates that conditions are favorable for a reversal — comparable to a weather forecast calling for a storm that does not always materialize. Confirmation should be sought through structural breaks, volume validation, or multi-timeframe alignment before any position is taken against the prevailing trend. As a standing rule: do not take a position against a strong, multi-timeframe-confirmed trend on the strength of a single reversal signal, regardless of score. Wait for a second signal or for structure to break first.

## Source Code

````pine
//@version=6
indicator("All In One", overlay = true, max_boxes_count = 200, max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

grp_ms      = "Market Structure"
pivotLength = input.int(8, "Pivot Length", group = grp_ms, minval = 2, tooltip = "8-15 for daily swing. 20-40 for multi-week/month swing.")

grp_vol       = "Volume"
volMaLength   = input.int(20, "Volume MA Length", group = grp_vol, minval = 1)
volMult       = input.float(1.8, "Volume Multiplier", group = grp_vol, minval = 0.1)
colUp         = input.color(color.rgb(39, 54, 233), "Up Volume Color", group = grp_vol)
colDn         = input.color(color.rgb(222, 50, 174), "Down Volume Color", group = grp_vol)
prevC         = input.bool(true, "Color Based On Previous Close", group = grp_vol)
lwVol         = input.bool(false, "Highlight Low Relative Volume", group = grp_vol)
colLw         = input.color(color.rgb(123, 124, 126), "Low RelVol Color", group = grp_vol)
showVolLabels = input.bool(true, "Show Volume Labels on Peaks", group = grp_vol)
peakLen       = input.int(9, "Peak Volume Label Length", group = grp_vol, minval = 2)
showHVE       = input.bool(true, "Mark HVE / HV1 (Daily/Weekly/Monthly only)", group = grp_vol)

grp_mom       = "Momentum"
rsiLength     = input.int(14, "RSI Length", group = grp_mom, minval = 2)
rsiOverbought = input.int(70, "RSI Overbought", group = grp_mom, minval = 51, maxval = 99)
rsiOversold   = input.int(30, "RSI Oversold", group = grp_mom, minval = 1, maxval = 49)
colorCandles  = input.bool(true, "Color Candles by Momentum", group = grp_mom)

grp_rev          = "Early Reversal Detection"
showRev          = input.bool(true, "Show Reversal Signals", group = grp_rev)
divLookback      = input.int(12, "Reversal Swing Lookback", group = grp_rev, minval = 5)
climaxMult       = input.float(2.2, "Climax Volume Multiplier", group = grp_rev, minval = 1.2)
trendMaLen       = input.int(50, "Trend Filter EMA Length", group = grp_rev, minval = 5)
revCooldown      = input.int(8, "Cooldown (bars)", group = grp_rev, minval = 3)
showSetupDots    = input.bool(false, "Show Setup Watch Dots", group = grp_rev)
revMinScore      = input.int(78, "Minimum Reversal Score", group = grp_rev, minval = 50, maxval = 100)
strongRevMin     = input.int(88, "Strong Reversal Score", group = grp_rev, minval = 60, maxval = 100)
wickMult         = input.float(1.7, "Rejection Wick / Body Ratio", group = grp_rev, minval = 0.5)
atrRejectMult    = input.float(1.6, "ATR Extension Needed", group = grp_rev, minval = 0.5)
useAdxFilter     = input.bool(true, "Avoid Fighting Very Strong Trend (ADX)", group = grp_rev)
mtfStrictness    = input.int(2, "MTF Agreements Needed (1-3)", group = grp_rev, minval = 1, maxval = 3)
chochCooldown    = input.int(10, "Bars to Wait After CHoCH", group = grp_rev, minval = 0)
requireExtension = input.bool(true, "Require Price Extension from Trend MA", group = grp_rev)

grp_atr   = "ATR Bands"
showAtr   = input.bool(true, "Show ATR Bands", group = grp_atr)
atrLength = input.int(14, "ATR Period", group = grp_atr, minval = 1)
atrEmaLen = input.int(20, "Baseline EMA Length", group = grp_atr, minval = 1)
atrMult1  = input.float(1.5, "ATR Multiplier 1", group = grp_atr, minval = 0.1)
atrMult2  = input.float(3.0, "ATR Multiplier 2", group = grp_atr, minval = 0.1)

grp_ob           = "Order Blocks"
showOBMitigation = input.bool(true, "Deactivate OB on Mitigation", group = grp_ob)

grp_v6 = "SMC Pro V6 Add-ons"
showV6FVG      = input.bool(true, "Show FVG", group = grp_v6)
showV6PD       = input.bool(true, "Show Premium / Discount", group = grp_v6)
showV6Internal = input.bool(true, "Show Internal Structure", group = grp_v6)
v6FvgExtend    = input.int(40, "FVG Extend Bars", minval = 5, group = grp_v6)
v6MaxFvg       = input.int(10, "Max FVG Boxes", minval = 1, maxval = 40, group = grp_v6)
v6IntLen       = input.int(3, "Internal Pivot Length", minval = 2, group = grp_v6)
v6Bench1       = input.symbol("SPY", "RS Benchmark 1", group = grp_v6)
v6Bench2       = input.symbol("QQQ", "RS Benchmark 2", group = grp_v6)
v6Sector       = input.symbol("XLK", "Sector ETF", group = grp_v6)
v6RsLen        = input.int(20, "RS Lookback", minval = 5, group = grp_v6)

// ── Quality Scoring inputs ────────────────────────────────────────────────────
grp_score          = "Quality Scoring"
structureDecayBars = input.int(20, "BOS Score Decay (bars)",  group = grp_score, minval = 5,  maxval = 60,
     tooltip = "How many bars a BOS/CHoCH keeps its full Structure score. Score tapers linearly to 0.")
intDecayBars       = input.int(10, "iBOS Score Decay (bars)", group = grp_score, minval = 3,  maxval = 30)
sweepDecayBars     = input.int(15, "Sweep Decay (bars)",      group = grp_score, minval = 3,  maxval = 40)
hveDecayBars       = input.int(10, "HVE/HV1 Decay (bars)",   group = grp_score, minval = 3,  maxval = 30)
volScoreLookback   = input.int(10, "Volume Score Lookback",   group = grp_score, minval = 3,  maxval = 30)
// Trend health lookback — how many bars to measure HH/HL sequence and pullback depth
trendHealthLen     = input.int(20, "Trend Health Lookback (bars)", group = grp_score, minval = 5, maxval = 50,
     tooltip = "Bars used to measure higher-high / higher-low sequence and pullback depth for the Trend Continuation bonus.")

grp_dash = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group = grp_dash)
dashPos  = input.string(position.top_right, "Position", options = [position.top_right, position.top_left, position.bottom_right, position.bottom_left], group = grp_dash)

grp_style    = "Style"
bullColor    = input.color(#089981, "Bullish Color", group = grp_style)
bearColor    = input.color(#f23645, "Bearish Color", group = grp_style)
neutralColor = input.color(#888888, "Neutral Color", group = grp_style)
revBullColor = input.color(#00bcd4, "Bull Reversal Color", group = grp_style)
revBearColor = input.color(#ff9800, "Bear Reversal Color", group = grp_style)

// ══════════════════════════════════════════════════════════════════════════════
// CORE INDICATORS
// ══════════════════════════════════════════════════════════════════════════════

momRsi        = ta.rsi(close, rsiLength)
strongBullMom = momRsi >= rsiOverbought
strongBearMom = momRsi <= rsiOversold

avgVol       = ta.sma(volume, volMaLength)
isBullCandle = close >= open
isBearCandle = close < open
highVolume   = volume > avgVol * volMult

volColor      = prevC ? close >= close[1] ? colUp : colDn : isBullCandle ? colUp : colDn
lowRVolFlag   = ta.lowest(volume, 10) == volume
volColorFinal = lwVol and lowRVolFlag ? colLw : volColor

atrVal    = ta.atr(atrLength)
emaBase   = ta.ema(close, atrEmaLen)
upperAtr1 = emaBase + atrVal * atrMult1
lowerAtr1 = emaBase - atrVal * atrMult1
upperAtr2 = emaBase + atrVal * atrMult2
lowerAtr2 = emaBase - atrVal * atrMult2

trendMa     = ta.ema(close, trendMaLen)
inUptrend   = close > trendMa
inDowntrend = close < trendMa

williamsR     = ta.wpr(14)
wprOversold   = -80.0
wprOverbought = -20.0

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME ANALYSIS
// ══════════════════════════════════════════════════════════════════════════════

var float hve = volume
if volume > hve
    hve := volume

oneYear = timeframe.isweekly ? 52 : timeframe.ismonthly ? 12 : 252
hvone   = ta.highest(volume, oneYear)

volBuzz    = avgVol != 0 ? 100.0 * (volume / avgVol) - 100.0 : 0.0
volBuzzStr = volBuzz >= 0 ? "+" + str.tostring(math.round(volBuzz)) + "%" : str.tostring(math.round(volBuzz)) + "%"
buzzColor  = volBuzz >= 0 ? bullColor : bearColor

upVol   = close > close[1] ? volume : 0
dnVol   = close < close[1] ? volume : 0
sumUp   = math.sum(upVol, 50)
sumDn   = math.sum(dnVol, 50)
udRatio = sumDn != 0 ? sumUp / sumDn : 1.0
udColor = udRatio >= 1.2 ? bullColor : udRatio <= 0.8 ? bearColor : neutralColor

formatVol(v) =>
    val = math.round(v, 0)
    suffix = ""
    if val >= 1000000000
        val := math.round(val / 1000000000.0, 2)
        suffix := "B"
    else if val >= 1000000
        val := math.round(val / 1000000.0, 2)
        suffix := "M"
    else if val >= 1000
        val := math.round(val / 1000.0, 2)
        suffix := "K"
    str.tostring(val, "0.0") + suffix

avgDolVol    = math.round(close * avgVol, 2)
avgDolVolStr = formatVol(avgDolVol)

pivotVolHigh  = ta.pivothigh(volume, peakLen, peakLen)
varPct        = avgVol[peakLen] != 0 ? 100.0 * (volume[peakLen] / avgVol[peakLen]) - 100.0 : 0.0
showHVEactive = showHVE and (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)

var label peakLabel1 = na
var label peakLabel2 = na

if not na(pivotVolHigh) and varPct > 25 and showVolLabels
    label.delete(peakLabel1)
    label.delete(peakLabel2)
    hvTag = ""
    if showHVEactive
        if volume[peakLen] == hve
            hvTag := "HVE ● "
        else if volume[peakLen] == hvone[peakLen]
            hvTag := "HV1 ● "
    peakLabel1 := label.new(bar_index - peakLen, volume[peakLen], hvTag + formatVol(volume[peakLen]), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, size = size.small, textcolor = color.white)
    peakLabel2 := label.new(bar_index - peakLen, volume[peakLen], "\n+" + str.tostring(math.round(varPct, 0)) + "%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, size = size.small, textcolor = bullColor)

isClimax = volume > avgVol * climaxMult
isHVEBar = showHVEactive and volume == hve
isHV1Bar = showHVEactive and volume == hvone and volume < hve

// ══════════════════════════════════════════════════════════════════════════════
// MOMENTUM SCORE
// ══════════════════════════════════════════════════════════════════════════════

ema20s  = ta.ema(close, 20)
ema50s  = ta.ema(close, 50)
ema200s = ta.ema(close, 200)
emaScore = ((close > ema20s ? 1.0 : 0.0) + (close > ema50s ? 1.0 : 0.0) + (close > ema200s ? 1.0 : 0.0)) / 3.0

[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
macdAbsMax = ta.highest(math.abs(histLine), 50)
macdNorm   = macdAbsMax != 0 ? math.max(0.0, math.min(1.0, (histLine / (2.0 * macdAbsMax)) + 0.5)) : 0.5

avgVolScore = ta.sma(volume, 20)
volRatio    = avgVolScore != 0 ? math.min(volume / avgVolScore, 3.0) / 3.0 : 0.5
volMomScore = isBullCandle ? volRatio : 1.0 - volRatio

atrBody  = ta.atr(14)
bodySize = math.abs(close - open)
bodyNorm = atrBody != 0 ? math.min(bodySize / atrBody, 1.5) / 1.5 : 0.5
bodyNorm := isBullCandle ? bodyNorm : 1.0 - bodyNorm

udMomScore = math.min(math.max((udRatio - 0.5) / 2.0, 0.0), 1.0)

rsiNorm  = momRsi / 100.0
momScore = math.round(math.max(1.0, math.min(100.0, (rsiNorm * 0.28 + emaScore * 0.23 + macdNorm * 0.22 + volMomScore * 0.12 + bodyNorm * 0.10 + udMomScore * 0.05) * 100.0)))
scoreColor = momScore >= 70 ? bullColor : momScore <= 30 ? bearColor : neutralColor

candleColor = momRsi >= rsiOverbought ? color.new(bullColor, 0) : momRsi > 50 ? color.new(bullColor, 40) : momRsi <= rsiOversold ? color.new(bearColor, 0) : color.new(bearColor, 40)
barcolor(colorCandles ? candleColor : na)

// ══════════════════════════════════════════════════════════════════════════════
// ATR BANDS
// ══════════════════════════════════════════════════════════════════════════════

p_ema = plot(showAtr ? emaBase : na, "Baseline EMA", color = color.new(color.gray, 50))
p_u1  = plot(showAtr ? upperAtr1 : na, "Upper ATR 1", color = color.new(bearColor, 50))
p_l1  = plot(showAtr ? lowerAtr1 : na, "Lower ATR 1", color = color.new(bullColor, 50))
p_u2  = plot(showAtr ? upperAtr2 : na, "Upper ATR 2", color = color.new(bearColor, 80))
p_l2  = plot(showAtr ? lowerAtr2 : na, "Lower ATR 2", color = color.new(bullColor, 80))
fill(p_u1, p_u2, color.new(bearColor, 90), "Upper ATR Zone")
fill(p_l1, p_l2, color.new(bullColor, 90), "Lower ATR Zone")

// ══════════════════════════════════════════════════════════════════════════════
// MTF SMC TREND
// ══════════════════════════════════════════════════════════════════════════════

get_smc_trend(len) =>
    var float lastH = na
    var float lastL = na
    var int tr = 0
    phx = ta.pivothigh(high, len, len)
    plx = ta.pivotlow(low, len, len)
    if not na(phx)
        lastH := phx
    if not na(plx)
        lastL := plx
    crossUp = ta.crossover(close, lastH)
    crossDown = ta.crossunder(close, lastL)
    if not na(lastH) and crossUp
        tr := 1
    if not na(lastL) and crossDown
        tr := -1
    tr

trend1H = request.security(syminfo.tickerid, "60", get_smc_trend(pivotLength), lookahead = barmerge.lookahead_off)
trend4H = request.security(syminfo.tickerid, "240", get_smc_trend(pivotLength), lookahead = barmerge.lookahead_off)
trend1D = request.security(syminfo.tickerid, "1D", get_smc_trend(pivotLength), lookahead = barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════════════════════════
// MARKET STRUCTURE
// ══════════════════════════════════════════════════════════════════════════════

var float lastHigh = na
var float lastLow = na
var int lastHighLoc = na
var int lastLowLoc = na

ph = ta.pivothigh(high, pivotLength, pivotLength)
pl = ta.pivotlow(low, pivotLength, pivotLength)

if not na(ph)
    lastHigh := ph
    lastHighLoc := bar_index[pivotLength]
if not na(pl)
    lastLow := pl
    lastLowLoc := bar_index[pivotLength]

var int trend = 0
var box obBox = na
var bool obIsBull = false

crossOverLastHigh = ta.crossover(close, lastHigh)
crossUnderLastLow = ta.crossunder(close, lastLow)

bullBreakout = not na(lastHigh) and crossOverLastHigh and trend != 1
bearBreakout = not na(lastLow) and crossUnderLastLow and trend != -1

var int lastBullChochBar = na
var int lastBearChochBar = na

if bullBreakout
    trend := 1
    obIsBull := true
    lastBullChochBar := bar_index
    volTag = isClimax ? " [Climax Vol]" : highVolume ? " [High Vol]" : ""
    lbl = "Bull CHoCH" + volTag
    if strongBullMom
        lbl += "\nHigh Mom"
    label.new(bar_index, low, lbl, style = label.style_label_up, color = color.new(bullColor, isClimax ? 0 : highVolume ? 20 : 50), textcolor = color.white, size = size.small)
    if not na(lastLowLoc)
        lb = bar_index - lastLowLoc
        obt = high[lb]
        obb = low[lb]
        if not na(obt) and not na(obb)
            obBox := box.new(lastLowLoc, obt, bar_index, obb, border_color = color.new(bullColor, 50), bgcolor = color.new(bullColor, 85))

if bearBreakout
    trend := -1
    obIsBull := false
    lastBearChochBar := bar_index
    volTag = isClimax ? " [Climax Vol]" : highVolume ? " [High Vol]" : ""
    lbl = "Bear CHoCH" + volTag
    if strongBearMom
        lbl += "\nHigh Mom"
    label.new(bar_index, high, lbl, style = label.style_label_down, color = color.new(bearColor, isClimax ? 0 : highVolume ? 20 : 50), textcolor = color.white, size = size.small)
    if not na(lastHighLoc)
        lb = bar_index - lastHighLoc
        obt = high[lb]
        obb = low[lb]
        if not na(obt) and not na(obb)
            obBox := box.new(lastHighLoc, obt, bar_index, obb, border_color = color.new(bearColor, 50), bgcolor = color.new(bearColor, 85))

if not na(obBox)
    obTop = box.get_top(obBox)
    obBot = box.get_bottom(obBox)
    mitigated = showOBMitigation and (obIsBull ? close < obTop : close > obBot)
    if not mitigated
        box.set_right(obBox, bar_index)
    else
        obBox := na

plotshape(highVolume and isBullCandle, "High Buy Volume", style = shape.triangleup, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(highVolume and isBearCandle, "High Sell Volume", style = shape.triangledown, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(isHVEBar, "HVE Bar", style = shape.cross, location = location.abovebar, color = color.new(color.yellow, 0), size = size.small)
plotshape(isHV1Bar, "HV1 Bar", style = shape.diamond, location = location.abovebar, color = color.new(color.orange, 20), size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// EARLY REVERSAL DETECTION
// ══════════════════════════════════════════════════════════════════════════════

[dip, dim, adxVal] = ta.dmi(14, 14)

revPH = ta.pivothigh(high, divLookback, divLookback)
revPL = ta.pivotlow(low, divLookback, divLookback)

var float revLastHigh = na
var float revPrevHigh = na
var float revLastLow = na
var float revPrevLow = na
var float revLastRsiHigh = na
var float revPrevRsiHigh = na
var float revLastRsiLow = na
var float revPrevRsiLow = na

if not na(revPH)
    revPrevHigh := revLastHigh
    revLastHigh := revPH
    revPrevRsiHigh := revLastRsiHigh
    revLastRsiHigh := momRsi[divLookback]

if not na(revPL)
    revPrevLow := revLastLow
    revLastLow := revPL
    revPrevRsiLow := revLastRsiLow
    revLastRsiLow := momRsi[divLookback]

bullDiv = not na(revPrevLow) and not na(revLastLow) and not na(revPrevRsiLow) and not na(revLastRsiLow) and revLastLow < revPrevLow and revLastRsiLow > revPrevRsiLow
bearDiv = not na(revPrevHigh) and not na(revLastHigh) and not na(revPrevRsiHigh) and not na(revLastRsiHigh) and revLastHigh > revPrevHigh and revLastRsiHigh < revPrevRsiHigh

bullSweep = not na(revLastLow) and low < revLastLow and close > revLastLow
bearSweep = not na(revLastHigh) and high > revLastHigh and close < revLastHigh
bullSweepValid = bullSweep and inDowntrend
bearSweepValid = bearSweep and inUptrend

body = math.abs(close - open)
safeBody = body == 0 ? syminfo.mintick : body
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
bullWickReject = lowerWick > safeBody * wickMult and lowerWick > atrVal * 0.25
bearWickReject = upperWick > safeBody * wickMult and upperWick > atrVal * 0.25

relVol = avgVol != 0 ? volume / avgVol : 0.0
volClimax = relVol >= climaxMult

bullAtrExtreme = low < emaBase - atrVal * atrRejectMult
bearAtrExtreme = high > emaBase + atrVal * atrRejectMult
bullBackInside = bullAtrExtreme and close > lowerAtr1
bearBackInside = bearAtrExtreme and close < upperAtr1

priceExtendedDown = close < trendMa
priceExtendedUp = close > trendMa

bullMomentumFade = momRsi < 45 and momRsi > momRsi[1]
bearMomentumFade = momRsi > 55 and momRsi < momRsi[1]

bullFailedBreakdown = low < low[1] and close > low[1] and close > open
bearFailedBreakout = high > high[1] and close < high[1] and close < open
bullMicroConfirm = close > high[1] or bullFailedBreakdown
bearMicroConfirm = close < low[1] or bearFailedBreakout

bullWprHook = williamsR[1] <= wprOversold and williamsR > williamsR[1]
bearWprHook = williamsR[1] >= wprOverbought and williamsR < williamsR[1]

atrProx = ta.atr(14)
nearSwingHigh = not na(revLastHigh) and high >= revLastHigh - atrProx * 2.0
nearSwingLow = not na(revLastLow) and low <= revLastLow + atrProx * 2.0

bearMtfCount = (trend1H <= 0 ? 1 : 0) + (trend4H <= 0 ? 1 : 0) + (trend1D <= 0 ? 1 : 0)
bullMtfCount = (trend1H >= 0 ? 1 : 0) + (trend4H >= 0 ? 1 : 0) + (trend1D >= 0 ? 1 : 0)
mtfAllowsBearRev = bearMtfCount >= mtfStrictness
mtfAllowsBullRev = bullMtfCount >= mtfStrictness

strongBullTrend = close > ema20s and ema20s > ema50s and ema50s > ema200s and adxVal > 30
strongBearTrend = close < ema20s and ema20s < ema50s and ema50s < ema200s and adxVal > 30
allowBearRev = not useAdxFilter or not strongBullTrend or bearSweepValid or bearBackInside
allowBullRev = not useAdxFilter or not strongBearTrend or bullSweepValid or bullBackInside

bullRevAfterChoch = chochCooldown == 0 or na(lastBearChochBar) or bar_index - lastBearChochBar > chochCooldown or bullSweepValid
bearRevAfterChoch = chochCooldown == 0 or na(lastBullChochBar) or bar_index - lastBullChochBar > chochCooldown or bearSweepValid

bullRevScore = 0
bullRevScore += bullSweepValid ? 25 : bullSweep ? 8 : 0
bullRevScore += bullDiv ? 15 : 0
bullRevScore += bullWickReject ? 15 : 0
bullRevScore += volClimax ? 12 : 0
bullRevScore += bullBackInside ? 15 : 0
bullRevScore += bullMicroConfirm ? 10 : 0
bullRevScore += bullWprHook ? 10 : 0
bullRevScore += mtfAllowsBullRev ? 8 : 0
bullRevScore += nearSwingLow ? 5 : 0
bullRevScore += bullMomentumFade ? 5 : 0
bullRevScore += udRatio < 0.7 ? 5 : 0
bullRevScore += (isHVEBar or isHV1Bar) and inDowntrend ? 8 : 0
bullRevScore := math.min(bullRevScore, 100)

bearRevScore = 0
bearRevScore += bearSweepValid ? 25 : bearSweep ? 8 : 0
bearRevScore += bearDiv ? 15 : 0
bearRevScore += bearWickReject ? 15 : 0
bearRevScore += volClimax ? 12 : 0
bearRevScore += bearBackInside ? 15 : 0
bearRevScore += bearMicroConfirm ? 10 : 0
bearRevScore += bearWprHook ? 10 : 0
bearRevScore += mtfAllowsBearRev ? 8 : 0
bearRevScore += nearSwingHigh ? 5 : 0
bearRevScore += bearMomentumFade ? 5 : 0
bearRevScore += udRatio > 1.5 ? 5 : 0
bearRevScore += (isHVEBar or isHV1Bar) and inUptrend ? 8 : 0
bearRevScore := math.min(bearRevScore, 100)

var bool bullRevLocked = false
var bool bearRevLocked = false
var int lastBullRevBar = na
var int lastBearRevBar = na

if not na(revPL)
    bullRevLocked := false
if not na(revPH)
    bearRevLocked := false

bullCooldownOk = na(lastBullRevBar) or bar_index - lastBullRevBar > revCooldown
bearCooldownOk = na(lastBearRevBar) or bar_index - lastBearRevBar > revCooldown

bullCore = bullSweep or bullBackInside or bullFailedBreakdown
bearCore = bearSweep or bearBackInside or bearFailedBreakout

extBullOk = not requireExtension or priceExtendedDown or bullBackInside
extBearOk = not requireExtension or priceExtendedUp or bearBackInside

bullRevSignal = showRev and allowBullRev and bullCore and bullRevScore >= revMinScore and not bullRevLocked and bullCooldownOk and bullRevAfterChoch and extBullOk
bearRevSignal = showRev and allowBearRev and bearCore and bearRevScore >= revMinScore and not bearRevLocked and bearCooldownOk and bearRevAfterChoch and extBearOk

bullStrongRev = bullRevSignal and bullRevScore >= strongRevMin
bearStrongRev = bearRevSignal and bearRevScore >= strongRevMin

if bullRevSignal
    bullRevLocked := true
    lastBullRevBar := bar_index

if bearRevSignal
    bearRevLocked := true
    lastBearRevBar := bar_index

bullLabelText(score) =>
    t = score >= strongRevMin ? "Strong Bull Rev" : "Early Bull Rev"
    t += "\nScore: " + str.tostring(score) + "/100"
    t += bullSweepValid ? "\nSweep" : bullSweep ? "\nWeak Sweep" : ""
    t += bullDiv ? " + RSI Div" : ""
    t += bullWickReject ? " + Wick" : ""
    t += volClimax ? " + Vol Climax" : ""
    t += bullBackInside ? " + ATR Reclaim" : ""
    t += bullMicroConfirm ? " + Micro" : ""
    t += bullWprHook ? " + WPR Hook" : ""
    t += isHVEBar or isHV1Bar ? " + HV Climax" : ""
    t += udRatio < 0.7 ? " + U/D Weak" : ""
    t

bearLabelText(score) =>
    t = score >= strongRevMin ? "Strong Bear Rev" : "Early Bear Rev"
    t += "\nScore: " + str.tostring(score) + "/100"
    t += bearSweepValid ? "\nSweep" : bearSweep ? "\nWeak Sweep" : ""
    t += bearDiv ? " + RSI Div" : ""
    t += bearWickReject ? " + Wick" : ""
    t += volClimax ? " + Vol Climax" : ""
    t += bearBackInside ? " + ATR Reject" : ""
    t += bearMicroConfirm ? " + Micro" : ""
    t += bearWprHook ? " + WPR Hook" : ""
    t += isHVEBar or isHV1Bar ? " + HV Climax" : ""
    t += udRatio > 1.5 ? " + U/D Strong" : ""
    t

if bullRevSignal
    label.new(bar_index, low, bullLabelText(bullRevScore), style = label.style_label_up, color = color.new(revBullColor, bullStrongRev ? 0 : 20), textcolor = color.white, size = bullStrongRev ? size.normal : size.small)

if bearRevSignal
    label.new(bar_index, high, bearLabelText(bearRevScore), style = label.style_label_down, color = color.new(revBearColor, bearStrongRev ? 0 : 20), textcolor = color.white, size = bearStrongRev ? size.normal : size.small)

plotshape(bullRevSignal, "Early Bull Reversal", shape.triangleup, location.belowbar, color.new(revBullColor, 0), size = size.small)
plotshape(bearRevSignal, "Early Bear Reversal", shape.triangledown, location.abovebar, color.new(revBearColor, 0), size = size.small)

bullSetup = showSetupDots and showRev and not bullRevSignal and bullCore and bullRevScore >= 55
bearSetup = showSetupDots and showRev and not bearRevSignal and bearCore and bearRevScore >= 55
plotshape(bullSetup, "Bull Setup Watch", shape.circle, location.belowbar, color.new(revBullColor, 65), size = size.tiny)
plotshape(bearSetup, "Bear Setup Watch", shape.circle, location.abovebar, color.new(revBearColor, 65), size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// V6 ADD-ONS: FVG, PREMIUM/DISCOUNT, INTERNAL STRUCTURE, RS
// ══════════════════════════════════════════════════════════════════════════════

var array<box> v6BullFvgBoxes = array.new<box>()
var array<box> v6BearFvgBoxes = array.new<box>()

v6BullFvg = showV6FVG and low > high[2]
v6BearFvg = showV6FVG and high < low[2]

if v6BullFvg
    b = box.new(bar_index - 2, low, bar_index + v6FvgExtend, high[2], bgcolor = color.new(bullColor, 86), border_color = color.new(bullColor, 65))

    array.unshift(v6BullFvgBoxes, b)
    if array.size(v6BullFvgBoxes) > v6MaxFvg
        old = array.pop(v6BullFvgBoxes)
        box.delete(old)

if v6BearFvg
    b = box.new(bar_index - 2, low[2], bar_index + v6FvgExtend, high, bgcolor = color.new(bearColor, 86), border_color = color.new(bearColor, 65))
    array.unshift(v6BearFvgBoxes, b)
    if array.size(v6BearFvgBoxes) > v6MaxFvg
        old = array.pop(v6BearFvgBoxes)
        box.delete(old)

if array.size(v6BullFvgBoxes) > 0
    for i = array.size(v6BullFvgBoxes) - 1 to 0
        b = array.get(v6BullFvgBoxes, i)
        box.set_right(b, bar_index + v6FvgExtend)
        if low <= box.get_bottom(b)
            box.delete(b)
            array.remove(v6BullFvgBoxes, i)

if array.size(v6BearFvgBoxes) > 0
    for i = array.size(v6BearFvgBoxes) - 1 to 0
        b = array.get(v6BearFvgBoxes, i)
        box.set_right(b, bar_index + v6FvgExtend)
        if high >= box.get_top(b)
            box.delete(b)
            array.remove(v6BearFvgBoxes, i)

var box v6PremiumBox = na
var box v6DiscountBox = na
var line v6EqLine = na

pdStatus = "N/A"
if not na(lastHigh) and not na(lastLow)
    v6Top = math.max(lastHigh, lastLow)
    v6Bot = math.min(lastHigh, lastLow)
    v6Eq = math.avg(v6Top, v6Bot)
    pdStatus := close > v6Eq ? "Premium" : close < v6Eq ? "Discount" : "Equilibrium"

    if showV6PD and barstate.islast
        v6Left = math.min(nz(lastHighLoc, bar_index), nz(lastLowLoc, bar_index))
        v6Right = bar_index + 80

        if na(v6PremiumBox)
            v6PremiumBox := box.new(v6Left, v6Top, v6Right, v6Eq, bgcolor = color.new(bearColor, 94), border_color = color.new(bearColor, 100))
        else
            box.set_left(v6PremiumBox, v6Left)
            box.set_right(v6PremiumBox, v6Right)
            box.set_top(v6PremiumBox, v6Top)
            box.set_bottom(v6PremiumBox, v6Eq)

        if na(v6DiscountBox)
            v6DiscountBox := box.new(v6Left, v6Eq, v6Right, v6Bot, bgcolor = color.new(bullColor, 94), border_color = color.new(bullColor, 100))
        else
            box.set_left(v6DiscountBox, v6Left)
            box.set_right(v6DiscountBox, v6Right)
            box.set_top(v6DiscountBox, v6Eq)
            box.set_bottom(v6DiscountBox, v6Bot)

        if na(v6EqLine)
            v6EqLine := line.new(v6Left, v6Eq, v6Right, v6Eq, color = color.new(neutralColor, 35), style = line.style_dashed)
        else
            line.set_xy1(v6EqLine, v6Left, v6Eq)
            line.set_xy2(v6EqLine, v6Right, v6Eq)

var float v6IntHigh = na
var float v6IntLow = na
var int v6IntHighLoc = na
var int v6IntLowLoc = na
var int v6IntTrend = 0

v6Iph = ta.pivothigh(high, v6IntLen, v6IntLen)
v6Ipl = ta.pivotlow(low, v6IntLen, v6IntLen)

if not na(v6Iph)
    v6IntHigh := v6Iph
    v6IntHighLoc := bar_index[v6IntLen]

if not na(v6Ipl)
    v6IntLow := v6Ipl
    v6IntLowLoc := bar_index[v6IntLen]

v6CrossOverIntHigh = ta.crossover(close, v6IntHigh)
v6CrossUnderIntLow = ta.crossunder(close, v6IntLow)

v6IntBullBreak = showV6Internal and not na(v6IntHigh) and v6CrossOverIntHigh
v6IntBearBreak = showV6Internal and not na(v6IntLow) and v6CrossUnderIntLow

if v6IntBullBreak
    txt = v6IntTrend == -1 ? "iCHoCH" : "iBOS"
    v6IntTrend := 1
    line.new(v6IntHighLoc, v6IntHigh, bar_index, v6IntHigh, color = color.new(bullColor, 60), style = line.style_dotted)
    label.new(bar_index, v6IntHigh, txt, style = label.style_label_down, color = color.new(bullColor, 90), textcolor = bullColor, size = size.tiny)

if v6IntBearBreak
    txt = v6IntTrend == 1 ? "iCHoCH" : "iBOS"
    v6IntTrend := -1
    line.new(v6IntLowLoc, v6IntLow, bar_index, v6IntLow, color = color.new(bearColor, 60), style = line.style_dotted)
    label.new(bar_index, v6IntLow, txt, style = label.style_label_up, color = color.new(bearColor, 90), textcolor = bearColor, size = size.tiny)

v6B1Close = request.security(v6Bench1, timeframe.period, close)
v6B2Close = request.security(v6Bench2, timeframe.period, close)
v6SecClose = request.security(v6Sector, timeframe.period, close)

v6AssetPerf = close / close[v6RsLen] - 1
v6B1Perf = v6B1Close / v6B1Close[v6RsLen] - 1
v6B2Perf = v6B2Close / v6B2Close[v6RsLen] - 1
v6SecPerf = v6SecClose / v6SecClose[v6RsLen] - 1

v6Rs1 = v6AssetPerf - v6B1Perf
v6Rs2 = v6AssetPerf - v6B2Perf
v6Rs3 = v6AssetPerf - v6SecPerf

v6RsScore = (v6Rs1 > 0 ? 1 : 0) + (v6Rs2 > 0 ? 1 : 0) + (v6Rs3 > 0 ? 1 : 0)
v6RsLabel = v6RsScore == 3 ? "Strong Leader" : v6RsScore == 2 ? "Leader" : v6RsScore == 1 ? "Mixed" : "Laggard"

v6BbBasis = ta.sma(close, 20)
v6BbDev = ta.stdev(close, 20)
v6BbWidth = v6BbBasis != 0 ? (v6BbDev * 4) / v6BbBasis * 100 : 0
v6BbWidthAvg = ta.sma(v6BbWidth, 50)
v6VolExpanding = v6BbWidth > v6BbWidthAvg
v6VolContracting = v6BbWidth < v6BbWidthAvg * 0.8

v6Regime = trend1D == 1 and trend4H == 1 ? "Bull Trend" : trend1D == -1 and trend4H == -1 ? "Bear Trend" : v6VolContracting ? "Compression" : v6VolExpanding ? "Expansion" : "Range / Chop"

dxyClose = request.security("TVC:DXY", timeframe.period, close, lookahead = barmerge.lookahead_off)
dxyCorr = ta.correlation(close, dxyClose, 20)

var int annualPeriods = 252
annualPeriods := syminfo.type == "crypto" ? 365 : 252
hvStat = ta.stdev(math.log(close / close[1]), 30) * math.sqrt(annualPeriods) * 100

// ══════════════════════════════════════════════════════════════════════════════
// REGIME DETECTION  (drives which scoring mode is active)
// ══════════════════════════════════════════════════════════════════════════════
// A "strong trend" is defined as MTF alignment + EMA stack + ADX confirmation.
// In this mode the scoring logic switches from entry-setup weighting to
// trend-continuation weighting so a grinding uptrend is not penalised for
// being overbought, in Premium, or having below-average daily volume.

isBullTrendRegime = trend1D == 1 and trend4H == 1 and
     close > ema20s and ema20s > ema50s and adxVal > 20
isBearTrendRegime = trend1D == -1 and trend4H == -1 and
     close < ema20s and ema20s < ema50s and adxVal > 20

// ── TREND HEALTH  (extra points available only in trend regime) ───────────────
// Measures whether the trend is making HH+HL (bull) or LH+LL (bear) over the
// trendHealthLen window using the same pivot arrays that drive market structure.

recentHigh = ta.highest(high, trendHealthLen)
recentLow  = ta.lowest(low,  trendHealthLen)
priorHigh  = ta.highest(high, trendHealthLen * 2) - recentHigh  // approx prior swing
priorLow   = ta.lowest(low,  trendHealthLen * 2) + recentLow   // approx prior swing

// HH/HL sequence: current range high is above its own midpoint AND price is
// holding above the lower half of the recent range (no deep retracement).
recentRange   = recentHigh - recentLow
rangeOk       = recentRange > atrVal * 0.5   // avoid flat/zero range
bullHHHL      = rangeOk and close > recentLow + recentRange * 0.4   // holding upper 60%
bearLHLL      = rangeOk and close < recentHigh - recentRange * 0.4  // holding lower 60%

// Pullback quality: shallow pullback = healthy trend (price > 38% retrace level)
bullShallowPB = rangeOk and low >= recentLow + recentRange * 0.38
bearShallowPB = rangeOk and high <= recentHigh - recentRange * 0.38

// Price vs trend MA — above/below and distance
bullAboveMa  = close > ema20s and close > ema50s
bearBelowMa  = close < ema20s and close < ema50s
// Not too extended (within 2 ATR of 20 EMA keeps continuation odds high)
bullNotExtended = close < ema20s + atrVal * 2.0
bearNotExtended = close > ema20s - atrVal * 2.0

// U/D ratio confirms directional volume pressure over 50 bars (already computed)
bullUdStrong = udRatio > 1.1
bearUdStrong = udRatio < 0.9

// ADX strength tiers
adxStrong = adxVal > 30
adxMod    = adxVal > 20

// ══════════════════════════════════════════════════════════════════════════════
// QUALITY SCORE — REGIME-AWARE DUAL MODE
// ══════════════════════════════════════════════════════════════════════════════
//
// SETUP MODE  (range, chop, compression, or single-TF trend):
//   Original entry-focused weighting. Rewards sweep+discount+vol climax.
//   Max theoretical: Trend 20 + Structure 20 + Liquidity 15 + Volume 20
//                  + Momentum 10 + RS 10 + Candle 5 = 100
//
// TREND CONTINUATION MODE  (isBullTrendRegime / isBearTrendRegime = true):
//   Replaces Liquidity and Volume sub-scores with trend-health equivalents.
//   Liquidity → "Trend Health" (HH/HL sequence, pullback depth, MA position)
//   Volume    → "Trend Momentum" (U/D ratio, ADX, smoothed buzz, RS strength)
//   All other sub-scores (Trend, Structure, Momentum, RS, Candle) unchanged.
//   This means a textbook grinding uptrend can reach 80-90/100.

// ── TREND (same both modes) ───────────────────────────────────────────────────
bullTrendPts = (trend1D == 1 ? 8 : 0) + (trend4H == 1 ? 6 : 0) + (close > ema20s and ema20s > ema50s ? 6 : 0)
bearTrendPts = (trend1D == -1 ? 8 : 0) + (trend4H == -1 ? 6 : 0) + (close < ema20s and ema20s < ema50s ? 6 : 0)

// ── STRUCTURE  (decay-based, same both modes) ─────────────────────────────────
bullBosSince  = ta.barssince(bullBreakout)
bearBosSince  = ta.barssince(bearBreakout)
bullIBosSince = ta.barssince(v6IntBullBreak)
bearIBosSince = ta.barssince(v6IntBearBreak)

bullBosDecay  = not na(bullBosSince)  and bullBosSince  <= structureDecayBars ?
     math.max(1, math.round(8.0 * (1.0 - bullBosSince  / float(structureDecayBars)))) : 0
bearBosDecay  = not na(bearBosSince)  and bearBosSince  <= structureDecayBars ?
     math.max(1, math.round(8.0 * (1.0 - bearBosSince  / float(structureDecayBars)))) : 0
bullIBosDecay = not na(bullIBosSince) and bullIBosSince <= intDecayBars ?
     math.max(1, math.round(3.0 * (1.0 - bullIBosSince / float(intDecayBars)))) : 0
bearIBosDecay = not na(bearIBosSince) and bearIBosSince <= intDecayBars ?
     math.max(1, math.round(3.0 * (1.0 - bearIBosSince / float(intDecayBars)))) : 0

bullStructurePts = bullBosDecay + (trend == 1 ? 6 : 0) + bullIBosDecay + (not na(obBox) and obIsBull ? 3 : 0)
bearStructurePts = bearBosDecay + (trend == -1 ? 6 : 0) + bearIBosDecay + (not na(obBox) and not obIsBull ? 3 : 0)

// ── LIQUIDITY / TREND HEALTH  (mode-switched) ─────────────────────────────────
// SETUP MODE: sweep decay + persistent FVG + graded P/D
bullSweepSince = ta.barssince(bullSweep)
bearSweepSince = ta.barssince(bearSweep)

bullSweepDecay = not na(bullSweepSince) and bullSweepSince <= sweepDecayBars ?
     math.max(1, math.round(6.0 * (1.0 - bullSweepSince / float(sweepDecayBars)))) : 0
bearSweepDecay = not na(bearSweepSince) and bearSweepSince <= sweepDecayBars ?
     math.max(1, math.round(6.0 * (1.0 - bearSweepSince / float(sweepDecayBars)))) : 0

hasBullFvg = array.size(v6BullFvgBoxes) > 0
hasBearFvg = array.size(v6BearFvgBoxes) > 0

pdRange = not na(lastHigh) and not na(lastLow) ? math.abs(lastHigh - lastLow) : na
pdMid   = not na(lastHigh) and not na(lastLow) ? math.avg(lastHigh, lastLow) : na
bullPdPts = not na(pdRange) and pdRange > 0 ?
     math.round(4.0 * math.max(0.0, 1.0 - math.max(0.0, close - pdMid) / (pdRange * 0.5))) : 2
bearPdPts = not na(pdRange) and pdRange > 0 ?
     math.round(4.0 * math.max(0.0, 1.0 - math.max(0.0, pdMid - close) / (pdRange * 0.5))) : 2

bullLiqSetup = bullSweepDecay + (hasBullFvg ? 5 : 0) + bullPdPts
bearLiqSetup = bearSweepDecay + (hasBearFvg ? 5 : 0) + bearPdPts

// TREND CONTINUATION MODE: HH/HL health + shallow pullback + MA position
// Max 15 pts to keep the same sub-score ceiling as Setup Mode liquidity
bullTrendHealth = (bullHHHL      ? 5 : 0) +   // holding upper range = HH/HL structure
                  (bullShallowPB ? 4 : 0) +   // pullback < 38.2% retrace
                  (bullAboveMa   ? 4 : 0) +   // price above both EMAs
                  (bullNotExtended ? 2 : 0)   // not over-extended (sustainable)
bearTrendHealth = (bearLHLL      ? 5 : 0) +
                  (bearShallowPB ? 4 : 0) +
                  (bearBelowMa   ? 4 : 0) +
                  (bearNotExtended ? 2 : 0)

bullLiquidityPts = isBullTrendRegime ? bullTrendHealth : bullLiqSetup
bearLiquidityPts = isBearTrendRegime ? bearTrendHealth : bearLiqSetup

// ── VOLUME / TREND MOMENTUM  (mode-switched) ──────────────────────────────────
// SETUP MODE: rolling HV count + HVE/HV1 decay + smoothed buzz + U/D
udBullPts = udRatio > 1.2 ? 5 : udRatio > 1.0 ? 3 : 0
udBearPts = udRatio < 0.8 ? 5 : udRatio < 1.0 ? 3 : 0

smoothBuzz = ta.sma(volBuzz, volScoreLookback)
buzzPts    = smoothBuzz > 30 ? 5 : smoothBuzz > 10 ? 3 : smoothBuzz > 0 ? 1 : 0

hveSince    = ta.barssince(isHVEBar)
hv1Since    = ta.barssince(isHV1Bar)
hveDecayPts = not na(hveSince) and hveSince <= hveDecayBars ?
     math.max(1, math.round(4.0 * (1.0 - hveSince / float(hveDecayBars)))) : 0
hv1DecayPts = not na(hv1Since) and hv1Since <= hveDecayBars ?
     math.max(1, math.round(3.0 * (1.0 - hv1Since / float(hveDecayBars)))) : 0
hvEventPts  = math.max(hveDecayPts, hv1DecayPts)

bullHVCount = math.sum(highVolume and isBullCandle ? 1 : 0, volScoreLookback)
bearHVCount = math.sum(highVolume and isBearCandle ? 1 : 0, volScoreLookback)
bullHVPts   = bullHVCount >= 2 ? 3 : bullHVCount >= 1 ? 2 : 0
bearHVPts   = bearHVCount >= 2 ? 3 : bearHVCount >= 1 ? 2 : 0

bullVolSetup = udBullPts + buzzPts + hvEventPts + bullHVPts
bearVolSetup = udBearPts + buzzPts + hvEventPts + bearHVPts

// TREND CONTINUATION MODE: directional volume pressure + ADX strength + RS
// Rewards the background conditions that sustain a trend, not a single spike day
// Max 20 pts to match the Setup Mode volume ceiling
bullTrendMom = (bullUdStrong    ? 7 : udRatio > 1.0 ? 4 : 0) +   // U/D confirms bull pressure
               (adxStrong       ? 6 : adxMod ? 3 : 0) +           // ADX shows trend strength
               (v6RsScore >= 2  ? 4 : v6RsScore == 1 ? 2 : 0) +   // outperforming benchmarks
               (smoothBuzz > 0  ? 3 : 0)                           // not in a volume drought
bearTrendMom = (bearUdStrong    ? 7 : udRatio < 1.0 ? 4 : 0) +
               (adxStrong       ? 6 : adxMod ? 3 : 0) +
               (v6RsScore == 0  ? 4 : v6RsScore == 1 ? 2 : 0) +   // lagging = bear pressure
               (smoothBuzz > 0  ? 3 : 0)

bullVolumePts = isBullTrendRegime ? bullTrendMom : bullVolSetup
bearVolumePts = isBearTrendRegime ? bearTrendMom : bearVolSetup

// ── MOMENTUM (same both modes) ────────────────────────────────────────────────
bullMomentumPts = (momScore > 60 ? 4 : 0) + (momRsi > 50 ? 3 : 0) + (williamsR > williamsR[1] ? 3 : 0)
bearMomentumPts = (momScore < 40 ? 4 : 0) + (momRsi < 50 ? 3 : 0) + (williamsR < williamsR[1] ? 3 : 0)

// ── RELATIVE STRENGTH (same both modes) ───────────────────────────────────────
rsPts = (v6Rs1 > 0 ? 3 : 0) + (v6Rs2 > 0 ? 3 : 0) + (v6Rs3 > 0 ? 4 : 0)

// ── CANDLESTICK (same both modes) ────────────────────────────────────────────
bullCandlePts = (bullWickReject ? 2 : 0) + (bullFailedBreakdown ? 2 : 0) + (bullMicroConfirm ? 1 : 0)
bearCandlePts = (bearWickReject ? 2 : 0) + (bearFailedBreakout ? 2 : 0) + (bearMicroConfirm ? 1 : 0)

// ── TOTALS ────────────────────────────────────────────────────────────────────
bullQualityScore = bullTrendPts + bullStructurePts + bullLiquidityPts + bullVolumePts + bullMomentumPts + rsPts + bullCandlePts
bearQualityScore = bearTrendPts + bearStructurePts + bearLiquidityPts + bearVolumePts + bearMomentumPts + rsPts + bearCandlePts

isBullQuality = bullQualityScore >= bearQualityScore

qTrend     = isBullQuality ? bullTrendPts     : bearTrendPts
qStructure = isBullQuality ? bullStructurePts : bearStructurePts
qLiquidity = isBullQuality ? bullLiquidityPts : bearLiquidityPts
qVolume    = isBullQuality ? bullVolumePts    : bearVolumePts
qMomentum  = isBullQuality ? bullMomentumPts  : bearMomentumPts
qRS        = rsPts
qCandle    = isBullQuality ? bullCandlePts    : bearCandlePts
qTotal     = isBullQuality ? bullQualityScore : bearQualityScore
qBias      = isBullQuality ? "Bull Quality"   : "Bear Quality"

// Regime label shown in dashboard so user knows which mode is active
qMode      = isBullTrendRegime ? "Trend Mode 🟢" : isBearTrendRegime ? "Trend Mode 🔴" : "Setup Mode"

qLabel = qTotal >= 85 ? "A+ Setup" : qTotal >= 75 ? "Good Setup" : qTotal >= 60 ? "Watchlist" : qTotal >= 45 ? "Weak" : "Avoid"
qColor = qTotal >= 85 ? color.lime : qTotal >= 75 ? color.green : qTotal >= 60 ? color.orange : color.red

// Sub-score labels also switch in trend mode so the dashboard column header
// tells the user what each row actually measures
liqLabel = (isBullQuality and isBullTrendRegime) or (not isBullQuality and isBearTrendRegime) ? "Trend Health" : "Liquidity"
volLabel  = (isBullQuality and isBullTrendRegime) or (not isBullQuality and isBearTrendRegime) ? "Trend Mom."   : "Volume"

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARDS
// ══════════════════════════════════════════════════════════════════════════════

trendStr(t) => t == 1 ? "Bullish" : t == -1 ? "Bearish" : "Neutral"
trendCol(t) => t == 1 ? bullColor : t == -1 ? bearColor : neutralColor

dashTxt = size.tiny

pdColor     = pdStatus == "Premium" ? bearColor : pdStatus == "Discount" ? bullColor : neutralColor
hvStatus    = isHVEBar ? "HVE" : isHV1Bar ? "HV1" : "None"
hvColor     = isHVEBar ? color.yellow : isHV1Bar ? color.orange : neutralColor
revStatus   = bullRevSignal ? "Bull " + str.tostring(bullRevScore) : bearRevSignal ? "Bear " + str.tostring(bearRevScore) : "None"
revColor    = bullRevSignal ? revBullColor : bearRevSignal ? revBearColor : neutralColor
momLabel    = momScore >= 70 ? "Strong Bull" : momScore <= 30 ? "Strong Bear" : momScore > 50 ? "Mild Bull" : momScore < 50 ? "Mild Bear" : "Neutral"
rsiColor    = momRsi >= rsiOverbought ? bearColor : momRsi <= rsiOversold ? bullColor : momRsi > 50 ? bullColor : bearColor
wprColor    = williamsR <= wprOversold ? bullColor : williamsR >= wprOverbought ? bearColor : neutralColor
corrColor   = dxyCorr > 0 ? bullColor : bearColor
hvStatColor = hvStat > 50 ? bearColor : hvStat > 20 ? neutralColor : bullColor
v6RegimeColor = v6Regime == "Bull Trend" ? bullColor : v6Regime == "Bear Trend" ? bearColor : v6Regime == "Compression" ? color.orange : v6Regime == "Expansion" ? color.teal : neutralColor
v6RsColor   = v6RsScore == 3 ? color.lime : v6RsScore == 2 ? color.green : v6RsScore == 1 ? color.orange : color.red

var table dash  = na
var table qDash = na

if showDash and barstate.islast
    if na(dash)
        dash := table.new(dashPos, 2, 22, bgcolor = color.new(chart.bg_color, 10), border_width = 1, border_color = color.new(color.gray, 55), frame_width = 1, frame_color = color.new(color.gray, 55))

    table.cell(dash, 0, 0, "SMC Pro V6", text_size = dashTxt, text_color = color.white, bgcolor = color.black)
    table.cell(dash, 1, 0, "Dashboard", text_size = dashTxt, text_color = color.white, bgcolor = color.black)

    table.cell(dash, 0, 1, "SMC 1H / 4H / 1D", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 1, trendStr(trend1H) + " / " + trendStr(trend4H) + " / " + trendStr(trend1D), text_size = dashTxt, text_color = color.black, bgcolor = color.new(neutralColor, 70))

    table.cell(dash, 0, 2, "Regime", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 2, v6Regime, text_size = dashTxt, text_color = color.black, bgcolor = color.new(v6RegimeColor, 50))

    table.cell(dash, 0, 3, "Momentum", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 3, str.tostring(momScore) + "/100 " + momLabel, text_size = dashTxt, text_color = color.black, bgcolor = color.new(scoreColor, 50))

    table.cell(dash, 0, 4, "Rev Signal", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 4, revStatus, text_size = dashTxt, text_color = color.black, bgcolor = color.new(revColor, 50))

    table.cell(dash, 0, 5, "Rev Score B/S", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 5, str.tostring(bullRevScore) + " / " + str.tostring(bearRevScore), text_size = dashTxt, text_color = color.black, bgcolor = color.new(neutralColor, 70))

    table.cell(dash, 0, 6, "Premium / Discount", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 6, pdStatus, text_size = dashTxt, text_color = color.black, bgcolor = color.new(pdColor, 55))

    table.cell(dash, 0, 7, "HVE / HV1", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 7, hvStatus, text_size = dashTxt, text_color = color.black, bgcolor = color.new(hvColor, 50))

    table.cell(dash, 0, 8, "RSI", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 8, str.tostring(momRsi, "#.##"), text_size = dashTxt, text_color = color.black, bgcolor = color.new(rsiColor, 50))

    table.cell(dash, 0, 9, "Williams %R", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 9, str.tostring(williamsR, "#.##"), text_size = dashTxt, text_color = color.black, bgcolor = color.new(wprColor, 50))

    table.cell(dash, 0, 10, "U/D Vol", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 10, str.tostring(udRatio, "#.##"), text_size = dashTxt, text_color = color.black, bgcolor = color.new(udColor, 50))

    table.cell(dash, 0, 11, "Vol Buzz", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 11, volBuzzStr, text_size = dashTxt, text_color = color.black, bgcolor = color.new(buzzColor, 50))

    table.cell(dash, 0, 12, "Avg $ Vol", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 12, avgDolVolStr, text_size = dashTxt, text_color = color.black, bgcolor = color.new(neutralColor, 70))

    table.cell(dash, 0, 13, "RS Rank", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 13, v6RsLabel, text_size = dashTxt, text_color = color.black, bgcolor = color.new(v6RsColor, 50))

    table.cell(dash, 0, 14, "RS SPY/QQQ/Sector", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 14, str.tostring(v6Rs1 * 100, "#.##") + "% / " + str.tostring(v6Rs2 * 100, "#.##") + "% / " + str.tostring(v6Rs3 * 100, "#.##") + "%", text_size = dashTxt, text_color = color.black, bgcolor = color.new(v6RsColor, 60))

    table.cell(dash, 0, 15, "DXY Corr", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 15, str.tostring(dxyCorr, "#.##"), text_size = dashTxt, text_color = color.black, bgcolor = color.new(corrColor, 50))

    table.cell(dash, 0, 16, "HV30", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 16, str.tostring(hvStat, "#.##") + "%", text_size = dashTxt, text_color = color.black, bgcolor = color.new(hvStatColor, 50))

    table.cell(dash, 0, 17, "Trend Bias", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 17, trend1D == 1 ? "Bullish" : trend1D == -1 ? "Bearish" : "Neutral", text_size = dashTxt, text_color = color.black, bgcolor = color.new(trendCol(trend1D), 50))

    table.cell(dash, 0, 18, "Bull Quality", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 18, str.tostring(bullQualityScore) + "/100", text_size = dashTxt, text_color = color.black, bgcolor = color.new(bullColor, 60))

    table.cell(dash, 0, 19, "Bear Quality", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 19, str.tostring(bearQualityScore) + "/100", text_size = dashTxt, text_color = color.black, bgcolor = color.new(bearColor, 60))

    table.cell(dash, 0, 20, "Primary Quality", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 20, qBias, text_size = dashTxt, text_color = color.black, bgcolor = color.new(qColor, 55))

    table.cell(dash, 0, 21, "Setup Grade", text_size = dashTxt, text_color = color.white, bgcolor = color.black)
    table.cell(dash, 1, 21, qLabel, text_size = dashTxt, text_color = color.white, bgcolor = qColor)

    if na(qDash)
        qDash := table.new(position.bottom_right, 2, 10, bgcolor = color.new(chart.bg_color, 10), border_width = 1, border_color = color.new(color.gray, 55), frame_width = 1, frame_color = color.new(color.gray, 55))

    table.cell(qDash, 0, 0, qBias, text_size = dashTxt, text_color = color.white, bgcolor = color.black)
    table.cell(qDash, 1, 0, str.tostring(qTotal) + "/100", text_size = dashTxt, text_color = color.white, bgcolor = qColor)

    table.cell(qDash, 0, 1, "Trend", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(qDash, 1, 1, str.tostring(qTrend) + "/20", text_size = dashTxt, text_color = color.black, bgcolor = color.new(qTrend >= 15 ? color.green : qTrend >= 8 ? color.orange : color.red, 60))

    table.cell(qDash, 0, 2, "Structure", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(qDash, 1, 2, str.tostring(qStructure) + "/20", text_size = dashTxt, text_color = color.black, bgcolor = color.new(qStructure >= 15 ? color.green : qStructure >= 8 ? color.orange : color.red, 60))

    table.cell(qDash, 0, 3, liqLabel, text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(qDash, 1, 3, str.tostring(qLiquidity) + "/15", text_size = dashTxt, text_color = color.black, bgcolor = color.new(qLiquidity >= 10 ? color.green : qLiquidity >= 5 ? color.orange : color.red, 60))

    table.cell(qDash, 0, 4, volLabel, text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(qDash, 1, 4, str.tostring(qVolume) + "/20", text_size = dashTxt, text_color = color.black, bgcolor = color.new(qVolume >= 15 ? color.green : qVolume >= 8 ? color.orange : color.red, 60))

    table.cell(qDash, 0, 5, "Momentum", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(qDash, 1, 5, str.tostring(qMomentum) + "/10", text_size = dashTxt, text_color = color.black, bgcolor = color.new(qMomentum >= 7 ? color.green : qMomentum >= 4 ? color.orange : color.red, 60))

    table.cell(qDash, 0, 6, "Relative Str.", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(qDash, 1, 6, str.tostring(qRS) + "/10", text_size = dashTxt, text_color = color.black, bgcolor = color.new(qRS >= 7 ? color.green : qRS >= 3 ? color.orange : color.red, 60))

    table.cell(qDash, 0, 7, "Candlestick", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(qDash, 1, 7, str.tostring(qCandle) + "/5", text_size = dashTxt, text_color = color.black, bgcolor = color.new(qCandle >= 4 ? color.green : qCandle >= 2 ? color.orange : color.red, 60))

    table.cell(qDash, 0, 8, "Score Mode", text_size = dashTxt, text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(qDash, 1, 8, qMode, text_size = dashTxt, text_color = color.black, bgcolor = color.new(isBullTrendRegime or isBearTrendRegime ? bullColor : neutralColor, 60))

    table.cell(qDash, 0, 9, "Grade", text_size = dashTxt, text_color = color.white, bgcolor = color.black)
    table.cell(qDash, 1, 9, qLabel, text_size = dashTxt, text_color = color.white, bgcolor = qColor)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullRevSignal, "Early Bull Reversal", "SMC Pro V6: Early Bull Reversal signal fired")
alertcondition(bearRevSignal, "Early Bear Reversal", "SMC Pro V6: Early Bear Reversal signal fired")
alertcondition(bullStrongRev, "Strong Bull Reversal", "SMC Pro V6: Strong Bull Reversal signal fired")
alertcondition(bearStrongRev, "Strong Bear Reversal", "SMC Pro V6: Strong Bear Reversal signal fired")
alertcondition(bullBreakout, "Bull CHoCH", "SMC Pro V6: Bull Change of Character")
alertcondition(bearBreakout, "Bear CHoCH", "SMC Pro V6: Bear Change of Character")
````
