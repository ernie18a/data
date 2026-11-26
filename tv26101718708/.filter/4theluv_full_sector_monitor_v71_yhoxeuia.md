# 4theluv Full Sector Monitor (v7.1)

- url: https://www.tradingview.com/script/YhOXeuIa-4theluv-Full-Sector-Monitor-v7-1/
- type: indicator
- pine_id: PUB;1c36cf0241e441e6a1eadf68ed96bb23
- version: 1.0

## Description

A real-time, single-glance dashboard of all 11 S&P 500 sectors — sorted by performance, weighted by conviction, and annotated with the stocks actually doing the moving. Built for traders who want to know where the money is flowing right now without flipping through 11 charts.

🎯 What It Does
This indicator displays a sortable table showing:

% change for each of the 11 SPDR sector ETFs (XLK, XLF, XLV, XLY, XLP, XLE, XLI, XLB, XLU, XLC, XLRE)
Relative volume (RVOL) vs. the 20-period average — your conviction gauge
Leader stock within each sector (the biggest mover in each sector's top-weight pool)
Strength score combining % change and volume conviction
Breadth header showing how many sectors are green and the average move
Sectors auto-sort top-to-bottom by % change every bar, so the strongest sector is always at the top.

📖 How To Read The Table
Header Row
Cell	Meaning
BREADTH X/11	How many sectors are positive. ≥7 green = bullish tape, ≤4 = bearish tape, in-between = mixed
AVG X.XX%	Equal-weighted average % change across all 11 sectors. A quick "market pulse"
RVOL / LEADER / STR	Column headers
Data Rows (sorted by % change, descending)
Column 1 — Sector Name
Plain English: Tech, Financials, Health, Discr (Discretionary), Staples, Energy, Industrials, Materials, Utilities, Comm (Communications), Real Estate.

Column 2 — % Change
The ETF's move on your selected timeframe.

🟢 Green = positive move with healthy volume
🔴 Red = negative move with healthy volume
🟠 Orange = move happening on weak volume (RVOL < 0.8) — treat with skepticism
Column 3 — RVOL (Relative Volume)
Current volume ÷ 20-period average volume.

Aqua/cyan highlight = RVOL ≥ 1.2× → strong participation, real conviction
Medium gray = normal volume (0.8× – 1.2×)
Light gray = RVOL < 0.8× → thin, unconvincing move
Column 4 — Leader
The single biggest mover (by absolute %) from that sector's top-weighted holdings, displayed as TICKER (X.XX%). Color matches direction. Health shows — (no leader pool to save calculation overhead).

Column 5 — STR (Strength)
% change × min(RVOL, 3). A composite score that rewards moves with volume behind them. RVOL is capped at 3× so a single volume spike can't dominate. Bigger number = higher conviction move, in either direction.

💡 Tooltips
Hover any cell to see the full sector breakdown: leader pool stocks, ETF %, RVOL, strength score, and conviction warnings.

🧠 How To Trade With It
1. Identify Sector Rotation
Look at the top 2–3 sectors. Are they offensive (Tech, Discr, Comm) or defensive (Staples, Utilities, Health)? That tells you the market's risk appetite right now.

Offensive leading + green breadth → risk-on environment, favor growth/momentum longs
Defensive leading + red breadth → risk-off, look for shorts or hedges
Energy/Materials leading → often reflation or commodity narrative
Financials leading → often a yield curve / rates story
2. Confirm With RVOL
A sector up +0.8% on 0.4× RVOL is noise. The same +0.8% on 1.8× RVOL is real. Always check the RVOL column before acting on the % change. The orange "weak conviction" coloring is your tell.

3. Use The Leader Column For Trade Ideas
The leader is doing the heavy lifting in that sector. Pull it up on a chart:

If the leader is extended, look for the #2 weight as a catch-up trade
If the leader is breaking out on volume, the whole sector ETF is likely tradeable
If the sector is green but the leader is red, something's off — investigate before trading
4. Watch The Breadth Number
9–11 green → trend day up, fade shorts, ride longs
0–2 green → trend day down, fade longs
5–6 green → choppy/rotational tape, trade ranges and pairs, not breakouts
5. Strength Column For Ranking
When two sectors have similar %, the one with higher STR has more institutional volume behind it. Prefer the higher-STR sector for swing entries.

⚙️ Settings Guide
Position & Size
Table Position — 9 placement options around the chart
Text Size — tiny / small / normal / large
Dashboard Timeframe — what timeframe to calculate moves on. Default 30 (30 min). Try D for daily rotation, 60 for intraday swings, 5 for scalping
Use Extended Hours — includes pre-market/after-hours price action. Recommended ON for early-session reads
Color Theme
Customize positive/negative/weak colors and background transparency to match your chart theme.

Signals
Strong RVOL threshold (default 1.2) — when RVOL gets the aqua highlight
Weak RVOL threshold (default 0.8) — when moves get orange "low conviction" warning
📊 Sector Leader Pools
Each sector pulls from these top-weighted holdings:

Sector	Leader Pool
Tech (XLK)	NVDA, AAPL, MSFT, AVGO
Comm (XLC)	META, GOOGL, NFLX, TMUS
Discr (XLY)	AMZN, TSLA, HD
Financials (XLF)	JPM, V, GS
Energy (XLE)	XOM, CVX, COP
Industrials (XLI)	GE, CAT, RTX
Staples (XLP)	COST, WMT
Materials (XLB)	LIN, SHW
Utilities (XLU)	NEE, CEG
Real Estate (XLRE)	AMT, PLD
Health (XLV)	ETF only
⚡ Performance Notes
Uses 39 request.security calls — fits comfortably under TradingView's 40-call limit on most plan tiers
Renders only on the last bar (barstate.islast) for zero historical-bar overhead
All calculations are bar-close based — no repainting
🔄 Best Used With
A 1-minute or 5-minute chart of SPY/QQQ for context
Your normal scanner/watchlist
A correlation tool if you trade pairs
📝 Changelog
v7.1 — Optimized to 39 security calls, added breadth header, strength score, conviction-aware coloring, tooltips, and weak-RVOL warnings. Health sector simplified to ETF-only.
v6.8 — Original 11-sector dashboard with 2-stock leader pools.
⚠️ Disclaimer
This indicator is for educational and informational purposes only. It does not constitute financial advice. Past performance and relative strength do not guarantee future results. Always do your own research and manage risk appropriately.

If you find this useful, drop a 🚀 and a follow. Suggestions and bug reports welcome in the comments.

Quick reference cheat sheet (paste at the top of your notes):
🟢 Green %  + Aqua RVOL = Real move, follow it
🔴 Red %    + Aqua RVOL = Real selling, respect it
🟠 Orange % anything    = Weak conviction, ignore or fade
Breadth ≥7 = Risk-on, ≤4 = Risk-off, 5-6 = Chop
STR > 2.0  = High-conviction move worth a trade
Good luck and happy hunting. 🎯

## Source Code

````pine
//@version=6
indicator("4theluv Full Sector Monitor (v7.1)", overlay = true)

// ============================================================
// SETTINGS
// ============================================================
grp_pos = "Position & Size"
tablePosition = input.string(position.middle_left, "Table Position", options = [position.top_right, position.top_center, position.top_left, position.bottom_right, position.bottom_center, position.bottom_left, position.middle_right, position.middle_center, position.middle_left], group = grp_pos)
textSize      = input.string(size.small, "Text Size", options = [size.tiny, size.small, size.normal, size.large], group = grp_pos)
tf_input      = input.timeframe("30", "Dashboard Timeframe", group = grp_pos)
use_ext       = input.bool(true, "Use Extended Hours (Pre-Market)", group = grp_pos)

grp_col = "Color Theme"
bg_transp     = input.int(15, "BG Transparency", minval = 0, maxval = 100, step = 5, group = grp_col)
c_names_raw   = input.color(color.gray,  "Sector Name BG", group = grp_col)
c_up_raw      = input.color(color.green, "Positive %",     group = grp_col)
c_down_raw    = input.color(color.red,   "Negative %",     group = grp_col)
c_weak_raw    = input.color(color.orange,"Weak Conviction", group = grp_col)
c_text        = input.color(color.white, "Text Color",     group = grp_col)

grp_sig = "Signals"
rvol_strong   = input.float(1.2, "Strong RVOL threshold", minval = 0.1, step = 0.1, group = grp_sig)
rvol_weak     = input.float(0.8, "Weak RVOL threshold",   minval = 0.1, step = 0.1, group = grp_sig)

// ============================================================
// HELPERS  (1 security call per symbol)
// ============================================================
set_transp(c) => color.new(c, bg_transp)
clean_sym(s) => str.replace_all(str.replace_all(str.replace_all(s, "NASDAQ:", ""), "NYSE:", ""), "AMEX:", "")

get_data(simple string sym, simple string tf) =>
    req_sym = use_ext ? ticker.modify(sym, session.extended) : ticker.modify(sym, session.regular)
    [c, c1, v, avg_v] = request.security(req_sym, tf, [close, close[1], volume, ta.sma(volume, 20)], ignore_invalid_symbol = true)
    change = ((c - c1) / c1) * 100
    rvol   = nz(v / avg_v, 0)
    [change, rvol]

// Get just %chg (lightweight, 1 call)
get_chg(simple string sym, simple string tf) =>
    req_sym = use_ext ? ticker.modify(sym, session.extended) : ticker.modify(sym, session.regular)
    [c, c1] = request.security(req_sym, tf, [close, close[1]], ignore_invalid_symbol = true)
    ((c - c1) / c1) * 100

// Leader from 2/3/4 symbols by absolute magnitude
leader2(simple string s1, simple string s2, simple string tf) =>
    c1 = get_chg(s1, tf)
    c2 = get_chg(s2, tf)
    best_c = math.abs(c2) > math.abs(c1) ? c2 : c1
    best_s = math.abs(c2) > math.abs(c1) ? s2 : s1
    [clean_sym(best_s), best_c]

leader3(simple string s1, simple string s2, simple string s3, simple string tf) =>
    c1 = get_chg(s1, tf)
    c2 = get_chg(s2, tf)
    c3 = get_chg(s3, tf)
    float bc = c1
    string bs = s1
    if math.abs(c2) > math.abs(bc)
        bc := c2
        bs := s2
    if math.abs(c3) > math.abs(bc)
        bc := c3
        bs := s3
    [clean_sym(bs), bc]

leader4(simple string s1, simple string s2, simple string s3, simple string s4, simple string tf) =>
    c1 = get_chg(s1, tf)
    c2 = get_chg(s2, tf)
    c3 = get_chg(s3, tf)
    c4 = get_chg(s4, tf)
    float bc = c1
    string bs = s1
    if math.abs(c2) > math.abs(bc)
        bc := c2
        bs := s2
    if math.abs(c3) > math.abs(bc)
        bc := c3
        bs := s3
    if math.abs(c4) > math.abs(bc)
        bc := c4
        bs := s4
    [clean_sym(bs), bc]

// ============================================================
// SECTOR DATA  (~39 security calls total)
// ============================================================
// 4-stock leaders (priority sectors)
[c_xlk, v_xlk]  = get_data("AMEX:XLK", tf_input)
[l_xlk, lc_xlk] = leader4("NASDAQ:NVDA","NASDAQ:AAPL","NASDAQ:MSFT","NASDAQ:AVGO", tf_input)

[c_xlc, v_xlc]  = get_data("AMEX:XLC", tf_input)
[l_xlc, lc_xlc] = leader4("NASDAQ:META","NASDAQ:GOOGL","NASDAQ:NFLX","NASDAQ:TMUS", tf_input)

// 3-stock leaders
[c_xly, v_xly]  = get_data("AMEX:XLY", tf_input)
[l_xly, lc_xly] = leader3("NASDAQ:AMZN","NASDAQ:TSLA","NYSE:HD", tf_input)

[c_xlf, v_xlf]  = get_data("AMEX:XLF", tf_input)
[l_xlf, lc_xlf] = leader3("NYSE:JPM","NYSE:V","NYSE:GS", tf_input)

[c_xle, v_xle]  = get_data("AMEX:XLE", tf_input)
[l_xle, lc_xle] = leader3("NYSE:XOM","NYSE:CVX","NYSE:COP", tf_input)

[c_xli, v_xli]  = get_data("AMEX:XLI", tf_input)
[l_xli, lc_xli] = leader3("NYSE:GE","NYSE:CAT","NYSE:RTX", tf_input)

// 2-stock leaders
[c_xlp, v_xlp]  = get_data("AMEX:XLP", tf_input)
[l_xlp, lc_xlp] = leader2("NASDAQ:COST","NYSE:WMT", tf_input)

[c_xlb, v_xlb]  = get_data("AMEX:XLB", tf_input)
[l_xlb, lc_xlb] = leader2("NYSE:LIN","NYSE:SHW", tf_input)

[c_xlu, v_xlu]  = get_data("AMEX:XLU", tf_input)
[l_xlu, lc_xlu] = leader2("NYSE:NEE","NASDAQ:CEG", tf_input)

[c_xlre, v_xlre]= get_data("AMEX:XLRE", tf_input)
[l_xlre,lc_xlre]= leader2("NYSE:AMT","NYSE:PLD", tf_input)

// Health: ETF only (no leader pool)
[c_xlv, v_xlv]  = get_data("AMEX:XLV", tf_input)
l_xlv  = "—"
lc_xlv = 0.0

// ============================================================
// TABLE
// ============================================================
var tbl = table.new(tablePosition, 5, 14, border_width = 1)

if barstate.islast
    names = array.from("Tech","Comm","Discr","Financials","Energy","Industrials","Staples","Materials","Utilities","Real Estate","Health")
    chgs  = array.from(c_xlk, c_xlc, c_xly, c_xlf, c_xle, c_xli, c_xlp, c_xlb, c_xlu, c_xlre, c_xlv)
    vols  = array.from(v_xlk, v_xlc, v_xly, v_xlf, v_xle, v_xli, v_xlp, v_xlb, v_xlu, v_xlre, v_xlv)
    lsyms = array.from(l_xlk, l_xlc, l_xly, l_xlf, l_xle, l_xli, l_xlp, l_xlb, l_xlu, l_xlre, l_xlv)
    lchgs = array.from(lc_xlk,lc_xlc,lc_xly,lc_xlf,lc_xle,lc_xli,lc_xlp,lc_xlb,lc_xlu,lc_xlre,lc_xlv)
    pools = array.from("NVDA·AAPL·MSFT·AVGO","META·GOOGL·NFLX·TMUS","AMZN·TSLA·HD","JPM·V·GS","XOM·CVX·COP","GE·CAT·RTX","COST·WMT","LIN·SHW","NEE·CEG","AMT·PLD","ETF only")

    // Breadth
    int greens = 0
    float avg_chg = 0.0
    for x in chgs
        avg_chg += x
        if x > 0
            greens += 1
    avg_chg := avg_chg / array.size(chgs)
    breadthColor = greens >= 7 ? set_transp(c_up_raw) : greens <= 4 ? set_transp(c_down_raw) : set_transp(color.gray)
    table.cell(tbl, 0, 0, "BREADTH " + str.tostring(greens) + "/11", bgcolor = breadthColor, text_color = c_text, text_size = textSize)
    table.cell(tbl, 1, 0, "AVG " + str.tostring(avg_chg, "0.##") + "%", bgcolor = breadthColor, text_color = c_text, text_size = textSize)
    table.cell(tbl, 2, 0, "RVOL",   bgcolor = color.black, text_color = c_text, text_size = textSize)
    table.cell(tbl, 3, 0, "LEADER", bgcolor = color.black, text_color = c_text, text_size = textSize)
    table.cell(tbl, 4, 0, "STR",    bgcolor = color.black, text_color = c_text, text_size = textSize, tooltip = "Strength = %chg × min(RVOL, 3)")

    sortedIndices = array.sort_indices(chgs, order.descending)

    for i = 0 to array.size(sortedIndices) - 1
        idx = array.get(sortedIndices, i)
        c   = array.get(chgs,  idx)
        rv  = array.get(vols,  idx)
        lc  = array.get(lchgs, idx)
        ls  = array.get(lsyms, idx)
        nm  = array.get(names, idx)
        pl  = array.get(pools, idx)

        baseColor = c >= 0 ? c_up_raw : c_down_raw
        weakMove  = rv < rvol_weak
        rowColor  = weakMove ? set_transp(c_weak_raw) : set_transp(baseColor)
        leadColor = ls == "—" ? color.new(color.gray, 70) : set_transp(lc >= 0 ? c_up_raw : c_down_raw)
        rvolColor = rv >= rvol_strong ? color.new(color.aqua, bg_transp) : rv < rvol_weak ? color.new(color.gray, 70) : color.new(color.gray, 50)

        strength = c * math.min(rv, 3.0)
        strColor = set_transp(strength >= 0 ? c_up_raw : c_down_raw)

        leaderText = ls == "—" ? "—" : ls + " (" + str.tostring(lc, "0.##") + "%)"
        tt = "Sector: " + nm + "\nLeader pool: " + pl + "\nETF %chg: " + str.tostring(c, "0.##") + "%\nRVOL: " + str.tostring(rv, "0.##") + "x\nStrength: " + str.tostring(strength, "0.##") + (weakMove ? "\n⚠ Low conviction" : "")

        table.cell(tbl, 0, i + 1, nm, text_color = c_text, bgcolor = set_transp(c_names_raw), text_halign = text.align_left, text_size = textSize, tooltip = tt)
        table.cell(tbl, 1, i + 1, str.tostring(c, "0.##") + "%", text_color = c_text, bgcolor = rowColor, text_size = textSize, tooltip = tt)
        table.cell(tbl, 2, i + 1, str.tostring(rv, "0.##") + "x", text_color = c_text, bgcolor = rvolColor, text_size = textSize, tooltip = tt)
        table.cell(tbl, 3, i + 1, leaderText, text_color = c_text, bgcolor = leadColor, text_size = textSize, tooltip = tt)
        table.cell(tbl, 4, i + 1, str.tostring(strength, "0.#"), text_color = c_text, bgcolor = strColor, text_size = textSize, tooltip = tt)
````
