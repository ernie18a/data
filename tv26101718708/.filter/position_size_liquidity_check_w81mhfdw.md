# Position Size + Liquidity Check

- url: https://www.tradingview.com/script/w81mHfdw-Position-Size-Liquidity-Check/
- type: indicator
- pine_id: PUB;a7d37e35f3ff47a48c4b4f74eebef946
- version: 5.0

## Description

=============================================================================
 Position Size Calculator + Liquidity Check
 =============================================================================

 Position sizing math derived from:
   "Position Size Calculator" by Kousik_View (MPL 2.0)
   https://mozilla.org/MPL/2.0/

 WHAT IT DOES
   Combines two essential pre-trade checks into one indicator:
   1. Position sizing - computes quantity, stop loss price, and risk
      amount from your account capital, risk-per-trade %, and
      stop-loss %.
   2. Liquidity verdict - checks whether the stock can actually
      absorb that computed position size, by sampling 1m/3m/5m
      turnover across the chart bar.

   You enter your risk parameters ONCE. The indicator tells you
   exactly how many shares to buy AND whether the stock is liquid
   enough for that size. No need to type position size manually.

 POSITION SIZING FORMULA (Kousik_View)
   Risk Amount    = Account Capital * RPT% / 100
   SL per share   = current close * StopLoss% / 100
   Stop Loss price = current close - SL per share
   Quantity       = Risk Amount / SL per share
   Position Size  = Quantity * current close

   Equivalent simplification:
     Position Size = Account Capital * (RPT% / StopLoss%)
   For Acct=5L, RPT=0.5, SL=2.5  ->  Position = Rs.1L regardless of price.

 LIQUIDITY CHECK
   For each lower-TF bar (1, 3, or 5 min):
     turnover = close * volume
   Count how many inner bars have turnover < computed position size.
   If the count exceeds your threshold, the stock can't absorb your
   order without market impact - flagged red.

 INPUTS
   Risk:
     - Account Capital (Rs.)
     - Risk per trade %
     - Stop Loss %
   Liquidity:
     - Inner timeframe (1, 3, 5 min)
     - Bars below position size to flag illiquid
   Display:
     - Show table / status line toggles
     - Table position (9-way) and text size

 DISPLAY
   Two-column table with rows:
     Qty        <shares>
     SL price   Rs.<price>
     Risk       Rs.<amount>
     Pos size   Rs.<amount>
     Liquidity  <pct>% bars below   <- red row when illiquid
     Avg turn   Rs.<amount>
   Status line shows: Qty, SL price, Risk, % illiquid, Avg turnover.

 =============================================================================

## Source Code

````pine
//@version=6
// =============================================================================
// Position Size Calculator + Liquidity Check
// =============================================================================
//
// Position sizing math derived from:
//   "Position Size Calculator" by Kousik_View (MPL 2.0)
//   https://mozilla.org/MPL/2.0/
//
// WHAT IT DOES
//   Combines two essential pre-trade checks into one indicator:
//   1. Position sizing - computes quantity, stop loss price, and risk
//      amount from your account capital, risk-per-trade %, and
//      stop-loss %.
//   2. Liquidity verdict - checks whether the stock can actually
//      absorb that computed position size, by sampling 1m/3m/5m
//      turnover across the chart bar.
//
//   You enter your risk parameters ONCE. The indicator tells you
//   exactly how many shares to buy AND whether the stock is liquid
//   enough for that size. No need to type position size manually.
//
// POSITION SIZING FORMULA (Kousik_View)
//   Risk Amount    = Account Capital * RPT% / 100
//   SL per share   = current close * StopLoss% / 100
//   Stop Loss price = current close - SL per share
//   Quantity       = Risk Amount / SL per share
//   Position Size  = Quantity * current close
//
//   Equivalent simplification:
//     Position Size = Account Capital * (RPT% / StopLoss%)
//   For Acct=5L, RPT=0.5, SL=2.5  ->  Position = Rs.1L regardless of price.
//
// LIQUIDITY CHECK
//   For each lower-TF bar (1, 3, or 5 min) inside the rolling lookback
//   window (N most recent chart bars):
//     turnover = close * volume
//   Count the share of inner bars whose turnover < computed position size.
//   If that share exceeds your % threshold, the stock can't absorb your
//   order without market impact - flagged red.
//
//   Default lookback is 10 chart bars. On a DAILY chart that's ~2 weeks
//   of trading days, smoothing out single-day anomalies. Adjust via the
//   "Lookback (chart bars)" input: 10 = 2 weeks, 22 = ~1 month, 60 = ~3 months.
//
// INPUTS
//   Risk:
//     - Account Capital (Rs.)
//     - Risk per trade %
//     - Stop Loss %
//   Liquidity:
//     - Inner timeframe (1, 3, 5 min)
//     - Lookback (chart bars) - rolling window size
//     - Max % bars below size - illiquid threshold
//   Volatility:
//     - ADR length (bars) - window for Average Daily Range %
//   Display:
//     - Show table / status line toggles
//     - Table position (9-way) and text size
//
// DISPLAY
//   Two-column table with rows:
//     Qty        <shares>
//     SL price   Rs.<price>
//     Risk       Rs.<amount>
//     Pos size   Rs.<amount>
//     ADR        <pct>%               <- average daily range (volatility)
//     Liquidity  <pct>% bars below   <- red row when illiquid
//     Avg turn   Rs.<amount>
//   Status line shows: Qty, SL price, Risk, ADR%, % illiquid, Avg turnover.
//
// ADR (AVERAGE DAILY RANGE %)
//   ADR% = 100 * (SMA(high / low, length) - 1)
//   The average bar range as a % of price. ~3-5% is a typical swing-trade
//   sweet spot; very low ADR = sluggish, very high = whippy. Compute it on
//   a DAILY chart for a true "average daily range".
//
// =============================================================================

indicator("Position Size + Liquidity Check", shorttitle = "PSC+L", overlay = true, scale = scale.none)

// === Risk inputs ===
acctCap = input.float(500000, "Account Capital (Rs.)", minval = 0, step = 10000)
rpt     = input.float(0.5,    "Risk per trade %",      minval = 0.0, step = 0.1)
stpPer  = input.float(2.5,    "Stop Loss %",           minval = 0.0, step = 0.1)

// === Liquidity inputs ===
innerTF      = input.string("1", "Inner timeframe (minutes)", options = ["1", "3", "5"])
lookbackDays = input.int(10, "Lookback (chart bars)", minval = 1, maxval = 60,
     tooltip = "Number of chart bars to aggregate over. On a daily chart: 10 = ~2 weeks, 22 = ~1 month, 60 = ~3 months.")
maxBelowPct  = input.float(50.0, "Max % bars below size to allow trade", minval = 0.0, maxval = 100.0, step = 5.0,
     tooltip = "Flag illiquid if more than this % of inner-TF bars (across lookback window) had turnover below your position size.")

// === Volatility input ===
adrLen    = input.int(20, "ADR length (bars)", minval = 1,
     tooltip = "Average Daily Range %: mean of high/low ratio over this many chart bars. Use on a DAILY chart for true ADR. 20 = ~1 month.")
adrThresh = input.float(5.0, "ADR green/red threshold %", minval = 0.0, step = 0.5,
     tooltip = "ADR cell is green when ADR% >= this value (enough volatility), red below it.")

// === Display inputs ===
showTable      = input.bool(true, "Show on chart (table)")
showStatusLine = input.bool(true, "Show in status line")

posChoice = input.string("Bottom right", "Table position",
     options = ["Top left", "Top center", "Top right",
                "Middle left", "Middle center", "Middle right",
                "Bottom left", "Bottom center", "Bottom right"])

textSize = input.string("Small", "Text size",
     options = ["Tiny", "Small", "Normal", "Large"])

// === Position sizing math (aligned to syminfo.mintick) ===
riskAmount    = math.round(acctCap * rpt / 100, 2)
slPerShareRaw = close * stpPer / 100
slPrice       = math.round((close - slPerShareRaw) / syminfo.mintick) * syminfo.mintick
slPerShare    = close - slPrice
quantity      = slPerShare > 0 ? math.round(riskAmount / slPerShare, 0) : 0
positionSize  = quantity * close

// === Per-chart-bar liquidity stats (computed each chart bar) ===
// Pull raw turnover array for the inner-TF bars inside this chart bar:
turnoverArr = request.security_lower_tf(syminfo.tickerid, innerTF, close * volume)

// Determine if we should use fallback (chart TF is <= innerTF)
innerTFMinutes = str.tonumber(innerTF)
chartTFMinutes = timeframe.isseconds ? timeframe.multiplier / 60.0 :
                 timeframe.isminutes ? timeframe.multiplier * 1.0 :
                 timeframe.isdaily   ? timeframe.multiplier * 1440.0 :
                 timeframe.isweekly  ? timeframe.multiplier * 10080.0 :
                 timeframe.ismonthly ? timeframe.multiplier * 43200.0 : 1440.0

isFallback = chartTFMinutes <= innerTFMinutes
hasVolume  = not na(volume) and volume > 0

dailyBelow       = 0
dailyTotal       = 0
dailyTurnoverSum = 0.0

if isFallback
    // Use the chart's own bar as a single lower-TF bar (fallback for lower TFs)
    if hasVolume
        dailyTotal       := 1
        dailyTurnoverSum := close * volume
        if (close * volume) < positionSize
            dailyBelow   := 1
else
    if not na(turnoverArr) and array.size(turnoverArr) > 0
        for i = 0 to array.size(turnoverArr) - 1
            t = array.get(turnoverArr, i)
            if not na(t)
                dailyTurnoverSum := dailyTurnoverSum + t
                dailyTotal       := dailyTotal + 1
                if t < positionSize
                    dailyBelow   := dailyBelow + 1

// === Rolling N-bar aggregation ===
rollingBelow       = math.sum(dailyBelow,        lookbackDays)
rollingTotal       = math.sum(dailyTotal,        lookbackDays)
rollingTurnover    = math.sum(dailyTurnoverSum,  lookbackDays)

// Expected bars calculation for Indian markets (NSE/BSE) to adjust for thin sessions
chartIsDaily    = timeframe.isdaily
chartIsWeekly   = timeframe.isweekly
sessionBars     = 375.0 / innerTFMinutes // NSE/BSE session is 375 mins (9:15 - 15:30)
defaultExpected = chartIsDaily  ? sessionBars :
                  chartIsWeekly ? sessionBars * 5 : 1.0

expectedMaxBars      = math.max(ta.highest(dailyTotal, lookbackDays), defaultExpected)
adjustedRollingTotal = isFallback ? rollingTotal : expectedMaxBars * lookbackDays
missingBarsCount     = isFallback ? 0 : math.max(0, adjustedRollingTotal - rollingTotal)
adjustedRollingBelow = isFallback ? rollingBelow : rollingBelow + missingBarsCount

belowPct    = adjustedRollingTotal > 0 ? (adjustedRollingBelow / adjustedRollingTotal) * 100 : 0
avgTurnover = rollingTotal > 0 ? rollingTurnover / rollingTotal : 0
avgDailyTurnover = lookbackDays > 0 ? rollingTurnover / lookbackDays : 0
illiquid    = hasVolume and (belowPct >= maxBelowPct)

// === Average Daily Range (%) ===
adrPct = low > 0 ? 100 * (ta.sma(high / low, adrLen) - 1) : 0

// === Helpers ===
getPos(s) =>
    s == "Top left"       ? position.top_left       :
     s == "Top center"     ? position.top_center     :
     s == "Top right"      ? position.top_right      :
     s == "Middle left"    ? position.middle_left    :
     s == "Middle center"  ? position.middle_center  :
     s == "Middle right"   ? position.middle_right   :
     s == "Bottom left"    ? position.bottom_left    :
     s == "Bottom center"  ? position.bottom_center  :
                             position.bottom_right

getSize(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Normal" ? size.normal :
                     size.large

fmtMoney(n) =>
    n >= 1e7 ? str.tostring(n / 1e7, "#.##") + "Cr" :n >= 1e5 ? str.tostring(n / 1e5, "#.##") + "L"  :n >= 1e3 ? str.tostring(n / 1e3, "#.#")  + "k"  : str.tostring(n, "#")

// === Table (8 rows x 2 columns) ===
var table tbl = table.new(getPos(posChoice), 2, 8, border_color = color.rgb(54, 58, 69), border_width = 1)

if showTable and barstate.islast
    // Premium dark theme palette
    labelBg   = color.rgb(30, 34, 45)       // Slate dark gray
    valueBg   = color.rgb(42, 46, 57)       // Lighter slate gray
    greenBg   = color.rgb(8, 153, 129)      // TradingView green
    redBg     = color.rgb(247, 82, 95)      // TradingView red
    orangeBg  = color.rgb(214, 116, 36)     // Warning orange
    sz      = getSize(textSize)

    table.cell(tbl, 0, 0, "Qty",       text_color = color.white, bgcolor = labelBg, text_size = sz)
    table.cell(tbl, 1, 0, str.tostring(quantity),
         text_color = color.white, bgcolor = valueBg, text_size = sz)

    table.cell(tbl, 0, 1, "SL price",  text_color = color.white, bgcolor = labelBg, text_size = sz)
    table.cell(tbl, 1, 1, "Rs." + str.tostring(slPrice, format.mintick),
         text_color = color.white, bgcolor = valueBg, text_size = sz)

    table.cell(tbl, 0, 2, "Risk",      text_color = color.white, bgcolor = labelBg, text_size = sz)
    table.cell(tbl, 1, 2, "Rs." + fmtMoney(riskAmount),
         text_color = color.white, bgcolor = valueBg, text_size = sz)

    posExceeded = positionSize > acctCap
    table.cell(tbl, 0, 3, "Pos size",  text_color = color.white, bgcolor = labelBg, text_size = sz)
    table.cell(tbl, 1, 3, "Rs." + fmtMoney(positionSize),
         text_color = color.white, bgcolor = posExceeded ? orangeBg : valueBg, text_size = sz)

    adrLabel = "ADR " + str.tostring(adrLen) + "d"
    table.cell(tbl, 0, 4, adrLabel, text_color = color.white, bgcolor = labelBg, text_size = sz)
    table.cell(tbl, 1, 4, str.tostring(adrPct, "#.##") + "%",
         text_color = color.white,
         bgcolor    = adrPct >= adrThresh ? greenBg : redBg,
         text_size  = sz)

    liqLabel = "Liquidity " + str.tostring(lookbackDays) + "d"
    table.cell(tbl, 0, 5, liqLabel, text_color = color.white, bgcolor = labelBg, text_size = sz)
    liqValue = hasVolume ? str.tostring(belowPct, "#.#") + "% below" : "No Vol Data"
    table.cell(tbl, 1, 5, liqValue,
         text_color = color.white,
         bgcolor    = not hasVolume ? color.gray : illiquid ? redBg : valueBg,
         text_size  = sz)

    avgInnerLabel = "Avg " + innerTF + "m turn"
    table.cell(tbl, 0, 6, avgInnerLabel, text_color = color.white, bgcolor = labelBg, text_size = sz)
    avgInnerValue = hasVolume ? "Rs." + fmtMoney(avgTurnover) : "No Vol Data"
    table.cell(tbl, 1, 6, avgInnerValue,
         text_color = color.white, bgcolor = valueBg, text_size = sz)

    chartBarLabel = timeframe.isdaily ? "Avg Daily turn" : timeframe.isweekly ? "Avg Weekly turn" : "Avg Bar turn"
    table.cell(tbl, 0, 7, chartBarLabel, text_color = color.white, bgcolor = labelBg, text_size = sz)
    avgDailyValue = hasVolume ? "Rs." + fmtMoney(avgDailyTurnover) : "No Vol Data"
    table.cell(tbl, 1, 7, avgDailyValue,
         text_color = color.white, bgcolor = valueBg, text_size = sz)

// === Status line plots ===
plot(showStatusLine ? quantity    : na, title = "Quantity",     color = color.white,
     display = display.status_line)
plot(showStatusLine ? slPrice     : na, title = "SL price",     color = color.yellow,
     display = display.status_line)
plot(showStatusLine ? riskAmount  : na, title = "Risk amount",  color = color.red,
     display = display.status_line)
plot(showStatusLine ? adrPct      : na, title = "ADR %",        color = adrPct >= adrThresh ? color.green : color.red,
     display = display.status_line)
plot(showStatusLine ? belowPct    : na, title = "Pct illiquid", color = illiquid ? color.red : color.gray,
     display = display.status_line)
plot(showStatusLine ? avgTurnover : na, title = "Avg inner turnover", color = color.gray,
     display = display.status_line)

alertcondition(illiquid, "Cannot absorb position size", "Stock too thin for computed position size")
````
