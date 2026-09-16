<!-- tradingview-pine-id: PUB;26ed621df6474cb28335eb2fca44d6d0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 204 Haftalik BTC Dongu Haritasi v6

Source: https://www.tradingview.com/script/NvtrGAWm/

## Description

What This Indicator Does

It's a Pine Script overlay for TradingView that visualizes a theorized ~204-week (~4-year) repeating cycle in BTC price history.

Plots: 6 historical dates (Jan 2015, Dec 2017, Dec 2018, Nov 2021, Nov 2022, Oct 2025) marked as alternating lows and highs, plus 3 projected future dates (Oct 2026, Sep 2029, Sep 2030) calculated by continuing the same pattern.

Colors candle backgrounds based on which "phase" of the cycle each period falls into — a subtle teal tint for low→high legs (152 weeks), a subtle red tint for high→low legs (52 weeks). Candle bodies keep their normal green/red — only the background band changes.

How It Works
Fixed timestamps for each anchor date are hardcoded using timestamp().
xloc.bar_time is used instead of bar index, so the lines land on the correct calendar date regardless of chart timeframe (1H, 4H, 1D, 1W all work).
Vertical lines + labels are drawn once, guarded by barstate.isfirst, so they don't redraw on every bar.
A loop checks which pair of consecutive anchor dates the current bar's time falls between, then applies bgcolor() accordingly — solid for confirmed history, dashed gray for the unconfirmed future projections.
Two toggle inputs let you turn the lines and/or the background coloring on/off independently.

Underlying logic: low→high always takes 152 weeks, high→low always takes 52 weeks, alternating — so skipping one point (low to low, or high to high) always equals exactly 204 weeks. That's the "204-week" pattern name.

---

## Source Code

````pine
//@version=6
indicator("204 Haftalik BTC Dongu Haritasi v6", overlay=true, max_lines_count=30, max_labels_count=30)

// ============================================================
// Pine v6 surumu. v5'ten farki:
//   - //@version=6
//   - input.bool() zaten v5'te de namespace'liydi, degismedi
//   - bgcolor() zaten global scope'ta cagriliyor (v6 sart kosuyor)
//   - ta.* fonksiyonu kullanilmadigi icin namespace hatasi riski yok
//
// Gecmis 6 tarihe ek olarak, oruntuye gore hesaplanmis 3 GELECEK
// tarihi de (t7, t8, t9) isaretler -- hepsi tahmin, henuz
// gerceklesmedi, bu yuzden gri + kesikli cizgiyle gosterilir.
//
// Mum ARKA PLANI (bgcolor), hangi "faz"da oldugunuzu gosterir:
//   Teal zemin    = DIP->ZIRVE fazi   (152 hafta, teoriye gore yukselis)
//   Kirmizi zemin = ZIRVE->DIP fazi   (52 hafta,  teoriye gore dusus)
// Mumlarin kendi yesil/kirmizi rengine DOKUNULMAZ, sadece arkasi boyanir.
// ============================================================

showLines = input.bool(true, "Dongu cizgilerini goster")
showPhase = input.bool(true, "Mum arka planini faza gore boya")

// Referans tarihleri (UTC). Ilk 6 tanesi gecmis, son 3 tanesi TAHMIN.
t1 = timestamp("UTC", 2015, 1, 12, 0, 0)   // DIP
t2 = timestamp("UTC", 2017, 12, 11, 0, 0)  // ZIRVE
t3 = timestamp("UTC", 2018, 12, 10, 0, 0)  // DIP
t4 = timestamp("UTC", 2021, 11, 8, 0, 0)   // ZIRVE
t5 = timestamp("UTC", 2022, 11, 7, 0, 0)   // DIP
t6 = timestamp("UTC", 2025, 10, 6, 0, 0)   // ZIRVE (bilinen son nokta)
t7 = timestamp("UTC", 2026, 10, 5, 0, 0)   // DIP?   (tahmin, +52 hf)
t8 = timestamp("UTC", 2029, 9, 3, 0, 0)    // ZIRVE? (tahmin, +152 hf)
t9 = timestamp("UTC", 2030, 9, 2, 0, 0)    // DIP?   (tahmin, +52 hf)

var array<int> anchors = array.from(t1, t2, t3, t4, t5, t6, t7, t8, t9)

// --- 1) Dikey cizgiler ve etiketler (yalniz bir kere cizilir) ---
drawMark(t, txt, isDip, isFuture) =>
    lineCol = isFuture ? color.new(color.gray, 20) : (isDip ? color.new(color.teal, 20) : color.new(color.orange, 20))
    lineSty = isFuture ? line.style_dashed : line.style_solid
    line.new(x1=t, y1=0.0, x2=t, y2=1.0, xloc=xloc.bar_time, extend=extend.both, color=lineCol, style=lineSty, width=1)
    label.new(x=t, y=na, xloc=xloc.bar_time, yloc=isDip ? yloc.belowbar : yloc.abovebar, text=txt, style=isDip ? label.style_label_up : label.style_label_down, color=lineCol, textcolor=color.white, size=size.small)

if showLines and barstate.isfirst
    drawMark(t1, "12 Oca 2015\nDIP", true, false)
    drawMark(t2, "11 Ara 2017\nZIRVE (+152 hf)", false, false)
    drawMark(t3, "10 Ara 2018\nDIP (+52 hf)", true, false)
    drawMark(t4, "8 Kas 2021\nZIRVE (+152 hf)", false, false)
    drawMark(t5, "7 Kas 2022\nDIP (+52 hf)", true, false)
    drawMark(t6, "6 Eki 2025\nZIRVE (+152 hf)", false, false)
    drawMark(t7, "~5 Eki 2026\nDIP? (+52 hf, tahmin)", true, true)
    drawMark(t8, "~3 Eyl 2029\nZIRVE? (+152 hf, tahmin)", false, true)
    drawMark(t9, "~2 Eyl 2030\nDIP? (+52 hf, tahmin)", true, true)

// --- 2) Faza gore mum arka plani (her barda calisir, global scope) ---
phaseColor() =>
    color result = na
    for i = 0 to array.size(anchors) - 2
        a = array.get(anchors, i)
        b = array.get(anchors, i + 1)
        if time >= a and time < b
            result := (i % 2 == 0) ? color.new(color.teal, 85) : color.new(color.red, 85)
    result

bgcolor(showPhase ? phaseColor() : na)
````
