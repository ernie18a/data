<!-- tradingview-pine-id: PUB;c02fdba56d70461fb312119e3135096e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# High/Low Day + RSI

Source: https://www.tradingview.com/script/5fwUdY0s/

## Description

High/Low Day + RSI

High/Low Day + RSI combines current and previous trading day extremes with a compact RSI display directly on the price chart. It provides a single view of the daily price range and momentum without requiring a separate oscillator pane.

FEATURES

• Current Day High and Low: Green and red horizontal lines track the highest and lowest prices reached during the current trading day. These levels update as the daily range expands.

• Previous Day Levels: PHD (Previous High Day) and PLD (Previous Low Day) display the previous trading day’s high and low. These levels remain fixed throughout the current day.

• On-Chart RSI: A vertical gauge appears to the right of the latest candle, showing the current RSI value and a colored diamond marker.

• Customizable Display: Show or hide the current day levels, previous day levels, and RSI independently. Choose solid, dashed, or dotted horizontal lines, customize previous day level colors, and adjust the RSI period and reference levels.

HOW THE RSI DISPLAY WORKS

RSI is calculated from closing prices on the chart’s selected timeframe, using a default period of 14.

The gauge maps the RSI scale onto the current day’s price range: RSI 0 corresponds to the daily low, and RSI 100 corresponds to the daily high. This mapping is only a visual placement method; it does not change the RSI calculation or represent a price target.

The default reference levels are 80, 50, and 20.

With the default settings, the marker colors are:

• Purple: RSI at or above 80.
• Red: RSI at or above 70 and below 80.
• Blue: RSI above 30 and below 70.
• Green: RSI above 20 and at or below 30.
• Orange: RSI at or below 20.

The outer color thresholds follow the configurable upper and lower levels. The additional 70 and 30 thresholds are fixed in the code.

HOW TO USE

1. Add the indicator to an intraday chart.
2. Use High Day and Low Day to follow the developing daily range.
3. Use PHD and PLD as reference levels when observing how price interacts with the previous trading day’s extremes.
4. Read the RSI gauge to assess momentum alongside those price levels. The middle reference defaults to 50, while the upper and lower references highlight elevated and depressed RSI readings.
5. Adjust visibility, line styles, colors, and RSI settings to suit your chart layout. Leave space to the right of the latest candle so the gauge remains visible.

CALCULATION AND BEHAVIOR

Daily levels are calculated from the bars available on the chart and reset when the script detects a new daily period. Day boundaries follow the symbol’s daily periods, rather than a custom session defined by this indicator. Chart session settings and available history can therefore affect the displayed range.

The current day’s high, low, and RSI can change while the market is active. Previous day levels are carried forward from the completed daily range tracked by the script.

The indicator is designed primarily for intraday charts. It displays the latest daily levels and current RSI gauge rather than preserving a historical set of daily lines.

This is a visual analysis indicator. It does not generate automated buy or sell signals, execute trades, include a backtesting strategy, or define alert conditions. Extreme RSI readings alone do not confirm a reversal.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EduWarlock

//@version=6
indicator(title='High/Low Day + RSI', shorttitle='HL Day + RSI', overlay=true, max_labels_count = 500)

// --------------------------------------------------------------------------------------------------------------------}
// High/Low Day Settings
// --------------------------------------------------------------------------------------------------------------------}
showLines = input(true, title='Show Current Day Lines')

// Line Style Settings
lineStyle = input.string("Solid", title="High/Low Day Line Style", options=["Solid", "Dashed", "Dotted"])
phlPldLineStyle = input.string("Dashed", title="PHL/PLD Line Style", options=["Solid", "Dashed", "Dotted"])

// --------------------------------------------------------------------------------------------------------------------}
// RSI Settings
// --------------------------------------------------------------------------------------------------------------------}
rsi_displ     = input.bool(true, "Show RSI", inline = "rsi", group = "RSI")
rsi_len       = input.int(14, "RSI Period", inline = "rsi", group = "RSI")
atr_len_rsi   = input.int(200, "ATR Length for RSI", group = "RSI")

rsi_upper_level = input.int(80, "Upper Level", group = "RSI - Levels")
rsi_mid_level = input.int(50, "Middle Level", group = "RSI - Levels")
rsi_lower_level = input.int(20, "Lower Level", group = "RSI - Levels")

rsi_mid_color    = input.color(color.gray, "Middle Line Color", group = "RSI - Colors")
rsi_upper_color   = input.color(color.purple, "Upper Line Color", group = "RSI - Colors")
rsi_lower_color   = input.color(color.orange, "Lower Line Color", group = "RSI - Colors")

// --------------------------------------------------------------------------------------------------------------------}
// Previous High/Low Day Settings
// --------------------------------------------------------------------------------------------------------------------}
// Previous High/Low Day Lines (PHD / PLD)
showPLD = input.bool(true, title="Show Previous Low Day (PLD)")
pldColor     = input.color(color.red, title="PLD Color")
showPHL = input.bool(true, title="Show Previous High Day (PHD)")
phlColor     = input.color(color.green, title="PHD Color")

// Function to get High/Low Day line style
getLineStyle() =>
    switch lineStyle
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Function to get PHL/PLD line style
getLineStylePHL_PLD() =>
    switch phlPldLineStyle
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Detect new day
newDay = ta.change(time("D")) != 0

// Variables for High/Low Day values
var float todayHigh = na
var float todayLow = na

// Previous values variables
var float prevHigh = na
var float prevLow = na

// Variables for lines and labels
var line highLine = na
var line lowLine = na
var label highLabel = na
var label lowLabel = na
var line pldLine = na
var line phlLine = na
var label pldLabel = na
var label phlLabel = na

// RSI calculation
rsi = float(na)
atr_rsi = ta.atr(atr_len_rsi)
if rsi_displ
    rsi := ta.rsi(close, rsi_len)

// High/Low Day update
if newDay
    prevHigh := todayHigh
    prevLow := todayLow

    todayHigh := high
    todayLow := low

    line.delete(highLine)
    line.delete(lowLine)
    label.delete(highLabel)
    label.delete(lowLabel)
    line.delete(pldLine)
    line.delete(phlLine)
    label.delete(pldLabel)
    label.delete(phlLabel)

    if showLines
        highLine := line.new(x1=bar_index, y1=todayHigh, x2=bar_index + 1, y2=todayHigh, color=color.green, width=1, extend=extend.right, style=getLineStyle())
        lowLine := line.new(x1=bar_index, y1=todayLow, x2=bar_index + 1, y2=todayLow, color=color.red, width=1, extend=extend.right, style=getLineStyle())
        highLabel := label.new(x=bar_index, y=todayHigh, text="High Day", textcolor=color.white, style=label.style_label_left, color=color.green, size=size.small)
        lowLabel := label.new(x=bar_index, y=todayLow, text="Low Day", textcolor=color.white, style=label.style_label_left, color=color.red, size=size.small)

    if showPLD and not na(prevLow)
        pldLine := line.new(x1=bar_index, y1=prevLow, x2=bar_index + 1, y2=prevLow, color=pldColor, width=1, extend=extend.right, style=getLineStylePHL_PLD())
        pldLabel := label.new(x=bar_index, y=prevLow, text="PLD", textcolor=color.white, style=label.style_label_left, color=pldColor, size=size.small)
    
    if showPHL and not na(prevHigh)
        phlLine := line.new(x1=bar_index, y1=prevHigh, x2=bar_index + 1, y2=prevHigh, color=phlColor, width=1, extend=extend.right, style=getLineStylePHL_PLD())
        phlLabel := label.new(x=bar_index, y=prevHigh, text="PHD", textcolor=color.white, style=label.style_label_left, color=phlColor, size=size.small)
else
    todayHigh := math.max(todayHigh, high)
    todayLow := math.min(todayLow, low)

    if showLines
        line.set_y1(highLine, todayHigh)
        line.set_y2(highLine, todayHigh)
        line.set_y1(lowLine, todayLow)
        line.set_y2(lowLine, todayLow)
        label.set_y(highLabel, todayHigh)
        label.set_x(highLabel, bar_index)
        label.set_y(lowLabel, todayLow)
        label.set_x(lowLabel, bar_index)

    if showPLD and not na(prevLow)
        line.set_y1(pldLine, prevLow)
        line.set_y2(pldLine, prevLow)
        if not na(pldLabel)
            label.set_x(pldLabel, bar_index)
    
    if showPHL and not na(prevHigh)
        line.set_y1(phlLine, prevHigh)
        line.set_y2(phlLine, prevHigh)
        if not na(phlLabel)
            label.set_x(phlLabel, bar_index)

if barstate.islast and rsi_displ
    hl_rsi = (todayHigh - todayLow) / 100
    rsi_vl = todayLow + hl_rsi * rsi

    rsi_color = rsi >= rsi_upper_level ? color.purple :
              rsi >= 70           ? color.red :
              rsi <= rsi_lower_level ? color.orange :
              rsi <= 30           ? color.green :
              color.blue

    m_rsi         = line.new(bar_index + 4, todayLow + hl_rsi * rsi_mid_level, bar_index + 6, todayLow + hl_rsi * rsi_mid_level, color = rsi_mid_color)
    high_rsi_lim  = line.new(bar_index + 4, todayLow + hl_rsi * rsi_upper_level, bar_index + 6, todayLow + hl_rsi * rsi_upper_level, color = rsi_upper_color)
    low_rsi       = line.new(bar_index + 4, todayLow + hl_rsi * rsi_lower_level, bar_index + 6, todayLow + hl_rsi * rsi_lower_level, color = rsi_lower_color)
    L_rsi         = line.new(bar_index + 5, todayHigh, bar_index + 5, todayLow, color = color.gray, style = line.style_arrow_both)
    L1_rsi        = label.new(bar_index + 5, rsi_vl, "◈", color = color(na), style = label.style_label_center, textcolor = rsi_color, size = size.large)
    L2_rsi        = label.new(bar_index + 5, rsi_vl, str.tostring(rsi, "◂ ##.#"), color = color(na), style = label.style_label_left, textcolor = chart.fg_color, size = size.normal)
    L3_rsi        = label.new(bar_index + 5, todayHigh, "RSI", color = color(na), style = label.style_label_down, textcolor = chart.fg_color, size = size.normal)

    line.delete(m_rsi[1])
    line.delete(high_rsi_lim[1])
    line.delete(low_rsi[1])
    line.delete(L_rsi[1])
    label.delete(L1_rsi[1])
    label.delete(L2_rsi[1])
    label.delete(L3_rsi[1])
````
