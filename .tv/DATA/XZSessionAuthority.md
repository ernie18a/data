<!-- tradingview-pine-id: PUB;df993a28207244a0887874c749ebeeea -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_Session_Authority

Source: https://www.tradingview.com/script/6QkVzyv5-XZ-Session-Core/

## Description

Library  "XZ_Session_Authority"
XZ Session Authority v1. Canonical suite-wide session-time authority for XZ indicators. Defines deterministic session standards, DST-aware IANA timezones, fixed session segments, custom-session reconstruction, occurrence keys and overlap masks. It deliberately contains no indicator-specific lifecycle, qualification, Supply/Demand, FVG, IL, market-structure or Research methodology.

sessionCount()
  Number of canonical market-list session indexes used by XZ: Sydney, Tokyo, London, New York.

usesMarketList(standard)
  True when the selected standard uses the canonical four-market session list.
  Parameters:
    standard (simple string)

standardCode(standard)
  Short code for a session standard.
  Parameters:
    standard (simple string)

sessionName(standard, sessionIndex)
  Full display name for one session index.
  Parameters:
    standard (simple string)
    sessionIndex (int)

sessionCode(standard, sessionIndex)
  Compact display code for one session index.
  Parameters:
    standard (simple string)
    sessionIndex (int)

sessionTimezone(standard, sessionIndex, customTimezone, symbolTimezone)
  Authoritative timezone for one session index.
  Parameters:
    standard (simple string)
    sessionIndex (int)
    customTimezone (simple string)
    symbolTimezone (simple string)

isLocalWeekday(timestampValue, tz)
  True when timestampValue is Monday-Friday in tz.
  Parameters:
    timestampValue (int)
    tz (string)

occurrenceKey(timestampValue, tz)
  Stable YYYYMMDD occurrence key in the supplied timezone.
  Parameters:
    timestampValue (int)
    tz (string)

segmentCount(standard, sessionIndex)
  Number of finite fixed segments for one market session occurrence. Tokyo Exchange Cash Hours uses two segments so the lunch break remains real.
  Parameters:
    standard (simple string)
    sessionIndex (int)

segmentBounds(standard, sessionIndex, segmentIndex, timestampValue, customTimezone, symbolTimezone)
  Market Centres and Exchange Cash Hours use fixed local schedules plus IANA timezone/DST authority. Consumers must not use this helper to infer exchange holidays or early closes on unrelated symbols.
  Parameters:
    standard (simple string)
    sessionIndex (int)
    segmentIndex (int)
    timestampValue (int)
    customTimezone (simple string)
    symbolTimezone (simple string)

customSpec(openHHMM, closeHHMM, weekdaysOnly)
  Reconstructs a Pine custom-session string from vertically stacked HHMM inputs.
  Parameters:
    openHHMM (simple string)
    closeHHMM (simple string)
    weekdaysOnly (simple bool)

sessionBit(sessionIndex)
  Bit assigned to one canonical session index.
  Parameters:
    sessionIndex (int)

maskHas(sessionMask, sessionIndex)
  Tests membership in the canonical four-session bit mask.
  Parameters:
    sessionMask (int)
    sessionIndex (int)

maskAdd(sessionMask, sessionIndex)
  Adds one canonical session index to a four-session bit mask.
  Parameters:
    sessionMask (int)
    sessionIndex (int)

maskIntersection(firstMask, secondMask)
  Intersection of two canonical session masks.
  Parameters:
    firstMask (int)
    secondMask (int)

maskCount(sessionMask)
  Number of active session bits in a mask.
  Parameters:
    sessionMask (int)

maskIsOverlap(sessionMask)
  True when more than one canonical session is active in a mask.
  Parameters:
    sessionMask (int)

singleSessionIndex(sessionMask)
  Returns the session index only when exactly one session bit is set; otherwise -1.
  Parameters:
    sessionMask (int)

maskCode(standard, sessionMask)
  Compact human-readable code for a session mask.
  Parameters:
    standard (simple string)
    sessionMask (int)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign
//@version=6

//@description XZ Session Authority v2. Canonical suite-wide session-time authority for XZ indicators. Defines deterministic session standards, DST-aware IANA timezones, fixed session segments, custom-session reconstruction, occurrence keys, overlap masks and timestamp-to-active-mask resolution. It deliberately contains no indicator-specific lifecycle, qualification, Supply/Demand, FVG, IL, market-structure, Auction Engine or Research methodology.
library("XZ_Session_Authority", false)

//==============================================================================
// XZ SESSION AUTHORITY v2
//==============================================================================
// v2 adds activeMaskAt(): a generic timestamp -> canonical market-session mask
// resolver built entirely from the existing session schedules/segment authority.
// No indicator-specific analytical semantics are introduced.
//==============================================================================

const int SESSION_COUNT = 4

//@function Number of canonical market-list session indexes used by XZ: Sydney, Tokyo, London, New York.
export sessionCount() =>
    SESSION_COUNT

//@function True when the selected standard uses the canonical four-market session list.
export usesMarketList(simple string standard) =>
    standard == "Market Centres (FX)" or standard == "Exchange Cash Hours"

//@function Short code for a session standard.
export standardCode(simple string standard) =>
    switch standard
        "Exchange Cash Hours" => "EXCH"
        "Symbol Native" => "NATIVE"
        "Custom" => "CUSTOM"
        => "FX"

//@function Full display name for one session index.
export sessionName(simple string standard, int sessionIndex) =>
    if standard == "Symbol Native"
        "Symbol Native"
    else if standard == "Custom"
        "Custom"
    else
        switch sessionIndex
            0 => "Sydney"
            1 => "Tokyo"
            2 => "London"
            => "New York"

//@function Compact display code for one session index.
export sessionCode(simple string standard, int sessionIndex) =>
    if standard == "Symbol Native"
        "NAT"
    else if standard == "Custom"
        "CUS"
    else
        switch sessionIndex
            0 => "SYD"
            1 => "TYO"
            2 => "LDN"
            => "NY"

//@function Authoritative timezone for one session index.
export sessionTimezone(simple string standard, int sessionIndex, simple string customTimezone, simple string symbolTimezone) =>
    if standard == "Symbol Native"
        symbolTimezone
    else if standard == "Custom"
        customTimezone
    else
        switch sessionIndex
            0 => "Australia/Sydney"
            1 => "Asia/Tokyo"
            2 => "Europe/London"
            => "America/New_York"

//@function True when timestampValue is Monday-Friday in tz.
export isLocalWeekday(int timestampValue, string tz) =>
    int localDOW = dayofweek(timestampValue, tz)
    localDOW >= dayofweek.monday and localDOW <= dayofweek.friday

//@function Stable YYYYMMDD occurrence key in the supplied timezone.
export occurrenceKey(int timestampValue, string tz) =>
    year(timestampValue, tz) * 10000 + month(timestampValue, tz) * 100 + dayofmonth(timestampValue, tz)

//@function Number of finite fixed segments for one market session occurrence. Tokyo Exchange Cash Hours uses two segments so the lunch break remains real.
export segmentCount(simple string standard, int sessionIndex) =>
    standard == "Exchange Cash Hours" and sessionIndex == 1 ? 2 : 1

_sessionOpenMinutes(simple string standard, int sessionIndex, int segmentIndex) =>
    int result = 0
    if standard == "Exchange Cash Hours"
        if sessionIndex == 0
            result := 10 * 60
        else if sessionIndex == 1
            result := segmentIndex == 0 ? 9 * 60 : 12 * 60 + 30
        else if sessionIndex == 2
            result := 8 * 60
        else
            result := 9 * 60 + 30
    else
        if sessionIndex == 0
            result := 7 * 60
        else if sessionIndex == 1
            result := 9 * 60
        else if sessionIndex == 2
            result := 8 * 60
        else
            result := 8 * 60
    result

_sessionCloseMinutes(simple string standard, int sessionIndex, int segmentIndex) =>
    int result = 0
    if standard == "Exchange Cash Hours"
        if sessionIndex == 0
            result := 16 * 60
        else if sessionIndex == 1
            result := segmentIndex == 0 ? 11 * 60 + 30 : 15 * 60 + 30
        else if sessionIndex == 2
            result := 16 * 60 + 30
        else
            result := 16 * 60
    else
        if sessionIndex == 0
            result := 16 * 60
        else if sessionIndex == 1
            result := 18 * 60
        else if sessionIndex == 2
            result := 17 * 60
        else
            result := 17 * 60
    result

//@function Returns [openTime, closeTime, validWeekday, occurrenceKey] for a fixed market-list session segment containing the date of timestampValue. Market Centres and Exchange Cash Hours use fixed local schedules plus IANA timezone/DST authority. Consumers must not use this helper to infer exchange holidays or early closes on unrelated symbols.
export segmentBounds(simple string standard, int sessionIndex, int segmentIndex, int timestampValue, simple string customTimezone, simple string symbolTimezone) =>
    string tz = sessionTimezone(standard, sessionIndex, customTimezone, symbolTimezone)
    int localYear = year(timestampValue, tz)
    int localMonth = month(timestampValue, tz)
    int localDay = dayofmonth(timestampValue, tz)
    int openMinutes = _sessionOpenMinutes(standard, sessionIndex, segmentIndex)
    int closeMinutes = _sessionCloseMinutes(standard, sessionIndex, segmentIndex)
    int openTime = timestamp(tz, localYear, localMonth, localDay, int(math.floor(openMinutes / 60)), openMinutes % 60, 0)
    int closeTime = timestamp(tz, localYear, localMonth, localDay, int(math.floor(closeMinutes / 60)), closeMinutes % 60, 0)
    bool validDay = isLocalWeekday(timestampValue, tz)
    int key = localYear * 10000 + localMonth * 100 + localDay
    [openTime, closeTime, validDay, key]

//@function Reconstructs a Pine custom-session string from vertically stacked HHMM inputs.
export customSpec(simple string openHHMM, simple string closeHHMM, simple bool weekdaysOnly) =>
    openHHMM + "-" + closeHHMM + (weekdaysOnly ? ":23456" : ":1234567")

//@function Bit assigned to one canonical session index.
export sessionBit(int sessionIndex) =>
    sessionIndex == 0 ? 1 : sessionIndex == 1 ? 2 : sessionIndex == 2 ? 4 : 8

//@function Tests membership in the canonical four-session bit mask.
export maskHas(int sessionMask, int sessionIndex) =>
    int bit = sessionBit(sessionIndex)
    int(sessionMask / bit) % 2 == 1

//@function Adds one canonical session index to a four-session bit mask.
export maskAdd(int sessionMask, int sessionIndex) =>
    maskHas(sessionMask, sessionIndex) ? sessionMask : sessionMask + sessionBit(sessionIndex)

//@function Intersection of two canonical session masks.
export maskIntersection(int firstMask, int secondMask) =>
    int result = 0
    for sessionIndex = 0 to SESSION_COUNT - 1
        if maskHas(firstMask, sessionIndex) and maskHas(secondMask, sessionIndex)
            result := maskAdd(result, sessionIndex)
    result

//@function Number of active session bits in a mask.
export maskCount(int sessionMask) =>
    int count = 0
    for sessionIndex = 0 to SESSION_COUNT - 1
        if maskHas(sessionMask, sessionIndex)
            count += 1
    count

//@function True when more than one canonical session is active in a mask.
export maskIsOverlap(int sessionMask) =>
    maskCount(sessionMask) > 1

//@function Returns the session index only when exactly one session bit is set; otherwise -1.
export singleSessionIndex(int sessionMask) =>
    sessionMask == 1 ? 0 : sessionMask == 2 ? 1 : sessionMask == 4 ? 2 : sessionMask == 8 ? 3 : -1

//@function Compact human-readable code for a session mask.
export maskCode(simple string standard, int sessionMask) =>
    if sessionMask == 0
        "NONE"
    else if not usesMarketList(standard)
        sessionCode(standard, 0)
    else
        string result = ""
        for sessionIndex = 0 to SESSION_COUNT - 1
            if maskHas(sessionMask, sessionIndex)
                result += (str.length(result) > 0 ? "+" : "") + sessionCode(standard, sessionIndex)
        result

//@function Resolves the canonical active-session mask at timestampValue for Market Centres (FX) or Exchange Cash Hours. Returns zero outside those market-list sessions, on local weekends, or for non-market-list standards. This is clock classification only and carries no indicator-specific analytical authority.
export activeMaskAt(simple string standard, int timestampValue) =>
    int result = 0
    if usesMarketList(standard) and not na(timestampValue)
        for sessionIndex = 0 to SESSION_COUNT - 1
            bool active = false
            int segmentN = segmentCount(standard, sessionIndex)
            for segmentIndex = 0 to segmentN - 1
                [openTime, closeTime, validWeekday, key] = segmentBounds(standard, sessionIndex, segmentIndex, timestampValue, "Etc/UTC", "Etc/UTC")
                if validWeekday and timestampValue >= openTime and timestampValue < closeTime
                    active := true
            if active
                result := maskAdd(result, sessionIndex)
    result
````
