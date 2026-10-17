# Classic EMA 9/21 crossover with Buy/Sell signal

- url: https://www.tradingview.com/script/g2vSmtry-Classic-EMA-9-21-crossover-with-Buy-Sell-signal/
- type: indicator
- pine_id: PUB;57d555450bff4e699800c4d33a2e240c
- version: 1.0

## Description

Good oldschool that worked really well in bigger TF like day, week, month

## Source Code

````pine
//@version=5
indicator("EMA Cross with Buy/Sell Label", overlay=true)

// --- ส่วนของการตั้งค่า (Inputs) ---
shortLen = input.int(9, title="EMA เส้นสั้น (9)")
longLen = input.int(21, title="EMA เส้นยาว (21)")

// --- ส่วนของการคำนวณ (Calculations) ---
emaShort = ta.ema(close, shortLen)
emaLong = ta.ema(close, longLen)

// เงื่อนไขการตัดกัน
buySignal  = ta.crossover(emaShort, emaLong)  // 9 ตัด 21 ขึ้น
sellSignal = ta.crossunder(emaShort, emaLong) // 9 ตัด 21 ลง

// --- ส่วนของการแสดงผล (Plotting) ---
plot(emaShort, color=color.blue, linewidth=2, title="EMA 9")
plot(emaLong, color=color.red, linewidth=2, title="EMA 21")

// แสดงสัญลักษณ์พร้อมข้อความ "BUY" เมื่อตัดขึ้น
plotshape(buySignal, 
     style=shape.labelup, 
     location=location.belowbar, 
     color=color.new(color.green, 0), 
     size=size.small, 
     text="BUY", 
     textcolor=color.white, 
     title="Buy Label")

// แสดงสัญลักษณ์พร้อมข้อความ "SELL" เมื่อตัดลง
plotshape(sellSignal, 
     style=shape.labeldown, 
     location=location.abovebar, 
     color=color.new(color.red, 0), 
     size=size.small, 
     text="SELL", 
     textcolor=color.white, 
     title="Sell Label")

// --- ระบบแจ้งเตือน (Alerts) ---
alertcondition(buySignal, title="สัญญาณซื้อ", message="EMA 9 ตัด EMA 21 ขึ้น: BUY")
alertcondition(sellSignal, title="สัญญาณขาย", message="EMA 9 ตัด EMA 21 ลง: SELL")
````
