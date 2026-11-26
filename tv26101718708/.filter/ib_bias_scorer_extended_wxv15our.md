# IB Bias Scorer Extended

- url: https://www.tradingview.com/script/wXv15oUr-IB-Bias-Scorer-Extended/
- type: indicator
- pine_id: PUB;a3bb0443e2c44ec3b0967f3f0fe590b3
- version: 3.0

## Description

IB Bias Scorer
The IB Bias Scorer is a multi-confluence directional bias engine that aggregates seven independent market reads — structure, trend alignment, institutional pricing, higher-timeframe agreement, momentum, participation, and liquidity — into a single normalized score. Rather than flashing a signal and hiding its reasoning, it renders the full decomposition as a compact bias-bar dashboard, so every score is traceable back to the components that produced it.
Designed as a companion to session-based VWAP and order-block indicators, the scorer is built for traders who want why, not just what — a quantified directional read with the underlying logic exposed for discretionary confirmation.
🔶 USAGE
The scorer synthesizes seven weighted components into a composite score on a −10 to +10 scale, displayed as a bull / bear percentage split at the top of a dashboard table. Each component renders its own row with a state label, a signed contribution, and a mini bias bar that fans out from a center zero line — bullish fills right, bearish fills left.
Traders use this to confirm directional conviction before entry. A composite in the "Strong" or "Elite" tiers with high agreement across components signals a high-confluence regime worth trading aggressively. A "Chop" or low-agreement reading signals a stand-aside market. The per-component breakdown also diagnoses why the bias is what it is — so you can spot cases where one strong component is dragging the score while the rest disagree.
🔹 The Seven Confluences
Each component returns a discrete score between −2 and +2, then is multiplied by its weight and summed. The sum is normalized to −10 to +10:
Market Structure (weight 2.0) — The trend skeleton. Detects higher-highs/higher-lows and lower-lows/lower-highs via swing pivots. Scores ±2 for clean trending structure, 0 for expansion or compression. Highest weight because structure reframes every other read.
EMA Stack Alignment (weight 1.5) — Fast-trend filter using 9/21/50 EMAs. Stacked and price-confirmed = ±2, stacked with price pulling back through the fast EMA = ±1.
VWAP Position + Slope (weight 1.5) — Institutional bias anchor. Combines price location relative to the daily-anchored VWAP with VWAP's own slope. Above a rising VWAP = +2, below a falling VWAP = −2.
HTF Trend Agreement (weight 1.5) — Multi-timeframe confirmation. Checks whether both 1H and 4H closes sit above or below a 50 EMA. Both agreed = ±2, one agreed / one neutral = ±1, split = 0.
Momentum Regime (weight 1.0) — RSI regime filter, not overbought/oversold. RSI ≥ 55 = +2, ≤ 45 = −2, otherwise ±1 based on the 50-line. Used as a tiebreaker, not a reversal signal.
Relative Volume (weight 1.0) — A directional amplifier. Takes the net sign of the other five components and scales it by volume vs. its average. High volume reinforces the prevailing bias; low volume dampens it. Volume alone is never directional — it only amplifies what is already there.
Unmitigated Session H/L (weight 1.0) — Liquidity-magnet imbalance. The novel component (see Liquidity Logic below).
🔹 Liquidity Logic (the Seventh Component)
The scorer tracks the four most recent session highs and lows — Asia, London, prior NY, and prior calendar Day — and considers each level "live" until price trades through it. When a level is swept, it is permanently cleared. The component then counts unmitigated highs above the current close and unmitigated lows below it, and scores the imbalance:
More highs above than lows below → bullish pull (magnets overhead). Score +1 or +2 depending on the gap.
More lows below than highs above → bearish pull (magnets underneath). Score −1 or −2.
Zero highs above, lows remain below → Uncharted regime. Price has swept all overhead supply; no air above, only support below. Scored +1.
Zero lows below, highs remain above → Basement regime. All support has been swept; only magnets are overhead. Scored −1.
The Uncharted and Basement cases are what make this component useful at extremes. Pure imbalance counting breaks down when price is near ATH (no highs above) or ATL (no lows below) — the absence of liquidity on one side is itself informational. The scorer treats these as moderate directional reads rather than neutral zeros.
🔹 The Composite Score
The weighted sum is normalized to −10 to +10 and converted to a percentage split where +10 = 100% bull / 0% bear and −10 = the inverse. The absolute value then maps to a grade tier:
Chop (|score| ≤ 2) — No directional edge. Stand aside or fade extremes.
Caution (2 – 3) — Weak directional tilt, insufficient confluence.
Medium (3 – 5) — Directional but not overwhelming. Tight risk warranted.
Strong (5 – 7.5) — High-conviction alignment. Primary setups live here.
Elite (≥ 7.5) — Near-full alignment across all seven components. Rare regime, high expected quality.
All thresholds are adjustable to suit different instruments and timeframes.
🔶 DETAILS
🔹 The Dashboard
The dashboard is the entire output surface — there are no chart overlays, alerts, or hidden plots. Everything the scorer computes is visible on the table:
Header row — Bull % and Bear % banners, color-coded.
Main split bar — A wide horizontal bar visualizing the split across ten cells.
Component rows — Seven rows, each with: component name, current state label, signed (weighted) contribution, and a mini ten-cell bar fanning from a center zero line. The bar fills proportionally to the component's magnitude, so a +2 component fills all five right-side cells, a −1 fills two-to-three left-side cells, and a 0 component shows an empty track.
Composite row — Final score out of 10, grade tier emoji and label.
Bias row — Overall direction (Bullish / Bearish / Chop) and agreement count (X / 7 agree), where agreement means the component's score points in the same direction as the final composite.
🔹 State Labels
Each component exposes a short state string so the current regime is legible at a glance. Representative examples:
Structure: HH/HL, LL/LH, Expand, Compress, Neutral
EMA Stack: Stacked, Pullback, Mixed
VWAP: Above↑, Below↓, Above→, At VWAP, Flat
HTF: Both↑, Both↓, 1H↑, 4H↓, Split
Momentum: numeric RSI value
Volume: volume ratio (e.g. ×1.82)
Liquidity: ↑3 ↓1 (count of unmitigated highs above / lows below), or Uncharted ↓N / Basement ↑N at the edge cases
🔹 Session Windows (Liquidity Component)
Default session definitions, configurable in settings, with a selectable timezone (defaults to New York):
Asia: 20:00 – 02:00
London: 02:00 – 08:00
NY: 09:30 – 16:00
When today's NY session completes, its high and low replace yesterday's as the "prior NY" reference. Prior Day H/L is a separate optional level pulled from the previous completed daily bar; once mitigated, it stays cleared for the remainder of the day rather than re-populating from daily data.
🔶 SETTINGS
🔹 Component Settings
Market Structure — Pivot lookback length and component weight.
EMA Stack — Fast, mid, and slow EMA lengths, plus weight.
VWAP — Slope lookback in bars, flat threshold as a percentage, and weight.
HTF Trend — Two higher-timeframe selectors (default 1H and 4H), EMA length used on each, and weight.
Momentum — RSI length, bull/bear regime thresholds, and weight.
Volume — Average-volume lookback, high and low multipliers, and weight.
Liquidity Levels — Asia / London / NY session definitions, toggle for Prior Day H/L, timezone selector, and weight.
🔹 Score Grading
Medium / Strong / Elite Floors — The absolute-value thresholds that promote a score into each tier.
Chop Ceiling — The dead-zone radius around zero inside which the bias is labeled CHOP regardless of sign.
🔹 Visual Settings
Directional Style — Bullish, bearish, and neutral colors.
Grade Style — Custom color and emoji per tier (Caution, Medium, Strong, Elite, Chop).
Table Style — Position (six options), text size, cell transparency, empty-bar-cell transparency, and background colors for headers and rows.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
// Updated 5/1/26
// ============================================================================
// IB STRATEGY BIAS SCORER
// ============================================================================
//
// OVERVIEW:
// Companion to the "VWAP Session and NY Cash" and "Pro Order Block Suite"
// indicators. Aggregates 7 high-weight confluences into a single directional
// bias score, displayed as a split bias bar with per-component diagnostics.
//
// DISPLAY:
//   • Top: Bull/Bear percentage split (e.g. "BEAR 28% | BULL 72%")
//   • Main: Horizontal bar visualizing the split
//   • Rows: Each component with its own bar fanning from a center zero line
//   • Footer: Composite score, grade tier, agreement count
//   • IB Range: Width classification (Narrow/Normal/Wide/Extreme) vs 14-day ATR
//
// CONFLUENCES SCORED:
//   1. Market Structure (BOS/CHoCH) — trend skeleton, highest weight
//   2. EMA Stack Alignment (9/21/50) — fast trend filter
//   3. VWAP Position + Slope — institutional bias anchor
//   4. HTF Trend Agreement (1H + 4H) — multi-timeframe confirmation
//   5. Momentum Regime (RSI above/below 50) — trend-regime filter
//   6. Relative Volume — participation / conviction
//   7. Unmitigated Session H/L — liquidity magnet imbalance (Asia, London,
//      prior NY, prior day). More highs above = bullish pull; more lows
//      below = bearish pull. Empty side = uncharted/basement edge case.
//
// Each component returns -2 to +2. Weighted sum normalized to -10 to +10.
// Percentage: bullish% = ((score + 10) / 20) * 100
//
// ============================================================================

indicator("IB Bias Scorer Ext", overlay = true, max_lines_count = 50, max_labels_count = 50)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------{
const string TIMEZONE = "America/New_York"
const int BAR_SEGMENTS = 10  // Number of cells used to draw each per-component bar
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------{
// --- Market Structure ---
msLen      = input.int(10, "Structure Pivot Length", minval = 2, group = "Market Structure", tooltip = "Length for swing pivot detection. Smaller = more sensitive, larger = cleaner.")
msWeight   = input.float(2.0, "Weight", minval = 0.5, maxval = 3.0, step = 0.5, group = "Market Structure", tooltip = "How heavily this component contributes to the total score. Default 2.0 reflects market structure as the highest-weight confluence.")

// --- EMA Stack ---
ema1Len    = input.int(9, "Fast EMA", minval = 1, group = "EMA Stack", inline = "ema")
ema2Len    = input.int(21, "Mid EMA", minval = 1, group = "EMA Stack", inline = "ema")
ema3Len    = input.int(50, "Slow EMA", minval = 1, group = "EMA Stack", inline = "ema")
emaWeight  = input.float(1.5, "Weight", minval = 0.5, maxval = 3.0, step = 0.5, group = "EMA Stack")

// --- VWAP ---
vwapSlopeLookback = input.int(10, "VWAP Slope Lookback (bars)", minval = 2, group = "VWAP", tooltip = "Number of bars used to determine whether VWAP is rising, flat, or falling.")
vwapFlatThresh    = input.float(0.05, "Flat Threshold (%)", minval = 0.0, step = 0.01, group = "VWAP", tooltip = "VWAP slope below this percentage over the lookback is treated as flat.")
vwapWeight        = input.float(1.5, "Weight", minval = 0.5, maxval = 3.0, step = 0.5, group = "VWAP")

// --- HTF Trend ---
htf1         = input.timeframe("60",  "Higher Timeframe 1", group = "HTF Trend")
htf2         = input.timeframe("240", "Higher Timeframe 2", group = "HTF Trend")
htfEmaLen    = input.int(50, "HTF EMA Length", minval = 1, group = "HTF Trend", tooltip = "EMA used on each HTF to determine trend direction.")
htfWeight    = input.float(1.5, "Weight", minval = 0.5, maxval = 3.0, step = 0.5, group = "HTF Trend")

// --- Momentum ---
rsiLen       = input.int(14, "RSI Length", minval = 2, group = "Momentum")
rsiBullMin   = input.float(55.0, "Bull Regime Above", minval = 50.0, maxval = 70.0, group = "Momentum", tooltip = "RSI at or above this is scored full bullish momentum.")
rsiBearMax   = input.float(45.0, "Bear Regime Below", minval = 30.0, maxval = 50.0, group = "Momentum", tooltip = "RSI at or below this is scored full bearish momentum.")
momWeight    = input.float(1.0, "Weight", minval = 0.5, maxval = 3.0, step = 0.5, group = "Momentum")

// --- Volume ---
volLookback  = input.int(20, "Avg Volume Lookback", minval = 2, group = "Volume")
volHighMult  = input.float(1.5, "High Volume Multiplier", minval = 1.0, step = 0.1, group = "Volume", tooltip = "Volume at or above avg × this multiplier is considered high.")
volLowMult   = input.float(0.7, "Low Volume Multiplier", minval = 0.1, maxval = 1.0, step = 0.1, group = "Volume", tooltip = "Volume at or below avg × this multiplier is considered low (chop).")
volWeight    = input.float(1.0, "Weight", minval = 0.5, maxval = 3.0, step = 0.5, group = "Volume")

// --- Liquidity Levels (Unmitigated Session H/L) ---
asiaSess     = input.session("2000-0200", "Asia Session",      group = "Liquidity Levels", tooltip = "Session window in exchange timezone for tracking Asia H/L.")
londonSess   = input.session("0200-0800", "London Session",    group = "Liquidity Levels", tooltip = "Session window for tracking London H/L.")
nySess       = input.session("0930-1600", "NY Session",        group = "Liquidity Levels", tooltip = "Session window. Once today's NY completes, its H/L becomes the 'prior NY' for scoring.")
trackPDHL    = input.bool(true,     "Track Prior Day H/L",     group = "Liquidity Levels", tooltip = "Include the previous calendar day's high and low as liquidity levels.")
liqTz        = input.string("America/New_York", "Timezone",    options = ["America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "Etc/UTC"], group = "Liquidity Levels")
liqWeight    = input.float(1.0, "Weight", minval = 0.5, maxval = 3.0, step = 0.5, group = "Liquidity Levels", tooltip = "Short-term bias weight. Default 1.0 keeps liquidity subordinate to structure and HTF trend.")

// --- IB Range Width ---
ibSess          = input.session("0930-1030", "IB Session (9:30-10:30 ET)", group = "IB Range Width", tooltip = "The Initial Balance window. First hour of RTH.")
ibTz            = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "Etc/UTC"], group = "IB Range Width")
ibAvgLen        = input.int(14, "IB Average Lookback (days)", minval = 2, maxval = 50, group = "IB Range Width", tooltip = "Number of prior completed IB ranges to average. Compares today's IB to what IB has been doing recently — not the full daily range.")
ibNarrowThresh  = input.float(0.75, "Narrow Threshold (× Avg IB)", minval = 0.1, maxval = 1.0, step = 0.05, group = "IB Range Width", tooltip = "Today's IB below this ratio of the average IB = Narrow. Compressed first hour, breakout likely.")
ibWideThresh    = input.float(1.25, "Wide Threshold (× Avg IB)",   minval = 1.0, maxval = 2.0, step = 0.05, group = "IB Range Width", tooltip = "Today's IB above this ratio of the average IB = Wide. First hour ate the range.")
ibExtremeThresh = input.float(1.75, "Extreme Threshold (× Avg IB)", minval = 1.0, maxval = 3.0, step = 0.1, group = "IB Range Width", tooltip = "Today's IB above this ratio of the average IB = Extreme. News/event day.")

// --- Daily ATR Reference ---
atrLen          = input.int(14, "ATR Length (daily)", minval = 2, group = "Daily ATR", tooltip = "Period for the daily ATR. Shows how much of the average daily range the IB has consumed.")
atrColor        = input.color(#5b9cf6, "ATR Row Color", group = "Daily ATR")

// --- Score Grading ---
medFloor     = input.float(3.0, "Medium Floor",  minval = 0.0, group = "Score Grading", tooltip = "|Score| at or above this becomes 'Medium'.")
strongFloor  = input.float(5.0, "Strong Floor",  minval = 0.0, group = "Score Grading", tooltip = "|Score| at or above this becomes 'Strong'.")
eliteFloor   = input.float(7.5, "Elite Floor",   minval = 0.0, group = "Score Grading", tooltip = "|Score| at or above this becomes 'Elite'.")
chopCeiling  = input.float(2.0, "Chop Ceiling",  minval = 0.0, group = "Score Grading", tooltip = "|Score| at or below this is explicitly labeled 'CHOP'.")

// --- Score Grading Style ---
cautColor    = input.color(#f23645, "Caution",  inline = "caut",   group = "Score Grading Style")
cautEmoji    = input.string("⚠️", "",            inline = "caut",   group = "Score Grading Style")
medColor     = input.color(#ff9800, "Medium",   inline = "med",    group = "Score Grading Style")
medEmoji     = input.string("🟡", "",            inline = "med",    group = "Score Grading Style")
strongColor  = input.color(#089981, "Strong",   inline = "strong", group = "Score Grading Style")
strongEmoji  = input.string("🔥", "",            inline = "strong", group = "Score Grading Style")
eliteColor   = input.color(#ab47bc, "Elite",    inline = "elite",  group = "Score Grading Style")
eliteEmoji   = input.string("💎", "",            inline = "elite",  group = "Score Grading Style")
chopColor    = input.color(#9598a1, "Chop",     inline = "chop",   group = "Score Grading Style")
chopEmoji    = input.string("➖", "",            inline = "chop",   group = "Score Grading Style")

// --- IB Range Style ---
ibNarrowColor  = input.color(#2196f3, "Narrow",  group = "IB Range Style", tooltip = "Compressed first hour — breakout likely.")
ibNormalColor  = input.color(#9598a1, "Normal",  group = "IB Range Style", tooltip = "Average day.")
ibWideColor    = input.color(#ff9800, "Wide",    group = "IB Range Style", tooltip = "First hour ate the range — fade setups.")
ibExtremeColor = input.color(#f23645, "Extreme", group = "IB Range Style", tooltip = "News/event day — IB may be the day's range.")

// --- Directional Colors ---
bullColor    = input.color(#089981, "Bullish",  group = "Directional Style")
bearColor    = input.color(#f23645, "Bearish",  group = "Directional Style")
neutColor    = input.color(#5b9cf6, "Neutral",  group = "Directional Style")
zeroLineColor = input.color(#9598a1, "Zero Line", group = "Directional Style")

// --- Table Style ---
tablePos       = input.string("Middle Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = "Table Style")
tableTextSz    = input.string("small", "Text Size", options = ["tiny", "small", "normal", "large"], group = "Table Style")
tableBgTransp  = input.int(15, "Cell Transparency", minval = 0, maxval = 100, group = "Table Style")
barEmptyTransp = input.int(85, "Empty Bar Cell Transparency", minval = 0, maxval = 100, group = "Table Style", tooltip = "Transparency for the unfilled portion of each component's bias bar.")
labelTextColor = input.color(#ffffff, "Label Text Color", group = "Table Style")
headerBgColor  = input.color(#1e222d, "Header Background", group = "Table Style")
rowBgColor     = input.color(#131722, "Row Background", group = "Table Style")

// --- Show / Hide Rows ---
showHeader     = input.bool(true, "Bias Header & Split Bar",   group = "Show / Hide Rows", tooltip = "Top banner showing BULL/BEAR percentage split and the colored bar.")
showStructure  = input.bool(true, "Structure",                 group = "Show / Hide Rows")
showEma        = input.bool(true, "EMA Stack",                 group = "Show / Hide Rows")
showVwap       = input.bool(true, "VWAP",                      group = "Show / Hide Rows")
showHtf        = input.bool(true, "HTF 1H/4H",                group = "Show / Hide Rows")
showMomentum   = input.bool(true, "Momentum",                  group = "Show / Hide Rows")
showVolume     = input.bool(true, "Volume",                    group = "Show / Hide Rows")
showLiquidity  = input.bool(true, "Liquidity",                 group = "Show / Hide Rows")
showComposite  = input.bool(true, "Composite Score & Bias",    group = "Show / Hide Rows", tooltip = "The final weighted score, grade tier, direction label, and agreement count.")
showIBRange    = input.bool(true, "IB Range Width & Setup",    group = "Show / Hide Rows", tooltip = "IB tier classification (Narrow/Normal/Wide/Extreme) and setup recommendation.")
showATR        = input.bool(true, "Daily ATR & Runway",        group = "Show / Hide Rows", tooltip = "14-day daily ATR, session consumption %, and remaining runway.")
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// Helper Functions
//------------------------------------------------------------------------------{
get_table_pos(pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.middle_right

get_text_size(sz) =>
    switch sz
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.small

clamp(val, minVal, maxVal) =>
    math.max(minVal, math.min(maxVal, val))

// In-session check using session string and configured timezone
in_session(string sess, string tz) =>
    not na(time(timeframe.period, sess, tz))
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 1. Market Structure (BOS / CHoCH)
//------------------------------------------------------------------------------{
var float lastSwingHigh  = na
var float prevSwingHigh  = na
var float lastSwingLow   = na
var float prevSwingLow   = na

ph = ta.pivothigh(high, msLen, msLen)
pl = ta.pivotlow(low, msLen, msLen)

if not na(ph)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := ph

if not na(pl)
    prevSwingLow  := lastSwingLow
    lastSwingLow  := pl

bool hh = not na(lastSwingHigh) and not na(prevSwingHigh) and lastSwingHigh > prevSwingHigh
bool hl = not na(lastSwingLow)  and not na(prevSwingLow)  and lastSwingLow  > prevSwingLow
bool lh = not na(lastSwingHigh) and not na(prevSwingHigh) and lastSwingHigh < prevSwingHigh
bool ll = not na(lastSwingLow)  and not na(prevSwingLow)  and lastSwingLow  < prevSwingLow

float  msScore = 0.0
string msState = "Neutral"

if hh and hl
    msScore := 2.0
    msState := "HH/HL"
else if ll and lh
    msScore := -2.0
    msState := "LL/LH"
else if hh and ll
    msState := "Expand"
else if lh and hl
    msState := "Compress"
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 2. EMA Stack Alignment
//------------------------------------------------------------------------------{
ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)

bool stackBull   = ema1 > ema2 and ema2 > ema3 and close > ema1
bool stackBear   = ema1 < ema2 and ema2 < ema3 and close < ema1
bool partialBull = ema1 > ema2 and ema2 > ema3 and close < ema1
bool partialBear = ema1 < ema2 and ema2 < ema3 and close > ema1

float  emaScore = 0.0
string emaState = "Mixed"

if stackBull
    emaScore := 2.0
    emaState := "Stacked"
else if stackBear
    emaScore := -2.0
    emaState := "Stacked"
else if partialBull
    emaScore := 1.0
    emaState := "Pullback"
else if partialBear
    emaScore := -1.0
    emaState := "Pullback"
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 3. VWAP Position + Slope
//------------------------------------------------------------------------------{
vwapVal = ta.vwap(hlc3, timeframe.change("1D"))

float vwapSlopePct = na(vwapVal[vwapSlopeLookback]) ? 0.0 : ((vwapVal - vwapVal[vwapSlopeLookback]) / vwapVal[vwapSlopeLookback]) * 100.0
bool vwapRising    = vwapSlopePct >  vwapFlatThresh
bool vwapFalling   = vwapSlopePct < -vwapFlatThresh
bool priceAboveVwap = close > vwapVal
bool priceBelowVwap = close < vwapVal

float  vwapScore = 0.0
string vwapState = "Flat"

if priceAboveVwap and vwapRising
    vwapScore := 2.0
    vwapState := "Above↑"
else if priceBelowVwap and vwapFalling
    vwapScore := -2.0
    vwapState := "Below↓"
else if priceAboveVwap and not vwapFalling
    vwapScore := 1.0
    vwapState := "Above→"
else if priceBelowVwap and not vwapRising
    vwapScore := -1.0
    vwapState := "Below→"
else
    vwapState := "At VWAP"
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 4. HTF Trend Agreement
//------------------------------------------------------------------------------{
get_htf_bias(float htfClose, float htfEma) =>
    htfClose > htfEma ? 1 : htfClose < htfEma ? -1 : 0

[htf1Close, htf1Ema] = request.security(syminfo.tickerid, htf1, [close, ta.ema(close, htfEmaLen)], lookahead = barmerge.lookahead_off)
[htf2Close, htf2Ema] = request.security(syminfo.tickerid, htf2, [close, ta.ema(close, htfEmaLen)], lookahead = barmerge.lookahead_off)

int htf1Bias = get_htf_bias(htf1Close, htf1Ema)
int htf2Bias = get_htf_bias(htf2Close, htf2Ema)

float  htfScore = 0.0
string htfState = "Mixed"

if htf1Bias == 1 and htf2Bias == 1
    htfScore := 2.0
    htfState := "Both↑"
else if htf1Bias == -1 and htf2Bias == -1
    htfScore := -2.0
    htfState := "Both↓"
else if htf1Bias == 1 and htf2Bias == 0
    htfScore := 1.0
    htfState := "1H↑"
else if htf1Bias == -1 and htf2Bias == 0
    htfScore := -1.0
    htfState := "1H↓"
else if htf1Bias == 0 and htf2Bias == 1
    htfScore := 1.0
    htfState := "4H↑"
else if htf1Bias == 0 and htf2Bias == -1
    htfScore := -1.0
    htfState := "4H↓"
else
    htfState := "Split"
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 5. Momentum Regime (RSI)
//------------------------------------------------------------------------------{
rsiVal = ta.rsi(close, rsiLen)

float  momScore = 0.0
string momState = str.tostring(rsiVal, "#")

if rsiVal >= rsiBullMin
    momScore := 2.0
else if rsiVal <= rsiBearMax
    momScore := -2.0
else if rsiVal > 50
    momScore := 1.0
else if rsiVal < 50
    momScore := -1.0
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 6. Relative Volume (directional amplifier)
//------------------------------------------------------------------------------{
avgVol   = ta.sma(volume, volLookback)
volRatio = avgVol > 0 ? volume / avgVol : 1.0

float directionalSum = msScore + emaScore + vwapScore + htfScore + momScore
int   directionalSign = directionalSum > 0 ? 1 : directionalSum < 0 ? -1 : 0

float  volScore = 0.0
string volState = "×" + str.tostring(volRatio, "#.##")

if volRatio >= volHighMult
    volScore := 2.0 * directionalSign
else if volRatio <= volLowMult
    volScore := -1.0 * directionalSign
else
    volScore := 0.5 * directionalSign
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 7. Unmitigated Session Highs/Lows (Liquidity Magnets)
//------------------------------------------------------------------------------{
var float asiaRunHi = na
var float asiaRunLo = na
var float lonRunHi  = na
var float lonRunLo  = na
var float nyRunHi   = na
var float nyRunLo   = na

var float asiaHi = na
var float asiaLo = na
var float lonHi  = na
var float lonLo  = na
var float nyHi   = na
var float nyLo   = na
var float pdHi   = na
var float pdLo   = na

var bool wasInAsia = false
var bool wasInLon  = false
var bool wasInNy   = false

bool inAsia = in_session(asiaSess, liqTz)
bool inLon  = in_session(londonSess, liqTz)
bool inNy   = in_session(nySess, liqTz)

if inAsia and not wasInAsia
    asiaRunHi := high
    asiaRunLo := low
else if inAsia
    asiaRunHi := math.max(nz(asiaRunHi, high), high)
    asiaRunLo := math.min(nz(asiaRunLo, low),  low)
if not inAsia and wasInAsia
    asiaHi := asiaRunHi
    asiaLo := asiaRunLo
wasInAsia := inAsia

if inLon and not wasInLon
    lonRunHi := high
    lonRunLo := low
else if inLon
    lonRunHi := math.max(nz(lonRunHi, high), high)
    lonRunLo := math.min(nz(lonRunLo, low),  low)
if not inLon and wasInLon
    lonHi := lonRunHi
    lonLo := lonRunLo
wasInLon := inLon

if inNy and not wasInNy
    nyRunHi := high
    nyRunLo := low
else if inNy
    nyRunHi := math.max(nz(nyRunHi, high), high)
    nyRunLo := math.min(nz(nyRunLo, low),  low)
if not inNy and wasInNy
    nyHi := nyRunHi
    nyLo := nyRunLo
wasInNy := inNy

float pdHiRef = request.security(syminfo.tickerid, "1D", high[1], lookahead = barmerge.lookahead_on)
float pdLoRef = request.security(syminfo.tickerid, "1D", low[1],  lookahead = barmerge.lookahead_on)
bool isNewDay = ta.change(time("1D")) != 0
if trackPDHL and isNewDay
    pdHi := pdHiRef
    pdLo := pdLoRef

if not na(asiaHi) and high >= asiaHi
    asiaHi := na
if not na(asiaLo) and low  <= asiaLo
    asiaLo := na
if not na(lonHi)  and high >= lonHi
    lonHi  := na
if not na(lonLo)  and low  <= lonLo
    lonLo  := na
if not na(nyHi)   and high >= nyHi
    nyHi   := na
if not na(nyLo)   and low  <= nyLo
    nyLo   := na
if not na(pdHi)   and high >= pdHi
    pdHi   := na
if not na(pdLo)   and low  <= pdLo
    pdLo   := na

int unHi = 0
int unLo = 0
if not na(asiaHi) and asiaHi > close
    unHi += 1
if not na(lonHi)  and lonHi  > close
    unHi += 1
if not na(nyHi)   and nyHi   > close
    unHi += 1
if trackPDHL and not na(pdHi) and pdHi > close
    unHi += 1

if not na(asiaLo) and asiaLo < close
    unLo += 1
if not na(lonLo)  and lonLo  < close
    unLo += 1
if not na(nyLo)   and nyLo   < close
    unLo += 1
if trackPDHL and not na(pdLo) and pdLo < close
    unLo += 1

float  liqScore = 0.0
string liqState = "↑" + str.tostring(unHi) + " ↓" + str.tostring(unLo)

int imbalance = unHi - unLo

if unHi == 0 and unLo == 0
    liqScore := 0.0
    liqState := "No Data"
else if unHi == 0 and unLo > 0
    liqScore := 1.0
    liqState := "Uncharted ↓" + str.tostring(unLo)
else if unLo == 0 and unHi > 0
    liqScore := -1.0
    liqState := "Basement ↑" + str.tostring(unHi)
else if imbalance >= 3
    liqScore := 2.0
else if imbalance >= 1
    liqScore := 1.0
else if imbalance <= -3
    liqScore := -2.0
else if imbalance <= -1
    liqScore := -1.0
else
    liqScore := 0.0
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 8. IB Range Width Classification
//------------------------------------------------------------------------------{
// Track the IB (Initial Balance) high and low during 9:30-10:30 ET.
// Once the IB session ends, lock the range and store it in a rolling buffer.
// Compare today's IB to the average of the last N completed IB ranges — not
// the daily ATR. This answers "is this IB tight or wide relative to what the
// IB has been doing?" rather than comparing to the full-day range.

var float ibRunHi    = na
var float ibRunLo    = na
var float ibLockedHi = na
var float ibLockedLo = na
var bool  wasInIB    = false
var bool  ibComplete = false

// Rolling buffer of completed IB ranges (stores the last ibAvgLen values)
var array<float> ibHistory = array.new_float(0)

bool inIB = in_session(ibSess, ibTz)

// Reset at the start of each new IB session
if inIB and not wasInIB
    ibRunHi   := high
    ibRunLo   := low
    ibComplete := false
else if inIB
    ibRunHi := math.max(nz(ibRunHi, high), high)
    ibRunLo := math.min(nz(ibRunLo, low),  low)

// Lock the IB when the session ends, push to history
if not inIB and wasInIB
    ibLockedHi := ibRunHi
    ibLockedLo := ibRunLo
    ibComplete := true
    // Store completed IB range in the rolling buffer
    float completedRange = ibRunHi - ibRunLo
    if not na(completedRange) and completedRange > 0
        array.push(ibHistory, completedRange)
        // Trim to keep only the last ibAvgLen entries
        if array.size(ibHistory) > ibAvgLen
            array.shift(ibHistory)

wasInIB := inIB

// Use developing range if still inside IB, locked range if IB is complete
float ibHigh  = ibComplete ? ibLockedHi : (inIB ? ibRunHi : ibLockedHi)
float ibLow   = ibComplete ? ibLockedLo : (inIB ? ibRunLo : ibLockedLo)
float ibRange = not na(ibHigh) and not na(ibLow) ? ibHigh - ibLow : na

// Average of prior completed IB ranges (excludes today's developing/current IB)
float avgIBRange = array.size(ibHistory) >= 2 ? array.avg(ibHistory) : na

// Ratio: today's IB vs the rolling average IB
float  ibRatio    = not na(ibRange) and not na(avgIBRange) and avgIBRange > 0 ? ibRange / avgIBRange : na
string ibTier     = "Waiting"
color  ibTierColor = ibNormalColor
string ibDetail   = ""

if not na(ibRatio)
    if ibRatio >= ibExtremeThresh
        ibTier      := "EXTREME"
        ibTierColor := ibExtremeColor
    else if ibRatio >= ibWideThresh
        ibTier      := "WIDE"
        ibTierColor := ibWideColor
    else if ibRatio < ibNarrowThresh
        ibTier      := "NARROW"
        ibTierColor := ibNarrowColor
    else
        ibTier      := "NORMAL"
        ibTierColor := ibNormalColor

    ibDetail := str.tostring(ibRange, "#.#") + "pts | Avg " + str.tostring(avgIBRange, "#.#") + " | " + str.tostring(ibRatio * 100, "#") + "%"
else
    ibDetail := inIB ? "Forming..." : (array.size(ibHistory) < 2 ? "Need data..." : "No Data")

// Setup recommendation based on tier
string ibSetupHint = switch ibTier
    "NARROW"  => "→ Break setups (C/D)"
    "NORMAL"  => "→ Any setup"
    "WIDE"    => "→ Bounce setups (A/B)"
    "EXTREME" => "→ Skip / fade only"
    => ""
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 9. Daily ATR Reference
//------------------------------------------------------------------------------{
// Pulls the 14-day ATR from the daily chart so you can see how today's IB
// and current session range compare to the average full-day range.
// This is context, not a classification — it tells you how much runway is left.

float dailyATR = request.security(syminfo.tickerid, "1D", ta.atr(atrLen), lookahead = barmerge.lookahead_off)

// Today's developing session range (RTH high - RTH low so far)
// We can reuse the NY session tracking: nyRunHi/nyRunLo if inside NY, else last locked
float sessionHi    = inNy ? nz(nyRunHi, high) : nz(nyHi, na)
float sessionLo    = inNy ? nz(nyRunLo, low)  : nz(nyLo, na)
float sessionRange = not na(sessionHi) and not na(sessionLo) ? sessionHi - sessionLo : na

// How much of the daily ATR has been consumed by the IB and by the session so far
float ibPctOfATR      = not na(ibRange) and not na(dailyATR) and dailyATR > 0 ? (ibRange / dailyATR) * 100.0 : na
float sessionPctOfATR = not na(sessionRange) and not na(dailyATR) and dailyATR > 0 ? (sessionRange / dailyATR) * 100.0 : na

string atrDetail = not na(dailyATR) ? str.tostring(dailyATR, "#.#") + "pts" : "N/A"
string atrIBPct  = not na(ibPctOfATR) ? "IB " + str.tostring(ibPctOfATR, "#") + "%" : ""
string atrSessPct = not na(sessionPctOfATR) ? " | Sess " + str.tostring(sessionPctOfATR, "#") + "%" : ""
string atrUsage  = atrIBPct + atrSessPct

// Runway remaining: how much of the ATR hasn't been used yet
float atrRemaining = not na(sessionRange) and not na(dailyATR) ? math.max(0.0, dailyATR - sessionRange) : na
string atrRunway   = not na(atrRemaining) ? str.tostring(atrRemaining, "#.#") + "pts left" : ""
//------------------------------------------------------------------------------}
// Composite Score + Percentage
//------------------------------------------------------------------------------{
float rawSum =
     msScore   * msWeight   +
     emaScore  * emaWeight  +
     vwapScore * vwapWeight +
     htfScore  * htfWeight  +
     momScore  * momWeight  +
     volScore  * volWeight  +
     liqScore  * liqWeight

float maxPossible = 2.0 * (msWeight + emaWeight + vwapWeight + htfWeight + momWeight + volWeight + liqWeight)
float finalScore  = maxPossible > 0 ? clamp((rawSum / maxPossible) * 10.0, -10.0, 10.0) : 0.0
float absScore    = math.abs(finalScore)

float bullPct = (finalScore + 10.0) / 20.0 * 100.0
float bearPct = 100.0 - bullPct

int agreeCount = 0
if finalScore > 0
    agreeCount := (msScore > 0 ? 1 : 0) + (emaScore > 0 ? 1 : 0) + (vwapScore > 0 ? 1 : 0) + (htfScore > 0 ? 1 : 0) + (momScore > 0 ? 1 : 0) + (volScore > 0 ? 1 : 0) + (liqScore > 0 ? 1 : 0)
else if finalScore < 0
    agreeCount := (msScore < 0 ? 1 : 0) + (emaScore < 0 ? 1 : 0) + (vwapScore < 0 ? 1 : 0) + (htfScore < 0 ? 1 : 0) + (momScore < 0 ? 1 : 0) + (volScore < 0 ? 1 : 0) + (liqScore < 0 ? 1 : 0)

color  gradeColor = cautColor
string gradeEmoji = cautEmoji
string gradeLabel = "Caution"

if absScore <= chopCeiling
    gradeColor := chopColor
    gradeEmoji := chopEmoji
    gradeLabel := "CHOP"
else if absScore >= eliteFloor
    gradeColor := eliteColor
    gradeEmoji := eliteEmoji
    gradeLabel := "Elite"
else if absScore >= strongFloor
    gradeColor := strongColor
    gradeEmoji := strongEmoji
    gradeLabel := "Strong"
else if absScore >= medFloor
    gradeColor := medColor
    gradeEmoji := medEmoji
    gradeLabel := "Medium"

string directionLabel = finalScore > chopCeiling ? "BULLISH" : finalScore < -chopCeiling ? "BEARISH" : "CHOP"
color  directionColor = finalScore > chopCeiling ? bullColor : finalScore < -chopCeiling ? bearColor : chopColor
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// Bar Rendering
//------------------------------------------------------------------------------{
render_bar(table t, int row, int colStart, float score, color fillColor) =>
    int halfSegs = BAR_SEGMENTS / 2
    int filledCells = int(math.round(math.abs(score) / 2.0 * halfSegs))
    filledCells := math.min(halfSegs, filledCells)

    for i = 0 to BAR_SEGMENTS - 1
        int col = colStart + i
        bool isLeftHalf = i < halfSegs
        int  distFromCenter = isLeftHalf ? halfSegs - i : i - halfSegs + 1

        color cellColor = na
        if score < 0 and isLeftHalf and distFromCenter <= filledCells
            cellColor := fillColor
        else if score > 0 and not isLeftHalf and distFromCenter <= filledCells
            cellColor := fillColor
        else
            cellColor := color.new(rowBgColor, barEmptyTransp)

        table.cell(t, col, row, "", bgcolor = cellColor, text_size = size.tiny)
//------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// Table Rendering (dynamic row count — unchecked rows are skipped)
//------------------------------------------------------------------------------{
// Count how many rows are needed based on toggles, then build the table
// with only that many rows. A running row counter `r` advances only when
// a section is enabled, so the table compacts automatically.

// Pre-count total rows needed
int totalRows = 0
if showHeader
    totalRows += 3  // banner + split bar + column headers
if showStructure
    totalRows += 1
if showEma
    totalRows += 1
if showVwap
    totalRows += 1
if showHtf
    totalRows += 1
if showMomentum
    totalRows += 1
if showVolume
    totalRows += 1
if showLiquidity
    totalRows += 1
if showComposite
    totalRows += 2  // score + bias label
if showIBRange
    totalRows += 2  // tier + setup hint
if showATR
    totalRows += 2  // ATR + runway

// Ensure at least 1 row so table.new doesn't error
totalRows := math.max(totalRows, 1)

var table biasTable = table.new(get_table_pos(tablePos), 13, totalRows, border_width = 1, border_color = color.new(color.gray, 70))

format_signed(s) =>
    (s > 0 ? "+" : "") + str.tostring(s, "#.#")

render_split_bar(table t, int row, float bullPctVal) =>
    for i = 0 to BAR_SEGMENTS - 1
        int col = 3 + i
        float cellPct = (i + 1) * (100.0 / BAR_SEGMENTS)
        float cellPctStart = i * (100.0 / BAR_SEGMENTS)

        color cellColor = na
        float bearFillEdge = 100.0 - bullPctVal
        if cellPct <= bearFillEdge
            cellColor := color.new(bearColor, 20)
        else if cellPctStart >= bearFillEdge
            cellColor := color.new(bullColor, 20)
        else
            cellColor := bullPctVal > 50 ? color.new(bullColor, 20) : color.new(bearColor, 20)

        table.cell(t, col, row, "", bgcolor = cellColor, text_size = size.tiny)

// Helper: fill bar columns with a single color (for non-component rows)
fill_bar_empty(table t, int row, color bg) =>
    for col = 3 to 12
        table.cell(t, col, row, "", bgcolor = bg, text_size = size.tiny)

if barstate.islast
    txtSz = get_text_size(tableTextSz)
    int r = 0  // Running row counter

    // === Header: Bias banner + split bar + column headers ===
    if showHeader
        bullPctStr = str.tostring(math.round(bullPct), "#") + "%"
        bearPctStr = str.tostring(math.round(bearPct), "#") + "%"
        table.cell(biasTable, 0, r, "BIAS", text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, "BEAR " + bearPctStr, text_color = labelTextColor, bgcolor = color.new(bearColor, 40), text_size = txtSz)
        table.cell(biasTable, 2, r, "BULL " + bullPctStr, text_color = labelTextColor, bgcolor = color.new(bullColor, 40), text_size = txtSz)
        fill_bar_empty(biasTable, r, headerBgColor)
        r += 1

        table.cell(biasTable, 0, r, "", bgcolor = headerBgColor, text_size = size.tiny)
        table.cell(biasTable, 1, r, "", bgcolor = headerBgColor, text_size = size.tiny)
        table.cell(biasTable, 2, r, "", bgcolor = headerBgColor, text_size = size.tiny)
        render_split_bar(biasTable, r, bullPct)
        r += 1

        table.cell(biasTable, 0, r, "Component", text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, "State",     text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 2, r, "Score",     text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        fill_bar_empty(biasTable, r, headerBgColor)
        r += 1

    // === Component rows ===
    if showStructure
        msColor = msScore > 0 ? bullColor : msScore < 0 ? bearColor : neutColor
        table.cell(biasTable, 0, r, "Structure", text_color = labelTextColor, bgcolor = rowBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, msState,     text_color = labelTextColor, bgcolor = color.new(msColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, format_signed(msScore * msWeight), text_color = labelTextColor, bgcolor = color.new(msColor, tableBgTransp), text_size = txtSz)
        render_bar(biasTable, r, 3, msScore, msColor)
        r += 1

    if showEma
        emaColor = emaScore > 0 ? bullColor : emaScore < 0 ? bearColor : neutColor
        table.cell(biasTable, 0, r, "EMA Stack", text_color = labelTextColor, bgcolor = rowBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, emaState,    text_color = labelTextColor, bgcolor = color.new(emaColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, format_signed(emaScore * emaWeight), text_color = labelTextColor, bgcolor = color.new(emaColor, tableBgTransp), text_size = txtSz)
        render_bar(biasTable, r, 3, emaScore, emaColor)
        r += 1

    if showVwap
        vwapColorCell = vwapScore > 0 ? bullColor : vwapScore < 0 ? bearColor : neutColor
        table.cell(biasTable, 0, r, "VWAP",      text_color = labelTextColor, bgcolor = rowBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, vwapState,   text_color = labelTextColor, bgcolor = color.new(vwapColorCell, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, format_signed(vwapScore * vwapWeight), text_color = labelTextColor, bgcolor = color.new(vwapColorCell, tableBgTransp), text_size = txtSz)
        render_bar(biasTable, r, 3, vwapScore, vwapColorCell)
        r += 1

    if showHtf
        htfColor = htfScore > 0 ? bullColor : htfScore < 0 ? bearColor : neutColor
        table.cell(biasTable, 0, r, "HTF 1H/4H", text_color = labelTextColor, bgcolor = rowBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, htfState,    text_color = labelTextColor, bgcolor = color.new(htfColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, format_signed(htfScore * htfWeight), text_color = labelTextColor, bgcolor = color.new(htfColor, tableBgTransp), text_size = txtSz)
        render_bar(biasTable, r, 3, htfScore, htfColor)
        r += 1

    if showMomentum
        momColor = momScore > 0 ? bullColor : momScore < 0 ? bearColor : neutColor
        table.cell(biasTable, 0, r, "Momentum",  text_color = labelTextColor, bgcolor = rowBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, "RSI " + momState, text_color = labelTextColor, bgcolor = color.new(momColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, format_signed(momScore * momWeight), text_color = labelTextColor, bgcolor = color.new(momColor, tableBgTransp), text_size = txtSz)
        render_bar(biasTable, r, 3, momScore, momColor)
        r += 1

    if showVolume
        volColor = volScore > 0 ? bullColor : volScore < 0 ? bearColor : neutColor
        table.cell(biasTable, 0, r, "Volume",    text_color = labelTextColor, bgcolor = rowBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, volState,    text_color = labelTextColor, bgcolor = color.new(volColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, format_signed(volScore * volWeight), text_color = labelTextColor, bgcolor = color.new(volColor, tableBgTransp), text_size = txtSz)
        render_bar(biasTable, r, 3, volScore, volColor)
        r += 1

    if showLiquidity
        liqColor = liqScore > 0 ? bullColor : liqScore < 0 ? bearColor : neutColor
        table.cell(biasTable, 0, r, "Liquidity", text_color = labelTextColor, bgcolor = rowBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, liqState,    text_color = labelTextColor, bgcolor = color.new(liqColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, format_signed(liqScore * liqWeight), text_color = labelTextColor, bgcolor = color.new(liqColor, tableBgTransp), text_size = txtSz)
        render_bar(biasTable, r, 3, liqScore, liqColor)
        r += 1

    // === Composite score + bias ===
    if showComposite
        scoreStr = format_signed(finalScore) + " / 10"
        gradeStr = gradeEmoji + " " + gradeLabel
        table.cell(biasTable, 0, r, "COMPOSITE", text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, gradeStr,    text_color = labelTextColor, bgcolor = color.new(gradeColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, scoreStr,    text_color = labelTextColor, bgcolor = color.new(gradeColor, tableBgTransp), text_size = txtSz)
        fill_bar_empty(biasTable, r, headerBgColor)
        r += 1

        agreeStr = str.tostring(agreeCount) + "/7 agree"
        table.cell(biasTable, 0, r, "BIAS", text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, directionLabel, text_color = labelTextColor, bgcolor = color.new(directionColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, agreeStr,       text_color = labelTextColor, bgcolor = color.new(directionColor, tableBgTransp), text_size = txtSz)
        fill_bar_empty(biasTable, r, headerBgColor)
        r += 1

    // === IB Range Width ===
    if showIBRange
        table.cell(biasTable, 0, r, "IB RANGE", text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, ibTier,     text_color = labelTextColor, bgcolor = color.new(ibTierColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, ibDetail,   text_color = labelTextColor, bgcolor = color.new(ibTierColor, tableBgTransp), text_size = txtSz)
        for col = 3 to 12
            table.cell(biasTable, col, r, "", bgcolor = color.new(ibTierColor, barEmptyTransp), text_size = size.tiny)
        r += 1

        table.cell(biasTable, 0, r, "SETUP", text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, ibSetupHint, text_color = labelTextColor, bgcolor = color.new(ibTierColor, tableBgTransp), text_size = txtSz)
        string ibStatusStr = inIB ? "⏳ IB Forming" : (ibComplete ? "✓ IB Locked" : "")
        table.cell(biasTable, 2, r, ibStatusStr, text_color = labelTextColor, bgcolor = color.new(ibTierColor, tableBgTransp), text_size = txtSz)
        fill_bar_empty(biasTable, r, headerBgColor)
        r += 1

    // === Daily ATR + Runway ===
    if showATR
        table.cell(biasTable, 0, r, "DAILY ATR", text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, atrDetail,   text_color = labelTextColor, bgcolor = color.new(atrColor, tableBgTransp), text_size = txtSz)
        table.cell(biasTable, 2, r, atrUsage,    text_color = labelTextColor, bgcolor = color.new(atrColor, tableBgTransp), text_size = txtSz)
        for col = 3 to 12
            int idx = col - 3
            float cellThresh = (idx + 1) * 10.0
            color atrCellColor = na
            if not na(sessionPctOfATR) and sessionPctOfATR >= cellThresh
                atrCellColor := sessionPctOfATR <= 100 ? color.new(bullColor, 30) : sessionPctOfATR <= 150 ? color.new(medColor, 30) : color.new(bearColor, 30)
            else
                atrCellColor := color.new(rowBgColor, barEmptyTransp)
            table.cell(biasTable, col, r, "", bgcolor = atrCellColor, text_size = size.tiny)
        r += 1

        table.cell(biasTable, 0, r, "RUNWAY", text_color = labelTextColor, bgcolor = headerBgColor, text_size = txtSz)
        table.cell(biasTable, 1, r, atrRunway, text_color = labelTextColor, bgcolor = color.new(atrColor, tableBgTransp), text_size = txtSz)
        string runwayStatus = ""
        if not na(sessionPctOfATR)
            if sessionPctOfATR < 50
                runwayStatus := "Plenty of room"
            else if sessionPctOfATR < 80
                runwayStatus := "Room to run"
            else if sessionPctOfATR < 100
                runwayStatus := "Getting full"
            else if sessionPctOfATR < 150
                runwayStatus := "Extended"
            else
                runwayStatus := "Overextended"
        table.cell(biasTable, 2, r, runwayStatus, text_color = labelTextColor, bgcolor = color.new(atrColor, tableBgTransp), text_size = txtSz)
        fill_bar_empty(biasTable, r, headerBgColor)
        r += 1
//------------------------------------------------------------------------------}
````
