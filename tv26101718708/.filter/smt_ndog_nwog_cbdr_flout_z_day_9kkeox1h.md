# SMT - NDOG - NWOG - CBDR - FLOUT - Z DAY

- url: https://www.tradingview.com/script/9KKEoX1h-SMT-NDOG-NWOG-CBDR-FLOUT-Z-DAY/
- type: indicator
- pine_id: PUB;bb58d999a17e45c78f71ef3cc2dc9308
- version: 1.0

## Description

Here is a simple breakdown of how it works and how to use it:

1. Z-Day Profile (The "Coiled Spring")
What it is: A Z-Day is an ICT concept representing a day of extreme consolidation where the market essentially goes nowhere (zero net change). How the script tracks it: The script calculates the Average Daily Range (ADR) over the last 14 days. If a trading day finishes and its total range was less than 50% of the normal ADR, the script stamps a yellow "Z-DAY" label at the start of the next day. How to use it: When you see a Z-Day label, expect massive, violent expansion (trend days) to occur shortly after, as institutional energy has been tightly coiled.

2. SMT Divergence (Smart Money Tool)
What it is: SMT spots fake moves or underlying strength/weakness by comparing two assets that should move together (like NQ and ES). How the script tracks it: You enter a correlated ticker in the settings (e.g., CME_MINI:ES1!). The script pulls that asset's data in the background. It then tracks swing highs and lows on both charts simultaneously. How to use it: If your current chart makes a Lower Low (sweeping liquidity), but the hidden SMT chart makes a Higher Low, the script flags this as a Bullish SMT. It means the down-move on your chart is likely a fake stop-hunt, and price is preparing to reverse upward.

3. Price Action Gaps (NDOG & NWOG)
What it is: Voids in price caused by the market closing and reopening. These gaps act as algorithmic magnets. How the script tracks it:

NDOG (New Day Opening Gap): Tracks the gap between the 5:00 PM EST close and the 6:00 PM EST reopen.

NWOG (New Week Opening Gap): Tracks the gap between Friday's close and Sunday's reopen. How to use it: The script draws colored boxes over these gaps and extends them endlessly to the right. The box will only disappear once price completely overlaps and "fills" the gap, allowing you to use them as high-probability draw-on-liquidity targets.

4. Dealer Ranges & Projections (CBDR & Asian)
What it is: Institutions accumulate orders during specific quiet hours (Dealer Ranges), and then manipulate or expand price outward based on those ranges. How the script tracks it:

It boxes the absolute High and Low printed during the CBDR (Central Bank Dealers Range, 14:00-20:00 NY time).

It boxes the absolute High and Low printed during the Asian Range (20:00-00:00 NY time). 

How to use it: The exact moment the Asian Range finishes at midnight, the script measures the height of the CBDR box. It then projects Fibonacci Standard Deviation lines (+1, +2, -1, -2) out into the future. You use these dashed lines as algorithmic take-profit targets for the new trading day.

It also calculates the Flout, which combines the CBDR and Asian ranges together, cuts them in half, and projects dotted lines for alternate target projections.

## Source Code

````pine
//@version=6
indicator("SMT - NDOG - NWOG - CBDR - FLOUT - Z DAY", overlay=true, max_boxes_count=500, max_lines_count=500)

// =====================================================================
// Advanced Intermarket & Dealer Range Dynamics
// Covers: SMT Divergence, NWOG/NDOG Gaps, Standard Deviations,
// CBDR, Flout Projections, and Z-Day Profiles.
// =====================================================================

// --- Inputs ---
grp_smt = "SMT Divergence"
use_smt = input.bool(true, "Show SMT Divergence", group=grp_smt)
smt_ticker = input.symbol("CME_MINI:ES1!", "Correlated Asset (e.g. ES, NQ, DXY)", group=grp_smt)
smt_bull_col = input.color(color.green, "Bullish SMT Color", group=grp_smt)
smt_bear_col = input.color(color.red, "Bearish SMT Color", group=grp_smt)

grp_gap = "Opening Gaps (NDOG/NWOG)"
use_gap = input.bool(true, "Show NDOG / NWOG", group=grp_gap)
col_ndog = input.color(color.new(color.orange, 80), "NDOG Color", group=grp_gap)
col_nwog = input.color(color.new(color.fuchsia, 80), "NWOG Color", group=grp_gap)

grp_rng = "Dealer Ranges & SD Projections"
use_cbdr = input.bool(true, "Show CBDR (14:00-20:00 NY)", group=grp_rng)
use_asian = input.bool(true, "Show Asian Range (20:00-00:00 NY)", group=grp_rng)
use_flout = input.bool(true, "Show Flout Projections", group=grp_rng)
col_cbdr = input.color(color.new(color.blue, 90), "CBDR Box Color", group=grp_rng)
col_asian = input.color(color.new(color.purple, 90), "Asian Box Color", group=grp_rng)
col_sd = input.color(color.new(color.gray, 0), "SD Line Color", group=grp_rng)

grp_z = "Z-Day Profile"
use_zday = input.bool(true, "Flag Z-Days (<50% ADR)", group=grp_z)

// =====================================================================
// 1. Z-DAY PROFILE
// =====================================================================
// Checks if the previous day was an intense consolidation day (a coiled spring)
dr = request.security(syminfo.tickerid, "D", high - low, lookahead=barmerge.lookahead_on)
adr = request.security(syminfo.tickerid, "D", ta.sma(high - low, 14), lookahead=barmerge.lookahead_on)

is_new_day = nz(ta.change(time("D"))) != 0 or barstate.isfirst

if use_zday and is_new_day and not barstate.isfirst
    if dr[1] < adr[1] * 0.5
        label.new(bar_index[1], high[1], "Z-DAY\n(Consolidation)", style=label.style_label_down, color=color.new(color.yellow,0), textcolor=color.black, size=size.small)

// =====================================================================
// 2. SMT DIVERGENCE
// =====================================================================
[smt_h, smt_l] = request.security(smt_ticker, timeframe.period, [high, low])

pl = ta.pivotlow(low, 5, 5)
ph = ta.pivothigh(high, 5, 5)
smt_pl = ta.pivotlow(smt_l, 5, 5)
smt_ph = ta.pivothigh(smt_h, 5, 5)

var float last_ph = na
var float last_pl = na
var float last_smt_ph = na
var float last_smt_pl = na

if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl
if not na(smt_ph)
    last_smt_ph := smt_ph
if not na(smt_pl)
    last_smt_pl := smt_pl

if use_smt
    // Bearish Divergence: Current makes HH, Correlated makes LH (or vice versa)
    if not na(ph) and not na(smt_ph)
        if ph > last_ph and smt_ph < last_smt_ph
            label.new(bar_index[5], high[5], "SMT Bearish", style=label.style_label_down, color=color.new(color.white,100), textcolor=smt_bear_col, size=size.tiny)
        else if ph < last_ph and smt_ph > last_smt_ph
            label.new(bar_index[5], high[5], "SMT Bearish", style=label.style_label_down, color=color.new(color.white,100), textcolor=smt_bear_col, size=size.tiny)

    // Bullish Divergence: Current makes LL, Correlated makes HL (or vice versa)
    if not na(pl) and not na(smt_pl)
        if pl < last_pl and smt_pl > last_smt_pl
            label.new(bar_index[5], low[5], "SMT Bullish", style=label.style_label_up, color=color.new(color.white,100), textcolor=smt_bull_col, size=size.tiny)
        else if pl > last_pl and smt_pl < last_smt_pl
            label.new(bar_index[5], low[5], "SMT Bullish", style=label.style_label_up, color=color.new(color.white,100), textcolor=smt_bull_col, size=size.tiny)

// =====================================================================
// 3. NDOG / NWOG (Price Action Gaps)
// =====================================================================
type Gap
    box b
    float top
    float bot

var gaps = array.new<Gap>()

if use_gap and is_new_day and not barstate.isfirst
    gap_top = math.max(close[1], open)
    gap_bot = math.min(close[1], open)
    if gap_top > gap_bot // A gap exists
        // Check if it's Sunday opening (NWOG)
        is_sunday = dayofweek(time, "America/New_York") == dayofweek.sunday
        is_monday = dayofweek(time, "America/New_York") == dayofweek.monday
        is_nwog = is_sunday or (is_monday and dayofweek(time[1], "America/New_York") == dayofweek.friday)
        
        col = is_nwog ? col_nwog : col_ndog
        txt = is_nwog ? "NWOG" : "NDOG"
        
        b = box.new(bar_index[1], gap_top, bar_index, gap_bot, bgcolor=col, border_color=na, text=txt, text_color=color.new(col,0), text_size=size.tiny)
        array.push(gaps, Gap.new(b, gap_top, gap_bot))

// Extend gaps until filled
if array.size(gaps) > 0
    for i = array.size(gaps) - 1 to 0
        g = array.get(gaps, i)
        box.set_right(g.b, bar_index)
        
        // Fill logic: If the candle closes beyond the midpoint of the gap, it's considered filled.
        mid = (g.top + g.bot) / 2
        if (open > mid and close < mid) or (open < mid and close > mid)
            // Filled! Stop extending to the right.
            array.remove(gaps, i)

// Garbage collection for gaps
if array.size(gaps) > 50
    g = array.shift(gaps)
    box.delete(g.b)

// =====================================================================
// 4. DEALER RANGES (CBDR, Asian, Flout, Standard Deviations)
// =====================================================================
in_cbdr = time(timeframe.period, "1400-2000", "America/New_York")
in_asian = time(timeframe.period, "2000-0000", "America/New_York")

var float cbdr_h = na
var float cbdr_l = na
var int cbdr_start = na

var float asian_h = na
var float asian_l = na
var int asian_start = na

var line[] active_sd_lines = array.new_line()
var box active_cbdr = na
var box active_asian = na

// --- CBDR Logic ---
if not na(in_cbdr) and na(in_cbdr[1]) // Start of CBDR window
    cbdr_h := high
    cbdr_l := low
    cbdr_start := bar_index
    if use_cbdr
        active_cbdr := box.new(cbdr_start, cbdr_h, bar_index, cbdr_l, bgcolor=col_cbdr, border_color=col_cbdr, text="CBDR", text_size=size.tiny)
else if not na(in_cbdr) // During CBDR window
    cbdr_h := math.max(cbdr_h, high)
    cbdr_l := math.min(cbdr_l, low)
    if use_cbdr and not na(active_cbdr)
        box.set_top(active_cbdr, cbdr_h)
        box.set_bottom(active_cbdr, cbdr_l)
        box.set_right(active_cbdr, bar_index)

// --- Asian Range Logic ---
if not na(in_asian) and na(in_asian[1]) // Start of Asian window
    asian_h := high
    asian_l := low
    asian_start := bar_index
    if use_asian
        active_asian := box.new(asian_start, asian_h, bar_index, asian_l, bgcolor=col_asian, border_color=col_asian, text="Asian", text_size=size.tiny)
else if not na(in_asian) // During Asian window
    asian_h := math.max(asian_h, high)
    asian_l := math.min(asian_l, low)
    if use_asian and not na(active_asian)
        box.set_top(active_asian, asian_h)
        box.set_bottom(active_asian, asian_l)
        box.set_right(active_asian, bar_index)

// --- Project Standard Deviations & Flout ---
// We project these exactly when the Asian session ends.
if na(in_asian) and not na(in_asian[1])
    // Clear out yesterday's active tracking lines (they remain on chart, but stop extending)
    array.clear(active_sd_lines)
        
    cbdr_range = cbdr_h - cbdr_l
    
    // Project CBDR Standard Deviations (+1, +2, -1, -2)
    if use_cbdr
        l1 = line.new(bar_index, cbdr_h + cbdr_range, bar_index+50, cbdr_h + cbdr_range, color=col_sd, style=line.style_dashed)
        l2 = line.new(bar_index, cbdr_h + cbdr_range*2, bar_index+50, cbdr_h + cbdr_range*2, color=col_sd, style=line.style_dashed)
        l3 = line.new(bar_index, cbdr_l - cbdr_range, bar_index+50, cbdr_l - cbdr_range, color=col_sd, style=line.style_dashed)
        l4 = line.new(bar_index, cbdr_l - cbdr_range*2, bar_index+50, cbdr_l - cbdr_range*2, color=col_sd, style=line.style_dashed)
        array.push(active_sd_lines, l1)
        array.push(active_sd_lines, l2)
        array.push(active_sd_lines, l3)
        array.push(active_sd_lines, l4)

    // Flout Logic (Combined Range / 2)
    if use_flout
        flout_h = math.max(cbdr_h, asian_h)
        flout_l = math.min(cbdr_l, asian_l)
        flout_range = flout_h - flout_l
        half_flout = flout_range / 2
        
        f1 = line.new(bar_index, flout_h + half_flout, bar_index+50, flout_h + half_flout, color=color.purple, style=line.style_dotted)
        f2 = line.new(bar_index, flout_l - half_flout, bar_index+50, flout_l - half_flout, color=color.purple, style=line.style_dotted)
        array.push(active_sd_lines, f1)
        array.push(active_sd_lines, f2)

// Extend active SD lines rightward throughout the new day until the next CBDR begins
if array.size(active_sd_lines) > 0 and na(in_cbdr)
    for i = 0 to array.size(active_sd_lines) - 1
        l = array.get(active_sd_lines, i)
        line.set_x2(l, bar_index)
````
