# Ehlers Decycler Oscillator [NovaLens]

- url: https://www.tradingview.com/script/k2PygJ16-Ehlers-Decycler-Oscillator-NovaLens/
- type: indicator
- pine_id: PUB;eccdc770943a4dabb520363f950c4385
- version: 1.0

## Description

Adaptive momentum oscillator built to separate two things most oscillators blur together: cycle rotation and distribution extremes. Auto-detects the dominant cycle, grades the oscillator against its own rolling history, and highlights confluence when both channels align.

Most oscillators conflate "the swing is high" with "the swing is reversing." They use the same colour, the same arrow, the same alert for both. The Decycler Oscillator separates them by design:

[list]
[*][b]Cycle channel[/b] tracks WHERE the swing is in its rotation (Rising / Topping / Falling / Bottoming).
[*][b]Distribution channel[/b] tracks WHERE the value sits in its own rolling history (Upper Extreme / Upper / Lower / Lower Extreme).
[/list]

A reading at the upper extreme of the distribution is not a sell signal. It is the market saying "this is rare for me." Whether it actually reverses depends on the cycle channel. When both channels agree (a cycle turn happening right at a distribution extreme), that is the confluence event. Everything else is partial information, and the indicator says so.


════════════════════════════════════════════

◉ [b]HOW IT WORKS[/b]

[b]The filter.[/b] The core is John Ehlers' Decycler Oscillator (Cycle Analytics for Traders, 2013): a two-stage high-pass filter that strips the slow trend out of price and leaves the swing component. We run two of them in parallel (Fast at the dominant period, Slow at 1.25x) and read crossovers as cycle turns.

[b]The adaptive period.[/b] The dominant period itself is detected, not assumed. On the Adaptive profile, an Autocorrelation Periodogram (Ehlers, 2016) scans a timeframe-derived range every bar, pulls the strongest cycle by power-weighted centre of gravity, and feeds that period into the filter. Scan range auto-tunes to the chart timeframe: 8-30 bars on intraday, 20-60 on daily and above. Fixed profiles (Reactive / Balanced / Smooth) skip the scan and lock the period for traders who already know the rhythm of their asset.

[b]The rank window.[/b] The output is percentile-ranked over a rolling window (about 2x cycle period) to produce the four-tier distribution grade.

The window LOCKS on confirmed zero-line crosses. A mid-swing period shift cannot silently shrink the window and produce phantom Upper Extreme reads. That single lock helps keep the percentile grade more stable across regime transitions.


════════════════════════════════════════════


◈ [b]HOW TO READ IT[/b]

The pane shows two lines (Fast and Slow) wrapped in a ribbon coloured by the current distribution tier:

[list]
[*]Teal: Upper Extreme
[*]Dark teal: Upper
[*]Burgundy: Lower
[*]Red: Lower Extreme
[/list]

[b]Markers, in order of conviction:[/b]

[list]
[*][b]Cycle Cross[/b] (small triangle): Fast crossed Slow in a tier-aligned direction. "Cycle just flipped." Mid-tier crosses are filtered out as chop noise.
[*][b]Reversal Confluence[/b] (large triangle): a cycle cross within 0-2 bars of a same-side exhaustion signal. Both channels agreed. This is the primary event the indicator is built around.
[*][b]Exhaustion[/b] (small circle, [i]colour inverted[/i]): oscillator peaked or troughed at the extreme of its rolling distribution. Colour is inverted by design to make exhaustion easier to read. A RED peak means upside pressure may be cooling. A GREEN trough means downside pressure may be fading. Distribution extremes are non-directional information.
[*][b]Continuation[/b] (Bull/Bear pill, small rounded label "Bull" / "Bear"): hidden divergence. Oscillator made a lower trough while close made a higher close (Bull), or oscillator made a higher peak while close made a lower close (Bear). This can support a continuation read rather than a reversal read.
[/list]

The info panel (top right by default) synthesises all five channels into one Setup line: Strong Bull/Bear Setup, Continuation Forming, Topping/Bottoming, Trend Running Up/Down, Stretched, Drift, or Quiet, in priority order.


════════════════════════════════════════════


✦ [b]HOW WE USE IT: CONFLUENCE OVER CROSSES[/b]

A common pattern on a liquid futures or crypto chart, Adaptive profile: ribbon goes Lower Extreme as price drops into a support zone. Lower Exhaustion fires (green circle, candle border tints orange). Within 2 bars, Fast crosses up through Slow, and a Reversal Confluence triangle prints below the ribbon. The Setup row reads "Strong bull setup." Tier transitions back through Lower into Upper on the next leg up.

That is the indicator doing its job: telling you the cycle and the distribution channels both agreed, in the same direction, within the same 2-bar window. Without confluence, the same cycle cross can appear frequently in choppy conditions and often carries less value on its own. Confluence is designed to reduce low-quality cycle flips by gating on the distribution extreme.

The Continuation pill addresses a different problem: spotting possible trend resumption. On a pullback within an uptrend, price holds a higher low while the oscillator prints a lower trough. That is hidden bullish divergence, which can support a continuation read rather than a reversal read. The indicator draws a small Bull pill below the ribbon. Built to be read quickly.


════════════════════════════════════════════


✦ [b]OTHER APPLICATIONS[/b]

[list]
[*][b]Reversal context[/b]: confluence triangles after a cycle turn at the distribution extreme, optionally combined with the Setup row reading Strong Bull/Bear Setup
[*][b]Trend continuation[/b]: Bull/Bear pills inside a clean directional move, used as continuation context inside an existing trend plan
[*][b]Distribution awareness[/b]: Upper Extreme / Lower Extreme tier reads as a "rare for this market" cue, layered on top of any external trade plan
[*][b]Cycle phase tracking[/b]: the info-panel Phase row (Rising / Topping / Falling / Bottoming) as a regime descriptor for higher-timeframe positioning
[*][b]Alert-driven workflow[/b]: subscribe to confluence and exhaustion alerts to reduce chart-watching and focus only on higher-priority events
[/list]


════════════════════════════════════════════


⚙ [b]GETTING STARTED[/b]

The Ehlers Decycler Oscillator ships with practical starting profiles:

[list]
[*][b]Adaptive[/b] (default): Autocorrelation Periodogram detects the dominant cycle every bar. Useful when the asset's typical cycle is unclear.
[*][b]Reactive[/b]: HP Period 40, faster turns. Use on shorter timeframes or fast-moving instruments.
[*][b]Balanced[/b]: HP Period 80, middle ground. A reasonable starting point on most assets if you want a fixed period.
[*][b]Smooth[/b]: HP Period 125, slower turns. Use on higher timeframes or when you want only larger-scale rotations.
[*][b]Custom[/b]: full manual control of HP Period and Rank Window.
[/list]

[b]Core settings:[/b]

[list]
[*][b]Profile[/b]: selects the tuning bundle above. Start with Adaptive.
[*][b]HP Period (Custom)[/b]: dominant cycle the filter targets, in BARS. 80 means 80 candles. The calendar time depends on the market and timeframe. Longer = smoother, fewer turns; shorter = more reactive.
[*][b]Rank Window (Custom)[/b]: rolling lookback for the 4-tier percentile grade. Rule of thumb: about 2x HP Period.
[*][b]Min/Max Period Override (Adaptive)[/b]: clamp the cycle scan range. 0 = auto-derive from chart timeframe.
[/list]

[b]Continuation settings:[/b]

[list]
[*][b]Show Bull/Bear (Continuation)[/b]: toggle the hidden-divergence pills.
[*][b]Max Lookback (Continuation)[/b]: bars between the two extremes that define a continuation pattern. 0 = auto: 2x average cycle once 3 cycles confirm, else 40.
[/list]

[b]Marker settings:[/b]

[list]
[*][b]Show Cycle Crosses[/b] / [b]Show Confluence Crosses[/b]: independent toggles. Turn cycle crosses OFF and confluence ON to see only primary confluence events.
[*][b]Show Exhaustion[/b]: distribution-extreme circles on the ribbon. Colour INVERTED by design.
[*][b]Show Price Chart Markers[/b]: mirrors confluence and exhaustion onto the price chart.
[/list]

[b]Display:[/b]

[list]
[*][b]Show Info Panel[/b]: 5-row panel (Tier / Phase / Exhaustion / Setup / Cycle). On by default.
[*][b]Light Theme Mode[/b]: swap info-panel colours for light chart backgrounds.
[/list]


════════════════════════════════════════════


△ [b]LIMITATIONS[/b]

[list]
[*][b]Warm-up[/b]: Adaptive needs a brief warm-up period (typically 40-80 bars depending on timeframe) before the cycle scan returns confident readings. Until then, the info panel shows "warming up..." and signals are suppressed.
[*][b]Choppy markets[/b]: when the autocorrelation power drops below 0.5, the cycle confidence is "Low" and the indicator says so. Weak signal tends to produce noisy reads.
[*][b]Adaptive period drift[/b]: fast HP-period changes can make the oscillator amplitude jump. The alpha-smoothing pass softens this, but in extreme regime shifts the first 5-10 bars after a shift may read noisier.
[*][b]Fixed profiles bypass cycle confidence[/b]: Reactive / Balanced / Smooth do not run the cycle scan, so they cannot tell you when the rhythm is unclear. Adaptive can.
[*][b]Continuation needs at least 8 bars between extremes[/b]: pivots closer than that are filtered as noise. On very fast intraday timeframes this can suppress otherwise-valid patterns.
[*][b]Continuation in parabolic moves[/b]: hidden divergence can chain-fire on blow-off legs because momentum stays pinned at the extreme while price continues to expand, marking same-direction pills back-to-back when momentum is overstretched. They remain continuation reads, not exhaustion warnings.
[/list]


════════════════════════════════════════════


🔔 [b]ALERTS[/b]

Ten alert conditions are built in so you can monitor without checking every bar manually:

[list]
[*][b]Upper Exhaustion / Lower Exhaustion[/b]: oscillator peaked or troughed at the extreme of its rolling distribution. The RED-at-top, GREEN-at-bottom inversion still applies.
[*][b]Topping / Bottoming[/b]: cycle phase transitioned (Rising to Topping, or Falling to Bottoming).
[*][b]Bull Cross / Bear Cross[/b]: Fast crossed Slow in a tier-aligned direction without a same-side exhaustion in the prior 2 bars.
[*][b]Bull Cross Confluence / Bear Cross Confluence[/b]: Fast crossed Slow within 2 bars of a same-side exhaustion signal. The main confluence event.
[*][b]Bull Continuation / Bear Continuation[/b]: hidden-divergence pattern confirmed (oscillator and price disagreement in the trend direction).
[/list]

All ten alerts fire on bar close (gated on barstate.isconfirmed). Each alert message includes ticker, price, timeframe, and timestamp placeholders for webhook routing.


════════════════════════════════════════════


⌁ [b]NOTES[/b]

[list]
[*]The original Decycler Oscillator construction was developed against a Python reference implementation under PyneCore.
[*]Repaint: intrabar-only. Closed-bar alerts are confirmed; current-bar visuals may update until the bar closes. All alert conditions are gated on barstate.isconfirmed.
[*]References: John F. Ehlers, [i]Cycle Analytics for Traders[/i] (2013), Wiley; Ehlers, [i]Autocorrelation Periodogram[/i] (Stocks & Commodities, 2016).
[*]Open-source under MPL 2.0. Free to use, fork, study.
[/list]

[b]NovaLens[/b]

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// © NovaLens

//@version=6
// ──────────────────────────────────────────────────────────────────────────────
// Ehlers Decycler Oscillator [NovaLens]
// John Ehlers' Decycler Oscillator, reframed around adaptive cycle detection
// and presented in the dual-line ribbon form traders recognize.
//
// Reads the swing in two channels:
//   (1) Where price sits in its own distribution - the 4-tier percentile grade
//       (Upper Extreme / Upper / Lower / Lower Extreme) drives the ribbon colour.
//   (2) Where the cycle is in its rotation - phase clock (Rising / Topping /
//       Falling / Bottoming) tracked off the fast oscillator slope.
//
// Signal hierarchy on the pane and mirrored onto the price chart:
//   • Cycle cross          small triangle at the ribbon midpoint on fast/slow
//                          crosses with tier-aligned direction.
//   • Reversal Confluence  larger triangle on a cross within 0-2 bars of a
//                          same-side Exhaustion on the same tier visit.
//   • Exhaustion           small transparent circle on the ribbon edge when
//                          the oscillator peaks / troughs at the edge of its
//                          rolling distribution. Non-directional (colour
//                          inverted by design: upper = red cooling,
//                          lower = green supporting).
//   • Continuation         'Bull' / 'Bear' pill on hidden divergence: momentum
//                          contracted while price stayed in-trend.
//
// Profile presets pre-tune the HP period and rank window for common horizons
// (Reactive / Balanced / Smooth) or run the Autocorrelation Periodogram on
// Adaptive to detect the dominant cycle directly.
//
// Repaint: intrabar-only. All alerts gated on barstate.isconfirmed.
// ──────────────────────────────────────────────────────────────────────────────
indicator("Ehlers Decycler Oscillator [NovaLens]", shorttitle="Ehlers Decycler [NovaLens]", overlay=false, precision=4, max_bars_back=600, max_labels_count=500)

// ─── Brand constants ────────────────────────────────────────────────────────
string BRAND_NAME    = "NovaLens"
string BRAND_ENTITY  = "NovaLens Quantitative Research"
string productCode   = "DC-01"
string productTier   = "Free"

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
string PROF_ADAPT    = "Adaptive"
string PROF_REACTIVE = "Reactive"
string PROF_BALANCED = "Balanced"
string PROF_SMOOTH   = "Smooth"
string PROF_CUSTOM   = "Custom"

string presetTip = "Picks how the oscillator reads the market. Each profile pre-tunes HP period AND rank window.\n\n• Adaptive (default) - cyclical markets (crypto, ranging FX, chop).\n  Detects cycle rhythm via Autocorrelation Periodogram. Cycle row in the info panel shows the detected period and confidence. You will see the scan range auto-re-tune if you change timeframe. Leaner signals, stricter adaptive gate.\n\n• Reactive - intraday and short swings.\n  HP 40 / rank 100. Daily ≈ 2 months, 1H ≈ 1.5 days. You will see more cycle crosses per session; distribution-extreme reads are shallower.\n\n• Balanced - daily swings (stocks, commodities, major FX).\n  HP 80 / rank 150. Daily ≈ 4 months, 1H ≈ 3 days. Confluence becomes the headline signal; cycle crosses alone are less frequent but more meaningful.\n\n• Smooth - weekly, position-grade trend following.\n  HP 125 / rank 250. Filters noise aggressively. Few signals per month on Daily; exhaustions here teach the most.\n\n• Custom - drive HP and rank from the inputs below.\n\nSignal density: Reactive > Adaptive > Balanced > Smooth. Values in BARS - chart timeframe sets wall-clock duration."

profile = input.string(PROF_ADAPT, "Profile", options=[PROF_ADAPT, PROF_REACTIVE, PROF_BALANCED, PROF_SMOOTH, PROF_CUSTOM], group="Parameters", tooltip=presetTip)

// ─── Custom ─────────────────────────────────────────────────────────────────
customPeriod  = input.int(80,  "HP Period",      minval=10, maxval=300, group="Custom",
     tooltip="Dominant cycle period the two-stage HP filter targets, in BARS.\n\n80 ≈ 4 months on 1D, 3 days on 1H, 80 minutes on 1min. Longer = smoother, fewer but more meaningful turns; shorter = more reactive.\n\nHalving HP roughly doubles cycle crosses per session; doubling it halves them. Rank Window should follow (≈ 2× HP) so tier grades stay calibrated to the new rotation speed.\n\nApplies only when Profile = Custom.")
customRank    = input.int(150, "Rank Window",    minval=50, maxval=500, group="Custom",
     tooltip="Rolling lookback the oscillator is percentile-ranked against for the 4-tier grading.\n\nLonger window = tier grades settle against a stable distribution (fewer Upper/Lower Extreme readings, each more meaningful). Shorter = compares to recent memory only (more extremes, more reactive).\n\nRule of thumb: rank window ≈ 2× HP period.\n\nApplies only when Profile = Custom.")

// ─── Adaptive - overrides default to 0 (auto from timeframe) ────────────────
autoMinPeriod = input.int(0,  "Min Period Override (0 = auto)", minval=0, maxval=40,  group="Adaptive",
     tooltip="Optional override for Adaptive's cycle scan LOWER bound, in BARS. Applies only when Profile = Adaptive.\n\n0 (default) = auto from timeframe:\n ≤15m → 8 · 30m-1H → 14 · 2H-12H → 18 · Daily+ → 20\n\nSet 8-40 to force a different lower bound. Below 8 reads HF noise the roofing filter already attenuates.\n\n0 here means 'use the auto value,' NOT 'ignore the bound.' Independent of Max.")
autoMaxPeriod = input.int(0,  "Max Period Override (0 = auto)", minval=0, maxval=100, group="Adaptive",
     tooltip="Optional override for Adaptive's cycle scan UPPER bound, in BARS. Applies only when Profile = Adaptive.\n\n0 (default) = auto from timeframe:\n ≤15m → 30 · 30m-1H → 45 · 2H-12H → 55 · Daily+ → 60\n\nSet 30-100 to force a different upper bound. Past ~80, prefer the Balanced/Smooth profiles - the roofing filter already attenuates longer cycles.\n\n0 here means 'use the auto value.' Independent of Min.")

// ─── Continuation (Hidden Divergence) ───────────────────────────────────────
showContinuation        = input.bool(true, "Show Bull/Bear (Continuation)", group="Continuation (Hidden Divergence)", tooltip="Small pill - 'Bull' (GREEN, below ribbon) or 'Bear' (RED, above ribbon) - fires on a HIDDEN DIVERGENCE. Momentum contracted while price stayed in-trend. Reads as 'trend consolidating, not reversing.'\n\n• Bull - fastOsc LOWER trough + close HIGHER than prev trough close. Gate: tier ≤ 1 (Lower / Lower Extreme).\n• Bear - fastOsc HIGHER peak + close LOWER than prev peak close. Gate: tier ≥ 2 (Upper / Upper Extreme).\n\nGuards: min 8-bar spacing + 5% envelope significance + Max Lookback cap. Filters noise pivots inside one cycle.\n\nPair with Exhaustion to read the opposite state: Exhaustion = distribution-edge cooling; Continuation = in-trend consolidation.\n\nSuppressed during warm-up.")
continuationMaxLookback = input.int(0, "Max Lookback (0 = auto)", minval=0, maxval=200, group="Continuation (Hidden Divergence)", tooltip="Max bars between the two peaks (bear) or two troughs (bull) that define a continuation pattern.\n\n0 (default) = auto: 2× average cycle length once 3 cycles confirm, else 40 bars.\nManual: 1-200. Shorter = only near-term patterns qualify; longer = older extremes still count.\n\nFLOOR: values below minimum cycle length (auto-tuned 8-20 bars) are silently raised - a continuation pattern needs that minimum spacing between extremes to be distinct.\n\nSATURATION: real peaks/troughs almost always resolve within one cycle window (~30-60 bars at Balanced horizon), so settings above ~40-60 produce near-identical behavior. If the control feels unresponsive in the 40-200 range, that's why.")

// ─── Display ────────────────────────────────────────────────────────────────
showCycleCrosses      = input.bool(true, "Show Cycle Crosses",      group="Display", tooltip="Small ▲/▼ at the ribbon midpoint - fast crossed slow in a direction-aligned tier half.\n\nGate: Bull needs tier ≤ 1 (room to rise); Bear needs tier ≥ 2 (room to fall). Mid-tier crosses still color the ribbon, just no marker - that was chop noise.\n\nObservational: 'cycle momentum just flipped.' Pair with Phase in the info panel.\n\nTurn OFF and leave Confluence ON to see only high-conviction events. Suppressed during warm-up.")
showConfluenceCrosses = input.bool(true, "Show Confluence Crosses", group="Display", tooltip="Larger ▲/▼ at the ribbon midpoint - a cross within 0-2 bars of a matching-side EXHAUSTION on the same tier visit. Higher-conviction.\n\n• Bull = bullCross (tier ≤ 1) + Lower Exhaustion within 2 bars\n• Bear = bearCross (tier ≥ 2) + Upper Exhaustion within 2 bars\n\nReads as 'cycle flipped right at exhaustion' - both channels agreed. Suppressed during warm-up.")
showStretch    = input.bool(true,  "Show Exhaustion",  group="Display", tooltip="Small transparent circle on the ribbon when the oscillator peaks/troughs at the edge of its distribution. One per visit to the extreme zone.\n\nGate:\n • Reactive/Balanced/Smooth/Custom - top/bottom quartile (tier 3 / 0)\n • Adaptive - top/bottom 15% + |fastOsc| ≥ 0.5× envelope deadband\n\nCOLOR INVERTED by design:\n • Upper Exhaustion = RED - topping pressure, NOT bullish\n • Lower Exhaustion = GREEN - support showing, NOT bearish\n\nExhaustion is distribution-edge, not direction. Crosses keep conventional teal/red.\n\nPrice chart: candle tints strong orange on fires (Show Price Chart Markers). Suppressed during warm-up.")
showPriceMarkers = input.bool(true, "Show Price Chart Markers", group="Display", tooltip="Mirrors the pane's signal hierarchy onto the price chart.\n\n• Confluence → full-color ▲/▼ (below/above candle)\n• Exhaustion → candle tints strong orange - non-directional. Pane circle shows which side (upper = red, lower = green).\n• Plain cycle cross → small 50%-alpha ▲/▼\n\nReads as: full-color ▲/▼ = both channels agreed, orange candle = distribution edge (check the pane circle for side), faded ▲/▼ = cycle-only, partial information.\n\nEach overlay tracks its in-pane toggle. Master off = ALL price-chart markers silenced.")
showInfoPanel  = input.bool(true,  "Show Info Panel",  group="Display", tooltip="Plain-English state panel in the top-right: Tier, Phase, Exhaustion, Setup, and (Adaptive only) Cycle.\n\nThe Setup row - one-line state synthesis - is always shown when the panel is on. Hover any row label for what the metric means and how to read it.")
lightTheme     = input.bool(false, "Light Theme Mode", group="Display", tooltip="Swap info-panel backgrounds and label colors for light chart backgrounds.\n\nOscillator lines, ribbon, and markers are unaffected - they render the same on dark and light charts.")

// ══════════════════════════════════════════════════════════════════════════════
//  COLOR PALETTE - 4 tier colors + exhaustion border + UI chrome
// ══════════════════════════════════════════════════════════════════════════════
const color C_UP_STRONG   = #00E6B4
const color C_UP_MID      = #006E55
const color C_DOWN_MID    = #8C2D2B
const color C_DOWN_STRONG = #FF504B
const color C_BEAR_PILL   = #D63F3B
const color C_GRAY        = #787B86
const color C_EXH_BAR     = #FF8C00

// K-asymmetry - fast line amplified 1.2× so crosses fire from the fast side
// first, giving the slow line its "catch-up" lag that defines the ribbon.
float K_FAST = 1.2
float K_SLOW = 1.0

// ══════════════════════════════════════════════════════════════════════════════
//  AUTOCORRELATION PERIODOGRAM (Ehlers) - dominant-cycle detector
// ══════════════════════════════════════════════════════════════════════════════
// Pipeline:
//   1. Roofing filter: HP (period 48) → SuperSmoother (period 10)
//   2. Two-pass correlation scan over [autoMinEff, autoMaxEff]:
//        Pass 1 → fill R[period] = max(corr,0)² and track maxR
//        Pass 2 → Center-of-Gravity period across bins where R ≥ 0.5·maxR
//   3. Power-threshold hysteresis: only update detectedPeriod when maxR ≥ 0.25
//      (Ehlers' "if Sp < threshold: hold previous").
// Gated behind PROF_ADAPT; other presets skip the scan entirely.
hpAlpha = (1 - math.sin(2 * math.pi / 48)) / math.cos(2 * math.pi / 48)
var float acpHp           = 0.0
var float filt            = 0.0
var float detectedPeriod  = 80.0
var bool  holdingLowConf  = false

// Timeframe-derived bounds. nz(..,60) covers Renko/Range/tick/volume charts
// where timeframe.in_seconds() returns na (na comparisons evaluate false in
// Pine, which would silently fall through to the Daily+ bucket).
int tfSec = nz(timeframe.in_seconds(), 60)
int autoMinAuto = 20
int autoMaxAuto = 60
if tfSec <= 900
    autoMinAuto := 8
    autoMaxAuto := 30
else if tfSec <= 3600
    autoMinAuto := 14
    autoMaxAuto := 45
else if tfSec <= 43200
    autoMinAuto := 18
    autoMaxAuto := 55

// Inversion guard: normalize effective bounds so an inverted override pair
// (Min > Max, or Min beyond the auto Max) can't poison scanCount / the
// corrPower array / the ACP loop.
int  rawMinEff    = autoMinPeriod > 0 ? autoMinPeriod : autoMinAuto
int  rawMaxEff    = autoMaxPeriod > 0 ? autoMaxPeriod : autoMaxAuto
int  autoMinEff   = math.min(rawMinEff, rawMaxEff)
int  autoMaxEff   = math.max(rawMinEff, rawMaxEff)
bool boundsManual = autoMinPeriod > 0 or autoMaxPeriod > 0

int scanCount = autoMaxEff - autoMinEff + 1
// Pine v6 re-runs from bar 0 when an input changes, so this var sizes
// correctly each time without a defensive resize check.
var array<float> corrPower = array.new<float>(scanCount, 0.0)

float bestCorr = 0.0

if profile == PROF_ADAPT
    acpHp := 0.5 * (1 + hpAlpha) * (close - nz(close[1])) + hpAlpha * nz(acpHp[1])

    ssA1 = math.exp(-math.sqrt(2) * math.pi / 10)
    ssB1 = 2 * ssA1 * math.cos(math.sqrt(2) * math.pi / 10)
    ssC2 = ssB1
    ssC3 = -ssA1 * ssA1
    ssC1 = 1 - ssC2 - ssC3
    filt := ssC1 * (acpHp + nz(acpHp[1])) / 2 + ssC2 * nz(filt[1]) + ssC3 * nz(filt[2])

    // Skip the nested correlation scan during warm-up - output is flagged
    // acpWarm and discarded downstream anyway. The HP + SuperSmoother filter
    // chain above still runs so filt[i+period] has the history it needs once
    // the scan resumes.
    float maxR = 0.0
    if bar_index >= autoMaxEff * 2
        for period = autoMinEff to autoMaxEff
            float sx  = 0.0
            float sy  = 0.0
            float sxx = 0.0
            float syy = 0.0
            float sxy = 0.0
            for i = 0 to period - 1
                float x = filt[i]
                float y = filt[i + period]
                sx  += x
                sy  += y
                sxx += x * x
                syy += y * y
                sxy += x * y
            float denom = (period * sxx - sx * sx) * (period * syy - sy * sy)
            float corr  = denom > 0 ? (period * sxy - sx * sy) / math.sqrt(denom) : 0.0
            float R     = corr > 0 ? corr * corr : 0.0
            array.set(corrPower, period - autoMinEff, R)
            if R > maxR
                maxR := R

    bestCorr := math.sqrt(maxR)

    // Power-threshold hysteresis + CoG accumulation (only if confident).
    float cogNum = 0.0
    float cogDen = 0.0
    if maxR >= 0.25
        for period = autoMinEff to autoMaxEff
            float R = array.get(corrPower, period - autoMinEff)
            if R >= 0.5 * maxR
                cogNum += float(period) * R
                cogDen += R

    if cogDen > 0
        detectedPeriod := cogNum / cogDen
        holdingLowConf := false
    else
        holdingLowConf := true

string confStr = bestCorr >= 0.75 ? "High" : bestCorr >= 0.50 ? "Medium" : "Low"

bool acpWarm = bar_index < autoMaxEff * 2

float hpPeriodEff = profile == PROF_REACTIVE ? 40.0 : profile == PROF_BALANCED ? 80.0 : profile == PROF_SMOOTH ? 125.0 : profile == PROF_CUSTOM ? float(customPeriod) : math.max(float(autoMinEff), detectedPeriod)

// Slow companion runs at 1.25× fast period - canonical Ehlers 100/125 ratio.
float slowPeriod = hpPeriodEff * 1.25

// ══════════════════════════════════════════════════════════════════════════════
//  CORE - Ehlers two-stage HP filter, FAST chain (hpPeriodEff)
// ══════════════════════════════════════════════════════════════════════════════
// α-smoothing: when hpPeriodEff drifts (Adaptive), raw α applied to historical
// state memory injects ringing. Smooth α with a 3-bar EMA before deriving the
// c-coefficients. No-op for fixed presets (constant α → EMA is the constant).
int    ALPHA_EMA_LEN = 3
cosVal1Raw = math.cos(math.toradians(0.707 * 360 / hpPeriodEff))
sinVal1Raw = math.sin(math.toradians(0.707 * 360 / hpPeriodEff))
alpha1Raw  = (cosVal1Raw + sinVal1Raw - 1) / cosVal1Raw
alpha1     = ta.ema(alpha1Raw, ALPHA_EMA_LEN)

cosVal2Raw = math.cos(math.toradians(0.707 * 360 / (0.5 * hpPeriodEff)))
sinVal2Raw = math.sin(math.toradians(0.707 * 360 / (0.5 * hpPeriodEff)))
alpha2Raw  = (cosVal2Raw + sinVal2Raw - 1) / cosVal2Raw
alpha2     = ta.ema(alpha2Raw, ALPHA_EMA_LEN)

var float hp1   = 0.0
var float hp1_1 = 0.0
var float hp1_2 = 0.0

c0 = (1 - alpha1 / 2) * (1 - alpha1 / 2)
c1 = 2 * (1 - alpha1)
c2 = (1 - alpha1) * (1 - alpha1)

hp1_new = c0 * (close - 2 * nz(close[1]) + nz(close[2])) + c1 * hp1_1 - c2 * hp1_2
hp1_2 := nz(hp1_1)
hp1_1 := nz(hp1_new)
hp1   := nz(hp1_new)

decycle = close - hp1

var float hp2   = 0.0
var float hp2_1 = 0.0
var float hp2_2 = 0.0
var float dec_1 = 0.0
var float dec_2 = 0.0

d0 = (1 - alpha2 / 2) * (1 - alpha2 / 2)
d1 = 2 * (1 - alpha2)
d2 = (1 - alpha2) * (1 - alpha2)

hp2_new = d0 * (decycle - 2 * dec_1 + dec_2) + d1 * hp2_1 - d2 * hp2_2
dec_2 := nz(dec_1)
dec_1 := nz(decycle)
hp2_2 := nz(hp2_1)
hp2_1 := nz(hp2_new)
hp2   := nz(hp2_new)

fastOsc = close != 0 ? 100 * K_FAST * hp2 / close : 0.0

// ══════════════════════════════════════════════════════════════════════════════
//  SLOW chain (slowPeriod) - same α-smoothing treatment as fast chain
// ══════════════════════════════════════════════════════════════════════════════
cosValS1Raw = math.cos(math.toradians(0.707 * 360 / slowPeriod))
sinValS1Raw = math.sin(math.toradians(0.707 * 360 / slowPeriod))
alphaS1Raw  = (cosValS1Raw + sinValS1Raw - 1) / cosValS1Raw
alphaS1     = ta.ema(alphaS1Raw, ALPHA_EMA_LEN)

cosValS2Raw = math.cos(math.toradians(0.707 * 360 / (0.5 * slowPeriod)))
sinValS2Raw = math.sin(math.toradians(0.707 * 360 / (0.5 * slowPeriod)))
alphaS2Raw  = (cosValS2Raw + sinValS2Raw - 1) / cosValS2Raw
alphaS2     = ta.ema(alphaS2Raw, ALPHA_EMA_LEN)

var float shp1   = 0.0
var float shp1_1 = 0.0
var float shp1_2 = 0.0

sc0 = (1 - alphaS1 / 2) * (1 - alphaS1 / 2)
sc1 = 2 * (1 - alphaS1)
sc2 = (1 - alphaS1) * (1 - alphaS1)

shp1_new = sc0 * (close - 2 * nz(close[1]) + nz(close[2])) + sc1 * shp1_1 - sc2 * shp1_2
shp1_2 := nz(shp1_1)
shp1_1 := nz(shp1_new)
shp1   := nz(shp1_new)

sdecycle = close - shp1

var float shp2   = 0.0
var float shp2_1 = 0.0
var float shp2_2 = 0.0
var float sdec_1 = 0.0
var float sdec_2 = 0.0

sd0 = (1 - alphaS2 / 2) * (1 - alphaS2 / 2)
sd1 = 2 * (1 - alphaS2)
sd2 = (1 - alphaS2) * (1 - alphaS2)

shp2_new = sd0 * (sdecycle - 2 * sdec_1 + sdec_2) + sd1 * shp2_1 - sd2 * shp2_2
sdec_2 := nz(sdec_1)
sdec_1 := nz(sdecycle)
shp2_2 := nz(shp2_1)
shp2_1 := nz(shp2_new)
shp2   := nz(shp2_new)

slowOsc = close != 0 ? 100 * K_SLOW * shp2 / close : 0.0

// ══════════════════════════════════════════════════════════════════════════════
//  PRESET RESOLUTION - rank window per preset
// ══════════════════════════════════════════════════════════════════════════════
// Rank window ≈ 2× dominant cycle gives ~2 cycles of percentile context. On
// Adaptive the window is LOCKED: only resize on a confirmed zero-line cross
// (full cycle reset), so a mid-swing period shift can't shrink the window and
// silently drop old peaks from the distribution (would produce phantom Upper
// Extreme reads without price moving). Floor of 100 keeps intraday behavior
// stable. Fixed profiles use static windows.
int adaptiveRankRaw = math.max(100, int(math.round(hpPeriodEff * 2)))
var int adaptiveRankLocked = 100
bool zeroCrossAdaptive = ta.cross(fastOsc, 0)
if profile == PROF_ADAPT and (bar_index < 50 or zeroCrossAdaptive)
    adaptiveRankLocked := adaptiveRankRaw

int rankWindow = profile == PROF_REACTIVE ? 100 : profile == PROF_BALANCED ? 150 : profile == PROF_SMOOTH ? 250 : profile == PROF_CUSTOM ? customRank : adaptiveRankLocked

// ══════════════════════════════════════════════════════════════════════════════
//  4-TIER PERCENTILE GRADING - on the fast oscillator
// ══════════════════════════════════════════════════════════════════════════════
float pctRank = nz(ta.percentrank(fastOsc, rankWindow), 50.0)

int    tier      = pctRank < 25.0 ? 0 : pctRank < 50.0 ? 1 : pctRank < 75.0 ? 2 : 3
string tierStr   = tier == 3 ? "Upper Extreme" : tier == 2 ? "Upper" : tier == 1 ? "Lower" : "Lower Extreme"
color  tierColor = tier == 3 ? C_UP_STRONG : tier == 2 ? C_UP_MID : tier == 1 ? C_DOWN_MID : C_DOWN_STRONG

// Fixed profiles don't use the ACP scan, so they don't need to wait for the
// ACP warm-up; only Adaptive gates on autoMaxEff * 2 (cold-start ≈ 2 cycles).
bool tierWarm = bar_index >= (profile == PROF_ADAPT ? math.max(rankWindow, autoMaxEff * 2) : rankWindow)

// Rolling oscillator envelope - shared by Adaptive's exhaustion deadband and
// marker vertical offsets.
float oscEnvelope = math.max(ta.highest(math.max(math.abs(fastOsc), math.abs(slowOsc)), 200), 0.5)

// ══════════════════════════════════════════════════════════════════════════════
//  4-STATE CYCLE-PHASE CLOCK + PERSISTENT CYCLE MEMORY
// ══════════════════════════════════════════════════════════════════════════════
float slope  = fastOsc - nz(fastOsc[1])
float slopeP = nz(fastOsc[1]) - nz(fastOsc[2])

bool peakBar   = slope <= 0 and slopeP >  0 and fastOsc >  0
bool troughBar = slope >= 0 and slopeP <  0 and fastOsc <  0

// EXHAUSTION - peak while top-quartile / trough while bottom-quartile, latched
// to one fire per tier visit. Adaptive layers three extra filters on top of
// the canonical quartile gate:
//   1. pctRank ≥ 85 (upper) / ≤ 15 (lower) - top/bottom 15% of distribution.
//   2. |fastOsc| ≥ 0.5 × envelope deadband - kills near-zero micro-peaks.
//   3. rank-window lock (above) - keeps the distribution stable.
// Re-arm hysteresis: Adaptive must drop a full 15 percentile points (below 70
// upper / above 30 lower) to re-arm; other profiles re-arm on tier exit.
bool isAdaptive = profile == PROF_ADAPT
float deadband = oscEnvelope * 0.5

bool upperGate = isAdaptive ? (pctRank >= 85.0 and fastOsc >=  deadband) : (tier == 3)
bool lowerGate = isAdaptive ? (pctRank <= 15.0 and fastOsc <= -deadband) : (tier == 0)

// Re-arm cascade - three release valves:
//   1. RANK / TIER  primary trigger; pctRank dropped below 70 (Adaptive) or
//                   tier exited 3 (fixed). Original behavior.
//   2. HIGHER PIVOT a new peakBar at fastOsc materially above the last latched
//                   fire is itself a fire-worthy event (5% headroom guard).
//                   Closes the "86 → 72 → 99" macro-top blind spot: pctRank
//                   dipping to 71 then climbing to a higher peak no longer
//                   silently swallows the bigger exhaustion.
//   3. TIME DECAY   force re-arm after 2 × autoMaxEff (Adaptive) / 2 ×
//                   rankWindow (fixed) bars without a fire. Safety net for
//                   pathological cases where pctRank stays pinned and no
//                   higher pivot triggers - re-arm so the next valid pivot
//                   isn't permanently swallowed.
bool upperReArmRank = isAdaptive ? (pctRank < 70.0) : (tier < 3)
bool lowerReArmRank = isAdaptive ? (pctRank > 30.0) : (tier > 0)

var bool  upperArmed         = true
var bool  lowerArmed         = true
var float lastUpperFireOsc   = na
var float lastLowerFireOsc   = na
var int   barsSinceUpperFire = 0
var int   barsSinceLowerFire = 0

int rearmTimeout = isAdaptive ? autoMaxEff * 2 : rankWindow * 2

// Headroom is envelope-additive (5% of the rolling oscillator envelope) rather
// than a 1.05× multiplier. The multiplier didn't scale uniformly - at osc=200
// it required +10pt to re-arm; at osc=1.0 it required +0.05pt. Same label,
// vastly different strictness across asset volatilities. Mirror on the lower
// side: SUBTRACT the headroom so a deeper trough re-arms (sign-correct for
// both positive and negative lastLowerFireOsc).
bool upperReArmHigher = peakBar   and not na(lastUpperFireOsc) and fastOsc > lastUpperFireOsc + oscEnvelope * 0.05
bool lowerReArmLower  = troughBar and not na(lastLowerFireOsc) and fastOsc < lastLowerFireOsc - oscEnvelope * 0.05
bool upperReArmTime   = not upperArmed and barsSinceUpperFire >= rearmTimeout
bool lowerReArmTime   = not lowerArmed and barsSinceLowerFire >= rearmTimeout

bool upperReArm = upperReArmRank or upperReArmHigher or upperReArmTime
bool lowerReArm = lowerReArmRank or lowerReArmLower  or lowerReArmTime

if barstate.isconfirmed and upperReArm
    upperArmed := true
if barstate.isconfirmed and lowerReArm
    lowerArmed := true

bool upperStretch = barstate.isconfirmed and tierWarm and peakBar   and upperGate and upperArmed
bool lowerStretch = barstate.isconfirmed and tierWarm and troughBar and lowerGate and lowerArmed

if upperStretch
    upperArmed         := false
    lastUpperFireOsc   := fastOsc
    barsSinceUpperFire := 0
else
    barsSinceUpperFire += 1
if lowerStretch
    lowerArmed         := false
    lastLowerFireOsc   := fastOsc
    barsSinceLowerFire := 0
else
    barsSinceLowerFire += 1

var int lastStretchBar = na
var int lastStretchDir = 0
if upperStretch
    lastStretchBar := bar_index
    lastStretchDir := 1
if lowerStretch
    lastStretchBar := bar_index
    lastStretchDir := -1

var int phase = -1
if bar_index >= 2
    if peakBar
        phase := 1
    else if troughBar
        phase := 3
    else if slope > 0
        phase := 0
    else if slope < 0
        phase := 2

string phaseStr = phase == 0 ? "Rising" : phase == 1 ? "Topping" : phase == 2 ? "Falling" : phase == 3 ? "Bottoming" : "-"

var int phaseStartBar = 0
if bar_index > 0 and phase != nz(phase[1], phase) and phase >= 0
    phaseStartBar := bar_index
int phaseDuration = phase < 0 ? 0 : (bar_index - phaseStartBar + 1)

var int             lastCycleStart = na
var float           cycleAvgLen    = na
var array<int>      cycleHistory   = array.new<int>(0)

int minCycleLen = math.max(8, int(math.floor(autoMinEff / 2.0)))

// Advance lastCycleStart only on valid troughs (>= minCycleLen bars since the
// previous valid trough). Noise troughs below the floor would otherwise
// rebase the clock and bias the cycle-length history downward. Bootstrap:
// first-ever trough seeds lastCycleStart regardless of length.
if troughBar and barstate.isconfirmed
    if na(lastCycleStart)
        lastCycleStart := bar_index
    else
        int thisLen = bar_index - lastCycleStart
        if thisLen >= minCycleLen
            array.push(cycleHistory, thisLen)
            if array.size(cycleHistory) > 5
                array.shift(cycleHistory)
            cycleAvgLen := array.avg(cycleHistory)
            lastCycleStart := bar_index

bool  halfReady   = array.size(cycleHistory) >= 3
float halfTypical = halfReady ? cycleAvgLen / 2.0 : na

// ══════════════════════════════════════════════════════════════════════════════
//  HIDDEN DIVERGENCE (CONTINUATION)
// ══════════════════════════════════════════════════════════════════════════════
// Detects the CONTINUATION class of divergence (hidden, not regular):
//   Bull Continuation  fastOsc lower trough   AND  close higher than prev trough close
//   Bear Continuation  fastOsc higher peak    AND  close lower  than prev peak  close
// Uses the same peakBar/troughBar detector Exhaustion uses. Gate:
//   Bull on tier ≤ 1 (Lower / Lower Extreme)
//   Bear on tier ≥ 2 (Upper / Upper Extreme)
//
// Three guards on top of the basic pattern:
//   • Min-distance floor: ≥ minCycleLen bars between the two extremes (the
//     same 8-bar floor that protects cycleHistory). Filters noise pivots
//     inside one cycle.
//   • Significance gate: |fastOsc - lastTroughOsc| > oscEnvelope * 0.05. New
//     trough must be at least 5% of the rolling envelope deeper than the
//     reference. Mirrors the cross-angle filter (oscEnvelope * 0.015) and
//     the exhaustion deadband (oscEnvelope * 0.5).
//   • Lookback cap: contLookback = manual override or auto (2× cycleAvgLen
//     once halfReady, else 40 bars).
//
// Regular divergence (oscillator higher high + price higher high reversal)
// is intentionally SKIPPED - it would duplicate Exhaustion, which is already
// the distribution-edge reversal cue.
//
// Tracker capture uses [1] not current bar: peakBar = slope<=0 and slopeP>0
// fires the bar AFTER the actual peak, so fastOsc / close on the current bar
// are post-peak values. fastOsc[1] / close[1] are the textbook peak values.
//
// Tracker updates are tier-gated to match the fire-side gates: peak trackers
// only update at tier >= 2; trough trackers only update at tier <= 1. A noise
// pivot at the wrong tier doesn't seed the reference.
var float lastPeakOsc    = na
var float lastPeakClose  = na
var int   lastPeakBar    = na
var float lastTroughOsc  = na
var float lastTroughClose = na
var int   lastTroughBar  = na

int contLookbackRaw = continuationMaxLookback > 0 ? continuationMaxLookback : (halfReady ? int(math.round(cycleAvgLen * 2)) : 40)
int contLookback    = math.max(contLookbackRaw, minCycleLen + 2)

float contSigTh = oscEnvelope * 0.05

bool bullContinuation = barstate.isconfirmed and tierWarm and troughBar and tier <= 1 and not na(lastTroughOsc) and fastOsc[1] < lastTroughOsc and (lastTroughOsc - fastOsc[1]) > contSigTh and close[1] > lastTroughClose and (bar_index - 1 - lastTroughBar) >= minCycleLen and (bar_index - 1 - lastTroughBar) <= contLookback
bool bearContinuation = barstate.isconfirmed and tierWarm and peakBar   and tier >= 2 and not na(lastPeakOsc)   and fastOsc[1] > lastPeakOsc   and (fastOsc[1] - lastPeakOsc)   > contSigTh and close[1] < lastPeakClose   and (bar_index - 1 - lastPeakBar)   >= minCycleLen and (bar_index - 1 - lastPeakBar)   <= contLookback

// Track last continuation bar for the Setup row cascade.
var int lastBullContinuationBar = na
var int lastBearContinuationBar = na
if bullContinuation
    lastBullContinuationBar := bar_index
if bearContinuation
    lastBearContinuationBar := bar_index

// Update the peak/trough trackers AFTER computing continuation so the check
// above always compares CURRENT vs PREVIOUS extreme. Capture from [1] (the
// actual extreme bar) and tier-gate so noise pivots don't seed the reference.
if peakBar and tier >= 2 and barstate.isconfirmed
    lastPeakOsc   := nz(fastOsc[1], fastOsc)
    lastPeakClose := nz(close[1],   close)
    lastPeakBar   := bar_index - 1
if troughBar and tier <= 1 and barstate.isconfirmed
    lastTroughOsc   := nz(fastOsc[1], fastOsc)
    lastTroughClose := nz(close[1],   close)
    lastTroughBar   := bar_index - 1

// ══════════════════════════════════════════════════════════════════════════════
//  VISUALS - dual-line + tier-graded ribbon fill, cross triangles, exhaustion
// ══════════════════════════════════════════════════════════════════════════════
// Lines track the TIER - color changes only on tier transitions. Ribbon fill
// uses the same tier color at higher transparency.
//
// Two marker channels, independent toggles:
//   • Cross - ▲/▼ at the ribbon midpoint on fast/slow cross. showCycleCrosses
//     (plain, 50% alpha) + showConfluenceCrosses (confluence, full color,
//     one size up).
//   • Exhaustion - small transparent circle (plotshape) on the ribbon
//     midpoint at the fire bar, 30% alpha. Color inverted: red = topping,
//     green = supporting. showStretch.
// Colors written as inline-hex ternaries on each plot - Pine's Style-tab
// engine only exposes per-tier pickers when the ternary uses literal hex;
// named const vars collapse the layout to a single picker. Slow line alpha
// 50, ribbon fill alpha 75.
p_fast = plot(fastOsc, "Fast Oscillator", color = tier == 3 ? #00E6B4 : tier == 2 ? #006E55 : tier == 1 ? #8C2D2B : #FF504B, linewidth=2)
p_slow = plot(slowOsc, "Slow Oscillator", color = tier == 3 ? color.new(#00E6B4, 50) : tier == 2 ? color.new(#006E55, 50) : tier == 1 ? color.new(#8C2D2B, 50) : color.new(#FF504B, 50), linewidth=2)
fill(p_fast, p_slow,                      color = tier == 3 ? color.new(#00E6B4, 75) : tier == 2 ? color.new(#006E55, 75) : tier == 1 ? color.new(#8C2D2B, 75) : color.new(#FF504B, 75), title="Tier Ribbon")

bool  bullCross = ta.crossover(fastOsc, slowOsc)
bool  bearCross = ta.crossunder(fastOsc, slowOsc)

// Cross quality gate - two filters layered on top of the raw ta.crossover:
//   1. Half-tier gate: bullCross needs tier ≤ 1 (room to rise), bearCross
//      needs tier ≥ 2 (room to fall). Mid-tier crosses in chop still drive
//      line/ribbon color, just no marker.
//   2. Cross-angle filter (all profiles): the fast-slow gap must be WIDENING
//      past a threshold at the crossover bar. Kills "grazing" crosses where
//      fast kisses slow and reverses. 1.5% of oscEnvelope per bar auto-scales
//      to every asset. Zero signal delay (measured at the cross bar itself).
float crossAngle = (fastOsc - slowOsc) - nz(fastOsc[1] - slowOsc[1])
float crossAngleTh = oscEnvelope * 0.015
bool  bullCrossShow = bullCross and tier <= 1 and tierWarm and barstate.isconfirmed and crossAngle >  crossAngleTh
bool  bearCrossShow = bearCross and tier >= 2 and tierWarm and barstate.isconfirmed and crossAngle < -crossAngleTh

// Reversal Confluence: cross within 0-2 bars of a same-side exhaustion on the
// same tier visit. Renders one size larger (full-color triangle).
bool bullConfluence = bullCrossShow and (lowerStretch or lowerStretch[1] or lowerStretch[2])
bool bearConfluence = bearCrossShow and (upperStretch or upperStretch[1] or upperStretch[2])

// Track most-recent confluence bars for the Setup row + price overlay.
var int lastBullConfluenceBar      = na
var int lastBearConfluenceBar      = na
if bullConfluence
    lastBullConfluenceBar := bar_index
if bearConfluence
    lastBearConfluenceBar := bar_index

// Marker placement offsets - envelope-based so markers clear the ribbon lines
// regardless of oscillator scale.
float crossGap    = oscEnvelope * 0.10
float crossUpY    = math.min(fastOsc, slowOsc) - crossGap
float crossDnY    = math.max(fastOsc, slowOsc) + crossGap
float ribbonMid   = (fastOsc + slowOsc) / 2

// Bull cross BELOW the ribbon pointing up, bear ABOVE pointing down - reads
// natively without parsing the marker color. Plain crosses render at 50%
// alpha (size.tiny); Reversal Confluence at full color (triangles, size.small).
plotshape(showCycleCrosses      and bullCrossShow and not bullConfluence ? crossUpY : na, title="Cycle Turn Up",                  style=shape.triangleup,   location=location.absolute, color=color.new(C_UP_STRONG, 50),   size=size.tiny,  display=display.pane)
plotshape(showCycleCrosses      and bearCrossShow and not bearConfluence ? crossDnY : na, title="Cycle Turn Down",                style=shape.triangledown, location=location.absolute, color=color.new(C_DOWN_STRONG, 50), size=size.tiny,  display=display.pane)
plotshape(showConfluenceCrosses and bullConfluence ? crossUpY : na, title="Cycle Turn Up (Confluence)",     style=shape.triangleup,   location=location.absolute, color=C_UP_STRONG,                  size=size.small, display=display.pane)
plotshape(showConfluenceCrosses and bearConfluence ? crossDnY : na, title="Cycle Turn Down (Confluence)",   style=shape.triangledown, location=location.absolute, color=C_DOWN_STRONG,                size=size.small, display=display.pane)

// Exhaustion color INVERTED: Upper = RED (cooling), Lower = GREEN (support).
// Single small transparent circle on the ribbon midpoint at the fire bar -
// one circle per fire, fixed position on the ribbon, ~30% alpha. Easy on
// the band but clear.
plotshape(showStretch and upperStretch ? ribbonMid : na, title="Upper Exhaustion (Pane)", style=shape.circle, location=location.absolute, color=color.new(C_DOWN_STRONG, 30), size=size.tiny, display=display.pane)
plotshape(showStretch and lowerStretch ? ribbonMid : na, title="Lower Exhaustion (Pane)", style=shape.circle, location=location.absolute, color=color.new(C_UP_STRONG,   30), size=size.tiny, display=display.pane)

// Continuation labels - small GREEN/RED pill with "Bull"/"Bear" text sitting
// OUTSIDE the ribbon. Color matches the single directional channel shared
// with Crosses / Confluence / Exhaustion; direction reads from both the
// word and the color.
//   • Bull → math.min(fastOsc, slowOsc) - oscEnvelope * 0.05, arrow UP -
//     pill body below the ribbon, arrow tip touches the lower edge.
//   • Bear → math.max(fastOsc, slowOsc) + oscEnvelope * 0.05, arrow DOWN -
//     pill body above the ribbon, arrow tip touches the upper edge.
// Using min/max (not just slowOsc / fastOsc) keeps the offset correct
// regardless of which line is on top during the pattern fire. Tones are
// darkened vs. the bright cross/confluence palette (C_UP_MID, C_BEAR_PILL)
// so the pill reads as a structural note, not a directional call-out.
// label.new requires `if` blocks (not ternary like plotshape) and respects
// the max_labels_count=500 cap on the indicator() declaration.
float contBullY = math.min(fastOsc, slowOsc) - oscEnvelope * 0.05
float contBearY = math.max(fastOsc, slowOsc) + oscEnvelope * 0.05
if showContinuation and bullContinuation
    label.new(bar_index, contBullY, "Bull", style=label.style_label_up,   color=C_UP_MID,     textcolor=color.white, size=size.small)
if showContinuation and bearContinuation
    label.new(bar_index, contBearY, "Bear", style=label.style_label_down, color=C_BEAR_PILL,  textcolor=color.white, size=size.small)

// Chart-overlay exhaustion flag: the candle BORDER tints STRONG ORANGE on
// any exhaustion fire (upper or lower). Non-directional - the pane circle
// still shows which side. Body + wick stay native green/red. Bar-chart users
// get the whole bar tinted; accepted because candle charts dominate.
bool exhaustionFire = showPriceMarkers and showStretch and (upperStretch or lowerStretch) and not bullConfluence and not bearConfluence
barcolor(exhaustionFire ? C_EXH_BAR : na, title="Exhaustion Candle Border")

// ══════════════════════════════════════════════════════════════════════════════
//  PRICE-CHART OVERLAY MARKERS
// ══════════════════════════════════════════════════════════════════════════════
// Mirrors the sub-panel hierarchy onto the price chart (plain cross tiny/50%,
// confluence small/full color, exhaustion = candle tint). TV handles the
// above/below-candle offset so markers always sit in the right place
// regardless of bar range.
plotshape(showPriceMarkers and showConfluenceCrosses and bullConfluence, title="Bull Confluence (Chart)", style=shape.triangleup,   location=location.belowbar, color=C_UP_STRONG,                  size=size.small, force_overlay=true, display=display.all - display.status_line, editable=false)
plotshape(showPriceMarkers and showConfluenceCrosses and bearConfluence, title="Bear Confluence (Chart)", style=shape.triangledown, location=location.abovebar, color=C_DOWN_STRONG,                size=size.small, force_overlay=true, display=display.all - display.status_line, editable=false)
plotshape(showPriceMarkers and showCycleCrosses     and bullCrossShow and not bullConfluence, title="Bull Cycle Turn (Chart)", style=shape.triangleup,   location=location.belowbar, color=color.new(C_UP_STRONG, 50),   size=size.tiny,  force_overlay=true, display=display.all - display.status_line, editable=false)
plotshape(showPriceMarkers and showCycleCrosses     and bearCrossShow and not bearConfluence, title="Bear Cycle Turn (Chart)", style=shape.triangledown, location=location.abovebar, color=color.new(C_DOWN_STRONG, 50), size=size.tiny,  force_overlay=true, display=display.all - display.status_line, editable=false)

// ══════════════════════════════════════════════════════════════════════════════
//  INFO PANEL
// ══════════════════════════════════════════════════════════════════════════════
// Row 0: Ehlers Decycler    |  <Tier>
// Row 1: Phase              |  Rising  11 of 14
// Row 2: Exhaustion         |  Top  12b ago
// Row 3:                    Setup  |  Strong bull setup
// Row 4: (Adaptive only)    Cycle  |  80 bars · High
if barstate.islast and showInfoPanel
    string ratioStr  = halfReady ? "  " + str.tostring(phaseDuration) + " of " + str.tostring(halfTypical, "#0") : "  " + str.tostring(phaseDuration) + "b"
    string phaseVal  = phase < 0 ? "-" : (phase == 1 or phase == 3 ? phaseStr : phaseStr + ratioStr)
    string scanRangeStr = " [" + str.tostring(autoMinEff) + "-" + str.tostring(autoMaxEff) + (boundsManual ? " manual" : "") + "]"
    string cycleVal  = acpWarm ? "warming up…" : holdingLowConf ? str.tostring(hpPeriodEff, "#0") + " bars · holding" + scanRangeStr : str.tostring(hpPeriodEff, "#0") + " bars · " + confStr + scanRangeStr
    string stretchVal = na(lastStretchBar) ? "-" : (lastStretchDir == 1 ? "Top" : "Bottom") + "  " + str.tostring(bar_index - lastStretchBar) + "b ago"

    color tblBg     = lightTheme ? color.new(#FAFAFC, 10) : color.new(color.black, 15)
    color tblFrame  = lightTheme ? color.new(#AAAFBE, 30) : color.new(C_GRAY, 30)
    color tblBorder = lightTheme ? color.new(#C8CDD7, 40) : color.new(C_GRAY, 50)
    color titleCol  = lightTheme ? #0F1423 : color.white
    color labelCol  = lightTheme ? #5A5F73 : C_GRAY
    color valueCol  = lightTheme ? #191E2D : color.white

    color tierLightTop    = lightTheme ? #00785A : C_UP_STRONG
    color tierLightBottom = lightTheme ? #A52828 : C_DOWN_STRONG
    color stateWordColor  = tier >= 2 ? tierLightTop : tierLightBottom

    color phaseRisingCol  = lightTheme ? #00785A : C_UP_MID
    color phaseBottomCol  = lightTheme ? #00785A : C_UP_STRONG
    color phaseFallingCol = lightTheme ? #A52828 : C_DOWN_MID
    color phaseWordColor  = phase == 1 ? #FFC850 : phase == 3 ? phaseBottomCol : phase == 0 ? phaseRisingCol : phase == 2 ? phaseFallingCol : labelCol

    // Exhaustion word color matches on-chart inverted convention:
    // dir==1 (Upper / topping pressure) → red; dir==-1 (Lower / support) → green.
    color stretchTopCol  = lightTheme ? #A52828 : C_DOWN_STRONG
    color stretchBotCol  = lightTheme ? #00785A : C_UP_STRONG
    color stretchWordCol = na(lastStretchBar) ? labelCol : (lastStretchDir == 1 ? stretchTopCol : stretchBotCol)

    // Setup row - one-line state synthesis. Combines tier + phase + cycle
    // confidence + recent Reversal Confluence + recent Continuation. tier/phase
    // read from the last CONFIRMED bar so the line doesn't flicker as the live
    // tick crosses a tier boundary. Continuation gets its own state branch
    // ("Bull / Bear continuation forming") instead of being collapsed into the
    // same "Strong setup" label as Reversal Confluence - they're different
    // stories (reversal at the edge vs trend resuming) and the synthesis layer
    // now preserves that distinction.
    int    readTier  = nz(tier[1],  tier)
    int    readPhase = nz(phase[1], phase)
    bool recentBullConf      = not na(lastBullConfluenceBar)      and (bar_index - lastBullConfluenceBar)      <= 3
    bool recentBearConf      = not na(lastBearConfluenceBar)      and (bar_index - lastBearConfluenceBar)      <= 3
    bool recentBullCont      = not na(lastBullContinuationBar)    and (bar_index - lastBullContinuationBar)    <= 3
    bool recentBearCont      = not na(lastBearContinuationBar)    and (bar_index - lastBearContinuationBar)    <= 3
    bool recentUpperExh      = not na(lastStretchBar) and lastStretchDir == 1  and (bar_index - lastStretchBar) <= 3
    bool recentLowerExh      = not na(lastStretchBar) and lastStretchDir == -1 and (bar_index - lastStretchBar) <= 3
    bool acpWeak      = profile == PROF_ADAPT and (acpWarm or holdingLowConf or bestCorr < 0.50)
    string setupVal =
       recentBullConf and readTier <= 1                            ? "Strong bull setup"        :
       recentBearConf and readTier >= 2                            ? "Strong bear setup"        :
       recentBullCont and readTier <= 1                            ? "Bull continuation forming":
       recentBearCont and readTier >= 2                            ? "Bear continuation forming":
       readTier == 3 and (recentUpperExh or readPhase == 1)        ? "Topping"                  :
       readTier == 0 and (recentLowerExh or readPhase == 3)        ? "Bottoming"                :
       readTier >= 2 and readPhase == 0 and not acpWeak            ? "Trend running up"         :
       readTier <= 1 and readPhase == 2 and not acpWeak            ? "Trend running down"       :
       acpWeak and readTier >= 1 and readTier <= 2                 ? "Weak chop"                :
       readTier == 3                                               ? "Stretched up"             :
       readTier == 0                                               ? "Stretched down"           :
       readTier == 2                                               ? "Drift up"                 :
       readTier == 1                                               ? "Drift down"               : "Quiet"
    int setupTone =
       recentBullConf and readTier <= 1                            ?  2 :
       recentBearConf and readTier >= 2                            ? -2 :
       recentBullCont and readTier <= 1                            ?  1 :
       recentBearCont and readTier >= 2                            ? -1 :
       readTier == 3 and (recentUpperExh or readPhase == 1)        ? -1 :
       readTier == 0 and (recentLowerExh or readPhase == 3)        ?  1 :
       readTier >= 2 and readPhase == 0 and not acpWeak            ?  1 :
       readTier <= 1 and readPhase == 2 and not acpWeak            ? -1 :
       readTier == 3 ? -1 : readTier == 0 ?  1 : 0
    color setupWordCol =
       setupTone ==  2 ? (lightTheme ? #00785A : C_UP_STRONG)   :
       setupTone ==  1 ? (lightTheme ? #00785A : C_UP_MID)      :
       setupTone == -2 ? (lightTheme ? #A52828 : C_DOWN_STRONG) :
       setupTone == -1 ? (lightTheme ? #A52828 : C_DOWN_MID)    : labelCol

    bool showCycleRow = profile == PROF_ADAPT
    int  rowCount     = 4 + (showCycleRow ? 1 : 0)

    table infoPanel = table.new(position.top_right, 2, rowCount, bgcolor=tblBg, border_width=1, border_color=tblBorder, frame_width=2, frame_color=tblFrame)

    string tipTitle   = "4-tier percentile grade of the fast oscillator over the rank window.\n\n• Upper Extreme - top 25% (stretched high)\n• Upper - next 25% (above midpoint)\n• Lower - next 25% (below midpoint)\n• Lower Extreme - bottom 25% (stretched low)\n\nLine and ribbon colors track this tier - they change only on tier transitions.\n\nObservational: 'where the swing sits in its own distribution.' Pair with Phase: Tier = how stretched, Phase = where in the cycle."
    string tipPhase   = "Cycle position, rotating Rising → Topping → Falling → Bottoming → repeat.\n\n'X of Y' on Rising/Falling reads as 'bar X of a typical Y-bar leg for this market' - factual history, not forecast. Y = half average cycle over last ≤5 cycles.\n\nNeeds ≥3 completed cycles for the ratio; earlier bars show bare bar count."
    string tipExhaustion = "Last EXHAUSTION fire - oscillator at the edge of its rolling distribution.\n\n• Top (RED) - peaked at upper edge. Pane: red circle on ribbon. Chart: orange candle. Reads as 'cooling at the top,' NOT bullish.\n• Bottom (GREEN) - troughed at lower edge. Pane: green circle. Chart: orange candle. Reads as 'support showing,' NOT bearish.\n\nColor INVERTED by design - exhaustion is distribution-edge, not direction.\n\nAdaptive's gate is stricter (top/bottom 15% + deadband) so exhaustions are fewer but more meaningful.\n\n'Nb ago' = bars since the fire. One per extreme-zone visit; counter runs until re-arm."
    string tipSetup      = "One-line state synthesis - tier + phase + cycle confidence + recent confluence + recent continuation rolled into a single read.\n\nStates (priority highest first):\n • Strong bull / bear setup - recent Reversal Confluence + matching tier\n • Bull / bear continuation forming - recent Continuation + matching tier\n • Topping / Bottoming - extreme tier + same-side exhaustion or phase\n • Trend running up / down - directional phase + tier alignment + usable cycle confidence (Adaptive)\n • Weak chop - Adaptive only: low cycle confidence + mid tiers\n • Stretched up / down - extreme tier without other context\n • Drift up / down - half-tier drift\n • Quiet - no edge\n\nObservational, not a trade directive."
    string tipCycle      = "Dominant cycle period the market is tracking right now - detected via an Autocorrelation Periodogram.\n\nScan range auto-derives from the chart timeframe (shown in brackets, e.g. [14-45]):\n ≤15m → 8-30 · 30m-1H → 14-45 · 2H-12H → 18-55 · Daily+ → 20-60\n\nMin/Max Period Overrides force either bound (0 = no override = auto); '[… manual]' means an override is active.\n\nConfidence:\n • High ≥ 0.75 - strong, clean cycle\n • Medium ≥ 0.50 - usable but choppy\n • Low < 0.50 - no clear cycle right now\n\n'holding' = detector's power dropped below threshold; holding the last confident reading instead of chasing noise.\n\nOnly shown on Adaptive profile."

    table.cell(infoPanel, 0, 0, "Ehlers Decycler", tooltip=tipTitle, text_color=titleCol, text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 0, tierStr,             tooltip=tipTitle, text_color=stateWordColor, text_size=size.large,  text_halign=text.align_right)

    table.cell(infoPanel, 0, 1, "Phase",   tooltip=tipPhase, text_color=labelCol,       text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 1, phaseVal,  tooltip=tipPhase, text_color=phaseWordColor, text_size=size.normal, text_halign=text.align_right)

    table.cell(infoPanel, 0, 2, "Exhaustion", tooltip=tipExhaustion, text_color=labelCol,       text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 2, stretchVal,   tooltip=tipExhaustion, text_color=stretchWordCol, text_size=size.normal, text_halign=text.align_right)

    int rowIdx = 3
    table.cell(infoPanel, 0, rowIdx, "Setup",   tooltip=tipSetup, text_color=labelCol,     text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, rowIdx, setupVal,  tooltip=tipSetup, text_color=setupWordCol, text_size=size.normal, text_halign=text.align_right)
    rowIdx += 1
    if showCycleRow
        table.cell(infoPanel, 0, rowIdx, "Cycle",   tooltip=tipCycle, text_color=labelCol, text_size=size.normal, text_halign=text.align_left)
        table.cell(infoPanel, 1, rowIdx, cycleVal,  tooltip=tipCycle, text_color=valueCol, text_size=size.normal, text_halign=text.align_right)
        rowIdx += 1

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS - 10 total, all bar-close gated
// ══════════════════════════════════════════════════════════════════════════════
// Bull/Bear "Cross" and "Cross Confluence" are mutually exclusive - subscribe
// to one or the other per side, no duplicate fires. Each message ends with a
// structured payload tail {ticker, price, tf, time} so webhook consumers can
// parse without rewriting the message.
alertcondition(upperStretch,                                                                       "Upper Exhaustion",      "Upper Exhaustion - oscillator peaked at the upper extreme of its rolling window. {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(lowerStretch,                                                                       "Lower Exhaustion",      "Lower Exhaustion - oscillator troughed at the lower extreme of its rolling window. {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(barstate.isconfirmed and phase == 1 and nz(phase[1], phase) == 0,                   "Topping",               "Topping - cycle turned Rising to Topping. {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(barstate.isconfirmed and phase == 3 and nz(phase[1], phase) == 2,                   "Bottoming",             "Bottoming - cycle turned Falling to Bottoming. {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(bullCrossShow and not bullConfluence,                                               "Bull Cross",            "Bull Cross - fast crossed above slow in the lower half (tier at or below Lower). {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(bullConfluence,                                                                     "Bull Cross Confluence", "Bull Cross Confluence - fast crossed above slow within 2 bars of a Lower Exhaustion. {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(bearCrossShow and not bearConfluence,                                               "Bear Cross",            "Bear Cross - fast crossed below slow in the upper half (tier at or above Upper). {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(bearConfluence,                                                                     "Bear Cross Confluence", "Bear Cross Confluence - fast crossed below slow within 2 bars of an Upper Exhaustion. {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(bullContinuation,                                                                   "Bull Continuation",     "Bull Continuation - oscillator made a lower trough while close made a higher close. {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
alertcondition(bearContinuation,                                                                   "Bear Continuation",     "Bear Continuation - oscillator made a higher peak while close made a lower close. {ticker={{ticker}}, price={{close}}, tf={{interval}}, time={{time}}}")
````
