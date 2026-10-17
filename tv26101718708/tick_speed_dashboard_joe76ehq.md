# Tick Speed Dashboard

- url: https://www.tradingview.com/script/JOE76EhQ/
- type: indicator
- pine_id: PUB;855b9301d70b4893b6af9f780e48126d
- version: 2.0

## Description

Tick Velocity and Acceleration is a real-time market activity dashboard that measures how fast the market is updating and whether that activity is increasing or slowing down.

The indicator displays all values directly on the chart in a clean dashboard table, making it easy to monitor market activity without adding extra plots below the chart.

It measures:

Speed: current received tick updates per second
Acceleration: change in tick speed compared to the previous measurement window
Relative Speed: current tick speed compared to its recent average
Relative Acceleration: change in relative market speed
Current Ticks: live tick count inside the active measurement window

The relative values are especially useful because raw tick speed can vary depending on the symbol, data feed, market session and liquidity. By comparing the current speed to its own recent average, the indicator makes it easier to identify whether the market is currently moving faster or slower than normal.

This can help identify:

increasing market activity
breakout acceleration
news-driven volatility
slowing momentum
unusually fast or slow market conditions

The dashboard includes clear status labels such as SLOW, NORMAL, ACTIVE, FAST and EXTREME, so the current market state can be read at a glance.

The indicator is optimized for live market conditions, where incoming realtime updates allow the dashboard to measure current tick velocity and acceleration most accurately.

## Source Code

````pine
//@version=6
indicator("Tick Velocity and Acceleration", overlay=true)

InputMode = input.string("Auto", "Mode", options=["Auto", "Manual"])
InputManualReferenceSeconds = input.int(1, "Manual Base In Seconds", minval=1)
InputAverageLength = input.int(60, "Reference Average", minval=1)
InputPosition = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

InputTableWidthName = input.int(8, "Column Width Name", minval=1)
InputTableWidthValue = input.int(8, "Column Width Value", minval=1)
InputTableWidthStatus = input.int(10, "Column Width Status", minval=1)
InputTableWidthFlow = input.int(10, "Column Width Flow", minval=1)

varip int TickCount = 0
varip int UpTickCount = 0
varip int DownTickCount = 0
varip int NeutralTickCount = 0
varip int LastUpTickCount = 0
varip int LastDownTickCount = 0
varip int LastNeutralTickCount = 0
varip int LastBucket = na
varip float LastPrice = na
varip float Speed = na
varip float PreviousSpeed = na
varip float Acceleration = na
varip float RelativeSpeed = na
varip float PreviousRelativeSpeed = na
varip float RelativeAcceleration = na
varip array<float> SpeedHistory = array.new_float()

CurrentSecond = int(timenow / 1000)

BaseSeconds =
     InputMode == "Manual" ? InputManualReferenceSeconds :
     timeframe.isseconds ? timeframe.multiplier :
     1

CurrentBucket = int(CurrentSecond / BaseSeconds)

if barstate.isrealtime
    if na(LastBucket)
        LastBucket := CurrentBucket
        TickCount := 1
        LastPrice := close
    else
        if CurrentBucket == LastBucket
            TickCount += 1

            if not na(LastPrice)
                if close > LastPrice
                    UpTickCount += 1
                else if close < LastPrice
                    DownTickCount += 1
                else
                    NeutralTickCount += 1

            LastPrice := close
        else
            LastUpTickCount := UpTickCount
            LastDownTickCount := DownTickCount
            LastNeutralTickCount := NeutralTickCount

            PreviousSpeed := Speed
            Speed := TickCount / BaseSeconds
            Acceleration := na(PreviousSpeed) ? na : Speed - PreviousSpeed

            array.push(SpeedHistory, Speed)

            if array.size(SpeedHistory) > InputAverageLength
                array.shift(SpeedHistory)

            SumSpeed = 0.0

            for Index = 0 to array.size(SpeedHistory) - 1
                SumSpeed += array.get(SpeedHistory, Index)

            AverageSpeed = array.size(SpeedHistory) > 0 ? SumSpeed / array.size(SpeedHistory) : na

            PreviousRelativeSpeed := RelativeSpeed
            RelativeSpeed := AverageSpeed > 0 ? Speed / AverageSpeed : na
            RelativeAcceleration := na(PreviousRelativeSpeed) ? na : RelativeSpeed - PreviousRelativeSpeed

            TickCount := 1
            UpTickCount := 0
            DownTickCount := 0
            NeutralTickCount := 0
            LastBucket := CurrentBucket
            LastPrice := close

TablePosition =
     InputPosition == "Top Left" ? position.top_left :
     InputPosition == "Bottom Right" ? position.bottom_right :
     InputPosition == "Bottom Left" ? position.bottom_left :
     position.top_right

FormatValue(Value) =>
    na(Value) ? "n/a" : str.tostring(Value, "#.##")

GetSpeedStatus(Value) =>
    na(Value) ? "n/a" :
     Value >= 3.0 ? "EXTREME" :
     Value >= 2.0 ? "FAST" :
     Value >= 1.2 ? "ACTIVE" :
     Value >= 0.8 ? "NORMAL" :
     "SLOW"

GetSpeedColor(Value) =>
    na(Value) ? color.gray :
     Value >= 3.0 ? color.red :
     Value >= 2.0 ? color.orange :
     Value >= 1.2 ? color.yellow :
     Value >= 0.8 ? color.new(color.green, 20) :
     color.new(color.gray, 20)

GetAccelerationStatus(Value) =>
    na(Value) ? "n/a" :
     Value > 0.20 ? "ACCELERATING" :
     Value < -0.20 ? "SLOWING" :
     "STABLE"

GetAccelerationColor(Value) =>
    na(Value) ? color.gray :
     Value > 0.20 ? color.new(color.green, 10) :
     Value < -0.20 ? color.new(color.red, 10) :
     color.new(color.gray, 40)

GetFlowStatus(UpTicks, DownTicks) =>
    UpTicks > DownTicks ? "● BULL" :
     DownTicks > UpTicks ? "● BEAR" :
     "● NEUTRAL"

GetFlowColor(UpTicks, DownTicks) =>
    UpTicks > DownTicks ? color.new(color.green, 0) :
     DownTicks > UpTicks ? color.new(color.red, 0) :
     color.new(color.gray, 0)

GetFlowDetails(UpTicks, DownTicks, NeutralTicks) =>
    "+" + str.tostring(UpTicks) + " / -" + str.tostring(DownTicks) + " / " + str.tostring(NeutralTicks)

GetColumnWidth(Column) =>
    Column == 0 ? InputTableWidthName :
     Column == 1 ? InputTableWidthValue :
     Column == 2 ? InputTableWidthStatus :
     InputTableWidthFlow

var table Dashboard = table.new(TablePosition, 4, 8, border_width=1, frame_width=1)

SetCell(Column, Row, Text, TextColor, BackgroundColor) =>
    table.cell(Dashboard, Column, Row, Text, text_color=TextColor, bgcolor=BackgroundColor, width=GetColumnWidth(Column))

if barstate.islast
    SetCell(0, 0, "TICK SPEED", color.white, color.rgb(20, 20, 20))
    SetCell(1, 0, "VALUE", color.white, color.rgb(20, 20, 20))
    SetCell(2, 0, "STATUS", color.white, color.rgb(20, 20, 20))
    SetCell(3, 0, "FLOW", color.white, color.rgb(20, 20, 20))

    SetCell(0, 1, "Speed (T/s)", color.white, color.rgb(45, 45, 45))
    SetCell(1, 1, FormatValue(Speed), color.white, color.rgb(35, 35, 35))
    SetCell(2, 1, GetSpeedStatus(RelativeSpeed), color.black, GetSpeedColor(RelativeSpeed))
    SetCell(3, 1, GetFlowStatus(LastUpTickCount, LastDownTickCount), color.white, GetFlowColor(LastUpTickCount, LastDownTickCount))

    SetCell(0, 2, "Accel. (T/s²)", color.white, color.rgb(45, 45, 45))
    SetCell(1, 2, FormatValue(Acceleration), color.white, color.rgb(35, 35, 35))
    SetCell(2, 2, GetAccelerationStatus(RelativeAcceleration), color.black, GetAccelerationColor(RelativeAcceleration))
    SetCell(3, 2, GetFlowDetails(LastUpTickCount, LastDownTickCount, LastNeutralTickCount), color.white, color.rgb(35, 35, 35))

    SetCell(0, 3, "Rel. Speed (x)", color.white, color.rgb(45, 45, 45))
    SetCell(1, 3, FormatValue(RelativeSpeed), color.white, color.rgb(35, 35, 35))
    SetCell(2, 3, GetSpeedStatus(RelativeSpeed), color.black, GetSpeedColor(RelativeSpeed))
    SetCell(3, 3, GetFlowStatus(LastUpTickCount, LastDownTickCount), color.white, GetFlowColor(LastUpTickCount, LastDownTickCount))

    SetCell(0, 4, "Rel. Accel.", color.white, color.rgb(45, 45, 45))
    SetCell(1, 4, FormatValue(RelativeAcceleration), color.white, color.rgb(35, 35, 35))
    SetCell(2, 4, GetAccelerationStatus(RelativeAcceleration), color.black, GetAccelerationColor(RelativeAcceleration))
    SetCell(3, 4, GetFlowDetails(LastUpTickCount, LastDownTickCount, LastNeutralTickCount), color.white, color.rgb(35, 35, 35))

    SetCell(0, 5, "Ticks", color.white, color.rgb(45, 45, 45))
    SetCell(1, 5, str.tostring(TickCount), color.white, color.rgb(35, 35, 35))
    SetCell(2, 5, barstate.isrealtime ? "LIVE" : "HIST", color.black, barstate.isrealtime ? color.new(color.green, 10) : color.new(color.gray, 30))
    SetCell(3, 5, GetFlowDetails(UpTickCount, DownTickCount, NeutralTickCount), color.white, color.rgb(35, 35, 35))

    SetCell(0, 6, "Base (s)", color.white, color.rgb(45, 45, 45))
    SetCell(1, 6, str.tostring(BaseSeconds), color.white, color.rgb(35, 35, 35))
    SetCell(2, 6, InputMode, color.white, color.rgb(35, 35, 35))
    SetCell(3, 6, GetFlowStatus(UpTickCount, DownTickCount), color.white, GetFlowColor(UpTickCount, DownTickCount))

    SetCell(0, 7, "Chart", color.white, color.rgb(45, 45, 45))
    SetCell(1, 7, timeframe.period, color.white, color.rgb(35, 35, 35))
    SetCell(2, 7, barstate.isrealtime ? "REALTIME" : "HIST", color.black, barstate.isrealtime ? color.new(color.green, 10) : color.new(color.gray, 30))
    SetCell(3, 7, "U/D/N", color.white, color.rgb(35, 35, 35))
````
