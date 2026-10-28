# GEX Levels [SYNC & TRADE]

- url: https://www.tradingview.com/script/pslwtnmH-gex-levels-sync-trade/
- type: indicator
- pine_id: PUB;fa7fa7fa9376426faeaf9c798395e352
- version: 2.0

## Description

# GEX Levels [SYNC & TRADE]

This indicator plots key options gamma levels on your chart and turns raw dashboard numbers into a plain-language read: where the market accelerates, where it brakes, where it's being pulled, and what counts as a trigger versus wishful thinking.

Data is not pulled automatically (Pine has no access to external APIs). You paste one line of numbers — the indicator draws everything and explains it. Source code is open.

---

## What it draws on the chart

Four levels as lines on price:

- **Resistance (Call Wall)** — first serious obstacle above.
- **Support (Put Wall)** — nearest floor below.
- **Boundary (Zero-Gamma / Flip)** — the divide between the "calm" and the "sharp-move" zone.
- **Springboard (Breakout)** — the level above which the acceleration starts.

Levels at the same price merge into one label. Lines can be limited to the current day or extended across the whole chart.

---

## What's in the table (bottom panel)

Nine rows, each a separate layer of meaning:

1. **Net GEX** — the character of the move: market "with brakes" (dips get bought) or "without brakes" (sharp swings both ways).
2. **Bias** — the options skew: bullish / bearish / neutral.
3. **P/C** — put/call ratio: more downside protection bought, or more upside bets.
4. **RV/IV** — realized vs. implied volatility: market already moving stronger or calmer than priced in.
5. **Boundary** — where price sits relative to flip: in the sharp-move zone or the calm one.
6. **Wall** — the meaning of resistance as a decision point.
7. **Springboard** — the short-squeeze mechanics when price holds above.
8. **Magnet (Pin)** — where, and how strongly, price is being pulled.
9. **Verdict** — a dynamic conclusion from the current price position: upside acceleration / downside zone / between the lines.

Row colors shift with meaning (red — downside risk, green — upside, gray — neutral).

---

## Settings

- **Language / Язык** — RU or EN. Switches the whole table and the level names.
- **Day Window** — start of a new GEX day: UTC 00:00, Deribit 08:00 UTC (expiry), or MSK 00:00.
- **Style** — line width, colors, label background, price display, merging of nearby levels.
- **Info Panel** — panel visibility and text size.

## Alerts

- **Flip cross** — price crossed the gamma flip, the regime has changed → reassess your thesis.
- **New day** — a new GEX day has started → refresh the dashboard data.

---

## How to use

1. Open the cryptogamma.io dashboard for the asset you need (BTC / ETH).
2. Copy the text with the numbers.
3. Run it through the converter prompt below (any AI) → you get one line.
4. Paste the line into the **GEX data** field in the indicator settings.
5. Refresh once a day (or on the new-day alert).

### Data line format

```
res=63000; sup=60000; flip=62000; brk=64500; regime=bearish; ng=-113830; rv=54.05; iv=48.89; pinlvl=63000; pinf=low
```

Separator is `;`. A missing key or a value of `0` hides that level/field.

---

## Converter prompt (paste into any AI)

```
You are an options gamma-data parser. I'll give you text from the
cryptogamma.io dashboard for BTC or ETH. Extract the values and return
EXACTLY ONE line in this format:

res=<price>; sup=<price>; flip=<price>; brk=<price>; regime=<bullish|bearish|neutral>; ng=<integer>; pcr=<number>; rv=<number>; iv=<number>; pinlvl=<price>; pinf=<low|med|high>

Key meanings:
- res    — Call Wall / nearest resistance above
- sup    — Put Wall / nearest support below
- flip   — Zero Gamma / Gamma Flip
- brk    — Breakout level, if given
- regime — overall bias: bullish / bearish / neutral
- ng     — Net GEX as a WHOLE NUMBER, no K/M, no commas (e.g. -113830)
- pcr    — Put/Call ratio (number)
- rv     — Realized Volatility (number)
- iv     — Implied Volatility (number)
- pinlvl — Pin / Max Pain level (price)
- pinf   — pin strength: low / med / high

Rules:
- If a value isn't in the text — skip that key entirely, don't write blanks.
- No spaces inside values. Separator is ';' only.
- No explanations or comments — return ONLY the line.

Dashboard text:
[paste here]
```

---

## Important

This indicator is an **analytical tool, not a signal**. The levels and panel show how forces are stacked in the options market at the moment of the data, but they don't predict direction and aren't a trade recommendation. Entry decisions, position sizing, and risk management are the user's responsibility.

Data must be refreshed manually: the numbers go stale with each new day and every large move.

---

*© SYNC & TRADE — @synchrotrading*

## Source Code

````pine
// © SYNC-AND-TRADE
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
// ** Copyright Notice **
// ** © TradingStrategyCourses 2026. All rights reserved. **
// 16.06.2026 - GEX Levels - verbose panel + dynamic verdict + RU/EN + dynamic wall/springboard - v14
//@version=6
indicator("GEX Levels [SYNC & TRADE]",
         overlay = true,
         max_lines_count = 500,
         max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
// DATA INPUT - one line, format key=value separated by ";"
// ═══════════════════════════════════════════════════════════════════════════
// LEVELS:  res=Resistance  sup=Support  flip=Zero-Gamma  brk=Breakout
// PANEL :  regime=bullish|bearish|neutral  ng=NetGamma  pcr=Put/Call
//          rv=RealizedVol  iv=ImpliedVol  pinlvl=PinLevel  pinf=low|med|high
// 0 or a missing key = level/field hidden

srcText = input.text_area("res=63000; sup=60000; flip=62000; brk=64500; regime=bearish; ng=-113830; rv=54.05; iv=48.89; pinlvl=63000; pinf=low", "GEX data (paste line)", group="GEX Data", tooltip="Paste ONE line. Format: key=value separated by ';'\n\nLEVELS:\n  res = Resistance (Call Wall)\n  sup = Support (Put Wall)\n  flip = Zero-Gamma / Gamma Flip\n  brk = Breakout\n\nPANEL:\n  regime = bullish | bearish | neutral\n  ng = Net Gamma   pcr = Put/Call ratio\n  rv = Realized Vol   iv = Implied Vol\n  pinlvl = Pin level (price)   pinf = low | med | high\n\n0 or a missing key hides that level/field.\nLevels on the same price are merged into one label.\n\nData source: cryptogamma.io dashboard (BTC/ETH).")

// === Day Window ===
dayBound  = input.bool(true, "Levels within current day only", group="Day Window", tooltip="Lines live from the day boundary to the next.\nOff = lines span the whole chart.")
dayBndChoice = input.string("UTC 00:00", "Day boundary", options=["UTC 00:00", "Deribit 08:00 UTC", "MSK 00:00"], group="Day Window", tooltip="When a new GEX-day starts.\nUTC 00:00 = 03:00 MSK\nDeribit 08:00 UTC = expiry time = 11:00 MSK\nMSK 00:00 = your local midnight")

// === Review Signals (alerts only, no chart markers) ===
// Alerts fire on flip cross and new day. Add them via the TradingView alert dialog.

// === Style ===
lineWidth   = input.int(2, "Line width", minval=1, maxval=4, group="Style")
labelOffset = input.int(5, "Label offset right (bars, full-width mode)", minval=0, maxval=50, group="Style")
showPrice   = input.bool(true, "Show price in label", group="Style")
mergeTol    = input.float(0, "Merge labels within (price)", minval=0, group="Style", tooltip="Levels closer than this distance are merged into one label.\n0 = merge only exact matches.")

labelBg     = input.bool(false, "Colored label background", group="Style", tooltip="Off = no background, gray text.\nOn = colored background per level, white text.")
labelTxtCol = input.color(#787B86, "Label text color (no-background mode)", group="Style")

colRes  = input.color(#C62828, "Color: Resistance", group="Style", inline="c1")
colSup  = input.color(#1B5E20, "Color: Support",    group="Style", inline="c1")
colFlip = input.color(#455A64, "Color: Flip",       group="Style", inline="c2")
colBrk  = input.color(#6A1B9A, "Color: Breakout",   group="Style", inline="c2")

// === Info Panel ===
showPanel = input.bool(true, "Show info panel", group="Info Panel")
panelSize = input.string("small", "Panel text size", options=["tiny", "small", "normal", "large"], group="Info Panel")
langChoice = input.string("RU", "Language / Язык", options=["RU", "EN"], group="Info Panel")
isEN = langChoice == "EN"

// ═══════════════════════════════════════════════════════════════════════════
// PARSER
// ═══════════════════════════════════════════════════════════════════════════

f_num(_src, _key) =>
    float _r = na
    _parts = str.split(_src, ";")
    for _p in _parts
        _kv = str.split(_p, "=")
        if array.size(_kv) == 2 and str.lower(array.get(_kv, 0)) == _key
            _r := str.tonumber(array.get(_kv, 1))
    _r

f_txt(_src, _key) =>
    string _r = ""
    _parts = str.split(_src, ";")
    for _p in _parts
        _kv = str.split(_p, "=")
        if array.size(_kv) == 2 and str.lower(array.get(_kv, 0)) == _key
            _r := array.get(_kv, 1)
    _r

f_grp(_n) =>
    _s = str.tostring(math.round(_n), "#")
    _len = str.length(_s)
    _out = ""
    for _i = 0 to _len - 1
        _out := _out + str.substring(_s, _i, _i + 1)
        _rem = _len - 1 - _i
        if _rem > 0 and _rem % 3 == 0
            _out := _out + ","
    _out

f_k(_n) =>
    _v = _n / 1000
    _v == math.round(_v) ? str.tostring(math.round(_v)) + "K" : str.tostring(_v, "#.#") + "K"

var float  gRes  = na
var float  gSup  = na
var float  gFlip = na
var float  gBrk  = na
var float  gNg   = na
var float  gPcr  = na
var float  gRv   = na
var float  gIv   = na
var float  gPinL = na
var string gReg  = "neutral"
var string gPinF = ""

if barstate.isfirst
    _clean = str.replace_all(srcText, " ", "")
    gRes  := f_num(_clean, "res")
    gSup  := f_num(_clean, "sup")
    gFlip := f_num(_clean, "flip")
    gBrk  := f_num(_clean, "brk")
    gNg   := f_num(_clean, "ng")
    gPcr  := f_num(_clean, "pcr")
    gRv   := f_num(_clean, "rv")
    gIv   := f_num(_clean, "iv")
    gPinL := f_num(_clean, "pinlvl")
    _reg  = str.lower(f_txt(_clean, "regime"))
    gReg  := _reg == "" ? "neutral" : _reg
    gPinF := str.lower(f_txt(_clean, "pinf"))

// ═══════════════════════════════════════════════════════════════════════════
// DAY BOUNDARY (selectable)
// ═══════════════════════════════════════════════════════════════════════════

_tz = dayBndChoice == "MSK 00:00" ? "Europe/Moscow" : "UTC"
_hr = dayBndChoice == "Deribit 08:00 UTC" ? 8 : 0
dayStart = timestamp(_tz, year(time, _tz), month(time, _tz), dayofmonth(time, _tz), _hr, 0)
if time < dayStart
    dayStart := dayStart - 86400000
dayEnd = dayStart + 86400000

// ═══════════════════════════════════════════════════════════════════════════
// LEVELS
// ═══════════════════════════════════════════════════════════════════════════

var array<line>  gLines  = array.new<line>()
var array<label> gLabels = array.new<label>()

f_draw(_price, _txt, _col) =>
    _bg = labelBg ? _col : color.new(color.gray, 100)
    _tc = labelBg ? color.white : labelTxtCol
    line  _ln = na
    label _lb = na
    if dayBound
        _ln := line.new(dayStart, _price, dayEnd, _price, xloc=xloc.bar_time, extend=extend.none, color=_col, width=lineWidth)
        _lb := label.new(dayEnd, _price, _txt, xloc=xloc.bar_time, style=label.style_label_left, color=_bg, textcolor=_tc, size=size.normal)
    else
        _ln := line.new(bar_index, _price, bar_index - 1, _price, xloc=xloc.bar_index, extend=extend.both, color=_col, width=lineWidth)
        _lb := label.new(bar_index + labelOffset, _price, _txt, xloc=xloc.bar_index, style=label.style_label_left, color=_bg, textcolor=_tc, size=size.normal)
    array.push(gLines, _ln)
    array.push(gLabels, _lb)

if barstate.islast
    for _l in gLines
        line.delete(_l)
    array.clear(gLines)
    for _b in gLabels
        label.delete(_b)
    array.clear(gLabels)

    pr = array.new<float>()
    nm = array.new<string>()
    cl = array.new<color>()
    if not na(gRes) and gRes > 0
        array.push(pr, gRes)
        array.push(nm, isEN ? "Resistance" : "Сопротивление")
        array.push(cl, colRes)
    if not na(gSup) and gSup > 0
        array.push(pr, gSup)
        array.push(nm, isEN ? "Support" : "Поддержка")
        array.push(cl, colSup)
    if not na(gBrk) and gBrk > 0
        array.push(pr, gBrk)
        array.push(nm, isEN ? "Breakout" : "Пробой")
        array.push(cl, colBrk)
    if not na(gFlip) and gFlip > 0
        array.push(pr, gFlip)
        array.push(nm, isEN ? "Flip" : "Граница")
        array.push(cl, colFlip)

    n = array.size(pr)
    if n > 0
        used = array.new<bool>(n, false)
        for i = 0 to n - 1
            if not array.get(used, i)
                _nm = array.get(nm, i)
                _pp = array.get(pr, i)
                _cc = array.get(cl, i)
                if i < n - 1
                    for j = i + 1 to n - 1
                        if not array.get(used, j) and math.abs(array.get(pr, j) - _pp) <= mergeTol
                            _nm := _nm + " / " + array.get(nm, j)
                            array.set(used, j, true)
                array.set(used, i, true)
                _full = showPrice ? _nm + " " + str.tostring(_pp, "#.##") : _nm
                f_draw(_pp, _full, _cc)

// ═══════════════════════════════════════════════════════════════════════════
// REVIEW SIGNALS — flip cross + new day
// ═══════════════════════════════════════════════════════════════════════════

_flipUp = not na(gFlip) and gFlip > 0 and ta.crossover(close, gFlip)
_flipDn = not na(gFlip) and gFlip > 0 and ta.crossunder(close, gFlip)
flipCross = _flipUp or _flipDn
newDay    = ta.change(dayStart) != 0 and not barstate.isfirst

alertcondition(flipCross, "Flip cross — пересмотр", "Цена пересекла gamma flip — режим сменился, пересмотри тезис")
alertcondition(newDay, "Новый день — обнови GEX", "Начался новый GEX-день — обнови данные с дашборда")

// ═══════════════════════════════════════════════════════════════════════════
// ПОЯСНИТЕЛЬНАЯ ПАНЕЛЬ — низ по центру, развёрнутый человеческий язык
// ═══════════════════════════════════════════════════════════════════════════

var table panel = table.new(position.bottom_center, 2, 9, border_width=0)
cLabel  = #787B86
cBear   = #C62828
cBull   = #1B5E20
cFlat   = #455A64

pSize = panelSize == "tiny" ? size.tiny : panelSize == "small" ? size.small : panelSize == "large" ? size.large : size.normal

if showPanel and barstate.islast
    _negG = not na(gNg) and gNg < 0
    _posG = not na(gNg) and gNg > 0
    _ngK  = na(gNg) ? "—" : str.tostring(gNg / 1000, "#.#") + "K"

    // 1. Режим (знак Net GEX = только характер движения, не направление)
    _regimeMsg = na(gNg) ? "—" : _negG ? (isEN ? "🔴 Market WITHOUT BRAKES: big players amplify moves instead of dampening them. Sharp swings BOTH ways" : "🔴 Рынок БЕЗ ТОРМОЗОВ: крупные игроки не гасят движение, а усиливают его. Ходы резкие в ОБЕ стороны") : (isEN ? "🟢 Market WITH BRAKES: big players dampen moves, dips get bought, spikes fade" : "🟢 Рынок С ТОРМОЗАМИ: крупные игроки гасят движение, провалы выкупаются, рывки затухают")
    _regimeCol = _negG ? cBear : _posG ? cBull : cLabel

    // 2. Настрой рынка (метка дашборда)
    _biasMsg = gReg == "bearish" ? (isEN ? "🔴 Bearish: options skewed toward downside bets" : "🔴 Медвежий: в опционах перевес ставок на снижение") : gReg == "bullish" ? (isEN ? "🟢 Bullish: options skewed toward upside bets" : "🟢 Бычий: в опционах перевес ставок на рост") : (isEN ? "🟡 Neutral: no clear skew" : "🟡 Нейтральный: явного перевеса нет")
    _biasCol = gReg == "bullish" ? cBull : gReg == "bearish" ? cBear : cFlat

    // 3. P/C
    _pcrTxt = na(gPcr) ? "—" : str.tostring(gPcr, "#.##")
    _bbMsg  = na(gPcr) ? "—" : gPcr > 1.0 ? (isEN ? "🐻 More downside protection bought than upside bets" : "🐻 Страховок от падения куплено больше, чем ставок на рост") : gPcr < 1.0 ? (isEN ? "🐂 More upside bets than downside protection" : "🐂 Ставок на рост больше, чем страховок от падения") : (isEN ? "⚖️ Balanced: market undecided" : "⚖️ Поровну: рынок не определился")
    _bbCol  = na(gPcr) ? cLabel : gPcr > 1.0 ? cBear : gPcr < 1.0 ? cBull : cFlat

    // 4. Размах (RV/IV)
    _rvTxt  = na(gRv) ? "—" : str.tostring(gRv, "#.#")
    _ivTxt  = na(gIv) ? "—" : str.tostring(gIv, "#.#")
    _volMsg = (na(gRv) or na(gIv)) ? "—" : gRv > gIv ? (isEN ? "🌊 Market already moving STRONGER than options price in. About range, not direction" : "🌊 Рынок уже ходит СИЛЬНЕЕ, чем закладывают опционы. Это про размах, не про направление") : (isEN ? "😴 Market moving calmer than options price in" : "😴 Рынок ходит спокойнее, чем закладывают опционы")
    _volCol = (na(gRv) or na(gIv)) ? cLabel : gRv > gIv ? cBear : cFlat

    // 5. Граница (flip)
    _flipMsg = na(gFlip) ? "—" : close < gFlip ? (isEN ? "Price BELOW the line → we're in the sharp-move zone" : "Цена НИЖЕ границы → мы в зоне резких ходов") : (isEN ? "Price ABOVE the line → we're in the calm zone" : "Цена ВЫШЕ границы → мы в спокойной зоне")
    _flipLbl = na(gFlip) ? (isEN ? "Boundary" : "Граница") : (isEN ? "Boundary $" : "Граница $") + f_grp(gFlip)

    // 6. Стена (res) — динамична: ниже стены = препятствие; выше = пробита, работает как поддержка
    _resMsg = na(gRes) ? "—" : close < gRes ? (isEN ? "First serious obstacle on the way up. Approaching it is a place to decide, not to hope" : "Первое серьёзное препятствие на пути вверх. Подход к ней — место для решения, не для надежды") : (isEN ? "✅ Price ABOVE the wall: broken, now acts as support on a pullback" : "✅ Цена УЖЕ выше стены: пробита, теперь работает как поддержка при возврате")
    _resLbl = na(gRes) ? (isEN ? "Wall" : "Стена") : (isEN ? "Wall $" : "Стена $") + f_grp(gRes)

    // 7. Трамплин (brk) — динамичен: ниже = условие; выше = факт срабатывания
    _brkMsg = na(gBrk) ? "—" : close > gBrk ? (isEN ? "✅ Already ABOVE: shorts squeezed, forced buying fuels the move up 🚀" : "✅ Цена УЖЕ выше: шорты под выносом, их вынужденные покупки разгоняют рост 🚀") : (isEN ? "Holding ABOVE squeezes the shorts: they're forced to BUY, driving price up 🚀" : "Закрепление ВЫШЕ вынесет шортов: вынуждены ПОКУПАТЬ, покупки разгонят цену вверх 🚀")
    _brkLbl = na(gBrk) ? (isEN ? "Springboard" : "Трамплин") : (isEN ? "Springboard $" : "Трамплин $") + f_grp(gBrk)

    // 8. Магнит (pin)
    _pinForce = gPinF == "low" ? (isEN ? "weak" : "слабый") : gPinF == "med" ? (isEN ? "medium" : "средний") : gPinF == "high" ? (isEN ? "strong" : "сильный") : "—"
    _pinStrong = isEN ? "strong" : "сильный"
    _pinMsg   = na(gPinL) ? "—" : _pinForce == _pinStrong ? (isEN ? "🧲 Strong: price is pulled and held at $" + f_grp(gPinL) : "🧲 Сильный: цену притягивает и держит у $" + f_grp(gPinL)) : (isEN ? "🧲 " + _pinForce + " at $" + f_grp(gPinL) + ": there's a pull, but it won't hold price" : "🧲 " + _pinForce + " у $" + f_grp(gPinL) + ": притяжение есть, но цену не удержит")

    // 9. Вывод — динамический, от положения цены
    _supS = na(gSup) ? "—" : "$" + f_k(gSup)
    _verdict = (na(gFlip) or na(gBrk)) ? "—" : close > gBrk ? (isEN ? "UPSIDE ACCELERATION: price above the springboard, dealers forced to buy — fuel for the move up 🚀" : "РАЗГОН ВВЕРХ: цена выше трамплина, дилеры вынуждены откупать — топливо для роста 🚀") : close < gFlip ? (isEN ? "DOWNSIDE ZONE: price pulled down toward " + _supS + ". A close below " + _supS + " = the drop ACCELERATES, this is not the bottom" : "ЗОНА ПАДЕНИЯ: цену тянет вниз к " + _supS + ". Пробой " + _supS + " с закрытием = падение УСКОРИТСЯ, это не дно") : (isEN ? "BETWEEN THE LINES: price pinned $" + f_k(gFlip) + "–$" + f_k(gBrk) + ". Whichever way it closes out is where it goes" : "МЕЖДУ ГРАНИЦ: цена зажата $" + f_k(gFlip) + "–$" + f_k(gBrk) + ". Куда выйдет с закрытием — туда и поедем")
    _verdictCol = (na(gFlip) or na(gBrk)) ? cLabel : close > gBrk ? cBull : close < gFlip ? cBear : cFlat

    table.cell(panel, 0, 0, "Net GEX " + _ngK, text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 0, _regimeMsg, text_color=_regimeCol, text_halign=text.align_left, bgcolor=na, text_size=pSize)

    table.cell(panel, 0, 1, isEN ? "Bias" : "Настрой", text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 1, _biasMsg, text_color=_biasCol, text_halign=text.align_left, bgcolor=na, text_size=pSize)

    table.cell(panel, 0, 2, "P/C " + _pcrTxt, text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 2, _bbMsg, text_color=_bbCol, text_halign=text.align_left, bgcolor=na, text_size=pSize)

    table.cell(panel, 0, 3, "RV/IV " + _rvTxt + "/" + _ivTxt, text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 3, _volMsg, text_color=_volCol, text_halign=text.align_left, bgcolor=na, text_size=pSize)

    table.cell(panel, 0, 4, _flipLbl, text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 4, _flipMsg, text_color=cFlat, text_halign=text.align_left, bgcolor=na, text_size=pSize)

    table.cell(panel, 0, 5, _resLbl, text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 5, _resMsg, text_color=cFlat, text_halign=text.align_left, bgcolor=na, text_size=pSize)

    table.cell(panel, 0, 6, _brkLbl, text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 6, _brkMsg, text_color=cFlat, text_halign=text.align_left, bgcolor=na, text_size=pSize)

    table.cell(panel, 0, 7, isEN ? "🧲 Magnet" : "🧲 Магнит", text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 7, _pinMsg, text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)

    table.cell(panel, 0, 8, isEN ? "⚠️ Verdict" : "⚠️ Вывод", text_color=cLabel, text_halign=text.align_left, bgcolor=na, text_size=pSize)
    table.cell(panel, 1, 8, _verdict, text_color=_verdictCol, text_halign=text.align_left, bgcolor=na, text_size=pSize)
````
