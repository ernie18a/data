# Adaptive Daytrade Signal

- url: https://www.tradingview.com/script/cHcxCVbT/
- type: indicator
- pine_id: PUB;ea3f20117eae4230a1a64f784f782f97
- version: 1.0

## Description

This is an adaptive day trading signal that analyzes market conditions using ADX+EMA; in trending markets, it automatically switches to VWAP+EMA to follow the trend on pullbacks, and in ranging markets, it switches to RSI + Bollinger Bands for counter-trend trading.

Recommended timeframes: 3- to 15-minute charts; Instruments: Nikkei 225 futures, S&P 500; for individual stocks, high-volume large-cap stocks; Session restrictions: For individual stocks, it’s effective to wait and see for the first 30 minutes after the open (adjust using “Limit to session”)

The key feature is that it automatically assesses market conditions and switches trading strategies accordingly. The chart background color lets you see the current market phase at a glance (green = uptrend, red = downtrend, gray = range-bound).
In trending phases (trend-following), the system waits for pullbacks or retracements to the EMA9 and enters only when the price is moving in the same direction as the VWAP. This is a classic approach in stock day trading and offers a good balance between win rate and potential profit.
In ranging phases (counter-trend), the system targets rebounds at the outer bands of the Bollinger Bands combined with RSI overbought conditions. Since attempting to follow the trend when there is no clear trend can result in being caught in a round-trip loss, the system automatically switches to this strategy when the ADX is weak.
In line with our opportunity-focused risk management policy, we set stop-losses relatively tight (based on the most recent swing or ATR × 1.0) and use a two-tiered profit-taking strategy: TP1 (1R) as a target for partial profit-taking, and TP2 (2.5R) to let profits run. Stop-loss and profit-taking lines are automatically displayed on the chart.

Since all parameters are adjustable, by adjusting the two settings—ADX trend threshold (trend detection sensitivity) and Volume vs. avg (volume filter)—you can balance the frequency of signals between prioritizing opportunities and prioritizing accuracy.

This indicator is calculated based on closing price candlesticks and does not use `request.security`, so there is no risk of repainting. However, signals are confirmed once the candlestick closes, and labels are displayed after the candlestick closes.

## Source Code

````pine
//@version=6
indicator("Adaptive Daytrade Signal", shorttitle="ADT", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================
// INPUTS
// ============================================================
grp_r = "Regime Detection"
i_adxLen   = input.int(14,   "ADX length",          minval=1,  group=grp_r)
i_adxTrend = input.int(20,   "ADX trend threshold", minval=5,  group=grp_r)
i_emaFast  = input.int(9,    "EMA fast",            minval=1,  group=grp_r)
i_emaSlow  = input.int(21,   "EMA slow",            minval=1,  group=grp_r)
i_emaTrend = input.int(50,   "EMA trend",           minval=1,  group=grp_r)

grp_t = "Trend Mode (pullback)"
i_pullbackPct = input.float(0.15, "Pullback zone % to EMA", minval=0.0, step=0.05, group=grp_t)
i_useVWAP     = input.bool(true,  "Require VWAP alignment", group=grp_t)

grp_rg = "Range Mode (reversal)"
i_rsiLen   = input.int(14, "RSI length",       minval=1, group=grp_rg)
i_rsiOB    = input.int(70, "RSI overbought",   minval=50, group=grp_rg)
i_rsiOS    = input.int(30, "RSI oversold",     minval=1,  group=grp_rg)
i_bbLen    = input.int(20, "BB length",        minval=1,  group=grp_rg)
i_bbMult   = input.float(2.0, "BB multiplier", minval=0.1, step=0.1, group=grp_rg)

grp_v = "Filters"
i_useVol   = input.bool(true,  "Volume filter", group=grp_v)
i_volMult  = input.float(1.2,  "Volume vs avg", minval=1.0, step=0.1, group=grp_v)
i_volLen   = input.int(20,     "Volume avg len", minval=1, group=grp_v)
i_session  = input.session("0930-1600", "Trading session (exchange tz)", group=grp_v)
i_useSession = input.bool(false, "Limit to session", group=grp_v)

grp_x = "Risk / Targets"
i_atrLen   = input.int(14,  "ATR length",       minval=1, group=grp_x)
i_slAtr    = input.float(1.0, "Stop ATR mult",  minval=0.1, step=0.1, group=grp_x)
i_useSwing = input.bool(true, "Use swing low/high for stop", group=grp_x)
i_swingLb  = input.int(5,    "Swing lookback",   minval=1, group=grp_x)
i_tp1R     = input.float(1.0, "TP1 at R mult",   minval=0.1, step=0.1, group=grp_x)
i_tp2R     = input.float(2.5, "TP2 at R mult",   minval=0.1, step=0.1, group=grp_x)

grp_d = "Display"
i_showLbl  = input.bool(true, "Show entry labels", group=grp_d)
i_showRisk = input.bool(true, "Show SL/TP lines",  group=grp_d)
i_showDash = input.bool(true, "Show dashboard",    group=grp_d)
i_showZone = input.bool(true, "Show regime background", group=grp_d)

// ============================================================
// CORE CALCULATIONS
// ============================================================
emaFast  = ta.ema(close, i_emaFast)
emaSlow  = ta.ema(close, i_emaSlow)
emaTrend = ta.ema(close, i_emaTrend)

[diPlus, diMinus, adx] = ta.dmi(i_adxLen, i_adxLen)

vwap_val = ta.vwap(hlc3)
rsi_val  = ta.rsi(close, i_rsiLen)

bbBasis = ta.sma(close, i_bbLen)
bbDev   = i_bbMult * ta.stdev(close, i_bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

atr_val = ta.atr(i_atrLen)
volAvg  = ta.sma(volume, i_volLen)
volOk   = i_useVol == false or volume >= volAvg * i_volMult

inSession = i_useSession == false or na(time(timeframe.period, i_session)) == false

// ============================================================
// REGIME DETECTION
// ============================================================
emaSlopeUp   = emaTrend > emaTrend[3]
emaSlopeDown = emaTrend < emaTrend[3]
isTrending   = adx >= i_adxTrend
isRanging    = adx < i_adxTrend

trendUp   = isTrending and emaFast > emaSlow and emaSlopeUp   and close > emaTrend
trendDown = isTrending and emaFast < emaSlow and emaSlopeDown and close < emaTrend

// ============================================================
// TREND MODE ENTRIES (pullback continuation)
// ============================================================
pullZone = emaFast * (i_pullbackPct / 100)

vwapLongOk  = i_useVWAP == false or close > vwap_val
vwapShortOk = i_useVWAP == false or close < vwap_val

touchedEmaLong  = low  <= emaFast + pullZone and low  >= emaFast - pullZone
touchedEmaShort = high >= emaFast - pullZone and high <= emaFast + pullZone

trendLong  = trendUp   and touchedEmaLong  and close > open and vwapLongOk  and volOk and inSession
trendShort = trendDown and touchedEmaShort and close < open and vwapShortOk and volOk and inSession

// ============================================================
// RANGE MODE ENTRIES (mean reversion)
// ============================================================
rangeLong  = isRanging and close <= bbLower and rsi_val <= i_rsiOS and close > open and volOk and inSession
rangeShort = isRanging and close >= bbUpper and rsi_val >= i_rsiOB and close < open and volOk and inSession

// ============================================================
// COMBINED SIGNALS
// ============================================================
rawLong  = trendLong  or rangeLong
rawShort = trendShort or rangeShort

var int lastDir = 0
longSig  = rawLong  and lastDir <= 0
shortSig = rawShort and lastDir >= 0

if longSig
    lastDir := 1
if shortSig
    lastDir := -1

isTrendEntry = trendLong or trendShort

// ============================================================
// RISK / TARGETS
// ============================================================
swingLow  = ta.lowest(low,  i_swingLb)
swingHigh = ta.highest(high, i_swingLb)

var float entryPx = na
var float slPx    = na
var float tp1Px   = na
var float tp2Px   = na
var int   posDir  = 0

calcLong() =>
    e   = close
    sl  = i_useSwing ? math.min(swingLow, e - atr_val * i_slAtr) : e - atr_val * i_slAtr
    r   = e - sl
    [e, sl, e + r * i_tp1R, e + r * i_tp2R]

calcShort() =>
    e   = close
    sl  = i_useSwing ? math.max(swingHigh, e + atr_val * i_slAtr) : e + atr_val * i_slAtr
    r   = sl - e
    [e, sl, e - r * i_tp1R, e - r * i_tp2R]

if longSig
    [e, sl, t1, t2] = calcLong()
    entryPx := e
    slPx    := sl
    tp1Px   := t1
    tp2Px   := t2
    posDir  := 1

if shortSig
    [e, sl, t1, t2] = calcShort()
    entryPx := e
    slPx    := sl
    tp1Px   := t1
    tp2Px   := t2
    posDir  := -1

// Exit / invalidation tracking
hitSL  = (posDir == 1 and low <= slPx) or (posDir == -1 and high >= slPx)
hitTP2 = (posDir == 1 and high >= tp2Px) or (posDir == -1 and low <= tp2Px)

if hitSL or hitTP2
    posDir := 0

// ============================================================
// LABELS
// ============================================================
aoff = atr_val * 0.5

if longSig and i_showLbl
    txt = isTrendEntry ? "BUY (Trend)" : "BUY (Range)"
    label.new(bar_index, low - aoff, txt, color=color.new(color.teal, 10), style=label.style_label_up, textcolor=color.white, size=size.small)

if shortSig and i_showLbl
    txt = isTrendEntry ? "SELL (Trend)" : "SELL (Range)"
    label.new(bar_index, high + aoff, txt, color=color.new(color.red, 10), style=label.style_label_down, textcolor=color.white, size=size.small)

// ============================================================
// RISK LINES
// ============================================================
showRiskLines = i_showRisk and posDir != 0 and na(slPx) == false
plot(showRiskLines ? slPx  : na, "Stop",  color=color.new(color.red,    0),  linewidth=2, style=plot.style_linebr)
plot(showRiskLines ? tp1Px : na, "TP1",   color=color.new(color.orange, 0),  linewidth=1, style=plot.style_linebr)
plot(showRiskLines ? tp2Px : na, "TP2",   color=color.new(color.green,  0),  linewidth=2, style=plot.style_linebr)

// ============================================================
// VWAP plot (reference)
// ============================================================
plot(vwap_val, "VWAP", color=color.new(color.blue, 30), linewidth=1)

// ============================================================
// REGIME BACKGROUND
// ============================================================
regimeCol = trendUp ? color.new(color.teal, 85) : trendDown ? color.new(color.red, 85) : isRanging ? color.new(color.gray, 94) : na
bgcolor(i_showZone ? regimeCol : na, title="Regime")

// ============================================================
// DASHBOARD
// ============================================================
var table tb = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 70), border_color=color.gray, border_width=1, frame_color=color.gray, frame_width=1)

if barstate.islast and i_showDash
    table.cell(tb, 0, 0, "Adaptive Daytrade", bgcolor=color.new(color.navy, 20), text_color=color.white,  text_size=size.small)
    table.cell(tb, 1, 0, syminfo.ticker + " " + timeframe.period, bgcolor=color.new(color.navy, 20), text_color=color.silver, text_size=size.small)

    reg_txt = trendUp ? "TREND UP" : trendDown ? "TREND DOWN" : isRanging ? "RANGE" : "NEUTRAL"
    reg_bg  = trendUp ? color.new(color.teal, 40) : trendDown ? color.new(color.red, 40) : isRanging ? color.new(color.gray, 50) : color.new(color.gray, 70)
    table.cell(tb, 0, 1, "Regime", bgcolor=color.new(color.black, 60), text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 1, reg_txt, bgcolor=reg_bg, text_color=color.white, text_size=size.small)

    table.cell(tb, 0, 2, "ADX", bgcolor=color.new(color.black, 60), text_color=color.silver, text_size=size.small)
    adx_bg = adx >= i_adxTrend ? color.new(color.teal, 50) : color.new(color.gray, 60)
    table.cell(tb, 1, 2, str.tostring(adx, "#.#"), bgcolor=adx_bg, text_color=color.white, text_size=size.small)

    vwap_txt = close > vwap_val ? "Above VWAP" : "Below VWAP"
    vwap_bg  = close > vwap_val ? color.new(color.teal, 50) : color.new(color.red, 50)
    table.cell(tb, 0, 3, "VWAP", bgcolor=color.new(color.black, 60), text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 3, vwap_txt, bgcolor=vwap_bg, text_color=color.white, text_size=size.small)

    table.cell(tb, 0, 4, "RSI", bgcolor=color.new(color.black, 60), text_color=color.silver, text_size=size.small)
    rsi_bg = rsi_val >= i_rsiOB ? color.new(color.red, 50) : rsi_val <= i_rsiOS ? color.new(color.teal, 50) : color.new(color.black, 60)
    table.cell(tb, 1, 4, str.tostring(rsi_val, "#.#"), bgcolor=rsi_bg, text_color=color.white, text_size=size.small)

    vol_txt = volOk ? "OK" : "Low"
    vol_bg  = volOk ? color.new(color.teal, 50) : color.new(color.gray, 60)
    table.cell(tb, 0, 5, "Volume", bgcolor=color.new(color.black, 60), text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 5, vol_txt, bgcolor=vol_bg, text_color=color.white, text_size=size.small)

    pos_txt = posDir == 1 ? "LONG active" : posDir == -1 ? "SHORT active" : "Flat"
    pos_bg  = posDir == 1 ? color.new(color.teal, 40) : posDir == -1 ? color.new(color.red, 40) : color.new(color.gray, 60)
    table.cell(tb, 0, 6, "Position", bgcolor=color.new(color.black, 60), text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 6, pos_txt, bgcolor=pos_bg, text_color=color.white, text_size=size.small)

    sig_txt = longSig ? ">>> BUY <<<" : shortSig ? ">>> SELL <<<" : "Waiting"
    sig_bg  = longSig ? color.new(color.teal, 20) : shortSig ? color.new(color.red, 20) : color.new(color.black, 60)
    table.cell(tb, 0, 7, "Signal", bgcolor=color.new(color.black, 60), text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 7, sig_txt, bgcolor=sig_bg, text_color=color.white, text_size=size.small)

// ============================================================
// ALERTS
// ============================================================
alertcondition(longSig,  title="ADT Buy",  message="Adaptive Daytrade BUY {{ticker}} @ {{close}}")
alertcondition(shortSig, title="ADT Sell", message="Adaptive Daytrade SELL {{ticker}} @ {{close}}")
````
