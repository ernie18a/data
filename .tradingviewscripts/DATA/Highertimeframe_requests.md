<!-- tradingview-pine-id: PUB;fdf308fa2abe46309c350fa8183ed3a0 -->
<!-- tradingviewscripts-format: 1 -->
# Higher-timeframe requests

Source: https://www.tradingview.com/script/W1YpYcOI-Higher-timeframe-requests/

## Description

█  OVERVIEW

This publication focuses on enhancing awareness of the best practices for accessing higher-timeframe (HTF) data via the [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) function. Some "traditional" approaches, such as what we explored in our previous [`security()` revisited](https://www.tradingview.com/script/00jFIl5w-security-revisited-PineCoders/) publication, have shown limitations in their ability to retrieve non-repainting HTF data. The fundamental technique outlined in this script is currently the most effective in preventing repainting when requesting data from a higher timeframe. For detailed information about why it works, see [this](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Other_timeframes_and_data.html#historical-and-realtime-behavior) section in the Pine Script™ [User Manual](https://www.tradingview.com/pine-script-docs/en/v5/index.html).

█  CONCEPTS

Understanding repainting

[Repainting](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Repainting.html) is a behavior that occurs when a script's calculations or outputs behave differently after restarting it. There are several types of repainting behavior, not all of which are inherently useless or misleading. The most prevalent form of repainting occurs when a script's calculations or outputs exhibit different behaviors on historical and realtime bars. 

When a script calculates across historical data, it only needs to execute once per bar, as those values are confirmed and not subject to change. After each historical execution, the script commits the states of its calculations for later access. 

On a realtime, unconfirmed bar, values are [fluid](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Repainting.html#fluid-data-values). They are subject to change on each new tick from the data provider until the bar closes. A script's code can execute on each tick in a realtime bar, meaning its calculations and outputs are subject to realtime fluctuations, just like the underlying data it uses. Each time a script executes on an unconfirmed bar, it first reverts applicable values to their last committed states, a process referred to as rollback. It only commits the new values from a realtime bar after the bar closes. See the User Manual's [Execution model](https://www.tradingview.com/pine-script-docs/en/v5/language/Execution_model.html) page to learn more.

In essence, a script can repaint when it calculates on realtime bars due to fluctuations before a bar's confirmation, which it cannot reproduce on historical data. A common strategy to avoid repainting when necessary involves forcing only confirmed values on realtime bars, which remain unchanged until each bar's conclusion. 

Repainting in higher-timeframe (HTF) requests

When working with a script that retrieves data from higher timeframes with [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security), it's crucial to understand the differences in how such requests behave on [historical and realtime bars](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Other_timeframes_and_data.html#historical-and-realtime-behavior).

The [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) function executes all code required by its `expression` argument using data from the specified context (symbol, timeframe, or modifiers) rather than on the chart's data. As when executing code in the chart's context, [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) only returns new historical values when a bar closes in the requested context. However, the values it returns on realtime HTF bars can also update before confirmation, akin to the rollback and recalculation process that scripts perform in the chart's context on the open bar. Similar to how scripts operate in the chart's context, [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) only confirms new values after a realtime bar closes in its specified context.

Once a script's execution cycle restarts, what were previously realtime bars become historical bars, meaning the [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) call will only return confirmed values from the HTF on those bars. Therefore, if the requested data fluctuates across an open HTF bar, the script will repaint those values after it restarts. 

This behavior is not a bug; it's simply the default behavior of [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security). In some cases, having the latest information from an unconfirmed HTF bar is precisely what a script needs. However, in many other cases, traders will require confirmed, stable values that do not fluctuate across an open HTF bar. Below, we explain the most reliable approach to achieve such a result. 

Achieving consistent timing on all bars

One can retrieve non-fluctuating values with consistent timing across historical and realtime feeds by exclusively using [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) to fetch the data from confirmed HTF bars. The best way to achieve this result is offsetting the `expression` argument by at least one bar (e.g., `close[][1[]]`) and using [barmerge.lookahead_on](https://www.tradingview.com/pine-script-reference/v5/#const_barmerge.lookahead_on) as the `lookahead` argument. 

We discourage the use of [barmerge.lookahead_on](https://www.tradingview.com/pine-script-reference/v5/#const_barmerge.lookahead_on) alone since it prompts the function to look toward future values of HTF bars across historical data, which is heavily misleading. However, when paired with a requested `expression` that includes a one-bar historical offset, the "future" data the function retrieves is not from the future. Instead, it represents the last confirmed bar's values at the start of each HTF bar, thus preventing the results on realtime bars from fluctuating before confirmation from the timeframe.  

For example, this line of code uses a [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) call with [barmerge.lookahead_on](https://www.tradingview.com/pine-script-reference/v5/#const_barmerge.lookahead_on) to request the [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) price from the "1D" timeframe, offset by one bar with the history-referencing operator [[][[]]](https://www.tradingview.com/pine-script-reference/v5/#op_%5B%5D). This line will return the daily price with consistent timing across all bars:

[pine]float htfClose = request.security(syminfo.tickerid, "1D", close[1], lookahead = barmerge.lookahead_on)[/pine]

Note that:
 • This technique only works as intended for higher-timeframe requests.
 • When designing a script to work specifically with HTFs, we recommend including conditions to prevent [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) from accessing timeframes equal to or lower than the chart's timeframe, especially if you intend to [publish](https://www.tradingview.com/pine-script-docs/en/v5/writing/Publishing.html#publishing-scripts) it. In this script, we included an [if](https://www.tradingview.com/pine-script-reference/v5/#kw_if) structure that raises a [runtime error](https://www.tradingview.com/pine-script-reference/v5/#fun_runtime.error) when the requested timeframe is too small. 
 • A necessary trade-off with this approach is that the script must wait for an HTF bar's confirmation to retrieve new data on realtime bars, thus delaying its availability until the open of the subsequent HTF bar. The time elapsed during such a delay varies with each market, but it's typically relatively small. 

👉 Failing to offset the function's `expression` argument while using [barmerge.lookahead_on](https://www.tradingview.com/pine-script-reference/v5/#const_barmerge.lookahead_on) will produce historical results with lookahead bias, as it will look to the future states of historical HTF bars, retrieving values before the times at which they're available in the feed. See the [`lookahead`](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Other_timeframes_and_data.html#lookahead) and [Future leak with `request.security()`](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Repainting.html#future-leak-with-request-security) sections in the Pine Script™ User Manual for more information. 

Evolving practices

The fundamental technique outlined in this publication is currently the only reliable approach to requesting non-repainting HTF data with [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security). It is the superior approach because it avoids the pitfalls of other methods, such as the one introduced in the [`security()` revisited](https://www.tradingview.com/script/00jFIl5w-security-revisited-PineCoders/) publication. That publication proposed using a custom `f_security()` function, which applied offsets to the `expression` and the requested result based on [historical](https://www.tradingview.com/pine-script-reference/v5/#var_barstate.ishistory) and [realtime](https://www.tradingview.com/pine-script-reference/v5/#var_barstate.isrealtime) bar states. At that time, we explored techniques that didn't carry the risk of lookahead bias if misused (i.e., removing the historical offset on the `expression` while using lookahead), as requests that look ahead to the future on historical bars exhibit dangerously misleading behavior. 

Despite these efforts, we've unfortunately found that the bar state method employed by `f_security()` can produce inaccurate results with inconsistent timing in some scenarios, undermining its credibility as a universal non-repainting technique. As such, we've deprecated that approach, and the Pine Script™ User Manual no longer recommends it.

█  METHOD VARIANTS

In this script, all non-repainting requests employ the same underlying technique to avoid repainting. However, we've applied variants to cater to specific use cases, as outlined below:

Variant 1

Variant 1, which the script displays using a [lime](https://www.tradingview.com/pine-script-reference/v5/#const_color.lime) plot, demonstrates a non-repainting HTF request in its simplest form, aligning with the concept explained in the "Achieving consistent timing" section above. It uses [barmerge.lookahead_on](https://www.tradingview.com/pine-script-reference/v5/#const_barmerge.lookahead_on) and offsets the `expression` argument in [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) by one bar to retrieve the value from the last confirmed HTF bar. For detailed information about why this works, see the [Avoiding Repainting](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Other_timeframes_and_data.html#avoiding-repainting) section of the User Manual's [Other timeframes and data](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Other_timeframes_and_data.html) page. 

Variant 2

Variant 2 ([fuchsia](https://www.tradingview.com/pine-script-reference/v5/#const_color.fuchsia)) introduces a custom function, `htfSecurity()`, which wraps the [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) function to facilitate convenient repainting control. By specifying a value for its `repaint` parameter, users can determine whether to allow repainting HTF data. When the `repaint` value is `false`, the function applies lookahead and a one-bar offset to request the last confirmed value from the specified `timeframe`. When the value is `true`, the function requests the `expression` using the default behavior of [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security), meaning the results can fluctuate across chart bars within realtime HTF bars and repaint when the script restarts. 

Note that:
 • This function exclusively handles HTF requests. If the requested timeframe is not higher than the chart's, it will raise a [runtime error](https://www.tradingview.com/pine-script-reference/v5/#fun_runtime.error). 
 • We prefer this approach since it provides optional repainting control. Sometimes, a script's calculations need to respond immediately to realtime HTF changes, which `repaint = true` allows. In other cases, such as when issuing alerts, triggering strategy commands, and more, one will typically need stable values that do not repaint, in which case `repaint = false` will produce the desired behavior. 

Variant 3

Variant 3 ([white](https://www.tradingview.com/pine-script-reference/v5/#const_color.white)) builds upon the same fundamental non-repainting approach used by the first two. The difference in this variant is that it applies repainting control to [tuples](https://www.tradingview.com/pine-script-docs/en/v5/language/Type_system.html#tuples), which one cannot pass as the `expression` argument in our `htfSecurity()` function. Tuples are handy for consolidating `request.*()` calls when a script requires several values from the same context, as one can request a single tuple from the context rather than executing multiple separate [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) calls. 

This variant applies the internal logic of our `htfSecurity()` function in the script's [global scope](https://www.tradingview.com/pine-script-docs/en/v5/language/Script_structure.html#code) to [request a tuple](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Other_timeframes_and_data.html#tuples) containing [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and `srcInput` values from a higher timeframe with repainting control. Historically, Pine Script™ did not allow the history-referencing operator [[][[]]](https://www.tradingview.com/pine-script-reference/v5/#op_%5B%5D) when requesting tuples unless the tuple came from a function call, which limited this technique. However, updates to Pine over time have lifted this restriction, allowing us to pass tuples with historical offsets directly as the `expression` in [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security). By offsetting all items in a tuple `expression` by one bar and using [barmerge.lookahead_on](https://www.tradingview.com/pine-script-reference/v5/#const_barmerge.lookahead_on), we effectively retrieve a tuple of stable, non-repainting HTF values. 

Since we cannot encapsulate this method within the `htfSecurity()` function and must execute the calculations in the global scope, the script's "Repainting" input directly controls the global `offset` and `lookahead` values to ensure it behaves as intended. 

Variant 4 (Control)

Variant 4, which the script displays as a translucent [orange](https://www.tradingview.com/pine-script-reference/v5/#const_color.orange) plot, uses a default [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) call, providing a reference point to compare the difference between a repainting request and the non-repainting variants outlined above. Whenever the script restarts its execution cycle, [realtime](https://www.tradingview.com/pine-script-reference/v5/#var_barstate.isrealtime) bars become [historical](https://www.tradingview.com/pine-script-reference/v5/#var_barstate.ishistory) bars, and the [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request.security) call here will repaint the results on those bars. 

█  Inputs

Repainting

The "Repainting" input (`repaintInput` variable) controls whether Variant 2 and Variant 3 are allowed to use fluctuating values from an unconfirmed HTF bar. If its value is `false` (default), these requests will only retrieve stable values from the last confirmed HTF bar. 

Source

The "Source" input (`srcInput` variable) determines the series the script will use in the `expression` for all HTF data requests. Its default value is [close](https://www.tradingview.com/pine-script-reference/v5/#var_close).

HTF Selection

This script features two ways to specify the higher timeframe for all its data requests, which users can control with the "HTF Selection" input (`tfTypeInput` variable):
 1) If its value is "Fixed TF", the script uses the timeframe value specified by the "Fixed Higher Timeframe" input (`fixedTfInput` variable). The script will raise a [runtime error](https://www.tradingview.com/pine-script-reference/v5/#fun_runtime.error) if the selected timeframe is not larger than the chart's. 
 2) If the input's value is "Multiple of chart TF", the script multiplies the value of the "Timeframe Multiple" input (`tfMultInput` variable) by the chart's [timeframe.in_seconds()](https://www.tradingview.com/pine-script-reference/v5/#fun_timeframe.in_seconds) value, then converts the result to a [valid timeframe string](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Timeframes.html#timeframe-string-specifications) via [timeframe.from_seconds()](https://www.tradingview.com/pine-script-reference/v5/#fun_timeframe.from_seconds).

Timeframe Display

This script features the option to display an "information box", i.e., a single-cell (https://www.tradingview.com/pine-script-reference/v5/#type_table) that shows the higher timeframe the script is currently using. Users can toggle the display and determine the table's size, location, and color scheme via the inputs in the "Timeframe Display" group. 

█  Outputs

This script produces the following outputs:
 • It plots the results from all four of the above variants for visual comparison. 
 • It highlights the chart's background [gray](https://www.tradingview.com/pine-script-reference/v5/#const_color.gray) whenever a new bar starts on the higher timeframe, signifying when confirmations occur in the requested context. 
 • To demarcate which bars the script considers [historical](https://www.tradingview.com/pine-script-reference/v5/#var_barstate.ishistory) or [realtime](https://www.tradingview.com/pine-script-reference/v5/#var_barstate.isrealtime) bars, it plots squares with contrasting colors corresponding to bar states at the bottom of the chart pane. 
 • It displays the higher timeframe string in a single-cell (https://www.tradingview.com/pine-script-reference/v5/#type_table) with a user-specified size, location, and color scheme.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PineCoders

//@version=5
indicator("Higher-timeframe requests", "", true)

// Higher-timeframe requests
// v1, 2024.03.29

// This code was written using the recommendations from the Pine Script™ User Manual's Style Guide:
//   https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html



//#region ———————————————————— Constants and inputs


// Constants
color  GRAY    = color.gray
color  WHITE   = color.white
color  ORANGE  = color.orange
color  FUCHSIA = color.fuchsia
color  LIME    = color.lime
string TICKER  = syminfo.tickerid
string ON      = "On"
string OFF     = "Off"
string TF0     = "Fixed TF"
string TF1     = "Multiple of chart TF"

// Tooltips
string TT_TFT = "The higher timeframe selection method. Possible options: '" + TF0 + "'' or '" + TF1 + "'."
string TT_FTF = "A fixed timeframe value. If the 'HTF Selection' value is 'Fixed TF', this input determines the 
     higher timeframe for the data requests."
string TT_TFM = "The multiplier applied to the chart's timeframe. For example, the higher timeframe calculated on a 
     15m chart with a multiple of 4 is 60m (1h). This input only affects the output when using 'Multiple of chart TF' 
     as the 'HTF Selection' value."

// Inputs
string GRP1         = "Calculations"
bool   repaintInput = input.string(OFF,     "Repainting",                group = GRP1, options = [ON, OFF]) == ON
float  srcInput     = input.source(close,   "Source",                    group = GRP1)
string tfTypeInput  = input.string(TF1,     "HTF Selection",             group = GRP1, options = [TF0, TF1], tooltip = TT_TFT)
string fixedTfInput = input.timeframe("1D", "  Fixed Higher Timeframe:", group = GRP1,                       tooltip = TT_FTF)
int    tfMultInput  = input.int(4,          "  Timeframe Multiple",      group = GRP1, minval = 1,           tooltip = TT_TFM)

string GRP2                 = "Timeframe Display"
bool   showInfoBoxInput     = input.bool(true,       "Show timeframe",                group = GRP2)
string infoBoxSizeInput     = input.string("large",  "Size ",          inline = "21", group = GRP2, options = ["tiny", "small", "normal", "large", "huge", "auto"])
string infoBoxYPosInput     = input.string("bottom", "↕",              inline = "21", group = GRP2, options = ["top", "middle", "bottom"])
string infoBoxXPosInput     = input.string("right",  "↔",              inline = "21", group = GRP2, options = ["left", "center", "right"])
color  infoBoxColorInput    = input.color(GRAY,      "",               inline = "21", group = GRP2)
color  infoBoxTxtColorInput = input.color(WHITE,     "T",              inline = "21", group = GRP2)
//#endregion



//#region ———————————————————— Calculations


// @variable A multiple of the chart's timeframe or a fixed higher timeframe, depending on the `tfTypeInput` value.
string requestedTf = switch tfTypeInput
    TF0 => fixedTfInput
    TF1 => timeframe.from_seconds(timeframe.in_seconds() * tfMultInput)


// ————— Variant 1. Basic non-repainting HTF `request.security()` call (LIME)

// Here, we demonstrate a non-repainting HTF request in its simplest form. The call uses `barmerge.lookahead_on`,
// meaning the function looks ahead to the final values of historical bars and references the current value on realtime 
// bars. However, since the `expression` in the call (`srcInput`) is offset by 1 bar, the "future" data the function 
// accesses is never from the future. It always represents the value from the last confirmed HTF bar. 


// @variable The `srcInput` value from the last confirmed bar on the `requestedTf`.
float c0 = request.security(TICKER, requestedTf, srcInput[1], lookahead = barmerge.lookahead_on)


// ————— Variant 2. `htfSecurity()` with repainting control (FUCHSIA)

// Here, the `htfSecurity()` function wraps `request.security()` to allow convenient control of repainting behavior. 
// When its `repaint` value is `false`, it offsets the input expression by one bar and uses `barmerge.lookahead_on` 
// as the `lookahead` value in the data request. 

// NOTE: This function cannot accept a tuple as its `expression` argument. However, it can accept an object of a 
//       user-defined type (UDT) to achieve a similar result. For a demonstration of a non-repainting tuple request, 
//       see Method 3 below.


// @function            A wrapper for `request.security()` with HTF repainting control. 
// @param symbol        (simple string) Symbol to request the data from.
// @param timeframe     (simple string) Timeframe of the requested data. Must be greater than the chart's timeframe. 
// @param expression    (<any type>) An expression to calculate and return from the requested context.
// @param repaint       (simple bool) Condition to determine whether the requested `expression` can repaint. 
//                      Optional. Default is false.
// @returns             (<any type>) The value of the `expression` from the requested `symbol` and `timeframe`.
htfSecurity(simple string symbol, simple string timeframe, expression, simple bool repaint = false) => 
    if timeframe.in_seconds(timeframe) <= timeframe.in_seconds() 
        runtime.error(
             "The requested timeframe (" + timeframe + ") is too small. Select a higher timeframe." 
         )
    int offset = repaint ? 0 : 1
    lookahead  = repaint ? barmerge.lookahead_off : barmerge.lookahead_on
    result     = request.security(symbol, timeframe, expression[offset], lookahead = lookahead)

// Return `srcInput` from the requested context using `htfSecurity()`, controlling repainting with `repaintInput`. 
float c1 = htfSecurity(TICKER, requestedTf, srcInput, repaintInput)


// ————— Variant 3. Non-repainting calls returning tuples (WHITE)

// While the `htfSecurity()` function above will allow one to easily request most types of data with repainting 
// control, scripts cannot use tuples as arguments in user-defined functions. If one needs to request a tuple from a 
// higher-timeframe context with repainting control, they can apply the above function's logic in the outer scope. 


// Set `offset` and `lookahead` variables based on `repaintInput` to control repainting: 
// 0 and `barmerge.lookahead_off` for repainting, 1 and `barmerge.lookahead_on` for non-repainting.
int offset = repaintInput ? 0 : 1
lookahead  = repaintInput ? barmerge.lookahead_off : barmerge.lookahead_on

// Request a tuple of the `open` and `srcInput` using `offset` and `lookahead` to manage repainting.
// Note that each expression in the tuple applies the `offset`.
[o2, c2] = request.security(TICKER, requestedTf, [open[offset], srcInput[offset]], lookahead = lookahead)


// ————— Variant 4, Control. Default `request.security()` call, which is subject to repainting. (ORANGE)

// Here, we included a `request.security()` call with default settings as a reference point. 
// Unlike the variants outlined above, this call behaves differently on historical and realtime bars. 
// When the script restarts its execution pattern, what were once considered realtime bars become historical bars.
// Consequently, the results across those bars may repaint. 


// @variable The `srcInput` value from the `TICKER` on the `requestedTf` timeframe. Its result can repaint.
float c3 = request.security(TICKER, requestedTf, srcInput)
//#endregion



//#region ———————————————————— Errors and outputs


// Raise a runtime error when the user-selected TF isn't higher than the chart TF.
if timeframe.in_seconds(requestedTf) <= timeframe.in_seconds() 
    runtime.error(
         "The requested timeframe (" + requestedTf + ") is too small. Select a higher timeframe."
     )

// ————— Plot values from `request.security()` examples.
plot(na, "══════════ PLOTS", display = display.data_window)
plot(c3, "Method 4: 🔨 Basic repainting call", color.new(ORANGE, 30), 8)
plot(c0, "Method 1: 👍 Non-repaintng call",    LIME,                  6)
plot(c1, "Method 2: 👍 `htfSecurity()`",       FUCHSIA,               4)
plot(c2, "Method 3: 👍 Tuple form",            WHITE,                 1)

// Plot squares at the chart's bottom, using contrasting colors for historical bars and orange for realtime bars, to 
// visually distinguish bars where data will repaint in variants permitting it.
plotshape(barstate.ishistory,  "`barstate.ishistory`",  shape.square, location.bottom, color.new(chart.fg_color, 70))
plotshape(barstate.isrealtime, "`barstate.isrealtime`", shape.square, location.bottom, color.new(ORANGE,         50))

// Mark timeframe changes by highlighting the background gray.
bgcolor(timeframe.change(requestedTf) ? color.new(GRAY, 80) : na, title = "Timeframe change highlight")

// Display the user-selected TF in a single-cell table.
if showInfoBoxInput and barstate.islastconfirmedhistory
    var table tfDisplay = table.new(str.format("{0}_{1}", infoBoxYPosInput, infoBoxXPosInput), 1, 1)
    table.cell(
         tfDisplay, 0, 0, requestedTf, bgcolor = infoBoxColorInput, text_color = infoBoxTxtColorInput, 
         text_size = infoBoxSizeInput
     )
//#endregion
````
