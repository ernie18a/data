# Rebound V-Fib RT Closer

- url: https://www.tradingview.com/script/FhLh0BlO/
- type: indicator
- pine_id: PUB;c11eed3556eb44308bea385b2bd64c49
- version: 1.0

## Description

[b]Rebound V-Fib RT Closer[/b]
The price-axis mirror of Rebound V-Fib RT for normal (linear) price charts. It detects an inverted-V peak (run-up then breakdown), draws the slanted V-Fib, resistance line, V-Ladder and baseball closer, marks trend entries, and exposes trend/resistance readouts - fast enough for second-scale charts and the Pine Screener.

For US equities on intraday/daily timeframes. Adjust 'Trading hours per day' for other markets (default 6.5).

Drawing-focused: there is no back-test, technical rating, resistance/exit signal, trailing stop, or lower-timeframe request. Trend geometry and rates update every bar; resistance detection and all drawing run on the last bar. Signals and drawings update on the live bar and confirm at close (they repaint intrabar) - for confirmed-only entry alerts, choose "Once Per Bar Close".

[b]DIFFERENCES FROM Rebound V-Fib RT[/b]
[list]
[*]Mirrors the whole detection in price: an inverted-V peak instead of a V-bottom, a breakdown leg instead of a rebound, a resistance ceiling instead of a support floor, and Fib targets projected downward
[*]The trend entry is shown as a single entry-bar background tint (red) plus an alert, computed from the live bar's rates / V-Fib / lead
[*]Inputs keep their positive magnitudes; the breakdown direction lives in the comparison signs (breakdown rate is negative, prior run-up rate is positive)
[/list]
[b]OUTPUTS[/b]

Overlay:
[list]
[*]Slanted Fib band (multi-colored levels), red breakdown line, purple resistance diagonal
[*]V-Ladder - purple key levels (0.236 / 0.5 / 1.0 / 1.618 / 2.272 / 3.0) between the previous and current resistance
[*]Baseball closer - emoji below the first bar that reached each V-Ladder level
[*]V-Fib Ratio label on the last bar
[*]Entry-bar background tint (red) when a trend entry is marked
[/list]
Status line + Data Window + Screener:
[list]
[*]V-Fib - current V-Fib Ratio (how far price has dropped down the slanted Fib band; the value equals the Fib level number)
[*]V-Trend - net rate (breakdown + run-up), %/day
[*]Sup%/d - resistance slope, %/day
[/list]
Data Window + Screener:
[list]
[*]Age - bars since the current trend entry (0 when not in a setup). Recommended Pine Screener filter: Age 1 ~ 7
[*]SupAge - days since the current resistance line was established
[*]SupLead% - close below resistance, as % of close (negative)
[*]Lead% - leading days x breakdown rate. Negative means price is leading the breakdown below the downtrend baseline
[*]Up%/d, Down%/d - trend slopes, %/day (Up%/d is the active breakdown leg, negative; Down%/d is the prior run-up, positive)
[/list]
Note: Pine Screener is limited to 500 bars of history; the resistance readouts (SupAge, Sup%/d, SupLead%) are computed on the last bar only.

[b]INPUTS[/b]

General:
[list]
[*]Lookback bars - inverted-V detection window
[*]Trading hours per day - intraday day-to-bar conversion for the %/day readouts (6.5 = US equities)
[/list]
Trend detection:
[list]
[*]Min run-up bars / Min breakdown bars - minimum bars from bottom to peak / from peak to now
[/list]
Trend entry:
[list]
[*]Min breakdown rate - reject if breakdown slope magnitude is below this (%/day)
[*]Run-up rate limit - constrains the prior run-up; default 0 requires run-up >= 0, more negative requires a steeper run-up
[*]Min V-Trend - reject unless breakdown + run-up rate clears the gate
[*]Min / Max entry V-Fib - lower / upper bound of the entry window on the slanted Fib band
[*]Min entry leading drop - minimum leading drop required at entry
[*]Unlock V-Fib - re-arm the entry once V-Fib drops past this (one signal per setup)
[/list]
Display:
[list]
[*]Show baseball closer - toggle the V-Ladder emoji
[*]Show trend entry - toggle the entry-bar background tint
[/list]
[b]DISCLAIMER[/b]
This script is provided "AS IS" without warranty of any kind. It is for informational purposes only and does not constitute financial advice. Past performance is not indicative of future results. The author is not liable for any losses arising from the use of this script. Trade at your own risk.

## Source Code

````pine
//@version=6
// Version: 3.0.0 Closer (2026-06-14)
//
// Rebound V-Fib RT Closer: linear-price, real-time member of the Rebound V-Fib
// family — the price-axis mirror of "Rebound V-Fib RT". Detects an inverted-V
// peak (run-up then breakdown), draws the slanted V-Fib, resistance line,
// V-Ladder, and baseball closer, marks trend entries, and plots trend/resistance
// readouts (data window / status line / Pine Screener). Drawing and resistance
// detection run on the last bar; everything else updates every bar and repaints
// intrabar until close.
//
// Mirror legend (internal names are kept from the Long version; their meaning is
// reflected): x1/y1 = the PEAK (a high); down_x2/down_y2 = the prior leg's BOTTOM
// (a low, to the left); down_diff = max DEPTH of the mid-bottom BELOW the base
// line (kept positive); up_slope/up_x2/up_y2 = the active DOWN leg (max slope to
// later highs = resistance from above, negative); "support" = resistance ceiling;
// uptrend_rate = active breakdown rate (negative); downtrend_rate = prior run-up
// rate (positive); the Fib projects DOWNWARD.

indicator("Rebound V-Fib RT Closer", "V-Fib CL", overlay = true, max_lines_count = 50, max_bars_back = 500)

max_bars_back(high, 500)   // dynamic high[i] / low[top_i] lookback defeats buffer auto-sizing; force full depth
max_bars_back(low, 500)

// ==================== Inputs ====================

lookback_bars         = input.int(240,   "Lookback bars",          minval = 10,  group = "General",         tooltip = "Lookback bars for trend detection. Pine Screener is capped at 500 bars, so larger values can be inaccurate there.")
trading_hours_per_day = input.float(6.5, "Trading hours per day",   minval = 0.1, group = "General",         tooltip = "Trading hours per day. Default 6.5 is for US stocks. Used only to convert intraday rate readouts to %/day")
min_downtrend_bars    = input.int(20,    "Min run-up bars",        minval = 1,   group = "Trend detection", tooltip = "Minimum run-up bars before the peak")
min_uptrend_bars      = input.int(5,     "Min breakdown bars",     minval = 1,   group = "Trend detection", tooltip = "Minimum breakdown bars after the peak")

min_uptrend_rate       = input.float(0.3,  "Min breakdown rate [%/day]", group = "Trend entry", tooltip = "Minimum breakdown slope magnitude for entry (linear %/day). Compared as breakdown_rate <= -value")
max_downtrend_rate     = input.float(0.0,  "Run-up rate limit [%/day]",  group = "Trend entry", tooltip = "Prior run-up constraint. Default 0 requires run-up >= 0; more negative values require a steeper run-up")
min_vtrend             = input.float(-0.1, "Min V-Trend [%/day]",        group = "Trend entry", tooltip = "Caps trend_diff (breakdown + run-up balance). Positive means run-up exceeds breakdown")
min_entry_vfib_ratio   = input.float(0.5,  "Min entry V-Fib",            group = "Trend entry", tooltip = "Entry zone lower bound on V-Fib (how far price has dropped)")
max_entry_vfib_ratio   = input.float(1.0,  "Max entry V-Fib",            group = "Trend entry", tooltip = "Entry zone upper bound on V-Fib")
min_entry_leading_gain = input.float(0.5,  "Min entry leading drop [%]", group = "Trend entry", tooltip = "Leading drop below downtrend base (leading_days x breakdown rate)")
unlock_vfib_ratio      = input.float(3.0,  "Unlock V-Fib",               group = "Trend entry", tooltip = "Re-arm the entry once V-Fib drops past this (one signal per setup)")

show_baseball         = input.bool(true, "Show baseball closer",   group = "Display")
show_entry            = input.bool(true, "Show trend entry",       group = "Display")


// ==================== Geometric helpers ====================
// Linear price space: slopes are price-units/bar.

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

line_intersect_x(int x_a, float y_a, float sa, int x_b, float y_b, float sb) =>
    int result = na
    if not na(y_a) and not na(y_b)
        float denom = sb - sa
        if denom != 0
            result := math.round((y_a - sa * float(x_a) - y_b + sb * float(x_b)) / denom)
    result

vfib_ratio_at_anchors(int x1, float y1, int down_x2, float down_y2, float diff, float price) =>
    float r = na
    if not na(price) and not na(y1) and not na(down_y2) and not na(diff) and not na(x1) and not na(down_x2)
        int dx = down_x2 - x1
        if dx != 0
            float unit = diff / 0.236
            float base_y = y1 + (down_y2 - y1) / dx * (bar_index - x1)
            float raw = (base_y - price) / unit
            r := na(raw) ? 0 : raw
    r


// ==================== Shared helpers ====================

draw_forward_limit_bars = 500

float bars_per_day = timeframe.ismonthly ? 1.0 / 20 : timeframe.isweekly ? 1.0 / 5 : timeframe.isdaily ? 1.0 : trading_hours_per_day * 3600 / math.max(timeframe.in_seconds(), 1)

can_draw(int x) =>
    x >= bar_index - draw_forward_limit_bars and x <= bar_index + draw_forward_limit_bars


// ==================== TrendFinder ====================
// Detects the inverted-V anchors (prior-leg bottom, peak, breakdown) and the
// current resistance line. Trend rates update every bar (linear %/day);
// resistance detection runs on the last bar only.

type TrendFinder
    int    down_x2 = na
    float  down_y2 = na
    int    x1 = na
    float  y1 = na
    float  down_diff = na   // max distance of mid-bottom below base line
    int    up_x2 = na
    float  up_y2 = na
    float  up_slope = na
    int    sup_x1 = na
    float  sup_y1 = na
    float  sup_slope = na
    array<int>   sup_cand_x1 = na
    array<float> sup_cand_y1 = na
    array<float> sup_cand_slope = na
    int    support_basis_x1 = na
    int    support_basis_up_x2 = na
    int    btm_abs = na          // incremental peak tracker: absolute bar_index of highest high since the bottom
    int    btm_left = na         // previous bar's scan-window left edge (absolute), to detect window changes
    float  uptrend_rate = na
    float  downtrend_rate = na   // linear %/day from mid-bottom-adjusted run-up leg
    float  trend_diff = na
    float  vfib_ratio = na
    float  leading_days = na
    float  support_rate = na
    float  support_lead = na
    float  support_age_days = na

method isValid(TrendFinder self) =>
    not na(self.down_diff)

method get_support_left_x(TrendFinder self, int x1, float y1, float slope) =>
    int xi = line_intersect_x(x1, y1, slope, self.x1, self.y1, self.up_slope)
    na(xi) ? self.x1 : xi

method get_vfib_ratio(TrendFinder self, float price) =>
    not self.isValid() ? na : vfib_ratio_at_anchors(self.x1, self.y1, self.down_x2, self.down_y2, self.down_diff, price)

method get_leading_days(TrendFinder self, float price) =>
    if na(self.up_slope) or self.up_slope == 0 or na(price) or na(self.x1)
        0.0
    else
        float line_y = self.y1 + self.up_slope * (bar_index - self.x1)
        (price - line_y) / (self.up_slope * bars_per_day)

method update(TrendFinder self) =>
    // top_i: lowest-low offset, clamped to available bars (length is bar_index + const, which Pine bounds
    // statically, so its buffer is replay-safe). Lets detection work before lookback_bars of history exists.
    top_i = -ta.lowestbars(low, math.min(lookback_bars, bar_index + 1))
    // btm_i: highest high since the bottom, tracked incrementally over high[] (O(1) amortized). NOT ta.highestbars:
    // a "since-bottom" length must depend on top_i (a price-derived series) which Pine can't statically bound,
    // so ta.highestbars' internal buffer under-allocates and overflows in Bar Replay (max_bars_back can't fix
    // it; toggling visibility temporarily clears it). Direct high[] access uses high's 500-bar buffer instead.
    int n        = math.max(nz(top_i, 5), 5)   // scan window length (offsets 0..n-1)
    int left_now = bar_index - n + 1           // window left edge, absolute bar_index
    int btm_i    = 0
    if not na(self.btm_abs) and not na(high) and left_now >= self.btm_left and self.btm_abs >= left_now
        // window grew at the front only: fold in the current bar (ties keep the newer bar)
        if high >= high[bar_index - self.btm_abs]
            self.btm_abs := bar_index
        btm_i := bar_index - self.btm_abs
    else
        // rescan: first bar, window changed, or running max aged out
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
            self.up_x2     := na
            self.up_y2     := na
            self.up_slope  := na

        // ---- peak of run-up
        if not na(self.down_x2) and (na(self.x1) or self.down_x2 != self.x1)
            if (na(self.x1) or bar_index - btm_i > self.x1) and bar_index - btm_i != self.down_x2
                self.x1        := bar_index - btm_i
                self.y1        := high[btm_i]
                self.up_x2     := na
                self.up_y2     := na
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
                    self.up_x2    := bar_index - j
                    self.up_y2    := high[j]
                    self.up_slope := s

    // ---- trend rate readouts (linear %/day, normalized by leg-start price)
    self.uptrend_rate   := (na(self.up_slope) or na(self.y1) or self.y1 == 0) ? 0 : 100.0 * self.up_slope / self.y1 * bars_per_day
    self.downtrend_rate := (na(self.down_diff) or na(self.down_y2) or self.down_y2 == 0 or self.down_x2 == self.x1) ? 0 : 100.0 * (self.down_y2 - self.down_diff - self.y1) / float(self.down_x2 - self.x1) / self.down_y2 * bars_per_day
    self.trend_diff     := self.uptrend_rate + self.downtrend_rate
    self.vfib_ratio     := self.get_vfib_ratio(low)
    self.leading_days   := self.get_leading_days(high)

method find_support(TrendFinder self) =>
    self.sup_x1    := na
    self.sup_y1    := na
    self.sup_slope := na
    if na(self.sup_cand_x1)
        self.sup_cand_x1    := array.new_int()
        self.sup_cand_y1    := array.new_float()
        self.sup_cand_slope := array.new_float()

    if not na(self.x1) and not na(self.up_slope) and not na(self.y1)
        int n_bars = math.min(bar_index - self.x1, lookback_bars - 1)
        if n_bars >= 2
            bool basis_changed = na(self.support_basis_x1) or (self.support_basis_x1 != self.x1 or self.support_basis_up_x2 != self.up_x2)
            if basis_changed
                array.clear(self.sup_cand_x1)
                array.clear(self.sup_cand_y1)
                array.clear(self.sup_cand_slope)
                self.support_basis_x1    := self.x1
                self.support_basis_up_x2 := self.up_x2

            int   j_from       = basis_changed ? n_bars - 1 : 1
            float up_x1        = float(self.x1)
            float up_intercept = self.up_slope * up_x1 - self.y1

            for j = j_from to 1
                if not na(high[j])
                    for i = n_bars to j + 1
                        if not na(high[i])
                            float slope = (high[j] - high[i]) / float(i - j)
                            if slope >= self.up_slope
                                continue
                            float denom = self.up_slope - slope
                            float xi    = denom == 0 ? up_x1 : (high[i] - slope * float(bar_index - i) + up_intercept) / denom
                            int start   = math.max(i - 1, bar_index - math.round(xi))
                            if start > n_bars
                                continue
                            bool broken = false
                            for k = 1 to start
                                if not na(high[k]) and high[k] > high[i] + slope * float(i - k)
                                    broken := true
                                    break
                            if not broken
                                array.push(self.sup_cand_x1,    bar_index - i)
                                array.push(self.sup_cand_y1,    high[i])
                                array.push(self.sup_cand_slope, slope)

            int n = array.size(self.sup_cand_x1)
            if n > 0
                for idx = n - 1 to 0
                    int   x1c     = array.get(self.sup_cand_x1, idx)
                    float y1c     = array.get(self.sup_cand_y1, idx)
                    float slope   = array.get(self.sup_cand_slope, idx)
                    int   i       = bar_index - x1c
                    bool  invalid = i > lookback_bars - 1
                    if not invalid and not na(high[1]) and high[1] > y1c + slope * float(i - 1)
                        invalid := true
                    if invalid
                        array.remove(self.sup_cand_x1,    idx)
                        array.remove(self.sup_cand_y1,    idx)
                        array.remove(self.sup_cand_slope, idx)
                n := array.size(self.sup_cand_x1)

            if n > 0
                for idx = 0 to n - 1
                    float slope = array.get(self.sup_cand_slope, idx)
                    if na(self.sup_slope) or slope < self.sup_slope
                        self.sup_x1    := array.get(self.sup_cand_x1, idx)
                        self.sup_y1    := array.get(self.sup_cand_y1, idx)
                        self.sup_slope := slope
    else
        array.clear(self.sup_cand_x1)
        array.clear(self.sup_cand_y1)
        array.clear(self.sup_cand_slope)
        self.support_basis_x1    := na
        self.support_basis_up_x2 := na

    // ---- resistance rate readouts (linear %/day; only valid on the bar find_support runs)
    bool  has_support = not na(self.sup_slope)
    float support_y   = has_support ? self.sup_y1 + self.sup_slope * float(bar_index - self.sup_x1) : na
    self.support_rate     := has_support and self.sup_y1 != 0 ? 100.0 * self.sup_slope / self.sup_y1 * bars_per_day : na
    self.support_lead     := has_support and close != 0 ? 100.0 * (close - support_y) / close : na
    self.support_age_days := has_support ? (bar_index - self.sup_x1) / bars_per_day : na


// ==================== Resistance-based Fib anchors ====================
// Anchors for the V-Ladder Fib, drawn off the immediately-previous resistance
// line (smallest slope above the current resistance). Returns
// SlantedFib.set_anchors() args; falls back to the peak origin when no previous
// resistance exists.
support_fib_anchors(TrendFinder trend) =>
    int   sx1 = na
    float sy1 = na
    int   sux = na
    float suy = na
    float sld = na
    int   sdx2 = trend.down_x2
    float sdy2 = trend.down_y2
    if not na(trend.sup_cand_x1) and not na(trend.sup_slope) and not na(trend.down_x2) and not na(trend.down_y2)
        // Previous resistance = candidate with the smallest slope strictly above sup_slope
        float prev_slope = na
        int   prev_x1    = na
        float prev_y1    = na
        for idx = 0 to trend.sup_cand_x1.size() - 1
            float s = trend.sup_cand_slope.get(idx)
            if s > trend.sup_slope and (na(prev_slope) or s < prev_slope)
                prev_slope := s
                prev_x1    := trend.sup_cand_x1.get(idx)
                prev_y1    := trend.sup_cand_y1.get(idx)

        if not na(prev_slope) and not na(prev_y1) and trend.down_x2 != prev_x1
            float new_diff = max_low_below_line(prev_x1, prev_y1, trend.down_x2, trend.down_y2)
            int   x4 = line_intersect_x(prev_x1, prev_y1, prev_slope, trend.sup_x1, trend.sup_y1, trend.sup_slope)
            if not na(new_diff) and not na(x4) and x4 != prev_x1
                sx1 := prev_x1
                sy1 := prev_y1
                sux := x4
                suy := prev_y1 + prev_slope * float(x4 - prev_x1)
                sld := new_diff
        // Fallback: no previous resistance — use the peak origin so the ladder still renders
        if na(sx1) and trend.isValid()
            sx1 := trend.x1
            sy1 := trend.y1
            sux := trend.up_x2
            suy := trend.up_y2
            sld := trend.down_diff
    [sx1, sy1, sdx2, sdy2, sux, suy, sld]


// ==================== SlantedFib drawing ====================
// Holds Fib anchor geometry and renders the slanted parallelogram + V-Fib label.
// support_anchored = false -> rainbow primary; true -> purple V-Ladder key levels.

type SlantedFib
    array<line> _lines = na
    array<label> _labels = na   // baseball closer emoji labels at fib×resistance intersections (V-Ladder only)
    label vfib_label = na
    int   x1 = na
    int   down_x2 = na
    int   up_x2 = na
    float y1 = na
    float down_y2 = na
    float up_y2 = na
    float diff = na
    // Boundary lines for resistance-anchored fib endpoints (left/right = fib level intersection with each line)
    int   left_anchor_x  = na   // anchor x of line whose intersection defines left endpoint
    float left_anchor_y  = na
    int   boundary_x     = na   // anchor x of line whose intersection defines right endpoint
    float boundary_y     = na
    float boundary_slope = na   // shared slope for both lines above

    // Optional right clip line: caps right endpoint at min(boundary intersection, clip intersection)
    int   clip_right_x     = na
    float clip_right_y     = na
    float clip_right_slope = na

    bool  support_anchored = false

method _get_lines(SlantedFib self) =>
    if na(self._lines)
        self._lines := array.new_line()
    self._lines

method _get_labels(SlantedFib self) =>
    if na(self._labels)
        self._labels := array.new_label()
    self._labels

method clear(SlantedFib self) =>
    lines = self._get_lines()
    if array.size(lines) > 0
        for ln in lines
            line.delete(ln)
        array.clear(lines)
    labels = self._get_labels()
    if array.size(labels) > 0
        for lb in labels
            label.delete(lb)
        array.clear(labels)
    if not na(self.vfib_label)
        self.vfib_label.delete()
        self.vfib_label := na

method isValid(SlantedFib self) =>
    not na(self.x1) and not na(self.down_x2) and not na(self.up_x2) and not na(self.y1) and not na(self.down_y2) and not na(self.up_y2) and not na(self.diff)

method vfib_ratio_at(SlantedFib self, float price) =>
    not self.isValid() ? na : vfib_ratio_at_anchors(self.x1, self.y1, self.down_x2, self.down_y2, self.diff, price)

method set_anchors(SlantedFib self, int x1, float y1, int down_x2, float down_y2, int up_x2, float up_y2, float diff) =>
    self.x1      := x1
    self.y1      := y1
    self.down_x2 := down_x2
    self.down_y2 := down_y2
    self.up_x2   := up_x2
    self.up_y2   := up_y2
    self.diff    := diff

method draw(SlantedFib self) =>
    self.clear()
    if self.isValid()
        lines = self._get_lines()
        float unit    = self.diff / 0.236
        float dx_down = float(self.down_x2 - self.x1)
        float dx_up   = float(self.up_x2  - self.x1)
        float dy_up   = self.up_y2   - self.y1
        float dy_down = self.down_y2 - self.y1
        ratios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.414, 1.618, 2, 2.272, 2.414, 2.618, 3)

        float base_slope = dx_down == 0 ? 0 : dy_down / dx_down

        for r in ratios
            // Resistance-anchored Fib: draw only key levels
            if self.support_anchored and r != 0.236 and r != 0.5 and r != 1.0 and r != 1.618 and r != 2.272 and r != 3.0
                continue
            float offset = -unit * r   // negative: Fib projects DOWNWARD from the peak base

            color rainbow_c = switch r
                0     => color.red
                0.5   => color.gray
                1.0   => color.gray
                1.618 => color.green
                2.272 => color.green
                3.0   => color.green
                =>       color.gray
            string rainbow_style = switch r
                0     => line.style_solid
                0.5   => line.style_solid
                1.0   => line.style_solid
                1.618 => line.style_solid
                =>       line.style_dotted
            color  c     = self.support_anchored ? color.purple     : rainbow_c
            string style = self.support_anchored ? line.style_solid : rainbow_style

            float x_start = na
            float x_end   = na
            float y_start = na
            float y_end   = na

            if self.support_anchored and not na(self.boundary_slope) and not na(self.left_anchor_x) and not na(self.left_anchor_y) and not na(self.boundary_x) and not na(self.boundary_y)
                // Endpoint rendering: fib level intersected with the left/right boundary lines (r=0.236 uses left_anchor, else x1/y1)
                float denom = self.boundary_slope - base_slope
                if denom == 0
                    continue

                bool  use_va_left = r == 0.236
                float left_x      = use_va_left ? float(self.left_anchor_x) : float(self.x1)
                float left_y      = use_va_left ? self.left_anchor_y : self.y1
                float fib_y       = self.y1 + offset

                x_start := (fib_y - left_y + self.boundary_slope * left_x - base_slope * float(self.x1)) / denom
                y_start := left_y + self.boundary_slope * (x_start - left_x)

                x_end := (fib_y - self.boundary_y + self.boundary_slope * float(self.boundary_x) - base_slope * float(self.x1)) / denom
                y_end := self.boundary_y + self.boundary_slope * (x_end - float(self.boundary_x))

                // Cap right end at clip_right line intersection if it is closer (smaller x) than the boundary intersection
                if not na(self.clip_right_slope) and not na(self.clip_right_x) and not na(self.clip_right_y)
                    float denom_clip = self.clip_right_slope - base_slope
                    if denom_clip != 0
                        float x_clip = (fib_y - self.clip_right_y + self.clip_right_slope * float(self.clip_right_x) - base_slope * float(self.x1)) / denom_clip
                        if not na(x_clip) and x_clip >= float(self.x1) and (x_clip < x_end or x_end < float(self.x1))
                            x_end := x_clip
                            y_end := self.y1 + offset + base_slope * (x_end - float(self.x1))

                // Fall back to left-boundary start if r=0.236 anchor lands outside the [left boundary, resistance] strip
                if use_va_left
                    float x_start_bound = (fib_y - self.y1 + self.boundary_slope * float(self.x1) - base_slope * float(self.x1)) / denom
                    float lo = math.min(x_start_bound, x_end)
                    float hi = math.max(x_start_bound, x_end)
                    if x_start < lo or x_start > hi
                        x_start := x_start_bound
                        y_start := self.y1 + self.boundary_slope * (x_start - float(self.x1))
            else
                // Standard parallelogram rendering (primary)
                float D = dx_down * dy_up - dy_down * dx_up
                if D == 0
                    continue
                float s = (offset * dx_up) / D
                x_start := float(self.x1) + s * dx_down
                x_end   := x_start + dx_down
                y_start := (self.y1 + offset) + s * dy_down
                y_end   := y_start + dy_down

            int x_fib_left  = math.round(x_start)
            int x_fib_right = math.round(x_end)
            if can_draw(x_fib_left) and can_draw(x_fib_right) and (not self.support_anchored or x_end >= float(self.x1))
                array.push(lines, line.new(x_fib_left, y_start, x_fib_right, y_end, color = c, style = style))

        // Left boundary line: from the peak, parallel to resistance, down to the r=3.0 reach
        if self.support_anchored and not na(self.boundary_slope) and not na(self.x1) and not na(self.y1)
            float denom_lb = self.boundary_slope - base_slope
            if denom_lb != 0
                float dx_top = -unit * 3.0 / denom_lb
                int   x_b = math.round(float(self.x1) + dx_top)
                float y_b = self.y1 + self.boundary_slope * dx_top
                if can_draw(self.x1) and can_draw(x_b)
                    array.push(lines, line.new(self.x1, self.y1, x_b, y_b, color = color.purple, style = line.style_solid))

        // V-Fib label only on primary (non-resistance-anchored) Fib
        if not self.support_anchored
            self.vfib_label := label.new(bar_index, low, str.tostring(self.vfib_ratio_at(low), "#.##"), color = color.red, style = label.style_label_up)

        // Baseball closer emoji below the first bar whose low crossed each V-Ladder fib level (single-pass, latest bar only)
        if self.support_anchored and show_baseball and barstate.islast
            array<float>  bb_ratios  = array.from(0.5, 1.0, 1.618, 2.272, 3.0)
            array<string> bb_emojis  = array.from("🧤", "🔴", "🔴", "🔴", "🔒")
            array<int>    bb_found_x = array.from(-1, -1, -1, -1, -1)
            array<float>  bb_found_l = array.from(-1.0, -1.0, -1.0, -1.0, -1.0)
            int bb_remaining = 5
            int bb_scan_from = math.max(self.x1 + 1, bar_index - 499)   // skip bars beyond history buffer
            for bar_x = bb_scan_from to bar_index
                if bb_remaining == 0
                    break
                float bar_low_val = low[bar_index - bar_x]
                if not na(bar_low_val)
                    float fib_base = self.y1 + base_slope * float(bar_x - self.x1)
                    for i = 0 to 4
                        if array.get(bb_found_x, i) < 0 and bar_low_val <= fib_base - unit * array.get(bb_ratios, i)
                            array.set(bb_found_x, i, bar_x)
                            array.set(bb_found_l, i, bar_low_val)
                            bb_remaining -= 1
            for i = 0 to 4
                int cb = array.get(bb_found_x, i)
                if cb >= 0 and can_draw(cb)
                    array.push(self._get_labels(), label.new(cb, array.get(bb_found_l, i), array.get(bb_emojis, i), color = color.new(color.purple, 80), textcolor = color.white, style = label.style_label_up, size = size.normal))


// ==================== TrendOverlay ====================
// Single-instance overlay tied to the primary trend: resistance diagonal (purple)
// and peak-to-resistance breakdown line (red).

type TrendOverlay
    array<line> _lines = na

method _get_lines(TrendOverlay self) =>
    if na(self._lines)
        self._lines := array.new_line()
    self._lines

method clear(TrendOverlay self) =>
    lines = self._get_lines()
    if array.size(lines) > 0
        for ln in lines
            line.delete(ln)
        array.clear(lines)

method render(TrendOverlay self, TrendFinder trend) =>
    self.clear()
    lines = self._get_lines()

    if trend.isValid() and not na(trend.sup_slope) and not na(trend.up_slope) and not na(trend.sup_y1)
        int   x_left = trend.get_support_left_x(trend.sup_x1, trend.sup_y1, trend.sup_slope)
        float y_left = trend.y1 + trend.up_slope * float(x_left - trend.x1)

        // Red line: peak along breakdown to resistance intersection
        if can_draw(x_left)
            array.push(lines, line.new(trend.x1, trend.y1, x_left, y_left, color = color.red))

        // Resistance diagonal (purple), projected forward to where it reaches the current close
        float xr      = trend.sup_slope == 0 ? float(bar_index) : float(trend.sup_x1) + (close - trend.sup_y1) / trend.sup_slope
        int   x_right = math.min(math.round(xr), bar_index + draw_forward_limit_bars)
        float y_right = trend.sup_y1 + trend.sup_slope * float(x_right - trend.sup_x1)
        if x_left < x_right
            array.push(lines, line.new(x_left, y_left, x_right, y_right, color = color.purple))


// ==================== Main ====================

var trend         = TrendFinder.new()
var fib_main      = SlantedFib.new()
var fib_ladder    = SlantedFib.new(support_anchored = true)
var trend_overlay = TrendOverlay.new()

trend.update()

if barstate.islast
    trend.find_support()

    fib_main.set_anchors(trend.x1, trend.y1, trend.down_x2, trend.down_y2, trend.up_x2, trend.up_y2, trend.down_diff)
    fib_main.draw()

    [sx1, sy1, sdx, sdy, sux, suy, sld] = support_fib_anchors(trend)
    fib_ladder.set_anchors(sx1, sy1, sdx, sdy, sux, suy, sld)
    fib_ladder.left_anchor_x  := trend.x1
    fib_ladder.left_anchor_y  := trend.y1
    fib_ladder.boundary_x     := trend.sup_x1
    fib_ladder.boundary_y     := trend.sup_y1
    fib_ladder.boundary_slope := trend.sup_slope
    fib_ladder.clip_right_x     := trend.x1
    fib_ladder.clip_right_y     := trend.y1
    fib_ladder.clip_right_slope := trend.up_slope
    fib_ladder.draw()

    trend_overlay.render(trend)


// ==================== Trend entry signal ====================
// Marks a trend entry from the per-bar rates / V-Fib / lead (no rating, no lower
// timeframe). Fires once per setup: locks on entry, re-arms on a new peak or
// when V-Fib passes unlock. Inputs are positive magnitudes; the breakdown
// direction lives in the comparison signs (uptrend_rate is the active breakdown
// leg, negative; downtrend_rate is the prior run-up, positive).

var bool entry_locked = false
var int  entry_basis  = -1
var int  entry_bar    = na   // bar_index of the last trend entry, for Age

int entry_basis_now = nz(trend.x1, -1)
if entry_basis_now != entry_basis
    entry_locked := false
    entry_basis  := entry_basis_now
if not na(trend.vfib_ratio) and trend.vfib_ratio >= unlock_vfib_ratio
    entry_locked := false

bool  entry_trend_cond = trend.uptrend_rate <= -min_uptrend_rate and trend.downtrend_rate >= -max_downtrend_rate and trend.trend_diff <= -min_vtrend
bool  entry_zone       = not na(trend.vfib_ratio) and trend.vfib_ratio >= min_entry_vfib_ratio and trend.vfib_ratio <= max_entry_vfib_ratio
float entry_lead       = trend.leading_days * trend.uptrend_rate
bool  entry_signal     = entry_trend_cond and entry_zone and entry_lead <= -min_entry_leading_gain and not entry_locked
if entry_signal
    entry_locked := true
    entry_bar    := bar_index

bgcolor(show_entry and entry_signal ? color.new(color.red, 50) : na, title = "Trend entry")
alertcondition(entry_signal, "Trend entry", "Rebound V-Fib RT Closer: trend entry")


// ==================== Data window readouts ====================
// Numeric readouts only (Pine Screener / data window / status line) — no chart
// line, no separate pane. Resistance rows are last-bar only.

disp_data = display.pine_screener + display.data_window
disp_stat = disp_data + display.status_line

plot(entry_locked ? bar_index - entry_bar + 1 : 0, "Age",  display = disp_data, precision = 0)
plot(trend.vfib_ratio,                        "V-Fib",    display = disp_stat, precision = 3)
plot(trend.trend_diff,                        "V-Trend",  display = disp_stat, color = trend.trend_diff > 0 ? color.red : color.blue, precision = 3)
plot(trend.support_age_days,                  "SupAge",   display = disp_data, precision = 0)
plot(trend.support_rate,                      "Sup%/d",   display = disp_stat, color = color.purple, precision = 3)
plot(trend.support_lead,                      "SupLead%", display = disp_data, precision = 3)
plot(trend.leading_days * trend.uptrend_rate, "Lead%",    display = disp_data, precision = 3)
plot(trend.uptrend_rate,                      "Up%/d",    display = disp_data, color = color.red,    precision = 3)
plot(trend.downtrend_rate,                    "Down%/d",  display = disp_data, color = color.blue,   precision = 3)
````
