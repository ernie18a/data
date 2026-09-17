<!-- tradingview-pine-id: PUB;051a9749bbd34685b09041feab1fcec3 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_Core_Utilities

Source: https://www.tradingview.com/script/4qjmqBNI-XZ-Core-Utilities/

## Description

Library  "XZ_Core_Utilities"
Generic formatting, identifier parsing and neutral geometry helpers for XZ scripts. Contains no XZ methodology or analytical authority.

csvContainsPositiveInt(objectId, csvIds)
  Returns true when a positive integer ID occurs as a comma-separated token.
  Parameters:
    objectId (int): Positive integer to search for.
    csvIds (string): Comma-separated integer text. Spaces are ignored.
  Returns: True when objectId occurs as an exact parsed token.

csvFirstPositiveInt(csvIds)
  Returns the first positive integer token in comma-separated text.
  Parameters:
    csvIds (string): Comma-separated integer text. Spaces are ignored.
  Returns: First parsed positive integer, or 0 when none exists.

nearDuplicateBounds(lowA, highA, lowB, highB, tolerancePct)
  Tests whether two low/high geometries are near-duplicates under a supplied percentage tolerance.
  Parameters:
    lowA (float): First lower bound.
    highA (float): First upper bound.
    lowB (float): Second lower bound.
    highB (float): Second upper bound.
    tolerancePct (float): Tolerance as a percentage of the wider geometry.
  Returns: True when both corresponding boundaries fall within the calculated tolerance.

formatDate(eventTime, timezone)
  Formats a timestamp as yyyy-MM-dd in the supplied timezone.
  Parameters:
    eventTime (int): UNIX timestamp in milliseconds.
    timezone (string): Timezone string accepted by str.format_time().
  Returns: Formatted date, or an em dash for na.

formatPercent(value)
  Formats a percentage value with up to two decimals.
  Parameters:
    value (float): Percentage value.
  Returns: Percentage text, or an em dash for na.

formatSignedPercent(value)
  Formats a signed percentage value with up to two decimals.
  Parameters:
    value (float): Percentage value.
  Returns: Signed percentage text, or an em dash for na.

timeframeLabel(tf)
  Converts common TradingView timeframe strings into compact readable labels.
  Parameters:
    tf (string): TradingView timeframe string.
  Returns: Compact label such as 1D, 1W, 4H or 15m.

formatDistance(distance, useTicks, minTick)
  Formats an absolute price distance as points or ticks. Unit policy is supplied by the caller.
  Parameters:
    distance (float): Raw price distance.
    useTicks (bool): True to convert distance to ticks.
    minTick (float): Instrument minimum tick.
  Returns: Formatted absolute distance with explicit unit.

directionalMovePct(fromPrice, toPrice, minTick)
  Calculates signed percentage move from one price to another.
  Parameters:
    fromPrice (float): Chronological starting price.
    toPrice (float): Chronological ending price.
    minTick (float): Instrument minimum tick used to reject a near-zero denominator.
  Returns: Signed percentage move, or na when unavailable.

normalizedPositionPct(currentValue, lowPrice, highPrice)
  Calculates normalized position of a value within low-to-high geometry.
  Parameters:
    currentValue (float): Value being located.
    lowPrice (float): Geometry lower bound.
    highPrice (float): Geometry upper bound.
  Returns: Position percentage where 0 is the lower bound and 100 is the upper bound. Values may fall outside 0-100.

formatElapsedDays(fromTime, toTime)
  Formats elapsed milliseconds between two timestamps as fractional days.
  Parameters:
    fromTime (int): Starting timestamp.
    toTime (int): Ending timestamp.
  Returns: Day text with singular/plural unit, or an em dash when invalid.

quartilePrice(low, high, levelIndex)
  Returns one of five equally spaced 0/25/50/75/100 geometry levels.
  Parameters:
    low (float): Lower geometry bound.
    high (float): Upper geometry bound.
    levelIndex (int): Integer level index from 0 to 4.
  Returns: Price at the requested quartile level.

quartileText(levelIndex)
  Returns the display text for quartile level index 0-4.
  Parameters:
    levelIndex (int): Integer level index from 0 to 4.
  Returns: 0%, 25%, 50%, 75% or 100%.

appendUniqueToken(current, token, separator)
  Appends a token only when it is not already present in a separator-delimited string.
  Parameters:
    current (string): Existing token string.
    token (string): Token to append.
    separator (string): Delimiter between tokens.
  Returns: Original or extended token string.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign

//@version=6
//@description Generic formatting, identifier parsing and neutral geometry helpers for XZ scripts. Contains no XZ methodology or analytical authority.
library("XZ_Core_Utilities", true)

//@function Returns true when a positive integer ID occurs as a comma-separated token.
//@param objectId Positive integer to search for.
//@param csvIds Comma-separated integer text. Spaces are ignored.
//@returns True when objectId occurs as an exact parsed token.
export csvContainsPositiveInt(int objectId, string csvIds) =>
    bool requested = false
    if objectId > 0 and str.length(csvIds) > 0
        string compactIds = str.replace_all(csvIds, " ", "")
        array<string> tokens = str.split(compactIds, ",")
        if array.size(tokens) > 0
            for t = 0 to array.size(tokens) - 1
                float parsed = str.tonumber(array.get(tokens, t))
                if not na(parsed) and int(parsed) == objectId
                    requested := true
                    break
    requested

//@function Returns the first positive integer token in comma-separated text.
//@param csvIds Comma-separated integer text. Spaces are ignored.
//@returns First parsed positive integer, or 0 when none exists.
export csvFirstPositiveInt(string csvIds) =>
    int result = 0
    if str.length(csvIds) > 0
        string compactIds = str.replace_all(csvIds, " ", "")
        array<string> tokens = str.split(compactIds, ",")
        if array.size(tokens) > 0
            for t = 0 to array.size(tokens) - 1
                float parsed = str.tonumber(array.get(tokens, t))
                if not na(parsed) and int(parsed) > 0
                    result := int(parsed)
                    break
    result

//@function Tests whether two low/high geometries are near-duplicates under a supplied percentage tolerance.
//@param lowA First lower bound.
//@param highA First upper bound.
//@param lowB Second lower bound.
//@param highB Second upper bound.
//@param tolerancePct Tolerance as a percentage of the wider geometry.
//@returns True when both corresponding boundaries fall within the calculated tolerance.
export nearDuplicateBounds(float lowA, float highA, float lowB, float highB, float tolerancePct) =>
    bool valid = not na(lowA) and not na(highA) and not na(lowB) and not na(highB) and highA > lowA and highB > lowB
    bool result = false
    if valid
        float widthRef = math.max(highA - lowA, highB - lowB)
        float tolerance = widthRef * tolerancePct / 100.0
        result := math.abs(lowA - lowB) <= tolerance and math.abs(highA - highB) <= tolerance
    result

//@function Formats a timestamp as yyyy-MM-dd in the supplied timezone.
//@param eventTime UNIX timestamp in milliseconds.
//@param timezone Timezone string accepted by str.format_time().
//@returns Formatted date, or an em dash for na.
export formatDate(int eventTime, string timezone) =>
    na(eventTime) ? "—" : str.format_time(eventTime, "yyyy-MM-dd", timezone)

//@function Formats a percentage value with up to two decimals.
//@param value Percentage value.
//@returns Percentage text, or an em dash for na.
export formatPercent(float value) =>
    na(value) ? "—" : str.tostring(value, "#.##") + "%"

//@function Formats a signed percentage value with up to two decimals.
//@param value Percentage value.
//@returns Signed percentage text, or an em dash for na.
export formatSignedPercent(float value) =>
    na(value) ? "—" : (value > 0 ? "+" : "") + str.tostring(value, "#.##") + "%"

//@function Converts common TradingView timeframe strings into compact readable labels.
//@param tf TradingView timeframe string.
//@returns Compact label such as 1D, 1W, 4H or 15m.
export timeframeLabel(string tf) =>
    string result = tf
    float numericMinutes = str.tonumber(tf)
    if tf == "D"
        result := "1D"
    else if tf == "W"
        result := "1W"
    else if tf == "M"
        result := "1M"
    else if not na(numericMinutes)
        int wholeMinutes = int(numericMinutes)
        result := wholeMinutes >= 60 and wholeMinutes % 60 == 0 ? str.tostring(int(wholeMinutes / 60)) + "H" : str.tostring(wholeMinutes) + "m"
    result

//@function Formats an absolute price distance as points or ticks. Unit policy is supplied by the caller.
//@param distance Raw price distance.
//@param useTicks True to convert distance to ticks.
//@param minTick Instrument minimum tick.
//@returns Formatted absolute distance with explicit unit.
export formatDistance(float distance, bool useTicks, float minTick) =>
    string result = "—"
    if not na(distance)
        float absoluteDistance = math.abs(distance)
        if useTicks
            float tickCount = minTick > 0 ? math.round(absoluteDistance / minTick) : na
            result := na(tickCount) ? "—" : str.tostring(tickCount, "#") + (math.abs(tickCount - 1.0) < 0.0001 ? " tick" : " ticks")
        else
            result := str.tostring(absoluteDistance, format.mintick) + (math.abs(absoluteDistance - 1.0) < minTick * 0.5 ? " point" : " points")
    result

//@function Calculates signed percentage move from one price to another.
//@param fromPrice Chronological starting price.
//@param toPrice Chronological ending price.
//@param minTick Instrument minimum tick used to reject a near-zero denominator.
//@returns Signed percentage move, or na when unavailable.
export directionalMovePct(float fromPrice, float toPrice, float minTick) =>
    not na(fromPrice) and not na(toPrice) and math.abs(fromPrice) > minTick * 0.5 ? (toPrice - fromPrice) / math.abs(fromPrice) * 100.0 : na

//@function Calculates normalized position of a value within low-to-high geometry.
//@param currentValue Value being located.
//@param lowPrice Geometry lower bound.
//@param highPrice Geometry upper bound.
//@returns Position percentage where 0 is the lower bound and 100 is the upper bound. Values may fall outside 0-100.
export normalizedPositionPct(float currentValue, float lowPrice, float highPrice) =>
    not na(lowPrice) and not na(highPrice) and highPrice > lowPrice and not na(currentValue) ? (currentValue - lowPrice) / (highPrice - lowPrice) * 100.0 : na

//@function Formats elapsed milliseconds between two timestamps as fractional days.
//@param fromTime Starting timestamp.
//@param toTime Ending timestamp.
//@returns Day text with singular/plural unit, or an em dash when invalid.
export formatElapsedDays(int fromTime, int toTime) =>
    string result = "—"
    if not na(fromTime) and not na(toTime) and toTime >= fromTime
        float elapsedDays = float(toTime - fromTime) / 86400000.0
        result := str.tostring(elapsedDays, "#.##") + (math.abs(elapsedDays - 1.0) < 0.0001 ? " day" : " days")
    result

//@function Returns one of five equally spaced 0/25/50/75/100 geometry levels.
//@param low Lower geometry bound.
//@param high Upper geometry bound.
//@param levelIndex Integer level index from 0 to 4.
//@returns Price at the requested quartile level.
export quartilePrice(float low, float high, int levelIndex) =>
    low + (high - low) * (float(levelIndex) * 0.25)

//@function Returns the display text for quartile level index 0-4.
//@param levelIndex Integer level index from 0 to 4.
//@returns 0%, 25%, 50%, 75% or 100%.
export quartileText(int levelIndex) =>
    levelIndex == 0 ? "0%" : levelIndex == 1 ? "25%" : levelIndex == 2 ? "50%" : levelIndex == 3 ? "75%" : "100%"

//@function Appends a token only when it is not already present in a separator-delimited string.
//@param current Existing token string.
//@param token Token to append.
//@param separator Delimiter between tokens.
//@returns Original or extended token string.
export appendUniqueToken(string current, string token, string separator) =>
    string result = current
    if str.length(current) == 0
        result := token
    else
        array<string> existing = str.split(current, separator)
        if array.indexof(existing, token) == -1
            result += separator + token
    result

//@function Parses all positive integer tokens from comma-separated text.
//@param csvIds Comma-separated integer text. Spaces are ignored.
//@returns Array of positive integers in source order.
export csvPositiveInts(string csvIds) =>
    array<int> result = array.new_int()
    if str.length(csvIds) > 0
        string compactIds = str.replace_all(csvIds, " ", "")
        array<string> tokens = str.split(compactIds, ",")
        if array.size(tokens) > 0
            for t = 0 to array.size(tokens) - 1
                float parsed = str.tonumber(array.get(tokens, t))
                if not na(parsed) and int(parsed) > 0
                    array.push(result, int(parsed))
    result

//@function Appends text using a separator only when the base is non-empty.
export appendSeparatedText(string base, string item, string separator) =>
    str.length(base) == 0 ? item : base + separator + item

//@function Pushes a non-negative integer only when absent and capacity remains.
export pushUniqueIntLimited(array<int> values, int value, int limit) =>
    if value >= 0 and array.size(values) < limit and array.indexof(values, value) == -1
        array.push(values, value)
    array.size(values)

//@function Moves/inserts a non-negative integer to the front and enforces a maximum size.
export prioritizeUniqueIntLimited(array<int> values, int value, int limit) =>
    if value >= 0
        int existingPos = array.indexof(values, value)
        if existingPos >= 0
            array.remove(values, existingPos)
        array.unshift(values, value)
        while array.size(values) > limit
            array.pop(values)
    array.size(values)

//@function Resolves an Auto/Points/Ticks policy into a ticks boolean.
export distanceUsesTicks(string unitMode, string instrumentType) =>
    unitMode == "Ticks" or (unitMode == "Auto" and instrumentType == "futures")

//@function Builds a generic normalized-position sentence for a bounded object.
export positionRelationshipText(float currentValue, float lowPrice, float highPrice, string objectName) =>
    float positionPct = normalizedPositionPct(currentValue, lowPrice, highPrice)
    "Live price position in " + objectName + ": " + formatPercent(positionPct)
````
