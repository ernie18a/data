# RSI cross 70/30 + Cross MA (marks on plot)

- url: https://www.tradingview.com/script/sf4EVuC2-rsi-cross-70-30-cross-ma-marks-on-plot/
- type: indicator
- pine_id: PUB;733404c33d754ed09004e651ae077233
- version: 1.0

## Description

RSI cross 70/30 + Cross MA (marks on plot)
After RSI cross 70 or 30 band and cross moving average you got short or long signal

## Source Code

````pine
//@version=6
indicator(title="RSI Cross MA (marks on plot)", shorttitle="RSI cross MA", overlay=true)
 
// Параметры
rsi_period = input.int(14, "RSI Period")
rsi_signal_period = input.int(14, "RSI Signal SMA Period")
rsi_upper_band = input.float(70, "Upper Band")
rsi_lower_band = input.float(30, "Lower Band")
 
rsi_val = ta.rsi(close, rsi_period)
rsi_signal_sma = ta.sma(rsi_val, rsi_signal_period)
 
// Переменные состояния
var bool exited_upper_zone = false
var bool exited_lower_zone = false
 
// Логика определения выхода из зоны
if rsi_val[1] > rsi_upper_band and rsi_val <= rsi_upper_band
    exited_upper_zone := true
 
if rsi_val[1] < rsi_lower_band and rsi_val >= rsi_lower_band
    exited_lower_zone := true
 
// Сброс флагов
if rsi_val > rsi_upper_band
    exited_upper_zone := false
if rsi_val < rsi_lower_band
    exited_lower_zone := false
 
// Условия сигналов
situation1_condition = exited_upper_zone and ta.crossunder(rsi_val, rsi_signal_sma)
situation2_condition = exited_lower_zone and ta.crossover(rsi_val, rsi_signal_sma)
 
// Сброс флагов после генерации сигнала
if situation1_condition
    exited_upper_zone := false
if situation2_condition
    exited_lower_zone := false
 
// Отрисовка сигналов на графике (overlay=true позволяет рисовать на свечах)
plotshape(situation1_condition, title="Signal Down (Main)", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
plotshape(situation2_condition, title="Signal Up (Main)", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
 
// alert
alertcondition(situation1_condition, "Signal short", "RSI {{syminfo.ticker}} TF: {{syminfo.interval}} вышел за 70 и пересек МА.")
alertcondition(situation2_condition, "Signal long", "RSI {{syminfo.ticker}} TF: {{syminfo.interval}} вышел за 30 и пересек МА.")
````
