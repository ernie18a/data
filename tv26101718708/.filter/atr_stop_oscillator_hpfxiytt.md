# ATR Stop Oscillator

- url: https://www.tradingview.com/script/hpFxiYtT-ATR-Stop-Oscillator/
- type: indicator
- pine_id: PUB;24474d0d26a047e38e5416d1a462c122
- version: 2.0

## Description

**What This Indicator Does — In Plain Terms**

This is a trend-following tool that measures how far price has moved away from its own volatility-based "safety line" (the ATR trailing stop), and displays that distance as a bar chart (histogram) below your main price chart — similar in spirit to how RSI or MACD sits below the chart, except this one is tracking distance from a trailing stop instead of momentum.

Here's the core idea in one sentence: **the indicator draws an invisible line that trails behind price and adjusts itself based on volatility (ATR), and the oscillator shows you how many "ATR units" price currently is above or below that line.**

- When the bars are **green and above the zero line**, price is above its trailing stop — meaning the trend is currently bullish/long-favoring.
- When the bars are **red and below the zero line**, price is below its trailing stop — meaning the trend is currently bearish/short-favoring.
- The **farther the bar is from zero**, the more "stretched" price is from its stop, in multiples of ATR (e.g., a reading of 3.0 means price is 3 full ATR units away from the stop line).
- When the bars **flip from red to green (or vice versa)**, that's a trend change — and that's exactly what triggers your alert.

---

**Input-by-Input Breakdown**

**Non-Repainting Signals (`ConfirmOnClose`)**
- **What it does:** Controls whether the trend-change alert waits for the current candle to fully close before firing, or fires immediately as soon as the condition is met — even mid-candle.
- **Why it matters:** If left ON (default), you avoid false or "fake" signals that flip back and forth while a candle is still forming — the alert only confirms once the bar is locked in. If turned OFF, you'll get faster signals, but some of them may reverse or disappear before the candle actually closes, since price is still moving. Think of it as a tradeoff between speed and reliability.
- **Practical use:** Leave this ON for swing trading or anything where you can't watch the chart constantly. Turn it OFF only if you're actively watching the screen and want the earliest possible warning, accepting the risk of a signal that later gets invalidated.

**ATR Period (`Atr`)**
- **What it does:** Sets how many bars are used to calculate the Average True Range (ATR) — the volatility measurement this whole indicator is built on. Default is 5.
- **Why it matters:** A shorter period (like 5) makes the ATR — and therefore the trailing stop and oscillator — more reactive to recent price swings, so it adjusts quickly but can feel "twitchy" or noisy. A longer period (like 20 or 50) smooths things out, making the stop line and oscillator move more slowly and steadily, but it'll lag behind sudden volatility changes.
- **Practical use:** Lower values suit fast-moving or short-timeframe trading (scalping, day trading). Higher values suit slower, longer-term trend following where you don't want to be shaken out by every small wiggle.

**Multiplier (`Mult`)**
- **What it does:** Multiplies the ATR value to determine how far away the trailing stop sits from price. Default is 5.
- **Why it matters:** This directly controls how "loose" or "tight" your trailing stop is. A higher multiplier (like 5 or higher) gives price more room to breathe before the trend is considered reversed — fewer false flips, but bigger moves against you before you get an alert. A lower multiplier (like 1 or 2) tightens the stop, giving you faster trend-change signals, but at the cost of more false flips during choppy/sideways price action.
- **Practical use:** This is your single biggest lever for tuning sensitivity. Tighten it if you're getting alerts too late or missing moves; loosen it if you're getting whipsawed by too many false trend-change alerts during sideways markets.

**Above Stop Color (`PosColor`)**
- **What it does:** Sets the color of the oscillator bars when price is above the trailing stop (positive/bullish readings). Default is green.
- **Why it matters:** Purely visual — it does not affect any calculation, alert, or signal logic. It only changes what you see on the chart.
- **Practical use:** Adjust this to match your personal chart theme or color-blind-friendly palette if needed. No functional impact either way.

**Below Stop Color (`NegColor`)**
- **What it does:** Sets the color of the oscillator bars when price is below the trailing stop (negative/bearish readings). Default is red.
- **Why it matters:** Same as above — cosmetic only, no effect on calculations or alerts.
- **Practical use:** Same as above — purely a visual preference setting.

---

**What You'll See on the Chart**

- A **histogram (bar chart)** oscillating above and below a dashed gray zero line, in your own separate pane below the price chart.
- **Green bars** = price above the ATR trailing stop (bullish state).
- **Red bars** = price below the ATR trailing stop (bearish state).
- **No labels or markers** on the price chart itself — you removed those. All the trend information lives in this oscillator pane only.

**What Triggers an Alert**

- The alert fires only on an actual **trend flip** — meaning the internal trend direction changed from bullish to bearish or vice versa, not just because the oscillator crossed zero on a fluke tick.
- You'll get one alert message telling you whether it flipped **BULLISH** or **BEARISH**, plus two separate alert conditions in TradingView's alert menu if you'd rather set them up individually.

If any of this doesn't match how you're actually planning to use it (e.g., you want the color inputs to also influence something functional, or you want a numeric readout of the current ATR-multiple value), tell me and I'll adjust — I didn't want to assume beyond what's in the script.

## Source Code

````pine
//@version=6
indicator('ATR Stop Oscillator', shorttitle = 'ATR Stop Oscillator', overlay = false)

ConfirmOnClose = input.bool(true, 'Non-Repainting Signals')

Atr = input.int(5, 'Atr Period', minval = 1, maxval = 500, step = 1)
Mult = input.float(5, 'Multiplier', minval = 0.5, maxval = 10, step = 0.1)

// Signal Line Section
ShowMa = input.bool(true, 'Show Signal MA', group = 'Signal Line')
MaType = input.string('EMA', 'MA Type', options = ['SMA', 'EMA', 'WMA', 'RMA (SMMA)', 'HMA', 'VWMA'], group = 'Signal Line')
MaLen = input.int(9, 'MA Length', minval = 1, maxval = 500, group = 'Signal Line')
MaColor = input.color(color.orange, 'MA Color', group = 'Signal Line')
MaWidth = input.int(1, 'MA Line Width', minval = 1, maxval = 5, group = 'Signal Line')

// Oscillator Style Section
// Strong = full-conviction color, Weak = its low-intensity counterpart.
// Both are fully opaque shades (no transparency) so contrast holds on any background.
ColorMode = input.string('Magnitude Gradient', 'Histogram Coloring', options = ['Solid', 'Magnitude Gradient', 'Slope (4-Color)'], group = 'Oscillator Style')
PosStrong = input.color(#00e676, 'Bull Strong', inline = 'bull', group = 'Oscillator Style')
PosWeak = input.color(#1b5e20, 'Weak', inline = 'bull', group = 'Oscillator Style')
NegStrong = input.color(#ff1744, 'Bear Strong', inline = 'bear', group = 'Oscillator Style')
NegWeak = input.color(#6d1b1b, 'Weak', inline = 'bear', group = 'Oscillator Style')

atrVal = ta.atr(Atr)

longStop = close - Mult * atrVal
shortStop = close + Mult * atrVal

var float TS = na
var int dir = 1

if na(TS)
    dir := 1
    TS := longStop
else
    // TS and dir are 'var' — before reassignment they already hold the
    // previous bar's committed values, so no [1] indexing is needed.
    prevTS = TS
    prevDir = dir

    if close > prevTS
        dir := 1
    else if close < prevTS
        dir := -1

    if dir == 1
        TS := prevDir == -1 ? longStop : math.max(prevTS, longStop)
    else
        TS := prevDir == 1 ? shortStop : math.min(prevTS, shortStop)

// Normalized oscillator: distance between price and ATR stop, in ATR units.
// Bounded: [0, +Mult] while bullish, [-Mult, 0] while bearish.
osc = (close - TS) / atrVal

// Signal line: selectable MA of the oscillator.
// MaType is an input (constant per chart load), so the same branch runs on
// every bar — the ta.* calls stay internally consistent.
maCalc(src, len, typ) =>
    switch typ
        'SMA'        => ta.sma(src, len)
        'EMA'        => ta.ema(src, len)
        'WMA'        => ta.wma(src, len)
        'RMA (SMMA)' => ta.rma(src, len)
        'HMA'        => ta.hma(src, len)
        'VWMA'       => ta.vwma(src, len)

maOsc = maCalc(osc, MaLen, MaType)

// --- Histogram coloring ---
// Solid: two-color behavior using the strong shades
solidColor = osc > 0 ? PosStrong : NegStrong

// Magnitude gradient: opaque dark shade near zero -> bright shade at the ±Mult bound.
// Works cleanly here because the oscillator has known hard bounds (no normalization needed).
gradUp = color.from_gradient(osc, 0, Mult, PosWeak, PosStrong)
gradDn = color.from_gradient(osc, -Mult, 0, NegStrong, NegWeak)
gradColor = osc > 0 ? gradUp : gradDn

// Slope (4-color, MACD-histogram style): strong when the cushion to the stop is
// expanding, weak when it is shrinking. Encodes information the bar height does not.
rising = osc >= osc[1]
slopeColor = osc > 0 ? (rising ? PosStrong : PosWeak) : (rising ? NegWeak : NegStrong)

oscColor = ColorMode == 'Solid' ? solidColor : ColorMode == 'Magnitude Gradient' ? gradColor : slopeColor

plot(osc, color = oscColor, linewidth = 2, style = plot.style_columns, title = 'ATR Stop Oscillator')
plot(ShowMa ? maOsc : na, color = MaColor, linewidth = MaWidth, title = 'Signal MA')
hline(0, 'Zero Line', color = color.gray, linestyle = hline.style_dashed)

// --- Trend-change detection: based on the internal dir state ---
trendChangeUpRaw = dir == 1 and dir[1] == -1
trendChangeDownRaw = dir == -1 and dir[1] == 1

confirmGate = not ConfirmOnClose or barstate.isconfirmed

trendChangeUp = trendChangeUpRaw and confirmGate
trendChangeDown = trendChangeDownRaw and confirmGate

alertcondition(trendChangeUp, 'Trend Change: Bullish', 'ATR Stop Oscillator: Trend flipped bullish')
alertcondition(trendChangeDown, 'Trend Change: Bearish', 'ATR Stop Oscillator: Trend flipped bearish')

// Optional: oscillator / signal-MA crosses (momentum confirmation within a trend)
alertcondition(ta.crossover(osc, maOsc) and confirmGate, 'Osc Cross Above MA', 'ATR Stop Oscillator crossed above signal MA')
alertcondition(ta.crossunder(osc, maOsc) and confirmGate, 'Osc Cross Below MA', 'ATR Stop Oscillator crossed below signal MA')

// Dynamic alert — frequency respects the Non-Repainting toggle
if trendChangeUp or trendChangeDown
    msg = 'ATR Stop Oscillator: Trend changed to ' + (trendChangeUp ? 'BULLISH' : 'BEARISH')
    if ConfirmOnClose
        alert(msg, alert.freq_once_per_bar_close)
    else
        alert(msg, alert.freq_once_per_bar)
````
