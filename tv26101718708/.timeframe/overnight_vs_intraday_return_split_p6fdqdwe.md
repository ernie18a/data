# Overnight vs Intraday Return Split

- url: https://www.tradingview.com/script/p6FDqDWe-Overnight-vs-Intraday-Return-Split/
- type: indicator
- pine_id: PUB;53916e2e8719435882cfcf5a72b32f86
- version: 2.0

## Description

Overnight vs Intraday Return Split

Overnight vs Intraday Return Split is a return-decomposition indicator that separates daily stock returns into close-to-open gap return and open-to-close session return.

The indicator separates cumulative return into two components:

1. Overnight return
   Previous close to current open.

2. Intraday return
   Current open to current close.

It also plots a Total cumulative return line for comparison.

This is a context and diagnostic tool. It is not a buy/sell indicator, not a strategy, and not a prediction model.

1. Core Idea

Many stocks do not move equally during the close-to-open window and the regular open-to-close session.

Some names may generate a large part of their historical return from gaps between the previous close and the next open. Other names may show stronger contribution from the regular trading session between open and close.

This indicator helps visualize that split by compounding the close-to-open and open-to-close components separately.

2. Important Calculation Note

This script does not separately calculate each pre-market candle or each after-hours candle.

The Overnight component represents the close-to-open gap:

Previous close → current open

The Intraday component represents the open-to-close session move:

Current open → current close

By default, the script uses daily bars internally, so it should be understood as a daily close-to-open versus open-to-close return decomposition, not a detailed extended-hours session breakdown.

3. What the Lines Mean

The indicator plots up to three lines:

* Overnight cumulative %
  Shows the compounded contribution from previous close to current open.

* Intraday cumulative %
  Shows the compounded contribution from current open to current close.

* Total cumulative %
  Shows the compounded full-period return.

The Total line is included as a reference to compare the two return components with the overall buy-and-hold style return.

4. Important Compounding Note

The Total line is compounded from log returns.

It should not be read as:

Overnight % + Intraday %

The overnight and intraday lines are compounded separately, so the visual relationship between the lines should be interpreted as a return-contribution comparison rather than a simple arithmetic sum.

5. Daily-Bar Calculation

By default, the script uses daily bars internally for the calculation.

This is intentional.

Using daily bars keeps the meaning of the close-to-open and open-to-close split consistent, even if the chart is opened on another timeframe such as 1H, 4H, or 1W.

Users can switch to Chart timeframe mode from the settings, but Daily bars is the recommended calculation source for the cleanest interpretation of the split.

6. Standard OHLC Option

The script includes an option to use standard candles for calculation.

When enabled, the calculation uses the symbol’s standard OHLC data.

This helps avoid distorted return calculations on synthetic chart types such as Heikin Ashi.

7. Optional Start Date Reset

Users can reset the cumulative comparison from a selected start date.

When this setting is enabled, the cumulative Overnight, Intraday, and Total lines restart from 0 at the chosen date.

This can be useful when studying a specific market regime, post-earnings period, IPO phase, trend phase, or custom research window.

8. Readout Label

The last-bar readout label summarizes:

* Calculation source
* Overnight cumulative return
* Intraday cumulative return
* Total cumulative return
* Which component is leading
* Latest bar overnight return
* Latest bar intraday return
* Latest bar total return

The label also includes warnings when the selected mode or market type may reduce the conceptual reliability of the split.

9. Best Markets

This indicator is best used on instruments with a real daily open and close, such as:

* Stocks
* ETFs
* Stock indices
* Session-based markets

It is generally not suitable for 24/7 markets such as crypto, because the concept of a true close-to-open gap is not the same in continuously traded markets.

10. How to Use

A practical workflow:

1. Add the indicator to a stock or ETF chart.

2. Keep Calculation source set to Daily bars.

3. Compare the Overnight and Intraday cumulative lines.

4. Watch which line contributes more to the Total return.

5. Use the readout label to identify the current leader.

6. Review whether the stock’s return profile is mostly gap-driven or session-driven.

7. Use the information as context alongside trend, volatility, volume, earnings, and broader market conditions.

8. Interpretation Examples

If the Overnight line is far above the Intraday line, the stock’s historical return during the selected period came mostly from close-to-open gaps.

If the Intraday line is far above the Overnight line, the stock’s historical return during the selected period came mostly from open-to-close session movement.

If one component is strongly positive while the other is negative, the stock may have a meaningful timing split between gap behavior and regular-session behavior.

These observations are analytical context only. They are not automatic trade signals.

12. Alerts

The script includes alert conditions for:

* Overnight cumulative return crossing above Intraday cumulative return
* Overnight cumulative return crossing below Intraday cumulative return

Alerts are informational only. They do not confirm future performance and do not execute trades.

13. Limitations

This indicator does not predict future returns.

It does not identify entries or exits.

It does not measure true order flow.

It does not separately calculate pre-market candles.

It does not separately calculate after-hours candles.

It does not include commissions, slippage, dividends, borrow costs, or tax effects.

It can behave differently around corporate actions, symbol adjustments, extended-hours data treatment, or unusual session structures.

It is less meaningful on markets that trade continuously without a true close-to-open gap.

14. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users are responsible for their own analysis, risk management, and trading decisions.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Overnight vs Intraday Return Split
// ============================================================================
// Splits stock returns into two cumulative components:
//
//   OVERNIGHT = previous close -> current open
//   INTRADAY  = current open   -> current close
//
// Purpose:
// - Shows whether a stock's historical return came mostly from overnight gaps
//   or from the regular trading session.
// - This is a context / diagnostic tool.
// - It is NOT a buy/sell signal.
// - Best used on assets with a real closed session: stocks, ETFs, indices.
// - Not suitable for 24/7 markets such as crypto.
//
// Important:
// The Total line is compounded from log returns.
// It should not be read as simple Overnight % + Intraday %.
//
// Main design:
// By default, the calculation uses DAILY bars internally even if the chart is
// opened on 1H, 4H, 1W, etc. This keeps the Overnight vs Intraday meaning correct.
// ============================================================================

indicator("Overnight vs Intraday Return Split", "ON/ID Split", overlay = false, max_labels_count = 20)

// ============================================================================
// Inputs
// ============================================================================

groupCalc = "Calculation"

calcSource = input.string(
     "Daily bars",
     "Calculation source",
     options = ["Daily bars", "Chart timeframe"],
     group = groupCalc,
     tooltip = "Daily bars is recommended. It keeps the Overnight / Intraday split correct even when the chart is opened on 1H, 4H, or 1W."
)

useStandardOHLC = input.bool(
     true,
     "Use standard candles for calculation",
     group = groupCalc,
     tooltip = "ON uses the symbol's standard OHLC data for the calculation. This avoids distorted returns on synthetic chart types such as Heikin Ashi."
)

useStartDate = input.bool(
     false,
     "Reset comparison from a start date",
     group = groupCalc,
     tooltip = "When ON, all cumulative lines restart from 0 at the selected start date."
)

// 1577836800000 = 2020-01-01 00:00:00 UTC.
// Fixed Unix timestamp avoids input.time() const/simple timestamp errors.
startDate = input.time(
     1577836800000,
     "Start date",
     group = groupCalc,
     active = useStartDate,
     tooltip = "The cumulative lines reset to 0 from this date when reset mode is enabled."
)

groupDisplay = "Display"

showOvernight = input.bool(
     true,
     "Show Overnight line",
     group = groupDisplay
)

showIntraday = input.bool(
     true,
     "Show Intraday line",
     group = groupDisplay
)

showTotal = input.bool(
     true,
     "Show Total line",
     group = groupDisplay,
     tooltip = "Total = compounded full-day return from Overnight and Intraday components. It is not a simple ON + ID percentage sum."
)

showFill = input.bool(
     true,
     "Shade lines to zero",
     group = groupDisplay
)

showZero = input.bool(
     true,
     "Show zero baseline",
     group = groupDisplay
)

lineStyleInput = input.string(
     "Stepline",
     "Line style",
     options = ["Stepline", "Line"],
     group = groupDisplay,
     tooltip = "Stepline is recommended when using Daily bars on intraday or weekly charts."
)

showReadout = input.bool(
     true,
     "Show last-bar readout label",
     group = groupDisplay
)

showWarnings = input.bool(
     true,
     "Show warnings in readout",
     group = groupDisplay
)

showCompoundingNote = input.bool(
     true,
     "Show compounding note",
     group = groupDisplay,
     tooltip = "Adds a note explaining that Total is compounded from ON and ID returns, not a simple percentage sum."
)

readoutOffset = input.int(
     2,
     "Readout label offset",
     minval = 0,
     maxval = 50,
     group = groupDisplay
)

readoutSizeInput = input.string(
     "Small",
     "Readout size",
     options = ["Tiny", "Small", "Normal"],
     group = groupDisplay
)

cOvernight = input.color(
     color.rgb(0, 150, 136),
     "Overnight color",
     group = groupDisplay
)

cIntraday = input.color(
     color.rgb(220, 70, 80),
     "Intraday color",
     group = groupDisplay
)

cTotal = input.color(
     color.rgb(120, 125, 135),
     "Total color",
     group = groupDisplay
)

cZero = input.color(
     color.new(color.gray, 60),
     "Zero line color",
     group = groupDisplay
)

readoutBg = input.color(
     color.rgb(245, 247, 250),
     "Readout background",
     group = groupDisplay
)

readoutText = input.color(
     color.rgb(25, 30, 35),
     "Readout text color",
     group = groupDisplay
)

// ============================================================================
// Helper
// ============================================================================

readoutSize =
     readoutSizeInput == "Tiny"  ? size.tiny :
     readoutSizeInput == "Small" ? size.small :
     size.normal

// ============================================================================
// Core calculation function
// ============================================================================

f_splitReturns() =>
    bool validBar = not na(close[1]) and open > 0 and close > 0 and close[1] > 0

    float overnightR = validBar ? math.log(open / close[1]) : 0.0
    float intradayR  = validBar ? math.log(close / open)    : 0.0
    float totalR     = overnightR + intradayR

    bool inRange = not useStartDate or time >= startDate
    bool firstInRange = inRange and (bar_index == 0 or not inRange[1])

    var float cumOvernight = 0.0
    var float cumIntraday  = 0.0
    var float cumTotal     = 0.0

    if firstInRange
        cumOvernight := 0.0
        cumIntraday  := 0.0
        cumTotal     := 0.0

    if inRange
        cumOvernight += overnightR
        cumIntraday  += intradayR
        cumTotal     += totalR

    float overnightPct = inRange ? (math.exp(cumOvernight) - 1.0) * 100.0 : na
    float intradayPct  = inRange ? (math.exp(cumIntraday)  - 1.0) * 100.0 : na
    float totalPct     = inRange ? (math.exp(cumTotal)     - 1.0) * 100.0 : na

    float lastOvernightPct = inRange ? (math.exp(overnightR) - 1.0) * 100.0 : na
    float lastIntradayPct  = inRange ? (math.exp(intradayR)  - 1.0) * 100.0 : na
    float lastTotalPct     = inRange ? (math.exp(totalR)     - 1.0) * 100.0 : na

    [overnightPct, intradayPct, totalPct, lastOvernightPct, lastIntradayPct, lastTotalPct]

// ============================================================================
// Data source
// ============================================================================

symbolForCalc = useStandardOHLC ? ticker.standard(syminfo.tickerid) : syminfo.tickerid

[dailyOvernightPct, dailyIntradayPct, dailyTotalPct, dailyLastOvernightPct, dailyLastIntradayPct, dailyLastTotalPct] =
     request.security(
         symbolForCalc,
         "D",
         f_splitReturns(),
         barmerge.gaps_off,
         barmerge.lookahead_off
     )

[chartOvernightPct, chartIntradayPct, chartTotalPct, chartLastOvernightPct, chartLastIntradayPct, chartLastTotalPct] =
     request.security(
         symbolForCalc,
         timeframe.period,
         f_splitReturns(),
         barmerge.gaps_off,
         barmerge.lookahead_off
     )

useDailyData = calcSource == "Daily bars"

overnightPct     = useDailyData ? dailyOvernightPct     : chartOvernightPct
intradayPct      = useDailyData ? dailyIntradayPct      : chartIntradayPct
totalPct         = useDailyData ? dailyTotalPct         : chartTotalPct
lastOvernightPct = useDailyData ? dailyLastOvernightPct : chartLastOvernightPct
lastIntradayPct  = useDailyData ? dailyLastIntradayPct  : chartLastIntradayPct
lastTotalPct     = useDailyData ? dailyLastTotalPct     : chartLastTotalPct

// ============================================================================
// Plotting
// ============================================================================

plotStyle = lineStyleInput == "Stepline" ? plot.style_stepline : plot.style_line

pZero = plot(
     0.0,
     "Zero",
     color = showZero ? cZero : na,
     linewidth = 1
)

pOvernight = plot(
     showOvernight ? overnightPct : na,
     "Overnight cumulative %",
     color = cOvernight,
     linewidth = 2,
     style = plotStyle
)

pIntraday = plot(
     showIntraday ? intradayPct : na,
     "Intraday cumulative %",
     color = cIntraday,
     linewidth = 2,
     style = plotStyle
)

pTotal = plot(
     showTotal ? totalPct : na,
     "Total cumulative %",
     color = cTotal,
     linewidth = 1,
     style = plotStyle
)

fill(
     pOvernight,
     pZero,
     color = showFill and showOvernight ? color.new(cOvernight, 88) : na,
     title = "Overnight fill"
)

fill(
     pIntraday,
     pZero,
     color = showFill and showIntraday ? color.new(cIntraday, 88) : na,
     title = "Intraday fill"
)

// ============================================================================
// Last-bar readout label
// ============================================================================

var label readoutLabel = na

hasData = not na(overnightPct) and not na(intradayPct) and not na(totalPct)

if barstate.islast and showReadout and hasData
    string dataModeText = useDailyData ? "Calculation: Daily bars" : "Calculation: Chart timeframe"

    string latestBarText = useDailyData ? "Latest daily bar:" : "Latest chart bar:"

    string leader = overnightPct >= intradayPct ? "Overnight" : "Intraday"
    float spread = math.abs(overnightPct - intradayPct)

    string compoundingText = showCompoundingNote ? "\nNote: Total is compounded from ON and ID returns, not a simple percentage sum." : ""

    string warningText = ""

    if showWarnings and syminfo.type == "crypto"
        warningText += "\n\nWarning: Crypto trades 24/7, so Overnight vs Intraday is not conceptually reliable."

    if showWarnings and not useDailyData
        warningText += "\n\nWarning: Chart timeframe mode changes the meaning of the split. Daily bars is recommended."

    string txt =
         dataModeText +
         "\nOvernight: " + str.tostring(overnightPct, "#.#") + "%" +
         "\nIntraday: "  + str.tostring(intradayPct, "#.#") + "%" +
         "\nTotal: "     + str.tostring(totalPct, "#.#") + "%" +
         "\nLeader: "    + leader + " by " + str.tostring(spread, "#.#") + " pts" +
         compoundingText +
         "\n\n" + latestBarText +
         "\nON: "    + str.tostring(lastOvernightPct, "#.##") + "%" +
         " | ID: "  + str.tostring(lastIntradayPct, "#.##") + "%" +
         " | TOT: " + str.tostring(lastTotalPct, "#.##") + "%" +
         warningText

    float labelY = showTotal ? totalPct : math.max(nz(overnightPct, 0.0), nz(intradayPct, 0.0))

    if na(readoutLabel)
        readoutLabel := label.new(
             bar_index + readoutOffset,
             labelY,
             txt,
             style = label.style_label_left,
             color = color.new(readoutBg, 0),
             textcolor = readoutText,
             size = readoutSize
        )
    else
        label.set_xy(readoutLabel, bar_index + readoutOffset, labelY)
        label.set_text(readoutLabel, txt)
        label.set_color(readoutLabel, color.new(readoutBg, 0))
        label.set_textcolor(readoutLabel, readoutText)
        label.set_size(readoutLabel, readoutSize)

if barstate.islast and (not showReadout or not hasData) and not na(readoutLabel)
    label.delete(readoutLabel)
    readoutLabel := na

// ============================================================================
// Data Window values
// ============================================================================

plot(overnightPct, "Data: Overnight cumulative %", display = display.data_window)
plot(intradayPct,  "Data: Intraday cumulative %",  display = display.data_window)
plot(totalPct,     "Data: Total cumulative %",     display = display.data_window)

plot(lastOvernightPct, "Data: Latest overnight %", display = display.data_window)
plot(lastIntradayPct,  "Data: Latest intraday %",  display = display.data_window)
plot(lastTotalPct,     "Data: Latest total %",     display = display.data_window)

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     ta.crossover(overnightPct, intradayPct),
     "Overnight crossed above Intraday",
     "Overnight cumulative return crossed above Intraday cumulative return."
)

alertcondition(
     ta.crossunder(overnightPct, intradayPct),
     "Overnight crossed below Intraday",
     "Overnight cumulative return crossed below Intraday cumulative return."
)

// ============================================================================
// End of file
// ============================================================================
````
