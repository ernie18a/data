# PLUS BTC 1 hour 

- url: https://www.tradingview.com/script/FW4sGvzj-PLUS-BTC-1-hour/
- type: strategy
- pine_id: PUB;354306aca1a843f7a21e45a39c3c0581
- version: 1.0

## Description

Overview
A short-only BTC strategy for the 1H chart focused on cleaner entries and improved win rate. Combines Stochastic RSI double-top reversal, higher-timeframe EMA trend filter, low-volatility guard (VIX Fix), cooldown, and ATR-based risk management. On each entry, a chart label “end short ariljaa neev” is plotted above the bar.

How it works

Setup
Stochastic RSI (K/D) detects an overbought touch and a cross back below the OB level (default 80), with K < D for bearish confirmation.
VIX Fix “grey zone” filter helps avoid low-volatility fakes.
Higher-timeframe trend filter: only shorts when price is below HTF EMA (default EMA 200 on 4H).
Optional session window (08:00–22:00, all days).
Cooldown between signals to reduce overtrading.

## Source Code

````pine
//@version=6
strategy("BTC Sell Strategy - Clean Entries v2 (Labelled)", overlay=true, max_labels_count=500, calc_on_every_tick=true)

// INPUTS
rsiLength   = input.int(14, "RSI Length", group="Stoch RSI")
stochLength = input.int(14, "Stoch Length", group="Stoch RSI")
stochK      = input.int(3,  "K Smoothing", group="Stoch RSI")
stochD      = input.int(3,  "D Smoothing", group="Stoch RSI")
obLevel     = input.float(80,"Overbought Level", group="Stoch RSI")

vixLength    = input.int(22, "VIX Fix Length", group="VIX Fix")
vixThreshold = input.float(2.0,"VIX Max (Grey)", group="VIX Fix")

rrPrimary    = input.float(1.5,"RR Take Profit", group="Trade")
atrLen       = input.int(14, "ATR Length", group="Trade")
atrMultSL    = input.float(2.0,"ATR SL Mult", group="Trade")
breakevenR   = input.float(0.8,"Move SL to BE at R", group="Trade")
trailATR     = input.bool(true,"ATR Trailing after BE", group="Trade")
trailMult    = input.float(1.5,"ATR Trail Mult", group="Trade")
cooldownBars = input.int(10,"Cooldown Bars", group="Trade")
useSession   = input.bool(true,"Limit to London/NY", group="Session")
htfTF        = input.string("240","HTF for Trend (min)", group="Trend")
emaLen       = input.int(200,"EMA Length (HTF)", group="Trend")

// VIX FIX
highestClose = ta.highest(close, vixLength)
vixFix       = (highestClose - low) / highestClose * 100
isVixGrey    = vixFix < vixThreshold

// STOCH RSI
rsiVal   = ta.rsi(close, rsiLength)
stochRaw = ta.stoch(rsiVal, rsiVal, rsiVal, stochLength)
kLine    = ta.sma(stochRaw, stochK)
dLine    = ta.sma(kLine,  stochD)

// Double-top refined
wasPreviouslyOB = ta.barssince(kLine[1] >= obLevel and kLine[2] < obLevel) <= 10
crossUnder      = ta.crossunder(kLine, obLevel)
bearConfirm     = kLine < dLine
isDoubleTop     = wasPreviouslyOB and crossUnder and bearConfirm

// Trend filter (HTF)
emaHTF  = request.security(syminfo.tickerid, htfTF, ta.ema(close, emaLen), barmerge.gaps_off, barmerge.lookahead_off)
trendOK = close < emaHTF

// Session filter (boolean)
inSession = not useSession or not na(time(timeframe.period, "0800-2200:1234567"))

// Cooldown
var int lastTradeBar = na
cooldownOK = na(lastTradeBar) or (bar_index - lastTradeBar > cooldownBars)

// ENTRY
entrySignal = isDoubleTop and isVixGrey and trendOK and inSession and cooldownOK
if entrySignal
    strategy.entry("Short", strategy.short)
    lastTradeBar := bar_index
    // Clean entry label on chart
    label.new(bar_index, high, text="end short ariljaa neev", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

// DYNAMIC SL/TP
atr = ta.atr(atrLen)
swingSL  = ta.highest(high, 5)
stopLoss = math.max(swingSL, close + atrMultSL * atr)
riskPts  = stopLoss - close
takeProfit = close - rrPrimary * riskPts
strategy.exit("Exit", from_entry="Short", stop=stopLoss, limit=takeProfit)

// Breakeven + optional trailing
var bool movedToBE = false
if strategy.position_size < 0
    avg = strategy.position_avg_price
    rNow = (avg - close) / (stopLoss - avg)
    if not movedToBE and rNow >= breakevenR
        float beStop  = avg
        float newStop = beStop
        if trailATR
            float tStop = close + trailMult * atr
            newStop := math.min(beStop, tStop)
        strategy.exit("Exit", from_entry="Short", stop=newStop, limit=takeProfit)
        movedToBE := true
else
    movedToBE := false
````
