// + ----------------------------------------------- -------------------
// | VR --- STEALS-3.mq4 |
// | "Copyright 2014 , www.trading-go.ru Project." |
// | "Http://www.trading-go.ru" |
// + ----------------------------------------------- -------------------
#property copyright "Copyright 2014 , www.trading-go.ru Project."
#property link "http://www.trading-go.ru"
#property description " Invisible Counselor , allows to put not visible"
#property description "StopLoss, TakeProfit, Breakeven, Traling stop, OrderClose, OrderDelete"
#property strict
/*
                  WARNING !
ADVISOR operate even when the terminal MT4 bild 610 or Up

Advisor is designed for installation of virtual StopLoss, TakeProfit, Breakeven, Traling stop, OrderClose, OrderDelete
This is the third version of the Advisor VR --- STEALS
The first version builds 509 or below http://codebase.mql4.com/ru/7602
The second version builds 509 or below http://codebase.mql4.com/ru/8796
Since writing the first version has been more than three years , this version incorporates many requests
Traders using earlier versions of the advisor.
Copyright Adviser Voldemar. Skype: Voldemar227

System requirements:
MT4 build above 610
*/
// + ----------------------------------------------- -------------------
// | Inputs |
// + ----------------------------------------------- -------------------
// Starting exhibition
input double StartLot = 0.01;
// Start Virtual Take Profit in points
input int TakeProfit = 500 ;
// Virtual starter Stop Loss in points
input int StopLoss = 500 ;
// Start Virtual Trailing Stop in points
input int TralingStop = 300 ;
// Virtual starter breakeven in points
input int Breakeven = 300 ;
// Append the prefecture of graphic objects
input string prefix = "vr";
// Unique number of orders Adviser
input int Magic = 0 ;
// Slippage in points
input int Slip = 30 ;
// Cycle delay for demo or live accounts for weak PC 500 and above for PC moschny 50 and above
input int MilSec = 100 ;
// + ----------------------------------------------- -------------------
// ||
// + ----------------------------------------------- -------------------
string info []; // Array for messages on the chart
int Coment = 10; // Number of messages on the chart
color cvit []; // Array of colors for messages on the chart
int ButX = 17 ; // X coordinate of the buttons Adviser
int BuyY = 15 ; // Y coordinate of the buttons Adviser
int x = 0, // ​​x coordinate of the buttons Adviser
y = 0 ; // Y coordinate of the buttons Adviser
double tp = 0, // ​​Variable to take profit
sl = 0, // ​​Variable for Stop Loss
tr = 0, // ​​Variable for Trailing Stop
br = 0 ; // Variable for breakeven
double wlot = 0 ; // Variable for your status
// + ----------------------------------------------- -------------------
// ||
// + ----------------------------------------------- ------------------- + +
int OnInit ()
  {
   Comment (""); // Zeroed technical comment
   pr ("VR --- STEALS- 3 Started!!!"); // Announce the launch of Advisor
   if (StartLot <MarketInfo (Symbol (), MODE_MINLOT)) // verify the item for an error , if the item is less than the minimum set by the broker
      wlot = MarketInfo (Symbol (), MODE_MINLOT); // Set the correct minimum lot
   else wlot = StartLot; // If no errors lot then work your lot
   tp = NormalizeDouble (TakeProfit * _Point, _Digits); // Normalize the value to take profit
   sl = NormalizeDouble (StopLoss * _Point, _Digits); // Normalize the value for the Stop Loss
   tr = NormalizeDouble (TralingStop * _Point, _Digits); // Normalize the value for Trailing Stop
   br = NormalizeDouble (Breakeven * _Point, _Digits); // Normalize the value for breakeven
   return (INIT_SUCCEEDED); // Return the result of the OnInit () function
  }
// + ----------------------------------------------- -------------------
// ||
// + ----------------------------------------------- -------------------
void OnTick ()
  {
   if (IsOptimization ())
     { // Check if the user does not optimize , if optimizing the output
      Print (" It makes no sense ! "); // User disappoint as adviser does not sell itself and has no trading strategy
      return; // Perform optimization makes no sense. Report it and leave .
     }
   if (! IsTesting () &&! IsOptimization ()) // If this is not a tasting and optimization, we have a bigger impact demo or real
     {
      while (! IsStopped ())
        {// Fixated Advisor for faster until the user did not stop Adviser
         worc (); // Call the main function of advisor
         Sleep (MilSec); // After each iteration cycle pauses that would not download the PC processor
        }
     }
   else worc (); // If this is a tasting run in normal mode
  }
// + ----------------------------------------------- -------------------
// | The main function of advisor |
// + ----------------------------------------------- -------------------
void worc ()
  {
   but (); // This function creates a button Hidden Charm orders and lots of choice
   for (int i = OrdersTotal () -1; i>= 0 ; i--) // looping through the orders
      if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES)) // Parse warrants parts
         if (OrderMagicNumber () == Magic || Magic == -1) // Check for Meydzhik room
            if (OrderSymbol () == _Symbol) // Check for character trades
              {
               x = y = 0 ; // Reset variables
               ChartTimePriceToXY (0,0, (OrderOpenTime ()), OrderOpenPrice (), x, y); // Find the coordinates in pixels from the opening price and the opening time of the order
               button (StringConcatenate ("Sl", OrderTicket ()), x- 100 , y, "Sl", "StopLoss", ButX, BuyY); // Create button stop loss
               button (StringConcatenate ("Tp", OrderTicket ()), x- 80 , y, "Tp", "TakeProfit", ButX, BuyY); // Create a button take profit
               button (StringConcatenate ("Br", OrderTicket ()), x- 60 , y, "Br", "Breakeven", ButX, BuyY); // Create button bezubytka
               button (StringConcatenate ("Tr", OrderTicket ()), x- 40 , y, "Tr", "Ttrailing Stop", ButX, BuyY); // Create button trailing stop
               button (StringConcatenate ("Ti", OrderTicket ()), x- 20 , y, "Ti", "Time Close", ButX, BuyY); // Create a button for the lifetime of the order
               button (StringConcatenate ("X", OrderTicket ()), x, y, "X", "Close Order", ButX, BuyY); // Create a button closure / removal orders
              }
   for (int i = ObjectsTotal () -1; i>= 0 ; i--) // looping through the objects
      if (ObjectType (ObjectName (i)) == OBJ_BUTTON) // If the object fell button
         if (but_stat (ObjectName (i)) == true) // If the button is pressed
            ObjectSetInteger ( 0 , ObjectName (i), OBJPROP_BGCOLOR, clrLightGreen); // Repaint the green
   else
      ObjectSetInteger ( 0 , ObjectName (i), OBJPROP_BGCOLOR, C'230, 230,230 '); // If the button is pressed the button will return the native color

   for (int i = OrdersTotal () -1; i>= 0 ; i--) // looping through the orders
      if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES)) // Parse warrants parts
         if (OrderMagicNumber () == Magic || Magic == -1) // Check for Meydzhik room
            if (OrderSymbol () == _Symbol) // Check for character trades
              {
               if (but_stat (StringConcatenate (prefix, "X", OrderTicket ())) == true) // If pressed X
                  closeorders (OrderTicket ()); // Close the order or remove
               if (OrderType () == 0 || OrderType () == 2 || OrderType () == 4) // Work with warrants to purchase
                 {
                  if (but_stat (StringConcatenate (prefix, "Tp", OrderTicket ())) == true) // If pressed take profit
                     obj_cre (StringConcatenate ("tp", OrderTicket ()), (Ask + tp), clrGreen); // Create a graphic label
                  else
                     obj_del (StringConcatenate ("tp", OrderTicket ())); // If the button is pressed delete object

                  if (but_stat (StringConcatenate (prefix, "Sl", OrderTicket ())) == true) // If the button is pressed the stop loss
                     obj_cre (StringConcatenate ("sl", OrderTicket ()), (Bid-sl), clrRed); // Create a graphic label
                  else
                     obj_del (StringConcatenate ("sl", OrderTicket ())); // If the button is pressed delete object
                 }
               if (OrderType () == 1 || OrderType () == 3 || OrderType () == 5) // We work with sell orders
                 {
                  if (but_stat (StringConcatenate (prefix, "Tp", OrderTicket ())) == true) // If pressed take profit
                     obj_cre (StringConcatenate ("tp", OrderTicket ()), (Bid-tp), clrGreen); // Create a graphic label
                  else
                     obj_del (StringConcatenate ("tp", OrderTicket ())); // If the button is pressed delete object

                  if (but_stat (StringConcatenate (prefix, "Sl", OrderTicket ())) == true) // If the button is pressed the stop loss
                     obj_cre (StringConcatenate ("sl", OrderTicket ()), (Ask + sl), clrRed); // Create a graphic label
                  else
                     obj_del (StringConcatenate ("sl", OrderTicket ())); // If the button is pressed delete object
                 }
               if (but_stat (StringConcatenate (prefix, "Br", OrderTicket ())) == true) // If pressed bezubytka
                 {
                  if (((Ask-br)> OrderOpenPrice ()) && OrderType () == 0) // If the order to buy and the price is above a predetermined level
                     obj_cre (StringConcatenate ("br", OrderTicket ()), (OrderOpenPrice ()), clrGreen); // Create a graphic label

                  if (((Bid + br) <OrderOpenPrice ()) && OrderType () == 1 ) // If an order to sell and the price is below a predetermined level
                     obj_cre (StringConcatenate ("br", OrderTicket ()), (OrderOpenPrice ()), clrGreen); // Create a graphic label
                 }
               else obj_del (StringConcatenate ("br", OrderTicket ())); // If the button is pressed delete object

               if (but_stat (StringConcatenate (prefix, "Tr", OrderTicket ())) == true) // If pressed trailing stop
                 {
                  if (((Ask-tr)> OrderOpenPrice ()) && OrderType () == 0) // If the order to buy and the price is above a predetermined level
                     obj_cre (StringConcatenate ("tr", OrderTicket ()), (OrderOpenPrice ()), clrGreen); // Create a graphic label

                  if (((Bid + tr) <OrderOpenPrice ()) && OrderType () == 1 ) // If an order to sell and the price is below a predetermined level
                     obj_cre (StringConcatenate ("tr", OrderTicket ()), (OrderOpenPrice ()), clrGreen); // Create a graphic label
                 }
               else obj_del (StringConcatenate ("tr", OrderTicket ())); // If the button is pressed delete object

               if (but_stat (StringConcatenate (prefix, "Ti", OrderTicket ())) == true) // If pressed lifetime warrant
                  obj_cre_v_line (StringConcatenate ("ti", OrderTicket ()), clrGreen); // Create a vertical line
               else
                  obj_del (StringConcatenate ("ti", OrderTicket ())); // If the button is pressed delete object
              }

   his_del_obj (); // Remove obktov when closing orders
   proverca_sl_tp_ti (); // Check for the conditions on stop loss, take profit of , time
   proverca_br_tr (); // Check for the conditions on bezubytka , Trailing Stop
  }
// + ----------------------------------------------- -------------------
// ||
// + ----------------------------------------------- -------------------
bool proverca_br_tr ()
  {
   for (int i = OrdersTotal () -1; i>= 0 ; i--) // looping through the orders
      if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES)) // Parse warrants parts
         if (OrderMagicNumber () == Magic || Magic == -1) // Check for Meydzhik room
            if (OrderSymbol () == _Symbol) // Check for character trades
              {
               if (OrderType () == 0) // If the order Bai
                 {
                  if (ObjectFind (StringConcatenate ("br", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if (Bid <= get_object (StringConcatenate ("br", OrderTicket ()))) // If the price returned beyond Object
                        if (OrderClose (OrderTicket (), OrderLots (), Bid, Slip, clrRed) == true) // Close the order at bezubytka
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                  else
                     pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
                 }
               if (OrderType () == 1) // If the order Cell
                 {
                  if (ObjectFind (StringConcatenate ("br", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if (Ask>= get_object (StringConcatenate ("br", OrderTicket ()))) // If the price returned beyond Object
                        if (OrderClose (OrderTicket (), OrderLots (), Ask, Slip, clrRed) == true) // Close the order at bezubytka
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                  else
                     pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
                 }
               // ----------------------------- //
               if (OrderType () == 0) // If the order Bai
                 {
                  if (ObjectFind (StringConcatenate ("tr", OrderTicket ())) == 0) // If the object is created and the conditions are met
                    {
                     if ((Bid-tr)> get_object (StringConcatenate ("tr", OrderTicket ()))) // If the price rises
                        set_object (StringConcatenate ("tr", OrderTicket ()), (Ask-tr)); // Move obkt trailing stop
                     if (Bid <= get_object (StringConcatenate ("tr", OrderTicket ()))) // If the price returned beyond Object
                        if (OrderClose (OrderTicket (), OrderLots (), Bid, Slip, clrRed) == true) // Close the trailing stop order
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                     else
                        pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
                    }
                 }
               if (OrderType () == 1) // If the order Cell
                 {
                  if (ObjectFind (StringConcatenate ("tr", OrderTicket ())) == 0) // If the object is created and the conditions are met
                    {
                     if ((Ask + tr) <get_object (StringConcatenate ("tr", OrderTicket ()))) // If the price falls
                        set_object (StringConcatenate ("tr", OrderTicket ()), (Bid + tr)); // Move obkt trailing stop
                     if (Ask>= get_object (StringConcatenate ("tr", OrderTicket ()))) // If the price returned beyond Object
                        if (OrderClose (OrderTicket (), OrderLots (), Ask, Slip, clrRed) == true) // Close the trailing stop order
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                     else
                        pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
                    }
                 }
              }
   return false;
  }
// + ----------------------------------------------- -------------------
// | Function moves the object by name, and the new price |
// + ----------------------------------------------- -------------------
bool set_object (string name, double pri)
  {
   return ObjectSetDouble ( 0 , name, OBJPROP_PRICE, pri); // Function moves the object by name, and the new price
  }
// + ----------------------------------------------- -------------------
// ||
// + ----------------------------------------------- -------------------
bool proverca_sl_tp_ti ()
  {
   for (int i = OrdersTotal () -1; i>= 0 ; i--) // Iterate orders
      if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES)) // Parse warrant component parts
         if (OrderMagicNumber () == Magic || Magic == -1) // if our Magic
            if (OrderSymbol () == _Symbol) // if our character
              {
               if (OrderType () == 0) // If the order Bai
                 {
                  if (ObjectFind (StringConcatenate ("tp", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if (Bid> get_object (StringConcatenate ("tp", OrderTicket ()))) // If the price is above the object takeprofit
                        if (OrderClose (OrderTicket (), OrderLots (), Bid, Slip, clrRed) == true) // Close the order
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                  else
                     pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message

                  if (ObjectFind (StringConcatenate ("sl", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if (Bid <get_object (StringConcatenate ("sl", OrderTicket ()))) // If the price is below the stop loss Object
                        if (OrderClose (OrderTicket (), OrderLots (), Bid, Slip, clrRed) == true) // Close the order
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                  else
                     pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message

                  if (ObjectFind (StringConcatenate ("ti", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if ((int) TimeCurrent ()> (int) get_object_ti (StringConcatenate ("ti", OrderTicket ()))) // If the time is longer warrant Object Life
                        if (OrderClose (OrderTicket (), OrderLots (), Bid, Slip, clrRed) == true) // Close the order
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                  else
                     pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
                 }
               if (OrderType () == 1)
                 {
                  if (ObjectFind (StringConcatenate ("tp", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if (Ask <get_object (StringConcatenate ("tp", OrderTicket ()))) // If the price is below the object takeprofit
                        if (OrderClose (OrderTicket (), OrderLots (), Ask, Slip, clrRed) == true) // Close the order
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                  else
                     pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message

                  if (ObjectFind (StringConcatenate ("sl", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if (Ask> get_object (StringConcatenate ("sl", OrderTicket ()))) // If the price is above the object stop loss
                        if (OrderClose (OrderTicket (), OrderLots (), Ask, Slip, clrRed) == true) // Close the order
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                  else
                     pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message

                  if (ObjectFind (StringConcatenate ("ti", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if ((int) TimeCurrent ()> (int) get_object_ti (StringConcatenate ("ti", OrderTicket ()))) // If the time is longer warrant Object Life
                        if (OrderClose (OrderTicket (), OrderLots (), Ask, Slip, clrRed) == true) // Close the order
                           pr ("Order close Ok!!!"); // If successful, we will report on the chart
                  else
                     pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
                 }
               if (OrderType ()> 1)
                  if (ObjectFind (StringConcatenate ("ti", OrderTicket ())) == 0) // If the object is created and the conditions are met
                     if ((int) TimeCurrent ()> (int) get_object_ti (StringConcatenate ("ti", OrderTicket ()))) // If the time is longer warrant Object Life
                        if (OrderDelete (OrderTicket (), clrRed) == true) // delete the order
                           pr ("Order delete Ok!!!"); // If successful, we will report on the chart
               else
                  pr ("Order delete Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
              }
   return false;
  }
// + ----------------------------------------------- -------------------
// | The function returns a time object lifetime orders |
// + ----------------------------------------------- -------------------
datetime get_object_ti (string name)
  {
   return (datetime) ObjectGetInteger ( 0 , name, OBJPROP_TIME);
  }
// + ----------------------------------------------- -------------------
// | Function vzvraschaet price Object |
// + ----------------------------------------------- -------------------
double get_object (string name)
  {
   return ObjectGetDouble ( 0 , name, OBJPROP_PRICE);
  }
// + ----------------------------------------------- -------------------
// | Function creates object lifetime orders |
// + ----------------------------------------------- -------------------
void obj_cre_v_line(string txt,color col)
  {
   if(ObjectFind(0,txt)==-1)
     {
      ObjectCreate(0,txt,OBJ_VLINE,0,Time[0]+_Period*10*60,0);
      ObjectSetInteger(0,txt,OBJPROP_TIME,Time[0]+_Period*10*60);
      ObjectSetInteger(0,txt,OBJPROP_COLOR,col);
      ObjectSetInteger(0,txt,OBJPROP_WIDTH,2);
      ObjectSetString(0,txt,OBJPROP_TOOLTIP,txt);
      WindowRedraw();
     }
  }
// + ----------------------------------------------- -------------------
// | Function creates obek graphic label |
// + ----------------------------------------------- -------------------
void obj_cre (string txt, double pri, color col)
  {
   if (ObjectFind ( 0 , txt) == -1)
     {
      ObjectCreate ( 0 , txt, OBJ_ARROW_RIGHT_PRICE, 0 , Time [ 0 ], pri);
      ObjectSetInteger ( 0 , txt, OBJPROP_TIME, Time [ 0]);
      ObjectSetDouble ( 0 , txt, OBJPROP_PRICE, pri);
      ObjectSetInteger ( 0 , txt, OBJPROP_COLOR, col);
      ObjectSetInteger ( 0 , txt, OBJPROP_WIDTH, 3);
      ObjectSetString ( 0 , txt, OBJPROP_TOOLTIP, txt);
      WindowRedraw ();
     }
  }
// + ----------------------------------------------- -------------------
// | Function removes the object by name |
// + ----------------------------------------------- -------------------
void obj_del (string txt)
  {
   ObjectDelete ( 0 , txt);
  }
// + ----------------------------------------------- -------------------
// | Function removes objects and complete execution of orders |
// + ----------------------------------------------- -------------------
void his_del_obj ()
  {
   for (int i = OrdersHistoryTotal () -1; i>= 0 ; i--)
      if (OrderSelect (i, SELECT_BY_POS, MODE_HISTORY))
         if (OrderMagicNumber () == Magic || Magic == -1)
            if (OrderSymbol () == _Symbol)
              {
               ObjectDelete ( 0 , StringConcatenate (prefix, "Sl", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate (prefix, "Tp", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate (prefix, "Br", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate (prefix, "Tr", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate (prefix, "Ti", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate (prefix, "X", OrderTicket ()));

               ObjectDelete ( 0 , StringConcatenate ("sl", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate ("tp", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate ("br", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate ("tr", OrderTicket ()));
               ObjectDelete ( 0 , StringConcatenate ("ti", OrderTicket ()));

              }
  }
// + ----------------------------------------------- -------------------
// | Function closes an order for tikketu or delete a pending order |
// + ----------------------------------------------- -------------------
bool closeorders (int tik)
  {
   string sy = "";
   if (OrderSelect (tik, SELECT_BY_TICKET))
      if (OrderMagicNumber () == Magic || Magic == -1)
         if (OrderSymbol () == _Symbol)
            if (OrderTicket () == tik)
              {
               sy = OrderSymbol ();
               if (OrderType () == 0) // If the order Bai
                  if (OrderClose (OrderTicket (), OrderLots (), MarketInfo (sy, MODE_BID), Slip, clrRed) == true)
                     pr ("Order close Ok!!!"); // If successful, we will report on the chart
               else
                  pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message

               if (OrderType () == 1) // If the order Cell
                  if (OrderClose (OrderTicket (), OrderLots (), MarketInfo (sy, MODE_ASK), Slip, clrRed) == true)
                     pr ("Order close Ok!!!"); // If successful, we will report on the chart
               else
                  pr ("Order close Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
               if (OrderType ()> 1) // If the Pending
                  if (OrderDelete (tik, clrRed) == true) // delete the order
                     pr ("Order delete Ok!!!"); // If successful, we will report on the chart
               else
                  pr ("Order delete Error!!!" + Error (GetLastError ()), clrRed); // If it fails, return an error message
              }
   return false;
  }
// + ----------------------------------------------- -------------------
// ||
// + ----------------------------------------------- -------------------
void but ()
  {
   double Dist = NormalizeDouble ( 500 * _Point, _Digits); // Distance to defaults to set pending orders
   button ("LOTS", 5,40, "LOTS" + DoubleToStr (wlot, 2 ), "LOTS", 100,20); // Create a button to select lots
   button ("BUY", 5,65, "BUY", "BUY", 100,20); // Create button to open the warrant Bai
   button ("SEL", 5,90, "SEL", "SEL", 100,20); // Create a button to open a Sell Order
   button ("BUY L", 5,115, "BUY L", "BUY LIMIT", 100,20); // Create a button to open a Buy Limit order
   button("SELL L",5,140,"SELL L ","SELL LIMIT",100,20);  // Create a button to open a Sell Limit Order
   button ("BUY S", 5,165, "BUY S", "BUY STOP", 100,20); // Create a button to open a Buy Stop order
   button ("SELL S", 5,190, "SELL S", "SELL STOP", 100,20); // Create a button to open a Sell Stop orders
   if (but_stat (prefix + "BUY") == true) // If pressed Bai
      if (openorders (_Symbol, 0 , wlot) == true) // Open the warrant
         button_off ("BUY"); // Translate button in the disabled state
   if (but_stat (prefix + "SEL") == true) // If pressed Cell
      if (openorders (_Symbol, 1 , wlot) == true) // Open the warrant
         button_off ("SEL"); // Translate button in the disabled state
   if (but_stat (prefix + "BUY L") == true) // If pressed Buy Limit
      if (openorders (_Symbol, 2 , wlot, Ask-Dist) == true) // Open the warrant
         button_off ("BUY L"); // Translate button in the disabled state
   if (but_stat (prefix + "SELL L") == true) // If pressed Sell Limit
      if (openorders (_Symbol, 3 , wlot, Bid + Dist) == true) // Open the warrant
         button_off ("SELL L"); // Translate button in the disabled state
   if (but_stat (prefix + "BUY S") == true) // If pressed Buy Stop
      if (openorders (_Symbol, 4 , wlot, Ask + Dist) == true) // Open the warrant
         button_off ("BUY S"); // Translate button in the disabled state
   if (but_stat (prefix + "SELL S") == true) // If pressed Sell Stop
      if (openorders (_Symbol, 5 , wlot, Bid-Dist) == true) // Open the warrant
         button_off ("SELL S"); // Translate button in the disabled state

   if (but_stat (prefix + "LOTS") == true) // If pressed lots of choice
     {
      if (StartLot <MarketInfo (Symbol (), MODE_MINLOT)) // verify the item for an error
         wlot = MarketInfo (Symbol (), MODE_MINLOT); // In case of error set the minimum lot razreshonny
      else wlot = StartLot; // If no error work installed, you lot
      for (int i = 0 ; i <= 20 ; i ++) // Create a series of 20 objects
        {
         button (StringConcatenate ("lot", i), 120,40 +18 * i, DoubleToStr (wlot * (i +1), 2 ), "LOTS", 50,15); // Draw 20 selection buttons with lots of lots
         if (but_stat (StringConcatenate (prefix, "lot", i)) == true) // define which button is pressed
           {
            wlot = wlot * (i +1); // Remember Lot buttons
            button_off (StringConcatenate ("lot", i)); // Press the button to select the lots selected lot
            button_off ("LOTS"); // Press the button to select the lots
           }
        }
     }
   else
   for (int xx = 0 ; xx <= 20 ; xx ++) // If the button is pressed lots of choice
              ObjectDelete (StringConcatenate (prefix, "lot", xx)); // Remove item selection buttons 20
  }
// + ----------------------------------------------- -------------------
// | The function returns the state of the button |
// + ----------------------------------------------- -------------------
bool but_stat (string name)
  {
   name = StringConcatenate (name);
   if (ObjectGetInteger ( 0 , name, OBJPROP_STATE) == true)
      return true;
   return false;
  }
// + ----------------------------------------------- -------------------
// | The function returns the state of the button to its original state |
// + ----------------------------------------------- -------------------
bool button_off (string name)
  {
   name = StringConcatenate (prefix, name);
   if (ObjectSetInteger ( 0 , name, OBJPROP_STATE, false) == true)
      return true; return false;
  }
// + ----------------------------------------------- -------------------
// | Function creates a button |
// + ----------------------------------------------- -------------------
bool button (string name, int xx, int yy, string text, string tool, int widch = 200 , int heigt = 20 , color coltx = C'80, 80,80 ', color colbg = C'230, 230,230', int cor = 0)
  {
   string txt = StringConcatenate (prefix, name);
   if (ObjectFind (txt) == -1)
     {
      ObjectCreate ( 0 , txt, OBJ_BUTTON, 0,0,0);
      ObjectSetInteger ( 0 , txt, OBJPROP_CORNER, cor);
      ObjectSetInteger ( 0 , txt, OBJPROP_BGCOLOR, colbg);
     }
   ObjectSetInteger ( 0 , txt, OBJPROP_XDISTANCE, xx);
   ObjectSetInteger ( 0 , txt, OBJPROP_YDISTANCE, yy);
   ObjectSetString ( 0 , txt, OBJPROP_TEXT, text);
   ObjectSetString ( 0 , txt, OBJPROP_TOOLTIP, tool);
   ObjectSetInteger ( 0 , txt, OBJPROP_XSIZE, widch);
   ObjectSetInteger ( 0 , txt, OBJPROP_YSIZE, heigt);
   ObjectSetString ( 0 , txt, OBJPROP_FONT, "Arial");
   ObjectSetInteger ( 0 , txt, OBJPROP_COLOR, coltx);
   ObjectSetInteger ( 0 , txt, OBJPROP_BORDER_COLOR, C'80, 80,80 ');
   ChartRedraw ();
   return true;
  }
// + ----------------------------------------------- -------------------
// | Function opens orders |
// + ----------------------------------------------- -------------------
bool openorders (string sy = "", int typ = 0 , double lot = 0 , double price = 0 , string com = "") // Function discovery orders
  {
   int tik = -2, p = 0 ; // Variables for
   if (sy == "") sy = _Symbol; // If the character is not specified take the chart symbol
   if (lot <MarketInfo (sy, MODE_MINLOT)) lot = MarketInfo (sy, MODE_MINLOT); // If the item is not set create a minimum lot
   if (price == 0) // If the price is not indicated
     {
      if (typ == 0 ) price = MarketInfo (sy, MODE_ASK); // For bais Quote by symbol
      else price = MarketInfo (sy, MODE_BID); // For Sellonian Quote by symbol
     }
   if (com == "") com = StringConcatenate (WindowExpertName (), "", Magic); // Comment warrant Name + Magic adviser Adviser

   while (IsTradeAllowed ()) // If free trade flow
     {
      tik=OrderSend(sy,typ,NormalizeDouble(lot,2),NormalizeDouble(price,(int)MarketInfo(sy,MODE_DIGITS)),Slip,0,0,com,Magic,0,clrBlue); // Open the warrant
      if (tik>= 0 ) {pr ("Order Open Ok!!!"); return true;} // If success will come from the function
      else // If not luck
        {
         p ++; // Increase the count by 1
         pr (__FUNCTION__ + "_Error_" + Error (GetLastError ()), clrRed); // Reported in the Journal
         Sleep ( 500) ; // Wait for half a second and try again
         if (p>= 5 ) {Print (__FUNCTION__, " Problems with trade flows ", sy, "", lot, "", price, "Error N", GetLastError ()); return false;} // If the count is greater than or equal to 5 will come out of the failure function
        }
     }
   return false;
  }
// + ----------------------------------------------- -------------------
// | |
// + ----------------------------------------------- -------------------
void OnDeinit (const int reason)
  {
   for (int k = ObjectsTotal () -1; k>= 0 ; k--) // If the output from the EA
      if (StringSubstr (ObjectName (k), 0,2) == prefix) // find all the objects Adviser
         ObjectDelete (ObjectName (k)); // Remove objects with our prefix
   Comment(WindowExpertName()+" successfully deinitialized !   ",getUninitReasonText(_UninitReason)); // Leave a message on the chart with the cause deinitialization Adviser
  }
// + ----------------------------------------------- -------------------
// | The function returns the reason deinitialization advisor |
// + ----------------------------------------------- -------------------
string getUninitReasonText(int reasonCode)
  {
   string text="";
   bool Lan=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian");
   switch(reasonCode)
     {
      case 0: if(Lan)
         text="Эксперт прекратил свою работу, вызвав функцию ExpertRemove()";   break;
         text="Account was changed";                                            break;
      case 1: if(Lan)
         text="Программа удалена с графика";                                    break;
         text="Program "+__FILE__+" was removed from chart";                    break;
      case 2: if(Lan)
         text="Программа перекомпилирована";                                    break;
         text="Program "+__FILE__+" was recompiled";                            break;
      case 3: if(Lan)
         text="Символ или период графика был изменен";                          break;
         text="Symbol or timeframe was changed";                                break;
      case 4: if(Lan)
         text="График закрыт";                                                  break;
         text="Chart was closed";                                               break;
      case 5: if(Lan)
         text="Входные параметры были изменены пользователем";                  break;
         text="Input-parameter was changed";                                    break;
      case 6: if(Lan)
         text="Переподключение к торговому серверу ";                           break;
         text="Reconnect to the trading server";                                break;
      case 7: if(Lan)
         text="Применен другой шаблон графика";                                 break;
         text="New template was applied to chart";                              break;
      case 8: if(Lan)
         text="Признак того, что обработчик OnInit() вернул ненулевое значение";break;
         text="A sign that the handler OnInit() returned non-zero value";       break;
      case 9: if(Lan)
         text="Терминал был закрыт";                                            break;
         text="The terminal was closed";                                        break;
      default:if(Lan)
         text="Причина деинициализации программы не известна";
         text="Another reason";
     }
   return text;
  }
//+------------------------------------------------------------------+
//| Function displays messages on the chart                          |
//+------------------------------------------------------------------+
void pr(string txt,color cvet=C'80,80,80')
  {
   txt=StringConcatenate(StringSubstr(TimeS(),11,8))+" - "+txt;
   ArrayResize(info,Coment,1000); ArrayResize(cvit,Coment,1000);
   for(int i=Coment-1; i>0; i--)
     {
      if(info[i]!=info[i-1]) info[i]=info[i-1];
      if(cvit[i]!=cvit[i-1]) cvit[i]=cvit[i-1];
     }
   if(info[0]!=txt && txt!=""){ info[0]=txt; cvit[0]=cvet; }
   for(int i=0; i<Coment; i++)
      button(StringConcatenate("Error",i),250+252*i,16,info[i],info[i],250,15,cvit[i],C'230,230,230',3);
  }
//+------------------------------------------------------------------+
//| The function returns the time for messages on the chart          |
//+------------------------------------------------------------------+
string TimeS()
  {
   datetime Cur=0;
   Cur=TimeCurrent();
   RefreshRates();
   return StringFormat("%02d.%02d.%02d %02d-%02d-%02d",TimeYear(Cur),TimeMonth(Cur),TimeDay(Cur),TimeHour(Cur),TimeMinute(Cur),TimeSeconds(Cur));
  }
//+------------------------------------------------------------------+
//| Uncomment the function number error Adviser                      |
//+------------------------------------------------------------------+
string Error(int error_code)
  {
   string error_string;
   switch(error_code)
     {
      case 0:   error_string="No error returned.";                                                            break;
      case 1:   error_string="No error returned, but the result is unknown.";                                 break;
      case 2:   error_string="Common error.";                                                                 break;
      case 3:   error_string="Invalid trade parameters.";                                                     break;
      case 4:   error_string="Trade server is busy.";                                                         break;
      case 5:   error_string="Old version of the client terminal.";                                           break;
      case 6:   error_string="No connection with trade server.";                                              break;
      case 7:   error_string="Not enough rights.";                                                            break;
      case 8:   error_string="Too frequent requests.";                                                        break;
      case 9:   error_string="Malfunctional trade operation.";                                                break;
      case 64:  error_string="Account disabled.";                                                             break;
      case 65:  error_string="Invalid account.";                                                              break;
      case 128: error_string="Trade timeout.";                                                                break;
      case 129: error_string="Invalid price.";                                                                break;
      case 130: error_string="Invalid stops.";                                                                break;
      case 131: error_string="Invalid trade volume.";                                                         break;
      case 132: error_string="Market is closed.";                                                             break;
      case 133: error_string="Trade is disabled.";                                                            break;
      case 134: error_string="Not enough money.";                                                             break;
      case 135: error_string="Price changed.";                                                                break;
      case 136: error_string="Off quotes.";                                                                   break;
      case 137: error_string="Broker is busy.";                                                               break;
      case 138: error_string="Requote.";                                                                      break;
      case 139: error_string="Order is locked.";                                                              break;
      case 140: error_string="Long positions only allowed.";                                                  break;
      case 141: error_string="Too many requests.";                                                            break;
      case 145: error_string="Modification denied because an order is too close to market.";                  break;
      case 146: error_string="Trade context is busy.";                                                        break;
      case 147: error_string="Expirations are denied by broker.";                                             break;
      case 148: error_string="The amount of opened and pending orders has reached the limit set by a broker.";break;
      case 4000: error_string="No error.";                                                                    break;
      case 4001: error_string="Wrong function pointer.";                                                      break;
      case 4002: error_string="Array index is out of range.";                                                 break;
      case 4003: error_string="No memory for function call stack.";                                           break;
      case 4004: error_string="Recursive stack overflow.";                                                    break;
      case 4005: error_string="Not enough stack for parameter.";                                              break;
      case 4006: error_string="No memory for parameter string.";                                              break;
      case 4007: error_string="No memory for temp string.";                                                   break;
      case 4008: error_string="Not initialized string.";                                                      break;
      case 4009: error_string="Not initialized string in an array.";                                          break;
      case 4010: error_string="No memory for an array string.";                                               break;
      case 4011: error_string="Too long string.";                                                             break;
      case 4012: error_string="Remainder from zero divide.";                                                  break;
      case 4013: error_string="Zero divide.";                                                                 break;
      case 4014: error_string="Unknown command.";                                                             break;
      case 4015: error_string="Wrong jump.";                                                                  break;
      case 4016: error_string="Not initialized array.";                                                       break;
      case 4017: error_string="DLL calls are not allowed.";                                                   break;
      case 4018: error_string="Cannot load library.";                                                         break;
      case 4019: error_string="Cannot call function.";                                                        break;
      case 4020: error_string="EA function calls are not allowed.";                                           break;
      case 4021: error_string="Not enough memory for a string returned from a function.";                     break;
      case 4022: error_string="System is busy.";                                                              break;
      case 4050: error_string="Invalid function parameters count.";                                           break;
      case 4051: error_string="Invalid function parameter value.";                                            break;
      case 4052: error_string="String function internal error.";                                              break;
      case 4053: error_string="Some array error.";                                                            break;
      case 4054: error_string="Incorrect series array using.";                                                break;
      case 4055: error_string="Custom indicator error.";                                                      break;
      case 4056: error_string="Arrays are incompatible.";                                                     break;
      case 4057: error_string="Global variables processing error.";                                           break;
      case 4058: error_string="Global variable not found.";                                                   break;
      case 4059: error_string="Function is not allowed in testing mode.";                                     break;
      case 4060: error_string="Function is not confirmed.";                                                   break;
      case 4061: error_string="Mail sending error.";                                                          break;
      case 4062: error_string="String parameter expected.";                                                   break;
      case 4063: error_string="Integer parameter expected.";                                                  break;
      case 4064: error_string="Double parameter expected.";                                                   break;
      case 4065: error_string="Array as parameter expected.";                                                 break;
      case 4066: error_string="Requested history data in updating state.";                                    break;
      case 4067: error_string="Some error in trade operation execution.";                                     break;
      case 4099: error_string="End of a file.";                                                               break;
      case 4100: error_string="Some file error.";                                                             break;
      case 4101: error_string="Wrong file name.";                                                             break;
      case 4102: error_string="Too many opened files.";                                                       break;
      case 4103: error_string="Cannot open file.";                                                            break;
      case 4104: error_string="Incompatible access to a file.";                                               break;
      case 4105: error_string="No order selected.";                                                           break;
      case 4106: error_string="Unknown symbol.";                                                              break;
      case 4107: error_string="Invalid price.";                                                               break;
      case 4108: error_string="Invalid ticket.";                                                              break;
      case 4109: error_string="Trade is not allowed.";                                                        break;
      case 4110: error_string="Longs are not allowed.";                                                       break;
      case 4111: error_string="Shorts are not allowed.";                                                      break;
      case 4200: error_string="Object already exists.";                                                       break;
      case 4201: error_string="Unknown object property.";                                                     break;
      case 4202: error_string="Object does not exist.";                                                       break;
      case 4203: error_string="Unknown object type.";                                                         break;
      case 4204: error_string="No object name.";                                                              break;
      case 4205: error_string="Object coordinates error.";                                                    break;
      case 4206: error_string="No specified subwindow.";                                                      break;
      default:   error_string="Some error in object operation.";
     }
   return(error_string);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
