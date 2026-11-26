# Medias Moviles AltasMarketView

- url: https://www.tradingview.com/script/svZIHlAh/
- type: indicator
- pine_id: PUB;510f99afd54040aea702a4607d6c777e
- version: 3.0

## Description

A multi-timeframe moving average indicator designed to display trend structure from different timeframes directly on a single chart.

## Features

- Up to 5 fully configurable moving averages.
- Supports both SMA and EMA for each average.
- Independent timeframe selection for every moving average.
- Custom colors for each line.
- Individual enable/disable controls.
- Dynamic fill zones between moving averages to highlight trend alignment and structure.
- Compatible with any market and timeframe.

## Configuration

Each moving average can be customized with:

- Type: SMA or EMA.
- Length.
- Timeframe.
- Color.
- Visibility.

The indicator also includes optional dynamic fills between selected moving averages. Fill colors automatically adjust depending on which moving average is positioned above the other.

## Suggested Uses

This indicator can be used to:

- Identify short-, medium-, and long-term trends.
- Analyze alignment between moving averages from different timeframes.
- Detect potential trend structure changes.
- Display higher-timeframe moving averages without switching charts.
- Complement discretionary technical analysis and market structure methodologies.

## Disclaimer

Moving averages are trend-following tools and should not be used as a standalone basis for trading or investment decisions.

## Source Code

````pine
//@version=6
indicator('Medias Moviles [AtlasMarketView]', overlay = true, max_labels_count = 50)

// ───────── FUNCIÓN MA ─────────
ma_func(src, len, typ) =>
    typ == 'EMA' ? ta.ema(src, len) : ta.sma(src, len)

// ───────── FORMATO TF ─────────
tf_label(tf) =>
    tf_num = str.tonumber(tf)

    tf == '' ? timeframe.period :
     tf == 'D' ? 'D' :
     tf == '1D' ? 'D' :
     tf == 'W' ? 'S' :
     tf == '1W' ? 'S' :
     tf == 'M' ? 'M' :
     tf == '1M' ? 'M' :
     not na(tf_num) and tf_num <= 60 ? tf + 'm' :
     not na(tf_num) and tf_num % 60 == 0 ? str.tostring(int(tf_num / 60)) + 'H' :
     not na(tf_num) ? str.tostring(tf_num) + 'm' :
     tf

// ───────── MA1 ─────────
ma1_on = input.bool(true, 'MA1')
ma1_len = input.int(200, 'MA1 Len')
ma1_tf = input.timeframe('D', 'MA1 TF')
ma1_typ = input.string('EMA', 'MA1 Tipo', options = ['SMA', 'EMA'])
ma1_col = input.color(color.gray, 'MA1 Color')

// ───────── MA2 ─────────
ma2_on = input.bool(true, 'MA2')
ma2_len = input.int(75, 'MA2 Len')
ma2_tf = input.timeframe('60', 'MA2 TF')
ma2_typ = input.string('EMA', 'MA2 Tipo', options = ['SMA', 'EMA'])
ma2_col = input.color(color.blue, 'MA2 Color')

// ───────── MA3 ─────────
ma3_on = input.bool(false, 'MA3')
ma3_len = input.int(50, 'MA3 Len')
ma3_tf = input.timeframe('240', 'MA3 TF')
ma3_typ = input.string('SMA', 'MA3 Tipo', options = ['SMA', 'EMA'])
ma3_col = input.color(color.red, 'MA3 Color')

// ───────── MA4 ─────────
ma4_on = input.bool(false, 'MA4')
ma4_len = input.int(21, 'MA4 Len')
ma4_tf = input.timeframe('W', 'MA4 TF')
ma4_typ = input.string('EMA', 'MA4 Tipo', options = ['SMA', 'EMA'])
ma4_col = input.color(color.teal, 'MA4 Color')

// ───────── MA5 ─────────
ma5_on = input.bool(false, 'MA5')
ma5_len = input.int(200, 'MA5 Len')
ma5_tf = input.timeframe('W', 'MA5 TF')
ma5_typ = input.string('SMA', 'MA5 Tipo', options = ['SMA', 'EMA'])
ma5_col = input.color(color.purple, 'MA5 Color')

// ───────── FILLS ─────────
fill_1_2 = input.bool(true, 'Fill MA1:MA2')
fill_2_3 = input.bool(false, 'Fill MA2:MA3')
fill_3_4 = input.bool(false, 'Fill MA3:MA4')
fill_4_5 = input.bool(false, 'Fill MA4:MA5')

// ───────── ETIQUETAS ─────────
show_labels = input.bool(true, 'Mostrar etiquetas')
label_offset = input.int(12, 'Distancia etiquetas', minval = 1, maxval = 100)
label_size = input.string('Small', 'Tamaño etiquetas', options = ['Tiny', 'Small', 'Normal'])

lbl_size =
     label_size == 'Tiny' ? size.tiny :
     label_size == 'Small' ? size.small :
     size.normal

// ───────── CÁLCULO ─────────
get_ma(on, len, tf, typ) =>
    on ? request.security(syminfo.tickerid, tf, ma_func(close, len, typ)) : na

ma1 = get_ma(ma1_on, ma1_len, ma1_tf, ma1_typ)
ma2 = get_ma(ma2_on, ma2_len, ma2_tf, ma2_typ)
ma3 = get_ma(ma3_on, ma3_len, ma3_tf, ma3_typ)
ma4 = get_ma(ma4_on, ma4_len, ma4_tf, ma4_typ)
ma5 = get_ma(ma5_on, ma5_len, ma5_tf, ma5_typ)

// ───────── PLOTS ─────────
p1 = plot(ma1, color = ma1_col, linewidth = 2)
p2 = plot(ma2, color = ma2_col, linewidth = 2)
p3 = plot(ma3, color = ma3_col, linewidth = 2)
p4 = plot(ma4, color = ma4_col, linewidth = 2)
p5 = plot(ma5, color = ma5_col, linewidth = 2)

// ───────── FILLS ─────────
fill(p1, p2, fill_1_2 and not na(ma1) and not na(ma2) ? color.new(ma1 > ma2 ? ma1_col : ma2_col, 80) : na)
fill(p2, p3, fill_2_3 and not na(ma2) and not na(ma3) ? color.new(ma2 > ma3 ? ma2_col : ma3_col, 80) : na)
fill(p3, p4, fill_3_4 and not na(ma3) and not na(ma4) ? color.new(ma3 > ma4 ? ma3_col : ma4_col, 80) : na)
fill(p4, p5, fill_4_5 and not na(ma4) and not na(ma5) ? color.new(ma4 > ma5 ? ma4_col : ma5_col, 80) : na)

// ───────── LABELS ─────────
var label ma1_lbl = na
var label ma2_lbl = na
var label ma3_lbl = na
var label ma4_lbl = na
var label ma5_lbl = na

solid_col(col) =>
    color.new(col, 0)

update_label(lbl, active, value, txt, col) =>
    label result = lbl
    label_col = solid_col(col)

    if barstate.islast
        if show_labels and active and not na(value)
            if na(result)
                result := label.new(
                     bar_index + label_offset,
                     value,
                     txt,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_none,
                     textcolor = label_col,
                     size = lbl_size
                 )
            else
                label.set_xy(result, bar_index + label_offset, value)
                label.set_text(result, txt)
                label.set_textcolor(result, label_col)
                label.set_size(result, lbl_size)
        else
            if not na(result)
                label.delete(result)
                result := na

    result

ma1_text = str.tostring(ma1_len) + ' ' + tf_label(ma1_tf) + ' ' + ma1_typ
ma2_text = str.tostring(ma2_len) + ' ' + tf_label(ma2_tf) + ' ' + ma2_typ
ma3_text = str.tostring(ma3_len) + ' ' + tf_label(ma3_tf) + ' ' + ma3_typ
ma4_text = str.tostring(ma4_len) + ' ' + tf_label(ma4_tf) + ' ' + ma4_typ
ma5_text = str.tostring(ma5_len) + ' ' + tf_label(ma5_tf) + ' ' + ma5_typ

ma1_lbl := update_label(ma1_lbl, ma1_on, ma1, ma1_text, ma1_col)
ma2_lbl := update_label(ma2_lbl, ma2_on, ma2, ma2_text, ma2_col)
ma3_lbl := update_label(ma3_lbl, ma3_on, ma3, ma3_text, ma3_col)
ma4_lbl := update_label(ma4_lbl, ma4_on, ma4, ma4_text, ma4_col)
ma5_lbl := update_label(ma5_lbl, ma5_on, ma5, ma5_text, ma5_col)
````
