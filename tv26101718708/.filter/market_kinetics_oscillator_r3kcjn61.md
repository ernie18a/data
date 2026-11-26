# Market Kinetics Oscillator

- url: https://www.tradingview.com/script/R3KcJn61/
- type: indicator
- pine_id: PUB;4d7c3e72a42d42c291198c740531d2d9
- version: 1.0

## Description

Market Kinetics Oscillator is designed to visualize market activity, price movement, and their dynamic changes in one compact oscillator.

The indicator combines volume-based activity velocity with price velocity and derivative-based momentum signals. It helps identify whether market activity is expanding, slowing down, building pressure, or losing momentum.

The oscillator includes:

VC (V/s)
Volume/activity velocity. It measures market activity per second based on volume divided by bar duration.

PV (ATR)
Price velocity. It measures price movement relative to ATR, making price movement more comparable across different symbols and timeframes.

ACC (ΔV)
Activity acceleration. It shows whether volume/activity velocity is increasing or decreasing.

Jerk (ΔA)
Change of acceleration. It helps detect whether acceleration itself is strengthening or weakening.

Impulse (ΣA)
Accumulated activity pressure. It sums acceleration over a selected impulse period to show whether activity pressure is building or fading over time.

The indicator includes adjustable settings for:

Data lookback length
Smoothing
Scaling
Impulse length
ATR length for price velocity
Individual line visibility
Table position and table size

The metric table uses the same colors as the plotted lines, making the oscillator easier to read at a glance.

This tool can help identify:

activity expansion
price reaction to market activity
acceleration and slowdown phases
potential momentum shifts
impulse buildup
divergence between market activity and price movement

A high activity velocity combined with strong price velocity may indicate efficient directional movement. High activity with weak price velocity may suggest absorption or resistance. Acceleration and jerk can help detect early changes in market behavior before they become obvious in price alone.

The Market Kinetics Oscillator is intended as an analytical tool for market dynamics and should be used together with price structure, volume context, and other confirmation methods.

## Source Code

````pine
//@version=6
indicator("Market Kinetics Oscillator", overlay=false)

InputSourceMode = input.string("Volume", "Speed Source", options=["Volume", "One Tick Per Bar"])

InputDataLookbackLength = input.int(300, "Data Lookback Length", minval=10)
InputImpulseLength = input.int(30, "Impulse Length", minval=1)

InputSpeedSmoothingLength = input.int(3, "Speed Smoothing", minval=1)
InputAccelerationSmoothingLength = input.int(2, "ACC Smoothing", minval=1)
InputJerkSmoothingLength = input.int(1, "Jerk Smoothing", minval=1)

InputPriceVelocityAtrLength = input.int(14, "PV ATR Length", minval=1)

InputSpeedScale = input.float(5.0, "VC Scale", minval=0.1, step=0.1)
InputPriceVelocityScale = input.float(5.0, "PV Scale", minval=0.1, step=0.1)
InputAccelerationScale = input.float(5.0, "ACC Scale", minval=0.1, step=0.1)
InputJerkScale = input.float(10.0, "Jerk Scale", minval=0.1, step=0.1)
InputImpulseScale = input.float(1.0, "Impulse Scale", minval=0.1, step=0.1)

InputShowSpeed = input.bool(true, "Show VC")
InputShowPriceVelocity = input.bool(true, "Show PV")
InputShowAcceleration = input.bool(true, "Show ACC")
InputShowJerk = input.bool(true, "Show Jerk")
InputShowImpulse = input.bool(false, "Show Impulse")
InputShowZeroLine = input.bool(true, "Show Zero Line")
InputShowReferenceLines = input.bool(true, "Show Reference Lines")

InputTablePosition = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
InputTableTextSize = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal"])
InputTableMetricWidth = input.int(11, "Table Metric Width", minval=1)
InputTableValueWidth = input.int(9, "Table Value Width", minval=1)
InputTableStatusWidth = input.int(11, "Table Status Width", minval=1)

VcColor = color.white
PriceVelocityColor = color.lime
AccelerationLineColor = color.black
JerkLineColor = color.yellow
ImpulseLineColor = color.blue

TablePosition =
     InputTablePosition == "Top Left" ? position.top_left :
     InputTablePosition == "Bottom Right" ? position.bottom_right :
     InputTablePosition == "Bottom Left" ? position.bottom_left :
     position.top_right

TableTextSize =
     InputTableTextSize == "Tiny" ? size.tiny :
     InputTableTextSize == "Normal" ? size.normal :
     size.small

BarSecondsByTimeframe = timeframe.in_seconds(timeframe.period)
BarSecondsByTime = na(time[1]) ? na : math.max(1.0, (time - time[1]) / 1000.0)
BarSeconds = na(BarSecondsByTimeframe) ? BarSecondsByTime : BarSecondsByTimeframe

TickAmount =
     InputSourceMode == "One Tick Per Bar" ? 1.0 :
     volume

SpeedRaw = BarSeconds > 0 ? TickAmount / BarSeconds : na

SpeedAverage = ta.sma(SpeedRaw, InputDataLookbackLength)
SpeedRelativeRaw = SpeedAverage > 0 ? SpeedRaw / SpeedAverage : na
Speed = ta.ema(SpeedRelativeRaw, InputSpeedSmoothingLength)

SpeedDeviationRaw = Speed - 1.0
SpeedDeviationAverage = ta.sma(SpeedDeviationRaw, InputDataLookbackLength)
SpeedDeviationStdev = ta.stdev(SpeedDeviationRaw, InputDataLookbackLength)
SpeedZ = SpeedDeviationStdev > 0 ? (SpeedDeviationRaw - SpeedDeviationAverage) / SpeedDeviationStdev : SpeedDeviationRaw
SpeedPlot = SpeedZ * InputSpeedScale
SpeedPercent = (Speed - 1.0) * 100.0

AtrValue = ta.atr(InputPriceVelocityAtrLength)
PriceVelocityRaw = AtrValue > 0 ? (close - close[1]) / AtrValue : na

PriceVelocityAverage = ta.sma(PriceVelocityRaw, InputDataLookbackLength)
PriceVelocityDeviation = ta.stdev(PriceVelocityRaw, InputDataLookbackLength)
PriceVelocityNormalized = PriceVelocityDeviation > 0 ? (PriceVelocityRaw - PriceVelocityAverage) / PriceVelocityDeviation : PriceVelocityRaw
PriceVelocityPlot = PriceVelocityNormalized * InputPriceVelocityScale

AccelerationRaw = Speed - Speed[1]
AccelerationSmoothed = ta.ema(AccelerationRaw, InputAccelerationSmoothingLength)

AccelerationAverage = ta.sma(AccelerationSmoothed, InputDataLookbackLength)
AccelerationDeviation = ta.stdev(AccelerationSmoothed, InputDataLookbackLength)
AccelerationNormalized = AccelerationDeviation > 0 ? (AccelerationSmoothed - AccelerationAverage) / AccelerationDeviation : AccelerationSmoothed
AccelerationPlot = AccelerationNormalized * InputAccelerationScale

JerkRaw = AccelerationSmoothed - AccelerationSmoothed[1]
JerkSmoothed = ta.ema(JerkRaw, InputJerkSmoothingLength)

JerkAverage = ta.sma(JerkSmoothed, InputDataLookbackLength)
JerkDeviation = ta.stdev(JerkSmoothed, InputDataLookbackLength)
JerkNormalized = JerkDeviation > 0 ? (JerkSmoothed - JerkAverage) / JerkDeviation : JerkSmoothed
JerkPlot = JerkNormalized * InputJerkScale

ImpulseRaw = math.sum(AccelerationNormalized, InputImpulseLength)
ImpulsePlot = ImpulseRaw * InputImpulseScale

plot(InputShowSpeed ? SpeedPlot : na, title="VC", color=VcColor, linewidth=2)
plot(InputShowPriceVelocity ? PriceVelocityPlot : na, title="PV", color=PriceVelocityColor, linewidth=2)
plot(InputShowAcceleration ? AccelerationPlot : na, title="ACC", color=AccelerationLineColor, linewidth=2)
plot(InputShowJerk ? JerkPlot : na, title="Jerk", color=JerkLineColor, linewidth=2)
plot(InputShowImpulse ? ImpulsePlot : na, title="Impulse", color=ImpulseLineColor, linewidth=2)

plot(InputShowZeroLine ? 0 : na, title="Zero Line", color=color.gray, linewidth=1)
plot(InputShowReferenceLines ? 5 : na, title="+5 Reference", color=color.new(color.gray, 75), linewidth=1)
plot(InputShowReferenceLines ? -5 : na, title="-5 Reference", color=color.new(color.gray, 75), linewidth=1)
plot(InputShowReferenceLines ? 10 : na, title="+10 Reference", color=color.new(color.gray, 85), linewidth=1)
plot(InputShowReferenceLines ? -10 : na, title="-10 Reference", color=color.new(color.gray, 85), linewidth=1)

FormatValue(Value) =>
    na(Value) ? "n/a" : str.tostring(Value, "#.##")

GetSpeedStatus(Value) =>
    na(Value) ? "n/a" :
     Value >= 100.0 ? "EXTREME" :
     Value >= 50.0 ? "FAST" :
     Value >= 20.0 ? "ACTIVE" :
     Value >= -20.0 ? "NORMAL" :
     "SLOW"

GetSignalStatus(Value) =>
    na(Value) ? "n/a" :
     Value >= 10.0 ? "STRONG+" :
     Value >= 3.0 ? "UP" :
     Value > -3.0 and Value < 3.0 ? "NEUTRAL" :
     Value <= -10.0 ? "STRONG-" :
     "DOWN"

GetMetricTextColor(BackgroundColor) =>
    BackgroundColor == color.white or BackgroundColor == color.yellow or BackgroundColor == color.lime ? color.black : color.white

var table OscillatorTable = table.new(TablePosition, 3, 9, border_width=1, frame_width=1)

SetHeaderCell(Column, Text, Width) =>
    table.cell(OscillatorTable, Column, 0, Text, text_color=color.white, bgcolor=color.rgb(20, 20, 20), width=Width, text_size=TableTextSize)

SetMetricCell(Row, Text, BackgroundColor) =>
    table.cell(OscillatorTable, 0, Row, Text, text_color=GetMetricTextColor(BackgroundColor), bgcolor=BackgroundColor, width=InputTableMetricWidth, text_size=TableTextSize)

SetValueCell(Row, Text) =>
    table.cell(OscillatorTable, 1, Row, Text, text_color=color.white, bgcolor=color.rgb(35, 35, 35), width=InputTableValueWidth, text_size=TableTextSize)

SetStatusCell(Row, Text) =>
    table.cell(OscillatorTable, 2, Row, Text, text_color=color.white, bgcolor=color.rgb(35, 35, 35), width=InputTableStatusWidth, text_size=TableTextSize)

if barstate.islast
    SetHeaderCell(0, "METRIC", InputTableMetricWidth)
    SetHeaderCell(1, "VALUE", InputTableValueWidth)
    SetHeaderCell(2, "STATUS", InputTableStatusWidth)

    SetMetricCell(1, "VC (V/s)", VcColor)
    SetValueCell(1, FormatValue(SpeedPercent))
    SetStatusCell(1, GetSpeedStatus(SpeedPercent))

    SetMetricCell(2, "PV (ATR)", PriceVelocityColor)
    SetValueCell(2, FormatValue(PriceVelocityPlot))
    SetStatusCell(2, GetSignalStatus(PriceVelocityPlot))

    SetMetricCell(3, "ACC (ΔV)", AccelerationLineColor)
    SetValueCell(3, FormatValue(AccelerationPlot))
    SetStatusCell(3, GetSignalStatus(AccelerationPlot))

    SetMetricCell(4, "Jerk (ΔA)", JerkLineColor)
    SetValueCell(4, FormatValue(JerkPlot))
    SetStatusCell(4, GetSignalStatus(JerkPlot))

    SetMetricCell(5, "Impulse (ΣA)", ImpulseLineColor)
    SetValueCell(5, FormatValue(ImpulsePlot))
    SetStatusCell(5, GetSignalStatus(ImpulsePlot))

    table.cell(OscillatorTable, 0, 6, "Raw V/s", text_color=color.white, bgcolor=color.rgb(45, 45, 45), width=InputTableMetricWidth, text_size=TableTextSize)
    SetValueCell(6, FormatValue(SpeedRaw))
    SetStatusCell(6, InputSourceMode)

    table.cell(OscillatorTable, 0, 7, "Bar s", text_color=color.white, bgcolor=color.rgb(45, 45, 45), width=InputTableMetricWidth, text_size=TableTextSize)
    SetValueCell(7, FormatValue(BarSeconds))
    SetStatusCell(7, timeframe.period)

    table.cell(OscillatorTable, 0, 8, "Lookback", text_color=color.white, bgcolor=color.rgb(45, 45, 45), width=InputTableMetricWidth, text_size=TableTextSize)
    SetValueCell(8, str.tostring(InputDataLookbackLength))
    SetStatusCell(8, "Bars")
````
