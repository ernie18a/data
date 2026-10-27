# Plasma Flow  [LunqFX]

- url: https://www.tradingview.com/script/nd82mhQf-Plasma-Flow-LunqFX/
- type: indicator
- pine_id: PUB;f2ac4ceb3d334ec0946b20318d3f21e7
- version: 2.0

## Description

Plasma Flow is a VWAP-based market regime and signal engine designed to help traders answer one question before taking any trade:

Is the market actually tradable right now?

Most VWAP tools only show where price is relative to fair value. Plasma Flow goes further by measuring how price is behaving around VWAP through four live dimensions: velocity, pressure, turbulence, and multi-timeframe flow bias.

The goal is simple:
filter out noisy conditions, highlight cleaner environments, and rank signals by quality instead of printing entries everywhere.


WHAT THIS INDICATOR DOES

Plasma Flow builds a dynamic VWAP structure with inner and outer statistical bands, then evaluates the market through a regime model.

[image]https://www.tradingview.com/x/NBGzAjwB/[/image]

It shows:

• Regime — whether the market is in Laminar Flow, Expansion, Contraction, Breakout, or Consolidation
• Velocity — how fast VWAP is moving relative to current volatility
• Pressure — how far price is stretched from VWAP
• Turbulence — whether the market is calm enough to trust signals
• Flow Bias — whether current and higher timeframes agree on direction
• Signal Quality — a simple 1 to 5 score for each setup
• Next Target — the nearest projected band level from current price

This makes Plasma Flow useful both as a standalone decision tool and as a market-condition filter for existing strategies.

💡 WHAT IS VWAP AND WHY IT MATTERS

VWAP stands for Volume Weighted Average Price. It is the 
average price that all buyers and sellers have paid over a 
period of time, weighted by how much volume traded at each 
price. Banks, hedge funds and institutional traders use VWAP 
as their primary benchmark.

Here is why this matters for you:

When price is far above VWAP, institutions look to sell.
When price is far below VWAP, institutions look to buy.
This creates a gravitational pull — price tends to return 
to VWAP after stretching too far in either direction.

Plasma Flow measures exactly how far price has stretched, 
whether the stretch is real or just noise, and whether 
conditions favor a snap-back entry right now.

📏 WHAT IS σ (SIGMA) — EXPLAINED SIMPLY

Sigma (σ) is a measure of distance from average, adjusted 
for how volatile the market currently is.

Think of it like this:

On a calm day, if price moves $10 away from VWAP that might 
be extreme. On a volatile day, $10 is nothing — price does 
that every 5 minutes. Sigma automatically adjusts for this.

1.0σ = price is moderately stretched from VWAP
2.0σ = price is significantly stretched — reversal zone  
3.0σ = price is at an extreme — statistically rare

The outer bands on the chart are drawn at ±1.5σ and ±2.8σ. 
When price touches the 1.5σ band, that is your entry trigger. 
When price reaches 2.8σ, that is your hard stop and extreme 
take-profit zone. No guessing required — the math does it.

🌊 THE 5 MARKET REGIMES — WHAT EACH MEANS

The Regime banner is the first thing to check every time 
you open a chart. Here is what each state means in plain 
English and what to do in each one:

LAMINAR FLOW — 🟢 Best conditions

The market is moving smoothly and predictably. Price is 
trending cleanly without random spikes and reversals. 
Institutional flow is dominant — retail noise is low.

What to do: This is when you trade. All signals that fire 
in LAMINAR FLOW have the highest probability. Watch for 
signal labels and check the Quality Score. LAMINAR + ★★★ 
or above is your ideal setup.

EXPANSION — 🟡 Momentum building

Price is accelerating away from VWAP. Momentum is building 
and the market is starting to trend. This can precede a 
breakout or a sharp reversal when it runs out of energy.

What to do: Do not fight the move. If a LONG signal fires 
during EXPANSION, it is a trend-continuation play. 
If you are already in a trade, hold and trail your stop.

CONTRACTION — 🟠 Energy compressing

Price is pulling back toward VWAP after a stretch. Momentum 
is slowing. This is the mean-reversion sweet spot — price 
returning from an extreme to its fair value.

What to do: Watch carefully. This is often when the best 
reversal signals appear. A SHORT signal during CONTRACTION 
after a high-sigma stretch is a high-quality mean-reversion 
trade. Check pressure reading — if it is HIGH or EXTREME, 
the snap-back is likely strong.

BREAKOUT — 🔴 High volatility, be careful

Price has broken outside the normal bands and volatility 
is spiking. This can be a genuine trend start or a stop-hunt 
followed by reversal. Either way — unpredictable.

What to do: No new entries. If you are in a trade already, 
tighten your stop or take partial profits immediately. 
Wait for the regime to stabilize back to LAMINAR before 
looking for new entries. Chasing breakouts is where most 
retail traders lose money.

CONSOLIDATION — ⚫ No edge, no trade

Price is stuck in a tight range around VWAP. There is no 
clear direction and no momentum. Both buyers and sellers 
are balanced — nobody is winning. Signals that fire here 
have low follow-through and are not worth trading.

What to do: Close the chart and find another instrument. 
There is no edge here. Trading consolidation is paying 
spread and swap for random outcomes.

🌀 WHAT IS TURBULENCE — THE MOST IMPORTANT NUMBER

Turbulence is the single most important reading in the panel. 
Think of it exactly like weather turbulence on a flight.

When turbulence is low — the flight is smooth, you can 
walk around the cabin, everything is predictable.

When turbulence is high — even experienced pilots tell 
everyone to sit down and buckle up, because they cannot 
predict what comes next.

Markets work the same way.

Turbulence measures how erratic current price movement is 
compared to the past 50 bars of normal behavior. It compares 
right-now volatility to the average volatility baseline.

CALM (below 0.8) — The market is in smooth, predictable flow. 
Price movements follow logic. This is when signals fire and 
when trades have the highest probability of working.

MIXED (0.8 to 1.3) — Some noise present. Signals still appear 
but reduce your position size. Not ideal but tradeable with 
caution.

CHAOTIC (above 1.3) — The market is erratic and unpredictable. 
No signals fire in this state regardless of what price does. 
This is by design — these are exactly the conditions where 
indicator-based trading fails and accounts get damaged.

This gating system alone — suppressing all signals when 
turbulence is too high — is what separates Plasma Flow 
from 90% of indicators on TradingView that generate signals 
regardless of market conditions.

⚡ VELOCITY — IS MOMENTUM REAL OR FAKE?

Standard momentum indicators measure raw price speed. 
The problem is that a 50-pip move on a calm Tuesday is 
very different from a 50-pip move during NFP news. 
Raw speed without context is meaningless.

Plasma Flow measures velocity as price speed divided by 
current market noise. This means you are always seeing 
momentum relative to what is normal for right now, 
not what was normal 3 months ago.

CRASH — Price is collapsing extremely fast relative to 
current volatility. A powerful move with real force behind it. 
Mean-reversion coming.

FALLING / DOWN — Bearish momentum of varying strength.
FLAT — No meaningful direction. Market is resting.
UP / RISING — Bullish momentum building.

SURGE — Price is spiking extremely fast. Same logic as CRASH 
but in reverse — a powerful move that often exhausts itself.

When VELOCITY shows CRASH or SURGE at the same time as 
PRESSURE shows HIGH or EXTREME, you have the most powerful 
mean-reversion setups the indicator produces.


🔭 WHY 3 TIMEFRAMES INSTEAD OF ONE

[image]https://www.tradingview.com/x/cxS0gCqV/[/image]

Here is a common trap: you are trading on the 15-minute 
chart and see a perfect LONG signal. But on the 1-hour chart, 
price is in a clear downtrend. You enter long — and price 
drops straight through your stop loss.

Your lower timeframe signal was technically correct.
The higher timeframe context invalidated it completely.

Plasma Flow solves this by computing VWAP velocity 
independently on three timeframes simultaneously — your 
current chart, plus two higher timeframes (default H1 and H4). 
It then shows you in the panel whether all three are pointing 
in the same direction.

3/3 — Full alignment. All timeframes agree. 
Highest conviction entries. Size up.

2/3 — Partial alignment. Two out of three agree.
Acceptable entry. Standard size.

1/3 — Conflicting signals. Timeframes disagree.
Skip the trade entirely. The market has no clear direction.

This multi-timeframe filter alone prevents a large percentage 
of the false entries that kill most trading strategies.

⭐ QUALITY SCORE — YOUR POSITION SIZING GUIDE

Every signal gets a score from 1 to 5 stars. Think of this 
as a confidence rating that tells you how much to risk.

★☆☆☆☆  POOR
Only one condition was met. This signal has no edge above 
random chance. Do not trade it. Use it only for practice 
or study.

★★☆☆☆  WEAK
Minimum threshold reached. Two conditions aligned. 
If you trade it, use half your normal position size 
and tighter stop. Acceptable for scalpers only.

★★★☆☆  GOOD
Three conditions aligned. This is a genuine signal with 
real statistical backing. Standard entry with your 
normal risk per trade.

★★★★☆  STRONG
Four conditions aligned. Everything is working together — 
pressure, turbulence, and timeframe alignment are all 
confirming. This is a high-conviction entry. 
Consider sizing up 1.5x your standard risk.

★★★★★  PERFECT
All conditions simultaneously optimal. Extreme pressure, 
very clean turbulence, full 3/3 timeframe alignment and 
combined condition bonus all triggered at once. 
This happens rarely — when it does, it tends to be 
the highest quality trade of the week or month.

📋 HOW TO TRADE WITH PLASMA FLOW
Step-by-step — from chart open to trade close

STEP 1 — Open the chart and check REGIME first.
Look at the colored banner at the top of the panel.
LAMINAR FLOW = green light. Anything else = caution or skip.

STEP 2 — Check TURBULENCE.
CALM only for full-size entries. MIXED = half size max.
CHAOTIC = close the chart and find another instrument today.

STEP 3 — Check FLOW BIAS.
Look at the three timeframe arrows. Need 2/3 minimum.
If the arrows conflict (one up, two down or vice versa), 
wait for alignment before looking for entries.

STEP 4 — Wait for a signal label on the chart.
▲ LONG appears below price in green.
▼ SHORT appears above price in red.
The label shows star rating and sigma reading.

STEP 5 — Read the sigma on the label.
This tells you how stretched price is right now.
-1.58σ on a LONG means price is 1.58 standard deviations 
below VWAP — a meaningful stretch with reversal potential.
Higher absolute value = stronger mean-reversion setup.

STEP 6 — Confirm Quality Score is ★★★ or above.
Below ★★★ = skip or paper trade only. 
★★★ to ★★★★★ = real entry with appropriate size.

STEP 7 — Set your stop loss.
For swing trades: just beyond the outer band (2.8σ level).
For scalps and day trades: just beyond the inner band 
(1.5σ level on the other side of VWAP).

STEP 8 — Use NEXT TGT as take-profit reference.
The panel shows the nearest VWAP band from current price 
with percentage distance. This is your first target. 
At minimum take 50% off at NEXT TGT and trail the rest.

STEP 9 — Monitor REGIME while in the trade.
If regime switches to TURBULENT or BREAKOUT after entry,
exit the trade immediately regardless of P&L. 
The market conditions that validated your entry no longer 
exist. Do not wait for price to confirm — get out.


⚙️ SETTINGS EXPLAINED FOR BEGINNERS


VWAP Window — default 50
This is how many bars are used to calculate the average.
Smaller number = faster, more signals, more noise.
Larger number = slower, fewer but cleaner signals.
Day traders on M15: try 20-30.
Swing traders on H4: try 80-100.
Start with default 50 and only change after you understand 
how the indicator behaves on your instrument.

Inner Band σ — default 1.5
This is the trigger line for signals. At 1.5 sigma, 
price is moderately stretched — enough to have a reversal 
edge but not so extreme that you are always waiting.
Increase to 2.0 if you only want to trade very stretched 
extremes. Decrease to 1.2 for more frequent signals.

Outer Band σ — default 2.8
This is the extreme zone. Price reaching here is statistically 
rare — less than 5% of the time. Use this as your hard stop 
reference and maximum stretch target.

Cooldown Bars — default 5
After a signal fires, no new signal can appear for this 
many bars. This prevents the indicator from giving you 
3 signals in a row on the same price level.
On M15 increase to 10. On H1 keep at 5.

Reversal Filter — default ON
Requires a real reversal candle (pin bar or engulfing) 
for the signal to appear. This removes the majority of 
false entries. Keep it ON unless you know what you are doing.

TF 2 and TF 3 — default H1 and H4
The two higher timeframes used for confluence calculation.
For crypto day trading try H4 and D1.
For M5 scalping try M15 and H1.
The default H1 and H4 works well for most forex instruments.

🌍 WHAT MARKETS AND TIMEFRAMES

Plasma Flow works on any liquid market with volume data:

Forex majors and minors — EURUSD, GBPUSD, USDJPY, 
AUDUSD, USDCAD, EURGBP and all crosses

Crypto — BTCUSD, ETHUSD, SOLUSD and all major pairs 
on Binance, Coinbase, Bybit

Commodities — XAUUSD (Gold), XAGUSD (Silver), USOIL, UKOIL

Indices — SPX500, NAS100, DAX40, FTSE100, NIKKEI

Stocks — Any US or EU stock with meaningful daily volume

Best timeframes by trading style:
Scalping    → M5, M15 (set TF2=M15, TF3=H1)
Day trading → M15, H1 (default settings)
Swing trade → H4, D1  (set TF2=D1, TF3=W1, Window=80)


⚠️ RISK DISCLAIMER

Plasma Flow is an analytical tool designed to support 
your trading decisions. It does not guarantee profitable 
trades. All financial markets carry significant risk of 
loss, including your entire account balance.

Use proper position sizing on every trade. Never risk 
more than 1-2% of your account on a single signal. 
Backtest thoroughly on your specific instrument and 
timeframe before using real money. Past signal accuracy 
does not guarantee future performance.

Trading is risky. Use this tool as part of a complete 
trading plan that includes risk management rules you 
follow every single time without exception.

## Source Code

````pine
// © LunqFX
//@version=6
indicator("Plasma Flow  ·  LunqFX", shorttitle="PF·LFX", overlay=true,
          max_labels_count=400, max_lines_count=100)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grpC = "Core"
vwLen   = input.int(50,    "VWAP Window",          minval=10, maxval=500, group=grpC)
stdM1   = input.float(1.5, "Inner Band sigma",      minval=0.5, step=0.1,  group=grpC)
stdM2   = input.float(2.8, "Outer Band sigma",      minval=1.0, step=0.1,  group=grpC)

grpS = "Signals"
showSig = input.bool(true, "Show Signals",          group=grpS)
sigCool = input.int(5,     "Cooldown (bars)",        group=grpS)
useFltr = input.bool(true, "Reversal Candle Filter", group=grpS)
showPnl = input.bool(true, "Show Panel",             group=grpS)

grpT = "Multi-Timeframe"
tf2 = input.timeframe("60",  "TF 2", group=grpT)
tf3 = input.timeframe("240", "TF 3", group=grpT)

// ══════════════════════════════════════════════════════════════════════════════
//  CHART PALETTE
// ══════════════════════════════════════════════════════════════════════════════
C_CYAN   = #00D4FF
C_MINT   = #00FFA3
C_VIOLET = #7B2FFF
C_ORANGE = #FF6B35
C_RED    = #FF2055
C_BLUE   = #0088FF
C_GOLD   = #FFD700
C_DIM    = #556677
C_PANEL  = #060810

// ══════════════════════════════════════════════════════════════════════════════
//  CORE MATH
// ══════════════════════════════════════════════════════════════════════════════
src = hlc3

vwNum = math.sum(src * volume, vwLen)
vwDen = math.sum(volume, vwLen)
vwap  = vwDen > 0.0 ? vwNum / vwDen : src

vwStd = math.sqrt(math.sum(volume * math.pow(src - vwap, 2), vwLen) /
                  math.max(vwDen, 1.0))

b1T = vwap + vwStd * stdM1
b1B = vwap - vwStd * stdM1
b2T = vwap + vwStd * stdM2
b2B = vwap - vwStd * stdM2

velRaw   = ta.roc(vwap, 3)
vel      = ta.ema(velRaw / math.max(vwStd, syminfo.mintick), 8)

turbRaw  = ta.stdev(vel, 20)
turbAvg  = ta.sma(turbRaw, 50)
turbIdx  = turbAvg > 0.0 ? turbRaw / turbAvg : 1.0

press    = vwStd > 0.0 ? (src - vwap) / vwStd : 0.0
pressEma = ta.ema(press, 5)

regScore = math.max(0.0, math.min(100.0, (1.5 - turbIdx) / 1.5 * 100.0))

isLaminar   = turbIdx < 0.8
isTurbulent = turbIdx > 1.3
isBreakout  = math.abs(pressEma) > 2.0
isExpand    = vel > 0.3
isContract  = vel < -0.3

phase    = isBreakout ? "BREAKOUT"     :
           isExpand   ? "EXPANSION"    :
           isContract ? "CONTRACTION"  :
           isLaminar  ? "LAMINAR FLOW" : "CONSOLIDATION"

phaseCol = isBreakout ? C_GOLD   :
           isExpand   ? C_MINT   :
           isContract ? C_ORANGE :
           isLaminar  ? C_CYAN   : C_VIOLET

// ══════════════════════════════════════════════════════════════════════════════
//  MULTI-TIMEFRAME CONFLUENCE
// ══════════════════════════════════════════════════════════════════════════════
f_tfVel(tf) =>
    _vw  = math.sum(hlc3 * volume, 50) / math.max(math.sum(volume, 50), 1.0)
    _std = math.max(math.sqrt(math.sum(volume * math.pow(hlc3 - _vw, 2), 50) /
                              math.max(math.sum(volume, 50), 1.0)), syminfo.mintick)
    _vel = ta.ema(ta.roc(_vw, 3) / _std, 8)
    request.security(syminfo.tickerid, tf, _vel, lookahead=barmerge.lookahead_off)

vel2 = f_tfVel(tf2)
vel3 = f_tfVel(tf3)

bull1 = vel  > 0.15
bull2 = vel2 > 0.10
bull3 = vel3 > 0.05

alignCount = (bull1 ? 1 : 0) + (bull2 ? 1 : 0) + (bull3 ? 1 : 0)
bearCount  = ((not bull1) ? 1 : 0) + ((not bull2) ? 1 : 0) + ((not bull3) ? 1 : 0)
isBullBias = alignCount >= bearCount
bestAlign  = math.max(alignCount, bearCount)

// ══════════════════════════════════════════════════════════════════════════════
//  SIGNALS
// ══════════════════════════════════════════════════════════════════════════════
atr14    = ta.atr(14)
entLong  = ta.crossover(src,  b1B) and pressEma < -0.8 and isLaminar
entShort = ta.crossunder(src, b1T) and pressEma >  0.8 and isLaminar

rng   = high - low
body  = math.abs(close - open)
bWick = math.min(close, open) - low
tWick = high - math.max(close, open)
pinB  = bWick > body * 2.0 and bWick > rng * 0.5
pinBr = tWick > body * 2.0 and tWick > rng * 0.5
engB  = close > open and close[1] < open[1] and close > open[1] and open <= close[1]
engBr = close < open and close[1] > open[1] and close < open[1] and open >= close[1]
patB  = pinB  or engB  or pinB[1]  or engB[1]
patBr = pinBr or engBr or pinBr[1] or engBr[1]

var int  lastSigIdx = na
sigRdy  = na(lastSigIdx) or bar_index - lastSigIdx >= sigCool
goLong  = showSig and entLong  and sigRdy and (not useFltr or patB)
goShort = showSig and entShort and sigRdy and (not useFltr or patBr)

if goLong or goShort
    lastSigIdx := bar_index

var bool lastWasLong = false
if goLong
    lastWasLong := true
if goShort
    lastWasLong := false

// ── Quality score
var int q = 1
q := 1
if math.abs(pressEma) > 2.0
    q := q + 1
if turbIdx < 0.5
    q := q + 1
if bestAlign == 3
    q := q + 1
if turbIdx < 0.4 and math.abs(pressEma) > 1.8
    q := q + 1
q := math.min(5, q)

var int lastQual = 1
if goLong or goShort
    lastQual := q

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_sigma(v) =>
    s = str.tostring(math.abs(v), "#.##") + "σ"
    v >= 0.0 ? "+" + s : "-" + s

f_ago(idx) =>
    d = bar_index - idx
    d == 0 ? "now" : str.tostring(d) + "b ago"

f_velWord(v) =>
    v > 2.0 ? "SURGE" : v > 0.8 ? "RISING" : v > 0.2 ? "UP" : v > -0.2 ? "FLAT" : v > -0.8 ? "DOWN" : v > -2.0 ? "FALLING" : "CRASH"

f_bar(pct, w) =>
    n = math.round(math.max(0.0, math.min(100.0, pct)) / 100.0 * w)
    str.repeat("▰", n) + str.repeat("▱", w - n)

f_dot(isBull) =>
    isBull ? "●" : "○"

// ══════════════════════════════════════════════════════════════════════════════
//  CHART VISUALS
// ══════════════════════════════════════════════════════════════════════════════
vwapCol = color.from_gradient(math.max(-3.0, math.min(3.0, vel * 5.0)) * 100.0 / 3.0 + 100.0,
                               0, 200, C_ORANGE, C_MINT)

pClamp  = math.max(-1.0, math.min(1.0, pressEma))
fillTop = color.from_gradient(pClamp * 100.0 + 100.0, 0, 200,
                               color.new(C_MINT, 88), color.new(C_ORANGE, 80))
fillBot = color.from_gradient(pClamp * 100.0 + 100.0, 0, 200,
                               color.new(C_BLUE, 80), color.new(C_RED, 88))

pB2T = plot(b2T,  "Outer Top", color=color.new(C_RED,    65), linewidth=1)
pB1T = plot(b1T,  "Band Top",  color=color.new(C_ORANGE, 15), linewidth=2)
pVWP = plot(vwap, "VWAP",      color=vwapCol,                 linewidth=2)
pB1B = plot(b1B,  "Band Bot",  color=color.new(C_BLUE,   15), linewidth=2)
pB2B = plot(b2B,  "Outer Bot", color=color.new(C_VIOLET, 65), linewidth=1)

fill(pB2T, pB1T, color=color.new(C_RED,    95))
fill(pB1T, pVWP, fillTop)
fill(pVWP, pB1B, fillBot)
fill(pB1B, pB2B, color=color.new(C_VIOLET, 95))

barcolor(color.from_gradient(pClamp * 100.0 + 100.0, 0, 200,
                              color.new(C_BLUE, 25), color.new(C_ORANGE, 25)))

// ── Signal labels
// Prevent label overlap: track bar_index and price of the last label
// and shift the new one down if it is too close
var int   lastLongBar   = na
var float lastLongPrice = na
var int   lastShortBar  = na
var float lastShortPrice = na

if goLong
    _baseY = b1B - atr14 * 1.2
    // If the previous LONG label is close in bars — shift this one lower
    _offsetMult = (not na(lastLongBar) and bar_index - lastLongBar < 15) ? 2.5 : 1.2
    _y = b1B - atr14 * _offsetMult
    _lTxt = "▲  LONG\n" + str.repeat("★", q) + "   " + f_sigma(pressEma)
    label.new(bar_index, _y,
              _lTxt,
              color     = color.new(#00E676, 0),
              textcolor = color.new(#021A0D, 0),
              style     = label.style_label_up,
              size      = size.normal)
    lastLongBar   := bar_index
    lastLongPrice := _y

if goShort
    _offsetMult = (not na(lastShortBar) and bar_index - lastShortBar < 15) ? 2.5 : 1.2
    _y = b1T + atr14 * _offsetMult
    _sTxt = "▼  SHORT\n" + str.repeat("★", q) + "   " + f_sigma(pressEma)
    label.new(bar_index, _y,
              _sTxt,
              color     = color.new(#FF4444, 0),
              textcolor = color.new(#1A0202, 0),
              style     = label.style_label_down,
              size      = size.normal)
    lastShortBar   := bar_index
    lastShortPrice := _y

// ══════════════════════════════════════════════════════════════════════════════
//  PANEL COLORS
// ══════════════════════════════════════════════════════════════════════════════

// Backgrounds
_bg0  = color.new(#0D1117, 0)
_bg1  = color.new(#111820, 0)
_bg2  = color.new(#151F2E, 0)
_sepC = color.new(#1E2D42, 0)
_phBg = color.new(phaseCol, 50)

// Text hierarchy
_C_LBL = color.new(#6B8CAE, 0)
_C_VAL = color.new(#D8E4F0, 0)
_C_HDR = color.new(#E8F4FF, 0)
_C_BRN = color.new(#4A6FA8, 0)

// Semantic accents
_C_BULL = color.new(#26D07C, 0)
_C_BEAR = color.new(#F05050, 0)
_C_NEUT = color.new(#4A6080, 0)
_C_GOLD = color.new(#E8B84B, 0)
_C_INFO = color.new(#5BA3D9, 0)

// Regime
_rCol  = regScore > 60 ? _C_BULL : regScore > 30 ? _C_GOLD : _C_BEAR
_rName = isLaminar ? "LAMINAR" : isTurbulent ? "TURBULENT" : "MIXED"

// Velocity
_vWord = f_velWord(vel * 3.0)
_vVal  = str.tostring(vel * 100.0, "#.0")
_vCol  = vel > 0.2 ? _C_BULL : vel < -0.2 ? _C_BEAR : _C_NEUT

// Pressure
_pAbs = math.abs(pressEma)
_pCol = _pAbs > 2.0 ? _C_BEAR : _pAbs > 1.0 ? _C_GOLD : _C_INFO
_pLbl = _pAbs > 2.0 ? "EXTREME" : _pAbs > 1.5 ? "HIGH" : _pAbs > 0.8 ? "MED" : "LOW"
_pPct = math.min(100.0, _pAbs / stdM2 * 100.0)

// Turbulence
_tCol = turbIdx < 0.8 ? _C_BULL : turbIdx > 1.3 ? _C_BEAR : _C_GOLD
_tLbl = turbIdx < 0.8 ? "CALM" : turbIdx > 1.3 ? "CHAOTIC" : "MIXED"
_tVal = str.tostring(turbIdx, "#.##")
_tPct = math.min(100.0, turbIdx / 2.0 * 100.0)

// Flow bias
_aLbl = bestAlign == 3 ? "FULL ALIGN" : bestAlign == 2 ? "PARTIAL" : "DIVERGED"
_aCol = bestAlign == 3 ? _C_GOLD : bestAlign == 2 ? _C_INFO : _C_NEUT
_tf1C = bull1 ? _C_BULL : _C_BEAR
_tf2C = bull2 ? _C_BULL : _C_BEAR
_tf3C = bull3 ? _C_BULL : _C_BEAR
_tf1T = "  " + timeframe.period + (bull1 ? "  ▲" : "  ▼")
_tf2T = tf2 + (bull2 ? "  ▲" : "  ▼")
_tf3T = tf3 + (bull3 ? "  ▲" : "  ▼") + "  "

// Signal
_sLbl = na(lastSigIdx) ? "-" : (lastWasLong ? "▲  BUY" : "▼  SELL")
_sCol = na(lastSigIdx) ? _C_NEUT : lastWasLong ? _C_BULL : _C_BEAR
_agoS = na(lastSigIdx) ? "-" : f_ago(lastSigIdx)

// Quality
_qScore = na(lastSigIdx) ? "-" : str.tostring(lastQual) + " / 5"
_qDesc  = lastQual >= 5 ? "PERFECT" : lastQual >= 4 ? "STRONG" : lastQual >= 3 ? "GOOD" : lastQual >= 2 ? "WEAK" : "POOR"
_qCol   = lastQual >= 4 ? _C_GOLD : lastQual >= 3 ? _C_INFO : _C_NEUT

// Next target
_ntLvl  = pressEma >= 0.0 ? (src < b1T ? b1T : b2T) : (src > b1B ? b1B : b2B)
_ntDist = math.abs(_ntLvl - src) / src * 100.0
_ntStr  = str.tostring(_ntDist, "#.##") + "%  "
_ntPrc  = str.tostring(_ntLvl, format.mintick)
_ntCol  = pressEma >= 0.0 ? _C_BULL : _C_BEAR

// ATR
atrAvg   = ta.sma(atr14, 50)
atrRatio = atrAvg > 0.0 ? atr14 / atrAvg : 1.0
_atrLbl  = atrRatio > 1.5 ? "HIGH" : atrRatio > 0.8 ? "NORMAL" : "LOW"
_atrCol  = atrRatio > 1.5 ? _C_BEAR : atrRatio > 0.8 ? _C_INFO : _C_BULL
_atrVal  = str.tostring(atr14, format.mintick) + "  "
_atrPct  = math.min(100.0, atrRatio / 2.0 * 100.0)

// Volume
volAvg   = ta.sma(volume, 20)
volRatio = volAvg > 0.0 ? volume / volAvg : 1.0
_volLbl  = volRatio > 1.5 ? "HIGH" : volRatio > 0.8 ? "AVG" : "LOW"
_volCol  = volRatio > 1.5 ? _C_GOLD : volRatio > 0.8 ? _C_INFO : _C_NEUT
_volVal  = str.tostring(math.round(volRatio * 100.0)) + "%  "
_volPct  = math.min(100.0, volRatio / 2.0 * 100.0)

// ══════════════════════════════════════════════════════════════════════════════
//  INFO PANEL
// ══════════════════════════════════════════════════════════════════════════════
if barstate.islast and showPnl
    var table T = table.new(position.bottom_right, 3, 21,
                             bgcolor      = color.new(#0D1117, 0),
                             frame_color  = color.new(#1E2D42, 40),
                             frame_width  = 1,
                             border_color = color.new(#1A2535, 0),
                             border_width = 0)

    // ROW 0 - Header
    table.cell(T, 0, 0, "▸ PLASMA FLOW",
               text_color=_C_HDR, bgcolor=_bg0,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 0, "", bgcolor=_bg0, text_size=size.tiny)
    table.cell(T, 2, 0, "LunqFX  ",
               text_color=_C_BRN, bgcolor=_bg0,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 1 - Phase
    table.cell(T, 0, 1, "▸▸ " + phase,
               text_color=color.new(#FFFFFF, 0), bgcolor=_phBg,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 1, f_sigma(pressEma),
               text_color=color.new(#FFFFFF, 20), bgcolor=_phBg,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 1, str.tostring(math.round(regScore)) + "%  ",
               text_color=color.new(#FFFFFF, 20), bgcolor=_phBg,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 2 - Separator
    table.cell(T, 0, 2, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 2, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 2, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 3 - Regime
    table.cell(T, 0, 3, "  REGIME",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 3, f_bar(regScore, 8) + " " + _rName,
               text_color=_rCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 3, str.tostring(math.round(regScore)) + "%  ",
               text_color=_rCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 4 - Separator
    table.cell(T, 0, 4, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 4, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 4, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 5 - Separator
    table.cell(T, 0, 5, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 5, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 5, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 6 - Velocity
    table.cell(T, 0, 6, "  VELOCITY",
               text_color=_C_LBL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 6, _vWord,
               text_color=_vCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 6, _vVal + "  ",
               text_color=_C_VAL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 7 - Pressure
    table.cell(T, 0, 7, "  PRESSURE",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 7, f_bar(_pPct, 8) + " " + _pLbl,
               text_color=_pCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 7, f_sigma(pressEma) + "  ",
               text_color=_pCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 8 - Turbulence
    table.cell(T, 0, 8, "  TURBULENCE",
               text_color=_C_LBL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 8, f_bar(_tPct, 8) + " " + _tLbl,
               text_color=_tCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 8, _tVal + "  ",
               text_color=_C_VAL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 9 - Separator
    table.cell(T, 0, 9, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 9, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 9, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 10 - Flow Bias
    table.cell(T, 0, 10, "  FLOW BIAS",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 10, f_bar(bestAlign / 3.0 * 100.0, 8),
               text_color=_aCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 10, _aLbl + "  ",
               text_color=_aCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 11 - TF dots
    table.cell(T, 0, 11, _tf1T,
               text_color=_tf1C, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 11, _tf2T,
               text_color=_tf2C, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 11, _tf3T,
               text_color=_tf3C, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 12 - Alignment bar
    table.cell(T, 0, 12, "", bgcolor=_bg2, text_size=size.tiny)
    table.cell(T, 1, 12, f_bar(bestAlign / 3.0 * 100.0, 12),
               text_color=_aCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 12, str.tostring(bestAlign) + "/3  ",
               text_color=_aCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 13 - Separator
    table.cell(T, 0, 13, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 13, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 13, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 14 - Signal
    table.cell(T, 0, 14, "  SIGNAL",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 14, _sLbl,
               text_color=_sCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 14, _agoS + "  ",
               text_color=_C_VAL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 15 - Quality
    table.cell(T, 0, 15, "  QUALITY",
               text_color=_C_LBL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 15, _qScore,
               text_color=_qCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 15, _qDesc + "  ",
               text_color=_qCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 16 - Separator
    table.cell(T, 0, 16, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 16, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 16, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 17 - Next Target
    table.cell(T, 0, 17, "  NEXT TGT",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 17, _ntPrc,
               text_color=_ntCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 17, _ntStr,
               text_color=_C_VAL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 18 - Separator
    table.cell(T, 0, 18, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 1, 18, "", bgcolor=_sepC, text_size=size.tiny)
    table.cell(T, 2, 18, "", bgcolor=_sepC, text_size=size.tiny)

    // ROW 19 - ATR
    table.cell(T, 0, 19, "  ATR",
               text_color=_C_LBL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 19, f_bar(_atrPct, 8) + " " + _atrLbl,
               text_color=_atrCol, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 19, _atrVal,
               text_color=_C_VAL, bgcolor=_bg2,
               text_size=size.normal, text_halign=text.align_right)

    // ROW 20 - Volume
    table.cell(T, 0, 20, "  VOLUME",
               text_color=_C_LBL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 20, f_bar(_volPct, 8) + " " + _volLbl,
               text_color=_volCol, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_center)
    table.cell(T, 2, 20, _volVal,
               text_color=_C_VAL, bgcolor=_bg1,
               text_size=size.normal, text_halign=text.align_right)
````
