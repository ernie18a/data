# Rolling vwap

- url: https://www.tradingview.com/script/KJ3eZ2us/
- type: indicator
- pine_id: PUB;32006e5f81cb44239b92fec5d239f83d
- version: 1.0

## Description

The Rolling VWAP is a dynamic volume-weighted average price indicator calculated over a continuously moving lookback window.

Unlike traditional session-based VWAP, which resets at the beginning of each trading session, or anchored VWAP, which begins from a fixed reference point, Rolling VWAP continuously updates its calculation as new data is introduced and older data is removed from the selected window.

This structure allows the indicator to represent the market’s more recent volume-weighted equilibrium and adapt dynamically to changes in price and traded volume.

Rolling VWAP can be used as a reference for identifying short-term fair value, directional bias, and changes in market acceptance. Price trading persistently above the Rolling VWAP may indicate acceptance of higher value, while sustained trading below it may suggest acceptance of lower value.

The slope and positioning of the Rolling VWAP can also provide information about the development of market structure. A rising Rolling VWAP reflects an upward shift in volume-weighted value, while a declining Rolling VWAP reflects a downward shift. A relatively flat VWAP may indicate a more balanced or rotational market environment.

Deviations between price and the Rolling VWAP can help visualize how far the market has moved away from its recent volume-weighted mean. Repeated interaction with the VWAP may also highlight areas where price is rotating around, accepting, or rejecting recently established value.

By using a rolling calculation rather than a fixed session or anchor, the indicator maintains the core principle of VWAP while providing a more adaptive measure of recent market value.

## Source Code

````pine
//@version=6
indicator(title = 'VWAP+', shorttitle = 'VWAP+', overlay = true, max_bars_back = 4999, max_polylines_count = 100, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

import PineCoders/ConditionalAverages/1 as pc

VWAP_Ctl = 'VWAP'
// VWAP #5 Settings
VWAP5_Settings = 'VWAP #5 Settings'
VWAP5_Ctl = input(false, title = '', group = VWAP_Ctl, inline = VWAP5_Settings)
Anchor5 = input.string(defval = 'Year', title = '', group = VWAP_Ctl, inline = VWAP5_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'])
VWAP5_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = VWAP_Ctl, inline = VWAP5_Settings)
Bands5_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = VWAP_Ctl, inline = VWAP5_Settings)
VWAP5_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = VWAP_Ctl, inline = VWAP5_Settings)

// VWAP #1 Settings
VWAP1_Settings = 'VWAP #1 Settings'
VWAP1_Ctl = input(false, title = '', group = VWAP_Ctl, inline = VWAP1_Settings)
Anchor1 = input.string(defval = 'Quarter', title = '', group = VWAP_Ctl, inline = VWAP1_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'])
VWAP1_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = VWAP_Ctl, inline = VWAP1_Settings)
Bands1_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = VWAP_Ctl, inline = VWAP1_Settings)
VWAP1_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = VWAP_Ctl, inline = VWAP1_Settings)

// VWAP #2 Settings
VWAP2_Settings = 'VWAP #2 Settings'
VWAP2_Ctl = input(false, title = '', group = VWAP_Ctl, inline = VWAP2_Settings)
Anchor2 = input.string(defval = 'Month', title = '', group = VWAP_Ctl, inline = VWAP2_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'])
VWAP2_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = VWAP_Ctl, inline = VWAP2_Settings)
Bands2_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = VWAP_Ctl, inline = VWAP2_Settings)
VWAP2_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = VWAP_Ctl, inline = VWAP2_Settings)

// VWAP #3 Settings
VWAP3_Settings = 'VWAP #3 Settings'
VWAP3_Ctl = input(false, title = '', group = VWAP_Ctl, inline = VWAP3_Settings)
Anchor3 = input.string(defval = 'Week', title = '', group = VWAP_Ctl, inline = VWAP3_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'])
VWAP3_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = VWAP_Ctl, inline = VWAP3_Settings)
Bands3_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = VWAP_Ctl, inline = VWAP3_Settings)
VWAP3_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = VWAP_Ctl, inline = VWAP3_Settings)

// VWAP #4 Settings
VWAP4_Settings = 'VWAP #4 Settings'
VWAP4_Ctl = input(false, title = '', group = VWAP_Ctl, inline = VWAP4_Settings)
Anchor4 = input.string(defval = 'Day', title = '', group = VWAP_Ctl, inline = VWAP4_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'])
VWAP4_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = VWAP_Ctl, inline = VWAP4_Settings)
Bands4_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = VWAP_Ctl, inline = VWAP4_Settings)
VWAP4_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = VWAP_Ctl, inline = VWAP4_Settings)

Previous_VWAP = 'Previous VWAP'
Pday_Ctl = input(false, title = '', group = Previous_VWAP, inline = 'day')
Pday_Val = input.string(defval = 'pDay', title = '', group = Previous_VWAP, inline = 'day', options = ['pDay'])
Pday_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = Previous_VWAP, inline = 'day')

Pyear_Ctl = input(false, title = '', group = Previous_VWAP, inline = 'day')
Pyear_Val = input.string(defval = 'pYear', title = '', group = Previous_VWAP, inline = 'day', options = ['pYear'])
Pyear_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = Previous_VWAP, inline = 'day')

Pweek_Ctl = input(false, title = '', group = Previous_VWAP, inline = 'week')
Pweek_Val = input.string(defval = 'pWeek', title = '', group = Previous_VWAP, inline = 'week', options = ['pWeek'])
Pweek_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = Previous_VWAP, inline = 'week')

Ppweek_Ctl = input(false, title = '', group = Previous_VWAP, inline = 'week')
Ppweek_Val = input.string(defval = 'ppWeek', title = '', group = Previous_VWAP, inline = 'week', options = ['ppWeek'])
Ppweek_Col = input.color(defval = color.rgb(91, 156, 246, 60), title = '', group = Previous_VWAP, inline = 'week')

Pmonth_Ctl = input(false, title = '', group = Previous_VWAP, inline = 'month')
Pmonth_Val = input.string(defval = 'pMonth', title = '', group = Previous_VWAP, inline = 'month', options = ['pMonth'])
Pmonth_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = Previous_VWAP, inline = 'month')

Ppmonth_Ctl = input(false, title = '', group = Previous_VWAP, inline = 'month')
Ppmonth_Val = input.string(defval = 'ppMonth', title = '', group = Previous_VWAP, inline = 'month', options = ['ppMonth'])
Ppmonth_Col = input.color(defval = color.rgb(91, 156, 246, 60), title = '', group = Previous_VWAP, inline = 'month')

Pquarter_Ctl = input(false, title = '', group = Previous_VWAP, inline = 'quarter')
Pquarter_Val = input.string(defval = 'pQuarter', title = '', group = Previous_VWAP, inline = 'quarter', options = ['pQuarter'])
Pquarter_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = Previous_VWAP, inline = 'quarter')

Ppquarter_Ctl = input(false, title = '', group = Previous_VWAP, inline = 'quarter')
Ppquarter_Val = input.string(defval = 'ppQuarter', title = '', group = Previous_VWAP, inline = 'quarter', options = ['ppQuarter'])
Ppquarter_Col = input.color(defval = color.rgb(91, 156, 246, 60), title = '', group = Previous_VWAP, inline = 'quarter')

int MS_IN_DAY = 60 * 1000 * 60 * 24

string GRP1 = 'Rolling VWAP'
bool enable7 = input.bool(false, '', group = GRP1, inline = '1')
int pdaysInput7 = input.int(7, '', group = GRP1, inline = '1', options = [1, 3, 5, 7, 14, 21, 28, 30, 60, 90, 182, 365]) * MS_IN_DAY
color RVWAP1_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'RVWAP', group = GRP1, inline = '1')
color RBands1_Col = input.color(defval = color.rgb(255, 255, 255, 90), title = 'Bands', group = GRP1, inline = '1')
color RVWAP1_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = GRP1, inline = '1')

bool enable30 = input.bool(false, '', group = GRP1, inline = '2')
int pdaysInput30 = input.int(30, '', group = GRP1, inline = '2', options = [1, 3, 5, 7, 14, 21, 28, 30, 60, 90, 182, 365]) * MS_IN_DAY
color RVWAP2_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'RVWAP', group = GRP1, inline = '2')
color RBands2_Col = input.color(defval = color.rgb(255, 255, 255, 90), title = 'Bands', group = GRP1, inline = '2')
color RVWAP2_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = GRP1, inline = '2')

bool enable90 = input.bool(false, '', group = GRP1, inline = '3')
int pdaysInput90 = input.int(90, '', group = GRP1, inline = '3', options = [1, 3, 5, 7, 14, 21, 28, 30, 60, 90, 182, 365]) * MS_IN_DAY
color RVWAP3_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'RVWAP', group = GRP1, inline = '3')
color RBands3_Col = input.color(defval = color.rgb(255, 255, 255, 90), title = 'Bands', group = GRP1, inline = '3')
color RVWAP3_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = GRP1, inline = '3')

bool enable365 = input.bool(false, '', group = GRP1, inline = '4')
int pdaysInput365 = input.int(365, '', group = GRP1, inline = '4', options = [1, 3, 5, 7, 14, 21, 28, 30, 60, 90, 182, 365]) * MS_IN_DAY
color RVWAP4_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'RVWAP', group = GRP1, inline = '4')
color RBands4_Col = input.color(defval = color.rgb(255, 255, 255, 90), title = 'Bands', group = GRP1, inline = '4')
color RVWAP4_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = GRP1, inline = '4')

string GRP2 = 'Rolling VWAP Std Bands'
bool aggr = input.bool(defval = true, title = 'Use Aggregated Data', group = GRP2, inline ="1")
string devMode = input.string(defval = 'Symmetrical', title = 'Deviation Bands', group = GRP2, inline = '2', options = ['Symmetrical', 'Standard'])
float stdevMult = input.float(0.5, '', group = GRP2, inline = '2', minval = 0.5, step = 0.5)
i_sym1 = input.bool(true, '', inline='3', group=GRP2)
i_sym2 = input.bool(true, '', inline='4', group=GRP2)
i_sym3 = input.bool(false, '', inline='5', group=GRP2)
i_sym4 = input.bool(false, '', inline='6', group=GRP2)

i_sym1_ticker = input.symbol('BINANCE:BTCUSDT', '', inline='3', group=GRP2)
i_sym2_ticker = input.symbol('COINBASE:BTCUSD', '', inline='4', group=GRP2)
i_sym3_ticker = input.symbol('BYBIT:BTCUSDT', '', inline='5', group=GRP2)
i_sym4_ticker = input.symbol('OKX:BTCUSDT', '', inline='6', group=GRP2)

float Src = hlc3
float finvol = 0
int right_bar = 0
color label_color_setting = color.new(#ecf008, 100)
string format_level = '#.####'
string DEFAULT_LINE_STYLE = line.style_dotted
string DEFAULT_LABEL_STYLE = label.style_label_left

// Function to calculate new period
f_is_new_period(anchor) =>
    switch anchor
        'Day' => timeframe.change('D')
        'Week' => timeframe.change('W')
        'Month' => timeframe.change('M')
        'Quarter' => timeframe.change('3M')
        'Year' => timeframe.change('12M')
        => false

// Function to calculate VWAP and Bands
f_calculate_vwap(src, is_active, is_new_period) =>
    if not is_active
        [na, na, na]

    ta.vwap(src, is_new_period, 1)

// VWAP Calculations
[vwap1, band1_upper, band1_lower] = f_calculate_vwap(Src, VWAP1_Ctl, f_is_new_period(Anchor1))
[vwap2, band2_upper, band2_lower] = f_calculate_vwap(Src, VWAP2_Ctl, f_is_new_period(Anchor2))
[vwap3, band3_upper, band3_lower] = f_calculate_vwap(Src, VWAP3_Ctl, f_is_new_period(Anchor3))
[vwap4, band4_upper, band4_lower] = f_calculate_vwap(Src, VWAP4_Ctl, f_is_new_period(Anchor4))
[vwap5, band5_upper, band5_lower] = f_calculate_vwap(Src, VWAP5_Ctl, f_is_new_period(Anchor5))

// Plot VWAP and Bands
vwap_plot1 = plot(VWAP1_Ctl ? vwap1 : na, color=VWAP1_Col)
lowerBand_1 = plot(VWAP1_Ctl ? band1_lower : na, color=Bands1_Col)
upperBand_1 = plot(VWAP1_Ctl ? band1_upper : na, color=Bands1_Col)
fill(upperBand_1, lowerBand_1, color=VWAP1_Bgc)

vwap_plot2 = plot(VWAP2_Ctl ? vwap2 : na, color=VWAP2_Col)
lowerBand_2 = plot(VWAP2_Ctl ? band2_lower : na, color=Bands2_Col)
upperBand_2 = plot(VWAP2_Ctl ? band2_upper : na, color=Bands2_Col)
fill(upperBand_2, lowerBand_2, color=VWAP2_Bgc)

vwap_plot3 = plot(VWAP3_Ctl ? vwap3 : na, color=VWAP3_Col)
lowerBand_3 = plot(VWAP3_Ctl ? band3_lower : na, color=Bands3_Col)
upperBand_3 = plot(VWAP3_Ctl ? band3_upper : na, color=Bands3_Col)
fill(upperBand_3, lowerBand_3, color=VWAP3_Bgc)

vwap_plot4 = plot(VWAP4_Ctl ? vwap4 : na, color=VWAP4_Col)
lowerBand_4 = plot(VWAP4_Ctl ? band4_lower : na, color=Bands4_Col)
upperBand_4 = plot(VWAP4_Ctl ? band4_upper : na, color=Bands4_Col)
fill(upperBand_4, lowerBand_4, color=VWAP4_Bgc)

vwap_plot5 = plot(VWAP5_Ctl ? vwap5 : na, color=VWAP5_Col)
lowerBand_5 = plot(VWAP5_Ctl ? band5_lower : na, color=Bands5_Col)
upperBand_5 = plot(VWAP5_Ctl ? band5_upper : na, color=Bands5_Col)
fill(upperBand_5, lowerBand_5, color=VWAP5_Bgc)

// Function to request volume
f_volume(_ticker) =>
    request.security(_ticker, timeframe.period, volume)

if aggr == true
    v1 = (i_sym1 ? f_volume(i_sym1_ticker) : 0)
    v2 = (i_sym2 ? f_volume(i_sym2_ticker) : 0)
    v3 = (i_sym3 ? f_volume(i_sym3_ticker) : 0)
    v4 = (i_sym4 ? f_volume(i_sym4_ticker) : 0)

    finvol := v1+v2+v3+v4
else
    finvol := volume

// Function to calculate rolling VWAP
calculateRollingVWAP(int period) =>
    float sumSrcVol = pc.totalForTimeWhen(Src * finvol, period, true)
    float sumVol = pc.totalForTimeWhen(finvol, period, true)
    float sumSrcSrcVol = pc.totalForTimeWhen(finvol * math.pow(Src, 2), period, true)
    float rollingVWAP = sumSrcVol / sumVol
    float variance = sumSrcSrcVol / sumVol - math.pow(rollingVWAP, 2)
    variance := math.max(0, variance)
    float stDev = math.sqrt(variance)
    float upperBand = rollingVWAP + (devMode == 'Standard' ? stdevMult : stdevMult / 100) * (devMode == 'Standard' ? stDev : rollingVWAP)
    float lowerBand = rollingVWAP - (devMode == 'Standard' ? stdevMult : stdevMult / 100) * (devMode == 'Standard' ? stDev : rollingVWAP)
    [rollingVWAP, upperBand, lowerBand]

// Calculating the rolling VWAP for each period
[rollingVWAP7, upperBand7, lowerBand7] = calculateRollingVWAP(pdaysInput7)
[rollingVWAP30, upperBand30, lowerBand30] = calculateRollingVWAP(pdaysInput30)
[rollingVWAP90, upperBand90, lowerBand90] = calculateRollingVWAP(pdaysInput90)
[rollingVWAP365, upperBand365, lowerBand365] = calculateRollingVWAP(pdaysInput365)

// Plotting the VWAP and bands for each enabled period
plot(enable7 ? rollingVWAP7 : na, '7-Day VWAP', RVWAP1_Col, linewidth = 1)
plot(enable30 ? rollingVWAP30 : na, '30-Day VWAP', RVWAP2_Col, linewidth = 1)
plot(enable90 ? rollingVWAP90 : na, '90-Day VWAP', RVWAP3_Col, linewidth = 1)
plot(enable365 ? rollingVWAP365 : na, '365-Day VWAP', RVWAP4_Col, linewidth = 1)

// Plot the bands for each enabled period
p1_7 = plot(enable7 ? upperBand7 : na, color = RBands1_Col)
p2_7 = plot(enable7 ? lowerBand7 : na, color = RBands1_Col)
fill(p1_7, p2_7, RVWAP1_Bgc)

p1_30 = plot(enable30 ? upperBand30 : na, color = RBands2_Col)
p2_30 = plot(enable30 ? lowerBand30 : na, color = RBands2_Col)
fill(p1_30, p2_30, RVWAP2_Bgc)

p1_90 = plot(enable90 ? upperBand90 : na, color = RBands3_Col)
p2_90 = plot(enable90 ? lowerBand90 : na, color = RBands3_Col)
fill(p1_90, p2_90, RVWAP3_Bgc)

p1_365 = plot(enable365 ? upperBand365 : na, color = RBands4_Col)
p2_365 = plot(enable365 ? lowerBand365 : na, color = RBands4_Col)
fill(p1_365, p2_365, RVWAP4_Bgc)

var float lastdailyLower = na
var float lastdailyUpper = na
var int thisDayStart = na
var float lastdailyPOC = na

var int thisWeekStart = na
var float lastWeeklyLower = na
var float lastWeeklyUpper = na
var int lastWeeklyStart = na
var float lastWeeklyPOC = na

var float lastlastWeeklyLower = na
var float lastlastWeeklyUpper = na
var float lastlastWeeklyPOC = na

var int thisMonthStart = na
var float lastMonthlyLower = na
var float lastMonthlyUpper = na
var int lastMonthlyStart = na
var float lastMonthlyPOC = na

var float lastlastMonthlyLower = na
var float lastlastMonthlyUpper = na
var float lastlastMonthlyPOC = na

var int thisQuarterStart = na
var float lastQuarterlyLower = na
var float lastQuarterlyUpper = na
var int lastQuarterlyStart = na
var float lastQuarterlyPOC = na

var float lastlastQuarterlyLower = na
var float lastlastQuarterlyUpper = na
var float lastlastQuarterlyPOC = na

var int thisYearStart = na
var float lastYearlyLower = na
var float lastYearlyUpper = na
var int lastYearlyStart = na
var float lastYearlyPOC = na

[yearlyVWAP, yearlyUpper, yearlyLower] = ta.vwap(Src, timeframe.change('12M'), 1)
[quarterlyVWAP, quarterlyUpper, quarterlyLower] = ta.vwap(Src, timeframe.change('3M'), 1)
[monthlyVWAP, monthlyUpper, monthlyLower] = ta.vwap(Src, timeframe.change('M'), 1)
[weeklyVWAP, weeklyUpper, weeklyLower] = ta.vwap(Src, timeframe.change('W'), 1)
[dailyVWAP, dailyUpper, dailyLower] = ta.vwap(Src, timeframe.change('D'), 1)

if timeframe.change('3M')
    lastlastQuarterlyLower := lastQuarterlyLower
    lastlastQuarterlyUpper := lastQuarterlyUpper
    lastlastQuarterlyPOC := lastQuarterlyPOC
    lastQuarterlyLower := quarterlyLower[1]
    lastQuarterlyUpper := quarterlyUpper[1]
    lastQuarterlyStart := thisQuarterStart
    lastQuarterlyPOC := quarterlyVWAP[1]
    thisQuarterStart := bar_index
    lastQuarterlyPOC

if timeframe.change('M')
    lastlastMonthlyLower := lastMonthlyLower
    lastlastMonthlyUpper := lastMonthlyUpper
    lastlastMonthlyPOC := lastMonthlyPOC
    lastMonthlyLower := monthlyLower[1]
    lastMonthlyUpper := monthlyUpper[1]
    lastMonthlyStart := thisMonthStart
    lastMonthlyPOC := monthlyVWAP[1]
    thisMonthStart := bar_index
    lastMonthlyPOC

if timeframe.change('W')
    lastlastWeeklyLower := lastWeeklyLower
    lastlastWeeklyUpper := lastWeeklyUpper
    lastlastWeeklyPOC := lastWeeklyPOC
    lastWeeklyLower := weeklyLower[1]
    lastWeeklyUpper := weeklyUpper[1]
    lastWeeklyStart := thisWeekStart
    lastWeeklyPOC := weeklyVWAP[1]
    thisWeekStart := bar_index
    lastWeeklyPOC

if timeframe.change('D')
    lastdailyLower := dailyLower[1]
    lastdailyUpper := dailyUpper[1]
    thisDayStart := bar_index
    lastdailyPOC := dailyVWAP[1]
    lastdailyPOC

if timeframe.change("12M")
    lastYearlyLower := yearlyLower[1]
    lastYearlyUpper := yearlyUpper[1]
    lastYearlyPOC :=  yearlyVWAP[1]
    thisYearStart := bar_index

if barstate.islast
    right_bar := bar_index + 21
    if Pday_Ctl
        var pDayBox = box.new(left = thisDayStart, right = right_bar, top = lastdailyUpper, bottom = lastdailyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(Pday_Col, 95))
        var pDayLine = line.new(x1 = thisDayStart, y1 = lastdailyPOC, x2 = right_bar, y2 = lastdailyPOC, color = color.new(Pday_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pDayLowerLabel = label.new(x = right_bar, y = lastdailyLower, text = 'pd VWAP -1', tooltip = str.tostring(lastdailyLower, format_level), color = label_color_setting, textcolor = color.new(Pday_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pDayUpperLabel = label.new(x = right_bar, y = lastdailyUpper, text = 'pd VWAP +1', tooltip = str.tostring(lastdailyUpper, format_level), color = label_color_setting, textcolor = color.new(Pday_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pDayPOCLabel = label.new(x = right_bar, y = lastdailyPOC, text = 'pd VWAP', tooltip = str.tostring(lastdailyPOC, format_level), color = label_color_setting, textcolor = color.new(Pday_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Pyear_Ctl
        var pYearBox = box.new(left = thisYearStart, right = right_bar, top = lastYearlyUpper, bottom = lastYearlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(Pyear_Col, 95))
        var pYearLine = line.new(x1 = thisYearStart, y1 = lastYearlyPOC, x2 = right_bar, y2 = lastYearlyPOC, color = color.new(Pyear_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pYearLowerLabel = label.new(x = right_bar, y = lastYearlyLower, text = 'py VWAP -1', tooltip = str.tostring(lastYearlyLower, format_level), color = label_color_setting, textcolor = color.new(Pyear_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pYearUpperLabel = label.new(x = right_bar, y = lastYearlyUpper, text = 'py VWAP +1', tooltip = str.tostring(lastYearlyUpper, format_level), color = label_color_setting, textcolor = color.new(Pyear_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pYearPOCLabel = label.new(x = right_bar, y = lastYearlyPOC, text = 'py VWAP', tooltip = str.tostring(lastYearlyPOC, format_level), color = label_color_setting, textcolor = color.new(Pyear_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Pweek_Ctl
        var pWeekBox = box.new(left = thisWeekStart, right = right_bar, top = lastWeeklyUpper, bottom = lastWeeklyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(Pweek_Col, 95))
        var pWeekLine = line.new(x1 = thisWeekStart, y1 = lastWeeklyPOC, x2 = right_bar, y2 = lastWeeklyPOC, color = color.new(Pweek_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pWeekLowerLabel = label.new(x = right_bar, y = lastWeeklyLower, text = 'pw VWAP -1', tooltip = str.tostring(lastWeeklyLower, format_level), color = label_color_setting, textcolor = color.new(Pweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pWeekUpperLabel = label.new(x = right_bar, y = lastWeeklyUpper, text = 'pw VWAP +1', tooltip = str.tostring(lastWeeklyUpper, format_level), color = label_color_setting, textcolor = color.new(Pweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pWeekPOCLabel = label.new(x = right_bar, y = lastWeeklyPOC, text = 'pw VWAP', tooltip = str.tostring(lastWeeklyPOC, format_level), color = label_color_setting, textcolor = color.new(Pweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Ppweek_Ctl
        var ppWeekBox = box.new(left = lastWeeklyStart, right = right_bar, top = lastlastWeeklyUpper, bottom = lastlastWeeklyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(Ppweek_Col, 95))
        var ppWeekLine = line.new(x1 = lastWeeklyStart, y1 = lastlastWeeklyPOC, x2 = right_bar, y2 = lastlastWeeklyPOC, color = color.new(Ppweek_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var ppWeekLowerLabel = label.new(x = right_bar, y = lastlastWeeklyLower, text = 'ppw VWAP -1', tooltip = str.tostring(lastlastWeeklyLower, format_level), color = label_color_setting, textcolor = color.new(Ppweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppWeekUpperLabel = label.new(x = right_bar, y = lastlastWeeklyUpper, text = 'ppw VWAP +1', tooltip = str.tostring(lastlastWeeklyUpper, format_level), color = label_color_setting, textcolor = color.new(Ppweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppWeekPOCLabel = label.new(x = right_bar, y = lastlastWeeklyPOC, text = 'ppw VWAP', tooltip = str.tostring(lastlastWeeklyPOC, format_level), color = label_color_setting, textcolor = color.new(Ppweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Pmonth_Ctl
        var pMonthBox = box.new(left = thisMonthStart, right = right_bar, top = lastMonthlyUpper, bottom = lastMonthlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(Pmonth_Col, 95))
        var pMonthLine = line.new(x1 = thisMonthStart, y1 = lastMonthlyPOC, x2 = right_bar, y2 = lastMonthlyPOC, color = color.new(Pmonth_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pMonthLowerLabel = label.new(x = right_bar, y = lastMonthlyLower, text = 'pm VWAP -1', tooltip = str.tostring(lastMonthlyLower, format_level), color = label_color_setting, textcolor = color.new(Pmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pMonthUpperLabel = label.new(x = right_bar, y = lastMonthlyUpper, text = 'pm VWAP +1', tooltip = str.tostring(lastMonthlyUpper, format_level), color = label_color_setting, textcolor = color.new(Pmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pMonthPOCLabel = label.new(x = right_bar, y = lastMonthlyPOC, text = 'pm VWAP', tooltip = str.tostring(lastMonthlyPOC, format_level), color = label_color_setting, textcolor = color.new(Pmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Ppmonth_Ctl
        var ppMonthBox = box.new(left = lastMonthlyStart, right = right_bar, top = lastlastMonthlyUpper, bottom = lastlastMonthlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(Ppmonth_Col, 95))
        var ppMonthLine = line.new(x1 = lastMonthlyStart, y1 = lastlastMonthlyPOC, x2 = right_bar, y2 = lastlastMonthlyPOC, color = color.new(Ppmonth_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var ppMonthLowerLabel = label.new(x = right_bar, y = lastlastMonthlyLower, text = 'ppm VWAP -1', tooltip = str.tostring(lastlastMonthlyLower, format_level), color = label_color_setting, textcolor = color.new(Ppmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppMonthUpperLabel = label.new(x = right_bar, y = lastlastMonthlyUpper, text = 'ppm VWAP +1', tooltip = str.tostring(lastlastMonthlyUpper, format_level), color = label_color_setting, textcolor = color.new(Ppmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppMonthPOCLabel = label.new(x = right_bar, y = lastlastMonthlyPOC, text = 'ppm VWAP', tooltip = str.tostring(lastlastMonthlyPOC, format_level), color = label_color_setting, textcolor = color.new(Ppmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Pquarter_Ctl
        var pQuarterBox = box.new(left = thisQuarterStart, right = right_bar, top = lastQuarterlyUpper, bottom = lastQuarterlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(Pquarter_Col, 95))
        var pQuarterLine = line.new(x1 = thisQuarterStart, y1 = lastQuarterlyPOC, x2 = right_bar, y2 = lastQuarterlyPOC, color = color.new(Pquarter_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pQuarterLowerLabel = label.new(x = right_bar, y = lastQuarterlyLower, text = 'pq VWAP -1', tooltip = str.tostring(lastQuarterlyLower, format_level), color = label_color_setting, textcolor = color.new(Pquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pQuarterUpperLabel = label.new(x = right_bar, y = lastQuarterlyUpper, text = 'pq VWAP +1', tooltip = str.tostring(lastQuarterlyUpper, format_level), color = label_color_setting, textcolor = color.new(Pquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pQuarterPOCLabel = label.new(x = right_bar, y = lastQuarterlyPOC, text = 'pq VWAP', tooltip = str.tostring(lastQuarterlyPOC, format_level), color = label_color_setting, textcolor = color.new(Pquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Ppquarter_Ctl
        var ppqBox = box.new(left = lastYearlyStart, right = right_bar, top = lastlastQuarterlyUpper, bottom = lastlastQuarterlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(Ppquarter_Col, 95))
        var ppqLine = line.new(x1 = lastYearlyStart, y1 = lastlastQuarterlyPOC, x2 = right_bar, y2 = lastlastQuarterlyPOC, color = color.new(Ppquarter_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var ppqLowerLabel = label.new(x = right_bar, y = lastlastQuarterlyLower, text = 'ppq VWAP -1', tooltip = str.tostring(lastlastQuarterlyLower, format_level), color = label_color_setting, textcolor = color.new(Ppquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppqUpperLabel = label.new(x = right_bar, y = lastlastQuarterlyUpper, text = 'ppq VWAP +1', tooltip = str.tostring(lastlastQuarterlyUpper, format_level), color = label_color_setting, textcolor = color.new(Ppquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppqPOCLabel = label.new(x = right_bar, y = lastlastQuarterlyPOC, text = 'ppq VWAP', tooltip = str.tostring(lastlastQuarterlyPOC, format_level), color = label_color_setting, textcolor = color.new(Ppquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if enable7
        var rollingVWAP7Label = label.new(x = na, y = na, text = str.tostring(pdaysInput7 / MS_IN_DAY) + 'D RVWAP', tooltip = str.tostring(rollingVWAP7, '#.####'), color = color.new(#ecf008, 100), textcolor = color.new(RVWAP1_Col, 40), style = label.style_label_left, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        label.set_xy(rollingVWAP7Label, bar_index + 1, rollingVWAP7)
    
    if enable30
        var rollingVWAP30Label = label.new(x = na, y = na, text = str.tostring(pdaysInput30 / MS_IN_DAY) + 'D RVWAP', tooltip = str.tostring(rollingVWAP30, '#.####'), color = color.new(#0f90f0, 100), textcolor = color.new(RVWAP2_Col, 40), style = label.style_label_left, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        label.set_xy(rollingVWAP30Label, bar_index + 1, rollingVWAP30)

    if enable90
        var rollingVWAP90Label = label.new(x = na, y = na, text = str.tostring(pdaysInput90 / MS_IN_DAY) + 'D RVWAP', tooltip = str.tostring(rollingVWAP90, '#.####'), color = color.new(#ec0080, 100), textcolor = color.new(RVWAP3_Col, 40), style = label.style_label_left, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        label.set_xy(rollingVWAP90Label, bar_index + 1, rollingVWAP90)

    if enable365
        var rollingVWAP365Label = label.new(x = na, y = na, text = str.tostring(pdaysInput365 / MS_IN_DAY) + 'D RVWAP', tooltip = str.tostring(rollingVWAP365, '#.####'), color = color.new(#0090f0, 100), textcolor = color.new(RVWAP4_Col, 40), style = label.style_label_left, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        label.set_xy(rollingVWAP365Label, bar_index + 1, rollingVWAP365)

// IB Range
enable_ib = input(true, 'Days to Show', group = 'IB Range', inline = 'ib')
DaysToShow = input.int(7, '', minval = 1, group = 'IB Range', inline = 'ib')
ib_color = input.color(color.rgb(91, 156, 246), '', group = 'IB Range', inline = 'ib')
var array<box> boxesArray = array.new<box>()
var string Tokyo = '0900-1500'
var string Tokyo_Range = '0900-1000'
TokyoTZ = 'Asia/Tokyo'
On_sesTokyo = math.sign(nz(time(timeframe.period, Tokyo, TokyoTZ)))
On_rangeTokyo = math.sign(nz(time(timeframe.period, Tokyo_Range, TokyoTZ)))

//High & Low Session Detector 
LowHighSessionDetector(On_Range, On_Session, Color_Session) =>
    var int Bar = 0
    var float High = 0.0
    var float Low = 0.0
    var box BoX = na

    if On_Range[1] == 0 and On_Range == 1
        Bar := bar_index
        High := high
        Low := low
        Low
    else if On_Range[1] == 1 and On_Range == 1
        High := math.max(high, High)
        Low := math.min(low, Low)
        Low
    else if On_Session == 0
        High := 0.0
        Low := 0.0
        Bar := 0
        Bar

    if On_Session > On_Session[1] and str.tonumber(timeframe.period) <= 60
        BoX := box.new(bar_index, High, bar_index, Low, bgcolor = color.new(Color_Session, 85), border_color = color.new(Color_Session, 100))
        array.push(boxesArray, BoX)

        if array.size(boxesArray) > DaysToShow
            box.delete(array.shift(boxesArray))
    if On_Range[1] == 1 and On_Range == 1
        box.set_top(BoX, High)
        box.set_bottom(BoX, Low)
    if On_Session[1] == 1 and On_Session == 1
        box.set_right(BoX, bar_index)
    if not timeframe.change('D')
        box.set_right(BoX, bar_index)

if enable_ib
    LowHighSessionDetector(On_rangeTokyo, On_sesTokyo, ib_color)
````
