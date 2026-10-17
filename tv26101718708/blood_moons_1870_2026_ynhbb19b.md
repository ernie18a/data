# Blood Moons (1870 - 2026)

- url: https://www.tradingview.com/script/YNhBb19B-Blood-Moons-1870-2026/
- type: indicator
- pine_id: PUB;30c6034448c2433ea4186cce69d5da0f
- version: 1.0

## Description

Blood moon dates going back to 1870 when SPX launched

## Source Code

````pine
//@version=5
indicator("Blood Moons 1870 - 2026", overlay=true, scale=scale.none)

// Function to check if the current bar matches a specific date
checkDate(y, m, d) =>
    time >= timestamp(y, m, d, 0, 0) and time < timestamp(y, m, d, 23, 59)

// Draw vertical line function
drawMoonLine() =>
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color.new(color.red, 50), style=line.style_dashed)

// Logic for dates provided in blood-moon-dates.txt
// 1870 - 1889
if checkDate(1870, 2, 5) or checkDate(1870, 7, 31) or checkDate(1871, 1, 25) or checkDate(1871, 7, 20) or checkDate(1872, 1, 15) or checkDate(1872, 7, 9) or checkDate(1873, 1, 4) or checkDate(1873, 6, 29) or checkDate(1874, 6, 18) or checkDate(1874, 12, 12)
    drawMoonLine()
if checkDate(1875, 6, 7) or checkDate(1875, 12, 1) or checkDate(1876, 5, 26) or checkDate(1876, 11, 19) or checkDate(1877, 5, 16) or checkDate(1877, 11, 9) or checkDate(1878, 5, 5) or checkDate(1878, 10, 29) or checkDate(1879, 4, 24) or checkDate(1879, 10, 18)
    drawMoonLine()
if checkDate(1880, 4, 12) or checkDate(1880, 10, 6) or checkDate(1881, 4, 1) or checkDate(1881, 15, 25) or checkDate(1882, 3, 21) or checkDate(1882, 9, 14) or checkDate(1883, 3, 10) or checkDate(1883, 9, 3) or checkDate(1884, 2, 28) or checkDate(1884, 8, 22)
    drawMoonLine()
if checkDate(1885, 2, 17) or checkDate(1885, 8, 11) or checkDate(1886, 2, 6) or checkDate(1886, 7, 31) or checkDate(1887, 1, 25) or checkDate(1887, 7, 20) or checkDate(1888, 1, 14) or checkDate(1888, 7, 8) or checkDate(1889, 1, 3) or checkDate(1889, 6, 28)
    drawMoonLine()

// 1890 - 1910
if checkDate(1890, 6, 17) or checkDate(1890, 12, 11) or checkDate(1891, 6, 6) or checkDate(1891, 11, 30) or checkDate(1892, 5, 25) or checkDate(1892, 11, 18) or checkDate(1893, 5, 15) or checkDate(1893, 11, 8) or checkDate(1894, 5, 4) or checkDate(1894, 10, 28)
    drawMoonLine()
if checkDate(1895, 4, 23) or checkDate(1895, 10, 17) or checkDate(1896, 4, 11) or checkDate(1896, 10, 5) or checkDate(1897, 3, 31) or checkDate(1897, 9, 24) or checkDate(1898, 3, 20) or checkDate(1898, 9, 13) or checkDate(1899, 3, 10) or checkDate(1899, 9, 2)
    drawMoonLine()
if checkDate(1900, 2, 28) or checkDate(1900, 8, 23) or checkDate(1901, 2, 17) or checkDate(1901, 8, 12) or checkDate(1902, 2, 6) or checkDate(1902, 8, 1) or checkDate(1903, 1, 26) or checkDate(1903, 7, 21) or checkDate(1904, 1, 15) or checkDate(1904, 7, 10)
    drawMoonLine()
if checkDate(1905, 1, 4) or checkDate(1905, 6, 29) or checkDate(1906, 6, 18) or checkDate(1906, 12, 12) or checkDate(1907, 6, 7) or checkDate(1907, 12, 1) or checkDate(1908, 5, 26) or checkDate(1908, 11, 19) or checkDate(1909, 5, 16) or checkDate(1909, 11, 9)
    drawMoonLine()

// 1910 - 1930
if checkDate(1910, 5, 5) or checkDate(1910, 10, 29) or checkDate(1911, 4, 24) or checkDate(1911, 10, 18) or checkDate(1912, 4, 12) or checkDate(1912, 10, 6) or checkDate(1913, 4, 1) or checkDate(1913, 9, 25) or checkDate(1914, 3, 21) or checkDate(1914, 9, 14)
    drawMoonLine()
if checkDate(1915, 3, 10) or checkDate(1915, 9, 3) or checkDate(1916, 2, 28) or checkDate(1916, 8, 22) or checkDate(1917, 2, 17) or checkDate(1917, 8, 11) or checkDate(1918, 2, 6) or checkDate(1918, 7, 31) or checkDate(1919, 1, 26) or checkDate(1919, 7, 20)
    drawMoonLine()
if checkDate(1920, 1, 15) or checkDate(1920, 7, 9) or checkDate(1921, 1, 3) or checkDate(1921, 6, 28) or checkDate(1922, 6, 17) or checkDate(1922, 12, 11) or checkDate(1923, 6, 7) or checkDate(1923, 12, 1) or checkDate(1924, 5, 26) or checkDate(1924, 11, 19)
    drawMoonLine()
if checkDate(1925, 5, 16) or checkDate(1925, 11, 9) or checkDate(1926, 5, 5) or checkDate(1926, 10, 29) or checkDate(1927, 4, 24) or checkDate(1927, 10, 18) or checkDate(1928, 4, 12) or checkDate(1928, 10, 6) or checkDate(1929, 4, 1) or checkDate(1929, 9, 25)
    drawMoonLine()

// 1930 - 1950
if checkDate(1930, 3, 21) or checkDate(1930, 9, 14) or checkDate(1931, 3, 10) or checkDate(1931, 9, 3) or checkDate(1932, 2, 28) or checkDate(1932, 8, 22) or checkDate(1933, 2, 17) or checkDate(1933, 8, 11) or checkDate(1934, 2, 6) or checkDate(1934, 7, 31)
    drawMoonLine()
if checkDate(1935, 1, 26) or checkDate(1935, 7, 20) or checkDate(1936, 1, 15) or checkDate(1936, 7, 9) or checkDate(1937, 1, 3) or checkDate(1937, 6, 28) or checkDate(1938, 6, 17) or checkDate(1938, 12, 11) or checkDate(1939, 6, 7) or checkDate(1939, 12, 1)
    drawMoonLine()
if checkDate(1940, 5, 26) or checkDate(1940, 11, 19) or checkDate(1941, 5, 16) or checkDate(1941, 11, 9) or checkDate(1942, 5, 5) or checkDate(1942, 10, 29) or checkDate(1943, 4, 24) or checkDate(1943, 10, 18) or checkDate(1944, 4, 12) or checkDate(1944, 10, 6)
    drawMoonLine()
if checkDate(1945, 4, 1) or checkDate(1945, 9, 25) or checkDate(1946, 3, 21) or checkDate(1946, 9, 14) or checkDate(1947, 3, 10) or checkDate(1947, 9, 3) or checkDate(1948, 2, 28) or checkDate(1948, 8, 22) or checkDate(1949, 2, 17) or checkDate(1949, 8, 11)
    drawMoonLine()

// 1950 - 1970
if checkDate(1950, 2, 6) or checkDate(1950, 7, 31) or checkDate(1951, 1, 26) or checkDate(1951, 7, 20) or checkDate(1952, 1, 15) or checkDate(1952, 7, 9) or checkDate(1953, 1, 3) or checkDate(1953, 6, 28) or checkDate(1954, 6, 17) or checkDate(1954, 12, 11)
    drawMoonLine()
if checkDate(1955, 6, 7) or checkDate(1955, 12, 1) or checkDate(1956, 5, 26) or checkDate(1956, 11, 19) or checkDate(1957, 5, 16) or checkDate(1957, 11, 9) or checkDate(1958, 5, 5) or checkDate(1958, 10, 29) or checkDate(1959, 4, 24) or checkDate(1959, 10, 18)
    drawMoonLine()
if checkDate(1960, 4, 12) or checkDate(1960, 10, 6) or checkDate(1961, 4, 1) or checkDate(1961, 9, 25) or checkDate(1962, 3, 21) or checkDate(1962, 9, 14) or checkDate(1963, 3, 10) or checkDate(1963, 9, 3) or checkDate(1964, 2, 28) or checkDate(1964, 8, 22)
    drawMoonLine()
if checkDate(1965, 2, 17) or checkDate(1965, 8, 11) or checkDate(1966, 2, 6) or checkDate(1966, 7, 31) or checkDate(1967, 1, 26) or checkDate(1967, 7, 20) or checkDate(1968, 1, 15) or checkDate(1968, 7, 9) or checkDate(1969, 1, 3) or checkDate(1969, 6, 28)
    drawMoonLine()

// 1970 - 1990
if checkDate(1970, 6, 17) or checkDate(1970, 12, 11) or checkDate(1971, 6, 7) or checkDate(1971, 12, 1) or checkDate(1972, 5, 26) or checkDate(1972, 11, 19) or checkDate(1973, 5, 16) or checkDate(1973, 11, 9) or checkDate(1974, 5, 5) or checkDate(1974, 10, 29)
    drawMoonLine()
if checkDate(1975, 4, 24) or checkDate(1975, 10, 18) or checkDate(1976, 4, 12) or checkDate(1976, 10, 6) or checkDate(1977, 4, 1) or checkDate(1977, 9, 25) or checkDate(1978, 3, 21) or checkDate(1978, 9, 14) or checkDate(1979, 3, 10) or checkDate(1979, 9, 3)
    drawMoonLine()
if checkDate(1980, 2, 28) or checkDate(1980, 8, 22) or checkDate(1981, 2, 17) or checkDate(1981, 8, 11) or checkDate(1982, 2, 6) or checkDate(1982, 7, 31) or checkDate(1983, 1, 26) or checkDate(1983, 7, 20) or checkDate(1984, 1, 15) or checkDate(1984, 7, 9)
    drawMoonLine()
if checkDate(1985, 1, 3) or checkDate(1985, 6, 28) or checkDate(1986, 6, 17) or checkDate(1986, 12, 11) or checkDate(1987, 6, 7) or checkDate(1987, 12, 1) or checkDate(1988, 5, 26) or checkDate(1988, 11, 19) or checkDate(1989, 5, 16) or checkDate(1989, 11, 9)
    drawMoonLine()

// 1990 - 2026
if checkDate(1990, 5, 5) or checkDate(1990, 10, 29) or checkDate(1991, 4, 24) or checkDate(1991, 10, 18) or checkDate(1992, 4, 12) or checkDate(1992, 10, 6) or checkDate(1993, 4, 1) or checkDate(1993, 9, 25) or checkDate(1994, 3, 21) or checkDate(1994, 9, 14)
    drawMoonLine()
if checkDate(1995, 3, 10) or checkDate(1995, 9, 3) or checkDate(1996, 2, 28) or checkDate(1996, 8, 22) or checkDate(1997, 2, 17) or checkDate(1997, 8, 11) or checkDate(1998, 2, 6) or checkDate(1998, 7, 31) or checkDate(1999, 1, 26) or checkDate(1999, 7, 20)
    drawMoonLine()
if checkDate(2000, 1, 21) or checkDate(2000, 7, 16) or checkDate(2001, 1, 9) or checkDate(2001, 7, 5) or checkDate(2003, 5, 16) or checkDate(2003, 11, 9) or checkDate(2004, 5, 4) or checkDate(2004, 10, 28) or checkDate(2007, 3, 3) or checkDate(2007, 8, 28)
    drawMoonLine()
if checkDate(2008, 2, 21) or checkDate(2008, 8, 16) or checkDate(2010, 6, 26) or checkDate(2010, 12, 21) or checkDate(2011, 6, 15) or checkDate(2011, 12, 10) or checkDate(2014, 4, 15) or checkDate(2014, 10, 8) or checkDate(2015, 4, 4) or checkDate(2015, 9, 28)
    drawMoonLine()
if checkDate(2018, 1, 31) or checkDate(2018, 7, 27) or checkDate(2019, 1, 21) or checkDate(2021, 5, 26) or checkDate(2022, 5, 16) or checkDate(2022, 11, 8) or checkDate(2025, 3, 14) or checkDate(2025, 9, 7) or checkDate(2025, 9, 8) or checkDate(2026, 3, 3)
    drawMoonLine()
````
