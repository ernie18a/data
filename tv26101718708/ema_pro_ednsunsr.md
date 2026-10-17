# EMA Pro

- url: https://www.tradingview.com/script/edNsunsr-EMA-Pro/
- type: indicator
- pine_id: PUB;6934df2568ff4819870b498ae9f21942
- version: 2.0

## Description

EMA Pro

- [b]Overview[/b]

EMA Signal Pro is a professional trend-following signal indicator built around the combination of EMA 200 breakout detection and EMA alignment confirmation.

Instead of generating signals from every price movement, the indicator waits for multiple conditions to align before issuing a trade signal. This approach helps filter out many low-probability setups and focuses on stronger trend continuation opportunities.

The indicator works independently on all TradingView timeframes, making it suitable for scalping, intraday trading, swing trading, and long-term investing.


-[b]Signal Logic[/b]
[b]LONG[/b]
A LONG (Buy)  is generated only when all three conditions below are met simultaneously.

1️⃣ EMA 200 Bullish Breakout

The current candle must break above the EMA 200.

This means:

The previous candle closed below EMA 200.
The current candle closes above EMA 200.

This confirms that price has crossed the primary long-term trend line.

2️⃣ Bullish Candle Structure

The breakout candle must have:

Lower wick larger than the upper wick

This indicates rejection of lower prices and strong buying pressure during the breakout.

3️⃣ Bullish EMA Alignment

The exponential moving averages must be aligned as follows:

EMA 20   (Highest)
EMA 50
EMA 100
EMA 200  (Lowest)

This alignment confirms that short-, medium-, and long-term trends are all pointing in the same bullish direction.


[b]SHORT[/b]
A SHORT (Sell)  is generated only when all three conditions below are met simultaneously.

1️⃣ EMA 200 Bearish Breakout

The current candle must break below the EMA 200.

This means:

The previous candle closed above EMA 200.
The current candle closes below EMA 200.
2️⃣ Bearish Candle Structure

The breakout candle must have:

Upper wick larger than the lower wick

This indicates rejection of higher prices and strong selling pressure.

3️⃣ Bearish EMA Alignment

The EMAs must be aligned as follows:

EMA 200  (Highest)
EMA 100
EMA 50
EMA 20   (Lowest)

This confirms a strong bearish trend across multiple market horizons.

Only when all three conditions occur together will a SHORT signal be generated.

 [b]Moving Averages Used[/b]
EMA	Period	Purpose
EMA 20	20	Short-term trend
EMA 50	50	Medium-term trend
EMA 100	100	Medium-to-long-term trend
EMA 200	200	Primary long-term trend and breakout reference


[b]-Customization[/b]
Display Options
Show or hide EMAs
Customize the color of each EMA individually



[b]-Best Practices[/b]
Compatible with all TradingView timeframes, from 1-minute to Monthly charts.
Signals are generated only after candle close, preventing repainting during candle formation.
For optimal performance, combine this indicator with proper risk management and stop-loss placement.
The best results are typically achieved on higher timeframes, such as 1H, 4H, and Daily charts.
Designed primarily for trending markets. During sideways or ranging conditions, fewer signals are produced, helping reduce unnecessary trades.


[i]© EMA Pro — All Rights Reserved[/i]

## Source Code

````pine
// © facelesstradersog
//@version=6
indicator("EMA Pro", overlay=true, max_labels_count=500)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⚙️ SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showEMAs        = input.bool(true,                    "Show EMAs",          group="⚙️ Display")
showSignalLabel = input.bool(true,                    "Show Signal Labels", group="⚙️ Display")
colorEMA20      = input.color(color.new(#FFD700, 0), "EMA 20",             group="⚙️ Display")
colorEMA50      = input.color(color.new(#FF8C00, 0), "EMA 50",             group="⚙️ Display")
colorEMA100     = input.color(color.new(#4169E1, 0), "EMA 100",            group="⚙️ Display")
colorEMA200     = input.color(color.new(#FF4444, 0), "EMA 200",            group="⚙️ Display")
fullBodyThresh  = input.float(0.70, "Full Body Threshold (%)", minval=0.5, maxval=0.95, step=0.05, group="⚙️ Signal Settings")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📐 EMA CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

plot(showEMAs ? ema20  : na, "EMA 20",  color=colorEMA20,  linewidth=1)
plot(showEMAs ? ema50  : na, "EMA 50",  color=colorEMA50,  linewidth=1)
plot(showEMAs ? ema100 : na, "EMA 100", color=colorEMA100, linewidth=1)
plot(showEMAs ? ema200 : na, "EMA 200", color=colorEMA200, linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🕯️ CANDLE COMPONENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bodyHigh    = math.max(open, close)
bodyLow     = math.min(open, close)
bodySize    = bodyHigh - bodyLow
totalRange  = high - low
upperShadow = high - bodyHigh
lowerShadow = bodyLow - low
bodyRatio   = totalRange > 0 ? bodySize / totalRange : 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🕯️ CANDLE TYPE CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// --- SHORT candle types ---
bool longUpperShadow   = upperShadow > lowerShadow
bool bearishEngulfing  = open > math.max(open[1], close[1]) and close < math.min(open[1], close[1]) and close < open
bool bearishFullBody   = bodyRatio >= fullBodyThresh and close < open

bool shortCandleOk = longUpperShadow or bearishEngulfing or bearishFullBody

// --- LONG candle types ---
bool longLowerShadow   = lowerShadow > upperShadow
bool bullishEngulfing  = open < math.min(open[1], close[1]) and close > math.max(open[1], close[1]) and close > open
bool bullishFullBody   = bodyRatio >= fullBodyThresh and close > open

bool longCandleOk = longLowerShadow or bullishEngulfing or bullishFullBody


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📊 INFO TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table infoTable = table.new(position.top_right, 2, 6, border_color=color.new(color.gray, 50), border_width=1, bgcolor=color.new(color.black, 75))

emaOrderBullish = ema20 > ema50 and ema50 > ema100 and ema100 > ema200
emaOrderBearish = ema200 > ema100 and ema100 > ema50 and ema50 > ema20
emaOrderColor   = emaOrderBullish ? color.green : emaOrderBearish ? color.red : color.gray
emaOrderText    = emaOrderBullish ? "Bullish ▲" : emaOrderBearish ? "Bearish ▼" : "Neutral ─"

if barstate.islast
    table.cell(infoTable, 0, 0, "EMA Signal Pro",             text_color=color.white,   bgcolor=color.new(color.navy, 30), text_size=size.small)
    table.cell(infoTable, 1, 0, syminfo.ticker,               text_color=color.yellow,  bgcolor=color.new(color.navy, 30), text_size=size.small)
    table.cell(infoTable, 0, 1, "EMA 20",                     text_color=color.gray,    text_size=size.tiny)
    table.cell(infoTable, 1, 1, str.tostring(ema20,  "#.##"), text_color=colorEMA20,    text_size=size.tiny)
    table.cell(infoTable, 0, 2, "EMA 50",                     text_color=color.gray,    text_size=size.tiny)
    table.cell(infoTable, 1, 2, str.tostring(ema50,  "#.##"), text_color=colorEMA50,    text_size=size.tiny)
    table.cell(infoTable, 0, 3, "EMA 100",                    text_color=color.gray,    text_size=size.tiny)
    table.cell(infoTable, 1, 3, str.tostring(ema100, "#.##"), text_color=colorEMA100,   text_size=size.tiny)
    table.cell(infoTable, 0, 4, "EMA 200",                    text_color=color.gray,    text_size=size.tiny)
    table.cell(infoTable, 1, 4, str.tostring(ema200, "#.##"), text_color=colorEMA200,   text_size=size.tiny)
    table.cell(infoTable, 0, 5, "EMA Trend",                  text_color=color.gray,    text_size=size.tiny)
    table.cell(infoTable, 1, 5, emaOrderText,                 text_color=emaOrderColor, text_size=size.tiny)
````
