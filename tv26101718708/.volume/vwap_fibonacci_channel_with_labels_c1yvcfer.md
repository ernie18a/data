# VWAP Fibonacci Channel with Labels

- url: https://www.tradingview.com/script/c1YvcFeR/
- type: indicator
- pine_id: PUB;83074ca43d3b4193b75ffdf7800bdcfd
- version: 1.0

## Description

1. 0.618 Breakout Trading Strategy (Trend Following)
This is the most popular day trading method, targeting stocks shifting into a strong uptrend fueled by massive intraday volume.
Entry Timing: Enter the trade during the morning session (09:00~10:00) when volume spikes sharply and the candlestick closes completely above the 0.618 Fibonacci line.
Take Profit (Exit): Sell half of the position at the 0.786 line as the price surges, and fully liquidate the remaining position near the final target at the 1.000 line.
Stop Loss: If the momentum fades after entry and the price falls completely back below the 0.500 line (VWAP Central Line) on low volume, cut losses immediately.
2. 0.500 (VWAP) Pullback Support Strategy (Conservative)
This strategy aims for a technical bounce at the VWAP line, which represents the average intraday entry price of institutions, foreigners, and market makers, right when a previously surging stock undergoes its first correction.
Entry Timing: When a stock that was in the overbought zone (above 0.618) pulls down, enter the trade if the price stops falling at the 0.500 line (VWAP Central Line), leaving a lower wick or forming a bullish green candle.
Take Profit (Exit): Upon a successful bounce, scale out and take profits at the previous resistance levels, specifically at the 0.618 line or the 0.786 line.
Stop Loss: If the 0.500 (VWAP) line fails to hold and the price breaks down toward the 0.382 line with a bearish red candle, consider the trend invalidated and execute a stop-loss.
3. 0.000~0.236 Contrarian Oversold Strategy (Dip Buying / Knife Catching)
This is a high-risk, high-reward strategy that capitalizes on a quick technical rebound (dead cat bounce) when a stock crashes excessively due to sudden panic selling or bad news.
Entry Timing: Enter when the price sharply drops, momentarily breaching the absolute bottom at the 0.000 line (undershooting), and then strongly recovers back inside the 0.000~0.236 zone with a robust bullish green candle.
Take Profit (Exit): In dip buying, greed must be eliminated. Secure your profits quickly as the price bounces back up toward the 0.382 line or near the 0.500 central line (VWAP).
Stop Loss: If the price turns back down after entry and breaks below the previous low at the 0.000 line, exit the trade mechanically to avoid further catastrophic downside.
⚠️ Essential Day Trading Reminders
Check Trading Volume/Turnover: This indicator aligns accurately only on market-leading stocks with a daily trading turnover of at least 30 to 50 billion KRW. Low-volume small-cap stocks easily distort indicator levels.
Trading Time Window: Focus strictly on the highest volatility periods: the morning session (09:00~10:00) and the pre-market close wrap-up (14:00~15:20). The reliability of this indicator drops significantly during the quiet lunchtime consolidation.

## Source Code

````pine
//@version=5
indicator("VWAP Fibonacci Channel with Labels", overlay=true)

// 1. 당일 누적 VWAP 계산
var float cumPV = 0.0
var float cumV = 0.0

if ta.change(time("D"))
    cumPV := ((high + low + close) / 3) * volume
    cumV := volume
else
    cumPV += ((high + low + close) / 3) * volume
    cumV += volume

myVWAP = cumV > 0 ? cumPV / cumV : na

// 2. 당일 최고가 및 최저가 추적
var float dayHigh = na
var float dayLow = na

if ta.change(time("D"))
    dayHigh := high
    dayLow := low
else
    dayHigh := math.max(high, dayHigh)
    dayLow := math.min(low, dayLow)

dayRange = dayHigh - dayLow

// 3. 피보나치 레벨 계산
line_100 = myVWAP + (dayRange * 0.5)
line_786 = myVWAP + (dayRange * 0.286)
line_618 = myVWAP + (dayRange * 0.118)
line_500 = myVWAP
line_382 = myVWAP - (dayRange * 0.118)
line_236 = myVWAP - (dayRange * 0.286)
line_000 = myVWAP - (dayRange * 0.5)

// 4. 라인 출력
plot(line_100, "1.000", color=color.red, linewidth=2)
plot(line_786, "0.786", color=color.orange)
plot(line_618, "0.618", color=color.yellow)
plot(line_500, "0.500 (VWAP)", color=color.purple, linewidth=2)
plot(line_382, "0.382", color=color.green)
plot(line_236, "0.236", color=color.blue)
plot(line_000, "0.000", color=color.navy, linewidth=2)

// 5. 실시간 캔들 옆에 숫자 라벨 표시 함수
f_draw_label(x, y, txt, clr) =>
    var label lbl = na
    if barstate.islast
        label.delete(lbl)
        lbl := label.new(x, y, text=txt, color=color.new(clr, 100), textcolor=clr, style=label.style_label_left, size=size.normal)

f_draw_label(bar_index + 2, line_100, " 1.000", color.red)
f_draw_label(bar_index + 2, line_786, " 0.786", color.orange)
f_draw_label(bar_index + 2, line_618, " 0.618", color.yellow)
f_draw_label(bar_index + 2, line_500, " 0.500 (VWAP)", color.purple)
f_draw_label(bar_index + 2, line_382, " 0.382", color.green)
f_draw_label(bar_index + 2, line_236, " 0.236", color.blue)
f_draw_label(bar_index + 2, line_000, " 0.000", color.navy)
````
