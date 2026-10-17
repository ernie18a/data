# Compression Expansion Map [Pineify]

- url: https://www.tradingview.com/script/r8QyGYGD-Compression-Expansion-Map-Pineify/
- type: indicator
- pine_id: PUB;29f1865a74ae4ccaadb57dcf1222e220
- version: 1.0

## Description

[b]Compression Expansion Map [Pineify][/b]

[b]Overview[/b]
Compression Expansion Map [Pineify] is a Pine Script v6 volatility lifecycle oscillator. It converts Bollinger and Keltner widths into comparable compression depths, records joint dwell, and confirms release with rising ATR.

[b]Problem Definition[/b]
A squeeze flag only asks whether one envelope is inside another. It hides how unusual current narrowness is versus history, whether two volatility measures agree, and whether contraction has persisted. It can call any exit an expansion when width merely normalizes. Fixed thresholds transfer poorly across markets and timeframes because scales and distributions differ.

[b]Design Rationale[/b]
Bollinger width uses standard deviation; Keltner width uses ATR. Each is basis-normalized and ranked against its own history. An agreement discount prevents one narrow envelope from creating maximum energy while the other remains broad; dwell separates a brief dip from a mature regime.

“Not compressed” is insufficient. Release must follow minimum dwell, reduce compression at minimum velocity, and show positive ATR slope. This adds lag but filters normalization. Ranks resist outliers, while sacrificing absolute magnitude.

[b]Key Features[/b]
[list]
[*]Self-normalized Bollinger and Keltner bandwidth percentiles.

[*]Agreement-weighted compression energy with dwell maturity.

[*]Release velocity, ATR slope, and ATR percentile combined into expansion force.

[*]Centered field, DNA, halo, phases, dashboard, and confirmed alerts.
[/list]

[b]How It Works[/b]
Bollinger width is band distance divided by absolute basis; Keltner width is normalized identically. [i]ta.percentrank[/i] maps each to 0–100; inversion gives high depth to historically narrow envelopes.

Average depth receives a 0.60-to-1.00 agreement factor based on depth distance. Above threshold, a bar counter starts. Progress toward Minimum Compression Bars raises energy from 75% to 100%, so Primed requires depth and residence.

Release velocity is the one-bar decline in compression; ATR slope compares current ATR with its earlier value. The first confirmed bar outside mature compression must pass both thresholds. Expansion force blends capped velocity, positive slope, and ATR percentile. It persists only while ATR rises and never beyond Maximum Expansion Hold. No future or external data is requested.

[b]How Multiple Indicators Work Together[/b]
This is one sequence, not an unrelated blend. Bollinger observes dispersion; Keltner observes true range. Ranks create comparability, agreement prevents domination, and dwell stores persistence. Release velocity measures discharge; ATR slope tests acceleration. DNA lines expose inputs while the hero field and dashboard explain state.

[b]Trading Ideas and Insights[/b]
A rising positive field means volatility is unusually compressed versus history. Primed is persistent compression, not direction. The expansion diamond confirms qualified release but cannot predict its direction. Repeated starts without maturity can mark unstable ranges; long dwell followed by weak release can mean normalization. These are contexts, not entry or performance claims.

[b]Unique Aspects[/b]
The components are standard; the lifecycle is the contribution. Two normalized depths must agree, compression accumulates residence memory, and expansion requires release from maturity plus range acceleration. The charge/release layout makes order visible. Implementation is independent; no retrieved source was used, reconstructed, translated, or altered.

[b]How to Use[/b]
[list=1]
[*]Allow the percentile lookback to warm up.

[*]Read the positive field as compression energy and compare DNA lines for agreement.

[*]Treat Primed as volatility context, not direction.

[*]Use the negative field and confirmed diamond for a qualified release.

[*]Confirm direction, liquidity, execution, and risk independently.

[*]Disable secondary layers for a cleaner view.
[/list]

[b]Customization[/b]
Envelope Length sets the window; multipliers alter raw widths; rank lookback controls context and adaptation.

Compression Threshold controls narrowness, while Minimum Compression Bars adds maturity and lag. Release Velocity controls discharge. ATR Slope settings define acceleration: lower values react faster but admit weaker releases. Maximum Expansion Hold caps persistence. Reevaluate settings across markets and timeframes.

[b]Assumptions and Limitations[/b]
History must be representative. Percentiles are relative, both envelopes share price data, and ATR is directionless. Expansion cannot determine breakout direction or continuation.

Live-bar values and phases may change before close; markers and alerts require [i]barstate.isconfirmed[/i]. There is no lookahead, negative offset, external symbol, or higher-timeframe request, but the model is lagging and parameter-sensitive. Gaps, illiquidity, regime breaks, and short history reduce usefulness. Orders, fees, slippage, and profitability are outside scope.

[b]Conclusion[/b]
Compression Expansion Map [Pineify] replaces a Boolean squeeze with an inspectable lifecycle. Depth measures charge, dwell measures maturity, and qualified release plus ATR acceleration measures expansion without claiming direction or outcomes.

## Source Code

````pine
//@version=6
indicator("Compression Expansion Map [Pineify]", overlay = false, precision = 1)

string groupEnvelope = "Dual-Envelope Core"
sourceInput = input.source(close, "Source", group = groupEnvelope)
int envelopeLength = input.int(20, "Envelope Length", minval = 5, maxval = 200, group = groupEnvelope)
float bollingerMultiplier = input.float(2.0, "Bollinger Deviation", minval = 0.5, maxval = 5.0, step = 0.1, group = groupEnvelope)
float keltnerMultiplier = input.float(1.5, "Keltner ATR Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = groupEnvelope)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEnvelope)
int rankLookback = input.int(150, "Percentile Lookback", minval = 50, maxval = 1000, group = groupEnvelope)

string groupLifecycle = "Lifecycle State"
float compressionThreshold = input.float(68.0, "Deep Compression Threshold", minval = 50.0, maxval = 90.0, step = 1.0, group = groupLifecycle)
int minimumDwell = input.int(6, "Minimum Compression Bars", minval = 2, maxval = 50, group = groupLifecycle)
float releaseThreshold = input.float(10.0, "Minimum Release Velocity", minval = 2.0, maxval = 40.0, step = 1.0, group = groupLifecycle)
int atrSlopeLength = input.int(5, "ATR Slope Length", minval = 1, maxval = 30, group = groupLifecycle)
float atrSlopeThreshold = input.float(2.0, "Minimum ATR Slope %", minval = 0.0, maxval = 20.0, step = 0.5, group = groupLifecycle)
int expansionHoldBars = input.int(8, "Maximum Expansion Hold", minval = 1, maxval = 30, group = groupLifecycle)

string groupVisual = "Visual System"
bool showEnvelopeDNA = input.bool(true, "Show Envelope DNA", group = groupVisual)
bool showEnergyHalo = input.bool(true, "Show Energy Halo", group = groupVisual)
bool showPhaseBackground = input.bool(true, "Show Phase Background", group = groupVisual)
bool showEventMarkers = input.bool(true, "Show Confirmed Events", group = groupVisual)
bool showDashboard = input.bool(true, "Show Lifecycle Dashboard", group = groupVisual)

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

float bollingerBasis = ta.sma(sourceInput, envelopeLength)
float bollingerDeviation = ta.stdev(sourceInput, envelopeLength) * bollingerMultiplier
float bollingerUpper = bollingerBasis + bollingerDeviation
float bollingerLower = bollingerBasis - bollingerDeviation

float keltnerBasis = ta.ema(sourceInput, envelopeLength)
float atr = ta.atr(atrLength)
float keltnerUpper = keltnerBasis + atr * keltnerMultiplier
float keltnerLower = keltnerBasis - atr * keltnerMultiplier

float bollingerDenominator = math.max(math.abs(bollingerBasis), syminfo.mintick)
float keltnerDenominator = math.max(math.abs(keltnerBasis), syminfo.mintick)
float bollingerWidth = 100.0 * (bollingerUpper - bollingerLower) / bollingerDenominator
float keltnerWidth = 100.0 * (keltnerUpper - keltnerLower) / keltnerDenominator

float bollingerWidthRank = ta.percentrank(bollingerWidth, rankLookback)
float keltnerWidthRank = ta.percentrank(keltnerWidth, rankLookback)
float atrRank = ta.percentrank(atr, rankLookback)
bool ready = not na(bollingerWidthRank) and not na(keltnerWidthRank) and not na(atrRank) and not na(atr[atrSlopeLength])

float bollingerDepth = ready ? 100.0 - bollingerWidthRank : na
float keltnerDepth = ready ? 100.0 - keltnerWidthRank : na
float envelopeAgreement = ready ? 1.0 - math.abs(bollingerDepth - keltnerDepth) / 100.0 : na
float rawCompression = ready ? (bollingerDepth + keltnerDepth) * 0.5 * (0.60 + 0.40 * envelopeAgreement) : na
bool deepCompression = ready and rawCompression >= compressionThreshold

int compressionBars = 0
compressionBars := deepCompression ? nz(compressionBars[1]) + 1 : 0
float dwellMaturity = ready ? math.min(float(compressionBars) / float(minimumDwell), 1.0) : na
float compressionEnergy = ready ? rawCompression * (0.75 + 0.25 * dwellMaturity) : na

float atrSlopePercent = ready and atr[atrSlopeLength] != 0.0 ? 100.0 * (atr / atr[atrSlopeLength] - 1.0) : na
float releaseVelocity = ready ? nz(rawCompression[1], rawCompression) - rawCompression : na
float releaseComponent = ready ? f_clamp(releaseVelocity / releaseThreshold, 0.0, 1.0) : na
float slopeComponent = ready and atrSlopeThreshold > 0.0 ? f_clamp(atrSlopePercent / atrSlopeThreshold, 0.0, 1.0) : ready ? atrSlopePercent > 0.0 ? 1.0 : 0.0 : na
float expansionForce = ready ? 100.0 * (0.45 * releaseComponent + 0.35 * slopeComponent + 0.20 * atrRank / 100.0) : na

bool compressionStart = barstate.isconfirmed and deepCompression and not deepCompression[1]
bool compressionPrimed = barstate.isconfirmed and deepCompression and compressionBars == minimumDwell
bool expansionStart = barstate.isconfirmed and ready and not deepCompression and nz(compressionBars[1], 0) >= minimumDwell and releaseVelocity >= releaseThreshold and atrSlopePercent >= atrSlopeThreshold

int expansionAge = 0
expansionAge := expansionStart ? 1 : nz(expansionAge[1]) > 0 and nz(expansionAge[1]) < expansionHoldBars and atrSlopePercent > 0.0 ? nz(expansionAge[1]) + 1 : 0
bool expansionActive = expansionAge > 0

int lifecycleState = not ready ? 0 : expansionActive ? 4 : deepCompression and compressionBars >= minimumDwell ? 3 : deepCompression ? 2 : 1
float lifecycleEnergy = not ready ? na : expansionActive ? -expansionForce : deepCompression ? compressionEnergy : 0.0

color neutralColor = color.rgb(148, 163, 184)
color compressionLowColor = color.rgb(34, 211, 238)
color compressionHighColor = color.rgb(168, 85, 247)
color expansionLowColor = color.rgb(251, 146, 60)
color expansionHighColor = color.rgb(244, 63, 94)
color compressionColor = not ready ? neutralColor : color.from_gradient(compressionEnergy, 0.0, 100.0, compressionLowColor, compressionHighColor)
color expansionColor = not ready ? neutralColor : color.from_gradient(expansionForce, 0.0, 100.0, expansionLowColor, expansionHighColor)
color energyColor = expansionActive ? expansionColor : deepCompression ? compressionColor : neutralColor
int haloTransparency = ready ? int(math.round(f_clamp(88.0 - math.abs(lifecycleEnergy) * 0.45, 35.0, 88.0))) : 100
int dnaTransparency = ready ? int(math.round(f_clamp(94.0 - envelopeAgreement * 14.0, 78.0, 94.0))) : 100

topRail = hline(100.0, "Maximum Compression Energy", color = color.new(compressionHighColor, 88))
compressionRail = hline(compressionThreshold, "Deep Compression", color = color.new(compressionHighColor, 48), linestyle = hline.style_dotted)
zeroRail = hline(0.0, "Lifecycle Axis", color = color.new(neutralColor, 48))
expansionRail = hline(-60.0, "Strong Expansion", color = color.new(expansionHighColor, 48), linestyle = hline.style_dotted)
bottomRail = hline(-100.0, "Maximum Expansion Force", color = color.new(expansionHighColor, 88))

fill(topRail, compressionRail, color = color.new(compressionHighColor, 92), title = "Primed Compression Zone")
fill(compressionRail, zeroRail, color = color.new(compressionLowColor, 97), title = "Compression Field")
fill(zeroRail, expansionRail, color = color.new(expansionLowColor, 97), title = "Expansion Field")
fill(expansionRail, bottomRail, color = color.new(expansionHighColor, 92), title = "Strong Expansion Zone")

bollingerDNA = plot(showEnvelopeDNA and ready ? bollingerDepth : na, "Bollinger Compression DNA", color = color.new(compressionLowColor, 42), linewidth = 1)
keltnerDNA = plot(showEnvelopeDNA and ready ? keltnerDepth : na, "Keltner Compression DNA", color = color.new(compressionHighColor, 42), linewidth = 1)
fill(bollingerDNA, keltnerDNA, color = showEnvelopeDNA ? color.new(compressionHighColor, dnaTransparency) : na, title = "Envelope Agreement Field")

plot(ready ? lifecycleEnergy : na, "Lifecycle Heat Columns", style = plot.style_columns, histbase = 0.0, color = color.new(energyColor, 48))
plot(showEnergyHalo and ready ? lifecycleEnergy : na, "Lifecycle Energy Halo", color = color.new(energyColor, haloTransparency), linewidth = 6)
plot(ready ? lifecycleEnergy : na, "Compression Expansion Energy", color = energyColor, linewidth = 2)

plotshape(showEventMarkers and compressionStart ? lifecycleEnergy : na, title = "Confirmed Deep Compression Start", style = shape.diamond, location = location.absolute, color = compressionLowColor, size = size.tiny)
plotshape(showEventMarkers and compressionPrimed ? lifecycleEnergy : na, title = "Confirmed Compression Primed", style = shape.circle, location = location.absolute, color = compressionHighColor, size = size.tiny)
plotshape(showEventMarkers and expansionStart ? lifecycleEnergy : na, title = "Confirmed Expansion Start", style = shape.diamond, location = location.absolute, color = expansionHighColor, size = size.small)

color phaseBackground = lifecycleState == 4 ? color.new(expansionColor, 90) : lifecycleState == 3 ? color.new(compressionHighColor, 90) : lifecycleState == 2 ? color.new(compressionLowColor, 94) : na
bgcolor(showPhaseBackground ? phaseBackground : na, title = "Lifecycle Phase Background")

string stateText = lifecycleState == 0 ? "WARMING UP" : lifecycleState == 4 ? "EXPANSION" : lifecycleState == 3 ? "PRIMED" : lifecycleState == 2 ? "COMPRESSING" : "BALANCED"
color stateColor = lifecycleState == 4 ? color.new(expansionColor, 12) : lifecycleState >= 2 ? color.new(compressionColor, 12) : color.new(neutralColor, 28)

var table dashboard = table.new(position.top_right, 2, 6, frame_color = color.new(neutralColor, 55), frame_width = 1, border_color = color.new(neutralColor, 78), border_width = 1)
if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "LIFECYCLE MAP", text_color = color.white, bgcolor = stateColor, text_size = size.small)
        table.cell(dashboard, 1, 0, stateText, text_color = color.white, bgcolor = stateColor, text_size = size.small)
        table.cell(dashboard, 0, 1, "Compression", text_color = compressionLowColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 1, 1, ready ? str.tostring(compressionEnergy, "#.0") : "NA", text_color = compressionColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 0, 2, "Agreement", text_color = neutralColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 1, 2, ready ? str.tostring(envelopeAgreement * 100.0, "#.0") + "%" : "NA", text_color = ready ? color.from_gradient(envelopeAgreement, 0.0, 1.0, neutralColor, compressionHighColor) : neutralColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 0, 3, "Dwell", text_color = neutralColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 1, 3, ready ? str.tostring(compressionBars) + " bars" : "NA", text_color = compressionColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 0, 4, "ATR Slope", text_color = expansionLowColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 1, 4, ready ? str.tostring(atrSlopePercent, "#.0") + "%" : "NA", text_color = atrSlopePercent >= 0.0 ? expansionColor : neutralColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 0, 5, "Release", text_color = expansionHighColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 1, 5, ready ? str.tostring(releaseVelocity, "#.0") : "NA", text_color = expansionColor, bgcolor = color.new(color.black, 82))
    else
        table.clear(dashboard, 0, 0, 1, 5)

alertcondition(compressionStart, "Deep Compression Started", "Compression Expansion Map confirmed the start of a deep dual-envelope compression.")
alertcondition(expansionStart, "Expansion Started", "Compression Expansion Map confirmed a release from mature compression with rising ATR.")
````
