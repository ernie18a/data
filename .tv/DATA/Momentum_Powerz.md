<!-- tradingview-pine-id: PUB;616ea5e804894301bc1617b86ec026dc -->
<!-- tradingviewscripts-format: 1 -->
# Momentum Powerz

Source: https://www.tradingview.com/script/lvgKnkmT-Momentum-Power/

## Description

Trend & Momentum Power (Futures Traders)

What it does

This indicator gives NQ traders a fast read on trend and momentum strength — for NQ and ES side by side — without having to flip charts. It's built for spotting confluence: when NQ and ES are both showing strong trend/momentum in the same direction, that agreement is often more meaningful than either instrument alone. When they diverge, that relative strength/weakness between the two can be just as useful to watch.

How it works

Trend Power is derived from Wilder's DMI/ADX — it measures how strong a directional trend is, not just whether one exists.
Momentum Power is an ATR-normalized rate-of-change — it measures how fast price is moving relative to recent volatility, so readings stay consistent across different volatility regimes.
Each reading is scored 1–3 dots (weak/medium/strong) and colored bullish, bearish, or neutral/indecisive.
The dashboard shows four rows: NQ Trend, NQ Momentum, ES Trend, ES Momentum — so you can see both instruments' internal state at a glance.
ES data is pulled live via request.security, so no need to switch charts.

New: Candle coloring on confluence

When enough dots across all four rows agree on direction (default: 7 of 12), the candles on your chart change color — green for bullish consensus, red for bearish. This is a visual cue for when NQ and ES trend/momentum are aligned, not aligned individual instrument readings in isolation.

Important — this is not a buy/sell signal

This tool does not generate entries, exits, or trade recommendations. It's a read on relative trend and momentum strength between NQ and ES to help you gauge confluence and context. Candle coloring reflects dot agreement, not a system signal — it still requires your own judgment, risk management, and confirmation from your broader trade plan before acting on anything you see.

Inputs

ES symbol is configurable (defaults to CME_MINI:ES1!; swap for micros or a fixed contract month)
All thresholds (trend/momentum weak/medium/strong, deadzones) are adjustable per your own calibration
Dot consensus threshold and candle colors are configurable independently of the dashboard dot colors

---

## Source Code

````pine
//@version=6
indicator("Momentum Powerz", overlay=true)

// ─── Symbol Inputs ──────────────────────────────────────────
grp_sym = "Symbols"
esSymbol = input.symbol("CME_MINI:ES1!", "ES Symbol", group=grp_sym)

// ─── Trend Power (ADX/DI) Inputs ───────────────────────────
grp_trend = "Trend Power (ADX/DI)"
adxLen        = input.int(14, "DI Length", minval=1, group=grp_trend)
adxSmoothing  = input.int(14, "ADX Smoothing", minval=1, maxval=50, group=grp_trend)
trendWeak     = input.float(15.0, "Weak Threshold (1 Dot)", group=grp_trend)
trendMedium   = input.float(25.0, "Medium Threshold (2 Dots)", group=grp_trend)
trendStrong   = input.float(35.0, "Strong Threshold (3 Dots)", group=grp_trend)
diDeadzone    = input.float(2.0, "DI Deadzone (Indecision if DI+/DI- closer than this)", minval=0.0, group=grp_trend)

// ─── Momentum Power (ATR-Normalized ROC) Inputs ────────────
grp_mom = "Momentum Power (ROC)"
momLen        = input.int(10, "ROC Lookback (Bars)", minval=1, group=grp_mom)
momAtrLen     = input.int(14, "ATR Length (Normalization)", minval=1, group=grp_mom)
momWeak       = input.float(0.5, "Weak Threshold (1 Dot)", group=grp_mom)
momMedium     = input.float(1.0, "Medium Threshold (2 Dots)", group=grp_mom)
momStrong     = input.float(1.5, "Strong Threshold (3 Dots)", group=grp_mom)
momDeadzone   = input.float(0.15, "Deadzone (Indecision below this normalized ROC)", minval=0.0, group=grp_mom)

// ─── Display ────────────────────────────────────────────────
grp_disp = "Display"
tablePosInput = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grp_disp)
dotTextSize   = input.string("Normal", "Dot Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_disp)
bullColor     = input.color(color.new(#00ff88, 0), "Bullish Color", group=grp_disp)
bearColor     = input.color(color.new(#ff3355, 0), "Bearish Color", group=grp_disp)
neutralColor  = input.color(color.new(#ffcc00, 0), "Indecision Color", group=grp_disp)
offColor      = color.new(#555555, 0)
labelTextColor = input.color(color.white, "Label Text Color", group=grp_disp)
tableBg       = input.color(color.new(#1a1a1a, 0), "Table Background", group=grp_disp)

// ─── Candle Coloring ─────────────────────────────────────────
grp_candle = "Candle Coloring"
enableCandleColor = input.bool(true, "Color Candles by Dot Consensus", group=grp_candle)
dotThreshold       = input.int(7, "Dots Required (out of 12)", minval=1, maxval=12, group=grp_candle)
candleBullColor    = input.color(color.new(#00ff88, 0), "Candle Bull Color", group=grp_candle)
candleBearColor    = input.color(color.new(#ff3355, 0), "Candle Bear Color", group=grp_candle)

tablePos = switch tablePosInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right

dotSize = switch dotTextSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.normal

// ─── Combined Trend + Momentum Calculation ─────────────────
// Runs against whatever symbol context it's evaluated in (chart symbol,
// or the security-requested symbol when wrapped in request.security).
f_calcAll() =>
    // Trend (Wilder's DMI/ADX)
    up   = ta.change(high)
    down = -ta.change(low)
    trur = ta.rma(ta.tr, adxLen)

    plusDM  = up > down and up > 0 ? up : 0
    minusDM = down > up and down > 0 ? down : 0

    plusDI  = trur != 0 ? 100 * ta.rma(plusDM, adxLen) / trur : 0.0
    minusDI = trur != 0 ? 100 * ta.rma(minusDM, adxLen) / trur : 0.0

    sumDI = plusDI + minusDI
    dx = 100 * math.abs(plusDI - minusDI) / (sumDI == 0 ? 1 : sumDI)
    adxVal = ta.rma(dx, adxSmoothing)

    diDiff = plusDI - minusDI
    trendIndecisive = math.abs(diDiff) < diDeadzone
    trendColor = trendIndecisive ? neutralColor : (diDiff > 0 ? bullColor : bearColor)
    trendDots = adxVal >= trendStrong ? 3 : adxVal >= trendMedium ? 2 : adxVal >= trendWeak ? 1 : 0
    trendDots := math.max(trendDots, 1)

    // Momentum (ATR-Normalized ROC)
    roc = close - close[momLen]
    atrMom = ta.atr(momAtrLen)
    normMom = atrMom != 0 ? roc / atrMom : 0.0

    momIndecisive = math.abs(normMom) < momDeadzone
    momColor = momIndecisive ? neutralColor : (normMom > 0 ? bullColor : bearColor)
    absMom = math.abs(normMom)
    momDots = absMom >= momStrong ? 3 : absMom >= momMedium ? 2 : absMom >= momWeak ? 1 : 0
    momDots := math.max(momDots, 1)

    [trendDots, trendColor, momDots, momColor]

// Chart symbol (your NQ chart)
[nqTrendDots, nqTrendColor, nqMomDots, nqMomColor] = f_calcAll()

// ES symbol pulled via request.security using the same calc logic
[esTrendDots, esTrendColor, esMomDots, esMomColor] = request.security(esSymbol, timeframe.period, f_calcAll(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─── Dot Consensus → Candle Color ───────────────────────────
greenDotCount = (nqTrendColor == bullColor ? nqTrendDots : 0) + (nqMomColor == bullColor ? nqMomDots : 0) + (esTrendColor == bullColor ? esTrendDots : 0) + (esMomColor == bullColor ? esMomDots : 0)
redDotCount   = (nqTrendColor == bearColor ? nqTrendDots : 0) + (nqMomColor == bearColor ? nqMomDots : 0) + (esTrendColor == bearColor ? esTrendDots : 0) + (esMomColor == bearColor ? esMomDots : 0)

candleColor = greenDotCount >= dotThreshold ? candleBullColor : redDotCount >= dotThreshold ? candleBearColor : na
barcolor(enableCandleColor ? candleColor : na)

// ─── Dashboard ──────────────────────────────────────────────
var table dash = table.new(tablePos, 4, 4, bgcolor=tableBg, border_width=1, frame_color=color.new(#333333, 0), frame_width=1)

f_drawRow(tbl, rowIdx, label, dotsLit, litColor) =>
    table.cell(tbl, 0, rowIdx, label, text_color=labelTextColor, bgcolor=tableBg, text_size=dotSize, text_halign=text.align_left)
    for d = 1 to 3
        cellColor = d <= dotsLit ? litColor : offColor
        table.cell(tbl, d, rowIdx, "●", text_color=cellColor, bgcolor=tableBg, text_size=dotSize)

if barstate.islast
    f_drawRow(dash, 0, "NQ Trend:", nqTrendDots, nqTrendColor)
    f_drawRow(dash, 1, "NQ Momentum:", nqMomDots, nqMomColor)
    f_drawRow(dash, 2, "ES Trend:", esTrendDots, esTrendColor)
    f_drawRow(dash, 3, "ES Momentum:", esMomDots, esMomColor)
````
