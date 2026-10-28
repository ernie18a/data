//+------------------------------------------------------------------+
//|                                          MD5.Cloud.Decryptor.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, MetaQuotes Software Corp."
#property link        "https://forge.mql5.io"
#property version     "1.00"
#property description "This example features the principles of the mechanism of custom data frame transmission"
#property description "from agents during a brute force search aimed at finding MD5 hashes."
#property description "\n"
#property description "The speed characteristics of the computing network and the progress"
#property description "are shown in real time. "
#property description ""

#include "MD5.Visualizer.mqh"
#include "MD5.Scanner.mqh"

//--- input parameters
sinput int                 PasswordLengthFrom   =6;                          // Password Length From
sinput int                 PasswordLengthTo     =6;                          // Password Length To
sinput BruteForceEnumType  BruteforceType       =BRUTEFORCE_SET_ASCII_DIGITS;// Bruteforce Attack Charset 
sinput string              BruteforceCharacters ="";                         // Bruteforce Custom Charset 

sinput HashEnumType        HashType=HASH_TYPE_SINGLE;                        // Hash Type
sinput string              HashList="ab4f63f9ac65152575886860dde480a1";      // Hash Source of azerty
                                                                             // MD5 hash or filename (1 hash in line)
sinput long                Counter=0;

//---
CMD5Visualizer *ExtVisualizer=NULL;
CMD5Scanner     ExtScanner;
//--- Master expert on the chart
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
   double passes=0.0;
//--- Calculating the limits
   if(!ExtScanner.CalculatePasses(PasswordLengthFrom,PasswordLengthTo,BruteforceType,BruteforceCharacters,passes))
      return;

   ParameterSetRange("Counter",true,0,0,1,1+long(passes/MIN_SCAN_PART));
//--- Creating the visualizer 
   if(ExtVisualizer==NULL)
      ExtVisualizer=new CMD5Visualizer;
//--- Initializing it
   ExtVisualizer.Initialize();
//--- Setting the correct size
   long   lparam=0;
   double dparam=0.0;
   string sparam="";

   ExtVisualizer.OnEvent(CHARTEVENT_CHART_CHANGE,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//--- Should the visualizer be deleted?
   if(ExtVisualizer!=NULL)
     {
      delete ExtVisualizer;
      ExtVisualizer=NULL;
     }
//---
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
   ulong  pass=0;
   long   id=0;
   double value=0;
   double total=0;
   string name;
//--- Reading the passes
   while(FrameNext(pass,name,id,value))
     {
      //--- If the password has been found
      if(name!="")
        {
         Print("Password found: ",name);
         name="";
        }
      else
         total+=MIN_SCAN_PART;
     }
//--- Add on a chart
   ExtVisualizer.AddResult(total/1000000.0);
  }
//+------------------------------------------------------------------+
//| Screen change handler                                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//---
   if(ExtVisualizer)
      ExtVisualizer.OnEvent(id,lparam,dparam,sparam);
//---
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtVisualizer.OnTimer();
  }
// Single expert
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   double passes=0.0;
//--- Calculating the limits
   if(!ExtScanner.CalculatePasses(PasswordLengthFrom,PasswordLengthTo,BruteforceType,BruteforceCharacters,passes))
     {
      FrameAdd("calc passes failed",Counter,0,NULL);
      return(INIT_FAILED);
     }
//--- Setting the lists of hashes for the attack
   if(!ExtScanner.SetHashesMD5(HashList))
     {
      FrameAdd("set hashes failed",Counter,0,NULL);
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
   ExtScanner.DoPass(Counter);
   FrameAdd("",Counter,0,NULL);   // Show a confirmation that the pass is completed
   return(0);
  }
//+------------------------------------------------------------------+
