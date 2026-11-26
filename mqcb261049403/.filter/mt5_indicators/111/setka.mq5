//+------------------------------------------------------------------+
//|                                                        Setka.mq5 |
//|                                          Copyright Privalov S.V. |
//|                             https://www.mql5.com/ru/users/prival |
//+------------------------------------------------------------------+
#property copyright "Privalov S.V."
#property link      "https://www.mql5.com/en/users/prival"
#property version   "3.08"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- input parameters
input int Step=250;              // vertical grid step in points
input int Figure=1000;           // figure step
input int MaxBars=0;             // bars in history (0 - all history)

                                 // color of vertical lines
color    new_hour   =DimGray;    // new hour
color    new_day    =Blue;       // new day
color    new_week   =DeepPink;   // new week
color    new_mon    =Yellow;     // new month

                                 // color horizontal lines
color    new_Hfigure=RoyalBlue;  // new figure
color    new_Hline  =DimGray;    // new line

datetime old_Times[21]={0};      // array for old times
//+------------------------------------------------------------------+
//| Checking of timeframe (async call)                                |
//+------------------------------------------------------------------+
bool CheckOtherTimeFrames(string symbol)
  {
   datetime ctm[1];
   datetime checktime=TimeCurrent()-86400*60;  // 2 months ago
   bool     res=true;
//--- request each timeframe to "update" it
   if(CopyTime(symbol,PERIOD_H1 ,checktime,1,ctm)!=1) res=false;
   if(CopyTime(symbol,PERIOD_D1 ,checktime,1,ctm)!=1) res=false;
   if(CopyTime(symbol,PERIOD_W1 ,checktime,1,ctm)!=1) res=false;
   if(CopyTime(symbol,PERIOD_MN1,checktime,1,ctm)!=1) res=false;
//--- return result
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check other timeframes (async call)
   CheckOtherTimeFrames(_Symbol);
//--- indicator buffers mapping
   EventSetTimer(25);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//  EventKillTimer();
   ObjectsDeleteAll(0,0,OBJ_HLINE);   // delete all horizontal lines
   ObjectsDeleteAll(0,0,OBJ_VLINE);   // delete all vertical lines
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // rates total
                 const int prev_calculated,  // bars calculated at previous call
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[])        // Spread
  {
   MqlDateTime str;
   string      line_name="";     // line name
   int         line_counter=0;   // line counter
   int         start_pos=0;      // starting position
   uint        start_time=GetTickCount();

//--- check other timeframes
   if(rates_total<0) return(0);
   if(!CheckOtherTimeFrames(_Symbol))
     {
      Print("Other timeframes are not ready...");
      return(prev_calculated);
     }
//--- first call
   if(prev_calculated==0)
     {
      start_time=GetTickCount();       // 
      ObjectsDeleteAll(0,0,OBJ_VLINE); // delete all vertical lines
      ObjectsDeleteAll(0,0,OBJ_HLINE); // delete all horizontal lines
      Ris_H_Line();                    // draw horizontal lines
      ArrayInitialize(old_Times,0);    // initialize array
                                       // calc start [os
      if(MaxBars!=0) if(MaxBars<rates_total) start_pos=rates_total-MaxBars;
     }
   else start_pos=prev_calculated-1;
//--- proceed all timeframes
   for(int i=start_pos;i<rates_total;i++)
     {
      color line_color=0;
      //--- define line color
      if(_Period<PERIOD_H1) if(isNewBar_i(time[i],PERIOD_H1) && _Period<PERIOD_M30) line_color=new_hour;
      if(_Period<PERIOD_D1) if(isNewBar_i(time[i],PERIOD_D1) && _Period<PERIOD_H4 ) line_color=new_day;
      if(_Period<PERIOD_W1) if(isNewBar_i(time[i],PERIOD_W1) && _Period<PERIOD_D1 ) line_color=new_week;
      if(_Period<PERIOD_MN1)if(isNewBar_i(time[i],PERIOD_MN1)&& _Period<PERIOD_MN1) line_color=new_mon;
      //---
      if(line_color!=0)
        {
         //--- prepare line name 12:00
         line_counter++;
         TimeToStruct(time[i],str);
         StringConcatenate(line_name,IntegerToString(str.hour,2,'0'),":",IntegerToString(str.min,2,'0'),"_N",line_counter);
         //--- set line
         SetVLine(line_name,time[i],line_color);
        }
     }
//--- every tick
   if(_Period<PERIOD_M30)
     {
      // delete old line of the closest hour
      if(ObjectFind(0,"VLine_0")>=0) ObjectDelete(0,"VLine_0");
      //--- set new line of the closest hour
      TimeToStruct(time[rates_total-1],str);
      SetVLine("VLine_0",time[rates_total-1]+60*(60-str.min),new_hour);
     }
//--- show statistics
   if(prev_calculated==0) 
     {
      Print("Failure or first call Time=",DoubleToString((GetTickCount()-start_time)/1000.0,1),"sec for ",rates_total,
            " bars  ObjectsTotal=",ObjectsTotal(0,0,-1)," MaxBars=",MaxBars);
     }
   return(rates_total);
  }
//+----------------------------------------------------------------------------+
//|  Description : Set the OBJ_VLINE vertical line                             |
//+----------------------------------------------------------------------------+
//|  Parameters:                                                               |
//|    nm - line name                                                          |
//|    t1 - line time                                                          |
//|    cl - line color                                                         |
//+----------------------------------------------------------------------------+
void SetVLine(string nm,datetime t1,color cl=Red)
  {
//--- time must be valid
   if(t1<=0) return;
//--- create object if it absent
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_VLINE,0,t1,2);
//--- set object properties
   ObjectSetInteger(0,nm,OBJPROP_COLOR,cl);
   ObjectSetInteger(0,nm,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,nm,OBJPROP_WIDTH,     1);          // line width
   ObjectSetInteger(0,nm,OBJPROP_BACK,      true);       // draw as background
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);      // disable selection
  }
//+----------------------------------------------------------------------------+
//|  Description : Set the OBJ_HLINE horizontal line                           |
//+----------------------------------------------------------------------------+
//|  Parameters:                                                               |
//|    nm - line name                                                          |
//|    p1 - price                                                              |
//|    cl - line color                                                         |
//+----------------------------------------------------------------------------+
void SetHLine(string nm,double p1,color cl=Red)
  {
//--- create object if it absent
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_HLINE,0,0,p1);
//--- set object properties
   ObjectSetInteger(0,nm,OBJPROP_COLOR,     cl);         // color  
   ObjectSetInteger(0,nm,OBJPROP_STYLE,     STYLE_DOT);  // style
   ObjectSetInteger(0,nm,OBJPROP_WIDTH,     1);          // line width
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);      // disable selection
  }
//+----------------------------------------------------------------------------+
//|  Description : Horizontal lines setting                                    |
//+----------------------------------------------------------------------------+
void Ris_H_Line()
  {
   double Uroven=0.0;      // level of first horizontal line
   int    rez,             // is it figure or not
   line_counter=0,         // lines counter
   i=0;                    // passes counter

//--- max and min points
   double mass[],
   max=10,
   min= 0;
   int    index;

   ArraySetAsSeries(mass,true);

   if(CopyHigh(_Symbol,PERIOD_MN1,0,Bars(_Symbol,PERIOD_MN1),mass)>2)
     {
      index=ArrayMaximum(mass,0,WHOLE_ARRAY);
      CopyHigh(_Symbol,PERIOD_MN1,index,1,mass);
      max=mass[0];
     }
   if(CopyLow(_Symbol,PERIOD_MN1,0,Bars(_Symbol,PERIOD_MN1),mass)>2)
     {
      index=ArrayMinimum(mass,0,WHOLE_ARRAY);
      CopyLow(_Symbol,PERIOD_MN1,index,1,mass);
      min=mass[0];
     }
//--- start drawing
   while(Uroven<=max)
     {
      i++;
      Uroven=i*Step*_Point;
      if(Uroven>=min)
        {
         line_counter++;
         rez=(int)MathMod(Uroven*MathPow(10,_Digits),Figure); // mod=0
         if(rez==0)
           {
            // draw up to W1
            if(_Period<PERIOD_W1) SetHLine("HLine_"+string(line_counter),Uroven,new_Hfigure);
           }
         else
         // the intermediate level up to M30 
            if(_Period<PERIOD_M30) SetHLine("HLine_"+string(line_counter),Uroven,new_Hline);
        }// end if(Uroven>=Min)
     }// end while (Uroven<=Max)
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Returns true if a new bar, overwise returns false                |
//+------------------------------------------------------------------+
bool isNewBar_i(datetime date,ENUM_TIMEFRAMES timeFrame)
  {
   bool     res=false;           // array for serving the old time values
   int      pos=0;               // index of old_Times[]   
   datetime new_Time[1];         // new bar time
//---
   switch(timeFrame)
     {
      case PERIOD_M1:  pos= 0; break;
      case PERIOD_M2:  pos= 1; break;
      case PERIOD_M3:  pos= 2; break;
      case PERIOD_M4:  pos= 3; break;
      case PERIOD_M5:  pos= 4; break;
      case PERIOD_M6:  pos= 5; break;
      case PERIOD_M10: pos= 6; break;
      case PERIOD_M12: pos= 7; break;
      case PERIOD_M15: pos= 8; break;
      case PERIOD_M20: pos= 9; break;
      case PERIOD_M30: pos=10; break;
      case PERIOD_H1:  pos=11; break;
      case PERIOD_H2:  pos=12; break;
      case PERIOD_H3:  pos=13; break;
      case PERIOD_H4:  pos=14; break;
      case PERIOD_H6:  pos=15; break;
      case PERIOD_H8:  pos=16; break;
      case PERIOD_H12: pos=17; break;
      case PERIOD_D1:  pos=18; break;
      case PERIOD_W1:  pos=19; break;
      case PERIOD_MN1: pos=20; break;
     }
//--- copying the time of a bar to the new_Time[0]  
   if(CopyTime(_Symbol,timeFrame,date,1,new_Time)==1)
     {
      if(old_Times[pos]!=new_Time[0]) // if old bar time isn't equal to new
        {
         if(old_Times[pos]!=0) res=true;    // if it isn't the first call, the result (new bar) is true
         old_Times[pos]=new_Time[0];        // saving the bar time
        }
     }
   else
      Print("Timeframe ",fTimeFrameName(timeFrame)," is not ready");
//---- 
   return(res);
  }
//+---------------------------------------------------------------------------------------------+
string fTimeFrameName(int arg)
  {
   int v;
   if(arg==0)
     {
      v=_Period;
     }
   else
     {
      v=arg;
     }
   switch(v)
     {
      case PERIOD_M1:    return("M1");
      case PERIOD_M2:    return("M2");
      case PERIOD_M3:    return("M3");
      case PERIOD_M4:    return("M4");
      case PERIOD_M5:    return("М5");
      case PERIOD_M6:    return("М6");
      case PERIOD_M10:   return("M10");
      case PERIOD_M12:   return("M12");
      case PERIOD_M15:   return("M15");
      case PERIOD_M20:   return("M20");
      case PERIOD_M30:   return("M30");
      case PERIOD_H1:    return("H1");
      case PERIOD_H2:    return("H2");
      case PERIOD_H3:    return("H3");
      case PERIOD_H4:    return("H4");
      case PERIOD_H6:    return("H6");
      case PERIOD_H8:    return("H8");
      case PERIOD_H12:   return("H12");
      case PERIOD_D1:    return("D1");
      case PERIOD_W1:    return("W1");
      case PERIOD_MN1:   return("MN1");
      default:    return("?");
     }
  } // end fTimeFrameName
