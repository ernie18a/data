# IChikou 

- url: https://www.tradingview.com/script/wGxnrv9a-IChikou/
- type: indicator
- pine_id: PUB;b785a3f7f9e54b7ea4cdb2aeae89b6f5
- version: 2.0

## Description

Ichimoku Cloud indicator with multiple source inputs for the Chikou or Lagging Span.

This is the default Ichimoku Cloud indicator with only adjustments to the lagging span. This is to be used for added data when reading the Chikou vs trends and IMO an additional layer of balance.

## Source Code

````pine
//@version=6
indicator(title="IChikou ", shorttitle="IChikou", overlay=true)
SingleSource = input.bool(false,"Yes for just one source that you chose ")
Sourcelag = input.source(close)


conversionPeriods = input.int(9, minval=1, title="Conversion Line Length")
basePeriods = input.int(26, minval=1, title="Base Line Length")
laggingSpan2Periods = input.int(52, minval=1, title="Leading Span B Length")
displacement = input.int(26, minval=1, title="Lagging Span")
donchian(len) => math.avg(ta.lowest(len), ta.highest(len))
conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)
leadLine1 = math.avg(conversionLine, baseLine)
leadLine2 = donchian(laggingSpan2Periods)
plot(conversionLine, color=#2962FF, title="Conversion Line")
plot(baseLine, color=#B71C1C, title="Base Line")

p1 = plot(leadLine1, offset = displacement - 1, color=#A5D6A7,
	 title="Leading Span A")
p2 = plot(leadLine2, offset = displacement - 1, color=#EF9A9A,
	 title="Leading Span B")
plot(leadLine1 > leadLine2 ? leadLine1 : leadLine2, offset = displacement - 1, title = "Kumo Cloud Upper Line", display = display.none) 
plot(leadLine1 < leadLine2 ? leadLine1 : leadLine2, offset = displacement - 1, title = "Kumo Cloud Lower Line", display = display.none) 
l1=plot(SingleSource== false ?high:na, offset = -displacement + 1, color=#43A047, title="Lagging Span h")
l2=plot(SingleSource== false ?close:Sourcelag, offset = -displacement + 1, color=#f0730d, title="Lagging Span c")
l3=plot(SingleSource== false ?low:na, offset = -displacement + 1, color=color.rgb(134, 7, 24), title="Lagging Span l")
fill(p1, p2, title = "Cloud Fill", color = leadLine1 > leadLine2 ? color(#30d1864d) : color(color.rgb(216, 71, 119,85)))
fill(l1, l2, title = "Cloud Fill", color = leadLine1 > leadLine2 ? color(color.rgb(92, 192, 182,70)) : color(color.rgb(74, 156, 223,85)))
fill(l2, l3, title = "Cloud Fill", color = leadLine1 > leadLine2 ? color(color.rgb(218, 110, 61, 70)) : color(color.rgb(214, 48, 18, 85)))
````
