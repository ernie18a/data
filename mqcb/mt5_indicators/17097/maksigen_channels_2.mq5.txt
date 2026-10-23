//+----------------------------------------------------------------------------+
//|                                                     MaksiGen_Channels.mq5  |
//|                                                Copyright © 2006, MaksiGen  |
//+----------------------------------------------------------------------------+
#property copyright "© 2006, MaksiGen"
#property copyright "© 2016, MetaQuotes Software Corp."
#property link      ""
#property version   "1.00"
#property description ""
#property indicator_chart_window 
#property indicator_buffers 10
#property indicator_plots   6
#property indicator_label1  "Area 2"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "Area1"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrGainsboro
#property indicator_label3  "Upper 2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
#property indicator_label4  "Upper 1"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLimeGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  5
#property indicator_label5  "Lower 1"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  5
#property indicator_label6  "Lower 2"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrOrange
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2

//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Hour //Type of constant
  {
   H00=0,    //00
   H01,      //01
   H02,      //02
   H03,      //03
   H04,      //04
   H05,      //05
   H06,      //06
   H07,      //07
   H08,      //08
   H09,      //09
   H10,      //10
   H11,      //11
   H12,      //12
   H13,      //13
   H14,      //14
   H15,      //15
   H16,      //16
   H17,      //17
   H18,      //18
   H19,      //19
   H20,      //20
   H21,      //21
   H22,      //22
   H23,      //23
  };
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Min //Type of constant
  {
   M00=0,    //00
   M01,      //01
   M02,      //02
   M03,      //03
   M04,      //04
   M05,      //05
   M06,      //06
   M07,      //07
   M08,      //08
   M09,      //09
   M10,      //10
   M11,      //11
   M12,      //12
   M13,      //13
   M14,      //14
   M15,      //15
   M16,      //16
   M17,      //17
   M18,      //18
   M19,      //19
   M20,      //20
   M21,      //21
   M22,      //22
   M23,      //23
   M24,      //24
   M25,      //25
   M26,      //26
   M27,      //27
   M28,      //28
   M29,      //29
   M30,      //30
   M31,      //31
   M32,      //32
   M33,      //33
   M34,      //34
   M35,      //35
   M36,      //36
   M37,      //37
   M38,      //38
   M39,      //39
   M40,      //40
   M41,      //41
   M42,      //42
   M43,      //43
   M44,      //44
   M45,      //45
   M46,      //46
   M47,      //47
   M48,      //48
   M49,      //49
   M50,      //50
   M51,      //51
   M52,      //52
   M53,      //53
   M54,      //54
   M55,      //55
   M56,      //56
   M57,      //57
   M58,      //58
   M59       //59
  };
input Hour   StartHour1=H00;         // Session start hour for the channel width
input Min    StartMinute1=M00;       // Minute start hour for the channel width
input Hour   EndHour1=H08;           // Session end hour for the channel width
input Min    EndMinute1=M15;         // Session end minute for the channel width
//---
input Hour   StartHour2=H08;         // Session 1 start hour
input Min    StartMinute2=M15;       // Session 1 start minute
input Hour   EndHour2=H12;           // Session 1 end hour
input Min    EndMinute2=M30;         // Session 1 end minute
//---
input Hour   StartHour3=H14;         // Session 2 start hour
input Min    StartMinute3=M00;       // Session 2 start minute
input Hour   EndHour3=H17;           // Session 2 end hour
input Min    EndMinute3=M30;         // Session 2 end minute
//--- 
input uint   Dispersion=100;         // Spread of the second channel width in points
input int    Shift=0;                // Horizontal shift of the indicator in bars

double Up2Buffer[],Up1Buffer[],Dn1Buffer[],Dn2Buffer[],maxValues[],minValues[],fillu2[],fillu1[],filld1[],filld2[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

void OnInit()
{
   SetIndexBuffer(0,fillu2   ,INDICATOR_DATA);
   SetIndexBuffer(1,filld2   ,INDICATOR_DATA);
   SetIndexBuffer(2,fillu1   ,INDICATOR_DATA);
   SetIndexBuffer(3,filld1   ,INDICATOR_DATA);
   SetIndexBuffer(4,Up2Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,Up1Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,Dn1Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,Dn2Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,maxValues,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,minValues,INDICATOR_CALCULATIONS);
      for (int i=0; i<6; i++) PlotIndexSetInteger(i,PLOT_SHIFT,Shift);
   IndicatorSetString(INDICATOR_SHORTNAME,"MaksiGen_Channels");
}

//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double& high[],
                const double& low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static bool warned=false;
      if(_Period>PERIOD_H1) { Comment("Indicator MaksiGen_Channels requires timeframe below H2!"); warned=true; return(0); }
      if (warned)           { Comment(""); warned=false; }
      if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
   //
   //
   //
   //
   //

   double dDispersion=Dispersion*_Point;
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      Up1Buffer[i] = Dn1Buffer[i] = Up2Buffer[i] = Dn2Buffer[i] = EMPTY_VALUE;
         maxValues[i] = (i>0) ? maxValues[i-1] : high[i];
         minValues[i] = (i>0) ? minValues[i-1] : low[i];
         if (i>0)
         if (checkTimeLimits(StartHour1,StartMinute1,EndHour1,EndMinute1,time[i]))
            if (checkTimeLimits(StartHour1,StartMinute1,EndHour1,EndMinute1,time[i-1]))
            {
               maxValues[i] = MathMax(maxValues[i-1],high[i]);
               minValues[i] = MathMin(minValues[i-1],low[i]);
            }
            else
            {
               maxValues[i] = high[i];
               minValues[i] = low[i];
            }                                 
         if (checkTimeLimits(StartHour2,StartMinute2,EndHour2,EndMinute2,time[i])) { Up1Buffer[i] = maxValues[i]; Dn1Buffer[i] = minValues[i]; Up2Buffer[i]=Up1Buffer[i]+dDispersion; Dn2Buffer[i]=Dn1Buffer[i]-dDispersion; }
         if (checkTimeLimits(StartHour3,StartMinute3,EndHour3,EndMinute3,time[i])) { Up1Buffer[i] = maxValues[i]; Dn1Buffer[i] = minValues[i]; Up2Buffer[i]=Up1Buffer[i]+dDispersion; Dn2Buffer[i]=Dn1Buffer[i]-dDispersion; }
               fillu1[i] = Up1Buffer[i];
               fillu2[i] = Up2Buffer[i];
               filld1[i] = Dn1Buffer[i];
               filld2[i] = Dn2Buffer[i];
   }
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

bool checkTimeLimits(uint startHour, uint endHour, datetime timeToCheck) { return(checkTimeLimits(startHour,0,0,endHour,0,0,timeToCheck)); }
bool checkTimeLimits(uint startHour, uint startMinute, uint endHour, uint endMinute, datetime timeToCheck) { return(checkTimeLimits(startHour,startMinute,0,endHour,endMinute,0,timeToCheck)); }
bool checkTimeLimits(uint startHour, uint startMinute, uint startSecond, uint endHour, uint endMinute, uint endSecond, datetime timeToCheck)
{
   bool answer = false;
   MqlDateTime tempTime; TimeToStruct(timeToCheck,tempTime);
      datetime startTime,endTime,checkTime;
               startTime = _ctMinMax(startHour,0,24)    *3600+_ctMinMax(startMinute,0,60) *60+_ctMinMax(startSecond,0,60);
               endTime   = _ctMinMax(endHour,0,24)      *3600+_ctMinMax(endMinute,0,60)   *60+_ctMinMax(endSecond,0,60);
               checkTime = _ctMinMax(tempTime.hour,0,24)*3600+_ctMinMax(tempTime.min,0,60)*60+_ctMinMax(tempTime.sec,0,60);
               
   if (startTime>endTime)
          answer = (checkTime>=startTime || checkTime<endTime);
   else   answer = (checkTime>=startTime && checkTime<endTime);
   return(answer);
}
uint _ctMinMax(uint value, uint min, uint max) { return((uint)MathMax(MathMin(value,max),min)); }