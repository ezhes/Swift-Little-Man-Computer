LOOP    LDA X    ; Load how many times left we need to multiply.
        BRZ STOP ; If we have zero more times, abort
        LDA ANS
        ADD Y    ; Add one iteration to our answer
        STA ANS  ; and save our partial answer
        LDA X
        ADD N1
        STA X    ; since we've added one iteration, we need to remove one from our todo
        BRA LOOP ; and go again
STOP    LDA ANS
	OUT      ; we're done. print
        HLT

X       DAT 9    ; The times to multiply
Y       DAT 4    ; The number to multiply by
ANS     DAT 0    ; our answer
N1      DAT -1   ; a constant for -1 since I don't know how constants work
