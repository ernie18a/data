<!-- tradingview-pine-id: PUB;efa72cdb67474d5895e4515c1301e331 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Tech Leadership Map+ [Herman]

Source: https://www.tradingview.com/script/miu0UG9g-Tech-Leadership-Map-Herman/

## Description

Tech Leadership Map [Herman]

Tech Leadership Map is a relative-market leadership indicator designed to show whether technology-focused market activity is currently leading, lagging, or moving without a clear advantage relative to the broader US equity market.

The indicator does not generate traditional buy or sell signals. Instead, it provides an additional market-context layer that can help traders evaluate whether current market participation supports or conflicts with the directional move they are analyzing.

It includes two selectable and independent leadership models:

* **Price**
* **Volume Pressure**

Both models convert several measurements into a standardized four-component composite score.

---

Why Tech Leadership Matters

Technology shares represent an important component of US equity index activity, particularly for Nasdaq-related instruments.

When technology is outperforming the broader market, Nasdaq-focused markets may be receiving stronger relative participation. When technology is underperforming, broader-market strength may not be confirmed by technology leadership.

This indicator attempts to make that relationship easier to observe directly on the chart.

It should be treated as a **relative-market context tool**, not as a standalone forecasting system.

---

Leadership States

The indicator evaluates four separate components.

Each component contributes:

**+1** = favors the selected technology leader
**0** = neutral / unavailable confirmation
**-1** = favors the benchmark

The resulting Composite Score can therefore range from:

**+4 to -4**

The default classification is:

**GREEN — Tech Leading**
Composite Score of +2 or higher.

Technology-oriented activity is showing stronger relative leadership than the selected benchmark.

**YELLOW — No Clear Edge**
Composite Score between -1 and +1.

The measurements are mixed and neither side has sufficient agreement to establish a clear leadership state.

**RED — Tech Lagging**
Composite Score of -2 or lower.

Technology-oriented activity is showing weaker relative leadership than the selected benchmark.

These colors describe the current relative-leadership condition. They do not represent predictions of future price direction.

---

# 1. PRICE MODE

The default Price model compares:

**QQQ — Price Leader**
with
**SPY — Price Benchmark**

Both symbols can be changed in the indicator settings.

The model evaluates four components.

### 1. Performance From RTH Open

The indicator measures the percentage performance of QQQ and SPY from the beginning of the configured US Regular Trading Hours session.

It then compares those performances.

If QQQ has performed better from the RTH open, the component favors the leader.

If SPY has performed better, it favors the benchmark.

---

### 2. Relative-Strength Ratio Slope

The indicator calculates the relative-strength relationship:

**QQQ / SPY**

The logarithm of this ratio is evaluated using a linear-regression slope.

A rising relative-strength relationship indicates improving technology leadership.

A falling relationship indicates weakening technology leadership relative to the benchmark.

---

### 3. Short-Term Momentum Difference

The model compares short-term rate-of-change momentum between the leader and benchmark.

By default, this component uses a 5-bar momentum comparison.

This allows the indicator to identify situations where both markets may be moving in the same direction while one is accelerating more strongly than the other.

---

### 4. Correlation-Break Confirmation

QQQ and SPY normally exhibit a relatively high degree of correlation.

The indicator measures correlation between their logarithmic returns.

When correlation falls below the model's internal threshold, the short-term momentum difference receives an additional confirmation vote.

The purpose of this component is to emphasize periods where relative movement becomes more meaningful because the two markets are no longer behaving as closely together.

---

# 2. VOLUME PRESSURE MODE

Volume Pressure provides an alternative model that does **not use QQQ/SPY price movement to determine leadership**.

The default market-internal sources are:

**NASDAQ: VOLDQ**
versus
**Broad Market / NYSE: VOLD**

These represent net up-volume minus down-volume market internals.

The symbols are editable because VOLDQ and VOLD represent different market universes and should not be interpreted as literal constituent-by-constituent equivalents of QQQ and SPY.

---

## Normalization

NASDAQ and broad-market internal series can operate on substantially different numerical scales.

For that reason, the indicator first normalizes each series independently before comparing them.

This prevents the raw numerical magnitude of one internal from automatically dominating the comparison.

---

## Volume Pressure Components

The model then evaluates four measurements.

### 1. Pressure Level

Compares the current normalized leader pressure with the normalized benchmark pressure.

---

### 2. Fast Pressure

Applies short-term smoothing to both normalized internal series and compares their relative position.

This helps reduce some bar-to-bar noise while preserving short-term changes in leadership.

---

### 3. Pressure Momentum

Measures the change in normalized internal pressure over the selected momentum lookback.

This identifies which market internal is currently improving or deteriorating faster.

---

### 4. Pressure Impulse

Each normalized internal is compared with its own slower baseline.

The difference between those impulses determines which market is showing the stronger deviation from its recent baseline.

---

# Chart Display

The default visualization uses colored dots placed along the chart.

The colors correspond directly to the current leadership state:

**Green = Tech Leading**
**Yellow = No Clear Edge**
**Red = Tech Lagging**

Optional chart-bar coloring can also be enabled.

By default, leadership dots are displayed only during the configured US Regular Trading Hours session:

**09:30–16:00 New York time**

This behavior can be changed in the settings.

---

# Statistics Table

The optional statistics table provides additional information about the active model.

Depending on the selected source, it displays:

* active leadership source
* current leadership state
* Composite Score
* individual component votes
* correlation in Price mode
* normalized internal gap in Volume Pressure mode

The table is intended to make the calculation transparent rather than displaying only the final color.

---

# How to Use It

The indicator is primarily intended as a **confirmation and market-context tool**.

For example, when analyzing a Nasdaq-related market, a trader may compare the current directional setup with the technology leadership state.

A bullish market setup occurring while technology is leading represents a different relative-market environment from the same setup occurring while technology is lagging.

Similarly, a bearish setup occurring while technology leadership is weakening may provide different contextual information from one occurring during strong technology leadership.

The indicator does not determine whether a trade should be entered. Entry, exit, risk management, market structure, liquidity, volatility, news conditions, and other factors remain separate trading decisions.

---

# Alerts

Three state-change alerts are available:

* Technology leadership becomes positive
* Technology leadership becomes negative
* Leadership becomes mixed

Alerts trigger when the composite state transitions into the corresponding condition.

---

# Repainting / Realtime Behavior

The indicator is designed without future-data references.

All external symbol requests use `lookahead_off`, and the script does not reference future bars or negative offsets.

However, values on the **currently forming realtime bar can change until that bar closes**, because the underlying markets and market internals are still updating.

Historical completed bars represent the final calculated state for those completed chart bars.

Users who require confirmed information should therefore evaluate the state after the relevant bar has closed.

---

# Data Availability

The indicator depends on external TradingView symbols.

Price mode requires valid data for the selected Price Leader and Price Benchmark.

Volume Pressure mode requires valid data for the selected market-internal symbols.

Availability of individual symbols can vary depending on TradingView data access, exchange coverage, account configuration, or symbol availability.

If the required data is unavailable, the indicator reports that state rather than attempting to substitute another source automatically.

---

# Originality

Tech Leadership Map combines two distinct approaches to relative-market analysis inside one standardized leadership framework.

Rather than displaying QQQ/SPY relative strength or market internals as isolated raw series, the indicator evaluates several independent characteristics of leadership and converts them into a transparent four-vote Composite Score.

The Price model evaluates:

* session-relative performance
* relative-strength trend
* relative momentum
* correlation-based confirmation

The Volume Pressure model independently evaluates:

* normalized internal pressure
* smoothed pressure leadership
* internal momentum
* pressure impulse

Both engines produce the same standardized leadership states, allowing users to compare price-based leadership with non-price market-internal participation using a consistent visual framework.

The complete Pine Script source code is published openly so users can inspect the calculations and understand exactly how each state is derived.

---

## Important Notes

This indicator is an analytical tool and is not intended to provide investment advice or guarantee future market performance.

Leadership describes a relative condition between the selected markets or market internals. It should not be interpreted as a prediction that the charted instrument must rise or fall.

Users should evaluate the indicator together with their own analysis, trading methodology, and risk-management process.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Tech Leadership Map [Herman]
//
// Two selectable leadership engines:
//
// 1) PRICE
//    QQQ vs SPY relative price leadership.
//    Uses performance from RTH open, relative-strength ratio slope,
//    short-term momentum gap, and correlation-break confirmation.
//
// 2) VOLUME PRESSURE
//    Uses market-internal net up-volume minus down-volume.
//    Default: NASDAQ USI:VOLDQ vs broad-market/NYSE USI:VOLD.
//    This mode does NOT use QQQ/SPY prices.
//
// IMPORTANT:
// VOLDQ is a NASDAQ internal and VOLD is a broad-market/NYSE internal.
// They are not literal constituent-by-constituent QQQ vs SPY universes.
// Both internal symbols are therefore user-editable.
//
// Anti-repaint design:
// - All request.security() calls use lookahead_off.
// - No future bars or negative offsets are referenced.
// - Current realtime-bar state can change while that bar is still forming.
// - Historical values represent the final state of completed chart bars.
//
// Table note:
// TABLE_SECTION_LIGHT below is deliberately separated from c_dhdr so the
// light-theme section-header shade can be changed manually in code without
// touching the rest of the Herman Trading palette.

//@version=6
indicator("Tech Leadership Map+ [Herman]", overlay = true)

// ══════════════════════════════════════════════════════════════════════════════
// INPUT GROUPS
// ══════════════════════════════════════════════════════════════════════════════

string G_SOURCE  = "Leadership Source"
string G_SYMBOLS = "Symbols"
string G_ENGINE  = "Engine"
string G_SESSION = "Session"
string G_VISUALS = "Visuals"
string G_TABLE   = "Statistics Table"

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

sourceMode = input.string(
     "Price",
     "Source",
     options = ["Price", "Volume Pressure"],
     tooltip = "Price compares QQQ vs SPY price leadership. Volume Pressure compares net up/down-volume internals without using QQQ/SPY prices.",
     group = G_SOURCE)

// Price source.
qqqSymbol = input.symbol("NASDAQ:QQQ", "Price Leader", group = G_SYMBOLS)
spySymbol = input.symbol("AMEX:SPY", "Price Benchmark", group = G_SYMBOLS)

// Non-price market-internal sources.
volumeLeaderSymbol = input.symbol(
     "USI:VOLDQ",
     "Volume Leader Internal",
     tooltip = "Default: NASDAQ up-volume minus down-volume.",
     group = G_SYMBOLS)

volumeBenchmarkSymbol = input.symbol(
     "USI:VOLD",
     "Volume Benchmark Internal",
     tooltip = "Default: broad-market / NYSE up-volume minus down-volume.",
     group = G_SYMBOLS)

internalNormLen = input.int(
     50,
     "Internal Normalization Length",
     minval = 10,
     maxval = 250,
     tooltip = "Normalizes internal series with different raw scales before comparing them. Used only by Volume Pressure.",
     group = G_ENGINE)

internalFastLen = input.int(
     3,
     "Internal Fast Length",
     minval = 1,
     maxval = 20,
     tooltip = "Short smoothing used by non-price leadership engines.",
     group = G_ENGINE)

internalSlowLen = input.int(
     10,
     "Internal Slow Length",
     minval = 3,
     maxval = 50,
     tooltip = "Slow baseline used to measure non-price internal impulse.",
     group = G_ENGINE)

internalMomLen = input.int(
     3,
     "Internal Momentum Length",
     minval = 1,
     maxval = 20,
     tooltip = "Lookback used to compare changes in normalized internals.",
     group = G_ENGINE)

rthSession  = input.session("0930-1600", "US RTH", group = G_SESSION)
showRthOnly = input.bool(true, "Show Dots Only During US RTH", group = G_SESSION)

showDots  = input.bool(true, "Leadership Dots", group = G_VISUALS)
dotWidth  = input.int(3, "Dot Size", minval = 1, maxval = 6, group = G_VISUALS)
colorBars = input.bool(true, "Color Chart Bars", group = G_VISUALS)

bullColor    = input.color(color.rgb(0, 255, 55), "Leading Color", group = G_VISUALS)
neutralColor = input.color(color.rgb(255, 235, 0), "Mixed Color", group = G_VISUALS)
bearColor    = input.color(color.rgb(255, 25, 25), "Lagging Color", group = G_VISUALS)

showTable  = input.bool(true, "Show Table", group = G_TABLE)
tableTheme = input.string("Light", "Theme", options = ["Dark", "Light"], group = G_TABLE)
tableSize  = input.string("small", "Size",
     options = ["tiny", "small", "normal", "large"], group = G_TABLE)
tablePos   = input.string(position.top_right, "Position",
     options = [position.top_right, position.bottom_right,
                position.top_left, position.bottom_left], group = G_TABLE)

// ══════════════════════════════════════════════════════════════════════════════
// TABLE PALETTE
// ══════════════════════════════════════════════════════════════════════════════

var color c_green = na, var color c_red  = na
var color c_nbg   = na, var color c_ntxt = na
var color c_hdr   = na, var color c_dhdr = na
var color c_sep   = na

if tableTheme == "Dark"
    c_green := #29a071, c_red  := #e54b4b
    c_nbg   := #2a2e39, c_ntxt := #e0e0e0
    c_hdr   := #3c415e, c_dhdr := #525a81
    c_sep   := #454955
else
    c_green := #29a071, c_red  := #e54b4b
    c_nbg   := #f7f7f7, c_ntxt := #1e2025
    c_hdr   := #e5eef7, c_dhdr := #dfe2f1
    c_sep   := #e1e4e6

color nbg2 = color.new(c_nbg, 50)

// MANUAL TABLE SECTION COLOR:
// Change only this hex if you want a different LIGHT section-header shade.
color TABLE_SECTION_LIGHT = #f0f3f6
color tableSectionBg = tableTheme == "Dark" ? c_dhdr : TABLE_SECTION_LIGHT

// ══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════

font_sz(sz) =>
    switch sz
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        =>           size.small

f_voteText(int v) =>
    v > 0 ? "+1 LEADER" : v < 0 ? "-1 BENCH" : "0"

f_voteColor(int v) =>
    v > 0 ? c_green : v < 0 ? c_red : c_ntxt

f_signVote(float x) =>
    na(x) ? 0 : x > 0 ? 1 : x < 0 ? -1 : 0

f_normInternal(float src, int len) =>
    float scale = ta.ema(math.abs(src), len)
    not na(src) and not na(scale) and scale > 0 ? src / scale : na

// ══════════════════════════════════════════════════════════════════════════════
// FROZEN PRICE ENGINE CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════

int   RATIO_LEN     = 14
int   MOM_LEN       = 5
int   CORR_LEN      = 20
float CORR_BREAK    = 0.92
int   SCORE_TRIGGER = 2

// ══════════════════════════════════════════════════════════════════════════════
// SYNCHRONIZED DATA
// ══════════════════════════════════════════════════════════════════════════════

[qOpen, qClose] = request.security(
     qqqSymbol,
     timeframe.period,
     [open, close],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true)

[sOpen, sClose] = request.security(
     spySymbol,
     timeframe.period,
     [open, close],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true)

float volumeLeader = request.security(
     volumeLeaderSymbol,
     timeframe.period,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true)

float volumeBenchmark = request.security(
     volumeBenchmarkSymbol,
     timeframe.period,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true)

// ══════════════════════════════════════════════════════════════════════════════
// SESSION STATE
// ══════════════════════════════════════════════════════════════════════════════

bool inRth  = not na(time(timeframe.period, rthSession, "America/New_York"))
bool newRth = inRth and not inRth[1]

var float qRthOpen = na
var float sRthOpen = na

if newRth
    qRthOpen := qOpen
    sRthOpen := sOpen

// ══════════════════════════════════════════════════════════════════════════════
// PRICE ENGINE
// ══════════════════════════════════════════════════════════════════════════════

// Vote 1 — relative performance from RTH open.
float qFromOpen = not na(qRthOpen) ? 100.0 * (qClose / qRthOpen - 1.0) : na
float sFromOpen = not na(sRthOpen) ? 100.0 * (sClose / sRthOpen - 1.0) : na
float openSpread = qFromOpen - sFromOpen
int priceVote1 = f_signVote(openSpread)

// Vote 2 — QQQ/SPY relative-strength ratio slope.
float rsRatio     = qClose / sClose
float logRatio    = math.log(rsRatio)
float ratioLrNow  = ta.linreg(logRatio, RATIO_LEN, 0)
float ratioLrPrev = ta.linreg(logRatio, RATIO_LEN, 1)
float ratioSlope  = ratioLrNow - ratioLrPrev
int priceVote2 = f_signVote(ratioSlope)

// Vote 3 — short-term momentum gap.
float qRoc = ta.roc(qClose, MOM_LEN)
float sRoc = ta.roc(sClose, MOM_LEN)
float momentumGap = qRoc - sRoc
int priceVote3 = f_signVote(momentumGap)

// Vote 4 — correlation break / pull-away.
float qRet = math.log(qClose / qClose[1])
float sRet = math.log(sClose / sClose[1])
float corr = ta.correlation(qRet, sRet, CORR_LEN)
bool corrBreak = not na(corr) and corr < CORR_BREAK
int priceVote4 = corrBreak ? priceVote3 : 0

int priceScore = priceVote1 + priceVote2 + priceVote3 + priceVote4

// ══════════════════════════════════════════════════════════════════════════════
// NON-PRICE INTERNAL ENGINE
// ══════════════════════════════════════════════════════════════════════════════

// Select the raw market-internal pair.
float internalLeader = sourceMode == "Volume Pressure" ? volumeLeader : na
float internalBenchmark = sourceMode == "Volume Pressure" ? volumeBenchmark : na

// Raw values have very different scales between NASDAQ and broad-market
// internals. Normalize each independently before comparing leadership.
float leaderNorm = f_normInternal(internalLeader, internalNormLen)
float benchNorm  = f_normInternal(internalBenchmark, internalNormLen)
float internalSpread = leaderNorm - benchNorm

// Vote 1 — current normalized internal advantage.
int internalVote1 = f_signVote(internalSpread)

// Vote 2 — fast smoothed leadership.
float leaderFast = ta.ema(leaderNorm, internalFastLen)
float benchFast  = ta.ema(benchNorm, internalFastLen)
int internalVote2 = f_signVote(leaderFast - benchFast)

// Vote 3 — internal momentum advantage.
float leaderMom = ta.change(leaderNorm, internalMomLen)
float benchMom  = ta.change(benchNorm, internalMomLen)
int internalVote3 = f_signVote(leaderMom - benchMom)

// Vote 4 — impulse vs each market's slower baseline.
float leaderSlow = ta.ema(leaderNorm, internalSlowLen)
float benchSlow  = ta.ema(benchNorm, internalSlowLen)
float leaderImpulse = leaderNorm - leaderSlow
float benchImpulse  = benchNorm - benchSlow
int internalVote4 = f_signVote(leaderImpulse - benchImpulse)

int internalScore = internalVote1 + internalVote2 + internalVote3 + internalVote4

// ══════════════════════════════════════════════════════════════════════════════
// ACTIVE ENGINE
// ══════════════════════════════════════════════════════════════════════════════

bool usingPrice = sourceMode == "Price"

int vote1 = usingPrice ? priceVote1 : internalVote1
int vote2 = usingPrice ? priceVote2 : internalVote2
int vote3 = usingPrice ? priceVote3 : internalVote3
int vote4 = usingPrice ? priceVote4 : internalVote4

int score = usingPrice ? priceScore : internalScore

bool hasPriceData = not na(qClose) and not na(sClose)
bool hasInternalData = not na(internalLeader) and not na(internalBenchmark) and
     not na(leaderNorm) and not na(benchNorm)

bool hasData = usingPrice ? hasPriceData : hasInternalData

int state =
     not hasData ? 0 :
     score >= SCORE_TRIGGER ? 1 :
     score <= -SCORE_TRIGGER ? -1 :
     0

color stateColor =
     state == 1 ? bullColor :
     state == -1 ? bearColor :
     neutralColor

bool allowed = not showRthOnly or inRth

// ══════════════════════════════════════════════════════════════════════════════
// CHART VISUALS
// ══════════════════════════════════════════════════════════════════════════════

plot(
     showDots and allowed and hasData ? open : na,
     "Leadership Dot",
     color = stateColor,
     style = plot.style_circles,
     linewidth = dotWidth)

barcolor(colorBars and allowed and hasData ? stateColor : na)

// ══════════════════════════════════════════════════════════════════════════════
// TABLE TEXT
// ══════════════════════════════════════════════════════════════════════════════

string vote1Label = usingPrice ? "From RTH Open" : "Pressure Level"
string vote2Label = usingPrice ? "Ratio Slope" : "Fast Pressure"
string vote3Label = usingPrice ? "5-Bar Momentum" : "Pressure Momentum"
string vote4Label = usingPrice ? "Correlation Break" : "Pressure Impulse"

// ══════════════════════════════════════════════════════════════════════════════
// STATISTICS TABLE
// ══════════════════════════════════════════════════════════════════════════════

var table tbl = table.new(
     tablePos,
     2,
     14,
     bgcolor = c_nbg,
     frame_color = c_sep,
     frame_width = 1,
     border_color = c_sep)

if barstate.islast
    if showTable
        int r = 0
        fsz = font_sz(tableSize)

        string stateText =
             not hasData ? "DATA UNAVAILABLE" :
             state == 1 ? "TECH LEADING" :
             state == -1 ? "TECH LAGGING" :
             "NO CLEAR EDGE"

        string scoreText =
             not hasData ? "n/a" :
             score > 0 ? "+" + str.tostring(score) :
             str.tostring(score)

        color stateTextColor =
             not hasData ? c_ntxt :
             state == 1 ? c_green :
             state == -1 ? c_red :
             c_ntxt

        // TITLE
        table.cell(tbl, 0, r, "Tech Leadership Map  [Herman]",
             text_color = c_ntxt, bgcolor = c_hdr, text_size = fsz)
        table.cell(tbl, 1, r, "",
             text_color = c_ntxt, bgcolor = c_hdr), r += 1

        // SECTION HEADER
        table.cell(tbl, 0, r, "Leadership",
             text_color = c_ntxt, bgcolor = tableSectionBg, text_size = fsz)
        table.cell(tbl, 1, r, "",
             bgcolor = tableSectionBg), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, "Source",
             bgcolor = nbg2, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r, sourceMode,
             bgcolor = nbg2, text_color = c_ntxt, text_size = fsz), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, "State",
             bgcolor = c_nbg, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r, stateText,
             bgcolor = c_nbg, text_color = stateTextColor, text_size = fsz), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, "Composite Score",
             bgcolor = nbg2, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r, scoreText + (hasData ? " / 4" : ""),
             bgcolor = nbg2, text_color = stateTextColor, text_size = fsz), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, vote1Label,
             bgcolor = c_nbg, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r, hasData ? f_voteText(vote1) : "n/a",
             bgcolor = c_nbg, text_color = hasData ? f_voteColor(vote1) : c_ntxt, text_size = fsz), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, vote2Label,
             bgcolor = nbg2, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r, hasData ? f_voteText(vote2) : "n/a",
             bgcolor = nbg2, text_color = hasData ? f_voteColor(vote2) : c_ntxt, text_size = fsz), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, vote3Label,
             bgcolor = c_nbg, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r, hasData ? f_voteText(vote3) : "n/a",
             bgcolor = c_nbg, text_color = hasData ? f_voteColor(vote3) : c_ntxt, text_size = fsz), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, vote4Label,
             bgcolor = nbg2, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r,
             hasData ? (usingPrice and not corrBreak ? "NO" : f_voteText(vote4)) : "n/a",
             bgcolor = nbg2,
             text_color = hasData ? (usingPrice and not corrBreak ? c_ntxt : f_voteColor(vote4)) : c_ntxt,
             text_size = fsz), r += 1

        // DATA ROW
        string detailLabel =
             usingPrice ? "Correlation" :
             "Normalized Gap"

        string detailValue =
             not hasData ? "n/a" :
             usingPrice ? (na(corr) ? "n/a" : str.tostring(corr, "#.###")) :
             str.tostring(internalSpread, "#.###")

        table.cell(tbl, 0, r, detailLabel,
             bgcolor = c_nbg, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r, detailValue,
             bgcolor = c_nbg, text_color = c_ntxt, text_size = fsz), r += 1

        // SECTION HEADER
        table.cell(tbl, 0, r, "Color Guide",
             text_color = c_ntxt, bgcolor = tableSectionBg, text_size = fsz)
        table.cell(tbl, 1, r, "",
             bgcolor = tableSectionBg), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, "GREEN",
             bgcolor = nbg2, text_color = c_green, text_size = fsz)
        table.cell(tbl, 1, r, "Tech Leading — Strong NAS100",
             bgcolor = nbg2, text_color = c_ntxt, text_size = fsz), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, "YELLOW",
             bgcolor = c_nbg, text_color = c_ntxt, text_size = fsz)
        table.cell(tbl, 1, r, "Mixed — No Clear Edge",
             bgcolor = c_nbg, text_color = c_ntxt, text_size = fsz), r += 1

        // DATA ROW
        table.cell(tbl, 0, r, "RED",
             bgcolor = nbg2, text_color = c_red, text_size = fsz)
        table.cell(tbl, 1, r, "Tech Lagging — Strong SP500",
             bgcolor = nbg2, text_color = c_ntxt, text_size = fsz)

    else
        table.clear(tbl, 0, 0, 1, 13)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

bool techTakesLead = hasData and state == 1 and state[1] != 1
bool techLosesLead = hasData and state == -1 and state[1] != -1
bool mixedNow      = hasData and state == 0 and state[1] != 0

alertcondition(
     techTakesLead,
     "Tech leadership bullish",
     "Tech leadership is stronger than the benchmark — avoid / de-prioritize shorts.")

alertcondition(
     techLosesLead,
     "Tech leadership bearish",
     "Tech leadership is weaker than the benchmark — avoid / de-prioritize longs.")

alertcondition(
     mixedNow,
     "Tech leadership mixed",
     "Tech leadership is mixed — no clear relative edge.")
````
