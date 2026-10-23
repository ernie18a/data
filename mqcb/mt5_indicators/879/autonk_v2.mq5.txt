//+------------------------------------------------------------------+
//|                                                      Auto_NK.mq5 |
//|                                        Copyright 2012.Karlson    |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "2012.Karlson"
#property description "Auto_NK, Karlson."
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
input string name="111";       // Name
input int width=1;             // Width
input int style=1;             // Style
input bool ray=true;           // Rays
int KF,pips;
datetime tim[];double low[];
//+------------------------------------------------------------------+
//| MI initialization function                                       |
//+------------------------------------------------------------------+
void OnInit()
  {
   if(_Digits==5 || _Digits==3) {KF=10;} else {KF=1;}
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);

   if(_Period>PERIOD_H12) {pips=150;}
   if(_Period>PERIOD_M30 && _Period<=PERIOD_H12) {pips=70;}
   if(_Period>PERIOD_M5 && _Period<=PERIOD_M30)  {pips=30;}
   if(_Period<=PERIOD_M5) {pips=20;}

   if(CopyLow(_Symbol,_Period,0,50,low)<50) {Print("Data Error");return;}
   if(CopyTime(_Symbol,_Period,0,50,tim)<50) {Print("Data Error");return;}

   if(ObjectFind(0,name)!=0)
     {
      Line(name,name,tim[0],low[0],TimeCurrent(),bid+pips*2.0*KF*_Point,clrBlack,width,style,ray);
      Line("",name+"_up",tim[0],low[0]+pips*2.0*KF*_Point,TimeCurrent(),bid+pips*4.0*KF*_Point,clrCrimson,width,style,ray);
      Line("",name+"_mid",tim[0],low[0]+pips*1.0*KF*_Point,TimeCurrent(),bid+pips*3.0*KF*_Point,clrSilver,width,style,ray);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   datetime time1=(int)ObjectGetInteger(0,name,OBJPROP_TIME,0);
   datetime time2=(int)ObjectGetInteger(0,name,OBJPROP_TIME,1);
   double price1=ObjectGetDouble(0,name,OBJPROP_PRICE,0);
   double price2=ObjectGetDouble(0,name,OBJPROP_PRICE,1);
   double nk_up_price=ObjectGetDouble(0,name+"_up",OBJPROP_PRICE,0);

   if(price2>price1 && time2>time1)
     {
      Line("",name+"_up",time1,nk_up_price,time2,price2+MathAbs(nk_up_price-price1),clrCrimson,width,style,ray);
      Line("",name+"_mid",time1,price1+MathAbs(nk_up_price-price1)/2.0,time2,price2+MathAbs(nk_up_price-price1)/2.0,clrSilver,width,style,ray);
     }

   if(price2<price1 && time2>time1)
     {
      Line("",name+"_up",time1,nk_up_price,time2,price2-MathAbs(nk_up_price-price1),clrCrimson,width,style,ray);
      Line("",name+"_mid",time1,price1-MathAbs(nk_up_price-price1)/2.0,time2,price2-MathAbs(nk_up_price-price1)/2.0,clrSilver,width,style,ray);
     }

   ChartRedraw(0);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Line                                                             |
//+------------------------------------------------------------------+
void Line(string nnn,string namez,datetime tt1,double pp1,datetime tt2,double pp2,color col,int wid,int sty,bool rays)
  {
   ObjectCreate(0,namez,OBJ_TREND,0,tt1,pp1,tt2,pp2);
   ObjectSetInteger(0,namez,OBJPROP_COLOR,col);
   ObjectSetInteger(0,namez,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,namez,OBJPROP_WIDTH,wid);
   ObjectSetInteger(0,namez,OBJPROP_STYLE,sty);
   ObjectSetInteger(0,namez,OBJPROP_RAY_RIGHT,rays);
   ObjectSetString(0,namez,OBJPROP_TEXT,nnn);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason==REASON_REMOVE)
     {
      if(ObjectFind(0,name+"_mid")==0) { ObjectDelete(0,name+"_mid");}
      if(ObjectFind(0,name+"_up")==0) { ObjectDelete(0,name+"_up");}
      if(ObjectFind(0,name)==0) { ObjectDelete(0,name);}
     }
  }
//+------------------------------------------------------------------+
