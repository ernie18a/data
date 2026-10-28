//+------------------------------------------------------------------+
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//| account_info_vertical 4.01                                       |
//| File45: https://www.mql5.com/en/users/file45/publications        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, file45."
#property link      "https://forge.mql5.io"
#property version   "4.01"
#property description "Places account information on the chart in vertical sequence.." 
#property description " "
#property description  "Hide account info: Click anywhere on account text."
#property description  "Show account info: Click on text - 'Account Info'."
#property description " "
#property description  "Show Profit only option."
#property strict
#property indicator_chart_window

input bool Show_only_Profit = false; // Show Profit only
input ENUM_BASE_CORNER CP = 2; // Corner
input int    Up_Down = 10;     // Up <-> Down 
input int    Left_Right = 10;  // Left <-> Right
input color  Font_Color = SlateGray; // Info Color
input color  Color_Profitx=LimeGreen;    // Profit Color
input color  Color_Lossx=Red;        // Loss Color
input int    Font_Size_v  = 8;  // Font Size
input bool   Font_Bold = false; // Font Bold

bool switchv;
color PnL_Color;
color Font_Colorx=Font_Color;
color Color_PnL_Closedx=Font_Color;

string Acc_F,TM,Hide_Show_x=" ";

int Up_Down_HS;
int Up_Down_ML;
int Up_Down_M;
int Up_Down_FM;
int Up_Down_E;
int Up_Down_B;
int Up_Down_P, Up_Down_Pv;
int Font_Size;

datetime LastAlertTime;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Font_Size_v<6)
    {
      Font_Size=6;
    } 
   else
    {
      Font_Size=Font_Size_v;
    }     
   
   if(CP==2 || CP==3)
     {
      Up_Down_ML= Up_Down+Font_Size*10;
      Up_Down_M = Up_Down+Font_Size*8;
      Up_Down_FM= Up_Down+Font_Size*6;
      Up_Down_E = Up_Down+Font_Size*4;
      Up_Down_B = Up_Down+Font_Size*2;
      Up_Down_P = Up_Down;
     }
   else
     {
      Up_Down_ML= Up_Down+Font_Size*2;
      Up_Down_M = Up_Down+Font_Size*4;
      Up_Down_FM= Up_Down+Font_Size*6;
      Up_Down_E = Up_Down+Font_Size*8;
      Up_Down_B = Up_Down+Font_Size*10;
      Up_Down_P = Up_Down+Font_Size*12;
     }

   switch(Font_Bold)
     {
      case 0: Acc_F = "Arial"; break;
      case 1: Acc_F = "Arial Bold";
     }
  
   Hide_Show_x = " ";

   if(Show_only_Profit == false)
    {
     ObjectCreate(0,"Acc_ML_v",OBJ_LABEL,0,0,0);
     ObjectCreate(0,"Acc_M_v",OBJ_LABEL,0,0,0);
     ObjectCreate(0,"Acc_FM_v",OBJ_LABEL,0,0,0);
     ObjectCreate(0,"Acc_E_v",OBJ_LABEL,0,0,0);
     ObjectCreate(0,"Acc_B_v",OBJ_LABEL,0,0,0);
   }
   ObjectCreate(0,"Acc_P_v",OBJ_LABEL,0,0,0);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("Acc_H_S_v");
   ObjectDelete("Acc_ML_v");
   ObjectDelete("Acc_M_v");
   ObjectDelete("Acc_FM_v");
   ObjectDelete("Acc_E_v");
   ObjectDelete("Acc_B_v");
   ObjectDelete("Acc_P_v");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if((CP==2 || CP==3) && Hide_Show_x==" ")
     {
      Up_Down_Pv=Up_Down_P;
     }
   else if((CP==2 || CP==3) && Hide_Show_x==" Account Info ") 
     {
      Up_Down_HS=Up_Down_P;

     } 
   else if((CP==0 || CP==1) && Hide_Show_x==" " && Show_only_Profit==false)
     {
      Up_Down_Pv=Up_Down_P;
     }
   else if((CP==0 || CP==1) && Hide_Show_x==" Account Info " && Show_only_Profit==false) 
     {
      Up_Down_HS=Up_Down_ML;
     }
   else if((CP==0 || CP==1) && Hide_Show_x==" " && Show_only_Profit==true)
     {
       Up_Down_Pv=Up_Down_ML;
     }
   else if((CP==0 || CP==1) && Hide_Show_x==" Account Info " && Show_only_Profit==true) 
     {
      Up_Down_HS=Up_Down_ML;
     }  
       
   ObjectCreate(0,"Acc_H_S_v",OBJ_LABEL,0,0,0);
   ObjectSetText("Acc_H_S_v",Hide_Show_x,Font_Size,Acc_F,Font_Color);
   ObjectSet("Acc_H_S_v",OBJPROP_SELECTABLE,false);
   ObjectSet("Acc_H_S_v",OBJPROP_CORNER,CP);
   ObjectSet("Acc_H_S_v",OBJPROP_XDISTANCE,Left_Right);
   ObjectSet("Acc_H_S_v",OBJPROP_YDISTANCE,Up_Down_HS);

   string Acc_ML_vs=formatDouble(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),2);
   ObjectSetText("Acc_ML_v"," Margin Level: "+Acc_ML_vs+" % ",Font_Size,Acc_F,Font_Color);
   ObjectSet("Acc_ML_v",OBJPROP_SELECTABLE,false);
   ObjectSet("Acc_ML_v",OBJPROP_CORNER,CP);
   ObjectSet("Acc_ML_v",OBJPROP_XDISTANCE,Left_Right);
   ObjectSet("Acc_ML_v",OBJPROP_YDISTANCE,Up_Down_ML);

   string Acc_M_vs=formatDouble(AccountMargin(),2);
   ObjectSetText("Acc_M_v"," Margin: "+Acc_M_vs,Font_Size,Acc_F,Font_Color);
   ObjectSet("Acc_M_v",OBJPROP_SELECTABLE,false);
   ObjectSet("Acc_M_v",OBJPROP_CORNER,CP);
   ObjectSet("Acc_M_v",OBJPROP_XDISTANCE,Left_Right);
   ObjectSet("Acc_M_v",OBJPROP_YDISTANCE,Up_Down_M);

   string Acc_FM_vs=formatDouble(AccountFreeMargin(),2);
   ObjectSetText("Acc_FM_v"," FreeMargin: "+Acc_FM_vs,Font_Size,Acc_F,Font_Color);
   ObjectSet("Acc_FM_v",OBJPROP_SELECTABLE,false);
   ObjectSet("Acc_FM_v",OBJPROP_CORNER,CP);
   ObjectSet("Acc_FM_v",OBJPROP_XDISTANCE,Left_Right);
   ObjectSet("Acc_FM_v",OBJPROP_YDISTANCE,Up_Down_FM);

   string Acc_E_vs=formatDouble(AccountEquity(),2);
   ObjectSetText("Acc_E_v"," Equity: "+Acc_E_vs,Font_Size,Acc_F,Font_Color);
   ObjectSet("Acc_E_v",OBJPROP_SELECTABLE,false);
   ObjectSet("Acc_E_v",OBJPROP_CORNER,CP);
   ObjectSet("Acc_E_v",OBJPROP_XDISTANCE,Left_Right);
   ObjectSet("Acc_E_v",OBJPROP_YDISTANCE,Up_Down_E);

   string Acc_B_vs=formatDouble(AccountBalance(),2);
   ObjectSetText("Acc_B_v"," Balance: "+Acc_B_vs,Font_Size,Acc_F,Font_Color);
   ObjectSet("Acc_B_v",OBJPROP_SELECTABLE,false);
   ObjectSet("Acc_B_v",OBJPROP_CORNER,CP);
   ObjectSet("Acc_B_v",OBJPROP_XDISTANCE,Left_Right);
   ObjectSet("Acc_B_v",OBJPROP_YDISTANCE,Up_Down_B);
   
   string Acc_P_vs=formatDouble(AccountProfit(),2);

   if(AccountProfit()>=0.01)
     {
      PnL_Color=Color_Profitx;
     }
   else if(AccountProfit()<=-0.01)
     {
      PnL_Color=Color_Lossx;
     }
   else
     {
      PnL_Color=Font_Color;
     }

   ObjectSetText("Acc_P_v"," Acc Profit: "+AccountCurrency()+" "+Acc_P_vs,Font_Size,Acc_F,PnL_Color);
   ObjectSet("Acc_P_v",OBJPROP_SELECTABLE,false);
   ObjectSet("Acc_P_v",OBJPROP_CORNER,CP);
   ObjectSet("Acc_P_v",OBJPROP_XDISTANCE,Left_Right);
   ObjectSet("Acc_P_v",OBJPROP_YDISTANCE,Up_Down_Pv);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
  {
   if(id==CHARTEVENT_OBJECT_CLICK && (sparam=="Acc_H_S_v" || sparam=="Acc_ML_v" || sparam=="Acc_M_v"
      || sparam=="Acc_FM_v" || sparam=="Acc_E_v" || sparam=="Acc_B_v" || sparam=="Acc_P_v"))
     {
      switchv=!switchv;

      switch(switchv)
        {
         case 0: Hide_Show_x=" ";
         if(Show_only_Profit == false)
          {
           ObjectCreate(0,"Acc_ML_v",OBJ_LABEL,0,0,0);
           ObjectCreate(0,"Acc_M_v",OBJ_LABEL,0,0,0);
           ObjectCreate(0,"Acc_FM_v",OBJ_LABEL,0,0,0);
           ObjectCreate(0,"Acc_E_v",OBJ_LABEL,0,0,0);
           ObjectCreate(0,"Acc_B_v",OBJ_LABEL,0,0,0);
         }
         ObjectCreate(0,"Acc_P_v",OBJ_LABEL,0,0,0);
         break;
         case 1: Hide_Show_x=" Account Info ";
         if(Show_only_Profit == false)
          {
           ObjectDelete("Acc_ML_v");
           ObjectDelete("Acc_M_v");
           ObjectDelete("Acc_FM_v");
           ObjectDelete("Acc_E_v");
           ObjectDelete("Acc_B_v");
         }
         ObjectDelete("Acc_P_v");
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string formatDouble(double number,int precision,string pcomma=",",string ppoint=".")
  {
   string snum     = DoubleToStr(number, precision);
   int    decp     = StringFind(snum, ".", 0);
   string sright   = StringSubstr(snum, decp + 1, precision);
   string sleft    = StringSubstr(snum, 0, decp);
   string formated = "";
   string comma    = "";

   while(StringLen(sleft)>3)
     {
      int    length = StringLen(sleft);
      string part   = StringSubstr(sleft, length - 3, 0);
      formated = part + comma + formated;
      comma    = pcomma;
      sleft    = StringSubstr(sleft, 0, length - 3);
     }
   if(sleft=="-")
      comma="";              // this line missing previously
   if(sleft!="")
      formated=sleft+comma+formated;
   if(precision>0)
      formated=formated+ppoint+sright;
   return(formated);
  }
//+------------------------------------------------------------------+
