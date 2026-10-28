//+------------------------------------------------------------------+
//|                                Multi_Lot_Scalper(10points 3).mq5 |
//|                              Copyright © 2005, Alejandro Galindo |
//|                                              http://elCactus.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Alejandro Galindo"
#property link      "http://elCactus.com"
#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CAccountInfo      m_account;           // account info wrapper
CPositionInfo     m_position;          // trade position object
CTrade            m_trade;             // trading object
CSymbolInfo       m_symbol;            // symbol info object
//----
input double TakeProfit=40;
input double Lots=0.1;
input double InitialStop=0;
input double TrailingStop=20;
input int MaxTrades=10;
input int Pips=25;
input int SecureProfit=10;
input int AccountProtection=1;
input int OrderstoProtect=3;
input int ReverseCondition=0;
input int StartYear=2016;
input int StartMonth=1;
input int EndYear=2016;
input int EndMonth= 12;
input int EndHour = 22;
input int EndMinute=30;
input int mm=0;
input int risk=6;
input int AccountisNormal=0;
//----
int      OpenOrders=0,cnt=0;
ulong    slippage=5;
double   stop_loss=0.0,take_profit=0.0;
double   BuyPrice=0.0,SellPrice=0.0;
double   lotsi=0.0,mylotsi=0.0;
ENUM_POSITION_TYPE position_type=0;
int      myOrderType=0;
bool     ContinueOpening=true;
double   LastPrice=0.0;
int      PreviousOpenOrders=0;
double   Profit=0.0;
ulong    LastTicket=0;
ENUM_POSITION_TYPE LastType=0;
double   LastClosePrice=0.0,LastLots=0.0;
double   Pivot=0.0;
string   text="",text2="";
int      handle;                          // variable for storing the handle of the iMACD indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(m_account.MarginMode()!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("Supported only hedging");
      return(INIT_FAILED);
     }
//--- the buffer numbers are the following: 0 - MAIN_LINE, 1 - SIGNAL_LINE.
   handle=iMACD(NULL,0,14,26,9,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_CURRENT),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   m_symbol.Name(Symbol());         // sets symbol name
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   return;
  }
//+------------------------------------------------------------------+
//| Expert new tick handling function                                |
//+------------------------------------------------------------------+
void OnTick(void)
  {
//---- 
   if(AccountisNormal==1)
      if(mm!=0)
         lotsi=MathCeil(m_account.Balance()*risk/10000);
   else
      lotsi=Lots;
   else
// then is mini
   if(mm!=0)
          lotsi=MathCeil(m_account.Balance()*risk/10000)/10;
   else
      lotsi=Lots;
//----
   if(lotsi>100)
      lotsi=100;
   OpenOrders=0;
//----
   for(cnt=0; cnt<PositionsTotal(); cnt++)
     {
      m_position.SelectByIndex(cnt);
      //----
      if(m_position.Symbol()==Symbol())
         OpenOrders++;
     }
//----
   if(OpenOrders<1)
     {
      //---
      MqlDateTime str1;
      TimeToStruct(TimeCurrent(),str1);

      if(str1.year<StartYear)
         return;
      //----
      if(str1.mon<StartMonth)
         return;
      //----
      if(str1.year>EndYear)
         return;
      //----
      if(str1.mon>EndMonth)
         return;
     }
//----
   if(PreviousOpenOrders>OpenOrders)
      for(cnt=PositionsTotal(); cnt>=0; cnt--)
        {
         m_position.SelectByIndex(cnt);
         position_type=m_position.PositionType();
         //----
         if(m_position.Symbol()==Symbol())
           {
            m_trade.PositionClose(m_position.Ticket(),slippage);
            return;
           }
        }
   PreviousOpenOrders=OpenOrders;
//----
   if(OpenOrders>=MaxTrades)
      ContinueOpening=false;
   else
      ContinueOpening=true;
//----
   if(LastPrice==0)
      for(cnt=0; cnt<PositionsTotal(); cnt++)
        {
         m_position.SelectByIndex(cnt);
         position_type=m_position.PositionType();
         //----
         if(m_position.Symbol()==Symbol())
           {
            LastPrice=m_position.PriceOpen();
            //----
            if(position_type==POSITION_TYPE_BUY)
               myOrderType=2;
            //----
            if(position_type==POSITION_TYPE_SELL)
               myOrderType=1;
           }
        }
//----
   if(OpenOrders<1)
     {
      myOrderType=3;
      //----
      if(iMACDGet(0,0)>iMACDGet(0,1))
         myOrderType=2;
      //----
      if(iMACDGet(0,0)<iMACDGet(0,1))
         myOrderType=1;
      //----
      if(ReverseCondition==1)
         if(myOrderType==1)
            myOrderType=2;
      else
      if(myOrderType==2)
         myOrderType=1;
     }
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return;
// if we have opened positions we take care of them
   for(cnt=PositionsTotal(); cnt>=0; cnt--)
     {
      m_position.SelectByIndex(cnt);
      //----
      if(m_position.Symbol()==Symbol())
        {
         if(m_position.PositionType()==POSITION_TYPE_SELL)
            if(TrailingStop>0)
               if(m_position.PriceOpen()-m_symbol.Ask()>=(TrailingStop+Pips)*Point())
                  if(m_position.StopLoss()>(m_symbol.Ask()+Point()*TrailingStop))
                    {
                     m_trade.PositionModify(m_position.Ticket(),
                                            m_symbol.Ask()+Point()*TrailingStop,
                                            m_position.PriceCurrent()-TakeProfit*Point()-TrailingStop*Point());
                     return;
                    }
         if(m_position.PositionType()==POSITION_TYPE_BUY)
            if(TrailingStop>0)
               if(m_symbol.Bid()-m_position.PriceOpen()>=(TrailingStop+Pips)*Point())
                  if(m_position.StopLoss()<(m_symbol.Bid()-Point()*TrailingStop))
                    {
                     m_trade.PositionModify(m_position.Ticket(),
                                            m_symbol.Bid()-Point()*TrailingStop,
                                            m_position.PriceCurrent()+TakeProfit*Point()+TrailingStop*Point());
                     return;
                    }
        }
     }
   Profit=0;
   LastTicket=0;
   LastType=0;
   LastClosePrice=0;
   LastLots=0;
//----
   for(cnt=0; cnt<PositionsTotal(); cnt++)
     {
      m_position.SelectByIndex(cnt);
      //----
      if(m_position.Symbol()==Symbol())
        {
         LastTicket=m_position.Ticket();
         //----
         if(m_position.PositionType()==POSITION_TYPE_BUY)
            LastType=POSITION_TYPE_BUY;
         //----
         if(m_position.PositionType()==POSITION_TYPE_SELL)
            LastType=POSITION_TYPE_SELL;
         LastClosePrice=m_position.PriceCurrent();
         LastLots=m_position.Volume();
         //----
         if(LastType==POSITION_TYPE_BUY)
           {
            if(m_position.PriceCurrent()<m_position.PriceOpen())
               Profit+=m_position.Profit();
            //----
            if(m_position.PriceCurrent()>m_position.PriceOpen())
               Profit+=m_position.Profit();
           }
         //----
         if(LastType==POSITION_TYPE_SELL)
           {
            if(m_position.PriceCurrent()>m_position.PriceOpen())
               Profit+=m_position.Profit();
            //----
            if(m_position.PriceCurrent()<m_position.PriceOpen())
               Profit+=m_position.Profit();
           }
        }
     }
   text2="Profit: $"+DoubleToString(Profit,2)+" +/-";
//----
   if(OpenOrders>=(MaxTrades-OrderstoProtect) && AccountProtection==1)
      if(Profit>=SecureProfit)
        {
         m_trade.PositionClose(LastTicket,slippage);
         ContinueOpening=false;
         return;
        }
//----
   if(myOrderType==3)
      text="No conditions to open trades";
   else
      text="                         ";
   Comment("LastPrice=",LastPrice," Previous open orders=",PreviousOpenOrders,
           "\nContinue opening=",ContinueOpening," PositionType=",myOrderType,"\n",
           text2,"\nLots=",lotsi,"\n",text);
//----
   if(myOrderType==1 && ContinueOpening)
     {
      if((m_symbol.Bid()-LastPrice)>=Pips*Point() || OpenOrders<1)
        {
         SellPrice = m_symbol.Bid();
         LastPrice = 0;
         //----
         if(TakeProfit==0)
            take_profit=0;
         else
            take_profit=SellPrice-TakeProfit*Point();
         //----
         if(InitialStop==0)
            stop_loss=0;
         else
            stop_loss=SellPrice+InitialStop*Point();
         //----
         if(OpenOrders!=0)
           {
            mylotsi=lotsi;
            //----
            for(cnt=1; cnt<=OpenOrders; cnt++)
               if(MaxTrades>12)
                  mylotsi=NormalizeDouble(mylotsi*1.5,1);
            else
               mylotsi=NormalizeDouble(mylotsi*2,1);
           }
         else
            mylotsi=lotsi;
         //----
         if(mylotsi>100)
            mylotsi=100;
         if(CheckMoneyForTrade(Symbol(),mylotsi,ORDER_TYPE_SELL))
            m_trade.Sell(mylotsi,Symbol(),SellPrice,stop_loss,take_profit,NULL);
         return;
        }
     }
   if(myOrderType==2 && ContinueOpening)
     {
      if((LastPrice-m_symbol.Ask())>=Pips*Point() || OpenOrders<1)
        {
         BuyPrice=m_symbol.Ask();
         LastPrice=0;
         //----
         if(TakeProfit==0)
            take_profit=0;
         else
            take_profit=BuyPrice+TakeProfit*Point();
         //----
         if(InitialStop==0)
            stop_loss=0;
         else
            stop_loss=BuyPrice-InitialStop*Point();
         //----
         if(OpenOrders!=0)
           {
            mylotsi = lotsi;
            for(cnt = 1; cnt <= OpenOrders; cnt++)
               if(MaxTrades>12)
                  mylotsi=NormalizeDouble(mylotsi*1.5,1);
            else
               mylotsi=NormalizeDouble(mylotsi*2,1);
           }
         else
            mylotsi=lotsi;
         //----
         if(mylotsi>100)
            mylotsi=100;
         if(CheckMoneyForTrade(Symbol(),mylotsi,ORDER_TYPE_BUY))
            m_trade.Buy(mylotsi,Symbol(),BuyPrice,stop_loss,take_profit,NULL);
         return;
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[];
   double macd=0.0;
   ArraySetAsSeries(MACD,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,0,index+1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[index]);
  }
//+------------------------------------------------------------------+
//| Check Money For Trade                                            |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- call of the checking function
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- something went wrong, report and return false
      Print("Error in ",__FUNCTION__," code=",GetLastError());
      return(false);
     }
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      Print("Not enough money for ",EnumToString(type)," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
