<!-- tradingview-pine-id: PUB;2aabaa5aa87b48f9b6561633db05520f -->
<!-- tradingviewscripts-format: 1 -->
# Strong Gold H4 Pressure Zones

Source: https://www.tradingview.com/script/e7mUd5yT-Strong-Gold-H4-Pressure-Zones-ProjectSyndicate/

## Description

Strong Gold H4 Pressure Zones

Strong Gold H4 Pressure Zones maps the gold trading day the way it actually moves — split into its true H4 rhythm — and reads three institutional layers on every candle slot: which parts of the session run hot, where the previous candle's wick left unfinished business, and where price gapped away from value. It is built to run on the M5 timeframe — M5 is the execution resolution the whole engine is calibrated to, while it thinks in H4, so you see the higher-timeframe structure forming live on your chart. Load it on an M5 XAUUSD chart for correct slot alignment and zone behaviour.

Most session tools just draw a box around the day. This one grades every H4 slot, projects the pressure the last candle built, and marks the gaps — all anchored to the daily candle open, identical for every trader on the planet.

🕐 True Gold-Day Slot Engine — the core. The gold day (≈23h with its 1-hour technical break) is sliced into six real periods: an H3 opening block, then five H4 candles — aligned to the actual 04:00 / 08:00 / 12:00 / 16:00 / 20:00 boundaries, not a naïve 4-hour count. Every slot is drawn as a shaded box built live from that slot's own high/low, anchored to the daily candle's open so the zones are the same in Miami, Dubai or Singapore regardless of chart timezone.

⏱️ Runs on M5 — by design. This indicator is meant to be applied on the M5 timeframe. The six H4 slots are built up tick by tick from M5 candles, and the pressure, volatility and FVG zones are all calibrated to that resolution. Apply it to an M5 chart — other timeframes will not slice the gold day correctly.

📊 20% Increment Grid — read position at a glance. Each slot box is split by horizontal guides at 0 / 20 / 40 / 60 / 80 / 100% of its range, labelled on the right. Instantly see whether price is pressing the extremes of the current H4 or coiling in the middle — the exact levels institutions lean on within a candle.

🌋 30-Day Session Volatility Profile — the rhythm read. This is not the current candle's volatility. Each of the six slots is averaged over the last 30 days and the six averages are ranked against each other 0–10, printing a fixed grade on every slot — CALM, MODERATE, HIGH, EXTREME. You learn which H4 windows of the gold session typically explode and which drift, so you size and time around the day's real character instead of guessing. The rank is static and colour-graded (calm teal → extreme purple), only drifting slowly as the rolling window updates.

🧲 Prior-Candle Pressure Zones — the wick memory. The heart of the tool. The moment a slot closes, it's read as a single composite H4 candle and its dominant wick is projected forward as a fixed pressure band inside the next slot:

A strong upper wick on the prior candle → SELL PRESSURE zone near the top (rejection from above — supply left overhead).
A strong lower wick on the prior candle → BUY PRESSURE zone near the bottom (rejection from below — demand left beneath).

Each band is graded 0–10 on wick dominance and printed with its score (▲ BUY PRESSURE 8.4/10 · ▼ SELL PRESSURE 7.2/10), opacity scaling with strength. These are fixed the instant the prior candle closes — they never repaint.

🔀 Prior-Slot Fair Value Gap — the imbalance carry-over. A true three-candle FVG detected on the H4 slots themselves (the slots are the candles), projected as a clean Fair Value Gap zone into the current slot, normalized to one uniform ATR-based height so no single gap swallows the chart. An optional gap-size filter keeps the noise out. You see the imbalance the last three candles left, drawn where it matters, without the clutter.

🎨 Fully Themed & Configurable. Volatility-graded box tones, custom buy/sell pressure and FVG colours, neutral increment grid, adjustable opacities, 2× increment and rank label sizing, per-module toggles, configurable opening-block / break / slot hours, volatility lookback, wick thresholds, FVG ATR length / extend / height, and sessions-to-plot depth.

🔒 Honest, Fixed-Zone Core. The live slot box repaints in price as the candle forms — inherent to showing a real-time H4 building on M5, not a defect. But every fixed output — the pressure bands, the FVG, the volatility rank — is locked to the prior completed candle and never redraws to flatter the chart. The 0–10 scores are descriptive ranking frameworks for directing attention, not backtested signals.

🚀 Built for XAUUSD on the M5 timeframe — the slot model matches gold's 23-hour day and 1-hour break out of the box. Use it on an M5 gold chart (adjust the hour inputs for other instruments).

🎯 How To Trade It — Pressure From The Prior H4

⏱️ Load the indicator on an M5 XAUUSD chart before anything else — the entire slot model is built for M5.

Everything hinges on one read: the last H4 candle told you where price got rejected — trade the current candle expecting that pressure to hold, or break with conviction when it fails.

◾ 1) Fade into a prior-candle pressure zone (the core thesis)

Use when the previous H4 left a strong wick and the current slot rotates back into that band.

▪️ The prior candle prints a strong lower wick → a graded BUY PRESSURE zone sits in the lower portion of the current slot. Buyers already defended there once. ▪️ Wait for price to rotate down into that band inside the current slot — ideally near the 0–20% increment level. ▪️ Entry: long as price reacts inside the buy-pressure zone; the higher the score (7+), the more the prior candle insisted on that level. ▪️ Stop: below the zone — if price closes through and accepts beneath it, the demand failed; stand aside. ▪️ Target: the mid-grid (50%) first, the opposite edge / prior-candle high on extension.

The mirror applies for a strong upper wick → SELL PRESSURE zone up top: fade rallies into it, stop above, target back down through the grid.

◾ 2) Weight it with the session profile

▪️ A pressure zone landing in a HIGH / EXTREME volatility slot means the reaction can be violent — expect follow-through and give the target room. ▪️ The same zone in a CALM slot means muted rotation — take the mid-grid and don't overstay. ▪️ The volatility rank tells you how hard the day's structure usually moves in that window before you commit.

◾ 3) Read the FVG as the pull

▪️ An unfilled Fair Value Gap projected into the current slot is where price is imbalanced — it often gets revisited. A buy-pressure zone below an open bullish FVG is confluence: rejection level plus imbalance both pointing up. ▪️ When a pressure zone and the FVG point opposite ways, that's conflict — let the slot resolve before committing.

◾ 4) Stand down — the map says wait

▪️ Prior candle closed as a clean body with no dominant wick → no pressure zone drew → no edge from rejection this slot. ▪️ Price already accepted through the pressure band → the level's spent. ▪️ CALM slot with no FVG and price mid-range → nothing worth risking on; let it develop.

Rule of thumb: ⭐ Strong prior-candle wick + price rotating into that graded pressure zone + a HIGH-volatility slot or aligned FVG → trade the rejection with the pull. ⭐ No wick, consumed zone, or dead CALM mid-range → stand down until the next candle sets the map.

⚠️ IMPORTANT NOTICE: Strong Gold H4 Pressure Zones is a structure-mapping tool designed for the M5 timeframe on XAUUSD. Pressure zones are projected from the prior H4 candle's wick geometry, the volatility rank is a 30-day per-slot average, and FVGs are drawn from three-candle gap logic — a model of behaviour, not exchange order-book data. The 0–10 scores are descriptive ranking frameworks for directing attention — NOT backtested signals and NOT standalone trade triggers. Fading into prior-candle pressure still carries real risk of failed levels and stop-outs. Always combine it with your own strategy, price-action analysis and risk management. Past behaviour does not guarantee future results.

---

## Source Code

````pine
//@version=6

indicator("Strong Gold H4 Pressure Zones", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

gSes = "═══ Session / Slot Model ═══"
i_firstHrs   = input.int(3,  "Opening Block Hours (slot 1)", group = gSes, minval = 1, maxval = 6, tooltip = "Length of the first slot (H3), 00:00-03:00.")
i_breakHrs   = input.int(1,  "Technical Break Hours (after opening block)", group = gSes, minval = 0, maxval = 3, tooltip = "Gold's 1h break sits between the H3 block and the first H4. Shifts every slot after the first by this much so H4 boxes align to the real 04:00/08:00/12:00/16:00/20:00 candles. No box drawn during the break.")
i_slotHrs    = input.int(4,  "Subsequent Slot Hours", group = gSes, minval = 1, maxval = 6, tooltip = "Length of each H4 slot after the break. 4 = H4.")
i_sessions   = input.int(10, "Sessions To Plot (days back)", group = gSes, minval = 1, maxval = 40, tooltip = "How many past trading days of slot boxes to keep drawn.")

gVol = "═══ Volatility Ranking ═══"
i_volDays    = input.int(30, "Volatility Lookback (days)", group = gVol, minval = 5, maxval = 90, tooltip = "Each slot's range is percentile-ranked against ALL slot ranges pooled over this many past days, giving a true 0–10 spread.")

gWick = "═══ Wick Pressure (previous H4 slot) ═══"
i_wickPct    = input.float(15.0, "Min Wick % of Range", group = gWick, minval = 5.0, maxval = 60.0, step = 1.0, tooltip = "The PREVIOUS slot's dominant wick (that slot as one composite candle), measured as wick length / slot range, must reach this to project a pressure zone. A real H4 rejection wick is ~15-35% of range — NOT a 58% pinbar.")
i_wickStr10  = input.float(45.0, "Wick % For 10/10 Strength", group = gWick, minval = 20.0, maxval = 90.0, step = 1.0, tooltip = "Wick fraction of range that scores a full 10/10 pressure rank. Between the min threshold and this, strength scales 0→10.")

gFvg = "═══ Previous-Slot FVG (H4) ═══"
i_showFvg    = input.bool(true, "Show Previous-Slot FVG Zone", group = gFvg, tooltip = "Detect a Fair Value Gap across the previous three H4 slots (the slots ARE the candles) and, if strong enough, project it as a fixed zone into the current box — same behaviour as the pressure zones.")
i_fvgMinStr  = input.float(0.0, "Min Gap Size Filter (gap/ATR scaled 0-10)", group = gFvg, minval = 0.0, maxval = 10.0, step = 0.5, tooltip = "Detection filter only (not shown on chart): larger gaps vs ATR pass. Raise to show fewer, cleaner FVGs; lower to show more. 0 = show every gap.")
i_fvgAtrLen  = input.int(14, "FVG ATR Length (H4 slots)", group = gFvg, minval = 1, tooltip = "ATR over completed slot ranges, used to grade the gap size.")
i_fvgExtend  = input.int(3, "FVG Extend Right (slots)", group = gFvg, minval = 1, maxval = 10, tooltip = "How many slots to the right the FVG rectangle projects from where it formed.")
i_fvgNormAtr = input.float(0.1, "FVG Zone Height (ATR mult)", group = gFvg, minval = 0.1, maxval = 3.0, step = 0.05, tooltip = "Universal zone height: every FVG box is drawn this many slot-ATRs tall, centered on the gap midpoint, so no giant zones. Set 0 to use the raw gap height instead.")

gStyle = "═══ Style ═══"
i_showGuides = input.bool(true,  "Show 20% Increment Lines", group = gStyle)
i_showPct    = input.bool(true,  "Show Increment % Labels", group = gStyle)
i_pctSize    = input.string("normal", "Increment % Label Size", options = ["tiny","small","normal","large","huge"], group = gStyle, tooltip = "Size of the 0%/20%/40%/60%/80%/100% labels on each box.")
i_showVolLbl = input.bool(true,  "Show Volatility Rank Label", group = gStyle)
i_showPress  = input.bool(true,  "Show Bullish/Bearish Pressure Zones", group = gStyle)
i_transp     = input.int(84, "Box Fill Transparency", group = gStyle, minval = 50, maxval = 96)
i_pressTransp= input.int(88, "Pressure Zone Transparency", group = gStyle, minval = 40, maxval = 96)
i_lblSize    = input.string("small", "Label Size", options = ["tiny","small","normal","large","huge"], group = gStyle)

gCol = "═══ Colors ═══"
i_volLo      = input.color(#26a69a, "Vol Low  (0-3)",  group = gCol, inline = "v")
i_volMid     = input.color(#00897b, "Vol Mid  (4-6)",  group = gCol, inline = "v")
i_volHi      = input.color(#880e4f, "Vol High (7-8)",  group = gCol, inline = "v")
i_volXt      = input.color(#4a148c, "Vol Extreme (9-10)", group = gCol, inline = "v")
i_bearPress  = input.color(#b71c1c, "Bearish Pressure", group = gCol, inline = "p")
i_bullPress  = input.color(#1b5e20, "Bullish Pressure", group = gCol, inline = "p")
i_fvgBull    = input.color(#00796b, "Bullish FVG", group = gCol, inline = "f")
i_fvgBear    = input.color(#6a1b9a, "Bearish FVG", group = gCol, inline = "f")
i_guideCol   = input.color(#78909c, "Increment Lines", group = gCol)

var color C_LBL = #CFD8DC

f_lsize(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.small

var string pfmt = "#.##"
if barstate.isfirst
    pfmt := syminfo.mintick <= 0.0001 ? "#.#####" : syminfo.mintick <= 0.01 ? "#.###" : syminfo.mintick <= 0.1 ? "#.##" : "#.#"
f_px(p) => str.tostring(p, pfmt)

f_volCol(float sc) =>
    sc >= 9 ? i_volXt : sc >= 7 ? i_volHi : sc >= 4 ? i_volMid : i_volLo

f_stars(float sc) =>
    sc >= 9 ? "★★★★★" : sc >= 7 ? "★★★★" : sc >= 5 ? "★★★" : sc >= 3 ? "★★" : sc >= 1 ? "★" : "·"

f_tier(float sc) =>
    sc >= 9 ? "EXTREME" : sc >= 7 ? "HIGH" : sc >= 4 ? "MODERATE" : "CALM"

f_wickStr(float wickFrac) =>
    float lo = i_wickPct   / 100.0
    float hi = i_wickStr10 / 100.0
    float sc = 0.0
    if wickFrac >= lo
        sc := math.min(math.max((wickFrac - lo) / math.max(hi - lo, 0.01), 0.0), 1.0) * 10.0
    sc

f_pressTransp(float str10) =>
    math.max(i_pressTransp - int(str10 * 3.2), 30)

f_fvgStr(float gapSize, float atrVal) =>
    float sc = 3.0
    if atrVal > 0
        float r = gapSize / atrVal
        sc := r >= 1.5 ? 8.0 : r >= 1.0 ? 6.0 : r >= 0.75 ? 4.5 : r >= 0.5 ? 3.0 : 1.5
    math.min(math.max(sc, 0.0), 10.0)

int  dayStartT = time("D")
bool newDay    = not na(dayStartT) and ta.change(dayStartT) != 0

var int dayOpenTime = na
if not na(dayStartT) and (na(dayOpenTime) or newDay)
    dayOpenTime := dayStartT

bool inDay = not na(dayOpenTime)

int firstSecs = i_firstHrs * 3600
int breakSecs = i_breakHrs * 3600
int slotSecs  = i_slotHrs  * 3600
int h4Start   = firstSecs + breakSecs

int secsIn = inDay ? int((time - dayOpenTime) / 1000) : na

f_slotIdx(int s) =>
    na(s) or s < 0 ? -1 : s < firstSecs ? 0 : s < h4Start ? -1 : math.min(5, 1 + int((s - h4Start) / slotSecs))

int slotIdx     = f_slotIdx(secsIn)
int slotIdxPrev = f_slotIdx(secsIn[1])
bool newSlot    = inDay and slotIdx >= 0 and (slotIdx != slotIdxPrev or newDay)

f_slotMs(int idx) =>
    (idx == 0 ? i_firstHrs : i_slotHrs) * 3600 * 1000

var array<float> volCal0 = array.new<float>()
var array<float> volCal1 = array.new<float>()
var array<float> volCal2 = array.new<float>()
var array<float> volCal3 = array.new<float>()
var array<float> volCal4 = array.new<float>()
var array<float> volCal5 = array.new<float>()

f_volArr(int idx) =>
    switch idx
        0 => volCal0
        1 => volCal1
        2 => volCal2
        3 => volCal3
        4 => volCal4
        => volCal5

f_avgRange(int idx) =>
    arr = f_volArr(idx)
    int sz = array.size(arr)
    float a = na
    if sz > 0
        float s = 0.0
        for j = 0 to sz - 1
            s += array.get(arr, j)
        a := s / sz
    a

f_volScore(int idx) =>
    float sc = na
    if idx >= 0
        float lo   = na
        float hi   = na
        int   good = 0
        for k = 0 to 5
            float a = f_avgRange(k)
            if not na(a)
                good += 1
                lo := na(lo) or a < lo ? a : lo
                hi := na(hi) or a > hi ? a : hi
        float me = f_avgRange(idx)
        if not na(me) and good >= 2 and not na(lo) and not na(hi) and hi > lo
            sc := math.min(math.max((me - lo) / (hi - lo), 0.0), 1.0) * 10.0
        else if not na(me)
            sc := 5.0
    sc

var int   curSlot  = -1
var int   curStartT= na
var float curHi    = na
var float curLo    = na
var float curOpen  = na
var float curClose = na

var float prevUpPct  = 0.0
var float prevLoPct  = 0.0
var float prevUpTop  = na
var float prevUpBot  = na
var float prevLoTop  = na
var float prevLoBot  = na
var bool  prevValid  = false

var float slotHi1 = na
var float slotLo1 = na
var float slotHi2 = na
var float slotLo2 = na
var array<float> slotRngHist = array.new<float>()
var bool  fvgValid = false
var bool  fvgBull  = false
var float fvgTop   = na
var float fvgBot   = na
var float fvgStr   = 0.0
var float fvgAtr   = na

var box   liveBox    = na
var array<line>  liveGuides = array.new<line>()
var array<label> livePctLbl = array.new<label>()
var label liveVolLbl = na

var array<box>   histBox   = array.new<box>()
var array<line>  histLine  = array.new<line>()
var array<label> histLbl   = array.new<label>()
var array<box>   histPress = array.new<box>()
var array<box>   histFvg   = array.new<box>()

f_archiveBox(box b) =>
    if not na(b)
        array.push(histBox, b)
        while array.size(histBox) > i_sessions * 6
            box.delete(array.shift(histBox))
f_archiveLines(array<line> src) =>
    if array.size(src) > 0
        for idx = 0 to array.size(src) - 1
            array.push(histLine, array.get(src, idx))
        while array.size(histLine) > i_sessions * 6 * 6
            line.delete(array.shift(histLine))
f_archiveLbls(array<label> src) =>
    if array.size(src) > 0
        for idx = 0 to array.size(src) - 1
            array.push(histLbl, array.get(src, idx))
        while array.size(histLbl) > i_sessions * 6 * 7
            label.delete(array.shift(histLbl))
f_archiveLbl(label l) =>
    if not na(l)
        array.push(histLbl, l)
        while array.size(histLbl) > i_sessions * 6 * 7
            label.delete(array.shift(histLbl))
f_archivePress(box b) =>
    if not na(b)
        array.push(histPress, b)
        while array.size(histPress) > i_sessions * 6 * 2
            box.delete(array.shift(histPress))
f_archiveFvg(box b) =>
    if not na(b)
        array.push(histFvg, b)
        while array.size(histFvg) > i_sessions * 6
            box.delete(array.shift(histFvg))

if barstate.isconfirmed
    if newSlot and inDay
        if curSlot >= 0 and not na(curHi) and not na(curLo) and (curHi - curLo) > 0
            float rng = curHi - curLo
            arr = f_volArr(curSlot)
            array.push(arr, rng)
            while array.size(arr) > i_volDays
                array.shift(arr)
            float bodyTop = math.max(curOpen, curClose)
            float bodyBot = math.min(curOpen, curClose)
            prevUpPct := math.min(math.max(curHi - bodyTop, 0.0) / rng, 1.0)
            prevLoPct := math.min(math.max(bodyBot - curLo, 0.0) / rng, 1.0)
            prevUpTop := curHi
            prevUpBot := bodyTop
            prevLoTop := bodyBot
            prevLoBot := curLo
            prevValid := true

            array.push(slotRngHist, rng)
            while array.size(slotRngHist) > i_fvgAtrLen
                array.shift(slotRngHist)
            float slotAtr = na
            if array.size(slotRngHist) > 0
                float s = 0.0
                for j = 0 to array.size(slotRngHist) - 1
                    s += array.get(slotRngHist, j)
                slotAtr := s / array.size(slotRngHist)
            fvgValid := false
            if not na(slotHi2) and not na(slotLo2) and not na(slotAtr) and slotAtr > 0
                if curLo > slotHi2
                    float gap = curLo - slotHi2
                    float st  = f_fvgStr(gap, slotAtr)
                    if st >= i_fvgMinStr
                        fvgValid := true
                        fvgBull  := true
                        fvgTop   := curLo
                        fvgBot   := slotHi2
                        fvgStr   := st
                        fvgAtr   := slotAtr
                else if curHi < slotLo2
                    float gap = slotLo2 - curHi
                    float st  = f_fvgStr(gap, slotAtr)
                    if st >= i_fvgMinStr
                        fvgValid := true
                        fvgBull  := false
                        fvgTop   := slotLo2
                        fvgBot   := curHi
                        fvgStr   := st
                        fvgAtr   := slotAtr
            slotHi2 := slotHi1
            slotLo2 := slotLo1
            slotHi1 := curHi
            slotLo1 := curLo

        if not na(liveBox)
            f_archiveBox(liveBox)
        f_archiveLines(liveGuides)
        f_archiveLbls(livePctLbl)
        if not na(liveVolLbl)
            f_archiveLbl(liveVolLbl)
        liveBox    := na
        liveVolLbl := na
        array.clear(liveGuides)
        array.clear(livePctLbl)

        curSlot  := slotIdx
        curStartT:= time
        curHi    := high
        curLo    := low
        curOpen  := open
        curClose := close

        if i_showPress and prevValid
            float lo  = i_wickPct / 100.0
            int   pxL = curStartT
            int   pxR = curStartT + f_slotMs(curSlot)
            if prevUpPct >= lo and not na(prevUpTop) and not na(prevUpBot) and prevUpTop > prevUpBot
                float bs = f_wickStr(prevUpPct)
                color bc = color.new(i_bearPress, f_pressTransp(bs))
                bbox = box.new(pxL, prevUpTop, pxR, prevUpBot, xloc = xloc.bar_time, bgcolor = bc, border_color = color.new(i_bearPress, 25), border_width = 1)
                f_archivePress(bbox)
                blab = label.new(int((pxL + pxR) / 2), prevUpTop, "▼ SELL PRESSURE  " + f_stars(bs) + " " + str.tostring(bs, "#.0") + "/10", xloc = xloc.bar_time, style = label.style_label_down, color = color.new(i_bearPress, 8), textcolor = color.white, size = f_lsize(i_lblSize), textalign = text.align_center)
                f_archiveLbl(blab)
            if prevLoPct >= lo and not na(prevLoTop) and not na(prevLoBot) and prevLoTop > prevLoBot
                float us = f_wickStr(prevLoPct)
                color uc = color.new(i_bullPress, f_pressTransp(us))
                ubox = box.new(pxL, prevLoTop, pxR, prevLoBot, xloc = xloc.bar_time, bgcolor = uc, border_color = color.new(i_bullPress, 25), border_width = 1)
                f_archivePress(ubox)
                ulab = label.new(int((pxL + pxR) / 2), prevLoBot, "▲ BUY PRESSURE  " + f_stars(us) + " " + str.tostring(us, "#.0") + "/10", xloc = xloc.bar_time, style = label.style_label_up, color = color.new(i_bullPress, 8), textcolor = color.white, size = f_lsize(i_lblSize), textalign = text.align_center)
                f_archiveLbl(ulab)

        if i_showFvg and fvgValid and not na(fvgTop) and not na(fvgBot) and fvgTop > fvgBot
            int   fxL = curStartT
            int   fxR = curStartT + f_slotMs(curSlot) * i_fvgExtend
            float fMid = (fvgTop + fvgBot) / 2.0
            float fH = (i_fvgNormAtr > 0 and not na(fvgAtr) and fvgAtr > 0) ? fvgAtr * i_fvgNormAtr : (fvgTop - fvgBot)
            float fTop = fMid + fH / 2.0
            float fBot = fMid - fH / 2.0
            color fcol = fvgBull ? i_fvgBull : i_fvgBear
            color fbg  = color.new(fcol, i_pressTransp)
            fbox = box.new(fxL, fTop, fxR, fBot, xloc = xloc.bar_time, bgcolor = fbg, border_color = color.new(fcol, 20), border_width = 1)
            f_archiveFvg(fbox)
            int fMidX = int((fxL + fxR) / 2)
            flab = label.new(fMidX, fMid, "Fair Value Gap", xloc = xloc.bar_time, style = label.style_none, textcolor = color.white, size = f_lsize(i_lblSize), textalign = text.align_center)
            f_archiveLbl(flab)

    if inDay and curSlot >= 0 and slotIdx == curSlot
        curHi    := math.max(curHi, high)
        curLo    := math.min(curLo, low)
        curClose := close

    if inDay and curSlot >= 0 and not na(curHi) and not na(curLo) and (curHi - curLo) > 0 and not na(curStartT)
        float boxH  = curHi - curLo
        float volSc = f_volScore(curSlot)
        color vcol  = na(volSc) ? color.gray : f_volCol(volSc)
        int   xL    = curStartT
        int   xR    = curStartT + f_slotMs(curSlot)

        if na(liveBox)
            liveBox := box.new(xL, curHi, xR, curLo, xloc = xloc.bar_time, bgcolor = color.new(vcol, i_transp), border_color = color.new(vcol, 40), border_width = 1)
        else
            box.set_top(liveBox, curHi)
            box.set_bottom(liveBox, curLo)
            box.set_bgcolor(liveBox, color.new(vcol, i_transp))
            box.set_border_color(liveBox, color.new(vcol, 40))

        if i_showGuides
            if array.size(liveGuides) == 0
                for k = 0 to 5
                    float yy = curLo + boxH * (k / 5.0)
                    ln = line.new(xL, yy, xR, yy, xloc = xloc.bar_time, color = color.new(i_guideCol, 25), width = 1, style = (k == 0 or k == 5) ? line.style_solid : line.style_dashed)
                    array.push(liveGuides, ln)
                    if i_showPct
                        lp = label.new(xR, yy, str.tostring(k * 20) + "%", xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(C_LBL, 20), size = f_lsize(i_pctSize), textalign = text.align_left)
                        array.push(livePctLbl, lp)
            else
                for k = 0 to 5
                    float yy = curLo + boxH * (k / 5.0)
                    ln = array.get(liveGuides, k)
                    line.set_y1(ln, yy)
                    line.set_y2(ln, yy)
                    if i_showPct and array.size(livePctLbl) > k
                        lp = array.get(livePctLbl, k)
                        label.set_y(lp, yy)

        if i_showVolLbl
            string vtxt = na(volSc) ? "· vol —" : f_stars(volSc) + "  " + str.tostring(volSc, "#.0") + "/10  " + f_tier(volSc)
            color  vlc  = na(volSc) ? color.new(color.gray, 30) : color.new(vcol, 12)
            if na(liveVolLbl)
                liveVolLbl := label.new(xL, curHi, vtxt, xloc = xloc.bar_time, style = label.style_label_down, color = vlc, textcolor = color.white, size = f_lsize(i_lblSize), textalign = text.align_center)
            else
                label.set_y(liveVolLbl, curHi)
                label.set_text(liveVolLbl, vtxt)
                label.set_color(liveVolLbl, vlc)

plot(slotIdx, "Slot Index", display = display.data_window)
plot(inDay and curSlot >= 0 ? f_volScore(curSlot) : na, "Slot Vol Rank (30d profile)", display = display.data_window)
````
