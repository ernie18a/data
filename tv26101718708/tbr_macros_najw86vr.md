# TBR Macros

- url: https://www.tradingview.com/script/NajW86VR-TBR-Macros/
- type: indicator
- pine_id: PUB;ef4023fdfc5f459eb62539202716c225
- version: 1.0

## Description

This Indicator is completely inspired by ICT_concepts on X(formerly known as twitter). This is a tool to help those who are interested in trading price and liquidity while focusing on time as the ruler. Below serves as a grading of the macros not of their importance but of their purpose and their role.

Tier S: The "Primary Injectors" (Critical Priority)
These are the most important because they coincide with the "Unbinding" of the ADR/ODR ranges into the NY session.

TBR NY 07:30 – 09:00 (Macro 20): * Grade: S+

Role: The Initial Injection. This macro audits the ODR (Overnight Range) and the OVD (Overnight Vertical Displacement). Its role is to determine if the "Ghost" from the overnight session has enough mass to sustain a trend.

Fractal Signature: If this macro sweeps the ODR High/Low and rejects, the daily bias is likely a "Fade."

NY AM 09:50 – 10:10 (Macro 18):

Grade: S

Role: The London Protocol Resolution. This is the classic ICT "Silver Bullet" window. Its role is to deliver price to the first major liquidity pool after the NY Open (144-node shoe start).

TBR NY 08:00 – 08:30 (Macro 21):

Grade: S

Role: The Pre-Open Singularity. It often creates the "Judas Swing" that traps retail traders before the 09:30 open.

Tier A: The "Trend Conductors" (High Priority)
These macros ensure the "Inflation" of the price continues toward the Regular Session targets.

TBR NY 20-40 Series (Macros 22–24: 08:20, 09:20, 10:20):

Grade: A+

Role: Lattice Reinforcement. These are "Harmonic Checkpoints." If price is at the 0.2152 Hinge of the OVD box during the 10:20 macro, the probability of a 27-tick expansion is >80%.

London 01:50 – 02:10 & TBR Lon 02:33 (Macros 9, 14):

Grade: A

Role: ODR Creation. These macros are responsible for "Stirring the Pot" and defining the Overnight Range. They inject the first true volatility into the ADR.

Tier B: The "Distribution & Reversal" Nodes (Medium Priority)
These macros handle the "Residual Pressure" and "Thermal Decay" of the move.

NY PM 13:50 – 14:10 (Macro 31):

Grade: B+

Role: The Hinge Node. As identified in your Node 31 research, this is the "Clock Speed" reversal point. It audits the AM range and decides if the PM session will "Mirror" or "Distribute."

TBR NY PM 15:15 – 15:45 (Macro 35):

Grade: B

Role: The Settlement Sieve. This macro forces price toward the 0.5 Equilibrium of the RDR (Regular Day Range) before the 16:00 close.

Tier C: The "Lattice Vibrations" (Lower Priority)
These macros occur during "Low-Entropy" periods where price is often range-bound.

Asia Hourly Series (Macros 0–8):

Grade: C

Role: Accumulation/Vibration. These macros build the "Mass" of the ADR. While individually less explosive, they collectively set the "Stator Reservoir" (the inhale) for the London expansion.

Strategy: Best used for "Fading the Extremes" of the ADR.

## Source Code

````pine
//@version=6
indicator("TBR Macros", overlay=true, max_boxes_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL
// ─────────────────────────────────────────────────────────────────────────────
var string TZ = "America/New_York"

i_days = input.int(5, "Days Back (1–20)", minval=1, maxval=20, group="General")

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
barH()  => hour(time, TZ)
barM()  => minute(time, TZ)
barHM() => barH() * 60 + barM()

// Updated Helper to handle midnight wrap-around (Midnight Cross Fix)
inWin(startH, startM, endH, endM) =>
    bm      = barHM()
    startT  = startH * 60 + startM
    endT    = endH * 60 + endM
    startT < endT ? (bm >= startT and bm < endT) : (bm >= startT or bm < endT)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (Styling maintained exactly)
// ─────────────────────────────────────────────────────────────────────────────
grp_asia = "──── Asia Hourly Macros ────"
i_asia_col   = input.color(color.new(#9B5DE5, 80), "Asia Color",   group=grp_asia)
i_asia_lblc = input.color(color.new(#9B5DE5,  0), "Asia Label Color", group=grp_asia)
i_a1 = input.bool(true, "16:50 – 17:10", group=grp_asia)
i_a2 = input.bool(true, "17:50 – 18:10", group=grp_asia)
i_a3 = input.bool(true, "18:50 – 19:10", group=grp_asia)
i_a4 = input.bool(true, "19:50 – 20:10", group=grp_asia)
i_a5 = input.bool(true, "20:50 – 21:10", group=grp_asia)
i_a6 = input.bool(true, "21:50 – 22:10", group=grp_asia)
i_a7 = input.bool(true, "22:50 – 23:10", group=grp_asia)
i_a8 = input.bool(true, "23:50 – 00:10", group=grp_asia)
i_a9 = input.bool(true, "00:50 – 01:10", group=grp_asia)

grp_lon = "──── London Hourly Macros ────"
i_lon_col   = input.color(color.new(#00B4D8, 80), "London Color",  group=grp_lon)
i_lon_lblc = input.color(color.new(#00B4D8,  0), "London Label Color", group=grp_lon)
i_l1 = input.bool(true, "01:50 – 02:10", group=grp_lon)
i_l2 = input.bool(true, "02:50 – 03:10", group=grp_lon)
i_l3 = input.bool(true, "03:50 – 04:10", group=grp_lon)
i_l4 = input.bool(true, "04:50 – 05:10", group=grp_lon)
i_l5 = input.bool(true, "05:50 – 06:10", group=grp_lon)
i_tbr_lon = input.bool(true, "TBR London  02:33 – 03:00", group=grp_lon)
i_tbrl_col   = input.color(color.new(#48CAE4, 75), "TBR London Color",  group=grp_lon)
i_tbrl_lblc = input.color(color.new(#48CAE4,  0), "TBR London Label Color", group=grp_lon)

grp_nyam = "──── New York AM Hourly Macros ────"
i_nyam_col   = input.color(color.new(#06D6A0, 80), "NY AM Color",  group=grp_nyam)
i_nyam_lblc = input.color(color.new(#06D6A0,  0), "NY AM Label Color", group=grp_nyam)
i_n1 = input.bool(true, "06:50 – 07:10", group=grp_nyam)
i_n2 = input.bool(true, "07:50 – 08:10", group=grp_nyam)
i_n3 = input.bool(true, "08:50 – 09:10", group=grp_nyam)
i_n4 = input.bool(true, "09:50 – 10:10", group=grp_nyam)
i_n5 = input.bool(true, "10:50 – 11:10", group=grp_nyam)
i_tbr_ny1 = input.bool(true, "TBR NY  07:30 – 09:00", group=grp_nyam)
i_tbr_ny2 = input.bool(true, "TBR NY  08:00 – 08:30", group=grp_nyam)
i_tbrny_col   = input.color(color.new(#F77F00, 75), "TBR NY Color",  group=grp_nyam)
i_tbrny_lblc = input.color(color.new(#F77F00,  0), "TBR NY Label Color", group=grp_nyam)

grp_2040 = "──── TBR NY 20-40 Macros ────"
i_2040_col   = input.color(color.new(#FF6B35, 80), "20-40 Color",  group=grp_2040)
i_2040_lblc = input.color(color.new(#FF6B35,  0), "20-40 Label Color", group=grp_2040)
i_2040_08 = input.bool(true, "08:20 – 08:40", group=grp_2040)
i_2040_09 = input.bool(true, "09:20 – 09:40", group=grp_2040)
i_2040_10 = input.bool(true, "10:20 – 10:40", group=grp_2040)
i_2040_11 = input.bool(true, "11:20 – 11:40", group=grp_2040)
i_2040_12 = input.bool(true, "12:20 – 12:40", group=grp_2040)
i_2040_13 = input.bool(true, "13:20 – 13:40", group=grp_2040)
i_2040_14 = input.bool(true, "14:20 – 14:40", group=grp_2040)

grp_nypm = "──── New York PM Hourly Macros ────"
i_nypm_col   = input.color(color.new(#EF233C, 80), "NY PM Color",  group=grp_nypm)
i_nypm_lblc = input.color(color.new(#EF233C,  0), "NY PM Label Color", group=grp_nypm)
i_p1 = input.bool(true, "11:50 – 12:10", group=grp_nypm)
i_p2 = input.bool(true, "12:50 – 13:10", group=grp_nypm)
i_p3 = input.bool(true, "13:50 – 14:10", group=grp_nypm)
i_p4 = input.bool(true, "14:50 – 15:10", group=grp_nypm)
i_p5 = input.bool(true, "15:50 – 16:10", group=grp_nypm)
i_tbr_nypm1 = input.bool(true, "TBR NY PM  13:10 – 13:40", group=grp_nypm)
i_tbr_nypm2 = input.bool(true, "TBR NY PM  15:15 – 15:45", group=grp_nypm)
i_tbrnypm_col   = input.color(color.new(#F72585, 75), "TBR NY PM Color",  group=grp_nypm)
i_tbrnypm_lblc = input.color(color.new(#F72585,  0), "TBR NY PM Label Color", group=grp_nypm)

// ─────────────────────────────────────────────────────────────────────────────
// STATE MANAGEMENT & ACCUMULATION
// ─────────────────────────────────────────────────────────────────────────────
var float[] m_hi_0  = array.new_float(0), var float[] m_lo_0  = array.new_float(0), var int[] m_l_0  = array.new_int(0), var int[] m_r_0  = array.new_int(0), var float m_whi_0  = na, var float m_wlo_0  = na, var int m_wl_0  = na, var bool m_in_0  = false
var float[] m_hi_1  = array.new_float(0), var float[] m_lo_1  = array.new_float(0), var int[] m_l_1  = array.new_int(0), var int[] m_r_1  = array.new_int(0), var float m_whi_1  = na, var float m_wlo_1  = na, var int m_wl_1  = na, var bool m_in_1  = false
var float[] m_hi_2  = array.new_float(0), var float[] m_lo_2  = array.new_float(0), var int[] m_l_2  = array.new_int(0), var int[] m_r_2  = array.new_int(0), var float m_whi_2  = na, var float m_wlo_2  = na, var int m_wl_2  = na, var bool m_in_2  = false
var float[] m_hi_3  = array.new_float(0), var float[] m_lo_3  = array.new_float(0), var int[] m_l_3  = array.new_int(0), var int[] m_r_3  = array.new_int(0), var float m_whi_3  = na, var float m_wlo_3  = na, var int m_wl_3  = na, var bool m_in_3  = false
var float[] m_hi_4  = array.new_float(0), var float[] m_lo_4  = array.new_float(0), var int[] m_l_4  = array.new_int(0), var int[] m_r_4  = array.new_int(0), var float m_whi_4  = na, var float m_wlo_4  = na, var int m_wl_4  = na, var bool m_in_4  = false
var float[] m_hi_5  = array.new_float(0), var float[] m_lo_5  = array.new_float(0), var int[] m_l_5  = array.new_int(0), var int[] m_r_5  = array.new_int(0), var float m_whi_5  = na, var float m_wlo_5  = na, var int m_wl_5  = na, var bool m_in_5  = false
var float[] m_hi_6  = array.new_float(0), var float[] m_lo_6  = array.new_float(0), var int[] m_l_6  = array.new_int(0), var int[] m_r_6  = array.new_int(0), var float m_whi_6  = na, var float m_wlo_6  = na, var int m_wl_6  = na, var bool m_in_6  = false
var float[] m_hi_7  = array.new_float(0), var float[] m_lo_7  = array.new_float(0), var int[] m_l_7  = array.new_int(0), var int[] m_r_7  = array.new_int(0), var float m_whi_7  = na, var float m_wlo_7  = na, var int m_wl_7  = na, var bool m_in_7  = false
var float[] m_hi_8  = array.new_float(0), var float[] m_lo_8  = array.new_float(0), var int[] m_l_8  = array.new_int(0), var int[] m_r_8  = array.new_int(0), var float m_whi_8  = na, var float m_wlo_8  = na, var int m_wl_8  = na, var bool m_in_8  = false
var float[] m_hi_9  = array.new_float(0), var float[] m_lo_9  = array.new_float(0), var int[] m_l_9  = array.new_int(0), var int[] m_r_9  = array.new_int(0), var float m_whi_9  = na, var float m_wlo_9  = na, var int m_wl_9  = na, var bool m_in_9  = false
var float[] m_hi_10 = array.new_float(0), var float[] m_lo_10 = array.new_float(0), var int[] m_l_10 = array.new_int(0), var int[] m_r_10 = array.new_int(0), var float m_whi_10 = na, var float m_wlo_10 = na, var int m_wl_10 = na, var bool m_in_10 = false
var float[] m_hi_11 = array.new_float(0), var float[] m_lo_11 = array.new_float(0), var int[] m_l_11 = array.new_int(0), var int[] m_r_11 = array.new_int(0), var float m_whi_11 = na, var float m_wlo_11 = na, var int m_wl_11 = na, var bool m_in_11 = false
var float[] m_hi_12 = array.new_float(0), var float[] m_lo_12 = array.new_float(0), var int[] m_l_12 = array.new_int(0), var int[] m_r_12 = array.new_int(0), var float m_whi_12 = na, var float m_wlo_12 = na, var int m_wl_12 = na, var bool m_in_12 = false
var float[] m_hi_13 = array.new_float(0), var float[] m_lo_13 = array.new_float(0), var int[] m_l_13 = array.new_int(0), var int[] m_r_13 = array.new_int(0), var float m_whi_13 = na, var float m_wlo_13 = na, var int m_wl_13 = na, var bool m_in_13 = false
var float[] m_hi_14 = array.new_float(0), var float[] m_lo_14 = array.new_float(0), var int[] m_l_14 = array.new_int(0), var int[] m_r_14 = array.new_int(0), var float m_whi_14 = na, var float m_wlo_14 = na, var int m_wl_14 = na, var bool m_in_14 = false
var float[] m_hi_15 = array.new_float(0), var float[] m_lo_15 = array.new_float(0), var int[] m_l_15 = array.new_int(0), var int[] m_r_15 = array.new_int(0), var float m_whi_15 = na, var float m_wlo_15 = na, var int m_wl_15 = na, var bool m_in_15 = false
var float[] m_hi_16 = array.new_float(0), var float[] m_lo_16 = array.new_float(0), var int[] m_l_16 = array.new_int(0), var int[] m_r_16 = array.new_int(0), var float m_whi_16 = na, var float m_wlo_16 = na, var int m_wl_16 = na, var bool m_in_16 = false
var float[] m_hi_17 = array.new_float(0), var float[] m_lo_17 = array.new_float(0), var int[] m_l_17 = array.new_int(0), var int[] m_r_17 = array.new_int(0), var float m_whi_17 = na, var float m_wlo_17 = na, var int m_wl_17 = na, var bool m_in_17 = false
var float[] m_hi_18 = array.new_float(0), var float[] m_lo_18 = array.new_float(0), var int[] m_l_18 = array.new_int(0), var int[] m_r_18 = array.new_int(0), var float m_whi_18 = na, var float m_wlo_18 = na, var int m_wl_18 = na, var bool m_in_18 = false
var float[] m_hi_19 = array.new_float(0), var float[] m_lo_19 = array.new_float(0), var int[] m_l_19 = array.new_int(0), var int[] m_r_19 = array.new_int(0), var float m_whi_19 = na, var float m_wlo_19 = na, var int m_wl_19 = na, var bool m_in_19 = false
var float[] m_hi_20 = array.new_float(0), var float[] m_lo_20 = array.new_float(0), var int[] m_l_20 = array.new_int(0), var int[] m_r_20 = array.new_int(0), var float m_whi_20 = na, var float m_wlo_20 = na, var int m_wl_20 = na, var bool m_in_20 = false
var float[] m_hi_21 = array.new_float(0), var float[] m_lo_21 = array.new_float(0), var int[] m_l_21 = array.new_int(0), var int[] m_r_21 = array.new_int(0), var float m_whi_21 = na, var float m_wlo_21 = na, var int m_wl_21 = na, var bool m_in_21 = false
var float[] m_hi_22 = array.new_float(0), var float[] m_lo_22 = array.new_float(0), var int[] m_l_22 = array.new_int(0), var int[] m_r_22 = array.new_int(0), var float m_whi_22 = na, var float m_wlo_22 = na, var int m_wl_22 = na, var bool m_in_22 = false
var float[] m_hi_23 = array.new_float(0), var float[] m_lo_23 = array.new_float(0), var int[] m_l_23 = array.new_int(0), var int[] m_r_23 = array.new_int(0), var float m_whi_23 = na, var float m_wlo_23 = na, var int m_wl_23 = na, var bool m_in_23 = false
var float[] m_hi_24 = array.new_float(0), var float[] m_lo_24 = array.new_float(0), var int[] m_l_24 = array.new_int(0), var int[] m_r_24 = array.new_int(0), var float m_whi_24 = na, var float m_wlo_24 = na, var int m_wl_24 = na, var bool m_in_24 = false
var float[] m_hi_25 = array.new_float(0), var float[] m_lo_25 = array.new_float(0), var int[] m_l_25 = array.new_int(0), var int[] m_r_25 = array.new_int(0), var float m_whi_25 = na, var float m_wlo_25 = na, var int m_wl_25 = na, var bool m_in_25 = false
var float[] m_hi_26 = array.new_float(0), var float[] m_lo_26 = array.new_float(0), var int[] m_l_26 = array.new_int(0), var int[] m_r_26 = array.new_int(0), var float m_whi_26 = na, var float m_wlo_26 = na, var int m_wl_26 = na, var bool m_in_26 = false
var float[] m_hi_27 = array.new_float(0), var float[] m_lo_27 = array.new_float(0), var int[] m_l_27 = array.new_int(0), var int[] m_r_27 = array.new_int(0), var float m_whi_27 = na, var float m_wlo_27 = na, var int m_wl_27 = na, var bool m_in_27 = false
var float[] m_hi_28 = array.new_float(0), var float[] m_lo_28 = array.new_float(0), var int[] m_l_28 = array.new_int(0), var int[] m_r_28 = array.new_int(0), var float m_whi_28 = na, var float m_wlo_28 = na, var int m_wl_28 = na, var bool m_in_28 = false
var float[] m_hi_29 = array.new_float(0), var float[] m_lo_29 = array.new_float(0), var int[] m_l_29 = array.new_int(0), var int[] m_r_29 = array.new_int(0), var float m_whi_29 = na, var float m_wlo_29 = na, var int m_wl_29 = na, var bool m_in_29 = false
var float[] m_hi_30 = array.new_float(0), var float[] m_lo_30 = array.new_float(0), var int[] m_l_30 = array.new_int(0), var int[] m_r_30 = array.new_int(0), var float m_whi_30 = na, var float m_wlo_30 = na, var int m_wl_30 = na, var bool m_in_30 = false
var float[] m_hi_31 = array.new_float(0), var float[] m_lo_31 = array.new_float(0), var int[] m_l_31 = array.new_int(0), var int[] m_r_31 = array.new_int(0), var float m_whi_31 = na, var float m_wlo_31 = na, var int m_wl_31 = na, var bool m_in_31 = false
var float[] m_hi_32 = array.new_float(0), var float[] m_lo_32 = array.new_float(0), var int[] m_l_32 = array.new_int(0), var int[] m_r_32 = array.new_int(0), var float m_whi_32 = na, var float m_wlo_32 = na, var int m_wl_32 = na, var bool m_in_32 = false
var float[] m_hi_33 = array.new_float(0), var float[] m_lo_33 = array.new_float(0), var int[] m_l_33 = array.new_int(0), var int[] m_r_33 = array.new_int(0), var float m_whi_33 = na, var float m_wlo_33 = na, var int m_wl_33 = na, var bool m_in_33 = false
var float[] m_hi_34 = array.new_float(0), var float[] m_lo_34 = array.new_float(0), var int[] m_l_34 = array.new_int(0), var int[] m_r_34 = array.new_int(0), var float m_whi_34 = na, var float m_wlo_34 = na, var int m_wl_34 = na, var bool m_in_34 = false
var float[] m_hi_35 = array.new_float(0), var float[] m_lo_35 = array.new_float(0), var int[] m_l_35 = array.new_int(0), var int[] m_r_35 = array.new_int(0), var float m_whi_35 = na, var float m_wlo_35 = na, var int m_wl_35 = na, var bool m_in_35 = false

// Updated accumulate to resolve assignment errors (Tuple Logic Fix)
accumulate(startH, startM, endH, endM, hi_arr, lo_arr, l_arr, r_arr, whi, wlo, wl, in_win) =>
    now = inWin(startH, startM, endH, endM)
    float res_whi = whi
    float res_wlo = wlo
    int   res_wl  = wl
    bool  res_in  = in_win
    
    if now and not in_win
        res_whi := high
        res_wlo := low
        res_wl  := bar_index
        res_in  := true
    else if now
        res_whi := math.max(nz(whi, high), high)
        res_wlo := math.min(nz(wlo, low), low)
    else if not now and in_win
        if not na(whi)
            array.push(hi_arr, whi)
            array.push(lo_arr, wlo)
            array.push(l_arr,  wl)
            array.push(r_arr,  bar_index - 1)
        res_whi := na
        res_wlo := na
        res_in  := false
    [res_whi, res_wlo, res_wl, res_in]

trimArr(hi_arr, lo_arr, l_arr, r_arr, maxD) =>
    while array.size(hi_arr) > maxD
        array.shift(hi_arr)
        array.shift(lo_arr)
        array.shift(l_arr)
        array.shift(r_arr)

// ─────────────────────────────────────────────────────────────────────────────
// EXECUTION FOR ALL 36 MACROS
// ─────────────────────────────────────────────────────────────────────────────
[nw0, nl0, nx0, ni0] = accumulate(16,50,17,10, m_hi_0, m_lo_0, m_l_0, m_r_0, m_whi_0, m_wlo_0, m_wl_0, m_in_0)
m_whi_0 := nw0, m_wlo_0 := nl0, m_wl_0 := nx0, m_in_0 := ni0
[nw1, nl1, nx1, ni1] = accumulate(17,50,18,10, m_hi_1, m_lo_1, m_l_1, m_r_1, m_whi_1, m_wlo_1, m_wl_1, m_in_1)
m_whi_1 := nw1, m_wlo_1 := nl1, m_wl_1 := nx1, m_in_1 := ni1
[nw2, nl2, nx2, ni2] = accumulate(18,50,19,10, m_hi_2, m_lo_2, m_l_2, m_r_2, m_whi_2, m_wlo_2, m_wl_2, m_in_2)
m_whi_2 := nw2, m_wlo_2 := nl2, m_wl_2 := nx2, m_in_2 := ni2
[nw3, nl3, nx3, ni3] = accumulate(19,50,20,10, m_hi_3, m_lo_3, m_l_3, m_r_3, m_whi_3, m_wlo_3, m_wl_3, m_in_3)
m_whi_3 := nw3, m_wlo_3 := nl3, m_wl_3 := nx3, m_in_3 := ni3
[nw4, nl4, nx4, ni4] = accumulate(20,50,21,10, m_hi_4, m_lo_4, m_l_4, m_r_4, m_whi_4, m_wlo_4, m_wl_4, m_in_4)
m_whi_4 := nw4, m_wlo_4 := nl4, m_wl_4 := nx4, m_in_4 := ni4
[nw5, nl5, nx5, ni5] = accumulate(21,50,22,10, m_hi_5, m_lo_5, m_l_5, m_r_5, m_whi_5, m_wlo_5, m_wl_5, m_in_5)
m_whi_5 := nw5, m_wlo_5 := nl5, m_wl_5 := nx5, m_in_5 := ni5
[nw6, nl6, nx6, ni6] = accumulate(22,50,23,10, m_hi_6, m_lo_6, m_l_6, m_r_6, m_whi_6, m_wlo_6, m_wl_6, m_in_6)
m_whi_6 := nw6, m_wlo_6 := nl6, m_wl_6 := nx6, m_in_6 := ni6
[nw7, nl7, nx7, ni7] = accumulate(23,50, 0,10, m_hi_7, m_lo_7, m_l_7, m_r_7, m_whi_7, m_wlo_7, m_wl_7, m_in_7)
m_whi_7 := nw7, m_wlo_7 := nl7, m_wl_7 := nx7, m_in_7 := ni7
[nw8, nl8, nx8, ni8] = accumulate( 0,50, 1,10, m_hi_8, m_lo_8, m_l_8, m_r_8, m_whi_8, m_wlo_8, m_wl_8, m_in_8)
m_whi_8 := nw8, m_wlo_8 := nl8, m_wl_8 := nx8, m_in_8 := ni8
[nw9, nl9, nx9, ni9] = accumulate( 1,50, 2,10, m_hi_9, m_lo_9, m_l_9, m_r_9, m_whi_9, m_wlo_9, m_wl_9, m_in_9)
m_whi_9 := nw9, m_wlo_9 := nl9, m_wl_9 := nx9, m_in_9 := ni9
[nw10, nl10, nx10, ni10] = accumulate( 2,50, 3,10, m_hi_10, m_lo_10, m_l_10, m_r_10, m_whi_10, m_wlo_10, m_wl_10, m_in_10)
m_whi_10 := nw10, m_wlo_10 := nl10, m_wl_10 := nx10, m_in_10 := ni10
[nw11, nl11, nx11, ni11] = accumulate( 3,50, 4,10, m_hi_11, m_lo_11, m_l_11, m_r_11, m_whi_11, m_wlo_11, m_wl_11, m_in_11)
m_whi_11 := nw11, m_wlo_11 := nl11, m_wl_11 := nx11, m_in_11 := ni11
[nw12, nl12, nx12, ni12] = accumulate( 4,50, 5,10, m_hi_12, m_lo_12, m_l_12, m_r_12, m_whi_12, m_wlo_12, m_wl_12, m_in_12)
m_whi_12 := nw12, m_wlo_12 := nl12, m_wl_12 := nx12, m_in_12 := ni12
[nw13, nl13, nx13, ni13] = accumulate( 5,50, 6,10, m_hi_13, m_lo_13, m_l_13, m_r_13, m_whi_13, m_wlo_13, m_wl_13, m_in_13)
m_whi_13 := nw13, m_wlo_13 := nl13, m_wl_13 := nx13, m_in_13 := ni13
[nw14, nl14, nx14, ni14] = accumulate( 2,33, 3, 0, m_hi_14, m_lo_14, m_l_14, m_r_14, m_whi_14, m_wlo_14, m_wl_14, m_in_14)
m_whi_14 := nw14, m_wlo_14 := nl14, m_wl_14 := nx14, m_in_14 := ni14
[nw15, nl15, nx15, ni15] = accumulate( 6,50, 7,10, m_hi_15, m_lo_15, m_l_15, m_r_15, m_whi_15, m_wlo_15, m_wl_15, m_in_15)
m_whi_15 := nw15, m_wlo_15 := nl15, m_wl_15 := nx15, m_in_15 := ni15
[nw16, nl16, nx16, ni16] = accumulate( 7,50, 8,10, m_hi_16, m_lo_16, m_l_16, m_r_16, m_whi_16, m_wlo_16, m_wl_16, m_in_16)
m_whi_16 := nw16, m_wlo_16 := nl16, m_wl_16 := nx16, m_in_16 := ni16
[nw17, nl17, nx17, ni17] = accumulate( 8,50, 9,10, m_hi_17, m_lo_17, m_l_17, m_r_17, m_whi_17, m_wlo_17, m_wl_17, m_in_17)
m_whi_17 := nw17, m_wlo_17 := nl17, m_wl_17 := nx17, m_in_17 := ni17
[nw18, nl18, nx18, ni18] = accumulate( 9,50,10,10, m_hi_18, m_lo_18, m_l_18, m_r_18, m_whi_18, m_wlo_18, m_wl_18, m_in_18)
m_whi_18 := nw18, m_wlo_18 := nl18, m_wl_18 := nx18, m_in_18 := ni18
[nw19, nl19, nx19, ni19] = accumulate(10,50,11,10, m_hi_19, m_lo_19, m_l_19, m_r_19, m_whi_19, m_wlo_19, m_wl_19, m_in_19)
m_whi_19 := nw19, m_wlo_19 := nl19, m_wl_19 := nx19, m_in_19 := ni19
[nw20, nl20, nx20, ni20] = accumulate( 7,30, 9, 0, m_hi_20, m_lo_20, m_l_20, m_r_20, m_whi_20, m_wlo_20, m_wl_20, m_in_20)
m_whi_20 := nw20, m_wlo_20 := nl20, m_wl_20 := nx20, m_in_20 := ni20
[nw21, nl21, nx21, ni21] = accumulate( 8, 0, 8,30, m_hi_21, m_lo_21, m_l_21, m_r_21, m_whi_21, m_wlo_21, m_wl_21, m_in_21)
m_whi_21 := nw21, m_wlo_21 := nl21, m_wl_21 := nx21, m_in_21 := ni21
[nw22, nl22, nx22, ni22] = accumulate( 8,20, 8,40, m_hi_22, m_lo_22, m_l_22, m_r_22, m_whi_22, m_wlo_22, m_wl_22, m_in_22)
m_whi_22 := nw22, m_wlo_22 := nl22, m_wl_22 := nx22, m_in_22 := ni22
[nw23, nl23, nx23, ni23] = accumulate( 9,20, 9,40, m_hi_23, m_lo_23, m_l_23, m_r_23, m_whi_23, m_wlo_23, m_wl_23, m_in_23)
m_whi_23 := nw23, m_wlo_23 := nl23, m_wl_23 := nx23, m_in_23 := ni23
[nw24, nl24, nx24, ni24] = accumulate(10,20,10,40, m_hi_24, m_lo_24, m_l_24, m_r_24, m_whi_24, m_wlo_24, m_wl_24, m_in_24)
m_whi_24 := nw24, m_wlo_24 := nl24, m_wl_24 := nx24, m_in_24 := ni24
[nw25, nl25, nx25, ni25] = accumulate(11,20,11,40, m_hi_25, m_lo_25, m_l_25, m_r_25, m_whi_25, m_wlo_25, m_wl_25, m_in_25)
m_whi_25 := nw25, m_wlo_25 := nl25, m_wl_25 := nx25, m_in_25 := ni25
[nw26, nl26, nx26, ni26] = accumulate(12,20,12,40, m_hi_26, m_lo_26, m_l_26, m_r_26, m_whi_26, m_wlo_26, m_wl_26, m_in_26)
m_whi_26 := nw26, m_wlo_26 := nl26, m_wl_26 := nx26, m_in_26 := ni26
[nw27, nl27, nx27, ni27] = accumulate(13,20,13,40, m_hi_27, m_lo_27, m_l_27, m_r_27, m_whi_27, m_wlo_27, m_wl_27, m_in_27)
m_whi_27 := nw27, m_wlo_27 := nl27, m_wl_27 := nx27, m_in_27 := ni27
[nw28, nl28, nx28, ni28] = accumulate(14,20,14,40, m_hi_28, m_lo_28, m_l_28, m_r_28, m_whi_28, m_wlo_28, m_wl_28, m_in_28)
m_whi_28 := nw28, m_wlo_28 := nl28, m_wl_28 := nx28, m_in_28 := ni28
[nw29, nl29, nx29, ni29] = accumulate(11,50,12,10, m_hi_29, m_lo_29, m_l_29, m_r_29, m_whi_29, m_wlo_29, m_wl_29, m_in_29)
m_whi_29 := nw29, m_wlo_29 := nl29, m_wl_29 := nx29, m_in_29 := ni29
[nw30, nl30, nx30, ni30] = accumulate(12,50,13,10, m_hi_30, m_lo_30, m_l_30, m_r_30, m_whi_30, m_wlo_30, m_wl_30, m_in_30)
m_whi_30 := nw30, m_wlo_30 := nl30, m_wl_30 := nx30, m_in_30 := ni30
[nw31, nl31, nx31, ni31] = accumulate(13,50,14,10, m_hi_31, m_lo_31, m_l_31, m_r_31, m_whi_31, m_wlo_31, m_wl_31, m_in_31)
m_whi_31 := nw31, m_wlo_31 := nl31, m_wl_31 := nx31, m_in_31 := ni31
[nw32, nl32, nx32, ni32] = accumulate(14,50,15,10, m_hi_32, m_lo_32, m_l_32, m_r_32, m_whi_32, m_wlo_32, m_wl_32, m_in_32)
m_whi_32 := nw32, m_wlo_32 := nl32, m_wl_32 := nx32, m_in_32 := ni32
[nw33, nl33, nx33, ni33] = accumulate(15,50,16,10, m_hi_33, m_lo_33, m_l_33, m_r_33, m_whi_33, m_wlo_33, m_wl_33, m_in_33)
m_whi_33 := nw33, m_wlo_33 := nl33, m_wl_33 := nx33, m_in_33 := ni33
[nw34, nl34, nx34, ni34] = accumulate(13,10,13,40, m_hi_34, m_lo_34, m_l_34, m_r_34, m_whi_34, m_wlo_34, m_wl_34, m_in_34)
m_whi_34 := nw34, m_wlo_34 := nl34, m_wl_34 := nx34, m_in_34 := ni34
[nw35, nl35, nx35, ni35] = accumulate(15,15,15,45, m_hi_35, m_lo_35, m_l_35, m_r_35, m_whi_35, m_wlo_35, m_wl_35, m_in_35)
m_whi_35 := nw35, m_wlo_35 := nl35, m_wl_35 := nx35, m_in_35 := ni35

// Final Array Trimming
trimArr(m_hi_0,  m_lo_0,  m_l_0,  m_r_0,  i_days), trimArr(m_hi_1,  m_lo_1,  m_l_1,  m_r_1,  i_days)
trimArr(m_hi_2,  m_lo_2,  m_l_2,  m_r_2,  i_days), trimArr(m_hi_3,  m_lo_3,  m_l_3,  m_r_3,  i_days)
trimArr(m_hi_4,  m_lo_4,  m_l_4,  m_r_4,  i_days), trimArr(m_hi_5,  m_lo_5,  m_l_5,  m_r_5,  i_days)
trimArr(m_hi_6,  m_lo_6,  m_l_6,  m_r_6,  i_days), trimArr(m_hi_7,  m_lo_7,  m_l_7,  m_r_7,  i_days)
trimArr(m_hi_8,  m_lo_8,  m_l_8,  m_r_8,  i_days), trimArr(m_hi_9,  m_lo_9,  m_l_9,  m_r_9,  i_days)
trimArr(m_hi_10, m_lo_10, m_l_10, m_r_10, i_days), trimArr(m_hi_11, m_lo_11, m_l_11, m_r_11, i_days)
trimArr(m_hi_12, m_lo_12, m_l_12, m_r_12, i_days), trimArr(m_hi_13, m_lo_13, m_l_13, m_r_13, i_days)
trimArr(m_hi_14, m_lo_14, m_l_14, m_r_14, i_days), trimArr(m_hi_15, m_lo_15, m_l_15, m_r_15, i_days)
trimArr(m_hi_16, m_lo_16, m_l_16, m_r_16, i_days), trimArr(m_hi_17, m_lo_17, m_l_17, m_r_17, i_days)
trimArr(m_hi_18, m_lo_18, m_l_18, m_r_18, i_days), trimArr(m_hi_19, m_lo_19, m_l_19, m_r_19, i_days)
trimArr(m_hi_20, m_lo_20, m_l_20, m_r_20, i_days), trimArr(m_hi_21, m_lo_21, m_l_21, m_r_21, i_days)
trimArr(m_hi_22, m_lo_22, m_l_22, m_r_22, i_days), trimArr(m_hi_23, m_lo_23, m_l_23, m_r_23, i_days)
trimArr(m_hi_24, m_lo_24, m_l_24, m_r_24, i_days), trimArr(m_hi_25, m_lo_25, m_l_25, m_r_25, i_days)
trimArr(m_hi_26, m_lo_26, m_l_26, m_r_26, i_days), trimArr(m_hi_27, m_lo_27, m_l_27, m_r_27, i_days)
trimArr(m_hi_28, m_lo_28, m_l_28, m_r_28, i_days), trimArr(m_hi_29, m_lo_29, m_l_29, m_r_29, i_days)
trimArr(m_hi_30, m_lo_30, m_l_30, m_r_30, i_days), trimArr(m_hi_31, m_lo_31, m_l_31, m_r_31, i_days)
trimArr(m_hi_32, m_lo_32, m_l_32, m_r_32, i_days), trimArr(m_hi_33, m_lo_33, m_l_33, m_r_33, i_days)
trimArr(m_hi_34, m_lo_34, m_l_34, m_r_34, i_days), trimArr(m_hi_35, m_lo_35, m_l_35, m_r_35, i_days)

// ─────────────────────────────────────────────────────────────────────────────
// DRAWING ENGINE
// ─────────────────────────────────────────────────────────────────────────────
var box[]   d_boxes  = array.new_box(0)
var label[] d_labels = array.new_label(0)

clearAll() =>
    for b in d_boxes
        box.delete(b)
    for lb in d_labels
        label.delete(lb)
    array.clear(d_boxes)
    array.clear(d_labels)

drawZone(hi_arr, lo_arr, l_arr, r_arr, whi, wlo, wl, in_live, enabled, boxCol, lblCol, lbl) =>
    if enabled
        n = array.size(hi_arr)
        if n > 0
            for i = 0 to n - 1
                bx = box.new(array.get(l_arr, i), array.get(hi_arr, i),
                             array.get(r_arr, i), array.get(lo_arr, i),
                             border_color = lblCol,
                             border_width = 1,
                             bgcolor      = boxCol)
                lb = label.new(array.get(r_arr, i), array.get(hi_arr, i),
                               text      = lbl,
                               color     = color.new(color.black, 100),
                               textcolor = lblCol,
                               style     = label.style_label_left,
                               size      = size.tiny)
                array.push(d_boxes, bx)
                array.push(d_labels, lb)
        if in_live and not na(whi)
            bx = box.new(wl, whi, bar_index, wlo,
                         border_color = lblCol,
                         border_width = 1,
                         bgcolor      = boxCol)
            lb = label.new(bar_index, whi,
                           text      = lbl + " ◀",
                           color     = color.new(color.black, 100),
                           textcolor = lblCol,
                           style     = label.style_label_left,
                           size      = size.tiny)
            array.push(d_boxes, bx)
            array.push(d_labels, lb)

if barstate.islast
    clearAll()
    drawZone(m_hi_0, m_lo_0, m_l_0, m_r_0, m_whi_0, m_wlo_0, m_wl_0, m_in_0, i_a1, i_asia_col, i_asia_lblc, "Asia 16:50")
    drawZone(m_hi_1, m_lo_1, m_l_1, m_r_1, m_whi_1, m_wlo_1, m_wl_1, m_in_1, i_a2, i_asia_col, i_asia_lblc, "Asia 17:50")
    drawZone(m_hi_2, m_lo_2, m_l_2, m_r_2, m_whi_2, m_wlo_2, m_wl_2, m_in_2, i_a3, i_asia_col, i_asia_lblc, "Asia 18:50")
    drawZone(m_hi_3, m_lo_3, m_l_3, m_r_3, m_whi_3, m_wlo_3, m_wl_3, m_in_3, i_a4, i_asia_col, i_asia_lblc, "Asia 19:50")
    drawZone(m_hi_4, m_lo_4, m_l_4, m_r_4, m_whi_4, m_wlo_4, m_wl_4, m_in_4, i_a5, i_asia_col, i_asia_lblc, "Asia 20:50")
    drawZone(m_hi_5, m_lo_5, m_l_5, m_r_5, m_whi_5, m_wlo_5, m_wl_5, m_in_5, i_a6, i_asia_col, i_asia_lblc, "Asia 21:50")
    drawZone(m_hi_6, m_lo_6, m_l_6, m_r_6, m_whi_6, m_wlo_6, m_wl_6, m_in_6, i_a7, i_asia_col, i_asia_lblc, "Asia 22:50")
    drawZone(m_hi_7, m_lo_7, m_l_7, m_r_7, m_whi_7, m_wlo_7, m_wl_7, m_in_7, i_a8, i_asia_col, i_asia_lblc, "Asia 23:50")
    drawZone(m_hi_8, m_lo_8, m_l_8, m_r_8, m_whi_8, m_wlo_8, m_wl_8, m_in_8, i_a9, i_asia_col, i_asia_lblc, "Asia 00:50")
    drawZone(m_hi_9, m_lo_9, m_l_9, m_r_9, m_whi_9, m_wlo_9, m_wl_9, m_in_9, i_l1, i_lon_col, i_lon_lblc, "Lon 01:50")
    drawZone(m_hi_10, m_lo_10, m_l_10, m_r_10, m_whi_10, m_wlo_10, m_wl_10, m_in_10, i_l2, i_lon_col, i_lon_lblc, "Lon 02:50")
    drawZone(m_hi_11, m_lo_11, m_l_11, m_r_11, m_whi_11, m_wlo_11, m_wl_11, m_in_11, i_l3, i_lon_col, i_lon_lblc, "Lon 03:50")
    drawZone(m_hi_12, m_lo_12, m_l_12, m_r_12, m_whi_12, m_wlo_12, m_wl_12, m_in_12, i_l4, i_lon_col, i_lon_lblc, "Lon 04:50")
    drawZone(m_hi_13, m_lo_13, m_l_13, m_r_13, m_whi_13, m_wlo_13, m_wl_13, m_in_13, i_l5, i_lon_col, i_lon_lblc, "Lon 05:50")
    drawZone(m_hi_14, m_lo_14, m_l_14, m_r_14, m_whi_14, m_wlo_14, m_wl_14, m_in_14, i_tbr_lon, i_tbrl_col, i_tbrl_lblc, "TBR Lon 02:33")
    drawZone(m_hi_15, m_lo_15, m_l_15, m_r_15, m_whi_15, m_wlo_15, m_wl_15, m_in_15, i_n1, i_nyam_col, i_nyam_lblc, "NY AM 06:50")
    drawZone(m_hi_16, m_lo_16, m_l_16, m_r_16, m_whi_16, m_wlo_16, m_wl_16, m_in_16, i_n2, i_nyam_col, i_nyam_lblc, "NY AM 07:50")
    drawZone(m_hi_17, m_lo_17, m_l_17, m_r_17, m_whi_17, m_wlo_17, m_wl_17, m_in_17, i_n3, i_nyam_col, i_nyam_lblc, "NY AM 08:50")
    drawZone(m_hi_18, m_lo_18, m_l_18, m_r_18, m_whi_18, m_wlo_18, m_wl_18, m_in_18, i_n4, i_nyam_col, i_nyam_lblc, "NY AM 09:50")
    drawZone(m_hi_19, m_lo_19, m_l_19, m_r_19, m_whi_19, m_wlo_19, m_wl_19, m_in_19, i_n5, i_nyam_col, i_nyam_lblc, "NY AM 10:50")
    drawZone(m_hi_20, m_lo_20, m_l_20, m_r_20, m_whi_20, m_wlo_20, m_wl_20, m_in_20, i_tbr_ny1, i_tbrny_col, i_tbrny_lblc, "TBR NY 07:30")
    drawZone(m_hi_21, m_lo_21, m_l_21, m_r_21, m_whi_21, m_wlo_21, m_wl_21, m_in_21, i_tbr_ny2, i_tbrny_col, i_tbrny_lblc, "TBR NY 08:00")
    drawZone(m_hi_22, m_lo_22, m_l_22, m_r_22, m_whi_22, m_wlo_22, m_wl_22, m_in_22, i_2040_08, i_2040_col, i_2040_lblc, "20-40 08:20")
    drawZone(m_hi_23, m_lo_23, m_l_23, m_r_23, m_whi_23, m_wlo_23, m_wl_23, m_in_23, i_2040_09, i_2040_col, i_2040_lblc, "20-40 09:20")
    drawZone(m_hi_24, m_lo_24, m_l_24, m_r_24, m_whi_24, m_wlo_24, m_wl_24, m_in_24, i_2040_10, i_2040_col, i_2040_lblc, "20-40 10:20")
    drawZone(m_hi_25, m_lo_25, m_l_25, m_r_25, m_whi_25, m_wlo_25, m_wl_25, m_in_25, i_2040_11, i_2040_col, i_2040_lblc, "20-40 11:20")
    drawZone(m_hi_26, m_lo_26, m_l_26, m_r_26, m_whi_26, m_wlo_26, m_wl_26, m_in_26, i_2040_12, i_2040_col, i_2040_lblc, "20-40 12:20")
    drawZone(m_hi_27, m_lo_27, m_l_27, m_r_27, m_whi_27, m_wlo_27, m_wl_27, m_in_27, i_2040_13, i_2040_col, i_2040_lblc, "20-40 13:20")
    drawZone(m_hi_28, m_lo_28, m_l_28, m_r_28, m_whi_28, m_wlo_28, m_wl_28, m_in_28, i_2040_14, i_2040_col, i_2040_lblc, "20-40 14:20")
    drawZone(m_hi_29, m_lo_29, m_l_29, m_r_29, m_whi_29, m_wlo_29, m_wl_29, m_in_29, i_p1, i_nypm_col, i_nypm_lblc, "NY PM 11:50")
    drawZone(m_hi_30, m_lo_30, m_l_30, m_r_30, m_whi_30, m_wlo_30, m_wl_30, m_in_30, i_p2, i_nypm_col, i_nypm_lblc, "NY PM 12:50")
    drawZone(m_hi_31, m_lo_31, m_l_31, m_r_31, m_whi_31, m_wlo_31, m_wl_31, m_in_31, i_p3, i_nypm_col, i_nypm_lblc, "NY PM 13:50")
    drawZone(m_hi_32, m_lo_32, m_l_32, m_r_32, m_whi_32, m_wlo_32, m_wl_32, m_in_32, i_p4, i_nypm_col, i_nypm_lblc, "NY PM 14:50")
    drawZone(m_hi_33, m_lo_33, m_l_33, m_r_33, m_whi_33, m_wlo_33, m_wl_33, m_in_33, i_p5, i_nypm_col, i_nypm_lblc, "NY PM 15:50")
    drawZone(m_hi_34, m_lo_34, m_l_34, m_r_34, m_whi_34, m_wlo_34, m_wl_34, m_in_34, i_tbr_nypm1, i_tbrnypm_col, i_tbrnypm_lblc, "TBR NY PM 13:10")
    drawZone(m_hi_35, m_lo_35, m_l_35, m_r_35, m_whi_35, m_wlo_35, m_wl_35, m_in_35, i_tbr_nypm2, i_tbrnypm_col, i_tbrnypm_lblc, "TBR NY PM 15:15")
````
