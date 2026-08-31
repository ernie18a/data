<!-- tradingview-pine-id: PUB;5bfc8355aa774a2c8d907157b10143cb -->
<!-- tradingviewscripts-format: 1 -->
# Divergence Screener [Trendoscope®]

Source: https://www.tradingview.com/script/zewvHAvQ-Divergence-Screener-Trendoscope/

## Description

🎲Overview
The Divergence Screener is a powerful TradingView indicator designed to detect and visualize bullish and bearish divergences, including hidden divergences, between price action and a user-selected oscillator. Built with flexibility in mind, it allows traders to customize the oscillator type, trend detection method, and other parameters to suit various trading strategies. The indicator is non-overlay, displaying divergence signals directly on the oscillator plot, with visual cues such as lines and labels on the chart for easy identification.

This indicator is ideal for traders seeking to identify potential reversal or continuation signals based on price-oscillator divergences. It supports multiple oscillators, trend detection methods, and alert configurations, making it versatile for different markets and timeframes.

🎲Features
🎯Customizable Oscillator Selection

[*]Built-in Oscillators: Choose from a variety of oscillators including RSI, CCI, CMO, COG, MFI, ROC, Stochastic, and WPR.
[*]External Oscillator Support: Users can input an external oscillator source, allowing integration with custom or third-party indicators.
[*]Configurable Length: Adjust the oscillator’s period (e.g., 14 for RSI) to fine-tune sensitivity.

[image]https://www.tradingview.com/x/8CyrAwXy/[/image]
🎯Divergence Detection
The screener identifies four types of divergences:

[*]Bullish Divergence: Price forms a lower low, but the oscillator forms a higher low, signaling potential upward reversal.
[*]Bearish Divergence: Price forms a higher high, but the oscillator forms a lower high, indicating potential downward reversal.
[*]Bullish Hidden Divergence: Price forms a higher low, but the oscillator forms a lower low, suggesting trend continuation in an uptrend.
[*]Bearish Hidden Divergence: Price forms a lower high, but the oscillator forms a higher high, suggesting trend continuation in a downtrend.

[image]https://www.tradingview.com/x/iKjcsM59/[/image]
[image]https://www.tradingview.com/x/HPjrni3D/[/image]
🎯Flexible Trend Detection

[*]The indicator offers three methods to determine the trend context for divergence detection:
[*]Zigzag: Uses zigzag pivots to identify trends based on higher highs (HH), higher lows (HL), lower highs (LH), and lower lows (LL).
[*]MA Difference: Calculates the trend based on the difference in a moving average (e.g., SMA, EMA) between divergence pivots.
[*]External Trend Signal: Allows users to input an external trend signal (positive for uptrend, negative for downtrend) for custom trend analysis.

[image]https://www.tradingview.com/x/YMPEXVDX/[/image]
🎯Zigzag-Based Pivot Analysis

[*]Customizable Zigzag Length: Adjust the zigzag length (default: 13) to control the sensitivity of pivot detection.
[*]Repaint Option: Choose whether divergence lines repaint based on the latest data or wait for confirmed pivots, balancing responsiveness and reliability.

🎯Visual and Alert Features

[*]Divergence Visualization: Divergence lines are drawn between price pivots and oscillator pivots, color-coded for easy identification:

[*]Bullish Divergence: Green
[*]Bearish Divergence: Red
[*]Bullish Hidden Divergence: Lime
[*]Bearish Hidden Divergence: Orange

[*]Labels and Tooltips: Labels (e.g., “D” for divergence, “H” for hidden) appear on price and oscillator pivots, with tooltips providing detailed information such as price/oscillator values, ratios, and pivot directions.
[*] Alerts: Configurable alerts for each divergence type (bullish, bearish, bullish hidden, bearish hidden) trigger on bar close, ensuring timely notifications.

[image]https://www.tradingview.com/x/476vqtDM/[/image]
🎲 How It Works
🎯Oscillator Calculation

[*]The indicator calculates the selected oscillator (or uses an external source) and plots it on the chart.
[*]Oscillator values are stored in a map for reference during divergence calculations.

🎯Pivot Detection

[*]A zigzag algorithm identifies pivots in the oscillator data, with configurable length and repainting options.
[*]Price and oscillator pivots are compared to detect divergences based on their direction and ratio.

🎯Divergence Identification

[*]The indicator compares price and oscillator pivot directions (HH, HL, LH, LL) to identify divergences.
[*]Trend context is determined using the selected method (Zigzag, MA Difference, or External).
[*]Divergences are classified as bullish, bearish, bullish hidden, or bearish hidden based on price-oscillator relationships and trend direction.

🎯Visualization and Alerts

[*]Valid divergences are drawn as lines connecting price and oscillator pivots, with corresponding labels.
[*]Alerts are triggered for allowed divergence types, providing detailed information via tooltips.

🎯Validation
Divergence lines are validated to ensure no intermediate bars violate the divergence condition, enhancing signal reliability.

🎲 Usage Instructions as Indicator
🎯Add to Chart:

[*]Add the “Divergence Screener [Trendoscope®]” to your TradingView chart.
[*]The indicator appears in a separate pane below the price chart, plotting the oscillator and divergence signals.

🎯Configure Settings:

[*]Adjust the oscillator type and length to match your trading style.
[*]Select a trend detection method and configure related parameters (e.g., MA type/length or external signal).
[*]Set the zigzag length and repainting preference.
[*]Enable/disable alerts for specific divergence types.

I🎯nterpret Signals:

[*]Bullish Divergence (Green): Look for potential buy opportunities in a downtrend.
[*]Bearish Divergence (Red): Consider sell opportunities in an uptrend.
[*]Bullish Hidden Divergence (Lime): Confirm continuation in an uptrend.
[*]Bearish Hidden Divergence (Orange): Confirm continuation in a downtrend.
[*]Use tooltips on labels to review detailed pivot and divergence information.

🎯Set Alerts:

[*]Create alerts for each divergence type to receive notifications via TradingView’s alert system.
[*]Alerts include detailed text with price, oscillator, and divergence information.

🎲 Example Scenarios as Indicator
🎯 With External Oscillator (Use MACD Histogram as Oscillator)
In order to use MACD as an oscillator for divergence signal instead of the built in options, follow these steps.

[*] Load MACD Indicator from Indicator library
[*] From Indicator settings of Divergence Screener, set Use External Oscillator and select MACD Histograme from the dropdown
[*] You can now see that the oscillator pane shows the data of selected MACD histogram and divergence signals are generated based on the external MACD histogram data.

[image]https://www.tradingview.com/x/qhud70u3/[/image]
🎯 With External Trend Signal (Supertrend Ladder ATR)
Now let's demonstrate how to use external direction signals using [Supertrend Ladder ATR](https://www.tradingview.com/script/8EZaD3CW-Supertrend-Ladder-ATR/) indicator. Please note that in order to use the indicator as trend source, the indicator should return positive integer for uptrend and negative integer for downtrend. Steps are as follows:

[*] Load the desired trend indicator. In this example, we are using [Supertrend Ladder ATR](url=https://www.tradingview.com/script/8EZaD3CW-Supertrend-Ladder-ATR/)
[*] From the settings of Divergence Screener, select "External" as Trend Detection Method
[*] Select the trend detection plot Direction from the dropdown. You can now see that the divergence signals will rely on the new trend settings rather than the built in options.

[image]https://www.tradingview.com/x/sU0ThTeV/[/image]

🎲 Using the Script with Pine Screener
The primary purpose of the Divergence Screener is to enable traders to scan multiple instruments (e.g., stocks, ETFs, forex pairs) for divergence signals using TradingView’s Pine Screener, facilitating efficient comparison and identification of trading opportunities.

To use the Divergence Screener as a screener, follow these steps:

[*]Add to Favorites: Add the Divergence Screener [Trendoscope®] to your TradingView favorites to make it available in the Pine Screener.
[*]Create a Watchlist: Build a watchlist containing the instruments (e.g., stocks, ETFs, or forex pairs) you want to scan for divergences.
[*]Access Pine Screener: Navigate to the Pine Screener via TradingView’s main menu: Products -> Screeners -> Pine, or directly visit tradingview.com/pine-screener/.
[*]Select Watchlist: Choose the watchlist you created from the Watchlist dropdown in the Pine Screener interface.
[*]Choose Indicator: Select Divergence Screener [Trendoscope®] from the Choose Indicator dropdown.
[*]Configure Settings: Set the desired timeframe (e.g., 1 hour, 1 day) and adjust indicator settings such as oscillator type, zigzag length, or trend detection method as needed.
[*]Select Filter Criteria: Select the condition on which the watchlist items needs to be filtered. Filtering can only be done on the plots defined in the script.
[*]Run Scan: Press the Scan button to display divergence signals across the selected instruments. The screener will show which instruments exhibit bullish, bearish, bullish hidden, or bearish hidden divergences based on the configured settings.

[image]https://www.tradingview.com/x/VUvMvIby/[/image]

🎲 Limitations and Possible Future Enhancements
Limitations are

[*] Custom input for oscillator and trend detection cannot be used in pine screener.
[*] Pine screener has max 500 bars available.
[*] Repaint option is by default enabled. When in repaint mode expect the early signal but the signals are prone to repaint.

Possible future enhancements

[*] Add more built-in options for oscillators and trend detection methods so that dependency on external indicators is limited
[*] Multi level zigzag support

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope
//                                       ░▒             
//                                  ▒▒▒   ▒▒      
//                              ▒▒▒▒▒     ▒▒      
//                      ▒▒▒▒▒▒▒░     ▒     ▒▒          
//                  ▒▒▒▒▒▒           ▒     ▒▒          
//             ▓▒▒▒       ▒        ▒▒▒▒▒▒▒▒▒▒▒  
//   ▒▒▒▒▒▒▒▒▒▒▒ ▒        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒         
//   ▒  ▒       ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░        
//   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒         
//   ▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▒▒                       
//    ▒▒▒▒▒         ▒▒▒▒▒▒▒                            
//                 ▒▒▒▒▒▒▒▒▒                           
//                ▒▒▒▒▒ ▒▒▒▒▒                          
//               ░▒▒▒▒   ▒▒▒▒▓      ████████╗██████╗ ███████╗███╗   ██╗██████╗  ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗
//              ▓▒▒▒▒     ▒▒▒▒      ╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
//              ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        ██║   ██████╔╝█████╗  ██╔██╗ ██║██║  ██║██║   ██║███████╗██║     ██║   ██║██████╔╝█████╗ 
//             ▒▒▒▒▒       ▒▒▒▒▒       ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║██║   ██║╚════██║██║     ██║   ██║██╔═══╝ ██╔══╝  
//            ▒▒▒▒▒         ▒▒▒▒▒      ██║   ██║  ██║███████╗██║ ╚████║██████╔╝╚██████╔╝███████║╚██████╗╚██████╔╝██║     ███████╗
//             ▒▒             ▒                        
//@version=6
import Trendoscope/Drawing/3 as dr
import Trendoscope/Zigzag/11 as zg
import Trendoscope/oota/1 as eta
indicator('Divergence Screener [Trendoscope®]', 'DS1.1[Trendoscope®]', overlay = false, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100, calc_bars_count = 500)

oscillator(simple string type = 'rsi', simple int length = 14, float source = close, float highSource = high, float lowSource = low) =>
    oscillator = switch type
        'cci' => ta.cci(source, length)
        'cmo' => ta.cmo(source, length)
        'cog' => ta.cog(source, length)
        'mfi' => ta.mfi(source, length)
        'roc' => ta.roc(source, length)
        'rsi' => ta.rsi(source, length)
        'stoch' => ta.stoch(source, highSource, lowSource, length)
        'wpr' => ta.wpr(length)
        => ta.rsi(source, length)
    oscillator

oscillatorType = input.string('rsi', 'Oscillator', ['rsi', 'cci', 'cmo', 'cog', 'mfi', 'roc', 'stoch', 'wpr'], inline = 'osc', group = 'Oscillator', display = display.none)
length = input.int(14, '', group = 'Oscillator', inline = 'osc', tooltip = 'Built in Oscillator Type and Length', display = display.none)
useExternalOscillator = input.bool(false, 'Use External Oscillator', inline = 'eosc', group = 'Oscillator', display = display.none)
externalOscillator = input.source(close, '', 'Use external oscillator instead of the built ins', inline = 'eosc', group = 'Oscillator', display = display.none)

rsiColor = color.blue

trendTypeTooltip = 'Method to identify trend. \n' + '\tZigzag - HH, HL on the starting pivot of divergence line is considered as uptrend and LL, LH on the starting pivot of divergence line is considered as downtrend\n' + '\tMA Difference - Difference between moving average of divergence line pivot will define the trend\n' + '\tExternal - Use External Oscillator Input'
trendMethod = input.string('Zigzag', 'Trend Detection Method', ['Zigzag', 'MA Difference', 'External'], group = 'Trend', display = display.none, tooltip = trendTypeTooltip)
maType = input.enum(eta.CustomSeries.SMA, 'MA Filter', inline = 'ma', group = 'Trend', display = display.none)
maLength = input.int(200, '', minval = 5, step = 50, inline = 'ma', group = 'Trend', display = display.none, tooltip = 'Moving Average to identify trend. Direction of moving average between the divergence pivots identify trend')
externalTrendSignal = input.source(close, 'External Trend Signal', 'Use External trend signal instead of the built in. The external indicator should return positive value for uptrend and negative value for downtrend', group = 'Trend', display = display.none)

zigzagLength = input.int(13, 'Length', group = 'Zigzag', tooltip = 'Zigzag Length', display = display.none)

repaint = input.bool(true, 'Repaint', 'If selected, divergence lines repaint as per the latest info. ' + 'If repaint is disabled, then the divergence is calculated based on confirmed pivots only. ' + 'Hence, the signals will be delayed till the pivot is confirmed.', group = 'Miscellaneous', display = display.none)

bullishDivergenceAlert = input.bool(true, 'Bullish Divergence', 'Alert on bullish divergence', group = 'Alerts', display = display.none)
bullishHiddenDivergenceAlert = input.bool(true, 'Bullish Hidden Divergence', 'Alert on bullish hidden divergence', group = 'Alerts', display = display.none)
bearishDivergenceAlert = input.bool(true, 'Bearish Divergence', 'Alert on bearish divergence', group = 'Alerts', display = display.none)
bearishHiddenDivergenceAlert = input.bool(true, 'Bearish Hidden Divergence', 'Alert on bearish hidden divergence', group = 'Alerts', display = display.none)

textColor = chart.bg_color

trendMethodInt = trendMethod == 'Zigzag' ? 1 : trendMethod == 'External' ? 3 : 2
var map<int, float> priceMap = map.new<int, float>()
var map<int, float> oscillatorMap = map.new<int, float>()
priceMap.put(bar_index, close)

enum DivergenceType
    BullishDivergence = "Bullish Divergence"
    BearishDivergence = "Bearish Divergence"
    BullishHiddenDivergence = "Bullish Hidden Divergence"
    BearishHiddenDivergence = "Bearish Hidden Divergence"
    None = "None"

type DivergenceObject
    dr.Line priceLine
    dr.Line oscillatorLine
    dr.Label priceLabel
    dr.Label oscillatorLabel
    chart.point pricePoint
    DivergenceType divergenceType
    bool broken = false

method delete(DivergenceObject this)=>
    this.priceLine.delete()
    this.oscillatorLine.delete()
    this.priceLabel.delete()
    this.oscillatorLabel.delete()
    this

method draw(DivergenceObject this)=>
    this.delete()
    this.priceLine.draw()
    this.oscillatorLine.draw()
    this.priceLabel.draw()
    this.oscillatorLabel.draw()
    this

type ZigzagProperties
	color textColor = color.black
	int trendMethod = 1
	bool repaint = false

enum PivotDirection
    HH = "Higher High"
    LH = "Lower High"
    HL = "Higher Low"
    LL = "Lower Low"

getDivergenceType(direction, divergence)=>
    direction > 0?
         (divergence > 0 ? DivergenceType.BearishDivergence : DivergenceType.BearishHiddenDivergence):
         (divergence > 0 ? DivergenceType.BullishDivergence : DivergenceType.BullishHiddenDivergence)

getPivotDirection(dir, ratio) =>
    dir > 0 ? (ratio > 1 ? PivotDirection.HH : PivotDirection.LH) : ratio > 1 ? PivotDirection.LL : PivotDirection.HL

getLinePropertiesMap(bool force_overlay=false)=>
    linePropertiesMap = map.new<DivergenceType, dr.LineProperties>()
    linePropertiesMap.put(DivergenceType.BullishDivergence, dr.LineProperties.new(xloc.bar_time, extend.none, color.green, line.style_solid, 1, force_overlay))
    linePropertiesMap.put(DivergenceType.BearishDivergence, dr.LineProperties.new(xloc.bar_time, extend.none, color.red, line.style_solid, 1, force_overlay))
    linePropertiesMap.put(DivergenceType.BullishHiddenDivergence, dr.LineProperties.new(xloc.bar_time, extend.none, color.lime, line.style_solid, 1, force_overlay))
    linePropertiesMap.put(DivergenceType.BearishHiddenDivergence, dr.LineProperties.new(xloc.bar_time, extend.none, color.orange, line.style_solid, 1, force_overlay))
    linePropertiesMap

getLabelPropertiesMap(bool force_overlay=false)=>
    labelPropertiesMap = map.new<DivergenceType, dr.LabelProperties>()
    labelPropertiesMap.put(DivergenceType.BullishDivergence, dr.LabelProperties.new(xloc.bar_time, yloc.price, color.green, label.style_label_up, chart.bg_color, size.small, force_overlay = force_overlay))
    labelPropertiesMap.put(DivergenceType.BearishDivergence, dr.LabelProperties.new(xloc.bar_time, yloc.price, color.red, label.style_label_down, chart.bg_color, size.small, force_overlay = force_overlay))
    labelPropertiesMap.put(DivergenceType.BullishHiddenDivergence, dr.LabelProperties.new(xloc.bar_time, yloc.price, color.lime, label.style_label_up, chart.bg_color, size.small, force_overlay = force_overlay))
    labelPropertiesMap.put(DivergenceType.BearishHiddenDivergence, dr.LabelProperties.new(xloc.bar_time, yloc.price, color.orange, label.style_label_down, chart.bg_color, size.small, force_overlay = force_overlay))
    labelPropertiesMap

getAllowedDivergenceTypes()=>
    allowedDivergenceTypes = map.new<DivergenceType, bool>()
    allowedDivergenceTypes.put(DivergenceType.BullishDivergence, bullishDivergenceAlert)
    allowedDivergenceTypes.put(DivergenceType.BullishHiddenDivergence, bullishHiddenDivergenceAlert)
    allowedDivergenceTypes.put(DivergenceType.BearishDivergence, bearishDivergenceAlert)
    allowedDivergenceTypes.put(DivergenceType.BearishHiddenDivergence, bearishHiddenDivergenceAlert)
    allowedDivergenceTypes

const map<DivergenceType, bool> allowedDivergenceTypes = getAllowedDivergenceTypes()

const map<DivergenceType, dr.LineProperties> priceLinePropertiesMap = getLinePropertiesMap(true)
const map<DivergenceType, dr.LineProperties> oscillatorLinePropertiesMap = getLinePropertiesMap()

const map<DivergenceType, dr.LabelProperties> priceLabelPropertiesMap = getLabelPropertiesMap(true)
const map<DivergenceType, dr.LabelProperties> oscillatorLabelPropertiesMap = getLabelPropertiesMap()

method divergence(zg.Zigzag this, array<DivergenceObject> divergenceObjects, ZigzagProperties properties) =>
    startIndex = properties.repaint ? 0 : 1
    DivergenceType divergenceType = DivergenceType.None
    if this.zigzagPivots.size() > 2 + startIndex
        lastPivot = this.zigzagPivots.get(startIndex)
        llastPivot = this.zigzagPivots.get(startIndex + 2)
        skip = false
        if this.flags.updateLastPivot
            if divergenceObjects.size() > 0
                lastDivergence = divergenceObjects.last()
                divergenceStartBar = lastDivergence.priceLine.start.index
                llastPivotBar = llastPivot.point.index

                divergenceEndBar = lastDivergence.priceLine.end.index
                lastPivotBar = lastPivot.point.index
                if llastPivotBar == divergenceStartBar and lastPivotBar > divergenceEndBar
                    divergenceObjects.pop().delete()
                skip := llastPivotBar == divergenceStartBar and lastPivotBar == divergenceEndBar
                skip

        if this.flags.newPivot and not skip
            dir = math.sign(lastPivot.dir)
            lastOsc = lastPivot.point.price
            lastPrice = lastPivot.indicatorValues.get(0)
            oscRatio = lastPivot.ratio
            priceRatio = lastPivot.indicatorRatios.get(0)

            priceDirection = getPivotDirection(lastPivot.dir, priceRatio)
            oscillatorDirection = getPivotDirection(lastPivot.dir, oscRatio)

            lastTrend = lastPivot.indicatorValues.get(2)
            lastMa = lastPivot.indicatorValues.get(1)

            pricePoint = chart.point.new(lastPivot.point.time, lastPivot.point.index, lastPrice)
            oscillatorPoint = chart.point.new(lastPivot.point.time, lastPivot.point.index, lastPivot.point.price)

            if priceDirection != oscillatorDirection and llastPivot.indicatorRatios.size() > 0
                llastPrice = llastPivot.indicatorValues.get(0)
                llastRatio = llastPivot.indicatorRatios.get(0)
                llastMa = llastPivot.indicatorValues.get(1)
                lastPricePoint = chart.point.new(llastPivot.point.time, llastPivot.point.index, llastPrice)
                llastOscillatorPoint = chart.point.new(llastPivot.point.time, llastPivot.point.index, llastPivot.point.price)

                sentiment = math.sign(oscRatio - priceRatio)
                trend = properties.trendMethod == 3 ? math.sign(lastTrend) : properties.trendMethod == 1 ? math.sign(dir * (llastRatio - 1)) : math.sign(llastMa - lastMa)
                divergence = trend == dir and sentiment < 0 ? 1 : trend != dir and sentiment > 0 ? -1 : 0
                if divergence != 0
                    divergenceType := getDivergenceType(dir, divergence)
                    priceDivergenceLine = dr.Line.new(lastPricePoint, pricePoint, priceLinePropertiesMap.get(divergenceType))
                    oscillatorDivergenceLine = dr.Line.new(llastOscillatorPoint, oscillatorPoint, oscillatorLinePropertiesMap.get(divergenceType))

                    validDivergence = true
                    for bar = lastPricePoint.index + 1 to pricePoint.index - 1 by 1
                        priceAtBar = priceMap.get(bar)
                        oscillatorAtBar = oscillatorMap.get(bar)
                        if priceAtBar * dir > priceDivergenceLine.get_price(bar) * dir or oscillatorAtBar * dir > oscillatorDivergenceLine.get_price(bar) * dir
                            validDivergence := false
                            break

                    if validDivergence
                        priceLabelText = divergenceType == DivergenceType.BullishDivergence or divergenceType == DivergenceType.BearishDivergence ? 'D' : 'H'
                        priceTooltipText = str.tostring(divergenceType) + '\nPrice : ' + str.tostring(lastPrice) + ' ( ' + str.tostring(priceRatio) + ' ) - ' +
                                         str.tostring(priceDirection) + '\n' + 'Oscillator :' + str.tostring(lastMa) + ' ( ' + str.tostring(oscRatio) + ' ) - ' + str.tostring(oscillatorDirection)
                        priceDivergenceLabel = dr.Label.new(pricePoint, priceLabelText, priceTooltipText, priceLabelPropertiesMap.get(divergenceType))
                        oscillatorDivergenceLabel = dr.Label.new(oscillatorPoint, priceLabelText, priceTooltipText, oscillatorLabelPropertiesMap.get(divergenceType))
                        if allowedDivergenceTypes.get(divergenceType)
                            alert('Alert : ' + priceTooltipText, alert.freq_once_per_bar_close)
                        divergenceObject = DivergenceObject.new(priceDivergenceLine, oscillatorDivergenceLine,priceDivergenceLabel, oscillatorDivergenceLabel, pricePoint, divergenceType)
                        divergenceObject.delete()
                        divergenceObjects.push(divergenceObject.draw())
                        true
                    else
                        priceDivergenceLine.delete()
                        false
    divergenceType
ma = maType.ma(maLength)
oscillator = useExternalOscillator ? externalOscillator : oscillator(oscillatorType, length)
plot(oscillator, 'Oscillator')

oscillatorMap.put(bar_index, oscillator)
indicators = matrix.new<float>()
indicatorNames = array.from('Price', str.tostring(maType) +'-' +str.tostring(maLength), 'External Trend')

indicators.add_row(0, array.from(close, close, close))
indicators.add_row(1, array.from(ma, ma, ma))
indicators.add_row(2, array.from(externalTrendSignal, externalTrendSignal, externalTrendSignal))

var zg.Zigzag zigzag = zg.Zigzag.new(zigzagLength, 300, 0)
var ZigzagProperties properties = ZigzagProperties.new(textColor, trendMethodInt, repaint)
var divergenceObjects = array.new<DivergenceObject>()
zigzag.calculate(array.from(oscillator), indicators, indicatorNames)
currentDivergence = zigzag.divergence(divergenceObjects, properties)

for divergence in divergenceObjects
    direction = divergence.divergenceType == DivergenceType.BullishDivergence or divergence.divergenceType == DivergenceType.BullishHiddenDivergence ? 1 : -1
    if(not divergence.broken and divergence.pricePoint.price*direction > close*direction)
        divergence.broken := true

lastDivergence = divergenceObjects.size()==0 or divergenceObjects.last().broken? DivergenceType.None : divergenceObjects.last().divergenceType

plot(currentDivergence==DivergenceType.BullishDivergence?1:0, 'Bullish Divergence (Current)', color.green, display = display.data_window)
plot(currentDivergence==DivergenceType.BearishDivergence?1:0, 'Bearish Divergence (Current)', color.red, display = display.data_window)
plot(currentDivergence==DivergenceType.BullishHiddenDivergence?1:0, 'Bullish Hidden Divergence (Current)', color.lime, display = display.data_window)
plot(currentDivergence==DivergenceType.BearishHiddenDivergence?1:0, 'Bearish Hidden Divergence (Current)', color.red, display = display.data_window)

plot(lastDivergence==DivergenceType.BullishDivergence?1:0, 'Bullish Divergence (Last)', color.green, display = display.data_window)
plot(lastDivergence==DivergenceType.BearishDivergence?1:0, 'Bearish Divergence (Last)', color.red, display = display.data_window)
plot(lastDivergence==DivergenceType.BullishHiddenDivergence?1:0, 'Bullish Hidden Divergence (Last)', color.lime, display = display.data_window)
plot(lastDivergence==DivergenceType.BearishHiddenDivergence?1:0, 'Bearish Hidden Divergence (Last)', color.red, display = display.data_window)
````
