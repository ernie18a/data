# Smart Money Concepts Pro [CandleChasers]

- url: https://www.tradingview.com/script/ZNskCQJh-Smart-Money-Concepts-Pro-CandleChasers/
- type: indicator
- pine_id: PUB;91509529176e4acf82f478e7654dbea0
- version: 1.0

## Description

[b]Smart Money Concepts Pro [CandleChasers]
[/b]
Smart Money Concepts Pro organizes market structure, liquidity, price imbalances and session context into a configurable chart-analysis workflow. Its qualified setup markers follow explicit rules, and the latest-setup panel explains the sweep, structure shift, displacement and zone rejection behind each signal.

This is an indicator. It does not place trades, run a strategy or infer institutional orders from candle data. It makes no win-rate, signal-accuracy or future-profitability claims.
How the components work together

Market structure establishes directional context. Swing and internal pivots confirm after the selected number of right-side bars. Continuation BOS requires a close through an unbroken same-direction pivot. Reversal CHoCH requires a close through a protected opposite pivot anchored by the preceding directional break. Smaller new pivots alone do not change that protected level.

Liquidity pools track unswept swing highs/lows. Nearby same-source pivots can merge into equal-high/low clusters. A wick breach followed by a close back inside is a sweep; a close-through consumes the pool without being classified as a sweep. Completed session highs/lows can optionally become source-labelled liquidity pools.

Order blocks use the nearest opposing candle before a swing break that meets displacement and body/range thresholds. An optional recent directional fair value gap validates the block. Candidates crossed at their distal edge or re-entered after departure before detection are rejected.

Fair value gaps use three-candle wick non-overlap with a directional middle candle and a minimum width relative to prior-bar ATR. Zones track fresh, touched and partially filled states, then retire according to mitigation, invalidation, expiry or capacity rules. Active-only and bounded historical views are available.

Higher-timeframe bias, structure and zones use previously completed higher-timeframe values. Imported events appear at the first following chart candle close. Optional higher-timeframe bias agreement can filter setups.

[b]Qualified setup sequence
[/b]
With sequence enforcement enabled, a long requires:

1. A sell-side liquidity sweep.
2. A later bullish structure break from the chosen internal or swing engine.
3. Directional bullish displacement on the shift bar or later.
4. A bullish rejection of an eligible existing zone on a later bar.

Shorts use the inverse sequence. The zone must have been detected at or after the shift. Opposite breaks/sweeps reset the sequence, it expires after the configured bars, and a qualified setup consumes it. Users can require CHoCH rather than any directional break.

Final qualification also requires swing bias agreement and whichever premium/discount, higher-timeframe, session and cooldown filters are enabled. A rejection overlaps the zone, closes beyond its near edge in the expected direction and does not breach the distal edge on that candle. First-only or multiple distinct retest encounters are supported.

The latest-setup explanation records actual event prices/times and passed filters. It is an audit trail rather than a probability or confidence score.

[b]Sessions, opening ranges and kill zones
[/b]
Regional mode includes editable Sydney, Asia/Tokyo, Frankfurt, London, New York full, New York AM, New York PM and Custom windows. Each uses an IANA timezone for region-specific daylight-saving behavior. Custom includes Toronto and other common zones, with an arbitrary supported IANA option. Selected windows combine with OR.

New York kill-zone mode substitutes four editable presets on the New York clock: Asia 19:00–00:00, London 02:00–05:00, NY AM 07:00–10:00 and NY PM 13:00–16:00. Sydney, Frankfurt and NY Full are inactive in that mode; Custom remains available. These are configurable analysis conventions, not exchange holiday calendars.

Selected session highs/lows develop on confirmed chart candles and freeze after completion. Opening ranges default to the first 30 elapsed minutes and freeze before their lines are drawn. The script uses fully contained chart bars and labels partial observed data. It does not synthesize missing intrabars. Completed levels have configurable extension and bounded history.

[b]Using the indicator
[/b]
Use standard, time-based candles. Select a higher timeframe strictly above the chart timeframe or disable higher-timeframe context. Start with a chart interval that aligns with your session and opening-range boundaries.

Input groups separate structure, zones, higher timeframe, liquidity, setups, planning, appearance, sessions, range/kill-zone settings and explanations. Minimal, Structure and Full Suite presets change visibility without changing setup detection. The master session filter defaults off, and feeding session ranges into liquidity pools defaults off.

Optional planning lines show the signal-close entry, an ATR-buffered zone stop and three increasing R-multiple targets. These are static planning levels, not filled orders or a trading recommendation.

[b]Alerts
[/b]
Named conditions cover bullish/bearish BOS, CHoCH, liquidity sweeps, order blocks, FVGs and qualified setups. Select Once Per Bar Close for named alerts.
Select Any alert() function call for detailed setup messages, including event provenance, zone/source timeframe, sessions and planned prices. Optional new-zone and session/opening-range completion messages can be included. Several distinct event messages may occur on one confirmed close. Recreate alerts after input changes.

[b]Timing and limitations
[/b]
Chart events confirm at candle close. Pivot detection retains its confirmation delay. Structure labels appear when detected. OB/FVG boxes extend to their historical geometric origins, with detection-time labels; those origins do not mean a signal was available earlier.

Developing session ranges move as new confirmed candles extend them. Completed opening/session ranges freeze. Some dashboard context uses the current live close, while setup markers confirm at close. The indicator does not claim that every visual element is immutable.
A chart that begins mid-session, lacks bars or uses an interval crossing boundaries can produce a partial or unavailable opening range. Session hours do not account for holidays. The premium/discount map uses the latest confirmed high/low pair, not a frozen impulse leg. Selective filters can produce few or no setups. Defaults are not optimized for any market.

[b]Design purpose
[/b]
The suite combines common SMC concepts for one explicit sequence rather than treating unrelated overlays as independent trading signals. Protected structure, selective zone validation, source-labelled liquidity, zone lifecycles, confirmed higher-timeframe packets and a persistent setup explanation make its decisions inspectable. Session ranges add context without requiring them to alter signals unless the optional liquidity integration is enabled.

## Source Code

````pine
//@version=6
indicator("Smart Money Concepts Pro [CandleChasers]", shorttitle="SMC [CandleChasers]", overlay=true, max_boxes_count=200, max_lines_count=450, max_labels_count=250, max_bars_back=2000)
// Smart Money Concepts Pro [CandleChasers]| Original implementation.
// Confirmed chart events; HTF uses exclusively previous completed HTF values.
// Historical origins do NOT mean signals were available there. Labels use detection.
// Protected structure is a documented mechanical approximation, not order-flow data.

string G1 = "01 | Structure"
int swingLen = input.int(10, "Swing pivot confirmation bars", minval=2, maxval=100, group=G1, display=display.data_window)
int microLen = input.int(3, "Internal pivot confirmation bars", minval=1, maxval=50, group=G1, display=display.data_window)
bool internalOn = input.bool(true, "Display internal structure", group=G1, display=display.none)
int eventCap = input.int(70, "Structure history", minval=10, maxval=90, group=G1, display=display.data_window)
string G2 = "02 | Zone validation & lifecycle"
bool obOn = input.bool(true, "Detect order blocks", group=G2, display=display.none)
bool fvgOn = input.bool(true, "Detect fair value gaps", group=G2, display=display.none)
int atrLen = input.int(14, "ATR length", minval=2, maxval=100, group=G2, display=display.data_window)
float dispATR = input.float(0.8, "Displacement body / prior ATR", minval=0.1, step=0.1, group=G2, display=display.data_window)
float bodyRatio = input.float(0.55, "Displacement minimum body / range", minval=0.1, maxval=1, step=0.05, group=G2, display=display.data_window)
int obSearch = input.int(30, "Opposing candle search bars", minval=2, maxval=200, group=G2, display=display.data_window)
string obBounds = input.string("Wicks", "Order block boundaries", options=["Wicks", "Body"], group=G2, display=display.data_window)
bool obNeedsGap = input.bool(true, "OB requires recent directional FVG", group=G2, display=display.none)
int gapWindow = input.int(3, "OB FVG association window", minval=1, maxval=20, group=G2, display=display.data_window)
float gapATR = input.float(0.10, "Minimum FVG width / prior ATR", minval=0, step=0.05, group=G2, display=display.data_window)
string invalidation = input.string("Close", "OB invalidation basis", options=["Close", "Wick"], group=G2, display=display.data_window)
string retireAt = input.string("Full fill", "Retire zone at", options=["First touch", "Midpoint", "Full fill"], group=G2, display=display.data_window)
int ageLimit = input.int(500, "Chart zone expiry bars", minval=20, maxval=1500, group=G2, display=display.data_window)
int htfAgeLimit = input.int(100, "HTF zone expiry HTF bars", minval=5, maxval=500, group=G2, display=display.data_window)
int activeCap = input.int(40, "Maximum active zones", minval=5, maxval=80, group=G2, display=display.data_window)
int archiveCap = input.int(30, "Maximum historical zones", minval=0, maxval=60, group=G2, display=display.data_window)
string zoneView = input.string("Active only", "Zone history", options=["Active only", "Active + historical"], group=G2, display=display.data_window)
string G3 = "03 | Higher timeframe"
bool htfOn = input.bool(true, "Enable confirmed HTF context", group=G3, display=display.none)
string htf = input.timeframe("240", "Higher timeframe", group=G3, display=display.data_window)
bool htfZones = input.bool(true, "Detect HTF zones", group=G3, display=display.none)
bool htfGate = input.bool(false, "Require HTF bias agreement for setups", group=G3, display=display.none)
string G4 = "04 | Liquidity"
bool liquidityOn = input.bool(true, "Display liquidity levels", group=G4, display=display.none)
int liquidityCap = input.int(30, "Maximum unswept pools", minval=5, maxval=60, group=G4, display=display.data_window)
float eqATR = input.float(0.10, "Equal high / low cluster tolerance / ATR", minval=0, step=0.05, group=G4, display=display.data_window)
int liquidityAge = input.int(1000, "Liquidity expiry bars", minval=20, maxval=1800, group=G4, display=display.data_window)
bool dayOn = input.bool(true, "Previous day levels (intraday)", group=G4, display=display.none)
string G5 = "05 | Setup sequence & retests"
bool setupsOn = input.bool(true, "Enable qualified retests", group=G5, display=display.none)
bool sequenceOn = input.bool(true, "Require sweep > shift > displacement > retest", group=G5, display=display.none)
string shiftSource = input.string("Internal", "Sequence structure shift", options=["Internal", "Swing"], group=G5, display=display.data_window)
int sequenceTTL = input.int(40, "Sequence expires after bars from sweep", minval=3, maxval=300, group=G5, display=display.data_window)
string shiftKind = input.string("Any directional break", "Sequence shift requirement", options=["Any directional break", "CHoCH only"], group=G5, display=display.data_window)
bool pdGate = input.bool(true, "Require discount long / premium short", group=G5, display=display.none)
string retestMode = input.string("Multiple", "Retest attempts", options=["First only", "Multiple"], group=G5, display=display.data_window)
int maxAttempts = input.int(3, "Maximum distinct zone encounters", minval=1, maxval=10, group=G5, display=display.data_window)
int setupCooldown = input.int(5, "Setup cooldown bars", minval=0, maxval=100, group=G5, display=display.data_window)
string G8 = "08 | Global sessions & timezones"
bool sessionOn = input.bool(false, "Filter setups by selected sessions", group=G8, display=display.none)
string sessionDays = input.string("Weekdays", "Session days", options=["Weekdays", "All days"], group=G8, display=display.data_window)
string sessionMembership = input.string("Bar opens inside", "Session membership", options=["Bar opens inside", "Entire candle inside"], group=G8, display=display.data_window)
bool sessionShade = input.bool(false, "Shade selected active sessions", group=G8, display=display.none)
bool sessionPanelOn = input.bool(false, "Show session / timezone panel", group=G8, display=display.none)
bool sydneyOn = input.bool(false, "Sydney: show / include", group=G8, inline="syd", display=display.none)
string sydneyHours = input.session("0800-1700", "Hours", group=G8, inline="syd", display=display.data_window)
string sydneyTZ = input.string("Australia/Sydney", "Sydney IANA timezone", group=G8, display=display.data_window)
bool tokyoOn = input.bool(false, "Asia / Tokyo: show / include", group=G8, inline="tok", display=display.none)
string tokyoHours = input.session("0900-1800", "Hours", group=G8, inline="tok", display=display.data_window)
string tokyoTZ = input.string("Asia/Tokyo", "Asia IANA timezone", group=G8, display=display.data_window)
bool frankfurtOn = input.bool(false, "Frankfurt: show / include", group=G8, inline="fra", display=display.none)
string frankfurtHours = input.session("0800-1700", "Hours", group=G8, inline="fra", display=display.data_window)
string frankfurtTZ = input.string("Europe/Berlin", "Frankfurt IANA timezone", group=G8, display=display.data_window)
bool londonOn = input.bool(true, "London: show / include", group=G8, inline="lon", display=display.none)
string londonHours = input.session("0800-1700", "Hours", group=G8, inline="lon", display=display.data_window)
string londonTZ = input.string("Europe/London", "London IANA timezone", group=G8, display=display.data_window)
bool newYorkOn = input.bool(false, "New York full: show / include", group=G8, inline="ny", display=display.none)
string newYorkHours = input.session("0800-1700", "Hours", group=G8, inline="ny", display=display.data_window)
string newYorkTZ = input.string("America/New_York", "New York full IANA timezone", group=G8, display=display.data_window)
bool nyAMOn = input.bool(true, "New York AM: show / include", group=G8, inline="am", display=display.none)
string nyAMHours = input.session("0830-1200", "Hours", group=G8, inline="am", display=display.data_window)
string nyAMTZ = input.string("America/New_York", "New York AM IANA timezone", group=G8, display=display.data_window)
bool nyPMOn = input.bool(true, "New York PM: show / include", group=G8, inline="pm", display=display.none)
string nyPMHours = input.session("1300-1600", "Hours", group=G8, inline="pm", display=display.data_window)
string nyPMTZ = input.string("America/New_York", "New York PM IANA timezone", group=G8, display=display.data_window)
bool customSessionOn = input.bool(false, "Custom: show / include", group=G8, inline="custom", display=display.none)
string customHours = input.session("0930-1600", "Hours", group=G8, inline="custom", display=display.data_window)
string customTZChoice = input.string("America/Toronto", "Custom timezone", options=["America/Toronto", "America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney", "Pacific/Auckland", "Etc/UTC", "Exchange", "Custom IANA"], group=G8, display=display.data_window)
string customIANA = input.string("America/Toronto", "Custom IANA identifier (when selected)", group=G8, display=display.data_window)
string customTZ = customTZChoice == "Exchange" ? syminfo.timezone : customTZChoice == "Custom IANA" ? customIANA : customTZChoice
string G9 = "09 | Session ranges & kill zones"
string clockMode = input.string("Regional sessions", "Session clock mode", options=["Regional sessions", "New York kill zones"], group=G9, display=display.data_window)
string asiaKZHours = input.session("1900-0000", "Asia kill zone (New York time)", group=G9, display=display.data_window)
string londonKZHours = input.session("0200-0500", "London kill zone (New York time)", group=G9, display=display.data_window)
string nyAMKZHours = input.session("0700-1000", "New York AM kill zone", group=G9, display=display.data_window)
string nyPMKZHours = input.session("1300-1600", "New York PM kill zone", group=G9, display=display.data_window)
bool rangesOn = input.bool(true, "Show selected session high / low", group=G9, display=display.none)
bool openingRangeOn = input.bool(true, "Show opening range", group=G9, display=display.none)
int openingMinutes = input.int(30, "Opening range minutes", minval=5, maxval=180, step=5, group=G9, display=display.data_window)
int rangeExtension = input.int(240, "Completed level extension minutes", minval=0, maxval=4320, group=G9, display=display.data_window)
int rangeHistoryCap = input.int(8, "Completed session ranges retained", minval=0, maxval=20, group=G9, display=display.data_window)
bool rangeAlerts = input.bool(false, "Include range-complete alerts", group=G9, display=display.none)
bool sessionLiquidity = input.bool(false, "Feed completed session H/L into liquidity pools", group=G9, display=display.none)
string G10 = "10 | Setup explanation"
bool explanationOn = input.bool(true, "Show latest setup explanation", group=G10, display=display.none)
bool explainLabels = input.bool(false, "Attach explanation label to latest setup", group=G10, display=display.none)
bool killZones = clockMode == "New York kill zones"
// Kill-zone mode substitutes four editable windows anchored to New York time.
// Sydney, Frankfurt and NY Full are inactive in this mode; Custom remains available.
bool sydneyEnabled = sydneyOn and not killZones
bool frankfurtEnabled = frankfurtOn and not killZones
bool newYorkEnabled = newYorkOn and not killZones
string asiaWindow = killZones ? asiaKZHours : tokyoHours
string asiaClock = killZones ? "America/New_York" : tokyoTZ
string londonWindow = killZones ? londonKZHours : londonHours
string londonClock = killZones ? "America/New_York" : londonTZ
string amWindow = killZones ? nyAMKZHours : nyAMHours
string amClock = killZones ? "America/New_York" : nyAMTZ
string pmWindow = killZones ? nyPMKZHours : nyPMHours
string pmClock = killZones ? "America/New_York" : nyPMTZ

// Regional hours are editable analysis windows, not exchange holiday calendars.
// Local IANA zones automatically follow each region's own DST transitions.
// Selected windows combine with OR. NY Full therefore includes its AM/PM windows.
// Time-based intraday candles only; session alignment affects partial-boundary bars.

string G6 = "06 | Planning projections"
bool projectOn = input.bool(true, "Latest setup entry / stop / targets", group=G6, display=display.none)
float stopATR = input.float(0.15, "Stop buffer / ATR", minval=0, step=0.05, group=G6, display=display.data_window)
float r1 = input.float(1, "Target 1 R", minval=0.1, step=0.25, group=G6, display=display.data_window)
float r2 = input.float(2, "Target 2 R", minval=0.1, step=0.25, group=G6, display=display.data_window)
float r3 = input.float(3, "Target 3 R", minval=0.1, step=0.25, group=G6, display=display.data_window)
int projectionBars = input.int(30, "Projection length bars", minval=5, maxval=300, group=G6, display=display.data_window)
string G7 = "07 | Appearance & alerts"
string preset = input.string("Full Suite", "Chart preset", options=["Minimal", "Structure", "Full Suite"], group=G7, display=display.data_window)
bool zoneLabels = input.bool(true, "Zone detection / state labels", group=G7, display=display.none)
bool midlinesOn = input.bool(true, "Zone midpoint lines", group=G7, display=display.none)
bool panelOn = input.bool(true, "Dashboard and condition checklist", group=G7, display=display.none)
bool candleTint = input.bool(false, "Tint candles by swing bias", group=G7, display=display.none)
bool dynamicAlerts = input.bool(true, "Detailed setup alerts via alert()", group=G7, display=display.none)
bool zoneEventAlerts = input.bool(false, "Include detailed new-zone alerts", group=G7, display=display.none)
color bull = input.color(#21CBA5, "Bullish", group=G7, display=display.none)
color bear = input.color(#EF7183, "Bearish", group=G7, display=display.none)
color gold = input.color(#E9BB66, "Liquidity / brand", group=G7, display=display.none)

bool fullView = preset == "Full Suite"
bool structureView = preset != "Minimal"
bool zoneVisible = fullView
float atr = ta.atr(atrLen)
bool htfValid = timeframe.in_seconds(htf) > timeframe.in_seconds()
if barstate.isfirst and (r1 >= r2 or r2 >= r3)
    runtime.error("Targets must increase: T1 R < T2 R < T3 R.")
if barstate.isfirst and htfOn and not htfValid
    runtime.error("Choose a higher timeframe strictly above the chart timeframe, or disable HTF context.")

// This pure-output engine is reused by chart swing, internal and HTF contexts.
// A continuation breaks the latest unbroken pivot. An opposite CHoCH must break
// the frozen protected level established by the previous directional break.
// Protected anchor = most recent opposite confirmed pivot at the break.
f_engine(int n, bool commit) =>
    float ph = ta.pivothigh(high, n, n)
    float pl = ta.pivotlow(low, n, n)
    float a = ta.atr(atrLen)
    float priorATR = a[1]
    bool displaced = not na(priorATR) and math.abs(close - open) >= priorATR * dispATR and math.abs(close - open) / math.max(high - low, syminfo.mintick) >= bodyRatio
    bool gfUp = not na(priorATR) and low > high[2] and low - high[2] >= priorATR * gapATR and close[1] > open[1]
    bool gfDown = not na(priorATR) and high < low[2] and low[2] - high >= priorATR * gapATR and close[1] < open[1]
    int barsUpGap = ta.barssince(gfUp)
    int barsDownGap = ta.barssince(gfDown)
    var float sh = na
    var float sl = na
    var int sht = na
    var int slt = na
    var bool hb = false
    var bool lb = false
    var float protectedHigh = na
    var float protectedLow = na
    var int pht = na
    var int plt = na
    var int bias = 0
    // Break prior-known levels BEFORE incorporating pivots confirmed this bar.
    int event = 0
    float broken = na
    int brokenTime = na
    if commit
        bool up = bias == -1 ? not na(protectedHigh) and close > protectedHigh : not na(sh) and not hb and close > sh
        bool down = bias == 1 ? not na(protectedLow) and close < protectedLow : not na(sl) and not lb and close < sl
        if up
            event := bias == -1 ? 2 : 1
            broken := bias == -1 ? protectedHigh : sh
            brokenTime := bias == -1 ? pht : sht
            bias := 1
            hb := true
            protectedLow := sl
            plt := slt
            protectedHigh := na
            pht := na
        else if down
            event := bias == 1 ? -2 : -1
            broken := bias == 1 ? protectedLow : sl
            brokenTime := bias == 1 ? plt : slt
            bias := -1
            lb := true
            protectedHigh := sh
            pht := sht
            protectedLow := na
            plt := na
        if not na(ph)
            sh := ph
            sht := time_close
            hb := close > ph
            if bias == -1 and na(protectedHigh)
                protectedHigh := ph
                pht := time_close
        if not na(pl)
            sl := pl
            slt := time_close
            lb := close < pl
            if bias == 1 and na(protectedLow)
                protectedLow := pl
                plt := time_close
    float obTop = na
    float obBottom = na
    int obOrigin = na
    int dir = event > 0 ? 1 : event < 0 ? -1 : 0
    bool associatedGap = dir == 1 ? not na(barsUpGap) and barsUpGap < gapWindow : not na(barsDownGap) and barsDownGap < gapWindow
    if dir != 0 and displaced and (dir == 1 ? close > open : close < open) and (not obNeedsGap or associatedGap)
        int found = na
        for j = 1 to obSearch
            if dir == 1 ? close[j] < open[j] : close[j] > open[j]
                found := j
                break
        if not na(found)
            float top = obBounds == "Wicks" ? high[found] : math.max(open[found], close[found])
            float bot = obBounds == "Wicks" ? low[found] : math.min(open[found], close[found])
            bool clean = top > bot
            bool leftZone = false
            // Walk chronologically; departure overlap is allowed, later re-entry
            // before the break invalidates the candidate. Distal violation always fails.
            if found > 1
                for k = found - 1 to 1
                    bool distalViolation = dir == 1 ? low[k] < bot : high[k] > top
                    bool reentered = leftZone and low[k] <= top and high[k] >= bot
                    if distalViolation or reentered
                        clean := false
                    if dir == 1 ? close[k] > top : close[k] < bot
                        leftZone := true
            bool gapAfterOrigin = not obNeedsGap or (dir == 1 ? barsUpGap < found : barsDownGap < found)
            bool birthReentry = leftZone and low <= top and high >= bot
            if clean and gapAfterOrigin and not birthReentry and (dir == 1 ? close > top and low >= bot : close < bot and high <= top)
                obTop := top
                obBottom := bot
                obOrigin := time[found]
    [bias, event, broken, brokenTime, sh, sl, protectedHigh, protectedLow, ph, pl, displaced, gfUp, gfDown, obTop, obBottom, obOrigin, time, time_close, high, low, close]

f_confirmed(int n) =>
    [b, e, level, lt, sh, sl, pH, pL, ph, pl, d, gu, gd, ot, ob, origin, t, tc, h, l, c] = f_engine(n, true)
    // Every field is offset; lookahead_on cannot leak current HTF state.
    [b[1], e[1], level[1], lt[1], sh[1], sl[1], pH[1], pL[1], d[1], gu[1], gd[1], ot[1], ob[1], origin[1], t[1], tc[1], h[1], l[1], c[1], high[3], low[3], time[3]]

[bias, event, broken, brokenTime, sh, sl, protectedHigh, protectedLow, ph, pl, displaced, gapUp, gapDown, obTop, obBottom, obOrigin, chartTime, chartCloseTime, chartHigh, chartLow, chartClose] = f_engine(swingLen, barstate.isconfirmed)
[ibias, ievent, ilevel, ilevelTime, ish, isl, ipH, ipL, iph, ipl, idisp, igu, igd, iot, iob, iorigin, it, itc, ih, il, ic] = f_engine(microLen, barstate.isconfirmed)
[hbias, hevent, hlevel, hlevelTime, hsh, hsl, hpH, hpL, hdisp, hgu, hgd, hot, hob, horigin, ht, htc, hh, hl, hc, hh2, htfLowTwoBarsBack, hfOrigin] = request.security(syminfo.tickerid, htf, f_confirmed(swingLen), lookahead=barmerge.lookahead_on)
bool htfTick = htfOn and htfValid and not na(ht) and (na(ht[1]) or ht != ht[1])
var int htfClock = 0
if barstate.isconfirmed and htfTick
    htfClock += 1
var array<line> eventLines = array.new<line>()
var array<label> eventLabels = array.new<label>()
f_mark(float level, int knownAt, string labelText, color col, bool dotted) =>
    if not na(level) and not na(knownAt)
        line ln = line.new(knownAt, level, time_close, level, xloc=xloc.bar_time, color=col, style=dotted ? line.style_dotted : line.style_dashed)
        label la = label.new(time_close, level, labelText, xloc=xloc.bar_time, style=label.style_none, textcolor=col, size=size.tiny)
        array.push(eventLines, ln)
        array.push(eventLabels, la)
        if array.size(eventLines) > eventCap
            line.delete(array.shift(eventLines))
            label.delete(array.shift(eventLabels))
if barstate.isconfirmed and structureView
    if event != 0
        f_mark(broken, brokenTime, (math.abs(event) == 2 ? "CHoCH" : "BOS") + (event > 0 ? " ↑" : " ↓"), event > 0 ? bull : bear, false)
    if internalOn and ievent != 0
        f_mark(ilevel, ilevelTime, "i " + (math.abs(ievent) == 2 ? "CHoCH" : "BOS") + (ievent > 0 ? " ↑" : " ↓"), ievent > 0 ? bull : bear, true)
    if htfTick and hevent != 0
        f_mark(hlevel, hlevelTime, htf + " " + (math.abs(hevent) == 2 ? "CHoCH" : "BOS"), hevent > 0 ? bull : bear, false)

// Multiple unswept liquidity pools. EQH/EQL retain their conservative outer edge.
type Pool
    float price
    int side
    int born
    int knownAt
    int members
    line drawing
    label tag
    string source = "Swing"
var array<Pool> pools = array.new<Pool>()
f_poolDelete(Pool p) =>
    line.delete(p.drawing)
    label.delete(p.tag)
f_poolAdd(float price, int side, string source = "Swing") =>
    bool merged = false
    if array.size(pools) > 0
        for i = array.size(pools) - 1 to 0
            Pool p = array.get(pools, i)
            if not merged and p.side == side and p.source == source and math.abs(price - p.price) <= atr * eqATR
                p.price := side == 1 ? math.max(price, p.price) : math.min(price, p.price)
                p.members += 1
                p.born := bar_index
                if not na(p.drawing)
                    line.set_y1(p.drawing, p.price)
                    line.set_y2(p.drawing, p.price)
                    line.set_width(p.drawing, 2)
                    label.set_y(p.tag, p.price)
                    label.set_text(p.tag, (source == "Swing" ? (side == 1 ? "EQH ×" : "EQL ×") : source + " ×") + str.tostring(p.members))
                merged := true
    if not merged
        line ln = na
        label la = na
        if fullView and liquidityOn
            ln := line.new(time_close, price, time_close, price, xloc=xloc.bar_time, color=color.new(gold, 40), style=line.style_dotted)
            la := label.new(time_close, price, source == "Swing" ? (side == 1 ? "BSL" : "SSL") : source + (side == 1 ? " H" : " L"), xloc=xloc.bar_time, style=label.style_none, textcolor=gold, size=size.tiny)
        array.push(pools, Pool.new(price, side, bar_index, time_close, 1, ln, la, source))
        if array.size(pools) > liquidityCap
            f_poolDelete(array.shift(pools))

bool bullSweep = false
bool bearSweep = false
float bullSweepLevel = na
float bearSweepLevel = na
string bullSweepSource = ""
string bearSweepSource = ""
if barstate.isconfirmed
    if array.size(pools) > 0
        for i = array.size(pools) - 1 to 0
            Pool p = array.get(pools, i)
            if not na(p.drawing)
                line.set_x2(p.drawing, time_close)
                label.set_x(p.tag, time_close)
            bool taken = p.side == 1 ? high > p.price : low < p.price
            bool reclaim = p.side == 1 ? close < p.price : close > p.price
            if taken and reclaim
                bullSweep := bullSweep or p.side == -1
                bearSweep := bearSweep or p.side == 1
                if p.side == -1 and na(bullSweepLevel)
                    bullSweepLevel := p.price
                    bullSweepSource := p.source
                else if p.side == 1 and na(bearSweepLevel)
                    bearSweepLevel := p.price
                    bearSweepSource := p.source
                if structureView and liquidityOn
                    f_mark(p.price, p.knownAt, p.source + (p.side == 1 ? " BSL sweep" : " SSL sweep"), gold, true)
            if taken or bar_index - p.born >= liquidityAge
                f_poolDelete(p)
                array.remove(pools, i)
    // Do not seed already-taken levels. Detection begins at pivot confirmation.
    if not na(ph) and high <= ph
        f_poolAdd(ph, 1)
    if not na(pl) and low >= pl
        f_poolAdd(pl, -1)

// Explicit state machine. A sweep must precede its directional structure shift.
// A qualifying displacement may occur on the shift bar or a later bar.
type Sequence
    int stage = 0
    int swept = na
    int shifted = na
    int displacedAt = na
    int shiftedTime = na
    int sweepTime = na
    float sweepLevel = na
    string sweepSource = ""
    float shiftLevel = na
    int shiftCode = 0
    int displacementTime = na
    float displacementRatio = na
method step(Sequence s, bool sweep, bool oppositeSweep, int direction, int shiftEvent, bool displacementNow, float sweptPrice, string sweptSource, float shiftPrice, bool commit, float displacementRatioNow) =>
    if commit
        bool oppositeBreak = direction == 1 ? shiftEvent < 0 : shiftEvent > 0
        if oppositeSweep or oppositeBreak or (s.stage > 0 and bar_index - s.swept > sequenceTTL)
            s.stage := 0
            s.swept := na
            s.shifted := na
            s.displacedAt := na
            s.shiftedTime := na
            s.sweepTime := na
            s.sweepLevel := na
            s.sweepSource := ""
            s.shiftLevel := na
            s.shiftCode := 0
            s.displacementTime := na
            s.displacementRatio := na
        if sweep and not oppositeSweep
            s.stage := 1
            s.swept := bar_index
            s.sweepTime := time_close
            s.sweepLevel := sweptPrice
            s.sweepSource := sweptSource
            s.shiftLevel := na
            s.shiftCode := 0
            s.displacementTime := na
            s.displacementRatio := na
            s.shifted := na
            s.displacedAt := na
            s.shiftedTime := na
        if s.stage == 1 and bar_index > s.swept and (shiftKind != "CHoCH only" or math.abs(shiftEvent) == 2) and (direction == 1 ? shiftEvent > 0 : shiftEvent < 0)
            s.stage := 2
            s.shifted := bar_index
            s.shiftedTime := time_close
            s.shiftLevel := shiftPrice
            s.shiftCode := shiftEvent
        if s.stage == 2 and displacementNow and bar_index >= s.shifted
            s.stage := 3
            s.displacedAt := bar_index
            s.displacementTime := time_close
            s.displacementRatio := displacementRatioNow
    s.stage
var Sequence longSeq = Sequence.new()
var Sequence shortSeq = Sequence.new()
int shiftEvent = shiftSource == "Internal" ? ievent : event
float shiftPrice = shiftSource == "Internal" ? ilevel : broken
// Evaluate both methods on every calculation; mutate only on confirmed closes.
// Historical ATR reference is evaluated globally, outside conditional method scope.
float displacementRatioNow = math.abs(close - open) / math.max(atr[1], syminfo.mintick)
longSeq.step(bullSweep, bearSweep, 1, shiftEvent, displaced and close > open, bullSweepLevel, bullSweepSource, shiftPrice, barstate.isconfirmed, displacementRatioNow)
shortSeq.step(bearSweep, bullSweep, -1, shiftEvent, displaced and close < open, bearSweepLevel, bearSweepSource, shiftPrice, barstate.isconfirmed, displacementRatioNow)

// Zone states: 0 fresh, 1 touched, 2 partially filled; terminal states are text.
// First/multiple retest counts DISTINCT overlap encounters, not every touching bar.
type Zone
    float top
    float bottom
    int direction
    string kind
    string tf
    bool higher
    int born
    int clockBorn
    int detectedTime
    int origin
    int state = 0
    float fillFraction = 0
    int attempts = 0
    bool inEncounter = false
    bool signaled = false
    box drawing = na
    line midpoint = na
var array<Zone> zones = array.new<Zone>()
var array<Zone> archived = array.new<Zone>()
f_zoneText(Zone z, string state) =>
    z.tf + " " + z.kind + (z.direction == 1 ? " +" : " −") + " | " + state + " | " + str.tostring(z.fillFraction * 100, "#") + "% | detect " + str.format_time(z.detectedTime, "MM-dd HH:mm", syminfo.timezone)
f_zoneDelete(Zone z) =>
    box.delete(z.drawing)
    line.delete(z.midpoint)
f_finish(Zone z, string reason) =>
    if zoneView == "Active + historical" and archiveCap > 0 and zoneVisible
        box.set_right(z.drawing, time_close)
        box.set_bgcolor(z.drawing, color.new(color.gray, 95))
        box.set_border_color(z.drawing, color.new(color.gray, 75))
        box.set_text(z.drawing, zoneLabels ? f_zoneText(z, reason) : "")
        box.set_text_color(z.drawing, color.new(color.gray, 20))
        if not na(z.midpoint)
            line.set_color(z.midpoint, color.new(color.gray, 80))
        array.push(archived, z)
        if array.size(archived) > archiveCap
            f_zoneDelete(array.shift(archived))
    else
        f_zoneDelete(z)
f_addZone(float top, float bottom, int dir, string kind, int origin, bool higher, int detectedTime) =>
    bool added = false
    bool duplicate = false
    if array.size(zones) > 0
        for existing in zones
            if existing.origin == origin and existing.kind == kind and existing.direction == dir and existing.higher == higher
                duplicate := true
    if not duplicate and not na(top) and not na(bottom) and top > bottom and not na(origin)
        Zone z = Zone.new(top, bottom, dir, kind, higher ? htf : timeframe.period, higher, bar_index, htfClock, detectedTime, origin)
        if zoneVisible
            color col = dir == 1 ? bull : bear
            z.drawing := box.new(origin, top, time_close, bottom, xloc=xloc.bar_time, border_color=color.new(col, higher ? 10 : 50), border_width=higher ? 2 : 1, bgcolor=color.new(col, kind == "OB" ? 87 : 93), text=zoneLabels ? f_zoneText(z, "fresh") : "", text_color=col, text_size=size.tiny, text_halign=text.align_right)
            if midlinesOn
                z.midpoint := line.new(origin, (top + bottom) / 2, time_close, (top + bottom) / 2, xloc=xloc.bar_time, color=color.new(col, 60), style=line.style_dotted)
        array.push(zones, z)
        added := true
        if dynamicAlerts and zoneEventAlerts
            alert("[CandleChasers] NEW " + (dir == 1 ? "BULLISH " : "BEARISH ") + z.kind + " | " + syminfo.tickerid + " | source " + z.tf + " | top " + str.tostring(top, format.mintick) + " | bottom " + str.tostring(bottom, format.mintick), alert.freq_all)
        if array.size(zones) > activeCap
            f_finish(array.shift(zones), "capacity retired")
    added

bool validRange = not na(sh) and not na(sl) and sh > sl
float eq = validRange ? (sh + sl) / 2 : na
f_inSession(string hours, string timezone) =>
    string days = sessionDays == "Weekdays" ? "23456" : "1234567"
    string sessionSpec = hours + ":" + days
    int sessionOpen = time(timeframe.period, sessionSpec, timezone)
    int sessionClose = time_close(timeframe.period, sessionSpec, timezone)
    bool openingInside = timeframe.isintraday and not na(sessionOpen)
    openingInside and (sessionMembership == "Bar opens inside" or (not na(sessionClose) and not na(time_close) and time >= sessionOpen and time_close <= sessionClose))
bool sydneyActive = f_inSession(sydneyHours, sydneyTZ)
bool tokyoActive = f_inSession(asiaWindow, asiaClock)
bool frankfurtActive = f_inSession(frankfurtHours, frankfurtTZ)
bool londonActive = f_inSession(londonWindow, londonClock)
bool newYorkActive = f_inSession(newYorkHours, newYorkTZ)
bool nyAMActive = f_inSession(amWindow, amClock)
bool nyPMActive = f_inSession(pmWindow, pmClock)
bool customActive = f_inSession(customHours, customTZ)
bool anySelectedSession = sydneyEnabled or tokyoOn or frankfurtEnabled or londonOn or newYorkEnabled or nyAMOn or nyPMOn or customSessionOn
bool allowedSession = (sydneyEnabled and sydneyActive) or (tokyoOn and tokyoActive) or (frankfurtEnabled and frankfurtActive) or (londonOn and londonActive) or (newYorkEnabled and newYorkActive) or (nyAMOn and nyAMActive) or (nyPMOn and nyPMActive) or (customSessionOn and customActive)
bool inSession = not sessionOn or allowedSession
string activeSessionNames = ""
if sydneyEnabled and sydneyActive
    activeSessionNames += "Sydney "
if tokyoOn and tokyoActive
    activeSessionNames += killZones ? "Asia-KZ " : "Tokyo "
if frankfurtEnabled and frankfurtActive
    activeSessionNames += "Frankfurt "
if londonOn and londonActive
    activeSessionNames += killZones ? "London-KZ " : "London "
if newYorkEnabled and newYorkActive
    activeSessionNames += "NY "
if nyAMOn and nyAMActive
    activeSessionNames += "NY-AM "
if nyPMOn and nyPMActive
    activeSessionNames += "NY-PM "
if customSessionOn and customActive
    activeSessionNames += "Custom "
if barstate.isfirst and sessionOn and not anySelectedSession
    runtime.error("No session is selected for this clock mode. Enable an active window in group 08; Sydney/Frankfurt/NY Full are inactive in kill-zone mode.")
if barstate.isfirst and sessionOn and not timeframe.isintraday
    runtime.error("Session filtering requires an intraday time-based chart. Disable the filter for daily/weekly charts.")

// SESSION RANGES: track observed, fully contained chart candles on confirmed closes.
// Start identity is computed in the session's local clock, including overnight/DST.
f_sessionStart(string hours, string timezone) =>
    int startHour = int(str.tonumber(str.substring(hours, 0, 2)))
    int startMinute = int(str.tonumber(str.substring(hours, 2, 4)))
    int todayStart = timestamp(timezone, year(time, timezone), month(time, timezone), dayofmonth(time, timezone), startHour, startMinute)
    int localNoon = timestamp(timezone, year(time, timezone), month(time, timezone), dayofmonth(time, timezone), 12, 0)
    int priorNoon = localNoon - 86400000
    time >= todayStart ? todayStart : timestamp(timezone, year(priorNoon, timezone), month(priorNoon, timezone), dayofmonth(priorNoon, timezone), startHour, startMinute)
f_sessionEnd(string hours, string timezone, int cycle) =>
    int endHour = int(str.tonumber(str.substring(hours, 5, 7)))
    int endMinute = int(str.tonumber(str.substring(hours, 7, 9)))
    int sameDayEnd = timestamp(timezone, year(cycle, timezone), month(cycle, timezone), dayofmonth(cycle, timezone), endHour, endMinute)
    int localNoon = timestamp(timezone, year(cycle, timezone), month(cycle, timezone), dayofmonth(cycle, timezone), 12, 0)
    int nextNoon = localNoon + 86400000
    sameDayEnd > cycle ? sameDayEnd : timestamp(timezone, year(nextNoon, timezone), month(nextNoon, timezone), dayofmonth(nextNoon, timezone), endHour, endMinute)
type SessionRange
    string name = ""
    int cycle = na
    int start = na
    int lastTime = na
    float hi = na
    float lo = na
    float orHi = na
    float orLo = na
    bool orReady = false
    bool orPartial = false
    bool partial = false
    line highLine = na
    line lowLine = na
    line orHighLine = na
    line orLowLine = na
    label tag = na
    color col = na
type SessionTracker
    SessionRange current = na
var array<SessionRange> rangeArchive = array.new<SessionRange>()
f_rangeDelete(SessionRange r) =>
    line.delete(r.highLine)
    line.delete(r.lowLine)
    line.delete(r.orHighLine)
    line.delete(r.orLowLine)
    label.delete(r.tag)
f_rangeLabel(SessionRange r, bool completed) =>
    r.name + (completed ? " completed" : " developing") + (r.partial ? " / partial data" : "") + "\nH " + str.tostring(r.hi, format.mintick) + " | L " + str.tostring(r.lo, format.mintick) + (openingRangeOn ? "\nOR " + (not r.orReady ? "developing" : na(r.orHi) ? "unavailable" : (r.orPartial ? "partial " : "") + str.tostring(r.orHi, format.mintick) + " / " + str.tostring(r.orLo, format.mintick)) : "")
f_rangeFreeze(SessionRange r) =>
    if not r.orReady
        r.orReady := true
        r.orPartial := true
        r.orHi := na
        r.orLo := na
    int ending = r.lastTime + rangeExtension * 60000
    if not na(r.highLine)
        line.set_x2(r.highLine, ending)
        line.set_x2(r.lowLine, ending)
        line.set_style(r.highLine, line.style_dashed)
        line.set_style(r.lowLine, line.style_dashed)
        label.set_x(r.tag, ending)
        label.set_text(r.tag, f_rangeLabel(r, true))
    if not na(r.orHighLine)
        line.set_x2(r.orHighLine, ending)
        line.set_x2(r.orLowLine, ending)
    // Session levels become available to sweep detection on the following bar.
    // Skip levels already breached by the confirmation bar.
    if sessionLiquidity
        if high <= r.hi
            f_poolAdd(r.hi, 1, r.name)
        if low >= r.lo
            f_poolAdd(r.lo, -1, r.name)
    if dynamicAlerts and rangeAlerts
        alert("[CandleChasers] SESSION COMPLETE | " + syminfo.tickerid + " | " + r.name + " | high " + str.tostring(r.hi, format.mintick) + " | low " + str.tostring(r.lo, format.mintick) + (r.partial ? " | partial observed range" : ""), alert.freq_all)
    if rangeHistoryCap > 0 and not na(r.highLine)
        array.push(rangeArchive, r)
        if array.size(rangeArchive) > rangeHistoryCap
            f_rangeDelete(array.shift(rangeArchive))
    else
        f_rangeDelete(r)
method track(SessionTracker tracker, bool enabled, bool active, string hours, string timezone, string sessionName, color col) =>
    string days = sessionDays == "Weekdays" ? "23456" : "1234567"
    int nativeOpen = time(timeframe.period, hours + ":" + days, timezone)
    int nativeClose = time_close(timeframe.period, hours + ":" + days, timezone)
    bool contained = not na(nativeOpen) and not na(nativeClose) and not na(time_close) and time >= nativeOpen and time_close <= nativeClose
    bool includeBar = enabled and active and contained and timeframe.isintraday
    int cycle = f_sessionStart(hours, timezone)
    if not na(tracker.current) and (not includeBar or tracker.current.cycle != cycle)
        if active and not contained
            tracker.current.partial := true
        f_rangeFreeze(tracker.current)
        tracker.current := na
    if includeBar
        if na(tracker.current)
            SessionRange fresh = SessionRange.new()
            fresh.name := sessionName
            fresh.cycle := cycle
            fresh.start := time
            fresh.lastTime := time_close
            fresh.hi := high
            fresh.lo := low
            fresh.partial := time > cycle
            fresh.orPartial := time > cycle
            fresh.col := col
            tracker.current := fresh
            if fullView and rangesOn
                fresh.highLine := line.new(time, high, time_close, high, xloc=xloc.bar_time, color=color.new(col, 25))
                fresh.lowLine := line.new(time, low, time_close, low, xloc=xloc.bar_time, color=color.new(col, 25))
                fresh.tag := label.new(time_close, high, "", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, 92), textcolor=col, size=size.tiny)
        SessionRange r = tracker.current
        if time > r.lastTime
            r.partial := true
            if not r.orReady
                r.orPartial := true
        r.lastTime := time_close
        r.hi := math.max(r.hi, high)
        r.lo := math.min(r.lo, low)
        int orEnd = r.cycle + openingMinutes * 60000
        bool insideOR = time >= r.cycle and time_close <= orEnd
        if not r.orReady and insideOR
            r.orHi := na(r.orHi) ? high : math.max(r.orHi, high)
            r.orLo := na(r.orLo) ? low : math.min(r.orLo, low)
        if not r.orReady and time < orEnd and time_close > orEnd
            r.orPartial := true
        if not r.orReady and time_close >= orEnd
            r.orReady := true
            if fullView and rangesOn and openingRangeOn and not na(r.orHi)
                // Opening range levels are first drawn at confirmation, never backdated.
                r.orHighLine := line.new(time_close, r.orHi, time_close, r.orHi, xloc=xloc.bar_time, color=col, width=2, style=line.style_dotted)
                r.orLowLine := line.new(time_close, r.orLo, time_close, r.orLo, xloc=xloc.bar_time, color=col, width=2, style=line.style_dotted)
            if dynamicAlerts and rangeAlerts and not na(r.orHi)
                alert("[CandleChasers] OPENING RANGE COMPLETE | " + syminfo.tickerid + " | " + r.name + " | OR high " + str.tostring(r.orHi, format.mintick) + " | OR low " + str.tostring(r.orLo, format.mintick) + (r.orPartial ? " | partial observed OR" : ""), alert.freq_all)
        if not na(r.highLine)
            line.set_y1(r.highLine, r.hi)
            line.set_y2(r.highLine, r.hi)
            line.set_y1(r.lowLine, r.lo)
            line.set_y2(r.lowLine, r.lo)
            line.set_x2(r.highLine, time_close)
            line.set_x2(r.lowLine, time_close)
            label.set_xy(r.tag, time_close, r.hi)
            label.set_text(r.tag, f_rangeLabel(r, false))
        if not na(r.orHighLine)
            line.set_x2(r.orHighLine, time_close)
            line.set_x2(r.orLowLine, time_close)
        if time_close >= f_sessionEnd(hours, timezone, r.cycle)
            f_rangeFreeze(r)
            tracker.current := na
    0
var SessionTracker sydneyRange = SessionTracker.new()
var SessionTracker tokyoRange = SessionTracker.new()
var SessionTracker frankfurtRange = SessionTracker.new()
var SessionTracker londonRange = SessionTracker.new()
var SessionTracker nyRange = SessionTracker.new()
var SessionTracker amRange = SessionTracker.new()
var SessionTracker pmRange = SessionTracker.new()
var SessionTracker customRange = SessionTracker.new()
bool needRanges = rangesOn or sessionLiquidity
if barstate.isconfirmed
    sydneyRange.track(needRanges and sydneyEnabled, sydneyActive, sydneyHours, sydneyTZ, "Sydney", #AD83ED)
    tokyoRange.track(needRanges and tokyoOn, tokyoActive, asiaWindow, asiaClock, killZones ? "Asia KZ" : "Tokyo", #6C9FE8)
    frankfurtRange.track(needRanges and frankfurtEnabled, frankfurtActive, frankfurtHours, frankfurtTZ, "Frankfurt", #78B7BB)
    londonRange.track(needRanges and londonOn, londonActive, londonWindow, londonClock, killZones ? "London KZ" : "London", bull)
    nyRange.track(needRanges and newYorkEnabled, newYorkActive, newYorkHours, newYorkTZ, "NY Full", #EA9A5C)
    amRange.track(needRanges and nyAMOn, nyAMActive, amWindow, amClock, "NY AM", #EA9A5C)
    pmRange.track(needRanges and nyPMOn, nyPMActive, pmWindow, pmClock, "NY PM", bear)
    customRange.track(needRanges and customSessionOn, customActive, customHours, customTZ, "Custom", gold)

bool longPD = not pdGate or (validRange and close <= eq and close >= sl)
bool shortPD = not pdGate or (validRange and close >= eq and close <= sh)
bool longHTF = not htfGate or (htfOn and hbias == 1)
bool shortHTF = not htfGate or (htfOn and hbias == -1)
var int lastSetup = na
bool cooldownOK = na(lastSetup) or bar_index - lastSetup > setupCooldown
bool longSetup = false
bool shortSetup = false
float setupStop = na
float setupEntry = na
string setupZone = ""
float setupTop = na
float setupBottom = na
bool sawLongRejection = false
bool sawShortRejection = false

// Zone touches/fills use confirmed chart candles, including HTF-origin zones.
// HTF OB close-invalidation requires a completed HTF candle. Wick invalidation
// and mitigation use confirmed chart wicks so exhausted zones cannot keep signaling.
if barstate.isconfirmed and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)
        bool canUpdate = not z.higher or (htfTick and ht >= z.detectedTime)
        float lifeLow = low
        float lifeHigh = high
        float lifeClose = z.higher ? hc : close
        bool closeInvalid = canUpdate and (z.direction == 1 ? lifeClose < z.bottom : lifeClose > z.top)
        bool wickInvalid = z.direction == 1 ? lifeLow < z.bottom : lifeHigh > z.top
        bool invalid = z.kind == "OB" and (invalidation == "Close" ? closeInvalid : wickInvalid)
        bool overlap = low <= z.top and high >= z.bottom
        bool updateOverlap = overlap
        bool expired = z.higher ? htfClock - z.clockBorn >= htfAgeLimit : bar_index - z.born >= ageLimit
        if overlap and not z.inEncounter
            z.attempts += 1
            z.inEncounter := true
            z.signaled := false
        if not overlap
            z.inEncounter := false
        int attemptLimit = retestMode == "First only" ? 1 : maxAttempts
        bool rejected = z.direction == 1 ? close > z.top and close > open : close < z.bottom and close < open
        // Prevent retests from invalid or expired zones, including intrabar distal
        // wick violations of an HTF zone regardless of lifecycle update timing.
        bool safePrice = z.direction == 1 ? low >= z.bottom : high <= z.top
        bool candidate = overlap and rejected and safePrice and not invalid and not expired and not z.signaled and z.attempts <= attemptLimit and bar_index > z.born
        sawLongRejection := sawLongRejection or (candidate and z.direction == 1)
        sawShortRejection := sawShortRejection or (candidate and z.direction == -1)
        bool seqLongOK = not sequenceOn or (longSeq.stage == 3 and z.detectedTime >= longSeq.shiftedTime and bar_index > longSeq.displacedAt)
        bool seqShortOK = not sequenceOn or (shortSeq.stage == 3 and z.detectedTime >= shortSeq.shiftedTime and bar_index > shortSeq.displacedAt)
        bool qualifyLong = candidate and z.direction == 1 and bias == 1 and seqLongOK and longPD and longHTF
        bool qualifyShort = candidate and z.direction == -1 and bias == -1 and seqShortOK and shortPD and shortHTF
        if setupsOn and inSession and cooldownOK and not longSetup and not shortSetup and (qualifyLong or qualifyShort)
            longSetup := qualifyLong
            shortSetup := qualifyShort
            setupEntry := close
            setupStop := qualifyLong ? math.floor((z.bottom - atr * stopATR) / syminfo.mintick) * syminfo.mintick : math.ceil((z.top + atr * stopATR) / syminfo.mintick) * syminfo.mintick
            setupTop := z.top
            setupBottom := z.bottom
            setupZone := z.tf + " " + z.kind + " encounter " + str.tostring(z.attempts)
            z.signaled := true
        if updateOverlap
            float penetration = z.direction == 1 ? (z.top - lifeLow) / (z.top - z.bottom) : (lifeHigh - z.bottom) / (z.top - z.bottom)
            z.fillFraction := math.max(z.fillFraction, math.max(0, math.min(1, penetration)))
            z.state := z.fillFraction > 0 ? 2 : 1
        if not na(z.drawing)
            box.set_right(z.drawing, time_close)
            box.set_text(z.drawing, zoneLabels ? f_zoneText(z, z.state == 0 ? "fresh" : z.state == 1 ? "touched" : "partial") : "")
            box.set_border_style(z.drawing, z.state == 0 ? line.style_solid : line.style_dashed)
            if not na(z.midpoint)
                line.set_x2(z.midpoint, time_close)
        bool retired = (retireAt == "First touch" ? updateOverlap : retireAt == "Midpoint" ? z.fillFraction >= 0.5 : z.fillFraction >= 1)
        if invalid or expired or retired
            f_finish(z, invalid ? "invalidated" : expired ? "expired" : "mitigated")
            array.remove(zones, i)

bool newBullOB = false
bool newBearOB = false
bool newBullFVG = false
bool newBearFVG = false
if barstate.isconfirmed
    if obOn and not na(obTop)
        bool addedOB = f_addZone(obTop, obBottom, event > 0 ? 1 : -1, "OB", obOrigin, false, time_close)
        newBullOB := addedOB and event > 0
        newBearOB := addedOB and event < 0
    if fvgOn and gapUp
        newBullFVG := f_addZone(low, high[2], 1, "FVG", time[2], false, time_close)
    if fvgOn and gapDown
        newBearFVG := f_addZone(low[2], high, -1, "FVG", time[2], false, time_close)
    if htfTick and htfZones
        if obOn and not na(hot)
            bool addedHTFOB = f_addZone(hot, hob, hevent > 0 ? 1 : -1, "OB", horigin, true, htc)
            newBullOB := newBullOB or (addedHTFOB and hevent > 0)
            newBearOB := newBearOB or (addedHTFOB and hevent < 0)
        if fvgOn and hgu
            bool addedHTFUp = f_addZone(hl, hh2, 1, "FVG", hfOrigin, true, htc)
            newBullFVG := newBullFVG or addedHTFUp
        if fvgOn and hgd
            bool addedHTFDown = f_addZone(htfLowTwoBarsBack, hh, -1, "FVG", hfOrigin, true, htc)
            newBearFVG := newBearFVG or addedHTFDown

var array<line> planLines = array.new<line>()
var array<label> planLabels = array.new<label>()
f_plan(float price, string labelText, color col) =>
    line ln = line.new(bar_index, price, bar_index + projectionBars, price, color=col, style=labelText == "Entry" ? line.style_solid : line.style_dashed)
    label la = label.new(bar_index + projectionBars, price, labelText + " " + str.tostring(price, format.mintick), style=label.style_label_left, color=color.new(col, 80), textcolor=col, size=size.tiny)
    array.push(planLines, ln)
    array.push(planLabels, la)
var string latestDirection = "Waiting for setup"
var string latestTimeNote = "—"
var string latestSweepNote = "—"
var string latestShiftNote = "—"
var string latestDisplacementNote = "—"
var string latestZoneNote = "—"
var string latestFilterNote = "—"
var string latestSessionNote = "—"
var float latestEntry = na
var float latestStop = na
var float latestT1 = na
var float latestT2 = na
var float latestT3 = na
var label explanationLabel = na
f_eventTime(int timestampValue) =>
    na(timestampValue) ? "—" : str.format_time(timestampValue, "MM-dd HH:mm", syminfo.timezone)

float setupRisk = math.abs(setupEntry - setupStop)
float target1 = longSetup ? math.round_to_mintick(setupEntry + setupRisk * r1) : shortSetup ? math.round_to_mintick(setupEntry - setupRisk * r1) : na
float target2 = longSetup ? math.round_to_mintick(setupEntry + setupRisk * r2) : shortSetup ? math.round_to_mintick(setupEntry - setupRisk * r2) : na
float target3 = longSetup ? math.round_to_mintick(setupEntry + setupRisk * r3) : shortSetup ? math.round_to_mintick(setupEntry - setupRisk * r3) : na
if longSetup or shortSetup
    Sequence provenance = longSetup ? longSeq : shortSeq
    latestDirection := longSetup ? "LONG" : "SHORT"
    latestTimeNote := f_eventTime(time_close) + " | " + syminfo.timezone
    latestSweepNote := sequenceOn ? provenance.sweepSource + " @ " + str.tostring(provenance.sweepLevel, format.mintick) + " | " + f_eventTime(provenance.sweepTime) : "Sequence disabled"
    latestShiftNote := sequenceOn ? shiftSource + " " + (math.abs(provenance.shiftCode) == 2 ? "CHoCH" : "BOS") + " @ " + str.tostring(provenance.shiftLevel, format.mintick) + " | " + f_eventTime(provenance.shiftedTime) : "Sequence disabled"
    latestDisplacementNote := sequenceOn ? str.tostring(provenance.displacementRatio, "#.##") + " × prior ATR | " + f_eventTime(provenance.displacementTime) : "Sequence disabled"
    latestZoneNote := setupZone + " | " + str.tostring(setupBottom, format.mintick) + "–" + str.tostring(setupTop, format.mintick)
    latestFilterNote := "Swing " + (longSetup ? "Bull" : "Bear") + " | PD " + (pdGate ? "pass" : "off") + " | HTF " + (htfGate ? "pass" : "off") + " | cooldown pass"
    latestSessionNote := clockMode + " | " + (activeSessionNames == "" ? "Outside selected windows" : activeSessionNames) + (sessionOn ? " | filter pass" : " | filter off")
    latestEntry := setupEntry
    latestStop := setupStop
    latestT1 := target1
    latestT2 := target2
    latestT3 := target3
    label.delete(explanationLabel)
    if explainLabels
        string details = latestDirection + " | " + latestTimeNote + "\nSweep: " + latestSweepNote + "\nShift: " + latestShiftNote + "\nDisplacement: " + latestDisplacementNote + "\nZone: " + latestZoneNote + "\nFilters: " + latestFilterNote + "\nSessions: " + latestSessionNote
        explanationLabel := label.new(time_close, setupEntry, "CC " + latestDirection + " · details", xloc=xloc.bar_time, style=longSetup ? label.style_label_up : label.style_label_down, color=color.new(longSetup ? bull : bear, 85), textcolor=longSetup ? bull : bear, size=size.tiny, tooltip=details)
    lastSetup := bar_index
    if sequenceOn
        if longSetup
            longSeq.stage := 0
        else
            shortSeq.stage := 0
    if array.size(planLines) > 0
        for ln in planLines
            line.delete(ln)
        for la in planLabels
            label.delete(la)
        array.clear(planLines)
        array.clear(planLabels)
    if projectOn
        f_plan(setupEntry, "Entry", gold)
        f_plan(setupStop, "Stop", bear)
        f_plan(target1, "T1 " + str.tostring(r1) + "R", bull)
        f_plan(target2, "T2 " + str.tostring(r2) + "R", bull)
        f_plan(target3, "T3 " + str.tostring(r3) + "R", bull)
    if dynamicAlerts
        alert("[CandleChasers] " + (longSetup ? "LONG" : "SHORT") + " | " + syminfo.tickerid + " | chart " + timeframe.period + " | " + setupZone + " | sweep " + latestSweepNote + " | shift " + latestShiftNote + " | displacement " + latestDisplacementNote + " | sessions " + (activeSessionNames == "" ? "outside selected windows" : activeSessionNames) + " | entry " + str.tostring(setupEntry, format.mintick) + " | stop " + str.tostring(setupStop, format.mintick) + " | T1 " + str.tostring(target1, format.mintick) + " | T2 " + str.tostring(target2, format.mintick) + " | T3 " + str.tostring(target3, format.mintick), alert.freq_all)

pHigh = plot(fullView and validRange ? sh : na, "Range high", color=color.new(bear, 75), style=plot.style_stepline)
pEQ = plot(fullView ? eq : na, "Equilibrium", color=color.new(gold, 40), style=plot.style_stepline)
pLow = plot(fullView and validRange ? sl : na, "Range low", color=color.new(bull, 75), style=plot.style_stepline)
fill(pHigh, pEQ, color=color.new(bear, 96), title="Premium")
fill(pEQ, pLow, color=color.new(bull, 96), title="Discount")
plot(structureView ? protectedHigh : na, "Protected high", color=bear, style=plot.style_linebr, linewidth=2)
plot(structureView ? protectedLow : na, "Protected low", color=bull, style=plot.style_linebr, linewidth=2)
[pdh, pdl] = request.security(syminfo.tickerid, "1D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
plot(fullView and dayOn and timeframe.isintraday ? pdh : na, "Previous day high", color=color.new(gold, 45), style=plot.style_stepline)
plot(fullView and dayOn and timeframe.isintraday ? pdl : na, "Previous day low", color=color.new(gold, 45), style=plot.style_stepline)
plotshape(bullSweep and liquidityOn and structureView, title="Sell-side sweep", style=shape.triangleup, location=location.belowbar, color=gold, size=size.tiny, text="SSL", textcolor=gold)
plotshape(bearSweep and liquidityOn and structureView, title="Buy-side sweep", style=shape.triangledown, location=location.abovebar, color=gold, size=size.tiny, text="BSL", textcolor=gold)
plotshape(longSetup, title="Qualified long", style=shape.labelup, location=location.belowbar, color=bull, text="CC ↑", textcolor=color.white, size=size.tiny)
plotshape(shortSetup, title="Qualified short", style=shape.labeldown, location=location.abovebar, color=bear, text="CC ↓", textcolor=color.white, size=size.tiny)
barcolor(candleTint ? (bias == 1 ? bull : bias == -1 ? bear : na) : na)

f_bias(int b) =>
    b == 1 ? "Bull" : b == -1 ? "Bear" : "Neutral"
f_stage(int stage) =>
    stage == 0 ? "Waiting sweep" : stage == 1 ? "Waiting shift" : stage == 2 ? "Waiting displacement" : "Waiting retest"
f_check(bool condition) =>
    condition ? "PASS" : "WAIT"
var table panel = table.new(position.top_right, 3, 12, bgcolor=color.new(#101820, 6), border_width=1, border_color=color.new(gold, 65))
var int confirmedBias = 0
var int confirmedInternal = 0
var bool confirmedLongRejection = false
var bool confirmedShortRejection = false
if barstate.isconfirmed
    confirmedBias := bias
    confirmedInternal := ibias
    confirmedLongRejection := sawLongRejection
    confirmedShortRejection := sawShortRejection
if barstate.islast and panelOn
    table.cell(panel, 0, 0, "CANDLECHASERS", text_color=gold, text_size=size.small)
    table.cell(panel, 1, 0, "LONG", text_color=bull)
    table.cell(panel, 2, 0, "SHORT", text_color=bear)
    table.cell(panel, 0, 1, "Swing / internal", text_color=color.silver)
    table.cell(panel, 1, 1, f_bias(confirmedBias), text_color=gold)
    table.cell(panel, 2, 1, f_bias(confirmedInternal), text_color=gold)
    table.cell(panel, 0, 2, "HTF " + htf, text_color=color.silver)
    table.cell(panel, 1, 2, htfOn ? f_bias(hbias) : "Off", text_color=gold)
    table.cell(panel, 2, 2, "Confirmed", text_color=color.silver)
    table.cell(panel, 0, 3, "Sequence", text_color=color.silver)
    table.cell(panel, 1, 3, sequenceOn ? f_stage(longSeq.stage) : "Off", text_color=bull, text_size=size.tiny)
    table.cell(panel, 2, 3, sequenceOn ? f_stage(shortSeq.stage) : "Off", text_color=bear, text_size=size.tiny)
    table.cell(panel, 0, 4, "Swing direction", text_color=color.silver)
    table.cell(panel, 1, 4, f_check(confirmedBias == 1), text_color=bull)
    table.cell(panel, 2, 4, f_check(confirmedBias == -1), text_color=bear)
    table.cell(panel, 0, 5, "Range filter*", text_color=color.silver)
    table.cell(panel, 1, 5, f_check(longPD), text_color=bull)
    table.cell(panel, 2, 5, f_check(shortPD), text_color=bear)
    table.cell(panel, 0, 6, "HTF filter", text_color=color.silver)
    table.cell(panel, 1, 6, f_check(longHTF), text_color=bull)
    table.cell(panel, 2, 6, f_check(shortHTF), text_color=bear)
    table.cell(panel, 0, 7, "Rejection this close", text_color=color.silver)
    table.cell(panel, 1, 7, f_check(confirmedLongRejection), text_color=bull)
    table.cell(panel, 2, 7, f_check(confirmedShortRejection), text_color=bear)
    table.cell(panel, 0, 8, "Session / cooldown*", text_color=color.silver)
    table.cell(panel, 1, 8, f_check(inSession), text_color=gold)
    table.cell(panel, 2, 8, f_check(cooldownOK), text_color=gold)
    table.cell(panel, 0, 9, "Zones / pools", text_color=color.silver)
    table.cell(panel, 1, 9, str.tostring(array.size(zones)), text_color=color.white)
    table.cell(panel, 2, 9, str.tostring(array.size(pools)), text_color=color.white)
    table.cell(panel, 0, 10, "*Live context", text_color=color.silver, text_size=size.tiny)
    table.cell(panel, 1, 10, "Signals at close", text_color=color.white, text_size=size.tiny)
    table.cell(panel, 2, 10, "v3.0", text_color=gold, text_size=size.tiny)
    table.cell(panel, 0, 11, "Selected sessions", text_color=color.silver, text_size=size.tiny)
    table.cell(panel, 1, 11, activeSessionNames == "" ? "None active" : activeSessionNames, text_color=gold, text_size=size.tiny)
    table.cell(panel, 2, 11, sessionOn ? "Filter ON" : "Filter OFF", text_color=color.silver, text_size=size.tiny)

// Session shading is a live calendar annotation; it does not create signals.
int activeWindowCount = (sydneyEnabled and sydneyActive ? 1 : 0) + (tokyoOn and tokyoActive ? 1 : 0) + (frankfurtEnabled and frankfurtActive ? 1 : 0) + (londonOn and londonActive ? 1 : 0) + (newYorkEnabled and newYorkActive ? 1 : 0) + (nyAMOn and nyAMActive ? 1 : 0) + (nyPMOn and nyPMActive ? 1 : 0) + (customSessionOn and customActive ? 1 : 0)
color sessionColor = activeWindowCount > 1 ? gold : sydneyEnabled and sydneyActive ? #AD83ED : tokyoOn and tokyoActive ? #6C9FE8 : frankfurtEnabled and frankfurtActive ? #78B7BB : londonOn and londonActive ? bull : newYorkEnabled and newYorkActive ? #EA9A5C : nyAMOn and nyAMActive ? #EA9A5C : nyPMOn and nyPMActive ? bear : gold
bgcolor(sessionShade and fullView and allowedSession ? color.new(sessionColor, 94) : na, title="Selected session shading")
var table sessionsPanel = table.new(position.bottom_right, 3, 9, bgcolor=color.new(#101820, 6), border_width=1, border_color=color.new(gold, 65))
f_sessionRow(int row, string name, string timezone, bool selected, bool active) =>
    table.cell(sessionsPanel, 0, row, name + (selected ? " ✓" : ""), text_color=gold, text_size=size.tiny)
    table.cell(sessionsPanel, 1, row, (not timeframe.isintraday ? "Intraday only" : active ? "ACTIVE" : "Closed") + " | " + str.format_time(time, "HH:mm", timezone), text_color=active ? bull : color.silver, text_size=size.tiny)
    table.cell(sessionsPanel, 2, row, timezone, text_color=color.silver, text_size=size.tiny)
if barstate.islast and sessionPanelOn
    table.cell(sessionsPanel, 0, 0, "CANDLECHASERS", text_color=gold, text_size=size.tiny)
    table.cell(sessionsPanel, 1, 0, "Bar open / local time", text_color=color.white, text_size=size.tiny)
    table.cell(sessionsPanel, 2, 0, "IANA timezone", text_color=color.white, text_size=size.tiny)
    f_sessionRow(1, "Sydney", sydneyTZ, sydneyEnabled, sydneyActive)
    f_sessionRow(2, killZones ? "Asia KZ" : "Asia / Tokyo", asiaClock, tokyoOn, tokyoActive)
    f_sessionRow(3, "Frankfurt", frankfurtTZ, frankfurtEnabled, frankfurtActive)
    f_sessionRow(4, killZones ? "London KZ" : "London", londonClock, londonOn, londonActive)
    f_sessionRow(5, "New York full", newYorkTZ, newYorkEnabled, newYorkActive)
    f_sessionRow(6, "New York AM", amClock, nyAMOn, nyAMActive)
    f_sessionRow(7, "New York PM", pmClock, nyPMOn, nyPMActive)
    f_sessionRow(8, "Custom", customTZ, customSessionOn, customActive)


// A snapshot of the most recent qualified setup; never a probability score.
var table explainPanel = table.new(position.bottom_left, 2, 11, bgcolor=color.new(#101820, 6), border_width=1, border_color=color.new(gold, 65))
f_explainRow(int row, string heading, string value) =>
    table.cell(explainPanel, 0, row, heading, text_color=color.silver, text_size=size.tiny)
    table.cell(explainPanel, 1, row, value, text_color=color.white, text_size=size.tiny)
if barstate.islast and explanationOn
    table.cell(explainPanel, 0, 0, "CANDLECHASERS", text_color=gold, text_size=size.tiny)
    table.cell(explainPanel, 1, 0, latestDirection, text_color=latestDirection == "LONG" ? bull : latestDirection == "SHORT" ? bear : color.silver, text_size=size.tiny)
    f_explainRow(1, "Confirmed time", latestTimeNote)
    f_explainRow(2, "Liquidity sweep", latestSweepNote)
    f_explainRow(3, "Structure shift", latestShiftNote)
    f_explainRow(4, "Displacement", latestDisplacementNote)
    f_explainRow(5, "Rejected zone", latestZoneNote)
    f_explainRow(6, "Passed filters", latestFilterNote)
    f_explainRow(7, "Session context", latestSessionNote)
    f_explainRow(8, "Planned entry", na(latestEntry) ? "—" : str.tostring(latestEntry, format.mintick))
    f_explainRow(9, "Invalidation / stop", na(latestStop) ? "—" : str.tostring(latestStop, format.mintick))
    f_explainRow(10, "T1 / T2 / T3", na(latestT1) ? "—" : str.tostring(latestT1, format.mintick) + " / " + str.tostring(latestT2, format.mintick) + " / " + str.tostring(latestT3, format.mintick))

alertcondition(barstate.isconfirmed and event == 1, "Bullish BOS [CandleChasers]", "Bullish BOS | {{ticker}} {{interval}} | {{close}}")
alertcondition(barstate.isconfirmed and event == -1, "Bearish BOS [CandleChasers]", "Bearish BOS | {{ticker}} {{interval}} | {{close}}")
alertcondition(barstate.isconfirmed and event == 2, "Bullish CHoCH [CandleChasers]", "Bullish CHoCH | {{ticker}} {{interval}} | {{close}}")
alertcondition(barstate.isconfirmed and event == -2, "Bearish CHoCH [CandleChasers]", "Bearish CHoCH | {{ticker}} {{interval}} | {{close}}")
alertcondition(bullSweep, "SSL sweep [CandleChasers]", "Sell-side sweep | {{ticker}} {{interval}}")
alertcondition(bearSweep, "BSL sweep [CandleChasers]", "Buy-side sweep | {{ticker}} {{interval}}")
alertcondition(newBullOB, "Bullish order block [CandleChasers]", "New bullish OB | {{ticker}} {{interval}}")
alertcondition(newBearOB, "Bearish order block [CandleChasers]", "New bearish OB | {{ticker}} {{interval}}")
alertcondition(newBullFVG, "Bullish FVG [CandleChasers]", "New bullish FVG | {{ticker}} {{interval}}")
alertcondition(newBearFVG, "Bearish FVG [CandleChasers]", "New bearish FVG | {{ticker}} {{interval}}")
alertcondition(longSetup, "Qualified long [CandleChasers]", "Qualified long | {{ticker}} {{interval}} | {{close}}")
alertcondition(shortSetup, "Qualified short [CandleChasers]", "Qualified short | {{ticker}} {{interval}} | {{close}}")
// Alert: choose Any alert() function call for full zone/timeframe/price payload.
// Recreate alerts after changing inputs. No win-rate or confidence score is claimed.
// v3.0 OPERATING NOTES
// Indicator only; no trades, backtest, win rate or probability estimates.
// Standard time-based candles only. Set HTF above chart timeframe or disable it.
// Group 08: selected session windows combine with OR; master filter defaults OFF.
// Regional hours are LOCAL IANA times; DST adjusts by region. Custom supports any
// supported IANA identifier, including America/Toronto. Chart timezone is unrelated.
// Group 09: Regional sessions or editable New York-clock kill zones. In kill-zone
// mode Asia/Tokyo, London, NY AM and NY PM switches select the four KZ windows;
// Sydney/Frankfurt/NY Full are inactive; Custom remains available. No holidays checked.
// Session filter only gates qualified retests; it does not reset sequences or prevent
// structure/zone/sweep detection outside the window. Intraday filtering required.
// Ranges exclude chart bars crossing boundaries. Align timeframes with session/OR
// times for complete data. Developing H/L move with incoming confirmed bars; completed
// levels freeze. Labels identify partial observed data; OR does not invent intrabars.
// Opening-range levels appear only after their interval is confirmed. If no complete
// chart bar fits the OR, it is unavailable. History/extension limits bound drawings.
// Optional completed session liquidity defaults OFF; levels join sweep detection
// after completion confirmation. Already-breached confirmation-bar levels are skipped.
// Group 10: latest setup explanation snapshots actual sequence provenance and gates.
// An optional tooltip label holds the same explanation. No confidence score is claimed.
// Detailed alerts: Any alert() function call. Optional zone/range alerts may create
// multiple separate messages per close. Named setup alerts: Once Per Bar Close.
// Recreate alerts after changing settings. Projections are plans, not executed fills.
// Initial v2.1 compiled successfully in the user's TradingView session. New v3.0
// additions have local source/reference tests; TradingView compilation/replay pending.
````
