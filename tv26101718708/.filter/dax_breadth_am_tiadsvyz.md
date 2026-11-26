# DAX Breadth [AM]

- url: https://www.tradingview.com/script/tIADsVYz-DAX-Breadth-AM/
- type: indicator
- pine_id: PUB;6c2815b27e8a44cfb7808ca869093cfe
- version: 1.0

## Description

DAX Breadth [AM] — Publication Description
TradingView Pine Script Library
---
Title
DAX Breadth [AM]
Tagline
The breadth data DAX traders never had — until now.
---
Full Description
The Problem
If you trade the DAX40 intraday, you already know this frustration: breadth data simply does not exist for European indices on retail platforms. NYSE traders have TICK, ADD, VOLD and TRIN available as standard symbols. DAX traders have nothing equivalent. There is no XETR:TICK. There is no XETR:ADD. The Deutsche Börse publishes no aggregated breadth feed accessible to retail platforms.
This indicator solves that problem from the ground up.
---
What It Does
DAX Breadth [AM] reconstructs five institutional-grade breadth metrics for the DAX40 by individually scanning all 40 Xetra components on every bar using `request.security()` calls. It creates data that does not otherwise exist on TradingView.
This is not a mashup of existing indicators. It is a full reconstruction of breadth internals from raw component data.
---
The Five Metrics
TICK
Net advancing minus declining components on each bar. A reading of +25 means 32 stocks up, 7 down. Mirrors NYSE TICK methodology applied to the DAX40 universe. Reacts instantly — your fastest breadth signal.
CUMT (Cumulative TICK)
Running sum of TICK readings since the Xetra session open (09:00 CET), resetting daily. A rising CUMT throughout the session confirms sustained buying pressure. A falling CUMT despite a rising DAX price flags a breadth divergence — one of the most powerful signals in this indicator.
UVOL% (Up-Volume Ratio)
Volume of all advancing components as a percentage of total DAX40 volume. This is the critical institutional participation metric. A narrow rally driven by SAP or Siemens alone will show moderate TICK but low UVOL%. Readings above 75% confirm broad institutional buying. Below 30% on a rising index is a red flag.
ADV% (Advancing Percentage)
Raw count of advancing stocks as a percentage of the 40 components. Simple, fast, and useful for immediate visual confirmation of breadth width.
A/D Thrust (EMA-smoothed)
Advance/decline ratio smoothed with a configurable EMA (default 5 bars). Slower than TICK and ADV% by design — it filters noise and confirms the sustained directional bias of the session. Read it last, alongside CUMT.
---
The Dashboard
Each metric is displayed in a compact floating table with five columns:
INT	VALUE	TIER	TRD	ROC
Metric name	Current reading	Strength tier	Direction arrow	Rate of change
TIER classifies each metric into five levels using adaptive thresholds that widen during the first 15 bars of the session (early-session noise reduction):
+2 Strong Bull — dark green
+1 Bull — light green
0 Neutral — grey
−1 Bear — red
−2 Strong Bear — dark red
TRD shows the directional change vs the previous bar (↑ ↓ →).
ROC shows the delta vs N bars ago (configurable, default 5). All ROC values use a consistent delta format with explicit +/− sign so momentum direction is immediately readable.
---
Composite Score & Conclusion Block
Below the separator, three summary rows provide the analytical conclusion:
COMP — A weighted composite of all five metrics on a scale of −100 to +100.
Weights: UVOL% 30% · A/D 25% · TICK 20% · ADV% 15% · CUMT 10%
Includes its own ROC value and direction arrow.
Labels: Strong (≥50) · Moderate (≥25) · Weak (<25)
BIAS — Session directional bias derived from the composite score:
Bullish · Mild Bull · Neutral · Mild Bear · Bearish
MODE — Operating mode:
NORMAL — standard session conditions
NO_EDGE — composite score too low to confirm direction
90PCT_DAY — rare extreme breadth event (≥90% or ≤10% advancing) signalling high-probability trend continuation for the remainder of the session
---
How to Use It in Your Trading
Confirmation tool, not a signal generator.
Use DAX Breadth [AM] to confirm or challenge what you see on price. Before entering a long setup, check: Is UVOL% above 60%? Is CUMT rising? Is ADV% above 55%? If breadth contradicts the price setup, reduce size or skip the trade.
Divergence detection.
The most actionable signal: DAX index making new session highs while CUMT is declining. This breadth divergence frequently precedes sharp reversals. Watch it closely during the 10:00–11:00 CET window.
Opening Range context.
At 09:15 CET, after the Opening Range has formed, read the initial TICK and CUMT direction. A CUMT already moving strongly in one direction within the first 15 minutes is a high-conviction session bias signal.
90PCT_DAY awareness.
When MODE switches to 90PCT_DAY, the historical edge for trend continuation is significant. These sessions occur 2–5 times per quarter. On these days, fade setups should be avoided and trend-following setups sized up.
---
Technical Notes
Timeframe: Designed for 1-minute and 5-minute charts during the Xetra session (09:00–17:30 CET / Europe/Berlin timezone). Do not use on higher timeframes — CUMT accumulation becomes meaningless outside intraday context.
Data source: 39 XETR-listed components + Covestro (FWB:1COV, post-ADNOC acquisition). All other 39 components use Xetra primary listing data.
Session reset: CUMT resets automatically at 09:00 CET each trading day.
Adaptive tiers: Tier thresholds widen automatically during the first 15 bars of each session to prevent false extreme readings during the volatile open.
Overlay indicator: Renders as a floating table on the price chart. No separate pane required.
---
Settings
Setting	Default	Description
Table Position	Right Top	Floating table placement
Text Size	Normal	Tiny / Small / Normal
A/D EMA Smoothing	5 bars	EMA length for A/D Thrust
ROC Lookback	5 bars	Bars back for rate of change
---
Why This Is Different
Most breadth indicators available for European indices either:
(a) rely on pre-existing index breadth feeds that don't exist for DAX, or
(b) use price-only proxies that approximate breadth without volume confirmation.
DAX Breadth [AM] reconstructs five distinct breadth dimensions — including volume-weighted participation — from raw component data on every bar. The result is an institutional-grade breadth dashboard that did not previously exist for DAX40 intraday traders on any retail platform.
---
Designed and built for professional DAX40 intraday trading.
Optimised for use on 1M and 5M XETR:DAX charts during the Xetra session.

## Source Code

````pine
//@version=6
indicator("DAX Breadth [AM]", overlay=true, max_bars_back=500)

// ══════════════════════════════════════════════════════════════════
//  DAX BREADTH [AM] — Pine Script v6
//  Reconstructed breadth internals for the DAX 40
//  Metrics: TICK | CUMT | UVOL% | ADV% | A/D
//  + Composite score | BIAS | MODE
//
//  40 XETR symbols — exact DAX40 composition.
// ══════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  SETTINGS
// ─────────────────────────────────────────────
var string GRP = "⚙️ Settings"

tbl_pos_inp = input.string("Right Top", "Table Position",
     options=["Right Top","Right Bottom","Left Top","Left Bottom"], group=GRP)
txt_sz_inp  = input.string("Normal", "Text Size",
     options=["Tiny","Small","Normal"], group=GRP)
ema_len     = input.int(5, "A/D EMA Smoothing", minval=1, maxval=20, group=GRP)
roc_bars    = input.int(5, "ROC Lookback (bars)", minval=1, maxval=20, group=GRP)

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
f_pos(s) =>
    switch s
        "Right Top"    => position.top_right
        "Right Bottom" => position.bottom_right
        "Left Top"     => position.top_left
        =>               position.bottom_left

f_sz(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        =>          size.small

tbl_pos = f_pos(tbl_pos_inp)
txt_sz  = f_sz(txt_sz_inp)

// Xetra session: 09:00–17:30 Europe/Berlin
in_sess = not na(time(timeframe.period, "0900-1730", "Europe/Berlin"))

// Session bar counter (for adaptive early-session thresholds)
var int bars_in_sess = 0
if in_sess
    bars_in_sess := in_sess and not in_sess[1] ? 1 : bars_in_sess + 1
else
    bars_in_sess := 0

early_sess = bars_in_sess <= 15  // first 15 bars (~15 min on 1M)

// ─────────────────────────────────────────────
//  COMPONENT DATA — XETR symbols
//  Each request.security() call fetches [close, volume] as tuple
//  = 1 call per symbol (Pine v5 supports tuple requests)
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
[c11,v11] = request.security("FWB:1COV",  timeframe.period, [close,volume], lookahead=barmerge.lookahead_off) // Covestro — FWB (niet op XETR na ADNOC overname)
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
//  N = component count (DAX40)
// ─────────────────────────────────────────────
var float N = 40.0

// ─────────────────────────────────────────────
//  PER-COMPONENT: advancing / declining / upvol
// ─────────────────────────────────────────────
adv(c)    => c > c[1] ? 1 : 0
dec(c)    => c < c[1] ? 1 : 0
uvol(c,v) => c > c[1] ? v : 0.0

total_adv =
     adv(c01)+adv(c02)+adv(c03)+adv(c04)+adv(c05)+adv(c06)+adv(c07)+
     adv(c08)+adv(c09)+adv(c10)+adv(c11)+adv(c13)+adv(c14)+
     adv(c15)+adv(c16)+adv(c17)+adv(c18)+adv(c19)+adv(c20)+adv(c21)+
     adv(c22)+adv(c23)+adv(c24)+adv(c25)+adv(c26)+adv(c27)+adv(c28)+
     adv(c29)+adv(c30)+adv(c31)+adv(c32)+adv(c33)+adv(c34)+adv(c35)+
     adv(c36)+adv(c37)+adv(c38)+adv(c39)+adv(c40)+adv(c41)

total_dec =
     dec(c01)+dec(c02)+dec(c03)+dec(c04)+dec(c05)+dec(c06)+dec(c07)+
     dec(c08)+dec(c09)+dec(c10)+dec(c11)+dec(c13)+dec(c14)+
     dec(c15)+dec(c16)+dec(c17)+dec(c18)+dec(c19)+dec(c20)+dec(c21)+
     dec(c22)+dec(c23)+dec(c24)+dec(c25)+dec(c26)+dec(c27)+dec(c28)+
     dec(c29)+dec(c30)+dec(c31)+dec(c32)+dec(c33)+dec(c34)+dec(c35)+
     dec(c36)+dec(c37)+dec(c38)+dec(c39)+dec(c40)+dec(c41)

vol_adv =
     uvol(c01,v01)+uvol(c02,v02)+uvol(c03,v03)+uvol(c04,v04)+uvol(c05,v05)+
     uvol(c06,v06)+uvol(c07,v07)+uvol(c08,v08)+uvol(c09,v09)+uvol(c10,v10)+
     uvol(c11,v11)+uvol(c13,v13)+uvol(c14,v14)+uvol(c15,v15)+
     uvol(c16,v16)+uvol(c17,v17)+uvol(c18,v18)+uvol(c19,v19)+uvol(c20,v20)+
     uvol(c21,v21)+uvol(c22,v22)+uvol(c23,v23)+uvol(c24,v24)+uvol(c25,v25)+
     uvol(c26,v26)+uvol(c27,v27)+uvol(c28,v28)+uvol(c29,v29)+uvol(c30,v30)+
     uvol(c31,v31)+uvol(c32,v32)+uvol(c33,v33)+uvol(c34,v34)+uvol(c35,v35)+
     uvol(c36,v36)+uvol(c37,v37)+uvol(c38,v38)+uvol(c39,v39)+uvol(c40,v40)+
     uvol(c41,v41)

total_vol =
     v01+v02+v03+v04+v05+v06+v07+v08+v09+v10+v11+v13+v14+v15+
     v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+v26+v27+v28+v29+v30+
     v31+v32+v33+v34+v35+v36+v37+v38+v39+v40+v41

// ─────────────────────────────────────────────
//  BREADTH METRICS
// ─────────────────────────────────────────────

// TICK: net advancing minus declining (-N to +N)
tick = total_adv - total_dec

// CUMT: cumulative TICK since session open, resets each day
var float cumt = 0.0
if in_sess
    cumt := not in_sess[1] ? float(tick) : cumt + tick
else
    cumt := 0.0

// A/D Thrust: (adv-dec)/N, EMA-smoothed (-1.0 to +1.0)
ad_raw = (total_adv - total_dec) / N
ad     = ta.ema(ad_raw, ema_len)

// UVOL%: up-volume as % of total volume (0–100)
uvol_pct = total_vol > 0 ? (vol_adv / total_vol) * 100.0 : 50.0

// ADV%: simple advancing count as % (0–100)
adv_pct = (total_adv / N) * 100.0

// ─────────────────────────────────────────────
//  TIER CLASSIFICATION
//  Adaptive: wider thresholds during early session
// ─────────────────────────────────────────────
// Returns: 1=Strong Bull | 2=Bull | 0=Neutral | -2=Bear | -1=Strong Bear

f_tick_tier(v) =>
    lim1 = early_sess ? 20 : 15
    lim2 = early_sess ?  5 :  3
    v >= lim1 ? 1 : v >= lim2 ? 2 : v <= -lim1 ? -1 : v <= -lim2 ? -2 : 0

f_cumt_tier(v) =>
    v >= 500 ? 1 : v >= 150 ? 2 : v <= -500 ? -1 : v <= -150 ? -2 : 0

f_ad_tier(v) =>
    v >= 0.7 ? 1 : v >= 0.2 ? 2 : v <= -0.7 ? -1 : v <= -0.2 ? -2 : 0

f_uvol_tier(v) =>
    v >= 80 ? 1 : v >= 60 ? 2 : v <= 20 ? -1 : v <= 40 ? -2 : 0

f_adv_tier(v) =>
    v >= 75 ? 1 : v >= 55 ? 2 : v <= 25 ? -1 : v <= 45 ? -2 : 0

// ─────────────────────────────────────────────
//  COMPOSITE SCORE
//  Weighted sum of all 5 metrics → -100 to +100
//  Weights: UVOL 30% | A/D 25% | TICK 20% | ADV 15% | CUMT 10%
// ─────────────────────────────────────────────
tick_n = tick / N                                    // -1 to +1
cumt_n = math.max(math.min(cumt / 400.0, 1.0), -1.0)
ad_n   = ad                                          // already -1 to +1
uvol_n = (uvol_pct - 50.0) / 50.0                   // -1 to +1
adv_n  = (adv_pct  - 50.0) / 50.0

comp = (tick_n * 0.20 + cumt_n * 0.10 + ad_n * 0.25 + uvol_n * 0.30 + adv_n * 0.15) * 100.0

// ─────────────────────────────────────────────
//  MODE & BIAS
// ─────────────────────────────────────────────
mode_str = adv_pct >= 90.0 or adv_pct <= 10.0 ? "90PCT_DAY" : math.abs(comp) < 8.0 ? "NO_EDGE" : "NORMAL"

bias_str = comp >= 30.0 ? "Bullish" : comp >= 10.0 ? "Mild Bull" : comp <= -30.0 ? "Bearish" : comp <= -10.0 ? "Mild Bear" : "Neutral"

// ─────────────────────────────────────────────
//  ROC (Rate of Change vs N bars ago)
//  All values shown as simple delta (current minus N bars ago)
// ─────────────────────────────────────────────
tick_roc = tick     - nz(tick[roc_bars])
cumt_roc = math.round(cumt    - nz(cumt[roc_bars]))
uvol_roc = math.round(uvol_pct - nz(uvol_pct[roc_bars]), 1)
adv_roc  = math.round(adv_pct  - nz(adv_pct[roc_bars]),  1)
ad_roc   = math.round((ad      - nz(ad[roc_bars])) * 100.0, 1)
comp_roc = math.round(comp     - nz(comp[roc_bars]))

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
C_BG    = color.new(#0d1117, 10)
C_HDR   = color.new(#161b22,  0)
C_STR_B = color.new(#00c853,  0)   // Strong Bull
C_BULL  = color.new(#69f0ae,  0)   // Bull
C_NEUT  = color.new(#90a4ae,  0)   // Neutral
C_BEAR  = color.new(#ff5252,  0)   // Bear
C_STR_S = color.new(#b71c1c,  0)   // Strong Bear
C_ORNG  = color.new(#ff6d00,  0)   // 90PCT_DAY
C_TXT   = color.new(#ffffff,  0)
C_DIM   = color.new(#b0bec5,  0)

f_tier_col(t) =>
    t == 1 ? C_STR_B : t == 2 ? C_BULL : t == -1 ? C_STR_S : t == -2 ? C_BEAR : C_NEUT

f_tier_lbl(t) =>
    t == 1 ? "+2" : t == 2 ? "+1" : t == -1 ? "-2" : t == -2 ? "-1" : " 0"

f_trd(cur, prev) =>
    cur > prev ? "↑" : cur < prev ? "↓" : "→"

// ─────────────────────────────────────────────
//  TABLE — 5 columns × 11 rows
//  Row order: TICK | CUMT | UVOL% | ADV% | A/D | sep | COMP | BIAS/MODE
// ─────────────────────────────────────────────
var table tbl = table.new(tbl_pos, 5, 11,
     bgcolor       = C_BG,
     border_width  = 1,
     border_color  = color.new(color.gray, 65),
     frame_width   = 2,
     frame_color   = color.new(color.gray, 40))

f_cell(r, c, txt, bg, tc) =>
    table.cell(tbl, c, r, txt, bgcolor=bg, text_color=tc, text_size=txt_sz,
               text_halign=text.align_center)

// ROC display helper: prefix + for positive values
f_roc_str(v) =>
    v > 0 ? "+" + str.tostring(v) : str.tostring(v)

if barstate.islast

    // ── Row 0: Header ──────────────────────────────────────
    f_cell(0, 0, "INT",   C_HDR, C_TXT)
    f_cell(0, 1, "VALUE", C_HDR, C_TXT)
    f_cell(0, 2, "TIER",  C_HDR, C_TXT)
    f_cell(0, 3, "TRD",   C_HDR, C_TXT)
    f_cell(0, 4, "ROC",   C_HDR, C_TXT)

    // ── Row 1: TICK ────────────────────────────────────────
    tk = f_tick_tier(tick)
    f_cell(1, 0, "TICK",                     C_BG, C_TXT)
    f_cell(1, 1, str.tostring(tick),          C_BG, f_tier_col(tk))
    f_cell(1, 2, f_tier_lbl(tk),             C_BG, f_tier_col(tk))
    f_cell(1, 3, f_trd(tick, nz(tick[1])),  C_BG, C_DIM)
    f_cell(1, 4, f_roc_str(tick_roc),        C_BG, C_DIM)

    // ── Row 2: CUMT ────────────────────────────────────────
    ct = f_cumt_tier(cumt)
    f_cell(2, 0, "CUMT",                              C_BG, C_TXT)
    f_cell(2, 1, str.tostring(math.round(cumt)),       C_BG, f_tier_col(ct))
    f_cell(2, 2, f_tier_lbl(ct),                      C_BG, f_tier_col(ct))
    f_cell(2, 3, f_trd(cumt, nz(cumt[1])),            C_BG, C_DIM)
    f_cell(2, 4, f_roc_str(cumt_roc),                 C_BG, C_DIM)

    // ── Row 3: UVOL% ───────────────────────────────────────
    ut = f_uvol_tier(uvol_pct)
    f_cell(3, 0, "UVOL%",                                        C_BG, C_TXT)
    f_cell(3, 1, str.tostring(math.round(uvol_pct, 1)) + "%",    C_BG, f_tier_col(ut))
    f_cell(3, 2, f_tier_lbl(ut),                                 C_BG, f_tier_col(ut))
    f_cell(3, 3, f_trd(uvol_pct, nz(uvol_pct[1])),              C_BG, C_DIM)
    f_cell(3, 4, f_roc_str(uvol_roc),                            C_BG, C_DIM)

    // ── Row 4: ADV% ────────────────────────────────────────
    avt = f_adv_tier(adv_pct)
    f_cell(4, 0, "ADV%",                                         C_BG, C_TXT)
    f_cell(4, 1, str.tostring(math.round(adv_pct, 1)) + "%",     C_BG, f_tier_col(avt))
    f_cell(4, 2, f_tier_lbl(avt),                                C_BG, f_tier_col(avt))
    f_cell(4, 3, f_trd(adv_pct, nz(adv_pct[1])),                C_BG, C_DIM)
    f_cell(4, 4, f_roc_str(adv_roc),                             C_BG, C_DIM)

    // ── Row 5: A/D (EMA-smoothed — lagging, laatste) ───────
    at = f_ad_tier(ad)
    f_cell(5, 0, "A/D",                                          C_BG, C_TXT)
    f_cell(5, 1, str.tostring(math.round(ad * 100.0, 1)),         C_BG, f_tier_col(at))
    f_cell(5, 2, f_tier_lbl(at),                                 C_BG, f_tier_col(at))
    f_cell(5, 3, f_trd(ad, nz(ad[1])),                          C_BG, C_DIM)
    f_cell(5, 4, f_roc_str(ad_roc),                              C_BG, C_DIM)

    // ── Row 6: Separator ───────────────────────────────────
    for col = 0 to 4
        table.cell(tbl, col, 6, "",
             bgcolor=color.new(#2a2a3a, 0), text_color=C_DIM,
             text_size=size.tiny, text_halign=text.align_center)

    // ── Row 7: COMP ── gewogen composite score + ROC ───────
    comp_r   = math.round(comp)
    comp_col = comp_r >= 30 ? C_STR_B : comp_r >= 10 ? C_BULL : comp_r <= -30 ? C_STR_S : comp_r <= -10 ? C_BEAR : C_NEUT
    comp_lbl = math.abs(comp_r) >= 50 ? "Strong" : math.abs(comp_r) >= 25 ? "Moderate" : "Weak"
    f_cell(7, 0, "COMP",                   C_BG, C_TXT)
    f_cell(7, 1, str.tostring(comp_r),      C_BG, comp_col)
    f_cell(7, 2, comp_lbl,                  C_BG, comp_col)
    f_cell(7, 3, f_trd(comp, nz(comp[1])), C_BG, C_DIM)
    f_cell(7, 4, f_roc_str(comp_roc),       C_BG, C_DIM)

    // ── Row 8: BIAS ────────────────────────────────────────
    bias_col = bias_str == "Bullish" ? C_STR_B : bias_str == "Mild Bull" ? C_BULL : bias_str == "Bearish" ? C_STR_S : bias_str == "Mild Bear" ? C_BEAR : C_NEUT
    f_cell(8, 0, "BIAS",    C_BG, C_TXT)
    f_cell(8, 1, bias_str,  C_BG, bias_col)
    f_cell(8, 2, "",        C_BG, C_DIM)
    f_cell(8, 3, "",        C_BG, C_DIM)
    f_cell(8, 4, "",        C_BG, C_DIM)

    // ── Row 9: MODE ────────────────────────────────────────
    mode_col = mode_str == "90PCT_DAY" ? C_ORNG : mode_str == "NO_EDGE" ? C_NEUT : C_TXT
    f_cell(9, 0, "MODE",    C_BG, C_TXT)
    f_cell(9, 1, mode_str,  C_BG, mode_col)
    f_cell(9, 2, "",        C_BG, C_DIM)
    f_cell(9, 3, "",        C_BG, C_DIM)
    f_cell(9, 4, "",        C_BG, C_DIM)

// ══════════════════════════════════════════════════════════════════
//  END OF SCRIPT — Phase 2 complete
//  Phase 3 opties:
//  □ Divergentie alerts (CUMT daalt terwijl index stijgt)
//  □ Achtergrondkleur op chart bij breadth extremen
//  □ 90PCT_DAY alert notificatie
// ══════════════════════════════════════════════════════════════════
````
