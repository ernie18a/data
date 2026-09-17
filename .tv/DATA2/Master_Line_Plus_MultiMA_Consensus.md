<!-- tradingview-pine-id: PUB;7f443a75fda84bbc981751dcb24170cf -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Master Line Plus · Multi-MA Consensus

Source: https://www.tradingview.com/script/zv91H545-Master-Line-Plus-Multi-MA-Consensus/

## Description

Master Line Plus — Multi-MA Consensus with Agreement Score

Master Line Plus blends eight different moving-average families into a single consensus trend line, measures how strongly those averages agree, and filters direction with a volatility-aware band. It's a clean, open-source way to read one trend reference — plus a sense of how much conviction is behind it — instead of stacking many moving averages on the chart.

How it works

Every moving-average type reacts to price differently. EMA and WMA weight recent bars heavily and turn quickly; SMA weights all bars equally and turns slowly; RMA (Wilder's) is the smoothest; HMA cuts lag while staying responsive; DEMA and TEMA use multiple EMA passes to reduce lag further; and ALMA applies a Gaussian weighting to balance smoothness and responsiveness. Each one alone is a compromise — fast types whipsaw in chop, slow types lag at turns.

Plus computes all eight over the same length and averages them into one line:

consensus = ( EMA + SMA + WMA + HMA + RMA + DEMA + TEMA + ALMA ) / 8

The purpose of the combination is not to stack indicators, but to average out the bias of each MA type: the lag-reducing members keep the line responsive while the smoother members damp noise, producing a trend estimate steadier than any single fast MA yet more responsive than any single slow one. Using eight diverse families (rather than eight EMAs) is what makes the blend meaningful — they disagree in different conditions, and that disagreement is itself information.

Agreement score. Because the eight averages are diverse, Plus also counts how many of them price is trading above. When most agree (e.g. 8/8) the trend is broad and well-supported; when they split (e.g. 5/8) the move is weaker or transitioning. The dashboard shows this as a percentage aligned with the current trend — a simple conviction gauge a single line can't give.

Direction. Trend is decided with an ATR band rather than a raw cross: it turns bullish only when price closes above the consensus by more than Flip band × ATR, bearish only when it closes the same distance below, and holds the previous trend in between. This deadband suppresses the constant flip-flopping of a plain price/MA cross in sideways markets. Triangles mark the exact flip bar, and the line and optional band are colored by trend.

Signal line & higher-timeframe filter. A signal line (an EMA of the consensus) can be shown for slope/cross context. Optionally, a higher-timeframe consensus must agree before a flip is allowed — so on a 1H chart you can require the daily consensus to also be bullish before a long flip prints.

How to use it

Use the consensus line as your trend reference and bias filter — favor longs while it's teal, shorts while it's red.
Read the Agreement % as conviction: high agreement supports staying with the trend; a falling score warns the move is losing breadth.
Enable higher-timeframe agreement to trade only with the larger trend and cut counter-trend signals.
Widen the Flip band on noisy instruments to reduce false flips; narrow it on clean trends for earlier turns. Increase Length for a slower bias; decrease it for a faster read.
Two built-in alerts fire on bullish and bearish flips.

Settings

Consensus — Source, Length (used by all eight MAs), ALMA offset/sigma.
Trend & signal — Flip band (× ATR) and the signal-line length.
Higher timeframe — require HTF agreement for flips, and the HTF to use.
Display — show/fill band, signal line, flip markers, bar coloring, dashboard.

Notes and limitations

This is a trend-following tool. Like all moving-average methods it lags at turning points and can flip late after sharp reversals; the ATR band trades some timing for fewer false signals.
The higher-timeframe consensus uses request.security with lookahead disabled, so it can update on the still-forming HTF bar until that bar closes. On-chart values are likewise evaluated on the current bar and can update in real time until the bar closes.
It does not predict price and makes no performance claims — use it as one input alongside your own analysis and risk management.

For research and education only. This is not financial advice.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════
//  MASTER LINE PLUS   ·   v1.0         Multi-MA Consensus + Agreement
//  © 2026 Boris Tatchou   ·   Licensed under MPL-2.0 (open source)
// ──────────────────────────────────────────────────────────────────────
//  Blends eight moving averages (EMA · SMA · WMA · HMA · RMA · DEMA ·
//  TEMA · ALMA) into one consensus trend line, adds an agreement score,
//  a signal line, optional higher-timeframe confirmation and a dashboard.
//
//  For research and education only. Not financial advice.
// ══════════════════════════════════════════════════════════════════════

indicator("Master Line Plus · Multi-MA Consensus", overlay = true)

// ── Inputs ────────────────────────────────────────────────────────────
G1 = "Consensus"
src     = input.source(close, "Source", group = G1)
len     = input.int(50, "Length", minval = 2, group = G1)
almaOff = input.float(0.85, "ALMA offset", minval = 0.0, maxval = 1.0, step = 0.05, group = G1)
almaSig = input.float(6.0,  "ALMA sigma",  minval = 1.0, step = 0.5, group = G1)

G2 = "Trend & signal"
bandMult = input.float(0.5, "Flip band (× ATR)", minval = 0.0, step = 0.1, group = G2,
             tooltip = "Price must clear the consensus line by this many ATR to flip the trend. Higher = fewer, steadier flips.")
sigLen   = input.int(20, "Signal-line length (EMA of consensus)", minval = 1, group = G2)

G3 = "Higher timeframe"
useHtf = input.bool(false, "Require higher-timeframe agreement for flips", group = G3)
htfTf  = input.timeframe("D", "Higher timeframe", group = G3)

G4 = "Display"
showBand  = input.bool(true,  "Show band", group = G4)
fillBand  = input.bool(true,  "Fill band", group = G4)
showSig   = input.bool(true,  "Show signal line", group = G4)
showMarks = input.bool(true,  "Show flip markers", group = G4)
colorBars = input.bool(false, "Color bars by trend", group = G4)
showDash  = input.bool(true,  "Show dashboard", group = G4)

// ── Eight moving averages → one consensus line ────────────────────────
f_dema(s, l) =>
    e1 = ta.ema(s, l)
    2.0 * e1 - ta.ema(e1, l)
f_tema(s, l) =>
    e1 = ta.ema(s, l)
    e2 = ta.ema(e1, l)
    e3 = ta.ema(e2, l)
    3.0 * e1 - 3.0 * e2 + e3

m_ema  = ta.ema(src, len)
m_sma  = ta.sma(src, len)
m_wma  = ta.wma(src, len)
m_hma  = ta.hma(src, len)
m_rma  = ta.rma(src, len)
m_dema = f_dema(src, len)
m_tema = f_tema(src, len)
m_alma = ta.alma(src, len, almaOff, almaSig)
consensus = (m_ema + m_sma + m_wma + m_hma + m_rma + m_dema + m_tema + m_alma) / 8.0

// ── Agreement score: how many of the eight sit below price ────────────
f_ab(m) => src > m ? 1 : 0
bullCount = f_ab(m_ema) + f_ab(m_sma) + f_ab(m_wma) + f_ab(m_hma) + f_ab(m_rma) + f_ab(m_dema) + f_ab(m_tema) + f_ab(m_alma)   // 0..8

// ── Direction: latch trend until price clears the far ATR band ────────
band = bandMult * ta.atr(14)
var int dir = 0
dir := close > consensus + band ?  1 :
       close < consensus - band ? -1 : dir
up = dir > 0
dn = dir < 0
lineCol = up ? color.teal : dn ? color.red : color.gray

agree    = up ? bullCount / 8.0 : dn ? (8 - bullCount) / 8.0 : 0.5
agreePct = int(math.round(agree * 100))

// ── Signal line + higher-timeframe consensus ─────────────────────────
sigLine = ta.ema(consensus, sigLen)
htfCons = request.security(syminfo.tickerid, htfTf, consensus, lookahead = barmerge.lookahead_off)
htfUp = not na(htfCons) and close > htfCons
htfDn = not na(htfCons) and close < htfCons
htfTxt = not useHtf ? "off" : htfUp ? "Bull" : htfDn ? "Bear" : "—"

// ── Plots ─────────────────────────────────────────────────────────────
plot(consensus, "Consensus", color = lineCol, linewidth = 2)
plot(showSig ? sigLine : na, "Signal line", color = color.new(color.white, 45), linewidth = 1)
uB = plot(showBand ? consensus + band : na, "Upper band", color = color.new(color.gray, 80))
lB = plot(showBand ? consensus - band : na, "Lower band", color = color.new(color.gray, 80))
fill(uB, lB, color = (fillBand and showBand) ? color.new(lineCol, 90) : na)
barcolor(colorBars ? (up ? color.new(color.teal, 60) : dn ? color.new(color.red, 60) : na) : na)

// ── Flip markers + alerts (optionally HTF-gated) ─────────────────────
okLong  = not useHtf or htfUp
okShort = not useHtf or htfDn
bull = up and dir[1] <= 0 and okLong
bear = dn and dir[1] >= 0 and okShort
plotshape(showMarks and bull, "Bull flip", shape.triangleup,   location.belowbar, color.teal, size = size.small)
plotshape(showMarks and bear, "Bear flip", shape.triangledown, location.abovebar, color.red,  size = size.small)
alertcondition(bull, "Bull flip", "Master Line Plus — bullish flip on {{ticker}} {{interval}}")
alertcondition(bear, "Bear flip", "Master Line Plus — bearish flip on {{ticker}} {{interval}}")

// ── Dashboard ─────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 4,
     bgcolor = color.new(color.black, 20), frame_color = color.new(color.gray, 55),
     frame_width = 1, border_color = color.new(color.gray, 80), border_width = 1)
if showDash and barstate.islast
    dirTxt = up ? "▲  Bull" : dn ? "▼  Bear" : "—  Flat"
    htfCol = htfTxt == "Bull" ? color.teal : htfTxt == "Bear" ? color.red : color.gray
    table.cell(t, 0, 0, "Master Line Plus", text_color = color.new(color.aqua, 0), text_size = size.small)
    table.cell(t, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 0, 1, "Trend",     text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 1, dirTxt,      text_color = lineCol, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 0, 2, "Agreement", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2, str.tostring(agreePct) + "%  (" + str.tostring(bullCount) + "/8)", text_color = lineCol, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 0, 3, "HTF" + (useHtf ? " " + htfTf : ""), text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 3, htfTxt, text_color = htfCol, text_size = size.small, text_halign = text.align_right)
````
