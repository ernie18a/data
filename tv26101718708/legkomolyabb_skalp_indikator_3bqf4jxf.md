# Legkomolyabb skalp indikator

- url: https://www.tradingview.com/script/3bQF4jxf-Legkomolyabb-skalp-indikator/
- type: indicator
- pine_id: PUB;41eb787d1aac48c7b0d4d3076af278e3
- version: 1.0

## Description

The main components of the script:

Triple Confirmation (Strategy)
Price exhaustion: The price moves outside ATR-based bands (overextended movement).
Momentum extreme: The RSI gives an overbought or oversold signal.
Structural reversal: A signal is only generated once a Pivot point (swing high or swing low) forms, confirming the reversal.
Trend Filter (EMA 200)

I integrated a 200 EMA. By default, you only receive:

Buy signals when the price is above the EMA (buying pullbacks in an uptrend),
Sell signals when the price is below the EMA.

This helps avoid losing trades against the main trend.

Risk Management (SL/TP)
The system automatically calculates the Stop-Loss level using ATR (volatility-based), giving the trade enough room to breathe.
The Take-Profit level is set automatically according to the selected risk/reward ratio (default: 1:2).
How to use it on the chart
Green triangles indicate buy opportunities.
Red triangles indicate sell opportunities.
The dashed/solid lines (red and green) show suggested exit levels after entry.

You can fine-tune the RSI levels or the trend filter anytime in the settings menu (gear icon).

Tip

If you use it on highly volatile markets (such as crypto), it’s recommended to increase the ATR multiplier (“Volatility Multiplier”) to 2.5 or 3.0 so the system only signals truly extreme exhaustion moves.

## Source Code

````pine

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("High-Prob Reversal V2", shorttitle="Reversal V2", overlay = true, max_labels_count = 500)

// --- Groups ---
string G_CORE   = "Core Settings"
string G_FILTER = "Trend Filter"
string G_EXIT   = "Risk Management"
string G_STYLE  = "Visuals"

// --- Inputs ---
int rsiLen      = input.int(14, "RSI Length", minval = 1, group = G_CORE)
float rsiOB     = input.float(70, "RSI Overbought", minval = 50, group = G_CORE)
float rsiOS     = input.float(30, "RSI Oversold", maxval = 50, group = G_CORE)
int volLen      = input.int(20, "Band Length", minval = 1, group = G_CORE)
float volMult   = input.float(1.5, "Volatility Multiplier", minval = 0.5, step = 0.1, group = G_CORE, tooltip = "Lower = More signals, Higher = More selective")

bool useFilter  = input.bool(false, "Use Trend Filter (EMA 200)", group = G_FILTER, tooltip = "If ON, only buys in uptrend and sells in downtrend.")
int emaLen      = input.int(200, "EMA Length", minval = 1, group = G_FILTER)

float rrRatio   = input.float(2.0, "Risk/Reward Ratio", minval = 0.1, step = 0.1, group = G_EXIT)
float slAtrMult = input.float(1.0, "SL ATR Multiplier", minval = 0.1, step = 0.1, group = G_EXIT)

color BULL_COLOR = input.color(#089981, "Bullish Color", group = G_STYLE)
color BEAR_COLOR = input.color(#f23645, "Bearish Color", group = G_STYLE)
color NEUT_COLOR = input.color(#5b9cf6, "Neutral Color", group = G_STYLE)

// --- Calculations ---
rsi     = ta.rsi(close, rsiLen)
sma     = ta.sma(close, volLen)
atr     = ta.atr(volLen)
ema     = ta.ema(close, emaLen)
upper   = sma + (atr * volMult)
lower   = sma - (atr * volMult)

// Pivot Points (Lookback 2, Lookforward 2)
pLo = ta.pivotlow(low, 2, 2)
pHi = ta.pivothigh(high, 2, 2)

// Logic: Check conditions at the time of the pivot (2 bars ago)
bool exhaustionLong  = low[2] < lower[2] and rsi[2] < rsiOS
bool exhaustionShort = high[2] > upper[2] and rsi[2] > rsiOB

bool trendLong  = not useFilter or low[2] > ema[2]
bool trendShort = not useFilter or high[2] < ema[2]

bool buySignal  = not na(pLo) and exhaustionLong and trendLong
bool sellSignal = not na(pHi) and exhaustionShort and trendShort

// --- SL/TP Logic ---
var float slPrice = na
var float tpPrice = na
var int activeDir = 0

if buySignal
    activeDir := 1
    slPrice := low[2] - (atr[2] * slAtrMult)
    float risk = close - slPrice
    tpPrice := close + (risk * rrRatio)

if sellSignal
    activeDir := -1
    slPrice := high[2] + (atr[2] * slAtrMult)
    float risk = slPrice - close
    tpPrice := close - (risk * rrRatio)

// Reset if hit
if (activeDir == 1 and (low <= slPrice or high >= tpPrice)) or (activeDir == -1 and (high >= slPrice or low <= tpPrice))
    activeDir := 0
    slPrice := na
    tpPrice := na

// --- Visuals ---
pSma = plot(sma, "Basis", color = color.new(NEUT_COLOR, 85))
pUp  = plot(upper, "Upper Band", color = color.new(BEAR_COLOR, 60))
pLo_ = plot(lower, "Lower Band", color = color.new(BULL_COLOR, 60))

fill(pUp, pSma, upper, sma, color.new(BEAR_COLOR, 90), color.new(BEAR_COLOR, 100), "Upper Fill")
fill(pLo_, pSma, sma, lower, color.new(BULL_COLOR, 100), color.new(BULL_COLOR, 90), "Lower Fill")

plot(useFilter ? ema : na, "Trend EMA", color = color.new(NEUT_COLOR, 50), linewidth = 2)

plotshape(buySignal, "Buy", shape.labelup, location.belowbar, BULL_COLOR, size = size.small, text = "BUY", textcolor = color.white)
plotshape(sellSignal, "Sell", shape.labeldown, location.abovebar, BEAR_COLOR, size = size.small, text = "SELL", textcolor = color.white)

plot(slPrice, "Stop Loss", color = color.new(color.red, 20), style = plot.style_linebr, linewidth = 2)
plot(tpPrice, "Take Profit", color = color.new(color.green, 20), style = plot.style_linebr, linewidth = 2)

// Alerts
alertcondition(buySignal, "Bullish Reversal", "Long Signal")
alertcondition(sellSignal, "Bearish Reversal", "Short Signal")
````
