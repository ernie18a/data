# Rebound V-Score

- url: https://www.tradingview.com/script/XUruCt92/
- type: indicator
- pine_id: PUB;b9fcbe6e37b54c87b4b6807b9c920f03
- version: 4.0

## Description

[b]Rebound V-Score[/b]
Scores Rebound V-Fib setups across timeframes. It runs both engines - RT (long / V-bottom rebound) and Closer (short / inverted-V breakdown) - on three selectable timeframes at once (default 1H, daily, weekly) and outputs ranking scores plus per-timeframe readouts for sorting and filtering across symbols. The score is built on the same V-Fib metric (where price sits on the slanted Fib) as the rest of the family. Built for the Pine Screener; no chart drawing, but it also runs on a chart.

For US equities by default. Adjust 'Trading hours per day' for other markets (default 6.5).

Each (direction x timeframe) produces a 0-1 "readiness" - how close that setup is to firing - blended into RT Score and CL Score. Columns are suffixed A / B / C, naming the slot, not the timeframe.

[b]SCORES (sort / filter keys, also on the status line)[/b]
[list]
[*]RT Score / CL Score (0-3) - long / short readiness across A/B/C. Sort descending for the best long / short candidates.
[*]V-Score (-3..+3) = RT Score - CL Score - net direction. RT/CL are kept separate too, so a timeframe conflict shows as both high.
[/list]

[b]ENTRY SIGNALS + ALERTS (both directions)[/b]
[list]
[*]Entry L / Entry S (Any, A, B, C) - long / short trend-entry on a timeframe, gated by the opposite Score (long needs no breakdown, short needs no rebound).
[*]Alerts "Long entry" / "Short entry" (any TF, A, B, C) - one-shot per setup. Use "Once Per Bar Close".
[/list]

[b]PER-TIMEFRAME READOUTS (Data Window + Screener)[/b]
For each of A / B / C: RT/CL V-Fib (position on the slanted Fib), RT/CL Age (bars since firing), V-Trend (RT-CL, %/day). Plus % change 3M / M / W / D (close vs 63 / 21 / 5 / 1 daily bars ago).

[b]INPUTS[/b]
[list]
[*]Timeframe A / B / C and their Score weights (default 6:3:1, leaning on slot A; normalized, only the ratio matters).
[*]Entry L max CL Score / Entry S max RT Score - the opposite-direction gate for each signal.
[*]Trend / entry thresholds and Score weights (V-Fib zone / trend / lead, default 6:3:1) - same as Rebound V-Fib RT / Closer.
[/list]

Notes: Pine Screener is limited to 500 bars and 5 unique request.* calls (this uses 4). The score measures readiness, not expected return.

[b]DISCLAIMER[/b]
This script is provided "AS IS" without warranty of any kind. It is for informational purposes only and does not constitute financial advice. Past performance is not indicative of future results. The author is not liable for any losses arising from the use of this script. Trade at your own risk.

## Source Code

````pine
//@version=6
// Version: 1.2.1 (2026-07-10)
//
// Rebound V-Score: scores Rebound V-Fib setups across timeframes. Runs both engines —
// RT (long / V-bottom) and Closer (short / inverted-V) — on three selectable timeframes
// (default 1H / daily / weekly) and emits readiness scores (V-Score / RT / CL) plus
// per-combo readouts for screening; the score is built on the same V-Fib metric (where
// price sits on the slanted Fib). Columns suffixed A / B / C = the chosen timeframes.
// Engines are copied from Rebound V-Fib RT / Closer with drawing and support detection
// removed, and bars_per_day measured per timeframe/symbol so %/day readouts stay correct.

indicator("Rebound V-Score", "V-Score", overlay = true, max_bars_back = 500)

max_bars_back(high, 500)   // dynamic high[i] / low[i] lookback defeats buffer auto-sizing; force full depth
max_bars_back(low, 500)

// ==================== Inputs ====================

lookback_bars         = input.int(240,   "Lookback bars",          minval = 10,  group = "General",         tooltip = "Lookback bars for trend detection. Pine Screener is capped at 500 bars, so larger values can be inaccurate there.")
min_downtrend_bars    = input.int(20,    "Min downtrend bars",     minval = 1,   group = "Trend detection", tooltip = "Minimum downtrend/run-up bars before the pivot")
min_uptrend_bars      = input.int(5,     "Min uptrend bars",       minval = 1,   group = "Trend detection", tooltip = "Minimum uptrend/breakdown bars after the pivot")

min_uptrend_rate       = input.float(0.3,  "Min uptrend rate [%/day]",   minval = 0.01, group = "Trend entry", tooltip = "Minimum rebound/breakdown slope magnitude for entry (linear %/day)")
max_downtrend_rate     = input.float(0.0,  "Max downtrend rate [%/day]", group = "Trend entry", tooltip = "Prior-leg slope constraint (typically <= 0)")
min_vtrend             = input.float(-0.1, "Min V-Trend [%/day]",        group = "Trend entry", tooltip = "Minimum trend_diff (uptrend_rate + downtrend_rate). Negative means downtrend may exceed rebound")
min_entry_vfib_ratio   = input.float(0.5,  "Min entry V-Fib",            minval = 0.01, group = "Trend entry", tooltip = "Entry zone lower bound on V-Fib")
max_entry_vfib_ratio   = input.float(1.0,  "Max entry V-Fib",            group = "Trend entry", tooltip = "Entry zone upper bound on V-Fib")
min_entry_leading_gain = input.float(0.5,  "Min entry leading gain [%]", minval = 0.01, group = "Trend entry", tooltip = "Leading gain/drop over the base (leading_days x rate)")
unlock_vfib_ratio      = input.float(3.0,  "Unlock V-Fib",               group = "Trend entry", tooltip = "Score zone decays to 0 by this V-Fib (also re-arms the Age lock)")

// Three selectable analysis timeframes; per-combo columns and TF weights are suffixed
// A / B / C (default 1H / daily / weekly). The suffix names the slot, not the timeframe.
tf_a = input.timeframe("60", "Timeframe A", group = "Screener", tooltip = "Analysis timeframe for slot A; all slot-A columns/weight come from it. Default 1H.")
tf_b = input.timeframe("D",  "Timeframe B", group = "Screener", tooltip = "Analysis timeframe for slot B. Default daily.")
tf_c = input.timeframe("W",  "Timeframe C", group = "Screener", tooltip = "Analysis timeframe for slot C. Default weekly.")
w_tf_a = input.float(6.0, "TF weight A", minval = 0, group = "Screener", tooltip = "Score weight of timeframe A. Weights are normalized, so only the A:B:C ratio matters. Weighs the V-Score / RT / CL Score outputs (status line and screener columns); entry signals and alerts use the Entry filter weights instead.")
w_tf_b = input.float(3.0, "TF weight B", minval = 0, group = "Screener", tooltip = "Score weight of timeframe B.")
w_tf_c = input.float(1.0, "TF weight C", minval = 0, group = "Screener", tooltip = "Score weight of timeframe C.")
session_mode = input.string("24h", "Session", options = ["regular", "extended", "24h"], group = "Screener", tooltip = "Session for the A/B/C timeframes; affects intraday timeframes only.")

entry_cl_max = input.float(0.3, "Entry L: max CL Score", minval = 0, group = "Screener", tooltip = "The long entry signal (slot-B setup) fires only when the CL Score stays below this under both Entry filter profiles (no breakdown). 0.3 = strict long-only filter.")
entry_rt_max = input.float(0.3, "Entry S: max RT Score", minval = 0, group = "Screener", tooltip = "The short entry signal (slot-B setup) fires only when the RT Score stays below this under both Entry filter profiles (no rebound). 0.3 = strict short-only filter.")

// Dual entry gate: the opposite Score must be below its filter under BOTH weight profiles (fast + slow)
w_ef_a = input.float(6.0, "Entry filter fast A", minval = 0, group = "Entry filter", tooltip = "Fast-profile weight of slot A for the entry gate. Entry signals require the opposite Score below its max under both the fast and slow profiles; 6:3:1 x 1:3:6 screened best in backtests.")
w_ef_b = input.float(3.0, "Entry filter fast B", minval = 0, group = "Entry filter")
w_ef_c = input.float(1.0, "Entry filter fast C", minval = 0, group = "Entry filter")
w_es_a = input.float(1.0, "Entry filter slow A", minval = 0, group = "Entry filter")
w_es_b = input.float(3.0, "Entry filter slow B", minval = 0, group = "Entry filter")
w_es_c = input.float(6.0, "Entry filter slow C", minval = 0, group = "Entry filter")

w_zone  = input.float(6.0, "Score weight: V-Fib zone", minval = 0, group = "Score weights", tooltip = "Readiness weight of how close V-Fib is to the entry zone. Weights are normalized internally, so only the zone:trend:lead ratio matters — the sum need not be 1.")
w_trend = input.float(3.0, "Score weight: trend",      minval = 0, group = "Score weights", tooltip = "Readiness weight of the trend pillar = min(active-leg rate, V-Trend); both must hold.")
w_lead  = input.float(1.0, "Score weight: lead",       minval = 0, group = "Score weights", tooltip = "Readiness weight of the leading-gain condition.")


// ==================== Geometric helpers ====================
// Linear price space: slopes are price-units/bar.

max_high_above_line(int x_a, float y_a, int x_b, float y_b) =>
    float max_diff = na
    if not na(y_a) and not na(y_b) and x_a != x_b
        float slope = (y_b - y_a) / float(x_b - x_a)
        int i_from = math.min(bar_index - x_a, bar_index - x_b)
        int i_to   = math.max(bar_index - x_a, bar_index - x_b)
        for i = i_from to i_to
            if not na(high[i])
                float d = high[i] - (y_a + slope * float((bar_index - i) - x_a))
                if na(max_diff) or d > max_diff
                    max_diff := d
    max_diff

max_low_below_line(int x_a, float y_a, int x_b, float y_b) =>
    float max_diff = na
    if not na(y_a) and not na(y_b) and x_a != x_b
        float slope = (y_b - y_a) / float(x_b - x_a)
        int i_from = math.min(bar_index - x_a, bar_index - x_b)
        int i_to   = math.max(bar_index - x_a, bar_index - x_b)
        for i = i_from to i_to
            if not na(low[i])
                float d = (y_a + slope * float((bar_index - i) - x_a)) - low[i]
                if na(max_diff) or d > max_diff
                    max_diff := d
    max_diff

vfib_ratio_at_anchors(int x1, float y1, int down_x2, float down_y2, float diff, float price) =>
    float r = na
    if not na(price) and not na(y1) and not na(down_y2) and not na(diff) and not na(x1) and not na(down_x2)
        int dx = down_x2 - x1
        if dx != 0
            float unit = diff / 0.236
            float base_y = y1 + (down_y2 - y1) / dx * (bar_index - x1)
            float raw = (price - base_y) / unit
            r := na(raw) ? 0 : raw
    r

vfib_ratio_short(int x1, float y1, int down_x2, float down_y2, float diff, float price) =>
    float r = na
    if not na(price) and not na(y1) and not na(down_y2) and not na(diff) and not na(x1) and not na(down_x2)
        int dx = down_x2 - x1
        if dx != 0
            float unit = diff / 0.236
            float base_y = y1 + (down_y2 - y1) / dx * (bar_index - x1)
            float raw = (base_y - price) / unit
            r := na(raw) ? 0 : raw
    r


// ==================== Readiness helpers ====================
// Readiness r in [0,1] = how close a combo is to firing. Each entry condition is
// turned into a soft "fraction satisfied" (1 = passes, ramps to 0 over a band), and
// the bottleneck (min) is taken so r=1 exactly when all conditions pass (= live).

clamp01(float x) =>
    math.max(0.0, math.min(1.0, x))

// q >= thr: full at thr, ramps to 0 at thr-band (band guarded against 0)
softgate_ge(float q, float thr, float band) =>
    clamp01(1.0 + (q - thr) / math.max(band, 1e-9))

// V-Fib approach to the entry zone: rises into [zlo,zhi]=1, decays to 0 by unlock
zone_r(float vfib) =>
    float zlo = min_entry_vfib_ratio
    float zhi = max_entry_vfib_ratio
    float un  = unlock_vfib_ratio
    na(vfib) ? 0.0 : vfib < zlo ? math.max(0.0, vfib / zlo) : vfib <= zhi ? 1.0 : math.max(0.0, (un - vfib) / math.max(un - zhi, 1e-9))

// Combined readiness. Short side passes negated rate/trend/lead so the same gates
// apply. Band for the rate/trend gates = min_uptrend_rate; lead gate band = its own
// threshold. Each gate is independently floored at 0 (per-element: a wrong-direction
// condition contributes 0 but does not veto the others), then the three pillars —
// V-Fib zone, trend, lead — are combined as a normalized weighted average. The prior
// leg constraint (s_dn) is intentionally excluded: its threshold is loose so it is
// ~always 1, which would only pad the average. The trend pillar is min(s_up, s_td) —
// the entry needs BOTH the active leg (s_up) and the net V-Trend (s_td), and s_td
// already contains the active-leg rate, so averaging them would double-count and be
// arbitrary. Each gate is capped at 1 at its entry threshold (softgate's clamp01), so
// excess beyond the entry condition is never added. Zone is weighted heavily (default
// 6:3:1) to dampen not-yet-arrived / over-extended setups without collapsing the score
// onto V-Fib alone (no hard cap — the pillars compensate).
readiness(float ur, float td, float lead, float vfib) =>
    float s_up   = softgate_ge(ur,   min_uptrend_rate,       min_uptrend_rate)
    float s_td   = softgate_ge(td,   min_vtrend,             min_uptrend_rate)
    float s_lead = softgate_ge(lead, min_entry_leading_gain, min_entry_leading_gain)
    float trend  = math.min(s_up, s_td)
    float wsum   = w_zone + w_trend + w_lead
    (w_zone * zone_r(vfib) + w_trend * trend + w_lead * s_lead) / math.max(wsum, 1e-9)

// Measured bars per day (runs inside request.security): count bars per calendar day and
// keep a ~5-day average, so omitted no-trade bars / extended sessions / each symbol's
// liquidity all scale %/day correctly; daily and above keep the calendar ladder.
bpd_measured() =>
    bool new_day = nz(ta.change(dayofmonth)) != 0
    float s = timeframe.in_seconds(timeframe.period)
    if s >= 86400
        s >= 86400 * 20 ? 1.0 / 20 : s >= 86400 * 5 ? 1.0 / 5 : 1.0
    else
        var int   count = 0
        var float avg   = na
        if new_day and count > 0
            avg   := na(avg) ? count : (avg * 4 + count) / 5   // EMA-style ~5-day average
            count := 0
        count += 1
        nz(avg, math.max(count, 1))   // before the first full day, fall back to the running count


// ==================== TrendFinder (long / RT) ====================
// Detects the V-shape anchors (downtrend top, V-bottom, uptrend) and the trend-rate
// readouts. Same engine as Rebound V-Fib RT; drawing and support detection removed,
// bars_per_day made per-instance (self.bpd, set each bar in update()).

type TrendFinder
    float  bpd = na              // bars per day for this instance's requested timeframe
    int    down_x2 = na
    float  down_y2 = na
    int    x1 = na
    float  y1 = na
    float  down_diff = na   // max distance of mid-top above base line
    float  up_slope = na
    int    btm_abs = na          // incremental V-bottom tracker: absolute bar_index of lowest low since the top
    int    btm_left = na         // previous bar's scan-window left edge (absolute), to detect window changes
    float  uptrend_rate = na
    float  downtrend_rate = na   // linear %/day from mid-top-adjusted down leg
    float  trend_diff = na
    float  vfib_ratio = na
    float  leading_days = na

method isValid(TrendFinder self) =>
    not na(self.down_diff)

method get_vfib_ratio(TrendFinder self, float price) =>
    not self.isValid() ? na : vfib_ratio_at_anchors(self.x1, self.y1, self.down_x2, self.down_y2, self.down_diff, price)

method get_leading_days(TrendFinder self, float price) =>
    if na(self.up_slope) or self.up_slope == 0 or na(price) or na(self.x1)
        0.0
    else
        float line_y = self.y1 + self.up_slope * (bar_index - self.x1)
        (price - line_y) / (self.up_slope * self.bpd)

method update(TrendFinder self, float bpd) =>
    self.bpd := bpd
    // top_i: highest-high offset, clamped to available bars (length is bar_index + const, which Pine bounds
    // statically, so its buffer is replay-safe). Lets detection work before lookback_bars of history exists.
    top_i = -ta.highestbars(high, math.min(lookback_bars, bar_index + 1))
    // btm_i: lowest low since the top, tracked incrementally over low[] (O(1) amortized). NOT ta.lowestbars:
    // a "since-top" length must depend on top_i (a price-derived series) which Pine can't statically bound,
    // so ta.lowestbars' internal buffer under-allocates and overflows in Bar Replay (max_bars_back can't fix
    // it; toggling visibility temporarily clears it). Direct low[] access uses low's 500-bar buffer instead.
    int n        = math.max(nz(top_i, 5), 5)   // scan window length (offsets 0..n-1)
    int left_now = bar_index - n + 1           // window left edge, absolute bar_index
    int btm_i    = 0
    if not na(self.btm_abs) and not na(low) and left_now >= self.btm_left and self.btm_abs >= left_now
        // window grew at the front only: fold in the current bar (ties keep the newer bar)
        if low <= low[bar_index - self.btm_abs]
            self.btm_abs := bar_index
        btm_i := bar_index - self.btm_abs
    else
        // rescan: first bar, window changed, or running min aged out
        for i = 1 to n - 1
            if low[i] < low[btm_i]
                btm_i := i
        self.btm_abs := bar_index - btm_i
    self.btm_left := left_now

    if low < self.y1 or (top_i >= min_downtrend_bars + min_uptrend_bars) and (btm_i >= min_uptrend_bars)
        // ---- top of downtrend
        if na(self.down_x2) or bar_index - top_i > self.down_x2
            self.down_x2   := bar_index - top_i
            self.down_y2   := high[top_i]
            self.x1        := na
            self.y1        := na
            self.down_diff := na
            self.up_slope  := na

        // ---- bottom of downtrend
        if not na(self.down_x2) and (na(self.x1) or self.down_x2 != self.x1)
            if (na(self.x1) or bar_index - btm_i > self.x1) and bar_index - btm_i != self.down_x2
                self.x1        := bar_index - btm_i
                self.y1        := low[btm_i]
                self.up_slope  := na

                // ---- middle top of downtrend (max distance above base line)
                self.down_diff := max_high_above_line(self.x1, self.y1, self.down_x2, self.down_y2)

    // ---- middle bottom of uptrend (min slope from x1 to any later low)
    if not na(self.x1) and not na(self.y1) and bar_index > self.x1
        int start = na(self.up_slope) ? bar_index - self.x1 - 1 : 0
        for j = start to 0
            if not na(low[j])
                float s = (low[j] - self.y1) / (bar_index - j - self.x1)
                if na(self.up_slope) or s <= self.up_slope
                    self.up_slope := s

    // ---- trend rate readouts (linear %/day, normalized by leg-start price)
    self.uptrend_rate   := (na(self.up_slope) or na(self.y1) or self.y1 == 0) ? 0 : 100.0 * self.up_slope / self.y1 * self.bpd
    self.downtrend_rate := (na(self.down_diff) or na(self.down_y2) or self.down_y2 == 0 or self.down_x2 == self.x1) ? 0 : 100.0 * (self.down_y2 + self.down_diff - self.y1) / float(self.down_x2 - self.x1) / self.down_y2 * self.bpd
    self.trend_diff     := self.uptrend_rate + self.downtrend_rate
    self.vfib_ratio     := self.get_vfib_ratio(high)
    self.leading_days   := self.get_leading_days(low)


// ==================== TrendFinderS (short / Closer) ====================
// Price-axis mirror of TrendFinder: detects an inverted-V peak (run-up then
// breakdown) and the trend-rate readouts. Same engine as Rebound V-Fib RT Closer;
// drawing and support detection removed, bars_per_day made per-instance,
// vfib_ratio_at_anchors -> vfib_ratio_short. Internal names kept from the long version.

type TrendFinderS
    float  bpd = na
    int    down_x2 = na
    float  down_y2 = na
    int    x1 = na
    float  y1 = na
    float  down_diff = na   // max distance of mid-bottom below base line
    float  up_slope = na
    int    btm_abs = na          // incremental peak tracker: absolute bar_index of highest high since the bottom
    int    btm_left = na
    float  uptrend_rate = na
    float  downtrend_rate = na   // linear %/day from mid-bottom-adjusted run-up leg
    float  trend_diff = na
    float  vfib_ratio = na
    float  leading_days = na

// Unique method names (no overload with TrendFinder): Pine forbids overloaded
// functions from reading global variables like high / bar_index (CE10182).
method isValidS(TrendFinderS self) =>
    not na(self.down_diff)

method get_vfib_ratioS(TrendFinderS self, float price) =>
    not self.isValidS() ? na : vfib_ratio_short(self.x1, self.y1, self.down_x2, self.down_y2, self.down_diff, price)

method get_leading_daysS(TrendFinderS self, float price) =>
    if na(self.up_slope) or self.up_slope == 0 or na(price) or na(self.x1)
        0.0
    else
        float line_y = self.y1 + self.up_slope * (bar_index - self.x1)
        (price - line_y) / (self.up_slope * self.bpd)

method updateS(TrendFinderS self, float bpd) =>
    self.bpd := bpd
    // top_i: lowest-low offset, clamped to available bars (length is bar_index + const, replay-safe).
    top_i = -ta.lowestbars(low, math.min(lookback_bars, bar_index + 1))
    // btm_i: highest high since the bottom, tracked incrementally over high[] (O(1) amortized). NOT
    // ta.highestbars (since-bottom length depends on top_i, which Pine can't statically bound, so its
    // buffer overflows in Bar Replay). Direct high[] access uses high's 500-bar buffer instead.
    int n        = math.max(nz(top_i, 5), 5)
    int left_now = bar_index - n + 1
    int btm_i    = 0
    if not na(self.btm_abs) and not na(high) and left_now >= self.btm_left and self.btm_abs >= left_now
        if high >= high[bar_index - self.btm_abs]
            self.btm_abs := bar_index
        btm_i := bar_index - self.btm_abs
    else
        for i = 1 to n - 1
            if high[i] > high[btm_i]
                btm_i := i
        self.btm_abs := bar_index - btm_i
    self.btm_left := left_now

    if high > self.y1 or (top_i >= min_downtrend_bars + min_uptrend_bars) and (btm_i >= min_uptrend_bars)
        // ---- bottom of prior leg
        if na(self.down_x2) or bar_index - top_i > self.down_x2
            self.down_x2   := bar_index - top_i
            self.down_y2   := low[top_i]
            self.x1        := na
            self.y1        := na
            self.down_diff := na
            self.up_slope  := na

        // ---- peak of run-up
        if not na(self.down_x2) and (na(self.x1) or self.down_x2 != self.x1)
            if (na(self.x1) or bar_index - btm_i > self.x1) and bar_index - btm_i != self.down_x2
                self.x1        := bar_index - btm_i
                self.y1        := high[btm_i]
                self.up_slope  := na

                // ---- middle bottom of run-up (max distance below base line)
                self.down_diff := max_low_below_line(self.x1, self.y1, self.down_x2, self.down_y2)

    // ---- middle top of breakdown (max slope from x1 to any later high)
    if not na(self.x1) and not na(self.y1) and bar_index > self.x1
        int start = na(self.up_slope) ? bar_index - self.x1 - 1 : 0
        for j = start to 0
            if not na(high[j])
                float s = (high[j] - self.y1) / (bar_index - j - self.x1)
                if na(self.up_slope) or s >= self.up_slope
                    self.up_slope := s

    // ---- trend rate readouts (linear %/day, normalized by leg-start price)
    self.uptrend_rate   := (na(self.up_slope) or na(self.y1) or self.y1 == 0) ? 0 : 100.0 * self.up_slope / self.y1 * self.bpd
    self.downtrend_rate := (na(self.down_diff) or na(self.down_y2) or self.down_y2 == 0 or self.down_x2 == self.x1) ? 0 : 100.0 * (self.down_y2 - self.down_diff - self.y1) / float(self.down_x2 - self.x1) / self.down_y2 * self.bpd
    self.trend_diff     := self.uptrend_rate + self.downtrend_rate
    self.vfib_ratio     := self.get_vfib_ratioS(low)
    self.leading_days   := self.get_leading_daysS(high)


// ==================== Per-timeframe calc wrappers (run inside request.security) ====================
// Each returns [vfib, age, trend_diff, readiness, entry] for one variant on the
// requested timeframe. The engine state and the entry-lock state machine (for Age) live
// in the secondary context, one independent instance per call.

calc_long(float bpd) =>
    var t = TrendFinder.new()
    t.update(bpd)

    // entry-lock state machine -> Age (bars since the setup fired; re-arms on a new
    // V-bottom or when V-Fib passes unlock). Same logic as the standalone RT.
    var bool e_locked = false
    var int  e_basis  = -1
    var int  e_bar    = na
    int e_basis_now = nz(t.x1, -1)
    if e_basis_now != e_basis
        e_locked := false
        e_basis  := e_basis_now
    if not na(t.vfib_ratio) and t.vfib_ratio >= unlock_vfib_ratio
        e_locked := false
    bool  cond = t.uptrend_rate >= min_uptrend_rate and t.downtrend_rate <= max_downtrend_rate and t.trend_diff >= min_vtrend
    bool  zone = not na(t.vfib_ratio) and t.vfib_ratio >= min_entry_vfib_ratio and t.vfib_ratio <= max_entry_vfib_ratio
    float lead = t.leading_days * t.uptrend_rate
    bool  entry_now = cond and zone and lead >= min_entry_leading_gain   // trend-entry condition (no lock): valid-now for screening
    bool  sig  = entry_now and not e_locked
    if sig
        e_locked := true
        e_bar    := bar_index
    float age = e_locked ? bar_index - e_bar + 1 : 0

    float r = readiness(t.uptrend_rate, t.trend_diff, lead, t.vfib_ratio)
    // entry_now = persistent "valid now" (screener filter); sig only arms the Age lock
    [t.vfib_ratio, age, t.trend_diff, r, entry_now ? 1.0 : 0.0]

calc_short(float bpd) =>
    var t = TrendFinderS.new()
    t.updateS(bpd)

    var bool e_locked = false
    var int  e_basis  = -1
    var int  e_bar    = na
    int e_basis_now = nz(t.x1, -1)
    if e_basis_now != e_basis
        e_locked := false
        e_basis  := e_basis_now
    if not na(t.vfib_ratio) and t.vfib_ratio >= unlock_vfib_ratio
        e_locked := false
    bool  cond = t.uptrend_rate <= -min_uptrend_rate and t.downtrend_rate >= -max_downtrend_rate and t.trend_diff <= -min_vtrend
    bool  zone = not na(t.vfib_ratio) and t.vfib_ratio >= min_entry_vfib_ratio and t.vfib_ratio <= max_entry_vfib_ratio
    float lead = t.leading_days * t.uptrend_rate
    bool  entry_now = cond and zone and lead <= -min_entry_leading_gain   // mirror of the long valid-now gate
    bool  sig  = entry_now and not e_locked
    if sig
        e_locked := true
        e_bar    := bar_index
    float age = e_locked ? bar_index - e_bar + 1 : 0

    // Short side: negate rate/trend/lead so the same (positive-threshold) gates apply.
    float r = readiness(-t.uptrend_rate, -t.trend_diff, -lead, t.vfib_ratio)
    [t.vfib_ratio, age, t.trend_diff, r, entry_now ? 1.0 : 0.0]

// Both engines in one call so each timeframe needs only ONE request.security (3 TFs x 2
// directions would be 6, over the Screener's limit of 5). Long tuple then short tuple.
calc_both() =>
    float bpd = bpd_measured()
    [lv, la, lvt, lr, le] = calc_long(bpd)
    [sv, sa, svt, sr, se] = calc_short(bpd)
    [lv, la, lvt, lr, le, sv, sa, svt, sr, se]


// ==================== Per-timeframe requests (A / B / C = the chosen timeframes) ====================
// 3 calc_both calls + 1 daily call for the % change columns = 4 request.security calls (limit is 5).

string req_ticker = ticker.modify(syminfo.tickerid, session_mode)

[rta_vfib, rta_age, rta_vt, rta_r, rta_ent, cla_vfib, cla_age, cla_vt, cla_r, cla_ent] = request.security(req_ticker, tf_a, calc_both())
[rtb_vfib, rtb_age, rtb_vt, rtb_r, rtb_ent, clb_vfib, clb_age, clb_vt, clb_r, clb_ent] = request.security(req_ticker, tf_b, calc_both())
[rtc_vfib, rtc_age, rtc_vt, rtc_r, rtc_ent, clc_vfib, clc_age, clc_vt, clc_r, clc_ent] = request.security(req_ticker, tf_c, calc_both())

// Multi-timeframe % change (3M / M / W / D), independent of the A/B/C analysis
// timeframes: one daily call, live close vs N daily bars ago (D=1, W=5, M=21, 3M=63).
[pd1, pd5, pd21, pd63] = request.security(syminfo.tickerid, "D", [close[1], close[5], close[21], close[63]], lookahead = barmerge.lookahead_off)
float change_d  = na(pd1)  or pd1  == 0 ? na : (close - pd1)  / pd1  * 100
float change_w  = na(pd5)  or pd5  == 0 ? na : (close - pd5)  / pd5  * 100
float change_m  = na(pd21) or pd21 == 0 ? na : (close - pd21) / pd21 * 100
float change_3m = na(pd63) or pd63 == 0 ? na : (close - pd63) / pd63 * 100


// ==================== Integrated Score (readiness, TF-weighted) ====================
// RT/CL kept separate so the two directions never cancel (a conflicting symbol shows
// both Scores high). Per-TF weights normalized to sum 3 so all-three-live tops out at
// 3.0; only the A:B:C ratio matters.

float wnorm = 3.0 / math.max(w_tf_a + w_tf_b + w_tf_c, 1e-9)
float wa = w_tf_a * wnorm
float wb = w_tf_b * wnorm
float wc = w_tf_c * wnorm
float rt_score = wa * rta_r + wb * rtb_r + wc * rtc_r   // 0..3, long readiness
float cl_score = wa * cla_r + wb * clb_r + wc * clc_r   // 0..3, short readiness
float v_score  = rt_score - cl_score                   // -3..3, net direction (+ long, - short)

// Entry gate: opposite-side readiness below the filter under both fast and slow profiles
float efn = 3.0 / math.max(w_ef_a + w_ef_b + w_ef_c, 1e-9)
float esn = 3.0 / math.max(w_es_a + w_es_b + w_es_c, 1e-9)
bool cl_gate_ok = efn * (w_ef_a * cla_r + w_ef_b * clb_r + w_ef_c * clc_r) < entry_cl_max and esn * (w_es_a * cla_r + w_es_b * clb_r + w_es_c * clc_r) < entry_cl_max
bool rt_gate_ok = efn * (w_ef_a * rta_r + w_ef_b * rtb_r + w_ef_c * rtc_r) < entry_rt_max and esn * (w_es_a * rta_r + w_es_b * rtb_r + w_es_c * rtc_r) < entry_rt_max

// Trend-entry signals (1/0), slot B only (the one slot that backtested well): direction
// valid on B AND the opposite side passing the dual gate.
float entry_l_b = rtb_ent > 0 and cl_gate_ok ? 1.0 : 0.0
float entry_s_b = clb_ent > 0 and rt_gate_ok ? 1.0 : 0.0

// Alerts fire on the rising edge of the entry state, so a gate opening days after the
// setup still alerts; the same setup can re-alert if its gate closes and reopens.
bool alert_l_b = entry_l_b > 0 and nz(entry_l_b[1]) == 0
bool alert_s_b = entry_s_b > 0 and nz(entry_s_b[1]) == 0

// Days since the last entry alert fired — na until the first fire, and cleared when the
// fired setup dies (slot-B Age re-arms on a new V-bottom or unlock). Lets the Screener
// and the daily CSV log catch fires that happened between scans while the setup is alive.
float bpd_chart = bpd_measured()
var int last_l_bar = na
var int last_s_bar = na
if rtb_age == 0
    last_l_bar := na
if clb_age == 0
    last_s_bar := na
if alert_l_b
    last_l_bar := bar_index
if alert_s_b
    last_s_bar := bar_index
float entry_l_age = na(last_l_bar) ? na : (bar_index - last_l_bar) / bpd_chart
float entry_s_age = na(last_s_bar) ? na : (bar_index - last_s_bar) / bpd_chart


// ==================== Output ====================
// Only V-Score / RT Score / CL Score are on the status line; the 15 per-combo readouts
// (suffixed A / B / C) stay data-window / Screener only. Entry signals are alerts only —
// the Screener can filter on alert conditions directly.

disp      = display.pine_screener + display.data_window
disp_stat = disp + display.status_line

// ---- multi-timeframe % change (leftmost) ----
plot(change_3m, "3M%", display = disp, color = change_3m < 0 ? color.red : color.green, precision = 2)
plot(change_m,  "M%",  display = disp, color = change_m  < 0 ? color.red : color.green, precision = 2)
plot(change_w,  "W%",  display = disp, color = change_w  < 0 ? color.red : color.green, precision = 2)
plot(change_d,  "D%",  display = disp, color = change_d  < 0 ? color.red : color.green, precision = 2)

plot(entry_l_age,       "Long Age",   display = disp, color = color.lime,   precision = 1)
plot(entry_s_age,       "Short Age",  display = disp, color = color.orange, precision = 1)

plot(v_score,           "V-Score",    display = disp_stat, color = v_score < 0 ? color.red : color.teal, precision = 3)
plot(rt_score,          "RT Score",   display = disp_stat, color = rt_score < entry_rt_max ? color.black : color.teal, precision = 3)
plot(cl_score,          "CL Score",   display = disp_stat, color = cl_score < entry_cl_max ? color.black : color.red,  precision = 3)

// V-Fib entry-zone check, shared by the chart marks and the V-Fib column colors
vfib_in_zone(float v) =>
    not na(v) and v >= min_entry_vfib_ratio and v <= max_entry_vfib_ratio

// ---- alerts (entry-state rising edge; long CL-filtered, short RT-filtered) ----
alertcondition(alert_l_b, "Long entry",  "Rebound V-Score: long entry")
alertcondition(alert_s_b, "Short entry", "Rebound V-Score: short entry")

// ---- chart marks on entry bars (pane only): a second tiny triangle stacks onto the base mark
// when the slot-C V-Fib is also in the entry zone ----
plotshape(alert_l_b,                            "Long entry",              style = shape.triangleup,   location = location.belowbar, color = color.lime,   size = size.small, display = display.pane)
plotshape(alert_l_b and vfib_in_zone(rtc_vfib), "Long entry (C in zone)",  style = shape.triangleup,   location = location.belowbar, color = color.lime,   size = size.tiny,  display = display.pane)
plotshape(alert_s_b,                            "Short entry",             style = shape.triangledown, location = location.abovebar, color = color.orange, size = size.small, display = display.pane)
plotshape(alert_s_b and vfib_in_zone(clc_vfib), "Short entry (C in zone)", style = shape.triangledown, location = location.abovebar, color = color.orange, size = size.tiny,  display = display.pane)

// ---- per-combo readouts, grouped by metric (columns follow plot order) ----
// V-Fib columns highlight when inside the entry zone (long side lime, short side orange)
plot(rta_vfib,          "RT V-Fib A",      display = disp, color = vfib_in_zone(rta_vfib) ? color.lime   : color.teal, precision = 3)
plot(rtb_vfib,          "RT V-Fib B",      display = disp, color = vfib_in_zone(rtb_vfib) ? color.lime   : color.teal, precision = 3)
plot(rtc_vfib,          "RT V-Fib C",      display = disp, color = vfib_in_zone(rtc_vfib) ? color.lime   : color.teal, precision = 3)
plot(cla_vfib,          "CL V-Fib A",      display = disp, color = vfib_in_zone(cla_vfib) ? color.orange : color.red,  precision = 3)
plot(clb_vfib,          "CL V-Fib B",      display = disp, color = vfib_in_zone(clb_vfib) ? color.orange : color.red,  precision = 3)
plot(clc_vfib,          "CL V-Fib C",      display = disp, color = vfib_in_zone(clc_vfib) ? color.orange : color.red,  precision = 3)
plot(rta_age,           "RT Age A",        display = disp, precision = 0)
plot(rtb_age,           "RT Age B",        display = disp, precision = 0)
plot(rtc_age,           "RT Age C",        display = disp, precision = 0)
plot(cla_age,           "CL Age A",        display = disp, precision = 0)
plot(clb_age,           "CL Age B",        display = disp, precision = 0)
plot(clc_age,           "CL Age C",        display = disp, precision = 0)
// V-Trend columns: colored while that side's trend condition holds, black otherwise
plot(rta_vt,            "RT V-Trend A",    display = disp, color = rta_vt >= min_vtrend  ? color.blue : color.black, precision = 3)
plot(rtb_vt,            "RT V-Trend B",    display = disp, color = rtb_vt >= min_vtrend  ? color.blue : color.black, precision = 3)
plot(rtc_vt,            "RT V-Trend C",    display = disp, color = rtc_vt >= min_vtrend  ? color.blue : color.black, precision = 3)
plot(cla_vt,            "CL V-Trend A",    display = disp, color = cla_vt <= -min_vtrend ? color.red  : color.black, precision = 3)
plot(clb_vt,            "CL V-Trend B",    display = disp, color = clb_vt <= -min_vtrend ? color.red  : color.black, precision = 3)
plot(clc_vt,            "CL V-Trend C",    display = disp, color = clc_vt <= -min_vtrend ? color.red  : color.black, precision = 3)
````
