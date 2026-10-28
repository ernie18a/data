//+------------------------------------------------------------------+
//|                                       Crossing of two iMA v2.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "2.000"
#property description "Crossing of two iMA, pending order or market"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedRisk *m_money;
//--- input parameters
sinput string              _0_                     = "Parameters of the first Moving Average";
input int                  InpMAPeriodFirst        = 5;           // Period of the first Moving Average
input int                  InpMAShiftFirst         = 3;           // Shift of the first Moving Average
input ENUM_MA_METHOD       InpMAMethodFirst        = MODE_SMMA;   // Method of the first Moving Average
input ENUM_APPLIED_PRICE   InpMAAppliedPriceFirst  = PRICE_CLOSE; // Type of price 
input color                InpMAFirstColor         = clrRed;      // Color of the first Moving Average
sinput string              _1_                     = "Parameters of the second Moving Average";
input int                  InpMAPeriodSecond       = 8;           // Period of the second Moving Average
input int                  InpMAShiftSecond        = 5;           // Shift of the second Moving Average
input ENUM_MA_METHOD       InpMAMethodSecond       = MODE_SMMA;   // Method of the second Moving Average
input ENUM_APPLIED_PRICE   InpMAAppliedPriceSecond = PRICE_CLOSE; // Type of price 
input color                InpMASecondColor        = clrBlue;     // Color of the second Moving Average
sinput string              _2_                     = "Parameters of the Third Moving Average";
input bool                 InpFilterMA             = true;        // Third indicator Moving Average - filter
input int                  InpMAPeriodThird        = 13;          // Period of the third Moving Average
input int                  InpMAShiftThird         = 8;           // Shift of the third Moving Average
input ENUM_MA_METHOD       InpMAMethodThird        = MODE_SMMA;   // Method of the third Moving Average
input ENUM_APPLIED_PRICE   InpMAAppliedPriceThird  = PRICE_CLOSE; // Type of price 
input color                InpMAThirdColor         = clrOrange;   // Color of the third Moving Average
sinput string        _3_               = "Parameters of Money Management";
input bool           InpMoneyManagement= true;        // true -> lot is manual, false -> percentage of risk from balance
input double         InpLots           = 0.1;         // Lots (use only if lot size is manual)
sinput string        _4_               = "Parameters of trading";
input double         InpRisk           = 5;           // Risk in percent for a deal from balance
input int            InpPriceLevel     = 0;           // (in pips) <0 -> Stop orders, =0 -> Market, >0 -> Limit orders
input ushort         InpStopLoss       = 50;          // Stop Loss (in pips)
input ushort         InpTakeProfit     = 50;          // Take Profit (in pips)
input ushort         InpTrailingStop   = 10;          // Trailing Stop ("0" -> not trailing)
input ushort         InpTrailingStep   = 4;           // Trailing Step (use if Trailing Stop >0)
input ulong          m_magic           = 69302344;    // Magic number
input ulong          m_slippage        = 30;          // Slippage
//---
int                  handle_iMA_First;                // variable for storing the handle of the iMA indicator 
int                  handle_iMA_Second;               // variable for storing the handle of the iMA indicator 
int                  handle_iMA_Third;                // variable for storing the handle of the iMA indicator 
double               ExtStopLoss=0.0;
double               ExtTakeProfit=0.0;
double               ExtTrailingStop=0.0;
double               ExtTrailingStep=0.0;
double               m_adjusted_point;                // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   for(int i=ChartIndicatorsTotal(0,0)-1;i>=0;i--)
      ChartIndicatorDelete(0,0,ChartIndicatorName(0,0,i));
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
//---
   delete(m_money);
   m_money=new CMoneyFixedRisk;
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(InpRisk);
//--- create handle of the indicator iMA
   handle_iMA_First=iCustom(m_symbol.Name(),Period(),"Custom Moving Average Input Color",
                            InpMAPeriodFirst,InpMAShiftFirst,InpMAMethodFirst,InpMAFirstColor,InpMAAppliedPriceFirst);
//handle_iMA_First=iMA(Symbol(),Period(),InpMAPeriodFirst,InpMAShiftFirst,InpMAMethodFirst,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_First==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("MAFirst: Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Second=iCustom(m_symbol.Name(),Period(),"Custom Moving Average Input Color",
                             InpMAPeriodSecond,InpMAShiftSecond,InpMAMethodSecond,InpMASecondColor,InpMAAppliedPriceSecond);
//iMA(Symbol(),Period(),InpMAPeriodSecond,InpMAShiftSecond,InpMAMethodSecond,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Second==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("MASecond: Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Third=iCustom(m_symbol.Name(),Period(),"Custom Moving Average Input Color",
                            InpMAPeriodThird,InpMAShiftThird,InpMAMethodThird,InpMAThirdColor,InpMAAppliedPriceThird);
//iMA(Symbol(),Period(),InpMAPeriodThird,InpMAShiftThird,InpMAMethodThird,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Third==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("MAThird: Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   ChartIndicatorAdd(0,0,handle_iMA_First);
   ChartIndicatorAdd(0,0,handle_iMA_Second);
   ChartIndicatorAdd(0,0,handle_iMA_Third);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete(m_money);
   for(int i=ChartIndicatorsTotal(0,0)-1;i>=0;i--)
      ChartIndicatorDelete(0,0,ChartIndicatorName(0,0,i));
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- trailing works on every tick
   if(InpTrailingStop!=0)
      Trailing();
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   RefreshRates();

//--- We look for crossing of two indicators
   double   First[];
   double   Second[];
   double   Third[];
   ArraySetAsSeries(First,true);    // index [0] - the most right bar on a charts
   ArraySetAsSeries(Second,true);   // index [0] - the most right bar on a charts
   ArraySetAsSeries(Third,true);    // index [0] - the most right bar on a charts
   int      buffer_num=0;           // indicator buffer number 
   int      start_pos=0;            // start position 
   int      count=3;                // amount to copy 
   if(!iMAGet(handle_iMA_First,buffer_num,start_pos,count,First))
      return;
   if(!iMAGet(handle_iMA_Second,buffer_num,start_pos,count,Second))
      return;
   if(InpFilterMA)
      if(!iMAGet(handle_iMA_Third,buffer_num,start_pos,count,Third))
         return;
//--- step 1: check in the arrays bars [0] and [1]
   if(First[0]>Second[0] && First[1]<Second[1]) // buy
     {
      if(InpFilterMA)
         if(Third[0]>=First[0])
            return;
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      OpenBuy(sl,tp);
      return;
     }
   else if(First[0]<Second[0] && First[1]>Second[1]) // sell
     {
      if(InpFilterMA)
         if(Third[0]<=First[0])
            return;
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      OpenSell(sl,tp);
      return;
     }
//--- step 2: on a step of 1 crossing haven't found. check in the arrays bars [0] and [2]
   if(First[0]>Second[0] && First[2]<Second[2]) // buy
     {
      //--- search in history
      if(SearchPositions(iTime(start_pos+3),iTime(start_pos)))
         return;
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      OpenBuy(sl,tp);
      return;
     }
   else if(First[0]<Second[2] && First[1]>Second[2]) // sell
     {
      //--- search in history
      if(SearchPositions(iTime(start_pos+3),iTime(start_pos)))
         return;
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      OpenSell(sl,tp);
      return;
     }
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
bool iMAGet(int    handle_iMA,   // indicator handle 
            int    buffer_num,   // indicator buffer number 
            int    start_pos,    // start position 
            int    count,        // amount to copy 
            double &buffer[]     // target array to copy 
            )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,buffer_num,start_pos,count,buffer)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Search in history                                                |
//+------------------------------------------------------------------+
bool SearchPositions(const datetime start_time,const datetime stop_time)
  {
//--- request trade history 
   HistorySelect(start_time,stop_time);
//--- for all deals 
   for(int i=HistoryDealsTotal()-1;i>=0;i--)
      if(m_deal.SelectByIndex(i)) // selects the deals by index for further access to its properties
         if(m_deal.Symbol()==m_symbol.Name() && m_deal.Magic()==m_magic)
           {
            if(m_deal.Entry()==DEAL_ENTRY_IN)
               if(m_deal.Time()>=start_time && m_deal.Time()<stop_time)
                  return(true);
           }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double price=m_symbol.Ask();

   double check_open_long_lot=0.0;
   if(InpMoneyManagement) // true -> lot is manual, false -> percentage of risk from balance
      check_open_long_lot=InpLots;
   else
      check_open_long_lot=m_money.CheckOpenLong(price,sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,price,ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_long_lot)
        {
         if(InpPriceLevel==0) // (in pips) <0 -> Stop orders, =0 -> Market, >0 -> Limit orders
           {
            if(m_trade.Buy(check_open_long_lot,NULL,price,sl,tp))
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
         else if(InpPriceLevel<0) // (in pips) <0 -> Stop orders, =0 -> Market, >0 -> Limit orders
           {
            sl=m_symbol.NormalizePrice(sl+MathAbs(InpPriceLevel*m_adjusted_point));
            tp=m_symbol.NormalizePrice(tp+MathAbs(InpPriceLevel*m_adjusted_point));
            price=m_symbol.NormalizePrice(price+MathAbs(InpPriceLevel*m_adjusted_point));

            DeleteAllOrders();

            if(m_trade.BuyStop(check_open_long_lot,price,m_symbol.Name(),sl,tp))
               Print("BuyStop - > true. ticket of order = ",m_trade.ResultOrder());
            else
               Print("BuyStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of order: ",m_trade.ResultOrder());
           }
         else if(InpPriceLevel>0) // (in pips) <0 -> Stop orders, =0 -> Market, >0 -> Limit orders
           {
            sl=m_symbol.NormalizePrice(sl-MathAbs(InpPriceLevel*m_adjusted_point));
            tp=m_symbol.NormalizePrice(tp-MathAbs(InpPriceLevel*m_adjusted_point));
            price=m_symbol.NormalizePrice(price-MathAbs(InpPriceLevel*m_adjusted_point));

            DeleteAllOrders();

            if(m_trade.BuyLimit(check_open_long_lot,price,m_symbol.Name(),sl,tp))
               Print("BuyLimit - > true. ticket of order = ",m_trade.ResultOrder());
            else
               Print("BuyLimit -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of order: ",m_trade.ResultOrder());
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

   double price=m_symbol.Bid();

   double check_open_short_lot=0.0;
   if(InpMoneyManagement) // true -> lot is manual, false -> percentage of risk from balance
      check_open_short_lot=InpLots;
   else
      check_open_short_lot=m_money.CheckOpenShort(price,sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,price,ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_short_lot)
        {
         if(InpPriceLevel==0) // (in pips) <0 -> Stop orders, =0 -> Market, >0 -> Limit orders
           {
            if(m_trade.Sell(check_open_short_lot,NULL,price,sl,tp))
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
         else if(InpPriceLevel<0) // (in pips) <0 -> Stop orders, =0 -> Market, >0 -> Limit orders
           {
            sl=m_symbol.NormalizePrice(sl-MathAbs(InpPriceLevel*m_adjusted_point));
            tp=m_symbol.NormalizePrice(tp-MathAbs(InpPriceLevel*m_adjusted_point));
            price=m_symbol.NormalizePrice(price-MathAbs(InpPriceLevel*m_adjusted_point));

            DeleteAllOrders();

            if(m_trade.SellStop(check_open_short_lot,price,m_symbol.Name(),sl,tp))
               Print("SellStop - > true. ticket of order = ",m_trade.ResultOrder());
            else
               Print("SellStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of order: ",m_trade.ResultOrder());
           }
         else if(InpPriceLevel>0) // (in pips) <0 -> Stop orders, =0 -> Market, >0 -> Limit orders
           {
            sl=m_symbol.NormalizePrice(sl+MathAbs(InpPriceLevel*m_adjusted_point));
            tp=m_symbol.NormalizePrice(tp+MathAbs(InpPriceLevel*m_adjusted_point));
            price=m_symbol.NormalizePrice(price+MathAbs(InpPriceLevel*m_adjusted_point));

            DeleteAllOrders();

            if(m_trade.SellLimit(check_open_short_lot,price,m_symbol.Name(),sl,tp))
               Print("SellLimit - > true. ticket of order = ",m_trade.ResultOrder());
            else
               Print("SellLimit -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of order: ",m_trade.ResultOrder());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(ExtTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
               continue;

            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //if(m_symbol.Bid()-m_position.PriceOpen()>ExtTrailingStop*m_adjusted_point)
               //{
               if(m_position.StopLoss()<m_symbol.Bid()-(ExtTrailingStop+ExtTrailingStep))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_symbol.Bid()-ExtTrailingStop),
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
               //}
              }
            else
              {
               //if((m_position.PriceOpen()-m_symbol.Ask())>(Point()*ExtTrailingStop_Sell)) // m_symbol.Ask() - цена продажи
               //{
               if((m_position.StopLoss()>(m_symbol.Ask()+(ExtTrailingStop+ExtTrailingStep))) || 
                  (m_position.StopLoss()==0))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_symbol.Ask()+ExtTrailingStop),
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  return;
                 }
               //}
              }

           }
  }
//+------------------------------------------------------------------+
//| Delete all pending rders                                         |
//+------------------------------------------------------------------+
void DeleteAllOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
