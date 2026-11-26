# HashCost - Bitcoin Mining Cost

- url: https://www.tradingview.com/script/7WzaSPaU-HashCost-Bitcoin-Mining-Cost/
- type: indicator
- pine_id: PUB;4566533e9f2144e09f59f8e62dfe1104
- version: 1.0

## Description

HashCost estimates the electricity or hosting energy cost of producing one Bitcoin using a user-defined mining fleet.

Unlike a generic network-wide mining-cost model, HashCost is built around the miner's own operating history. Users enter dated fleet configurations containing effective hashrate, average paid power, electricity cost, and pool fee. Each configuration takes effect on its specified date, while previous configurations remain intact, allowing the plotted production-cost history to reflect changes in the user's mining setup over time.

HOW IT WORKS

HashCost combines the active fleet configuration with Bitcoin network difficulty and block subsidy data to estimate the expected BTC production per day.

Production Cost = Daily Paid Energy Cost / Expected Net BTC per Day

The model uses:
- Effective hashrate in TH/s
- Average paid power in kW
- Electricity or hosting-energy rate in USD/kWh
- Pool fee
- Bitcoin network difficulty
- Bitcoin block subsidy

Effective hashrate and paid power are entered as 24-hour averages. This makes it possible to represent miners who operate for only part of each day.

For example, a 300 TH/s miner consuming 6 kW for 8 hours per day can be represented as:
100 TH/s effective hashrate
2 kW average paid power

FLEET HISTORY

Each line represents one complete mining configuration:

YYYY-MM-DD | Effective TH/s | Avg Paid kW | $/kWh | Pool %

Example:

2026-01-01 | 1000 | 20 | 0.05 | 1

Add a new line whenever the mining setup changes. Keep previous lines in chronological order from oldest to newest.

HashCost preserves those historical configurations rather than retroactively applying the latest settings to the entire chart.

NETWORK DATA

Bitcoin difficulty and block-height data are sourced from Glassnode's crypto metrics on TradingView.

HashCost checks the freshness of the underlying network data and fails closed if the selected source becomes stale rather than silently continuing to calculate with outdated forward-filled values.

INFO PANEL

BTC Cost
Estimated energy production cost of one BTC.

BTC vs Cost
Percentage difference between current BTC market price and estimated production cost.

BTC / Day
Expected net BTC production per day after the entered pool fee.

Cost / Day
Average paid electricity or hosting energy cost per day.

Eff. Hashrate
Effective 24-hour mining hashrate.

SCOPE AND LIMITATIONS

HashCost is an electricity/hosting-energy operating-cost model. It is not an all-in accounting cost model.

It does not include hardware purchase cost, depreciation, repairs or maintenance, financing, taxes, labor, rent, or other expenses unless already incorporated into the entered energy rate.

Transaction-fee revenue is excluded.

HashCost is intended for standard 1D Bitcoin charts quoted in USD or supported USD-like markets such as USDT, USDC, and FDUSD.

It is a mining production-cost analysis tool, not a trading signal or price prediction.

## Source Code

````pine
//@version=6
indicator(
     "HashCost - Bitcoin Mining Cost",
     shorttitle="HashCost",
     overlay=true,
     format=format.price,
     precision=2
)

//=============================================================================
// HASHCOST - BITCOIN MINING COST
//
// Daily-only Bitcoin electricity / hosting-energy production cost.
//
// Production Cost = Daily Paid Energy Cost / Expected Net BTC per Day
//
// NETWORK SOURCES
// GLASSNODE:BTC_DIFFICULTY
//     Absolute estimated hashes required to find one block.
//
// GLASSNODE:BTC_BLOCKS
//     Bitcoin block height.
//
// Primary and legacy Glassnode symbols are both supported.
// The freshest valid source is selected automatically.
//
// DATA INTEGRITY
// If the selected network feed is more than 72 hours behind the chart,
// HashCost fails closed rather than silently using stale forward-filled data.
//
// Transaction-fee revenue, hardware CAPEX, depreciation, repairs, taxes,
// financing and other non-energy costs are excluded.
//=============================================================================


//=============================================================================
// LIMITS
//=============================================================================

int MAX_FLEET_LINES = 500

float MAX_HASHRATE_TH = 1000000000000.0
float MAX_AVG_PAID_POWER_KW = 1000000000.0
float MAX_ELECTRICITY_RATE = 1000.0

int MAX_SOURCE_AGE_MS = 259200000  // 72 hours


//=============================================================================
// INPUTS
//=============================================================================

fleetHistoryInput = input.text_area(
     "2026-01-01 | 1000 | 20 | 0.05 | 1",
     "FLEET HISTORY - Date | Effective Hashrate TH/s | Avg Paid Power kW | Electricity $/kWh | Pool Fee %",
     tooltip =
         "One row = one complete mining setup.\n\n" +
         "FORMAT:\n" +
         "YYYY-MM-DD | Effective TH/s | Avg Paid kW | $/kWh | Pool %\n\n" +
         "EXAMPLE:\n" +
         "2026-01-01 | 1000 | 20 | 0.05 | 1\n\n" +
         "Hashrate and paid power are 24h averages.\n" +
         "300 TH/s + 6 kW for 8h/day = 100 TH/s + 2 kW average.\n\n" +
         "Dates apply from 00:00 UTC.\n" +
         "Add new rows when the setup changes. Oldest -> newest.",
     group="HOW TO USE - Add a new row when your setup changes. Keep old rows.",
     display=display.none
)

showTable = input.bool(
     true,
     "Show Info Table",
     group="DISPLAY",
     display=display.none
)


//=============================================================================
// COLORS
//=============================================================================

epochColor(int index) =>
    switch index % 4
        0 => color.rgb(41, 121, 255)
        1 => color.rgb(255, 145, 0)
        2 => color.rgb(0, 188, 150)
        => color.rgb(171, 71, 188)


//=============================================================================
// BITCOIN SUBSIDY
//=============================================================================

subsidyFromHalvingCount(int halvings) =>
    float subsidy = 0.0

    if halvings < 33
        subsidy := math.floor(
             5000000000.0 /
             math.pow(2.0, halvings)
        ) / 100000000.0

    subsidy


subsidyFromBlockHeight(float height) =>
    int halvings = int(
         math.floor(
             height /
             210000.0
         )
    )

    subsidyFromHalvingCount(halvings)


//-----------------------------------------------------------------------------
// HALVING-DAY WEIGHTING
//
// Newly mined blocks are:
// previousHeight + 1 ... currentHeight
//
// The halving block itself receives the NEW subsidy.
//-----------------------------------------------------------------------------

dailySubsidyFromHeights(
     float currentHeight,
     float previousHeight
) =>
    float result =
         subsidyFromBlockHeight(
             currentHeight
         )

    if not na(previousHeight) and currentHeight > previousHeight

        int previousEra =
             int(
                 math.floor(
                     previousHeight /
                     210000.0
                 )
             )

        int currentEra =
             int(
                 math.floor(
                     currentHeight /
                     210000.0
                 )
             )

        if currentEra == previousEra

            result :=
                 subsidyFromHalvingCount(
                     currentEra
                 )

        else if currentEra == previousEra + 1

            float halvingHeight =
                 currentEra *
                 210000.0

            float oldSubsidyBlocks =
                 math.max(
                     halvingHeight -
                     previousHeight -
                     1.0,
                     0.0
                 )

            float newSubsidyBlocks =
                 math.max(
                     currentHeight -
                     halvingHeight +
                     1.0,
                     0.0
                 )

            float totalBlocks =
                 oldSubsidyBlocks +
                 newSubsidyBlocks

            float oldSubsidy =
                 subsidyFromHalvingCount(
                     previousEra
                 )

            float newSubsidy =
                 subsidyFromHalvingCount(
                     currentEra
                 )

            if totalBlocks > 0

                result :=
                     (
                         oldSubsidyBlocks *
                         oldSubsidy +
                         newSubsidyBlocks *
                         newSubsidy
                     ) /
                     totalBlocks

        else

            // Multiple halving eras crossed in one daily observation
            // is not considered a trustworthy daily value.
            result := na

    result


//-----------------------------------------------------------------------------
// HISTORICAL CALENDAR FALLBACK
//
// Only used when block-height data is unavailable.
//
// We deliberately stop after the 2024 halving. Future halvings must be
// determined from block height rather than guessed from calendar dates.
//-----------------------------------------------------------------------------

subsidyFromHistoricalTime(int t) =>

    int halving1 =
         timestamp(
             "UTC",
             2012,
             11,
             28,
             0,
             0
         )

    int halving2 =
         timestamp(
             "UTC",
             2016,
             7,
             9,
             0,
             0
         )

    int halving3 =
         timestamp(
             "UTC",
             2020,
             5,
             11,
             0,
             0
         )

    int halving4 =
         timestamp(
             "UTC",
             2024,
             4,
             20,
             0,
             0
         )


    float subsidy = na


    if t < halving1
        subsidy := 50.0

    else if t < halving2
        subsidy := 25.0

    else if t < halving3
        subsidy := 12.5

    else if t < halving4
        subsidy := 6.25


    subsidy


//=============================================================================
// FLEET STORAGE
//=============================================================================

var array<int> epochDates =
     array.new_int()

var array<float> epochHashrates =
     array.new_float()

var array<float> epochAvgPaidPowers =
     array.new_float()

var array<float> epochRates =
     array.new_float()

var array<float> epochPoolFees =
     array.new_float()


var int invalidRows = 0
var int firstInvalidRow = na
var bool fleetLineLimitExceeded = false


//=============================================================================
// FLEET PARSER
//=============================================================================

if barstate.isfirst

    array<string> lines =
         str.split(
             fleetHistoryInput,
             "\n"
         )


    if array.size(lines) > MAX_FLEET_LINES

        fleetLineLimitExceeded := true


    else

        for i = 0 to array.size(lines) - 1

            string line =
                 str.trim(
                     array.get(
                         lines,
                         i
                     )
                 )


            if str.length(line) > 0

                bool rowValid = false

                int parsedEpochDate = na

                float parsedHashrate = na
                float parsedAvgPaidPower = na
                float parsedRate = na
                float parsedPoolFee = na


                array<string> fields =
                     str.split(
                         line,
                         "|"
                     )


                if array.size(fields) == 5

                    string dateText =
                         str.trim(
                             array.get(
                                 fields,
                                 0
                             )
                         )

                    string hashrateText =
                         str.trim(
                             array.get(
                                 fields,
                                 1
                             )
                         )

                    string powerText =
                         str.trim(
                             array.get(
                                 fields,
                                 2
                             )
                         )

                    string rateText =
                         str.trim(
                             array.get(
                                 fields,
                                 3
                             )
                         )

                    string poolFeeText =
                         str.trim(
                             array.get(
                                 fields,
                                 4
                             )
                         )


                    bool dateStructureValid =
                         (
                             str.length(dateText) == 10 and
                             str.substring(dateText, 4, 5) == "-" and
                             str.substring(dateText, 7, 8) == "-"
                         )


                    if dateStructureValid

                        array<string> dateParts =
                             str.split(
                                 dateText,
                                 "-"
                             )


                        if array.size(dateParts) == 3

                            float yearValue =
                                 str.tonumber(
                                     str.trim(
                                         array.get(
                                             dateParts,
                                             0
                                         )
                                     )
                                 )

                            float monthValue =
                                 str.tonumber(
                                     str.trim(
                                         array.get(
                                             dateParts,
                                             1
                                         )
                                     )
                                 )

                            float dayValue =
                                 str.tonumber(
                                     str.trim(
                                         array.get(
                                             dateParts,
                                             2
                                         )
                                     )
                                 )

                            float hashrateValue =
                                 str.tonumber(
                                     hashrateText
                                 )

                            float avgPaidPowerValue =
                                 str.tonumber(
                                     powerText
                                 )

                            float rateValue =
                                 str.tonumber(
                                     rateText
                                 )

                            float poolFeeValue =
                                 str.tonumber(
                                     poolFeeText
                                 )


                            bool validNumbers =
                                 (
                                     not na(yearValue) and
                                     not na(monthValue) and
                                     not na(dayValue) and
                                     not na(hashrateValue) and
                                     not na(avgPaidPowerValue) and
                                     not na(rateValue) and
                                     not na(poolFeeValue)
                                 )


                            bool integerDateParts =
                                 (
                                     validNumbers and
                                     yearValue == math.floor(yearValue) and
                                     monthValue == math.floor(monthValue) and
                                     dayValue == math.floor(dayValue)
                                 )


                            bool validRanges =
                                 (
                                     integerDateParts and
                                     yearValue >= 2009 and
                                     yearValue <= 2200 and
                                     monthValue >= 1 and
                                     monthValue <= 12 and
                                     dayValue >= 1 and
                                     dayValue <= 31 and
                                     hashrateValue > 0 and
                                     hashrateValue <= MAX_HASHRATE_TH and
                                     avgPaidPowerValue >= 0 and
                                     avgPaidPowerValue <= MAX_AVG_PAID_POWER_KW and
                                     rateValue >= 0 and
                                     rateValue <= MAX_ELECTRICITY_RATE and
                                     poolFeeValue >= 0 and
                                     poolFeeValue < 100
                                 )


                            if validRanges

                                int inputYear =
                                     int(
                                         yearValue
                                     )

                                int inputMonth =
                                     int(
                                         monthValue
                                     )

                                int inputDay =
                                     int(
                                         dayValue
                                     )


                                int epochDate =
                                     timestamp(
                                         "UTC",
                                         inputYear,
                                         inputMonth,
                                         inputDay,
                                         0,
                                         0
                                     )


                                string canonicalDate =
                                     str.format_time(
                                         epochDate,
                                         "yyyy-MM-dd",
                                         "UTC"
                                     )


                                bool canonicalDateValid =
                                     canonicalDate ==
                                     dateText


                                int bitcoinGenesis =
                                     timestamp(
                                         "UTC",
                                         2009,
                                         1,
                                         3,
                                         0,
                                         0
                                     )


                                bool onOrAfterGenesis =
                                     epochDate >=
                                     bitcoinGenesis


                                bool chronological =
                                     (
                                         array.size(
                                             epochDates
                                         ) == 0 or
                                         epochDate >
                                         array.get(
                                             epochDates,
                                             array.size(
                                                 epochDates
                                             ) - 1
                                         )
                                     )


                                if canonicalDateValid and
                                   onOrAfterGenesis and
                                   chronological

                                    rowValid := true

                                    parsedEpochDate :=
                                         epochDate

                                    parsedHashrate :=
                                         hashrateValue

                                    parsedAvgPaidPower :=
                                         avgPaidPowerValue

                                    parsedRate :=
                                         rateValue

                                    parsedPoolFee :=
                                         poolFeeValue /
                                         100.0


                if rowValid

                    array.push(
                         epochDates,
                         parsedEpochDate
                    )

                    array.push(
                         epochHashrates,
                         parsedHashrate
                    )

                    array.push(
                         epochAvgPaidPowers,
                         parsedAvgPaidPower
                    )

                    array.push(
                         epochRates,
                         parsedRate
                    )

                    array.push(
                         epochPoolFees,
                         parsedPoolFee
                    )


                else

                    invalidRows += 1

                    if na(firstInvalidRow)
                        firstInvalidRow := i + 1


//=============================================================================
// FLEET VALIDATION
//=============================================================================

bool hasFleetRows =
     array.size(
         epochDates
     ) > 0


bool fleetInputValid =
     (
         not fleetLineLimitExceeded and
         hasFleetRows and
         invalidRows == 0
     )


//=============================================================================
// ACTIVE FLEET EPOCH
//=============================================================================

var int activeEpochIndex = -1


if fleetInputValid

    while activeEpochIndex + 1 < array.size(epochDates) and time >= array.get(epochDates, activeEpochIndex + 1)

        activeEpochIndex += 1


bool isOperating =
     fleetInputValid and
     activeEpochIndex >= 0


bool waitingForFleetStart =
     fleetInputValid and
     activeEpochIndex < 0


float activeHashrateTH =
     isOperating
     ? array.get(
         epochHashrates,
         activeEpochIndex
       )
     : na


float activeAvgPaidPowerKW =
     isOperating
     ? array.get(
         epochAvgPaidPowers,
         activeEpochIndex
       )
     : na


float activeRateUSD =
     isOperating
     ? array.get(
         epochRates,
         activeEpochIndex
       )
     : na


float activePoolFee =
     isOperating
     ? array.get(
         epochPoolFees,
         activeEpochIndex
       )
     : na


color activeColor =
     isOperating
     ? epochColor(
         activeEpochIndex
       )
     : na


//=============================================================================
// ENVIRONMENT VALIDATION
//=============================================================================

bool standardChart =
     chart.is_standard


bool supportedTimeframe =
     timeframe.isdaily and
     timeframe.multiplier == 1


bool btcChart =
     syminfo.basecurrency ==
     "BTC"


bool usdLikeQuote =
     (
         syminfo.currency == "USD" or
         syminfo.currency == "USDT" or
         syminfo.currency == "USDC" or
         syminfo.currency == "FDUSD"
     )


bool supportedSymbol =
     btcChart and
     usdLikeQuote


bool supportedEnvironment =
     supportedSymbol and
     supportedTimeframe and
     standardChart


//=============================================================================
// DIFFICULTY DATA
//
// TradingView's Glassnode difficulty metric is already ABSOLUTE:
// estimated hashes required to find one block.
//
// gaps_off is used for continuity, BUT we independently track the timestamp
// of the underlying source bar and reject values older than 72 hours.
//=============================================================================

float difficultyPrimary =
     request.security(
         "GLASSNODE:BTC_DIFFICULTY",
         "D",
         close,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


int difficultyPrimaryTime =
     request.security(
         "GLASSNODE:BTC_DIFFICULTY",
         "D",
         time,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


float difficultyLegacy =
     request.security(
         "GLASSNODE:XTVCBTC_DIFFICULTY",
         "D",
         close,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


int difficultyLegacyTime =
     request.security(
         "GLASSNODE:XTVCBTC_DIFFICULTY",
         "D",
         time,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


bool difficultyPrimaryAvailable =
     (
         not na(difficultyPrimary) and
         difficultyPrimary > 0 and
         not na(difficultyPrimaryTime)
     )


bool difficultyLegacyAvailable =
     (
         not na(difficultyLegacy) and
         difficultyLegacy > 0 and
         not na(difficultyLegacyTime)
     )


bool difficultyPrimaryFresh =
     (
         difficultyPrimaryAvailable and
         math.abs(time - difficultyPrimaryTime) <= MAX_SOURCE_AGE_MS
     )


bool difficultyLegacyFresh =
     (
         difficultyLegacyAvailable and
         math.abs(time - difficultyLegacyTime) <= MAX_SOURCE_AGE_MS
     )


float difficultyHashes = na
int difficultySourceTime = na


if difficultyPrimaryFresh and difficultyLegacyFresh

    if difficultyPrimaryTime >= difficultyLegacyTime

        difficultyHashes :=
             difficultyPrimary

        difficultySourceTime :=
             difficultyPrimaryTime

    else

        difficultyHashes :=
             difficultyLegacy

        difficultySourceTime :=
             difficultyLegacyTime


else if difficultyPrimaryFresh

    difficultyHashes :=
         difficultyPrimary

    difficultySourceTime :=
         difficultyPrimaryTime


else if difficultyLegacyFresh

    difficultyHashes :=
         difficultyLegacy

    difficultySourceTime :=
         difficultyLegacyTime


bool difficultyDataValid =
     not na(difficultyHashes) and
     difficultyHashes > 0


bool difficultyAnyAvailable =
     difficultyPrimaryAvailable or
     difficultyLegacyAvailable


//=============================================================================
// BLOCK HEIGHT DATA
//
// BTC_BLOCKS is block height directly.
// No "-1" conversion.
//
// As with difficulty, the newest fresh primary/legacy observation is used.
//=============================================================================

float blockHeightPrimary =
     request.security(
         "GLASSNODE:BTC_BLOCKS",
         "D",
         close,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


float previousBlockHeightPrimary =
     request.security(
         "GLASSNODE:BTC_BLOCKS",
         "D",
         close[1],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


int blockHeightPrimaryTime =
     request.security(
         "GLASSNODE:BTC_BLOCKS",
         "D",
         time,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


float blockHeightLegacy =
     request.security(
         "GLASSNODE:XTVCBTC_BLOCKS",
         "D",
         close,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


float previousBlockHeightLegacy =
     request.security(
         "GLASSNODE:XTVCBTC_BLOCKS",
         "D",
         close[1],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


int blockHeightLegacyTime =
     request.security(
         "GLASSNODE:XTVCBTC_BLOCKS",
         "D",
         time,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
     )


bool blockPrimaryAvailable =
     (
         not na(blockHeightPrimary) and
         blockHeightPrimary >= 0 and
         not na(blockHeightPrimaryTime)
     )


bool blockLegacyAvailable =
     (
         not na(blockHeightLegacy) and
         blockHeightLegacy >= 0 and
         not na(blockHeightLegacyTime)
     )


bool blockPrimaryFresh =
     (
         blockPrimaryAvailable and
         math.abs(time - blockHeightPrimaryTime) <= MAX_SOURCE_AGE_MS
     )


bool blockLegacyFresh =
     (
         blockLegacyAvailable and
         math.abs(time - blockHeightLegacyTime) <= MAX_SOURCE_AGE_MS
     )


float blockHeight = na
float previousBlockHeight = na
int blockHeightSourceTime = na


if blockPrimaryFresh and blockLegacyFresh

    if blockHeightPrimaryTime >= blockHeightLegacyTime

        blockHeight :=
             blockHeightPrimary

        previousBlockHeight :=
             previousBlockHeightPrimary

        blockHeightSourceTime :=
             blockHeightPrimaryTime

    else

        blockHeight :=
             blockHeightLegacy

        previousBlockHeight :=
             previousBlockHeightLegacy

        blockHeightSourceTime :=
             blockHeightLegacyTime


else if blockPrimaryFresh

    blockHeight :=
         blockHeightPrimary

    previousBlockHeight :=
         previousBlockHeightPrimary

    blockHeightSourceTime :=
         blockHeightPrimaryTime


else if blockLegacyFresh

    blockHeight :=
         blockHeightLegacy

    previousBlockHeight :=
         previousBlockHeightLegacy

    blockHeightSourceTime :=
         blockHeightLegacyTime


bool blockHeightDataValid =
     not na(blockHeight) and
     blockHeight >= 0


bool blockHeightAnyAvailable =
     blockPrimaryAvailable or
     blockLegacyAvailable


//=============================================================================
// BLOCK SUBSIDY
//=============================================================================

float blockSubsidy =
     blockHeightDataValid
     ? dailySubsidyFromHeights(
         blockHeight,
         previousBlockHeight
       )
     : subsidyFromHistoricalTime(
         time
       )


bool subsidyDataValid =
     not na(blockSubsidy) and
     blockSubsidy >= 0


bool networkDataValid =
     difficultyDataValid and
     subsidyDataValid


bool subsidyExhausted =
     networkDataValid and
     blockSubsidy == 0


//=============================================================================
// MINING ECONOMICS
//=============================================================================

float dailyPaidKWh =
     isOperating
     ? activeAvgPaidPowerKW *
       24.0
     : na


float dailyCostUSD =
     isOperating
     ? dailyPaidKWh *
       activeRateUSD
     : na


float hashrateH =
     isOperating
     ? activeHashrateTH *
       1e12
     : na


float expectedBlocksPerDay =
     (
         isOperating and
         networkDataValid and
         not subsidyExhausted and
         difficultyHashes > 0
     )
     ? (
         hashrateH *
         86400.0
       ) /
       difficultyHashes
     : na


float btcPerDayGross =
     not na(expectedBlocksPerDay)
     ? expectedBlocksPerDay *
       blockSubsidy
     : na


float btcPerDayNet =
     not na(btcPerDayGross)
     ? btcPerDayGross *
       (
         1.0 -
         activePoolFee
       )
     : na


float productionCostUSD =
     (
         isOperating and
         networkDataValid and
         not subsidyExhausted and
         not na(btcPerDayNet) and
         btcPerDayNet > 0
     )
     ? (
         dailyCostUSD == 0
         ? 0.0
         : dailyCostUSD /
           btcPerDayNet
       )
     : na


bool zeroCostOperation =
     (
         isOperating and
         networkDataValid and
         not subsidyExhausted and
         not na(btcPerDayNet) and
         btcPerDayNet > 0 and
         dailyCostUSD == 0
     )


float btcVsCostPercent =
     (
         supportedEnvironment and
         not na(productionCostUSD) and
         productionCostUSD > 0
     )
     ? (
         (
             close /
             productionCostUSD
         ) -
         1.0
       ) *
       100.0
     : na


//=============================================================================
// PLOT
//=============================================================================

float plotCostUSD =
     (
         supportedEnvironment and
         isOperating and
         networkDataValid and
         not subsidyExhausted and
         not zeroCostOperation
     )
     ? productionCostUSD
     : na


plot(
     plotCostUSD,
     title="BTC Production Cost",
     color=activeColor,
     linewidth=3
)


//=============================================================================
// INFO PANEL
//=============================================================================

var table info =
     table.new(
         position.top_right,
         2,
         5,
         border_width=0
     )


if barstate.islast

    table.clear(
         info,
         0,
         0,
         1,
         4
    )


    if showTable

        color panelBg =
             color.new(
                 chart.bg_color,
                 12
             )


        color labelCol =
             color.new(
                 chart.fg_color,
                 38
             )


        color valueCol =
             chart.fg_color


        color positiveCol =
             color.rgb(
                 0,
                 180,
                 90
             )


        color negativeCol =
             color.rgb(
                 230,
                 70,
                 70
             )


        color warningCol =
             color.rgb(
                 230,
                 70,
                 70
             )


        //---------------------------------------------------------------------
        // TOO MANY FLEET ROWS
        //---------------------------------------------------------------------

        if fleetLineLimitExceeded

            table.cell(
                 info,
                 0,
                 0,
                 "Fix Fleet History",
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 "Max 500 lines",
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


        //---------------------------------------------------------------------
        // INVALID / EMPTY FLEET
        //---------------------------------------------------------------------

        else if not fleetInputValid

            string fleetWarning =
                 invalidRows > 0
                 ? (
                     "Row " +
                     str.tostring(
                         firstInvalidRow
                     ) +
                     " invalid"
                   )
                 : "Add at least 1 row"


            table.cell(
                 info,
                 0,
                 0,
                 invalidRows > 0
                 ? "Fix Fleet History"
                 : "Fleet History Required",
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 fleetWarning,
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


        //---------------------------------------------------------------------
        // WRONG SYMBOL
        //---------------------------------------------------------------------

        else if not supportedSymbol

            table.cell(
                 info,
                 0,
                 0,
                 "BTC USD quote required",
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 "",
                 bgcolor=panelBg
            )


        //---------------------------------------------------------------------
        // NON-STANDARD CHART
        //---------------------------------------------------------------------

        else if not standardChart

            table.cell(
                 info,
                 0,
                 0,
                 "Standard chart required",
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 "",
                 bgcolor=panelBg
            )


        //---------------------------------------------------------------------
        // WRONG TIMEFRAME
        //---------------------------------------------------------------------

        else if not supportedTimeframe

            table.cell(
                 info,
                 0,
                 0,
                 "Use 1D timeframe",
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 "",
                 bgcolor=panelBg
            )


        //---------------------------------------------------------------------
        // NETWORK DATA FAILURE / STALENESS
        //---------------------------------------------------------------------

        else if not networkDataValid

            string networkMessage = "Unavailable"


            if not difficultyDataValid

                networkMessage :=
                     difficultyAnyAvailable
                     ? "Difficulty stale"
                     : "Difficulty unavailable"


            else if not subsidyDataValid

                if not blockHeightDataValid

                    networkMessage :=
                         blockHeightAnyAvailable
                         ? "Block height stale"
                         : "Block height unavailable"

                else

                    networkMessage :=
                         "Subsidy unavailable"


            table.cell(
                 info,
                 0,
                 0,
                 "Network Data",
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 networkMessage,
                 text_color=warningCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


        //---------------------------------------------------------------------
        // SUBSIDY EXHAUSTED
        //---------------------------------------------------------------------

        else if subsidyExhausted

            table.cell(
                 info,
                 0,
                 0,
                 "Block Subsidy",
                 text_color=labelCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 "Exhausted",
                 text_color=valueCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


        //---------------------------------------------------------------------
        // FLEET NOT STARTED
        //---------------------------------------------------------------------

        else if waitingForFleetStart

            string firstFleetDate =
                 str.format_time(
                     array.get(
                         epochDates,
                         0
                     ),
                     "yyyy-MM-dd",
                     "UTC"
                 )


            table.cell(
                 info,
                 0,
                 0,
                 "Fleet Starts",
                 text_color=labelCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 firstFleetDate,
                 text_color=valueCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


        //---------------------------------------------------------------------
        // NORMAL PANEL
        //---------------------------------------------------------------------

        else

            string costText =
                 zeroCostOperation
                 ? "$0"
                 : "$" +
                   str.tostring(
                       productionCostUSD,
                       "#,###"
                   )


            string vsCostText =
                 zeroCostOperation
                 ? "N/A"
                 : (
                     (
                         btcVsCostPercent >= 0
                         ? "+"
                         : ""
                     ) +
                     str.tostring(
                         btcVsCostPercent,
                         "#.0"
                     ) +
                     "%"
                   )


            color vsCostColor =
                 zeroCostOperation or
                 na(btcVsCostPercent)
                 ? valueCol
                 : (
                     btcVsCostPercent >= 0
                     ? positiveCol
                     : negativeCol
                   )


            string btcDayText =
                 str.tostring(
                     btcPerDayNet,
                     "0.000000"
                 )


            string costDayText =
                 "$" +
                 str.tostring(
                     dailyCostUSD,
                     "0.00"
                 )


            string hashrateText =
                 str.tostring(
                     activeHashrateTH /
                     1000.0,
                     "0.00"
                 ) +
                 " PH/s"


            // BTC COST
            table.cell(
                 info,
                 0,
                 0,
                 "BTC Cost",
                 text_color=labelCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 0,
                 costText,
                 text_color=activeColor,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            // BTC VS COST
            table.cell(
                 info,
                 0,
                 1,
                 "BTC vs Cost",
                 text_color=labelCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 1,
                 vsCostText,
                 text_color=vsCostColor,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            // BTC / DAY
            table.cell(
                 info,
                 0,
                 2,
                 "BTC / Day",
                 text_color=labelCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 2,
                 btcDayText,
                 text_color=valueCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            // COST / DAY
            table.cell(
                 info,
                 0,
                 3,
                 "Cost / Day",
                 text_color=labelCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 3,
                 costDayText,
                 text_color=valueCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            // EFFECTIVE HASHRATE
            table.cell(
                 info,
                 0,
                 4,
                 "Eff. Hashrate",
                 text_color=labelCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )


            table.cell(
                 info,
                 1,
                 4,
                 hashrateText,
                 text_color=valueCol,
                 text_size=size.normal,
                 bgcolor=panelBg,
                 text_halign=text.align_left
            )
````
