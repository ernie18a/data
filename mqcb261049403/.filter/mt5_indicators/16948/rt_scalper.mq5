//+------------------------------------------------------------------+
//|                                                   RT_Scalper.mq5 |
//|                                   Copyright © 2016, prostotrader |
//|                                                  http://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, prostotrader"
#property link      "http://mql5.com"
#property version   "1.00"
#property description "RT Scalper"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot Deals
#property indicator_label1  "Deals" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1
//-- plot volumes
#property indicator_label2  "Volumes" 
#property indicator_type2   DRAW_LINE 
#property indicator_color2  clrMagenta
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  1
//--- plot orders
#property indicator_label3  "Orders" 
#property indicator_type3   DRAW_LINE 
#property indicator_color3  clrAqua
#property indicator_style3  STYLE_SOLID 
#property indicator_width3  1
//
input uint Deals=50; //Порог сделок
//--- indicator buffers
double BuffDeals[];
double BuffVolumes[];
double BuffOrders[];
double BuffSellVol[];
double BuffSellPos[];
double BuffBuyVol[];
double BuffBuyPos[];
//
int event_cnt;    //Переменная для вызова функции OnCalculate
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   event_cnt=0;
//---
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   IndicatorSetString(INDICATOR_SHORTNAME,"RT_Scalper");
//--- indicator buffers mapping
   SetIndexBuffer(0,BuffDeals,INDICATOR_DATA);
   SetIndexBuffer(1,BuffVolumes,INDICATOR_DATA);
   SetIndexBuffer(2,BuffOrders,INDICATOR_DATA);
   SetIndexBuffer(3,BuffSellVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BuffSellPos,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BuffBuyVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BuffBuyPos,INDICATOR_CALCULATIONS);
//---   
   ArraySetAsSeries(BuffDeals,true);
   ArraySetAsSeries(BuffVolumes,true);
   ArraySetAsSeries(BuffOrders,true);
   ArraySetAsSeries(BuffSellVol,true);
   ArraySetAsSeries(BuffSellPos,true);
   ArraySetAsSeries(BuffBuyVol,true);
   ArraySetAsSeries(BuffBuyPos,true);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
//---Set objects
   int window=ChartWindowFind(ChartID(),"RT_Scalper");
   ObjectCreate(ChartID(),"RT_Scalper_1",OBJ_LABEL,window,0,0);
   ObjectCreate(ChartID(),"RT_Scalper_2",OBJ_LABEL,window,0,0);
   ObjectCreate(ChartID(),"RT_Scalper_3",OBJ_LABEL,window,0,0);
   ObjectCreate(ChartID(),"RT_Scalper_4",OBJ_LABEL,window,0,0);
//---   
   ObjectSetInteger(ChartID(),"RT_Scalper_1",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(ChartID(),"RT_Scalper_2",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(ChartID(),"RT_Scalper_3",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(ChartID(),"RT_Scalper_4",OBJPROP_XDISTANCE,5);

   ObjectSetInteger(ChartID(),"RT_Scalper_1",OBJPROP_YDISTANCE,15);
   ObjectSetInteger(ChartID(),"RT_Scalper_2",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(ChartID(),"RT_Scalper_3",OBJPROP_YDISTANCE,45);
   ObjectSetInteger(ChartID(),"RT_Scalper_4",OBJPROP_YDISTANCE,60);

   ObjectSetInteger(ChartID(),"RT_Scalper_1",OBJPROP_COLOR,clrLightPink);
   ObjectSetInteger(ChartID(),"RT_Scalper_2",OBJPROP_COLOR,clrLightPink);
   ObjectSetInteger(ChartID(),"RT_Scalper_3",OBJPROP_COLOR,clrLightSkyBlue);
   ObjectSetInteger(ChartID(),"RT_Scalper_4",OBJPROP_COLOR,clrLightSkyBlue);

   ObjectSetString(ChartID(),"RT_Scalper_1",OBJPROP_TEXT,"Макс. объём Sell: 0");
   ObjectSetString(ChartID(),"RT_Scalper_2",OBJPROP_TEXT,"Поз. макс. объёма Sell: 0");
   ObjectSetString(ChartID(),"RT_Scalper_3",OBJPROP_TEXT,"Макс. объём Buy: 0");
   ObjectSetString(ChartID(),"RT_Scalper_4",OBJPROP_TEXT,"Поз. макс. объёма Buy: 0");
   ChartRedraw(ChartID());
//
   if(!MarketBookAdd(Symbol()))
     {
      Alert("Book not added!");
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
   MarketBookRelease(Symbol());
//---
   ObjectDelete(ChartID(),"RT_Scalper_1");
   ObjectDelete(ChartID(),"RT_Scalper_2");
   ObjectDelete(ChartID(),"RT_Scalper_3");
   ObjectDelete(ChartID(),"RT_Scalper_4");
//
   if(reason==REASON_INITFAILED)
     {
      int window=ChartWindowFind(ChartID(),"RT_Scalper");
      ChartIndicatorDelete(ChartID(),window,"RT_Scalper");
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
   if(symbol==Symbol())
     {
      double price[];
      OnCalculate(event_cnt,event_cnt,0,price);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator Get Book volumes                                |
//+------------------------------------------------------------------+
double GetBookVolumes(long &sell_v,long &sell_p,long &buy_v,long &buy_p)
  {
   long sell_vol= 0;
   long buy_vol = 0;
   MqlBookInfo book[];
   sell_v = 0;
   sell_p = 0;
   buy_v = 0;
   buy_p = 0;
   long last_sell=0;
   bool is_buy=false;
   if(MarketBookGet(Symbol(),book))//getBook )
     {
      int size=ArraySize(book);
      //---    
      if(size>0)
        {
         for(int i=0; i<size; i++)
           {
            if(book[i].type==BOOK_TYPE_SELL)
              {
               sell_vol+=book[i].volume;
               if(book[i].volume>=sell_v)
                 {
                  sell_v = book[i].volume;
                  sell_p = i;
                 }
              }
            else
            if(book[i].type==BOOK_TYPE_BUY)
              {
               if(!is_buy)
                 {
                  is_buy=true;
                  last_sell=i-1;
                 }
               buy_vol+=book[i].volume;
               if(book[i].volume>buy_v)
                 {
                  buy_v = book[i].volume;
                  buy_p = i;
                 }
              }
           }
         long summ=buy_vol+sell_vol;
         if(summ>0)
           {
            sell_p= last_sell-sell_p+1;
            buy_p = buy_p-last_sell;
            return(double(sell_vol-buy_vol)/double(summ) * 100); //Инвертировано для наглядности графика
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator Get all deals                                   |
//+------------------------------------------------------------------+
double GetDeals()
  {
   MqlTick ticks[];
   int buy_deal=0;
   int sell_deal=0;
   int result=CopyTicks(Symbol(),ticks,COPY_TICKS_TRADE,0,Deals);
   if(result>0)
     {
      for(int i=0; i<result; i++)
        {
         if((ticks[i].flags &TICK_FLAG_BUY)==TICK_FLAG_BUY) buy_deal++;
         if((ticks[i].flags &TICK_FLAG_SELL)==TICK_FLAG_SELL) sell_deal++;
        }
      long summ=buy_deal+sell_deal;
      if(summ>0)
        {
         return(double(buy_deal-sell_deal)/double(summ) * 100);
        }
     }
   return( 0 );
  }
//+------------------------------------------------------------------+
//| Custom indicator Get all orders                                   |
//+------------------------------------------------------------------+
double GetOrders()
  {
   double sell_vol= SymbolInfoDouble(Symbol(),SYMBOL_SESSION_SELL_ORDERS_VOLUME);
   double buy_vol = SymbolInfoDouble(Symbol(),SYMBOL_SESSION_BUY_ORDERS_VOLUME);
   double summ=sell_vol+buy_vol;
   if(long(summ)>0)
     {
      return((buy_vol - sell_vol)/summ * 100);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(prev_calculated==0)
     {
      ArrayInitialize(BuffDeals,0);
      ArrayInitialize(BuffVolumes,0);
      ArrayInitialize(BuffOrders,0);
      ArrayInitialize(BuffSellVol,0);
      ArrayInitialize(BuffSellPos,0);
      ArrayInitialize(BuffBuyVol,0);
      ArrayInitialize(BuffBuyPos,0);
     }
   else
     {
      int a_diff=rates_total-prev_calculated;
      if(a_diff>0)
        {
         for(int i=a_diff-1; i>0; i++)
           {
            BuffDeals[i]=BuffDeals[i+1];
            BuffVolumes[i]= BuffVolumes[i+1];
            BuffOrders[i] = BuffOrders[i+1];
            BuffSellVol[i] = BuffSellVol[i+1];
            BuffSellPos[i] = BuffSellPos[i+1];
            BuffBuyVol[i] = BuffBuyVol[i+1];
            BuffBuyPos[i] = BuffBuyPos[i+1];
           }
        }
     }
   long sell_vol;
   long sell_pos;
   long buy_vol;
   long buy_pos;
   BuffDeals[0]=GetDeals();
   BuffVolumes[0]= GetBookVolumes(sell_vol,sell_pos,buy_vol,buy_pos);
   BuffOrders[0] = GetOrders();
   BuffSellVol[0] = double(sell_vol);
   BuffSellPos[0] = double(sell_pos);
   BuffBuyVol[0] = double(buy_vol);
   BuffBuyPos[0] = double(buy_pos);
//---  
   ObjectSetString(ChartID(),"RT_Scalper_1",OBJPROP_TEXT,"Макс. объём Sell: "+string(sell_vol));
   ObjectSetString(ChartID(),"RT_Scalper_2",OBJPROP_TEXT,"Поз. макс. объёма Sell: "+string(sell_pos));
   ObjectSetString(ChartID(),"RT_Scalper_3",OBJPROP_TEXT,"Макс. объём Buy: "+string(buy_vol));
   ObjectSetString(ChartID(),"RT_Scalper_4",OBJPROP_TEXT,"Поз. макс. объёма Buy: "+string(buy_pos));
//---
   ChartRedraw(ChartID());
   event_cnt=rates_total;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
