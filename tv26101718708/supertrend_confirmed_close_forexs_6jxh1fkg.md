# Supertrend Confirmed Close | forexs

- url: https://www.tradingview.com/script/6jXh1FKG-Supertrend-Confirmed-Close-forexs/
- type: indicator
- pine_id: PUB;c838d49c12de4c40b16f7c386b3183c5
- version: 1.0

## Description

# Supertrend Confirmed Close

Supertrend Confirmed Close is an open source modification of the classic ATR based Supertrend indicator. Its main purpose is to confirm trend reversals only after the current bar has closed, so temporary intrabar crossings do not create confirmed Buy or Sell signals.

## How it works

The indicator builds trailing volatility bands from Average True Range and a user selected price source.

Default settings:

ATR Period: 10

ATR Multiplier: 3.0

Source: HL2

ATR Method: Wilder ATR

An SMA of True Range can also be selected as an alternative ATR calculation.

During a bullish state, the lower Supertrend band trails price. During a bearish state, the upper Supertrend band trails price.

A bullish reversal is confirmed when the previous trend state is bearish and a completed bar closes above the previous bearish Supertrend band.

A bearish reversal is confirmed when the previous trend state is bullish and a completed bar closes below the previous bullish Supertrend band.

## What is different in this version

This implementation adds explicit closed bar confirmation to the reversal logic. The trend state, Buy signal, Sell signal, and direction change alerts are not confirmed until the bar is complete.

It also includes an optional "Freeze Supertrend Line Until Candle Close" setting. When enabled, the displayed active Supertrend line remains at its previous confirmed value while the realtime bar is forming, then updates when the bar closes.

Other additions include Pine Script v6 compatibility, organized inputs, optional trend change circles, trend highlighting, and separate alert conditions for bullish, bearish, and any confirmed direction change.

## Signals and alerts

BUY marks a confirmed change from a bearish Supertrend state to a bullish Supertrend state.

SELL marks a confirmed change from a bullish Supertrend state to a bearish Supertrend state.

These labels describe the indicator's trend state. They are not forecasts or guarantees of future price direction.

Alert conditions are provided for confirmed Buy, confirmed Sell, and confirmed direction changes. Users may also select TradingView's Once Per Bar Close frequency when creating an alert.

## Settings

Users can adjust the ATR period, ATR multiplier, source, and ATR calculation method. Buy and Sell labels, trend change circles, trend highlighting, and realtime line freezing can also be enabled or disabled.

## Limitations

Supertrend is a trend following method. In sideways or choppy markets it can change direction frequently and produce false or late signals.

Closed bar confirmation intentionally waits until the bar is complete. This avoids treating temporary intrabar crossings as confirmed reversals, but it can also make signals occur later than an intrabar implementation.

ATR settings materially affect sensitivity. Different symbols, market conditions, and timeframes can produce different behavior.

This indicator does not include position sizing, stop loss rules, profit targets, trade management, or performance guarantees. It should not be treated as a complete trading system.

For signal based use, apply it to standard price charts such as regular candles or bars rather than synthetic chart types whose prices do not represent directly traded market prices.

## Credits and open source reuse

This script reuses and modifies the open source SuperTrend implementation published by TradingView author KivancOzbilgic. That publication also credits everget, Alex Orekhov, for inspiration related to highlighting, signals, and alerts.

The reused Supertrend logic is credited here in accordance with TradingView's open source reuse requirements. This modified publication should remain open source unless the necessary permission for another publication mode has been obtained from the original author.

## Disclaimer

This indicator is provided for technical analysis and educational purposes only. It is not financial or investment advice. No signal or indicator can guarantee a profitable outcome.

## Source Code

````pine
//@version=6
indicator(
     title = "Supertrend Confirmed Close",
     shorttitle = "Supertrend CC",
     overlay = true,
     format = format.price
)

// ============================================================================
// INPUTS
// ============================================================================

atrPeriod = input.int(
     defval = 10,
     title = "ATR Period",
     minval = 1,
     group = "Supertrend Settings"
)

src = input.source(
     defval = hl2,
     title = "Source",
     group = "Supertrend Settings"
)

multiplier = input.float(
     defval = 3.0,
     title = "ATR Multiplier",
     minval = 0.1,
     step = 0.1,
     group = "Supertrend Settings"
)

useWilderATR = input.bool(
     defval = true,
     title = "Use Standard Wilder ATR",
     group = "Supertrend Settings"
)

showSignals = input.bool(
     defval = true,
     title = "Show Buy/Sell Signals",
     group = "Display"
)

showCircles = input.bool(
     defval = true,
     title = "Show Trend Change Circles",
     group = "Display"
)

highlighting = input.bool(
     defval = true,
     title = "Trend Highlighting",
     group = "Display"
)

freezeRealtimeLine = input.bool(
     defval = true,
     title = "Freeze Supertrend Line Until Candle Close",
     tooltip = "When enabled, the active Supertrend line remains at its last confirmed value while the current candle is still open.",
     group = "Display"
)

// ============================================================================
// ATR CALCULATION
// ============================================================================

// TradingView's standard Wilder-style ATR.
float atrWilder = ta.atr(atrPeriod)

// Original script's alternative ATR method:
// Simple Moving Average of True Range.
float atrSma = ta.sma(ta.tr, atrPeriod)

// Select ATR method.
float atrValue = useWilderATR ? atrWilder : atrSma

// ============================================================================
// RAW SUPERTREND BANDS
// ============================================================================

float rawUp = src - multiplier * atrValue
float rawDn = src + multiplier * atrValue

// ============================================================================
// TRAILING SUPERTREND BANDS
// ============================================================================

float up = rawUp
float dn = rawDn

// Previous finalized band values.
float upPrev = nz(up[1], rawUp)
float dnPrev = nz(dn[1], rawDn)

// Preserve original Supertrend trailing logic.
up := close[1] > upPrev ? math.max(rawUp, upPrev) : rawUp
dn := close[1] < dnPrev ? math.min(rawDn, dnPrev) : rawDn

// ============================================================================
// TREND STATE
// ============================================================================

// Trend:
//  1 = Bullish
// -1 = Bearish

var int trend = 1

// Previous confirmed trend.
int previousTrend = nz(trend[1], 1)

// Make sure ATR and Supertrend bands are available.
bool calculationReady =
     not na(atrValue) and
     not na(upPrev) and
     not na(dnPrev)

// ============================================================================
// CONFIRMED CANDLE CLOSE SIGNALS
// ============================================================================

// BUY:
// Previous trend must be bearish.
// Current candle must be confirmed closed.
// Closing price must finish ABOVE the previous bearish Supertrend band.

bool buySignal =
     calculationReady and
     barstate.isconfirmed and
     previousTrend == -1 and
     close > dnPrev

// SELL:
// Previous trend must be bullish.
// Current candle must be confirmed closed.
// Closing price must finish BELOW the previous bullish Supertrend band.

bool sellSignal =
     calculationReady and
     barstate.isconfirmed and
     previousTrend == 1 and
     close < upPrev

// ============================================================================
// UPDATE TREND
// ============================================================================

// During an open candle:
// buySignal  = false
// sellSignal = false
// trend therefore remains equal to previousTrend.
//
// The trend can only reverse on the confirmed closing execution.

trend := buySignal ? 1 : sellSignal ? -1 : previousTrend

// Confirmed direction change.
bool directionChange = buySignal or sellSignal

// ============================================================================
// STRICT REALTIME DISPLAY
// ============================================================================

// Optional strict mode.
//
// While the realtime candle is open, display the previous confirmed
// Supertrend value instead of allowing the visible line to move intrabar.
//
// This affects DISPLAY ONLY.
// Signal logic is candle-close confirmed regardless of this setting.

float displayedUp =
     freezeRealtimeLine and not barstate.isconfirmed
     ? up[1]
     : up

float displayedDn =
     freezeRealtimeLine and not barstate.isconfirmed
     ? dn[1]
     : dn

// ============================================================================
// SUPERTREND LINES
// ============================================================================

float bullishLine =
     trend == 1
     ? displayedUp
     : na

float bearishLine =
     trend == -1
     ? displayedDn
     : na

upPlot = plot(
     bullishLine,
     title = "Bullish Supertrend",
     color = color.green,
     linewidth = 2,
     style = plot.style_linebr
)

dnPlot = plot(
     bearishLine,
     title = "Bearish Supertrend",
     color = color.red,
     linewidth = 2,
     style = plot.style_linebr
)

// ============================================================================
// TREND CHANGE CIRCLES
// ============================================================================

// plot() accepts a price series, so these circles can be placed exactly
// on the Supertrend price level without relying on numeric-to-bool casting.

plot(
     showCircles and buySignal ? up : na,
     title = "Bullish Trend Start",
     color = color.green,
     linewidth = 3,
     style = plot.style_circles
)

plot(
     showCircles and sellSignal ? dn : na,
     title = "Bearish Trend Start",
     color = color.red,
     linewidth = 3,
     style = plot.style_circles
)

// ============================================================================
// BUY / SELL LABELS
// ============================================================================

// plotshape() receives a TRUE/FALSE condition as required by Pine v6.

plotshape(
     showSignals and buySignal,
     title = "Buy Signal",
     text = "BUY",
     location = location.belowbar,
     style = shape.labelup,
     size = size.tiny,
     color = color.green,
     textcolor = color.white
)

plotshape(
     showSignals and sellSignal,
     title = "Sell Signal",
     text = "SELL",
     location = location.abovebar,
     style = shape.labeldown,
     size = size.tiny,
     color = color.red,
     textcolor = color.white
)

// ============================================================================
// TREND HIGHLIGHTING
// ============================================================================

// Fully transparent price anchor for fill().
priceAnchor = plot(
     ohlc4,
     title = "Price Anchor",
     color = color.new(color.white, 100),
     editable = false
)

color bullishFill =
     highlighting and trend == 1
     ? color.new(color.green, 90)
     : na

color bearishFill =
     highlighting and trend == -1
     ? color.new(color.red, 90)
     : na

fill(
     priceAnchor,
     upPlot,
     title = "Bullish Highlight",
     color = bullishFill
)

fill(
     priceAnchor,
     dnPlot,
     title = "Bearish Highlight",
     color = bearishFill
)

// ============================================================================
// ALERT CONDITIONS
// ============================================================================

alertcondition(
     condition = buySignal,
     title = "Supertrend Buy",
     message = "Confirmed Supertrend BUY after candle close."
)

alertcondition(
     condition = sellSignal,
     title = "Supertrend Sell",
     message = "Confirmed Supertrend SELL after candle close."
)

alertcondition(
     condition = directionChange,
     title = "Supertrend Direction Change",
     message = "Confirmed Supertrend direction change after candle close."
)
````
