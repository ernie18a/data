# 3-6-9

- url: https://www.tradingview.com/script/ctl7aukg-3-6-9/
- type: indicator
- pine_id: PUB;db4146fbbbcd46c999a297daa8e7ddc2
- version: 1.0

## Description

3-6-9 (overlay)

[i]This script marks bars where many independent 3-6-9 style numerology checks line up.[/i]

[b]What it does[/b]
Each bar, the indicator builds three scores: one for [b]3[/b], one for [b]6[/b], one for [b]9[/b]. It adds evidence from time, optional open/close prices as tick counts, bar cycles, optional volume, and optional recognition methods. When combined scores and “source group” agreement pass filters, it draws a [b]◆[/b] on the chart. Hover the marker for the full breakdown.

[b]Core scoring (every value vs target 3, 6, or 9)[/b]
If the toggles are on, each scanned integer can earn points: exact [b]digit sum[/b] equals target (+3); [b]digital root[/b] equals target (+2); number [b]contains[/b] digit 3, 6, or 9 (+1); number is [b]divisible[/b] by the target (+1, light weight). Some channels also use [b]additive[/b] rules: digit-sum equals target (+5) or root of that sum matches (+3).

[b]Base sources[/b] (enable each under Sources)
• [b]Scan time[/b] — Minute, hour, HHMM, hour+minute, day, month, day+month, full calendar date, and digit-sum combinations. Uses [b]Time scan timezone[/b].
• [b]Scan open and close (ticks)[/b] — Core engine on [b]open[/b] and [b]close[/b] as [b]syminfo.mintick[/b] counts (not high/low).
• [b]Scan bar cycles[/b] — Bar number, bar+minute, bar modulo 1000.
• [b]Scan volume[/b] — Rounded volume through the core engine (best when volume is meaningful).

[b]Recognition methods[/b] (enable each under Recognition methods)
Scores for 3, 6, and 9 are [i]added[/i] to that number’s bar total:
• [b]Sequential 3-6-9 ladder[/b] — After base “hits” (base score ≥ 6 for that number), requires 3 then 6 then 9 in order within [b]Ladder lookback[/b].
• [b]Session-cycle timing[/b] — Minutes since [b]Session open hour[/b] and [b]Session open minute[/b] (wraps past midnight).
• [b]Cluster scoring[/b] — If two or more enabled base sources each score that number above [b]Minimum score per source group[/b], adds a bonus.
• [b]3-6-9 sequence memory[/b] — If all three base hits occurred within [b]Sequence memory lookback[/b], boosts all three.
• [b]Date numerology[/b] — Day, month, year, and combined date digit patterns.
• [b]Lo Shu 3-6-9 family[/b] — Digital roots of day, month, HHMM, [b]close[/b] tick count, bar number.
• [b]Vortex 3-6-9 gates[/b] — Bar % target, session minutes % target, or combined root.
• [b]Tesla triad filter[/b] — All three base hits on the bar [i]or[/i] sequence memory complete.
• [b]Repeated digit strength[/b] — Repeats of 3, 6, 9 in HHMM, close ticks, or bar number.
• [b]Mirror numbers[/b] — Pairs/triads like 36/63, 39/93, 69/96, 369/963 in time, ticks, or bar number.
• [b]Planetary numerology cycle[/b] — Day-of-week, hour, and combined calendar cycles.

[b]Totals and “source groups”[/b]
Each of 3, 6, 9 gets one final [b]scoreN[/b]. [b]Total score[/b] = score3 + score6 + score9.
Separately, each enabled source/method group must be “strong enough” for that bar: the [i]maximum[/i] of its three channel scores must reach the [b]effective minimum source score[/b]. The count of groups that pass is [b]matchedSources[/b].

[b]When the diamond appears[/b]
On a [b]confirmed[/b] bar, a marker is drawn only if all are true:
• [b]Total score[/b] ≥ effective minimum total score
• At least [b]effective minimum matching numbers[/b] of {3,6,9} have scoreN ≥ effective minimum number score
• [b]MatchedSources[/b] ≥ effective minimum source groups
• If [b]Require rolling score peak[/b] is on: total score is a new high over [b]Rolling peak lookback[/b] (versus prior bars only)
• [b]Minimum bars between dots[/b] since the last marker

[i]Marker position: close ± ATR(14) × Dot offset, not wick high/low.[/i]

[b]Auto-adjust filters[/b]
When on (recommended), the script uses [b]Auto calibration lookback[/b] to estimate rolling percentiles of past total score, strongest number score, and strongest source score, then sets effective minimums. [b]Auto threshold profile[/b]: [i]More signals[/i] (looser), [i]Balanced[/i] (default), [i]Selective[/i] (stricter).

[b]Manual tuning[/b]
Turn [b]Auto-adjust filters[/b] off. Then [b]Minimum total score for dot[/b], [b]Minimum score per number[/b], [b]Minimum matching numbers[/b], [b]Minimum source groups[/b], and [b]Minimum score per source group[/b] apply directly.

[b]How to use[/b]
Match [b]Time scan timezone[/b] and session open to the session you track. Start with auto + Balanced and enough history loaded. Hover ◆ to read reasons and scores. Refine by profile, cooldown, peak filter, or turning off noisy methods.

[b]Alerts[/b]
One condition fires when a bar meets the full diamond criteria.

## Source Code

````pine
//@version=6
// author OnnoP
indicator("3-6-9", shorttitle="3-6-9", overlay=true,
     max_labels_count=500, max_lines_count=50, max_boxes_count=50)

// ----------------------------------------------------------------------
// Inputs
// ----------------------------------------------------------------------

GRP_ENGINE = "Engine"
i_min_total_score  = input.int(38, "Minimum total score for dot", minval=1, maxval=200, group=GRP_ENGINE,
     tooltip="Higher values show only the strongest 3-6-9 alignments. This controls the combined 3, 6, and 9 score.")
i_min_number_score = input.int(10, "Minimum score per number", minval=1, maxval=80, group=GRP_ENGINE,
     tooltip="A number only counts as present when its own score reaches this value.")
i_min_numbers      = input.int(2, "Minimum matching numbers", minval=1, maxval=3, group=GRP_ENGINE,
     tooltip="Use 2 or 3 for prominent 3-6-9 combinations. Use 1 to show single-number occurrences.")
i_min_sources      = input.int(3, "Minimum source groups", minval=1, maxval=15, group=GRP_ENGINE,
     tooltip="Requires agreement across enabled source groups and recognition methods.")
i_min_source_score = input.int(10, "Minimum score per source group", minval=1, maxval=80, group=GRP_ENGINE,
     tooltip="A source group only counts when one of 3, 6, or 9 is strong inside that group.")
i_auto_filters     = input.bool(true, "Auto-adjust filters", group=GRP_ENGINE,
     tooltip="Uses rolling score calibration so thresholds adapt to the enabled source/method mix and the current chart.")
i_auto_profile     = input.string("Balanced", "Auto threshold profile", options=["More signals", "Balanced", "Selective"], group=GRP_ENGINE,
     tooltip="More signals uses lower rolling percentiles. Selective uses higher percentiles for rarer diamonds.")
i_auto_lookback    = input.int(300, "Auto calibration lookback", minval=50, maxval=5000, group=GRP_ENGINE,
     tooltip="Number of previous bars used to learn practical score thresholds for the current settings.")
i_require_peak     = input.bool(false, "Require rolling score peak", group=GRP_ENGINE,
     tooltip="Only places a dot when the total 3-6-9 score is a new high inside the lookback window.")
i_peak_lookback    = input.int(12, "Rolling peak lookback", minval=3, maxval=500, group=GRP_ENGINE)
i_min_bars_between_dots = input.int(16, "Minimum bars between dots", minval=0, maxval=500, group=GRP_ENGINE,
     tooltip="Prevents clusters of dots. A new dot can only appear after this many bars have passed since the previous one.")
i_use_digit_sum    = input.bool(true, "Use exact digit sums", group=GRP_ENGINE,
     tooltip="Checks whether the sum of a number's digits equals exactly 3, 6, or 9. Example: minute 15 -> 1+5 = 6.")
i_use_digital_root = input.bool(true, "Use digital roots", group=GRP_ENGINE,
     tooltip="Keeps reducing digit sums until one digit remains. Example: 78 -> 7+8 = 15 -> 1+5 = 6.")
i_use_digits       = input.bool(true, "Use contained digits", group=GRP_ENGINE,
     tooltip="Checks whether the number contains 3, 6, or 9 anywhere.")
i_use_multiples    = input.bool(true, "Use multiples", group=GRP_ENGINE,
     tooltip="Adds light evidence for numbers divisible by 3, 6, or 9. This is intentionally weighted lower because it occurs often.")

GRP_SOURCES = "Sources"
i_use_time     = input.bool(true, "Scan time", group=GRP_SOURCES)
i_use_price    = input.bool(true, "Scan open and close (ticks)", group=GRP_SOURCES)
i_use_cycle    = input.bool(true, "Scan bar cycles", group=GRP_SOURCES)
i_use_volume   = input.bool(false, "Scan volume", group=GRP_SOURCES,
     tooltip="Useful on markets with meaningful volume. Leave off for symbols where volume is synthetic or unavailable.")
i_timezone     = input.string("America/New_York", "Time scan timezone",
     options=[
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "America/Toronto",
         "America/Sao_Paulo",
         "Europe/London",
         "Europe/Paris",
         "Europe/Berlin",
         "Europe/Zurich",
         "Asia/Dubai",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Asia/Shanghai",
         "Asia/Tokyo",
         "Australia/Sydney",
         "Pacific/Auckland",
         "UTC"],
     group=GRP_SOURCES,
     tooltip="IANA zone used for Scan time and session-cycle inputs (bar clock is unchanged).")

GRP_METHODS = "Recognition methods"
i_use_sequence_ladder = input.bool(true, "Sequential 3-6-9 ladder", group=GRP_METHODS,
     tooltip="Looks for 3, then 6, then 9 appearing in order inside the selected lookback.")
i_ladder_lookback = input.int(18, "Ladder lookback", minval=3, maxval=300, group=GRP_METHODS)
i_use_session_cycle = input.bool(true, "Session-cycle timing", group=GRP_METHODS,
     tooltip="Scores minutes elapsed since the configured session open.")
i_session_open_hour = input.int(9, "Session open hour", minval=0, maxval=23, group=GRP_METHODS)
i_session_open_minute = input.int(30, "Session open minute", minval=0, maxval=59, group=GRP_METHODS)
i_use_cluster_scoring = input.bool(true, "Cluster scoring", group=GRP_METHODS,
     tooltip="Boosts numbers when multiple enabled base sources agree on the same number.")
i_use_sequence_memory = input.bool(true, "3-6-9 sequence memory", group=GRP_METHODS,
     tooltip="Scores all three numbers when 3, 6, and 9 all appeared recently, even if not on the same bar.")
i_memory_lookback = input.int(24, "Sequence memory lookback", minval=3, maxval=500, group=GRP_METHODS)
i_use_date_numerology = input.bool(true, "Date numerology", group=GRP_METHODS,
     tooltip="Uses day, month, year, day+month, and full-date reductions as a separate numerology source.")
i_use_lo_shu = input.bool(true, "Lo Shu 3-6-9 family", group=GRP_METHODS,
     tooltip="Scores the 3-6-9 vertical Lo Shu family across date, time, price, and bar roots.")
i_use_vortex = input.bool(true, "Vortex 3-6-9 gates", group=GRP_METHODS,
     tooltip="Uses 3/6/9 cycle gates around bar count, session minutes, and compact time values.")
i_use_tesla_triad = input.bool(true, "Tesla triad filter", group=GRP_METHODS,
     tooltip="Boosts all three numbers when the current bar or recent memory contains the full 3-6-9 triad.")
i_use_repeated_digits = input.bool(true, "Repeated digit strength", group=GRP_METHODS,
     tooltip="Boosts values that repeat 3, 6, or 9, such as 33, 66, 99, 333, 666, or 999.")
i_use_mirror_numbers = input.bool(true, "Mirror numbers", group=GRP_METHODS,
     tooltip="Scores mirrored 3-6-9 pairs and triads such as 36/63, 39/93, 69/96, 369, and 963.")
i_use_planetary_numerology = input.bool(true, "Planetary numerology cycle", group=GRP_METHODS,
     tooltip="Combines day-of-week, hour, date, and month cycles into numerology roots.")

GRP_VISUAL = "Visuals"
i_show_dots  = input.bool(true, "Show hover markers", group=GRP_VISUAL)
i_max_dots   = input.int(80, "Maximum markers", minval=10, maxval=500, group=GRP_VISUAL)
i_dot_side   = input.string("Above candle", "Dot position", options=["Above candle", "Below candle"], group=GRP_VISUAL)
i_dot_offset = input.float(0.18, "Dot offset (ATR)", minval=0.0, maxval=2.0, step=0.01, group=GRP_VISUAL)
i_dot_size   = input.string("Huge", "Marker size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=GRP_VISUAL)

// ----------------------------------------------------------------------
// Mathematical 3-6-9 engine
// ----------------------------------------------------------------------

f_abs_int(int value) =>
    value < 0 ? -value : value

f_digit_sum(int value) =>
    int n = f_abs_int(value)
    int sum = 0
    if n == 0
        sum := 0
    else
        while n > 0
            sum += n % 10
            n := int(math.floor(n / 10))
    sum

f_digital_root(int value) =>
    int sum = f_digit_sum(value)
    while sum > 9
        sum := f_digit_sum(sum)
    sum

f_has_digit(int value, int target) =>
    int n = f_abs_int(value)
    bool found = false
    if n == 0
        found := target == 0
    else
        while n > 0
            int digit = n % 10
            if digit == target
                found := true
            n := int(math.floor(n / 10))
    found

f_engine_score(int value, int target, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int n = f_abs_int(value)
    int rawSum = f_digit_sum(n)
    int root = f_digital_root(n)
    int score = 0
    if useDigitSum and rawSum == target
        score += 3
    if useDigitalRoot and root == target
        score += 2
    if useDigits and f_has_digit(n, target)
        score += 1
    if useMultiples and n > 0 and n % target == 0
        score += 1
    score

f_digit_expr(int value) =>
    int n = f_abs_int(value)
    string expr = ""
    if n == 0
        expr := "0"
    else
        int divisor = 1
        while int(math.floor(n / divisor)) >= 10
            divisor *= 10
        while divisor > 0
            int digit = int(math.floor(n / divisor)) % 10
            expr += (str.length(expr) > 0 ? "+" : "") + str.tostring(digit)
            divisor := int(math.floor(divisor / 10))
    expr

f_additive_score(int digitSum, int target, bool useDigitalRoot) =>
    int score = 0
    if digitSum == target
        score += 5
    else if useDigitalRoot and f_digital_root(digitSum) == target
        score += 3
    score

f_additive_reason(int digitSum, string expression, string label, int target, bool useDigitalRoot) =>
    string reason = ""
    if digitSum == target
        reason := label + ": " + expression + " = " + str.tostring(target)
    else if useDigitalRoot and f_digital_root(digitSum) == target
        reason := label + ": " + expression + " = " + str.tostring(digitSum) + ", digital root = " + str.tostring(target)
    reason

f_engine_reason(int value, string label, int target, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int n = f_abs_int(value)
    int rawSum = f_digit_sum(n)
    int root = f_digital_root(n)
    string expr = f_digit_expr(n)
    string reason = ""
    if useDigitSum and rawSum == target
        reason := label + ": " + expr + " = " + str.tostring(target)
    else if useDigitalRoot and root == target
        reason := label + ": " + expr + " = " + str.tostring(rawSum) + ", digital root = " + str.tostring(target)
    else if useDigits and f_has_digit(n, target)
        reason := label + ": contains digit " + str.tostring(target)
    else if useMultiples and n > 0 and n % target == 0
        reason := label + ": " + str.tostring(n) + " is divisible by " + str.tostring(target)
    reason

f_append_reason(string current, string sourceName, string reason) =>
    reason == "" ? current : current + (str.length(current) > 0 ? "\n" : "") + "  - " + sourceName + ": " + reason

f_tick_units(float price, float mintick) =>
    mintick > 0.0 ? int(math.round(price / mintick)) : int(math.round(price))

f_clamp_int(int value, int minValue, int maxValue) =>
    math.max(minValue, math.min(value, maxValue))

f_bool_count(bool a, bool b, bool c) =>
    (a ? 1 : 0) + (b ? 1 : 0) + (c ? 1 : 0)

f_digit_count(int value, int target) =>
    int n = f_abs_int(value)
    int count = 0
    if n == 0
        count := target == 0 ? 1 : 0
    else
        while n > 0
            if n % 10 == target
                count += 1
            n := int(math.floor(n / 10))
    count

f_has_pair(int value, int firstDigit, int secondDigit) =>
    int n = f_abs_int(value)
    int pair = firstDigit * 10 + secondDigit
    bool found = false
    while n >= 10
        if n % 100 == pair
            found := true
        n := int(math.floor(n / 10))
    found

f_has_triad(int value, int firstDigit, int secondDigit, int thirdDigit) =>
    int n = f_abs_int(value)
    int triad = firstDigit * 100 + secondDigit * 10 + thirdDigit
    bool found = false
    while n >= 100
        if n % 1000 == triad
            found := true
        n := int(math.floor(n / 10))
    found

f_score_repeated_digits(int target, int compactTime, int priceUnits, int barNumber) =>
    int timeCount = f_digit_count(compactTime, target)
    int priceCount = f_digit_count(priceUnits, target)
    int barCount = f_digit_count(barNumber, target)
    int maxCount = math.max(timeCount, math.max(priceCount, barCount))
    maxCount >= 3 ? 9 : maxCount == 2 ? 5 : 0

f_reason_repeated_digits(int target, int compactTime, int priceUnits, int barNumber) =>
    string reason = ""
    if f_digit_count(priceUnits, target) >= 2
        reason := "Price tick count repeats digit " + str.tostring(target)
    else if f_digit_count(compactTime, target) >= 2
        reason := "Time HHMM repeats digit " + str.tostring(target)
    else if f_digit_count(barNumber, target) >= 2
        reason := "Bar number repeats digit " + str.tostring(target)
    reason

f_score_mirror_numbers(int target, int compactTime, int priceUnits, int barNumber) =>
    bool pair36 = f_has_pair(compactTime, 3, 6) or f_has_pair(compactTime, 6, 3) or f_has_pair(priceUnits, 3, 6) or f_has_pair(priceUnits, 6, 3) or f_has_pair(barNumber, 3, 6) or f_has_pair(barNumber, 6, 3)
    bool pair39 = f_has_pair(compactTime, 3, 9) or f_has_pair(compactTime, 9, 3) or f_has_pair(priceUnits, 3, 9) or f_has_pair(priceUnits, 9, 3) or f_has_pair(barNumber, 3, 9) or f_has_pair(barNumber, 9, 3)
    bool pair69 = f_has_pair(compactTime, 6, 9) or f_has_pair(compactTime, 9, 6) or f_has_pair(priceUnits, 6, 9) or f_has_pair(priceUnits, 9, 6) or f_has_pair(barNumber, 6, 9) or f_has_pair(barNumber, 9, 6)
    bool triad = f_has_triad(compactTime, 3, 6, 9) or f_has_triad(compactTime, 9, 6, 3) or f_has_triad(priceUnits, 3, 6, 9) or f_has_triad(priceUnits, 9, 6, 3) or f_has_triad(barNumber, 3, 6, 9) or f_has_triad(barNumber, 9, 6, 3)
    bool targetPair = target == 3 ? pair36 or pair39 : target == 6 ? pair36 or pair69 : pair39 or pair69
    (triad ? 7 : 0) + (targetPair ? 5 : 0)

f_reason_mirror_numbers(int target, int compactTime, int priceUnits, int barNumber) =>
    string reason = ""
    bool triad = f_has_triad(compactTime, 3, 6, 9) or f_has_triad(compactTime, 9, 6, 3) or f_has_triad(priceUnits, 3, 6, 9) or f_has_triad(priceUnits, 9, 6, 3) or f_has_triad(barNumber, 3, 6, 9) or f_has_triad(barNumber, 9, 6, 3)
    if triad
        reason := "A mirrored 369/963 triad is present"
    else
        reason := "A mirrored pair involving " + str.tostring(target) + " is present"
    reason

f_score_planetary_numerology(int target, int dayOfWeekNow, int hourNow, int dayNow, int monthNow, int yearNow) =>
    int score = 0
    score += f_digital_root(dayOfWeekNow) == target ? 3 : 0
    score += f_digital_root(dayOfWeekNow + hourNow) == target ? 4 : 0
    score += f_digital_root(dayNow + monthNow + dayOfWeekNow) == target ? 4 : 0
    score += f_digital_root(dayNow + monthNow + yearNow + hourNow) == target ? 4 : 0
    score += f_digital_root((dayOfWeekNow * 24) + hourNow) == target ? 3 : 0
    score

f_reason_planetary_numerology(int target, int dayOfWeekNow, int hourNow, int dayNow, int monthNow, int yearNow) =>
    string reason = ""
    if f_digital_root(dayOfWeekNow + hourNow) == target
        reason := "Day-of-week + hour reduces to " + str.tostring(target)
    else if f_digital_root(dayNow + monthNow + dayOfWeekNow) == target
        reason := "Date + day-of-week cycle reduces to " + str.tostring(target)
    else if f_digital_root(dayNow + monthNow + yearNow + hourNow) == target
        reason := "Full date + hour cycle reduces to " + str.tostring(target)
    else if f_digital_root((dayOfWeekNow * 24) + hourNow) == target
        reason := "Planetary week-hour index reduces to " + str.tostring(target)
    reason

f_score_session_cycle(int target, int minutesFromOpen, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int sessionMinute = math.max(minutesFromOpen, 0)
    int score = 0
    score += f_engine_score(sessionMinute, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_additive_score(f_digit_sum(sessionMinute), target, useDigitalRoot)
    score

f_reason_session_cycle(int target, int minutesFromOpen, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int sessionMinute = math.max(minutesFromOpen, 0)
    string reason = f_additive_reason(f_digit_sum(sessionMinute), f_digit_expr(sessionMinute), "Minutes from session open " + str.tostring(sessionMinute), target, useDigitalRoot)
    if reason == ""
        reason := f_engine_reason(sessionMinute, "Minutes from session open " + str.tostring(sessionMinute), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    reason

f_score_date_numerology(int target, int dayNow, int monthNow, int yearNow, bool useDigitalRoot) =>
    int daySum = f_digit_sum(dayNow)
    int monthSum = f_digit_sum(monthNow)
    int yearSum = f_digit_sum(yearNow)
    int score = 0
    score += f_additive_score(daySum, target, useDigitalRoot)
    score += f_additive_score(monthSum, target, useDigitalRoot)
    score += f_additive_score(yearSum, target, useDigitalRoot)
    score += f_additive_score(daySum + monthSum, target, useDigitalRoot)
    score += f_additive_score(daySum + monthSum + yearSum, target, useDigitalRoot)
    score

f_reason_date_numerology(int target, int dayNow, int monthNow, int yearNow, bool useDigitalRoot) =>
    int daySum = f_digit_sum(dayNow)
    int monthSum = f_digit_sum(monthNow)
    int yearSum = f_digit_sum(yearNow)
    string reason = f_additive_reason(daySum + monthSum + yearSum, f_digit_expr(dayNow) + "+" + f_digit_expr(monthNow) + "+" + f_digit_expr(yearNow), "Full date numerology", target, useDigitalRoot)
    if reason == ""
        reason := f_additive_reason(daySum + monthSum, f_digit_expr(dayNow) + "+" + f_digit_expr(monthNow), "Day + month numerology", target, useDigitalRoot)
    if reason == ""
        reason := f_additive_reason(yearSum, f_digit_expr(yearNow), "Year numerology", target, useDigitalRoot)
    reason

f_score_lo_shu(int target, int dayNow, int monthNow, int hhmm, float closePx, float mintick, int barNumber) =>
    int score = 0
    score += f_digital_root(dayNow) == target ? 3 : 0
    score += f_digital_root(monthNow) == target ? 3 : 0
    score += f_digital_root(hhmm) == target ? 3 : 0
    score += f_digital_root(f_tick_units(closePx, mintick)) == target ? 3 : 0
    score += f_digital_root(barNumber) == target ? 3 : 0
    score

f_reason_lo_shu(int target, int dayNow, int monthNow, int hhmm, float closePx, float mintick, int barNumber) =>
    string reason = ""
    if f_digital_root(f_tick_units(closePx, mintick)) == target
        reason := "Close price belongs to the Lo Shu 3-6-9 family with root " + str.tostring(target)
    else if f_digital_root(hhmm) == target
        reason := "Time HHMM belongs to the Lo Shu 3-6-9 family with root " + str.tostring(target)
    else if f_digital_root(barNumber) == target
        reason := "Bar number belongs to the Lo Shu 3-6-9 family with root " + str.tostring(target)
    else if f_digital_root(dayNow) == target or f_digital_root(monthNow) == target
        reason := "Date component belongs to the Lo Shu 3-6-9 family with root " + str.tostring(target)
    reason

f_score_vortex(int target, int barNumber, int minutesFromOpen, int hhmm) =>
    int score = 0
    score += barNumber % target == 0 ? 4 : 0
    score += minutesFromOpen >= 0 and minutesFromOpen % target == 0 ? 4 : 0
    score += f_digital_root(barNumber + minutesFromOpen + hhmm) == target ? 4 : 0
    score

f_reason_vortex(int target, int barNumber, int minutesFromOpen, int hhmm) =>
    string reason = ""
    if barNumber % target == 0
        reason := "Bar number is on a vortex " + str.tostring(target) + " gate"
    else if minutesFromOpen >= 0 and minutesFromOpen % target == 0
        reason := "Session minute is on a vortex " + str.tostring(target) + " gate"
    else if f_digital_root(barNumber + minutesFromOpen + hhmm) == target
        reason := "Bar + session minute + time reduces to vortex gate " + str.tostring(target)
    reason

f_score_time(int target, int hourNow, int minuteNow, int dayNow, int monthNow, int yearNow, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int hhmm = hourNow * 100 + minuteNow
    int dateCompact = yearNow * 10000 + monthNow * 100 + dayNow
    int minuteDigitSum = f_digit_sum(minuteNow)
    int hourDigitSum = f_digit_sum(hourNow)
    int timeDigitSum = hourDigitSum + minuteDigitSum
    int dayDigitSum = f_digit_sum(dayNow)
    int monthDigitSum = f_digit_sum(monthNow)
    int yearDigitSum = f_digit_sum(yearNow)
    int dayMonthDigitSum = dayDigitSum + monthDigitSum
    int fullDateDigitSum = dayDigitSum + monthDigitSum + yearDigitSum
    int score = 0
    score += f_engine_score(minuteNow, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(hourNow, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(hhmm, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(hourNow + minuteNow, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(dayNow, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(monthNow, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(dayNow + monthNow, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(dateCompact, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_additive_score(minuteDigitSum, target, useDigitalRoot)
    score += f_additive_score(hourDigitSum, target, useDigitalRoot)
    score += f_additive_score(timeDigitSum, target, useDigitalRoot)
    score += f_additive_score(dayDigitSum, target, useDigitalRoot)
    score += f_additive_score(monthDigitSum, target, useDigitalRoot)
    score += f_additive_score(dayMonthDigitSum, target, useDigitalRoot)
    score += f_additive_score(fullDateDigitSum, target, useDigitalRoot)
    score

f_reason_time(int target, int hourNow, int minuteNow, int dayNow, int monthNow, int yearNow, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int hhmm = hourNow * 100 + minuteNow
    int dateCompact = yearNow * 10000 + monthNow * 100 + dayNow
    int minuteDigitSum = f_digit_sum(minuteNow)
    int hourDigitSum = f_digit_sum(hourNow)
    int dayDigitSum = f_digit_sum(dayNow)
    int monthDigitSum = f_digit_sum(monthNow)
    int yearDigitSum = f_digit_sum(yearNow)
    string reason = f_additive_reason(dayDigitSum, f_digit_expr(dayNow), "Day " + str.tostring(dayNow), target, useDigitalRoot)
    if reason == ""
        reason := f_additive_reason(monthDigitSum, f_digit_expr(monthNow), "Month " + str.tostring(monthNow), target, useDigitalRoot)
    if reason == ""
        reason := f_additive_reason(dayDigitSum + monthDigitSum, f_digit_expr(dayNow) + "+" + f_digit_expr(monthNow), "Day + month", target, useDigitalRoot)
    if reason == ""
        reason := f_additive_reason(minuteDigitSum, f_digit_expr(minuteNow), "Minute " + str.tostring(minuteNow), target, useDigitalRoot)
    if reason == ""
        reason := f_additive_reason(hourDigitSum + minuteDigitSum, f_digit_expr(hourNow) + "+" + f_digit_expr(minuteNow), "Hour + minute", target, useDigitalRoot)
    if reason == ""
        reason := f_additive_reason(dayDigitSum + monthDigitSum + yearDigitSum, f_digit_expr(dayNow) + "+" + f_digit_expr(monthNow) + "+" + f_digit_expr(yearNow), "Full date", target, useDigitalRoot)
    if reason == ""
        reason := f_engine_reason(hhmm, "Time HHMM " + str.tostring(hhmm), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    if reason == ""
        reason := f_engine_reason(dateCompact, "Date " + str.tostring(dateCompact), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    reason

f_score_price(int target, float openPx, float closePx, float mintick, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int score = 0
    score += f_engine_score(f_tick_units(openPx, mintick), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(f_tick_units(closePx, mintick), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score

f_reason_price(int target, float openPx, float closePx, float mintick, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    string reason = f_engine_reason(f_tick_units(closePx, mintick), "Close price " + str.tostring(closePx, format.mintick), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    if reason == ""
        reason := f_engine_reason(f_tick_units(openPx, mintick), "Open price " + str.tostring(openPx, format.mintick), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    reason

f_score_cycle(int target, int barNumber, int minuteNow, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int score = 0
    score += f_engine_score(barNumber, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(barNumber + minuteNow, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score += f_engine_score(barNumber % 1000, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    score

f_reason_cycle(int target, int barNumber, int minuteNow, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    string reason = f_engine_reason(barNumber, "Bar number " + str.tostring(barNumber), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    if reason == ""
        reason := f_engine_reason(barNumber + minuteNow, "Bar number + minute", target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    if reason == ""
        reason := f_engine_reason(barNumber % 1000, "Bar number modulo 1000", target, useDigitSum, useDigitalRoot, useDigits, useMultiples)
    reason

f_score_volume(int target, float volumeNow, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int volUnits = int(math.round(nz(volumeNow, 0.0)))
    f_engine_score(volUnits, target, useDigitSum, useDigitalRoot, useDigits, useMultiples)

f_reason_volume(int target, float volumeNow, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    int volUnits = int(math.round(nz(volumeNow, 0.0)))
    f_engine_reason(volUnits, "Volume " + str.tostring(volUnits), target, useDigitSum, useDigitalRoot, useDigits, useMultiples)

f_number_reasons(int target, int hourNow, int minuteNow, int dayNow, int monthNow, int yearNow, float openPx, float closePx, float mintick, int barNumber, float volumeNow, bool useVolume, bool useDigitSum, bool useDigitalRoot, bool useDigits, bool useMultiples) =>
    string reasons = ""
    reasons := f_append_reason(reasons, "Time/date", f_reason_time(target, hourNow, minuteNow, dayNow, monthNow, yearNow, useDigitSum, useDigitalRoot, useDigits, useMultiples))
    reasons := f_append_reason(reasons, "Price", f_reason_price(target, openPx, closePx, mintick, useDigitSum, useDigitalRoot, useDigits, useMultiples))
    reasons := f_append_reason(reasons, "Cycle", f_reason_cycle(target, barNumber, minuteNow, useDigitSum, useDigitalRoot, useDigits, useMultiples))
    if useVolume
        reasons := f_append_reason(reasons, "Volume", f_reason_volume(target, volumeNow, useDigitSum, useDigitalRoot, useDigits, useMultiples))
    reasons == "" ? "  - Combined minor matches across enabled sources." : reasons

f_hit_color(bool hit3, bool hit6, bool hit9) =>
    color result = color(na)
    if hit3 and hit6 and hit9
        result := #F8FAFC
    else if hit3 and hit6
        result := #FFB74D
    else if hit3 and hit9
        result := #FFD54F
    else if hit6 and hit9
        result := #BA68C8
    else if hit3
        result := #FFC107
    else if hit6
        result := #7E57C2
    else if hit9
        result := #00BCD4
    result

f_marker_text(bool hit3, bool hit6, bool hit9) =>
    string txt = ""
    txt += hit3 ? "3" : ""
    txt += hit6 ? (str.length(txt) > 0 ? "-6" : "6") : ""
    txt += hit9 ? (str.length(txt) > 0 ? "-9" : "9") : ""
    txt

f_dot_tooltip(int score3, int score6, int score9, int totalScore, int matchedNumbers, int matchedSources, int minNumberScore, int minTotalScore, int minSources, int timeScore, int priceScore, int cycleScore, int volumeScore, int sequenceScore, int sessionScore, int clusterScore, int memoryScore, int numerologyScore, int loShuScore, int vortexScore, int teslaScore, int repeatedScore, int mirrorScore, int planetaryScore, string reasons3, string reasons6, string reasons9) =>
    "Prominent 3-6-9 alignment\n" +
     "Shown because the bar passed all dot filters:\n" +
     "Total score: " + str.tostring(totalScore) + " / " + str.tostring(minTotalScore) + "\n" +
     "Numbers matched: " + str.tostring(matchedNumbers) + " (" + f_marker_text(score3 >= minNumberScore, score6 >= minNumberScore, score9 >= minNumberScore) + ")\n" +
     "Source groups matched: " + str.tostring(matchedSources) + " / " + str.tostring(minSources) + "\n\n" +
     "Why these numbers matched\n" +
     (score3 >= minNumberScore ? "3:\n" + reasons3 + "\n" : "") +
     (score6 >= minNumberScore ? "6:\n" + reasons6 + "\n" : "") +
     (score9 >= minNumberScore ? "9:\n" + reasons9 + "\n" : "") +
     "\nTime/date checks include additive digit sums, e.g. 15 -> 1+5 = 6 and day 21 -> 2+1 = 3.\n\n" +
     "Number scores\n" +
     "3: " + str.tostring(score3) + " | 6: " + str.tostring(score6) + " | 9: " + str.tostring(score9) + "\n\n" +
     "Source scores\n" +
     "Time: " + str.tostring(timeScore) + "\n" +
     "Price: " + str.tostring(priceScore) + "\n" +
     "Bar cycle: " + str.tostring(cycleScore) + "\n" +
     "Volume: " + str.tostring(volumeScore) + "\n" +
     "Sequential ladder: " + str.tostring(sequenceScore) + "\n" +
     "Session cycle: " + str.tostring(sessionScore) + "\n" +
     "Cluster: " + str.tostring(clusterScore) + "\n" +
     "Sequence memory: " + str.tostring(memoryScore) + "\n" +
     "Date numerology: " + str.tostring(numerologyScore) + "\n" +
     "Lo Shu: " + str.tostring(loShuScore) + "\n" +
     "Vortex: " + str.tostring(vortexScore) + "\n" +
     "Tesla triad: " + str.tostring(teslaScore) + "\n" +
     "Repeated digits: " + str.tostring(repeatedScore) + "\n" +
     "Mirror numbers: " + str.tostring(mirrorScore) + "\n" +
     "Planetary numerology: " + str.tostring(planetaryScore)

// ----------------------------------------------------------------------
// Per-bar scans
// ----------------------------------------------------------------------

hourNow = hour(time, i_timezone)
minuteNow = minute(time, i_timezone)
dayNow = dayofmonth(time, i_timezone)
monthNow = month(time, i_timezone)
yearNow = year(time, i_timezone)
dayOfWeekNow = dayofweek(time, i_timezone)
atrNow = ta.atr(14)
barNumber = bar_index + 1
hhmmNow = hourNow * 100 + minuteNow
closeUnits = f_tick_units(close, syminfo.mintick)
sessionOpenMinute = i_session_open_hour * 60 + i_session_open_minute
currentSessionMinute = hourNow * 60 + minuteNow
minutesFromOpen = currentSessionMinute >= sessionOpenMinute ? currentSessionMinute - sessionOpenMinute : currentSessionMinute + 1440 - sessionOpenMinute

timeScore3 = i_use_time ? f_score_time(3, hourNow, minuteNow, dayNow, monthNow, yearNow, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
timeScore6 = i_use_time ? f_score_time(6, hourNow, minuteNow, dayNow, monthNow, yearNow, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
timeScore9 = i_use_time ? f_score_time(9, hourNow, minuteNow, dayNow, monthNow, yearNow, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0

priceScore3 = i_use_price ? f_score_price(3, open, close, syminfo.mintick, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
priceScore6 = i_use_price ? f_score_price(6, open, close, syminfo.mintick, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
priceScore9 = i_use_price ? f_score_price(9, open, close, syminfo.mintick, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0

cycleScore3 = i_use_cycle ? f_score_cycle(3, barNumber, minuteNow, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
cycleScore6 = i_use_cycle ? f_score_cycle(6, barNumber, minuteNow, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
cycleScore9 = i_use_cycle ? f_score_cycle(9, barNumber, minuteNow, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0

volumeScore3 = i_use_volume ? f_score_volume(3, volume, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
volumeScore6 = i_use_volume ? f_score_volume(6, volume, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
volumeScore9 = i_use_volume ? f_score_volume(9, volume, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0

baseScore3 = timeScore3 + priceScore3 + cycleScore3 + volumeScore3
baseScore6 = timeScore6 + priceScore6 + cycleScore6 + volumeScore6
baseScore9 = timeScore9 + priceScore9 + cycleScore9 + volumeScore9
baseHit3 = baseScore3 >= 6
baseHit6 = baseScore6 >= 6
baseHit9 = baseScore9 >= 6

barsSince3 = nz(ta.barssince(baseHit3), i_memory_lookback + i_ladder_lookback + 1)
barsSince6 = nz(ta.barssince(baseHit6), i_memory_lookback + i_ladder_lookback + 1)
barsSince9 = nz(ta.barssince(baseHit9), i_memory_lookback + i_ladder_lookback + 1)
ladderComplete = barsSince3 > barsSince6 and barsSince6 > barsSince9 and barsSince3 <= i_ladder_lookback
sequenceScore3 = i_use_sequence_ladder and ladderComplete ? 6 : 0
sequenceScore6 = sequenceScore3
sequenceScore9 = sequenceScore3

sessionScore3 = i_use_session_cycle ? f_score_session_cycle(3, minutesFromOpen, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
sessionScore6 = i_use_session_cycle ? f_score_session_cycle(6, minutesFromOpen, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0
sessionScore9 = i_use_session_cycle ? f_score_session_cycle(9, minutesFromOpen, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : 0

clusterCount3 = f_bool_count(timeScore3 >= i_min_source_score, priceScore3 >= i_min_source_score, cycleScore3 >= i_min_source_score) + (i_use_volume and volumeScore3 >= i_min_source_score ? 1 : 0)
clusterCount6 = f_bool_count(timeScore6 >= i_min_source_score, priceScore6 >= i_min_source_score, cycleScore6 >= i_min_source_score) + (i_use_volume and volumeScore6 >= i_min_source_score ? 1 : 0)
clusterCount9 = f_bool_count(timeScore9 >= i_min_source_score, priceScore9 >= i_min_source_score, cycleScore9 >= i_min_source_score) + (i_use_volume and volumeScore9 >= i_min_source_score ? 1 : 0)
clusterScore3 = i_use_cluster_scoring and clusterCount3 >= 2 ? clusterCount3 * 4 : 0
clusterScore6 = i_use_cluster_scoring and clusterCount6 >= 2 ? clusterCount6 * 4 : 0
clusterScore9 = i_use_cluster_scoring and clusterCount9 >= 2 ? clusterCount9 * 4 : 0

memoryComplete = barsSince3 <= i_memory_lookback and barsSince6 <= i_memory_lookback and barsSince9 <= i_memory_lookback
memoryScore3 = i_use_sequence_memory and memoryComplete ? 5 : 0
memoryScore6 = memoryScore3
memoryScore9 = memoryScore3

numerologyScore3 = i_use_date_numerology ? f_score_date_numerology(3, dayNow, monthNow, yearNow, i_use_digital_root) : 0
numerologyScore6 = i_use_date_numerology ? f_score_date_numerology(6, dayNow, monthNow, yearNow, i_use_digital_root) : 0
numerologyScore9 = i_use_date_numerology ? f_score_date_numerology(9, dayNow, monthNow, yearNow, i_use_digital_root) : 0

loShuScore3 = i_use_lo_shu ? f_score_lo_shu(3, dayNow, monthNow, hhmmNow, close, syminfo.mintick, barNumber) : 0
loShuScore6 = i_use_lo_shu ? f_score_lo_shu(6, dayNow, monthNow, hhmmNow, close, syminfo.mintick, barNumber) : 0
loShuScore9 = i_use_lo_shu ? f_score_lo_shu(9, dayNow, monthNow, hhmmNow, close, syminfo.mintick, barNumber) : 0

vortexScore3 = i_use_vortex ? f_score_vortex(3, barNumber, minutesFromOpen, hhmmNow) : 0
vortexScore6 = i_use_vortex ? f_score_vortex(6, barNumber, minutesFromOpen, hhmmNow) : 0
vortexScore9 = i_use_vortex ? f_score_vortex(9, barNumber, minutesFromOpen, hhmmNow) : 0

teslaCurrentTriad = baseHit3 and baseHit6 and baseHit9
teslaRecentTriad = memoryComplete
teslaTriadScore = i_use_tesla_triad and (teslaCurrentTriad or teslaRecentTriad) ? 7 : 0
teslaScore3 = teslaTriadScore
teslaScore6 = teslaTriadScore
teslaScore9 = teslaTriadScore

repeatedScore3 = i_use_repeated_digits ? f_score_repeated_digits(3, hhmmNow, closeUnits, barNumber) : 0
repeatedScore6 = i_use_repeated_digits ? f_score_repeated_digits(6, hhmmNow, closeUnits, barNumber) : 0
repeatedScore9 = i_use_repeated_digits ? f_score_repeated_digits(9, hhmmNow, closeUnits, barNumber) : 0

mirrorScore3 = i_use_mirror_numbers ? f_score_mirror_numbers(3, hhmmNow, closeUnits, barNumber) : 0
mirrorScore6 = i_use_mirror_numbers ? f_score_mirror_numbers(6, hhmmNow, closeUnits, barNumber) : 0
mirrorScore9 = i_use_mirror_numbers ? f_score_mirror_numbers(9, hhmmNow, closeUnits, barNumber) : 0

planetaryScore3 = i_use_planetary_numerology ? f_score_planetary_numerology(3, dayOfWeekNow, hourNow, dayNow, monthNow, yearNow) : 0
planetaryScore6 = i_use_planetary_numerology ? f_score_planetary_numerology(6, dayOfWeekNow, hourNow, dayNow, monthNow, yearNow) : 0
planetaryScore9 = i_use_planetary_numerology ? f_score_planetary_numerology(9, dayOfWeekNow, hourNow, dayNow, monthNow, yearNow) : 0

score3 = baseScore3 + sequenceScore3 + sessionScore3 + clusterScore3 + memoryScore3 + numerologyScore3 + loShuScore3 + vortexScore3 + teslaScore3 + repeatedScore3 + mirrorScore3 + planetaryScore3
score6 = baseScore6 + sequenceScore6 + sessionScore6 + clusterScore6 + memoryScore6 + numerologyScore6 + loShuScore6 + vortexScore6 + teslaScore6 + repeatedScore6 + mirrorScore6 + planetaryScore6
score9 = baseScore9 + sequenceScore9 + sessionScore9 + clusterScore9 + memoryScore9 + numerologyScore9 + loShuScore9 + vortexScore9 + teslaScore9 + repeatedScore9 + mirrorScore9 + planetaryScore9

sourceTimeScore = timeScore3 + timeScore6 + timeScore9
sourcePriceScore = priceScore3 + priceScore6 + priceScore9
sourceCycleScore = cycleScore3 + cycleScore6 + cycleScore9
sourceVolumeScore = volumeScore3 + volumeScore6 + volumeScore9
sourceSequenceScore = sequenceScore3 + sequenceScore6 + sequenceScore9
sourceSessionScore = sessionScore3 + sessionScore6 + sessionScore9
sourceClusterScore = clusterScore3 + clusterScore6 + clusterScore9
sourceMemoryScore = memoryScore3 + memoryScore6 + memoryScore9
sourceNumerologyScore = numerologyScore3 + numerologyScore6 + numerologyScore9
sourceLoShuScore = loShuScore3 + loShuScore6 + loShuScore9
sourceVortexScore = vortexScore3 + vortexScore6 + vortexScore9
sourceTeslaScore = teslaScore3 + teslaScore6 + teslaScore9
sourceRepeatedScore = repeatedScore3 + repeatedScore6 + repeatedScore9
sourceMirrorScore = mirrorScore3 + mirrorScore6 + mirrorScore9
sourcePlanetaryScore = planetaryScore3 + planetaryScore6 + planetaryScore9

totalScore = score3 + score6 + score9
baseEnabledGroups = (i_use_time ? 1 : 0) + (i_use_price ? 1 : 0) + (i_use_cycle ? 1 : 0) + (i_use_volume ? 1 : 0)
enabledSourceGroups = baseEnabledGroups + (i_use_sequence_ladder and baseEnabledGroups > 0 ? 1 : 0) + (i_use_session_cycle ? 1 : 0) + (i_use_cluster_scoring and baseEnabledGroups >= 2 ? 1 : 0) + (i_use_sequence_memory and baseEnabledGroups > 0 ? 1 : 0) + (i_use_date_numerology ? 1 : 0) + (i_use_lo_shu ? 1 : 0) + (i_use_vortex ? 1 : 0) + (i_use_tesla_triad and baseEnabledGroups > 0 ? 1 : 0) + (i_use_repeated_digits ? 1 : 0) + (i_use_mirror_numbers ? 1 : 0) + (i_use_planetary_numerology ? 1 : 0)
activeSourceGroups = math.max(enabledSourceGroups, 1)
maxNumberScore = math.max(score3, math.max(score6, score9))
maxSourceScore = math.max(sourceTimeScore, math.max(sourcePriceScore, math.max(sourceCycleScore, math.max(sourceVolumeScore, math.max(sourceSequenceScore, math.max(sourceSessionScore, math.max(sourceClusterScore, math.max(sourceMemoryScore, math.max(sourceNumerologyScore, math.max(sourceLoShuScore, math.max(sourceVortexScore, math.max(sourceTeslaScore, math.max(sourceRepeatedScore, math.max(sourceMirrorScore, sourcePlanetaryScore))))))))))))))
autoTotalPercentile = i_auto_profile == "More signals" ? 70 : i_auto_profile == "Selective" ? 90 : 82
autoNumberPercentile = i_auto_profile == "More signals" ? 58 : i_auto_profile == "Selective" ? 78 : 68
autoSourcePercentile = i_auto_profile == "More signals" ? 45 : i_auto_profile == "Selective" ? 65 : 55
autoMinSources = i_auto_profile == "More signals" ? activeSourceGroups <= 8 ? 1 : 2 : i_auto_profile == "Selective" ? activeSourceGroups <= 4 ? 2 : activeSourceGroups <= 12 ? 3 : 4 : activeSourceGroups <= 3 ? 1 : activeSourceGroups <= 10 ? 2 : 3
autoMinNumbers = i_auto_profile == "More signals" ? 1 : i_auto_profile == "Selective" ? i_min_numbers : math.min(i_min_numbers, 2)
fallbackSourceScore = i_auto_profile == "More signals" ? 4 : i_auto_profile == "Selective" ? 7 : 5
fallbackNumberScore = i_auto_profile == "More signals" ? 6 : i_auto_profile == "Selective" ? 12 : 8
fallbackTotalScore = i_auto_profile == "More signals" ? 22 : i_auto_profile == "Selective" ? 42 : 30
learnedSourceScore = int(math.round(nz(ta.percentile_nearest_rank(maxSourceScore[1], i_auto_lookback, autoSourcePercentile), fallbackSourceScore)))
learnedNumberScore = int(math.round(nz(ta.percentile_nearest_rank(maxNumberScore[1], i_auto_lookback, autoNumberPercentile), fallbackNumberScore)))
learnedTotalScore = int(math.round(nz(ta.percentile_nearest_rank(totalScore[1], i_auto_lookback, autoTotalPercentile), fallbackTotalScore)))
effectiveMinSources = math.min(i_auto_filters ? autoMinSources : i_min_sources, activeSourceGroups)
effectiveMinSourceScore = i_auto_filters ? f_clamp_int(learnedSourceScore, 4, 12) : i_min_source_score
effectiveMinNumbers = i_auto_filters ? autoMinNumbers : i_min_numbers
effectiveMinNumberScore = i_auto_filters ? f_clamp_int(learnedNumberScore, 6, 22) : i_min_number_score
effectiveMinTotalScore = i_auto_filters ? math.max(fallbackTotalScore, math.max(effectiveMinNumberScore * effectiveMinNumbers, learnedTotalScore)) : i_min_total_score

hit3 = score3 >= effectiveMinNumberScore
hit6 = score6 >= effectiveMinNumberScore
hit9 = score9 >= effectiveMinNumberScore
matchedNumbers = (hit3 ? 1 : 0) + (hit6 ? 1 : 0) + (hit9 ? 1 : 0)
timeSourceHit = i_use_time and math.max(timeScore3, math.max(timeScore6, timeScore9)) >= effectiveMinSourceScore
priceSourceHit = i_use_price and math.max(priceScore3, math.max(priceScore6, priceScore9)) >= effectiveMinSourceScore
cycleSourceHit = i_use_cycle and math.max(cycleScore3, math.max(cycleScore6, cycleScore9)) >= effectiveMinSourceScore
volumeSourceHit = i_use_volume and math.max(volumeScore3, math.max(volumeScore6, volumeScore9)) >= effectiveMinSourceScore
sequenceSourceHit = i_use_sequence_ladder and math.max(sequenceScore3, math.max(sequenceScore6, sequenceScore9)) >= effectiveMinSourceScore
sessionSourceHit = i_use_session_cycle and math.max(sessionScore3, math.max(sessionScore6, sessionScore9)) >= effectiveMinSourceScore
clusterSourceHit = i_use_cluster_scoring and math.max(clusterScore3, math.max(clusterScore6, clusterScore9)) >= effectiveMinSourceScore
memorySourceHit = i_use_sequence_memory and math.max(memoryScore3, math.max(memoryScore6, memoryScore9)) >= effectiveMinSourceScore
numerologySourceHit = i_use_date_numerology and math.max(numerologyScore3, math.max(numerologyScore6, numerologyScore9)) >= effectiveMinSourceScore
loShuSourceHit = i_use_lo_shu and math.max(loShuScore3, math.max(loShuScore6, loShuScore9)) >= effectiveMinSourceScore
vortexSourceHit = i_use_vortex and math.max(vortexScore3, math.max(vortexScore6, vortexScore9)) >= effectiveMinSourceScore
teslaSourceHit = i_use_tesla_triad and math.max(teslaScore3, math.max(teslaScore6, teslaScore9)) >= effectiveMinSourceScore
repeatedSourceHit = i_use_repeated_digits and math.max(repeatedScore3, math.max(repeatedScore6, repeatedScore9)) >= effectiveMinSourceScore
mirrorSourceHit = i_use_mirror_numbers and math.max(mirrorScore3, math.max(mirrorScore6, mirrorScore9)) >= effectiveMinSourceScore
planetarySourceHit = i_use_planetary_numerology and math.max(planetaryScore3, math.max(planetaryScore6, planetaryScore9)) >= effectiveMinSourceScore
matchedSources = (timeSourceHit ? 1 : 0) + (priceSourceHit ? 1 : 0) + (cycleSourceHit ? 1 : 0) + (volumeSourceHit ? 1 : 0) + (sequenceSourceHit ? 1 : 0) + (sessionSourceHit ? 1 : 0) + (clusterSourceHit ? 1 : 0) + (memorySourceHit ? 1 : 0) + (numerologySourceHit ? 1 : 0) + (loShuSourceHit ? 1 : 0) + (vortexSourceHit ? 1 : 0) + (teslaSourceHit ? 1 : 0) + (repeatedSourceHit ? 1 : 0) + (mirrorSourceHit ? 1 : 0) + (planetarySourceHit ? 1 : 0)
rollingPeak = totalScore > nz(ta.highest(totalScore[1], i_peak_lookback), -1)
isCandidate = totalScore >= effectiveMinTotalScore and matchedNumbers >= effectiveMinNumbers and matchedSources >= effectiveMinSources and (not i_require_peak or rollingPeak)
var int lastDotBar = na
cooldownReady = na(lastDotBar) or bar_index - lastDotBar >= i_min_bars_between_dots
isHit = isCandidate and cooldownReady
comboHit = isHit and matchedNumbers >= 2
baseColor = f_hit_color(hit3, hit6, hit9)
markerColor = #FFD700
methodReasons3 = ""
methodReasons3 := f_append_reason(methodReasons3, "Sequential ladder", sequenceScore3 > 0 ? "3 -> 6 -> 9 completed inside " + str.tostring(i_ladder_lookback) + " bars" : "")
methodReasons3 := f_append_reason(methodReasons3, "Session cycle", sessionScore3 > 0 ? f_reason_session_cycle(3, minutesFromOpen, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : "")
methodReasons3 := f_append_reason(methodReasons3, "Sequence memory", memoryScore3 > 0 ? "3, 6, and 9 all appeared inside " + str.tostring(i_memory_lookback) + " bars" : "")
methodReasons3 := f_append_reason(methodReasons3, "Date numerology", numerologyScore3 > 0 ? f_reason_date_numerology(3, dayNow, monthNow, yearNow, i_use_digital_root) : "")
methodReasons3 := f_append_reason(methodReasons3, "Lo Shu", loShuScore3 > 0 ? f_reason_lo_shu(3, dayNow, monthNow, hhmmNow, close, syminfo.mintick, barNumber) : "")
methodReasons3 := f_append_reason(methodReasons3, "Vortex", vortexScore3 > 0 ? f_reason_vortex(3, barNumber, minutesFromOpen, hhmmNow) : "")
methodReasons3 := f_append_reason(methodReasons3, "Tesla triad", teslaScore3 > 0 ? "Full 3-6-9 triad is active" : "")
methodReasons3 := f_append_reason(methodReasons3, "Repeated digits", repeatedScore3 > 0 ? f_reason_repeated_digits(3, hhmmNow, closeUnits, barNumber) : "")
methodReasons3 := f_append_reason(methodReasons3, "Mirror numbers", mirrorScore3 > 0 ? f_reason_mirror_numbers(3, hhmmNow, closeUnits, barNumber) : "")
methodReasons3 := f_append_reason(methodReasons3, "Planetary numerology", planetaryScore3 > 0 ? f_reason_planetary_numerology(3, dayOfWeekNow, hourNow, dayNow, monthNow, yearNow) : "")

methodReasons6 = ""
methodReasons6 := f_append_reason(methodReasons6, "Sequential ladder", sequenceScore6 > 0 ? "3 -> 6 -> 9 completed inside " + str.tostring(i_ladder_lookback) + " bars" : "")
methodReasons6 := f_append_reason(methodReasons6, "Session cycle", sessionScore6 > 0 ? f_reason_session_cycle(6, minutesFromOpen, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : "")
methodReasons6 := f_append_reason(methodReasons6, "Sequence memory", memoryScore6 > 0 ? "3, 6, and 9 all appeared inside " + str.tostring(i_memory_lookback) + " bars" : "")
methodReasons6 := f_append_reason(methodReasons6, "Date numerology", numerologyScore6 > 0 ? f_reason_date_numerology(6, dayNow, monthNow, yearNow, i_use_digital_root) : "")
methodReasons6 := f_append_reason(methodReasons6, "Lo Shu", loShuScore6 > 0 ? f_reason_lo_shu(6, dayNow, monthNow, hhmmNow, close, syminfo.mintick, barNumber) : "")
methodReasons6 := f_append_reason(methodReasons6, "Vortex", vortexScore6 > 0 ? f_reason_vortex(6, barNumber, minutesFromOpen, hhmmNow) : "")
methodReasons6 := f_append_reason(methodReasons6, "Tesla triad", teslaScore6 > 0 ? "Full 3-6-9 triad is active" : "")
methodReasons6 := f_append_reason(methodReasons6, "Repeated digits", repeatedScore6 > 0 ? f_reason_repeated_digits(6, hhmmNow, closeUnits, barNumber) : "")
methodReasons6 := f_append_reason(methodReasons6, "Mirror numbers", mirrorScore6 > 0 ? f_reason_mirror_numbers(6, hhmmNow, closeUnits, barNumber) : "")
methodReasons6 := f_append_reason(methodReasons6, "Planetary numerology", planetaryScore6 > 0 ? f_reason_planetary_numerology(6, dayOfWeekNow, hourNow, dayNow, monthNow, yearNow) : "")

methodReasons9 = ""
methodReasons9 := f_append_reason(methodReasons9, "Sequential ladder", sequenceScore9 > 0 ? "3 -> 6 -> 9 completed inside " + str.tostring(i_ladder_lookback) + " bars" : "")
methodReasons9 := f_append_reason(methodReasons9, "Session cycle", sessionScore9 > 0 ? f_reason_session_cycle(9, minutesFromOpen, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples) : "")
methodReasons9 := f_append_reason(methodReasons9, "Sequence memory", memoryScore9 > 0 ? "3, 6, and 9 all appeared inside " + str.tostring(i_memory_lookback) + " bars" : "")
methodReasons9 := f_append_reason(methodReasons9, "Date numerology", numerologyScore9 > 0 ? f_reason_date_numerology(9, dayNow, monthNow, yearNow, i_use_digital_root) : "")
methodReasons9 := f_append_reason(methodReasons9, "Lo Shu", loShuScore9 > 0 ? f_reason_lo_shu(9, dayNow, monthNow, hhmmNow, close, syminfo.mintick, barNumber) : "")
methodReasons9 := f_append_reason(methodReasons9, "Vortex", vortexScore9 > 0 ? f_reason_vortex(9, barNumber, minutesFromOpen, hhmmNow) : "")
methodReasons9 := f_append_reason(methodReasons9, "Tesla triad", teslaScore9 > 0 ? "Full 3-6-9 triad is active" : "")
methodReasons9 := f_append_reason(methodReasons9, "Repeated digits", repeatedScore9 > 0 ? f_reason_repeated_digits(9, hhmmNow, closeUnits, barNumber) : "")
methodReasons9 := f_append_reason(methodReasons9, "Mirror numbers", mirrorScore9 > 0 ? f_reason_mirror_numbers(9, hhmmNow, closeUnits, barNumber) : "")
methodReasons9 := f_append_reason(methodReasons9, "Planetary numerology", planetaryScore9 > 0 ? f_reason_planetary_numerology(9, dayOfWeekNow, hourNow, dayNow, monthNow, yearNow) : "")

baseReasons3 = f_number_reasons(3, hourNow, minuteNow, dayNow, monthNow, yearNow, open, close, syminfo.mintick, barNumber, volume, i_use_volume, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples)
baseReasons6 = f_number_reasons(6, hourNow, minuteNow, dayNow, monthNow, yearNow, open, close, syminfo.mintick, barNumber, volume, i_use_volume, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples)
baseReasons9 = f_number_reasons(9, hourNow, minuteNow, dayNow, monthNow, yearNow, open, close, syminfo.mintick, barNumber, volume, i_use_volume, i_use_digit_sum, i_use_digital_root, i_use_digits, i_use_multiples)
reasons3 = hit3 ? baseReasons3 + (methodReasons3 != "" ? "\n" + methodReasons3 : "") : ""
reasons6 = hit6 ? baseReasons6 + (methodReasons6 != "" ? "\n" + methodReasons6 : "") : ""
reasons9 = hit9 ? baseReasons9 + (methodReasons9 != "" ? "\n" + methodReasons9 : "") : ""

// ----------------------------------------------------------------------
// Visual output
// ----------------------------------------------------------------------

var array<label> hitDots = array.new<label>()
if i_show_dots and isHit and barstate.isconfirmed
    bool dotAbove = i_dot_side == "Above candle"
    float dotY = dotAbove ? close + atrNow * i_dot_offset : close - atrNow * i_dot_offset
    labelSize = i_dot_size == "Tiny" ? size.tiny : i_dot_size == "Small" ? size.small : i_dot_size == "Normal" ? size.normal : i_dot_size == "Large" ? size.large : size.huge
    label newDot = label.new(bar_index, dotY, "◆",
         style=label.style_none, textcolor=markerColor, color=color.new(markerColor, 100), size=labelSize,
         tooltip=f_dot_tooltip(score3, score6, score9, totalScore, matchedNumbers, matchedSources, effectiveMinNumberScore, effectiveMinTotalScore, effectiveMinSources, sourceTimeScore, sourcePriceScore, sourceCycleScore, sourceVolumeScore, sourceSequenceScore, sourceSessionScore, sourceClusterScore, sourceMemoryScore, sourceNumerologyScore, sourceLoShuScore, sourceVortexScore, sourceTeslaScore, sourceRepeatedScore, sourceMirrorScore, sourcePlanetaryScore, reasons3, reasons6, reasons9))
    array.push(hitDots, newDot)
    if array.size(hitDots) > i_max_dots
        label oldDot = array.shift(hitDots)
        label.delete(oldDot)
    lastDotBar := bar_index

// ----------------------------------------------------------------------
// Alerts
// ----------------------------------------------------------------------

alertcondition(isHit, title="3-6-9 occurrence", message="A prominent 3-6-9 occurrence was detected.")
````
