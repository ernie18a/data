# TF-Siper777

- url: https://www.tradingview.com/script/oFJroGoN/
- type: indicator
- pine_id: PUB;3919158daf2e449a96b72b1a7b6acb71
- version: 1.0

## Description

สัญญาณ BUY มาจาก 3 เงื่อนไข
Signal 1 — RSI Oversold
RSI ตัดขึ้นเส้น 35
ราคาอยู่เหนือ EMA เร็ว (เส้นเหลือง)
เหมาะกับ จังหวะดีดตัวขึ้น
Signal 2 — ราคา Cross EMA
ราคาตัดขึ้นเส้น EMA เร็ว
RSI ยังไม่ถึง 40 (ยังไม่แพง)
เหมาะกับ จับ Momentum ต้นเทรนด์
Signal 3 — EMA Cross
EMA เร็วตัดขึ้น EMA ช้า
RSI ต่ำกว่า 60
เหมาะกับ จับเทรนด์ใหม่
สัญญาณ SELL มาจาก 3 เงื่อนไข
Signal 1 — RSI Overbought
RSI ตัดลงเส้น 65
ราคาอยู่ใต้ EMA เร็ว
Signal 2 — ราคา Cross EMA ลง
ราคาตัดลงเส้น EMA เร็ว
RSI สูงกว่า 60
Signal 3 — EMA Cross ลง
EMA เร็วตัดลง EMA ช้า
RSI สูงกว่า 40
วิธีเทรดตามสัญญาณ
เมื่อเห็น ▲ BUY (สีเขียว)
รอให้ แท่งเทียนปิด ก่อน
เช็คพื้นหลัง ต้องเป็นสีเขียว (Uptrend)
เปิด Buy ราคาตลาด
ตั้ง SL ที่เส้นแดง
ตั้ง TP1 เส้นเขียวแรก (ปิดครึ่งนึง)
ตั้ง TP2 เส้นเขียวสอง (ปิดที่เหลือ)
เมื่อเห็น ▼ SELL (สีแดง)
รอให้ แท่งเทียนปิด ก่อน
เช็คพื้นหลัง ต้องเป็นสีแดง (Downtrend)
เปิด Sell ราคาตลาด
ตั้ง SL ที่เส้นแดง
ตั้ง TP1 เส้นเขียวแรก
ตั้ง TP2 เส้นเขียวสอง
❌ อย่าเข้าเทรดเมื่อ
พื้นหลังกราฟ ไม่มีสี (ตลาด Sideway)
สัญญาณ BUY แต่พื้นหลัง สีแดง
สัญญาณ SELL แต่พื้นหลัง สีเขียว
แท่งเทียน ยังไม่ปิด

## Source Code

````pine
//@version=5
indicator("TF-Siper777", overlay=true, timeframe="")

// ============================================================
//                        INPUTS
// ============================================================
src = close

// RSI Settings
rsiLen        = input.int(5,   "RSI Length",       minval=1, group="RSI Settings")
rsiOverbought = input.int(65,  "RSI Overbought",   group="RSI Settings")
rsiOversold   = input.int(35,  "RSI Oversold",     group="RSI Settings")

// EMA Settings
emaFast = input.int(9,  "Fast EMA",  minval=1, group="EMA Settings")
emaSlow = input.int(21, "Slow EMA",  minval=1, group="EMA Settings")

// ATR Settings
atrLen  = input.int(14,    "ATR Period",      minval=1,   group="ATR / Volatility")
atrMult = input.float(0.3, "ATR Multiplier",  minval=0.1, group="ATR / Volatility")

// Volume Filter
useVolFilter = input.bool(false, "Use Volume Filter", group="Volume Filter")
volLen       = input.int(20, "Volume MA Length",      group="Volume Filter")

// SL/TP Settings
atrSL    = input.float(1.5, "Stop Loss (x ATR)",   minval=0.1, group="SL / TP")
atrTP    = input.float(3.0, "Take Profit (x ATR)",  minval=0.1, group="SL / TP")
showSLTP = input.bool(true, "Show SL/TP Lines",     group="SL / TP")

// ============================================================
//                      CALCULATIONS
// ============================================================
rsiVal = ta.rsi(src, rsiLen)
emaF   = ta.ema(src, emaFast)
emaS   = ta.ema(src, emaSlow)
atr    = ta.atr(atrLen)
volMA  = ta.sma(volume, volLen)

// Trend
bullTrend = emaF >= emaS   // ผ่อนจาก > เป็น >= 
bearTrend = emaF <= emaS

// ATR Filter (ผ่อนลงมาก)
atrAvg   = ta.sma(atr, atrLen)
atrValid = atr >= atrAvg * atrMult

// Volume Filter
volValid = useVolFilter ? volume > volMA * 0.8 : true

// Candle Body Filter (ผ่อนลง)
bodySize    = math.abs(close - open)
candleRange = high - low
bodyValid   = candleRange > 0 ? bodySize / candleRange >= 0.2 : true

// ============================================================
//                    SIGNAL CONDITIONS
// ============================================================

// BUY — เพิ่ม 3 แบบ รวมกัน
buySignal1 = (ta.crossover(rsiVal, rsiOversold)
     and close > emaF
     and atrValid
     and volValid)

buySignal2 = (rsiVal < 40
     and close > emaF
     and ta.crossover(close, emaF)
     and atrValid)

buySignal3 = (ta.crossover(emaF, emaS)
     and rsiVal < 60
     and atrValid)

goldBuy = buySignal1 or buySignal2 or buySignal3

// SELL — เพิ่ม 3 แบบ รวมกัน
sellSignal1 = (ta.crossunder(rsiVal, rsiOverbought)
     and close < emaF
     and atrValid
     and volValid)

sellSignal2 = (rsiVal > 60
     and close < emaF
     and ta.crossunder(close, emaF)
     and atrValid)

sellSignal3 = (ta.crossunder(emaF, emaS)
     and rsiVal > 40
     and atrValid)

goldSell = sellSignal1 or sellSignal2 or sellSignal3

// ============================================================
//                      SL / TP LEVELS
// ============================================================
var float buySL  = na
var float buyTP1 = na
var float buyTP2 = na
var float sellSL  = na
var float sellTP1 = na
var float sellTP2 = na

if goldBuy
    buySL  := close - atr * atrSL
    buyTP1 := close + atr * atrTP
    buyTP2 := close + atr * atrTP * 2

if goldSell
    sellSL  := close + atr * atrSL
    sellTP1 := close - atr * atrTP
    sellTP2 := close - atr * atrTP * 2

// ============================================================
//                        VISUALS
// ============================================================
plot(emaF, color=color.new(color.yellow, 0), linewidth=2, title="Fast EMA")
plot(emaS, color=color.new(color.white,  0), linewidth=2, title="Slow EMA")

plotshape(goldBuy,
     title="Sniper Buy",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.green, 0),
     text="▲ BUY",
     textcolor=color.white,
     size=size.normal)

plotshape(goldSell,
     title="Sniper Sell",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     text="▼ SELL",
     textcolor=color.white,
     size=size.normal)

// SL/TP
plot(showSLTP and goldBuy[0]  ? buySL  : na, color=color.red,  style=plot.style_linebr, linewidth=1, title="Buy SL")
plot(showSLTP and goldBuy[0]  ? buyTP1 : na, color=color.lime, style=plot.style_linebr, linewidth=1, title="Buy TP1")
plot(showSLTP and goldBuy[0]  ? buyTP2 : na, color=color.lime, style=plot.style_linebr, linewidth=1, title="Buy TP2")
plot(showSLTP and goldSell[0] ? sellSL  : na, color=color.red,  style=plot.style_linebr, linewidth=1, title="Sell SL")
plot(showSLTP and goldSell[0] ? sellTP1 : na, color=color.lime, style=plot.style_linebr, linewidth=1, title="Sell TP1")
plot(showSLTP and goldSell[0] ? sellTP2 : na, color=color.lime, style=plot.style_linebr, linewidth=1, title="Sell TP2")

// Trend Background
bgcolor(bullTrend ? color.new(color.green, 95) : bearTrend ? color.new(color.red, 95) : na)

// ============================================================
//                        ALERTS
// ============================================================
alertcondition(goldBuy,  title="Gold Buy Alert",  message="🟢 GOLD SNIPER BUY Signal!")
alertcondition(goldSell, title="Gold Sell Alert", message="🔴 GOLD SNIPER SELL Signal!")
````
