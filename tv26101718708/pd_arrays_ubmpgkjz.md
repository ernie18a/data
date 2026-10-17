# PD Arrays

- url: https://www.tradingview.com/script/UbMpGKJz-PD-Arrays/
- type: indicator
- pine_id: PUB;92f7f58711be4f9bb990200dd49fc56f
- version: 8.0

## Description

Hi all!

This indicator is based on my indicator 'Order blocks' (https://www.tradingview.com/script/gBnqr4b2-Order-blocks/) that will show you order blocks (OB) found by the indicator or the once that are in alignment with the current trend. 

This indicator will, however, not only show you order blocks but it will also find fair value gaps (FVG). Order blocks and fair value gaps are popular and a big part of inner circle trading (ICT). The true power lies in that the indicator will give you alerts and show you labels for retest ('R'), false breakouts ('FB') and breakouts ('B'). This is possible through my library 'Touched' (https://www.tradingview.com/script/6x0Ed1nM-Touched/). The possibilities of interactions in the form of breakouts allows for the findings of broken order blocks and fair value gaps. That means that this indicator allows the showing of zones that are before the CHoCH/CHoCH+ and has flipped function. So a support becomes resistance and vice versa. These zones are popular and are called breaker blocks (BB, a flipped order block) and inversion fair value gap (IFVG, a flipped fair value gap). If a broken order block is before a BOS (instead of a CHoCH/CHoCH+) it's called a mitigation block (MB) instead of a breaker block, but it has the same function.
So, broken order blocks are called [b]breaker blocks[/b] (BB) if they're before a change of character (CHoCH/CHoCH+) and [b]mitigation blocks[/b] (MB) if they're before a break of structure (BOS). 
Broken fair value gaps are called [b]inversion fair value gaps[/b] (IFVG). The following zones will be displayed by the indicator:

• Fair value gaps
• Inversion fair value gaps 
• Order blocks
• Breaker blocks
• Mitigation blocks

The trend is based on price action that creates change of characters (CHoCH/CHoCH+) and break of structures (BOS). This is based on pivots/swings with your set length for left and right and is possible through my script 'PriceAction' (https://www.tradingview.com/script/nAGqSrxy-PriceAction/). The market structure will be displayed with solid lines and a label showing the type (CHoCH/CHoCH+/BOS).

2 things can invalidate a zone and cause it to disappear;
• broken by price or
• a CHoCH/CHoCH+ appears to start a new trend. 
I.e. a bullish zone (OB/FVG/BB/MB/IFVG) will disappear upon the closing price being lower than the zone's low or a bearish CHoCH/CHoCH+ happens. A bullish BB/MB/IFVG means a bearish OB/FVG that has been broken by price and is now bullish.

I've tried to make the ability to find zones to be on a different timeframe than chart (like in my script 'Order blocks') but I have not found it to be reliable yet, so the zones are found on the chart's timeframe. I will keep working on making it more reliable, but for now it's only possible to find them on the chart's timeframe.

The default settings will show you all zones (OB/FVG) and their broken version (BB/MB/IFVG). If the trend is bullish it will show bullish OBs and bullish FVGs and bearish OBs/FVGs that are broken and now are bullish (BB/MB/IFVG), and vice versa. OBs and FVGs will be displayed as soon as they are found, IFVGs when it's broken by price and BBs/MBs upon the next structural break (CHoCH/CHoCH+/BOS). All zones within a CHoCH/CHoCH+ (from the high/low pivot that's broken to when it's broken by price) will be kept to be take action on by the script's code. They're hidden until they make sense regarding to the new trend that's determined by the 'PriceAction' library.

[b]Settings[/b]

• Keep history
Check this if you want old zones to be kept (from previous trends). They are removed if they are broken or a CHoCH/CHoCH+ appears.

[i]PD ARRAYS[/i]

• Fair value gaps
Show fair value gaps or not.

• Inversion fair value gaps
Show inversion fair value gaps or not.

• Order blocks
Show order blocks or not.

• Breaker blocks
Show breaker blocks or not.

• Mitigation blocks
Show mitigation blocks or not.

[i] FAIR VALUE GAPS[/i]

• Consecutive rising/falling
The candles in the reaction must consecutivly rise or fall (the 'hl2' must be rising/falling).

• Force strong
If this is enabled it will force the FVG middle candle to have a higher/lower 'hl2' (middle of the entire candle) than the first candle's high.

• Hide consecutive zones
If multiple fair value gaps are found after each other only the first one will be found by the indicator.

• Minimum size
A factor of the Average True Range (of length 14) that the size of the fair value gap must have.

[i]ORDER BLOCKS[/i]

• Reaction
A factor of the Average True Range (of length 14) that the total reaction must have. A higher value will create fewer zones with a bigger reaction. And check the checkbox if you want the limit to be displayed.

• Take out
The bar that start the reaction must take out the previous bar high/low (liquidity sweep).

• Consecutive rising/falling
The candles in the reaction must consecutivly rise or fall.

• Fair value gap
The middle bar in the order block must create a fair value gap.

• Hide consecutive zones
If multiple order blocks are found after each other only the first one will be found by the indicator.

[i]DISPLAY[/i]

• Bull
The color for bullish zones (OB or FVG). This is the color before a breakout from the price, if it's broken by price once its a bearish zone instead.

• Bear
The color for bearish zones (OB or FVG). This is the color before a breakout from the price, if it's broken by price once its a bullish zone instead.

[i]MARKET STRUCTURE[/i]

• Enable
If zones found should follow market structure or not. This is automatically enabled if 'Current trend' is true.

• Pivot
Set the length of pivots and check if they should be shown or not.

• Font size
Set the font size of market structure text.

[i]ALERT[/i]

• Retests
Enable alerts for retest.

• False breakouts
Enable alerts for false breakouts.

• Breakouts
Enable alerts for breakouts.

[b]Examples[/b]
Below will be some examples of how the indicator behaves. All the examples are with the default settings but only the example zone is visible.

• This demonstrates a retest of an inversion fair value gap after a CHoCH+. After price goes higher (after that support) price retests later IFVGs and goes even higher.

https://www.tradingview.com/x/IqKqAWAr/

• Shows the lowest bullish fair value gap that's retested two times and goes higher. On the journey of higher prices more FVGs are retested/has false breakouts and price goes higher. 

https://www.tradingview.com/x/3cIlG3jz/

• Shows a bearish order block (at the top) that's retested and price goes lower.

https://www.tradingview.com/x/ps05Bzzd/

• Shows a bearish breaker block that has two retests and a false breakout. The origin is a bullish order block that's now (after price has broken it) a bearish breaker block. After that resistance price goes lower.

https://www.tradingview.com/x/Pqd5gSIn/

• Shows a retest of a bullish mitigation block (that's a broken bearish order block).

https://www.tradingview.com/x/mq4bXFBN/

The code for finding these PD Arrays are extracted to my library 'PDArrays' (https://www.tradingview.com/script/80p2t4uT-PDArrays/).

I hope that this indicator will help you in your trading and I've been trying to make an indicator like this for a very long time. Many new tries, a lot of time spent and lots of lines of code I managed to make one that I think is good enough!

If you have any findings of unexpected behavior or feature of, feel free to reach out!

Best of luck trading!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mickes

//@version=6
indicator("PD Arrays", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

import mickes/Touched/17
import mickes/PriceAction/9
import mickes/PDArrays/8

_history = input.bool(false, "Keep history")

var pdArraysGroup = "PD arrays"
_fairValueGaps = input.bool(true, "Fair value gaps", group = pdArraysGroup)
_inversionFairValueGaps = input.bool(true, "• Inversion fair value gaps", tooltip = "A broken fair value gap, use the same _settings as for fair value gaps.", group = pdArraysGroup)
_orderBlocks = input.bool(true, "Order blocks", group = pdArraysGroup)
_breakerBlocks = input.bool(true, "• Breaker blocks", tooltip = "A broken order block before a change of character (CHoCH), use the same _settings as for order blocks.", group = pdArraysGroup)
_mitigationBlocks = input.bool(true, "• Mitigation blocks", tooltip = "A broken order block before a break of structure (BOS), use the same _settings as for order blocks.", group = pdArraysGroup)

var _fairValueGapGroup = "Fair value gaps"
var _fairValueGapAsOrigin = _fairValueGaps or _inversionFairValueGaps
_fairValueGapConsecutiveRisingOrFalling = input.bool(false, "Consecutive rising/falling", tooltip = "The candles in the reaction must consecutivly rise or fall (the 'hl2' must be rising/falling).", group = _fairValueGapGroup, active = _fairValueGapAsOrigin)
_fairValueGapStrong = input.bool(false, "Force strong", tooltip = "If this is enabled it will force the FVG middle candle to have a higher/lower 'hl2' (middle of the entire candle) than the first candle's high.", group = _fairValueGapGroup, active = _fairValueGapAsOrigin)
_fairValueGapHideConsecutiveZones = input.bool(true, "Hide consecutive _context", tooltip = "If multiple fair value gaps are found after each other only the first one will be found by the indicator.", group = _fairValueGapGroup, active = _fairValueGapAsOrigin)
_fairValueGapMinimumSizeFactor = input.float(0.1, "Minimum size", tooltip = "A factor of the Average True Range (of length 14) that the size of the fair value gap must have.", group = _fairValueGapGroup, active = _fairValueGapAsOrigin)

var _orderBlockGroup = "Order blocks"
var _orderBlockAsOrigin = _orderBlocks or _breakerBlocks or _mitigationBlocks
_orderBlockReactionFactor = input.float(1.5, "Reaction", inline = "reaction", group = _orderBlockGroup, active = _orderBlockAsOrigin)
_orderBlockReactionShow = input.bool(true, "", tooltip = "A factor of the Average True Range (of length 14) that the total reaction must have. A higher value will create fewer _context with a bigger reaction. And check the checkbox if you want the limit to be displayed.", inline = "reaction", group = _orderBlockGroup, active = _orderBlockAsOrigin)
_orderBlockTakeOut = input.bool(true, "Take out", tooltip = "The bar that start the reaction must take out the previous bar high/low (liquidity sweep).", group = _orderBlockGroup, active = _orderBlockAsOrigin)
_orderBlockConsecutiveRisingOrFalling = input.bool(false, "Consecutive rising/falling", tooltip = "The candles in the reaction must consecutivly rise or fall.", group = _orderBlockGroup, active = _orderBlockAsOrigin)
_orderBlockFairValueGap = input.bool(true, "Fair Value Gap", tooltip = "The middle bar in the order block must create a fair value gap.", group = _orderBlockGroup, active = _orderBlockAsOrigin)
_orderBlockHideConsecutiveZones = input.bool(true, "Hide consecutive _context", tooltip = "If multiple order are found after each other only the first one will be found by the indicator.", group = _orderBlockGroup, active = _orderBlockAsOrigin)

_colorBull = input.color(color.green, "Bull", group = "Display")
_colorBear = input.color(color.red, "Bear", group = "Display")

_marketStructurePivotLength = input.int(5, "Pivot", inline = "pivot", group = "Market structure")
_marketStructureShowPivots = input.bool(true, "", inline = "pivot", tooltip = "Set the length of pivots and check if they should be shown or not.", group = "Market structure")
_marketStructureFontSize = input.int(7, "Font size", group = "Market structure")
_direction = input.enum(PDArrays.Direction.Both, "Direction", tooltip = "The zones created will always be filtered on if they're of high probability depending on the market structure trend. But with this setting you can choose if you want only bearish (potentially pushing the price lower) or bullish (potentially pushing the price higher) zones to be created, or if you want both.", group = "Market structure")

_turtleSoups = input.bool(true, "Filter", group = "Turtle soups", tooltip = "For zones to be created a turtle soup needs to have happend between the CHoCH/CHoCH+ pivot and the bar that caused the change of trend.")
_turtleSoupsPivotLeftLength = input.int(1, "Pivot", inline = "liquidityturtlesoup", group = "Turtle soups", active = _turtleSoups)
_turtleSoupsPivotRightLength = input.int(1, "", tooltip = "Set the pivot lengths (right and left) that can be  target for a turtle soup.", inline = "liquidityturtlesoup", group = "Turtle soups", active = _turtleSoups)
_turtleSoupsLookback = input.int(5, "Lookback", tooltip = "Set how many pivots back that can be a target for a turtle soup.", group = "Turtle soups", active = _turtleSoups)
_turtleSoupsTimeframe = input.timeframe("", "Timeframe", tooltip = "The higher timeframe for pivots that can be a target for a turtle soup.", group = "Turtle soups", active = _turtleSoups)
_turtleSoupsColor = input.color(color.new(color.orange, 70), "Color", group = "Turtle soups", active = _turtleSoups)
_turtleSoupsConfirmation = input.bool(true, "Confirmation", tooltip = "• ENABLED\nThe turtle soup needs to be followed by a change of character (CHoCH) in the opposite direction.\n\n• DISABLED\nAll potential turtle soups will be shown, even the once with the 'wrong' direction (this is due to how higher timeframe values (pivots in this case) are fethed in Pine Script and that the trend can change during that fetching).", group = "Turtle soups", active = _turtleSoups)

var _confirmationPivotsGroup = "Confirmation pivots"
_confirmationPivots = input.bool(true, "Filter", tooltip = "A 'confirmation pivot' is a pivot that appears after a CHoCH/CHoCH+ that includes a turtle soup (liquidity sweep/grab). When the confirmation pivot appears (after a turtle soup inside a CHoCH/CHoCH+) the change in trend is confimed. Enabling this filtering will invalidate any zones after this event and will cause the indicator to only create zones between the lowest low (or highest high for a bearish CHoCH/CHoCH+) before a CHoCH/CHoCH+ that contains a turtle soup and when this confirmation pivot is found (i.e. pivot + right length not when the pivot is).\n\nNOTE: This is only enabled if filtering on turtle soups is true.", group = _confirmationPivotsGroup, active = _turtleSoups)
_confirmationPivotsLeftLength = input.int(2, "Pivot", inline = "confirmationpivot", group = _confirmationPivotsGroup, active = _turtleSoups and _confirmationPivots)
_confirmationPivotsRightLength = input.int(2, "", tooltip = "Set the pivot lengths (left and right) for the pivot after the turtle soup confirmation (CHoCH) that will cause the creation of context.", inline = "confirmationpivot", group = _confirmationPivotsGroup, active = _turtleSoups and _confirmationPivots)
_confirmationPivotsShow = input.bool(true, "", inline = "confirmationpivot", group = _confirmationPivotsGroup, active = _turtleSoups and _confirmationPivots)
_confirmationPivotsLookback = input.int(5, "Lookback", group = _confirmationPivotsGroup, active = _turtleSoups and _confirmationPivots)
_confirmationPivotsTimeframe = input.timeframe("", "Timeframe", group = _confirmationPivotsGroup, active = _turtleSoups and _confirmationPivots)

var _statisticsGroup = "Statistics"
_statisticsTradesPerZone = input.int(1, "Trades per zone", tooltip = "A zone can create maximum of these number of trades (e.g. if this is '1' only the first enabled alert integration (e.g. retests) will open a trade not the following integrations).", group = _statisticsGroup)
_statisticsTradeStopLossMargin = input.float(0.3, "Stop loss margin", tooltip = "A margin below bullish zones and above bearish zones for the stop loss. This is a factor of the zone's width (high - low).", group = _statisticsGroup)

_alertForceClose = input.bool(true, "Force close", tooltip = "The bar must be closed for an alert to be sent. This affects all integrations, even the ones you see as a label on the chart (including broken versuons if OB/FVG (BB/MB/IFVG)).", group = "Alert")
_alertRetests = input.bool(true, "Retests", tooltip = "Alert for retest. This is also used to open trades.", group = "Alert")
_alertFalseBreakouts = input.bool(false, "False breakouts", tooltip = "Alert for false breakouts. This is also used to open trades.", group = "Alert")

Confirm(PriceAction.TurtleSoups turtleSoupsContext, int trend, PriceAction.TurtleSoupSettings settings, int earliest, int latest, PriceAction.Screener screener) =>
    switch trend
        -1 => PriceAction.Confirm(turtleSoupsContext.Bearish, turtleSoupsContext, settings, earliest, latest, screener)
        1 => PriceAction.Confirm(turtleSoupsContext.Bullish, turtleSoupsContext, settings, earliest, latest, screener)
TurtleSoup(PriceAction.TurtleSoups turtleSoupsContext, PriceAction.TurtleSoupSettings settings) =>
    if barstate.isconfirmed // only if the bar is closed
        PriceAction.VisualizeTurtleSoups(turtleSoupsContext.Highs, turtleSoupsContext.Bearish, turtleSoupsContext, settings)
        PriceAction.VisualizeTurtleSoups(turtleSoupsContext.Lows, turtleSoupsContext.Bullish, turtleSoupsContext, settings)

var _marketStructureInfo = PDArrays.MarketStructureInfo.new(PDArrays.MarketStructurePivot.new(-1), PDArrays.MarketStructurePivot.new(-1), PDArrays.TurtleSoupInfo.new())
var _context = PDArrays.Context.new(array.new<PDArrays.Zone>(), array.new<PDArrays.Zone>(), array.new<PDArrays.Zone>(), array.new<PriceAction.Pivot>(), array.new<PriceAction.Pivot>(), PDArrays.Statistics.new(Longs = array.new<PDArrays.Trade>(5, PDArrays.Trade.new()), Shorts = array.new<PDArrays.Trade>(5, PDArrays.Trade.new())))
var _settings = PDArrays.Settings.new(_history, _colorBull, _colorBear, false, _alertRetests, _alertFalseBreakouts, array.from(_fairValueGaps ? PDArrays.Type.FairValueGap : na, _orderBlocks ? PDArrays.Type.OrderBlock : na, _inversionFairValueGaps ? PDArrays.Type.InversionFairValueGap : na, _breakerBlocks ? PDArrays.Type.BreakerBlock : na, _mitigationBlocks ? PDArrays.Type.MitigationBlock : na), PDArrays.FairValueGapSettings.new(_fairValueGapConsecutiveRisingOrFalling, _fairValueGapStrong, _fairValueGapHideConsecutiveZones, _fairValueGapMinimumSizeFactor), PDArrays.OrderBlockSettings.new(_orderBlockTakeOut, _orderBlockFairValueGap, _orderBlockConsecutiveRisingOrFalling, _orderBlockReactionFactor, _orderBlockReactionShow, _orderBlockHideConsecutiveZones), PDArrays.ConfirmationPivotSettings.new(_confirmationPivotsLeftLength, _confirmationPivotsRightLength, _confirmationPivotsShow, _confirmationPivotsLookback, _confirmationPivotsTimeframe), PDArrays.StatisticsSettings.new(PDArrays.TradeSettings.new(_statisticsTradesPerZone, _statisticsTradeStopLossMargin)))
var _foundZones = array.new<PDArrays.Zone>()
var _priceAction = PriceAction.PriceAction.new(Liquidity = PriceAction.Liquidity.new(array.new<PriceAction.Pivot>(), array.new<PriceAction.Pivot>(), 1, 5), Swing = PriceAction.Structure.new(_marketStructurePivotLength, _marketStructurePivotLength, PriceAction.Type.Swing, 0, -1, false, "", color(na), array.new<box>(), array.new<box>(), array.new<PriceAction.StructureBreak>(), array.new<PriceAction.Pivot>(), _marketStructureFontSize, false, false, false))

PriceAction.Pivot(_priceAction.Swing)
if _marketStructureShowPivots
    PriceAction.PivotLabels(_priceAction.Swing)
_breakOfStructure = PriceAction.BreakOfStructure(_priceAction.Swing)
if not na(_breakOfStructure)
    _marketStructureInfo.LatestBreakOfStructure := PDArrays.MarketStructurePivot.new(bar_index, _breakOfStructure)
_changeOfCharacter = PriceAction.ChangeOfCharacter(_priceAction.Swing)
if not na(_changeOfCharacter)
    [deepestPullbackInsideCHoCH, deepestPullbackInsideCHoCHBarIndex] = PDArrays.DeepestRetracement(_changeOfCharacter.BarIndex, bar_index, _priceAction.Swing.Trend)
    _marketStructureInfo.LatestChangeOfCharacter := PDArrays.MarketStructurePivot.new(bar_index, _changeOfCharacter, deepestPullbackInsideCHoCH, deepestPullbackInsideCHoCHBarIndex)

[_pivotHigh, _pivotLow] = PDArrays.Pivots(_settings)
_orderBlock = PDArrays.OrderBlock(_settings, _pivotHigh, _pivotLow)
_fairValueGap = PDArrays.FairValueGap(_settings)

var _turtleSoupsContext = PriceAction.TurtleSoups.new(array.new<PriceAction.Pivot>(), array.new<PriceAction.Pivot>(), array.new<PriceAction.TurtleSoup>(), array.new<PriceAction.TurtleSoup>(), array.new<string>())
if _turtleSoups
    var turtleSoupSettings = PriceAction.TurtleSoupSettings.new(_turtleSoupsPivotLeftLength, _turtleSoupsPivotRightLength, _turtleSoupsLookback, _turtleSoupsConfirmation, _turtleSoupsColor)
    TurtleSoup(_turtleSoupsContext, turtleSoupSettings)
    if not na(_changeOfCharacter)
        Confirm(_turtleSoupsContext, _priceAction.Swing.Trend, turtleSoupSettings, _marketStructureInfo.LatestChangeOfCharacter.Pivot.BarIndex, bar_index, PriceAction.Screener.new())
    [pivotHigh, pivotLow] = request.security(syminfo.tickerid, _turtleSoupsTimeframe, PriceAction.GetPivots(turtleSoupSettings))
    PriceAction.SetBarIndices(pivotHigh, pivotLow)
    PriceAction.SetPivots(_turtleSoupsContext, turtleSoupSettings, pivotHigh, pivotLow)

if not na(_orderBlock)
    PDArrays.SetBarIndex(_orderBlock)
    _foundZones.unshift(_orderBlock)
if not na(_fairValueGap)
    PDArrays.SetBarIndex(_fairValueGap)
    _foundZones.unshift(_fairValueGap)

if _turtleSoups and _confirmationPivots
    [confirmationPivotHigh, confirmationPivotLow] = request.security(syminfo.tickerid, _confirmationPivotsTimeframe, PDArrays.GetConfirmationPivots(_settings.ConfirmationPivotSettings))
    PriceAction.SetBarIndices(confirmationPivotHigh, confirmationPivotLow)
    PDArrays.SetConfirmationPivots(_context, _settings.ConfirmationPivotSettings, confirmationPivotHigh, confirmationPivotLow)
    PDArrays.InvalidateIfAfterConfirmationPivot(_context, _marketStructureInfo, _priceAction.Swing.Trend, _foundZones, _settings.ConfirmationPivotSettings)

if _alertForceClose ? barstate.isconfirmed : true
    PDArrays.Interactions(_context, _settings, _priceAction.Swing.Trend, _marketStructureInfo)
    PDArrays.HiddenInteractions(_context, _settings, _marketStructureInfo, _priceAction.Swing.Trend)

PDArrays.HandleTrades(_context.Statistics.Longs, PDArrays.TradeDirection.Long)
PDArrays.HandleTrades(_context.Statistics.Shorts, PDArrays.TradeDirection.Short)

PDArrays.MarketStructureTrailingStopLoss(_context.Statistics.Longs, PDArrays.TradeDirection.Long, _priceAction.Swing.Trend)
PDArrays.MarketStructureTrailingStopLoss(_context.Statistics.Shorts, PDArrays.TradeDirection.Short, _priceAction.Swing.Trend)

if _turtleSoups
    PDArrays.InvalidateIfNoTurtleSoup(_turtleSoupsContext, _marketStructureInfo, _foundZones, _priceAction)
if _direction != PDArrays.Direction.Both
    PDArrays.InvalidateIfWrongDirection(_foundZones, _direction, _priceAction.Swing.Trend)
    if not _turtleSoups and not na(_changeOfCharacter)
        PDArrays.RevalidateIfRightDirection(_foundZones, _direction, _priceAction.Swing.Trend, _changeOfCharacter.BarIndex)
PDArrays.MarketStructureZones(_marketStructureInfo, _foundZones, _context, _priceAction, _settings)


long0 = _context.Statistics.Longs.get(0)
plot(bar_index - long0.EntryBarIndex, "Entry 0", display = display.pine_screener, precision = 0)
plot(long0.SourceInt, "Source 0", display = display.pine_screener, precision = 0)
plot(long0.Profit, "Profit 0", display = display.pine_screener)
plot(long0.ProfitIfTrailingStopLoss, "Trailing stop profit 0", display = display.pine_screener)

long1 = _context.Statistics.Longs.get(1)
plot(bar_index - long1.EntryBarIndex, "Entry 1", display = display.pine_screener, precision = 0)
plot(long1.SourceInt, "Source 1", display = display.pine_screener, precision = 0)
plot(long1.Profit, "Profit 1", display = display.pine_screener)
plot(long1.ProfitIfTrailingStopLoss, "Trailing stop profit 1", display = display.pine_screener)

long2 = _context.Statistics.Longs.get(2)
plot(bar_index - long2.EntryBarIndex, "Entry 2", display = display.pine_screener, precision = 0)
plot(long2.SourceInt, "Source 2", display = display.pine_screener, precision = 0)
plot(long2.Profit, "Profit 2", display = display.pine_screener)
plot(long2.ProfitIfTrailingStopLoss, "Trailing stop profit 2", display = display.pine_screener)

long3 = _context.Statistics.Longs.get(3)
plot(bar_index - long3.EntryBarIndex, "Entry 3", display = display.pine_screener, precision = 0)
plot(long3.SourceInt, "Source 3", display = display.pine_screener, precision = 0)
plot(long3.Profit, "Profit 3", display = display.pine_screener)
plot(long3.ProfitIfTrailingStopLoss, "Trailing stop profit 3", display = display.pine_screener)

long4 = _context.Statistics.Longs.get(4)
plot(bar_index - long4.EntryBarIndex, "Entry 4", display = display.pine_screener, precision = 0)
plot(long4.SourceInt, "Source 4", display = display.pine_screener, precision = 0)
plot(long4.Profit, "Profit 4", display = display.pine_screener)
plot(long4.ProfitIfTrailingStopLoss, "Trailing stop profit 4", display = display.pine_screener)
````
