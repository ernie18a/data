# Market Leader PRO v6 (RSI + EMA)

- url: https://www.tradingview.com/script/NjXdoUmw/
- type: strategy
- pine_id: PUB;46a04abe88da46d1a5189a697cff9f11
- version: 2.0

## Description

📊 Market Leader PRO (RSI + EMA) – Strategy Description 
🧠 แนวคิดหลัก (Core Concept)

กลยุทธ์นี้ถูกออกแบบเพื่อ จับหุ้น/สินทรัพย์ที่เป็น “ผู้นำรอบ (Market Leader)”
โดยเน้นเทรดตาม แนวโน้มหลัก (Trend Following) และใช้ Momentum + Structure เป็นตัวคัดกรอง

เป้าหมาย: เข้า “ตัวที่เงินใหญ่กำลังเล่น” และถือไปกับเทรนด์

⚙️ องค์ประกอบของระบบ
1) 📈 Trend Filter — EMA200
ใช้ EMA200 เป็นตัวกำหนดแนวโน้มหลัก
เทรดเฉพาะฝั่ง Long เมื่อราคาอยู่เหนือ EMA200 และเส้นเอียงขึ้น

👉 ตัดสินใจง่าย:

เหนือ = เล่น
ใต้ = งด
2) ⚡ Momentum Structure — EMA Stack

ใช้ EMA หลายเส้นเพื่อดู “ความแข็งของเทรนด์”

EMA12 > EMA26 > EMA49 > EMA89 > EMA200

👉 ถ้าเรียงแบบนี้ =
Trend แข็ง + Momentum ต่อเนื่อง (Institutional Trend)

3) 📊 RSI Confirmation

ใช้ RSI (14) เป็นตัว “ยืนยันแรง”

RSI > 50 = ฝั่งกระทิงคุมเกม
RSI 55–65 = โซนที่ดีที่สุด (Strong Trend)
RSI < 45 = เริ่มเสียแรง

👉 หุ้น/สินทรัพย์ที่เป็น Leader จริง
จะ “ไม่หลุด RSI 50 บ่อย”

🚀 เงื่อนไขเข้า (Entry Setup)
1) Breakout Entry
ราคาเบรก High 20 แท่ง
RSI 55–70
EMA เรียงครบ

👉 ใช้ตอนตลาด “มีแรง” → ได้รอบใหญ่

2) Pullback Entry (แนะนำที่สุด)
ราคาย่อ EMA26–EMA49
RSI ลงมาแล้วเด้งกลับ > 50
ยังอยู่เหนือ EMA200

👉 จุดนี้ให้ Risk/Reward ดีที่สุด

❌ เงื่อนไขออก (Exit Logic)
1) Trend เริ่มเสีย
ราคาหลุด EMA89 + RSI < 45
2) Momentum หาย
EMA12 ตัดลง EMA26
3) จบรอบ
ราคาหลุด EMA200
💰 Risk Management (หัวใจระบบ)
🔹 Stop Loss
ใช้ % จากราคาเข้า (เช่น 1–2%)
🔹 Take Profit
ตั้งเป้า 2–4% (ทอง) / 5–10% (หุ้น)
🔹 Trailing Stop
ล็อกกำไรเมื่อราคาวิ่งต่อ
🔹 Breakeven
เมื่อกำไรถึงระดับที่กำหนด → เลื่อน Stop มาที่ทุน

👉 ทำให้:

“กำไรปล่อยวิ่ง”
“ขาดทุนคุมได้”
🔥 จุดเด่นของกลยุทธ์
✅ จับ “หุ้นผู้นำรอบ” ได้จริง
✅ ใช้ Trend + Momentum + Volume logic
✅ ลดการเทรดมั่ว (มี filter EMA200)
✅ เหมาะกับ TF 1H / 4H / Day
✅ ใช้ได้ทั้ง หุ้น / ทอง / Crypto
⚠️ ข้อจำกัด (ต้องเข้าใจ)
❌ ตลาด Sideway → จะโดน stop บ้าง (ปกติของ trend system)
❌ ไม่เหมาะกับการ “เด้งสั้นสวนเทรนด์”
❌ ต้องมีวินัยตามระบบ (ห้าม override)
🧠 Insight ระดับมืออาชีพ
Leader จริง =
ขึ้นแรง + ลงน้อย + ฟื้นเร็ว
ถ้าราคา:
ไม่หลุด EMA26 บ่อย
RSI อยู่เหนือ 50 ตลอด

👉 = “เงินใหญ่ถืออยู่”

🎯 สรุปกลยุทธ์ (โคตรสั้น)

“เล่นเฉพาะของที่อยู่เหนือ EMA200
รอให้ย่อเข้า EMA
เข้าเมื่อ RSI กลับมายืน >50
แล้วถือจนกว่าโครงสร้างจะเสีย”# 📊 Market Leader PRO (RSI + EMA) – Strategy Description

## 🧠 Core Concept

This strategy is designed to **identify and trade “Market Leaders”** — stocks or assets that are leading the current cycle.
It focuses on **Trend Following**, using **Momentum + Structure** as key filters.

**Objective:** Enter assets where institutional money is flowing, and ride the trend.

---

## ⚙️ System Components

### 1) 📈 Trend Filter — EMA200

The **EMA200** defines the primary trend.
Only take **long positions when price is above EMA200 and the slope is upward**.

👉 Simple rule:

* Above = Trade
* Below = Avoid

---

### 2) ⚡ Momentum Structure — EMA Stack

Multiple EMAs are used to measure trend strength:

EMA12 > EMA26 > EMA49 > EMA89 > EMA200

👉 When aligned:

* Strong trend
* Sustained momentum
* Institutional participation

---

### 3) 📊 RSI Confirmation

RSI (14) is used to confirm momentum strength:

* RSI > 50 → Bullish control
* RSI 55–65 → Optimal “strong trend” zone
* RSI < 45 → Weakening momentum

👉 True market leaders typically **hold above RSI 50 consistently**

---

## 🚀 Entry Conditions

### 1) Breakout Entry

* Price breaks above 20-period high
* RSI between 55–70
* EMA stack fully aligned

👉 Best for strong momentum phases → captures large moves

---

### 2) Pullback Entry (Recommended)

* Price retraces to EMA26–EMA49
* RSI dips and reclaims above 50
* Price remains above EMA200

👉 Provides the **best risk/reward setup**

---

## ❌ Exit Conditions

### 1) Trend Weakening

* Price breaks below EMA89 + RSI < 45

### 2) Momentum Loss

* EMA12 crosses below EMA26

### 3) Trend Reversal

* Price breaks below EMA200

---

## 💰 Risk Management (Core of the System)

🔹 **Stop Loss**

* Defined as % from entry (e.g., 1–2%)

🔹 **Take Profit**

* 2–4% (Gold) / 5–10% (Stocks)

🔹 **Trailing Stop**

* Locks in profits as price moves

🔹 **Breakeven**

* Move stop to entry once profit threshold is reached

👉 Result:

* Let profits run
* Cut losses quickly

---

## 🔥 Strengths of the Strategy

* ✅ Effectively captures Market Leaders
* ✅ Combines Trend + Momentum + Structure
* ✅ Reduces random trades (EMA200 filter)
* ✅ Works on 1H / 4H / Daily timeframes
* ✅ Applicable to Stocks / Gold / Crypto

---

## ⚠️ Limitations

* ❌ Underperforms in sideways markets (normal for trend systems)
* ❌ Not suitable for counter-trend scalping
* ❌ Requires strict discipline (no override)

---

## 🧠 Professional Insight

**True Leaders = Strong up moves + shallow pullbacks + fast recovery**

If price:

* Rarely breaks below EMA26
* Holds RSI above 50 consistently

👉 Indicates **institutional accumulation**

---

## 🎯 Strategy Summary (Ultra Short)

**“Trade only above EMA200
Buy pullbacks into EMA
Enter when RSI reclaims >50
Hold until structure breaks”**

## Source Code

````pine
//@version=6
strategy("Market Leader PRO v6 (Supertrend + Structure + Volume)", overlay=true,
     initial_capital=100000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=15)

// =====================
// 🔧 INPUT
// =====================
atrPeriod = input.int(10, "ATR Length")
factor    = input.float(3.0, "Supertrend Factor")

emaLen    = input.int(200, "EMA Trend")
rsiLen    = input.int(14, "RSI Length")
rsiLevel  = input.int(50, "RSI Threshold")

volLen    = input.int(20, "Volume SMA Length")

// Structure
lookback  = input.int(20, "Breakout Lookback")

// Risk
tp_percent = input.float(1.2, "TP (%)")
sl_percent = input.float(0.6, "SL (%)")

// =====================
// 📊 INDICATORS
// =====================
[st, direction] = ta.supertrend(factor, atrPeriod)
ema200 = ta.ema(close, emaLen)
rsi    = ta.rsi(close, rsiLen)

// Volume
volMA  = ta.sma(volume, volLen)
highVol = volume > volMA

// Structure (Breakout)
highestHigh = ta.highest(high, lookback)
lowestLow   = ta.lowest(low, lookback)

// =====================
// 🎯 CONDITIONS
// =====================

// LONG CONDITIONS
trendUp     = close > ema200
momentumUp  = rsi > rsiLevel
stUp        = ta.change(direction) < 0
breakoutUp  = close > highestHigh[1]
volumeUp    = highVol

longSignal = trendUp and momentumUp and stUp and breakoutUp and volumeUp

// SHORT CONDITIONS
trendDown     = close < ema200
momentumDown  = rsi < rsiLevel
stDown        = ta.change(direction) > 0
breakoutDown  = close < lowestLow[1]
volumeDown    = highVol

shortSignal = trendDown and momentumDown and stDown and breakoutDown and volumeDown

// =====================
// 🚀 ENTRY
// =====================
if (longSignal and strategy.position_size == 0)
    strategy.entry("Long", strategy.long)

if (shortSignal and strategy.position_size == 0)
    strategy.entry("Short", strategy.short)

// =====================
// 🛑 EXIT (Trend Change)
// =====================
if (ta.change(direction) > 0 and strategy.position_size > 0)
    strategy.close("Long")

if (ta.change(direction) < 0 and strategy.position_size < 0)
    strategy.close("Short")

// =====================
// 🎯 TP / SL
// =====================
if (strategy.position_size > 0)
    strategy.exit("TP/SL Long", from_entry="Long",
        limit = strategy.position_avg_price * (1 + tp_percent/100),
        stop  = strategy.position_avg_price * (1 - sl_percent/100))

if (strategy.position_size < 0)
    strategy.exit("TP/SL Short", from_entry="Short",
        limit = strategy.position_avg_price * (1 - tp_percent/100),
        stop  = strategy.position_avg_price * (1 + sl_percent/100))

// =====================
// 🎨 VISUAL
// =====================
bgcolor(strategy.position_size > 0 ? color.new(color.green, 85) : na)
bgcolor(strategy.position_size < 0 ? color.new(color.red, 85) : na)

plot(ema200, "EMA 200", color=color.yellow)
plot(st, "Supertrend", color = direction < 0 ? color.green : color.red)

// Breakout Levels
plot(highestHigh, "Resistance", color=color.red, style=plot.style_linebr)
plot(lowestLow, "Support", color=color.green, style=plot.style_linebr)
````
