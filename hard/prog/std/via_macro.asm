; Add VIA registers
; {1} = name
; {2} = address
    MAC DEFINE_VIA
VIA_{1}_RB = {2} 
VIA_{1}_RA = {2}+1
VIA_{1}_DDRB = {2}+2
VIA_{1}_DDRA = {2}+3
VIA_{1}_T1C_L = {2}+4
VIA_{1}_T1C_H = {2}+5
VIA_{1}_T1L_L = {2}+6
VIA_{1}_T1L_H = {2}+7
VIA_{1}_T2C_L = {2}+8
VIA_{1}_T2C_H = {2}+9
VIA_{1}_SR = {2}+$A
VIA_{1}_ACR = {2}+$B
VIA_{1}_PCR = {2}+$C
VIA_{1}_IFR = {2}+$D
VIA_{1}_IER = {2}+$E
VIA_{1}_ORA = {2}+$F
    ENDM