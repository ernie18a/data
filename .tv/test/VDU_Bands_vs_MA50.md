<!-- tradingview-pine-id: PUB;cf7f434de0254197b08d8d384e75384d -->
<!-- tradingviewscripts-format: 1 -->
# VDU Bands (vs MA50)

Source: https://www.tradingview.com/script/ZMRTJnTQ-VDU-Bands-vs-MA50/

## Description

VDU Bands (vs MA50)

Colors volume bars by volume ÷ 50-day volume average so True VDU is obvious at a glance.

Color key:
• Blue   ≤ 50%  → True VDU (locked definition)
• Purple 50–60% → mild dry
• Olive  60–70% → quiet
• Gray   70–100% → average
• Red    > 100% → expansion

Orange line = MA50 volume.

---

## Source Code

````pine
//@version=6
indicator("VDU Bands (vs MA50)", overlay=false, format=format.volume)

maLen = input.int(50, "Volume MA Length")
volMa = ta.sma(volume, maLen)
pct   = volume / volMa

c = pct <= 0.50 ? color.new(color.blue, 0) :       // True VDU ≤50%
     pct <= 0.60 ? color.new(color.purple, 0) :     // 50–60%
     pct <= 0.70 ? color.new(color.olive, 0) :      // 60–70%
     pct <= 1.00 ? color.new(color.gray, 40) :      // 70–100%
     color.new(color.red, 20)                       // >100%

plot(volume, style=plot.style_columns, color=c, title="Volume")
plot(volMa, color=color.orange, linewidth=2, title="MA50 Vol")

plotshape(pct <= 0.50, style=shape.circle, location=location.top,
     color=color.blue, size=size.tiny, title="True VDU")
````
