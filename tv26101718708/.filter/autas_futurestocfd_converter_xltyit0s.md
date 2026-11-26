# AUTAS Futures-to-CFD Converter

- url: https://www.tradingview.com/script/XLTyit0s-AUTAS-Futures-to-CFD-Converter/
- type: indicator
- pine_id: PUB;664e37030051447292ccad0474521743
- version: 1.0

## Description

Futures levels don't line up with your broker's CFD price. This indicator measures the gap and converts futures levels into the price your broker actually quotes.

HOW TO USE
Add it to your broker's CFD chart (US30, NAS100, XAUUSD…) and choose the matching futures contract: YM1! for US30, NQ1! for NAS100, GC1! for gold, ES1! for US500. Type up to four futures levels, from order flow, a futures chart or a newsletter, and they're drawn on your CFD chart at the converted price.

THE TABLE SHOWS
- Futures price and CFD price
- Live gap, and the median gap over recent bars (steadier: one odd tick doesn't move your levels)
- Each futures level → its CFD equivalent

WARNINGS
If the live gap moves far from its median, you'll see a heads-up. That usually means a contract roll or a data gap, so check before trusting converted levels. The threshold adjusts automatically, or you can set your own.

NOTES
- CFD price = futures price − gap. The gap drifts slowly with interest rates and jumps when the futures contract rolls.
- Without a real-time data add-on, TradingView shows CME futures delayed, so the live gap will lag.

A conversion tool, not a trading signal. Not financial advice.

## Source Code

````pine
//@version=6
// AUTAS Futures-to-CFD Converter
// Put it on your broker's CFD chart (US30, NAS100, XAUUSD…), choose the matching futures contract, and it shows
// the gap (basis) between them and converts futures levels — from order flow, a futures chart or a newsletter —
// into the price your broker actually quotes.
indicator("AUTAS Futures-to-CFD Converter", shorttitle="AUTAS Fut→CFD", overlay=true, max_lines_count=12, max_labels_count=12)

grpF     = "Futures contract"
symFut   = input.symbol("CBOT_MINI:YM1!", "Futures symbol", group=grpF, tooltip="YM1! for US30 · NQ1! for NAS100 · GC1! for gold · ES1! for US500. The 1! means the front-month contract.")
basisSrc = input.string("Median of recent bars", "Gap to use", options=["Median of recent bars", "Live"], group=grpF,
     tooltip="Median is steadier: one odd tick doesn't move your converted levels. Live follows every bar.")
medLen   = input.int(20, "Bars in the median", minval=3, group=grpF)
jumpPts  = input.float(0.0, "Warn if live gap differs from median by more than (0 = auto)", minval=0, group=grpF)

grpL  = "Futures levels to convert (0 = off)"
lvl1  = input.float(0.0, "Level 1", group=grpL)
lvl2  = input.float(0.0, "Level 2", group=grpL)
lvl3  = input.float(0.0, "Level 3", group=grpL)
lvl4  = input.float(0.0, "Level 4", group=grpL)
grpD      = "Display"
lineLen   = input.int(30, "Line length (bars)", minval=5, group=grpD)
tablePos  = input.string("Top right", "Table position", options=["Top right", "Bottom right", "Top left", "Bottom left"], group=grpD)

// ---------- basis = futures − CFD
fut       = request.security(symFut, timeframe.period, close)
liveBasis = fut - close
medBasis  = ta.median(liveBasis, medLen)
basis     = basisSrc == "Live" ? liveBasis : medBasis
// auto threshold: 4x the typical bar-to-bar wobble of the gap
wobble    = ta.median(math.abs(liveBasis - liveBasis[1]), medLen)
thresh    = jumpPts > 0 ? jumpPts : math.max(wobble * 4, syminfo.mintick * 10)
jumped    = not na(medBasis) and math.abs(liveBasis - medBasis) > thresh

conv(float f) => f > 0 and not na(basis) ? f - basis : na

// ---------- drawings
var line[]  lines  = array.new_line()
var label[] labels = array.new_label()
if barstate.islast
    for l in lines
        line.delete(l)
    for lb in labels
        label.delete(lb)
    array.clear(lines)
    array.clear(labels)
    levels = array.from(lvl1, lvl2, lvl3, lvl4)
    for i = 0 to 3
        f = array.get(levels, i)
        c = conv(f)
        if not na(c)
            array.push(lines, line.new(bar_index - lineLen, c, bar_index + 5, c, color=#00d47c, width=2, style=line.style_dashed))
            array.push(labels, label.new(bar_index + 5, c, "Futures " + str.tostring(f, format.mintick) + " → " + str.tostring(c, format.mintick), style=label.style_label_left, color=color.new(#0a0e1a, 0), textcolor=#00d47c, size=size.small))

// ---------- table
tPos = switch tablePos
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Top left"     => position.top_left
    => position.bottom_left
var table tb = table.new(tPos, 2, 10, bgcolor=color.new(#0a0e1a, 5), border_color=#1a1f2e, border_width=1)
if barstate.isfirst
    table.merge_cells(tb, 0, 0, 1, 0)
    table.merge_cells(tb, 0, 9, 1, 9)
if barstate.islast
    table.cell(tb, 0, 0, "AUTAS FUTURES → CFD", text_color=#00d47c, text_size=size.small)
    table.cell(tb, 0, 1, "Futures", text_color=#94a3b8, text_size=size.small)
    table.cell(tb, 1, 1, na(fut) ? "no data" : str.tostring(fut, format.mintick), text_color=#e8ebef, text_size=size.small)
    table.cell(tb, 0, 2, syminfo.ticker, text_color=#94a3b8, text_size=size.small)
    table.cell(tb, 1, 2, str.tostring(close, format.mintick), text_color=#e8ebef, text_size=size.small)
    table.cell(tb, 0, 3, "Live gap", text_color=#94a3b8, text_size=size.small)
    table.cell(tb, 1, 3, na(liveBasis) ? "—" : (liveBasis >= 0 ? "+" : "") + str.tostring(liveBasis, format.mintick), text_color=#e8ebef, text_size=size.small)
    table.cell(tb, 0, 4, "Median gap (" + str.tostring(medLen) + " bars)", text_color=#94a3b8, text_size=size.small)
    table.cell(tb, 1, 4, na(medBasis) ? "—" : (medBasis >= 0 ? "+" : "") + str.tostring(medBasis, format.mintick), text_color=#e8ebef, text_size=size.small)
    levels = array.from(lvl1, lvl2, lvl3, lvl4)
    for i = 0 to 3
        f = array.get(levels, i)
        c = conv(f)
        table.cell(tb, 0, 5 + i, "Level " + str.tostring(i + 1), text_color=#94a3b8, text_size=size.small)
        table.cell(tb, 1, 5 + i, f <= 0 ? "off" : na(c) ? "—" : str.tostring(f, format.mintick) + " → " + str.tostring(c, format.mintick), text_color=f <= 0 ? #6b7280 : #00d47c, text_size=size.small)
    msg = na(fut) ? "No futures data: check the symbol, or whether your plan includes that exchange's data." : jumped ? "Heads up: the live gap is " + str.tostring(math.abs(liveBasis - medBasis), format.mintick) + " away from its median — possibly a contract roll or a data gap. Check before using converted levels." : "CFD price = futures price − gap. The gap shifts slowly with interest rates and jumps at contract roll."
    table.cell(tb, 0, 9, msg, text_color=jumped or na(fut) ? #f59e0b : #94a3b8, text_size=size.tiny, text_halign=text.align_left)
````
