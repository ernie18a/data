# Cipher Wave B

- url: https://www.tradingview.com/script/JDyf6XOO-Cipher-Wave-B/
- type: indicator
- pine_id: PUB;d8330e700756420b95cd58e852d31e25
- version: 1.0

## Description

Cipher Wave B bundles five classic oscillators into a single, color-coded momentum pane so you can read trend, momentum, and exhaustion at a glance — without stacking five separate indicators.
What's inside
🌊 Blue Wave (WaveTrend) — the centerpiece. A fast wave and a smoothed signal line; when the signal crosses the wave at an extreme, you get a turn. Long/short thresholds at ±60.
🟢🔴 Money Flow — a volume-weighted directional area. Fills green above zero when buyers dominate, red below when sellers do. Use it to read the environment before acting on any signal.
🟣 RSI — heavily smoothed, plotted 0–100 so you can spot divergences against price.
🟢🔴 Stochastic RSI — a smoothed line that shifts green (rising) or red (falling) to flag momentum divergences.
🟡 VWAP oscillator — a self-normalizing yellow area showing whether price is stretched above or below its volume-weighted mean. Snaps back toward zero over time.
Signals
Green dots fire on a Blue Wave cross-up while oversold (potential bottom); red dots on a cross-down while overbought (potential top). They're pinned to the bottom ribbon and intentionally selective — tune sensitivity with the Dot Level inputs. Alerts are built in for both dots and raw wave crosses (set them to "Once Per Bar Close" to avoid intrabar flicker).
Notes

Calculates on Heikin Ashi internally by default (toggle in settings) for smoother reads.
Every component, threshold, color, and dot size is adjustable.
Built on the open-source WaveTrend oscillator by LazyBear — full credit to the original author.

This is a momentum visualization tool, not a crystal ball. No oscillator predicts price. Use it to filter and confirm, manage risk, and combine timeframes — not as a standalone buy/sell machine.
Not financial advice. For educational purposes.

## Source Code

````pine
//@version=6
// =============================================================================
//  "Cipher Wave B"  —  an open-source Market Cipher B–style oscillator
//  Reverse-engineered from public descriptions (Crypto Face intro videos).
//  Built on the open-source LazyBear WaveTrend, plus MFI, RSI, Stoch RSI, VWAP.
//  Educational tool. NOT financial advice. You own this code outright.
// =============================================================================
indicator("Cipher Wave B", shorttitle="CWB", overlay=false, precision=2,
     max_bars_back=2000)

// ----------------------------------------------------------------------------
// INPUTS
// ----------------------------------------------------------------------------
grpSrc   = "Source / Candles"
useHA    = input.bool(true,  "Calculate on Heikin Ashi (like the original)", group=grpSrc)

grpWT    = "Blue Wave (WaveTrend)"
wtShow   = input.bool(true,  "Show Blue Wave",              group=grpWT)
wtChlen  = input.int(9,      "WT Channel Length",           group=grpWT, minval=1)
wtAvg    = input.int(12,     "WT Average Length",           group=grpWT, minval=1)
wtMALen  = input.int(3,      "WT Signal (light blue) Len",  group=grpWT, minval=1)
wtAmp    = input.float(1.4,  "WT Amplitude",                group=grpWT, minval=0.1, step=0.1)
wtOB1    = input.int(53,     "Overbought Trigger Line",     group=grpWT)
wtOS1    = input.int(-53,    "Oversold Trigger Line",       group=grpWT)
wtOB2    = input.int(60,     "Short Threshold",             group=grpWT)
wtOS2    = input.int(-60,    "Long Threshold",              group=grpWT)

grpMFI   = "Money Flow Index"
mfiShow  = input.bool(true,  "Show Money Flow Area",        group=grpMFI)
mfiLen   = input.int(60,     "MFI Length",                  group=grpMFI, minval=1)
mfiMult  = input.float(190., "MFI Area Scale",              group=grpMFI)
mfiPosY  = input.float(2.5,  "MFI Vertical Offset",         group=grpMFI)

grpRSI   = "RSI"
rsiShow  = input.bool(true,  "Show RSI (purple)",           group=grpRSI)
rsiLen   = input.int(14,     "RSI Length",                  group=grpRSI, minval=1)

grpStoch = "Stochastic RSI"
stShow   = input.bool(true,  "Show Stoch RSI line",         group=grpStoch)
stRsiLen = input.int(14,     "Stoch RSI: RSI Length",       group=grpStoch, minval=1)
stStoLen = input.int(14,     "Stoch RSI: Stoch Length",     group=grpStoch, minval=1)
stKSmooth= input.int(3,      "Stoch RSI: K Smoothing",      group=grpStoch, minval=1)

grpVWAP  = "VWAP Oscillator"
vwapShow = input.bool(true,  "Show VWAP Area (yellow)",     group=grpVWAP)
vwapLen  = input.int(9,      "VWAP Smoothing",              group=grpVWAP, minval=1)

grpDots  = "Signals"
dotsShow = input.bool(true,  "Show Green/Red Dots",         group=grpDots)
dotSize  = input.int(3,      "Dot Size",                    group=grpDots, minval=1, maxval=6)
dotOB    = input.int(45,     "Red Dot Level (top)",         group=grpDots)
dotOS    = input.int(-45,    "Green Dot Level (bottom)",    group=grpDots)

// ----------------------------------------------------------------------------
// SOURCE — optional internal Heikin Ashi
// ----------------------------------------------------------------------------
haTicker = ticker.heikinashi(syminfo.tickerid)
haClose  = request.security(haTicker, timeframe.period, close, lookahead=barmerge.lookahead_off)
haOpen   = request.security(haTicker, timeframe.period, open,  lookahead=barmerge.lookahead_off)
haHigh   = request.security(haTicker, timeframe.period, high,  lookahead=barmerge.lookahead_off)
haLow    = request.security(haTicker, timeframe.period, low,   lookahead=barmerge.lookahead_off)

srcClose = useHA ? haClose : close
srcOpen  = useHA ? haOpen  : open
srcHigh  = useHA ? haHigh  : high
srcLow   = useHA ? haLow   : low
srcHLC3  = (srcHigh + srcLow + srcClose) / 3.0

// ----------------------------------------------------------------------------
// 1) WAVETREND  — the "blue wave" (LazyBear WaveTrend, open source)
//    Range roughly -100..+100. wt1 = dark blue area, wt2 = light blue signal.
// ----------------------------------------------------------------------------
esa   = ta.ema(srcHLC3, wtChlen)
de    = ta.ema(math.abs(srcHLC3 - esa), wtChlen)
ci    = de != 0 ? (srcHLC3 - esa) / (0.015 * de) : 0
tci   = ta.ema(ci, wtAvg)
wt1   = tci * wtAmp               // dark blue, amplitude-boosted to match real MC-B
wt2   = ta.sma(wt1, wtMALen)      // light blue signal

// WaveTrend crosses (used for alerts; dots compute their own crosses below)
wtCrossUp   = ta.crossover(wt1, wt2)
wtCrossDown = ta.crossunder(wt1, wt2)

// ----------------------------------------------------------------------------
// 2) MONEY FLOW — green area ABOVE zero (bullish) / red area BELOW zero (bearish)
//    Transcript stresses MFI is about VOLUME of transactions, not price.
//    So weight the candle-body direction by volume, normalized.
// ----------------------------------------------------------------------------
hlRange  = srcHigh - srcLow
bodyDir  = hlRange != 0 ? (srcClose - srcOpen) / hlRange : 0   // -1..+1 candle bias
volNorm  = volume / ta.sma(volume, mfiLen)                     // relative volume
mfiUpper = ta.sma(bodyDir * volNorm * mfiMult, mfiLen)
mfi      = mfiUpper - mfiPosY
mfiUp    = mfi >= 0

// ----------------------------------------------------------------------------
// 3) RSI — heavily smoothed purple line, operates 0..100 (NOT remapped).
//    Transcript: RSI & Stoch RSI stay 0-100 on purpose, to show divergences.
//    Oversold <= 20, overbought >= 80.
// ----------------------------------------------------------------------------
rsiRaw  = ta.rsi(srcClose, rsiLen)
rsi     = ta.ema(rsiRaw, 3)          // 0..100, sits in upper zone of the pane

// ----------------------------------------------------------------------------
// 4) STOCH RSI — heavily smoothed red/green line, operates 0..100 (NOT remapped).
//    Green = bullish (rising), Red = bearish (falling).
// ----------------------------------------------------------------------------
rsi1    = ta.rsi(srcClose, stRsiLen)
stoch   = ta.stoch(rsi1, rsi1, rsi1, stStoLen)
stK     = ta.sma(stoch, stKSmooth)
stKsm   = ta.ema(stK, 3)             // 0..100
stUp    = stKsm >= stKsm[1]

// ----------------------------------------------------------------------------
// 5) VWAP OSCILLATOR — yellow area; above 0 rising, below 0 falling.
//    Auto-normalized to the band so it self-scales on any asset/timeframe
//    (no hard-coded magic multiplier that breaks when price level changes).
// ----------------------------------------------------------------------------
typicalVol = srcHLC3 * volume
rollVwap   = math.sum(typicalVol, vwapLen) / math.sum(volume, vwapLen)
vwapDiff   = ta.ema((srcClose - rollVwap) / srcClose * 100, vwapLen)
// scale by recent volatility of the diff so the yellow area fills ~±20 band
vwapStdev  = ta.stdev(vwapDiff, 100)
vwapOsc    = vwapStdev != 0 ? vwapDiff / vwapStdev * 10 : vwapDiff

// ----------------------------------------------------------------------------
// GREEN / RED DOTS  — placed exactly at the WaveTrend cross, like the original
//   wt1 = fast wave, wt2 = slow signal (sma of wt1).
//   BOTTOM: fast turns up, crosses ABOVE slow, in oversold  -> GREEN dot
//   TOP   : fast turns down, crosses BELOW slow, in overbought -> RED dot
//   Dots are plotted pinned to the bottom ribbon (see plotting section).
// ----------------------------------------------------------------------------
greenDot = ta.crossover(wt1, wt2)  and wt2 <= dotOS   // cross up in oversold = bottom
redDot   = ta.crossunder(wt1, wt2) and wt2 >= dotOB   // cross down in overbought = top

// ----------------------------------------------------------------------------
// PLOTTING
// ----------------------------------------------------------------------------
// zero & trigger lines
hline(0,    "Zero",        color=color.new(color.gray, 60))
// ±53 alarm "blue lines" (transcript calls them blue trigger/alarm lines)
hline(wtOB1,"OB Trigger",  color=color.new(#2962ff, 40), linestyle=hline.style_dotted)
hline(wtOS1,"OS Trigger",  color=color.new(#2962ff, 40), linestyle=hline.style_dotted)
// ±60 long/short thresholds for the momentum wave
hline(wtOB2,"Short Thr",   color=color.new(color.gray, 88), linestyle=hline.style_dashed)
hline(wtOS2,"Long Thr",    color=color.new(color.gray, 88), linestyle=hline.style_dashed)
// RSI/Stoch reference: oversold 20, overbought 80 (these live in the 0..100 zone)
hline(80,   "RSI OB (80)", color=color.new(color.gray, 90), linestyle=hline.style_dotted)
hline(20,   "RSI OS (20)", color=color.new(color.gray, 90), linestyle=hline.style_dotted)

// --- VWAP yellow area (drawn first, sits behind) — bold bright band at zero ---
p_vwap = plot(vwapShow ? vwapOsc : na, "VWAP Osc", color=color.new(#ffe600, 100))
p_vzero= plot(vwapShow ? 0.0     : na, "VWAP base", color=color.new(color.gray, 100), display=display.none)
fill(p_vwap, p_vzero, color=color.new(#ffd800, 35), title="VWAP Area")

// --- MFI green/red area (green fills above zero, red below — like real MC-B) ---
p_mfi  = plot(mfiShow ? mfi : na, "MFI", color=color.new(color.gray, 100))
p_mzero= plot(mfiShow ? 0.0 : na, "MFI base", color=color.new(color.gray, 100), display=display.none)
fill(p_mfi, p_mzero, color=mfiUp ? color.new(#26a69a, 35) : color.new(#ef5350, 35), title="Money Flow Area")

// --- WaveTrend blue wave (the star: fat area from zero + signal line) ---
// wt1 = main wave drawn as a thick filled area down to zero (dark blue)
// wt2 = light blue signal line riding on top
zeroLine = plot(0.0, "zero base", color=color.new(color.gray, 100), display=display.none)
p_wt1 = plot(wtShow ? wt1 : na, "WT1 (blue wave)",  color=color.new(#3a9ff5, 0), linewidth=2)
fill(zeroLine, p_wt1, color=color.new(#2196f3, 35), title="Blue Wave Fill")
plot(wtShow ? wt2 : na, "WT2 (light blue signal)", color=color.new(#cfeaff, 0), linewidth=2)

// --- RSI purple line (0..100, mapped onto the same pane) ---
plot(rsiShow ? rsi : na, "RSI", color=color.new(#9c27b0, 0), linewidth=2)

// --- Stoch RSI red/green line ---
stCol = stUp ? #00e676 : #ff5252
plot(stShow ? stKsm : na, "Stoch RSI", color=color.new(stCol, 0), linewidth=2)

// --- bottom ribbon (the colored bar at the very bottom) ---
ribbonY = -108.0
plot(ribbonY, "Ribbon", color=mfiUp ? color.new(#26a69a, 0) : color.new(#ef5350, 0),
     linewidth=4, style=plot.style_linebr)

// --- dots --- pinned to the bottom ribbon, exactly like Crypto Face's chart.
// Green buy dots sit ON the ribbon at the bottom; reds slightly above it.
plot(dotsShow and greenDot ? ribbonY : na, "Green Dot", color=#00e676,
     style=plot.style_circles, linewidth=dotSize)
plot(dotsShow and redDot   ? ribbonY : na, "Red Dot",   color=#ff1744,
     style=plot.style_circles, linewidth=dotSize)

// ----------------------------------------------------------------------------
// ALERTS
// ----------------------------------------------------------------------------
alertcondition(greenDot, "Green Dot (Buy)",  "CWB: Green Dot buy signal")
alertcondition(redDot,   "Red Dot (Sell)",   "CWB: Red Dot sell signal")
alertcondition(wtCrossUp,   "Blue Wave Cross Up",   "CWB: WaveTrend cross up")
alertcondition(wtCrossDown, "Blue Wave Cross Down", "CWB: WaveTrend cross down")
````
