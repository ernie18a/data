# RichmondHillCM - PTJ Regime Change

- url: https://www.tradingview.com/script/SYdAKuCY-RichmondHillCM-PTJ-Regime-Change/
- type: indicator
- pine_id: PUB;0ebbb5e2059a4fa1908fdbd2b259670e
- version: 2.0

## Description

[b]PTJ Regime Change — Bull / Bear / Neutral Market Gauge[/b]

A composite market-regime indicator inspired by the trend-following, 200-day-moving-average philosophy popularised by Paul Tudor Jones. Instead of relying on a single signal, it polls s[b]even independent technical components,[/b] each casting a +1 (bullish) or −1 (bearish) vote, then sums them into one score from −7 to +7 and classifies the market into a [b]Bull, Bear, or Neutral [/b]regime.
The 7 components:

Price vs 200 MA — primary trend filter
Price vs 50 MA — intermediate trend filter
MA slope — are both averages rising?
RSI — momentum inside a healthy band (not weak, not euphoric)
MACD histogram — momentum expanding vs contracting
Volume — does volume confirm the day's direction?
ATR stress — is volatility calm or spiking?

[b]How to use it:[/b]

• Background and candle colours show the live regime at a glance.

• The bottom-right table breaks down every component, its signal, and the total score.

• Optional labels mark the exact bar where the regime flips.

• Built-in alerts for regime changes, 200-MA crosses (above/below), and RSI blow-off/euphoria warnings.

Every input is configurable: MA type (SMA/EMA) and lengths, RSI/MACD/ATR settings, volume period, and the bull/bear score thresholds — so you can tune sensitivity to your symbol and timeframe.

[b]Works on any symbol and any timeframe.[/b]
Credits: methodology inspired by Paul Tudor Jones' trend/200-MA approach; original scoring framework concept by RichmondHillCM.

[i]Disclaimer: For educational purposes only. This is not financial advice and does not guarantee future performance. Always do your own research.[/i]

## Source Code

````pine
// ============================================================================
//  PTJ REGIME CHANGE  —  Bull / Bear / Neutral Regime Indicator
// ----------------------------------------------------------------------------
//  Pine Script® v6  |  Works on any symbol and any timeframe  |  Overlay
// ----------------------------------------------------------------------------
//  CONCEPT
//  A composite "market regime" gauge inspired by Paul Tudor Jones' well-known
//  emphasis on trend-following and the 200-day moving average as a master
//  filter ("nothing good happens below the 200-day"). Seven independent
//  technical components each vote +1 (bullish) or -1 (bearish). The votes are
//  summed into a single score from -7 to +7, which is then classified into a
//  Bull, Bear, or Neutral regime.
//
//  THE 7 COMPONENTS (each worth -1 / 0 / +1)
//    1. Price vs 200 MA   — primary trend filter
//    2. Price vs 50 MA    — intermediate trend filter
//    3. MA slope          — are both MAs rising? (trend health)
//    4. RSI               — momentum in a healthy band (not weak, not euphoric)
//    5. MACD histogram    — momentum expanding vs contracting
//    6. Volume            — does volume confirm the day's direction?
//    7. ATR stress        — is volatility calm (bull) or stressed (bear)?
//
//  HOW TO READ IT
//    • Background colour + candle colour show the live regime.
//    • The bottom-right table breaks down every component and the total score.
//    • Optional labels mark the exact bar where the regime flips.
//    • Alerts fire on regime changes, 200-MA crosses, and RSI blow-off tops.
// ----------------------------------------------------------------------------
//  CREDITS
//    • Methodology inspired by the trend / 200-MA philosophy popularised by
//      Paul Tudor Jones.
//    • Original v5 concept & scoring framework: RichmondHillCM.
//
//  DISCLAIMER
//    For educational purposes only. This is not financial advice and makes no
//    guarantee of future performance. Always do your own research.
// ============================================================================

//@version=6
indicator(title     = "RichmondHillCM - PTJ Regime Change",
          shorttitle = "RichmondHillCM - PTJ Regime Change",
          overlay    = true,
          max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Moving Averages
// ─────────────────────────────────────────────────────────────────────────────
grp_ma   = "Moving Averages"
ma200Len = input.int(200, "200-MA length", group = grp_ma, minval = 50)
ma50Len  = input.int(50,  "50-MA length",  group = grp_ma, minval = 10)
maType   = input.string("EMA", "MA type", options = ["SMA", "EMA"], group = grp_ma)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Momentum (RSI + MACD)
// ─────────────────────────────────────────────────────────────────────────────
grp_mom  = "Momentum"
rsiLen   = input.int(14, "RSI length",     group = grp_mom, minval = 2)
rsiBull  = input.int(40, "RSI bull floor", group = grp_mom, minval = 10, maxval = 50,
                     tooltip = "RSI above this value = bullish momentum zone.")
rsiBear  = input.int(80, "RSI bear ceiling (euphoria/blow-off)", group = grp_mom, minval = 60, maxval = 95,
                     tooltip = "RSI at/above this triggers bearish caution — PTJ watches for blow-off tops.")
macdFast = input.int(12, "MACD fast",   group = grp_mom, minval = 2)
macdSlow = input.int(26, "MACD slow",   group = grp_mom, minval = 5)
macdSig  = input.int(9,  "MACD signal", group = grp_mom, minval = 2)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Volume
// ─────────────────────────────────────────────────────────────────────────────
grp_vol  = "Volume"
volLen   = input.int(10, "Volume MA length", group = grp_vol, minval = 2)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Volatility (ATR)
// ─────────────────────────────────────────────────────────────────────────────
grp_atr   = "Volatility (ATR)"
atrLen    = input.int(14,  "ATR length",                 group = grp_atr, minval = 2)
atrNorm   = input.int(50,  "ATR normalisation period",   group = grp_atr, minval = 20)
atrStress = input.float(2.5, "ATR stress multiplier",    group = grp_atr, minval = 1.5, step = 0.1,
                        tooltip = "Current ATR / mean ATR above this = high-stress, bearish caution.")

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Scoring & Display
// ─────────────────────────────────────────────────────────────────────────────
grp_score  = "Scoring & Display"
bullThresh = input.int(3,  "Bull threshold (min score out of 7)", group = grp_score, minval = 1, maxval = 7,
                       tooltip = "Score >= this value = Bull regime.")
bearThresh = input.int(-3, "Bear threshold (max score out of -7)", group = grp_score, minval = -7, maxval = -1,
                       tooltip = "Score <= this value = Bear regime.")
showBg     = input.bool(true,  "Show background colour",    group = grp_score)
showTable  = input.bool(true,  "Show component table",      group = grp_score)
showMAs    = input.bool(true,  "Plot 200/50 MAs",           group = grp_score)
showMALabels = input.bool(true, "Label the MA lines",       group = grp_score,
                          tooltip = "Draw a tag at the end of each moving-average line showing its name and current value.")
showLabels = input.bool(false, "Show regime change labels", group = grp_score)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — Candle Colouring
// ─────────────────────────────────────────────────────────────────────────────
grp_candle       = "Candle Colouring"
showCandleColour = input.bool(true, "Colour candles by regime", group = grp_candle,
                              tooltip = "Green candles in Bull, red in Bear, neutral colour otherwise.")
bullCandleClr    = input.color(color.new(color.green, 0),  "Bull candle colour",    group = grp_candle)
bearCandleClr    = input.color(color.new(color.red,   0),  "Bear candle colour",    group = grp_candle)
neutCandleClr    = input.color(color.new(color.gray,  30), "Neutral candle colour", group = grp_candle)

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER — moving-average selector (SMA or EMA based on the input above)
// ─────────────────────────────────────────────────────────────────────────────
ma(src, len) =>
    maType == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

// ─────────────────────────────────────────────────────────────────────────────
//  COMPONENT 1 & 2 — Price vs the two moving averages
// ─────────────────────────────────────────────────────────────────────────────
ma200 = ma(close, ma200Len)
ma50  = ma(close, ma50Len)

priceAbove200 = close > ma200   // primary trend filter
priceAbove50  = close > ma50    // intermediate trend filter

// ─────────────────────────────────────────────────────────────────────────────
//  COMPONENT 3 — MA slope: are BOTH averages rising over the last 5 bars?
// ─────────────────────────────────────────────────────────────────────────────
ma200Rising = ma200 > ma200[5]
ma50Rising  = ma50  > ma50[5]
maSlope     = ma200Rising and ma50Rising

// ─────────────────────────────────────────────────────────────────────────────
//  COMPONENT 4 — RSI: bullish only inside a healthy band.
//  Below the floor = weak; at/above the ceiling = euphoric blow-off (bearish).
// ─────────────────────────────────────────────────────────────────────────────
rsi        = ta.rsi(close, rsiLen)
rsiBullish = rsi >= rsiBull and rsi < rsiBear
rsiBearish = rsi <  rsiBull or  rsi >= rsiBear

// ─────────────────────────────────────────────────────────────────────────────
//  COMPONENT 5 — MACD histogram: expanding above zero = bull,
//  contracting below zero = bear.
// ─────────────────────────────────────────────────────────────────────────────
[macdLine, signalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
macdBullish = macdHist > 0 and macdHist > macdHist[1]
macdBearish = macdHist < 0 and macdHist < macdHist[1]

// ─────────────────────────────────────────────────────────────────────────────
//  COMPONENT 6 — Volume confirmation: above-average volume on an up day
//  confirms (bull); above-average volume on a down day = distribution (bear).
// ─────────────────────────────────────────────────────────────────────────────
volMA    = ta.sma(volume, volLen)
volBull  = volume > volMA and close > close[1]
volBear  = volume > volMA and close < close[1]
volScore = volBull ? 1 : volBear ? -1 : 0
volRatio = volMA != 0 ? volume / volMA : 0   // used for the table display

// ─────────────────────────────────────────────────────────────────────────────
//  COMPONENT 7 — ATR stress: calm volatility supports trend continuation;
//  a volatility spike (stress multiple) flags risk-off conditions.
// ─────────────────────────────────────────────────────────────────────────────
atrVal     = ta.atr(atrLen)
atrMean    = ta.sma(atrVal, atrNorm)
atrRatio   = atrMean != 0 ? atrVal / atrMean : 0
atrBullish = atrRatio < 1.5
atrBearish = atrRatio > atrStress

// ─────────────────────────────────────────────────────────────────────────────
//  COMPOSITE SCORE  (range: -7 .. +7)
//  Each component contributes a single vote.
// ─────────────────────────────────────────────────────────────────────────────
score  = 0
score += priceAbove200 ? 1 : -1
score += priceAbove50  ? 1 : -1
score += maSlope       ? 1 : -1
score += rsiBullish    ? 1 : -1
score += macdBullish   ? 1 : (macdBearish ? -1 : 0)
score += volScore
score += atrBullish    ? 1 : (atrBearish ? -1 : 0)

// ─────────────────────────────────────────────────────────────────────────────
//  REGIME CLASSIFICATION
// ─────────────────────────────────────────────────────────────────────────────
bullRegime    = score >= bullThresh
bearRegime    = score <= bearThresh
neutralRegime = not bullRegime and not bearRegime

// ─────────────────────────────────────────────────────────────────────────────
//  REGIME-CHANGE DETECTION
//  NOTE (v6): logical operators treat a `na` bool as `false`, so on the very
//  first bars (where the previous-bar value is na) the comparison resolves
//  cleanly without throwing off the change detection.
// ─────────────────────────────────────────────────────────────────────────────
prevBull = bullRegime[1]
prevBear = bearRegime[1]

regimeChangedBull = bullRegime and not prevBull
regimeChangedBear = bearRegime and not prevBear

// ─────────────────────────────────────────────────────────────────────────────
//  PLOTS — Moving Averages
// ─────────────────────────────────────────────────────────────────────────────
plot(showMAs ? ma200 : na, "200 MA", color = color.new(color.orange, 0), linewidth = 2)
plot(showMAs ? ma50  : na, "50 MA",  color = color.new(color.blue,   0), linewidth = 1)

// ─────────────────────────────────────────────────────────────────────────────
//  MA LINE LABELS
//  Draws a tag at the right-hand end of each moving-average line showing its
//  name and current value. Uses `var` so each label is created once and then
//  repositioned every bar — this keeps the tag pinned to the most recent bar
//  instead of leaving a trail of labels across the chart.
// ─────────────────────────────────────────────────────────────────────────────
var label lbl200 = na
var label lbl50  = na

if showMAs and showMALabels and barstate.islast
    // 200 MA tag
    lbl200 := label.new(bar_index, ma200,
                  text      = "200 MA  " + str.tostring(math.round_to_mintick(ma200)),
                  style     = label.style_label_left,
                  color     = color.new(color.orange, 20),
                  textcolor = color.white,
                  size      = size.small)
    label.delete(lbl200[1])

    // 50 MA tag
    lbl50 := label.new(bar_index, ma50,
                  text      = "50 MA  " + str.tostring(math.round_to_mintick(ma50)),
                  style     = label.style_label_left,
                  color     = color.new(color.blue, 20),
                  textcolor = color.white,
                  size      = size.small)
    label.delete(lbl50[1])

// ─────────────────────────────────────────────────────────────────────────────
//  CANDLE COLOURING
//  Colours every candle by the CURRENT regime. On a regime-change bar the
//  colour already reflects the new regime, so the transition is immediate.
// ─────────────────────────────────────────────────────────────────────────────
candleColour = bullRegime ? bullCandleClr : bearRegime ? bearCandleClr : neutCandleClr

plotcandle(open, high, low, close,
           title       = "Regime Candles",
           color       = showCandleColour ? candleColour : na,
           wickcolor   = showCandleColour ? candleColour : na,
           bordercolor = showCandleColour ? candleColour : na)

// ─────────────────────────────────────────────────────────────────────────────
//  BACKGROUND COLOUR
// ─────────────────────────────────────────────────────────────────────────────
bgColour = bullRegime ? color.new(color.green, 88) :   bearRegime ? color.new(color.red,   88) :   color.new(color.gray,  94)
bgcolor(showBg ? bgColour : na, title = "Regime background")

// ─────────────────────────────────────────────────────────────────────────────
//  REGIME-CHANGE LABELS (optional)
// ─────────────────────────────────────────────────────────────────────────────
if showLabels and regimeChangedBull
    label.new(bar_index, high, text = "▲ BULL", style = label.style_label_up,
              color = color.new(color.green, 10), textcolor = color.white, size = size.small)

if showLabels and regimeChangedBear
    label.new(bar_index, low, text = "▼ BEAR", style = label.style_label_down,
              color = color.new(color.red, 10), textcolor = color.white, size = size.small)

// ─────────────────────────────────────────────────────────────────────────────
//  COMPONENT TABLE (bottom-right)
// ─────────────────────────────────────────────────────────────────────────────
var table tbl = table.new(position.bottom_right, 3, 10,
                          border_width = 1, border_color = color.new(color.gray, 60),
                          frame_width  = 1, frame_color  = color.new(color.gray, 40))

bullClr   = color.new(color.green, 20)
bearClr   = color.new(color.red,   20)
neutClr   = color.new(color.gray,  40)
headerClr = color.new(color.gray,  20)
txtWhite  = color.white
txtDark   = color.new(color.gray, 10)

// Small helper to write a styled table cell.
f_cell(row, col, txt, bg, tc) =>
    table.cell(tbl, col, row, txt, bgcolor = bg, text_color = tc, text_size = size.small)

if showTable and barstate.islast
    // Header row
    f_cell(0, 0, "Component", headerClr, txtWhite)
    f_cell(0, 1, "Signal",    headerClr, txtWhite)
    f_cell(0, 2, "Value",     headerClr, txtWhite)

    // 1 — Price vs 200 MA
    c1 = priceAbove200 ? bullClr : bearClr
    f_cell(1, 0, "Price vs 200 MA", neutClr, txtDark)
    f_cell(1, 1, priceAbove200 ? "▲ Bull" : "▼ Bear", c1, txtWhite)
    f_cell(1, 2, str.tostring(math.round(close / ma200 * 100, 1)) + "%", neutClr, txtDark)

    // 2 — Price vs 50 MA
    c2 = priceAbove50 ? bullClr : bearClr
    f_cell(2, 0, "Price vs 50 MA", neutClr, txtDark)
    f_cell(2, 1, priceAbove50 ? "▲ Bull" : "▼ Bear", c2, txtWhite)
    f_cell(2, 2, str.tostring(math.round(close / ma50 * 100, 1)) + "%", neutClr, txtDark)

    // 3 — MA slope
    c3 = maSlope ? bullClr : bearClr
    f_cell(3, 0, "MA Slope (50+200)", neutClr, txtDark)
    f_cell(3, 1, maSlope ? "▲ Rising" : "▼ Falling", c3, txtWhite)
    f_cell(3, 2, " ", neutClr, txtDark)

    // 4 — RSI
    c4 = rsiBullish ? bullClr : bearClr
    f_cell(4, 0, "RSI (" + str.tostring(rsiLen) + ")", neutClr, txtDark)
    f_cell(4, 1, rsiBullish ? "▲ Momentum" : "▼ Extreme", c4, txtWhite)
    f_cell(4, 2, str.tostring(math.round(rsi, 1)), neutClr, txtDark)

    // 5 — MACD histogram
    c5 = macdBullish ? bullClr : macdBearish ? bearClr : neutClr
    f_cell(5, 0, "MACD Histogram", neutClr, txtDark)
    f_cell(5, 1, macdBullish ? "▲ Expanding" : macdBearish ? "▼ Contracting" : "— Neutral", c5, txtWhite)
    f_cell(5, 2, str.tostring(math.round(macdHist, 4)), neutClr, txtDark)

    // 6 — Volume confirm  (FIXED: now shows the volume/volMA ratio, not ATR)
    c6 = volScore == 1 ? bullClr : volScore == -1 ? bearClr : neutClr
    f_cell(6, 0, "Volume Confirm", neutClr, txtDark)
    f_cell(6, 1, volScore == 1 ? "▲ Confirming" : volScore == -1 ? "▼ Distributing" : "— Neutral", c6, txtWhite)
    f_cell(6, 2, str.tostring(math.round(volRatio, 2)) + "x", neutClr, txtDark)

    // 7 — ATR stress
    c7 = atrBullish ? bullClr : atrBearish ? bearClr : neutClr
    f_cell(7, 0, "ATR Stress", neutClr, txtDark)
    f_cell(7, 1, atrBullish ? "▲ Low stress" : atrBearish ? "▼ High stress" : "— Elevated", c7, txtWhite)
    f_cell(7, 2, str.tostring(math.round(atrRatio, 2)) + "x", neutClr, txtDark)

    // Summary row — overall regime + score
    regimeTxt = bullRegime ? "● BULL  (" + str.tostring(score) + "/7)" :   bearRegime ? "● BEAR  (" + str.tostring(score) + "/7)" :     "● NEUTRAL (" + str.tostring(score) + "/7)"
    regimeBg  = bullRegime ? color.new(color.green, 10) :   bearRegime ? color.new(color.red, 10) :    color.new(color.gray, 30)

    f_cell(8, 0, "PTJ REGIME", headerClr, txtWhite)
    table.cell(tbl, 1, 8, regimeTxt, text_color = txtWhite, bgcolor = regimeBg, text_size = size.small)
    table.cell(tbl, 2, 8, "", bgcolor = regimeBg)

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(regimeChangedBull, title = "PTJ — Regime turned BULLISH",
               message = "PTJ Regime: Composite score crossed into Bull zone.")
alertcondition(regimeChangedBear, title = "PTJ — Regime turned BEARISH",
               message = "PTJ Regime: Composite score crossed into Bear zone.")
alertcondition(close < ma200 and close[1] >= ma200[1], title = "PTJ — Price crossed BELOW 200 MA",
               message = "CRITICAL: Price closed below the 200-day MA.")
alertcondition(close > ma200 and close[1] <= ma200[1], title = "PTJ — Price crossed ABOVE 200 MA",
               message = "PTJ: Price reclaimed the 200-day MA.")
alertcondition(rsi >= rsiBear, title = "PTJ — RSI Blow-off / Euphoria warning",
               message = "PTJ euphoria signal: RSI reached extreme level.")
````
