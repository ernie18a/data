//+------------------------------------------------------------------+
//|                                            Canvas_Background.mq5 |
//|                                       Copyright 2021, Dark Ryd3r |
//|                                    https://twitter.com/DarkRyd3r |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Dark Ryd3r"
#property link      "https://twitter.com/DarkRyd3r"
#property version   "1.00"
#include  <Canvas\Canvas_shader.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
//---
   ChartSetInteger ( 0, CHART_FOREGROUND, true );
   CCanvas C;
   int  Width=( ushort ) ChartGetInteger ( 0, CHART_WIDTH_IN_PIXELS );    // we get the width of the window
   int  Height=( ushort ) ChartGetInteger ( 0, CHART_HEIGHT_IN_PIXELS );   // get the Height of the window
   if (!C.CreateBitmapLabel( 0, 0, "CanvasExamlple", 0, 0,Width,Height, COLOR_FORMAT_XRGB_NOALPHA ))       // сcreate a canvas with the size of the current window
      Print ( "Error creating canvas: ", GetLastError ());
   uint  i= 0,j= 100000 ;
   int  size=Width*Height;
   uchar  h[ 25600 ];
   for  ( int  w= 0 ; w< 25600 ; w++)
      h[w]=  uchar ( 128 + 128 * sin ( double (w)/ 256 )); //create an array to speed up work
   double  X1= 0,Y1= 0,X2= 0,Y2= 0 ;
   while (! IsStopped ()) {
      int  pos= int (i%size);
      if (pos== 0 ) {
         C.Update();
         //Sleep(100);
         X1= Width-( sin (( double )j/ 100 )*( double )Width);
         Y1= Height-( cos (( double )j/ 140 )*( double )Height);
         X2= Width+( cos (( double )j/ 80 )*( double )Width);
         Y2= Height+( sin (( double )j/ 20 )*( double )Height);
         j++;
      }
      int  X=pos+Width;
      int  Y= int (pos%Width);
      double  d= ((X1-X)*(X1-X)+(Y1-Y)*(Y1-Y))/(((X1-X)*(X1-X)+(Y1-Y)*(Y1-Y))+((X2-X)*(X2-X)+(Y2-Y)*(Y2-Y)));
      C.m_pixels[pos]=XRGB(h[ int (d* 11520 )],h[ int (d* 17920 )],h[ int (d* 6400 )]);
      i++;
   }
   C.Destroy();

}
//+------------------------------------------------------------------+
