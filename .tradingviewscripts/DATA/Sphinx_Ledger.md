<!-- tradingview-pine-id: PUB;254ba9ee561a402aa5b625ca43723a01 -->
<!-- tradingviewscripts-format: 1 -->
# Sphinx Ledger

Source: https://www.tradingview.com/script/morEUVtW-Sphinx-Ledger-Intrabar-Volume-Profile-with-Delta-Split/

## Description

SPHINX LEDGER - Intrabar Volume Profile with Slice-Level Delta

OVERVIEW

Sphinx Ledger is a volume profile that is built from intrabar data instead of chart bars, and that can be anchored either to the trading session or to a rolling multi-day window. It renders a right-edge histogram, a developing POC, a Value Area, and an optional faded backdrop of prior sessions, with every profile row split into its buy and sell components.

The intent is to answer two questions on the same chart: where has volume actually built up, and who was in control at each of those prices.

WHAT IT DOES DIFFERENTLY

Most Pine volume profiles distribute each chart bar's volume evenly across that bar's entire high-low range. On a 1m bar that is a coarse approximation: a bar with a 12 point range smears its volume across all 12 points even if almost all of it traded in a 2 point pocket. High volume shelves get blurred and low volume vacuums get filled in.

Sphinx Ledger instead pulls the intrabar slices inside each chart bar (5 second by default) and bins each slice against its own tight range. Roughly twelve placements per 1m bar rather than one. HVN shelves and LVN gaps resolve much closer to what a native session volume profile shows.

The same slice structure drives the delta split. Each 5 second slice carries its own direction from its own open and close, so the buy/sell proportion inside a row reflects intrabar order flow rather than assigning one direction to a whole 1m bar. A 1m bar that opens low, runs up and closes flat contributes both sides in the correct places instead of registering as a single doji.

HOW THE PROFILE IS CALCULATED

1. Anchor. In Session mode the profile clears at the 20:00 ET reset and rebuilds through the day. In Rolling mode it never clears; each confirmed chart bar is tagged with a day index and entries older than the chosen window are aged out on each new day. Auto mode selects Session below the 1 hour timeframe and Rolling at 1 hour and above.

2. Range and bins. The running high and low of the anchor window are tracked and divided into the configured number of rows. Row height = (window high - window low) / rows.

3. Binning. Each entry (a 5 second slice in Session mode, a chart bar in Rolling mode) is assigned to the rows its high-low range spans, and its volume is divided evenly across those rows. Direction is taken from that entry's own close versus open: up adds to the buy array, down adds to the sell array, an unchanged entry splits 50/50.

4. Range expansion. When a new bar extends the window high or low, bin width changes, so the entire retained history is re-binned from scratch. When the range is unchanged, new slices are added incrementally. This keeps the profile exact rather than drifting as the day expands, without rebuilding on every bar.

5. POC. The row holding the most volume. The plotted price is the midpoint of that row.

6. Value Area. Starting from the POC row, the profile expands outward one row at a time, always taking the higher-volume neighbour, until the accumulated volume reaches the configured percentage of total window volume. VAH is the top edge of the highest included row, VAL is the bottom edge of the lowest.

7. Prior sessions. At each Session-mode reset the completed profile is resampled to the overlay resolution and pushed into a rolling buffer of up to ten days, then drawn behind the live histogram with opacity fading by age.

THE DELTA RENDERING

With delta fill on, each row's bar is divided horizontally in proportion to its buy and sell volume, green on the left, red on the right. The split shows who won at that price. The intensity gradient then maps the absolute delta of the row to opacity: lopsided rows render bright, balanced rows render dim. Together the two convey both direction and conviction per price level, which a single-colour profile cannot.

Reading it in practice:
- A wide row that is heavily one-sided is a shelf that was taken by one side and tends to act as support or resistance on the retest.
- A wide row that is close to balanced is genuine two-sided acceptance, more likely to be chop and a magnet than a turning point.
- A narrow row is a vacuum. Price crossing it usually crosses fast.
- Repeated returns into a one-sided shelf that fail to move it are an absorption read.

SETTINGS

Main
- Timezone: session anchoring reference.
- Profile resolution: number of price bins. Higher gives finer POC precision at more compute cost.
- Profile intrabar resolution: the lower timeframe sampled inside each chart bar. 5S is the default. Falls back to the chart bar automatically if the LTF is not served.
- Value Area percent: standard is 70.

Profile Period
- Anchor mode: Auto, Session (intraday, intrabar slices), or Rolling (HTF composite from chart bars).
- Rolling window days: how many days composite into one profile in Rolling mode. 20 approximates the current swing on a daily chart.

Position
- Histogram right offset and POC/VA line right offset control how far right of the current bar the drawings anchor. Large values need matching right margin in TradingView's chart settings under Scales, Margins, Right.

Histogram
- Show histogram, colour source, opacity, width in bars, optional vertical padding.
- Delta fill, buy and sell colours, delta intensity gradient.

Prior Days
- Overlay on/off, overlay resolution, number of days, colour, newest-day opacity.

POC, Value Area, Labels
- Independent colour, style, width, optional Value Area shading, label size.

HOW TO USE IT

On intraday charts leave the anchor on Auto or set Session. The developing POC is the day's fair value reference: price above it with the POC holding on retests is acceptance higher, price rejecting from below is the opposite. VAH and VAL frame the accepted range, and the first move outside them either accepts and continues or reverts, which is the decision point. LVN gaps between shelves are where fast moves travel.

On 1 hour and above, use Rolling. A single-session profile on a daily chart describes one day and usually plots far from current price, which is not useful. The rolling composite instead describes the current swing, so the POC and Value Area land where price is actually trading.

The prior-day backdrops are for locating shelves that persist across sessions. A level that was an HVN on three consecutive days carries more weight than one that formed this morning.

ALERTS

Six conditions are available, all on the developing values: price crossing above or below POC, VAH, and VAL.

LIMITATIONS AND NOTES

- Volume inside a single slice is distributed evenly across that slice's range. At 5 second resolution the range is small enough that this is close to true placement, but it is still a distribution, not tick-by-tick data.
- Intrabar requests are limited by TradingView on long histories. On charts with a very large number of bars, older bars may not return slices and will fall back to chart-bar placement.
- Sub-minute intrabar data availability depends on your data plan and on the symbol. If 5S is unavailable the script degrades gracefully to the chart bar.
- Pine allows a maximum of 500 boxes. Days shown multiplied by overlay resolution should stay under roughly 450 to leave room for the live histogram, otherwise the oldest backdrops will drop off.
- Prior-day snapshots are captured at the Session-mode day reset. They do not accumulate in Rolling mode.
- On futures, volume comes from the contract being charted. Continuous contracts carry the roll, so profiles spanning a roll date mix contracts.
- The 20:00 ET day reset is the CME session boundary. On non-futures symbols the reset time may not correspond to a meaningful session break.
- This is an analysis tool. It does not generate buy or sell signals and nothing here is financial advice.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Sphinx Ledger — Dynamic POC + Delta Histogram + Multi-Day Overlay
// Version 3.1 — anchor modes: Session (5S intraday) + Rolling (N-day HTF composite)
//
// Change from v2.9:
//   - PROFILE NOW BUILT FROM 5S INTRABARS, not 1m bars. Each chart bar's
//     volume was previously smeared evenly across the bar's whole high-low
//     range (a 1m-bar approximation). Now request.security_lower_tf pulls
//     the 5-second slices inside each chart bar and each fine slice places
//     its own volume at its own tight range — resolving HVN shelves / LVN
//     vacuums to ~TradingView SVP fidelity. ~12 slices per 1m bar.
//   - Delta split is now SLICE-LEVEL: each 5S slice carries its own
//     direction (close>open) so the buy/sell histogram and intensity
//     gradient reflect true intrabar order flow, not one direction per
//     whole 1m bar.
//   - New input "Profile intrabar resolution" (default 5S). Falls back to
//     the chart bar automatically if the data plan doesn't serve the LTF.
//   - The bar-history arrays (bar_los/his/vols/dirs) now hold SLICE entries
//     rather than bar entries. _rebuild_profile / _add_bar_to_profile are
//     unchanged — they're agnostic to whether an entry is a bar or a slice,
//     so POC, VA, the delta histogram, and the prior-day snapshot all
//     upgrade automatically.
//   - Correctness: the day-range update now runs before binning and the
//     expand test reads the prior bar's range, so the first slice of an
//     expanding bar bins into the correct (already-widened) range.
//
//@version=6
indicator('Sphinx Ledger', shorttitle = 'Sphinx Ledger', overlay = true, max_lines_count = 20, max_labels_count = 20, max_boxes_count = 500)

// ============================================================
// === INPUTS ===
// ============================================================
g_main = 'Main'
g_pos = 'Position (right-side)'
g_hist = 'Histogram'
g_poc = 'POC'
g_va = 'Value Area'
g_lbl = 'Labels'

i_tz = input.string('America/New_York', '⠀Timezone', group = g_main, options = ['America/New_York', 'America/Chicago', 'Europe/London', 'Europe/Berlin', 'Asia/Tokyo'])
i_rows = input.int(80, '⠀Profile resolution (rows)', group = g_main, minval = 20, maxval = 250, tooltip = 'Number of price bins for the volume profile. Higher = finer POC precision, more compute. 80 is a good balance.')
i_prof_ltf = input.timeframe('5S', '⠀Profile intrabar resolution', group = g_main, tooltip = 'Lower timeframe sampled inside each chart bar to place volume where it actually traded, instead of smearing a 1m bar across its whole range. 5S ≈ TradingView SVP granularity. Falls back to the chart bar if your data plan doesn\'t serve it.')
i_va_pct = input.float(70.0, '⠀Value Area %', group = g_main, minval = 50.0, maxval = 95.0, step = 1.0, tooltip = 'Percentage of total day volume contained in the Value Area (between VAL and VAH). Standard is 70%.')

// Profile period / anchor — how the profile's time window is defined.
g_anchor = 'Profile Period'
anchor_mode = input.string('Auto (by timeframe)', '⠀Anchor mode', group = g_anchor, options = ['Auto (by timeframe)', 'Session — intraday (5S)', 'Rolling — HTF composite'], tooltip = 'Session (intraday): the profile clears each day at the 20:00 ET reset and is built from 5-second intrabar slices — use on 1m–15m charts for SVP-fidelity intraday value. Rolling (HTF): a trailing N-day composite that never clears mid-window, built from chart bars — use on 1H/4H/1D so the POC/VA describe the CURRENT SWING (and land near price) instead of one session. Auto picks Session below 1H and Rolling at 1H and above.')
roll_days = input.int(20, '⠀Rolling window (days)', group = g_anchor, minval = 2, maxval = 120, tooltip = 'In Rolling (HTF) mode, how many days of volume to composite into one profile. 20 ≈ the current swing on a daily chart. Larger = a broader, slower-moving value picture; smaller = tighter to the most recent leg.')

// Position controls — how far right of current price the histogram and lines render.
hist_right_offset = input.int(10, '⠀Histogram right offset (bars)', group = g_pos, minval = 0, maxval = 2000, tooltip = 'How far right of the current bar to anchor the histogram bulges. 0 = flush with current bar. Higher values push the histogram further right (requires sufficient chart right margin in TradingView\'s chart settings).')
i_extend_bars = input.int(50, '⠀POC/VA line right offset (bars)', group = g_pos, minval = 0, maxval = 2000, tooltip = 'How far right of the current bar the POC/VAH/VAL lines extend. Increase to push the line labels further right. Requires sufficient chart right margin in TradingView\'s chart settings (Scales → Margins → Right).')

// Histogram (right-edge live volume profile)
show_hist = input.bool(true, '⠀Show histogram', group = g_hist)
hist_use_poc_col = input.bool(true, '⠀Match POC color', group = g_hist, tooltip = 'When ON, histogram uses POC\'s color. When OFF, uses the custom color below.')
hist_col_custom = input.color(#9c27b0, '⠀Custom color', group = g_hist, tooltip = 'Only used when \'Match POC color\' is OFF.')
hist_op = input.int(70, '⠀Opacity', group = g_hist, minval = 0, maxval = 95, tooltip = '0 = solid, 95 = nearly invisible.')
hist_width_bars = input.int(30, '⠀Histogram width (bars)', group = g_hist, minval = 5, maxval = 200, tooltip = 'Width of the histogram bulges in bars. Larger = more visual weight.')
hist_pad_pct = input.float(0.0, '⠀Vertical padding %', group = g_hist, minval = 0.0, maxval = 50.0, step = 2.5, tooltip = 'Optional padding above and below the day\'s actual H/L. 0% = true to data (recommended). 10–25% = inflates histogram visually if the day\'s range feels small.')

// Delta fill (two-tone histogram with buy/sell split + intensity)
delta_mode = input.bool(true, '⠀Show delta fill (CVD)', group = g_hist, tooltip = 'When ON, each row is split into buy and sell portions: buy volume rendered green, sell volume rendered red. The proportion shows who won at that price. When OFF, the histogram uses a single color (POC color or custom).')
col_buy = input.color(#089981, '⠀Buy color (green)', group = g_hist)
col_sell = input.color(#f44336, '⠀Sell color (red)', group = g_hist)
delta_intensity = input.bool(true, '⠀Delta intensity gradient', group = g_hist, tooltip = 'When ON, rows with stronger absolute delta (more lopsided buy vs sell) render brighter. Quiet/balanced rows render dimmer. Adds magnitude information on top of the proportion split. When OFF, all rows use full opacity.')

// Prior-day overlay (gray backdrop showing previous N days' profiles)
g_prev = 'Prior Days'
show_prev = input.bool(true, '⠀Show prior-day overlay', group = g_prev, tooltip = 'Renders the last N days\' volume profiles as faint backdrops behind today\'s histogram. Useful for spotting persistent HVNs/LVNs that today\'s price may interact with.')
prev_rows = input.int(80, '⠀Overlay resolution (rows)', group = g_prev, minval = 20, maxval = 200, tooltip = 'Price bins per prior-day backdrop. Higher = finer detail. Total boxes ≈ days shown × resolution, so high values combined with many days can exceed Pine\'s 500-box limit (oldest boxes then drop off / backdrops vanish). Rule of thumb: keep (days shown × resolution) under ~450 to leave room for today\'s histogram.')
prev_days = input.int(5, '⠀Days to show', group = g_prev, minval = 1, maxval = 10, tooltip = 'How many prior days to render as backdrops. Each day fades with age — newest day at full opacity, oldest day faded toward invisible. Higher counts use more rendering budget; if you also have a wide histogram, very high counts may approach the 500-box Pine limit.')
prev_col = input.color(#999999, '⠀Overlay color', group = g_prev, tooltip = 'Color for the prior-day backdrops. Default is light gray.')
prev_op = input.int(80, '⠀Newest day opacity', group = g_prev, minval = 50, maxval = 95, tooltip = 'Opacity of the most recent prior day. Higher value = more transparent. Older days are progressively faded from this value toward 95 (nearly invisible).')

// POC
show_poc = input.bool(true, '⠀Show POC line', group = g_poc, inline = 'p1')
col_poc = input.color(#9c27b0, '⠀Color', group = g_poc, inline = 'p1')
sty_poc = input.string('Solid', '⠀Line style', group = g_poc, options = ['Solid', 'Dashed', 'Dotted'])
wid_poc = input.int(2, '⠀Width', group = g_poc, minval = 1, maxval = 4)

// Value Area (VAH + VAL together)
show_va = input.bool(true, '⠀Show Value Area (VAH/VAL)', group = g_va, inline = 'v1')
col_va = input.color(color.new(#9c27b0, 30), '⠀Color', group = g_va, inline = 'v1')
sty_va = input.string('Dashed', '⠀Line style', group = g_va, options = ['Solid', 'Dashed', 'Dotted'])
wid_va = input.int(1, '⠀Width', group = g_va, minval = 1, maxval = 4)
fill_va = input.bool(false, '⠀Shade Value Area between VAH and VAL', group = g_va)
col_va_fill = input.color(color.new(#9c27b0, 92), '⠀Shade color', group = g_va)

// Labels
show_lbls = input.bool(true, '⠀Show line labels (POC / VAH / VAL)', group = g_lbl)
lbl_size = input.string('small', '⠀Label size', group = g_lbl, options = ['tiny', 'small', 'normal'])

// ============================================================
// === DAY ANCHOR — 20:00 ET (matches Trinity day reset) ===
// ============================================================
in_day_open = not na(time(timeframe.period, '2000-2002', i_tz))
is_day_reset = in_day_open and not in_day_open[1]

// --- effective anchor mode (rolling for HTF, session/5S for intraday) ---
float _tf_min = timeframe.in_seconds(timeframe.period) / 60.0
bool use_rolling = anchor_mode == 'Rolling — HTF composite' or anchor_mode == 'Auto (by timeframe)' and _tf_min >= 60.0
// --- timeframe-robust day boundary (fires on the first bar of each new session,
//     works identically on 1m … 1D, unlike the 20:00 minute-window which never
//     lands on a daily bar). Used to age out the rolling window. ---
bool _new_day = ta.change(time('D')) != 0
var int day_count = 0
if _new_day
    day_count := day_count + 1
    day_count

// ============================================================
// === STYLE HELPERS ===
// ============================================================
_sty(s) =>
    s == 'Dashed' ? line.style_dashed : s == 'Dotted' ? line.style_dotted : line.style_solid
_lblsz(s) =>
    s == 'tiny' ? size.tiny : s == 'small' ? size.small : size.normal

// ============================================================
// === STATE ===
// ============================================================
var array<float> vol_arr = array.new_float(250, 0.0)
var array<float> buy_arr = array.new_float(250, 0.0)
var array<float> sell_arr = array.new_float(250, 0.0)
var float day_lo = na
var float day_hi = na
var float poc_p = na
var float vah_p = na
var float val_p = na

// Drawing handles
var line ln_poc = na
var line ln_vah = na
var line ln_val = na
var label lb_poc = na
var label lb_vah = na
var label lb_val = na
var box bx_va = na

// Histogram boxes (one per row that has volume)
var array<box> hist_boxes = array.new_box()

// Per-slice accumulator: stores history of (lo, hi, vol, dir) since day reset.
// Entries are now 5S INTRABAR SLICES (v3.0), not 1m bars. We re-bin the whole
// history when the day's range expands, so we need the raw slice data to redo
// the binning accurately.
var array<float> bar_los = array.new_float()
var array<float> bar_his = array.new_float()
var array<float> bar_vols = array.new_float()
var array<int> bar_dirs = array.new_int() // 1 = up slice (buy), -1 = down slice (sell), 0 = doji (split)
var array<int> bar_days = array.new_int() // day-index tag per entry (rolling mode: drop entries older than roll_days)

// Prior-day snapshots — rolling buffer of the last N days.
const int MAX_PREV_DAYS = 10
const int MAX_PREV_ROWS = 200
var array<float> prev_vol_flat = array.new_float(MAX_PREV_DAYS * MAX_PREV_ROWS, 0.0)
var array<float> prev_day_los = array.new_float(MAX_PREV_DAYS, na)
var array<float> prev_day_his = array.new_float(MAX_PREV_DAYS, na)
var array<int> prev_day_rows = array.new_int(MAX_PREV_DAYS, 0)
var array<box> prev_boxes = array.new_box()

// 5S intrabar slices for the current chart bar — high/low/volume/open/close so
// each fine slice carries its own direction for the delta split. Falls back to
// the chart bar downstream if the LTF isn't served (empty array).
[_iihi, _iilo, _iivol, _iiopen, _iiclose] = request.security_lower_tf(syminfo.tickerid, i_prof_ltf, [high, low, volume, open, close])

// ============================================================
// === BIN / RECOMPUTE ===
// ============================================================
_rebuild_profile() =>
    for r = 0 to i_rows - 1 by 1
        array.set(vol_arr, r, 0.0)
        array.set(buy_arr, r, 0.0)
        array.set(sell_arr, r, 0.0)
    if not na(day_lo) and not na(day_hi) and day_hi > day_lo
        float row_h = (day_hi - day_lo) / i_rows
        if row_h > 0 and array.size(bar_los) > 0
            int n = array.size(bar_los)
            for i = 0 to n - 1 by 1
                float blo = array.get(bar_los, i)
                float bhi = array.get(bar_his, i)
                float bvol = array.get(bar_vols, i)
                int bdir = array.get(bar_dirs, i)
                if bvol > 0
                    int first_row = math.max(0, int(math.floor((blo - day_lo) / row_h)))
                    int last_row = math.min(i_rows - 1, int(math.floor((bhi - day_lo) / row_h)))
                    int n_rows = last_row - first_row + 1
                    if n_rows > 0
                        float share = bvol / n_rows
                        for r = first_row to last_row by 1
                            array.set(vol_arr, r, array.get(vol_arr, r) + share)
                            if bdir > 0
                                array.set(buy_arr, r, array.get(buy_arr, r) + share)
                            else if bdir < 0
                                array.set(sell_arr, r, array.get(sell_arr, r) + share)
                            else
                                array.set(buy_arr, r, array.get(buy_arr, r) + share / 2)
                                array.set(sell_arr, r, array.get(sell_arr, r) + share / 2)

_add_bar_to_profile(blo, bhi, bvol, bdir) =>
    if not na(day_lo) and not na(day_hi) and day_hi > day_lo and bvol > 0
        float row_h = (day_hi - day_lo) / i_rows
        if row_h > 0
            int first_row = math.max(0, int(math.floor((blo - day_lo) / row_h)))
            int last_row = math.min(i_rows - 1, int(math.floor((bhi - day_lo) / row_h)))
            int n_rows = last_row - first_row + 1
            if n_rows > 0
                float share = bvol / n_rows
                for r = first_row to last_row by 1
                    array.set(vol_arr, r, array.get(vol_arr, r) + share)
                    if bdir > 0
                        array.set(buy_arr, r, array.get(buy_arr, r) + share)
                    else if bdir < 0
                        array.set(sell_arr, r, array.get(sell_arr, r) + share)
                    else
                        array.set(buy_arr, r, array.get(buy_arr, r) + share / 2)
                        array.set(sell_arr, r, array.get(sell_arr, r) + share / 2)

_find_poc() =>
    int idx = 0
    float best = 0.0
    for r = 0 to i_rows - 1 by 1
        v = array.get(vol_arr, r)
        if v > best
            best := v
            idx := r
            idx
    [idx, best]

_compute_va(poc_idx) =>
    float total = 0.0
    for r = 0 to i_rows - 1 by 1
        total := total + array.get(vol_arr, r)
        total
    float target = total * i_va_pct / 100.0
    float accum = array.get(vol_arr, poc_idx)
    int up = poc_idx
    int dn = poc_idx
    while accum < target and (up < i_rows - 1 or dn > 0)
        float v_up = up < i_rows - 1 ? array.get(vol_arr, up + 1) : -1.0
        float v_dn = dn > 0 ? array.get(vol_arr, dn - 1) : -1.0
        if v_up > v_dn
            up := up + 1
            accum := accum + v_up
            accum
        else if v_dn > v_up
            dn := dn - 1
            accum := accum + v_dn
            accum
        else if v_up >= 0
            up := up + 1
            accum := accum + v_up
            accum
        else if v_dn >= 0
            dn := dn - 1
            accum := accum + v_dn
            accum
        else
            break
    [up, dn]

// ============================================================
// === DAY RESET ===
// ============================================================
if is_day_reset and not use_rolling
    if not na(day_lo) and not na(day_hi) and day_hi > day_lo
        for d = MAX_PREV_DAYS - 1 to 1 by 1
            array.set(prev_day_los, d, array.get(prev_day_los, d - 1))
            array.set(prev_day_his, d, array.get(prev_day_his, d - 1))
            array.set(prev_day_rows, d, array.get(prev_day_rows, d - 1))
            for r = 0 to MAX_PREV_ROWS - 1 by 1
                _src_idx = (d - 1) * MAX_PREV_ROWS + r
                _dst_idx = d * MAX_PREV_ROWS + r
                array.set(prev_vol_flat, _dst_idx, array.get(prev_vol_flat, _src_idx))
        array.set(prev_day_los, 0, day_lo)
        array.set(prev_day_his, 0, day_hi)
        array.set(prev_day_rows, 0, prev_rows)
        float ratio = i_rows / float(prev_rows)
        for r = 0 to prev_rows - 1 by 1
            float src_start = r * ratio
            float src_end = (r + 1) * ratio
            int ss = int(math.floor(src_start))
            int se = math.min(i_rows - 1, int(math.floor(src_end)))
            float accum = 0.0
            int ct = 0
            for sr = ss to se by 1
                accum := accum + array.get(vol_arr, sr)
                ct := ct + 1
                ct
            float avg = ct > 0 ? accum / ct : 0.0
            array.set(prev_vol_flat, r, avg)
    array.clear(bar_los)
    array.clear(bar_his)
    array.clear(bar_vols)
    array.clear(bar_dirs)
    array.clear(bar_days)
    for r = 0 to i_rows - 1 by 1
        array.set(vol_arr, r, 0.0)
        array.set(buy_arr, r, 0.0)
        array.set(sell_arr, r, 0.0)
    day_lo := na
    day_hi := na
    poc_p := na
    vah_p := na
    val_p := na
    if not na(ln_poc)
        ln_poc.delete()
        ln_poc := na
        ln_poc
    if not na(ln_vah)
        ln_vah.delete()
        ln_vah := na
        ln_vah
    if not na(ln_val)
        ln_val.delete()
        ln_val := na
        ln_val
    if not na(lb_poc)
        lb_poc.delete()
        lb_poc := na
        lb_poc
    if not na(lb_vah)
        lb_vah.delete()
        lb_vah := na
        lb_vah
    if not na(lb_val)
        lb_val.delete()
        lb_val := na
        lb_val
    if not na(bx_va)
        bx_va.delete()
        bx_va := na
        bx_va
    if array.size(hist_boxes) > 0
        for i = 0 to array.size(hist_boxes) - 1 by 1
            box.delete(array.get(hist_boxes, i))
        array.clear(hist_boxes)

// ============================================================
// === ACCUMULATE + INCREMENTAL PROFILE UPDATE (5S intrabars) ===
// ============================================================
// On each confirmed chart bar, push its 5S slices into history and into the
// profile. If the chart bar expands the day range, a full rebuild runs (bin
// width changed); otherwise each slice is added incrementally. Falls back to
// the whole chart bar if the LTF isn't served.
if barstate.isconfirmed and not use_rolling and not na(low) and not na(high)
    bool _expands = na(day_lo) or na(day_hi) or low < day_lo or high > day_hi
    // Update running day extremes BEFORE binning so the range covers this bar.
    if na(day_lo) or low < day_lo
        day_lo := low
        day_lo
    if na(day_hi) or high > day_hi
        day_hi := high
        day_hi
    int _ni = array.size(_iihi)
    if _ni > 0
        for _k = 0 to _ni - 1 by 1
            float _sh = array.get(_iihi, _k)
            float _sl = array.get(_iilo, _k)
            float _sv = array.get(_iivol, _k)
            float _so = array.get(_iiopen, _k)
            float _sc = array.get(_iiclose, _k)
            if not na(_sh) and not na(_sl) and not na(_sv) and _sv > 0
                int _sd = _sc > _so ? 1 : _sc < _so ? -1 : 0
                array.push(bar_los, _sl)
                array.push(bar_his, _sh)
                array.push(bar_vols, _sv)
                array.push(bar_dirs, _sd)
                if not _expands
                    _add_bar_to_profile(_sl, _sh, _sv, _sd)
    else if volume > 0
        int _dir = close > open ? 1 : close < open ? -1 : 0
        array.push(bar_los, low)
        array.push(bar_his, high)
        array.push(bar_vols, volume)
        array.push(bar_dirs, _dir)
        if not _expands
            _add_bar_to_profile(low, high, volume, _dir)
    if _expands
        _rebuild_profile()

// --- ROLLING (HTF composite): trailing N-day profile from chart bars ---------
// Never clears at the day reset; instead each confirmed chart bar is pushed with
// a day tag, entries older than roll_days are aged out on each new day, and the
// window's hi/lo + profile are recomputed. Chart bars (not 5S) keep this within
// Pine's compute budget on 4H/1D, where the composite — not one session — is the
// point. The window range spans the whole retained swing, so POC/VA land near price.
if barstate.isconfirmed and use_rolling and not na(low) and not na(high) and volume > 0
    int _rdir = close > open ? 1 : close < open ? -1 : 0
    array.push(bar_los, low)
    array.push(bar_his, high)
    array.push(bar_vols, volume)
    array.push(bar_dirs, _rdir)
    array.push(bar_days, day_count)
    // age out entries older than the rolling window (on a fresh day)
    if _new_day
        while array.size(bar_days) > 0 and array.get(bar_days, 0) < day_count - roll_days
            array.shift(bar_los)
            array.shift(bar_his)
            array.shift(bar_vols)
            array.shift(bar_dirs)
            array.shift(bar_days)
    // recompute the window extremes across all retained entries, then rebuild
    float _wlo = na
    float _whi = na
    if array.size(bar_los) > 0
        for _i = 0 to array.size(bar_los) - 1 by 1
            float _el = array.get(bar_los, _i)
            float _eh = array.get(bar_his, _i)
            _wlo := na(_wlo) or _el < _wlo ? _el : _wlo
            _whi := na(_whi) or _eh > _whi ? _eh : _whi
            _whi
    day_lo := _wlo
    day_hi := _whi
    _rebuild_profile()

// ============================================================
// === COMPUTE POC / VA (every bar — needed for alert crossovers) ===
// ============================================================
if not na(day_lo) and not na(day_hi) and day_hi > day_lo and array.size(bar_los) > 0
    [poc_idx, poc_vol] = _find_poc()
    [vah_idx, val_idx] = _compute_va(poc_idx)
    float row_h = (day_hi - day_lo) / i_rows
    poc_p := day_lo + (poc_idx + 0.5) * row_h
    vah_p := day_lo + (vah_idx + 1) * row_h
    val_p := day_lo + val_idx * row_h
    val_p

// ============================================================
// === RENDER PRIOR-DAY OVERLAY (gray backdrop, drawn first) ===
// ============================================================
if show_prev and barstate.islast
    if array.size(prev_boxes) > 0
        for i = 0 to array.size(prev_boxes) - 1 by 1
            box.delete(array.get(prev_boxes, i))
        array.clear(prev_boxes)
    int days_to_show = math.min(prev_days, MAX_PREV_DAYS)
    int anchor_b = bar_index + hist_right_offset
    int max_bar_width = hist_width_bars
    for d = days_to_show - 1 to 0 by 1
        float d_lo = array.get(prev_day_los, d)
        float d_hi = array.get(prev_day_his, d)
        int d_rws = array.get(prev_day_rows, d)
        if not na(d_lo) and not na(d_hi) and d_hi > d_lo and d_rws > 0
            float d_row_h = (d_hi - d_lo) / d_rws
            float d_max_vol = 0.0
            for r = 0 to d_rws - 1 by 1
                v = array.get(prev_vol_flat, d * MAX_PREV_ROWS + r)
                if v > d_max_vol
                    d_max_vol := v
                    d_max_vol
            if d_max_vol > 0
                int day_op = prev_op
                if days_to_show > 1
                    float frac = d / float(days_to_show - 1)
                    day_op := int(math.round(prev_op + frac * (95 - prev_op)))
                    day_op
                day_op := math.min(95, day_op)
                color d_fill = color.new(prev_col, day_op)
                color d_border = color.new(prev_col, math.min(95, day_op + 10))
                for r = 0 to d_rws - 1 by 1
                    v = array.get(prev_vol_flat, d * MAX_PREV_ROWS + r)
                    if v > 0
                        int bar_w = int(math.round(v / d_max_vol * max_bar_width))
                        if bar_w >= 1
                            float row_lo = d_lo + r * d_row_h
                            float row_hi = d_lo + (r + 1) * d_row_h
                            int box_left = anchor_b - bar_w
                            int box_right = anchor_b
                            bx = box.new(box_left, row_hi, box_right, row_lo, bgcolor = d_fill, border_color = d_border, border_width = 1)
                            array.push(prev_boxes, bx)
else
    if array.size(prev_boxes) > 0
        for i = 0 to array.size(prev_boxes) - 1 by 1
            box.delete(array.get(prev_boxes, i))
        array.clear(prev_boxes)

// ============================================================
// === RENDER HISTOGRAM (right-edge, live every bar) ===
// ============================================================
if show_hist and barstate.islast and not na(day_lo) and not na(day_hi) and day_hi > day_lo
    if array.size(hist_boxes) > 0
        for i = 0 to array.size(hist_boxes) - 1 by 1
            box.delete(array.get(hist_boxes, i))
        array.clear(hist_boxes)
    float pad_amt = (day_hi - day_lo) * hist_pad_pct / 100.0
    float row_h_h = (day_hi - day_lo) / i_rows
    float max_vol = 0.0
    float max_abs_delta = 0.0
    for r = 0 to i_rows - 1 by 1
        v = array.get(vol_arr, r)
        if v > max_vol
            max_vol := v
            max_vol
        float bv = array.get(buy_arr, r)
        float sv = array.get(sell_arr, r)
        float ad = math.abs(bv - sv)
        if ad > max_abs_delta
            max_abs_delta := ad
            max_abs_delta
    if max_vol > 0
        int anchor_b = bar_index + hist_right_offset
        int max_bar_width = hist_width_bars
        color hist_base = hist_use_poc_col ? col_poc : hist_col_custom
        for r = 0 to i_rows - 1 by 1
            v = array.get(vol_arr, r)
            if v > 0
                int bar_w = int(math.round(v / max_vol * max_bar_width))
                if bar_w >= 1
                    float row_lo = day_lo + r * row_h_h
                    float row_hi = day_lo + (r + 1) * row_h_h
                    int box_right = anchor_b
                    int box_left = anchor_b - bar_w
                    if delta_mode
                        float bv = array.get(buy_arr, r)
                        float sv = array.get(sell_arr, r)
                        float total_bv_sv = bv + sv
                        int row_op = hist_op
                        if delta_intensity and max_abs_delta > 0
                            float ad = math.abs(bv - sv)
                            float intensity = ad / max_abs_delta
                            row_op := int(math.round(95 - intensity * (95 - hist_op)))
                            row_op
                        if total_bv_sv > 0
                            int buy_w = int(math.round(bar_w * bv / total_bv_sv))
                            int sell_w = bar_w - buy_w
                            int split_x = box_left + buy_w
                            color buy_fill = color.new(col_buy, row_op)
                            color sell_fill = color.new(col_sell, row_op)
                            color buy_border = color.new(col_buy, math.min(95, row_op + 15))
                            color sell_border = color.new(col_sell, math.min(95, row_op + 15))
                            if buy_w >= 1
                                bx_buy = box.new(box_left, row_hi, split_x, row_lo, bgcolor = buy_fill, border_color = buy_border, border_width = 1)
                                array.push(hist_boxes, bx_buy)
                            if sell_w >= 1
                                bx_sell = box.new(split_x, row_hi, box_right, row_lo, bgcolor = sell_fill, border_color = sell_border, border_width = 1)
                                array.push(hist_boxes, bx_sell)
                        else
                            color fallback_fill = color.new(hist_base, row_op)
                            bx = box.new(box_left, row_hi, box_right, row_lo, bgcolor = fallback_fill, border_color = color.new(hist_base, math.min(95, row_op + 15)), border_width = 1)
                            array.push(hist_boxes, bx)
                    else
                        color hist_fill = color.new(hist_base, hist_op)
                        color hist_border = color.new(hist_base, math.min(95, hist_op + 15))
                        bx = box.new(box_left, row_hi, box_right, row_lo, bgcolor = hist_fill, border_color = hist_border, border_width = 1)
                        array.push(hist_boxes, bx)
else
    if array.size(hist_boxes) > 0
        for i = 0 to array.size(hist_boxes) - 1 by 1
            box.delete(array.get(hist_boxes, i))
        array.clear(hist_boxes)

// ============================================================
// === DRAW LINES (live update every bar) ===
// ============================================================
if not na(poc_p) and barstate.islast
    int l_left = bar_index - 1440
    int l_right = bar_index + i_extend_bars
    if show_poc
        if na(ln_poc)
            ln_poc := line.new(l_left, poc_p, l_right, poc_p, color = color.new(col_poc, 0), width = wid_poc, style = _sty(sty_poc))
            ln_poc
        else
            ln_poc.set_xy1(l_left, poc_p)
            ln_poc.set_xy2(l_right, poc_p)
            ln_poc.set_color(color.new(col_poc, 0))
            ln_poc.set_width(wid_poc)
            ln_poc.set_style(_sty(sty_poc))
        if show_lbls
            if na(lb_poc)
                lb_poc := label.new(l_right, poc_p, 'POC', style = label.style_label_left, color = color.new(col_poc, 0), textcolor = #000000, size = _lblsz(lbl_size))
                lb_poc
            else
                lb_poc.set_xy(l_right, poc_p)
                lb_poc.set_color(color.new(col_poc, 0))
        else
            if not na(lb_poc)
                lb_poc.delete()
                lb_poc := na
                lb_poc
    else
        if not na(ln_poc)
            ln_poc.delete()
            ln_poc := na
            ln_poc
        if not na(lb_poc)
            lb_poc.delete()
            lb_poc := na
            lb_poc
    if show_va and not na(vah_p) and not na(val_p)
        if na(ln_vah)
            ln_vah := line.new(l_left, vah_p, l_right, vah_p, color = col_va, width = wid_va, style = _sty(sty_va))
            ln_vah
        else
            ln_vah.set_xy1(l_left, vah_p)
            ln_vah.set_xy2(l_right, vah_p)
            ln_vah.set_color(col_va)
            ln_vah.set_width(wid_va)
            ln_vah.set_style(_sty(sty_va))
        if na(ln_val)
            ln_val := line.new(l_left, val_p, l_right, val_p, color = col_va, width = wid_va, style = _sty(sty_va))
            ln_val
        else
            ln_val.set_xy1(l_left, val_p)
            ln_val.set_xy2(l_right, val_p)
            ln_val.set_color(col_va)
            ln_val.set_width(wid_va)
            ln_val.set_style(_sty(sty_va))
        if show_lbls
            if na(lb_vah)
                lb_vah := label.new(l_right, vah_p, 'VAH', style = label.style_label_left, color = col_va, textcolor = #000000, size = _lblsz(lbl_size))
                lb_vah
            else
                lb_vah.set_xy(l_right, vah_p)
                lb_vah.set_color(col_va)
            if na(lb_val)
                lb_val := label.new(l_right, val_p, 'VAL', style = label.style_label_left, color = col_va, textcolor = #000000, size = _lblsz(lbl_size))
                lb_val
            else
                lb_val.set_xy(l_right, val_p)
                lb_val.set_color(col_va)
        else
            if not na(lb_vah)
                lb_vah.delete()
                lb_vah := na
                lb_vah
            if not na(lb_val)
                lb_val.delete()
                lb_val := na
                lb_val
        if fill_va
            if na(bx_va)
                bx_va := box.new(l_left, vah_p, l_right, val_p, bgcolor = col_va_fill, border_color = color.new(#000000, 100))
                bx_va
            else
                bx_va.set_lefttop(l_left, vah_p)
                bx_va.set_rightbottom(l_right, val_p)
                bx_va.set_bgcolor(col_va_fill)
        else
            if not na(bx_va)
                bx_va.delete()
                bx_va := na
                bx_va
    else
        if not na(ln_vah)
            ln_vah.delete()
            ln_vah := na
            ln_vah
        if not na(ln_val)
            ln_val.delete()
            ln_val := na
            ln_val
        if not na(lb_vah)
            lb_vah.delete()
            lb_vah := na
            lb_vah
        if not na(lb_val)
            lb_val.delete()
            lb_val := na
            lb_val
        if not na(bx_va)
            bx_va.delete()
            bx_va := na
            bx_va

// ============================================================
// === DATA WINDOW EXPORTS ===
// ============================================================
plot(poc_p, 'POC', color = na, display = display.data_window)
plot(vah_p, 'VAH', color = na, display = display.data_window)
plot(val_p, 'VAL', color = na, display = display.data_window)

// ============================================================
// === ALERT CONDITIONS ===
// ============================================================
poc_cross_up = not na(poc_p) and ta.crossover(close, poc_p)
poc_cross_down = not na(poc_p) and ta.crossunder(close, poc_p)
vah_cross_up = not na(vah_p) and ta.crossover(close, vah_p)
vah_cross_down = not na(vah_p) and ta.crossunder(close, vah_p)
val_cross_up = not na(val_p) and ta.crossover(close, val_p)
val_cross_down = not na(val_p) and ta.crossunder(close, val_p)

alertcondition(poc_cross_up, 'Price crossed above POC', 'Price crossed above developing POC')
alertcondition(poc_cross_down, 'Price crossed below POC', 'Price crossed below developing POC')
alertcondition(vah_cross_up, 'Price crossed above VAH', 'Price crossed above developing VAH')
alertcondition(vah_cross_down, 'Price crossed below VAH', 'Price crossed below developing VAH')
alertcondition(val_cross_up, 'Price crossed above VAL', 'Price crossed above developing VAL')
alertcondition(val_cross_down, 'Price crossed below VAL', 'Price crossed below developing VAL')
````
