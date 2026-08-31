<!-- tradingview-pine-id: PUB;bee6c8ea85d44ee5a50fca4e4a602601 -->
<!-- tradingviewscripts-format: 1 -->
# Equalhigh — Stochastic Dominance Aurora v1

Source: https://www.tradingview.com/script/Z9obCJul-Equalhigh-Stochastic-Dominance-Aurora/

## Description

EQUALHIGH — STOCHASTIC DOMINANCE AURORA

OVERVIEW

Stochastic Dominance Aurora is a relative-strength regime indicator designed to identify when an asset begins to outperform a benchmark in a broad, persistent and progressively ordered manner.

Instead of relying on moving-average crossovers or overbought/oversold levels, Aurora compares the distributions of benchmark-relative returns across four consecutive time blocks.

Its purpose is to answer one practical question:

Is the asset developing genuine relative leadership, or is its recent outperformance driven by only a few exceptional bars?

The indicator is primarily designed for weekly stock analysis, although it can be used on other timeframes with appropriate settings.

HOW IT WORKS

Aurora first calculates the logarithmic return of the asset and subtracts the logarithmic return of the selected benchmark:

Relative Return = Asset Return − Benchmark Return

The observation window is then divided into four consecutive blocks:

• Block 1: oldest period
• Block 2: second period
• Block 3: third period
• Block 4: most recent period

The indicator uses a rank-based Jonckheere–Terpstra approach to determine whether the distribution of relative returns is progressively improving from the oldest block to the newest one.

Every observation in a newer block is compared with every observation in the preceding blocks. The resulting statistic is standardized into a Z-score and transformed into the Aurora Dominance line.

This rank-based method reduces the influence of isolated gaps and extreme price movements.

AURORA DOMINANCE LINE

The main line is normalized approximately between −100 and +100.

• Positive values indicate an improving relative-return structure.
• Negative values indicate a deteriorating relative-return structure.
• Values near zero indicate that no clear ordered regime has been detected.
• Values above +50 generally represent strong positive dominance.
• Values below −50 generally represent strong negative dominance.

The line measures relative structure, not absolute price direction. A stock may rise while Aurora deteriorates if the benchmark rises faster.

AURORA STATES

DORMANT — Violet

No statistically meaningful relative-return structure is present.

This is a neutral condition and does not automatically indicate weakness.

WATCH — Turquoise

The first signs of ordered relative improvement are appearing, but the evidence remains insufficient for confirmation.

This state can be used to add the asset to a watchlist.

ARMED — Cyan

The relative-return distributions are becoming meaningfully ordered and the asset is outperforming its benchmark.

The setup is developing, but one or more confirmation conditions may still be missing.

CONFIRMED — Blue

A statistically significant positive relative regime has been detected.

Confirmation requires:

• Z-score at or above the Confirmed threshold
• Positive relative momentum
• Sufficient path efficiency
• Rising Dominance score when acceleration is required
• A completed chart bar

This is the primary bullish confirmation state.

MATURE — Gold

The positive ordering has reached an exceptionally high statistical level.

Mature indicates strong relative leadership, but it may also mean that the move is already advanced. It is not automatically a new-entry signal.

FADING — Orange

The relative-return structure is deteriorating, although a complete bearish breakdown has not yet been confirmed.

This state suggests that relative leadership is weakening.

BREAKDOWN — Red

A statistically significant negative relative regime has been detected.

This condition requires negative relative momentum, sufficient path efficiency and a sufficiently negative Z-score.

SIGNAL MARKERS

BLUE “A” MARKER

A blue “A” marker appears when bullish confirmation becomes newly active on a confirmed bar.

The signal requires:

• Z-score at or above the Confirmed threshold
• Positive relative strength
• Efficiency at or above the selected minimum
• Score acceleration when enabled
• Bar-close confirmation

The marker is intended to identify the beginning of a confirmed relative-leadership regime. It is not an automatic buy signal.

RED “A” MARKER

A red “A” marker appears when bearish confirmation becomes newly active on a confirmed bar.

It identifies a new statistically ordered period of benchmark-relative deterioration.

DASHBOARD

DOMINANCE

The normalized Aurora reading displayed approximately between −100 and +100.

Z-SCORE

The standardized statistical strength of the ordered relative-return structure.

Default interpretation:

• Below 0.35: no meaningful positive structure
• 0.35 to 1.15: Watch
• 1.15 to 1.65: Armed
• 1.65 or higher: potential bullish confirmation
• 2.50 or higher: Mature positive structure
• −1.65 or lower: potential bearish breakdown

The Z-score alone does not generate confirmation. Relative momentum, efficiency and acceleration filters must also be satisfied.

RELATIVE STRENGTH

The asset’s percentage performance relative to the selected benchmark over the chosen lookback period.

• Positive: the asset outperformed the benchmark.
• Negative: the asset underperformed the benchmark.

EFFICIENCY

Efficiency measures how directly the relative-price curve travelled from its starting point to its current point.

Efficiency = Net Relative Movement ÷ Total Relative Path

A high value indicates a clean and directional relative move. A low value indicates a noisy or erratic path.

DEFAULT SETTINGS

The default configuration is designed for weekly charts:

• Block Length: 13
• Total statistical window: approximately 52 weeks
• Armed Z-score: 1.15
• Confirmed Z-score: 1.65
• Mature Z-score: 2.50
• Relative-Strength Lookback: 13
• Efficiency Lookback: 13
• Minimum Efficiency: 0.20
• Require Score Acceleration: Enabled

Four blocks of 13 weekly bars represent approximately one year of market history.

BENCHMARK SELECTION

Benchmark selection has a major influence on the results.

Suggested examples:

• Broad US equities: AMEX:SPY
• Nasdaq and growth stocks: NASDAQ:QQQ
• US small-cap stocks: AMEX:IWM
• Sector analysis: relevant sector ETF
• European equities: a broad European index or ETF supported by the data provider

The benchmark should represent the asset’s realistic opportunity set. Avoid comparing securities from unrelated markets or investment styles unless that comparison is intentional.

SENSITIVITY PROFILES

EARLY PROFILE

• Block Length: 10
• Confirmed Z-score: 1.45
• Minimum Efficiency: 0.15

This configuration produces earlier signals but increases the risk of false positives.

BALANCED PROFILE

• Block Length: 13
• Confirmed Z-score: 1.65
• Minimum Efficiency: 0.20

This is the recommended starting configuration.

SELECTIVE PROFILE

• Block Length: 13
• Confirmed Z-score: 1.96
• Minimum Efficiency: 0.25

This configuration produces fewer and generally stronger signals.

LONG-TERM PROFILE

• Block Length: 20
• Confirmed Z-score: 1.96
• Minimum Efficiency: 0.25

This configuration is slower and better suited to long-term trend confirmation.

PRACTICAL WORKFLOW

Aurora is best used as part of a complete investment process:

1. Confirm that company fundamentals are stable or improving.
2. Verify that valuation still provides an acceptable risk/reward profile.
3. Look for a Watch → Armed → Confirmed progression.
4. Check the price structure and nearby resistance levels.
5. Define the condition that would invalidate the investment thesis.

The strongest setup generally combines:

Improving fundamentals + acceptable valuation + positive relative strength + first blue Aurora confirmation

Aurora is designed to help determine when market recognition may be beginning. It does not determine whether the company is fundamentally undervalued.

ALERTS

Three alert conditions are included:

• Aurora — First Bullish Confirmation
• Aurora — First Bearish Confirmation
• Aurora — Mature Trend

For reliable notifications, configure TradingView alerts using:

Once Per Bar Close

NON-REPAINTING DESIGN

The script uses:

• No future pivots
• No negative plotting offsets
• No lookahead benchmark data
• No future-bar confirmation
• Signal markers confirmed only at bar close

Values may naturally evolve while the current realtime bar is still open. The blue and red markers are validated only after the bar closes.

LIMITATIONS

Aurora does not:

• Calculate fair value
• Analyse financial statements
• Predict earnings surprises
• Guarantee future outperformance
• Replace risk management
• Provide automatic buy or sell recommendations

The indicator may react late after a sudden price gap and may be less reliable on illiquid securities. Results also depend on the selected benchmark, timeframe and parameter configuration.

Aurora should therefore be used as a relative-regime confirmation tool rather than as a standalone trading system.

DISCLAIMER

This indicator is provided for educational and analytical purposes only. It does not constitute financial advice, investment advice or a recommendation to buy or sell any financial instrument. Past statistical relationships do not guarantee future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stevesyl

//@version=6
indicator("Equalhigh — Stochastic Dominance Aurora v1", shorttitle="EH Aurora", overlay=false, max_bars_back=500)

// ═════════════════════════════════════════════════════════════════════════════
// 1. RÉGLAGES
// ═════════════════════════════════════════════════════════════════════════════
groupModel = "1. Moteur de domination"
benchmark  = input.symbol("AMEX:SPY", "Benchmark", group=groupModel)
blockLen   = input.int(13, "Longueur d'un bloc", minval=5, maxval=40, group=groupModel,
     tooltip="Quatre blocs successifs sont comparés. 13 sur un graphique hebdomadaire = 52 semaines.")
zArmed     = input.float(1.15, "Seuil Armed (Z)", minval=0.25, step=0.05, group=groupModel)
zConfirm   = input.float(1.65, "Seuil Confirmed (Z)", minval=0.50, step=0.05, group=groupModel)
zMature    = input.float(2.50, "Seuil Mature (Z)", minval=1.00, step=0.05, group=groupModel)

groupFilter = "2. Filtres du signal"
relLookback = input.int(13, "Période de force relative", minval=3, maxval=52, group=groupFilter)
effLookback = input.int(13, "Période d'efficacité", minval=3, maxval=52, group=groupFilter)
minEff      = input.float(0.20, "Efficacité minimale", minval=0.00, maxval=1.00, step=0.05, group=groupFilter)
needAccel   = input.bool(true, "Exiger une accélération du score", group=groupFilter)

groupVisual = "3. Apparence"
showRibbon  = input.bool(true, "Afficher l'aurore", group=groupVisual)
showSignals = input.bool(true, "Afficher les premiers points", group=groupVisual)
showTable   = input.bool(true, "Afficher le tableau", group=groupVisual)
tablePos    = input.string("Haut droite", "Position du tableau",
     options=["Haut gauche", "Haut centre", "Haut droite", "Milieu gauche", "Milieu droite", "Bas gauche", "Bas centre", "Bas droite"], group=groupVisual)

// ═════════════════════════════════════════════════════════════════════════════
// 2. DONNÉES RELATIVES — aucun lookahead
// ═════════════════════════════════════════════════════════════════════════════
benchClose = request.security(benchmark, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
assetRet   = math.log(close / close[1])
benchRet   = math.log(benchClose / benchClose[1])
relRet     = assetRet - benchRet
relCurve   = math.log(close / benchClose)

// Jonckheere–Terpstra : compte combien d'observations d'un bloc récent sont
// supérieures à celles d'un bloc ancien. 0,5 est attribué aux égalités.
f_pair_score(int oldStart, int newStart, int len) =>
    float u = 0.0
    for i = 0 to len - 1
        float oldValue = relRet[oldStart + i]
        for j = 0 to len - 1
            float newValue = relRet[newStart + j]
            u += newValue > oldValue ? 1.0 : newValue == oldValue ? 0.5 : 0.0
    u

int requiredBars = blockLen * 4 + 1
bool enoughData = bar_index >= requiredBars and not na(relRet[blockLen * 4 - 1])

// Bloc 1 = plus ancien ; bloc 4 = plus récent.
float jt = na
float jtMean = na
float jtVariance = na
float zScore = na

if enoughData
    int b4 = 0
    int b3 = blockLen
    int b2 = blockLen * 2
    int b1 = blockLen * 3
    jt := f_pair_score(b1, b2, blockLen) + f_pair_score(b1, b3, blockLen) + f_pair_score(b1, b4, blockLen) +
          f_pair_score(b2, b3, blockLen) + f_pair_score(b2, b4, blockLen) + f_pair_score(b3, b4, blockLen)

    float n = blockLen * 4.0
    float sumN2 = 4.0 * blockLen * blockLen
    float sumTerm = 4.0 * blockLen * blockLen * (2.0 * blockLen + 3.0)
    jtMean := (n * n - sumN2) / 4.0
    jtVariance := (n * n * (2.0 * n + 3.0) - sumTerm) / 72.0
    zScore := (jt - jtMean) / math.sqrt(jtVariance)

// Compression douce : un score lisible de -100 à +100 sans écraser la zone utile.
f_tanh(float x) =>
    float e = math.exp(math.min(20.0, math.max(-20.0, 2.0 * x)))
    (e - 1.0) / (e + 1.0)

float dominance = na(zScore) ? na : 100.0 * f_tanh(zScore / 3.0)
float relMomentum = enoughData ? 100.0 * (math.exp(relCurve - relCurve[relLookback]) - 1.0) : na
float path = math.sum(math.abs(ta.change(relCurve)), effLookback)
float efficiency = path > 0 ? math.abs(relCurve - relCurve[effLookback]) / path : 0.0
bool acceleratingUp = dominance > dominance[1]
bool acceleratingDn = dominance < dominance[1]

// ═════════════════════════════════════════════════════════════════════════════
// 3. MACHINE D'ÉTATS
// ═════════════════════════════════════════════════════════════════════════════
bool bullConfirmed = enoughData and zScore >= zConfirm and relMomentum > 0 and efficiency >= minEff and (not needAccel or acceleratingUp)
bool bearConfirmed = enoughData and zScore <= -zConfirm and relMomentum < 0 and efficiency >= minEff and (not needAccel or acceleratingDn)

int state = 0
string stateName = "Dormant"
color stateColor = color.rgb(126, 87, 194)

if enoughData
    if zScore >= zMature and relMomentum > 0
        state := 4
        stateName := "Mature"
        stateColor := color.rgb(255, 193, 7)
    else if bullConfirmed
        state := 3
        stateName := "Confirmed"
        stateColor := color.rgb(0, 174, 255)
    else if zScore >= zArmed and relMomentum > 0
        state := 2
        stateName := "Armed"
        stateColor := color.rgb(0, 229, 255)
    else if zScore > 0.35
        state := 1
        stateName := "Watch"
        stateColor := color.rgb(72, 255, 199)
    else if zScore <= -zConfirm and relMomentum < 0
        state := -3
        stateName := "Breakdown"
        stateColor := color.rgb(255, 61, 87)
    else if zScore < -0.35
        state := -1
        stateName := "Fading"
        stateColor := color.rgb(255, 132, 53)

bool firstBlue = barstate.isconfirmed and bullConfirmed and not bullConfirmed[1]
bool firstRed  = barstate.isconfirmed and bearConfirmed and not bearConfirmed[1]

// ═════════════════════════════════════════════════════════════════════════════
// 4. AURORE VISUELLE
// ═════════════════════════════════════════════════════════════════════════════
hline(0, "Équilibre", color=color.new(color.silver, 72))
hline(50, "Domination +", color=color.new(color.aqua, 88))
hline(-50, "Domination -", color=color.new(color.red, 88))

float glowWide = showRibbon ? dominance : na
float glowMid  = showRibbon ? dominance : na
float core     = dominance

pWide = plot(glowWide, "Halo large", color=color.new(stateColor, 88), linewidth=4)
pMid  = plot(glowMid, "Halo moyen", color=color.new(stateColor, 70), linewidth=3)
pCore = plot(core, "Stochastic Dominance", color=stateColor, linewidth=3)

// Rubans de seuil : ils forment le fond discret de l'aurore.
pTop = plot(showRibbon ? 85 : na, "Plafond Aurora", display=display.none)
pZero = plot(showRibbon ? 0 : na, "Centre Aurora", display=display.none)
pBot = plot(showRibbon ? -85 : na, "Plancher Aurora", display=display.none)
fill(pTop, pZero, color=showRibbon ? color.new(color.rgb(0, 174, 255), 94) : na, title="Aurore haussière")
fill(pZero, pBot, color=showRibbon ? color.new(color.rgb(255, 61, 87), 95) : na, title="Aurore baissière")

plotshape(showSignals and firstBlue ? dominance : na, title="Premier point bleu", style=shape.circle,
     location=location.absolute, color=color.rgb(0, 174, 255), size=size.small, text="A", textcolor=color.white)
plotshape(showSignals and firstRed ? dominance : na, title="Premier point rouge", style=shape.circle,
     location=location.absolute, color=color.rgb(255, 61, 87), size=size.small, text="A", textcolor=color.white)

// ═════════════════════════════════════════════════════════════════════════════
// 5. TABLEAU ET ALERTES
// ═════════════════════════════════════════════════════════════════════════════
f_position(string p) =>
    switch p
        "Haut gauche"    => position.top_left
        "Haut centre"    => position.top_center
        "Milieu gauche"  => position.middle_left
        "Milieu droite"  => position.middle_right
        "Bas gauche"     => position.bottom_left
        "Bas centre"     => position.bottom_center
        "Bas droite"     => position.bottom_right
        => position.top_right

var table dash = table.new(f_position(tablePos), 2, 5, bgcolor=color.new(color.rgb(12, 16, 28), 12), frame_color=color.new(color.white, 82), frame_width=1)

if barstate.islast and showTable
    table.cell(dash, 0, 0, "AURORA", text_color=color.white, bgcolor=color.new(stateColor, 40), text_size=size.small)
    table.cell(dash, 1, 0, stateName, text_color=color.white, bgcolor=color.new(stateColor, 40), text_size=size.small)
    table.cell(dash, 0, 1, "Dominance", text_color=color.silver)
    table.cell(dash, 1, 1, na(dominance) ? "—" : str.tostring(dominance, "#.0"), text_color=stateColor)
    table.cell(dash, 0, 2, "Z-score", text_color=color.silver)
    table.cell(dash, 1, 2, na(zScore) ? "—" : str.tostring(zScore, "#.00"), text_color=color.white)
    table.cell(dash, 0, 3, "Force relative", text_color=color.silver)
    table.cell(dash, 1, 3, na(relMomentum) ? "—" : (relMomentum >= 0 ? "+" : "") + str.tostring(relMomentum, "#.00") + "%", text_color=relMomentum >= 0 ? color.aqua : color.rgb(255, 107, 129))
    table.cell(dash, 0, 4, "Efficacité", text_color=color.silver)
    table.cell(dash, 1, 4, str.tostring(efficiency * 100.0, "#.0") + "%", text_color=efficiency >= minEff ? color.rgb(72, 255, 199) : color.orange)

if barstate.islast and not showTable
    table.clear(dash, 0, 0, 1, 4)

alertcondition(firstBlue, "Aurora — première confirmation haussière", "{{ticker}} : domination stochastique haussière confirmée à la clôture.")
alertcondition(firstRed, "Aurora — première confirmation baissière", "{{ticker}} : domination stochastique baissière confirmée à la clôture.")
alertcondition(barstate.isconfirmed and state == 4 and state[1] != 4, "Aurora — tendance mature", "{{ticker}} : l'Aurora entre en phase Mature.")

// Fenêtre Données : valeurs utiles sans surcharger le panneau.
plot(zScore, "Z-score JT", display=display.data_window)
plot(relMomentum, "Force relative (%)", display=display.data_window)
plot(efficiency * 100.0, "Efficacité (%)", display=display.data_window)
````
