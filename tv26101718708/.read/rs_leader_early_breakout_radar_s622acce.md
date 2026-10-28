# RS Leader - Early Breakout Radar

- url: https://www.tradingview.com/script/S622AcCe-RS-Leader-Early-Breakout-Radar/
- type: indicator
- pine_id: PUB;19ca34ac65cb43548f32f4b98b7b4bcc
- version: 1.0

## Description

RS Leader - Early Breakout Radar identifies stocks demonstrating exceptional relative strength before a conventional price breakout occurs.

The indicator compares the current symbol with a selectable market benchmark, using SPY by default. It searches for situations in which the relative-strength ratio is near a long-term high while the stock remains in a tight consolidation beneath its previous price high. This combination can help identify securities outperforming the broader market before that leadership becomes obvious from price alone.

RS Leader is different from the RSI oscillator. Its relative-strength calculation is:

Stock Price ÷ Benchmark Price

RS Leader Score

Each stock receives a dynamic score from 1 to 100:

• Relative-strength leadership: 40 points
• Proximity to the breakout level: 20 points
• Price-range contraction: 15 points
• Moving-average structure: 15 points
• Volume behavior: 10 points

A default minimum score of 70 is required before an RS Leader signal can appear. All requirements and scoring thresholds can be adjusted in the indicator settings.

Signal Interpretation

• Blue RS LEADER label: Relative strength is near a long-term high while price remains tightly consolidated below resistance.

• Blue line: The nearby price level that must be exceeded for a potential breakout.

• Green BREAKOUT label: Price closed above the prior resistance level following an active RS Leader setup.

• Blue background shading: Optional highlighting of bars that currently satisfy the complete setup.

Dashboard Colors

• Green: Condition is favorable or confirmed.

• Blue: An active RS Leader setup meets the minimum score.

• Orange: Condition is developing, neutral or requires caution.

• Red: Condition is not currently satisfied.

The dashboard displays the current RS Leader Score, relative-strength status, distance from the price high, consolidation width, moving-average alignment, relative volume and selected benchmark.

The indicator uses confirmed closing-bar information and does not intentionally use future data. Signals can still fail, and historical relationships do not guarantee future results. Relative strength may deteriorate, apparent breakouts may reverse, and market or company-specific events can materially affect price behavior.

RS Leader is provided solely for educational and informational purposes. It does not constitute investment advice, a recommendation to buy or sell any security, or a guarantee of future performance. Users should independently evaluate market conditions, liquidity, earnings dates, volatility and personal risk tolerance before making any financial decision.

## Source Code

````pine
//@version=6
indicator("RS Leader - Early Breakout Radar", shorttitle="RSLead", overlay=true, max_labels_count=300, max_lines_count=100)

// RS Leader looks for a stock whose relative-strength line is reaching a
// long-term high while price is still consolidating below its own high.
// Relative strength here means price performance versus a benchmark. It is
// not the RSI oscillator. Signals are confirmed only after the bar closes.

//=============================================================================
// INPUTS
//=============================================================================
string GROUP_RS = "Relative Strength"
string GROUP_SETUP = "Pre-Breakout Setup"
string GROUP_FILTERS = "Optional Confirmation Filters"
string GROUP_DISPLAY = "Display"

benchmarkSymbol = input.symbol("AMEX:SPY", "Market benchmark", group=GROUP_RS)
rsLookback = input.int(252, "RS high lookback (bars)", minval=50, maxval=500, group=GROUP_RS)
rsHighTolerance = input.float(0.50, "RS high tolerance (%)", minval=0.0, maxval=5.0, step=0.10, group=GROUP_RS)

priceLookback = input.int(252, "Price high lookback (bars)", minval=50, maxval=500, group=GROUP_SETUP)
maximumDistanceFromHigh = input.float(10.0, "Maximum distance below price high (%)", minval=1.0, maxval=30.0, step=0.5, group=GROUP_SETUP)
tightRangeBars = input.int(10, "Tight-range length", minval=3, maxval=30, group=GROUP_SETUP)
maximumRangeWidth = input.float(8.0, "Maximum tight-range width (%)", minval=1.0, maxval=25.0, step=0.5, group=GROUP_SETUP)
minimumLeaderScore = input.int(70, "Minimum RS Leader score", minval=50, maxval=95, group=GROUP_SETUP)

useTrendFilter = input.bool(true, "Require bullish MA alignment", group=GROUP_FILTERS)
fastMaLength = input.int(20, "Fast moving average", minval=5, maxval=100, group=GROUP_FILTERS)
mediumMaLength = input.int(50, "Medium moving average", minval=10, maxval=200, group=GROUP_FILTERS)
slowMaLength = input.int(200, "Slow moving average", minval=50, maxval=400, group=GROUP_FILTERS)
useVolumeDryUp = input.bool(false, "Require consolidation volume dry-up", group=GROUP_FILTERS)
volumeLength = input.int(50, "Average volume length", minval=10, maxval=200, group=GROUP_FILTERS)
maximumRelativeVolume = input.float(0.90, "Maximum consolidation relative volume", minval=0.20, maxval=2.0, step=0.05, group=GROUP_FILTERS)

showDashboard = input.bool(true, "Show status dashboard", group=GROUP_DISPLAY)
showResistance = input.bool(true, "Show nearby breakout level", group=GROUP_DISPLAY)
showLeaderMarkers = input.bool(true, "Show RS Leader signals", group=GROUP_DISPLAY)
showEarlyStateDots = input.bool(false, "Show every qualifying bar", group=GROUP_DISPLAY)
highlightActiveSetup = input.bool(false, "Shade active setup bars", group=GROUP_DISPLAY)

//=============================================================================
// STANDARD-CANDLE DATA
//=============================================================================
standardTicker = ticker.new(syminfo.prefix, syminfo.ticker)
[stockOpen, stockHigh, stockLow, stockClose, stockVolume] = request.security(
     standardTicker,
     timeframe.period,
     [open, high, low, close, volume],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

benchmarkClose = request.security(
     benchmarkSymbol,
     timeframe.period,
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

//=============================================================================
// RELATIVE-STRENGTH LEADERSHIP
//=============================================================================
float rsRatio = benchmarkClose > 0 ? stockClose / benchmarkClose : na
float rsLookbackHigh = ta.highest(rsRatio, rsLookback)
float rsThreshold = rsLookbackHigh * (1.0 - rsHighTolerance / 100.0)
bool rsAtNewHigh = not na(rsRatio) and not na(rsThreshold) and rsRatio >= rsThreshold

float pricePriorHigh = ta.highest(stockHigh, priceLookback)[1]
float distanceFromPriceHigh = pricePriorHigh > 0 ? (pricePriorHigh - stockClose) / pricePriorHigh * 100.0 : na
bool priceHasNotBrokenOut = not na(pricePriorHigh) and stockClose < pricePriorHigh
bool priceIsCloseEnough = not na(distanceFromPriceHigh) and distanceFromPriceHigh >= 0 and distanceFromPriceHigh <= maximumDistanceFromHigh

//=============================================================================
// CONSOLIDATION AND CONFIRMATION FILTERS
//=============================================================================
float rangeHigh = ta.highest(stockHigh, tightRangeBars)
float rangeLow = ta.lowest(stockLow, tightRangeBars)
float rangeWidthPercent = stockClose > 0 ? (rangeHigh - rangeLow) / stockClose * 100.0 : na
bool tightRangePass = not na(rangeWidthPercent) and rangeWidthPercent <= maximumRangeWidth

float fastMa = ta.sma(stockClose, fastMaLength)
float mediumMa = ta.sma(stockClose, mediumMaLength)
float slowMa = ta.sma(stockClose, slowMaLength)
bool bullishMaAlignment = stockClose > fastMa and fastMa > mediumMa and mediumMa > slowMa and mediumMa > mediumMa[5]
bool trendPass = not useTrendFilter or bullishMaAlignment

float averageVolume = ta.sma(stockVolume, volumeLength)
float relativeVolume = averageVolume > 0 ? stockVolume / averageVolume : na
bool volumeDryUpPass = not useVolumeDryUp or na(relativeVolume) or relativeVolume <= maximumRelativeVolume

//=============================================================================
// RS LEADER SCORE (1-100)
// RS leadership: 40 points, price location: 20, contraction: 15,
// MA structure: 15, and volume behavior: 10.
//=============================================================================
f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

float rsPercentOfHigh = rsLookbackHigh > 0 ? rsRatio / rsLookbackHigh * 100.0 : na
float rsScoreComponent = na(rsPercentOfHigh) ? 0.0 : f_clamp((rsPercentOfHigh - 90.0) / 10.0 * 40.0, 0.0, 40.0)
float priceScoreComponent = na(distanceFromPriceHigh) or distanceFromPriceHigh < 0 ? 0.0 : f_clamp((1.0 - distanceFromPriceHigh / maximumDistanceFromHigh) * 20.0, 0.0, 20.0)
float rangeScoreComponent = na(rangeWidthPercent) ? 0.0 : f_clamp((maximumRangeWidth * 1.5 - rangeWidthPercent) / maximumRangeWidth * 15.0, 0.0, 15.0)
float trendScoreComponent = (stockClose > fastMa ? 5.0 : 0.0) + (fastMa > mediumMa ? 4.0 : 0.0) + (mediumMa > slowMa ? 4.0 : 0.0) + (mediumMa > mediumMa[5] ? 2.0 : 0.0)
float volumeScoreComponent = na(relativeVolume) ? 5.0 : relativeVolume <= 0.75 ? 10.0 : relativeVolume <= 1.0 ? 7.0 : relativeVolume <= 1.25 ? 3.0 : 0.0
float rawLeaderScore = rsScoreComponent + priceScoreComponent + rangeScoreComponent + trendScoreComponent + volumeScoreComponent
int rsLeaderScore = int(math.round(f_clamp(rawLeaderScore, 1.0, 100.0)))

bool enoughHistory = not na(pricePriorHigh) and not na(rsLookbackHigh) and not na(slowMa)
bool scorePass = rsLeaderScore >= minimumLeaderScore
bool rsLeaderSetup = barstate.isconfirmed and enoughHistory and rsAtNewHigh and priceHasNotBrokenOut and priceIsCloseEnough and tightRangePass and trendPass and volumeDryUpPass and scorePass
bool newRsLeaderSignal = rsLeaderSetup and not rsLeaderSetup[1]
bool priceBreakout = barstate.isconfirmed and not na(pricePriorHigh) and stockClose > pricePriorHigh and stockClose[1] <= pricePriorHigh[1]

// A transparent 0/1 series is included so the script can be used as a
// condition in TradingView alerts and compatible screeners.
plot(rsLeaderSetup ? 1 : 0, "RS Leader Setup", display=display.none)
plot(newRsLeaderSignal ? 1 : 0, "New RS Leader Signal", display=display.none)
plot(priceBreakout ? 1 : 0, "Price Breakout", display=display.none)
plot(rsLeaderScore, "RS Leader Score", display=display.none)

//=============================================================================
// CHART DISPLAY
//=============================================================================
color leaderBlue = color.rgb(35, 110, 255)
color breakoutGreen = color.rgb(0, 180, 105)
color warningOrange = color.rgb(245, 155, 25)
color failRed = color.rgb(215, 55, 70)
color neutralGray = color.rgb(65, 72, 88)
color panelColor = color.rgb(35, 41, 54)

plot(showResistance and (rsLeaderSetup or rsLeaderSetup[1]) ? pricePriorHigh : na, "Breakout Level", color=leaderBlue, linewidth=2, style=plot.style_linebr)

if showLeaderMarkers and newRsLeaderSignal
    label.new(bar_index, stockLow, "RS LEADER\n" + str.tostring(rsLeaderScore) + "/100", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=leaderBlue, textcolor=color.white, size=size.small)

plotshape(showEarlyStateDots and rsLeaderSetup, title="RS Leader Active", style=shape.circle, location=location.belowbar, color=leaderBlue, size=size.tiny)
plotshape(priceBreakout and rsLeaderSetup[1], title="RS Leader Breakout", style=shape.labelup, location=location.belowbar, color=breakoutGreen, text="BREAKOUT", textcolor=color.white, size=size.small)

bgcolor(highlightActiveSetup and rsLeaderSetup ? color.new(leaderBlue, 90) : na, title="Active RS Leader Highlight")

//=============================================================================
// DASHBOARD
//=============================================================================
f_yesNo(bool condition) =>
    condition ? "YES" : "NO"

f_passColor(bool condition) =>
    condition ? breakoutGreen : failRed

f_number(float value, string pattern) =>
    na(value) ? "N/A" : str.tostring(value, pattern)

var table dashboard = table.new(position.top_right, 2, 9, border_width=1, border_color=color.rgb(95, 101, 118))

if barstate.islast
    color clearColor = color.new(color.black, 100)
    color activeHeader = rsLeaderSetup ? leaderBlue : neutralGray

    table.cell(dashboard, 0, 0, showDashboard ? "RS LEADER" : "", bgcolor=showDashboard ? activeHeader : clearColor, text_color=color.white, text_size=size.large)
    table.cell(dashboard, 1, 0, showDashboard ? (rsLeaderSetup ? "ACTIVE" : "WAIT") : "", bgcolor=showDashboard ? activeHeader : clearColor, text_color=color.white, text_size=size.large)

    color scoreColor = rsLeaderScore >= 80 ? breakoutGreen : rsLeaderScore >= minimumLeaderScore ? leaderBlue : rsLeaderScore >= 50 ? warningOrange : failRed
    table.cell(dashboard, 0, 1, showDashboard ? "LEADER SCORE" : "", bgcolor=showDashboard ? panelColor : clearColor, text_color=color.white, text_size=size.large)
    table.cell(dashboard, 1, 1, showDashboard ? str.tostring(rsLeaderScore) + "/100" : "", bgcolor=showDashboard ? scoreColor : clearColor, text_color=color.white, text_size=size.large)

    table.cell(dashboard, 0, 2, showDashboard ? "RS at long-term high" : "", bgcolor=showDashboard ? panelColor : clearColor, text_color=color.white)
    table.cell(dashboard, 1, 2, showDashboard ? f_yesNo(rsAtNewHigh) : "", bgcolor=showDashboard ? f_passColor(rsAtNewHigh) : clearColor, text_color=color.white)

    table.cell(dashboard, 0, 3, showDashboard ? "Price below breakout" : "", bgcolor=showDashboard ? panelColor : clearColor, text_color=color.white)
    table.cell(dashboard, 1, 3, showDashboard ? f_yesNo(priceHasNotBrokenOut) : "", bgcolor=showDashboard ? f_passColor(priceHasNotBrokenOut) : clearColor, text_color=color.white)

    table.cell(dashboard, 0, 4, showDashboard ? "Distance from high" : "", bgcolor=showDashboard ? panelColor : clearColor, text_color=color.white)
    table.cell(dashboard, 1, 4, showDashboard ? f_number(distanceFromPriceHigh, "#.##") + "%" : "", bgcolor=showDashboard ? (priceIsCloseEnough ? breakoutGreen : warningOrange) : clearColor, text_color=color.white)

    table.cell(dashboard, 0, 5, showDashboard ? "Range width" : "", bgcolor=showDashboard ? panelColor : clearColor, text_color=color.white)
    table.cell(dashboard, 1, 5, showDashboard ? f_number(rangeWidthPercent, "#.##") + "%" : "", bgcolor=showDashboard ? f_passColor(tightRangePass) : clearColor, text_color=color.white)

    table.cell(dashboard, 0, 6, showDashboard ? "Bullish MA alignment" : "", bgcolor=showDashboard ? panelColor : clearColor, text_color=color.white)
    table.cell(dashboard, 1, 6, showDashboard ? f_yesNo(bullishMaAlignment) : "", bgcolor=showDashboard ? f_passColor(bullishMaAlignment) : clearColor, text_color=color.white)

    table.cell(dashboard, 0, 7, showDashboard ? "Relative volume" : "", bgcolor=showDashboard ? panelColor : clearColor, text_color=color.white)
    table.cell(dashboard, 1, 7, showDashboard ? f_number(relativeVolume, "#.##") + "x" : "", bgcolor=showDashboard ? (na(relativeVolume) ? neutralGray : relativeVolume <= 1 ? breakoutGreen : warningOrange) : clearColor, text_color=color.white)

    table.cell(dashboard, 0, 8, showDashboard ? "Benchmark" : "", bgcolor=showDashboard ? panelColor : clearColor, text_color=color.white)
    table.cell(dashboard, 1, 8, showDashboard ? benchmarkSymbol : "", bgcolor=showDashboard ? neutralGray : clearColor, text_color=color.white)

//=============================================================================
// ALERTS
//=============================================================================
alertcondition(newRsLeaderSignal, title="New RS Leader", message="RS Leader detected early relative-strength leadership on {{ticker}} {{interval}}.")
alertcondition(priceBreakout and rsLeaderSetup[1], title="RS Leader Breakout", message="{{ticker}} broke above its prior high after an RS Leader setup on {{interval}}.")

// Educational and informational use only. This indicator does not predict
// future returns and is not financial advice. Always evaluate liquidity,
// earnings dates, market conditions and risk before making a trade.
````
