//------------------------------------------------------------------
#property copyright   "Copyright © 2006, Kim Igor V. aka KimIV"
#property link        "http://www.kimiv.ru"
#property description "The iParamon WorkTime indicator originally made by Kim Igor V"
#property description "This version made by Mladen"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

input int    NumberOfDays = 10;                 // Number of days
input string Begin_1      = "07:00";            // Start of first session
input string End_1        = "11:00";            // End of first session 
input color  Color_1      = clrBisque;          // Color of first session
input string Begin_2      = "13:00";            // Start of second session
input string End_2        = "17:00";            // End of second session
input color  Color_2      = clrPaleTurquoise;   // Color of second session
input string Begin_3      = "19:00";            // Start of third session
input string End_3        = "23:00";            // End of third session
input color  Color_3      = clrMistyRose;       // Color of third session
input string UniqueID     = "workTimes1";       // Unique ID for objects

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void OnInit() { }
void OnDeinit(const int& reason ) 
{
   for (int i=ObjectsTotal(0,-1,OBJ_RECTANGLE)-1; i>=0; i--) 
   {
      string name = ObjectName(0,i,-1,OBJ_RECTANGLE); if (StringFind(name,UniqueID+":")==0)  ObjectDelete(0,name);
   }
}
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
   if (_Period>=PERIOD_D1 || Bars(_Symbol,_Period)<rates_total) return(0);
      int noOfDays = NumberOfDays; static datetime lastTime=0; if (lastTime==time[rates_total-1]) noOfDays=MathMin(NumberOfDays,1);
                   
   //
   //
   //
   //
   //
                      
   datetime dtime[]; int copied = CopyTime(_Symbol,PERIOD_D1,0,noOfDays,dtime);
                     if (copied <= 0) return(0);
         for (int i=0; i<copied && !IsStopped(); i++) 
         {
            if (Begin_1!="") CreateSession(dtime[copied-i-1],Begin_1,End_1,Color_1,":PWT1:"+(string)i);
            if (Begin_2!="") CreateSession(dtime[copied-i-1],Begin_2,End_2,Color_2,":PWT2:"+(string)i);
            if (Begin_3!="") CreateSession(dtime[copied-i-1],Begin_3,End_3,Color_3,":PWT3:"+(string)i);
         }
   lastTime=time[rates_total-1];
   return(rates_total);
}

//
//
//
//
//

void CreateSession(datetime btime, string begin, string end, color dcolor, string id)
{
   datetime stime = StringToTime(TimeToString(btime,TIME_DATE)+" "+begin);
   datetime etime = StringToTime(TimeToString(btime,TIME_DATE)+" "+end  );
        if (etime<stime) etime+=24*3600;
        double ah[],al[]; int size = CopyHigh(_Symbol,_Period,stime,etime-1,ah); if (size<=0) return;
                              size = CopyLow (_Symbol,_Period,stime,etime-1,al); if (size<=0) return;
        double whigh = ah[ArrayMaximum(ah)], 
               wlow  = al[ArrayMinimum(al)];

   //
   //
   //
   //
   //
   
   string name = UniqueID+id;
      ObjectCreate(0,name,OBJ_RECTANGLE,0,0,0,0,0);
         ObjectSetInteger(0,name,OBJPROP_COLOR,dcolor);
         ObjectSetInteger(0,name,OBJPROP_BACK,true);
         ObjectSetInteger(0,name,OBJPROP_FILL,true);
         ObjectSetInteger(0,name,OBJPROP_TIME,0,stime);
         ObjectSetInteger(0,name,OBJPROP_TIME,1,etime);
            ObjectSetDouble(0,name,OBJPROP_PRICE,0,whigh);
            ObjectSetDouble(0,name,OBJPROP_PRICE,1,wlow);
}