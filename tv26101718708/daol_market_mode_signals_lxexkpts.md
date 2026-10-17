# [DAOL] Market Mode Signals

- url: https://www.tradingview.com/script/LXEXkPts-DAOL-Market-Mode-Signals/
- type: indicator
- pine_id: PUB;8538448cd51443cd984143cb594d01a7
- version: 1.0

## Description

⏺️ What is it?

[DAOL] Market Mode Signals identifies uptrend, downtrend, range and transition conditions, then applies different signal rules to each environment.

It combines EMA alignment and slope, DMI/ADX, Kaufman’s Efficiency Ratio and a prior-bar price channel. ATR adjusts setup tolerances and stop buffers to recent volatility.

The indicator displays confirmed BUY/SELL signals and tracks one signal at a time using fixed reference, stop and target levels.

It is an indicator, not an order execution system or a Strategy Tester backtest.

⏺️ Indicator นี้คืออะไร?

[DAOL] Market Mode Signals เป็นอินดิเคเตอร์ที่แยกสภาวะตลาดเป็น ขาขึ้น ขาลง ไซด์เวย์ และช่วงเปลี่ยนผ่าน แล้วเลือกเงื่อนไขสัญญาณให้เหมาะกับแต่ละสภาวะ

ผสมหลักการ EMA, DMI/ADX, Efficiency Ratio และกรอบราคาจากแท่งก่อนหน้า พร้อมใช้ ATR ปรับระยะตามความผันผวน

แสดงสัญญาณ BUY/SELL เมื่อแท่งปิดยืนยัน และติดตามครั้งละหนึ่งรอบ พร้อมตรึงราคาอ้างอิง Stop และ Target

เป็นอินดิเคเตอร์สำหรับประกอบการวิเคราะห์ ไม่ได้ส่งคำสั่งซื้อขายหรือแสดงผล Backtest ใน Strategy Tester

⏺️ How are market conditions classified?

🔹 UPTREND: Fast EMA above slow EMA, rising slow EMA, +DI above −DI, and ADX/ER meeting the trend thresholds.
🔹 DOWNTREND: Fast EMA below slow EMA, falling slow EMA, −DI above +DI, and ADX/ER meeting the trend thresholds.
🔹 RANGE: Both ADX and ER at or below their range thresholds.
🔹 TRANSITION: None of the above conditions is satisfied.

By default, a condition must persist for two consecutive closed bars before becoming the confirmed market mode. New setups also require the current classification to agree with that confirmed mode.

ADX measures trend strength; the EMA and DI conditions determine direction.

⏺️ แยกสภาวะตลาดอย่างไร?

🔹 UPTREND: EMA สั้นอยู่เหนือ EMA ยาว เส้นยาวมีความชันขึ้น +DI มากกว่า −DI และ ADX/ER ผ่านเกณฑ์แนวโน้ม
🔹 DOWNTREND: EMA สั้นอยู่ใต้ EMA ยาว เส้นยาวมีความชันลง −DI มากกว่า +DI และ ADX/ER ผ่านเกณฑ์แนวโน้ม
🔹 RANGE: ADX และ ER ต่ำกว่าหรือเท่ากับเกณฑ์ไซด์เวย์ทั้งคู่
🔹 TRANSITION: เงื่อนไขไม่เข้ากลุ่มข้างต้น ระบบงดสร้างจังหวะใหม่

ค่าเริ่มต้นรอสภาวะเดียวกัน สองแท่งปิดต่อเนื่อง ก่อนยืนยันโหมด และเงื่อนไขปัจจุบันต้องตรงกับโหมดยืนยันจึงจะเริ่มสร้างจังหวะได้

ADX ใช้อ่านความแข็งแรงของแนวโน้ม ส่วน EMA และ DI ใช้อ่านทิศทาง

⏺️ How are signals generated?

Trend signals

In an uptrend, price must test the fast EMA area and close back above it with a bullish body, while respecting the slow EMA conditions. A subsequent bar must close above the setup close with a bullish body.

The downtrend signal uses the opposite conditions.

Range signals

In a range, price must test the lower or upper channel area and close inside the channel with a directional body:

🔹 Lower-area rejection → potential BUY setup
🔹 Upper-area rejection → potential SELL setup

A subsequent bar must close further in the proposed direction with a matching candle body. The target is the frozen channel midpoint, and the signal must satisfy the minimum reward-to-risk requirement.

Both signal types require confirmation within the setup expiry window and within one frozen ATR of the setup close. A setup is cancelled if its stop boundary is touched, the market classification changes, or the setup expires. Range setups are also cancelled if price closes at or beyond either frozen channel boundary.

⏺️ สัญญาณเกิดขึ้นอย่างไร?

สัญญาณตามแนวโน้ม

ตลาดขาขึ้น: ราคาทดสอบบริเวณ EMA สั้น แล้วปิดกลับเหนือเส้นด้วยแท่งขึ้น โดยยังผ่านเงื่อนไข EMA ยาว จากนั้นรอแท่งถัดไปปิดสูงกว่าราคาปิดของแท่งตั้งต้น พร้อมเป็นแท่งขึ้น

ตลาดขาลง: ใช้เงื่อนไขตรงข้าม เพื่อรอราคาเด้งแล้วอ่อนตัวต่อ

สัญญาณไซด์เวย์

ราคาทดสอบบริเวณขอบกรอบ แล้วปิดกลับอยู่ภายในกรอบด้วยแท่งที่สนับสนุนทิศทาง:

🔹 ทดสอบขอบล่างแล้วฟื้น → รอ BUY
🔹 ทดสอบขอบบนแล้วอ่อนตัว → รอ SELL

จากนั้นรอแท่งยืนยันปิดเดินหน้าต่อในทิศทางนั้น โดย เป้าหมายอยู่ที่กึ่งกลางกรอบที่ตรึงไว้ และต้องมี Reward/Risk ผ่านเกณฑ์ขั้นต่ำ

ทั้งสองรูปแบบต้องยืนยันภายในเวลาที่กำหนด และราคายืนยันต้องห่างจากราคาปิดแท่งตั้งต้นไม่เกินหนึ่ง ATR ที่ตรึงไว้

ระบบยกเลิกจังหวะเมื่อแตะขอบเขต Stop สภาวะตลาดเปลี่ยน หรือหมดเวลารอยืนยัน สำหรับจังหวะไซด์เวย์จะยกเลิกเพิ่มเติมเมื่อราคาปิดถึงหรือออกนอกขอบกรอบที่ตรึงไว้

⏺️ Reading the chart

🔹 BUY Trend / SELL Trend: Confirmed trend-pullback signal
🔹 BUY Range / SELL Range: Confirmed range-rebound signal
🔹 White line: Signal closing-price reference
🔹 Red line: Fixed stop reference
🔹 Green line: Fixed target reference

Background colors show the confirmed market mode:

🔹 Green — uptrend
🔹 Red — downtrend
🔹 Aqua — range
🔹 Gray — transition

BUY indicates a long-direction setup. SELL indicates a short-direction setup, not an instruction to close an existing long position.

⏺️ วิธีอ่านกราฟ

🔹 BUY Trend / SELL Trend: สัญญาณย่อหรือเด้งตามแนวโน้มที่ยืนยันแล้ว
🔹 BUY Range / SELL Range: สัญญาณฟื้นหรืออ่อนตัวจากขอบกรอบไซด์เวย์ที่ยืนยันแล้ว
🔹 เส้นขาว: ราคาปิดของแท่งสัญญาณ ใช้เป็นราคาอ้างอิง
🔹 เส้นแดง: ระดับ Stop ที่ตรึงไว้
🔹 เส้นเขียว: ระดับ Target ที่ตรึงไว้

สีพื้นหลังแสดงโหมดตลาดที่ยืนยัน:

🔹 เขียว — ขาขึ้น
🔹 แดง — ขาลง
🔹 ฟ้า — ไซด์เวย์
🔹 เทา — ช่วงเปลี่ยนผ่าน

BUY หมายถึงจังหวะฝั่ง Long ส่วน SELL หมายถึงจังหวะฝั่ง Short ไม่ใช่คำสั่งปิด Long ที่ถืออยู่

⏺️ Signal tracking and reference levels

The entry reference is the signal bar’s close. It is not a guaranteed execution price.

The stop is placed beyond the setup bar’s low or high, with a frozen ATR buffer and tick-size rounding.

🔹 Trend target — two times the reference risk by default
🔹 Range target — the frozen channel midpoint
🔹 Range minimum reward/risk — 1.2 by default

Tracking begins on the bar after the signal. Levels remain fixed, and a change in market mode alone does not end an active signal.

Tracking ends when:

🔹 STOP: Only the stop level is touched
🔹 TARGET: Only the target level is touched
🔹 BOTH: Both levels are touched within one bar; their order is unknown
🔹 EXPIRE: Neither level has been touched within the maximum tracking period

These markers describe price-level touches. They do not calculate realized returns or order fills.

⏺️ การติดตามสัญญาณและระดับอ้างอิง

ราคาอ้างอิงเข้าคือ ราคาปิดแท่งสัญญาณ ไม่ใช่ราคาที่รับประกันว่าจะซื้อขายได้จริง

Stop อยู่เลยจุดต่ำหรือสูงของแท่งตั้งต้น โดยเพิ่มระยะ ATR ที่ตรึงไว้ และปรับตามขนาด Tick

🔹 เป้าหมาย Trend — ค่าเริ่มต้นสองเท่าของระยะเสี่ยงอ้างอิง
🔹 เป้าหมาย Range — กึ่งกลางกรอบที่ตรึงไว้
🔹 Reward/Risk ขั้นต่ำของ Range — ค่าเริ่มต้น 1.2

เริ่มตรวจระดับตั้งแต่ แท่งถัดจากแท่งสัญญาณ ระดับจะคงที่ และการเปลี่ยนโหมดตลาดเพียงอย่างเดียวไม่ทำให้รอบที่ติดตามอยู่สิ้นสุด

เครื่องหมายสิ้นสุดรอบ:

🔹 STOP: แตะเฉพาะระดับ Stop
🔹 TARGET: แตะเฉพาะระดับ Target
🔹 BOTH: แตะทั้งสองระดับในแท่งเดียว ไม่ทราบว่าแตะระดับใดก่อน
🔹 EXPIRE: ยังไม่แตะระดับใดเมื่อครบระยะติดตาม

เครื่องหมายเหล่านี้แสดงการแตะระดับราคา ไม่ใช่ผลกำไรขาดทุนหรือการจับคู่คำสั่งซื้อขายจริง

⏺️ Settings and alerts

Signal modes:

🔹 Auto: Allow trend and range signals according to market conditions
🔹 Trend Only: Allow trend signals only
🔹 Range Only: Allow range signals only

Key defaults:

🔹 EMA — 20 / 50
🔹 DMI/ADX — 14
🔹 Efficiency Ratio — 20
🔹 Trend thresholds — ADX ≥ 22 and ER ≥ 0.30
🔹 Range thresholds — ADX ≤ 18 and ER ≤ 0.20
🔹 Prior-bar channel — 40 bars
🔹 ATR — 14, using the preceding bar’s value
🔹 Market confirmation — 2 closed bars
🔹 Setup confirmation window — up to 3 subsequent bars
🔹 Tracking expiry — 80 subsequent bars
🔹 Cooldown — 5 complete bars after tracking ends

Alerts are available for each signal type, any BUY, any SELL and tracking completion. Set alerts to “Once Per Bar Close” and recreate them after changing inputs or code.

⏺️ การตั้งค่าและ Alert

เลือกโหมดได้:

🔹 Auto: ใช้ทั้งสัญญาณ Trend และ Range ตามสภาวะตลาด
🔹 Trend Only: ใช้เฉพาะสัญญาณตามแนวโน้ม
🔹 Range Only: ใช้เฉพาะสัญญาณไซด์เวย์

ค่าเริ่มต้นสำคัญ:

🔹 EMA — 20 / 50
🔹 DMI/ADX — 14
🔹 Efficiency Ratio — 20
🔹 เกณฑ์ Trend — ADX ≥ 22 และ ER ≥ 0.30
🔹 เกณฑ์ Range — ADX ≤ 18 และ ER ≤ 0.20
🔹 กรอบราคาจากแท่งก่อนหน้า — 40 แท่ง
🔹 ATR — 14 ใช้ค่าจากแท่งก่อนหน้า
🔹 ยืนยันโหมด — 2 แท่งปิด
🔹 รอยืนยันจังหวะ — ไม่เกิน 3 แท่งถัดไป
🔹 หมดระยะติดตาม — 80 แท่งถัดไป
🔹 เว้นระยะหลังจบรอบ — 5 แท่งเต็ม

มี Alert แยกตามประเภทสัญญาณ รวม BUY รวม SELL และเมื่อสิ้นสุดการติดตาม ตั้งเป็น Once Per Bar Close และสร้าง Alert ใหม่หลังเปลี่ยน Input หรือโค้ด

⏺️ Development and references

This Pine Script v6 implementation was written for this indicator without copying Community script code.

The extension combines market-mode confirmation, mode-specific setups, frozen setup references, cancellation rules and single-signal tracking.

The underlying EMA, DMI/ADX, ATR, Efficiency Ratio and price-channel concepts are established methods. No claim is made that the combination is globally unique or that it guarantees profitable signals.

References:

🔹 J. Welles Wilder Jr. — New Concepts in Technical Trading Systems (1978): Directional Movement, ADX and ATR
🔹 Perry J. Kaufman — Trading Systems and Methods: Efficiency Ratio
🔹 Donchian-style channels: historical highest-high and lowest-low references

Supporting documentation:

TradingView — Directional Movement

TradingView — Average True Range

TradingView — Kaufman’s Adaptive Moving Average

⏺️ การพัฒนาและอ้างอิง

เขียนด้วย Pine Script v6 สำหรับอินดิเคเตอร์นี้ โดยไม่คัดลอกโค้ดจากสคริปต์ Community

ส่วนที่พัฒนาต่อยอดคือการยืนยันโหมดตลาด การเลือกเงื่อนไขตามโหมด การตรึงระดับตั้งต้น การยกเลิกจังหวะที่ผิดเงื่อนไข และการติดตามครั้งละหนึ่งรอบ

EMA, DMI/ADX, ATR, Efficiency Ratio และกรอบราคาย้อนหลังเป็นหลักการที่มีอยู่แล้ว ไม่อ้างว่าแนวคิดผสมนี้ไม่เคยมีผู้ทำมาก่อน หรือรับประกันว่าสัญญาณจะทำกำไร

⏺️ Limitations and disclaimer

🔹 Use standard price charts. Synthetic chart types are rejected.
🔹 Settings are measured in bars; changing timeframe changes the elapsed time represented by each window.
🔹 The indicator has no TFEX-specific session filter, contract-roll handling or optimized S50/GO presets.
🔹 Market classification can lag or misclassify changing conditions.
🔹 Fixed stop and target references do not account for slippage, fees, gaps, liquidity or actual execution.
🔹 No win rate, profit factor or expected return has been established.
🔹 Static checks and basic level arithmetic were completed. TradingView compilation and market-data validation remain pending.
🔹 For educational and informational purposes only. Signals are analytical conditions, not personalized investment advice or guaranteed outcomes.

⏺️ ข้อจำกัดและคำชี้แจง

🔹 ใช้กับกราฟราคามาตรฐาน ระบบไม่รองรับกราฟราคาสังเคราะห์
🔹 การตั้งค่านับเป็นแท่ง เมื่อเปลี่ยน Timeframe ระยะเวลาจริงของแต่ละช่วงจะเปลี่ยนตาม
🔹 เวอร์ชันนี้ยังไม่มีตัวกรอง Session ของ TFEX การจัดการเปลี่ยนสัญญา หรือค่าที่ผ่านการปรับทดสอบเฉพาะ S50/GO
🔹 การจำแนกตลาดอาจล่าช้าหรือคลาดเคลื่อนเมื่อสภาวะเปลี่ยน
🔹 Stop/Target อ้างอิงไม่ได้รวม Slippage ค่าธรรมเนียม Gap สภาพคล่อง หรือการส่งคำสั่งจริง
🔹 ยังไม่มีผลยืนยัน Win Rate, Profit Factor หรือผลตอบแทนคาดหวัง
🔹 ตรวจโครงสร้างเบื้องต้นและสูตรระดับราคาแล้ว แต่ยังไม่ได้ compile ใน TradingView หรือทดสอบข้อมูลตลาดจริง
🔹 ใช้เพื่อการศึกษาและประกอบการวิเคราะห์ สัญญาณเป็นเงื่อนไขทางเทคนิค ไม่ใช่คำแนะนำลงทุนเฉพาะบุคคลหรือการรับประกันผลลัพธ์

## Source Code

````pine
//@version=6
indicator("[DAOL] Market Mode Signals", overlay=true, max_bars_back=1000)

// Original implementation combining standard concepts; no Community code reused.
// Wilder (1978), New Concepts in Technical Trading Systems: DMI/ADX, ATR.
// Kaufman, Trading Systems and Methods: Efficiency Ratio.
// Prior-bar high/low channel: Donchian-style range reference.
// https://www.tradingview.com/support/solutions/43000502250-directional-movement-dmi/
// https://www.tradingview.com/support/solutions/43000501823-average-true-range-atr/
// Educational signal tracker, NOT a strategy or broker execution simulator.
// No costs, fill assumptions, position sizing, or profitability statistics.

string mode = input.string("Auto", "Signal mode", options=["Auto", "Trend Only", "Range Only"])
int fastLen = input.int(20, "Fast EMA", minval=2, maxval=200)
int slowLen = input.int(50, "Slow EMA", minval=3, maxval=300)
int slopeLen = input.int(5, "Slow EMA slope bars", minval=1, maxval=50)
int dmiLen = input.int(14, "DMI / ADX length", minval=2, maxval=100)
int erLen = input.int(20, "Efficiency Ratio length", minval=2, maxval=200)
float trendAdx = input.float(22, "Trend ADX minimum", minval=1)
float rangeAdx = input.float(18, "Range ADX maximum", minval=1)
float trendEr = input.float(0.30, "Trend ER minimum", minval=0.01, maxval=1)
float rangeEr = input.float(0.20, "Range ER maximum", minval=0, maxval=0.99)
int modeBars = input.int(2, "Market mode confirmation bars", minval=1, maxval=10)
int channelLen = input.int(40, "Prior-bar channel length", minval=5, maxval=300)
int atrLen = input.int(14, "ATR length", minval=2, maxval=100)
float touchAtr = input.float(0.30, "Touch tolerance / ATR", minval=0, maxval=2)
float stopAtr = input.float(0.35, "Stop buffer / ATR", minval=0.05, maxval=3)
float trendRR = input.float(2, "Trend target / risk", minval=0.5, maxval=10)
float minRangeRR = input.float(1.2, "Minimum range reward / risk", minval=0.1, maxval=5)
int waitBars = input.int(3, "Setup expiry bars", minval=1, maxval=20)
int cooldown = input.int(5, "Cooldown after completed signal", minval=0, maxval=100)
int maxTrack = input.int(80, "Tracking expiry bars", minval=1, maxval=1000)
bool shade = input.bool(true, "Shade confirmed market mode")

if barstate.isfirst
    if not chart.is_standard
        runtime.error("Use a standard price chart.")
    if fastLen >= slowLen or rangeAdx >= trendAdx or rangeEr >= trendEr
        runtime.error("Fast EMA must be shorter than slow EMA. Range thresholds must be below trend thresholds.")

float fast = ta.ema(close, fastLen)
float slow = ta.ema(close, slowLen)
[diPlus, diMinus, adx] = ta.dmi(dmiLen, dmiLen)
float atr = ta.atr(atrLen)[1]
float path = math.sum(math.abs(ta.change(close)), erLen)
float er = path > 0 ? math.abs(close - close[erLen]) / path : 0.0
float top = ta.highest(high, channelLen)[1]
float bottom = ta.lowest(low, channelLen)[1]
float slope = slow - slow[slopeLen]
bool ready = not na(atr) and atr > 0 and not na(slope) and not na(path) and not na(adx) and not na(top) and top > bottom
// 1 uptrend, -1 downtrend, 2 range, 0 transition.
int raw = ready ? (adx >= trendAdx and er >= trendEr and fast > slow and slope > 0 and diPlus > diMinus ? 1 : adx >= trendAdx and er >= trendEr and fast < slow and slope < 0 and diMinus > diPlus ? -1 : adx <= rangeAdx and er <= rangeEr ? 2 : 0) : 0
var int candidate = 0
var int streak = 0
var int regime = 0
var int setupDir = 0
var int setupMode = 0
var int setupBar = na
var float trigger = na
var float setupStop = na
var float setupTarget = na
var float setupAtr = na
var float frozenTop = na
var float frozenBottom = na
var int activeDir = 0
var int activeBar = na
var int lastEnd = na
var float entry = na
var float stop = na
var float target = na
var string status = "Waiting for data"
bool buyTrend = false
bool sellTrend = false
bool buyRange = false
bool sellRange = false
bool stopEvent = false
bool targetEvent = false
bool expiryEvent = false
bool ambiguousEvent = false

if barstate.isconfirmed
    candidate := raw == candidate ? candidate : raw
    streak := raw == raw[1] ? streak + 1 : 1
    if streak >= modeBars
        regime := candidate
    bool ended = false
    // Never test entry-bar extremes against levels created at that bar's close.
    if activeDir != 0 and bar_index > activeBar
        bool hitStop = activeDir == 1 ? low <= stop : high >= stop
        bool hitTarget = activeDir == 1 ? high >= target : low <= target
        ambiguousEvent := hitStop and hitTarget
        stopEvent := hitStop and not hitTarget
        targetEvent := hitTarget and not hitStop
        expiryEvent := not hitStop and not hitTarget and bar_index - activeBar >= maxTrack
        ended := hitStop or hitTarget or expiryEvent
        if ended
            status := ambiguousEvent ? "Both touched: order unknown" : stopEvent ? "Stop touched" : targetEvent ? "Target touched" : "Tracking expired"
            activeDir := 0
            lastEnd := bar_index

    if setupDir != 0
        bool invalid = not ready or raw != setupMode or regime != setupMode or bar_index - setupBar > waitBars
        invalid := invalid or (setupDir == 1 ? low <= setupStop : high >= setupStop)
        if setupMode == 2
            invalid := invalid or close >= frozenTop or close <= frozenBottom
        if invalid
            setupDir := 0
            status := "Setup cancelled"
        else if bar_index > setupBar
            bool confirm = setupDir == 1 ? close > trigger and close > open : close < trigger and close < open
            float risk = setupDir == 1 ? close - setupStop : setupStop - close
            float proposedTarget = setupMode == 2 ? setupTarget : close + setupDir * risk * trendRR
            float reward = setupDir * (proposedTarget - close)
            bool distanceOK = math.abs(close - trigger) <= setupAtr
            bool rewardOK = risk >= syminfo.mintick and reward > 0 and (setupMode != 2 or reward / risk >= minRangeRR)
            if confirm and distanceOK and rewardOK
                activeDir := setupDir
                activeBar := bar_index
                entry := close
                stop := setupStop
                target := activeDir == 1 ? math.floor(proposedTarget / syminfo.mintick) * syminfo.mintick : math.ceil(proposedTarget / syminfo.mintick) * syminfo.mintick
                buyTrend := setupDir == 1 and setupMode == 1
                sellTrend := setupDir == -1 and setupMode == -1
                buyRange := setupDir == 1 and setupMode == 2
                sellRange := setupDir == -1 and setupMode == 2
                status := setupMode == 2 ? "Tracking range signal" : "Tracking trend signal"
                setupDir := 0

    bool canArm = ready and activeDir == 0 and setupDir == 0 and not ended and (na(lastEnd) or bar_index - lastEnd > cooldown)
    if canArm and regime == raw
        int direction = 0
        bool allowTrend = mode != "Range Only"
        bool allowRange = mode != "Trend Only"
        if allowTrend and regime == 1 and low <= fast + touchAtr * atr and close > slow and close > open and close > fast and low > slow - touchAtr * atr
            direction := 1
        else if allowTrend and regime == -1 and high >= fast - touchAtr * atr and close < slow and close < open and close < fast and high < slow + touchAtr * atr
            direction := -1
        else if allowRange and regime == 2 and close > bottom and close < top
            bool lowerTest = low <= bottom + touchAtr * atr and close < bottom + (top - bottom) * 0.35 and close > open
            bool upperTest = high >= top - touchAtr * atr and close > top - (top - bottom) * 0.35 and close < open
            direction := lowerTest and not upperTest ? 1 : upperTest and not lowerTest ? -1 : 0
        if direction != 0
            setupDir := direction
            setupMode := regime
            setupBar := bar_index
            setupAtr := atr
            trigger := close
            frozenTop := top
            frozenBottom := bottom
            float rawStop = direction == 1 ? low - stopAtr * atr : high + stopAtr * atr
            setupStop := direction == 1 ? math.floor(rawStop / syminfo.mintick) * syminfo.mintick : math.ceil(rawStop / syminfo.mintick) * syminfo.mintick
            setupTarget := (top + bottom) / 2
            status := direction == 1 ? "Waiting BUY confirmation" : "Waiting SELL confirmation"

color modeColor = regime == 1 ? color.lime : regime == -1 ? color.red : regime == 2 ? color.aqua : color.gray
bgcolor(shade ? color.new(modeColor, 93) : na, title="Confirmed market mode")
plot(fast, "Fast EMA", color=color.orange)
plot(slow, "Slow EMA", color=color.blue, linewidth=2)
plot(activeDir != 0 ? entry : na, "Signal reference", color=color.white, style=plot.style_linebr)
plot(activeDir != 0 ? stop : na, "Frozen stop", color=color.red, style=plot.style_linebr)
plot(activeDir != 0 ? target : na, "Frozen target", color=color.lime, style=plot.style_linebr)
plotshape(buyTrend, title="Trend BUY", text="BUY\nTrend", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.tiny)
plotshape(sellTrend, title="Trend SELL", text="SELL\nTrend", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)
plotshape(buyRange, title="Range BUY", text="BUY\nRange", style=shape.labelup, location=location.belowbar, color=color.aqua, textcolor=color.black, size=size.tiny)
plotshape(sellRange, title="Range SELL", text="SELL\nRange", style=shape.labeldown, location=location.abovebar, color=color.orange, textcolor=color.black, size=size.tiny)
plotshape(stopEvent, title="Stop touched", text="STOP", style=shape.xcross, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(targetEvent, title="Target touched", text="TARGET", style=shape.circle, location=location.abovebar, color=color.lime, size=size.tiny)
plotshape(ambiguousEvent, title="Both levels touched", text="BOTH", style=shape.diamond, location=location.abovebar, color=color.yellow, size=size.tiny)
plotshape(expiryEvent, title="Tracking expired", text="EXPIRE", style=shape.xcross, location=location.abovebar, color=color.gray, size=size.tiny)
plot(er, "Efficiency Ratio", display=display.data_window)
plot(adx, "ADX", display=display.data_window)

var table panel = table.new(position.top_right, 2, 4, border_width=1)
if barstate.islast
    string market = not ready ? "Building data" : regime == 1 ? "UPTREND" : regime == -1 ? "DOWNTREND" : regime == 2 ? "RANGE" : "TRANSITION"
    table.cell(panel, 0, 0, "Market mode", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 0, market, text_color=modeColor, bgcolor=color.black)
    table.cell(panel, 0, 1, "Signal status", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 1, status, text_color=color.white, bgcolor=color.black)
    table.cell(panel, 0, 2, "ADX / ER", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 2, str.tostring(adx, "#.0") + " / " + str.tostring(er, "#.00"), text_color=color.white, bgcolor=color.black)
    table.cell(panel, 0, 3, "Tracking", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 3, activeDir == 1 ? "LONG reference" : activeDir == -1 ? "SHORT reference" : "None", text_color=color.white, bgcolor=color.black)

alertcondition(buyTrend, "Trend BUY", "Market Mode Signals: confirmed Trend BUY. Reference is signal close.")
alertcondition(sellTrend, "Trend SELL", "Market Mode Signals: confirmed Trend SELL. Reference is signal close.")
alertcondition(buyRange, "Range BUY", "Market Mode Signals: confirmed Range BUY. Reference is signal close.")
alertcondition(sellRange, "Range SELL", "Market Mode Signals: confirmed Range SELL. Reference is signal close.")
alertcondition(buyTrend or buyRange, "Any BUY", "Market Mode Signals: confirmed BUY.")
alertcondition(sellTrend or sellRange, "Any SELL", "Market Mode Signals: confirmed SELL.")
alertcondition(stopEvent or targetEvent or ambiguousEvent or expiryEvent, "Tracking completed", "Market Mode Signals: tracking completed; inspect STOP, TARGET, BOTH or EXPIRE marker.")
````
