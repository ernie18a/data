//+------------------------------------------------------------------+
//|                                         MetaNeural Dashboard.mq4 |
//|                                     Copyright © 2013, MetaNeural |
//|                                                                  |
//+------------------------------------------------------------------+
//////////////////////////////////////////////////////////////////////
// Update information
// Edited by CS Robots, DKP Sweden (November 2019)
// MQL5 Profile https://www.mql5.com/en/users/kenpar
//
//1: Fixed problems with take profit calculations for sup-res levels
//2: Fixed problems with status change of hourglass - Idle(hourglass)
//   Down(down red arrow) - Up(Green up arrow)
//3: Fixed all warnings in '#property strict' mode
//4: Changed text fonts for better reading visual
//5: 'Place Second order' now follow sup-res levels
//6: Some goodies...Colors can be changed for second order and Buy/sell TP
//7: Failsafe - Can only be attached to Daily charts as it's designed to work on
//
// Maybe there's more to fix in this code, i just did what i felt necessary
// Feel free to continue search for bugs.....
//////////////////////////////////////////////////////////////////////
#property copyright "Copyright © 2013, MetaNeural"
#property link      "" 
#property version   "1.1"  
#property indicator_chart_window
#property strict
//--
#define NONE 0
#define UP 1
#define DOWN 2
//--
#define STRENGTH 5
#define FAILURE 6
//--
extern int Session1 = 2;//Asia-session start
extern int Session2 = 8;//Euro-session start
extern int Session3 = 15;//US-Session start

int NextSession = -1;

extern color TextColor = White;
extern int   TextSize = 9;//Status display
int    gset=5;
extern int   Corner = 1; // 1 - right; 0 - left
extern int   p_order_size = 8;//Order object size
input color  p_order_col  = clrOrange;//Second order line
input color  ps_order_col = clrRed;//Sell order TP
input color  pb_order_col = clrLime;//Buy order TP

extern bool AlertDBias = true;
extern bool EmailDBias = true;

extern bool AlertSecondTxt = true;
extern bool EmailSecondTxt = true;

extern color BuyBoxColor = Blue;
extern color SellBoxColor = Red;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(Period()!=PERIOD_D1){
   Print("Operational on Daily charts");
   return(INIT_FAILED);}
//----
   if(TextSize==13)gset=6;
   if(TextSize==11)gset=5;
   if(TextSize==9)gset=4;
   if(TextSize==7)gset=3;
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   if(UninitializeReason() == REASON_REMOVE)
   {
      ObjectsDelete();
      Comment("");
   }
//----
   return(0);
  }
  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//--- daily variables 
   int DailyBias = NONE;
   double dc,dc2,do1,do2,dh,dh2,dl,dl2,dr,dv,dv2;
   dc = iClose(Symbol(),PERIOD_D1,1); // previous day close
   dc2 = iClose(Symbol(),PERIOD_D1,2); // close for the day before the last day
   do1 = iOpen(Symbol(),PERIOD_D1,1); // open
   do2 = iOpen(Symbol(),PERIOD_D1,2); // open for the day before the last day
   dh = iHigh(Symbol(),PERIOD_D1,1); // high
   dh2 = iHigh(Symbol(),PERIOD_D1,2); // high for the day before the last day
   dl = iLow(Symbol(),PERIOD_D1,1); // low
   dl2 = iLow(Symbol(),PERIOD_D1,2); // low for the day before the last day
   dr = dh-dl; // range
   dv =(int) iVolume(Symbol(),PERIOD_D1,1); // volume
   dv2 =(int) iVolume(Symbol(),PERIOD_D1,2); // volume for the day before the last day
//--- daily variables

//--- hourly variables
   int HourlyBias = NONE, HourlyTheme = NONE;
   double hc,hc2,ho,ho2,hh,hh2,hl,hl2,hr,hv,hv2,hs;
   string ftip="";
   hc = iClose(Symbol(),PERIOD_H1,1); // previous hour close
   hc2 = iClose(Symbol(),PERIOD_H1,2); // close for the hour before the last hour
   ho = iOpen(Symbol(),PERIOD_H1,1); // open
   ho2 = iOpen(Symbol(),PERIOD_H1,2); // open for the hour before the last hour
   hh = iHigh(Symbol(),PERIOD_H1,1); // high
   hh2 = iHigh(Symbol(),PERIOD_H1,2); // high for the hour before the last hour
   hl = iLow(Symbol(),PERIOD_H1,1); // low
   hl2 = iLow(Symbol(),PERIOD_H1,2); // low for the hour before the last hour
   hr = dh-dl; // range
   hv =(int) iVolume(Symbol(),PERIOD_H1,1); // volume
   hv2 =(int) iVolume(Symbol(),PERIOD_H1,2); // volume for the hour before the last hour
   hs = iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_H1,1),true);
   
   
//--- hourly variables
   
//--- check for long bias of previous day
   if(do1 <= dl + 0.33*dr && dc >= dl + 0.66*dr && dv > dv2) // clear sign of upwards strength for the previous day
   {
      DailyBias = UP;
   }
   
   if(dl < dl2 && dc > do1 && dc > dl+0.625*dr && dv > dv2) // standard up bar failure
   {
      DailyBias = UP;
   }
   
   if(dc - do1 <= 250*Point && dc > do1 && dv > dv2) // up t failure
   {
      DailyBias = UP;
   }
   
   if(dl < dl2 && dh > dh2 && dc >= dh2 && dv > dv2) // up wall failure 
   {
      DailyBias = UP;
   }
   
   if(MathAbs(dc - do2) < 100*Point && do2 > dc2) // reversal failure
   {
      DailyBias = UP;
   }
//--- check for long bias of previous day


//--- check for short bias of previous day
   if(dc <= dl + 0.33*dr && do1 >= dl + 0.66*dr && dv > dv2) // clear sign of downwards strength for the previous day
   {
      DailyBias = DOWN;
   }
   
   if(dh > dh2 && dc < do1 && dc < dh-0.625*dr && dv > dv2) // standard down bar failure
   {
      DailyBias = DOWN;
   }
   
   if(do1 - dc <= 250*Point && dc < do1 && dv > dv2) // down t failure
   {
      DailyBias = DOWN;
   }
   
   if(dl < dl2 && dh > dh2 && dc <= dl2 && dv > dv2) // down wall failure 
   {
      DailyBias = DOWN;
   }
   
   if(MathAbs(dc - do2) < 100*Point && do2 < dc2) // reversal failure
   {
      DailyBias = DOWN;
   }
//--- check for short bias of previous day


   int uphighvol = 0, dwhighvol = 0;
//--- check for long bias of previous hourly candle   
   if(ho <= hl + 0.33*hr && hc >= hl + 0.66*hr && hv > hv2) // clear sign of upwards strength for the previous hour
   {
      HourlyBias = UP;
      HourlyTheme = STRENGTH;
      uphighvol = 1;
   }
   
   if(hl < hl2 && hc > ho && hc > hl+0.625*hr && hv > hv2) // standard up bar failure
   {
      HourlyBias = UP;
      HourlyTheme = FAILURE;
      ftip = "Standard";
   }
   
   if(hc - ho <= 40*Point && hc > ho && hv > hv2) // up t failure
   {
      HourlyBias = UP;
      HourlyTheme = FAILURE;
      ftip = "T";
   }
   
   if(hl < hl2 && hh > hh2 && hc >= hh2 && hv > hv2) // up wall failure 
   {
      HourlyBias = UP;
      HourlyTheme = FAILURE;
      ftip = "Wall";
   }

   if(MathAbs(hc - ho2) < 40*Point && ho2 > hc2) // reversal failure
   {
      HourlyBias = UP;
      HourlyTheme = FAILURE;
      ftip = "Reversal";
   }
//--- check for long bias of previous hourly candle

//--- check for short bias of previous hourly candle
   if(hc <= hl + 0.33*hr && ho >= hl + 0.66*hr && hv > hv2) // clear sign of downwards strength for the previous hour
   {
      HourlyBias = DOWN;
      HourlyTheme = STRENGTH;
      dwhighvol = 1;
   }
   
   if(hh > hh2 && hc < ho && hc < hh-0.625*hr && hv > hv2) // standard down bar failure
   {
      HourlyBias = DOWN;
      HourlyTheme = FAILURE;
      ftip = "Standard";
   }
   
   if(ho - hc <= 40*Point && hc < ho && hv > hv2) // down t failure
   {
      HourlyBias = DOWN;
      HourlyTheme = FAILURE;
      ftip = "T";
   }
   
   if(hl < hl2 && hh > hh2 && hc <= hl2 && hv > hv2) // down wall failure 
   {
      HourlyBias = DOWN;
      HourlyTheme = FAILURE;
      ftip = "Wall";
   }
   
   if(MathAbs(hc - ho2) < 40*Point && ho2 < hc2) // reversal failure
   {
      HourlyBias = DOWN;
      HourlyTheme = FAILURE;
      ftip = "Reversal";
   }
//--- check for short bias of previous hourly candle

//--- long bias with lower Volume
   int uplowvol = 0;int dwlowvol = 0;
   
   if(ho <= hl + 0.33*hr && hc >= hl + 0.66*hr && hv < hv2) // clear sign of upwards strength for the previous hour
   {
      uplowvol =1;
   }   
   
   if(hc >= hl + 0.66*hr && ho <= hl + 0.5*hr && ho >= hl+0.33*hr) // sign of upward strength
   {
      if(hv<hv2)
      uplowvol = 1;
      if(hv>hv2)
      uphighvol = 1;
   }
      
   if(hl < hl2 && hc > ho && hc > hl+0.625*hr && hv < hv2) // standard up bar failure
   {
      uplowvol = 1;
   }
   
   if(hc - ho <= 40*Point && hc > ho && hv < hv2) // up t failure
   {
      uplowvol = 1;   
   }
   
   if(hl < hl2 && hh > hh2 && hc >= hh2 && hv < hv2) // up wall failure 
   {
      uplowvol = 1;
   }
//--- long bias with lower Volume
//--- short bias with lower Volume
   if(hc <= hl + 0.33*hr && ho >= hl + 0.66*hr && hv < hv2) // clear sign of downwards strength for the previous hour
   {
      dwlowvol = 1;
   }
   
   if(hc <= hl + 0.33*hr && ho >= hl + 0.5*hr && ho <= hl+0.66*hr) // sign of downward strength
   {
      if(hv<hv2)
      dwlowvol = 1;
      if(hv>hv2)
      uphighvol = 1;
   }
      
   if(hh > hh2 && hc < ho && hc < hh-0.625*hr && hv < hv2) // standard down bar failure
   {
      dwlowvol = 1;
   }
   
   if(ho - hc <= 40*Point && hc < ho && hv < hv2) // down t failure
   {
      dwlowvol = 1;
   }
   
   if(hl < hl2 && hh > hh2 && hc <= hl2 && hv < hv2) // down wall failure 
   {
      dwlowvol = 1;
   }
//--- short bias with lower Volume

//--- Dashboard creation

   if(ObjectFind("CurPrice")==-1)
   CreateObjects();
   
//--- Dashboard creation

//--- Dashboard update

   ObjectSetText("CurPrice",DoubleToStr(Close[0],Digits),TextSize,"Arial",TextColor);
   
   
   ObjectSetText("DBias","gg",TextSize,"Webdings"); // top box
   ObjectSetText("tDBias","D1",TextSize,"Tahoma",TextColor);   // D1 text below
   
   if(DailyBias == UP) /// setting box color
   ObjectSet("DBias",6,Lime);
   else if(DailyBias == DOWN)   
   ObjectSet("DBias",6,Red);   
   else ObjectSet("DBias",6,TextColor);   
    
    
   // check for TP   
   if(ObjectDescription("Symbolism") == "é" && Close[0] > ObjectGet("thetp",1)-100*Point)
   {// if tp is hit   
   ObjectSetText("ResetStatus","1",2*TextSize,"Tahoma",TextColor);  //we should reset; wait for new session
   }
   
   if(ObjectDescription("Symbolism") == "ê" && Close[0] < ObjectGet("thetp",1)+100*Point)
   {// if tp is hit   
   ObjectSetText("ResetStatus","1",2*TextSize,"Tahoma",TextColor);  //we should reset; wait for new session   
   }
   // check for TP

//reset if tp hit and new session starts
if(ObjectDescription("ResetStatus") == "1")
{     
   if(TimeHour(TimeCurrent()) == NextSession)
   {
   //reset
   ObjectSetText("Symbolism","6",2*TextSize,"Wingdings",TextColor);  //hourglass/no trade   
   ObjectSetText("Symbol","6",2*TextSize,"Wingdings",TextColor);  //hourglass/no trade
  
   ObjectSetText("Txt3","",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt3b","",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt3c","",TextSize,"Tahoma",TextColor);      
   
   ObjectDelete("TheTP");
   ObjectDelete("TheNext");   
      
   ObjectSetText("ResetStatus","0",2*TextSize,"Tahoma",TextColor); 
   }
   NextSession = NextSes(TimeHour(Time[0]));
}
//reset if tp hit and new session starts

//update second order text
double nex;
if(ObjectDescription("Symbolism") == "é")//long trade
{
   nex = FindTP(hc,DOWN);   
   if(Close[0] > nex + 100*Point && nex > ObjectGet("TheNext",1))
   {
   if(ObjectCreate("TheNext",OBJ_TEXT,0,Time[0],nex))
   ObjectSetText("TheNext","---Place 2:nd order Here",p_order_size,"Tahoma",p_order_col);
   
   //ObjectSet("TheNext",0,Time[0]);    
   ObjectSet("TheNext",1,nex);
   }
   ObjectSet("TheNext",0,Time[0]+2*(Time[0]-Time[5]));
}
if(ObjectDescription("Symbolism") == "ê")//short trade
{
   nex = FindTP(hc,UP);   
   double xx; if(ObjectGet("TheNext",1)==0) xx=10000; else xx = ObjectGet("TheNext",1);
   if(Close[0] < nex - 100*Point && nex < xx)
   {
   if(ObjectCreate("TheNext",OBJ_TEXT,0,Time[0],nex))
   ObjectSetText("TheNext","---Place 2:nd order Here",p_order_size,"Tahoma",p_order_col);  
            
   ObjectSet("TheNext",1,nex);
   }
   ObjectSet("TheNext",0,Time[0]+2*(Time[0]-Time[5])); 
}   
//update second order text
   
   //hourly update
if(NewBar())
{      
   deinit();
   
   if(ObjectDescription("Symbolism") == "é") // we are in a long trade
   {
      
      //
      
      if(dwlowvol == 1)
      {
      ObjectSetText("Txt3","Weak DOWN move, smart",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","money not interested, Stay In",TextSize,"Tahoma",TextColor);
      
      if(ObjectCreate("LTrade"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_TEXT,0,iTime(Symbol(),PERIOD_H1,1),hl))
      ObjectSetText("LTrade"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),"h",TextSize,"Wingdings 3",Lime);
      
      ObjectSetText("Symbol","é",2*TextSize,"Wingdings",Lime);   //up
      
      UpdateGradient(4);
      }
      
      else if(dwhighvol == 1)
      {
      ObjectSetText("Txt3","Strength coming in to the DOWNSIDE",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","Trade is still valid, Stay In",TextSize,"Tahoma",TextColor);
      
      if(ObjectCreate("LTrade2"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_TEXT,0,iTime(Symbol(),PERIOD_H1,1),hl))
      ObjectSetText("LTrade2"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),"D",TextSize,"Wingdings",Lime);
      
      ObjectSetText("Symbol","é",2*TextSize,"Wingdings",Lime);   //up
      
      UpdateGradient(4);      
      }
      
      else if(HourlyBias == DOWN && dwhighvol == 0)
      {
      ObjectSetText("Txt3","Direction change imminent, consider",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","taking partial profit, keep",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3c","partial order in until TP",TextSize,"Tahoma",TextColor);
      
      if(ObjectCreate("LTrade3"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_TEXT,0,iTime(Symbol(),PERIOD_H1,1),hl))
      ObjectSetText("LTrade3"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),"r",TextSize,"Webdings",Lime);     
      
      ObjectSetText("Symbol","r",2*TextSize,"Webdings",TextColor);  //X   
      UpdateGradient(5);
      }
      
      else if(HourlyBias == UP || uphighvol == 1 || uplowvol == 1)
      {      
      ObjectSetText("Txt3","Trade direction is confirmed",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","and still valid, STAY IN until TP",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3c","",TextSize,"Tahoma",TextColor);   
         
      if(ObjectCreate("LTrade4"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_TEXT,0,iTime(Symbol(),PERIOD_H1,1),hl))
      ObjectSetText("LTrade4"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),"h",TextSize,"Wingdings 3",Lime);
      
      ObjectSetText("Symbol","é",2*TextSize,"Wingdings",Lime);   //up
      
      UpdateGradient(2);      
      }
      
      else
      {
      ObjectSetText("Symbol","6",2*TextSize,"Wingdings",TextColor);  //hourglass   

      ObjectSetText("Txt3","NEUTRAL - Waiting",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","for next signal",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3c","",TextSize,"Tahoma",TextColor);   
      
      UpdateGradient(0);
      }
      
   }

   if(ObjectDescription("Symbolism") == "ê") // we are in a short trade
   {   
      if(uplowvol == 1)
      {
      ObjectSetText("Txt3","Weak UP move, smart",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","money not interested, Stay In",TextSize,"Tahoma",TextColor);
      
      if(ObjectCreate("STrade"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_TEXT,0,iTime(Symbol(),PERIOD_H1,1),hh+200*Point))
      ObjectSetText("STrade"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),"i",TextSize,"Wingdings 3",Lime);
      
      ObjectSetText("Symbol","ê",2*TextSize,"Wingdings",Red);   //down
      
      UpdateGradient(4);      
      }
      
      else if(dwhighvol == 1)
      {
      ObjectSetText("Txt3","Strength coming in to the UPSIDE",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","Trade is still valid, Stay In",TextSize,"Tahoma",TextColor);
      
      if(ObjectCreate("STrade2"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_TEXT,0,iTime(Symbol(),PERIOD_H1,1),hh+200*Point))
      ObjectSetText("STrade2"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),"D",TextSize,"Wingdings",Lime);
      
      ObjectSetText("Symbol","ê",2*TextSize,"Wingdings",Red);   //down
      
      UpdateGradient(4);      
      }     
      
      else if(HourlyBias == UP && uphighvol == 0)
      {
      ObjectSetText("Txt3","Direction change imminent, consider",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","taking partial profit, keep",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3c","partial order in until TP",TextSize,"Tahoma",TextColor);
      
      if(ObjectCreate("LTrade3"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_TEXT,0,iTime(Symbol(),PERIOD_H1,1),hh+200*Point))
      ObjectSetText("LTrade3"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),"r",TextSize,"Webdings",Lime);     

      ObjectSetText("Symbol","r",2*TextSize,"Webdings",TextColor);  //X   
      
      UpdateGradient(6);
      }
      
      else if(HourlyBias == DOWN || dwhighvol == 1 || dwlowvol == 1)
      {      
      ObjectSetText("Txt3","Trade direction is confirmed",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","and still valid, STAY IN until TP",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3c","",TextSize,"Arial",TextColor);   
         
      if(ObjectCreate("STrade4"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_TEXT,0,iTime(Symbol(),PERIOD_H1,1),hh+200*Point))
      ObjectSetText("STrade4"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),"i",TextSize,"Wingdings 3",Lime);
      
      ObjectSetText("Symbol","ê",2*TextSize,"Wingdings",Red);   //down
      
      
      UpdateGradient(1);      
      }      
      
      else
      {
      ObjectSetText("Symbol","6",2*TextSize,"Wingdings",TextColor);  //hourglass   

      ObjectSetText("Txt3","NEUTRAL - Waiting",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3b","for next signal",TextSize,"Tahoma",TextColor);
      ObjectSetText("Txt3c","",TextSize,"Tahoma",TextColor);               
      
      UpdateGradient(0);
      }
             
   }   
   
   
}   
   // hourly update
   
   
   //set hour glass/arrow       
   if(DailyBias == DOWN && HourlyTheme == FAILURE && HourlyBias == DOWN && ObjectDescription("Symbolism") == "6")
   {
   ObjectSetText("Symbol","ê",2*TextSize,"Wingdings");   //down
   ObjectSetText("Symbolism","ê",2*TextSize,"Wingdings");   //down
   ObjectSet("Symbol",6,Red);
   }
   
   if(DailyBias == UP && HourlyTheme == FAILURE && HourlyBias == UP  && ObjectDescription("Symbolism") == "6")
   {
   ObjectSetText("Symbol","é",2*TextSize,"Wingdings");   //up
   ObjectSetText("Symbolism","é",2*TextSize,"Wingdings");   //up   
   ObjectSet("Symbol",6,Lime);
   }

   
   
   //update gradients
   int x = 0;
   if(ObjectDescription("Symbol") == "é") x = 2;
   if(ObjectDescription("Symbol") == "ê") x = 1;
   
   if(ObjectDescription("Txt3")=="")
   UpdateGradient(x);

   //update first text command      
   if(DailyBias == UP && ObjectDescription("Symbolism") == "6")
   {
   
   if(ObjectDescription("Txt1b") != "today is UP")
   {
   if(AlertDBias)
   Alert(Symbol() + " Directional Bias for today is UP");
   if(EmailDBias)
   SendMail(Symbol() + " Directional Bias for today is UP","");   
   }
      
   ObjectSetText("Txt1","Directional Bias for",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt1b","today is UP",TextSize,"Tahoma",TextColor);
   }
   else if(DailyBias == DOWN && ObjectDescription("Symbolism") == "6")
   {

   if(ObjectDescription("Txt1b") != "today is DOWN")
   {
   if(AlertDBias)
   Alert(Symbol() + " Directional Bias for today is DOWN");
   if(EmailDBias)
   SendMail(Symbol() + " Directional Bias for today is DOWN","");   
   }
   
   ObjectSetText("Txt1","Directional Bias for",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt1b","today is DOWN",TextSize,"Tahoma",TextColor);
   }
   else if(ObjectDescription("Symbolism") == "6") 
   {

   if(ObjectDescription("Txt1b") != "bias for today")
   {
   if(AlertDBias)
   Alert(Symbol() + " There is no directional bias for today");
   if(EmailDBias)
   SendMail(Symbol() + " There is no directional bias for today","");   
   }   
   
   ObjectSetText("Txt1","There is no directional",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt1b","bias for today",TextSize,"Tahoma",TextColor);
   }
   else if(ObjectDescription("Symbolism") == "é" && (ObjectDescription("Txt1") == "Directional Bias for" || ObjectDescription("Txt1") == "There is no directional"))
   {//set text for long trade
   ObjectSetText("Txt1","A "+ ftip + " failure has occured",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt1b","on "+ Symbol() + " H1 " + DoubleToStr(TimeHour(Time[1]),0) + ":" + DoubleToStr(TimeMinute(Time[1]),0),TextSize,"Tahoma",TextColor);
   }
   else if(ObjectDescription("Symbolism") == "ê" && (ObjectDescription("Txt1") == "Directional Bias for" || ObjectDescription("Txt1") == "There is no directional"))
   {//set text for long trade
   ObjectSetText("Txt1","A "+ ftip + " failure has occured",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt1b","on "+ Symbol() + " H1 " + DoubleToStr(TimeHour(Time[1]),0) + ":" + DoubleToStr(TimeMinute(Time[1]),0),TextSize,"Tahoma",TextColor);
   }   
   
   
   
   double thetp, thenext;
   //update second text command
   if(DailyBias == UP && ObjectDescription("Symbolism") == "6")
   {
   
   if(ObjectDescription("Txt2b") != "failure of the downside")
   {
   if(AlertSecondTxt)
   Alert(Symbol() + " Waiting for a failure of the downside");
   if(EmailSecondTxt)
   SendMail(Symbol() + " Waiting for a failure of the downside","");   
   }
   
   ObjectSetText("Txt2","Waiting for a",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt2b","failure of the downside",TextSize,"Tahoma",TextColor);   
   }
   else if(DailyBias == DOWN && ObjectDescription("Symbolism") == "6")
   {
   
   if(ObjectDescription("Txt2b") != "failure of the upside")
   {
   if(AlertSecondTxt)
   Alert(Symbol() + " Waiting for a failure of the upside");
   if(EmailSecondTxt)
   SendMail(Symbol() + " Waiting for a failure of the upside","");   
   }
      
   ObjectSetText("Txt2","Waiting for a",TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt2b","failure of the upside",TextSize,"Tahoma",TextColor);      
   }
   else if(ObjectDescription("Symbolism") == "6") 
   {
   ObjectSetText("Txt2","",TextSize,"Arial",TextColor);
   ObjectSetText("Txt2b","",TextSize,"Arial",TextColor);
   }
   else if(ObjectDescription("Symbolism") == "é" && (ObjectDescription("Txt2") == "Waiting for a" || ObjectDescription("Txt2") == ""))
   {// set text for long trade
   thetp = FindTP(hc,UP);
   thenext = FindTP(hc,DOWN);
   
   ObjectSetText("Txt2","Open BUY at " + DoubleToStr(hc,Digits),TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt2b","Set TP at " + DoubleToStr(thetp-100*Point,Digits),TextSize,"Tahoma",TextColor);
   
   if(AlertSecondTxt)
   Alert(Symbol() + " Open BUY at " + DoubleToStr(hc,Digits) + ". Set TP at " + DoubleToStr(thetp-100*Point,Digits));
   if(EmailSecondTxt)
   SendMail(Symbol() + " Open BUY at " + DoubleToStr(hc,Digits) + ". Set TP at " + DoubleToStr(thetp-100*Point,Digits),"");
   
   if(ObjectCreate("LongTrade"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_RECTANGLE,0,iTime(Symbol(),PERIOD_H1,2),hh,iTime(Symbol(),PERIOD_H1,0),hl))
   ObjectSet("LongTrade"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),6,BuyBoxColor);
   
   if(ObjectCreate("TheTP",OBJ_TEXT,0,Time[0],thetp))
   ObjectSetText("TheTP","       <----------[TP Here]",p_order_size,"Tahoma",pb_order_col);     
   ObjectSet("TheTP",0,Time[0]);    
   }
   else if(ObjectDescription("Symbolism") == "ê" && (ObjectDescription("Txt2") == "Waiting for a" || ObjectDescription("Txt2") == ""))
   {// set text for short trade
   thetp = FindTP(hc,DOWN);
   thenext = FindTP(hc,UP);   
   
   ObjectSetText("Txt2","Open SELL at " + DoubleToStr(hc,Digits),TextSize,"Tahoma",TextColor);
   ObjectSetText("Txt2b","Set TP at " + DoubleToStr(thetp+100*Point,Digits),TextSize,"Tahoma",TextColor);

   if(AlertSecondTxt)
   Alert(Symbol() + " Open SELL at " + DoubleToStr(hc,Digits) + ". Set TP at " + DoubleToStr(thetp+100*Point,Digits));
   if(EmailSecondTxt)
   SendMail(Symbol() + " Open SELL at " + DoubleToStr(hc,Digits) + ". Set TP at " + DoubleToStr(thetp+100*Point,Digits),"");
   
   if(ObjectCreate("ShortTrade"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),OBJ_RECTANGLE,0,iTime(Symbol(),PERIOD_H1,2),hh,iTime(Symbol(),PERIOD_H1,0),hl))
   ObjectSet("ShortTrade"+DoubleToStr(iTime(Symbol(),PERIOD_H1,1),0),6,SellBoxColor);
   
   if(ObjectCreate("TheTP",OBJ_TEXT,0,Time[0],thetp))
   ObjectSetText("TheTP","       <----------[TP Here]",p_order_size,"Tahoma",ps_order_col);
   }   
   

//--- Dashboard update
   
//---
   return(0);
  }
//+------------------------------------------------------------------+
double FindTP(double entry,int direction)
{
   double min=0;
   if(direction == UP)
   {
      min = 10000;
      for(int i = ObjectsTotal()-1;i>=0;i--)
      {
         if(ObjectType(ObjectName(i)) == OBJ_HLINE && StringFind(ObjectName(i),"Red") != -1)
         {
            if(ObjectGet(ObjectName(i),1) > entry+150*MarketInfo(Symbol(),MODE_POINT) && ObjectGet(ObjectName(i),1) < min)
            min = ObjectGet(ObjectName(i),1);
         }         
      }
      if (min == 10000)
      {
         min = entry+150*MarketInfo(Symbol(),MODE_POINT);
      }
   }
   if(direction == DOWN)
   {
      min = 0;
      for(int ii = ObjectsTotal()-1;ii>=0;ii--)
      {
         if(ObjectType(ObjectName(ii)) == OBJ_HLINE && StringFind(ObjectName(ii),"Green") != -1)
         {
            if(ObjectGet(ObjectName(ii),1) < entry-150*MarketInfo(Symbol(),MODE_POINT) && ObjectGet(ObjectName(ii),1) > min)
            min = ObjectGet(ObjectName(ii),1);
         }         
      }
      if (min == 0)
      {
         min = entry-150*MarketInfo(Symbol(),MODE_POINT);
      }
   }
   return(min);
}

void ObjectsDelete()
{
   ObjectDelete("Symbol");
   ObjectDelete("Symbolism");
   ObjectDelete("ResetStatus");
   ObjectDelete("CurPrice");
   ObjectDelete("DBias");
   ObjectDelete("tDBias");
   ObjectDelete("Grad1");
   ObjectDelete("Grad2");
   ObjectDelete("Grad3");
   ObjectDelete("Grad4");
   ObjectDelete("Grad5");
   ObjectDelete("Grad6");
   ObjectDelete("Txt1");
   ObjectDelete("Txt1b");
   ObjectDelete("Txt2");
   ObjectDelete("Txt2b");
   ObjectDelete("Txt3");
   ObjectDelete("Txt3b");
   ObjectDelete("Txt3c");
}  

void CreateObjects()
{
   ObjectCreate("Symbolism",OBJ_TEXT,0,Time[0],0);
   ObjectSetText("Symbolism","6",2*TextSize,"Wingdings",TextColor);  //hourglass  

   ObjectCreate("ResetStatus",OBJ_TEXT,0,Time[0],0);
   ObjectSetText("ResetStatus","0",2*TextSize,"Tahoma",TextColor);
     
   ObjectCreate("CurPrice",OBJ_LABEL,0,0,0);
   ObjectSet("CurPrice",102,10);//x value
   ObjectSet("CurPrice",103,TextSize);//y value
   ObjectSet("CurPrice",101,Corner);//corner value
   
   ObjectCreate("DBias",OBJ_LABEL,0,0,0);
   ObjectSet("DBias",102,10);//x value
   ObjectSet("DBias",103,3*TextSize);//y value
   ObjectSet("DBias",101,Corner);//corner value
   
   ObjectCreate("tDBias",OBJ_LABEL,0,0,0);
   ObjectSet("tDBias",102,10);//x value
   ObjectSet("tDBias",103,5*TextSize);//y value
   ObjectSet("tDBias",101,Corner);//corner value   
   
   ObjectCreate("Symbol",OBJ_LABEL,0,0,0);
   ObjectSet("Symbol",102,10);//x value
   ObjectSet("Symbol",103,7*TextSize);//y value
   ObjectSet("Symbol",101,Corner);//corner value   
   ObjectSetText("Symbol","6",2*TextSize,"Wingdings",TextColor);  //hourglass   
   
   ObjectCreate("Grad1",OBJ_LABEL,0,0,0);
   ObjectSet("Grad1",102,10);//x value
   ObjectSet("Grad1",103,10*TextSize);//y value
   ObjectSet("Grad1",101,Corner);//corner value   
   ObjectSetText("Grad1","gg",gset,"Webdings");
   
   ObjectCreate("Grad2",OBJ_LABEL,0,0,0);
   ObjectSet("Grad2",102,10);//x value
   ObjectSet("Grad2",103,11*TextSize);//y value
   ObjectSet("Grad2",101,Corner);//corner value   
   ObjectSetText("Grad2","gg",gset,"Webdings");
   
   ObjectCreate("Grad3",OBJ_LABEL,0,0,0);
   ObjectSet("Grad3",102,10);//x value
   ObjectSet("Grad3",103,12*TextSize);//y value
   ObjectSet("Grad3",101,Corner);//corner value   
   ObjectSetText("Grad3","gg",gset,"Webdings");
   
   ObjectCreate("Grad4",OBJ_LABEL,0,0,0);
   ObjectSet("Grad4",102,10);//x value
   ObjectSet("Grad4",103,13*TextSize);//y value
   ObjectSet("Grad4",101,Corner);//corner value   
   ObjectSetText("Grad4","gg",gset,"Webdings");
   
   ObjectCreate("Grad5",OBJ_LABEL,0,0,0);
   ObjectSet("Grad5",102,10);//x value
   ObjectSet("Grad5",103,14*TextSize);//y value
   ObjectSet("Grad5",101,Corner);//corner value   
   ObjectSetText("Grad5","gg",gset,"Webdings");
   
   ObjectCreate("Grad6",OBJ_LABEL,0,0,0);
   ObjectSet("Grad6",102,10);//x value
   ObjectSet("Grad6",103,15*TextSize);//y value
   ObjectSet("Grad6",101,Corner);//corner value   
   ObjectSetText("Grad6","gg",gset,"Webdings");   

   ObjectCreate("Txt1",OBJ_LABEL,0,0,0);
   ObjectSet("Txt1",102,10);//x value
   ObjectSet("Txt1",103,17*TextSize);//y value
   ObjectSet("Txt1",101,Corner);//corner value   

   ObjectCreate("Txt1b",OBJ_LABEL,0,0,0);
   ObjectSet("Txt1b",102,10);//x value
   ObjectSet("Txt1b",103,19*TextSize);//y value
   ObjectSet("Txt1b",101,Corner);//corner value      
   
   ObjectCreate("Txt2",OBJ_LABEL,0,0,0);
   ObjectSet("Txt2",102,10);//x value
   ObjectSet("Txt2",103,22*TextSize);//y value
   ObjectSet("Txt2",101,Corner);//corner value   

   ObjectCreate("Txt2b",OBJ_LABEL,0,0,0);
   ObjectSet("Txt2b",102,10);//x value
   ObjectSet("Txt2b",103,24*TextSize);//y value
   ObjectSet("Txt2b",101,Corner);//corner value   

   ObjectCreate("Txt3",OBJ_LABEL,0,0,0);
   ObjectSet("Txt3",102,10);//x value
   ObjectSet("Txt3",103,27*TextSize);//y value
   ObjectSet("Txt3",101,Corner);//corner value   
   ObjectSetText("Txt3","");
   
   ObjectCreate("Txt3b",OBJ_LABEL,0,0,0);
   ObjectSet("Txt3b",102,10);//x value
   ObjectSet("Txt3b",103,29*TextSize);//y value
   ObjectSet("Txt3b",101,Corner);//corner value   
   ObjectSetText("Txt3b","");
   
   ObjectCreate("Txt3c",OBJ_LABEL,0,0,0);
   ObjectSet("Txt3c",102,10);//x value
   ObjectSet("Txt3c",103,31*TextSize);//y value
   ObjectSet("Txt3c",101,Corner);//corner value   
   ObjectSetText("Txt3c","");


   Comment("MetaNeural Dashboard", "\n",
           "Developed by: MetaNeural Trading", "\n");

}

void UpdateGradient(int type)
{
   if(type==0) // neutral
   {
   ObjectSet("Grad1",6,Lime);
   ObjectSet("Grad2",6,LawnGreen);
   ObjectSet("Grad3",6,YellowGreen);   
   ObjectSet("Grad4",6,DarkOrange);
   ObjectSet("Grad5",6,OrangeRed);
   ObjectSet("Grad6",6,Red);
   }

   if(type==1) // one color - red
   {   
   ObjectSet("Grad1",6,Red);
   ObjectSet("Grad2",6,Red);
   ObjectSet("Grad3",6,Red);   
   ObjectSet("Grad4",6,Red);
   ObjectSet("Grad5",6,Red);
   ObjectSet("Grad6",6,Red);   
   }
   
   if(type==2) // one color - green
   {   
   ObjectSet("Grad1",6,Lime);
   ObjectSet("Grad2",6,Lime);
   ObjectSet("Grad3",6,Lime);   
   ObjectSet("Grad4",6,Lime);
   ObjectSet("Grad5",6,Lime);
   ObjectSet("Grad6",6,Lime);
   }
   
   if(type==4) // medium 
   {   
   ObjectSet("Grad1",6,Lime);
   ObjectSet("Grad2",6,Lime);
   ObjectSet("Grad3",6,Lime);   
   ObjectSet("Grad4",6,Red);
   ObjectSet("Grad5",6,Red);
   ObjectSet("Grad6",6,Red);
   }

   if(type==5) // least - red
   {   
   ObjectSet("Grad1",6,Lime);
   ObjectSet("Grad2",6,Lime);
   ObjectSet("Grad3",6,OrangeRed);   
   ObjectSet("Grad4",6,Red);
   ObjectSet("Grad5",6,Red);
   ObjectSet("Grad6",6,Red);  
   }
      
   if(type==6) // least - green
   {   
   ObjectSet("Grad1",6,Lime);
   ObjectSet("Grad2",6,Lime);
   ObjectSet("Grad3",6,Lime);   
   ObjectSet("Grad4",6,Lime);
   ObjectSet("Grad5",6,OrangeRed);
   ObjectSet("Grad6",6,Red);
   
   
   
   

   
   
   
   
   }

}



bool NewBar()
   {   
      static datetime lastbar = 0;
      datetime curbar = Time[0];   
         if(lastbar!=curbar)   
            {      
               lastbar=curbar;      
               return (true);   
                  }   
               else   
                     {      
                      return(false);   
                        }
               }
               
//returns the openning hour of the next session
int NextSes(int cur)
{
   int Next = -1;   
   if(cur < Session1) Next = Session1;
   if(cur > Session1) Next = Session2;
   if(cur > Session2) Next = Session3;
   if(cur > Session3) Next = -1;   
   return(Next);





}
                    