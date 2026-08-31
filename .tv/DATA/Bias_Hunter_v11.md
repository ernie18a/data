<!-- tradingview-pine-id: PUB;f91f299412934d1c84a2ff3dbaf0aecd -->
<!-- tradingviewscripts-format: 1 -->
# Bias Hunter v1.1

Source: https://www.tradingview.com/script/1PlLEhSn-Bias-Hunter-v1-1/

## Description

Bias Hunter v1.1 ... Pre-Session Bias Checklist Dashboard

Description:

Bias Hunter is a pre-session bias checklist for day traders. It condenses the routine "where are we?" questions you'd normally check by hand before a session into one dashboard, scores each factor +1 (bullish), -1 (bearish), or 0 (neutral), and shows a running tally.

It deliberately gives no LONG/SHORT verdict. The tally summarizes confluence; the trading decision stays yours.

WHAT IT CHECKS

Directional factors (each +1 / -1 / 0):

Daily open ... price above or below today's open
Prior day H/L ... above prior day high, inside the range, or below prior day low
Weekly open ... price above or below this week's open
EMA20 Daily ... price above or below the daily EMA
EMA20 4H ... price above or below the 4H EMA
VWAP ... price above or below session VWAP
RSI (regime-aware) ... in trending conditions (ADX ≥ 17) RSI above/below 50 reads as momentum. In choppy conditions it flips to mean-reversion mode and only votes at the extremes (below 30 bullish, above 70 bearish), marked "MR" on the dashboard
Prior 4H candle ... direction of the last completed 4H candle
Prior Daily candle ... direction of the last completed daily candle
Market structure ... HH/HL or LH/LL from the last confirmed pivots on Daily or 4H (selectable)

Context rows (shown but not counted in the tally):

ADX ... selectable timeframe (30m / 1H / 4H, default 1H for day trading). Green ≥ 25 (trending), yellow 17-25, white below, plus a CHOP flag under 15
Volume ... current bar volume vs its 20-bar average

TALLY

The bottom row sums all directional factors (range -10 to +10). Strong positive = broad bullish confluence, strong negative = broad bearish confluence, near zero = mixed conditions or chop.

Note: several factors are correlated by design (a strong trend day aligns most of them). A high tally means "everything agrees", not "high probability". Combine with your own entry framework.

NON-REPAINTING BY DESIGN

All higher-timeframe data pulled with lookahead off
EMAs, ADX, RSI regime, candles, and pivots use confirmed bars only
Factor states update on confirmed chart bars, so the tally does not flicker intrabar
Pivots confirm after the pivot length elapses ... structure is honest but reacts with a delay. That is the price of no repaint

SETTINGS

Structure timeframe (D or 4H) and pivot length
EMA, RSI, ADX, volume-average lengths
ADX timeframe (30m / 1H / 4H)
Dashboard position and text size

Works on any symbol and any chart timeframe ... built and tested on gold, indices, and crypto.

Part of the Hunters Trades indicator suite. Feedback welcome.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © Hunters Trades

//@version=6
indicator("Bias Hunter v1.1", shorttitle="Bias Hunter v1.1", overlay=true)

// ══════════════════════════════════════════════════════════════════
//  Bias Hunter v1.1 ... pre-session bias checklist
//  9 directional factors, +1/-1/0 each ... tally range -9..+9
//  Context rows (no tally weight): ADX regime, volume vs average
//  v1.1: selectable ADX TF (default 1H) ... added RSI (regime-aware),
//        VWAP position, prior 4H candle, prior D candle, volume context
// ══════════════════════════════════════════════════════════════════

// ── Inputs ──
grpG = "General"
structTf = input.string("D", "Structure timeframe", options=["D", "240"], group=grpG, display=display.none)
pivLen   = input.int(5, "Pivot left/right length", minval=2, maxval=20, group=grpG, display=display.none)
emaLen   = input.int(20, "EMA length (D and 4H)", minval=5, maxval=100, group=grpG, display=display.none)
adxTf    = input.string("60", "ADX timeframe", options=["30", "60", "240"], group=grpG, display=display.none, tooltip="60 = 1H, better for day trading ... 240 = 4H for swing context")
adxLen   = input.int(14, "ADX length", minval=5, maxval=50, group=grpG, display=display.none)
rsiLen   = input.int(14, "RSI length", minval=5, maxval=50, group=grpG, display=display.none)
volLen   = input.int(20, "Volume average length", minval=5, maxval=100, group=grpG, display=display.none)

grpT = "Dashboard"
tblPosStr  = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Middle Right", "Bottom Right", "Bottom Left"], group=grpT, display=display.none)
tblSizeStr = input.string("Small", "Text size", options=["Tiny", "Small", "Normal"], group=grpT, display=display.none)

tblPos = tblPosStr == "Top Left" ? position.top_left :
     tblPosStr == "Middle Right" ? position.middle_right :
     tblPosStr == "Bottom Right" ? position.bottom_right :
     tblPosStr == "Bottom Left" ? position.bottom_left :
     position.top_right

tblSize = tblSizeStr == "Tiny" ? size.tiny : tblSizeStr == "Normal" ? size.normal : size.small

// ── Colors (Trend Hunter v2.2 aesthetic) ──
colBull = color.new(color.green, 0)
colBear = color.new(color.red, 0)
colNeut = color.new(color.gray, 20)
colTxt  = color.white
colHead = color.new(color.purple, 60)
colBg   = color.new(color.black, 80)

// ══════════════════════════════════════════════════════════════════
//  HTF DATA ... confirmed bars only, lookahead off
// ══════════════════════════════════════════════════════════════════

dOpen  = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_off)
wOpen  = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_off)
pdHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)

emaD  = request.security(syminfo.tickerid, "D",   ta.ema(close, emaLen)[1], lookahead=barmerge.lookahead_off)
ema4h = request.security(syminfo.tickerid, "240", ta.ema(close, emaLen)[1], lookahead=barmerge.lookahead_off)

// prior confirmed HTF candle direction: +1 bull, -1 bear, 0 doji
f_candleDir() =>
    o = open[1]
    c = close[1]
    c > o ? 1 : c < o ? -1 : 0

cndl4h = request.security(syminfo.tickerid, "240", f_candleDir(), lookahead=barmerge.lookahead_off)
cndlD  = request.security(syminfo.tickerid, "D",   f_candleDir(), lookahead=barmerge.lookahead_off)

f_adx(_len) =>
    up = ta.change(high)
    dn = -ta.change(low)
    plusDM  = na(up) ? na : (up > dn and up > 0 ? up : 0)
    minusDM = na(dn) ? na : (dn > up and dn > 0 ? dn : 0)
    trur = ta.rma(ta.tr, _len)
    plusDI  = fixnan(100 * ta.rma(plusDM, _len) / trur)
    minusDI = fixnan(100 * ta.rma(minusDM, _len) / trur)
    sum = plusDI + minusDI
    100 * ta.rma(math.abs(plusDI - minusDI) / (sum == 0 ? 1 : sum), _len)

adxV = request.security(syminfo.tickerid, adxTf, f_adx(adxLen)[1], lookahead=barmerge.lookahead_off)

// ── Structure pivots ──
f_pivots(_len) =>
    ph = ta.pivothigh(high, _len, _len)
    pl = ta.pivotlow(low, _len, _len)
    var float lastPH = na
    var float prevPH = na
    var float lastPL = na
    var float prevPL = na
    if not na(ph)
        prevPH := lastPH
        lastPH := ph
    if not na(pl)
        prevPL := lastPL
        lastPL := pl
    [lastPH, prevPH, lastPL, prevPL]

[sPH, sPHprev, sPL, sPLprev] = request.security(syminfo.tickerid, structTf, f_pivots(pivLen), lookahead=barmerge.lookahead_off)

// ── Chart-TF series ──
rsiV  = ta.rsi(close, rsiLen)
vwapV = ta.vwap(hlc3)
volAvg = ta.sma(volume, volLen)

// ══════════════════════════════════════════════════════════════════
//  FACTOR EVALUATION ... confirmed chart bars only
// ══════════════════════════════════════════════════════════════════

var int fDailyOpen = 0
var int fPrevDay   = 0
var int fWeekOpen  = 0
var int fEmaD      = 0
var int fEma4h     = 0
var int fStruct    = 0
var int fRsi       = 0
var int fVwap      = 0
var int fCndl4h    = 0
var int fCndlD     = 0
var float vAdx     = na
var float vRsi     = na
var float volRatio = na
var string sPrevDayTxt = "..."
var string sStructTxt  = "..."
var string sRsiTxt     = "..."

if barstate.isconfirmed
    fDailyOpen := na(dOpen) ? 0 : close > dOpen ? 1 : -1
    fWeekOpen  := na(wOpen) ? 0 : close > wOpen ? 1 : -1
    fEmaD      := na(emaD)  ? 0 : close > emaD  ? 1 : -1
    fEma4h     := na(ema4h) ? 0 : close > ema4h ? 1 : -1
    fVwap      := na(vwapV) ? 0 : close > vwapV ? 1 : -1
    fCndl4h    := nz(cndl4h, 0)
    fCndlD     := nz(cndlD, 0)
    vAdx       := adxV
    volRatio   := volAvg > 0 ? volume / volAvg : na

    if na(pdHigh) or na(pdLow)
        fPrevDay := 0
        sPrevDayTxt := "..."
    else if close > pdHigh
        fPrevDay := 1
        sPrevDayTxt := "ABOVE"
    else if close < pdLow
        fPrevDay := -1
        sPrevDayTxt := "BELOW"
    else
        fPrevDay := 0
        sPrevDayTxt := "INSIDE"

    bool hhhl = not na(sPH) and not na(sPHprev) and not na(sPL) and not na(sPLprev) and sPH > sPHprev and sPL > sPLprev
    bool lhll = not na(sPH) and not na(sPHprev) and not na(sPL) and not na(sPLprev) and sPH < sPHprev and sPL < sPLprev
    fStruct    := hhhl ? 1 : lhll ? -1 : 0
    sStructTxt := hhhl ? "HH / HL" : lhll ? "LH / LL" : "MIXED"

    // RSI ... regime-aware: trend (ADX >= 17) reads momentum,
    // chop reads mean reversion at the extremes
    vRsi := rsiV
    bool trending = not na(vAdx) and vAdx >= 17
    if na(vRsi)
        fRsi := 0
        sRsiTxt := "..."
    else if trending
        fRsi := vRsi > 50 ? 1 : vRsi < 50 ? -1 : 0
        sRsiTxt := str.tostring(vRsi, "#.#")
    else
        fRsi := vRsi < 30 ? 1 : vRsi > 70 ? -1 : 0
        sRsiTxt := str.tostring(vRsi, "#.#") + " MR"

tally = fDailyOpen + fPrevDay + fWeekOpen + fEmaD + fEma4h + fStruct + fRsi + fVwap + fCndl4h + fCndlD
isChop = not na(vAdx) and vAdx < 15

// ══════════════════════════════════════════════════════════════════
//  DASHBOARD
// ══════════════════════════════════════════════════════════════════

f_dirTxt(_f) => _f == 1 ? "✅" : _f == -1 ? "❌" : "..."
f_dirCol(_f) => _f == 1 ? colBull : _f == -1 ? colBear : colNeut
f_abTxt(_f)  => _f == 1 ? "ABOVE" : _f == -1 ? "BELOW" : "..."
f_cndlTxt(_f) => _f == 1 ? "BULL" : _f == -1 ? "BEAR" : "..."

var table dash = table.new(tblPos, 2, 14, bgcolor=colBg, border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    adxCol = na(vAdx) ? colNeut : vAdx >= 25 ? colBull : vAdx >= 17 ? color.yellow : colTxt
    adxTxt = na(vAdx) ? "..." : str.tostring(vAdx, "#.#") + (isChop ? "  CHOP" : "")
    volCol = na(volRatio) ? colNeut : volRatio >= 1.5 ? colBull : volRatio >= 0.8 ? colTxt : colNeut
    volTxt = na(volRatio) ? "..." : str.tostring(volRatio, "#.##") + "x"
    tallyCol = tally > 0 ? colBull : tally < 0 ? colBear : colNeut
    tallyTxt = (tally > 0 ? "+" : "") + str.tostring(tally)
    adxTfTxt = adxTf == "60" ? "1H" : adxTf == "240" ? "4H" : "30m"

    table.cell(dash, 0, 0, "BIAS HUNTER", text_color=colTxt, text_size=tblSize, bgcolor=colHead, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.1", text_color=colTxt, text_size=tblSize, bgcolor=colHead)

    table.cell(dash, 0, 1, "Daily open", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, f_dirTxt(fDailyOpen), text_color=f_dirCol(fDailyOpen), text_size=tblSize)

    table.cell(dash, 0, 2, "Prior day H/L", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, sPrevDayTxt, text_color=f_dirCol(fPrevDay), text_size=tblSize)

    table.cell(dash, 0, 3, "Weekly open", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, f_dirTxt(fWeekOpen), text_color=f_dirCol(fWeekOpen), text_size=tblSize)

    table.cell(dash, 0, 4, "EMA" + str.tostring(emaLen) + " Daily", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, f_abTxt(fEmaD), text_color=f_dirCol(fEmaD), text_size=tblSize)

    table.cell(dash, 0, 5, "EMA" + str.tostring(emaLen) + " 4H", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, f_abTxt(fEma4h), text_color=f_dirCol(fEma4h), text_size=tblSize)

    table.cell(dash, 0, 6, "VWAP", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, f_abTxt(fVwap), text_color=f_dirCol(fVwap), text_size=tblSize)

    table.cell(dash, 0, 7, "RSI " + str.tostring(rsiLen), text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, sRsiTxt, text_color=f_dirCol(fRsi), text_size=tblSize)

    table.cell(dash, 0, 8, "4H candle", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, f_cndlTxt(fCndl4h), text_color=f_dirCol(fCndl4h), text_size=tblSize)

    table.cell(dash, 0, 9, "D candle", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 9, f_cndlTxt(fCndlD), text_color=f_dirCol(fCndlD), text_size=tblSize)

    table.cell(dash, 0, 10, "Structure " + (structTf == "D" ? "D" : "4H"), text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 10, sStructTxt, text_color=f_dirCol(fStruct), text_size=tblSize)

    table.cell(dash, 0, 11, "ADX " + adxTfTxt, text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 11, adxTxt, text_color=adxCol, text_size=tblSize)

    table.cell(dash, 0, 12, "Volume", text_color=colTxt, text_size=tblSize, text_halign=text.align_left)
    table.cell(dash, 1, 12, volTxt, text_color=volCol, text_size=tblSize)

    table.cell(dash, 0, 13, "TALLY", text_color=colTxt, text_size=tblSize, bgcolor=colHead, text_halign=text.align_left)
    table.cell(dash, 1, 13, tallyTxt, text_color=tallyCol, text_size=tblSize, bgcolor=colHead)

plot(na, title="Hidden", display=display.none)
````
