<!-- tradingview-pine-id: PUB;939a921836294916b90e25a5d29194db -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# DivHK_Core

Source: https://www.tradingview.com/script/TdI0kbdg/

## Description

Library  "DivHK_Core"

get_p(f, idx)
  Parameters:
    f (array<float>)
    idx (int)

calc_pct(pool)
  Parameters:
    pool (array<float>)

pct_push(pool, val, maxsz)
  Parameters:
    pool (array<float>)
    val (float)
    maxsz (int)

current_pct_est(val, frozen)
  Parameters:
    val (float)
    frozen (array<float>)

reversal_tick_rev(val, frozen, st, sf)
  Parameters:
    val (float)
    frozen (array<float>)
    st (int)
    sf (int)

reversal_tick_rev_inv(val, frozen, st, sf)
  Parameters:
    val (float)
    frozen (array<float>)
    st (int)
    sf (int)

reversal_tick_score(val, st, sf, b_long_1, b_long_2, b_long_3, b_short_1, b_short_2, b_short_3)
  Parameters:
    val (float)
    st (int)
    sf (int)
    b_long_1 (float)
    b_long_2 (float)
    b_long_3 (float)
    b_short_1 (float)
    b_short_2 (float)
    b_short_3 (float)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © S-Schmidt
//@version=6

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  DivHK_Core  —  Kern-Logik für das Dividenden Handelssystem HK             ║
// ║  Library v1 · Perzentil-Berechnungen + State Machine                        ║
// ║                                                                              ║
// ║  Enthält:                                                                    ║
// ║    get_p()                — Sicherer Array-Zugriff (float[9])               ║
// ║    calc_pct()             — 9 Perzentil-Stufen aus Pool berechnen            ║
// ║    pct_push()             — Rolling Pool update (Score-Indikatoren)          ║
// ║    current_pct_est()      — Aktuellen Perzentil-Rang interpolieren           ║
// ║    reversal_tick_rev()    — State Machine für Reversal-Indikatoren           ║
// ║                             (KGV / DivR / Kurs, frozen array extern)         ║
// ║    reversal_tick_score()  — State Machine für Score-Indikatoren              ║
// ║                             (D/W/M, 6 Rückgabewerte inkl. deep signals)     ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

library("DivHK_Core", overlay=false)

// ──────────────────────────────────────────────────────────────────────────────
// get_p
// Sicherer Zugriff auf frozen float[9] Array
// ──────────────────────────────────────────────────────────────────────────────
export get_p(float[] f, int idx) =>
    // @param f    — Frozen-Array (float[9], Index 0=P0.01 … 8=P99.99)
    // @param idx  — Ziel-Index (0–8)
    // @returns    — Wert an idx oder na bei ungültigem Array
    array.size(f) >= 9 ? array.get(f, idx) : na

// ──────────────────────────────────────────────────────────────────────────────
// calc_pct
// 9 Perzentil-Stufen aus einem Pool-Array berechnen
// Gibt float[9] zurück: [P0.01, P1, P10, P25, P50, P75, P90, P99, P99.99]
// ──────────────────────────────────────────────────────────────────────────────
export calc_pct(float[] pool) =>
    // @param pool  — Rohdaten-Array (beliebige Größe, min. 2 Elemente empfohlen)
    // @returns     — float[9] mit den 9 Perzentil-Schwellen
    float[] result = array.new_float(9, na)
    if array.size(pool) >= 2
        array.set(result, 0, array.percentile_nearest_rank(pool, 0.01))
        array.set(result, 1, array.percentile_nearest_rank(pool, 1.0))
        array.set(result, 2, array.percentile_nearest_rank(pool, 10.0))
        array.set(result, 3, array.percentile_nearest_rank(pool, 25.0))
        array.set(result, 4, array.percentile_nearest_rank(pool, 50.0))
        array.set(result, 5, array.percentile_nearest_rank(pool, 75.0))
        array.set(result, 6, array.percentile_nearest_rank(pool, 90.0))
        array.set(result, 7, array.percentile_nearest_rank(pool, 99.0))
        array.set(result, 8, array.percentile_nearest_rank(pool, 99.99))
    result

// ──────────────────────────────────────────────────────────────────────────────
// pct_push
// Rolling Pool-Update für Score-Indikatoren (begrenzt auf maxsz Einträge)
// ──────────────────────────────────────────────────────────────────────────────
export pct_push(float[] pool, float val, int maxsz) =>
    // @param pool   — Ziel-Pool (wird in-place verändert)
    // @param val    — Neuer Wert (na wird ignoriert)
    // @param maxsz  — Max. Pool-Größe (wird auf 5000 gedeckelt)
    // @returns      — void
    if not na(val)
        int cap = math.min(maxsz, 5000)
        array.push(pool, val)
        if array.size(pool) > cap
            array.shift(pool)

// ──────────────────────────────────────────────────────────────────────────────
// current_pct_est
// Interpoliert aktuellen Perzentil-Rang eines Werts im frozen Array
// Gibt Wert in 0.0–100.0 zurück (linear interpoliert zwischen Stufen)
// ──────────────────────────────────────────────────────────────────────────────
export current_pct_est(float val, float[] frozen) =>
    // @param val     — Aktueller Metrik-Wert
    // @param frozen  — Frozen float[9] Array (P0.01 … P99.99)
    // @returns       — Geschätzter Perzentil-Rang 0.0–100.0 (na wenn ungültig)
    if na(val) or array.size(frozen) < 9
        float(na)
    else
        float[] pct_levels = array.from(0.01, 1.0, 10.0, 25.0, 50.0, 75.0, 90.0, 99.0, 99.99)
        float p0 = array.get(frozen, 0)
        float p8 = array.get(frozen, 8)
        float result = na
        if val <= p0
            result := 0.0
        else if val >= p8
            result := 100.0
        else
            for i = 0 to 7
                float lo_v = array.get(frozen, i)
                float hi_v = array.get(frozen, i + 1)
                if val >= lo_v and val <= hi_v
                    float lo_p = array.get(pct_levels, i)
                    float hi_p = array.get(pct_levels, i + 1)
                    float range_v = hi_v - lo_v
                    result := range_v != 0.0 ? lo_p + (val - lo_v) / range_v * (hi_p - lo_p) : lo_p
                    break
        result

// ──────────────────────────────────────────────────────────────────────────────
// reversal_tick_rev
// State Machine für Reversal-Indikatoren (KGV · DivR · Kurs)
// Verwendet frozen Array für Bandgrenzen
// Rückgabe: [new_state, new_stufe, sig_long, sig_short]
// ──────────────────────────────────────────────────────────────────────────────
export reversal_tick_rev(float val, float[] frozen, int st, int sf) =>
    // @param val     — Aktueller Metrik-Wert
    // @param frozen  — Frozen float[9] (P0.01…P99.99)
    // @param st      — Aktueller State (0=NEUTRAL · 1=LONG · 2=SHORT)
    // @param sf      — Aktuelle Stufe (0=keine · 1=P10/P90 · 2=P1/P99 · 3=P0.01/P99.99)
    // @returns       — [new_st, new_sf, sig_long, sig_short]
    int   new_st   = st
    int   new_sf   = sf
    bool  sig_l    = false
    bool  sig_s    = false

    if array.size(frozen) >= 9 and not na(val)
        float p10   = array.get(frozen, 2)   // Index 2 = P10
        float p90   = array.get(frozen, 6)   // Index 6 = P90
        float p1    = array.get(frozen, 1)   // Index 1 = P1
        float p99   = array.get(frozen, 7)   // Index 7 = P99
        float p001  = array.get(frozen, 0)   // Index 0 = P0.01
        float p9999 = array.get(frozen, 8)   // Index 8 = P99.99

        // LONG-Zone: val ≤ p10 (niedrige Bewertung = günstig)
        bool in_long_1  = val <= p10
        bool in_long_2  = val <= p1
        bool in_long_3  = val <= p001

        // SHORT-Zone: val ≥ p90 (hohe Bewertung = teuer)
        bool in_short_1 = val >= p90
        bool in_short_2 = val >= p99
        bool in_short_3 = val >= p9999

        if st == 0  // NEUTRAL
            if in_long_3
                new_st := 1
                new_sf := 3
                sig_l  := true
            else if in_long_2
                new_st := 1
                new_sf := 2
                sig_l  := true
            else if in_long_1
                new_st := 1
                new_sf := 1
                sig_l  := true
            else if in_short_3
                new_st := 2
                new_sf := 3
                sig_s  := true
            else if in_short_2
                new_st := 2
                new_sf := 2
                sig_s  := true
            else if in_short_1
                new_st := 2
                new_sf := 1
                sig_s  := true

        else if st == 1  // IN_ZONE_LONG
            if not in_long_1
                new_st := 0
                new_sf := 0
            else
                // Stufen-Upgrade
                if in_long_3 and sf < 3
                    new_sf := 3
                    sig_l  := true
                else if in_long_2 and sf < 2
                    new_sf := 2
                    sig_l  := true

        else if st == 2  // IN_ZONE_SHORT
            if not in_short_1
                new_st := 0
                new_sf := 0
            else
                // Stufen-Upgrade
                if in_short_3 and sf < 3
                    new_sf := 3
                    sig_s  := true
                else if in_short_2 and sf < 2
                    new_sf := 2
                    sig_s  := true

    [new_st, new_sf, sig_l, sig_s]

// ──────────────────────────────────────────────────────────────────────────────
// reversal_tick_rev_inv
// State Machine für DivR_Reversal_System — INVERTIERTE Logik
// Hohe Rendite (hoher Index) = Long-Zone · Niedrige Rendite = Short-Zone
// Rückgabe: [new_state, new_stufe, sig_long, sig_short]
// ──────────────────────────────────────────────────────────────────────────────
export reversal_tick_rev_inv(float val, float[] frozen, int st, int sf) =>
    // @param val     — Aktueller Yield-Wert (%)
    // @param frozen  — Frozen float[9] (P0.01…P99.99 der Yield-Verteilung)
    // @param st      — Aktueller State (0=NEUTRAL · 1=LONG · 2=SHORT)
    // @param sf      — Aktuelle Stufe (0=keine · 1–3)
    // @returns       — [new_st, new_sf, sig_long, sig_short]
    int   new_st   = st
    int   new_sf   = sf
    bool  sig_l    = false
    bool  sig_s    = false

    if array.size(frozen) >= 9 and not na(val)
        float p10   = array.get(frozen, 2)   // P10 Yield
        float p90   = array.get(frozen, 6)   // P90 Yield
        float p1    = array.get(frozen, 1)   // P1 Yield
        float p99   = array.get(frozen, 7)   // P99 Yield
        float p001  = array.get(frozen, 0)   // P0.01 Yield
        float p9999 = array.get(frozen, 8)   // P99.99 Yield

        // LONG-Zone: hohe Rendite = Kurs historisch TIEF
        bool in_long_1  = val > p90
        bool in_long_2  = val > p99
        bool in_long_3  = val > p9999

        // SHORT-Zone: niedrige Rendite = Kurs historisch HOCH
        bool in_short_1 = val < p10
        bool in_short_2 = val < p1
        bool in_short_3 = val < p001

        if st == 0  // NEUTRAL
            if in_long_3
                new_st := 1
                new_sf := 3
                sig_l  := true
            else if in_long_2
                new_st := 1
                new_sf := 2
                sig_l  := true
            else if in_long_1
                new_st := 1
                new_sf := 1
                sig_l  := true
            else if in_short_3
                new_st := 2
                new_sf := 3
                sig_s  := true
            else if in_short_2
                new_st := 2
                new_sf := 2
                sig_s  := true
            else if in_short_1
                new_st := 2
                new_sf := 1
                sig_s  := true

        else if st == 1  // IN_ZONE_LONG (hohe Yield)
            if not in_long_1
                new_st := 0
                new_sf := 0
                sig_l  := true
            else
                if in_long_3 and sf < 3
                    new_sf := 3
                else if in_long_2 and sf < 2
                    new_sf := 2

        else if st == 2  // IN_ZONE_SHORT (niedrige Yield)
            if not in_short_1
                new_st := 0
                new_sf := 0
                sig_s  := true
            else
                if in_short_3 and sf < 3
                    new_sf := 3
                else if in_short_2 and sf < 2
                    new_sf := 2

    [new_st, new_sf, sig_l, sig_s]

// ──────────────────────────────────────────────────────────────────────────────
// reversal_tick_score
// State Machine für Score-Indikatoren (D · W · M)
// Bandgrenzen kommen als Parameter (da kein globaler Kontext in Library)
// Rückgabe: [new_state, new_stufe, sig_long, sig_short, sig_long_deep, sig_short_deep]
// ──────────────────────────────────────────────────────────────────────────────
export reversal_tick_score(float val, int st, int sf,
     float b_long_1, float b_long_2, float b_long_3,
     float b_short_1, float b_short_2, float b_short_3) =>
    // @param val       — Aktueller Score-Wert (Perzentil-Rang 0–100)
    // @param st        — Aktueller State (0=NEUTRAL · 1=LONG · 2=SHORT)
    // @param sf        — Aktuelle Stufe (0=keine · 1–3)
    // @param b_long_1  — Untere Grenze Stufe 1 (z.B. P10  = 10.0)
    // @param b_long_2  — Untere Grenze Stufe 2 (z.B. P1   =  1.0)
    // @param b_long_3  — Untere Grenze Stufe 3 (z.B. P0.01 = 0.01)
    // @param b_short_1 — Obere Grenze Stufe 1  (z.B. P90  = 90.0)
    // @param b_short_2 — Obere Grenze Stufe 2  (z.B. P99  = 99.0)
    // @param b_short_3 — Obere Grenze Stufe 3  (z.B. P99.99 = 99.99)
    // @returns         — [new_st, new_sf, sig_l, sig_s, sig_l_deep, sig_s_deep]
    int  new_st     = st
    int  new_sf     = sf
    bool sig_l      = false
    bool sig_s      = false
    bool sig_l_deep = false
    bool sig_s_deep = false

    if not na(val)
        bool in_long_1  = val <= b_long_1
        bool in_long_2  = val <= b_long_2
        bool in_long_3  = val <= b_long_3
        bool in_short_1 = val >= b_short_1
        bool in_short_2 = val >= b_short_2
        bool in_short_3 = val >= b_short_3

        if st == 0  // NEUTRAL
            if in_long_3
                new_st     := 1
                new_sf     := 3
                sig_l      := true
                sig_l_deep := true
            else if in_long_2
                new_st := 1
                new_sf := 2
                sig_l  := true
            else if in_long_1
                new_st := 1
                new_sf := 1
                sig_l  := true
            else if in_short_3
                new_st     := 2
                new_sf     := 3
                sig_s      := true
                sig_s_deep := true
            else if in_short_2
                new_st := 2
                new_sf := 2
                sig_s  := true
            else if in_short_1
                new_st := 2
                new_sf := 1
                sig_s  := true

        else if st == 1  // IN_ZONE_LONG
            if not in_long_1
                new_st := 0
                new_sf := 0
            else
                if in_long_3 and sf < 3
                    new_sf     := 3
                    sig_l      := true
                    sig_l_deep := true
                else if in_long_2 and sf < 2
                    new_sf := 2
                    sig_l  := true

        else if st == 2  // IN_ZONE_SHORT
            if not in_short_1
                new_st := 0
                new_sf := 0
            else
                if in_short_3 and sf < 3
                    new_sf     := 3
                    sig_s      := true
                    sig_s_deep := true
                else if in_short_2 and sf < 2
                    new_sf := 2
                    sig_s  := true

    [new_st, new_sf, sig_l, sig_s, sig_l_deep, sig_s_deep]
````
