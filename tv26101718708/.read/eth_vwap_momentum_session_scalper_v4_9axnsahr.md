# ETH VWAP Momentum Session Scalper v4

- url: https://www.tradingview.com/script/9AxNsAhr-ETH-VWAP-Momentum-Session-Scalper-v4/
- type: indicator
- pine_id: PUB;e6a06546702e4a109b2be893a09524fc
- version: 1.0

## Description

It watches price on the chart and tries to identify good buy or sell moments based on a mix of trend, momentum, volume, and volatility checks. When the conditions line up, it draws the signal on the chart and shows entry, stop-loss, and target levels.

How it decides to buy
It gives a BUY signal when:

Price is above VWAP, which suggests bullish bias.

The candle closes strong, not weak.

RSI, MACD, EMA trend, higher-timeframe trend, and volume filters all support the move if those filters are turned on.

The trade happens only during your chosen session if session filtering is enabled.

How it decides to sell
It gives a SELL signal when:

Price is below VWAP, which suggests bearish bias.

The candle closes weak, not strong.

RSI, MACD, EMA trend, higher-timeframe trend, and volume filters all support the downside if enabled.

The trade is inside the selected session if that filter is on.

What the lines mean
After a signal:

Entry shows the signal price.

Stop shows where invalidation would be.

TP1 and TP2 show first and second profit targets.

ATR Trailing Stop shows a dynamic stop line that follows price.

What the extra filters do
MACD checks whether momentum supports the move.

EMA filter checks whether the short-term trend agrees.

Volume filter checks whether there is enough participation.

Higher-timeframe EMA checks whether the bigger trend agrees.

Cooldown prevents too many signals back-to-back.

Session filter keeps it focused on active trading hours.

Simple summary
This script is basically a filtered ETH scalp signal system that tries to avoid weak trades by only triggering when price, momentum, trend, and volume all line up. It is meant to help you trade cleaner setups, not to guarantee wins.

## Source Code

````pine
//@version=5
indicator("ETH VWAP Momentum Session Scalper v4", overlay=true)

// Inputs
lenAtr        = input.int(14, "ATR Length")
lookback      = input.int(5, "Swing Lookback")
useRsi        = input.bool(true, "Use RSI Filter")
rsiLen        = input.int(14, "RSI Length")
showLabels    = input.bool(true, "Show Labels")

useMacd       = input.bool(true, "Use MACD Filter")
macdFast      = input.int(12, "MACD Fast Length")
macdSlow      = input.int(26, "MACD Slow Length")
macdSignal    = input.int(9, "MACD Signal Length")

useEma        = input.bool(true, "Use EMA Trend Filter")
emaFastLen    = input.int(9, "EMA Fast Length")
emaSlowLen    = input.int(21, "EMA Slow Length")

useVol        = input.bool(true, "Use Volume Filter")
volLen        = input.int(20, "Volume SMA Length")
volMult       = input.float(1.0, "Volume Multiplier", step=0.1)

useHTF        = input.bool(true, "Use Higher Timeframe Trend Filter")
htfTf         = input.timeframe("15", "HTF Trend Timeframe")
htfEmaLen     = input.int(50, "HTF EMA Length")

useSession    = input.bool(true, "Use Session Filter")
tradeSession  = input.session("0700-1700", "Trade Session")

cooldownBars  = input.int(5, "Cooldown Bars After Signal")
trailMult     = input.float(1.5, "ATR Trail Multiplier", step=0.1)
useTrail      = input.bool(true, "Show ATR Trailing Stop")

// Core values
vwapVal   = ta.vwap(hlc3)
atrVal    = ta.atr(lenAtr)
buffer    = atrVal * 0.15
swingHigh = ta.highest(high, lookback)
swingLow  = ta.lowest(low, lookback)
rsiVal    = ta.rsi(close, rsiLen)

// MACD
[macdLine, signalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignal)
macdBull = macdLine > signalLine and macdHist > 0
macdBear = macdLine < signalLine and macdHist < 0

// EMA trend filter
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
emaBull = emaFast > emaSlow
emaBear = emaFast < emaSlow

// Volume filter
volSma = ta.sma(volume, volLen)
volOk = volume > volSma * volMult

// HTF trend filter
htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfEma   = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfEmaLen), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfClose > htfEma
htfBear  = htfClose < htfEma

// Session filter
inSession = not useSession or not na(time(timeframe.period, tradeSession))

// Base triggers
baseLong =
     barstate.isconfirmed and
     inSession and
     close > vwapVal + buffer and
     close > open and
     close > high[1] and
     (not useRsi or rsiVal > 50)

baseShort =
     barstate.isconfirmed and
     inSession and
     close < vwapVal - buffer and
     close < open and
     close < low[1] and
     (not useRsi or rsiVal < 50)

// Filters
longFilters =
     (not useMacd or macdBull) and
     (not useEma or emaBull) and
     (not useVol or volOk) and
     (not useHTF or htfBull)

shortFilters =
     (not useMacd or macdBear) and
     (not useEma or emaBear) and
     (not useVol or volOk) and
     (not useHTF or htfBear)

// Cooldown
var int lastSignalBar = na
canTrade = na(lastSignalBar) or (bar_index - lastSignalBar > cooldownBars)

// Final triggers
longTrig = baseLong and longFilters and canTrade
shortTrig = baseShort and shortFilters and canTrade

// Trade levels
var float entryLine = na
var float stopLine = na
var float tp1Line = na
var float tp2Line = na
var float trailLine = na
var int   tradeDir = 0

if longTrig
    entryLine := close
    stopLine := swingLow - buffer
    tp1Line := close + atrVal
    tp2Line := close + atrVal * 2
    trailLine := close - atrVal * trailMult
    tradeDir := 1
    lastSignalBar := bar_index
    if showLabels
        label.new(bar_index, low - buffer, "BUY", style=label.style_label_up, color=color.lime, textcolor=color.white, size=size.small)

if shortTrig
    entryLine := close
    stopLine := swingHigh + buffer
    tp1Line := close - atrVal
    tp2Line := close - atrVal * 2
    trailLine := close + atrVal * trailMult
    tradeDir := -1
    lastSignalBar := bar_index
    if showLabels
        label.new(bar_index, high + buffer, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

// Trailing stop update
if useTrail and tradeDir == 1 and not na(trailLine)
    trailLine := math.max(trailLine, close - atrVal * trailMult)

if useTrail and tradeDir == -1 and not na(trailLine)
    trailLine := math.min(trailLine, close + atrVal * trailMult)

// Plots
plot(vwapVal, "VWAP", color=color.orange, linewidth=2)
plot(entryLine, "Entry", color=color.blue, linewidth=2, style=plot.style_linebr)
plot(stopLine, "Stop", color=color.red, linewidth=2, style=plot.style_linebr)
plot(tp1Line, "TP1", color=color.green, linewidth=2, style=plot.style_linebr)
plot(tp2Line, "TP2", color=color.teal, linewidth=2, style=plot.style_linebr)
plot(useTrail ? trailLine : na, "ATR Trailing Stop", color=color.fuchsia, linewidth=2, style=plot.style_linebr)
plot(useEma ? emaFast : na, "EMA Fast", color=color.yellow, linewidth=1)
plot(useEma ? emaSlow : na, "EMA Slow", color=color.purple, linewidth=1)
plot(useHTF ? htfEma : na, "HTF EMA", color=color.fuchsia, linewidth=2)

// Alerts
alertcondition(longTrig, title="Long Signal", message="ETH VWAP Momentum Session Scalper v4: BUY")
alertcondition(shortTrig, title="Short Signal", message="ETH VWAP Momentum Session Scalper v4: SELL")

// Info label
var label info = na
if barstate.islast
    label.delete(info)
    txt = "ATR: " + str.tostring(atrVal, format.mintick) + "\n" +
          "VWAP: " + str.tostring(vwapVal, format.mintick) + "\n" +
          "Entry: " + str.tostring(entryLine, format.mintick) + "\n" +
          "Stop: " + str.tostring(stopLine, format.mintick) + "\n" +
          "TP1: " + str.tostring(tp1Line, format.mintick) + "\n" +
          "TP2: " + str.tostring(tp2Line, format.mintick) + "\n" +
          "Trail: " + str.tostring(trailLine, format.mintick) + "\n" +
          "Vol OK: " + str.tostring(volOk)
    info := label.new(bar_index, high, txt, style=label.style_label_left, textcolor=color.white, color=color.new(color.blue, 60))
````
