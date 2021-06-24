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
L 6502:71256SA U1
U 1 1 60C3AE78
P 2800 2250
F 0 "U1" H 2800 3215 50  0000 C CNN
F 1 "71256SA" H 2800 3124 50  0000 C CNN
F 2 "" H 2800 2850 50  0001 C CNN
F 3 "" H 2800 2850 50  0001 C CNN
	1    2800 2250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR05
U 1 1 60C3EA2F
P 2350 3100
F 0 "#PWR05" H 2350 2850 50  0001 C CNN
F 1 "GND" H 2355 2927 50  0000 C CNN
F 2 "" H 2350 3100 50  0001 C CNN
F 3 "" H 2350 3100 50  0001 C CNN
	1    2350 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2350 2850 2350 3000
$Comp
L power:+5V #PWR06
U 1 1 60C3F0A0
P 3300 850
F 0 "#PWR06" H 3300 700 50  0001 C CNN
F 1 "+5V" H 3315 1023 50  0000 C CNN
F 2 "" H 3300 850 50  0001 C CNN
F 3 "" H 3300 850 50  0001 C CNN
	1    3300 850 
	1    0    0    -1  
$EndComp
Wire Wire Line
	3250 1550 3300 1550
Wire Wire Line
	2350 2550 2150 2550
Text Label 2200 2550 0    50   ~ 0
D0
Wire Wire Line
	2350 2650 2150 2650
Wire Wire Line
	2350 2750 2150 2750
Wire Wire Line
	3250 2450 3450 2450
Wire Wire Line
	3250 2550 3450 2550
Wire Wire Line
	3250 2650 3450 2650
Wire Wire Line
	3250 2750 3450 2750
Wire Wire Line
	3250 2850 3450 2850
Entry Wire Line
	2050 2650 2150 2550
Entry Wire Line
	2050 2750 2150 2650
Entry Wire Line
	2050 2850 2150 2750
Entry Wire Line
	3450 2450 3550 2550
Entry Wire Line
	3450 2550 3550 2650
Entry Wire Line
	3450 2650 3550 2750
Entry Wire Line
	3450 2750 3550 2850
Entry Wire Line
	3450 2850 3550 2950
Entry Wire Line
	3550 1750 3650 1850
Entry Wire Line
	3550 1850 3650 1950
Entry Wire Line
	3550 1950 3650 2050
Entry Wire Line
	3550 2050 3650 2150
Entry Wire Line
	3550 2250 3650 2350
Entry Wire Line
	1950 1750 2050 1650
Entry Wire Line
	1950 1850 2050 1750
Entry Wire Line
	1950 1950 2050 1850
Entry Wire Line
	1950 2050 2050 1950
Entry Wire Line
	1950 2150 2050 2050
Entry Wire Line
	1950 2250 2050 2150
Entry Wire Line
	1950 2350 2050 2250
Entry Wire Line
	1950 2450 2050 2350
Entry Wire Line
	1950 2550 2050 2450
Wire Wire Line
	3250 1750 3550 1750
Wire Wire Line
	3550 1850 3250 1850
Wire Wire Line
	3250 1950 3550 1950
Wire Wire Line
	3550 2050 3250 2050
Wire Wire Line
	3250 2250 3550 2250
Wire Wire Line
	2350 1650 2050 1650
Wire Wire Line
	2050 1750 2350 1750
Wire Wire Line
	2350 1850 2050 1850
Wire Wire Line
	2050 1950 2350 1950
Wire Wire Line
	2350 2050 2050 2050
Wire Wire Line
	2050 2150 2350 2150
Wire Wire Line
	2350 2250 2050 2250
Wire Wire Line
	2050 2350 2350 2350
Wire Wire Line
	2350 2450 2050 2450
Text Label 4100 1650 2    50   ~ 0
A14
Text Label 2150 1650 0    50   ~ 0
A12
Text Label 2150 1750 0    50   ~ 0
A7
Text Label 2150 1850 0    50   ~ 0
A6
Text Label 2150 1950 0    50   ~ 0
A5
Text Label 2150 2050 0    50   ~ 0
A4
Text Label 2150 2150 0    50   ~ 0
A3
Text Label 2150 2250 0    50   ~ 0
A2
Text Label 2150 2350 0    50   ~ 0
A1
Text Label 2150 2450 0    50   ~ 0
A0
Text Label 2200 2650 0    50   ~ 0
D1
Text Label 2200 2750 0    50   ~ 0
D2
Text Label 3300 2850 0    50   ~ 0
D3
Text Label 3300 2750 0    50   ~ 0
D4
Text Label 3300 2650 0    50   ~ 0
D5
Text Label 3300 2550 0    50   ~ 0
D6
Text Label 3300 2450 0    50   ~ 0
D7
Text Label 3350 2250 0    50   ~ 0
A10
Text Label 3350 2050 0    50   ~ 0
A11
Text Label 3350 1950 0    50   ~ 0
A9
Text Label 3350 1850 0    50   ~ 0
A8
Text Label 3350 1750 0    50   ~ 0
A13
Wire Wire Line
	3850 2150 3850 3000
Wire Wire Line
	3850 3000 2350 3000
Connection ~ 2350 3000
Wire Wire Line
	2350 3000 2350 3100
$Comp
L power:GND #PWR02
U 1 1 60C502CE
P 1000 4500
F 0 "#PWR02" H 1000 4250 50  0001 C CNN
F 1 "GND" H 1005 4327 50  0000 C CNN
F 2 "" H 1000 4500 50  0001 C CNN
F 3 "" H 1000 4500 50  0001 C CNN
	1    1000 4500
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR01
U 1 1 60C509EC
P 1000 4200
F 0 "#PWR01" H 1000 4050 50  0001 C CNN
F 1 "+5V" H 1015 4373 50  0000 C CNN
F 2 "" H 1000 4200 50  0001 C CNN
F 3 "" H 1000 4200 50  0001 C CNN
	1    1000 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	1000 4200 1000 4300
Wire Wire Line
	1000 4300 1350 4300
Wire Wire Line
	1350 4300 1350 4500
Wire Wire Line
	1450 4500 1450 4400
Wire Wire Line
	1450 4400 1000 4400
Wire Wire Line
	1000 4400 1000 4500
Text Label 1550 4500 1    50   ~ 0
A15
$Comp
L 6502:myBus J2
U 1 1 60C4CC59
P 3000 4800
F 0 "J2" H 3225 4527 50  0000 C CNN
F 1 "myBus" H 3225 4436 50  0000 C CNN
F 2 "" H 1950 5500 50  0001 C CNN
F 3 "" H 1950 5500 50  0001 C CNN
	1    3000 4800
	1    0    0    -1  
$EndComp
Text Label 3150 4450 1    50   ~ 0
D7
Wire Wire Line
	3150 4500 3150 4300
Wire Wire Line
	3050 4250 3050 4500
Wire Wire Line
	2950 4500 2950 4250
Wire Wire Line
	2850 4500 2850 4250
Wire Wire Line
	2750 4500 2750 4250
Wire Wire Line
	2650 4500 2650 4250
Wire Wire Line
	2550 4500 2550 4250
Wire Wire Line
	2450 4500 2450 4250
Wire Wire Line
	2350 4500 2350 4250
Wire Wire Line
	2250 4500 2250 4250
Wire Wire Line
	2150 4500 2150 4250
Wire Wire Line
	2050 4500 2050 4250
Wire Wire Line
	1950 4500 1950 4250
Wire Wire Line
	1850 4250 1850 4500
Wire Wire Line
	1750 4500 1750 4250
Wire Wire Line
	3250 4300 3250 4500
Wire Wire Line
	3350 4500 3350 4300
Wire Wire Line
	3450 4500 3450 4300
Wire Wire Line
	3550 4500 3550 4300
Wire Wire Line
	3650 4500 3650 4300
Wire Wire Line
	3750 4300 3750 4500
Wire Wire Line
	3850 4500 3850 4300
Text Label 3950 4500 1    50   ~ 0
Clock
Text Label 3250 4450 1    50   ~ 0
D6
Text Label 3350 4450 1    50   ~ 0
D5
Text Label 3450 4450 1    50   ~ 0
D4
Text Label 3550 4450 1    50   ~ 0
D3
Text Label 3650 4450 1    50   ~ 0
D2
Text Label 3750 4450 1    50   ~ 0
D1
Text Label 3850 4450 1    50   ~ 0
D0
Text Label 3050 4450 1    50   ~ 0
A0
Text Label 2950 4450 1    50   ~ 0
A1
Text Label 2850 4450 1    50   ~ 0
A2
Text Label 2750 4450 1    50   ~ 0
A3
Text Label 2650 4450 1    50   ~ 0
A4
Text Label 2550 4450 1    50   ~ 0
A5
Text Label 2450 4450 1    50   ~ 0
A6
Text Label 2350 4450 1    50   ~ 0
A7
Text Label 2250 4450 1    50   ~ 0
A8
Text Label 2150 4450 1    50   ~ 0
A9
Text Label 2050 4450 1    50   ~ 0
A10
Text Label 1950 4450 1    50   ~ 0
A11
Text Label 1850 4450 1    50   ~ 0
A12
Text Label 1750 4450 1    50   ~ 0
A13
Text Label 1650 4500 1    50   ~ 0
A14
Entry Wire Line
	3850 4300 3950 4200
Entry Wire Line
	3750 4300 3850 4200
Entry Wire Line
	3650 4300 3750 4200
Entry Wire Line
	3550 4300 3650 4200
Entry Wire Line
	3450 4300 3550 4200
Entry Wire Line
	3350 4300 3450 4200
Entry Wire Line
	3250 4300 3350 4200
Entry Wire Line
	3150 4300 3250 4200
Entry Wire Line
	3050 4250 3150 4150
Entry Wire Line
	2950 4250 3050 4150
Entry Wire Line
	2850 4250 2950 4150
Entry Wire Line
	2750 4250 2850 4150
Entry Wire Line
	2650 4250 2750 4150
Entry Wire Line
	2550 4250 2650 4150
Entry Wire Line
	2450 4250 2550 4150
Entry Wire Line
	2350 4250 2450 4150
Entry Wire Line
	2250 4250 2350 4150
Entry Wire Line
	2150 4250 2250 4150
Entry Wire Line
	2050 4250 2150 4150
Entry Wire Line
	1950 4250 2050 4150
Entry Wire Line
	1850 4250 1950 4150
Entry Wire Line
	1750 4250 1850 4150
NoConn ~ 4150 4500
NoConn ~ 4250 4500
NoConn ~ 4350 4500
NoConn ~ 4450 4500
NoConn ~ 4550 4500
NoConn ~ 4750 4500
NoConn ~ 4850 4500
NoConn ~ 4950 4500
NoConn ~ 5050 4500
NoConn ~ 5150 4500
Wire Bus Line
	2050 3400 3550 3400
Wire Bus Line
	4550 3400 4550 4200
Connection ~ 3550 3400
Wire Bus Line
	3550 3400 4550 3400
Wire Bus Line
	1950 3650 3650 3650
Wire Bus Line
	3650 3650 3650 4150
Connection ~ 3650 3650
Wire Wire Line
	3300 850  3300 1000
$Comp
L 6502:4NAND U2
U 1 1 60CAC8E6
P 4700 1850
F 0 "U2" H 4675 2415 50  0000 C CNN
F 1 "4NAND" H 4675 2324 50  0000 C CNN
F 2 "" H 4600 2300 50  0001 C CNN
F 3 "" H 4600 2300 50  0001 C CNN
	1    4700 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	4300 2150 3850 2150
Connection ~ 3850 2150
Wire Wire Line
	3300 1000 3750 1000
Wire Wire Line
	4000 1000 4000 1200
Wire Wire Line
	4000 1200 5250 1200
Wire Wire Line
	5250 1200 5250 1550
Wire Wire Line
	5250 1550 5050 1550
Connection ~ 3300 1000
Wire Wire Line
	3300 1000 3300 1550
Text Label 4100 1550 2    50   ~ 0
A15
Wire Wire Line
	4300 1750 4200 1750
Wire Wire Line
	4200 1750 4200 1850
Wire Wire Line
	4200 1850 4300 1850
Text Label 5350 1950 0    50   ~ 0
Clock
Wire Wire Line
	4300 2050 4200 2050
Wire Wire Line
	5250 1650 5050 1650
Wire Wire Line
	5250 1650 5250 1750
Wire Wire Line
	5250 1750 5050 1750
$Comp
L Device:LED D1
U 1 1 60CC7D5C
P 5750 1850
F 0 "D1" H 5743 1595 50  0000 C CNN
F 1 "LED" H 5743 1686 50  0000 C CNN
F 2 "" H 5750 1850 50  0001 C CNN
F 3 "~" H 5750 1850 50  0001 C CNN
	1    5750 1850
	-1   0    0    1   
$EndComp
$Comp
L Device:R R2
U 1 1 60CC8177
P 6100 1850
F 0 "R2" V 5893 1850 50  0000 C CNN
F 1 "R" V 5984 1850 50  0000 C CNN
F 2 "" V 6030 1850 50  0001 C CNN
F 3 "~" H 6100 1850 50  0001 C CNN
	1    6100 1850
	0    1    1    0   
$EndComp
Wire Wire Line
	5900 1850 5950 1850
Wire Wire Line
	6250 1850 6350 1850
Wire Wire Line
	6350 1850 6350 2050
$Comp
L power:GND #PWR09
U 1 1 60CCD621
P 6350 2050
F 0 "#PWR09" H 6350 1800 50  0001 C CNN
F 1 "GND" H 6355 1877 50  0000 C CNN
F 2 "" H 6350 2050 50  0001 C CNN
F 3 "" H 6350 2050 50  0001 C CNN
	1    6350 2050
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR07
U 1 1 60CCFF23
P 6100 3150
F 0 "#PWR07" H 6100 3000 50  0001 C CNN
F 1 "+5V" H 6115 3323 50  0000 C CNN
F 2 "" H 6100 3150 50  0001 C CNN
F 3 "" H 6100 3150 50  0001 C CNN
	1    6100 3150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR08
U 1 1 60CD04AE
P 6100 3600
F 0 "#PWR08" H 6100 3350 50  0001 C CNN
F 1 "GND" H 6105 3427 50  0000 C CNN
F 2 "" H 6100 3600 50  0001 C CNN
F 3 "" H 6100 3600 50  0001 C CNN
	1    6100 3600
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG02
U 1 1 60CD23FE
P 6300 3150
F 0 "#FLG02" H 6300 3225 50  0001 C CNN
F 1 "PWR_FLAG" H 6300 3323 50  0000 C CNN
F 2 "" H 6300 3150 50  0001 C CNN
F 3 "~" H 6300 3150 50  0001 C CNN
	1    6300 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6100 3150 6300 3150
$Comp
L power:PWR_FLAG #FLG01
U 1 1 60CD8036
P 6100 3500
F 0 "#FLG01" H 6100 3575 50  0001 C CNN
F 1 "PWR_FLAG" H 6100 3673 50  0000 C CNN
F 2 "" H 6100 3500 50  0001 C CNN
F 3 "~" H 6100 3500 50  0001 C CNN
	1    6100 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6100 3500 6100 3600
Wire Wire Line
	4200 1850 4200 1950
Wire Wire Line
	4200 1950 4300 1950
Connection ~ 4200 1850
Wire Wire Line
	4100 1550 4300 1550
Wire Wire Line
	4100 1650 4300 1650
Wire Wire Line
	5050 2150 5250 2150
Wire Wire Line
	5250 2150 5250 2350
Wire Wire Line
	4200 2050 4200 2300
Wire Wire Line
	4200 2300 5150 2300
Wire Wire Line
	5150 2300 5150 2050
Wire Wire Line
	5150 2050 5050 2050
Wire Wire Line
	5350 1950 5050 1950
Wire Wire Line
	5250 1750 5250 2150
Connection ~ 5250 1750
Connection ~ 5250 2150
Wire Wire Line
	5050 1850 5600 1850
$Comp
L power:+5V #PWR03
U 1 1 60D06901
P 1250 1350
F 0 "#PWR03" H 1250 1200 50  0001 C CNN
F 1 "+5V" H 1265 1523 50  0000 C CNN
F 2 "" H 1250 1350 50  0001 C CNN
F 3 "" H 1250 1350 50  0001 C CNN
	1    1250 1350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR04
U 1 1 60D06F66
P 1250 1700
F 0 "#PWR04" H 1250 1450 50  0001 C CNN
F 1 "GND" H 1255 1527 50  0000 C CNN
F 2 "" H 1250 1700 50  0001 C CNN
F 3 "" H 1250 1700 50  0001 C CNN
	1    1250 1700
	1    0    0    -1  
$EndComp
$Comp
L Connector:XLR3_Switched J1
U 2 1 60D12038
P 1700 1550
F 0 "J1" H 1700 1183 50  0000 C CNN
F 1 "XLR3_Switched" H 1700 1274 50  0000 C CNN
F 2 "" H 1700 1650 50  0001 C CNN
F 3 " ~" H 1700 1650 50  0001 C CNN
	2    1700 1550
	-1   0    0    1   
$EndComp
Wire Wire Line
	2350 1550 2000 1550
Wire Wire Line
	1250 1350 1250 1450
Wire Wire Line
	1250 1450 1400 1450
Wire Wire Line
	1400 1650 1250 1650
Wire Wire Line
	1250 1650 1250 1700
$Comp
L Device:R R1
U 1 1 60C51E73
P 3600 1300
F 0 "R1" V 3393 1300 50  0000 C CNN
F 1 "R" V 3484 1300 50  0000 C CNN
F 2 "" V 3530 1300 50  0001 C CNN
F 3 "~" H 3600 1300 50  0001 C CNN
	1    3600 1300
	0    1    1    0   
$EndComp
Wire Wire Line
	3750 1300 3750 1000
Connection ~ 3750 1000
Wire Wire Line
	3750 1000 4000 1000
Wire Wire Line
	3450 1650 3250 1650
Text Label 3450 1550 0    50   ~ 0
ROM_W
Wire Wire Line
	3450 1300 3450 1650
Text Label 4650 4500 1    50   ~ 0
ROM_W
NoConn ~ 4050 4500
NoConn ~ 1700 1550
Wire Wire Line
	3250 2350 5250 2350
Wire Wire Line
	3250 2150 3850 2150
Wire Bus Line
	2050 2650 2050 3400
Wire Bus Line
	3650 1850 3650 3650
Wire Bus Line
	3550 2550 3550 3400
Wire Bus Line
	3250 4200 4550 4200
Wire Bus Line
	1950 1750 1950 3650
Wire Bus Line
	1850 4150 3650 4150
$EndSCHEMATC
