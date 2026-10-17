# Percentage-Level(+%/-%)[LionTrader_]

- url: https://www.tradingview.com/script/Dp1Jniku/
- type: indicator
- pine_id: PUB;4a57dc2025934d4f8646f4c54399873c
- version: 1.0

## Description

[b]Percentage-Level (+%/-%) by LionTrader_ [/b]
is a highly efficient and clean technical indicator designed to automatically plot dynamic price levels based on custom percentage offsets. It provides traders with a direct visual representation of percentage-based expansions, making it easier than ever to see exactly when price action reaches or breaks through key structural thresholds.
A major advantage of this tool is its multi-tiered structure, allowing you to track up to [b]three independent levels simultaneously[/b]. This flexibility is perfect for identifying multiple price targets, managing scaling strategies, or monitoring different layers of support and resistance.
The indicator features separate long and short controls, giving you the freedom to customize the exact percentage distance, the base price source, and the validation criteria for both the upside and the downside independently.
To keep your charts clean and readable, it utilizes smart visual feedback. The plotted levels remain thin and semi-transparent in the background during normal price action, but they instantly turn thick and brightly colored once your chosen invalidation source, such as the candle high or low, breaches the level.
Additionally, the script ensures excellent chart organization by using clean step-lines and optional cross markers that highlight the exact execution points where a level was triggered. This makes it an incredibly reliable, no-nonsense tool for anyone who bases their trading decisions on fixed percentage movements or requires clear, automated invalidation levels on their charts.

I hope you like it 
your LionTrader_🦁

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LionTrader_
//@version=6
indicator("Percentage-Level(+%/-%)(V1)[LionTrader_]",shorttitle = '%-Levels(V1)[LionTrader_]', overlay=true)

// --- (Inputs) ---
a = '% Level-1'
Activ1 = input.bool(true,title = 'Show Levels-1👁️',group = a)
pct_inputl1 = input.float(1.0, title="Percentage% difference(Long)⬆️", step=0.1, minval=0.01)
pct_inputs1 = input.float(1.0, title="Percentage% difference(Short)⬇️", step=0.1, minval=0.01)
base_pricel1 = input.source(open, title="Source (Long)")
base_prices1 = input.source(open, title="Source (Short)")
Longcolor1 = input.bool(true, title = 'Color Long ',tooltip = 'If invaliditon it will be color' , inline = 'aa')
Shortcolor1 = input.bool(true, title = 'Color Short ',tooltip = 'If invaliditon it will be color', inline = 'aa' )
colorl1 = input.color(color.red,title = 'Long Color', inline = 'a') 
colors1 = input.color(color.green,title = 'Short Color', inline = 'a')
invalidationsourcelong1 = input.source(high,title = 'Invalidation Source(Long)')
invalidationsourceshort1 = input.source(low,title = 'Invalidation Source(Short)')
label1 = input.string('Both',options = ['No','Long','Short','Both'],title = 'Show Labels?🏷️')

//--2
b='% Level-2'
Activ2 = input.bool(false,title = 'Show Levels-2👁️',group = b)
pct_inputl2 = input.float(2.0, title="Percentage% difference(Long-2)⬆️", step=0.1, minval=0.01)
pct_inputs2 = input.float(2.0, title="Percentage% difference(Short-2)⬇️", step=0.1, minval=0.01)
base_pricel2 = input.source(open, title="Source (Long-2)")
base_prices2 = input.source(open, title="Source (Short-2)")
Longcolor2 = input.bool(true, title = 'Color Long-2 ',tooltip = 'If invaliditon it will be color' , inline = 'na')
Shortcolor2 = input.bool(true, title = 'Color Short-2 ',tooltip = 'If invaliditon it will be color' , inline = 'na')
colorl2 = input.color(color.red,title = 'Long Color', inline = 'b') 
colors2 = input.color(color.green,title = 'Short Color', inline = 'b' ) 
invalidationsourcelong2 = input.source(high,title = 'Invalidation Source(Long-2)')
invalidationsourceshort2 = input.source(low,title = 'Invalidation Source(Short-2)')
label2 = input.string('Both',options = ['No','Long','Short','Both'],title = 'Show Labels-2?🏷️')

//--3
c = '& Level-3'
Activ3= input.bool(false,title = 'Show Levels-3👁️',group = c)
pct_inputl3 = input.float(3.0, title="Percentage% difference(Long-3)⬆️", step=0.1, minval=0.01)
pct_inputs3 = input.float(3.0, title="Percentage% difference(Short-3)⬇️", step=0.1, minval=0.01)
base_pricel3 = input.source(open, title="Source (Long-3)")
base_prices3 = input.source(open, title="Source (Short-3)")
Longcolor3 = input.bool(true, title = 'Color Short-3 ' , inline = 'nc' )
Shortcolor3 = input.bool(true, title = 'Color Short-3 ' , inline = 'nc')
colorl3 = input.color(color.red,title = 'Long Color', inline = 'c') 
colors3 = input.color(color.green,title = 'Short Color', inline = 'c') 
invalidationsourcelong3 = input.source(high,title = 'Invalidation Source(Long-3)')
invalidationsourceshort3 = input.source(low,title = 'Invalidation Source(Short-3)')
label3 = input.string('Both',options = ['No','Long','Short','Both'],title = 'Show Labels-3?🏷️')


// --- calculation ---
// calculate of prozentualen price
pct_valuel1 = base_pricel1 * (pct_inputl1 / 100)
pct_values1 = base_prices1 * (pct_inputs1 / 100)
//  Level calculate
upper_level1 = base_pricel1 + pct_valuel1
lower_level1 = base_prices1 - pct_values1
//----2
pct_valuel2 = base_pricel2 * (pct_inputl2 / 100)
pct_values2 = base_prices2 * (pct_inputs2 / 100)
upper_level2 = base_pricel2 + pct_valuel2
lower_level2 = base_prices2 - pct_values2
//----3
pct_valuel3 = base_pricel3 * (pct_inputl3 / 100)
pct_values3 = base_prices3 * (pct_inputs3 / 100)
upper_level3 = base_pricel3 + pct_valuel3
lower_level3 = base_prices3 - pct_values3

//---Plots
//--Long
linel1 =invalidationsourcelong1>=upper_level1 
plot(upper_level1, color= linel1 and Longcolor1==true and Activ1? colorl1 : na, title="Long Level-1 (+%)", style=plot.style_steplinebr, linewidth=3)
plot(upper_level1, color=not linel1 and Activ1? color.new(color.white, 81) : na, title="Long Level-1 (+%)", style=plot.style_steplinebr, linewidth=1)
linel2 =invalidationsourcelong2>=upper_level2  
plot(upper_level2, color= linel2 and Longcolor2== true and Activ2? colorl2 : na, title="Long Level-2 (+%)", style=plot.style_steplinebr, linewidth=3)
plot(upper_level2, color= not linel2 and Activ2? color.new(color.white, 81) : na, title="Long Level-2 (+%)", style=plot.style_steplinebr, linewidth=1)
linel3 =invalidationsourcelong3>=upper_level3 
plot(upper_level3, color=linel3 and Longcolor3== true and Activ3 ? colorl3 : na, title="Long Level-3 (+%)", style=plot.style_steplinebr, linewidth=3)
plot(upper_level3, color= not linel3 and Activ3?color.new(color.white, 81) : na, title="Long Level-3 (+%)", style=plot.style_steplinebr, linewidth=1)
//--Short
lines1 =invalidationsourceshort1<=lower_level1 
plot(lower_level1, color= lines1 and Shortcolor1==true and Activ1? colors1 : na, title="Short Level-1 (-%)", style=plot.style_steplinebr,linewidth = 3)
plot(lower_level1, color= not lines1 and Activ1? color.new(color.white, 80) : na, title="Short Level-1 (-%)", style=plot.style_steplinebr,linewidth = 1)
lines2 =invalidationsourceshort2<=lower_level2 
plot(lower_level2, color= lines2 and Shortcolor2==true and Activ2? colors2 : na, title="Short Level-2 (-%)", style=plot.style_steplinebr,linewidth = 3)
plot(lower_level2, color= not lines2 and Activ2? color.new(color.white, 80) : na, title="Short Level-2 (-%)", style=plot.style_steplinebr,linewidth = 1)
lines3 =invalidationsourceshort3<=lower_level3 
plot(lower_level3, color= lines3 and Shortcolor3== true and Activ3? colors3 : na, title="Short Level-3 (-%)", style=plot.style_steplinebr,linewidth = 3)
plot(lower_level3, color= not lines3 and Activ3? color.new(color.white, 80) : na, title="Short Level-3 (-%)", style=plot.style_steplinebr,linewidth = 1)

//---labels
//--Long
label1l = label1=='Long' or label1=='Both'
plotshape(linel1 and Activ1 and label1l, style = shape.cross,location =location.top  , color = colorl1 )
label2l = label2=='Long' or label2=='Both'
plotshape(linel2 and Activ2 and label2l, style = shape.cross,location =location.top  , color = colorl2 )
label3l = label3=='Long' or label3=='Both'
plotshape(linel3 and Activ3 and label3l, style = shape.cross,location =location.top  , color = colorl3 )
//--short
label1s = label1=='Short' or label1=='Both'
plotshape(lines1 and Activ1 and label1s, style = shape.cross,location =location.bottom  , color = colors1 )
label2s = label2=='Short' or label2=='Both'
plotshape(lines2 and Activ2 and label2s, style = shape.cross,location =location.bottom  , color = colors2 )
label3s = label3=='Short' or label3=='Both'
plotshape(lines3 and Activ3 and label3s, style = shape.cross,location =location.bottom  , color = colors3 )

//---alarm
````
