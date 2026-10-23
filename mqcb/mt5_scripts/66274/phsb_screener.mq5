//+------------------------------------------------------------------+
//|                                                PHSB_Screener.mq5 |
//|            Copyright 2025, Paulo Bonanni, phsbconsultoria.com.br |
//|                                           phsbconsultoria.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Paulo Bonanni"
#property link      "phsbconsultoria.com.br"
#property version   "2.05"
#property description "Advanced screener to identify assets with significant price drawdown\nIdentifies assets with maximum drawdown in selected period\nAccurate calculation using peak to current price\nWorks across all broker assets or filtered categories\nAutomatically cleans Market Watch after execution"
#property script_show_inputs

//--- Input parameters
input int    LookbackPeriod = 90;      // Lookback period in days
input double DrawdownThreshold = 1.0; // Drawdown threshold in %
input bool   ShowAllSymbols = false;   // Show all symbols in log
input bool   FilterForex = true;      // Include Forex symbols
input bool   FilterStocks = false;      // Include Stocks and ETFs
input bool   FilterIndices = false;    // Include Indices
input bool   FilterCommodities = false;// Include Commodities
input bool   FilterCrypto = false;     // Include Cryptocurrencies
input int    DataLoadTimeout = 5000;   // Data loading timeout (ms)
input bool   CleanupAfterRun = true;   // Clean symbols after execution
input bool   PreloadData = true;       // Preload data in batches
input int    BatchSize = 50;           // Batch size for loading

//+------------------------------------------------------------------+
//| Structure to store results                                       |
//+------------------------------------------------------------------+
struct SymbolResult
  {
   string            symbol;
   double            drawdown;
   double            peak;
   double            price;
   string            result_str;
  };

string            original_symbols[]; // Store original Market Watch symbols
string            added_symbols[];    // Store symbols added during execution

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   // Save original Market Watch state
   SaveOriginalSymbols();
   
   Print("=== ADVANCED PB SCREENER - LOADING DATA ===");
   Print("Version 2.05 - Accurate Peak to Current Price Drawdown");

   // Get all available symbols and apply filters FIRST
   string all_symbols[];
   int total_symbols = GetSymbolsList(all_symbols);
   Print("Total symbols available: ", total_symbols);

   // Filter symbols BEFORE preloading
   string filtered_symbols[];
   int filtered_count = 0;
   
   for(int i = 0; i < total_symbols; i++)
     {
      if(ShouldIncludeSymbol(all_symbols[i]))
        {
         filtered_count++;
         ArrayResize(filtered_symbols, filtered_count);
         filtered_symbols[filtered_count-1] = all_symbols[i];
        }
     }
   
   Print("Symbols after filtering: ", filtered_count);

   // Preload only FILTERED symbols in batches if enabled
   if(PreloadData && filtered_count > 0)
     {
      Print("Preloading filtered symbols...");
      for(int batch_start = 0; batch_start < filtered_count; batch_start += BatchSize)
        {
         PreloadSymbolsBatch(filtered_symbols, batch_start, BatchSize);
        }
     }

   int symbols_found = 0;
   int symbols_checked = 0;
   int symbols_loaded = 0;
   SymbolResult results[];

   // Process only FILTERED symbols
   for(int i = 0; i < filtered_count; i++)
     {
      string symbol_name = filtered_symbols[i];
      symbols_checked++;

      // Show progress
      if(symbols_checked % 50 == 0)
        {
         Print("Progress: ", symbols_checked, "/", filtered_count,
               " | Loaded: ", symbols_loaded,
               " | Found: ", symbols_found);
        }

      // Try to load and verify symbol data
      if(!LoadAndVerifySymbolData(symbol_name))
        {
         if(ShowAllSymbols)
            Print("Skipping: ", symbol_name, " - Data not loaded");
         continue;
        }

      symbols_loaded++;

      // Calculate drawdown using accurate method (Peak to Current Price)
      double current_price = SymbolInfoDouble(symbol_name, SYMBOL_BID);
      double peak_price = GetPeakPrice(symbol_name, LookbackPeriod);
      double drawdown = CalculateDrawdown(symbol_name, LookbackPeriod, current_price);

      if(drawdown >= DrawdownThreshold)
        {
         symbols_found++;
         ArrayResize(results, symbols_found);

         results[symbols_found-1].symbol = symbol_name;
         results[symbols_found-1].drawdown = drawdown;
         results[symbols_found-1].peak = peak_price;
         results[symbols_found-1].price = current_price;
         results[symbols_found-1].result_str = StringFormat("%s | DD: %.2f%% | Peak: %.5f | Current: %.5f",
                          symbol_name, drawdown, peak_price, current_price);

         Print("FOUND: ", results[symbols_found-1].result_str);
        }
     }

   // Sort and display results
   DisplayResults(results, symbols_found, symbols_checked, symbols_loaded);
  }

//+------------------------------------------------------------------+
//| Save original Market Watch symbols                              |
//+------------------------------------------------------------------+
void SaveOriginalSymbols()
  {
   int count = SymbolsTotal(true);
   ArrayResize(original_symbols, count);
   
   for(int i = 0; i < count; i++)
     {
      original_symbols[i] = SymbolName(i, true);
     }
   
   if(count > 0)
     {
      Print("Saved ", count, " original Market Watch symbols for cleanup");
     }
   else
     {
      Print("Market Watch is empty - no symbols to save");
     }
  }

//+------------------------------------------------------------------+
//| Get list of all available symbols                                |
//+------------------------------------------------------------------+
int GetSymbolsList(string &symbols[])
  {
   int count = SymbolsTotal(false);
   ArrayResize(symbols, count);

   for(int i = 0; i < count; i++)
     {
      symbols[i] = SymbolName(i, false);
     }

   return count;
  }

//+------------------------------------------------------------------+
//| Load and verify symbol data                                      |
//+------------------------------------------------------------------+
bool LoadAndVerifySymbolData(string symbol)
  {
   // Track added symbols
   int size = ArraySize(added_symbols);
   ArrayResize(added_symbols, size + 1);
   added_symbols[size] = symbol;

   // Step 1: Select symbol in Market Watch
   if(!SymbolSelect(symbol, true))
     {
      if(ShowAllSymbols)
         Print("Failed to select: ", symbol);
      return false;
     }

   // Step 2: Wait for symbol data to load
   if(!WaitForSymbolData(symbol))
     {
      if(ShowAllSymbols)
         Print("Timeout loading: ", symbol);
      SymbolSelect(symbol, false); // Remove from Market Watch
      return false;
     }

   // Step 3: Verify sufficient historical data
   if(!VerifyHistoricalData(symbol))
     {
      if(ShowAllSymbols)
         Print("Insufficient historical data: ", symbol);
      SymbolSelect(symbol, false); // Remove from Market Watch
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Wait for symbol data to be loaded                                |
//+------------------------------------------------------------------+
bool WaitForSymbolData(string symbol)
  {
   uint start_time = GetTickCount();
   uint timeout_ms = (uint)DataLoadTimeout;

   while(GetTickCount() - start_time < timeout_ms)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

      if(bid > 0 && ask > 0 && bid != DBL_MAX && ask != DBL_MAX)
        {
         int bars = Bars(symbol, PERIOD_D1);
         if(bars > 10)
           {
            return true;
           }
        }
      Sleep(100);
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Verify historical data availability                              |
//+------------------------------------------------------------------+
bool VerifyHistoricalData(string symbol)
  {
   MqlRates rates[];
   int copied = CopyRates(symbol, PERIOD_D1, 0, LookbackPeriod + 10, rates);

   if(copied < LookbackPeriod)
     {
      if(ShowAllSymbols)
         Print("Insufficient data for ", symbol, ": ", copied, " bars (required: ", LookbackPeriod, ")");
      return false;
     }

   int valid_data_count = 0;
   for(int i = 0; i < MathMin(copied, 10); i++)
     {
      if(rates[i].open > 0 && rates[i].high > 0 && rates[i].low > 0 && rates[i].close > 0)
        {
         valid_data_count++;
        }
     }

   if(valid_data_count < 5)
     {
      if(ShowAllSymbols)
         Print("Invalid data for ", symbol);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Calculate maximum drawdown from peak to current price           |
//+------------------------------------------------------------------+
double CalculateDrawdown(string symbol, int days, double current_price)
  {
   MqlRates rates[];
   int copied = CopyRates(symbol, PERIOD_D1, 0, days, rates);

   if(copied <= 0)
     {
      if(ShowAllSymbols)
         Print("Error copying data for calculation: ", symbol);
      return 0.0;
     }

   // Find the peak price in the period
   double peak = rates[0].close;
   for(int i = 1; i < copied; i++)
     {
      if(rates[i].close > peak)
        {
         peak = rates[i].close;
        }
     }

   // Calculate drawdown from peak to current price
   double drawdown = 0.0;
   if(peak > 0 && current_price > 0)
     {
      drawdown = ((peak - current_price) / peak) * 100;
     }

   return drawdown;
  }

//+------------------------------------------------------------------+
//| Get peak price used in drawdown calculation                      |
//+------------------------------------------------------------------+
double GetPeakPrice(string symbol, int days)
  {
   MqlRates rates[];
   int copied = CopyRates(symbol, PERIOD_D1, 0, days, rates);

   if(copied <= 0)
      return 0.0;

   double peak = rates[0].close;
   for(int i = 1; i < copied; i++)
     {
      if(rates[i].close > peak)
        {
         peak = rates[i].close;
        }
     }

   return peak;
  }

//+------------------------------------------------------------------+
//| Display sorted results                                           |
//+------------------------------------------------------------------+
void DisplayResults(SymbolResult &results[], int symbols_found, int symbols_checked, int symbols_loaded)
  {
   if(symbols_found > 0)
     {
      Print("");
      Print("=== RESULTS SORTED BY DRAWDOWN ===");

      // Sort by drawdown (descending)
      for(int i = 0; i < symbols_found - 1; i++)
        {
         for(int j = 0; j < symbols_found - i - 1; j++)
           {
            if(results[j].drawdown < results[j+1].drawdown)
              {
               SymbolResult temp = results[j];
               results[j] = results[j+1];
               results[j+1] = temp;
              }
           }
        }

      for(int i = 0; i < symbols_found; i++)
        {
         Print("#", i+1, ": ", results[i].result_str);
        }

      Print("");
      Print("=== SUMMARY ===");
      Print("Symbols checked: ", symbols_checked);
      Print("Symbols loaded: ", symbols_loaded);
      Print("Symbols found: ", symbols_found);
      Print("Success rate: ", DoubleToString((double)symbols_loaded/symbols_checked*100, 1), "%");
      Print("Highest drawdown: ", results[0].symbol, " - ", DoubleToString(results[0].drawdown, 2), "%");
      Print("Lowest drawdown: ", results[symbols_found-1].symbol, " - ", DoubleToString(results[symbols_found-1].drawdown, 2), "%");
      Print("Calculation: Drawdown = (Historical Peak Price - Current Price) / Historical Peak Price * 100");
     }
   else
     {
      Print("");
      Print("=== NO RESULTS FOUND ===");
      Print("Symbols checked: ", symbols_checked);
      Print("Symbols loaded: ", symbols_loaded);
      Print("No assets with drawdown > ", DrawdownThreshold, "% in last ", LookbackPeriod, " days");
     }

   // Clean up Market Watch
   CleanupAddedSymbols();
  }

//+------------------------------------------------------------------+
//| Clean up symbols added during execution                          |
//+------------------------------------------------------------------+
void CleanupAddedSymbols()
  {
   if(!CleanupAfterRun)
     {
      Print("Cleanup disabled by user setting");
      return;
     }

   Print("Cleaning up Market Watch...");
   int removed_count = 0;
   
   // Remove ALL symbols that were added during execution
   for(int i = 0; i < ArraySize(added_symbols); i++)
     {
      if(SymbolSelect(added_symbols[i], false))
        {
         removed_count++;
         if(ShowAllSymbols)
            Print("Removed: ", added_symbols[i]);
        }
     }
   
   // Also do a safety cleanup based on original state
   int current_count = SymbolsTotal(true);
   for(int i = current_count - 1; i >= 0; i--)
     {
      string current_symbol = SymbolName(i, true);
      bool was_original = false;
      
      for(int j = 0; j < ArraySize(original_symbols); j++)
        {
         if(current_symbol == original_symbols[j])
           {
            was_original = true;
            break;
           }
        }
      
      if(!was_original)
        {
         if(SymbolSelect(current_symbol, false))
           {
            removed_count++;
            if(ShowAllSymbols)
               Print("Safety removed: ", current_symbol);
           }
        }
     }
   
   if(removed_count > 0)
     {
      Print("Market Watch cleanup completed. Removed ", removed_count, " symbols");
     }
   else
     {
      Print("Market Watch cleanup: No symbols to remove");
     }
     
   // Clear the added symbols array
   ArrayFree(added_symbols);
  }

//+------------------------------------------------------------------+
//| Filter symbols by category                                       |
//+------------------------------------------------------------------+
bool ShouldIncludeSymbol(string symbol)
  {
   // If all filters are false, include nothing
   if(!FilterForex && !FilterStocks && !FilterIndices && !FilterCommodities && !FilterCrypto)
      return false;

   string symbol_name = symbol;
   string description = SymbolInfoString(symbol, SYMBOL_DESCRIPTION);
   string path = SymbolInfoString(symbol, SYMBOL_PATH);

   // Forex filter
   if(FilterForex)
     {
      if(StringFind(symbol_name, "USD") >= 0 ||
         StringFind(symbol_name, "EUR") >= 0 ||
         StringFind(symbol_name, "GBP") >= 0 ||
         StringFind(symbol_name, "JPY") >= 0 ||
         StringFind(symbol_name, "CHF") >= 0 ||
         StringFind(symbol_name, "CAD") >= 0 ||
         StringFind(symbol_name, "AUD") >= 0 ||
         StringFind(symbol_name, "NZD") >= 0 ||
         StringFind(description, "Forex") >= 0 ||
         StringFind(path, "Forex") >= 0)
         return true;
     }

   // Stocks filter
   if(FilterStocks)
     {
      if(StringFind(description, "Stock") >= 0 ||
         StringFind(path, "Stock") >= 0 ||
         StringFind(symbol_name, ".US") >= 0 ||
         StringFind(symbol_name, ".NY") >= 0 ||
         StringFind(symbol_name, ".NS") >= 0 ||
         StringFind(description, "Shares") >= 0 ||
         StringFind(path, "Shares") >= 0 ||
         StringFind(description, "ETF") >= 0 ||
         StringFind(path, "ETF") >= 0 ||
         StringFind(description, "Equity") >= 0)
         return true;
     }

   // Indices filter
   if(FilterIndices)
     {
      if(StringFind(symbol_name, "US500") >= 0 ||
         StringFind(symbol_name, "US30") >= 0 ||
         StringFind(symbol_name, "NAS100") >= 0 ||
         StringFind(symbol_name, "SPX") >= 0 ||
         StringFind(symbol_name, "DJI") >= 0 ||
         StringFind(symbol_name, "NDX") >= 0 ||
         StringFind(description, "Index") >= 0 ||
         StringFind(path, "Index") >= 0)
         return true;
     }
     
    // Stocks filter
   if(FilterCommodities)
     {
      if(StringFind(description, "Metals") >= 0 ||
         StringFind(path, "Metals") >= 0 ||
         StringFind(description, "Spot Energy") >= 0 ||
         StringFind(path, "Spot Energy") >= 0 ||
         StringFind(description, "Energies") >= 0 ||
         StringFind(path, "Energies") >= 0 ||
         StringFind(description, "Commodities") >= 0 ||
         StringFind(path, "Commodities") >= 0 )
         return true;
     } 

   // Cryptocurrencies filter
   if(FilterCrypto)
     {
      if(StringFind(symbol_name, "BTC") >= 0 ||
         StringFind(symbol_name, "ETH") >= 0 ||
         StringFind(symbol_name, "XRP") >= 0 ||
         StringFind(symbol_name, "LTC") >= 0 ||
         StringFind(symbol_name, "BCH") >= 0 ||
         StringFind(description, "Crypto") >= 0 ||
         StringFind(path, "Crypto") >= 0 ||
         StringFind(description, "Cryptocurrency") >= 0 ||
         StringFind(path, "Cryptocurrency") >= 0 ||
         StringFind(description, "Cryptocurrencies") >= 0 ||
         StringFind(path, "Cryptocurrencies") >= 0)
         return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Batch preloading for better performance                          |
//+------------------------------------------------------------------+
bool PreloadSymbolsBatch(string &symbols[], int start_index, int batch_size)
  {
   int end_index = MathMin(start_index + batch_size, ArraySize(symbols));
   int loaded_count = 0;

   for(int i = start_index; i < end_index; i++)
     {
      if(SymbolSelect(symbols[i], true))
        {
         loaded_count++;
         // Track added symbols
         int size = ArraySize(added_symbols);
         ArrayResize(added_symbols, size + 1);
         added_symbols[size] = symbols[i];
        }
     }

   Print("Preloaded ", loaded_count, " symbols...");
   Sleep(1000);
   return loaded_count > 0;
  }
//+------------------------------------------------------------------+