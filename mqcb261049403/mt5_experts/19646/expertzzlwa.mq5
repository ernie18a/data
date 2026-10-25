//+------------------------------------------------------------------+
//|                                                        MT45.mq45 |
//|                                              Copyright 2017, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2017, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"
#property strict
//******************************************************
// There is the library on this page https://www.mql5.com/ru/code/768
// It is need for correct testing by mode 1 minute OHLC
#include <IsNewBar.mqh>
//******************************************************
//--- override types of orders from MQL4 into MQL5
#ifdef __MQL5__
#define OrdersTotal  PositionsTotal
#define OP_BUY  ORDER_TYPE_BUY        
#define OP_SELL ORDER_TYPE_SELL       
#endif 
//*****************************************************
// Enumeration for choosing the mode of expert
enum MODE
  {
   original_mode=0,
   addition_test_mode=1,
   ma_test_mode=2,
  };
// and indicator
enum TERM
  {
   Short_term  = 0,
   Medium_term = 1,
   Long_term1  = 2,
   //Long_term2  = 3,
   //Long_term3  = 4,
  };
//*****************************************************
input int    Stop = 600;  // stoploss
input int    Take = 700;  // takeprofit
input int    Slip = 100;  // slip
input int    MN   = 123;  // magik
input double LT   = 0.01; // lot
input double KL   = 2;    // lot's increase
input double ML   = 10;   // maximal lot
                          //*************************************************
//These added variables are set mode of expert
input bool   Martin= false;
input TERM   Level = Long_term1;
input MODE   mode=original_mode;
//*************************************************
int bars=0;
bool b,s;

//*****************************************************
//Handle of indicators
int handle,handle1,handle2;
//*****************************************************
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//******************************************************
// There is intilazed our indicators 
#ifdef __MQL5__
   if(mode==addition_test_mode)
      handle=iCustom(_Symbol,_Period,"Market\\ZigZagLW Addition.ex5",Level);

   if(mode==ma_test_mode)
     {
      handle1=iMA(NULL,0,150,0,MODE_SMMA,PRICE_CLOSE);
      handle2=iMA(NULL,0,10,0,MODE_SMA,PRICE_CLOSE);
     }
#endif  
// Intelaze variables for correct working
   if(mode==original_mode)
     {
      b=true; s=true;
     }
   if(mode==addition_test_mode)
     {
      b=false; s=false;
     }

//******************************************************      
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
//| Opening of orders                                                |
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
//--- declaration and initialazation of request and result
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- parameters of request
   request.action   =TRADE_ACTION_DEAL;                     // type of trade action
   request.symbol   =Symbol();                              // symbol
   request.volume   =Lot();                                 // volume
   request.type     =type;                                  // opders type
   request.price    =price;                                 // open price
   request.sl       =sl;                                    // StopLoss price
   request.tp       =tp;                                    // TakeProfit price
   request.deviation=Slip;                                  // slip
   request.magic    =MN;                                    // MagicNumber
//--- request sending
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());     // output error message
//--- information of operation
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
//**************************************************
//If Martin is true then lot always is minimal   
   if(!Martin) lot=LT;
//**************************************************
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


//*****************************************      
//---- declaration of static variables
   static CIsNewBar NB1;
//+----------------------------------------------+
//| Determination of signals for deals           |
//+----------------------------------------------+
// checking is new bar here
   if(NB1.IsNewBar(Symbol(),PERIOD_CURRENT) && (mode==addition_test_mode || mode==ma_test_mode))
     {

#ifdef __MQL5__
      if(mode==addition_test_mode)
        {
         //copy last values 
         double buy[1];
         double sell[1];
         CopyBuffer(handle,0,1,1,buy);
         CopyBuffer(handle,1,1,1,sell);
         // forming signals
         if(!CompareDoubles(buy[0],0.0))
           {b=true; s=false;}
         if(!CompareDoubles(sell[0],0.0))
           {s=true; b=false;}
        }
      if(mode==ma_test_mode)
        {
         double shor[2];
         double lon[2];
         CopyBuffer(handle1,0,1,2,shor);
         CopyBuffer(handle2,0,1,2,lon);
         if(shor[1]>lon[1] && shor[0]<lon[0])
           {s=true; b=false;}
         if(shor[1]<lon[1] && shor[0]>lon[0])
           {b=true; s=false;}

        }
#endif

      //trading block      

      if(b)//&& OrdersTotal()<1)
        {
         price=NormalizeDouble(ASK,_Digits);
         sl=NormalizeDouble(BID-Stop*_Point,_Digits);
         tp=NormalizeDouble(BID+Take*_Point,_Digits);
         PutOrder(0,ASK,sl,tp);

         //if(mode==original_mode)
         s=false; b=false;
        }

      if(s)//&& OrdersTotal()<1)
        {
         price=NormalizeDouble(BID,_Digits);
         sl=NormalizeDouble(ASK+Stop*_Point,_Digits);
         tp=NormalizeDouble(ASK-Take*_Point,_Digits);
         PutOrder(1,BID,sl,tp);

         //if(mode==original_mode)
         b=false; s=false;
        }
      //if(mode==addition_test_mode){
      //s=false; b=false;
      //}
        } else{
      //******************************
      // Original trading block of original mode
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

      //******************************
      //Close brakit added block
     }
//*****************************   
  }
//****************************************************************************
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| right comparison of 2 doubles                                    |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,8)==0) return(true);
   else return(false);
  }
//***************************************************************************
