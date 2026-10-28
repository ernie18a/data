//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
//+------------------------------------------------------------------+
//|                                       RSI adaptive EMA Alert.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "RSI adaptive EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrRed,clrBlue
#property indicator_width1  2
//--- input parameters
input double             inpPeriod = 32;          // RSI period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
input group             "Alerts"
input string               InpSoundName            = "alert.wav"; // Sound Name
input uchar                InpSoundRepetitions     = 3;           // Repetitions
input uchar                InpSoundPause           = 3;           // Pause, in seconds
input bool                 InpUseSound             = false;       // Use Sound
input bool                 InpUseAlert             = true;        // Use Alert
input bool                 InpUseMail              = true;        // Use Send mail
input bool                 InpUseNotification      = true;        // Use Send notification
//--- indicator buffers
double val[],valc[];
//--- alert
datetime m_last_sound      = 0;        // "0" -> D'1970.01.01 00:00';
uchar    m_repetitions     = 0;        //
string   m_text            = "";       //
datetime m_prev_bars       = 0;        // "0" -> D'1970.01.01 00:00';
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI adaptive EMA Alert ("+(string)inpPeriod+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total)
      return(prev_calculated);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      double _alpha = MathAbs(iRsi(_price,inpPeriod,i,rates_total)/100.0 - 0.5) * 2.0;
      val[i]  = (i>0) ? val[i-1]+_alpha*(_price-val[i-1]) : _price;
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
//--- alert
   if(time[rates_total-1]>m_prev_bars)
     {
      m_last_sound=0;
      m_prev_bars=time[rates_total-1];
      m_repetitions=0;
     }
   if(m_repetitions>=InpSoundRepetitions)
      return(rates_total);
   datetime time_current=TimeCurrent();
   if(time_current-m_last_sound>InpSoundPause)
     {
      int i=rates_total-1;
      if(valc[i-1]!=1.0 && valc[i]==1.0)
        {
         if(InpUseSound)
            PlaySound(InpSoundName);
         m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" RSI adaptive EMA, Trend UP, "+TimeToString(time[i]);
         if(InpUseAlert)
            Alert(m_text);
         m_last_sound=time_current;
         m_repetitions++;
         //---
         if(InpUseMail)
            SendMail(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1),m_text);
         if(InpUseNotification)
            SendNotification(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" "+m_text);
        }
      else
        {
         if(valc[i-1]!=2.0 && valc[i]==2.0)
           {
            if(InpUseSound)
               PlaySound(InpSoundName);
            m_text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" Three MAs, Trend DOWN, "+TimeToString(time[i]);
            if(InpUseAlert)
               Alert(m_text);
            m_last_sound=time_current;
            m_repetitions++;
            //---
            if(InpUseMail)
               SendMail(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1),m_text);
            if(InpUseNotification)
               SendNotification(Symbol()+","+StringSubstr(EnumToString(Period()),7,-1)+" "+m_text);
           }
        }
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _rsiInstances 1
#define _rsiInstancesSize 3
double workRsi[][_rsiInstances*_rsiInstancesSize];
#define _price  0
#define _change 1
#define _changa 2
//+------------------------------------------------------------------+
//| iRsi                                                             |
//+------------------------------------------------------------------+
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars)
      ArrayResize(workRsi,bars);
   int z=instanceNo*_rsiInstancesSize;
//---
   workRsi[r][z+_price]=price;
   double alpha=1.0/MathMax(period,1);
   if(r<period)
     {
      int k;
      double sum=0;
      for(k=0; k<period && (r-k-1)>=0; k++)
         sum+=MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
      workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
      workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
     }
   else
     {
      double change=workRsi[r][z+_price]-workRsi[r-1][z+_price];
      workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(change  - workRsi[r-1][z+_change]);
      workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
     }
   return(50.0*(workRsi[r][z+_change]/MathMax(workRsi[r][z+_changa],DBL_MIN)+1));
  }
//+------------------------------------------------------------------+
//| Get Price                                                        |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:
            return(close[i]);
         case PRICE_OPEN:
            return(open[i]);
         case PRICE_HIGH:
            return(high[i]);
         case PRICE_LOW:
            return(low[i]);
         case PRICE_MEDIAN:
            return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:
            return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:
            return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
