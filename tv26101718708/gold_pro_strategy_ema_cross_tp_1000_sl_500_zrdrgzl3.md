# Gold Pro Strategy: EMA Cross (TP 1000, SL 500)

- url: https://www.tradingview.com/script/ZrdRGzl3/
- type: strategy
- pine_id: PUB;485ee26e42c04eb4ab05ab8512e2d521
- version: 1.0

## Description

1.	จุดเข้า (Entry Point):
•	Buy (Long): เข้าเมื่อ EMA เส้นเร็ว (9) ตัดขึ้นเหนือ EMA เส้นช้า (21) สะท้อนถึงโมเมนตัมขาขึ้นในระยะสั้น.
•	Sell (Short): เข้าเมื่อ EMA เส้นเร็ว (9) ตัดลงใต้ EMA เส้นช้า (21) สะท้อนถึงโมเมนตัมขาลง.
2.	การทำกำไรและตัดขาดทุน (TP/SL):
•	TP (Take Profit): ตั้งไว้ที่ 1000 จุด (หรือ 10.00 USD สำหรับทองคำ) เพื่อเก็บกำไรในระยะกลาง.
•	SL (Stop Loss): ตั้งไว้ที่ 500 จุด (หรือ 5.00 USD) เพื่อรักษาความเสี่ยงในอัตราส่วน Risk:Reward ที่ 1:2 ซึ่งถือว่าเป็นสัดส่วนที่ยอดเยี่ยมสำหรับนักเทรดมือโปร.
3.	Timeframe ที่แนะนำ: แนะนำให้ใช้ในกรอบเวลา 15 นาที (M15) หรือ 1 ชั่วโมง (H1) เพื่อลดสัญญาณหลอก (Noise) ที่มักเกิดขึ้นบ่อยในทองคำ.
⚠️ ข้อแนะนำจากโปร
•	Backtest ก่อนเสมอ: ทองคำมีความผันผวนสูง ควรใช้ Strategy Tester ใน TradingView เพื่อดูผลลัพธ์ย้อนหลังก่อนใช้เงินจริง.
•	เลี่ยงช่วงข่าวแรง: ในช่วงประกาศตัวเลขเศรษฐกิจสำคัญ (เช่น Non-Farm) กราฟทองคำอาจสะบัดจนโดน SL ได้ง่าย แม้ระบบจะบอกให้เข้าก็ตาม.
คุณต้องการให้ผมปรับแต่งโค้ดเพิ่ม ตัวกรอง RSI เพื่อดูความแรงของราคา (Overbought/Oversold) ด้วยไหมครับ?

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © boonyalrit93067

//@version=5
strategy("Gold Pro Strategy: EMA Cross (TP 1000, SL 500)", overlay=true, initial_capital=1000, default_qty_type=strategy.cash, default_qty_value=1000)

// --- การตั้งค่า Input ---
emaFastLen = input.int(9, "EMA เส้นเร็ว", minval=1)
emaSlowLen = input.int(21, "EMA เส้นช้า", minval=1)
tpPoints = input.int(10000, "Take Profit (Points)", step=100) // ในทองคำ 1000 จุด = 10000 points ใน Pine Script
slPoints = input.int(5000, "Stop Loss (Points)", step=100)   // ในทองคำ 500 จุด = 5000 points ใน Pine Script

// --- การคำนวณอินดิเคเตอร์ ---
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// --- เงื่อนไขการเข้าเทรด ---
longCondition = ta.crossover(emaFast, emaSlow)
shortCondition = ta.crossunder(emaFast, emaSlow)

// --- การแสดงผลบนกราฟ ---
plot(emaFast, color=color.blue, title="EMA Fast")
plot(emaSlow, color=color.orange, title="EMA Slow")

// --- คำสั่งส่งคำสั่งเทรด (Execution) ---
// สำหรับฝั่ง Long (Buy)
if (longCondition)
    strategy.entry("Long", strategy.long)
    strategy.exit("Exit Long", "Long", loss = slPoints, profit = tpPoints, comment_loss="SL", comment_profit="TP")

// สำหรับฝั่ง Short (Sell)
if (shortCondition)
    strategy.entry("Short", strategy.short)
    strategy.exit("Exit Short", "Short", loss = slPoints, profit = tpPoints, comment_loss="SL", comment_profit="TP")

// --- การทำสีพื้นหลังเมื่อเกิดสัญญาณ ---
bgcolor(longCondition ? color.new(color.green, 80) : na)
bgcolor(shortCondition ? color.new(color.red, 80) : na)
````
