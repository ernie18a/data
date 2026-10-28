# Volume Delta Pressure [JOAT]

- url: https://www.tradingview.com/script/5Z2B46DS-Volume-Delta-Pressure-JOAT/
- type: indicator
- pine_id: PUB;19d2bc69eb17481f88c7d148b84beb36
- version: 1.0

## Description

[b]Volume Delta Pressure[/b] estimates how much of each bar's volume was buying versus selling, then turns that split into a clean read on who is actually in control. It combines a per-bar delta engine, a cumulative session delta line, a normalized pressure oscillator, gradient candle heat, VWAP bands, and a full on-chart dashboard — so order flow becomes something you can [i]see[/i] at a glance instead of guessing.

[image]https://www.tradingview.com/x/TNOkNK9V/[/image]

[b]▎ WHAT IT DOES[/b]
It reconstructs buy/sell volume for every candle, tracks the running net delta across the session, and measures whether current flow is stretched into [b]Accumulation[/b] or [b]Distribution[/b]. From that it colors your candles by pressure, prints cooldown-gated BUY/SELL labels, flags CVD/price divergences, and reports the full picture in a top-corner panel.

[b]▎ HOW IT WORKS[/b]
• [b]Delta engine[/b] — Two methods. [i]Lower-TF Intrabar[/i] polls a smaller timeframe, signs each intrabar by its direction (up = buy, down = sell, doji split), and sums the volume. [i]Range/Body Proxy[/i] splits chart-bar volume using where close sits inside the bar's range blended with candle-body direction. [i]Auto[/i] uses intrabar data when available and falls back to the proxy everywhere else.
• [b]Bar delta[/b] — Buy volume minus sell volume for the current candle, plus buy% / sell% of total bar volume.
• [b]CVD[/b] — Cumulative volume delta that adds each bar's delta and resets on your chosen anchor (session/day, week, month, or never).
• [b]Pressure oscillator[/b] — Delta is EMA-smoothed, then normalized either as a [i]Z-Score[/i] against its rolling mean/stdev (roughly −3..+3) or as [i]% of Volume[/i] (−100..+100). This single value drives the state, gauge, and candle color.
• [b]Signals[/b] — A BUY fires when pressure crosses up through zero; a SELL when it crosses down. Each flip must also pass a [b]delta-expansion filter[/b] (absolute delta above a multiple of its recent average), optional [b]price confirmation[/b] (up close for buys, down close for sells), an optional [b]divergence requirement[/b], and a [b]cooldown[/b] that blocks stacked same-side signals. Signals only confirm on bar close.
• [b]Divergence[/b] — Pivot highs/lows on price are compared against CVD at the same pivot. Price lower-low with CVD higher-low prints a [i]Bull Div[/i]; price higher-high with CVD lower-high prints a [i]Bear Div[/i]. Each stays "active" for a set number of bars.
• [b]VWAP + σ bands[/b] — Anchored VWAP with inner and outer standard-deviation channels, tinted green above / red below.
• [b]No-volume guard[/b] — On assets that report no volume, signals switch off and the dashboard shows a clear notice instead of printing misleading data.

[b]▎ HOW TO USE IT[/b]
• Read [b]candle heat[/b] first: deep green = strong net buying, grey = balanced, deep red = strong net selling. Candles flash full color on a confirmed signal.
• Treat [b]BUY / SELL pills[/b] as flow-flip alerts, not standalone entries. They are strongest when they agree with the CVD trend and VWAP location.
• Use [b]CVD[/b] to judge conviction behind a move — price up while CVD falls warns the push is thin.
• [b]Divergence labels[/b] mark spots where price and delta disagree — useful for anticipating exhaustion or reversal.
• Trade with the [b]VWAP channel[/b]: above VWAP favors longs, band edges mark stretched conditions and mean-reversion zones.
• For fewer, higher-quality signals, turn on [i]Require CVD Divergence[/i] and keep price confirmation on.

[b]▎ KEY SETTINGS[/b]
• [b]Engine[/b] — Delta method, intrabar timeframe (auto or manual), proxy close-vs-body weight, and delta smoothing.
• [b]Pressure Oscillator[/b] — Normalization mode, lookback, and the Accumulation / Distribution thresholds.
• [b]CVD & Divergence[/b] — Reset anchor, pivot length, recency window, and label caps.
• [b]Signals[/b] — Expansion multiplier and baseline, price/divergence requirements, cooldown, and label size/cap.
• [b]VWAP[/b] — Source, anchor, inner/outer σ multipliers, and colors.
• [b]Visuals[/b] — Gradient candle toggle, saturation points, and the buy/neutral/sell color set.
• [b]Dashboard[/b] — Show/hide, position, and text size.

[image]https://www.tradingview.com/x/5dMmw9gi/[/image]

[b]▎ DASHBOARD[/b]
A top-right gradient panel reporting: delta source (LTF or Proxy), bar delta, session/cumulative CVD and its trend, buy% and sell%, the pressure value, a segmented flow gauge, the current State (Accumulation / Distribution / Neutral), active divergence, dominant side, VWAP location, and the last active signal — each cell color-coded by side.

[b]▎ ALERTS[/b]
• [b]Buy Pressure Flip[/b] — fires on a confirmed BUY signal.
• [b]Sell Pressure Flip[/b] — fires on a confirmed SELL signal.

[b]▎ NOTES[/b]
• Works on all timeframes and assets that report volume; degrades gracefully where volume is absent.
• Signals confirm on bar close, so labels and alerts do not repaint after the bar completes.
• Every visual layer — candles, VWAP, labels, dashboard — toggles independently for a clean chart.
• Delta is an [i]estimate[/i] reconstructed from price and volume, not exchange-reported order flow.

[i]For research and education only. This is not financial advice. No indicator can predict the future, and past behavior does not guarantee future results. Always do your own analysis and manage your own risk.[/i]

[i]Made with passion by JackOfAllTrades ⚡[/i]

## Source Code

````pine
//@version=6
indicator("Volume Delta Pressure [JOAT]", shorttitle="VDP [JOAT]", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume Delta Pressure [JOAT]
// Estimates per-bar buy/sell delta (LTF intrabar OR range/body proxy),
// cumulative delta (CVD, resettable), a normalized pressure oscillator,
// gradient candle heat, VWAP + σ-band channel, clean BUY/SELL label pills,
// clean CVD/price divergence labels, and a full chrome-gradient dashboard.
// Guards assets with no volume (signals off, notice shown). All TFs/assets.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01 · ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gEngine = "01 · Engine"
deltaMethod   = input.string("Auto (LTF + Proxy)", "Delta Method", options=["Auto (LTF + Proxy)", "Lower-TF Intrabar", "Range/Body Proxy"], group=gEngine, tooltip="How per-bar buy/sell volume is split.\nLower-TF Intrabar polls a smaller timeframe and signs each intrabar by its direction (most accurate).\nRange/Body Proxy splits chart-bar volume by where close sits in the range plus body direction (works everywhere, no LTF data needed).\nAuto uses LTF when intrabar data is available and falls back to the proxy otherwise.")
ltfMode       = input.string("Auto (chart aware)", "Intrabar Timeframe Mode", options=["Auto (chart aware)", "Manual"], group=gEngine, tooltip="Auto adapts the lower timeframe to the chart. Manual uses the value below.")
ltfManual     = input.timeframe("1", "Manual Intrabar Timeframe", group=gEngine, tooltip="Used only in Manual mode. Must be lower than the chart timeframe.")
closeWeight   = input.float(0.65, "Proxy Close-vs-Body Weight", minval=0.0, maxval=1.0, step=0.05, group=gEngine, tooltip="Proxy blend. 1.0 = split volume purely by close position in the range. 0.0 = split purely by candle body direction. 0.65 balances both.")
smoothLen     = input.int(5, "Delta EMA Smoothing", minval=1, maxval=100, group=gEngine, tooltip="EMA length applied to raw bar delta before the pressure oscillator is built.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02 · PRESSURE OSCILLATOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gPress = "02 · Pressure Oscillator"
normMode      = input.string("Z-Score", "Normalization", options=["Z-Score", "% of Volume"], group=gPress, tooltip="Z-Score normalizes smoothed delta by its rolling mean/stdev (unbounded, ~ -3..3).\n% of Volume expresses net delta as a percent of bar volume (-100..100).")
zLen          = input.int(50, "Normalization Lookback", minval=5, maxval=500, group=gPress, tooltip="Lookback for the z-score mean/stdev.")
statePos      = input.float(0.6, "Accumulation Threshold", minval=0.0, step=0.1, group=gPress, tooltip="Pressure above this reads as Accumulation in the dashboard.")
stateNeg      = input.float(-0.6, "Distribution Threshold", maxval=0.0, step=0.1, group=gPress, tooltip="Pressure below this reads as Distribution in the dashboard.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03 · CVD & DIVERGENCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gCvd = "03 · CVD & Divergence"
cvdReset      = input.string("Session/Day", "CVD Reset", options=["Session/Day", "Week", "Month", "None"], group=gCvd, tooltip="When cumulative volume delta resets to zero.")
divLen        = input.int(5, "Divergence Pivot Length", minval=2, maxval=50, group=gCvd, tooltip="Pivot strength used to detect price/CVD divergence (bars on each side).")
divRecency    = input.int(12, "Divergence Recency (bars)", minval=1, maxval=100, group=gCvd, tooltip="A divergence is considered active for this many bars after it prints.")
showDivLabels = input.bool(true, "Show Divergence Labels", group=gCvd, tooltip="Print a clean \"Δ Bull Div\" / \"Δ Bear Div\" label at the pivot where price/CVD divergence occurs. No arrows.")
maxDivLabels  = input.int(40, "Max Divergence Labels", minval=5, maxval=250, group=gCvd, tooltip="Cap on retained divergence labels (older ones are removed).")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04 · SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gSig = "04 · Signals"
showSignals   = input.bool(true, "Show BUY / SELL Labels", group=gSig, tooltip="Print clean BUY / SELL label pills on pressure-flip signals (no arrows).")
lblSize       = input.string("Normal", "Signal Label Size", options=["Tiny", "Small", "Normal", "Large"], group=gSig)
maxSignalLabels = input.int(60, "Max Signal Labels", minval=10, maxval=250, group=gSig, tooltip="Cap on retained BUY/SELL labels (older ones are removed).")
expandMult    = input.float(1.2, "Delta Expansion Multiplier", minval=0.5, maxval=5.0, step=0.1, group=gSig, tooltip="A flip only signals when absolute bar delta exceeds this multiple of its recent average (momentum filter).")
expandLen     = input.int(20, "Expansion Baseline Length", minval=2, maxval=200, group=gSig, tooltip="Lookback for the average absolute delta used by the expansion filter.")
requireDiv    = input.bool(false, "Require CVD Divergence", group=gSig, tooltip="When on, a BUY also needs a bullish CVD divergence (price lower low, CVD higher low) and a SELL a bearish one. Fewer but stronger signals.")
requirePriceConf = input.bool(true, "Require Price Confirmation", group=gSig, tooltip="BUY needs an up close (close>close[1]); SELL needs a down close.")
signalCooldown= input.int(5, "Signal Cooldown (bars)", minval=0, maxval=100, group=gSig, tooltip="Minimum bars between two signals of the same side (prevents stacking).")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05 · VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gVwap = "05 · VWAP"
useVwap       = input.bool(true, "Show VWAP + σ Bands", group=gVwap, tooltip="Volume-weighted average price with a standard-deviation channel, tinted green above / red below. Resets on the chosen anchor.")
vwapSrc       = input.source(hlc3, "VWAP Source", group=gVwap)
vwapAnchor    = input.string("Session", "Anchor", options=["Session", "Week", "Month"], group=gVwap, tooltip="When VWAP resets to a new anchor period.")
vwapDev1      = input.float(1.0, "Inner Band σ", minval=0.25, maxval=6.0, step=0.25, group=gVwap, tooltip="Standard-deviation multiplier for the inner band pair.")
showBand2     = input.bool(true, "Show Outer Band", group=gVwap)
vwapDev2      = input.float(2.0, "Outer Band σ", minval=0.25, maxval=8.0, step=0.25, group=gVwap, tooltip="Standard-deviation multiplier for the outer band pair.")
vwapCol       = input.color(#B8C6D6, "VWAP Line", group=gVwap)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06 · VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gVis = "06 · Visuals"
colorCandles  = input.bool(true, "Gradient Candle Heat", group=gVis, tooltip="Recolor candles from strong-sell (red) through neutral (grey) to strong-buy (green) by pressure, flashing full color on signals. The signature visual.")
zGradMax      = input.float(2.0, "Z-Score Gradient Saturation", minval=0.5, step=0.1, group=gVis, tooltip="Pressure magnitude (z-score mode) that maps to full color saturation.")
pctGradMax    = input.float(60.0, "% Volume Gradient Saturation", minval=5.0, step=5.0, group=gVis, tooltip="Pressure magnitude (% of volume mode) that maps to full color saturation.")
buyColor      = input.color(#00E676, "Strong Buy", group=gVis, inline="cols")
neutralColor  = input.color(#787B86, "Neutral", group=gVis, inline="cols")
sellColor     = input.color(#FF1744, "Strong Sell", group=gVis, inline="cols")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 07 · DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gDash = "07 · Dashboard"
showDash      = input.bool(true, "Show Dashboard", group=gDash)
dashPos       = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=gDash)
dashSize      = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=gDash)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD CHROME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color DASH_HEAD_A = #12263A
color DASH_HEAD_B = #1E3E63
color DASH_CHROME = #A9BAC9
color DASH_ROWBG  = #0E1524
color DASH_LBL    = #8B95A7
color DASH_TITLE  = #F2F7FC

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_dashPos(_p) =>
    _p == "Top Left" ? position.top_left : _p == "Bottom Right" ? position.bottom_right : _p == "Bottom Left" ? position.bottom_left : _p == "Middle Right" ? position.middle_right : position.top_right

f_dashSize(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Large" ? size.large : _s == "Normal" ? size.normal : size.small

f_lblSize(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Normal" ? size.normal : _s == "Large" ? size.large : size.small

f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_v, _hi))

f_autoLTF() =>
    int s = timeframe.in_seconds(timeframe.period)
    s >= 86400 ? "30" : s >= 14400 ? "15" : s >= 3600 ? "5" : s >= 900 ? "1" : s >= 300 ? "1" : "1"

f_num(_v) =>
    float a = math.abs(_v)
    string sfx = a >= 1e9 ? "B" : a >= 1e6 ? "M" : a >= 1e3 ? "K" : ""
    float d = a >= 1e9 ? _v / 1e9 : a >= 1e6 ? _v / 1e6 : a >= 1e3 ? _v / 1e3 : _v
    str.tostring(d, "#.##") + sfx

f_vbg(_c) =>
    color.new(_c, 86)

f_gauge(_frac) =>
    int n = int(math.round(f_clamp(_frac, 0.0, 1.0) * 8.0))
    string s = ""
    for i = 0 to 7
        s := s + (i < n ? "▮" : "▯")
    s

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLUME GUARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float vol = nz(volume)
bool barHasVol = not na(volume) and volume > 0.0
var bool anyVolSeen = false
if barHasVol
    anyVolSeen := true
bool volAvailable = anyVolSeen

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR / LABEL OFFSET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float atrVal = ta.atr(14)
float lblOff = (na(atrVal) or atrVal == 0.0) ? syminfo.mintick * 10.0 : atrVal * 0.6

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOWER-TIMEFRAME INTRABAR DELTA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string ltfTf = ltfMode == "Manual" ? ltfManual : f_autoLTF()
bool wantLTF = deltaMethod != "Range/Body Proxy"

array<float> ltfClose = request.security_lower_tf(syminfo.tickerid, ltfTf, close)
array<float> ltfOpen  = request.security_lower_tf(syminfo.tickerid, ltfTf, open)
array<float> ltfVol   = request.security_lower_tf(syminfo.tickerid, ltfTf, volume)

f_ltfDelta(array<float> _c, array<float> _o, array<float> _v) =>
    float _buy = 0.0
    float _sell = 0.0
    int n = array.size(_c)
    if n > 0 and array.size(_v) == n and array.size(_o) == n
        for i = 0 to n - 1
            float c = array.get(_c, i)
            float o = array.get(_o, i)
            float v = nz(array.get(_v, i))
            int sgn = c > o ? 1 : c < o ? -1 : 0
            _buy  += sgn > 0 ? v : sgn == 0 ? v * 0.5 : 0.0
            _sell += sgn < 0 ? v : sgn == 0 ? v * 0.5 : 0.0
    [_buy, _sell]

[ltfBuy, ltfSell] = f_ltfDelta(ltfClose, ltfOpen, ltfVol)
bool ltfOk = wantLTF and (ltfBuy + ltfSell) > 0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RANGE / BODY PROXY DELTA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float rng = high - low
float closeFrac = rng > 0.0 ? (close - low) / rng : 0.5
float dirFrac = close > open ? 1.0 : close < open ? 0.0 : 0.5
float buyFrac = math.max(0.0, math.min(1.0, closeFrac * closeWeight + dirFrac * (1.0 - closeWeight)))
float proxyBuy = vol * buyFrac
float proxySell = vol * (1.0 - buyFrac)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL DELTA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool usingLTF = ltfOk and deltaMethod != "Range/Body Proxy" and (deltaMethod == "Lower-TF Intrabar" or deltaMethod == "Auto (LTF + Proxy)")
float buyVol  = usingLTF ? ltfBuy  : proxyBuy
float sellVol = usingLTF ? ltfSell : proxySell
float barVol  = buyVol + sellVol
float delta   = buyVol - sellVol
float buyPct  = barVol > 0.0 ? 100.0 * buyVol / barVol : 50.0
float sellPct = 100.0 - buyPct

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CVD (RESETTABLE)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool cvdNewPeriod = cvdReset == "Session/Day" ? timeframe.change("D") : cvdReset == "Week" ? timeframe.change("W") : cvdReset == "Month" ? timeframe.change("M") : false
var float cvd = 0.0
if cvdNewPeriod
    cvd := 0.0
cvd := cvd + delta

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRESSURE OSCILLATOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float deltaSmooth = ta.ema(delta, smoothLen)
float dBasis = ta.sma(deltaSmooth, zLen)
float dDev = ta.stdev(deltaSmooth, zLen)
float zScore = dDev > 0.0 ? (deltaSmooth - dBasis) / dDev : 0.0
float deltaNorm = barVol > 0.0 ? 100.0 * delta / barVol : 0.0
float pressure = normMode == "Z-Score" ? zScore : deltaNorm
float gradMax = normMode == "Z-Score" ? zGradMax : pctGradMax

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP + σ BANDS (idiom #4)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool vwapReset = vwapAnchor == "Week" ? timeframe.change("W") : vwapAnchor == "Month" ? timeframe.change("M") : timeframe.change("D")
[vwapV, vwUp1, vwLo1] = ta.vwap(vwapSrc, vwapReset, vwapDev1)
float vwSigma = vwapDev1 != 0.0 ? (vwUp1 - vwapV) / vwapDev1 : (vwUp1 - vwapV)
float vwUp2 = vwapV + vwapDev2 * vwSigma
float vwLo2 = vwapV - vwapDev2 * vwSigma

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CVD DIVERGENCE (PIVOT BASED) + CLEAN LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float pl = ta.pivotlow(low, divLen, divLen)
float ph = ta.pivothigh(high, divLen, divLen)
var float lastPLprice = na
var float lastPLcvd = na
var float lastPHprice = na
var float lastPHcvd = na
var int lastBullDivBar = na
var int lastBearDivBar = na
var array<label> divLabels = array.new<label>()

if not na(pl)
    float curCvd = cvd[divLen]
    if not na(lastPLprice) and pl < lastPLprice and curCvd > lastPLcvd
        lastBullDivBar := bar_index
        if showDivLabels and volAvailable
            label dl = label.new(bar_index - divLen, pl - lblOff * 0.6, "Δ Bull Div", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(buyColor, 12), textcolor=color.white, size=size.small, text_formatting=text.format_bold)
            array.push(divLabels, dl)
            while array.size(divLabels) > maxDivLabels
                label od = array.shift(divLabels)
                label.delete(od)
    lastPLprice := pl
    lastPLcvd := curCvd

if not na(ph)
    float curCvdH = cvd[divLen]
    if not na(lastPHprice) and ph > lastPHprice and curCvdH < lastPHcvd
        lastBearDivBar := bar_index
        if showDivLabels and volAvailable
            label dl = label.new(bar_index - divLen, ph + lblOff * 0.6, "Δ Bear Div", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(sellColor, 12), textcolor=color.white, size=size.small, text_formatting=text.format_bold)
            array.push(divLabels, dl)
            while array.size(divLabels) > maxDivLabels
                label od = array.shift(divLabels)
                label.delete(od)
    lastPHprice := ph
    lastPHcvd := curCvdH

bool bullDivActive = not na(lastBullDivBar) and (bar_index - lastBullDivBar) <= divRecency
bool bearDivActive = not na(lastBearDivBar) and (bar_index - lastBearDivBar) <= divRecency

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool flipUp = ta.crossover(pressure, 0.0)
bool flipDn = ta.crossunder(pressure, 0.0)
float avgAbsDelta = ta.sma(math.abs(delta), expandLen)
bool deltaExpand = math.abs(delta) >= avgAbsDelta * expandMult and avgAbsDelta > 0.0
bool priceUp = not requirePriceConf or close > close[1]
bool priceDn = not requirePriceConf or close < close[1]
bool divBuyOk = not requireDiv or bullDivActive
bool divSellOk = not requireDiv or bearDivActive

var int lastBuyBar = na
var int lastSellBar = na
bool buyCoolOk = na(lastBuyBar) or (bar_index - lastBuyBar) >= signalCooldown
bool sellCoolOk = na(lastSellBar) or (bar_index - lastSellBar) >= signalCooldown

bool buySignal  = volAvailable and barstate.isconfirmed and flipUp and deltaExpand and priceUp and divBuyOk and buyCoolOk
bool sellSignal = volAvailable and barstate.isconfirmed and flipDn and deltaExpand and priceDn and divSellOk and sellCoolOk

if buySignal
    lastBuyBar := bar_index
if sellSignal
    lastSellBar := bar_index

var int lastSignalDir = 0
if buySignal
    lastSignalDir := 1
if sellSignal
    lastSignalDir := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LABEL PILLS (idiom #1 — clean labels, no arrows)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var array<label> sigLabels = array.new<label>()
if showSignals and (buySignal or sellSignal)
    bool isLong = buySignal
    color sc = isLong ? buyColor : sellColor
    float ly = isLong ? low - lblOff : high + lblOff
    label lb = label.new(bar_index, ly, isLong ? "BUY" : "SELL", xloc=xloc.bar_index, yloc=yloc.price, style = isLong ? label.style_label_up : label.style_label_down, color=color.new(sc, 0), textcolor=color.white, size=f_lblSize(lblSize), text_formatting=text.format_bold)
    array.push(sigLabels, lb)
    while array.size(sigLabels) > maxSignalLabels
        label od = array.shift(sigLabels)
        label.delete(od)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE GRADIENT HEAT (idiom #3)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color heatColor = pressure >= 0.0 ? color.from_gradient(pressure, 0.0, gradMax, neutralColor, buyColor) : color.from_gradient(pressure, -gradMax, 0.0, sellColor, neutralColor)
color barCol = na
if colorCandles and volAvailable
    barCol := buySignal ? color.new(buyColor, 0) : sellSignal ? color.new(sellColor, 0) : heatColor
barcolor(barCol, title="Pressure Heat")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP PLOTS + GRADIENT CHANNEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pVwap = plot(useVwap ? vwapV : na, "VWAP", color=color.new(vwapCol, 0), linewidth=2)
pU1 = plot(useVwap ? vwUp1 : na, "VWAP +σ", color=color.new(buyColor, 55))
pL1 = plot(useVwap ? vwLo1 : na, "VWAP -σ", color=color.new(sellColor, 55))
pU2 = plot(useVwap and showBand2 ? vwUp2 : na, "VWAP +2σ", color=color.new(buyColor, 72))
pL2 = plot(useVwap and showBand2 ? vwLo2 : na, "VWAP -2σ", color=color.new(sellColor, 72))
fill(pVwap, pU1, color = useVwap ? color.new(buyColor, 90) : na, title="VWAP Upper Fill")
fill(pVwap, pL1, color = useVwap ? color.new(sellColor, 90) : na, title="VWAP Lower Fill")
fill(pU1, pU2, color = useVwap and showBand2 ? color.new(buyColor, 94) : na, title="VWAP Outer Up Fill")
fill(pL1, pL2, color = useVwap and showBand2 ? color.new(sellColor, 94) : na, title="VWAP Outer Dn Fill")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, "Buy Pressure Flip", "VDP: BUY pressure flip on {{ticker}} ({{interval}})")
alertcondition(sellSignal, "Sell Pressure Flip", "VDP: SELL pressure flip on {{ticker}} ({{interval}})")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string pState = pressure >= statePos ? "Accumulation" : pressure <= stateNeg ? "Distribution" : "Neutral"
color pStateColor = pressure >= statePos ? buyColor : pressure <= stateNeg ? sellColor : neutralColor
string domSide = delta > 0.0 ? "Buyers" : delta < 0.0 ? "Sellers" : "Balanced"
color domColor = delta > 0.0 ? buyColor : delta < 0.0 ? sellColor : neutralColor
string divFlag = bullDivActive ? "Bullish ▲" : bearDivActive ? "Bearish ▼" : "None"
color divColor = bullDivActive ? buyColor : bearDivActive ? sellColor : neutralColor
string sigText = lastSignalDir == 1 ? "BUY" : lastSignalDir == -1 ? "SELL" : "—"
color sigColor = lastSignalDir == 1 ? buyColor : lastSignalDir == -1 ? sellColor : neutralColor
color deltaColor = delta > 0.0 ? buyColor : delta < 0.0 ? sellColor : neutralColor
color cvdColor = cvd > 0.0 ? buyColor : cvd < 0.0 ? sellColor : neutralColor
string srcText = usingLTF ? "LTF " + ltfTf : "Proxy"
string cvdTrend = cvd > cvd[3] ? "Rising ▲" : cvd < cvd[3] ? "Falling ▼" : "Flat"
color cvdTrendCol = cvd > cvd[3] ? buyColor : cvd < cvd[3] ? sellColor : neutralColor
string vwapLoc = na(vwapV) ? "n/a" : close > vwapV ? "Above VWAP" : close < vwapV ? "Below VWAP" : "At VWAP"
color vwapLocCol = na(vwapV) ? neutralColor : close > vwapV ? buyColor : close < vwapV ? sellColor : neutralColor
string gaugeText = (pressure >= 0.0 ? "+" : "−") + f_gauge(math.abs(pressure) / gradMax)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD RENDER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = na
if showDash and barstate.islast
    ps = f_dashSize(dashSize)
    if not na(dash)
        table.delete(dash)
    dash := table.new(f_dashPos(dashPos), 2, 13, bgcolor=color.new(#070B12, 6), frame_color=color.new(DASH_CHROME, 45), frame_width=1, border_color=color.new(#070B12, 45), border_width=1)

    // Header (gradient chrome, bold-italic)
    table.cell(dash, 0, 0, "VOLUME DELTA PRESSURE", text_color=DASH_TITLE, text_size=ps, text_halign=text.align_left, bgcolor=DASH_HEAD_A)
    table.cell(dash, 1, 0, srcText, text_color=DASH_CHROME, text_size=ps, text_halign=text.align_center, bgcolor=DASH_HEAD_B)
    table.cell_set_text_formatting(dash, 0, 0, text.format_bold + text.format_italic)
    table.cell_set_text_formatting(dash, 1, 0, text.format_bold + text.format_italic)

    // Row 1 — Bar Delta / no-volume notice
    if not volAvailable
        table.cell(dash, 0, 1, "⚠ No volume data", text_color=sellColor, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
        table.cell(dash, 1, 1, "signals off", text_color=neutralColor, text_size=ps, text_halign=text.align_center, bgcolor=color.new(DASH_ROWBG, 20))
    else
        table.cell(dash, 0, 1, "Bar Delta", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
        table.cell(dash, 1, 1, f_num(delta), text_color=deltaColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(deltaColor))

    // Row 2 — CVD
    table.cell(dash, 0, 2, cvdReset == "None" ? "Cumulative Δ" : "Session Δ (CVD)", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 2, f_num(cvd), text_color=cvdColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(cvdColor))

    // Row 3 — CVD Trend
    table.cell(dash, 0, 3, "CVD Trend", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 3, cvdTrend, text_color=cvdTrendCol, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(cvdTrendCol))

    // Row 4 — Buy %
    table.cell(dash, 0, 4, "Buy %", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 4, str.tostring(buyPct, "#.#") + "%", text_color=buyColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(buyColor))

    // Row 5 — Sell %
    table.cell(dash, 0, 5, "Sell %", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 5, str.tostring(sellPct, "#.#") + "%", text_color=sellColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(sellColor))

    // Row 6 — Pressure
    table.cell(dash, 0, 6, "Pressure", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 6, str.tostring(pressure, "#.##") + (normMode == "Z-Score" ? "σ" : "%"), text_color=pStateColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(pStateColor))

    // Row 7 — Flow Gauge
    table.cell(dash, 0, 7, "Flow Gauge", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 7, gaugeText, text_color=pStateColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(pStateColor))

    // Row 8 — State
    table.cell(dash, 0, 8, "State", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 8, pState, text_color=pStateColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(pStateColor))

    // Row 9 — Divergence
    table.cell(dash, 0, 9, "Δ Divergence", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 9, divFlag, text_color=divColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(divColor))

    // Row 10 — Dominant Side
    table.cell(dash, 0, 10, "Dominant Side", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 10, domSide, text_color=domColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(domColor))

    // Row 11 — VWAP Location
    table.cell(dash, 0, 11, "VWAP", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 11, vwapLoc, text_color=vwapLocCol, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(vwapLocCol))

    // Row 12 — Active Signal
    table.cell(dash, 0, 12, "Active Signal", text_color=DASH_LBL, text_size=ps, text_halign=text.align_left, bgcolor=color.new(DASH_ROWBG, 20))
    table.cell(dash, 1, 12, sigText, text_color=sigColor, text_size=ps, text_halign=text.align_center, bgcolor=f_vbg(sigColor))
````
