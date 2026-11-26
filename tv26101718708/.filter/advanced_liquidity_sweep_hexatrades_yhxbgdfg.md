# Advanced Liquidity Sweep [HexaTrades]

- url: https://www.tradingview.com/script/YHXBgDFg-Advanced-Liquidity-Sweep-HexaTrades/
- type: indicator
- pine_id: PUB;ceb9241f14074b69aaecacfb4a3ca00f
- version: 1.0

## Description

Advanced Liquidity Sweep is a Smart Money Concepts (SMC) indicator designed to automatically identify liquidity pools, equal highs and lows, liquidity sweeps, and potential reversal areas. Rather than simply detecting wick breaks, it evaluates each sweep using multiple confirmation factors and assigns a strength score, helping traders distinguish between minor stop hunts and higher-quality liquidity events.

The indicator is designed for cryptocurrencies, stocks, forex, futures, commodities, and indices across all timeframes.


[b]What is Liquidity?[/b]

Financial markets constantly search for liquidity before making significant moves.

Retail traders often place:
• Stop losses below swing lows
• Stop losses above swing highs
• Breakout orders above resistance
• Breakdown orders below support

These orders accumulate into liquidity pools. Large market participants frequently move prices into these areas to fill large positions before reversing or continuing the trend.

This indicator automatically identifies those liquidity pools and highlights when they are swept.


[b]How it works :[/b]

- Map the liquidity.: Confirmed pivot highs become BSL lines, pivot lows become SSL lines. You choose Major and/or Minor swing sizes.

- Cluster equal highs/lows. Several highs (or lows) at nearly the same price form an EQH / EQL cluster, a bigger, juicier liquidity pool that scores higher.

- Detect the sweep (on closed candles only).
• Bearish: price trades above a BSL level but closes back below it.
• Bullish: price trades below an SSL level but closes back above it.

- Score it 0–100. Six factors rate how convincing the rejection was (see below). At/above your Strong threshold, it’s tagged STRONG.

- Draw a sweep zone. Optionally turn each sweep into a supply/demand zone you can watch for re-entry, with optional auto-expiry.

- Filter the noise. Optional Trend, Higher-Timeframe and Filter presets keep only the cleaner grabs.


[b][b]Features[/b][/b]


🔶 [b]Major & Minor Swing Detection[/b]

The indicator detects both major and minor swing highs and lows.
Major swings represent stronger institutional liquidity and usually produce higher-quality reactions.
Minor swings identify shorter-term liquidity that is commonly targeted during intraday trading.

Users can monitor:
• Major swings only
• Minor swings only
• Both simultaneously


[b]🔶Buy-Side Liquidity (BSL)[/b]

Buy-side liquidity forms above previous swing highs.

These areas usually contain:
• Short stop losses
• Breakout buy orders
• Momentum entries
When price trades above these highs before quickly closing back below, the indicator identifies a bearish liquidity sweep.


[b]🔶 Sell-Side Liquidity (SSL)[/b]

Sell-side liquidity forms below previous swing lows.

These areas usually contain:
• Long stop losses
• Panic selling
• Breakdown entries
When price trades below these lows before closing back above, the indicator identifies a bullish liquidity sweep.


[b]🔶 Equal Highs & Equal Lows[/b]

Equal highs and equal lows are some of the strongest liquidity pools because many traders place stops at nearly identical price levels.

The indicator automatically detects these structures using:
• ATR-based tolerance
• Percentage-based tolerance
Equal liquidity levels are highlighted separately and tracked independently from normal swing liquidity.


[b]🔶 Zone Colors[/b]

Here are the zone and line colors used in this indicator and what each one means:

🔴 Red: Buy-Side Liquidity (BSL)
- Represents swing highs where buy-side liquidity is concentrated.
- Commonly contains short stop-loss orders and breakout buy orders.
- These are active, unswept liquidity levels and potential targets for a bearish liquidity sweep.

🟢 Green:  Sell-Side Liquidity (SSL)
- Represents swing lows where sell-side liquidity is concentrated.
- Commonly contains long stop-loss orders and breakdown sell orders.
- These are active, unswept liquidity levels and potential targets for a bullish liquidity sweep.

🟠 Orange: Equal Highs / Equal Lows (EQH / EQL)
- Marks two or more highs or lows formed at nearly the same price.
- These levels are displayed using dashed lines and often contain larger clusters of resting liquidity.
- Sweeps of Equal Highs and Equal Lows typically produce stronger, higher-probability trading opportunities.

⚪ Gray: Swept (Inactive) Liquidity
- Indicates liquidity that has already been swept by price.
- Once a level has been taken, it changes to gray and becomes inactive.
- This helps distinguish spent liquidity from active levels that may still attract future price movement.

[b] Sweep Signal Colors[/b]

🟩 Bullish Liquidity Sweep
-Appears when  Sell-Side Liquidity (SSL) or an Equal Low (EQL) is swept.
-Price trades below the liquidity level but closes back above it, confirming a bullish liquidity sweep.

🟪 Bearish Liquidity Sweep
-  Appears when  Buy-Side Liquidity (BSL) or an Equal High (EQH ) is swept.
- Price trades above the liquidity level but closes back below it, confirming a bearish liquidity sweep.


[b]🔶 Liquidity Sweep Detection[/b]

A liquidity sweep occurs when price temporarily breaks a liquidity level but fails to hold beyond it.

For a valid sweep:

Bearish Sweep
• Price trades above Buy-Side Liquidity
• The candle closes back below the level

Bullish Sweep
• Price trades below Sell-Side Liquidity
• The candle closes back above the level
Because the signal is generated only after the candle closes, the indicator does not repaint.


[b]🔶Sweep Strength Score[/b]

Every sweep receives a strength score from 0 to 100.

The score combines multiple factors including:
• Wick rejection
• Candle body strength
• Penetration distance beyond liquidity
• Volume confirmation
• Distance from the EMA
• Equal High / Equal Low cluster strength

Higher scores generally indicate stronger liquidity events.

Strength tiers are classified as: Weak, Medium, Strong, and Elite

Users can also define a minimum score to filter out lower-quality sweeps.


[b]🔶 Score Presets[/b]

Three scoring profiles are available:

Conservative: Places greater emphasis on clean rejection candles and body structure.
Balanced: Provides an even weighting across all scoring components and is suitable for most trading styles.
Aggressive: Places greater importance on volume and equal liquidity clusters, making it more responsive to institutional activity.


[b]🔶 Trend & Higher Timeframe Filters[/b]

The indicator includes optional trend confirmation filters to help improve signal quality.
The Trend Filter uses the EMA 50 and EMA 200 to evaluate the current market direction and offers two modes:

Continuation : Displays only sweeps that align with the prevailing trend.
Reversal : Displays only sweeps that occur against the prevailing trend, helping identify potential market reversals.

For additional confirmation, the Higher Timeframe (HTF) Bias Filter compares price with a higher timeframe EMA. When enabled, sweeps are generated only if they align with the broader market trend, helping reduce false signals and improving overall trade selection.


[b]🔶 Liquidity & Sweep Zones[/b]

The indicator provides two complementary ways to visualize liquidity on the chart.

Liquidity Zones highlight swing highs and lows as either horizontal lines, price zones, or both, making it easier to identify areas where liquidity is likely to accumulate. Users can choose between Lines Only, Zones Only, or Both to match their preferred chart style.

When a liquidity sweep occurs, the indicator automatically creates a Sweep Zone around the rejection candle. These zones can be extended into the future, automatically removed after a user-defined period, or kept indefinitely. Sweep zones often serve as potential support or resistance areas, making them useful for identifying future reaction zones, retests, and trade opportunities.



[b]⭐️ Bullish Liquidity Sweep [/b]

Price sweeps below the Sell-Side Liquidity (SSL), triggering stop-loss orders before quickly reversing and closing back above the liquidity level. The Sweep Zone acts as a potential support area, while the strength score helps evaluate the quality of the setup. Traders may look for long opportunities on the confirmation or retest, targeting the next Buy-Side Liquidity (BSL).
Example:
https://www.tradingview.com/x/0gnoHHlU/


[b]⭐️Bearish Liquidity Sweep[/b]

Price sweeps above Buy-Side Liquidity (BSL), triggering breakout orders and stop-losses before reversing and closing back below the liquidity level. The Sweep Zone acts as a potential resistance area, while the strength score helps evaluate the quality of the setup. Traders may look for short opportunities on the rejection or retest, targeting the next Sell-Side Liquidity (SSL
example chart:
https://www.tradingview.com/x/b7ws5BS3/


[b]Alerts[/b]

Built-in alert conditions include:
• Bullish Liquidity Sweep
• Bearish Liquidity Sweep
• Equal High Sweep
• Equal Low Sweep
• Strong Bullish Sweep
• Strong Bearish Sweep
• Next-Candle Confirmed Sweep
• Any Liquidity Sweep
These alerts allow traders to automate notifications without monitoring charts continuously.


[b]How to Use[/b]

The Advanced Liquidity Sweep indicator helps identify where liquidity exists, when it has been swept, and how strong the resulting market reaction is. For the best results, combine it with market structure, support and resistance, and proper risk management.

Bullish Setup:
- Wait for price to sweep a Sell-Side Liquidity (SSL) level.
- The candle should close back above the liquidity level, confirming a bullish sweep.
- Prefer Medium, Strong, or Elite sweep scores for higher-quality setups.
- Use the Trend Filter or Higher Timeframe Bias Filter for additional confirmation.
- Watch for a retest of the Sweep Zone before considering a long entry.
-Place the stop-loss below the sweep low and target nearby resistance or Buy-Side Liquidity.

Bearish Setup:
- Wait for price to sweep a Buy-Side Liquidity (BSL) level.
- The candle should close back below the liquidity level, confirming a bearish sweep.
- Focus on higher-strength sweep scores for better probability.
- Confirm the setup using the Trend or Higher Timeframe filters.
- Look for rejection from the Sweep Zone before entering a short position.
- Place the stop-loss above the sweep high and target nearby support or Sell-Side Liquidity.

Advanced Liquidity Sweep is designed to help traders understand where liquidity exists, identify when it has been taken, and evaluate the quality of each sweep using multiple confirmation factors. Rather than relying on simple wick breaks, it combines liquidity analysis, market structure, trend confirmation, and strength scoring to provide greater context for trading decisions. As with any technical tool, it should be used alongside sound risk management and additional market analysis for the best results.


[i]We would love to hear your suggestions. If you have ideas for new features, indicators, analytics, or improvements, please share your feedback. Your input helps guide future updates and improve the indicator for all traders.[/i]

[i]This indicator is for educational and analytical purposes only. It should not be considered financial advice. Always use proper risk management and make trading decisions based on your own analysis[/i]

## Source Code

````pine
//@version=6
indicator("HexaTrades Advanced Liquidity Sweep", "HexaTrades Advanced Liquidity Sweep", overlay = true,
         max_lines_count  = 500,
         max_labels_count = 500,
         max_boxes_count  = 500)

// ============================================================================
//  USER-DEFINED TYPE — one tracked liquidity level
// ============================================================================
type Liquidity
    float price          // liquidity price (the swing high/low)
    int   bar            // bar_index where the pivot actually sits
    bool  isHigh         // true = buy-side (high), false = sell-side (low)
    bool  isMajor        // true = major swing, false = minor swing
    bool  isEqual        // formed an equal high/low cluster?
    int   touches        // cluster strength (equal touches incl. self)
    bool  swept          // has it been taken?
    int   sweptBar       // bar_index of the sweep
    line  ln             // horizontal level line (Line / Both display)
    label lb             // reserved label handle
    box   zone           // sweep zone box (created on the sweep)
    box   zbox           // liquidity zone box around the level (Zone / Both)
    color baseCol        // base colour, reused by the age-fade renderer
    int   shade          // last transparency bucket applied (-1 = none yet)
    bool  zoneExpired    // sweep zone already expired / removed?

// ============================================================================
//  INPUTS  (simplified — presets replace the raw weight / filter parameters)
// ============================================================================
// ---- Swing & Liquidity Structure -------------------------------------------
gStruct   = "Swing & Liquidity Structure"
swingMode = input.string("Both", "Swing Levels To Detect",
                 options = ["Major Only", "Minor Only", "Both"], group = gStruct,
                 tooltip = "Which pivots become liquidity. Major = larger length (stronger, fewer). Minor = smaller length (more, faster). Both tracks each and de-dupes shared pivots.")
swingLen  = input.int(10, "Major Swing Length", minval = 1, group = gStruct,
                 tooltip = "Bars required on EACH side of a major pivot. Larger = fewer, more significant swings. A pivot confirms this many bars after it forms (inherent non-repaint delay).")
minorLen  = input.int(5,  "Minor Swing Length", minval = 1, group = gStruct,
                 tooltip = "Bars on each side of a minor pivot. Smaller catches faster, more local liquidity.")
maxLevels = input.int(20, "Max Liquidity Levels", minval = 1, maxval = 100, group = gStruct,
                 tooltip = "Hard cap on stored levels. The OLDEST level (and its drawings) is recycled when exceeded, keeping the script within TradingView object limits.")

// ---- Equal Highs / Lows ----------------------------------------------------
gEqual    = "Equal Highs / Lows"
showEqual = input.bool(true, "Detect Equal Highs / Lows (EQH/EQL)", group = gEqual,
                 tooltip = "Cluster nearby same-side levels into equal highs/lows. Clusters are stronger liquidity pools and raise the strength score.")
eqMode    = input.string("ATR", "Tolerance Mode", options = ["ATR", "Percent"], group = gEqual, inline = "eq",
                 tooltip = "How 'equal' is measured. ATR adapts to volatility; Percent is a fixed fraction of price.")
eqTolVal  = input.float(0.10, "Value", minval = 0.0, step = 0.05, group = gEqual, inline = "eq",
                 tooltip = "Tolerance amount. ATR mode: × ATR(14). Percent mode: % of price. Two same-side levels within this distance are treated as equal.")

// ---- Sweep Detection & Score -----------------------------------------------
gSweep      = "Sweep Detection & Score"
useConfirm  = input.bool(false, "Require Next-Candle Confirmation", group = gSweep,
                 tooltip = "Emit an extra CONFIRMED signal one closed bar after a sweep (next candle closes in the sweep direction). The original sweep is never altered.")
scorePreset = input.string("Balanced", "Score Preset",
                 options = ["Conservative", "Balanced", "Aggressive"], group = gSweep,
                 tooltip = "Weighting profile for the 0-100 strength score.\n• Balanced = default factor mix.\n• Conservative = rewards clean wick/body rejection.\n• Aggressive = rewards volume & equal clusters.")
strongScore = input.int(70, "Strong Sweep Threshold", minval = 0, maxval = 100, group = gSweep,
                 tooltip = "Score at/above which a sweep is tagged STRONG — drives strong-sweep alerts, bar colouring and the 'Strong' label tier.")
useMinScore = input.bool(false, "Hide Sweeps Below Min Score", group = gSweep, inline = "ms",
                 tooltip = "When on, low-quality sweeps still close their level but produce no label / zone / signal.")
minScore    = input.int(50, "", minval = 0, maxval = 100, group = gSweep, inline = "ms",
                 tooltip = "Minimum score to draw and signal a sweep (when the filter on the left is enabled).")

// ---- Filters ---------------------------------------------------------------
gFilt        = "Filters"
filterPreset = input.string("Off", "Filter Preset",
                 options = ["Off", "Normal", "Strict"], group = gFilt,
                 tooltip = "False-signal filtering strength.\n• Off = no candle filters (default).\n• Normal = wick + volume.\n• Strict = wick + body + volume + range + penetration.")
useTrend  = input.bool(false, "Trend Filter (fast/slow EMA)", group = gFilt, inline = "tr",
                 tooltip = "Only accept sweeps aligned with the EMA50/EMA200 bias.")
trendMode = input.string("Continuation", "", options = ["Continuation", "Reversal"], group = gFilt, inline = "tr",
                 tooltip = "Continuation: a bullish sweep needs bullish bias. Reversal: a bullish sweep needs bearish bias (counter-trend stop-hunts).")
useHtf    = input.bool(false, "HTF Bias Filter", group = gFilt, inline = "htf",
                 tooltip = "Only accept sweeps aligned with the higher-timeframe EMA bias.")
htfTf     = input.timeframe("240", "", group = gFilt, inline = "htf",
                 tooltip = "Higher timeframe for the bias filter. Requested with lookahead OFF — non-repainting.")

// ---- Liquidity Display -----------------------------------------------------
gDisp        = "Liquidity Display"
liqStyle     = input.string("Both", "Display Style", options = ["Line", "Zone", "Both"], group = gDisp,
                 tooltip = "Line = single horizontal level. Zone = a thin box around the level. Both = line + zone.")
zoneLookback = input.int(500, "Lookback Window (bars)", minval = 10, maxval = 5000, step = 10, group = gDisp,
                 tooltip = "Only keep levels/zones formed within the last N candles; older drawings are deleted automatically to keep the chart clean.")
useFade      = input.bool(true, "Fade Old Levels", group = gDisp,
                 tooltip = "Newer levels appear bright and gradually fade as they age. Equal H/L levels stay highlighted; swept levels are subdued.")
hideSwept    = input.bool(false, "Hide Swept Levels", group = gDisp,
                 tooltip = "Delete a level's line/zone the moment it is swept (instead of subduing its colour).")

// ---- Sweep Zones -----------------------------------------------------------
gZones         = "Sweep Zones"
showZone       = input.bool(true, "Enable Sweep Zones", group = gZones,
                 tooltip = "Draw a box over the sweep candle's rejection range when a sweep is emitted.")
zoneExtend     = input.int(0, "Extension Length (bars)", minval = 0, maxval = 500, group = gZones,
                 tooltip = "Project the sweep-zone box this many bars to the right of the sweep.")
zoneExpireMode = input.string("Never", "Expiration",
                 options = ["Never", "50 Bars", "100 Bars"], group = gZones,
                 tooltip = "When to remove a sweep zone after it forms (Never, or after 50 / 100 bars).")

// ---- Labels & Dashboard ----------------------------------------------------
gPanel     = "Labels & Dashboard"
showLabels = input.bool(true, "Show Sweep Labels", group = gPanel,
                 tooltip = "Print a compact label (tag + score + tier) at each emitted sweep.")
dashPos    = input.string("Top Right", "Dashboard Position",
                 options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gPanel,
                 tooltip = "Where to anchor the information dashboard.")

// ---- Colors ----------------------------------------------------------------
gCol     = "Colors"
colHigh  = input.color(color.new(color.red,    0), "Buy-Side (BSL)",  group = gCol,
                 tooltip = "Colour for buy-side liquidity lines/zones (swing highs above price).")
colLow   = input.color(color.new(color.green,  0), "Sell-Side (SSL)", group = gCol,
                 tooltip = "Colour for sell-side liquidity lines/zones (swing lows below price).")
colEqual = input.color(color.new(color.orange, 0), "Equal H/L",       group = gCol,
                 tooltip = "Colour for equal-high/low clusters (kept highlighted as they age).")
colSwept = input.color(color.new(color.gray,  40), "Swept Level",     group = gCol,
                 tooltip = "Subdued colour applied to a level once it has been swept.")
colBull  = input.color(color.new(color.lime,    0), "Bullish (Buy) Sweep",  group = gCol,
                 tooltip = "Colour for bullish sweeps (sell-side liquidity taken, closed back up).")
colBear  = input.color(color.new(color.fuchsia, 0), "Bearish (Sell) Sweep", group = gCol,
                 tooltip = "Colour for bearish sweeps (buy-side liquidity taken, closed back down).")

// ============================================================================
//  HARDCODED DEFAULTS  (formerly cosmetic / rarely-changed inputs)
//  These reproduce the original default behaviour exactly. Edit here if needed.
// ============================================================================
showLines       = true                       // master draw switch
zoneAtr         = 0.10                        // min liquidity-zone half-thickness (×ATR)
extendLive      = true                        // extend active levels to the live bar
fadeMax         = 70                          // oldest-level fade transparency
useZoneWindow   = true                        // honour the Lookback Window
autoHideWeak    = false                       // hide minor singleton lines
showScoreLbl    = true                        // score line on labels
showTierLbl     = true                        // tier word on labels
compactMode     = false                       // tight labels
colorBars       = true                        // colour the sweep candle
showDash        = true                        // show the dashboard
dashSize        = "Small"                     // dashboard text size
sweepZoneTransp = 85                          // sweep-zone fill transparency
sweepZoneBorder = 40                          // sweep-zone border transparency
deleteOnExpire  = true                        // delete (vs fade) expired sweep zones
volLen          = 20                          // volume SMA length
emaFastLen      = 50                          // fast EMA (trend + score)
emaSlowLen      = 200                         // slow EMA (trend bias)
htfLen          = 50                          // HTF EMA length

// ============================================================================
//  PRESET RESOLUTION  (maps presets → the exact variables the engine uses)
//  Defaults: Score "Balanced" and Filter "Off" reproduce the original output.
// ============================================================================
// Score weights — "Balanced" equals the original default weights.
wWick = scorePreset == "Conservative" ? 1.2 : scorePreset == "Aggressive" ? 0.8 : 1.0
wAtr  = scorePreset == "Conservative" ? 1.0 : scorePreset == "Aggressive" ? 0.8 : 1.0
wVol  = scorePreset == "Conservative" ? 0.5 : scorePreset == "Aggressive" ? 1.2 : 0.8
wBody = scorePreset == "Conservative" ? 1.2 : scorePreset == "Aggressive" ? 0.8 : 1.0
wEma  = scorePreset == "Conservative" ? 0.4 : scorePreset == "Aggressive" ? 0.8 : 0.6
wEq   = scorePreset == "Conservative" ? 1.0 : scorePreset == "Aggressive" ? 0.6 : 0.8

// Filters — "Off" disables everything (the original default).
fpNormal = filterPreset == "Normal"
fpStrict = filterPreset == "Strict"
useWick     = fpNormal or fpStrict
minWickPct  = fpStrict ? 40.0 : 33.0
useBody     = fpStrict
minBodyPct  = 20.0
useVol      = fpNormal or fpStrict
volMult     = fpStrict ? 1.2 : 1.0
useRange    = fpStrict                       // Strict only (niche)
minRangeMul = 0.5
useAtrDist  = fpStrict                       // Strict only (niche)
atrDistMult = 0.10
useWB       = false                          // legacy wick/body ratio — off
minWB       = 1.5

// Sweep-zone expiry from the dropdown.
useZoneExpire  = zoneExpireMode != "Never"
zoneExpireBars = zoneExpireMode == "50 Bars" ? 50 : zoneExpireMode == "100 Bars" ? 100 : 50

// ============================================================================
//  CORE CALCULATIONS  (all ta.* / request.* called every bar, global scope)
// ============================================================================
atr        = ta.atr(14)
emaFast    = ta.ema(close, emaFastLen)
emaSlow    = ta.ema(close, emaSlowLen)
volSma     = ta.sma(volume, volLen)
trendBull  = emaFast > emaSlow
trendBear  = emaFast < emaSlow

// Higher-timeframe bias (lookahead OFF → non-repainting)
[htfClose, htfEma] = request.security(syminfo.tickerid, htfTf,
                         [close, ta.ema(close, htfLen)],
                         lookahead = barmerge.lookahead_off)
htfBull = htfClose > htfEma
htfBear = htfClose < htfEma

// Volume confirmation + equal tolerance (price units)
volOk = not useVol or (volume > volSma * volMult)
eqTol = eqMode == "ATR" ? atr * eqTolVal : close * eqTolVal / 100.0

// ============================================================================
//  PERSISTENT STORAGE & PER-BAR STATE
// ============================================================================
var array<Liquidity> levels = array.new<Liquidity>()

// Dashboard / last-sweep memory
var string lastSweepType = "—"
var string lastSweepDir  = "—"
var float  lastScore     = na

// Pending (un-confirmed) sweep state for next-candle confirmation
var bool  pendBull   = false
var bool  pendBear   = false
var float pendBullHi = na
var float pendBearLo = na

// Per-bar signal flags (drive barcolor / plotshape / alerts)
bool sigBull       = false
bool sigBear       = false
bool sigBullEq     = false
bool sigBearEq     = false
bool sigBullCf     = false
bool sigBearCf     = false
bool sigStrongBull = false
bool sigStrongBear = false

// ============================================================================
//  HELPERS — filters & scoring (pure; identical math to prior versions)
// ============================================================================
// Penetration (ATR) beyond the level
atrDistOk(float pierce) =>
    not useAtrDist or pierce >= atr * atrDistMult

// Wick-rejection test on the current candle
wickOk(bool bearish) =>
    float rng = high - low
    bool ok = true
    if useWick and rng > 0
        float rej = bearish ? (high - close) / rng : (close - low) / rng
        ok := rej * 100.0 >= minWickPct
    else if useWick and rng <= 0
        ok := false
    ok

// Body-rejection test: real body closing AGAINST the sweep direction
bodyOk(bool bearish) =>
    float rng = high - low
    bool ok = true
    if useBody and rng > 0
        float body = bearish ? (open - close) : (close - open)
        ok := math.max(body, 0.0) / rng * 100.0 >= minBodyPct
    else if useBody and rng <= 0
        ok := false
    ok

// Wick-to-body ratio test
wbOk(bool bearish) =>
    bool ok = true
    if useWB
        float body = math.abs(close - open)
        float wick = bearish ? (high - math.max(open, close)) : (math.min(open, close) - low)
        ok := body > 0 ? (wick / body) >= minWB : wick > 0
    ok

// Low-range guard
rangeOk() =>
    not useRange or (atr > 0 and (high - low) >= atr * minRangeMul)

// Trend filter for a given sweep direction
trendOk(bool bullishSweep) =>
    bool ok = true
    if useTrend
        ok := trendMode == "Continuation" ? (bullishSweep ? trendBull : trendBear) : (bullishSweep ? trendBear : trendBull)
    ok

// HTF bias filter for a given sweep direction
htfOk(bool bullishSweep) =>
    not useHtf or (bullishSweep ? htfBull : htfBear)

// Multi-factor strength score (0-100) — evaluated on the confirmed sweep candle
sweepScore(bool bullish, float pierce, int touches) =>
    float rng      = math.max(high - low, syminfo.mintick)
    float wickComp = math.max(bullish ? (close - low) / rng : (high - close) / rng, 0.0)
    float bodyRaw  = bullish ? (close - open) : (open - close)
    float bodyComp = math.min(math.max(bodyRaw, 0.0) / rng, 1.0)
    float atrComp  = atr > 0 ? math.min(pierce / atr, 1.0) : 0.0
    float volComp  = volSma > 0 ? math.min(volume / (volSma * 2.0), 1.0) : 0.0
    float emaComp  = atr > 0 ? math.min(math.abs(close - emaFast) / (atr * 3.0), 1.0) : 0.0
    float eqComp   = math.min(touches / 3.0, 1.0)
    float raw  = wickComp * wWick + atrComp * wAtr + volComp * wVol +
                 bodyComp * wBody + emaComp * wEma + eqComp * wEq
    float wsum = wWick + wAtr + wVol + wBody + wEma + wEq
    wsum > 0 ? math.min(raw / wsum * 100.0, 100.0) : 0.0

// Strength tier word from a score
scoreTier(float s) =>
    s >= 90 ? "Elite" : s >= strongScore ? "Strong" : s >= 50 ? "Medium" : "Weak"

// ============================================================================
//  HELPERS — UI utilities
// ============================================================================
tablePos() =>
    switch dashPos
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

txtSize() =>
    dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : size.small

// Quantised age → transparency bucket. Returning a small set of discrete values
// means the renderer only repaints a line when its bucket actually changes.
fadeShade(int age) =>
    int a = math.max(age, 0)
    int s = a < 50 ? 0 : a < 150 ? 25 : a < 300 ? 45 : a < 500 ? 60 : 75
    math.min(s, fadeMax)

// Dashboard row writer (aligned key/value). Background is OPAQUE dark navy so
// white / coloured values stay readable on any chart theme (light or dark).
dashRowBg = color.new(#0E1A2B, 0)
dashRow(table t, int r, string k, string v, color vc) =>
    table.cell(t, 0, r, k, text_color = color.new(#B2B5BE, 0), text_size = txtSize(), text_halign = text.align_left,  bgcolor = dashRowBg)
    table.cell(t, 1, r, v, text_color = vc,                    text_size = txtSize(), text_halign = text.align_right, bgcolor = dashRowBg)

// ============================================================================
//  1) SWING LIQUIDITY DETECTION  (pivots confirm after their length in bars)
// ============================================================================
wantMajor = swingMode != "Minor Only"
wantMinor = swingMode != "Major Only"

// ta.* must be called every bar for correct state; the mode gate is applied
// only when consuming the results below.
phMaj = ta.pivothigh(swingLen, swingLen)
plMaj = ta.pivotlow (swingLen, swingLen)
phMin = ta.pivothigh(minorLen, minorLen)
plMin = ta.pivotlow (minorLen, minorLen)

// Register a new liquidity level when a pivot confirms.
addLevel(float price, bool isHigh, bool isMajor, int lenUsed) =>
    int pivotBar = bar_index - lenUsed   // bar where the pivot actually sits

    // De-dupe: skip near-exact duplicates (e.g. major & minor on one pivot).
    bool dup = false
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            Liquidity d = array.get(levels, i)
            if d.isHigh == isHigh and not d.swept and math.abs(d.price - price) <= syminfo.mintick
                dup := true
                break

    if not dup
        // Equal high/low detection vs. recent same-side, unswept levels.
        bool eq      = false
        int  touches = 1
        if showEqual and array.size(levels) > 0
            for i = array.size(levels) - 1 to 0
                Liquidity lq = array.get(levels, i)
                if lq.isHigh == isHigh and not lq.swept and math.abs(lq.price - price) <= eqTol
                    eq         := true
                    lq.isEqual := true
                    lq.touches := lq.touches + 1
                    lq.baseCol := colEqual         // keep the matched level's fade colour in sync
                    touches    := lq.touches
                    if not na(lq.ln)
                        line.set_color(lq.ln, colEqual)
                        line.set_style(lq.ln, line.style_dashed)
                    if not na(lq.zbox)
                        box.set_border_color(lq.zbox, color.new(colEqual, 40))
                        box.set_bgcolor(lq.zbox, color.new(colEqual, 80))
                    break

        color baseCol = eq ? colEqual : (isHigh ? colHigh : colLow)

        // Auto-hide weak minor singletons when requested.
        bool hideWeak = autoHideWeak and not isMajor and not eq
        bool drawLn   = showLines and liqStyle != "Zone" and not hideWeak
        bool drawZone = showLines and liqStyle != "Line" and not hideWeak

        line ln = na
        if drawLn
            ln := line.new(pivotBar, price, bar_index, price,
                     xloc = xloc.bar_index, color = baseCol,
                     width = isMajor ? 2 : 1,
                     style = eq ? line.style_dashed : line.style_solid)

        // Liquidity zone box around the level, built from the pivot candle's
        // wick with an ATR-based minimum thickness so it is always visible.
        box zbox = na
        if drawZone
            float thick = atr * zoneAtr
            float zTop = na
            float zBot = na
            if isHigh
                float bodyTop = math.max(open[lenUsed], close[lenUsed])
                zTop := price
                zBot := math.min(bodyTop, price - thick)
            else
                float bodyBot = math.min(open[lenUsed], close[lenUsed])
                zBot := price
                zTop := math.max(bodyBot, price + thick)
            zbox := box.new(pivotBar, zTop, bar_index, zBot,
                     xloc         = xloc.bar_index,
                     border_color = color.new(baseCol, 40),
                     border_width = isMajor ? 1 : 0,
                     bgcolor      = color.new(baseCol, 80))

        array.push(levels, Liquidity.new(price, pivotBar, isHigh, isMajor, eq, touches,
                     false, na, ln, na, na, zbox, baseCol, -1, false))

        // Recycle the oldest level (FIFO) once over the cap.
        while array.size(levels) > maxLevels
            Liquidity old = array.shift(levels)
            if not na(old.ln)
                line.delete(old.ln)
            if not na(old.lb)
                label.delete(old.lb)
            if not na(old.zone)
                box.delete(old.zone)
            if not na(old.zbox)
                box.delete(old.zbox)

if wantMajor and not na(phMaj)
    addLevel(phMaj, true,  true,  swingLen)
if wantMajor and not na(plMaj)
    addLevel(plMaj, false, true,  swingLen)
if wantMinor and not na(phMin)
    addLevel(phMin, true,  false, minorLen)
if wantMinor and not na(plMin)
    addLevel(plMin, false, false, minorLen)

// ============================================================================
//  2 & 3) SWEEP DETECTION  (only on confirmed bars → non-repainting)
// ============================================================================
// Mark a level as taken: subdue its drawings, or delete them if requested.
markSwept(Liquidity lq) =>
    lq.swept    := true
    lq.sweptBar := bar_index
    if not na(lq.ln)
        line.set_color(lq.ln, colSwept)
        line.set_x2(lq.ln, bar_index)
        line.set_style(lq.ln, line.style_dotted)
    if not na(lq.zbox)
        box.set_right(lq.zbox, bar_index)
        box.set_border_color(lq.zbox, color.new(colSwept, 40))
        box.set_bgcolor(lq.zbox, color.new(colSwept, 85))
    if hideSwept
        if not na(lq.ln)
            line.delete(lq.ln)
            lq.ln := na
        if not na(lq.zbox)
            box.delete(lq.zbox)
            lq.zbox := na

// Draw the sweep zone box + a compact stacked label (only when emitted).
drawSweep(Liquidity lq, bool bullish, float score) =>
    color sigCol = bullish ? colBull : colBear
    if showZone
        float top = bullish ? lq.price : high
        float bot = bullish ? low      : lq.price
        lq.zone := box.new(bar_index - 1, top, bar_index + zoneExtend, bot,
                     border_color = color.new(sigCol, sweepZoneBorder),
                     bgcolor      = color.new(sigCol, sweepZoneTransp))
    if showLabels
        string tag   = lq.isEqual ? (bullish ? "EQL" : "EQH") : (bullish ? "SSL" : "BSL")
        string arrow = bullish ? "▲" : "▼"
        string txt   = tag + " " + arrow
        if not compactMode
            if showScoreLbl
                txt := txt + "\n" + str.tostring(math.round(score))
            if showTierLbl
                txt := txt + "\n" + scoreTier(score)
        else if showScoreLbl
            txt := txt + " " + str.tostring(math.round(score))
        label.new(bar_index, bullish ? low : high, txt,
             style     = bullish ? label.style_label_up : label.style_label_down,
             color     = sigCol,
             textcolor = color.white,
             size      = compactMode ? size.tiny : size.small,
             yloc      = bullish ? yloc.belowbar : yloc.abovebar)

// --- Evaluate sweeps at bar close only --------------------------------------
if barstate.isconfirmed
    // (a) confirm any pending sweep from the previous bar
    if useConfirm and pendBull
        sigBullCf := close > open or close > pendBullHi
        if sigBullCf and showLabels
            label.new(bar_index, low, "✓", style = label.style_label_up,
                 color = colBull, textcolor = color.white, size = size.tiny, yloc = yloc.belowbar)
        pendBull := false
    if useConfirm and pendBear
        sigBearCf := close < open or close < pendBearLo
        if sigBearCf and showLabels
            label.new(bar_index, high, "✓", style = label.style_label_down,
                 color = colBear, textcolor = color.white, size = size.tiny, yloc = yloc.abovebar)
        pendBear := false

    // (b) scan levels for fresh sweeps
    if volOk and rangeOk() and array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            Liquidity lq = array.get(levels, i)
            if not lq.swept
                // BEARISH sweep: wick takes a HIGH, candle closes back below.
                if lq.isHigh and high > lq.price and close < lq.price
                    float pierce = high - lq.price
                    if atrDistOk(pierce) and wickOk(true) and bodyOk(true) and wbOk(true) and trendOk(false) and htfOk(false)
                        float score = sweepScore(false, pierce, lq.touches)
                        bool  emit  = not useMinScore or score >= minScore
                        markSwept(lq)
                        if emit
                            drawSweep(lq, false, score)
                            lastSweepType := lq.isEqual ? "EQH Sweep" : "BSL Sweep"
                            lastSweepDir  := "Bearish"
                            lastScore     := score
                            if lq.isEqual
                                sigBearEq := true
                            else
                                sigBear := true
                            if score >= strongScore
                                sigStrongBear := true
                            if useConfirm
                                pendBear   := true
                                pendBearLo := low
                // BULLISH sweep: wick takes a LOW, candle closes back above.
                else if (not lq.isHigh) and low < lq.price and close > lq.price
                    float pierce = lq.price - low
                    if atrDistOk(pierce) and wickOk(false) and bodyOk(false) and wbOk(false) and trendOk(true) and htfOk(true)
                        float score = sweepScore(true, pierce, lq.touches)
                        bool  emit  = not useMinScore or score >= minScore
                        markSwept(lq)
                        if emit
                            drawSweep(lq, true, score)
                            lastSweepType := lq.isEqual ? "EQL Sweep" : "SSL Sweep"
                            lastSweepDir  := "Bullish"
                            lastScore     := score
                            if lq.isEqual
                                sigBullEq := true
                            else
                                sigBull := true
                            if score >= strongScore
                                sigStrongBull := true
                            if useConfirm
                                pendBull   := true
                                pendBullHi := high

// ============================================================================
//  MAINTENANCE — sweep-zone expiry + lookback-window cleanup (every bar, O(n))
// ============================================================================
if array.size(levels) > 0
    for i = array.size(levels) - 1 to 0
        Liquidity lq = array.get(levels, i)

        // Sweep-zone expiry (fade or delete) once it is old enough.
        if useZoneExpire and lq.swept and not lq.zoneExpired and not na(lq.zone) and bar_index - lq.sweptBar > zoneExpireBars
            lq.zoneExpired := true
            if deleteOnExpire
                box.delete(lq.zone)
                lq.zone := na
            else
                box.set_bgcolor(lq.zone, color.new(colSwept, 92))
                box.set_border_color(lq.zone, color.new(colSwept, 70))

        // Lookback window: drop levels older than N candles (with their drawings).
        if useZoneWindow and bar_index - lq.bar > zoneLookback
            if not na(lq.ln)
                line.delete(lq.ln)
            if not na(lq.lb)
                label.delete(lq.lb)
            if not na(lq.zone)
                box.delete(lq.zone)
            if not na(lq.zbox)
                box.delete(lq.zbox)
            array.remove(levels, i)

// ============================================================================
//  RENDER — extend active levels + apply age fade (cosmetic; last bar only).
//  The final chart state is identical to per-bar updates; signals untouched.
// ============================================================================
if barstate.islast
    for lq in levels
        if not lq.swept
            // extend to the live bar
            if extendLive and showLines
                if not na(lq.ln)
                    line.set_x2(lq.ln, bar_index)
                if not na(lq.zbox)
                    box.set_right(lq.zbox, bar_index)
            // age fade — equal levels stay highlighted (capped); repaint only on
            // a bucket change to avoid redundant object updates.
            if useFade
                int want = lq.isEqual ? math.min(fadeShade(bar_index - lq.bar), 25) : fadeShade(bar_index - lq.bar)
                if want != lq.shade
                    lq.shade := want
                    if not na(lq.ln)
                        line.set_color(lq.ln, color.new(lq.baseCol, want))
                    if not na(lq.zbox)
                        box.set_border_color(lq.zbox, color.new(lq.baseCol, math.min(want + 40, 90)))

// ============================================================================
//  BAR COLORING & PLOTSHAPES
// ============================================================================
anyBull  = sigBull or sigBullEq
anyBear  = sigBear or sigBearEq
barColor = colorBars and anyBull ? colBull : colorBars and anyBear ? colBear : na
barcolor(barColor)

// display.pane → shapes stay on the chart but their values leave the status
// line / data window (declutters the indicator's status-line readout).
plotshape(sigBull,       title = "SSL Sweep",         style = shape.triangleup,   location = location.belowbar, color = colBull,  size = size.tiny, display = display.pane)
plotshape(sigBear,       title = "BSL Sweep",         style = shape.triangledown, location = location.abovebar, color = colBear,  size = size.tiny, display = display.pane)
plotshape(sigBullEq,     title = "EQL Sweep",         style = shape.diamond,      location = location.belowbar, color = colEqual, size = size.tiny, display = display.pane)
plotshape(sigBearEq,     title = "EQH Sweep",         style = shape.diamond,      location = location.abovebar, color = colEqual, size = size.tiny, display = display.pane)
plotshape(sigStrongBull, title = "Strong Bull Sweep", style = shape.circle,       location = location.belowbar, color = colBull,  size = size.tiny, display = display.pane)
plotshape(sigStrongBear, title = "Strong Bear Sweep", style = shape.circle,       location = location.abovebar, color = colBear,  size = size.tiny, display = display.pane)

// ============================================================================
//  ALERTS  (titles & messages preserved verbatim)
// ============================================================================
alertcondition(sigStrongBull, "Strong Bullish Sweep",   "Strong bullish liquidity sweep — score above threshold.")
alertcondition(sigStrongBear, "Strong Bearish Sweep",   "Strong bearish liquidity sweep — score above threshold.")
alertcondition(sigBearEq,     "Equal High Sweep (EQH)", "Equal-high liquidity swept.")
alertcondition(sigBullEq,     "Equal Low Sweep (EQL)",  "Equal-low liquidity swept.")
alertcondition(sigBullCf,     "Confirmed Bullish Sweep","Bullish liquidity sweep confirmed by the next candle.")
alertcondition(sigBearCf,     "Confirmed Bearish Sweep","Bearish liquidity sweep confirmed by the next candle.")
alertcondition(sigBull,       "Bullish Liquidity Sweep (SSL)", "Bullish liquidity sweep — sell-side liquidity taken, closed back up.")
alertcondition(sigBear,       "Bearish Liquidity Sweep (BSL)", "Bearish liquidity sweep — buy-side liquidity taken, closed back down.")
alertcondition(anyBull or anyBear, "Any Liquidity Sweep", "A liquidity sweep occurred.")

// ============================================================================
//  DASHBOARD  (built once, on the last bar — slimmed to decision-grade rows)
// ============================================================================
var table dash = na
if showDash and barstate.islast
    int rows = 6
    if na(dash)
        dash := table.new(tablePos(), 2, rows, border_width = 1,
                     frame_color = color.new(color.gray, 50), frame_width = 1)
    else
        table.clear(dash, 0, 0, 1, rows - 1)

    color  biasCol = trendBull ? colLow : trendBear ? colHigh : color.gray
    string biasTxt = trendBull ? "Bullish" : trendBear ? "Bearish" : "Neutral"
    color  htfCol  = htfBull ? colLow : htfBear ? colHigh : color.gray
    string htfTxt  = htfBull ? "Bullish" : htfBear ? "Bearish" : "Neutral"
    color  dirCol  = lastSweepDir == "Bullish" ? colBull : lastSweepDir == "Bearish" ? colBear : color.gray
    string scTxt   = na(lastScore) ? "—" : str.tostring(math.round(lastScore)) + "/100"
    color  scCol   = na(lastScore) ? color.gray : lastScore >= strongScore ? colBull : lastScore >= 50 ? color.orange : color.gray

    table.cell(dash, 0, 0, "LIQUIDITY SWEEP", text_color = color.white, bgcolor = color.new(color.blue, 0), text_size = txtSize(), text_halign = text.align_left)
    table.cell(dash, 1, 0, "",                text_color = color.white, bgcolor = color.new(color.blue, 0), text_size = txtSize(), text_halign = text.align_right)
    dashRow(dash, 1, "Last Sweep",      lastSweepType, color.white)
    dashRow(dash, 2, "Sweep Direction", lastSweepDir,  dirCol)
    dashRow(dash, 3, "Strength Score",  scTxt,         scCol)
    dashRow(dash, 4, "Current Trend",   biasTxt,       biasCol)
    dashRow(dash, 5, "HTF Trend",       htfTxt,        htfCol)
````
