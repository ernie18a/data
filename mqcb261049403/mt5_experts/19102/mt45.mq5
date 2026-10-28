//+------------------------------------------------------------------+
//|                                                        MT45.mq45 |
//|                                              Copyright 2017, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"
#property strict

//--- переопределим типы ордеров из MQL4 в MQL5
#ifdef __MQL5__ 
#define OrdersTotal  PositionsTotal
#define OP_BUY  ORDER_TYPE_BUY        
#define OP_SELL ORDER_TYPE_SELL       
#endif 

input int    Stop = 600;  // стоплосс
input int    Take = 700;  // тейкпрофит
input int    Slip = 100;  // проскальзывание
input int    MN   = 123;  // магик
input double LT   = 0.01; // лот
input double KL   = 2;    // увеличение лота
input double ML   = 10;   // максимальный лот

int bars=0;
bool b=true,s=true;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

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
//| открывает позицию                                                |
//+------------------------------------------------------------------+
bool PutOrder(ENUM_ORDER_TYPE type,double price,double sl,double tp)
  {
//---  MQL4
#ifdef __MQL4__
   int ticket=OrderSend(_Symbol,type,Lot(),price,Slip,sl,tp,"",MN);
   if(ticket<0)
      PrintFormat("OrderSend error %d",GetLastError());
#endif
//---  MQL5         
#ifdef __MQL5__
//--- объявление и инициализация запроса и результата
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- параметры запроса
   request.action   =TRADE_ACTION_DEAL;                     // тип торговой операции
   request.symbol   =Symbol();                              // символ
   request.volume   =Lot();                                 // объем 
   request.type     =type;                                  // тип ордера
   request.price    =price;                                 // цена для открытия
   request.sl       =sl;                                    // цена StopLoss
   request.tp       =tp;                                    // цена TakeProfit
   request.deviation=Slip;                                  // допустимое отклонение от цены
   request.magic    =MN;                                    // MagicNumber ордера
//--- отправка запроса
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());     // если отправить запрос не удалось, вывести код ошибки
//--- информация об операции
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
#endif  
//---
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lot()
  {
   double lot=LT;
//---  MQL4
#ifdef __MQL4__
   if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
     {
      if(OrderProfit()>0) lot=LT;
      if(OrderProfit()<0) lot=OrderLots()*KL;
     }
#endif

//---  MQL5
#ifdef __MQL5__
   if(HistorySelect(0,TimeCurrent()))
     {
      double profit=HistoryDealGetDouble(HistoryDealGetTicket(HistoryDealsTotal()-1),DEAL_PROFIT);
      double LastLot=HistoryDealGetDouble(HistoryDealGetTicket(HistoryDealsTotal()-1),DEAL_VOLUME);
      if(profit>0) lot=LT;
      if(profit<0) lot=LastLot*KL;
     }
#endif

   if(lot>ML)lot=LT;
   return(lot);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double price=0,sl=0,tp=0;

   double ASK=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double BID=SymbolInfoDouble(_Symbol,SYMBOL_BID);

   if(bars!=Bars(_Symbol,0))
     {
      if(b && OrdersTotal()<1)
        {
         price=NormalizeDouble(ASK,_Digits);
         sl=NormalizeDouble(BID-Stop*_Point,_Digits);
         tp=NormalizeDouble(BID+Take*_Point,_Digits);
         PutOrder(0,ASK,sl,tp);
         b=false;s=true;
        }

      if(s && OrdersTotal()<1)
        {
         price=NormalizeDouble(BID,_Digits);
         sl=NormalizeDouble(ASK+Stop*_Point,_Digits);
         tp=NormalizeDouble(ASK-Take*_Point,_Digits);
         PutOrder(1,BID,sl,tp);
         s=false;b=true;
        }
      bars=Bars(_Symbol,0);
     }
  }
//+------------------------------------------------------------------+
