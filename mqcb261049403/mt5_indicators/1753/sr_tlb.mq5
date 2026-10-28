//+------------------------------------------------------------------+
//|                                                       SR_TLB.mq5 |
//|                                  Copyright © 2008, Ulterior (FF) |
//+------------------------------------------------------------------+
//---- The author of the indicator
#property copyright "Copyright © 2008, Ulterior (FF)"
//---- A ink to the author's site 
#property link      "http://localhost"
//---- the nummber of the indicator version
#property version   "1.00"
#property description "Support and Resistance MTF Trend Line Breaks"
//---- The indicator is drawn in the main window
#property indicator_chart_window 
//---- the number of indicator buffers is 42
#property indicator_buffers 42
//---- 0 graphical constructions used
#property indicator_plots   0
//+----------------------------------------------+
//| Input parameters of the indicator            |
//+----------------------------------------------+
input int LB=3;
input int maxBarsForPeriod=1000;
input bool showM01 = true;
input bool showM02 = true;
input bool showM03 = true;
input bool showM04 = true;
input bool showM05 = true;
input bool showM06 = true;
input bool showM10 = true;
input bool showM12 = true;
input bool showM15 = true;
input bool showM20 = true;
input bool showM30 = true;
input bool showH01 = true;
input bool showH02 = true;
input bool showH03 = true;
input bool showH04 = true;
input bool showH06 = true;
input bool showH08 = true;
input bool showH12 = true;
input bool showD01 = true;
input bool showW01 = true;
input bool showMN1 = true;
//+----------------------------------------------+
//---- Declaring dynamic arrays that
// will further be used as indicator bufers
double TLBMax_M01[];
double TLBMax_M02[];
double TLBMax_M03[];
double TLBMax_M04[];
double TLBMax_M05[];
double TLBMax_M06[];
double TLBMax_M10[];
double TLBMax_M12[];
double TLBMax_M15[];
double TLBMax_M20[];
double TLBMax_M30[];
double TLBMax_H01[];
double TLBMax_H02[];
double TLBMax_H03[];
double TLBMax_H04[];
double TLBMax_H06[];
double TLBMax_H08[];
double TLBMax_H12[];
double TLBMax_D01[];
double TLBMax_W01[];
double TLBMax_MN1[];

double TLBMin_M01[];
double TLBMin_M02[];
double TLBMin_M03[];
double TLBMin_M04[];
double TLBMin_M05[];
double TLBMin_M06[];
double TLBMin_M10[];
double TLBMin_M12[];
double TLBMin_M15[];
double TLBMin_M20[];
double TLBMin_M30[];
double TLBMin_H01[];
double TLBMin_H02[];
double TLBMin_H03[];
double TLBMin_H04[];
double TLBMin_H06[];
double TLBMin_H08[];
double TLBMin_H12[];
double TLBMin_D01[];
double TLBMin_W01[];
double TLBMin_MN1[];
//---- Declaring integer variables of data calculation start
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(1);

   set_prevBarTime(PERIOD_M1,NULL);
   set_prevBarTime(PERIOD_M2,NULL);
   set_prevBarTime(PERIOD_M3,NULL);
   set_prevBarTime(PERIOD_M4,NULL);
   set_prevBarTime(PERIOD_M5,NULL);
   set_prevBarTime(PERIOD_M6,NULL);
   set_prevBarTime(PERIOD_M10,NULL);
   set_prevBarTime(PERIOD_M12,NULL);
   set_prevBarTime(PERIOD_M15,NULL);
   set_prevBarTime(PERIOD_M20,NULL);
   set_prevBarTime(PERIOD_M30,NULL);
   set_prevBarTime(PERIOD_H1,NULL);
   set_prevBarTime(PERIOD_H2,NULL);
   set_prevBarTime(PERIOD_H3,NULL);
   set_prevBarTime(PERIOD_H4,NULL);
   set_prevBarTime(PERIOD_H6,NULL);
   set_prevBarTime(PERIOD_H8,NULL);
   set_prevBarTime(PERIOD_H12,NULL);
   set_prevBarTime(PERIOD_D1,NULL);
   set_prevBarTime(PERIOD_W1,NULL);
   set_prevBarTime(PERIOD_MN1,NULL);

//---- Set dynamic arrays as buffers for storing data
   Init(0,TLBMax_M01);
   Init(1,TLBMax_M02);
   Init(2,TLBMax_M03);
   Init(3,TLBMax_M04);
   Init(4,TLBMax_M05);
   Init(5,TLBMax_M06);
   Init(6,TLBMax_M10);
   Init(7,TLBMax_M12);
   Init(8,TLBMax_M15);
   Init(9,TLBMax_M20);
   Init(10,TLBMax_M30);
   Init(11,TLBMax_H01);
   Init(12,TLBMax_H02);
   Init(13,TLBMax_H03);
   Init(14,TLBMax_H04);
   Init(15,TLBMax_H06);
   Init(16,TLBMax_H08);
   Init(17,TLBMax_H12);
   Init(18,TLBMax_D01);
   Init(19,TLBMax_W01);
   Init(20,TLBMax_MN1);

   Init(21,TLBMin_M01);
   Init(22,TLBMin_M02);
   Init(23,TLBMin_M03);
   Init(24,TLBMin_M04);
   Init(25,TLBMin_M05);
   Init(26,TLBMin_M06);
   Init(27,TLBMin_M10);
   Init(28,TLBMin_M12);
   Init(29,TLBMin_M15);
   Init(30,TLBMin_M20);
   Init(31,TLBMin_M30);
   Init(32,TLBMin_H01);
   Init(33,TLBMin_H02);
   Init(34,TLBMin_H03);
   Init(35,TLBMin_H04);
   Init(36,TLBMin_H06);
   Init(37,TLBMin_H08);
   Init(38,TLBMin_H12);
   Init(39,TLBMin_D01);
   Init(40,TLBMin_W01);
   Init(41,TLBMin_MN1);

//---- Set accuracy of displaying for the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- Creating labels for displaying in DataWindow and the name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"3 Line Break On Chart +levels");
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Init(int Number,double  &IndArray[])
  {
//---- Set a dynamic array as an indicator buffer
   SetIndexBuffer(Number,IndArray,INDICATOR_CALCULATIONS);
//----  Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndArray,true);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   DeleteHLineObject(getPeriodAsString(PERIOD_M1)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M1)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M1)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M1)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M2)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M2)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M2)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M2)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M3)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M3)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M3)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M3)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M4)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M4)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M4)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M4)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M5)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M5)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M5)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M5)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M6)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M6)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M6)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M6)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M10)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M10)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M10)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M10)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M12)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M12)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M12)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M12)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M15)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M15)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M15)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M15)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M20)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M20)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M20)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M20)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_M30)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_M30)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_M30)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_M30)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_H1)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_H1)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_H1)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_H1)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_H2)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_H2)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_H2)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_H2)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_H3)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_H3)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_H3)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_H3)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_H4)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_H4)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_H4)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_H4)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_H6)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_H6)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_H6)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_H6)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_H8)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_H8)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_H8)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_H8)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_H12)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_H12)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_H12)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_H12)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_D1)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_D1)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_D1)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_D1)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_W1)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_W1)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_W1)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_W1)+" Res C");

   DeleteHLineObject(getPeriodAsString(PERIOD_MN1)+" Sup");
   DeleteHLineObject(getPeriodAsString(PERIOD_MN1)+" Res");
   DeleteHLineObject(getPeriodAsString(PERIOD_MN1)+" Sup C");
   DeleteHLineObject(getPeriodAsString(PERIOD_MN1)+" Res C");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double& high[],     // A price array of price maximums for the calculation of the indicator
                const double& Low[],      // A price array of price minimums for the calculation of the indicator
                const double &Close[],
                const long &Tick_volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- Indexing elements in arrays as in timeseries  
   ArraySetAsSeries(Time,true);

   if( Period() <= PERIOD_M1 && showM01 ) displayPeriod( PERIOD_M1,Time );
   if( Period() <= PERIOD_M2 && showM02 ) displayPeriod( PERIOD_M2,Time );
   if( Period() <= PERIOD_M3 && showM03 ) displayPeriod( PERIOD_M3,Time );
   if( Period() <= PERIOD_M4 && showM04 ) displayPeriod( PERIOD_M4,Time );
   if( Period() <= PERIOD_M5 && showM05 ) displayPeriod( PERIOD_M5,Time );
   if( Period() <= PERIOD_M6 && showM05 ) displayPeriod( PERIOD_M6,Time );
   if( Period() <= PERIOD_M10 && showM10 ) displayPeriod( PERIOD_M10,Time );
   if( Period() <= PERIOD_M12 && showM12 ) displayPeriod( PERIOD_M12,Time );
   if( Period() <= PERIOD_M15 && showM15 ) displayPeriod( PERIOD_M15,Time );
   if( Period() <= PERIOD_M20 && showM20 ) displayPeriod( PERIOD_M20,Time );
   if( Period() <= PERIOD_M30 && showM30 ) displayPeriod( PERIOD_M30,Time );
   if( Period() <= PERIOD_H1 && showH01 ) displayPeriod( PERIOD_H1,Time );
   if( Period() <= PERIOD_H2 && showH02 ) displayPeriod( PERIOD_H2,Time );
   if( Period() <= PERIOD_H3 && showH03 ) displayPeriod( PERIOD_H3,Time );
   if( Period() <= PERIOD_H4 && showH04 ) displayPeriod( PERIOD_H4,Time );
   if( Period() <= PERIOD_H6 && showH06 ) displayPeriod( PERIOD_H6,Time );
   if( Period() <= PERIOD_H8 && showH08 ) displayPeriod( PERIOD_H8,Time );
   if( Period() <= PERIOD_H12 && showH12 ) displayPeriod( PERIOD_H12,Time );
   if( Period() <= PERIOD_D1 && showD01 ) displayPeriod( PERIOD_D1,Time );
   if( Period() <= PERIOD_W1 && showW01 ) displayPeriod( PERIOD_W1,Time );
   if( Period() <= PERIOD_MN1 && showMN1 ) displayPeriod( PERIOD_MN1,Time );
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Diap(ENUM_TIMEFRAMES mtPeriod,bool up,int C,int index)
  {
//----
   int i;
   double MM=0.0;
   if(up)
     {
      MM=get_max(mtPeriod,index);
      for(i=1; i<C; i++)
         if(get_max(mtPeriod,index-i)>MM)
            MM=get_max(mtPeriod,index-i);
     }
   if(!up)
     {
      MM=get_min(mtPeriod,index);
      for(i=1; i<C; i++)
         if(get_min(mtPeriod,index-i)<MM)
            MM=get_min(mtPeriod,index-i);
     }
//----
   return(MM);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteHLineObject(string name)
  {
//----
   ObjectDelete(0,name);
   ObjectDelete(0,name+"_Label");
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowHLineObject(string name,color clr,int style,double dValue,int index,const datetime  &Time[])
  {
//----
   if(ObjectFind(0,name))
     {
      CreateHLineObject(name,clr,style,dValue,index,Time);
     }

//if(ShowLineLabels)
     {
      ObjectMove(0,name+"_Label",0,Time[0]+_Period*index,dValue);
      ObjectSetInteger(0,name+"_Label",OBJPROP_STYLE,style);
     }

   ObjectMove(0,name,0,0,dValue);
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateHLineObject(string name,color clr,int style,double dValue,int index,const datetime  &Time[])
  {
//----
//if(ShowLineLabels)
     {
      ObjectCreate(0,name+"_Label",OBJ_TEXT,0,Time[0]+_Period*index,dValue);
      ObjectSetString(0,name+"_Label",OBJPROP_FONT,"Verdana");
      ObjectSetInteger(0,name+"_Label",OBJPROP_FONTSIZE,7);
      ObjectSetInteger(0,name+"_Label",OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name+"_Label",OBJPROP_BACK,false);
      ObjectSetInteger(0,name+"_Label",OBJPROP_ANCHOR,ANCHOR_LOWER);
      ObjectSetString(0,name+"_Label",OBJPROP_TEXT,name);
     }

   ObjectCreate(0,name,OBJ_HLINE,0,Time[0],dValue);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getPeriodAsString(ENUM_TIMEFRAMES mtPeriod)
  {
//----
   string periodname=NULL;
   switch(mtPeriod)
     {
      case PERIOD_M1:  { periodname = "M1"; break; }
      case PERIOD_M2:  { periodname = "M2"; break; }
      case PERIOD_M3:  { periodname = "M3"; break; }
      case PERIOD_M4:  { periodname = "M4"; break; }
      case PERIOD_M5:  { periodname = "M5"; break; }
      case PERIOD_M6:  { periodname = "M6"; break; }
      case PERIOD_M10: { periodname = "M10"; break; }
      case PERIOD_M12: { periodname = "M12"; break; }
      case PERIOD_M15: { periodname = "M15"; break; }
      case PERIOD_M20: { periodname = "M20"; break; }
      case PERIOD_M30: { periodname = "M30"; break; }
      case PERIOD_H1:  { periodname = "H1"; break; }
      case PERIOD_H2:  { periodname = "H2"; break; }
      case PERIOD_H3:  { periodname = "H3"; break; }
      case PERIOD_H4:  { periodname = "H4"; break; }
      case PERIOD_H6:  { periodname = "H6"; break; }
      case PERIOD_H8:  { periodname = "H8"; break; }
      case PERIOD_H12: { periodname = "H12"; break; }
      case PERIOD_D1:  { periodname = "D1"; break; }
      case PERIOD_W1:  { periodname = "W1"; break; }
      case PERIOD_MN1: { periodname = "MN1"; break; }
     }
//----
   return(periodname);
  }

datetime prevBarTime_M01 = NULL;
datetime prevBarTime_M02 = NULL;
datetime prevBarTime_M03 = NULL;
datetime prevBarTime_M04 = NULL;
datetime prevBarTime_M05 = NULL;
datetime prevBarTime_M06 = NULL;
datetime prevBarTime_M10 = NULL;
datetime prevBarTime_M12 = NULL;
datetime prevBarTime_M15 = NULL;
datetime prevBarTime_M20 = NULL;
datetime prevBarTime_M30 = NULL;
datetime prevBarTime_H01 = NULL;
datetime prevBarTime_H02 = NULL;
datetime prevBarTime_H03 = NULL;
datetime prevBarTime_H04 = NULL;
datetime prevBarTime_H06 = NULL;
datetime prevBarTime_H08 = NULL;
datetime prevBarTime_H12 = NULL;
datetime prevBarTime_D01 = NULL;
datetime prevBarTime_W01 = NULL;
datetime prevBarTime_MN1 = NULL;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_prevBarTime(ENUM_TIMEFRAMES mtPeriod_,datetime value)
  {
//----
   switch(mtPeriod_)
     {
      case PERIOD_M1:  { prevBarTime_M01 = value; break; }
      case PERIOD_M2:  { prevBarTime_M02 = value; break; }
      case PERIOD_M3:  { prevBarTime_M03 = value; break; }
      case PERIOD_M4:  { prevBarTime_M04 = value; break; }
      case PERIOD_M5:  { prevBarTime_M05 = value; break; }
      case PERIOD_M6:  { prevBarTime_M06 = value; break; }
      case PERIOD_M10: { prevBarTime_M10 = value; break; }
      case PERIOD_M15: { prevBarTime_M15 = value; break; }
      case PERIOD_M12: { prevBarTime_M12 = value; break; }
      case PERIOD_M20: { prevBarTime_M20 = value; break; }
      case PERIOD_M30: { prevBarTime_M30 = value; break; }
      case PERIOD_H1:  { prevBarTime_H01 = value; break; }
      case PERIOD_H2:  { prevBarTime_H02 = value; break; }
      case PERIOD_H3:  { prevBarTime_H03 = value; break; }
      case PERIOD_H4:  { prevBarTime_H04 = value; break; }
      case PERIOD_H6:  { prevBarTime_H06 = value; break; }
      case PERIOD_H8:  { prevBarTime_H08 = value; break; }
      case PERIOD_H12: { prevBarTime_H12 = value; break; }
      case PERIOD_D1:  { prevBarTime_D01 = value; break; }
      case PERIOD_W1:  { prevBarTime_W01 = value; break; }
      case PERIOD_MN1: { prevBarTime_MN1 = value; break; }
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime get_prevBarTime(ENUM_TIMEFRAMES mtPeriod)
  {
//----
   switch(mtPeriod)
     {
      case PERIOD_M1:  { return(prevBarTime_M01); break; }
      case PERIOD_M2:  { return(prevBarTime_M02); break; }
      case PERIOD_M3:  { return(prevBarTime_M03); break; }
      case PERIOD_M4:  { return(prevBarTime_M04); break; }
      case PERIOD_M5:  { return(prevBarTime_M05); break; }
      case PERIOD_M6:  { return(prevBarTime_M06); break; }
      case PERIOD_M10: { return(prevBarTime_M10); break; }
      case PERIOD_M12: { return(prevBarTime_M12); break; }
      case PERIOD_M15: { return(prevBarTime_M15); break; }
      case PERIOD_M20: { return(prevBarTime_M20); break; }
      case PERIOD_M30: { return(prevBarTime_M30); break; }
      case PERIOD_H1:  { return(prevBarTime_H01); break; }
      case PERIOD_H2:  { return(prevBarTime_H02); break; }
      case PERIOD_H3:  { return(prevBarTime_H03); break; }
      case PERIOD_H4:  { return(prevBarTime_H04); break; }
      case PERIOD_H6:  { return(prevBarTime_H06); break; }
      case PERIOD_H8:  { return(prevBarTime_H08); break; }
      case PERIOD_H12: { return(prevBarTime_H12); break; }
      case PERIOD_D1:  { return(prevBarTime_D01); break; }
      case PERIOD_W1:  { return(prevBarTime_W01); break; }
      case PERIOD_MN1: { return(prevBarTime_MN1); break; }
     }
//----
   return(NULL);
  }

datetime prevBarCount_M01 = NULL;
datetime prevBarCount_M02 = NULL;
datetime prevBarCount_M03 = NULL;
datetime prevBarCount_M04 = NULL;
datetime prevBarCount_M05 = NULL;
datetime prevBarCount_M06 = NULL;
datetime prevBarCount_M10 = NULL;
datetime prevBarCount_M12 = NULL;
datetime prevBarCount_M15 = NULL;
datetime prevBarCount_M20 = NULL;
datetime prevBarCount_M30 = NULL;
datetime prevBarCount_H01 = NULL;
datetime prevBarCount_H02 = NULL;
datetime prevBarCount_H03 = NULL;
datetime prevBarCount_H04 = NULL;
datetime prevBarCount_H06 = NULL;
datetime prevBarCount_H08 = NULL;
datetime prevBarCount_H12 = NULL;
datetime prevBarCount_D01 = NULL;
datetime prevBarCount_W01 = NULL;
datetime prevBarCount_MN1 = NULL;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_prevBarCount(ENUM_TIMEFRAMES mtPeriod,int value)
  {
//----
   switch(mtPeriod)
     {
      case PERIOD_M1:  { prevBarCount_M01 = value; break; }
      case PERIOD_M2:  { prevBarCount_M02 = value; break; }
      case PERIOD_M3:  { prevBarCount_M03 = value; break; }
      case PERIOD_M4:  { prevBarCount_M04 = value; break; }
      case PERIOD_M5:  { prevBarCount_M05 = value; break; }
      case PERIOD_M6:  { prevBarCount_M06 = value; break; }
      case PERIOD_M10: { prevBarCount_M10 = value; break; }
      case PERIOD_M12: { prevBarCount_M12 = value; break; }
      case PERIOD_M15: { prevBarCount_M15 = value; break; }
      case PERIOD_M20: { prevBarCount_M20 = value; break; }
      case PERIOD_M30: { prevBarCount_M30 = value; break; }
      case PERIOD_H1:  { prevBarCount_H01 = value; break; }
      case PERIOD_H2:  { prevBarCount_H02 = value; break; }
      case PERIOD_H3:  { prevBarCount_H03 = value; break; }
      case PERIOD_H4:  { prevBarCount_H04 = value; break; }
      case PERIOD_H6:  { prevBarCount_H06 = value; break; }
      case PERIOD_H8:  { prevBarCount_H08 = value; break; }
      case PERIOD_H12: { prevBarCount_H12 = value; break; }
      case PERIOD_D1:  { prevBarCount_D01 = value; break; }
      case PERIOD_W1:  { prevBarCount_W01 = value; break; }
      case PERIOD_MN1: { prevBarCount_MN1 = value; break; }
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime get_prevBarCount(ENUM_TIMEFRAMES mtPeriod)
  {
//----
   switch(mtPeriod)
     {
      case PERIOD_M1:  { return(prevBarCount_M01); break; }
      case PERIOD_M2:  { return(prevBarCount_M02); break; }
      case PERIOD_M3:  { return(prevBarCount_M03); break; }
      case PERIOD_M4:  { return(prevBarCount_M04); break; }
      case PERIOD_M5:  { return(prevBarCount_M05); break; }
      case PERIOD_M6:  { return(prevBarCount_M06); break; }
      case PERIOD_M10: { return(prevBarCount_M10); break; }
      case PERIOD_M12: { return(prevBarCount_M12); break; }
      case PERIOD_M15: { return(prevBarCount_M15); break; }
      case PERIOD_M20: { return(prevBarCount_M20); break; }
      case PERIOD_M30: { return(prevBarCount_M30); break; }
      case PERIOD_H1:  { return(prevBarCount_H01); break; }
      case PERIOD_H2:  { return(prevBarCount_H02); break; }
      case PERIOD_H3:  { return(prevBarCount_H03); break; }
      case PERIOD_H4:  { return(prevBarCount_H04); break; }
      case PERIOD_H6:  { return(prevBarCount_H06); break; }
      case PERIOD_H8:  { return(prevBarCount_H08); break; }
      case PERIOD_H12: { return(prevBarCount_H12); break; }
      case PERIOD_D1:  { return(prevBarCount_D01); break; }
      case PERIOD_W1:  { return(prevBarCount_W01); break; }
      case PERIOD_MN1: { return(prevBarCount_MN1); break; }
     }
//----
   return(NULL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_max(ENUM_TIMEFRAMES mtPeriod,int index,double value)
  {
//----
   switch(mtPeriod)
     {
      case PERIOD_M1:  { TLBMax_M01[ index ] = value; break; }
      case PERIOD_M2:  { TLBMax_M02[ index ] = value; break; }
      case PERIOD_M3:  { TLBMax_M03[ index ] = value; break; }
      case PERIOD_M4:  { TLBMax_M04[ index ] = value; break; }
      case PERIOD_M5:  { TLBMax_M05[ index ] = value; break; }
      case PERIOD_M6:  { TLBMax_M06[ index ] = value; break; }
      case PERIOD_M10: { TLBMax_M10[ index ] = value; break; }
      case PERIOD_M12: { TLBMax_M12[ index ] = value; break; }
      case PERIOD_M15: { TLBMax_M15[ index ] = value; break; }
      case PERIOD_M20: { TLBMax_M20[ index ] = value; break; }
      case PERIOD_M30: { TLBMax_M30[ index ] = value; break; }
      case PERIOD_H1:  { TLBMax_H01[ index ] = value; break; }
      case PERIOD_H2:  { TLBMax_H02[ index ] = value; break; }
      case PERIOD_H3:  { TLBMax_H03[ index ] = value; break; }
      case PERIOD_H4:  { TLBMax_H04[ index ] = value; break; }
      case PERIOD_H6:  { TLBMax_H06[ index ] = value; break; }
      case PERIOD_H8:  { TLBMax_H08[ index ] = value; break; }
      case PERIOD_H12: { TLBMax_H12[ index ] = value; break; }
      case PERIOD_D1:  { TLBMax_D01[ index ] = value; break; }
      case PERIOD_W1:  { TLBMax_W01[ index ] = value; break; }
      case PERIOD_MN1: { TLBMax_MN1[ index ] = value; break; }
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_max(ENUM_TIMEFRAMES mtPeriod,int index)
  {
//----
   switch(mtPeriod)
     {
      case PERIOD_M1:  { return(TLBMax_M01[ index ]); break; }
      case PERIOD_M2:  { return(TLBMax_M02[ index ]); break; }
      case PERIOD_M3:  { return(TLBMax_M03[ index ]); break; }
      case PERIOD_M4:  { return(TLBMax_M04[ index ]); break; }
      case PERIOD_M5:  { return(TLBMax_M05[ index ]); break; }
      case PERIOD_M6:  { return(TLBMax_M06[ index ]); break; }
      case PERIOD_M10: { return(TLBMax_M10[ index ]); break; }
      case PERIOD_M12: { return(TLBMax_M12[ index ]); break; }
      case PERIOD_M15: { return(TLBMax_M15[ index ]); break; }
      case PERIOD_M20: { return(TLBMax_M20[ index ]); break; }
      case PERIOD_M30: { return(TLBMax_M30[ index ]); break; }
      case PERIOD_H1:  { return(TLBMax_H01[ index ]); break; }
      case PERIOD_H2:  { return(TLBMax_H02[ index ]); break; }
      case PERIOD_H3:  { return(TLBMax_H03[ index ]); break; }
      case PERIOD_H4:  { return(TLBMax_H04[ index ]); break; }
      case PERIOD_H6:  { return(TLBMax_H06[ index ]); break; }
      case PERIOD_H8:  { return(TLBMax_H08[ index ]); break; }
      case PERIOD_H12: { return(TLBMax_H12[ index ]); break; }
      case PERIOD_D1:  { return(TLBMax_D01[ index ]); break; }
      case PERIOD_W1:  { return(TLBMax_W01[ index ]); break; }
      case PERIOD_MN1: { return(TLBMax_MN1[ index ]); break; }
     }
//----
   return(NULL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_min(ENUM_TIMEFRAMES mtPeriod,int index,double value)
  {
//----
   switch(mtPeriod)
     {
      case PERIOD_M1:  { TLBMin_M01[ index ] = value; break; }
      case PERIOD_M2:  { TLBMin_M02[ index ] = value; break; }
      case PERIOD_M3:  { TLBMin_M03[ index ] = value; break; }
      case PERIOD_M4:  { TLBMin_M04[ index ] = value; break; }
      case PERIOD_M5:  { TLBMin_M05[ index ] = value; break; }
      case PERIOD_M6:  { TLBMin_M06[ index ] = value; break; }
      case PERIOD_M10: { TLBMin_M10[ index ] = value; break; }
      case PERIOD_M12: { TLBMin_M12[ index ] = value; break; }
      case PERIOD_M15: { TLBMin_M15[ index ] = value; break; }
      case PERIOD_M20: { TLBMin_M20[ index ] = value; break; }
      case PERIOD_M30: { TLBMin_M30[ index ] = value; break; }
      case PERIOD_H1:  { TLBMin_H01[ index ] = value; break; }
      case PERIOD_H2:  { TLBMin_H02[ index ] = value; break; }
      case PERIOD_H3:  { TLBMin_H03[ index ] = value; break; }
      case PERIOD_H4:  { TLBMin_H04[ index ] = value; break; }
      case PERIOD_H6:  { TLBMin_H06[ index ] = value; break; }
      case PERIOD_H8:  { TLBMin_H08[ index ] = value; break; }
      case PERIOD_H12: { TLBMin_H12[ index ] = value; break; }
      case PERIOD_D1:  { TLBMin_D01[ index ] = value; break; }
      case PERIOD_W1:  { TLBMin_W01[ index ] = value; break; }
      case PERIOD_MN1: { TLBMin_MN1[ index ] = value; break; }
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_min(ENUM_TIMEFRAMES mtPeriod,int index)
  {
//----
   switch(mtPeriod)
     {
      case PERIOD_M1:  { return(TLBMin_M01[ index ]); break; }
      case PERIOD_M2:  { return(TLBMin_M02[ index ]); break; }
      case PERIOD_M3:  { return(TLBMin_M03[ index ]); break; }
      case PERIOD_M4:  { return(TLBMin_M04[ index ]); break; }
      case PERIOD_M5:  { return(TLBMin_M05[ index ]); break; }
      case PERIOD_M6:  { return(TLBMin_M06[ index ]); break; }
      case PERIOD_M10: { return(TLBMin_M10[ index ]); break; }
      case PERIOD_M12: { return(TLBMin_M12[ index ]); break; }
      case PERIOD_M15: { return(TLBMin_M15[ index ]); break; }
      case PERIOD_M20: { return(TLBMin_M20[ index ]); break; }
      case PERIOD_M30: { return(TLBMin_M30[ index ]); break; }
      case PERIOD_H1:  { return(TLBMin_H01[ index ]); break; }
      case PERIOD_H2:  { return(TLBMin_H02[ index ]); break; }
      case PERIOD_H3:  { return(TLBMin_H03[ index ]); break; }
      case PERIOD_H4:  { return(TLBMin_H04[ index ]); break; }
      case PERIOD_H6:  { return(TLBMin_H06[ index ]); break; }
      case PERIOD_H8:  { return(TLBMin_H08[ index ]); break; }
      case PERIOD_H12: { return(TLBMin_H12[ index ]); break; }
      case PERIOD_D1:  { return(TLBMin_D01[ index ]); break; }
      case PERIOD_W1:  { return(TLBMin_W01[ index ]); break; }
      case PERIOD_MN1: { return(TLBMin_MN1[ index ]); break; }
     }
//----
   return(NULL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool displayPeriod(ENUM_TIMEFRAMES mtPeriod_,const datetime & time[])
  {

   datetime iTime[1];
   int numBars=Bars(Symbol(),mtPeriod_);
//---- Copy the new data to the arrays
   if(CopyTime(Symbol(),mtPeriod_,0,1,iTime)<=0) return(false);

   if(get_prevBarTime(mtPeriod_)==NULL || get_prevBarTime(mtPeriod_)!=iTime[0] || 
      get_prevBarCount(mtPeriod_)==NULL || get_prevBarCount(mtPeriod_)!=numBars)
     {
      set_prevBarTime(mtPeriod_,iTime[0]);
      set_prevBarCount(mtPeriod_,numBars);
     }
   else return(true);

   if(maxBarsForPeriod>0 && numBars>maxBarsForPeriod) numBars=maxBarsForPeriod;
   int TLBBuffShift=0;
   int limit=numBars;

   double iClose[];
//---- Copy the new data to the arrays
   if(CopyClose(Symbol(),mtPeriod_,0,limit+1,iClose)<=0) return(false);
//---- Indexing elements in arrays as in timeseries  
   ArraySetAsSeries(iClose,true);

   int i,j;
   j=1;
   while(iClose[limit-1]==iClose[limit-1-j])
     {
      j++;
      if(j>limit-1)
         break;
     }

   if(iClose[limit-1]>iClose[limit-1-j])
     {
      set_max(mtPeriod_,0,iClose[limit-1]);
      set_min(mtPeriod_,0,iClose[limit-1-j]);
     }
   if(iClose[limit-1]<iClose[limit-1-j])
     {
      set_max(mtPeriod_,0,iClose[limit-1-j]);
      set_min(mtPeriod_,0,iClose[limit-1]);
     }

   for(i=1; i<LB; i++)
     {
      while(iClose[limit-j]<=Diap(mtPeriod_,true,i,TLBBuffShift) && iClose[limit-j]>=Diap(mtPeriod_,false,i,TLBBuffShift))
        {
         j++;

         if(j>limit-1)
            break;
        }
      if(j>limit-1)
         break;

      if(iClose[limit-j]>get_max(mtPeriod_,i-1))
        {
         set_max(mtPeriod_,i,iClose[limit-j]);
         set_min(mtPeriod_,i,get_max(mtPeriod_,i-1));
         TLBBuffShift++;
        }
      if(iClose[limit-j]<get_min(mtPeriod_,i-1))
        {
         set_min(mtPeriod_,i,iClose[limit-j]);
         set_max(mtPeriod_,i,get_min(mtPeriod_,i-1));
         TLBBuffShift++;
        }
     }

   for(i=LB; i<limit; i++)
     {
      while(iClose[limit-j]<=Diap(mtPeriod_,true,LB,TLBBuffShift) && iClose[limit-j]>=Diap(mtPeriod_,false,LB,TLBBuffShift))
        {
         j++;
         if(j>limit-1)
            break;
        }
      if(j>limit-1)
         break;

      if(iClose[limit-j]>get_max(mtPeriod_,i-1))
        {
         set_max(mtPeriod_,i,iClose[limit-j]);
         set_min(mtPeriod_,i,get_max(mtPeriod_,i-1));
         TLBBuffShift++;
        }
      if(iClose[limit-j]<get_min(mtPeriod_,i-1))
        {
         set_min(mtPeriod_,i,iClose[limit-j]);
         set_max(mtPeriod_,i,get_min(mtPeriod_,i-1));
         TLBBuffShift++;
        }
     }

   double sup= 0,res = 0,supc = 0,resc = 0;
   int redCnt=0,blueCnt=0;
   int numObj= 0;
   for(i=1; i<=TLBBuffShift; i++)
     {
      if(get_max(mtPeriod_,i)>get_max(mtPeriod_,i-1))
        {
         if(blueCnt>=LB)
            sup=get_max(mtPeriod_,i-LB);
         else
            sup=get_min(mtPeriod_,i-blueCnt-1);

         resc = get_max( mtPeriod_, i );
         supc = 0;
         res=0;

         blueCnt++;
         redCnt=0;
        }
      if(get_max(mtPeriod_,i)<get_max(mtPeriod_,i-1))
        {
         if(redCnt>=LB)
            res=get_min(mtPeriod_,i-LB);
         else
            res=get_max(mtPeriod_,i-redCnt-1);

         supc= get_min(mtPeriod_,i);
         sup = 0;
         resc= 0;

         blueCnt=0;
         redCnt++;
        }

     }
   
   if(sup>0.0) ShowHLineObject(getPeriodAsString(mtPeriod_)+" Sup",clrBlue,STYLE_SOLID,sup,500,time);
   else DeleteHLineObject(getPeriodAsString(mtPeriod_)+" Sup");

   if(res>0.0) ShowHLineObject(getPeriodAsString(mtPeriod_)+" Res",clrRed,STYLE_SOLID,res,500,time);
   else DeleteHLineObject(getPeriodAsString(mtPeriod_)+" Res");

   if(supc>0.0) ShowHLineObject(getPeriodAsString(mtPeriod_)+" Sup C",clrBlue,STYLE_DASHDOTDOT,supc,1200,time);
   else DeleteHLineObject(getPeriodAsString(mtPeriod_)+" Sup C");

   if(resc>0.0) ShowHLineObject(getPeriodAsString(mtPeriod_)+" Res C",clrRed,STYLE_DASHDOTDOT,resc,1200,time);
   else DeleteHLineObject(getPeriodAsString(mtPeriod_)+" Res C");
//----
   return(true);
  }
//+------------------------------------------------------------------+
