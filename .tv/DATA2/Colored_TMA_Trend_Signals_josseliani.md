<!-- tradingview-pine-id: PUB;2c89b08864ad49f8aa588bfab73e23fd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Colored TMA Trend Signals [josseliani]

Source: https://www.tradingview.com/script/LOqMbiyG-Colored-TMA-Trend-Signals-josseliani/

## Description

This is a very simple indicator for beginners in trading, based on the popular Triangular Moving Average.

I wanted to keep it simple: minimal settings, clear visuals, and easy-to-understand trade logic.

TMA color-change signals are popular, but there is one thing I wanted to improve. Sometimes, by the time TMA changes direction, price has already moved quite far away from the average. The turn is there, but entering is already uncomfortable: price is stretched, and the potential stop becomes too large. 

So I added a simple candle-close confirmation engine instead of using every color change as an entry.

→ THE TMA

TMA is a Triangular Moving Average, calculated here using two consecutive simple moving averages of the same length.

Green → TMA is rising.
Red → TMA is falling.

A basic standard-deviation channel surrounds it. Optional EMA smoothing can be applied to the price source.

Small triangles mark confirmed changes between rising and falling TMA direction. They show the turn itself; BUY/SELL uses a separate confirmation.

→ BUY/SELL CONFIRMATION

For BUY, the indicator counts consecutive candle closes above the selected level. For SELL, it counts consecutive closes below it.

The default is three candles, with TMA as the confirmation level.

You can also select Bands:

• BUY → closes above the upper band.
• SELL → closes below the lower band.

Each close is compared with the level calculated on that candle.

The important detail is that the candle counters run independently of the TMA color change.

Confirmation is checked exactly on the selected Nth close — the third close by default. If the direction and signal-limit conditions do not allow a signal then, that confirmation is not reused on later candles.

The sequence must reset and form again.

For example, if price has already closed above TMA for more than three consecutive candles before TMA turns green, the earlier confirmation is not reused. Price must first close at or below TMA, then form three consecutive closes above it again.

If TMA turns green on the third close, BUY can appear together with the triangle. SELL follows the same logic in the opposite direction.

This was my simple way of skipping some entries where the move had already started before TMA turned. The script does not measure the distance from price to TMA, so a fresh confirmation can still appear far from the average.

→ ONE SIGNAL PER COLOR

With the default settings:

• A confirmed turn to green unlocks one BUY and blocks SELL.
• A confirmed turn to red unlocks one SELL and blocks BUY.

The first eligible confirmation produces the signal.

After BUY, another BUY is blocked until TMA turns red and then green again. After SELL, another SELL is blocked until it turns green and then red again.

A color section can also have no signal if the conditions are not met.

Disabling One Trade Per Color allows further signals after new confirmation sequences form. Its directional restrictions remain active while it is enabled, even if Only With TMA Trend is disabled.

→ HOW I USE IT

For me, the small triangle is simply information: TMA has changed direction.

BUY/SELL is a separate trade signal.

I made this mainly for people who are just starting to work with the market and do not want to immediately dive into complicated strategies and lots of settings.

It is basically ordinary trading with a moving average, just visualized a little more conveniently.

You can leave the default settings and watch the TMA direction and the confirmed BUY/SELL signals.

This is not a complete trading system. The trader still decides whether an entry makes sense at the current price and determines the stop, target, position size and risk management.

→ INPUTS

• Half Length → TMA smoothing length. Default: 12. The double-SMA calculation has an effective length of 2 × Half Length − 1, or 23 by default.

• Price Source → selects the calculation price. The default Weighted Price is (High + Low + 2 × Close) / 4.

• Band Deviation → standard-deviation multiplier controlling channel width. Default: 2.0. Standard deviation uses the selected source and the effective TMA length.

• Use Source Smoothing → optional EMA smoothing before calculating TMA and the channel. Disabled by default.

• Smoothing Period → optional EMA length. Default: 12.

• Show Bands → shows or hides the channel.

• Show TMA Color-Change Signals → shows or hides the triangles without disabling their alerts.

• TMA Line Width → adjusts line thickness.

• Show BUY/SELL Labels → shows or hides trade labels without disabling trade calculations or alerts.

• Break Level → selects TMA or Bands for confirmation.

• Confirm Bars → required consecutive closes, from 1 to 10. Default: 3. Confirmation is checked exactly on the selected Nth close.

• Only With TMA Trend → allows BUY only while TMA is rising and SELL only while it is falling. Enabled by default.

• One Trade Per Color → applies the directional signal limits explained above. Enabled by default.

Label spacing uses ATR and the candle range. It is only visual and does not change the signal candle or trading logic.

→ WHAT I ADDED AND WHY

TMA and standard-deviation bands are established calculations. My addition is the confirmation and signal-handling logic around them:

• Separate markers for TMA turns and BUY/SELL confirmations.
• Candle-close counters independent of color changes.
• Confirmation checked on the exact Nth close, without reusing a blocked confirmation later.
• One eligible signal per matching color turn.
• A choice of TMA or bands as confirmation levels.
• Separate alerts independent of marker visibility.

The purpose is to distinguish a moving-average turn from a confirmed price sequence while keeping the visual presentation and trading logic simple.

→ ALERTS

• TMA Bullish Color Change
• TMA Bearish Color Change
• Any TMA Color Change
• Trade Long
• Trade Short
• Any Trade Signal

All signal conditions require a closed candle. Select Once Per Bar Close when creating alerts.

→ CONFIRMATION AND LIMITATIONS

Triangles and BUY/SELL signals appear on the confirmation candle after it closes. They are not shifted into the past. The first established TMA direction does not produce a turn triangle, and unchanged TMA values preserve the last direction for turn detection.

The line, its color and the channel can change while the current candle is open. The calculation uses no future bars or higher-timeframe requests.

TMA and candle confirmation introduce delay. Signals can arrive late, sideways markets can produce unsuccessful signals, and a sequence reset does not guarantee an entry close to TMA.

Use standard time-based candles. This is an indicator, not a backtested strategy; it does not calculate trade results or a verified win rate.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © josseliani

//@version=6
indicator("Colored TMA Trend Signals [josseliani]", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
groupTma = "TMA"
halfLength = input.int(12, "Half Length", minval=1, group=groupTma)
priceMode = input.string("Weighted Price", "Price Source", options=["Close", "Open", "High", "Low", "Median Price", "Typical Price", "Weighted Price"], group=groupTma)
bandsDeviation = input.float(2.0, "Band Deviation", minval=0.1, step=0.1, group=groupTma, tooltip="Standard-deviation multiplier for the bands around TMA.")
useSmoothing = input.bool(false, "Use Source Smoothing", group=groupTma)
smoothingPeriod = input.int(12, "Smoothing Period", minval=1, group=groupTma)

groupVisual = "VISUAL"
showBands = input.bool(true, "Show Bands", group=groupVisual)
showTrendSignals = input.bool(true, "Show TMA Color-Change Signals", group=groupVisual)
lineWidth = input.int(2, "TMA Line Width", minval=1, maxval=5, group=groupVisual)

groupTrade = "TRADE SIGNALS"
showTradeSignals = input.bool(true, "Show BUY/SELL Labels", group=groupTrade, tooltip="Visual option only. Trade alerts remain active when labels are hidden.")
tradeLevel = input.string("TMA", "Break Level", options=["TMA", "Bands"], group=groupTrade)
confirmBars = input.int(3, "Confirm Bars", minval=1, maxval=10, group=groupTrade, tooltip="Confirmation is checked exactly on the Nth consecutive close beyond the selected level. If blocked, the sequence must reset before another confirmation is checked.")
tradeOnlyWithTrend = input.bool(true, "Only With TMA Trend", group=groupTrade, tooltip="BUY only while TMA is green, SELL only while red.")
onePerColor = input.bool(true, "One Trade Per Color", group=groupTrade, tooltip="A bullish turn unlocks one BUY and blocks SELL. A bearish turn unlocks one SELL and blocks BUY. After a signal, that direction stays locked until a new matching color turn.")

// ─────────────────────────────────────────────────────────────
// PRICE SOURCE
// ─────────────────────────────────────────────────────────────
src = switch priceMode
    "Open" => open
    "High" => high
    "Low" => low
    "Median Price" => hl2
    "Typical Price" => hlc3
    "Weighted Price" => hlcc4
    => close

base = useSmoothing ? ta.ema(src, smoothingPeriod) : src

// ─────────────────────────────────────────────────────────────
// TMA AND STANDARD-DEVIATION BANDS
// ─────────────────────────────────────────────────────────────
// Two equal-length SMAs produce a trailing triangular MA.
// Effective length: halfLength * 2 - 1. No future bars are used.
tmaLen = halfLength * 2 - 1
tma = ta.sma(ta.sma(base, halfLength), halfLength)
deviation = ta.stdev(base, tmaLen)
upperBand = tma + deviation * bandsDeviation
lowerBand = tma - deviation * bandsDeviation
atr = ta.atr(14)

trendUp = tma > tma[1]
trendDown = tma < tma[1]
tmaColor = trendUp ? color.lime : trendDown ? color.red : color.gray

// ─────────────────────────────────────────────────────────────
// CONFIRMED COLOR CHANGES
// ─────────────────────────────────────────────────────────────
// Flat bars preserve the last directional trend for turn detection.
var int lastSolidTrend = 0
currTrend = trendUp ? 1 : trendDown ? -1 : 0
bullishTurn = false
bearishTurn = false

if barstate.isconfirmed and currTrend != 0
    bullishTurn := currTrend == 1 and lastSolidTrend == -1
    bearishTurn := currTrend == -1 and lastSolidTrend == 1
    lastSolidTrend := currTrend

// ─────────────────────────────────────────────────────────────
// TRADE CONFIRMATION
// ─────────────────────────────────────────────────────────────
bullBreakLevel = tradeLevel == "Bands" ? upperBand : tma
bearBreakLevel = tradeLevel == "Bands" ? lowerBand : tma

// These counters run independently of TMA color changes.
var int barsAbove = 0
var int barsBelow = 0
barsAbove := close > bullBreakLevel ? barsAbove + 1 : 0
barsBelow := close < bearBreakLevel ? barsBelow + 1 : 0

var bool longUsedThisColor = false
var bool shortUsedThisColor = false

if bullishTurn
    longUsedThisColor := false
    shortUsedThisColor := true

if bearishTurn
    shortUsedThisColor := false
    longUsedThisColor := true

trendAllowsLong = not tradeOnlyWithTrend or trendUp
trendAllowsShort = not tradeOnlyWithTrend or trendDown
longSlotFree = not onePerColor or not longUsedThisColor
shortSlotFree = not onePerColor or not shortUsedThisColor
tradeBull = false
tradeBear = false

// Exact equality is intentional: blocked confirmations are not reused.
// Signal calculation is independent of label visibility.
if barstate.isconfirmed
    if barsAbove == confirmBars and trendAllowsLong and longSlotFree
        tradeBull := true
        longUsedThisColor := true

    if barsBelow == confirmBars and trendAllowsShort and shortSlotFree
        tradeBear := true
        shortUsedThisColor := true

// ─────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────
plot(tma, title="TMA", color=tmaColor, linewidth=lineWidth)
plot(showBands ? upperBand : na, title="Upper Band", color=color.new(color.gray, 50))
plot(showBands ? lowerBand : na, title="Lower Band", color=color.new(color.gray, 50))

plotshape(showTrendSignals and bullishTurn ? tma : na, title="TMA Bullish Color Change", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.tiny)
plotshape(showTrendSignals and bearishTurn ? tma : na, title="TMA Bearish Color Change", style=shape.triangledown, location=location.absolute, color=color.red, size=size.tiny)

// ─────────────────────────────────────────────────────────────
// BUY / SELL LABELS
// ─────────────────────────────────────────────────────────────
// Vertical spacing only. Labels remain on the actual signal bar.
labelGapAtr = 1.5
gap = math.max(atr * labelGapAtr, high - low)

if showTradeSignals and tradeBull
    label.new(bar_index, low - gap, "BUY", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.lime, 70), textcolor=color.lime, size=size.small)

if showTradeSignals and tradeBear
    label.new(bar_index, high + gap, "SELL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.red, 70), textcolor=color.red, size=size.small)

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────
alertcondition(bullishTurn, title="TMA Bullish Color Change", message="Colored TMA: bullish color change on {{ticker}} {{interval}}")
alertcondition(bearishTurn, title="TMA Bearish Color Change", message="Colored TMA: bearish color change on {{ticker}} {{interval}}")
alertcondition(bullishTurn or bearishTurn, title="Any TMA Color Change", message="Colored TMA: color changed on {{ticker}} {{interval}}")
alertcondition(tradeBull, title="Trade Long", message="Colored TMA: trade long on {{ticker}} {{interval}}")
alertcondition(tradeBear, title="Trade Short", message="Colored TMA: trade short on {{ticker}} {{interval}}")
alertcondition(tradeBull or tradeBear, title="Any Trade Signal", message="Colored TMA: trade signal on {{ticker}} {{interval}}")
````
