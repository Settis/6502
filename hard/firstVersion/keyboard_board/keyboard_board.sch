EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L myLib:myBus J2
U 1 1 60716115
P 4000 5450
F 0 "J2" H 3950 5177 50  0000 C CNN
F 1 "myBus" H 3950 5086 50  0000 C CNN
F 2 "" H 2950 6150 50  0001 C CNN
F 3 "" H 2950 6150 50  0001 C CNN
	1    4000 5450
	1    0    0    -1  
$EndComp
$Comp
L myLib:W65C51N U1
U 1 1 60717187
P 3250 3400
F 0 "U1" H 3225 4265 50  0000 C CNN
F 1 "W65C51N" H 3225 4174 50  0000 C CNN
F 2 "" H 3150 4150 50  0001 C CNN
F 3 "" H 3150 4150 50  0001 C CNN
	1    3250 3400
	1    0    0    -1  
$EndComp
$Comp
L 74xx_IEEE:74HC238 U2
U 1 1 60715917
P 5550 3150
F 0 "U2" H 5550 3666 50  0000 C CNN
F 1 "74HC238" H 5550 3575 50  0000 C CNN
F 2 "" H 5550 3150 50  0001 C CNN
F 3 "" H 5550 3150 50  0001 C CNN
	1    5550 3150
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D1
U 1 1 6071659A
P 6600 3450
F 0 "D1" H 6593 3195 50  0000 C CNN
F 1 "LED" H 6593 3286 50  0000 C CNN
F 2 "" H 6600 3450 50  0001 C CNN
F 3 "~" H 6600 3450 50  0001 C CNN
	1    6600 3450
	-1   0    0    1   
$EndComp
$Comp
L Device:R R1
U 1 1 607171D6
P 7100 3450
F 0 "R1" V 6893 3450 50  0000 C CNN
F 1 "R" V 6984 3450 50  0000 C CNN
F 2 "" V 7030 3450 50  0001 C CNN
F 3 "~" H 7100 3450 50  0001 C CNN
	1    7100 3450
	0    1    1    0   
$EndComp
$Comp
L Connector:Mini-DIN-6 J1
U 1 1 6071A58D
P 1400 3350
F 0 "J1" H 1400 3717 50  0000 C CNN
F 1 "PS/2" H 1400 3626 50  0000 C CNN
F 2 "" H 1400 3350 50  0001 C CNN
F 3 "http://service.powerdynamics.com/ec/Catalog17/Section%2011.pdf" H 1400 3350 50  0001 C CNN
	1    1400 3350
	1    0    0    -1  
$EndComp
NoConn ~ 1100 3250
NoConn ~ 1100 3450
$Comp
L power:+5V #PWR0101
U 1 1 6071BA7E
P 950 3250
F 0 "#PWR0101" H 950 3100 50  0001 C CNN
F 1 "+5V" H 965 3423 50  0000 C CNN
F 2 "" H 950 3250 50  0001 C CNN
F 3 "" H 950 3250 50  0001 C CNN
	1    950  3250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 6071C9F8
P 1850 3600
F 0 "#PWR0102" H 1850 3350 50  0001 C CNN
F 1 "GND" H 1855 3427 50  0000 C CNN
F 2 "" H 1850 3600 50  0001 C CNN
F 3 "" H 1850 3600 50  0001 C CNN
	1    1850 3600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0103
U 1 1 6071D031
P 1900 5400
F 0 "#PWR0103" H 1900 5150 50  0001 C CNN
F 1 "GND" H 1905 5227 50  0000 C CNN
F 2 "" H 1900 5400 50  0001 C CNN
F 3 "" H 1900 5400 50  0001 C CNN
	1    1900 5400
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0104
U 1 1 6071D41F
P 1900 4900
F 0 "#PWR0104" H 1900 4750 50  0001 C CNN
F 1 "+5V" H 1915 5073 50  0000 C CNN
F 2 "" H 1900 4900 50  0001 C CNN
F 3 "" H 1900 4900 50  0001 C CNN
	1    1900 4900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0105
U 1 1 6071DBCB
P 7400 3600
F 0 "#PWR0105" H 7400 3350 50  0001 C CNN
F 1 "GND" H 7405 3427 50  0000 C CNN
F 2 "" H 7400 3600 50  0001 C CNN
F 3 "" H 7400 3600 50  0001 C CNN
	1    7400 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	6100 3450 6350 3450
Wire Wire Line
	6750 3450 6950 3450
Wire Wire Line
	7250 3450 7300 3450
Wire Wire Line
	7400 3450 7400 3600
Wire Wire Line
	2100 5050 2450 5050
Wire Wire Line
	2450 5050 2450 5150
Wire Wire Line
	2350 5150 2350 4950
Wire Wire Line
	2350 4950 1900 4950
Wire Wire Line
	1900 4950 1900 4900
Wire Wire Line
	1850 3350 1850 3600
Wire Wire Line
	1700 3350 1850 3350
Wire Wire Line
	950  3250 950  3350
Wire Wire Line
	950  3350 1100 3350
Wire Wire Line
	1700 3450 2100 3450
Wire Wire Line
	2100 3450 2100 3900
Wire Wire Line
	2100 3900 2800 3900
Wire Wire Line
	2800 3300 1950 3300
Wire Wire Line
	1950 3300 1950 3250
Wire Wire Line
	1950 3250 1700 3250
Wire Wire Line
	5550 3750 5550 3850
Wire Wire Line
	5550 3850 7300 3850
Wire Wire Line
	7300 3850 7300 3450
Connection ~ 7300 3450
Wire Wire Line
	7300 3450 7400 3450
$Comp
L power:+5V #PWR0106
U 1 1 60723306
P 4800 2650
F 0 "#PWR0106" H 4800 2500 50  0001 C CNN
F 1 "+5V" H 4815 2823 50  0000 C CNN
F 2 "" H 4800 2650 50  0001 C CNN
F 3 "" H 4800 2650 50  0001 C CNN
	1    4800 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	4800 2650 5550 2650
Wire Wire Line
	5550 2650 5550 2850
Wire Wire Line
	5000 3250 4800 3250
Wire Wire Line
	4800 3250 4800 2650
Connection ~ 4800 2650
$Comp
L power:GND #PWR0107
U 1 1 60725146
P 4700 3150
F 0 "#PWR0107" H 4700 2900 50  0001 C CNN
F 1 "GND" H 4705 2977 50  0000 C CNN
F 2 "" H 4700 3150 50  0001 C CNN
F 3 "" H 4700 3150 50  0001 C CNN
	1    4700 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	5000 3100 4700 3100
Wire Wire Line
	4700 3100 4700 3150
Wire Wire Line
	4700 3100 4700 2950
Wire Wire Line
	4700 2950 5000 2950
Connection ~ 4700 3100
Wire Wire Line
	6350 3450 6350 3700
Wire Wire Line
	6350 3700 6550 3700
Connection ~ 6350 3450
Wire Wire Line
	6350 3450 6450 3450
Text Label 6550 3700 0    50   ~ 0
CS
Text Label 2800 2900 2    50   ~ 0
CS
$Comp
L power:GND #PWR0108
U 1 1 60727549
P 2450 2800
F 0 "#PWR0108" H 2450 2550 50  0001 C CNN
F 1 "GND" H 2455 2627 50  0000 C CNN
F 2 "" H 2450 2800 50  0001 C CNN
F 3 "" H 2450 2800 50  0001 C CNN
	1    2450 2800
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 2800 2650 2800
Wire Wire Line
	2800 3000 2650 3000
Wire Wire Line
	2650 3000 2650 2800
Connection ~ 2650 2800
Wire Wire Line
	2650 2800 2450 2800
Text Label 5000 3500 2    50   ~ 0
A15
Text Label 5000 3600 2    50   ~ 0
A14
Text Label 5000 3700 2    50   ~ 0
A5
Text Label 2550 5150 1    50   ~ 0
A15
Text Label 2650 5150 1    50   ~ 0
A14
Text Label 3550 5150 1    50   ~ 0
A5
Text Label 3950 5150 1    50   ~ 0
A1
Text Label 4050 5150 1    50   ~ 0
A0
Text Label 2800 4000 2    50   ~ 0
A0
Text Label 2800 4100 2    50   ~ 0
A1
NoConn ~ 2750 5150
NoConn ~ 2850 5150
NoConn ~ 2950 5150
NoConn ~ 3050 5150
NoConn ~ 3150 5150
NoConn ~ 3250 5150
NoConn ~ 3350 5150
NoConn ~ 3450 5150
NoConn ~ 3650 5150
NoConn ~ 3750 5150
NoConn ~ 3850 5150
$Comp
L power:+5V #PWR0109
U 1 1 6073124D
P 3400 4400
F 0 "#PWR0109" H 3400 4250 50  0001 C CNN
F 1 "+5V" H 3415 4573 50  0000 C CNN
F 2 "" H 3400 4400 50  0001 C CNN
F 3 "" H 3400 4400 50  0001 C CNN
	1    3400 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3650 4100 3650 4500
Wire Wire Line
	3650 4500 3400 4500
Wire Wire Line
	3400 4500 3400 4400
Text Label 5050 5150 1    50   ~ 0
RWB
Text Label 3650 2800 0    50   ~ 0
RWB
Text Label 4950 5150 1    50   ~ 0
Clock
Text Label 3650 2900 0    50   ~ 0
Clock
Text Label 5450 5150 1    50   ~ 0
IRQ
Text Label 3650 3000 0    50   ~ 0
IRQ
NoConn ~ 6100 2950
NoConn ~ 6100 3050
NoConn ~ 6100 3150
NoConn ~ 6100 3250
NoConn ~ 6100 3350
NoConn ~ 6100 3550
NoConn ~ 6100 3650
Text Label 5150 5150 1    50   ~ 0
RESB
Text Label 2800 3100 2    50   ~ 0
RESB
NoConn ~ 2800 3200
NoConn ~ 2800 3700
NoConn ~ 2800 3400
NoConn ~ 5550 5150
NoConn ~ 5350 5150
NoConn ~ 5250 5150
Wire Wire Line
	4850 5150 4850 4900
Wire Wire Line
	4750 5150 4750 4900
Wire Wire Line
	4650 5150 4650 4900
Wire Wire Line
	4550 5150 4550 4900
Wire Wire Line
	4450 5150 4450 4900
Wire Wire Line
	4350 5150 4350 4900
Wire Wire Line
	4250 5150 4250 4900
Wire Wire Line
	4150 5150 4150 4900
Entry Wire Line
	4050 4800 4150 4900
Entry Wire Line
	4150 4800 4250 4900
Entry Wire Line
	4250 4800 4350 4900
Entry Wire Line
	4350 4800 4450 4900
Entry Wire Line
	4450 4800 4550 4900
Entry Wire Line
	4550 4800 4650 4900
Entry Wire Line
	4650 4800 4750 4900
Entry Wire Line
	4750 4800 4850 4900
Entry Wire Line
	3900 3100 4000 3200
Entry Wire Line
	3900 3200 4000 3300
Entry Wire Line
	3900 3300 4000 3400
Entry Wire Line
	3900 3400 4000 3500
Entry Wire Line
	3900 3500 4000 3600
Entry Wire Line
	3900 3600 4000 3700
Entry Wire Line
	3900 3700 4000 3800
Entry Wire Line
	3900 3800 4000 3900
Wire Wire Line
	3650 3100 3900 3100
Wire Wire Line
	3650 3200 3900 3200
Wire Wire Line
	3900 3300 3650 3300
Wire Wire Line
	3650 3400 3900 3400
Wire Wire Line
	3900 3500 3650 3500
Wire Wire Line
	3650 3600 3900 3600
Wire Wire Line
	3900 3700 3650 3700
Wire Wire Line
	3650 3800 3900 3800
Text Label 3700 3100 0    50   ~ 0
D7
Text Label 3700 3200 0    50   ~ 0
D6
Text Label 3700 3300 0    50   ~ 0
D5
Text Label 3700 3400 0    50   ~ 0
D4
Text Label 3700 3500 0    50   ~ 0
D3
Text Label 3700 3600 0    50   ~ 0
D2
Text Label 3700 3700 0    50   ~ 0
D1
Text Label 3700 3800 0    50   ~ 0
D0
Text Label 4150 5100 1    50   ~ 0
D7
Text Label 4250 5100 1    50   ~ 0
D6
Text Label 4350 5100 1    50   ~ 0
D5
Text Label 4450 5100 1    50   ~ 0
D4
Text Label 4550 5100 1    50   ~ 0
D3
Text Label 4650 5100 1    50   ~ 0
D2
Text Label 4750 5100 1    50   ~ 0
D1
Text Label 4850 5100 1    50   ~ 0
D0
NoConn ~ 2800 3500
$Comp
L power:+5V #PWR0110
U 1 1 60754CCE
P 2550 3550
F 0 "#PWR0110" H 2550 3400 50  0001 C CNN
F 1 "+5V" H 2565 3723 50  0000 C CNN
F 2 "" H 2550 3550 50  0001 C CNN
F 3 "" H 2550 3550 50  0001 C CNN
	1    2550 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 3600 2550 3600
Wire Wire Line
	2550 3600 2550 3550
NoConn ~ 2800 3800
$Comp
L power:GND #PWR0111
U 1 1 607575D3
P 3850 4050
F 0 "#PWR0111" H 3850 3800 50  0001 C CNN
F 1 "GND" H 3855 3877 50  0000 C CNN
F 2 "" H 3850 4050 50  0001 C CNN
F 3 "" H 3850 4050 50  0001 C CNN
	1    3850 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3650 3900 3850 3900
Wire Wire Line
	3850 3900 3850 4000
Wire Wire Line
	3650 4000 3850 4000
Connection ~ 3850 4000
Wire Wire Line
	3850 4000 3850 4050
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 6075A813
P 1900 4950
F 0 "#FLG0101" H 1900 5025 50  0001 C CNN
F 1 "PWR_FLAG" H 1900 5123 50  0000 C CNN
F 2 "" H 1900 4950 50  0001 C CNN
F 3 "~" H 1900 4950 50  0001 C CNN
	1    1900 4950
	-1   0    0    1   
$EndComp
Connection ~ 1900 4950
Wire Wire Line
	2100 5400 1900 5400
Wire Wire Line
	2100 5050 2100 5400
Wire Bus Line
	4000 3200 4000 4800
Wire Bus Line
	4000 4800 4750 4800
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 6075FBEB
P 1900 5400
F 0 "#FLG0102" H 1900 5475 50  0001 C CNN
F 1 "PWR_FLAG" H 1900 5573 50  0000 C CNN
F 2 "" H 1900 5400 50  0001 C CNN
F 3 "~" H 1900 5400 50  0001 C CNN
	1    1900 5400
	1    0    0    -1  
$EndComp
Connection ~ 1900 5400
$EndSCHEMATC
