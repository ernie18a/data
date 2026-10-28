//+---------------------------------+
//|        BREW_MissingData_Sep.mq4 |
//+---------------------------------+
#property  copyright "Copyright © 2010, Brewmanz"
#property link      "https://www.metaquotes.net/"

//#property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 1
#property  indicator_color1  Red
#property  indicator_width1 3
//---- input parameters
extern int AlertIfMissingPeriodsOver=10;
extern int AlertLimit=10;
//---- display buffers
double V1Buff[];
int AlertsToGo;
//+-------------------------------------------+
//| Custom indicator initialization function  |
//+-------------------------------------------+
int init()
  {
   AlertsToGo=AlertLimit;
//Print("Init() starting");
   string short_name;
   IndicatorBuffers(1);
//---- indicator line
//SetIndexStyle( 0,DRAW_LINE);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,V1Buff);

//---- name for DataWindow and indicator subwindow label
   short_name="BREW MissingData("+AlertIfMissingPeriodsOver+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"100+MissingIntervals");
//----
   SetIndexDrawBegin(0,1);
//----
//Print("Init() ending");
   return(0);
  }
//+--------------------------------------+
int start()
  {
   int ix,ixMax;

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   ixMax=Bars-counted_bars;
   if(counted_bars==0) ixMax-=1+1;

   for(ix=ixMax; ix>=0; ix--)
     {
      //if(ix > ixMax - TrailingBarsLength)//check if enough history to work
      //   continue;
      datetime dThis = Time[ix];
      datetime dPrev = Time[ix+1];
      int periodStep = (dThis - dPrev)/(Period()*60);
      // wait! if over weekend, deduct 'markets closed' time (49 hours)
      if(TimeDayOfWeek(dThis)<TimeDayOfWeek(dPrev))
         periodStep-=(49*60)/Period();
      int periodMissed=periodStep-1;
      // is all okay?
      if(periodMissed<=0)
        {
         V1Buff[ix]=0;//EMPTY_VALUE;
         continue;
        }
      // oops. data is missing. could be weekend ...
      if(TimeDayOfWeek(dThis)<TimeDayOfWeek(dPrev))
        {
         if(periodMissed*Period()==49*60)
           {
            V1Buff[ix]=0;//EMPTY_VALUE;
            continue;
           }
        }

      Print(TimeToStr(dPrev),"-",TimeToStr(dThis)," Missing ",periodMissed," Periods of ",Period()," mins");
      if(periodMissed>AlertIfMissingPeriodsOver)
        {
         if(AlertsToGo>0)
           {
            AlertsToGo--;
            Alert(TimeToStr(dPrev),"-",TimeToStr(dThis)," Missing ",periodMissed," Periods of ",Period()," mins");
           }
        }
      V1Buff[ix]=100+periodMissed;
     }
//---- plot any calced values

//----
//Print("Start() ret");
   return(0);
  }
//+------------------------------------+
