# Helios Multi-Session ORB / IB + VWAP + ATR

- url: https://www.tradingview.com/script/lV65gdOg-Helios-Multi-Session-ORB-IB-VWAP-ATR/
- type: indicator
- pine_id: PUB;0a7c3c56ca4f4cd081703e10057622c9
- version: 1.0

## Description

# Helios — Multi-Session ORB / IB + VWAP + ATR

**Helios** combines multi-session Opening Ranges (ORB), Initial Balance (IB), session-anchored VWAPs, standard deviation bands, and an ATR volatility dashboard into one customizable indicator.

Designed for intraday traders, Helios provides a clean way to monitor key session price levels, evaluate price relative to volume-weighted averages, and assess current market volatility without overcrowding the chart.

## Key Features

**1. Multi-Session Opening Ranges (ORB) & Initial Balance (IB)**

Automatically plots the high and low of opening ranges across 14 configurable trading sessions and market events.

Supported sessions include:

- **Asia:** Globex, Sydney, Tokyo, and China Cash Open
- **Europe:** Frankfurt, London, and London Funds
- **United States:** Dealer Positioning, US Economic Data, NY Momentum, NYSE Open, Post-Lunch, and Power Hour
- **Initial Balance:** New York Initial Balance (IB)

Each session supports independently selectable **5, 15, 30, or 60-minute opening ranges**.

Opening ranges are calculated using 1-minute data for greater precision, even when viewing higher intraday timeframes.

Ranges become visible only after their formation window completes, preventing unfinished ranges from being displayed as established levels.

**2. Intelligent Range Extensions**

Helios keeps the chart organized by automatically managing historical and active opening ranges.

- The most recently completed opening range extends forward with price.
- Previous ranges stop extending when the next enabled opening range appears.
- Historical ranges remain visible for context.
- Optional formation boxes highlight each opening range.
- Customizable high, low, midpoint, and session labels.
- Optional cutoff at the 16:00 New York close.

This makes it easier to identify potential support, resistance, breakout, and rejection levels throughout the trading day.

**3. Dual Session-Anchored VWAP**

Helios includes two independently configurable Volume Weighted Average Prices:

- **Overnight VWAP:** Anchored at 18:00 New York time.
- **Regular Trading Hours VWAP:** Anchored at 09:30 New York time.

The Overnight VWAP can optionally continue through the regular session until 16:00 ET.

Both VWAPs support configurable standard deviation bands:

- ±1σ
- ±2σ
- ±3σ

Optional shading provides a visual representation of price dispersion around each VWAP.

These levels can help traders evaluate intraday price positioning, potential mean-reversion areas, and momentum continuation.

**4. ATR Volatility Dashboard**

An integrated Average True Range (ATR) dashboard provides a quick overview of current market volatility.

Volatility is classified into four regimes:

- **Low:** Relatively compressed price movement
- **Normal:** Typical volatility conditions
- **Elevated:** Increased volatility and larger price fluctuations
- **Extreme:** Exceptionally high volatility conditions

The dashboard supports automatic instrument-specific thresholds for NQ/MNQ, ES/MES, YM/MYM, and GC/MGC, along with supported indices and CFDs.

Additional features include:

- Custom ATR periods
- Automatic or manual volatility thresholds
- Color-coded volatility regimes
- Configurable dashboard position
- Simple, Standard, and Detailed display modes
- Futures contract dollar-per-point and ATR-based dollar-range information

The ATR dashboard is informational only and does not alter the opening ranges or generate trading signals.

## How to Use Helios

**Opening Range Breakouts:** Identify potential directional opportunities when price breaks above or below a completed session's opening range.

**VWAP Confluence:** Evaluate whether opening range breakouts align with the current session's VWAP positioning.

**Mean Reversion:** Monitor reactions near VWAP standard deviation bands and established session highs or lows.

**Volatility Awareness:** Use the ATR dashboard to contextualize price movement and adjust risk management to prevailing volatility conditions.

**Cross-Session Analysis:** Compare price reactions around opening ranges established during Asian, European, and US trading hours.

## Customization

All sessions can be individually enabled or disabled. Traders can customize range durations, line extensions, colors, labels, formation boxes, VWAPs, standard deviation bands, and ATR display settings to suit their preferred chart layout.

## Important Notes

- This is a charting and market-analysis indicator, not an automated trading strategy.
- Helios does not automatically execute trades or generate buy/sell signals.
- Opening ranges use available 1-minute intrabar data, subject to TradingView's historical data limits and the selected chart timeframe.
- VWAP calculations depend on the instrument's available volume data.
- Session scheduling uses the relevant market's local time zone, accounting for applicable daylight saving changes.

**Helios is built around three core elements: session structure, volume-weighted price positioning, and volatility.**

The goal is to provide traders with a streamlined view of important intraday reference levels while keeping price action at the center of every decision.

*Disclaimer: This indicator is provided for educational and informational purposes only. It does not constitute financial advice. Trading involves risk, and no indicator guarantees profitable results.*

---

Courtesy of David

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CatsEatWiFi

//@version=6
indicator("Helios Multi-Session Opening Range", shorttitle="Helios ORB", overlay=true,
     max_lines_count=120, max_labels_count=60, max_boxes_count=30,
     dynamic_requests=true)

// =============================================================================
// HELIOS MULTI-SESSION OPENING RANGE
//
// Visual/lifecycle behaviour follows the clean Helios/legacy ORB presentation:
//
// • One selected OR duration per session: 5m / 15m / 30m / 60m.
// • An ORB is invisible while it forms and appears only once its window has
//   elapsed (e.g. the NYSE 30m ORB appears at 10:00 NY).
// • The most recently completed ORB is the live/current ORB.
// • Current ORB lines follow price to the right by the selected extension.
// • When the NEXT enabled ORB appears, every older live ORB is PINNED at that
//   moment. Nothing uses extend.right.
// • The range box exists only over the actual ORB formation window.
// • Helios colours: blue high, purple low, white midpoint (NY IB has no midpoint).
// • Only the current ORB carries right-edge labels.
//
// ORB ranges are built from 1-minute data so a 5m ORB stays a true 5m range
// when the chart itself is on a higher intraday timeframe.
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// Master / display
// ─────────────────────────────────────────────────────────────────────────────
string G_MASTER = "Helios ORB"
bool enabled = input.bool(true, "Enable Opening Ranges", group=G_MASTER)
int extendBars = input.int(30, "Current ORB Right Extension (chart bars)",
     minval=0, maxval=250, group=G_MASTER,
     tooltip="Only the newest ORB extends beyond the current bar. Older ORBs stop exactly when the next enabled ORB begins.")
bool stopAllOrbsAtEod = input.bool(true, "Stop All ORBs at NY 16:00", group=G_MASTER,
     tooltip="Stops range formation and live lines at 16:00 New York time. Sessions starting after 16:00 continue through the following day close.")

string G_DISPLAY = "Display"
bool showRangeBox = input.bool(true, "ORB Formation Box", group=G_DISPLAY)
bool showMid = input.bool(false, "Midpoint", group=G_DISPLAY)
bool showLabels = input.bool(true, "Current ORB Labels", group=G_DISPLAY)
int boxTransparency = input.int(90, "Box Transparency", minval=70, maxval=100, group=G_DISPLAY)
int lineWidth = input.int(1, "High / Low Width", minval=1, maxval=4, group=G_DISPLAY)

string G_COLOUR = "Colours"
color highColor = input.color(color.rgb(106, 183, 255), "High", group=G_COLOUR)
color lowColor  = input.color(color.rgb(184, 155, 239), "Low", group=G_COLOUR)
color midColor  = input.color(color.rgb(245, 245, 245), "Mid", group=G_COLOUR)
color nyIbHighColor = input.color(color.rgb(106, 183, 255), "NY IB High", group=G_COLOUR)
color nyIbLowColor = input.color(color.rgb(184, 155, 239), "NY IB Low", group=G_COLOUR)

// ─────────────────────────────────────────────────────────────────────────────
// Optional ATR display — ported from the legacy BannedAirship ORB
// Same coloured-value visual treatment, recoloured to the Helios palette.
// This is DISPLAY ONLY: it does not filter, block or alter any ORB.
// ─────────────────────────────────────────────────────────────────────────────
string G_ATR = "ATR Display"
bool showAtrDisplay = input.bool(true, "Show ATR Display", group=G_ATR)
string atrDisplayDetail = input.string("Detailed", "Detail",
     options=["Simple", "Standard", "Detailed"], group=G_ATR)
string atrPositionInput = input.string("Top Right", "Position",
     options=["Top Left", "Top Center", "Top Right",
              "Middle Left", "Middle Center", "Middle Right",
              "Bottom Left", "Bottom Center", "Bottom Right"], group=G_ATR)
int atrPeriodDisplay = input.int(14, "ATR Period", minval=1, group=G_ATR)
bool atrAutoCalibrate = input.bool(true, "Auto-Calibrate Thresholds", group=G_ATR,
     tooltip="Uses the legacy instrument-specific ATR regime thresholds for NQ, ES/SPX, YM and Gold. Other symbols use the legacy default set.")

// Manual thresholds are used only when Auto-Calibrate is OFF.
float atrManualNormalOn = input.float(7.00, "Manual: Normal ≥", step=0.25, group=G_ATR)
float atrManualElevatedOn = input.float(15.00, "Manual: Elevated ≥", step=0.25, group=G_ATR)
float atrManualExtremeOn = input.float(25.00, "Manual: Extreme ≥", step=0.25, group=G_ATR)
float atrManualLowBack = input.float(5.25, "Manual: Back to Low ≤", step=0.25, group=G_ATR)
float atrManualNormalBack = input.float(13.00, "Manual: Back to Normal ≤", step=0.25, group=G_ATR)
float atrManualElevatedBack = input.float(22.50, "Manual: Back to Elevated ≤", step=0.25, group=G_ATR)

// Helios regime palette.
// Low = muted slate, Normal = Helios blue, Elevated = Helios purple,
// Extreme = Helios amber. The entire ATR value cell changes colour exactly
// like the old display.
color atrLowColor = input.color(color.rgb(92, 104, 120), "Low Vol", inline="ATRC1", group=G_ATR)
color atrNormalColor = input.color(color.rgb(106, 183, 255), "Normal", inline="ATRC1", group=G_ATR)
color atrElevatedColor = input.color(color.rgb(184, 155, 239), "Elevated", inline="ATRC2", group=G_ATR)
color atrExtremeColor = input.color(color.rgb(232, 170, 74), "Extreme", inline="ATRC2", group=G_ATR)
int atrColorTransparency = input.int(12, "Regime Fill Transparency",
     minval=0, maxval=80, group=G_ATR)

// ─────────────────────────────────────────────────────────────────────────────
// Session VWAPs
// ─────────────────────────────────────────────────────────────────────────────
string G_VWAP_ON = "VWAP — Overnight 18:00 ET"
bool showOvernightVwap = input.bool(true, "Show Overnight VWAP", group=G_VWAP_ON)
bool carryOvernightVwap = input.bool(false, "Carry Through RTH to 16:00",
     group=G_VWAP_ON,
     tooltip="OFF: the 18:00 anchored VWAP stops at 09:30 ET. ON: the same anchored VWAP continues calculating through 16:00 ET.")
color overnightVwapColor = input.color(color.rgb(184, 155, 239), "Colour", group=G_VWAP_ON)
int overnightVwapWidth = input.int(2, "VWAP Width", minval=1, maxval=4, group=G_VWAP_ON)

string G_VWAP_RTH = "VWAP — RTH 09:30 ET"
bool showRthVwap = input.bool(true, "Show RTH VWAP", group=G_VWAP_RTH)
color rthVwapColor = input.color(color.rgb(106, 183, 255), "Colour", group=G_VWAP_RTH)
int rthVwapWidth = input.int(2, "VWAP Width", minval=1, maxval=4, group=G_VWAP_RTH)

string G_VWAP_BANDS = "VWAP — Bands"
bool showVwapBand1 = input.bool(true, "±1σ", inline="VB", group=G_VWAP_BANDS)
bool showVwapBand2 = input.bool(false, "±2σ", inline="VB", group=G_VWAP_BANDS)
bool showVwapBand3 = input.bool(false, "±3σ", inline="VB", group=G_VWAP_BANDS)
bool shadeVwapBands = input.bool(false, "Subtle Band Shading", group=G_VWAP_BANDS)

// ─────────────────────────────────────────────────────────────────────────────
// Session controls — one Helios-style duration selector per ORB
// ─────────────────────────────────────────────────────────────────────────────
string G_EU = "Sessions — Europe"
bool enFrankfurt = input.bool(true, "Frankfurt", inline="FF", group=G_EU)
string durFrankfurt = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="FF", group=G_EU)

bool enLondon = input.bool(true, "London", inline="LDN", group=G_EU)
string durLondon = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="LDN", group=G_EU)

bool enLondonFunds = input.bool(true, "London Funds", inline="LF", group=G_EU)
string durLondonFunds = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="LF", group=G_EU)

string G_US = "Sessions — US"
bool enDealer = input.bool(true, "Dealer Positioning", inline="DLR", group=G_US)
string durDealer = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="DLR", group=G_US)

bool enUSEcon = input.bool(false, "US Economic Data", inline="ECO", group=G_US)
string durUSEcon = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="ECO", group=G_US)

bool enNYMomentum = input.bool(false, "NY Momentum", inline="NYM", group=G_US)
string durNYMomentum = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="NYM", group=G_US)

bool enNYSE = input.bool(true, "NYSE Open", inline="NYSE", group=G_US)
string durNYSE = input.string("30m", "", options=["5m", "15m", "30m", "60m"], inline="NYSE", group=G_US)
bool enNYIB = input.bool(false, "NY Initial Balance", inline="NYIB", group=G_US)
string durNYIB = input.string("60m", "", options=["5m", "15m", "30m", "60m"], inline="NYIB", group=G_US)

bool enPostLunch = input.bool(false, "Post-Lunch", inline="PL", group=G_US)
string durPostLunch = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="PL", group=G_US)

bool enPowerHour = input.bool(false, "Power Hour", inline="PH", group=G_US)
string durPowerHour = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="PH", group=G_US)

string G_ASIA = "Sessions — Globex / Asia"
bool enGlobex = input.bool(false, "Globex Open", inline="GBX", group=G_ASIA)
string durGlobex = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="GBX", group=G_ASIA)

bool enSydney = input.bool(false, "Sydney Open", inline="SYD", group=G_ASIA)
string durSydney = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="SYD", group=G_ASIA)

bool enTokyo = input.bool(true, "Tokyo Open", inline="TKY", group=G_ASIA)
string durTokyo = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="TKY", group=G_ASIA)

bool enChina = input.bool(true, "China Cash Open", inline="CHN", group=G_ASIA)
string durChina = input.string("15m", "", options=["5m", "15m", "30m", "60m"], inline="CHN", group=G_ASIA)

// ─────────────────────────────────────────────────────────────────────────────
// Constants and state
// ─────────────────────────────────────────────────────────────────────────────
const int SESSION_COUNT = 14
const int NY_IB_SESSION = 13
const int MS_MINUTE = 60000

var array<float> orbHigh = array.new<float>(SESSION_COUNT, na)
var array<float> orbLow = array.new<float>(SESSION_COUNT, na)
var array<int> orbStart = array.new<int>(SESSION_COUNT, na)
var array<int> orbFinish = array.new<int>(SESSION_COUNT, na)
var array<bool> orbPinned = array.new<bool>(SESSION_COUNT, true)
// An ORB is tracked silently while it forms and only drawn once complete.
var array<bool> orbRevealed = array.new<bool>(SESSION_COUNT, false)

var array<line> hiLines = array.new<line>(SESSION_COUNT, na)
var array<line> loLines = array.new<line>(SESSION_COUNT, na)
var array<line> midLines = array.new<line>(SESSION_COUNT, na)
var array<box> orbBoxes = array.new<box>(SESSION_COUNT, na)
var array<label> hiLabels = array.new<label>(SESSION_COUNT, na)
var array<label> loLabels = array.new<label>(SESSION_COUNT, na)
var array<label> midLabels = array.new<label>(SESSION_COUNT, na)

var int newestStart = na

// ─────────────────────────────────────────────────────────────────────────────
// Session authority
// ─────────────────────────────────────────────────────────────────────────────
f_enabled(int s) =>
    switch s
        0  => enFrankfurt
        1  => enLondon
        2  => enLondonFunds
        3  => enDealer
        4  => enUSEcon
        5  => enNYMomentum
        6  => enNYSE
        7  => enPostLunch
        8  => enPowerHour
        9  => enGlobex
        10 => enSydney
        11 => enTokyo
        12 => enChina
        13 => enNYIB
        => false

f_name(int s) =>
    switch s
        0  => "Frankfurt"
        1  => "London"
        2  => "London Funds"
        3  => "Dealer"
        4  => "US Econ"
        5  => "NY Momentum"
        6  => "NYSE"
        7  => "Post-Lunch"
        8  => "Power Hour"
        9  => "Globex"
        10 => "Sydney"
        11 => "Tokyo"
        12 => "China"
        13 => "IB"
        => "ORB"

f_timezone(int s) =>
    switch s
        0       => "Europe/Berlin"
        1       => "Europe/London"
        2       => "Europe/London"
        3       => "America/New_York"
        4       => "America/New_York"
        5       => "America/New_York"
        6       => "America/New_York"
        7       => "America/New_York"
        8       => "America/New_York"
        9       => "America/New_York"
        10      => "Australia/Sydney"
        11      => "Asia/Tokyo"
        12      => "Asia/Shanghai"
        13      => "America/New_York"
        => "America/New_York"

f_start_minute(int s) =>
    switch s
        0  => 8 * 60
        1  => 8 * 60
        2  => 8 * 60 + 45
        3  => 7 * 60
        4  => 8 * 60 + 30
        5  => 9 * 60 + 15
        6  => 9 * 60 + 30
        7  => 13 * 60 + 30
        8  => 15 * 60 + 30
        9  => 18 * 60
        10 => 10 * 60
        11 => 9 * 60
        12 => 9 * 60 + 30
        13 => 9 * 60 + 30
        => 0

f_duration_text(int s) =>
    switch s
        0  => durFrankfurt
        1  => durLondon
        2  => durLondonFunds
        3  => durDealer
        4  => durUSEcon
        5  => durNYMomentum
        6  => durNYSE
        7  => durPostLunch
        8  => durPowerHour
        9  => durGlobex
        10 => durSydney
        11 => durTokyo
        12 => durChina
        13 => durNYIB
        => "15m"

f_duration(int s) =>
    string d = f_duration_text(s)
    d == "5m" ? 5 : d == "30m" ? 30 : d == "60m" ? 60 : 15

// ─────────────────────────────────────────────────────────────────────────────
// Object helpers
// ─────────────────────────────────────────────────────────────────────────────
f_delete_session_objects(int s) =>
    line h = array.get(hiLines, s)
    line l = array.get(loLines, s)
    line m = array.get(midLines, s)
    box b = array.get(orbBoxes, s)
    label hl = array.get(hiLabels, s)
    label ll = array.get(loLabels, s)
    label ml = array.get(midLabels, s)

    if not na(h)
        line.delete(h)
    if not na(l)
        line.delete(l)
    if not na(m)
        line.delete(m)
    if not na(b)
        box.delete(b)
    if not na(hl)
        label.delete(hl)
    if not na(ll)
        label.delete(ll)
    if not na(ml)
        label.delete(ml)

    array.set(hiLines, s, na)
    array.set(loLines, s, na)
    array.set(midLines, s, na)
    array.set(orbBoxes, s, na)
    array.set(hiLabels, s, na)
    array.set(loLabels, s, na)
    array.set(midLabels, s, na)

f_delete_labels(int s) =>
    label hl = array.get(hiLabels, s)
    label ll = array.get(loLabels, s)
    label ml = array.get(midLabels, s)
    if not na(hl)
        label.delete(hl)
    if not na(ll)
        label.delete(ll)
    if not na(ml)
        label.delete(ml)
    array.set(hiLabels, s, na)
    array.set(loLabels, s, na)
    array.set(midLabels, s, na)

// Called when session `s` is revealed: every other visible ORB is pinned at
// the reveal time, so the previous ORB stays live right up until the new one
// appears and there is never a stretch with no current ORB on the chart.
f_pin_older_orbs(int s, int pinAt) =>
    int newStart = array.get(orbStart, s)
    for j = 0 to SESSION_COUNT - 1
        int oldStart = array.get(orbStart, j)
        bool pinned = array.get(orbPinned, j)

        // Important for Sydney/Globex and NYSE/IB coincidences: ORBs that start
        // on exactly the same minute are peers and must not pin one another,
        // even when their different durations reveal them at different times.
        if j != s and array.get(orbRevealed, j) and not na(oldStart) and oldStart != newStart
            if not pinned
                line h = array.get(hiLines, j)
                line l = array.get(loLines, j)
                line m = array.get(midLines, j)

                if not na(h)
                    line.set_x2(h, pinAt)
                if not na(l)
                    line.set_x2(l, pinAt)
                if not na(m)
                    line.set_x2(m, pinAt)
                array.set(orbPinned, j, true)

            // Remove labels from older ORBs, including ones pinned at EOD.
            f_delete_labels(j)

// Draw a completed ORB, replacing the prior occurrence of the same session.
f_reveal_orb(int s, int rightEdge) =>
    int started = array.get(orbStart, s)
    int finish = array.get(orbFinish, s)
    float hh = array.get(orbHigh, s)
    float ll = array.get(orbLow, s)

    f_pin_older_orbs(s, finish)
    f_delete_session_objects(s)

    line hLine = line.new(started, hh, rightEdge, hh,
         xloc=xloc.bar_time, extend=extend.none,
         color=s == NY_IB_SESSION ? nyIbHighColor : highColor, width=lineWidth, style=line.style_solid)
    line lLine = line.new(started, ll, rightEdge, ll,
         xloc=xloc.bar_time, extend=extend.none,
         color=s == NY_IB_SESSION ? nyIbLowColor : lowColor, width=lineWidth, style=line.style_solid)
    array.set(hiLines, s, hLine)
    array.set(loLines, s, lLine)

    if showMid and s != NY_IB_SESSION
        float mid = (hh + ll) * 0.5
        line mLine = line.new(started, mid, rightEdge, mid,
             xloc=xloc.bar_time, extend=extend.none,
             color=midColor, width=1, style=line.style_dashed)
        array.set(midLines, s, mLine)

    // Formation box spans exactly the ORB window, never the session.
    if showRangeBox
        box b = box.new(left=started, top=hh, right=finish, bottom=ll,
             xloc=xloc.bar_time,
             border_color=color.new(s == NY_IB_SESSION ? nyIbHighColor : highColor, 80), border_width=1,
             bgcolor=color.new(s == NY_IB_SESSION ? nyIbHighColor : highColor, boxTransparency))
        array.set(orbBoxes, s, b)

    array.set(orbRevealed, s, true)
    array.set(orbPinned, s, false)

// ─────────────────────────────────────────────────────────────────────────────
// Source-bar processor
// ─────────────────────────────────────────────────────────────────────────────
// Global arrays are reference types, so Pine allows their contents to be
// updated inside a function. This only tracks ranges; drawing happens in the
// chart-bar reveal pass below.
f_process_orb_source(int srcTime, float srcHigh, float srcLow, int prevSrcTime) =>
    // Start each session on the first source bar at or after its native-local
    // open. Detecting the crossing (instead of requiring a bar stamped exactly
    // HH:MM:00) keeps the ORB alive when the open minute has no print — thin
    // CFDs, holiday sessions — and still fires exactly once on 30-second charts.
    // A gap that skips the whole formation window produces no ORB at all.
    for s = 0 to SESSION_COUNT - 1
        if f_enabled(s)
            string tz = f_timezone(s)
            int startMinute = f_start_minute(s)
            int openTs = timestamp(tz, year(srcTime, tz), month(srcTime, tz), dayofmonth(srcTime, tz),
                 int(math.floor(startMinute / 60)), startMinute % 60)
            int duration = f_duration(s)
            int finish = openTs + duration * MS_MINUTE
            bool crossedOpen = not na(prevSrcTime) and prevSrcTime < openTs
                 and srcTime >= openTs and srcTime < finish

            if crossedOpen
                // A range still forming at the NY close completes at 16:00.
                int openNyEnd = timestamp("America/New_York", year(openTs, "America/New_York"),
                     month(openTs, "America/New_York"), dayofmonth(openTs, "America/New_York"), 16, 0)
                if stopAllOrbsAtEod and openTs < openNyEnd
                    finish := math.min(finish, openNyEnd)

                // Begin tracking only. The prior occurrence of this session stays
                // on the chart (already pinned) until the new range is complete.
                array.set(orbHigh, s, na)
                array.set(orbLow, s, na)
                array.set(orbStart, s, openTs)
                array.set(orbFinish, s, finish)
                array.set(orbRevealed, s, false)

    // Track every forming ORB independently. Nothing is drawn here.
    for s = 0 to SESSION_COUNT - 1
        if f_enabled(s) and not array.get(orbRevealed, s)
            int started = array.get(orbStart, s)
            int finish = array.get(orbFinish, s)

            if not na(started) and not na(finish) and srcTime >= started and srcTime < finish
                float oldH = array.get(orbHigh, s)
                float oldL = array.get(orbLow, s)
                array.set(orbHigh, s, na(oldH) ? srcHigh : math.max(oldH, srcHigh))
                array.set(orbLow, s, na(oldL) ? srcLow : math.min(oldL, srcLow))

// ─────────────────────────────────────────────────────────────────────────────
// Exact 1-minute source on 1m+ charts; native chart bars below 1m.
// ─────────────────────────────────────────────────────────────────────────────
[t1, tc1, h1, l1, c1, v1] = request.security_lower_tf(
     syminfo.tickerid, "1", [time, time_close, high, low, close, volume],
     ignore_invalid_timeframe=true)

int n = array.size(t1)

// Last source bar fed to the ORB engine, used for open-crossing detection.
var int lastOrbSrcTime = na

if enabled
    if n > 0
        for i = 0 to n - 1
            int srcT = array.get(t1, i)
            f_process_orb_source(srcT, array.get(h1, i), array.get(l1, i), lastOrbSrcTime)
            lastOrbSrcTime := srcT
    else if barstate.isconfirmed and timeframe.in_seconds() <= 60
        // On 30s/sub-minute charts, 1m is not a valid lower timeframe. Use the
        // chart's native bars, which are finer than the requested ORB precision.
        // Coarser chart bars are never used: a 1H bar cannot form a 15m range,
        // so history beyond the intrabar limit simply has no ORBs.
        f_process_orb_source(time, high, low, lastOrbSrcTime)
        lastOrbSrcTime := time

    // Reveal pass, driven by the CHART bar rather than the source bars: an ORB
    // is drawn on the first chart candle that opens at or after its end time,
    // i.e. the instant the candle containing the final minute has closed.
    // NYSE 30m ends 10:00, so on a 1m chart it appears on the 10:00 candle once
    // 09:59 has closed — never on the 09:59 candle itself. This holds the same
    // way on historical bars, in Bar Replay and in realtime, and on any
    // timeframe (a 5m ORB on a 15m chart appears when its 15m candle closes).
    for s = 0 to SESSION_COUNT - 1
        if f_enabled(s) and not array.get(orbRevealed, s)
            int revStart = array.get(orbStart, s)
            int revFinish = array.get(orbFinish, s)
            bool revHasRange = not na(array.get(orbHigh, s))
            if revHasRange and not na(revStart) and not na(revFinish) and time >= revFinish
                f_reveal_orb(s, time_close)
                // The most recently revealed ORB (and its same-start peers) is
                // the current one and carries the labels.
                newestStart := revStart

// ─────────────────────────────────────────────────────────────────────────────
// Right edge of the newest ORB only.
// Older ORBs are frozen when the next ORB is revealed by f_pin_older_orbs().
// ─────────────────────────────────────────────────────────────────────────────
if enabled
    int chartSeconds = int(math.max(1.0, timeframe.in_seconds()))
    int extensionMs = extendBars * chartSeconds * 1000
    int liveRight = time_close + extensionMs
    int nyEndOfDay = timestamp("America/New_York", year(time_close, "America/New_York"),
         month(time_close, "America/New_York"), dayofmonth(time_close, "America/New_York"), 16, 0)

    // Pin every still-live ORB exactly at the NY cash close.
    if stopAllOrbsAtEod and time_close >= nyEndOfDay
        for eodSession = 0 to SESSION_COUNT - 1
            int eodStart = array.get(orbStart, eodSession)
            bool eodPinned = array.get(orbPinned, eodSession)
            if not eodPinned and array.get(orbRevealed, eodSession) and not na(eodStart) and eodStart < nyEndOfDay
                line eodHigh = array.get(hiLines, eodSession)
                line eodLow = array.get(loLines, eodSession)
                line eodMid = array.get(midLines, eodSession)
                if not na(eodHigh)
                    line.set_x2(eodHigh, nyEndOfDay)
                if not na(eodLow)
                    line.set_x2(eodLow, nyEndOfDay)
                if not na(eodMid)
                    line.set_x2(eodMid, nyEndOfDay)
                label eodHighLabel = array.get(hiLabels, eodSession)
                label eodLowLabel = array.get(loLabels, eodSession)
                label eodMidLabel = array.get(midLabels, eodSession)
                if not na(eodHighLabel)
                    label.set_x(eodHighLabel, nyEndOfDay)
                if not na(eodLowLabel)
                    label.set_x(eodLowLabel, nyEndOfDay)
                if not na(eodMidLabel)
                    label.set_x(eodMidLabel, nyEndOfDay)
                array.set(orbPinned, eodSession, true)

    for s = 0 to SESSION_COUNT - 1
        int started = array.get(orbStart, s)
        bool pinned = array.get(orbPinned, s)

        if not pinned and array.get(orbRevealed, s) and not na(started)
            int sessionRight = stopAllOrbsAtEod and started < nyEndOfDay ? math.min(liveRight, nyEndOfDay) : liveRight
            line hLine = array.get(hiLines, s)
            line lLine = array.get(loLines, s)
            line mLine = array.get(midLines, s)

            if not na(hLine)
                line.set_x2(hLine, sessionRight)
            if not na(lLine)
                line.set_x2(lLine, sessionRight)
            if not na(mLine)
                line.set_x2(mLine, sessionRight)

            // Only the latest-starting ORB(s) get labels.
            bool isNewest = not na(newestStart) and started == newestStart

            if showLabels and isNewest
                float hh = array.get(orbHigh, s)
                float ll = array.get(orbLow, s)
                float mm = (hh + ll) * 0.5
                string prefix = f_name(s) + " " + f_duration_text(s)
                string highText = s == NY_IB_SESSION ? "IB High" : prefix + " H"
                string lowText = s == NY_IB_SESSION ? "IB Low" : prefix + " L"

                label hl = array.get(hiLabels, s)
                label lo = array.get(loLabels, s)
                label ml = array.get(midLabels, s)

                if na(hl)
                    hl := label.new(sessionRight, hh, highText,
                         xloc=xloc.bar_time, yloc=yloc.price,
                         style=label.style_label_left,
                         color=color.new(color.black, 100),
                         textcolor=s == NY_IB_SESSION ? nyIbHighColor : highColor, size=size.tiny)
                    array.set(hiLabels, s, hl)
                else
                    label.set_x(hl, sessionRight)
                    label.set_y(hl, hh)
                    label.set_text(hl, highText)

                if na(lo)
                    lo := label.new(sessionRight, ll, lowText,
                         xloc=xloc.bar_time, yloc=yloc.price,
                         style=label.style_label_left,
                         color=color.new(color.black, 100),
                         textcolor=s == NY_IB_SESSION ? nyIbLowColor : lowColor, size=size.tiny)
                    array.set(loLabels, s, lo)
                else
                    label.set_x(lo, sessionRight)
                    label.set_y(lo, ll)
                    label.set_text(lo, lowText)

                if showMid and s != NY_IB_SESSION
                    if na(ml)
                        ml := label.new(sessionRight, mm, prefix + " M",
                             xloc=xloc.bar_time, yloc=yloc.price,
                             style=label.style_label_left,
                             color=color.new(color.black, 100),
                             textcolor=midColor, size=size.tiny)
                        array.set(midLabels, s, ml)
                    else
                        label.set_x(ml, sessionRight)
                        label.set_y(ml, mm)
                        label.set_text(ml, prefix + " M")
            else
                f_delete_labels(s)

// Pine automatically rebuilds objects when indicator inputs change, so no
// separate input-change cleanup path is required.

// =============================================================================
// OPTIONAL ATR DISPLAY / REGIME ENGINE
// Ported from the legacy ORB display. This is intentionally presentation-only.
// =============================================================================

// Legacy instrument family detection.
// Futures match on the exact contract root (NQ1!, NQZ2026 → "NQ"), so stocks
// whose tickers merely contain "ES", "GC" or "YM" are not misclassified.
// CFDs match on the ticker prefix (NAS100USD, US30USD, XAUUSD ...).
bool atrIsFutures = syminfo.type == "futures"
string atrRoot = atrIsFutures ? syminfo.root : ""
string atrTicker = syminfo.ticker

bool atrIsNQFutures = atrRoot == "NQ" or atrRoot == "MNQ"
bool atrIsNQCfd = str.startswith(atrTicker, "NAS100") or str.startswith(atrTicker, "US100") or str.startswith(atrTicker, "USTEC")
bool atrIsNQ = atrIsNQFutures or atrIsNQCfd

bool atrIsESFutures = atrRoot == "ES" or atrRoot == "MES"
bool atrIsSPXIndex = atrTicker == "SPX"
bool atrIsSPXCfd = str.startswith(atrTicker, "US500") or str.startswith(atrTicker, "SPX500") or str.startswith(atrTicker, "SP500")
bool atrIsES = atrIsESFutures or atrIsSPXCfd
bool atrIsSPX = atrIsSPXIndex or atrIsSPXCfd

bool atrIsYMFutures = atrRoot == "YM" or atrRoot == "MYM"
bool atrIsYMCfd = str.startswith(atrTicker, "US30") or str.startswith(atrTicker, "DOWJONES") or str.startswith(atrTicker, "DJ30")
bool atrIsYM = atrIsYMFutures or atrIsYMCfd

bool atrIsGoldFutures = atrRoot == "GC" or atrRoot == "MGC"
bool atrIsGoldCfd = str.startswith(atrTicker, "XAUUSD") or str.startswith(atrTicker, "GOLD")
bool atrIsGold = atrIsGoldFutures or atrIsGoldCfd

string atrInstrumentName = atrIsFutures ? atrRoot : atrTicker
string atrPointValueText = "N/A"
// Any futures contract reports its own $/point, micros included.
float atrDollarPerPoint = atrIsFutures ? syminfo.pointvalue : na

if atrIsNQCfd
    atrInstrumentName := "NAS100"
else if atrIsSPXIndex
    atrInstrumentName := "SPX"
else if atrIsSPXCfd
    atrInstrumentName := "US500"
else if atrIsYMCfd
    atrInstrumentName := "US30"
else if atrIsGoldCfd
    atrInstrumentName := "GOLD"

if not na(atrDollarPerPoint)
    atrPointValueText := "$" + str.tostring(atrDollarPerPoint, "#.##")

float atrValue = ta.atr(atrPeriodDisplay)

// Preserve the legacy display rounding.
float atrRounded = na
if not na(atrValue)
    if atrIsGold
        atrRounded := math.round(atrValue * 10.0) / 10.0
    else if atrIsYM
        atrRounded := math.round(atrValue)
    else
        atrRounded := math.round(atrValue * 4.0) / 4.0

// 4-zone hysteresis thresholds.
float atrNormalOn = na
float atrLowBack = na
float atrElevatedOn = na
float atrNormalBack = na
float atrExtremeOn = na
float atrElevatedBack = na

if atrAutoCalibrate
    if atrIsNQ
        atrNormalOn := 7.00
        atrLowBack := 5.25
        atrElevatedOn := 15.00
        atrNormalBack := 13.00
        atrExtremeOn := 25.00
        atrElevatedBack := 22.50
    else if atrIsGold
        atrNormalOn := 1.00
        atrLowBack := 0.75
        atrElevatedOn := 2.50
        atrNormalBack := 2.10
        atrExtremeOn := 4.50
        atrElevatedBack := 4.00
    else if atrIsES or atrIsSPX
        atrNormalOn := 1.25
        atrLowBack := 1.00
        atrElevatedOn := 2.75
        atrNormalBack := 2.40
        atrExtremeOn := 4.50
        atrElevatedBack := 4.00
    else if atrIsYM
        atrNormalOn := 9.00
        atrLowBack := 7.00
        atrElevatedOn := 20.00
        atrNormalBack := 17.00
        atrExtremeOn := 33.00
        atrElevatedBack := 29.00
    else
        // Legacy default family.
        atrNormalOn := 1.25
        atrLowBack := 1.00
        atrElevatedOn := 2.75
        atrNormalBack := 2.40
        atrExtremeOn := 4.50
        atrElevatedBack := 4.00
else
    atrNormalOn := atrManualNormalOn
    atrLowBack := atrManualLowBack
    atrElevatedOn := atrManualElevatedOn
    atrNormalBack := atrManualNormalBack
    atrExtremeOn := atrManualExtremeOn
    atrElevatedBack := atrManualElevatedBack

// Regimes:
// 0 = LOW, 1 = NORMAL, 2 = ELEVATED, 3 = EXTREME.
var int atrRegime = 1

if not na(atrRounded)
    // Move as many zones as the value justifies in one bar (a LOW → EXTREME
    // spike no longer takes three bars to show), keeping hysteresis downward.
    // Rising transitions.
    while atrRegime < 3 and atrRounded >= (atrRegime == 0 ? atrNormalOn : atrRegime == 1 ? atrElevatedOn : atrExtremeOn)
        atrRegime += 1

    // Falling transitions with hysteresis.
    while atrRegime > 0 and atrRounded <= (atrRegime == 3 ? atrElevatedBack : atrRegime == 2 ? atrNormalBack : atrLowBack)
        atrRegime -= 1

string atrRegimeName =
     atrRegime == 0 ? "LOW" :
     atrRegime == 1 ? "NORMAL" :
     atrRegime == 2 ? "ELEVATED" : "EXTREME"

color atrRegimeColor =
     atrRegime == 0 ? color.new(atrLowColor, atrColorTransparency) :
     atrRegime == 1 ? color.new(atrNormalColor, atrColorTransparency) :
     atrRegime == 2 ? color.new(atrElevatedColor, atrColorTransparency) :
                      color.new(atrExtremeColor, atrColorTransparency)

// Table placement mirrors the old ORB.
atrTablePosition =
     atrPositionInput == "Top Left" ? position.top_left :
     atrPositionInput == "Top Center" ? position.top_center :
     atrPositionInput == "Top Right" ? position.top_right :
     atrPositionInput == "Middle Left" ? position.middle_left :
     atrPositionInput == "Middle Center" ? position.middle_center :
     atrPositionInput == "Middle Right" ? position.middle_right :
     atrPositionInput == "Bottom Left" ? position.bottom_left :
     atrPositionInput == "Bottom Center" ? position.bottom_center :
     position.bottom_right

var table atrTable = table.new(atrTablePosition, 1, 8,
     bgcolor=color.new(color.rgb(15, 18, 24), 5),
     frame_color=color.new(color.rgb(70, 80, 96), 30),
     frame_width=1)

if barstate.islast
    // Clear all rows first so switching detail/visibility never leaves stale text.
    table.clear(atrTable, 0, 0, 0, 7)

    if showAtrDisplay and not na(atrRounded)
        // Same visual hierarchy as the old display:
        // title row + large fully-coloured ATR value cell.
        table.cell(atrTable, 0, 0, "ATR",
             bgcolor=color.rgb(15, 18, 24),
             text_color=color.rgb(235, 240, 248),
             text_size=size.normal)

        table.cell(atrTable, 0, 1, str.tostring(atrRounded, "#.##"),
             bgcolor=atrRegimeColor,
             text_color=color.white,
             text_size=size.huge)

        if atrDisplayDetail != "Simple"
            table.cell(atrTable, 0, 2, "Ticker: " + atrInstrumentName,
                 bgcolor=color.rgb(15, 18, 24),
                 text_color=color.rgb(205, 214, 226),
                 text_size=size.small)

            table.cell(atrTable, 0, 3,
                 "Mode: " + (atrAutoCalibrate ? "AUTO" : "MANUAL"),
                 bgcolor=color.rgb(15, 18, 24),
                 text_color=color.rgb(205, 214, 226),
                 text_size=size.small)

        if atrDisplayDetail == "Detailed"
            table.cell(atrTable, 0, 4, "$/pt: " + atrPointValueText,
                 bgcolor=color.rgb(15, 18, 24),
                 text_color=color.rgb(184, 195, 208),
                 text_size=size.small)

            float atrDollarRange = not na(atrDollarPerPoint) ? atrValue * atrDollarPerPoint : na
            table.cell(atrTable, 0, 5,
                 "Range: " + (not na(atrDollarRange) ? "$" + str.tostring(atrDollarRange, "#") : "N/A"),
                 bgcolor=color.rgb(15, 18, 24),
                 text_color=color.rgb(184, 195, 208),
                 text_size=size.small)

            table.cell(atrTable, 0, 6, "Regime: " + atrRegimeName,
                 bgcolor=color.rgb(15, 18, 24),
                 text_color=atrRegime == 0 ? atrLowColor :
                            atrRegime == 1 ? atrNormalColor :
                            atrRegime == 2 ? atrElevatedColor : atrExtremeColor,
                 text_size=size.small)

            table.cell(atrTable, 0, 7,
                 "Lvl: " + str.tostring(atrNormalOn, "#.##") + " / "
                         + str.tostring(atrElevatedOn, "#.##") + " / "
                         + str.tostring(atrExtremeOn, "#.##"),
                 bgcolor=color.rgb(15, 18, 24),
                 text_color=color.rgb(184, 195, 208),
                 text_size=size.small)

// =============================================================================
// SESSION VWAP ENGINE
//
// Overnight: 18:00 ET anchor -> 09:30 ET, optionally continues -> 16:00 ET.
// RTH:       09:30 ET anchor -> 16:00 ET.
//
// Bands are volume-weighted population standard deviation of HLC3 around each
// anchored VWAP. When usable volume is unavailable, weight falls back to 1 so
// the display still works on instruments such as cash indices.
// =============================================================================
const int VWAP_ON_START = 18 * 60
const int VWAP_RTH_START = 9 * 60 + 30
const int VWAP_RTH_END = 16 * 60

var float onSumW = 0.0
var float onSumWX = 0.0
var float onSumWX2 = 0.0
var float rthSumW = 0.0
var float rthSumWX = 0.0
var float rthSumWX2 = 0.0

var float onVwapSeries = na
var float onSdSeries = na
var float rthVwapSeries = na
var float rthSdSeries = na

// Protect the accumulators from historical/realtime re-processing of the same
// lower-timeframe bar.
var int lastVwapSourceTime = na

f_vwap_add(float sumW, float sumWX, float sumWX2, float px, float vol) =>
    float weight = na(vol) or vol <= 0 ? 1.0 : vol
    float newW = sumW + weight
    float newWX = sumWX + weight * px
    float newWX2 = sumWX2 + weight * px * px
    [newW, newWX, newWX2]

f_vwap_value(float sumW, float sumWX, float sumWX2) =>
    float mean = sumW > 0 ? sumWX / sumW : na
    float variance = sumW > 0 and not na(mean) ? math.max(0.0, sumWX2 / sumW - mean * mean) : na
    float deviation = not na(variance) ? math.sqrt(variance) : na
    [mean, deviation]

// Process one source bar. This function returns updated accumulator values and
// the visible VWAP/SD values after that source bar.
f_process_vwap_bar(
     int srcTime, int prevSrcTime, float srcHigh, float srcLow, float srcClose, float srcVolume,
     float curOnW, float curOnWX, float curOnWX2,
     float curRthW, float curRthWX, float curRthWX2) =>

    // Pine v6 does not allow reassignment of declared function parameters.
    // Work on local copies and return the updated state instead.
    float nextOnW = curOnW
    float nextOnWX = curOnWX
    float nextOnWX2 = curOnWX2
    float nextRthW = curRthW
    float nextRthWX = curRthWX
    float nextRthWX2 = curRthWX2

    int nyMinute = hour(srcTime, "America/New_York") * 60 + minute(srcTime, "America/New_York")
    float px = (srcHigh + srcLow + srcClose) / 3.0

    // Reset on the first source bar at or after each anchor, so a missing
    // 18:00 or 09:30 print can never leave a VWAP accumulating across days.
    int nyYear = year(srcTime, "America/New_York")
    int nyMonth = month(srcTime, "America/New_York")
    int nyDay = dayofmonth(srcTime, "America/New_York")
    int onAnchor = timestamp("America/New_York", nyYear, nyMonth, nyDay, 18, 0)
    int rthAnchor = timestamp("America/New_York", nyYear, nyMonth, nyDay, 9, 30)

    bool onReset = srcTime >= onAnchor and (na(prevSrcTime) or prevSrcTime < onAnchor)
    bool rthReset = srcTime >= rthAnchor and (na(prevSrcTime) or prevSrcTime < rthAnchor)

    if onReset
        nextOnW := 0.0
        nextOnWX := 0.0
        nextOnWX2 := 0.0

    if rthReset
        nextRthW := 0.0
        nextRthWX := 0.0
        nextRthWX2 := 0.0

    int onEndMinute = carryOvernightVwap ? VWAP_RTH_END : VWAP_RTH_START

    // 18:00 -> midnight OR midnight -> selected end.
    bool onActive = nyMinute >= VWAP_ON_START or nyMinute < onEndMinute
    bool rthActive = nyMinute >= VWAP_RTH_START and nyMinute < VWAP_RTH_END

    if onActive
        [nw, nwx, nwx2] = f_vwap_add(nextOnW, nextOnWX, nextOnWX2, px, srcVolume)
        nextOnW := nw
        nextOnWX := nwx
        nextOnWX2 := nwx2

    if rthActive
        [rw, rwx, rwx2] = f_vwap_add(nextRthW, nextRthWX, nextRthWX2, px, srcVolume)
        nextRthW := rw
        nextRthWX := rwx
        nextRthWX2 := rwx2

    [onMean, onDev] = f_vwap_value(nextOnW, nextOnWX, nextOnWX2)
    [rthMean, rthDev] = f_vwap_value(nextRthW, nextRthWX, nextRthWX2)

    float visibleOn = onActive ? onMean : na
    float visibleOnDev = onActive ? onDev : na
    float visibleRth = rthActive ? rthMean : na
    float visibleRthDev = rthActive ? rthDev : na

    [nextOnW, nextOnWX, nextOnWX2, nextRthW, nextRthWX, nextRthWX2, visibleOn, visibleOnDev, visibleRth, visibleRthDev]

// Prefer closed 1-minute intrabars whenever TradingView supplies them.
int vwapIntrabars = array.size(t1)
bool processedVwapSource = false

if vwapIntrabars > 0
    for vi = 0 to vwapIntrabars - 1
        int vt = array.get(t1, vi)

        if na(lastVwapSourceTime) or vt > lastVwapSourceTime
            float vh = array.get(h1, vi)
            float vl = array.get(l1, vi)
            float vc = array.get(c1, vi)
            float vv = array.get(v1, vi)

            [newOnW, newOnWX, newOnWX2, newRthW, newRthWX, newRthWX2, newOnValue, newOnDev, newRthValue, newRthDev] = f_process_vwap_bar(vt, lastVwapSourceTime, vh, vl, vc, vv, onSumW, onSumWX, onSumWX2, rthSumW, rthSumWX, rthSumWX2)

            onSumW := newOnW
            onSumWX := newOnWX
            onSumWX2 := newOnWX2
            rthSumW := newRthW
            rthSumWX := newRthWX
            rthSumWX2 := newRthWX2

            onVwapSeries := newOnValue
            onSdSeries := newOnDev
            rthVwapSeries := newRthValue
            rthSdSeries := newRthDev

            lastVwapSourceTime := vt
            processedVwapSource := true

// On 1m or sub-1m charts security_lower_tf("1") may have no usable intrabars.
// Fall back to the chart bar once it is closed. This also makes 30-second
// charts naturally use their finer native data rather than fabricating minutes.
if not processedVwapSource and vwapIntrabars == 0 and barstate.isconfirmed
    if na(lastVwapSourceTime) or time > lastVwapSourceTime
        [newOnW, newOnWX, newOnWX2, newRthW, newRthWX, newRthWX2, newOnValue, newOnDev, newRthValue, newRthDev] = f_process_vwap_bar(time, lastVwapSourceTime, high, low, close, volume, onSumW, onSumWX, onSumWX2, rthSumW, rthSumWX, rthSumWX2)

        onSumW := newOnW
        onSumWX := newOnWX
        onSumWX2 := newOnWX2
        rthSumW := newRthW
        rthSumWX := newRthWX
        rthSumWX2 := newRthWX2

        onVwapSeries := newOnValue
        onSdSeries := newOnDev
        rthVwapSeries := newRthValue
        rthSdSeries := newRthDev

        lastVwapSourceTime := time

// On chart bars where no new source observation was admitted, visibility still
// needs to respect the current NY clock (for example the exact 09:30/16:00 cut).
int nowNyMinute = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
int currentOnEnd = carryOvernightVwap ? VWAP_RTH_END : VWAP_RTH_START
bool currentOnActive = nowNyMinute >= VWAP_ON_START or nowNyMinute < currentOnEnd
bool currentRthActive = nowNyMinute >= VWAP_RTH_START and nowNyMinute < VWAP_RTH_END

float onV = showOvernightVwap and currentOnActive ? onVwapSeries : na
float onSd = showOvernightVwap and currentOnActive ? onSdSeries : na
float rthV = showRthVwap and currentRthActive ? rthVwapSeries : na
float rthSd = showRthVwap and currentRthActive ? rthSdSeries : na

// Helios visual hierarchy: bold basis, increasingly softer band colours.
color onBand1Color = color.new(overnightVwapColor, 28)
color onBand2Color = color.new(overnightVwapColor, 45)
color onBand3Color = color.new(overnightVwapColor, 62)
color rthBand1Color = color.new(rthVwapColor, 28)
color rthBand2Color = color.new(rthVwapColor, 45)
color rthBand3Color = color.new(rthVwapColor, 62)

pOn = plot(onV, "Overnight VWAP 18:00",
     color=overnightVwapColor, linewidth=overnightVwapWidth, style=plot.style_linebr)
pOn1U = plot(showVwapBand1 ? onV + onSd : na, "ON VWAP +1σ",
     color=onBand1Color, linewidth=1, style=plot.style_linebr)
pOn1L = plot(showVwapBand1 ? onV - onSd : na, "ON VWAP -1σ",
     color=onBand1Color, linewidth=1, style=plot.style_linebr)
pOn2U = plot(showVwapBand2 ? onV + onSd * 2.0 : na, "ON VWAP +2σ",
     color=onBand2Color, linewidth=1, style=plot.style_linebr)
pOn2L = plot(showVwapBand2 ? onV - onSd * 2.0 : na, "ON VWAP -2σ",
     color=onBand2Color, linewidth=1, style=plot.style_linebr)
pOn3U = plot(showVwapBand3 ? onV + onSd * 3.0 : na, "ON VWAP +3σ",
     color=onBand3Color, linewidth=1, style=plot.style_linebr)
pOn3L = plot(showVwapBand3 ? onV - onSd * 3.0 : na, "ON VWAP -3σ",
     color=onBand3Color, linewidth=1, style=plot.style_linebr)

pRth = plot(rthV, "RTH VWAP 09:30",
     color=rthVwapColor, linewidth=rthVwapWidth, style=plot.style_linebr)
pRth1U = plot(showVwapBand1 ? rthV + rthSd : na, "RTH VWAP +1σ",
     color=rthBand1Color, linewidth=1, style=plot.style_linebr)
pRth1L = plot(showVwapBand1 ? rthV - rthSd : na, "RTH VWAP -1σ",
     color=rthBand1Color, linewidth=1, style=plot.style_linebr)
pRth2U = plot(showVwapBand2 ? rthV + rthSd * 2.0 : na, "RTH VWAP +2σ",
     color=rthBand2Color, linewidth=1, style=plot.style_linebr)
pRth2L = plot(showVwapBand2 ? rthV - rthSd * 2.0 : na, "RTH VWAP -2σ",
     color=rthBand2Color, linewidth=1, style=plot.style_linebr)
pRth3U = plot(showVwapBand3 ? rthV + rthSd * 3.0 : na, "RTH VWAP +3σ",
     color=rthBand3Color, linewidth=1, style=plot.style_linebr)
pRth3L = plot(showVwapBand3 ? rthV - rthSd * 3.0 : na, "RTH VWAP -3σ",
     color=rthBand3Color, linewidth=1, style=plot.style_linebr)

// Optional shading stays subtle and follows each session's own Helios colour.
fill(pOn1U, pOn1L,
     color=shadeVwapBands and showOvernightVwap and showVwapBand1
         ? color.new(overnightVwapColor, 94) : na,
     title="ON VWAP ±1σ Fill")
fill(pOn2U, pOn2L,
     color=shadeVwapBands and showOvernightVwap and showVwapBand2
         ? color.new(overnightVwapColor, 96) : na,
     title="ON VWAP ±2σ Fill")
fill(pOn3U, pOn3L,
     color=shadeVwapBands and showOvernightVwap and showVwapBand3
         ? color.new(overnightVwapColor, 97) : na,
     title="ON VWAP ±3σ Fill")

fill(pRth1U, pRth1L,
     color=shadeVwapBands and showRthVwap and showVwapBand1
         ? color.new(rthVwapColor, 94) : na,
     title="RTH VWAP ±1σ Fill")
fill(pRth2U, pRth2L,
     color=shadeVwapBands and showRthVwap and showVwapBand2
         ? color.new(rthVwapColor, 96) : na,
     title="RTH VWAP ±2σ Fill")
fill(pRth3U, pRth3L,
     color=shadeVwapBands and showRthVwap and showVwapBand3
         ? color.new(rthVwapColor, 97) : na,
     title="RTH VWAP ±3σ Fill")
````
