# ATR Exceedance Probability Model [LuxAlgo]

- url: https://www.tradingview.com/script/YIL56q9W-ATR-Exceedance-Probability-Model-LuxAlgo/
- type: indicator
- pine_id: PUB;84294000a55a40058cd26f05ec2451b2
- version: 1.0

## Description

The [b]Volatility Exceedance Probability Model (VEPM)[/b] indicator is a comprehensive statistical tool designed to quantify the significance of volatility spikes, determine the likelihood of trend continuation, and categorize market environments into specific regimes.

🔶 [b]USAGE[/b]

The indicator provides a multi-layered view of volatility, allowing traders to distinguish between standard market noise and statistically significant "exceedance" events.

🔹 [b]Oscillator Interpretation[/b]
The main oscillator plots the current exceedance frequency (the rate at which price or range breaches ATR-based thresholds) against a long-term baseline.
[list]
[*] [b]Bullish/Significant Glow:[/b] When the Z-Score of the frequency exceeds the sensitivity threshold, the oscillator glows green, indicating a high-probability volatility expansion.
[*] [b]Bearish/Normal Glow:[/b] When the frequency falls below the baseline, the oscillator shifts toward red, signaling a contraction in volatility.
[*] [b]Frequency Delta:[/b] The area between the current frequency and baseline frequency is filled to highlight the momentum of volatility expansion or exhaustion.
[/list]

🔹 [b]Chart Visuals & Regimes[/b]
The script overlays information directly on the price action to provide context:
[list]
[*] [b]ATR Bands:[/b] Dynamic bands based on the Average True Range act as the "exceedance" barrier.
[*] [b]Regime Boxes:[/b] The indicator automatically identifies "Quiet," "Normal," and "High Vol" regimes. These are visualized as colored boxes (defaulting to High Vol) to show the duration and range of specific volatility climates.
[*] [b]Significance Dots:[/b] Circles appear at the top of the chart to mark bars that have breached the volatility threshold.
[/list]

🔹 [b]Dashboard Metrics[/b]
A real-time dashboard provides quantitative data:
[list]
[*] [b]Exceedance Freq:[/b] The percentage of bars in the short-term window that breached the ATR levels.
[*] [b]Serial Break Prob:[/b] The historical probability that a breach will be followed by another breach (continuation).
[*] [b]Clustering Edge:[/b] The statistical advantage of volatility clustering; a positive value suggests that volatility is currently feeding on itself.
[/list]

🔶 [b]DETAILS[/b]

The VEPM operates on the principle that volatility is not constant but "clusters" in time. It uses the following logic to derive its metrics:

[list=1]
[*] [b]Exceedance Detection:[/b] It calculates whether the current price range (True Range) or price levels (High/Low) exceed a user-defined ATR multiplier. 
[*] [b]Statistical Z-Score:[/b] By comparing the current frequency of these breaches to a long-term baseline (200 bars by default), the model calculates a Z-Score to determine if the current activity is statistically "abnormal."
[*] [b]Continuation Probability:[/b] The model looks back at previous breaches and calculates how often they resulted in immediate follow-through, providing a "Serial Break" percentage.
[/list]

🔶 [b]SETTINGS[/b]

🔹 [b]Core Settings[/b]
[list]
[*] [b]ATR Length:[/b] The lookback period used for the Average True Range calculation.
[*] [b]ATR Multiplier:[/b] The threshold used to define what constitutes a "breach" or exceedance.
[*] [b]Breach Detection Method:[/b] Choose between comparing the bar's total range to ATR or checking if price levels exceed the previous bar's bands.
[/list]

🔹 [b]Statistical Windows[/b]
[list]
[*] [b]Short-Term Window:[/b] The period used to calculate the current exceedance frequency.
[*] [b]Baseline Window:[/b] The long-term period used to establish the "normal" mean of volatility frequency.
[*] [b]Z-Score Sensitivity:[/b] Determines the threshold for identifying statistically significant volatility spikes.
[/list]

🔹 [b]Visuals[/b]
[list]
[*] [b]Show ATR Bands:[/b] Toggles the visibility of the ATR-based levels on the chart.
[*] [b]Bands Mode:[/b] Determines if bands are offset from a central basis (SMA/EMA) or from the bar's High/Low.
[*] [b]Regime Box Options:[/b] Toggles background boxes for Quiet, Normal, or High Volatility regimes.
[/list]

🔹 [b]Dashboard[/b]
[list]
[*] [b]Dashboard:[/b] Enables or disables the on-screen information table.
[*] [b]Position/Size:[/b] Controls the location and scale of the dashboard UI.
[/list]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("ATR Exceedance Probability Model [LuxAlgo]", "LuxAlgo - ATR Prob Model", precision = 2)

//---------------------------------------------------------------------------------------------------------------------}
// Constants
//---------------------------------------------------------------------------------------------------------------------{
color DATA                    = #DBDBDB
color HEADERS                 = #808080
color BACKGROUND              = #161616
color BORDERS                 = #2E2E2E

string TOP_RIGHT              = 'Top Right'
string BOTTOM_RIGHT           = 'Bottom Right'
string BOTTOM_LEFT            = 'Bottom Left'

string TINY                   = 'Tiny'
string SMALL                  = 'Small'
string NORMAL                 = 'Normal'
string LARGE                  = 'Large'
string HUGE                   = 'Huge'

string DASHBOARD_GROUP        = 'Dashboard'

string dashboardTooltip       = 'Enable or disable the dashboard.'
string dashboardPositionTooltip= 'Select the dashboard location.'
string dashboardSizeTooltip   = 'Select the dashboard size.'

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
//---------------------------------------------------------------------------------------------------------------------{
int atrLen                    = input.int(14, "ATR Length", minval = 1, group = "Core Settings", tooltip = "Lookback for ATR calculation.")
float threshold               = input.float(1.5, "ATR Multiplier", minval = 0.1, step = 0.1, group = "Core Settings", tooltip = "Multiplier k for k*ATR threshold.")
string detectMethod           = input.string("Price vs Previous ATR Level", "Breach Detection Method", options = ["True Range vs ATR", "Price vs Previous ATR Level"], group = "Core Settings", tooltip = "True Range vs ATR: Current bar's total movement > ATR.\nPrice vs Previous ATR Level: Current High/Low exceeds levels set by the PREVIOUS bar.")

bool showBands                = input.bool(true, "Show ATR Bands on Chart", group = "Visuals")
string bandMode               = input.string("High/Low Offset", "Bands Mode", options = ["Central Basis", "High/Low Offset"], group = "Visuals", tooltip = "Central Basis: Basis +/- ATR. High/Low Offset: High + ATR and Low - ATR.")
string bandMethod             = input.string("SMA", "Bands Basis Method", options = ["SMA", "EMA", "WMA", "VWMA", "LSMA", "Price"], group = "Visuals")
int basisLen                  = input.int(20, "Bands Basis Length", minval = 1, group = "Visuals")

int shortWindow               = input.int(20, "Short-Term Window", minval = 5, group = "Statistical Windows")
int longWindow                = input.int(200, "Baseline Window", minval = 50, group = "Statistical Windows")
float confidence              = input.float(1.96, "Z-Score Sensitivity", minval = 0.1, step = 0.1, group = "Statistical Windows")

bool glowOn                   = input.bool(true, "Enable Visual Glows", group = "Visuals")
bool colorCandles             = input.bool(true, "Color Candles by Significance", group = "Visuals")

color bullColor               = input.color(#00ffbb, "Significance Color", group = "Style")
color bearColor               = input.color(#f23645, "Alert Color", group = "Style")
color neutColor               = input.color(#5b9cf6, "Normal Color", group = "Style")
color dimColor                = input.color(color.new(#607d8b, 75), "Dimmed Color", group = "Style")

bool dashboardInput           = input.bool(true, 'Dashboard', group = DASHBOARD_GROUP, tooltip = dashboardTooltip)
string dashboardPositionInput = input.string(TOP_RIGHT, 'Position', group = DASHBOARD_GROUP, tooltip = dashboardPositionTooltip, options = [TOP_RIGHT,BOTTOM_RIGHT,BOTTOM_LEFT])
string dashboardSizeInput     = input.string(SMALL, 'Size', group = DASHBOARD_GROUP, tooltip = dashboardSizeTooltip, options = [TINY,SMALL,NORMAL,LARGE,HUGE])

//---------------------------------------------------------------------------------------------------------------------}
// Functions / Methods
//---------------------------------------------------------------------------------------------------------------------{
var string parsedDashboardPosition = switch dashboardPositionInput
    TOP_RIGHT       => position.top_right
    BOTTOM_RIGHT    => position.bottom_right
    BOTTOM_LEFT     => position.bottom_left

var string parsedDashboardSize     = switch dashboardSizeInput
    TINY            => size.tiny
    SMALL           => size.small
    NORMAL          => size.normal
    LARGE           => size.large
    HUGE            => size.huge

cell(table t_able, int column, int row, string data, color text_col = #DBDBDB, string align = text.align_right, color background = na, float height = 0) => 
    t_able.cell(column, row, data, text_color = text_col, text_size = parsedDashboardSize, text_halign = align, bgcolor = background, height = height)

divider(table t_able, int row, int lastColumn) =>    
    string rowDivider = '━━━━━━━━━━━━━━'
    t_able.merge_cells(0, row, lastColumn, row)
    cell(t_able, 0, row, rowDivider, text_col = BORDERS, align = text.align_center, height = 0.5)

//---------------------------------------------------------------------------------------------------------------------}
// Calculations
//---------------------------------------------------------------------------------------------------------------------{
float tr    = ta.tr(true)
float atr   = ta.atr(atrLen)

// Basis for bands
float basis = switch bandMethod
    "SMA"   => ta.sma(close, basisLen)
    "EMA"   => ta.ema(close, basisLen)
    "WMA"   => ta.wma(close, basisLen)
    "VWMA"  => ta.vwma(close, basisLen)
    "LSMA"  => ta.linreg(close, basisLen, 0)
    "Price" => close
    => ta.sma(close, basisLen)

// Upper/Lower Bands (Current Bar)
float upper = bandMode == "Central Basis" ? basis + (atr * threshold) : high + (atr * threshold)
float lower = bandMode == "Central Basis" ? basis - (atr * threshold) : low - (atr * threshold)

// Core Detection Logic
bool isExceed = detectMethod == "True Range vs ATR" ? tr > (atr * threshold) : (high > upper[1] or low < lower[1])

// --- Statistical Logic ---
float exceedVal = isExceed ? 1.0 : 0.0
float currentFreq = ta.sma(exceedVal, shortWindow) * 100
float baselineFreq = ta.sma(exceedVal, longWindow) * 100

// Z-Score of frequency
float baselineMean = ta.sma(currentFreq, longWindow)
float baselineStd  = ta.stdev(currentFreq, longWindow)
float zScore       = (currentFreq - baselineMean) / (baselineStd > 0 ? baselineStd : na)

// Continuation Probability (Conditional Probability of a break given a previous break)
int countPrevExceed = 0
int countContinuation = 0
for i = 0 to shortWindow - 1
    if exceedVal[i+1] == 1.0
        countPrevExceed += 1
        if exceedVal[i] == 1.0
            countContinuation += 1

float probContinuation = countPrevExceed > 0 ? (float(countContinuation) / countPrevExceed) * 100 : 0.0

// "Clustering Edge": The increase in likelihood of a break when one just happened
float clusterEdge = probContinuation - currentFreq

// Regime Detection
float atrZ = (atr - ta.sma(atr, longWindow)) / math.max(ta.stdev(atr, longWindow), 1e-6)
string regime = atrZ > 1.0 ? "High Vol" : atrZ < -1.0 ? "Quiet" : "Normal"
color regimeColor = regime == "High Vol" ? bearColor : regime == "Quiet" ? bullColor : neutColor

//---------------------------------------------------------------------------------------------------------------------}
// Visualizations
//---------------------------------------------------------------------------------------------------------------------{
barcolor(colorCandles ? (zScore > confidence ? bullColor : isExceed ? neutColor : dimColor) : na)

// Primary Plots
plotBaseline = plot(baselineFreq, "Baseline Frequency", color.new(chart.fg_color, 70), 1, plot.style_linebr)
plotCurrent  = plot(currentFreq, "Current Frequency", zScore > confidence ? bullColor : zScore < -confidence ? bearColor : neutColor, 2)

// Frequency Delta Gradient Fill
fill(plotCurrent, plotBaseline, 
     top_value    = math.max(currentFreq, baselineFreq), 
     bottom_value = math.min(currentFreq, baselineFreq), 
     top_color    = currentFreq > baselineFreq ? color.new(bullColor, 50) : color.new(bearColor, 80), 
     bottom_color = currentFreq > baselineFreq ? color.new(bullColor, 80) : color.new(bearColor, 50), 
     title        = "Frequency Gradient Fill")

// Glowing Frequency Layers for seamless transition
plot(glowOn ? currentFreq : na, "Glow 1", color.new(zScore > confidence ? bullColor : zScore < -confidence ? bearColor : neutColor, 80), 4)
plot(glowOn ? currentFreq : na, "Glow 2", color.new(zScore > confidence ? bullColor : zScore < -confidence ? bearColor : neutColor, 90), 8)
plot(glowOn ? currentFreq : na, "Glow 3", color.new(zScore > confidence ? bullColor : zScore < -confidence ? bearColor : neutColor, 95), 12)

plot(probContinuation, "Continuation Likelihood", color.new(chart.fg_color, 0), 1, plot.style_circles, display = display.none)
hline(0, "Zero Line", color.gray, hline.style_dotted)

// ATR Bands Visualization
p_basis = plot(showBands ? basis : na, "Bands Basis", color.new(neutColor, 80), 1, plot.style_linebr, force_overlay = true)
p_upper = plot(showBands ? upper : na, "Upper Band", color.new(bullColor, 40), 1, plot.style_linebr, force_overlay = true)
p_lower = plot(showBands ? lower : na, "Lower Band", color.new(bearColor, 40), 1, plot.style_linebr, force_overlay = true)

fill(p_basis, p_upper, color.new(bullColor, 90), "Upper Band Fill")
fill(p_basis, p_lower, color.new(bearColor, 90), "Lower Band Fill")

// Overlay Markers
plotshape(zScore > confidence, "Significant Breach", shape.circle, location.top, bullColor, size = size.tiny, force_overlay = true)
plotshape(isExceed and not (zScore > confidence), "Normal Breach", shape.circle, location.top, color.new(neutColor, 50), size = size.tiny, force_overlay = true)

//---------------------------------------------------------------------------------------------------------------------}
// Dashboard
//---------------------------------------------------------------------------------------------------------------------{
var table dash = table.new(parsedDashboardPosition, 2, 9
     , bgcolor          = BACKGROUND    
     , border_width     = 0    
     , frame_color      = BORDERS
     , frame_width      = 1
     , force_overlay    = false)

if barstate.islast and bar_index >= longWindow and dashboardInput
    dash.merge_cells(0, 0, 1, 0)
    cell(dash, 0, 0, 'ATR Prob Model', text_col = DATA, align = text.align_center)
    
    divider(dash, 1, 1)
    
    color fColor = zScore > confidence ? bullColor : zScore < -confidence ? bearColor : neutColor
    cell(dash, 0, 2, 'Exceedance Freq', text_col = HEADERS, align = text.align_left)
    cell(dash, 1, 2, str.format("{0,number,#.##}%", currentFreq), text_col = fColor)
    
    divider(dash, 3, 1)
    
    color pColor = probContinuation > currentFreq ? bullColor : DATA
    cell(dash, 0, 4, 'Serial Break Prob', text_col = HEADERS, align = text.align_left)
    cell(dash, 1, 4, str.format("{0,number,#.##}%", probContinuation), text_col = pColor)
    
    divider(dash, 5, 1)
    
    color cColor = clusterEdge > 0 ? bullColor : bearColor
    cell(dash, 0, 6, 'Clustering Edge', text_col = HEADERS, align = text.align_left)
    cell(dash, 1, 6, str.format("{0,number,#.##}%", clusterEdge), text_col = cColor)
    
    divider(dash, 7, 1)
    
    color zColor = math.abs(zScore) > confidence ? bullColor : DATA
    cell(dash, 0, 8, 'Z-Score', text_col = HEADERS, align = text.align_left)
    cell(dash, 1, 8, str.format("{0,number,#.##}", zScore), text_col = zColor)

//---------------------------------------------------------------------------------------------------------------------}
````
