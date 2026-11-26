# MACD + Volume

- url: https://www.tradingview.com/script/QgKK26n8/
- type: indicator
- pine_id: PUB;1c36247a9c28465ebcdc4d103b622fdd
- version: 6.0

## Description

MACD + Volume Indicator

This composite tool integrates three distinct technical indicators commonly used in intraday and swing trading analysis:

Moving Average Convergence Divergence (MACD):  
A momentum oscillator derived from moving averages. It measures both trend direction and momentum by comparing short-term and long-term moving averages. The indicator allows customization of oscillator and signal line types, supporting SMA and EMA (default), as well as RMA, WMA, and VWMA.

Cumulative Volume Delta (CVD):  
A volume-based indicator that tracks the cumulative difference between buying and selling pressure. By default, it uses diamond markers to represent whether the cumulative delta is trending upward or downward. This component can be disabled at any time if the user prefers.

Up/Down Volume:  
Another volume-based measure that highlights bullish versus bearish volume shifts. By default, it employs triangle markers to indicate whether the volume delta is positive (bullish) or negative (bearish). This component can also be disabled at any time according to user preference.

## Source Code

````pine
//@version=6
indicator("Moving Average Convergence Divergence + Volume", "MACD + Volume by @J777", timeframe = "", timeframe_gaps = true)
import TradingView/ta/12

// Inputs
float  sourceInput  = input.source(close, "Source")
int    fastLenInput = input.int(12, "Fast length",   1)
int    slowLenInput = input.int(26, "Slow length",   1)
int    sigLenInput  = input.int(9,  "Signal length", 1)

    // Added RMA, WMA, VWMA
string oscTypeInput = input.string("EMA", "Oscillator MA type", ["EMA", "SMA", "RMA", "WMA", "VWMA"], display = display.none)
string sigTypeInput = input.string("EMA", "Signal MA type",     ["EMA", "SMA", "RMA", "WMA", "VWMA"], display = display.none)
deltashow = input.bool(defval = true, title = "Show Delta Volume (Up/Down indicator)")
cvdshow = input.bool(defval = true, title = "Show CVD")
volanalysis = input.int(12,"Volume Analysis Length",2)
volratio = input.float(1.11, "Volume Ratio",1.0)
histoTooltip = "CVD indicator: Changes color if the body size of the bar (excluding the wick) is greater than the average of previous periods."
 + "\n\nUp/Down Volume Indicator: Changes color if the absolute delta value (difference between the last volume and the opening volume) is greater than the average of previous periods."
 + "\n\nMACD: Changes color if the conditions of the CVD and Up/Down indicators are met, and additionally, the total volume of the period is greater than the average of previous periods."
 + "\n\nAll three indicators operate based on the values of Volume Analysis Length and Volume Ratio. The default colors to display these volume changes are lime and maroon."
chhisto = input.string(defval = 'none', title = "Change MACD color on high volume", options = ['MACD', 'Signal', 'Histogram', 'none'], tooltip = histoTooltip)
anchorInput = input.timeframe("1D", "Anchor period")
lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe."
 + " \n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(false, "Use custom timeframe", tooltip = lowerTimeframeTooltip)
lowerTimeframeInput = input.timeframe("1", "Timeframe", active = useCustomTimeframeInput)
ma1show = input.bool(defval = false, title = 'Show MA1')
ma1col = input.color(defval = #b8b8b8, title = 'Color')
ma1style = input.string(defval = 'Solid', title = 'Line Style', options = ['Solid', 'Dashed', 'Dotted'])
ma1type = input.string("VWMA", "Type", ["EMA", "SMA", "RMA", "WMA", "VWMA"], display = display.none)
ma1len = input.int(defval = 12, title = 'Length', minval = 1)
ma1src  = input.source(close, "Source")
ma1(ma1src, ma1len, ma1type) =>
    switch ma1type
        "SMA"       => ta.sma(ma1src,  ma1len) 
        "EMA"       => ta.ema(ma1src,  ma1len) 
        "RMA"       => ta.rma(ma1src,  ma1len) 
        "WMA"       => ta.wma(ma1src,  ma1len) 
        "VWMA"      => ta.vwma(ma1src,  ma1len) 
        => na

var lowerTimeframe = switch
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"

// @function    Calculates an SMA, EMA, RMA, WMA or VWMA of a `source` series.
ma(float source, int length, simple string maType) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)
        "RMA" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        
// Calculate and plot the MACD, signal, and histogram values.
float maFast = ma(sourceInput, fastLenInput, oscTypeInput)
float maSlow = ma(sourceInput, slowLenInput, oscTypeInput)
float macd   = maFast - maSlow
float signal = ma(macd, sigLenInput, sigTypeInput)
float hist   = macd - signal
color hColor = hist >= 0 ? hist > hist[1] ? #26a69a : #b2dfdb : hist > hist[1] ? #ffcdd2 :#ff5252

[upVolume, downVolume, delta] = ta.requestUpAndDownVolume(lowerTimeframe)
[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe, anchorInput)

// Volume analysis
vol_sma = ta.sma(volume, volanalysis)
vol_ratio = volume / vol_sma // Current volume vs average

//Up/Down Volume delta size vs average
updownds = math.abs(delta)
absdelsma = ta.sma(updownds, volanalysis)
delsmaavg = updownds / absdelsma

//CVD size vs average
float CVDsize = lastVolume > openVolume ? lastVolume - openVolume : openVolume - lastVolume
bool CVDgreen = lastVolume > openVolume ? true : false
CVDssma = ta.sma(CVDsize, volanalysis)
CVDsavg = CVDsize / CVDssma

bool isupdelta = delta > 0

// Calculates color based on volume average
color colCVD = CVDgreen == true ? CVDsavg > volratio ? color.lime : color.teal : CVDsavg > volratio ? color.maroon : color.red
color coldelta = isupdelta ? delsmaavg > volratio ? color.lime : color.teal : delsmaavg > volratio ? color.maroon : color.red

//MA1 style
var ma1_style = ma1style == 'Solid' ? line.style_solid : ma1style == 'Dashed' ? line.style_dashed : line.style_dotted

//Changes MACD histogram color
bool colorMACD = false
if vol_ratio > volratio and chhisto != 'none' and CVDsavg > volratio and delsmaavg > volratio
    colorMACD := true

hline(0, "Zero", #787b8680)
plot(hist, "Histogram", color = chhisto == 'Histogram' ? colorMACD == true ? colCVD : hColor : hColor, style = plot.style_columns)
plot(macd, "MACD", color = chhisto == 'MACD' ? colorMACD == true ? colCVD : #2962FF : #2962FF)
plot(signal, "Signal line", color = chhisto == 'Signal' ? colorMACD == true ? colCVD : #ff6d00 : #ff6d00)
plotshape(deltashow ? delta : na, "Delta", shape.cross, location.bottom, coldelta, size = size.tiny, format = format.volume)
plotshape(cvdshow ? lastVolume : na, "CVD", shape.xcross, location.bottom, colCVD, size = size.tiny, format = format.volume)
plot(ma1show ? ma1(ma1src, ma1len, ma1type) : na, color = ma1show ? ma1col : na, force_overlay = true, linestyle = ma1style == 'Solid' ? plot.linestyle_solid : ma1style == 'Dashed' ? plot.linestyle_dashed : plot.linestyle_dotted)

var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")


// Create alert conditions.
alertcondition(hist[1] >= 0 and hist < 0, "Rising to falling", "MACD histogram switched from a rising to falling state")
alertcondition(hist[1] <= 0 and hist > 0, "Falling to rising", "MACD histogram switched from a falling to rising state")
````
