//+------------------------------------------------------------------+
//|                                        Abd.shepherd@Facebook.com |
//|                                              ABO-HOB@HOTMAIL.COM |
//|                                              ABO-HOB@HOTMAIL.COM |
//+------------------------------------------------------------------+
#property copyright   "2016, Abd.shepherd@Facebook.com"                                    // copyright
#property version     "1.01"                                                               // Version 
#property link        "https://www.mql5.com/en/users/abo-hob"    // URL                                            // Version
#property description "This Expert Advisor is Working to test indicator buffers  "             // Description (line 1)
//#property icon      "\\Images\\SysReqMet.ico"; 
#property strict
extern string Indicator_Name="Put_your_Indicator_Name";
extern int    prev_calculated=100;
extern int    Indicator_shift=1;
string Auther="***Indicator_Buffers***";
string Buffer0 = "Buffer0";
string Buffer1 = "Buffer1";
string Buffer2 = "Buffer2";
string Buffer3 = "Buffer3";
string Buffer4 = "Buffer4";
string Buffer5 = "Buffer5";
string Buffer6 = "Buffer6";
string Buffer7 = "Buffer7";
string Used    = "No_Buffer_Detected";
bool Check0;
bool Check1;
bool Check2;
bool Check3;
bool Check4;
bool Check5;
bool Check6;
bool Check7;
color c0=clrGray;
color c1=clrGray;
color c2=clrGray;
color c3=clrGray;
color c4=clrGray;
color c5=clrGray;
color c6=clrGray;
color c7=clrGray;
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int init()
  {
   ObjectCreate(Auther,OBJ_LABEL,0,0,0);
   ObjectSet(Auther,OBJPROP_CORNER,3);
   ObjectSet(Auther,OBJPROP_XDISTANCE,5);
   ObjectSet(Auther,OBJPROP_YDISTANCE,5);
   ObjectSetText(Auther,Auther,9,"Verdana",Orange);

   Check0=true;
   Check1=true;
   Check2=true;
   Check3=true;
   Check4=true;
   Check5=true;
   Check6=true;
   Check7=true;

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete(ChartID(),Auther);
   ObjectDelete(ChartID(),Buffer0);
   ObjectDelete(ChartID(),Buffer1);
   ObjectDelete(ChartID(),Buffer2);
   ObjectDelete(ChartID(),Buffer3);
   ObjectDelete(ChartID(),Buffer4);
   ObjectDelete(ChartID(),Buffer5);
   ObjectDelete(ChartID(),Buffer6);
   ObjectDelete(ChartID(),Buffer7);
   ObjectDelete(ChartID(),Used);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   ENUM_LICENSE_TYPE mql_program=(ENUM_LICENSE_TYPE)MQLInfoInteger(MQL_LICENSE_TYPE);

   int    i,limit;
//--- last counted bar will be recounted
   limit=Bars-prev_calculated;
   if(prev_calculated>1){limit++;}
   for(i=Indicator_shift; i<limit; i++)
     {
      double B0=iCustom(Symbol(),0,Indicator_Name,0,i);
      double B1=iCustom(Symbol(),0,Indicator_Name,1,i);
      double B2=iCustom(Symbol(),0,Indicator_Name,2,i);
      double B3=iCustom(Symbol(),0,Indicator_Name,3,i);
      double B4=iCustom(Symbol(),0,Indicator_Name,4,i);
      double B5=iCustom(Symbol(),0,Indicator_Name,5,i);
      double B6=iCustom(Symbol(),0,Indicator_Name,6,i);
      double B7=iCustom(Symbol(),0,Indicator_Name,7,i);
      string bb0=DoubleToString(B0);
      string bb1=DoubleToString(B1);
      string bb2=DoubleToString(B2);
      string bb3=DoubleToString(B3);
      string bb4=DoubleToString(B4);
      string bb5=DoubleToString(B5);
      string bb6=DoubleToString(B6);
      string bb7=DoubleToString(B7);

      ObjectCreate(Buffer0,OBJ_LABEL,0,0,0);
      ObjectSet(Buffer0,OBJPROP_CORNER,4);
      ObjectSet(Buffer0,OBJPROP_XDISTANCE,5);
      ObjectSet(Buffer0,OBJPROP_YDISTANCE,15);
      ObjectSetText(Buffer0,Buffer0+" =  "+bb0,9,"Verdana",c0);

      ObjectCreate(Buffer1,OBJ_LABEL,0,0,0);
      ObjectSet(Buffer1,OBJPROP_CORNER,4);
      ObjectSet(Buffer1,OBJPROP_XDISTANCE,5);
      ObjectSet(Buffer1,OBJPROP_YDISTANCE,30);
      ObjectSetText(Buffer1,Buffer1+" =  "+bb1,9,"Verdana",c1);

      ObjectCreate(Buffer2,OBJ_LABEL,0,0,0);
      ObjectSet(Buffer2,OBJPROP_CORNER,4);
      ObjectSet(Buffer2,OBJPROP_XDISTANCE,5);
      ObjectSet(Buffer2,OBJPROP_YDISTANCE,45);
      ObjectSetText(Buffer2,Buffer2+" =  "+bb2,9,"Verdana",c2);

      ObjectCreate(Buffer3,OBJ_LABEL,0,0,0);
      ObjectSet(Buffer3,OBJPROP_CORNER,4);
      ObjectSet(Buffer3,OBJPROP_XDISTANCE,5);
      ObjectSet(Buffer3,OBJPROP_YDISTANCE,60);
      ObjectSetText(Buffer3,Buffer3+" =  "+bb3,9,"Verdana",c3);

      ObjectCreate(Buffer4,OBJ_LABEL,0,0,0);
      ObjectSet(Buffer4,OBJPROP_CORNER,4);
      ObjectSet(Buffer4,OBJPROP_XDISTANCE,5);
      ObjectSet(Buffer4,OBJPROP_YDISTANCE,75);
      ObjectSetText(Buffer4,Buffer4+" =  "+bb4,9,"Verdana",c4);

      ObjectCreate(Buffer5,OBJ_LABEL,0,0,0);
      ObjectSet(Buffer5,OBJPROP_CORNER,4);
      ObjectSet(Buffer5,OBJPROP_XDISTANCE,5);
      ObjectSet(Buffer5,OBJPROP_YDISTANCE,90);
      ObjectSetText(Buffer5,Buffer5+" =  "+bb5,9,"Verdana",c5);

      ObjectCreate(Buffer6,OBJ_LABEL,0,0,0);
      ObjectSet(Buffer6,OBJPROP_CORNER,4);
      ObjectSet(Buffer6,OBJPROP_XDISTANCE,5);
      ObjectSet(Buffer6,OBJPROP_YDISTANCE,105);
      ObjectSetText(Buffer6,Buffer6+" =  "+bb6,9,"Verdana",c6);

      ObjectCreate(Buffer7,OBJ_LABEL,0,0,0);
      ObjectSet(Buffer7,OBJPROP_CORNER,4);
      ObjectSet(Buffer7,OBJPROP_XDISTANCE,5);
      ObjectSet(Buffer7,OBJPROP_YDISTANCE,120);
      ObjectSetText(Buffer7,Buffer7+" =  "+bb7,9,"Verdana",c7);

      if(StringToDouble(bb0)!=0&&Check0==true) {c0=clrYellowGreen;Check0=false;}
      if(StringToDouble(bb1)!=0&&Check1==true) {c1=clrYellowGreen;Check1=false;}
      if(StringToDouble(bb2)!=0&&Check2==true) {c2=clrYellowGreen;Check2=false;}
      if(StringToDouble(bb3)!=0&&Check3==true) {c3=clrYellowGreen;Check3=false;}
      if(StringToDouble(bb4)!=0&&Check4==true) {c4=clrYellowGreen;Check4=false;}
      if(StringToDouble(bb5)!=0&&Check5==true) {c5=clrYellowGreen;Check5=false;}
      if(StringToDouble(bb6)!=0&&Check6==true) {c6=clrYellowGreen;Check6=false;}
      if(StringToDouble(bb7)!=0&&Check7==true) {c6=clrYellowGreen;Check7=false;}
     }

   return(0);
  }
//+------------------------------------------------------------------+
