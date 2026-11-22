//+------------------------------------------------------------------+
//|                                                 MANAGER GRID.mq4 |
//|                                                Copyright MQL BLUE|
//|                                           http://www.mqlblue.com |
//+------------------------------------------------------------------+
#property copyright "Copyright MQL BLUE"
#property link      "https://www.mqlblue.com"
#property version   "2.0"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>

#define        Version                       "2.0"

input string   AdditionalTradeParams   = "----- Additional Trade Params ------------";
input int      AddNewTradeAfter        = 50;
input string   TakeProfitParams        = "----- Take Profit ------------------------";
input int      TakeProfit1Total        = 150;
input int      TakeProfit1Partitive    = 20;
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
input double   Lots                    = 0.25;
input int      Slippage                = 3;

bool     AllPairsMT4             = true;
int      MagicNo                 = 543227;

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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   ShortName = WindowExpertName();
   Print ("Init "+ShortName+" ver. "+Version);
   point = Point();
   if (Digits()==3 || Digits()==5) point *=10;

   //EURUSD, GBPUSD, USDJPY, USDCAD, GBPNZD, EURNZD, USDCHF, AUDUSD
   if (AllPairsMT4 || StringFind(_Symbol, "EURUSD")>=0 || StringFind(_Symbol, "GBPUSD")>=0 || StringFind(_Symbol, "USDJPY")>=0 || StringFind(_Symbol, "USDCAD")>=0 || StringFind(_Symbol, "GBPNZD")>=0 || StringFind(_Symbol, "EURNZD")>=0 || StringFind(_Symbol, "USDCHF")>=0 || StringFind(_Symbol, "AUDUSD")>=0)
   {
      
      chartId=ChartID();
      if (IsTesting()) chartId=0;
   
      ObjectCreate(chartId, nameProfitPips, OBJ_LABEL,0,0,0,0);
      ObjectSetInteger(chartId, nameProfitPips, OBJPROP_XDISTANCE, 5);
      ObjectSetInteger(chartId, nameProfitPips, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(chartId, nameProfitPips, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString(chartId, nameProfitPips, OBJPROP_TEXT, "Profit pips = 0");
   
      ObjectCreate(chartId, nameProfitCurrency, OBJ_LABEL,0,0,0,0);
      ObjectSetInteger(chartId, nameProfitCurrency, OBJPROP_XDISTANCE, 5);
      ObjectSetInteger(chartId, nameProfitCurrency, OBJPROP_YDISTANCE, 35);
      ObjectSetInteger(chartId, nameProfitCurrency, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString(chartId, nameProfitCurrency, OBJPROP_TEXT, "Profit currency = 0,00 "+AccountCurrency());

      ordersHistoryCount=0;
            
//---
}

    PlaceOrder(OP_SELL, Lots, 0, 0, "", MagicNo);
            return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(chartId, nameProfitPips);
   ObjectDelete(chartId, nameProfitCurrency);
   }
   
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   

   
   int countBUY = CountOrders(OP_BUY);
   int countSELL = CountOrders(OP_SELL);
   int countAll = countBUY + countSELL;
          
   /*
   if (countAll > 0)
   {   
      // close on opposite
      double stochValueSignal = iStochastic(_Symbol, SystemTF, 40, 3, 5, MODE_SMA, 0, MODE_SIGNAL, 0);
      if (NormalizeDouble(stochValueSignal,Digits) > NormalizeDouble(System2,Digits) && countBUY > 0)
      {
         CloseOrders(OP_BUY);
      }
      else if (NormalizeDouble(stochValueSignal,Digits) < NormalizeDouble(System1,Digits) && countSELL > 0)
      {
         CloseOrders(OP_SELL);
      }
   }

   countBUY = CountOrders(OP_BUY, MagicNoD1);
   countSELL = CountOrders(OP_SELL, MagicNoD1);
   countAll = countBUY + countSELL;
   */
   
   if (countAll > 0)
   {
      int i=0;
      // read current orders' comments
      string comments = "";
      bool existOrderWithoutComment = false;
      for (i=0; i<OrdersTotal(); i++)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderSymbol()==_Symbol)
            {
               comments += OrderComment()+";";
               if (StringTrimLeft(StringTrimRight(OrderComment()))=="") existOrderWithoutComment=true;
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
      for (i=OrdersTotal()-1; i>=0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderSymbol()==_Symbol)
            {
               if (StringFind(OrderComment(), "order10")>=0 && MaxOrders > 10)
               {
                  // order 11
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order11")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order11", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order11")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order11", MagicNo);
                  }                                    
               }
               else if (StringFind(OrderComment(), "order11")>=0 && MaxOrders > 11)
               {
                  // order 12
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order12")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order12", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order12")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order12", MagicNo);
                  }                                    
               }
               else if (StringFind(OrderComment(), "order12")>=0 && MaxOrders > 12)
               {
                  // order 13
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order13")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order13", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order13")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order13", MagicNo);
                  }                                    
               }
               else if (StringFind(OrderComment(), "order13")>=0 && MaxOrders > 13)
               {
                  // order 14
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order14")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order14", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order14")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order14", MagicNo);
                  }                                    
               }
               else if (StringFind(OrderComment(), "order14")>=0 && MaxOrders > 14)
               {
                  // order 15
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order15")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order15", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order15")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order15", MagicNo);
                  }                                    
               }                           
               else if ((StringTrimRight(StringTrimLeft(OrderComment()))=="" || StringFind(OrderComment(), "order1")>=0) && MaxOrders > 1)
               {
                  // order 2
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order2")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, TakeProfit2, "order2", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order2")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, TakeProfit2, "order2", MagicNo);
                  }
               }
               else if (StringFind(OrderComment(), "order2")>=0 && MaxOrders > 2)
               {
                  // order 3
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order3")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, TakeProfit3, "order3", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order3")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, TakeProfit3, "order3", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment(), "order3")>=0 && MaxOrders > 3)
               {
                  // order 4
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order4")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order4", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order4")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order4", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment(), "order4")>=0 && MaxOrders > 4)
               {
                  // order 5
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order5")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order5", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order5")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order5", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment(), "order5")>=0 && MaxOrders > 5)
               {
                  // order 6
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order6")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order6", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order6")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order6", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment(), "order6")>=0 && MaxOrders > 6)
               {
                  // order 7
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order7")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order7", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order7")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order7", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment(), "order7")>=0 && MaxOrders > 7)
               {
                  // order 8
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order8")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order8", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order8")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order8", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment(), "order8")>=0 && MaxOrders > 8)
               {
                  // order 9
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order9")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order9", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order9")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order9", MagicNo);
                  }                  
               }
               else if (StringFind(OrderComment(), "order9")>=0 && MaxOrders > 9)
               {
                  // order 10
                  if (OrderType()==OP_BUY && OrderOpenPrice()-Ask >= AddNewTradeAfter*point && StringFind(comments,"order10")<0)
                  {
                     PlaceOrder(OP_BUY, Lots, 0, 0, "order10", MagicNo);
                  }
                  else if (OrderType()==OP_SELL && Bid-OrderOpenPrice() >= AddNewTradeAfter*point && StringFind(comments, "order10")<0)
                  {
                     PlaceOrder(OP_SELL, Lots, 0, 0, "order10", MagicNo);
                  }                  
               }
            }
         } 
      }      
      
      countBUY = CountOrders(OP_BUY);
      countSELL = CountOrders(OP_SELL);
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
               for (i=0; i<OrdersTotal(); i++)
               {
                  if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                  {
                     if (OrderSymbol()==_Symbol && NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(tp,Digits))
                     {
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(tp, Digits), OrderExpiration(), clrNONE))
                        {
                           int error = GetLastError();
                           if (error > 1) 
                              Print(ShortName +" (OrderModify Error) "+ ErrorDescription(error)); 
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
   
   if (OrdersHistoryTotal() != ordersHistoryCount)
   {
      // Refresh pips counter
      HistoryStat histStat = {0,0,0,0,0,0,"",0,0,-1};
      ReadHistory(histStat);
         
      ObjectSetString(chartId, nameProfitPips, OBJPROP_TEXT, "Profit pips = "+DoubleToStr(histStat.profitPips,0));   
      ObjectSetString(chartId, nameProfitCurrency, OBJPROP_TEXT, "Profit currency = "+DoubleToStr(histStat.profitCurrency,2)+" "+AccountCurrency());

      ordersHistoryCount = OrdersHistoryTotal();
   }
   
   ControlTP();
   
   RiskControl();
}

//+------------------------------------------------------------------+
//| Control TP for first 3 orders                                    |
//+------------------------------------------------------------------+
void ControlTP()
{
   int countBUY = CountOrders(OP_BUY);
   int countSELL = CountOrders(OP_SELL);
   int countAll = countBUY + countSELL;

   if (countAll > 1 && countAll <= 3)
   {
      double properTPLevel = 0;
      for (int i=0; i < OrdersTotal(); i++)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderSymbol()==_Symbol)
            {
               if (StringTrimRight(StringTrimLeft(OrderComment()))=="" || StringFind(OrderComment(), "order1")>=0)
               {
                  
                  if (OrderType()==OP_BUY)
                  {
                     properTPLevel = OrderOpenPrice()+TakeProfit1Partitive*point;
                  }
                  else if (OrderType()==OP_SELL)
                  {
                     properTPLevel = OrderOpenPrice()-TakeProfit1Partitive*point;
                  }
                  if (NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(properTPLevel,Digits))
                  {
                     if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(properTPLevel,Digits), OrderExpiration()))
                        Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError())); 
                  }                  
               }
               else if (StringFind(OrderComment(), "order2")>=0)
               {
                  if (OrderType()==OP_BUY)
                  {
                     properTPLevel = OrderOpenPrice()+TakeProfit2*point;
                  }
                  else if (OrderType()==OP_SELL)
                  {
                     properTPLevel = OrderOpenPrice()-TakeProfit2*point;
                  }
                  if (NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(properTPLevel,Digits))
                  {
                     if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(properTPLevel,Digits), OrderExpiration()))
                        Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError())); 
                  }                  
               }
               else if (StringFind(OrderComment(), "order3")>=0)
               {
                  if (OrderType()==OP_BUY)
                  {
                     properTPLevel = OrderOpenPrice()+TakeProfit3*point;
                  }
                  else if (OrderType()==OP_SELL)
                  {
                     properTPLevel = OrderOpenPrice()-TakeProfit3*point;
                  }
                  if (NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(properTPLevel,Digits))
                  {
                     if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(properTPLevel,Digits), OrderExpiration()))
                        Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError())); 
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
         
   ObjectSetString(chartId, nameProfitPips, OBJPROP_TEXT, "Profit pips = "+DoubleToStr(histStat.profitPips,0));   
   ObjectSetString(chartId, nameProfitCurrency, OBJPROP_TEXT, "Profit currency = "+DoubleToStr(histStat.profitCurrency,2)+" "+AccountCurrency());
         
   // sprawdŸ czy bie¿¹cy kurs jest powy¿ej(buy)/poni¿ej(sell) tp o x pips
   // je¿eli tak to otwieramy now¹ pozycjê z komentarzem "order1"   
   if (histStat.lastOrderType >=0 && StringFind(histStat.lastOrderComment, "[tp]")>=0 && NormalizeDouble(histStat.profitPips,0) < TakeProfit1Total)
   {
      if (histStat.lastOrderType == OP_BUY)
      {
         if (MathAbs(NormalizeDouble((Ask - histStat.lastOrderTakeProfit)/point,0)) >= TakeProfit1Offset) PlaceOrder(OP_BUY, Lots, 0, TakeProfit1Partitive, "order1", MagicNo);
      }
      else if (histStat.lastOrderType == OP_SELL)
      {
         if (MathAbs(NormalizeDouble((histStat.lastOrderTakeProfit - Bid)/point,0)) >= TakeProfit1Offset) PlaceOrder(OP_SELL, Lots, 0, TakeProfit1Partitive, "order1", MagicNo);
      }            
   } 
}

//+------------------------------------------------------------------+
//| Control orders loss                                              |
//+------------------------------------------------------------------+
void RiskControl()
{
   double profit = 0;
   double maxRisk = 0-AccountBalance()*(Risk/100);
   for (int i=0; i<OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNo)
         {
            profit += OrderProfit()+OrderCommission()+OrderSwap();
         }
      }
   }
   if (profit < maxRisk)
   {
      Print("Current orders loss = "+DoubleToString(profit,2)+" has exceeded "+DoubleToString(Risk,2)+"% of Account Balance = "+DoubleToString(AccountBalance(),2));
      CloseOrders(OP_BUY);
      CloseOrders(OP_SELL);
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
   int i=OrdersHistoryTotal()-1;
   while (i >=0 && !end)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if (OrderSymbol()==_Symbol && (OrderMagicNumber()==0 || OrderMagicNumber()==MagicNo))
         {
            if (StringFind(OrderComment(), "order1")>=0)
            {
               stat.profitPips += MathAbs(OrderClosePrice()-OrderOpenPrice())/point;
               stat.profitCurrency += OrderProfit()+OrderCommission()+OrderSwap();
               if (OrderOpenTime() > stat.lastOrderOpenTime)
               {
                  stat.lastOrderOpenPrice = OrderOpenPrice();
                  stat.lastOrderClosePrice = OrderClosePrice();
                  stat.lastOrderStopLoss = OrderStopLoss();
                  stat.lastOrderTakeProfit = OrderTakeProfit();
                  stat.lastOrderComment = OrderComment();
                  stat.lastOrderOpenTime = OrderOpenTime();
                  stat.lastOrderCloseTime = OrderCloseTime();
                  stat.lastOrderType = OrderType();
               }
            }
            else
            {
               string comment = OrderComment();
               StringReplace(comment, "[tp]", "");
               StringReplace(comment, "[sl]", "");
               comment = StringTrimLeft(StringTrimRight(comment));
               if (comment == "")
               {
                  stat.profitPips += MathAbs(OrderClosePrice()-OrderOpenPrice())/point;
                  stat.profitCurrency += OrderProfit()+OrderCommission()+OrderSwap();
                  if (OrderOpenTime() > stat.lastOrderOpenTime)
                  {
                     stat.lastOrderOpenPrice = OrderOpenPrice();
                     stat.lastOrderClosePrice = OrderClosePrice();
                     stat.lastOrderStopLoss = OrderStopLoss();
                     stat.lastOrderTakeProfit = OrderTakeProfit();
                     stat.lastOrderComment = OrderComment();
                     stat.lastOrderOpenTime = OrderOpenTime();
                     stat.lastOrderCloseTime = OrderCloseTime();
                     stat.lastOrderType = OrderType();
                  }
                  end = true;
               }
            }
         }
      }
      i--;
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
   
   for(int i=0;i<OrdersTotal();i++) 
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol()) 
         {
            if(OrderType()==OP_BUY) 
            {
               price=price+OrderOpenPrice()*OrderLots();
               lots=lots+OrderLots();
            }
            if(OrderType()==OP_SELL) 
            {
               price=price-OrderOpenPrice()*OrderLots();
               lots=lots-OrderLots();
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
//+------------------------------------------------------------------+
void PlaceOrder(int Type, double Lotz, double SL, double TP, string comment, int magic)
{
   int err;
   color  l_color=Red;
   double l_price=0, takeProfit = 0;
   string action;
   RefreshRates();
      
   // Price and color for the trade type
   if(Type == OP_BUY){ l_price = Ask;  l_color = Blue; action = "Buy"; }
   if(Type == OP_SELL){ l_price = Bid; l_color = Red; action = "Sell"; } 
   
   // Avoid collusions
   while (IsTradeContextBusy()) Sleep(1000);
   long l_datetime = TimeCurrent();
   
   if(!CheckMoneyForTrade(_Symbol, Lotz, (int)MathMod(Type,2))) { 
      Print("Cannot open pending trade - not enough money");
      return;
   }
   // Send order
   int l_ticket = OrderSend(Symbol(), Type, Lotz, l_price, Slippage, 0, 0, comment, magic, 0, l_color);
   
   // Retry if failure
   if (l_ticket == -1)
   {
      while(l_ticket == -1 && TimeCurrent() - l_datetime < 60 && !IsTesting())
      {
         err = GetLastError();
         if (err == 148) return;
         Sleep(1000);
         while (IsTradeContextBusy()) Sleep(1000);
         RefreshRates();
         if (Type == OP_BUY) l_price = Ask;
         if (Type == OP_SELL) l_price = Bid;
         l_ticket = OrderSend(Symbol(), Type, Lotz, l_price, Slippage, 0, 0, comment, magic, 0, l_color);
      }
      if (l_ticket == -1)
         Print(ShortName +" (OrderSend Error) "+ ErrorDescription(GetLastError()));
   }
   if (l_ticket != -1)
   {           
      // Update positions
      if(OrderSelect(l_ticket, SELECT_BY_TICKET, MODE_TRADES) && (TP > 0 || SL > 0))
      {
         // order modify
         int limit = 10;         
         while (limit > 0)
         {
            if(!OrderModify(l_ticket, OrderOpenPrice(), GetStopLoss(OrderType(), SL), GetTakeProfit(OrderType(), TP), 0, Green))
            {
               int error = GetLastError();
               if (error > 1) 
               {
                  Print(ShortName +" (OrderModify Error) "+ ErrorDescription(error)); 
                  RefreshRates();
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
}

bool CheckMoneyForTrade(string symb, double lots,int type)
  {
   ResetLastError();
   double free_margin=AccountFreeMarginCheck(symb,type, lots);
   //-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   //--- checking successful
   return(true);
  }

//+------------------------------------------------------------------+
//| Compute take profit level                                        |
//| PARAMS: int orderType - type of order                            |
//+------------------------------------------------------------------+   
double GetTakeProfit(int orderType, double tp)
{
   double takeProfit = 0;
   if (tp>0)
   {
      double stopLvl = MarketInfo(OrderSymbol(), MODE_STOPLEVEL);   
      if (orderType == OP_BUY)
      {
         takeProfit = OrderOpenPrice() + tp*point;
         if (takeProfit - Bid < stopLvl*Point) 
         {
            takeProfit = Bid + stopLvl*Point + 1*Point;
         }
      }
      else if (orderType == OP_SELL)
      {
         takeProfit = OrderOpenPrice() - tp*point;
         if (Ask - takeProfit < stopLvl*Point)
         {
            takeProfit = Ask - stopLvl*Point - 1*Point;
         }
      }
   }
   return (NormalizeDouble(takeProfit,Digits));
}

//+------------------------------------------------------------------+
//| Compute stop loss level                                          |
//| PARAMS: int orderType - type of order                            |
//+------------------------------------------------------------------+   
double GetStopLoss(int orderType, double sl)
{
   double stopLoss = 0;
   if (sl > 0)
   {
      double stopLvl = MarketInfo(OrderSymbol(), MODE_STOPLEVEL);   
      if (orderType == OP_BUY)
      {
         stopLoss = OrderOpenPrice() - sl*point;
         if (Bid - stopLoss < stopLvl*Point) stopLoss = Bid - stopLvl*Point;
      }
      else if (orderType == OP_SELL)
      {
         stopLoss = OrderOpenPrice() + sl*point;
         if (stopLoss - Ask < stopLvl*Point) stopLoss = Ask + stopLvl*Point;
      }   
   }
   return (NormalizeDouble(stopLoss,Digits));
}
  
//+------------------------------------------------------------------+
//| Count orders                                                     |
//| PARAMS: int      Type - counting orders' type                    |
//| RETURN: orders count                                             |
//+------------------------------------------------------------------+
int CountOrders(int Type)
{
   int count=0;
   for (int i=0; i<OrdersTotal(); i++) 
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      {
         if (OrderSymbol() == Symbol() && OrderMagicNumber()==MagicNo)
         {
            if (OrderType()==Type) count++;
         }
      }
   }
   return (count);         
}    

//+------------------------------------------------------------------+
//| Close Orders                                                     |
//| PARAMS: int Type    - type of closing orders                     |
//+------------------------------------------------------------------+   
void CloseOrders(int Type)
{
   int i=0;      
   datetime l_datetime = TimeCurrent();
   bool closed = false;
   while (i < OrdersTotal())      
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      {
         if (OrderSymbol() == Symbol() && OrderType() == Type && OrderMagicNumber()==MagicNo)
         {
            l_datetime = TimeCurrent();
            closed = false;
            while(!closed && TimeCurrent() - l_datetime < 60)
            {
               closed = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, Gold);
               int err = GetLastError();
               if (err == 150) return;
               Sleep(1000);
               while (IsTradeContextBusy()) Sleep(1000);
               RefreshRates();
            }
            if (closed)
               i--;
            else
               Print("OrderClose Error: "+ ErrorDescription(GetLastError()));        
         }
      }
      i++;
   }                     
}

//+------------------------------------------------------------------+
//| Check if limit of orders on candle is exceeded                   |
//| PARAMS: int      Type - order type                               | 
//| RETURN: true - can open new order                                |
//+------------------------------------------------------------------+
bool CanOpen(ENUM_ORDER_TYPE ordType)
{
   int candleOrdersLimit=1;
   int i=OrdersHistoryTotal()-1;
   int CandleOrdersCount=0;
   bool canOpen = false;
   while (i >= 0 && CandleOrdersCount < candleOrdersLimit)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNo)
         {
            if (OrderOpenTime() < Time[0]) 
               i=-1;
            else
               CandleOrdersCount++;
         }
      }
      i--;
   }
   if (CandleOrdersCount < candleOrdersLimit) canOpen=true;
   return (canOpen);
}  

//+------------------------------------------------------------------+
