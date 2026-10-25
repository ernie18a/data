//+------------------------------------------------------------------+
//|              Trade on qualified RSI(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Ron Thompson"
#property link      "http://www.lightpatch.com/forex"
#property version "1.002"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
input double Lots=0.1;
input ushort Stop_Loss=21;
input int    CountBars=5;                    // minimum -> "1"
//---
ulong          m_magic=97531856;             // magic number
ulong          m_slippage=30;                // slippage
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
int    handle_iRSI;                          // variable for storing the handle of the iRSI indicator
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(CountBars<1)
     {
      Print("Error! CountBars<1");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
//SetMarginMode();
//if(!IsHedging())
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),28,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   bool found=false;
   double rsi=0.0;
   bool flagA=false;
   double nslB=0.0,nslS=0.0,osl=0.0,ccl=0.0;
// only one position at a time/per symbol 
// so see if our symbol has an position open

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            // An position for this Symbol() is open so check
            // the stoploss, adjust as price changes
            // in the favorable direction.
            ccl=iClose(1); // 1 NOT 0 or the swings will kill ya!
            osl=m_position.StopLoss();
            nslB=m_symbol.NormalizePrice(ccl-(Stop_Loss*m_adjusted_point));
            nslS=m_symbol.NormalizePrice(ccl+(Stop_Loss*m_adjusted_point));
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(nslB>osl && m_position.PriceCurrent()<Stop_Loss*m_adjusted_point>nslB)
                 {
                  string text="BUY MODIFY "+m_symbol.Name()+
                              " osl="+DoubleToString(osl,m_symbol.Digits())+
                              " nsl="+DoubleToString(nslB,m_symbol.Digits());
                  Print(text);
                  Comment(text);
                  if(!m_trade.PositionModify(m_position.Ticket(),nslB,m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position current price ",m_position.PriceCurrent()," -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(nslS<osl && m_position.PriceCurrent()+Stop_Loss*m_adjusted_point<nslS)
                 {
                  string text="SELL MODIFY "+m_symbol.Name()+
                              " osl="+DoubleToString(osl,m_symbol.Digits())+
                              " nsl="+DoubleToString(nslS,m_symbol.Digits());
                  Print(text);
                  Comment(text);
                  if(!m_trade.PositionModify(m_position.Ticket(),nslS,m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position current price ",m_position.PriceCurrent()," -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
            // set the 'found' flag so we don't buy/sell any more
            found=true;
            break;
           }

   if(!found)
     {
      //Comment(" ");
      //
      rsi=iRSIGet(1);
      //
      if(rsi>=55)
        {
         flagA=true;
         for(int i=2; i<=2+CountBars; i++)
           {
            if(iRSIGet(i)<55)
              {
               flagA=false;
               break;
              }
           }
         if(flagA)
           {
            if(!RefreshRates())
               return;
            // it seems backwards, but it's because qualified RSI turns
            // out to be a top or bottom indicator much more often than
            // it turns out to be a trend indicator.
            Print("SELL started  ",m_symbol.Bid());
            OpenSell(m_symbol.Bid()+Stop_Loss*m_adjusted_point,0.0);
           }
        }
      if(rsi<=45)
        {
         flagA=true;
         for(int i=2; i<=2+CountBars; i++)
           {
            if(iRSIGet(i)>45)
              {
               flagA=false;
               break;
              }
           }
         if(flagA)
           {
            if(!RefreshRates())
               return;
            // it seems backwards, but it's because qualified RSI turns
            // out to be a top or bottom indicator much more often than
            // it turns out to be a trend indicator.
            Print("BUY started  ",m_symbol.Ask());
            OpenBuy(m_symbol.Ask()-Stop_Loss*m_adjusted_point,0.0);
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iRSI                                |
//+------------------------------------------------------------------+
double iRSIGet(const int index)
  {
   double RSI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,0,index,1,RSI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RSI[0]);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=Lots)
        {
         if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=Lots)
        {
         if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
