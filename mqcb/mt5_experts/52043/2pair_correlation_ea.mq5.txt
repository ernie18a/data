#include <Trade\Trade.mqh>  // Include the trading functions library

CTrade trade;  // Declare the trade object to handle trading operations

// Input parameters
input double MaxDrawdownPercent = 20.0;    // Maximum drawdown percentage to stop trading
input double RiskPercent = 2.0;            // Risk percentage per trade (as a percentage of the account balance)
input double PriceDifferenceThreshold = 100.0; // Threshold for price divergence (adjust as needed)
input int Slippage = 3;                    // Maximum allowable slippage in pips (default 3 pips)
input double MinimumTotalProfit = 0.30;    // Minimum total profit before closing all trades (in account currency)
input int ATRPeriod = 14;                  // ATR period for volatility measurement
input double RecoveryPercent = 95.0;       // The percentage of the balance the equity must recover to resume trading

// Function to calculate dynamic lot size based on account balance and risk percentage
double CalculateDynamicLotSize(double stopLossPips)
{
    double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (RiskPercent / 100.0);  // Risk amount per trade
    double lotSize = riskAmount / (stopLossPips * _Point);  // Calculate lot size based on stop loss distance
    return MathMax(0.01, lotSize);  // Ensure minimum lot size is 0.01
}

// Function to check if current drawdown exceeds the maximum allowed
bool IsMaxDrawdownReached()
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double drawdownPercent = ((balance - equity) / balance) * 100.0;

    // Check if equity has dropped below the maximum drawdown limit
    if (drawdownPercent >= MaxDrawdownPercent)
    {
        Print("Max drawdown reached. Pausing trading.");
        return true;  // Stop trading if max drawdown is reached
    }

    return false;
}

// Function to check if account has recovered enough to resume trading
bool HasAccountRecovered()
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    
    // Check if equity has recovered to the RecoveryPercent of the balance
    if ((equity / balance) * 100.0 >= RecoveryPercent)
    {
        Print("Account has recovered to " + DoubleToString(RecoveryPercent, 2) + "%. Resuming trading.");
        return true;  // Account has recovered, resume trading
    }
    
    return false;
}

// Function to check market volatility using ATR and decide whether to trade
bool IsVolatilityHigh(string symbol)
{
    double currentATR = iATR(symbol, PERIOD_M5, ATRPeriod);
    
    // If ATR is high, we consider the market volatile
    if (currentATR > PriceDifferenceThreshold * 0.01)  // Adjust multiplier as needed
    {
        Print("High volatility detected. Pausing trades for safety.");
        return true;
    }
    
    return false;
}

// Function to check if there are any open trades for a given symbol
bool IsTradeOpen(string symbol)
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (PositionGetSymbol(i) == symbol)
        {
            return true;  // A trade is open for this symbol
        }
    }
    return false;
}

// Function to calculate the total profit of all trades
double CalculateTotalProfit()
{
    double totalProfit = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        totalProfit += PositionGetDouble(POSITION_PROFIT);  // Add up profit for each open position
    }

    return totalProfit;
}

// Function to close all trades if the total profit exceeds the threshold
void CloseAllTradesIfProfitable()
{
    double totalProfit = CalculateTotalProfit();

    if (totalProfit >= MinimumTotalProfit)
    {
        // Close all trades if the total profit exceeds the minimum threshold
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            trade.PositionClose(ticket);
        }

        Print("Closed all trades with total profit: " + DoubleToString(totalProfit, 2));
    }
    else
    {
        Print("Total profit: " + DoubleToString(totalProfit, 2) + " - keeping trades open.");
    }
}

// Function to detect price divergence and execute trades
void DetectPriceDivergenceAndTrade()
{
    // Stop trading if max drawdown is reached, and only resume after recovery
    if (IsMaxDrawdownReached() && !HasAccountRecovered()) 
    {
        return;  // Pause trading
    }

    // Fetch bid prices for BTC/USD and ETH/USD
    double btcusdBid = SymbolInfoDouble("BTCUSD", SYMBOL_BID);
    double ethusdBid = SymbolInfoDouble("ETHUSD", SYMBOL_BID);

    // Calculate the price difference
    double priceDifference = btcusdBid - ethusdBid;

    // Ensure the lot size is dynamically calculated based on the stop loss
    double stopLossPips = 50;  // Example fixed stop loss in pips (adjust as needed)
    double dynamicLotSize = CalculateDynamicLotSize(stopLossPips);

    // Check for price divergence opportunities (buy BTC/USD, sell ETH/USD)
    if (priceDifference > PriceDifferenceThreshold && !IsTradeOpen("BTCUSD") && !IsTradeOpen("ETHUSD"))
    {
        if (IsVolatilityHigh("BTCUSD") || IsVolatilityHigh("ETHUSD")) return;  // Avoid trading in high volatility

        // Execute correlation trades with slippage control
        trade.Buy(dynamicLotSize, "BTCUSD", 0, Slippage, 0, "Buy BTC/USD due to price divergence");
        trade.Sell(dynamicLotSize, "ETHUSD", 0, Slippage, 0, "Sell ETH/USD due to price divergence");

        Print("Divergence detected: Buying BTC/USD, Selling ETH/USD");
    }
    // Check for reverse divergence opportunities (sell BTC/USD, buy ETH/USD)
    else if (priceDifference < -PriceDifferenceThreshold && !IsTradeOpen("BTCUSD") && !IsTradeOpen("ETHUSD"))
    {
        if (IsVolatilityHigh("BTCUSD") || IsVolatilityHigh("ETHUSD")) return;  // Avoid trading in high volatility

        // Execute reverse correlation trades with slippage control
        trade.Sell(dynamicLotSize, "BTCUSD", 0, Slippage, 0, "Sell BTC/USD due to reverse divergence");
        trade.Buy(dynamicLotSize, "ETHUSD", 0, Slippage, 0, "Buy ETH/USD due to reverse divergence");

        Print("Reverse divergence detected: Selling BTC/USD, Buying ETH/USD");
    }

    // Close all trades together if total profit exceeds the threshold
    CloseAllTradesIfProfitable();
}

// Main function called on every tick
void OnTick()
{
    DetectPriceDivergenceAndTrade();  // Check for price divergence and manage trades on every tick
}

// Initialization function
int OnInit()
{
    Print("2-Pair Correlation EA initialized with self-adaptive risk management.");
    return INIT_SUCCEEDED;
}

// Deinitialization function
void OnDeinit(const int reason)
{
    Print("2-Pair Correlation EA deinitialized.");
}
