# CCI Regime Oscillator

- url: https://www.tradingview.com/script/R1Xog6Lv-CCI-Regime-Oscillator/
- type: indicator
- pine_id: PUB;b0afa110f3924e6097303a6803e5e07e
- version: 1.0

## Description

CCI Regime Oscillator:
Using CCI coloring to visualize the deviation of current price to histroical price trends

Functions:
1. Help to determin Bullish, Bearish, or Nutruel (Green line, Red line, or Grey line)
2. Indicates Buy Dip (Green dot) or Sell Top (Red dot) at very early stage

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
//Written by @Felix_Hsu
indicator(title="CCI Regime Oscillator", shorttitle="CCI-Regime", overlay=false, precision=1)

// ==========================================
// Output:
//   1. Regime Line — 3-color CCI (bull / bear / neutral)
//   2. Extreme Signals — independent long/short at deep OB/OS
//
// No Signal line, no Histogram, no redundancy with WT.
// ==========================================

// ==========================================
// Inputs
// ==========================================
string GRP_CORE = "CCI Settings"
autoParam    = input.bool(false,   "Auto Parameters",       group=GRP_CORE)
cciLen       = input.int(20,       "CCI Length",             minval=2, group=GRP_CORE)
normLen      = input.int(100,      "Normalization Lookback", minval=20, group=GRP_CORE)

string GRP_ZONE = "Regime & Zone Settings"
regimeThresh = input.int(20,       "Regime Threshold (±)",   minval=5,  maxval=40, group=GRP_ZONE)
obLevel      = input.int(60,       "Extreme Overbought",     minval=50, maxval=90, group=GRP_ZONE)
osLevel      = input.int(-60,      "Extreme Oversold",       minval=-90, maxval=-50, group=GRP_ZONE)

// ==========================================
// Auto Parameter Mapping
// ==========================================
_tf = timeframe.period

autoCciLen = _tf == "1" ? 10 : _tf == "2" ? 12 : _tf == "3" ? 13 : _tf == "4" ? 14 : _tf == "5" ? 14 : _tf == "10" ? 16 : _tf == "15" ? 20 : _tf == "30" ? 25 : _tf == "45" ? 28 : _tf == "60" ? 30 : _tf == "120" ? 34 : _tf == "240" ? 40 : timeframe.isdaily ? 40 : timeframe.isweekly ? 50 : cciLen

autoNormLen = _tf == "1" ? 60 : _tf == "2" ? 70 : _tf == "3" ? 75 : _tf == "4" ? 80 : _tf == "5" ? 80 : _tf == "10" ? 90 : _tf == "15" ? 100 : _tf == "30" ? 100 : _tf == "45" ? 120 : _tf == "60" ? 120 : _tf == "120" ? 150 : _tf == "240" ? 200 : timeframe.isdaily ? 200 : timeframe.isweekly ? 200 : normLen

autoOB = _tf == "1" ? 55 : _tf == "5" ? 60 : _tf == "15" ? 60 : _tf == "60" ? 65 : _tf == "240" ? 70 : 60
autoOS = -autoOB

// Apply auto params
cciLen  := autoParam ? autoCciLen  : cciLen
normLen := autoParam ? autoNormLen : normLen
obLevel := autoParam ? autoOB      : obLevel
osLevel := autoParam ? autoOS      : osLevel

// ==========================================
// Core Calculation
// ==========================================
src    = ohlc4
rawCci = ta.cci(src, cciLen)

// Normalize to ±100 via percentrank
// percentrank(0–100) → rescale to -100–+100
cci = (ta.percentrank(rawCci, normLen) - 50) * 2

// ==========================================
// Regime Classification
// ==========================================
bool isBull    = cci > regimeThresh
bool isBear    = cci < -regimeThresh
bool isNeutral = not isBull and not isBear

// ==========================================
// Extreme Zone Signals (independent)
// ==========================================
bool isOB = cci >= obLevel
bool isOS = cci <= osLevel

// Detect turning points within extreme zones:
// Oversold + CCI trough (turned up) → long signal
// Overbought + CCI peak (turned down) → short signal
bool cciTurnedUp   = cci > cci[1] and cci[1] <= cci[2]
bool cciTurnedDown = cci < cci[1] and cci[1] >= cci[2]

bool extremeLong  = isOS and cciTurnedUp
bool extremeShort = isOB and cciTurnedDown

// ==========================================
// Visual: Zone Background
// ==========================================
hOB  = hline(60,    "Overbought",  color=color.new(color.red, 70),   linestyle=hline.style_dashed)
hTop = hline(100,   "Top",         color=color.new(color.gray, 90))
hOS  = hline(-60,   "Oversold",    color=color.new(color.green, 70), linestyle=hline.style_dashed)
hBot = hline(-100,  "Bottom",      color=color.new(color.gray, 90))
hline(0, "Zero Line", color=color.new(color.gray, 60), linestyle=hline.style_dotted)

fill(hOB, hTop, color=color.new(color.red, 92),   title="Overbought Zone")
fill(hOS, hBot, color=color.new(color.green, 92),  title="Oversold Zone")

// ==========================================
// Visual: Regime Line (3-color)
// ==========================================
color regimeColor = isBull ? color.new(#26a69a, 0) : isBear ? color.new(#ef5350, 0) : color.new(color.gray, 30)

plot(cci, title="CCI Regime", color=regimeColor, linewidth=2)

// ==========================================
// Visual: Extreme Zone Signals
// ==========================================
plotshape(extremeLong  ? cci : na, title="Extreme Long",  style=shape.circle,   location=location.absolute, color=color.new(#26a69a, 0), size=size.tiny)
plotshape(extremeShort ? cci : na, title="Extreme Short", style=shape.circle, location=location.absolute, color=color.new(#ef5350, 0), size=size.tiny)

// ==========================================
// Alerts
// ==========================================
alertcondition(extremeLong,  title="CCI Extreme Long",  message="CCI-Regime: Extreme oversold entry — LONG signal")
alertcondition(extremeShort, title="CCI Extreme Short", message="CCI-Regime: Extreme overbought entry — SHORT signal")
alertcondition(isBull and not isBull[1], title="CCI Regime → Bull", message="CCI-Regime shifted to BULL regime")
alertcondition(isBear and not isBear[1], title="CCI Regime → Bear", message="CCI-Regime shifted to BEAR regime")
````
