//+------------------------------------------------------------------+
//|                             scalpel(barabashkakvn's edition).mq5 |
//|                                           Copyright © 2009, ryaz |
//|                                               ryaz://outta.here/ |
//+------------------------------------------------------------------+
#property copyright "ryaz"
#property link      "outta@here"
#property version   "1.001"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                      // trade position object
CTrade         m_trade;                         // trading object
CSymbolInfo    m_symbol;                        // symbol info object
CAccountInfo   m_account;                       // account info wrapper

#define EA "Scalpel"
#define VER "1_01"

input double   Lots=-5;         // if Lots are negative means the percent of free margin used
input ushort   InpTakeProfit     = 30;
input ushort   InpStopLoss       = 21;
input ushort   InpTrailingStop   = 10;
input int      cciPeriod         = 15;
input double   cciLimit          = 3;
input int      MaxPos            = 1;           // open positions allowed in one dir.
input uint     InpInterval       = 0;           // Minutes before adding a position (0=not used) 
input uint     Reduce            = 600;         // Minutes before reducing TP by one pip (0=not used)
input uint     Live              = 0;           // Minutes before closing an order regardless profit (0=not used)
input int      Volatility        = 14;          // volatility bars (positive>directional or negative>non dir.)
input ushort   InpThreshold      = 1;           // pip threshold for volatility
input uchar    FridayClose       = 22;          // At what time to close all orders on Friday (0=not used)
input ushort   InpSlippage       = 3;
input double   InpSpreadLimit    = 5.5;
input ulong    MagicNumber       = 123581321;
double high4,high1,high30,low4,low1,low30,high4s,high1s,high30s,low4s,low1s,low30s;
long vol1u=1,volu,vold,vol1d=1,vol0u,vol0d;
double cci,thresh;
datetime tim=0,timm=0,tim30=0,tim1=0,tim4=0;
int lDigits;
bool ccib,ccis;

double ExtLots=-1;
ushort ExtTakeProfit=0;
ushort ExtStopLoss=0;
ushort ExtTrailingStop=0;
uint   ExtInterval=0;
ushort ExtThreshold=0;
ushort ExtSlippage=3;
double ExtSpreadLimit=0.0;
ushort digits_adjust=-1;

int    handle_iCCI;                          // variable for storing the handle of the iCCI indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Bars(Symbol(),Period())<cciPeriod)
     {
      Print("On graphics there aren't enough bars");
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(Symbol(),Period(),cciPeriod,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iCCI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

   m_symbol.Name(Symbol());                     // sets symbol name
   m_symbol.Refresh();
   if(!RefreshRates())
     {
      Print("Error Refreshes the symbol quotes");
      return(INIT_PARAMETERS_INCORRECT);
     }

   m_trade.SetExpertMagicNumber(MagicNumber);   // sets MagicNumber number

   if(Lots==0.0)
     {
      Print("Incorrect \"Lots\" parameter - parameter can't be equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }

//--- transformation Lots of "-5" to "-0.05"
   double volume=Lots;
   while(volume<=-1)
      volume/=100;

   ExtLots=volume;//UseLots(Lots);
   ExtInterval=InpInterval;
   ExtSpreadLimit=InpSpreadLimit;
   ExtStopLoss=InpStopLoss;
   ExtTrailingStop=InpTrailingStop;
   ExtSlippage=InpSlippage;
   ExtThreshold=MathAbs(InpThreshold);
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
     {
      digits_adjust=10;
     }
   ExtTakeProfit   = InpTakeProfit*digits_adjust;
   ExtStopLoss     = InpStopLoss*digits_adjust;
   ExtTrailingStop = InpTrailingStop*digits_adjust;
   ExtSlippage     = InpSlippage*digits_adjust;
   ExtThreshold    = InpThreshold*digits_adjust;
   ExtInterval     = InpInterval*60;
   ExtSpreadLimit  = InpSpreadLimit*digits_adjust*Point();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double UseLots(const double m_lots)
  {
   double volume=m_lots;

   if(volume<0.0)
     {
      while(volume<=-1)
         volume/=100;
      //--- step 1: calculates the margin required for the minimal volume a deal
      double margin_lots_min=-1;
      bool result=OrderCalcMargin(ORDER_TYPE_BUY,Symbol(),m_symbol.LotsMin(),m_symbol.Ask(),margin_lots_min);
      if(!result || margin_lots_min==0.0)
        {
         Print("OrderCalcMargin(ORDER_TYPE_BUY,",Symbol(),",",
               DoubleToString(m_symbol.LotsMin(),2),",",
               DoubleToString(m_symbol.Ask(),Digits()),",margin_lots_min); margin_lots_min = ",
               DoubleToString(margin_lots_min,2),", error # ",GetLastError());
         return(0);
        }
      //--- step 2: let's check sufficiency of a margin
      if(margin_lots_min>m_account.FreeMargin())
        {
         Print("The margin for BUY ",DoubleToString(m_symbol.LotsMin(),2)," (",
               DoubleToString(margin_lots_min,2),") is more, than a free margin = ",
               DoubleToString(m_account.FreeMargin(),2));
         return(0);
        }
      //--- step 3: let's count quantity of "margin_lots_min" in "FreeMargin"
      int count_lots_min=(int)(m_account.FreeMargin()/margin_lots_min);
      //--- step 4: total lot (taking into account risk) is equal
      volume=volume*count_lots_min*m_symbol.LotsMin();
      //--- step 5: check on lot step
      double lot_check=LotCheck(MathAbs(volume));
      if(lot_check==0.0)
        {
         Print("The calculated lot at risk is equal ",
               DoubleToString(MathAbs(volume),2)," and it less minimum lot ",
               DoubleToString(m_symbol.LotsMin(),2));
         return(0);
        }
      else
         volume=-lot_check;
     }
   else
     {
      double lot_check=LotCheck(volume);
      if(lot_check==0.0)
        {
         Print("The calculated lot at risk is equal ",
               DoubleToString(MathAbs(volume),2)," and it less minimum lot ",
               DoubleToString(m_symbol.LotsMin(),2));
         return(0);
        }
      else
         volume=lot_check;
     }
   return(volume);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int buys=0,sells=0;
   uint life_minutes=0;
   double lots=0.0,h=0.0,l=0.0;
   bool close;
   if(!IsTradeAllowed())
      return;
   if(!RefreshRates())
      return;
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(!m_position.SelectByIndex(i))
         continue;
      if(m_position.Magic()!=MagicNumber)
         continue;
      if(m_position.Symbol()!=Symbol())
         continue;
      life_minutes=(uint)((TimeCurrent()-m_position.Time())/60);
      if(Live>0)
         close=life_minutes>Live;
      else
         close=false;
      if(!close && FridayClose>0)
         close=(str1.day_of_week==5 && str1.hour>FridayClose);
      if(m_position.Type()==POSITION_TYPE_BUY)
        {
         if(!close && Reduce>0)
            close=(m_symbol.Bid()>m_position.TakeProfit()-digits_adjust*(life_minutes/Reduce)*Point());
         if(close)
           {
            close=m_trade.PositionClose(m_position.Ticket());
            if(close)
              {
               life_minutes=0;
               continue;
              }
           }
         buys++;
         if(ExtTakeProfit>0)
            if(m_symbol.Bid()-m_position.PriceOpen()>Point()*ExtTakeProfit)
               if(NormalizeDouble(m_position.StopLoss()-m_symbol.Bid()+Point()*ExtTakeProfit,Digits()-1)<0)
                  m_trade.PositionModify(m_position.Ticket(),
                                         NormalizeDouble(m_symbol.Bid()-Point()*ExtTakeProfit,Digits()),
                                         m_position.TakeProfit());
        }
      else
        {
         if(!close && Reduce>0)
            close=(m_symbol.Ask()<m_position.TakeProfit()+digits_adjust*(life_minutes/Reduce)*Point());
         if(close)
           {
            close=m_trade.PositionClose(m_position.Ticket());
            if(close)
              {
               life_minutes=0;
               continue;
              }
           }
         sells++;
         if(ExtTakeProfit>0)
            if(m_position.PriceOpen()-m_symbol.Ask()>Point()*ExtTakeProfit)
               if(m_position.StopLoss()==0 || 
                  NormalizeDouble(m_position.StopLoss()-m_symbol.Ask()-Point()*ExtTakeProfit,Digits()-1)>0)
                  m_trade.PositionModify(m_position.Ticket(),
                                         NormalizeDouble(m_symbol.Ask()+Point()*ExtTakeProfit,Digits()),
                                         m_position.TakeProfit());
        }
     }
   if(MathAbs(buys-sells)>=MaxPos)
      return;
   if(str1.day_of_week==5)
      return;
   if(ExtInterval>0 && life_minutes>ExtInterval)
      return;
   if(ExtSpreadLimit>0 && (m_symbol.Ask()-m_symbol.Bid())>ExtSpreadLimit)
      return;
   if(tim!=iTime(Symbol(),Period(),0))
     {
      cci=iCCIGet(1);
      if(cciLimit>0)
        {
         ccib=(cci>0 && cci< cciLimit);
         ccis=(cci<0 && cci>-cciLimit);
        }
      else
        {
         ccib=(cci>-cciLimit);
         ccib=(cci< cciLimit);
        }
      tim=iTime(Symbol(),Period(),0);
     }
   if(!ccib && !ccis)
      return;
   high4=iHigh(Symbol(),PERIOD_H4,0);
   low4=iLow(Symbol(),PERIOD_H4,0);
   if(tim4!=iTime(Symbol(),PERIOD_H4,0))
     {
      high4s=iHigh(Symbol(),PERIOD_H4,1);
      low4s=iLow(Symbol(),PERIOD_H4,1);
      tim4=iTime(Symbol(),PERIOD_H4,0);
     }
   if(tim1!=iTime(Symbol(),PERIOD_H1,0))
     {
      high1s=iHigh(Symbol(),PERIOD_H1,1);
      low1s=iLow(Symbol(),PERIOD_H1,1);
      tim1=iTime(Symbol(),PERIOD_H1,0);
     }
   high1=iHigh(Symbol(),PERIOD_H1,0);
   low1=iLow(Symbol(),PERIOD_H1,0);
   if(tim30!=iTime(Symbol(),PERIOD_M30,0))
     {
      high30s=iHigh(Symbol(),PERIOD_M30,1);
      low30s=iLow(Symbol(),PERIOD_M30,1);
      tim30=iTime(Symbol(),PERIOD_M30,0);
     }
   high30=iHigh(Symbol(),PERIOD_M30,0);
   low30=iLow(Symbol(),PERIOD_M30,0);
   if(Volatility>0)
     {
      if(timm!=iTime(Symbol(),PERIOD_M1,0))
        {
         vol1u=0;
         vol1d=0;
         for(int i=Volatility; i<Volatility<<1; i++)
           {
            h=iClose(Symbol(),PERIOD_M1,i);
            l=iOpen(Symbol(),PERIOD_M1,i);
            if(h>l+thresh)
               vol1u+=iTickVolume(Symbol(),PERIOD_M1,i);
            else
            if(l>h+thresh)
               vol1d+=iTickVolume(Symbol(),PERIOD_M1,i);
           }
         volu=0;
         vold=0;
         for(int i=1; i<Volatility; i++)
           {
            h=iClose(Symbol(),PERIOD_M1,i);
            l=iOpen(Symbol(),PERIOD_M1,i);
            if(h>l+thresh)
               volu+=iTickVolume(Symbol(),PERIOD_M1,i);
            else
            if(l>h+thresh)
               vold+=iTickVolume(Symbol(),PERIOD_M1,i);
           }
         timm=iTime(Symbol(),PERIOD_M1,0);
        }
      h=iClose(Symbol(),PERIOD_M1,0);
      l=iOpen(Symbol(),PERIOD_M1,0);
      if(h>l+thresh)
        {
         vol0u=volu+iTickVolume(Symbol(),PERIOD_M1,0);
         vol0d=vold;
        }
      else
      if(l>h+thresh)
        {
         vol0d=vold+iTickVolume(Symbol(),PERIOD_M1,0);
         vol0u=volu;
           } else {
         vol0u=volu;
         vol0d=vold;
        }
     }
   else if(Volatility<0)
     {
      if(timm!=iTime(Symbol(),PERIOD_M1,0))
        {
         vol1u=0;
         for(int i=-Volatility; i<(-Volatility)<<1; i++)
           {
            h=iClose(Symbol(),PERIOD_M1,i);
            l=iOpen(Symbol(),PERIOD_M1,i);
            if(MathAbs(h-l)>thresh)
               vol1u+=iTickVolume(Symbol(),PERIOD_M1,i);
           }
         volu=0;
         for(int i=1; i<-Volatility; i++)
           {
            h=iClose(Symbol(),PERIOD_M1,i);
            l=iOpen(Symbol(),PERIOD_M1,i);
            if(MathAbs(h-l)>=thresh)
               volu+=iTickVolume(Symbol(),PERIOD_M1,i);
           }
         vol1d=vol1u;
         vold=volu;
         timm=iTime(Symbol(),PERIOD_M1,0);
        }
      h=iClose(Symbol(),PERIOD_M1,0);
      l=iOpen(Symbol(),PERIOD_M1,0);
      if(MathAbs(h-l)>=thresh)
         vol0u=volu+iTickVolume(Symbol(),PERIOD_M1,0);
      vol0d=vol0u;
     }
   else
     {
      h=iClose(Symbol(),PERIOD_M1,0);
      l=iOpen(Symbol(),PERIOD_M1,0);
      if(MathAbs(h-l)>=thresh)
         vol0u=iTickVolume(Symbol(),PERIOD_M1,0);
      else
         vol0u=0;
      vol0d=vol0u;
     }
   if(ccib)
     {
      if(low4>low4s && low1>low1s && low30>low30s && 
         m_symbol.Ask()>iHigh(Symbol(),Period(),1) && vol0u>vol1u && vol1u>0 && 
         iHigh(Symbol(),Period(),2)>iHigh(Symbol(),Period(),1) && 
         iHigh(Symbol(),Period(),3)>iHigh(Symbol(),Period(),2))
        {
         lots=UseLots(ExtLots);
         if(lots==0)
            return;
         if(lots<0)
            lots=MathAbs(lots);
         m_trade.Buy(lots,Symbol(),m_symbol.Ask(),
                     m_symbol.Ask()-ExtStopLoss*Point(),m_symbol.Ask()+ExtTakeProfit*Point(),EA);
        }
     }
   else if(high4<high4s && high1<high1s && high30<high30s && 
      m_symbol.Ask()<iLow(Symbol(),Period(),1) && vol0d>vol1d && vol1d>0 && 
      iLow(Symbol(),Period(),2)<iLow(Symbol(),Period(),1) && 
      iLow(Symbol(),Period(),3)<iLow(Symbol(),Period(),2) && 
      ((cciLimit>0 && cci<0 && cci>-cciLimit) || (cciLimit<0 && cci<cciLimit)))
        {
         lots=UseLots(ExtLots);
         if(lots==0)
            return;
         if(lots<0)
            lots=MathAbs(lots);
         m_trade.Sell(lots,Symbol(),m_symbol.Bid(),
                      m_symbol.Bid()+ExtStopLoss*Point(),m_symbol.Bid()-ExtTakeProfit*Point(),EA);
        }
      return;
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
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(const int index)
  {
   double CCI[];
   ArraySetAsSeries(CCI,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCCI,0,0,index+1,CCI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(CCI[index]);
  }
//+------------------------------------------------------------------+
