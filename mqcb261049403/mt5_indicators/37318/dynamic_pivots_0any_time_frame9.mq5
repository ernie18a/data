//------------------------------------------------------------------
#property copyright "© mladen, 2021"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   7
#property indicator_label1  "Pivot high 3"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_label2  "Pivot high 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_label3  "Pivot high 1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_label4  "Pivot"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDimGray
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Pivot low 1"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrCoral
#property indicator_label6  "Pivot low 2"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrCoral
#property indicator_label7  "Pivot low 3"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrCoral

//
//
//

input ENUM_TIMEFRAMES inpTimeFrame              = PERIOD_D1; // Time frame
input double          inpPivotLevel1            = 0.38;      // Pivot level 1
input double          inpPivotLevel2            = 0.61;      // Pivot level 2
input double          inpPivotLevel3            = 1.00;      // Pivot level 3
input bool            inpAlternativeCalculation = true;      // Use alternative calculation?

//
//
//

double ul3[],ul2[],ul1[],mid[],dl1[],dl2[],dl3[];
struct sGlobalStruct
{
   ENUM_TIMEFRAMES timeFrame;
   int             timeFrameSeconds;
   bool            timeFrameOK;
};
sGlobalStruct global;
#define _timeFrameToString(_tf) StringSubstr(EnumToString((ENUM_TIMEFRAMES)_tf),7)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   global.timeFrame        = MathMax(inpTimeFrame,_Period);
   global.timeFrameSeconds = PeriodSeconds(global.timeFrame);
   global.timeFrameOK      = (_Period<global.timeFrame);

      //
      //
      //
   
      SetIndexBuffer(0,ul3,INDICATOR_DATA);
      SetIndexBuffer(1,ul2,INDICATOR_DATA);
      SetIndexBuffer(2,ul1,INDICATOR_DATA);
      SetIndexBuffer(3,mid,INDICATOR_DATA);
      SetIndexBuffer(4,dl1,INDICATOR_DATA);
      SetIndexBuffer(5,dl2,INDICATOR_DATA);
      SetIndexBuffer(6,dl3,INDICATOR_DATA);
   
      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,_timeFrameToString(global.timeFrame)+" Dynamic pivots");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason){ }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (!global.timeFrameOK) return(0);
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   //
   //
   //
         struct sWorkStruct
            {
               double max;
               double min;
            };
         static sWorkStruct m_work[];
         static int         m_workSize = -1;
                        if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);            
   
   //
   //
   //
   
   for(int i=limit; i<rates_total && !_StopFlag; i++)
     {
         datetime _timeNow  =         iTimeAdjust(global.timeFrame,global.timeFrameSeconds,time[i]);
         datetime _timePrev = (i>0) ? iTimeAdjust(global.timeFrame,global.timeFrameSeconds,time[i-1]) : -1;
              if (_timeNow!=_timePrev)
                  {
                     m_work[i].max = high[i];
                     m_work[i].min = low[i];
                  }
              else            
                  {
                     m_work[i].max = m_work[i-1].max>high[i] ? m_work[i-1].max : high[i];
                     m_work[i].min = m_work[i-1].min<low[i]  ? m_work[i-1].min : low[i];
                  }

         //
         //
         //
      
            double range= m_work[i].max-m_work[i].min;
            
            //
            //
            //

            mid[i]=(m_work[i].max+m_work[i].min)/2.0;

            //
            //
            //
                        
            if(inpAlternativeCalculation)
               {
                  ul3[i] = (m_work[i].max+mid[i])/2.0;
                  dl3[i] = (m_work[i].min+mid[i])/2.0;
         
                  if (inpPivotLevel1>0) 
                        if (inpPivotLevel1>0.5) 
                           { 
                              dl1[i] = EMPTY_VALUE; 
                              ul1[i] = m_work[i].min+range*inpPivotLevel1; 
                           } 
                        else 
                           { 
                              ul1[i] = EMPTY_VALUE; 
                              dl1[i] = m_work[i].min+range*inpPivotLevel1; 
                           }
                  if (inpPivotLevel2>0) 
                        if (inpPivotLevel2>0.5) 
                           { 
                              dl2[i] = EMPTY_VALUE; 
                              ul2[i] = m_work[i].min+range*inpPivotLevel2; 
                           } 
                        else 
                           { 
                              ul1[i] = EMPTY_VALUE; 
                              dl2[i] = m_work[i].min+range*inpPivotLevel2; 
                           }
               }
            else
               {
                  if (inpPivotLevel1>0) { ul1[i] = mid[i]+range*inpPivotLevel1; dl1[i] = mid[i]-range*inpPivotLevel1; }
                  if (inpPivotLevel2>0) { ul2[i] = mid[i]+range*inpPivotLevel2; dl2[i] = mid[i]-range*inpPivotLevel2; }
                  if (inpPivotLevel3>0) { ul3[i] = mid[i]+range*inpPivotLevel3; dl3[i] = mid[i]-range*inpPivotLevel3; }
               }
     }
   return (rates_total);
}

//-------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------
//
//
//

datetime iTimeAdjust(ENUM_TIMEFRAMES _timeFrame, int _timeFrameSeconds, datetime _time)
{
   if (_timeFrame==PERIOD_W1)
         {
               MqlDateTime _adjustedTime; TimeToStruct(_time,_adjustedTime);
                           _adjustedTime.sec  = 0;
                           _adjustedTime.min  = 0;
                           _adjustedTime.hour = 0;
                           _time              = StructToTime(_adjustedTime);         
                    return(_time-_adjustedTime.day_of_week*86400);
         }                     
   if (_timeFrame==PERIOD_MN1)
         {
               MqlDateTime _adjustedTime; TimeToStruct(_time,_adjustedTime);
                           _adjustedTime.sec  = 0;
                           _adjustedTime.min  = 0;
                           _adjustedTime.hour = 0;
                           _adjustedTime.day  = 1;
                           _time              = StructToTime(_adjustedTime);         
                    return(_time);
         }                     
   return( int(_time/_timeFrameSeconds)*_timeFrameSeconds );
}