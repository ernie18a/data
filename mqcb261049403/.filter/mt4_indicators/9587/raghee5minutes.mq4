//+------------------------------------------------------------------+
//|                                               Raghee5minutes.mq4 |
//|                            Copyright © 2009, Roman Robidet Burel |
//|    IF you find this Indicator/Code usefull and you want          |
//|                    donate something                              |
//|         YOU ARE WELCOME  PayPal : roman.robidet@hotmail.com      |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Roman Robidet Burel"
#property link      "none"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Chartreuse
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Maroon

double ema13[];
double ema21[];
double ema34[];
double ema55[];
double XScale;
double Angle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexStyle(1,DRAW_LINE,0,2);
   SetIndexStyle(2,DRAW_LINE,0,2);
   SetIndexStyle(3,DRAW_LINE,0,2);

//---- indicator buffers mapping
   SetIndexBuffer(0,ema13);
   SetIndexBuffer(1,ema21);
   SetIndexBuffer(2,ema34);
   SetIndexBuffer(3,ema55);

//  SetIndexEmptyValue(0,0.0);
//  SetIndexEmptyValue(1,0.0);
//  SetIndexEmptyValue(2,0.0);

//---- indicator short name
   IndicatorShortName("Raghe Fast Trade 5 minutes");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(Period()>5) return(0);

   XScale=MarketInfo(Symbol(),MODE_TICKVALUE)*MarketInfo(Symbol(),MODE_TICKSIZE)*10;
   if(XScale==0) return(0);

   double RV13=iMA(Symbol(),60,34,0,MODE_EMA,PRICE_CLOSE,13);
   double RV2=iMA(Symbol(),60,34,0,MODE_EMA,PRICE_CLOSE,0);
   Angle=MathArctan((RV2-RV13)/(XScale*13))/3.1415965*180;
//----
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

//-- main loop
   for(int i=0; i<limit; i++)
     {
      if(Angle>30) {   ema34[i]=iMA(Symbol(),0,34,0,MODE_EMA,PRICE_LOW,i);SetIndexLabel(2,"EMA34L");}
      else if(Angle<-30) {   ema34[i]=iMA(Symbol(),0,34,0,MODE_EMA,PRICE_HIGH,i);SetIndexLabel(2,"EMA34H");}
      else { ema13[i]=0;ema21[i]=0;ema55[i]=0;break;}

      ema13[i]=iMA(Symbol(),0,13,0,MODE_EMA,PRICE_CLOSE,i);
      SetIndexLabel(0,"EMA13C");
      ema21[i]=iMA(Symbol(),0,21,0,MODE_EMA,PRICE_CLOSE,i);
      SetIndexLabel(1,"EMA21C");
      ema55[i]=iMA(Symbol(),0,55,0,MODE_EMA,PRICE_CLOSE,i);
      SetIndexLabel(3,"EMA55C");
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
