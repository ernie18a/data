# Covered Call Strike Optimizer

- url: https://www.tradingview.com/script/qlRnHk0Q-Covered-Call-Strike-Optimizer/
- type: indicator
- pine_id: PUB;4107480e17184360af3b20047226115a
- version: 1.0

## Description

Covered Call Strike Optimizer
A TradingView Pine Script (v6) that projects OTM covered call strike levels at the start of each period and scores each method's historical accuracy by measuring how close the predicted level was to the actual closing price at period end.

What It Does
At the beginning of each period the script snapshots a strike price for every enabled study method. At the end of each period it measures how far each projected level was from where price actually closed, accumulating the error over every period in your chart history. The results table shows which method has historically been the tightest predictor for the specific symbol and timeframe you are analyzing.

This answers the question: "Which strike selection method would have put my covered call closest to where price actually ended up?"

The Math
HV Expected Move (purple) — most rigorous
Uses the Black-Scholes 1-sigma expected move formula:

strike = open × (1 + HV_annualized × sqrt(DTE / 252))
sqrt(DTE / 252) correctly de-annualizes the volatility to the exact period length. This is the same math options market makers use to price contracts. The HV lookback measures the volatility regime and is always kept independent of DTE — it does not need to be auto-scaled because sqrt(DTE/252) already handles time-scaling.

ATR Levels (orange)
strike = period_open + (multiplier × ATR)
ATR measures the average range of one bar. The multiplier asks: how many typical bar-ranges might price travel over this entire period? For short-duration trades (e.g., 3-day or weekly), using ATR(14) measures volatility over a window 3–5× longer than the trade, which may reflect a stale regime. Auto-scaling sets the lookback to max(DTE, 10) so the smoothing window matches the trade horizon. A floor of 10 bars is enforced — fewer bars produces noisy estimates.

Standard Deviation (blue)
strike = period_open + (multiplier × StdDev(close, length))
SD measures the dispersion of closing prices over the lookback window. Same auto-scale logic as ATR — when enabled, length = max(DTE, 10).

Fixed % OTM (red)
strike = period_open × (1 + pct / 100)
No volatility adjustment. A simple directional assumption that price will not rise more than X% during the period.

Previous Period High (yellow)
The highest bar high from the prior completed period. Serves as a natural resistance level and potential OTM target on range-bound or mean-reverting symbols.

Results Table
Located in the top-right corner of the chart.

Column	Description
Level	Study name and multiplier
Price	Current projected strike price
OTM %	How far above today's close the strike sits right now
Avg Err%	Average absolute % distance from the actual close across all periods
Avg $	Average absolute dollar distance from the actual close across all periods
Lower Avg Err% and Avg $ = the method historically predicted closest to where price actually closed.

Color Coding (Avg Err% and Avg $ columns)
Color	Avg Error	Interpretation
Lime	< 10%	Tight predictor — this level consistently landed close to close
Yellow	10–25%	Moderate — useful directional guide but not precise
Red	≥ 25%	Loose — strike was frequently far from where price closed
The footer row shows how many complete periods were analyzed. More periods = more reliable statistics.

Best-Row Highlight
The row with the lowest Avg Err% is highlighted with a faint white background glow — this is the method that historically placed the strike closest to where price actually closed. The highlight uses a 0.01% epsilon comparison to handle floating-point rounding.

Period Background Shading
Each period's final bar is shaded to show the covered call outcome relative to the HV 1-sigma level:

Green — price closed at or below HV 1σ (covered call likely expired worthless)
Red — price closed above HV 1σ (covered call was breached and likely required management)
Settings
Period
Setting	Default	Description
Expiration Cycle	Monthly (21)	Quick-select preset: 3-Day (3), Weekly (5), Monthly (21), Quarterly (63), or Custom
Custom DTE (bars)	21	Active only when Expiration Cycle = Custom
Auto-scale ATR & SD lookback to DTE	ON	When ON: ATR length = SD length = max(DTE, 10). Matches the smoothing window to your trade horizon. When OFF: use the manual length inputs in each study group. HV is never auto-scaled (already time-scaled via sqrt(DTE/252)).
DTE to bar count mapping (Daily chart):

Expiration	Bars
3-Day	3
Weekly	5
Monthly	21
Quarterly	63
On a Weekly chart divide by 5. On an Hourly chart multiply by ~6.5.

ATR Levels (orange)
Setting	Default	Description
Show ATR Levels	ON	Toggle lines and table rows for all ATR levels
ATR Length (manual override)	14	Only used when Auto-scale is OFF
Multiplier 1	1.0x	Strike = open + 1.0 × ATR
Multiplier 2	1.5x	Strike = open + 1.5 × ATR
Multiplier 3	2.0x	Strike = open + 2.0 × ATR
Multiplier 4	3.0x	Strike = open + 3.0 × ATR
Standard Deviation Levels (blue)
Setting	Default	Description
Show SD Levels	ON	Toggle lines and table rows for all SD levels
SD Length (manual override)	20	Only used when Auto-scale is OFF
Multiplier 1	1.0σ	Strike = open + 1.0 × SD
Multiplier 2	2.0σ	Strike = open + 2.0 × SD
Multiplier 3	3.0σ	Strike = open + 3.0 × SD
Historical Volatility / Expected Move (purple)
Setting	Default	Description
Show HV Expected Move	ON	Toggle HV lines and table rows
HV Lookback (bars)	30	Bars used to compute realized volatility. Not auto-scaled — HV is already time-adjusted via sqrt(DTE/252).
Fixed % OTM Levels (red)
Setting	Default	Description
Show % Levels	ON	Toggle fixed % lines and table rows
Level 1 %	5%	Strike = open × 1.05
Level 2 %	10%	Strike = open × 1.10
Level 3 %	15%	Strike = open × 1.15
Previous Period High (yellow)
Setting	Default	Description
Show Prev High	ON	Toggle the prior period high line and table row
Display
Setting	Default	Description
Show Results Table	ON	Show/hide the accuracy table
Show Lines on Chart	ON	Master toggle for all dashed lines and labels. Turn OFF to see just the table without cluttering the chart. Individual study toggles still control their rows in the table.
Shade Period Background	ON	Green/red background shading at each period's close bar
Label Size	Tiny	Size of line labels: Tiny, Small, or Normal
How to Use
Step 1 — Select your expiration cycle
Set Expiration Cycle in the Period group to match your options strategy:

Trading 3-day options on a Daily chart → select 3-Day (3)
Trading weekly options on a Daily chart → select Weekly (5)
Trading monthly options on a Daily chart → select Monthly (21)
Trading monthly options on a Weekly chart → set Custom DTE to 4 or 5
Step 2 — Decide on auto-scaling
Leave Auto-scale ATR & SD lookback to DTE ON (recommended). This ensures ATR and SD are measuring volatility over the same number of bars as your trade lasts. For very short DTEs (3 or 5), the floor of 10 bars keeps estimates stable.

Turn it OFF if you prefer consistent, longer-term smoothing regardless of DTE — for example, if you always want ATR(14) as your baseline regardless of whether you're trading weeklies or monthlies.

Step 3 — Read the results table
Look at Avg Err% and Avg $. The rows with the lowest values (lime-colored) are the methods that historically placed the strike closest to where price actually closed. Use those as your primary strike selection candidates.

The Price and OTM % columns show where those same methods are projecting for the current active period.

Step 4 — Reduce chart clutter when needed
Toggle Show Lines on Chart OFF in Display settings to hide all dashed lines while keeping the results table. Individual study toggles (Show ATR Levels, Show SD Levels, etc.) let you focus on specific methods.

Tips
Run on a symbol with at least 50+ complete periods for statistically meaningful Avg Err% values. The footer shows the period count.
Compare cycles: switch between Weekly (5) and Monthly (21) presets to see which methods hold up across different time horizons.
HV Expected Move is the options-theory benchmark — it approximates what implied volatility is pricing in. If another method consistently beats it in Avg Err%, that is a meaningful signal for that symbol.
ATR and SD with auto-scale ON produce different lookback lengths for different cycles. A 3-day trade uses ATR(10) while a monthly trade uses ATR(21), giving each cycle an appropriately sized volatility window.
Prev Period High tends to work best on range-bound or mean-reverting symbols where prior resistance is respected.
Results are historical and backward-looking. Market regime changes (e.g., a volatility spike) can shift which method performs best going forward.

## Source Code

````pine

//@version=6
indicator("Covered Call Strike Optimizer", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ════════════════════════════════════════════════════════════════════════════
// COVERED CALL STRIKE OPTIMIZER
//
// PURPOSE
// Draws projected OTM covered call strike levels at the start of each period
// and scores each method's historical accuracy by measuring how close the
// predicted level was to the actual closing price at period end.
//
// HOW IT WORKS
// 1. At the open of each period the script snapshots a strike price for every
//    enabled study method using the indicators available at that bar.
// 2. At the close of each period it computes:
//      Avg Err%  = |close - strike| / close x 100  (relative error)
//      Avg $     = |close - strike|                 (dollar error)
//    and accumulates both across every period in chart history.
// 3. The results table shows each method's running average. The row with the
//    lowest Avg Err% is highlighted with a white border-glow background to
//    identify the best historical predictor at a glance.
//
// MATH NOTES
//   ATR: per-bar measure of typical range. Strike = open + N x ATR.
//        When auto-scale is ON, ATR lookback = max(DTE, 10).
//   SD:  per-bar price dispersion. Strike = open + N x StdDev(close, len).
//        Same auto-scale logic as ATR.
//   HV Expected Move: Black-Scholes 1-sigma formula.
//        Strike = open + open x HV_annualized x sqrt(DTE / 252)
//        sqrt(DTE/252) correctly de-annualizes realized vol to the period.
//        1-sigma => ~68% probability OTM expiry. 2-sigma => ~95%.
//        hv_move is computed INSIDE is_start using `open` directly to avoid
//        a stale p_open from the prior period. HV uses a separate counter
//        (hv_total) with na guards to prevent NaN poisoning.
//   Fixed %: simple OTM target relative to the period open.
//   Prev High: highest bar of the prior completed period.
//
// TABLE ROW HIGHLIGHT
//   The best row (lowest Avg Err% among enabled levels) is identified by
//   scanning all avg errors on barstate.islast before the table is drawn.
//   f_upd_best and _row_bg use if/else to avoid Pine v6 ternary-continuation
//   parsing restrictions (? cannot start a new line).
//   The winning row gets bgcolor = color.new(color.white, 82) -- a faint white
//   glow that reads as a border highlight without obscuring colored text.
//
// COLOR KEY (Avg Err% column)
//   Lime   < 10%  -- tight predictor
//   Yellow 10-25% -- moderate
//   Red    >= 25% -- loose predictor
// ════════════════════════════════════════════════════════════════════════════


// --- INPUTS: PERIOD ----------------------------------------------------------
grp0 = "Period"
dte_preset = input.string("Monthly (21)", "Expiration Cycle", group=grp0,
    options=["3-Day (3)", "Weekly (5)", "Monthly (21)", "Quarterly (63)", "Custom"],
    tooltip="Quick-select common expiration cycles. Custom lets you set any bar count.")
dte_custom = input.int(21, "Custom DTE (bars)", group=grp0, minval=1, maxval=252,
    tooltip="Only used when Expiration Cycle = Custom.")
dte = switch dte_preset
    "3-Day (3)"      => 3
    "Weekly (5)"     => 5
    "Monthly (21)"   => 21
    "Quarterly (63)" => 63
    =>                  dte_custom
auto_scale = input.bool(true, "Auto-scale ATR & SD lookback to DTE", group=grp0,
    tooltip="ON: ATR length = SD length = max(DTE, 10).\nOFF: Use manual length inputs below.\nHV is never auto-scaled -- sqrt(DTE/252) already handles its time-scaling.")


// --- INPUTS: ATR LEVELS (orange) ---------------------------------------------
grp1     = "ATR Levels (orange)"
show_atr   = input.bool(true,  "Show ATR Levels",             group=grp1)
atr_len_in = input.int(14,     "ATR Length (manual override)", group=grp1,
    tooltip="Ignored when Auto-scale is ON.")
atr_m1     = input.float(1.0,  "Multiplier 1", group=grp1, step=0.25)
atr_m2     = input.float(1.5,  "Multiplier 2", group=grp1, step=0.25)
atr_m3     = input.float(2.0,  "Multiplier 3", group=grp1, step=0.25)
atr_m4     = input.float(3.0,  "Multiplier 4", group=grp1, step=0.25)
atr_col    = input.color(color.new(color.orange, 0), "Color", group=grp1)


// --- INPUTS: STANDARD DEVIATION LEVELS (blue) --------------------------------
grp2     = "Standard Deviation Levels (blue)"
show_sd    = input.bool(true,  "Show SD Levels",              group=grp2)
sd_len_in  = input.int(20,     "SD Length (manual override)", group=grp2,
    tooltip="Ignored when Auto-scale is ON.")
sd_m1      = input.float(1.0,  "Multiplier 1", group=grp2, step=0.5)
sd_m2      = input.float(2.0,  "Multiplier 2", group=grp2, step=0.5)
sd_m3      = input.float(3.0,  "Multiplier 3", group=grp2, step=0.5)
sd_col     = input.color(color.new(color.blue, 0), "Color", group=grp2)


// --- INPUTS: HV EXPECTED MOVE (purple) ---------------------------------------
// Formula: open + open x HV_annualized x sqrt(DTE / 252)
// 1-sigma => ~68% OTM expiry probability | 2-sigma => ~95%
grp3     = "Historical Volatility / Expected Move (purple)"
show_hv    = input.bool(true, "Show HV Expected Move", group=grp3)
hv_len     = input.int(30,    "HV Lookback (bars)",     group=grp3,
    tooltip="Bars used to compute realized vol. NOT auto-scaled -- sqrt(DTE/252) handles time-scaling.\nShort = reactive to recent vol. Long = stable regime estimate.")
hv_col     = input.color(color.new(color.purple, 0), "Color", group=grp3)


// --- INPUTS: FIXED % OTM LEVELS (red) ----------------------------------------
grp4     = "Fixed % OTM Levels (red)"
show_pct   = input.bool(true,  "Show % Levels", group=grp4)
pct1       = input.float(5.0,  "Level 1 %",     group=grp4, step=1.0)
pct2       = input.float(10.0, "Level 2 %",     group=grp4, step=1.0)
pct3       = input.float(15.0, "Level 3 %",     group=grp4, step=1.0)
pct_col    = input.color(color.new(color.red, 0), "Color", group=grp4)


// --- INPUTS: PREVIOUS PERIOD HIGH (yellow) -----------------------------------
grp5      = "Previous Period High (yellow)"
show_prev  = input.bool(true, "Show Prev High", group=grp5)
prev_col   = input.color(color.new(color.yellow, 0), "Color", group=grp5)


// --- INPUTS: DISPLAY ---------------------------------------------------------
grp6        = "Display"
show_table  = input.bool(true,        "Show Results Table",      group=grp6)
show_lines  = input.bool(true,        "Show Lines on Chart",     group=grp6,
    tooltip="Uncheck to hide all lines and labels while keeping the results table.")
show_bg     = input.bool(true,        "Shade Period Background", group=grp6,
    tooltip="Green = closed within HV 1-sigma (call expired worthless). Red = breached.")
lbl_size    = input.string(size.tiny, "Label Size",              group=grp6,
    options=[size.tiny, size.small, size.normal])


// --- RESOLVE LOOKBACK LENGTHS ------------------------------------------------
atr_len = auto_scale ? math.max(dte, 10) : atr_len_in
sd_len  = auto_scale ? math.max(dte, 10) : sd_len_in


// --- CORE INDICATOR VALUES ---------------------------------------------------
atr_val = ta.atr(atr_len)
sd_val  = ta.stdev(close, sd_len)
log_ret = math.log(close / close[1])
hv_ann  = ta.stdev(log_ret, hv_len) * math.sqrt(252.0)


// --- PERIOD BAR COUNTER ------------------------------------------------------
var int bar_count = 0
bar_count := bar_count >= dte - 1 ? 0 : bar_count + 1
is_start  = bar_count == 0
is_end    = bar_count == dte - 1


// --- PERSISTENT STATE --------------------------------------------------------
var float p_open    = na
var float p_prev_hi = na

// --- STRIKE SNAPSHOTS --------------------------------------------------------
var float sv_atr1 = na
var float sv_atr2 = na
var float sv_atr3 = na
var float sv_atr4 = na
var float sv_sd1  = na
var float sv_sd2  = na
var float sv_sd3  = na
var float sv_hv1  = na
var float sv_hv2  = na
var float sv_pct1 = na
var float sv_pct2 = na
var float sv_pct3 = na
var float sv_prev = na

if is_start
    p_open  := open
    sv_atr1 := open + atr_m1 * atr_val
    sv_atr2 := open + atr_m2 * atr_val
    sv_atr3 := open + atr_m3 * atr_val
    sv_atr4 := open + atr_m4 * atr_val
    sv_sd1  := open + sd_m1 * sd_val
    sv_sd2  := open + sd_m2 * sd_val
    sv_sd3  := open + sd_m3 * sd_val
    // HV computed inside is_start using `open` directly -- avoids stale p_open.
    // If hv_ann is na (early bars, not enough history), sv_hv1/2 remain na
    // and are excluded via na guard in the accumulator block below.
    _hv     = open * hv_ann * math.sqrt(float(dte) / 252.0)
    sv_hv1  := open + 1.0 * _hv   // 1-sigma: ~68% OTM expiry probability
    sv_hv2  := open + 2.0 * _hv   // 2-sigma: ~95% OTM expiry probability
    sv_pct1 := open * (1.0 + pct1 / 100.0)
    sv_pct2 := open * (1.0 + pct2 / 100.0)
    sv_pct3 := open * (1.0 + pct3 / 100.0)
    sv_prev := nz(p_prev_hi)

p_prev_hi := is_start ? high : math.max(nz(p_prev_hi), high)


// --- ACCURACY ACCUMULATORS ---------------------------------------------------
// e_* = cumulative absolute % error | d_* = cumulative absolute $ error
// hv_total is a separate counter -- only increments when hv_ann was valid.
var int   total    = 0
var int   hv_total = 0
var float e_atr1   = 0.0
var float e_atr2   = 0.0
var float e_atr3   = 0.0
var float e_atr4   = 0.0
var float e_sd1    = 0.0
var float e_sd2    = 0.0
var float e_sd3    = 0.0
var float e_hv1    = 0.0
var float e_hv2    = 0.0
var float e_pct1   = 0.0
var float e_pct2   = 0.0
var float e_pct3   = 0.0
var float e_prev   = 0.0
var float d_atr1   = 0.0
var float d_atr2   = 0.0
var float d_atr3   = 0.0
var float d_atr4   = 0.0
var float d_sd1    = 0.0
var float d_sd2    = 0.0
var float d_sd3    = 0.0
var float d_hv1    = 0.0
var float d_hv2    = 0.0
var float d_pct1   = 0.0
var float d_pct2   = 0.0
var float d_pct3   = 0.0
var float d_prev   = 0.0

f_pct(lvl) => math.abs(close - lvl) / close * 100.0
f_dol(lvl) => math.abs(close - lvl)

if is_end and not na(sv_atr1)
    total  += 1
    e_atr1 += f_pct(sv_atr1)
    e_atr2 += f_pct(sv_atr2)
    e_atr3 += f_pct(sv_atr3)
    e_atr4 += f_pct(sv_atr4)
    e_sd1  += f_pct(sv_sd1)
    e_sd2  += f_pct(sv_sd2)
    e_sd3  += f_pct(sv_sd3)
    e_pct1 += f_pct(sv_pct1)
    e_pct2 += f_pct(sv_pct2)
    e_pct3 += f_pct(sv_pct3)
    e_prev += sv_prev > 0 ? f_pct(sv_prev) : 0.0
    d_atr1 += f_dol(sv_atr1)
    d_atr2 += f_dol(sv_atr2)
    d_atr3 += f_dol(sv_atr3)
    d_atr4 += f_dol(sv_atr4)
    d_sd1  += f_dol(sv_sd1)
    d_sd2  += f_dol(sv_sd2)
    d_sd3  += f_dol(sv_sd3)
    d_pct1 += f_dol(sv_pct1)
    d_pct2 += f_dol(sv_pct2)
    d_pct3 += f_dol(sv_pct3)
    d_prev += sv_prev > 0 ? f_dol(sv_prev) : 0.0
    if not na(sv_hv1)
        hv_total += 1
        e_hv1    += f_pct(sv_hv1)
        e_hv2    += f_pct(sv_hv2)
        d_hv1    += f_dol(sv_hv1)
        d_hv2    += f_dol(sv_hv2)


// --- PERIOD BACKGROUND -------------------------------------------------------
_bg_col = show_bg and is_end and total > 0 ? (close <= sv_hv1 ? color.new(color.green, 90) : color.new(color.red, 90)) : na
bgcolor(_bg_col, title="Period Outcome")


// --- LINE + LABEL DRAWING ----------------------------------------------------
f_draw(y, col, lbl, x1, x2) =>
    line.new(x1, y, x2, y, color=col, width=1, style=line.style_dashed)
    label.new(x2, y, lbl, color=color.new(col, 70), textcolor=col,
              style=label.style_label_left, size=lbl_size)

if show_lines and is_start and not na(p_open)
    x1 = bar_index
    x2 = bar_index + dte
    if show_atr
        f_draw(sv_atr1, atr_col, "ATR " + str.tostring(atr_m1, "#.##") + "x", x1, x2)
        f_draw(sv_atr2, atr_col, "ATR " + str.tostring(atr_m2, "#.##") + "x", x1, x2)
        f_draw(sv_atr3, atr_col, "ATR " + str.tostring(atr_m3, "#.##") + "x", x1, x2)
        f_draw(sv_atr4, atr_col, "ATR " + str.tostring(atr_m4, "#.##") + "x", x1, x2)
    if show_sd
        f_draw(sv_sd1, sd_col, "SD " + str.tostring(sd_m1, "#.#") + "s", x1, x2)
        f_draw(sv_sd2, sd_col, "SD " + str.tostring(sd_m2, "#.#") + "s", x1, x2)
        f_draw(sv_sd3, sd_col, "SD " + str.tostring(sd_m3, "#.#") + "s", x1, x2)
    if show_hv
        f_draw(sv_hv1, hv_col, "HV 1s", x1, x2)
        f_draw(sv_hv2, hv_col, "HV 2s", x1, x2)
    if show_pct
        f_draw(sv_pct1, pct_col, "+" + str.tostring(pct1, "#") + "%", x1, x2)
        f_draw(sv_pct2, pct_col, "+" + str.tostring(pct2, "#") + "%", x1, x2)
        f_draw(sv_pct3, pct_col, "+" + str.tostring(pct3, "#") + "%", x1, x2)
    if show_prev and sv_prev > 0
        f_draw(sv_prev, prev_col, "Prev High", x1, x2)


// --- FIND BEST ROW -----------------------------------------------------------
// Returns the smaller of candidate and current, treating na(current) as +inf.
// Uses if/else to avoid Pine v6's ternary-after-or parsing restriction.
f_upd_best(candidate, current) =>
    float result = current
    if na(current) or candidate < current
        result := candidate
    result

var float best_err = na

if barstate.islast
    _b = float(na)
    if show_atr and total > 0
        _b := f_upd_best(e_atr1 / total, _b)
        _b := f_upd_best(e_atr2 / total, _b)
        _b := f_upd_best(e_atr3 / total, _b)
        _b := f_upd_best(e_atr4 / total, _b)
    if show_sd and total > 0
        _b := f_upd_best(e_sd1 / total, _b)
        _b := f_upd_best(e_sd2 / total, _b)
        _b := f_upd_best(e_sd3 / total, _b)
    if show_hv and hv_total > 0
        _b := f_upd_best(e_hv1 / hv_total, _b)
        _b := f_upd_best(e_hv2 / hv_total, _b)
    if show_pct and total > 0
        _b := f_upd_best(e_pct1 / total, _b)
        _b := f_upd_best(e_pct2 / total, _b)
        _b := f_upd_best(e_pct3 / total, _b)
    if show_prev and total > 0
        _b := f_upd_best(e_prev / total, _b)
    best_err := _b


// --- RESULTS TABLE -----------------------------------------------------------
_avg(e, t) => t > 0 ? e / t : na

otm_str(lvl) => str.tostring(math.round((lvl / close - 1.0) * 100.0, 1), "#.0") + "%"

err_str(e, t) => t > 0 ? str.tostring(math.round(e / t * 10.0) / 10.0, "#.0") + "%" : "-"

dol_str(d, t) => t > 0 ? "$" + str.tostring(math.round(d / t * 10.0) / 10.0, "#.0") : "-"

err_col(e, t) =>
    ae = t > 0 ? e / t : na
    na(ae) ? color.gray : ae < 10.0 ? color.lime : ae < 25.0 ? color.yellow : color.red

// Row highlight: winning row (lowest Avg Err%) gets faint white glow.
// Uses if/else -- Pine v6 disallows ? on a continuation line.
_row_bg(e, t) =>
    ae = _avg(e, t)
    color result = color.new(color.black, 88)
    if not na(ae) and not na(best_err) and math.abs(ae - best_err) < 0.01
        result := color.new(color.white, 82)
    result

var table tbl = table.new(position.top_right, 5, 15,
    bgcolor=color.new(color.black, 15),
    border_color=color.new(color.gray, 40), border_width=1,
    frame_color=color.new(color.gray, 20), frame_width=1)

// t = period count (total or hv_total depending on the study)
add_row(r, lbl, lvl, e, d, col, t) =>
    bg = _row_bg(e, t)
    table.cell(tbl, 0, r, lbl,                        bgcolor=bg, text_color=col,               text_size=size.small)
    table.cell(tbl, 1, r, str.tostring(lvl, "#.00"),  bgcolor=bg, text_color=color.white,        text_size=size.small)
    table.cell(tbl, 2, r, otm_str(lvl),               bgcolor=bg, text_color=color.silver,       text_size=size.small)
    table.cell(tbl, 3, r, err_str(e, t),              bgcolor=bg, text_color=err_col(e, t),      text_size=size.small)
    table.cell(tbl, 4, r, dol_str(d, t),              bgcolor=bg, text_color=err_col(e, t),      text_size=size.small)

if show_table and barstate.islast
    hdr = color.new(color.gray, 50)
    table.cell(tbl, 0, 0, "Level",    bgcolor=hdr, text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 0, "Price",    bgcolor=hdr, text_color=color.white, text_size=size.small)
    table.cell(tbl, 2, 0, "OTM %",    bgcolor=hdr, text_color=color.white, text_size=size.small)
    table.cell(tbl, 3, 0, "Avg Err%", bgcolor=hdr, text_color=color.white, text_size=size.small)
    table.cell(tbl, 4, 0, "Avg $",    bgcolor=hdr, text_color=color.white, text_size=size.small)

    r = 1
    if show_atr
        add_row(r, "ATR " + str.tostring(atr_m1, "#.#") + "x", sv_atr1, e_atr1, d_atr1, atr_col, total), r += 1
        add_row(r, "ATR " + str.tostring(atr_m2, "#.#") + "x", sv_atr2, e_atr2, d_atr2, atr_col, total), r += 1
        add_row(r, "ATR " + str.tostring(atr_m3, "#.#") + "x", sv_atr3, e_atr3, d_atr3, atr_col, total), r += 1
        add_row(r, "ATR " + str.tostring(atr_m4, "#.#") + "x", sv_atr4, e_atr4, d_atr4, atr_col, total), r += 1
    if show_sd
        add_row(r, "SD " + str.tostring(sd_m1, "#.#") + "s", sv_sd1, e_sd1, d_sd1, sd_col, total), r += 1
        add_row(r, "SD " + str.tostring(sd_m2, "#.#") + "s", sv_sd2, e_sd2, d_sd2, sd_col, total), r += 1
        add_row(r, "SD " + str.tostring(sd_m3, "#.#") + "s", sv_sd3, e_sd3, d_sd3, sd_col, total), r += 1
    if show_hv
        // HV uses hv_total (only periods where hv_ann was valid at open)
        add_row(r, "HV 1s expected move", sv_hv1, e_hv1, d_hv1, hv_col, hv_total), r += 1
        add_row(r, "HV 2s expected move", sv_hv2, e_hv2, d_hv2, hv_col, hv_total), r += 1
    if show_pct
        add_row(r, "+" + str.tostring(pct1, "#.0") + "% OTM", sv_pct1, e_pct1, d_pct1, pct_col, total), r += 1
        add_row(r, "+" + str.tostring(pct2, "#.0") + "% OTM", sv_pct2, e_pct2, d_pct2, pct_col, total), r += 1
        add_row(r, "+" + str.tostring(pct3, "#.0") + "% OTM", sv_pct3, e_pct3, d_pct3, pct_col, total), r += 1
    if show_prev
        add_row(r, "Prev Period High", nz(sv_prev, close), e_prev, d_prev, prev_col, total), r += 1

    foot = color.new(color.gray, 70)
    table.cell(tbl, 0, r, "Periods: " + str.tostring(total) + "  (HV: " + str.tostring(hv_total) + ")",
        bgcolor=foot, text_color=color.yellow, text_size=size.small)
    table.cell(tbl, 1, r, "", bgcolor=foot)
    table.cell(tbl, 2, r, "", bgcolor=foot)
    table.cell(tbl, 3, r, "Lime<10%  Yel<25%  Red>=25%", bgcolor=foot, text_color=color.gray, text_size=size.tiny)
    table.cell(tbl, 4, r, "lower = closer",               bgcolor=foot, text_color=color.gray, text_size=size.tiny)
````
