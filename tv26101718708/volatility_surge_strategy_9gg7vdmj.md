# Volatility Surge Strategy

- url: https://www.tradingview.com/script/9gg7vdMj/
- type: strategy
- pine_id: PUB;a9df2e21a28f483babd29bd366517d00
- version: 1.0

## Description

█ OVERVIEW

Volatility Surge Strategy (VSS) is an original indicator inspired by the concept of the Williams VIX Fix — a method of measuring the depth of price decline from a recent high to replicate VIX-like behavior on any instrument.

This script is a fully independent implementation built from scratch. The core calculation concept (drop depth from highest close) is a publicly known mathematical formula with no copyright. All Pine Script code is original.

█ HOW IT WORKS

• Volatility Index (VI): Measures how far the current low has dropped from the highest close over a lookback period, expressed as a percentage.
• BB Filter: Applies a Bollinger Band to the VI. When VI exceeds the upper band, a volatility spike is detected.
• Switch Signal: Triggers an entry when the candle direction flips (bearish → bullish or vice versa) while a spike is still active — catching the moment momentum begins to shift.

█ ENTRY LOGIC

• Bullish Switch: Spike active on two consecutive bars + previous bar bearish + current bar bullish → Long entry
• Bearish Switch: Spike active on two consecutive bars + previous bar bullish + current bar bearish → Short entry
• All entries fire only on confirmed bars (barstate.isconfirmed)

█ RISK MANAGEMENT

• Stop Loss: ATR × SL Multiplier below/above entry close
• Take Profit: SL distance × Risk/Reward Ratio
• Fixed lot size (1 unit default)
• Commission: 0.05% per side | Slippage: 2 ticks

█ SETTINGS

Volatility Index
• Lookback Period (default 22) — reference window for highest close; increase to reduce sensitivity

BB Filter
• BB Period (default 20) — smoothing window for VI
• BB Multiplier (default 2.0) — spike detection threshold; increase to require stronger moves

Risk Management
• ATR Period (default 14)
• SL ATR Multiplier (default 1.5)
• Risk/Reward Ratio (default 1.5)

█ ALERTS

• High Volatility — VI crosses above the upper band (either candle direction)
• Bullish Switch — spike active, candle flips bearish → bullish
• Bearish Switch — spike active, candle flips bullish → bearish

Set alerts to "Once Per Bar Close" for best accuracy.

█ NOTES

• This indicator works best as a filter or confirmation tool combined with trend direction, key levels, or divergence signals.
• Short timeframes tend to produce noise; higher timeframes (daily and above) show more stable results in testing.
• Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
// ================================================================
// Volatility Surge Strategy [VSS]
// Original implementation
// ① Volatility Index (VI): Drop depth from highest close over N bars
// ② Bollinger Band filter: Detect volatility spikes
// ③ Switch signal: Enter on bullish/bearish candle flip during spike
// ================================================================
strategy(
    title             = "Volatility Surge Strategy",
    shorttitle        = "VSS",
    overlay           = false,
    default_qty_type  = strategy.fixed,
    default_qty_value = 1,
    commission_type   = strategy.commission.percent,
    commission_value  = 0.05,
    slippage          = 2
)

// ── Parameters ──────────────────────────────────────────────────
var g_vi = "Volatility Index"
var g_bb = "BB Filter"
var g_rm = "Risk Management"

lookback  = input.int  (22,  title="Lookback Period",     minval=5, maxval=200, group=g_vi)
bbPeriod  = input.int  (20,  title="BB Period",           minval=5,             group=g_bb)
bbMult    = input.float(2.0, title="BB Multiplier",       minval=0.5, maxval=5, group=g_bb, step=0.1)
atrPeriod = input.int  (14,  title="ATR Period",          minval=1,             group=g_rm)
atrMult   = input.float(1.5, title="SL ATR Multiplier",   minval=0.5, maxval=5, group=g_rm, step=0.1)
rrRatio   = input.float(1.5, title="Risk/Reward Ratio",   minval=0.5, maxval=5, group=g_rm, step=0.1)

// ── Volatility Index ────────────────────────────────────────────
// Drop depth (%) from highest close over lookback bars to current low
highest_c = ta.highest(close, lookback)
vi        = (highest_c - low) / highest_c * 100

// ── Bollinger Band Filter ───────────────────────────────────────
vi_sma   = ta.sma(vi, bbPeriod)
vi_stdev = ta.stdev(vi, bbPeriod)
vi_upper = vi_sma + bbMult * vi_stdev

// ── Conditions ──────────────────────────────────────────────────
isHigh  = vi >= vi_upper        // Volatility spike active
isBull  = close > open          // Current bar is bullish
wasBull = close[1] > open[1]    // Previous bar was bullish

// Switch: candle direction flips while spike is still active
bullSwitch = isHigh[1] and isHigh and isBull  and not wasBull
bearSwitch = isHigh[1] and isHigh and not isBull and wasBull

// ── ATR-based SL / TP ───────────────────────────────────────────
atr = ta.atr(atrPeriod)

// ── Strategy Entries ────────────────────────────────────────────
if bullSwitch and barstate.isconfirmed
    strategy.entry("BUY", strategy.long)
    strategy.exit("BUY_X", "BUY",
         stop  = close - atr * atrMult,
         limit = close + atr * atrMult * rrRatio)

if bearSwitch and barstate.isconfirmed
    strategy.entry("SELL", strategy.short)
    strategy.exit("SELL_X", "SELL",
         stop  = close + atr * atrMult,
         limit = close - atr * atrMult * rrRatio)

// ── Visuals ─────────────────────────────────────────────────────
// Histogram: spike = yellow (bullish) / red (bearish), normal = gray
barCol = isHigh
     ? (isBull ? color.rgb(255, 220, 0) : color.rgb(255, 60, 60))
     : color.rgb(110, 110, 110)

plot(vi,       title="VI (Histogram)", style=plot.style_histogram, linewidth=4, color=barCol)
plot(vi_upper, title="Upper Band",     color=color.new(color.aqua, 50), linewidth=1)
plot(vi_sma,   title="Mid (SMA)",      color=color.new(color.gray, 60), linewidth=1)

// Switch markers
plotshape(bullSwitch, title="Bull Switch",
     style=shape.triangleup,   location=location.bottom,
     color=color.yellow, size=size.small)
plotshape(bearSwitch, title="Bear Switch",
     style=shape.triangledown, location=location.top,
     color=color.red,    size=size.small)

// ── Alerts ──────────────────────────────────────────────────────
alertcondition(isHigh       and barstate.isconfirmed, title="High Volatility", message="{{ticker}}, {{interval}}: Volatility Surge Detected")
alertcondition(bullSwitch   and barstate.isconfirmed, title="Bullish Switch",  message="{{ticker}}, {{interval}}: Bullish Switch")
alertcondition(bearSwitch   and barstate.isconfirmed, title="Bearish Switch",  message="{{ticker}}, {{interval}}: Bearish Switch")
````
