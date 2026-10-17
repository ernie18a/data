# RSI Probability Matrix [ChartPrime]

- url: https://www.tradingview.com/script/c25U5rsF-RSI-Probability-Matrix-ChartPrime/
- type: indicator
- pine_id: PUB;5dfdfad08cf348138e3977de614d8f3c
- version: 1.0

## Description

[b]RSI Probability Matrix [ChartPrime][/b]

[b]🔶 OVERVIEW[/b]

Traders frequently rely on rigid, fixed overbought and oversold thresholds for the Relative Strength Index, ignoring how historical price action actually responds at different momentum levels. The [b]RSI Probability Matrix [ChartPrime][/b] introduces a statistical learning engine to your charts. It tracks and measures real-time trade outcomes across 10-point RSI brackets, turning historical momentum reactions into actionable win-rate probabilities.

Instead of guessing whether an overbought or oversold signal holds weight, this indicator dynamically evaluates success and failure rates using an ATR-based target and stop-loss matrix.

[b]🔶 HOW IT WORKS[/b]

The indicator executes its statistical and tracking workflow through a multi-stage architecture:

[list]
[*] [b]Dynamic Momentum Engine:[/b] Calculates a standard RSI and smoothed signal line pair, backed by an Average True Range (ATR) volatility measurement to size structural targets and stops.
[*] [b]Real-Time Trade Tracking Array:[/b] Maintains live arrays spanning all 101 RSI index values (0 to 100), recording historical win and loss outcomes whenever buy or sell crossover triggers are hit.
[*] [b]ATR-Based Risk Framework:[/b] When an oversold buy or overbought sell signal triggers, the engine projects dynamic target and stop-loss levels based on a custom multiplier of the current ATR value.
[*] [b]Probability Matrix Dashboard:[/b] Aggregates the tracked data into 10-point bracket intervals, calculating real-time win percentages for both buy and sell directions across the entire chart history.
[/list]

[b]🔶 KEY FEATURES[/b]

[list]
[*] [b]Statistical Matrix Table:[/b] A clean, configurable dashboard displaying detailed trade counts and directional win probabilities broken down across structured RSI bands.
[*] [b]Automated Signal & Outcome Markers:[/b] Pins clear entry badges onto the chart along with success (✅) or failure (❌) markers when trades hit their target or stop parameters.
[*] [b]Gradient Color Customization:[/b] Fluidly shifts RSI line colors across customizable bullish and bearish palettes depending on prevailing momentum zones.
[*] [b]Flexible Target Management:[/b] Full control over ATR lookback periods, multiplier thresholds, and overbought/oversold trigger boundaries to fit your strategy.
[/list]

[b]🔶 TRADING APPLICATIONS[/b]

[list]
[*] [b]Probability-Weighted Entries:[/b] Before taking a trade at a specific RSI level, check the dashboard matrix to see the historical win percentage for that exact momentum bracket. Only take setups backed by favorable statistical odds.
[*] [b]Objective Risk-to-Reward Execution:[/b] Utilize the automated ATR target and stop lines to enforce disciplined trade management, allowing the probability engine to accurately record wins and losses.
[*] [b]Momentum Exhaustion Filtering:[/b] Combine overbought or oversold crossovers with the matrix summary totals to identify which RSI zones hold the strongest historical defense from institutional participants.
[/list]

[b]🔶 SETTINGS[/b]

[list]
[*] [b]Indicator Settings (RSI Length / Signal / OB-OS Levels):[/b] Controls the core lookback periods and the boundary thresholds required to trigger buy and sell signals.
[*] [b]Target & Stop Settings (ATR Length / Multiplier):[/b] Adjusts the volatility distance used to calculate structural profit targets and stop-loss zones.
[*] [b]Dashboard Settings (Visibility / Position / Size):[/b] Configures the placement and layout of the real-time statistical probability matrix table on your workspace.
[/list]

[b]🔶 CONCLUSION[/b]

The [b]RSI Probability Matrix [ChartPrime][/b] removes the guesswork from momentum trading. By dynamically tracking and grading historical trade success across customized RSI bands, it gives you a data-driven edge built entirely on real market feedback.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ChartPrime

//@version=6
indicator("RSI Probability Matrix [ChartPrime]", overlay = false, max_lines_count = 500, max_labels_count = 500)


// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{

groupSettings       = "Indicator Settings"
rsiPeriod           = input.int(14, "RSI Length", group=groupSettings, tooltip="The lookback period used to calculate the RSI.")
signalPeriod        = input.int(14, "Signal Length", group=groupSettings, tooltip="The smoothing period for the RSI's moving average signal line.")
oversoldThreshold   = input.int(40, "Oversold Level", group=groupSettings, tooltip="The RSI value below which the market is considered oversold (triggers buy signals on crossover).")
overboughtThreshold = input.int(60, "Overbought Level", group=groupSettings, tooltip="The RSI value above which the market is considered overbought (triggers sell signals on crossunder).")

groupTargets        = "Target & Stop Settings"
atrPeriod           = input.int(14, "ATR Length", group=groupTargets, tooltip="The lookback period for the Average True Range (volatility) calculation.")
atrMultiplier       = input.float(3.0, "ATR Multiplier", step=0.1, group=groupTargets, tooltip="Multiplier applied to the ATR to calculate dynamic target and stop loss distances.")

groupColors         = "Color Theme"
colorBullish        = input.color(#3be797, "Bullish / Win Color", group=groupColors, tooltip="Primary color for buy signals, oversold zones, and winning trades (Pale Mint).")
colorBearish        = input.color(color.rgb(230, 53, 136), "Bearish / Loss Color", group=groupColors, tooltip="Primary color for sell signals, overbought zones, and losing trades (Pale Coral).")
colorMidline        = input.color(color.yellow, "Midline Color", group=groupColors, tooltip="Color used for the neutral 50-level midline.")

groupDashboard      = "Dashboard Settings"
enableDashboard     = input.bool(true, "Show Dashboard", group=groupDashboard, tooltip="Toggle matrix dashboard visibility.")
tablePosition       = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=groupDashboard)
tableSize           = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal"], group=groupDashboard)


// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{

rsiValue    = ta.rsi(close, rsiPeriod)
signalValue = ta.sma(rsiValue, signalPeriod)
atrValue    = ta.atr(atrPeriod)

// Statistical Arrays (Index 0-100 represents exact RSI value)
var longWinsArray  = array.new_int(101, 0)
var longLossArray  = array.new_int(101, 0)
var shortWinsArray = array.new_int(101, 0)
var shortLossArray = array.new_int(101, 0)

// Trade Management State
var activeTradeState = 0     // 1 = Buy, -1 = Sell, 0 = Flat
var tradeEntryRsi    = 0     
var targetPriceLevel = 0.0
var stopPriceLevel   = 0.0
var tradeEntryPrice  = 0.0

// Visual Objects Handles
var line targetLineObj = na
var line stopLineObj   = na
var line entryLineObj  = na

// Active Trade Evaluation
if activeTradeState != 0
    line.set_x2(targetLineObj, bar_index)
    line.set_x2(stopLineObj, bar_index)
    line.set_x2(entryLineObj, bar_index)
    
    if activeTradeState == 1 // Active Buy
        if high >= targetPriceLevel
            array.set(longWinsArray, tradeEntryRsi, array.get(longWinsArray, tradeEntryRsi) + 1)
            label.new(bar_index, targetPriceLevel, "✅", style=label.style_none, size=size.normal, force_overlay=true)
            activeTradeState := 0 
            targetLineObj.set_style(line.style_dashed)
            stopLineObj.set_style(line.style_dashed)

        else if low <= stopPriceLevel
            array.set(longLossArray, tradeEntryRsi, array.get(longLossArray, tradeEntryRsi) + 1)
            label.new(bar_index, stopPriceLevel, "❌", style=label.style_none, size=size.normal, force_overlay=true)
            activeTradeState := 0 
            targetLineObj.set_style(line.style_dashed)
            stopLineObj.set_style(line.style_dashed)

    else if activeTradeState == -1 // Active Sell
        if low <= targetPriceLevel 
            array.set(shortWinsArray, tradeEntryRsi, array.get(shortWinsArray, tradeEntryRsi) + 1)
            label.new(bar_index, targetPriceLevel, "✅", style=label.style_none, size=size.normal, force_overlay=true)
            activeTradeState := 0
            targetLineObj.set_style(line.style_dashed)
            stopLineObj.set_style(line.style_dashed)

        else if high >= stopPriceLevel 
            array.set(shortLossArray, tradeEntryRsi, array.get(shortLossArray, tradeEntryRsi) + 1)
            label.new(bar_index, stopPriceLevel, "❌", style=label.style_none, size=size.normal, force_overlay=true)
            activeTradeState := 0
            targetLineObj.set_style(line.style_dashed)
            stopLineObj.set_style(line.style_dashed)

// Entry Conditions
longEntrySignal  = ta.crossover(rsiValue, signalValue) and rsiValue < oversoldThreshold and activeTradeState == 0
shortEntrySignal = ta.crossunder(rsiValue, signalValue) and rsiValue > overboughtThreshold and activeTradeState == 0

// Helper Functions for Dashboard
resolvePosition(string posStr) =>
    switch posStr
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

resolveSize(string sizeStr) =>
    switch sizeStr
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.small


// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{

// Gradient Color Logic
rsiGradientColor = color.from_gradient(rsiValue, oversoldThreshold, overboughtThreshold, colorBullish, colorBearish)

// Plot RSI in Separate Pane
hob = hline(overboughtThreshold, title="Overbought", color=color.new(colorBearish, 50), linestyle=hline.style_dashed)
hos = hline(oversoldThreshold, title="Oversold", color=color.new(colorBullish, 50), linestyle=hline.style_dashed)
hline(50, title="Midline", color=color.new(chart.fg_color, 50), linestyle=hline.style_dotted)

fill(hos, hob, color = color.new(chart.fg_color, 90))

plot(rsiValue, title="RSI", color=rsiGradientColor, linewidth=2)
plot(signalValue, title="Signal", color=color.new(colorMidline, 0), linewidth=1)


// Trigger Buy Signals
if longEntrySignal and not na(rsiValue) and not na(atrValue)
    activeTradeState := 1
    tradeEntryRsi    := math.round(rsiValue)
    tradeEntryPrice  := close
    targetPriceLevel := close + (atrValue * atrMultiplier)
    stopPriceLevel   := close - (atrValue * atrMultiplier)
    
    winsCount        = array.get(longWinsArray, tradeEntryRsi)
    lossesCount      = array.get(longLossArray, tradeEntryRsi)
    totalTradesCount = winsCount + lossesCount
    
    winPercentage    = totalTradesCount > 0 ? (winsCount / totalTradesCount) * 100 : 0.0
    lossPercentage   = totalTradesCount > 0 ? (lossesCount / totalTradesCount) * 100 : 0.0
    
    winDisplayStr    = totalTradesCount > 0 ? str.tostring(winPercentage, "#") + "% Win" : "Collecting Data..."
    lossDisplayStr   = totalTradesCount > 0 ? str.tostring(lossPercentage, "#") + "% Loss" : "Collecting Data..."
    
    label.new(bar_index, low - (atrValue * 0.5), "RSI Up\n[" + str.tostring(tradeEntryRsi) + "]", style=label.style_label_up, color=color.new(colorBullish, 85), textcolor=colorBullish, size=size.small, force_overlay=true)
    
    targetLineObj := line.new(bar_index, targetPriceLevel, bar_index, targetPriceLevel, color=color.new(colorBullish, 30), style=line.style_solid, width=1, force_overlay=true)
    stopLineObj   := line.new(bar_index, stopPriceLevel, bar_index, stopPriceLevel, color=color.new(colorBearish, 30), style=line.style_solid, width=1, force_overlay=true)
    entryLineObj  := line.new(bar_index, tradeEntryPrice, bar_index, tradeEntryPrice, color=color.new(chart.fg_color, 50), style=line.style_dotted, width=1, force_overlay=true)
    
    label.new(bar_index, targetPriceLevel, winDisplayStr, style=label.style_none, textcolor=colorBullish, size=size.small, force_overlay=true, tooltip = totalTradesCount == 0 ? "Collecting Data for RSI:" + str.tostring(tradeEntryRsi) : "Win Probability")
    label.new(bar_index, stopPriceLevel, lossDisplayStr, style=label.style_none, textcolor=colorBearish, size=size.small, force_overlay=true, tooltip = totalTradesCount == 0 ? "Collecting Data for RSI:" + str.tostring(tradeEntryRsi) : "Loss Probability")

// Trigger Sell Signals
if shortEntrySignal and not na(rsiValue) and not na(atrValue)
    activeTradeState := -1
    tradeEntryRsi    := math.round(rsiValue)
    tradeEntryPrice  := close
    targetPriceLevel := close - (atrValue * atrMultiplier) 
    stopPriceLevel   := close + (atrValue * atrMultiplier) 
    
    winsCount        = array.get(shortWinsArray, tradeEntryRsi)
    lossesCount      = array.get(shortLossArray, tradeEntryRsi)
    totalTradesCount = winsCount + lossesCount
    
    winPercentage    = totalTradesCount > 0 ? (winsCount / totalTradesCount) * 100 : 0.0
    lossPercentage   = totalTradesCount > 0 ? (lossesCount / totalTradesCount) * 100 : 0.0
    
    winDisplayStr    = totalTradesCount > 0 ? str.tostring(winPercentage, "#") + "% Win" : "Collecting Data..."
    lossDisplayStr   = totalTradesCount > 0 ? str.tostring(lossPercentage, "#") + "% Loss" : "Collecting Data..."
    
    label.new(bar_index, high + (atrValue * 0.5), "RSI Down\n[" + str.tostring(tradeEntryRsi) + "]", style=label.style_label_down, color=color.new(colorBearish, 85), textcolor=colorBearish, size=size.small, force_overlay=true)
    
    targetLineObj := line.new(bar_index, targetPriceLevel, bar_index, targetPriceLevel, color=color.new(colorBullish, 30), style=line.style_solid, width=1, force_overlay=true)
    stopLineObj   := line.new(bar_index, stopPriceLevel, bar_index, stopPriceLevel, color=color.new(colorBearish, 30), style=line.style_solid, width=1, force_overlay=true)
    entryLineObj  := line.new(bar_index, tradeEntryPrice, bar_index, tradeEntryPrice, color=color.new(chart.fg_color, 50), style=line.style_dotted, width=1, force_overlay=true)
    
    label.new(bar_index, targetPriceLevel, winDisplayStr, style=label.style_none, textcolor=colorBullish, size=size.small, force_overlay=true, tooltip = totalTradesCount == 0 ? "Collecting Data for RSI:" + str.tostring(tradeEntryRsi) : "Win Probability")
    label.new(bar_index, stopPriceLevel, lossDisplayStr, style=label.style_none, textcolor=colorBearish, size=size.small, force_overlay=true, tooltip = totalTradesCount == 0 ? "Collecting Data for RSI:" + str.tostring(tradeEntryRsi) : "Loss Probability")

// Probability Matrix Dashboard
if enableDashboard and barstate.islast
    var dashboardTable = table.new(position = resolvePosition(tablePosition), columns = 4, rows = 12, bgcolor = color.new(#131722, 15), border_width = 1, border_color = color.new(color.gray, 70), force_overlay = true)
    
    fontSize = resolveSize(tableSize)
    
    // Dashboard Header
    table.cell(dashboardTable, 0, 0, "RSI Band", bgcolor=color.new(chart.fg_color, 85), text_color=chart.fg_color, text_size=fontSize)
    table.cell(dashboardTable, 1, 0, "Trades", bgcolor=color.new(chart.fg_color, 85), text_color=chart.fg_color, text_size=fontSize)
    table.cell(dashboardTable, 2, 0, "Buy Win %", bgcolor=color.new(chart.fg_color, 85), text_color=colorBullish, text_size=fontSize)
    table.cell(dashboardTable, 3, 0, "Sell Win %", bgcolor=color.new(chart.fg_color, 85), text_color=colorBearish, text_size=fontSize)
    
    grandLongWins    = 0
    grandLongLosses  = 0
    grandShortWins   = 0
    grandShortLosses = 0
    
    // Render 10-point RSI brackets (0-9, 10-19, ..., 90-100)
    for bandIndex = 0 to 9
        bandMinRsi = bandIndex * 10
        bandMaxRsi = bandIndex == 9 ? 100 : (bandIndex * 10) + 9
        
        bandLongWins    = 0
        bandLongLosses  = 0
        bandShortWins   = 0
        bandShortLosses = 0
        
        for rsiIndex = bandMinRsi to bandMaxRsi
            bandLongWins    += array.get(longWinsArray, rsiIndex)
            bandLongLosses  += array.get(longLossArray, rsiIndex)
            bandShortWins   += array.get(shortWinsArray, rsiIndex)
            bandShortLosses += array.get(shortLossArray, rsiIndex)
            
        grandLongWins    += bandLongWins
        grandLongLosses  += bandLongLosses
        grandShortWins   += bandShortWins
        grandShortLosses += bandShortLosses
        
        bandTotalLongs  = bandLongWins + bandLongLosses
        bandTotalShorts = bandShortWins + bandShortLosses
        bandTotalTrades = bandTotalLongs + bandTotalShorts
        
        bandLongWinRate  = bandTotalLongs > 0 ? (bandLongWins / bandTotalLongs) * 100 : 0.0
        bandShortWinRate = bandTotalShorts > 0 ? (bandShortWins / bandTotalShorts) * 100 : 0.0
        
        bandLongStr  = bandTotalLongs > 0 ? str.tostring(bandLongWinRate, "#.#") + "%" : "-"
        bandShortStr = bandTotalShorts > 0 ? str.tostring(bandShortWinRate, "#.#") + "%" : "-"
        
        bandTitle  = str.tostring(bandMinRsi) + "-" + str.tostring(bandMaxRsi)
        currentRow = bandIndex + 1
        
        table.cell(dashboardTable, 0, currentRow, bandTitle, text_color=chart.fg_color, text_size=fontSize)
        table.cell(dashboardTable, 1, currentRow, str.tostring(bandTotalTrades), text_color=chart.fg_color, text_size=fontSize)
        table.cell(dashboardTable, 2, currentRow, bandLongStr, text_color=bandTotalLongs > 0 ? colorBullish : chart.fg_color, text_size=fontSize)
        table.cell(dashboardTable, 3, currentRow, bandShortStr, text_color=bandTotalShorts > 0 ? colorBearish : chart.fg_color, text_size=fontSize)
        
    // Dashboard Summary Row
    totalLongTrades  = grandLongWins + grandLongLosses
    totalShortTrades = grandShortWins + grandShortLosses
    totalAllTrades   = totalLongTrades + totalShortTrades
    
    totalLongWinRate  = totalLongTrades > 0 ? (grandLongWins / totalLongTrades) * 100 : 0.0
    totalShortWinRate = totalShortTrades > 0 ? (grandShortWins / totalShortTrades) * 100 : 0.0
    
    totalLongStr  = totalLongTrades > 0 ? str.tostring(totalLongWinRate, "#.#") + "%" : "-"
    totalShortStr = totalShortTrades > 0 ? str.tostring(totalShortWinRate, "#.#") + "%" : "-"
    
    table.cell(dashboardTable, 0, 11, "TOTAL", bgcolor=color.new(chart.fg_color, 90), text_color=chart.fg_color, text_size=fontSize)
    table.cell(dashboardTable, 1, 11, str.tostring(totalAllTrades), bgcolor=color.new(chart.fg_color, 90), text_color=chart.fg_color, text_size=fontSize)
    table.cell(dashboardTable, 2, 11, totalLongStr, bgcolor=color.new(chart.fg_color, 90), text_color=totalLongTrades > 0 ? colorBullish : chart.fg_color, text_size=fontSize)
    table.cell(dashboardTable, 3, 11, totalShortStr, bgcolor=color.new(chart.fg_color, 90), text_color=totalShortTrades > 0 ? colorBearish : chart.fg_color, text_size=fontSize)

// --------------------------------------------------------------------------------------------------------------------}
````
