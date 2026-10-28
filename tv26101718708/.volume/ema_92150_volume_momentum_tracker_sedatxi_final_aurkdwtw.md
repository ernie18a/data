# EMA 9/21/50 + Volume Momentum Tracker SEDATXI [FINAL]

- url: https://www.tradingview.com/script/AURKdwTW-EMA-9-21-50-Volume-Momentum-Tracker-SEDATXI-FINAL/
- type: indicator
- pine_id: PUB;36595a69fc8a46b0aefcd2998dd52eac
- version: 1.0

## Description

EMA 9/21/50 + Volume Momentum Tracker [FINAL] show buy sell liquidity and

## Source Code

````pine
//@version=6
indicator("EMA 9/21/50 + Volume Momentum Tracker [FINAL]", shorttitle="EMA + VOL MOM", overlay=true, max_bars_back=1000)

// ── INPUTS ─────────────────────────────────────
group_ema = "EMA Settings"
len9  = input.int(9,  "Fast EMA", group=group_ema)
len21 = input.int(21, "Medium EMA", group=group_ema)
len50 = input.int(50, "Trend EMA", group=group_ema)
src   = input.source(close, "Source", group=group_ema)

showHTF = input.bool(true, "Show 15m EMA50", group="Higher Timeframe")

group_vol = "Volume Settings"
volLen  = input.int(20, "Volume MA Length", group=group_vol)
volMult = input.float(1.5, "Volume Spike Multiplier", step=0.1, group=group_vol)
showVol = input.bool(true, "Show Volume Histogram", group=group_vol)

// ── TABLE SETTINGS ─────────────────────────────
group_table = "Table Settings"
basePos = input.string("top_right", "Table Position",
     options=["top_left", "top_right", "bottom_left", "bottom_right"], group=group_table)

tableOffset = input.int(0, "Table Vertical Offset (rows)", minval=0, maxval=15, group=group_table)

// ── EMAs ───────────────────────────────────────
ema9  = ta.ema(src, len9)
ema21 = ta.ema(src, len21)
ema50 = ta.ema(src, len50)

// HTF EMA
ema50_htf = request.security(syminfo.tickerid, "15", ta.ema(close, 50))

// ── VOLUME MOMENTUM ────────────────────────────
volMA    = ta.sma(volume, volLen)
volSpike = volume > volMA * volMult

bullVol  = volSpike and close > open
bearVol  = volSpike and close < open

// ── TREND LOGIC ────────────────────────────────
priceAboveAll = close > ema9 and close > ema21 and close > ema50
priceBelowAll = close < ema9 and close < ema21 and close < ema50

bullStack = ema9 > ema21 and ema21 > ema50
bearStack = ema9 < ema21 and ema21 < ema50

isStrongBull = bullStack and priceAboveAll and close > ema50_htf and bullVol
isStrongBear = bearStack and priceBelowAll and close < ema50_htf and bearVol

isBullish = priceAboveAll or bullStack
isBearish = priceBelowAll or bearStack

// ── PLOTS ──────────────────────────────────────
plot(ema9,  "EMA 9",  color=close > ema9  ? color.lime  : color.red, linewidth=2)
plot(ema21, "EMA 21", color=close > ema21 ? color.yellow : color.orange, linewidth=2)
plot(ema50, "EMA 50", color=close > ema50 ? color.green  : color.red, linewidth=3)

plot(showHTF ? ema50_htf : na, "15m EMA50", color=color.blue, linewidth=2)

// Volume Histogram
plot(showVol ? volume : na,
     style=plot.style_columns,
     title="Volume",
     color = volSpike ? (close > open ? color.green : color.red) : color.gray)

// ── BACKGROUND ─────────────────────────────────
bgcolor(
     isStrongBull ? color.new(color.green, 85) :
     isStrongBear ? color.new(color.red, 85) : na)

// ── TABLE POSITION ─────────────────────────────
pos = basePos == "top_left" ? position.top_left :
      basePos == "top_right" ? position.top_right :
      basePos == "bottom_left" ? position.bottom_left :
      position.bottom_right

// ── TABLE ──────────────────────────────────────
var table t = table.new(pos, 2, 6 + tableOffset, bgcolor=color.new(color.black, 75), border_width=1)

// ── TABLE UPDATE (OFFSET FIX) ──────────────────
if barstate.islast
    // spacer rows (prevents overlap)
    for i = 0 to tableOffset - 1
        table.cell(t, 0, i, "")
        table.cell(t, 1, i, "")

    row = tableOffset

    // STATE
    table.cell(t, 0, row, "STATE", text_color=color.white)
    table.cell(t, 1, row,
        isStrongBull ? "STRONG BULL" :
        isStrongBear ? "STRONG BEAR" :
        isBullish ? "BULLISH" :
        isBearish ? "BEARISH" : "NEUTRAL",
        text_color =
            isStrongBull ? color.green :
            isStrongBear ? color.red :
            isBullish ? color.lime :
            isBearish ? color.orange : color.gray)

    // PRICE
    table.cell(t, 0, row+1, "PRICE", text_color=color.white)
    table.cell(t, 1, row+1,
        priceAboveAll ? "ABOVE ALL" :
        priceBelowAll ? "BELOW ALL" : "MIXED",
        text_color =
            priceAboveAll ? color.green :
            priceBelowAll ? color.red : color.gray)

    // STACK
    table.cell(t, 0, row+2, "STACK", text_color=color.white)
    table.cell(t, 1, row+2,
        bullStack ? "BULL STACK" :
        bearStack ? "BEAR STACK" : "NONE",
        text_color =
            bullStack ? color.green :
            bearStack ? color.red : color.gray)

    // VOLUME
    table.cell(t, 0, row+3, "VOL", text_color=color.white)
    table.cell(t, 1, row+3,
        bullVol ? "BULL VOL" :
        bearVol ? "BEAR VOL" : "LOW",
        text_color =
            bullVol ? color.green :
            bearVol ? color.red : color.gray)

    // HTF
    table.cell(t, 0, row+4, "HTF", text_color=color.white)
    table.cell(t, 1, row+4,
        showHTF ? (close > ema50_htf ? "ABOVE" : "BELOW") : "OFF",
        text_color =
            showHTF ? (close > ema50_htf ? color.green : color.red) : color.gray)

    // CLOSE
    table.cell(t, 0, row+5, "CLOSE", text_color=color.white)
    table.cell(t, 1, row+5, str.tostring(close, "#.####"), text_color=color.yellow)

// ── ALERTS ─────────────────────────────────────
alertcondition(ta.crossover(close, ema50), "Bullish EMA50 Break", "Price crossed above EMA50")
alertcondition(ta.crossunder(close, ema50), "Bearish EMA50 Break", "Price crossed below EMA50")

alertcondition(isStrongBull and ta.crossover(ema9, ema21),
     "Strong Bullish", "Strong Bullish Alignment + Volume")

alertcondition(isStrongBear and ta.crossunder(ema9, ema21),
     "Strong Bearish", "Strong Bearish Alignment + Volume")

alertcondition(bullVol and isBullish,
     "Bull Volume", "Bullish Volume Spike")

alertcondition(bearVol and isBearish,
     "Bear Volume", "Bearish Volume Spike")
````
