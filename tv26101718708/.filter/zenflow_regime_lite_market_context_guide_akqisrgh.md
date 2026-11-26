# ZENFlow Regime Lite | Market Context Guide

- url: https://www.tradingview.com/script/AkQISRgh-ZENFlow-Regime-Lite-Market-Context-Guide/
- type: indicator
- pine_id: PUB;a9e1ccd66fef44b9bc1ed6d06321ccc2
- version: 1.0

## Description

[b]ZENFlow Regime Lite | Market Context Guide[/b]

ZENFlow Regime Lite is an open-source market regime and context-reading indicator designed to help traders understand the current market environment before looking for trade setups.

The main idea behind this script is simple:

Read the market first.
Then decide whether the market is trending, ranging, compressing, or unclear.

This Lite version is designed as a beginner-friendly market context guide. It does not provide direct entry, stop-loss, or take-profit levels. Instead, it helps users identify the broader condition of the market so they can make more informed decisions using their own trading method.

Core Concept

Many traders start by asking:

Should I buy?
Should I sell?
Where is the entry?

ZENFlow Regime Lite starts from a different question:

What kind of market are we in right now?

The indicator uses a multi-timeframe context approach. It reads the current chart timeframe together with a higher timeframe context to help classify the market into broad conditions such as trend, range, compression, chop, or breakout-watch environments.

What This Indicator Shows

HTF Context

The higher timeframe context helps users understand the broader market environment.

Examples:

• Trend Up
• Trend Down
• Range
• Compression
• Chop

HTF Bias

The bias row summarizes whether the higher timeframe favors long, short, range mode, breakout watch, or neutral conditions.

Examples:

• Long Bias
• Short Bias
• Range Mode
• Wait Breakout
• Neutral

Trading Timeframe Regime

The script also reads the current chart timeframe to show whether the trading timeframe is trending, ranging, compressing, or choppy.

Market State

The state classification helps users understand the phase of the move.

Examples:

• Early
• Healthy
• Mature
• Exhaustion

Momentum

Momentum is based on directional pressure and DI gap behavior.

Examples:

• Rising
• Strong
• Fading
• Collapsing

Energy

Energy is based on ATR behavior compared with its baseline.

Examples:

• Quiet
• Normal
• Expanding
• Extreme

Guide

The Guide row provides a broad market-reading suggestion.

Examples:

• Follow Long Bias
• Follow Short Bias
• Avoid Chase
• Range Market
• Wait Breakout
• Wait

The Guide is not an entry signal. It is a market-context summary.

Calculation Logic

ZENFlow Regime Lite combines several market components:

• ADX and DI
Used to detect trend strength and directional pressure.

• Bollinger Band Width
Used to identify range and compression conditions.

• ATR and ATR Baseline
Used to measure volatility and market energy.

• Stochastic
Used as part of state and exhaustion interpretation.

• Multi-Timeframe Context
Used to compare the current chart timeframe with a higher timeframe environment.

The purpose of combining these components is to avoid reading price action from a single signal only. The script is designed to provide a broader context before trade planning.

How to Use

Start with HTF Context

Check whether the higher timeframe is trending, ranging, compressing, or choppy.

Read HTF Bias

Use this to understand whether the broader environment favors long, short, range, breakout watch, or neutral behavior.

Check the Trading Timeframe

Compare the current chart timeframe with the higher timeframe. Alignment between both timeframes usually provides a cleaner reading.

Read State, Momentum, and Energy

These rows help determine whether the current move is still developing, healthy, late, or losing strength.

Use the Guide row carefully

The Guide row is only a broad context suggestion. It should not be treated as an automatic buy or sell instruction.

Suggested Interpretation

A stronger long-side context may appear when:

• HTF Bias favors Long
• Trading timeframe is also Trend Up
• State is Early or Healthy
• Momentum is Rising or Strong
• Energy is Normal or Expanding

A stronger short-side context may appear when:

• HTF Bias favors Short
• Trading timeframe is also Trend Down
• State is Early or Healthy
• Momentum is Rising or Strong
• Energy is Normal or Expanding

A caution condition may appear when:

• State is Mature or Exhaustion
• Momentum is Fading or Collapsing
• Energy is Extreme
• The market is in Range, Compression, or Chop
• Price has already moved too far and the Guide shows Avoid Chase

What This Lite Version Does Not Include

This Lite version is intentionally limited to broad market-regime reading.

It does not include:

• Final Plan
• Action row
• ZSS setup events
• CHoCH / BOS engine
• Liquidity target engine
• Entry / Stop-loss / Take-profit planner
• Tactical reversal layer
• Trade execution system

This keeps the script simple, educational, and suitable for users who want to learn how to read market context first.

Alerts

The script includes broad context alerts such as:

• Follow Long Bias
• Follow Short Bias
• Avoid Chase
• Range Market
• Wait Breakout
• Wait

These alerts are designed to notify users when the market context changes. They are not standalone trade signals.

Recommended Use

ZENFlow Regime Lite can be used as:

• A market-regime dashboard
• A trend/range/compression context reader
• A top-down market filter
• A learning tool for reading market condition
• A companion to a trader’s own entry method

Limitations

This indicator does not predict future price movement.
It does not guarantee profitable trades.
It does not replace risk management.
It should not be used as a standalone trading system.
Market behavior can change quickly, especially during news events, low-liquidity periods, or highly volatile conditions.

All trading decisions remain the responsibility of the user.

Educational Use Only

This script is intended for educational and analytical use only.
It is not financial advice.

────────────────────

## Source Code

````pine
//@version=6
indicator("ZENFlow Regime Lite | Market Context Guide", overlay=true, max_labels_count=50)


//────────────────────────────────────────────
// ZENFlow Regime Lite | Market Context Guide
// FREE / Open-source version
//
// Purpose:
// This script is a beginner-friendly market regime reader.
// It provides broad market context only.
//
// Lite limitations:
// - No Final Plan
// - No Action row
// - No ZSS
// - No CHoCH / BOS engine
// - No Liquidity Target engine
// - No Entry / SL / TP planner
//────────────────────────────────────────────

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────
grpCore = "Core Logic"
diLen      = input.int(8, "DI Length", minval=1, group=grpCore)
adxSmooth  = input.int(14, "ADX Smoothing", minval=1, group=grpCore)
adxTrend   = input.float(25.0, "ADX Trend Threshold", step=0.1, group=grpCore)
adxEarly   = input.float(18.0, "ADX Early Threshold", step=0.1, group=grpCore)

bbLen      = input.int(20, "BB Length", minval=1, group=grpCore)
bbMult     = input.float(2.0, "BB Mult", step=0.1, group=grpCore)
bwSmaLen   = input.int(50, "BB Width SMA", minval=5, group=grpCore)

atrLen     = input.int(14, "ATR Length", minval=1, group=grpCore)
atrBaseLen = input.int(50, "ATR Baseline", minval=5, group=grpCore)

stochLen     = input.int(9, "Stoch Length", minval=1, group=grpCore)
stochSmoothK = input.int(3, "Stoch Smooth K", minval=1, group=grpCore)
stochDLen    = input.int(3, "Stoch D Length", minval=1, group=grpCore)

grpHTF = "HTF Context"
useAutoHTF = input.bool(true, "Auto HTF Mapping", group=grpHTF)
manualHTF  = input.string("240", "Manual HTF", options=["15", "60", "240", "D", "W"], group=grpHTF)

grpViz = "Visual"
showHUD        = input.bool(true, "Show Lite HUD", group=grpViz)
showBarColor   = input.bool(true, "Color Candles", group=grpViz)
hudTextSizeOpt = input.string("small", "HUD Text Size", options=["tiny", "small", "normal"], group=grpViz)
grpOverlay = "Lite Overlay"

showEMAs = input.bool(true, "Show EMA 20/50/100/200", group=grpOverlay)
ema20Len  = input.int(20, "EMA 20", minval=1, group=grpOverlay)
ema50Len  = input.int(50, "EMA 50", minval=1, group=grpOverlay)
ema100Len = input.int(100, "EMA 100", minval=1, group=grpOverlay)
ema200Len = input.int(200, "EMA 200", minval=1, group=grpOverlay)

showSwings = input.bool(true, "Show Last Swing High/Low", group=grpOverlay)
swingLen   = input.int(8, "Swing Pivot Length", minval=1, group=grpOverlay)
swingExtendBars = input.int(50, "Swing Line Extend Bars", minval=10, maxval=300, group=grpOverlay)


//────────────────────────────────────────────
// HUD STYLE
//────────────────────────────────────────────
hudTextSize =
     hudTextSizeOpt == "tiny"  ? size.tiny  :
     hudTextSizeOpt == "small" ? size.small :
                                 size.normal

//────────────────────────────────────────────
// TF MAPPING
//────────────────────────────────────────────
f_autoHTF() =>
    string out = "240"
    if timeframe.isminutes
        out := timeframe.multiplier <= 15 ? "60" :
               timeframe.multiplier <= 60 ? "240" :
               timeframe.multiplier <= 240 ? "D" : "W"
    else if timeframe.isdaily
        out := "W"
    else if timeframe.isweekly
        out := "M"
    else
        out := "240"
    out

string htfRes = useAutoHTF ? f_autoHTF() : manualHTF

f_tfText(_tf) =>
    _tf == "1"   ? "M1"  :_tf == "3"   ? "M3"  :_tf == "5"   ? "M5"  :_tf == "15"  ? "M15" :_tf == "30"  ? "M30" :_tf == "45"  ? "M45" :_tf == "60"  ? "H1"  :_tf == "120" ? "H2"  :_tf == "180" ? "H3"  :_tf == "240" ? "H4"  :_tf == "480" ? "H8"  :_tf == "D"   ? "D1"  :_tf == "W"   ? "W1"  :_tf == "M"   ? "MN"  : _tf

tfTxt  = f_tfText(timeframe.period)
htfTxt = f_tfText(htfRes)

//────────────────────────────────────────────
// TEXT / COLOR HELPERS
//────────────────────────────────────────────
f_trendText(_trend) =>
    _trend == 1  ? "TREND UP" :_trend == -1 ? "TREND DOWN" :_trend == 2  ? "RANGE" :_trend == 3  ? "COMPRESSION" :"CHOP"

f_trendColor(_trend) =>
    _trend == 1  ? color.new(color.green, 0) :_trend == -1 ? color.new(color.red, 0) :_trend == 2  ? color.new(#d1c134, 0) :_trend == 3  ? color.new(color.purple, 0) :color.new(color.gray, 0)

f_stateText(_state) =>
    _state == 1 ? "EARLY" :_state == 2 ? "HEALTHY" :_state == 3 ? "MATURE" :"EXHAUSTION"

f_momText(_mom) =>
    _mom == 1 ? "RISING" :_mom == 2 ? "STRONG" :_mom == 3 ? "FADING" :"COLLAPSING"

f_energyText(_energy) =>
    _energy == 1 ? "QUIET" :_energy == 2 ? "NORMAL" :_energy == 3 ? "EXPANDING" :"EXTREME"

f_biasText(_bias) =>
    _bias == 1  ? "LONG BIAS" :_bias == -1 ? "SHORT BIAS" :_bias == 2  ? "RANGE MODE" :_bias == 3  ? "WAIT BREAKOUT" :"NEUTRAL"

f_biasColor(_bias) =>
    _bias == 1  ? color.new(color.green, 0) :_bias == -1 ? color.new(color.red, 0) :_bias == 2  ? color.new(#d1c134, 0) :_bias == 3  ? color.new(color.purple, 0) :color.new(color.gray, 20)

//────────────────────────────────────────────
// MARKET LOGIC
//────────────────────────────────────────────
f_market_logic() =>
    [dip_, dim_, adx_] = ta.dmi(diLen, adxSmooth)
    diGap_ = math.abs(dip_ - dim_)

    atrNow_  = ta.atr(atrLen)
    atrBase_ = ta.sma(atrNow_, atrBaseLen)

    basis_ = ta.sma(close, bbLen)
    dev_   = bbMult * ta.stdev(close, bbLen)
    bbU_   = basis_ + dev_
    bbL_   = basis_ - dev_

    bbWidth_    = (bbU_ - bbL_) / math.max(basis_, syminfo.mintick) * 100.0
    bbWidthSma_ = ta.sma(bbWidth_, bwSmaLen)

    ll_   = ta.lowest(low, stochLen)
    hh_   = ta.highest(high, stochLen)
    kRaw_ = hh_ == ll_ ? 50.0 : (close - ll_) / math.max(hh_ - ll_, syminfo.mintick) * 100.0
    k_    = ta.sma(kRaw_, stochSmoothK)
    d_    = ta.sma(k_, stochDLen)
    stoAvg_ = (k_ + d_) * 0.5

    isTrend_ = adx_ >= adxTrend

    trend_ =
         isTrend_ and dip_ > dim_ ? 1 :
         isTrend_ and dim_ > dip_ ? -1 :
         bbWidth_ < bbWidthSma_ * 0.85 ? 3 :
         bbWidth_ < bbWidthSma_ ? 2 : 0

    mom_ =
         diGap_ > diGap_[1] and diGap_[1] > diGap_[2] ? 1 :
         diGap_ > 15 ? 2 :
         diGap_ < diGap_[1] and diGap_[1] < diGap_[2] ? 3 : 0

    energy_ =
         atrNow_ < atrBase_ * 0.90 ? 1 :
         atrNow_ < atrBase_ * 1.05 ? 2 :
         atrNow_ < atrBase_ * 1.25 ? 3 : 4

    phaseEarly_ =
         adx_ >= adxEarly and adx_ < adxTrend and
         ((trend_ == 1 and stoAvg_ > 50) or (trend_ == -1 and stoAvg_ < 50))

    phaseHealthy_ =
         adx_ >= adxTrend and adx_ < 35 and diGap_ >= 8 and
         ((trend_ == 1 and stoAvg_ > 50) or (trend_ == -1 and stoAvg_ < 50))

    phaseMature_ =
         adx_ >= 35 and adx_ < 45 and diGap_ >= 10 and
         ((trend_ == 1 and stoAvg_ > 60) or (trend_ == -1 and stoAvg_ < 40))

    phaseExhaustion_ =
         adx_ >= 30 and
         (
             (trend_ == 1 and stoAvg_ >= 75 and (energy_ == 1 or energy_ == 2) and (mom_ == 3 or mom_ == 0)) or
             (trend_ == -1 and stoAvg_ <= 25 and (energy_ == 1 or energy_ == 2) and (mom_ == 3 or mom_ == 0))
         )

    state_ =
         phaseExhaustion_ ? 4 :
         phaseMature_     ? 3 :
         phaseHealthy_    ? 2 :
         phaseEarly_      ? 1 :
         adx_ < 30        ? 1 :
         adx_ < 40        ? 2 :
         adx_ < 50        ? 3 : 4

    int eqsLong_ = 0
    int eqsShort_ = 0

    eqsLong_ += trend_ == 1 ? 20 : 0
    eqsLong_ += state_ == 1 ? 20 : state_ == 2 ? 18 : state_ == 3 ? 8 : 0
    eqsLong_ += mom_ == 1 ? 16 : mom_ == 2 ? 20 : mom_ == 3 ? 6 : 0
    eqsLong_ += energy_ == 2 ? 12 : energy_ == 3 ? 15 : energy_ == 4 ? 8 : 4
    eqsLong_ += adx_ >= adxTrend and diGap_ >= 8 ? 15 : adx_ >= adxEarly and diGap_ >= 5 ? 8 : 0
    eqsLong_ -= state_ == 4 ? 20 : 0
    eqsLong_ := int(math.max(0, math.min(100, eqsLong_)))

    eqsShort_ += trend_ == -1 ? 20 : 0
    eqsShort_ += state_ == 1 ? 20 : state_ == 2 ? 18 : state_ == 3 ? 8 : 0
    eqsShort_ += mom_ == 1 ? 16 : mom_ == 2 ? 20 : mom_ == 3 ? 6 : 0
    eqsShort_ += energy_ == 2 ? 12 : energy_ == 3 ? 15 : energy_ == 4 ? 8 : 4
    eqsShort_ += adx_ >= adxTrend and diGap_ >= 8 ? 15 : adx_ >= adxEarly and diGap_ >= 5 ? 8 : 0
    eqsShort_ -= state_ == 4 ? 20 : 0
    eqsShort_ := int(math.max(0, math.min(100, eqsShort_)))

    bias_ =
         trend_ == 1 and eqsLong_ >= 55 ? 1 :
         trend_ == -1 and eqsShort_ >= 55 ? -1 :
         trend_ == 2 ? 2 :
         trend_ == 3 ? 3 : 0

    [trend_, state_, mom_, energy_, bias_]

//────────────────────────────────────────────
// CURRENT TF + HTF
//────────────────────────────────────────────
[curTrend, curState, curMom, curEnergy, curBias] = f_market_logic()
[htfTrend, htfState, htfMom, htfEnergy, htfBias] = request.security(syminfo.tickerid, htfRes, f_market_logic(), barmerge.gaps_off, barmerge.lookahead_off)

//────────────────────────────────────────────
// FREE VERSION GUIDE ENGINE
// Lite = broad guidance only.
// No Final Plan, no Action, no CHoCH, no Entry/TP/SL.
//────────────────────────────────────────────
isLongExtended =
     curTrend == 1 and
     (curState == 3 or curState == 4 or curMom == 3 or curMom == 0)

isShortExtended =
     curTrend == -1 and
     (curState == 3 or curState == 4 or curMom == 3 or curMom == 0)

guide =
     htfBias == 1 and curTrend == 1 and not isLongExtended ? "FOLLOW LONG BIAS" :
     htfBias == -1 and curTrend == -1 and not isShortExtended ? "FOLLOW SHORT BIAS" :
     isLongExtended or isShortExtended ? "AVOID CHASE" :
     curTrend == 2 ? "RANGE MARKET" :
     curTrend == 3 ? "WAIT BREAKOUT" :
     "WAIT"

guideColor =guide == "FOLLOW LONG BIAS"  ? color.new(color.green, 0) :guide == "FOLLOW SHORT BIAS" ? color.new(color.red, 0) :guide == "AVOID CHASE"       ? color.new(color.orange, 0) :guide == "RANGE MARKET"      ? color.new(#d1c134, 0) :guide == "WAIT BREAKOUT"     ? color.new(color.purple, 0) :color.new(color.gray, 20)

guideTextColor =
     guide == "RANGE MARKET" ? color.black :
     color.white

//────────────────────────────────────────────
// EMA OVERLAY — Lite
//────────────────────────────────────────────
ema20  = ta.ema(close, ema20Len)
ema50  = ta.ema(close, ema50Len)
ema100 = ta.ema(close, ema100Len)
ema200 = ta.ema(close, ema200Len)

plot(showEMAs ? ema20 : na, "EMA 20", color=color.new(color.aqua, 0), linewidth=1)
plot(showEMAs ? ema50 : na, "EMA 50", color=color.new(color.yellow, 0), linewidth=1)
plot(showEMAs ? ema100 : na, "EMA 100", color=color.new(color.orange, 0), linewidth=1)
plot(showEMAs ? ema200 : na, "EMA 200", color=color.new(color.red, 0), linewidth=2)


//────────────────────────────────────────────
// LAST SWING HIGH / LOW — Lite
//────────────────────────────────────────────
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow  = na
var int lastSwingHighBar = na
var int lastSwingLowBar  = na

if not na(ph)
    lastSwingHigh := ph
    lastSwingHighBar := bar_index - swingLen

if not na(pl)
    lastSwingLow := pl
    lastSwingLowBar := bar_index - swingLen

var line swingHighLine = na
var line swingLowLine  = na
var label swingHighLabel = na
var label swingLowLabel  = na

if showSwings and barstate.islast
    if not na(lastSwingHigh) and not na(lastSwingHighBar)
        line.delete(swingHighLine)
        label.delete(swingHighLabel)

        swingHighLine := line.new(lastSwingHighBar,lastSwingHigh,bar_index + swingExtendBars,lastSwingHigh,xloc=xloc.bar_index,extend=extend.none,color=color.new(color.red, 0),style=line.style_dashed,width=1)

        swingHighLabel := label.new(bar_index + swingExtendBars,lastSwingHigh,"Last Swing High",xloc=xloc.bar_index,style=label.style_label_left,textcolor=color.white,color=color.new(color.red, 0),size=size.tiny)

    if not na(lastSwingLow) and not na(lastSwingLowBar)
        line.delete(swingLowLine)
        label.delete(swingLowLabel)

        swingLowLine := line.new(lastSwingLowBar,lastSwingLow,bar_index + swingExtendBars,lastSwingLow,xloc=xloc.bar_index,extend=extend.none,color=color.new(color.green, 0),style=line.style_dashed,width=1)

        swingLowLabel := label.new(bar_index + swingExtendBars,lastSwingLow,"Last Swing Low",xloc=xloc.bar_index,style=label.style_label_left,textcolor=color.white,color=color.new(color.green, 0),size=size.tiny)

//────────────────────────────────────────────
// BAR COLOR
//────────────────────────────────────────────
barCol =
     curTrend == 1  ? color.new(color.green, 0) :
     curTrend == -1 ? color.new(color.red, 0) :
     curTrend == 2  ? color.new(color.yellow, 0) :
     curTrend == 3  ? color.new(color.purple, 0) :
                      color.new(color.gray, 0)

barcolor(showBarColor ? barCol : na)

//────────────────────────────────────────────
// HUD
//────────────────────────────────────────────
var table hud = table.new(position.top_right, 1, 10, border_width=2)

headerBg   = color.white
headerText = color.red
bodyBg     = color.new(color.black, 10)
bodyText   = color.white

if showHUD and barstate.islast
    table.clear(hud, 0, 0, 0, 9)

    int row = 0

    table.cell(hud, 0, row, "ZENFlow Regime Lite",
         text_color=headerText, bgcolor=headerBg, text_size=size.normal)
    row += 1

    table.cell(hud, 0, row, "HTF CONTEXT: " + htfTxt + " " + f_trendText(htfTrend),
         text_color=color.white, bgcolor=f_trendColor(htfTrend), text_size=hudTextSize)
    row += 1

    table.cell(hud, 0, row, "HTF BIAS: " + f_biasText(htfBias),
         text_color=color.white, bgcolor=f_biasColor(htfBias), text_size=hudTextSize)
    row += 1

    table.cell(hud, 0, row, "TRADING TF: " + tfTxt + " " + f_trendText(curTrend),
         text_color=color.white, bgcolor=f_trendColor(curTrend), text_size=hudTextSize)
    row += 1

    table.cell(hud, 0, row, "STATE: " + f_stateText(curState),
         text_color=bodyText, bgcolor=bodyBg, text_size=hudTextSize)
    row += 1

    table.cell(hud, 0, row, "MOMENTUM: " + f_momText(curMom),
         text_color=bodyText, bgcolor=bodyBg, text_size=hudTextSize)
    row += 1

    table.cell(hud, 0, row, "ENERGY: " + f_energyText(curEnergy),
         text_color=bodyText, bgcolor=bodyBg, text_size=hudTextSize)
    row += 1

    table.cell(hud, 0, row, "GUIDE: " + guide,
         text_color=guideTextColor, bgcolor=guideColor, text_size=size.normal)
    row += 1

//────────────────────────────────────────────
// ALERTS — Lite broad alerts only
//────────────────────────────────────────────
alertcondition(guide == "FOLLOW LONG BIAS",  "ZEN LITE FOLLOW LONG BIAS",  "ZEN LITE FOLLOW LONG BIAS")
alertcondition(guide == "FOLLOW SHORT BIAS", "ZEN LITE FOLLOW SHORT BIAS", "ZEN LITE FOLLOW SHORT BIAS")
alertcondition(guide == "AVOID CHASE",       "ZEN LITE AVOID CHASE",       "ZEN LITE AVOID CHASE")
alertcondition(guide == "RANGE MARKET",      "ZEN LITE RANGE MARKET",      "ZEN LITE RANGE MARKET")
alertcondition(guide == "WAIT BREAKOUT",     "ZEN LITE WAIT BREAKOUT",     "ZEN LITE WAIT BREAKOUT")
alertcondition(guide == "WAIT",              "ZEN LITE WAIT",              "ZEN LITE WAIT")
````
