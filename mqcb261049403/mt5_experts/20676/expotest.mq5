//+------------------------------------------------------------------+
//|                                                     Expotest.mq5 |
//|                                               Yuriy Tokman (YTG) |
//|                                                http://ytg.com.ua |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "http://ytg.com.ua"
#property version   "1.00"

ENUM_ORDER_TYPE_FILLING fill = ORDER_FILLING_IOC;

input ENUM_TIMEFRAMES TimeFrames = PERIOD_CURRENT;
input int SL        = 150;
input int TP        = 200;
input double Volume = 0;
input double Risk   = 0.13;
input int MAGIC     = 7505;
input int Slippage  = 30;

input double step = 0.02;
input double maximum = 0.2;

int h_sar  = INVALID_HANDLE;  
double b_SAR[]; 
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int i;ulong tic =0; double volums = 0, profits = 0;
   HistorySelect(0,TimeCurrent());    
   int count = 0;
   for(i=0;i<HistoryDealsTotal();i++){
     count++;
     tic = HistoryDealGetTicket(i);
     volums = HistoryDealGetDouble(tic,DEAL_VOLUME);
     profits = HistoryDealGetDouble(tic,DEAL_PROFIT);
   }     

   double Lots = GetLot();
   if(profits<0)Lots = volums*2;
//---
   bool buy = false, sell = false;
   
   for(int cnt=0;cnt<=PositionsTotal();cnt++){
    if(PositionGetSymbol(cnt)==Symbol()){
	  if(PositionGetInteger(POSITION_MAGIC)==MAGIC){      
   if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)buy  = true;
   if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)sell = true;                  
    }}}
//---
    if(!buy && !sell){ 
    if(GetSig()>0)OnBUY(Lots,SL,TP);
    if(GetSig()<0)OnSELL(Lots,SL,TP);}    
//---    
  }
//+------------------------------------------------------------------+
int GetSig(){ int sig=0;
   //----
   if(h_sar==INVALID_HANDLE){
     h_sar=iSAR(_Symbol,TimeFrames,step, maximum);return(0);}
   else{
    if(CopyBuffer(h_sar,0,0,2,b_SAR)<2)     return(0);
    if(!ArraySetAsSeries(b_SAR,true))return(0);}
   //----
   double Ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   //----   
   if (b_SAR[0] <= Ask)sig=+1;
   if (b_SAR[0] >= Ask)sig=-1;
   //----
   return(sig);
  }
//----
//-----+
double GetLot()
 {
   double price=0.0;
   double margin=0.0;
   double MaximumRisk = Risk/100;

   if(!SymbolInfoDouble(_Symbol,SYMBOL_ASK,price))               return(0.0);
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,1.0,price,margin)) return(0.0);
   if(margin<=0.0)                                               return(0.0);

   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   
   double lot=NormalizeDouble(AccountInfoDouble(ACCOUNT_FREEMARGIN)*MaximumRisk/margin,2);

   if(Volume>0)lot=Volume;   
   if(lot<min_volume)lot=min_volume;
   if(lot>max_volume)lot=max_volume;    
   return(lot); 
 }
//----
//+------------------------------------------------------------------+
//| Открытие позиции Buy                                             |
//+------------------------------------------------------------------+
void OnBUY(double ll,double sl,double tp)
  {
//--- объявление и инициализация запроса и результата
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- параметры запроса
   request.action   =TRADE_ACTION_DEAL;                     // тип торговой операции
   request.symbol   =Symbol();                              // символ
   request.volume   =ll;                                   // объем в 0.1 лот
   request.type     =ORDER_TYPE_BUY;                        // тип ордера
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // цена для открытия
   request.sl= SymbolInfoDouble(Symbol(),SYMBOL_ASK) - sl*Point();  
   request.tp= SymbolInfoDouble(Symbol(),SYMBOL_ASK) + tp*Point();
   request.deviation=Slippage;                                     // допустимое отклонение от цены
   request.magic    =MAGIC;                          // MagicNumber ордера
   request.type_filling = fill;
//--- отправка запроса
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());     // если отправить запрос не удалось, вывести код ошибки
//--- информация об операции
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
  }
//+------------------------------------------------------------------+
//| Открытие позиции Sell                                            |
//+------------------------------------------------------------------+
void OnSELL(double ll,double sl,double tp)
  {
//--- объявление и инициализация запроса и результата
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- параметры запроса
   request.action   =TRADE_ACTION_DEAL;                     // тип торговой операции
   request.symbol   =Symbol();                              // символ
   request.volume   =ll;                                   // объем в 0.2 лот
   request.type     =ORDER_TYPE_SELL;                       // тип ордера
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // цена для открытия
   request.sl= SymbolInfoDouble(Symbol(),SYMBOL_BID) + sl*Point();  
   request.tp= SymbolInfoDouble(Symbol(),SYMBOL_BID) - tp*Point();
   request.deviation=Slippage;                                     // допустимое отклонение от цены
   request.magic    =MAGIC;                          // MagicNumber ордера
   request.type_filling = fill;
//--- отправка запроса
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());     // если отправить запрос не удалось, вывести код ошибки
//--- информация об операции
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
  }
//+------------------------------------------------------------------+