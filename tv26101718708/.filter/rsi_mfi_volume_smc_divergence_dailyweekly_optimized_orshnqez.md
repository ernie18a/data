# RSI + MFI + Volume + SMC + Divergence [Daily/Weekly Optimized]

- url: https://www.tradingview.com/script/ORshnQEz-RSI-MFI-Volume-SMC-Divergence-Daily-Weekly-Optimized/
- type: indicator
- pine_id: PUB;1bf83b0e070e4b7e9bf74aa98ca19124
- version: 1.0

## Description

RSI + MFI + Volume + SMC + Divergence [Daily/Weekly Optimized ,works on 2 weeks also )
very good to see the bothems and the tops.

## Source Code

````pine
//@version=5
indicator("RSI + MFI + Volume + SMC + Divergence [Daily/Weekly Optimized]", shorttitle="RSI-MFI D/W Pro", overlay=true, max_lines_count=500)

// ── Instellingen ─────────────────────────────────────
rsiLen   = input.int(14, "RSI Lengte", minval=1)
mfiLen   = input.int(14, "MFI Lengte", minval=1)
volLen   = input.int(30, "Volume MA Lengte", minval=1)   // langer op D/W

rsiOS    = input.int(35, "RSI Oversold Level", minval=20, maxval=50)   // milder
rsiOB    = input.int(65, "RSI Overbought Level", minval=50, maxval=80)
mfiOS    = input.int(25, "MFI Oversold Level", minval=10, maxval=40)
mfiOB    = input.int(75, "MFI Overbought Level", minval=60, maxval=90)

volMult  = input.float(1.4, "Volume Multiplier", minval=1.0, step=0.1)

useTrend = input.bool(true, "200 EMA Trend Filter (aanbevolen)")
useSMC   = input.bool(true, "Smart Money Filter")
useDiv   = input.bool(true, "RSI Divergence Filter")

swingLen = input.int(12, "Swing Lookback voor SMC & Divergence", minval=5)

// ── Berekeningen ─────────────────────────────────────
rsi   = ta.rsi(close, rsiLen)
mfi   = ta.mfi(hlc3, mfiLen)
volMA = ta.sma(volume, volLen)
osc   = (rsi + mfi) / 2

ema200 = ta.ema(close, 200)

// Trend
bullTrend = not useTrend or close > ema200
bearTrend = not useTrend or close < ema200

// Smart Money
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

// ── Buy & Sell Signals (beter gebalanceerd) ──────────
buySignal  = ta.crossover(rsi, rsiOS) and mfi <= mfiOS and volume > volMA * volMult and 
             bullTrend and smcBull and (not useDiv or bullDiv)

sellSignal = ta.crossunder(rsi, rsiOB) and mfi >= mfiOB and volume > volMA * volMult and 
             bearTrend and smcBear and (not useDiv or bearDiv)

// ── Oscillator pane ──────────────────────────────────
plot(osc, title="RSI + MFI Osc", color=osc > 50 ? color.new(color.green, 0) : color.new(color.red, 0), linewidth=2)
hline(rsiOS, "Oversold", color=color.new(color.green, 0), linestyle=hline.style_dashed)
hline(50, "Midden", color=color.new(color.gray, 50))
hline(rsiOB, "Overbought", color=color.new(color.red, 0), linestyle=hline.style_dashed)

plot(rsi, "RSI", color=color.new(color.orange, 70))
plot(mfi, "MFI", color=color.new(color.fuchsia, 70))

// ── Verticale lijnen + labels op de prijschart ───────
if buySignal
    line.new(bar_index, low * 0.99, bar_index, high * 1.01, xloc=xloc.bar_index, extend=extend.both, color=color.new(color.lime, 15), width=3)
    label.new(bar_index, high * 1.02, "BUY", color=color.lime, textcolor=color.black, style=label.style_label_down, size=size.normal)

if sellSignal
    line.new(bar_index, low * 0.99, bar_index, high * 1.01, xloc=xloc.bar_index, extend=extend.both, color=color.new(color.red, 15), width=3)
    label.new(bar_index, low * 0.98, "SELL", color=color.red, textcolor=color.white, style=label.style_label_up, size=size.normal)

// Achtergrond oscillator
bgcolor(buySignal ? color.new(color.green, 90) : sellSignal ? color.new(color.red, 90) : na)

// ── Alerts ───────────────────────────────────────────
alertcondition(buySignal,  "Strong BUY",  "🚀 STRONG BUY op Daily/Weekly!")
alertcondition(sellSignal, "Strong SELL", "🔴 STRONG SELL op Daily/Weekly!")
````
