<!-- tradingview-pine-id: PUB;4d443adb72e74b9f8e63f44a6ee81e5b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Initial Balance Auction Intelligence by DGT

Source: https://www.tradingview.com/script/ks2QGulb-Initial-Balance-Auction-Intelligence-by-DGT/

## Description

Initial Balance Auction Intelligence (ɪʙAUC) - Market State Engine

ɪʙAUC is an Auction Market Theory framework that tracks how price develops after the Initial Balance (IB), rather than treating it as static support/resistance. Using configurable post-IB auction windows, it identifies:

Acceptance · Failed Auction · Retest / Continuation · Rejection · Two-Sided Auction

combining price location, extension relative to IB width, close strength, and retest behavior - producing Regime, Bias, Phase, Auction State, cumulative Pressure, Quality, Maturity, and Invalidation levels, with an optional dashboard and alerts on confirmed transitions.[image]https://www.tradingview.com/x/hKYa44mS/[/image]

Initial Balance & Auction States

The Initial Balance (IB) is the range established during the selected opening session, with IBH / IBL as boundaries and IBM as midpoint. Session and timezone are configurable (chart Exchange timezone or a range of predefined markets), allowing the framework to adapt to different markets and sessions.

Once the IB completes, ɪʙAUC evaluates each subsequent auction window (5/10/15/30 min, configurable) against it:

* PROBING ABOVE/BELOW - live, tentative; price beyond a boundary while the window is still forming
* ACCEPTED ABOVE/BELOW - a completed window closes outside the IB
* FAILED ABOVE/BELOW - price extends beyond a boundary but closes back inside
* CONTINUATION - after acceptance, a retest of that boundary holds
* REJECTION - after acceptance, a retest fails and price moves back through it
* TWO-SIDED AUCTION - both IB extremes tested and rejected - a more rotational, conflicted read

Only completed windows confirm a state transition; probing states are live/developing information.[image]https://www.tradingview.com/x/drdJYy8J/[/image][image]https://www.tradingview.com/x/v5bImFtu/[/image]

Visuals: Decision Candles & Projections

Decision Candles (optional) visualize the developing auction window's High/Low and Open/Close, highlighted when the window interacts with IBH or IBL - live information until the window completes.[image]https://www.tradingview.com/x/IkbkONdn/[/image]

Initial Balance Projections (optional) extend reference levels above IBH and below IBL at 0.5×, 1.0×, and 1.5× the IB range. These are reference levels for evaluating potential range extension - not predicted or guaranteed targets.[image]https://www.tradingview.com/x/KxegeHBY/[/image]

Metrics & Dashboard

Conviction/Quality combines close strength, IB-relative extension, and retest behavior to grade confirmed events - Acceptance/Continuation use acceptance criteria, while Failed/Rejection/Two-Sided use failure criteria. Maturity tracks how long a state has held (Early → Developing → Mature → Exhausted).

Pressure is a bounded −100..+100 reading, accumulated across the whole session from confirmed transitions. Bias reflects only the current event. These are deliberately different questions and can disagree - Pressure is not order-flow, volume, or a probability.

Regime (session character: Balanced / Rotational / Expansion / Failed Expansion / Trend Auction) and Phase (lifecycle stage: Balance → Probe → Acceptance → Retest → Expansion/Rotation → Exhaustion) provide higher-level context on top of the raw auction state.

The optional dashboard shows Regime, Bias, Phase, Auction State, Pressure, Quality, and Next (the next structural event or retest level plus its invalidation price), each with a contextual tooltip.[image]https://www.tradingview.com/x/5eA9jVPO/[/image]

How to Read It

ɪʙAUC is a contextual framework, not a standalone signal. Read Regime, Bias, Phase, Pressure, Quality, and Invalidation together - acceptance can support continuation, failed auctions can signal reversion toward balance, and two-sided auctions can favor rotation.

Alerts fire on confirmed transitions (Accepted/Failed Above/Below, Two-Sided, Continuation, Rejection) and include the relevant level, instrument, and IB session context.

Important Notes

[*] Designed for intraday timeframes ≤ 30 minutes; the engine operates only when this condition is met.
[*] Session and timezone should match the market being analyzed.
[*] Uses 1-minute lower-timeframe data on higher intraday charts for precise auction-window construction.
[*] Live probes/Decision Candles are developing information; state transitions confirm only when the selected auction window completes.

DISCLAIMER

This script is intended for informational and educational purposes only. It does not constitute financial, investment, or trading advice. All trading decisions made based on its output are solely the responsibility of the user.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
//# *
//# * Study       : Initial Balance Auction Intelligence
//# * Author      : © dgtrd
//# *
//# * Revision History
//# * Release    : Aug 23, 2026 : Initial Version
//# *
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //

indicator('Initial Balance Auction Intelligence by DGT', 'ɪʙAUC ☼☾', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

enum utcOffsets
    EXCHANGE = 'Exchange'

    UTCm5_New_York = 'America/New_York'
    UTC0_London = 'Europe/London'
    UTCp9_Tokyo = 'Asia/Tokyo'
    UTCp10_Sydney = 'Australia/Sydney'
    UTCp4_Dubai = 'Asia/Dubai'
    UTCp1_Berlin = 'Europe/Berlin'
    UTCp1_Paris = 'Europe/Paris'
    UTCp3_Istanbul = 'Europe/Istanbul'
    UTCm6_Chicago = 'America/Chicago'
    UTCm8_Los_Angeles = 'America/Los_Angeles'
    UTCp8_Singapore = 'Asia/Singapore'
    UTCp8_Shanghai = 'Asia/Shanghai'
    UTCp9_Seoul = 'Asia/Seoul'
    UTCp5p30_Kolkata = 'Asia/Kolkata'

    UTCm5_Toronto = 'America/Toronto'
    UTCm8_Vancouver = 'America/Vancouver'
    UTCm8_Tijuana = 'America/Tijuana'
    UTCm7_Denver = 'America/Denver'
    UTCm7_Edmonton = 'America/Edmonton'
    UTCm7_Ciudad_Juarez = 'America/Ciudad_Juarez'
    UTCm6_Mexico_City = 'America/Mexico_City'
    UTCm6_Winnipeg = 'America/Winnipeg'
    UTCm6_Costa_Rica = 'America/Costa_Rica'
    UTCm5_Lima = 'America/Lima'
    UTCm5_Bogota = 'America/Bogota'
    UTCm5_Jamaica = 'America/Jamaica'
    UTCm4p30_Caracas = 'America/Caracas'
    UTCm4_Santiago = 'America/Santiago'
    UTCm4_Manaus = 'America/Manaus'
    UTCm4_La_Paz = 'America/La_Paz'
    UTCm4_Santo_Domingo = 'America/Santo_Domingo'
    UTCm3p30_St_Johns = 'America/St_Johns'
    UTCm3_Sao_Paulo = 'America/Sao_Paulo'
    UTCm3_Buenos_Aires = 'America/Argentina/Buenos_Aires'
    UTCm3_Montevideo = 'America/Montevideo'
    UTCm9_Anchorage = 'America/Anchorage'
    UTCm10_Honolulu = 'Pacific/Honolulu'
    UTCm11_Pago_Pago = 'Pacific/Pago_Pago'

    UTC0_Lisbon = 'Europe/Lisbon'
    UTCp1_Madrid = 'Europe/Madrid'
    UTCp1_Warsaw = 'Europe/Warsaw'
    UTCp2_Kyiv = 'Europe/Kyiv'
    UTCp2_Athens = 'Europe/Athens'
    UTCp3_Moscow = 'Europe/Moscow'
    UTCp4_Samara = 'Europe/Samara'

    UTCp3_Riyadh = 'Asia/Riyadh'
    UTCp3_Baghdad = 'Asia/Baghdad'
    UTCp3p30_Tehran = 'Asia/Tehran'
    UTCp4_Baku = 'Asia/Baku'
    UTCp4_Yerevan = 'Asia/Yerevan'
    UTCp4p30_Kabul = 'Asia/Kabul'
    UTCp2_Jerusalem = 'Asia/Jerusalem'

    UTCp5_Karachi = 'Asia/Karachi'
    UTCp5_Tashkent = 'Asia/Tashkent'
    UTCp5_Yekaterinburg = 'Asia/Yekaterinburg'
    UTCp5p30_Colombo = 'Asia/Colombo'
    UTCp5p45_Kathmandu = 'Asia/Kathmandu'
    UTCp6_Dhaka = 'Asia/Dhaka'
    UTCp6_Almaty = 'Asia/Almaty'
    UTCp6_Omsk = 'Asia/Omsk'
    UTCp6p30_Yangon = 'Asia/Yangon'
    UTCp7_Jakarta = 'Asia/Jakarta'
    UTCp7_Bangkok = 'Asia/Bangkok'
    UTCp7_Krasnoyarsk = 'Asia/Krasnoyarsk'
    UTCp8_Taipei = 'Asia/Taipei'
    UTCp8_Kuala_Lumpur = 'Asia/Kuala_Lumpur'
    UTCp8_Manila = 'Asia/Manila'
    UTCp9_Pyongyang = 'Asia/Pyongyang'
    UTCp9_Yakutsk = 'Asia/Yakutsk'
    UTCp10_Vladivostok = 'Asia/Vladivostok'
    UTCp11_Magadan = 'Asia/Magadan'
    UTCp12_Kamchatka = 'Asia/Kamchatka'

    UTCp9p30_Adelaide = 'Australia/Adelaide'
    UTCp8_Perth = 'Australia/Perth'
    UTCp10_Port_Moresby = 'Pacific/Port_Moresby'
    UTCp11_Noumea = 'Pacific/Noumea'
    UTCp12_Auckland = 'Pacific/Auckland'
    UTCp12_Fiji = 'Pacific/Fiji'
    UTCp13_Tongatapu = 'Pacific/Tongatapu'
    UTCp14_Kiritimati = 'Pacific/Kiritimati'

    UTC0_Accra = 'Africa/Accra'
    UTC0_Casablanca = 'Africa/Casablanca'
    UTCp1_Lagos = 'Africa/Lagos'
    UTCp1_Algiers = 'Africa/Algiers'
    UTCp2_Cairo = 'Africa/Cairo'
    UTCp2_Johannesburg = 'Africa/Johannesburg'
    UTCp3_Addis_Ababa = 'Africa/Addis_Ababa'



//---------------------------------------------------------------------------------------------------------------------//
// SETTINGS

display = display.all - display.status_line

ibGroup = 'Initial Balance'
aiGroup = 'Auction Intelligence'

ibRange = input.session('0930-1030', 'Initial Balance Session', inline = 'inline', group = ibGroup, display = display,
     tooltip = 'The opening range window that defines the Initial Balance, in the timezone set below.')
sessionTimezoneInput = input.enum(utcOffsets.UTCm5_New_York, '  Session Timezone', group = ibGroup, display = display,
     tooltip = 'Timezone the session above is defined in. Must match the market/session you\'re actually tracking - changing the session hours without also changing this can silently track the wrong window. "Exchange" uses the chart symbol\'s own exchange timezone instead of a fixed one.')
sessionTimezone = sessionTimezoneInput == utcOffsets.EXCHANGE ? syminfo.timezone : str.tostring(sessionTimezoneInput)

ibColor = input.color(#2962ff, 'Initial Balance Lines Color', group = ibGroup)
showMidlineT = input.string('On', 'Initial Balance Midpoint', options = ['On', 'Off'], inline = 'IBM', group = ibGroup, display = display), showMidline = showMidlineT == 'On'

ibmColor = input.color(color.new(color.gray, 25), '', inline = 'IBM', group = ibGroup)

showDashboard = input.bool(true, 'Auction Intelligence Dashboard', inline = 'DB1', group = aiGroup)
dashboardSize = input.string('Small', '',
     options = ['Tiny', 'Small', 'Normal'], group = aiGroup, inline = 'DB1',  display = display)

panelTextSize = dashboardSize == 'Small' ? size.small : dashboardSize == 'Tiny' ? size.tiny : size.normal

auctionWindowStr = input.string('30', 'Auction Window (minutes)', options = ['5', '10', '15', '30'], group = aiGroup, display = display,
     tooltip = 'Length of each post-IB auction window evaluated by the state machine. 30 minutes is the default and provides a practical balance between responsiveness and confirmation. IB completion is determined by the Initial Balance Session above.')


showDecisionCandlesT = input.string('Off', '  Auction Decision Candles', options = ['On', 'Off'], inline = 'AC', group = aiGroup, display = display,
     tooltip = 'Highlights auction windows where price interacts with the Initial Balance and shows a directional response'), showDecisionCandles = showDecisionCandlesT == 'On'
decisionBullColor = input.color(color.teal, '', inline = 'AC', group = aiGroup)
decisionBearColor = input.color(color.red, '', inline = 'AC', group = aiGroup)

showProjectionsT = input.string('Off', '  Initial Balance Projections', inline = 'IBP', options = ['On', 'Off'], group = ibGroup, display = display,
     tooltip = 'Once the Initial Balance completes, projects reference levels at 0.5x, 1x, and 1.5x the IB range above IBH and below IBL - a classic look-ahead reference for potential range extension, not a predicted or guaranteed target.'), showProjections = showProjectionsT == 'On'
ibmPColor = input.color(color.new(color.orange, 69), '', inline = 'IBP', group = ibGroup)



//showPreviousIB = input.bool(true, 'Show Previous Session IB', group = ibGroup,
//     tooltip = 'Draws yesterday\'s IBH/IBL as a faint reference for today - whether today\'s IB forms inside or outside the prior one is a classic read on balance vs. trend days.')
//showIBFormingTint = input.bool(false, 'Highlight IB Forming Window', group = ibGroup,
//     tooltip = 'Very light background tint while the IB is still forming (before it locks in), distinct from having to read AUCTION on the dashboard.')



ibWidthLookback = 20//input.int(20, '  IB Width Lookback (sessions)', minval = 5, maxval = 100, group = aiGroup, display = display,
     //tooltip = 'How many past sessions to compare today\'s IB width against for the percentile shown on the dashboard.')

//---------------------------------------------------------------------------------------------------------------------//
// FUNCTIONS


f_lowerTfRange() =>
    o = float(na)
    h = float(na)
    l = float(na)
    c = float(na)
    if timeframe.in_seconds() <= 60
        o := open
        h := high
        l := low
        c := close
    else
        [aO, aH, aL, aC] = request.security_lower_tf(syminfo.tickerid, '1', [open, high, low, close])
        if aH.size() > 0
            o := aO.get(0)
            h := aH.max()
            l := aL.min()
            c := aC.get(aC.size() - 1)
    [o, h, l, c]

f_closeStrength(o, h, l, c) =>
    rng = h - l
    rng > 0 ? (c - l) / rng * 100 : 50.0

f_percentileRank(arr, val) =>
    n = arr.size()
    result = 50.0
    if n > 0
        count = 0
        for i = 0 to n - 1
            if arr.get(i) <= val
                count += 1
        result := count * 100.0 / n
    result

f_regime(state, failedAbove, failedBelow) =>
    string result = switch
        state == "Continuation"     => "Trend Auction"
        state == "Rejection"        => "Failed Expansion"
        state == "Accepted Above"   => "Expansion"
        state == "Accepted Below"   => "Expansion"
        state == "Two-Sided Auction" => "Rotational"
        failedAbove and failedBelow => "Rotational"
        state == "Failed Above"     => "Rotational"
        state == "Failed Below"     => "Rotational"
        => "Balanced"
    result

f_bias(state, side) =>
    string result = switch state
        "Accepted Above"   => "Bullish"
        "Accepted Below"   => "Bearish"
        "Failed Above"     => "Bearish Pressure"
        "Failed Below"     => "Bullish Pressure"
        "Two-Sided Auction" => "Conflicted"
        "Continuation"     => side == "above" ? "Bullish" : "Bearish"
        "Rejection"        => side == "above" ? "Bearish" : "Bullish"
        => "Balanced"
    result

f_phase(state, isLiveRetesting, hadContinuation) =>
    string result = switch
        isLiveRetesting             => "Retest"
        state == "Building IB"      => "Balance"
        state == "Balanced"         => "Balance"
        state == "Two-Sided Auction" => "Rotation"
        state == "Probing Above"    => "Probe"
        state == "Probing Below"    => "Probe"
        state == "Failed Above"     => "Probe"
        state == "Failed Below"     => "Probe"
        state == "Accepted Above"   => "Acceptance"
        state == "Accepted Below"   => "Acceptance"
        state == "Continuation"     => "Expansion"
        state == "Rejection" and hadContinuation => "Exhaustion"
        state == "Rejection"        => "Retest"
        => "Balance"
    result

f_maturity(candles) =>
    string result = switch
        candles <= 1 => "Early"
        candles <= 3 => "Developing"
        candles <= 6 => "Mature"
        => "Exhausted"
    result

f_acceptanceQuality(conviction, candles) =>
    string result = "-"
    if not na(conviction)
        score = conviction + math.min(candles * 5, 20)
        if candles <= 1
            result := switch
                score < 40 => "Weak"
                score < 65 => "Developing"
                => "Established"
        else
            result := switch
                score < 40 => "Weak"
                score < 65 => "Developing"
                score < 85 => "Established"
                => "Strong"
    result

f_failureQuality(excursionRatio) =>
    string result = "-"
    if not na(excursionRatio)
        result := switch
            excursionRatio < 0.3 => "Weak"
            excursionRatio < 0.7 => "Moderate"
            excursionRatio < 1.2 => "High"
            => "Violent"
    result

f_qualityLabel(state, acceptQ, failQ) =>
    string result = switch
        state == "Accepted Above"   => acceptQ
        state == "Accepted Below"   => acceptQ
        state == "Continuation"     => acceptQ
        state == "Failed Above"     => failQ
        state == "Failed Below"     => failQ
        state == "Two-Sided Auction" => failQ
        state == "Rejection"        => failQ
        => "-"
    result

f_pressureLabel(val) =>
    string result = switch
        val > 10  => "BUY " + str.tostring(math.round(val))
        val < -10 => "SELL " + str.tostring(math.round(math.abs(val)))
        => "NEUTRAL"
    result

f_invalidation(state, side) =>
    string result = switch state
        "Accepted Above"   => "<IBH"
        "Accepted Below"   => ">IBL"
        "Continuation"     => side == "above" ? "<IBH" : ">IBL"
        "Rejection"        => side == "above" ? ">IBH" : "<IBL"
        "Failed Above"     => ">IBH"
        "Failed Below"     => "<IBL"
        "Two-Sided Auction" => "accept either side"
        => "-"
    result

f_narrative(state, side) =>
    string result = switch state
        "Building IB"      => "Initial Balance still forming."
        "Balanced"         => "Price trading within the Initial Balance."
        "Probing Above"    => "Price trading above IBH, awaiting the completed auction window close to confirm."
        "Probing Below"    => "Price trading below IBL, awaiting the completed auction window close to confirm."
        "Accepted Above"   => "Price closed above IBH. Auction now above the Initial Balance."
        "Accepted Below"   => "Price closed below IBL. Auction now below the Initial Balance."
        "Failed Above"     => "Price probed above IBH but returned inside the IB. Acceptance not established."
        "Failed Below"     => "Price probed below IBL but returned inside the IB. Acceptance not established."
        "Continuation"     => side == "above" ? "Retest of IBH held. Auction continuing higher." : "Retest of IBL held. Auction continuing lower."
        "Rejection"        => side == "above" ? "Retest of IBH failed; price reclaimed the Initial Balance." : "Retest of IBL failed; price reclaimed the Initial Balance."
        "Two-Sided Auction" => "Both IB extremes tested without sustained acceptance. Market remains rotational."
        => ""
    result


timeframeOK = timeframe.isintraday and timeframe.in_seconds() <= 30 * 60

//---------------------------------------------------------------------------------------------------------------------//
// SESSION ENGINE + INITIAL BALANCE


var line lnHigh = na, var line lnLow = na, var line lnHighExt = na, var line lnLowExt = na
var line lnMid = na, var line lnMidExt = na
var label lblHigh = na, var label lblLow = na, var label lblMid = na
var line lnPrevHigh = na, var line lnPrevLow = na
var float prevIBHigh = na, var float prevIBLow = na
var float balanceHigh = na
var float balanceLow  = na
var int   balanceTime = na
//var array<float> ibWidths = array.new<float>()
naColor = #00000000
var box decisionHL = na
var box decisionOC = na
var line lnProjUp1 = na, var line lnProjUp2 = na, var line lnProjUp3 = na
var line lnProjDn1 = na, var line lnProjDn2 = na, var line lnProjDn3 = na

session      = not na(time(timeframe.period, ibRange, sessionTimezone))
sessionStart = session and session != session[1]

if sessionStart and timeframeOK
    if not na(balanceHigh) and not na(balanceLow)
        //ibWidths.push(balanceHigh - balanceLow)
        //if ibWidths.size() > ibWidthLookback
        //    ibWidths.shift()
        prevIBHigh := balanceHigh
        prevIBLow  := balanceLow

    //if not showPreviousIB
    //    lnHigh.delete()
    //    lnHighExt.delete()
    //    lnLow.delete()
    //    lnLowExt.delete()

    if not na(lnProjUp1)
        line.delete(lnProjUp1)
    if not na(lnProjUp2)
        line.delete(lnProjUp2)
    if not na(lnProjUp3)
        line.delete(lnProjUp3)
    if not na(lnProjDn1)
        line.delete(lnProjDn1)
    if not na(lnProjDn2)
        line.delete(lnProjDn2)
    if not na(lnProjDn3)
        line.delete(lnProjDn3)
    lnProjUp1 := na
    lnProjUp2 := na
    lnProjUp3 := na
    lnProjDn1 := na
    lnProjDn2 := na
    lnProjDn3 := na

    balanceTime := time
    [_, ibHigh, ibLow, _] = f_lowerTfRange()
    balanceHigh := ibHigh
    balanceLow  := ibLow


    lnHigh    := line.new(time, ibHigh, time, ibHigh, xloc.bar_time, extend.none, ibColor, line.style_solid, 1)
    lnLow     := line.new(time, ibLow, time, ibLow, xloc.bar_time, extend.none, ibColor, line.style_solid, 1)
    lnHighExt := line.new(time, ibHigh, time, ibHigh, xloc.bar_time, extend.none, ibColor, line.style_dotted, 1)
    lnLowExt  := line.new(time, ibLow, time, ibLow, xloc.bar_time, extend.none, ibColor, line.style_dotted, 1)
    linefill.new(lnHigh, lnLow, color.new(ibColor, 89))

    lblHigh := label.new(time, ibHigh, 'IBH ' + str.tostring(ibHigh, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = naColor, textcolor = ibColor, size = size.small)
    lblLow  := label.new(time, ibLow, 'IBL ' + str.tostring(ibLow, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = naColor, textcolor = ibColor, size = size.small)

    if showMidline
        ibMid = (ibHigh + ibLow) / 2
        lnMid    := line.new(time, ibMid, time, ibMid, xloc.bar_time, extend.none, ibmColor, line.style_dashed, 1)
        lnMidExt := line.new(time, ibMid, time, ibMid, xloc.bar_time, extend.none, ibmColor, line.style_dashed, 1)
        lblMid   := label.new(time, ibMid, 'IBM ' + str.tostring(ibMid, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = naColor, textcolor = ibmColor, size = size.small)

    //if showPreviousIB and not na(prevIBHigh) and not na(prevIBLow)
    //    lnPrevHigh := line.new(time, prevIBHigh, time, prevIBHigh, xloc.bar_time, extend.none, color.new(color.purple, 55), line.style_dotted, 1)
    //    lnPrevLow  := line.new(time, prevIBLow, time, prevIBLow, xloc.bar_time, extend.none, color.new(color.purple, 55), line.style_dotted, 1)

if session and timeframeOK
    balanceHigh := math.max(high, balanceHigh)
    balanceLow  := math.min(low, balanceLow)
    balanceMid = (balanceHigh + balanceLow) / 2
    if not na(lnHigh)
        lnHigh.set_y1(balanceHigh), lnHigh.set_xy2(time, balanceHigh)
    if not na(lnHighExt)
        lnHighExt.set_y1(balanceHigh), lnHighExt.set_xy2(time, balanceHigh)
    if not na(lnLow)
        lnLow.set_y1(balanceLow), lnLow.set_xy2(time, balanceLow)
    if not na(lnLowExt)
        lnLowExt.set_y1(balanceLow), lnLowExt.set_xy2(time, balanceLow)
    if showMidline and not na(lnMid)
        lnMid.set_y1(balanceMid), lnMid.set_xy2(time, balanceMid)
        lnMidExt.set_y1(balanceMid), lnMidExt.set_xy2(time, balanceMid)
    if not na(lblHigh)
        lblHigh.set_xy(time, balanceHigh)
        lblHigh.set_text('IBH · ' + str.tostring(balanceHigh, format.mintick))
    if not na(lblLow)
        lblLow.set_xy(time, balanceLow)
        lblLow.set_text('IBL · ' + str.tostring(balanceLow, format.mintick))
    if showMidline and not na(lblMid)
        lblMid.set_xy(time, balanceMid)
        lblMid.set_text('IBM · ' + str.tostring(balanceMid, format.mintick))
else
    if not na(lnHighExt)
        lnHighExt.set_x2(time)
    if not na(lnLowExt)
        lnLowExt.set_x2(time)
    if not na(lnMidExt)
        lnMidExt.set_x2(time)
    if not na(lblMid)
        lblMid.set_x(time)
    if not na(lblHigh)
        lblHigh.set_x(time)
    if not na(lblLow)
        lblLow.set_x(time)

//if showPreviousIB and timeframeOK
//if  timeframeOK

//    if not na(lnPrevHigh)
//        lnPrevHigh.set_x2(time)
//    if not na(lnPrevLow)
//        lnPrevLow.set_x2(time)

//---------------------------------------------------------------------------------------------------------------------//
// AUCTION ENGINE

var float queryOpen  = na
var float queryHigh  = na
var float queryLow   = na
var float queryClose = na
var int   queryTime  = na

int queryLength = timeframe.in_seconds(auctionWindowStr) * 1000
queryChange = timeframe.change(auctionWindowStr)

if queryChange
    queryTime := time

var bool ibComplete = false
if sessionStart
    ibComplete := false
if session[1] and not session and timeframeOK
    ibComplete := true

if showProjections and ibComplete and not ibComplete[1]
    ibW = balanceHigh - balanceLow
    lnProjUp1 := line.new(time, balanceHigh + 0.5 * ibW, time + 1, balanceHigh + 0.5 * ibW, xloc.bar_time, extend.right, ibmPColor, line.style_dashed, 1)
    lnProjUp2 := line.new(time, balanceHigh + 1.0 * ibW, time + 1, balanceHigh + 1.0 * ibW, xloc.bar_time, extend.right, ibmPColor, line.style_dashed, 1)
    lnProjUp3 := line.new(time, balanceHigh + 1.5 * ibW, time + 1, balanceHigh + 1.5 * ibW, xloc.bar_time, extend.right, ibmPColor, line.style_dashed, 1)
    lnProjDn1 := line.new(time, balanceLow - 0.5 * ibW, time + 1, balanceLow - 0.5 * ibW, xloc.bar_time, extend.right, ibmPColor, line.style_dashed, 1)
    lnProjDn2 := line.new(time, balanceLow - 1.0 * ibW, time + 1, balanceLow - 1.0 * ibW, xloc.bar_time, extend.right, ibmPColor, line.style_dashed, 1)
    lnProjDn3 := line.new(time, balanceLow - 1.5 * ibW, time + 1, balanceLow - 1.5 * ibW, xloc.bar_time, extend.right, ibmPColor, line.style_dashed, 1)

//bgcolor(showIBFormingTint and session and not ibComplete ? color.new(ibColor, 94) : na, title = 'IB Forming')

if ibComplete and queryChange and timeframeOK
    [pro, prh, prl, prc] = f_lowerTfRange()
    queryOpen  := pro
    queryHigh  := prh
    queryLow   := prl
    queryClose := prc

    if showDecisionCandles and timeframe.in_seconds() <= 30 * 60
        //if not na(decisionHL)
        //    box.delete(decisionHL)
        //if not na(decisionOC)
        //    box.delete(decisionOC)

        decisionHL := box.new(
             time, prh, time, prl,
             border_color = na,
             border_width = 0,
             bgcolor = na,
             xloc = xloc.bar_time)

        decisionOC := box.new(
             time, math.max(pro, prc), time, math.min(pro, prc),
             border_color = na,
             border_width = 0,
             bgcolor = na,
             xloc = xloc.bar_time)

inCurrentQueryWindow = not na(queryTime) and time < queryTime + queryLength

if ibComplete and timeframe.isintraday and inCurrentQueryWindow
    queryHigh  := math.max(high, queryHigh)
    queryLow   := math.min(low, queryLow)
    queryClose := close

    if showDecisionCandles and not na(decisionHL) and not na(decisionOC)
        touchesIB = (queryHigh >= balanceHigh and queryLow <= balanceHigh) or (queryHigh >= balanceLow and queryLow <= balanceLow)

        decisionColor = queryOpen < queryClose ? decisionBullColor : decisionBearColor

        decisionHL.set_lefttop(queryTime, queryHigh)
        decisionHL.set_right(time)
        decisionHL.set_bottom(queryLow)
        decisionHL.set_bgcolor(touchesIB ? color.new(decisionColor, 81) : na)

        decisionOC.set_lefttop(queryTime, math.max(queryOpen, queryClose))
        decisionOC.set_right(time)
        decisionOC.set_bottom(math.min(queryOpen, queryClose))
        decisionOC.set_bgcolor(touchesIB ? color.new(decisionColor, 81) : na)

//---------------------------------------------------------------------------------------------------------------------//

failedAuctionBelow = (queryOpen[1] < balanceLow  or queryLow[1] < balanceLow) and queryClose[1] > balanceLow and queryClose[1] < balanceHigh
failedAuctionAbove = (queryOpen[1] > balanceHigh or queryHigh[1] > balanceHigh) and queryClose[1] > balanceLow and queryClose[1] < balanceHigh
bullAcceptance     = queryClose[1] > balanceHigh
bearAcceptance     = queryClose[1] < balanceLow

//---------------------------------------------------------------------------------------------------------------------//
// AUCTION STATE MACHINE

var string auctionState   = "Building IB"
var bool   failedAboveFlag = false
var bool   failedBelowFlag = false
var string acceptedSide    = "none"
var bool   awaitingRetest  = false
var float  retestLevel     = na
var float  convictionScore = na
var float  convAcceptPts   = na
var float  convExtendPts   = na
var float  convRetestPts   = na
var int    candlesInState  = 0
var bool   hadContinuationFlag = false
var float  lastAcceptExcursion = na
var float  lastFailExcursion   = na
var float  pressureAccum       = 0.0

var bool becameAcceptedAbove = false
var bool becameAcceptedBelow = false
var bool becameFailedAbove   = false
var bool becameFailedBelow   = false
var bool becameTwoSided      = false
var bool becameContinuation  = false
var bool becameRejection     = false

if sessionStart
    auctionState        := "Building IB"
    failedAboveFlag      := false
    failedBelowFlag      := false
    acceptedSide         := "none"
    awaitingRetest       := false
    retestLevel          := na
    convictionScore      := na
    convAcceptPts        := na
    convExtendPts        := na
    convRetestPts        := na
    candlesInState        := 0
    hadContinuationFlag   := false
    lastAcceptExcursion   := na
    lastFailExcursion     := na
    pressureAccum         := 0.0

if ibComplete and not ibComplete[1]
    auctionState := "Balanced"

becameAcceptedAbove := false
becameAcceptedBelow := false
becameFailedAbove    := false
becameFailedBelow    := false
becameTwoSided        := false
becameContinuation    := false
becameRejection        := false

stateAllowsLiveProbe = auctionState == "Balanced" or auctionState == "Two-Sided Auction" or auctionState == "Failed Above" or auctionState == "Failed Below"
if ibComplete and stateAllowsLiveProbe
    if high > balanceHigh
        auctionState := "Probing Above"
    else if low < balanceLow
        auctionState := "Probing Below"

if queryChange and ibComplete
    string stateBefore = auctionState
    bool  convFires   = false
    probeUp    = bool(na)
    scoreHigh  = bool(na)
    bool  isRetest    = false

    bothFailed = failedAuctionBelow and failedAuctionAbove

    if awaitingRetest
        touchedLevel = (acceptedSide == "above" and queryLow[1] <= retestLevel) or (acceptedSide == "below" and queryHigh[1] >= retestLevel)
        if touchedLevel
            holds = (acceptedSide == "above" and queryClose[1] > retestLevel) or (acceptedSide == "below" and queryClose[1] < retestLevel)
            auctionState   := holds ? "Continuation" : "Rejection"
            awaitingRetest := false
            convFires      := true
            isRetest       := true
            scoreHigh      := acceptedSide == "above" ? holds : not holds
            convRetestPts  := holds ? 30.0 : 0.0
            if holds
                awaitingRetest := true

    else if bothFailed
        failedAboveFlag := true
        failedBelowFlag := true
        auctionState := "Two-Sided Auction"
        convFires := true
        isRetest := true
        convRetestPts := 15.0
        upEx   = queryHigh[1] - balanceHigh
        downEx = balanceLow - queryLow[1]
        scoreHigh := downEx > upEx

    else if failedAuctionBelow
        failedBelowFlag := true
        auctionState := failedAboveFlag ? "Two-Sided Auction" : "Failed Below"
        convFires := true
        probeUp   := false
        scoreHigh := true

    else if failedAuctionAbove
        failedAboveFlag := true
        auctionState := failedBelowFlag ? "Two-Sided Auction" : "Failed Above"
        convFires := true
        probeUp   := true
        scoreHigh := false

    else if bullAcceptance
        acceptedSide   := "above"
        awaitingRetest := true
        retestLevel    := balanceHigh
        auctionState   := "Accepted Above"
        convFires      := true
        probeUp        := true
        scoreHigh      := true

    else if bearAcceptance
        acceptedSide   := "below"
        awaitingRetest := true
        retestLevel    := balanceLow
        auctionState   := "Accepted Below"
        convFires      := true
        probeUp        := false
        scoreHigh      := false

    if convFires
        clv = f_closeStrength(queryOpen[1], queryHigh[1], queryLow[1], queryClose[1])
        convAcceptPts := (scoreHigh ? clv : 100 - clv) * 0.4

        if not isRetest
            ibWidthNow = balanceHigh - balanceLow
            excursion  = probeUp ? (queryHigh[1] - balanceHigh) : (balanceLow - queryLow[1])
            excursionRatio = ibWidthNow > 0 ? math.max(excursion / ibWidthNow, 0.0) : na
            convExtendPts := ibWidthNow > 0 ? math.min(excursionRatio, 1.0) * 30 : 15.0
            convRetestPts := 15.0
            if failedAuctionBelow or failedAuctionAbove
                lastFailExcursion := excursionRatio
            if bullAcceptance or bearAcceptance
                lastAcceptExcursion := excursionRatio
        else
            convExtendPts := 15.0

        convictionScore := convAcceptPts + convExtendPts + convRetestPts

    if auctionState != stateBefore
        candlesInState := 1
    else
        candlesInState += 1

    becameAcceptedAbove := auctionState == "Accepted Above" and stateBefore != "Accepted Above"
    becameAcceptedBelow := auctionState == "Accepted Below" and stateBefore != "Accepted Below"
    becameFailedAbove    := auctionState == "Failed Above" and stateBefore != "Failed Above"
    becameFailedBelow    := auctionState == "Failed Below" and stateBefore != "Failed Below"
    becameTwoSided        := auctionState == "Two-Sided Auction" and stateBefore != "Two-Sided Auction"
    becameContinuation    := auctionState == "Continuation" and stateBefore != "Continuation"
    becameRejection        := auctionState == "Rejection" and stateBefore != "Rejection"

    if auctionState == "Continuation"
        hadContinuationFlag := true

    if becameAcceptedAbove
        pressureAccum := math.max(-100.0, math.min(100.0, pressureAccum + 30))
    if becameAcceptedBelow
        pressureAccum := math.max(-100.0, math.min(100.0, pressureAccum - 30))
    if becameFailedAbove
        pressureAccum := math.max(-100.0, math.min(100.0, pressureAccum - 15))
    if becameFailedBelow
        pressureAccum := math.max(-100.0, math.min(100.0, pressureAccum + 15))
    if becameContinuation
        pressureAccum := math.max(-100.0, math.min(100.0, pressureAccum + (acceptedSide == "above" ? 20 : -20)))
    if becameRejection
        pressureAccum := math.max(-100.0, math.min(100.0, pressureAccum + (acceptedSide == "above" ? -20 : 20)))

//---------------------------------------------------------------------------------------------------------------------//
// VISUALS 

if queryChange and ibComplete
    if becameAcceptedAbove
        label.new(bar_index[1], low[1], '▲', color = naColor, textcolor = color.teal, style = label.style_label_up, size = size.small, tooltip = 'Accepted Above IBH')
    if becameAcceptedBelow
        label.new(bar_index[1], high[1], '▼', color = naColor, textcolor = color.red, style = label.style_label_down, size = size.small, tooltip = 'Accepted Below IBL')
    if becameTwoSided
        label.new(bar_index[1], high[1], '◆', color = naColor, textcolor = color.gray, style = label.style_label_down, size = size.small, tooltip = 'Two-Sided Auction - both IBH and IBL tested and rejected in the same window')
    else if becameFailedBelow
        label.new(bar_index[1], low[1], '✕', color = naColor, textcolor = color.orange, style = label.style_label_up, size = size.small, tooltip = 'Failed Below - rejected back into IB')
    else if becameFailedAbove
        label.new(bar_index[1], high[1], '✕', color = naColor, textcolor = color.orange, style = label.style_label_down, size = size.small, tooltip = 'Failed Above - rejected back into IB')
    if becameContinuation
        label.new(bar_index[1], acceptedSide == "above" ? low[1] : high[1], '●',
             color = naColor, textcolor = acceptedSide == "above" ? color.teal : color.red,
             style = acceptedSide == "above" ? label.style_label_up : label.style_label_down, size = size.small, tooltip = 'Retest held - continuation')
    if becameRejection
        label.new(bar_index[1], acceptedSide == "above" ? high[1] : low[1], '↻',
             color = naColor, textcolor = color.orange,
             style = acceptedSide == "above" ? label.style_label_down : label.style_label_up, size = size.small, tooltip = 'Retest failed - price returned through the accepted IB level')

//---------------------------------------------------------------------------------------------------------------------//
// DASHBOARD

var table dash = table.new(position.top_right, 2, 7, bgcolor = color.new(chart.fg_color, 95), border_color = color.new(chart.fg_color, 95), border_width = 1, frame_color = color.new(chart.fg_color, 81), frame_width = 1)

if showDashboard and barstate.islast and timeframeOK
    regime = auctionState == "Building IB" ? '-' : f_regime(auctionState, failedAboveFlag, failedBelowFlag)
    bias   = auctionState == "Building IB" ? '-' : f_bias(auctionState, acceptedSide)
    invalidation = f_invalidation(auctionState, acceptedSide)
    acceptQ  = f_acceptanceQuality(convictionScore, candlesInState)
    failQ    = f_failureQuality(lastFailExcursion)
    quality  = f_qualityLabel(auctionState, acceptQ, failQ)

    isLiveRetesting = ibComplete and awaitingRetest and ((acceptedSide == "above" and low <= retestLevel) or (acceptedSide == "below" and high >= retestLevel))
    phase = auctionState == "Building IB" ? '-' : f_phase(auctionState, isLiveRetesting, hadContinuationFlag)
    pressureLabel = auctionState == "Building IB" ? '-' : f_pressureLabel(pressureAccum)

    string nextEvent = "-"
    if awaitingRetest
        distToRetest = math.abs(close - retestLevel)
        nextEvent := 'Retest ' + str.tostring(retestLevel, format.mintick) + ' (Δ' + str.tostring(distToRetest, format.mintick) + ')\nInvalidation ' + invalidation
    else
        nextEvent := switch auctionState
            "Building IB"      => "Await IB"
            "Balanced"         => "Await Probe"
            "Probing Above"    => "Close >IBH"
            "Probing Below"    => "Close <IBL"
            "Failed Above"     => "Re-auction\nInvalidation " + invalidation
            "Failed Below"     => "Re-auction\nInvalidation " + invalidation
            "Two-Sided Auction" => "Await accept"
            "Rejection"        => "Re-auction\nInvalidation " + invalidation
            => "Await event"

    nextEvent := str.replace_all(nextEvent, "IBH", str.tostring(balanceHigh, format.mintick))
    nextEvent := str.replace_all(nextEvent, "IBL", str.tostring(balanceLow, format.mintick))

    maturity = f_maturity(candlesInState)
    narrative = f_narrative(auctionState, acceptedSide)

    nextTooltip = str.replace_all(str.replace_all('This read is invalidated by: ' + invalidation, "IBH", str.tostring(balanceHigh, format.mintick)), "IBL", str.tostring(balanceLow, format.mintick))

    table.cell(dash, 0, 0, 'REGIME', text_color = chart.fg_color, text_halign = text.align_left, text_size = panelTextSize)
    table.cell(dash, 1, 0, regime, text_color = chart.fg_color, text_size = panelTextSize, tooltip = 'Session-level auction character: Balanced, Rotational, Expansion, Failed Expansion, or Trend Auction - derived from the state machine, not a separate signal.')

    table.cell(dash, 0, 1, 'BIAS', text_color = chart.fg_color, text_halign = text.align_left, text_size = panelTextSize)
    table.cell(dash, 1, 1, bias, text_size = panelTextSize, text_color = bias == 'Bullish' ? color.teal : bias == 'Bearish' ? color.red : chart.fg_color, tooltip = 'Directional read from the CURRENT event only - not a trade signal, and not the same as Pressure (which is cumulative across the whole session and can disagree with Bias on purpose).')

    table.cell(dash, 0, 2, 'PHASE', text_color = chart.fg_color, text_halign = text.align_left, text_size = panelTextSize)
    table.cell(dash, 1, 2, phase, text_color = chart.fg_color, text_size = panelTextSize, tooltip = 'Lifecycle stage: Balance -> Probe -> Acceptance -> Retest -> Expansion -> Exhaustion.')

    table.cell(dash, 0, 3, 'AUCTION', text_color = chart.fg_color, text_halign = text.align_left, text_size = panelTextSize)
    isLiveState = auctionState == "Probing Above" or auctionState == "Probing Below"
    table.cell(dash, 1, 3, auctionState + (isLiveState ? ' (live)' : ''), text_size = panelTextSize, text_color = isLiveState ? color.gray : chart.fg_color, tooltip = narrative + (isLiveState ? ' (Live/tentative - not yet confirmed by a completed auction candle.)' : ''))

    table.cell(dash, 0, 4, 'PRESSURE', text_color = chart.fg_color, text_halign = text.align_left, text_size = panelTextSize)
    table.cell(dash, 1, 4, pressureLabel, text_size = panelTextSize, text_color = pressureAccum > 10 ? color.teal : pressureAccum < -10 ? color.red : chart.fg_color, tooltip = 'Bounded cumulative auction pressure (-100..100), built from evidence across the whole session - not order-flow or volume pressure, and not a probability.')

    table.cell(dash, 0, 5, 'QUALITY', text_color = chart.fg_color, text_halign = text.align_left, text_size = panelTextSize)
    table.cell(dash, 1, 5, quality, text_size = panelTextSize, text_color = chart.fg_color, tooltip = na(convictionScore) ? 'No confirmed event yet this session.' : 'Conviction: ' + str.tostring(math.round(convictionScore)) + ' (' + str.tostring(math.round(convAcceptPts)) + ' accept + ' + str.tostring(math.round(convExtendPts)) + ' extend + ' + str.tostring(math.round(convRetestPts)) + ' retest) · Maturity: ' + maturity + ' (' + str.tostring(candlesInState) + ' candle' + (candlesInState == 1 ? '' : 's') + ')')

    table.cell(dash, 0, 6, 'NEXT', text_color = chart.fg_color, text_halign = text.align_left, text_size = panelTextSize)
    table.cell(dash, 1, 6, nextEvent, text_color = chart.fg_color, text_size = panelTextSize, tooltip = nextTooltip)
else
    if showDashboard
        table.cell(dash, 0, 0, 'IB Auction Intelligence\nIntraday ≤ 30m', text_size = panelTextSize, text_color = color.orange, text_halign = text.align_center)

//---------------------------------------------------------------------------------------------------------------------//
// ALERTS


alertMsgPrefix = 'IB Auction Intelligence - ' + syminfo.ticker + ' '
alertMsgSuffix = ' @ ' + str.tostring(close, format.mintick) + ' | Anchor: IB ' + ibRange + ' ' + sessionTimezone

if becameAcceptedAbove
    alert(alertMsgPrefix + 'accepted above IBH ' + str.tostring(balanceHigh, format.mintick) + alertMsgSuffix, alert.freq_once_per_bar_close)
if becameAcceptedBelow
    alert(alertMsgPrefix + 'accepted below IBL ' + str.tostring(balanceLow, format.mintick) + alertMsgSuffix, alert.freq_once_per_bar_close)
if becameFailedAbove
    alert(alertMsgPrefix + 'failed above IBH ' + str.tostring(balanceHigh, format.mintick) + alertMsgSuffix, alert.freq_once_per_bar_close)
if becameFailedBelow
    alert(alertMsgPrefix + 'failed below IBL ' + str.tostring(balanceLow, format.mintick) + alertMsgSuffix, alert.freq_once_per_bar_close)
if becameTwoSided
    alert(alertMsgPrefix + 'two-sided auction between IBH ' + str.tostring(balanceHigh, format.mintick) + ' and IBL ' + str.tostring(balanceLow, format.mintick) + alertMsgSuffix, alert.freq_once_per_bar_close)
if becameContinuation
    alert(alertMsgPrefix + 'retest held at ' + str.tostring(retestLevel, format.mintick) + ', continuation' + alertMsgSuffix, alert.freq_once_per_bar_close)
if becameRejection
    alert(alertMsgPrefix + 'retest failed at ' + str.tostring(retestLevel, format.mintick) + ', rejection' + alertMsgSuffix, alert.freq_once_per_bar_close)

var table logo = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(logo, 0, 0, '☼☾  ', text_size = size.normal, text_color = color.teal, tooltip = 'SoleMare Analytics')
````
