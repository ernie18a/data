# DCA Performance Backtester [Multi-Mode]

- url: https://www.tradingview.com/script/rt72RwL8-DCA-Performance-Backtester-Multi-Mode/
- type: indicator
- pine_id: PUB;9707380196514f9bab710251ae95c09c
- version: 4.0

## Description

[b]DCA Performance Backtester [Multi-Mode]
[/b]
WHAT IT DOES
This indicator backtests Dollar-Cost Averaging (DCA) accumulation strategies on any symbol and shows the full result on the chart: an on-chart summary table, entry markers, average-cost line, real dividend (ex-date) tracking, a dividend-yield value zone, and a fair comparison against Lump Sum investing. It is accumulate-only (HODL) — no selling logic.

BUY MODES (can be combined)
1. Time-Based DCA — buy a fixed amount every Day / Week / Month. You can pick the weekday (weekly), the day of month (monthly, e.g. payday), or the hour (daily on intraday charts). If the market is closed on the target day, it buys the next trading day.
2. Buy the Dip — buy when price drops X% (default 12%) from the highest close of the last N bars (default 20). A cooldown (default 14 bars) spaces out repeat buys while the condition persists. Optional RSI settings:
   • Filter mode — only buy when RSI is below the threshold (default 30).
   • Hybrid mode — buy a normal unit on every qualifying dip (blue "D" label) AND an extra special unit when RSI is also below the threshold (red "fire" label), each stream with its own cooldown. The special unit size is adjustable via a multiplier.
3. Martingale-style averaging — first unit at a fixed size, then buy a larger unit (configurable multiplier) each time price falls another X% from the last entry, with a max-steps cap and optional reset when price recovers above average cost.

DIVIDENDS (REAL EX-DATE DATA)
Uses the symbol's actual dividend history. On each ex-date the script credits dividend × units held. Choose Gross or Net; where an exchange only provides gross figures (e.g. SET), Net is estimated as Gross × (1 − withholding tax %). Each ex-date is marked on the price chart with its per-round yield ("XD 2.35%" = dividend per share ÷ close of that day).

DIVIDEND-YIELD VALUE ZONE
Highlights price areas where the annual dividend yield at that price exceeds your threshold (default 8%/year) — useful for income-focused accumulation. Two calculation modes: trailing 12 months (TTM) or last completed calendar year. An outlier filter (default 2.5× median) excludes one-off special dividends so they do not inflate the yield. A reference line shows the exact price where yield equals the threshold.

SUMMARY TABLE
Buy count (normal vs RSI-passed dips), invested capital, units held, average cost, current portfolio value, P/L, ex-date count, total dividends received, dividends as % of invested capital, current TTM yield, DCA total return (incl. dividends), and a Lump Sum comparison computed from the same invested amount at the start date — including dividends on the Lump Sum side for a fair comparison.

ALERTS
Every buy signal fires alert() with a JSON payload (symbol, mode, price, amount, drawdown from high, RSI, and whether the RSI condition passed) — ready for webhooks. Create an alert with "Any alert() function call". Alerts fire on bar close for signals that occur after the alert is created; historical backtest markers do not fire.

HOW TO USE
Recommended on daily charts. Enable one or more buy modes, set your budget and date range, and read the "DCA beats/loses Lump Sum" row to judge whether systematic dip-buying suits the symbol. Typical tuning: calmer stocks work with smaller dip thresholds (5–7%), volatile ones with larger (12–15%).

METHOD & LIMITATIONS
Simulation buys at bar close (no intrabar fills). Accounting is computed by the script itself (indicator, not a strategy — no Strategy Tester tab). Commission % per purchase is included in cost basis. Dividend data depends on TradingView's database and may be incomplete for some markets or older periods. Past performance does not guarantee future results. Educational tool — not investment advice.

═══════════════════════════════════════════════

[b]DCA Performance Backtester [Multi-Mode]
[/b]
เครื่องมือทดสอบย้อนหลัง (backtest) กลยุทธ์สะสมหุ้นแบบ DCA กับสินทรัพย์ใดก็ได้ แสดงผลครบบนชาร์ต: ตารางสรุป, จุดซื้อ, เส้นต้นทุนเฉลี่ย, เงินปันผลจากวัน XD จริง, โซนราคาที่ปันผลคุ้ม และการเทียบกับ Lump Sum อย่างยุติธรรม — เป็นแบบซื้อสะสมอย่างเดียว (HODL) ไม่มีการขาย

โหมดการซื้อ (เปิดพร้อมกันได้)
1) DCA ตามรอบเวลา — รายวัน/รายสัปดาห์/รายเดือน เลือกวันและเวลาซื้อได้ ตลาดปิดวันเป้าหมายจะเลื่อนให้อัตโนมัติ
2) Buy the Dip — ซื้อเมื่อราคาย่อจาก High ตาม % ที่ตั้ง (ค่าเริ่มต้น 12% จากกรอบ 20 แท่ง เว้นซื้อซ้ำ 14 แท่ง) พร้อมตัวเลือก RSI สองแบบ: กรองอย่างเดียว หรือโหมดผสม — ไม้ปกติทุกครั้งที่ย่อ (ป้าย D สีฟ้า) + ไม้พิเศษเมื่อ RSI ต่ำกว่าเกณฑ์ด้วย (ป้ายไฟสีแดง) แยก cooldown สองสาย ปรับตัวคูณไม้พิเศษได้
3) ถัวเฉลี่ยขาลงแบบ Martingale — ไม้ใหญ่ขึ้นตามตัวคูณเมื่อราคาลงต่อ มีเพดานจำนวนไม้และรีเซ็ตเมื่อราคาฟื้น

เงินปันผล — ใช้ประวัติ XD จริงของสินทรัพย์ คิดจากจำนวนหน่วยที่ถือ ณ วัน XD เลือก Gross/Net ได้ (ตลาดที่มีแต่ Gross เช่น SET จะคำนวณ Net จากภาษีหัก ณ ที่จ่ายให้) จุด XD บนชาร์ตแสดง % ปันผลของงวดนั้นเทียบราคาวันนั้น

โซนปันผลคุ้ม — ไฮไลท์พื้นหลังช่วงราคาที่ yield ต่อปีสูงกว่าเกณฑ์ (ค่าเริ่มต้น 8%) เลือกวิธีคิดได้ทั้ง TTM 12 เดือน หรือปีปฏิทินล่าสุด พร้อมตัวกรองตัดปันผลพิเศษที่ทำให้ yield โป่งเกินจริง และเส้นบอกราคาที่ yield เท่าเกณฑ์พอดี

ตารางสรุป — จำนวนไม้ (แยกไม้ปกติ/ผ่าน RSI), เงินต้น, หน่วยที่ถือ, ต้นทุนเฉลี่ย, มูลค่าพอร์ต, กำไร/ขาดทุน, จำนวนครั้ง XD, ปันผลรวมและคิดเป็น % ของเงินต้น, yield ปัจจุบัน, ผลตอบแทนรวมปันผล และบรรทัดตัดสิน DCA ชนะ/แพ้ Lump Sum

Alert — ทุกสัญญาณซื้อยิง alert() เป็น JSON (สัญลักษณ์ โหมด ราคา จำนวนเงิน % ย่อ RSI และสถานะผ่าน RSI) พร้อมต่อ webhook ตั้งด้วย "Any alert() function call" — ยิงเฉพาะสัญญาณที่เกิดหลังตั้ง alert ที่ราคาปิดแท่ง

ข้อจำกัด — จำลองซื้อที่ราคาปิดแท่ง เป็น indicator จึงไม่มีแท็บ Strategy Tester ข้อมูลปันผลอิงฐานข้อมูล TradingView ผลในอดีตไม่ยืนยันอนาคต จัดทำเพื่อการศึกษา ไม่ใช่คำแนะนำการลงทุน

## Source Code

````pine
//@version=6
// ============================================================================
//  DCA Performance Backtester [Multi-Mode]
//  ----------------------------------------------------------------------------
//  Buy modes (enable separately or combine):
//    1) Time-Based DCA : fixed amount every Day / Week / Month
//    2) Buy the Dip    : buy when price drops X% from recent high (+RSI filter/hybrid)
//    3) Martingale DCA : buy bigger units as price falls, with multiplier
//  Accumulate-only (HODL) — no selling logic.
//  Output: on-chart summary table + Lump Sum comparison + real dividend (XD) tracking
//  ----------------------------------------------------------------------------
//  โหมดการซื้อ (เปิด/ปิดแยกกันได้ หรือใช้ร่วมกันหลายโหมด) — ซื้อสะสมอย่างเดียว ไม่มีการขาย
//  INDICATOR version — คำนวณบัญชี DCA เองทั้งหมด ไม่ใช้ broker emulator
// ============================================================================
indicator("DCA Performance Backtester [Multi-Mode]", shorttitle = "DCA BT",
     overlay = false, max_labels_count = 500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grpLang = "🌐 Language / ภาษา"
langStr = input.string("TH", "Table & chart text / ภาษาตารางและข้อความบนชาร์ต",
     options = ["TH", "EN"], group = grpLang,
     tooltip = "Switches the summary table and on-chart texts. Input titles below are shown bilingually (EN / TH). / สลับภาษาตารางสรุปและข้อความบนชาร์ต ส่วนชื่อช่องตั้งค่าแสดงสองภาษาคู่กัน")

// helper: pick text by language / เลือกข้อความตามภาษา
t(string en, string th) =>
    langStr == "EN" ? en : th

grpRange = "⏱ Backtest Range / ช่วงเวลาทดสอบ"
startDate = input.time(timestamp("1 Jan 2021 00:00 +0700"), "Start date / วันเริ่ม DCA", group = grpRange)
endDate   = input.time(timestamp("1 Jan 2099 00:00 +0700"), "End date / วันสิ้นสุด",     group = grpRange)

grpBudget = "💰 Budget / งบประมาณ"
useBudget = input.bool(false,    "Cap total budget / จำกัดงบลงทุนรวม",                    group = grpBudget)
maxBudget = input.float(100000,  "Max total budget / งบรวมสูงสุด", minval = 0,            group = grpBudget)
commPct   = input.float(0.1,     "Commission % per buy / ค่าคอมมิชชั่น % ต่อครั้ง", minval = 0, step = 0.01, group = grpBudget)

// ---- Mode 1 : Time-Based DCA ----
grp1 = "1️⃣ Time-Based DCA / DCA ตามรอบเวลา"
useTimeDCA = input.bool(true,      "Enable / เปิดใช้โหมดนี้",                                        group = grp1)
freq       = input.string("Weekly","Frequency / ความถี่", options = ["Daily", "Weekly", "Monthly"],  group = grp1)
everyN     = input.int(1,          "Buy every N periods / ซื้อทุก ๆ N รอบ", minval = 1,              group = grp1)
amtTime    = input.float(1000,     "Amount per buy / เงินลงทุนต่อครั้ง", minval = 0,                 group = grp1)
dowStr     = input.string("Monday / จันทร์", "Weekly: buy on / ซื้อวันไหนของสัปดาห์",
     options = ["Monday / จันทร์", "Tuesday / อังคาร", "Wednesday / พุธ", "Thursday / พฤหัสบดี",
     "Friday / ศุกร์", "Saturday / เสาร์", "Sunday / อาทิตย์"],                                       group = grp1,
     tooltip = "If market is closed that day, buys the next trading day. / ถ้าตลาดปิดวันนั้น เลื่อนไปวันทำการถัดไป")
domDay     = input.int(1,          "Monthly: day of month / ซื้อวันที่เท่าไรของเดือน", minval = 1, maxval = 28, group = grp1,
     tooltip = "Skips holidays automatically. / ข้ามวันหยุดให้อัตโนมัติ")
dailyHour  = input.int(-1,         "Daily: hour, -1 = first bar / ซื้อตอนกี่โมง (-1 = แท่งแรกของวัน)",
     minval = -1, maxval = 23,                                                                       group = grp1,
     tooltip = "Intraday charts only. / ใช้กับชาร์ต intraday เท่านั้น")

// ---- Mode 2 : Buy the Dip ----
grp2 = "2️⃣ Buy the Dip / DCA ตอนราคาย่อ"
useDip      = input.bool(false, "Enable / เปิดใช้โหมดนี้",                                   group = grp2)
dipLookback = input.int(20,     "Lookback high (bars) / กรอบหา High (แท่ง)", minval = 2,     group = grp2,
     tooltip = "Shorter window catches fresh dips after recovery. / หน้าต่างสั้นจับการย่อรอบใหม่หลังฟื้นได้ดีกว่า")
dipPct      = input.float(12,   "% dip from high to buy / % ที่ย่อลงจาก High แล้วเข้าซื้อ", minval = 0.1, group = grp2)
amtDip      = input.float(1000, "Amount per buy / เงินลงทุนต่อครั้ง", minval = 0,            group = grp2)
dipCooldown = input.int(14,     "Min bars between buys / เว้นอย่างน้อย N แท่งระหว่างไม้", minval = 0, group = grp2)
useRsi      = input.bool(false, "RSI filter — buy only when RSI passes / กรองด้วย RSI (ซื้อเฉพาะผ่านเกณฑ์)", group = grp2,
     tooltip = "Normal D buys will not occur while this is on. / เปิดแล้วไม้ D ปกติจะไม่เกิด")
useHybrid   = input.bool(false, "🅲 Hybrid: dip buy + special buy on RSI / โหมดผสม: ไม้ปกติ + ไม้พิเศษตอน RSI ผ่าน", group = grp2,
     tooltip = "Overrides the filter above. Normal unit (blue D) on every dip AND an extra special unit (red fire) when RSI also passes — separate cooldowns. / ไม่สนตัวกรองด้านบน ซื้อไม้ปกติทุก dip และไม้พิเศษเพิ่มเมื่อ RSI ผ่าน แยก cooldown กัน")
specialMult = input.float(1,    "Special buy multiplier / ตัวคูณขนาดไม้พิเศษ", minval = 0, step = 0.5, group = grp2)
rsiLen      = input.int(14,     "RSI Length", minval = 1,                                    group = grp2)
rsiTh       = input.float(30,   "Buy when RSI below / ซื้อเมื่อ RSI ต่ำกว่า", minval = 1, maxval = 99, group = grp2)

// ---- Mode 3 : Martingale ----
grp3 = "3️⃣ Martingale-Style / ถัวเฉลี่ยขาลง"
useMart      = input.bool(false, "Enable / เปิดใช้โหมดนี้",                                          group = grp3)
martBase     = input.float(1000, "First unit amount / เงินไม้แรกของรอบ", minval = 0,                 group = grp3)
martStepPct  = input.float(5,    "% drop from last buy / % ลงจากไม้ล่าสุดแล้วซื้อเพิ่ม", minval = 0.1, group = grp3)
martMult     = input.float(1.5,  "Unit multiplier / ตัวคูณขนาดไม้ (1 = เท่าเดิม)", minval = 1,       group = grp3)
martMaxSteps = input.int(10,     "Max units per cycle / จำนวนไม้สูงสุดต่อรอบ", minval = 1,           group = grp3)
martReset    = input.bool(true,  "Reset when price > avg cost / เริ่มรอบใหม่เมื่อราคาฟื้นเหนือต้นทุน", group = grp3)

// ---- Dividend (XD) ----
grpDiv = "💸 Dividend (XD) / เงินปันผล"
useDiv   = input.bool(true, "Include dividends / รวมเงินปันผลจากวัน XD", group = grpDiv,
     tooltip = "Credits dividend × units held on each real ex-date. / คิดจากจำนวนหุ้นที่ถือ ณ วัน XD จริง")
divField = input.string("Net (after tax) / หลังหักภาษี", "Dividend type / ใช้ปันผลแบบ",
     options = ["Gross (before tax) / ก่อนหักภาษี", "Net (after tax) / หลังหักภาษี"], group = grpDiv)
divTaxPct = input.float(10, "Withholding tax % / ภาษีหัก ณ ที่จ่าย %",
     minval = 0, maxval = 50, group = grpDiv,
     tooltip = "Used to estimate Net when only Gross exists (e.g. SET). / ใช้คำนวณ Net เมื่อตลาดมีแต่ข้อมูล Gross เช่น SET")

// ---- Dividend Yield Zone ----
grpYield = "💎 Dividend Yield Zone / โซนปันผลคุ้ม"
useYieldZone  = input.bool(true, "Highlight zone where yield ≥ threshold / ไฮไลท์โซนที่ yield ถึงเกณฑ์", group = grpYield,
     tooltip = "Annual dividend ÷ close of each bar. Blue background when above threshold. / ปันผลต่อปีหารราคาปิดแต่ละแท่ง พื้นหลังฟ้าเมื่อถึงเกณฑ์")
yieldTh       = input.float(8,   "Yield threshold %/yr / เกณฑ์ yield ต่อปี (%)", minval = 0.1, step = 0.5, group = grpYield)
showYieldLine = input.bool(true, "Show price line at threshold / แสดงเส้นราคาที่ yield = เกณฑ์พอดี",     group = grpYield)
yieldMode     = input.string("TTM (last 12 months / 12 เดือนล่าสุด)", "Annual dividend basis / วิธีคิดปันผลต่อปี",
     options = ["TTM (last 12 months / 12 เดือนล่าสุด)", "Last calendar year / ปีปฏิทินล่าสุดที่จบแล้ว"], group = grpYield,
     tooltip = "TTM = fresher; calendar year = steadier. / TTM สดกว่า ปีปฏิทินนิ่งกว่า")
filterSpecial = input.bool(true, "Exclude outlier payouts / ตัดงวดผิดปกติ (กันปันผลพิเศษ)", group = grpYield,
     tooltip = "Drops payouts larger than median × threshold (needs ≥3 payouts). / ตัดงวดที่ใหญ่กว่า median × เกณฑ์ (ต้องมี ≥3 งวด)")
specialXTh    = input.float(2.5, "Outlier threshold (× median) / เกณฑ์งวดผิดปกติ (เท่าของ median)", minval = 1.5, step = 0.5, group = grpYield)

// ---- Display ----
grpDisp  = "🖥 Display / การแสดงผล"
showTable  = input.bool(true, "Show summary table / แสดงตาราง Summary",                       group = grpDisp)
tablePos   = input.string("Top Right", "Table position / ตำแหน่งตาราง",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],                      group = grpDisp)
showAvg    = input.bool(true, "Show avg-cost line / แสดงเส้นต้นทุนเฉลี่ย",                     group = grpDisp)
showLabels = input.bool(true, "Show buy labels / แสดง Label จุดซื้อ",                          group = grpDisp)
showXdPct  = input.bool(true, "Show XD yield % labels / แสดง % ปันผลที่จุด XD",                group = grpDisp)

// ─────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────
inRange = time >= startDate and time <= endDate

var float totalInvested = 0.0
var int   buyCount      = 0
var float accQty        = 0.0
var float accCost       = 0.0
var float startPrice    = na
var int   startBar      = na

if inRange and na(startPrice)
    startPrice := close
    startBar   := bar_index

// ─────────────────────────────────────────────
//  SIGNALS
// ─────────────────────────────────────────────
float buyAmt = 0.0
string buyTag = ""

// -- Mode 1: Time-Based --
ordMon(int d) =>
    d == dayofweek.sunday ? 7 : d - 1

int targetDow = switch dowStr
    "Monday / จันทร์"     => dayofweek.monday
    "Tuesday / อังคาร"    => dayofweek.tuesday
    "Wednesday / พุธ"     => dayofweek.wednesday
    "Thursday / พฤหัสบดี" => dayofweek.thursday
    "Friday / ศุกร์"      => dayofweek.friday
    "Saturday / เสาร์"    => dayofweek.saturday
    => dayofweek.sunday

var int periodCounter = 0
var int lastDayKey    = -1
var int lastWeekKey   = -1
var int lastMonthKey  = -1

int dayKey   = year * 10000 + month * 100 + dayofmonth
int weekKey  = year * 100 + weekofyear
int monthKey = year * 12 + month

bool periodTrig = false
if inRange and useTimeDCA
    if freq == "Daily"
        bool hourOk = dailyHour < 0 or not timeframe.isintraday or hour >= dailyHour
        if hourOk and dayKey != lastDayKey
            periodTrig := true
            lastDayKey := dayKey
    else if freq == "Weekly"
        if ordMon(dayofweek) >= ordMon(targetDow) and weekKey != lastWeekKey
            periodTrig := true
            lastWeekKey := weekKey
    else
        if dayofmonth >= domDay and monthKey != lastMonthKey
            periodTrig := true
            lastMonthKey := monthKey

if periodTrig
    periodCounter += 1
    if periodCounter % everyN == 0
        buyAmt += amtTime
        buyTag += "T"

// -- Mode 2: Buy the Dip --
float hh      = ta.highest(high, dipLookback)
float ddFromHigh = (hh - close) / hh * 100
float rsiVal  = ta.rsi(close, rsiLen)
var int lastDipBar  = -999999   // cooldown สายไม้ปกติ / normal stream
var int lastFireBar = -999999   // cooldown สายไม้พิเศษ / special stream
var int dipCount    = 0
var int dipRsiCount = 0
bool rsiPass    = rsiVal <= rsiTh
bool dipHit     = ddFromHigh >= dipPct
bool dipRsiPass = false
if inRange and useDip
    if useHybrid
        // 🅲 two independent streams: normal unit on every dip + special unit when RSI passes
        if dipHit and (bar_index - lastDipBar) >= dipCooldown
            buyAmt += amtDip
            buyTag += "D"
            dipCount += 1
            lastDipBar := bar_index
        if dipHit and rsiPass and (bar_index - lastFireBar) >= dipCooldown
            buyAmt += amtDip * specialMult
            buyTag += "🔥"
            dipRsiPass := true
            dipRsiCount += 1
            lastFireBar := bar_index
    else
        bool dipOk = dipHit and (not useRsi or rsiPass)
        if dipOk and (bar_index - lastDipBar) >= dipCooldown
            buyAmt += amtDip
            dipRsiPass := rsiPass
            buyTag += dipRsiPass ? "D🔥" : "D"
            dipCount += 1
            if dipRsiPass
                dipRsiCount += 1
            lastDipBar := bar_index

// -- Mode 3: Martingale --
var float lastMartPrice = na
var int   martStep      = 0
if inRange and useMart
    if martReset and martStep > 0 and accQty > 0 and close > accCost / accQty
        martStep      := 0
        lastMartPrice := na
    if na(lastMartPrice)
        buyAmt += martBase
        buyTag += "M"
        martStep      := 1
        lastMartPrice := close
    else if martStep < martMaxSteps and close <= lastMartPrice * (1 - martStepPct / 100)
        buyAmt += martBase * math.pow(martMult, martStep)
        buyTag += "M"
        martStep      += 1
        lastMartPrice := close

// -- Budget cap --
if useBudget
    buyAmt := math.min(buyAmt, math.max(0, maxBudget - totalInvested))

// ─────────────────────────────────────────────
//  EXECUTE (accumulate only / HODL)
// ─────────────────────────────────────────────
if buyAmt > 0
    float qty = buyAmt / close
    accQty        += qty
    accCost       += buyAmt * (1 + commPct / 100)
    totalInvested += buyAmt
    buyCount      += 1
    // Webhook Alert (JSON) — use "Any alert() function call"
    string modeName = str.contains(buyTag, "D") or str.contains(buyTag, "🔥") ? "Buy the Dip" :
         str.contains(buyTag, "M") ? "Martingale" : "Time-Based DCA"
    string alertMsg = '{"event":"DCA_BUY","symbol":"' + syminfo.ticker +
         '","mode":"' + modeName + '","tag":"' + buyTag +
         '","price":' + str.tostring(close) +
         ',"amount":' + str.tostring(buyAmt, "#.##") +
         ',"qty":' + str.tostring(qty, "#.####") +
         ',"drawdown_from_high":' + str.tostring(ddFromHigh, "#.##") +
         ',"rsi":' + str.tostring(rsiVal, "#.##") +
         ',"rsi_pass":' + (dipRsiPass ? "true" : "false") + '}'
    alert(alertMsg, alert.freq_once_per_bar_close)
    if showLabels
        // special (RSI-passed) buys = red / normal = teal
        color lblCol = dipRsiPass ? color.new(color.red, 0) : color.new(color.teal, 20)
        label.new(bar_index, low, buyTag, xloc.bar_index, yloc.belowbar,
             lblCol, label.style_label_up, color.white,
             size.tiny, force_overlay = true)

// ─────────────────────────────────────────────
//  METRICS
// ─────────────────────────────────────────────
float units     = accQty
float avgCost   = accQty > 0 ? accCost / accQty : na
float invested  = accCost
int   fillCount = buyCount
float portValue = units * close
float pnl       = portValue - invested
float pnlPct    = invested > 0 ? pnl / invested * 100 : na

// ---- Dividends (XD) ----
float divGross = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_off, true)
float divNet   = request.dividends(syminfo.tickerid, dividends.net,   barmerge.gaps_on, barmerge.lookahead_off, true)
bool  wantNet = divField == "Net (after tax) / หลังหักภาษี"
float divPS   = wantNet ?
     (not na(divNet) ? divNet : divGross * (1 - divTaxPct / 100)) :
     (not na(divGross) ? divGross : divNet)

var float totalDiv = 0.0
var float lumpDiv  = 0.0
var int   xdCount  = 0

if useDiv and inRange and not na(divPS) and divPS > 0
    xdCount += 1
    if units > 0
        totalDiv += divPS * units
    if not na(startPrice) and invested > 0
        lumpDiv += divPS * (invested / startPrice)

float lumpValue  = not na(startPrice) and invested > 0 ? invested * close / startPrice : na
float dcaRetPct  = invested > 0 ? (pnl + (useDiv ? totalDiv : 0)) / invested * 100 : na
float lumpRetPct = invested > 0 and not na(lumpValue) ? (lumpValue - invested + (useDiv ? lumpDiv : 0)) / invested * 100 : na
float dcaVsLump  = dcaRetPct - lumpRetPct

// ---- Dividend Yield Zone ----
var array<int>   xdTimes = array.new<int>()
var array<float> xdAmts  = array.new<float>()
if not na(divPS) and divPS > 0
    array.push(xdTimes, time)
    array.push(xdAmts, divPS)
while array.size(xdTimes) > 0 and array.get(xdTimes, 0) < time - 31536000000
    array.shift(xdTimes)
    array.shift(xdAmts)
// TTM with outlier filter
float ttmDiv = 0.0
if array.size(xdAmts) > 0
    if filterSpecial and array.size(xdAmts) >= 3
        float medAmt = array.median(xdAmts)
        for i = 0 to array.size(xdAmts) - 1
            float a = array.get(xdAmts, i)
            if a <= medAmt * specialXTh
                ttmDiv += a
    else
        ttmDiv := array.sum(xdAmts)
// last completed calendar year
var float divCurYear  = 0.0
var float divPrevYear = 0.0
var int   trackYear   = na
if na(trackYear)
    trackYear := year
if year != trackYear
    divPrevYear := divCurYear
    divCurYear  := 0.0
    trackYear   := year
if not na(divPS) and divPS > 0
    divCurYear += divPS
float annualDiv  = yieldMode == "TTM (last 12 months / 12 เดือนล่าสุด)" ? ttmDiv : divPrevYear
float curYield   = close > 0 and annualDiv > 0 ? annualDiv / close * 100 : na
float yieldPrice = annualDiv > 0 ? annualDiv / (yieldTh / 100) : na
bool  inYieldZone = useYieldZone and not na(curYield) and curYield >= yieldTh
bgcolor(inYieldZone ? color.new(color.aqua, 85) : na, force_overlay = true)
plot(useYieldZone and showYieldLine ? yieldPrice : na, "Price @ yield threshold / ราคาที่ yield = เกณฑ์",
     color.new(color.aqua, 35), 1, plot.style_linebr, force_overlay = true)

// XD markers
plotshape(useDiv and inRange and not na(divPS) and divPS > 0 and not showXdPct, "XD day / วัน XD", shape.diamond,
     location.abovebar, color.new(color.aqua, 0), text = "XD", textcolor = color.aqua,
     size = size.tiny, force_overlay = true)
if useDiv and inRange and not na(divPS) and divPS > 0 and showXdPct and close > 0
    float xdPct = divPS / close * 100
    label.new(bar_index, high, "XD " + str.tostring(xdPct, "#.##") + "%",
         xloc.bar_index, yloc.abovebar, color.new(color.aqua, 80),
         label.style_label_down, color.aqua, size.tiny, force_overlay = true)

// ─────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────
plot(invested,                  "Invested / เงินต้นสะสม",  color.new(color.gray,  0), 2, plot.style_stepline)
plot(portValue > 0 ? portValue : na, "DCA value / มูลค่าพอร์ต DCA",    color.new(color.teal,  0), 2)
plot(lumpValue,                 "Lump Sum value / มูลค่า Lump Sum",    color.new(color.orange, 0), 2)
plot(useDiv and portValue > 0 ? portValue + totalDiv : na, "DCA + dividends / มูลค่าพอร์ต + ปันผลสะสม", color.new(color.aqua, 0), 1)
plot(showAvg and avgCost > 0 ? avgCost : na, "Avg cost / ต้นทุนเฉลี่ย",
     color.new(color.fuchsia, 0), 1, plot.style_linebr, force_overlay = true)

// ─────────────────────────────────────────────
//  SUMMARY TABLE (bilingual via t())
// ─────────────────────────────────────────────
posFromStr(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_row(table tb, int r, string k, string v, color vc) =>
    table.cell(tb, 0, r, k, text_color = color.new(color.white, 20), text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, v, text_color = vc,                          text_size = size.small, text_halign = text.align_right)

var table tbl = na
if showTable and barstate.islast
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(posFromStr(tablePos), 2, 17, bgcolor = color.new(color.black, 15),
         border_width = 1, border_color = color.new(color.gray, 70), force_overlay = true)

    string modeTxt = (useTimeDCA ? "⏱" : "") + (useDip ? "📉" : "") + (useMart ? "🎲" : "")
    color pnlCol  = pnl >= 0 ? color.lime : color.red
    color diffCol = dcaVsLump >= 0 ? color.lime : color.orange
    string offTxt = t("off", "ปิดอยู่")

    table.cell(tbl, 0, 0, "📊 DCA SUMMARY", text_color = color.yellow, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 0, modeTxt,          text_color = color.yellow, text_size = size.normal, text_halign = text.align_right)
    f_row(tbl, 1,  t("Buy count",            "จำนวนครั้งที่ซื้อ"),        str.tostring(buyCount),                        color.white)
    f_row(tbl, 2,  t("Invested capital",     "เงินต้นสะสม"),             str.tostring(invested, "#,###.##"),            color.white)
    f_row(tbl, 3,  t("Units held",           "จำนวนหน่วยที่ถือ"),        str.tostring(units, "#,###.########"),         color.white)
    f_row(tbl, 4,  t("Average cost",         "ต้นทุนเฉลี่ย"),            str.tostring(avgCost, format.mintick),         color.fuchsia)
    f_row(tbl, 5,  t("Current price",        "ราคาปัจจุบัน"),            str.tostring(close, format.mintick),           color.white)
    f_row(tbl, 6,  t("Portfolio value",      "มูลค่าพอร์ต"),             str.tostring(portValue, "#,###.##"),           color.teal)
    string retSfx = useDiv ? t(" (incl. div)", " (รวมปันผล)") : ""
    f_row(tbl, 7,  t("P/L (price)",          "กำไร/ขาดทุน (ราคา)"),      str.tostring(pnl, "#,###.##"),                 pnlCol)
    f_row(tbl, 8,  t("XD count",             "จำนวนครั้ง XD"),           useDiv ? str.tostring(xdCount) : offTxt,       color.aqua)
    f_row(tbl, 9,  t("Dividends received",   "ปันผลรวมที่ได้รับ"),        useDiv ? str.tostring(totalDiv, "#,###.##") : offTxt, color.aqua)
    f_row(tbl, 10, t("DCA return", "ผลตอบแทน DCA") + retSfx,            str.tostring(dcaRetPct, "#.##") + " %",
         dcaRetPct >= 0 ? color.lime : color.red)
    f_row(tbl, 11, t("Lump Sum value",       "Lump Sum มูลค่า"),         str.tostring(lumpValue, "#,###.##"),           color.orange)
    f_row(tbl, 12, t("Lump Sum return", "ผลตอบแทน LS") + retSfx,        str.tostring(lumpRetPct, "#.##") + " %",
         lumpRetPct >= 0 ? color.lime : color.red)
    f_row(tbl, 13, t("DCA vs Lump Sum",      "DCA ชนะ/แพ้ LS"),          (dcaVsLump >= 0 ? "+" : "") + str.tostring(dcaVsLump, "#.##") + " %", diffCol)
    if useDip
        f_row(tbl, 14, t("Dip buys: normal / 🔥RSI", "ไม้ Dip ปกติ / 🔥ผ่าน RSI"),
             str.tostring(dipCount - dipRsiCount) + " / " + str.tostring(dipRsiCount), color.orange)
    if useDiv and invested > 0
        f_row(tbl, 15, t("Dividends as % of invested", "ปันผลรวมคิดเป็น % ของเงินต้น"),
             str.tostring(totalDiv / invested * 100, "#.##") + " %", color.aqua)
    if useYieldZone and not na(curYield)
        f_row(tbl, 16, t("Current yield (TTM) / th.", "Yield ปัจจุบัน / เกณฑ์") + " " + str.tostring(yieldTh, "#.#") + "%",
             str.tostring(curYield, "#.##") + " %" + (curYield >= yieldTh ? " 💎" : ""),
             curYield >= yieldTh ? color.lime : color.gray)

            //eof
````
