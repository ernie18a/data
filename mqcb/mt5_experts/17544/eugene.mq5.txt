//+------------------------------------------------------------------+
//|                              Eugene(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
input double   Size=0.1;
//---
ulong          m_magic=15489;                // magic number
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
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
   int Prev_Order=-1;
   int Counter_buy=0;
   int Counter_sell=0;

   datetime Check_period=0;
   datetime Checked_period=0;
   int current_year=0;
//---
   int Insider,Insider2;
   int Black_insider,White_insider,White_bird,Black_bird;
   bool Buy_signal=false;
   int Confirm_buy;
   int Confirm_sell;
   bool Sell_signal=false;
   int Downer=0;
   int Upper=0;
   double Zig_level_buy;
   double Zig_level_sell;
   string i_n;

   string loss_filename,win_filename,month,day,ticket_id;

   double max_price;
   double min_price;

   CalculatePositions(Counter_buy,Counter_sell);

   Checked_period=iTime(m_symbol.Name(),Period(),0);

   if(Checked_period==Check_period)
     {
      if(Counter_sell+Counter_buy>=2)
        {
         return;
        }
     }
   else
     {
      Check_period=Checked_period;
     }

   double open_1=iOpen(m_symbol.Name(),Period(),1);
   double open_2=iOpen(m_symbol.Name(),Period(),2);
   double high_0=iHigh(m_symbol.Name(),Period(),0);
   double high_1=iHigh(m_symbol.Name(),Period(),1);
   double high_2=iHigh(m_symbol.Name(),Period(),2);
   double high_3=iHigh(m_symbol.Name(),Period(),3);
   double low_0=iLow(m_symbol.Name(),Period(),0);
   double low_1=iLow(m_symbol.Name(),Period(),1);
   double low_2=iLow(m_symbol.Name(),Period(),2);
   double low_3=iLow(m_symbol.Name(),Period(),3);
   double close_1=iClose(m_symbol.Name(),Period(),1);
   double close_2=iClose(m_symbol.Name(),Period(),2);

   if(high_1<=high_2 && low_1>=low_2)
      Insider=1;
   else
      Insider=0;

   if(high_2<=high_3 && low_2>=low_3)
      Insider2=1;
   else
      Insider2=0;

   if(high_1<=high_2 && low_1>=low_2 && open_1<=open_1)
      Black_insider=1;
   else
      Black_insider=0;

   if(high_1<=high_2 && low_1>=low_2 && open_1>open_1)
      White_insider=1;
   else
      White_insider=0;

   if(White_insider==1 && open_2>open_2)
      White_bird=1;
   else
      White_bird=0;

   if(Black_insider==1 && open_2<open_2)
      Black_bird=1;
   else
      Black_bird=0;

   if(open_1<open_1)
      Zig_level_buy=(open_1-(open_1-open_1)/3);//White
   else
      Zig_level_buy=(open_1-(open_1-low_1)/3);//Black

   if(open_1>open_1)
      Zig_level_sell=(open_1+(open_1-open_1)/3);//Black
   else
      Zig_level_sell=(open_1+(high_1-open_1)/3);//White

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(((low_0<=Zig_level_buy) || (str1.hour>=8)) && (Black_bird==0) && (White_insider==0))
      Confirm_buy=1;
   else
      Confirm_buy=0;

   if(((high_0>=Zig_level_sell) || (str1.hour>=8)) && (White_bird==0) && (Black_insider==0))
      Confirm_sell=1;
   else
      Confirm_sell=0;

//---
   if(high_0>high_1)
      Buy_signal=true;
   else
      Buy_signal=false;

   if(Buy_signal)
     {
      int i=0;
      max_price=iHigh(m_symbol.Name(),Period(),i);
      while(max_price<iHigh(m_symbol.Name(),Period(),i+1))
        {
         max_price=iHigh(m_symbol.Name(),Period(),i+1);
         i++;
        }
     }
//---
   if(low_0<low_1)
      Sell_signal=true;
   else
      Sell_signal=false;

   if(Sell_signal)
     {
      int i=0;
      min_price=iLow(m_symbol.Name(),Period(),i);
      while(min_price>iLow(m_symbol.Name(),Period(),i+1))
        {
         min_price=iLow(m_symbol.Name(),Period(),i+1);
         i++;
        }
     }
//---
   if(Counter_buy/*+Counter_sell*/==0)
     {
      //--- BUY
      if(Buy_signal)
        {
         if(Confirm_buy==1)
            if(low_0>low_1 && low_1<high_2)
               if(Counter_buy+Counter_sell==0)
                 {
                  if(!RefreshRates())
                     return;

                  if(m_trade.Buy(Size,NULL,m_symbol.Ask()))
                    {
                     if(m_trade.ResultDeal()==0)
                        Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                  else
                     Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  return;
                 }
        }
      //--- SELL
      if(Sell_signal)
        {
         if(Confirm_sell==1)
            if(high_0<high_1)
               if(/*Counter_buy+*/Counter_sell==0)
                 {
                  if(!RefreshRates())
                     return;

                  if(m_trade.Sell(Size,NULL,m_symbol.Bid()))
                    {
                     if(m_trade.ResultDeal()==0)
                        Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                  else
                     Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  return;
                 }
        }
     }

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(Sell_signal)
                  if(Confirm_sell==1)
                     if(high_0<high_1)
                        m_trade.PositionClose(m_position.Ticket());
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(Buy_signal)
                  if(Confirm_buy==1)
                     if(low_0>low_1 && low_1<high_2)
                        m_trade.PositionClose(m_position.Ticket());
              }
           }

//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
//| Подсчёт позиций Buy и Sell                                       |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0.0;
   count_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
