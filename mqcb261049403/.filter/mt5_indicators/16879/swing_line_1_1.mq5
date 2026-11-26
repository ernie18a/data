//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Swing line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrLimeGreen,clrPaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//
//
//
//
//

input ENUM_TIMEFRAMES  TimeFrame       = PERIOD_CURRENT; // Time frame
input bool             AlertsOn        = false;          // Turn alerts on?
input bool             AlertsOnCurrent = true;           // Alert on current bar?
input bool             AlertsMessage   = true;           // Display messages on alerts?
input bool             AlertsSound     = false;          // Play sound on alerts?
input bool             AlertsEmail     = false;          // Send email on alerts?
input bool             AlertsNotify    = false;          // Send push notification on alerts?
input bool             Interpolate     = true;           // Interpolate in multi time frame mode?

double swli[],swlic[],count[];
ENUM_TIMEFRAMES _indicatorTimeFrame;
int _mtfHandle =INVALID_HANDLE;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,swli ,INDICATOR_DATA); 
   SetIndexBuffer(1,swlic,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(2,count,INDICATOR_CALCULATIONS); 
      _indicatorTimeFrame = MathMax(_Period,TimeFrame);
      if (_indicatorTimeFrame!=_Period)
      {
         _mtfHandle = iCustom(_Symbol,_indicatorTimeFrame,getName(),PERIOD_CURRENT,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotify);
         if (_mtfHandle==INVALID_HANDLE) return(INIT_FAILED);
      }         
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//


double  work[][5];
#define hHi   0
#define hLo   1
#define lHi   2
#define lLo   3
#define trend 4


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
         if(_indicatorTimeFrame!=_Period)
         {
            double result[1]; if (CopyBuffer(_mtfHandle,2,0,1,result)<1) 
            { 
               for (int i=prev_calculated; i<rates_total; i++)
               {
                  Comment(StringSubstr(EnumToString((ENUM_TIMEFRAMES)_indicatorTimeFrame),7)+" data not ready\nnext attempt will be made on new tick");
               }
               return(prev_calculated); 
            }
            else if (StringFind(ChartGetString(0,CHART_COMMENT),"data not ready")>=0) Comment("");

            //
            //---
            //
      
            #define _mtfRatio (double)PeriodSeconds((ENUM_TIMEFRAMES)_indicatorTimeFrame)/PeriodSeconds(_Period)
            int  n,k,i=MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-int(result[0]*_mtfRatio)-1,0)),_prevMark=-99; datetime _prevTime;
            for(; i<rates_total && !_StopFlag; i++)
            {
               int _currMark = iBarShift(_Symbol,_indicatorTimeFrame,time[i]); if (_currMark<0) continue;
               if (_currMark!=_prevMark)
               {
                  _prevMark =_currMark;
                  _prevTime = time[i];
                  #define _mtfCopy(_buff,_buffNo) { if(CopyBuffer(_mtfHandle,_buffNo,_currMark,1,result)<1) break; _buff[i]=result[0]; }
                          _mtfCopy(swli ,0);
                          _mtfCopy(swlic,1);
               }
               else 
               {
                  #define _mtfCopyValue(_buff) _buff[i] = _buff[i-1]; 
                          _mtfCopyValue(swli);
                          _mtfCopyValue(swlic);
               }                  
               
               //
               //---
               //

               if(!Interpolate) continue;
                  int _nextMark = (i<rates_total-1) ? iBarShift(_Symbol,_indicatorTimeFrame,time[i+1]) : _prevMark+1; if(_nextMark==_prevMark) continue;               
                  for (n=1; (i-n)> 0 && time[i-n] >= _prevTime; n++) continue;
                  for (k=1; (i-k)>=0 && k<n; k++)
                  {
                     #define _mtfInterpolate(_buff) _buff[i-k]=_buff[i]+(_buff[i-n]-_buff[i])*k/n
                             _mtfInterpolate(swli);
                  }               
            }
            return(rates_total);
         }

   //
   //
   //
   //
   //

   if (ArrayRange(work,0)!=rates_total) ArrayResize(work,rates_total);
      for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
      {
         work[i][trend] = (i>0) ? work[i-1][trend] : -1;
         work[i][hHi]   = (i>0) ? work[i-1][hHi] : high[i];  work[i][hLo] = (i>0) ? work[i-1][hLo] : low[i]; 
         work[i][lHi]   = (i>0) ? work[i-1][lHi] : high[i];  work[i][lLo] = (i>0) ? work[i-1][lLo] : low[i]; 
         if (i>0 && work[i-1][trend] == 1)
         {
            work[i][hHi] = MathMax(work[i-1][hHi],high[i]);
            work[i][hLo] = MathMax(work[i-1][hLo],low[i]);
            if (high[i]<work[i][hLo]) { work[i][trend] = -1; work[i][lHi] = high[i]; work[i][lLo] = low[i]; }
         }
         if (i>0 && work[i-1][trend] == -1)
         {
            work[i][lHi] = MathMin(work[i-1][lHi],high[i]);
            work[i][lLo] = MathMin(work[i-1][lLo],low[i]);
            if (low[i]>work[i][lHi]) { work[i][trend] =  1; work[i][hHi] = high[i]; work[i][hLo] = low[i]; }
         }
         swli[i]  = (work[i][trend]==1) ? work[i][hLo] : (work[i][trend]==-1) ? work[i][lHi] : close[i];
         swlic[i] = (work[i][trend]==1) ? 1 : (work[i][trend]==-1) ? 2 : 0;
   }
   count[rates_total-1]=MathMax(rates_total-prev_calculated+1,1);
   manageAlerts(time,swlic,rates_total);
   return(rates_total);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void manageAlerts(const datetime& time[], double& ttrend[], int bars)
{
   if (!AlertsOn) return;
      int whichBar = bars-1; if (!AlertsOnCurrent) whichBar = bars-2; datetime time1 = time[whichBar];
      if (ttrend[whichBar] != ttrend[whichBar-1])
      {
         if (ttrend[whichBar] == 1) doAlert(time1,"up");
         if (ttrend[whichBar] == 2) doAlert(time1,"down");
      }         
}   

//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      #define timeFrameToString(_tf) StringSubstr(EnumToString((ENUM_TIMEFRAMES)_tf),7)
      message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" swing line state changed to "+doWhat;
         if (AlertsMessage) Alert(message);
         if (AlertsEmail)   SendMail(_Symbol+" swing line",message);
         if (AlertsNotify)  SendNotification(message);
         if (AlertsSound)   PlaySound("alert2.wav");
   }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string getName()
{
   string _path=MQL5InfoString(MQL5_PROGRAM_PATH); StringToLower(_path);
   string _partsA[];
   int    _partsN = StringSplit(_path,StringGetCharacter("\\",0),_partsA);
   string name=_partsA[_partsN-1]; for(int n=_partsN-2; n>=0 && _partsA[n]!="indicators"; n--) name=_partsA[n]+"\\"+name;
   return(name);
}
