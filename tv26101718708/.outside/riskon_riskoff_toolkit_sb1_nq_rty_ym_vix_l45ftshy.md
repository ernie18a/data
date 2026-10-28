# Risk-On / Risk-Off Toolkit [SB1] (NQ, RTY, YM) VIX

- url: https://www.tradingview.com/script/L45FTSHy-Risk-On-Risk-Off-Toolkit-SB1-NQ-RTY-YM-VIX/
- type: indicator
- pine_id: PUB;2c9d461fa9344bfd8100a8b4735581b1
- version: 8.0

## Description

Description:
The Risk-On / Risk-Off Toolkit [SB1] is a professional-grade market context indicator designed to help traders quickly identify broad market sentiment shifts and gauge risk appetite. By combining major US equity futures (NQ, RTY, YM) with VIX dynamics, this toolkit provides clear visual signals of “Risk-On” (bullish, lower volatility environment) and “Risk-Off” (bearish, higher volatility environment) conditions. This is ideal for traders using discretionary analysis, swing strategies, intraday scalping, or portfolio positioning decisions.
                                                                                                                                                                       My Personal Thoughts: Utilize all 3 charts to Identify which is Leading and who is lagging between the 3 (NQ, RTY, YM)                                                                                                                                                                                                   Key Features:
Futures Trend Analysis:
Monitors the Nasdaq 100 (NQ), Russell 2000 (RTY), and Dow Jones (YM) futures in real-time.
Determines bullish/bearish bias based on each futures contract’s current close relative to its open.
Identifies when all three indices are moving in sync, highlighting broad market directional alignment.
                                                                                                                                                                    VIX Confirmation:
Integrates the CBOE Volatility Index (VIX) to gauge market risk sentiment.
Confirms Risk-On conditions when VIX is falling while all three futures are bullish.
Confirms Risk-Off conditions when VIX is rising while all three futures are bearish.
Optional background shading visually highlights Risk-On (green) and Risk-Off (red) conditions for quick, intuitive assessment.
                                                                                                                                                              Strong Body Candle Signals:
Detects high conviction candlestick moves where the body represents at least 85% of the total range.
Confirms whether the candle closes near its extreme (top for bullish, bottom for bearish) within 15% of the range.
Plots arrows for strong bullish or bearish candles:
Green triangle-up for bullish strong candles
Red triangle-down for bearish strong candles
Provides a visual cue for intraday or swing traders to confirm trend momentum without cluttering the chart with labels.
                                                                                                                                                                     Alert System:
Alerts can be set for Risk-On alignment: all monitored futures are bullish and VIX is falling.
Alerts can also be set for Risk-Off alignment: all monitored futures are bearish and VIX is rising.
Ensures traders never miss shifts in broad market sentiment, suitable for both intraday and end-of-day review.
                                                                                                                                                                 Table Summary:
Provides a top-right summary table of each monitored market and VIX:
Displays Index Name and Current Bias (Bullish/Bearish/Neutral).
Highlights bullish conditions in green and bearish conditions in red.
Includes VIX status as “↓ Falling”, “↑ Rising”, or “Flat”, providing a quick visual reference of volatility trends.
                                                                                                                                                  Customizable Visuals:
Control the visibility of strong candle arrows.
Maintains dynamic bar coloring for strong candle moves (green for bullish, red for bearish).
How to Use the Risk-On / Risk-Off Toolkit:
                                                                                                                                                             Trend Confirmation: Use the alignment of NQ, RTY, and YM to determine whether the overall market environment is bullish or bearish.
                                                                                                                                                               Risk Sentiment Filter: Use VIX confirmation to identify if traders are in a risk-on or risk-off sentiment. This is especially useful for adjusting position sizing, hedging, or timing entries.
                                                                                                                                                      Momentum Validation: Strong candle arrows indicate decisive moves, providing additional confirmation for trade entries, breakouts, or trend continuation.
                                                                                                                                                               Alerts & Visual Cues: Set alerts to be notified whenever Risk-On or Risk-Off conditions are met, helping you act in real-time.
                                                                                                                                                            Quick Reference: Use the summary table for a bird’s-eye view of market alignment across indices and VIX, avoiding the need to track multiple charts simultaneously.
                                                                                                                                                                Why This Indicator is Unique:
Combines three major US indices with volatility confirmation to identify true macro market sentiment shifts.
Provides both visual and alert-based signals for actionable insights.
The inclusion of strong candle arrows gives intraday and swing traders a clear, low-latency cue for high-probability moves.
Perfect for multi-timeframe analysis and adaptable to both short-term and long-term strategies.
                                                                                                                                                           Indicator Name Justification:
The name “Risk-On / Risk-Off Toolkit [SB1]” accurately reflects the core function: identifying broad market risk appetite and sentiment alignment across key indices with volatility confirmation. It communicates instantly that the tool helps traders understand when the market is favoring risk-taking (Risk-On) versus risk-aversion (Risk-Off).

## Source Code

````pine
//@version=5 
indicator("Risk-On / Risk-Off Toolkit [SB1]", overlay=true, max_lines_count=500)

//=== Inputs ===//
show_vix_bg = input.bool(true, "Show VIX Background Color")

//=== Dashboard Position ===//
dash_pos = input.string("Top Right", "Dashboard Position", 
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"])
pos = dash_pos == "Top Left" ? position.top_left :
      dash_pos == "Top Right" ? position.top_right :
      dash_pos == "Bottom Left" ? position.bottom_left :
      position.bottom_right

//=== Futures Data ===//
nq_close = request.security("CME_MINI:NQ1!", timeframe.period, close)
nq_open  = request.security("CME_MINI:NQ1!", timeframe.period, open)
rty_close = request.security("CME_MINI:RTY1!", timeframe.period, close)
rty_open  = request.security("CME_MINI:RTY1!", timeframe.period, open)
ym_close = request.security("CBOT_MINI:YM1!", timeframe.period, close)
ym_open  = request.security("CBOT_MINI:YM1!", timeframe.period, open)

//=== Determine Trend ===//
nq_bull = nq_close > nq_open
rty_bull = rty_close > rty_open
ym_bull = ym_close > ym_open

nq_bear = nq_close < nq_open
rty_bear = rty_close < rty_open
ym_bear = ym_close < ym_open

//==================================================//
//=== Normalized Trend Strength (n-value block) ===//
//==================================================//

// Reusable function
getTrendStrength(closeSeries, fastLen, slowLen) =>
    fastEMA = ta.ema(closeSeries, fastLen)
    slowEMA = ta.ema(closeSeries, slowLen)
    dist    = math.abs(fastEMA - slowEMA)
    atrv    = ta.atr(14)
    n       = atrv != 0 ? dist / atrv : 0
    [fastEMA, slowEMA, n]

// Inputs for EMAs
fast_len = input.int(8, "Fast EMA Length")
slow_len = input.int(21, "Slow EMA Length")

// Apply to the 3 indices
[fast_nq, slow_nq, n_nq] = getTrendStrength(nq_close, fast_len, slow_len)
[fast_rty, slow_rty, n_rty] = getTrendStrength(rty_close, fast_len, slow_len)
[fast_ym, slow_ym, n_ym] = getTrendStrength(ym_close, fast_len, slow_len)

//==================================================//

//=== All in Sync Conditions ===//
all_bullish = nq_bull and rty_bull and ym_bull
all_bearish = nq_bear and rty_bear and ym_bear

//=== VIX Confirmation ===//
vix_close = request.security("CBOE:VIX", timeframe.period, close)
vix_prev  = request.security("CBOE:VIX", timeframe.period, close[1])
vix_falling = vix_close < vix_prev
vix_rising  = vix_close > vix_prev

//=== Combined Context ===//
risk_on  = all_bullish and vix_falling
risk_off = all_bearish and vix_rising
out_of_alignment = not risk_on and not risk_off

//=== Alerts ===//
alertcondition(risk_on, title="Risk-On Alignment", message="All (NQ, RTY, YM) are bullish and VIX is falling — Strong Risk-On Sentiment")
alertcondition(risk_off, title="Risk-Off Alignment", message="All (NQ, RTY, YM) are bearish and VIX is rising — Strong Risk-Off Sentiment")
alertcondition(out_of_alignment, title="Out of Alignment", message="Market indices are not aligned — Risk-On/Off conditions invalid or mixed")

//=== Background Color ===//
var color bgColor = na
if show_vix_bg
    bgColor := risk_on ? color.new(color.green, 85) :
         risk_off ? color.new(color.red, 85) :
         color.new(color.gray, 90)
else
    bgColor := na
bgcolor(bgColor)

//=== Table Dashboard (Movable) ===//
var table t = table.new(pos, 3, 5, border_width=1)

// Header
table.cell(t, 0, 0, "Index", bgcolor=color.new(color.gray, 70), text_color=color.white)
table.cell(t, 1, 0, "Bias", bgcolor=color.new(color.gray, 70), text_color=color.white)
table.cell(t, 2, 0, "n-Value", bgcolor=color.new(color.gray, 70), text_color=color.white)

// NQ Row
table.cell(t, 0, 1, "NQ", text_color=color.white)
table.cell(t, 1, 1, nq_bull ? "Bullish" : nq_bear ? "Bearish" : "Neutral",
     bgcolor=nq_bull ? color.new(color.green, 30) : nq_bear ? color.new(color.red, 30) : na)
table.cell(t, 2, 1, str.tostring(n_nq, "#.##"), bgcolor=color.white, text_color=color.black)

// RTY Row
table.cell(t, 0, 2, "RTY", text_color=color.white)
table.cell(t, 1, 2, rty_bull ? "Bullish" : rty_bear ? "Bearish" : "Neutral",
     bgcolor=rty_bull ? color.new(color.green, 30) : rty_bear ? color.new(color.red, 30) : na)
table.cell(t, 2, 2, str.tostring(n_rty, "#.##"), bgcolor=color.white, text_color=color.black)

// YM Row
table.cell(t, 0, 3, "YM", text_color=color.white)
table.cell(t, 1, 3, ym_bull ? "Bullish" : ym_bear ? "Bearish" : "Neutral",
     bgcolor=ym_bull ? color.new(color.green, 30) : ym_bear ? color.new(color.red, 30) : na)
table.cell(t, 2, 3, str.tostring(n_ym, "#.##"), bgcolor=color.white, text_color=color.black)

// VIX Row
table.cell(t, 0, 4, "VIX", text_color=color.white)
table.cell(t, 1, 4, vix_falling ? "↓ Falling" : vix_rising ? "↑ Rising" : "Flat",
     bgcolor=vix_falling ? color.new(color.green, 30) : vix_rising ? color.new(color.red, 30) : na)
table.cell(t, 2, 4, "")  // empty cell

//=== Strong Body Candle (85%) ===//
bodyPct      = input.float(0.85, "Min Body % of Range", step=0.05)
extremePct   = input.float(0.15, "Close within % of Extreme", step=0.15)
showLabels   = input.bool(true, "Show Strong Candle Labels")

candleRange  = high - low
bodySize     = math.abs(close - open)
bodyRatio    = candleRange > 0 ? bodySize / candleRange : 0.0

isStrongBody = bodyRatio >= bodyPct
bullCloseNearHigh = (high - close) <= (candleRange * extremePct)
bearCloseNearLow  = (close - low)  <= (candleRange * extremePct)

bullStrong = isStrongBody and close > open and bullCloseNearHigh
bearStrong = isStrongBody and close < open and bearCloseNearLow

plotshape(bullStrong and showLabels, title="Bull Strong Candle", style=shape.triangleup,
          location=location.belowbar, color=color.green, size=size.tiny)
plotshape(bearStrong and showLabels, title="Bear Strong Candle", style=shape.triangledown,
          location=location.abovebar, color=color.red, size=size.tiny)

barcolor(bullStrong ? color.green : bearStrong ? color.red : na)

//=== Combined Candle + Risk Context Alerts ===//
alertcondition(bullStrong and risk_on, title="Strong Bull Candle + Risk-On",
     message="Strong Bull Candle aligns with Risk-On conditions — high-confidence long context")
alertcondition(bearStrong and risk_off, title="Strong Bear Candle + Risk-Off",
     message="Strong Bear Candle aligns with Risk-Off conditions — high-confidence short context")
````
