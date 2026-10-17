# Oversold Master

- url: https://www.tradingview.com/script/8aRf4tVV-Oversold-Master/
- type: indicator
- pine_id: PUB;42e68aaeee1c4035a7fb9405416eebe4
- version: 2.0

## Description

How it works, and how to tune it:

Gray line = neutral. Red = in overbought zone. Blue = in oversold zone.
A triangle signal only appears after price has confirmed its way back out of the zone (controlled by "Bars to Confirm Exit From Zone") — this is what prevents you from selling into a strong momentum spike that keeps climbing.
The bands themselves move (adaptive mode) — during high volatility they widen, so you don't get an overbought signal every 20 minutes; during quiet chop they tighten, so you still catch real extremes.
The trend filter checks a daily EMA by default — it will block sell signals while the daily trend is up, and block buy signals while the daily trend is down. This is the setting most responsible for avoiding "buying a dip that's actually the start of a crash."

## Source Code

````pine
//@version=6
indicator("Smart OB/OS (Adaptive + Confirmed)", overlay=false)

// =====================================================================
// READ ME (seriously): No indicator is lag-free AND noise-free AND
// retracement-free. This script reduces false signals by (1) using
// adaptive bands instead of fixed 70/30, (2) waiting for a confirmed
// exit from the zone instead of firing on the first touch, and
// (3) optionally requiring the higher-timeframe trend to agree.
// That will cut whipsaws a lot. It will not make every trade a winner.
// =====================================================================

// === CORE SETTINGS ===
g1 = "Core RSI Settings"
rsiLength   = input.int(14, "RSI Length", group=g1)
smoothLen   = input.int(5, "RSI Smoothing (EMA)", group=g1, tooltip="Low-lag smoothing to cut micro-noise without adding much delay.")
src         = input.source(close, "Source", group=g1)

// === ADAPTIVE BANDS ===
g2 = "Adaptive Overbought/Oversold Bands"
bbLength    = input.int(50, "Band Lookback", group=g2)
bbMult      = input.float(2.0, "Band Multiplier", group=g2, step=0.1)
useAdaptive = input.bool(true, "Use Adaptive Bands (recommended)", group=g2, tooltip="If off, uses fixed levels below instead.")
fixedOB     = input.int(70, "Fixed Overbought Level", group=g2)
fixedOS     = input.int(30, "Fixed Oversold Level", group=g2)

// === CONFIRMATION / NOISE FILTER ===
g3 = "Confirmation Filter"
confirmBars = input.int(1, "Bars to Confirm Exit From Zone", minval=1, group=g3, tooltip="How many consecutive closed bars must confirm the reversal before signaling. Higher = fewer false signals, more lag.")

// === TREND FILTER ===
g4 = "Higher-Timeframe Trend Filter"
useTrendFilter = input.bool(true, "Only Trade With the Trend", group=g4)
trendTF        = input.timeframe("D", "Trend Timeframe", group=g4)
trendLen       = input.int(50, "Trend EMA Length", group=g4)

// =====================================================================
// CALCULATIONS
// =====================================================================
rawRSI    = ta.rsi(src, rsiLength)
smoothRSI = ta.ema(rawRSI, smoothLen)

// Adaptive bands via Bollinger logic on the smoothed RSI
bbBasis = ta.sma(smoothRSI, bbLength)
bbDev   = bbMult * ta.stdev(smoothRSI, bbLength)
adaptiveOB = bbBasis + bbDev
adaptiveOS = bbBasis - bbDev

overboughtLevel = useAdaptive ? adaptiveOB : fixedOB
oversoldLevel   = useAdaptive ? adaptiveOS : fixedOS

// Higher timeframe trend
trendEMA   = request.security(syminfo.tickerid, trendTF, ta.ema(close, trendLen), lookahead=barmerge.lookahead_off)
trendPrice = request.security(syminfo.tickerid, trendTF, close, lookahead=barmerge.lookahead_off)
isUptrend   = trendPrice > trendEMA
isDowntrend = trendPrice < trendEMA

// === ZONE STATE ===
inOverbought = smoothRSI >= overboughtLevel
inOversold   = smoothRSI <= oversoldLevel

// Track consecutive bars confirming an exit from the zone
var int barsOutFromOB = 0
var int barsOutFromOS = 0
wasOverbought = inOverbought[1]
wasOversold   = inOversold[1]

barsOutFromOB := wasOverbought and not inOverbought ? 1 : (not inOverbought and barsOutFromOB[1] > 0 and barsOutFromOB[1] < confirmBars ? barsOutFromOB[1] + 1 : (inOverbought ? 0 : barsOutFromOB[1]))
barsOutFromOS := wasOversold and not inOversold ? 1 : (not inOversold and barsOutFromOS[1] > 0 and barsOutFromOS[1] < confirmBars ? barsOutFromOS[1] + 1 : (inOversold ? 0 : barsOutFromOS[1]))

confirmedSellRaw = barsOutFromOB == confirmBars and barsOutFromOB[1] < confirmBars
confirmedBuyRaw  = barsOutFromOS == confirmBars and barsOutFromOS[1] < confirmBars

// Apply trend filter
confirmedSell = confirmedSellRaw and (not useTrendFilter or isDowntrend)
confirmedBuy  = confirmedBuyRaw and (not useTrendFilter or isUptrend)

// =====================================================================
// PLOTTING
// =====================================================================
rsiColor = inOverbought ? color.new(#ff0062, 0) : inOversold ? color.new(#00c3ff, 0) : color.new(#707070, 30)
plot(smoothRSI, "Smoothed RSI", color=rsiColor, linewidth=2)
plot(overboughtLevel, "Overbought Band", color=color.new(color.red, 60))
plot(oversoldLevel, "Oversold Band", color=color.new(color.teal, 60))
hline(50, "Midline", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

plotshape(confirmedSell, title="Confirmed Sell", style=shape.triangledown, location=location.top, color=#ff0062, size=size.small)
plotshape(confirmedBuy, title="Confirmed Buy", style=shape.triangleup, location=location.bottom, color=#00c3ff, size=size.small)

bgcolor(inOverbought ? color.new(#ff0062, 90) : inOversold ? color.new(#00c3ff, 90) : na)

// =====================================================================
// ALERTS
// =====================================================================
alertcondition(confirmedSell, title="Confirmed Sell Signal", message="Smart OB/OS: confirmed SELL signal (overbought exit)")
alertcondition(confirmedBuy, title="Confirmed Buy Signal", message="Smart OB/OS: confirmed BUY signal (oversold exit)")

if confirmedSell
    alert("Smart OB/OS: CONFIRMED SELL on " + syminfo.ticker + " @ " + str.tostring(close), alert.freq_once_per_bar_close)
if confirmedBuy
    alert("Smart OB/OS: CONFIRMED BUY on " + syminfo.ticker + " @ " + str.tostring(close), alert.freq_once_per_bar_close)
````
