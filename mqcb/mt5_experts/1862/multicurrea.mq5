//+---------------------------------------------------------------------+
//|                                                 MultiCurrEA.mq5     |
//|                                        Автор:   Maxim Khrolenko     |
//|                                        E-mail:  forevex@mail.ru     |
//+---------------------------------------------------------------------+
#property copyright "Maxim Khrolenko"
#property link      "forevex@mail.ru"

//--- Include standard libraries
#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>
//---============================== Input paramters ============================================
//--- Number of symbols
#define SIZE 3
//--- Symbol 0 ---------------------------------
input string          Symbol_0      ="EURUSD";  // (Symbol_0) Symbol
input bool            IsTrade_0     =true;      // (Trade_0) Trading allowed
//--- Parameters of Bollinger Bands
input ENUM_TIMEFRAMES Period_0      =PERIOD_H1; // (Period_0) Period of Bollinger Bands
input uint            BBPeriod_0    =20;        // (BBPeriod_0) Period for calculating the average line of Bollinger Bands
input uint            BBShift_0     =0;         // (BBShift_0) Horizontal shift of Bollinger Bands
input double          BBDeviation_0 =2.0;       // (BBDeviation_0) Standard deviation of Bollinger Bands

//--- Symbol 1 ---------------------------------
input string          Symbol_1      ="GBPUSD";  // (Symbol_1) Symbol
input bool            IsTrade_1     =true;      // (Trade_1) Trading allowed
//--- Parameters of Bollinger Bands
input ENUM_TIMEFRAMES Period_1      =PERIOD_H1; // (Period_1) Period of Bollinger Bands
input uint            BBPeriod_1    =18;        // (BBPeriod_1) Period for calculating the average line of Bollinger Bands
input uint            BBShift_1     =0;         // (BBShift_1) Horizontal shift of Bollinger Bands
input double          BBDeviation_1 =1.8;       // (BBDeviation_1) Standard deviation of Bollinger Bands

//--- Symbol 2 ---------------------------------
input string          Symbol_2      ="USDJPY";  // (Symbol_2) Symbol
input bool            IsTrade_2     =true;      // (Trade_2) Trading allowed
//--- Parameters of Bollinger Bands
input ENUM_TIMEFRAMES Period_2      =PERIOD_H1; // (Period_2) Period of Bollinger Bands
input uint            BBPeriod_2    =21;        // (BBPeriod_2) Period for calculating the average line of Bollinger Bands
input uint            BBShift_2     =0;         // (BBShift_2) Horizontal shift of Bollinger Bands
input double          BBDeviation_2 =2.1;       // (BBDeviation_2) Standard deviation of Bollinger Bands

//--- Parameters for all symbols ----------
input double          DealOfFreeMargin =1.0;    // (DealOfFreeMargin) Percent of free margin for a deal
input double          LotIncrease      =0.9;    // (LotIncrease) Ratio for increasing the next lot
input uint            MagicNumber      =555;    // (MagicNumber1) Magic number
//--- Set the digits of quotes manually
enum ENUM_digits
  {
   di4=4, // 4 digits
   di5=5, // 5 digits
  };
input ENUM_digits       Digs=5;             // Digits of quotes

//---=============================================================================================
//--- Arrays for input parameters
string          SymbolArr[SIZE];
bool            IsTradeArr[SIZE];
ENUM_TIMEFRAMES PeriodArr[SIZE];
int             BBPeriodArr[SIZE];
int             BBShiftArr[SIZE];
double          BBDeviationArr[SIZE];
//---
double          MinLotArr[SIZE],MaxLotArr[SIZE];
double          PointArr[SIZE],ContractSize[SIZE];
int             DealNumberArr[SIZE];
double          OrderLot;
long            Leverage;
datetime        Locked_bar_time_arr[SIZE],time_arr[];
//--- Indicator handels
int             BB_handle_high[SIZE],BB_handle_low[SIZE];
//--- Arrays
double          BB_upper_band_high[],BB_lower_band_high[];
double          BB_upper_band_low[],BB_lower_band_low[];
//--- Classes
CAccountInfo    AccountInfo;
CPositionInfo   PositionInfo;
CSymbolInfo     SymbolInfo;
CTrade          Trade;
//---===================== The OnInit function  =======================================================
int OnInit()
  {
//--- Section A.1: Find out whether trading on this account is allowed.
   if(AccountInfo.TradeAllowed())
      Print("Trading is allowed on this account");
   else
     {
      Print("Trading is not allowd on the account: probably you have entered using an invest password");
      ExpertRemove();
     }

//--- Section A.2: Find out whether trading using EAs is allowed on this account.
   if(AccountInfo.TradeExpert())
      Print("Automated trading is allowed on the account");
   else
     {
      Print("Automated trading using EAs or scripts is not allowed");
      ExpertRemove();
     }

//--- Section A.3: Set a timer forevent generation (in milliseconds).
   EventSetMillisecondTimer(1000);

//--- Section A.4: Copy input parameters to arrays.
   SymbolArr[0]=Symbol_0;
   SymbolArr[1]=Symbol_1;
   SymbolArr[2]=Symbol_2;

   IsTradeArr[0]=IsTrade_0;
   IsTradeArr[1]=IsTrade_1;
   IsTradeArr[2]=IsTrade_2;

   PeriodArr[0]=Period_0;
   PeriodArr[1]=Period_1;
   PeriodArr[2]=Period_2;

   BBPeriodArr[0]=(int)BBPeriod_0;
   BBPeriodArr[1]=(int)BBPeriod_1;
   BBPeriodArr[2]=(int)BBPeriod_2;

   BBShiftArr[0]=(int)BBShift_0;
   BBShiftArr[1]=(int)BBShift_1;
   BBShiftArr[2]=(int)BBShift_2;

   BBDeviationArr[0]=BBDeviation_0;
   BBDeviationArr[1]=BBDeviation_1;
   BBDeviationArr[2]=BBDeviation_2;

//--- Section A.5: Check if the symbol is available in the Market Watch.
   for(int i=0; i<SIZE; i++)
     {
      if(IsSymbolInMarketWatch(SymbolArr[i])==false)
        {
         Print(SymbolArr[i]," is not available in the market Watch. Select the right symbol");
         ExpertRemove();
        }
     }

//--- Section A.6: Check if the symbol is used more than once. This is not allowed.
   if(SIZE>1)
     {
      for(int i=0; i<SIZE-1; i++)
        {
         if(IsTradeArr[i]==false) continue;
         for(int j=i+1; j<SIZE; j++)
           {
            if(IsTradeArr[j]==false) continue;
            if(SymbolArr[i]==SymbolArr[j])
              {
               Print(SymbolArr[i]," is used more than once");
               ExpertRemove();
              }
           }
        }
     }

//--- Section A.7: Check errors in input parameters for all symbols.
   if(DealOfFreeMargin<=0.0 || DealOfFreeMargin>=100.0)
     {
      Print("Percent of free margin for a deal must be in the range 0-100%");
      ExpertRemove();
     }
   if(LotIncrease<=0.0)
     {
      Print("Ratio for increasing the next lot must be greater than 0");
      ExpertRemove();
     }

//--- Section A.8: Check errors in input parameters for each symbol.
   for(int i=0; i<SIZE; i++)
     {
      //--- Check if trading is allowed for this symbol.
      if(IsTradeArr[i]==false) continue;

      //--- A.8.1
      if(BBDeviationArr[i]<0.0)
        {
         Print("Standard deviation of Bollinger Bands for ",SymbolArr[i]," must be greater than 0.");
         ExpertRemove();
        }

      //--- A.8.2: Set handles for Bollinger Bands.
      BB_handle_high[i]=iBands(SymbolArr[i],PeriodArr[i],BBPeriodArr[i],BBShiftArr[i],BBDeviationArr[i],
                               PRICE_HIGH);
      if(BB_handle_high[i]<0)
        {
         Print("Handle of Bollinger bands on high prices for ",SymbolArr[i]," has not been created, Handle=",INVALID_HANDLE,
               "\n Error=",GetLastError());
         ExpertRemove();
        }
      //---
      BB_handle_low[i]=iBands(SymbolArr[i],PeriodArr[i],BBPeriodArr[i],BBShiftArr[i],BBDeviationArr[i],
                              PRICE_LOW);
      if(BB_handle_low[i]<0)
        {
         Print("Handle of Bollinger bands on low prices for ",SymbolArr[i]," has not been created, handle=",INVALID_HANDLE,
               "\n Error=",GetLastError());
         ExpertRemove();
        }
     }

//--- Section A.9: Calculate a leverage for this account.
   Leverage=AccountInfo.Leverage();

//--- Section A.10: Calculate data connected with the lot for each symbol.
   for(int i=0; i<SIZE; i++)
     {
      //--- Check if trading is allowed for this symbol.
      if(IsTradeArr[i]==false) continue;

      //--- Set the name for the symbol.
      SymbolInfo.Name(SymbolArr[i]);

      //--- Get the minimal and maximal volume of trade operations.
      MinLotArr[i]=SymbolInfo.LotsMin();
      MaxLotArr[i]=SymbolInfo.LotsMax();

      //--- Get the point size.
      PointArr[i]=SymbolInfo.Point();

      //--- Get the contract size.
      ContractSize[i]=SymbolInfo.ContractSize();

      //--- Set some additional parameters.
      DealNumberArr[i]=0;
      Locked_bar_time_arr[i]=D'1980.01.01 00:00';
     }
   return(0);
  }
//---===================== The OnTimer function ======================================================
void OnTimer()
  {
//--- Section B.1: Check connection of the terminal with the trade server.
   if(TerminalInfoInteger(TERMINAL_CONNECTED)==false) return;

//--- Section B.2: The main loop of the FOR operator.
   for(int N=0; N<SIZE; N++)
     {
      //--- Check if trading is allowed for this symbol.
      if(IsTradeArr[N]==false)
         continue; // break the current iteraion of FOR.

      //--- Section  B.2.1: Copy new data from the indicator handles.
      //--- The upper line of the Bollinger Bands on high prices.
      if(CopyBuffer(BB_handle_high[N],UPPER_BAND,BBShiftArr[N],1,BB_upper_band_high)<=0)
         continue; // break the current iteraion of FOR.
      ArraySetAsSeries(BB_upper_band_high,true);

      //--- The lower line of the Bollinger Bands on high prices.
      if(CopyBuffer(BB_handle_high[N],LOWER_BAND,BBShiftArr[N],1,BB_lower_band_high)<=0)
         continue; // break the current iteraion of FOR.
      ArraySetAsSeries(BB_lower_band_high,true);

      //--- The upper line of the Bollinger Bands on low prices.
      if(CopyBuffer(BB_handle_low[N],UPPER_BAND,BBShiftArr[N],1,BB_upper_band_low)<=0)
         continue; // break the current iteraion of FOR.
      ArraySetAsSeries(BB_upper_band_low,true);

      //--- The lower line of the Bollinger Bands on low prices.
      if(CopyBuffer(BB_handle_low[N],LOWER_BAND,BBShiftArr[N],1,BB_lower_band_low)<=0)
         continue; // break the current iteraion of FOR.
      ArraySetAsSeries(BB_lower_band_low,true);

      //--- Section  B.2.2: Copy the open time of the current bar.
      if(CopyTime(SymbolArr[N],PeriodArr[N],0,1,time_arr)<=0)
         continue; // break the current iteraion of FOR.
      ArraySetAsSeries(time_arr,true);

      //--- Section  B.2.3: Calculate the current Ask and Bid prices.
      SymbolInfo.Name(SymbolArr[N]);
      SymbolInfo.RefreshRates();
      double Ask=SymbolInfo.Ask();
      double Bid=SymbolInfo.Bid();

      //--- Section B.2.4: Close position ===============================================
      if(PositionSelect(SymbolArr[N]))
        {
         //--- Section  B.2.4.1: Close the BUY position.
         if(PositionInfo.PositionType()==POSITION_TYPE_BUY)
           {
            if(Bid>=BB_lower_band_high[0] || DealNumberArr[N]==0)
              {
               DealNumberArr[N]=0;
               if(!Trade.PositionClose(SymbolArr[N]))
                 {
                  Print("Closing of position Buy ",SymbolArr[N]," failed. Code=",Trade.ResultRetcode(),
                        " (",Trade.ResultRetcodeDescription(),")");
                  continue; // break the current iteration of FOR.
                 }
               else
                 {
                  Print("Position Buy ",SymbolArr[N]," successfully closed. Code=",Trade.ResultRetcode(),
                        " (",Trade.ResultRetcodeDescription(),")");
                  continue; // break the current iteration of FOR.
                 }
              }
           }
         //--- Section  B.2.4.1: Close the SELL position.
         if(PositionInfo.PositionType()==POSITION_TYPE_SELL)
           {
            if(Ask<=BB_upper_band_low[0] || DealNumberArr[N]==0)
              {
               DealNumberArr[N]=0;
               if(!Trade.PositionClose(SymbolArr[N]))
                 {
                  Print("Closing of position Sell ",SymbolArr[N]," failed. Code=",Trade.ResultRetcode(),
                        " (",Trade.ResultRetcodeDescription(),")");
                  continue; // break the current iteration of FOR.
                 }
               else
                 {
                  Print("Position Sell ",SymbolArr[N]," successfully closed. Code=",Trade.ResultRetcode(),
                        " (",Trade.ResultRetcodeDescription(),")");
                  continue; // Break the current iteration of FOR.
                 }
              }
           }
        }

      //--- Section  B.2.5: Position opening limits =================================

      //--- Section  B.2.5.1: The price is in the position closing area.
      if(Bid>=BB_lower_band_high[0] && Ask<=BB_upper_band_low[0])
        {
         DealNumberArr[N]=0;
         continue; // break the current iteration of FOR.
        }

      //--- Section B.2.5.2: A position has been already opened on the current bar.
      if(Locked_bar_time_arr[N]>=time_arr[0])
         continue; // break the current iteration of FOR.

      //============================   Open position   ============================

      //--- Section  B.2.6: A BUY signal.
      if(Locked_bar_time_arr[N]<time_arr[0] && Ask<=BB_lower_band_low[0])
        {
         //--- Section  B.2.6.1: Determine the number of the current deal.
         DealNumberArr[N]++;

         //--- Section  B.2.6.2: Calculate lot as the percent of free margin.
         OrderLot=AccountInfoDouble(ACCOUNT_FREEMARGIN)*DealOfFreeMargin/100*Leverage/ContractSize[N];

         //--- Section  B.2.6.3: Increase lot starting from the second deal.
         if(DealNumberArr[N]>1)
            OrderLot=OrderLot*LotIncrease*(DealNumberArr[N]-1);

         //--- Section  B.2.6.4: Check the allowed lot size.
         OrderLot=NormalizeDouble(OrderLot,2);
         if(OrderLot<MinLotArr[N]) OrderLot=MinLotArr[N];
         if(OrderLot>MaxLotArr[N]) OrderLot=MaxLotArr[N];

         if(!Trade.Buy(OrderLot,SymbolArr[N]))
           {
            //--- Section  B.2.6.5: If buying failed, minus 1 from the deal number.
            DealNumberArr[N]--;
            Print("Buying ",SymbolArr[N]," failed. Code=",Trade.ResultRetcode(),
                  " (",Trade.ResultRetcodeDescription(),")");
            continue; // break the current iteration of FOR.
           }
         else
           {
            //--- Section  B.2.6.6: Remember the current time to block trading on the current bar.
            Locked_bar_time_arr[N]=TimeCurrent();
            Print("Buying ",SymbolArr[N]," has been successfully completed. Code=",Trade.ResultRetcode(),
                  " (",Trade.ResultRetcodeDescription(),")");
            continue; // break the current iteration of FOR.
           }
        }

      //--- Section  B.2.7: A SELL signal.
      if(Locked_bar_time_arr[N]<time_arr[0] && Bid>=BB_upper_band_high[0])
        {
         //--- Section  B.2.7.1: Define the number of the current deal.
         DealNumberArr[N]++;

         //--- Section  B.2.7.2: Calculate the lot as the percent of free margin.
         OrderLot=AccountInfoDouble(ACCOUNT_FREEMARGIN)*DealOfFreeMargin/100*Leverage/ContractSize[N];

         //--- Section  B.2.7.3: Increase lot starting from the second deal.
         if(DealNumberArr[N]>1)
            OrderLot=OrderLot*LotIncrease*(DealNumberArr[N]-1);

         //--- Section  B.2.7.4: Check the allowed lot size.
         OrderLot=NormalizeDouble(OrderLot,2);
         if(OrderLot<MinLotArr[N]) OrderLot=MinLotArr[N];
         if(OrderLot>MaxLotArr[N]) OrderLot=MaxLotArr[N];

         if(!Trade.Sell(OrderLot,SymbolArr[N]))
           {
            //--- Section  B.2.7.5: If selling failed, minus 1 from the deal number.
            DealNumberArr[N]--;
            Print("Selling ",SymbolArr[N]," has failed. Code=",Trade.ResultRetcode(),
                  " (",Trade.ResultRetcodeDescription(),")");
            continue; // break the current iteration of FOR.
           }
         else
           {
            //--- Section  B.2.7.6: Remember the current time to block trading on the current bar.
            Locked_bar_time_arr[N]=TimeCurrent();
            Print("Sell ",SymbolArr[N]," has been successfully completed. Code=",Trade.ResultRetcode(),
                  " (",Trade.ResultRetcodeDescription(),")");
            continue; // break the current iteration of FOR.
           }
        }
     } //--- The end of the main loop of the FOR operator.
  }
//---===================== The OnDeinit function  =====================================================
void OnDeinit(const int reason)
  {
   for(int i=0; i<SIZE; i++)
     {
      //--- Section  C.1: Release the indicators.
      IndicatorRelease(BB_handle_high[i]);
      IndicatorRelease(BB_handle_low[i]);
     }
   EventKillTimer();
  }
//===================== Functions  =============================

//--- IsSymbolInMarketWatch() - start
bool IsSymbolInMarketWatch(string f_Symbol)
  {
   for(int s=0; s<SymbolsTotal(false); s++)
     {
      if(f_Symbol==SymbolName(s,false))
         return(true);
     }
   return(false);
  }
//--- IsSymbolInMarketWatch() - end
