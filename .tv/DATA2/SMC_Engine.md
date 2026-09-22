<!-- tradingview-pine-id: PUB;db4265b6a74846c798723dd7dfc4f358 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SMC Engine

Source: https://www.tradingview.com/script/ZHP7rGVm-SMC-Engine/

## Description

SMC Engine

Overview

SMC Engine is a market-context indicator designed to identify potential liquidity sweeps and directional pressure around a selected session range.
The indicator combines an open-based NY range, candle spread analysis, and lower-timeframe volume pressure to classify market conditions such as Stop Hunts, directional aggression, and breakouts.
The default session is 09:30–10:30 New York time, but the session and timezone can be adjusted from the settings.

Key Features

[*]Open-based NY session range
[*]Automatic range box visualization
[*]Projected range levels after the session
[*]Candle spread anomaly detection
[*]Lower-timeframe volume pressure
[*]Stop Hunt High detection
[*]Stop Hunt Low detection
[*]Bullish Aggression detection
[*]Bearish Aggression detection
[*]Breakout Up/Down classification
[*]Real-time sentiment dashboard

How It Works

1. Open-Based NY Range

During the selected session, the indicator tracks the highest and lowest candle opening prices.

These levels form the open-based range used by the sentiment engine.

Note: This is an open-based range, not a conventional opening range calculated from candle highs and lows.

2. Spread Analysis

The indicator compares the current candle's spread (High - Low) with its average spread over the selected baseline period.

Default settings:

[*]Spread Baseline: 50 bars
[*]Spread Anomaly Multiplier: 2.0

When the current spread exceeds the baseline multiplied by the anomaly multiplier, it is classified as a spread anomaly.

3. Volume Pressure

The indicator uses lower-timeframe candle data to estimate directional volume pressure.

[*]Lower-timeframe close > open → volume is counted as positive
[*]Lower-timeframe close < open → volume is counted as negative
[*]Lower-timeframe close = open → volume is ignored

The resulting value is used as a volume-pressure proxy.
This is not true bid/ask volume delta.

Sentiment Conditions

Stop Hunt High

A Stop Hunt High is identified when:

[*]The candle has an unusually large spread
[*]Price trades above the open-based range high
[*]The candle closes back at or below that level
[*]Lower-timeframe volume pressure is negative

The signal is displayed with an orange downward triangle.
This can be viewed as a potential bearish liquidity-sweep setup.

Stop Hunt Low

A Stop Hunt Low is identified when:

[*]The candle has an unusually large spread
[*]Price trades below the open-based range low
[*]The candle closes back at or above that level
[*]Lower-timeframe volume pressure is positive

The signal is displayed with an orange upward triangle.
This can be viewed as a potential bullish liquidity-sweep setup.

Bullish / Bearish Aggression

When a spread anomaly occurs without meeting the Stop Hunt conditions, the indicator evaluates candle direction and volume pressure to identify:

[*]Bullish Aggression
[*]Bearish Aggression
[*]Air Pocket/Uncertain

Breakouts

When the spread is not classified as an anomaly, the indicator can identify:

[*]Breakout Up
[*]Breakout Down

These classifications are based on price closing beyond the open-based range together with corresponding volume pressure.

How to Use It

The indicator is primarily intended as a market-context and confirmation tool, rather than a standalone buy/sell system
A simple way to use the Stop Hunt signals is:

Bullish Setup

Stop Hunt Low → wait for confirmation → consider long
When an orange Stop Hunt Low appears, avoid entering immediately. Observe the following price action and look for bullish confirmation before considering a long trade.

Bearish Setup

Stop Hunt High → wait for confirmation → consider short
When an orange Stop Hunt High appears, avoid entering immediately. Observe the following price action and look for bearish confirmation before considering a short trade.
The Stop Hunt signal should therefore be treated as a setup/area of interest, not an automatic entry signal.
Traders can combine the signal with their own market structure, price action, risk management, and higher-timeframe analysis.

Dashboard

The dashboard displays:

[*]VSA Price Spread — current candle spread in ticks
[*]Baseline Spread — average spread used for anomaly detection
[*]Volume Pressure — calculated lower-timeframe directional volume pressure
[*]Current Sentiment — current classification produced by the engine

Recommended Usage

The default configuration is designed around using a lower timeframe for volume-pressure analysis, such as a 1-minute lower timeframe on a 5-minute chart.
The appropriate settings can vary by market, symbol, and timeframe, so traders should test the indicator under the conditions in which they intend to use it.

Important Limitations
The range is based on candle opens, not highs and lows.
Volume Pressure is a directional-volume proxy and should not be interpreted as true bid/ask delta.
A Stop Hunt signal does not guarantee a reversal or profitable trade.
Breakout classifications do not guarantee that a breakout will continue.
The indicator does not determine stop-loss placement, take-profit levels, or position sizing.
Market conditions, liquidity, and data-feed characteristics can affect the behavior of lower-timeframe calculations.
Traders should independently test and validate the indicator before using it in live trading.

SMC Engine is intended for market analysis and educational purposes and should be used together with appropriate risk management.

---

## Source Code

````pine
//@version=6
indicator("SMC Engine", shorttitle="SMC Engine", overlay=true, max_boxes_count=200, max_lines_count=200)

// --- Inputs ---
var string GRP1 = "Session & Range (Open-Based)"
i_session      = input.session("0930-1030", title="NY Opening Range", group=GRP1)
i_timezone     = input.string("America/New_York", title="Timezone", group=GRP1)

var string GRP2 = "VSA Spread & Volume Pressure Logic"
i_baseline_len = input.int(50, title="Spread Baseline Bars", group=GRP2, minval=10)
i_anomaly_mult = input.float(2.0, title="Spread Anomaly Multiplier", group=GRP2, step=0.1)
i_ltf          = input.timeframe("1", title="Volume Pressure Lower Timeframe", group=GRP2)

// --- Initial Balance (Strictly Open-Based) ---
bool in_session = time(timeframe.period, i_session, i_timezone) != 0

var float session_open_high = na
var float session_open_low  = na
var box   ib_box             = na

if in_session and not in_session[1]
    session_open_high := open
    session_open_low  := open
    ib_box := box.new(left=bar_index, top=session_open_high, right=bar_index, bottom=session_open_low, 
                      border_color=color.new(color.blue, 50), bgcolor=color.new(color.blue, 90))
else if in_session
    session_open_high := math.max(session_open_high, open)
    session_open_low  := math.min(session_open_low, open)
    box.set_top(ib_box, session_open_high)
    box.set_bottom(ib_box, session_open_low)
    box.set_right(ib_box, bar_index)

// Project the Open-Based lines forward after session ends for liquidity sweeps
if not in_session and in_session[1]
    line.new(bar_index - 1, session_open_high, bar_index + 15, session_open_high, color=color.blue, style=line.style_dashed)
    line.new(bar_index - 1, session_open_low, bar_index + 15, session_open_low, color=color.blue, style=line.style_dashed)

// --- VSA Spread Tracker (High - Low) ---
float current_spread  = high - low
float baseline_spread = ta.sma(current_spread, i_baseline_len)
bool  is_anomaly      = current_spread > (baseline_spread * i_anomaly_mult)

// --- Volume Pressure Proxy ---
// This uses lower-timeframe candle direction to estimate directional volume.
// It is a volume-pressure proxy, not true bid/ask volume delta.
[ltf_open, ltf_close, ltf_vol] = request.security_lower_tf(syminfo.tickerid, i_ltf, [open, close, volume])
float bar_delta = 0

if not na(ltf_close) and array.size(ltf_close) > 0
    for i = 0 to array.size(ltf_close) - 1
        float o = array.get(ltf_open, i)
        float c = array.get(ltf_close, i)
        float v = array.get(ltf_vol, i)
        if c > o
            bar_delta += v
        else if c < o
            bar_delta -= v

// --- Sentiment Engine ---
string sentiment       = "Stable"
color  sentiment_color = color.new(color.gray, 0)

// Identify sweeps against the Open-Based liquidity levels
bool sweep_high = (close <= session_open_high) and (high > session_open_high)
bool sweep_low  = (close >= session_open_low) and (low < session_open_low)

if is_anomaly
    if sweep_high and bar_delta < 0
        sentiment := "Stop Hunt (High)"
        sentiment_color := color.orange
    else if sweep_low and bar_delta > 0
        sentiment := "Stop Hunt (Low)"
        sentiment_color := color.orange
    else if bar_delta > 0 and close > open
        sentiment := "Bullish Aggression"
        sentiment_color := color.green
    else if bar_delta < 0 and close < open
        sentiment := "Bearish Aggression"
        sentiment_color := color.red
    else
        sentiment := "Air Pocket/Uncertain"
        sentiment_color := color.yellow
else
    // Tight spread condition - evaluating for genuine momentum
    if close > session_open_high and bar_delta > 0
        sentiment := "Breakout Up"
        sentiment_color := color.teal
    else if close < session_open_low and bar_delta < 0
        sentiment := "Breakout Down"
        sentiment_color := color.maroon

// --- Live Dashboard ---
var table hud = table.new(position.top_right, 2, 5, border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(hud, 0, 0, "Sentiment Metric", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 0, "Value", text_color=color.white, bgcolor=color.black)
    
    table.cell(hud, 0, 1, "VSA Price Spread", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 1, str.tostring(current_spread / syminfo.mintick, "#.##") + " ticks", text_color=color.white, bgcolor=is_anomaly ? color.red : color.gray)
    
    table.cell(hud, 0, 2, "Baseline Spread", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 2, str.tostring(baseline_spread / syminfo.mintick, "#.##") + " ticks", text_color=color.white, bgcolor=color.gray)
    
    table.cell(hud, 0, 3, "Volume Pressure", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 3, str.tostring(bar_delta, "#.##"), text_color=color.white, bgcolor=bar_delta > 0 ? color.green : color.red)
    
    table.cell(hud, 0, 4, "Current Sentiment", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 4, sentiment, text_color=color.white, bgcolor=sentiment_color)

// --- Visual Alerts ---
plotshape(sentiment == "Stop Hunt (High)", title="Sweep High", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.small)
plotshape(sentiment == "Stop Hunt (Low)", title="Sweep Low", style=shape.triangleup, location=location.belowbar, color=color.orange, size=size.small)
plotshape(sentiment == "Bullish Aggression", title="Bullish Push", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(sentiment == "Bearish Aggression", title="Bearish Push", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
````
