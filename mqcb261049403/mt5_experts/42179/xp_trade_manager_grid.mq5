//+------------------------------------------------------------------+
//|                                                 MANAGER GRID.mq5 |
//|                                                Copyright MQL BLUE|
//|                                           http://www.mqlblue.com |
//+------------------------------------------------------------------+
#property copyright "Copyright MQL BLUE"
#property link      "https://www.mqlblue.com"
#property version   "3.0"
#property strict

#define        Version                       "3.0"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

input string   AdditionalTradeParams   = "----- Additional Trade Params ------------";
input int      AddNewTradeAfter        = 50;
input string   TakeProfitParams        = "----- Take Profit ------------------------";
input int      TakeProfit1Total        = 150;
input int      TakeProfit1Partitive    = 10;
input int      TakeProfit1Offset       = 3;
input int      TakeProfit2             = 40;
input int      TakeProfit3             = 50;
input int      TakeProfit4Total        = 60;
input int      TakeProfit5Total        = 70;
input int      TakeProfit6Total        = 80;
input int      TakeProfit7Total        = 90;
input int      TakeProfit8Total        = 100;
input int      TakeProfit9Total        = 120;
input int      TakeProfit10Total       = 150;
input int      TakeProfit11Total       = 180;
input int      TakeProfit12Total       = 200;
input int      TakeProfit13Total       = 220;
input int      TakeProfit14Total       = 250;
input int      TakeProfit15Total       = 300;
input string   TradeParams             = "----- Trade Params ------------------------";
input int      MaxOrders               = 15;
input double   Risk                    = 100;   // Risk Balance (%)
input double   Lots                    = 0.01;
input int      Slippage                = 3;

int      MagicNo                 = 0;

string ShortName = "XP Trade Manager Grid";
int LastOrdersCount=0;
long chartId=0;
int ordersHistoryCount=0;

struct HistoryStat
{
   double profitPips;
   double profitCurrency;
   double lastOrderOpenPrice;
   double lastOrderClosePrice;
   double lastOrderStopLoss;
   double lastOrderTakeProfit;
   string lastOrderComment;
   datetime lastOrderOpenTime;
   datetime lastOrderCloseTime;
   int lastOrderType;
};

const string nameProfitPips = "profitPips";  
const string nameProfitCurrency = "profitCurrency";

struct HistOrders
{
   int currPendingCount;
   int currActiveCount;
   int histPendingCount;
   int histActiveCount;
};

double stageHigh=0;
double stageLow=0;
string ObjectSignature="";
double point=0;
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CTrade *tradeClass;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   ShortName = MQLInfoString(MQL_PROGRAM_NAME);
   Print ("Init "+ShortName+" ver. "+Version);
   point = Point();
   if (Digits()==3 || Digits()==5) point *=10;
   tradeClass = new CTrade();
	tradeClass.SetDeviationInPoints(Slippage);
	tradeClass.SetExpertMagicNumber(MagicNo);

      chartId=ChartID();
   
      ObjectCreate(chartId, nameProfitPips, OBJ_LABEL,0,0,0,0);
      ObjectSetInteger(chartId, nameProfitPips, OBJPROP_XDISTANCE, 5);
      ObjectSetInteger(chartId, nameProfitPips, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(chartId, nameProfitPips, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString(chartId, nameProfitPips, OBJPROP_TEXT, "Profit pips = 0");
   
      ObjectCreate(chartId, nameProfitCurrency, OBJ_LABEL,0,0,0,0);
      ObjectSetInteger(chartId, nameProfitCurrency, OBJPROP_XDISTANCE, 5);
      ObjectSetInteger(chartId, nameProfitCurrency, OBJPROP_YDISTANCE, 35);
      ObjectSetInteger(chartId, nameProfitCurrency, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString(chartId, nameProfitCurrency, OBJPROP_TEXT, "Profit currency = 0,00 "+AccountInfoString(ACCOUNT_CURRENCY));

      ordersHistoryCount=0;
 
//---
      return(INIT_SUCCEEDED);
      
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete tradeClass;
   ObjectDelete(chartId, nameProfitPips);
   ObjectDelete(chartId, nameProfitCurrency);
   }
   
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   
   
   int countBUY = CountOrders(POSITION_TYPE_BUY);
   int countSELL = CountOrders(POSITION_TYPE_SELL);
   int countAll = countBUY + countSELL;
          

   if (countAll > 0)
   {
      int i=0;
      // read current orders' comments
      string comments = "";
      bool existOrderWithoutComment = false;
      m_trade.SetExpertMagicNumber(MagicNo);
      for(int j=PositionsTotal()-1;j>=0;j--){ // returns the number of current positions
         if(m_position.SelectByIndex(j))  {   // selects the position by index for further access to its properties
            if(m_position.Symbol()==_Symbol){ 
               ulong ticket = m_position.Ticket(); 
               comments += m_position.Comment()+";";
               string oCom = m_position.Comment();
               StringTrimRight(oCom);
               StringTrimLeft(oCom);
               if (oCom=="") existOrderWithoutComment=true;
            }
         }
      }
      
      // check for renew first order
      if (StringFind(comments, "order1")<0 && !existOrderWithoutComment)
      {
         RenewFirstOrder();  
      }
      
      // check orders
      string orderComment = "";
      double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      double Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      m_trade.SetExpertMagicNumber(MagicNo);
      for(int j=PositionsTotal()-1;j>=0;j--){ // returns the number of current positions
         if(m_position.SelectByIndex(j))  {   // selects the position by index for further access to its properties
            if( m_position.Symbol()==_Symbol){ 
               ulong ticket = m_position.Ticket(); 
               string OrderComment = m_position.Comment();
               string trimcom = OrderComment;
               StringTrimRight(trimcom);
               StringTrimLeft(trimcom);
               if (StringFind(OrderComment, "order10")>=0 && MaxOrders > 10)
               {
                  // order 11
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order11")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order11", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order11")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order11", MagicNo);
                  }                                    
               }
               else if (StringFind(OrderComment, "order11")>=0 && MaxOrders > 11)
               {
                  // order 12
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order12")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order12", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order12")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order12", MagicNo);
                  }                                    
               }
               else if (StringFind(OrderComment, "order12")>=0 && MaxOrders > 12)
               {
                  // order 13
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order13")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order13", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order13")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order13", MagicNo);
                  }                                    
               }
               else if (StringFind(OrderComment, "order13")>=0 && MaxOrders > 13)
               {
                  // order 14
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order14")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order14", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order14")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order14", MagicNo);
                  }                                    
               }
               else if (StringFind(OrderComment, "order14")>=0 && MaxOrders > 14)
               {
                  // order 15
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order15")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order15", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order15")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order15", MagicNo);
                  }                                    
               }                           
               else if ((trimcom =="" || StringFind(OrderComment, "order1")>=0) && MaxOrders > 1)
               {
                  // order 2
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order2")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, TakeProfit2, "order2", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order2")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, TakeProfit2, "order2", MagicNo);
                  }
               }
               else if (StringFind(OrderComment, "order2")>=0 && MaxOrders > 2)
               {
                  // order 3
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order3")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, TakeProfit3, "order3", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order3")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, TakeProfit3, "order3", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment, "order3")>=0 && MaxOrders > 3)
               {
                  // order 4
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order4")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order4", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order4")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order4", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment, "order4")>=0 && MaxOrders > 4)
               {
                  // order 5
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order5")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order5", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL&& Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order5")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order5", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment, "order5")>=0 && MaxOrders > 5)
               {
                  // order 6
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order6")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order6", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order6")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order6", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment, "order6")>=0 && MaxOrders > 6)
               {
                  // order 7
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order7")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order7", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order7")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order7", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment, "order7")>=0 && MaxOrders > 7)
               {
                  // order 8
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order8")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order8", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order8")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order8", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment, "order8")>=0 && MaxOrders > 8)
               {
                  // order 9
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order9")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order9", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order9")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order9", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment, "order9")>=0 && MaxOrders > 9)
               {
                  // order 10
                  if (m_position.PositionType()==POSITION_TYPE_BUY && m_position.PriceOpen()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order10")<0)
                  {
                     PlaceOrder(ORDER_TYPE_BUY, Lots, 0, 0, "order10", MagicNo);
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL && Bid-m_position.PriceOpen() >= AddNewTradeAfter*point && StringFind(comments, "order10")<0)
                  {
                     PlaceOrder(ORDER_TYPE_SELL, Lots, 0, 0, "order10", MagicNo);
                  }                  
               }
            }
         } 
      }      
      
      countBUY = CountOrders(POSITION_TYPE_BUY);
      countSELL = CountOrders(POSITION_TYPE_SELL);
      countAll = countBUY + countSELL;
      
      if (countAll >= 4 && countAll != LastOrdersCount && (StringFind(comments, "order1")>=0 || existOrderWithoutComment))
      {
         double beLevel = ComputeBE();
         if (beLevel > 0)
         {
            double tp = beLevel;
            if (countBUY > countSELL)
            {
               if (countAll == 4)
               {
                  tp += (TakeProfit4Total/countAll)*point;
               }
               else if (countAll == 5)
               {
                  tp += (TakeProfit5Total/countAll)*point;
               }
               else if (countAll == 6)
               {
                  tp += (TakeProfit6Total/countAll)*point;
               }
               else if (countAll == 7)
               {
                  tp += (TakeProfit7Total/countAll)*point;
               }
               else if (countAll == 8)
               {
                  tp += (TakeProfit8Total/countAll)*point;
               }
               else if (countAll == 9)
               {
                  tp += (TakeProfit9Total/countAll)*point;
               }
               else if (countAll == 10)
               {
                  tp += (TakeProfit10Total/countAll)*point;
               }
               else if (countAll == 11)
               {
                  tp += (TakeProfit11Total/countAll)*point;
               }
               else if (countAll == 12)
               {
                  tp += (TakeProfit12Total/countAll)*point;
               }
               else if (countAll == 13)
               {
                  tp += (TakeProfit13Total/countAll)*point;
               }
               else if (countAll == 14)
               {
                  tp += (TakeProfit14Total/countAll)*point;
               }
               else if (countAll == 15)
               {
                  tp += (TakeProfit15Total/countAll)*point;
               }
            }
            else
            {
               if (countAll == 4)
               {
                  tp -= (TakeProfit4Total/countAll)*point;
               }
               else if (countAll == 5)
               {
                  tp -= (TakeProfit5Total/countAll)*point;
               }
               else if (countAll == 6)
               {
                  tp -= (TakeProfit6Total/countAll)*point;
               }
               else if (countAll == 7)
               {
                  tp -= (TakeProfit7Total/countAll)*point;
               }
               else if (countAll == 8)
               {
                  tp -= (TakeProfit8Total/countAll)*point;
               }
               else if (countAll == 9)
               {
                  tp -= (TakeProfit9Total/countAll)*point;
               }
               else if (countAll == 10)
               {
                  tp -= (TakeProfit10Total/countAll)*point;
               }
               else if (countAll == 11)
               {
                  tp -= (TakeProfit11Total/countAll)*point;
               }
               else if (countAll == 12)
               {
                  tp -= (TakeProfit12Total/countAll)*point;
               }
               else if (countAll == 13)
               {
                  tp -= (TakeProfit13Total/countAll)*point;
               }
               else if (countAll == 14)
               {
                  tp -= (TakeProfit14Total/countAll)*point;
               }
               else if (countAll == 15)
               {
                  tp -= (TakeProfit15Total/countAll)*point;
               }
            }
            
            if (tp > 0)
            {
               m_trade.SetExpertMagicNumber(0);
               for(int j=PositionsTotal()-1;j>=0;j--){ // returns the number of current positions
                  if(m_position.SelectByIndex(j))  {   // selects the position by index for further access to its properties
                     if( m_position.Symbol()==_Symbol){ 
                        ulong ticket = m_position.Ticket(); 
                        if (NormalizeDouble(m_position.TakeProfit(),Digits())!=NormalizeDouble(tp,Digits()))
                        {
                            
                           ResetLastError();
                           if(!m_trade.PositionModify(ticket, m_position.StopLoss(), NormalizeDouble(tp, Digits())))
                           {
                              int error = GetLastError();
                              if (error > 1) 
                                 Print(ShortName +" (OrderModify Error) "+ IntegerToString(error)); 
                           }   
                           
                        }            
                     }
                  }
               }
            }
            
         }
      }
      LastOrdersCount = countAll;
      
   }
   else
   {
      RenewFirstOrder();
   }
   
      
   ControlTP();
   
   RiskControl();
 
}
void OnTrade(){   
   
   //Print("TRADE EVENSJ------------------------------------------");
//   if (OrdersHistoryTotal() != ordersHistoryCount)
      {
      // Refresh pips counter
      HistoryStat histStat = {0,0,0,0,0,0,"",0,0,-1};
      ReadHistory(histStat);
         
      ObjectSetString(chartId, nameProfitPips, OBJPROP_TEXT, "Profit pips = "+DoubleToString(histStat.profitPips,0));   
      ObjectSetString(chartId, nameProfitCurrency, OBJPROP_TEXT, "Profit currency = "+DoubleToString(histStat.profitCurrency,2)+" "+AccountInfoString(ACCOUNT_CURRENCY));

     // ordersHistoryCount = OrdersHistoryTotal();
   }

}

//+------------------------------------------------------------------+
//| Control TP for first 3 orders                                    |
//+------------------------------------------------------------------+
void ControlTP()
{
   int countBUY = CountOrders(POSITION_TYPE_BUY);
   int countSELL = CountOrders(POSITION_TYPE_SELL);
   int countAll = countBUY + countSELL;

   if (countAll > 1 && countAll <= 3)
   {
      double properTPLevel = 0;
      m_trade.SetExpertMagicNumber(MagicNo);
      for(int j=PositionsTotal()-1;j>=0;j--){ // returns the number of current positions
         if(m_position.SelectByIndex(j))  {   // selects the position by index for further access to its properties
            if( m_position.Symbol()==_Symbol){ 
               ulong ticket = m_position.Ticket(); 
               string OrderComment = m_position.Comment();
               string trimcom = OrderComment;
               StringTrimRight(trimcom);
               StringTrimLeft(trimcom);       
               if (trimcom=="" || StringFind(OrderComment, "order1")>=0)
               {
                  
                  if (m_position.PositionType()==POSITION_TYPE_BUY)
                  {
                     properTPLevel = m_position.PriceOpen()+TakeProfit1Partitive*point;
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL)
                  {
                     properTPLevel = m_position.PriceOpen()-TakeProfit1Partitive*point;
                  }
                  if (NormalizeDouble(m_position.TakeProfit(),Digits()) != NormalizeDouble(properTPLevel,Digits()))
                  {
                     ResetLastError();
                     if (!m_trade.PositionModify(ticket, m_position.StopLoss(), NormalizeDouble(properTPLevel,Digits())))
                        Print(ShortName +" (OrderModify Error) "+ IntegerToString(GetLastError())); 
                  }                  
               }
               else if (StringFind(OrderComment, "order2")>=0)
               {
                  if (m_position.PositionType()==POSITION_TYPE_BUY)
                  {
                     properTPLevel = m_position.PriceOpen()+TakeProfit2*point;
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL)
                  {
                     properTPLevel = m_position.PriceOpen()-TakeProfit2*point;
                  }
                  if (NormalizeDouble(m_position.TakeProfit(),Digits()) != NormalizeDouble(properTPLevel,Digits()))
                  {
                     ResetLastError();
                     if (!m_trade.PositionModify(ticket, m_position.StopLoss(), NormalizeDouble(properTPLevel,Digits())))
                        Print(ShortName +" (OrderModify Error) "+ IntegerToString(GetLastError())); ; 
                  }                  
               }
               else if (StringFind(OrderComment, "order3")>=0)
               {
                  if (m_position.PositionType()==POSITION_TYPE_BUY)
                  {
                     properTPLevel = m_position.PriceOpen()+TakeProfit3*point;
                  }
                  else if (m_position.PositionType()==POSITION_TYPE_SELL)
                  {
                     properTPLevel = m_position.PriceOpen()-TakeProfit3*point;
                  }
                  if (NormalizeDouble(m_position.TakeProfit(),Digits()) != NormalizeDouble(properTPLevel,Digits()))
                  {
                     ResetLastError();
                     if (!m_trade.PositionModify(ticket, m_position.StopLoss(), NormalizeDouble(properTPLevel,Digits())))
                        Print(ShortName +" (OrderModify Error) "+ IntegerToString(GetLastError())); 
                  }                  
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Try to renew first order                                         |
//+------------------------------------------------------------------+
void RenewFirstOrder()
{
   // do struktury odczytaj:
   // 1. ³aczny profit ze zleceñ z komentarzem order1 + zlecenie bez komentarza (od najnowszego "order1" do zlecenia bez komentarza w³¹cznie)
   // 2. open i tp najnowszego zlecenia "order1" lub bez komentarza (ale zamkniêtego na tp).
   HistoryStat histStat = {0,0,0,0,0,0,"",0,0,-1};
   ReadHistory(histStat);
         
   ObjectSetString(chartId, nameProfitPips, OBJPROP_TEXT, "Profit pips = "+DoubleToString(histStat.profitPips,0));   
   ObjectSetString(chartId, nameProfitCurrency, OBJPROP_TEXT, "Profit currency = "+DoubleToString(histStat.profitCurrency,2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
         
   // sprawdŸ czy bie¿¹cy kurs jest powy¿ej(buy)/poni¿ej(sell) tp o x pips
   // je¿eli tak to otwieramy now¹ pozycjê z komentarzem "order1"  
   if (histStat.lastOrderType >=0 && StringFind(histStat.lastOrderComment, "tp")>=0 && NormalizeDouble(histStat.profitPips,0) < TakeProfit1Total)
   {
   //Print(histStat.lastOrderComment+"__"+histStat.lastOrderType+" "+histStat.profitPips); 
      if (histStat.lastOrderType == DEAL_TYPE_BUY)
      {
         if (MathAbs(NormalizeDouble((SymbolInfoDouble(Symbol(), SYMBOL_ASK) - histStat.lastOrderTakeProfit)/point,0)) >= TakeProfit1Offset) PlaceOrder(ORDER_TYPE_BUY, Lots, 0, TakeProfit1Partitive, "order1", MagicNo);
      }
      else if (histStat.lastOrderType == DEAL_TYPE_SELL)
      {
         if (MathAbs(NormalizeDouble((histStat.lastOrderTakeProfit - SymbolInfoDouble(Symbol(), SYMBOL_BID))/point,0)) >= TakeProfit1Offset) PlaceOrder(ORDER_TYPE_SELL, Lots, 0, TakeProfit1Partitive, "order1", MagicNo);
      }            
   } 
}

//+------------------------------------------------------------------+
//| Control orders loss                                              |
//+------------------------------------------------------------------+
void RiskControl()
{
   double profit = 0;
   double maxRisk = 0-AccountInfoDouble(ACCOUNT_BALANCE)*(Risk/100);
   for(int j=PositionsTotal()-1;j>=0;j--){ // returns the number of current positions
      if(m_position.SelectByIndex(j))  {   // selects the position by index for further access to its properties
         if( m_position.Symbol()==_Symbol && m_position.Magic()==MagicNo){ 
            profit += m_position.Profit()+m_position.Swap()+m_position.Commission();
         }
      }
   }
   if (profit < maxRisk)
   {
      Print("Current orders loss = "+DoubleToString(profit,2)+" has exceeded "+DoubleToString(Risk,2)+"% of Account Balance = "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2));
      CloseOrders(ORDER_TYPE_BUY);
      CloseOrders(ORDER_TYPE_SELL);
   }
}

//+------------------------------------------------------------------+
//| Read stat from history                                           |
//+------------------------------------------------------------------+
bool ReadHistory(HistoryStat &stat)
{
   stat.profitPips=0;
   stat.profitCurrency=0;
   stat.lastOrderOpenPrice=0;
   stat.lastOrderClosePrice=0;
   stat.lastOrderStopLoss=0;
   stat.lastOrderTakeProfit=0;
   stat.lastOrderComment="";
   stat.lastOrderOpenTime=0;
   stat.lastOrderCloseTime=0;
   stat.lastOrderType=-1;
   
   bool end = false;
   HistorySelect(0, TimeCurrent());
   int total = HistoryDealsTotal();
   for (int d = total-1; d >= 0; d--){
      //Print(d);
      ulong outticket=HistoryDealGetTicket(d);
      if ( HistoryDealGetInteger(outticket, DEAL_MAGIC) != 0 && HistoryDealGetInteger(outticket, DEAL_MAGIC) != MagicNo  ) continue;
      if ( HistoryDealGetString(outticket, DEAL_SYMBOL)!= Symbol()) continue; 
      if(HistoryDealGetInteger(outticket,DEAL_ENTRY)==DEAL_ENTRY_OUT){ 
         double clprice = HistoryDealGetDouble(outticket, DEAL_PRICE);
         datetime cltime = (datetime)HistoryDealGetInteger(outticket, DEAL_TIME);
         double sl = HistoryDealGetDouble(outticket, DEAL_SL);
         double tp = HistoryDealGetDouble(outticket, DEAL_TP);
         double profit = HistoryDealGetDouble(outticket, DEAL_PROFIT)+HistoryDealGetDouble(outticket, DEAL_COMMISSION)+HistoryDealGetDouble(outticket, DEAL_SWAP);
         long posticket = HistoryDealGetInteger(outticket, DEAL_POSITION_ID);
         string outcomm = HistoryDealGetString(outticket, DEAL_COMMENT);
         for(int o=total-1; o>=0; o--){ 
            ulong ticket=HistoryDealGetTicket(o); 
            if(Symbol()!=HistoryDealGetString(ticket,DEAL_SYMBOL)) continue;
            if(HistoryDealGetInteger(ticket, DEAL_MAGIC)!=0 && HistoryDealGetInteger(ticket, DEAL_MAGIC)!=MagicNo) continue;
            if(HistoryDealGetInteger(ticket, DEAL_POSITION_ID)!=posticket)continue;
            if(HistoryDealGetInteger(ticket,DEAL_ENTRY)==DEAL_ENTRY_IN){
               double opprice = HistoryDealGetDouble(ticket, DEAL_PRICE);
               datetime optime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
               string comm = HistoryDealGetString(ticket, DEAL_COMMENT);
               int type = (int) HistoryDealGetInteger(ticket, DEAL_TYPE);
             
             
             //find out for this position
               if (StringFind(comm, "order1")>=0){
                  stat.profitPips += MathAbs(clprice-opprice)/point;
                  stat.profitCurrency+=profit;   
                  if (optime> stat.lastOrderOpenTime)
                  {
                     stat.lastOrderOpenPrice = opprice;
                     stat.lastOrderClosePrice = clprice;
                     stat.lastOrderStopLoss = sl;
                     stat.lastOrderTakeProfit = tp;
                     stat.lastOrderComment = outcomm;
                     stat.lastOrderOpenTime = optime;
                     stat.lastOrderCloseTime = cltime;
                     stat.lastOrderType = type;
                  }
               }
               else 
               {
                  StringReplace(comm, "tp", "");
                  StringReplace(comm, "sl", "");
                  StringTrimLeft(comm);
                  StringTrimRight(comm);
                  if (comm == "")
                  {
                     stat.profitPips += MathAbs(clprice-opprice)/point;
                     stat.profitCurrency+=profit;   
                 /// if(ticket==2)Print((comm=="") +" "+posticket+" "+profit+" _"+comm+"_ "+stat.profitCurrency);
                     if (optime> stat.lastOrderOpenTime)
                     {
                        stat.lastOrderOpenPrice = opprice;
                        stat.lastOrderClosePrice = clprice;
                        stat.lastOrderStopLoss = sl;
                        stat.lastOrderTakeProfit = tp;
                        stat.lastOrderComment = outcomm;
                        stat.lastOrderOpenTime = optime;
                        stat.lastOrderCloseTime = cltime;
                        stat.lastOrderType = type;
                     }
                     end = true;
                     break;
                  }
               }
            }
         }
         if(end) break;
      }
   }            

   
   return (true);
}

//+------------------------------------------------------------------+
//| Compute Break Even point for all orders                          |
//+------------------------------------------------------------------+
double ComputeBE()
{
   double lots=0;
   double price=0;
   
   m_trade.SetExpertMagicNumber(MagicNo);
   for(int j=PositionsTotal()-1;j>=0;j--){ // returns the number of current positions
      if(m_position.SelectByIndex(j))  {   // selects the position by index for further access to its properties
         if( m_position.Symbol()==_Symbol){
            if(m_position.PositionType()==POSITION_TYPE_BUY) 
            {
               price=price+m_position.PriceOpen()*m_position.Volume();
               lots=lots+m_position.Volume();
            }
            else  if(m_position.PositionType()==POSITION_TYPE_SELL) 
            {
               price=price-m_position.PriceOpen()*m_position.Volume();
               lots=lots-m_position.Volume();
            }  
         }
      }
   }
   double level=0;
   
   if(lots!=0) level=price/lots;
   return (level);
}

  

//+------------------------------------------------------------------+
//| Places an order                                                  |
//| PARAMS: int      Type  - order type                              |
//|         double   Lotz  - trans size                              |
//|         int      Magic - optional magic no                       |
//| RETURN: order ticket or 0 if fails                               |
//+------------------------------------------------------------------+
ulong PlaceOrder(ENUM_ORDER_TYPE Type, double Lotz, double SL, double TP, string comment, int magic)
{
   color  l_color=Red;
   double l_price=0, takeProfit = 0;   
   MqlTradeResult resultInfo;
      
   // Price and color for the trade type
   if(Type == ORDER_TYPE_BUY)         { l_price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);  l_color = Blue;  }
   if(Type == ORDER_TYPE_SELL)        { l_price = SymbolInfoDouble(Symbol(), SYMBOL_BID); l_color = Red;  } 
   
   // Avoid collusions
   long l_datetime = TimeCurrent();
   l_price = normPrice(l_price);
   Lotz = normalizeLots(Lotz);
   if(!CheckMoneyForTrade(_Symbol, Lotz, Type)) return(-1);
   
      // Send order

   bool result = tradeClass.PositionOpen(_Symbol, (ENUM_ORDER_TYPE)Type, Lotz, l_price, 0, 0, comment);
   // Retry if failure
   tradeClass.Result(resultInfo);
   
   // Retry if failure
   if (!result)
   {
      while(!result && TimeCurrent() - l_datetime < 10 && !MQLInfoInteger(MQL_TESTER))
      {
         if (resultInfo.retcode == TRADE_RETCODE_LIMIT_POSITIONS) return (0);
         Sleep(1000);

         if (Type == ORDER_TYPE_BUY) l_price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         if (Type == ORDER_TYPE_SELL) l_price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         l_price  = normPrice(l_price);
         result = tradeClass.PositionOpen(_Symbol, (ENUM_ORDER_TYPE)Type, Lotz, l_price, 0, 0, comment);
         tradeClass.Result(resultInfo);
      }
      if (!result) Print(__FUNCTION__+" PositionOpen Error: code="+ IntegerToString(resultInfo.retcode));
   }
   ulong ticket = resultInfo.order;
   if (result)
   {   
      m_trade.SetExpertMagicNumber(magic);
      if (m_position.SelectByIndex((int)resultInfo.order)  && (TP > 0 || SL > 0))
      {
         ticket = resultInfo.order;
         double orderSL = GetStopLoss(Type, l_price,  SL); 
         double orderTP = GetTakeProfit(Type,l_price, TP);
         
         int limit = 10;         
         while (limit > 0)
         {
            ResetLastError();
            if(!m_trade.PositionModify(ticket, orderSL, orderTP ))
            {
               int error = GetLastError();
               if (error > 1) 
               {
                  Print(ShortName +" (OrderModify Error) "+ IntegerToString(error)); 
                  Sleep(1000);
               }
               else
                  limit=0;   
            }
            else
               limit=0;
            limit--;
         }
      } 
                      
   }
   return (ticket);
}
  
 
 //+------------------------------------------------------------------+
//| Compute stop loss level                                          |
//| PARAMS: int orderType - type of order                            |
//+------------------------------------------------------------------+   
double GetStopLoss(ENUM_ORDER_TYPE orderType, double OrderOpenPrice, double StopLoss)
{
   double stopLoss = 0;
   if (StopLoss > 0)
   {
      long stopLvl = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);   
      if (orderType == ORDER_TYPE_BUY)
      {
         stopLoss = OrderOpenPrice - StopLoss*point;
         if (SymbolInfoDouble(_Symbol, SYMBOL_BID) - stopLoss < stopLvl*_Point) 
         {
            stopLoss = SymbolInfoDouble(_Symbol, SYMBOL_BID) - stopLvl*_Point - 1*_Point;
            //Print("Min. distance ("+DoubleToString(stopLvl*_Point, _Digits)+") is exceeded. New StopLoss value is "+DoubleToString(stopLoss, _Digits));
         }
         
      }
      else if (orderType == ORDER_TYPE_SELL)
      {
         stopLoss = OrderOpenPrice + StopLoss*point;
         if (stopLoss - SymbolInfoDouble(_Symbol, SYMBOL_ASK) < stopLvl*_Point) 
         {
            stopLoss = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + stopLvl*_Point + 1*_Point;
           //Print("Min. distance ("+DoubleToString(stopLvl*_Point, _Digits)+") is exceeded. New StopLoss value is "+DoubleToString(stopLoss,_Digits));
         }
      }   
   }
   return (NormalizeDouble(stopLoss,_Digits));
}

//+------------------------------------------------------------------+
//| Compute take profit level                                        |
//| PARAMS: int orderType - type of order                            |
//+------------------------------------------------------------------+   
double GetTakeProfit(ENUM_ORDER_TYPE orderType, double OrderOpenPrice,  double TakeProfit)
{
   double takeProfit = 0;
   if (TakeProfit>0)
   {
      long stopLvl = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);   
      if (orderType == ORDER_TYPE_BUY)
      {
         takeProfit = OrderOpenPrice + TakeProfit*point;
         if (takeProfit - SymbolInfoDouble(_Symbol, SYMBOL_BID) < stopLvl*_Point) 
         {
            takeProfit = SymbolInfoDouble(_Symbol, SYMBOL_BID) + stopLvl*_Point + 1*_Point;
         }
      }
      else if (orderType ==ORDER_TYPE_SELL)
      {
         takeProfit = OrderOpenPrice - TakeProfit*point;
         if (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - takeProfit < stopLvl*_Point)
         {
            takeProfit = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLvl*_Point - 1*_Point;
         }
      }
   }
   return (NormalizeDouble(takeProfit,_Digits));
} 
//+------------------------------------------------------------------+
//| Count orders                                                     |
//| PARAMS: int      Type - counting orders' type                    |
//| RETURN: orders count                                             |
//+------------------------------------------------------------------+
int CountOrders(int Type)
{
   int count=0;
   for(int j=PositionsTotal()-1;j>=0;j--){ // returns the number of current positions
      if(m_position.SelectByIndex(j))  {   // selects the position by index for further access to its properties
         if( m_position.Symbol()==_Symbol && m_position.Magic()==MagicNo) 
         {
            if (m_position.PositionType()==Type) count++;
         }
      }
   }
   return (count);         
}    

//+------------------------------------------------------------------+
//| Close Orders                                                     |
//| PARAMS: int Type    - type of closing orders                     |
//+------------------------------------------------------------------+   
void CloseOrders(ENUM_ORDER_TYPE orderType)
{
   datetime l_datetime = TimeCurrent();
   MqlTradeResult resultInfo;
   ulong ticket=0;
   bool result = false;
   int i=PositionsTotal()-1;      

   while (i>=0)      
   {	
      ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket)) 
      {
         if (PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC)==MagicNo && PositionGetInteger(POSITION_TYPE)==orderType)
         {
            l_datetime = TimeCurrent();
			   result = false;
            while(!result && TimeCurrent() - l_datetime < 10)
            {
               result = tradeClass.PositionClose(ticket);
               if (!result)
               {
                  tradeClass.Result(resultInfo);
                  if (resultInfo.retcode == TRADE_RETCODE_POSITION_CLOSED) return;
               }
               if (!result) Sleep(1000);  
            }
            
            if (!result)
            {
               tradeClass.Result(resultInfo);
               Print(__FUNCTION__+" PositionClose Error: code="+ IntegerToString(resultInfo.retcode));            
            }
         }
      }
      i--;
   }                     
}
  

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Normalization functions                                          |
//| RETURN: normalized values                                        |
//+------------------------------------------------------------------+

double normPrice(double p, string pair=""){
        // Prices to open must be a multiple of ticksize 
    if (pair == "") pair = _Symbol;
    double ts = SymbolInfoDouble(pair, SYMBOL_TRADE_TICK_SIZE);
    return( MathRound(p/ts) * ts );
}

ENUM_ORDER_TYPE_FILLING GetFilling( const string Symb, const uint Type = ORDER_FILLING_FOK )
{
  const ENUM_SYMBOL_TRADE_EXECUTION ExeMode = (ENUM_SYMBOL_TRADE_EXECUTION)::SymbolInfoInteger(Symb, SYMBOL_TRADE_EXEMODE);
  const int FillingMode = (int)::SymbolInfoInteger(Symb, SYMBOL_FILLING_MODE);

  return((FillingMode == 0 || (Type >= ORDER_FILLING_RETURN) || ((FillingMode & (Type + 1)) != Type + 1)) ?
         (((ExeMode == SYMBOL_TRADE_EXECUTION_EXCHANGE) || (ExeMode == SYMBOL_TRADE_EXECUTION_INSTANT)) ?
           ORDER_FILLING_RETURN : ((FillingMode == SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK)) :
          (ENUM_ORDER_TYPE_FILLING)Type);
}

double normalizeLots(double value) {

    double minLots=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
    double maxLots=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
    double minStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
    if(value<minLots) {
     value=minLots;
    }
    
    if(value>maxLots) {
     value=maxLots;
    }
    
    int digits=1;
    
    if(minStep<0.1) {
     digits=2;
    }else if(minStep == 1){
     digits = 0;
    }else if(minStep == 0.05){
     return(NormalizeDouble(NormalizeDouble(2*value, 1)/2, 2));
    }
    
    return(NormalizeDouble(MathRound(value / minStep) * minStep,digits));

    //return(NormalizeDouble(value,digits));
}



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
  