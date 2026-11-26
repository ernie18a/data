# Volatility Reactor [MontyCodex]

- url: https://www.tradingview.com/script/YrqIBNDg/
- type: indicator
- pine_id: PUB;2bedf1a4bcb44de0b34dcac6a13dc3ec
- version: 1.0

## Description

[b]Volatility Reactor [MontyCodexPro][/b]

Description

Volatility Reactor [MontyCodexPro] is a volatility-regime oscillator designed to answer a question that traditional volatility indicators often leave unresolved:
What stage of the volatility cycle is the market currently in?
Instead of displaying only ATR, Bollinger Band width, or a simple compression signal, Volatility Reactor combines several measurements into a structured volatility model.
The indicator separates two concepts that should not be confused:
Reactor Energy
Measures the intensity of the current volatility regime.
Directional Pressure
Measures whether price pressure is predominantly bullish, bearish, or balanced.
These two dimensions are then combined with a dedicated Volatility Cycle engine that classifies market conditions into:
COMPRESSION → CHARGING → IGNITION → EXPANSION → EXHAUSTION
The objective is not to generate automatic BUY or SELL signals.
The objective is to make changes in volatility easier to identify, interpret, and monitor.

⚡ REACTOR ENERGY
The main histogram represents Reactor Energy, normalized on a scale from approximately 0 to 100.
Its height answers:
How much volatility energy is currently present in the market?
Lower readings generally indicate contraction.
Higher readings indicate increasing or established volatility expansion.
Reactor Energy is built from several independent components:
- normalized ATR;
- Bollinger Band width;
- True Range expansion;
- relative volume;
- price efficiency.
These measurements are normalized against the recent market regime before being combined.
This means that the oscillator is not simply measuring whether ATR is high or low in absolute terms.
It attempts to determine whether current market activity is elevated or compressed relative to its own recent behavior.

🎨 DIRECTIONAL PRESSURE
The color of the histogram represents Directional Pressure.
This is calculated independently from Reactor Energy.
Directional Pressure evaluates information such as:
- candle body pressure;
- closing location within the candle;
- normalized momentum;
- directional price efficiency.
The result ranges approximately from:
-100 → bearish pressure
0 → balanced pressure
+100 → bullish pressure
By default:
Cyan / turquoise represents bullish pressure.
Blue represents balanced or weak directional pressure.
Purple represents bearish pressure.
This separation is important.
A market can have:
- high volatility with bullish pressure;
- high volatility with bearish pressure;
- high volatility without strong directional pressure;
- low volatility while directional pressure begins to develop.
Volatility and direction are therefore treated as two different variables.

🔄 VOLATILITY CYCLE
The lower ribbon represents the current Volatility Cycle.
Unlike the histogram, the ribbon does not measure magnitude.
It answers:
What phase of the volatility process is currently active?
The cycle contains five main states.

🟣 COMPRESSION
Compression represents a market where volatility has contracted.
The engine looks for conditions such as:
- reduced Reactor Energy;
- ATR below its recent regime;
- contracted Bollinger Band width;
- reduced range expansion.
Compression does not predict the direction of the next movement.
It simply identifies an environment where volatility has contracted.
Think of it as:
Energy is low and the market is compressed.

🔵 CHARGING
Charging appears when Energy begins to increase after a qualified compression.
The market has not yet reached a confirmed expansion regime, but volatility is starting to build.
It answers:
Is the market beginning to wake up after compression?
Charging should be interpreted as a transition phase rather than a directional signal.

🟠 IGNITION
Ignition represents the initial release of volatility after recent compression.
It occurs when Reactor Energy accelerates through the Ignition threshold while range or Bollinger expansion begins to appear.
In simple terms:
IGNITION = volatility release is starting.
Ignition is different from Expansion.
Ignition identifies the beginning of the release.
Expansion identifies a volatility regime that has already become more established.
Directional Pressure helps interpret the event:
IGNITION ↑
Volatility is being released with predominantly bullish pressure.
IGNITION ↓
Volatility is being released with predominantly bearish pressure.
A directional arrow does not represent a trade recommendation.
It describes the pressure accompanying the volatility release.

🔷 EXPANSION
Expansion represents an established high-energy volatility environment.
The engine considers factors including:
- elevated Reactor Energy;
- directional pressure;
- price efficiency;
- persistence of the expansion.
This state answers:
Has volatility moved beyond the initial release and developed into a sustained expansion?
Expansion can occur with either bullish or bearish directional pressure.
Again:
Expansion is a market condition, not an entry signal.

⚪ EXHAUSTION
Exhaustion appears when a previously elevated Energy regime begins to lose strength.
The engine evaluates the decline of Reactor Energy after a recent expansion.
It answers:
Is the current volatility expansion beginning to lose energy?
Exhaustion does not automatically mean that price will reverse.
A market can lose volatility while continuing in the same direction.
The state should therefore be interpreted as:
The expansion is losing energy.
Not:
The market must reverse.

📊 HOW TO READ THE INDICATOR
Volatility Reactor is designed around three visual layers.
Histogram height
Represents:
REACTOR ENERGY
Higher histogram = stronger volatility regime.
Lower histogram = contracted volatility regime.
Histogram color
Represents:
DIRECTIONAL PRESSURE
Cyan = bullish pressure.
Purple = bearish pressure.
Blue = balanced or weak directional pressure.
Lower ribbon
Represents:
VOLATILITY CYCLE
The ribbon identifies whether the market is currently in:
- Compression;
- Charging;
- Ignition;
- Expansion;
- Exhaustion;
- or Neutral conditions.
The compact labels below the ribbon highlight important changes in the cycle while keeping the oscillator visually clean.

📡 REACTOR RADAR
Volatility Reactor includes a compact information panel for users who want an immediate interpretation of the current environment.
The Radar displays:
CYCLE
The current volatility-cycle phase and how many bars the market has remained in that state.
ENERGY
The current Reactor Energy reading and whether Energy is increasing, decreasing, or remaining relatively stable.
PRESSURE
The current directional pressure and its strength.
READ
A simplified interpretation of the current environment.
Examples may include:
Energy contracted · waiting for release
Energy rising after compression
Volatility release starting · bullish
Volatility expanding · bearish
Expansion losing energy
These messages are descriptive interpretations of the indicator's internal measurements.
They are not predictions or trading instructions.

🖱️ INTERACTIVE INFORMATION
Several fields inside the Reactor Radar include TradingView tooltips.
Move the mouse cursor over the corresponding information to access additional explanations about:
- the Volatility Cycle;
- Reactor Energy;
- Directional Pressure;
- the current interpretation.
No click is required.
TradingView automatically displays the additional information when the cursor remains over the corresponding field.

🎛️ REACTOR PROFILES
Volatility Reactor includes four operating profiles.
Responsive
Uses shorter calculation periods and reduced smoothing.
Designed for traders who want the Reactor to respond more quickly to changes in market conditions.
It may also generate more state transitions.
Balanced
The default profile.
Designed to provide a compromise between responsiveness and stability.
This is the recommended starting point for most users.
Smooth
Uses longer calculation periods and additional smoothing.
Designed for users who prefer a more structural view of volatility with fewer short-term changes.
Custom
Allows experienced users to configure the Reactor engine manually.
Advanced parameters include:
- regime length;
- Energy smoothing;
- ATR period;
- Bollinger period;
- range baseline;
- volume baseline;
- price efficiency;
- momentum;
- directional pressure smoothing.

⚙️ ADVANCED STATE MODEL
The Custom configuration also provides access to the internal volatility-cycle thresholds.
Users can adjust:
- Compression threshold;
- Ignition threshold;
- Expansion threshold;
- minimum directional pressure;
- compression memory;
- minimum compression duration;
- Exhaustion sensitivity;
- minimum price efficiency.
These controls make it possible to adapt the Reactor to different markets, timeframes, and trading styles.

🚨 ALERTS
Volatility Reactor includes configurable TradingView alerts for:
- Compression;
- Charging;
- Ignition;
- Expansion;
- Exhaustion;
- Directional Pressure Flip;
- Any Reactor Event.
Important events such as Ignition, Expansion, and Exhaustion are enabled by default in the alert configuration.
Users can also require alerts to be confirmed at candle close.

✅ CLOSE CONFIRMATION
When Close confirm is enabled, alert events are only exposed after the current candle has been confirmed.
This can help reduce intrabar state changes when monitoring the indicator with TradingView alerts.

🎨 CUSTOMIZATION
The visual appearance can be customized extensively.
Users can modify:
- bullish pressure color;
- bearish pressure color;
- balanced pressure color;
- Compression color;
- Charging color;
- Ignition color;
- Expansion color;
- Exhaustion color;
- histogram transparency;
- glow intensity;
- Volatility Cycle visibility;
- cycle labels;
- background highlighting;
- Reactor Radar;
- optional candle coloring.
The default visual design follows the MontyCodexPro color system.

🚀 WHAT MAKES VOLATILITY REACTOR DIFFERENT?
Traditional volatility indicators often answer only one question:
Is volatility high or low?
Volatility Reactor attempts to answer several related questions:
Is volatility compressed?
Is Energy beginning to build?
Has the market started releasing volatility?
Has that release developed into sustained Expansion?
Is the Expansion beginning to lose Energy?
Is the pressure behind the movement bullish or bearish?
The main idea is therefore not to add another volatility measurement.
It is to organize multiple volatility measurements into a readable market process.
Instead of viewing volatility as a single value, Volatility Reactor represents it as a cycle.

💡 PRACTICAL USE
Volatility Reactor can be used to complement:
- market structure analysis;
- breakout analysis;
- trend-following systems;
- momentum indicators;
- support and resistance;
- discretionary price-action analysis.
For example, a trader may use the Reactor to distinguish between:
a breakout occurring during low Energy
and
a breakout accompanied by Ignition and increasing directional pressure.
Similarly, the Exhaustion state can help identify when an existing high-volatility environment is beginning to lose intensity.
The Reactor provides context.
The trading decision remains with the user.
🎯 WHO IS IT DESIGNED FOR?
Volatility Reactor can be applied to different markets and timeframes, including:
- cryptocurrencies;
- Forex;
- indices;
- stocks;
- commodities;
- gold.
Its normalized design allows the engine to adapt its measurements to the recent behavior of the selected market rather than relying only on absolute volatility values.

⚠️ CORRECT USE OF THE INDICATOR
Volatility Reactor is not an automatic trading system.
Compression does not guarantee a breakout.
Ignition does not guarantee continuation.
Expansion does not guarantee that a trend will continue.
Exhaustion does not guarantee a reversal.
Directional Pressure does not represent future price probability.
The indicator should be used as a contextual volatility tool together with appropriate market analysis and risk management.

⚠️ DISCLAIMER
Volatility Reactor [MontyCodexPro] is a technical analysis tool intended exclusively for educational and informational purposes.
It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.
The indicator does not predict future market movements and does not guarantee results.
Financial markets involve risk. Every user is responsible for their own trading decisions, testing methodology, and risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//
// Copyright (c) 2026 MontyCodexPro
//
// VOLATILITY REACTOR [MONTYCODEXPRO]
// Open Source Community Edition
//
// V1.5 - Aligned Labels
// - Keeps the distinct lower Volatility Cycle ribbon
// - Transition labels remain below the ribbon
// - All transition labels now share one aligned baseline
// - Label size is increased for easier reading
// - Minimum spacing between labels is increased to reduce crowding
// - Current cycle remains identified at the right edge
// - Reactor calculations and state logic are unchanged from V1.4
//
// CORE IDEA
// Energy and direction are intentionally separated.
//
// REACTOR ENERGY:        0 to 100
// DIRECTIONAL PRESSURE: -100 to +100
//
// VOLATILITY CYCLE
// COMPRESSION -> CHARGING -> IGNITION -> EXPANSION -> EXHAUSTION
//
// IMPORTANT
// - This is an analytical volatility-regime tool, not a BUY/SELL system.
// - Energy does not imply direction.
// - Directional pressure does not imply volatility.
// - No future data or lookahead is used.

//@version=6
indicator(
     "Volatility Reactor [MontyCodex]",
     shorttitle          = "Volatility Reactor [MontyCodex]",
     overlay             = false,
     max_labels_count    = 200
 )


// ============================================================================
// PROFILE CONSTANTS
// ============================================================================

string PROFILE_RESPONSIVE = "Responsive"
string PROFILE_BALANCED   = "Balanced"
string PROFILE_SMOOTH     = "Smooth"
string PROFILE_CUSTOM     = "Custom"


// ============================================================================
// STATE CONSTANTS
// ============================================================================

int STATE_NEUTRAL        = 0
int STATE_COMPRESSION    = 1
int STATE_CHARGING       = 2
int STATE_IGNITION       = 3
int STATE_EXPANSION      = 4
int STATE_EXHAUSTION     = 5


// ============================================================================
// MONTYCODEXPRO COLORS
// ============================================================================

color MCP_BLACK          = #050816
color MCP_PANEL          = #0B1020

color MCP_CYAN           = #22D3EE
color MCP_BLUE           = #2563EB
color MCP_VIOLET         = #7C3AED
color MCP_PURPLE         = #A855F7

color MCP_TEXT           = #EAF0FF
color MCP_MUTED          = #94A3B8
color MCP_AMBER          = #F59E0B


// ============================================================================
// GROUPS
// ============================================================================

string GRP_MAIN          = "REACTOR"
string GRP_CUSTOM        = "ADVANCED ENGINE"
string GRP_STATES        = "ADVANCED STATE MODEL"
string GRP_VISUAL        = "APPEARANCE"
string GRP_ALERTS        = "ALERTS"


// ============================================================================
// TOOLTIPS
// ============================================================================

string tipProfile        = "Responsive reacts faster, Balanced is the recommended default, Smooth filters more noise, and Custom uses the advanced parameters below."

string tipRegime         = "Baseline window used to normalize volatility components against the recent market regime."
string tipSmooth         = "Smoothing applied to Reactor Energy."
string tipAtr            = "ATR period used by the volatility engine."
string tipBb             = "Bollinger Band period used to measure volatility contraction and expansion."
string tipRange          = "Baseline period for True Range expansion."
string tipVolume         = "Baseline period for relative volume. If volume is unavailable, this component becomes neutral."
string tipEfficiency     = "Measures how efficiently price travels compared with the total path covered."
string tipMomentum       = "Lookback used by directional pressure."
string tipPressure       = "Smoothing applied to directional pressure."

string tipCompression    = "Maximum Energy normally associated with a compressed volatility regime."
string tipIgnition       = "Energy threshold crossed after recent compression to detect a release attempt."
string tipExpansion      = "Energy level required for sustained Expansion."
string tipMinPressure    = "Minimum absolute directional pressure required for sustained Expansion."
string tipMemory         = "Number of bars during which a qualified compression remains relevant."
string tipCompBars       = "Minimum consecutive compression bars required to qualify the contraction."
string tipExhaust        = "Minimum negative Energy slope used to detect loss of expansion energy."
string tipMinEff         = "Minimum price-efficiency reading required for sustained Expansion."

string tipCycle          = "Volatility Cycle shows the market phase below the oscillator: Compression, Charging, Ignition, Expansion, Exhaustion or Neutral. It classifies the phase; it does not measure Energy magnitude."
string tipCycleLabels    = "Writes the phase name inside the Volatility Cycle whenever the state changes, making the ribbon self-explanatory."
string tipBackground     = "Adds a subtle tint for the current volatility-cycle state."
string tipRadar          = "Compact readout with Cycle, Energy, Pressure and a plain-language interpretation."
string tipCandles        = "Optionally colors chart candles using directional pressure only. This is not a trading signal."
string tipConfirm        = "When enabled, alert events are exposed only after the current candle closes."


// ============================================================================
// INPUTS - REACTOR
// ============================================================================

reactorProfile           = input.string(PROFILE_BALANCED, "Profile", options = [PROFILE_RESPONSIVE, PROFILE_BALANCED, PROFILE_SMOOTH, PROFILE_CUSTOM], group = GRP_MAIN, tooltip = tipProfile)


// ============================================================================
// INPUTS - ADVANCED ENGINE
// ============================================================================

customRegime             = input.int(120, "Regime  ", minval = 40, maxval = 500, group = GRP_CUSTOM, inline = "eng_1", tooltip = tipRegime)
customEnergySmooth       = input.int(3, "Smooth     ", minval = 1, maxval = 20, group = GRP_CUSTOM, inline = "eng_1", tooltip = tipSmooth)

customAtr                = input.int(14, "ATR       ", minval = 2, maxval = 100, group = GRP_CUSTOM, inline = "eng_2", tooltip = tipAtr)
customBb                 = input.int(20, "BB            ", minval = 5, maxval = 100, group = GRP_CUSTOM, inline = "eng_2", tooltip = tipBb)

customRange              = input.int(20, "Range     ", minval = 5, maxval = 100, group = GRP_CUSTOM, inline = "eng_3", tooltip = tipRange)
customVolume             = input.int(20, "Volume     ", minval = 5, maxval = 100, group = GRP_CUSTOM, inline = "eng_3", tooltip = tipVolume)

customEfficiency         = input.int(10, "Efficiency", minval = 2, maxval = 100, group = GRP_CUSTOM, inline = "eng_4", tooltip = tipEfficiency)
customMomentum           = input.int(8, "Momentum", minval = 2, maxval = 100, group = GRP_CUSTOM, inline = "eng_4", tooltip = tipMomentum)

customPressureSmooth     = input.int(3, "Pressure", minval = 1, maxval = 20, group = GRP_CUSTOM, tooltip = tipPressure)


// ============================================================================
// INPUTS - ADVANCED STATE MODEL
// ============================================================================

compressionThreshold     = input.float(28.0, "Compress", minval = 5.0, maxval = 50.0, step = 1.0, group = GRP_STATES, inline = "state_1", tooltip = tipCompression)
ignitionThreshold        = input.float(48.0, "Ignition", minval = 20.0, maxval = 80.0, step = 1.0, group = GRP_STATES, inline = "state_1", tooltip = tipIgnition)

expansionThreshold       = input.float(62.0, "Expand", minval = 30.0, maxval = 95.0, step = 1.0, group = GRP_STATES, inline = "state_2", tooltip = tipExpansion)
minPressure              = input.float(18.0, "Min press.", minval = 0.0, maxval = 80.0, step = 1.0, group = GRP_STATES, inline = "state_2", tooltip = tipMinPressure)

compressionMemory        = input.int(8, "Memory", minval = 1, maxval = 30, group = GRP_STATES, inline = "state_3", tooltip = tipMemory)
minCompressionBars       = input.int(3, "Comp bars", minval = 1, maxval = 20, group = GRP_STATES, inline = "state_3", tooltip = tipCompBars)

exhaustionSlope          = input.float(2.0, "Exhaust", minval = 0.1, maxval = 15.0, step = 0.1, group = GRP_STATES, inline = "state_4", tooltip = tipExhaust)
minEfficiency            = input.float(0.28, "Efficiency", minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_STATES, inline = "state_4", tooltip = tipMinEff)


// ============================================================================
// INPUTS - APPEARANCE
// ============================================================================

bullColor                = input.color(MCP_CYAN, "Bull       ", group = GRP_VISUAL, inline = "vis_1")
bearColor                = input.color(MCP_PURPLE, "Bear       ", group = GRP_VISUAL, inline = "vis_1")

neutralColor             = input.color(MCP_BLUE, "Balanced ", group = GRP_VISUAL, inline = "vis_2")
compressionColor         = input.color(MCP_VIOLET, "Compress", group = GRP_VISUAL, inline = "vis_2")

chargingColor            = input.color(MCP_BLUE, "Charging ", group = GRP_VISUAL, inline = "vis_3")
ignitionColor            = input.color(MCP_AMBER, "Ignition   ", group = GRP_VISUAL, inline = "vis_3")

expansionColor           = input.color(MCP_CYAN, "Expansion", group = GRP_VISUAL, inline = "vis_4")
exhaustionColor          = input.color(MCP_MUTED, "Exhaust  ", group = GRP_VISUAL, inline = "vis_4")

columnTransparency       = input.int(10, "Columns", minval = 0, maxval = 100, group = GRP_VISUAL, inline = "vis_5")
glowTransparency         = input.int(72, "Glow", minval = 0, maxval = 100, group = GRP_VISUAL, inline = "vis_5")

showVolatilityCycle      = input.bool(true, "Volatility cycle", group = GRP_VISUAL, inline = "vis_6", tooltip = tipCycle)
showCycleLabels          = input.bool(true, "Cycle labels", group = GRP_VISUAL, inline = "vis_6", tooltip = tipCycleLabels)

showBackground           = input.bool(true, "Background", group = GRP_VISUAL, inline = "vis_7", tooltip = tipBackground)
showRadar                = input.bool(true, "Radar", group = GRP_VISUAL, inline = "vis_7", tooltip = tipRadar)

paintCandles             = input.bool(false, "Paint candles", group = GRP_VISUAL, tooltip = tipCandles)


// ============================================================================
// INPUTS - ALERTS
// ============================================================================

confirmAlertsOnClose     = input.bool(true, "Close confirm", group = GRP_ALERTS, tooltip = tipConfirm)

alertCompression         = input.bool(false, "Compression", group = GRP_ALERTS, inline = "alt_1")
alertCharging            = input.bool(false, "Charging", group = GRP_ALERTS, inline = "alt_1")

alertIgnition            = input.bool(true, "Ignition", group = GRP_ALERTS, inline = "alt_2")
alertExpansion           = input.bool(true, "Expansion", group = GRP_ALERTS, inline = "alt_2")

alertExhaustion          = input.bool(true, "Exhaustion", group = GRP_ALERTS, inline = "alt_3")
alertPressureFlip        = input.bool(false, "Pressure flip", group = GRP_ALERTS, inline = "alt_3")


// ============================================================================
// PROFILE ENGINE
// ============================================================================

int regimeLength =
     reactorProfile == PROFILE_RESPONSIVE ? 80 :
     reactorProfile == PROFILE_SMOOTH ? 180 :
     reactorProfile == PROFILE_CUSTOM ? customRegime :
     120

int energySmooth =
     reactorProfile == PROFILE_RESPONSIVE ? 2 :
     reactorProfile == PROFILE_SMOOTH ? 5 :
     reactorProfile == PROFILE_CUSTOM ? customEnergySmooth :
     3

int atrLength =
     reactorProfile == PROFILE_RESPONSIVE ? 10 :
     reactorProfile == PROFILE_SMOOTH ? 20 :
     reactorProfile == PROFILE_CUSTOM ? customAtr :
     14

int bbLength =
     reactorProfile == PROFILE_RESPONSIVE ? 14 :
     reactorProfile == PROFILE_SMOOTH ? 30 :
     reactorProfile == PROFILE_CUSTOM ? customBb :
     20

int rangeLength =
     reactorProfile == PROFILE_RESPONSIVE ? 14 :
     reactorProfile == PROFILE_SMOOTH ? 30 :
     reactorProfile == PROFILE_CUSTOM ? customRange :
     20

int volumeLength =
     reactorProfile == PROFILE_RESPONSIVE ? 14 :
     reactorProfile == PROFILE_SMOOTH ? 30 :
     reactorProfile == PROFILE_CUSTOM ? customVolume :
     20

int efficiencyLength =
     reactorProfile == PROFILE_RESPONSIVE ? 7 :
     reactorProfile == PROFILE_SMOOTH ? 14 :
     reactorProfile == PROFILE_CUSTOM ? customEfficiency :
     10

int momentumLength =
     reactorProfile == PROFILE_RESPONSIVE ? 5 :
     reactorProfile == PROFILE_SMOOTH ? 12 :
     reactorProfile == PROFILE_CUSTOM ? customMomentum :
     8

int pressureSmooth =
     reactorProfile == PROFILE_RESPONSIVE ? 2 :
     reactorProfile == PROFILE_SMOOTH ? 4 :
     reactorProfile == PROFILE_CUSTOM ? customPressureSmooth :
     3


// ============================================================================
// HELPERS
// ============================================================================

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))


f_safeRatio(float value, float baseline, float fallback) =>
    na(value) or na(baseline) or baseline == 0.0 ? fallback : value / baseline


f_component(float ratio, float lowAnchor, float highAnchor) =>
    float width = math.max(highAnchor - lowAnchor, 0.000001)
    f_clamp((ratio - lowAnchor) / width, 0.0, 1.0)


f_stateText(int state) =>
    switch state
        STATE_COMPRESSION => "COMPRESSION"
        STATE_CHARGING    => "CHARGING"
        STATE_IGNITION    => "IGNITION"
        STATE_EXPANSION   => "EXPANSION"
        STATE_EXHAUSTION  => "EXHAUSTION"
        => "NEUTRAL"


f_stateColor(int state) =>
    switch state
        STATE_COMPRESSION => compressionColor
        STATE_CHARGING    => chargingColor
        STATE_IGNITION    => ignitionColor
        STATE_EXPANSION   => expansionColor
        STATE_EXHAUSTION  => exhaustionColor
        => MCP_MUTED


f_energyArrow(float slope) =>
    slope > 1.0 ? "↑" :
     slope < -1.0 ? "↓" :
     "→"


f_pressureArrow(float pressure) =>
     pressure > minPressure ? "↑" :
     pressure < -minPressure ? "↓" :
     "·"


f_pressureText(float pressure) =>
    string direction =
         pressure > minPressure ? "BULL" :
         pressure < -minPressure ? "BEAR" :
         "BALANCED"

    direction + "  " + str.tostring(math.abs(pressure), "#.0")


f_cycleText(int state, float pressure) =>
    string direction = f_pressureArrow(pressure)

    switch state
        STATE_COMPRESSION => "COMPRESSION"
        STATE_CHARGING    => "CHARGING"
        STATE_IGNITION    => "IGNITION " + direction
        STATE_EXPANSION   => "EXPANSION " + direction
        STATE_EXHAUSTION  => "EXHAUSTION"
        => "NEUTRAL"


f_cycleShortText(int state, float pressure) =>
    string direction = f_pressureArrow(pressure)

    switch state
        STATE_COMPRESSION => "COMP"
        STATE_CHARGING    => "CHG"
        STATE_IGNITION    => "IGN " + direction
        STATE_EXPANSION   => "EXP " + direction
        STATE_EXHAUSTION  => "EXH"
        => "NEU"


f_readText(int state, float pressure, float slope) =>
    string direction =
         pressure > minPressure ? "bullish" :
         pressure < -minPressure ? "bearish" :
         "unclear"

    switch state
        STATE_COMPRESSION => "Energy contracted · waiting for release"
        STATE_CHARGING    => "Energy rising after compression"
        STATE_IGNITION    => direction == "unclear" ? "Volatility release starting · direction unclear" : "Volatility release starting · " + direction
        STATE_EXPANSION   => direction == "unclear" ? "Volatility expanding · mixed pressure" : "Volatility expanding · " + direction
        STATE_EXHAUSTION  => slope < 0.0 ? "Expansion losing energy" : "Expansion losing definition"
        => "No clear volatility cycle"


// ============================================================================
// BASE SERIES
// ============================================================================

float prevClose          = nz(close[1], close)

float trueRange =
     math.max(
         high - low,
         math.max(
             math.abs(high - prevClose),
             math.abs(low - prevClose)
         )
     )

float atrValue           = ta.atr(atrLength)
float atrBaseline        = ta.sma(atrValue, regimeLength)
float atrRatio           = f_safeRatio(atrValue, atrBaseline, 1.0)

float bbBasis            = ta.sma(close, bbLength)
float bbDeviation        = ta.stdev(close, bbLength) * 2.0

float bbWidth =
     not na(bbBasis) and bbBasis != 0.0 ?
     (bbDeviation * 2.0) / math.abs(bbBasis) :
     na

float bbBaseline         = ta.sma(bbWidth, regimeLength)
float bbRatio            = f_safeRatio(bbWidth, bbBaseline, 1.0)

float rangeBaseline      = ta.sma(trueRange, rangeLength)
float rangeRatio         = f_safeRatio(trueRange, rangeBaseline, 1.0)

float volumeBaseline     = ta.sma(volume, volumeLength)

bool hasVolume =
     not na(volume) and
     not na(volumeBaseline) and
     volumeBaseline > 0.0

float volumeRatio =
     hasVolume ?
     volume / volumeBaseline :
     1.0

float pathMove           = math.sum(math.abs(close - close[1]), efficiencyLength)
float netMove            = math.abs(close - close[efficiencyLength])

float efficiency =
     not na(pathMove) and pathMove > 0.0 ?
     f_clamp(netMove / pathMove, 0.0, 1.0) :
     0.0


// ============================================================================
// REACTOR ENERGY
// ============================================================================

float atrScore           = f_component(atrRatio, 0.65, 1.55)
float bbScore            = f_component(bbRatio, 0.60, 1.60)
float rangeScore         = f_component(rangeRatio, 0.65, 1.75)

float volumeScore =
     hasVolume ?
     f_component(volumeRatio, 0.70, 1.80) :
     0.50

float efficiencyScore    = efficiency

float energyRaw =
     100.0 * (
         atrScore        * 0.26 +
         bbScore         * 0.24 +
         rangeScore      * 0.22 +
         volumeScore     * 0.14 +
         efficiencyScore * 0.14
     )

float reactorEnergy      = ta.ema(energyRaw, energySmooth)
float reactorSlope       = reactorEnergy - reactorEnergy[1]


// ============================================================================
// DIRECTIONAL PRESSURE
// ============================================================================

float candleRange        = high - low

float bodyPressure =
     candleRange > 0.0 ?
     (close - open) / candleRange :
     0.0

float closeLocation =
     candleRange > 0.0 ?
     ((close - low) / candleRange) * 2.0 - 1.0 :
     0.0

float momentumValue      = close - close[momentumLength]

float momentumPressure =
     not na(atrValue) and atrValue > 0.0 ?
     f_clamp(momentumValue / (atrValue * 2.5), -1.0, 1.0) :
     0.0

float efficiencySign =
     momentumValue > 0.0 ? 1.0 :
     momentumValue < 0.0 ? -1.0 :
     0.0

float signedEfficiency   = efficiency * efficiencySign

float pressureRaw =
     (
         bodyPressure     * 0.35 +
         closeLocation    * 0.25 +
         momentumPressure * 0.30 +
         signedEfficiency * 0.10
     ) * 100.0

float directionalPressure = ta.ema(pressureRaw, pressureSmooth)


// ============================================================================
// VOLATILITY CYCLE STATE MODEL
// ============================================================================

bool compressionRaw =
     reactorEnergy <= compressionThreshold and
     atrRatio < 0.95 and
     bbRatio < 0.92 and
     rangeRatio < 1.00

var int compressionStreak = 0

compressionStreak :=
     compressionRaw ?
     nz(compressionStreak[1]) + 1 :
     0

int barsSinceCompression = ta.barssince(compressionRaw)

bool recentCompression =
     not na(barsSinceCompression) and
     barsSinceCompression <= compressionMemory

bool qualifiedCompression =
     compressionStreak >= minCompressionBars

bool recentQualifiedCompression =
     recentCompression and
     ta.highest(compressionStreak, compressionMemory + 1) >= minCompressionBars

bool ignitionRaw =
     recentQualifiedCompression and
     ta.crossover(reactorEnergy, ignitionThreshold) and
     (
         rangeRatio > 1.10 or
         bbRatio > 1.02
     )

float recentEnergyPeak   = ta.highest(reactorEnergy, 8)

bool expansionRaw =
     reactorEnergy >= expansionThreshold and
     efficiency >= minEfficiency and
     math.abs(directionalPressure) >= minPressure and
     reactorSlope > -1.0

bool exhaustionRaw =
     recentEnergyPeak >= expansionThreshold and
     reactorEnergy > ignitionThreshold and
     reactorSlope <= -exhaustionSlope

bool chargingRaw =
     not compressionRaw and
     not ignitionRaw and
     not expansionRaw and
     recentQualifiedCompression and
     reactorEnergy < expansionThreshold and
     reactorSlope > 0.0

int reactorState =
     ignitionRaw ?
     STATE_IGNITION :
     exhaustionRaw ?
     STATE_EXHAUSTION :
     expansionRaw ?
     STATE_EXPANSION :
     qualifiedCompression ?
     STATE_COMPRESSION :
     chargingRaw ?
     STATE_CHARGING :
     STATE_NEUTRAL


// ============================================================================
// STATE DURATION + EVENTS
// ============================================================================

var int stateBars = 1

stateBars :=
     reactorState == reactorState[1] ?
     nz(stateBars[1], 0) + 1 :
     1

bool stateChanged        = reactorState != reactorState[1]

bool compressionEvent    = stateChanged and reactorState == STATE_COMPRESSION
bool chargingEvent       = stateChanged and reactorState == STATE_CHARGING
bool ignitionEvent       = reactorState == STATE_IGNITION
bool expansionEvent      = stateChanged and reactorState == STATE_EXPANSION
bool exhaustionEvent     = stateChanged and reactorState == STATE_EXHAUSTION

bool bullishPressureFlip = ta.crossover(directionalPressure, minPressure)
bool bearishPressureFlip = ta.crossunder(directionalPressure, -minPressure)

bool pressureFlipEvent =
     bullishPressureFlip or
     bearishPressureFlip


// ============================================================================
// DYNAMIC COLORS
// ============================================================================

color pressureGradient =
     color.from_gradient(
         directionalPressure,
         -100.0,
         100.0,
         bearColor,
         bullColor
     )

color pressureColor =
     math.abs(directionalPressure) < minPressure ?
     neutralColor :
     pressureGradient

color currentStateColor  = f_stateColor(reactorState)

int stateBackgroundTransparency =
     reactorState == STATE_IGNITION ? 89 :
     reactorState == STATE_COMPRESSION ? 93 :
     reactorState == STATE_EXPANSION ? 94 :
     reactorState == STATE_EXHAUSTION ? 94 :
     97


// ============================================================================
// VISUAL GUIDE ZONES
// ============================================================================

hZero = hline(
     0.0,
     "Zero",
     color = color.new(MCP_MUTED, 88)
 )

hCompression = hline(
     compressionThreshold,
     "Compression",
     color     = color.new(compressionColor, 60),
     linestyle = hline.style_dotted
 )

hIgnition = hline(
     ignitionThreshold,
     "Ignition",
     color     = color.new(ignitionColor, 70),
     linestyle = hline.style_dotted
 )

hExpansion = hline(
     expansionThreshold,
     "Expansion",
     color     = color.new(expansionColor, 75),
     linestyle = hline.style_dotted
 )

hMax = hline(
     100.0,
     "Maximum",
     color = color.new(MCP_MUTED, 96)
 )

fill(
     hZero,
     hCompression,
     color = color.new(compressionColor, 94),
     title = "Compression Zone"
 )

fill(
     hIgnition,
     hExpansion,
     color = color.new(ignitionColor, 96),
     title = "Ignition Zone"
 )

fill(
     hExpansion,
     hMax,
     color = color.new(expansionColor, 97),
     title = "Expansion Zone"
 )


// ============================================================================
// MAIN REACTOR VISUAL
// ============================================================================

plot(
     reactorEnergy,
     "Reactor Energy",
     style     = plot.style_columns,
     histbase  = 0.0,
     color     = color.new(pressureColor, columnTransparency)
 )

plot(
     reactorEnergy,
     "Energy Glow",
     color     = color.new(pressureColor, glowTransparency),
     linewidth = 7
 )

plot(
     reactorEnergy,
     "Energy Core",
     color     = color.new(pressureColor, 0),
     linewidth = 2
 )


// ============================================================================
// VOLATILITY CYCLE
// ============================================================================

plot(
     showVolatilityCycle ? -6.0 : na,
     "Volatility Cycle",
     style    = plot.style_columns,
     histbase = -14.0,
     color    = color.new(currentStateColor, reactorState == STATE_NEUTRAL ? 72 : 8)
 )


// ============================================================================
// CYCLE TRANSITION LABELS
// ============================================================================
//
// Labels are intentionally placed BELOW the ribbon, not inside it.
// This keeps the ribbon visually distinct from the histogram and avoids
// text stacking on top of itself.

var array<label> cycleLabels = array.new<label>()
var int          lastCycleLabelBar = na
var label        currentCycleTag = na

bool cycleTransitionEvent =
     stateChanged and
     reactorState != STATE_NEUTRAL

bool keyCycleState =
     reactorState == STATE_IGNITION or
     reactorState == STATE_EXHAUSTION

bool allowCycleLabel =
     na(lastCycleLabelBar) or
     bar_index - lastCycleLabelBar >= 10 or
     keyCycleState

if showVolatilityCycle and showCycleLabels and cycleTransitionEvent and allowCycleLabel and barstate.isconfirmed

    float cycleLabelY = -17.0

    string cycleLabelText =
         f_cycleShortText(
             reactorState,
             directionalPressure
         )

    label cycleLabel =
         label.new(
             bar_index,
             cycleLabelY,
             cycleLabelText,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = label.style_none,
             color     = color.new(currentStateColor, 100),
             textcolor = MCP_TEXT,
             size      = size.small
         )

    array.push(
         cycleLabels,
         cycleLabel
     )

    lastCycleLabelBar := bar_index

    if array.size(cycleLabels) > 50

        label oldCycleLabel =
             array.shift(cycleLabels)

        label.delete(
             oldCycleLabel
         )


// ============================================================================
// CURRENT CYCLE TAG
// ============================================================================

if barstate.islast

    if showVolatilityCycle

        string currentCycleText =
             "CYCLE · " +
             f_cycleText(
                 reactorState,
                 directionalPressure
             )

        if na(currentCycleTag)

            currentCycleTag := label.new(
                 bar_index + 1,
                 -10.0,
                 currentCycleText,
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 style     = label.style_label_left,
                 color     = color.new(currentStateColor, 8),
                 textcolor = MCP_TEXT,
                 size      = size.small
             )

        else

            label.set_x(currentCycleTag, bar_index + 1)
            label.set_y(currentCycleTag, -10.0)
            label.set_text(currentCycleTag, currentCycleText)
            label.set_color(currentCycleTag, color.new(currentStateColor, 8))
            label.set_textcolor(currentCycleTag, MCP_TEXT)

    else

        if not na(currentCycleTag)
            label.delete(currentCycleTag)
            currentCycleTag := na


// ============================================================================
// BACKGROUND
// ============================================================================

bgcolor(
     showBackground ?
     color.new(currentStateColor, stateBackgroundTransparency) :
     na
 )


// ============================================================================
// OPTIONAL CANDLE COLORING
// ============================================================================

barcolor(
     paintCandles ?
     color.new(pressureColor, 15) :
     na
 )


// ============================================================================
// COMPACT REACTOR RADAR
// ============================================================================

var table radar = table.new(
     position.top_right,
     2,
     5,
     bgcolor      = color.new(MCP_BLACK, 8),
     frame_color  = color.new(MCP_VIOLET, 45),
     frame_width  = 1,
     border_width = 0
 )

if barstate.islast

    if showRadar

        string energyText =
             str.tostring(reactorEnergy, "#.0") + "  " + f_energyArrow(reactorSlope)

        string cycleText =
             f_cycleText(reactorState, directionalPressure) + "  ·  " + str.tostring(stateBars) + "b"

        string pressureText =
             f_pressureText(directionalPressure)

        string readText =
             f_readText(
                 reactorState,
                 directionalPressure,
                 reactorSlope
             )

        table.cell(
             radar,
             0,
             0,
             "VOLATILITY",
             text_color = MCP_CYAN,
             bgcolor    = color.new(MCP_PANEL, 0),
             text_size  = size.tiny
         )

        table.cell(
             radar,
             1,
             0,
             "REACTOR",
             text_color = MCP_CYAN,
             bgcolor    = color.new(MCP_PANEL, 0),
             text_size  = size.tiny
         )

        table.cell(
             radar,
             0,
             1,
             "CYCLE",
             text_color = MCP_MUTED,
             bgcolor    = color.new(MCP_BLACK, 5),
             text_size  = size.tiny
         )

        table.cell(
             radar,
             1,
             1,
             cycleText,
             text_color = currentStateColor,
             bgcolor    = color.new(MCP_BLACK, 5),
             text_size  = size.tiny
         )

        table.cell_set_tooltip(
             radar,
             1,
             1,
             "Volatility Cycle classifies the current phase:\n\nCOMPRESSION = volatility contracted.\nCHARGING = Energy rising after compression.\nIGNITION = volatility release is starting.\nEXPANSION = release is established.\nEXHAUSTION = expansion is losing Energy.\nNEUTRAL = no clear phase.\n\n↑ / ↓ shows directional pressure.\nThe number followed by 'b' is the number of bars spent in the current phase."
         )

        table.cell(
             radar,
             0,
             2,
             "ENERGY",
             text_color = MCP_MUTED,
             bgcolor    = color.new(MCP_BLACK, 5),
             text_size  = size.tiny
         )

        table.cell(
             radar,
             1,
             2,
             energyText,
             text_color = pressureColor,
             bgcolor    = color.new(MCP_BLACK, 5),
             text_size  = size.tiny
         )

        table.cell_set_tooltip(
             radar,
             1,
             2,
             "Reactor Energy is normalized from 0 to 100.\n\nLow values indicate contraction.\nRising values indicate increasing volatility energy.\nHigh values indicate expansion.\n\nThe arrow shows the current Energy slope."
         )

        table.cell(
             radar,
             0,
             3,
             "PRESSURE",
             text_color = MCP_MUTED,
             bgcolor    = color.new(MCP_BLACK, 5),
             text_size  = size.tiny
         )

        table.cell(
             radar,
             1,
             3,
             pressureText,
             text_color = pressureColor,
             bgcolor    = color.new(MCP_BLACK, 5),
             text_size  = size.tiny
         )

        table.cell_set_tooltip(
             radar,
             1,
             3,
             "Directional Pressure ranges from -100 to +100.\n\nNegative = bearish pressure.\nPositive = bullish pressure.\nNear zero = balanced pressure.\n\nPressure and Energy are calculated separately."
         )

        table.cell(
             radar,
             0,
             4,
             "READ",
             text_color = MCP_MUTED,
             bgcolor    = color.new(MCP_BLACK, 5),
             text_size  = size.tiny
         )

        table.cell(
             radar,
             1,
             4,
             readText,
             text_color = currentStateColor,
             bgcolor    = color.new(MCP_BLACK, 5),
             text_size  = size.tiny
         )

        table.cell_set_tooltip(
             radar,
             1,
             4,
             "Plain-language interpretation of the current volatility state.\n\nIt is descriptive, not predictive, and is not a BUY/SELL instruction."
         )

    else

        table.clear(
             radar,
             0,
             0,
             1,
             4
         )


// ============================================================================
// ALERT ENGINE
// ============================================================================

bool alertReady =
     not confirmAlertsOnClose or
     barstate.isconfirmed

bool enabledCompression =
     alertReady and
     alertCompression and
     compressionEvent

bool enabledCharging =
     alertReady and
     alertCharging and
     chargingEvent

bool enabledIgnition =
     alertReady and
     alertIgnition and
     ignitionEvent

bool enabledExpansion =
     alertReady and
     alertExpansion and
     expansionEvent

bool enabledExhaustion =
     alertReady and
     alertExhaustion and
     exhaustionEvent

bool enabledPressureFlip =
     alertReady and
     alertPressureFlip and
     pressureFlipEvent

bool anyReactorEvent =
     enabledCompression or
     enabledCharging or
     enabledIgnition or
     enabledExpansion or
     enabledExhaustion or
     enabledPressureFlip


// ============================================================================
// ALERT CONDITIONS
// ============================================================================

alertcondition(
     enabledCompression,
     "Volatility Compression",
     "Volatility Reactor [MontyCodexPro] - COMPRESSION on {{ticker}} ({{interval}})."
 )

alertcondition(
     enabledCharging,
     "Volatility Charging",
     "Volatility Reactor [MontyCodexPro] - CHARGING on {{ticker}} ({{interval}})."
 )

alertcondition(
     enabledIgnition,
     "Volatility Ignition",
     "Volatility Reactor [MontyCodexPro] - IGNITION on {{ticker}} ({{interval}})."
 )

alertcondition(
     enabledExpansion,
     "Volatility Expansion",
     "Volatility Reactor [MontyCodexPro] - EXPANSION on {{ticker}} ({{interval}})."
 )

alertcondition(
     enabledExhaustion,
     "Volatility Exhaustion",
     "Volatility Reactor [MontyCodexPro] - EXHAUSTION on {{ticker}} ({{interval}})."
 )

alertcondition(
     enabledPressureFlip,
     "Directional Pressure Flip",
     "Volatility Reactor [MontyCodexPro] - directional pressure flip on {{ticker}} ({{interval}})."
 )

alertcondition(
     anyReactorEvent,
     "Any Reactor Event",
     "Volatility Reactor [MontyCodexPro] - Reactor event on {{ticker}} ({{interval}})."
 )
````
