# DAX Flow [AM]

- url: https://www.tradingview.com/script/QcaGoqJD-DAX-Flow-AM/
- type: indicator
- pine_id: PUB;6aea34e2794443e1913ab091eb4973d8
- version: 1.0

## Description

DAX Flow Trio [AM] — A/D Ratio & TRIN
This indicator measures the internal breadth quality of DAX40 price moves using two complementary metrics calculated directly from all 40 XETR components.
Why breadth matters
Price can move up while the majority of stocks decline — driven by a handful of heavyweight names. Breadth indicators expose this divergence and help you avoid entering low-quality moves.
Two lines. One story.
🔵 A/D Ratio (solid line)
Advancing stocks divided by declining stocks across all 40 DAX components.

Above 1.0 → more stocks rising than falling
Below 1.0 → more stocks falling than rising

🔴 TRIN (dashed line) — inverse logic
(Advancing/Declining) divided by (Up Volume/Down Volume).

Below 1.0 → bullish: volume flows into advancing stocks
Above 1.0 → bearish: volume flows into declining stocks

How to use it
When A/D crosses above 1.0 AND TRIN drops below 1.0 simultaneously → breadth confirms the price move. When they diverge → treat the move with caution.
Specs

Built on all 40 XETR components
Designed for 15M timeframe
Session-filtered: active during Xetra hours only (09:00–17:30 CET)
No repainting

Part of the DAX Breadth Toolkit [AM]

## Source Code

````pine
//@version=6
indicator("DAX Flow [AM]", overlay=false, max_bars_back=500)

// ══════════════════════════════════════════════════════════════════
//  DAX FLOW TRIO [AM] v2 — Pine Script v6
//  🔵 A/D Ratio      → solide lijn
//  🟠 Up/Down Volume → gestreept (dashed)
//  🟣 TRIN           → gestippeld (dotted) — INVERSE: <1.0 = bullish
//
//  Geen achtergrondvlakken. Geen tabel.
//  Labels rechts aan elke lijn.
//  Aanbevolen TF: 15M
// ══════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  SETTINGS
// ─────────────────────────────────────────────
smooth  = input.int(3,   "Smoothing (bars)", minval=1, maxval=10)
cap_val = input.float(4.0, "Max cap ratio",  minval=2.0, maxval=10.0, step=0.5)

// ─────────────────────────────────────────────
//  KLEUREN
// ─────────────────────────────────────────────
C_AD  = color.new(#2979ff, 0)   // Blauw  — A/D Ratio
C_UV  = color.new(#ff6d00, 0)   // Oranje — Up/Down Volume
C_TR  = color.new(#aa00ff, 0)   // Paars  — TRIN
C_REF = color.new(#ffffff, 75)  // Wit gedimpt — referentielijnen

// ─────────────────────────────────────────────
//  COMPONENT DATA — alle 40 DAX stocks
// ─────────────────────────────────────────────
[c01,v01] = request.security("XETR:ADS",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c02,v02] = request.security("XETR:AIR",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c03,v03] = request.security("XETR:ALV",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c04,v04] = request.security("XETR:BAS",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c05,v05] = request.security("XETR:BAYN", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c06,v06] = request.security("XETR:BMW",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c07,v07] = request.security("XETR:BEI",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c08,v08] = request.security("XETR:BNR",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c09,v09] = request.security("XETR:CBK",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c10,v10] = request.security("XETR:CON",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c11,v11] = request.security("FWB:1COV",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c13,v13] = request.security("XETR:DB1",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c14,v14] = request.security("XETR:DBK",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c15,v15] = request.security("XETR:DHL",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c16,v16] = request.security("XETR:DTE",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c17,v17] = request.security("XETR:EOAN", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c18,v18] = request.security("XETR:FME",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c19,v19] = request.security("XETR:FRE",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c20,v20] = request.security("XETR:HEN3", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c21,v21] = request.security("XETR:HEI",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c22,v22] = request.security("XETR:HNR1", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c23,v23] = request.security("XETR:IFX",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c24,v24] = request.security("XETR:MBG",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c25,v25] = request.security("XETR:MRK",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c26,v26] = request.security("XETR:MTX",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c27,v27] = request.security("XETR:MUV2", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c28,v28] = request.security("XETR:P911", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c29,v29] = request.security("XETR:PAH3", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c30,v30] = request.security("XETR:QIA",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c31,v31] = request.security("XETR:RHM",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c32,v32] = request.security("XETR:RWE",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c33,v33] = request.security("XETR:SAP",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c34,v34] = request.security("XETR:SRT3", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c35,v35] = request.security("XETR:SIE",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c36,v36] = request.security("XETR:ENR",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c37,v37] = request.security("XETR:SHL",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c38,v38] = request.security("XETR:SY1",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c39,v39] = request.security("XETR:VOW3", timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c40,v40] = request.security("XETR:VNA",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)
[c41,v41] = request.security("XETR:ZAL",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
//  ADVANCING / DECLINING / VOLUMES
// ─────────────────────────────────────────────
adv(c)    => c > c[1] ? 1 : 0
dec(c)    => c < c[1] ? 1 : 0
uvol(c,v) => c > c[1] ? v : 0.0
dvol(c,v) => c < c[1] ? v : 0.0

total_adv =
     adv(c01)+adv(c02)+adv(c03)+adv(c04)+adv(c05)+adv(c06)+adv(c07)+
     adv(c08)+adv(c09)+adv(c10)+adv(c11)+adv(c13)+adv(c14)+adv(c15)+
     adv(c16)+adv(c17)+adv(c18)+adv(c19)+adv(c20)+adv(c21)+adv(c22)+
     adv(c23)+adv(c24)+adv(c25)+adv(c26)+adv(c27)+adv(c28)+adv(c29)+
     adv(c30)+adv(c31)+adv(c32)+adv(c33)+adv(c34)+adv(c35)+adv(c36)+
     adv(c37)+adv(c38)+adv(c39)+adv(c40)+adv(c41)

total_dec =
     dec(c01)+dec(c02)+dec(c03)+dec(c04)+dec(c05)+dec(c06)+dec(c07)+
     dec(c08)+dec(c09)+dec(c10)+dec(c11)+dec(c13)+dec(c14)+dec(c15)+
     dec(c16)+dec(c17)+dec(c18)+dec(c19)+dec(c20)+dec(c21)+dec(c22)+
     dec(c23)+dec(c24)+dec(c25)+dec(c26)+dec(c27)+dec(c28)+dec(c29)+
     dec(c30)+dec(c31)+dec(c32)+dec(c33)+dec(c34)+dec(c35)+dec(c36)+
     dec(c37)+dec(c38)+dec(c39)+dec(c40)+dec(c41)

vol_up =
     uvol(c01,v01)+uvol(c02,v02)+uvol(c03,v03)+uvol(c04,v04)+uvol(c05,v05)+
     uvol(c06,v06)+uvol(c07,v07)+uvol(c08,v08)+uvol(c09,v09)+uvol(c10,v10)+
     uvol(c11,v11)+uvol(c13,v13)+uvol(c14,v14)+uvol(c15,v15)+uvol(c16,v16)+
     uvol(c17,v17)+uvol(c18,v18)+uvol(c19,v19)+uvol(c20,v20)+uvol(c21,v21)+
     uvol(c22,v22)+uvol(c23,v23)+uvol(c24,v24)+uvol(c25,v25)+uvol(c26,v26)+
     uvol(c27,v27)+uvol(c28,v28)+uvol(c29,v29)+uvol(c30,v30)+uvol(c31,v31)+
     uvol(c32,v32)+uvol(c33,v33)+uvol(c34,v34)+uvol(c35,v35)+uvol(c36,v36)+
     uvol(c37,v37)+uvol(c38,v38)+uvol(c39,v39)+uvol(c40,v40)+uvol(c41,v41)

vol_dn =
     dvol(c01,v01)+dvol(c02,v02)+dvol(c03,v03)+dvol(c04,v04)+dvol(c05,v05)+
     dvol(c06,v06)+dvol(c07,v07)+dvol(c08,v08)+dvol(c09,v09)+dvol(c10,v10)+
     dvol(c11,v11)+dvol(c13,v13)+dvol(c14,v14)+dvol(c15,v15)+dvol(c16,v16)+
     dvol(c17,v17)+dvol(c18,v18)+dvol(c19,v19)+dvol(c20,v20)+dvol(c21,v21)+
     dvol(c22,v22)+dvol(c23,v23)+dvol(c24,v24)+dvol(c25,v25)+dvol(c26,v26)+
     dvol(c27,v27)+dvol(c28,v28)+dvol(c29,v29)+dvol(c30,v30)+dvol(c31,v31)+
     dvol(c32,v32)+dvol(c33,v33)+dvol(c34,v34)+dvol(c35,v35)+dvol(c36,v36)+
     dvol(c37,v37)+dvol(c38,v38)+dvol(c39,v39)+dvol(c40,v40)+dvol(c41,v41)

// ─────────────────────────────────────────────
//  RATIO BEREKENINGEN — gecapped
// ─────────────────────────────────────────────

// A/D Ratio
ad_raw   = total_dec > 0 ? total_adv / total_dec : cap_val
ad_ratio = math.min(ad_raw, cap_val)
ad_line  = ta.ema(ad_ratio, smooth)

// Up/Down Volume Ratio
uv_raw   = vol_dn > 0 ? vol_up / vol_dn : cap_val
uv_ratio = math.min(uv_raw, cap_val)
uv_line  = ta.ema(uv_ratio, smooth)

// TRIN — inverse logica: <1.0 = bullish
trin_raw  = (total_dec > 0 and vol_dn > 0 and vol_up > 0) ?
             (total_adv / total_dec) / (vol_up / vol_dn) : 1.0
trin_val  = math.min(math.max(trin_raw, 0.1), cap_val)
trin_line = ta.ema(trin_val, smooth)

// ─────────────────────────────────────────────
//  XETRA SESSIE FILTER — alleen tijdens markturen
// ─────────────────────────────────────────────
in_sess = not na(time(timeframe.period, "0900-1730", "Europe/Berlin"))

ad_plot   = in_sess ? ad_line   : na
uv_plot   = in_sess ? uv_line   : na
trin_plot = in_sess ? trin_line : na

// ─────────────────────────────────────────────
//  REFERENTIELIJNEN
// ─────────────────────────────────────────────
hline(1.0, "1.0", color=color.new(#aaaaaa, 30), linestyle=hline.style_solid,  linewidth=1)
hline(2.0, "2.0", color=C_REF, linestyle=hline.style_dotted, linewidth=1)
hline(0.5, "0.5", color=C_REF, linestyle=hline.style_dotted, linewidth=1)

// ─────────────────────────────────────────────
//  PLOTS — drie lijnstijlen
//  Solid   = A/D Ratio (hoofdlijn)
//  Dashed  = Up/Down Volume (bevestiging)
//  Circles = TRIN (klein, gestippeld effect, inverse)
// ─────────────────────────────────────────────
plot(ad_plot,   "A/D Ratio", color=C_AD, linewidth=2, style=plot.style_line)
plot(trin_plot, "TRIN",      color=C_TR, linewidth=1, style=plot.style_circles)

// ─────────────────────────────────────────────
//  LABELS — rechts aan elke lijn op laatste bar
// ─────────────────────────────────────────────
if barstate.islast and in_sess
    // A/D label
    label.new(bar_index + 1, ad_line,
         text="A/D " + str.tostring(math.round(ad_line, 2)),
         xloc=xloc.bar_index, yloc=yloc.price,
         color=color.new(C_AD, 85), textcolor=C_AD,
         style=label.style_label_left, size=size.small)

    // TRIN label
    label.new(bar_index + 1, trin_line,
         text="TRIN " + str.tostring(math.round(trin_line, 2)),
         xloc=xloc.bar_index, yloc=yloc.price,
         color=color.new(C_TR, 85), textcolor=C_TR,
         style=label.style_label_left, size=size.small)
````
