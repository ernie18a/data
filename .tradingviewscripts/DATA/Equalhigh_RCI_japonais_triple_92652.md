<!-- tradingview-pine-id: PUB;9b883d55a124442db28b8e9f8a673213 -->
<!-- tradingviewscripts-format: 1 -->
# Equalhigh — RCI japonais triple 9/26/52

Source: https://www.tradingview.com/script/MIHyV9zr-Equalhigh-JAPANESE-TRIPLE-RCI/

## Description

EQUALHIGH — JAPANESE TRIPLE RCI 9/26/52

OVERVIEW

This indicator implements the triple Rank Correlation Index configuration commonly used in Japanese technical analysis.

It combines three RCI horizons:

• RCI 9 — short-term momentum
• RCI 26 — swing direction
• RCI 52 — underlying trend

Unlike RSI, RCI does not primarily measure the magnitude of price changes. It measures how closely the chronological order of the bars corresponds to the ranked order of their prices.

The indicator is designed to identify:

• Progressive market reversals
• Momentum recoveries after pullbacks
• Bullish or bearish multi-horizon alignment
• Trend deterioration
• Choppy and conflicting market conditions

CALCULATION

RCI is based on Spearman’s rank correlation between:

1. The chronological rank of each bar
2. The price rank of each bar

The result is scaled from −100 to +100.

• +100 indicates a perfectly ordered upward movement.
• −100 indicates a perfectly ordered downward movement.
• Values near zero indicate weak directional organization or conflicting price action.

This implementation calculates the full Spearman rank correlation and assigns an average rank to tied prices.

INDICATOR LINES

CYAN — RCI 9: SHORT-TERM IMPULSE

RCI 9 reacts quickly to changes in momentum. It is useful for detecting early rebounds, short-term exhaustion and the first phase of a possible reversal.

ORANGE — RCI 26: SWING DIRECTION

RCI 26 confirms whether the short-term movement is developing into a more meaningful swing.

PURPLE — RCI 52: UNDERLYING TREND

RCI 52 is the slowest component. It represents the broader directional structure and acts as the main trend filter.

KEY LEVELS

+80: Upper extreme zone
+50: Strong positive momentum
0: Directional equilibrium
−50: Strong negative momentum
−80: Lower extreme zone

An extreme RCI reading does not automatically mean that price must reverse. A strong trend can keep the RCI near +80 or −80 for an extended period.

SIGNALS

R+ — EARLY BULLISH REVERSAL

An R+ signal appears when:

• RCI 9 crosses upward out of the lower extreme zone
• RCI 26 is already rising

This identifies an early improvement in price organization. It is not a complete trend confirmation and should ideally be supported by price action, volume or a support level.

R− — EARLY BEARISH REVERSAL

An R− signal appears when:

• RCI 9 crosses downward out of the upper extreme zone
• RCI 26 is already falling

This indicates early deterioration in short-term momentum.

A+ — NEW BULLISH ALIGNMENT

An A+ signal appears when RCI 9, RCI 26 and RCI 52 become positive simultaneously.

This confirms that short-term momentum, the swing structure and the underlying trend are all on the bullish side of equilibrium.

A− — NEW BEARISH ALIGNMENT

An A− signal appears when all three RCI horizons become negative simultaneously.

This confirms bearish alignment across the three observed time horizons.

PRACTICAL INTERPRETATION

STRONG BULLISH REGIME

• RCI 52 is above zero
• RCI 26 is above zero or recovering
• RCI 9 moves out of a temporary pullback
• An R+ or A+ signal is supported by bullish price action

STRONG BEARISH REGIME

• RCI 52 is below zero
• RCI 26 is below zero or deteriorating
• RCI 9 turns down after a temporary recovery
• An R− or A− signal is supported by bearish price action

POSSIBLE PROGRESSIVE REVERSAL

A bullish reversal often develops in stages:

1. RCI 9 turns upward
2. RCI 26 begins to recover
3. RCI 52 stabilizes or turns upward
4. All three RCIs eventually move above zero

The bearish sequence is the opposite.

CHOPPY OR LOW-CONVICTION MARKET

When the three lines repeatedly cross each other around zero, the market lacks a stable directional structure. Trend-following signals are generally less reliable in this environment.

SUGGESTED WORKFLOW FOR SWING TRADING

For a potential long setup:

1. Confirm that price is near support or breaking above resistance.
2. Look for an R+ early reversal signal.
3. Check that RCI 26 is rising.
4. Prefer situations where RCI 52 is positive, stabilizing or improving.
5. Use A+ as stronger multi-horizon confirmation.
6. Define risk with price structure or an ATR-based stop.

For a potential short setup, apply the opposite conditions.

DEFAULT SETTINGS

• Short RCI: 9
• Medium RCI: 26
• Long RCI: 52
• Source: Close
• Extreme level: 80
• Reversal trigger: 80
• Signal confirmation: Bar close

The default 9/26/52 configuration is suitable for swing analysis on daily and four-hour charts. Because the periods represent bars, their actual duration changes with the selected timeframe.

USER SETTINGS

RCI Short

Controls the sensitivity of short-term momentum. A lower value reacts faster but produces more noise.

RCI Medium

Represents the intermediate swing structure.

RCI Long

Acts as the broader trend filter. Higher values provide a slower and more stable reading.

Extreme Level

Defines the upper and lower visual zones. The default setting is +80 and −80.

Reversal Trigger

Determines the level used to generate early R+ and R− reversal signals.

Confirm Only at Bar Close

When enabled, signals are validated only after the current candle closes. This helps prevent temporary intrabar signals.

Show Early Reversals

Displays the R+ and R− markers.

Show 9/26/52 Alignments

Displays the A+ and A− markers.

Shade Extreme Zones

Highlights the upper and lower RCI extreme areas.

Shade Background by Alignment

Optionally colors the indicator background according to bullish or bearish triple alignment.

ALERTS

Four TradingView alert conditions are included:

• RCI — Early Bullish Reversal
• RCI — Early Bearish Reversal
• RCI — New Bullish Alignment
• RCI — New Bearish Alignment

For more stable signals, alerts should normally be configured “Once Per Bar Close.”

REPAINTING BEHAVIOR

The indicator uses only current and historical price data. It does not use future bars.

RCI values can naturally change while the current candle is still forming. When “Confirm Only at Bar Close” is enabled, signal markers and alerts are confirmed at the candle close and do not subsequently repaint on completed bars.

LIMITATIONS

RCI is a market-structure and momentum indicator, not a standalone trading system.

It does not account for:

• Fundamental valuation
• Earnings announcements
• Liquidity conditions
• Volatility regime changes
• Support and resistance
• Position sizing
• Transaction costs

Extreme readings should not automatically be interpreted as buy or sell signals. The indicator is most effective when combined with price structure, volume, volatility and disciplined risk management.

DISCLAIMER

This indicator is provided for educational and analytical purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. Past performance does not guarantee future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stevesyl

//@version=6
indicator(
     "Equalhigh — RCI japonais triple 9/26/52",
     shorttitle = "RCI Japonais 9/26/52",
     overlay = false,
     precision = 1
)

// ═════════════════════════════════════════════════════════════════════════════
// 1. PARAMÈTRES
// ═════════════════════════════════════════════════════════════════════════════

groupPeriods = "1. Périodes RCI"
shortLength = input.int(9, "RCI court", minval = 2, maxval = 100, group = groupPeriods)
mediumLength = input.int(26, "RCI intermédiaire", minval = 2, maxval = 150, group = groupPeriods)
longLength = input.int(52, "RCI long", minval = 2, maxval = 250, group = groupPeriods)
source = input.source(close, "Source", group = groupPeriods)

groupLevels = "2. Niveaux"
extremeLevel = input.float(80.0, "Niveau extrême", minval = 50.0, maxval = 99.0, step = 1.0, group = groupLevels)
reversalLevel = input.float(80.0, "Déclencheur de retournement", minval = 50.0, maxval = 99.0, step = 1.0, group = groupLevels)

groupSignals = "3. Signaux"
showReversals = input.bool(true, "Afficher les retournements précoces", group = groupSignals)
showAlignments = input.bool(true, "Afficher les alignements 9/26/52", group = groupSignals)
confirmAtClose = input.bool(true, "Confirmer uniquement à la clôture", group = groupSignals)

groupDisplay = "4. Affichage"
shadeExtremeZones = input.bool(true, "Colorer les zones extrêmes", group = groupDisplay)
shadeAlignedRegime = input.bool(false, "Colorer le fond selon l'alignement", group = groupDisplay)

// ═════════════════════════════════════════════════════════════════════════════
// 2. RCI — CORRÉLATION DE RANG DE SPEARMAN
// ═════════════════════════════════════════════════════════════════════════════

// Le rang temporel va de 1 (plus ancienne observation) à N (plus récente).
// Le rang du prix va de 1 (prix le plus bas) à N (prix le plus haut).
// Les ex aequo reçoivent leur rang moyen. Une hausse parfaitement régulière
// donne +100 ; une baisse parfaitement régulière donne -100.
f_rci(float src, int length) =>
    float result = na

    if not na(src[length - 1])
        float meanRank = (length + 1.0) / 2.0
        float covariance = 0.0
        float timeVariance = 0.0
        float priceVariance = 0.0

        for i = 0 to length - 1
            float priceRank = 1.0
            float tiedPrices = 0.0

            for j = 0 to length - 1
                if src[j] < src[i]
                    priceRank += 1.0
                else if src[j] == src[i] and j != i
                    tiedPrices += 1.0

            priceRank += tiedPrices / 2.0

            float timeRank = length - i
            float timeDeviation = timeRank - meanRank
            float priceDeviation = priceRank - meanRank

            covariance += timeDeviation * priceDeviation
            timeVariance += timeDeviation * timeDeviation
            priceVariance += priceDeviation * priceDeviation

        float denominator = math.sqrt(timeVariance * priceVariance)
        result := denominator > 0.0 ? 100.0 * covariance / denominator : 0.0

    result

rciShort = f_rci(source, shortLength)
rciMedium = f_rci(source, mediumLength)
rciLong = f_rci(source, longLength)

// ═════════════════════════════════════════════════════════════════════════════
// 3. LECTURE DE RÉGIME ET SIGNAUX
// ═════════════════════════════════════════════════════════════════════════════

barConfirmed = not confirmAtClose or barstate.isconfirmed

// Retournement progressif : le RCI court quitte une zone extrême et le RCI
// intermédiaire évolue déjà dans le même sens.
earlyBullishReversal = barConfirmed and ta.crossover(rciShort, -reversalLevel) and rciMedium > rciMedium[1]
earlyBearishReversal = barConfirmed and ta.crossunder(rciShort, reversalLevel) and rciMedium < rciMedium[1]

// Alignement complet : les trois horizons sont du même côté de zéro.
bullishAlignment = rciShort > 0.0 and rciMedium > 0.0 and rciLong > 0.0
bearishAlignment = rciShort < 0.0 and rciMedium < 0.0 and rciLong < 0.0

newBullishAlignment = barConfirmed and bullishAlignment and not bullishAlignment[1]
newBearishAlignment = barConfirmed and bearishAlignment and not bearishAlignment[1]

// ═════════════════════════════════════════════════════════════════════════════
// 4. AFFICHAGE
// ═════════════════════════════════════════════════════════════════════════════

upperExtreme = hline(extremeLevel, "+80 — excès haussier", color = color.new(color.red, 25), linestyle = hline.style_dashed)
upperMid = hline(50.0, "+50", color = color.new(color.gray, 75), linestyle = hline.style_dotted)
zeroLine = hline(0.0, "Équilibre", color = color.new(color.gray, 35))
lowerMid = hline(-50.0, "-50", color = color.new(color.gray, 75), linestyle = hline.style_dotted)
lowerExtreme = hline(-extremeLevel, "-80 — excès baissier", color = color.new(color.lime, 25), linestyle = hline.style_dashed)

invisibleTop = hline(100.0, "Maximum", color = color.new(color.white, 100), display = display.none)
invisibleBottom = hline(-100.0, "Minimum", color = color.new(color.white, 100), display = display.none)

fill(invisibleTop, upperExtreme, color = shadeExtremeZones ? color.new(color.red, 91) : na, title = "Zone haute")
fill(lowerExtreme, invisibleBottom, color = shadeExtremeZones ? color.new(color.lime, 91) : na, title = "Zone basse")

plot(rciShort, "RCI 9 — impulsion", color = color.rgb(0, 188, 212), linewidth = 2)
plot(rciMedium, "RCI 26 — swing", color = color.rgb(255, 152, 0), linewidth = 2)
plot(rciLong, "RCI 52 — tendance", color = color.rgb(156, 39, 176), linewidth = 3)

plotshape(
     showReversals and earlyBullishReversal,
     title = "Retournement haussier précoce",
     style = shape.triangleup,
     location = location.bottom,
     color = color.lime,
     size = size.tiny,
     text = "R+"
)

plotshape(
     showReversals and earlyBearishReversal,
     title = "Retournement baissier précoce",
     style = shape.triangledown,
     location = location.top,
     color = color.red,
     size = size.tiny,
     text = "R−"
)

plotshape(
     showAlignments and newBullishAlignment,
     title = "Nouvel alignement haussier",
     style = shape.circle,
     location = location.bottom,
     color = color.green,
     size = size.tiny,
     text = "A+"
)

plotshape(
     showAlignments and newBearishAlignment,
     title = "Nouvel alignement baissier",
     style = shape.circle,
     location = location.top,
     color = color.maroon,
     size = size.tiny,
     text = "A−"
)

regimeColor = bullishAlignment ? color.new(color.green, 91) : bearishAlignment ? color.new(color.red, 91) : na
bgcolor(shadeAlignedRegime ? regimeColor : na, title = "Régime RCI")

// ═════════════════════════════════════════════════════════════════════════════
// 5. ALERTES TRADINGVIEW
// ═════════════════════════════════════════════════════════════════════════════

alertcondition(earlyBullishReversal, "RCI — retournement haussier précoce", "RCI 9 quitte la zone basse et RCI 26 remonte sur {{ticker}} ({{interval}}).")
alertcondition(earlyBearishReversal, "RCI — retournement baissier précoce", "RCI 9 quitte la zone haute et RCI 26 baisse sur {{ticker}} ({{interval}}).")
alertcondition(newBullishAlignment, "RCI — nouvel alignement haussier", "Les RCI 9/26/52 passent en alignement haussier sur {{ticker}} ({{interval}}).")
alertcondition(newBearishAlignment, "RCI — nouvel alignement baissier", "Les RCI 9/26/52 passent en alignement baissier sur {{ticker}} ({{interval}}).")
````
