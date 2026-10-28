//+------------------------------------------------------------------+
//|                                          MW Download History.mq5 |
//|                  Copyright 2026, Martinware (Martin Bittencourt) |
//|                    https://www.mql5.com/en/users/momergil/seller |
//| Inspired by the work "downloadhistory.mq5", by etrader 2011      |
//| http://efftrading.ru                                             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Martinware™ (Martin Bittencourt)"
#property link "https://www.mql5.com/en/users/momergil/seller"
#property version "1.1"
#property description "This script allows the download of all available data of one or "
      "more symbols in Market Watch and saves it into a file."

//---- settings
#property script_show_inputs

//--- imports

//--- defines 1
#define MW_DH_DEST_FOLDER "MW Download History"
#define MW_DH_MAX_ATTEMPTS 10

//--- includes

//--- defines 2

//--- resources

//--- enums

//--- structs and classes

//--- input parameters
input group "Symbols"
sinput string SingleSymbol = ""; //Symbol to download (null = all Market Watch symbols)
sinput string SkipSymbolWithThis = "_"; //....Skip any symbol with this string
sinput string SkipTheseSymbols = ""; //....Skip any of these symbols (use ; to separate)

input group "Others"
sinput ENUM_TIMEFRAMES PeriodToDownload = PERIOD_M1; //Timeframe


//--- others

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("MW DH: Start");
   
   if (SingleSymbol != "")
   {
      if (!SymbolInfoInteger(SingleSymbol,SYMBOL_SELECT))
      {
         Print("MW DH: The informed symbol must be in the Market Watch list");
         
         Print("MW DH: End");
         
         return;
      }
      
      if (!SymbolSelect(SingleSymbol,true))
      {
         Print("MW DH: Error loading the informed symbol (error code: ",GetLastError(),")");
         
         Print("MW DH: End");
         
         return;
      }
     
      downloadThisSymbol(SingleSymbol);
   }
   else
   {
      const int allSymCount = SymbolsTotal(true);
      
      if (SkipSymbolWithThis == "" && SkipTheseSymbols == "")
      {
         Print("MW DH: Downloading and saving data of ",allSymCount," symbols");
         
         for (int aaa = 0; aaa < allSymCount; ++aaa)
            downloadThisSymbol(SymbolName(aaa,true));
      }
      else //if (!SkipSymbolWithThis == "" || !SkipTheseSymbols == "")
      {
         string excSymArray[];
         
         const int excSymCount = StringSplit(SkipTheseSymbols,';',excSymArray);
         
         if (excSymCount > 0)
            Print("MW DH: Downloading and saving data of aprox. ",allSymCount - excSymCount," symbols");
         else
            Print("MW DH: Downloading and saving data of aprox. ",allSymCount," symbols");
         
         for (int aaa = 0; aaa < allSymCount; ++aaa)
         {
            const string symb = SymbolName(aaa,true);
            
            if (StringFind(symb,SkipSymbolWithThis) < 0)
            {
               if (excSymCount > 0)
               {
                  bool foundSymInExecSymList = false;
                  
                  for (int aaa = 0; aaa < excSymCount; ++aaa)
                  {
                     if (StringFind(symb,excSymArray[aaa]) > -1)
                     {
                        foundSymInExecSymList = true;
                        
                        break;
                     }
                  }
                  
                  if (!foundSymInExecSymList)
                     downloadThisSymbol(symb);
                  else
                     Print("MW DH: ",symb,"'s data will not be downloaded because of skip symbol condition");
               }
               else
                  downloadThisSymbol(symb);
            }
            else
               Print("MW DH: ",symb,"'s data will not be downloaded because of skip string condition");
         }
      }
   }
   
   Print("MW DH: End");
}
//+------------------------------------------------------------------+
//| Main and preparation function: opens file, if exists, or creates |
//| it                                                               |
//+------------------------------------------------------------------+
void downloadThisSymbol(const string symbol)
{
   Print("MW DH: Saving data of symbol \"",symbol,"\"");
   
   //Get first date of the history on the server
   const datetime firstDataD1DT = (datetime)SeriesInfoInteger(symbol,PeriodToDownload,SERIES_SERVER_FIRSTDATE);
   
   Print("MW DH: First data's datetime: ",firstDataD1DT);
   
   //Try to find already existing file to save the data; if success, locate the last datetime saved
   //If not, create the file and set the header
   datetime lastSavedData = 0;
   
   //Search in COMMON folder for any file with the asset's name
   const string dataFileName = MW_DH_DEST_FOLDER + "\\" + symbol 
         + " " + StringSubstr(EnumToString(PeriodToDownload),7) + ".csv";
   
   int resHandle = FileOpen(dataFileName,FILE_READ|FILE_CSV|FILE_COMMON,'\n');
   
   if (resHandle == INVALID_HANDLE)
   {
      Print("MW DH: No file for this symbol found. Creating one");
      
      resHandle = FileOpen(dataFileName,FILE_WRITE|FILE_CSV|FILE_COMMON);
      
      if (resHandle == INVALID_HANDLE)
      {
         Print("MW DH: Error opening file to write the data (error code: ",GetLastError(),")");
         
         return;
      }
      
      FileWrite(resHandle,
            "<DATE>"
            + "\t<TIME>"
            + "\t<OPEN>"
            + "\t<HIGH>"
            + "\t<LOW>"
            + "\t<CLOSE>"
            + "\t<TICKVOL>"
            + "\t<VOL>"
            + "\t<SPREAD>"
            );
      
      /*
      Print("MW DH: Writing header: "
            ,FileWrite(resHandle,
                  "<DATE>"
                  + "\t<TIME>"
                  + "\t<OPEN>"
                  + "\t<HIGH>"
                  + "\t<LOW>"
                  + "\t<CLOSE>"
                  + "\t<TICKVOL>"
                  + "\t<VOL>"
                  + "\t<SPREAD>"
                  )
            ," header bytes written");
      */
   }
   else
   {
      string readRes;
      
      do
      {
         readRes = FileReadString(resHandle);
      }
      while (!FileIsLineEnding(resHandle) && !IsStopped());
      
      //Last line reached
      StringTrimRight(readRes);
      
      const string justDT = StringSubstr(readRes,0,19);
      
      lastSavedData = StringToTime(justDT);
      
      Print("MW DH: Symbol file found. Last saved data's datetime: ",lastSavedData);
      
      //Close to read, open to write
      FileClose(resHandle);
      
      resHandle = FileOpen(dataFileName,FILE_WRITE|FILE_READ|FILE_CSV|FILE_COMMON);
      
      if (resHandle == INVALID_HANDLE)
      {
         Print("MW DH: Error opening file to write the data (error code: ",GetLastError(),")");
         
         return;
      }
      
      FileSeek(resHandle,0,SEEK_END);
   }
   
   //
   if (!getAndSaveLoadHistory(symbol,PeriodToDownload,lastSavedData,resHandle))
      Print("MW DH: Error loading and saving history of symbol \"",symbol,"\"");
   else
      Print("MW DH: Success loading and saving history of symbol \"",symbol,"\"");
      
   FileClose(resHandle);
}
//+------------------------------------------------------------------+
//| Get data from server and fill the file with it                   |
//+------------------------------------------------------------------+
bool getAndSaveLoadHistory(const string symbol
      , const ENUM_TIMEFRAMES period
      , const datetime startDT
      , int& resHandle)
{
   if (!SymbolSelect(symbol,true))
   {
      Print("MW DH: Error selecting symbol");
      
      return false;
   }
   
   //Check if data is present
   datetime avHistFirstDate = 0;
   
   if (!SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,avHistFirstDate))
   {
      Print("MW DH: Error getting the first data's datetime (error code: ",GetLastError(),")");
      
      return false;
   }
   
   if (avHistFirstDate == 0
         || (startDT != 0 && avHistFirstDate > startDT))
   {
      Print("MW DH: Error in value of first available datetime (result: "
            ,avHistFirstDate,"; reference: ",startDT,")");
      
      return false;
   }
   
   //
   MqlRates rates[1];
   
   if (SeriesInfoInteger(symbol,period,SERIES_TERMINAL_FIRSTDATE,avHistFirstDate))
   {
      //There is loaded data to build timeseries
      if (avHistFirstDate > 0)
      {
         //Force timeseries build
         if (CopyRates(symbol,period,avHistFirstDate + PeriodSeconds(period),1,rates) < 0)
         {
            Print("MW DH: Error when copying rates to force terminal loading symbol's data "
                  "(error code: ",GetLastError(),")");
            
            return false;
         }
         
         //Check date
         if (SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,avHistFirstDate))
         {
            if (avHistFirstDate == 0
                  || (startDT != 0 && avHistFirstDate > startDT))
            {
               Print("MW DH: Error in second attempt to get data from before the start datetime");
            
               return false;
            }
         }
      }
   }   
   
   //
   const int maxBars = TerminalInfoInteger(TERMINAL_MAXBARS);

   //Load symbol history info
   datetime firstServerDate = 0;
   
   for (int aaa = 0; aaa < 100 && !IsStopped(); ++aaa)
   {
      if (!SeriesInfoInteger(symbol,period,SERIES_SERVER_FIRSTDATE,firstServerDate))
         Sleep(5);
   }

   //Fix start date for loading
   datetime actStartDT;
   
   if (startDT == 0)
      actStartDT = firstServerDate;
   else
      actStartDT = startDT + PeriodSeconds(period); //Always from 1 bar onwards
   
   if (avHistFirstDate > 0 && avHistFirstDate < firstServerDate)
   {
      Print("MW DH: Warning: first server date, "
            ,firstServerDate
            ,", does not match to first series date, "
            ,avHistFirstDate);
   }
   
   const datetime tlDT = TimeLocal();

   if (tlDT <= actStartDT)
   {
      Print("MW DH: The data file is updated");
      
      return true;
   }

   //Load data step by step
   int failCount = 1;
   
   while (!IsStopped())
   {
      //Wait for timeseries build
      for (int aaa = 0; aaa < 10000 && !IsStopped(); ++aaa)
      {
         if (!SeriesInfoInteger(symbol,period,SERIES_SYNCHRONIZED))
            Sleep(5);
         else
            break;
      }
      
      //Ask for built bars
      const int barsCount = Bars(symbol,period);
      
      if (barsCount > 0)
      {
         if (barsCount > maxBars)
         {
            Print("MW DH: Unexpected behavior: the number of available bars ("
                  ,barsCount,") is bigger than the maximum bars (",maxBars,")");
            
            return false;
         }
      }
      
      //Getting the data
      MqlRates rates[];

      const int cpyRes = CopyRates(symbol,period,actStartDT,tlDT,rates);
      
      Print("MW DH: Total available bars: ",barsCount
            ," (maximum: ",maxBars
            ,"); copied bars: ",cpyRes
            ,"; from: ",actStartDT);
      
      if (cpyRes > 0)
      {
         //Check for data
         if (rates[0].time < actStartDT)
         {
            Print("MW DH: Copied data is invalid (",rates[0].time,")");
            
            return false;
         }
         
         //Print("DEBUG: Now it's going to start saving starting from: ",rates[0].time);
         
         for (int aaa = 0; aaa < cpyRes; ++aaa)
            writeToFile(resHandle,rates[aaa],symbol);
         
         //Print("DEBUG: Now it's finishing saving in file at: ",rates[ArraySize(rates) - 1].time);
         
         break;
      }
      else if (cpyRes == 0)
      {
         Print("MW DH: The data file is updated");
         
         break;
      }
      else
      {
         if (++failCount > MW_DH_MAX_ATTEMPTS)
            return false;
         
         Sleep(10);
      }
   }
   
   //
   return true;
}
//+------------------------------------------------------------------+
//| Function only to write to file                                   |
//+------------------------------------------------------------------+
void writeToFile(int& resHandle
      , MqlRates& barData
      , const string symbol)
{
   const int tDigits = int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   
   string dataS = TimeToString(barData.time,TIME_DATE)
         + "\t" + TimeToString(barData.time,TIME_MINUTES|TIME_SECONDS)
         + "\t" + DoubleToString(barData.open,tDigits)
         + "\t" + DoubleToString(barData.high,tDigits)
         + "\t" + DoubleToString(barData.low,tDigits)
         + "\t" + DoubleToString(barData.close,tDigits)
         + "\t" + IntegerToString(barData.tick_volume)
         + "\t" + IntegerToString(barData.real_volume)
         + "\t" + IntegerToString(barData.spread);

   FileWrite(resHandle,dataS);

   //Print("MW DH: Writing: ",dataS
         //,"; ",FileWrite(resHandle,dataS)," bytes written");
}
//+------------------------------------------------------------------+