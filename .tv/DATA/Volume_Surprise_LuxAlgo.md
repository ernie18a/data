<!-- tradingview-pine-id: PUB;13c53f2018c640a093a7502d6a9333c4 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Surprise [LuxAlgo]

Source: https://www.tradingview.com/script/LvqOpkKP-Volume-Surprise-LuxAlgo/

## Description

The Volume Surprise tool displays the trading volume alongside the expected volume at that time, allowing users to spot unexpected trading activity on the chart easily.

The tool includes an extrapolation of the estimated volume for future periods, allowing forecasting future trading activity.

🔶 USAGE

[image]https://www.tradingview.com/x/oXrTRHv7/[/image]

We define Volume Surprise as a situation where the actual trading volume deviates significantly from its expected value at a given time.

Being able to determine if trading activity is higher or lower than expected allows us to precisely gauge the interest of market participants in specific trends.

A histogram constructed from the difference between the volume and expected volume is provided to easily highlight the difference between the two and may be used as a standalone.

[image]https://www.tradingview.com/x/e7ZfNFO0[/image]

The tool can also help quantify the impact of specific market events, such as news about an instrument. For example, an important announcement leading to volume below expectations might be a sign of market participants underestimating the impact of the announcement.

[image]https://www.tradingview.com/x/yJCHkw6m/[/image]

Like in the example above, it is possible to observe cases where the volume significantly differs from the expected one, which might be interpreted as an anomaly leading to a correction.

🔹Detecting Rare Trading Activity

Expected volume is defined as the mean (or median if we want to limit the impact of outliers) of the volume grouped at a specific point in time. This value depends on grouping volume based on periods, which can be user-defined.

However, it is possible to adjust the indicator to overestimate/underestimate expected volume, allowing for highlighting excessively high or low volume at specific times.

In order to do this, select "Percentiles" as the summary method, and change the percentiles value to a value that is close to 100 (overestimate expected volume) or to 0 (underestimate expected volume).

[image]https://www.tradingview.com/x/K3YH8qK5/[/image]

In the example above, we are only interested in detecting volume that is excessively high, we use the 95th percentile to do so, effectively highlighting when volume is higher than 95% of the volumes recorded at that time.

🔶 DETAILS

🔹Choosing the Right Periods

Our expected volume value depends on grouping volume based on periods, which can be user-defined.

For example, if only the hourly period is selected, volumes are grouped by their respective hours. As such, to get the expected volume for the hour 7 PM, we collect and group the historical volumes that occurred at 7 PM and average them to get our expected value at that time.

Users are not limited to selecting a single period, and can group volume using a combination of all the available periods. 

Do note that when on lower timeframes, only having higher periods will lead to less precise expected values. Enabling periods that are too low might prevent grouping. Finally, enabling a lot of periods will, on the other hand, lead to a lot of groups, preventing the ability to get effective expected values.

In order to avoid changing periods by navigating across multiple timeframes, an "Auto Selection" setting is provided.

🔹Group Length

[image]https://www.tradingview.com/x/ETHkWBos/[/image]

The length setting allows controlling the maximum size of a volume group. Using higher lengths will provide an expected value on more historical data, further highlighting recurring patterns.

🔹Recommended Assets

Obtaining the expected volume for a specific period (time of the day, day of the week, quarter, etc) is most effective when on assets showing higher signs of periodicity in their trading activity.

This is visible on stocks, futures, and forex pairs, which tend to have a defined, recognizable interval with usually higher trading activity.

[image]https://www.tradingview.com/x/MZbvKnz8/[/image]

Assets such as cryptocurrencies will usually not have a clearly defined periodic trading activity, which lowers the validity of forecasts produced by the tool, as well as any conclusions originating from the volume to expected volume comparisons.

🔶 SETTINGS

[*]Length: Maximum number of records in a volume group for a specific period. Older values are discarded.
[*]Smooth: Period of a SMA used to smooth volume. The smoothing affects the expected value.

🔹Periods

[*]Auto Selection: Automatically choose a practical combination of periods based on the chart timeframe.
[*] Custom periods can be used if disabling "Auto Selection". Available periods include:
- Minutes
- Hours
- Days (can be: Day of Week, Day of Month, Day of Year)
- Months
- Quarters

🔹Summary

[*]Method: Method used to obtain the expected value. Options include Mean (default) or Percentile.
[*]Percentile: Percentile number used if "Method" is set to "Percentile". A value of 50 will effectively use a median for the expected value. 

🔹Forecast

[*]Forecast Window: Number of bars ahead for which the expected volume is predicted.
[*]Style: Style settings of the forecast.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("Volume Surprise [LuxAlgo]", "LuxAlgo - Volume Surprise", overlay = false, format = format.volume)
//---------------------------------------------------------------------------------------------------------------------}
// Settings
//---------------------------------------------------------------------------------------------------------------------{
length = input.int(50,
  minval = 1)

smooth = input.int(1,
  minval = 1)

// Periods
autoFormat = input(true, 'Auto Selection',
  group = 'Periods',
  tooltip = 'Automatically choose a practical combination of periods based on the chart timeframe')

considerMinutes = input(true, 'Minutes',
  group = 'Periods')

considerHours = input(true, 'Hours',
  group = 'Periods')

considerDays = input(false, 'Days',
   inline = 'day',
   group = 'Periods')

daysOptions = input.string('Day of Week', '',
  options = ['Day of Week', 'Day of Month', 'Day of Year'],
  inline = 'day',
  group = 'Periods')

considerMonths = input(false, 'Months',
  group = 'Periods')

considerQuarters = input(false, 'Quarters',
  group = 'Periods')

// Summary
summaryMethod = input.string('Mean', 'Method',
  options = ['Mean', 'Percentile'],
  group = 'Summary')

percentile = input(50,
  active = summaryMethod == 'Percentile',
  group = 'Summary')

// Forecast
showForecast = input(true, 'Show Forecast',
  group = 'Forecast')

forecastWindow = input.int(50, 'Forecast Window',
  minval = 1,
  maxval = 499,
  group = 'Forecast')

forecastStyleColor = input(#2962ff, 'Style',
  inline = 'forecast_style',
  group = 'Forecast')

forecastStyleLine = input.string('Dotted', '',
  options = ['Solid', 'Dashed', 'Dotted'],
  inline = 'forecast_style',
  group = 'Forecast')

//---------------------------------------------------------------------------------------------------------------------}
// Types
//---------------------------------------------------------------------------------------------------------------------{
type vector
    array<float> v

//---------------------------------------------------------------------------------------------------------------------}
// Methods
//---------------------------------------------------------------------------------------------------------------------{
method getSummary(map<string, vector> id, key) =>
    summary = switch summaryMethod
        'Mean' => id.get(key).v.avg()
        'Percentile' => id.get(key).v.percentile_linear_interpolation(percentile)

//---------------------------------------------------------------------------------------------------------------------}
// Calculations
//---------------------------------------------------------------------------------------------------------------------{
if barstate.isfirst and autoFormat
    if timeframe.isseconds
        considerMinutes := true, considerHours := true, considerDays := false, considerMonths := false, considerQuarters := false
    else if timeframe.isminutes and timeframe.in_seconds(timeframe.period) >= 3600
        considerMinutes := false, considerHours := true, considerDays := true, considerMonths := false, considerQuarters := false
    else if timeframe.isminutes
        considerMinutes := true, considerHours := true, considerDays := false, considerMonths := false, considerQuarters := false
    else
        considerMinutes := false, considerHours := false, considerDays := false, considerMonths := true, considerQuarters := true

// custom datetime format
var format =
  str.format('{0}{1}{2}{3}{4}ss',
  considerQuarters ? str.tostring(math.ceil(month / 3)) : '',
  considerMonths ? 'MM:' : '',
  considerDays ? (daysOptions == 'Day of Week' ? 'EEE:' : daysOptions == 'Day of Month' ? 'dd:' : 'DDD:') : '',
  considerHours ? 'hh:' : '',
  considerMinutes ? 'mm:' : ''
  )

var data = map.new<string, vector>()

vol = ta.sma(volume, smooth)
key = str.format_time(time, format)

// Add new vector to map if key is not found
if not data.keys().includes(key)
    data.put(key, vector.new(array.new<float>(0)))

summary = data.getSummary(key)

data.get(key).v.push(vol)

// Trim vector
if data.get(key).v.size() > length
    data.get(key).v.shift()

//---------------------------------------------------------------------------------------------------------------------}
//Forecast
//---------------------------------------------------------------------------------------------------------------------{
var forecastStyle = switch forecastStyleLine
    'Solid' => line.style_solid
    'Dashed' => line.style_dashed
    'Dotted' => line.style_dotted

if showForecast and barstate.islast
    forecastCoordinates = array.new<chart.point>(0)
    forecastCoordinates.push(chart.point.from_time(time, summary))

    for i = 1 to forecastWindow
        t = time(timeframe.period, bars_back = -i)
        forecastKey = str.format_time(t, format)

        // Forecasted value
        if data.keys().includes(forecastKey)
            forecastValue = data.getSummary(forecastKey)
            forecastCoordinates.push(chart.point.from_time(t, forecastValue))
        else
            forecastCoordinates.push(chart.point.from_time(t, na))
    
    polyline.delete(polyline.new(forecastCoordinates, xloc = xloc.bar_time, line_style = forecastStyle, line_color = forecastStyleColor)[1])

//---------------------------------------------------------------------------------------------------------------------}
//Plot
//---------------------------------------------------------------------------------------------------------------------{
css = vol > summary ? color.new(#089981, 50) : color.new(#f23645, 50)

plotVolume = plot(vol, 'Volume', color = color.gray)
plotEv = plot(summary, 'Expected Volume', color = color.orange, linestyle = plot.linestyle_dotted)

plot(vol - summary, 'Difference',
  style = plot.style_columns,
  color = css)

//---------------------------------------------------------------------------------------------------------------------}
````
