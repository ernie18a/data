# Previous Day High/Low Breakout Indicator

- url: https://www.tradingview.com/script/3QWpoMwv-Previous-Day-High-Low-Breakout-Indicator/
- type: indicator
- pine_id: PUB;ccad659184f24dc385fccf723910c6e2
- version: 1.0

## Description

[b]Previous Day High/Low Breakout Indicator[/b]

This indicator is built around a simple breakout concept:

• Bullish momentum is assumed when price closes above the Previous Day High (PDH)
• Bearish momentum is assumed when price closes below the Previous Day Low (PDL)

The script continuously tracks the previous session’s high and low levels and uses them as directional breakout triggers.

Unlike indicators that rely on multiple lagging filters, this approach focuses primarily on raw price action and market expansion beyond key reference levels.

━━━━━━━━━━━━━━━━━━

CORE LOGIC

Previous Day Range Detection

The script calculates:
• Previous Day High (PDH)
• Previous Day Low (PDL)

using the selected session settings.

These levels remain active until a new session completes and fresh PDH/PDL levels become available.

━━━━━━━━━━━━━━━━━━

LONG LOGIC

A BUY signal is generated when:

• Price closes above the Previous Day High

This indicates that price has broken beyond the prior session’s upper boundary, suggesting possible bullish continuation or expansion.

If an active short position exists internally, the script first generates a SELL EXIT signal before flipping to a BUY signal.

━━━━━━━━━━━━━━━━━━

SHORT LOGIC

A SELL signal is generated when:

• Price closes below the Previous Day Low

This indicates that price has broken beneath the prior session’s lower boundary, suggesting possible bearish continuation or downside expansion.

If an active long position exists internally, the script first generates a BUY EXIT signal before flipping to a SELL signal.

━━━━━━━━━━━━━━━━━━

EXIT LOGIC

The indicator uses an opposite-breakout exit model.

Long Exit
A BUY EXIT signal occurs when:
• A valid bearish breakout appears while a long state is active

Short Exit
A SELL EXIT signal occurs when:
• A valid bullish breakout appears while a short state is active

This creates a continuous flip-based structure where the market remains either:
• Bullish
• Bearish
• Neutral

depending on the latest breakout condition.

━━━━━━━━━━━━━━━━━━

MARKET COMPATIBILITY

This indicator is primarily designed for continuous 24-hour markets such as cryptocurrencies, where Previous Day High and Low levels often act as important breakout reference zones.

However, it can also be used on other markets such as:
• Indices
• Stocks
• Forex
• Futures

with appropriate session selection and trader discretion.

━━━━━━━━━━━━━━━━━━

FLOATING RUNNING P/L LABEL

While a trade state is active, the script displays a floating running P/L label on the chart.

The label updates dynamically and shows:
• Current trade direction
• Live unrealized percentage gain/loss

The label’s:
• Colors
• Position offset
• Visibility

can all be customized from settings.

━━━━━━━━━━━━━━━━━━

BACKTEST WINDOW

The indicator includes an optional custom backtest window.

When enabled:
• Signals
• Statistics
• Performance calculations

are restricted only to the selected date range.

This helps isolate specific market conditions or testing periods without affecting the rest of the chart.

━━━━━━━━━━━━━━━━━━

STATISTICS TABLE

A compact statistics table is included for quick performance reference.

The table displays:
• Total Trades
• Wins / Losses
• Win Rate %
• Average Win %
• Average Loss %

The table position and colors are fully customizable from settings.

━━━━━━━━━━━━━━━━━━

NOTES

• This script is an indicator, not a TradingView strategy.
• Statistics are internally calculated and intended for analytical reference only.
• Performance can vary significantly across assets, sessions, and timeframes.
• Always combine breakout systems with proper risk management and market context analysis.

━━━━━━━━━━━━━━━━━━

DISCLAIMER

This indicator is provided for educational and informational purposes only and should not be considered financial advice.

Trading involves substantial risk, and past performance does not guarantee future results. Always perform your own research, test strategies thoroughly, and use appropriate risk management before trading with real capital.

## Source Code

````pine
//@version=6
indicator("Previous Day High/Low Breakout Indicator", overlay=true, max_labels_count=500)

// ======================================================
// 📌 SETTINGS
// ======================================================
tz = "Asia/Kolkata"

// ======================================================
// 📌 BACKTEST WINDOW
// ======================================================
groupBT = "Backtest"

useBT  = input.bool(false, "Use Backtest Window", group=groupBT)
startT = input.time(timestamp("2024-01-01 00:00 +0530"), "Start", group=groupBT)
endT   = input.time(timestamp("2026-12-31 23:59 +0530"), "End", group=groupBT)

inBT = not useBT or (time >= startT and time <= endT)

// ======================================================
// 📌 PD SESSION
// ======================================================
pdSession = input.session("0000-2300", "PD Session")

inPD  = not na(time(timeframe.period, pdSession, tz))
newPD = inPD and not inPD[1]
endPD = not inPD and inPD[1]

var float sessHigh = na
var float sessLow  = na
var float pdHigh   = na
var float pdLow    = na

if newPD
    sessHigh := high
    sessLow  := low
else if inPD
    sessHigh := math.max(sessHigh, high)
    sessLow  := math.min(sessLow, low)

if endPD
    pdHigh := sessHigh
    pdLow  := sessLow

// ======================================================
// 📌 POSITION STATE
// ======================================================
var int   pos        = 0
var float entryPrice = na

longPos  = pos == 1
shortPos = pos == -1
flat     = pos == 0

// ======================================================
// 📌 PERFORMANCE VARIABLES
// ======================================================
var int totalTrades = 0
var int wins        = 0
var int losses      = 0

var float totalWinPct  = 0.0
var float totalLossPct = 0.0

// ======================================================
// 📌 SIGNALS
// ======================================================
buySignal      = false
sellSignal     = false
buyExitSignal  = false
sellExitSignal = false

// ======================================================
// 📌 LONG BREAKOUT
// ======================================================
if inBT and close > pdHigh

    // EXIT SHORT
    if shortPos

        sellExitSignal := true

        float tradePct = ((entryPrice - close) / entryPrice) * 100

        totalTrades += 1

        if tradePct > 0
            wins += 1
            totalWinPct += tradePct
        else
            losses += 1
            totalLossPct += math.abs(tradePct)

        pos := 0
        entryPrice := na

    // ENTER LONG
    if flat
        buySignal := true
        pos := 1
        entryPrice := close

// ======================================================
// 📌 SHORT BREAKOUT
// ======================================================
if inBT and close < pdLow

    // EXIT LONG
    if longPos

        buyExitSignal := true

        float tradePct = ((close - entryPrice) / entryPrice) * 100

        totalTrades += 1

        if tradePct > 0
            wins += 1
            totalWinPct += tradePct
        else
            losses += 1
            totalLossPct += math.abs(tradePct)

        pos := 0
        entryPrice := na

    // ENTER SHORT
    if flat
        sellSignal := true
        pos := -1
        entryPrice := close

// ======================================================
// 📌 RUNNING P/L
// ======================================================
float runningPL = na

if longPos and not na(entryPrice)
    runningPL := ((close - entryPrice) / entryPrice) * 100

if shortPos and not na(entryPrice)
    runningPL := ((entryPrice - close) / entryPrice) * 100

// ======================================================
// 📌 METRICS
// ======================================================
float winRate = totalTrades > 0 ? (wins / totalTrades) * 100 : na

float avgWin =
     wins > 0
     ? totalWinPct / wins
     : na

float avgLoss =
     losses > 0
     ? totalLossPct / losses
     : na

// ======================================================
// 📌 TABLE SETTINGS
// ======================================================
groupTable = "Table"

showTable = input.bool(true, "Show Table", group=groupTable)

tablePos = input.string(
     "Top Right",
     "Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=groupTable)

headerBg = input.color(color.black, "Header Background", group=groupTable)
bodyBg   = input.color(color.rgb(20,20,20), "Body Background", group=groupTable)

headerTxt = input.color(color.white, "Header Text Color", group=groupTable)
bodyTxt   = input.color(color.white, "Body Text Color", group=groupTable)

tablePosition =
     tablePos == "Top Right" ? position.top_right :
     tablePos == "Top Left" ? position.top_left :
     tablePos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

// ======================================================
// 📌 TABLE
// ======================================================
var table statsTable = table.new(tablePosition, 2, 6, border_width=1)

if barstate.islast

    table.clear(statsTable, 0, 0, 1, 5)

    if showTable

        table.cell(statsTable, 0, 0, "Metric", bgcolor=headerBg, text_color=headerTxt)
        table.cell(statsTable, 1, 0, "Value", bgcolor=headerBg, text_color=headerTxt)

        table.cell(statsTable, 0, 1, "Total Trades", bgcolor=bodyBg, text_color=bodyTxt)
        table.cell(statsTable, 1, 1, str.tostring(totalTrades), bgcolor=bodyBg, text_color=bodyTxt)

        table.cell(statsTable, 0, 2, "Wins / Losses", bgcolor=bodyBg, text_color=bodyTxt)
        table.cell(statsTable, 1, 2, str.tostring(wins) + " / " + str.tostring(losses), bgcolor=bodyBg, text_color=bodyTxt)

        table.cell(statsTable, 0, 3, "Win %", bgcolor=bodyBg, text_color=bodyTxt)
        table.cell(statsTable, 1, 3, na(winRate) ? "0%" : str.tostring(winRate, "#.##") + "%", bgcolor=bodyBg, text_color=bodyTxt)

        table.cell(statsTable, 0, 4, "Avg Win %", bgcolor=bodyBg, text_color=bodyTxt)
        table.cell(statsTable, 1, 4, na(avgWin) ? "0%" : str.tostring(avgWin, "#.##") + "%", bgcolor=bodyBg, text_color=bodyTxt)

        table.cell(statsTable, 0, 5, "Avg Loss %", bgcolor=bodyBg, text_color=bodyTxt)
        table.cell(statsTable, 1, 5, na(avgLoss) ? "0%" : str.tostring(avgLoss, "#.##") + "%", bgcolor=bodyBg, text_color=bodyTxt)

// ======================================================
// 📌 FLOATING P/L LABEL SETTINGS
// ======================================================
groupPL = "Floating P/L Label"

showPLLabel = input.bool(true, "Show Floating P/L Label", group=groupPL)

plBgColor   = input.color(color.black, "Background Color", group=groupPL)
plTextColor = input.color(color.white, "Text Color", group=groupPL)

plOffset = input.int(20, "Y Offset", minval=1, group=groupPL)

var label plLabel = na

if not na(plLabel)
    label.delete(plLabel)

if showPLLabel and not flat and not na(runningPL)

    string plText =
         (longPos ? "LONG " : "SHORT ") +
         str.tostring(runningPL, "#.##") + "%"

    plLabel := label.new(
         bar_index,
         high + (ta.atr(14) * plOffset / 100),
         text=plText,
         style=label.style_label_left,
         color=plBgColor,
         textcolor=plTextColor,
         size=size.normal)

// ======================================================
// 📌 LABELS
// ======================================================
plotshape(
     buySignal,
     title="BUY",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.small)

plotshape(
     sellSignal,
     title="SELL",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.small)

plotshape(
     buyExitSignal,
     title="BUY EXIT",
     text="BUY EXIT",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.orange,
     textcolor=color.white,
     size=size.tiny)

plotshape(
     sellExitSignal,
     title="SELL EXIT",
     text="SELL EXIT",
     style=shape.labelup,
     location=location.belowbar,
     color=color.orange,
     textcolor=color.white,
     size=size.tiny)

// ======================================================
// 📌 ALERTS
// ======================================================
alertcondition(buySignal, title="BUY Alert", message="BUY Signal")
alertcondition(sellSignal, title="SELL Alert", message="SELL Signal")
alertcondition(buyExitSignal, title="BUY EXIT Alert", message="BUY EXIT Signal")
alertcondition(sellExitSignal, title="SELL EXIT Alert", message="SELL EXIT Signal")

// ======================================================
// 📌 PD LINES
// ======================================================
plot(pdHigh, color=color.green, title="PD High", linewidth=2)
plot(pdLow, color=color.red, title="PD Low", linewidth=2)
````
