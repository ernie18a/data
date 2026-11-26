# Rebound V-Fib Log

- url: https://www.tradingview.com/script/vRIIU25t/
- type: indicator
- pine_id: PUB;645b927bc83e44d5891329ee219df2c2
- version: 7.0

## Description

[b]Rebound V-Fib Log[/b]
A log-scale variant of Rebound V-Fib. Trend geometry - V-shape detection, slanted Fibonacci levels, support lines - is computed in log price space, so on log-scale charts the bands and trend lines render straight, representing constant %/day rates of change. Intended for log-scale charts only.

For US equities on intraday/daily timeframes. Adjust 'Trading hours per day' for other markets (default 6.5).

The built-in back-test verifies entries and trailing-stop hits on lower-timeframe bars within each chart bar. It ignores slippage, commissions, liquidity and compounding - reference use only.

[b]DIFFERENCES FROM Rebound V-Fib[/b]
[list]
[*]Trend slopes, Fib levels and support lines are computed in log(price) space
[*]Rate outputs (Up%/d, Down%/d, Sup%/d) use log-space slopes. Numerically interchangeable with the linear version's %/day at typical trend speeds
[*]V-Fib Ratio: position on the slanted Fib band, computed as a log-distance ratio. The value equals the Fib level number - e.g. V-Fib = 0.236 means price is on the 0.236 line (the downtrend's middle top), V-Fib = 1.0 means price is on the 1.0 line
[*]Trail anchored as % of trail high (scales with price), not absolute price width
[/list]

[b]OUTPUTS[/b]

Overlay:
[list]
[*]Slanted Fib band (multi-colored levels), blue uptrend line, purple support diagonal - all log-straight on log charts
[*]V-Fib Ratio label on the last bar
[*]Dotted stop guides: blue/purple = active trend/support entry, orange = current support trail
[/list]

Sub-pane:
[list]
[*]Capital - equity curve from the back-test start
[*]LONG label on entry - entry price, rate, V-Fib, lead, trail level, gap %
[*]EXIT label on close - exit price, exit reason (Trail / Trend / V-Fib) and P/L
[*]IF label - last-bar support-entry forecast, shown when V-Fib has overshot the entry window and a pullback-rebound is confirmed
[/list]

Background color (both panes): blue/purple on entry bars (trend/support), red/gray on close bars (loss/gain).

Status line + Data Window + Screener:
[list]
[*]V-Fib - current V-Fib Ratio
[*]V-Trend - net rate (Up + Down), %/day
[*]Sup%/d - support slope, %/day
[*]SupTrail% - max drawdown since support start (floored by Min support trail), used as trail gap
[*]Capital - current equity value
[*]Risk - worst open-trade drawdown across the back-test (<= 0)
[*]Gain/d - average gain per day spent in completed trades
[/list]

Data Window + Screener:
[list]
[*]3M% / M% / W% / D% - change from 3M / 1M / 1W / day close
[*]Age - bars held in the current trade (= days on daily timeframe)
[*]SupAge - days since the current support line was established
[*]SupLead% - close above support, as % of close
[*]Lead% - leading days x uptrend rate. Leading days = days the current price is ahead of / behind the uptrend baseline (positive when above, negative when below)
[*]Up%/d, Down%/d - trend slopes, %/day
[/list]

Data Window only:
[list]
[*]ActiveTrail, SupportTrail - current stop prices
[/list]

[b]INPUTS[/b]

General:
[list]
[*]Lookback bars - V-shape detection window
[*]Support last bar only - compute support only on the last bar (faster, disables historical support back-test)
[*]Trading hours per day - intraday day-to-bar conversion (6.5 = US equities)
[/list]

Trend detection:
[list]
[*]Min downtrend bars / Min uptrend bars - minimum bars from top to V-bottom / from V-bottom to now
[*]Min uptrend rate - reject if uptrend slope below this (%/day)
[*]Max downtrend rate - reject if downtrend slope exceeds this (typically <= 0)
[*]Min V-Trend - reject if Up + Down rate is below this
[/list]

Entry conditions:
[list]
[*]Min / Max entry V-Fib ratio - lower / upper bound of the entry window on the slanted Fib band
[*]Min entry leading gain - minimum Lead% required at entry
[*]Max trend trail - cap on the trail gap for trend entries, % of entry price
[*]Min support pullback - V-Fib must drop from its peak by (peak x this ratio) before trough tracking starts
[*]Min support rebound - V-Fib must then rise by this amount from the post-peak trough to arm the support entry
[*]Min support trail - floor on the support trail gap (%)
[*]Max support trail - cap on the trail gap for support entries, % of entry price
[/list]

Exit conditions:
[list]
[*]Only exit by trailing stop - disable the V-Fib-based exit only; rate-based exit and trailing stop remain active
[*]Exit uptrend diff / Keep uptrend rate - rate-based exit fires when uptrend rate falls below both Keep uptrend rate AND (entry rate + Exit uptrend diff). Exit uptrend diff is typically negative
[*]Exit V-Fib ratio - V-Fib-based exit triggers when V-Fib reaches this
[*]Unlock V-Fib ratio - release the trend-entry lock when V-Fib reaches this (should be > Exit V-Fib ratio). The lock is set on each trend entry and is also released by the rate-based exit
[/list]

Back-test:
[list]
[*]Enable backtest - run the simulation
[*]Start capital - starting capital (default 1000)
[*]Capital risk - fraction of capital risked per trade (default 0.2 = 20%). Back-test outputs (Risk, Gain/d, Capital deltas) scale with Start capital x Capital risk
[*]Backtest bars - recent bars included
[*]Min trade bars - hide Gain/d until this many bars have been spent in trades
[/list]

Display:
[list]
[*]Show entry / support entry / exit label - toggle LONG / IF / EXIT
[*]Show labels on capital - place labels on the capital curve instead of by rate value
[/list]

[b]DISCLAIMER[/b]
This script is provided "AS IS" without warranty of any kind. It is for informational purposes only and does not constitute financial advice. Past performance is not indicative of future results. The author is not liable for any losses arising from the use of this script. Trade at your own risk.

## Source Code

````pine
//@version=6
// Version: 2.3.2 (2026-06-15)
//
// Rebound V-Fib Log: Detects rebound entries using a slanted Fibonacci-based
// V-shape, with all trend geometry computed in log price space. On log-scale
// price charts, the Fib channels and trendlines render as visually straight
// lines (constant %/bar growth). This indicator is intended for log-scale
// charts only.
//
// Semantics:
//   - uptrend_rate / downtrend_rate / support_rate are continuously
//     compounded %/day.
//   - vfib_ratio is the ratio of log-distances on the slanted Fib scale.
//   - Trailing stops are anchored by % of trail high (not absolute price
//     width), so the stop scales naturally with price.
//
// Recommended Pine Screener filter: Age 1 ~ 7
// Note: Pine Screener is limited to 500 bars of history.

indicator("Rebound V-Fib Log", overlay = false, max_lines_count = 100, precision = 3, max_bars_back = 500)

max_bars_back(low, 500)   // dynamic-length ta.lowestbars(low, top_i) defeats buffer auto-sizing; force full depth

import TradingView/TechnicalRating/3 as tr

// ==================== Inputs ====================

// General
lookback_bars            = input.int(240,   "Lookback bars",                group = "General",            tooltip = "Lookback bars. Larger values may be inaccurate in Pine Screener due to 500-bar history limit")
support_last_bar_only    = input.bool(false, "Support last bar only",       group = "General",            tooltip = "Calculate support lines only on the last bar. Faster, but support backtest will not work.")
trading_hours_per_day    = input.float(6.5, "Trading hours per day",        group = "General",            tooltip = "Trading hours per day. Default 6.5 is for US stocks. Adjust for other markets")

// Trend detection
min_downtrend_bars       = input.int(20,    "Min downtrend bars",           group = "Trend detection",    tooltip = "Minimum downtrend bars before rebound")
min_uptrend_bars         = input.int(5,     "Min uptrend bars",             group = "Trend detection",    tooltip = "Minimum uptrend bars after bottom")
min_uptrend_rate         = input.float(0.3, "Min uptrend rate [%/day]",     group = "Trend detection",    tooltip = "Minimum rebound slope for entry (continuously compounded %/day)")
max_downtrend_rate       = input.float(0.0, "Max downtrend rate [%/day]",   group = "Trend detection",    tooltip = "Maximum allowed downtrend slope. downtrend_rate is typically <= 0")
min_vtrend               = input.float(-0.1,"Min V-Trend [%/day]",          group = "Trend detection",    tooltip = "Minimum V-Trend (uptrend_rate + downtrend_rate). Negative means downtrend exceeds rebound.")

// Entry conditions
min_entry_vfib_ratio     = input.float(0.5, "Min entry V-Fib ratio",        group = "Entry conditions",   tooltip = "Entry zone lower bound on V-Fib")
max_entry_vfib_ratio     = input.float(1.0, "Max entry V-Fib ratio",        group = "Entry conditions",   tooltip = "Entry zone upper bound on V-Fib")
min_entry_leading_gain   = input.float(0.5, "Min entry leading gain [%]",   group = "Entry conditions",   tooltip = "Leading gain over uptrend base. leading_days x uptrend_rate")
max_trend_trail          = input.float(20.0,"Max trend trail [%]",          group = "Entry conditions",   tooltip = "Cap for trend entry trail gap. If gap to V-bottom exceeds this, the trail is capped at this value")
min_support_pullback     = input.float(0.15,"Min support pullback ratio",   minval=0.0, maxval=1.0, group = "Entry conditions", tooltip = "Pullback threshold = peak_vfib x this ratio")
min_support_rebound      = input.float(0.15,"Min support rebound",          group = "Entry conditions",   tooltip = "V-Fib must rise by this amount from the post-peak trough to confirm rebound")
min_support_trail        = input.float(0.0, "Min support trail [%]",        group = "Entry conditions",   tooltip = "Floor for support trail gap. If observed max drawdown is smaller, this value is used instead")
max_support_trail        = input.float(20.0,"Max support trail [%]",        group = "Entry conditions",   tooltip = "Cap for support entry trail gap. If gap to support_trail_stop exceeds this, the trail is capped at this value")
min_entry_rating         = input.float(0.3, "Min entry rating",             minval = -1.0, maxval = 1.0, group = "Entry conditions",   tooltip = "TradingView Technical Rating threshold for entries (-1 Strong Sell ~ +1 Strong Buy). Applies to both trend and support entries.")

// Exit conditions
exit_trail_only          = input.bool(true, "Only exit by trailing stop",   group = "Exit conditions")
exit_uptrend_diff        = input.float(-0.3,"Exit uptrend diff [%/day]",    group = "Exit conditions",    tooltip = "Exit if uptrend_rate < entry_rate + this")
keep_uptrend_rate        = input.float(0.3, "Keep uptrend rate [%/day]",    group = "Exit conditions",    tooltip = "Suppress trend-exit above this rate")
exit_vfib_ratio          = input.float(2.6, "Exit V-Fib ratio",             group = "Exit conditions",    tooltip = "Exit threshold. Keeps lock until unlock_vfib_ratio")
unlock_vfib_ratio        = input.float(3.0, "Unlock V-Fib ratio",           group = "Exit conditions",    tooltip = "Release lock, allow new entry. Should be > exit_vfib_ratio")

// Backtest
enable_backtest          = input.bool(true, "Enable backtest",              group = "Backtest")
start_capital            = input.float(1000.0, "Start capital",             group = "Backtest")
capital_risk             = input.float(0.2, "Capital risk",                 group = "Backtest",           tooltip = "Capital risk per trade (0.2 = 20% of capital)")
backtest_bars            = input.int(500,   "Backtest bars",                group = "Backtest",           tooltip = "Number of recent bars used for backtest")
min_trade_bars           = input.int(20,    "Min trade bars",               group = "Backtest",           tooltip = "Hide capital/day until N bars of entries accumulated")
enable_support_entry     = input.bool(true, "Enable support entry",         group = "Backtest",           tooltip = "If off, support rebound entries are not taken in backtest. Detection and IF labels remain visible for reference.")

// Display
show_entry_label         = input.bool(true, "Show entry label",             group = "Display")
show_support_entry_label = input.bool(true, "Show support entry label",     group = "Display")
show_exit_label          = input.bool(true, "Show exit label",              group = "Display")
show_labels_on_capital   = input.bool(true, "Show labels on capital",       group = "Display")
show_baseball            = input.bool(true, "Show baseball runner",         group = "Display")


// ==================== Log-space helpers ====================
// All trend geometry uses lp = log(price). Slopes are in log-price-units/bar
// (i.e. continuously-compounded growth rate per bar). Drawing converts back
// to price via from_lp() before passing to line.new, so on a log-scale chart
// the visually-straight pixel line between two log-correct endpoints is
// also log-straight (correct).

to_lp(float p)   => p > 0 ? math.log(p) : na
from_lp(float l) => math.exp(l)


// ==================== Geometric helpers ====================
// Max log-distance of any high above the base line connecting (x_a, y_a) and (x_b, y_b),
// scanning bars in the inclusive offset range between the two anchors.
max_high_above_line(int x_a, float y_a, int x_b, float y_b) =>
    float max_diff = na
    if y_a > 0 and y_b > 0 and x_a != x_b
        float lp_a = to_lp(y_a)
        float lp_b = to_lp(y_b)
        float slope = (lp_b - lp_a) / float(x_b - x_a)
        int i_from = math.min(bar_index - x_a, bar_index - x_b)
        int i_to   = math.max(bar_index - x_a, bar_index - x_b)
        for i = i_from to i_to
            if high[i] > 0
                float lp_line = lp_a + slope * float((bar_index - i) - x_a)
                float d = to_lp(high[i]) - lp_line
                if na(max_diff) or d > max_diff
                    max_diff := d
    max_diff

// Intersection x of two log lines: line A through (x_a, y_a) with slope sa,
// line B through (x_b, y_b) with slope sb. Returns na if parallel or anchors invalid.
line_intersect_x(int x_a, float y_a, float sa, int x_b, float y_b, float sb) =>
    int result = na
    if y_a > 0 and y_b > 0
        float denom = sb - sa
        if denom != 0
            result := math.round((to_lp(y_a) - sa * float(x_a) - to_lp(y_b) + sb * float(x_b)) / denom)
    result

// V-Fib ratio for arbitrary anchors and price. Caller must ensure anchors are valid.
vfib_ratio_at_anchors(int x1, float y1, int down_x2, float down_y2, float lp_diff, float price) =>
    float r = na
    if price > 0 and y1 > 0 and down_y2 > 0 and not na(lp_diff) and not na(x1) and not na(down_x2)
        int dx = down_x2 - x1
        if dx != 0
            float lp_unit = lp_diff / 0.236
            float base_lp_slope = (to_lp(down_y2) - to_lp(y1)) / dx
            float lp_base_y = to_lp(y1) + base_lp_slope * (bar_index - x1)
            float raw = (to_lp(price) - lp_base_y) / lp_unit
            r := na(raw) ? 0 : raw
    r


// ==================== Lower timeframe ====================

int lt_sec = timeframe.in_seconds() / 24
lt_sec := switch
    lt_sec > 3600 => 3600  // 1W, 1M
    lt_sec >= 300 => 300   // 2H, 4H, 1D
    => 60
lt_sec := math.min(timeframe.in_seconds(), lt_sec)
string lt_tf = timeframe.from_seconds(lt_sec)
lt_highs = request.security_lower_tf(syminfo.tickerid, lt_tf, high)
lt_lows  = request.security_lower_tf(syminfo.tickerid, lt_tf, low)
lt_h = lt_highs.size() > 0 and timeframe.in_seconds() > 60 ? lt_highs : array.from(high)
lt_l = lt_lows.size()  > 0 and timeframe.in_seconds() > 60 ? lt_lows  : array.from(low)

float bars_per_day = timeframe.ismonthly ? 1.0 / 20 : timeframe.isweekly ? 1.0 / 5 : timeframe.isdaily ? 1.0 : trading_hours_per_day * 3600 / timeframe.in_seconds()
draw_forward_limit_bars = 500


// ==================== Shared helpers ====================

can_draw(int x) =>
    x >= bar_index - draw_forward_limit_bars and x <= bar_index + draw_forward_limit_bars

is_wide_pct(float price, float floor_price, float limit_pct) =>
    not na(price) and not na(floor_price) and price > 0 and 100.0 * (price - floor_price) / price > limit_pct

[ratingTotal, _ratingMA, _ratingOther] = tr.calcRatingAll()
bool rating_ok = not na(ratingTotal) and ratingTotal >= min_entry_rating

new_entry_label(float y, bool is_support, string action, float price, string rate_name, float rate, float vfib, float lead, float trail, float gap_pct, bool wide_gap) =>
    string gap_text = wide_gap ? str.format("*{0,number,#.##}%*", gap_pct) : str.format("{0,number,#.##}%", gap_pct)
    string info = str.format("{0} @ {1,number,#.##}\n{2}: {3,number,#.##}%/d\nV-Fib: {4,number,#.##}\nLead: {5,number,#.##}%\nTrail: {6,number,#.##}\nGap: {7}",
        action, price, rate_name, rate, vfib, lead, trail, gap_text)
    label.new(bar_index, y, info, color = is_support ? color.purple : color.blue, style = label.style_label_down, force_overlay = false)


// ==================== TrendFinder ====================
// Geometry stored in log space:
//   y1, down_y2, up_y2, sup_y1   : actual prices (anchor points)
//   down_lp_diff                 : max log-distance of mid-top above base log-line
//   down_lp_slope, up_lp_slope   : slope in log(price) per bar
//   sup_lp_slope                 : support log-slope per bar
//   *_rate                       : 100 * lp_slope * bars_per_day (cc %/day)
//   vfib_ratio                   : (lp(price) - lp_base_line) / (down_lp_diff / 0.236)

type TrendFinder
    bool   locked = false
    int    down_x2 = na
    float  down_y2 = na
    int    x1 = na
    float  y1 = na
    float  down_lp_diff = na
    float  down_lp_slope = na
    int    up_x2 = na
    float  up_y2 = na
    float  up_lp_slope = na
    float  uptrend_rate = na
    float  downtrend_rate = na
    float  trend_diff = na
    float  vfib_ratio = na
    float  leading_days = na
    int    sup_x1 = na
    float  sup_y1 = na
    float  sup_lp_slope = na
    float  support_rate = na
    float  support_lead = na
    float  support_trail_gap = na
    float  support_trail_stop = na
    float  support_age_days = na
    array<int>   sup_cand_x1 = na
    array<float> sup_cand_y1 = na
    array<float> sup_cand_lp_slope = na
    int    support_basis_x1 = na
    int    support_basis_up_x2 = na
    float  peak_vfib = na
    float  trough_vfib = na
    bool   support_arm = false
    int    peak_basis_x1 = na
    int    peak_basis_down_x2 = na
    float  support_entry_price = na

method isValid(TrendFinder self) =>
    not na(self.down_lp_diff)

method get_leading_days(TrendFinder self, float price) =>
    if na(self.up_lp_slope) or self.up_lp_slope == 0 or price <= 0
        0.0
    else
        float lp_line = to_lp(self.y1) + self.up_lp_slope * (bar_index - self.x1)
        (to_lp(price) - lp_line) / (self.up_lp_slope * bars_per_day)

method get_vfib_ratio(TrendFinder self, float price) =>
    not self.isValid() ? na : vfib_ratio_at_anchors(self.x1, self.y1, self.down_x2, self.down_y2, self.down_lp_diff, price)

// Intersection (in (bar_index, lp(price)) plane) of an arbitrary log-line
// (anchored at x1, y1 with slope lp_slope) and the uptrend log-line.
method get_support_left_x(TrendFinder self, int x1, float y1, float lp_slope) =>
    int xi = line_intersect_x(x1, y1, lp_slope, self.x1, self.y1, self.up_lp_slope)
    na(xi) ? self.x1 : xi

method update(TrendFinder self) =>
    if self.vfib_ratio >= unlock_vfib_ratio
        self.locked := false

    top_i = -ta.highestbars(high, lookback_bars)
    btm_i = -ta.lowestbars(low, math.max(nz(top_i, 5), 5))   // bars back of the lowest low since the top

    if low < self.y1 or (top_i >= min_downtrend_bars + min_uptrend_bars) and (btm_i >= min_uptrend_bars)
        // ---- top of downtrend
        if na(self.down_x2) or bar_index - top_i > self.down_x2
            self.down_x2       := bar_index - top_i
            self.down_y2       := high[top_i]
            self.x1            := na
            self.y1            := na
            self.down_lp_diff  := na
            self.down_lp_slope := na
            self.up_x2         := na
            self.up_y2         := na
            self.up_lp_slope   := na

        // ---- bottom of downtrend
        if not na(self.down_x2) and (na(self.x1) or self.down_x2 != self.x1)
            if (na(self.x1) or bar_index - btm_i > self.x1) and bar_index - btm_i != self.down_x2
                self.x1            := bar_index - btm_i
                self.y1            := low[btm_i]
                self.down_lp_diff  := na
                self.down_lp_slope := na
                self.up_x2         := na
                self.up_y2         := na
                self.up_lp_slope   := na

                // ---- middle top of downtrend (max log-distance above base line)
                float lp_diff = max_high_above_line(self.x1, self.y1, self.down_x2, self.down_y2)
                if not na(lp_diff)
                    self.down_lp_diff  := lp_diff
                    self.down_lp_slope := (to_lp(self.down_y2) + lp_diff - to_lp(self.y1)) / float(self.down_x2 - self.x1)

    // ---- middle bottom of uptrend (min log-slope from x1 to any later low)
    if not na(self.x1) and not na(self.y1) and self.y1 > 0 and bar_index > self.x1
        float lp_y1 = to_lp(self.y1)
        int   start = na(self.up_lp_slope) ? bar_index - self.x1 - 1 : 0
        for j = start to 0
            if low[j] > 0
                float s = (to_lp(low[j]) - lp_y1) / (bar_index - j - self.x1)
                if na(self.up_lp_slope) or s <= self.up_lp_slope
                    self.up_x2       := bar_index - j
                    self.up_y2       := low[j]
                    self.up_lp_slope := s

    self.uptrend_rate   := na(self.up_lp_slope)   ? 0 : 100.0 * self.up_lp_slope   * bars_per_day
    self.downtrend_rate := na(self.down_lp_slope) ? 0 : 100.0 * self.down_lp_slope * bars_per_day
    self.trend_diff     := self.uptrend_rate + self.downtrend_rate
    self.vfib_ratio     := self.get_vfib_ratio(high)
    self.leading_days   := self.get_leading_days(low)

    // ---- V-Fib pullback/rebound tracking + intraday support entry detection
    bool peak_basis_changed = na(self.peak_basis_x1) or self.peak_basis_x1 != self.x1 or self.peak_basis_down_x2 != self.down_x2
    if peak_basis_changed
        self.peak_vfib            := na
        self.trough_vfib          := na
        self.support_arm          := false
        self.peak_basis_x1        := self.x1
        self.peak_basis_down_x2   := self.down_x2
    self.support_entry_price := na
    for i = 0 to lt_h.size() - 1
        float vfib_i = self.get_vfib_ratio(lt_h.get(i))
        if not na(vfib_i)
            // Check rebound BEFORE updating peak so we don't lose trough reference
            if not na(self.trough_vfib) and vfib_i - self.trough_vfib >= min_support_rebound
                self.support_arm := true
            if na(self.peak_vfib) or vfib_i > self.peak_vfib
                if not na(self.peak_vfib) and vfib_i - self.peak_vfib > min_support_rebound
                    self.trough_vfib := na
                self.peak_vfib := vfib_i
            if not na(self.peak_vfib) and self.peak_vfib - vfib_i >= self.peak_vfib * min_support_pullback
                if na(self.trough_vfib) or vfib_i < self.trough_vfib
                    self.trough_vfib := vfib_i
            if self.support_arm and vfib_i > max_entry_vfib_ratio and na(self.support_entry_price)
                self.support_entry_price := lt_h.get(i)

method find_support(TrendFinder self, bool should_find) =>
    if should_find
        self.sup_x1       := na
        self.sup_y1       := na
        self.sup_lp_slope := na
        if na(self.sup_cand_x1)
            self.sup_cand_x1       := array.new_int()
            self.sup_cand_y1       := array.new_float()
            self.sup_cand_lp_slope := array.new_float()

    if should_find and not na(self.x1) and not na(self.up_lp_slope) and self.y1 > 0
        int n_bars = math.min(bar_index - self.x1, lookback_bars - 1)
        if n_bars >= 2
            bool basis_changed = na(self.support_basis_x1) or (self.support_basis_x1 != self.x1 or self.support_basis_up_x2 != self.up_x2)
            if basis_changed
                array.clear(self.sup_cand_x1)
                array.clear(self.sup_cand_y1)
                array.clear(self.sup_cand_lp_slope)
                self.support_trail_gap    := na
                self.support_basis_x1     := self.x1
                self.support_basis_up_x2  := self.up_x2

            int j_from = basis_changed ? n_bars - 1 : 1
            int j_to   = basis_changed ? 1 : 1
            float lp_self_y1  = to_lp(self.y1)
            float up_x1       = float(self.x1)
            float up_intercept = self.up_lp_slope * up_x1 - lp_self_y1

            for j = j_from to j_to
                if low[j] > 0
                    float lp_low_j = to_lp(low[j])
                    for i = n_bars to j + 1
                        if low[i] > 0
                            float lp_low_i = to_lp(low[i])
                            float lp_slope = (lp_low_j - lp_low_i) / float(i - j)
                            if lp_slope <= self.up_lp_slope
                                continue
                            float denom = self.up_lp_slope - lp_slope
                            float xi    = denom == 0 ? up_x1 : (lp_low_i - lp_slope * float(bar_index - i) + up_intercept) / denom
                            int start   = math.max(i - 1, bar_index - math.round(xi))
                            if start > n_bars
                                continue
                            bool broken = false
                            for k = 1 to start
                                if low[k] > 0
                                    float lp_support_k = lp_low_i + lp_slope * float(i - k)
                                    if to_lp(low[k]) < lp_support_k
                                        broken := true
                                        break
                            if not broken
                                array.push(self.sup_cand_x1,       bar_index - i)
                                array.push(self.sup_cand_y1,       low[i])
                                array.push(self.sup_cand_lp_slope, lp_slope)

            int n = array.size(self.sup_cand_x1)
            if n > 0
                for idx = n - 1 to 0
                    int   x1c       = array.get(self.sup_cand_x1, idx)
                    float y1c       = array.get(self.sup_cand_y1, idx)
                    float lp_slope  = array.get(self.sup_cand_lp_slope, idx)
                    int   i         = bar_index - x1c
                    bool  invalid   = i > lookback_bars - 1
                    if not invalid and low[1] > 0
                        float lp_support_1 = to_lp(y1c) + lp_slope * float(i - 1)
                        if to_lp(low[1]) < lp_support_1
                            invalid := true
                    if invalid
                        array.remove(self.sup_cand_x1,       idx)
                        array.remove(self.sup_cand_y1,       idx)
                        array.remove(self.sup_cand_lp_slope, idx)
                n := array.size(self.sup_cand_x1)

            if n > 0
                for idx = 0 to n - 1
                    float lp_slope = array.get(self.sup_cand_lp_slope, idx)
                    if na(self.sup_lp_slope) or lp_slope > self.sup_lp_slope
                        self.sup_x1       := array.get(self.sup_cand_x1, idx)
                        self.sup_y1       := array.get(self.sup_cand_y1, idx)
                        self.sup_lp_slope := lp_slope

                // Max drawdown (in % of price) from support start to now
                float peak    = na
                float max_dd  = na
                int   bars_back = bar_index - self.sup_x1
                for offset = 0 to bars_back
                    int b = bars_back - offset
                    array<float> highs = lt_h[b]
                    array<float> lows  = lt_l[b]
                    if not na(highs) and not na(lows)
                        int m = math.min(array.size(highs), array.size(lows))
                        if m > 0
                            for idx2 = 0 to m - 1
                                float h = array.get(highs, idx2)
                                float l = array.get(lows, idx2)
                                peak := na(peak) ? h : math.max(peak, h)
                                if peak != 0
                                    float dd = 100.0 * (peak - l) / peak
                                    max_dd := na(max_dd) ? dd : math.max(max_dd, dd)
                self.support_trail_gap := math.max(max_dd, min_support_trail)
            else
                self.support_trail_gap := na
    else if should_find
        array.clear(self.sup_cand_x1)
        array.clear(self.sup_cand_y1)
        array.clear(self.sup_cand_lp_slope)
        self.support_trail_gap   := na
        self.support_basis_x1    := na
        self.support_basis_up_x2 := na

    bool  has_support = not na(self.sup_lp_slope)
    float support_y   = has_support ? from_lp(to_lp(self.sup_y1) + self.sup_lp_slope * float(bar_index - self.sup_x1)) : na
    self.support_rate       := has_support ? 100.0 * self.sup_lp_slope * bars_per_day : na
    self.support_lead       := has_support and close != 0 ? 100.0 * (close - support_y) / close : na
    self.support_trail_stop := has_support and not na(self.support_trail_gap) and self.support_lead >= 0 ? support_y * (1 - self.support_trail_gap / 100.0) : na
    self.support_age_days   := has_support ? (bar_index - self.sup_x1) / bars_per_day : na


// ==================== Support-based Fib anchors ====================
// Compute anchors for a Fib drawn relative to the (sup_index+1)-th support
// line *below* the current one in slope, i.e. the K-th previous support.
//   sup_index = 0 → immediately previous support (largest slope < sup_lp_slope)
//   sup_index = 1 → two before (second-largest below current)
//   ...
// Returns a 7-tuple matching SlantedFib.set_anchors() arguments:
//   x1, y1  : origin (= chosen candidate's first contact)
//   down_*  : same as primary (trend.down_x2 / down_y2)
//   up_*    : intersection of the chosen support line and the current support line
//   lp_diff : max-high-above-line over [down_x2, x1] using new base
// Returns all-na anchors when conditions aren't met (no such previous / degenerate).
support_fib_anchors(TrendFinder trend, int sup_index) =>
    int   sx1 = na
    float sy1 = na
    int   sux = na
    float suy = na
    float sld = na
    int   sdx2 = trend.down_x2
    float sdy2 = trend.down_y2
    if not na(trend.sup_cand_x1) and not na(trend.sup_lp_slope) and not na(trend.down_x2) and trend.down_y2 > 0
        // K-th largest slope strictly less than sup_lp_slope (K = sup_index + 1)
        float threshold  = trend.sup_lp_slope
        float prev_slope = na
        int   prev_x1    = na
        float prev_y1    = na
        bool  exhausted  = false
        for k = 0 to sup_index
            float best_slope = na
            int   best_x1    = na
            float best_y1    = na
            for idx = 0 to trend.sup_cand_x1.size() - 1
                float s = trend.sup_cand_lp_slope.get(idx)
                if s < threshold and (na(best_slope) or s > best_slope)
                    best_slope := s
                    best_x1    := trend.sup_cand_x1.get(idx)
                    best_y1    := trend.sup_cand_y1.get(idx)
            if na(best_slope)
                exhausted := true
                break
            prev_slope := best_slope
            prev_x1    := best_x1
            prev_y1    := best_y1
            threshold  := best_slope

        if not exhausted and not na(prev_slope) and prev_y1 > 0 and trend.down_x2 != prev_x1
            float new_diff = max_high_above_line(prev_x1, prev_y1, trend.down_x2, trend.down_y2)
            int   x4 = line_intersect_x(prev_x1, prev_y1, prev_slope, trend.sup_x1, trend.sup_y1, trend.sup_lp_slope)
            if not na(new_diff) and not na(x4) and x4 != prev_x1
                sx1 := prev_x1
                sy1 := prev_y1
                sux := x4
                suy := from_lp(to_lp(prev_y1) + prev_slope * float(x4 - prev_x1))
                sld := new_diff
        // Fallback: no previous support found (only current sup exists). Use V-bottom origin
        // with primary's lp_diff so secondary still renders (clipped to sup line by boundary).
        if na(sx1) and sup_index == 0 and trend.isValid()
            sx1 := trend.x1
            sy1 := trend.y1
            sux := trend.up_x2
            suy := trend.up_y2
            sld := trend.down_lp_diff
    [sx1, sy1, sdx2, sdy2, sux, suy, sld]


// ==================== SlantedFib drawing ====================
// Holds Fib anchor geometry and renders the slanted parallelogram + V-Fib
// label for its own basis. primary/secondary concept is not baked in: the
// caller supplies anchors via update(). Per-instance visual style:
//   - use_rainbow = true  → existing per-ratio coloring/styling
//   - use_rainbow = false → uniform base_color with dashed style
// On log-scale charts the visually-straight pixel line between two
// log-correct endpoints is also log-straight (correct).

type SlantedFib
    array<line> _lines = na
    array<label> _labels = na   // baseball emoji labels at fib×support intersections (V-Ladder only)
    label vfib_label = na
    int   x1 = na
    int   down_x2 = na
    int   up_x2 = na
    float y1 = na
    float down_y2 = na
    float up_y2 = na
    float lp_diff = na
    // Boundary lines for support-anchored fib endpoints (left/right = fib level intersection with each line)
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
    not na(self.x1) and not na(self.down_x2) and not na(self.up_x2) and self.y1 > 0 and self.down_y2 > 0 and self.up_y2 > 0 and not na(self.lp_diff)

method vfib_ratio_at(SlantedFib self, float price) =>
    not self.isValid() ? na : vfib_ratio_at_anchors(self.x1, self.y1, self.down_x2, self.down_y2, self.lp_diff, price)

method set_anchors(SlantedFib self, int x1, float y1, int down_x2, float down_y2, int up_x2, float up_y2, float lp_diff) =>
    self.x1      := x1
    self.y1      := y1
    self.down_x2 := down_x2
    self.down_y2 := down_y2
    self.up_x2   := up_x2
    self.up_y2   := up_y2
    self.lp_diff := lp_diff

method draw(SlantedFib self) =>
    self.clear()
    if self.isValid()
        lines = self._get_lines()
        float lp_unit     = self.lp_diff / 0.236
        float lp_y1       = to_lp(self.y1)
        float lp_down_y2  = to_lp(self.down_y2)
        float lp_up_y2    = to_lp(self.up_y2)
        float dx_down     = float(self.down_x2 - self.x1)
        float dx_up       = float(self.up_x2  - self.x1)
        float dy_up_lp    = lp_up_y2 - lp_y1
        float dy_down_lp  = lp_down_y2 - lp_y1
        ratios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.414, 1.618, 2, 2.272, 2.414, 2.618, 3)

        float base_slope = dx_down == 0 ? 0 : dy_down_lp / dx_down

        for r in ratios
            // Support-anchored Fib: draw only key levels
            if self.support_anchored and r != 0.236 and r != 0.5 and r != 1.0 and r != 1.618 and r != 2.272 and r != 3.0
                continue
            float offset = lp_unit * r

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

            float x_start       = na
            float x_end         = na
            float y_start_lp    = na
            float y_end_lp      = na
            float x_boundary    = na   // support-boundary intersection x, captured before clip_right cap (for baseball label anchor)
            float y_boundary_lp = na

            if self.support_anchored and not na(self.boundary_slope) and not na(self.left_anchor_x) and self.left_anchor_y > 0 and not na(self.boundary_x) and self.boundary_y > 0
                // Endpoint-based rendering: left/right = fib level intersection with boundary lines.
                // Left anchor varies by ratio: r==0.236 uses left_anchor; r>0.236 uses self.x1/y1.
                float denom = self.boundary_slope - base_slope
                if denom == 0
                    continue

                bool  use_va_left = r == 0.236
                float left_x      = use_va_left ? float(self.left_anchor_x) : float(self.x1)
                float lp_left     = use_va_left ? to_lp(self.left_anchor_y) : lp_y1
                float lp_right    = to_lp(self.boundary_y)
                float fib_y       = lp_y1 + offset

                x_start := (fib_y - lp_left  + self.boundary_slope * left_x                    - base_slope * float(self.x1)) / denom
                y_start_lp := lp_left + self.boundary_slope * (x_start - left_x)

                x_end := (fib_y - lp_right + self.boundary_slope * float(self.boundary_x) - base_slope * float(self.x1)) / denom
                y_end_lp := lp_right + self.boundary_slope * (x_end - float(self.boundary_x))

                // Preserve support-boundary intersection before any clip_right override (used for baseball label anchor)
                x_boundary    := x_end
                y_boundary_lp := y_end_lp

                // Cap right end at clip_right line intersection if it is closer (smaller x) than the boundary intersection
                if not na(self.clip_right_slope) and not na(self.clip_right_x) and self.clip_right_y > 0
                    float denom_clip = self.clip_right_slope - base_slope
                    if denom_clip != 0
                        float lp_clip = to_lp(self.clip_right_y)
                        float x_clip = (fib_y - lp_clip + self.clip_right_slope * float(self.clip_right_x) - base_slope * float(self.x1)) / denom_clip
                        if not na(x_clip) and x_clip >= float(self.x1) and (x_clip < x_end or x_end < float(self.x1))
                            x_end    := x_clip
                            y_end_lp := lp_y1 + offset + base_slope * (x_end - float(self.x1))

                // Fall back to left-boundary start if r=0.236 anchor lands outside the [left boundary, support] strip
                if use_va_left
                    float x_start_bound = (fib_y - lp_y1 + self.boundary_slope * float(self.x1) - base_slope * float(self.x1)) / denom
                    float lo = math.min(x_start_bound, x_end)
                    float hi = math.max(x_start_bound, x_end)
                    if x_start < lo or x_start > hi
                        x_start    := x_start_bound
                        y_start_lp := lp_y1 + self.boundary_slope * (x_start - float(self.x1))
            else
                // Standard parallelogram rendering (primary)
                float D = dx_down * dy_up_lp - dy_down_lp * dx_up
                if D == 0
                    continue
                float s = (offset * dx_up) / D
                float px = float(self.x1) + s * dx_down
                float py_lp = (lp_y1 + offset) + s * dy_down_lp
                x_start := px
                x_end   := px + dx_down
                y_start_lp := py_lp
                y_end_lp   := py_lp + dy_down_lp

            int x_fib_left  = math.round(x_start)
            int x_fib_right = math.round(x_end)
            if can_draw(x_fib_left) and can_draw(x_fib_right) and (not self.support_anchored or x_end >= float(self.x1))
                float y_left  = from_lp(y_start_lp)
                float y_right = from_lp(y_end_lp)
                array.push(lines, line.new(x_fib_left, y_left, x_fib_right, y_right, color = c, style = style, force_overlay = true))

        // Left boundary line for support-anchored Fib:
        // from (self.x1, self.y1) parallel to support (boundary_slope), extending up to r=3.0's reach
        if self.support_anchored and not na(self.boundary_slope) and not na(self.x1) and self.y1 > 0
            float denom_lb = self.boundary_slope - base_slope
            if denom_lb != 0
                float dx_top = lp_unit * 3.0 / denom_lb
                int   x_a = self.x1
                float y_a = self.y1
                int   x_b = math.round(float(self.x1) + dx_top)
                float y_b = from_lp(lp_y1 + self.boundary_slope * dx_top)
                if can_draw(x_a) and can_draw(x_b)
                    array.push(lines, line.new(x_a, y_a, x_b, y_b, color = color.purple, style = line.style_solid, force_overlay = true))

        // V-Fib label only on primary (non-support-anchored) Fib
        if not self.support_anchored
            self.vfib_label := label.new(bar_index, high, str.tostring(self.vfib_ratio_at(high), "#.##"), color = color.blue, style = label.style_label_down, force_overlay = true)

        // Baseball emoji above the first bar whose high crossed each V-Ladder fib level (single-pass, latest bar only)
        if self.support_anchored and show_baseball and barstate.islast
            array<float>  bb_ratios  = array.from(0.5, 1.0, 1.618, 2.272, 3.0)
            array<string> bb_emojis  = array.from("🏏", "1️⃣", "2️⃣", "3️⃣", "🏃")
            array<int>    bb_found_x = array.from(-1, -1, -1, -1, -1)
            array<float>  bb_found_h = array.from(-1.0, -1.0, -1.0, -1.0, -1.0)
            int bb_remaining = 5
            int bb_scan_from = math.max(self.x1 + 1, bar_index - 499)   // skip bars beyond history buffer
            for bar_x = bb_scan_from to bar_index
                if bb_remaining == 0
                    break
                float bar_high_val = high[bar_index - bar_x]
                if bar_high_val > 0
                    float bar_high_lp = to_lp(bar_high_val)
                    float fib_base_lp = lp_y1 + base_slope * float(bar_x - self.x1)
                    for i = 0 to 4
                        if array.get(bb_found_x, i) < 0 and bar_high_lp >= fib_base_lp + lp_unit * array.get(bb_ratios, i)
                            array.set(bb_found_x, i, bar_x)
                            array.set(bb_found_h, i, bar_high_val)
                            bb_remaining -= 1
            for i = 0 to 4
                int cb = array.get(bb_found_x, i)
                if cb >= 0 and can_draw(cb)
                    array.push(self._get_labels(), label.new(cb, array.get(bb_found_h, i), array.get(bb_emojis, i), color = color.new(color.purple, 80), textcolor = color.white, style = label.style_label_down, size = size.normal, force_overlay = true))


// ==================== BacktestEngine ====================
// Price-space (no log conversion needed): trail gap is a % of price, P/L is
// (exit - entry) / entry, etc.

type BacktestEngine
    bool   entry = false
    bool   entry_is_support = false
    float  entry_price = na
    int    entry_bar = na
    float  entry_uptrend_rate = na
    float  entry_trail_pct = na   // fractional, e.g. 0.18 for 18% trail
    float  trail_high = na
    float  trail_stop = na
    int    trade_bars = 0
    float  profit = 0
    float  min_profit = 0
    float  max_profit = 0
    float  max_loss = 0
    color  bg = na

method trail_step(BacktestEngine self, float h, float l) =>
    self.trail_high := math.max(self.trail_high, h)
    self.trail_stop := self.trail_high * (1 - self.entry_trail_pct)
    l <= self.trail_stop

method enter(BacktestEngine self, TrendFinder trend, float ep, string rate_name, float rate, float vfib, float lead, float trail, bool is_support) =>
    if not is_support
        trend.locked := true
    self.entry_is_support   := is_support
    self.bg                 := is_support ? color.new(color.purple, 50) : color.new(color.blue, 50)
    self.entry              := true
    self.entry_price        := ep
    self.entry_bar          := bar_index
    self.entry_uptrend_rate := trend.uptrend_rate
    self.entry_trail_pct    := ep > 0 ? (ep - trail) / ep : 0
    self.trail_high         := ep
    if show_entry_label
        float ylabel = show_labels_on_capital ? start_capital * (1 + capital_risk * self.profit) : rate
        bool  wide   = is_wide_pct(ep, is_support ? trend.support_trail_stop : trend.y1, is_support ? max_support_trail : max_trend_trail)
        new_entry_label(ylabel, is_support, "LONG", ep, rate_name, rate, vfib, lead, trail, self.entry_trail_pct * 100, wide)

method run(BacktestEngine self, TrendFinder trend) =>
    self.bg := na
    if last_bar_index - bar_index < backtest_bars
        bool entry_trend_cond = (min_uptrend_rate <= trend.uptrend_rate) and (trend.downtrend_rate <= max_downtrend_rate) and (min_vtrend <= trend.trend_diff)

        if not self.entry
            float ep      = na
            float ep_vfib = na
            float ep_lead = na
            if entry_trend_cond and rating_ok and not trend.locked
                for i = 0 to lt_h.size() - 1
                    float vfib = trend.get_vfib_ratio(lt_h.get(i))
                    float lead = trend.get_leading_days(lt_l.get(i)) * trend.uptrend_rate
                    if vfib >= min_entry_vfib_ratio and vfib <= max_entry_vfib_ratio and lead >= min_entry_leading_gain
                        ep      := lt_h.get(i)
                        ep_vfib := vfib
                        ep_lead := lead
                        break

            if not na(ep)
                float trail = math.max(ep * (1 - max_trend_trail / 100.0), trend.y1)
                self.enter(trend, ep, "Trend", trend.uptrend_rate, ep_vfib, ep_lead, trail, false)
            else if enable_support_entry and rating_ok and not na(trend.support_trail_stop) and not na(trend.support_entry_price)
                float ep_s   = trend.support_entry_price
                float trail  = math.max(ep_s * (1 - max_support_trail / 100.0), trend.support_trail_stop)
                float vfib_s = trend.get_vfib_ratio(ep_s)
                float lead_s = trend.get_leading_days(ep_s) * trend.uptrend_rate
                self.enter(trend, ep_s, "Support", trend.support_rate, vfib_s, lead_s, trail, true)
                trend.support_arm  := false
                trend.trough_vfib  := na

        bool exit_trend_cond = trend.uptrend_rate < math.min(keep_uptrend_rate, self.entry_uptrend_rate + exit_uptrend_diff)

        if self.entry
            float prev_trail_high = self.trail_high
            bool  trail_stop_cond = self.trail_step(high, low)

            if trail_stop_cond and high > prev_trail_high and timeframe.in_seconds() > 60
                self.trail_high := prev_trail_high
                trail_stop_cond := false
                for i = 0 to lt_h.size() - 1
                    if self.trail_step(lt_h.get(i), lt_l.get(i))
                        trail_stop_cond := true
                        break

            float exit_price = trail_stop_cond ? math.min(open, self.trail_stop) : close

            bool exit_vfib_cond = false
            if not exit_trail_only
                exit_vfib_cond := trend.vfib_ratio >= exit_vfib_ratio

            float p = (exit_price - self.entry_price) / self.entry_price
            if p < self.max_loss
                self.max_loss := p

            if trail_stop_cond or exit_trend_cond or exit_vfib_cond
                self.bg         := p < 0 ? color.new(color.red, 50) : color.new(color.gray, 50)
                self.entry      := false
                self.trade_bars := self.trade_bars + (bar_index - self.entry_bar)
                self.profit     := self.profit + p
                if self.profit < self.min_profit
                    self.min_profit := self.profit
                if self.profit > self.max_profit
                    self.max_profit := self.profit

                if show_exit_label
                    string info  = str.format("EXIT @ {0,number,#.##}\nby Trend {1,number,#.##}%/d\nP/L: {2,number,#.##%}", exit_price, trend.uptrend_rate, p)
                    float  ylabel = trend.uptrend_rate
                    color  clabel = p < 0 ? color.red : color.gray
                    if trail_stop_cond
                        info   := str.format("EXIT @ {0,number,#.##}\nby Trail {1,number,#.##}\nP/L: {2,number,#.##%}", exit_price, self.trail_stop, p)
                        ylabel := trend.uptrend_rate
                    else if exit_vfib_cond
                        info   := str.format("EXIT @ {0,number,#.##}\nby V-Fib {1,number,#.##}\nP/L: {2,number,#.##%}", exit_price, trend.vfib_ratio, p)
                        ylabel := trend.vfib_ratio
                    ylabel := show_labels_on_capital ? start_capital * (1 + capital_risk * self.profit) : ylabel
                    label.new(bar_index, ylabel, info, color = clabel, style = label.style_label_up, force_overlay = false)

        if exit_trend_cond
            trend.locked := false


// ==================== TrendOverlay (chart-wide extras) ====================
// Single-instance overlay tied to the primary trend: support diagonal,
// uptrend-to-support blue line, trailing-stop horizontals, and the support
// entry IF-label. Independent of any SlantedFib instance.

type TrendOverlay
    array<line> _lines = na
    label label_support_entry = na

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

method render(TrendOverlay self, TrendFinder trend, BacktestEngine bt, float active_trail_stop) =>
    self.clear()
    lines = self._get_lines()

    if trend.isValid() and trend.y1 > 0
        float lp_y1 = to_lp(trend.y1)

        // Blue line: V-bottom along uptrend to support intersection
        if not na(trend.sup_lp_slope) and not na(trend.up_lp_slope)
            int xi = trend.get_support_left_x(trend.sup_x1, trend.sup_y1, trend.sup_lp_slope)
            if can_draw(xi)
                float yi = from_lp(lp_y1 + trend.up_lp_slope * float(xi - trend.x1))
                array.push(lines, line.new(trend.x1, trend.y1, xi, yi, color = color.blue, force_overlay = true))

        // Support diagonal (purple)
        if not na(trend.sup_lp_slope) and not na(trend.up_lp_slope) and trend.sup_y1 > 0
            int   x_left  = trend.get_support_left_x(trend.sup_x1, trend.sup_y1, trend.sup_lp_slope)
            float y_left  = from_lp(lp_y1 + trend.up_lp_slope * float(x_left - trend.x1))
            float xr      = trend.sup_lp_slope == 0 ? float(bar_index) : float(trend.sup_x1) + (to_lp(close) - to_lp(trend.sup_y1)) / trend.sup_lp_slope
            int   x_right = math.min(math.round(xr), bar_index + draw_forward_limit_bars)
            float y_right = from_lp(to_lp(trend.sup_y1) + trend.sup_lp_slope * float(x_right - trend.sup_x1))
            if x_left < x_right
                array.push(lines, line.new(x_left, y_left, x_right, y_right, color = color.purple, force_overlay = true))

        // Horizontal trail stops (no log distortion either way)
        if not na(trend.support_trail_stop)
            array.push(lines, line.new(bar_index - 5, trend.support_trail_stop, bar_index + 20, trend.support_trail_stop, color = color.orange, style = line.style_dotted, force_overlay = true))
        if not na(active_trail_stop)
            array.push(lines, line.new(bar_index - 5, active_trail_stop, bar_index + 20, active_trail_stop, color = bt.entry_is_support ? color.purple : color.blue, style = line.style_dotted, force_overlay = true))

        // Support entry IF-label
        if not na(self.label_support_entry)
            self.label_support_entry.delete()
            self.label_support_entry := na
        bool entered_now = bt.entry and bt.entry_bar == bar_index
        bool support_entry = show_support_entry_label and not entered_now and not na(trend.support_trail_stop) and trend.vfib_ratio > max_entry_vfib_ratio and trend.support_arm and rating_ok
        if support_entry
            float if_trail   = math.max(close * (1 - max_support_trail / 100.0), trend.support_trail_stop)
            float if_gap_pct = close > 0 ? 100.0 * (close - if_trail) / close : 0
            bool  if_wide    = is_wide_pct(close, trend.support_trail_stop, max_support_trail)
            float label_y    = enable_backtest and show_labels_on_capital ? start_capital * (1 + capital_risk * bt.profit) : trend.support_rate
            self.label_support_entry := new_entry_label(label_y, true, "IF", close, "Support", trend.support_rate, trend.vfib_ratio, trend.support_lead, if_trail, if_gap_pct, if_wide)


// ==================== Main ====================

var trend         = TrendFinder.new()
var bt            = BacktestEngine.new()
var fib_main      = SlantedFib.new()
var fib_sup_list  = array.new<SlantedFib>()
var trend_overlay = TrendOverlay.new()

// Initialize support-based Fib list once (currently: first support line only)
if array.size(fib_sup_list) == 0
    array.push(fib_sup_list, SlantedFib.new(support_anchored = true))

trend.update()
trend.find_support(barstate.islast or (not support_last_bar_only and last_bar_index - bar_index < backtest_bars))
backtest_active = enable_backtest and last_bar_index - bar_index < backtest_bars
if backtest_active
    bt.run(trend)

float active_trail_stop = bt.entry ? bt.trail_stop : na

if barstate.islast
    fib_main.set_anchors(trend.x1, trend.y1, trend.down_x2, trend.down_y2, trend.up_x2, trend.up_y2, trend.down_lp_diff)
    fib_main.draw()

    for i = 0 to fib_sup_list.size() - 1
        [sx1, sy1, sdx, sdy, sux, suy, sld] = support_fib_anchors(trend, i)
        SlantedFib sfib = fib_sup_list.get(i)
        sfib.set_anchors(sx1, sy1, sdx, sdy, sux, suy, sld)

        // Boundary lines for endpoint resolution
        sfib.left_anchor_x  := trend.x1     // V-bottom for left boundary
        sfib.left_anchor_y  := trend.y1
        sfib.boundary_x     := trend.sup_x1 // current support's first contact for right boundary
        sfib.boundary_y     := trend.sup_y1
        sfib.boundary_slope := trend.sup_lp_slope

        // Right clip at V-bottom uptrend (blue) line: prevents low-r fib levels from extending past it
        sfib.clip_right_x     := trend.x1
        sfib.clip_right_y     := trend.y1
        sfib.clip_right_slope := trend.up_lp_slope

        sfib.draw()
    trend_overlay.render(trend, bt, active_trail_stop)


// ==================== Data window plots ====================

[close_3M, close_M] = request.security(syminfo.tickerid, "M", [close[3], close[1]], lookahead = barmerge.lookahead_off)
close_W = request.security(syminfo.tickerid, "W", close[1], lookahead = barmerge.lookahead_off)
close_D = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_off)
change_3M = (close - close_3M) / close_3M * 100
change_M  = (close - close_M)  / close_M  * 100
change_W  = (close - close_W)  / close_W  * 100
change_D  = (close - close_D)  / close_D  * 100
disp_data = display.pine_screener + display.data_window
disp_stat = disp_data + display.status_line

plot(change_3M,                                                                                  title = "3M%",         display = disp_data, color = change_3M < 0 ? color.red : color.green, precision = 2)
plot(change_M,                                                                                   "M%",                  display = disp_data, color = change_M  < 0 ? color.red : color.green, precision = 2)
plot(change_W,                                                                                   "W%",                  display = disp_data, color = change_W  < 0 ? color.red : color.green, precision = 2)
plot(change_D,                                                                                   "D%",                  display = disp_data, color = change_D  < 0 ? color.red : color.green, precision = 2)
plot(ratingTotal,                                                                                "Rating",              display = disp_stat, color = ratingTotal >= 0 ? color.green : color.red, precision = 2)
plot(bt.entry ? bar_index - bt.entry_bar + 1 : 0,                                                "Age",                 display = disp_data, precision = 0)
plot(trend.vfib_ratio,                                                                           "V-Fib",               display = disp_stat, precision = 3)
plot(trend.trend_diff,                                                                           "V-Trend",             display = disp_stat, color = trend.trend_diff < 0 ? color.red : color.blue, precision = 3)
plot(trend.support_age_days,                                                                     "SupAge",              display = disp_data, precision = 0)
plot(trend.support_rate,                                                                         "Sup%/d",              display = disp_stat, color = color.purple, precision = 3)
plot(trend.support_trail_gap,                                                                    "SupTrail%",           display = disp_stat, color = color.orange, precision = 3)
plot(trend.support_lead,                                                                         "SupLead%",            display = disp_data, precision = 3)
plot(active_trail_stop,                                                                          "ActiveTrail",         display = display.data_window, color = color.blue,   precision = 3)
plot(trend.support_trail_stop,                                                                   "SupportTrail",        display = display.data_window, color = color.orange, precision = 3)
plot(trend.leading_days * trend.uptrend_rate,                                                    "Lead%",               display = disp_data, precision = 3)
plot(trend.uptrend_rate,                                                                         "Up%/d",               display = disp_data, color = color.blue, precision = 3)
plot(trend.downtrend_rate,                                                                       "Down%/d",             display = disp_data, color = color.red,  precision = 3)
plot(backtest_active ? start_capital * (1 + capital_risk * bt.profit) : na,                      "Capital",                              color = color.gray, style = plot.style_stepline_diamond, linewidth = 3, precision = 0, show_last = backtest_bars)
plot(backtest_active ? start_capital * capital_risk * bt.max_loss : na,                          "Risk",                display = disp_stat, color = color.red, precision = 0, show_last = backtest_bars)
plot(backtest_active ? bt.trade_bars >= min_trade_bars ? start_capital * capital_risk * bt.profit / (bt.trade_bars * bars_per_day) : 0 : na, "Gain/d", display = disp_stat, color = color.gray, style = plot.style_stepline_diamond, linewidth = 3, precision = 3, show_last = backtest_bars)

bgcolor(bt.bg)
bgcolor(bt.bg, force_overlay = true)
````
