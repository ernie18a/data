# MTF Trend Consensus

- url: https://www.tradingview.com/script/JjBLWXJg-MTF-Trend-Consensus/
- type: indicator
- pine_id: PUB;899f520b081549cea5aebfae60ff2a68
- version: 1.0

## Description

[b]MTF Trend Consensus[/b] condenses the work of flipping between four charts into a single number. It reads EMA direction and ADX strength on the chart timeframe plus up to four automatically-selected higher timeframes, then reports an ADX-weighted agreement score from 0% to 100% so the broader trend context is legible without leaving the current chart.

[b]Why Weight The Vote By ADX[/b]

The obvious way to summarise multi-timeframe trend is a raw majority vote — "3 out of 4 higher timeframes agree". That vote treats a Daily with ADX 15 (barely trending) the same as a Daily with ADX 45 (strongly trending), which is misleading. This indicator therefore uses a weighted vote: each timeframe's contribution to the consensus score is proportional to its own ADX reading, so a timeframe that is genuinely trending carries more weight than one that is merely drifting. The result is that the headline number responds more to where trend strength actually lives, rather than to the nominal count of timeframes pointing the same way.

[b]What It Does[/b]

[list]
[*]Detects the chart timeframe and automatically selects a matching set of higher timeframes. A 5-minute chart gets 15m / 1H / 4H / Daily; a 1H chart gets 4H / Daily / Weekly / Monthly, and so on.
[*]On each timeframe computes three pieces of state: EMA(Fast) vs EMA(Slow) direction, ADX value, and whether price is above or below the slow EMA.
[*]Produces a single ADX-weighted Consensus Score (0–100%) that reflects how strongly the scanned timeframes agree on the majority direction.
[*]Renders a 6-column dashboard with one row per timeframe (TF / Dir / Str / Gauge / EMA / Agree) plus a headline banner with the score, a visual bar gauge, and one of five labels: STRONG BULLISH, BULLISH, MIXED, BEARISH, STRONG BEARISH.
[*]Optionally tints the chart background green or red when every scanned timeframe agrees on direction.
[/list]

[b]How It Works[/b]

[b]Timeframe selection[/b]

The script reads the chart's timeframe in minutes and assigns it to one of five groups. Each group has a fixed ladder of higher timeframes — 15m / 1H / 4H / D / W / M — so the user never has to configure which timeframes to scan. A 1-minute or 5-minute chart scans 15m / 1H / 4H / D. A 15-minute chart scans 1H / 4H / D / W. A 1H chart scans 4H / D / W / M. Higher chart timeframes scan fewer levels because there are fewer larger frames available.

[b]Per-timeframe state[/b]

On every scanned timeframe:

[list]
[*][b]Direction[/b] = +1 when Fast EMA > Slow EMA, otherwise −1.
[*][b]ADX[/b] from [i]ta.dmi(period, period)[/i]. The default period is 14.
[*][b]Price position[/b] = +1 when close is above Slow EMA, otherwise −1. This is displayed as a separate EMA column so the user can see cases where direction and price-position disagree (for example, an EMA crossover has happened but price has retraced back through the slow EMA).
[/list]

[b]Consensus math[/b]

First, the overall direction is decided by a simple majority vote across the entry timeframe and all valid higher timeframes. Ties are broken by the entry timeframe.

Then the score is computed as:

[i]ConsensusScore = Σ(ADX of timeframes that agree with the overall direction) / Σ(ADX of all scanned timeframes) × 100[/i]

A score of 100% means every scanned timeframe agrees with the majority direction. A score of 50% means the weighted mass of agreement and disagreement is roughly balanced.

[b]Score labelling[/b]

[list]
[*]≥75% → STRONG BULLISH or STRONG BEARISH (depending on overall direction)
[*]50–74% → BULLISH or BEARISH
[*]<50% → MIXED (no directional label — the vote is too split to be useful)
[/list]

[b]Non-repainting[/b]

Every EMA and ADX read — including on the chart's own timeframe — uses the previous confirmed bar ([i]close[1][/i] and friends), and every [i]request.security()[/i] call uses [i]lookahead = barmerge.lookahead_on[/i]. This is the pattern that prevents the dashboard from flickering intrabar and prevents historical values from retroactively changing.

[b]How To Use[/b]

[list=1]
[*]Add the indicator to any chart. The dashboard appears in the top-right by default; everything is auto-configured based on the chart's timeframe.
[*]Read the top banner first. STRONG BULLISH / STRONG BEARISH (score ≥ 75%) means almost every scanned timeframe — weighted by how strongly each is trending — points the same way. MIXED (< 50%) means the trend structure across timeframes is inconsistent and the tool gives no directional opinion.
[*]Use it as a confirmation filter, not as an entry trigger. A common workflow is: only take long setups on the chart timeframe when the consensus is BULLISH or stronger, and skip or reduce size during MIXED readings.
[*]Watch the EMA column separately. A timeframe that shows a bullish Dir arrow but a bearish EMA column often indicates price is retesting the slow EMA after a recent cross — useful context that a single direction number cannot give.
[*]Set the three built-in alerts to be notified when the score crosses 75%, when it drops below 50%, or when the chart timeframe itself flips direction.
[/list]

[b]Settings[/b]

[list]
[*][b]Entry TF Mode[/b] — Auto (detects chart timeframe) or manual selection from 15, 60, 240, D.
[*][b]Fast EMA / Slow EMA[/b] — Defaults 20 / 50. The script enforces Fast < Slow at runtime.
[*][b]ADX Period[/b] — Default 14.
[*][b]ADX Threshold[/b] — Default 25. Used only to colour the Str column (green above, grey below); it does not change the consensus math itself.
[*][b]Table Position / Size[/b] — Nine positions, three sizes.
[*][b]Show Background / Background Transparency[/b] — Toggle the green/red full-agreement tint and choose how faint it is (70–97).
[/list]

[b]Alerts[/b]

[list]
[*][b]High Consensus Reached[/b] — score crosses above 75% from below.
[*][b]Consensus Broken[/b] — score crosses below 50% from above.
[*][b]Entry TF Direction Change[/b] — the chart timeframe's EMA direction flips.
[/list]

[b]Limitations[/b]

[list]
[*]This is a context dashboard. It does not predict price direction, does not place orders, and does not guarantee that a high consensus will persist.
[*]Consensus scores depend on the Fast/Slow EMA periods and ADX period; results differ materially with different inputs. Defaults (20 / 50 / 14) are generic — tune them to your instrument and timeframe.
[*]On chart timeframes of Monthly or higher, no valid higher-timeframe ladder exists and the dashboard falls back to the entry timeframe alone. The consensus score becomes a single-timeframe reading in that case.
[*]Each scanned timeframe needs enough history to fill its Slow EMA and ADX lookback on [i]that[/i] timeframe. Very short chart histories (for example, a fresh symbol on a Weekly chart) will show degraded values on the largest scanned timeframes until enough bars accumulate.
[*]EMA crossovers and ADX can both lag sharply after fast reversals and can chop during low-volatility ranges. The ADX weighting reduces the impact of low-ADX timeframes but cannot eliminate it entirely.
[*]The background tint only paints when every scanned timeframe agrees on direction; partial agreement is visible only inside the dashboard, not on the chart background.
[/list]

[b]Disclaimer[/b]

This indicator is a multi-timeframe context dashboard, not a trade signal generator. It does not forecast price and does not place orders. Always conduct your own analysis and apply your own risk management.

## Source Code

````pine
// ============================================================================
// MTF Trend Consensus — Multi-Timeframe Trend Agreement Dashboard
// ============================================================================
//
// WHAT IT DOES:
//   Analyzes trend direction across multiple timeframes using EMA crossovers
//   and ADX strength, then displays a consensus score showing how many
//   timeframes agree on the current trend direction.
//
// HOW IT WORKS:
//   1. Detects chart timeframe and auto-selects up to 4 higher timeframes
//   2. For each TF: calculates Fast/Slow EMA cross direction + ADX strength
//   3. Computes a weighted consensus score (0-100%) based on ADX-weighted agreement
//   4. Displays everything in a compact dashboard table
//
// NON-REPAINTING:
//   All data (including the entry TF) uses the previous confirmed bar [1]
//   to ensure signals never repaint on the current forming bar.
//
// INPUTS:
//   - Timeframes: Auto-detect or manual entry TF selection
//   - Trend Detection: EMA periods, ADX period/threshold
//   - Display: Table position, size, background color
//
// ALERTS:
//   - High Consensus Reached (score crosses above 75%)
//   - Consensus Broken (score drops below 50%)
//   - Entry TF Direction Change
//
// ============================================================================

//@version=6
indicator("MTF Trend Consensus", overlay=true, max_bars_back=500)

// ============================================================================
// COLOR CONSTANTS
// ============================================================================

var color C_BUY         = #26a69a
var color C_SELL        = #ef5350
var color C_NEUTRAL_UI  = #787b86
var color C_WHITE       = #d1d4dc
var color C_PANEL_BG    = color.new(#131722, 0)
var color C_HEADER_BG   = color.new(#1e222d, 0)
var color C_ROW_BG      = color.new(#16191e, 0)
var color C_ROW_BG2     = color.new(#1a1e27, 0)
var color C_STRONG_BUY  = #00E676
var color C_STRONG_SELL = #FF1744

// ============================================================================
// USER INPUTS
// ============================================================================

// --- Timeframes ---
i_tfMode = input.string("Auto", "Entry TF Mode", options=["Auto", "15", "60", "240", "D"], group="Timeframes", tooltip="Auto detects chart TF and maps to higher timeframes. Manual lets you set the base TF for comparison.")

// --- Trend Detection ---
i_emaFast     = input.int(20, "Fast EMA Period", minval=2, maxval=200, group="Trend Detection", tooltip="Fast EMA for trend direction crossover. Must be less than Slow EMA.")
i_emaSlow     = input.int(50, "Slow EMA Period", minval=5, maxval=500, group="Trend Detection", tooltip="Slow EMA for trend direction crossover. Must be greater than Fast EMA.")
i_adxPeriod   = input.int(14, "ADX Period", minval=5, maxval=50, group="Trend Detection", tooltip="Period for ADX trend strength calculation.")
i_adxThresh   = input.float(25.0, "ADX Threshold", minval=10.0, maxval=50.0, step=1.0, group="Trend Detection", tooltip="ADX above this value indicates a strong trend.")

// --- Display ---
i_tablePos    = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Display", tooltip="Position of the dashboard table on the chart.")
i_tableSize   = input.string("Small", "Table Size", options=["Small", "Normal", "Large"], group="Display", tooltip="Font size for the dashboard table.")
i_showBG      = input.bool(true, "Show Background Color", group="Display", tooltip="Color the chart background when all timeframes agree on direction.")
i_bgTransp    = input.int(90, "Background Transparency", minval=70, maxval=97, group="Display", tooltip="Transparency level for the background color overlay.")

// Input validation: ensure fast < slow
emaFast = math.min(i_emaFast, i_emaSlow - 1)
emaSlow = math.max(i_emaSlow, i_emaFast + 1)

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

tablePos = switch i_tablePos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right

tableSize = switch i_tableSize
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large

f_gauge(float value, float maxVal) =>
    int filled = math.round(math.min(value, maxVal) / nz(maxVal, 1.0) * 10)
    string result = ""
    for i = 0 to 9
        result += i < filled ? "█" : "░"
    result

f_tfLabel(string tf) =>
    switch tf
        "1"   => "1m"
        "5"   => "5m"
        "15"  => "15m"
        "60"  => "1H"
        "240" => "4H"
        "D"   => "D"
        "W"   => "W"
        "M"   => "M"
        => tf

// Dashboard row drawing (global scope — Pine v6 requires global function declarations)
f_drawRow(table panel, int row, string label, int dir, float adx, int pp, int refDir, bool isEntry, color rowBg, string sz) =>
    string dirStr   = dir == 1 ? "▲" : "▼"
    color  dirCol   = dir == 1 ? C_BUY : C_SELL
    string strStr   = str.tostring(math.round(nz(adx, 0)))
    color  strCol   = nz(adx, 0) >= i_adxThresh ? C_BUY : C_NEUTRAL_UI
    string gaugeStr = f_gauge(nz(adx, 0), 50.0)
    string emaStr   = pp == 1 ? "▲" : "▼"
    color  emaCol   = pp == 1 ? C_BUY : C_SELL
    bool   agrees   = dir == refDir
    string agreeStr = isEntry ? "—" : (agrees ? "YES" : "NO")
    color  agreeCol = isEntry ? C_NEUTRAL_UI : (agrees ? C_BUY : C_SELL)

    table.cell(panel, 0, row, label,    text_color=C_WHITE,      text_size=sz, bgcolor=rowBg)
    table.cell(panel, 1, row, dirStr,   text_color=dirCol,       text_size=sz, bgcolor=rowBg)
    table.cell(panel, 2, row, strStr,   text_color=strCol,       text_size=sz, bgcolor=rowBg)
    table.cell(panel, 3, row, gaugeStr, text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=rowBg)
    table.cell(panel, 4, row, emaStr,   text_color=emaCol,       text_size=sz, bgcolor=rowBg)
    table.cell(panel, 5, row, agreeStr, text_color=agreeCol,     text_size=sz, bgcolor=rowBg)

// ============================================================================
// CORE TREND DETECTION FUNCTION
// ============================================================================

f_trendData(float _close, float _high, float _low) =>
    float fastEMA = ta.ema(_close, emaFast)
    float slowEMA = ta.ema(_close, emaSlow)
    int direction = fastEMA > slowEMA ? 1 : -1
    [diP, diM, adxVal] = ta.dmi(i_adxPeriod, i_adxPeriod)
    float adxStrength = adxVal
    int pricePos = _close > slowEMA ? 1 : -1
    [direction, adxStrength, pricePos]

// ============================================================================
// TIMEFRAME MAPPING + DATA RETRIEVAL
// ============================================================================
// Use hardcoded request.security() calls with simple string TFs to avoid
// the "series string" compilation issue. Each TF is always fetched;
// we use boolean flags to decide which data to include in the consensus.

// Determine chart TF and TF group for slot mapping
chartMinutes = timeframe.in_seconds() / 60

// Effective entry TF in minutes (Auto or manual override)
float effectiveMinutes = i_tfMode == "Auto" ? chartMinutes : i_tfMode == "15" ? 15 : i_tfMode == "60" ? 60 : i_tfMode == "240" ? 240 : 1440

// TF group determines which 4 higher TFs to display
// Group 1: <=5m  → 15m, 1H, 4H, D
// Group 2: <=15m → 1H, 4H, D, W
// Group 3: <=1H  → 4H, D, W, M
// Group 4: <=4H  → D, W, M (3 TFs)
// Group 5: <=D   → W, M (2 TFs)
// Group 0: M+    → no higher TFs
var int tfGroup = 0
if barstate.isfirst
    if effectiveMinutes <= 5
        tfGroup := 1
    else if effectiveMinutes <= 15
        tfGroup := 2
    else if effectiveMinutes <= 60
        tfGroup := 3
    else if effectiveMinutes <= 240
        tfGroup := 4
    else if effectiveMinutes <= 1440
        tfGroup := 5

// Entry TF data — uses [1] for non-repainting
[entryDir, entryADX, entryPricePos] = f_trendData(close[1], high[1], low[1])

// Higher TF data — hardcoded simple string TFs (avoids series string issue)
[dir15,  adx15,  pp15]  = request.security(syminfo.tickerid, "15",  f_trendData(close[1], high[1], low[1]), lookahead=barmerge.lookahead_on)
[dir60,  adx60,  pp60]  = request.security(syminfo.tickerid, "60",  f_trendData(close[1], high[1], low[1]), lookahead=barmerge.lookahead_on)
[dir240, adx240, pp240] = request.security(syminfo.tickerid, "240", f_trendData(close[1], high[1], low[1]), lookahead=barmerge.lookahead_on)
[dirD,   adxD,   ppD]   = request.security(syminfo.tickerid, "D",   f_trendData(close[1], high[1], low[1]), lookahead=barmerge.lookahead_on)
[dirW,   adxW,   ppW]   = request.security(syminfo.tickerid, "W",   f_trendData(close[1], high[1], low[1]), lookahead=barmerge.lookahead_on)
[dirM,   adxM,   ppM]   = request.security(syminfo.tickerid, "M",   f_trendData(close[1], high[1], low[1]), lookahead=barmerge.lookahead_on)

// Direct slot mapping by TF group (clean, no cascading booleans)
// Slot 1 (first higher TF)
int   slot1Dir = tfGroup == 1 ? dir15  : tfGroup == 2 ? dir60  : tfGroup == 3 ? dir240 : tfGroup == 4 ? dirD : tfGroup == 5 ? dirW : na
float slot1ADX = tfGroup == 1 ? adx15  : tfGroup == 2 ? adx60  : tfGroup == 3 ? adx240 : tfGroup == 4 ? adxD : tfGroup == 5 ? adxW : na
int   slot1PP  = tfGroup == 1 ? pp15   : tfGroup == 2 ? pp60   : tfGroup == 3 ? pp240  : tfGroup == 4 ? ppD  : tfGroup == 5 ? ppW  : na
string slot1TF = tfGroup == 1 ? "15"   : tfGroup == 2 ? "60"   : tfGroup == 3 ? "240"  : tfGroup == 4 ? "D"  : tfGroup == 5 ? "W"  : na

// Slot 2 (second higher TF)
int   slot2Dir = tfGroup == 1 ? dir60  : tfGroup == 2 ? dir240 : tfGroup == 3 ? dirD   : tfGroup == 4 ? dirW : tfGroup == 5 ? dirM : na
float slot2ADX = tfGroup == 1 ? adx60  : tfGroup == 2 ? adx240 : tfGroup == 3 ? adxD   : tfGroup == 4 ? adxW : tfGroup == 5 ? adxM : na
int   slot2PP  = tfGroup == 1 ? pp60   : tfGroup == 2 ? pp240  : tfGroup == 3 ? ppD    : tfGroup == 4 ? ppW  : tfGroup == 5 ? ppM  : na
string slot2TF = tfGroup == 1 ? "60"   : tfGroup == 2 ? "240"  : tfGroup == 3 ? "D"    : tfGroup == 4 ? "W"  : tfGroup == 5 ? "M"  : na

// Slot 3 (third higher TF)
int   slot3Dir = tfGroup == 1 ? dir240 : tfGroup == 2 ? dirD   : tfGroup == 3 ? dirW   : tfGroup == 4 ? dirM : na
float slot3ADX = tfGroup == 1 ? adx240 : tfGroup == 2 ? adxD   : tfGroup == 3 ? adxW   : tfGroup == 4 ? adxM : na
int   slot3PP  = tfGroup == 1 ? pp240  : tfGroup == 2 ? ppD    : tfGroup == 3 ? ppW    : tfGroup == 4 ? ppM  : na
string slot3TF = tfGroup == 1 ? "240"  : tfGroup == 2 ? "D"    : tfGroup == 3 ? "W"    : tfGroup == 4 ? "M"  : na

// Slot 4 (fourth higher TF — only groups 1-3 have 4 TFs)
int   slot4Dir = tfGroup == 1 ? dirD   : tfGroup == 2 ? dirW   : tfGroup == 3 ? dirM   : na
float slot4ADX = tfGroup == 1 ? adxD   : tfGroup == 2 ? adxW   : tfGroup == 3 ? adxM   : na
int   slot4PP  = tfGroup == 1 ? ppD    : tfGroup == 2 ? ppW    : tfGroup == 3 ? ppM    : na
string slot4TF = tfGroup == 1 ? "D"    : tfGroup == 2 ? "W"    : tfGroup == 3 ? "M"    : na

int validTFs = (not na(slot1TF) ? 1 : 0) + (not na(slot2TF) ? 1 : 0) + (not na(slot3TF) ? 1 : 0) + (not na(slot4TF) ? 1 : 0)

// ============================================================================
// CONSENSUS SCORE CALCULATION
// ============================================================================

// Majority vote for overall direction (entry TF breaks ties)
int bullCount = (entryDir == 1 ? 1 : 0) + (not na(slot1Dir) and slot1Dir == 1 ? 1 : 0) + (not na(slot2Dir) and slot2Dir == 1 ? 1 : 0) + (not na(slot3Dir) and slot3Dir == 1 ? 1 : 0) + (not na(slot4Dir) and slot4Dir == 1 ? 1 : 0)
int totalCount = 1 + validTFs
int bearCount  = totalCount - bullCount
int overallDir = bullCount > bearCount ? 1 : bullCount < bearCount ? -1 : entryDir

// ADX-weighted consensus: sum(agreeing * ADX) / sum(all ADX)
float agreeW = 0.0
float totalW = 0.0

totalW += nz(entryADX, 1.0)
agreeW += (entryDir == overallDir) ? nz(entryADX, 1.0) : 0.0

if not na(slot1Dir)
    totalW += nz(slot1ADX, 1.0)
    agreeW += (slot1Dir == overallDir) ? nz(slot1ADX, 1.0) : 0.0
if not na(slot2Dir)
    totalW += nz(slot2ADX, 1.0)
    agreeW += (slot2Dir == overallDir) ? nz(slot2ADX, 1.0) : 0.0
if not na(slot3Dir)
    totalW += nz(slot3ADX, 1.0)
    agreeW += (slot3Dir == overallDir) ? nz(slot3ADX, 1.0) : 0.0
if not na(slot4Dir)
    totalW += nz(slot4ADX, 1.0)
    agreeW += (slot4Dir == overallDir) ? nz(slot4ADX, 1.0) : 0.0

int consensusScore = math.round(agreeW / nz(totalW, 1.0) * 100)

// ============================================================================
// BACKGROUND COLOR
// ============================================================================

bool allBull = entryDir == 1 and (na(slot1Dir) or slot1Dir == 1) and (na(slot2Dir) or slot2Dir == 1) and (na(slot3Dir) or slot3Dir == 1) and (na(slot4Dir) or slot4Dir == 1)
bool allBear = entryDir == -1 and (na(slot1Dir) or slot1Dir == -1) and (na(slot2Dir) or slot2Dir == -1) and (na(slot3Dir) or slot3Dir == -1) and (na(slot4Dir) or slot4Dir == -1)

color bgCol = i_showBG ? (allBull ? color.new(C_BUY, i_bgTransp) : allBear ? color.new(C_SELL, i_bgTransp) : na) : na
bgcolor(bgCol)

// ============================================================================
// DASHBOARD TABLE
// ============================================================================

int tableRows = 3 + validTFs + 1  // header + banner + col headers + TF rows + entry row
var table panel = table.new(tablePos, 6, tableRows, bgcolor=C_PANEL_BG, border_width=1, border_color=color.new(#2a2e39, 0), frame_width=1, frame_color=color.new(#2a2e39, 0))

if barstate.islast
    // --- Row 0: Title ---
    table.cell(panel, 0, 0, "𝗠𝗧𝗙 𝗧𝗥𝗘𝗡𝗗 𝗖𝗢𝗡𝗦𝗘𝗡𝗦𝗨𝗦", text_color=C_WHITE, text_size=tableSize, bgcolor=C_HEADER_BG)
    table.merge_cells(panel, 0, 0, 5, 0)

    // --- Row 1: Consensus Banner ---
    string dirLabel  = ""
    color  bannerCol = C_NEUTRAL_UI
    if consensusScore >= 75
        dirLabel  := overallDir == 1 ? "STRONG BULLISH" : "STRONG BEARISH"
        bannerCol := overallDir == 1 ? C_STRONG_BUY : C_STRONG_SELL
    else if consensusScore >= 50
        dirLabel  := overallDir == 1 ? "BULLISH" : "BEARISH"
        bannerCol := overallDir == 1 ? C_BUY : C_SELL
    else
        dirLabel  := "MIXED"
        bannerCol := C_NEUTRAL_UI

    string bannerGauge = f_gauge(consensusScore, 100)
    string bannerText  = "Consensus: " + str.tostring(consensusScore) + "%  " + bannerGauge + "  " + dirLabel
    table.cell(panel, 0, 1, bannerText, text_color=bannerCol, text_size=tableSize, bgcolor=C_PANEL_BG)
    table.merge_cells(panel, 0, 1, 5, 1)

    // --- Row 2: Column Headers ---
    table.cell(panel, 0, 2, "TF",    text_color=C_NEUTRAL_UI, text_size=tableSize, bgcolor=C_HEADER_BG)
    table.cell(panel, 1, 2, "Dir",   text_color=C_NEUTRAL_UI, text_size=tableSize, bgcolor=C_HEADER_BG)
    table.cell(panel, 2, 2, "Str",   text_color=C_NEUTRAL_UI, text_size=tableSize, bgcolor=C_HEADER_BG)
    table.cell(panel, 3, 2, "Gauge", text_color=C_NEUTRAL_UI, text_size=tableSize, bgcolor=C_HEADER_BG)
    table.cell(panel, 4, 2, "EMA",   text_color=C_NEUTRAL_UI, text_size=tableSize, bgcolor=C_HEADER_BG)
    table.cell(panel, 5, 2, "Agree", text_color=C_NEUTRAL_UI, text_size=tableSize, bgcolor=C_HEADER_BG)

    // --- Higher TF rows (descending: largest TF at top) ---
    int r = 3
    if not na(slot4TF)
        f_drawRow(panel, r, f_tfLabel(slot4TF), slot4Dir, slot4ADX, slot4PP, overallDir, false, C_ROW_BG, tableSize)
        r += 1
    if not na(slot3TF)
        f_drawRow(panel, r, f_tfLabel(slot3TF), slot3Dir, slot3ADX, slot3PP, overallDir, false, C_ROW_BG2, tableSize)
        r += 1
    if not na(slot2TF)
        f_drawRow(panel, r, f_tfLabel(slot2TF), slot2Dir, slot2ADX, slot2PP, overallDir, false, C_ROW_BG, tableSize)
        r += 1
    if not na(slot1TF)
        f_drawRow(panel, r, f_tfLabel(slot1TF), slot1Dir, slot1ADX, slot1PP, overallDir, false, C_ROW_BG2, tableSize)
        r += 1

    // --- Entry TF row (highlighted) ---
    string entryLabel = f_tfLabel(timeframe.period) + " ★"
    f_drawRow(panel, r, entryLabel, entryDir, entryADX, entryPricePos, overallDir, true, C_HEADER_BG, tableSize)

// ============================================================================
// ALERT CONDITIONS
// ============================================================================

alertcondition(consensusScore >= 75 and consensusScore[1] < 75, "High Consensus Reached", "MTF Consensus crossed above 75% — {{ticker}} {{interval}}")
alertcondition(consensusScore < 50 and consensusScore[1] >= 50, "Consensus Broken", "MTF Consensus dropped below 50% — {{ticker}} {{interval}}")
alertcondition(entryDir != entryDir[1], "Entry TF Direction Change", "Entry TF trend direction changed — {{ticker}} {{interval}}")

// ============================================================================
// END
// ============================================================================
````
