#AUTORE:        0x003b0
 
#[test eseguiti e funzionanti]:
#ADD(1) ~ ADD(a) ~ ADD(a) ~ ADD(B) ~ ADD(;) ~ ADD(9) ~SSX~SORT~PRINT~DEL(b) ~DEL(B) ~PRI~SDX~REV~PRINT
#ADD(1) ~ SSX ~ ADD(a) ~ add(B) ~ ADD(B) ~ ADD ~ ADD(9) ~PRINT~SORT(a)~PRINT~DEL(bb) ~DEL(B) ~PRINT~REV~SDX~PRINT
#ADD(o) ~ADD(G) ~ADD(42) ~ADD(7) ~ADD(@)~ADD(o)~PRINT~DEL(o)~SORT~PRINT~ REV~ PRINT(A) ~PRINT
#ADD(1) ~ADD(2) ~ADD(1) ~ADD(4) ~SSX(n)~DEL(1)~SORT~SSX~ REV~ DEL(4)~DEL(2) ~PRINT

.data
listInput: .string "ADD(1) ~ADD(2) ~ADD(1) ~ADD(4) ~SSX(n)~DEL(1)~SORT~SSX~ REV~ DEL(4)~DEL(2) ~PRINT"

.text
main:
    la s0, listInput            #Testa della stringa
    li s1, 0x00000900           #Testa della lista concatenata circolare
    li s2, 0                    #Loop counter
    li s3, 0                    #Contatore dei comandi eseguiti e ben formattati
    li s4, 30                   #Numero massimo di input/comandi
    li s5, 0x00000900           #Testa della lista concatenata circolare (utile per add)

loop_commands:
    add t1, s2, s0
    lb t2, 0(t1)                         #Carattere corrente
    beqz t2, endProgram                  #Fine striga 
    bge s3, s4, endProgram               #listInput ha più di 30 comandi
    
    li a1, 65                            #codice ASCII per char 'A'
    beq t2, a1, checkADD                 
    li a1, 68                            #codice ASCII per char 'D'
    beq t2, a1, checkDEL                
    li a1, 80                            #codice ASCII per char 'P'      
    beq t2, a1, checkPRINT
    li a1, 82                            #codice ASCII per char 'R' 
    beq t2, a1, checkREV
    li a1, 32                            #codice ASCII per char 'Spazio' 
    beq t2, a1, nextChar
    
    li a1, 83                            #codice ASCII per char 'S' 
    addi s2, s2, 1
    add t1, s2, s0
    lb t2, 0(t1)
    beq t2, a1, checkSecondLetter
    
    checkSecondLetter:
    li a1, 79                                   #codice ASCII per char 'O'
    beq t2, a1, checkSORT
    li a1, 68                                   #codice ASCII per char 'D'
    beq t2, a1, checkSDX
    li a1, 83                                   #codice ASCII per char 'S'
    beq t2, a1, checkSSX

    addi s2, s2, 1                       #Il carattere corrente non è la lettere iniziale di alcun comando
    j loop_commands
#################################################################
####################Controlla ADD################################ 
#################################################################
checkADD:
    #Controllo secondo char (dovrebbe essere una 'D')
    addi s2, s2, 1                               #incrementa Loop Counter
    add t1, s2, s0        
    lb t2, 0(t1)                                
    li a1, 68                                    #codice ASCII per char 'D'
    bne t2, a1, nextCommand    
    
    #Controllo terzo char (dovrebbe essere una 'D')
    addi s2, s2, 1         
    add t1, s2, s0            
    lb t2, 0(t1)             
    bne t2, a1, nextCommand                    
    
    #Controllo quarto char (dovrebbe essere una parentesi aperta)
    addi s2, s2, 1             
    add t1, s2, s0
    lb t2, 0(t1)               
    li a1, 40                                    #codice ASCII per char 'parentesi aperta'
    bne t2, a1, nextCommand    
    
    #Controllo quinto char (dovrebbe essere il carattere da inserire nella lista)
    addi s2, s2, 1
    add t1, s2, s0
    lb t2, 0(t1)
    addi a0, t2, 0         
    li a1, 41                                   #codice ASCII per char 'parentesi chiusa'
    beq a0, a1, EmptyInputAddCommand            #Possibilità di una add vuota
    
    #Controllo sesto char
    addi s2, s2, 1
    add t1, s2, s0
    lb t2, 0(t1)
    bne t2, a1, nextCommand     
    
endCheckADD:
    jal add                                     #Comando accettato, esegui procedura 'add'
    li a0, 0                                 
    li t0, 0
    addi s3, s3, 1                              #Incrementa di 1 il contatore dei comandi eseguiti
    j nextCommand                               
    
EmptyInputAddCommand:                             
    addi s2, s2, 1
    j nextCommand                               #'add' vuota, scarta comando
#################################################################
####################Controlla DEL################################ 
#################################################################
checkDEL:
    #Controllo secondo char (dovrebbe essere una 'E')
    addi s2, s2, 1                           #incrementa Loop Counter
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 69                                #codice ASCII per char 'E'
    bne t2, a1, nextCommand
    
    #Controllo terzo char (dovrebbe essere una 'L')
    addi s2, s2, 1
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 76                                #codice ASCII per char 'L'
    bne t2, a1, nextCommand
    
    #Controllo quarto char (dovrebbe essere una parentesi aperta)
    addi s2, s2, 1
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 40                                #codice ASCII per char 'parentesi aperta'
    bne t2, a1, nextCommand
    
    #Controllo quinto char (dovrebbe essere il carattere da eliminare dalla lista, se esistente)
    addi s2, s2, 1
    add t1, s2, s0
    lb t2, 0(t1)         
    addi a0, t2, 0                           #Assegna il carattere corrente al registro a0
    li a1, 41                                #codice ASCII per char 'parentesi chiusa'
    beq a0, a1, EmptyInputDelCommand         #Possibilità di una del vuota
    
    #Controllo sesto char
    addi s2, s2, 1
    add t1, s2, s0
    lb t2, 0(t1)            
    bne t2, a1, nextCommand     
    
endCheckDEL:
    jal del                                  #Comando accettato, esegui procedura 'del'
    li a0, 0                
    addi s3, s3, 1                           #Incrementa di 1 il contatore dei comandi eseguiti
    j nextCommand
    
EmptyInputDelCommand:
    addi s2, s2, 1
    j nextCommand                            #'del' vuota, scarta comando
#################################################################
####################Controlla PRINT############################## 
#################################################################
checkPRINT:
    #Controllo secondo char (dovrebbe essere una 'R')
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)            
    li a1, 82                                #codice ASCII per char 'R'
    bne t2, a1, nextCommand
    
    #Controllo terzo char (dovrebbe essere una 'I')
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)            
    li a1, 73                                #codice ASCII per char 'I'
    bne t2, a1, nextCommand
    
    #Controllo quarto char (dovrebbe essere una 'N')
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 78                                #codice ASCII per char 'N'
    bne t2, a1, nextCommand
    
    #Controllo quinto char (dovrebbe essere una 'T')
    addi s2, s2, 1     
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 84                                #codice ASCII per char 'T'
    bne t2, a1, nextCommand
    
    #Controllo sesto char (spazio/i, tilde, zero)
    addi s2, s2, 1     
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 126                              #codice ASCII per char '~'
    beq t2, a1, endCheckPRINT               #possibilità che sia "PRINT~", in tal caso, comando accettato
    li a1, 32                               #codice ASCII per char 'spazio'
    beq t2, a1, endCheckPRINT               #possibilità che sia "PRINT " con spazio dopo il comando, in tal caso, comando accettato
    beq t2, zero, endCheckPRINT             #Fine stringa
    j nextCommand
        
endCheckPRINT:
    addi s3, s3, 1                          #Incrementa di 1 il contatore dei comandi perché PRINT è ben formattato
    j print                                 #Comando accettato, esegui 'print'
#################################################################
####################Controlla SORT############################### 
#################################################################
checkSORT:
    #Controllo terzo char (dovrebbe essere una 'R')
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)        
    li a1, 82                                #codice ASCII per char 'R'
    bne t2, a1, nextCommand
    
    #Controllo quarto char (dovrebbe essere una 'T')
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)            
    li a1, 84                                #codice ASCII per char 'T'
    bne t2, a1, nextCommand
    
    #Controllo quinto char (spazio, tilde, zero)
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 126                              #codice ASCII per char '~'
    beq t2, a1, endCheckSORT                #possibilità che sia "SORT~", in tal caso, comando accettato
    li a1, 32                               #codice ASCII per char 'spazio'
    beq t2, a1, endCheckSORT                #possibilità che sia "SORT " con spazio dopo il comando, in tal caso, comando accettato
    beq t2, zero, endCheckSORT              #Fine stringa
    j nextCommand
        
endCheckSORT:
    addi s2, s2, -1                         #Decrementa loopcounter
    addi s3, s3, 1                          #Incrementa di 1 il contatore dei comandi perché SORT è ben formattato
    jal sort                                #Comando accettato, esegui procedura 'sort'
    j nextCommand
#################################################################
####################Controlla SDX################################ 
#################################################################  
checkSDX:
    #Controllo terzo char (dovrebbe essere una 'X')
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 88                                #codice ASCII per char 'X'
    bne t2, a1, nextCommand
    
    #Controllo quarto char (spazio, tilde, zero)
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)        
    li a1, 126                              #codice ASCII per char '~'
    beq t2, a1, endCheckSDX                 #possibilità che sia "SDX~", in tal caso, comando accettato
    li a1, 32                               #codice ASCII per char 'spazio'
    beq t2, a1, endCheckSDX                 #possibilità che sia "SDX " con spazio dopo il comando, in tal caso, comando accettato
    beq t2, zero, endCheckSDX               #Fine stringa
    j nextCommand
        
endCheckSDX:
    #addi s2, s2, -1    
    jal sdx                                #Comando accettato, esegui procedura 'sdx'
    addi s3, s3, 1                         #Incrementa di 1 il contatore dei comandi eseguiti
    j nextCommand
#################################################################
####################Controlla SSX################################ 
#################################################################    
checkSSX:
    #Controllo terzo char (dovrebbe essere una 'X')
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)            
    li a1, 88                                 #codice ASCII per char 'X'
    bne t2, a1, nextCommand
    
    #Controllo quarto char (spazio, tilde, zero)
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)            
    li a1, 126                                #codice ASCII per char '~'
    beq t2, a1, endCheckSSX                   #possibilità che sia "SSX~", in tal caso, comando accettato
    li a1, 32                                 #codice ASCII per char 'spazio'
    beq t2, a1, endCheckSSX                   #possibilità che sia "SSX " con spazio dopo il comando, in tal caso, comando accettato
    beq t2, zero, endCheckSSX                 #Fine stringa
    j nextCommand
        
endCheckSSX:
    #addi s2, s2, -1    
    jal ssx                                  #Comando accettato, esegui procedura 'ssx'
    addi s3, s3, 1                           #Incrementa di 1 il contatore dei comandi eseguiti
    j nextCommand
#################################################################
####################Controlla REV################################ 
#################################################################
checkREV:
    #Controllo secondo char (dovrebbe essere una 'E')
    addi s2, s2, 1     
    add t1, s2, s0
    lb t2, 0(t1)         
    li a1, 69                                #codice ASCII per char 'E'
    bne t2, a1, nextCommand
    
    #Controllo terzo char (dovrebbe essere una 'V')
    addi s2, s2, 1        
    add t1, s2, s0
    lb t2, 0(t1)        
    li a1, 86                                #codice ASCII per char 'V'
    bne t2, a1, nextCommand
    
    #Controllo quarto char (spazio, tilde, zero)
    addi s2, s2, 1     
    add t1, s2, s0
    lb t2, 0(t1)            
    li a1, 126                              #codice ASCII per char '~'
    beq t2, a1, endCheckREV                 #possibilità che sia "REV~", in tal caso, comando accettato
    li a1, 32                               #codice ASCII per char 'spazio'
    beq t2, a1, endCheckREV                 #possibilità che sia "REV " con spazio dopo il comando, in tal caso, comando accettato
    beq t2, zero, endCheckREV               #Fine stringa
    j nextCommand
        
endCheckREV:
    addi s2, s2, -1                     
    jal rev                                 #Comando accettato, esegui procedura 'ssx'
    addi s3, s3, 1                          #Incrementa di 1 il contatore dei comandi eseguiti
    j nextCommand
#################################################################################################
####################FINE CONTROLLO CARATTERI DEI COMANDI IN INPUT################################ 
#################################################################################################
nextCommand:
    li a1, 126                                  #codice ASCII per char '~'
    li a5, 41                                   #codice ASCII per char 'parentesi chiusa'
    
    loop_nextCommand_2:
        beqz t2, endProgram                     #Possibilità che sia finita la stringa di comandi in input   
        beq t2, a1, checkSpace                  #Possibilità che sia presente uno spazio dopo il comando
        beq t2, a5, checkAfterParenthesis       #Controlla caratteri dopo parentesi chiusa del comando
        #bne t2, a1, loop_commands
        addi s2, s2, 1
        add t1, s2, s0
        lb t2, 0(t1)
        j loop_nextCommand_2
        
    checkAfterParenthesis:                      
        addi s2, s2, 1
        add t1, s2, s0
        lb t2, 0(t1)
        #fino a che il carattere non è tilde non uscire dal ciclo
        beq t2, a1, nextChar
        beqz t2, endProgram
        j checkAfterParenthesis
          
    checkSpace:
        addi s2, s2, 1
        add t1, s2, s0
        lb t2, 0(t1)
        li a1, 32
        beq t2, a1, nextChar                   #il carattere corrente è ancora uno spazio vai a nextChar
        j loop_commands     
    
nextChar:
    addi s2, s2, 1                        
    j loop_commands            
#######################################################################
####################---Operazione ADD---############################### 
####################################################################### 
#a0 contiene il carattere da aggiungere alla lista circolare
#s1 testa della lista
#s5 cambia e aumenta di 8 in 8 ogni volta che viene aggiunto un nuovo elemento

add:
    addi sp, sp, -4      
    sw ra, 0(sp)                   
    li t0, 32                
    li t1, 125
    #code ASCII accettati [32,125]
    blt a0, t0, endADD           
    bgt a0, t1, endADD         
    
    #Verifica se è un primo inserimento
    lb t3, 4(s1)                                #Carica in t3 primo carattere della lista
    beqz t3, addFirstElement                    #Se la lista è vuota, aggiungi primo elemento
    lw t4, 0(s1)                      
    
        #Scorri la lista circolare per trovare l'ultimo elemento, cioè colui che ha il puntatore all'elem succ uguale alla testa
    loop_find_last_element:
    lw t3, 0(t4)                         
    beq t3, s1, addNewElement                   #se uguale a ind testa allora abbiamo trovato l'ultimo elemento, aggiungi nuovo elemento
    lw t4, 0(t4)                                #prossimo elemento
    j loop_find_last_element                    #continua scorrimento
     
        #Aggiungi nuovo elemento alla lista circolare  
    addNewElement:
    addi s5, s5, 8
    mv t0, s5                        
    lw t6, 0(t0)                    
    bnez t6, addNewElement
    lb t6, 4(t0)
    bnez t6, addNewElement
    #salva in memoria
    sw t0, 0(t4)
    sw s1, 0(t0)
    sb a0, 4(t0)
    j print                                    #Stampa lista circolare
    
        #Aggiungi il primo elemento della lista circolare
    addFirstElement:
    sw s1, 0(s1)                             #Puntatore del primo elemento alla testa
    sb a0, 4(s1)                             #Stampa lista circolare
    j print                 
    
endADD:
    lw ra, 0(sp)
    addi sp, sp, 4                  
    jr ra                            
#################################################################
####################Operazione DEL############################### 
#################################################################  
#a0 contiene il carattere da eliminare alla lista circolare

del:
    addi sp, sp, -4                     #Creo spazio nella stack
    sw ra, 0(sp)                        #Salvo indirizzo di ritorno

    lw t0, 0(s1)        
    beqz t0, endDEL                     #Se la lista è vuota, termina la procedura 
    mv t1, s1
    beq t0, s1, uniqueElement           #Possibilità che sia presente solo un elemento nella lista
 
        #Cerco elemento da eliminare, se esistente
    loopSearch:
        lw t2, 0(t1)                    #Puntatore al prossimo elemento
        lw t4, 0(t2)                    #Puntatore al prossimo elemento
        lb t3, 4(t1)                    #Carattere 
        beq t2, s1, endList             #Ultimo elemento della lista
        beq t3, a0, deleteElement       #Se il carattere della lista è uguale a quello in input a0, eliminalo
        lw t1, 0(t1)                    #Prossimo elemento
        j loopSearch                    #Continua a cercare
        
        #Se la lista ha solo un elemento, controlla che sia questo quello da eliminare
    uniqueElement:
        lw t2, 0(s1)
        lb t3, 4(s1)
        bne t3, a0, print               #Se l'unico elemento non corrisponde con quello da eliminare, stampa la lista
        sw zero, 0(s1)
        sb zero, 4(s1)
        j print                         #Stampa lista vuota
        
    deleteElement:
        beq t1, s1, deleteHead          #Controllare che l'elem da elimare sia la testa della lista
            #Non essendo la testa, cerco l'elemento precedente di quello da eliminare
        FindPrecDeletedElement:
        mv s9, s1
        lw t5, 0(s1)
        mv t6, s1
            FindPrecDeletedElement_2:
            beq t5, t1, foundPrec            #Esegui foundPrec una volta trovato l'elemento precedente
            mv t6, t5
            lw t5, 0(t5)
            j FindPrecDeletedElement_2
        foundPrec:
        sw t2, 0(t6)
        mv, t1, s1
        j loopSearch                      #Continua a cercare 
        
    deleteHead:
        #Cerca ultimo elemento prima di eliminare la testa
        bne t4, s1, findL                 #Esegui FindL una volta trovato l'ultimo elemento
        mv s1, t2
        mv t1, s1
        sw t1, 0(s7)
        j loopSearch                      #Continua a cercare l'ultimo elemento
        findL:
            mv s7, t4
            lw t4, 0(t4)
            j deleteHead
                   
    endList:
        #Controlla se l'ultimo elemento della lista è quello da eliminare (deleteLastElement) altrimenti stampa la lisa 
        beq t3, a0, deleteLastElement
        j print
    
    deleteLastElement:
         #qui deve impostare il puntatore dell'elemento precedente da eliminare alla testa
    mv s9, s1
    lw t5, 0(s1)
    
    FindPrecLastElement:
        #Cerca elemento precedente all'ultimo
    lw t6, 0(t5)
    beq t6, t1, foundPrecLast
    mv s9, t5
    lw t5, 0(t5)                         #Prossimo elemento
    j FindPrecLastElement                #Continua a cercare

        foundPrecLast:
        sw s1, 0(t5)                     #Modifica il puntatore in memoria assegnandogli l'indirizzo della testa
        j print                        
        
endDEL:    
    lw ra, 0(sp)
    addi sp, sp, 4           
    jr ra                    
#################################################################
####################Operazione PRINT############################# 
#################################################################  
print:
    mv t0, s1
    lw t1, 0(t0)
    beqz t1, emptyList          #Possibilità che la lista sia vuota
    li a7, 11    
    li a0, 126
    ecall
    lb a0, 4(t0)                #carica primo carattere della lista
    li a7, 11
    ecall                    
    beq t1, s1, endPRINT
    
    print_loop:   
        lb a0, 4(t1)                #carica prossimo carattere
        li a7, 11
        ecall
        lw t1, 0(t1)                #Prossimo elemento
        beq t1, s1, endPRINT
        j print_loop                #Continua a stampare 
        
    emptyList:
        li a7, 11    
        li a0, 126
        ecall
        li a7, 11
        li a0, 32
        ecall
         
endPRINT: 
    lw ra, 0(sp)
    beqz ra, nextCommand
    addi sp, sp, 4                  
    jr ra                       
#################################################################
####################Operazione SORT############################## 
#################################################################  
#Ordine di ordinamento: simboli<numeri<minuscole<maiuscole
#SIMBOLI: [0,31], NUMERI: [48,57], MINUSCOLE: [97,122], MAIUSCOLE: [128,153]
    
sort:
    addi sp, sp, -4         
    sw ra, 0(sp)              
    li t0, 0                        #Conta scambi
    li t6, 0                        #Char ASCII per confronto

BubbleSort:
    lw t0, 0(s1)                #Carica PAHEAD del primo elemento della lista
    beqz t0, endSORT            #Possibilità che la lista sia vuota, niente da ordinare
    beq t0, s1, print           #Possibilità che la lista abbia solo un elemento, niente da ordinare
    lb t1, 4(s1)                #1º char della lista
    mv t2, s1                   #t2 = ind testa
    addi sp, sp, -4          
    sw t1, 0(sp)                #Salva primo char della lista nello stack

    li t0, 0                    #Contatore scambi

    InnerLoop:
        lw t3, 0(sp)                    #Primo carattere per il confronto
        addi sp, sp, 4                  
        lw t4, 0(t2)                 
        lb t5, 4(t4)                    #Secondo carattere per il confronto
        addi sp, sp, -4              
        sw t5, 0(sp)                 
        mv s10, t3                      #Preservare valore originale char ASCII prima della trasformazione
        mv s11, t5                      #Preservare valore originale char ASCII prima della trasformazione
        
            #Categorizzazione del primo carattere per il confronto
        CheckFirstAsciiValue:
        li t6, 64
        ble t3, t6, NumOrSymbol         #se t3<=64, NumOrSymbol
        li t6, 90
        ble t3, t6, isCapitalLetter     #se t3<=90, isCapitalLetter
        li t6, 96
        ble t3, t6, isSymbol_68         #se t3<=96, isSymbol_68
        li t6, 122
        ble t3, t6, isLowerCase         #se t3<=122, isLowerCase
        li t6, 125
        ble t3, t6, isSymbol_94         #se t3<=125, isSymbol_94

            #Categorizzazione del secondo carattere per il confronto
        CheckSecondAsciiValue:
        lw t5, 0(sp)
        addi sp, sp, 4
        li t6, 64
        ble t5, t6, NumOrSymbolSecondChar         #se t3<=64, NumOrSymbol
        li t6, 90
        ble t5, t6, isCapitalLetter_secondChar     #se t3<=90, isCapitalLetter
        li t6, 96
        ble t5, t6, isSymbol_68_secondChar         #se t3<=96, isSymbol_68
        li t6, 122
        ble t5, t6, isLowerCase_secondChar         #se t3<=122, isLowerCase
        li t6, 125
        ble t5, t6, isSymbol_94_secondChar         #se t3<=125, isSymbol_94

        NumOrSymbol:
            li t6, 48
            bge t3, t6, checkNum                        #se t3<=48, checkNum
            j isSymbol_32                               #se t3>48 quindi da 49 compreso in poi, salta a isSymbol_32

        NumOrSymbolSecondChar:
            li t6, 48
            bge t5, t6, checkNumSecondChar
            j isSymbol_32_secondChar 

            checkNum:
                li t6, 57
                ble t3, t6, isNumber
                j isSymbol_42                           #sicuramente simbolo compreso in [58,64]
                

            checkNumSecondChar:
                li t6, 57
                ble t5, t6, isNumber_SecondChar            
                #qui non metto j isSymbol_42 perché se t3>=57, sicuramente è simbolo compreso in [58,64]

            isSymbol_42:
                addi t3, t3, -42
                j CheckSecondAsciiValue

            isSymbol_42_secondChar:
                addi t5, t5, -42
                j CompareChars
            
            isSymbol_32:
                addi t3, t3, -32
                j CheckSecondAsciiValue

            isSymbol_32_secondChar:
                addi t5, t5, -32
                j CompareChars

                isNumber:
                    j CheckSecondAsciiValue

                isNumber_SecondChar:
                    j CompareChars
        
        isCapitalLetter:
            addi t3, t3, 63
            j CheckSecondAsciiValue

        isCapitalLetter_secondChar:
            addi t5, t5, 63
            j CompareChars

        isSymbol_68:
            addi t3, t3, -68
            j CheckSecondAsciiValue

        isSymbol_68_secondChar:
            addi t5, t5, -68
            j CompareChars

        isLowerCase:
            j CheckSecondAsciiValue

        isLowerCase_secondChar:
            j CompareChars

        isSymbol_94:
            addi t3, t3, -94
            j CheckSecondAsciiValue

        isSymbol_94_secondChar:
            addi t5, t5, -94
            j CompareChars


    CompareChars:
        beq t3, t5, NoSwap                        
        blt t3, t5, NoSwap
        #scambio in memoria i caratteri
        sw s10, 4(t4)
        sw s11, 4(t2)
        addi t0, t0, 1                         #Incremento di 1 il contatore scambi
    
    NoSwap:
        lw s7, 0(t4)
        beq s7, s1, ContinueSorting            #Controlla se si è alla fine della lista  
        #Passa al confronto della prossima coppia di elementi           
        addi sp, sp, 4
        lb t3, 4(t4)
        sw t3, 0(sp)
        mv t2, t4
        j InnerLoop

    ContinueSorting:
        #Se il numero di scambi è zero, la lista è ordinata e stampa la lista; Altrimenti riesegui BubbleSort
        beqz t0, print
        j BubbleSort      
  
endSORT:
    lw ra, 0(sp)
    addi sp, sp, 4                  
    jr ra    
#################################################################
####################Operazione SDX############################### 
################################################################# 
sdx: 
    addi sp, sp, -4         
    sw ra, 0(sp)           
    lw t0, 0(s1)
    beqz t0, endSDX                        #Possibilità che la lista sia vuota
    beq t0, s1, print                      #Se unico elemento della lista, stampa
    mv t1, s1

    findLastElement:
        #Cerca ultimo elemento, cioè colui che ha il PAHEAD uguale all'indirizzo della testa
        #e impostalo come nuovo primo elemento della lista
        lw t3, 0(t1)
        beq t3, s1, lastBecomesFirst     
        mv t1, t3                           #Prossimo elemento
        j findLastElement                    
        
        lastBecomesFirst:
            mv s1, t1
            j print
             
endSDX:    
    lw ra, 0(sp)
    addi sp, sp, 4               
    jr ra    
#################################################################
####################Operazione SSX############################### 
################################################################# 
ssx:
    addi sp, sp, -4         
    sw ra, 0(sp)              
    lw t0, 0(s1)
    beqz t0, endSSX                #Possibilità che la lista sia vuota
    beq t0, s1, print              #Se unico elemento della lista, stampa

        #È necessario modificare s1 (testa della lista), assegnandogli l'indirizzo del secondo elemento
    move_elements_left:
        lw s1, 0(s1)                        #word contenuta nella testa, che è l'ind al 2º elemento
        mv s1, s1                           #nuova testa della lista
        j print
               
endSSX:    
    lw ra, 0(sp)
    addi sp, sp, 4                  
    jr ra     
#################################################################
####################Operazione REV############################### 
#################################################################  
rev:
    addi sp, sp, -4         
    sw ra, 0(sp)              
    lw t0, 0(s1)
    beqz t0, endREV                  #Possibilità che la lista sia vuota
    beq t0, s1, print                #Se unico elemento della lista, stampa
    mv t1, s1
       
        #mi salvo tutti i char nello stack, fino a che non è finita la lista
    saveEachCharinStack:
        lw t2, 0(t1)
        lw t6, 4(t1)                #primo char
        addi sp, sp, -4
        sw t6, 0(sp)
        beq t2, s1, savedAllChars_nowSwap
        mv t1, t2
        j saveEachCharinStack
    
        #salvati i char nello stack, estraggo il primo char dallo stack e lo salvo come primo elem in memoria             
    savedAllChars_nowSwap:
        lw t5, 0(sp)
        addi sp, sp, 4
        sw t5, 4(s1)
        lw t4, 0(s1)
        mv t4, t4
        
        #salvato il primo, estraggo gli altri e li salvo in memoria 
    saveOtherChars:
        lw t5, 0(sp)
        addi sp, sp, 4
        sw t5, 4(t4)
        lw t3, 0(t4)
        beq t3, s1, print            #Stampa la lista una volta averli estratti e salvati tutti in memoria
        mv t4, t3                 
        j saveOtherChars
           
endREV:
    lw ra, 0(sp)
    addi sp, sp, 4                  
    jr ra         
#################################################################
####################FINE PROGRAMMA############################### 
#################################################################   
endProgram:
    #li a7, 11                #con il valore 11 mi stampa il char input  
    li a0, 10
    ecall        
