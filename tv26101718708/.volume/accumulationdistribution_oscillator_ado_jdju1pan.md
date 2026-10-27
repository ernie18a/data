# Accumulation/Distribution Oscillator (ADO)

- url: https://www.tradingview.com/script/jdjU1Pan-Accumulation-Distribution-Oscillator-ADO/
- type: indicator
- pine_id: PUB;171088d3662a4d80886d2c2605c7f5d2
- version: 1.0

## Description

What is the ADO?
The formula shown is:
Step 1 — Calculate AD per bar:

AD = [(Close – Open) / (High – Low)] × Volume

Step 2 — Sum 20 bars:

ADO = Σ AD (over 20 periods)

This measures whether money is flowing into (accumulation) or out of (distribution) an asset over a 20-bar rolling window, weighted by volume.

## Source Code

````pine
//@version=5
indicator("ADO — Accumulation/Distribution Oscillator", shorttitle="ADO", overlay=false)

// ── Inputs
length = input.int(20, title="Period", minval=1)

// ── AD per bar (guard against High == Low)
range_hl = high - low
ad_bar   = range_hl != 0 ? ((close - open) / range_hl) * volume : 0.0

// ── ADO = rolling sum over the period
ado = math.sum(ad_bar, length)

// ── Zero line
hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_dashed, linewidth=1)

// ── Main line plot
plot(ado, title="ADO", color=ado >= 0 ? color.new(color.teal, 10) : color.new(color.red, 10), linewidth=2)

// ── Histogram bars
plot(ado, style=plot.style_histogram, title="ADO Histogram", color=ado >= 0 ? color.new(color.teal, 60) : color.new(color.red, 60), linewidth=1)

// ── Background shading
bgcolor(ado >= 0 ? color.new(color.teal, 92) : color.new(color.red, 92))
````
