# COT Hedger Positioning Extremes

- url: https://www.tradingview.com/script/bdK56MJA-COT-Hedger-Positioning-Extremes/
- type: indicator
- pine_id: PUB;b5103cbcf915466b95ad649652f522b0
- version: 1.0

## Description

[b]█ OVERVIEW[/b]

This indicator ranks hedger positioning from the CFTC Commitment of Traders Disaggregated report against its own history and marks the weeks when that positioning enters an extreme band. It also records what the chart symbol did after each past entry, so you can see how the reading has behaved on the contract you are charting.

Hedgers here means the Producer/Merchant/Processor/User category: entities the CFTC classifies as producing, processing or handling the physical commodity and using futures to hedge that business. An optional setting adds Swap Dealers, which approximates the Legacy report's Commercial category.

The approach follows the COT Index associated with Larry Williams, which reads a hedger position near the top of its multi-year range as a contrarian bullish condition and a position near the bottom as a contrarian bearish one. This script does not assume that reading holds. The forward-return panel described below lets you check it on your own chart.

═══════════════════════════════════════

[b]█ HOW IT IS CALCULATED[/b]

Hedger net is hedger long positions minus hedger short positions. The script divides hedger net by open interest, so the reading is a share of the market instead of a contract count. Raw contract counts drift as open interest grows or shrinks over the years, and ranking them partly ranks that drift.

Each week the script computes a percentile rank: the share of the previous 156 weekly readings at or below the current one. A rank of 90 means the current reading is at or above 90 percent of the prior three years of readings. Hedgers in most physical markets are net short, so a high rank usually means hedgers are less short than usual, not that they are net long.

The script uses a percentile rank instead of min-max scaling. Under min-max scaling a single outlier week compresses every other reading for as long as it stays in the window. A rank is not affected that way.

Managed Money net is calculated the same way and plotted as a second line for context. It does not affect zones, events or alerts.

═══════════════════════════════════════

[b]█ ZONES AND EVENTS[/b]

The main line is the hedger percentile. It is green in the upper zone, red in the lower zone and gray between them.

[b]Upper zone:[/b] hedger percentile at or above 80 with default settings. Hedger net, as a share of open interest, is near the top of its range for the lookback window.

[b]Lower zone:[/b] hedger percentile at or below 20 with default settings. Hedger net is near the bottom of its range.

A triangle at the bottom of the pane marks an entry into the upper zone. A triangle at the top marks an entry into the lower zone. An entry counts only after the line has spent at least 26 weeks outside that zone. A reading that slips out of a zone and returns a few weeks later does not produce a second marker or a second alert. Alerts fire on the same two events.

═══════════════════════════════════════

[b]█ FORWARD-RETURN PANEL[/b]

For each marked entry, the script records the chart symbol's return from the open of the following week to the close 13 weeks and 26 weeks after the entry week. Entry at the following open avoids assuming a fill in the week the report was released.

The panel shows the episode count, median return and share of positive returns for upper-zone entries, lower-zone entries, and every week with a valid reading. The all-weeks rows are the baseline: compare each zone's figures against them, not against zero. A row with fewer than 5 episodes shows "few" in place of statistics.

The panel is in-sample and descriptive. It runs no significance test, episode counts are small with default settings, and the all-weeks baseline uses overlapping windows. Treat it as a check on the reading, not as evidence that the reading has predictive value.

═══════════════════════════════════════

[b]█ DASHBOARD[/b]

The dashboard shows the zone state, the active CFTC code with report and options setting, the hedger group, hedger and Managed Money net as a percent of open interest, both percentiles, and data age. Data age is the number of weeks since open interest last changed. The cell turns orange at 2 weeks or more, which flags a delayed report.

═══════════════════════════════════════

[b]█ SETTINGS[/b]

[b]Hedger group:[/b] Producer/Merchant, or Producer/Merchant plus Swap Dealers.
[b]Include options:[/b] futures and options combined, or futures only.
[b]COT futures contract:[/b] optional. Pick the futures contract whose report to read, for example ICEUS:SB1! for sugar. Left blank, the script uses the chart's own futures contract on CME, CBOT, NYMEX, COMEX or ICE US. On common spot and CFD symbols, and on unleveraged single-commodity ETFs that hold the commodity or its futures, such as XAUUSD, GLD, USO and CANE, it reads the futures report for the same commodity. Any other chart shows a centered prompt until a contract is picked.
[b]CFTC code override:[/b] optional. A six-character CFTC code, such as 088691 for gold, takes priority over the contract setting and the chart. Examples: 088691 gold, 084691 silver, 085692 copper, 067651 WTI crude.
[b]Percentile lookback:[/b] 156 weeks by default.
[b]Extreme band width:[/b] 20 by default, which places the upper zone at 80 and above and the lower zone at 20 and below.
[b]Episode separation:[/b] 26 weeks by default.
[b]Short and long horizon:[/b] 13 and 26 weeks by default.
[b]Minimum episodes:[/b] 5 by default.
[b]Show dashboard and Show forward-return panel:[/b] both off by default. Turn them on in the Display and Forward-return panel groups.

═══════════════════════════════════════

[b]█ LIMITATIONS[/b]

[b]Weekly charts only.[/b] On any other timeframe the script plots nothing, fires no alerts and shows a centered warning to switch to 1W. COT data is weekly, and every window in the script is counted in weekly bars.

[b]Physical commodities only.[/b] The Disaggregated report does not cover financial futures such as equity index, interest rate or currency contracts. The script shows a message when no data returns for the selected code.

[b]CFTC-reported exchanges only.[/b] Futures on other exchanges, such as Brent on ICE Futures Europe, show a prompt instead of data. Equity ETFs such as oil and gas producer funds, and leveraged or inverse commodity ETFs, are not mapped to any commodity report.

[b]Report timing.[/b] Positions are as of Tuesday and published the following Friday afternoon. Holidays and government shutdowns have delayed releases by days to weeks. Historical data shows each report at its as-of date, not the date it became public, so past readings include information that was not available in real time during those delays.

[b]Roll gaps.[/b] Forward returns on an unadjusted continuous contract include the price gaps at each contract roll. Enable back-adjustment for continuous futures in the chart settings before reading the panel, particularly on energy contracts.

[b]Positioning moves with price.[/b] In many physical markets, hedger net moves opposite to price from week to week, because hedgers add shorts into rallies and reduce them into declines. A zone entry often follows a large price move that has already happened.

[b]Relative reading.[/b] A percentile describes where the current reading sits within the lookback window. A market whose positioning has shifted structurally can stay in one zone for long stretches.

[b]History.[/b] Disaggregated data begins in 2006, and the first readings appear only after the lookback fills, about three years later with default settings.

[b]Mapped and overridden symbols.[/b] On a spot, CFD or ETF chart, the positioning shown is the futures market's, and the forward-return panel measures the chart symbol, including any ETF roll and fee drag. When the override points at a different contract than the chart, the panel still measures the chart symbol.

═══════════════════════════════════════

[b]█ ORIGINALITY[/b]

TradingView's built-in Commitment of Traders indicators display report metrics directly, and many published COT Index scripts rescale Legacy commercial or speculator net positions with min-max scaling. This script differs in four ways. It isolates the physical hedger category with Disaggregated data instead of the Legacy Commercial category, which also contains swap dealers. It normalizes by open interest before ranking. It uses a percentile rank and de-clusters zone entries so each episode counts once. It measures the chart symbol's return after each entry against an all-weeks baseline on the same chart.

COT tickers are built with TradingView's LibraryCOT library.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BY_Tse

// COT Hedger Positioning Extremes v1.1
// Ranks hedger net positioning from the CFTC Disaggregated Commitment of Traders
// report against its own history and marks entries into the extreme bands.
//
// Hedger net   Producer/Merchant/Processor/User long minus short, optionally plus
//              Swap Dealer long minus short, as a percent of open interest.
// Percentile   Share of the previous N weekly readings at or below the current one.
// Upper zone   Percentile at or above 100 minus the band width.
// Lower zone   Percentile at or below the band width.
// Entry        First week in a zone after at least the separation period outside it.
// Panel        Chart symbol return from the next weekly open to the weekly close
//              h weeks after each entry week, against an all-weeks baseline.

//@version=6
indicator("COT Hedger Positioning Extremes", shorttitle = "COT Hedgers", overlay = false, precision = 1)

import TradingView/LibraryCOT/6 as cot

// ── Inputs ───────────────────────────────────────────────────────────────────
const string GRP_DATA  = "COT data"
const string GRP_ZONE  = "Zones"
const string GRP_STATS = "Forward-return panel"
const string GRP_DISP  = "Display"

const string HG_PM   = "Producer/Merchant"
const string HG_PMSW = "Producer/Merchant + Swap Dealers"

string hedgerMode   = input.string(HG_PM, "Hedger group", options = [HG_PM, HG_PMSW], group = GRP_DATA,
     tooltip = "Producer/Merchant is the physical hedger category. Adding Swap Dealers approximates the Legacy report's Commercial category.")
bool   includeOpt   = input.bool(true, "Include options", group = GRP_DATA,
     tooltip = "On: futures and options combined. Off: futures only.")
string cotSymbol    = input.symbol("", "COT futures contract", group = GRP_DATA,
     tooltip = "Optional. Pick the futures contract whose COT report to read, for example ICEUS:SB1! for sugar or COMEX:GC1! for gold. Leave blank to use the chart's own futures contract, or the matching report on common spot, CFD and single-commodity ETF symbols such as XAUUSD, GLD and USO.")
string codeOverride = input.string("", "CFTC code override", group = GRP_DATA,
     tooltip = "Optional. A six-character CFTC code takes priority over everything else. Examples: 088691 gold, 084691 silver, 085692 copper, 067651 WTI crude.")

int lookback = input.int(156, "Percentile lookback (weeks)", minval = 52, maxval = 520, group = GRP_ZONE)
int bandPct  = input.int(20, "Extreme band width", minval = 5, maxval = 40, group = GRP_ZONE,
     tooltip = "20 sets the upper zone at 80 and above and the lower zone at 20 and below.")
int sepWeeks = input.int(26, "Episode separation (weeks)", minval = 1, maxval = 104, group = GRP_ZONE,
     tooltip = "A zone entry counts only after the line has spent at least this many weeks outside that zone.")

bool showStats = input.bool(false, "Show forward-return panel", group = GRP_STATS)
int  hShort    = input.int(13, "Short horizon (weeks)", minval = 1, maxval = 52, group = GRP_STATS)
int  hLong     = input.int(26, "Long horizon (weeks)", minval = 1, maxval = 104, group = GRP_STATS)
int  minEp     = input.int(5, "Minimum episodes to show statistics", minval = 1, maxval = 30, group = GRP_STATS)

bool showMM    = input.bool(true, "Show Managed Money percentile", group = GRP_DISP)
bool showBg    = input.bool(true, "Shade zones", group = GRP_DISP)
bool showTable = input.bool(false, "Show dashboard", group = GRP_DISP)

const color UP_COL  = #26a69a
const color LO_COL  = #ef5350
const color NEU_COL = #9e9e9e
const color MM_COL  = #5b8def

// ── Timeframe check ──────────────────────────────────────────────────────────
// COT data is weekly and every window below is counted in weekly bars. On any
// other timeframe the script plots nothing and shows a centered warning.
bool isWeekly = timeframe.isweekly and timeframe.multiplier == 1

// ── COT data ─────────────────────────────────────────────────────────────────
// Code source, in priority order:
//   1. CFTC code override
//   2. COT futures contract input, through getCFTCCode()
//   3. The chart's own futures contract, through getCFTCCode()
//   4. Spot, CFD and unleveraged single-commodity ETF symbols, through f_spotCode()
// getCFTCCode() raises a runtime error on any symbol it cannot map, so it is
// called only for futures on CME Group and ICE US exchanges, prefix variants such
// as _MINI and _DL included. Any other case with no code shows a prompt instead
// of an error and requests a placeholder code that returns no data, since
// COTTickerid() rejects an empty code. Stocks are never mapped, so an equity
// ticker that matches a commodity name is not misread. Leveraged and inverse
// ETFs are left out because their forward returns would not match the signal.
f_cftcExchange(string p) =>
    str.startswith(p, "CME") or str.startswith(p, "CBOT") or str.startswith(p, "NYMEX") or str.startswith(p, "COMEX") or str.startswith(p, "ICEUS")

f_spotCode(string t) =>
    switch t
        // Gold: COMEX 088691
        "XAUUSD"    => "088691"
        "GOLD"      => "088691"
        "GLD"       => "088691"
        "IAU"       => "088691"
        "IAUM"      => "088691"
        "GLDM"      => "088691"
        "SGOL"      => "088691"
        "AAAU"      => "088691"
        "BAR"       => "088691"
        "OUNZ"      => "088691"
        "PHYS"      => "088691"
        // Silver: COMEX 084691
        "XAGUSD"    => "084691"
        "SILVER"    => "084691"
        "SLV"       => "084691"
        "SIVR"      => "084691"
        "PSLV"      => "084691"
        // Platinum: NYMEX 076651
        "XPTUSD"    => "076651"
        "PLATINUM"  => "076651"
        "PPLT"      => "076651"
        "PLTM"      => "076651"
        // Palladium: NYMEX 075651
        "XPDUSD"    => "075651"
        "PALLADIUM" => "075651"
        "PALL"      => "075651"
        // Copper: COMEX 085692
        "COPPER"    => "085692"
        "XCUUSD"    => "085692"
        "CPER"      => "085692"
        // WTI crude: NYMEX 067651
        "USOIL"     => "067651"
        "WTICOUSD"  => "067651"
        "USO"       => "067651"
        "USL"       => "067651"
        "DBO"       => "067651"
        "OILK"      => "067651"
        // Natural gas: NYMEX 023651
        "NATGAS"    => "023651"
        "NATGASUSD" => "023651"
        "XNGUSD"    => "023651"
        "UNG"       => "023651"
        "UNL"       => "023651"
        // RBOB gasoline: NYMEX 111659
        "UGA"       => "111659"
        // Corn: CBOT 002602
        "CORN"      => "002602"
        "CORNUSD"   => "002602"
        // Wheat SRW: CBOT 001602
        "WEAT"      => "001602"
        "WHEAT"     => "001602"
        "WHEATUSD"  => "001602"
        // Soybeans: CBOT 005602
        "SOYB"      => "005602"
        "SOYBEAN"   => "005602"
        "SOYBNUSD"  => "005602"
        // Sugar No. 11: ICE US 080732
        "CANE"      => "080732"
        "SUGAR"     => "080732"
        "SUGARUSD"  => "080732"
        // Coffee C, cocoa, cotton No. 2: ICE US
        "COFFEE"    => "083731"
        "COCOA"     => "073732"
        "COTTON"    => "033661"
        => ""

bool   isFutures  = syminfo.type == "futures"
bool   cftcExch   = isFutures and f_cftcExchange(syminfo.prefix)
string ovr        = str.trim(codeOverride)
bool   hasPick    = cotSymbol != ""
string pickPrefix = str.contains(cotSymbol, ":") ? str.substring(cotSymbol, 0, str.pos(cotSymbol, ":")) : ""
bool   pickOk     = hasPick and f_cftcExchange(pickPrefix)
string spotCode   = isFutures or syminfo.type == "stock" ? "" : f_spotCode(syminfo.ticker)

// "override", "pick", "chart", "map" or "none"
string codeSrc = ovr != "" ? "override" : hasPick ? "pick" : cftcExch ? "chart" : spotCode != "" ? "map" : "none"
bool   noCode  = codeSrc == "none" or (codeSrc == "pick" and not pickOk)
bool   canRun  = isWeekly and not noCode

string cftcCode = codeSrc == "override" ? ovr : codeSrc == "map" ? spotCode : ""
if codeSrc == "pick" and pickOk
    cftcCode := cot.getCFTCCode(ticker.standard(cotSymbol))
if codeSrc == "chart"
    cftcCode := cot.getCFTCCode(ticker.standard(syminfo.tickerid))
string reqCode = cftcCode == "" ? "000000" : cftcCode

f_cot(string metric, string dir) =>
    request.security(cot.COTTickerid("Disaggregated", reqCode, includeOpt, metric, dir, "All"), "1W", close, ignore_invalid_symbol = true)

float pmLong  = f_cot("Producer Merchant Positions", "Long")
float pmShort = f_cot("Producer Merchant Positions", "Short")
float swLong  = f_cot("Swap Positions", "Long")
float swShort = f_cot("Swap Positions", "Short")
float mmLong  = f_cot("Managed Money Positions", "Long")
float mmShort = f_cot("Managed Money Positions", "Short")
float openInt = f_cot("Open Interest", "No direction")

// ── Positioning ──────────────────────────────────────────────────────────────
bool  incSwap   = hedgerMode == HG_PMSW
float hedgerNet = pmLong - pmShort + (incSwap ? nz(swLong) - nz(swShort) : 0.0)
float mmNet     = mmLong - mmShort
float hedgerOI  = openInt > 0 ? 100 * hedgerNet / openInt : na
float mmOI      = openInt > 0 ? 100 * mmNet / openInt : na

// Percentile output starts only when the script can run, once the lookback holds
// valid readings. Gating here blanks plots, zones, entries, stats and alerts.
var int nValid = 0
if not na(hedgerOI)
    nValid += 1
bool ready = canRun and nValid > lookback

float hRankRaw   = ta.percentrank(hedgerOI, lookback)
float mRankRaw   = ta.percentrank(mmOI, lookback)
float hedgerRank = ready ? hRankRaw : na
float mmRank     = ready and not na(mmOI) ? mRankRaw : na

// ── Zones and de-clustered entries ───────────────────────────────────────────
float upperBand = 100 - bandPct
float lowerBand = bandPct
int   zone      = na(hedgerRank) ? 0 : hedgerRank >= upperBand ? 1 : hedgerRank <= lowerBand ? -1 : 0

var int lastUpper = na
var int lastLower = na
bool enterUpper = zone == 1  and ready[1] and zone[1] != 1  and (na(lastUpper) or bar_index - lastUpper > sepWeeks)
bool enterLower = zone == -1 and ready[1] and zone[1] != -1 and (na(lastLower) or bar_index - lastLower > sepWeeks)
if zone == 1
    lastUpper := bar_index
if zone == -1
    lastLower := bar_index

// ── Forward returns ──────────────────────────────────────────────────────────
// Entry at the open of the week after the signal week, exit at the close h weeks
// after the signal week.
float retShort = close / open[hShort - 1] - 1
float retLong  = close / open[hLong - 1] - 1

var array<float> upS  = array.new<float>()
var array<float> upL  = array.new<float>()
var array<float> loS  = array.new<float>()
var array<float> loL  = array.new<float>()
var array<float> allS = array.new<float>()
var array<float> allL = array.new<float>()

if not na(retShort)
    if enterUpper[hShort]
        upS.push(retShort)
    if enterLower[hShort]
        loS.push(retShort)
    if ready[hShort]
        allS.push(retShort)
if not na(retLong)
    if enterUpper[hLong]
        upL.push(retLong)
    if enterLower[hLong]
        loL.push(retLong)
    if ready[hLong]
        allL.push(retLong)

// ── Data age ─────────────────────────────────────────────────────────────────
// Weeks since open interest last changed. Flags delayed reports.
var int lastOiChange = na
if not na(openInt) and (na(openInt[1]) or openInt != openInt[1])
    lastOiChange := bar_index
int dataAge = na(lastOiChange) ? na : bar_index - lastOiChange

// ── Plots ────────────────────────────────────────────────────────────────────
color zoneCol = zone == 1 ? UP_COL : zone == -1 ? LO_COL : NEU_COL

plot(hedgerRank,               "Hedger percentile",        color = zoneCol, linewidth = 2)
plot(showMM ? mmRank : na,     "Managed Money percentile", color = color.new(MM_COL, 30), linewidth = 1)
hline(100 - bandPct, "Upper band", color = color.new(UP_COL, 50),  linestyle = hline.style_dashed)
hline(50,            "Midline",    color = color.new(NEU_COL, 70), linestyle = hline.style_dotted)
hline(bandPct,       "Lower band", color = color.new(LO_COL, 50),  linestyle = hline.style_dashed)
bgcolor(showBg and zone != 0 ? color.new(zoneCol, 88) : na, title = "Zone shading")

plotshape(enterUpper, "Upper zone entry", shape.triangleup,   location.bottom, UP_COL, size = size.small)
plotshape(enterLower, "Lower zone entry", shape.triangledown, location.top,    LO_COL, size = size.small)

// ── Status label ─────────────────────────────────────────────────────────────
var label statusLbl = na
if barstate.islast and canRun
    label.delete(statusLbl)
    string msg = na(openInt) or na(pmLong) ? "No Disaggregated COT data for CFTC code " + cftcCode + ". This report covers physical commodities only." :
         not ready ? "Warming up: " + str.tostring(nValid) + " of " + str.tostring(lookback + 1) + " weeks of COT data loaded." : ""
    if msg != ""
        statusLbl := label.new(bar_index, 50, msg, style = label.style_label_left, color = LO_COL, textcolor = color.white, size = size.small)

// ── Tables ───────────────────────────────────────────────────────────────────
f_fmt(float v, string fmt, string suffix) =>
    na(v) ? "n/a" : str.tostring(v, fmt) + suffix

f_fmtRet(float v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(100 * v, "0.0") + "%"

f_kv(table t, int row, string key, string val, color valCol) =>
    table.cell(t, 0, row, key, text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, row, val, text_color = valCol, text_size = size.small, text_halign = text.align_right)

f_statRow(table t, int row, string name, array<float> a, int minN) =>
    int n  = a.size()
    int up = 0
    for v in a
        if v > 0
            up += 1
    bool enough = n >= minN
    table.cell(t, 0, row, name, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, row, str.tostring(n), text_color = color.gray, text_size = size.small)
    table.cell(t, 2, row, enough ? f_fmtRet(a.median()) : "few", text_color = color.white, text_size = size.small)
    table.cell(t, 3, row, enough ? str.tostring(100.0 * up / n, "0") + "%" : "few", text_color = color.white, text_size = size.small)

var table dash  = showTable and canRun ? table.new(position.top_right, 2, 8, bgcolor = color.new(color.black, 20), border_color = color.new(color.gray, 60), border_width = 1) : na
var table stats = showStats and canRun ? table.new(position.bottom_right, 4, 7, bgcolor = color.new(color.black, 20), border_color = color.new(color.gray, 60), border_width = 1) : na
var table warn  = canRun ? na : table.new(position.middle_center, 1, 2, bgcolor = color.new(LO_COL, 10), frame_color = color.white, frame_width = 2)

if not canRun and barstate.islast
    // Delayed-data feeds carry a _DLY suffix on the exchange prefix; drop it for display.
    string chartExch = str.replace_all(syminfo.prefix, "_DLY", "")
    string pickExch  = str.replace_all(pickPrefix, "_DLY", "")
    string exchList  = "This indicator reads CFTC reports for futures on CME, CBOT, NYMEX, COMEX and ICE US."
    string warnTitle = not isWeekly ? "WEEKLY CHART REQUIRED" : codeSrc == "pick" or isFutures ? "NO CFTC REPORT FOR THIS EXCHANGE" : "COT CONTRACT REQUIRED"
    string warnBody  = not isWeekly ? "Switch the chart timeframe to 1W.\nCOT data is weekly and every window in this indicator is counted in weekly bars." :
         codeSrc == "pick" ? "The selected COT futures contract trades on " + (pickExch == "" ? "an unrecognized exchange" : pickExch) + ".\n" + exchList + "\nPick a contract from one of those exchanges in Settings, COT data, COT futures contract." :
         isFutures ? "This contract trades on " + chartExch + ".\n" + exchList + "\nTo read another contract's report, pick it in Settings, COT data, COT futures contract." :
         "This symbol has no automatic COT mapping.\nPick the matching futures contract in Settings, COT data, COT futures contract.\nExamples: ICEUS:SB1! for sugar, COMEX:GC1! for gold."
    table.cell(warn, 0, 0, warnTitle, text_color = color.white, text_size = size.large)
    table.cell(warn, 0, 1, warnBody,  text_color = color.white, text_size = size.normal)

if showTable and canRun and barstate.islast
    string stateTxt = not ready ? "WARMING UP" : zone == 1 ? "UPPER ZONE" : zone == -1 ? "LOWER ZONE" : "NEUTRAL"
    table.cell(dash, 0, 0, "COT HEDGERS", text_color = color.white, text_size = size.normal, bgcolor = zoneCol)
    table.cell(dash, 1, 0, stateTxt,      text_color = color.white, text_size = size.normal, bgcolor = zoneCol)
    f_kv(dash, 1, "Source",            "Disagg " + (includeOpt ? "F+O " : "F ") + cftcCode, color.white)
    f_kv(dash, 2, "Hedger group",      incSwap ? "PM + Swap" : "PM", color.white)
    f_kv(dash, 3, "Hedger net / OI",   f_fmt(hedgerOI, "0.0", "%"), color.white)
    f_kv(dash, 4, "Hedger percentile", f_fmt(hedgerRank, "0", ""), zoneCol)
    f_kv(dash, 5, "MM net / OI",       f_fmt(mmOI, "0.0", "%"), MM_COL)
    f_kv(dash, 6, "MM percentile",     f_fmt(mmRank, "0", ""), MM_COL)
    f_kv(dash, 7, "Data age",          na(dataAge) ? "n/a" : str.tostring(dataAge) + " wk", dataAge >= 2 ? color.orange : color.white)

if showStats and canRun and barstate.islast
    string hs = str.tostring(hShort) + "w"
    string hl = str.tostring(hLong) + "w"
    table.cell(stats, 0, 0, "Chart return after", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(stats, 1, 0, "n",                  text_color = color.gray, text_size = size.small)
    table.cell(stats, 2, 0, "Median",             text_color = color.gray, text_size = size.small)
    table.cell(stats, 3, 0, "% up",               text_color = color.gray, text_size = size.small)
    f_statRow(stats, 1, "Upper entry +" + hs, upS,  minEp)
    f_statRow(stats, 2, "Upper entry +" + hl, upL,  minEp)
    f_statRow(stats, 3, "Lower entry +" + hs, loS,  minEp)
    f_statRow(stats, 4, "Lower entry +" + hl, loL,  minEp)
    f_statRow(stats, 5, "All weeks +" + hs,   allS, minEp)
    f_statRow(stats, 6, "All weeks +" + hl,   allL, minEp)

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(enterUpper, "Upper zone entry", "COT Hedgers: hedger net entered the upper extreme of its percentile range.")
alertcondition(enterLower, "Lower zone entry", "COT Hedgers: hedger net entered the lower extreme of its percentile range.")
````
