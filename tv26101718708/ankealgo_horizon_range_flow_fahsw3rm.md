# [AnkeAlgo] Horizon Range Flow

- url: https://www.tradingview.com/script/FAHSW3RM/
- type: indicator
- pine_id: PUB;af6df349fbaa48f79bd3b89d4ac151d3
- version: 1.0

## Description

This indicator is built around a structured workflow that combines reference-period highs and lows, volume confirmation, trend bands, and SuperTrend linkage. It is designed to help traders track key range breaks, confirm directional flips, and manage exits with more structure.

[image]https://www.tradingview.com/x/M44dWrl8/[/image]

[b]Core Concept[/b]

[list]
[*]The script records the high and low of the last completed reference period and uses them as key structural boundaries for the current phase.
[*]When price breaks below the previous period low or above the previous period high, the script checks whether the selected volume filter is satisfied.
[*]If SuperTrend linkage is enabled, the setup is armed first and the final signal is only confirmed after a SuperTrend flip.
[*]The indicator combines structure, confirmation, execution management, and performance stats in one workflow.
[/list]

[b]How Signals Are Triggered[/b]

[image]https://www.tradingview.com/x/XaG26SJR/[/image]

[list=1]
[*]The script first tracks the complete high-low range of the selected reference timeframe, with `3D` as the default setting.
[*]When a new reference period starts, the previous period high and low become the active structural levels.
[*]If price trades below the previous period low and the selected volume condition passes, a long setup is armed.
[*]If price trades above the previous period high and the selected volume condition passes, a short setup is armed.
[*]When `SuperTrend Linkage` is enabled, the script waits for a SuperTrend directional flip before printing the final `BUY` or `SELL` signal.
[*]When linkage is disabled, the breakout itself can trigger the final signal immediately after the filter conditions are met.
[/list]

[quote]This is not just a basic previous high/low breakout marker. It is a combined framework for structure recognition, volume confirmation, trend filtering, SuperTrend timing, and linked trade management. [/quote]

[b]Key Features[/b]

[list]
[*][b]Reference Period Range Detection[/b]: Defines structural boundaries from higher timeframe highs and lows.
[*][b]Volume Filter[/b]: Supports previous period average volume, recent N-bar average volume, and previous bar volume.
[*][b]Trend Band[/b]: Visualizes bullish, bearish, or neutral structure using completed period relationships.
[*][b]SuperTrend Linkage[/b]: Delays final signal confirmation until SuperTrend flips, reducing premature entries.
[*][b]Flexible Exit Modes[/b]: Supports `SuperTrend Exit`, `ATR Dynamic Exit`, and `ATR Scale-Out Exit`.
[*][b]Performance Panel[/b]: Tracks total trades, win rate, summed return, compounded equity, average trade, payoff, PF, max drawdown, streaks, open PnL, remaining size, and stop price.
[/list]

[b]Parameter Groups[/b]

[list]
[*][b]Period Settings[/b]: Defines the reference timeframe used to build the structural range.
[*][b]Display Settings[/b]: Controls separators, completed range levels, colors, and signal visibility.
[*][b]Filter Settings[/b]: Configures volume filter mode, multiplier, and moving average length.
[*][b]Trend Band[/b]: Controls trend band visibility and trend-based filtering.
[*][b]SuperTrend[/b]: Sets ATR length, factor, display, and linkage behavior.
[*][b]Linkage Trading[/b]: Controls exit mode, ATR target multiples, partial scale-out settings, remaining position handling, fees, and slippage assumptions.
[/list]

[b]Use Cases[/b]

[list]
[*]Traders who want to work with higher timeframe structural highs and lows instead of random intraperiod levels.
[*]Users who prefer combining breakout logic with volume confirmation.
[*]Trend-following or reversal traders who want a SuperTrend flip as a final directional confirmation.
[*]Authors who want signals, exit logic, and performance statistics visible on the same chart.
[/list]

[b]Linked Trade Management[/b]

When `SuperTrend Linkage` is enabled, the script stores entry price, stop level, and ATR-based targets after a confirmed signal, then manages the position according to the selected exit mode:

[list]
[*][b]SuperTrend Exit[/b]: Exits primarily on SuperTrend reversal.
[*][b]ATR Dynamic Exit[/b]: Uses a single ATR-based target for full exit.
[*][b]ATR Scale-Out Exit[/b]: Supports 1R, 2R, and 3R partial profit-taking, with the remainder either trailing on SuperTrend or exiting at 3R.
[/list]

[b]Why The Statistics Panel Matters[/b]

One of the strongest professional features in this script is the built-in statistics table. Instead of showing only entry labels and exit logic, the indicator also keeps a running record of how the linked execution model behaves over time.

[list]
[*][b]Total / Long / Short Breakdown[/b]: The panel separates overall performance from long-only and short-only performance, making it easier to identify directional bias.
[*][b]Win Rate and Avg Trade[/b]: These metrics help measure signal efficiency instead of relying on visual chart impressions alone.
[*][b]Summed Return vs Compounded Equity[/b]: The script shows both cumulative trade contribution and compounded equity growth, which gives a more realistic view of consistency.
[*][b]Profit Factor and Payoff Ratio[/b]: These are especially useful when evaluating whether the stop-and-target structure is mathematically healthy.
[*][b]Max Drawdown and Streaks[/b]: Drawdown and consecutive win/loss streak tracking help assess robustness, not just profitability.
[*][b]Open PnL, Remaining Qty, Next Target, and Stop[/b]: The panel is also operational, not just analytical, because it displays the current trade state in real time.
[/list]

[quote]For advanced users, this table turns the script from a visual signal tool into a compact execution-monitoring dashboard. It helps evaluate not only whether a setup triggers, but also how the trade model behaves statistically across time.[/quote]

[b]Code Walkthrough[/b]

To make the publication more transparent for advanced users, here is a quick breakdown of how the core logic is implemented in code.

[b]1. Reference Period State Management[/b]

[pine]
periodKeyTime = time(crossTf)
isNewPeriod = ta.change(periodKeyTime) != 0

if isNewPeriod
    referenceHigh := prevHigh
    referenceLow := prevLow
    referencePeriodAvgVolume := prevPeriodAvgVolume
[/pine]

This section is what keeps the indicator anchored to a higher-timeframe structure. Instead of reacting to every local swing, the script waits for a completed reference period and then carries its high, low, and average volume into the next phase as the active benchmark.

[b]2. Volume Filter Logic[/b]

[pine]
volumePass = switch volumeFilterMode
    "Previous Period Average Volume" => not useVolumeFilter or (not na(periodAvgVolumeBase) and periodAvgVolumeBase > 0 and volume >= periodAvgVolumeBase * volumeMultiplier)
    "Recent N-Bar Average Volume" => not useVolumeFilter or (not na(maVolumeBase) and maVolumeBase > 0 and volume >= maVolumeBase * volumeMultiplier)
    => not useVolumeFilter or (prevBarVolumeBase > 0 and volume >= prevBarVolumeBase * volumeMultiplier)
[/pine]

From a code-design perspective, this is an efficient way to expose multiple confirmation models without duplicating signal logic. The signal engine does not care which volume model is selected; it only reads a final boolean gate through `volumePass`.

[b]3. Armed Setup and SuperTrend Confirmation[/b]

[pine]
if not buyTriggered and buyBreakReady
    buySetupArmed := true

if buySetupArmed and superTrendBullFlip
    buySignal := true
    buyTriggered := true
    buySetupArmed := false
[/pine]

This is one of the more professional touches in the script. The breakout and the confirmation are separated into two stages: first the structure break is detected, then the final execution signal waits for a SuperTrend flip. That separation helps avoid turning every raw liquidity sweep into an immediate trade signal.

[b]4. Exit Engine and Trade Statistics[/b]

[pine]
if linkageTakeProfitMode == "ATR Scale-Out Exit"
    if not linkageTp1Done and high >= linkageTp1Price
        linkagePositionPct -= tp1ExitPct

if tradeClosed
    linkageClosedTrades += 1
    linkageNetPct += tradeReturnPct
    linkageEquity *= tradeEquityFactor
[/pine]

The script does more than plot entries and exits. It also maintains internal trade state, partial profit execution, equity compounding, and performance aggregation. That is why the stats panel can display values such as win rate, profit factor, max drawdown, average trade, and running open PnL directly from the indicator logic.

[quote]The professional value of this script is not only in its signal labels, but in the way it organizes structure detection, confirmation timing, trade management, and performance accounting into one coherent Pine workflow.[/quote]

[pine]
//@version=6
indicator("[AnkeAlgo] Horizon Range Flow", overlay=true, max_lines_count=500, max_labels_count=500)

formatDays(value) =>
    na(value) ? "-" : str.tostring(value, "#.0") + "d"

formatRatio(value) =>
    na(value) ? "-" : str.tostring(value, "#.##")
[/pine]

[b]Best Practice Notes[/b]

[list=1]
[*]Use the indicator on instruments with clear structural swings and adjust the reference timeframe to match market rhythm.
[*]Enable both volume filtering and SuperTrend linkage if you want stricter confirmation.
[*]Use `ATR Scale-Out Exit` when you want to manage partial profits instead of relying on one fixed target.
[*]This tool works best as part of a broader process that includes market structure, session context, and independent risk control.
[/list]

[b]Risk Notice[/b]

[quote]This indicator is a structure and execution-assistance tool, not financial advice. Results can vary significantly across markets, timeframes, and parameter settings, so always validate the logic before using it in live conditions.[/quote]

## Source Code

````pine
//@version=6
indicator("[AnkeAlgo] Horizon Range Flow", overlay=true, max_lines_count=500, max_labels_count=500)

formatPct(value) =>
    na(value) ? "-" : str.tostring(value, "#.##") + "%"

formatPrice(value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

formatDays(value) =>
    na(value) ? "-" : str.tostring(value, "#.0") + "d"

formatRatio(value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

calcGrossTradePct(tradeDir, entryPrice, exitPrice) =>
    tradeDir == 1 ? (exitPrice - entryPrice) / entryPrice * 100.0 : (entryPrice - exitPrice) / entryPrice * 100.0

calcNetContributionPct(tradeDir, entryPrice, exitPrice, sizeFraction, roundTripCostPct) =>
    sizeFraction * (calcGrossTradePct(tradeDir, entryPrice, exitPrice) - roundTripCostPct)

groupPeriod = "Period Settings"
groupStyle = "Display Settings"
groupFilter = "Filter Settings"
groupTrend = "Trend Band"
groupSuperTrend = "SuperTrend"
groupLinkage = "Linkage Trading"

crossTf = input.timeframe("3D", "Reference Period", group=groupPeriod)
showSeparators = input.bool(true, "Period Separators", inline="periodDisplay", group=groupStyle)
showFinalLevels = input.bool(false, "Completed High/Low Levels", inline="periodDisplay", group=groupStyle)

useVolumeFilter = input.bool(true, "Enable Volume Filter", group=groupFilter)
volumeFilterMode = input.string("Previous Period Average Volume", "Volume Filter Mode", options=["Previous Period Average Volume", "Recent N-Bar Average Volume", "Previous Bar Volume"], group=groupFilter)
volumeMultiplier = input.float(2.0, "Volume Multiplier", minval=1.0, step=0.1, inline="volumeBase", group=groupFilter)
volumeMaLength = input.int(20, "Volume MA Length", minval=1, inline="volumeBase", group=groupFilter)

showTrendBand = input.bool(true, "Show Trend Band", inline="trendSwitch", group=groupTrend)
useTrendFilter = input.bool(true, "Trend Filter", inline="trendSwitch", group=groupTrend)
trendFilterMode = input.string("Trend-Aligned Filter", "Trend Filter Mode", options=["Trend-Aligned Filter", "No Filter"], group=groupTrend)
upTrendBandColor = input.color(color.new(color.teal, 90), "Bullish Color", inline="trendColor", group=groupTrend)
downTrendBandColor = input.color(color.new(color.red, 90), "Bearish Color", inline="trendColor", group=groupTrend)

showSuperTrend = input.bool(true, "Show SuperTrend", inline="stSwitch", group=groupSuperTrend)
useSuperTrendLinkage = input.bool(true, "SuperTrend Linkage", inline="stSwitch", group=groupSuperTrend)
superTrendAtrLength = input.int(10, "ATR Length", minval=1, inline="stParam", group=groupSuperTrend)
superTrendFactor = input.float(3.0, "Factor", minval=0.1, step=0.1, inline="stParam", group=groupSuperTrend)
superTrendUpColor = input.color(color.new(color.green, 0), "Bullish Color", inline="stColor", group=groupSuperTrend)
superTrendDownColor = input.color(color.new(color.red, 0), "Bearish Color", inline="stColor", group=groupSuperTrend)

linkageTakeProfitMode = input.string("SuperTrend Exit", "Take Profit Mode", options=["SuperTrend Exit", "ATR Dynamic Exit", "ATR Scale-Out Exit"], group=groupLinkage)
linkageTakeProfitAtrLength = input.int(14, "TP ATR Length", minval=1, inline="tpSingle", group=groupLinkage)
linkageTakeProfitAtrMultiplier = input.float(2.0, "Single ATR Multiple", minval=0.1, step=0.1, inline="tpSingle", group=groupLinkage)
linkageTp1Multiplier = input.float(1.0, "1R", minval=0.1, step=0.1, inline="tpStep", group=groupLinkage)
linkageTp2Multiplier = input.float(2.0, "2R", minval=0.1, step=0.1, inline="tpStep", group=groupLinkage)
linkageTp3Multiplier = input.float(3.0, "3R", minval=0.1, step=0.1, inline="tpStep", group=groupLinkage)
linkageTp1QtyPct = input.float(50.0, "1R Qty %", minval=0.0, maxval=100.0, step=5.0, inline="tpQty", group=groupLinkage)
linkageTp2QtyPct = input.float(25.0, "2R Qty %", minval=0.0, maxval=100.0, step=5.0, inline="tpQty", group=groupLinkage)
linkageRemainderExitMode = input.string("SuperTrend Trail", "Remainder Exit", options=["SuperTrend Trail", "Take Profit at 3R"], group=groupLinkage)
linkageFeePct = input.float(0.04, "Fee %", minval=0.0, step=0.01, inline="cost", group=groupLinkage)
linkageSlippagePct = input.float(0.02, "Slippage %", minval=0.0, step=0.01, inline="cost", group=groupLinkage)

highColor = input.color(color.new(color.red, 0), "High Level Color", inline="levelColor", group=groupStyle)
lowColor = input.color(color.new(color.lime, 0), "Low Level Color", inline="levelColor", group=groupStyle)
separatorColor = input.color(color.new(color.gray, 45), "Separator Color", group=groupStyle)
buyColor = input.color(color.new(color.green, 0), "Buy Signal Color", inline="signalColor", group=groupStyle)
sellColor = input.color(color.new(color.orange, 0), "Sell Signal Color", inline="signalColor", group=groupStyle)

periodKeyTime = time(crossTf)
isNewPeriod = ta.change(periodKeyTime) != 0

var float periodHigh = na
var float periodLow = na
var int periodStartBar = na

var float referenceHigh = na
var float referenceLow = na
var float periodVolumeSum = na
var int periodVolumeBars = na
var float referencePeriodAvgVolume = na
var float lastCompletedHigh = na
var float lastCompletedLow = na
var int trendDirection = 0
var float trendBandHigh = na
var float trendBandLow = na
var bool buyTriggered = false
var bool sellTriggered = false
var bool buySetupArmed = false
var bool sellSetupArmed = false
var int linkageTradeDir = 0
var float linkageEntryPrice = na
var float linkageStopPrice = na
var float linkageTakeProfitPrice = na
var float linkageTp1Price = na
var float linkageTp2Price = na
var float linkageTp3Price = na
var bool linkageTp1Done = false
var bool linkageTp2Done = false
var bool linkageTp3Done = false
var float linkagePositionPct = 0.0
var float linkageRealizedPct = 0.0
var int linkageFirstTradeTime = na
var int linkageClosedTrades = 0
var int linkageWinTrades = 0
var int linkageLossTrades = 0
var float linkageNetPct = 0.0
var float linkageEquity = 1.0
var float linkagePeakEquity = 1.0
var float linkageMaxDrawdownPct = 0.0
var float linkageGrossProfitPct = 0.0
var float linkageGrossLossPct = 0.0
var int linkageCurrentWinStreak = 0
var int linkageCurrentLossStreak = 0
var int linkageMaxWinStreak = 0
var int linkageMaxLossStreak = 0
var int linkageLongTrades = 0
var int linkageLongWins = 0
var float linkageLongNetPct = 0.0
var float linkageLongEquity = 1.0
var int linkageShortTrades = 0
var int linkageShortWins = 0
var float linkageShortNetPct = 0.0
var float linkageShortEquity = 1.0
var table linkageStatsTable = table.new(position.bottom_right, 6, 8, bgcolor=color.new(color.rgb(10, 14, 22), 10), frame_color=color.new(color.rgb(70, 88, 120), 35), frame_width=1, border_color=color.new(color.rgb(50, 62, 86), 55), border_width=1)

buySignal = false
sellSignal = false
prevVolume = nz(volume[1])
volumeMa = ta.sma(volume, volumeMaLength)
linkageAtr = ta.atr(linkageTakeProfitAtrLength)
roundTripCostPct = (linkageFeePct + linkageSlippagePct) * 2.0
periodAvgVolumeBase = referencePeriodAvgVolume
maVolumeBase = volumeMa
prevBarVolumeBase = prevVolume

volumePass = switch volumeFilterMode
    "Previous Period Average Volume" => not useVolumeFilter or (not na(periodAvgVolumeBase) and periodAvgVolumeBase > 0 and volume >= periodAvgVolumeBase * volumeMultiplier)
    "Recent N-Bar Average Volume" => not useVolumeFilter or (not na(maVolumeBase) and maVolumeBase > 0 and volume >= maVolumeBase * volumeMultiplier)
    => not useVolumeFilter or (prevBarVolumeBase > 0 and volume >= prevBarVolumeBase * volumeMultiplier)

buyTrendPass = not useTrendFilter or trendFilterMode == "No Filter" or trendDirection == -1
sellTrendPass = not useTrendFilter or trendFilterMode == "No Filter" or trendDirection == 1
[superTrendValue, superTrendDirection] = ta.supertrend(superTrendFactor, superTrendAtrLength)
superTrendUp = superTrendDirection < 0 ? superTrendValue : na
superTrendDown = superTrendDirection > 0 ? superTrendValue : na
superTrendBullFlip = superTrendDirection < 0 and superTrendDirection[1] > 0
superTrendBearFlip = superTrendDirection > 0 and superTrendDirection[1] < 0
buyBreakReady = not na(referenceLow) and low < referenceLow and volumePass and buyTrendPass
sellBreakReady = not na(referenceHigh) and high > referenceHigh and volumePass and sellTrendPass

if barstate.isfirst
    periodHigh := high
    periodLow := low
    periodStartBar := bar_index
    periodVolumeSum := volume
    periodVolumeBars := 1
else
    if isNewPeriod
        prevHigh = periodHigh
        prevLow = periodLow
        prevStartBar = periodStartBar
        prevEndBar = bar_index - 1
        prevPeriodAvgVolume = periodVolumeBars > 0 ? periodVolumeSum / periodVolumeBars : na
        isUpTrend = not na(lastCompletedHigh) and not na(lastCompletedLow) and prevHigh > lastCompletedHigh and prevLow > lastCompletedLow
        isDownTrend = not na(lastCompletedHigh) and not na(lastCompletedLow) and prevHigh < lastCompletedHigh and prevLow < lastCompletedLow

        if showFinalLevels and prevEndBar >= prevStartBar
            line.new(prevStartBar, prevHigh, prevEndBar, prevHigh, xloc=xloc.bar_index, extend=extend.none, color=color.new(highColor, 55), width=2)
            line.new(prevStartBar, prevLow, prevEndBar, prevLow, xloc=xloc.bar_index, extend=extend.none, color=color.new(lowColor, 55), width=2)

        if showSeparators
            line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=separatorColor, style=line.style_dashed, width=1)

        periodHigh := high
        periodLow := low
        periodStartBar := bar_index
        referenceHigh := prevHigh
        referenceLow := prevLow
        referencePeriodAvgVolume := prevPeriodAvgVolume
        lastCompletedHigh := prevHigh
        lastCompletedLow := prevLow
        trendDirection := isUpTrend ? 1 : isDownTrend ? -1 : 0
        trendBandHigh := trendDirection != 0 ? prevHigh : na
        trendBandLow := trendDirection != 0 ? prevLow : na
        buyTriggered := false
        sellTriggered := false
        buySetupArmed := false
        sellSetupArmed := false
        periodVolumeSum := volume
        periodVolumeBars := 1
    else
        if na(periodHigh) or high > periodHigh
            periodHigh := high

        if na(periodLow) or low < periodLow
            periodLow := low

        periodVolumeSum += volume
        periodVolumeBars += 1

if useSuperTrendLinkage
    if not buyTriggered and buyBreakReady
        buySetupArmed := true

    if not sellTriggered and sellBreakReady
        sellSetupArmed := true

    if buySetupArmed and superTrendBullFlip
        buySignal := true
        buyTriggered := true
        buySetupArmed := false

    if sellSetupArmed and superTrendBearFlip
        sellSignal := true
        sellTriggered := true
        sellSetupArmed := false
else
    if not buyTriggered and buyBreakReady
        buySignal := true
        buyTriggered := true

    if not sellTriggered and sellBreakReady
        sellSignal := true
        sellTriggered := true

if useSuperTrendLinkage and linkageTradeDir == 1 and not na(superTrendUp)
    linkageStopPrice := na(linkageStopPrice) ? superTrendUp : math.max(linkageStopPrice, superTrendUp)

if useSuperTrendLinkage and linkageTradeDir == -1 and not na(superTrendDown)
    linkageStopPrice := na(linkageStopPrice) ? superTrendDown : math.min(linkageStopPrice, superTrendDown)

if useSuperTrendLinkage and linkageTradeDir != 0
    bool tradeClosed = false
    float tradeReturnPct = na

    if linkageTradeDir == 1
        longStopHit = not na(linkageStopPrice) and low <= linkageStopPrice
        longSingleTpHit = linkageTakeProfitMode == "ATR Dynamic Exit" and not na(linkageTakeProfitPrice) and high >= linkageTakeProfitPrice
        longSuperTrendExit = (linkageTakeProfitMode == "SuperTrend Exit" or (linkageTakeProfitMode == "ATR Scale-Out Exit" and linkageRemainderExitMode == "SuperTrend Trail")) and superTrendBearFlip

        if longStopHit
            linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageStopPrice, linkagePositionPct, roundTripCostPct)
            linkagePositionPct := 0.0
        else
            if linkageTakeProfitMode == "ATR Scale-Out Exit"
                if not linkageTp1Done and linkageTp1QtyPct > 0 and not na(linkageTp1Price) and high >= linkageTp1Price and linkagePositionPct > 0
                    tp1ExitPct = math.min(linkagePositionPct, linkageTp1QtyPct / 100.0)
                    linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageTp1Price, tp1ExitPct, roundTripCostPct)
                    linkagePositionPct -= tp1ExitPct
                    linkageTp1Done := true

                if not linkageTp2Done and linkageTp2QtyPct > 0 and not na(linkageTp2Price) and high >= linkageTp2Price and linkagePositionPct > 0
                    tp2ExitPct = math.min(linkagePositionPct, linkageTp2QtyPct / 100.0)
                    linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageTp2Price, tp2ExitPct, roundTripCostPct)
                    linkagePositionPct -= tp2ExitPct
                    linkageTp2Done := true

                if linkageRemainderExitMode == "Take Profit at 3R" and not linkageTp3Done and not na(linkageTp3Price) and high >= linkageTp3Price and linkagePositionPct > 0
                    linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageTp3Price, linkagePositionPct, roundTripCostPct)
                    linkagePositionPct := 0.0
                    linkageTp3Done := true
            else if longSingleTpHit and linkagePositionPct > 0
                linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageTakeProfitPrice, linkagePositionPct, roundTripCostPct)
                linkagePositionPct := 0.0

            if longSuperTrendExit and linkagePositionPct > 0
                linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, close, linkagePositionPct, roundTripCostPct)
                linkagePositionPct := 0.0
    else
        shortStopHit = not na(linkageStopPrice) and high >= linkageStopPrice
        shortSingleTpHit = linkageTakeProfitMode == "ATR Dynamic Exit" and not na(linkageTakeProfitPrice) and low <= linkageTakeProfitPrice
        shortSuperTrendExit = (linkageTakeProfitMode == "SuperTrend Exit" or (linkageTakeProfitMode == "ATR Scale-Out Exit" and linkageRemainderExitMode == "SuperTrend Trail")) and superTrendBullFlip

        if shortStopHit
            linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageStopPrice, linkagePositionPct, roundTripCostPct)
            linkagePositionPct := 0.0
        else
            if linkageTakeProfitMode == "ATR Scale-Out Exit"
                if not linkageTp1Done and linkageTp1QtyPct > 0 and not na(linkageTp1Price) and low <= linkageTp1Price and linkagePositionPct > 0
                    tp1ExitPct = math.min(linkagePositionPct, linkageTp1QtyPct / 100.0)
                    linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageTp1Price, tp1ExitPct, roundTripCostPct)
                    linkagePositionPct -= tp1ExitPct
                    linkageTp1Done := true

                if not linkageTp2Done and linkageTp2QtyPct > 0 and not na(linkageTp2Price) and low <= linkageTp2Price and linkagePositionPct > 0
                    tp2ExitPct = math.min(linkagePositionPct, linkageTp2QtyPct / 100.0)
                    linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageTp2Price, tp2ExitPct, roundTripCostPct)
                    linkagePositionPct -= tp2ExitPct
                    linkageTp2Done := true

                if linkageRemainderExitMode == "Take Profit at 3R" and not linkageTp3Done and not na(linkageTp3Price) and low <= linkageTp3Price and linkagePositionPct > 0
                    linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageTp3Price, linkagePositionPct, roundTripCostPct)
                    linkagePositionPct := 0.0
                    linkageTp3Done := true
            else if shortSingleTpHit and linkagePositionPct > 0
                linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, linkageTakeProfitPrice, linkagePositionPct, roundTripCostPct)
                linkagePositionPct := 0.0

            if shortSuperTrendExit and linkagePositionPct > 0
                linkageRealizedPct += calcNetContributionPct(linkageTradeDir, linkageEntryPrice, close, linkagePositionPct, roundTripCostPct)
                linkagePositionPct := 0.0

    if linkagePositionPct <= 0
        tradeClosed := true
        tradeReturnPct := linkageRealizedPct

    if tradeClosed
        tradeEquityFactor = math.max(0.0, 1.0 + tradeReturnPct / 100.0)
        linkageClosedTrades += 1
        linkageNetPct += tradeReturnPct
        linkageEquity *= tradeEquityFactor
        linkagePeakEquity := math.max(linkagePeakEquity, linkageEquity)
        currentDrawdownPct = linkagePeakEquity > 0 ? (linkagePeakEquity - linkageEquity) / linkagePeakEquity * 100.0 : 0.0
        linkageMaxDrawdownPct := math.max(linkageMaxDrawdownPct, currentDrawdownPct)

        if tradeReturnPct > 0
            linkageWinTrades += 1
            linkageGrossProfitPct += tradeReturnPct
            linkageCurrentWinStreak += 1
            linkageCurrentLossStreak := 0
            linkageMaxWinStreak := math.max(linkageMaxWinStreak, linkageCurrentWinStreak)
        else if tradeReturnPct < 0
            linkageLossTrades += 1
            linkageGrossLossPct += math.abs(tradeReturnPct)
            linkageCurrentLossStreak += 1
            linkageCurrentWinStreak := 0
            linkageMaxLossStreak := math.max(linkageMaxLossStreak, linkageCurrentLossStreak)
        else
            linkageCurrentWinStreak := 0
            linkageCurrentLossStreak := 0

        if linkageTradeDir == 1
            linkageLongTrades += 1
            linkageLongNetPct += tradeReturnPct
            linkageLongEquity *= tradeEquityFactor
            if tradeReturnPct > 0
                linkageLongWins += 1
        else
            linkageShortTrades += 1
            linkageShortNetPct += tradeReturnPct
            linkageShortEquity *= tradeEquityFactor
            if tradeReturnPct > 0
                linkageShortWins += 1

        linkageTradeDir := 0
        linkageEntryPrice := na
        linkageStopPrice := na
        linkageTakeProfitPrice := na
        linkageTp1Price := na
        linkageTp2Price := na
        linkageTp3Price := na
        linkageTp1Done := false
        linkageTp2Done := false
        linkageTp3Done := false
        linkagePositionPct := 0.0
        linkageRealizedPct := 0.0

if useSuperTrendLinkage and linkageTradeDir == 0
    if buySignal
        linkageTradeDir := 1
        linkageEntryPrice := close
        linkageStopPrice := superTrendUp
        linkageTakeProfitPrice := close + linkageAtr * linkageTakeProfitAtrMultiplier
        linkageTp1Price := close + linkageAtr * linkageTp1Multiplier
        linkageTp2Price := close + linkageAtr * linkageTp2Multiplier
        linkageTp3Price := close + linkageAtr * linkageTp3Multiplier
        linkageTp1Done := false
        linkageTp2Done := false
        linkageTp3Done := false
        linkagePositionPct := 1.0
        linkageRealizedPct := 0.0
        linkageFirstTradeTime := na(linkageFirstTradeTime) ? time : linkageFirstTradeTime
    else if sellSignal
        linkageTradeDir := -1
        linkageEntryPrice := close
        linkageStopPrice := superTrendDown
        linkageTakeProfitPrice := close - linkageAtr * linkageTakeProfitAtrMultiplier
        linkageTp1Price := close - linkageAtr * linkageTp1Multiplier
        linkageTp2Price := close - linkageAtr * linkageTp2Multiplier
        linkageTp3Price := close - linkageAtr * linkageTp3Multiplier
        linkageTp1Done := false
        linkageTp2Done := false
        linkageTp3Done := false
        linkagePositionPct := 1.0
        linkageRealizedPct := 0.0
        linkageFirstTradeTime := na(linkageFirstTradeTime) ? time : linkageFirstTradeTime

upTrendHighPlot = plot(showTrendBand and trendDirection == 1 ? trendBandHigh : na, "Bullish Trend Band High", color=color.new(color.teal, 100), linewidth=1, style=plot.style_linebr)
upTrendLowPlot = plot(showTrendBand and trendDirection == 1 ? trendBandLow : na, "Bullish Trend Band Low", color=color.new(color.teal, 100), linewidth=1, style=plot.style_linebr)
downTrendHighPlot = plot(showTrendBand and trendDirection == -1 ? trendBandHigh : na, "Bearish Trend Band High", color=color.new(color.red, 100), linewidth=1, style=plot.style_linebr)
downTrendLowPlot = plot(showTrendBand and trendDirection == -1 ? trendBandLow : na, "Bearish Trend Band Low", color=color.new(color.red, 100), linewidth=1, style=plot.style_linebr)
fill(upTrendHighPlot, upTrendLowPlot, color=upTrendBandColor, title="Bullish Trend Band")
fill(downTrendHighPlot, downTrendLowPlot, color=downTrendBandColor, title="Bearish Trend Band")

plot(showSuperTrend ? superTrendUp : na, "Current SuperTrend Bullish", color=superTrendUpColor, linewidth=2, style=plot.style_linebr)
plot(showSuperTrend ? superTrendDown : na, "Current SuperTrend Bearish", color=superTrendDownColor, linewidth=2, style=plot.style_linebr)

plotshape(buySignal, title="Buy Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=buyColor, textcolor=color.white, size=size.tiny)
plotshape(sellSignal, title="Sell Signal", text="SELL", style=shape.labeldown, location=location.abovebar, color=sellColor, textcolor=color.white, size=size.tiny)

alertcondition(buySignal, title="Buy Signal", message="Price broke below the previous period low, passed the selected volume filter, and produced a buy signal.")
alertcondition(sellSignal, title="Sell Signal", message="Price broke above the previous period high, passed the selected volume filter, and produced a sell signal.")
alertcondition(showSuperTrend and superTrendBullFlip, title="SuperTrend Bullish Flip", message="The current SuperTrend flipped from bearish to bullish.")
alertcondition(showSuperTrend and superTrendBearFlip, title="SuperTrend Bearish Flip", message="The current SuperTrend flipped from bullish to bearish.")

if barstate.islast
    if useSuperTrendLinkage
        totalWinRate = linkageClosedTrades > 0 ? linkageWinTrades * 100.0 / linkageClosedTrades : na
        longWinRate = linkageLongTrades > 0 ? linkageLongWins * 100.0 / linkageLongTrades : na
        shortWinRate = linkageShortTrades > 0 ? linkageShortWins * 100.0 / linkageShortTrades : na
        totalCompoundedPct = linkageClosedTrades > 0 ? (linkageEquity - 1.0) * 100.0 : na
        longCompoundedPct = linkageLongTrades > 0 ? (linkageLongEquity - 1.0) * 100.0 : na
        shortCompoundedPct = linkageShortTrades > 0 ? (linkageShortEquity - 1.0) * 100.0 : na
        activePnlPct = linkageTradeDir != 0 and linkagePositionPct > 0 ? linkageRealizedPct + calcNetContributionPct(linkageTradeDir, linkageEntryPrice, close, linkagePositionPct, roundTripCostPct) : na
        activeSide = linkageTradeDir == 1 ? "Long" : linkageTradeDir == -1 ? "Short" : "Flat"
        takeProfitLabel = linkageTakeProfitMode == "SuperTrend Exit" ? "ST Exit" : linkageTakeProfitMode == "ATR Dynamic Exit" ? "ATR Single" : "ATR Scale"
        avgTradePct = linkageClosedTrades > 0 ? linkageNetPct / linkageClosedTrades : na
        longAvgTradePct = linkageLongTrades > 0 ? linkageLongNetPct / linkageLongTrades : na
        shortAvgTradePct = linkageShortTrades > 0 ? linkageShortNetPct / linkageShortTrades : na
        profitFactor = linkageGrossLossPct > 0 ? linkageGrossProfitPct / linkageGrossLossPct : na
        avgWinPct = linkageWinTrades > 0 ? linkageGrossProfitPct / linkageWinTrades : na
        avgLossPct = linkageLossTrades > 0 ? linkageGrossLossPct / linkageLossTrades : na
        payoffRatio = not na(avgWinPct) and not na(avgLossPct) and avgLossPct > 0 ? avgWinPct / avgLossPct : na
        nextTargetPrice = linkageTradeDir != 0 ? linkageTakeProfitMode == "ATR Dynamic Exit" ? linkageTakeProfitPrice : linkageTakeProfitMode == "ATR Scale-Out Exit" and not linkageTp1Done and linkageTp1QtyPct > 0 ? linkageTp1Price : linkageTakeProfitMode == "ATR Scale-Out Exit" and not linkageTp2Done and linkageTp2QtyPct > 0 ? linkageTp2Price : linkageTakeProfitMode == "ATR Scale-Out Exit" and linkageRemainderExitMode == "Take Profit at 3R" and not linkageTp3Done ? linkageTp3Price : na : na
        remainingPctText = linkageTradeDir != 0 ? str.tostring(linkagePositionPct * 100.0, "#.##") + "%" : "-"
        runningDays = not na(linkageFirstTradeTime) ? (time - linkageFirstTradeTime) / 86400000.0 : na
        titleBg = color.new(color.rgb(24, 34, 54), 0)
        headerBg = color.new(color.rgb(36, 48, 74), 10)
        bodyBg1 = color.new(color.rgb(17, 22, 34), 10)
        bodyBg2 = color.new(color.rgb(13, 18, 28), 10)
        footerBg = color.new(color.rgb(26, 32, 46), 0)
        mutedText = color.rgb(184, 196, 214)
        titleText = color.white
        pnlTotalColor = linkageNetPct >= 0 ? color.rgb(96, 211, 146) : color.rgb(255, 107, 107)
        pnlLongColor = linkageLongNetPct >= 0 ? color.rgb(96, 211, 146) : color.rgb(255, 107, 107)
        pnlShortColor = linkageShortNetPct >= 0 ? color.rgb(96, 211, 146) : color.rgb(255, 107, 107)
        compTotalColor = na(totalCompoundedPct) ? color.white : totalCompoundedPct >= 0 ? color.rgb(96, 211, 146) : color.rgb(255, 107, 107)
        compLongColor = na(longCompoundedPct) ? color.white : longCompoundedPct >= 0 ? color.rgb(96, 211, 146) : color.rgb(255, 107, 107)
        compShortColor = na(shortCompoundedPct) ? color.white : shortCompoundedPct >= 0 ? color.rgb(96, 211, 146) : color.rgb(255, 107, 107)
        activePnlColor = na(activePnlPct) ? color.white : activePnlPct >= 0 ? color.rgb(96, 211, 146) : color.rgb(255, 107, 107)
        activeSideColor = linkageTradeDir == 1 ? color.rgb(96, 211, 146) : linkageTradeDir == -1 ? color.rgb(255, 161, 79) : mutedText

        table.cell(linkageStatsTable, 0, 0, "SuperTrend Linkage", text_color=titleText, bgcolor=titleBg, text_size=size.small)
        table.cell(linkageStatsTable, 1, 0, activeSide, text_color=activeSideColor, bgcolor=titleBg, text_size=size.small)
        table.cell(linkageStatsTable, 2, 0, "Days Running", text_color=mutedText, bgcolor=titleBg, text_size=size.small)
        table.cell(linkageStatsTable, 3, 0, formatDays(runningDays), text_color=titleText, bgcolor=titleBg, text_size=size.small)
        table.cell(linkageStatsTable, 4, 0, "One-Way Cost", text_color=mutedText, bgcolor=titleBg, text_size=size.small)
        table.cell(linkageStatsTable, 5, 0, formatPct(linkageFeePct + linkageSlippagePct), text_color=titleText, bgcolor=titleBg, text_size=size.small)

        table.cell(linkageStatsTable, 0, 1, "Category", text_color=mutedText, bgcolor=headerBg)
        table.cell(linkageStatsTable, 1, 1, "Trades", text_color=mutedText, bgcolor=headerBg)
        table.cell(linkageStatsTable, 2, 1, "Win Rate", text_color=mutedText, bgcolor=headerBg)
        table.cell(linkageStatsTable, 3, 1, "Sum Trades", text_color=mutedText, bgcolor=headerBg)
        table.cell(linkageStatsTable, 4, 1, "Comp Equity", text_color=mutedText, bgcolor=headerBg)
        table.cell(linkageStatsTable, 5, 1, "Avg Trade", text_color=mutedText, bgcolor=headerBg)

        table.cell(linkageStatsTable, 0, 2, "Total", text_color=titleText, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 1, 2, str.tostring(linkageClosedTrades), text_color=titleText, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 2, 2, formatPct(totalWinRate), text_color=titleText, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 3, 2, formatPct(linkageNetPct), text_color=pnlTotalColor, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 4, 2, formatPct(totalCompoundedPct), text_color=compTotalColor, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 5, 2, formatPct(avgTradePct), text_color=titleText, bgcolor=bodyBg1)

        table.cell(linkageStatsTable, 0, 3, "Long", text_color=titleText, bgcolor=bodyBg2)
        table.cell(linkageStatsTable, 1, 3, str.tostring(linkageLongTrades), text_color=titleText, bgcolor=bodyBg2)
        table.cell(linkageStatsTable, 2, 3, formatPct(longWinRate), text_color=titleText, bgcolor=bodyBg2)
        table.cell(linkageStatsTable, 3, 3, formatPct(linkageLongNetPct), text_color=pnlLongColor, bgcolor=bodyBg2)
        table.cell(linkageStatsTable, 4, 3, formatPct(longCompoundedPct), text_color=compLongColor, bgcolor=bodyBg2)
        table.cell(linkageStatsTable, 5, 3, formatPct(longAvgTradePct), text_color=titleText, bgcolor=bodyBg2)

        table.cell(linkageStatsTable, 0, 4, "Short", text_color=titleText, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 1, 4, str.tostring(linkageShortTrades), text_color=titleText, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 2, 4, formatPct(shortWinRate), text_color=titleText, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 3, 4, formatPct(linkageShortNetPct), text_color=pnlShortColor, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 4, 4, formatPct(shortCompoundedPct), text_color=compShortColor, bgcolor=bodyBg1)
        table.cell(linkageStatsTable, 5, 4, formatPct(shortAvgTradePct), text_color=titleText, bgcolor=bodyBg1)

        table.cell(linkageStatsTable, 0, 5, "Payoff", text_color=mutedText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 1, 5, formatRatio(payoffRatio), text_color=titleText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 2, 5, "PF", text_color=mutedText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 3, 5, formatRatio(profitFactor), text_color=titleText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 4, 5, "Max DD", text_color=mutedText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 5, 5, formatPct(linkageMaxDrawdownPct), text_color=titleText, bgcolor=footerBg, text_size=size.small)

        table.cell(linkageStatsTable, 0, 6, "Win/Loss Streak", text_color=mutedText, bgcolor=bodyBg2, text_size=size.small)
        table.cell(linkageStatsTable, 1, 6, str.tostring(linkageMaxWinStreak) + "/" + str.tostring(linkageMaxLossStreak), text_color=titleText, bgcolor=bodyBg2, text_size=size.small)
        table.cell(linkageStatsTable, 2, 6, "TP Mode", text_color=mutedText, bgcolor=bodyBg2, text_size=size.small)
        table.cell(linkageStatsTable, 3, 6, takeProfitLabel, text_color=titleText, bgcolor=bodyBg2, text_size=size.small)
        table.cell(linkageStatsTable, 4, 6, "Next Target", text_color=mutedText, bgcolor=bodyBg2, text_size=size.small)
        table.cell(linkageStatsTable, 5, 6, formatPrice(nextTargetPrice), text_color=titleText, bgcolor=bodyBg2, text_size=size.small)

        table.cell(linkageStatsTable, 0, 7, "Remaining Qty", text_color=mutedText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 1, 7, remainingPctText, text_color=titleText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 2, 7, "Open PnL", text_color=mutedText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 3, 7, formatPct(activePnlPct), text_color=activePnlColor, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 4, 7, "Stop", text_color=mutedText, bgcolor=footerBg, text_size=size.small)
        table.cell(linkageStatsTable, 5, 7, formatPrice(linkageStopPrice), text_color=titleText, bgcolor=footerBg, text_size=size.small)
    else
        table.clear(linkageStatsTable, 0, 0, 5, 7)
````
