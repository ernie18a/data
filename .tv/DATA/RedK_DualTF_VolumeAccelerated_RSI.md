<!-- tradingview-pine-id: PUB;bc66c34ff94946fb8b7f24b1d76591e0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RedK DualTF Volume-Accelerated RSI

Source: https://www.tradingview.com/script/BKy9A1Ii-RedK-DualTF-Volume-Accelerated-RSI-RedK-VARSI/

## Description

█ RedK_VARSI — Release Notes

The idea behind RedK Dual Timeframe Volume-Accelerated RSI (RedK_VARSI) is to enable traders to impose volume impact on the widely used [RSI (Relative Strength Index)](https://www.tradingview.com/support/solutions/43000502338/) indicator - for improved "combined price action + volume" analysis - and then to visualize the resulting insight from 2 different timeframes simultaneously; the current (chart's) timeframe, and a higher timeframe (the Context timeframe) of their choice. 

This analysis approach enables traders to effectively scan for opportunities, and make trading decisions that are in the direction of the broader market "context", without leaving the chart. 

Two quick notes here:
---------------------------

[*]Dual Timeframe RSI trading strategy is a very common technique among traders - used with various instruments (Futures, crypto, FOREX, stocks...) and various trading styles (scalp, swing, trend...) - What RedK_VARSI does is to provide an effective tool to enable traders to easily work their dual timeframe RSI analysis, in one chart, while also taking volume impact into consideration.

[*]RedK_VARSI is the modern sibling of an indicator I created back in 2020, the[ RedK Volume-Weighted RSI ](https://www.tradingview.com/script/BaTELgMy-RedK-Vol-Weighted-RSI-Extending-the-power-of-the-classic-RSI/).   The basic concept is the same, but there are features that could only be implemented with the more recent versions of Pine, like pulling true higher (context) timeframe volume-weighted RSI series, adding advanced visualization, dynamically enable and disable settings ...among other features. It's exciting to see what we can now achieve with the advancements in Pine compared to what was possible back then.

█  Reading VARSI - Indicator visual elements

https://www.tradingview.com/x/Sn6lOCav/

RedK_VARSI plots a volume-weighted RSI for the current chart timeframe (plotted as a blue/orange line), alongside a second VARSI read from a higher Context timeframe (plotted as green/red area backdrop). The main indicator panel is set as a 0 - 100 oscillator - same as the classic RSI.
When the two plots agree in direction from the midline, that means there's a momentum alignment across the two timeframes. When the two VARSI plots disagree, that possibly means the market is in transition - and the risk is higher - we should wait for a better setup.
(Throughout the settings and these notes, "Context" and "higher timeframe" mean the same thing)

Key indicator elements:

[*]Current TF volume-weighted RSI (VARSI), with a selectable moving-average method.
[*]Optional smoothing of the main RSI line, with its own selectable MA method.
[*]A signal line for the current VARSI.
[*]Context TF volume-weighted RSI — the same calculation on a higher timeframe, derived as a multiple of the current chart's timeframe.
[*]Alignment Markers: will show (if enabled) when the current and Context VARSI agree on direction.
[*]Single-timeframe mode — turn the Context off entirely and use VARSI as a straight, volume-weighted RSI - or turn volume-weighting off, and use RedK_VARSI as a regular RSI (see below settings in details).
[*] Other elements: similar to the classic RSI, there's overbought & oversold levels (70 and 30 respectively) and a midline (at 50). 

█  Indicator Settings & Usage
https://www.tradingview.com/x/vCFiAGao/

RedK_VARSI reads like a standard RSI. The 0–100 scale and the 50 midline work exactly as you'd expect, so everything you already know about reading the classic RSI still applies. 

[*]Volume weighting is the core idea: each bar's price change is weighted by that bar's volume before averaging, so moves on strong participation count for more than moves on thin volume. On symbols with no volume data, VARSI automatically falls back to a standard (unweighted) RSI, so it always works.

[*]Optional smoothing lets you take noise out of the main plot with a short moving average of your choice. Keep it small — smoothing always trades responsiveness for a cleaner line. Set it to 1 to switch it off.

[*]The Context timeframe is set as a multiplier of the current chart. For example, on a 1-hour chart a multiplier of 5 gives you a ~5-hour Context read. This is the modern, correct version of what I used to approximate with a length multiplier ("sentiment") in the old version.

[*]Context Update — Live vs Last Closed Bar. By default the Context TF VARSI updates live as the higher-timeframe bar develops. This is the most responsive behavior. If you prefer a steadier line that only changes when the higher-timeframe bar closes, switch to "Last Closed Bar."

[*]Alignment markers print when the current VARSI and the Context VARSI plots are on the same side of the midline — both bullish or both bearish. These are the moments when short-term momentum and the broader price momentum agree.

[*]Single-timeframe mode: If you just want a clean, volume-weighted RSI without a second timeframe, turn off "Show Context RSI." That hides the Context plot, its shading, and the alignment markers, leaving you a straightforward single-timeframe RSI with all the volume-weighting, smoothing, and signal-line features intact. The alerts work the same either way.

Setting RedK_VARSI to match TradingView's built-in RSI
Set Length = 14, Averaging = RMA, Smoothing = 1, and Volume Weighted = off — VARSI will match a classic RSI. Disable the Context TF to remove the higher TF area plot. 

https://www.tradingview.com/x/ah8GCZTU/

█  Using VARSI to analyze price action 
(for more details, search online for "Dual Timeframe RSI trading strategy")

[*]High-gain/lower-risk trade opportunities can be found (both to the upside or the downside) when the current timeframe momentum aligns with the broader timeframe. 
[*]VARSI can help you locate opportunities where the higher timeframe momentum gives a bullish reading, while the current (shorter) timeframe retraces within the bullish alignment - this works like catching the waves in an ongoing current. Opportunities to the downside (short) would be worked in a similar way in during a bearish alignment.
[*]Both the alignment markers and the signal line will provide the clues the trader needs to find these entry/re-entry setups - which a single timeframe RSI will not provide as effectively.

This screenshot shows examples of how to use VARSI to find possible bullish side setups 

https://www.tradingview.com/x/NLXgd25g/

█  Using Alerts in RedK-VARSI

RedK_VARSI introduces five alerts - to use the alerts, right-click on any indicator element, and choose the first shortcut menu command "Add alert on RedK_VARSI..." and choose one of the 5 alerts from the dropdown. See the screenshot below for the steps.

[*]VARSI crosses above the midline (bullish)
[*]VARSI crosses below the midline (bearish)
[*]VARSI swings around the midline (either direction — one alert for both)
[*]VARSI enters the overbought zone
[*]VARSI enters the oversold zone

https://www.tradingview.com/x/C6BgDQmq/

==================================================================================
📝 Notes on Use and Limitations
==================================================================================

[*]Volume data: if the symbol has no volume feed, VARSI automatically falls back to an unweighted (standard) RSI calculation.
[*]Context multiplier and available history: at very large multipliers the resulting Context timeframe may exceed the history available for some symbols, in which case the Context TF plot won't show. That's a data-availability limit, not an error.
[*]Debug option: an optional Debug checkbox shows the resolved Context timeframe in the Data Window (split into minutes, hours, or days) — handy for confirming exactly which timeframe the multiplier landed on.
[*]This is an insight tool, not a signal service. The markers and alerts describe price action readings. They are not advice to enter or exit any position, and the indicator does not claim predictive accuracy.

==================================================================================
⚠️ Important Notes & Disclaimer
==================================================================================
Using this indicator means you have read and agreed to the following:

[*]Not Advice. This indicator, and other work of this author, represent analytical studies of price and volume behavior. No parts should be considered buy/sell recommendations or signals — “Bulls” and “Bears” describe measured states only. Nothing here is financial, investment, or trading advice.

[*]Risk & Responsibility. Trading involves substantial risk of loss and is not for everyone. All decisions, interpretation, and risk and money management are yours alone. Past behavior does not predict future results. The author accepts no liability for any loss or consequence arising from use of this tool.

[*]Indicator Provided As-Is. Feature requests are welcome and can be shared with the author, but whether or when any request is implemented cannot be promised or guaranteed.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RedKTrader
// Internal Build version : 1.20
//
//@version = 6
indicator("RedK DualTF Volume-Accelerated RSI", shorttitle = 'RedK_VARSI v1.0', overlay = false, precision = 1)

// =====================================================================================================
//  RedK VARSI (Volume-Accelerated RSI)
//  A reworked Pine v6 successor to the 2020 "RedK Vol_Weighted RSI", 
//  with a request.security() - based higher-timeframe ("Context") calculation, 
//  optional smoothing, a signal line, Dual TF alignment markers, and introduces 5 alerts.
// =====================================================================================================


// *****************************************************************************************************
//  Selectable moving-average type
// -----------------------------------------------------------------------------------------------------
f_getMA(_data, _len, MAtype) =>
    value = switch MAtype
        'SMA' => ta.sma(_data, _len)
        'EMA' => ta.ema(_data, _len)
        'HMA' => ta.hma(_data, _len)
        'RMA' => ta.rma(_data, _len)
        => ta.wma(_data, _len)
    value

// *****************************************************************************************************
//  Volume-Weighted RSI, using the selected MA method
//  Note: change() and volume are both read in whatever context this runs in (chart or security),
//  so when called inside request.security() it correctly uses the HTF close-change and HTF volume.
// -----------------------------------------------------------------------------------------------------
f_CalcVW_Rsi(int _len, string avg_type, bool _volWeighted) =>
    _vol   = na(volume) or not _volWeighted ? 1.0 : volume
    chg    = ta.change(close) * _vol
    up     = f_getMA(math.max(chg, 0), _len, avg_type)
    down   = f_getMA(-math.min(chg, 0), _len, avg_type)
    rsiraw = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
    rsiraw


// -----------------------------------------------------------------------------------------------------
//   Inputs
// -----------------------------------------------------------------------------------------------------
grpC   = "Current Timeframe RSI"
grpH   = "Context Timeframe RSI"
grpsig = "Signal Line"
grplvl = "Levels"
disnon = display.none

// --- Current TF -------------------------------------------------------------------------------------
rsiLen   = input.int(14, minval = 1, title = "RSI Length", inline = "rsi", group = grpC)
avg_type = input.string('RMA', title = "Averaging", options = ['EMA', 'HMA', 'RMA', 'SMA', 'WMA'],
  inline = "rsi", group = grpC,
  tooltip = "Averaging method for the current-TF RSI.\nRMA reproduces Wilder's classic RSI." +
            "\nSet Length=14, Averaging=RMA, Smoothing=1, Volume Weighted=off to exactly match a standard RSI.")

VolWeighted = input.bool(true, "Volume Weighted", group = grpC,
  tooltip = '''When on, each bar's price change is weighted by that bar's volume before averaging. This
  emphasises moves that happen on higher participation.
  \nTurn off for a pure price-based RSI.''')

smooth    = input.int(3, minval = 1, title = "Smoothing", inline = "smooth", group = grpC, display = disnon)
smth_type = input.string('WMA', title = "Averaging", options = ['EMA', 'HMA', 'RMA', 'SMA', 'WMA'], display = disnon,
  inline = "smooth", group = grpC, active = smooth > 1,
  tooltip = "Optional smoothing to apply to Current TF RSI." +
            "\nHelps remove noise but introduces lag. Keep to small values or disable.")

col_rsi_long  = input.color(color.aqua, title = "Bullish", inline = "rsi_c", group = grpC)
col_rsi_short = input.color(#f57f17,     title = "Bearish", inline = "rsi_c", group = grpC)

// --- Signal line ------------------------------------------------------------------------------------
signal_len   = input.int(5, "Length", minval = 1, inline = "sig", group = grpsig, display = disnon)
sig_avg_type = input.string('EMA', title = "  Averaging", options = ['EMA', 'HMA', 'RMA', 'SMA', 'WMA'], display = disnon,
  inline = "sig", group = grpsig, active = signal_len > 1,
  tooltip = "Length and Averaging method for the RSI Signal Line.")
col_signal   = input.color(color.blue, title = "Signal Line Color", active = signal_len > 1,
  inline = "sig_c", group = grpsig)

// --- Context (Higher) TF ----------------------------------------------------------------------------
show_htf = input.bool(true, "Show Context RSI", group = grpH, display = disnon,
  tooltip = "Disabling this turns VARSI into a single TF volume-weighted RSI, and hides the Context TF Plot.\n" +
            "Also turns off the Alignment Markers & related alerts.")
htf_mult   = input.int(5, "Context Multiplier (× chart TF)", minval = 2, maxval = 60, group = grpH, 
  display = disnon, active = show_htf,
  tooltip = "Context TF = this many times the current chart timeframe. e.g. 5 on a 1H chart ≈ 5H")
            
htf_update = input.string('Live Update', "Context Update", options = ['Live Update', 'Last Closed Bar'], group = grpH, 
  display = disnon, active = show_htf,
  tooltip = "Live Update (default): the Context RSI updates as the higher-TF bar develops — most responsive. " +
            "Last Closed Bar: the Context RSI only changes when the higher-TF bar closes — steadier, no intrabar movement. " +
            "Has no effect when the Context TF equals the chart TF.")

col_rsiH_long  = input.color(#33aa00, title = "Bullish", inline = "htf_c", group = grpH, active = show_htf)
col_rsiH_short = input.color(#ff1111, title = "Bearish", inline = "htf_c", group = grpH, active = show_htf)

// --- Levels -----------------------------------------------------------------------------------------
show_align = input.bool(true, "Show Alignment Markers", group = grplvl, active = show_htf,
  tooltip = "Plot a marker when the Current TF RSI and the Context RSI agree on direction (both above / both below 50).")


// =====================================================================================================
//   Calculations
// -----------------------------------------------------------------------------------------------------
midline  = 50
ob_level = 70   
os_level = 30   

// Current TF VW-RSI + optional smoothing
rsiCTF_raw = f_CalcVW_Rsi(rsiLen, avg_type, VolWeighted)
rsiCTF     = smooth > 1 ? f_getMA(rsiCTF_raw, smooth, smth_type) : rsiCTF_raw

// Signal line
rsi_sig = signal_len > 1 ? f_getMA(rsiCTF, signal_len, sig_avg_type) : rsiCTF

// Resolve Context TF via the built-in (multiplier method)
htf_tf = timeframe.from_seconds(int(timeframe.in_seconds(timeframe.period) * htf_mult))

// Context TF must be >= chart TF. With minval=2 on the multiplier this is effectively always true,
// a lower resolved TF can never plot a misleading faster-than-chart backdrop.
htf_secs    = timeframe.in_seconds(htf_tf)
chart_secs  = timeframe.in_seconds(timeframe.period)
htf_invalid = htf_secs < chart_secs

// Pull the Context VW-RSI.
rsiHi_raw = request.security(syminfo.tickerid, htf_tf,
             f_CalcVW_Rsi(rsiLen, avg_type, VolWeighted),
             lookahead = barmerge.lookahead_off)

// The confirmed-bar offset is only meaningful when the Context TF is strictly higher than the chart TF;
// equal/lower uses the live value (avoids a pointless one-bar lag).
htf_is_higher   = htf_secs > chart_secs
use_last_closed = htf_update == 'Last Closed Bar' and htf_is_higher
rsiHi = (htf_invalid or not show_htf) ? na : (use_last_closed ? rsiHi_raw[1] : rsiHi_raw)

// Direction / alignment state (alignment requires a valid, shown Context)
ctf_up   = rsiCTF > midline
htf_up   = rsiHi  > midline
aligned_up   = show_htf and not htf_invalid and ctf_up  and htf_up
aligned_down = show_htf and not htf_invalid and (not ctf_up) and (not htf_up)


// =====================================================================================================
//   Plots
// -----------------------------------------------------------------------------------------------------
// Levels first so z-order keeps the main line on top

dw          = display.data_window
d_sl        = display.status_line
dsp_dp_dw   = display.pane + display.data_window
// if a higher TF is enabled, realted plots will show in panel and data window, otherwise hide all
dsp_htf     = show_htf ? dsp_dp_dw + d_sl : disnon 
dsp_htf_am  = show_htf ? dsp_dp_dw : disnon 

hline(midline,  title = "Midline",     color = color.new(color.yellow, 50), linestyle = hline.style_dotted)
hline(ob_level, title = "Overbought",  color = color.new(color.green,  30), linestyle = hline.style_dashed)
hline(os_level, title = "Oversold",    color = color.new(color.red,    30), linestyle = hline.style_dashed)


p1 = plot(rsiCTF, title = "Current RSI", color = ctf_up ? col_rsi_long : col_rsi_short, linewidth = 3)

ps = plot(rsi_sig, title = "RSI Signal", color = col_signal, linewidth = 1, display = d_sl + dsp_dp_dw)

p2 = plot(rsiHi, title = "Higher TF RSI",
     color = htf_up ? col_rsiH_long : col_rsiH_short, linewidth = 1, display = dsp_htf)

pl_midline = plot(midline, "midline ref", color = color.new(color.white, 100),
     editable = false, display = display.none)

// Context sentiment fill (above / below midline)
fill(p2, pl_midline, top_value = 100, bottom_value = 50,
    top_color = color.new(col_rsiH_long, 20), bottom_color = color.new(col_rsiH_long, 90))
fill(pl_midline, p2, top_value = 50, bottom_value = 0,
    top_color = color.new(col_rsiH_short, 90), bottom_color = color.new(col_rsiH_short, 20))

//==========================================================================================================
// Alignment markers - note to hide them also in data window if no HTF is plotted
plotshape(show_align and aligned_up   and not aligned_up[1],   title = "Bull Alignment", 
  display = not show_align ? disnon : dsp_htf_am,
     style = shape.triangleup,   location = location.bottom, color = col_rsiH_long,  size = size.small)
plotshape(show_align and aligned_down and not aligned_down[1], title = "Bear Alignment", 
  display = not show_align ? disnon : dsp_htf_am,
     style = shape.triangledown, location = location.top,    color = col_rsiH_short, size = size.small)


// =====================================================================================================
//   Alerts — all based on the single (Current TF) VARSI line,
//      so they are independent of the Context setting. 
// -----------------------------------------------------------------------------------------------------

alertcondition(ta.crossover(rsiCTF, midline),  title = "VARSI crosses above midline (Bullish)",
  message = "{{ticker}} — VARSI crossed ABOVE the midline (bullish)")
alertcondition(ta.crossunder(rsiCTF, midline), title = "VARSI crosses below midline (Bearish)",
  message = "{{ticker}} — VARSI crossed BELOW the midline (bearish)")
alertcondition(ta.cross(rsiCTF, midline),      title = "VARSI swings around midline (Up or Down)",
  message = "{{ticker}} — VARSI crossed the midline")

alertcondition(ta.crossover(rsiCTF, ob_level), title = "VARSI enters Overbought zone",
  message = "{{ticker}} — VARSI entered the Overbought zone")
alertcondition(ta.crossunder(rsiCTF, os_level),title = "VARSI enters Oversold zone",
  message = "{{ticker}} — VARSI entered the Oversold zone")


// =====================================================================================================
//  Extra debug: show the resolved Context TF in the Data Window. 
// -----------------------------------------------------------------------------------------------------
dbg = input.bool(false, "Debug: quick method to show selected Context TF in Data Window", group = grpH, active = show_htf,
  tooltip = "Will display as minutes, then hours if > 60, then days if > 1,440.")

htf_mins = htf_secs / 60.0


plot(dbg and htf_mins <= 60                       ? htf_mins        : na, "Context TF (mins)", 
  display = dbg and show_htf ? dw : disnon)
plot(dbg and htf_mins >  60 and htf_mins <= 1440  ? htf_mins / 60.0 : na, "Context TF (hrs)",  
  display = dbg and show_htf ? dw : disnon)
plot(dbg and htf_mins >  1440                     ? htf_mins / 1440.0 : na, "Context TF (days)", 
  display = dbg and show_htf ? dw : disnon)
````
