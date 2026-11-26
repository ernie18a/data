# ABC123LeiaBiggy

- url: https://www.tradingview.com/script/4m4t7zyk-ABC123LeiaBiggy/
- type: indicator
- pine_id: PUB;35186d9d88a64b509e0ae2474f9d7ea0
- version: 1.0

## Description

I am bearish on the NZD today. 

Before we dive into my NZD analysis. Let’s discuss what happened with our last trades. 

On Friday, I sent you an email informing you of my bullish USDJPY bias into the 159 zone. 

I attach below a picture of the USDJPY trade so you can study it.

As of today, I am bearish on the NZD : 

1) China’s growth unexpectedly slowed down, retail sales came out at 0.2%. China is one of New Zealand’s biggest trade partners (they account for about 25% of new zealand’s exports). In simple terms, if China is affected, new zealand is affected too. 

2) New Zealand’s unemployment rate is the highest since the September 2015 quarter, which makes it hard for them to raise interest rates as inflation rises. 

3) New Zealand’s businesses are contracting, according to the BNZ-BusinessNZ Performance of Services Index (PSI). 

As simple as that.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
//  SMS STRATEGY  —  Smart Money Sweep  (30-minute timeframe only)
//  v3  —  Fixed idx >= 1 threshold; clarified B0/B1 pair logic
//
//  BEARISH SETUP  (daily HIGH swept = A)
//    A   — The daily high that was most recently taken out.
//    B0  — Start of the impulse that grabbed A.
//          Scan back from sweep bar → first BEARISH candle found.
//          Look at that candle + the BULLISH candle immediately to its right.
//          B0 = lowest low between that pair.
//    B1  — Highest point reached after A was swept, before price breaks B0.
//          Mathematically ABOVE A (price had to go above A to sweep it).
//    50% — Midpoint of B0 ↔ B1.
//    C   — Entry: lowest low of all candles that touch the 50% fib line.
//          (If a touching candle breaks below B0 → retest mode; entry = next B0 touch.)
//    SL  — B1.   TP — C − 3 × (SL − C).   Risk:Reward = 1:3.
//
//  BULLISH SETUP  (daily LOW swept = A)
//    A   — The daily low that was most recently taken out.
//    B0  — Start of the impulse that grabbed A.
//          Scan back from sweep bar → first BULLISH candle found.
//          Look at that candle + the BEARISH candle immediately to its right.
//          B0 = highest high between that pair.
//    B1  — Lowest point reached after A was swept, before price breaks above B0.
//          Mathematically BELOW A (price had to go below A to sweep it).
//    50% — Midpoint of B0 ↔ B1.
//    C   — Entry: highest high of all candles that touch the 50% fib line.
//          (If a touching candle breaks above B0 → retest mode; entry = next B0 touch.)
//    SL  — B1.   TP — C + 3 × (C − SL).   Risk:Reward = 1:3.
//
//  Invalidation: price extends 3× the B0↔B1 range past B0 before C is found.
//  State lock: once B1 is established (state 2), new daily sweeps are ignored
//  until the setup completes (3) or is invalidated (4).
//
//  OUTPUTS: Labelled lines for A / B0 / B1 / Fib50 / C / SL / TP,
//           top-right dashboard table, TradingView alert on entry.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("SMS Strategy [30m]", shorttitle = "SMS", overlay = true,
     max_lines_count = 40, max_labels_count = 40, max_bars_back = 500)

// ─────────────────────────────────────────────────────────────────────────────
//  TIMEFRAME GUARD
// ─────────────────────────────────────────────────────────────────────────────
if timeframe.period != "30"
    runtime.error("SMS Strategy must be applied on the 30-minute chart.")

// ─────────────────────────────────────────────────────────────────────────────
//  USER INPUTS
// ─────────────────────────────────────────────────────────────────────────────
i_scan  = input.int(40,  "B0 Scan Depth (bars)",   minval = 10, maxval = 100,
     tooltip = "How many 30m bars back to locate the swing extreme and B0 candle pair.")
i_fresh = input.int(100, "Sweep Freshness (bars)",  minval = 20, maxval = 300,
     tooltip = "A level only fires if price has NOT crossed it in this many bars. Prevents re-sweep false signals.")

// ─────────────────────────────────────────────────────────────────────────────
//  COLOUR PALETTE
// ─────────────────────────────────────────────────────────────────────────────
C_A    = color.new(#FF9800, 0)
C_B0   = color.new(#FFD600, 0)
C_B1   = color.new(#CE93D8, 0)
C_F50  = color.new(#42A5F5, 40)
C_C    = color.new(#00E676, 0)
C_SL   = color.new(#EF5350, 20)
C_TP   = color.new(#66BB6A, 20)

// ─────────────────────────────────────────────────────────────────────────────
//  DAILY DATA  —  5 completed daily candles, no lookahead bias
// ─────────────────────────────────────────────────────────────────────────────
dH1 = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_off)
dL1 = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_off)
dH2 = request.security(syminfo.tickerid, "D", high[2], lookahead = barmerge.lookahead_off)
dL2 = request.security(syminfo.tickerid, "D", low[2],  lookahead = barmerge.lookahead_off)
dH3 = request.security(syminfo.tickerid, "D", high[3], lookahead = barmerge.lookahead_off)
dL3 = request.security(syminfo.tickerid, "D", low[3],  lookahead = barmerge.lookahead_off)
dH4 = request.security(syminfo.tickerid, "D", high[4], lookahead = barmerge.lookahead_off)
dL4 = request.security(syminfo.tickerid, "D", low[4],  lookahead = barmerge.lookahead_off)
dH5 = request.security(syminfo.tickerid, "D", high[5], lookahead = barmerge.lookahead_off)
dL5 = request.security(syminfo.tickerid, "D", low[5],  lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
//  PERSISTENT STATE
//  0 = IDLE  1 = AWAIT_B0_BREAK  2 = FIND_C  3 = ENTRY_SET  4 = INVALID
// ─────────────────────────────────────────────────────────────────────────────
var int   st      = 0
var bool  bear    = false

var float A_lvl   = na
var int   A_bar   = na
var float B0_lvl  = na
var int   B0_bar  = na
var float B1_lvl  = na
var float F50     = na
var float C_lvl   = na
var float SL_lvl  = na
var float TP_lvl  = na
var float run_ext = na
var float best_c  = na
var bool  c_ret   = false
var float inv_th  = na

var line  ln_A   = na
var line  ln_B0  = na
var line  ln_B1  = na
var line  ln_F50 = na
var line  ln_C   = na
var line  ln_SL  = na
var line  ln_TP  = na
var label lb_A   = na
var label lb_B0  = na
var label lb_B1  = na
var label lb_C   = na
var label lb_SL  = na
var label lb_TP  = na

// ─────────────────────────────────────────────────────────────────────────────
//  UTILITY FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────

// Highest high across bars[0 … n]
f_max_hi(int n) =>
    float mx = high
    for k = 1 to n
        mx := math.max(mx, high[k])
    mx

// Lowest low across bars[0 … n]
f_min_lo(int n) =>
    float mn = low
    for k = 1 to n
        mn := math.min(mn, low[k])
    mn

// ─────────────────────────────────────────────────────────────────────────────
//  B0 DETECTION  —  "start of the impulse that grabbed A"
//
//  Scan backwards from bar[1].  The FIRST candle of the opposite colour is the
//  candle created right before the impulse move that swept A.  The candle
//  immediately to its RIGHT (one bar more recent, idx-1) is the first candle
//  of that impulse.  Those two candles are the B0 pair.
//
//  BEARISH setup (daily HIGH swept):
//    First BEARISH candle found = "launch pad" red candle
//    Candle to its right        = first green candle of the up-move
//    B0 = min( low[bearish], low[first-green] )   ← lowest floor of the pair
//    B1 = highest point reached before B0 breaks  ← mathematically ABOVE A
//
//  BULLISH setup (daily LOW swept):
//    First BULLISH candle found = "launch pad" green candle
//    Candle to its right        = first red candle of the down-move
//    B0 = max( high[bullish], high[first-red] )   ← highest ceiling of the pair
//    B1 = lowest point reached before B0 breaks   ← mathematically BELOW A
//
//  Returns [b0_level, b0_bar_index, bars_ago]
// ─────────────────────────────────────────────────────────────────────────────

f_b0_bear(int depth) =>
    int   idx        = -1
    for j = 1 to depth
        if idx == -1 and close[j] < open[j]
            idx := j
    float b0_lvl     = na
    int   b0_bar_out = na
    if idx >= 1
        int pair   = math.max(idx - 1, 0)       // right neighbour; clamp to bar[0]
        b0_lvl     := math.min(low[idx], low[pair])
        b0_bar_out := bar_index - idx
    [b0_lvl, b0_bar_out, idx]

f_b0_bull(int depth) =>
    int   idx        = -1
    for j = 1 to depth
        if idx == -1 and close[j] > open[j]
            idx := j
    float b0_lvl     = na
    int   b0_bar_out = na
    if idx >= 1
        int pair   = math.max(idx - 1, 0)       // right neighbour; clamp to bar[0]
        b0_lvl     := math.max(high[idx], high[pair])
        b0_bar_out := bar_index - idx
    [b0_lvl, b0_bar_out, idx]

// ─────────────────────────────────────────────────────────────────────────────
//  SWEEP DETECTION  —  strict first-cross + freshness guard (v2 fix)
//
//  A level only fires when:
//    • This bar is the FIRST bar to cross the level (high[1] ≤ level or low[1] ≥ level)
//    • Price has NOT crossed that level in the past i_fresh bars
//      (prevents re-sweeps of a level that was already violated earlier)
//  Priority: most recent daily candle (i = 0) wins if multiple levels cross same bar.
// ─────────────────────────────────────────────────────────────────────────────
float swept_h = na
float swept_l = na

dHighs = array.from(dH1, dH2, dH3, dH4, dH5)
dLows  = array.from(dL1, dL2, dL3, dL4, dL5)

for i = 0 to 4
    h = array.get(dHighs, i)
    l = array.get(dLows,  i)

    // ── High sweep ──────────────────────────────────────────────────────────
    if not na(h) and high > h and high[1] <= h and na(swept_h)
        bool fresh_h = true
        for k = 2 to i_fresh
            if high[k] > h
                fresh_h := false
                break
        if fresh_h
            swept_h := h

    // ── Low sweep ───────────────────────────────────────────────────────────
    if not na(l) and low < l and low[1] >= l and na(swept_l)
        bool fresh_l = true
        for k = 2 to i_fresh
            if low[k] < l
                fresh_l := false
                break
        if fresh_l
            swept_l := l

new_bear_sw = not na(swept_h)
new_bull_sw = not na(swept_l)
new_sw      = new_bear_sw or new_bull_sw

// ─────────────────────────────────────────────────────────────────────────────
//  GLOBAL RESET  —  any new fresh sweep while a setup is active wipes state
// ─────────────────────────────────────────────────────────────────────────────
// Once B1 is established (state 2 = FIND_C), new daily sweeps are IGNORED —
// the setup is locked until it completes (3) or is invalidated (4).
// Only reset in state 1 (B0 not yet broken), or after a completed / invalid setup.
do_reset = (st == 1 or st == 3 or st == 4) and new_sw

if do_reset
    line.delete(ln_A),  line.delete(ln_B0),  line.delete(ln_B1)
    line.delete(ln_F50), line.delete(ln_C),  line.delete(ln_SL),  line.delete(ln_TP)
    label.delete(lb_A), label.delete(lb_B0), label.delete(lb_B1)
    label.delete(lb_C), label.delete(lb_SL), label.delete(lb_TP)
    ln_A  := na, ln_B0  := na, ln_B1  := na, ln_F50 := na
    ln_C  := na, ln_SL  := na, ln_TP  := na
    lb_A  := na, lb_B0  := na, lb_B1  := na
    lb_C  := na, lb_SL  := na, lb_TP  := na
    st      := 0
    A_lvl   := na, A_bar   := na
    B0_lvl  := na, B0_bar  := na, B1_lvl  := na
    F50     := na, C_lvl   := na, SL_lvl  := na, TP_lvl  := na
    run_ext := na, best_c  := na, c_ret   := false, inv_th  := na

// ─────────────────────────────────────────────────────────────────────────────
//  STATE 0  —  IDLE
// ─────────────────────────────────────────────────────────────────────────────
if st == 0 and new_sw

    if new_bear_sw
        bear  := true
        A_lvl := swept_h
        A_bar := bar_index
        [b0_tmp, b0_bar_tmp, idx_tmp] = f_b0_bear(i_scan)
        if not na(b0_tmp)
            B0_lvl  := b0_tmp
            B0_bar  := b0_bar_tmp
            run_ext := f_max_hi(idx_tmp)   // highest high from B0 candle to sweep bar
            c_ret   := false
            best_c  := na
            st      := 1
            ln_A  := line.new(A_bar,  A_lvl,  bar_index + 60, A_lvl,
                 color = C_A, width = 1, style = line.style_dashed, extend = extend.both)
            lb_A  := label.new(A_bar, A_lvl, "A",
                 color = C_A, textcolor = color.black,
                 style = label.style_label_down, size = size.small)
            ln_B0 := line.new(B0_bar, B0_lvl, bar_index + 60, B0_lvl,
                 color = C_B0, width = 2, extend = extend.both)
            lb_B0 := label.new(B0_bar, B0_lvl, "B0",
                 color = C_B0, textcolor = color.black,
                 style = label.style_label_up, size = size.small)

    else if new_bull_sw
        bear  := false
        A_lvl := swept_l
        A_bar := bar_index
        [b0_tmp, b0_bar_tmp, idx_tmp] = f_b0_bull(i_scan)
        if not na(b0_tmp)
            B0_lvl  := b0_tmp
            B0_bar  := b0_bar_tmp
            run_ext := f_min_lo(idx_tmp)   // lowest low from B0 candle to sweep bar
            c_ret   := false
            best_c  := na
            st      := 1
            ln_A  := line.new(A_bar,  A_lvl,  bar_index + 60, A_lvl,
                 color = C_A, width = 1, style = line.style_dashed, extend = extend.both)
            lb_A  := label.new(A_bar, A_lvl, "A",
                 color = C_A, textcolor = color.black,
                 style = label.style_label_up, size = size.small)
            ln_B0 := line.new(B0_bar, B0_lvl, bar_index + 60, B0_lvl,
                 color = C_B0, width = 2, extend = extend.both)
            lb_B0 := label.new(B0_bar, B0_lvl, "B0",
                 color = C_B0, textcolor = color.black,
                 style = label.style_label_down, size = size.small)

// ─────────────────────────────────────────────────────────────────────────────
//  STATE 1  —  AWAIT B0 BREAK
//  Track running extreme (→ B1). Transition to state 2 when B0 breaks.
// ─────────────────────────────────────────────────────────────────────────────
else if st == 1
    if bear
        run_ext := math.max(run_ext, high)
        if low < B0_lvl
            B1_lvl := run_ext
            F50    := (B0_lvl + B1_lvl) / 2.0
            inv_th := B0_lvl - 3.0 * (B1_lvl - B0_lvl)
            best_c := na
            c_ret  := false
            st     := 2
            ln_B1  := line.new(A_bar, B1_lvl, bar_index + 60, B1_lvl,
                 color = C_B1, width = 1, style = line.style_dotted, extend = extend.both)
            lb_B1  := label.new(bar_index, B1_lvl, "B1",
                 color = C_B1, textcolor = color.white,
                 style = label.style_label_left, size = size.small)
            ln_F50 := line.new(A_bar, F50, bar_index + 60, F50,
                 color = C_F50, width = 1, style = line.style_dashed, extend = extend.both)
    else
        run_ext := math.min(run_ext, low)
        if high > B0_lvl
            B1_lvl := run_ext
            F50    := (B0_lvl + B1_lvl) / 2.0
            inv_th := B0_lvl + 3.0 * (B0_lvl - B1_lvl)
            best_c := na
            c_ret  := false
            st     := 2
            ln_B1  := line.new(A_bar, B1_lvl, bar_index + 60, B1_lvl,
                 color = C_B1, width = 1, style = line.style_dotted, extend = extend.both)
            lb_B1  := label.new(bar_index, B1_lvl, "B1",
                 color = C_B1, textcolor = color.white,
                 style = label.style_label_left, size = size.small)
            ln_F50 := line.new(A_bar, F50, bar_index + 60, F50,
                 color = C_F50, width = 1, style = line.style_dashed, extend = extend.both)

// ─────────────────────────────────────────────────────────────────────────────
//  STATE 2  —  FIND C
//  Watch candles that touch the 50 % fib.  Track best entry level.
// ─────────────────────────────────────────────────────────────────────────────
else if st == 2

    // ── Invalidation ────────────────────────────────────────────────────────
    bool invalidated = bear ? (low < inv_th) : (high > inv_th)

    if invalidated
        line.delete(ln_A),  line.delete(ln_B0),  line.delete(ln_B1)
        line.delete(ln_F50), line.delete(ln_C),  line.delete(ln_SL), line.delete(ln_TP)
        label.delete(lb_A), label.delete(lb_B0), label.delete(lb_B1)
        label.delete(lb_C), label.delete(lb_SL), label.delete(lb_TP)
        ln_A  := na, ln_B0  := na, ln_B1  := na, ln_F50 := na
        ln_C  := na, ln_SL  := na, ln_TP  := na
        lb_A  := na, lb_B0  := na, lb_B1  := na
        lb_C  := na, lb_SL  := na, lb_TP  := na
        st := 4

    else
        // ── 50 % fib touch ──────────────────────────────────────────────────
        bool fib_touch = low <= F50 and high >= F50

        if fib_touch and not c_ret
            if bear
                if low < B0_lvl
                    c_ret  := true
                    C_lvl  := B0_lvl
                    SL_lvl := B1_lvl
                    TP_lvl := C_lvl - 3.0 * (SL_lvl - C_lvl)
                else
                    best_c := na(best_c) ? low : math.min(best_c, low)
                    C_lvl  := best_c
                    SL_lvl := B1_lvl
                    TP_lvl := C_lvl - 3.0 * (SL_lvl - C_lvl)
            else
                if high > B0_lvl
                    c_ret  := true
                    C_lvl  := B0_lvl
                    SL_lvl := B1_lvl
                    TP_lvl := C_lvl + 3.0 * (C_lvl - SL_lvl)
                else
                    best_c := na(best_c) ? high : math.max(best_c, high)
                    C_lvl  := best_c
                    SL_lvl := B1_lvl
                    TP_lvl := C_lvl + 3.0 * (C_lvl - SL_lvl)

            // Redraw C / SL / TP whenever they update
            if not na(C_lvl)
                line.delete(ln_C),  line.delete(ln_SL), line.delete(ln_TP)
                label.delete(lb_C), label.delete(lb_SL), label.delete(lb_TP)
                string c_txt = c_ret ? "C  (await B0 retest)" : "C  ← Entry"
                ln_C  := line.new(bar_index, C_lvl,  bar_index + 60, C_lvl,
                     color = C_C, width = 2, extend = extend.both)
                lb_C  := label.new(bar_index, C_lvl, c_txt,
                     color = C_C, textcolor = color.black,
                     style = label.style_label_right, size = size.small)
                ln_SL := line.new(bar_index, SL_lvl, bar_index + 60, SL_lvl,
                     color = C_SL, width = 1,
                     style = line.style_dashed, extend = extend.both)
                lb_SL := label.new(bar_index, SL_lvl,
                     "SL  " + str.tostring(SL_lvl, format.mintick),
                     color = C_SL, textcolor = color.white,
                     style = label.style_label_right, size = size.tiny)
                ln_TP := line.new(bar_index, TP_lvl, bar_index + 60, TP_lvl,
                     color = C_TP, width = 1,
                     style = line.style_dashed, extend = extend.both)
                lb_TP := label.new(bar_index, TP_lvl,
                     "TP 1:3  " + str.tostring(TP_lvl, format.mintick),
                     color = C_TP, textcolor = color.white,
                     style = label.style_label_right, size = size.tiny)

        // ── Entry trigger ────────────────────────────────────────────────────
        if not na(C_lvl)
            bool triggered = false

            if c_ret
                // Retest mode: wait for price to re-touch B0
                triggered := high >= B0_lvl and low <= B0_lvl
                if triggered
                    C_lvl  := B0_lvl
                    SL_lvl := B1_lvl
                    TP_lvl := bear ? C_lvl - 3.0 * (SL_lvl - C_lvl) :
                                     C_lvl + 3.0 * (C_lvl - SL_lvl)
                    line.delete(ln_C),  line.delete(ln_SL), line.delete(ln_TP)
                    label.delete(lb_C), label.delete(lb_SL), label.delete(lb_TP)
                    ln_C  := line.new(bar_index, C_lvl,  bar_index + 60, C_lvl,
                         color = C_C, width = 2, extend = extend.both)
                    lb_C  := label.new(bar_index, C_lvl, "C  ← B0 Retest Entry",
                         color = C_C, textcolor = color.black,
                         style = label.style_label_right, size = size.small)
                    ln_SL := line.new(bar_index, SL_lvl, bar_index + 60, SL_lvl,
                         color = C_SL, width = 1,
                         style = line.style_dashed, extend = extend.both)
                    lb_SL := label.new(bar_index, SL_lvl,
                         "SL  " + str.tostring(SL_lvl, format.mintick),
                         color = C_SL, textcolor = color.white,
                         style = label.style_label_right, size = size.tiny)
                    ln_TP := line.new(bar_index, TP_lvl, bar_index + 60, TP_lvl,
                         color = C_TP, width = 1,
                         style = line.style_dashed, extend = extend.both)
                    lb_TP := label.new(bar_index, TP_lvl,
                         "TP 1:3  " + str.tostring(TP_lvl, format.mintick),
                         color = C_TP, textcolor = color.white,
                         style = label.style_label_right, size = size.tiny)
            else
                triggered := high >= C_lvl and low <= C_lvl

            if triggered
                st := 3
                string dir = bear ? "SHORT" : "LONG"
                alert(dir + " | Entry: "   + str.tostring(C_lvl,  format.mintick) +
                           " | SL: "       + str.tostring(SL_lvl, format.mintick) +
                           " | TP (1:3): " + str.tostring(TP_lvl, format.mintick),
                     alert.freq_once_per_bar)

// ─────────────────────────────────────────────────────────────────────────────
//  STATE 3 / 4  —  held until next fresh sweep triggers do_reset
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
//  DASHBOARD TABLE
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    var table dash = table.new(position.top_right, 2, 10,
         bgcolor      = color.new(color.black, 60),
         border_color = color.gray, border_width = 1,
         frame_color  = color.gray, frame_width  = 1)

    st_txt = st == 0 ? "IDLE"           :
             st == 1 ? "AWAIT B0 BREAK"  :
             st == 2 ? "FIND C"          :
             st == 3 ? "✓  ENTRY SET"    : "✗  INVALID"
    st_clr = st == 3 ? color.lime   :
             st == 4 ? color.red    :
             st == 0 ? color.gray   : color.orange

    dir_txt = bear ? "BEARISH  ▼" : "BULLISH  ▲"
    dir_clr = bear ? C_SL         : C_C

    table.cell(dash, 0, 0, "SMS Strategy", bgcolor = color.new(#1565C0, 30),
         text_color = color.white,  text_size = size.small)
    table.cell(dash, 1, 0, "30 min",        bgcolor = color.new(#1565C0, 30),
         text_color = color.silver, text_size = size.small)

    table.cell(dash, 0, 1, "State",      text_color = color.silver,  text_size = size.tiny)
    table.cell(dash, 1, 1, st_txt,       text_color = st_clr,        text_size = size.tiny)

    table.cell(dash, 0, 2, "Direction",  text_color = color.silver,  text_size = size.tiny)
    table.cell(dash, 1, 2, st == 0 ? "—" : dir_txt,
         text_color = st == 0 ? color.gray : dir_clr, text_size = size.tiny)

    table.cell(dash, 0, 3, "A",   text_color = C_A,  text_size = size.tiny)
    table.cell(dash, 1, 3, na(A_lvl)  ? "—" : str.tostring(A_lvl,  format.mintick),
         text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 4, "B0",  text_color = C_B0, text_size = size.tiny)
    table.cell(dash, 1, 4, na(B0_lvl) ? "—" : str.tostring(B0_lvl, format.mintick),
         text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 5, "B1",  text_color = C_B1, text_size = size.tiny)
    table.cell(dash, 1, 5, na(B1_lvl) ? "—" : str.tostring(B1_lvl, format.mintick),
         text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 6, "50 % Fib", text_color = C_F50, text_size = size.tiny)
    table.cell(dash, 1, 6, na(F50)    ? "—" : str.tostring(F50,    format.mintick),
         text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 7, "C  Entry", text_color = C_C,  text_size = size.tiny)
    table.cell(dash, 1, 7, na(C_lvl)  ? "—" : str.tostring(C_lvl,  format.mintick),
         text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 8, "Stop Loss", text_color = C_SL, text_size = size.tiny)
    table.cell(dash, 1, 8, na(SL_lvl) ? "—" : str.tostring(SL_lvl, format.mintick),
         text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 9, "TP  1:3",  text_color = C_TP, text_size = size.tiny)
    table.cell(dash, 1, 9, na(TP_lvl) ? "—" : str.tostring(TP_lvl, format.mintick),
         text_color = color.white, text_size = size.tiny)
````
