# Swing Reversal Dashboard (Auto TF)

- url: https://www.tradingview.com/script/eQslLlAu-Swing-Reversal-Dashboard-Auto-TF/
- type: indicator
- pine_id: PUB;7e1cd7e6932847e08428534dc2afb6f7
- version: 1.0

## Description

swing table at the bottom, by analyzing chart patterns and candles

## Source Code

````pine
//@version=6
indicator("Swing Reversal Dashboard (Auto TF)", overlay=true)

// ======================================================
// ── INPUTS
// ======================================================

vol_len = input.int(20, "Volume MA Length")

// ======================================================
// ── AUTO TIMEFRAME DATA (IMPORTANT)
// Uses chart timeframe automatically
// ======================================================

c_tf = close
o_tf = open
h_tf = high
l_tf = low
v_tf = volume

// ======================================================
// ── VOLUME ANALYSIS
// ======================================================

vol_ma = ta.sma(v_tf, vol_len)
vol_spike = v_tf > vol_ma * 1.5
vol_state = vol_spike ? "SPIKE" : "NORMAL"

// ======================================================
// ── CANDLE STRENGTH MODEL
// ======================================================

body = math.abs(c_tf - o_tf)
candle_range = h_tf - l_tf

bull_strength = candle_range != 0 ? (c_tf - l_tf) / candle_range : 0
bear_strength = candle_range != 0 ? (h_tf - c_tf) / candle_range : 0

bull_score = bull_strength * 100
bear_score = bear_strength * 100

// ======================================================
// ── STRUCTURE
// ======================================================

ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

trend_up = ema20 > ema50
trend_down = ema20 < ema50

atr_val = ta.atr(14)

structure =
     math.abs(ema20 - ema50) < atr_val * 0.2 ? "RANGE" :
     trend_up ? "UPTREND" :
     trend_down ? "DOWNTREND" : "RANGE"

// ======================================================
// ── SWING LOGIC
// ======================================================

buy_setup =
     bull_score > 60 and vol_spike and structure != "DOWNTREND"

sell_setup =
     bear_score > 60 and vol_spike and structure != "UPTREND"

state =
     buy_setup ? "BUY SETUP" :
     sell_setup ? "SELL SETUP" :
     "NEUTRAL"

// ======================================================
// ── TABLE (BOTTOM RIGHT)
// ======================================================

var table swing = table.new(position.bottom_right, 2, 6,
     bgcolor=color.new(color.black, 85),
     border_color=color.new(color.gray, 60),
     frame_color=color.new(color.gray, 60))

if barstate.islast
    table.cell(swing, 0, 0, "SWING REVERSAL", text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.cell(swing, 1, 0, "", bgcolor=color.new(color.gray, 80))

    table.cell(swing, 0, 1, "STATE", text_color=color.white)
    table.cell(swing, 1, 1, state,
         text_color=color.white,
         bgcolor=state == "BUY SETUP" ? color.new(color.green, 30) :
                 state == "SELL SETUP" ? color.new(color.red, 30) :
                 color.new(color.gray, 70))

    table.cell(swing, 0, 2, "Bull %", text_color=color.white)
    table.cell(swing, 1, 2, str.tostring(bull_score, "#") + "%", text_color=color.lime)

    table.cell(swing, 0, 3, "Bear %", text_color=color.white)
    table.cell(swing, 1, 3, str.tostring(bear_score, "#") + "%", text_color=color.red)

    table.cell(swing, 0, 4, "Volume", text_color=color.white)
    table.cell(swing, 1, 4, vol_state,
         text_color=color.white,
         bgcolor=vol_spike ? color.new(color.orange, 30) : color.new(color.gray, 70))

    table.cell(swing, 0, 5, "Structure", text_color=color.white)
    table.cell(swing, 1, 5, structure,
         text_color=color.white,
         bgcolor=structure == "RANGE" ? color.new(color.blue, 70) :
                 structure == "UPTREND" ? color.new(color.green, 70) :
                 color.new(color.red, 70))
````
