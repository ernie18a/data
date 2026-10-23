     
      /*##############################################################
      #  DAILY CHANGE INDICATOR                                      #
      #                                                              #
      #  This Indicator shows the percentage change between          #
      #  yesterday day close and today actual Price (Bid).           #
      #  It works on any time frame.                                 #
      #                                                              #
      #  Copyright: BLACKHAWK                                        #
      ##############################################################*/

/*
------------------------------------------------------------------------------------------------

Description:
 
This indicator shows the % Daily Change of yesterday close with respect to actual price (Bid). 

It calculates the percentage change between yesterday close price and the actual bid price. 

It works on any timeframe.


External Modifications:

You can modify the color and size:

Color:         You can change the color for Up Movement, Down Movement and No Movement      
Size:          You can change the text font size and the arrow size   

You can modify the position of text and arrow:

X_Position           You can modify X position (distance) from corner
Y_Position           You can modify Y position (distance) from corner
Corner_Position      You can select the corner position (0: Top Left / 1: Top Right / 2: Bottom Left / 3: Bottom Right)

------------------------------------------------------------------------------------------------
*/


#property indicator_chart_window

//---------------------------------------------------- 
extern int     Font_Size               = 8;
extern int     Arrow_Size              = 10;
extern color   Up_Color                = Green;
extern color   Down_Color              = Red;
extern color   No_Mvt_Color            = Blue;

extern int     X_Position_Text         = 3;
extern int     Y_Position_Text         = 3;
extern int     Corner_Position_Text    = 2;

extern int     X_Position_Arrow        = 3;
extern int     Y_Position_Arrow        = 90;
extern int     Corner_Position_Arrow   = 2;
// ---------------------------------------------------

#define OBJECT    "DailyChange"
#define OBJECT1   "ArrowChange"



int start()

   {
   
   double ClPrice_D1    = iClose(NULL, PERIOD_D1, 1);
   double ActualBid     = Bid;
   double PercChange    = ((ActualBid - ClPrice_D1)/ClPrice_D1)*100;

   string ArrowUp       =  "p";  // 112 Up arrow code
   string ArrowDn       =  "q";  // 113 Down arrow code
   string Arrow0        =  "";
   string Arrow;
   color  Obj_Color;
   
   string PerChg = "D.Ch.: "+DoubleToStr(PercChange, 2) + " %";
   
   if(PercChange > 0)   {Arrow = ArrowUp; Obj_Color = Up_Color;}
   if(PercChange < 0)   {Arrow = ArrowDn; Obj_Color = Down_Color;}
   if(PercChange == 0)  {Arrow = Arrow0; Obj_Color = No_Mvt_Color;}
   
   
   string ArrowChg = Arrow;
     
   if(ObjectFind(OBJECT) < 0)
      
      {
      ObjectCreate   (OBJECT, OBJ_LABEL, 0, 0, 0);
      ObjectSet      (OBJECT, OBJPROP_CORNER, Corner_Position_Text);
      ObjectSet      (OBJECT, OBJPROP_YDISTANCE, X_Position_Text);
      ObjectSet      (OBJECT, OBJPROP_XDISTANCE, Y_Position_Text);
      ObjectSetText  (OBJECT, PerChg, Font_Size, "Verdana", Obj_Color);
      } 
   
   ObjectSetText(OBJECT, PerChg, Font_Size, "Verdana", Obj_Color); 

  if(ObjectFind(OBJECT1) < 0)
      
      {
      ObjectCreate   (OBJECT1, OBJ_LABEL, 0, 0, 0);
      ObjectSet      (OBJECT1, OBJPROP_CORNER, Corner_Position_Arrow);
      ObjectSet      (OBJECT1, OBJPROP_YDISTANCE, X_Position_Arrow);
      ObjectSet      (OBJECT1, OBJPROP_XDISTANCE, Y_Position_Arrow);
      ObjectSetText  (OBJECT1, ArrowChg, Arrow_Size, "Wingdings 3", Obj_Color);
      } 
   
   ObjectSetText(OBJECT1, ArrowChg, Arrow_Size, "Wingdings 3", Obj_Color);  
   
   WindowRedraw();
   

}

//--- INIT AND DEINIT ------------------------------------- //

int init()
{
   
}


int deinit()
{
   ObjectDelete(OBJECT);
   ObjectDelete(OBJECT1);
}



