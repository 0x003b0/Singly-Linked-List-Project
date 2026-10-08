# Linked List

| | |
| :--- | :--- |
| **Autore** | 0x003b0 |
| **Versione RIPES (IDE)** | v2.2.5 |

---

## Obbiettivo e descrizione del progetto

L'obbiettivo del progetto è la creazione e gestione di una **lista concatenata circolare** implementata utilizzando il codice **RISC-V**.

Questa struttura dati dinamica è composta da una sequenza di nodi, ciascuno contenente un campo di dati arbitrario e un riferimento che punta al nodo successivo. Questo tipo di struttura permette l'accesso solo in maniera sequenziale.

Ogni nodo della lista avrà la dimensione totale di **5 byte** di cui:
* **I primi 4 byte (byte 0-3)**: saranno riservati al `PAHEAD`, cioè il puntatore all'elemento successivo oppure a sé stesso se è l'unico elemento presente nella lista.
* **Il byte 4**: conterrà l'informazione del nodo, rappresentata da un codice ASCII compreso nell'intervallo $[32, 125]$.

È importante aggiungere che i puntatori all'elemento successivo di ogni nodo avranno dimensione in memoria di 32 bit, equivalente a una word RISC-V.

### Operazioni Implementate
Le seguenti operazioni permettono la manipolazione della struttura dati:
* `ADD`: inserimento di un nuovo nodo
* `DEL`: rimozione di un nodo
* `PRINT`: stampa a video la lista concatenata circolare
* `SORT`: ordinamento della lista concatenata circolare
* `SDX`: rotazione in senso orario dei nodi della lista concatenata circolare
* `SSX`: rotazione in senso antiorario dei nodi della lista concatenata circolare
* `REV`: inversione dei nodi della lista concatenata circolare

> [!NOTE]
> **Ordinamento caratteri ASCII:**
> Nel momento in cui l'utente eseguirà l'operazione `SORT`, i caratteri ASCII dovranno seguire il seguente ordine: 
> simboli < numeri < minuscole < maiuscole
> 
> *Esempio:* la lista `A2b7` si ordinerà nella seguente maniera: `;27bA`

---

## Descrizione della sezione `.data` del programma

Questa sezione inizializza la variabile stringa `listInput` che conterrà una serie di comandi separati dal simbolo `~` (codice ASCII: 126).
Alcuni comandi possono contenere dei parametri e, se ben formattati, eseguono l'operazione. I comandi contenuti nella variabile `listInput` non dovranno essere più di 30.

I comandi, per poter essere accettati dal programma ed eseguire le operazioni a loro assegnate, dovranno essere formattati nel seguente modo:
* `ADD(char)`: dovrà contenere un solo carattere ASCII tra le parentesi
* `DEL(char)`: dovrà contenere un solo carattere ASCII tra le parentesi
* `PRINT`
* `SORT`
* `SDX`
* `SSX`
* `REV`

### Tabella della formattazione dei comandi

| Comandi accettati | Comandi NON accettati |
| :--- | :--- |
| `ADD(1)` | `ADD(11)`, `add(1)`, `add(11)`, `AD D(1)`, `ADD (1)` |
| `DEL(1)` | `DEL(11)`, `del(1)`, `del (11)`, `DE L(1)`, `DEL (1)` |
| `PRINT` | `print`, `PRINT()`, `PRINT(char)` |
| `SORT` | `sort`, `SORT()`, `SORT(char)` |
| `SDX` | `sdx`, `SDX()`, `SDX(char)` |
| `SSX` | `ssx`, `SSX()`, `SSX(char)` |
| `REV` | `rev`, `REV()`, `REV(char)` |

**Esempio di stringa di input in `.data`:**
```assembly
.data
listInput: .string "ADD(1)~SSX~ADD(a)~ADD(B)~ADD(9)~PRINT~SORT~DEL(B)~REV~SDX~DEL(a)"
```

---

## Descrizione del `main` del programma

La funzione `main` definita nella sezione `.text` contiene la dichiarazione e l'inizializzazione delle variabili e il codice che controlla i comandi inseriti dall'utente nella stringa `listInput`, analizzando ogni comando carattere per carattere.

### Mappa dei registri principali

| Registro | Descrizione / Utilizzo |
| :--- | :--- |
| `s0` | Puntatore alla testa della stringa `listInput` (a partire dall'indirizzo `0x10000000`). |
| `s1` | Indirizzo in memoria della testa della lista concatenata circolare (da `0x00000900`). |
| `s2` | Loop counter: incrementato man mano che si scorrono i caratteri della stringa `listInput`. |
| `s3` | Numero di comandi ben formattati ed eseguiti correttamente. |
| `s4` | Numero massimo di comandi inseribili (inizializzato a 30). |
| `s5` | Indirizzo in memoria da cui il programma inizierà ad inserire i nuovi nodi (da `0x00000900`); utile per la procedura `ADD`. |

### Descrizione ad alto livello

Il programma inizia leggendo la stringa di comandi contenuta nel registro `s0` (`listInput`).
1. Il ciclo `loop_commands` esamina la stringa carattere per carattere finché non raggiunge la fine o viene raggiunto il limite di 30 comandi.
2. Per ogni carattere letto, il programma verifica se corrisponde a una delle lettere iniziali dei comandi (`A`, `D`, `P`, `R`, `S`).
   * *Nota:* Poiché `SORT`, `SSX` e `SDX` condividono la stessa lettera iniziale (`S`), viene controllato anche il secondo carattere in `checkSecondLetter` prima di saltare alla procedura corretta.
3. Se trova una corrispondenza valida:
   * `ADD(char)` esegue `jal add` (salva il carattere in `a0`)
   * `DEL(char)` esegue `jal del` (salva il carattere in `a0`)
   * `PRINT` esegue `j print`
   * `SORT` esegue `jal sort`
   * `SDX` esegue `jal sdx`
   * `SSX` esegue `jal ssx`
   * `REV` esegue `jal rev`
4. Il programma incrementa il contatore comandi (`s3`) **solo** se il comando è ben formato ed eseguito.
5. Dopo l'esecuzione, passa al comando successivo tramite `nextCommand`, che controlla eventuale punteggiatura/spazi fino a trovare il separatore `~`.

#### Uso generale di registri e memoria

| Risorsa | Utilizzo |
| :--- | :--- |
| `a0` | Contiene il carattere ASCII passato come argomento a `ADD` e `DEL`. |
| `a1` | Utilizzato per il confronto dei caratteri nei comandi. |
| `t0, t1, t2` | Registri temporanei di supporto. |
| **Stack** | Conserva gli indirizzi di ritorno (`ra`) e dati temporanei durante le procedure. |

---

## Descrizione delle procedure

### 1. `ADD`

L'obbiettivo di questa procedura è aggiungere il carattere tra parentesi del comando `ADD(char)` come primo elemento se la lista è vuota, oppure in coda se sono già presenti elementi.

I caratteri ASCII accettabili devono essere compresi nell'intervallo [32, 125]. Se il carattere non rientra in questo intervallo, il comando viene scartato.

* **Primo inserimento:** La lista è vuota; il puntatore al nodo successivo viene impostato pari all'indirizzo della testa della lista (`s1`) e viene salvato il carattere ASCII.
* **Successivo inserimento:** Aggiunge il nuovo nodo in coda. Cerca l'ultimo elemento (quello il cui puntatore al successivo punta alla testa), aggiorna il puntatore del vecchio ultimo elemento verso il nuovo nodo, e fa puntare il nuovo nodo alla testa della lista.

#### Registri utilizzati in `ADD`
* `sp`: Riservato per salvare `ra`.
* `ra`: Indirizzo di ritorno alla chiamata `jal add`.
* `t0, t1, t3, t4, t6`: Registri temporanei.
* `a0`: Carattere ASCII da aggiungere.
* `s1`: Indirizzo della testa della lista.
* `s5`: Traccia l'indirizzo di allocazione del nuovo elemento.

#### Esempio di memoria per `ADD`
```assembly
.data
listInput: .string "ADD(1)~ADD(a)~ADD(a)~ADD(B)~ADD(;)~ADD(9)"
```

| Address | Word | Byte 0 | Byte 1 | Byte 2 | Byte 3 | Note |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `0x0000092c` | `0x00000039` | `0x39` ('9') | `0x00` | `0x00` | `0x00` | ASCII '9' |
| `0x00000928` | `0x00000900` | `0x00` | `0x09` | `0x00` | `0x00` | Pointer $\rightarrow$ Testa |
| `0x00000924` | `0x00000036` | `0x36` (';') | `0x00` | `0x00` | `0x00` | ASCII ';' |
| `0x00000920` | `0x00000928` | `0x28` | `0x09` | `0x00` | `0x00` | Pointer |
| `0x0000091c` | `0x00000042` | `0x42` ('B') | `0x00` | `0x00` | `0x00` | ASCII 'B' |
| `0x00000918` | `0x00000920` | `0x20` | `0x09` | `0x00` | `0x00` | Pointer |
| `0x00000914` | `0x00000061` | `0x61` ('a') | `0x00` | `0x00` | `0x00` | ASCII 'a' |
| `0x00000910` | `0x00000918` | `0x18` | `0x09` | `0x00` | `0x00` | Pointer |
| `0x0000090c` | `0x00000061` | `0x61` ('a') | `0x00` | `0x00` | `0x00` | ASCII 'a' |
| `0x00000908` | `0x00000910` | `0x10` | `0x09` | `0x00` | `0x00` | Pointer |
| `0x00000904` | `0x00000031` | `0x31` ('1') | `0x00` | `0x00` | `0x00` | ASCII '1' |
| `0x00000900` | `0x00000908` | `0x08` | `0x09` | `0x00` | `0x00` | Pointer al nodo succ. |

---

### 2. `DEL`

L'obbiettivo di questa procedura è eliminare il carattere (o più occorrenze del carattere) specificato dalla lista concatenata circolare.

#### Casi gestiti:
1. **La lista è vuota:** Il comando viene scartato.
2. **L'elemento da eliminare è l'unico della lista:** Imposta a zero sia il valore del puntatore che il carattere.
3. **L'elemento da eliminare è la testa della lista:** Trova l'ultimo elemento della lista e aggiorna il suo puntatore affinché punti al secondo elemento (che diventa la nuova testa). Continua la scansione per eventuali altre occorrenze.
4. **L'elemento da eliminare è in mezzo alla lista:** Trova l'elemento precedente a quello da eliminare e aggiorna il suo puntatore al nodo successivo a quello da eliminare. Continua la scansione.
5. **L'elemento da eliminare è in coda alla lista:** Trova l'elemento precedente e imposta il suo puntatore direttamente alla testa della lista. Continua la scansione.

#### Registri utilizzati in `DEL`
* `sp`, `ra`: Gestione dello Stack Pointer e indirizzo di ritorno.
* `t0, t1, t2, t3, t4, t5, t6`: Registri temporanei.
* `a0`: Carattere ASCII da eliminare.
* `s1`: Indirizzo della testa della lista.
* `s7, s9`: Registri di appoggio.

#### Esempio di memoria per `DEL`
```assembly
.data
listInput: .string "ADD(1)~ADD(a)~ADD(a)~ADD(B)~DEL(B)"
```

| Address | Word | Byte 0 | Byte 1 | Byte 2 | Byte 3 | Note |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `0x0000091c` | `0x00000042` | `0x42` | `0x00` | `0x00` | `0x00` | *Elemento 'B' rimosso* |
| `0x00000918` | `0x00000900` | `0x09` | `0x00` | `0x00` | `0x00` | Puntatore modificato alla testa (`0x00000900`) |
| `0x00000914` | `0x00000061` | `0x61` | `0x00` | `0x00` | `0x00` | ASCII 'a' |
| `0x00000910` | `0x00000900` | `0x09` | `0x00` | `0x00` | `0x00` | Pointer |
| `0x0000090c` | `0x00000061` | `0x61` | `0x00` | `0x00` | `0x00` | ASCII 'a' |
| `0x00000908` | `0x00000910` | `0x10` | `0x09` | `0x00` | `0x00` | Pointer |
| `0x00000904` | `0x00000031` | `0x31` | `0x00` | `0x00` | `0x00` | ASCII '1' |
| `0x00000900` | `0x00000908` | `0x08` | `0x09` | `0x00` | `0x00` | Pointer |

---

### 3. `PRINT`

Stampa a video i caratteri ASCII contenuti nella lista concatenata circolare.
* Se la lista è vuota (puntatore della testa uguale a 0), stampa uno spazio (codice ASCII 32).
* Se la lista contiene elementi, esegue il ciclo `print_loop` stampando i caratteri sequenzialmente fino a ritornare al nodo di partenza.

#### Registri utilizzati in `PRINT`
* `t0, t1`: Registri temporanei.
* `a0`: Carattere ASCII da stampare a video.
* `s1`: Indirizzo della testa della lista.

---

### 4. `SORT`

L'obbiettivo di questa procedura è ordinare i caratteri ASCII contenuti nella lista concatenata circolare secondo questo ordine: simboli < numeri < minuscole < maiuscole.

Per poter mantenere questo ordine, dato che i simboli sono sparsi nella tabella ASCII e le maiuscole sono minori delle minuscole, ho raggruppato i simboli in questo intervallo [0, 31], mentre le maiuscole in questo [128, 153].

#### Spiegazione raggruppamento simboli nel nuovo intervallo [0,31]:

Nella tabella ASCII i simboli sono compresi nei seguenti intervalli: [32, 47], [58, 64], [91, 96], [123, 125]. In totale abbiamo 32 simboli. Quindi andremo a sottrarre il valore del simbolo ASCII in modo da farlo rientrare in questo intervallo [0, 31] dato che ci stanno tutti e 32 i simboli:

* **[32, 47]**, a questi simboli gli sottraiamo 32:  
  `{32 - 32 = 0}, ..., {47 - 32 = 15}` quindi questi saranno compresi nel nuovo intervallo [0, 15]
* **[58, 64]**, a questi simboli gli sottraiamo 42:  
  `{58 - 42 = 16}, ..., {64 - 42 = 22}` quindi questi saranno compresi nel nuovo intervallo [16, 22]
* **[91, 96]**, a questi simboli gli sottraiamo 68:  
  `{91 - 68 = 23}, ..., {96 - 68 = 28}` quindi questi saranno compresi nel nuovo intervallo [23, 28]
* **[123, 125]**, a questi simboli gli sottraiamo 94:  
  `{123 - 94 = 29}, ..., {125 - 94 = 31}` quindi questi saranno compresi nel nuovo intervallo [29, 31]

---

#### Spiegazione raggruppamento maiuscole nel nuovo intervallo [128,153]:

Le maiuscole sono comprese nel seguente intervallo: [65, 90].  
Dato che nella tabella ASCII le minuscole sono nell'intervallo [97, 122] e l'ultimo carattere della tabella è il 127, possiamo mettere in atto la stessa tecnica usata per i simboli ma sommando alle maiuscole il valore di 63:

* **[65, 90]**, a queste maiuscole gli sommiamo 63:  
  `{65 + 63 = 128}, ..., {90 + 63 = 153}` quindi questi saranno compresi nel nuovo intervallo [128, 153]

Gli altri caratteri ASCII come numeri e minuscole non era necessario alterarli.

---

Di conseguenza ottengo l'ordine desiderato:
* **Simboli**: [0, 31]
* **Numeri**: [48, 57]
* **Minuscole**: [97, 122]
* **Maiuscole**: [128, 153]

#### Algoritmo di ordinamento
Utilizza un **Bubble Sort**: confronta a coppie gli elementi contigui. Se il secondo elemento è minore del primo, scambia i caratteri in memoria (senza modificare la struttura dei puntatori). Il processo si ripete finché non viene completato un passaggio senza compiere alcuno scambio (`t0 == 0`). Prima del ripristino, le trasformazioni dei valori ASCII vengono ripristinate ai valori originali (salvati temporaneamente in `s10` e `s11`).

#### Registri utilizzati in `SORT`
* `sp`, `ra`: Gestione Stack e Indirizzo di ritorno.
* `t0`: Contatore degli scambi effettuati.
* `t1`: Primo carattere della lista.
* `t2, t4`: Puntatori ai nodi.
* `t3, t5`: Caratteri della coppia in confronto.
* `t6`: Registro di classificazione del tipo di carattere.
* `s10, s11`: Backup dei caratteri originali prima della trasformazione.

#### Esempio di memoria per `SORT`
```assembly
.data
listInput: .string "ADD(B)~ADD(a)~ADD(1)~ADD(a)~SORT"
```

* **Prima dell'ordinamento:** `B -> a -> 1 -> a`
* **Dopo l'ordinamento:** `1 -> a -> a -> B`

---

### 5. `SDX` (Shift Destra)

Ruota gli elementi della lista circolare in senso orario, rendendo l'ultimo elemento la nuova testa della lista.
* Se la lista è vuota o contiene un solo elemento, non viene effettuata alcuna modifica.
* Se contiene più elementi, la procedura individua l'ultimo elemento e aggiorna semplicemente il registro `s1` (la testa della lista) affinché punti a quest'ultimo nodo. **I puntatori in memoria non vengono modificati.**

#### Registri utilizzati in `SDX`
* `sp`, `ra`: Gestione dello Stack.
* `t0, t3`: Registri temporanei.
* `t1`: Indirizzo del nuovo primo elemento.
* `s1`: Indirizzo della testa della lista.

---

### 6. `SSX` (Shift Sinistra)

Ruota gli elementi della lista circolare in senso antiorario, rendendo il secondo elemento la nuova testa della lista.
* Se la lista è vuota o contiene un solo elemento, la lista rimane invariata.
* Se la lista ha più nodi, individua l'indirizzo del secondo elemento e aggiorna il valore del registro `s1` impostandolo come nuova testa.

#### Registri utilizzati in `SSX`
* `sp`, `ra`: Gestione dello Stack.
* `t0`: Registro temporaneo.
* `s1`: Indirizzo della testa della lista.

---

### 7. `REV`

Inverte l'ordine dei caratteri presenti nella lista circolare.
* Se la lista è vuota o ha un solo elemento, non viene eseguita alcuna inversione.
* Per liste con più di un elemento, la procedura effettua una scansione memorizzando sequenzialmente i caratteri sullo **Stack** (sfruttando la logica LIFO - *Last In First Out*). Successivamente, riestrae i caratteri dallo stack salvandoli di nuovo nei nodi partendo dalla testa. I puntatori ai nodi rimangono inalterati.

#### Registri utilizzati in `REV`
* `sp`, `ra`: Gestione dello Stack.
* `t0, t1, t2, t3, t4, t5, t6`: Registri temporanei.
* `s1`: Indirizzo della testa della lista.

#### Esempio di memoria per `REV`
```assembly
.data
listInput: .string "ADD(1)~ADD(2)~ADD(3)~ADD(4)~REV"
```

* **Prima dell'inversione:** `1 -> 2 -> 3 -> 4`
* **Dopo l'inversione:** `4 -> 3 -> 2 -> 1`

---

## Test Eseguiti nel Programma

Tutti i comandi mal formattati vengono scartati e non incrementano il contatore dei comandi eseguiti (`s3`).

### Test 1
* **Comandi totali:** 15
* **Comandi errati:** `PRI`
* **Comandi eseguiti (`s3`):** 14
```assembly
.data
listInput: .string "ADD(1)~ADD(a)~ADD(a)~ADD(B)~ADD(;)~ADD(9)~SSX~SORT~PRINT~DEL(b)~DEL(B)~PRI~SDX~REV~PRINT"
```
**Output Terminale:**
`~1~1a~1aa~1aaB~1aaB;~1aaB;9~aaB;91~;19aaB~;19aaB~;19aaB~;19aa~a;19a~a91;a~a91;a`

---

### Test 2
* **Comandi totali:** 16
* **Comandi errati:** `add(B)`, `ADD`, `SORT(a)`, `DEL(bb)`
* **Comandi eseguiti (`s3`):** 12
```assembly
.data
listInput: .string "ADD(1)~SSX~ADD(a)~add(B)~ADD(B)~ADD~ADD(9)~PRINT~SORT(a)~PRINT~DEL(bb)~DEL(B)~PRINT~REV~SDX~PRINT"
```
**Output Terminale:**
`~1~1~1a~1aB~1aB9~1aB9~1aB9~1a9~1a9~9a1~19a~19a`

---

### Test 3
* **Comandi totali:** 16
* **Comandi errati:** `add(r)`, `add(5)`, `del(r)`, `SO RT`
* **Comandi eseguiti (`s3`):** 12
```assembly
.data
listInput: .string "REV~add(r)~ADD(A)~ADD(r)~add(5)~ADD(1)~ADD(5)~ADD(e)~del(r)~DEL(5)~REV~PRINT~SO RT~PRINT~SORT~PRINT"
```
**Output Terminale:**
`~A~Ar~Ar1~Ar15~Ar15e~Ar1e~e1rA~e1rA~e1rA~1erA~1erA`

---

### Test 4
* **Comandi totali:** 13
* **Comandi errati:** `ADD(42)`, `PRINT(A)`
* **Comandi eseguiti (`s3`):** 11
```assembly
.data
listInput: .string "ADD(o)~ADD(G)~ADD(42)~ADD(7)~ADD(@)~ADD(o)~PRINT~DEL(o)~SORT~PRINT~REV~PRINT(A)~PRINT"
```
**Output Terminale:**
`~o~oG~oG7~oG7@~oG7@o~oG7@o~G7@~@7G~@7G~G7@~G7@`

---

### Test 5
* **Comandi totali:** 13
* **Comandi errati:** `PRI NT`
* **Comandi eseguiti (`s3`):** 12
```assembly
.data
listInput: .string "ADD(1)~ADD(2)~ADD(1)~ADD(4)~ADD(;)~PRI NT~DEL(1)~SORT~SSX~REV~DEL(4)~DEL(2)~PRINT"
```
**Output Terminale:**
`~1~12~121~1214~1214;~24;~;24~24;~;42~;2~;~;`

---

### Test 6
* **Comandi totali:** 12
* **Comandi errati:** `SSX(n)`
* **Comandi eseguiti (`s3`):** 11
```assembly
.data
listInput: .string "ADD(1)~ADD(2)~ADD(1)~ADD(4)~SSX(n)~DEL(1)~SORT~SSX~REV~DEL(4)~DEL(2)~PRINT"
```
**Output Terminale:**
`~1~12~121~1214~24~24~42~24~2~~`
