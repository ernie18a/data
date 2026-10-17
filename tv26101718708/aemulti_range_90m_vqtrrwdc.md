# AE_Multi Range 90m

- url: https://www.tradingview.com/script/vQtrrWDC-AE-Multi-Range-90m/
- type: indicator
- pine_id: PUB;281cee5c708d433bbfdd1dc5adef66f4
- version: 1.0

## Description

[b]A 90-minute Opening Range (ORB) and market-structure mapping tool for intraday trading.[/b]

AE_Multi Range 90m is a session-based structural mapping tool built around 90-minute Opening Ranges, with optional higher-timeframe MAIN references.
The idea behind this indicator is simple:
Instead of manually drawing numerous intraday support/resistance levels, allow defined 90-minute ranges to automatically build a continuously evolving map of price structure.
The screenshot shows one MAIN reference together with two active 90-minute zones. This allows the relationship between the higher session structure and the smaller 90-minute ranges to be seen directly on the chart.

The example chart below shows AE_Multi Range 90m being used alongside my separate AE_RSI HARMONY indicator. RSI HARMONY is not included in this script; it is shown only to demonstrate how the 90-minute structural framework can be used within a broader discretionary analysis workflow.

[b]WHAT IT DOES[/b]

Each selected 90-minute zone provides:
• ORB High
• ORB Low
• CE (Center Equilibrium)
• Optional breakout alerts

The indicator provides two independent 90-minute selections:
• Active Zone 1
• Active Zone 2
Both include a None option, so either zone can be completely disabled when it is not required.

The indicator also provides two independent higher-timeframe MAIN references:
• MAIN1
• MAIN2

Each MAIN can independently be set to:
• Sydney
• Tokyo
• London
• None

This allows the indicator to be used in several different configurations.

[i]1. 90M ONLY[/i]
Set:
MAIN1 = None
MAIN2 = None
The chart becomes a pure 90-minute structural map.

[i]2. ONE MAIN + 90M RANGES[/i]
Use one MAIN reference together with one or two active 90-minute zones.

[i]3. TWO MAIN REFERENCES + 90M RANGES[/i]
Use both MAIN1 and MAIN2 when two higher-timeframe session references are useful.

[i]4. COMPLETELY CUSTOM[/i]
Because every MAIN and Active Zone has an independent None option, the trader can decide exactly how much information should be displayed.

[b]THE IDEA BEHIND THE 90M STRUCTURE[/b]

One of the observations behind this project is that the automatically generated 90-minute range boundaries can become useful structural reference points throughout the trading session.
As new ranges develop, their highs and lows can naturally coincide with areas where short-term market structure changes.
For example, a 90-minute high may become an area where price breaks an existing short-term structure, while a 90-minute low may become a reference point for a downside structural transition.
This means the 90-minute framework can sometimes provide a visual reference for BOS/MSS-type structural changes without requiring additional manually drawn lines.
This is an observation from testing and chart study, not a claim that every 90-minute level will produce a reversal or successful trade.
The purpose of the indicator is to make these structural relationships easier to see.

[b]WHY I BUILT IT[/b]

During testing, I found myself repeatedly drawing additional horizontal levels to understand where price had previously established structure.
That created the usual problem:
more information → more lines → more visual noise.
The experiment was to remove some of those manually drawn levels and see whether the 90-minute framework could provide enough of the same structural information automatically.
The result was interesting enough to turn the idea into a dedicated tool.
The objective is therefore not to create another indicator that tells you when to buy or sell.
The objective is to create a clean structural map and allow price action to interact with it.

[b]HOW I USE IT[/b]

A simple workflow is:
Higher structure → 90M structure → price action
MAIN1/MAIN2 can be used when a higher session reference is useful.
The 90-minute ranges then provide the intraday structural framework.
From there, price action can be observed around:
• Previous ORB High
• Previous ORB Low
• CE
• Breaks of range boundaries
• Retests of broken boundaries
• Areas where multiple levels converge
• Changes in short-term market structure
The indicator does not determine the trade.
It simply makes the structural information available.

[i]CE — CENTER EQUILIBRIUM[/i]
The CE is calculated as the midpoint between the ORB High and ORB Low:
CE = (High + Low) / 2
It can be displayed after the ORB period and used as an additional reference inside the completed range.

[b]ALERTS[/b]
The indicator includes breakout alerts for:
• MAIN1 / MAIN2 ORB High
• MAIN1 / MAIN2 ORB Low
• Active Zone 1 High
• Active Zone 1 Low
• Active Zone 2 High
• Active Zone 2 Low
The alerts are intended as notifications that price has crossed a defined structural level.
They are not buy or sell signals.

[i][b]INSPIRATION & CREDIT[/b][/i]

This project was inspired by the work and ideas of @Eskemo_Bob .
I want to explicitly acknowledge @Eskemo_Bob for the inspiration that helped lead to this development.
The concept was then developed further into this multi-session implementation with:
• Two independent MAIN selections
• Two independent 90-minute zones
• Optional None settings
• CE levels
• Session-specific ORB calculations
• Breakout alerts
• Flexible combinations of higher and lower session structures
Credit and appreciation to @Eskemo_Bob for the inspiration.

[b]DEVELOPMENT[/b]
This indicator was developed by A3rl, with ChatGPT used as an AI development assistant during the design and refinement process.
The development process included discussing the underlying concept, refining the session logic, testing different configurations, simplifying the visual presentation, and working through Pine Script implementation details.
The final trading methodology, configuration choices, testing observations, and decisions regarding how the indicator should be used remain the author's own.

[i][b]IMPORTANT[/b][/i]
This indicator is provided for educational and informational purposes only.
It does not provide investment, financial, trading, or personalized investment advice.
The levels displayed by this indicator are mathematical and session-based reference levels. They should not be interpreted as guaranteed support, resistance, entry points, exit points, targets, or predictions of future price movement.
The presence of a breakout, retest, CE interaction, BOS/MSS-type structure, or any other condition does not guarantee a particular market outcome.
Past performance and historical observations do not guarantee future results.
Trading futures, forex, CFDs, cryptocurrencies, and other leveraged financial instruments involves substantial risk and may result in significant losses.
Always consider your own financial situation, experience, risk tolerance, and risk-management process before making any trading decision.
You are solely responsible for your own trading and investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https\://mozilla.org/MPL/2.0/

// © A3rl



//@version=6

indicator('AE_Multi Range 90m', overlay = true)



//====================================================

// INPUTS

//====================================================



inputMax = input.int(360, title = 'ORB timeframe limit (minutes)')

showCE = input.bool(true, title = 'Show CE Levels')



//====================================================

//====================================================
// MAIN 6H SELECTORS
//====================================================

//------------------------------
// MAIN 1
//------------------------------

mainZone1 = input.string(
    'Sydney',
    title = 'MAIN1',
    options = [
        'None',
        'Sydney',
        'Tokyo',
        'London'
    ])

//------------------------------
// MAIN 2
//------------------------------

mainZone2 = input.string(
    'None',
    title = 'MAIN2',
    options = [
        'None',
        'Sydney',
        'Tokyo',
        'London'
    ])

//====================================================
// TIMEZONE
//====================================================

// Exact timezone requested: UTC-4
string tz = 'Etc/GMT+4'

//====================================================
// MAIN 6H DEFINITIONS
//====================================================

// Sydney
string mainSydneyORB  = '1700-0000'
string mainSydneySess = '1700-0600'

// Tokyo
string mainTokyoORB  = '0000-0600'
string mainTokyoSess = '0000-1200'

// London
string mainLondonORB  = '0600-1200'
string mainLondonSess = '0600-1645'

//====================================================
// MAIN1 SELECTED SESSION
//====================================================

main1Enabled = mainZone1 != 'None'

main1ORBTime = switch mainZone1
    'Sydney' => mainSydneyORB
    'Tokyo'  => mainTokyoORB
    'London' => mainLondonORB
    => ''

main1SessionTime = switch mainZone1
    'Sydney' => mainSydneySess
    'Tokyo'  => mainTokyoSess
    'London' => mainLondonSess
    => ''

//====================================================
// MAIN1 TIME CHECKS
//====================================================

t_main1ORB = main1Enabled ? time(
    timeframe.period,
    main1ORBTime + ':1234567',
    tz) : na

t_main1Session = main1Enabled ? time(
    timeframe.period,
    main1SessionTime + ':1234567',
    tz) : na

main1InORB = main1Enabled and not na(t_main1ORB)
main1InSession = main1Enabled and not na(t_main1Session)

main1FirstORB = main1InORB and not main1InORB[1]

//====================================================
// MAIN1 ORB LEVELS
//====================================================

var float main1High = na
var float main1Low = na

if main1FirstORB
    main1High := high
    main1Low := low
else
    main1High := main1High[1]
    main1Low := main1Low[1]

if high > main1High and main1InORB
    main1High := high

if low < main1Low and main1InORB
    main1Low := low

main1CE = (main1High + main1Low) / 2

//====================================================
// MAIN2 SELECTED SESSION
//====================================================

main2Enabled = mainZone2 != 'None'

main2ORBTime = switch mainZone2
    'Sydney' => mainSydneyORB
    'Tokyo'  => mainTokyoORB
    'London' => mainLondonORB
    => ''

main2SessionTime = switch mainZone2
    'Sydney' => mainSydneySess
    'Tokyo'  => mainTokyoSess
    'London' => mainLondonSess
    => ''

//====================================================
// MAIN2 TIME CHECKS
//====================================================

t_main2ORB = main2Enabled ? time(
    timeframe.period,
    main2ORBTime + ':1234567',
    tz) : na

t_main2Session = main2Enabled ? time(
    timeframe.period,
    main2SessionTime + ':1234567',
    tz) : na

main2InORB = main2Enabled and not na(t_main2ORB)
main2InSession = main2Enabled and not na(t_main2Session)

main2FirstORB = main2InORB and not main2InORB[1]

//====================================================
// MAIN2 ORB LEVELS
//====================================================

var float main2High = na
var float main2Low = na

if main2FirstORB
    main2High := high
    main2Low := low
else
    main2High := main2High[1]
    main2Low := main2Low[1]

if high > main2High and main2InORB
    main2High := high

if low < main2Low and main2InORB
    main2Low := low

main2CE = (main2High + main2Low) / 2

//====================================================

// ACTIVE 90M ZONE 1

//====================================================



activeZone1 = input.string(

     'None',

     title = 'Active Zone 1',

     options = [

         'None',



         'Sydney 90_1',

         'Tokyo 90_1',

         'London 90_1',

         'New York 90_1',



         'Sydney 90_2',

         'Tokyo 90_2',

         'London 90_2',

         'New York 90_2',



         'Sydney 90_3',

         'Tokyo 90_3',

         'London 90_3',

         'New York 90_3'

     ])



//====================================================

// ACTIVE 90M ZONE 2

//====================================================



activeZone2 = input.string(

     'Sydney 90_1',

     title = 'Active Zone 2',

     options = [

        'None',



         'Sydney 90_1',

         'Tokyo 90_1',

         'London 90_1',

         'New York 90_1',



         'Sydney 90_2',

         'Tokyo 90_2',

         'London 90_2',

         'New York 90_2',



         'Sydney 90_3',

         'Tokyo 90_3',

         'London 90_3',

         'New York 90_3'

     ])



//====================================================

// 90M SESSION DEFINITIONS

//====================================================



//----------------------------------------------------

// 90_1

//----------------------------------------------------



string s90_1_ORB  = '1700-1930'

string s90_1_Sess = '1700-2100'



string t90_1_ORB  = '1930-2100'

string t90_1_Sess = '1930-2230'



string l90_1_ORB  = '2100-2230'

string l90_1_Sess = '2100-0000'



string n90_1_ORB  = '2230-0000'

string n90_1_Sess = '2230-0130'



//----------------------------------------------------

// 90_2

//----------------------------------------------------



string s90_2_ORB  = '0000-0130'

string s90_2_Sess = '0000-0300'



string t90_2_ORB  = '0130-0300'

string t90_2_Sess = '0130-0430'



string l90_2_ORB  = '0300-0430'

string l90_2_Sess = '0300-0600'



string n90_2_ORB  = '0430-0600'

string n90_2_Sess = '0430-0730'



//----------------------------------------------------

// 90_3

//----------------------------------------------------



string s90_3_ORB  = '0600-0730'

string s90_3_Sess = '0600-0900'



string t90_3_ORB  = '0730-0900'

string t90_3_Sess = '0730-1030'



string l90_3_ORB  = '0900-1030'

string l90_3_Sess = '0900-1200'



string n90_3_ORB  = '1030-1200'

string n90_3_Sess = '1030-1645'



//====================================================

// FUNCTION — 90M ORB

//====================================================



get90ORB(string zone) =>

    switch zone

        'Sydney 90_1'   => s90_1_ORB

        'Tokyo 90_1'    => t90_1_ORB

        'London 90_1'   => l90_1_ORB

        'New York 90_1' => n90_1_ORB



        'Sydney 90_2'   => s90_2_ORB

        'Tokyo 90_2'    => t90_2_ORB

        'London 90_2'   => l90_2_ORB

        'New York 90_2' => n90_2_ORB



        'Sydney 90_3'   => s90_3_ORB

        'Tokyo 90_3'    => t90_3_ORB

        'London 90_3'   => l90_3_ORB

        'New York 90_3' => n90_3_ORB



        => ''



//====================================================

// FUNCTION — 90M SESSION

//====================================================



get90Session(string zone) =>

    switch zone

        'Sydney 90_1'   => s90_1_Sess

        'Tokyo 90_1'    => t90_1_Sess

        'London 90_1'   => l90_1_Sess

        'New York 90_1' => n90_1_Sess



        'Sydney 90_2'   => s90_2_Sess

        'Tokyo 90_2'    => t90_2_Sess

        'London 90_2'   => l90_2_Sess

        'New York 90_2' => n90_2_Sess



        'Sydney 90_3'   => s90_3_Sess

        'Tokyo 90_3'    => t90_3_Sess

        'London 90_3'   => l90_3_Sess

        'New York 90_3' => n90_3_Sess



        => ''



//====================================================

// ACTIVE ZONE 1 — TIME

//====================================================



zone1Enabled = activeZone1 != 'None'



zone1ORBTime = get90ORB(activeZone1)

zone1SessionTime = get90Session(activeZone1)



t_zone1ORB = zone1Enabled ? time(

     timeframe.period,

     zone1ORBTime + ':1234567',

     tz) : na



t_zone1Session = zone1Enabled ? time(

     timeframe.period,

     zone1SessionTime + ':1234567',

     tz) : na



zone1InORB = zone1Enabled and not na(t_zone1ORB)

zone1InSession = zone1Enabled and not na(t_zone1Session)



zone1FirstORB = zone1InORB and not zone1InORB[1]



//====================================================

// ACTIVE ZONE 2 — TIME

//====================================================



zone2Enabled = activeZone2 != 'None'



zone2ORBTime = get90ORB(activeZone2)

zone2SessionTime = get90Session(activeZone2)



t_zone2ORB = zone2Enabled ? time(

     timeframe.period,

     zone2ORBTime + ':1234567',

     tz) : na



t_zone2Session = zone2Enabled ? time(

     timeframe.period,

     zone2SessionTime + ':1234567',

     tz) : na



zone2InORB = zone2Enabled and not na(t_zone2ORB)

zone2InSession = zone2Enabled and not na(t_zone2Session)



zone2FirstORB = zone2InORB and not zone2InORB[1]



//====================================================

// ACTIVE ZONE 1 — ORB

//====================================================



var float zone1High = na

var float zone1Low = na



if zone1FirstORB

    zone1High := high

    zone1Low := low

else

    zone1High := zone1High[1]

    zone1Low := zone1Low[1]



if high > zone1High and zone1InORB

    zone1High := high



if low < zone1Low and zone1InORB

    zone1Low := low



zone1CE = (zone1High + zone1Low) / 2



//====================================================

// ACTIVE ZONE 2 — ORB

//====================================================



var float zone2High = na

var float zone2Low = na



if zone2FirstORB

    zone2High := high

    zone2Low := low

else

    zone2High := zone2High[1]

    zone2Low := zone2Low[1]



if high > zone2High and zone2InORB

    zone2High := high



if low < zone2Low and zone2InORB

    zone2Low := low



zone2CE = (zone2High + zone2Low) / 2



//====================================================

// TIMEFRAME FILTER

//====================================================



hide = timeframe.isintraday and timeframe.multiplier <= inputMax



//====================================================

//====================================================
// MAIN1 PLOTS
//====================================================

plot(
    hide and main1InSession ? main1High : na,
    style = plot.style_cross,
    color = main1High[1] != main1High ? na : color.rgb(255, 205, 153),
    title = 'MAIN1 ORB High',
    linewidth = 2)

plot(
    hide and main1InSession ? main1Low : na,
    style = plot.style_cross,
    color = main1Low[1] != main1Low ? na : color.rgb(204, 153, 0),
    title = 'MAIN1 ORB Low',
    linewidth = 2)

plot(
    hide and main1InSession and not main1InORB and showCE ? main1CE : na,
    style = plot.style_cross,
    color = color.rgb(255, 204, 102),
    title = 'MAIN1 ORB CE',
    linewidth = 2)

//====================================================
// MAIN2 PLOTS
//====================================================

plot(
    hide and main2InSession ? main2High : na,
    style = plot.style_cross,
    color = main2High[1] != main2High ? na : color.rgb(153, 204, 255),
    title = 'MAIN2 ORB High',
    linewidth = 2)

plot(
    hide and main2InSession ? main2Low : na,
    style = plot.style_cross,
    color = main2Low[1] != main2Low ? na : color.rgb(51, 102, 153),
    title = 'MAIN2 ORB Low',
    linewidth = 2)

plot(
    hide and main2InSession and not main2InORB and showCE ? main2CE : na,
    style = plot.style_cross,
    color = color.rgb(102, 204, 255),
    title = 'MAIN2 ORB CE',
    linewidth = 2)

//====================================================

// ACTIVE ZONE 1 PLOTS

//====================================================



plot(

     hide and zone1InSession ? zone1High : na,

     style = plot.style_cross,

     color = zone1High[1] != zone1High ? na : color.rgb(255, 182, 193),

     title = 'Active Zone 1 High',

     linewidth = 2)



plot(

     hide and zone1InSession ? zone1Low : na,

     style = plot.style_cross,

     color = zone1Low[1] != zone1Low ? na : color.rgb(199, 21, 133),

     title = 'Active Zone 1 Low',

     linewidth = 2)



plot(

     hide and zone1InSession and not zone1InORB and showCE ? zone1CE : na,

     style = plot.style_cross,

     color = color.rgb(255, 153, 204),

     title = 'Active Zone 1 CE',

     linewidth = 2)



//====================================================

// ACTIVE ZONE 2 PLOTS

//====================================================



plot(

     hide and zone2InSession ? zone2High : na,

     style = plot.style_cross,

     color = zone2High[1] != zone2High ? na : color.rgb(173, 216, 230),

     title = 'Active Zone 2 High',

     linewidth = 2)



plot(

     hide and zone2InSession ? zone2Low : na,

     style = plot.style_cross,

     color = zone2Low[1] != zone2Low ? na : color.rgb(0, 0, 115),

     title = 'Active Zone 2 Low',

     linewidth = 2)



plot(

     hide and zone2InSession and not zone2InORB and showCE ? zone2CE : na,

     style = plot.style_cross,

     color = color.rgb(153, 204, 255),

     title = 'Active Zone 2 CE',

     linewidth = 2)



//====================================================

//====================================================
// ALERTS — MAIN1
//====================================================

alertcondition(
    ta.crossover(high, main1High) and
    main1InSession and
    not main1InORB,
    title = 'MAIN1 ORB High Break',
    message = 'Price crossed above MAIN1 ORB High: {{ticker}} at {{close}}')

alertcondition(
    ta.crossunder(low, main1Low) and
    main1InSession and
    not main1InORB,
    title = 'MAIN1 ORB Low Break',
    message = 'Price crossed below MAIN1 ORB Low: {{ticker}} at {{close}}')

//====================================================
// ALERTS — MAIN2
//====================================================

alertcondition(
    ta.crossover(high, main2High) and
    main2InSession and
    not main2InORB,
    title = 'MAIN2 ORB High Break',
    message = 'Price crossed above MAIN2 ORB High: {{ticker}} at {{close}}')

alertcondition(
    ta.crossunder(low, main2Low) and
    main2InSession and
    not main2InORB,
    title = 'MAIN2 ORB Low Break',
    message = 'Price crossed below MAIN2 ORB Low: {{ticker}} at {{close}}')

//====================================================

// ALERTS — ACTIVE ZONE 1

//====================================================



alertcondition(

     ta.crossover(high, zone1High) and

     zone1InSession and

     not zone1InORB,

     title = 'Active Zone 1 High Break',

     message = 'Price crossed above Active Zone 1 ORB High: {{ticker}} at {{close}}')



alertcondition(

     ta.crossunder(low, zone1Low) and

     zone1InSession and

     not zone1InORB,

     title = 'Active Zone 1 Low Break',

     message = 'Price crossed below Active Zone 1 ORB Low: {{ticker}} at {{close}}')



//====================================================

// ALERTS — ACTIVE ZONE 2

//====================================================



alertcondition(

     ta.crossover(high, zone2High) and

     zone2InSession and

     not zone2InORB,

     title = 'Active Zone 2 High Break',

     message = 'Price crossed above Active Zone 2 ORB High: {{ticker}} at {{close}}')



alertcondition(

     ta.crossunder(low, zone2Low) and

     zone2InSession and

     not zone2InORB,

     title = 'Active Zone 2 Low Break',

     message = 'Price crossed below Active Zone 2 ORB Low: {{ticker}} at {{close}}')
````
