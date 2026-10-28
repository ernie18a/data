# 03:00 H1 Box Breakout Entries

- url: https://www.tradingview.com/script/N7HjwvOq-03-00-H1-Box-Breakout-Entries/
- type: indicator
- pine_id: PUB;da74d51d5f7f489794807467141dab96
- version: 3.0

## Description

Here's a publish-ready description for TradingView:

---

**03:00 H1 Box Breakout Entries**

A simple, clean breakout indicator built around the H1 candle at a fixed time of day (default **03:00 UTC** — fully configurable).

### How it works
1. When the chosen H1 candle (e.g. 03:00 UTC) closes, the indicator draws a **gray box** spanning that candle's high and low. The box extends to the right until the day completes.
2. The indicator then waits for any subsequent H1 candle to **close** above the box (BUY signal) or below the box (SELL signal). Only closed candles are evaluated — no signals during candle formation.
3. A **green "BUY"** label is plotted below the breakout candle, and a **red "SELL"** label above, along with a short horizontal tick at the actual entry price (the breakout candle's close).
4. If price breaks one side first and then reverses to break the opposite side ("fake break" scenario), the opposite signal is also plotted — entries alternate as long as new directional breaks occur within the same session.
5. At the next box-hour candle, a fresh box is drawn and the previous box is frozen so the chart stays clean over time.

### Inputs
- **Box Hour** — hour of day (0–23) the box is anchored to. Default: 3
- **Box Hour Timezone** — timezone string for the hour (e.g. `UTC`, `Asia/Tashkent`, `Europe/London`, `Etc/GMT-5`). Default: UTC
- **Show Entry Labels** — toggle BUY/SELL labels on/off
- **Label Offset (× ATR14)** — vertical distance of labels from candles (default 1.5)
- **Box / Buy / Sell colors** — customizable

### Notes
- This indicator must be applied on the **H1 (1 hour)** timeframe.
- The "break" rule is **close-based**: only the candle's close needs to be outside the box. Wicks or partial bodies inside the box are allowed.
- The indicator does not generate alerts, place orders, or draw stop-loss / take-profit levels — it is purely a visual aid for traders watching the daily session-open breakout setup.
- Useful as a confluence tool with your own SL/TP/risk-management framework.

### Suggested use
Combine the entry signals with your preferred risk model (e.g. SL just beyond the opposite side of the box, fixed RR target) and market-context filters (news, higher-timeframe bias, session liquidity).

---

Disclaimer line you may want to add per TradingView publishing guidelines:

> *This script is provided for educational and informational purposes only and does not constitute financial advice. Trade at your own risk.*

## Source Code

````pine
//@version=5
indicator("H1 Box Break + Retest Confirmation", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ───── Inputs ─────
boxHour         = input.int(3,     "Box Hour",            minval=0, maxval=23, group="Box")
boxTZ           = input.string("UTC", "Box Hour Timezone", group="Box", tooltip="e.g. UTC, Asia/Tashkent, Europe/London, Etc/GMT-5 (means UTC+5)")

usePinBar       = input.bool(true, "Pin Bar / Hammer / Shooting Star", group="Confirmation Patterns")
pinRatio        = input.float(2.0, "Wick : Body Ratio",   minval=1.0, step=0.5, group="Confirmation Patterns", tooltip="Lower (or upper) wick must be at least this many times the body size to qualify as a pin bar.")
useEngulfing    = input.bool(true, "Bullish / Bearish Engulfing", group="Confirmation Patterns")

showLabels      = input.bool(true, "Show Entry Labels", group="Display")
showRetestMark  = input.bool(false,"Mark Retest Candles (debug)", group="Display")
labelOffsetMult = input.float(1.5, "Label Offset (× ATR14)", minval=0.0, step=0.1, group="Display")

boxColor        = input.color(color.new(color.gray, 70), "Box",  group="Colors")
buyColor        = input.color(color.green,               "Buy",  group="Colors")
sellColor       = input.color(color.red,                 "Sell", group="Colors")

// ───── Timeframe guard ─────
if timeframe.in_seconds() > timeframe.in_seconds("60")
    runtime.error("Apply on H1 or lower (current: " + timeframe.period + ").")

// ───── Fetch the most recently CLOSED H1 candle ─────
[h1H, h1L, h1C, h1T] = request.security(syminfo.tickerid, "60", [high[1], low[1], close[1], time[1]], lookahead=barmerge.lookahead_on)
var int lastH1Time = na
newH1 = not na(h1T) and (na(lastH1Time) or h1T != lastH1Time)

// ───── State ─────
// 0 idle, 1 box active (no break yet),
// 2 broke up — waiting for retest + bullish confirmation,
// 3 broke down — waiting for retest + bearish confirmation
var int   state           = 0
var int   lastSignalDir   = 0      // 0 none, 1 long, -1 short — used to avoid duplicate same-direction signals
var float boxHigh         = na
var float boxLow          = na
var box   currentBox      = na
var int   boxBuiltForTime = na

atrVal     = ta.atr(14)
barsPerH1  = math.max(1, math.round(60.0 * 60.0 / timeframe.in_seconds()))

// ───── Box creation + initial H1 break detection ─────
if newH1
    h1Hour = hour(h1T, boxTZ)

    // New box at configured hour
    if h1Hour == boxHour and (na(boxBuiltForTime) or boxBuiltForTime != h1T)
        if not na(currentBox)
            box.set_extend(currentBox, extend.none)
            box.set_right(currentBox, bar_index - 1)

        boxHigh         := h1H
        boxLow          := h1L
        leftBar         = bar_index - barsPerH1
        currentBox      := box.new(leftBar, boxHigh, bar_index + 20, boxLow, border_color=color.new(color.gray, 40), bgcolor=boxColor, extend=extend.right)
        state           := 1
        lastSignalDir   := 0
        boxBuiltForTime := h1T

    // Initial break / direction flip (fake-break handling)
    if state != 0
        if h1C > boxHigh and state != 2
            state := 2
        else if h1C < boxLow and state != 3
            state := 3

    lastH1Time := h1T

// ───── Candlestick patterns on chart TF ─────
body      = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

// Avoid divide-by-zero on doji bars by guarding with body > 0
isHammer       = body > 0 and lowerWick > body * pinRatio and upperWick < body
isShootingStar = body > 0 and upperWick > body * pinRatio and lowerWick < body

isBullEngulf = close[1] < open[1] and close > open and close >= open[1] and open <= close[1]
isBearEngulf = close[1] > open[1] and close < open and close <= open[1] and open >= close[1]

// ───── Retest + confirmation ─────
if barstate.isconfirmed
    offset = na(atrVal) ? 0.0 : atrVal * labelOffsetMult

    // BULLISH: state 2 = H1 broke up; wait for retest at boxHigh + bullish confirm
    if state == 2 and lastSignalDir != 1
        // Hammer/pin bar that wicked into the box and closed back above
        hammerConfirm = usePinBar and isHammer and low <= boxHigh and close > boxHigh
        // Bullish engulfing where the retest leg (prev or current bar) dipped into the box, current closes above
        engulfConfirm = useEngulfing and isBullEngulf and (low[1] <= boxHigh or low <= boxHigh) and close > boxHigh

        if showRetestMark and low <= boxHigh and close > boxHigh
            label.new(bar_index, low, "•", color=color.new(color.yellow, 50), textcolor=color.white, style=label.style_label_up, size=size.tiny)

        if hammerConfirm or engulfConfirm
            reason = hammerConfirm ? "Hammer @ retest" : "Bull Engulf @ retest"
            if showLabels
                label.new(bar_index, low - offset, "BUY\n" + reason, color=buyColor, textcolor=color.white, style=label.style_label_up, size=size.small)
            line.new(bar_index, close, bar_index + 3, close, color=buyColor, width=2)
            lastSignalDir := 1

    // BEARISH: state 3 = H1 broke down; wait for retest at boxLow + bearish confirm
    else if state == 3 and lastSignalDir != -1
        shootConfirm  = usePinBar and isShootingStar and high >= boxLow and close < boxLow
        engulfConfirm = useEngulfing and isBearEngulf and (high[1] >= boxLow or high >= boxLow) and close < boxLow

        if showRetestMark and high >= boxLow and close < boxLow
            label.new(bar_index, high, "•", color=color.new(color.yellow, 50), textcolor=color.white, style=label.style_label_down, size=size.tiny)

        if shootConfirm or engulfConfirm
            reason = shootConfirm ? "Shooting Star @ retest" : "Bear Engulf @ retest"
            if showLabels
                label.new(bar_index, high + offset, "SELL\n" + reason, color=sellColor, textcolor=color.white, style=label.style_label_down, size=size.small)
            line.new(bar_index, close, bar_index + 3, close, color=sellColor, width=2)
            lastSignalDir := -1
````
