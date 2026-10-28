//+------------------------------------------------------------------+
//|                                                 Hamyar Zones.mq4 |
//|                               Copyright © 2010,Farshad Saremifar |
//|                                                   www.4xline.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010,Farshad Saremifar"
#property link      "www.4xline.com"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  Green
#property indicator_style1 STYLE_DASH

#property indicator_width1 1
#property indicator_color2  Red
#property indicator_width2 4
#property indicator_color3  DodgerBlue
#property indicator_width3 4

#property indicator_color4  Red
#property indicator_style4 2
#property indicator_color5  DodgerBlue
#property indicator_style5 2

#property indicator_color6  Red
#property indicator_style6 2
#property indicator_color7  DodgerBlue
#property indicator_style7 2

//---- input parameters
extern string    Copyright="Copyright © 2010,Farshad Saremifar,www.4xline.com";
extern int NumberOfDays=5;
extern int ATR_Period=25;
extern int StartHour=9;
extern int Quarter=0;
extern bool DayLightSaving=true;
extern int GMT_Shift=210;
int GMT_SHIFT=210;
int StartMinute=0;
int LondonTZ = 0;
int Tehran = 210;
int TokyoTZ = 540;
int NewYorkTZ = -300;
double BuyZone[], Pivot[], SellZone[];
double Buytp1[], Buytp2[], Selltp1[], Selltp2[];

double PDayHigh, PDayLow;

datetime PivotDayStartTime;
 int Tehranshift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorDigits(Digits);
   SetIndexBuffer( 0, Pivot);
   SetIndexBuffer( 1, SellZone);
   SetIndexBuffer( 2, BuyZone);
   SetIndexBuffer(3, Selltp1);
   SetIndexBuffer( 4, Buytp1);
   SetIndexBuffer(5, Selltp2);
   SetIndexBuffer( 6, Buytp2);
  
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexStyle(5, DRAW_LINE);
   SetIndexStyle(6, DRAW_LINE);
  
   SetIndexEmptyValue( 0, EMPTY_VALUE );
   SetIndexEmptyValue( 1, EMPTY_VALUE );
   SetIndexEmptyValue( 2, EMPTY_VALUE );
   SetIndexEmptyValue( 3, EMPTY_VALUE );
   SetIndexEmptyValue( 4, EMPTY_VALUE );
   SetIndexEmptyValue( 5, EMPTY_VALUE );
   SetIndexEmptyValue( 6, EMPTY_VALUE );
   
   SetIndexLabel( 0, "Pivot" );
   SetIndexLabel( 1, "SellZone" );
   SetIndexLabel( 2, "BuyZone" );
   SetIndexLabel( 3, "Selltp1" );
   SetIndexLabel( 4, "Buytp1" );
    SetIndexLabel( 5, "Selltp2" );
   SetIndexLabel( 6, "Buytp2" );
  
  switch (Quarter)
  {
  case 1: StartMinute=0;break;
  case 2: StartMinute=15;break;
  case 3: StartMinute=30;break;
  case 4: StartMinute=45;break;
  default: StartMinute=0;break;

  
  
  }
 
   PivotDayStartTime = 0; 
//----
  
   int dst;
  if(DayLightSaving==false) {dst=1;GMT_SHIFT=GMT_Shift;}
  
  if(DayLightSaving==true) {dst=2;GMT_SHIFT=GMT_Shift+60;}
   
   
   
   datetime brokerTime = CurTime();
   datetime GMT = TimeLocal()- GMT_SHIFT * 60;
  

   datetime london = GMT + (LondonTZ + (dst*60 - 1*60)) * 60;
   datetime tokyo = GMT + (TokyoTZ) * 60;
   datetime newyork = GMT + (NewYorkTZ + (dst*60 - 1*60)) * 60;
   datetime tehran=GMT + (Tehran + (dst*60 - 1*60)) * 60;
   Tehranshift=tehran-brokerTime;
    GlobalVariableSet("Tehranshift"+WindowHandle(Symbol(),Period())+Symbol()+Period(),Tehranshift);
     GlobalVariableSet("GMT_SHIFT"+WindowHandle(Symbol(),Period())+Symbol()+Period(),GMT_SHIFT);
    GlobalVariableSet("DayLightSaving"+WindowHandle(Symbol(),Period())+Symbol()+Period(),DayLightSaving);
  
    
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
 GlobalVariablesDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   GlobalVariableSet("StartHour"+WindowHandle(Symbol(),Period())+Symbol()+Period(),StartHour);
  GlobalVariableSet("StartMinute"+WindowHandle(Symbol(),Period())+Symbol()+Period(),StartMinute);
   GlobalVariableSet("ATR_Period"+WindowHandle(Symbol(),Period())+Symbol()+Period(),ATR_Period);
  GlobalVariableSet("NumberOfDays"+WindowHandle(Symbol(),Period())+Symbol()+Period(),NumberOfDays);
  GlobalVariableSet("Quarter"+WindowHandle(Symbol(),Period())+Symbol()+Period(),Quarter);
   GlobalVariableSet("Tehranshift"+WindowHandle(Symbol(),Period())+Symbol()+Period(),Tehranshift);
   GlobalVariableSet("GMT_SHIFT"+WindowHandle(Symbol(),Period())+Symbol()+Period(),GMT_SHIFT);
  GlobalVariableSet("DayLightSaving"+WindowHandle(Symbol(),Period())+Symbol()+Period(),DayLightSaving);
  
   int i, j,Count;
   double Range;
    i =((NumberOfDays*1440)/Period())+((1440)/Period());
   
   //----


  
  while(i >=0)
   {
      if(  PivotDay( Time[i+1]+Tehranshift-StartHour*60*60-StartMinute*60)!=PivotDay( Time[i]+Tehranshift-StartHour*60*60-StartMinute*60))
           {
               double pip15,pip30,pip60;
               Pivot[i]=iCustom(NULL,0,"Hamyar Calculate","","",ATR_Period,0,i);
               pip15=iCustom(NULL,0,"Hamyar Calculate","","",ATR_Period,2,i);
               pip30=iCustom(NULL,0,"Hamyar Calculate","","",ATR_Period,3,i);
               pip60=iCustom(NULL,0,"Hamyar Calculate","","",ATR_Period,4,i);
              
               BuyZone[i] =Pivot[i]+ pip15;       
               SellZone[i] = Pivot[i] - pip15;                 
               Selltp1[i] = Pivot[i] - (pip30+pip15);                 
               Buytp1[i] = Pivot[i] + (pip30+pip15);                 
               Selltp2[i] = SellZone[i] - (pip15+pip60);                 
               Buytp2[i] = BuyZone[i] + (pip15+pip60);                 
   

               SellZone[i+1] =EMPTY_VALUE;
               BuyZone[i+1] =EMPTY_VALUE;
               Pivot[i+1] =EMPTY_VALUE;
               Selltp1[i+1] = EMPTY_VALUE;
               Buytp1[i+1] = EMPTY_VALUE;
               Selltp2[i+1] =EMPTY_VALUE;
               Buytp2[i+1] = EMPTY_VALUE;
               
               SellZone[i+2] =EMPTY_VALUE;
               BuyZone[i+2] =EMPTY_VALUE;
               Pivot[i+2] =EMPTY_VALUE;
               Selltp1[i+2] =EMPTY_VALUE;
               Buytp1[i+2] = EMPTY_VALUE;
               Selltp2[i+2] =EMPTY_VALUE;
               Buytp2[i+2] = EMPTY_VALUE;
               PivotDayStartTime=Time[i];
                    
                  
               
       }
      else     
               {
       
                BuyZone[i] = BuyZone[i+1];
                SellZone[i] = SellZone[i+1];
                Selltp1[i] = Selltp1[i+1];
                Buytp1[i] = Buytp1[i+1];
                Selltp2[i] = Selltp2[i+1];
                Buytp2[i] = Buytp2[i+1];
                
                Pivot[i] = Pivot[i+1];
      }  
     
     
      i--;
     if (i==0)GlobalVariableSet("PivotDayStartTime"+WindowHandle(Symbol(),Period())+Symbol()+Period(),PivotDayStartTime); 
   }
//----
  
   return(0);
  }
//+------------------------------------------------------------------+

//--------------------
int PivotDay( datetime BarTime )
{
    int PDay = TimeDayOfWeek( BarTime);

      if( PDay == 0 ) PDay = 5;      
      if( PDay == 6 ) PDay = 5;   
        

   return( PDay );
}
  

