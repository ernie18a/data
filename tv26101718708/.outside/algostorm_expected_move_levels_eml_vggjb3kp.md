# AlgoStorm Expected Move Levels (EML)

- url: https://www.tradingview.com/script/VGGjB3KP-AlgoStorm-Expected-Move-Levels-EML/
- type: indicator
- pine_id: PUB;6af8f83613934214899c97310971bfb2
- version: 4.0

## Description

[b]AlgoStorm Expected Move Levels (EML)[/b]

A precision options-implied range mapping tool that plots daily and weekly ±1σ and ±2σ expected-move bands from the ATM straddle, from implied volatility, or from an automatic average-range fallback — with a live meter showing how much of the average daily and weekly range has already been consumed.

The AlgoStorm Expected Move Levels (EML) indicator is designed for index and futures traders who trade with the options market's own forecast. The at-the-money straddle is the market's priced bet on how far the underlying travels before expiry; the expected move derived from it defines the range the market is paid to defend. Gamma levels show where dealers defend — [i]the expected move shows how far the market is priced to travel[/i]. Together they form the complete options-informed map for index futures, and EML is the second half of that pair.

[b]DATA INPUT — READ BEFORE LOADING[/b]
This indicator carries no built-in options data feed. Setup is a single paste. Our free browser-based GEX dashboard includes an Expected Move calculator that auto-fills spot and the ATM straddle from delayed CBOE quotes and emits one CSV line — [i]1,anchor,dailyStraddle,weeklyStraddle,multiplier[/i] (example: 1,6350.25,44.30,94.80,0.85). Drop that line into the [b]EM Data[/b] field and every value is populated at once; the leading 1 is a format version the script validates, so a malformed or mismatched paste is flagged on the chart instead of silently plotting nonsense.

Prefer to work from your own options chain? The Manual Entry group still accepts an ATM straddle price (call + put at the strike nearest spot) or an annualized implied-volatility figure, and a valid paste simply takes precedence over it. With the paste field empty and both manual inputs at zero, the script runs standalone on its average-range fallback, so it works out of the box. Refresh the paste once per session, before the open.

[b]Symbol Mode:[/b] SPX / ES plots pasted values as-is — SPX options are struck at the same levels ES trades. SPY mode divides the pasted anchor and straddles by 10. Scaling is applied to pasted values only; manual entries are always read in chart units.

[b]Technical Architecture: Triple-Source Expected Move Pipeline[/b]

[list=1]
[*][b]Versioned Paste Decoder:[/b] One string input carries anchor, daily straddle, weekly straddle and multiplier — validated on version and field count, with every absent slot decoding to zero so it falls through to the manual entries and then to the range fallback. The info table reports whether the live values came from the paste, from manual entry, or from the automatic fallback.
[*][b]Straddle Conversion Engine:[/b] EM(1σ) = ATM straddle × 0.85. A straddle's price is its expected payout; under a normal approximation, roughly 85% of that payout equals the 1σ price range. The multiplier is exposed as an input — set 1.0 to use the raw straddle convention instead. A pasted line carries its own multiplier and takes precedence; when using the paste workflow, adjust the multiplier on the dashboard before copying.
[*][b]Volatility Mode:[/b] EM(daily) = anchor × IV × √(1/252) and EM(weekly) = anchor × IV × √(5/252), the trading-day convention. Useful when you track IV but not option prices.
[*][b]Automatic Fallback Cascade:[/b] Any zeroed input degrades gracefully — daily falls back to the Average Daily Range (default 14 days), weekly to the Average Weekly Range (default 8 weeks), and a missing weekly straddle first derives from the daily straddle × √5. The info table always displays which source is live, so there is never ambiguity about what the bands represent.
[*][b]Chart-Side Lock Engine:[/b] The script contains zero request.security calls. Anchors and bands compute from the chart's own session boundaries and lock at the day/week open — they cannot move intraday, and there is no repaint path by construction.
[*][b]Range Consumption Meter:[/b] Completed daily and weekly ranges feed fixed-length rolling windows; the current period's range is expressed as a percentage of its average ("today has used 78% of its average range") — the continuation/exhaustion filter the EM bands are read with.
[/list]

[b]Features & Functionality[/b]

[list=1]
[*][b]Daily Expected Move Bands:[/b] ±1σ and optional ±2σ steplines around a configurable anchor — prior close (the desk-quoting convention, default), today's open, or the spot price carried in the paste.
[*][b]Weekly Expected Move Bands:[/b] The identical structure anchored at the weekly boundary, off by default for chart cleanliness.
[*][b]Anchor Lines:[/b] Dimmed reference steplines marking the exact price the bands are centred on.
[*][b]Live Info Table:[/b] Effective daily and weekly EM with source labels, ADR/AWR values, day/week range-consumption percentages that highlight when a range is fully spent, and an EM Data row reporting paste / manual / fallback status.
[*][b]Symbol Mode:[/b] SPX / ES one-to-one, or SPY with pasted values auto-scaled ÷10 — a chart label confirms whenever scaling is active.
[*][b]Alert Suite:[/b] Seven conditions — daily ±1σ break, daily ±2σ break (tail move), weekly ±1σ break, and ADR exhausted (day range reaches 100% of average). All fire on confirmed closes; a crossed band cannot move away afterward.
[/list]

[b]Honest limitations:[/b] the expected move is model context, not a boundary — [i]roughly one day in three closes outside the ±1σ band by construction, because that is what 1σ means[/i]. Straddle and IV inputs are static: re-enter them when the session rolls or the volatility regime shifts. ADR/AWR use chart-session ranges, which on continuous futures include the overnight session — usually what you want on full-Globex instruments, but know your convention.

Open-source under CC BY-NC-SA 4.0. [i]Educational tool — not financial advice.[/i]

## Source Code

````pine
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoStorm

//@version=6
indicator(title = "AlgoStorm Expected Move Levels (EML)", shorttitle = "EML • [AlgoStorm]", overlay = true)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  NOTES
//  • The options-implied travel map: how far the market is PRICED to move
//    today and this week. Pairs with GEX-L (where dealers defend) — together
//    they form the complete options-informed futures map.
//  • ONE-FIELD SETUP. Any expected-move source can emit the five-value CSV
//    line — paste it into "EM Data" and every value below is filled at once. Format (5 values):
//        1,anchor,dailyStraddle,weeklyStraddle,multiplier
//    Leading 1 is the format version. Any slot may be 0 (= not supplied).
//    Lines from the NQ dashboard lead with N1 (NDX values; Symbol Mode NDX / NQ).
//    Example: 1,6350.25,44.30,94.80,0.85
//  • Three expected-move (EM) sources, in order of quality. Each is turned into
//    a straddle-equivalent (the average absolute move to expiry) and then
//    EM = straddle-equivalent × multiplier (default 0.85, the widely quoted rule
//    of thumb). A straddle prices ≈0.8σ under a normal approximation, so at 0.85
//    the ±1 EM band is ≈±0.68σ — roughly a 50% band — and ±2 EM ≈83%, in EVERY
//    mode. Set the multiplier to 1.25 for a ±1σ (≈68%) band.
//      1. ATM Straddle — the at-the-money call + put at the strike nearest the
//         underlying, from the paste or typed manually. Used as-is.
//      2. Implied Volatility — enter annualized IV%. Straddle-equivalent is the
//         Black-Scholes ATM straddle for that IV (trading-day convention):
//         Daily  = anchor × IV × √(1/252) × √(2/π)
//         Weekly = anchor × IV × √(5/252) × √(2/π)
//      3. ADR / AWR fallback — no inputs required. Straddle-equivalent is half
//         the Average Daily/Weekly Range: for a random walk the average high–low
//         range is twice the average close-to-close move. Realized, not implied,
//         so it is the roughest of the three; it lets the script work before
//         you fetch options data.
//  • Precedence: a valid paste wins over the manual entries. Clear the EM Data
//    field to fall back to manual straddle / IV entry.
//  • Anchor: prior close (default, mirrors how desks quote the daily EM),
//    today's open, or the spot price carried in the paste. Weekly bands anchor
//    the same way at the weekly boundary.
//  • Symbol Mode: SPX/ES uses pasted straddles as-is (the anchor gets the
//    futures basis below); SPY scales the pasted anchor and straddles by the
//    measured SPY ÷ SPX ratio (Auto) or by ÷10. Scaling applies to PASTED
//    values only — manual entries are always taken in chart units.
//  • Range-consumption context: "today has used 78% of its average range" —
//    the mean-reversion / continuation filter the EM bands are read with.
//  • Futures basis: in "Dashboard Spot (pasted)" mode the pasted anchor is an
//    SPX price, and ES/MES trade above SPX by the carry basis, so the anchor is
//    shifted by chart − SPX (the only request.security call, on the SPX close;
//    other anchors never use it). Levels lock at the
//    day/week open and never move intraday — no repaint path. ADR/AWR use
//    chart-session ranges (full ETH on continuous futures contracts).
//  • Designed for intraday through daily timeframes.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

string G_DATA = "Expected Move Data"

var string TT_DATA = """- Paste the five-value EM line from your expected-move source.
- Format: 1,anchor,dailyStraddle,weeklyStraddle,multiplier  (5 values total).
- Example: 1,6350.25,44.30,94.80,0.85.
- The leading 1 is the format version.
- Lines from the NQ dashboard start with N1 (NDX values): set Symbol Mode to NDX / NQ for them.
- Use 0 for any value you do not have.
- A valid paste overrides the Manual Entry group below.
- Clear this field to enter values by hand."""

var string TT_SYM = """- SPX / ES: pasted straddles are used as-is; a pasted anchor is shifted by the Futures Basis setting.
- SPY: scales the pasted anchor and straddles to SPY: by the measured SPY ÷ SPX ratio when Futures Basis is Auto, else ÷10.
- NDX / NQ: N1 lines from the NQ dashboard; straddles as-is, a pasted anchor shifted by the NQ − NDX basis.
- Scaling applies to PASTED values only
- Type manual entries in chart units."""

var string TT_ANCHOR = """- Reference price the bands are centred on.
- Prior Close: the desk-quoting convention (default).
- Today's Open: session-open anchoring.
- Dashboard Spot: the anchor carried in the paste, an SPX price, shifted by the Futures Basis setting on ES/MES
- Falls back to prior close when absent."""

string i_emData  = input.string(defval = "", title = "EM Data (Paste CSV)", group = G_DATA, tooltip = TT_DATA)
string i_symMode = input.string(defval = "SPX / ES", title = "Symbol Mode", group = G_DATA, options = ["SPX / ES", "SPY (auto ÷10)", "NDX / NQ"], tooltip = TT_SYM)
string i_anchor  = input.string(defval = "Prior Close", title = "Anchor", group = G_DATA, options = ["Prior Close", "Today's Open", "Dashboard Spot (pasted)"], tooltip = TT_ANCHOR)

string G_SRC = "Manual Entry (used when no paste)"
string i_mode = input.string(defval = "ATM Straddle", title = "EM Mode", group = G_SRC,
                 options = ["ATM Straddle", "Implied Volatility", "ADR / AWR (auto)"],
                 tooltip = "Ignored while a valid paste supplies a daily straddle. Straddle and IV modes fall back to ADR/AWR automatically while their inputs are 0.")
float i_dStraddle = input.float(defval = 0.0, title = "Daily ATM Straddle Price",  group = G_SRC, minval = 0.0,
                 tooltip = "Same-day (0DTE) ATM call + put price, in chart units. 0 = use the paste, or the ADR fallback.")
float i_wStraddle = input.float(defval = 0.0, title = "Weekly ATM Straddle Price", group = G_SRC, minval = 0.0,
                 tooltip = "ATM straddle expiring ≈1 week out (5 trading days — a full trading week, whatever weekday you load it). 0 = derive from the daily straddle (× √5) or fall back to AWR.")
float i_stradMult = input.float(defval = 0.85, title = "Straddle → EM Multiplier", group = G_SRC, minval = 0.5, maxval = 1.5, step = 0.05,
                 tooltip = "EM = straddle × this, in every mode (IV and ADR/AWR are first converted to the straddle they imply). 0.85 is the widely quoted rule of thumb: about a 50% band under a normal approximation (a straddle prices ≈0.8σ). 1.25 gives a ±1σ (≈68%) band. A paste carrying its own multiplier overrides this.")
float i_iv = input.float(defval = 0.0, title = "Implied Volatility % (annualized)", group = G_SRC, minval = 0.0, step = 0.5,
                 tooltip = "E.g. 14.5 for 14.5%. Used only in Implied Volatility mode, converted to the ATM straddle it implies (σ·√(2/π)) and then multiplied like a quoted straddle. 0 = use ADR fallback.")

string G_VIS = "Core Visibility Toggles"
bool i_showDaily  = input.bool(defval = true,  title = "Daily EM Bands (±1 EM)", group = G_VIS)
bool i_show2Sig   = input.bool(defval = true,  title = "±2 EM Bands",            group = G_VIS)
bool i_showWeekly = input.bool(defval = false, title = "Weekly EM Bands",       group = G_VIS)
bool i_showAnchor = input.bool(defval = true,  title = "Anchor Line",           group = G_VIS)
bool i_showTable  = input.bool(defval = true,  title = "EM Info Table",         group = G_VIS)
bool i_showWarn   = input.bool(defval = true,  title = "Paste / Scaling Warnings", group = G_VIS,
                 tooltip = "Chart label flagging a malformed paste or active SPY auto-scaling.")

string G_RANGE = "Average Range Lookbacks"
int i_adrLen = input.int(defval = 14, title = "ADR Length (days)",  group = G_RANGE, minval = 2, maxval = 60)
int i_awrLen = input.int(defval = 8,  title = "AWR Length (weeks)", group = G_RANGE, minval = 2, maxval = 26)

string G_COLORS = "Color Suite"
color i_cUp     = input.color(defval = #c7e36c, title = "Upper Bands",  group = G_COLORS)
color i_cDn     = input.color(defval = #ff8068, title = "Lower Bands",  group = G_COLORS)
color i_cAnchor = input.color(defval = #f3f5f0, title = "Anchor Line",  group = G_COLORS)

// Futures basis. Declared last on purpose: TradingView keys saved inputs by
// position, so new inputs are appended after every existing one.
string G_BASIS = "Futures Basis & SPY Ratio"
var string TT_BASIS = """- Used only when Anchor is Dashboard Spot (pasted): that anchor is an SPX price, and ES/MES trade above SPX by the carry basis (tens of points when expiry is months away, zero at expiry).
- Auto: chart close minus SPX close on the latest bar where both traded, taken at each day and week open so the bands never move intraday. Any timeframe of one minute or more: where chart bars do not open with SPX bars (1 hour, daily…), it pairs 15-minute (or 1-minute) bars inside each chart bar.
- Manual: the points entered below. Off: the pasted anchor unchanged.
- Ignored for the other anchors.
- SPY mode: Auto scales pasted values by the measured SPY ÷ SPX ratio (about 0.0997, from dividends and fees) instead of ÷10; Manual and Off divide by 10."""
string i_basisMode   = input.string(defval = "Auto (chart − SPX)", title = "Futures Basis Adjustment", group = G_BASIS, options = ["Auto (chart − SPX)", "Manual", "Off"], tooltip = TT_BASIS)
string i_basisRef    = input.symbol(defval = "SP:SPX", title = "Basis Reference (SPX)", group = G_BASIS)
float  i_basisManual = input.float(defval = 0.0, title = "Manual Basis (pts)", group = G_BASIS, step = 0.25)
string i_basisRefNDX = input.symbol(defval = "NASDAQ:NDX", title = "Basis Reference (NDX)", group = G_BASIS)

// ═══════════════════════════════════════════════════════════════════════════════
// SPX CONVERSION
// A pasted line is in SPX units. ES/MES trade above SPX by the carry basis (a
// shift of the anchor); SPY trades at about a tenth of SPX (a ratio, a little
// under 0.1). Both are measured on bars where the chart and SPX both traded:
// SPX bars exist only in the cash session, gaps_on returns na elsewhere, and
// only minute charts whose length divides 30 open SPX bars (from 09:30 ET) and
// the chart's bars together. Locked at each day and week open, like the
// anchors, so the bands never move intraday.
// ═══════════════════════════════════════════════════════════════════════════════

bool newDay  = timeframe.change("D")
bool newWeek = timeframe.change("W")

bool  isSPY    = i_symMode == "SPY (auto ÷10)"
// NDX / NQ mode: the paste is in NDX units and the basis is measured against NDX.
bool   isNDX   = i_symMode == "NDX / NQ"
string refSym  = isNDX ? i_basisRefNDX : i_basisRef
string idxName = isNDX ? "NDX" : "SPX"
bool  autoConv = i_basisMode == "Auto (chart − SPX)"
bool  basisTF  = timeframe.isminutes and timeframe.multiplier <= 30 and 30 % timeframe.multiplier == 0
float refClose = request.security(refSym, timeframe.period, close, gaps = barmerge.gaps_on)
var float autoBasis = na
var float autoRatio = na
if basisTF and barstate.isconfirmed and not na(refClose) and refClose > 0
    autoBasis := close - refClose
    autoRatio := close / refClose

// On every other timeframe above one minute, pair SPX and chart closes from the
// same lower-timeframe bars inside each chart bar, matched on bar time.
bool   pairTF  = not basisTF and timeframe.in_seconds() > 60
string pairRes = timeframe.in_seconds() >= 900 ? "15" : "1"
if pairTF and barstate.isconfirmed
    [refT, refC] = request.security_lower_tf(refSym, pairRes, [time, close])
    [chT, chC]   = request.security_lower_tf(syminfo.tickerid, pairRes, [time, close])
    int nRef = array.size(refT)
    if nRef > 0 and array.size(chT) > 0
        for i = nRef - 1 to 0
            int   j  = array.indexof(chT, array.get(refT, i))
            float rc = array.get(refC, i)
            if j >= 0 and rc > 0
                float cc = array.get(chC, j)
                autoBasis := cc - rc
                autoRatio := cc / rc
                break
// Outside these bounds it is the wrong chart for the mode, not carry or fees.
bool  basisSane = not na(autoBasis) and math.abs(autoBasis) < close * 0.05
bool  ratioSane = not na(autoRatio) and autoRatio > 0.09 and autoRatio < 0.11
float liveShift  = isSPY ? 0.0 : i_basisMode == "Manual" ? i_basisManual : not autoConv ? 0.0 : basisSane ? autoBasis : 0.0
float liveFactor = isSPY ? (autoConv and ratioSane ? autoRatio : 0.1) : 1.0

var float dayShift   = 0.0
var float weekShift  = 0.0
var float dayFactor  = na
var float weekFactor = na
if newDay or na(dayFactor)
    dayShift  := liveShift
    dayFactor := liveFactor
if newWeek or na(weekFactor)
    weekShift  := liveShift
    weekFactor := liveFactor

// ═══════════════════════════════════════════════════════════════════════════════
// PASTE DECODER
// The tokenized array is built once — the input is constant for the life of a
// script run, so re-splitting per bar would only churn allocations. Missing or
// non-numeric slots decode to 0, which every downstream branch reads as
// "not supplied".
// ═══════════════════════════════════════════════════════════════════════════════

const int EM_FORMAT_VERSION = 1
const int EM_FIELD_COUNT    = 5

_tok(array<string> parts, int idx) =>
    int   n   = array.size(parts)
    float raw = idx < n ? str.tonumber(array.get(parts, idx)) : na
    nz(raw, 0.0)

string emRaw = str.replace_all(i_emData, " ", "")

var array<string> emParts = str.split(emRaw, ",")

int   emCount  = array.size(emParts)
// "N1" marks an NDX line from the NQ dashboard; copies of EML without NDX / NQ
// mode read it as an unknown version and reject it, as they should.
bool  emIsNDX  = emCount > 0 and array.get(emParts, 0) == "N" + str.tostring(EM_FORMAT_VERSION)
float emVer    = emIsNDX ? EM_FORMAT_VERSION : _tok(emParts, 0)
float emAnchor = _tok(emParts, 1)
float emDaily_ = _tok(emParts, 2)
float emWkly_  = _tok(emParts, 3)
float emMult_  = _tok(emParts, 4)

bool emPresent = str.length(emRaw) > 0
bool emFormOK  = emPresent and emCount == EM_FIELD_COUNT and emVer == EM_FORMAT_VERSION
// An NDX line in an SPX mode, or an SPX line in NDX / NQ mode, is refused.
bool emTagOK   = emIsNDX == isNDX
bool emValid   = emFormOK and emTagOK

// SPY scaling touches pasted values only — manual entries are chart-native.
// Daily values take the day's factor, weekly ones the week's (1 outside SPY mode).
float pAnchor  = emAnchor * dayFactor
float pAnchorW = emAnchor * weekFactor
float pDaily   = emDaily_ * dayFactor
float pWeekly  = emWkly_  * weekFactor

bool usePasteD = emValid and pDaily  > 0
bool usePasteW = emValid and pWeekly > 0

// Paste wins; manual entries fill the slots it leaves empty.
float effDStraddle = usePasteD ? pDaily  : i_dStraddle
float effWStraddle = usePasteW ? pWeekly : i_wStraddle
float effMult      = emValid and emMult_ > 0 ? emMult_ : i_stradMult

// A paste carrying a straddle implies straddle mode — otherwise a user sitting
// in IV mode would paste and see nothing change.
string effMode = usePasteD ? "ATM Straddle" : i_mode

// ═══════════════════════════════════════════════════════════════════════════════
// DAY / WEEK STATE ENGINE
// Chart-side session tracking — completed ranges are pushed into fixed-length
// arrays at each boundary BEFORE the running H/L resets, so ADR/AWR only ever
// average fully completed periods.
// ═══════════════════════════════════════════════════════════════════════════════

var float dayHi         = na
var float dayLo         = na
var float prevDayClose  = na
var float dayOpenPrice  = na
var float weekHi        = na
var float weekLo        = na
var float prevWeekClose = na
var float weekOpenPrice = na

var array<float> dRanges = array.new<float>()
var array<float> wRanges = array.new<float>()

if newDay
    if not na(dayHi) and not na(dayLo)
        array.push(dRanges, dayHi - dayLo)
        if array.size(dRanges) > i_adrLen
            array.shift(dRanges)
    prevDayClose := close[1]
    dayOpenPrice := open
    dayHi := high
    dayLo := low
else
    dayHi := math.max(nz(dayHi, high), high)
    dayLo := math.min(nz(dayLo, low),  low)

if newWeek
    if not na(weekHi) and not na(weekLo)
        array.push(wRanges, weekHi - weekLo)
        if array.size(wRanges) > i_awrLen
            array.shift(wRanges)
    prevWeekClose := close[1]
    weekOpenPrice := open
    weekHi := high
    weekLo := low
else
    weekHi := math.max(nz(weekHi, high), high)
    weekLo := math.min(nz(weekLo, low),  low)

float adr = array.size(dRanges) > 0 ? array.avg(dRanges) : na
float awr = array.size(wRanges) > 0 ? array.avg(wRanges) : na

// ═══════════════════════════════════════════════════════════════════════════════
// EXPECTED MOVE COMPUTATION
// ═══════════════════════════════════════════════════════════════════════════════

bool usePasteAnchor = i_anchor == "Dashboard Spot (pasted)" and emValid and pAnchor > 0

float anchorD = switch i_anchor
    "Prior Close"  => prevDayClose
    "Today's Open" => dayOpenPrice
    => usePasteAnchor ? pAnchor + dayShift : prevDayClose

float anchorW = switch i_anchor
    "Prior Close"  => prevWeekClose
    "Today's Open" => weekOpenPrice
    => usePasteAnchor ? pAnchorW + weekShift : prevWeekClose

// Every source is first turned into a straddle-equivalent (the average absolute
// move to expiry), then multiplied — so ±1 EM covers the same share of outcomes
// whichever source drew it:
//   IV:        σ·√(2/π)  — the Black-Scholes ATM straddle for that IV
//   ADR / AWR: range ÷ 2 — for a random walk the average high–low range is twice
//              the average close-to-close move (√(8/π)σ vs √(2/π)σ)
float SQRT_2_OVER_PI = math.sqrt(2.0 / math.pi)
float adrEM = not na(adr) ? adr / 2.0 * effMult : na
float awrEM = not na(awr) ? awr / 2.0 * effMult : na

float emDaily = switch effMode
    "ATM Straddle"       => effDStraddle > 0 ? effDStraddle * effMult : adrEM
    "Implied Volatility" => i_iv > 0 and not na(anchorD) ? anchorD * (i_iv / 100.0) * math.sqrt(1.0 / 252.0) * SQRT_2_OVER_PI * effMult : adrEM
    => adrEM

float emWeekly = switch effMode
    "ATM Straddle"       => effWStraddle > 0 ? effWStraddle * effMult :
                             effDStraddle > 0 ? effDStraddle * effMult * math.sqrt(5.0) : awrEM
    "Implied Volatility" => i_iv > 0 and not na(anchorW) ? anchorW * (i_iv / 100.0) * math.sqrt(5.0 / 252.0) * SQRT_2_OVER_PI * effMult : awrEM
    => awrEM

// Effective source labels for the table (mode may have fallen back to ADR/AWR).
string dStradSrc = usePasteD ? "Straddle · paste" : "Straddle · manual"
string wStradSrc = usePasteW ? "Straddle · paste" : "Straddle · manual"

string dSrc = effMode == "ATM Straddle" ? (effDStraddle > 0 ? dStradSrc : "ADR fallback") :
              effMode == "Implied Volatility" ? (i_iv > 0 ? "IV" : "ADR fallback") : "ADR"
string wSrc = effMode == "ATM Straddle" ? (effWStraddle > 0 ? wStradSrc : effDStraddle > 0 ? "Daily × √5" : "AWR fallback") :
              effMode == "Implied Volatility" ? (i_iv > 0 ? "IV" : "AWR fallback") : "AWR"

string emStatus = not emPresent ? "Manual entry" :
                  emFormOK and not emTagOK ? "⚠ Paste is " + (emIsNDX ? "NDX" : "SPX") + ", mode is not" :
                  not emValid   ? "⚠ Invalid paste" :
                  i_symMode == "SPY (auto ÷10)" ? "Paste ✓ · SPY ÷10" : "Paste ✓"

float dU1 = not na(anchorD) and not na(emDaily) ? anchorD + emDaily       : na
float dD1 = not na(anchorD) and not na(emDaily) ? anchorD - emDaily       : na
float dU2 = not na(anchorD) and not na(emDaily) ? anchorD + 2.0 * emDaily : na
float dD2 = not na(anchorD) and not na(emDaily) ? anchorD - 2.0 * emDaily : na

float wU1 = not na(anchorW) and not na(emWeekly) ? anchorW + emWeekly       : na
float wD1 = not na(anchorW) and not na(emWeekly) ? anchorW - emWeekly       : na
float wU2 = not na(anchorW) and not na(emWeekly) ? anchorW + 2.0 * emWeekly : na
float wD2 = not na(anchorW) and not na(emWeekly) ? anchorW - 2.0 * emWeekly : na

// Range consumption — monotonic within the period, so threshold alerts fire once.
float dUsedPct = not na(adr) and adr > 0 and not na(dayHi)  ? (dayHi - dayLo)   / adr * 100.0 : na
float wUsedPct = not na(awr) and awr > 0 and not na(weekHi) ? (weekHi - weekLo) / awr * 100.0 : na

// ═══════════════════════════════════════════════════════════════════════════════
// VISUAL HIERARCHY
// Steplines: levels are constant within each day/week, so bands render as
// clean horizontal shelves that step at the boundary.
// ═══════════════════════════════════════════════════════════════════════════════

// --- Tier 1: Daily expected move ---
plot(i_showDaily ? dU1 : na, title = "Daily +1 EM", color = i_cUp, linewidth = 2, style = plot.style_stepline)
plot(i_showDaily ? dD1 : na, title = "Daily −1 EM", color = i_cDn, linewidth = 2, style = plot.style_stepline)
plot(i_showDaily and i_show2Sig ? dU2 : na, title = "Daily +2 EM", color = color.new(i_cUp, 45), linewidth = 1, style = plot.style_stepline)
plot(i_showDaily and i_show2Sig ? dD2 : na, title = "Daily −2 EM", color = color.new(i_cDn, 45), linewidth = 1, style = plot.style_stepline)

// --- Tier 2: Weekly expected move ---
plot(i_showWeekly ? wU1 : na, title = "Weekly +1 EM", color = color.new(i_cUp, 55), linewidth = 1, style = plot.style_stepline)
plot(i_showWeekly ? wD1 : na, title = "Weekly −1 EM", color = color.new(i_cDn, 55), linewidth = 1, style = plot.style_stepline)
plot(i_showWeekly and i_show2Sig ? wU2 : na, title = "Weekly +2 EM", color = color.new(i_cUp, 75), linewidth = 1, style = plot.style_stepline)
plot(i_showWeekly and i_show2Sig ? wD2 : na, title = "Weekly −2 EM", color = color.new(i_cDn, 75), linewidth = 1, style = plot.style_stepline)

// --- Tier 3: Anchors ---
plot(i_showDaily and i_showAnchor ? anchorD : na, title = "Daily Anchor",  color = color.new(i_cAnchor, 35), linewidth = 1, style = plot.style_stepline)
plot(i_showWeekly and i_showAnchor ? anchorW : na, title = "Weekly Anchor", color = color.new(i_cAnchor, 65), linewidth = 1, style = plot.style_stepline)

// ═══════════════════════════════════════════════════════════════════════════════
// PASTE / SCALING NOTICE
// A single reusable label — deleted and rebuilt on the last bar so repeated
// realtime ticks cannot stack duplicates.
// ═══════════════════════════════════════════════════════════════════════════════

var label emNotice = na

if barstate.islast
    if not na(emNotice)
        label.delete(emNotice)
    emNotice := na
    if i_showWarn
        if emFormOK and not emTagOK
            emNotice := label.new(bar_index, high,
                          text      = emIsNDX ? "⚠ EML: this is an NDX line (N1) — set Symbol Mode to NDX / NQ" : "⚠ EML: this is an SPX line — set Symbol Mode to SPX / ES or SPY",
                          color     = color.new(i_cDn, 75),
                          textcolor = i_cDn,
                          style     = label.style_label_down,
                          size      = size.tiny)
        else if emPresent and not emValid
            emNotice := label.new(bar_index, high,
                          text      = "⚠ EML: unreadable paste — expected 5 values: 1,anchor,daily,weekly,mult",
                          color     = color.new(i_cDn, 75),
                          textcolor = i_cDn,
                          style     = label.style_label_down,
                          size      = size.tiny)
        else if emValid and isSPY
            emNotice := label.new(bar_index, high,
                          text      = dayFactor != 0.1 ? "SPY mode: pasted SPX values × " + str.tostring(dayFactor, "0.00000") + " (measured SPY ÷ SPX)" : "⚠ SPY mode: pasted SPX values ÷10 (ratio not measured)",
                          color     = color.new(color.yellow, 75),
                          textcolor = color.yellow,
                          style     = label.style_label_down,
                          size      = size.tiny)
        else if usePasteAnchor and i_basisMode != "Off"
            string shiftTxt = (dayShift >= 0 ? "+" : "") + str.tostring(dayShift, "#.##")
            string basisTxt = ""
            if i_basisMode == "Manual"
                basisTxt := dayShift != 0 ? "Pasted anchor shifted " + shiftTxt + " pts (manual basis)" : ""
            else if not (basisTF or pairTF)
                basisTxt := "⚠ Auto basis needs a chart of one minute or more; use Manual here. Pasted anchor unshifted"
            else if math.abs(dayShift) >= 0.01
                basisTxt := "Pasted anchor shifted " + shiftTxt + " pts (chart − " + idxName + " basis)"
            else if not basisSane
                basisTxt := isNDX ? "⚠ Basis not measured: no matching NDX bar, or chart is not NDX/NQ. Pasted anchor unshifted" : "⚠ Basis not measured: no matching SPX bar, or chart is not SPX/ES. Pasted anchor unshifted"
            if basisTxt != ""
                emNotice := label.new(bar_index, high,
                              text      = basisTxt,
                              color     = color.new(color.gray, 80),
                              textcolor = color.gray,
                              style     = label.style_label_down,
                              size      = size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// LIVE INFO TABLE
// Populated only on the last bar to avoid unnecessary per-bar cell redraws.
// ═══════════════════════════════════════════════════════════════════════════════

var table info_table = table.new(position.top_right, 2, 8,
                                  bgcolor      = color.new(color.black, 80),
                                  border_width = 1,
                                  border_color = color.new(color.gray, 65))

if i_showTable and barstate.islast
    table.cell(info_table, 0, 0, "EML",   bgcolor = color.new(color.gray, 55), text_color = color.white, text_size = size.small)
    table.cell(info_table, 1, 0, "Value", bgcolor = color.new(color.gray, 55), text_color = color.white, text_size = size.small)
    table.cell(info_table, 0, 1, "Daily EM", text_color = i_cUp, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 1, not na(emDaily) ? str.tostring(emDaily, format.mintick) + "  ·  " + dSrc : "—", text_color = i_cUp, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 2, "ADR(" + str.tostring(i_adrLen) + ")", text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 2, not na(adr) ? str.tostring(adr, format.mintick) : "—", text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 3, "Day Range Used", text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 3, not na(dUsedPct) ? str.tostring(dUsedPct, "#.#") + "%" : "—", text_color = not na(dUsedPct) and dUsedPct >= 100 ? i_cDn : color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 4, "Weekly EM", text_color = i_cUp, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 4, not na(emWeekly) ? str.tostring(emWeekly, format.mintick) + "  ·  " + wSrc : "—", text_color = i_cUp, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 5, "AWR(" + str.tostring(i_awrLen) + ")", text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 5, not na(awr) ? str.tostring(awr, format.mintick) : "—", text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 6, "Week Range Used", text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 6, not na(wUsedPct) ? str.tostring(wUsedPct, "#.#") + "%" : "—", text_color = not na(wUsedPct) and wUsedPct >= 100 ? i_cDn : color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 7, "EM Data", text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 7, emStatus, text_color = emPresent and not emValid ? i_cDn : color.silver, text_size = size.small, bgcolor = color.new(color.black, 85))

// ═══════════════════════════════════════════════════════════════════════════════
// ALERT CONDITIONS
// All conditions fire on confirmed bar closes — no repainting. Levels are
// locked at the day/week open, so a crossed band cannot move away afterward.
// ═══════════════════════════════════════════════════════════════════════════════

bool xDU1 = ta.crossover(close,  dU1)
bool xDD1 = ta.crossunder(close, dD1)
bool xDU2 = ta.crossover(close,  dU2)
bool xDD2 = ta.crossunder(close, dD2)
bool xWU1 = ta.crossover(close,  wU1)
bool xWD1 = ta.crossunder(close, wD1)
bool xAdr = ta.crossover(dUsedPct, 100.0)

alertcondition(barstate.isconfirmed and xDU1, title = "Daily +1 EM Break ▲",  message = "Price closed above the daily +1 EM band — {{ticker}} @ {{close}}")
alertcondition(barstate.isconfirmed and xDD1, title = "Daily −1 EM Break ▼",  message = "Price closed below the daily −1 EM band — {{ticker}} @ {{close}}")
alertcondition(barstate.isconfirmed and xDU2, title = "Daily +2 EM Break ▲",  message = "Price closed above the daily +2 EM band — {{ticker}} @ {{close}}")
alertcondition(barstate.isconfirmed and xDD2, title = "Daily −2 EM Break ▼",  message = "Price closed below the daily −2 EM band — {{ticker}} @ {{close}}")
alertcondition(barstate.isconfirmed and xWU1, title = "Weekly +1 EM Break ▲", message = "Price closed above the weekly +1 EM band — {{ticker}} @ {{close}}")
alertcondition(barstate.isconfirmed and xWD1, title = "Weekly −1 EM Break ▼", message = "Price closed below the weekly −1 EM band — {{ticker}} @ {{close}}")
alertcondition(barstate.isconfirmed and xAdr, title = "ADR Exhausted",      message = "Today's range has fully consumed the average daily range — {{ticker}} @ {{close}}")
````
