# COT Positioning

- url: https://www.tradingview.com/script/TUrWrW35-COT-Positioning/
- type: indicator
- pine_id: PUB;13aa620579b04c709ac46ac0b256d760
- version: 1.0

## Description

COT Positioning shows how the three main groups of traders in the Commitments of Traders (COT) report are positioned in the futures market behind your chart: Large Speculators, Commercials and Retail Traders.

It's an informational tool. It shows positioning clearly and honestly, without buy or sell signals.

WHAT IS THE COT REPORT?

The Commitments of Traders report is published by the CFTC (Commodity Futures Trading Commission), the US regulator for futures markets. It shows how traders are positioned in futures traded on US exchanges such as the CME, CBOT, NYMEX and COMEX.

- History: the reports date back to 1924. Regular monthly reports started in 1962 and they have been weekly since 2000.
- Timing: positions are counted at the close on Tuesday and published on Friday at 15:30 New York time. The gap gives the CFTC time to collect and check the data reported by brokers.
- Coverage: a market is included when 20 or more large traders hold positions above the CFTC's reporting levels. These large traders usually make up 70–90% of all open positions in a market.

THE THREE GROUPS

This indicator uses the CFTC's Legacy report, which splits traders into three groups:

- Commercials: traders who use futures to hedge a business risk. In commodities these are producers, processors and users of the commodity. In currency and index futures they include banks and dealers hedging their business.
- Large Speculators (non-commercials): large traders who are not hedging, such as hedge funds and trend-following funds. They trade to profit from price moves and are the group most traders follow.
- Retail Traders (non-reportable): all traders too small to be reported individually. The CFTC does not know who they are, so this group is a rough stand-in for smaller traders, not an exact count of retail.

HOW TRADERS USE THE COT REPORT

- Confirming a bias. Research on currency futures has found that weekly changes in speculators' positions move together with exchange rates, and that speculators' positions tend to signal that the current move continues. Many traders use this as confirmation: if Large Speculators are building longs in the direction of their own bias, it supports the idea.
- Watching extremes. When a group's position reaches the highest or lowest level in several years, the trade may be crowded, with fewer traders left to push it further. Some studies found that peaks and troughs in positioning were useful signals, while others found extremes are not systematically followed by reversals. Extremes are best treated as a warning, not a signal on their own.
- Commercials vs Large Speculators. Commercials usually take the opposite side to speculators. Research on currency futures found that hedgers' positions tend to forecast price reversals, so when the two groups are stretched to opposite extremes, many traders see it as a sign that a trend may be maturing.
- Context, not timing. Studies by central banks found that positioning mostly follows price rather than leading it, and the data is already three days old when published. COT works best as background context for a bias, alongside price action and fundamentals, not as an entry signal.

HOW THIS INDICATOR WORKS

- Honest timing. Each report is shown only from its official release (the first Friday after the report date, 15:30 New York time), not from the Tuesday the positions were counted. Many COT indicators place each report on its Tuesday, which makes history look as if the data was known three days earlier than it was. Here, history shows only what traders could actually have known at the time.
- Data checks. Every report is checked before it's shown: all parts must come from the same report, no values can be negative, and total longs and shorts must balance with open interest.
- Catches up on delays. If the CFTC or TradingView publishes reports late, up to four missed reports are filled in automatically, in the correct order.
- Automatic market detection. The indicator finds the right COT report for the chart you open:
  – Forex: EUR, GBP, JPY, CHF, CAD, AUD, NZD, MXN, BRL and ZAR futures, plus the US Dollar Index. On pairs quoted the other way round (e.g. USD/JPY), longs and shorts are swapped to match the chart. On crosses (e.g. GBP/JPY), the first currency's positioning against the US dollar is shown.
  – Indices: S&P 500, Nasdaq-100 and Dow Jones (consolidated reports, which include the smaller contracts), Russell 2000, Nikkei 225 and VIX.
  – Commodities: gold, silver, platinum, palladium, copper, WTI and Brent crude, natural gas, gasoline, heating oil, corn, wheat, soybeans, sugar, coffee, cocoa and cotton.
  – Crypto: CME Bitcoin and Ether futures.
  It works on futures charts and on the common spot and CFD symbols for these markets.
- Old-data warning. If a market has had no new report for about 2½ weeks (for example because it dropped below the CFTC's 20-trader limit), the table shows a warning.

WHAT YOU SEE

- Three lines, one per group, in either view:
  – NET: long minus short contracts.
  – COT Index: where the current NET sits between its lowest (0) and highest (100) level over the chosen period (156 weekly reports, about 3 years, by default).
- A table with each group's NET position, Long %, Short % and Δ NET (the change since the previous week's report), plus the market name and the release date of the report shown.

SETTINGS

- Include options: off uses the futures-only report; on uses the futures and options combined report.
- Plot: NET or COT Index.
- COT Index length (weekly reports): the look-back period for the COT Index.
- Labels at line end: show the group names next to the lines.
- Groups: show or hide each group and choose its colour.
- Table: show or hide it, its position and its text size.

NOTES

- COT is a weekly report, so the indicator works on intraday, daily and weekly charts, not on monthly charts.
- COT data only exists for US futures markets. On spot and CFD charts the matching futures report is used. For crypto, only CME futures are covered, not crypto exchanges.
- In rare weeks when a US holiday or government shutdown delays the release, history may show that report a little earlier than it was actually published.
- This is an analysis tool, not a buy or sell signal. Use it alongside your own analysis and risk management.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  COT Positioning
//  Built by Jake Koel  ·  © jakekoel
// ─────────────────────────────────────────────────────────────
// Shows CFTC Commitments of Traders (Legacy report) positioning for
// Large Speculators, Commercials and Retail Traders (non-reportable).
// Each report is shown only from its official release
// (Friday 15:30 New York time, positions as of Tuesday), so history
// only shows what traders could actually have known at the time.
indicator("COT Positioning", shorttitle = "COT Positioning", overlay = false, format = format.volume, dynamic_requests = true, max_labels_count = 10)
import TradingView/LibraryCOT/6 as cot

// ───────────────────────── Inputs ─────────────────────────
bool   inclOpt  = input.bool(false, "Include options", group = "Data", tooltip = "Off: futures-only report. On: futures and options combined report.")

string viewMode = input.string("NET", "Plot", options = ["NET", "COT Index"], group = "Display", tooltip = "NET: long minus short contracts.\nCOT Index: where the current NET sits between its lowest (0) and highest (100) over the chosen number of weekly reports.")
int    idxLen   = input.int(156, "COT Index length (weekly reports)", minval = 26, maxval = 260, group = "Display", tooltip = "156 reports = about 3 years.")
bool   showLbl  = input.bool(true, "Labels at line end", group = "Display")

bool   showLS   = input.bool(true, "Large Speculators", inline = "ls", group = "Groups")
color  colLS    = input.color(#2962FF, "", inline = "ls", group = "Groups")
bool   showCO   = input.bool(true, "Commercials", inline = "co", group = "Groups")
color  colCO    = input.color(#FF9800, "", inline = "co", group = "Groups")
bool   showNR   = input.bool(true, "Retail Traders", inline = "nr", group = "Groups", tooltip = "CFTC non-reportable positions: traders too small to report. A rough stand-in for retail traders, not an exact count.")
color  colNR    = input.color(#9E9E9E, "", inline = "nr", group = "Groups")

bool   showTbl  = input.bool(true, "Show table", group = "Table")
string tPosIn   = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right", "Middle left"], group = "Table")
string tSizeIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = "Table")

// ───────────────────────── Market mapping ─────────────────────────
// CFTC codes, checked against the CFTC's published reports.
// Currencies: CME currency futures (priced against USD)
ccyCode(string c) =>
    switch c
        "EUR" => "099741"
        "GBP" => "096742"
        "JPY" => "097741"
        "CHF" => "092741"
        "CAD" => "090741"
        "AUD" => "232741"
        "NZD" => "112741"
        "MXN" => "095741"
        "BRL" => "102741"
        "ZAR" => "122741"
        => ""

// Futures charts: by contract root (micro contracts use the main contract's report)
rootCode(string r) =>
    switch r
        "6E"  => "099741"
        "M6E" => "099741"
        "6B"  => "096742"
        "M6B" => "096742"
        "6J"  => "097741"
        "6S"  => "092741"
        "6C"  => "090741"
        "6A"  => "232741"
        "M6A" => "232741"
        "6N"  => "112741"
        "6M"  => "095741"
        "6L"  => "102741"
        "6Z"  => "122741"
        "DX"  => "098662"
        "ES"  => "13874+"
        "MES" => "13874+"
        "NQ"  => "20974+"
        "MNQ" => "20974+"
        "YM"  => "12460+"
        "MYM" => "12460+"
        "RTY" => "239742"
        "M2K" => "239742"
        "NIY" => "240743"
        "NKD" => "240743"
        "VX"  => "1170E1"
        "BTC" => "133741"
        "MBT" => "133741"
        "ETH" => "146021"
        "MET" => "146021"
        "GC"  => "088691"
        "MGC" => "088691"
        "SI"  => "084691"
        "SIL" => "084691"
        "PL"  => "076651"
        "PA"  => "075651"
        "HG"  => "085692"
        "CL"  => "067651"
        "MCL" => "067651"
        "BZ"  => "06765T"
        "NG"  => "023651"
        "RB"  => "111659"
        "HO"  => "022651"
        "ZC"  => "002602"
        "ZW"  => "001602"
        "ZS"  => "005602"
        "SB"  => "080732"
        "KC"  => "083731"
        "CC"  => "073732"
        "CT"  => "033661"
        => ""

// Spot, CFD, index and crypto symbols, recognised by symbol name
// (some brokers' symbols, e.g. XAUUSD, have no base currency set)
string TK = str.upper(syminfo.ticker)
has(string s) => str.contains(TK, s)

spotCode() =>
    string b = syminfo.basecurrency
    bool   equity = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr"
    string c = switch TK
        "SPX"       => "13874+"
        "SPX500"    => "13874+"
        "US500"     => "13874+"
        "SP500"     => "13874+"
        "SPX500USD" => "13874+"
        "US500USD"  => "13874+"
        "NDX"       => "20974+"
        "NAS100"    => "20974+"
        "US100"     => "20974+"
        "USTEC"     => "20974+"
        "NAS100USD" => "20974+"
        "DJI"       => "12460+"
        "US30"      => "12460+"
        "DJ30"      => "12460+"
        "WS30"      => "12460+"
        "US30USD"   => "12460+"
        "RUT"       => "239742"
        "US2000"    => "239742"
        "NI225"     => "240743"
        "JP225"     => "240743"
        "JPN225"    => "240743"
        "JP225USD"  => "240743"
        "VIX"       => "1170E1"
        "DXY"       => "098662"
        "USDX"      => "098662"
        => ""
    if c == "" and not equity
        c := b == "BTC" or b == "XBT" or str.startswith(TK, "BTC") or str.startswith(TK, "XBT") ? "133741" :
          b == "ETH" or str.startswith(TK, "ETH") ? "146021" :
          has("XAU") or has("GOLD") ? "088691" :
          has("XAG") or has("SILVER") ? "084691" :
          has("XPT") or has("PLATINUM") ? "076651" :
          has("XPD") or has("PALLADIUM") ? "075651" :
          has("COPPER") or has("XCU") ? "085692" :
          has("UKOIL") or has("BRENT") or has("XBR") ? "06765T" :
          has("NATGAS") or has("NGAS") or has("XNG") or has("NATURALGAS") ? "023651" :
          has("USOIL") or has("WTI") or has("XTI") ? "067651" :
          has("CORN") ? "002602" :
          has("WHEAT") ? "001602" :
          has("SOYBEAN") ? "005602" :
          has("SUGAR") ? "080732" :
          has("COFFEE") ? "083731" :
          has("COCOA") ? "073732" :
          has("COTTON") ? "033661" : ""
    c

codeName(string c) =>
    switch c
        "099741" => "EUR"
        "096742" => "GBP"
        "097741" => "JPY"
        "092741" => "CHF"
        "090741" => "CAD"
        "232741" => "AUD"
        "112741" => "NZD"
        "095741" => "MXN"
        "102741" => "BRL"
        "122741" => "ZAR"
        "098662" => "US Dollar Index"
        "13874+" => "S&P 500 (consolidated)"
        "20974+" => "Nasdaq-100 (consolidated)"
        "12460+" => "Dow Jones (consolidated)"
        "239742" => "E-mini Russell 2000"
        "240743" => "Nikkei 225 (yen contract)"
        "1170E1" => "VIX"
        "133741" => "Bitcoin (CME)"
        "146021" => "Ether (CME)"
        "088691" => "Gold"
        "084691" => "Silver"
        "076651" => "Platinum"
        "075651" => "Palladium"
        "085692" => "Copper"
        "067651" => "WTI Crude Oil"
        "06765T" => "Brent Crude"
        "023651" => "Natural Gas"
        "111659" => "RBOB Gasoline"
        "022651" => "Heating Oil (ULSD)"
        "002602" => "Corn"
        "001602" => "Wheat"
        "005602" => "Soybeans"
        "080732" => "Sugar"
        "083731" => "Coffee"
        "073732" => "Cocoa"
        "033661" => "Cotton"
        => "CFTC " + c

// Returns: CFTC code, invert long/short?, market name
mapMarket() =>
    string base  = syminfo.basecurrency
    string quote = syminfo.currency
    bool   fut   = syminfo.type == "futures"
    string code  = fut ? rootCode(syminfo.root) : ""
    bool   inv   = false
    string name  = ""
    if code == "" and fut
        // Any other futures contract: TradingView's own COT library
        code := cot.getCFTCCode(syminfo.prefix + ":" + syminfo.ticker)
    if code == ""
        code := spotCode()
    if code != ""
        name := codeName(code)
    else if ccyCode(base) != ""
        // e.g. EURUSD, or a cross like GBPJPY (shows the first currency vs USD)
        code := ccyCode(base)
        name := quote == "USD" ? base : base + " (vs USD)"
    else if base == "USD" and ccyCode(quote) != ""
        // e.g. USDJPY: JPY futures, longs and shorts swapped to match the chart
        code := ccyCode(quote)
        inv  := true
        name := quote + " (inverted)"
    else if base != "" and ccyCode(quote) != ""
        // e.g. NOKJPY: no futures for NOK, so show JPY positioning flipped to match the chart
        code := ccyCode(quote)
        inv  := true
        name := quote + " (inverted, vs USD)"
    else if base == "USD"
        // e.g. USDSEK: no futures for the other currency, show US Dollar Index positioning
        code := "098662"
        name := "US Dollar Index"
    [code, inv, name]

[code, invert, marketName] = mapMarket()
bool validCode = code != ""
bool tfOk      = timeframe.isintraday or timeframe.isdaily or timeframe.isweekly
int  DAY       = 86400000

// ───────────────────────── Data engine (runs on daily bars) ─────────────────────────
type Report
    int date
    int rel
    array<float> q

type Snapshot
    int   date  = na
    int   rel   = na
    int   count = 0
    float q0 = na
    float q1 = na
    float q2 = na
    float q3 = na
    float q4 = na
    float q5 = na
    float d0 = na
    float d1 = na
    float d2 = na
    float i0 = na
    float i1 = na
    float i2 = na

// Fetches the latest 4 reports of one COT series (value + report date).
// Reading the 3 previous reports too lets the indicator catch up by itself
// if TradingView delivers several reports at once (e.g. after a delay).
cotReq(string metric, string side) =>
    [v0, t0, v1, t1, v2, t2, v3, t3] = request.security(cot.COTTickerid("Legacy", code, inclOpt, metric, side, "All"), "1D", [close, time, close[1], time[1], close[2], time[2], close[3], time[3]], ignore_invalid_symbol = true)
    [array.from(v0, v1, v2, v3), array.from(t0, t1, t2, t3)]

// Official release: the first Friday after the report date, 15:30 New York time
// (reports are normally dated Tuesday; in holiday weeks they can be dated Monday)
releaseOf(int t) =>
    int d0  = timestamp("UTC", year(t, "UTC"), month(t, "UTC"), dayofmonth(t, "UTC"))
    int add = (dayofweek.friday - dayofweek(d0, "UTC") + 7) % 7
    int d   = d0 + (add == 0 ? 7 : add) * DAY
    timestamp("America/New_York", year(d, "UTC"), month(d, "UTC"), dayofmonth(d, "UTC"), 15, 30)

// Adds a NET value to the history and returns its COT Index (0–100)
indexOf(array<float> h, float n) =>
    h.push(n)
    if h.size() > idxLen
        h.shift()
    h.size() >= idxLen and h.max() > h.min() ? 100 * (n - h.min()) / (h.max() - h.min()) : na

engine() =>
    [NCL, tNCL] = cotReq("Noncommercial Positions", "Long")
    [NCS, tNCS] = cotReq("Noncommercial Positions", "Short")
    [COL, tCOL] = cotReq("Commercial Positions", "Long")
    [COS, tCOS] = cotReq("Commercial Positions", "Short")
    [NRL, tNRL] = cotReq("Nonreportable Positions", "Long")
    [NRS, tNRS] = cotReq("Nonreportable Positions", "Short")
    [OI,  tOI]  = cotReq("Open Interest", "No direction")
    [SP,  tSP]  = cotReq("Noncommercial Positions", "Spreading")

    var Snapshot       st       = Snapshot.new()
    var array<Report>  pending  = array.new<Report>()
    var int            lastSeen = na
    var array<float>   h0       = array.new_float()
    var array<float>   h1       = array.new_float()
    var array<float>   h2       = array.new_float()

    float tol = inclOpt ? 2 : 0
    // Check the 4 latest reports, oldest first, and queue any not seen yet.
    // On every new price update the indicator looks again, so a report that
    // TradingView delivers late is picked up as soon as it arrives.
    for k = 3 to 0
        int t0 = tNCL.get(k)
        if not na(t0) and (na(lastSeen) or t0 > lastSeen)
            float ncl = NCL.get(k)
            float ncs = NCS.get(k)
            float col = COL.get(k)
            float cos = COS.get(k)
            float nrl = NRL.get(k)
            float nrs = NRS.get(k)
            float oi  = OI.get(k)
            float sp  = SP.get(k)
            int   ti  = tOI.get(k)
            int   ts  = tSP.get(k)
            // Consolidated index reports (codes ending in "+") add the smaller contracts
            // converted to full size, so their totals can differ by a few contracts from rounding.
            float tolK = str.endswith(code, "+") ? math.max(tol, 5, nz(oi) * 0.0005) : tol
            // Data checks: all parts from the same report, no negative counts,
            // total longs = total shorts, and both sides add up to open interest.
            bool aligned  = t0 == tNCS.get(k) and t0 == tCOL.get(k) and t0 == tCOS.get(k) and t0 == tNRL.get(k) and t0 == tNRS.get(k)
            bool counts   = not na(ncl) and not na(ncs) and not na(col) and not na(cos) and not na(nrl) and not na(nrs) and math.min(ncl, ncs, col, cos, nrl, nrs) >= 0
            bool balanced = counts and math.abs(ncl + col + nrl - ncs - cos - nrs) <= tolK
            bool controls = na(oi) or na(sp) or ti != t0 or ts != t0 ? true : math.abs(ncl + col + nrl + sp - oi) <= tolK and math.abs(ncs + cos + nrs + sp - oi) <= tolK
            // A complete report waits in the queue until its official release time
            if aligned and balanced and controls
                lastSeen := t0
                array<float> q = invert ? array.from(ncs, ncl, cos, col, nrs, nrl) : array.from(ncl, ncs, col, cos, nrl, nrs)
                pending.push(Report.new(t0, releaseOf(t0), q))

    // Publish every report whose release time has passed by the end of this day
    while pending.size() > 0
        Report r = pending.first()
        if r.rel > time_close
            break
        pending.shift()
        float n0 = r.q.get(0) - r.q.get(1)
        float n1 = r.q.get(2) - r.q.get(3)
        float n2 = r.q.get(4) - r.q.get(5)
        // Δ NET only against the previous week's report (not after a gap of missing weeks)
        bool  hasPrev = st.count > 0 and r.date - st.date <= 8 * DAY
        st.d0 := hasPrev ? n0 - (st.q0 - st.q1) : na
        st.d1 := hasPrev ? n1 - (st.q2 - st.q3) : na
        st.d2 := hasPrev ? n2 - (st.q4 - st.q5) : na
        st.q0 := r.q.get(0)
        st.q1 := r.q.get(1)
        st.q2 := r.q.get(2)
        st.q3 := r.q.get(3)
        st.q4 := r.q.get(4)
        st.q5 := r.q.get(5)
        st.i0 := indexOf(h0, n0)
        st.i1 := indexOf(h1, n1)
        st.i2 := indexOf(h2, n2)
        st.date  := r.date
        st.rel   := r.rel
        st.count += 1
    st.copy()

// Daily state as of the previous completed day (no look-ahead):
// a report released on Friday appears from the next trading day.
engineConfirmed() =>
    Snapshot s = engine()
    s[1]

Snapshot data = na
if validCode and tfOk
    if timeframe.isweekly
        // Weekly candles show the latest report released by the end of that week
        data := request.security(syminfo.tickerid, "1D", engine(), calc_bars_count = 5000)
    else
        data := request.security(syminfo.tickerid, "1D", engineConfirmed(), lookahead = barmerge.lookahead_on, calc_bars_count = 5000)
if na(data)
    data := Snapshot.new()

// ───────────────────────── Plots ─────────────────────────
bool  idxView = viewMode == "COT Index"
float v0 = idxView ? data.i0 : data.q0 - data.q1
float v1 = idxView ? data.i1 : data.q2 - data.q3
float v2 = idxView ? data.i2 : data.q4 - data.q5

// Drawn back to front: Retail Traders, then Commercials, then Large Speculators on top
plot(showNR ? v2 : na, "Retail Traders", colNR, 2, plot.style_stepline)
plot(showCO ? v1 : na, "Commercials", colCO, 2, plot.style_stepline)
plot(showLS ? v0 : na, "Large Speculators", colLS, 2, plot.style_stepline)
hline(idxView ? 50 : 0, "Zero / midpoint", color.new(color.gray, 50), hline.style_dotted)

// ───────────────────────── Formatting ─────────────────────────
fmtNum(float x) =>
    na(x) ? "–" : math.abs(x) >= 1000000 ? str.tostring(x / 1000000, "0.##") + "M" : math.abs(x) >= 1000 ? str.tostring(x / 1000, "0.##") + "K" : str.tostring(x, "0")

fmtSigned(float x) =>
    na(x) ? "–" : (x > 0 ? "+" : "") + fmtNum(x)

fmtPct(float x) =>
    na(x) ? "–" : str.tostring(x, "0.0") + "%"

share(float a, float b) =>
    a + b > 0 ? 100 * a / (a + b) : na

// ───────────────────────── Labels at line end ─────────────────────────
var array<label> tags = array.new<label>()
if barstate.islast
    for t in tags
        label.delete(t)
    tags.clear()
    if showLbl
        // Names only; Large Speculators drawn last so its label sits on top
        if showNR and not na(v2)
            tags.push(label.new(bar_index, v2, "Retail Traders", style = label.style_label_left, color = colNR, textcolor = color.white, size = size.small))
        if showCO and not na(v1)
            tags.push(label.new(bar_index, v1, "Commercials", style = label.style_label_left, color = colCO, textcolor = color.white, size = size.small))
        if showLS and not na(v0)
            tags.push(label.new(bar_index, v0, "Large Speculators", style = label.style_label_left, color = colLS, textcolor = color.white, size = size.small))

// ───────────────────────── Table ─────────────────────────
tPos = switch tPosIn
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    "Middle right" => position.middle_right
    "Middle left"  => position.middle_left
    => position.top_right

tSize = switch tSizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

// Solid table colours chosen from the chart background, so the text is readable
// on light and dark charts alike (including custom background colours)
bool  DARK    = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color) < 128
color TXT     = DARK ? #E0E3EB : #131722
color MUTED   = DARK ? #9598A1 : #6A6D78
color HEAD_BG = DARK ? #2A2E39 : #E0E3EB
color ROW_BG  = DARK ? #1E222D : #F8F9FD
color LINE_C  = DARK ? #363A45 : #D1D4DC

var table tb = table.new(tPos, 5, 5, border_width = 1, border_color = LINE_C, frame_width = 1, frame_color = LINE_C)

rowCells(int row, string name, color c, float l, float s, float d) =>
    table.cell(tb, 0, row, name, text_color = c, bgcolor = ROW_BG, text_size = tSize, text_halign = text.align_left)
    table.cell(tb, 1, row, fmtNum(l - s), text_color = TXT, bgcolor = ROW_BG, text_size = tSize, text_halign = text.align_right)
    table.cell(tb, 2, row, fmtPct(share(l, s)), text_color = TXT, bgcolor = ROW_BG, text_size = tSize, text_halign = text.align_right)
    table.cell(tb, 3, row, fmtPct(share(s, l)), text_color = TXT, bgcolor = ROW_BG, text_size = tSize, text_halign = text.align_right)
    table.cell(tb, 4, row, fmtSigned(d), text_color = TXT, bgcolor = ROW_BG, text_size = tSize, text_halign = text.align_right)

if barstate.isfirst and showTbl
    table.merge_cells(tb, 0, 4, 4, 4)

if barstate.islast and showTbl
    array<string> heads = array.from("Group", "NET", "Long %", "Short %", "Δ NET")
    for c = 0 to 4
        table.cell(tb, c, 0, heads.get(c), text_color = TXT, bgcolor = HEAD_BG, text_size = tSize, text_halign = c == 0 ? text.align_left : text.align_right)
    rowCells(1, "Large Speculators", colLS, data.q0, data.q1, data.d0)
    rowCells(2, "Commercials", colCO, data.q2, data.q3, data.d1)
    rowCells(3, "Retail Traders", colNR, data.q4, data.q5, data.d2)
    string info = not validCode ? "No COT data mapped for this symbol" : not tfOk ? "COT is a weekly report: use an intraday, daily or weekly chart" : na(data.date) ? "Waiting for COT data" : marketName + "  ·  Released " + str.format_time(data.rel, "dd MMM yyyy", "America/New_York") + (timenow - data.rel > 17 * DAY ? "\n⚠ No new report for " + str.tostring(math.floor((timenow - data.date) / (7 * DAY))) + " weeks. The CFTC only publishes markets with at least 20 large traders, so this market may have stopped being reported." : "")
    table.cell(tb, 0, 4, info, text_color = MUTED, bgcolor = ROW_BG, text_size = tSize, text_halign = text.align_left)

// ───────────────────────── Signature ─────────────────────────
var table sig = table.new(tPosIn == "Bottom right" ? position.bottom_left : position.bottom_right, 1, 1)
if barstate.islast
    table.cell(sig, 0, 0, "@jakekoel", text_color = color.new(color.gray, 30), text_size = size.small)
````
