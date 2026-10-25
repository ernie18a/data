//+------------------------------------------------------------------+
//|                       EA Stop Order(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Хлыстов Владимир"
#property link      "cmillion@narod.ru"
#property version   "1.003"
#property description " Advisor opens a grid of stop orders"
#property description "    When the specified profit level is reached,"
#property description "       it closes all positions and deletes all pending orders"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
//--- input parameters
input double   InpProfitClose    = 5;        // Profit purpose (in money)
input bool     InpBuyStop        = true;     // Use Buy stop
input bool     InpSellStop       = true;     // Use Sell stop
input int      InpMaxOrders      = 15;       // Maximum pending orders
input ushort   InpStopLoss       = 0;        // StopLoss ("0" -> off)
input ushort   InpTakeProfit     = 0;        // TakeProfit ("0" -> off)
input ushort   InpDistance       = 100;      // Distance from current price
input double   InpLots           = 0.1;      // Lots
input double   InpLotRatio       = 1.5;      // Lot Ratio
input ulong    m_magic=72994760;             // magic number
//---
ulong          m_slippage=10;                // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
//---
bool           m_bln_close_all=false;        // "true" -> you must close all positions
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpLotRatio<=0.0)
     {
      string text=__FUNCTION__+", ERROR: "+"The parameter \"Lot Ratio\" can not be less than or equal to zero";
      Print(text);
      Alert(text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(__FUNCTION__,", ERROR: ",err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- 
   ExtStopLoss=InpStopLoss*m_symbol.Point();
   ExtTakeProfit=InpTakeProfit*m_symbol.Point();
//---
   m_bln_close_all=false;                    // "true" -> you must close all positions
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
   if(m_bln_close_all)
     {
      CloseAllPositions();
      DeleteAllOrders();
      if(CalculateAllPositions()==0.0 && CalculateAllPendingOrders()==0.0)
         m_bln_close_all=false;
     }
//---
   double Profit=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            Profit+=m_position.Commission()+m_position.Swap()+m_position.Profit();
//---
   if(Profit>=InpProfitClose) // close all
     {
      m_bln_close_all=true;
      return;
     }
//---
   if(CalculateAllPendingOrders()!=0)
      return;
//---
   if(!RefreshRates())
      return;
   int StopsLevel=m_symbol.StopsLevel();
   if(StopsLevel==0)
      StopsLevel=m_symbol.Spread()*3;

   for(int i=1; i<=InpMaxOrders; i++)
     {
      if(InpDistance*i>StopsLevel)
        {
         double Lot=(i==1)?InpLots:LotCheck(InpLots*(double)(i-1)*InpLotRatio);
         if(Lot!=0.0)
           {
            if(InpBuyStop)
              {
               double Price=m_symbol.NormalizePrice(m_symbol.Ask()+(double)InpDistance*(double)i*m_symbol.Point());
               double sl=(InpStopLoss==0)?0.0:m_symbol.NormalizePrice(Price-ExtStopLoss);
               double tp=(InpTakeProfit==0)?0.0:m_symbol.NormalizePrice(Price+ExtTakeProfit);
               m_trade.BuyStop(Lot,Price,m_symbol.Name(),sl,tp);
              }
            if(InpSellStop)
              {
               double Price=m_symbol.NormalizePrice(m_symbol.Bid()-(double)InpDistance*(double)i*m_symbol.Point());
               double sl=(InpStopLoss==0)?0.0:m_symbol.NormalizePrice(Price+ExtStopLoss);
               double tp=(InpTakeProfit==0)?0.0:m_symbol.NormalizePrice(Price-ExtTakeProfit);
               m_trade.SellStop(Lot,Price,m_symbol.Name(),sl,tp);
              }
           }
        }
     }
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Calculate all pending orders for symbol                          |
//+------------------------------------------------------------------+
int CalculateAllPendingOrders()
  {
   int total=0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Delete all pending orders                                                    |
//+------------------------------------------------------------------+
void DeleteAllOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
