# Tokyo Rules v6

- url: https://www.tradingview.com/script/89Q9nv2Q/
- type: indicator
- pine_id: PUB;847073d96dcd4e96964479480f505a04
- version: 1.0

## Description

Tokyo Rules [Rob Booker] v6

[b]Description[/b]

Tokyo Rules is a market regime identification system based on Rob Booker's original "Arizona Rules" methodology, re-imagined with Tokyo district names that intuitively reflect each phase of market behavior.

The core idea is simple but powerful: **before deciding how to trade, first decide where you are.** The indicator reads the relationship between three moving averages (EMA 62, SMA 200, SMA 800) to classify the market into one of four phases — each named after a distinct Tokyo district that mirrors its character.



🟡[b] Ginza — Range Phase[/b]
The market is quiet, polished, and going nowhere fast.

EMA 62 is sandwiched between SMA 200 and SMA 800. No clear trend exists. Like Ginza on a slow afternoon — elegant but still. Trade both bullish and bearish MACD divergences; target the nearest moving average.

🔵 [b]Shinagawa — Trend Start Phase[/b]
The train is leaving the station.

EMA 62 has crossed SMA 800, but SMA 200 has not yet followed. A new trend is emerging. Like Shinagawa Station — the departure point of the Shinkansen. Trade divergences aligned with the emerging trend direction only; target EMA 62 or SMA 800.

🟢[b] Shibuya — Trend Continuation Phase[/b]
Full energy. All signals aligned.

All three moving averages are fully stacked in order (EMA 62 > SMA 200 > SMA 800 for bullish, or the reverse for bearish). Like Shibuya Scramble Crossing at peak hour — maximum momentum. Trade breakouts or pullback divergences in the trend direction; target SMA 800.

🔴 [b]Roppongi — Chaos Phase[/b]
No clear direction. Stay out.

Moving averages are tangled and contradictory. Like Roppongi at 3am — exciting but dangerous. This is a no-trade zone. Step back, drop to a lower timeframe, and look for a Ginza phase there instead.



[b]Divergence Detection[/b]

The indicator automatically detects MACD divergences against price pivot highs and lows:

- Bullish Divergence — Price makes a lower low while MACD makes a higher low → potential long opportunity
- Bearish Divergence — Price makes a higher high while MACD makes a lower high → potential short opportunity

Divergence signals are filtered by phase — only signals appropriate to the current market context are shown, reducing noise significantly.

A Stochastic oscillator (9-3-3) provides a second confirmation layer. BUY/SELL triangle markers appear only when both divergence and Stochastic overbought/oversold conditions align simultaneously.



[b]Indicators Used[/b]

| Indicator | Settings | Role |
|---|---|---|
| EMA | 62 | Short-term trend & phase pivot |
| SMA | 200 | Mid-term trend reference |
| SMA | 800 | Long-term trend anchor |
| MACD | 12-26-9 | Divergence detection |
| Stochastic | 9-3-3 | Entry confirmation |



[b]Visual Features[/b]

- Background color changes with each phase for instant recognition
- Phase labels appear on the chart at every phase transition
- Divergence lines drawn directly on price with phase name tags
- Info table (top-right) shows current phase, direction, MA values, and Stoch %K in real time
- 3 built-in alerts: Bullish Divergence, Bearish Divergence, Phase Change



[b]Recommended Usage[/b]

- Timeframe: 1H (primary), 15M (secondary / drill-down from Roppongi phase)
- Markets: Forex, indices, crypto — any liquid instrument with sufficient history for SMA 800
- Note: SMA 800 requires at least 800 bars of history. Use a timeframe and symbol with sufficient data loaded.



[b]Settings[/b]

All parameters are fully adjustable via the Inputs panel:

- MA periods (EMA 62 / SMA 200 / SMA 800)
- MACD settings (Fast / Slow / Signal)
- Divergence pivot sensitivity (Left / Right bars)
- Stochastic settings and OB/OS thresholds
- Display toggles (background, MAs, labels, divergence lines)



[b]Credits[/b]

Original concept: Rob Booker — "The Arizona Rules" (2007)
Tokyo district adaptation & Pine Script v6 implementation by the author.

This indicator is a creative reinterpretation of Rob Booker's market phase framework. The underlying logic is faithful to the original methodology; only the naming convention has been adapted.



This indicator is for educational and informational purposes only. It does not constitute financial advice. Always apply your own risk management.

## Source Code

````pine
// =============================================================================
// Tokyo Rules — Rob Booker  (Pine Script v6)
// Purpose : Market phase identification + MACD divergence detection
// Phases  : Ginza (Range) / Shinagawa (Trend Start) / Shibuya (Trend) / Roppongi (Chaos)
// =============================================================================
//@version=6
indicator(title = "Tokyo Rules [Rob Booker] v6",
         shorttitle = "TK Rules",
         overlay = true,
         max_labels_count = 500,
         max_lines_count  = 500)

// =============================================================================
// ── INPUTS ──
// =============================================================================
grp_ma    = "Moving Averages"
grp_macd  = "MACD (Divergence)"
grp_stoch = "Stochastic"
grp_disp  = "Display"

// MA
len_ema62  = input.int(62,  "EMA Period (Short)",  group = grp_ma, minval = 1)
len_sma200 = input.int(200, "SMA Period (Mid)",    group = grp_ma, minval = 1)
len_sma800 = input.int(800, "SMA Period (Long)",   group = grp_ma, minval = 1)

// MACD
macd_fast = input.int(12, "MACD Fast",   group = grp_macd, minval = 1)
macd_slow = input.int(26, "MACD Slow",   group = grp_macd, minval = 1)
macd_sig  = input.int(9,  "MACD Signal", group = grp_macd, minval = 1)

// Divergence pivot bars
piv_left  = input.int(5, "Divergence Pivot Left Bars",  group = grp_macd, minval = 2)
piv_right = input.int(5, "Divergence Pivot Right Bars", group = grp_macd, minval = 2)

// Stochastic
stoch_k  = input.int(9,  "Stoch %K",         group = grp_stoch, minval = 1)
stoch_d  = input.int(3,  "Stoch %D",         group = grp_stoch, minval = 1)
stoch_slw = input.int(3, "Stoch Smooth",      group = grp_stoch, minval = 1)
stoch_ob = input.int(80, "Overbought Level",  group = grp_stoch, minval = 50, maxval = 100)
stoch_os = input.int(20, "Oversold Level",    group = grp_stoch, minval = 0,  maxval = 50)

// Display
show_bg     = input.bool(true, "Show Phase Background Color", group = grp_disp)
show_ma     = input.bool(true, "Show Moving Averages",        group = grp_disp)
show_labels = input.bool(true, "Show Phase Labels",           group = grp_disp)
show_div    = input.bool(true, "Show Divergence Lines",       group = grp_disp)

// =============================================================================
// ── MOVING AVERAGES ──
// =============================================================================
ema62  = ta.ema(close, len_ema62)
sma200 = ta.sma(close, len_sma200)
sma800 = ta.sma(close, len_sma800)

// =============================================================================
// ── PHASE DETECTION ──
//   Shibuya    : All 3 MAs fully aligned (trend continuation)
//   Shinagawa  : EMA62 crossed SMA800, SMA200 has not yet (trend start)
//   Ginza     : EMA62 between SMA200 and SMA800 (range)
//   Roppongi : None of the above (chaos — no trade)
// =============================================================================
isShibuyaBull = ema62 > sma200 and sma200 > sma800
isShibuyaBear = ema62 < sma200 and sma200 < sma800
isShibuya     = isShibuyaBull or isShibuyaBear

isShinagawaBull = ema62 > sma800 and sma200 <= sma800
isShinagawaBear = ema62 < sma800 and sma200 >= sma800
isShinagawa     = (isShinagawaBull or isShinagawaBear) and not isShibuya

isGinzaBull = ema62 > sma800 and ema62 < sma200
isGinzaBear = ema62 < sma800 and ema62 > sma200
isGinza     = (isGinzaBull or isGinzaBear) and not isShibuya and not isShinagawa

isRoppongi = not isShibuya and not isShinagawa and not isGinza

phaseNum = isShibuya ? 3 : isShinagawa ? 2 : isGinza ? 1 : 0

phaseName(int n) =>
    switch n
        3 => "Shibuya"
        2 => "Shinagawa"
        1 => "Ginza"
        => "Roppongi"

phaseColor(int n) =>
    switch n
        3 => color.new(color.green,  80)
        2 => color.new(color.blue,   80)
        1 => color.new(color.yellow, 82)
        => color.new(color.red,      88)

phaseTextColor(int n) =>
    switch n
        3 => color.green
        2 => color.blue
        1 => color.orange
        => color.red

// =============================================================================
// ── BACKGROUND COLOR ──
// =============================================================================
bgcolor(show_bg ? phaseColor(phaseNum) : na, title = "Phase BG")

// =============================================================================
// ── MOVING AVERAGE PLOTS ──
// =============================================================================
plot(show_ma ? ema62  : na, title = "EMA 62",  color = color.new(color.orange, 0), linewidth = 2)
plot(show_ma ? sma200 : na, title = "SMA 200", color = color.new(color.blue,   0), linewidth = 2)
plot(show_ma ? sma800 : na, title = "SMA 800", color = color.new(color.red,    0), linewidth = 3)

// =============================================================================
// ── PHASE LABEL (on phase change only) ──
// =============================================================================
phaseChanged = phaseNum != phaseNum[1]

if show_labels and phaseChanged and barstate.isconfirmed
    label.new(
         x         = bar_index,
         y         = high,
         text      = phaseName(phaseNum),
         style     = label.style_label_down,
         color     = phaseColor(phaseNum),
         textcolor = phaseTextColor(phaseNum),
         size      = size.small)

// =============================================================================
// ── MACD ──
// =============================================================================
[macdLine, signalLine, histLine] = ta.macd(close, macd_fast, macd_slow, macd_sig)

// =============================================================================
// ── STOCHASTIC ──
// =============================================================================
stochK = ta.sma(ta.stoch(close, high, low, stoch_k), stoch_d)
stochD = ta.sma(stochK, stoch_slw)

// =============================================================================
// ── DIVERGENCE DETECTION ──
//   Bearish Div : Price Higher High + MACD Lower High  → potential sell
//   Bullish Div : Price Lower Low   + MACD Higher Low  → potential buy
//   Pivot confirmation is delayed by piv_right bars.
// =============================================================================

priceHigh = ta.pivothigh(high,     piv_left, piv_right)
priceLow  = ta.pivotlow( low,      piv_left, piv_right)
macdHigh  = ta.pivothigh(macdLine, piv_left, piv_right)
macdLow   = ta.pivotlow( macdLine, piv_left, piv_right)

var int   lastPriceHighBar = na
var float lastPriceHighVal = na
var int   lastMacdHighBar  = na
var float lastMacdHighVal  = na

var int   lastPriceLowBar  = na
var float lastPriceLowVal  = na
var int   lastMacdLowBar   = na
var float lastMacdLowVal   = na

if not na(priceHigh)
    lastPriceHighBar := bar_index - piv_right
    lastPriceHighVal := priceHigh

if not na(macdHigh)
    lastMacdHighBar := bar_index - piv_right
    lastMacdHighVal := macdHigh

if not na(priceLow)
    lastPriceLowBar := bar_index - piv_right
    lastPriceLowVal := priceLow

if not na(macdLow)
    lastMacdLowBar := bar_index - piv_right
    lastMacdLowVal := macdLow

// ── Bearish Divergence ──
bearDiv          = false
bearDivPriceBar1 = 0
bearDivPriceBar2 = 0
bearDivPriceVal1 = 0.0
bearDivPriceVal2 = 0.0

if not na(priceHigh) and not na(macdHigh)
    curBar       = bar_index - piv_right
    curPriceHigh = priceHigh
    curMacdHigh  = macdHigh
    if not na(lastPriceHighVal) and not na(lastMacdHighVal)
        if curPriceHigh > lastPriceHighVal and curMacdHigh < lastMacdHighVal
            bearDiv          := true
            bearDivPriceBar1 := lastPriceHighBar
            bearDivPriceBar2 := curBar
            bearDivPriceVal1 := lastPriceHighVal
            bearDivPriceVal2 := curPriceHigh

// ── Bullish Divergence ──
bullDiv          = false
bullDivPriceBar1 = 0
bullDivPriceBar2 = 0
bullDivPriceVal1 = 0.0
bullDivPriceVal2 = 0.0

if not na(priceLow) and not na(macdLow)
    curBar2      = bar_index - piv_right
    curPriceLow  = priceLow
    curMacdLow   = macdLow
    if not na(lastPriceLowVal) and not na(lastMacdLowVal)
        if curPriceLow < lastPriceLowVal and curMacdLow > lastMacdLowVal
            bullDiv          := true
            bullDivPriceBar1 := lastPriceLowBar
            bullDivPriceBar2 := curBar2
            bullDivPriceVal1 := lastPriceLowVal
            bullDivPriceVal2 := curPriceLow

// =============================================================================
// ── PHASE FILTER FOR DIVERGENCE ──
//   Ginza    : Both bull and bear divergences are valid
//   Shinagawa : Only divergences aligned with the emerging trend direction
//   Shibuya   : Only pullback divergences aligned with the trend
//   Roppongi: No signals
// =============================================================================
showBearDiv = false
showBullDiv = false

if isGinza
    showBearDiv := bearDiv
    showBullDiv := bullDiv

if isShinagawa
    showBearDiv := bearDiv and isShinagawaBear
    showBullDiv := bullDiv and isShinagawaBull

if isShibuya
    showBearDiv := bearDiv and isShibuyaBear
    showBullDiv := bullDiv and isShibuyaBull

// =============================================================================
// ── DIVERGENCE LINES & LABELS ──
// =============================================================================
if show_div and showBearDiv and barstate.isconfirmed
    line.new(x1 = bearDivPriceBar1, y1 = bearDivPriceVal1,
             x2 = bearDivPriceBar2, y2 = bearDivPriceVal2,
             color = color.new(color.red, 0), width = 2,
             style = line.style_solid)
    label.new(x = bearDivPriceBar2, y = bearDivPriceVal2,
              text      = "Bear Div [" + phaseName(phaseNum) + "]",
              style     = label.style_label_down,
              color     = color.new(color.red, 10),
              textcolor = color.white,
              size      = size.small)

if show_div and showBullDiv and barstate.isconfirmed
    line.new(x1 = bullDivPriceBar1, y1 = bullDivPriceVal1,
             x2 = bullDivPriceBar2, y2 = bullDivPriceVal2,
             color = color.new(color.lime, 0), width = 2,
             style = line.style_solid)
    label.new(x = bullDivPriceBar2, y = bullDivPriceVal2,
              text      = "Bull Div [" + phaseName(phaseNum) + "]",
              style     = label.style_label_up,
              color     = color.new(color.green, 10),
              textcolor = color.white,
              size      = size.small)

// =============================================================================
// ── STOCHASTIC CONFIRMATION SIGNALS ──
// =============================================================================
stochBullConfirm = stochK < stoch_os
stochBearConfirm = stochK > stoch_ob

plotshape(show_div and showBullDiv and stochBullConfirm,
         title    = "Bull Div + Stoch Confirm",
         style    = shape.triangleup,
         location = location.belowbar,
         color    = color.new(color.lime, 0),
         size     = size.normal,
         text     = "BUY")

plotshape(show_div and showBearDiv and stochBearConfirm,
         title    = "Bear Div + Stoch Confirm",
         style    = shape.triangledown,
         location = location.abovebar,
         color    = color.new(color.red, 0),
         size     = size.normal,
         text     = "SELL")

// =============================================================================
// ── INFO TABLE (top-right) ──
// =============================================================================
var table infoTable = table.new(
     position     = position.top_right,
     columns      = 2,
     rows         = 7,
     bgcolor      = color.new(color.black, 75),
     border_width = 1,
     border_color = color.new(color.gray, 50),
     frame_width  = 1,
     frame_color  = color.new(color.gray, 30))

tHeaderBg   = color.new(color.gray, 60)
tHeaderText = color.white
tLabelBg    = color.new(color.gray, 20)

if barstate.islast
    table.cell(infoTable, 0, 0, "Tokyo Rules",
         bgcolor = tHeaderBg, text_color = tHeaderText,
         text_size = size.small, text_halign = text.align_center)
    table.cell(infoTable, 1, 0, "Rob Booker",
         bgcolor = tHeaderBg, text_color = tHeaderText,
         text_size = size.small, text_halign = text.align_center)

    table.cell(infoTable, 0, 1, "Phase",
         bgcolor = tLabelBg, text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 1, phaseName(phaseNum),
         bgcolor = tLabelBg, text_color = phaseTextColor(phaseNum),
         text_size = size.small, text_halign = text.align_center)

    dirText  = isShibuyaBull or isShinagawaBull ? "Up   [+]" :
               isShibuyaBear or isShinagawaBear ? "Down [-]" : "Sideways [=]"
    dirColor = isShibuyaBull or isShinagawaBull ? color.lime :
               isShibuyaBear or isShinagawaBear ? color.red  : color.yellow
    table.cell(infoTable, 0, 2, "Direction",
         bgcolor = tLabelBg, text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 2, dirText,
         bgcolor = tLabelBg, text_color = dirColor,
         text_size = size.small, text_halign = text.align_center)

    table.cell(infoTable, 0, 3, "EMA 62",
         bgcolor = tLabelBg, text_color = color.orange, text_size = size.small)
    table.cell(infoTable, 1, 3, str.tostring(ema62, "#.####"),
         bgcolor = tLabelBg, text_color = color.orange,
         text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 4, "SMA 200",
         bgcolor = tLabelBg, text_color = color.blue, text_size = size.small)
    table.cell(infoTable, 1, 4, str.tostring(sma200, "#.####"),
         bgcolor = tLabelBg, text_color = color.blue,
         text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 5, "SMA 800",
         bgcolor = tLabelBg, text_color = color.red, text_size = size.small)
    table.cell(infoTable, 1, 5, str.tostring(sma800, "#.####"),
         bgcolor = tLabelBg, text_color = color.red,
         text_size = size.small, text_halign = text.align_right)

    stochText  = str.tostring(math.round(stochK, 1))
    stochColor = stochK > stoch_ob ? color.red : stochK < stoch_os ? color.lime : color.white
    table.cell(infoTable, 0, 6, "Stoch %K",
         bgcolor = tLabelBg, text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 6, stochText,
         bgcolor = tLabelBg, text_color = stochColor,
         text_size = size.small, text_halign = text.align_right)

// =============================================================================
// ── ALERTS ──
//   alertcondition message must be a constant string (no dynamic concatenation)
// =============================================================================
alertcondition(showBullDiv and stochBullConfirm,
     title   = "Bullish Divergence (Stoch Confirmed)",
     message = "Tokyo Rules: Bullish Divergence detected. Check Phase label on chart.")

alertcondition(showBearDiv and stochBearConfirm,
     title   = "Bearish Divergence (Stoch Confirmed)",
     message = "Tokyo Rules: Bearish Divergence detected. Check Phase label on chart.")

alertcondition(phaseChanged,
     title   = "Phase Changed",
     message = "Tokyo Rules: Market phase has changed. Check Phase label on chart.")
````
