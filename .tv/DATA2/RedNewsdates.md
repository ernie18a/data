<!-- tradingview-pine-id: PUB;d4a1faf311584d52ac57070521fa60ca -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Red_News_dates

Source: https://www.tradingview.com/script/5wN4xOz4-Red-News-dates/

## Description

Library  "Red_News_Dates"
A simple library that returns Red New Dates

To use:

import WeeklyPivots/Red_News_Dates/3 as news

Then to see if today is NFP:

nfpDAY = news.nfpDAY() 

It also exports ppiDAY, cpiDAY, salesDAY, EUinterestDAY, DAXholidayDAY and DAXholidayDAYearly. DAXholidayDAYearly is true the day before.

Also fomcDAY

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © WeeklyPivots

//@version=6

library("Red_News_dates" , overlay=true)

// NFP

export nfpDAY() =>

    var nfpDAY = false
    var nfp_Array = array.new_string(0)

    //nfp_Array = array.new_int()

    if barstate.isfirst

        array.push(nfp_Array, "2026-01-09")
        array.push(nfp_Array, "2026-02-11")
        array.push(nfp_Array, "2026-03-06")
        array.push(nfp_Array, "2026-04-03")
        array.push(nfp_Array, "2026-05-08")
        array.push(nfp_Array, "2026-06-05")
        array.push(nfp_Array, "2026-07-02")
        array.push(nfp_Array, "2026-08-07")
        array.push(nfp_Array, "2026-09-04")
        array.push(nfp_Array, "2026-10-02")
        array.push(nfp_Array, "2026-11-06")
        array.push(nfp_Array, "2026-12-04")

        array.push(nfp_Array, '2025-01-10')
        array.push(nfp_Array, "2025-02-07")
        array.push(nfp_Array, "2025-03-07")
        array.push(nfp_Array, "2025-04-04")
        array.push(nfp_Array, "2025-05-02")
        array.push(nfp_Array, "2025-06-06")
        array.push(nfp_Array, "2025-07-03")
        array.push(nfp_Array, "2025-08-01")
        array.push(nfp_Array, "2025-09-05")
        //array.push(nfp_Array, "2025-10-03") cancelled due to shutdown
        //array.push(nfp_Array, "2025-11-07") cancelled due to shutdown
        array.push(nfp_Array, "2025-11-20") // Delayed due to shutdowj
        array.push(nfp_Array, "2025-12-16") // Delayed due to shutdowj

        array.push(nfp_Array, "2024-01-05")
        array.push(nfp_Array, "2024-02-02")
        array.push(nfp_Array, "2024-03-08")
        array.push(nfp_Array, "2024-04-05")
        array.push(nfp_Array, "2024-05-03")
        array.push(nfp_Array, "2024-06-07")
        array.push(nfp_Array, "2024-07-05")
        array.push(nfp_Array, "2024-08-02")
        array.push(nfp_Array, "2024-09-06")
        array.push(nfp_Array, "2024-10-04")
        array.push(nfp_Array, "2024-11-01")
        array.push(nfp_Array, "2024-12-06")

        array.push(nfp_Array, "2023-01-06")
        array.push(nfp_Array, "2023-02-03")
        array.push(nfp_Array, "2023-03-10")
        array.push(nfp_Array, "2023-04-07")
        array.push(nfp_Array, "2023-05-05")
        array.push(nfp_Array, "2023-06-02")
        array.push(nfp_Array, "2023-07-07")
        array.push(nfp_Array, "2023-08-01")
        array.push(nfp_Array, "2023-09-06")
        array.push(nfp_Array, "2023-10-03")
        array.push(nfp_Array, "2023-11-03")
        array.push(nfp_Array, "2023-12-08")


    myDate = str.format_time(time, "yyyy-MM-dd", "Europe/London")

    _nfpFound = array.includes(nfp_Array, myDate)

export ppiDAY() =>

    var ppiDAY = false
    var ppi_Array = array.new_string(0)

    if barstate.isfirst

        array.push(ppi_Array, "2026-01-30")
        array.push(ppi_Array, "2026-02-27")
        array.push(ppi_Array, "2026-03-18")
        array.push(ppi_Array, "2026-04-14")
        array.push(ppi_Array, "2026-05-13")
        array.push(ppi_Array, "2026-06-11")
        array.push(ppi_Array, "2026-07-15")
        array.push(ppi_Array, "2026-08-13")
        array.push(ppi_Array, "2026-09-10")
        array.push(ppi_Array, "2026-10-15")
        array.push(ppi_Array, "2026-11-13")
        array.push(ppi_Array, "2026-12-15")

        array.push(ppi_Array, "2025-01-14")
        array.push(ppi_Array, "2025-02-13")
        array.push(ppi_Array, "2025-03-13")
        array.push(ppi_Array, "2025-04-11")
        array.push(ppi_Array, "2025-05-15")
        array.push(ppi_Array, "2025-06-12")
        array.push(ppi_Array, "2025-07-16")
        array.push(ppi_Array, "2025-08-14")
        array.push(ppi_Array, "2025-09-10")
        array.push(ppi_Array, "2025-10-16")
        array.push(ppi_Array, "2025-11-14")
        array.push(ppi_Array, "2025-12-11")

        array.push(ppi_Array, "2024-01-12")
        array.push(ppi_Array, "2024-02-16")
        array.push(ppi_Array, "2024-03-14")
        array.push(ppi_Array, "2024-04-11")
        array.push(ppi_Array, "2024-05-14")
        array.push(ppi_Array, "2024-06-13")
        array.push(ppi_Array, "2024-07-12")
        array.push(ppi_Array, "2024-08-13")
        array.push(ppi_Array, "2024-09-12")
        array.push(ppi_Array, "2024-10-11")
        array.push(ppi_Array, "2024-11-14")
        array.push(ppi_Array, "2024-12-12")

        array.push(ppi_Array, "2023-01-18")
        array.push(ppi_Array, "2023-02-16")
        array.push(ppi_Array, "2023-03-15")
        array.push(ppi_Array, "2023-04-13")
        array.push(ppi_Array, "2023-05-11")
        array.push(ppi_Array, "2023-06-14")
        array.push(ppi_Array, "2023-07-13")
        array.push(ppi_Array, "2023-08-11")
        array.push(ppi_Array, "2023-09-14")
        array.push(ppi_Array, "2023-10-11")
        array.push(ppi_Array, "2023-11-15")
        array.push(ppi_Array, "2023-12-13")

    myDate = str.format_time(time, "yyyy-MM-dd", "Europe/London")

    _ppiFound = array.includes(ppi_Array, myDate)


export cpiDAY() =>

    var cpiDAY = false
    var cpi_Array = array.new_string(0)

    if barstate.isfirst

        array.push(cpi_Array, "2026-01-13")
        array.push(cpi_Array, "2026-02-11")
        array.push(cpi_Array, "2026-03-11")
        array.push(cpi_Array, "2026-04-10")
        array.push(cpi_Array, "2026-05-12")
        array.push(cpi_Array, "2026-06-10")
        array.push(cpi_Array, "2026-07-14")
        array.push(cpi_Array, "2026-08-12")
        array.push(cpi_Array, "2026-09-11")
        array.push(cpi_Array, "2026-10-14")
        array.push(cpi_Array, "2026-11-10")
        array.push(cpi_Array, "2026-12-10")

        array.push(cpi_Array, "2025-01-14")
        array.push(cpi_Array, "2025-02-12")
        array.push(cpi_Array, "2025-03-12")
        array.push(cpi_Array, "2025-04-10")
        array.push(cpi_Array, "2025-05-13")
        array.push(cpi_Array, "2025-06-11")
        array.push(cpi_Array, "2025-07-15")
        array.push(cpi_Array, "2025-08-12")
        array.push(cpi_Array, "2025-09-11")
        array.push(cpi_Array, "2025-10-15")
        array.push(cpi_Array, "2025-11-13")
        array.push(cpi_Array, "2025-12-10")

        array.push(cpi_Array, "2024-01-11")
        array.push(cpi_Array, "2024-02-13")
        array.push(cpi_Array, "2024-03-12")
        array.push(cpi_Array, "2024-04-10")
        array.push(cpi_Array, "2024-05-11")
        array.push(cpi_Array, "2024-06-12")
        array.push(cpi_Array, "2024-07-11")
        array.push(cpi_Array, "2024-08-14")
        array.push(cpi_Array, "2024-09-11")
        array.push(cpi_Array, "2024-10-10")
        array.push(cpi_Array, "2024-11-13")
        array.push(cpi_Array, "2024-12-11")

        array.push(cpi_Array, "2023-01-12")
        array.push(cpi_Array, "2023-02-14")
        array.push(cpi_Array, "2023-03-14")
        array.push(cpi_Array, "2023-04-12")
        array.push(cpi_Array, "2023-05-10")
        array.push(cpi_Array, "2023-06-13")
        array.push(cpi_Array, "2023-07-12")
        array.push(cpi_Array, "2023-08-10")
        array.push(cpi_Array, "2023-09-13")
        array.push(cpi_Array, "2023-10-12")
        array.push(cpi_Array, "2023-11-14")
        array.push(cpi_Array, "2023-12-12")

    myDate = str.format_time(time, "yyyy-MM-dd", "Europe/London")

    _cpiFound = array.includes(cpi_Array, myDate)


export salesDAY() =>

    var salesDAY = false
    var sales_Array = array.new_string(0)

    if barstate.isfirst

        array.push(sales_Array, "2026-01-14")
        array.push(sales_Array, "2026-02-10")
        array.push(sales_Array, "2026-03-06")
        array.push(sales_Array, "2026-04-01")
        array.push(sales_Array, "2026-05-14")
        array.push(sales_Array, "2026-06-17")
        array.push(sales_Array, "2026-07-16")
        array.push(sales_Array, "2026-08-14")
        array.push(sales_Array, "2026-09-16")
        array.push(sales_Array, "2026-10-15")
        array.push(sales_Array, "2026-11-17")
        array.push(sales_Array, "2026-12-16")

        array.push(sales_Array, "2025-01-16")
        array.push(sales_Array, "2025-02-14")
        array.push(sales_Array, "2025-03-17")
        array.push(sales_Array, "2025-04-16")
        array.push(sales_Array, "2025-05-15")
        array.push(sales_Array, "2025-06-17")
        array.push(sales_Array, "2025-07-17")
        array.push(sales_Array, "2025-08-15")
        array.push(sales_Array, "2025-09-16")
        array.push(sales_Array, "2025-10-16")
        array.push(sales_Array, "2025-11-14")
        array.push(sales_Array, "2025-12-17")

        array.push(sales_Array, "2024-01-17")
        array.push(sales_Array, "2024-02-15")
        array.push(sales_Array, "2024-03-14")
        array.push(sales_Array, "2024-04-15")
        array.push(sales_Array, "2024-05-15")
        array.push(sales_Array, "2024-06-18")
        array.push(sales_Array, "2024-07-16")
        array.push(sales_Array, "2024-08-15")
        array.push(sales_Array, "2024-09-17")
        array.push(sales_Array, "2024-10-17")
        array.push(sales_Array, "2024-11-15")
        array.push(sales_Array, "2024-12-17")

        array.push(sales_Array, "2023-01-18")
        array.push(sales_Array, "2023-02-15")
        array.push(sales_Array, "2023-03-15")
        array.push(sales_Array, "2023-04-14")
        array.push(sales_Array, "2023-05-16")
        array.push(sales_Array, "2023-06-15")
        array.push(sales_Array, "2023-07-18")
        array.push(sales_Array, "2023-08-15")
        array.push(sales_Array, "2023-09-14")
        array.push(sales_Array, "2023-10-17")
        array.push(sales_Array, "2023-11-15")
        array.push(sales_Array, "2023-12-14")

    myDate = str.format_time(time, "yyyy-MM-dd", "Europe/London")

    _salesFound = array.includes(sales_Array, myDate)


export EUinterestDAY() =>

    var EUinterestDAY = false
    var EUinterest_Array = array.new_string(0)

    if barstate.isfirst

        array.push(EUinterest_Array, "2026-02-05")
        array.push(EUinterest_Array, "2026-03-19")
        array.push(EUinterest_Array, "2026-04-30")
        array.push(EUinterest_Array, "2026-06-11")
        array.push(EUinterest_Array, "2026-07-23")
        array.push(EUinterest_Array, "2026-09-10")
        array.push(EUinterest_Array, "2026-10-29")
        array.push(EUinterest_Array, "2026-12-17")

        array.push(EUinterest_Array, "2025-01-30")
        array.push(EUinterest_Array, "2025-03-06")
        array.push(EUinterest_Array, "2025-04-17")
        array.push(EUinterest_Array, "2025-06-05")
        array.push(EUinterest_Array, "2025-07-24")
        array.push(EUinterest_Array, "2025-09-11")
        array.push(EUinterest_Array, "2025-10-30")
        array.push(EUinterest_Array, "2025-12-18")

        array.push(EUinterest_Array, "2024-01-25")
        array.push(EUinterest_Array, "2024-03-07")
        array.push(EUinterest_Array, "2024-04-11")
        array.push(EUinterest_Array, "2024-06-06")
        array.push(EUinterest_Array, "2024-07-18")
        array.push(EUinterest_Array, "2024-09-12")
        array.push(EUinterest_Array, "2024-10-17")
        array.push(EUinterest_Array, "2024-12-12")

        array.push(EUinterest_Array, "2023-02-02")
        array.push(EUinterest_Array, "2023-03-16")
        array.push(EUinterest_Array, "2023-04-14")
        array.push(EUinterest_Array, "2023-05-04")
        array.push(EUinterest_Array, "2023-06-15")
        array.push(EUinterest_Array, "2023-07-27")
        array.push(EUinterest_Array, "2023-09-14")
        array.push(EUinterest_Array, "2023-10-26")
        array.push(EUinterest_Array, "2023-12-14")

    myDate = str.format_time(time, "yyyy-MM-dd", "Europe/London")

    _EUinterestFound = array.includes(EUinterest_Array, myDate)


export DAXholidayDAY() =>

    var DAXholidayDAY = false
    var DAXholiday_Array = array.new_string(0)

    if barstate.isfirst

        // All dates are the day before, so it can close @ close time.

        array.push(DAXholiday_Array, "2026-04-02") // Good Friday
        array.push(DAXholiday_Array, "2026-04-05") // Easter Monday
        array.push(DAXholiday_Array, "2026-04-30") // Labour Day
        array.push(DAXholiday_Array, "2026-12-23") // Xmas Eve
        array.push(DAXholiday_Array, "2026-12-24") // Xmas Day
        array.push(DAXholiday_Array, "2026-12-25") // Boxing Day
        array.push(DAXholiday_Array, "2026-12-30") // New Years Eve

        array.push(DAXholiday_Array, "2025-04-17") // Good Friday
        array.push(DAXholiday_Array, "2025-04-20") // Easter Monday
        array.push(DAXholiday_Array, "2025-04-30") // Labour Day
        array.push(DAXholiday_Array, "2025-12-23") // Xmas Eve
        array.push(DAXholiday_Array, "2025-12-24") // Xmas Day
        array.push(DAXholiday_Array, "2025-12-25") // Boxing Day
        array.push(DAXholiday_Array, "2025-12-30") // New Years Eve

        array.push(DAXholiday_Array, "2024-03-28") // Good Friday
        array.push(DAXholiday_Array, "2024-03-31") // Easter Monday
        array.push(DAXholiday_Array, "2024-04-30") // Labour Day
        array.push(DAXholiday_Array, "2024-12-23") // Xmas Eve
        array.push(DAXholiday_Array, "2024-12-24") // Xmas Day
        array.push(DAXholiday_Array, "2024-12-25") // Boxing Day
        array.push(DAXholiday_Array, "2024-12-30") // New Years Eve

        array.push(DAXholiday_Array, "2023-01-01") // New Years
        array.push(DAXholiday_Array, "2023-04-07") // Good Friday
        array.push(DAXholiday_Array, "2023-04-10") // Easter Monday
        array.push(DAXholiday_Array, "2023-05-01") // Labour Day
        array.push(DAXholiday_Array, "2023-12-24") // Xmas Eve
        array.push(DAXholiday_Array, "2023-12-25") // Xmas Day
        array.push(DAXholiday_Array, "2023-12-26") // Boxing Day
        array.push(DAXholiday_Array, "2023-12-31") // New Years Eve

    myDate = str.format_time(time, "yyyy-MM-dd", "Europe/London")

    _DAXholidayFound = array.includes(DAXholiday_Array, myDate)

// Early DAX closes

export DAXholidayDAYearly() =>

    var DAXholidayDAYearly = false
    var DAXholidayEarly_Array = array.new_string(0)

    if barstate.isfirst

        // All dates are the day before, so it can close @ close time.

        array.push(DAXholidayEarly_Array, "2026-12-30") // New Years Eve


        // array.push(DAXholiday_Array, "2025-04-17") // Good Friday
        // array.push(DAXholiday_Array, "2025-04-20") // Easter Monday
        // array.push(DAXholiday_Array, "2025-04-30") // Labour Day
        // array.push(DAXholiday_Array, "2025-12-23") // Xmas Eve
        // array.push(DAXholiday_Array, "2025-12-24") // Xmas Day
        // array.push(DAXholiday_Array, "2025-12-25") // Boxing Day
        array.push(DAXholidayEarly_Array, "2025-12-30") // New Years Eve

        // array.push(DAXholiday_Array, "2024-03-28") // Good Friday
        // array.push(DAXholiday_Array, "2024-03-31") // Easter Monday
        // array.push(DAXholiday_Array, "2024-04-30") // Labour Day
        // array.push(DAXholiday_Array, "2024-12-23") // Xmas Eve
        // array.push(DAXholiday_Array, "2024-12-24") // Xmas Day
        // array.push(DAXholiday_Array, "2024-12-25") // Boxing Day
        array.push(DAXholidayEarly_Array, "2024-12-30") // New Years Eve

        // array.push(DAXholiday_Array, "2023-01-01") // New Years
        // array.push(DAXholiday_Array, "2023-04-07") // Good Friday
        // array.push(DAXholiday_Array, "2023-04-10") // Easter Monday
        // array.push(DAXholiday_Array, "2023-05-01") // Labour Day
        // array.push(DAXholiday_Array, "2023-12-24") // Xmas Eve
        // array.push(DAXholiday_Array, "2023-12-25") // Xmas Day
        // array.push(DAXholiday_Array, "2023-12-26") // Boxing Day
        //array.push(DAXholidayEarly_Array, "2023-12-31") // New Years Eve

    myDate = str.format_time(time, "yyyy-MM-dd", "Europe/London")

    _DAXholidayEarlyFound = array.includes(DAXholidayEarly_Array, myDate)


//FOMC

export fomcDAY() =>

    var fomcDAY = false
    var fomc_Array = array.new_string(0)

    if barstate.isfirst

        array.push(fomc_Array, "2026-01-28")
        array.push(fomc_Array, "2026-03-18")
        array.push(fomc_Array, "2026-04-29")
        array.push(fomc_Array, "2026-06-17")
        array.push(fomc_Array, "2026-07-29")
        array.push(fomc_Array, "2026-09-16")
        array.push(fomc_Array, "2026-10-28")
        array.push(fomc_Array, "2026-12-09")

        array.push(fomc_Array, "2025-12-10")
        array.push(fomc_Array, "2025-10-29")
        array.push(fomc_Array, "2025-09-17")
        array.push(fomc_Array, "2025-07-30")
        array.push(fomc_Array, "2025-06-18")
        array.push(fomc_Array, "2025-05-07")
        array.push(fomc_Array, "2025-03-19")
        array.push(fomc_Array, "2025-01-29")

        array.push(fomc_Array, "2024-12-18")
        array.push(fomc_Array, "2024-11-07")
        array.push(fomc_Array, "2024-09-18")
        array.push(fomc_Array, "2024-07-31")
        array.push(fomc_Array, "2024-06-12")
        array.push(fomc_Array, "2024-05-01")
        array.push(fomc_Array, "2024-03-20")
        array.push(fomc_Array, "2024-01-31")

        array.push(fomc_Array, "2023-12-31")


    myDate = str.format_time(time, "yyyy-MM-dd", "Europe/London")

    _fomcFound = array.includes(fomc_Array, myDate)
````
