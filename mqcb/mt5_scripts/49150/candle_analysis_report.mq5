//+------------------------------------------------------------------+
//|                              Copyright 2024, Enrique Enguix      |
//|                              https://www.mql5.com/es/users/envex |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Enrique Enguix"
#property link      "https://www.mql5.com/es/users/envex"
#property version   "1.00"
#property strict

// Structure to hold candle amplitude and index
struct CandleAmplitude
  {
   double            amplitude;
   int               index;
  };

// Function to compare candle amplitudes
bool CompareAmplitude(const CandleAmplitude &a, const CandleAmplitude &b)
  {
   return a.amplitude > b.amplitude;
  }

// Entry point of the script
void OnStart()
  {
// Arrays to store candle data
   double openPrices[];
   double closePrices[];
   double highPrices[];
   double lowPrices[];

   ArraySetAsSeries(openPrices, true);
   ArraySetAsSeries(closePrices, true);
   ArraySetAsSeries(highPrices, true);
   ArraySetAsSeries(lowPrices, true);

// Copy price data
   int copied = CopyOpen(Symbol(), Period(), 0, 5000, openPrices);
   copied = CopyClose(Symbol(), Period(), 0, 5000, closePrices);
   copied = CopyHigh(Symbol(), Period(), 0, 5000, highPrices);
   copied = CopyLow(Symbol(), Period(), 0, 5000, lowPrices);

// Variables to track candle counts and amplitudes
   int bullishCount = 0;
   int bearishCount = 0;
   int neutralCount = 0;
   double bullishAmplitudeTotal = 0.0;
   double bearishAmplitudeTotal = 0.0;

// Arrays to store top 5 bullish and bearish candles by amplitude
   CandleAmplitude bullishCandles[5];
   CandleAmplitude bearishCandles[5];

// Calculate candle amplitudes and categorize candles
   for(int i = 0; i < 5000; i++)
     {
      double amplitude = highPrices[i] - lowPrices[i];

      if(closePrices[i] > openPrices[i])
        {
         bullishCount++;
         bullishAmplitudeTotal += amplitude;

         // Update top 5 bullish candles
         for(int j = 0; j < 5; j++)
           {
            if(amplitude > bullishCandles[j].amplitude)
              {
               for(int k = 4; k > j; k--)
                 {
                  bullishCandles[k] = bullishCandles[k - 1];
                 }
               bullishCandles[j].amplitude = amplitude;
               bullishCandles[j].index = i;
               break;
              }
           }
        }
      else
         if(closePrices[i] < openPrices[i])
           {
            bearishCount++;
            bearishAmplitudeTotal += amplitude;

            // Update top 5 bearish candles
            for(int j = 0; j < 5; j++)
              {
               if(amplitude > bearishCandles[j].amplitude)
                 {
                  for(int k = 4; k > j; k--)
                    {
                     bearishCandles[k] = bearishCandles[k - 1];
                    }
                  bearishCandles[j].amplitude = amplitude;
                  bearishCandles[j].index = i;
                  break;
                 }
              }
           }
         else
           {
            neutralCount++;
           }
     }

// Get pip value for the financial instrument
   double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

// Create comment with structured information
   string commentInfo = "=== Candle Analysis Report ===\n\n";
   commentInfo += "Number of bullish candles: " + IntegerToString(bullishCount) + "\n";
   commentInfo += "Average amplitude of bullish candles in points: " + DoubleToString(bullishAmplitudeTotal / bullishCount / pipValue, 0) + " points\n\n";
   commentInfo += "Number of bearish candles: " + IntegerToString(bearishCount) + "\n";
   commentInfo += "Average amplitude of bearish candles in points: " + DoubleToString(bearishAmplitudeTotal / bearishCount / pipValue, 0) + " points\n\n";
   commentInfo += "Number of neutral candles: " + IntegerToString(neutralCount) + "\n\n";
   commentInfo += "Top 5 bullish candles by amplitude:\n";

   for(int i = 0; i < 5; i++)
     {
      commentInfo += "Candle " + IntegerToString(i+1) + ": Index = " + IntegerToString(bullishCandles[i].index)
                     + ", Amplitude = " + DoubleToString(bullishCandles[i].amplitude / pipValue, 0) + " points\n";
     }

   commentInfo += "\nTop 5 bearish candles by amplitude:\n";
   for(int i = 0; i < 5; i++)
     {
      commentInfo += "Candle " + IntegerToString(i+1) + ": Index = " + IntegerToString(bearishCandles[i].index)
                     + ", Amplitude = " + DoubleToString(bearishCandles[i].amplitude / pipValue, 0) + " points\n";
     }

// Display the analysis report as a comment in the chart
   Comment(commentInfo);
  }
//+------------------------------------------------------------------+
