# Sigma Channel [JOAT]

- url: https://www.tradingview.com/script/9uvKJAQY-Sigma-Channel-JOAT/
- type: indicator
- pine_id: PUB;8eadf892d02b429a8f3060cef282d1f5
- version: 1.0

## Description

[b]JOAT Sigma Channel [JOAT][/b]

[b]Introduction[/b]

JOAT Sigma Channel is an open-source regression-based channel overlay built to identify the best-fit directional corridor across a search range of candidate windows.

It is designed to show whether price is traveling normally inside a fitted corridor, stretching away from it, reclaiming it, or moving into stress territory.

The problem it solves is model selection.

A fixed-length regression channel can look excellent in one regime and poor in the next.

If the market accelerates, slows down, or shifts its dominant drift horizon, a static window becomes less useful.

Sigma Channel solves that by searching a range of possible windows and selecting the strongest available fit.

That fit becomes the active corridor.

Around it the script builds multiple sigma tiers.

These tiers create a richer price-state map than a single upper and lower band.

The result is a more useful framework for reading acceptance, stretch, reclaim, and exhaustion.

[image]https://www.tradingview.com/x/mwBEYz45/[/image]

[b]Core Concepts[/b]

[b]1. Multi-Window OLS Search[/b]

The script evaluates multiple candidate regression windows and scores them by fit quality.

[pine]
for len = minWindow to maxWindow by stepWindow
    [candidateSlope, candidateIntercept, candidateR2, candidateSigma] = f_model(len)
[/pine]

[b]2. Sigma-Tier Envelope Stack[/b]

The fitted centerline is surrounded by inner, core, outer, and stress layers.

[b]3. Slope and Quality Diagnostics[/b]

The chosen model exposes both slope and fit quality.

[b]4. Reclaim and Acceptance States[/b]

The script identifies when price reclaims or accepts back inside the corridor after extension.

[b]5. Stress-State Shading[/b]

The most extreme statistical layer is visually emphasized.

[b]6. Forward Projection[/b]

The active model projects forward to keep the corridor useful at the right edge.

[b]7. Residual Awareness[/b]

Residual behavior helps judge whether the active model remains representative.

[b]8. Gradient Candle Context[/b]

Bar coloring transitions with the current statistical state.

[image]https://www.tradingview.com/x/Th44KS7I/[/image]

[b]Features[/b]

[list]
[*][b]Adaptive regression search:[/b] scans multiple windows instead of using one fixed length
[*][b]Inner, core, outer, and stress bands:[/b] multiple sigma tiers for normal and abnormal travel
[*][b]Slope-aware corridor logic:[/b] distinguishes positive and negative drift
[*][b]Reclaim and acceptance events:[/b] return-to-channel behavior is identified
[*][b]Stress shading:[/b] abnormal statistical extension is highlighted
[*][b]Forward projection:[/b] the active corridor extends to the chart edge
[*][b]Gradient candle tinting:[/b] bar color reflects the current z-state
[*][b]Dashboard:[/b] slope, quality, window, and deviation state are summarized
[/list]

[b]Input Parameters[/b]

[b]Model Search:[/b]

[list]
[*]Minimum Window
[*]Maximum Window
[*]Window Step
[*]Minimum R-Squared
[*]Projection Bars
[/list]

[b]Deviation Envelope:[/b]

[list]
[*]Inner Sigma
[*]Core Sigma
[*]Outer Sigma
[*]Stress Sigma
[/list]

[b]Filter Stack / Visual System:[/b]

[list]
[*]Bias EMA
[*]ATR Length
[*]Momentum RSI
[*]Use EMA Bias Gate
[*]Use RSI Gate
[*]Use Volume Gate
[*]Tint Bars
[*]Show Projection
[*]Show Dashboard
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Check the active slope and whether the corridor is upward, downward, or balanced.

[b]Step 2:[/b] Check fit quality before trusting the active statistical path.

[b]Step 3:[/b] Read whether price is inside the core corridor, at the outer layer, or in stress territory.

[b]Step 4:[/b] Watch reclaims back into the channel after extension.

[b]Step 5:[/b] Use the projection to organize the near-future chart space.

[b]Indicator Limitations[/b]

[list]
[*]The selected best-fit window can change as the market evolves
[*]Linear regression becomes less representative in strongly nonlinear markets
[*]Statistical extension does not guarantee immediate reversal
[*]The indicator measures deviation from a model, not directional certainty
[/list]

[b]Originality Statement[/b]

This script is original in the way it combines adaptive regression selection, multi-tier sigma structure, reclaim logic, stress-state shading, and forward projection into one corridor framework.

The goal is not just to draw a regression channel.

The goal is to keep the active model responsive while preserving statistical context.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not financial advice.

Regression fit and statistical deviation do not predict future price with certainty.

Markets can remain extended or break away from the active fit entirely.

[b]Best Use Cases[/b]

[list]
[*]Reading whether price is behaving normally inside a fitted directional corridor
[*]Identifying statistical stretch and stress states
[*]Watching for reclaim behavior after extension
[*]Combining statistical deviation with separate structure or liquidity analysis
[/list]

[b]Interpretation Notes[/b]

The channel should be trusted more when fit quality is stronger and the slope is clear.

Core travel is generally more normal than outer-band travel.

Stress states are especially useful when they coincide with separate structural or participation warnings.

The projection should be read as a continuation of the current best-fit model, not as a forecast guarantee.

[b]Publication Notes[/b]

This script is intended to be published with a clean chart where the corridor, the active slope, and at least one reclaim or extension state are obvious.

The example chart should help the viewer understand how the band hierarchy works.

Avoid combining it with unrelated overlays in the publication image.

-Made with passion by jackofalltrades

## Source Code

````pine
//@version=6
indicator("Sigma Channel [JOAT]", shorttitle = "SGM [JOAT]", overlay = true, max_lines_count = 220, max_labels_count = 140, max_boxes_count = 80, max_bars_back = 5000)

string G_MODEL = "Model Search"
string G_FILTER = "Filter Stack"
string G_VIS = "Visual System"

int minWindow = input.int(34, "Minimum Window", minval = 10, maxval = 300, group = G_MODEL)
int maxWindow = input.int(160, "Maximum Window", minval = 20, maxval = 500, group = G_MODEL)
int stepWindow = input.int(7, "Window Step", minval = 1, maxval = 50, group = G_MODEL)
float qualityFloor = input.float(0.52, "Minimum R-Squared", minval = 0.10, maxval = 0.99, step = 0.01, group = G_MODEL)
float innerMult = input.float(1.00, "Inner Sigma", minval = 0.40, step = 0.05, group = G_MODEL)
float coreMult = input.float(1.65, "Core Sigma", minval = 0.80, step = 0.05, group = G_MODEL)
float outerMult = input.float(2.40, "Outer Sigma", minval = 1.00, step = 0.05, group = G_MODEL)
float stressMult = input.float(3.20, "Stress Sigma", minval = 1.20, step = 0.05, group = G_MODEL)
int projectionBars = input.int(18, "Forward Projection", minval = 5, maxval = 120, group = G_MODEL)

int biasLen = input.int(89, "Bias EMA", minval = 10, maxval = 400, group = G_FILTER)
int atrLen = input.int(14, "ATR Length", minval = 2, group = G_FILTER)
int momentumLen = input.int(14, "Momentum RSI", minval = 2, group = G_FILTER)
bool useBiasGate = input.bool(true, "Use EMA Bias Gate", group = G_FILTER)
bool useMomentumGate = input.bool(true, "Use RSI Gate", group = G_FILTER)
bool useVolumeGate = input.bool(false, "Use Volume Sponsorship", group = G_FILTER)
int volumeLen = input.int(20, "Volume Baseline", minval = 5, maxval = 200, group = G_FILTER)
float volumeThreshold = input.float(1.05, "Volume Threshold", minval = 0.50, step = 0.05, group = G_FILTER)

bool tintBars = input.bool(true, "Tint Bars", group = G_VIS)
bool showProjection = input.bool(true, "Show Forward Projection", group = G_VIS)
bool showLabel = input.bool(true, "Show State Label", group = G_VIS)
bool showDashboard = input.bool(true, "Show Dashboard", group = G_VIS)
bool shadeStress = input.bool(true, "Shade Stress State", group = G_VIS)

color bullCore = input.color(color.rgb(21, 196, 156), "Bull Core", group = G_VIS)
color bearCore = input.color(color.rgb(222, 93, 121), "Bear Core", group = G_VIS)
color accentCore = input.color(color.rgb(230, 194, 103), "Accent", group = G_VIS)
color neutralCore = input.color(color.rgb(122, 135, 159), "Neutral", group = G_VIS)
color shellCore = input.color(color.rgb(91, 160, 255), "Shell Accent", group = G_VIS)
color panelBg = input.color(color.rgb(11, 16, 28), "Dashboard Background", group = G_VIS)
color panelEdge = input.color(color.rgb(42, 57, 79), "Dashboard Border", group = G_VIS)

type FitModel
    float slope
    float intercept
    float r2
    float sigma
    float mae
    float score
    int length
    bool valid

f_clamp(float value, float lowValue, float highValue) =>
    math.max(lowValue, math.min(highValue, value))

f_model(int lengthValue) =>
    float sumX = 0.0
    float sumY = 0.0
    float sumXX = 0.0
    float sumXY = 0.0
    float sumYY = 0.0
    for i = 0 to lengthValue - 1
        float x = i
        float y = close[lengthValue - 1 - i]
        sumX += x
        sumY += y
        sumXX += x * x
        sumXY += x * y
        sumYY += y * y
    float denomX = lengthValue * sumXX - sumX * sumX
    float denomY = lengthValue * sumYY - sumY * sumY
    float slopeValue = 0.0
    float interceptValue = 0.0
    float r2Value = 0.0
    float sigmaValue = na
    float maeValue = na
    bool validValue = false
    if denomX > 0 and denomY > 0
        slopeValue := (lengthValue * sumXY - sumX * sumY) / denomX
        interceptValue := (sumY - slopeValue * sumX) / lengthValue
        float corr = (lengthValue * sumXY - sumX * sumY) / math.sqrt(denomX * denomY)
        r2Value := corr * corr
        float sse = 0.0
        float sae = 0.0
        for j = 0 to lengthValue - 1
            float expected = interceptValue + slopeValue * j
            float actual = close[lengthValue - 1 - j]
            float residual = actual - expected
            sse += residual * residual
            sae += math.abs(residual)
        sigmaValue := math.sqrt(sse / math.max(lengthValue - 2, 1))
        maeValue := sae / lengthValue
        validValue := true
    FitModel.new(slopeValue, interceptValue, r2Value, sigmaValue, maeValue, na, lengthValue, validValue)

f_line_update(line id, int x1, float y1, int x2, float y2, color lineColor, int widthValue, styleValue) =>
    line target = id
    if na(target)
        target := line.new(x1, y1, x2, y2, color = lineColor, width = widthValue, style = styleValue)
    line.set_xy1(target, x1, y1)
    line.set_xy2(target, x2, y2)
    line.set_color(target, lineColor)
    line.set_width(target, widthValue)
    line.set_style(target, styleValue)
    target

f_label_update(label id, int xValue, float yValue, string textValue, color textColor, color fillColor) =>
    label target = id
    if na(target)
        target := label.new(xValue, yValue, textValue, style = label.style_label_left, color = fillColor, textcolor = textColor, size = size.small)
    label.set_xy(target, xValue, yValue)
    label.set_text(target, textValue)
    label.set_textcolor(target, textColor)
    label.set_color(target, fillColor)
    target

float atrValue = ta.atr(atrLen)
float biasEma = ta.ema(close, biasLen)
float momentum = ta.rsi(close, momentumLen)
float volumeBase = ta.sma(volume, volumeLen)
bool volumeSponsored = volume > volumeBase * volumeThreshold

float bestScore = na
FitModel best = FitModel.new(na, na, na, na, na, na, na, false)

for lengthValue = minWindow to maxWindow by stepWindow
    FitModel candidate = f_model(lengthValue)
    if candidate.valid and candidate.r2 >= qualityFloor
        float slopeAtr = atrValue > 0 ? math.abs(candidate.slope) / atrValue : 0.0
        float sigmaAtr = atrValue > 0 and not na(candidate.sigma) ? candidate.sigma / atrValue : 0.0
        float scoreValue = candidate.r2 * math.log(lengthValue) + slopeAtr * 0.35 - sigmaAtr * 0.10
        candidate.score := scoreValue
        if na(bestScore) or scoreValue > bestScore
            bestScore := scoreValue
            best := candidate

bool validModel = best.valid and not na(best.length)
float sigmaUnit = validModel ? math.max(best.sigma, syminfo.mintick) : na
float centerStart = validModel ? best.intercept : na
float centerNow = validModel ? best.intercept + best.slope * (best.length - 1) : na
float centerNext = validModel ? best.intercept + best.slope * best.length : na
float centerProjection = validModel ? best.intercept + best.slope * (best.length - 1 + projectionBars) : na

float upperInner = validModel ? centerNow + sigmaUnit * innerMult : na
float lowerInner = validModel ? centerNow - sigmaUnit * innerMult : na
float upperCore = validModel ? centerNow + sigmaUnit * coreMult : na
float lowerCore = validModel ? centerNow - sigmaUnit * coreMult : na
float upperOuter = validModel ? centerNow + sigmaUnit * outerMult : na
float lowerOuter = validModel ? centerNow - sigmaUnit * outerMult : na
float upperStress = validModel ? centerNow + sigmaUnit * stressMult : na
float lowerStress = validModel ? centerNow - sigmaUnit * stressMult : na

float projectedUpperCore = validModel ? centerProjection + sigmaUnit * coreMult : na
float projectedLowerCore = validModel ? centerProjection - sigmaUnit * coreMult : na
float projectedUpperOuter = validModel ? centerProjection + sigmaUnit * outerMult : na
float projectedLowerOuter = validModel ? centerProjection - sigmaUnit * outerMult : na

float residualZ = validModel ? (close - centerNow) / sigmaUnit : na
float slopeAtr = validModel and atrValue > 0 ? best.slope / atrValue : na
float widthAtr = validModel and atrValue > 0 ? (upperCore - lowerCore) / atrValue : na
float stretchAtr = validModel and atrValue > 0 ? (upperOuter - lowerOuter) / atrValue : na
float regimeStrength = validModel ? best.r2 * math.min(math.abs(nz(slopeAtr)) * 100.0, 100.0) : na
float priceVsBias = atrValue > 0 ? (close - biasEma) / atrValue : na

bool ascendingAuction = validModel and best.slope > 0
bool descendingAuction = validModel and best.slope < 0
bool balanceAuction = validModel and best.slope == 0
bool biasLong = not useBiasGate or close >= biasEma
bool biasShort = not useBiasGate or close <= biasEma
bool momentumLong = not useMomentumGate or momentum >= 50
bool momentumShort = not useMomentumGate or momentum <= 50
bool sponsorGate = not useVolumeGate or volumeSponsored

bool longReclaim = barstate.isconfirmed and ascendingAuction and close > lowerCore and close[1] <= lowerCore[1] and biasLong and momentumLong and sponsorGate
bool shortReclaim = barstate.isconfirmed and descendingAuction and close < upperCore and close[1] >= upperCore[1] and biasShort and momentumShort and sponsorGate
bool longAcceptance = barstate.isconfirmed and ascendingAuction and ta.crossover(close, centerNow) and residualZ <= 0.75 and biasLong and sponsorGate
bool shortAcceptance = barstate.isconfirmed and descendingAuction and ta.crossunder(close, centerNow) and residualZ >= -0.75 and biasShort and sponsorGate
bool longExhaustion = barstate.isconfirmed and ascendingAuction and ta.crossunder(close, upperOuter) and close[1] > upperOuter[1]
bool shortExhaustion = barstate.isconfirmed and descendingAuction and ta.crossover(close, lowerOuter) and close[1] < lowerOuter[1]

bool stressLong = validModel and close > upperOuter
bool stressShort = validModel and close < lowerOuter
bool extremeLong = validModel and close > upperStress
bool extremeShort = validModel and close < lowerStress

color slopeColor = ascendingAuction ? bullCore : descendingAuction ? bearCore : neutralCore
color residualColor = color.from_gradient(f_clamp(nz(residualZ), -stressMult, stressMult), -stressMult, stressMult, color.new(bearCore, 0), color.new(bullCore, 0))
color shellColor = color.from_gradient(f_clamp(math.abs(nz(residualZ)), 0.0, stressMult), 0.0, stressMult, color.new(shellCore, 10), color.new(accentCore, 0))
color stateColor = longReclaim or longAcceptance ? bullCore : shortReclaim or shortAcceptance ? bearCore : residualColor

plotCenter = plot(centerNow, "Centerline", color = residualColor, linewidth = 2)
plotInnerTop = plot(upperInner, "Upper Inner", color = color.new(shellColor, 15), linewidth = 1)
plotInnerBottom = plot(lowerInner, "Lower Inner", color = color.new(shellColor, 15), linewidth = 1)
plotCoreTop = plot(upperCore, "Upper Core", color = color.new(slopeColor, 0), linewidth = 1)
plotCoreBottom = plot(lowerCore, "Lower Core", color = color.new(slopeColor, 0), linewidth = 1)
plotOuterTop = plot(upperOuter, "Upper Outer", color = color.new(slopeColor, 35), linewidth = 1, style = plot.style_linebr)
plotOuterBottom = plot(lowerOuter, "Lower Outer", color = color.new(slopeColor, 35), linewidth = 1, style = plot.style_linebr)
plotStressTop = plot(upperStress, "Upper Stress", color = color.new(accentCore, 70), linewidth = 1, style = plot.style_linebr)
plotStressBottom = plot(lowerStress, "Lower Stress", color = color.new(accentCore, 70), linewidth = 1, style = plot.style_linebr)

fill(plotInnerTop, plotInnerBottom, color = color.new(residualColor, 88), title = "Inner Envelope")
fill(plotCoreTop, plotCoreBottom, color = color.new(slopeColor, 92), title = "Core Envelope")
fill(plotOuterTop, plotCoreTop, color = color.new(slopeColor, 95), title = "Upper Shell")
fill(plotCoreBottom, plotOuterBottom, color = color.new(slopeColor, 95), title = "Lower Shell")
fill(plotStressTop, plotOuterTop, color = color.new(accentCore, 97), title = "Upper Stress Fill")
fill(plotOuterBottom, plotStressBottom, color = color.new(accentCore, 97), title = "Lower Stress Fill")

barcolor(tintBars ? (longReclaim or longAcceptance ? bullCore : shortReclaim or shortAcceptance ? bearCore : color.new(residualColor, 20)) : na)
bgcolor(shadeStress ? extremeLong ? color.new(bearCore, 93) : extremeShort ? color.new(bullCore, 93) : na : na, title = "Stress Backdrop")

var line projCenter = na
var line projUpperCore = na
var line projLowerCore = na
var line projUpperOuter = na
var line projLowerOuter = na
var label stateLabel = na

if barstate.islast
    int rightBar = bar_index + projectionBars
    if showProjection and validModel
        int startBar = bar_index - best.length + 1
        projCenter := f_line_update(projCenter, startBar, centerStart, rightBar, centerProjection, color.new(residualColor, 20), 2, line.style_solid)
        projUpperCore := f_line_update(projUpperCore, startBar, centerStart + sigmaUnit * coreMult, rightBar, projectedUpperCore, color.new(slopeColor, 15), 1, line.style_dashed)
        projLowerCore := f_line_update(projLowerCore, startBar, centerStart - sigmaUnit * coreMult, rightBar, projectedLowerCore, color.new(slopeColor, 15), 1, line.style_dashed)
        projUpperOuter := f_line_update(projUpperOuter, startBar, centerStart + sigmaUnit * outerMult, rightBar, projectedUpperOuter, color.new(shellColor, 40), 1, line.style_dotted)
        projLowerOuter := f_line_update(projLowerOuter, startBar, centerStart - sigmaUnit * outerMult, rightBar, projectedLowerOuter, color.new(shellColor, 40), 1, line.style_dotted)
    else
        if not na(projCenter)
            line.delete(projCenter)
            projCenter := na
        if not na(projUpperCore)
            line.delete(projUpperCore)
            projUpperCore := na
        if not na(projLowerCore)
            line.delete(projLowerCore)
            projLowerCore := na
        if not na(projUpperOuter)
            line.delete(projUpperOuter)
            projUpperOuter := na
        if not na(projLowerOuter)
            line.delete(projLowerOuter)
            projLowerOuter := na
    if showLabel and validModel
        string stateText = longReclaim ? "Bullish Reclaim" : shortReclaim ? "Bearish Reclaim" : longAcceptance ? "Bullish Acceptance" : shortAcceptance ? "Bearish Acceptance" : stressLong ? "Upper Stress" : stressShort ? "Lower Stress" : ascendingAuction ? "Ascending Auction" : descendingAuction ? "Descending Auction" : "Balanced Auction"
        float labelY = stressLong ? upperStress : stressShort ? lowerStress : centerNow
        stateLabel := f_label_update(stateLabel, rightBar, labelY, stateText, stateColor, color.new(panelBg, 8))
    else if not na(stateLabel)
        label.delete(stateLabel)
        stateLabel := na

var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(panelBg, 8), frame_color = panelEdge, frame_width = 1, border_color = panelEdge, border_width = 1)
if showDashboard and barstate.islast
    string regimeText = ascendingAuction ? "Ascending" : descendingAuction ? "Descending" : "Balanced"
    string setupText = longReclaim ? "Long Reclaim" : shortReclaim ? "Short Reclaim" : longAcceptance ? "Long Acceptance" : shortAcceptance ? "Short Acceptance" : longExhaustion ? "Long Exhaustion" : shortExhaustion ? "Short Exhaustion" : "Monitoring"
    string biasText = useBiasGate ? close >= biasEma ? "Above EMA" : "Below EMA" : "Disabled"
    string momentumText = useMomentumGate ? momentum >= 50 ? "Positive" : "Negative" : "Disabled"
    string sponsorshipText = volumeSponsored ? "Sponsored" : "Neutral"

    table.cell(dash, 0, 0, "Sigma", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dash, 1, 0, regimeText, text_color = slopeColor, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dash, 0, 1, "Window", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 1, validModel ? str.tostring(best.length) : "No Model", text_color = color.white, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 2, "R2", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 2, validModel ? str.tostring(best.r2, "#.000") : "na", text_color = validModel and best.r2 >= qualityFloor ? accentCore : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 3, "Slope / ATR", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 3, validModel ? str.tostring(slopeAtr, "#.000") : "na", text_color = slopeColor, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 4, "Z-Score", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 4, validModel ? str.tostring(residualZ, "#.00") : "na", text_color = math.abs(nz(residualZ)) > outerMult ? accentCore : color.white, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 5, "Width / ATR", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 5, validModel ? str.tostring(widthAtr, "#.00") : "na", text_color = shellCore, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 6, "Setup", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 6, setupText, text_color = stateColor, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 7, "Bias / RSI", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 7, biasText + " / " + momentumText, text_color = close >= biasEma ? bullCore : bearCore, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 8, "Volume", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 8, sponsorshipText, text_color = volumeSponsored ? shellCore : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.small)

plot(best.r2, "R-Squared", color = color.new(color.white, 100), display = display.data_window)
plot(best.sigma, "Sigma", color = color.new(color.white, 100), display = display.data_window)
plot(best.mae, "MAE", color = color.new(color.white, 100), display = display.data_window)
plot(residualZ, "Residual Z", color = color.new(color.white, 100), display = display.data_window)
plot(slopeAtr, "Slope ATR", color = color.new(color.white, 100), display = display.data_window)
plot(widthAtr, "Width ATR", color = color.new(color.white, 100), display = display.data_window)
plot(regimeStrength, "Regime Strength", color = color.new(color.white, 100), display = display.data_window)
plot(priceVsBias, "Price vs Bias ATR", color = color.new(color.white, 100), display = display.data_window)

alertcondition(longReclaim, "SGM Long Reclaim", "Sigma Channel [JOAT] detected a long reclaim on {{ticker}}.")
alertcondition(shortReclaim, "SGM Short Reclaim", "Sigma Channel [JOAT] detected a short reclaim on {{ticker}}.")
alertcondition(longAcceptance, "SGM Long Acceptance", "Sigma Channel [JOAT] detected a long acceptance through centerline on {{ticker}}.")
alertcondition(shortAcceptance, "SGM Short Acceptance", "Sigma Channel [JOAT] detected a short acceptance through centerline on {{ticker}}.")
alertcondition(longExhaustion or shortExhaustion, "SGM Exhaustion", "Sigma Channel [JOAT] detected an outer-envelope exhaustion on {{ticker}}.")
alertcondition(extremeLong or extremeShort, "SGM Stress", "Sigma Channel [JOAT] entered a stress condition on {{ticker}}.")
````
