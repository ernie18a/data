<!-- tradingview-pine-id: PUB;2016463b4626439fbacc9a77df6e6c6e -->
<!-- tradingviewscripts-format: 1 -->
# Trend Continuation Momentum Detector v3

Source: https://www.tradingview.com/script/Qu4ayrSm-Trend-Continuation-Momentum-Detector/

## Description

TCMD v3 — Trend Continuation Momentum Detector
Core Concept

TCMD is a weighted multi-factor momentum scoring system built on Heiken Ashi candles. Instead of one signal triggering everything, it blends five independent measurements of "how strong is this move" into a composite Momentum Score (0–100), then layers state logic, filters, and risk levels on top.

The five scoring factors
Body Expansion (30% weight) — Is this candle's body unusually large? Calculated as HA body / 20-bar avg body, scaled to 0–100.
Wick Quality (25% weight) — Is the move "clean" (no rejection)? The wick opposing the candle's direction is measured as a % of body size — a small opposing wick scores high.
Trend Slope (20% weight) — Is the EMA of HA close actually rising/falling with conviction? EMA slope over slopeLookback bars, normalized by ATR, then multiplied by a sensitivity factor.
Volume (15% weight) — Is volume confirming the move? volume / 20-bar avg volume, scaled.
Z-Score / distance from mean (10% weight) — Is price extended from its own EMA in a statistically meaningful (but not extreme) way? (HA close − EMA) / stdev, scored with a bell-shaped curve peaking around 0.5–2.0 SD and decaying past 3 SD (overextended).

These combine into a weighted average (weights auto-normalize even if they don't sum to 100) to produce momentumScore.

Why Heiken Ashi

HA smooths noise so body size/wick logic reflects sustained pressure rather than single-tick noise — important since body expansion and wick quality are core inputs.

Signal Logic — 5-State Machine

Each confirmed bar is classified as:

STRONG BUY — momentumScore > threshold (default 75) AND bullish HA candle AND clean wick AND body > average AND HA close above EMA AND (optional) close above VWAP AND (optional) delta positive
STRONG SELL — mirror conditions to the downside
BUY / SELL (bias) — looser: HA close vs EMA + VWAP direction + momentumScore ≥ 50, no wick/body purity required
NEUTRAL — none of the above

This state drives everything downstream: candle coloring, markers, warnings, and TP/SL.

"One-Shot + EMA Reset" Entry Logic

The key anti-spam mechanism: a Strong Buy/Sell marker fires once per cycle, then locks. It won't fire again until price pulls back and touches the EMA (low touches EMA resets buy-side, high touches EMA resets sell-side). This stops multiple entry signals stacking up during one continuous trending move — you get one entry, then must wait for a retest before the next is valid.

Warning System
Light Warning (diamond) — Strong Buy/Sell degrades to plain Buy/Sell, same direction, losing steam
Heavy Warning (x-cross) — Strong Buy/Sell degrades to Neutral or flips to the opposite bias — reversal risk

These are degradation alerts for managing an existing position, not new directional entries.

VWAP & Delta as Confirmation Filters
VWAP filter — Strong signals optionally require price on the "correct" side of session VWAP. Most meaningful intraday since VWAP resets each session.
Delta filter — pulls real buy/sell volume from a lower timeframe (default 1-min) and requires it to agree with signal direction. Falls back to candle direction (close vs open) when lower-timeframe data isn't available in deep history.
Mean Reversion (MR) Signal — separate counter-trend logic

MR looks for momentum exhaustion at a statistical extreme, the opposite philosophy from the trend signals. It fires when:

Price is ≥ mrSdThreshold VWAP standard deviations away (default 1.8 ≈ near the 2SD band)
Momentum Score is weak (< mrMomentumMax) and optionally fading vs the prior bar
The current HA body is small (neutral) and its real high/low engulfs the previous candle's body — a rejection pattern
Session warm-up (mrMinBars) and minimum VWAP SD width (mrMinSdPct) guards are satisfied so it doesn't fire on noisy early bars

MR has its own optional dotted TP/SL lines and alerts, independent of trend-following TP/SL.

TP / SL Levels

When a fresh Strong Buy/Sell fires, TP1/TP2/SL are calculated from the signal candle's HA range (high−low), drawn from the next bar's real open:

Long: TP1 = entry + 2×range, TP2 = entry + 4×range, SL = entry − 1.5×range
Short: mirrored

An "Active SL" is tracked internally; if close crosses through it, an SL-hit marker/alert fires and clears the level.

How to Use It in Practice
Check the current state first — Strong Buy/Sell, Buy/Sell, or Neutral — as your top-line read.
Strong Buy/Sell circle = entry trigger. TP/SL lines (if enabled) auto-draw on the next bar's open.
Diamond (light warning) = start thinking about trimming/tightening — momentum easing, direction unchanged.
X-cross (heavy warning) = treat as an exit signal for the prior position, not a new entry.
Consecutive strong bars = move is extended, higher risk of a sharp mean-reversion snap — cross-check against MR triangles.
VWAP Z-Score / SD bands — gauge how stretched price is; MR triangles are your explicit counter-trend cue at extremes.
ATR — elevated/high readings mean volatility regime has shifted; sanity-check your TP/SL multiples still fit the current range.
Delta — cross-check real order flow agrees with the HA/EMA-based signal, useful for scalping confirmation beyond price action alone.

One thing worth flagging for your GC/NQ intraday use: the VWAP filter and MR signal are most meaningful on session-based intraday timeframes given the session-reset VWAP — on higher timeframes or across sessions, those two features lose some of their intended meaning.

---

## Source Code

````pine
//@version=6

// ════════════════════════════════════════════════════════════════════════════
//  TREND CONTINUATION MOMENTUM DETECTOR v3
// ────────────────────────────────────────────────────────────────────────────
//  v3 additions over v2:
//    - VWAP ±1SD / ±2SD bands (toggleable, colour-configurable)
//    - Dashboard table size adjustable (Tiny / Small / Normal / Large / Huge)
//    - Mean Reversion signal: fires when price taps ≥mrSdThreshold SD from
//      VWAP and momentum is decelerating — triangle markers + MR TP/SL lines
//      + dedicated alerts
//  v3.1 additions:
//    - ATR row in dashboard with colour coding (white/orange/red by ratio)
//    - Per-row dashboard visibility checkboxes
// ════════════════════════════════════════════════════════════════════════════

indicator("Trend Continuation Momentum Detector v3", shorttitle = "TCMD v3",
     overlay = true, max_labels_count = 500, max_lines_count = 500)

// ────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────
grpCalc = "Calculation Settings"
bodyAvgLength    = input.int(20,   "Body Average Length (bars)",           minval = 5,   maxval = 100,  group = grpCalc, tooltip = "จำนวนแท่งย้อนหลังที่ใช้คำนวณขนาดบอดี้เฉลี่ยของแคนเดิล Heiken Ashi (นับเฉพาะแท่งก่อนหน้า ไม่รวมแท่งปัจจุบัน)")
emaLength        = input.int(20,   "EMA Length (HA Close)",                minval = 5,   maxval = 200,  group = grpCalc, tooltip = "ความยาวของเส้น EMA ที่คำนวณจากราคาปิดของแคนเดิล Heiken Ashi ใช้เป็นเส้นอ้างอิงเทรนด์หลักสำหรับตัดสินทิศทางและความชัน")
volAvgLength     = input.int(20,   "Volume Average Length (bars)",         minval = 5,   maxval = 100,  group = grpCalc, tooltip = "จำนวนแท่งย้อนหลังที่ใช้คำนวณปริมาณการซื้อขายเฉลี่ย เพื่อเทียบว่าแท่งปัจจุบันมีโวลุ่มสูงกว่าค่าเฉลี่ยแค่ไหน")
stdevLength      = input.int(20,   "Standard Deviation Length (bars)",     minval = 5,   maxval = 100,  group = grpCalc, tooltip = "จำนวนแท่งย้อนหลังที่ใช้คำนวณค่าส่วนเบี่ยงเบนมาตรฐานของราคาปิด HA ใช้ในการคำนวณ Z-Score (ระยะห่างจากค่าเฉลี่ย)")
slopeLookback    = input.int(3,    "EMA Slope Lookback (bars)",            minval = 1,   maxval = 20,   group = grpCalc, tooltip = "จำนวนแท่งที่ใช้เทียบเพื่อหาความชันของเส้น EMA ในปัจจุบัน")
slopeSensitivity = input.float(5.0,"Slope Sensitivity Multiplier",         minval = 0.1, maxval = 50.0, step = 0.5, group = grpCalc, tooltip = "ตัวคูณความไวของคะแนนความชัน EMA ที่ปรับด้วย ATR แล้ว ยิ่งค่าสูง คะแนนจากความชันจะพุ่งถึง 100 ได้เร็วขึ้น")
wickTolerancePct = input.float(10.0,"Opposing Wick Tolerance (% of Body)",minval = 0.0, maxval = 50.0, step = 1.0, group = grpCalc, tooltip = "ไส้เทียนฝั่งตรงข้ามทิศทางแคนเดิลต้องมีขนาดไม่เกินกี่ % ของบอดี้ จึงจะถือว่า \"ไม่มีไส้รบกวน\"")

grpWeights = "Momentum Score Weights (%)"
wBodyExp    = input.float(30.0, "Body Expansion Weight",       minval = 0, maxval = 100, group = grpWeights, tooltip = "น้ำหนักของปัจจัย \"ขนาดบอดี้เทียบค่าเฉลี่ย\" ต่อคะแนน Momentum Score รวม")
wWickQual   = input.float(25.0, "Wick Quality Weight",         minval = 0, maxval = 100, group = grpWeights, tooltip = "น้ำหนักของปัจจัย \"คุณภาพไส้เทียน\" (ขนาดไส้ฝั่งตรงข้ามเทียบกับบอดี้) ต่อคะแนน Momentum Score รวม")
wTrendSlope = input.float(20.0, "Trend Slope Weight",          minval = 0, maxval = 100, group = grpWeights, tooltip = "น้ำหนักของปัจจัย \"ความชันของเส้น EMA\" (ปรับด้วย ATR แล้ว) ต่อคะแนน Momentum Score รวม")
wVolume     = input.float(15.0, "Volume Confirmation Weight",  minval = 0, maxval = 100, group = grpWeights, tooltip = "น้ำหนักของปัจจัย \"ปริมาณการซื้อขายเทียบค่าเฉลี่ย\" ต่อคะแนน Momentum Score รวม")
wZScore     = input.float(10.0, "Distance From Mean Weight",   minval = 0, maxval = 100, group = grpWeights, tooltip = "น้ำหนักของปัจจัย \"ระยะห่างทางสถิติจากค่าเฉลี่ย\" (Z-Score) ต่อคะแนน Momentum Score รวม น้ำหนักทั้งหมดถูกปรับสัดส่วนอัตโนมัติ จึงไม่จำเป็นต้องรวมกันได้เท่ากับ 100")

grpSignal = "Signal Settings"
momentumThreshold = input.float(75.0, "Strong Signal Score Threshold", minval = 50.0, maxval = 100.0, group = grpSignal, tooltip = "คะแนน Momentum Score ขั้นต่ำที่ต้องทำได้ จึงจะมีสิทธิ์เป็น Strong Buy / Strong Sell (ต้องผ่านเงื่อนไขอื่นประกอบด้วย ไม่ใช่แค่คะแนนถึงอย่างเดียว) เกณฑ์อ่านคะแนนคร่าวๆ: ต่ำกว่า 50=อ่อน, 50-75=มี bias, เกิน 75=แรงจัด")
buySellThreshold  = input.float(50.0, "Buy/Sell (Bias) Score Threshold", minval = 0.0, maxval = 100.0, group = grpSignal, tooltip = "คะแนน Momentum Score ขั้นต่ำสำหรับป้าย Buy/Sell ธรรมดา (มี bias ทิศทาง แต่ยังไม่แรงพอเป็น Strong)")

grpVwap = "VWAP & SD Bands"
useVwapFilter = input.bool(true,  "Require Price Above/Below VWAP",        group = grpVwap, tooltip = "เมื่อเปิดใช้งาน Strong Buy ต้องการให้ราคาปิดอยู่เหนือ VWAP และ Strong Sell ต้องอยู่ใต้ VWAP หมายเหตุ: VWAP มาตรฐานจะรีเซ็ตทุกเริ่มเซสชันใหม่ filter นี้จึงมีความหมายชัดเจนที่สุดบน timeframe ระดับ intraday")
showSdBands   = input.bool(false, "Show VWAP SD Bands (±1/2/3)",           group = grpVwap, tooltip = "SD คำนวณแบบ cumulative ตั้งแต่ต้น session เหมือน TradingView built-in VWAP")
col1SdBand    = input.color(color.new(color.orange, 80), "±1SD Band Fill", group = grpVwap)
col2SdBand    = input.color(color.new(color.orange, 65), "±2SD Band Fill", group = grpVwap)
col3SdBand    = input.color(color.new(color.orange, 50), "±3SD Band Fill", group = grpVwap)
col1SdLine    = input.color(color.new(color.orange, 50), "±1SD Line",      group = grpVwap)
col2SdLine    = input.color(color.new(color.orange, 30), "±2SD Line",      group = grpVwap)
col3SdLine    = input.color(color.new(color.orange,  0), "±3SD Line",      group = grpVwap)

grpDelta = "Delta (Lower Timeframe Order Flow)"
useDeltaFilter = input.bool(true,  "Require Delta Confirmation for Strong Signals", group = grpDelta, tooltip = "เมื่อเปิดใช้งาน Strong Buy ต้องมี Delta เป็นบวก (ฝั่งซื้อมากกว่าขาย) และ Strong Sell ต้องมี Delta เป็นลบ (ฝั่งขายมากกว่าซื้อ)")
deltaLowerTF   = input.timeframe("1", "Lower Timeframe for Delta",                  group = grpDelta, tooltip = "Timeframe ย่อยที่ใช้ดึงข้อมูลปริมาณซื้อ/ขายจริงมาคำนวณ Delta ควรเลือกให้เล็กกว่า timeframe หลักพอสมควร เช่น กราฟหลัก 5 นาที ใช้ lower timeframe เป็น 1 นาที")

grpTpSl = "TP / SL Levels"
showTpSl         = input.bool(false, "Show TP/SL Lines on Entry",                  group = grpTpSl, tooltip = "แสดงเส้นแนวนอน TP1, TP2, SL บนกราฟทุกครั้งที่เกิดจุดเข้า Strong Buy หรือ Strong Sell ใหม่\n\nวิธีคำนวณ:\n- Range = High-Low ของแท่ง HA ที่เกิดสัญญาณ (รวมไส้)\n- Entry = Open จริงของแท่งถัดจากสัญญาณ (เส้นวาดหลังแท่งนั้นปิด)\n\nฝั่ง Buy: TP1 = entry + 2×range, TP2 = entry + 4×range, SL = entry - 1.5×range\nฝั่ง Sell: TP1 = entry - 2×range, TP2 = entry - 4×range, SL = entry + 1.5×range")
tpSlLineLength   = input.int(3,      "Line Length (bars forward)",               minval = 1, maxval = 20,  group = grpTpSl, tooltip = "ความยาวของเส้น TP/SL นับเป็นจำนวนแท่งไปทางขวาจากจุดวาด")
tpSlHistoryCount = input.int(1,      "Number of TP/SL Sets to Keep (per side)", minval = 1, maxval = 100, group = grpTpSl, tooltip = "จำนวนชุด TP/SL ล่าสุดที่จะเก็บไว้บนกราฟพร้อมกัน แยกนับฝั่ง Buy และฝั่ง Sell อย่างละชุด เมื่อเกิดสัญญาณใหม่เกินจำนวนนี้ ชุดที่เก่าที่สุดจะถูกลบออกอัตโนมัติ (สูงสุด 100 ชุดต่อฝั่ง)")
tp1Multiplier    = input.float(2.0,  "TP1 Multiplier (x range)",                minval = 0.1, maxval = 20.0, step = 0.1, group = grpTpSl)
tp2Multiplier    = input.float(4.0,  "TP2 Multiplier (x range)",                minval = 0.1, maxval = 20.0, step = 0.1, group = grpTpSl)
slMultiplier     = input.float(1.5,  "SL Multiplier (x range)",                 minval = 0.1, maxval = 20.0, step = 0.1, group = grpTpSl)
colTp            = input.color(color.new(color.teal, 0), "TP Line Color",       group = grpTpSl)
colSl            = input.color(color.new(color.red,  0), "SL Line Color",       group = grpTpSl)
tpSlLabelOffset  = input.int(1,      "Label Offset (bars right of line end)",   minval = 0, maxval = 10, group = grpTpSl, tooltip = "เลื่อน label TP1/TP2/SL ออกไปทางขวาจากปลายเส้นอีกกี่แท่ง ใช้แก้ปัญหา label ทับเส้น")

grpMR = "Mean Reversion Signal"
showMrSignal  = input.bool(true,  "Show Mean Reversion Signals",                      group = grpMR, tooltip = "สัญญาณ Counter-trend เมื่อราคาแตะขอบ SD band และ momentum อ่อน")
mrSdThreshold = input.float(1.8,  "SD Threshold to Trigger MR",                      minval = 1.0, maxval = 5.0, step = 0.1, group = grpMR, tooltip = "ราคาต้องห่าง VWAP อย่างน้อยกี่ SD (default 1.8 ≈ ขอบ 2SD)")
mrMomentumMax = input.float(65.0, "Max Momentum Score for MR",                       minval = 0.0, maxval = 100.0, group = grpMR, tooltip = "ไม่แสดง MR ถ้า Momentum Score เกินนี้ (เทรนด์ยังแรง)")
mrRequireFade = input.bool(true,  "Require Score Fading (score < prev bar)",         group = grpMR, tooltip = "บังคับ Momentum Score ลดลงจากแท่งก่อน — ยืนยันโมเมนตัมอ่อน")
mrMinBars     = input.int(10,    "Min Bars in Session Before MR",                    minval = 3, maxval = 100, group = grpMR, tooltip = "จำนวนแท่งขั้นต่ำนับจากต้น session ก่อนที่ MR signal จะเริ่มทำงาน ป้องกันสัญญาณผิดช่วงที่ VWAP SD ยังสะสมข้อมูลไม่พอ")
mrMinSdPct    = input.float(0.05,"Min VWAP SD (% of price)",                         minval = 0.01, maxval = 1.0, step = 0.01, group = grpMR, tooltip = "VWAP SD ต้องขยายถึงอย่างน้อยกี่ % ของราคาปัจจุบัน ก่อน MR signal จะ trigger ได้ ป้องกัน SD เล็กมากต้น session ทำให้ Z-Score พุ่งผิดปกติ (default 0.05% เหมาะกับ futures/crypto)")
colMrBull     = input.color(color.new(color.aqua,    0), "MR Bull Color (-2SD zone)", group = grpMR)
colMrBear     = input.color(color.new(color.fuchsia, 0), "MR Bear Color (+2SD zone)", group = grpMR)
showMrTpSl    = input.bool(false, "Show MR TP/SL Lines (dotted)",                   group = grpMR)

grpDisplay = "Display Settings"
showEntryMarkers  = input.bool(true,  "Show Entry Markers (filled circle)",    group = grpDisplay, tooltip = "แสดงหรือซ่อนวงกลมทึบ \"จุดเข้า\" ที่ขึ้นเมื่อแท่งเทียนเพิ่งกลายเป็น Strong Buy หรือ Strong Sell ใหม่")
showLightWarning  = input.bool(true,  "Show Light Warning Markers (diamond)",  group = grpDisplay, tooltip = "แสดงหรือซ่อนเพชร \"เตือนเบา\" ที่ขึ้นเมื่อโมเมนตัมถอยจาก Strong Buy/Sell ลงมาเป็น Buy/Sell ธรรมดา (ทิศทางเดิม แต่แรงลดลง)")
showHeavyWarning  = input.bool(true,  "Show Heavy Warning Markers (x-cross)", group = grpDisplay, tooltip = "แสดงหรือซ่อนกากบาท \"เตือนหนัก\" ที่ขึ้นเมื่อโมเมนตัมร่วงจาก Strong Buy/Sell ลงไปถึง Neutral หรือกลับทิศไปอีกฝั่ง")
showSlHitMarker   = input.bool(false, "Show SL Hit Markers",                  group = grpDisplay, tooltip = "แสดงสัญลักษณ์ ✕ บนกราฟเมื่อราคาปิดทะลุผ่านเส้น SL ของ Strong Buy/Sell ล่าสุด สัญญาณว่าควรออกจากสถานะ")
showCandleColors  = input.bool(true,  "Colour Candles by Signal State",        group = grpDisplay, tooltip = "ปรับสีแท่งเทียน OHLC จริงตามสถานะ Signal ปัจจุบัน\n\nสี: Strong Buy=เขียวเข้ม, Buy=เขียวอ่อน, Neutral=เทา, Sell=ส้มอ่อน, Strong Sell=แดง")
showEmaLine       = input.bool(true,  "Show EMA (HA) Line on Chart",          group = grpDisplay, inline = "ema_line", tooltip = "แสดงเส้น EMA ที่คำนวณจากราคาปิด Heiken Ashi บนกราฟราคา เป็น filter หลักของทิศทาง Strong Buy/Sell")
colEmaLine        = input.color(color.new(color.blue, 20), "",                   group = grpDisplay, inline = "ema_line")
widEmaLine        = input.int(1, "",          minval = 1, maxval = 4,            group = grpDisplay, inline = "ema_line")
showVwapLine      = input.bool(true,  "Show VWAP Line on Chart",                group = grpDisplay, inline = "vwap_line")
colVwapLine       = input.color(color.new(#9c27b0, 0), "",                   group = grpDisplay, inline = "vwap_line")
widVwapLine       = input.int(2, "",          minval = 1, maxval = 4,            group = grpDisplay, inline = "vwap_line")
showDashboard     = input.bool(true,  "Show Dashboard",                          group = grpDisplay, tooltip = "แสดงหรือซ่อนตารางดาชบอร์ดบนกราฟ\n\nวิธีอ่านค่าแต่ละแถว:\n\nMomentum Score: คะแนนรวม 0-100 | ต่ำกว่า 50=อ่อน | 50-75=มี bias | เกิน 75=แรงจัด\nBody Expansion: บอดี้เทียบค่าเฉลี่ย ยิ่งสูงยิ่งมีแรงผลักชัด\nWick Quality: ไส้ตรงข้ามยิ่งน้อย คะแนนยิ่งสูง 100=แทบไม่มีไส้รบกวน\nTrend Slope: ความชัน EMA ปรับด้วย ATR บวก=ขึ้น ลบ=ลง\nVolume Strength: โวลุ่มเทียบเฉลี่ย เกิน 100%=สูงกว่าเฉลี่ย 2 เท่า\nZ-Score (EMA): ราคาห่าง EMA กี่ SD | 0.5-2.0=โซนดี | เกิน 3.0=เสี่ยง overextend\nVWAP Z-Score: ราคาห่าง VWAP กี่ SD | สีม่วง=เกิน 2SD (โซน MR)\nPrice vs VWAP: เหนือ/ใต้ VWAP กี่ %\nSignal: สรุปรวม ดูตัวนี้ก่อนเสมอ\nStrong Bars: แท่ง Strong ต่อเนื่อง ยิ่งมากเสี่ยง overshoot\nDelta: ซื้อลบขายจาก lower TF บวก=ฝั่งซื้อคุม ลบ=ฝั่งขายคุม\nActive SL: ระดับ SL ที่ active อยู่\nATR: ค่า ATR ปัจจุบัน vs ค่าเฉลี่ย ATR | ขาว=ปกติ | ส้ม=เริ่มผันผวน | แดง=ผันผวนสูง")
dashboardPos      = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],       group = grpDisplay, tooltip = "มุมของกราฟที่จะตรึงตารางดาชบอร์ดไว้")
dashboardSize     = input.string("Small", "Dashboard Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],                   group = grpDisplay, tooltip = "ขนาดตัวอักษรในตาราง Dashboard")

colStrongBuy  = input.color(color.new(color.lime,   0), "Strong Buy Color",  group = grpDisplay, tooltip = "สีที่ใช้แทน Strong Buy ทั้งวงกลมจุดเข้า, แถว Signal ในดาชบอร์ด, และกากบาทเตือนหนักฝั่งขาย (ที่กลับมาเป็นขาขึ้น)")
colBuy        = input.color(color.new(color.blue,   0), "Buy Color",         group = grpDisplay, tooltip = "สีที่ใช้แทนสถานะ Buy ธรรมดา ทั้งเพชรเตือนเบาฝั่งซื้อ และแถว Signal ในดาชบอร์ด")
colNeutral    = input.color(color.new(color.white,  0), "Neutral Color",     group = grpDisplay, tooltip = "สีที่ใช้แทนสถานะ Neutral ในแถว Signal และสีของ Delta เมื่อค่าเป็น N/A")
colSell       = input.color(color.new(color.orange, 0), "Sell Color",        group = grpDisplay, tooltip = "สีที่ใช้แทนสถานะ Sell ธรรมดา ทั้งเพชรเตือนเบาฝั่งขาย และแถว Signal ในดาชบอร์ด")
colStrongSell = input.color(color.new(color.red,    0), "Strong Sell Color", group = grpDisplay, tooltip = "สีที่ใช้แทน Strong Sell ทั้งวงกลมจุดเข้า, แถว Signal ในดาชบอร์ด, และกากบาทเตือนหนักฝั่งซื้อ (ที่กลับมาเป็นขาลง)")

// ────────────────────────────────────────────────────────────────────────────
//  DASHBOARD ROW VISIBILITY TOGGLES
// ────────────────────────────────────────────────────────────────────────────
grpRows = "Dashboard Row Visibility"
showRowMomentum   = input.bool(true, "Show: Momentum Score",    group = grpRows)
showRowBody       = input.bool(true, "Show: Body Expansion",    group = grpRows)
showRowWick       = input.bool(true, "Show: Wick Quality",      group = grpRows)
showRowSlope      = input.bool(true, "Show: Trend Slope",       group = grpRows)
showRowVolume     = input.bool(true, "Show: Volume Strength",   group = grpRows)
showRowZScore     = input.bool(true, "Show: Z-Score (EMA)",     group = grpRows)
showRowVwapDist   = input.bool(false, "Show: Price vs VWAP",     group = grpRows)
showRowVwapZ      = input.bool(true,  "Show: VWAP Z-Score",      group = grpRows)
showRowSignal     = input.bool(true,  "Show: Signal",            group = grpRows)
showRowStrongBars = input.bool(false, "Show: Strong Bars",       group = grpRows)
showRowDelta      = input.bool(true,  "Show: Delta",             group = grpRows)
showRowSl         = input.bool(false, "Show: Active SL",         group = grpRows)
showRowAtr        = input.bool(true, "Show: ATR",               group = grpRows, tooltip = "แสดงค่า ATR ปัจจุบัน และ ratio เทียบค่าเฉลี่ย ATR\nขาว = ปกติ (ratio < 1.2)\nส้ม = เริ่มผันผวน (ratio 1.2–1.8)\nแดง = ผันผวนสูงมาก (ratio > 1.8)")

// ────────────────────────────────────────────────────────────────────────────
//  HTF EMA (HA) OVERLAY
//  TF dropdown: 5m 15m 30m 1H 2H 4H 6H 1D 1W
//  Length dropdown: 9 20 50 100 200
// ────────────────────────────────────────────────────────────────────────────
grpHtfEma = "HTF EMA (HA) Lines"

f_htfTfStr(s) =>
    s == "5m"  ? "5"   : s == "15m" ? "15"  : s == "30m" ? "30"  :
     s == "1H"  ? "60"  : s == "2H"  ? "120" : s == "4H"  ? "240" :
     s == "6H"  ? "360" : s == "1D"  ? "1D"  : "1W"

f_htfEmaLenVal(s) =>
    s == "9"   ? 9   : s == "20"  ? 20  : s == "50"  ? 50  :
     s == "100" ? 100 : 200

showHtfEma1    = input.bool(true,  "EMA 1",       inline = "htfema1", group = grpHtfEma)
htfEma1TfStr   = input.string("1H",  "",
     options = ["5m","15m","30m","1H","2H","4H","6H","1D","1W"],
     inline = "htfema1", group = grpHtfEma)
htfEma1LenStr  = input.string("20", "",
     options = ["9","20","50","100","200"],
     inline = "htfema1", group = grpHtfEma)
colHtfEma1     = input.color(color.new(#f59b00, 60), "", inline = "htfema1", group = grpHtfEma)
widHtfEma1     = input.int(1, "",  minval = 1, maxval = 4, inline = "htfema1", group = grpHtfEma)

// ────────────────────────────────────────────────────────────────────────────
//  TIME SEPARATOR
//  TF dropdown: 15m 30m 1H 2H 4H 6H 1D 1W
// ────────────────────────────────────────────────────────────────────────────
grpSep = "Time Separator"

f_sepTfStr(s) =>
    s == "15m" ? "15"  : s == "30m" ? "30"  :
     s == "1H"  ? "60"  : s == "2H"  ? "120" : s == "4H"  ? "240" :
     s == "6H"  ? "360" : s == "1D"  ? "1D"  : "1W"

showSep1      = input.bool(true,  "Sep 1",
     inline = "sep1", group = grpSep)
sep1TfStr     = input.string("1H", "",
     options = ["15m","30m","1H","2H","4H","6H","1D","1W"],
     inline = "sep1", group = grpSep)
colSep1       = input.color(color.new(color.gray, 60), "",
     inline = "sep1", group = grpSep)
widSep1       = input.int(1, "",  minval = 1, maxval = 4,
     inline = "sep1", group = grpSep)
sep1Style     = input.string("Dashed", "",
     options = ["Solid","Dashed","Dotted"],
     inline = "sep1", group = grpSep)
sep1LookBack  = input.int(8, "Look back",
     minval = 0, maxval = 24, inline = "sep1", group = grpSep,
     tooltip = "จำนวนเส้นย้อนหลังที่เก็บไว้บนกราฟ 0 = เฉพาะเส้นปัจจุบัน")

// ────────────────────────────────────────────────────────────────────────────
//  ATR VOLATILITY SETTINGS
// ────────────────────────────────────────────────────────────────────────────
grpAtr = "ATR Volatility Settings"
atrLength      = input.int(14,  "ATR Length",                  minval = 1, maxval = 100, group = grpAtr, tooltip = "ความยาวของ ATR ที่ใช้วัดความผันผวน")
atrAvgLength   = input.int(50,  "ATR Average Length (bars)",   minval = 5, maxval = 200, group = grpAtr, tooltip = "จำนวนแท่งที่ใช้คำนวณค่าเฉลี่ย ATR เพื่อเปรียบเทียบกับ ATR ปัจจุบัน")
atrOrangeRatio = input.float(1.2, "ATR Orange Threshold (ratio)", minval = 1.0, maxval = 3.0, step = 0.1, group = grpAtr, tooltip = "ATR ratio (ATR/ค่าเฉลี่ย ATR) ที่เริ่มเปลี่ยนสีเป็นส้ม แสดงว่าเริ่มผันผวนสูงกว่าปกติ")
atrRedRatio    = input.float(1.8, "ATR Red Threshold (ratio)",    minval = 1.0, maxval = 5.0, step = 0.1, group = grpAtr, tooltip = "ATR ratio ที่เปลี่ยนสีเป็นแดง แสดงว่าผันผวนสูงมาก ควรระวังการ overextend")

// ────────────────────────────────────────────────────────────────────────────
//  SESSION HIGHLIGHT SETTINGS  (style เดียวกับ Killzones ใน HTF Suite)
//  - วาดด้วย box ไม่ใช่ bgcolor → ขอบชัด เห็นช่วงเวลาแน่นอน
//  - Timezone: America/New_York (EST/EDT อัตโนมัติ)
//  - เวลาใน session string เป็น NY time
//    Asia    : 20:00–00:00  (เปิด 20:00 NY วันก่อน – เที่ยงคืน)
//    London  : 02:00–05:00  (London open 02:00–05:00 NY)
//    NY AM   : 09:30–11:00  (NY open killzone)
//    NY PM   : 13:30–16:00  (NY afternoon)
// ────────────────────────────────────────────────────────────────────────────
grpSession = "Session Highlights"

sessEnable      = input.bool(true,  "Enable Sessions",            group = grpSession)
sessTz          = input.string("America/New_York", "Timezone",    group = grpSession,
     options = ["America/New_York","UTC","Europe/London","Europe/Paris",
                "Asia/Tokyo","Asia/Singapore","Asia/Bangkok","Australia/Sydney"])
sessMaxDays     = input.int(3, "Session Drawing Limit",           group = grpSession, minval = 1, maxval = 20,
     tooltip = "จำนวนวันย้อนหลังที่จะแสดง box สูงสุดต่อ session")
sessTfLimit     = input.timeframe("30", "Hide on TF at or above", group = grpSession,
     tooltip = "ซ่อน session boxes เมื่อ timeframe ปัจจุบัน >= ค่านี้")
sessBoxTrans    = input.int(85, "Box Transparency",               group = grpSession, minval = 0, maxval = 100)
sessShowPivots  = input.bool(true,  "Show High/Low Pivot Lines",  group = grpSession)
sessPivotWidth  = input.int(1, "Pivot Line Width",                group = grpSession, minval = 1, maxval = 4)
sessShowLabels  = input.bool(true,  "Show Session Labels",        group = grpSession)
sessLabelPos    = input.string("Top", "Label Position",            group = grpSession, options = ["Top","Bottom"],
     tooltip = "Top = label ที่ระดับ High ของ session / Bottom = label ที่ระดับ Low")
sessLabelSize   = input.string("Small", "Label Size",             group = grpSession,
     options = ["Tiny","Small","Normal","Large"])

sessUseAsia     = input.bool(true,         "",           inline = "sAS", group = grpSession)
sessAsiaTxt     = input.string("Asia",     "",           inline = "sAS", group = grpSession)
sessAsiaSess    = input.session("2000-0000","",          inline = "sAS", group = grpSession)
sessAsiaCol     = input.color(color.blue,  "",           inline = "sAS", group = grpSession)

sessUseLondon   = input.bool(true,         "",           inline = "sLO", group = grpSession)
sessLondonTxt   = input.string("London",   "",           inline = "sLO", group = grpSession)
sessLondonSess  = input.session("0200-0500","",          inline = "sLO", group = grpSession)
sessLondonCol   = input.color(color.orange,"",           inline = "sLO", group = grpSession)

sessUseNYAM     = input.bool(true,         "",           inline = "sNA", group = grpSession)
sessNYAMTxt     = input.string("NY AM",    "",           inline = "sNA", group = grpSession)
sessNYAMSess    = input.session("0930-1100","",          inline = "sNA", group = grpSession)
sessNYAMCol     = input.color(#089981,     "",           inline = "sNA", group = grpSession)

sessUseNYPM     = input.bool(true,         "",           inline = "sNP", group = grpSession)
sessNYPMTxt     = input.string("NY PM",    "",           inline = "sNP", group = grpSession)
sessNYPMSess    = input.session("1330-1600","",          inline = "sNP", group = grpSession)
sessNYPMCol     = input.color(color.purple,"",           inline = "sNP", group = grpSession)

// ────────────────────────────────────────────────────────────────────────────
//  HEIKEN ASHI
// ────────────────────────────────────────────────────────────────────────────
var float haOpen = na
haClose = (open + high + low + close) / 4.0
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
haHigh  = math.max(high, math.max(haOpen, haClose))
haLow   = math.min(low,  math.min(haOpen, haClose))

haBody      = math.abs(haClose - haOpen)
haIsBullish = haClose > haOpen
haIsBearish = haClose < haOpen
haUpperWick = haHigh - math.max(haOpen, haClose)
haLowerWick = math.min(haOpen, haClose) - haLow

// ────────────────────────────────────────────────────────────────────────────
//  SUPPORTING SERIES
// ────────────────────────────────────────────────────────────────────────────
avgBody20   = ta.sma(haBody[1], bodyAvgLength)
avgVolume20 = ta.sma(volume, volAvgLength)
emaHA20     = ta.ema(haClose, emaLength)
stdevHA20   = ta.stdev(haClose, stdevLength)
atrValue    = ta.atr(atrLength)
atrAvg      = ta.sma(atrValue, atrAvgLength)
atrRatio    = atrAvg > 0 ? atrValue / atrAvg : 1.0
vwapValue   = ta.vwap(hlc3)

// ── HTF EMA (HA) — request from higher timeframes ──
f_htfHaClose(tf) =>
    _o = request.security(syminfo.tickerid, tf, open, lookahead = barmerge.lookahead_off)
    _h = request.security(syminfo.tickerid, tf, high, lookahead = barmerge.lookahead_off)
    _l = request.security(syminfo.tickerid, tf, low,  lookahead = barmerge.lookahead_off)
    _c = request.security(syminfo.tickerid, tf, close,lookahead = barmerge.lookahead_off)
    (_o + _h + _l + _c) / 4.0

htfHaClose1H = f_htfHaClose(f_htfTfStr(htfEma1TfStr))
htfEma1H     = ta.ema(htfHaClose1H, f_htfEmaLenVal(htfEma1LenStr))

// ── Time Separator helpers ──
f_sepStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// VWAP SD bands — cumulative variance from session start (matches TradingView built-in)
var float _sumVol    = 0.0
var float _sumPV     = 0.0
var float _sumPV2    = 0.0
_isNewSession = ta.change(time("D")) != 0 or (syminfo.session == "0000-0000" and bar_index == 0)
if _isNewSession
    _sumVol  := 0.0
    _sumPV   := 0.0
    _sumPV2  := 0.0
_sumVol  += volume
_sumPV   += hlc3 * volume
_sumPV2  += hlc3 * hlc3 * volume

// Count bars elapsed since session start (for MR warm-up guard)
var int _sessionBarCount = 0
if _isNewSession
    _sessionBarCount := 1
else
    _sessionBarCount := _sessionBarCount + 1
_vwapCalc   = _sumVol > 0 ? _sumPV  / _sumVol : hlc3
_vwapVar    = _sumVol > 0 ? _sumPV2 / _sumVol - _vwapCalc * _vwapCalc : 0.0
vwapSd      = math.sqrt(math.max(_vwapVar, 0.0))
vwap1SdUp   = vwapValue + 1.0 * vwapSd
vwap1SdDn   = vwapValue - 1.0 * vwapSd
vwap2SdUp   = vwapValue + 2.0 * vwapSd
vwap2SdDn   = vwapValue - 2.0 * vwapSd
vwap3SdUp   = vwapValue + 3.0 * vwapSd
vwap3SdDn   = vwapValue - 3.0 * vwapSd

// ────────────────────────────────────────────────────────────────────────────
//  FACTOR A — BODY EXPANSION
// ────────────────────────────────────────────────────────────────────────────
bodyExpansionRatio = avgBody20 > 0 ? haBody / avgBody20 : 0.0
bodyExpansionScore = math.min(bodyExpansionRatio * 50.0, 100.0)

// ────────────────────────────────────────────────────────────────────────────
//  FACTOR B — WICK QUALITY
// ────────────────────────────────────────────────────────────────────────────
opposingWick     = haIsBullish ? haLowerWick : haIsBearish ? haUpperWick : (haUpperWick + haLowerWick) / 2.0
wickRatio        = haBody > 0 ? opposingWick / haBody : 1.0
wickQualityScore = math.max(100.0 - wickRatio * 100.0, 0.0)

// ────────────────────────────────────────────────────────────────────────────
//  FACTOR C — TREND SLOPE
// ────────────────────────────────────────────────────────────────────────────
emaSlopeRaw     = (emaHA20 - emaHA20[slopeLookback]) / slopeLookback
slopePercent    = atrValue != 0 ? (emaSlopeRaw / atrValue) * 100.0 : 0.0
trendSlopeScore = math.min(math.abs(slopePercent) * slopeSensitivity, 100.0)

// ────────────────────────────────────────────────────────────────────────────
//  FACTOR D — VOLUME
// ────────────────────────────────────────────────────────────────────────────
volumeRatio = avgVolume20 > 0 ? volume / avgVolume20 : 1.0
volumeScore = math.min(volumeRatio * 50.0, 100.0)

// ────────────────────────────────────────────────────────────────────────────
//  FACTOR E — Z-SCORE
// ────────────────────────────────────────────────────────────────────────────
zScore = stdevHA20 != 0 ? (haClose - emaHA20) / stdevHA20 : 0.0

f_zScoreScore(z) =>
    absZ = math.abs(z)
    float score = 0.0
    if absZ <= 0.5
        score := (absZ / 0.5) * 60.0
    else if absZ <= 2.0
        score := 60.0 + ((absZ - 0.5) / 1.5) * 40.0
    else if absZ <= 3.0
        score := 100.0 - ((absZ - 2.0) / 1.0) * 40.0
    else
        score := math.max(60.0 - (absZ - 3.0) * 30.0, 0.0)
    score

zScoreScore = f_zScoreScore(zScore)

// ────────────────────────────────────────────────────────────────────────────
//  COMPOSITE MOMENTUM SCORE
// ────────────────────────────────────────────────────────────────────────────
totalWeight      = wBodyExp + wWickQual + wTrendSlope + wVolume + wZScore
weightedSum      = bodyExpansionScore * wBodyExp + wickQualityScore * wWickQual + trendSlopeScore * wTrendSlope + volumeScore * wVolume + zScoreScore * wZScore
momentumScoreRaw = totalWeight > 0 ? weightedSum / totalWeight : 0.0
momentumScore    = math.min(math.max(momentumScoreRaw, 0.0), 100.0)

// ────────────────────────────────────────────────────────────────────────────
//  DELTA
// ────────────────────────────────────────────────────────────────────────────
ltfClose  = request.security_lower_tf(syminfo.tickerid, deltaLowerTF, close)
ltfOpen   = request.security_lower_tf(syminfo.tickerid, deltaLowerTF, open)
ltfVolume = request.security_lower_tf(syminfo.tickerid, deltaLowerTF, volume)

f_sumBuyVol(closes, opens, vols) =>
    float total = 0.0
    if closes.size() > 0
        for i = 0 to closes.size() - 1
            if closes.get(i) > opens.get(i)
                total += vols.get(i)
    total

f_sumSellVol(closes, opens, vols) =>
    float total = 0.0
    if closes.size() > 0
        for i = 0 to closes.size() - 1
            if closes.get(i) < opens.get(i)
                total += vols.get(i)
    total

intrabarCount = ltfClose.size()
buyVolume     = f_sumBuyVol(ltfClose, ltfOpen, ltfVolume)
sellVolume    = f_sumSellVol(ltfClose, ltfOpen, ltfVolume)
deltaRaw      = buyVolume - sellVolume
deltaValid    = intrabarCount > 0

// ── Fallback สำหรับ historical bars ที่ lower TF data ไม่มี ──
// ────────────────────────────────────────────────────────────────────────────
//  DELTA — historical-safe
//  _deltaForSignal คำนวณทุก bar (ไม่ผ่าน barstate.isconfirmed)
//  ถ้ามี lower-TF จริง → ใช้ deltaRaw
//  ถ้าไม่มี (historical ย้อนเกิน buffer) → fallback ทิศ candle
//  deltaConfirmed/Valid ไว้สำหรับ dashboard แสดงผลเท่านั้น
// ────────────────────────────────────────────────────────────────────────────
_deltaForSignal = deltaValid ? deltaRaw : (close > open ? 1.0 : close < open ? -1.0 : 0.0)

var float deltaConfirmed      = na
var bool  deltaConfirmedValid = false
var bool  deltaIsRealData     = false

if barstate.isconfirmed
    deltaConfirmed      := _deltaForSignal
    deltaConfirmedValid := true
    deltaIsRealData     := deltaValid

// ────────────────────────────────────────────────────────────────────────────
//  SIGNAL LOGIC
// ────────────────────────────────────────────────────────────────────────────
vwapLongOk  = not useVwapFilter or close > vwapValue
vwapShortOk = not useVwapFilter or close < vwapValue

deltaLongOk  = not useDeltaFilter or _deltaForSignal > 0
deltaShortOk = not useDeltaFilter or _deltaForSignal < 0

strongBuyCore  = momentumScore > momentumThreshold and haIsBullish and haLowerWick <= haBody * (wickTolerancePct / 100.0) and haBody > avgBody20 and haClose > emaHA20 and vwapLongOk and deltaLongOk
strongSellCore = momentumScore > momentumThreshold and haIsBearish and haUpperWick <= haBody * (wickTolerancePct / 100.0) and haBody > avgBody20 and haClose < emaHA20 and vwapShortOk and deltaShortOk

buyBiasCore  = haIsBullish and haClose > emaHA20 and vwapLongOk  and momentumScore >= buySellThreshold
sellBiasCore = haIsBearish and haClose < emaHA20 and vwapShortOk and momentumScore >= buySellThreshold

// ────────────────────────────────────────────────────────────────────────────
//  5-LEVEL STATE MACHINE
// ────────────────────────────────────────────────────────────────────────────
var int STATE_STRONG_BUY  =  2
var int STATE_BUY         =  1
var int STATE_NEUTRAL     =  0
var int STATE_SELL        = -1
var int STATE_STRONG_SELL = -2

var int currentState   = STATE_NEUTRAL
var int previousState  = STATE_NEUTRAL
var int strongBarCount = 0

if barstate.isconfirmed
    previousState := currentState
    int newState = STATE_NEUTRAL
    if strongBuyCore
        newState := STATE_STRONG_BUY
    else if strongSellCore
        newState := STATE_STRONG_SELL
    else if buyBiasCore
        newState := STATE_BUY
    else if sellBiasCore
        newState := STATE_SELL
    currentState := newState
    if newState == STATE_STRONG_BUY or newState == STATE_STRONG_SELL
        strongBarCount := strongBarCount + 1
    else
        strongBarCount := 0

// ────────────────────────────────────────────────────────────────────────────
//  STRONG SIGNAL — ONE-SHOT + EMA RESET
//  แสดงจุดครั้งแรกครั้งเดียว แล้วล็อคจนกว่า Low (Buy) หรือ High (Sell)
//  ของแท่งใดก็ได้จะแตะ EMA (HA) ก่อน ถึงจะ trigger ใหม่ได้
// ────────────────────────────────────────────────────────────────────────────
var bool _buyEmaReset  = true
var bool _sellEmaReset = true

// อ่านสถานะก่อน update — ใช้ใน isFresh ด้านล่าง
_buyReadyNow  = _buyEmaReset
_sellReadyNow = _sellEmaReset

if barstate.isconfirmed
    // 1) ถ้า Low แตะ EMA → unlock ฝั่ง buy
    if low <= emaHA20
        _buyEmaReset  := true
    // 2) ถ้า High แตะ EMA → unlock ฝั่ง sell
    if high >= emaHA20
        _sellEmaReset := true
    // 3) ถ้า fire signal แล้ว → lock ทันที (ผลมีผลแท่งถัดไป)
    if currentState == STATE_STRONG_BUY  and _buyEmaReset
        _buyEmaReset  := false
    if currentState == STATE_STRONG_SELL and _sellEmaReset
        _sellEmaReset := false

// isFresh ใช้ _buyReadyNow (ค่าก่อน lock) ไม่ใช่ค่าหลัง lock
isFreshStrongBuy  = barstate.isconfirmed and currentState == STATE_STRONG_BUY  and previousState != STATE_STRONG_BUY  and _buyReadyNow
isFreshStrongSell = barstate.isconfirmed and currentState == STATE_STRONG_SELL and previousState != STATE_STRONG_SELL and _sellReadyNow

isLightWarningLong  = barstate.isconfirmed and previousState == STATE_STRONG_BUY  and currentState == STATE_BUY
isLightWarningShort = barstate.isconfirmed and previousState == STATE_STRONG_SELL and currentState == STATE_SELL

isHeavyWarningLong  = barstate.isconfirmed and previousState == STATE_STRONG_BUY  and (currentState == STATE_NEUTRAL or currentState == STATE_SELL)
isHeavyWarningShort = barstate.isconfirmed and previousState == STATE_STRONG_SELL and (currentState == STATE_NEUTRAL or currentState == STATE_BUY)

// ────────────────────────────────────────────────────────────────────────────
//  MEAN REVERSION SIGNAL
//  Pre-condition 1 (เดิม): VWAP Z-Score เกิน threshold + momentum อ่อน
//  Pre-condition 2 (ใหม่): Neutral HA candle กิน body แท่งสีก่อนหน้า
//    "Neutral" = haBody < avgBody20 (body เล็กกว่าค่าเฉลี่ย = momentum อ่อน)
//    "กิน body" = haOpen <= prev haClose_max และ haClose >= prev haOpen_min
//    Bull MR: neutral candle กิน body ของแท่งสีแดงก่อนหน้า (engulf bearish)
//    Bear MR: neutral candle กิน body ของแท่งสีเขียวก่อนหน้า (engulf bullish)
// ────────────────────────────────────────────────────────────────────────────
vwapZScore = vwapSd > 0 ? (close - vwapValue) / vwapSd : 0.0

mrSessionReady = _sessionBarCount >= mrMinBars
mrSdReady      = close > 0 and (vwapSd / close * 100.0) >= mrMinSdPct

// ── Engulf condition ──
// "Neutral" = haBody ของแท่งปัจจุบันเล็กกว่าค่าเฉลี่ย (momentum อ่อน)
// "Engulf"  = High ของแท่งปัจจุบัน ≥ body high ก่อนหน้า
//            AND Low ของแท่งปัจจุบัน ≤ body low ก่อนหน้า
// (ใช้ high/low จริง ไม่ใช่ haOpen/haClose เพราะ neutral candle มีไส้ยาว)
_mrNeutral    = haBody < avgBody20
_prevBodyHigh = math.max(haOpen[1], haClose[1])   // body top ของแท่งก่อน
_prevBodyLow  = math.min(haOpen[1], haClose[1])   // body bottom ของแท่งก่อน
_prevWasBear  = haClose[1] < haOpen[1]            // แท่งก่อน = HA แดง
_prevWasBull  = haClose[1] > haOpen[1]            // แท่งก่อน = HA เขียว

// high/low ของแท่งปัจจุบัน (real candle) กิน body ก่อนหน้า
_engulfBull   = _mrNeutral and _prevWasBear and high >= _prevBodyHigh and low <= _prevBodyLow
_engulfBear   = _mrNeutral and _prevWasBull and high >= _prevBodyHigh and low <= _prevBodyLow

_mrBaseCond = mrSessionReady and mrSdReady and momentumScore < mrMomentumMax and (not mrRequireFade or momentumScore < momentumScore[1])

mrBullCondition = barstate.isconfirmed and _mrBaseCond and vwapZScore <= -mrSdThreshold and _engulfBull

mrBearCondition = barstate.isconfirmed and _mrBaseCond and vwapZScore >= mrSdThreshold and _engulfBear

// MR TP/SL (same multipliers, dotted lines)
var float pendingMrBullRange = na
var bool  pendingMrBullDraw  = false
var float pendingMrBearRange = na
var bool  pendingMrBearDraw  = false

if mrBullCondition
    pendingMrBullRange := haHigh - haLow
    pendingMrBullDraw  := true
if mrBearCondition
    pendingMrBearRange := haHigh - haLow
    pendingMrBearDraw  := true

var array<line>  mrBullLines  = array.new<line>()
var array<label> mrBullLabels = array.new<label>()
var array<line>  mrBearLines  = array.new<line>()
var array<label> mrBearLabels = array.new<label>()

f_pruneMr(lineArr, labelArr) =>
    while lineArr.size() > 3
        line.delete(lineArr.shift())
    while labelArr.size() > 3
        label.delete(labelArr.shift())

if showMrTpSl and barstate.isconfirmed and pendingMrBullDraw[1]
    float rng = pendingMrBullRange[1]
    float ep  = open
    int x1 = bar_index
    int x2 = bar_index + tpSlLineLength
    int xL = x2 + tpSlLabelOffset
    mrBullLines.push(line.new(x1, ep + rng * tp1Multiplier, x2, ep + rng * tp1Multiplier, color = colMrBull, width = 1, style = line.style_dotted))
    mrBullLines.push(line.new(x1, ep + rng * tp2Multiplier, x2, ep + rng * tp2Multiplier, color = colMrBull, width = 1, style = line.style_dotted))
    mrBullLines.push(line.new(x1, ep - rng * slMultiplier,  x2, ep - rng * slMultiplier,  color = colSl,     width = 1, style = line.style_dotted))
    mrBullLabels.push(label.new(xL, ep + rng * tp1Multiplier, "MR TP1", color = color.new(color.black,100), textcolor = colMrBull, style = label.style_label_right, size = size.tiny))
    mrBullLabels.push(label.new(xL, ep + rng * tp2Multiplier, "MR TP2", color = color.new(color.black,100), textcolor = colMrBull, style = label.style_label_right, size = size.tiny))
    mrBullLabels.push(label.new(xL, ep - rng * slMultiplier,  "MR SL",  color = color.new(color.black,100), textcolor = colSl,     style = label.style_label_right, size = size.tiny))
    f_pruneMr(mrBullLines, mrBullLabels)
    pendingMrBullDraw := false

if showMrTpSl and barstate.isconfirmed and pendingMrBearDraw[1]
    float rng = pendingMrBearRange[1]
    float ep  = open
    int x1 = bar_index
    int x2 = bar_index + tpSlLineLength
    int xL = x2 + tpSlLabelOffset
    mrBearLines.push(line.new(x1, ep - rng * tp1Multiplier, x2, ep - rng * tp1Multiplier, color = colMrBear, width = 1, style = line.style_dotted))
    mrBearLines.push(line.new(x1, ep - rng * tp2Multiplier, x2, ep - rng * tp2Multiplier, color = colMrBear, width = 1, style = line.style_dotted))
    mrBearLines.push(line.new(x1, ep + rng * slMultiplier,  x2, ep + rng * slMultiplier,  color = colSl,     width = 1, style = line.style_dotted))
    mrBearLabels.push(label.new(xL, ep - rng * tp1Multiplier, "MR TP1", color = color.new(color.black,100), textcolor = colMrBear, style = label.style_label_right, size = size.tiny))
    mrBearLabels.push(label.new(xL, ep - rng * tp2Multiplier, "MR TP2", color = color.new(color.black,100), textcolor = colMrBear, style = label.style_label_right, size = size.tiny))
    mrBearLabels.push(label.new(xL, ep + rng * slMultiplier,  "MR SL",  color = color.new(color.black,100), textcolor = colSl,     style = label.style_label_right, size = size.tiny))
    f_pruneMr(mrBearLines, mrBearLabels)
    pendingMrBearDraw := false

// ────────────────────────────────────────────────────────────────────────────
//  TP / SL (trend-following)
// ────────────────────────────────────────────────────────────────────────────
var float pendingLongRange  = na
var bool  pendingLongTpSl   = false
var float pendingShortRange = na
var bool  pendingShortTpSl  = false

if isFreshStrongBuy
    pendingLongRange := haHigh - haLow
    pendingLongTpSl  := true
if isFreshStrongSell
    pendingShortRange := haHigh - haLow
    pendingShortTpSl  := true

var array<line>  longTpSlLines   = array.new<line>()
var array<label> longTpSlLabels  = array.new<label>()
var array<line>  shortTpSlLines  = array.new<line>()
var array<label> shortTpSlLabels = array.new<label>()

var float activeLongSlPrice  = na
var float activeShortSlPrice = na

f_pruneTpSlHistory(lineArr, labelArr, maxSets) =>
    while lineArr.size() > maxSets * 3
        line.delete(lineArr.shift())
    while labelArr.size() > maxSets * 3
        label.delete(labelArr.shift())

if showTpSl and barstate.isconfirmed and pendingLongTpSl[1]
    float rng      = pendingLongRange[1]
    float entryPx  = open
    float tp1Price = entryPx + rng * tp1Multiplier
    float tp2Price = entryPx + rng * tp2Multiplier
    float slPrice  = entryPx - rng * slMultiplier
    int   x1 = bar_index
    int   x2 = bar_index + tpSlLineLength
    int   xL = x2 + tpSlLabelOffset
    longTpSlLines.push(line.new(x1, tp1Price, x2, tp1Price, color = colTp, width = 1))
    longTpSlLines.push(line.new(x1, tp2Price, x2, tp2Price, color = colTp, width = 1))
    longTpSlLines.push(line.new(x1, slPrice,  x2, slPrice,  color = colSl, width = 1))
    longTpSlLabels.push(label.new(xL, tp1Price, "TP1", color = color.new(color.black,100), textcolor = colTp, style = label.style_label_right, size = size.tiny))
    longTpSlLabels.push(label.new(xL, tp2Price, "TP2", color = color.new(color.black,100), textcolor = colTp, style = label.style_label_right, size = size.tiny))
    longTpSlLabels.push(label.new(xL, slPrice,  "SL",  color = color.new(color.black,100), textcolor = colSl, style = label.style_label_right, size = size.tiny))
    f_pruneTpSlHistory(longTpSlLines, longTpSlLabels, tpSlHistoryCount)
    activeLongSlPrice := slPrice
    pendingLongTpSl   := false

if showTpSl and barstate.isconfirmed and pendingShortTpSl[1]
    float rng      = pendingShortRange[1]
    float entryPx  = open
    float tp1Price = entryPx - rng * tp1Multiplier
    float tp2Price = entryPx - rng * tp2Multiplier
    float slPrice  = entryPx + rng * slMultiplier
    int   x1 = bar_index
    int   x2 = bar_index + tpSlLineLength
    int   xL = x2 + tpSlLabelOffset
    shortTpSlLines.push(line.new(x1, tp1Price, x2, tp1Price, color = colTp, width = 1))
    shortTpSlLines.push(line.new(x1, tp2Price, x2, tp2Price, color = colTp, width = 1))
    shortTpSlLines.push(line.new(x1, slPrice,  x2, slPrice,  color = colSl, width = 1))
    shortTpSlLabels.push(label.new(xL, tp1Price, "TP1", color = color.new(color.black,100), textcolor = colTp, style = label.style_label_right, size = size.tiny))
    shortTpSlLabels.push(label.new(xL, tp2Price, "TP2", color = color.new(color.black,100), textcolor = colTp, style = label.style_label_right, size = size.tiny))
    shortTpSlLabels.push(label.new(xL, slPrice,  "SL",  color = color.new(color.black,100), textcolor = colSl, style = label.style_label_right, size = size.tiny))
    f_pruneTpSlHistory(shortTpSlLines, shortTpSlLabels, tpSlHistoryCount)
    activeShortSlPrice := slPrice
    pendingShortTpSl   := false

if isFreshStrongBuy
    activeLongSlPrice := na
if isFreshStrongSell
    activeShortSlPrice := na

// ────────────────────────────────────────────────────────────────────────────
//  SL HIT DETECTION
// ────────────────────────────────────────────────────────────────────────────
longSlHit  = barstate.isconfirmed and not na(activeLongSlPrice)  and close < activeLongSlPrice
shortSlHit = barstate.isconfirmed and not na(activeShortSlPrice) and close > activeShortSlPrice

if longSlHit
    activeLongSlPrice := na
if shortSlHit
    activeShortSlPrice := na

// ────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ────────────────────────────────────────────────────────────────────────────
f_scoreColor(score) =>
    score >= momentumThreshold ? colStrongBuy
     : score >= buySellThreshold ? color.new(color.yellow, 0) : colStrongSell

f_zScoreColor(z) =>
    absZ = math.abs(z)
    absZ >= 3.0 ? colStrongSell : absZ >= 2.0 ? color.new(color.yellow, 0)
     : absZ >= 0.5 ? colStrongBuy : color.white

f_atrColor(ratio) =>
    ratio >= atrRedRatio    ? color.new(color.red,    0) :
     ratio >= atrOrangeRatio ? color.new(color.orange, 0) :
     color.white

f_stateLabel(state) =>
    switch state
        STATE_STRONG_BUY  => "STRONG BUY"
        STATE_BUY         => "BUY"
        STATE_SELL        => "SELL"
        STATE_STRONG_SELL => "STRONG SELL"
        => "NEUTRAL"

f_stateColor(state) =>
    switch state
        STATE_STRONG_BUY  => colStrongBuy
        STATE_BUY         => colBuy
        STATE_SELL        => colSell
        STATE_STRONG_SELL => colStrongSell
        => colNeutral

f_tblSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

tblSz = f_tblSize(dashboardSize)

// ────────────────────────────────────────────────────────────────────────────
//  CANDLE COLOURING
// ────────────────────────────────────────────────────────────────────────────
candleColor = currentState == STATE_STRONG_BUY ? color.new(color.lime, 10) : currentState == STATE_BUY ? color.new(color.lime, 55) : currentState == STATE_STRONG_SELL ? color.new(color.red, 10) : currentState == STATE_SELL ? color.new(color.red, 55) : color.new(color.gray, 40)
barcolor(showCandleColors ? candleColor : na, title = "Signal Candle Color")

// ────────────────────────────────────────────────────────────────────────────
//  CHART PLOTS
// ────────────────────────────────────────────────────────────────────────────
plot(showEmaLine   ? emaHA20    : na, title = "EMA (HA)", color = colEmaLine,  linewidth = widEmaLine,  style = plot.style_line)
plot(showVwapLine  ? vwapValue  : na, title = "VWAP",     color = colVwapLine, linewidth = widVwapLine, style = plot.style_line)

// ── HTF EMA (HA) plots ──
plot(showHtfEma1 ? htfEma1H : na, title = "HTF EMA", color = colHtfEma1, linewidth = widHtfEma1, style = plot.style_line)

// ── Time Separators ──
_sep1Tf     = f_sepTfStr(sep1TfStr)
_sep1Change = ta.change(time(_sep1Tf))

var array<line> _sep1Lines = array.new<line>()

if showSep1 and _sep1Change != 0
    _sep1Lines.push(line.new(bar_index, high, bar_index, low,
         extend = extend.both, color = colSep1, style = f_sepStyle(sep1Style), width = widSep1))
    while _sep1Lines.size() > math.max(sep1LookBack + 1, 1)
        line.delete(_sep1Lines.shift())

p1Up  = plot(showSdBands ? vwap1SdUp : na, title = "VWAP +1SD", color = col1SdLine, linewidth = 1)
p1Dn  = plot(showSdBands ? vwap1SdDn : na, title = "VWAP -1SD", color = col1SdLine, linewidth = 1)
p2Up  = plot(showSdBands ? vwap2SdUp : na, title = "VWAP +2SD", color = col2SdLine, linewidth = 1)
p2Dn  = plot(showSdBands ? vwap2SdDn : na, title = "VWAP -2SD", color = col2SdLine, linewidth = 1)
p3Up  = plot(showSdBands ? vwap3SdUp : na, title = "VWAP +3SD", color = col3SdLine, linewidth = 2)
p3Dn  = plot(showSdBands ? vwap3SdDn : na, title = "VWAP -3SD", color = col3SdLine, linewidth = 2)
pMid  = plot(showSdBands ? vwapValue : na, title = "VWAP (fill ref)", display = display.none)

fill(p1Up, pMid, color = showSdBands ? col1SdBand : na, title = "+1SD Fill")
fill(pMid, p1Dn, color = showSdBands ? col1SdBand : na, title = "-1SD Fill")
fill(p2Up, p1Up, color = showSdBands ? col2SdBand : na, title = "+2SD Fill")
fill(p1Dn, p2Dn, color = showSdBands ? col2SdBand : na, title = "-2SD Fill")
fill(p3Up, p2Up, color = showSdBands ? col3SdBand : na, title = "+3SD Fill")
fill(p2Dn, p3Dn, color = showSdBands ? col3SdBand : na, title = "-3SD Fill")

plotshape(showEntryMarkers and isFreshStrongBuy,  title = "Entry: Strong Buy",  style = shape.circle,       location = location.belowbar, color = colStrongBuy,  size = size.small)
plotshape(showEntryMarkers and isFreshStrongSell, title = "Entry: Strong Sell", style = shape.circle,       location = location.abovebar, color = colStrongSell, size = size.small)
plotshape(showLightWarning and isLightWarningLong,  title = "Light Warn Long",  style = shape.diamond,      location = location.belowbar, color = colBuy,        size = size.tiny)
plotshape(showLightWarning and isLightWarningShort, title = "Light Warn Short", style = shape.diamond,      location = location.abovebar, color = colSell,       size = size.tiny)
plotshape(showHeavyWarning and isHeavyWarningLong,  title = "Heavy Warn Long",  style = shape.xcross,       location = location.belowbar, color = colStrongSell, size = size.tiny)
plotshape(showHeavyWarning and isHeavyWarningShort, title = "Heavy Warn Short", style = shape.xcross,       location = location.abovebar, color = colStrongBuy,  size = size.tiny)

longSlHitVisible  = showSlHitMarker and longSlHit  and not isFreshStrongBuy  and not isFreshStrongSell and not isLightWarningLong  and not isHeavyWarningLong
shortSlHitVisible = showSlHitMarker and shortSlHit and not isFreshStrongBuy  and not isFreshStrongSell and not isLightWarningShort and not isHeavyWarningShort
plotshape(longSlHitVisible,  title = "SL Hit Long",  style = shape.xcross, location = location.abovebar, color = colStrongSell, size = size.small)
plotshape(shortSlHitVisible, title = "SL Hit Short", style = shape.xcross, location = location.belowbar, color = colStrongBuy,  size = size.small)

// MR markers — triangles pointing toward the mean
plotshape(showMrSignal and mrBullCondition, title = "MR Bull", style = shape.triangleup,   location = location.belowbar, color = colMrBull, size = size.small)
plotshape(showMrSignal and mrBearCondition, title = "MR Bear", style = shape.triangledown, location = location.abovebar, color = colMrBear, size = size.small)

// ────────────────────────────────────────────────────────────────────────────
//  DASHBOARD — dynamic rows (only visible rows rendered)
//  Strategy: pre-count visible rows → size table dynamically
//  Row order: Header | Signal | Momentum | Body | Wick | Slope | Volume |
//             ZScore | VwapDist | VwapZ | StrongBars | Delta | SL | ATR
// ────────────────────────────────────────────────────────────────────────────

// Count how many data rows will be visible (excluding header)
visibleRows = 1  // always header
visibleRows += showRowSignal     ? 1 : 0
visibleRows += showRowMomentum   ? 1 : 0
visibleRows += showRowBody       ? 1 : 0
visibleRows += showRowWick       ? 1 : 0
visibleRows += showRowSlope      ? 1 : 0
visibleRows += showRowVolume     ? 1 : 0
visibleRows += showRowZScore     ? 1 : 0
visibleRows += showRowVwapDist   ? 1 : 0
visibleRows += showRowVwapZ      ? 1 : 0
visibleRows += showRowStrongBars ? 1 : 0
visibleRows += showRowDelta      ? 1 : 0
visibleRows += showRowSl         ? 1 : 0
visibleRows += showRowAtr        ? 1 : 0

var string tblPos = dashboardPos == "Top Right" ? position.top_right : dashboardPos == "Top Left" ? position.top_left : dashboardPos == "Bottom Right" ? position.bottom_right : position.bottom_left

// Table is created fresh every barstate.islast so row count matches exactly
// what is visible — no empty rows at the bottom.
var table dashboard = na

if barstate.islast
    if showDashboard
        // Delete old table and recreate with exact row count
        if not na(dashboard)
            table.delete(dashboard)
        dashboard := table.new(position = tblPos, columns = 2, rows = visibleRows,
             border_width = 1, border_color = color.new(color.gray, 30),
             bgcolor = color.new(color.black, 15))

        // ── Header (always row 0) ──
        table.cell(dashboard, 0, 0, "TCMD v3 Dashboard", text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = tblSz, text_halign = text.align_left)
        table.cell(dashboard, 1, 0, "",                  text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = tblSz)

        // ── Dynamic rows ──
        int row = 1

        if showRowSignal
            table.cell(dashboard, 0, row, "Signal",         text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, f_stateLabel(currentState), text_color = f_stateColor(currentState), text_size = tblSz)
            row := row + 1

        if showRowMomentum
            table.cell(dashboard, 0, row, "Momentum Score",  text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, str.tostring(momentumScore, "#.##"), text_color = f_scoreColor(momentumScore), text_size = tblSz)
            row := row + 1

        if showRowBody
            table.cell(dashboard, 0, row, "Body Expansion",  text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, str.tostring(bodyExpansionScore, "#.##") + "%", text_color = color.white, text_size = tblSz)
            row := row + 1

        if showRowWick
            table.cell(dashboard, 0, row, "Wick Quality",    text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, str.tostring(wickQualityScore, "#.##") + "%",  text_color = color.white, text_size = tblSz)
            row := row + 1

        if showRowSlope
            table.cell(dashboard, 0, row, "Trend Slope",     text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, str.tostring(slopePercent, "#.##"), text_color = slopePercent >= 0 ? colStrongBuy : colStrongSell, text_size = tblSz)
            row := row + 1

        if showRowVolume
            table.cell(dashboard, 0, row, "Volume Strength", text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, str.tostring(volumeRatio * 100.0, "#.##") + "%", text_color = color.white, text_size = tblSz)
            row := row + 1

        if showRowZScore
            table.cell(dashboard, 0, row, "Z-Score (EMA)",  text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, str.tostring(zScore, "#.##"), text_color = f_zScoreColor(zScore), text_size = tblSz)
            row := row + 1

        if showRowVwapDist
            vwapDistPct = vwapValue != 0 ? (close - vwapValue) / vwapValue * 100.0 : 0.0
            table.cell(dashboard, 0, row, "Price vs VWAP",  text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, (close > vwapValue ? "Above +" : "Below ") + str.tostring(math.abs(vwapDistPct), "#.##") + "%", text_color = close > vwapValue ? colStrongBuy : colStrongSell, text_size = tblSz)
            row := row + 1

        if showRowVwapZ
            vwapZscoreAbs = math.abs(vwapZScore)
            vwapZcol = vwapZscoreAbs >= 2.0 ? color.new(color.fuchsia, 0) : vwapZscoreAbs >= 1.0 ? color.new(color.yellow, 0) : color.white
            table.cell(dashboard, 0, row, "VWAP Z-Score",   text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, str.tostring(vwapZScore, "#.##"), text_color = vwapZcol, text_size = tblSz)
            row := row + 1

        if showRowStrongBars
            strongBarsText  = (currentState == STATE_STRONG_BUY or currentState == STATE_STRONG_SELL) ? str.tostring(strongBarCount) + " bars" : "-"
            strongBarsColor = strongBarCount >= 10 ? colStrongSell : strongBarCount >= 5 ? color.new(color.yellow, 0) : colStrongBuy
            table.cell(dashboard, 0, row, "Strong Bars",    text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, strongBarsText,   text_color = (currentState == STATE_STRONG_BUY or currentState == STATE_STRONG_SELL) ? strongBarsColor : color.gray, text_size = tblSz)
            row := row + 1

        if showRowDelta
            string deltaText  = "N/A"
            color  deltaColor = color.gray
            if deltaConfirmedValid
                if deltaIsRealData
                    totalDeltaVol = buyVolume + sellVolume
                    deltaPct      = totalDeltaVol > 0 ? (deltaConfirmed / totalDeltaVol) * 100.0 : 0.0
                    deltaText     := str.tostring(deltaConfirmed, "#.##") + " (" + str.tostring(deltaPct, "#.##") + "%)"
                else
                    deltaText := deltaConfirmed > 0 ? "↑ candle" : deltaConfirmed < 0 ? "↓ candle" : "–"
                deltaColor := deltaConfirmed > 0 ? colStrongBuy : deltaConfirmed < 0 ? colStrongSell : colNeutral
            table.cell(dashboard, 0, row, "Delta (" + deltaLowerTF + ")", text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, deltaText, text_color = deltaColor, text_size = tblSz)
            row := row + 1

        if showRowSl
            slText  = not na(activeLongSlPrice) ? str.tostring(activeLongSlPrice, "#.####") : not na(activeShortSlPrice) ? str.tostring(activeShortSlPrice, "#.####") : "-"
            slColor = not na(activeLongSlPrice) or not na(activeShortSlPrice) ? colSl : color.gray
            table.cell(dashboard, 0, row, "Active SL",  text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, slText,        text_color = slColor,     text_size = tblSz)
            row := row + 1

        if showRowAtr
            // ATR value | ratio vs average | volatility label
            string atrVolLabel = atrRatio >= atrRedRatio    ? " ▲▲ HIGH" :
                                  atrRatio >= atrOrangeRatio ? " ▲ ELEV"  : " ● NORM"
            string atrCellText = str.tostring(atrValue, "#.####") +
                                  "  ×" + str.tostring(atrRatio, "#.##") + atrVolLabel
            table.cell(dashboard, 0, row, "ATR(" + str.tostring(atrLength) + ")", text_color = color.white, text_size = tblSz, text_halign = text.align_left)
            table.cell(dashboard, 1, row, atrCellText, text_color = f_atrColor(atrRatio), text_size = tblSz)
            row := row + 1

    else
        if not na(dashboard)
            table.delete(dashboard)
            dashboard := na

// ────────────────────────────────────────────────────────────────────────────
//  SESSION HIGHLIGHTS — box engine (HTF Suite style)
// ────────────────────────────────────────────────────────────────────────────

// ── helpers ──
f_sessLblSz(s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

var bool _sessTfOk = timeframe.in_seconds() < timeframe.in_seconds(sessTfLimit)

// ── per-session state type ──
type SessState
    array<box>   boxes
    array<line>  hiLines
    array<line>  loLines
    array<label> labels
    float        curHi
    float        curLo

f_newSessState() =>
    SessState.new(array.new<box>(), array.new<line>(), array.new<line>(), array.new<label>(), na, na)

var SessState _stAS = f_newSessState()
var SessState _stLO = f_newSessState()
var SessState _stNA = f_newSessState()
var SessState _stNP = f_newSessState()

f_sessManage(SessState st, bool useS, string sess, string txt, color col) =>
    if sessEnable and useS and _sessTfOk
        _inNow  = not na(time("", sess, sessTz))
        _inPrev = not na(time("", sess, sessTz, bars_back = 1))
        _bc     = color.new(col, sessBoxTrans)
        _trans  = color.new(color.white, 100)

        // ── session opens: create new box + pivot lines + label ──
        if _inNow and not _inPrev
            st.curHi := high
            st.curLo := low

            st.boxes.unshift(box.new(time, high, time, low,
                 xloc         = xloc.bar_time,
                 border_color = _bc,
                 bgcolor      = _bc))

            if sessShowPivots
                st.hiLines.unshift(line.new(time, high, time, high,
                     xloc  = xloc.bar_time,
                     color = col,
                     width = sessPivotWidth))
                st.loLines.unshift(line.new(time, low, time, low,
                     xloc  = xloc.bar_time,
                     color = col,
                     width = sessPivotWidth))

            if sessShowLabels
                // Top = label แปะเหนือ High ของแท่งเปิด session
                // Bottom = label แปะใต้ Low ของแท่งเปิด session
                _lblY   = sessLabelPos == "Bottom" ? low  : high
                _lblSty = sessLabelPos == "Bottom" ? label.style_label_up : label.style_label_down
                st.labels.unshift(label.new(time, _lblY, txt,
                     xloc      = xloc.bar_time,
                     color     = _trans,
                     textcolor = col,
                     style     = _lblSty,
                     size      = f_sessLblSz(sessLabelSize)))

            // ── prune old drawings beyond sessMaxDays ──
            if st.boxes.size() > sessMaxDays
                st.boxes.pop().delete()
            if sessShowPivots and st.hiLines.size() > sessMaxDays
                st.hiLines.pop().delete()
                st.loLines.pop().delete()
            if sessShowLabels and st.labels.size() > sessMaxDays
                st.labels.pop().delete()

        // ── session in progress: expand box + update pivot extremes + update label y ──
        if _inNow and st.boxes.size() > 0
            st.curHi := math.max(high, nz(st.curHi, high))
            st.curLo := math.min(low,  nz(st.curLo, low))

            b = st.boxes.get(0)
            b.set_right(time)
            b.set_top(st.curHi)
            b.set_bottom(st.curLo)

            if sessShowPivots and st.hiLines.size() > 0
                hl = st.hiLines.get(0)
                ll = st.loLines.get(0)
                hl.set_x2(time)
                ll.set_x2(time)
                if high > hl.get_y1()
                    hl.set_xy1(hl.get_x1(), high)
                    hl.set_xy2(time, high)
                if low < ll.get_y1()
                    ll.set_xy1(ll.get_x1(), low)
                    ll.set_xy2(time, low)

            // label x = pinned at session open bar (set once on creation, x unchanged)
            // label y = tracks box top (Top) or box bottom (Bottom)
            if sessShowLabels and st.labels.size() > 0
                _lbl = st.labels.get(0)
                _lbl.set_y(sessLabelPos == "Bottom" ? st.curLo : st.curHi)

f_sessManage(_stAS, sessUseAsia,   sessAsiaSess,   sessAsiaTxt,   sessAsiaCol)
f_sessManage(_stLO, sessUseLondon, sessLondonSess, sessLondonTxt, sessLondonCol)
f_sessManage(_stNA, sessUseNYAM,   sessNYAMSess,   sessNYAMTxt,   sessNYAMCol)
f_sessManage(_stNP, sessUseNYPM,   sessNYPMSess,   sessNYPMTxt,   sessNYPMCol)

// ────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ────────────────────────────────────────────────────────────────────────────
alertcondition(isFreshStrongBuy,    title = "Entry: Strong Buy",                    message = "TCMD v3: Fresh Strong Buy on {{ticker}} ({{interval}}).")
alertcondition(isFreshStrongSell,   title = "Entry: Strong Sell",                   message = "TCMD v3: Fresh Strong Sell on {{ticker}} ({{interval}}).")
alertcondition(isLightWarningLong,  title = "Light Warning: Long fading",           message = "TCMD v3: Long momentum easing on {{ticker}} ({{interval}}).")
alertcondition(isLightWarningShort, title = "Light Warning: Short fading",          message = "TCMD v3: Short momentum easing on {{ticker}} ({{interval}}).")
alertcondition(isHeavyWarningLong,  title = "Heavy Warning: Long reversing",        message = "TCMD v3: Strong Buy dropped to Neutral/Sell on {{ticker}} ({{interval}}).")
alertcondition(isHeavyWarningShort, title = "Heavy Warning: Short reversing",       message = "TCMD v3: Strong Sell dropped to Neutral/Buy on {{ticker}} ({{interval}}).")
alertcondition(longSlHit,           title = "SL Hit: Long",                         message = "TCMD v3: Long SL hit on {{ticker}} ({{interval}}).")
alertcondition(shortSlHit,          title = "SL Hit: Short",                        message = "TCMD v3: Short SL hit on {{ticker}} ({{interval}}).")
alertcondition(mrBullCondition,     title = "Mean Reversion: Bull Setup",           message = "TCMD v3: MR Bull — price at VWAP -2SD, momentum fading on {{ticker}} ({{interval}}).")
alertcondition(mrBearCondition,     title = "Mean Reversion: Bear Setup",           message = "TCMD v3: MR Bear — price at VWAP +2SD, momentum fading on {{ticker}} ({{interval}}).")
````
