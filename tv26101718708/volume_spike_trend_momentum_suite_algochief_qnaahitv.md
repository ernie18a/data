# Volume Spike Trend & Momentum Suite [AlgoChief]

- url: https://www.tradingview.com/script/qnaaHiTv-Volume-Spike-Trend-Momentum-Suite-AlgoChief/
- type: indicator
- pine_id: PUB;5a40fa9edac64675819d2b71ca13dfd5
- version: 1.0

## Description

Volume Spike Trend & Momentum Engine is a systematic trading tool designed to identify the exact moments institutional volume enters the market. Instead of relying solely on lagging price action, this indicator anchors trend direction to statistical volume expansions (RVOL), tracks active momentum health, and plots dynamic ATR-based trailing stops to clearly mark both trend inception and exhaustion.


How It Works

1. Relative Volume Spike Detection
The script calculates real-time Relative Volume (RVOL) against a dynamic simple moving average of volume. When current volume expands beyond user-defined thresholds (default 1.8x), the engine flags an institutional volume event with a bottom marker.

2. Trend Initiation and Direction Confirmation
A trend is confirmed only when a volume spike coincides with price closing in alignment with the underlying baseline moving average. 
A bullish trend begins when volume surges and price closes above the baseline EMA.
A bearish trend begins when volume surges and price closes below the baseline EMA.

3. Real-Time Momentum Classification
Not all trends move with the same velocity. The script integrates directional movement index (ADX) and volume persistence to classify candle momentum into two states:
Bright candles indicate high velocity, strong volume, and expanding momentum.
Dark candles indicate fading momentum and volume drying up, warning traders of potential consolidation or pullback.

4. Dynamic Trailing Exit Logic
Rather than using static profit targets, the indicator implements a ratcheting Average True Range (ATR) trailing stop line. In an uptrend, the stop only moves upward; in a downtrend, it only moves downward. A close beyond this trailing threshold formally signals trend termination.


Visual Elements on Chart

Green Buy Start Label: Confirmed initiation of an uptrend with volume backing.
Red Sell Start Label: Confirmed initiation of a downtrend with volume backing.
Orange Exit Label: Breakout of the ATR trailing baseline, signaling trend completion.
Yellow Candle Dots: Highlights exact bars where relative volume exceeds the spike multiplier.
Color-Coded Candles: Bright colors for active high momentum, muted dark colors for slowing momentum.
On-Screen Status Table: Live top-right dashboard displaying current trend regime, momentum state, relative volume factor, and trend strength values.


Trading Applications

This indicator is versatile across multiple asset classes including Crypto, Forex, Indices, and Equities.
Intraday Trading: 5-minute and 15-minute charts for breakout and momentum scalping.
Swing Trading: 1-hour, 4-hour, and Daily charts for capturing multi-day trending legs.


Risk Disclaimer

This indicator is published strictly for educational and analytical purposes. No indicator or algorithmic calculation can guarantee market outcomes or financial gains. Always apply disciplined risk management, proper position sizing, and independent technical verification before placing live trades.

## Source Code

````pine
//@version=6
indicator("Volume Spike Trend & Momentum Suite [AlgoChief]", overlay=true)

// ==========================================
// 1. INPUT SETTINGS
// ==========================================
grp_vol     = "Volume Spike Settings"
volLen      = input.int(20, "Volume MA Length", minval=1, group=grp_vol)
spikeMult   = input.float(1.8, "Volume Spike Multiplier (e.g. 1.8x)", minval=1.1, step=0.1, group=grp_vol)

grp_trend   = "Trend & Baseline Settings"
emaLen      = input.int(21, "Trend Baseline EMA Length", minval=1, group=grp_trend)
atrLen      = input.int(14, "ATR Length for Trailing Exit", minval=1, group=grp_trend)
atrMult     = input.float(2.0, "ATR Trailing Multiplier", minval=0.5, step=0.1, group=grp_trend)

grp_mom     = "Momentum Settings"
adxLen      = input.int(14, "ADX Smoothing Length", minval=1, group=grp_mom)
adxThreshold= input.int(22, "ADX Strong Momentum Threshold", minval=10, group=grp_mom)

// ==========================================
// 2. VOLUME SPIKE & BASELINE CALCULATIONS
// ==========================================
volMA       = ta.sma(volume, volLen)
rvol        = volume / volMA
isVolSpike  = rvol >= spikeMult
baseEMA     = ta.ema(close, emaLen)
atrVal      = ta.atr(atrLen)

// ADX for Trend Strength / Momentum
[diplus, diminus, adx] = ta.dmi(adxLen, adxLen)

// Spike Direction Confirmation
bullSpike = isVolSpike and close > open and close > baseEMA
bearSpike = isVolSpike and close < open and close < baseEMA

// ==========================================
// 3. TREND STATE ENGINE (START & END LOGIC)
// ==========================================
var int trendState = 0        // 1 = Bullish, -1 = Bearish, 0 = Neutral
var float trailingStop = na

bool trendStartBull = false
bool trendStartBear = false
bool trendEndBull   = false
bool trendEndBear   = false

// Dynamic Trailing Stop calculation
if trendState == 1
    // Stop ratchet upwards only
    longStop = low - (atrVal * atrMult)
    trailingStop := (trendState[1] == 1 and not na(trailingStop)) ? math.max(trailingStop, longStop) : longStop
    // Trend End condition: Close below trailing stop
    if close < trailingStop
        trendState   := 0
        trendEndBull := true
        trailingStop := na

else if trendState == -1
    // Stop ratchet downwards only
    shortStop = high + (atrVal * atrMult)
    trailingStop := (trendState[1] == -1 and not na(trailingStop)) ? math.min(trailingStop, shortStop) : shortStop
    // Trend End condition: Close above trailing stop
    if close > trailingStop
        trendState   := 0
        trendEndBear := true
        trailingStop := na

// Trend Start condition: Fresh volume spike in the direction of breakout
if bullSpike and trendState != 1
    trendState      := 1
    trendStartBull  := true
    trailingStop    := low - (atrVal * atrMult)

else if bearSpike and trendState != -1
    trendState      := -1
    trendStartBear  := true
    trailingStop    := high + (atrVal * atrMult)

// ==========================================
// 4. MOMENTUM CLASSIFICATION (STRONG VS WEAK)
// ==========================================
bool isMomentumStrong = false
bool isMomentumWeak   = false

if trendState != 0
    // Strong momentum: ADX above threshold + volume active or ADX rising
    isMomentumStrong := (adx >= adxThreshold) and (adx >= adx[1] or rvol > 1.2)
    // Weak momentum: ADX falling or very low volume
    isMomentumWeak   := not isMomentumStrong

// Color candles based on Trend & Momentum
color barCol = color.gray
if trendState == 1
    barCol := isMomentumStrong ? #00E676 : #1B5E20 // Bright Green = Strong Bull, Dark Green = Weakening Bull
else if trendState == -1
    barCol := isMomentumStrong ? #FF1744 : #B71C1C // Bright Red = Strong Bear, Dark Red = Weakening Bear

barcolor(barCol)

// ==========================================
// 5. CHART SIGNALS & PLOTS
// ==========================================
// Baseline & Trailing Stop Line
plot(baseEMA, "Baseline EMA", color=color.new(color.blue, 40), linewidth=1)
plot(trailingStop, "Trailing Stop Line", 
     color = trendState == 1 ? color.green : trendState == -1 ? color.red : color.gray, 
     style = plot.style_linebr, linewidth = 2)

// Trend Start Markers
plotshape(trendStartBull, title="Trend Start Bullish", style=shape.labelup, location=location.belowbar, 
          color=color.green, text="🚀 BUY START", textcolor=color.white, size=size.normal)

plotshape(trendStartBear, title="Trend Start Bearish", style=shape.labeldown, location=location.abovebar, 
          color=color.red, text="🔻 SELL START", textcolor=color.white, size=size.normal)

// Trend End Markers
plotshape(trendEndBull, title="Trend End Bullish", style=shape.xcross, location=location.abovebar, 
          color=color.orange, text="EXIT (BULL END)", textcolor=color.white, size=size.small)

plotshape(trendEndBear, title="Trend End Bearish", style=shape.xcross, location=location.belowbar, 
          color=color.orange, text="EXIT (BEAR END)", textcolor=color.white, size=size.small)

// Volume Spike Dot on Candle
plotshape(isVolSpike, title="Volume Spike Dot", style=shape.circle, location=location.bottom, 
          color=color.yellow, size=size.tiny)

// ==========================================
// 6. DASHBOARD TABLE (TOP RIGHT CORNER)
// ==========================================
var table dash = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 30), border_color=color.gray, border_width=1)

if barstate.islast
    // 1. Trend Direction
    string trendTxt = trendState == 1 ? "BULLISH 🟢" : trendState == -1 ? "BEARISH 🔴" : "NEUTRAL / NO TREND ⚪"
    color  trendBg  = trendState == 1 ? color.teal : trendState == -1 ? color.maroon : color.gray
    table.cell(dash, 0, 0, "Trend Direction", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, trendTxt, bgcolor=trendBg, text_color=color.white, text_size=size.small)

    // 2. Momentum State
    string momTxt = trendState == 0 ? "IDLE" : (isMomentumStrong ? "🔥 STRONG" : "⚠️ WEAKENING")
    color  momBg  = trendState == 0 ? color.gray : (isMomentumStrong ? color.green : color.orange)
    table.cell(dash, 0, 1, "Momentum Status", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, momTxt, bgcolor=momBg, text_color=color.white, text_size=size.small)

    // 3. Relative Volume (RVOL)
    string rvolTxt = str.tostring(rvol, "#.##") + "x " + (isVolSpike ? "[⚡ SPIKE]" : "")
    color  rvolBg  = isVolSpike ? color.purple : color.black
    table.cell(dash, 0, 2, "Relative Volume", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, rvolTxt, bgcolor=rvolBg, text_color=color.white, text_size=size.small)

    // 4. ADX Value
    table.cell(dash, 0, 3, "ADX (Strength)", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(adx, "#.#"), text_color=color.white, text_size=size.small)

// ==========================================
// 7. ALERTS
// ==========================================
alertcondition(trendStartBull, title="Alert: Bullish Trend Started", message="[+] Bullish Trend Started with Volume Spike on {{ticker}} at {{close}}")
alertcondition(trendStartBear, title="Alert: Bearish Trend Started", message="[-] Bearish Trend Started with Volume Spike on {{ticker}} at {{close}}")
alertcondition(trendEndBull,   title="Alert: Bullish Trend Ended",   message="[x] Bullish Trend Ended (Trailing Stop Hit) on {{ticker}} at {{close}}")
alertcondition(trendEndBear,   title="Alert: Bearish Trend Ended",   message="[x] Bearish Trend Ended (Trailing Stop Hit) on {{ticker}} at {{close}}")
````
