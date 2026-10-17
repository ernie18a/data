# Aura Trend & Candlestick Oracle [Pineify]

- url: https://www.tradingview.com/script/4VRAxg4x-Aura-Trend-Candlestick-Oracle-Pineify/
- type: indicator
- pine_id: PUB;4dc6f31945ee42cd882827f277161e13
- version: 1.0

## Description

[b]Aura Trend & Candlestick Oracle[/b]

This indicator layers EMA-based trend detection with candlestick pattern recognition, then gates the pattern signals through the prevailing trend direction. The idea: candlestick reversals are far more reliable when they fire in alignment with the macro trend rather than against it. A hammer in a downtrend is noise; the same hammer in an uptrend is a potential continuation entry after a pullback.

[b]Key Features[/b]

[list]
[*]EMA cloud (fast/slow) with dynamic color fill that shifts between bullish, bearish, and neutral states

[*]Five candlestick patterns: Bullish Engulfing, Bearish Engulfing, Hammer, Shooting Star, Inverted Hammer / Hanging Man

[*]Signals filtered by trend — bullish patterns only fire in uptrends, bearish patterns only in downtrends

[*]Background shading highlights trend zones for quick chart-reading

[*]Dashboard panel showing live trend status and current EMA values

[*]Four alert conditions: BUY signal, SELL signal, EMA bullish crossover, EMA bearish crossunder
[/list]

[b]How It Works[/b]

[i]Trend detection[/i] uses two exponential moving averages — a fast EMA (default 50) and a slow EMA (default 200). When the fast EMA is above the slow EMA, the script treats the market as an uptrend; when below, a downtrend. This classic crossover relationship provides the filtering layer for all pattern signals.

[i]Candlestick pattern detection[/i] evaluates each bar's body size, wick lengths, and direction, then checks the previous bar's properties for multi-bar patterns:

[list=1]
[*][b]Engulfing patterns[/b] — the current candle's body fully wraps the prior candle's body in the opposite direction. Bullish Engulfing requires a red prior bar followed by a green bar that opens below the prior body low and closes above the prior body high.

[*][b]Hammer[/b] — lower wick exceeds 2× the body size, upper wick is less than half the body. No directional restriction on the body itself.

[*][b]Shooting Star / Inverted Hammer / Hanging Man[/b] — upper wick exceeds 2× body, lower wick less than half the body. The body color separates these: Inverted Hammer is green (treated as bullish), Hanging Man is red (treated as bearish). Shooting Star is the upper-wick pattern used for bearish signals.
[/list]

[b]How the Components Work Together[/b]

The EMA trend state acts as a regime filter, not just a visual layer. A bullish candlestick pattern (Engulfing, Hammer, Inverted Hammer) only triggers a BUY signal when [i]fastEma > slowEma[/i] — the pattern fires into the trend, not against it. Similarly, bearish patterns only produce SELL signals when the fast EMA is below the slow EMA.

This prevents the common trap of fading reversals in strong trends. A hammer below the 200 EMA might signal a brief bounce, but it is not a high-probability long in a downtrend. By requiring trend alignment, the indicator reduces false positives from countertrend noise. The tradeoff is that signals at the beginning of a trend reversal — when the fast EMA has not yet crossed — will be missed. This is by design.

[b]Trading Ideas and Insights[/b]

[list]
[*]On higher timeframes (daily, weekly), use the EMA cloud crossover alert to identify macro trend shifts, then drop to a lower timeframe to look for BUY/SELL pattern signals for entry timing.

[*]After a pullback to or near the fast EMA in an uptrend, a Hammer or Bullish Engulfing signal at that level adds confluence — price has retested the trend structure and showed rejection. Consider these setups stronger than patterns firing far from either EMA.

[*]The Hanging Man (red candle with extended upper wick in an uptrend) triggers a SELL signal when the market is in a downtrend. In practice, watch for this pattern forming near prior resistance or the slow EMA during a counter-rally in a downtrend.

[*]Use the dashboard panel to confirm trend state without scrolling back. On faster timeframes, the 50/200 EMA spread updates frequently; on crypto or forex pairs, consider adjusting the slow EMA to 100 to reduce lag.
[/list]

Past candlestick patterns do not guarantee future price movement. All signals should be treated as areas of potential interest, not definitive entry triggers.

[b]Unique Aspects[/b]

[list]
[*]Trend-gating is the core differentiator here. Many candlestick indicators plot patterns on every bar regardless of context; this one explicitly suppresses countertrend signals at the calculation level, so the chart stays clean.

[*]The Inverted Hammer is classified as bullish and the Hanging Man as bearish based on body color, using the upper-wick geometry. Some implementations treat these as the same pattern with identical signals; here they are split by color to reflect their different interpretations in technical analysis.

[*]The EMA cloud uses transparency-adjusted fills that match the trend color, so the visual relationship between the two EMAs immediately communicates regime state without requiring a separate panel.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to any chart and timeframe. The EMA cloud and background shading appear immediately, showing the current trend regime.

[*]Watch for BUY labels (green) below bars during uptrend zones (green background) — these mark bars where a bullish pattern fired with trend confirmation.

[*]Watch for SELL labels (red) above bars during downtrend zones (red background).

[*]Set up alerts via the Alerts panel: choose "Aura BUY Signal" or "Aura SELL Signal" for pattern-filtered signals, or "Trend Shift to Uptrend/Downtrend" for EMA crossover notifications.

[*]Check the dashboard (top-right corner) for live trend status and EMA values on the current bar.
[/list]

[b]Customization[/b]

[list]
[*][b]Fast EMA Length[/b] (default: 50) — Controls the short-term trend line. Lower values increase sensitivity and produce more cloud crossovers; higher values smooth out the regime filter.

[*][b]Slow EMA Length[/b] (default: 200) — The long-term trend anchor. The 50/200 combination is a widely watched institutional reference; on shorter timeframes, consider 20/50 or 9/21.

[*][b]Color Candles by Trend[/b] — When enabled, all candles recolor to match the current trend state. Disable if you prefer standard OHLC coloring or are using another candle-coloring indicator.

[*][b]Bullish / Bearish / Neutral Colors[/b] — All visual elements (cloud, candles, background, EMAs) derive from these three color inputs, so changing them updates the entire indicator at once.
[/list]

[b]Conclusion[/b]

Aura Trend & Candlestick Oracle combines two well-understood techniques — EMA trend detection and candlestick pattern recognition — with a regime filter that suppresses countertrend noise. It works best on trending markets where the EMA structure is well-defined; in choppy, sideways conditions, expect frequent EMA crossovers and fewer valid pattern signals. Traders who already use candlestick patterns and want an automatic trend-alignment layer without managing multiple indicators will find this a practical consolidation.

## Source Code

````pine
//@version=6
//
// Aura Trend & Candlestick Oracle
// --------------------------------
// Combines a dual-EMA trend cloud with five candlestick pattern detectors,
// then gates each pattern signal through the prevailing EMA regime.
// Bullish patterns (Engulfing, Hammer, Inverted Hammer) only trigger in uptrends;
// bearish patterns (Engulfing, Shooting Star, Hanging Man) only in downtrends.
//
// Trend regimes:
//   1. Uptrend   — fast EMA above slow EMA; green cloud and background
//   2. Downtrend — fast EMA below slow EMA; red cloud and background
//   3. Neutral   — EMAs crossing or equal; gray cloud
//
indicator("Aura Trend & Candlestick Oracle [Pineify]", overlay=true, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{

grpTrend = "📈 Trend Filter (EMAs)"
fastLen = input.int(50, title="Fast EMA Length", minval=1, group=grpTrend,
     tooltip="Short-term trend reference. Lower values respond faster but produce more crossovers. The 50/200 pair is a widely-watched institutional level.")
slowLen = input.int(200, title="Slow EMA Length", minval=1, group=grpTrend,
     tooltip="Long-term trend anchor. On faster timeframes, consider reducing to 100 or 50 to keep it contextually relevant.")

grpStyle = "🎨 Aesthetics & Style"
colorCands = input.bool(true, title="Color Candles by Trend", group=grpStyle,
     tooltip="When enabled, all candles recolor to match the current trend state. Disable if using another candle-coloring indicator.")
bullColor   = input.color(#089981, title="Bullish Color",  inline="bull", group=grpStyle)
bearColor   = input.color(#f23645, title="Bearish Color",  inline="bear", group=grpStyle)
neutralColor = input.color(#808080, title="Neutral Color", group=grpStyle,
     tooltip="Applied when the two EMAs are equal or actively crossing. All three colors propagate to the cloud, candles, background, and labels.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{

// --- EMA Cloud ---
fastEma = ta.ema(close, fastLen)
slowEma = ta.ema(close, slowLen)

// Regime state: uptrend when fast is above slow, downtrend when below
isUptrend   = fastEma > slowEma
isDowntrend = fastEma < slowEma

// --- Candlestick Geometry ---
bodySize   = math.abs(close - open)
candleRange = high - low
isGreen    = close > open
isRed      = close < open

// Wick lengths differ between green and red candles because body top/bottom flip
lowerWick = isGreen ? (open - low)  : (close - low)
upperWick = isGreen ? (high - close) : (high - open)

// Previous bar properties needed for two-bar patterns
prevIsGreen    = close[1] > open[1]
prevIsRed      = close[1] < open[1]
prevBodyTop    = math.max(open[1], close[1])
prevBodyBottom = math.min(open[1], close[1])

// --- Candlestick Pattern Detection ---

// Engulfing: current body fully wraps the prior body in the opposite direction
bullEngulfing = prevIsRed  and isGreen and close > prevBodyTop    and open < prevBodyBottom
bearEngulfing = prevIsGreen and isRed  and close < prevBodyBottom and open > prevBodyTop

// Hammer: lower shadow dominates — price tested lower levels and recovered
// Ratio thresholds (2× body, 0.5× body) are the conventional minimums
isHammer = lowerWick > (bodySize * 2) and upperWick < (bodySize * 0.5)

// Upper-wick patterns share the same geometry but carry opposite implications by color:
//   Green body → Inverted Hammer (potential bullish continuation after rejection)
//   Red body   → Hanging Man (potential bearish exhaustion at highs)
//   Shooting Star is the bearish signal variant used in the sell condition below
isShootingStar   = upperWick > (bodySize * 2) and lowerWick < (bodySize * 0.5) and isRed
isInvertedHammer = upperWick > (bodySize * 2) and lowerWick < (bodySize * 0.5) and isGreen
isHangingMan     = upperWick > (bodySize * 2) and lowerWick < (bodySize * 0.5) and isRed

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{

// Trend-gating: suppress countertrend patterns at the calculation level.
// A hammer in a downtrend is noise; only accept it when the fast EMA is above the slow EMA.
validBuy  = (bullEngulfing or isHammer or isInvertedHammer) and isUptrend
validSell = (bearEngulfing or isShootingStar or isHangingMan) and isDowntrend

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{

// EMAs recolor to reflect regime state
emaColor = isUptrend ? bullColor : isDowntrend ? bearColor : neutralColor
pFast = plot(fastEma, title="Fast EMA", color=emaColor, linewidth=2)
pSlow = plot(slowEma, title="Slow EMA", color=emaColor, linewidth=2)

// Cloud fill with high transparency — visible but not distracting
cloudColor = isUptrend ? color.new(bullColor, 88) : isDowntrend ? color.new(bearColor, 88) : color.new(neutralColor, 88)
fill(pFast, pSlow, color=cloudColor, title="Trend Cloud")

barcolor(colorCands ? emaColor : na)

// Subtle background shading — trend zone reinforcement
bgcolor(isUptrend   ? color.new(bullColor, 92) : na, title="Uptrend Background")
bgcolor(isDowntrend ? color.new(bearColor, 92) : na, title="Downtrend Background")

// Dashboard: live trend status and EMA values at a glance
var table infoTable = table.new(position.top_right, 2, 4,
     bgcolor=color.new(color.black, 80),
     frame_color=color.gray,
     frame_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Aura Oracle",    text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, syminfo.tickerid,  text_color=color.gray,  text_size=size.small)

    string trendStatus = isUptrend ? "🟢 UPTREND" : isDowntrend ? "🔴 DOWNTREND" : "⚪ NEUTRAL"
    table.cell(infoTable, 0, 1, "Trend:",     text_color=color.white,                             text_size=size.small)
    table.cell(infoTable, 1, 1, trendStatus,  text_color=isUptrend ? bullColor : bearColor,        text_size=size.small)

    table.cell(infoTable, 0, 2, "Fast EMA:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(fastEma, format.mintick), text_color=bullColor, text_size=size.small)

    table.cell(infoTable, 0, 3, "Slow EMA:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(slowEma, format.mintick), text_color=bearColor, text_size=size.small)

//---------------------------------------------------------------------------------------------------------------------}
// ALERTS
//---------------------------------------------------------------------------------------------------------------------{

alertcondition(validBuy,  title="🟢 Aura BUY Signal",
     message="High Probability Bullish Reversal Detected in Uptrend.\nPattern: Engulfing/Hammer\nSymbol: {{ticker}}\nPrice: {{close}}")

alertcondition(validSell, title="🔴 Aura SELL Signal",
     message="High Probability Bearish Reversal Detected in Downtrend.\nPattern: Engulfing/Shooting Star\nSymbol: {{ticker}}\nPrice: {{close}}")

alertcondition(ta.crossover(fastEma, slowEma),  title="⬆️ Trend Shift to Uptrend",
     message="Fast EMA crossed above Slow EMA - Uptrend Beginning")

alertcondition(ta.crossunder(fastEma, slowEma), title="⬇️ Trend Shift to Downtrend",
     message="Fast EMA crossed below Slow EMA - Downtrend Beginning")
````
