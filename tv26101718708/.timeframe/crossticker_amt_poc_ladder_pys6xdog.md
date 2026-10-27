# Cross-Ticker AMT + POC Ladder

- url: https://www.tradingview.com/script/pYS6XdOg-Cross-Ticker-AMT-POC-Ladder/
- type: indicator
- pine_id: PUB;2de27f6079364061b49e5b6aa1f15662
- version: 2.0

## Description

Cross-Ticker AMT + POC Ladder
OVERVIEW
You trade one chart, but you usually care about more than one market. If you are on ES, where NQ sits relative to its own key levels matters, and the reverse is just as true. This indicator puts another symbol's full reference-level stack onto your current chart as a compact price ladder, so you can see at a glance whether the market you are monitoring is pressing into support or resistance, without ever leaving your chart.
Two index futures trade at very different price scales (ES near 5,800, NQ near 20,000), so you cannot plot one symbol's levels as horizontal lines on the other's chart, they would land off screen. The ladder solves this by showing the monitored symbol's levels, its live price, and the distance to every level in both points and percent inside a table.
WHAT IT SHOWS

pdH / pdL: prior day high and low (RTH session)
OVN H / OVN L: overnight (Globex) session high and low
pwH / pwL: prior week high and low
pmH / pmL: prior month high and low
pdPOC, pwPOC, pmPOC: prior day, week, and month volume Point of Control
pmVAH / pmVAL: prior month Value Area High and Low
dPOC / wPOC / mPOC: developing day, week, and month POC (optional)

The ladder is sorted high to low with a PRICE marker inserted at the monitored symbol's current price. Levels above price read as resistance, levels below read as support, and the nearest level on each side is highlighted so the next decision point is obvious.
VOLUME PROFILE METHOD
POC and Value Area are calculated from a binned volume profile of the monitored symbol, not estimated. The prior month POC, VAH, and VAL use a dedicated engine that distributes each bar's volume across its high to low range into fixed price rows, then expands the value area outward from the POC until the chosen percentage of total volume is enclosed (default 68 percent). Row size, value area percent, and the calculation timeframe are all adjustable so you can match the profile resolution you use elsewhere.
A High Volatility Mode is included for wide-range instruments. When enabled it builds the prior month profile from coarser bars and widens the row size, which is lighter on TradingView's calculation budget. Turn it on for products like NQ, or if the prior month values come up blank or the script is slow to load.
SETTINGS

Monitored symbol, RTH session, and overnight session
Individual on/off toggle for every level
Profile row size, value area percent, RTH-only vs full session, and High Volatility Mode
Full control over colors, cell and header backgrounds, text size, decimals, and table position
Proximity threshold (percent) used for highlighting and alerts

ALERTS
Named conditions fire when the monitored symbol comes within your threshold of its nearest resistance, nearest support, or any level. A dynamic alert that names the exact level it is approaching is also available.
NOTES AND LIMITATIONS

Highs and lows are exact. POC and Value Area depend on profile resolution and row size, so set the row size to suit the monitored symbol (for example a finer row for ES, a coarser row for NQ).
Prior week and month levels populate once enough history is loaded. On very low timeframes you may need to load more bars before they appear.
This is a context tool. The monitored market tagging one of its levels only informs your chart to the degree the two instruments are tracking together. On divergent sessions, weight it accordingly.
Add the indicator more than once to monitor several symbols at the same time, each instance is independent.

This script is provided for education and market analysis only. It is not financial advice, and nothing here is a guarantee of any result. Trade your own plan and manage your own risk.

## Source Code

````pine
//@version=6
// © TatankaTrading
// ============================================================================
// Cross-Ticker AMT + POC Ladder
//
// Shows ANOTHER symbol's full level stack in a table on your current chart
// (default: watch NQ while on ES). Levels computed in the target symbol's
// context:
//   pdH/pdL .......... prior RTH day high/low
//   OVN H/OVN L ...... overnight (Globex) high/low
//   pwH/pwL .......... prior week high/low (full range)
//   pmH/pmL .......... prior month high/low (full range)
//   pdPOC/pwPOC/pmPOC. prior day/week/month volume POC
//   dPOC/wPOC/mPOC ... developing day/week/month POC (optional)
//
// Rendered as a price ladder (high->low) with a PRICE marker; nearest level
// on each side is highlighted. Add the indicator again for a second symbol.
// ============================================================================
indicator("Cross-Ticker AMT + POC Ladder", overlay=true)

// ============================================================================
// INPUTS
// ============================================================================
g_sym  = "═══ Symbol & Sessions ═══"
g_lvl  = "═══ Levels ═══"
g_prof = "═══ POC Profile ═══"
g_disp = "═══ Display ═══"
g_alrt = "═══ Alerts ═══"

i_sym       = input.symbol("CME_MINI:NQ1!", "Monitored symbol", group=g_sym)
i_backadj   = input.bool(true, "Back-adjust continuous contract (roll fix)", group=g_sym, tooltip="ON: removes the price gap left by quarterly contract rolls on continuous symbols (NQ1!, ES1!), so prior-week / prior-month / prior-month-profile levels read in the CURRENT contract's price scale. Turn OFF only to compare against a non-back-adjusted source. No effect if you point 'Monitored symbol' at an explicit contract (e.g. NQU2025).")
TZ          = "America/Chicago"
i_rthSess   = input.session("0830-1500", "RTH session",       group=g_sym)
i_ovnSess   = input.session("1700-0830", "Overnight session", group=g_sym)

i_pdH_on = input.bool(true,  "pdH",   group=g_lvl, inline="a"), i_pdL_on = input.bool(true, "pdL", group=g_lvl, inline="a")
i_ovH_on = input.bool(true,  "OVN H", group=g_lvl, inline="b"), i_ovL_on = input.bool(true, "OVN L", group=g_lvl, inline="b")
i_pwH_on = input.bool(true,  "pwH",   group=g_lvl, inline="c"), i_pwL_on = input.bool(true, "pwL", group=g_lvl, inline="c")
i_pmH_on = input.bool(true,  "pmH",   group=g_lvl, inline="d"), i_pmL_on = input.bool(true, "pmL", group=g_lvl, inline="d")
i_pdP_on = input.bool(true,  "pdPOC", group=g_lvl, inline="e"), i_pwP_on = input.bool(true, "pwPOC", group=g_lvl, inline="e")
i_pmP_on   = input.bool(true, "pmPOC", group=g_lvl, inline="f"), i_pmVAH_on = input.bool(true, "pmVAH", group=g_lvl, inline="f"), i_pmVAL_on = input.bool(true, "pmVAL", group=g_lvl, inline="f")
i_dP_on  = input.bool(false, "dPOC",  group=g_lvl, inline="g"), i_wP_on  = input.bool(false, "wPOC", group=g_lvl, inline="g")
i_mP_on  = input.bool(false, "mPOC",  group=g_lvl, inline="h")

i_profileRTH = input.bool(true, "POC uses RTH only (off = full 24h)", group=g_prof)
i_binTicks   = input.int(4, "POC bin size (ticks)", minval=1, group=g_prof)
i_spread     = input.bool(false, "Spread bar volume across range", group=g_prof, tooltip="Used for the day/week developing POC only.")
i_rowSize    = input.float(1.0, "Prev-month row size", minval=0.25, step=0.25, group=g_prof, tooltip="Match your main indicator's Macro Volume Profile Row Size: 0.25 for ES, 1 for NQ.")
i_vaPct      = input.float(68.0, "Prev-month Value Area %", group=g_prof)
i_macroTF    = input.timeframe("30", "Prev-month calc TF", group=g_prof, tooltip="Resolution used to build the prior-month profile. Matches the production indicator's 30-min macro engine.")
i_hiVol      = input.bool(false, "High Volatility Mode", group=g_prof, tooltip="Mirrors your main indicator's High Volatility Mode for the prior-month profile. When on, it builds the profile from 60-minute bars instead of 30, and widens the row size to at least 20 ticks of the monitored symbol. This is coarser but far lighter. Turn it on for NQ, or if the prior-month values come up blank / the indicator is slow to load — the finer 30-min build can exceed TradingView's calculation limits on wide-range instruments.")

i_pos    = input.string("top_right", "Table position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=g_disp)
i_txt    = input.string("small", "Text size", options=["tiny","small","normal"], group=g_disp)
i_dec    = input.int(2, "Price decimals", minval=0, maxval=5, group=g_disp)
i_resCol = input.color(#EF5350, "Resistance (above price)", group=g_disp)
i_supCol = input.color(#26A69A, "Support (below price)",    group=g_disp)
i_bgCol  = input.color(#1E222D, "Cell background",  group=g_disp)
i_hdrCol = input.color(#2A2E39, "Header background", group=g_disp)
i_nearBg = input.color(#4A3A1E, "Nearest highlight", group=g_disp)

i_alOn   = input.bool(true,  "Alert when within threshold of nearest level", group=g_alrt)
i_thr    = input.float(0.15, "Proximity threshold (%)", minval=0.01, step=0.01, group=g_alrt)

posVal  = i_pos == "top_left" ? position.top_left : i_pos == "bottom_right" ? position.bottom_right : i_pos == "bottom_left" ? position.bottom_left : i_pos == "middle_right" ? position.middle_right : position.top_right
sizeVal = i_txt == "tiny" ? size.tiny : i_txt == "normal" ? size.normal : size.small
fmt     = i_dec == 0 ? "#" : i_dec == 1 ? "#.#" : i_dec == 2 ? "#.##" : i_dec == 3 ? "#.###" : i_dec == 4 ? "#.####" : "#.#####"
fmtSign = i_dec == 0 ? "+#;-#" : i_dec == 1 ? "+#.#;-#.#" : i_dec == 2 ? "+#.##;-#.##" : i_dec == 3 ? "+#.###;-#.###" : i_dec == 4 ? "+#.####;-#.####" : "+#.#####;-#.#####"

// ============================================================================
// PROFILE HELPERS
// ============================================================================
f_addBar(map<int, float> m, float bsz) =>
    if i_spread
        lo = int(math.floor(low / bsz))
        hi = int(math.floor(high / bsz))
        nb = math.max(hi - lo + 1, 1)
        vper = volume / nb
        for k = lo to hi
            cur = map.contains(m, k) ? map.get(m, k) : 0.0
            map.put(m, k, cur + vper)
    else
        k = int(math.floor(hlc3 / bsz))
        cur = map.contains(m, k) ? map.get(m, k) : 0.0
        map.put(m, k, cur + volume)

f_poc(map<int, float> m, float bsz) =>
    float bk = na
    float bv = -1.0
    ks = map.keys(m)
    if array.size(ks) > 0
        for i = 0 to array.size(ks) - 1
            k = array.get(ks, i)
            v = map.get(m, k)
            if v > bv
                bv := v
                bk := k
    na(bk) ? na : bk * bsz + bsz / 2

// --- Ported verbatim from the production indicator so prev-month matches exactly ---
calc_profile_stats(map<float, float> v_map, float va_pct) =>
    array<float> prices = map.keys(v_map)
    array<float> vols   = map.values(v_map)
    float poc = 0.0, float vah = 0.0, float val = 0.0
    if array.size(prices) > 0
        float max_vol = 0.0
        float total_vol = 0.0
        for i = 0 to array.size(prices) - 1
            float v = array.get(vols, i)
            total_vol += v
            if v > max_vol
                max_vol := v
                poc := array.get(prices, i)
        array.sort(prices)
        int poc_idx = -1
        for i = 0 to array.size(prices) - 1
            if array.get(prices, i) == poc
                poc_idx := i
                break
        float final_pct = va_pct > 1.0 ? va_pct / 100.0 : va_pct
        float cur_va = max_vol
        float tgt_va = total_vol * final_pct
        int up = poc_idx
        int dn = poc_idx
        int max_idx = array.size(prices) - 1
        while cur_va < tgt_va
            float v_up = (up < max_idx) ? map.get(v_map, array.get(prices, up + 1)) : 0.0
            float v_dn = (dn > 0) ? map.get(v_map, array.get(prices, dn - 1)) : 0.0
            if (up >= max_idx and dn <= 0)
                break
            if (v_up >= v_dn and up < max_idx) or dn <= 0
                up += 1
                cur_va += v_up
            else
                dn -= 1
                cur_va += v_dn
        vah := array.get(prices, up)
        val := array.get(prices, dn)
    [poc, vah, val]

// Prev-month profile engine (30-min bars, full session, volume spread across range).
f_macro_engine(float _row_size, float _val_pct, bool _hivol) =>
    var map<float, float> m = map.new<float, float>()
    var float p_vah = na, var float p_val = na, var float p_poc = na
    float row = _hivol ? math.max(_row_size, syminfo.mintick * 20) : _row_size
    bool new_m = ta.change(time("M", TZ)) != 0
    if new_m and map.size(m) > 0
        [cp, cvah, cval] = calc_profile_stats(m, _val_pct)
        p_poc := cp
        p_vah := cvah
        p_val := cval
        map.clear(m)
    float h_bin = math.round(high / row) * row
    float l_bin = math.round(low / row) * row
    int steps = int(math.min(200, math.max(1, math.round((h_bin - l_bin) / row))))
    float v_step = volume / steps
    for j = 0 to steps - 1
        float p = l_bin + j * row
        float ex = map.get(m, p)
        map.put(m, p, na(ex) ? v_step : ex + v_step)
    [p_poc, p_vah, p_val]

// ============================================================================
// LEVEL ENGINE (runs in the target symbol's context via request.security)
// ============================================================================
f_engine() =>
    inRTH  = not na(time(timeframe.period, i_rthSess, TZ))
    newRTH = inRTH and not inRTH[1]
    inOVN  = not na(time(timeframe.period, i_ovnSess, TZ))
    newOVN = inOVN and not inOVN[1]
    bsz    = i_binTicks * syminfo.mintick

    var float dH = na, var float dL = na, var float pdH = na, var float pdL = na
    var float ovnH = na, var float ovnL = na
    // accumulate the current RTH session (08:30-15:00) high/low
    if inRTH
        if newRTH
            dH := high
            dL := low
        else
            dH := na(dH) ? high : math.max(dH, high)
            dL := na(dL) ? low  : math.min(dL, low)
    // overnight + new trading day at 17:00 (overnight open):
    //   roll the just-completed RTH session into prior-day levels
    if newOVN
        pdH := dH
        pdL := dL
        ovnH := high
        ovnL := low
    else if inOVN
        ovnH := math.max(ovnH, high)
        ovnL := math.min(ovnL, low)

    var map<int, float> dM = map.new<int, float>()
    var map<int, float> wM = map.new<int, float>()
    var map<int, float> mM = map.new<int, float>()
    var float pdPOC = na, var float pwPOC = na
    newWeek   = time("W") != time("W")[1]
    newMonth  = time("M") != time("M")[1]
    actAdd    = i_profileRTH ? inRTH : true
    if barstate.isconfirmed
        if newOVN
            pdPOC := f_poc(dM, bsz)
            map.clear(dM)
        if newWeek
            pwPOC := f_poc(wM, bsz)
            map.clear(wM)
        if newMonth
            map.clear(mM)
        if actAdd
            f_addBar(dM, bsz)
            f_addBar(wM, bsz)
            f_addBar(mM, bsz)

    float dPOC = na, float wPOC = na, float mPOC = na
    if barstate.islast
        dPOC := f_poc(dM, bsz)
        wPOC := f_poc(wM, bsz)
        mPOC := f_poc(mM, bsz)

    [pdH, pdL, ovnH, ovnL, pdPOC, pwPOC, dPOC, wPOC, mPOC, close]

// ============================================================================
// PULL TARGET SYMBOL DATA
// ============================================================================
// CONTRACT-ROLL FIX --------------------------------------------------------
// "NQ1!"/"ES1!" are continuous front-month symbols. By default TradingView does
// NOT back-adjust them: at each quarterly roll the new contract is spliced in
// raw, leaving a price gap in history. Any level that spans the roll (prior week
// during roll week, prior month, the prior-month profile) is then quoted in the
// OLD contract's price scale -> the ~290pt error vs the production indicator.
// Prior-DAY levels were unaffected because they sit entirely post-roll.
//
// ticker.modify(..., backadjustment.on) shifts past-contract data by the roll
// spread so everything reads in the CURRENT contract's scale. Has no effect on
// non-continuous symbols, so it's safe if you point i_sym at an explicit contract.
req_sym = i_backadj ? ticker.modify(i_sym, backadjustment = backadjustment.on) : i_sym

[pdH, pdL, ovnH, ovnL, pdPOC, pwPOC, dPOC, wPOC, mPOC, px] = request.security(req_sym, timeframe.period, f_engine(), lookahead=barmerge.lookahead_off)
macroTF = i_hiVol ? "60" : i_macroTF
// Macro engine keeps a stateful var-map that finalizes the PRIOR completed month at
// rollover and holds it. That mirrors an on-chart stateful calc, so it's pulled with
// lookahead_off (no future leak -> the held prior-month value comes through clean).
[pmPOC, pmVAH, pmVAL] = request.security(req_sym, macroTF, f_macro_engine(i_rowSize, i_vaPct, i_hiVol), lookahead=barmerge.lookahead_off)
// Prior week/month high-low: the [1] offset already steps back one completed period,
// so this uses lookahead_ON (standard non-repaint prior-period idiom).
[pwH, pwL] = request.security(req_sym, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pmH, pmL] = request.security(req_sym, "M", [high[1], low[1]], lookahead=barmerge.lookahead_on)

// ============================================================================
// ASSEMBLE LEVELS
// ============================================================================
type Lvl
    float price
    string name

f_add(array<Lvl> a, bool en, float pr, string nm) =>
    if en and not na(pr)
        array.push(a, Lvl.new(pr, nm))

lvls = array.new<Lvl>()
f_add(lvls, i_pdH_on, pdH,   "pdH")
f_add(lvls, i_pdL_on, pdL,   "pdL")
f_add(lvls, i_ovH_on, ovnH,  "OVN H")
f_add(lvls, i_ovL_on, ovnL,  "OVN L")
f_add(lvls, i_pwH_on, pwH,   "pwH")
f_add(lvls, i_pwL_on, pwL,   "pwL")
f_add(lvls, i_pmH_on, pmH,   "pmH")
f_add(lvls, i_pmL_on, pmL,   "pmL")
f_add(lvls, i_pdP_on, pdPOC, "pdPOC")
f_add(lvls, i_pwP_on, pwPOC, "pwPOC")
f_add(lvls, i_pmP_on, pmPOC, "pmPOC")
f_add(lvls, i_pmVAH_on, pmVAH, "pmVAH")
f_add(lvls, i_pmVAL_on, pmVAL, "pmVAL")
f_add(lvls, i_dP_on,  dPOC,  "dPOC")
f_add(lvls, i_wP_on,  wPOC,  "wPOC")
f_add(lvls, i_mP_on,  mPOC,  "mPOC")

// nearest above / below (no sort needed)
f_scan(array<Lvl> a, float p) =>
    float aP = na, string aN = "", float bP = na, string bN = ""
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            l = array.get(a, i)
            if l.price >= p
                if na(aP) or l.price < aP
                    aP := l.price
                    aN := l.name
            else
                if na(bP) or l.price > bP
                    bP := l.price
                    bN := l.name
    [aN, aP, bN, bP]

[nrN, nrP, nsN, nsP] = f_scan(lvls, px)

// ============================================================================
// ALERT (transition into proximity band)
// ============================================================================
f_pct(float lvl, float p) => na(lvl) or p == 0 ? na : math.abs(lvl - p) / p * 100
rPct = f_pct(nrP, px)
sPct = f_pct(nsP, px)
nearRes = not na(rPct) and rPct <= i_thr
nearSup = not na(sPct) and sPct <= i_thr
within  = nearRes or nearSup

var bool prevWithin = false
firedNew = within and not prevWithin
prevWithin := within

// Dynamic message. To use: Add Alert -> Condition = this indicator -> "Any alert() function call"
if i_alOn and firedNew
    side = nearRes and (na(sPct) or (not na(rPct) and rPct <= sPct)) ? nrN : nsN
    px2  = side == nrN ? nrP : nsP
    alert(i_sym + " approaching " + side + " (" + str.tostring(px2, fmt) + ")", alert.freq_once_per_bar)

// Named conditions — these appear directly in the alert dropdown
alertcondition(nearRes, "Approaching resistance", "Monitored symbol approaching a resistance level")
alertcondition(nearSup, "Approaching support",    "Monitored symbol approaching a support level")
alertcondition(within,  "Approaching any level",  "Monitored symbol approaching a key level")

// ============================================================================
// SORT (desc by price) + RENDER LADDER
// ============================================================================
f_sortDesc(array<Lvl> a) =>
    n = array.size(a)
    if n > 1
        for i = 0 to n - 2
            mx = i
            for j = i + 1 to n - 1
                if array.get(a, j).price > array.get(a, mx).price
                    mx := j
            if mx != i
                tmp = array.get(a, i)
                array.set(a, i, array.get(a, mx))
                array.set(a, mx, tmp)

var table t = table.new(posVal, 4, 20, border_width=1)

if barstate.islast
    f_sortDesc(lvls)
    hb = i_hdrCol
    table.clear(t, 0, 0, 3, 19)
    table.cell(t, 0, 0, i_sym,                       text_color=color.white, text_size=sizeVal, bgcolor=hb)
    table.cell(t, 1, 0, str.tostring(px, fmt),       text_color=color.yellow, text_size=sizeVal, bgcolor=hb)
    table.cell(t, 2, 0, "Δpt",                       text_color=color.white, text_size=sizeVal, bgcolor=hb)
    table.cell(t, 3, 0, "Δ%",                        text_color=color.white, text_size=sizeVal, bgcolor=hb)

    int row = 1
    bool inserted = false
    n = array.size(lvls)
    if n > 0
        for i = 0 to n - 1
            l = array.get(lvls, i)
            if not inserted and l.price < px and row < 19
                table.cell(t, 0, row, "── PRICE ──",          text_color=color.black, text_size=sizeVal, bgcolor=color.yellow)
                table.cell(t, 1, row, str.tostring(px, fmt),   text_color=color.black, text_size=sizeVal, bgcolor=color.yellow)
                table.cell(t, 2, row, "",                      bgcolor=color.yellow)
                table.cell(t, 3, row, "",                      bgcolor=color.yellow)
                row += 1
                inserted := true
            if row < 19
                isRes = l.price >= px
                d     = l.price - px
                pct   = px == 0 ? na : d / px * 100
                col   = isRes ? i_resCol : i_supCol
                near  = l.name == nrN or l.name == nsN
                bg    = near ? i_nearBg : i_bgCol
                table.cell(t, 0, row, (near ? "▶ " : "") + l.name,     text_color=col, text_size=sizeVal, bgcolor=bg)
                table.cell(t, 1, row, str.tostring(l.price, fmt),      text_color=col, text_size=sizeVal, bgcolor=bg)
                table.cell(t, 2, row, str.tostring(d, fmtSign),        text_color=col, text_size=sizeVal, bgcolor=bg)
                table.cell(t, 3, row, str.tostring(pct, "+#.##;-#.##"),text_color=col, text_size=sizeVal, bgcolor=bg)
                row += 1
    if not inserted and row < 19
        table.cell(t, 0, row, "── PRICE ──",            text_color=color.black, text_size=sizeVal, bgcolor=color.yellow)
        table.cell(t, 1, row, str.tostring(px, fmt), text_color=color.black, text_size=sizeVal, bgcolor=color.yellow)
````
