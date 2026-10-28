//+------------------------------------------------------------------+
//|                                                   BreakPoint.mqh |
//|                        Copyright 2017, NetrillioN Software Corp. |
//|                                       https://www.netrillion.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, NetrillioN Software Corp."
#property link      "https://www.netrillion.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
string buttonID="Button"; 
string labelID="Info"; 
string stime_arr[];

//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+



 //+------------------------------------------------------------------+
//|  CheckButton  
//+------------------------------------------------------------------+
/*
  Check if the pause button was clicked.
*/
string CheckButton()
{
 string bstate="paused";
   if( ( ObjectGetInteger( 0, buttonID, OBJPROP_STATE ) ) == true )
   {
    bstate = "go";
    ObjectSetString(0,labelID,OBJPROP_TEXT,"released");
    ObjectSetInteger( 0, buttonID, OBJPROP_STATE, false );
   }
   else
   {
    bstate = "paused";
    ObjectSetString(0,labelID,OBJPROP_TEXT," Paused - (Click GO Button to Release)");
   }
 return bstate;
}

//+------------------------------------------------------------------+
//|  End of CheckButton  
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|  BreakPoint  
//+------------------------------------------------------------------+
/*
  This will stop execution when a condition is true or when a valid time is reachd.
  If a stop time is set then the condition will be ignored. 
  Chart window must be activated first and after clicking button.
  
 example useage(1):

//some code you may have somewhere and you just want to observe what is the value of the variable "oranges"
int apples = 5;
int oranges = 3;
BreakPoint("","","",true,"oranges",IntegerToString(oranges));// the execution will stop here.
//the values will be displayed on the current chart.
int grapes = 1;
//the chart will show oranges : 3 
  
example useage(2):

//some code you may have somewhere and you just want to observe what is the value of the variable "oranges"
// at a specific backtest time "2018.10.22 12:00"
int peaches = 4;
int oranges = 11;
BreakPoint("","2018.10.22 12:00","",false,"oranges",IntegerToString(oranges));//the execution stops here.
//the values displayed on the chart when backtest time in Strategy Tester reaches "2018.10.22 12:00".
int carrots = 7;
//the chart will show oranges : 11  


example useage(3):

//some code you may have somewhere and you just want to observe what is the value of the variable "on_off"
bool on_off= false;
int oranges = 11;
 
//... some code here that would have caused "on_off" to change to true...
BreakPoint("","","on_off",on_off,"oranges",IntegerToString(oranges));// the execution will stop here ONLY when on_off is true. Otherwise execution will proceed as normal.
 
//the chart will show 
on_off : 1
oranges : 11
  
*/
bool BreakPoint(
string mode="",
string StopTimeStr="1979.09.22 12:30",
string aConditionStr="",
bool aCondition=false,
string aVariable1name="",string aVariable1="",
string aVariable2name="",string aVariable2="",
string aVariable3name="",string aVariable3="",
string aVariable4name="",string aVariable4="",
string aVariable5name="",string aVariable5="",
string aVariable6name="",string aVariable6="",
string aVariable7name="",string aVariable7="",
string aVariable8name="",string aVariable8="")
{
 string dstr;
 bool fnd=false,reslt=false,validmode=false,validbool=false,validtime=false;
 datetime current_time=TimeCurrent();
 datetime stime = StrToTime(StopTimeStr);
 int j=0, arrsz=ArrayRange(stime_arr,0);

    //search for timestr
    while(j<arrsz && arrsz>0)
    {
        if(stime_arr[j] == StopTimeStr)fnd = true;
     j++;
    }
    //ensure valid mode
    if( IsVisualMode() == true || mode == "test") 
    {
     validmode = true;
    }   
    
    //ensure valid bool
    if(aCondition == true && StopTimeStr == "")
    {
     validbool = true;
    }

    //esnsure valid time   
    if(StopTimeStr != "" && fnd == false) 
    {  
        if(StopTimeStr != "" && current_time > stime)dstr = StringConcatenate(dstr,"StopTime already passed.");
        if(current_time <= stime)
        {
         validbool = false;
            if(current_time == stime)
            {
             validtime = true;
             ObjectDelete("current_breakpoint");
             ObjectCreate("current_breakpoint",OBJ_VLINE,0,iTime(NULL,0,0), 0/* 1.0045 */);
            }          
        }    
    }
    
    //decision point
    if(validmode == true && (validtime == true || validbool == true))
    {
     //setup the interface but do nothing
     create_debug_interface();    
    }
    else
    {
     return(reslt);    
    }
     //setup display variables
    if(aVariable1name != "" && aVariable1 != "")dstr = StringConcatenate(dstr,"\n",aVariable1name," : ",aVariable1,"\n");
    if(aVariable2name != "" && aVariable2 != "")dstr = StringConcatenate(dstr,"\n",aVariable2name," : ",aVariable2,"\n");
    if(aVariable3name != "" && aVariable3 != "")dstr = StringConcatenate(dstr,"\n",aVariable3name," : ",aVariable3,"\n");
    if(aVariable4name != "" && aVariable4 != "")dstr = StringConcatenate(dstr,"\n",aVariable4name," : ",aVariable4,"\n");
    if(aVariable5name != "" && aVariable5 != "")dstr = StringConcatenate(dstr,"\n",aVariable5name," : ",aVariable5,"\n");
    if(aVariable6name != "" && aVariable6 != "")dstr = StringConcatenate(dstr,"\n",aVariable6name," : ",aVariable6,"\n");
    if(aVariable7name != "" && aVariable7 != "")dstr = StringConcatenate(dstr,"\n",aVariable7name," : ",aVariable7,"\n");
    if(aVariable8name != "" && aVariable8 != "")dstr = StringConcatenate(dstr,"\n",aVariable8name," : ",aVariable8,"\n");        
                    
 //display all provided variables
 Comment(dstr);

 //pause here
 string astate = "paused";
    while(astate != "go")
    {  
     astate = CheckButton();
    } 
dstr = "";      
Comment(dstr);      
remove_debug_interface();
 return(reslt);
}
//+------------------------------------------------------------------+
//|  End of BreakPoint  
//+------------------------------------------------------------------+

 
 
 
 
//+------------------------------------------------------------------+
//|  remove_debug_interface  
//+------------------------------------------------------------------+
/*
  Delete  button and the label.
*/ 
void remove_debug_interface()
{
   ObjectDelete(0,buttonID); 
   ObjectDelete(0,labelID);  
}
//+------------------------------------------------------------------+
//|  End of remove_debug_interface  
//+------------------------------------------------------------------+
 
 
 
//+------------------------------------------------------------------+
//|  create_debug_interface  
//+------------------------------------------------------------------+
/*
  Creat a button and a label when in "test" or visual(strategy tester) mode.
*/
void create_debug_interface(string mode="")
{
    //ensure valid mode
    if( IsVisualMode() == true || mode == "test") 
    {
     //--- Create a button to send custom events 
     ObjectCreate(0,buttonID,OBJ_BUTTON,0,100,100); 
     ObjectSetInteger(0,buttonID,OBJPROP_COLOR,clrWhite); 
     ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,clrGray); 
     ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,100); 
     ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,100); 
     ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,50);//button length 
     ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,50);//button hieght 
     ObjectSetString(0,buttonID,OBJPROP_FONT,"Arial"); 
     ObjectSetString(0,buttonID,OBJPROP_TEXT,"GO"); 
     ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,10); 
     ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0); 
  
     //--- Create a label for displaying information 
     ObjectCreate(0,labelID,OBJ_LABEL,0,200,200); 
     ObjectSetInteger(0,labelID,OBJPROP_COLOR,clrRed); 
     ObjectSetInteger(0,labelID,OBJPROP_XDISTANCE,100); 
     ObjectSetInteger(0,labelID,OBJPROP_YDISTANCE,50); 
     ObjectSetString(0,labelID,OBJPROP_FONT,"Trebuchet MS"); 
     ObjectSetString(0,labelID,OBJPROP_TEXT," Paused - (Click GO Button to Release)"); 
     ObjectSetInteger(0,labelID,OBJPROP_FONTSIZE,20); 
     ObjectSetInteger(0,labelID,OBJPROP_SELECTABLE,0); 
    }
}
//+------------------------------------------------------------------+
//|  End of create_debug_interface  
//+------------------------------------------------------------------+


 



