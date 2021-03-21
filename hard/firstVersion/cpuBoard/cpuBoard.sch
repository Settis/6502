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
L Switch:SW_Push SW1
U 1 1 603F2EBD
P 4400 1550
F 0 "SW1" H 4400 1835 50  0000 C CNN
F 1 "SW_Push" H 4400 1744 50  0000 C CNN
F 2 "" H 4400 1750 50  0001 C CNN
F 3 "~" H 4400 1750 50  0001 C CNN
	1    4400 1550
	1    0    0    -1  
$EndComp
$Comp
L Device:R R5
U 1 1 603F4102
P 5150 1850
F 0 "R5" H 5220 1896 50  0000 L CNN
F 1 "3.3K" H 5220 1805 50  0000 L CNN
F 2 "" V 5080 1850 50  0001 C CNN
F 3 "~" H 5150 1850 50  0001 C CNN
	1    5150 1850
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR09
U 1 1 603F4F83
P 5150 1450
F 0 "#PWR09" H 5150 1300 50  0001 C CNN
F 1 "+5V" H 5165 1623 50  0000 C CNN
F 2 "" H 5150 1450 50  0001 C CNN
F 3 "" H 5150 1450 50  0001 C CNN
	1    5150 1450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR07
U 1 1 603F5E7D
P 4050 1700
F 0 "#PWR07" H 4050 1450 50  0001 C CNN
F 1 "GND" H 4055 1527 50  0000 C CNN
F 2 "" H 4050 1700 50  0001 C CNN
F 3 "" H 4050 1700 50  0001 C CNN
	1    4050 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	4200 1550 4050 1550
Wire Wire Line
	5150 1450 5150 1700
Wire Wire Line
	5150 2100 4600 2100
Wire Wire Line
	4600 1550 4600 2100
Connection ~ 4600 2100
Wire Wire Line
	4250 2100 4600 2100
Wire Wire Line
	5150 2000 5150 2100
Wire Wire Line
	4050 1550 4050 1700
$Comp
L Device:LED D2
U 1 1 603F7BB1
P 5250 2350
F 0 "D2" H 5243 2095 50  0000 C CNN
F 1 "RED" H 5243 2186 50  0000 C CNN
F 2 "" H 5250 2350 50  0001 C CNN
F 3 "~" H 5250 2350 50  0001 C CNN
	1    5250 2350
	-1   0    0    1   
$EndComp
$Comp
L Device:R R6
U 1 1 603FA72C
P 5650 2350
F 0 "R6" H 5720 2396 50  0000 L CNN
F 1 "330R" H 5720 2305 50  0000 L CNN
F 2 "" V 5580 2350 50  0001 C CNN
F 3 "~" H 5650 2350 50  0001 C CNN
	1    5650 2350
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR012
U 1 1 603FAE5D
P 6000 2450
F 0 "#PWR012" H 6000 2200 50  0001 C CNN
F 1 "GND" H 6005 2277 50  0000 C CNN
F 2 "" H 6000 2450 50  0001 C CNN
F 3 "" H 6000 2450 50  0001 C CNN
	1    6000 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 2200 4950 2200
Wire Wire Line
	4950 2200 4950 2350
Wire Wire Line
	4950 2350 5100 2350
Wire Wire Line
	5400 2350 5500 2350
Wire Wire Line
	5800 2350 6000 2350
Wire Wire Line
	6000 2350 6000 2450
$Comp
L power:+5V #PWR010
U 1 1 60401E94
P 5550 2850
F 0 "#PWR010" H 5550 2700 50  0001 C CNN
F 1 "+5V" H 5565 3023 50  0000 C CNN
F 2 "" H 5550 2850 50  0001 C CNN
F 3 "" H 5550 2850 50  0001 C CNN
	1    5550 2850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR011
U 1 1 604024B8
P 5600 3300
F 0 "#PWR011" H 5600 3050 50  0001 C CNN
F 1 "GND" H 5605 3127 50  0000 C CNN
F 2 "" H 5600 3300 50  0001 C CNN
F 3 "" H 5600 3300 50  0001 C CNN
	1    5600 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 2500 4800 2500
Wire Wire Line
	4800 2500 4800 3100
Wire Wire Line
	4800 3100 4900 3100
Wire Wire Line
	5500 3000 5550 3000
Wire Wire Line
	5550 3000 5550 2850
Wire Wire Line
	5500 3200 5600 3200
Wire Wire Line
	5600 3200 5600 3300
$Comp
L power:GND #PWR08
U 1 1 60403A33
P 4350 4100
F 0 "#PWR08" H 4350 3850 50  0001 C CNN
F 1 "GND" H 4355 3927 50  0000 C CNN
F 2 "" H 4350 4100 50  0001 C CNN
F 3 "" H 4350 4100 50  0001 C CNN
	1    4350 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 4000 4350 4000
Wire Wire Line
	4350 4000 4350 4100
Wire Wire Line
	2900 2300 3200 2300
Wire Wire Line
	3200 2800 2900 2800
Wire Wire Line
	2900 2800 2900 2300
Connection ~ 2900 2300
$Comp
L Device:R R3
U 1 1 60405C4D
P 2650 2250
F 0 "R3" H 2720 2296 50  0000 L CNN
F 1 "3.3K" H 2720 2205 50  0000 L CNN
F 2 "" V 2580 2250 50  0001 C CNN
F 3 "~" H 2650 2250 50  0001 C CNN
	1    2650 2250
	1    0    0    -1  
$EndComp
$Comp
L Device:R R2
U 1 1 60406704
P 2500 2450
F 0 "R2" H 2570 2496 50  0000 L CNN
F 1 "3.3K" H 2570 2405 50  0000 L CNN
F 2 "" V 2430 2450 50  0001 C CNN
F 3 "~" H 2500 2450 50  0001 C CNN
	1    2500 2450
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR06
U 1 1 60404346
P 2300 1600
F 0 "#PWR06" H 2300 1450 50  0001 C CNN
F 1 "+5V" H 2315 1773 50  0000 C CNN
F 2 "" H 2300 1600 50  0001 C CNN
F 3 "" H 2300 1600 50  0001 C CNN
	1    2300 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	2650 2100 2650 2000
Wire Wire Line
	2650 2000 2900 2000
Wire Wire Line
	2650 2000 2500 2000
Wire Wire Line
	2500 2000 2500 2300
Connection ~ 2650 2000
Wire Wire Line
	2650 2400 3200 2400
Wire Wire Line
	2500 2600 3200 2600
$Comp
L Device:LED D1
U 1 1 6040D209
P 1850 2700
F 0 "D1" H 1843 2917 50  0000 C CNN
F 1 "GREEN" H 1843 2826 50  0000 C CNN
F 2 "" H 1850 2700 50  0001 C CNN
F 3 "~" H 1850 2700 50  0001 C CNN
	1    1850 2700
	1    0    0    -1  
$EndComp
$Comp
L Device:R R1
U 1 1 6040F90D
P 1550 2700
F 0 "R1" H 1620 2746 50  0000 L CNN
F 1 "470R" H 1620 2655 50  0000 L CNN
F 2 "" V 1480 2700 50  0001 C CNN
F 3 "~" H 1550 2700 50  0001 C CNN
	1    1550 2700
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR02
U 1 1 60410193
P 1250 3000
F 0 "#PWR02" H 1250 2750 50  0001 C CNN
F 1 "GND" H 1255 2827 50  0000 C CNN
F 2 "" H 1250 3000 50  0001 C CNN
F 3 "" H 1250 3000 50  0001 C CNN
	1    1250 3000
	1    0    0    -1  
$EndComp
NoConn ~ 4250 2300
NoConn ~ 3200 2100
NoConn ~ 3200 2500
NoConn ~ 4250 2600
$Comp
L cpuBoard-rescue:w65c816s-wdc U1
U 1 1 6056A5F1
P 3750 2950
F 0 "U1" H 3750 3000 50  0000 C CNN
F 1 "w65c816s" H 3750 2850 50  0000 C CNN
F 2 "" H 4000 3700 50  0001 C CNN
F 3 "" H 4000 3700 50  0001 C CNN
	1    3750 2950
	1    0    0    -1  
$EndComp
$Comp
L custom:myBus J1
U 1 1 605782FC
P 3550 5850
F 0 "J1" H 3500 5577 50  0000 C CNN
F 1 "Jumpers" H 3500 5486 50  0000 C CNN
F 2 "" H 2500 6550 50  0001 C CNN
F 3 " ~" H 2500 6550 50  0001 C CNN
	1    3550 5850
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR04
U 1 1 605804D8
P 1650 5200
F 0 "#PWR04" H 1650 5050 50  0001 C CNN
F 1 "+5V" H 1665 5373 50  0000 C CNN
F 2 "" H 1650 5200 50  0001 C CNN
F 3 "" H 1650 5200 50  0001 C CNN
	1    1650 5200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR05
U 1 1 60584829
P 1900 5250
F 0 "#PWR05" H 1900 5000 50  0001 C CNN
F 1 "GND" H 1905 5077 50  0000 C CNN
F 2 "" H 1900 5250 50  0001 C CNN
F 3 "" H 1900 5250 50  0001 C CNN
	1    1900 5250
	1    0    0    -1  
$EndComp
Wire Wire Line
	2000 5550 2000 5250
Wire Wire Line
	2000 5250 1900 5250
Wire Wire Line
	1900 5550 1650 5550
Wire Wire Line
	1650 5550 1650 5200
Entry Wire Line
	2200 5100 2300 5000
Entry Wire Line
	2300 5100 2400 5000
Entry Wire Line
	2400 5100 2500 5000
Entry Wire Line
	2500 5100 2600 5000
Entry Wire Line
	2600 5100 2700 5000
Entry Wire Line
	2700 5100 2800 5000
Entry Wire Line
	2800 5100 2900 5000
Entry Wire Line
	2900 5100 3000 5000
Entry Wire Line
	3000 5100 3100 5000
Entry Wire Line
	3100 5100 3200 5000
Entry Wire Line
	3200 5100 3300 5000
Entry Wire Line
	3300 5100 3400 5000
Entry Wire Line
	3400 5100 3500 5000
Entry Wire Line
	3500 5100 3600 5000
Entry Wire Line
	3600 5100 3700 5000
Entry Wire Line
	3700 5250 3800 5150
Entry Wire Line
	3800 5250 3900 5150
Entry Wire Line
	3900 5250 4000 5150
Entry Wire Line
	4000 5250 4100 5150
Entry Wire Line
	4100 5250 4200 5150
Entry Wire Line
	4200 5250 4300 5150
Entry Wire Line
	4300 5250 4400 5150
Entry Wire Line
	4400 5250 4500 5150
Wire Wire Line
	2100 5100 2100 5550
Entry Wire Line
	2100 5100 2200 5000
Wire Wire Line
	2200 5100 2200 5550
Wire Wire Line
	2300 5550 2300 5100
Wire Wire Line
	2400 5100 2400 5550
Wire Wire Line
	2500 5550 2500 5100
Wire Wire Line
	2600 5100 2600 5550
Wire Wire Line
	2700 5550 2700 5100
Wire Wire Line
	2800 5100 2800 5550
Wire Wire Line
	2900 5550 2900 5100
Wire Wire Line
	3000 5100 3000 5550
Wire Wire Line
	3100 5550 3100 5100
Wire Wire Line
	3200 5100 3200 5550
Wire Wire Line
	3300 5550 3300 5100
Wire Wire Line
	3400 5100 3400 5550
Wire Wire Line
	3500 5550 3500 5100
Wire Wire Line
	3600 5100 3600 5550
Wire Bus Line
	3800 4750 3800 5150
Wire Bus Line
	3800 4750 4750 4750
Entry Wire Line
	4650 2800 4750 2900
Entry Wire Line
	4650 2900 4750 3000
Entry Wire Line
	4650 3000 4750 3100
Entry Wire Line
	4650 3100 4750 3200
Entry Wire Line
	4650 3200 4750 3300
Entry Wire Line
	4650 3300 4750 3400
Entry Wire Line
	4650 3400 4750 3500
Entry Wire Line
	4650 3500 4750 3600
Wire Wire Line
	4250 2800 4650 2800
Wire Wire Line
	4650 2900 4250 2900
Wire Wire Line
	4250 3000 4650 3000
Wire Wire Line
	4650 3100 4250 3100
Wire Wire Line
	4250 3200 4650 3200
Wire Wire Line
	4650 3300 4250 3300
Wire Wire Line
	4250 3400 4650 3400
Wire Wire Line
	4650 3500 4250 3500
Wire Bus Line
	4650 4400 2100 4400
Wire Bus Line
	2100 4400 2100 5000
Wire Bus Line
	2100 4400 2100 4100
Wire Bus Line
	2100 4100 2700 4100
Connection ~ 2100 4400
Entry Wire Line
	4550 3600 4650 3700
Entry Wire Line
	4550 3700 4650 3800
Entry Wire Line
	4550 3800 4650 3900
Entry Wire Line
	4550 3900 4650 4000
Entry Wire Line
	2700 3000 2800 2900
Entry Wire Line
	2700 3100 2800 3000
Entry Wire Line
	2700 3300 2800 3200
Entry Wire Line
	2700 3400 2800 3300
Entry Wire Line
	2700 3500 2800 3400
Entry Wire Line
	2700 3600 2800 3500
Entry Wire Line
	2700 3700 2800 3600
Entry Wire Line
	2700 3800 2800 3700
Entry Wire Line
	2700 3900 2800 3800
Entry Wire Line
	2700 4000 2800 3900
Entry Wire Line
	2700 4100 2800 4000
Wire Wire Line
	4250 3600 4550 3600
Wire Wire Line
	4550 3700 4250 3700
Wire Wire Line
	4250 3800 4550 3800
Wire Wire Line
	4550 3900 4250 3900
Wire Wire Line
	2800 2900 3200 2900
Wire Wire Line
	3200 3000 2800 3000
Wire Wire Line
	3200 3200 2800 3200
Wire Wire Line
	2800 3300 3200 3300
Wire Wire Line
	3200 3400 2800 3400
Wire Wire Line
	2800 3500 3200 3500
Wire Wire Line
	3200 3600 2800 3600
Wire Wire Line
	2800 3700 3200 3700
Wire Wire Line
	3200 3800 2800 3800
Wire Wire Line
	2800 3900 3200 3900
Wire Wire Line
	3200 4000 2800 4000
Wire Wire Line
	3700 5250 3700 5550
Wire Wire Line
	3800 5550 3800 5250
Wire Wire Line
	3900 5250 3900 5550
Wire Wire Line
	4000 5550 4000 5250
Wire Wire Line
	4100 5250 4100 5550
Wire Wire Line
	4200 5250 4200 5550
Wire Wire Line
	4300 5550 4300 5250
Wire Wire Line
	4400 5250 4400 5550
Text Label 4500 5550 1    50   ~ 0
CLK
Text Label 4250 2700 0    50   ~ 0
RWB
Text Label 4600 5550 1    50   ~ 0
RWB
Text Label 4250 2400 0    50   ~ 0
CLK
Text Label 4700 5550 1    50   ~ 0
RESB
Text Label 4800 5550 1    50   ~ 0
VPA
Text Label 4900 5550 1    50   ~ 0
VDA
Text Label 5000 5550 1    50   ~ 0
IRQ
Text Label 5100 5550 1    50   ~ 0
NMI
Text Label 2000 2700 0    50   ~ 0
VPA
Text Label 4850 2200 0    50   ~ 0
VDA
Text Label 4800 2100 0    50   ~ 0
RESB
Text Label 2950 2400 0    50   ~ 0
IRQ
Text Label 2950 2600 0    50   ~ 0
NMI
$Comp
L Connector:XLR3_Switched J2
U 2 1 60579D9F
P 5200 3100
F 0 "J2" H 5200 3442 50  0000 C CNN
F 1 "Jumpers" H 5200 3351 50  0000 C CNN
F 2 "" H 5200 3200 50  0001 C CNN
F 3 " ~" H 5200 3200 50  0001 C CNN
	2    5200 3100
	1    0    0    -1  
$EndComp
Text Label 4750 4550 0    50   ~ 0
D[0..7]
Text Label 2100 4850 0    50   ~ 0
A[0..15]
Text Label 2350 4100 0    50   ~ 0
A[0..11]
Text Label 2350 4400 0    50   ~ 0
A[12..15]
Text Label 4350 2800 0    50   ~ 0
D0
Text Label 4350 2900 0    50   ~ 0
D1
Text Label 4350 3000 0    50   ~ 0
D2
Text Label 4350 3100 0    50   ~ 0
D3
Text Label 4350 3200 0    50   ~ 0
D4
Text Label 4350 3300 0    50   ~ 0
D5
Text Label 4350 3400 0    50   ~ 0
D6
Text Label 4350 3500 0    50   ~ 0
D7
Text Label 4350 3600 0    50   ~ 0
A15
Text Label 4350 3700 0    50   ~ 0
A14
Text Label 4350 3800 0    50   ~ 0
A13
Text Label 4350 3900 0    50   ~ 0
A12
Wire Wire Line
	1250 3000 1250 2700
Wire Wire Line
	2000 2700 3200 2700
Wire Wire Line
	1250 2700 1400 2700
Wire Wire Line
	2800 3100 3200 3100
Entry Wire Line
	2700 3200 2800 3100
Text Label 2900 2900 0    50   ~ 0
A0
Text Label 2900 3000 0    50   ~ 0
A1
Text Label 2900 3100 0    50   ~ 0
A2
Text Label 2900 3200 0    50   ~ 0
A3
Text Label 2900 3300 0    50   ~ 0
A4
Text Label 2900 3400 0    50   ~ 0
A5
Text Label 2900 3500 0    50   ~ 0
A6
Text Label 2900 3600 0    50   ~ 0
A7
Text Label 2900 3700 0    50   ~ 0
A8
Text Label 2900 3800 0    50   ~ 0
A9
Text Label 2900 3900 0    50   ~ 0
A10
Text Label 2900 4000 0    50   ~ 0
A11
Text Label 2100 5450 1    50   ~ 0
A15
Text Label 2200 5450 1    50   ~ 0
A14
Text Label 2300 5450 1    50   ~ 0
A13
Text Label 2400 5450 1    50   ~ 0
A12
Text Label 2500 5450 1    50   ~ 0
A11
Text Label 2600 5450 1    50   ~ 0
A10
Text Label 2700 5450 1    50   ~ 0
A9
Text Label 2800 5450 1    50   ~ 0
A8
Text Label 2900 5450 1    50   ~ 0
A7
Text Label 3000 5450 1    50   ~ 0
A6
Text Label 3100 5450 1    50   ~ 0
A5
Text Label 3200 5450 1    50   ~ 0
A4
Text Label 3300 5450 1    50   ~ 0
A3
Text Label 3400 5450 1    50   ~ 0
A2
Text Label 3500 5450 1    50   ~ 0
A1
Text Label 3600 5450 1    50   ~ 0
A0
Text Label 3700 5450 1    50   ~ 0
D7
Text Label 3800 5450 1    50   ~ 0
D6
Text Label 3900 5450 1    50   ~ 0
D5
Text Label 4000 5450 1    50   ~ 0
D4
Text Label 4100 5450 1    50   ~ 0
D3
Text Label 4200 5450 1    50   ~ 0
D2
Text Label 4300 5450 1    50   ~ 0
D1
Text Label 4400 5450 1    50   ~ 0
D0
$Comp
L power:+5V #PWR01
U 1 1 60619FF0
P 1100 4150
F 0 "#PWR01" H 1100 4000 50  0001 C CNN
F 1 "+5V" H 1115 4323 50  0000 C CNN
F 2 "" H 1100 4150 50  0001 C CNN
F 3 "" H 1100 4150 50  0001 C CNN
	1    1100 4150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR03
U 1 1 6061A6E1
P 1350 4400
F 0 "#PWR03" H 1350 4150 50  0001 C CNN
F 1 "GND" H 1355 4227 50  0000 C CNN
F 2 "" H 1350 4400 50  0001 C CNN
F 3 "" H 1350 4400 50  0001 C CNN
	1    1350 4400
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG01
U 1 1 6061B3DC
P 1350 4400
F 0 "#FLG01" H 1350 4475 50  0001 C CNN
F 1 "PWR_FLAG" H 1350 4573 50  0000 C CNN
F 2 "" H 1350 4400 50  0001 C CNN
F 3 "~" H 1350 4400 50  0001 C CNN
	1    1350 4400
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG02
U 1 1 6061C4F4
P 1400 4150
F 0 "#FLG02" H 1400 4225 50  0001 C CNN
F 1 "PWR_FLAG" H 1400 4323 50  0000 C CNN
F 2 "" H 1400 4150 50  0001 C CNN
F 3 "~" H 1400 4150 50  0001 C CNN
	1    1400 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1400 4150 1100 4150
Wire Wire Line
	2900 2000 2900 2300
$Comp
L Device:R R4
U 1 1 606205FC
P 3050 1850
F 0 "R4" H 3120 1896 50  0000 L CNN
F 1 "(Not on board)" H 3120 1805 50  0000 L CNN
F 2 "" V 2980 1850 50  0001 C CNN
F 3 "~" H 3050 1850 50  0001 C CNN
	1    3050 1850
	-1   0    0    1   
$EndComp
Wire Wire Line
	2500 2000 2300 2000
Wire Wire Line
	2300 2000 2300 1700
Connection ~ 2500 2000
Wire Wire Line
	3050 1700 2300 1700
Connection ~ 2300 1700
Wire Wire Line
	2300 1700 2300 1600
Wire Wire Line
	3050 2000 3050 2200
Wire Wire Line
	3050 2200 3200 2200
Wire Bus Line
	4650 3700 4650 4400
Wire Bus Line
	3800 5150 4500 5150
Wire Bus Line
	4750 2900 4750 4750
Wire Bus Line
	2700 3000 2700 4100
Wire Bus Line
	2100 5000 3700 5000
$EndSCHEMATC
