# TBSMMR | TradeBee

- url: https://www.tradingview.com/script/74tM6pef-TBSMMR-TradeBee/
- type: indicator
- pine_id: PUB;86b18999f57b4459b9808fb3bbeb0fe5
- version: 1.0

## Description

Purpose: Small-Cap Market Regime (TBSMMR) evaluates overall US small-cap market conditions and classifies the market as Bullish, Choppy, or Bearish.

Key Features :
Market indicators: IWM, QQQ, SPY, and US 10-Year Treasury yield.

Composite Score: Combines trend, relative strength, directional efficiency, volume, and yield movements.

Market Regime: Identifies BULLISH, CHOPPY, or BEARISH conditions.

Trend Labels: Displays UPTREND, DOWNTREND, or MIXED for IWM and QQQ.

Dashboard: Customizable position, font size, and displayed metrics, including centre positioning.

Visual Indicators: Color-coded regime and score, with optional IWM EMA 20 and EMA 50 plots.

Alerts: Notifications when the market regime changes.

Color Interpretation
Green    Bullish
Pink       Choppy / Mixed
Red       Bearish

Important Notes :
The default analysis timeframe is daily. The default bullish threshold is +35, and the bearish threshold is −25, subject to the additional regime rules. The composite score is a rule-based market indicator, not a probability or a standalone buy/sell signal.

DASHBOARD ELEMENTS & INTERPRETATION

1. MARKET REGIME
   Shows the overall market condition.

   BULLISH - Positive market conditions.
   CHOPPY  - Mixed or less directional conditions.
   BEARISH - Negative market conditions.

2. COMPOSITE SCORE
   Combines trend, relative strength, directional efficiency,
   volume and Treasury yield movements.

   Higher score - More bullish inputs.
   Lower score  - More bearish inputs.

   The background color reflects the overall market regime,
   not just whether the score is positive or negative.

3. IWM TREND
   Shows the trend of the Russell 2000 small-cap ETF.

   UPTREND   - Price above EMA 20, and EMA 20 above EMA 50.
   DOWNTREND - Price below EMA 20, and EMA 20 below EMA 50.
   MIXED     - Neither condition is satisfied.

4. QQQ TREND
   Shows the trend of the Nasdaq-100 ETF.

   Uses the same EMA 20 and EMA 50 rules as IWM.
   Helps assess whether Nasdaq stocks confirm the small-cap trend.

5. IWM vs SPY
   Compares IWM's return with SPY's return over the selected
   lookback period.

   Positive value - IWM is outperforming SPY.
   Negative value - IWM is underperforming SPY.

6. DIRECTIONAL EFFICIENCY
   Measures how directly IWM price has moved over the lookback.

   Higher value - More directional price movement.
   Lower value  - Choppier price movement.

   Default regime filter: 35%.

7. IWM VOLUME RATIO
   Compares current IWM volume with its average volume.

   1.0x       - Average volume.
   Above 1.2x - Stronger-than-average volume using the default
   setting.

   Consider volume together with price direction.

8. 10Y YIELD CHANGE
   Shows the change in the US 10-year Treasury yield over the
   selected lookback, expressed in basis points (bps).

   Rising yields  - Can put pressure on equities.
   Falling yields - Can ease pressure on equities.

   Default pressure threshold: +10 bps or -10 bps.

COLOUR GUIDE

GREEN - Bullish
PINK  - Choppy / Mixed
RED   - Bearish

QUICK INTERPRETATION

* BULLISH regime + IWM and QQQ UPTREND:
  Trend signals are aligned positively.

* CHOPPY regime + MIXED trends or low efficiency:
  Signals are less aligned or price movement is less directional.

* BEARISH regime + IWM DOWNTREND:
  Small-cap weakness is consistent with the bearish classification.

* Conflicting readings:
  Review the individual dashboard elements to understand what
  is influencing the overall regime.

IMPORTANT NOTE
A BEARISH regime can also be triggered by the additional IWM
bearish-trend rule, even when the composite score is above
the bearish score threshold.

TBSMMR is a rule-based market assessment, not a guarantee of
future performance or a standalone buy/sell signal.

## Source Code

````pine

 //@version=6
indicator("TBSMMR | TradeBee", shorttitle="TBSMMR", overlay=true)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

groupSymbols = "Market Symbols"
groupCalc = "Calculation Settings"
groupRegime = "Regime Thresholds"
groupDisplay = "Dashboard Display"
groupColors = "Colors"
groupAlerts = "Alerts"

iwmSymbol = input.symbol("AMEX:IWM", "IWM Small-Cap ETF", group=groupSymbols)
qqqSymbol = input.symbol("NASDAQ:QQQ", "QQQ Nasdaq ETF", group=groupSymbols)
spySymbol = input.symbol("AMEX:SPY", "SPY S&P 500 ETF", group=groupSymbols)
yieldSymbol = input.symbol("TVC:US10Y", "US 10-Year Yield", group=groupSymbols)

analysisTimeframe = input.timeframe("D", "Analysis Timeframe", group=groupCalc)
relativeStrengthLength = input.int(20, "Relative Strength Lookback", minval=1, group=groupCalc)
volumeLength = input.int(20, "Volume Average Length", minval=1, group=groupCalc)
efficiencyLength = input.int(20, "Directional Efficiency Length", minval=2, group=groupCalc)
strongVolumeRatio = input.float(1.2, "Strong Volume Ratio", minval=0.1, step=0.1, group=groupCalc)
yieldLookback = input.int(5, "10Y Yield Change Lookback", minval=1, group=groupCalc)
yieldPressureBps = input.float(10.0, "10Y Yield Pressure (bps)", minval=0, step=1, group=groupCalc)

greenThreshold = input.int(35, "Bullish Score Threshold", group=groupRegime)
redThreshold = input.int(-25, "Bearish Score Threshold", group=groupRegime)
chopEfficiencyThreshold = input.float(0.35, "Minimum Trend Efficiency", minval=0, maxval=1, step=0.05, group=groupRegime)

showRegimeBackground = input.bool(false, "Show Market Regime Background", group=groupDisplay)
bgTransparency = input.int(90, "Chart Background Transparency", minval=0, maxval=100, group=groupDisplay)
showEmaPlots = input.bool(true, "Show IWM EMA 20 / 50", group=groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options=[
         "Top Left", "Top Centre", "Top Right",
         "Middle Left", "Middle Centre", "Middle Right",
         "Bottom Left", "Bottom Centre", "Bottom Right"
     ],
     group=groupDisplay)

dashboardFont = input.string("Small", "Dashboard Font Size", options=["Tiny", "Small", "Normal", "Large"], group=groupDisplay)

showTitleRow = input.bool(true, "Show Title", group=groupDisplay)
showRegimeRow = input.bool(true, "Show Market Regime", group=groupDisplay)
showScoreRow = input.bool(true, "Show Composite Score", group=groupDisplay)
showIwmTrendRow = input.bool(true, "Show IWM Trend", group=groupDisplay)
showQqqTrendRow = input.bool(true, "Show QQQ Trend", group=groupDisplay)
showRelativeStrengthRow = input.bool(true, "Show IWM vs SPY", group=groupDisplay)
showEfficiencyRow = input.bool(true, "Show Directional Efficiency", group=groupDisplay)
showVolumeRow = input.bool(true, "Show IWM Volume Ratio", group=groupDisplay)
showYieldRow = input.bool(true, "Show 10Y Yield Change", group=groupDisplay)

bullColor = input.color(color.rgb(0, 150, 80), "Bullish Green", group=groupColors)
chopColor = input.color(color.rgb(244, 160, 190), "Choppy / Mixed Pink", group=groupColors)
bearColor = input.color(color.rgb(210, 45, 55), "Bearish Red", group=groupColors)
neutralColor = input.color(color.rgb(100, 105, 115), "Neutral Background", group=groupColors)
dashboardTextColor = input.color(color.white, "Dashboard Text", group=groupColors)
otherTextColor = input.color(color.rgb(220, 225, 235), "Other Dashboard Text", group=groupColors)

enableBullishAlert = input.bool(true, "Alert: Enter Bullish Regime", group=groupAlerts)
enableChoppyAlert = input.bool(true, "Alert: Enter Choppy Regime", group=groupAlerts)
enableBearishAlert = input.bool(true, "Alert: Enter Bearish Regime", group=groupAlerts)

// ─────────────────────────────────────────────
// MARKET METRICS
// ─────────────────────────────────────────────

f_metrics() =>
    ema20 = ta.ema(close, 20)
    ema50 = ta.ema(close, 50)
    roc5 = ta.roc(close, 5)
    roc20 = ta.roc(close, relativeStrengthLength)
    volAvg = ta.sma(volume, volumeLength)
    volRatio = not na(volAvg) and volAvg != 0 ? volume / volAvg : na
    netMove = math.abs(close - close[efficiencyLength])
    barMoves = math.sum(math.abs(close - close[1]), efficiencyLength)
    efficiency = not na(barMoves) and barMoves != 0 ? netMove / barMoves : 0.0
    [close, ema20, ema50, roc5, roc20, volRatio, efficiency]

[iwmClose, iwmEma20, iwmEma50, iwmRoc5, iwmRoc20, iwmVolRatio, iwmEfficiency] = request.security(iwmSymbol, analysisTimeframe, f_metrics())

[qqqClose, qqqEma20, qqqEma50, qqqRoc5, qqqRoc20, qqqVolRatio, qqqEfficiency] = request.security(qqqSymbol, analysisTimeframe, f_metrics())

[spyClose, spyEma20, spyEma50, spyRoc5, spyRoc20, spyVolRatio, spyEfficiency] = request.security(spySymbol, analysisTimeframe, f_metrics())

yieldChangeBps = request.security(
     yieldSymbol, analysisTimeframe,
     (close - close[yieldLookback]) * 100)

// ─────────────────────────────────────────────
// TREND LABELS
// ─────────────────────────────────────────────

f_trend(_close, _ema20, _ema50) =>
    _close > _ema20 and _ema20 > _ema50 ? "UPTREND" :
     _close < _ema20 and _ema20 < _ema50 ? "DOWNTREND" :
     "MIXED"

f_trendColor(_trend) =>
    _trend == "UPTREND" ? bullColor :
     _trend == "DOWNTREND" ? bearColor :
     chopColor

iwmTrend = f_trend(iwmClose, iwmEma20, iwmEma50)
qqqTrend = f_trend(qqqClose, qqqEma20, qqqEma50)

iwmTrendColor = f_trendColor(iwmTrend)
qqqTrendColor = f_trendColor(qqqTrend)

// ─────────────────────────────────────────────
// COMPOSITE SCORE
// ─────────────────────────────────────────────

relativeStrength = iwmRoc20 - spyRoc20

int compositeScore = 0

compositeScore += iwmClose > iwmEma20 ? 20 : -20
compositeScore += iwmEma20 > iwmEma50 ? 15 : -15
compositeScore += qqqClose > qqqEma20 ? 10 : -10
compositeScore += relativeStrength > 0 ? 15 : -15
compositeScore += iwmEfficiency >= chopEfficiencyThreshold ? 10 : 0
compositeScore += iwmVolRatio >= strongVolumeRatio and iwmRoc5 > 0 ? 10 : 0
compositeScore += iwmVolRatio >= strongVolumeRatio and iwmRoc5 < 0 ? -10 : 0
compositeScore += yieldChangeBps >= yieldPressureBps ? -10 : 0
compositeScore += yieldChangeBps <= -yieldPressureBps ? 5 : 0

// ─────────────────────────────────────────────
// MARKET REGIME
// ─────────────────────────────────────────────

isBullish = compositeScore >= greenThreshold and iwmEfficiency >= chopEfficiencyThreshold

isBearish = compositeScore <= redThreshold or
     (iwmClose < iwmEma50 and iwmRoc20 < 0 and iwmEfficiency >= chopEfficiencyThreshold)

regime = isBullish ? "BULLISH" : isBearish ? "BEARISH" : "CHOPPY"

regimeColor = isBullish ? bullColor : isBearish ? bearColor : chopColor

// Composite score background matches the overall regime.
scoreBackground = regimeColor

// ─────────────────────────────────────────────
// CHART DISPLAY
// ─────────────────────────────────────────────

bgcolor(
     showRegimeBackground ? color.new(regimeColor, bgTransparency) : na,
     title="Market Regime Background",
     force_overlay=true)

plot(showEmaPlots ? iwmEma20 : na, title="IWM EMA 20", color=bullColor, linewidth=2, force_overlay=true)
plot(showEmaPlots ? iwmEma50 : na, title="IWM EMA 50", color=bearColor, linewidth=2, force_overlay=true)

// ─────────────────────────────────────────────
// DASHBOARD HELPERS
// ─────────────────────────────────────────────

f_position(_position) =>
    switch _position
        "Top Left"      => position.top_left
        "Top Centre"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Centre" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Centre" => position.bottom_center
        => position.bottom_right

f_fontSize(_size) =>
    _size == "Tiny" ? size.tiny :
     _size == "Normal" ? size.normal :
     _size == "Large" ? size.large :
     size.small

f_ratio(_value) =>
    na(_value) ? "N/A" : str.tostring(_value, "#.##") + "x"

f_efficiency(_value) =>
    na(_value) ? "N/A" : str.tostring(_value * 100, "#.0") + "%"

f_bps(_value) =>
    na(_value) ? "N/A" :
     (_value > 0 ? "+" : "") + str.tostring(_value, "#.0") + " bps"

f_metricColor(_value) =>
    na(_value) ? neutralColor :
     _value > 0 ? bullColor :
     _value < 0 ? bearColor : neutralColor

// ─────────────────────────────────────────────
// DASHBOARD ROW COUNT
// ─────────────────────────────────────────────

dashboardRows = (showTitleRow ? 1 : 0) +
     (showRegimeRow ? 1 : 0) +
     (showScoreRow ? 1 : 0) +
     (showIwmTrendRow ? 1 : 0) +
     (showQqqTrendRow ? 1 : 0) +
     (showRelativeStrengthRow ? 1 : 0) +
     (showEfficiencyRow ? 1 : 0) +
     (showVolumeRow ? 1 : 0) +
     (showYieldRow ? 1 : 0)

var table dashboard = table.new(
     f_position(dashboardPosition), 2, math.max(dashboardRows, 1),
     border_width=1, frame_width=1)

// ─────────────────────────────────────────────
// DASHBOARD RENDERING
// ─────────────────────────────────────────────

if barstate.islast
    table.clear(dashboard, 0, 0, 1, math.max(dashboardRows, 1) - 1)

    if showDashboard
        int row = 0
        textSize = f_fontSize(dashboardFont)

        if showTitleRow
            table.cell(dashboard, 0, row, "TBSMMR | TradeBee",
                 bgcolor=color.rgb(35, 40, 50), text_color=color.white,
                 text_size=textSize, tooltip="TradeBee Small-Cap Market Regime dashboard.")
            table.cell(dashboard, 1, row, analysisTimeframe,
                 bgcolor=color.rgb(35, 40, 50), text_color=color.white,
                 text_size=textSize, tooltip="Analysis timeframe.")
            row += 1

        if showRegimeRow
            table.cell(dashboard, 0, row, "MARKET REGIME",
                 bgcolor=neutralColor, text_color=dashboardTextColor,
                 text_size=textSize,
                 tooltip="Overall market state from the composite score and directional efficiency.")
            table.cell(dashboard, 1, row, regime,
                 bgcolor=regimeColor, text_color=color.black,
                 text_size=textSize,
                 tooltip="BULLISH: score meets bullish threshold and efficiency filter. BEARISH: score meets bearish rule. Otherwise CHOPPY.")
            row += 1

        if showScoreRow
            table.cell(dashboard, 0, row, "COMPOSITE SCORE",
                 bgcolor=neutralColor, text_color=dashboardTextColor,
                 text_size=textSize,
                 tooltip="Rule-based score combining IWM trend, QQQ trend, relative strength, efficiency, volume and 10-year yield movement.")
            table.cell(dashboard, 1, row, str.tostring(compositeScore),
                 bgcolor=scoreBackground, text_color=color.black,
                 text_size=textSize,
                 tooltip="Cell color matches the overall regime: green bullish, pink choppy, red bearish. This score is not a probability.")
            row += 1

        if showIwmTrendRow
            table.cell(dashboard, 0, row, "IWM TREND",
                 bgcolor=neutralColor, text_color=dashboardTextColor,
                 text_size=textSize,
                 tooltip="Small-cap trend using price versus EMA 20 and EMA 20 versus EMA 50.")
            table.cell(dashboard, 1, row, iwmTrend,
                 bgcolor=iwmTrendColor, text_color=color.black,
                 text_size=textSize,
                 tooltip="UPTREND: price above EMA 20 and EMA 20 above EMA 50. DOWNTREND: both conditions reversed. MIXED: otherwise.")
            row += 1

        if showQqqTrendRow
            table.cell(dashboard, 0, row, "QQQ TREND",
                 bgcolor=neutralColor, text_color=dashboardTextColor,
                 text_size=textSize,
                 tooltip="Nasdaq trend using price versus EMA 20 and EMA 20 versus EMA 50.")
            table.cell(dashboard, 1, row, qqqTrend,
                 bgcolor=qqqTrendColor, text_color=color.black,
                 text_size=textSize,
                 tooltip="UPTREND: price above EMA 20 and EMA 20 above EMA 50. DOWNTREND: both conditions reversed. MIXED: otherwise.")
            row += 1

        if showRelativeStrengthRow
            rsText = (relativeStrength > 0 ? "+" : "") + str.tostring(relativeStrength, "#.##") + "%"
            table.cell(dashboard, 0, row, "IWM vs SPY",
                 bgcolor=neutralColor, text_color=dashboardTextColor,
                 text_size=textSize,
                 tooltip="Difference between IWM and SPY percentage returns over the relative-strength lookback. Positive means IWM outperformed SPY.")
            table.cell(dashboard, 1, row, rsText,
                 bgcolor=f_metricColor(relativeStrength), text_color=color.black,
                 text_size=textSize)
            row += 1

        if showEfficiencyRow
            table.cell(dashboard, 0, row, "DIRECTIONAL EFF.",
                 bgcolor=neutralColor, text_color=dashboardTextColor,
                 text_size=textSize,
                 tooltip="Measures how directly price moved during the lookback. Higher values indicate more directional movement.")
            table.cell(dashboard, 1, row, f_efficiency(iwmEfficiency),
                 bgcolor=iwmEfficiency >= chopEfficiencyThreshold ? bullColor : chopColor,
                 text_color=color.black, text_size=textSize)
            row += 1

        if showVolumeRow
            volColor = iwmVolRatio >= strongVolumeRatio ? bullColor : chopColor
            table.cell(dashboard, 0, row, "IWM VOLUME RATIO",
                 bgcolor=neutralColor, text_color=dashboardTextColor,
                 text_size=textSize,
                 tooltip="Current IWM volume divided by average volume.")
            table.cell(dashboard, 1, row, f_ratio(iwmVolRatio),
                 bgcolor=volColor, text_color=color.black, text_size=textSize)
            row += 1

        if showYieldRow
            yieldColor = yieldChangeBps >= yieldPressureBps ? bearColor :
                 yieldChangeBps <= -yieldPressureBps ? bullColor : chopColor
            table.cell(dashboard, 0, row, "10Y YIELD CHANGE",
                 bgcolor=neutralColor, text_color=dashboardTextColor,
                 text_size=textSize,
                 tooltip="Change in US 10-year Treasury yield over the configured lookback, in basis points.")
            table.cell(dashboard, 1, row, f_bps(yieldChangeBps),
                 bgcolor=yieldColor, text_color=color.black, text_size=textSize)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

enteredBullish = regime == "BULLISH" and regime[1] != "BULLISH"
enteredChoppy = regime == "CHOPPY" and regime[1] != "CHOPPY"
enteredBearish = regime == "BEARISH" and regime[1] != "BEARISH"

alertcondition(enableBullishAlert and enteredBullish,
     title="TBSMMR Bullish Regime",
     message="TBSMMR | TradeBee: Market regime changed to BULLISH.")

alertcondition(enableChoppyAlert and enteredChoppy,
     title="TBSMMR Choppy Regime",
     message="TBSMMR | TradeBee: Market regime changed to CHOPPY.")

alertcondition(enableBearishAlert and enteredBearish,
     title="TBSMMR Bearish Regime",
     message="TBSMMR | TradeBee: Market regime changed to BEARISH.")
````
