#property copyright     "Integer"
#property link          "https://www.mql5.com/en/users/integer"
#property description   " "
#property description   "      http://dmffx.com"
#property description   " "
#property description   "      mailto:for-good-letters@yandex.ru"
#property description   " "

/*
Create(int aSizeX, int aSizeY, int aBGColor);
Sets the background color and size of the image.
aSizeX - image width (in pixels);
aSizeY - image height (in pixels);
aBGColor - background color;

Delete(string aFileName, bool aFromImages=true);
Deletes the file.
aFileName - bmp filename (without path). It isn't needed to specify the extension.
if aFromImages=true, the file will be deleted from \Images folder, if it=false, the file will be deleted from \Files folder. 

DrawCircle(int aX, int aY, int aRadius1, int aRadius2, int aColor, double aRatio=1.0, double aAngleFrom=0.0, double aAngleTo, bool aSolid=false);
Draws a circle.
aX - X coordinate of the center;
aY - Y coordinate of the center;
aRadius1 - radius of the first cicle;
aRadius2 - radius of the second circle;
aColor - color;
aRatio - ratio (1=cirlce, overwise ellipse).
aAngleFrom - starting angle of the sector;
aAngleTo - ending angle of the sector. If aAngleFrom=aAngleTo, it will draw the circle;
aSolid = true - filled circle.

DrawDot(int aX, int aY, int aColor);
Draws a dot.
aX - X coordinate;
aY - Y coordinate;
aColor - color;

DrawLine(int aX1,int aY1, int aX2, int aY2, int aColor);
Draws a line.
aX1, aY1 - starting coordinates;
aX2, aY2 - ending coordinates;
aColor - color;

DrawRectangle(int aX1, int aY1, int aX2, int aY2, int aColor, bool aSolid=false);
Draws a rectangle
aX1, aY1 - coordinates of the upper left corner;
aX2, aY2 - coorinates of the lower right corner;
aColor - color;
aSolid - true = filled rectange.

DrawTriangle(int aX1, int aY1, int aX2, int aY2, int aX3, int aY3, int aColor, bool aSolid=false);
Draws triangle.
aX1, aY1, aX2, aY2, aX3, aY3 - coordinates;
aColor - color;
aSolid - true - filled triange.

Fill(int aX, int aY, int aColor);
Fills the area.
aX, aY - starting point for filling;
aColor - fill color.


Hide(string aObjectName);
Deletes graphic object with the specified name.
aObjectName - name of the object to delete.

Save(string aFileName, bool aToImages=true);
Saves the created image to file.
aFileName - file name. It isn't necessary to specify the extension; 
aToImages - file will be saved to \Images folder, if it false, the file will be saved to \Files folder.

Show(int aX, int aY, string aBMPFileName, string aObjectName);
Shows the image on the chart.
aX, aY - image coordinates;
aBMPFileName - file with bmp image to show;
aObjectName - name of OBJ_BITMAP_LABEL graphic object.

SetDrawWidth(int aWidth);
Sets draw width.
aWidth - width.

TypeText(int aX, int aY, int aColor);
Prints text on the image.
aX, aY - coordinates of the left upper corner of the text;
aColor - text color.

Usage:

1. Include file with the class:
#include <cIntBMP.mqh>
2. Declare a class instance.
cIntBMP bmp;
3. Set background color and size of the image (Create()).
4. Draw.
5. Save (Save()).
6. Show (Show());

After the work:

1. Delete graphic object (Hide()).
2. Delete file (Delete()).

* * *

References:
   
http://www.gamesmaker.ru/73-format_dannykh_bmp_bitmap/
http://ru.wikipedia.org/wiki/BMP
http://www.reshalki.ru/index.php/reshalki/77
   
*/

int MaxHeight=12;
string CA[]={"!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","{","|","}","~","","Ђ","Ѓ","‚","ѓ","„","…","†","‡","€","‰","Љ","‹","Њ","Ќ","Ћ","Џ","ђ","‘","’","“","”","•","–","—","","™","љ","›","њ","ќ","ћ","џ"," ","Ў","ў","Ј","¤","Ґ","¦","§","Ё","©","Є","«","¬","­","®","Ї","°","±","І","і","ґ","µ","¶","·","ё","№","є","»","ј","Ѕ","ѕ","ї","А","Б","В","Г","Д","Е","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я","а","б","в","г","д","е","ж","з","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я"};
int PA[]={0,8,14,40,62,81,98,101,112,123,128,137,139,141,142,151,171,182,198,214,232,252,272,285,306,326,328,331,338,348,355,366,403,422,446,463,485,505,521,544,566,575,587,605,618,646,671,693,713,738,762,779,792,812,828,853,870,883,904,917,926,939,944,950,952,968,987,999,1018,1034,1044,1065,1082,1089,1098,1113,1122,1142,1156,1170,1188,1206,1213,1223,1232,1246,1256,1274,1286,1300,1312,1323,1333,1344,1350,1352,1376,1391,1393,1404,1408,1411,1423,1439,1461,1487,1516,1521,1552,1572,1594,1617,1640,1642,1644,1648,1652,1660,1663,1669,1669,1683,1704,1709,1732,1746,1767,1784,1784,1810,1830,1842,1858,1872,1882,1902,1924,1947,1967,1977,1983,1985,2019,2030,2034,2048,2057,2064,2074,2092,2121,2122,2140,2172,2186,2196,2205,2222,2232,2240,2259,2281,2305,2318,2347,2367,2394,2411,2436,2465,2483,2503,2531,2553,2575,2597,2617,2634,2647,2669,2696,2713,2736,2754,2785,2818,2841,2870,2890,2910,2940,2964,2980,2999,3017,3026,3045,3061,3079,3092,3107,3125,3137,3150,3168,3183,3197,3212,3230,3242,3252,3268,3290,3302,3318,3329,3351,3374,3391,3411,3425,3439,3460,3476};
int WA[]={1,4,6,5,7,5,1,2,2,3,5,2,2,1,4,5,3,5,5,5,5,5,5,5,5,1,2,4,5,4,5,10,6,5,6,6,5,5,6,6,1,3,6,5,7,6,6,6,6,6,5,5,6,6,10,6,6,6,2,4,2,5,5,2,5,5,5,5,5,2,5,5,1,1,5,1,7,5,5,5,5,2,4,2,5,5,7,4,4,4,3,1,3,6,1,7,5,2,4,4,5,4,4,5,10,10,3,10,6,7,5,5,1,2,3,3,4,3,5,0,8,9,4,9,5,5,5,0,6,4,3,5,5,1,5,5,8,6,5,5,2,8,2,3,5,1,1,4,5,5,1,5,10,5,5,1,5,4,2,6,5,5,5,8,5,10,6,6,6,6,6,7,6,6,6,6,6,5,6,9,6,6,6,7,8,7,8,6,5,7,6,5,5,5,4,5,5,7,5,5,5,5,5,7,5,5,5,5,5,4,4,7,4,5,4,7,8,6,7,5,4,7,5};
int XA[]={1,1,1,1,1,1,1,1,1,1,1,4,4,4,1,1,2,2,2,2,2,2,2,2,2,3,3,4,4,5,5,5,5,5,5,5,5,5,6,6,1,1,1,2,2,2,3,3,3,3,3,3,3,3,3,3,4,4,4,5,5,5,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,1,1,1,1,1,2,2,2,2,3,3,3,3,4,4,5,5,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2,1,1,2,3,3,1,2,3,3,3,3,3,4,5,1,2,1,2,1,1,1,2,2,3,3,4,4,4,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,5,5,5,5,5,1,2,3,3,3,3,3,3,3,3,3,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,1,1,2,2,3,3,3,4,4,4,5,5,5,5,5,5,1,1,2,2,2,3,3,3,4,4,4,4,4,4,4,4,4,5,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,1,2,2,2,2,3,3,3,4,4,4,5,5,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,5,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,5,5,1,1,1,2,2,1,2,2,3,3,4,4,1,1,2,2,3,3,4,4,5,5,1,1,2,2,3,3,4,1,2,3,3,3,3,4,4,5,5,5,1,1,1,1,2,2,2,2,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,7,8,8,8,9,9,9,10,10,10,10,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,1,1,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,5,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,1,1,1,1,1,1,1,2,2,3,3,4,4,4,5,5,5,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,3,4,5,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,0,0,1,2,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,1,1,1,1,1,1,1,1,1,2,3,4,5,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,7,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,1,2,2,3,3,4,5,5,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,1,1,1,1,1,1,1,2,2,3,3,4,4,4,5,5,5,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,6,6,6,6,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,1,2,3,3,3,3,3,3,3,3,3,4,5,1,1,1,1,1,1,1,1,2,3,4,5,6,6,6,6,6,6,6,6,0,0,1,1,1,2,2,3,3,4,4,5,5,5,6,6,0,0,1,1,1,2,2,3,3,4,4,5,5,5,6,6,7,7,8,8,9,9,9,10,10,0,0,0,0,1,1,2,2,3,4,4,5,5,6,6,6,6,0,0,1,2,3,3,3,3,3,4,5,6,6,0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,2,2,3,3,4,4,1,1,2,2,2,2,2,2,2,2,2,2,2,1,2,3,4,5,0,1,2,3,4,5,1,2,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,5,5,1,1,1,1,2,2,3,3,4,4,5,5,1,1,1,1,2,2,3,3,4,4,5,5,5,5,5,5,5,5,5,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,5,5,1,1,1,1,1,1,1,1,1,2,3,4,5,5,5,5,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,4,4,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,4,4,4,4,4,5,6,7,7,7,7,7,1,1,1,1,1,1,2,3,4,5,5,5,5,5,1,1,1,1,2,2,3,3,4,4,5,5,5,5,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,5,5,1,1,1,1,2,2,3,3,4,4,5,5,5,5,5,5,5,5,1,1,1,1,1,1,2,1,1,2,2,2,3,3,3,4,4,1,1,1,1,1,1,1,2,2,1,1,1,1,1,2,3,4,5,5,5,5,5,5,1,1,2,2,3,3,4,4,5,5,1,1,1,1,2,2,3,3,4,4,5,5,6,6,7,7,7,7,1,1,1,1,2,2,3,3,4,4,4,4,0,1,1,1,1,1,2,2,2,3,4,4,4,4,1,1,1,2,2,2,3,3,3,4,4,4,1,2,2,2,2,2,2,2,2,3,3,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,1,2,3,4,5,6,1,1,0,1,2,3,3,3,3,3,3,3,3,3,4,4,5,5,5,5,6,6,6,7,7,7,1,1,1,1,1,1,1,1,1,2,3,3,4,4,5,1,2,1,1,1,1,1,1,2,3,3,4,4,1,2,3,4,1,3,5,0,1,2,2,2,2,2,2,2,2,3,4,0,0,1,1,2,2,2,2,2,2,2,2,3,3,4,4,0,0,1,1,1,1,1,1,1,2,2,2,2,3,3,3,4,4,5,5,5,5,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,7,7,8,8,9,9,10,1,2,2,2,2,2,2,2,3,4,5,6,6,6,6,6,6,6,6,6,7,7,8,8,9,9,10,10,10,1,2,2,3,3,1,1,1,1,1,1,1,1,1,2,3,4,5,6,6,6,6,6,6,6,6,6,7,7,8,8,9,9,10,10,10,1,1,1,1,1,1,1,1,1,2,2,3,3,3,4,4,4,5,5,6,0,1,2,3,3,3,3,3,3,3,3,3,4,4,5,5,6,6,7,7,7,7,1,1,1,1,1,1,1,1,1,2,3,3,3,4,5,5,5,5,5,5,5,5,5,0,1,1,1,1,1,1,1,1,1,2,2,3,3,3,4,4,5,5,5,5,5,5,0,1,1,2,0,1,2,3,0,1,2,3,1,2,2,2,3,3,3,4,1,2,3,0,1,2,3,4,5,0,1,1,1,2,4,4,4,5,6,7,8,8,8,1,2,2,2,2,3,4,5,5,5,5,5,5,6,6,7,7,8,8,9,9,2,2,3,3,4,1,1,1,1,1,1,2,3,4,5,5,5,5,5,5,6,6,7,7,8,8,9,9,1,1,1,1,1,1,2,3,3,3,4,4,4,5,0,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,5,5,5,1,1,1,1,1,1,2,3,3,3,4,5,5,5,5,5,5,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,6,6,6,6,6,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,4,4,4,4,4,0,0,1,2,3,3,3,3,3,3,3,3,1,1,1,1,1,2,2,3,3,4,4,5,5,5,5,5,1,1,1,1,1,1,1,1,1,2,3,4,5,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,1,1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,4,4,4,4,5,5,1,1,1,2,2,3,3,3,4,4,4,4,5,5,5,5,6,6,7,7,8,8,8,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,6,6,1,2,2,3,3,3,4,4,5,5,1,2,3,4,5,5,1,2,1,1,1,1,1,1,2,2,3,3,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,8,8,8,8,8,8,0,1,1,1,1,1,1,1,1,1,2,1,2,2,3,1,1,2,2,3,3,3,3,3,3,4,4,5,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,4,4,0,1,1,1,1,1,1,1,2,3,3,4,4,4,4,4,4,5,1,1,1,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,4,5,5,5,5,5,5,5,5,5,5,1,1,1,1,1,2,2,2,2,3,3,3,4,4,4,4,5,5,5,1,1,1,1,1,1,1,1,1,2,2,3,3,4,5,5,6,6,6,6,6,6,6,6,6,8,8,9,9,9,10,10,1,1,1,1,2,2,2,3,3,3,4,4,5,5,1,1,2,2,3,3,3,4,4,5,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,1,1,2,2,2,3,3,3,4,4,0,1,1,1,1,1,1,2,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,1,1,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,1,1,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,5,1,1,1,1,1,1,1,1,1,2,3,4,5,1,1,2,2,3,3,3,3,3,3,3,3,4,4,5,5,6,6,7,7,7,7,7,7,7,7,7,8,8,1,1,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,0,1,1,2,2,3,3,4,4,5,5,5,5,5,5,5,5,5,6,6,7,7,8,8,9,9,10,1,2,2,3,3,4,4,4,5,5,5,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,2,3,4,4,5,5,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,2,2,3,3,4,4,4,5,5,5,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,1,2,2,2,2,2,2,2,3,4,5,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,7,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,1,2,3,4,5,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,3,4,5,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,1,2,3,3,3,3,3,3,3,3,3,4,5,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,6,6,6,6,6,1,1,1,2,2,3,3,4,4,5,5,5,5,5,5,5,5,5,6,6,7,7,8,8,9,9,9,0,0,0,0,1,1,2,2,3,4,4,5,5,6,6,6,6,1,1,1,1,1,1,1,1,1,2,3,4,5,5,5,5,5,5,5,5,5,6,6,1,1,1,1,1,2,3,4,5,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2,3,4,4,4,4,4,4,4,4,4,5,6,7,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,1,2,3,4,4,4,4,4,4,4,4,4,5,6,7,7,7,7,7,7,7,7,7,8,8,0,0,1,2,2,2,2,2,2,2,2,2,3,3,4,4,5,5,6,6,7,7,7,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,8,8,8,8,8,8,8,8,8,1,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,6,6,6,0,0,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,5,5,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,3,3,4,4,5,5,6,6,7,7,7,7,7,7,7,1,1,1,1,1,2,2,2,2,3,3,4,4,5,5,6,6,6,6,6,6,6,6,6,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,1,1,1,1,1,1,2,3,4,0,0,1,1,1,1,1,2,2,3,3,4,4,4,4,4,4,5,5,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,1,1,2,2,2,3,4,4,4,4,4,4,5,6,6,6,7,7,1,1,2,2,3,3,3,4,4,4,5,5,5,1,1,1,1,1,1,2,3,4,5,5,5,5,5,5,1,1,1,1,1,1,2,2,3,3,4,4,5,5,5,5,5,5,1,1,1,1,1,1,2,3,3,4,4,5,1,2,2,2,2,3,4,5,5,5,5,5,5,1,1,1,1,1,1,2,3,4,4,5,6,7,7,7,7,7,7,1,1,1,1,1,1,2,3,4,5,5,5,5,5,5,1,1,1,1,2,2,3,3,4,4,5,5,5,5,1,1,1,1,1,1,2,3,4,5,5,5,5,5,5,1,1,1,1,1,1,1,1,2,2,3,3,4,4,5,5,5,5,1,1,1,1,2,2,3,3,4,4,5,5,0,1,2,2,2,2,2,2,3,4,1,1,1,1,1,2,2,3,3,4,4,4,4,4,4,4,1,1,1,2,2,3,3,4,4,4,4,4,4,4,4,5,5,6,6,7,7,7,1,1,1,1,2,2,3,3,4,4,4,4,1,1,1,1,1,1,2,3,4,4,4,4,4,4,5,5,1,1,1,2,3,4,4,4,4,4,4,1,1,1,1,1,1,2,3,4,4,4,4,4,4,5,6,7,7,7,7,7,7,1,1,1,1,1,1,2,3,4,4,4,4,4,4,5,6,7,7,7,7,7,7,8,0,0,1,2,2,2,2,2,2,3,3,4,4,5,5,6,6,1,1,1,1,1,1,2,2,3,3,4,4,5,5,7,7,7,7,7,7,1,1,1,1,1,1,2,2,3,3,4,4,5,5,0,0,1,1,2,2,2,3,3,3,4,4,4,4,1,1,1,1,1,1,2,3,3,3,3,4,4,5,5,6,6,7,7,7,7,1,1,1,2,2,2,3,3,4,4,5,5,5,5,5,5};
int YA[]={2,3,4,5,6,7,8,10,2,3,4,2,3,4,4,8,2,3,4,5,6,7,8,9,10,4,8,4,8,2,3,4,5,6,7,8,9,10,4,8,4,5,9,3,6,10,2,3,4,5,6,7,8,9,10,11,3,7,10,4,8,9,3,9,2,4,8,2,4,7,3,6,9,5,8,10,4,8,10,3,9,3,4,7,8,9,2,5,6,10,3,4,7,10,8,9,7,10,2,3,4,3,4,5,6,7,8,9,10,11,2,12,2,12,3,4,5,6,7,8,9,10,11,3,5,4,3,5,7,7,5,6,7,8,9,7,7,11,10,7,7,10,9,10,7,8,5,6,2,3,4,3,4,5,6,7,8,9,2,10,2,10,2,10,3,4,5,6,7,8,9,3,3,2,3,4,5,6,7,8,9,10,3,9,10,2,8,10,2,7,10,2,6,10,3,4,5,10,3,9,2,10,2,6,10,2,6,10,3,4,5,7,8,9,7,8,5,6,8,3,4,8,2,3,4,5,6,7,8,9,10,8,2,3,4,5,6,9,2,5,10,2,5,10,2,5,10,2,6,7,8,9,3,4,5,6,7,8,9,2,6,10,2,6,10,2,6,10,3,7,8,9,2,2,8,9,10,2,6,7,2,4,5,2,3,3,4,5,7,8,9,2,6,10,2,6,10,2,6,10,3,4,5,7,8,9,3,4,5,9,2,6,10,2,6,10,2,6,10,3,4,5,6,7,8,9,5,10,11,5,10,7,6,8,5,9,4,10,6,8,6,8,6,8,6,8,6,8,4,10,5,9,6,8,7,3,2,2,7,8,10,2,6,3,4,5,5,6,7,8,3,4,9,10,3,10,2,6,7,11,2,5,8,11,2,5,8,11,2,5,6,7,11,3,8,11,3,4,8,5,6,7,8,9,10,6,7,8,4,5,8,2,3,8,4,5,8,6,7,8,9,10,2,3,4,5,6,7,8,9,10,2,6,10,2,6,10,2,6,10,3,4,5,7,8,9,3,4,5,6,7,8,9,2,10,2,10,2,10,2,10,3,9,2,3,4,5,6,7,8,9,10,2,10,2,10,2,10,3,9,4,5,6,7,8,2,3,4,5,6,7,8,9,10,2,6,10,2,6,10,2,6,10,2,10,2,3,4,5,6,7,8,9,10,2,6,2,6,2,6,2,3,4,5,6,7,8,9,2,10,2,10,2,6,10,2,6,9,3,6,7,8,9,10,2,3,4,5,6,7,8,9,10,6,6,6,6,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,8,9,10,10,2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,10,5,6,4,7,3,8,2,9,10,2,3,4,5,6,7,8,9,10,10,10,10,10,2,3,4,5,6,7,8,9,10,4,5,6,7,8,9,6,7,4,5,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,10,3,4,5,6,7,8,9,2,10,2,10,2,10,2,10,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,10,2,6,2,6,2,6,2,6,3,4,5,3,4,5,6,7,8,9,2,10,2,10,2,8,10,2,9,10,3,4,5,6,7,8,9,11,2,3,4,5,6,7,8,9,10,2,6,2,6,2,6,2,6,3,4,5,7,8,9,10,3,4,5,9,2,6,10,2,6,10,2,6,10,3,7,8,9,2,2,2,3,4,5,6,7,8,9,10,2,2,2,3,4,5,6,7,8,9,10,10,10,10,2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,10,7,8,4,5,6,2,3,2,3,4,5,6,7,8,9,10,7,8,4,5,6,7,8,9,10,7,8,4,5,6,2,3,2,3,9,10,4,8,5,7,6,5,7,4,8,2,3,9,10,2,3,4,5,6,7,8,9,10,5,4,2,3,2,9,10,2,8,10,2,7,10,2,6,10,2,5,10,2,4,10,2,3,10,2,3,4,5,6,7,8,9,10,11,12,2,12,2,3,4,5,6,7,8,9,10,2,12,2,3,4,5,6,7,8,9,10,11,12,3,2,1,2,3,12,12,12,12,12,12,2,3,8,9,5,7,10,5,7,10,5,7,10,6,7,8,9,10,2,3,4,5,6,7,8,9,10,5,10,5,10,5,10,6,7,8,9,6,7,8,9,5,10,5,10,5,10,6,9,6,7,8,9,5,10,5,10,5,10,2,3,4,5,6,7,8,9,10,6,7,8,9,5,7,10,5,7,10,5,7,10,6,7,9,3,4,5,6,7,8,9,10,2,5,6,7,8,9,12,5,10,12,5,10,12,5,10,12,5,6,7,8,9,10,11,2,3,4,5,6,7,8,9,10,6,5,5,6,7,8,9,10,2,5,6,7,8,9,10,2,5,6,7,8,9,10,11,12,2,3,4,5,6,7,8,9,10,7,6,8,5,9,10,2,3,4,5,6,7,8,9,10,5,6,7,8,9,10,5,5,6,7,8,9,10,5,5,6,7,8,9,10,5,6,7,8,9,10,6,5,5,6,7,8,9,10,6,7,8,9,5,10,5,10,5,10,6,7,8,9,5,6,7,8,9,10,11,12,5,10,5,10,5,10,6,7,8,9,6,7,8,9,5,10,5,10,5,10,5,6,7,8,9,10,11,12,5,6,7,8,9,10,5,6,9,5,7,10,5,8,10,6,9,3,4,5,6,7,8,9,5,10,5,6,7,8,9,10,10,9,5,6,7,8,9,10,5,6,7,8,9,10,7,8,5,6,5,6,7,8,9,10,7,8,5,6,7,8,9,10,5,6,7,8,5,6,9,10,7,8,7,8,5,6,9,10,12,5,6,7,8,12,9,10,11,9,5,6,7,8,5,9,10,5,8,10,5,7,10,5,6,10,6,2,3,4,5,7,8,9,10,1,11,2,3,4,5,6,7,8,9,10,11,1,11,2,3,4,5,7,8,9,10,6,4,3,3,4,4,3,3,10,2,2,2,2,3,4,5,6,7,8,9,10,2,6,2,6,9,10,2,6,10,7,8,9,2,3,4,5,6,7,8,9,10,2,1,2,0,2,2,11,10,5,6,7,8,9,10,5,3,5,2,5,11,10,11,10,10,10,10,5,5,3,4,5,6,7,8,9,10,5,5,5,9,5,9,3,4,5,6,7,8,9,10,5,9,5,9,5,7,3,4,5,6,7,8,9,2,5,7,10,2,5,10,2,10,3,4,8,9,3,9,2,4,8,2,4,7,3,6,9,5,8,10,4,8,10,3,9,2,9,8,10,8,10,9,10,3,4,5,6,7,8,9,2,2,2,2,3,4,5,6,7,8,9,10,6,10,6,10,6,10,7,8,9,8,7,9,6,10,2,3,4,5,6,7,8,9,10,6,6,6,6,2,3,4,5,6,7,8,9,10,6,10,6,10,6,10,7,8,9,2,3,4,5,6,7,8,9,10,5,6,1,4,7,0,3,8,2,9,10,2,2,2,2,3,4,5,6,7,8,9,10,2,7,2,6,2,6,7,8,9,10,2,3,4,5,6,7,8,9,10,10,10,11,12,10,2,3,4,5,6,7,8,9,10,3,2,3,4,5,6,7,8,9,10,3,6,3,5,12,5,12,6,7,8,9,10,11,3,4,4,3,2,3,2,3,3,2,3,2,6,5,6,7,5,6,7,6,6,6,6,6,6,6,6,6,6,2,2,3,4,2,2,3,4,2,3,2,2,3,4,10,6,7,8,9,5,5,5,6,7,8,9,10,7,10,7,10,7,10,8,9,6,10,7,9,8,5,6,7,8,9,10,7,7,7,5,6,7,8,9,10,7,10,7,10,7,10,8,9,5,6,7,8,9,10,7,3,6,8,2,5,9,10,3,2,3,4,5,6,7,8,9,10,3,6,3,5,3,5,6,7,8,9,10,5,6,7,8,9,10,10,10,11,12,10,5,6,7,8,9,10,2,3,4,5,6,9,0,7,10,1,7,10,1,7,10,0,7,10,2,3,4,5,6,7,8,9,2,5,6,7,8,12,3,9,12,3,9,12,2,5,6,7,8,9,10,11,8,9,10,10,2,3,4,5,6,7,8,9,2,4,5,6,8,3,7,3,7,3,7,2,4,5,6,8,2,3,4,5,6,7,8,9,10,2,2,2,1,2,2,3,4,5,6,8,9,10,11,12,3,5,6,10,2,4,7,11,2,5,8,11,2,6,9,11,3,7,8,10,2,3,4,5,6,7,8,9,10,0,2,6,10,2,6,10,0,2,6,10,2,10,4,5,6,3,7,2,5,8,2,4,6,8,2,4,6,8,2,8,3,7,4,5,6,3,4,5,6,7,8,9,2,6,10,2,6,10,2,6,10,2,10,3,9,8,7,9,6,8,10,7,9,6,10,7,7,7,7,7,8,6,6,2,3,4,5,6,7,1,8,1,3,4,5,6,8,1,3,5,8,1,3,5,8,1,4,6,8,1,8,2,3,4,5,6,7,0,2,3,4,5,6,7,8,9,10,0,3,2,4,3,6,10,6,10,4,5,6,7,8,10,6,10,6,10,2,3,4,5,6,7,8,9,10,2,5,6,7,8,9,10,5,6,7,8,9,10,5,5,4,5,5,5,6,7,8,9,10,11,10,5,10,5,6,7,8,9,10,9,3,4,5,2,3,4,5,6,2,3,4,5,6,7,8,9,10,11,2,2,3,4,5,6,7,8,9,10,11,6,6,7,8,9,3,5,7,10,5,7,10,3,5,7,10,6,7,9,2,3,4,5,6,7,8,9,10,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,10,4,7,3,5,7,4,7,6,7,8,9,5,7,10,5,7,10,5,10,6,9,6,10,7,9,6,8,10,7,9,8,2,5,6,7,8,9,10,11,12,3,4,5,9,2,6,10,2,6,10,2,6,10,3,7,8,9,6,9,5,7,10,5,8,10,6,9,2,5,6,7,8,9,10,2,9,10,6,7,8,4,5,8,2,3,8,4,5,8,6,7,8,9,10,2,3,4,5,6,7,8,9,10,2,6,10,2,6,10,2,6,10,2,7,8,9,2,3,4,5,6,7,8,9,10,2,6,10,2,6,10,2,6,10,3,4,5,7,8,9,2,3,4,5,6,7,8,9,10,2,2,2,2,10,11,9,10,2,3,4,5,6,7,8,10,2,10,2,10,2,10,2,3,4,5,6,7,8,9,10,10,11,2,3,4,5,6,7,8,9,10,2,6,10,2,6,10,2,6,10,2,10,10,2,9,3,8,4,7,5,6,2,3,4,5,6,7,8,9,10,5,6,4,7,3,8,2,9,10,9,3,10,2,10,2,6,10,2,6,10,3,4,5,7,8,9,2,3,4,5,6,7,8,9,10,8,9,7,5,6,3,4,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,0,8,9,1,7,1,5,6,0,3,4,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,5,6,4,7,3,8,2,9,10,10,3,4,5,6,7,8,9,2,2,2,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,4,5,6,7,8,9,6,7,4,5,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,6,6,6,6,2,3,4,5,6,7,8,9,10,3,4,5,6,7,8,9,2,10,2,10,2,10,2,10,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,10,2,2,2,2,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,2,6,2,6,2,6,2,6,3,4,5,3,4,5,6,7,8,9,2,10,2,10,2,10,2,10,3,9,2,2,2,3,4,5,6,7,8,9,10,2,2,2,3,4,5,6,9,7,10,7,10,7,10,7,10,2,3,4,5,6,7,8,9,4,5,6,3,7,3,7,3,7,2,3,4,5,6,7,8,9,10,3,7,3,7,3,7,4,5,6,2,3,9,10,4,8,5,7,6,5,7,4,8,2,3,9,10,2,3,4,5,6,7,8,9,10,10,10,10,2,3,4,5,6,7,8,9,10,10,11,2,3,4,5,6,7,7,7,7,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,10,10,2,3,4,5,6,7,8,9,10,10,10,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,10,10,2,3,4,5,6,7,8,9,10,10,10,2,3,4,5,6,7,8,9,10,10,11,2,3,2,2,3,4,5,6,7,8,9,10,6,10,6,10,6,10,6,10,7,8,9,2,3,4,5,6,7,8,9,10,6,10,6,10,6,10,6,10,7,8,9,2,3,4,5,6,7,8,9,10,2,3,4,5,6,7,8,9,10,6,10,6,10,6,10,6,10,7,8,9,3,9,2,10,2,6,10,2,6,10,2,6,10,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9,10,6,3,4,5,6,7,8,9,2,10,2,10,2,10,3,4,5,6,7,8,9,3,4,5,9,10,2,6,7,8,2,6,2,6,2,6,2,3,4,5,6,7,8,9,10,8,9,5,7,10,5,7,10,5,7,10,6,7,8,9,10,5,6,7,8,9,4,5,10,3,5,10,3,5,10,2,6,7,8,9,5,6,7,8,9,10,5,7,10,5,7,10,5,7,10,6,8,9,5,6,7,8,9,10,5,5,5,10,11,6,7,8,9,10,5,10,5,10,5,6,7,8,9,10,10,11,6,7,8,9,5,7,10,5,7,10,5,7,10,6,7,9,5,10,6,8,9,7,5,6,7,8,9,10,7,6,8,9,5,10,6,9,5,10,5,7,10,5,7,10,6,8,9,5,6,7,8,9,10,9,8,7,5,6,7,8,9,10,5,6,7,8,9,10,3,9,4,8,3,7,5,6,7,8,9,10,5,6,7,8,9,10,7,6,8,5,9,10,10,6,7,8,9,5,5,5,6,7,8,9,10,5,6,7,8,9,10,6,7,8,9,7,6,5,6,7,8,9,10,5,6,7,8,9,10,7,7,7,5,6,7,8,9,10,6,7,8,9,5,10,5,10,5,10,6,7,8,9,5,6,7,8,9,10,5,5,5,5,6,7,8,9,10,5,6,7,8,9,10,11,12,5,10,5,10,5,10,6,7,8,9,6,7,8,9,5,10,5,10,5,10,6,9,5,5,5,6,7,8,9,10,5,5,5,6,7,8,12,9,12,9,12,5,6,7,8,9,10,11,6,7,8,5,9,5,9,4,5,6,7,8,9,10,11,5,9,5,9,6,7,8,5,6,9,10,7,8,7,8,5,6,9,10,5,6,7,8,9,10,10,10,5,6,7,8,9,10,10,11,5,6,7,8,8,5,6,7,8,9,10,5,6,7,8,9,10,10,10,5,6,7,8,9,10,10,10,5,6,7,8,9,10,5,6,7,8,9,10,10,10,5,6,7,8,9,10,10,10,5,6,7,8,9,10,11,5,6,5,5,6,7,8,9,10,7,10,7,10,7,10,8,9,5,6,7,8,9,10,7,10,7,10,7,10,8,9,5,6,7,8,9,10,5,6,7,8,9,10,7,10,7,10,7,10,8,9,6,9,5,10,5,7,10,5,7,10,6,7,8,9,5,6,7,8,9,10,7,6,7,8,9,5,10,5,10,5,10,6,7,8,9,6,7,10,5,8,9,5,8,5,8,5,6,7,8,9,10};

#import "kernel32.dll"
   int CopyFileA (uchar & FromFileName[],uchar & ToFileName[],int FailIfExists);
   int DeleteFileA (uchar & FromFileName[]);
#import

struct BITMAPFILEHEADER{ 
  short     Type;
  int       Size;
  short     Reserved1;
  short     Reserved2;
  int       OffBits;
};

struct BITMAPINFOHEADER{
  int    Size;
  int    Width;
  int    Height;
  short  Planes;
  short  BitCount;
  int    Compression;
  int    SizeImage;
  int    XPelsPerMeter;
  int    YPelsPerMeter;
  int    ClrUsed;
  int    ClrImportant;
};

struct BIMAPHEADER{
   BITMAPFILEHEADER File;
   BITMAPINFOHEADER Info;   
};

struct POINT{
   int x;
   int y;
};

struct BITMAPLINE{
   int Pixel[];
};

struct Dot{
   int x;
   int y;
   int c;
};

class cIntBMP{
   private:
      BIMAPHEADER Header;
      BITMAPLINE Line[];
      int m_SizeX;
      int m_SizeY;
      double m_tp;
      int m_dw;
      BITMAPLINE m_tl[];
         void GetRGB(color aColor,int & aR,int & aG, int & aB){
            aR=aColor;
            aB=aR/65536;
            aR-=aB*65536;
            aG=aR/256;
            aR-=aG*256;
         } 
         int RGB256(int aR,int aG,int aB){
            return(aR+256*aG+65536*aB);
         }
         int ConvertColor(color aColor){
            int m_r,m_g,m_b;
            GetRGB(aColor,m_r,m_g,m_b);
            return(RGB256(m_b,m_g,m_r));
         }
         string CheckExtension(string aFileName){
            string m_ex=StringSubstr(aFileName,StringLen(aFileName)-4,4);
            StringToLower(m_ex);
            if(m_ex!=".bmp")aFileName+=".bmp";  
            return(aFileName);    
         } 
         bool Copy(string aFromFileName,string aToFileName=""){
               if(!MQL5InfoInteger(MQL5_DLLS_ALLOWED)){
                  Alert("DLLS not allowed. Impossible save file to Images");
                  return(false);
               }
            if(aToFileName=="")aToFileName=aFromFileName;
            aFromFileName=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+CheckExtension(aFromFileName);
            aToFileName=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Images\\"+CheckExtension(aToFileName);
            uchar m_from[];
            uchar m_to[];
            StringToCharArray(aFromFileName,m_from);
            StringToCharArray(aToFileName,m_to);
            return(CopyFileA(m_from,m_to,0)==1);
         } 
         void dls(int aX1,int aY1,int aX2,int aY2,int aColor){
               if(aX1==aX2 && aY1==aY2){
                  dd(aX1,aY1,aColor);
                  return;
               }
            int m_width=(int)MathAbs(aX1-aX2);
            int m_height=(int)MathAbs(aY1-aY2);
            int m_tmp;
               if(m_width>m_height){
                  if(aX2<aX1){
                     m_tmp=aX1;
                     aX1=aX2;
                     aX2=m_tmp;
                     m_tmp=aY1;
                     aY1=aY2;
                     aY2=m_tmp; 
                  }
                  for(int m_x=aX1;m_x<=aX2;m_x++){
                     double m_k=m_x-aX1;
                     m_k/=m_width;
                     int m_y=(int)MathRound(m_k*(aY2-aY1)+aY1);
                     dd(m_x,m_y,aColor);
                  }
               }
               else{
                  if(aY2<aY1){
                     m_tmp=aY1;
                     aY1=aY2;
                     aY2=m_tmp;
                     m_tmp=aX1;
                     aX1=aX2;
                     aX2=m_tmp;                  
                  }
                  for(int m_y=aY1;m_y<=aY2;m_y++){
                     double m_k=m_y-aY1;
                     m_k/=m_height;
                     int m_x=(int)MathRound(m_k*(aX2-aX1)+aX1);
                     dd(m_x,m_y,aColor);
                  }
               }
         } 
         void dd(int aX,int aY,int aColor){
            for(int xx=aX-m_dw/2;xx<aX+m_dw-m_dw/2;xx++){
               for(int yy=aY-m_dw/2;yy<aY+m_dw-m_dw/2;yy++){
                  if(xx>=0 && xx<m_SizeX && yy>=0 && yy<m_SizeY){
                     Line[yy].Pixel[xx]=aColor;
                  }                     
               }
            }
         } 
   public:
      void cIntBMP(){
         Header.File.Type=0x4D42;
         Header.File.Reserved1=0;
         Header.File.Reserved2=0;
         Header.File.OffBits=54;   
         Header.Info.Size=40;    
         Header.Info.Planes=1; 
         Header.Info.BitCount=32;
         Header.Info.Compression=0;   
         Header.Info.XPelsPerMeter=2795;
         Header.Info.YPelsPerMeter=2795;
         Header.Info.ClrUsed=0;
         Header.Info.ClrImportant=0;   
         m_tp=M_PI*2;
         m_dw=1;
      }
      void Create(int aSizeX,int aSizeY,int aBGColor){  
         m_SizeX=aSizeX;
         m_SizeY=aSizeY;
         Header.File.Size=54+m_SizeX*m_SizeY;
         Header.Info.Width=m_SizeX;
         Header.Info.Height=m_SizeY;
         Header.Info.SizeImage=m_SizeX*m_SizeY;
         ArrayResize(Line,m_SizeY);
         aBGColor=ConvertColor(aBGColor);
            for(int y=0;y<m_SizeY;y++){
               ArrayResize(Line[y].Pixel,m_SizeX);
                  for(int x=0;x<m_SizeX;x++){
                     Line[y].Pixel[x]=aBGColor;
                  }
            }
      }
      void SetDrawWidth(int aWidth){
         m_dw=aWidth;
      }
      bool Save(string aFileName,bool aToImages=true){
         aFileName=CheckExtension(aFileName);
         int m_h=FileOpen(aFileName,FILE_BIN|FILE_WRITE);
         if(m_h==-1)return(false);
         bool m_rv=true;
         FileWriteStruct(m_h,Header);
            for(int y=0;y<m_SizeY;y++){
               FileWriteArray(m_h,Line[y].Pixel);
            }
         FileClose(m_h);
            if(aToImages){
               m_rv=Copy(aFileName);
               FileDelete(aFileName);
            }
         return(m_rv);           
      }
      void Delete(string aFileName,bool aFromImages=true){
         aFileName=CheckExtension(aFileName);
               if(aFromImages){
                  aFileName=TerminalInfoString(TERMINAL_PATH)+"\\MQL5\\Images\\"+aFileName;
                  uchar m_fn[];
                  StringToCharArray(aFileName,m_fn);
                  DeleteFileA(m_fn);
               }
               else{
                  FileDelete(aFileName);
               }
      }
      
      /*
   ObjectCreate(0,"Obj",OBJ_BITMAP_LABEL,0,0,0);
   ObjectSetInteger(0,"Obj",OBJPROP_XDISTANCE,30);
   ObjectSetInteger(0,"Obj",OBJPROP_YDISTANCE,30);
   ObjectSetString(0,"Obj",OBJPROP_BMPFILE,0,"/Images/bmpimg.bmp");   
   ObjectSetString(0,"Obj",OBJPROP_BMPFILE,1,"/Images/bmpimg.bmp");   
   ObjectSetInteger(0,"Obj",OBJPROP_STATE,true);
   ChartRedraw(0);      
      */
      void Show(int aX,int aY,string aBMPFileName,string aObjectName){
         aBMPFileName="\\Images\\"+CheckExtension(aBMPFileName);
         ObjectDelete(0,aObjectName);
            if(ObjectFind(0,aObjectName)==-1){
               ObjectDelete(0,aObjectName);
               ObjectCreate(0,aObjectName,OBJ_BITMAP_LABEL,0,0,0);
               ObjectSetInteger(0,aObjectName,OBJPROP_BACK,false);
               ObjectSetInteger(0,aObjectName,OBJPROP_SELECTED,false);
               ObjectSetInteger(0,aObjectName,OBJPROP_SELECTABLE,false);
            }
         ObjectSetInteger(0,aObjectName,OBJPROP_XDISTANCE,aX);
         ObjectSetInteger(0,aObjectName,OBJPROP_YDISTANCE,aY); 
         ObjectSetString(0,aObjectName,OBJPROP_BMPFILE,0,aBMPFileName);
         ObjectSetString(0,aObjectName,OBJPROP_BMPFILE,1,aBMPFileName);   
         ObjectSetInteger(0,aObjectName,OBJPROP_STATE,true);     
         ChartRedraw(0);
      }
      void Hide(string aObjectName){
         ObjectDelete(0,aObjectName);
      }
      void DrawDot(int aX,int aY,int aColor){
         aColor=ConvertColor(aColor);
         dd(aX,aY,aColor);
      }
      void DrawLine(int aX1,int aY1,int aX2,int aY2,int aColor){
         aColor=ConvertColor(aColor);
            if(aX2==aX1 || aY2==aY1){
               dls(aX1,aY1,aX2,aY2,aColor);
               return;
            }
         double k=(aY2-aY1);
         k/=(aX2-aX1);
         double b=aY2-k*aX2;
            for(int x=MathMin(aX1,aX2)+1;x<=MathMax(aX1,aX2);x++){
               int y=(int)MathRound(k*x+b);
               int yp=(int)MathRound(k*(x-1)+b);
               dls(x,y,x-1,yp,aColor);
            }
      }
      void DrawTriangle(int aX1,int aY1,int aX2,int aY2,int aX3,int aY3,int aColor,bool aSolid=false){
         aColor=ConvertColor(aColor);
         double k12=(aY2-aY1);
         if(aX2!=aX1)k12/=(aX2-aX1);
         double b12=aY2-k12*aX2;         
         double k13=(aY3-aY1);
         if(aX3!=aX1)k13/=(aX3-aX1);
         double b13=aY3-k13*aX3;
         double k23=(aY3-aY2);
         if(aX3!=aX2)k23/=(aX3-aX2);
         double b23=aY3-k23*aX3;
         int l=MathMin(aX1,MathMin(aX2,aX3))+1;
         int r=MathMax(aX1,MathMax(aX2,aX3));         
         bool l12=false;
         bool l13=false;
         bool l23=false;
         int y12=0;
         int yp12=0; 
         int y13=0;
         int yp13=0;
         int y23=0;
         int yp23=0;
            for(int x=l;x<=r;x++){
               l12=false;
               l13=false;
               l23=false;
                  if(aX2!=aX1){
                     if(x-1>=MathMin(aX1,aX2) && x<=MathMax(aX1,aX2)){
                        y12=(int)MathRound(k12*x+b12);
                        yp12=(int)MathRound(k12*(x-1)+b12);
                        dls(x,y12,x-1,yp12,aColor);
                        l12=true;                        
                     }
                  }
                  else{
                     dls(aX1,aY1,aX2,aY2,aColor);
                  }
                  if(aX3!=aX1){
                     if(x-1>=MathMin(aX1,aX3) && x<=MathMax(aX1,aX3)){
                        y13=(int)MathRound(k13*x+b13);
                        yp13=(int)MathRound(k13*(x-1)+b13);
                        dls(x,y13,x-1,yp13,aColor);
                        l13=true;
                     }  
                  }
                  else{
                     dls(aX1,aY1,aX3,aY3,aColor);
                  }                  
                  if(aX3!=aX2){
                     if(x-1>=MathMin(aX2,aX3) && x<=MathMax(aX2,aX3)){
                        y23=(int)MathRound(k23*x+b23);
                        yp23=(int)MathRound(k23*(x-1)+b23);
                        dls(x,y23,x-1,yp23,aColor);
                        l23=true;
                     } 
                  }
                  else{
                     dls(aX3,aY3,aX2,aY2,aColor);
                  }                  
                  if(aSolid){
                     if(l12 && l13){
                        dls(x,y12,x,y13,aColor);
                     }
                     if(l12 && l23){
                        dls(x,y12,x,y23,aColor);
                     }
                     if(l13 && l23){
                        dls(x,y13,x,y23,aColor);
                     }
                  }                 
            }
      } 
      void DrawRectangle(int aX1,int aY1,int aX2,int aY2,int aColor,bool aSolid=false){
         aColor=ConvertColor(aColor);
            if(aSolid){
               if(aX2<aX1){
                  int m_tmp=aX1;
                  aX1=aX2;
                  aX2=m_tmp;
                  m_tmp=aY1;
                  aY1=aY2;
                  aY2=m_tmp;                  
               }
               for(int m_x=aX1;m_x<=aX2;m_x++){
                  dls(m_x,aY1,m_x,aY2,aColor);
               }
            }
            else{
               dls(aX1,aY1,aX2,aY1,aColor);
               dls(aX1,aY2,aX2,aY2,aColor);         
               dls(aX1,aY1,aX1,aY2,aColor);     
               dls(aX2,aY1,aX2,aY2,aColor);                
            }               
      }
      void Fill(int aX,int aY,int aColor){
         aColor=ConvertColor(aColor);
         int aColorToChange=Line[aY].Pixel[aX];
         Dot a[];
         ArrayResize(a,1);
         a[0].x=aX;
         a[0].y=aY;
         Line[aY].Pixel[aX]=aColor;
         int ss=0;
            for(int i=0;i<ArraySize(a);i++){
                  Line[a[i].y].Pixel[a[i].x]=aColor;
                  int X=a[i].x+1;
                     if(X<m_SizeX){
                        if(Line[a[i].y].Pixel[X]==aColorToChange){
                           Line[a[i].y].Pixel[X]=aColor;
                           ArrayResize(a,ArraySize(a)+1);
                           a[ArraySize(a)-1].x=X;
                           a[ArraySize(a)-1].y=a[i].y;
                        }
                     }
                  X=a[i].x-1;
                     if(X>=0){
                        if(Line[a[i].y].Pixel[X]==aColorToChange){
                           Line[a[i].y].Pixel[X]=aColor;
                           ArrayResize(a,ArraySize(a)+1);
                           a[ArraySize(a)-1].x=X;
                           a[ArraySize(a)-1].y=a[i].y;
                        }
                     }                  
                  int Y=a[i].y+1;
                     if(Y<m_SizeY){
                        if(Line[Y].Pixel[a[i].x]==aColorToChange){
                           Line[Y].Pixel[a[i].x]=aColor;
                           ArrayResize(a,ArraySize(a)+1);
                           a[ArraySize(a)-1].x=a[i].x;
                           a[ArraySize(a)-1].y=Y;
                        }
                     } 
                  Y=a[i].y-1;
                     if(Y>=0){
                        if(Line[Y].Pixel[a[i].x]==aColorToChange){
                           Line[Y].Pixel[a[i].x]=aColor;
                           ArrayResize(a,ArraySize(a)+1);
                           a[ArraySize(a)-1].x=a[i].x;
                           a[ArraySize(a)-1].y=Y;
                        }
                     } 
            }
      }
      void DrawCircle(int aX,int aY,int aRadius1,int aRadius2,int aColor,double aRatio=1,double aAngleFrom=0,double aAngleTo=0,bool aSolid=false){
         int m_sz=0;    
         int m_ox1=0;
         int m_oy1=0;
         int m_ox2=0;
         int m_oy2=0;
         int m_ix1=0;
         int m_iy1=0;
         int m_ix2=0;
         int m_iy2=0;
         int m_ii=0; 
         double u[];    
         double u2[];         
         int aRadius=MathMax(aRadius1,aRadius2);
         int size=(aRadius+1)*4;
         ArrayResize(u,size);
            for(int i=aRadius;i>=0;i--){
               u[m_ii]=i;
               u[m_ii]/=aRadius;
               u[m_ii]=MathArccos(u[m_ii]);
               m_ii++;
            }
            for(int i=0;i>=-aRadius;i--){
               u[m_ii]=i;
               u[m_ii]/=aRadius;
               u[m_ii]=MathArccos(u[m_ii]); 
               m_ii++;
            }
            for(int i=-aRadius;i<=0;i++){
               u[m_ii]=i;
               u[m_ii]/=aRadius;
               u[m_ii]=m_tp-MathArccos(u[m_ii]); 
               m_ii++;
            }
            for(int i=0;i<=aRadius;i++){
               u[m_ii]=i;
               u[m_ii]/=aRadius;
               u[m_ii]=m_tp-MathArccos(u[m_ii]); 
               m_ii++;
            }              
            if(aAngleFrom!=aAngleTo){
               aAngleFrom-=MathFloor(aAngleFrom/m_tp)*m_tp;
               aAngleTo-=MathFloor(aAngleTo/m_tp)*m_tp;
               ArrayResize(u2,ArraySize(u));
                  if(aAngleFrom<aAngleTo){
                       for(int i=0;i<ArraySize(u);i++){ 
                           if(u[i]>=aAngleFrom){
                              u2[m_sz]=u[i];
                              m_sz++;
                           }
                           if(u[i]>aAngleTo){
                              break;
                           }                           
                       }
                    ArrayResize(u,m_sz);
                    ArrayCopy(u,u2,0,0,m_sz);
                  }
                  else{
                       for(int i=0;i<ArraySize(u);i++){ 
                           if(u[i]>=aAngleFrom){
                              u2[m_sz]=u[i];
                              m_sz++;
                           }
                       }
                       for(int i=0;i<ArraySize(u);i++){ 
                           if(u[i]<=aAngleTo){
                              u2[m_sz]=u[i];
                              m_sz++;
                           }
                       }  
                    ArrayResize(u,m_sz);
                    ArrayCopy(u,u2,0,0,m_sz);                                            
                  }
            }       
            for(int i=1;i<ArraySize(u);i++){
                  m_ox1=aX+(int)MathRound(MathCos(u[i])*aRadius1);
                  m_oy1=aY+(int)MathRound(MathSin(u[i])*aRadius1*aRatio);
                  m_ox2=aX+(int)MathRound(MathCos(u[i-1])*aRadius1);
                  m_oy2=aY+(int)MathRound(MathSin(u[i-1])*aRadius1*aRatio);
                  DrawLine(m_ox1,m_oy1,m_ox2,m_oy2,aColor);
                  m_ix1=aX+(int)MathRound(MathCos(u[i])*aRadius2);
                  m_iy1=aY+(int)MathRound(MathSin(u[i])*aRadius2*aRatio);
                  m_ix2=aX+(int)MathRound(MathCos(u[i-1])*aRadius2);
                  m_iy2=aY+(int)MathRound(MathSin(u[i-1])*aRadius2*aRatio);
                  DrawLine(m_ix1,m_iy1,m_ix2,m_iy2,aColor);  
                     if(aSolid){
                        DrawTriangle(m_ox1,m_oy1,m_ox2,m_oy2,m_ix1,m_iy1,aColor,true);
                        DrawTriangle(m_ix1,m_iy1,m_ix2,m_iy2,m_ox2,m_oy2,aColor,true);
                     }                                  
            }
            if(!aSolid && aAngleFrom!=aAngleTo){
               m_ox1=aX+(int)MathRound(MathCos(u[0])*aRadius1);
               m_oy1=aY+(int)MathRound(MathSin(u[0])*aRadius1*aRatio); 
               m_ix1=aX+(int)MathRound(MathCos(u[0])*aRadius2);
               m_iy1=aY+(int)MathRound(MathSin(u[0])*aRadius2*aRatio);                                      
               DrawLine(m_ix1,m_iy1,m_ox1,m_oy1,aColor);
               m_sz--;
               m_ox1=aX+(int)MathRound(MathCos(u[m_sz])*aRadius1);
               m_oy1=aY+(int)MathRound(MathSin(u[m_sz])*aRadius1*aRatio); 
               m_ix1=aX+(int)MathRound(MathCos(u[m_sz])*aRadius2);
               m_iy1=aY+(int)MathRound(MathSin(u[m_sz])*aRadius2*aRatio);                                      
               DrawLine(m_ix1,m_iy1,m_ox1,m_oy1,aColor);
            }
      }
      void TypeText(int aX,int aY,string aText,int aColor){
         int dw=m_dw;
         m_dw=1;
            for(int j=0;j<StringLen(aText);j++){
               string TypeChar=StringSubstr(aText,j,1);               
                  if(TypeChar==" "){
                     aX+=5;
                  }
                  else{
                     int Pointer=0;
                        for(int i=0;i<ArraySize(CA);i++){
                           if(CA[i]==TypeChar){
                              Pointer=i;
                           }
                        }
                        for(int i=PA[Pointer];i<PA[Pointer+1];i++){
                           DrawDot(aX+XA[i],aY+MaxHeight-YA[i],aColor);
                        }
                     aX+=WA[Pointer]+1;                        
                  }
            }
         m_dw=dw;
      }      
};