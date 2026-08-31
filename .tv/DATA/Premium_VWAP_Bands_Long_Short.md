<!-- tradingview-pine-id: PUB;2ac3961be4f74c70a6a64b4325268bb5 -->
<!-- tradingviewscripts-format: 1 -->
# Premium VWAP Bands — Long / Short

Source: https://www.tradingview.com/script/VMAoLcz8/

## Description

# Premium Session VWAP Bands — Long / Short Trend

## Overview

Premium Session VWAP Bands is a minimalist trend-direction indicator designed to provide an immediate visual reading of the current intraday market bias.

The indicator uses only:

* Session VWAP
* VWAP slope
* Price position relative to VWAP
* Standard-deviation bands

It does not use RSI, MACD, moving averages, ATR, ADX, SuperTrend, order flow, volume profile, fair value gaps, or Smart Money Concepts.

The main objective is simplicity. A trader should be able to look at the chart and identify one of three market states:

* LONG
* SHORT
* NEUTRAL

The current state is communicated through a subtle chart background and a compact information panel in the upper-right corner.

This is an indicator, not a strategy. It does not place orders, calculate position size, provide automatic entries, or generate backtest results.

---

## Core VWAP Calculation

The central gold line represents the session VWAP.

VWAP stands for Volume Weighted Average Price. It measures the average traded price while assigning greater weight to prices where more volume occurred.

The VWAP calculation resets at the beginning of each new trading day. This makes the indicator primarily suitable for intraday analysis.

The session VWAP acts as the main directional reference:

* Price above VWAP indicates that the market is trading above the session’s volume-weighted average.
* Price below VWAP indicates that the market is trading below the session’s volume-weighted average.
* Price moving repeatedly around VWAP usually indicates balance, consolidation, or an unclear directional advantage.

The VWAP line is intentionally more prominent than the bands and uses a matte-gold color by default.

---

## VWAP Bands

The indicator displays one upper band and one lower band around VWAP.

The bands are calculated using standard deviation and are designed to show how far price has moved away from the session VWAP.

The default Band Multiplier is:

1.0

A lower multiplier creates narrower bands and makes them more sensitive to smaller price movements.

A higher multiplier creates wider bands and highlights more significant price extensions.

The bands should not automatically be interpreted as buy or sell signals.

For example:

* A touch of the Upper Band does not automatically mean that price should reverse downward.
* A touch of the Lower Band does not automatically mean that price should reverse upward.

During a strong trend, price may remain near or outside one band for an extended period.

The bands are best used to evaluate:

* Price extension from VWAP
* Pullbacks toward the session average
* Trend continuation conditions
* Potential mean-reversion areas
* The current structure of intraday volatility

---

# Background Trend Logic

The background is the primary directional feature of the indicator.

It uses three possible states:

* Green background: LONG
* Red background: SHORT
* No background: NEUTRAL

The background is intentionally highly transparent so that candles, drawings, levels, and price action remain clearly visible.

The default transparency is 91%.

---

## Green Background — LONG Trend

The chart background becomes dark green only when all required LONG conditions are confirmed.

A LONG state requires:

1. The current price to close above VWAP.
2. VWAP to be higher than it was on the previous bar.
3. The calculated VWAP slope to be positive.
4. Price to remain clearly above the internal neutral zone around VWAP.
5. The bar to be closed and confirmed.

In simplified terms:

Price is above a rising VWAP.

The green background indicates a bullish intraday environment in which long setups may be given priority over short setups.

It does not mean that a trader should immediately enter a long position when the background turns green.

A more conservative approach is to wait for:

* A pullback toward VWAP
* A successful rejection of VWAP
* A higher low
* A bullish candle confirmation
* A breakout followed by continuation
* Confluence with the trader’s existing market structure analysis

The green background should therefore be treated as a directional filter rather than an automatic entry signal.

### Example LONG interpretation

When the background is green:

* Long setups are aligned with the current VWAP direction.
* Countertrend short positions carry additional risk.
* Pullbacks toward VWAP may provide more favorable locations than buying after an extended move.
* Price remaining above a rising VWAP supports the continuation of the bullish state.

The LONG state remains active only while the required conditions continue to be satisfied.

---

## Red Background — SHORT Trend

The chart background becomes dark red only when all required SHORT conditions are confirmed.

A SHORT state requires:

1. The current price to close below VWAP.
2. VWAP to be lower than it was on the previous bar.
3. The calculated VWAP slope to be negative.
4. Price to remain clearly below the internal neutral zone around VWAP.
5. The bar to be closed and confirmed.

In simplified terms:

Price is below a falling VWAP.

The red background indicates a bearish intraday environment in which short setups may be given priority over long setups.

It does not mean that a trader should immediately enter a short position when the background turns red.

A more conservative approach is to wait for:

* A pullback toward VWAP
* A rejection below VWAP
* A lower high
* A bearish candle confirmation
* A breakdown followed by continuation
* Confluence with the trader’s existing market structure analysis

The red background should be treated as a directional filter rather than an automatic entry signal.

### Example SHORT interpretation

When the background is red:

* Short setups are aligned with the current VWAP direction.
* Countertrend long positions carry additional risk.
* Pullbacks toward VWAP may provide better locations than selling after an extended decline.
* Price remaining below a falling VWAP supports the continuation of the bearish state.

The SHORT state remains active only while the required conditions continue to be satisfied.

---

## No Background — NEUTRAL Trend

When neither the LONG nor SHORT conditions are fully satisfied, the indicator changes to the NEUTRAL state.

The background is then completely removed.

A NEUTRAL state may occur when:

* VWAP is flat or nearly flat.
* Price is too close to VWAP.
* Price is above VWAP while VWAP is falling.
* Price is below VWAP while VWAP is rising.
* Price repeatedly crosses VWAP.
* The market is consolidating.
* Directional conditions are conflicting.
* The session has just started and insufficient VWAP information is available.

The indicator uses a small internal neutral zone around VWAP. This zone is equal to 5% of the current distance between VWAP and the Upper Band.

Its purpose is to prevent very small movements directly around VWAP from being immediately classified as LONG or SHORT.

When price remains inside this area, the state stays NEUTRAL even if price is marginally above or below VWAP.

This helps reduce rapid background switching when the market is balanced around its session average.

A NEUTRAL state should not automatically be interpreted as a reversal signal. It means only that the indicator does not currently detect a sufficiently clear directional alignment.

---

# Trend Information Panel

A compact panel appears in the upper-right corner of the chart.

It displays one of three values:

* Trend: LONG
* Trend: SHORT
* Trend: NEUTRAL

The panel uses:

* Green text for LONG
* Red text for SHORT
* Gray text for NEUTRAL

The panel is intended to provide a clear trend reading without adding unnecessary statistics or visual clutter.

It can be disabled in the indicator settings.

---

# Alert Conditions

The indicator includes three alert conditions:

## LONG Trend Activated

Triggered when the confirmed trend state changes from SHORT or NEUTRAL to LONG.

The alert is generated only when a closed bar confirms that:

* Price is above VWAP
* VWAP is rising
* Price is outside the neutral zone

## SHORT Trend Activated

Triggered when the confirmed trend state changes from LONG or NEUTRAL to SHORT.

The alert is generated only when a closed bar confirms that:

* Price is below VWAP
* VWAP is falling
* Price is outside the neutral zone

## Neutral Trend

Triggered when the confirmed trend state changes from LONG or SHORT to NEUTRAL.

This may indicate that:

* Trend momentum has weakened
* Price has returned toward VWAP
* VWAP has flattened
* Price and VWAP direction are no longer aligned

Alerts trigger only when the state changes. They do not repeat on every bar while the same state remains active.

For the most consistent behavior, alerts should be configured using:

Once Per Bar Close

---

# Suggested Use on the 2-Minute Timeframe

The indicator was designed primarily for the 2-minute timeframe, especially for intraday markets such as index futures.

On a 2-minute chart, the indicator can be used as a directional filter:

## During a LONG state

Traders may focus on:

* Pullbacks toward VWAP
* Bullish reactions above VWAP
* Higher-low formations
* Continuation after consolidation
* Long setups that agree with the session direction

## During a SHORT state

Traders may focus on:

* Pullbacks toward VWAP
* Bearish reactions below VWAP
* Lower-high formations
* Continuation after consolidation
* Short setups that agree with the session direction

## During a NEUTRAL state

Traders may consider:

* Waiting for clearer directional alignment
* Reducing trade frequency
* Avoiding repeated entries around VWAP
* Monitoring for a confirmed transition into LONG or SHORT

Because the 2-minute timeframe contains significant market noise, the indicator should not be used as a standalone entry system.

It is better suited to filtering direction while entries are determined using price action, market structure, support and resistance, risk management, or another independently tested method.

---

# Recommended Starting Settings

For a standard 2-minute intraday chart:

* Show VWAP: Enabled
* Show Bands: Enabled
* Band Multiplier: 1.0
* Enable Background: Enabled
* Background Transparency: 91
* Show Trend Panel: Enabled

Possible Band Multiplier adjustments:

* 0.8: Narrower and more sensitive bands
* 1.0: Balanced default setting
* 1.2–1.5: Wider bands showing more significant price extension

There is no universal setting that will perform equally well on every instrument or market condition. Parameters should be evaluated separately for the selected symbol, session, and trading style.

---

# Best Market Conditions

The indicator is generally easier to interpret when:

* The market has a clear intraday direction.
* VWAP has a visible positive or negative slope.
* Price remains consistently on one side of VWAP.
* Pullbacks are orderly.
* Trading volume and liquidity are sufficient.
* The market has moved out of an earlier consolidation.

The indicator may become less useful when:

* VWAP is nearly flat.
* Price crosses VWAP repeatedly.
* The market is moving sideways.
* Liquidity is low.
* Price action is highly erratic.
* Major economic news creates extreme short-term volatility.
* A new trading session has only recently started.

---

# Important Limitations

This indicator does not predict future price movements.

A green background does not guarantee that price will continue rising.

A red background does not guarantee that price will continue falling.

VWAP and its slope are calculated from existing price and volume data. As market conditions change, the trend state can also change.

The indicator does not include:

* Entry signals
* Stop-loss levels
* Take-profit levels
* Position sizing
* Risk-to-reward calculations
* Trade management
* Performance statistics
* Strategy backtesting

Users remain responsible for defining their own entry criteria, exit criteria, risk limits, session selection, and position size.

---

# Repainting and Calculation Behavior

The indicator does not use future data, look-ahead settings, or higher-timeframe security requests.

Trend states and alerts are confirmed only after the current candle closes.

Once a historical candle has closed, its confirmed trend state does not change because of later price data.

During the formation of a live candle, the VWAP line and bands may naturally move as price and volume update. However, a new confirmed LONG, SHORT, or NEUTRAL state is registered only at the candle close.

This design helps prevent alerts from being generated by temporary intrabar movements.

---

# Summary

Premium Session VWAP Bands is designed for traders who want a clean and immediate view of intraday direction without using multiple overlapping indicators.

Its interpretation is intentionally simple:

* Green background: price is above a rising VWAP
* Red background: price is below a falling VWAP
* No background: directional conditions are unclear or neutral

The indicator is best used as a trend-direction filter and market-context tool. It should be combined with independently tested entry rules and appropriate risk management.

This indicator is provided for informational and educational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument.

---

## Source Code

````pine
//@version=6
indicator(
     title      = "Premium VWAP Bands — Long / Short",
     shorttitle = "VWAP L/S",
     overlay    = true
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string GROUP_VWAP       = "VWAP"
string GROUP_BANDS      = "Bands"
string GROUP_BACKGROUND = "Background"
string GROUP_COLORS     = "Colors"
string GROUP_PANEL      = "Trend Panel"

// VWAP
bool showVwap = input.bool(
     defval = true,
     title  = "Show VWAP",
     group  = GROUP_VWAP
)

// Bands
bool showBands = input.bool(
     defval = true,
     title  = "Show Bands",
     group  = GROUP_BANDS
)

float bandMultiplier = input.float(
     defval = 1.0,
     title  = "Band Multiplier",
     minval = 0.1,
     maxval = 5.0,
     step   = 0.1,
     group  = GROUP_BANDS
)

// Background
bool enableBackground = input.bool(
     defval = true,
     title  = "Enable Background",
     group  = GROUP_BACKGROUND
)

int backgroundTransparency = input.int(
     defval = 91,
     title  = "Transparency",
     minval = 0,
     maxval = 100,
     group  = GROUP_BACKGROUND
)

// Colors
color vwapColor = input.color(
     defval = color.rgb(184, 150, 72),
     title  = "VWAP Color",
     group  = GROUP_COLORS
)

color upperBandColor = input.color(
     defval = color.rgb(82, 82, 82),
     title  = "Upper Band Color",
     group  = GROUP_COLORS
)

color lowerBandColor = input.color(
     defval = color.rgb(82, 82, 82),
     title  = "Lower Band Color",
     group  = GROUP_COLORS
)

color longBackgroundColor = input.color(
     defval = color.rgb(24, 82, 57),
     title  = "Long Background",
     group  = GROUP_COLORS
)

color shortBackgroundColor = input.color(
     defval = color.rgb(105, 38, 38),
     title  = "Short Background",
     group  = GROUP_COLORS
)

// Trend panel
bool showTrendPanel = input.bool(
     defval = true,
     title  = "Show Trend Panel",
     group  = GROUP_PANEL
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP AND STANDARD-DEVIATION BANDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// A new VWAP calculation begins with every trading day.
bool newTradingDay = timeframe.change("1D")

// Native Pine Script VWAP calculation.
// The overload returns VWAP together with standard-deviation bands.
[sessionVwap, upperBand, lowerBand] = ta.vwap(
     hlc3,
     newTradingDay,
     bandMultiplier
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND-STATE LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int STATE_SHORT   = -1
int STATE_NEUTRAL = 0
int STATE_LONG    = 1

// VWAP direction based exclusively on its current and previous values.
float vwapSlope = sessionVwap - sessionVwap[1]

bool vwapRising  = not na(vwapSlope) and vwapSlope > 0
bool vwapFalling = not na(vwapSlope) and vwapSlope < 0

// Small internal dead zone around VWAP.
// It prevents rapid LONG/SHORT switching when price is effectively sitting
// directly on the VWAP. The zone scales automatically with band width.
float bandHalfWidth = math.abs(upperBand - sessionVwap)
float neutralZone   = bandHalfWidth * 0.05

bool priceClearlyAboveVwap = close > sessionVwap + neutralZone
bool priceClearlyBelowVwap = close < sessionVwap - neutralZone

bool rawLongCondition =
     not na(sessionVwap) and
     vwapRising and
     priceClearlyAboveVwap

bool rawShortCondition =
     not na(sessionVwap) and
     vwapFalling and
     priceClearlyBelowVwap

int calculatedState =
     rawLongCondition  ? STATE_LONG  :
     rawShortCondition ? STATE_SHORT :
     STATE_NEUTRAL

// The public trend state updates only after candle confirmation.
// This prevents an unfinished realtime candle from permanently changing
// historical trend states or triggering an unconfirmed alert.
var int trendState = STATE_NEUTRAL

if barstate.isconfirmed
    trendState := calculatedState

bool isLong    = trendState == STATE_LONG
bool isShort   = trendState == STATE_SHORT
bool isNeutral = trendState == STATE_NEUTRAL

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL OUTPUT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     series    = showVwap ? sessionVwap : na,
     title     = "VWAP",
     color     = vwapColor,
     linewidth = 3
)

plot(
     series    = showBands ? upperBand : na,
     title     = "Upper Band",
     color     = upperBandColor,
     linewidth = 2
)

plot(
     series    = showBands ? lowerBand : na,
     title     = "Lower Band",
     color     = lowerBandColor,
     linewidth = 2
)

color trendBackground =
     isLong  ? color.new(longBackgroundColor, backgroundTransparency)  :
     isShort ? color.new(shortBackgroundColor, backgroundTransparency) :
     na

bgcolor(
     color = enableBackground ? trendBackground : na,
     title = "Trend Background"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MINIMAL TREND PANEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color panelBackground = color.new(color.rgb(18, 18, 18), 8)
color panelBorder     = color.new(color.rgb(184, 150, 72), 35)

color trendTextColor =
     isLong  ? color.rgb(90, 170, 125) :
     isShort ? color.rgb(190, 90, 90)  :
     color.rgb(145, 145, 145)

string trendText =
     isLong  ? "Trend: LONG" :
     isShort ? "Trend: SHORT" :
     "Trend: NEUTRAL"

var table trendPanel = table.new(
     position     = position.top_right,
     columns      = 1,
     rows         = 1,
     bgcolor      = panelBackground,
     frame_color  = panelBorder,
     frame_width  = 1,
     border_color = panelBorder,
     border_width = 1
)

if barstate.islast
    if showTrendPanel
        table.cell(
             table_id         = trendPanel,
             column           = 0,
             row              = 0,
             text             = trendText,
             text_color       = trendTextColor,
             text_size        = size.small,
             text_halign      = text.align_center,
             text_valign      = text.align_center,
             bgcolor          = panelBackground,
             width            = 14,
             height           = 2
        )
    else
        table.clear(trendPanel, 0, 0, 0, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE-CHANGE ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Alerts trigger only when a confirmed candle changes the trend state.
bool longTrendActivated =
     barstate.isconfirmed and
     trendState == STATE_LONG and
     trendState[1] != STATE_LONG

bool shortTrendActivated =
     barstate.isconfirmed and
     trendState == STATE_SHORT and
     trendState[1] != STATE_SHORT

bool neutralTrendActivated =
     barstate.isconfirmed and
     trendState == STATE_NEUTRAL and
     trendState[1] != STATE_NEUTRAL

alertcondition(
     condition = longTrendActivated,
     title     = "LONG Trend Activated",
     message   = "LONG trend activated: price is above a rising VWAP."
)

alertcondition(
     condition = shortTrendActivated,
     title     = "SHORT Trend Activated",
     message   = "SHORT trend activated: price is below a falling VWAP."
)

alertcondition(
     condition = neutralTrendActivated,
     title     = "Neutral Trend",
     message   = "VWAP trend changed to NEUTRAL."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AUTOMATIC CODE AUDIT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// ✓ Indicator uses Pine Script v6 and indicator() only.
// ✓ No strategy functions or backtesting logic.
// ✓ No request.security() calls.
// ✓ No look-ahead settings.
// ✓ No future-bar references.
// ✓ No loops, arrays, labels, lines or unnecessary calculations.
// ✓ Trend states and alerts update only on confirmed candles.
// ✓ Alerts fire only when the confirmed trend state changes.
// ✓ VWAP and bands use TradingView's native ta.vwap() implementation.
// ✓ No repainting after a candle has closed.
// ✓ No future leak.
// ✓ No look-ahead bias.
// ✓ Optimized for lightweight execution on 2-minute charts.
//
````
