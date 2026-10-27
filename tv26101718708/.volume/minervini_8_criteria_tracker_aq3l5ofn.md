# Minervini 8 Criteria Tracker

- url: https://www.tradingview.com/script/Aq3L5OFN-Minervini-8-Criteria-Tracker/
- type: indicator
- pine_id: PUB;36047390e7774d61a43bf8a646f791be
- version: 4.0

## Description

Minervini 8 Criteria Tracker

Track the last 6 day of Minervini Criteria Qualification
Timeframe daily

## Source Code

````pine
// ============================================================
// MINERVINI 8 CRITERIA TRACKER — TradingView Indicator
// Pine Script v5  |  Fixed: no array-of-arrays
// ============================================================
// Tabel 8 kriteria SEPA Mark Minervini, 6 hari terakhir.
// Gunakan timeframe DAILY (1D).
// ============================================================

//@version=5
indicator("Minervini 8 Criteria Tracker", "Minervini Criteria Tracker", overlay=true)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────

var GMA = "Moving Average"
ma50_len  = input.int(50,  "MA Cepat",   minval=1, group=GMA)
ma150_len = input.int(150, "MA Menengah",minval=1, group=GMA)
ma200_len = input.int(200, "MA Lambat",  minval=1, group=GMA)
ma200_bars= input.int(21,  "MA200 uptrend min (bar)", minval=3, group=GMA)

var GCR = "Kriteria"
rs_min    = input.float(70, "Min RS Rating C6",      minval=0, maxval=100, group=GCR)
vol_mult  = input.float(1.0,"Volume multiplier C7",  minval=0.1, step=0.1, group=GCR)
pct_low   = input.float(30, "% di atas 52W Low C4",  minval=0, group=GCR)
pct_high  = input.float(25, "% di bawah 52W High C5",minval=0, group=GCR)

var GTB = "Tabel"
tbl_pos   = input.string("top_right","Posisi",
             options=["top_right","top_center","top_left","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group=GTB)
dark      = input.bool(true, "Dark Theme", group=GTB)

// ─────────────────────────────────────────
// WARNA
// ─────────────────────────────────────────

c_bg      = dark ? color.new(#0f1318,0) : color.new(#f0f4f8,0)
c_hdr     = dark ? color.new(#070a0e,0) : color.new(#1a2540,0)
c_lbl     = dark ? color.new(#d0dde8,0) : color.new(#0a0f1a,0)
c_dim     = dark ? color.new(#3a5060,0) : color.new(#8090a0,0)
c_today   = dark ? color.new(#0d1e2e,0) : color.new(#ddeeff,0)
c_thdr    = color.new(#40c4ff,0)

c_pbg = color.new(#002a15,0)  // pass bg
c_pfg = color.new(#00e676,0)  // pass fg
c_fbg = color.new(#2a0606,0)  // fail bg
c_ffg = color.new(#ff4444,0)  // fail fg
c_up  = color.new(#00e676,0)  // changed → pass
c_dn  = color.new(#ff4444,0)  // changed → fail
c_pbg_dim = color.new(#002a15,60)
c_fbg_dim = color.new(#2a0606,60)

c_entry_bg = color.new(#282000,0)
c_entry_fg = color.new(#ffd740,0)
c_exit_bg  = color.new(#280404,0)
c_exit_fg  = color.new(#ff4444,0)
c_watch_bg = color.new(#001828,0)
c_watch_fg = color.new(#40c4ff,0)

// ─────────────────────────────────────────
// FUNGSI KALKULASI 1 KRITERIA, 1 OFFSET
// ─────────────────────────────────────────

// MA200 uptrend check
f_ma200_up(offset) =>
    ma = ta.sma(close, ma200_len)
    ok = true
    for i = 0 to ma200_bars - 1
        if ma[offset + i] <= ma[offset + i + 1]
            ok := false
            break
    ok

// RS estimasi sederhana (tanpa data index eksternal)
// return saham 63 bar → scale ke 0-100
f_rs(offset) =>
    ret = (close[offset] / close[offset + 63] - 1.0) * 100.0
    math.min(100.0, math.max(0.0, 50.0 + ret * 1.2))

// Kembalikan 1 bool: apakah kriteria ke-ci terpenuhi pada offset hari lalu
f_crit(ci, offset) =>
    ma50  = ta.sma(close, ma50_len) [offset]
    ma150 = ta.sma(close, ma150_len)[offset]
    ma200 = ta.sma(close, ma200_len)[offset]
    px    = close [offset]
    vol   = volume[offset]
    vavg  = ta.sma(volume, 50)[offset]
    hi52  = ta.highest(high[offset], 252)
    lo52  = ta.lowest (low [offset], 252)

    bool result = false
    if   ci == 0  // C1: price > MA50, MA150, MA200
        result := px > ma50 and px > ma150 and px > ma200
    else if ci == 1  // C2: MA50 > MA150 > MA200
        result := ma50 > ma150 and ma150 > ma200
    else if ci == 2  // C3: MA200 uptrend
        result := f_ma200_up(offset)
    else if ci == 3  // C4: +30% dari 52W low
        result := px >= lo52 * (1.0 + pct_low / 100.0)
    else if ci == 4  // C5: dalam 25% dari 52W high
        result := px >= hi52 * (1.0 - pct_high / 100.0)
    else if ci == 5  // C6: RS >= threshold
        result := f_rs(offset) >= rs_min
    else if ci == 6  // C7: volume >= avg * mult
        result := vol >= vavg * vol_mult
    else if ci == 7  // C8: price > 1Y lalu & 3M lalu
        result := px > close[offset + 252] and px > close[offset + 63]
    result

// ─────────────────────────────────────────
// BANGUN FLAT ARRAY 48 elemen  [ci*6 + d]
// ci = 0..7 (kriteria), d = 0..5 (hari)
// ─────────────────────────────────────────

// Evaluasi semua 48 nilai di setiap bar (Pine butuh ini di top-level)
// Kita pakai 48 variabel skalar lalu masukkan ke array flat

// Kriteria 0 (C1)
b00=f_crit(0,0) 
b01=f_crit(0,1) 
b02=f_crit(0,2) 
b03=f_crit(0,3) 
b04=f_crit(0,4) 
b05=f_crit(0,5)
// Kriteria 1 (C2)
b10=f_crit(1,0) 
b11=f_crit(1,1) 
b12=f_crit(1,2) 
b13=f_crit(1,3) 
b14=f_crit(1,4) 
b15=f_crit(1,5)
// Kriteria 2 (C3)
b20=f_crit(2,0) 
b21=f_crit(2,1) 
b22=f_crit(2,2) 
b23=f_crit(2,3) 
b24=f_crit(2,4) 
b25=f_crit(2,5)
// Kriteria 3 (C4)
b30=f_crit(3,0) 
b31=f_crit(3,1) 
b32=f_crit(3,2) 
b33=f_crit(3,3) 
b34=f_crit(3,4) 
b35=f_crit(3,5)
// Kriteria 4 (C5)
b40=f_crit(4,0) 
b41=f_crit(4,1) 
b42=f_crit(4,2) 
b43=f_crit(4,3) 
b44=f_crit(4,4) 
b45=f_crit(4,5)
// Kriteria 5 (C6)
b50=f_crit(5,0) 
b51=f_crit(5,1) 
b52=f_crit(5,2) 
b53=f_crit(5,3) 
b54=f_crit(5,4) 
b55=f_crit(5,5)
// Kriteria 6 (C7)
b60=f_crit(6,0) 
b61=f_crit(6,1) 
b62=f_crit(6,2) 
b63=f_crit(6,3) 
b64=f_crit(6,4) 
b65=f_crit(6,5)
// Kriteria 7 (C8)
b70=f_crit(7,0) 
b71=f_crit(7,1) 
b72=f_crit(7,2) 
b73=f_crit(7,3) 
b74=f_crit(7,4) 
b75=f_crit(7,5)

// Flat array bool 48 elemen — index = ci*6 + d
flat = array.from(
     b00,b01,b02,b03,b04,b05,   // C1
     b10,b11,b12,b13,b14,b15,   // C2
     b20,b21,b22,b23,b24,b25,   // C3
     b30,b31,b32,b33,b34,b35,   // C4
     b40,b41,b42,b43,b44,b45,   // C5
     b50,b51,b52,b53,b54,b55,   // C6
     b60,b61,b62,b63,b64,b65,   // C7
     b70,b71,b72,b73,b74,b75)   // C8

// Accessor: apakah kriteria ci pada hari d terpenuhi?
f_get(ci, d) => array.get(flat, ci * 6 + d)

// ─────────────────────────────────────────
// SCORE PER HARI
// ─────────────────────────────────────────

f_score_day(d) =>
    int s = 0
    for ci = 0 to 7
        if f_get(ci, d)
            s += 1
    s

sc0 = f_score_day(0)
sc1 = f_score_day(1)
sc2 = f_score_day(2)
sc3 = f_score_day(3)
sc4 = f_score_day(4)
sc5 = f_score_day(5)

scores = array.from(sc0, sc1, sc2, sc3, sc4, sc5)

// ─────────────────────────────────────────
// HELPER WARNA / TEKS
// ─────────────────────────────────────────

f_score_col(s) =>
    s == 8 ? color.new(#00e676,0) :
     s >= 6 ? color.new(#a8e060,0) :
     s >= 4 ? color.new(#ffd740,0) :
              color.new(#ff5555,0)

f_sig_txt(s) =>
    s == 8 ? "⚡ ENTRY" : s <= 3 ? "⚠  EXIT" : s >= 6 ? "👁 WATCH" : "- TUNGGU"

f_sig_bg(s) =>
    s == 8 ? c_entry_bg : s <= 3 ? c_exit_bg : s >= 6 ? c_watch_bg : c_bg

f_sig_fg(s) =>
    s == 8 ? c_entry_fg : s <= 3 ? c_exit_fg : s >= 6 ? c_watch_fg : c_dim

// ─────────────────────────────────────────
// TABEL  (hanya di bar terakhir)
// ─────────────────────────────────────────
//
// Layout kolom:
//   col 0       = label kriteria
//   col 1..6    = hari D0..D5
//   col 7       = trend 6 hari
//
// Layout baris:
//   row 0       = judul
//   row 1       = header kolom
//   row 2..9    = C1..C8
//   row 10      = sinyal
//   row 11      = skor
//   row 12      = catatan
// ─────────────────────────────────────────

var table tbl = na

if barstate.islast

    pos = switch tbl_pos
        "top_right"    => position.top_right
        "top_center"    => position.top_center
        "top_left"     => position.top_left
        "middle_left"    => position.middle_left
        "middle_center"    => position.middle_center
        "middle_right"    => position.middle_right
        "bottom_left"  => position.bottom_left
        "bottom_center"  => position.bottom_center
        "bottom_right"  => position.bottom_right
        => position.top_right

    tbl := table.new(pos, 8, 13,
         bgcolor      = c_bg,
         border_color = dark ? color.new(#1e2530,0) : color.new(#b0bcc8,0),
         border_width = 1,
         frame_color  = color.new(#2a3a4a,0),
         frame_width  = 2)

    // ── ROW 0 : judul ──
    table.cell(tbl, 0, 0,
         "  ▸ MINERVINI 8 CRITERIA SEPA TRACKER",
         text_color  = c_thdr,
         text_size   = size.small,
         bgcolor     = c_hdr,
         text_halign = text.align_left)
    table.merge_cells(tbl, 0, 0, 7, 0)

    // ── ROW 1 : header kolom ──
    hdr_days = array.from("HARI INI","-1 HARI","-2 HARI","-3 HARI","-4 HARI","-5 HARI")

    table.cell(tbl, 0, 1, "  Kriteria",
         text_color=c_dim, text_size=size.tiny, bgcolor=c_hdr, text_halign=text.align_left)

    for d = 0 to 5
        table.cell(tbl, d+1, 1,
             array.get(hdr_days, d),
             text_color = d==0 ? c_thdr : c_dim,
             text_size  = size.tiny,
             bgcolor    = d==0 ? c_today : c_hdr)

    table.cell(tbl, 7, 1, "TREND 6H",
         text_color=c_dim, text_size=size.tiny, bgcolor=c_hdr)

    // Label kriteria
    labels = array.from(
         "C1  Price > MA50/150/200",
         "C2  MA50 > MA150 > MA200",
         "C3  MA200 Uptrend ≥"+str.tostring(ma200_bars)+"b",
         "C4  Price ≥ +"+str.tostring(pct_low,"#")+"% 52W Low",
         "C5  Price ≤ -"+str.tostring(pct_high,"#")+"% 52W High",
         "C6  RS Rating ≥ "+str.tostring(rs_min,"#"),
         "C7  Volume ≥ "+str.tostring(vol_mult,"#.#")+"× Avg50",
         "C8  Price > 1Y & 3M ago")

    // ── ROW 2-9 : 8 kriteria ──
    for ci = 0 to 7
        // Kolom label
        table.cell(tbl, 0, ci+2,
             "  "+array.get(labels,ci),
             text_color  = c_lbl,
             text_size   = size.tiny,
             bgcolor     = c_bg,
             text_halign = text.align_left)

        // 6 kolom hari
        for d = 0 to 5
            pv   = f_get(ci, d)                         // nilai hari ini
            prev = d < 5 ? f_get(ci, d+1) : pv          // nilai hari sebelumnya

            chg_up = pv  and not prev   // baru PASS
            chg_dn = not pv and prev    // baru FAIL

            arrow  = chg_up ? " ↑" : chg_dn ? " ↓" : ""
            txt    = (pv ? "✓ PASS" : "✗ FAIL") + arrow
            fg     = chg_up ? c_up : chg_dn ? c_dn : pv ? c_pfg : c_ffg
            bg     = d == 0 ? (pv ? c_pbg : c_fbg) : (pv ? c_pbg_dim : c_fbg_dim)

            table.cell(tbl, d+1, ci+2, txt,
                 text_color = fg,
                 text_size  = size.tiny,
                 bgcolor    = bg)

        // Kolom trend: visual bar + hitungan
        int   pc  = 0
        string bar_vis = ""
        for t = 0 to 5
            // tampilkan dari D-5 ke D0 (kiri=lama, kanan=baru)
            pass_t = f_get(ci, 5 - t)
            bar_vis += pass_t ? "█" : "░"
            if pass_t
                pc += 1

        tc = pc >= 5 ? c_pfg : pc >= 3 ? color.new(#ffd740,0) : c_ffg
        table.cell(tbl, 7, ci+2,
             bar_vis+" "+str.tostring(pc)+"/6",
             text_color = tc,
             text_size  = size.tiny,
             bgcolor    = c_bg)

    // ── ROW 10 : sinyal ──
    table.cell(tbl, 0, 10, "  ▸ SINYAL",
         text_color=c_dim, text_size=size.tiny, bgcolor=c_hdr, text_halign=text.align_left)

    for d = 0 to 5
        sc = array.get(scores, d)
        table.cell(tbl, d+1, 10, f_sig_txt(sc),
             text_color = f_sig_fg(sc),
             text_size  = size.tiny,
             bgcolor    = f_sig_bg(sc))

    // Trend sinyal (naik/turun)
    sig_trend     = sc0 > sc1 ? "▲ NAIK" : sc0 < sc1 ? "▼ TURUN" : "= SAMA"
    sig_trend_col = sc0 > sc1 ? c_up     : sc0 < sc1 ? c_dn      : c_dim
    table.cell(tbl, 7, 10, sig_trend,
         text_color=sig_trend_col, text_size=size.tiny, bgcolor=c_hdr)

    // ── ROW 11 : skor ──
    table.cell(tbl, 0, 11, "  ▸ SKOR /8",
         text_color=c_dim, text_size=size.tiny, bgcolor=c_hdr, text_halign=text.align_left)

    for d = 0 to 5
        sc       = array.get(scores, d)
        prev_sc  = d < 5 ? array.get(scores, d+1) : sc
        delta    = sc - prev_sc
        dstr     = delta > 0 ? "(+"+str.tostring(delta)+")" : delta < 0 ? "("+str.tostring(delta)+")" : ""
        lbl      = sc==8 ? "SEMPURNA" : sc>=6 ? "KUAT" : sc>=4 ? "SEDANG" : "LEMAH"

        table.cell(tbl, d+1, 11,
             str.tostring(sc)+"/8 "+dstr+"\n"+lbl,
             text_color = f_score_col(sc),
             text_size  = size.tiny,
             bgcolor    = d==0 ? c_today : c_hdr)

    // Rata-rata
    avg6 = (sc0+sc1+sc2+sc3+sc4+sc5) / 6.0
    table.cell(tbl, 7, 11,
         "AVG\n"+str.tostring(avg6,"#.#")+"/8",
         text_color = f_score_col(math.round(avg6)),
         text_size  = size.tiny,
         bgcolor    = c_hdr)

    // ── ROW 12 : legenda ──
    table.cell(tbl, 0, 12,
         "  ↑=baru pass  ↓=baru fail  █/░=pass/fail  ⚡ENTRY=8/8  ⚠EXIT=≤3/8  👁WATCH=6-7/8",
         text_color  = c_dim,
         text_size   = size.tiny,
         bgcolor     = c_hdr,
         text_halign = text.align_left)
    table.merge_cells(tbl, 0, 12, 7, 12)

// ─────────────────────────────────────────
// PLOT MA (referensi visual di chart)
// ─────────────────────────────────────────

plot(ta.sma(close,ma50_len),  "MA50",  color=color.new(#40c4ff,30), linewidth=1)
plot(ta.sma(close,ma150_len), "MA150", color=color.new(#ffd740,40), linewidth=1)
plot(ta.sma(close,ma200_len), "MA200", color=color.new(#ff6b35,20), linewidth=2)

// ─────────────────────────────────────────
// BACKGROUND & ALERT
// ─────────────────────────────────────────

bgcolor(sc0 == 8 ? color.new(#00e676,93) : na, title="BG Entry 8/8")
bgcolor(sc0 <= 3 ? color.new(#ff4444,93) : na, title="BG Exit ≤3/8")

alertcondition(sc0 == 8,             title="⚡ ENTRY 8/8", message="{{ticker}} — ENTRY: semua 8 kriteria Minervini terpenuhi!")
alertcondition(sc0 >= 7 and sc1 < 7, title="👁 WATCH naik ke 7+", message="{{ticker}} — score Minervini naik ke 7+, pantau entry!")
alertcondition(sc0 <= 3,             title="⚠ EXIT ≤3/8", message="{{ticker}} — EXIT: hanya ≤3/8 kriteria Minervini.")
alertcondition(sc1 - sc0 >= 2,       title="📉 Turun 2+ poin",message="{{ticker}} — score Minervini turun 2+ poin dalam 1 hari.")

//
//alertcondition(sc0 <= 3,             title="⚠ EXIT ≤3/8", message="{{ticker}} — EXIT: hanya "+str.toString(sc0)+"/8 kriteria Minervini.")
//alertcondition(sc1 - sc0 >= 2,       title="📉 Turun 2+ poin",message="{{ticker}} — score Minervini turun "+str.toString(sc1-sc0)+" poin dalam 1 hari.")
````
