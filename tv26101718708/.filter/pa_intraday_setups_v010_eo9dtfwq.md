# PA Intraday Setups v0.1.0

- url: https://www.tradingview.com/script/eo9DTFWq-PA-Intraday-Setups-v0-1-0/
- type: indicator
- pine_id: PUB;5c199b595d67449da428a985a59312ef
- version: 1.0

## Description

# PA Intraday Setups — Publication Description

---

## OVERVIEW

PA Intraday Setups is a heuristic execution assistant for discretionary intraday
price-action traders. Instead of generating a single buy/sell arrow, it watches the
chart for eleven of the most common Brooks-style price-action setups and labels each
one as it confirms — so you can keep your eyes on structure and let the indicator
handle the pattern-recognition bookkeeping.

It is built around one idea: **context first, setup second.** The script continuously
classifies the market into trend / range / wide-channel / always-in context, and only
fires a setup when the context that setup requires is actually present. This mirrors
how a discretionary trader thinks — "what is the market doing right now, and is this a
setup I'm allowed to take?"

This is NOT a fully automated strategy and NOT a signal service. It is an
education-and-discipline tool: it shows you where a textbook setup exists, draws
suggested entry / stop / target guide lines, and stays silent everywhere else.

---

## WHAT IT DETECTS

The eleven setups are grouped exactly the way a price-action trader files them — by
order type and market context.

PART 1 — BREAKOUT SETUPS (stop entries beyond a signal bar)

1. TREND PULLBACK H2 / L2 — In a confirmed trend (and only after a strong breakout
   or tight channel, not inside a broad channel), a clean two-legged counter-trend
   pullback whose signal bar closes in the trend direction.

2. BREAK-FAIL-BREAK — A failed breakout that re-breaks the same level within a few
   bars (default 3). Confirms the breakout direction after trapping the first movers.

3. KEY-LEVEL STRUCTURE REVERSAL — A reversal off a key level that coincides with a
   recognizable structure: double top/bottom, wedge, head-and-shoulders, or an
   inside/outside-bar (OB/IB) signal bar.

PART 2 — LIMIT SETUPS (limit entries at a pre-marked price)

4. RANGE HIGH / LOW LIMIT FADE — Inside a balanced range, fade the prior high/low
   back toward the middle with a fixed risk.

5. WIDE-CHANNEL POINT 3 FADE — A counter-channel limit fade at the third touch
   ("Point 3") of a wide channel.

6. TREND 50% PULLBACK — In a strong trend, a limit entry at the 50% retrace of the
   most recent impulse leg, provided the pullback stays weak (no three consecutive
   strong counter-trend bars).

7. TRUE-BREAKOUT TRAPPED PULLBACK — After a genuine breakout holds, a with-trend
   limit entry on the retest that traps the counter-side. Requires a strong breakout
   bar AND a strong follow-through bar; dojis or weak bodies disqualify it.

PART 3 — ALWAYS-IN / STRONG-TREND SETUPS

8. L1 / H1 FAILURE — In an always-in trend, the first counter-trend attempt fails at
   the prior with-trend follow-through extreme.

9. THIRD-BAR FAILURE — A counter-trend attempt that fails to print a third
   consecutive counter-trend bar, faded in the trend direction.

10. EMA20 PULLBACK — The first pullback to the EMA in an always-in trend, entered
    with-trend near the moving average.

11. TREND BREAKOUT SCALP — A with-trend strong-body breakout bar (close beyond the
    50% mark) taken as a quick scalp with an ATR-based target.

The script also prints INVALIDATION and FORCED-EXIT labels (e.g. an H2 that turns
into a reversal bar, a 50%/trapped/EMA setup that breaks its premise, or three
consecutive counter-trend bars against an open trend) so you can see when a setup is
voided.

---

## CONTEXT LABELS

When enabled, the indicator drops a small label the moment the market context
changes, so you always know which "regime" you're in:

- CTX Range — balanced, mean-reverting range (use the Limit setups)
- CTX AI Long / CTX AI Short — always-in long/short, a strong directional regime
- CTX Wide Ch Up / CTX Wide Ch Dn — wide channel, where Point 3 fades live

---

## TRADE GUIDES

For each confirmed setup the script can draw three short guide lines projected to the
right:

- Entry (dotted) — the stop-order or limit price
- Stop (solid red) — the protective stop
- Target (dashed green) — a fixed reward based on the configurable RR or an ATR
  multiple

These are suggestions for visual reference only — they are not orders and do not
account for slippage, spread, or your own risk rules.

---

## SETTINGS

SESSION
- Optional trading session + timezone. When off, the script treats every bar as
  active and resets session stats daily.

GENERAL
- EMA length (default 20), ATR length (14), trend lookback, range/breakout lookback,
  pivot strength.

THRESHOLDS (the heart of the tool)
- Strong-bar body %, max entry-side tail %, doji body %, near-key/near-EMA buffers
  (in ATR), minimum trend move / closes-on-side / efficiency, range width & overlap,
  wide-channel width & overlap, break-fail-break window, trapped-pullback window,
  structure confirm window, impulse lookback, ATR scalp target multiple, default RR.
  Tighten these for fewer / cleaner signals; loosen for more.

MANUAL KEY LEVELS
- Up to four price levels you type in yourself (e.g. overnight high/low, a daily
  pivot). Setups that depend on "key levels" will respect these in addition to the
  auto-detected prior-session H/L/C, session open, range extremes, and EMA.

DISPLAY
- Toggle the EMA plot, context labels, trade guides, invalidation labels, range
  lines, and manual-level lines; set guide-line length.

SETUPS
- Independent on/off switch for each of the eleven setups, so you can run only the
  ones that fit your style.

---

## HOW TO USE

1. Add the indicator and pick your timeframe (designed for intraday — e.g. 1m–15m on
   index futures, FX, or liquid stocks).
2. Decide your context. Watch the CTX labels: trend regimes favor the breakout and
   always-in setups; range regimes favor the limit fades.
3. Mark your own key levels in the Manual Key Levels group — the quality of the
   key-level setups depends heavily on good levels, and no algorithm marks them as
   well as you do.
4. Turn off the setups you don't trade. Most traders do better with three or four
   setups than with all eleven.
5. Use the guide lines as a starting point, then size and place your real orders by
   your own risk plan.
6. Optionally create alerts — there is one alert per setup, plus aggregate "any long
   setup / any short setup / forced exit / invalid" alerts.

---

## IMPORTANT NOTES & LIMITATIONS

- This is an APPROXIMATION. Setups that a human reads from key levels, channels,
  wedges, head-and-shoulders and channel "Point 3" are estimated here using pivots,
  EMA/ATR context, prior ranges and your manual levels. It will sometimes label a
  setup you would skip, and skip one you would take.
- Labels confirm on bar close (`barstate.isconfirmed`). They do not repaint after a
  bar closes, but live bars can change until close.
- Thresholds are general-purpose defaults. Different instruments and timeframes need
  retuning — treat the Thresholds group as your edge, not a fixed recipe.
- No setup is a recommendation. Discretion, context, and risk management remain
  entirely yours.

---

## OPEN SOURCE

Published open-source under the Mozilla Public License 2.0. You are free to study,
fork and improve it. If you build on it, a link back is appreciated.

---

## DISCLAIMER

This script is for educational and informational purposes only. It is not financial
advice and not a recommendation to buy or sell any instrument. Trading involves
substantial risk of loss. Past behavior of any setup does not guarantee future
results. Test thoroughly on a demo account and trade your own plan.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © WuDaiChuan
//
// PA Intraday Setups
// Version: v0.1.0
//
// A heuristic execution assistant for discretionary intraday price-action trading.
// It flags eleven common Brooks-style setups (trend pullbacks, break-fail-break,
// key-level reversals, range/limit fades, channel Point 3, 50% pullbacks, trapped
// pullbacks, L1/H1 and third-bar failures, EMA pullbacks, and trend-breakout scalps)
// and is not a fully automated trader. Setups that depend on key levels, channels,
// wedges, head-and-shoulders, or Point 3 are approximated with pivots, EMA/ATR
// context, prior ranges, and optional manual levels. Educational tool only; nothing
// here is financial advice.

indicator("PA Intraday Setups v0.1.0", overlay=true, max_labels_count=500, max_lines_count=500)

// -------------------------
// Inputs
// -------------------------
groupSession = "Session"
useSession = input.bool(false, "Use trading session", group=groupSession)
tradeSession = input.session("0930-1600", "Trading session", group=groupSession)
sessionTz = input.string("America/New_York", "Session timezone", group=groupSession)

groupGeneral = "General"
emaLen = input.int(20, "EMA length", minval=1, group=groupGeneral)
atrLen = input.int(14, "ATR length", minval=1, group=groupGeneral)
trendLookback = input.int(20, "Trend lookback", minval=5, maxval=200, group=groupGeneral)
rangeLookback = input.int(20, "Range / breakout lookback", minval=5, maxval=200, group=groupGeneral)
pivotLen = input.int(3, "Pivot strength", minval=1, maxval=10, group=groupGeneral)

groupThresholds = "Thresholds"
strongBodyPct = input.float(0.50, "Strong bar body percent", minval=0.10, maxval=0.95, step=0.05, group=groupThresholds)
maxEntryTailPct = input.float(0.35, "Max entry-side tail percent", minval=0.05, maxval=0.80, step=0.05, group=groupThresholds)
dojiBodyPct = input.float(0.25, "Doji / weak body percent", minval=0.05, maxval=0.60, step=0.05, group=groupThresholds)
nearKeyAtr = input.float(0.18, "Near key level buffer, ATR", minval=0.01, step=0.01, group=groupThresholds)
nearEmaAtr = input.float(0.18, "Near EMA buffer, ATR", minval=0.01, step=0.01, group=groupThresholds)
minTrendMoveAtr = input.float(1.25, "Min trend move, ATR", minval=0.10, step=0.05, group=groupThresholds)
minTrendSidePct = input.float(0.62, "Min closes on trend side", minval=0.30, maxval=1.00, step=0.05, group=groupThresholds)
minTrendEfficiency = input.float(0.35, "Min trend efficiency", minval=0.05, maxval=1.00, step=0.05, group=groupThresholds)
rangeMaxAtr = input.float(3.00, "Range max width, ATR", minval=0.25, step=0.25, group=groupThresholds)
rangeOverlapMin = input.float(0.55, "Range min overlap percent", minval=0.10, maxval=1.00, step=0.05, group=groupThresholds)
wideChannelMinAtr = input.float(3.00, "Wide channel min width, ATR", minval=0.50, step=0.25, group=groupThresholds)
wideChannelOverlapMin = input.float(0.35, "Wide channel min overlap percent", minval=0.10, maxval=1.00, step=0.05, group=groupThresholds)
bfbMaxBars = input.int(3, "Break-fail-break max bars", minval=1, maxval=10, group=groupThresholds)
trapMaxBars = input.int(25, "Trapped pullback max bars", minval=2, maxval=100, group=groupThresholds)
structConfirmBars = input.int(20, "Structure reversal confirm window", minval=2, maxval=100, group=groupThresholds)
impulseLookback = input.int(12, "50 percent pullback impulse lookback", minval=3, maxval=100, group=groupThresholds)
atrTargetMult = input.float(1.00, "ATR scalp target multiple", minval=0.10, step=0.10, group=groupThresholds)
defaultRR = input.float(1.00, "Default guide RR", minval=0.25, step=0.25, group=groupThresholds)

groupManual = "Manual Key Levels"
useLevel1 = input.bool(false, "Use manual level 1", group=groupManual)
level1 = input.float(0.0, "Manual level 1", group=groupManual)
useLevel2 = input.bool(false, "Use manual level 2", group=groupManual)
level2 = input.float(0.0, "Manual level 2", group=groupManual)
useLevel3 = input.bool(false, "Use manual level 3", group=groupManual)
level3 = input.float(0.0, "Manual level 3", group=groupManual)
useLevel4 = input.bool(false, "Use manual level 4", group=groupManual)
level4 = input.float(0.0, "Manual level 4", group=groupManual)

groupDisplay = "Display"
showEma = input.bool(true, "Plot EMA", group=groupDisplay)
showContext = input.bool(true, "Show context labels", group=groupDisplay)
showTradeGuides = input.bool(true, "Show entry / stop / target guides", group=groupDisplay)
guideBars = input.int(8, "Guide line length", minval=1, maxval=50, group=groupDisplay)
showInvalid = input.bool(true, "Show invalid / forced exit labels", group=groupDisplay)
showRangeLines = input.bool(false, "Show range high / low", group=groupDisplay)
showManualLevels = input.bool(true, "Show manual levels", group=groupDisplay)

groupSetups = "Setups"
showH2L2 = input.bool(true, "1. Trend pullback H2 / L2", group=groupSetups)
showBfb = input.bool(true, "2. Break-fail-break", group=groupSetups)
showKeyRev = input.bool(true, "3. Key-level structure reversal", group=groupSetups)
showRangeFade = input.bool(true, "4. Range high / low limit fade", group=groupSetups)
showPoint3 = input.bool(true, "5. Wide-channel Point 3 fade", group=groupSetups)
showPullback50 = input.bool(true, "6. Trend 50 percent pullback", group=groupSetups)
showTrap = input.bool(true, "7. True-breakout trapped pullback", group=groupSetups)
showL1Fail = input.bool(true, "8. L1 / H1 failure limit", group=groupSetups)
showThirdFailure = input.bool(true, "9. Third-bar failure", group=groupSetups)
showEmaPullback = input.bool(true, "10. EMA20 pullback", group=groupSetups)
showTrendScalp = input.bool(true, "11. Trend breakout scalp", group=groupSetups)

// -------------------------
// Core calculations
// -------------------------
tick = syminfo.mintick
ema = ta.ema(close, emaLen)
atr = ta.atr(atrLen)
keyBuffer = atr * nearKeyAtr
emaBuffer = atr * nearEmaAtr

barRange = math.max(high - low, tick)
body = math.abs(close - open)
bodyPct = body / barRange
upperTail = high - math.max(open, close)
lowerTail = math.min(open, close) - low

bull = close > open
bear = close < open
doji = bodyPct <= dojiBodyPct
strongBull = bull and bodyPct >= strongBodyPct and upperTail <= barRange * maxEntryTailPct
strongBear = bear and bodyPct >= strongBodyPct and lowerTail <= barRange * maxEntryTailPct
bullRevBar = bull and close >= low + barRange * 0.60 and (strongBull or lowerTail >= barRange * 0.30 or close > high[1])
bearRevBar = bear and close <= high - barRange * 0.60 and (strongBear or upperTail >= barRange * 0.30 or close < low[1])

overlap = high >= low[1] and low <= high[1]
overlapPct = ta.sma(overlap ? 1.0 : 0.0, rangeLookback)
rangeHigh = ta.highest(high[1], rangeLookback)
rangeLow = ta.lowest(low[1], rangeLookback)
rangeWidth = math.max(rangeHigh - rangeLow, tick)
rangeEfficiency = math.abs(close - close[rangeLookback]) / math.max(ta.highest(high, rangeLookback) - ta.lowest(low, rangeLookback), tick)

emaSlopeAtr = (ema - ema[trendLookback]) / math.max(atr, tick)
trendBarsAbove = ta.sma(close > ema ? 1.0 : 0.0, trendLookback)
trendBarsBelow = ta.sma(close < ema ? 1.0 : 0.0, trendLookback)
trendMoveAtr = (close - close[trendLookback]) / math.max(atr, tick)
trendUp = emaSlopeAtr > 0 and trendMoveAtr >= minTrendMoveAtr and trendBarsAbove >= minTrendSidePct and rangeEfficiency >= minTrendEfficiency
trendDown = emaSlopeAtr < 0 and trendMoveAtr <= -minTrendMoveAtr and trendBarsBelow >= minTrendSidePct and rangeEfficiency >= minTrendEfficiency
strongTrendUp = trendUp and close > ema and strongBull
strongTrendDown = trendDown and close < ema and strongBear
rangeContext = rangeWidth <= atr * rangeMaxAtr and overlapPct >= rangeOverlapMin and rangeEfficiency <= 0.45
wideChannelUp = trendUp and rangeWidth >= atr * wideChannelMinAtr and overlapPct >= wideChannelOverlapMin
wideChannelDown = trendDown and rangeWidth >= atr * wideChannelMinAtr and overlapPct >= wideChannelOverlapMin
alwaysLong = trendUp and close > ema and not rangeContext and (math.abs(trendMoveAtr) >= minTrendMoveAtr or ta.sma(strongBull ? 1.0 : 0.0, trendLookback) >= 0.20)
alwaysShort = trendDown and close < ema and not rangeContext and (math.abs(trendMoveAtr) >= minTrendMoveAtr or ta.sma(strongBear ? 1.0 : 0.0, trendLookback) >= 0.20)

bearStreak = nz(ta.barssince(not bear), 10000)
bullStreak = nz(ta.barssince(not bull), 10000)
strongBearStreak = nz(ta.barssince(not strongBear), 10000)
strongBullStreak = nz(ta.barssince(not strongBull), 10000)
threeBear = bear and bear[1] and bear[2]
threeBull = bull and bull[1] and bull[2]

// -------------------------
// Session state
// -------------------------
inSession = useSession ? not na(time(timeframe.period, tradeSession, sessionTz)) : true
newSession = useSession ? (inSession and not inSession[1]) : (barstate.isfirst or ta.change(time("D")) != 0)
activeBar = inSession

var int sessionBar = 0
var float sessionOpen = na
var float sessionHigh = na
var float sessionLow = na
var float sessionClose = na
var float prevSessionHigh = na
var float prevSessionLow = na
var float prevSessionClose = na

if newSession
    prevSessionHigh := sessionHigh
    prevSessionLow := sessionLow
    prevSessionClose := sessionClose
    sessionBar := 1
    sessionOpen := open
    sessionHigh := high
    sessionLow := low
else if activeBar
    sessionBar += 1
    sessionHigh := math.max(nz(sessionHigh, high), high)
    sessionLow := math.min(nz(sessionLow, low), low)

if activeBar
    sessionClose := close

// -------------------------
// Helpers
// -------------------------
f_near(_a, _b, _tol) =>
    not na(_a) and not na(_b) and math.abs(_a - _b) <= _tol

f_touches_level(_level, _lo, _hi, _tol) =>
    not na(_level) and _lo <= _level + _tol and _hi >= _level - _tol

f_manual_touch(_lo, _hi, _tol) =>
    (useLevel1 and f_touches_level(level1, _lo, _hi, _tol)) or (useLevel2 and f_touches_level(level2, _lo, _hi, _tol)) or (useLevel3 and f_touches_level(level3, _lo, _hi, _tol)) or (useLevel4 and f_touches_level(level4, _lo, _hi, _tol))

f_mark(_cond, _isLong, _txt, _col) =>
    if _cond and barstate.isconfirmed
        label.new(
             bar_index,
             _isLong ? low : high,
             _txt,
             style=_isLong ? label.style_label_up : label.style_label_down,
             color=_col,
             textcolor=color.white,
             size=size.tiny)

f_draw_guides(_cond, _entry, _stop, _target) =>
    if showTradeGuides and _cond and barstate.isconfirmed and not na(_entry) and not na(_stop) and not na(_target)
        line.new(bar_index, _entry, bar_index + guideBars, _entry, color=color.rgb(17, 24, 39), width=1, style=line.style_dotted)
        line.new(bar_index, _stop, bar_index + guideBars, _stop, color=color.rgb(185, 28, 28), width=1, style=line.style_solid)
        line.new(bar_index, _target, bar_index + guideBars, _target, color=color.rgb(22, 101, 52), width=1, style=line.style_dashed)

f_breakout_guides(_cond, _isLong, _rr) =>
    if showTradeGuides and _cond and barstate.isconfirmed
        entry = _isLong ? high + tick : low - tick
        stop = _isLong ? low - tick : high + tick
        risk = math.max(math.abs(entry - stop), tick)
        target = _isLong ? entry + risk * _rr : entry - risk * _rr
        f_draw_guides(true, entry, stop, target)

f_limit_guides(_cond, _isLong, _entry, _stop, _rr) =>
    if showTradeGuides and _cond and barstate.isconfirmed
        risk = math.max(math.abs(_entry - _stop), tick)
        target = _isLong ? _entry + risk * _rr : _entry - risk * _rr
        f_draw_guides(true, _entry, _stop, target)

nearPrevHlc = f_touches_level(prevSessionHigh, low, high, keyBuffer) or f_touches_level(prevSessionLow, low, high, keyBuffer) or f_touches_level(prevSessionClose, low, high, keyBuffer)
nearSessionOpen = f_touches_level(sessionOpen, low, high, keyBuffer)
nearRangeExtreme = f_touches_level(rangeHigh, low, high, keyBuffer) or f_touches_level(rangeLow, low, high, keyBuffer)
nearEma = f_touches_level(ema, low, high, emaBuffer)
nearManual = f_manual_touch(low, high, keyBuffer)
nearKey = nearPrevHlc or nearSessionOpen or nearRangeExtreme or nearEma or nearManual

plot(showEma ? ema : na, "EMA", color=color.orange, linewidth=2)
plot(showRangeLines ? rangeHigh : na, "Range high", color=color.new(color.red, 70), style=plot.style_linebr)
plot(showRangeLines ? rangeLow : na, "Range low", color=color.new(color.green, 70), style=plot.style_linebr)
plot(showManualLevels and useLevel1 ? level1 : na, "Manual level 1", color=color.new(color.blue, 65), style=plot.style_linebr)
plot(showManualLevels and useLevel2 ? level2 : na, "Manual level 2", color=color.new(color.blue, 65), style=plot.style_linebr)
plot(showManualLevels and useLevel3 ? level3 : na, "Manual level 3", color=color.new(color.blue, 65), style=plot.style_linebr)
plot(showManualLevels and useLevel4 ? level4 : na, "Manual level 4", color=color.new(color.blue, 65), style=plot.style_linebr)

longColor = color.rgb(20, 83, 45)
shortColor = color.rgb(127, 29, 29)
limitLongColor = color.rgb(15, 118, 110)
limitShortColor = color.rgb(147, 51, 81)
exitColor = color.rgb(217, 119, 6)
invalidColor = color.rgb(75, 85, 99)

// -------------------------
// Pivots and structures
// -------------------------
pl = ta.pivotlow(low, pivotLen, pivotLen)
ph = ta.pivothigh(high, pivotLen, pivotLen)
plFound = not na(pl)
phFound = not na(ph)
pl0 = ta.valuewhen(plFound, pl, 0)
pl1 = ta.valuewhen(plFound, pl, 1)
pl2 = ta.valuewhen(plFound, pl, 2)
ph0 = ta.valuewhen(phFound, ph, 0)
ph1 = ta.valuewhen(phFound, ph, 1)
ph2 = ta.valuewhen(phFound, ph, 2)

doubleBottomStruct = plFound and not na(pl1) and f_near(pl0, pl1, atr * 0.35)
doubleTopStruct = phFound and not na(ph1) and f_near(ph0, ph1, atr * 0.35)
wedgeDownStruct = plFound and not na(pl2) and pl0 < pl1 and pl1 < pl2
wedgeUpStruct = phFound and not na(ph2) and ph0 > ph1 and ph1 > ph2
hsBottomStruct = plFound and not na(pl2) and pl1 < pl0 and pl1 < pl2 and f_near(pl0, pl2, atr * 0.50)
hsTopStruct = phFound and not na(ph2) and ph1 > ph0 and ph1 > ph2 and f_near(ph0, ph2, atr * 0.50)
insideBar = high < high[1] and low > low[1]
outsideBar = high > high[1] and low < low[1]

// -------------------------
// 1. Trend pullback H2 / L2
// -------------------------
twoLegDown = low < low[2] and high[1] > high[2]
twoLegUp = high > high[2] and low[1] < low[2]
cleanLongPullback = ta.highest(strongBear ? 1.0 : 0.0, 4) < 0.5
cleanShortPullback = ta.highest(strongBull ? 1.0 : 0.0, 4) < 0.5
h2Long = activeBar and showH2L2 and trendUp[1] and not wideChannelUp and twoLegDown and bull and cleanLongPullback
l2Short = activeBar and showH2L2 and trendDown[1] and not wideChannelDown and twoLegUp and bear and cleanShortPullback
h2InvalidLong = activeBar and showInvalid and showH2L2 and trendUp[1] and twoLegDown and bear
l2InvalidShort = activeBar and showInvalid and showH2L2 and trendDown[1] and twoLegUp and bull

// -------------------------
// 2. Break-fail-break
// -------------------------
firstBreakLong = activeBar and close > rangeHigh and open <= rangeHigh and bodyPct >= strongBodyPct and rangeWidth >= atr * 0.75
firstBreakShort = activeBar and close < rangeLow and open >= rangeLow and bodyPct >= strongBodyPct and rangeWidth >= atr * 0.75

var int bfbLongState = 0
var int bfbShortState = 0
var int bfbLongFirstBar = na
var int bfbShortFirstBar = na
var float bfbLongLevel = na
var float bfbShortLevel = na

bfbLong = false
bfbShort = false

if firstBreakLong
    bfbLongState := 1
    bfbLongFirstBar := bar_index
    bfbLongLevel := rangeHigh

if firstBreakShort
    bfbShortState := 1
    bfbShortFirstBar := bar_index
    bfbShortLevel := rangeLow

if bfbLongState > 0 and not na(bfbLongFirstBar) and bar_index - bfbLongFirstBar > bfbMaxBars
    bfbLongState := 0
if bfbShortState > 0 and not na(bfbShortFirstBar) and bar_index - bfbShortFirstBar > bfbMaxBars
    bfbShortState := 0

if bfbLongState == 1 and bar_index > bfbLongFirstBar and close < bfbLongLevel
    bfbLongState := 2
if bfbShortState == 1 and bar_index > bfbShortFirstBar and close > bfbShortLevel
    bfbShortState := 2

if bfbLongState == 2 and bar_index > bfbLongFirstBar and bar_index - bfbLongFirstBar <= bfbMaxBars and close > bfbLongLevel and strongBull
    bfbLong := showBfb
    bfbLongState := 0
if bfbShortState == 2 and bar_index > bfbShortFirstBar and bar_index - bfbShortFirstBar <= bfbMaxBars and close < bfbShortLevel and strongBear
    bfbShort := showBfb
    bfbShortState := 0

// -------------------------
// 3. Key-level structure reversal breakout
// -------------------------
var int lastBullStructBar = na
var int lastBearStructBar = na
var float lastBullStructLevel = na
var float lastBearStructLevel = na

if doubleBottomStruct or wedgeDownStruct or hsBottomStruct
    lastBullStructBar := bar_index - pivotLen
    lastBullStructLevel := pl0
if doubleTopStruct or wedgeUpStruct or hsTopStruct
    lastBearStructBar := bar_index - pivotLen
    lastBearStructLevel := ph0

obIbLong = nearKey and (insideBar[1] or outsideBar[1]) and bullRevBar and close > high[1]
obIbShort = nearKey and (insideBar[1] or outsideBar[1]) and bearRevBar and close < low[1]
structLongReady = not na(lastBullStructBar) and bar_index > lastBullStructBar and bar_index - lastBullStructBar <= structConfirmBars
structShortReady = not na(lastBearStructBar) and bar_index > lastBearStructBar and bar_index - lastBearStructBar <= structConfirmBars
keyRevLong = activeBar and showKeyRev and nearKey and ((structLongReady and (strongBull or bullRevBar) and close > high[1]) or obIbLong or (h2Long and nearKey))
keyRevShort = activeBar and showKeyRev and nearKey and ((structShortReady and (strongBear or bearRevBar) and close < low[1]) or obIbShort or (l2Short and nearKey))

if keyRevLong
    lastBullStructBar := na
if keyRevShort
    lastBearStructBar := na

// -------------------------
// 4. Range high / low limit fade
// -------------------------
rangeFadeLong = activeBar and showRangeFade and rangeContext and low <= rangeLow + keyBuffer and (bullRevBar or close > rangeLow)
rangeFadeShort = activeBar and showRangeFade and rangeContext and high >= rangeHigh - keyBuffer and (bearRevBar or close < rangeHigh)

// -------------------------
// 5. Wide-channel Point 3 limit fade
// -------------------------
point3Long = activeBar and showPoint3 and wideChannelDown[pivotLen] and wedgeDownStruct and nearKey
point3Short = activeBar and showPoint3 and wideChannelUp[pivotLen] and wedgeUpStruct and nearKey

// -------------------------
// 6. Trend 50 percent pullback
// -------------------------
impulseHigh = ta.highest(high, impulseLookback)
impulseLow = ta.lowest(low, impulseLookback)
impulseMid = (impulseHigh + impulseLow) / 2.0
weakPullbackLong = bearStreak <= 3 and strongBearStreak < 3
weakPullbackShort = bullStreak <= 3 and strongBullStreak < 3
pullback50Long = activeBar and showPullback50 and trendUp and not rangeContext and f_touches_level(impulseMid, low, high, keyBuffer) and (twoLegDown or weakPullbackLong) and strongBearStreak < 3
pullback50Short = activeBar and showPullback50 and trendDown and not rangeContext and f_touches_level(impulseMid, low, high, keyBuffer) and (twoLegUp or weakPullbackShort) and strongBullStreak < 3
pullback50ExitLong = showInvalid and trendUp[1] and strongBear and close < impulseMid
pullback50ExitShort = showInvalid and trendDown[1] and strongBull and close > impulseMid

// -------------------------
// 7. True-breakout trapped pullback
// -------------------------
trueBreakLong = firstBreakLong and strongBull and not doji
trueBreakShort = firstBreakShort and strongBear and not doji

var int trapDir = 0
var int trapBreakBar = na
var float trapLevel = na
var bool trapFollowOk = false
var bool trapUsed = false

trapLong = false
trapShort = false
trapExitLong = false
trapExitShort = false
trapInvalid = false

if trueBreakLong
    trapDir := 1
    trapBreakBar := bar_index
    trapLevel := rangeHigh
    trapFollowOk := false
    trapUsed := false
if trueBreakShort
    trapDir := -1
    trapBreakBar := bar_index
    trapLevel := rangeLow
    trapFollowOk := false
    trapUsed := false

if trapDir != 0 and not na(trapBreakBar) and bar_index == trapBreakBar + 1
    trapFollowOk := trapDir == 1 ? (strongBull and close > close[1] and not doji) : (strongBear and close < close[1] and not doji)
    trapInvalid := showInvalid and not trapFollowOk
    if not trapFollowOk
        trapDir := 0

if trapDir != 0 and not na(trapBreakBar) and bar_index - trapBreakBar > trapMaxBars
    trapDir := 0

if trapDir == 1 and trapFollowOk and not trapUsed and bar_index > trapBreakBar + 1 and f_touches_level(trapLevel, low, high, keyBuffer) and close > trapLevel and not doji
    trapLong := showTrap
    trapUsed := true
if trapDir == -1 and trapFollowOk and not trapUsed and bar_index > trapBreakBar + 1 and f_touches_level(trapLevel, low, high, keyBuffer) and close < trapLevel and not doji
    trapShort := showTrap
    trapUsed := true

if trapDir == 1 and trapFollowOk and close < trapLevel and strongBear
    trapExitLong := showInvalid
if trapDir == -1 and trapFollowOk and close > trapLevel and strongBull
    trapExitShort := showInvalid

// -------------------------
// 8. L1 / H1 failure limit
// -------------------------
var float lastAiLongFollowLow = na
var float lastAiShortFollowHigh = na
var int lastAiLongFollowBar = na
var int lastAiShortFollowBar = na

if alwaysLong and strongBull
    lastAiLongFollowLow := low
    lastAiLongFollowBar := bar_index
if alwaysShort and strongBear
    lastAiShortFollowHigh := high
    lastAiShortFollowBar := bar_index

l1FailLong = activeBar and showL1Fail and alwaysLong and not na(lastAiLongFollowLow) and bar_index > lastAiLongFollowBar and low <= lastAiLongFollowLow and close > lastAiLongFollowLow and not threeBear
h1FailShort = activeBar and showL1Fail and alwaysShort and not na(lastAiShortFollowHigh) and bar_index > lastAiShortFollowBar and high >= lastAiShortFollowHigh and close < lastAiShortFollowHigh and not threeBull

// -------------------------
// 9. Third-bar failure
// -------------------------
thirdFailureLong = activeBar and showThirdFailure and alwaysLong[1] and bear and bear[1] and not bear[2]
thirdFailureShort = activeBar and showThirdFailure and alwaysShort[1] and bull and bull[1] and not bull[2]

// -------------------------
// 10. EMA20 pullback
// -------------------------
var int aiState = 0
var bool emaPullUsedLong = false
var bool emaPullUsedShort = false

if newSession
    aiState := 0
    emaPullUsedLong := false
    emaPullUsedShort := false

if alwaysLong and aiState != 1
    aiState := 1
    emaPullUsedLong := false
    emaPullUsedShort := false
if alwaysShort and aiState != -1
    aiState := -1
    emaPullUsedShort := false
    emaPullUsedLong := false
if not alwaysLong and not alwaysShort and rangeContext
    aiState := 0

emaPullLong = activeBar and showEmaPullback and aiState == 1 and not emaPullUsedLong and low <= ema + emaBuffer and close >= ema - emaBuffer and not strongBear
emaPullShort = activeBar and showEmaPullback and aiState == -1 and not emaPullUsedShort and high >= ema - emaBuffer and close <= ema + emaBuffer and not strongBull

if emaPullLong
    emaPullUsedLong := true
if emaPullShort
    emaPullUsedShort := true

emaExitLong = showInvalid and strongBear[1] and close[1] < ema[1] and bear and close < ema and close < close[1]
emaExitShort = showInvalid and strongBull[1] and close[1] > ema[1] and bull and close > ema and close > close[1]

// -------------------------
// 11. Trend breakout scalp
// -------------------------
trendScalpLong = activeBar and showTrendScalp and alwaysLong and bull and close >= low + barRange * 0.50 and bodyPct >= strongBodyPct
trendScalpShort = activeBar and showTrendScalp and alwaysShort and bear and close <= high - barRange * 0.50 and bodyPct >= strongBodyPct

// -------------------------
// Forced exits and invalid contexts
// -------------------------
forceExitLong = showInvalid and (alwaysLong or trendUp) and threeBear
forceExitShort = showInvalid and (alwaysShort or trendDown) and threeBull

// -------------------------
// Labels
// -------------------------
if showContext and barstate.isconfirmed
    if rangeContext and not rangeContext[1]
        label.new(bar_index, high, "CTX Range", style=label.style_label_down, color=color.rgb(55, 65, 81), textcolor=color.white, size=size.tiny)
    if alwaysLong and not alwaysLong[1]
        label.new(bar_index, low, "CTX AI Long", style=label.style_label_up, color=color.rgb(20, 83, 45), textcolor=color.white, size=size.tiny)
    if alwaysShort and not alwaysShort[1]
        label.new(bar_index, high, "CTX AI Short", style=label.style_label_down, color=color.rgb(127, 29, 29), textcolor=color.white, size=size.tiny)
    if wideChannelUp and not wideChannelUp[1]
        label.new(bar_index, high, "CTX Wide Ch Up", style=label.style_label_down, color=color.rgb(88, 28, 135), textcolor=color.white, size=size.tiny)
    if wideChannelDown and not wideChannelDown[1]
        label.new(bar_index, low, "CTX Wide Ch Dn", style=label.style_label_up, color=color.rgb(88, 28, 135), textcolor=color.white, size=size.tiny)

f_mark(h2Long, true, "H2", longColor)
f_mark(l2Short, false, "L2", shortColor)
f_mark(bfbLong, true, "BFB", longColor)
f_mark(bfbShort, false, "BFB", shortColor)
f_mark(keyRevLong, true, "KeyRev", longColor)
f_mark(keyRevShort, false, "KeyRev", shortColor)
f_mark(rangeFadeLong, true, "Range Lmt", limitLongColor)
f_mark(rangeFadeShort, false, "Range Lmt", limitShortColor)
f_mark(point3Long, true, "P3 Lmt", limitLongColor)
f_mark(point3Short, false, "P3 Lmt", limitShortColor)
f_mark(pullback50Long, true, "50% Lmt", limitLongColor)
f_mark(pullback50Short, false, "50% Lmt", limitShortColor)
f_mark(trapLong, true, "Trap PB", limitLongColor)
f_mark(trapShort, false, "Trap PB", limitShortColor)
f_mark(l1FailLong, true, "L1 Fail", limitLongColor)
f_mark(h1FailShort, false, "H1 Fail", limitShortColor)
f_mark(thirdFailureLong, true, "3rd Fail", limitLongColor)
f_mark(thirdFailureShort, false, "3rd Fail", limitShortColor)
f_mark(emaPullLong, true, "EMA PB", limitLongColor)
f_mark(emaPullShort, false, "EMA PB", limitShortColor)
f_mark(trendScalpLong, true, "Scalp", longColor)
f_mark(trendScalpShort, false, "Scalp", shortColor)

f_mark(h2InvalidLong, false, "Invalid H2", invalidColor)
f_mark(l2InvalidShort, true, "Invalid L2", invalidColor)
f_mark(trapInvalid, false, "Trap invalid", invalidColor)
f_mark(pullback50ExitLong, false, "50% exit", exitColor)
f_mark(pullback50ExitShort, true, "50% exit", exitColor)
f_mark(trapExitLong, false, "Trap exit", exitColor)
f_mark(trapExitShort, true, "Trap exit", exitColor)
f_mark(emaExitLong, false, "EMA exit", exitColor)
f_mark(emaExitShort, true, "EMA exit", exitColor)
f_mark(forceExitLong, false, "3-bar exit", exitColor)
f_mark(forceExitShort, true, "3-bar exit", exitColor)

// -------------------------
// Trade guides
// -------------------------
breakoutLongSetups = h2Long or bfbLong or keyRevLong
breakoutShortSetups = l2Short or bfbShort or keyRevShort
f_breakout_guides(breakoutLongSetups, true, defaultRR)
f_breakout_guides(breakoutShortSetups, false, defaultRR)

rangeLongEntry = rangeLow
rangeLongStop = low - tick
rangeShortEntry = rangeHigh
rangeShortStop = high + tick
f_limit_guides(rangeFadeLong, true, rangeLongEntry, rangeLongStop, 1.0)
f_limit_guides(rangeFadeShort, false, rangeShortEntry, rangeShortStop, 1.0)

point3LongEntry = low
point3LongStop = low - atr * atrTargetMult
point3ShortEntry = high
point3ShortStop = high + atr * atrTargetMult
f_limit_guides(point3Long, true, point3LongEntry, point3LongStop, defaultRR)
f_limit_guides(point3Short, false, point3ShortEntry, point3ShortStop, defaultRR)

pullback50LongStop = pullback50Long ? math.min(low, impulseMid) - tick : na
pullback50ShortStop = pullback50Short ? math.max(high, impulseMid) + tick : na
f_limit_guides(pullback50Long, true, impulseMid, pullback50LongStop, defaultRR)
f_limit_guides(pullback50Short, false, impulseMid, pullback50ShortStop, defaultRR)

trapLongStop = trapLong ? trapLevel - atr * atrTargetMult : na
trapShortStop = trapShort ? trapLevel + atr * atrTargetMult : na
f_limit_guides(trapLong, true, trapLevel, trapLongStop, defaultRR)
f_limit_guides(trapShort, false, trapLevel, trapShortStop, defaultRR)

l1Stop = l1FailLong ? math.min(low, lastAiLongFollowLow) - tick : na
h1Stop = h1FailShort ? math.max(high, lastAiShortFollowHigh) + tick : na
f_limit_guides(l1FailLong, true, lastAiLongFollowLow, l1Stop, defaultRR)
f_limit_guides(h1FailShort, false, lastAiShortFollowHigh, h1Stop, defaultRR)

thirdLongStop = thirdFailureLong ? low - tick : na
thirdShortStop = thirdFailureShort ? high + tick : na
f_limit_guides(thirdFailureLong, true, close, thirdLongStop, defaultRR)
f_limit_guides(thirdFailureShort, false, close, thirdShortStop, defaultRR)

emaLongStop = emaPullLong ? low - tick : na
emaShortStop = emaPullShort ? high + tick : na
f_limit_guides(emaPullLong, true, ema, emaLongStop, defaultRR)
f_limit_guides(emaPullShort, false, ema, emaShortStop, defaultRR)

// Add ATR scalp target hints on trend scalp entries.
if showTradeGuides and trendScalpLong and barstate.isconfirmed
    scalpEntry = high + tick
    scalpStop = low - tick
    scalpTarget = scalpEntry + atr * atrTargetMult
    f_draw_guides(true, scalpEntry, scalpStop, scalpTarget)
if showTradeGuides and trendScalpShort and barstate.isconfirmed
    scalpEntry = low - tick
    scalpStop = high + tick
    scalpTarget = scalpEntry - atr * atrTargetMult
    f_draw_guides(true, scalpEntry, scalpStop, scalpTarget)

// -------------------------
// Alerts
// -------------------------
anyLongSetup = h2Long or bfbLong or keyRevLong or rangeFadeLong or point3Long or pullback50Long or trapLong or l1FailLong or thirdFailureLong or emaPullLong or trendScalpLong
anyShortSetup = l2Short or bfbShort or keyRevShort or rangeFadeShort or point3Short or pullback50Short or trapShort or h1FailShort or thirdFailureShort or emaPullShort or trendScalpShort
anyForcedExit = forceExitLong or forceExitShort or pullback50ExitLong or pullback50ExitShort or trapExitLong or trapExitShort or emaExitLong or emaExitShort
anyInvalid = h2InvalidLong or l2InvalidShort or trapInvalid

alertcondition(anyLongSetup, "PA any long setup", "PA long setup detected")
alertcondition(anyShortSetup, "PA any short setup", "PA short setup detected")
alertcondition(anyForcedExit, "PA forced exit", "PA forced-exit condition detected")
alertcondition(anyInvalid, "PA invalid setup", "PA invalid / prohibited condition detected")

alertcondition(h2Long, "PA H2 long", "PA H2 long")
alertcondition(l2Short, "PA L2 short", "PA L2 short")
alertcondition(bfbLong or bfbShort, "PA break-fail-break", "PA break-fail-break")
alertcondition(keyRevLong or keyRevShort, "PA key reversal", "PA key-level structure reversal")
alertcondition(rangeFadeLong or rangeFadeShort, "PA range fade", "PA range high/low limit fade")
alertcondition(point3Long or point3Short, "PA Point 3", "PA wide-channel Point 3 fade")
alertcondition(pullback50Long or pullback50Short, "PA 50 percent pullback", "PA trend 50 percent pullback")
alertcondition(trapLong or trapShort, "PA trapped pullback", "PA true-breakout trapped pullback")
alertcondition(l1FailLong or h1FailShort, "PA L1/H1 failure", "PA L1/H1 failure")
alertcondition(thirdFailureLong or thirdFailureShort, "PA third-bar failure", "PA third-bar failure")
alertcondition(emaPullLong or emaPullShort, "PA EMA pullback", "PA EMA20 pullback")
alertcondition(trendScalpLong or trendScalpShort, "PA trend scalp", "PA trend breakout scalp")
````
