<!-- tradingview-pine-id: PUB;fe9c2088757b4296a71af4e2714388b9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market Regime Engine

Source: https://www.tradingview.com/script/MIEZDvM9-Market-Regime-Engine/

## Description

Know the market you're in before you trade it — adaptive k-means volatility + a trend/range read that tells you whether to trend-follow, fade, or stand aside.

The same setup that prints money in a trend gets chopped to pieces in a range. Market Regime Engine reads the environment first — is price TRENDING or RANGING, and is volatility LOW, NORMAL or HIGH — then tells you which playbook fits: trend-follow, fade the range, or stand aside in the chop.

── TWO HONEST, ADAPTIVE READS ──
• Volatility (self-learning) — a genuine k-means clustering (k = 3) of ATR over a rolling window. The model continually re-learns the market's own low / normal / high volatility buckets instead of using fixed thresholds, so it adapts to each symbol and timeframe. No black box, no "AI" hand-waving — just clustering you can read in the code.
• Behaviour — the Kaufman Efficiency Ratio: how much of the recent range was actual directional progress versus back-and-forth noise. Above your threshold = TRENDING, below = RANGING.

Direction (▲/▼) comes from price versus a bias EMA, so a trend is labelled TRENDING ▲ or TRENDING ▼.

── WHAT YOU SEE ──
The background (and optionally the candles) colour by regime — green up-trend, red down-trend, blue range. A label marks each regime change. Everything is confirmed on close.

── READING THE DASHBOARD ──
• Regime — the current state: TRENDING ▲, TRENDING ▼ or RANGING.
• Confidence — 0–100 conviction. For a trend it rises the further the efficiency ratio is above your threshold; for a range it rises the further below. It measures how cleanly price fits the state, not a win rate.
• Volatility — Low / Normal / High, from the k-means cluster the current ATR falls into.
• Efficiency — the raw efficiency ratio as a percent, with your threshold beside it.
• Bias — whether price is above or below the bias EMA.
• Play — the suggested approach for this regime: "Trend-follow pullbacks", "Fade the range", or "Stand aside — chop" (ranging + high volatility).

── HOW TO USE IT ──
Use it as a filter on top of your own system:
• TRENDING → take trend-following entries (pullbacks, breakouts); avoid fading.
• RANGING + Low/Normal vol → mean-reversion at the range edges works best.
• RANGING + High vol → the danger zone; expect whipsaw, size down or stand aside.
It pairs naturally with structure/SMC or momentum tools — let the regime decide which of your setups to trust right now.

── NON-REPAINTING ──
The efficiency ratio, the volatility cluster and the regime are all evaluated on closed bars (barstate.isconfirmed), so a regime label does not repaint after the fact.

── SETTINGS ──
Trend/range window, trend threshold, bias EMA, and the volatility training window (how many bars the k-means model learns from) are all adjustable, along with background/candle colouring, the regime-change labels, dashboard position/size and every colour. The defaults (efficiency window 20, trend threshold 0.35, bias EMA 100, training window 150) were chosen from out-of-sample testing across the major coins on 1H–1D — the settings where a TRENDING call carried the strongest forward directional edge.

── A NOTE ON HONESTY ──
"k-means" here is a real, transparent clustering of volatility — deliberately simple and readable, not a predictive machine-learning oracle. It classifies the current environment; it does not forecast price.

Free and open-source (Mozilla Public License 2.0) — the full logic is on the Pine tab.

This tool is for research and education. It is not financial advice and does not guarantee profit. Test on your own markets and manage your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zebris_boris
//
// ──────────────────────────────────────────────────────────────
//  Market Regime Engine  ·  v1.0  ·  Boris Tatchou
// ──────────────────────────────────────────────────────────────
//  Know the market you're in BEFORE you trade it.
//  Two honest, adaptive reads combined into one regime:
//   • Volatility — a real k-means clustering of ATR into Low /
//     Normal / High buckets that re-learns from the chart itself.
//   • Behaviour — a Kaufman efficiency ratio that separates
//     TRENDING from RANGING price.
//  The result colours the background, labels the state, scores a
//  0–100 confidence, and tells you which playbook fits right now:
//  trend-follow, fade the range, or stand aside in the chop.
//  All reads are confirmed on close — non-repainting.
//  Free & open-source. Research/education only — not financial advice.
// ──────────────────────────────────────────────────────────────
//@version=6
indicator("Market Regime Engine", "Regime", overlay = true, max_labels_count = 200)

// ── Inputs ─────────────────────────────────────────────────
gR = "① Regime engine"
gV = "② Visuals"
gD = "③ Dashboard"
gC = "④ Colors"

erLen    = input.int(20, "Trend/range window", minval = 5, maxval = 100, group = gR, tooltip = "Kaufman efficiency ratio window. Higher = smoother, slower regime switches. 20 tested best across the top coins & 1H–1D.")
erThr    = input.float(0.35, "Trend threshold", minval = 0.05, maxval = 0.90, step = 0.05, group = gR, tooltip = "Efficiency ratio above this = TRENDING, below = RANGING. 0.35 gave the best forward directional edge out-of-sample; lower = more (but weaker) trend calls.")
emaLen   = input.int(100, "Bias EMA", minval = 5, maxval = 400, group = gR, tooltip = "Direction of a trend = price above/below this EMA. 100 tested marginally best.")
trainLen = input.int(150, "Volatility training window", minval = 30, maxval = 300, group = gR, tooltip = "How many bars the k-means volatility model learns from. 150 gave sharper forward-volatility separation than 100 while staying adaptive. Re-clustered every few bars for speed; the reading updates every bar.")

showBg   = input.bool(true,  "Colour background by regime", group = gV)
showBars = input.bool(false, "Colour candles by regime",   group = gV)
showFlip = input.bool(true,  "Label regime changes",       group = gV)

showDash = input.bool(true, "Dashboard", group = gD)
dashPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Middle right", "Bottom right", "Bottom left"], group = gD)
dashSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gD)

upCol   = input.color(#26a69a, "Trending up",   group = gC)
dnCol   = input.color(#ef5350, "Trending down", group = gC)
rngCol  = input.color(#5c6bc0, "Ranging",       group = gC)
loVol   = input.color(#26c6da, "Low volatility",  group = gC)
hiVol   = input.color(#ffa726, "High volatility", group = gC)
cNeu    = color.rgb(158, 162, 174)

atr = ta.atr(14)

// ── Behaviour: Kaufman efficiency ratio (trend vs range) ───
_chg = math.abs(close - close[erLen])
_vol = math.sum(math.abs(close - close[1]), erLen)
er   = _vol != 0 ? _chg / _vol : 0.0
dir  = close > ta.ema(close, emaLen) ? 1 : -1
trending = er >= erThr

// ── Volatility: online k-means (k = 3) over a rolling ATR window ─
// A rolling array avoids deep historical look-back (stable — no buffer
// errors) and re-clusters on a cadence, not every bar (same reading, cheaper).
var float[] atrWin = array.new<float>()
if barstate.isconfirmed and not na(atr)
    array.push(atrWin, atr)
    if array.size(atrWin) > trainLen
        array.shift(atrWin)
var float cLo = na
var float cMd = na
var float cHi = na
_recluster = barstate.isconfirmed and array.size(atrWin) >= 30 and (na(cLo) or bar_index % 5 == 0 or barstate.islast)
if _recluster
    _sz = array.size(atrWin)
    float _lo = array.min(atrWin)
    float _hi = array.max(atrWin)
    float _md = (_lo + _hi) / 2.0
    for _it = 0 to 4
        float _sLo = 0.0
        float _sMd = 0.0
        float _sHi = 0.0
        int   _nLo = 0
        int   _nMd = 0
        int   _nHi = 0
        for j = 0 to _sz - 1
            _v  = array.get(atrWin, j)
            _dL = math.abs(_v - _lo)
            _dM = math.abs(_v - _md)
            _dH = math.abs(_v - _hi)
            if _dL <= _dM and _dL <= _dH
                _sLo += _v
                _nLo += 1
            else if _dH <= _dM
                _sHi += _v
                _nHi += 1
            else
                _sMd += _v
                _nMd += 1
        _lo := _nLo > 0 ? _sLo / _nLo : _lo
        _md := _nMd > 0 ? _sMd / _nMd : _md
        _hi := _nHi > 0 ? _sHi / _nHi : _hi
    // guarantee low <= mid <= high so the Low / Normal / High labels can't swap
    cLo := math.min(_lo, math.min(_md, _hi))
    cHi := math.max(_lo, math.max(_md, _hi))
    cMd := (_lo + _md + _hi) - cLo - cHi

// classify current ATR against the learned centroids
volLvl = 1
if not na(cLo)
    _dL = math.abs(atr - cLo)
    _dM = math.abs(atr - cMd)
    _dH = math.abs(atr - cHi)
    volLvl := _dL <= _dM and _dL <= _dH ? 0 : (_dH <= _dM ? 2 : 1)
volTxt = volLvl == 0 ? "Low" : volLvl == 2 ? "High" : "Normal"
volCol = volLvl == 0 ? loVol : volLvl == 2 ? hiVol : cNeu

// ── Compose the regime ─────────────────────────────────────
regTxt = trending ? (dir == 1 ? "TRENDING ▲" : "TRENDING ▼") : "RANGING"
regCol = trending ? (dir == 1 ? upCol : dnCol) : rngCol
conf   = trending ? math.round(math.min(100.0, 50.0 + (er - erThr) / math.max(1.0 - erThr, 0.01) * 50.0)) : math.round(math.min(100.0, 50.0 + (erThr - er) / math.max(erThr, 0.01) * 50.0))
play   = trending ? "Trend-follow pullbacks" : (volLvl == 2 ? "Stand aside — chop" : "Fade the range")

// ── Visuals ────────────────────────────────────────────────
bgcolor(showBg ? color.new(regCol, trending ? 82 : 88) : na, title = "Regime background")
barcolor(showBars ? regCol : na, title = "Regime candles")

var int regState = 0     // 0 ranging, 1 up, 2 down
newState = trending ? (dir == 1 ? 1 : 2) : 0
regFlip = barstate.isconfirmed and newState != regState and not na(cLo)
if barstate.isconfirmed
    regState := newState
if showFlip and regFlip
    label.new(bar_index, trending and dir == 1 ? low : high, regTxt, xloc = xloc.bar_index, style = trending and dir == 1 ? label.style_label_up : label.style_label_down, color = color.new(regCol, 10), textcolor = color.white, size = size.small)

// ── Dashboard ──────────────────────────────────────────────
_dpos = dashPos == "Top left" ? position.top_left : dashPos == "Middle right" ? position.middle_right : dashPos == "Bottom right" ? position.bottom_right : dashPos == "Bottom left" ? position.bottom_left : position.top_right
_dSz  = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : dashSize == "Huge" ? size.huge : size.small
cDhBg  = color.rgb(16, 19, 26)
cLbBg  = color.rgb(26, 30, 40)
cLbTx  = color.rgb(198, 203, 212)
cDhTx  = color.rgb(232, 234, 237)
cHdrBg = color.rgb(19, 27, 48)
cHdrTx = color.rgb(150, 180, 235)
var table dash = table.new(_dpos, 2, 7, border_width = 1, frame_color = color.rgb(42, 46, 57), bgcolor = cDhBg)
_row(r, l, v, vc) =>
    table.cell(dash, 0, r, l, bgcolor = cLbBg, text_color = cLbTx, text_size = _dSz)
    table.cell(dash, 1, r, v, bgcolor = cLbBg, text_color = vc, text_size = _dSz, text_halign = text.align_right)
_meter(_v) =>
    _f = math.max(0, math.min(5, math.round(_v / 20.0)))
    str.repeat("█", _f) + str.repeat("░", 5 - _f)
if showDash and barstate.islast
    table.cell(dash, 0, 0, "🧭 Market Regime", bgcolor = cHdrBg, text_color = cHdrTx, text_size = _dSz)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period, bgcolor = cHdrBg, text_color = cHdrTx, text_size = _dSz, text_halign = text.align_right)
    _row(1, "Regime",       regTxt, regCol)
    _row(2, "Confidence",   _meter(conf) + "  " + str.tostring(conf, "#"), regCol)
    _row(3, "Volatility",   volTxt, volCol)
    _row(4, "Efficiency",   str.tostring(er * 100, "#") + "%  (thr " + str.tostring(erThr * 100, "#") + ")", cDhTx)
    _row(5, "Bias",         dir == 1 ? "▲ above EMA" : "▼ below EMA", dir == 1 ? upCol : dnCol)
    _row(6, "Play",         play, regCol)

// ── Alerts ─────────────────────────────────────────────────
alertcondition(regFlip and newState == 1, "Turned trending up",   "Regime: TRENDING UP on {{ticker}} ({{interval}})")
alertcondition(regFlip and newState == 2, "Turned trending down", "Regime: TRENDING DOWN on {{ticker}} ({{interval}})")
alertcondition(regFlip and newState == 0, "Turned ranging",       "Regime: RANGING on {{ticker}} ({{interval}})")
alertcondition(regFlip, "Regime changed", "Regime change on {{ticker}} ({{interval}})")
````
