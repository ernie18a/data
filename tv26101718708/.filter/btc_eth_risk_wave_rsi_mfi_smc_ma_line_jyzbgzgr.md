# BTC ETH Risk Wave  RSI MFI SMC MA line

- url: https://www.tradingview.com/script/JyZbGZGR-BTC-ETH-Risk-Wave-RSI-MFI-SMC-MA-line/
- type: indicator
- pine_id: PUB;41275227da4a42e385ee5b189ee32f28
- version: 1.0

## Description

RSI + MFI + SMC Oscillator (RSI‑MA based)**  

This oscillator combines **RSI** and **Money Flow Index (MFI)** into one unified momentum line with a built‑in **moving‑average line (RSI‑MA)**, making overbought/oversold levels and trend momentum easy to see. RSI and MFI are also displayed separately in the same pane so you can quickly compare all signals in one view.  

The indicator uses your own **volume multiplier** and **Smart Money Concept filter (SMC)** to show signals only when higher‑than‑average volume and potential “smart money” patterns align. The layout is designed for clear, integrated oscillator‑style trading in a separate lower pane, without overlaying the price chart.

## Source Code

````pine
//@version=5
indicator("RSI+MFI+SMC Oscillator (RSI‑MA line)", 
     shorttitle="RSI+MFI Osc", 
     overlay=false, 
     max_lines_count=500)


// ── Instellingen ─────────────────────────────────────
rsiLen   = input.int(14, "RSI Lengte", minval=1)
mfiLen   = input.int(14, "MFI Lengte", minval=1)
volLen   = input.int(30, "Volume MA Lengte", minval=1)

rsiOS    = input.int(35, "RSI Oversold Level", minval=20, maxval=50)
rsiOB    = input.int(65, "RSI Overbought Level", minval=50, maxval=80)
mfiOS    = input.int(25, "MFI Oversold Level", minval=10, maxval=40)
mfiOB    = input.int(75, "MFI Overbought Level", minval=60, maxval=90)

volMult  = input.float(1.4, "Volume Multiplier", minval=1.0, step=0.1)

useTrend = input.bool(true, "200 EMA Trend Filter (aanbevolen)")
useSMC   = input.bool(true, "Smart Money Filter")
useDiv   = input.bool(true, "RSI Divergence Filter")

swingLen = input.int(12, "Swing Lookback voor SMC & Divergence", minval=5)

oscMA_len = input.int(9, "Oscillator MA Lengte (RSI+MFI)", minval=2)


// ── Berekeningen (alleen nodig voor de oscillator) ──
rsi   = ta.rsi(close, rsiLen)
mfi   = ta.mfi(hlc3, mfiLen)
volMA = ta.sma(volume, volLen)
osc   = (rsi + mfi) / 2
oscMA = ta.sma(osc, oscMA_len)

ema200 = ta.ema(close, 200)


// Trend (optioneel voor extra signalen)
bullTrend = not useTrend or close > ema200
bearTrend = not useTrend or close < ema200


// Smart Money (SMC‑filter, gebruikt in alerts)
bullSwingLow  = low == ta.lowest(low, swingLen)
bearSwingHigh = high == ta.highest(high, swingLen)
bullVolSpike  = volume > volMA * 1.7
bearVolSpike  = volume > volMA * 1.7
bullLiq       = low < ta.lowest(low[1], 8) and close > open
bearLiq       = high > ta.highest(high[1], 8) and close < open

smcBull = not useSMC or (bullSwingLow or bullVolSpike or bullLiq)
smcBear = not useSMC or (bearSwingHigh or bearVolSpike or bearLiq)


// ── RSI Divergence (bullish & bearish) ───────────────
bullDiv = useDiv and (low < low[1] and rsi > rsi[1]) and (low < low[2] and rsi > rsi[2])
bearDiv = useDiv and (high > high[1] and rsi < rsi[1]) and (high > high[2] and rsi < rsi[2])


// ── Buy & Sell Signals (alleen voor alerts) ──────────
buySignal  = ta.crossover(rsi, rsiOS) and 
             mfi <= mfiOS and 
             volume > volMA * volMult and      // volume multiplier
             bullTrend and 
             smcBull and 
             (not useDiv or bullDiv)

sellSignal = ta.crossunder(rsi, rsiOB) and 
             mfi >= mfiOB and 
             volume > volMA * volMult and      // volume multiplier
             bearTrend and 
             smcBear and 
             (not useDiv or bearDiv)


// ── Oscillator pane (onderaan) ───────────────────────
plot(osc,   title="RSI + MFI Osc", color=osc > 50 ? color.new(color.green, 0) : color.new(color.red, 0), linewidth=2)
plot(oscMA, title="Oscillator MA (RSI‑based)", color=color.new(color.blue, 0), linewidth=1, style=plot.style_line)

hline(rsiOS, "Oversold", color=color.new(color.green, 0), linestyle=hline.style_dashed)
hline(50, "Midden", color=color.new(color.gray, 50))
hline(rsiOB, "Overbought", color=color.new(color.red, 0), linestyle=hline.style_dashed)

plot(rsi, "RSI", color=color.new(color.orange, 70))
plot(mfi, "MFI", color=color.new(color.fuchsia, 70))


// ── Alerts (optioneel) ───────────────────────────────
alertcondition(buySignal,  "Strong BUY Osc",  "🚀 STRONG BUY (RSI+MFI Oscillator)")
alertcondition(sellSignal, "Strong SELL Osc", "🔴 STRONG SELL (RSI+MFI Oscillator)")
````
