# Sphinx Key Levels  DOL Graded Supply & Demand

- url: https://www.tradingview.com/script/M0h3fDik-Sphinx-Key-Levels-DOL-Graded-Supply-Demand/
- type: indicator
- pine_id: PUB;7222f69a5fdc4cd48264e259e0d70e69
- version: 2.0

## Description

A draw-on-liquidity (DOL) map that plots the reference levels price is drawn toward, then builds supply and demand zones ONLY at those levels using an ICT-style delivery sequence. The aim is confluence by construction: rather than printing supply/demand everywhere, a zone can only exist where a tracked liquidity level was actually raided.
What it plots
Liquidity levels (each toggleable): prior day, week and month highs/lows; prior Asia and London session highs/lows; and the overnight high/low. Nearby levels are merged into a single graded band so the chart stays readable, and untested ("naked") levels are weighted up, since unswept liquidity tends to act as a stronger magnet.
Equilibrium references, kept separate from liquidity: midnight, 08:30 and 09:30 opens, plus optional weekly and monthly opens. A compact table reads price as premium or discount against each open.
Opening gaps: NDOG (new day) and NWOG (new week), drawn at their true range with a consequent-encroachment midline.
How the zones are built
For each enabled level, the script runs a four-step sequence:

Sweep - price trades through the level, raiding the short-term liquidity resting beyond it.
Reclaim - price closes back on the origin side within a set window, rejecting the raid.
Order block - the last opposite-close candle into the swept extreme is marked as the zone, optionally extended to the swept wick so a protective stop can sit beyond the raided liquidity.
Displacement - a fair value gap must form in the move away from the level to validate the zone. No FVG within the window, no zone. This step can be turned off to draw on the order block alone.

A high-type level that is swept and reclaimed produces a supply zone; a low-type level produces a demand zone. Only enabled level types generate zones, so selecting, for example, only prior day high/low restricts zones to those two levels. Each level holds one live zone at a time. A zone is mitigated when price closes through its far side, and by default a zone expires when its underlying level rolls to a new session, so a zone only remains on the chart while a live level of that type stands behind it.
Alerts
Three conditions: a new zone forms, price enters an active zone, and a zone is mitigated.
Notes
Higher-timeframe values use confirmed prior-period data and do not repaint after a bar closes. Zone detection runs on the live bar by default, so a forming zone can update until that bar closes and is fixed on close; an option is included to confirm zones only on closed bars for users who prefer no intrabar movement. Session times are New York based. Built for intraday index futures on sub-hourly charts; other symbols and timeframes will need the sweep and displacement windows retuned.
This is an analysis and context tool. It does not place orders and makes no performance claims.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) Sphinx Key Levels - DOL Graded Supply & Demand
// Version 2.8  (zone removal always deletes; invalidation or first-touch)
//   Draw-on-liquidity (DOL) map: prior day/week/month H/L, prior Asia/London
//   session H/L, and overnight H/L - clustered so nearby levels merge into one
//   graded zone (declutter). Plus opening EQ reference lines (midnight/08:30/
//   09:30/weekly/monthly). Naked (untested) levels weighted up.
//   NEW: supply/demand zones generated ONLY at enabled DOL levels via the ICT
//   delivery sequence - a level is short-term liquidity; a sweep+reclaim prints
//   an order block, and FVG displacement validates it. No standalone S/D noise.
//
// v2.6
//   - Clustering: seed suppression now tracks actual cluster membership, so a
//     chain of levels can no longer drop the outermost member from the map.
//   - Overnight H/L is suppressed when it duplicates an enabled Asia or London
//     extreme. The 18:00-09:30 window contains both, so the same observation
//     was counting twice toward cluster grade and running a second S/D slot.
//   - A DOL level that is closed through rather than raided is now marked
//     consumed and stops re-arming until it rolls. New 'DOL level broken' alert.
//   - Close-through a zone is reported as invalidation; the entry tag is
//     reported as mitigation. Alert titles changed accordingly - existing
//     alerts wired to the old titles must be recreated.
//   - Weekly and monthly opens now ride in the existing W/M security tuples,
//     cutting request.security from six calls to four.
//   - The 08:30 and 09:30 opening EQ lines are captured on session crossing
//     instead of an exact clock match, so they no longer vanish on timeframes
//     that do not land exactly on those marks.
//   - Sweep and displacement windows capped at 200 bars and max_bars_back
//     pinned at 300, so the order block scan cannot outrun the history buffer.
//   - Dead 'price' field dropped from the SD type; gap-absorption test
//     precomputed once per level rather than inside the nested cluster scan.
//
// v2.8
//   - Zones are now always deleted, never greyed out. The old 'Hide mitigated
//     zones' toggle is replaced by 'Remove zone on', selecting whether a zone
//     dies at invalidation (close through the far side) or at first mitigation
//     (price returns and tags it). The grey-out branch kept boxes and labels
//     alive forever, so on long history the slot count climbed until oldest
//     drawings were dropped out from under the script.
//   - Drawing caps cut to 60 lines / 100 labels / 100 boxes, which is real
//     headroom over the true live maximum now that nothing accumulates.
//@version=6
indicator('Sphinx Key Levels - DOL Graded Supply & Demand', shorttitle = 'Sphinx Key Levels', overlay = true, max_lines_count = 60, max_labels_count = 100, max_boxes_count = 100, max_bars_back = 300)

// ============================================================
// INPUTS
// ============================================================
gL = 'Liquidity levels (H/L)'
i_pd = input.bool(true, 'Prior day H/L (PDH/PDL)', group = gL)
i_pw = input.bool(true, 'Prior week H/L (PWH/PWL)', group = gL)
i_pm = input.bool(true, 'Prior month H/L (PMH/PML)', group = gL)
i_as = input.bool(true, 'Prior Asia session H/L', group = gL)
i_lo = input.bool(true, 'Prior London session H/L', group = gL)
i_on = input.bool(true, 'Overnight H/L (18:00-09:30)', group = gL)

gE = 'Opening EQ lines'
i_eq_mid = input.bool(true, 'Midnight open (Daily EQ)', group = gE)
i_eq_830 = input.bool(true, '08:30 open (NY Open EQ)', group = gE)
i_eq_930 = input.bool(true, '09:30 open (RTH Open)', group = gE)
i_eq_wk = input.bool(false, 'Weekly open (Weekly EQ)', group = gE)
i_eq_mo = input.bool(false, 'Monthly open (Monthly EQ)', group = gE)

gG = 'Opening gaps'
i_ndog = input.bool(true, 'NDOG (New Day Opening Gap)', group = gG)
i_nwog = input.bool(true, 'NWOG (New Week Opening Gap)', group = gG)

gC = 'Clustering'
i_cluster_atr = input.float(0.10, 'Cluster tolerance (x daily ATR)', minval = 0.01, step = 0.01, group = gC)
i_min_band = input.float(2.0, 'Min band height (pts)', minval = 0.0, step = 0.25, group = gC)
i_naked_w = input.bool(true, 'Weight naked (untested) levels up', group = gC)

gS = 'Style'
col_strong = input.color(#ffa726, 'Strong cluster (3+ / 2+naked)', group = gS)
col_major = input.color(#ffffff, 'Major', group = gS)
col_minor = input.color(color.new(color.gray, 35), 'Minor', group = gS)
i_show_bands = input.bool(true, 'Show cluster zone boxes', group = gS)
zone_op = input.int(82, 'Zone band opacity', minval = 0, maxval = 100, group = gS)
col_mid = input.color(#7e57c2, 'Daily EQ', group = gS, inline = 'e1')
col_830 = input.color(#42a5f5, 'NY Open EQ', group = gS, inline = 'e1')
col_930 = input.color(#26c6da, 'RTH Open', group = gS, inline = 'e2')
col_wk = input.color(#ab47bc, 'Weekly EQ', group = gS, inline = 'e2')
col_mo = input.color(#8d6e63, 'Monthly EQ', group = gS, inline = 'e3')
i_lbl_size = input.string('small', 'Label size', options = ['tiny', 'small', 'normal', 'large'], group = gS)
i_show_tbl = input.bool(true, 'Show bias table', group = gS)
i_tbl_pos = input.string('top_right', 'Table position', options = ['top_right', 'bottom_right', 'top_left', 'bottom_left'], group = gS)

// ---- S/D zones at DOL (ICT sweep -> reclaim -> OB -> FVG) ----
gSD = 'S/D zones at DOL'
i_sd_on = input.bool(true, 'Enable S/D zones', group = gSD, tooltip = 'Master switch for supply/demand zone generation at DOL levels.')
i_sd_confirmed = input.bool(false, 'Confirm zones on bar close', group = gSD, tooltip = 'When on, sweeps, reclaims, displacement and mitigation are only evaluated on closed bars. Removes intrabar flicker at the cost of one bar of lag.')
i_sd_sweep_win = input.int(20, 'Sweep->reclaim window (bars)', minval = 1, maxval = 200, group = gSD, tooltip = 'Max bars allowed between the sweep of a level and the reclaim close back on the origin side. Tighten to demand faster, cleaner raids. Also sets how long a level may sit beyond its price before it is treated as broken rather than raided. Capped at 200 because the order block scan indexes history dynamically over this window.')
i_sd_req_fvg = input.bool(true, 'Require FVG displacement', group = gSD, tooltip = 'Require a fair value gap in the move away from the level before a zone is drawn. Off = draw on reclaim alone (order block only).')
i_sd_disp_win = input.int(15, 'Displacement window (bars)', minval = 1, maxval = 200, group = gSD, tooltip = 'After a reclaim, how many bars to wait for a validating FVG before the setup is discarded.')
i_sd_ext_sweep = input.bool(true, 'Extend zone to swept extreme', group = gSD, tooltip = 'Extend the zone to the swept wick so a protective stop sits beyond the raided liquidity.')
i_sd_remove = input.string('Invalidation (close through)', 'Remove zone on', options = ['Invalidation (close through)', 'First mitigation (touch)'], group = gSD, tooltip = 'When a zone is deleted. Invalidation = price closes through the far side, so the zone survives the reaction it was drawn to predict. First mitigation = price returns and tags the zone at all, which clears the chart faster but removes the level the moment it is used. Zones are always deleted either way - nothing is left greyed out to accumulate.')
i_sd_expire_roll = input.bool(true, 'Expire zones when DOL rolls', group = gSD, tooltip = 'Remove an unmitigated zone when its source level rolls to a new session, keeping zones tied to a live DOL. Off = keep valid order blocks until mitigated.')
i_sd_label = input.bool(true, 'Show zone labels', group = gSD)
i_sd_boxes = input.bool(true, 'Show zone boxes', group = gSD)
col_sd_dem = input.color(#26a69a, 'Demand', group = gSD, inline = 'sd1')
col_sd_sup = input.color(#ef5350, 'Supply', group = gSD, inline = 'sd1')
i_sd_op = input.int(80, 'Zone opacity', minval = 0, maxval = 100, group = gSD)
i_sd_bord = input.int(25, 'Border opacity', minval = 0, maxval = 100, group = gSD)

_lblsz(z) =>
    z == 'tiny' ? size.tiny : z == 'normal' ? size.normal : z == 'large' ? size.large : size.small

// ============================================================
// S/D STATE MACHINE (per DOL level)
//   Sequence, demand at a low-type level L (mirror for supply at a high-type):
//     1. SWEEP    : low < L (pierce below, raid sellside)
//     2. RECLAIM  : close > L within sweep window -> print OB
//     3. OB       : last down-close candle into the swept low
//     4. DISPLACE : bullish FVG (low > high[2]) within disp window -> draw zone
//   Zone body = OB range, optionally extended to the swept wick so a stop sits
//   beyond the raided liquidity. Close-through the far side = mitigated.
// ============================================================
type SD
    string kind
    bool   isHigh
    // sweep tracking
    bool   pendActive
    int    pendBar
    float  pendExt
    // arm/displacement
    int    st          // 0 = idle, 1 = armed (reclaimed, awaiting displacement)
    int    expBar
    int    obBar
    float  obTop
    float  obBot
    // live zone
    box    z
    label  zl
    float  zTop
    float  zBot
    bool   zLive
    bool   zIn         // price was inside the zone on the previous bar
    // break vs sweep
    bool   consumed    // level was closed through, not raided - hunt disabled until roll
    // per-bar alert events
    bool   evForm
    bool   evInv
    bool   evEnter
    bool   evBreak

method _spawn(SD this) =>
    _c = this.isHigh ? col_sd_sup : col_sd_dem
    if i_sd_boxes
        this.z := box.new(this.obBar, this.obTop, bar_index + 10, this.obBot, xloc = xloc.bar_index, bgcolor = color.new(_c, i_sd_op), border_color = color.new(_c, i_sd_bord), border_width = 1)
    if i_sd_label
        _txt = this.kind + (this.isHigh ? ' Supply' : ' Demand')
        _yy = this.isHigh ? this.obTop : this.obBot
        _sty = this.isHigh ? label.style_label_down : label.style_label_up
        this.zl := label.new(this.obBar, _yy, _txt, xloc = xloc.bar_index, style = _sty, color = color.new(color.black, 100), textcolor = _c, size = size.tiny)
    this.zTop := this.obTop
    this.zBot := this.obBot
    this.zLive := true
    this.zIn := true
    this.evForm := true
    this.st := 0
    this.pendActive := false

method _kill(SD this) =>
    if not na(this.z)
        box.delete(this.z)
        this.z := na
    if not na(this.zl)
        label.delete(this.zl)
        this.zl := na
    this.zLive := false

method step(SD this, float price, bool en, bool rst) =>
    this.evForm := false
    this.evInv := false
    this.evEnter := false
    this.evBreak := false
    _ok = not i_sd_confirmed or barstate.isconfirmed
    // disabled source -> remove any zone, clear state
    if not en
        if this.zLive
            this._kill()
        this.st := 0
        this.pendActive := false
        this.consumed := false
    else
        // new underlying level (new day/week/session) -> reset the hunt
        // and (optionally) expire any unmitigated zone from the old level
        if rst
            this.st := 0
            this.pendActive := false
            this.consumed := false
            if i_sd_expire_roll and this.zLive
                this._kill()
        if _ok and not na(price)
            if this.isHigh
                // ---- SUPPLY hunt ----
                if high > price and not this.consumed
                    if not this.pendActive
                        this.pendActive := true
                        this.pendBar := bar_index
                        this.pendExt := high
                    else
                        this.pendExt := math.max(this.pendExt, high)
                if this.pendActive and bar_index - this.pendBar > i_sd_sweep_win
                    this.pendActive := false
                    // window elapsed with price still closing above -> the level was
                    // broken, not raided. Stop hunting until the level rolls.
                    if close > price
                        this.consumed := true
                        this.evBreak := true
                if this.st == 0 and this.pendActive and close < price and not this.zLive
                    look = math.max(0, math.min(bar_index - this.pendBar, i_sd_sweep_win))
                    hiOff = 0
                    hiVal = high
                    for k = 0 to look by 1
                        if high[k] > hiVal
                            hiVal := high[k]
                            hiOff := k
                    obOff = hiOff
                    for k = hiOff to math.min(hiOff + 3, look) by 1
                        if close[k] > open[k]
                            obOff := k
                            break
                    this.obBar := bar_index - obOff
                    this.obBot := low[obOff]
                    this.obTop := i_sd_ext_sweep ? math.max(high[obOff], this.pendExt) : high[obOff]
                    if i_sd_req_fvg
                        this.st := 1
                        this.expBar := bar_index + i_sd_disp_win
                    else
                        this._spawn()
                if this.st == 1
                    if bar_index > this.expBar
                        this.st := 0
                        this.pendActive := false
                    else if bar_index > 2 and not na(low[2]) and high < low[2]
                        this._spawn()
            else
                // ---- DEMAND hunt ----
                if low < price and not this.consumed
                    if not this.pendActive
                        this.pendActive := true
                        this.pendBar := bar_index
                        this.pendExt := low
                    else
                        this.pendExt := math.min(this.pendExt, low)
                if this.pendActive and bar_index - this.pendBar > i_sd_sweep_win
                    this.pendActive := false
                    // window elapsed with price still closing below -> the level was
                    // broken, not raided. Stop hunting until the level rolls.
                    if close < price
                        this.consumed := true
                        this.evBreak := true
                if this.st == 0 and this.pendActive and close > price and not this.zLive
                    look = math.max(0, math.min(bar_index - this.pendBar, i_sd_sweep_win))
                    loOff = 0
                    loVal = low
                    for k = 0 to look by 1
                        if low[k] < loVal
                            loVal := low[k]
                            loOff := k
                    obOff = loOff
                    for k = loOff to math.min(loOff + 3, look) by 1
                        if close[k] < open[k]
                            obOff := k
                            break
                    this.obBar := bar_index - obOff
                    this.obTop := high[obOff]
                    this.obBot := i_sd_ext_sweep ? math.min(low[obOff], this.pendExt) : low[obOff]
                    if i_sd_req_fvg
                        this.st := 1
                        this.expBar := bar_index + i_sd_disp_win
                    else
                        this._spawn()
                if this.st == 1
                    if bar_index > this.expBar
                        this.st := 0
                        this.pendActive := false
                    else if bar_index > 2 and not na(high[2]) and low > high[2]
                        this._spawn()
        // ---- keep-alive + mitigation + invalidation ----
        // A zone is always deleted, never greyed out. The old grey-out path
        // left the box and label alive indefinitely, so on long history the
        // slot count climbed until TradingView started dropping the oldest
        // drawings out from under the script.
        if this.zLive
            if not na(this.z)
                box.set_right(this.z, bar_index + 10)
            if _ok
                _in = high >= this.zBot and low <= this.zTop
                if _in and not this.zIn
                    this.evEnter := true
                this.zIn := _in
                _inv = this.isHigh ? close > this.zTop : close < this.zBot
                if _inv
                    this.evInv := true
                    this._kill()
                else if this.evEnter and i_sd_remove == 'First mitigation (touch)'
                    this._kill()
    this

// ============================================================
// DOL LEVELS + NAKED TRACKING
// ============================================================
katr_d = request.security(syminfo.tickerid, 'D', ta.atr(14), lookahead = barmerge.lookahead_off)
atr_tol = na(katr_d) ? ta.atr(14) * 3 : katr_d
[pdh, pdl] = request.security(syminfo.tickerid, 'D', [high[1], low[1]], lookahead = barmerge.lookahead_on)
// The weekly/monthly opens ride along in the same tuple as the prior-period
// extremes. lookahead_on is safe for all three: high[1]/low[1] are completed
// periods, and a period's own open is fixed the moment that period begins.
[pwh, pwl, eq_wk] = request.security(syminfo.tickerid, 'W', [high[1], low[1], open], lookahead = barmerge.lookahead_on)
[pmh, pml, eq_mo] = request.security(syminfo.tickerid, 'M', [high[1], low[1], open], lookahead = barmerge.lookahead_on)

kh = hour(time, 'America/New_York')
km = minute(time, 'America/New_York')
kmins = kh * 60 + km
kx_in_asia = kmins >= 1200 or kmins < 180
kx_in_lon = kmins >= 180 and kmins < 510
kx_in_on = kmins >= 1080 or kmins < 570
var float asiaH_cur = na
var float asiaL_cur = na
var float asiaH_prev = na
var float asiaL_prev = na
var float lonH_cur = na
var float lonL_cur = na
var float lonH_prev = na
var float lonL_prev = na
var float onH_cur = na
var float onL_cur = na
var float onH_prev = na
var float onL_prev = na
var bool asiaH_t = false
var bool asiaL_t = false
var bool lonH_t = false
var bool lonL_t = false
var bool onH_t = false
var bool onL_t = false
if kx_in_asia and not kx_in_asia[1]
    asiaH_cur := high
    asiaL_cur := low
    asiaL_cur
else if kx_in_asia
    asiaH_cur := math.max(asiaH_cur, high)
    asiaL_cur := math.min(asiaL_cur, low)
    asiaL_cur
if not kx_in_asia and kx_in_asia[1]
    asiaH_prev := asiaH_cur
    asiaL_prev := asiaL_cur
    asiaH_t := false
    asiaL_t := false
    asiaL_t
if kx_in_lon and not kx_in_lon[1]
    lonH_cur := high
    lonL_cur := low
    lonL_cur
else if kx_in_lon
    lonH_cur := math.max(lonH_cur, high)
    lonL_cur := math.min(lonL_cur, low)
    lonL_cur
if not kx_in_lon and kx_in_lon[1]
    lonH_prev := lonH_cur
    lonL_prev := lonL_cur
    lonH_t := false
    lonL_t := false
    lonL_t
if kx_in_on and not kx_in_on[1]
    onH_cur := high
    onL_cur := low
    onL_cur
else if kx_in_on
    onH_cur := math.max(onH_cur, high)
    onL_cur := math.min(onL_cur, low)
    onL_cur
if not kx_in_on and kx_in_on[1]
    onH_prev := onH_cur
    onL_prev := onL_cur
    onH_t := false
    onL_t := false
    onL_t
if not na(asiaH_prev) and high >= asiaH_prev
    asiaH_t := true
    asiaH_t
if not na(asiaL_prev) and low <= asiaL_prev
    asiaL_t := true
    asiaL_t
if not na(lonH_prev) and high >= lonH_prev
    lonH_t := true
    lonH_t
if not na(lonL_prev) and low <= lonL_prev
    lonL_t := true
    lonL_t
if not na(onH_prev) and high >= onH_prev
    onH_t := true
    onH_t
if not na(onL_prev) and low <= onL_prev
    onL_t := true
    onL_t
newDay = ta.change(time('D')) != 0
newWk = ta.change(time('W')) != 0
newMo = ta.change(time('M')) != 0
var bool pdh_t = false
var bool pdl_t = false
var bool pwh_t = false
var bool pwl_t = false
var bool pmh_t = false
var bool pml_t = false
if newDay
    pdh_t := false
    pdl_t := false
    pdl_t
if newWk
    pwh_t := false
    pwl_t := false
    pwl_t
if newMo
    pmh_t := false
    pml_t := false
    pml_t
if not na(pdh) and high >= pdh
    pdh_t := true
    pdh_t
if not na(pdl) and low <= pdl
    pdl_t := true
    pdl_t
if not na(pwh) and high >= pwh
    pwh_t := true
    pwh_t
if not na(pwl) and low <= pwl
    pwl_t := true
    pwl_t
if not na(pmh) and high >= pmh
    pmh_t := true
    pmh_t
if not na(pml) and low <= pml
    pml_t := true
    pml_t

// ============================================================
// OPENING EQ LINES  (captured at their NY times)
// ============================================================
newNYday = ta.change(dayofmonth(time, 'America/New_York')) != 0
var float eq_mid = na
var float eq_830 = na
var float eq_930 = na
// Session-crossing capture rather than an exact hour/minute match. The old
// test only fired if a bar opened precisely on 08:30 or 09:30, so any
// timeframe that does not divide evenly into those marks - and every
// timeframe above 30m - silently produced no EQ line at all.
_in_0830 = not na(time(timeframe.period, '0830-1600', 'America/New_York'))
_in_rth = not na(time(timeframe.period, '0930-1600', 'America/New_York'))
_rth_open_bar = _in_rth and not _in_rth[1]
_rth_close_bar = not _in_rth and _in_rth[1]
if newNYday
    eq_mid := open
    eq_830 := na
    eq_930 := na
    eq_930
if _in_0830 and not _in_0830[1]
    eq_830 := open
    eq_830
if _rth_open_bar
    eq_930 := open
    eq_930

// ============================================================
// OPENING GAPS  (session-based capture - robust across intraday timeframes)
//   NDOG: prior RTH close (16:00) -> CME reopen (18:00)
//   NWOG: Friday RTH close        -> Sunday reopen (18:00)
// ============================================================
_gap_max = atr_tol * 4.0
var float rth_close = na
if _rth_close_bar
    rth_close := close[1]
    rth_close
_woy = weekofyear
var int last_ow = na
var float ndogH = na
var float ndogL = na
var bool ndog_t = false
var float nwogH = na
var float nwogL = na
var bool nwog_t = false
if _rth_open_bar
    _ro = open
    _new_week = na(last_ow) or _woy != last_ow
    _valid = not na(rth_close) and rth_close != _ro and math.abs(rth_close - _ro) <= _gap_max
    if _valid and not _new_week
        ndogH := math.max(rth_close, _ro)
        ndogL := math.min(rth_close, _ro)
        ndog_t := false
        ndog_t
    if _valid and _new_week
        nwogH := math.max(rth_close, _ro)
        nwogL := math.min(rth_close, _ro)
        nwog_t := false
        nwog_t
    last_ow := _woy
    last_ow
ndogCE = not na(ndogH) and not na(ndogL) ? (ndogH + ndogL) / 2 : na
nwogCE = not na(nwogH) and not na(nwogL) ? (nwogH + nwogL) / 2 : na
if not na(ndogCE) and high >= ndogCE and low <= ndogCE
    ndog_t := true
    ndog_t
if not na(nwogCE) and high >= nwogCE and low <= nwogCE
    nwog_t := true
    nwog_t
_inGap(px) =>
    _r = false
    if i_ndog and not na(ndogH) and px <= ndogH and px >= ndogL
        _r := true
        _r
    if i_nwog and not na(nwogH) and px <= nwogH and px >= nwogL
        _r := true
        _r
    _r

// ============================================================
// S/D EXECUTION  (per-bar, event-driven - one slot per DOL level)
//   Enables mirror the liquidity toggles: only selected levels produce zones.
// ============================================================
var array<SD> sdArr = array.new<SD>()
if barstate.isfirst
    array.push(sdArr, SD.new(kind = 'PDH', isHigh = true,  st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'PDL', isHigh = false, st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'PWH', isHigh = true,  st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'PWL', isHigh = false, st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'PMH', isHigh = true,  st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'PML', isHigh = false, st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'AsH', isHigh = true,  st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'AsL', isHigh = false, st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'LoH', isHigh = true,  st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'LoL', isHigh = false, st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'ONH', isHigh = true,  st = 0, pendActive = false, zLive = false, consumed = false))
    array.push(sdArr, SD.new(kind = 'ONL', isHigh = false, st = 0, pendActive = false, zLive = false, consumed = false))

_rst_asia = not kx_in_asia and kx_in_asia[1]
_rst_lon = not kx_in_lon and kx_in_lon[1]
_rst_on = not kx_in_on and kx_in_on[1]

// ---- overnight independence ----
// The overnight window (18:00-09:30) fully contains both Asia (20:00-03:00)
// and London (03:00-08:30), so ONH/ONL is frequently the same observation as
// AsH/LoH or AsL/LoL. Counting it twice inflates the cluster grade and lets a
// second S/D slot hunt a price another slot already owns. Suppress ON only
// when it duplicates a level that is itself enabled - with Asia and London
// toggled off, ON is independent again and returns.
_on_dup(float onv, float av, float lv) =>
    (i_as and not na(av) and not na(onv) and math.abs(onv - av) <= syminfo.mintick) or (i_lo and not na(lv) and not na(onv) and math.abs(onv - lv) <= syminfo.mintick)
_on_h_ok = i_on and not _on_dup(onH_prev, asiaH_prev, lonH_prev)
_on_l_ok = i_on and not _on_dup(onL_prev, asiaL_prev, lonL_prev)

if i_sd_on
    array.get(sdArr, 0).step(pdh, i_pd, newDay)
    array.get(sdArr, 1).step(pdl, i_pd, newDay)
    array.get(sdArr, 2).step(pwh, i_pw, newWk)
    array.get(sdArr, 3).step(pwl, i_pw, newWk)
    array.get(sdArr, 4).step(pmh, i_pm, newMo)
    array.get(sdArr, 5).step(pml, i_pm, newMo)
    array.get(sdArr, 6).step(asiaH_prev, i_as, _rst_asia)
    array.get(sdArr, 7).step(asiaL_prev, i_as, _rst_asia)
    array.get(sdArr, 8).step(lonH_prev, i_lo, _rst_lon)
    array.get(sdArr, 9).step(lonL_prev, i_lo, _rst_lon)
    array.get(sdArr, 10).step(onH_prev, _on_h_ok, _rst_on)
    array.get(sdArr, 11).step(onL_prev, _on_l_ok, _rst_on)

// ---- S/D alerts (aggregate per-bar events across all levels) ----
bool sd_formed = false
bool sd_invalid = false
bool sd_mitigated = false
bool sd_broken = false
if i_sd_on
    for _si = 0 to array.size(sdArr) - 1 by 1
        _s = array.get(sdArr, _si)
        sd_formed := sd_formed or _s.evForm
        sd_invalid := sd_invalid or _s.evInv
        sd_mitigated := sd_mitigated or _s.evEnter
        sd_broken := sd_broken or _s.evBreak
alertcondition(sd_formed, 'S/D zone formed', 'Sphinx S/D: a new supply or demand zone formed at a DOL level')
alertcondition(sd_mitigated, 'S/D zone mitigated', 'Sphinx S/D: price tagged an active supply or demand zone')
alertcondition(sd_invalid, 'S/D zone invalidated', 'Sphinx S/D: price closed through a supply or demand zone')
alertcondition(sd_broken, 'DOL level broken', 'Sphinx S/D: a DOL level was closed through rather than raided')

// ============================================================
// STORAGE
// ============================================================
var array<line> glines = array.new_line()
var array<label> glabels = array.new_label()
var array<box> gboxes = array.new_box()

// ============================================================
// BUILD + CLUSTER + DRAW (last bar)
// ============================================================
if barstate.islast
    if array.size(glines) > 0
        for gi = 0 to array.size(glines) - 1 by 1
            line.delete(array.get(glines, gi))
    if array.size(glabels) > 0
        for gi = 0 to array.size(glabels) - 1 by 1
            label.delete(array.get(glabels, gi))
    if array.size(gboxes) > 0
        for gi = 0 to array.size(gboxes) - 1 by 1
            box.delete(array.get(gboxes, gi))
    array.clear(glines)
    array.clear(glabels)
    array.clear(gboxes)

    // candidate liquidity levels (inline pushes keep arrays in lockstep)
    cP = array.new_float()
    cK = array.new_string()
    cN = array.new_bool()
    cH = array.new_bool()
    if i_pd and not na(pdh)
        array.push(cP, pdh)
        array.push(cK, 'PDH')
        array.push(cN, not pdh_t)
        array.push(cH, true)
    if i_pd and not na(pdl)
        array.push(cP, pdl)
        array.push(cK, 'PDL')
        array.push(cN, not pdl_t)
        array.push(cH, false)
    if i_pw and not na(pwh)
        array.push(cP, pwh)
        array.push(cK, 'PWH')
        array.push(cN, not pwh_t)
        array.push(cH, true)
    if i_pw and not na(pwl)
        array.push(cP, pwl)
        array.push(cK, 'PWL')
        array.push(cN, not pwl_t)
        array.push(cH, false)
    if i_pm and not na(pmh)
        array.push(cP, pmh)
        array.push(cK, 'PMH')
        array.push(cN, not pmh_t)
        array.push(cH, true)
    if i_pm and not na(pml)
        array.push(cP, pml)
        array.push(cK, 'PML')
        array.push(cN, not pml_t)
        array.push(cH, false)
    if i_as and not na(asiaH_prev)
        array.push(cP, asiaH_prev)
        array.push(cK, 'AsH')
        array.push(cN, not asiaH_t)
        array.push(cH, true)
    if i_as and not na(asiaL_prev)
        array.push(cP, asiaL_prev)
        array.push(cK, 'AsL')
        array.push(cN, not asiaL_t)
        array.push(cH, false)
    if i_lo and not na(lonH_prev)
        array.push(cP, lonH_prev)
        array.push(cK, 'LoH')
        array.push(cN, not lonH_t)
        array.push(cH, true)
    if i_lo and not na(lonL_prev)
        array.push(cP, lonL_prev)
        array.push(cK, 'LoL')
        array.push(cN, not lonL_t)
        array.push(cH, false)
    if _on_h_ok and not na(onH_prev)
        array.push(cP, onH_prev)
        array.push(cK, 'ONH')
        array.push(cN, not onH_t)
        array.push(cH, true)
    if _on_l_ok and not na(onL_prev)
        array.push(cP, onL_prev)
        array.push(cK, 'ONL')
        array.push(cN, not onL_t)
        array.push(cH, false)

    // seed clustering (read-only, no copy, no mutation)
    ntot = array.size(cP)
    ntot := math.min(ntot, array.size(cK))
    ntot := math.min(ntot, array.size(cN))
    ntot := math.min(ntot, array.size(cH))
    if ntot > 0
        tol = i_cluster_atr * atr_tol
        // _inGap is fixed per level, so resolve it once rather than re-running
        // it inside the nested scan on every realtime tick.
        cGap = array.new_bool(ntot, false)
        for i = 0 to ntot - 1 by 1
            array.set(cGap, i, _inGap(array.get(cP, i)))
        // A level is a seed only if it has not already been absorbed into an
        // earlier cluster. The previous test suppressed a level whenever ANY
        // earlier level sat within tolerance, including one that was itself
        // suppressed - so in a chain (100 / 105 / 110 at tol 6) the third level
        // was killed by the second and never gathered by the first. Tracking
        // actual membership makes suppression and absorption the same event.
        cClaimed = array.new_bool(ntot, false)
        for i = 0 to ntot - 1 by 1
            pi = array.get(cP, i)
            isSeed = not array.get(cGap, i) and not array.get(cClaimed, i)
            if isSeed
                sumP = 0.0
                cnt = 0
                hasNaked = false
                hasHigh = false
                hasLow = false
                kinds = ''
                cLo = pi
                cHi = pi
                for b = i to ntot - 1 by 1
                    if not array.get(cGap, b) and not array.get(cClaimed, b) and math.abs(array.get(cP, b) - pi) <= tol
                        array.set(cClaimed, b, true)
                        pb = array.get(cP, b)
                        sumP := sumP + pb
                        cLo := math.min(cLo, pb)
                        cHi := math.max(cHi, pb)
                        cnt := cnt + 1
                        hasNaked := hasNaked or array.get(cN, b)
                        hb = array.get(cH, b)
                        hasHigh := hasHigh or hb
                        hasLow := hasLow or not hb
                        kinds := kinds == '' ? array.get(cK, b) : kinds + '/' + array.get(cK, b)
                        kinds
                if cnt > 0
                    meanP = sumP / cnt
                    nkw = i_naked_w and hasNaked
                    strong = cnt >= 3 or cnt >= 2 and nkw
                    major = not strong and (cnt >= 2 or nkw)
                    col = strong ? col_strong : major ? col_major : col_minor
                    w = strong ? 3 : major ? 2 : 1
                    bcol = hasHigh and hasLow ? #ffd54f : hasHigh ? #ef5350 : #26a69a
                    nk = hasNaked ? ' (naked)' : ''
                    _x1 = math.max(0, bar_index - 1500)
                    if cnt > 1 and i_show_bands
                        _bt = cHi
                        _bb = cLo
                        if _bt - _bb < i_min_band
                            _bt := meanP + i_min_band / 2
                            _bb := meanP - i_min_band / 2
                            _bb
                        bxc = box.new(_x1, _bt, bar_index + 20, _bb, xloc = xloc.bar_index, bgcolor = color.new(col, zone_op), border_color = color.new(bcol, 40), border_width = 1)
                        array.push(gboxes, bxc)
                    lnc = line.new(bar_index - 1, meanP, bar_index, meanP, xloc = xloc.bar_index, extend = extend.left, color = color.new(col, 0), width = w)
                    lbc = label.new(bar_index + 20, meanP, kinds + ' ' + str.tostring(meanP, format.mintick) + nk, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col, size = _lblsz(i_lbl_size))
                    array.push(glines, lnc)
                    array.push(glabels, lbc)

    // opening gaps drawn at TRUE range (priority); absorb in-range levels as confluence
    if i_ndog and not na(ndogH)
        nd_ce = (ndogH + ndogL) / 2
        nd_conf = ''
        nd_cnt = 0
        if array.size(cP) > 0
            for ci = 0 to array.size(cP) - 1 by 1
                _p = array.get(cP, ci)
                if _p <= ndogH and _p >= ndogL
                    nd_conf := nd_conf == '' ? array.get(cK, ci) : nd_conf + '/' + array.get(cK, ci)
                    nd_cnt := nd_cnt + 1
                    nd_cnt
        nd_bt = ndogH
        nd_bb = ndogL
        if nd_bt - nd_bb < i_min_band
            nd_bt := nd_ce + i_min_band / 2
            nd_bb := nd_ce - i_min_band / 2
            nd_bb
        nd_x1 = math.max(0, bar_index - 1500)
        array.push(gboxes, box.new(nd_x1, nd_bt, bar_index + 20, nd_bb, xloc = xloc.bar_index, bgcolor = color.new(nd_cnt >= 1 ? col_strong : col_major, zone_op), border_color = color.new(#ffca28, 30), border_width = 2))
        array.push(glines, line.new(bar_index - 1, nd_ce, bar_index, nd_ce, xloc = xloc.bar_index, extend = extend.left, color = color.new(#ffca28, 0), width = 1, style = line.style_dotted))
        array.push(glabels, label.new(bar_index + 20, nd_ce, 'NDOG' + (nd_conf != '' ? ' +' + nd_conf : '') + ' ' + str.tostring(nd_ce, format.mintick) + (not ndog_t ? ' (naked)' : ''), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = #ffca28, size = _lblsz(i_lbl_size)))
    if i_nwog and not na(nwogH)
        nw_ce = (nwogH + nwogL) / 2
        nw_conf = ''
        nw_cnt = 0
        if array.size(cP) > 0
            for ci = 0 to array.size(cP) - 1 by 1
                _p = array.get(cP, ci)
                if _p <= nwogH and _p >= nwogL
                    nw_conf := nw_conf == '' ? array.get(cK, ci) : nw_conf + '/' + array.get(cK, ci)
                    nw_cnt := nw_cnt + 1
                    nw_cnt
        nw_bt = nwogH
        nw_bb = nwogL
        if nw_bt - nw_bb < i_min_band
            nw_bt := nw_ce + i_min_band / 2
            nw_bb := nw_ce - i_min_band / 2
            nw_bb
        nw_x1 = math.max(0, bar_index - 1500)
        array.push(gboxes, box.new(nw_x1, nw_bt, bar_index + 20, nw_bb, xloc = xloc.bar_index, bgcolor = color.new(nw_cnt >= 1 ? col_strong : col_major, zone_op), border_color = color.new(#ff7043, 20), border_width = 2))
        array.push(glines, line.new(bar_index - 1, nw_ce, bar_index, nw_ce, xloc = xloc.bar_index, extend = extend.left, color = color.new(#ff7043, 0), width = 1, style = line.style_dotted))
        array.push(glabels, label.new(bar_index + 20, nw_ce, 'NWOG' + (nw_conf != '' ? ' +' + nw_conf : '') + ' ' + str.tostring(nw_ce, format.mintick) + (not nwog_t ? ' (naked)' : ''), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = #ff7043, size = _lblsz(i_lbl_size)))

    // opening EQ lines (separate - equilibrium, not liquidity; inlined pushes)
    if i_eq_mid and not na(eq_mid)
        array.push(glines, line.new(bar_index - 1, eq_mid, bar_index, eq_mid, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_mid, 0), width = 1, style = line.style_dashed))
        array.push(glabels, label.new(bar_index + 20, eq_mid, 'Midnight Daily EQ ' + str.tostring(eq_mid, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_mid, size = _lblsz(i_lbl_size)))
    if i_eq_830 and not na(eq_830)
        array.push(glines, line.new(bar_index - 1, eq_830, bar_index, eq_830, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_830, 0), width = 1, style = line.style_dashed))
        array.push(glabels, label.new(bar_index + 20, eq_830, '0830 NY Open EQ ' + str.tostring(eq_830, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_830, size = _lblsz(i_lbl_size)))
    if i_eq_930 and not na(eq_930)
        array.push(glines, line.new(bar_index - 1, eq_930, bar_index, eq_930, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_930, 0), width = 1, style = line.style_dashed))
        array.push(glabels, label.new(bar_index + 20, eq_930, 'RTH Open ' + str.tostring(eq_930, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_930, size = _lblsz(i_lbl_size)))
    if i_eq_wk and not na(eq_wk)
        array.push(glines, line.new(bar_index - 1, eq_wk, bar_index, eq_wk, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_wk, 0), width = 1, style = line.style_dashed))
        array.push(glabels, label.new(bar_index + 20, eq_wk, 'Weekly EQ ' + str.tostring(eq_wk, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_wk, size = _lblsz(i_lbl_size)))
    if i_eq_mo and not na(eq_mo)
        array.push(glines, line.new(bar_index - 1, eq_mo, bar_index, eq_mo, xloc = xloc.bar_index, extend = extend.left, color = color.new(col_mo, 0), width = 1, style = line.style_dashed))
        array.push(glabels, label.new(bar_index + 20, eq_mo, 'Monthly EQ ' + str.tostring(eq_mo, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = col_mo, size = _lblsz(i_lbl_size)))

// ============================================================
// BIAS TABLE  (price vs the equilibrium opens)
// ============================================================
_pos(p) =>
    p == 'bottom_right' ? position.bottom_right : p == 'top_left' ? position.top_left : p == 'bottom_left' ? position.bottom_left : position.top_right
_bias(px) =>
    na(px) ? '-' : close > px ? 'premium' : 'discount'
_biasc(px) =>
    na(px) ? color.new(color.gray, 30) : close > px ? color.new(#ef5350, 0) : color.new(#26a69a, 0)
var table bt = table.new(_pos(i_tbl_pos), 2, 3, border_width = 1, border_color = color.new(color.gray, 55))
if i_show_tbl and barstate.islast
    table.cell(bt, 0, 0, 'Daily EQ', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(bt, 1, 0, _bias(eq_mid), text_color = color.white, bgcolor = _biasc(eq_mid), text_size = size.small)
    table.cell(bt, 0, 1, 'NY Open EQ', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(bt, 1, 1, _bias(eq_830), text_color = color.white, bgcolor = _biasc(eq_830), text_size = size.small)
    table.cell(bt, 0, 2, 'RTH Open', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(bt, 1, 2, _bias(eq_930), text_color = color.white, bgcolor = _biasc(eq_930), text_size = size.small)
````
