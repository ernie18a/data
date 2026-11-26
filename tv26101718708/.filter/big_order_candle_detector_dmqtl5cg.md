# Big Order Candle Detector

- url: https://www.tradingview.com/script/DmQTL5cg-Big-Order-Candle-Detector/
- type: indicator
- pine_id: PUB;daa72b711abf4df19c83da78130dd682
- version: 8.0

## Description

[b]Big Order Candle Detector (BOCD) – Explanation & Usage[/b]

The Big Order Candle Detector (BOCD) is an indicator designed to identify potential large institutional order activity in the market. It focuses on detecting strong price displacement, which may signal the early stage of a trend.

This structure allows the indicator to capture moments where price moves aggressively, often without overlap with previous price ranges. Such behavior can indicate the presence of strong buying or selling pressure.

[b]How Big Order is Detected[/b]

A Bullish Big Order is identified when the current candle’s low is higher than the high of Candle A. This indicates a clear gap or displacement upward, suggesting strong buying interest.

A Bearish Big Order, on the other hand, occurs when the current candle’s high is lower than the low of Candle A, reflecting strong downward pressure.

To reduce noise, the script only marks the first Big Order signal when multiple signals appear consecutively. This ensures cleaner and more meaningful signals.

[b]Visual Representation on Chart[/b]

The indicator provides several visual elements to assist analysis:

[b]Triangle Signals[/b]
Green triangle → Bullish Big Order
Red triangle → Bearish Big Order
→ Represents early momentum or possible trend initiation

[b]Highlighted Candle (Orange)[/b]
→ Considered the origin of the move or liquidity zone

[b]Support & Resistance Box[/b]
Drawn based on the high and low of Candle A
→ Acts as a reaction zone for future price movement

[b]Strategy & How to Use[/b]

This indicator is best used as a supporting tool for price action analysis, not as a standalone trading signal.

[b]BUY Scenario (Bullish Setup)[/b]

When a bullish Big Order appears, it suggests that strong buying momentum has entered the market. Instead of entering immediately, traders typically wait for price to retrace.

[b]Approach:[/b]
Wait for price to pull back into the support box, Look for confirmation signals before entering

[i]Confirmation Examples:[/i]
Bullish candlestick pattern (e.g., engulfing, pin bar)
Minor break of structure
Increase in volume
Trade Plan:
Entry: Inside the support box (after confirmation)
Take Profit: Nearest resistance zone or previous high
Stop Loss: Below the support box

[b]SELL Scenario (Bearish Setup)[/b]

In a bearish setup, the indicator signals strong selling pressure. Similar to the bullish case, traders wait for a retracement rather than chasing the move.

[b]Approach:[/b]
Wait for price to move back into the resistance box, Look for signs of rejection

[i]Confirmation Examples:[/i]
Bearish rejection candle
Formation of lower high
Weak bullish momentum
Trade Plan:
Entry: Inside the resistance box (after confirmation)
Take Profit: Nearest support zone
Stop Loss: Above the resistance box

[b]Key Concept Summary[/b]
Big Order = Strong displacement (possible institutional activity)
Triangle = Signal of momentum
Orange Candle = Origin zone
Box = Key support/resistance area
Retracement = Entry opportunity
Confirmation = Risk control

[b]Important Considerations[/b]
This indicator:
[list]
[*]Does not guarantee winning trades
[*]Should not be used alone
[*]Always combine with:
[*]Risk management
[*]Market structure analysis
[*]Additional confirmation tools
[/list]

[b]In practice, BOCD works best as:[/b]

A decision-support tool to identify high-probability zones, rather than a direct buy/sell system.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// © Hampeh

//@version=6
indicator("Big Order Candle Detector", shorttitle="BOCD", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =====================================================================
// NOTA PRESTASI (kenapa skrip ini ringan)
// ---------------------------------------------------------------------
// 1) HANYA 2 panggilan request.security (dulu 6). Trend, aras BO dan masa
//    tutup candle bagi satu timeframe kini diambil SEKALI GUS dalam satu
//    panggilan gabungan — bukan tiga panggilan berasingan per timeframe.
//    Setiap request.security ialah satu permintaan data berasingan, jadi
//    inilah penjimatan masa-muat yang paling besar.
// 2) Blok FIFO dan blok paparan dinamik hanya berjalan bila senarai box
//    BERUBAH (ada box baru / box mati / box dipadam) — bukan setiap bar.
//    Dulu dua blok ni mengimbas keseluruhan senarai pada SETIAP bar.
// 3) array.size() dikira sekali di luar gelung, bukan pada setiap lelaran.
// 4) Label hanya digerakkan untuk box yang BETUL-BETUL DIPAPAR. Label box
//    tersorok memang lutsinar, jadi menggerakkannya sia-sia.
// =====================================================================

// ================= INPUT =================
showBullish = input.bool(true, "Show Bullish BigO")
showBearish = input.bool(true, "Show Bearish BigO")
showLabel   = input.bool(false, "Show BigO Triangle")

bullColor   = input.color(color.lime, "Bullish Line Color")
bearColor   = input.color(color.red, "Bearish Line Color")
borderColor = input.color(color.orange, "Candle Before BigO Color")

maxActiveBox    = input.int(100, "Max Active Box (Per Direction)", minval=1, maxval=200, tooltip="Maximum number of RECENT boxes (active + closed combined) kept on the chart, counted SEPARATELY per direction.\n\nPERFORMANCE NOTE: this is the single biggest factor affecting speed. A value of 100 means up to 200 boxes, 400 lines and 400 labels are managed. Lower it to 10-20 if the chart feels heavy — the view stays almost identical, because Dynamic Display only ever shows one box per direction.")
showBuyBox      = input.bool(true, "Show Buy Box")
showSellBox     = input.bool(true, "Show Sell Box")
boxBorderWidth  = input.int(2, "Box Top/Bottom Line Width", minval=1, maxval=5)
seriesBoxMode   = input.string("First", "Box On Consecutive BigO", options=["All", "Latest", "First"], tooltip="Controls which box is kept when BigO signals occur CONSECUTIVELY in one series (same direction):\n\nAll = keep every box in the series.\nLatest = keep only the LAST box of the series — each time the series continues, the previous box in that same series is deleted and replaced.\nFirst (default) = keep only the FIRST box of the series — a box is created on the first BigO only, and continuations are ignored.\n\nA series is counted by direction: bullish followed by bullish, or bearish followed by bearish. A change of direction starts a new series.")
dynamicDisplay  = input.bool(true, "Dynamic Display (One Box Per Direction)", tooltip="ON (default) = only ONE box is shown per direction — the most recent one that is not yet invalidated. All others are hidden.\n\nOFF = show EVERY box that exists, including invalidated ones. Useful for checking whether a box on a particular candle was actually created.")
boxFallbackMode = input.string("Track All Simultaneously", "Box Fallback On Invalidation", options=["Reset On Takeover", "Track All Simultaneously"], tooltip="Controls how OLDER boxes are evaluated when the displayed box is invalidated (close breaks through both sides):\n\nReset On Takeover = only the box CURRENTLY DISPLAYED is tracked. When it is invalidated, the previous box takes over and its break flags are RESET — it is re-evaluated from the takeover bar onward, so past price action does not consume it in the background.\n\nTrack All Simultaneously (default) = every box is tracked at all times, even while hidden. An older box that price has already broken through counts as invalidated and is skipped.")
showBoxPriceLabel = input.bool(true, "Show Box High/Low Price Label")
boxLabelSize      = input.string("Normal", "Box Price Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"])
labelForwardBars  = input.int(10, "Price Label Forward Offset (Bars)", minval=0, maxval=100, tooltip="Price labels are point objects and cannot 'extend' like lines, so they are pushed this many bars forward — into the empty space on the right of the chart — to sit closer to the screen edge, in line with the box and lines that already extend fully.")

// ================= GARISAN BO (BREAK-OUT LEVEL) =================
// SATU ray bagi setiap timeframe, pada aras yang DIPECAH, bermula pada
// candle HH/LL yang membentuk aras tu dan memanjang ke KANAN sahaja.
//   WARNA = jenis break -> break HH = KUNING, break LL = BIRU
//   GAYA  = timeframe   -> TF = SOLID, HTF = DASH, HTF2 = DOTTED
showBOLineTF   = input.bool(true, "Show BO Line (Current TF)", tooltip="Most recent BO break level on the chart timeframe. Line style: SOLID.")
showBOLineHTF  = input.bool(true, "Show BO Line (HTF)", tooltip="Most recent BO break level on the HTF — the paired higher timeframe of the chart. Line style: DASHED.")
showBOLineHTF2 = input.bool(true, "Show BO Line (HTF2)", tooltip="Most recent BO break level on HTF2 — the paired higher timeframe of the HTF. Line style: DOTTED.")

hhLineColor = input.color(color.yellow, "BO Line Color (Break HH)")
llLineColor = input.color(color.blue, "BO Line Color (Break LL)")
boLineWidth = input.int(1, "BO Line Width", minval=1, maxval=5)

buyBoxBgColor     = input.color(color.new(color.lime, 80), "Buy Box Background Color")
buyBoxBorderColor = input.color(color.lime, "Buy Box Border Color")

sellBoxBgColor    = input.color(color.new(color.red, 80), "Sell Box Background Color")
sellBoxBorderColor = input.color(color.red, "Sell Box Border Color")

// ================= SUPERTREND (TIMEFRAME CHART SEMASA) =================
showSupertrend  = input.bool(false, "Show Supertrend", tooltip="OFF by default. Supertrend is a visual overlay only — it is not used by the box, trend or alert logic.")
stFactor        = input.float(4.5, "Supertrend Factor (ATR Multiplier)", minval=0.1, maxval=20.0, step=0.1, tooltip="ATR multiplier — sets how far the Supertrend line sits from price.\n\nHIGHER = line further away, fewer flips, less whipsaw, but slower to react.\nLOWER = more responsive but more false signals.\n\nDefault 4.5 — chosen after comparing settings on XAUUSD M1, where the common 3.0 broke strong trends into many segments. Industry standard: 3.0 (better suited to use as a trailing stop than as a direction filter).")
stAtrPeriod     = input.int(14, "Supertrend ATR Period", minval=1, maxval=200, tooltip="Number of bars used for the ATR calculation. Default 14 (smoother, fewer flips). Industry standard: 10.")
stUpColor       = input.color(color.lime, "Supertrend Color (Uptrend)")
stDownColor     = input.color(color.red, "Supertrend Color (Downtrend)")
stLineWidth     = input.int(2, "Supertrend Line Width", minval=1, maxval=5)

// ================= WARNA TREND & TABLE =================
breakoutBuyColor  = input.color(color.lime, "HTF Trend Color (Uptrend / Buy)")
breakoutSellColor = input.color(color.red, "HTF Trend Color (Downtrend / Sell)")

showTrendTable    = input.bool(true, "Show HTF Trend Table")
trendTablePos     = input.string("Top Right", "Trend Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
trendTableSize    = input.string("Normal", "Trend Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

// ---- Alert: harga MASUK SEMULA ke garisan BO (retest) ----
// AMARAN PENTING (had TradingView, bukan had skrip ini):
// TradingView menyimpan SALINAN semua setting indikator pada masa alert
// dicipta. Menukar mana-mana toggle di bawah TIDAK memberi kesan kepada alert
// yang sedang berjalan. Selepas menukar setting alert, PADAM alert tu di
// TradingView dan CIPTA SEMULA. Amalan terbaik: laraskan semua setting
// DAHULU, baru cipta alert.
alertRetestTF   = input.bool(true, "Alert On BO Line Retest (Current TF)", tooltip="IMPORTANT — AFTER CHANGING ANY ALERT SETTING, DELETE THE ALERT IN TRADINGVIEW AND CREATE IT AGAIN.\nTradingView stores a copy of the indicator settings at the moment an alert is created. Changing this toggle does NOT affect an alert that is already running — the old alert keeps firing until it is deleted and recreated.\n\nFires when price comes back and touches the BO line of the chart timeframe.\n\nExample: after a HH break (uptrend) the line sits BELOW price. When price falls back and touches it, the alert fires — without waiting for the candle to close.\n\nTo create the alert: click the clock icon > select the 'Big Order Candle Detector' indicator > choose 'Any alert() function call'.")
alertRetestHTF  = input.bool(true, "Alert On BO Line Retest (HTF)", tooltip="IMPORTANT — AFTER CHANGING ANY ALERT SETTING, DELETE THE ALERT IN TRADINGVIEW AND CREATE IT AGAIN. Alert settings are frozen at the moment the alert is created, so changing this toggle has no effect on an alert that is already running.\n\nFires when price comes back and touches the BO line of the HTF.")
alertRetestHTF2 = input.bool(true, "Alert On BO Line Retest (HTF2)", tooltip="IMPORTANT — AFTER CHANGING ANY ALERT SETTING, DELETE THE ALERT IN TRADINGVIEW AND CREATE IT AGAIN. Alert settings are frozen at the moment the alert is created, so changing this toggle has no effect on an alert that is already running.\n\nFires when price comes back and touches the BO line of HTF2.")

// Tukar pilihan saiz label (string) kepada pemalar size.* yang Pine perlukan
labelSizeValue = boxLabelSize == "Auto" ? size.auto : boxLabelSize == "Tiny" ? size.tiny : boxLabelSize == "Small" ? size.small : boxLabelSize == "Normal" ? size.normal : boxLabelSize == "Large" ? size.large : size.huge

// Warna sorok: color.new(_, 100) — BUKAN na. `na` tak boleh dipercayai untuk
// sorokkan objek SEDIA ADA (label khususnya masih boleh tersangkut kelihatan).
hiddenColor = color.new(color.white, 100)

// ================= TYPES =================
type BigOBoxParts
    box   bg
    line  topLine
    line  bottomLine
    label topLabel
    label bottomLabel
    float top
    float bottom
    bool  alive
    bool  topBroken
    bool  bottomBroken
    bool  isBuy
    int   createdBar
    bool  shown

// =====================================================================
// FUNGSI
// =====================================================================

// ---- Keadaan satu timeframe: TREND + ARAS BO + MASA TUTUP CANDLE ----
// GABUNGAN: dulu ini tiga panggilan request.security berasingan bagi setiap
// timeframe (trend, aras BO, time_close). Sekarang semuanya dikira dalam
// SATU fungsi dan dipulangkan sebagai satu tuple — jadi satu panggilan
// security sahaja per timeframe.
//
// Dua set aras disimpan dengan SENGAJA, kerana kelakuannya berbeza:
//   • hhT/llT (trend) — TIDAK dikosongkan selepas break. Trend ialah status
//     kekal; mengosongkan aras di sini akan mengubah kelakuan sedia ada.
//   • hhB/llB (garisan BO) — DIKOSONGKAN selepas break, supaya aras yang
//     sama tidak mencetuskan break berulang pada setiap bar seterusnya.
//
// Takrif aras (sama untuk kedua-duanya):
//   HH = Close candle bullish yang diikuti candle bearish
//   LL = Close candle bearish yang diikuti candle bullish
//
// bu/be diisytihar di SKOP LUAR blok `if` — kalau di dalam blok yang tak
// dijalankan setiap bar, rujukan sejarah bu[1]/be[1] tidak boleh dipercayai.
f_tfState() =>
    var float  hhT     = na
    var float  llT     = na
    var string trend   = "N/A"
    var float  hhB     = na
    var float  llB     = na
    var int    hhBTime = na
    var int    llBTime = na
    var float  boLevel = na
    var bool   boIsHH  = false
    var int    boTime  = na

    bu = close > open
    be = close < open

    if barstate.isconfirmed
        if bu[1] and be
            hhT     := close[1]
            hhB     := close[1]
            hhBTime := time[1]
        if be[1] and bu
            llT     := close[1]
            llB     := close[1]
            llBTime := time[1]

        // Trend — aras kekal (tidak dikosongkan)
        if not na(hhT) and close > hhT
            trend := "UPTREND"
        if not na(llT) and close < llT
            trend := "DOWNTREND"

        // Garisan BO — aras dikosongkan selepas dipecah
        if not na(hhB) and close > hhB
            boLevel := hhB
            boTime  := hhBTime
            boIsHH  := true
            hhB     := na
        if not na(llB) and close < llB
            boLevel := llB
            boTime  := llBTime
            boIsHH  := false
            llB     := na

    [trend, boLevel, boIsHH, boTime, time_close]

// ---- Pasangan timeframe ----
// M1->M15, M5->M30, M15->H1, M30->H4, H1->D1, H4->W1, D1->MN
f_pairTF(string tf) =>
    na(tf)       ? na    :
     tf == "1"   ? "15"  :
     tf == "5"   ? "30"  :
     tf == "15"  ? "60"  :
     tf == "30"  ? "240" :
     tf == "60"  ? "D"   :
     tf == "240" ? "W"   :
     tf == "D"   ? "M"   : na

f_tfLabel(string tf) =>
    na(tf)        ? "N/A" :
     tf == "1"    ? "M1"  :
     tf == "3"    ? "M3"  :
     tf == "5"    ? "M5"  :
     tf == "15"   ? "M15" :
     tf == "30"   ? "M30" :
     tf == "45"   ? "M45" :
     tf == "60"   ? "H1"  :
     tf == "120"  ? "H2"  :
     tf == "180"  ? "H3"  :
     tf == "240"  ? "H4"  :
     tf == "D"    ? "D1"  :
     tf == "W"    ? "W1"  :
     tf == "M"    ? "MN"  : tf

// ---- Urus SATU ray aras (cipta / kemaskini / padam) ----
// Titik mula diberi sebagai CAP MASA + xloc.bar_time, supaya aras dari
// HTF/HTF2 jatuh pada candle yang betul pada chart semasa.
// Guna blok `if` satu-cabang (bukan if/else) dan akhiri dengan `ln`:
// if/else akan menyebabkan ralat ketaksepadanan jenis pulangan.
f_levelLine(float lvl, int startTime, bool show, color col, int width, string lineStyle) =>
    var line ln = na
    bool ok = show and not na(lvl) and not na(startTime)
    int x2 = startTime + 1 > time ? startTime + 1 : time

    if ok and na(ln)
        ln := line.new(startTime, lvl, x2, lvl, xloc=xloc.bar_time, color=col, width=width, style=lineStyle, extend=extend.right)

    if ok and not na(ln)
        line.set_xy1(ln, startTime, lvl)
        line.set_xy2(ln, x2, lvl)
        line.set_color(ln, col)
        line.set_width(ln, width)
        line.set_style(ln, lineStyle)

    if not ok and not na(ln)
        line.delete(ln)
        ln := na

    ln

// ---- Kesan harga MASUK SEMULA ke garisan BO (retest) ----
// Selepas break HH, harga DI ATAS aras -> masuk semula bila low <= aras.
// Selepas break LL, harga DI BAWAH aras -> masuk semula bila high >= aras.
// Guna high/low (BUKAN close) supaya mencetus tanpa menunggu candle tutup.
//   • armedLvl/armedBar dipasang semula setiap kali ada aras break BARU
//   • fired ditanda selepas sentuhan pertama -> senyap sehingga break baru
//   • bar_index > armedBar menghalang cetusan palsu pada bar break sendiri
f_boRetest(float lvl, bool isHH) =>
    var float armedLvl = na
    var int   armedBar = na
    var bool  fired    = true
    bool trig = false

    if not na(lvl) and (na(armedLvl) or lvl != armedLvl)
        armedLvl := lvl
        armedBar := bar_index
        fired    := false

    if not na(armedLvl) and not fired and bar_index > armedBar
        bool touched = isHH ? low <= armedLvl : high >= armedLvl
        if touched
            trig  := true
            fired := true
    trig

f_rangeText(float lo, float hi) =>
    na(lo) or na(hi) ? "-" : str.tostring(lo, format.mintick) + " : " + str.tostring(hi, format.mintick)

// Format baki masa (contoh "13m 52s" / "1h 23m 45s" / "2d 05h 10m")
f_fmtRemain(float ms) =>
    string res = "-"
    if not na(ms)
        int totalSec = int(math.max(0, math.floor(ms / 1000)))
        int dd  = int(math.floor(totalSec / 86400))
        int hh  = int(math.floor((totalSec % 86400) / 3600))
        int mm  = int(math.floor((totalSec % 3600) / 60))
        int ss  = totalSec % 60
        res := dd > 0 ? str.format("{0}d {1,number,00}h {2,number,00}m", dd, hh, mm) :
               hh > 0 ? str.format("{0}h {1,number,00}m {2,number,00}s", hh, mm, ss) :
               str.format("{0}m {1,number,00}s", mm, ss)
    res

// =====================================================================
// LOGIK BIG ORDER
// =====================================================================
// Struktur 3 candle: A = candle[2], BigO = candle[1], B = candle[0]
bullishBigO = showBullish and low > high[2]
bearishBigO = showBearish and high < low[2]
bigOSignal  = bullishBigO or bearishBigO

markCandleBeforeBigO = barstate.isconfirmed and bigOSignal

var BigOBoxParts[] bigOBoxes = array.new<BigOBoxParts>()

// Bendera "senarai box berubah". Blok FIFO dan paparan dinamik hanya perlu
// berjalan bila ini true — bukan pada setiap bar. Inilah penjimatan terbesar
// selepas pengurangan panggilan security.
var bool boxesDirty = false

barcolor(markCandleBeforeBigO ? borderColor : na, offset=-2)

// ================= EXTEND / BEKUKAN KOTAK AKTIF =================
// Semakan PECAH hanya pada bar CONFIRMED, guna CLOSE (body) — wick yang
// menusuk aras tapi tutup semula di dalam box TIDAK membatalkan box.
// topBroken/bottomBroken dijejak berasingan & kumulatif; box dibekukan
// hanya bila KEDUA-DUA sisi pernah ditutup melepasi.
//
// Box/garis guna extend.right, jadi ia sambung sendiri ke tepi skrin —
// tiada kemaskini kedudukan diperlukan setiap bar. Hanya label (objek
// titik) perlu digerakkan, dan itu pun HANYA untuk box yang dipapar.
boxCount = array.size(bigOBoxes)
if boxCount > 0
    extIdx = 0
    while extIdx < boxCount
        parts = array.get(bigOBoxes, extIdx)
        if parts.alive
            trackThisBox = boxFallbackMode == "Track All Simultaneously" or parts.shown

            if barstate.isconfirmed and trackThisBox
                if close > parts.top
                    parts.topBroken := true
                if close < parts.bottom
                    parts.bottomBroken := true

                if parts.topBroken and parts.bottomBroken
                    parts.alive := false
                    boxesDirty  := true
                    // Baru pecah — hentikan extend, bekukan di bar ini
                    box.set_extend(parts.bg, extend.none)
                    line.set_extend(parts.topLine, extend.none)
                    line.set_extend(parts.bottomLine, extend.none)
                    box.set_right(parts.bg, bar_index)
                    line.set_x2(parts.topLine, bar_index)
                    line.set_x2(parts.bottomLine, bar_index)
                    if not na(parts.topLabel)
                        label.set_x(parts.topLabel, bar_index)
                    if not na(parts.bottomLabel)
                        label.set_x(parts.bottomLabel, bar_index)

            // Label hanya digerakkan untuk box yang DIPAPAR — label box
            // tersorok lutsinar, jadi menggerakkannya membazir masa.
            if parts.alive and (parts.shown or not dynamicDisplay)
                if not na(parts.topLabel)
                    label.set_x(parts.topLabel, bar_index + labelForwardBars)
                if not na(parts.bottomLabel)
                    label.set_x(parts.bottomLabel, bar_index + labelForwardBars)
        extIdx += 1

showCurrentBox = (bullishBigO and showBuyBox) or (bearishBigO and showSellBox)

// Satu "siri" = BigO berturutan dengan ARAH YANG SAMA
bigOSeriesContinues = (bullishBigO and bullishBigO[1]) or (bearishBigO and bearishBigO[1])
allowCreateBox      = seriesBoxMode == "First" ? not bigOSeriesContinues : true

// ================= CIPTA BOX =================
if markCandleBeforeBigO and showCurrentBox and allowCreateBox
    // Mod "Latest": padam box bar sebelum ini dalam siri yang sama.
    // createdBar + arah disemak supaya tak tersalah padam box lain.
    if seriesBoxMode == "Latest" and bigOSeriesContinues and array.size(bigOBoxes) > 0
        lastIdx = array.size(bigOBoxes) - 1
        lp = array.get(bigOBoxes, lastIdx)
        if lp.createdBar == bar_index - 1 and lp.isBuy == bullishBigO
            box.delete(lp.bg)
            line.delete(lp.topLine)
            line.delete(lp.bottomLine)
            label.delete(lp.topLabel)
            label.delete(lp.bottomLabel)
            array.remove(bigOBoxes, lastIdx)

    boxLeft   = bar_index[2]
    boxRight  = bar_index
    boxTop    = high[2]
    boxBottom = low[2]

    boxLineColor    = bullishBigO ? buyBoxBorderColor : sellBoxBorderColor
    boxBgColorFinal = bullishBigO ? buyBoxBgColor : sellBoxBgColor

    newBg = box.new(left=boxLeft, top=boxTop, right=boxRight, bottom=boxBottom, bgcolor=boxBgColorFinal, border_width=0, extend=extend.right)
    newTopLine    = line.new(x1=boxLeft, y1=boxTop,    x2=boxRight, y2=boxTop,    color=boxLineColor, width=boxBorderWidth, extend=extend.right)
    newBottomLine = line.new(x1=boxLeft, y1=boxBottom, x2=boxRight, y2=boxBottom, color=boxLineColor, width=boxBorderWidth, extend=extend.right)

    newTopLabel    = showBoxPriceLabel ? label.new(x=boxRight, y=boxTop,    text=str.tostring(boxTop, format.mintick),    style=label.style_none, textcolor=boxLineColor, size=labelSizeValue) : na
    newBottomLabel = showBoxPriceLabel ? label.new(x=boxRight, y=boxBottom, text=str.tostring(boxBottom, format.mintick), style=label.style_none, textcolor=boxLineColor, size=labelSizeValue) : na

    // Bendera pecah dimulakan ikut GAP yang membentuk box ni. Candle BigO
    // berada sepenuhnya di luar julat anchor, jadi satu sisi memang dah
    // ditutup melepasi. Ini WAJIB kerana blok semakan pecah berjalan SEBELUM
    // blok cipta box — candle BigO itu sendiri takkan pernah disemak.
    // Kesannya: box SELL batal bila close naik melepasi TOP; box BUY batal
    // bila close turun melepasi BOTTOM.
    newParts = BigOBoxParts.new(bg=newBg, topLine=newTopLine, bottomLine=newBottomLine, topLabel=newTopLabel, bottomLabel=newBottomLabel, top=boxTop, bottom=boxBottom, alive=true, topBroken=bullishBigO, bottomBroken=bearishBigO, isBuy=bullishBigO, createdBar=bar_index, shown=false)
    array.push(bigOBoxes, newParts)
    boxesDirty := true

// ================= HAD FIFO IKUT ARAH =================
// Hanya berjalan bila senarai berubah — bilangan box hanya boleh MENINGKAT
// bila box baru dicipta, jadi mengimbas setiap bar memang tak perlu.
if boxesDirty
    nFifo = array.size(bigOBoxes)
    buyTotal  = 0
    sellTotal = 0
    totalIdx  = 0
    while totalIdx < nFifo
        tcp = array.get(bigOBoxes, totalIdx)
        if tcp.isBuy
            buyTotal += 1
        else
            sellTotal += 1
        totalIdx += 1

    fifoBuyIdx = 0
    while buyTotal > maxActiveBox and fifoBuyIdx < array.size(bigOBoxes)
        fb = array.get(bigOBoxes, fifoBuyIdx)
        if fb.isBuy
            box.delete(fb.bg)
            line.delete(fb.topLine)
            line.delete(fb.bottomLine)
            label.delete(fb.topLabel)
            label.delete(fb.bottomLabel)
            array.remove(bigOBoxes, fifoBuyIdx)
            buyTotal -= 1
        else
            fifoBuyIdx += 1

    fifoSellIdx = 0
    while sellTotal > maxActiveBox and fifoSellIdx < array.size(bigOBoxes)
        fs = array.get(bigOBoxes, fifoSellIdx)
        if not fs.isBuy
            box.delete(fs.bg)
            line.delete(fs.topLine)
            line.delete(fs.bottomLine)
            label.delete(fs.topLabel)
            label.delete(fs.bottomLabel)
            array.remove(bigOBoxes, fifoSellIdx)
            sellTotal -= 1
        else
            fifoSellIdx += 1

// ================= PAPARAN DINAMIK =================
// Hanya SATU box dipapar bagi setiap arah — yang paling terkini & masih
// terbuka. Kalau ia batal, paparan berundur ke box sebelumnya, dan
// seterusnya. Box lain disorok tapi kekal dijejak di latar belakang.
//
// Blok ini hanya berjalan bila senarai box BERUBAH. Keterlihatan tak boleh
// berubah tanpa ada box baru, box mati, atau box dipadam — jadi mengimbas
// keseluruhan senarai pada setiap bar memang membazir.
var float curBuyTop     = na
var float curBuyBottom  = na
var float curSellTop    = na
var float curSellBottom = na

if boxesDirty
    nVis = array.size(bigOBoxes)
    currentBuyIdx  = -1
    currentSellIdx = -1
    scanIdx = nVis - 1
    while scanIdx >= 0
        sp = array.get(bigOBoxes, scanIdx)
        if sp.alive
            if sp.isBuy and currentBuyIdx == -1
                currentBuyIdx := scanIdx
            if not sp.isBuy and currentSellIdx == -1
                currentSellIdx := scanIdx
        scanIdx -= 1

    curBuyTop     := na
    curBuyBottom  := na
    curSellTop    := na
    curSellBottom := na
    if currentBuyIdx >= 0
        cbp = array.get(bigOBoxes, currentBuyIdx)
        curBuyTop    := cbp.top
        curBuyBottom := cbp.bottom
    if currentSellIdx >= 0
        csp = array.get(bigOBoxes, currentSellIdx)
        curSellTop    := csp.top
        curSellBottom := csp.bottom

    visIdx = 0
    while visIdx < nVis
        vp = array.get(bigOBoxes, visIdx)
        isCurrent = not dynamicDisplay or (vp.isBuy and visIdx == currentBuyIdx) or (not vp.isBuy and visIdx == currentSellIdx)

        // AMBIL ALIH: dalam mod "Reset On Takeover", bendera pecah
        // dipulihkan ke KEADAAN ASAL box tu (sisi gap kekal terpecah).
        if isCurrent and not vp.shown and boxFallbackMode == "Reset On Takeover"
            vp.topBroken    := vp.isBuy
            vp.bottomBroken := not vp.isBuy

        vp.shown := isCurrent

        if isCurrent
            vpLineColor = vp.isBuy ? buyBoxBorderColor : sellBoxBorderColor
            vpBgColor   = vp.isBuy ? buyBoxBgColor : sellBoxBgColor
            box.set_bgcolor(vp.bg, vpBgColor)
            line.set_color(vp.topLine, vpLineColor)
            line.set_color(vp.bottomLine, vpLineColor)
            if not na(vp.topLabel)
                label.set_textcolor(vp.topLabel, vpLineColor)
                // Box ini baru ambil alih paparan — selaraskan label terus,
                // kerana blok EXTEND melangkau label box yang tersorok.
                if vp.alive
                    label.set_x(vp.topLabel, bar_index + labelForwardBars)
            if not na(vp.bottomLabel)
                label.set_textcolor(vp.bottomLabel, vpLineColor)
                if vp.alive
                    label.set_x(vp.bottomLabel, bar_index + labelForwardBars)
        else
            box.set_bgcolor(vp.bg, hiddenColor)
            line.set_color(vp.topLine, hiddenColor)
            line.set_color(vp.bottomLine, hiddenColor)
            if not na(vp.topLabel)
                label.set_textcolor(vp.topLabel, hiddenColor)
            if not na(vp.bottomLabel)
                label.set_textcolor(vp.bottomLabel, hiddenColor)
        visIdx += 1

    boxesDirty := false

// ================= TRIANGLE =================
plotshape(bullishBigO and barstate.isconfirmed and showLabel, title="Bullish BigO Triangle", style=shape.triangleup,   location=location.belowbar, color=bullColor, size=size.small, offset=-1)
plotshape(bearishBigO and barstate.isconfirmed and showLabel, title="Bearish BigO Triangle", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, offset=-1)

// ================= SUPERTREND =================
// AWAS konvensyen tanda arah (berlawanan dengan intuisi):
//   stDir < 0 -> UPTREND (garis DI BAWAH harga)
//   stDir > 0 -> DOWNTREND (garis DI ATAS harga)
// Dua plot berasingan + style_linebr supaya garis TERPUTUS pada titik flip,
// bukan melukis lonjakan menegak merentasi harga.
[stValue, stDir] = ta.supertrend(stFactor, stAtrPeriod)

plot(showSupertrend and stDir < 0 ? stValue : na, title="Supertrend (Uptrend)",   color=stUpColor,   linewidth=stLineWidth, style=plot.style_linebr)
plot(showSupertrend and stDir > 0 ? stValue : na, title="Supertrend (Downtrend)", color=stDownColor, linewidth=stLineWidth, style=plot.style_linebr)

// =====================================================================
// KEADAAN MULTI-TIMEFRAME — HANYA 2 PANGGILAN SECURITY
// =====================================================================
breakoutTF  = f_pairTF(timeframe.period)
breakoutTF2 = f_pairTF(breakoutTF)

breakoutTFLabel  = f_tfLabel(breakoutTF)
breakoutTF2Label = f_tfLabel(breakoutTF2)
currentTFLabel   = f_tfLabel(timeframe.period)

// TF semasa — dikira terus, tiada security langsung
[curTFTrendText, tfBOLevel, tfBOIsHH, tfBOTime, _tfClose] = f_tfState()

// Pine tak benarkan tuple di dalam ternary, jadi timeframe "selamat"
// digunakan untuk panggilan security (elak hantar `na` sebagai timeframe),
// kemudian hasilnya dibatalkan kepada na/"N/A" kalau tiada pasangan sebenar.
htfTFSafe  = na(breakoutTF)  ? timeframe.period : breakoutTF
htf2TFSafe = na(breakoutTF2) ? timeframe.period : breakoutTF2

[htfTrendRaw,  htfBORaw,  htfBOIsHHRaw,  htfBOTimeRaw,  htfCloseRaw]  = request.security(syminfo.tickerid, htfTFSafe,  f_tfState(), lookahead=barmerge.lookahead_off)
[htf2TrendRaw, htf2BORaw, htf2BOIsHHRaw, htf2BOTimeRaw, htf2CloseRaw] = request.security(syminfo.tickerid, htf2TFSafe, f_tfState(), lookahead=barmerge.lookahead_off)

htfValid  = not na(breakoutTF)
htf2Valid = not na(breakoutTF2)

htfTrendText  = htfValid  ? htfTrendRaw  : "N/A"
htf2TrendText = htf2Valid ? htf2TrendRaw : "N/A"

htfBOLevel  = htfValid  ? htfBORaw  : na
htf2BOLevel = htf2Valid ? htf2BORaw : na
htfBOTime   = htfValid  ? htfBOTimeRaw  : na
htf2BOTime  = htf2Valid ? htf2BOTimeRaw : na
htfBOIsHH   = htfBOIsHHRaw
htf2BOIsHH  = htf2BOIsHHRaw

htfTimeClose  = htfValid  ? htfCloseRaw  : na
htf2TimeClose = htf2Valid ? htf2CloseRaw : na

htfTrendColor   = htfTrendText   == "UPTREND" ? breakoutBuyColor : htfTrendText   == "DOWNTREND" ? breakoutSellColor : color.gray
htf2TrendColor  = htf2TrendText  == "UPTREND" ? breakoutBuyColor : htf2TrendText  == "DOWNTREND" ? breakoutSellColor : color.gray
curTFTrendColor = curTFTrendText == "UPTREND" ? breakoutBuyColor : curTFTrendText == "DOWNTREND" ? breakoutSellColor : color.gray

// ================= GARISAN BO =================
// WARNA = jenis break (HH kuning / LL biru); GAYA = timeframe
tfBOColor   = tfBOIsHH   ? hhLineColor : llLineColor
htfBOColor  = htfBOIsHH  ? hhLineColor : llLineColor
htf2BOColor = htf2BOIsHH ? hhLineColor : llLineColor

f_levelLine(tfBOLevel,   tfBOTime,   showBOLineTF,   tfBOColor,   boLineWidth, line.style_solid)
f_levelLine(htfBOLevel,  htfBOTime,  showBOLineHTF,  htfBOColor,  boLineWidth, line.style_dashed)
f_levelLine(htf2BOLevel, htf2BOTime, showBOLineHTF2, htf2BOColor, boLineWidth, line.style_dotted)

// ================= TABLE =================
// Teks table hanya dibina pada bar TERAKHIR. Dulu str.format/str.tostring
// dijalankan pada setiap bar walaupun table cuma dilukis sekali.
trendTablePosValue = trendTablePos == "Top Right" ? position.top_right : trendTablePos == "Top Left" ? position.top_left : trendTablePos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table htfTrendTable = table.new(trendTablePosValue, 2, 5, border_width=1, border_color=color.new(color.black, 50))

if showTrendTable and barstate.islast
    trendTableSizeValue = trendTableSize == "Tiny" ? size.tiny : trendTableSize == "Small" ? size.small : trendTableSize == "Normal" ? size.normal : trendTableSize == "Large" ? size.large : size.huge

    htfRemainText  = na(htfTimeClose)  ? "-" : f_fmtRemain(htfTimeClose  - timenow)
    htf2RemainText = na(htf2TimeClose) ? "-" : f_fmtRemain(htf2TimeClose - timenow)
    curTFRemainText = na(time_close) ? "-" : f_fmtRemain(time_close - timenow)

    table.cell(htfTrendTable, 0, 0, "HTF2 (" + breakoutTF2Label + ")", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=trendTableSizeValue)
    table.cell(htfTrendTable, 1, 0, htf2TrendText + " (" + htf2RemainText + ")", text_color=color.white, bgcolor=color.new(htf2TrendColor, 20), text_size=trendTableSizeValue)

    table.cell(htfTrendTable, 0, 1, "HTF (" + breakoutTFLabel + ")", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=trendTableSizeValue)
    table.cell(htfTrendTable, 1, 1, htfTrendText + " (" + htfRemainText + ")", text_color=color.white, bgcolor=color.new(htfTrendColor, 20), text_size=trendTableSizeValue)

    table.cell(htfTrendTable, 0, 2, "TF (" + currentTFLabel + ")", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=trendTableSizeValue)
    table.cell(htfTrendTable, 1, 2, curTFTrendText + " (" + curTFRemainText + ")", text_color=color.white, bgcolor=color.new(curTFTrendColor, 20), text_size=trendTableSizeValue)

    table.cell(htfTrendTable, 0, 3, "BO BUY", text_color=color.white, bgcolor=color.new(buyBoxBorderColor, 20), text_size=trendTableSizeValue)
    table.cell(htfTrendTable, 1, 3, f_rangeText(curBuyBottom, curBuyTop), text_color=color.white, bgcolor=color.new(buyBoxBorderColor, 40), text_size=trendTableSizeValue)

    table.cell(htfTrendTable, 0, 4, "BO SELL", text_color=color.white, bgcolor=color.new(sellBoxBorderColor, 20), text_size=trendTableSizeValue)
    table.cell(htfTrendTable, 1, 4, f_rangeText(curSellBottom, curSellTop), text_color=color.white, bgcolor=color.new(sellBoxBorderColor, 40), text_size=trendTableSizeValue)

// ================= ALERT: MASUK SEMULA KE GARISAN BO =================
// Mencetus sebaik sahaja harga menyentuh semula aras break — tidak menunggu
// candle tutup. alert.freq_once_per_bar (bukan once_per_bar_close) supaya ia
// boleh keluar DALAM bar berjalan, tapi tetap sekali sahaja setiap bar.
//
// AMARAN: toggle alert di INPUT tidak boleh menghentikan alert yang SEDANG
// BERJALAN. Setting dibekukan pada masa alert dicipta — PADAM dan CIPTA
// SEMULA alert selepas menukar toggle.
tfRetest   = f_boRetest(tfBOLevel,   tfBOIsHH)
htfRetest  = f_boRetest(htfBOLevel,  htfBOIsHH)
htf2Retest = f_boRetest(htf2BOLevel, htf2BOIsHH)

f_retestMsg(string tfName, bool isHH, float lvl) =>
    "BOCD | " + syminfo.ticker + " (" + timeframe.period + ")" +
     " | Price retested BO line " + tfName +
     " | Break " + (isHH ? "HH" : "LL") +
     " | Level: " + str.tostring(lvl, format.mintick) +
     " | Price: " + str.tostring(close, format.mintick)

if alertRetestTF and tfRetest
    alert(f_retestMsg("TF " + currentTFLabel, tfBOIsHH, tfBOLevel), alert.freq_once_per_bar)

if alertRetestHTF and htfRetest
    alert(f_retestMsg("HTF " + breakoutTFLabel, htfBOIsHH, htfBOLevel), alert.freq_once_per_bar)

if alertRetestHTF2 and htf2Retest
    alert(f_retestMsg("HTF2 " + breakoutTF2Label, htf2BOIsHH, htf2BOLevel), alert.freq_once_per_bar)
````
