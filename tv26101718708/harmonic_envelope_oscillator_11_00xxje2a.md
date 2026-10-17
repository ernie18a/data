# Harmonic Envelope Oscillator 1.1

- url: https://www.tradingview.com/script/00XXje2a-Harmonic-Envelope-Oscillator-1-1/
- type: indicator
- pine_id: PUB;cc7b6ebb2e8b4cda901ba9ca6ca263d1
- version: 1.0

## Description

Harmonic Envelope Oscillator 1.1 (HE Oscillator) is a non-overlay momentum oscillator that measures how far price has deviated from a central moving average, normalized into clean harmonic levels based on powers of 2.It calculates multiple SMAs with exponentially increasing lengths (base length × 1, 2, 4, 8, ..., 128), uses one of them as the dynamic center (default MA3), and then normalizes the deviation using a highly flexible multiplier (from 1/1024 up to 16384 with fine-tuning). The result is plotted as a smooth oscillator with fixed harmonic envelopes at ±1, ±2, ±4, ±8, ±16, ±32, ±64, ±128.The indicator features clear color-coded zones, background coloring, a real-time "Current Zone" table, and zero-line cross signals.Main Use Cases:1. Mean-Reversion TradingExtreme readings (Env 4 / +8 and above) often mark overextended conditions and potential reversal zones.
Especially powerful when price reaches "Unicorn" or "Env 8" levels.

2. Trend Strength & Momentum ConfirmationSustained readings above +4 or +8 confirm strong directional moves.
Helps you stay in trending trades longer and avoid premature exits.

3. Volatility & Regime IdentificationThe colored zones visually tell you the current market character:Noise / Continuation → low volatility, chop
High / Very High → strong momentum
Extreme → Unicorn → Env 8 → outlier / parabolic moves

4. Scalping & IntradayUse tighter multipliers (1/4 to 1/2) on 1m–15m charts for precise entries around zero and Env 1–2 levels.

5. Swing & Position TradingHigher multipliers (1 to 16+) on 1H–Daily charts work well to spot major exhaustion points.

6. Divergence & Confluence ToolExcellent when combined with other indicators (RSI, MACD, Volume Profile, or the Gann Grid you asked about earlier) for high-probability setups.

Strengths: Very clean and structured harmonic levels (mathematically elegant).
Adaptive to different instruments and timeframes via the multiplier.
Excellent visual hierarchy with zones and table.

## Source Code

````pine
//@version=6
indicator("Harmonic Envelope Oscillator 1.1", shorttitle="HE Oscillator", overlay=false, max_bars_back=1000)

// ── INPUTS ───────────────────────────────────────────────────────────────
group_mult = "Multiplier Settings"
multPreset = input.string("1/4", "Multiplier Preset", 
     options = ["1/1024","1/512","1/256","1/128","1/64","1/32","1/16","1/8","1/4","1/2", "1","2","4","8","16","32","64","128","256","512","1024","2048","4096","8192","16384"], 
     group = group_mult)

manualFine = input.float(1.0, "Fine-tune ×", minval = 0.00001, step = 0.0001, group = group_mult)

offsetMode = input.string("Points", "Offset Mode", options=["Points", "Percent"], group = "Global")
base_length = input.int(32, "Base Length (Power-of-2)", minval=1, group = "Global")

centerSelect = input.string("MA3 (Center)", "Center Cycle", 
     options = ["MA1", "MA2", "MA3 (Center)", "MA4", "MA5", "MA6"], group = "Global")

// ── MA LENGTHS ───────────────────────────────────────────────────────────
len1 = base_length
len2 = base_length * 2
len3 = base_length * 4
len4 = base_length * 8
len5 = base_length * 16
len6 = base_length * 32
len7 = base_length * 64
len8 = base_length * 128

ma1 = ta.sma(close, len1)
ma2 = ta.sma(close, len2)
ma3 = ta.sma(close, len3)
ma4 = ta.sma(close, len4)
ma5 = ta.sma(close, len5)
ma6 = ta.sma(close, len6)
ma7 = ta.sma(close, len7)
ma8 = ta.sma(close, len8)

// Center selection
center = switch centerSelect
    "MA1" => ma1
    "MA2" => ma2
    "MA3 (Center)" => ma3
    "MA4" => ma4
    "MA5" => ma5
    "MA6" => ma6
    => ma3

// ── DEVIATION / MULTIPLIER (Fixed) ───────────────────────────────────────
float mult_base = switch multPreset
    "1/1024" => 1.0/1024
    "1/512"  => 1.0/512
    "1/256"  => 1.0/256
    "1/128"  => 1.0/128
    "1/64"   => 1.0/64
    "1/32"   => 1.0/32
    "1/16"   => 1.0/16
    "1/8"    => 1.0/8
    "1/4"    => 1.0/4
    "1/2"    => 1.0/2
    "1"      => 1.0
    "2"      => 2.0
    "4"      => 4.0
    "8"      => 8.0
    "16"     => 16.0
    "32"     => 32.0
    "64"     => 64.0
    "128"    => 128.0
    "256"    => 256.0
    "512"    => 512.0
    "1024"   => 1024.0
    "2048"   => 2048.0
    "4096"   => 4096.0
    "8192"   => 8192.0
    "16384"  => 16384.0
    => 0.25

float final_mult = mult_base * manualFine

float dev_unit = offsetMode == "Percent" ? 
     close * (0.00625 / 100) * final_mult : 
     0.2441405 * final_mult

// ── NORMALIZED OSCILLATOR ───────────────────────────────────────────────
float raw_osc = (close - center) / dev_unit
float osc     = ta.ema(raw_osc, 3)

// ── PLOTS ───────────────────────────────────────────────────────────────
plot(osc,     title="Harmonic Oscillator", color=color.white, linewidth=2)
plot(raw_osc, title="Raw", color=color.new(color.gray, 50), linewidth=1)

// Key Harmonic Levels
hline(0,   "Center",           color=color.gray,   linestyle=hline.style_solid)
hline(1,   "Env 1",            color=#90bff9)
hline(2,   "Env 2",            color=#ff9800)
hline(4,   "Env 3 - Normal",   color=#fbff00, linewidth=2)
hline(8,   "Env 4 - High",     color=#6bf806, linewidth=2)
hline(16,  "Env 5 - Very High",color=#3179f5, linewidth=2)
hline(32,  "Env 6 - Extreme",  color=#7e57c2, linewidth=2)
hline(64,  "Env 7 - Unicorn",  color=#ff0022, linewidth=2)
hline(128, "Env 8 - Impossible",color=color.white, linewidth=2)

// Mirror negative levels
hline(-1,  "", color=#90bff9)
hline(-2,  "", color=#ff9800)
hline(-4,  "", color=#fbff00, linewidth=2)
hline(-8,  "", color=#6bf806, linewidth=2)
hline(-16, "", color=#3179f5, linewidth=2)
hline(-32, "", color=#7e57c2, linewidth=2)
hline(-64, "", color=#ff0022, linewidth=2)
hline(-128,"", color=color.white, linewidth=2)

// ── ZONE BACKGROUND (Fixed) ─────────────────────────────────────────────
bgcolor(math.abs(osc) <= 4 ?   color.new(#fbff00, 85) : na, title="Central Zone")
bgcolor(math.abs(osc) > 4 and math.abs(osc) <= 16 ? color.new(#6bf806, 88) : na, title="High Zone")
bgcolor(math.abs(osc) > 16 and math.abs(osc) <= 32 ? color.new(#3179f5, 88) : na, title="Very High")
bgcolor(math.abs(osc) > 32 and math.abs(osc) <= 64 ? color.new(#7e57c2, 85) : na, title="Unicorn")
bgcolor(math.abs(osc) > 64 ?   color.new(#ff0022, 80) : na, title="Env 8 Extreme")

// ── CURRENT ZONE TABLE ───────────────────────────────────────────────────
var table zoneTable = table.new(position.top_right, 1, 3, bgcolor=color.new(color.black, 75), border_width=1)

if barstate.islast
    string zoneText = math.abs(osc) <= 1  ? "NOISE (Env 1)" :
                     math.abs(osc) <= 2  ? "CONTINUATION (Env 2)" :
                     math.abs(osc) <= 4  ? "NORMAL / CENTER" :
                     math.abs(osc) <= 8  ? "HIGH" :
                     math.abs(osc) <= 16 ? "VERY HIGH" :
                     math.abs(osc) <= 32 ? "EXTREME" :
                     math.abs(osc) <= 64 ? "UNICORN" : "ENV 8 - YOU SHOULDN'T BE HERE"

    table.cell(zoneTable, 0, 0, "Current Zone", text_color=color.white, text_size=size.small)
    table.cell(zoneTable, 0, 1, zoneText, text_color=osc >= 0 ? color.red : color.lime, text_size=size.normal)
    table.cell(zoneTable, 0, 2, "Value: " + str.tostring(osc, "#.##"), text_color=color.white, text_size=size.small)

// ── ZERO LINE CROSS SHAPES ───────────────────────────────────────────────
plotshape(osc > 0 and osc[1] <= 0, title="Bullish Zero Cross", location=location.bottom, color=color.new(color.green,0), style=shape.triangleup,   size=size.small)
plotshape(osc < 0 and osc[1] >= 0, title="Bearish Zero Cross", location=location.top,    color=color.new(color.red,0),   style=shape.triangledown, size=size.small)
````
