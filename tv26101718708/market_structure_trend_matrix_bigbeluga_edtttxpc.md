# Market Structure Trend Matrix [BigBeluga]

- url: https://www.tradingview.com/script/EdtttXPC-Market-Structure-Trend-Matrix-BigBeluga/
- type: indicator
- pine_id: PUB;c62dfb56bb854a6bbc6dc4a5c9576b3e
- version: 2.0

## Description

[b]Market Structure Trend Matrix [BigBeluga][/b] is a comprehensive technical analysis framework engineered for traders who demand precision in identifying market regimes and trend expansions. By integrating automated [b]Market Structure (MS)[/b] detection with volatility-adjusted risk parameters, this indicator provides a systematic roadmap for navigating complex price action.

The tool focuses on the [b]Change of Character (ChoCh)[/b]—the critical moment when a previous trend structure breaks and a new directional bias begins. 

[b]🔵 ARCHITECTURE & CORE LOGIC[/b]
[list]
[*] [b]Automated Structure Mapping:[/b] The engine uses a sophisticated pivot-detection algorithm (MS Length) to scan for institutional-grade swing highs and lows. It ignores minor retail noise, drawing structural lines only when significant supply or demand zones are breached.
[*] [b]The ChoCh Engine:[/b] When price crosses a recent pivot high or low, the indicator prints a "ChoCh" label. This represents a fundamental shift in market sentiment, signaling that the current trend has likely terminated and a new cycle has begun.
[image]https://www.tradingview.com/x/1xq8DcAx/[/image]
[*] [b]Infinite Expansion Targets:[/b] One of the most advanced features of the Matrix is its ability to project sequential, infinite targets. These levels are not static; they are calculated using [b]Average True Range (ATR)[/b] multipliers, meaning they expand and contract based on current market volatility.
[image]https://www.tradingview.com/x/7z0cNUBl/[/image]
[*] [b]Volatility-Anchored Trailing Stop:[/b] To ensure professional-grade risk management, the indicator plots a dynamic [b]ATR Trailing Stop[/b]. This line acts as a "ratchet" mechanism—it moves closer to price during the trend expansion but stays firm during minor pullbacks, providing a clear exit point if the trend truly fails.
[image]https://www.tradingview.com/x/gXrCe0VU/[/image]
[/list]

[b]🔵 ADVANCED FEATURES & UPDATES[/b]
[list]
[*] [b]Target History Control:[/b] This latest version includes a [b]Show History[/b] toggle. You can choose to keep the chart clean by only displaying the [b]Active Target[/b], or you can enable history to see a visual record of every target hit during the trend, complete with historical percentage labels.
[*] [b]Dynamic Trailing Stop Visibility:[/b] The [b]Show Trailing Stop[/b] feature allows you to toggle the visibility of the ATR stop line and its associated background fill, giving you full control over the visual "weight" on your workspace.
[image]https://www.tradingview.com/x/UaW3yr9I/[/image]
[*] [b]Percentage Profit Labels:[/b] Every time price reaches an expansion target, the script automatically plots a label showing the percentage gain from the initial [b]ChoCh[/b] entry point.
[*] [b]Volatility-Adjusted Spacing:[/b] Both the trailing stop and the target steps use ATR-based calculations. This ensures that the indicator remains effective across all asset classes—from volatile Cryptocurrencies to stable Forex pairs.
[/list]

[b]🔵 HOW TO INTERPRET THE MATRIX[/b]
[list]
[*] [b]Bullish State (Green Matrix):[/b] Activated when price breaks above a major Pivot High. The indicator projects upward expansion targets and maintains a trailing stop below the price.
[image]https://www.tradingview.com/x/mm0pCdqU/[/image]
[*] [b]Bearish State (Pink Matrix):[/b] Activated when price breaks below a major Pivot Low. The indicator projects downward targets and maintains a trailing stop above the price.
[image]https://www.tradingview.com/x/63b0y6bK/[/image]
[*] [b]The Target Cascade:[/b] As price hits a target, the indicator instantly projects the [i]next[/i] level. If price continues to expand, you will see a "cascade" of dashed lines, each representing a deeper extension into the trend.
[image]https://www.tradingview.com/x/Q6kYr26h/[/image]
[/list]

[b]🔵 APPLICATION IN TRADING[/b]

[list]
[*] [b]Scalping & Day Trading:[/b] Set the Market Structure Length to a lower value (e.g., 5-8) to capture fast intraday pivots and expansion moves on 1m or 5m charts.
[*] [b]Swing Trading:[/b] Use a higher length (e.g., 15-20) to identify macro structure shifts on Daily or H4 timeframes, allowing the ATR targets to guide your long-term profit-taking.
[*] [b]Risk-Reward Management:[/b] The distance between the [b]ChoCh Entry[/b] and the [b]ATR Trailing Stop[/b] provides an objective risk measurement, while the sequential targets provide clear reward milestones.
[*] [b]Filtering False Breaks:[/b] By using an ATR Multiplier for the trailing stop, the Matrix avoids many of the common "whipsaws" found in standard trend-following systems.
[/list]

[b]🔵 CONCLUSION[/b]
[b]Market Structure Trend Matrix [BigBeluga][/b] is more than a signal tool; it is a visual framework for objective decision-making. By anchoring your trading to structural pivots and volatility-based targets, you remove the guesswork from trend following. Whether you are looking for a clean "ChoCh" entry or a systematic way to trail your profits during a massive expansion, the Trend Matrix provides the data and clarity required to trade like a professional.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Market Structure Trend Matrix [BigBeluga]", "MS Trend Matrix [BigBeluga]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

msLen          = input.int(10, "Market Structure Length", tooltip = "The lookback and lookahead period for detecting pivot highs and lows used for market structure.")
atrLength      = input.int(14, "ATR Length", tooltip = "The period used to calculate the Average True Range for the trailing stop and target spacing.")
atrMult        = input.float(4.0, "ATR Multiplier", tooltip = "Multiplied by ATR to determine the distance of the trailing stop from the price.")
targetStepMult = input.float(2.0, "Target Step (ATR Multiplier)", tooltip = "Determines the vertical distance between consecutive infinite targets based on ATR.")

bullColor      = input.color(color.rgb(52, 230, 126), "Bullish Color", tooltip = "Color used for bullish market structure, targets, and trailing stops.")
bearColor      = input.color(color.rgb(255, 82, 241), "Bearish Color", tooltip = "Color used for bearish market structure, targets, and trailing stops.")

showHistory    = input.bool(true, "Show Target History", tooltip = "When disabled, historical target lines and percentage labels will be hidden, leaving only the active target.")
showStop       = input.bool(true, "Show Trailing Stop", tooltip = "Toggle the visibility of the ATR Trailing Stop line and background fill.")

// }




// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

ph = ta.pivothigh(msLen, msLen)
pl = ta.pivotlow(msLen, msLen)

var float phVal = na 
var float plVal = na
var int phIndx = 0
var int plIndx = 0
var bool direction = false 

float atr = ta.atr(atrLength)
var float atrTS = na

var float entryPrice = na
var float currentTarget = na
var line targetLine = na
var int trendStart = 0

// Arrays to track lines and labels for current trend cleanup
var line[]  targetLines  = array.new_line()
var label[] targetLabels = array.new_label()

// Function to clear arrays (old trend targets)
clearCurrentTrendObjects() =>
    if array.size(targetLines) > 0
        for i = 0 to array.size(targetLines) - 1
            line.delete(array.get(targetLines, i))
        array.clear(targetLines)
    if array.size(targetLabels) > 0
        for i = 0 to array.size(targetLabels) - 1
            label.delete(array.get(targetLabels, i))
        array.clear(targetLabels)

if not na(ph)
    phVal := high[msLen]
    phIndx := bar_index[msLen]

if not na(pl)
    plVal := low[msLen]
    plIndx := bar_index[msLen]


if ta.crossover(close, phVal) and not direction
    direction := true 
    atrTS := close - (atr * atrMult)
    entryPrice := phVal
    currentTarget := entryPrice + (atr * targetStepMult)
    trendStart := bar_index

    line.new(phIndx, phVal, bar_index, phVal, color=bullColor, width = 2)
    label.new(int(math.avg(phIndx, bar_index)), phVal, "ChoCh ↑", style = label.style_label_down, color = na, textcolor = bullColor)
    
    line.delete(targetLine)
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color=color.new(bullColor, 0), width=1)


if ta.crossunder(close, plVal) and direction
    direction := false 
    atrTS := close + (atr * atrMult)
    entryPrice := plVal
    currentTarget := entryPrice - (atr * targetStepMult)
    trendStart := bar_index

    line.new(plIndx, plVal, bar_index, plVal, color=bearColor, width = 2)
    label.new(int(math.avg(plIndx, bar_index)), plVal, "ChoCh ↓", style = label.style_label_up, color = na, textcolor = bearColor)
    
    line.delete(targetLine)
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color=color.new(bearColor, 0), width=1)


directionChange = direction != direction[1]

if directionChange and not showHistory
    clearCurrentTrendObjects()


if direction
    atrTS := math.max(nz(atrTS, close - (atr * atrMult)), close - (atr * atrMult))
    
    if high >= currentTarget and not na(currentTarget)
        line.set_x2(targetLine, bar_index)
        line.set_style(targetLine, line.style_dashed)
        line.set_x1(targetLine, trendStart)

        array.push(targetLines, targetLine)
        perc = (currentTarget - entryPrice) / entryPrice * 100
        array.push(targetLabels, label.new(trendStart, currentTarget, str.format("+{0,number,#.##}%", perc), style=label.style_none, textcolor=bullColor, size=size.small))

        currentTarget := currentTarget + (atr * targetStepMult)
        targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color=color.new(bullColor, 40), width=1)
    else
        line.set_x2(targetLine, bar_index + 10)

else
    atrTS := math.min(nz(atrTS, close + (atr * atrMult)), close + (atr * atrMult))
    
    if low <= currentTarget and not na(currentTarget)
        line.set_x2(targetLine, bar_index)
        line.set_style(targetLine, line.style_dashed)
        line.set_x1(targetLine, trendStart)
        
        array.push(targetLines, targetLine)
        perc = (currentTarget - entryPrice) / entryPrice * 100
        array.push(targetLabels, label.new(trendStart, currentTarget, str.format("{0,number,#.##}%", perc), style=label.style_none, textcolor=bearColor, size=size.small))

        currentTarget := currentTarget - (atr * targetStepMult)
        targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color=color.new(bearColor, 40), width=1)
    else
        line.set_x2(targetLine, bar_index + 10)

// }




// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

plot(showStop and not directionChange ? atrTS : na, "ATR Trailing Stop", 
     color = direction ? bullColor : bearColor, 
     style = plot.style_linebr, 
     linewidth = 2)

plot_price = plot(close, display = display.none, editable = false)
plot_stop  = plot(showStop ? atrTS : na, display = display.none, editable = false)

fillCol = direction ? color.new(bullColor, 70) : color.new(bearColor, 70)

fill(plot_price, plot_stop, close, atrTS, na, showStop ? fillCol : na)

// }
````
