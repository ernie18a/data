//+------------------------------------------------------------------+
//|                                            MetaNeural_VSA_SR.mq4 |
//|                                  Copyright © 2013, MetaNeural    |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, MetaNeural"
#property link      ""
#property strict
#property indicator_chart_window


extern int BarsBack = 100;

extern int DailyLookBack = 20;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int t=BarsBack;t>0;t--)
   {
   ObjectDelete("Red"+DoubleToStr(t,0));
   ObjectDelete("Green"+DoubleToStr(t,0));
   ObjectDelete("RedD"+DoubleToStr(t,0));
   ObjectDelete("GreenD"+DoubleToStr(t,0));   
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----

   if(NewBar())
   {
   deinit();
   }

   for(int i=BarsBack;i>0;i--)
   {
   
   if(Period() == PERIOD_H1)
   {
      if( ((Close[i] > Open[i] && Close[i] > (High[i]+Low[i])/2) ||  (Close[i] > (High[i]+Low[i])/2 && Close[i] == Open[i]))       
      && iVolume(Symbol(),Period(),i)>iVolume(Symbol(),Period(),i+1))
      { // up bar that shows buying strenght
      ObjectCreate("Green"+DoubleToStr(i,0),OBJ_HLINE,0,Time[i],Close[i]);
      ObjectSet("Green"+DoubleToStr(i,0),6,Chartreuse);     
      ObjectSet("Green"+DoubleToStr(i,0),7,STYLE_DASH);
         for(int k = BarsBack; k>i; k--)
         {
         if(ObjectGet("Red"+DoubleToStr(k,0),1) <= Close[i])
            ObjectDelete("Red"+DoubleToStr(k,0));      
         }
      }
   
      if( ((Close[i] < Open[i] && Close[i] > (High[i]+Low[i])/2) ||  (Close[i] < (High[i]+Low[i])/2 && Close[i] == Open[i]))       
      && iVolume(Symbol(),Period(),i)>iVolume(Symbol(),Period(),i+1))
      { // down bar that shows buying strenght
      ObjectCreate("Green"+DoubleToStr(i,0),OBJ_HLINE,0,Time[i],Close[i]);
      ObjectSet("Green"+DoubleToStr(i,0),6,Chartreuse);     
      ObjectSet("Green"+DoubleToStr(i,0),7,STYLE_DASH);
         for(int sktt = BarsBack; sktt>i; sktt--)
         {
         if(ObjectGet("Green"+DoubleToStr(sktt,0),1) >= Close[i])
            ObjectDelete("Green"+DoubleToStr(sktt,0));      
         }
      }
   
      if( ((Close[i] < Open[i] && Close[i] < (High[i]+Low[i])/2) ||  (Close[i] < (High[i]+Low[i])/2 && Close[i] == Open[i]))       
      && iVolume(Symbol(),Period(),i)>iVolume(Symbol(),Period(),i+1))
      { // down bar that shows selling strenght
      ObjectCreate("Red"+DoubleToStr(i,0),OBJ_HLINE,0,Time[i],Close[i]);
      ObjectSet("Red"+DoubleToStr(i,0),6,Red);   
      ObjectSet("Red"+DoubleToStr(i,0),7,STYLE_DASH);
         for(int ktt = BarsBack; ktt>i; ktt--)
         {
         if(ObjectGet("Green"+DoubleToStr(ktt,0),1) >= Close[i])
            ObjectDelete("Green"+DoubleToStr(ktt,0));      
         }  
      }
      
      if( ((Close[i] > Open[i] && Close[i] < (High[i]+Low[i])/2) ||  (Close[i] < (High[i]+Low[i])/2 && Close[i] == Open[i]))       
      && iVolume(Symbol(),Period(),i)>iVolume(Symbol(),Period(),i+1))
      { // up bar that shows selling strenght
      ObjectCreate("Red"+DoubleToStr(i,0),OBJ_HLINE,0,Time[i],Close[i]);
      ObjectSet("Red"+DoubleToStr(i,0),6,Red);     
      ObjectSet("Red"+DoubleToStr(i,0),7,STYLE_DASH);
         for(int kt = BarsBack; kt>i; kt--)
         {
         if(ObjectGet("Red"+DoubleToStr(kt,0),1) <= Close[i])
            ObjectDelete("Red"+DoubleToStr(kt,0));      
         }
      }
      
   }      
   if(Period() == PERIOD_D1 || Period() == PERIOD_H1)
   {
      //daily
      
      if( ((iClose(Symbol(),PERIOD_D1,i) > iOpen(Symbol(),PERIOD_D1,i) && iClose(Symbol(),PERIOD_D1,i) > (iHigh(Symbol(),PERIOD_D1,i)+iLow(Symbol(),PERIOD_D1,i))/2) ||  (iClose(Symbol(),PERIOD_D1,i) > (iHigh(Symbol(),PERIOD_D1,i)+iLow(Symbol(),PERIOD_D1,i))/2 && iClose(Symbol(),PERIOD_D1,i) == iOpen(Symbol(),PERIOD_D1,i)))       
      && iVolume(Symbol(),PERIOD_D1,i)>iVolume(Symbol(),PERIOD_D1,i+1))
      { // up bar that shows buying strenght
      ObjectCreate("GreenD"+DoubleToStr(i,0),OBJ_HLINE,0,iTime(Symbol(),PERIOD_D1,i),iClose(Symbol(),PERIOD_D1,i));
      ObjectSet("GreenD"+DoubleToStr(i,0),6,Chartreuse);     
      
         for(int k2 = BarsBack; k2>i; k2--)
         {
         if(ObjectGet("RedD"+DoubleToStr(k2,0),1) <= iClose(Symbol(),PERIOD_D1,i))
            if(k2>DailyLookBack)
            ObjectDelete("RedD"+DoubleToStr(k2,0));      
            else ObjectSet("RedD"+DoubleToStr(k2,0),7,STYLE_DOT);      
         }
      }
   
      if( ((iClose(Symbol(),PERIOD_D1,i) < iOpen(Symbol(),PERIOD_D1,i) && iClose(Symbol(),PERIOD_D1,i) > (iHigh(Symbol(),PERIOD_D1,i)+iLow(Symbol(),PERIOD_D1,i))/2) ||  (iClose(Symbol(),PERIOD_D1,i) < (iHigh(Symbol(),PERIOD_D1,i)+iLow(Symbol(),PERIOD_D1,i))/2 && iClose(Symbol(),PERIOD_D1,i) == iOpen(Symbol(),PERIOD_D1,i)))       
      && iVolume(Symbol(),PERIOD_D1,i)>iVolume(Symbol(),PERIOD_D1,i+1))
      { // down bar that shows buying strenght
      ObjectCreate("GreenD"+DoubleToStr(i,0),OBJ_HLINE,0,iTime(Symbol(),PERIOD_D1,i),iClose(Symbol(),PERIOD_D1,i));
      ObjectSet("GreenD"+DoubleToStr(i,0),6,Chartreuse);     
      
         for(int sktt2 = BarsBack; sktt2>i; sktt2--)
         {
         if(ObjectGet("GreenD"+DoubleToStr(sktt2,0),1) >= iClose(Symbol(),PERIOD_D1,i))
            if(sktt2 > DailyLookBack)
            ObjectDelete("GreenD"+DoubleToStr(sktt2,0));      
            else ObjectSet("GreenD"+DoubleToStr(sktt2,0),7,STYLE_DOT);      
         }
      }
   
      if( ((iClose(Symbol(),PERIOD_D1,i) < iOpen(Symbol(),PERIOD_D1,i) && iClose(Symbol(),PERIOD_D1,i) < (iHigh(Symbol(),PERIOD_D1,i)+iLow(Symbol(),PERIOD_D1,i))/2) ||  (iClose(Symbol(),PERIOD_D1,i) < (iHigh(Symbol(),PERIOD_D1,i)+iLow(Symbol(),PERIOD_D1,i))/2 && iClose(Symbol(),PERIOD_D1,i) == iOpen(Symbol(),PERIOD_D1,i)))       
      && iVolume(Symbol(),PERIOD_D1,i)>iVolume(Symbol(),PERIOD_D1,i+1))
      { // down bar that shows selling strenght
      ObjectCreate("RedD"+DoubleToStr(i,0),OBJ_HLINE,0,iTime(Symbol(),PERIOD_D1,i),iClose(Symbol(),PERIOD_D1,i));
      ObjectSet("RedD"+DoubleToStr(i,0),6,Red);   
      
         for(int ktt2 = BarsBack; ktt2>i; ktt2--)
         {
         if(ObjectGet("GreenD"+DoubleToStr(ktt2,0),1) >= iClose(Symbol(),PERIOD_D1,i))
            if(ktt2>DailyLookBack)
            ObjectDelete("GreenD"+DoubleToStr(ktt2,0));      
            else ObjectSet("GreenD"+DoubleToStr(ktt2,0),7,STYLE_DOT);      
         }  
      }
      
      if( ((iClose(Symbol(),PERIOD_D1,i) > iOpen(Symbol(),PERIOD_D1,i) && iClose(Symbol(),PERIOD_D1,i) < (iHigh(Symbol(),PERIOD_D1,i)+iLow(Symbol(),PERIOD_D1,i))/2) ||  (iClose(Symbol(),PERIOD_D1,i) < (iHigh(Symbol(),PERIOD_D1,i)+iLow(Symbol(),PERIOD_D1,i))/2 && iClose(Symbol(),PERIOD_D1,i) == iOpen(Symbol(),PERIOD_D1,i)))       
      && iVolume(Symbol(),PERIOD_D1,i)>iVolume(Symbol(),PERIOD_D1,i+1))
      { // up bar that shows selling strenght
      ObjectCreate("RedD"+DoubleToStr(i,0),OBJ_HLINE,0,iTime(Symbol(),PERIOD_D1,i),iClose(Symbol(),PERIOD_D1,i));
      ObjectSet("RedD"+DoubleToStr(i,0),6,Red);     
      
         for(int kt2 = BarsBack; kt2>i; kt2--)
         {
         if(ObjectGet("RedD"+DoubleToStr(kt2,0),1) <= iClose(Symbol(),PERIOD_D1,i))
            if(kt2>DailyLookBack)
            ObjectDelete("RedD"+DoubleToStr(kt2,0));      
            else ObjectSet("RedD"+DoubleToStr(kt2,0),7,STYLE_DOT);      
         }
      }
   }      
      
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

bool NewBar()
   {   
      static datetime lastbar = 0;
      datetime curbar = Time[0];   
         if(lastbar!=curbar)   
            {      
               lastbar=curbar;      
               return (true);   
                  }   
               else   
                     {      
                      return(false);   
                        }
               }