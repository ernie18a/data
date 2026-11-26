# Trend-following MTF EMA Entries [CocoChoco]

- url: https://www.tradingview.com/script/RTyck5oR-Trend-following-MTF-EMA-Entries-CocoChoco/
- type: indicator
- pine_id: PUB;1d678e27e99849fb9bfc284e602ebcd8
- version: 1.0

## Description

**MTF EMA Entries [CocoChoco]** is a multi-timeframe trend-following indicator designed to identify high-probability entry points using EMA alignment and trend strength confirmation.

The script evaluates price relative to a configurable EMA (default 20) across three timeframes: a lower “execution” TF and two higher TFs. 

A directional bias is established when price is above/below the EMA *and* the EMA slope confirms momentum (rising for longs, falling for shorts). 

Trade signals are generated only when all three timeframes are fully aligned in the same direction.

To filter out weak or ranging conditions, an ADX-based strength filter (default threshold: 18) is applied on the execution timeframe, requiring increasing trend strength before allowing entries.

**Entries**

* Long: All timeframes bullish (price > EMA + rising EMA) + ADX confirmation
* Short: All timeframes bearish (price < EMA + falling EMA) + ADX confirmation
* Signals trigger once per move (no repeated entries)

**Exits**

* Triggered on price crossing back through the EMA on the execution timeframe

**Features**

* Optional EMA overlay
* Clean entry/exit markers
* Real-time dashboard showing trend alignment across timeframes
* Alert conditions for bullish and bearish entries

Best suited for traders seeking structured, trend-aligned entries with built-in momentum confirmation.

## Source Code

````pine
//@version=6
indicator("MTF EMA Entries [CocoChoco]", overlay=true, max_labels_count=500)

// --- INPUTS ---
tf   = input.timeframe("5",  "Execution Timeframe (TF)",  group="Timeframes")
htf1 = input.timeframe("15", "Higher Timeframe 1 (HTF1)", group="Timeframes")
htf2 = input.timeframe("60", "Higher Timeframe 2 (HTF2)", group="Timeframes")
emaLen = input.int(20, "EMA Length", group="Settings")

adxThresh = input.float(18.0, "ADX Threshold", group="ADX Filter")
adxLen    = input.int(14,     "ADX Length",     group="ADX Filter")

showEMA  = input.bool(true,        "Show EMA",  group="EMA Display")
emaColor = input.color(color.blue, "EMA Color", group="EMA Display")

// --- EMA + PRICE + SLOPE ON EACH TF ---
get_signal(tf) =>
    float _close   = request.security(syminfo.tickerid, tf, close,                    barmerge.gaps_off, barmerge.lookahead_off)
    float _ema     = request.security(syminfo.tickerid, tf, ta.ema(close, emaLen),    barmerge.gaps_off, barmerge.lookahead_off)
    float _emaPrev = request.security(syminfo.tickerid, tf, ta.ema(close, emaLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
    bool  _slopeUp = _ema > _emaPrev
    bool  _slopeDn = _ema < _emaPrev
    int   _dir     = (_close > _ema and _slopeUp) ? 1 : (_close < _ema and _slopeDn) ? -1 : 0
    [_close, _ema, _dir]

[tfClose,   tfEMA,   tfDir]   = get_signal(tf)
[htf1Close, htf1EMA, htf1Dir] = get_signal(htf1)
[htf2Close, htf2EMA, htf2Dir] = get_signal(htf2)

// --- ADX (calculated on execution TF) ---
adxRaw() =>
    [_plus, _minus, _adx] = ta.dmi(adxLen, adxLen)
    _adx

adxValue = request.security(syminfo.tickerid, tf, adxRaw(), barmerge.gaps_off, barmerge.lookahead_off)
adxPrev  = request.security(syminfo.tickerid, tf, adxRaw()[1], barmerge.gaps_off, barmerge.lookahead_off)
adxFilter = adxValue > adxThresh and adxValue > adxPrev

// --- BASE TF CHECK ---
isBaseTF = timeframe.period == tf

// --- CROSS CONDITIONS (global scope to avoid CW10002) ---
crossUnderEMA = ta.crossunder(tfClose, tfEMA)
crossOverEMA  = ta.crossover(tfClose, tfEMA)

// --- SIGNALS ---
longSignal  = isBaseTF and tfDir == 1  and htf1Dir == 1  and htf2Dir == 1  and adxFilter
shortSignal = isBaseTF and tfDir == -1 and htf1Dir == -1 and htf2Dir == -1 and adxFilter

// --- EXIT CONDITIONS ---
exitLongRaw  = isBaseTF and crossUnderEMA
exitShortRaw = isBaseTF and crossOverEMA

// --- TRADE STATE ---
var bool inLong  = false
var bool inShort = false

if longSignal
    inLong  := true
    inShort := false
if shortSignal
    inShort := true
    inLong  := false

exitLong  = inLong  and exitLongRaw  and not exitLongRaw[1]
exitShort = inShort and exitShortRaw and not exitShortRaw[1]

if exitLong
    inLong := false
if exitShort
    inShort := false

// --- ENTRY SIGNALS (first bar only, on close) ---
var bool wasInLong  = false
var bool wasInShort = false

longEntry  = longSignal  and not wasInLong
shortEntry = shortSignal and not wasInShort

if longSignal
    wasInLong  := true
    wasInShort := false
else if not longSignal and wasInLong and (exitLongRaw or tfDir != 1)
    wasInLong := false

if shortSignal
    wasInShort := true
    wasInLong  := false
else if not shortSignal and wasInShort and (exitShortRaw or tfDir != -1)
    wasInShort := false

// --- VISUALS ---
plot(showEMA ? tfEMA : na, title="EMA", color=emaColor, linewidth=2)

plotshape(longEntry,             "Long Entry",  shape.triangleup,   location.belowbar, color.green,  size=size.small)
plotshape(shortEntry,            "Short Entry", shape.triangledown, location.abovebar, color.red,    size=size.small)
plotshape(exitLong or exitShort, "Exit Signal", shape.xcross,       location.belowbar, color.yellow, size=size.tiny)

// --- ALERTS ---
alertcondition(longEntry,  "Bullish Entry", "Bullish Entry Signal fired")
alertcondition(shortEntry, "Bearish Entry", "Bearish Entry Signal fired")

// --- DASHBOARD ---
var table dash = table.new(position.top_right, 2, 4, border_width=1)
if barstate.islast
    if isBaseTF
        table.cell(dash, 0, 0, "TF",    bgcolor=color.gray, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 0, "EMA " + str.tostring(emaLen), bgcolor=color.gray, text_color=color.white, text_size=size.small)
        table.cell(dash, 0, 1, tf,   bgcolor=color.gray, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 1, tfDir   == 1 ? "▲" : tfDir   == -1 ? "▼" : "–", bgcolor=tfDir   == 1 ? color.green : tfDir   == -1 ? color.red : color.gray, text_size=size.small)
        table.cell(dash, 0, 2, htf1,  bgcolor=color.gray, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 2, htf1Dir == 1 ? "▲" : htf1Dir == -1 ? "▼" : "–", bgcolor=htf1Dir == 1 ? color.green : htf1Dir == -1 ? color.red : color.gray, text_size=size.small)
        table.cell(dash, 0, 3, htf2,  bgcolor=color.gray, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 3, htf2Dir == 1 ? "▲" : htf2Dir == -1 ? "▼" : "–", bgcolor=htf2Dir == 1 ? color.green : htf2Dir == -1 ? color.red : color.gray, text_size=size.small)
    else
        table.cell(dash, 0, 0, "Set chart to\n" + tf + " timeframe", bgcolor=color.gray, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 0, "", bgcolor=color.gray)
````
