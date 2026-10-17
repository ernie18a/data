# Auto RSI- alexnt79

- url: https://www.tradingview.com/script/LoCwwtGP-Auto-RSI-alexnt79/
- type: indicator
- pine_id: PUB;38108e2ba6a943dba620e0e909abeeb1
- version: 1.0

## Description

rsi auto change follow timeframe . strategy by brian EMA trading day -5

## Source Code

````pine
//@version=6
indicator("Auto RSI- alexnt", overlay=true)

// =====================
// USE DEFAULT MAPPING
// =====================
useDefault = input.bool(true, "Use Brian Default Mapping")

// =====================
// CUSTOM EMA VALUES
// =====================
ema_1m  = input.int(1950, "1 Minute EMA")
ema_3m  = input.int(650,  "3 Minute EMA")
ema_5m  = input.int(390,  "5 Minute EMA")
ema_15m = input.int(130,  "15 Minute EMA")
ema_30m = input.int(65,   "30 Minute EMA")
ema_1h  = input.int(33,   "1 Hour EMA")
ema_4h  = input.int(8,    "4 Hour EMA")
ema_d   = input.int(5,    "Daily EMA")
ema_w   = input.int(1,    "Weekly EMA")

// =====================
// STYLE
// =====================
emaColor = input.color(color.purple, "EMA Color")
emaWidth = input.int(2, "EMA Width", minval=1, maxval=5)

// =====================
// VISIBILITY
// =====================
show_1m  = input.bool(true, "Show 1m")
show_3m  = input.bool(true, "Show 3m")
show_5m  = input.bool(true, "Show 5m")
show_15m = input.bool(true, "Show 15m")
show_30m = input.bool(true, "Show 30m")
show_1h  = input.bool(true, "Show 1H")
show_4h  = input.bool(true, "Show 4H")
show_d   = input.bool(true, "Show Daily")
show_w   = input.bool(true, "Show Weekly")

// =====================
// TIMEFRAME DETECTION
// =====================
string tf = timeframe.period

int emaLength = na
bool visible = true

if tf == "1"
    emaLength := useDefault ? 1950 : ema_1m
    visible := show_1m

else if tf == "3"
    emaLength := useDefault ? 650 : ema_3m
    visible := show_3m

else if tf == "5"
    emaLength := useDefault ? 390 : ema_5m
    visible := show_5m

else if tf == "15"
    emaLength := useDefault ? 130 : ema_15m
    visible := show_15m

else if tf == "30"
    emaLength := useDefault ? 65 : ema_30m
    visible := show_30m

else if tf == "60"
    emaLength := useDefault ? 33 : ema_1h
    visible := show_1h

else if tf == "240"
    emaLength := useDefault ? 8 : ema_4h
    visible := show_4h

else if tf == "D"
    emaLength := useDefault ? 5 : ema_d
    visible := show_d

else if tf == "W"
    emaLength := useDefault ? 1 : ema_w
    visible := show_w

else
    emaLength := useDefault ? 65 : ema_30m
    visible := true

emaValue = ta.ema(close, emaLength)

plot(
     visible ? emaValue : na,
     title="Brian MA",
     color=emaColor,
     linewidth=emaWidth
)
````
