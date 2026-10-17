# Stochastic with label OVS/OVB 

- url: https://www.tradingview.com/script/BaSqPrFt/
- type: indicator
- pine_id: PUB;f206e08f566a4f5693dd39f1f9d4c76e
- version: 1.0

## Description

[b]Stochastic Oscillator[/b]

A Stochastic Oscillator indicator with OVB (Overbought) and OVS (Oversold) signal labels displayed beneath the price chart. The indicator uses two momentum lines — a blue %K line and an orange %D signal line — fluctuating between the 20 and 80 levels to identify market momentum and potential reversal zones. Red “OVB” labels appear when the oscillator enters the overbought region above 80, signaling possible bearish exhaustion, while green “OVS” labels appear below 20, indicating potential bullish reversal opportunities. The indicator is designed to help traders detect momentum shifts, trend weakness, and short-term entry or exit signals in fast-moving markets such as XAU/USD.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Custom Stochastic with OVB/OVS Label Options

//@version=6
indicator("สโตเคสติก 9 3 3 80 20", shorttitle="Stoch OVB/OVS", overlay=false)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
smoothK     = input.int(3,  title="Smooth K",    minval=1)
smoothD     = input.int(3,  title="Smooth D",    minval=1)
lengthK     = input.int(9,  title="Length K",    minval=1)
upperLevel  = input.int(80, title="Overbought",  minval=50, maxval=100)
lowerLevel  = input.int(20, title="Oversold",    minval=0,  maxval=50)

labelStyle  = input.string("Label (OVB/OVS)", title="Signal Display Style",
             options=["Label (OVB/OVS)", "Dot (Green/Red)"])

// ─── STOCHASTIC CALCULATION ───────────────────────────────────────────────────
k = ta.sma(ta.stoch(close, high, low, lengthK), smoothK)
d = ta.sma(k, smoothD)

// ─── PLOT LINES ───────────────────────────────────────────────────────────────
plot(k, title="K", color=color.new(color.orange, 0), linewidth=1)
plot(d, title="D", color=color.new(color.blue,   0), linewidth=1)

hline(upperLevel, "Overbought", color=color.new(color.red,   60), linestyle=hline.style_dashed)
hline(lowerLevel, "Oversold",   color=color.new(color.green, 60), linestyle=hline.style_dashed)
hline(50,         "Mid",        color=color.new(color.gray,  80), linestyle=hline.style_dotted)

bgcolor(k >= upperLevel ? color.new(color.red,   90) :
        k <= lowerLevel ? color.new(color.green, 90) : na,
        title="Zone Background")

// ─── SIGNAL: ครั้งแรกที่ K เข้า zone เท่านั้น ────────────────────────────────
// OVB = Overbought: K เพิ่งแตะหรือข้าม upperLevel ขึ้นไป → แสดงด้านบน
enterOVB = k[1] < upperLevel and k >= upperLevel

// OVS = Oversold: K เพิ่งแตะหรือข้าม lowerLevel ลงมา → แสดงด้านล่าง
enterOVS = k[1] > lowerLevel and k <= lowerLevel

// ─── LABEL mode ───────────────────────────────────────────────────────────────
if labelStyle == "Label (OVB/OVS)"
    if enterOVB
        // OVB อยู่ด้านบน: label_down ห้อยลงมาจากค่า K
        label.new(bar_index, k, "OVB",
                  style     = label.style_label_down,
                  color     = color.new(color.red, 0),
                  textcolor = color.white,
                  size      = size.small)
    if enterOVS
        // OVS อยู่ด้านล่าง: label_up ชี้ขึ้นจากค่า K
        label.new(bar_index, k, "OVS",
                  style     = label.style_label_up,
                  color     = color.new(color.green, 0),
                  textcolor = color.white,
                  size      = size.small)

// ─── DOT mode ─────────────────────────────────────────────────────────────────
else if labelStyle == "Dot (Green/Red)"
    if enterOVB
        label.new(bar_index, k, "●",
                  style     = label.style_none,
                  textcolor = color.new(color.red, 0),
                  size      = size.normal)
    if enterOVS
        label.new(bar_index, k, "●",
                  style     = label.style_none,
                  textcolor = color.new(color.green, 0),
                  size      = size.normal)

// ─── ALERT CONDITIONS ─────────────────────────────────────────────────────────
alertcondition(enterOVB, title="OVB Alert", message="Stochastic เข้า Overbought Zone")
alertcondition(enterOVS, title="OVS Alert", message="Stochastic เข้า Oversold Zone")
````
