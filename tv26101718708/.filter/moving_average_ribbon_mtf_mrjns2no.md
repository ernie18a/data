# Moving Average Ribbon - MTF

- url: https://www.tradingview.com/script/MRJNS2nO-Moving-Average-Ribbon-MTF/
- type: indicator
- pine_id: PUB;4754057583634372ac6165d79c4ee10c
- version: 1.0

## Description

MOVING AVERAGE RIBBON (MTF)

A clean, lightweight ribbon of four independent moving averages — everything you normally need from several separate MA scripts, combined into a single indicator slot.

Instead of loading four copies of a basic MA indicator, this script lets you configure each line completely on its own, including the timeframe it is calculated on.


FEATURES

• 4 independent moving averages. Each one can be enabled or disabled individually, and a disabled MA is fully removed from the chart and the status line.

• 5 MA types per line: SMA, EMA, SMMA (RMA), WMA, and VWMA. Every MA can use a different type — for example an EMA for the fast line and an SMA for the slow line.

• Custom source per line. Choose close, open, hl2, hlc3, or any other series available in the source dropdown, separately for each MA.

• Custom length and color per line.

• Per-MA multi-timeframe (MTF). Each moving average has its own MTF toggle and timeframe field. Enable MTF on a single line to overlay, for example, the daily 200 MA on a 15-minute chart, while the other three lines stay on the chart timeframe.

• Compact settings layout. All parameters for one MA sit on a single inline row, so the settings panel stays readable, and the inputs for a disabled MA are greyed out.


DEFAULT CONFIGURATION

MA #1 — SMA, length 5, source close
MA #2 — SMA, length 20, source close
MA #3 — SMA, length 50, source close
MA #4 — SMA, length 200, source close

All four are enabled by default with MTF turned off, so out of the box the indicator behaves as a standard 5 / 20 / 50 / 200 ribbon on the chart timeframe. Every value can be changed in the settings.


ABOUT THE MTF CALCULATION

Higher-timeframe values are requested with lookahead disabled, so no future data is used and the plotted history matches what would have been visible in real time. Higher-timeframe lines update as the higher-timeframe bar develops, and become final when that bar closes. The indicator also supports the built-in timeframe selector in the settings, with gaps enabled, if you prefer to shift the whole indicator to another resolution at once.


HOW TO USE IT

• Use the fast and slow lines together to read trend direction and momentum: price above the ribbon with the lines stacked in order suggests an uptrend, the reverse suggests a downtrend.

• Watch crossovers between two lines as a classic trend-change reference (for example 20 over 50).

• Use the MTF option to keep a higher-timeframe level of reference — such as the daily 200 MA — visible while you work on a lower timeframe.


This indicator is a visualization tool only. It does not generate buy or sell signals and should be combined with your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("Moving Average Ribbon", shorttitle = "MA Ribbon MTF", overlay = true, timeframe = "", timeframe_gaps = true)

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length)
        "EMA"        => ta.ema(source,  length)
        "SMMA (RMA)" => ta.rma(source,  length)
        "WMA"        => ta.wma(source,  length)
        "VWMA"       => ta.vwma(source, length)
        => na

// Fungsi helper untuk menghitung MA di timeframe tertentu (mendukung MTF)
// Jika useMTF nonaktif atau timeframe kosong, gunakan chart timeframe biasa
mtfMA(source, length, MAtype, useMTF, tf) =>
    float result = na
    if useMTF and tf != ""
        result := request.security(syminfo.tickerid, tf, ma(source, length, MAtype), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    else
        result := ma(source, length, MAtype)
    result

show_ma1     = input(true,         "MA #1", inline = "MA #1", display = display.none)
ma1_type     = input.string("SMA", "",      inline = "MA #1", active = show_ma1, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source   = input(close,        "",      inline = "MA #1", active = show_ma1, display = display.none)
ma1_length   = input.int(5,       "",      inline = "MA #1", active = show_ma1, minval  = 1)
ma1_color    = input(color.rgb(255, 157, 252),      "",      inline = "MA #1", active = show_ma1, display = display.none)
ma1_useMTF   = input(false,        "MTF",   inline = "MA #1 MTF", active = show_ma1, display = display.none)
ma1_tf       = input.timeframe("", "",      inline = "MA #1 MTF", active = show_ma1)

show_ma2     = input(true,         "MA #2", inline = "MA #2", display = display.none)
ma2_type     = input.string("SMA", "",      inline = "MA #2", active = show_ma2, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source   = input(close,        "",      inline = "MA #2", active = show_ma2, display = display.none)
ma2_length   = input.int(20,       "",      inline = "MA #2", active = show_ma2, minval  = 1)
ma2_color    = input(color.rgb(0, 102, 255),      "",      inline = "MA #2", active = show_ma2, display = display.none)
ma2_useMTF   = input(false,        "MTF",   inline = "MA #2 MTF", active = show_ma2, display = display.none)
ma2_tf       = input.timeframe("", "",      inline = "MA #2 MTF", active = show_ma2)

show_ma3     = input(true,         "MA #3", inline = "MA #3", display = display.none)
ma3_type     = input.string("SMA", "",      inline = "MA #3", active = show_ma3, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source   = input(close,        "",      inline = "MA #3", active = show_ma3, display = display.none)
ma3_length   = input.int(50,      "",      inline = "MA #3", active = show_ma3, minval  = 1)
ma3_color    = input(#fbb000,      "",      inline = "MA #3", active = show_ma3, display = display.none)
ma3_useMTF   = input(false,        "MTF",   inline = "MA #3 MTF", active = show_ma3, display = display.none)
ma3_tf       = input.timeframe("", "",      inline = "MA #3 MTF", active = show_ma3)

show_ma4     = input(true,         "MA #4", inline = "MA #4", display = display.none)
ma4_type     = input.string("SMA", "",      inline = "MA #4", active = show_ma4, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source   = input(close,        "",      inline = "MA #4", active = show_ma4, display = display.none)
ma4_length   = input.int(200,      "",      inline = "MA #4", active = show_ma4, minval  = 1)
ma4_color    = input(#f60c0c,      "",      inline = "MA #4", active = show_ma4, display = display.none)
ma4_useMTF   = input(false,        "MTF",   inline = "MA #4 MTF", active = show_ma4, display = display.none)
ma4_tf       = input.timeframe("", "",      inline = "MA #4 MTF", active = show_ma4)

ma1 = show_ma1 ? mtfMA(ma1_source, ma1_length, ma1_type, ma1_useMTF, ma1_tf) : na
ma2 = show_ma2 ? mtfMA(ma2_source, ma2_length, ma2_type, ma2_useMTF, ma2_tf) : na
ma3 = show_ma3 ? mtfMA(ma3_source, ma3_length, ma3_type, ma3_useMTF, ma3_tf) : na
ma4 = show_ma4 ? mtfMA(ma4_source, ma4_length, ma4_type, ma4_useMTF, ma4_tf) : na

plot(ma1, "MA #1", ma1_color, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", ma2_color, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", ma3_color, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", ma4_color, display = show_ma4 ? display.all : display.none)
````
