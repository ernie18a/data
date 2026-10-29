Long: flat AND hour(datetime) < configured long-entry hour AND close > open of the higher-timeframe bar still forming AND open of that bar − low of that bar > configured point threshold
Short: flat AND hour(datetime) < configured short-entry hour AND close < open of the higher-timeframe bar still forming AND high of that bar − open of that bar > configured point threshold
Exit: long, hour(datetime) > configured market-close hour − 1
Exit: short, hour(datetime) > configured market-close hour − 1