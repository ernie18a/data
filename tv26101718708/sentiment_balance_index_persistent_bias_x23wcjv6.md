# Sentiment Balance Index - Persistent Bias

- url: https://www.tradingview.com/script/x23WcJv6-Sentiment-Balance-Index-Persistent-Bias/
- type: indicator
- pine_id: PUB;13e3658e96994720af54ca6431418592
- version: 1.0

## Description

[b]Sentiment Balance Index (SBI) — Persistent Bias[/b] 

The Sentiment Balance Index is a centered momentum oscillator that measures the balance between buying and selling pressure on a -100 to +100 scale, where zero means gains and losses are perfectly balanced. It's mathematically equivalent to a standard RSI rescaled around zero (SBI = 2 × RSI − 100), so it carries the same information as RSI but in a format that makes bullish vs. bearish dominance immediately visible — positive values mean sentiment leans bullish, negative values mean it leans bearish.

How it works

*Price moves (either close-to-close change or candle body) are split into up-moves and down-moves, each smoothed independently using your choice of moving average (Wilder's RMA, EMA, SMA, WMA, or HMA).

*Moves can optionally be normalized by ATR, making the oscillator less sensitive to changing volatility regimes.

*The result can be further smoothed with an output EMA for a cleaner line.

Persistent Bias Engine

[url=https://www.tradingview.com/x/RsFiP0Lz/]https://www.tradingview.com/x/RsFiP0Lz/[/url]

Unlike a simple zero-cross indicator, SBI tracks a sticky trend state that only flips when price convincingly crosses to the opposite side of an adjustable dead-zone band — it doesn't reset itself just because the oscillator dips back toward zero. This filters out minor chop and only signals genuine regime changes. Bull/bear flip markers, background tinting, and alerts can all be set to fire only on confirmed (closed) bars, preventing repainting from intrabar noise.

Overbought/Oversold Zones

Adjustable upper and lower zone lines work like classic RSI's 70/30 levels, giving a visual reference for stretched conditions on the -100/+100 scale.

Inputs

*Source, lookback length, move definition (close change or candle body)
*Smoothing method and optional output smoothing
*Optional ATR normalization
*Adjustable flip threshold (dead-zone band)
*Adjustable overbought/oversold levels
*Confirmed-bar-only signals toggle
*Full color/style customization

This is a trend/momentum tool best used alongside price structure or other confirmation — like any oscillator, it can stay pinned at bullish or bearish extremes during strong trends.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//@version=6
indicator("Sentiment Balance Index - Persistent Bias", shorttitle="Sentiment Balance Index ", overlay=false, precision=2)


// ── Inputs ────────────────────────────────────────────────────────────
grpCalc = "Calculation"
priceSrc   = input.source(close, "Source (Close change mode)", group=grpCalc)
lookback   = input.int(14, "Length", minval=2, group=grpCalc)

grpZones = "Overbought / Oversold Zones"
upperZone  = input.float(50.0, "Overbought level", minval=0.0, maxval=100.0, step=1.0, group=grpZones, tooltip="Upper zone line, like classic RSI overbought (e.g. 70 on a 0-100 scale ≈ 40 here since MPO is 2x centered RSI).")
lowerZone  = input.float(-50.0, "Oversold level", minval=-100.0, maxval=0.0, step=1.0, group=grpZones, tooltip="Lower zone line, like classic RSI oversold.")


smoothKind = input.string("RMA (Wilder)", "Gain/Loss smoothing", options=["RMA (Wilder)", "EMA", "SMA", "WMA", "HMA"], group=grpCalc)
moveMode   = input.string("Close change", "Move definition", options=["Close change", "Candle body"], group=grpCalc, tooltip="Close change = priceSrc - priceSrc[1]. Candle body = close - open.")
useAtrNorm = input.bool(false, "Normalize moves by ATR", group=grpCalc)
atrLength  = input.int(14, "ATR length", minval=1, group=grpCalc)
outSmoothLen = input.int(1, "Output smoothing (EMA, 1 = off)", minval=1, group=grpCalc)



grpBias = "Bias / Signals"
flipBand     = input.float(15, "Flip threshold (± band)", minval=0.0, maxval=99.0, step=1.0, group=grpBias, tooltip="0 = pure zero-cross flip. Above 0 adds a dead zone: trend state flips to bull only above +band and to bear only below -band, otherwise it holds.")
confirmClose = input.bool(true, "Signals/alerts on bar close only", group=grpBias, tooltip="When on, the trend state itself only updates on a confirmed (closed) bar, so it cannot flicker intrabar and then reverse.")


grpStyle = "Style"
bullCol  = input.color(#26a69a, "Bull colour", group=grpStyle)
bearCol  = input.color(#ef5350, "Bear colour", group=grpStyle)
showHist = input.bool(true, "Show histogram", group=grpStyle)
showBg   = input.bool(false, "Tint background on flips", group=grpStyle)

// ── Helpers ───────────────────────────────────────────────────────────


smoothMA(srcVal, len, kind) =>
    val = switch kind
        "RMA (Wilder)" => ta.rma(srcVal, len)
        "EMA" => ta.ema(srcVal, len)
        "SMA" => ta.sma(srcVal, len)
        "WMA" => ta.wma(srcVal, len)
        "HMA" => ta.hma(srcVal, len)
        => ta.rma(srcVal, len)
    math.max(val, 0.0)

// ── Calculation ───────────────────────────────────────────────────────
atrVal   = ta.atr(atrLength)
rawMove  = moveMode == "Candle body" ? close - open : priceSrc - priceSrc[1]
netMove  = useAtrNorm and atrVal > 0 ? rawMove / atrVal : rawMove

upMove   = math.max(netMove, 0.0)
downMove = math.max(-netMove, 0.0)
avgUp    = smoothMA(upMove, lookback, smoothKind)
avgDown  = smoothMA(downMove, lookback, smoothKind)
totalMove = avgUp + avgDown

float pulseRaw    = na(totalMove) ? na : (totalMove > 0 ? 100.0 * (avgUp - avgDown) / totalMove : 0.0)
float pulseSmooth = ta.ema(pulseRaw, outSmoothLen)

// ── Persistent-state trend (confirmed-close only) ───────────────────────
var int trendState = 0
if not na(pulseSmooth) and (not confirmClose or barstate.isconfirmed)
    if pulseSmooth > flipBand
        trendState := 1
    else if pulseSmooth < -flipBand
        trendState := -1

trendFlipUp   = trendState == 1 and nz(trendState[1]) != 1
trendFlipDown = trendState == -1 and nz(trendState[1]) != -1
barReady      = not confirmClose or barstate.isconfirmed

// ── Plots ─────────────────────────────────────────────────────────────
plotColor = trendState == 1 ? bullCol : trendState == -1 ? bearCol : color.gray

hline(0, "Zero", color=color.gray, linestyle=hline.style_dashed)
plot(flipBand > 0 ? flipBand : na, "+Band", color=color.new(color.gray, 50), style=plot.style_linebr)
plot(flipBand > 0 ? -flipBand : na, "-Band", color=color.new(color.gray, 50), style=plot.style_linebr)

plot(upperZone, "Overbought", color=color.new(bearCol, 40), style=plot.style_line)
plot(lowerZone, "Oversold", color=color.new(bullCol, 40), style=plot.style_line)

plot(showHist ? pulseSmooth : na, "SBI Histogram", color=color.new(plotColor, 65), style=plot.style_columns)
plot(pulseSmooth, "SBI", color=plotColor, linewidth=2)

plotshape(trendFlipUp and barReady, "Bull flip", style=shape.triangleup, location=location.bottom, color=bullCol, size=size.tiny)
plotshape(trendFlipDown and barReady, "Bear flip", style=shape.triangledown, location=location.top, color=bearCol, size=size.tiny)

bgcolor(showBg and trendFlipUp and barReady ? color.new(bullCol, 85) : showBg and trendFlipDown and barReady ? color.new(bearCol, 85) : na)

// ── Alerts ────────────────────────────────────────────────────────────
alertcondition(trendFlipUp and barReady, "SBI Bull Flip", "SBI flipped BULLISH on {{ticker}} ({{interval}})")
alertcondition(trendFlipDown and barReady, "SBI Bear Flip", "SBI flipped BEARISH on {{ticker}} ({{interval}})")
````
