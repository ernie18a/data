# Multi-TF RSI + Trend Magic Signals

- url: https://www.tradingview.com/script/1A6sF0YK-Multi-TF-RSI-Trend-Magic-Signals/
- type: indicator
- pine_id: PUB;613576f98f2d4dc1a0e3cc236a499878
- version: 1.0

## Description

trending Rsi indicator use  this indicator on 4 hour chart whenever the yellow dotted line buy call will be initiated and red dotted line initiated . use the #% sl and 10 %profit

## Source Code

````pine
//@version=6
// strategy_archetype: first_principles
indicator("Multi-TF RSI + Trend Magic Signals", overlay=true, max_labels_count=100)

// ============================================================
// INPUT SETTINGS
// ============================================================
rsiLen       = input.int(14,     "RSI Period")
tmAtrLen     = input.int(20,     "TM20 ATR Length")
tmMultiplier = input.float(2.0,  "TM20 ATR Multiplier")
cciLen       = input.int(14,     "CCI Length (for TM color)")

// ============================================================
// TREND MAGIC (TM20) — classic ATR trailing stop + CCI color
// ============================================================
atr    = ta.atr(tmAtrLen)
cciVal = ta.cci(hlc3, cciLen)

// Upper / lower ATR bands
up = hl2 + tmMultiplier * atr
dn = hl2 - tmMultiplier * atr

var float tmUp = na
var float tmDn = na
var int   tmTrend = 1   // 1 = up (bullish), -1 = down (bearish)

// Trailing-stop logic (classic Trend Magic)
tmUp := close[1] > nz(tmUp[1]) ? math.max(up, nz(tmUp[1])) : up
tmDn := close[1] < nz(tmDn[1]) ? math.min(dn, nz(tmDn[1])) : dn

tmTrend := close > nz(tmDn[1]) ? 1 : close < nz(tmUp[1]) ? -1 : nz(tmTrend[1], 1)

tmLine = tmTrend == 1 ? tmUp : tmDn

// TM is blue/bullish when CCI > 0 (per original Trend Magic specification)
tmBullish = cciVal > 0

// ============================================================
// MULTI-TIMEFRAME RSI (non-repainting pattern)
// ============================================================

// Weekly RSI — previous completed weekly bar [1] outside for non-repainting
weeklyRSI  = request.security(syminfo.tickerid, "W",   ta.rsi(close, rsiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)[1]
weeklyOK    = weeklyRSI > 50
weeklyBear  = weeklyRSI < 50

// 4-hour RSI — explicitly fetched so indicator works on ANY chart timeframe
rsi4H       = request.security(syminfo.tickerid, "240", ta.rsi(close, rsiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)[1]
rsi4HOK     = rsi4H > 50
rsi4HBear   = rsi4H < 50

// ============================================================
// COMBINED BUY & SELL SIGNALS
// ============================================================
buyCondition  = weeklyOK and rsi4HOK and tmBullish
sellCondition = weeklyBear and rsi4HBear and not tmBullish

// Edge detection — fire only ONCE when condition transitions from false to true
buySignal  = buyCondition  and not buyCondition[1]
sellSignal = sellCondition and not sellCondition[1]

// ============================================================
// PLOTTING
// ============================================================

// Trend Magic line
plot(tmLine, "Trend Magic", color=cciVal > 0 ? color.blue : color.red, linewidth=2)

// Horizontal reference at zero for CCI context (not a literal constant, so use plot)
plot(0, "Zero Line", color=color.gray, style=plot.style_circles, display=display.none)

// Green upward arrow below candle
plotshape(buySignal, style=shape.triangleup, location=location.belowbar,
          color=color.new(color.green, 0), size=size.large, title="Buy Signal")

// Red downward arrow above candle
plotshape(sellSignal, style=shape.triangledown, location=location.abovebar,
          color=color.new(color.red, 0), size=size.large, title="Sell Signal")



// ============================================================
// ALERT CONDITIONS
// ============================================================
alertcondition(buySignal,  "Buy Alert",  "Multi-TF RSI + TM: Buy signal triggered (Weekly RSI>50, 4H RSI>50, TM Bullish)")
alertcondition(sellSignal, "Sell Alert", "Multi-TF RSI + TM: Sell signal triggered (Weekly RSI<50, 4H RSI<50, TM Bearish)")

// Informative labels
if buySignal
    label.new(bar_index, low,
              "BUY\nWkRSI: "  + str.tostring(weeklyRSI, "#.#") +
              "\n4H RSI: "   + str.tostring(rsi4H, "#.#") +
              "\nCCI: "      + str.tostring(cciVal, "#.#") +
              "\nTM: Bullish",
              style=label.style_label_up, color=color.green,
              textcolor=color.white, size=size.small, yloc=yloc.belowbar)

if sellSignal
    label.new(bar_index, high,
              "SELL\nWkRSI: " + str.tostring(weeklyRSI, "#.#") +
              "\n4H RSI: "   + str.tostring(rsi4H, "#.#") +
              "\nCCI: "      + str.tostring(cciVal, "#.#") +
              "\nTM: Bearish",
              style=label.style_label_down, color=color.red,
              textcolor=color.white, size=size.small, yloc=yloc.abovebar)
````
