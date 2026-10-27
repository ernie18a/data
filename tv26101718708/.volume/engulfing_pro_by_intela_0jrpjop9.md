# Engulfing Pro by INTELA

- url: https://www.tradingview.com/script/0JrpjoP9-Engulfing-Pro-by-INTELA/
- type: indicator
- pine_id: PUB;e35de1d7ca8246dea3863549aa78af4f
- version: 2.0

## Description

[b] Engulfing Pro by INTELA[/b]
📘 What is an Engulfing Pattern?
An Engulfing Pattern is a two-candle formation signaling a potential trend reversal.
It consists of two consecutive candles:

Bullish Engulfing: occurs after a downtrend. The green (bullish) candle completely engulfs the previous red (bearish) candle, suggesting an upward reversal.

Bearish Engulfing: occurs after an uptrend. The red (bearish) candle completely engulfs the previous green (bullish) candle, suggesting a downward reversal.

⚙️ Script Implementation
The Engulfing Pro by INTELA indicator automatically detects these patterns and marks them with triangles on the chart.
It also includes filters to enhance accuracy:

Time Filter: restricts detection to a user-defined time range.

Volume Filter: requires current candle volume to exceed the previous one.

Body Filter: ensures the current candle body is proportionally larger than the previous one.

🧩 User Inputs
Timezone: time zone used for the time filter.

Start Hour / End Hour: time range for signal detection.

Body Bigger than: comparison factor between current and previous candle body (e.g., 1.2 means 20% larger).

Color Bullish Signal: color of the bullish triangle.

Color Bearish Signal: color of the bearish triangle.

🎨 Style Options
In the Style tab of TradingView, users can customize:

Shapes: adjust triangle color and size.

Mode: choose position (Absolute, Above bar, Below bar).

Output Values: show or hide values on the price scale.

Input Values: show or hide input parameters in the status bar.

🧠 Conclusion
Engulfing Pro by INTELA is a professional tool for traders seeking precise reversal pattern detection.
Its time, volume, and body filters minimize false signals and allow full customization to match any trading style.

## Source Code

````pine
//@version=6
// By INTELA Developments - Facundo Laje
// v1.1
indicator('Engulfing Pro by INTELA', overlay=true)



//================= VARIABLES =================//

openBarCurrent = open[0]
closeBarCurrent = close[0]
HighBarCurrent = high[0]
LowBarCurrent = low[0]

openBarPrevious = open[1]
closeBarPrevious = close[1]
HighBarPrevious = high[1]
LowBarPrevious = low[1]

//================= ENGULFING =================//

bullishEngulfing = openBarCurrent <= closeBarPrevious and
                   openBarCurrent < openBarPrevious and
                   closeBarCurrent > HighBarPrevious

bearishEngulfing = openBarCurrent >= closeBarPrevious and
                   openBarCurrent > openBarPrevious and
                   closeBarCurrent < LowBarPrevious

//================= TIMEZONE =================//

tz = input.string("America/New_York", "Timezone",
     options = ["Etc/UTC", "America/New_York", "Europe/London", "Asia/Tokyo"])

//================= FILTRO HORARIO =================//

startHour = input.int(1, "Hora inicio", minval=0, maxval=23)
endHour   = input.int(17, "Hora fin", minval=0, maxval=23)

currentHour = hour(time[0], tz)

inSession = startHour <= endHour ?
     (currentHour >= startHour and currentHour < endHour) :
     (currentHour >= startHour or currentHour < endHour)

//================= FILTRO VOLUMEN =================//

volumeCurrent  = volume[0]
volumePrevious = volume[1]

volumeFilter = volumeCurrent > volumePrevious

//================= FILTRO CUERPO =================//

BiggerBodyFilter = input.float(
     1.2,
     "Body Bigger than",
     minval=0.5,
     maxval=10,
     step=0.1)

bodyCurrent  = math.abs(closeBarCurrent - openBarCurrent)
bodyPrevious = math.abs(closeBarPrevious - openBarPrevious)

bodyFilter = bodyCurrent > bodyPrevious * BiggerBodyFilter

//================= OFFSET SEÑALES =================//

signalOffsetPct = input.float(
     20.0,
     "Distancia señal (%)",
     minval=0.1,
     maxval=50.0,
     step=0.1)

rangeCurrent = HighBarCurrent - LowBarCurrent
signalOffset = rangeCurrent * (signalOffsetPct / 100)

//================= SEÑALES =================//

bullishSignal = bullishEngulfing and inSession and volumeFilter and bodyFilter
bearishSignal = bearishEngulfing and inSession and volumeFilter and bodyFilter

//================= INPUT COLORES =================//

bullishColor = input.color(color.aqua, "Color Bullish Signal")
bearishColor = input.color(color.gray, "Color Bearish Signal")

//================= PLOT =================//

plotshape(
     bullishSignal ? LowBarCurrent - signalOffset : na,
     style=shape.triangleup,
     location=location.absolute,
     color=bullishColor,
     size=size.tiny,
     offset=0
)

plotshape(
     bearishSignal ? HighBarCurrent + signalOffset : na,
     style=shape.triangledown,
     location=location.absolute,
     color=bearishColor,
     size=size.tiny,
     offset=0
)

//================= ALERTAS =================//

alertcondition(
     bullishSignal,
     title="Bullish Engulfing",
     message="Bullish Engulfing"
)

alertcondition(
     bearishSignal,
     title="Bearish Engulfing",
     message="Bearish Engulfing"
)

if bullishSignal and barstate.isconfirmed
    alert(
         "🟢 Bullish Engulfing en " +
         syminfo.ticker +
         " (" +
         timeframe.period +
         ")",
         alert.freq_once_per_bar
    )

if bearishSignal and barstate.isconfirmed
    alert(
         "🔴 Bearish Engulfing en " +
         syminfo.ticker +
         " (" +
         timeframe.period +
         ")",
         alert.freq_once_per_bar
    )
````
