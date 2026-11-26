# Central Pivot Range (CPR) with Signals

- url: https://www.tradingview.com/script/izSwZfNX-Central-Pivot-Range-CPR-with-Signals/
- type: indicator
- pine_id: PUB;f3c483a77d1d467b960079729601ac61
- version: 2.0

## Description

Central Pivot Range
The Central Pivot Range (CPR) is an indicator to identify key price points to set up trades. CPR is beneficial for intraday trading.

Before you understand the CPR, it is important for you to know the Support and Resistance; I’d suggest you read through this chapter to know what more about Support and Resistance before proceeding further.

The CPR consists of three components –

Pivot
Bottom Central Pivot (BC)
Top Central Pivot (TC)
These are derived out of the underlying’s High, Low, and Close calculations –

Pivot = (High + Low + Close)/3

Bottom CPR = (High + Low)/ 2

Top CPR = (Pivot – BC) + Pivot

Spend a minute to understand the formula. These are simple averages and manipulation to the averages. In any technical indicator, the moment you see averages, you need to associate the indicator to the underlying trend.

The CPR does just this, i.e. helps the trader identify key price points and the associated trend around these price points.

Today’s CPR values act as the reference for tomorrow’s trading. We will get back to this in a bit.

On Kite search for ‘Pivot’ in studies, and you’ll find the CPR indicator –



I’m looking 15-minute chart of M&M here. Once you load the CPR, the CPR loads as three horizontal lines, as seen below.



One thing that stands out is the varying width of the CPR. I’ve marked three points on the chart to discuss this.

I want you to look at the first arrow starting from left, ignore the CPR but look at the price action itself. Remember this is the 15-minute chart, and it is quite clear that the day started with a small green candle with not much movement through the day. The open and close were close to each other.

Whenever, we have a sideways movement, the next day’s CPR narrow ranged, this is exactly what we observe on the next day. Now the 2nd day itself was trending day. Hence the CPR for 3rd day was a wide-ranged one.

So the point is –

If today is a narrow range day, tomorrow’s CPR will be a narrow ranged CPR.
If today is a trending day, tomorrow’s CPR is a wide-ranged one. Higher the trend, wider is the CPR.
Alright, so how do we use the CPR? Well, this is quite straightforward –

Bullish outlook, look for buying opportunities when the current market price is higher than ‘Top central pivot’ (TC).

Let me elaborate. Assume a stock has rallied for a bit. The current market price is higher than the TC, and you are looking for an opportunity to set up a buy trade.

You can now wait till the stock arrests its rally and retraces back to the TC line.

I’ve highlighted a possible opportunity here –



From a price action perspective, when the current market price is higher than the TC, it indicates that the traders are willing to buy even though the average price is higher.  Hence, it would help if you are looking for buying opportunities. Remember, when CMP is higher than TC, the TC now acts as a support line.

Likewise, when the stock or the index is trading lesser than the “Bottom Central Pivot’ (BC). When the current market price is less than that BC, it implies that there is bearishness in the market, hence look for selling opportunities.

Again, look for a price pull back to the BC line before initiating a fresh short.



You can even trade the stock while it is within the CPR. Trading while the stock price is within the CPR is like a range trade.

You buy when the stock is at BC, with TC as a target and sell (fresh short) when the stock is at the TC with an expectation that the price declines to BC soon.

Of course, I know many traders who prefer not to trade the range and prefer to trade only the pullbacks. I too would prefer to use CPR only to trade the pullbacks.

Lastly, here is something that you need to be aware of when trading the CPR.

When you plot the EOD CPR, the previous month’s OHLC is referenced.
Previous week’s OHLC is a reference when you plot CPR for 30mins and 1-hour candles.
Previous day’s OHLC is referenced when you plot CPR for 1, 3, 5, 10, and 15 minutes candles.
Happy trading.

Key Takeaways from this chapter
You can trade from the chart by selecting the trade button.
The trade button is a floating window which you can place anywhere on the chart.
The candle pattern helps identify the candlestick patterns, use this to reconfirm the pattern.
CPR helps you identify the S&R pattern
It is considered bullish if the current market price is higher than the TC line.
It is considered bearish if the current market price below the BC line.

## Source Code

````pine
//@version=6
indicator("Universal Scanner Card", overlay=true, max_labels_count=50)

// ============================================================
// INPUTS
// ============================================================
grpRegime = "Regime / Setup"
benchmarkSym  = input.symbol("NSE:NIFTY", "Benchmark", group=grpRegime)
smaLen        = input.int(100, "Regime SMA Length", group=grpRegime)
rsLen         = input.int(20, "RS Lookback (~4 weeks)", group=grpRegime)

grpCPR = "CPR"
showCPR       = input.bool(true, "Show CPR Lines", group=grpCPR)
narrowCprPct  = input.float(0.5, "Narrow CPR Threshold (%)", group=grpCPR)

grpPOC = "Value / POC Proxy"
pocLen        = input.int(20, "POC Proxy Lookback (bars)", group=grpPOC)

grpQuality = "Quality Score Weights"
wRegime  = input.float(15, "Weight: Regime Bullish", group=grpQuality)
wTrend   = input.float(10, "Weight: Price > SMA100", group=grpQuality)
wRS      = input.float(20, "Weight: RS Rising", group=grpQuality)
wRSRank  = input.float(20, "Weight: RS Rank (scaled)", group=grpQuality)
wOBV     = input.float(10, "Weight: OBV Rising", group=grpQuality)
wVWMA    = input.float(10, "Weight: Price > VWMA20", group=grpQuality)
wValueUp = input.float(15, "Weight: Value Migration Up", group=grpQuality)

// ============================================================
// PRIOR DAY HLC (for CPR) - works regardless of chart timeframe
// ============================================================
pDH = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pDL = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)
pDC = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)

pivot = (pDH + pDL + pDC) / 3
bc    = (pDH + pDL) / 2
tc    = (pivot - bc) + pivot
cprTop    = math.max(tc, bc)
cprBottom = math.min(tc, bc)
cprWidthPct = math.abs(tc - bc) / pivot * 100
cprNarrow   = cprWidthPct <= narrowCprPct

// ============================================================
// REGIME - benchmark vs its own SMA
// ============================================================
benchClose = request.security(benchmarkSym, timeframe.period, close)
benchSma   = request.security(benchmarkSym, timeframe.period, ta.sma(close, smaLen))
regimeBullish = benchClose > benchSma

// ============================================================
// TREND / RS / MOMENTUM
// ============================================================
smaClose   = ta.sma(close, smaLen)
priceAboveSma = close > smaClose

rsRatio    = close / benchClose
rsRatioSma = ta.sma(rsRatio, rsLen)
rsRising   = rsRatio > rsRatioSma
rsMomPct   = (rsRatio - rsRatio[rsLen]) / rsRatio[rsLen] * 100
rsRankProxy = ta.percentrank(rsRatio, 100)   // 0-100, proxy only (single-symbol, not full universe)

rsiVal = ta.rsi(close, 14)

obvVal    = ta.obv
obvRising = obvVal > obvVal[5]

vwma20 = ta.vwma(close, 20)
priceAboveVwma = close > vwma20

ret        = ta.change(close) / close[1] * 100
stdevRet   = ta.stdev(ret, 20)

relVol = volume / ta.sma(volume, 20)

// ============================================================
// POC PROXY (volume-weighted avg price over lookback)
// ============================================================
pocProxy     = ta.vwma(close, pocLen)
prevPocProxy = pocProxy[pocLen]
pocShiftPct  = (pocProxy - prevPocProxy) / prevPocProxy * 100
valueUp      = pocProxy > prevPocProxy

// ============================================================
// SETUP EVIDENCE (Leader / Improver / Laggard)
// ============================================================
c1 = regimeBullish
c2 = priceAboveSma
c3 = rsRising
c4 = obvRising
c5 = priceAboveVwma
c6 = valueUp
c7 = relVol >= 0.5 and relVol <= 1.5

evidenceCount = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) + (c5 ? 1 : 0) + (c6 ? 1 : 0) + (c7 ? 1 : 0)
evidenceTotal = 7

setupLabel = evidenceCount >= 6 ? "LEADER" : evidenceCount >= 4 ? "IMPROVER" : "LAGGARD"

// ============================================================
// TRIGGER - inside CPR = armed, breakout close above TC = confirmed
// ============================================================
insideCpr       = close >= cprBottom and close <= cprTop
triggerConfirmed = ta.crossover(close, cprTop)
triggerArmed      = setupLabel != "LAGGARD" and insideCpr and not triggerConfirmed

triggerLabel = triggerConfirmed ? "CONFIRMED" : triggerArmed ? "ARMED" : "IDLE"

// ============================================================
// QUALITY SCORE (0-100, weights configurable above)
// ============================================================
maxWeight = wRegime + wTrend + wRS + wRSRank + wOBV + wVWMA + wValueUp
rawScore = (regimeBullish ? wRegime : 0) +
           (priceAboveSma ? wTrend : 0) +
           (rsRising ? wRS : 0) +
           (rsRankProxy / 100 * wRSRank) +
           (obvRising ? wOBV : 0) +
           (priceAboveVwma ? wVWMA : 0) +
           (valueUp ? wValueUp : 0)
qualityScore = maxWeight > 0 ? rawScore / maxWeight * 100 : na

// ============================================================
// PLOTS
// ============================================================
plot(showCPR ? tc : na, "TC", color=color.new(color.red, 0), linewidth=1)
plot(showCPR ? pivot : na, "Pivot", color=color.new(color.white, 0), linewidth=1)
plot(showCPR ? bc : na, "BC", color=color.new(color.green, 0), linewidth=1)
plot(smaClose, "SMA100", color=color.new(color.aqua, 40))
plot(vwma20, "VWMA20", color=color.new(color.yellow, 40))

// ============================================================
// TABLE (mirrors the scanner card layout)
// ============================================================
var table t = table.new(position.top_right, 2, 14, border_width=1)

regimeColor  = regimeBullish ? color.lime : color.red
setupColor   = setupLabel == "LEADER" ? color.orange : setupLabel == "IMPROVER" ? color.yellow : color.gray
triggerColor = triggerLabel == "CONFIRMED" ? color.lime : triggerLabel == "ARMED" ? color.orange : color.gray

if barstate.islast
    table.cell(t, 0, 0, "REGIME", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 0, regimeBullish ? "BULLISH" : "BEARISH", text_color=regimeColor, text_size=size.small)

    table.cell(t, 0, 1, "SETUP", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, setupLabel + " " + str.tostring(evidenceCount) + "/" + str.tostring(evidenceTotal), text_color=setupColor, text_size=size.small)

    table.cell(t, 0, 2, "TRIGGER", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 2, triggerLabel, text_color=triggerColor, text_size=size.small)

    table.cell(t, 0, 3, "CPR", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 3, (cprNarrow ? "NARROW " : "") + str.tostring(cprWidthPct, "#.###") + "%", text_color=color.white, text_size=size.small)

    table.cell(t, 0, 4, "TC / Pivot / BC", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(tc, "#.##") + " / " + str.tostring(pivot, "#.##") + " / " + str.tostring(bc, "#.##"), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 5, "POC Proxy", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 5, str.tostring(pocProxy, "#.##"), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 6, "Value Shift", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 6, str.tostring(pocShiftPct, "#.##") + "% " + (valueUp ? "UP" : "DOWN"), text_color=valueUp ? color.lime : color.red, text_size=size.small)

    table.cell(t, 0, 7, "RS Rank (proxy)", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 7, str.tostring(rsRankProxy, "#.#") + "/100", text_color=color.white, text_size=size.small)

    table.cell(t, 0, 8, "RS Mom", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 8, str.tostring(rsMomPct, "#.##") + "%", text_color=color.white, text_size=size.small)

    table.cell(t, 0, 9, "RSI(14)", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 9, str.tostring(rsiVal, "#.#"), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 10, "OBV", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 10, obvRising ? "Rising" : "Falling", text_color=obvRising ? color.lime : color.red, text_size=size.small)

    table.cell(t, 0, 11, "StdDev(20)", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 11, str.tostring(stdevRet, "#.##") + "%", text_color=color.white, text_size=size.small)

    table.cell(t, 0, 12, "Rel Vol", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 12, str.tostring(relVol, "#.##") + "x", text_color=color.white, text_size=size.small)

    table.cell(t, 0, 13, "QUALITY / 100", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 13, str.tostring(qualityScore, "#.#"), text_color=color.new(color.aqua, 0), text_size=size.small)

// ============================================================
// TRIGGER MARKERS ON CHART
// ============================================================
plotshape(triggerConfirmed, title="Trigger Confirmed", location=location.belowbar, style=shape.triangleup, color=color.lime, size=size.small)
````
