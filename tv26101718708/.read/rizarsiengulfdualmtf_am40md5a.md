# Riza_Rsi_Engulf_DualMTF

- url: https://www.tradingview.com/script/aM40Md5a/
- type: indicator
- pine_id: PUB;b1310fb3176048f0a4372dbc7e3ccaff
- version: 1.0

## Description

Riza RSI & Engulfing: Dual MTF Scalper v6
This indicator is a precision-engineered oscillator designed for scalpers and day traders. It combines the volatility-tracking power of WaveTrend (WT) with Engulfing candlestick patterns across dual custom timeframes.

🔑 Key Features
1. Smart Dual-MTF Logic
The script automatically adjusts its calculation period based on your chart:

For 45-Second Charts: It defaults to a 10-minute calculation timeframe.

For 1-Minute Charts: It defaults to a 15-minute calculation timeframe.
This ensures you are always looking at the "Big Picture" trend while trading on the noise-heavy lower timeframes.

2. WaveTrend (WT) Oscillator
A customized momentum oscillator that identifies extreme overbought and oversold conditions.

Green/Red Lines: Track the momentum flow.

Circle Plots: Signal potential trend reversals at critical levels.

3. Engulfing Signal Integration
The indicator scans for institutional engulfing patterns.

Blue Circles: Bullish Engulfing.

Yellow Circles: Bearish Engulfing.

4. Strong "Sniper" Signals
The script identifies Strong Buy/Sell moments by filtering engulfing patterns with oscillator extremes:

Strong Buy (Lime Cross): Occurs when a Bullish Engulfing matches an Oversold WaveTrend.

Strong Sell (Fuchsia Cross): Occurs when a Bearish Engulfing matches an Overbought WaveTrend.

📈 How to Use
Confirmation: Don't just trade every circle. Wait for the Background Highlight (Bgcolor) or the Cross (+) symbols for high-probability setups.

Scalping: Perfect for identifying quick reversals in BIST, NAS100, and Crypto markets.

## Source Code

````pine
//@version=6
// Combined Indicator: Riza_Rsi + Engulfing Sinyal - Çift Özel Zaman Aralığı
indicator(title="Riza_Rsi_Engulf_DualMTF", shorttitle="Riza_R_E_v6", overlay=false)

// ==================== HESAPLAMA ZAMAN ARALIKLARI ====================
useCustomTimeframe = input.bool(true, "Özel Zaman Aralığı Kullan", group="HESAPLAMA")
waitForClose = input.bool(true, "Zaman aralığının kapanmasını bekleyin", group="HESAPLAMA")

// 1. Durum: 45 Saniyelik Grafik Ayarı (Varsayılan 10dk)
tf45S = input.timeframe("10", "45sn Grafiği için Zaman Aralığı", group="HESAPLAMA")

// 2. Durum: 1 Dakikalık Grafik Ayarı (Varsayılan 15dk)
tf1Min = input.timeframe("15", "1dk Grafiği için Zaman Aralığı", group="HESAPLAMA")

// Zaman Aralığı Seçim Mantığı
is45Sec = timeframe.period == "45S" or timeframe.period == "45"
is1Min  = timeframe.period == "1"

effectiveTimeframe = timeframe.period 
if useCustomTimeframe
    if is45Sec
        effectiveTimeframe := tf45S
    else if is1Min
        effectiveTimeframe := tf1Min

// ==================== HESAPLAMA FONKSİYONLARI ====================
n1 = input.int(10, "Channel Length")
n2 = input.int(21, "Average Length")
obLevel1 = input.int(60, "Over Bought Level 1")
osLevel1 = input.int(-60, "Over Sold Level 1")
obLevel2 = input.int(53, "Over Bought Level 2")
osLevel2 = input.int(-53, "Over Sold Level 2")

calcWT() =>
    ap = hlc3
    esa = ta.ema(ap, n1)
    d = ta.ema(math.abs(ap - esa), n1)
    ci = (ap - esa) / (0.015 * d)
    tci = ta.ema(ci, n2)
    wt1_val = tci
    wt2_val = ta.sma(wt1_val, 4)
    [wt1_val, wt2_val]

calcEngulfing() =>
    bueng_val = open[3] > close[3] and open[2] > close[2] and open[1] > close[1] and close > open and close >= open[1] and close[1] >= open and (close - open > open[1] - close[1])
    beeng_val = open[3] < close[3] and open[2] < close[2] and close[1] > open[1] and open > close and open >= close[1] and open[1] >= close and (open - close > close[1] - open[1])
    [bueng_val, beeng_val]

// Veri Çekme (MTF)
[wt1, wt2] = request.security(syminfo.tickerid, effectiveTimeframe, calcWT(), lookahead = waitForClose ? barmerge.lookahead_off : barmerge.lookahead_on)
[Bueng, Beeng] = request.security(syminfo.tickerid, effectiveTimeframe, calcEngulfing(), lookahead = waitForClose ? barmerge.lookahead_off : barmerge.lookahead_on)

// ==================== GÖRSELLEŞTİRME ====================
plot(0, color=color.gray, title="Zero Line")
plot(obLevel1, color=color.red, title="OB Level 1")
plot(osLevel1, color=color.green, title="OS Level 1")
plot(obLevel2, color=color.red, title="OB Level 2", style=plot.style_circles)
plot(osLevel2, color=color.green, title="OS Level 2", style=plot.style_circles)

plot(wt1, color=color.green, title="WT1", linewidth=2)
plot(wt2, color=color.red, title="WT2", linewidth=2)
plot(wt1-wt2, color=color.new(color.blue, 80), style=plot.style_area, title="WT Diff")

wtCross = ta.cross(wt1, wt2)
wtBullishCross = ta.crossover(wt1, wt2)
wtBearishCross = ta.crossunder(wt1, wt2)

plot(wtCross ? wt2 : na, color=color.black, style=plot.style_circles, linewidth=3)
plot(wtCross ? wt2 : na, color=(wt2 - wt1 > 0 ? color.red : color.lime), style=plot.style_circles, linewidth=2)

engulfingAlisRenk = #328EFF
plot(Bueng ? osLevel1 - 10 : na, color=engulfingAlisRenk, style=plot.style_circles, linewidth=4)
plot(Beeng ? obLevel1 + 10 : na, color=color.yellow, style=plot.style_circles, linewidth=4)

strongBuy = Bueng and (wt1 < osLevel2 or wtBullishCross)
strongSell = Beeng and (wt1 > obLevel2 or wtBearishCross)

plot(strongBuy ? osLevel1 - 20 : na, color=color.lime, style=plot.style_cross, linewidth=4)
plot(strongSell ? obLevel1 + 20 : na, color=color.fuchsia, style=plot.style_cross, linewidth=4)

barcolor(Bueng ? engulfingAlisRenk : Beeng ? color.yellow : wtBullishCross ? color.white : wtBearishCross ? color.fuchsia : na)
bgcolor(strongBuy ? color.new(color.lime, 70) : strongSell ? color.new(color.fuchsia, 70) : na)
````
