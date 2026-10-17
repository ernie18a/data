# DXY Regime & Bitcoin Cycle Indicator

- url: https://www.tradingview.com/script/16lN4RPg-DXY-Regime-Bitcoin-Cycle-Indicator/
- type: indicator
- pine_id: PUB;4d35d396cd86418a85bf2f7689881c8b
- version: 1.0

## Description

[b]DXY Regime & Bitcoin Cycle Indicator[/b]

This indicator measures the current U.S. Dollar (DXY) trend regime and its historical relationship with Bitcoin performance.

[b]Core Idea[/b]
Bitcoin has spent most of its existence inside a long-term dollar bull market. Historically, Bitcoin’s strongest returns have occurred during periods of dollar weakness. This tool identifies whether the dollar is currently in a Falling or Rising regime using a simple but effective method.
Methodology

[b]Uses monthly DXY data[/b]
[list]
[*]Calculates a 4-month Simple Moving Average of DXY
[*]Measures the 2-month Rate of Change of that SMA (called Dollar Trend Velocity)
[*]Negative velocity = Falling Dollar Regime (historically more favorable for Bitcoin)
[*]Positive velocity = Rising Dollar Regime (historically less favorable for Bitcoin)
[/list]

[b]What the Indicator Shows[/b]
[list]
[*]Background coloring: Teal = Falling regime | Red = Rising regime
[*]Histogram: Dollar Trend Velocity
[*]Table (top right):
[*][*]Velocity
[*][*]Regime (Falling / Rising)
[*][*]Streak (consecutive months in current regime)
[*][*]Strength (Mild / Moderate / Strong)
[*][*]Bias (BTC bullish / BTC weak)
[/list]


[b]How to Use[/b]
This is a macro regime filter, not a short-term timing tool.
It helps assess the broader dollar backdrop when making Bitcoin allocation or risk decisions. A Falling Dollar regime has historically provided a stronger tailwind for Bitcoin, while a Rising Dollar regime has often acted as a headwind.

[b]Disclaimer: This script is for educational and research purposes only. It does not constitute financial advice.[/b]

## Source Code

````pine
//@version=6
indicator("DXY Regime & Bitcoin Cycle Indicator", shorttitle="DXY Regime", overlay=false, format=format.percent, precision=2)

// -----------------------------------------------------------------------------
// Macro thesis:
// Bitcoin has spent most of its life in a strong dollar bull market. Historically,
// BTC tends to do best when the dollar is weakening. This indicator isolates the
// DXY regime using the sign of the Dollar Trend Velocity.
// -----------------------------------------------------------------------------
// Strict framework:
// 1) Monthly DXY only via request.security(..., "M", ...)
// 2) 4-month SMA of DXY monthly closes
// 3) 2-month ROC of that SMA = Dollar Trend Velocity
// 4) Velocity < 0 -> Falling Dollar Regime
// 5) Velocity > 0 -> Rising Dollar Regime
// 6) Velocity is the main plot; the SMA is not plotted to avoid scale conflict
// -----------------------------------------------------------------------------

// =========================
// Inputs
// =========================

dxySymbol = input.string("TVC:DXY", "DXY Symbol", group="DXY")
showBackground = input.bool(true, "Show background coloring", group="Display")
showTable = input.bool(true, "Show regime table", group="Display")
bgTransparency = input.int(72, "Background transparency", minval=0, maxval=100, group="Display")
fallingColor = input.color(color.teal, "Falling Dollar Regime", group="Colors")
risingColor = input.color(color.red, "Rising Dollar Regime", group="Colors")
zeroLineColor = input.color(color.gray, "Zero line", group="Display")

// =========================
// DXY monthly data and calculations.
// ta.roc() already returns percentage change, so no additional * 100 is needed.
// Keeping the full expression inside request.security ensures both the SMA
// and ROC are calculated on monthly bars, regardless of the chart timeframe.
// =========================

[dxySma4M, dollarTrendVelocity, dxyMonthlyTime] = request.security(dxySymbol, "M", [ta.sma(close, 4), ta.roc(ta.sma(close, 4), 2), time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// =========================
// Regime logic
// =========================

regimeName = "Neutral"
regimeCode = 0

if dollarTrendVelocity < 0
    regimeName := "Falling"
    regimeCode := -1
else if dollarTrendVelocity > 0
    regimeName := "Rising"
    regimeCode := 1
else
    regimeName := "Neutral"
    regimeCode := 0

// =========================
// Background color
// =========================

bgColor = color(na)
if showBackground
    if regimeCode < 0
        bgColor := color.new(fallingColor, bgTransparency)
    else if regimeCode > 0
        bgColor := color.new(risingColor, bgTransparency)

bgcolor(bgColor)
hline(0, "Zero Line", color=zeroLineColor, linestyle=hline.style_dashed, linewidth=1)

// =========================
// Velocity plot (main plot)
// =========================

velocityColor = color.new(color.gray, 20)
if regimeCode < 0
    velocityColor := color.new(fallingColor, 15)
else if regimeCode > 0
    velocityColor := color.new(risingColor, 15)

plot(dollarTrendVelocity, title="Dollar Trend Velocity", color=velocityColor, style=plot.style_columns, linewidth=2)

// =========================
// Consecutive month streak count
// =========================

var int streakMonths = 0
var int previousRegimeCode = 0
newMonthlyBar = not na(dxyMonthlyTime) and (na(dxyMonthlyTime[1]) or dxyMonthlyTime != dxyMonthlyTime[1])

if newMonthlyBar
    if regimeCode == 0
        streakMonths := 0
    else if regimeCode == previousRegimeCode
        streakMonths := streakMonths + 1
    else
        streakMonths := 1
    previousRegimeCode := regimeCode

// =========================
// Alerts
// =========================

fallToRiseAlert = regimeCode > 0 and regimeCode[1] < 0
riseToFallAlert = regimeCode < 0 and regimeCode[1] > 0

alertcondition(fallToRiseAlert, title="Falling → Rising", message="DXY velocity turned positive: Rising Dollar Regime")
alertcondition(riseToFallAlert, title="Rising → Falling", message="DXY velocity turned negative: Falling Dollar Regime")

// =========================
// Regime table
// =========================

regimeStrength = "Mild"
if math.abs(dollarTrendVelocity) >= 3.0
    regimeStrength := "Strong"
else if math.abs(dollarTrendVelocity) >= 1.5
    regimeStrength := "Moderate"

if showTable and barstate.islast
    var table regimeTable = table.new(position.top_right, 2, 5, border_width=1, border_color=color.new(color.white, 70), frame_color=color.new(color.black, 80), frame_width=1)

    table.cell(regimeTable, 0, 0, "Velocity", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(regimeTable, 1, 0, str.format("{0,number,0.00}%", dollarTrendVelocity), text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)

    table.cell(regimeTable, 0, 1, "Regime", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(regimeTable, 1, 1, regimeName, text_color=color.white, bgcolor=regimeCode < 0 ? color.new(fallingColor, 35) : regimeCode > 0 ? color.new(risingColor, 35) : color.new(color.gray, 35), text_size=size.small)

    table.cell(regimeTable, 0, 2, "Streak", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(regimeTable, 1, 2, str.tostring(streakMonths) + " mo", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)

    table.cell(regimeTable, 0, 3, "Strength", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(regimeTable, 1, 3, regimeStrength, text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)

    table.cell(regimeTable, 0, 4, "Bias", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(regimeTable, 1, 4, regimeCode < 0 ? "BTC bullish" : regimeCode > 0 ? "BTC weak" : "Neutral", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)

// =========================
// Notes
// =========================

// - DXY 4M SMA smooths the long-dollar trend.
// - 2M ROC of this SMA measures the acceleration/deceleration of the dollar trend.
// - Negative velocity = falling dollar = historically more favorable for BTC.
// - Positive velocity = rising dollar = historically less favorable for BTC.
````
