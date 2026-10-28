//+------------------------------------------------------------------+
//|                                          Create_Initial_Data.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Script creates training and testing datasets                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/dng"
#property version   "1.00"
#property script_show_inputs
//+------------------------------------------------------------------+
//| External parameters for script operation                         |
//+------------------------------------------------------------------+
input datetime Start = D'2015.01.01 00:00:00';  // Start of the population period
input datetime End = D'2020.12.31 23:59:00';    // End of the population period
input ENUM_TIMEFRAMES TimeFrame = PERIOD_M5;    // Timeframe for loading data
input int      BarsToLine = 40;                 // Number of historical bars in one pattern
input string   StudyFileName = "study_data.csv";// File name to write the training dataset
input string   TestFileName  = "test_data.csv"; // File name to write the testing dataset
input bool     NormalizeData = true;            // Data normalization flag
//+------------------------------------------------------------------+
//| Script program start                                             |
//+------------------------------------------------------------------+
void OnStart(void)
  {
//--- Connect indicators to the chart
   int h_ZZ = iCustom(_Symbol, TimeFrame, "Examples\\ZigZag.ex5", 48, 1, 47);
   int h_RSI = iRSI(_Symbol, TimeFrame, 12, PRICE_TYPICAL);
   int h_MACD = iMACD(_Symbol, TimeFrame, 12, 48, 12, PRICE_TYPICAL);
   double close[];
   if(CopyClose(_Symbol, TimeFrame, Start, End, close) <= 0)
      return;
//--- Load indicator data into dynamic arrays
   double zz[], macd_main[], macd_signal[], rsi[];
   datetime end_zz = End + PeriodSeconds(TimeFrame) * 500;
   if(h_ZZ == INVALID_HANDLE || CopyBuffer(h_ZZ, 0, Start, end_zz, zz) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "ZigZag");
      return;
     }
   if(h_RSI == INVALID_HANDLE || CopyBuffer(h_RSI, 0, Start, End, rsi) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "RSI");
      return;
     }
   if(h_MACD == INVALID_HANDLE || CopyBuffer(h_MACD, MAIN_LINE, Start, End, macd_main) <= 0 ||
      CopyBuffer(h_MACD, SIGNAL_LINE, Start, End, macd_signal) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "MACD");
      return;
     }
   int total = ArraySize(close);
   double target1[], target2[], macd_delta[], test[];
   if(ArrayResize(target1, total) <= 0 || ArrayResize(target2, total) <= 0 ||
      ArrayResize(test, total) <= 0 || ArrayResize(macd_delta, total) <= 0)
      return;
//--- Calculate targets: direction and distance to the nearest extremum
   ArrayInitialize(test, 0);
   double extremum = -1;
   for(int i = ArraySize(zz) - 2; i >= 0; i--)
     {
      if(zz[i + 1] > 0 && zz[i + 1] != EMPTY_VALUE)
         extremum = zz[i + 1];
      if(i >= total)
         continue;
      target2[i] = extremum - close[i];
      target1[i] = (target2[i] >= 0 ? 1 : -1);
      macd_delta[i] = macd_main[i] - macd_signal[i];
     }
//--- Data normalization
   if(NormalizeData)
     {
      double main_norm = MathMax(MathAbs(macd_main[ArrayMinimum(macd_main)]),
                                 macd_main[ArrayMaximum(macd_main)]);
      double sign_norm = MathMax(MathAbs(macd_signal[ArrayMinimum(macd_signal)]),
                                 macd_signal[ArrayMaximum(macd_signal)]);
      double delt_norm = MathMax(MathAbs(macd_delta[ArrayMinimum(macd_delta)]),
                                 macd_delta[ArrayMaximum(macd_delta)]);
      for(int i = 0; i < total; i++)
        {
         rsi[i] = (rsi[i] - 50.0) / 50.0;
         macd_main[i] /= main_norm;
         macd_signal[i] /= sign_norm;
         macd_delta[i] /= delt_norm;
        }
     }
//--- Randomly generate data indexes for the test dataset
   int for_test = (int)((total - BarsToLine) * 0.2);
   for(int i = 0; i < for_test; i++)
     {
      int t = (int)((double)(MathRand() * MathRand()) / MathPow(32767.0, 2) * (total - 1 - BarsToLine)) + BarsToLine;
      if(test[t] == 1)
        {
         i--;
         continue;
        }
      test[t] = 1;
     }
//--- Open the training dataset file for writing
   int Study = FileOpen(StudyFileName, FILE_WRITE | FILE_CSV | FILE_ANSI, ",", CP_UTF8);
   if(Study == INVALID_HANDLE)
     {
      PrintFormat("Error opening file %s: %d", StudyFileName, GetLastError());
      return;
     }
//--- Open the testing dataset file for writing
   int Test = FileOpen(TestFileName, FILE_WRITE | FILE_CSV | FILE_ANSI, ",", CP_UTF8);
   if(Test == INVALID_HANDLE)
     {
      PrintFormat("Error opening file %s: %d", TestFileName, GetLastError());
      return;
     }
//--- Write datasets to files
   for(int i = BarsToLine - 1; i < total; i++)
     {
      Comment(StringFormat("%.2f%%", i * 100.0 / (double)(total - BarsToLine)));
      if(!WriteData(target1, target2, rsi, macd_main, macd_signal, macd_delta, i, BarsToLine, (test[i] == 1 ? Test : Study)))
        {
         PrintFormat("Error to write data: %d", GetLastError());
         break;
        }
     }
//--- Close files
   Comment("");
   FileFlush(Study);
   FileClose(Study);
   FileFlush(Test);
   FileClose(Test);
   PrintFormat("Study data saved to file %s\\MQL5\\Files\\%s",
               TerminalInfoString(TERMINAL_DATA_PATH), StudyFileName);
   PrintFormat("Test data saved to file %s\\MQL5\\Files\\%s",
               TerminalInfoString(TERMINAL_DATA_PATH), TestFileName);
  }
//+------------------------------------------------------------------+
//| Function for writing pattern to file                             |
//+------------------------------------------------------------------+
bool WriteData(double &target1[],      // Buffer 1 of target values
               double &target2[],      // Buffer 2 of target values
               double &data1[],        // Buffer 1 of historical data
               double &data2[],        // Buffer 2 of historical data
               double &data3[],        // Buffer 3 of historical data
               double &data4[],        // Buffer 4 of historical data
               int cur_bar,            // Current pattern end bar
               int bars,               // Number of historical bars in one pattern
               int handle)             // File handle for writing
  {
//--- Validate file handle
   if(handle == INVALID_HANDLE)
     {
      Print("Invalid Handle");
      return false;
     }
//--- Determine the index of the first record of pattern historical data
   int start = cur_bar - bars + 1;
   if(start < 0)
     {
      Print("Too small current bar");
      return false;
     }
//--- Check the correctness of the data index and write it to a file
   int size1 = ArraySize(data1);
   int size2 = ArraySize(data2);
   int size3 = ArraySize(data3);
   int size4 = ArraySize(data4);
   int sizet1 = ArraySize(target1);
   int sizet2 = ArraySize(target2);
   string pattern = (string)(start < size1 ? data1[start] : 0.0) + "," +
                    (string)(start < size2 ? data2[start] : 0.0) + "," +
                    (string)(start < size3 ? data3[start] : 0.0) + "," +
                    (string)(start < size4 ? data4[start] : 0.0);
   for(int i = start + 1; i <= cur_bar; i++)
     {
      pattern = pattern + "," + (string)(i < size1 ? data1[i] : 0.0) + "," +
                (string)(i < size2 ? data2[i] : 0.0) + "," +
                (string)(i < size3 ? data3[i] : 0.0) + "," +
                (string)(i < size4 ? data4[i] : 0.0);
     }
   return (FileWrite(handle, pattern, (double)(cur_bar < sizet1 ? target1[cur_bar] : 0), (double)(cur_bar < sizet2 ? target2[cur_bar] : 0)) > 0);
  }
//+------------------------------------------------------------------+
