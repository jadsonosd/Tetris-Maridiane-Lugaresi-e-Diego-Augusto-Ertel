;+
;+ Jogo de Tetris
;+
;+ Autores: Diego Augusto Ertel
;+          Maridiane Lugaresi
;+
;+ Criado: 29Oct2019
;+
;+ Versao: 1.0
;+
.model small
.stack 200H
.data

   tbl_Telaini1       db "             * T E T R I S *            "                          
   tbl_Telaini2       db "                 (J)ogar                "
   tbl_Telaini3       db "                 (S)air                 "
   tbl_Telaini4       db "         Desenvolvido por:              "
   tbl_Telaini5       db "         Diego Augusto Ertel            "
   tbl_Telaini6       db "         Maridiane Lugaresi, 2019       "
   tbl_Telaini7       db "           *JOGO FINALIZADO*            "
   
   tbl_Desenhos1      db "  "

   tbl_Barra_hor      db 2,2,2,2
                      db 0,0,0,0
                      db 0,0,0,0
                      db 0,0,0,0

   tbl_Barra_vert     db 0,2,0,0
                      db 0,2,0,0
                      db 0,2,0,0
                      db 0,2,0,0
     
   tbl_Quadrado       db 0,3,3,0
                      db 0,3,3,0
                      db 0,0,0,0
                      db 0,0,0,0

   tbl_Vermelha_cima  db 0,4,0,0
                      db 4,4,4,0
                      db 0,0,0,0
                      db 0,0,0,0
                     
   tbl_Vermelha_dir   db 0,4,0,0
                      db 0,4,4,0
                      db 0,4,0,0
                      db 0,0,0,0
                     
   tbl_Vermelha_baixo db 4,4,4,0
                      db 0,4,0,0
                      db 0,0,0,0
                      db 0,0,0,0
                     
   tbl_Vermelha_esq   db 0,4,0,0
                      db 4,4,0,0
                      db 0,4,0,0
                      db 0,0,0,0
                     
   tbl_Roxa_hor       db 0,5,0,0
                      db 0,5,5,0
                      db 0,0,5,0
                      db 0,0,0,0
                     
   tbl_Roxa_vert      db 0,5,5,0
                      db 5,5,0,0
                      db 0,0,0,0
                      db 0,0,0,0
                     
   tbl_Amarela_hor    db 6,6,0,0
                      db 0,6,6,0
                      db 0,0,0,0
                      db 0,0,0,0
                     
   tbl_Amarela_vert   db 0,0,6,0
                      db 0,6,6,0
                      db 0,6,0,0
                      db 0,0,0,0
                     
   tbl_Azul_cima      db 0,0,0,0
                      db 0,9,0,0
                      db 0,9,9,9
                      db 0,0,0,0
                     
   tbl_Azul_dir       db 0,9,9,0
                      db 0,9,0,0
                      db 0,9,0,0
                      db 0,0,0,0
                     
   tbl_Azul_baixo     db 0,0,0,0
                      db 9,9,9,0
                      db 0,0,9,0
                      db 0,0,0,0
                     
   tbl_Azul_esq       db 0,0,9,0
                      db 0,0,9,0
                      db 0,9,9,0
                      db 0,0,0,0
                     
   tbl_Ciano_cima     db 0,0,0,0
                      db 0,0,3,0
                      db 3,3,3,0
                      db 0,0,0,0
                     
   tbl_Ciano_esq      db 0,3,3,0
                      db 0,0,3,0
                      db 0,0,3,0
                      db 0,0,0,0
                     
   tbl_Ciano_baixo    db 0,0,0,0
                      db 0,3,3,3
                      db 0,3,0,0
                      db 0,0,0,0
                     
   tbl_Ciano_dir      db 0,3,0,0
                      db 0,3,0,0
                      db 0,3,3,0
                      db 0,0,0,0
 
   tbl_Score          db  "SCORE"
   tbl_Jogo           db  "  "
         
   tbl_Final          db  "           * G A M E O V E R *          "
   
   var_aux            db 0

.code  
   ;Ler um caractere sem mostrar na tela, devolve em AL    
   LER_CHAR proc
     mov AH, 07
     int 21H
     ret
   endp
   
   ; ESCREVER CHAR
   ; Escreve caracter de AL
   ; BL atributo cor - 4 bits:  intensidade, red, green, blue  
   ESC_CHAR proc
       push ax
       push bx
       push cx
       push dx                                                                                                                
                                                                                                                               
       mov bh, 1                    ; pagina ou cor do segundo plano
       mov cx, 1                    ; numero de repeticoes
       mov ah, 09h                  ; numero do servico de BIOS
       int 10h
       
       pop dx
       pop cx
       pop bx
       pop ax
       ret
   endp

   ;String iniciada em ES:BP, Comprimento cx
   ;Coordenadas da tela em dx, dh = linha, dl = coluna - bl
   ;Atributo cor - 4 bits: intensidade, red, green, blue
   ESC_STRING proc
      push ax
      push bx
      push cx
      push dx
     
      mov bh, 1    ;pagina
      mov ah, 13h  ;numero do servico de BIOS
      mov al, 00h  ;numero do subservico
      int 10h
     
      pop dx
      pop cx
      pop bx
      pop ax
      ret
   endp
   
   ;Limpar a tela
   LIMPAR_TELA proc
      push ax
      push bx
      push cx
      push dx
     
      mov ah, 00h
      mov al, 03h
      int 10h
     
      pop dx
      pop cx
      pop bx
      pop ax
      ret
   endp
   
   ;Configuracao da tela
   CONFIG_TELA proc
      push ax
      mov al, 01h                   ;modo texto 40x25 16 cores 8 paginas
      mov ah, 13h                   ;modo de video
      int 10h
      pop ax
      ret
   endp
   
   ;Configuracao das paginas
   CONFIG_PAG proc
      push ax
      mov al, 01                    ;numero da pagina definido em al  
      mov ah, 05h                   ;numero do servico de BIOS
      int 10h
      pop ax
      ret
   endp  
   
   MOV_CURSOR proc
       push ax
       push bx
       
       mov bh, 1                    ; pagina
       mov ah, 02                   ; numero do servico de BIOS
       int 10h                      ; posiciona cursor
       
       pop bx
       pop ax
       ret
   endp  
   
   ;Teta inicial do jogo                  
   TELA_INICIAL proc
      push ax
      push bx
      push cx
      push dx
     
      mov ax, @data                 ;escreve string
      mov es, ax
      mov bl, 2                     ;define cor branca nas bordas
      mov cx, 40                    ;tamanho      
     
      mov dl, 0                     ;coluna                    
      mov dh, 3                     ;linha
      mov bp, offset tbl_Telaini1   ;* T E T R I S *
      call ESC_STRING
                                   
      mov bl, 44h                   ;cores
      mov dl, 6                     ;coluna                    
      mov dh, 6                     ;linha
      mov cx, 1                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino vermelho        
      call ESC_STRING
       
      mov bl, 44h                   ;cores
      mov dl, 5                     ;coluna                    
      mov dh, 7                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino vermelho
      call ESC_STRING
     
      mov bl, 55h                   ;cores
      mov dl, 10                    ;coluna                    
      mov dh, 6                     ;linha
      mov cx, 2                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino roxo
      call ESC_STRING
 
      mov bl, 55h                   ;cores
      mov dl, 9                     ;coluna                    
      mov dh, 7                     ;linha
      mov cx, 2                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino roxo
      call ESC_STRING
     
      mov bl, 65h                   ;cores
      mov dl, 13                    ;coluna                    
      mov dh, 6                     ;linha
      mov cx, 2                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino amarelo
      call ESC_STRING
     
      mov bl, 65h                   ;cores
      mov dl, 14                    ;coluna                    
      mov dh, 7                     ;linha
      mov cx, 2                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino amarelo
      call ESC_STRING
     
      mov bl, 22h                   ;cores
      mov dl, 17                    ;coluna                    
      mov dh, 7                     ;linha
      mov cx, 4                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino verde
      call ESC_STRING
     
      mov bl, 33h                   ;cores
      mov dl, 22                    ;coluna                    
      mov dh, 6                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o quadrado ciano
      call ESC_STRING
     
      mov bl, 33h                   ;cores
      mov dl, 22                    ;coluna                    
      mov dh, 7                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o quadrado ciano
      call ESC_STRING
                     
      mov bl, 99h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 6                     ;linha
      mov cx, 1                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino azul claro
      call ESC_STRING
     
      mov bl, 99h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 7                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino azul claro
      call ESC_STRING
     
      mov bl, 11h                   ;cores
      mov dl, 32                    ;coluna                    
      mov dh, 6                     ;linha
      mov cx, 1                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino azul escuro
      call ESC_STRING
     
      mov bl, 11h                   ;cores
      mov dl, 30                    ;coluna                    
      mov dh, 7                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino azul escuro
      call ESC_STRING
               
      mov bl, 7                     ;cores
      mov dl, 0                     ;coluna                    
      mov dh, 10                    ;linha
      mov cx, 40
      mov bp, offset tbl_Telaini2  
      call ESC_STRING            
                                    ;cores
      mov dl, 0                     ;coluna                    
      mov dh, 11                    ;linha
      mov bp, offset tbl_Telaini3  
      call ESC_STRING
             
      mov bl, 4                     ;cores
      mov dl, 0                     ;coluna                    
      mov dh, 14                    ;linha
      mov bp, offset tbl_Telaini4  
      call ESC_STRING
                                    ;cores
      mov dl, 0                     ;coluna                    
      mov dh, 15                    ;linha
      mov bp, offset tbl_Telaini5  
      call ESC_STRING
                                    ;cores
      mov dl, 0                     ;coluna                    
      mov dh, 16                    ;linha
      mov bp, offset tbl_Telaini6  
      call ESC_STRING
     
      pop dx
      pop cx
      pop bx
      pop ax
      ret
   endp
   
   ;imprime o retangulo onde as pecas se movimentam
   IMPRIME_AREA_JOGO proc
      push ax
      push bx
      push cx
      push dx  
     
      xor bp,bp      
      mov bl, 08h                   ;cores
      mov dl, 1                     ;coluna                    
      mov dh, 1                     ;linha
      mov cx, 5                     ;numero de caracteres
      mov bp, offset tbl_Score      ;SCORE
      call ESC_STRING  
      xor bp, bp
     
      mov bl, 80h                   ;cores
      mov dl, 9                     ;coluna
      mov dh, 1                     ;linha
      mov cx, 10
      mov bp, offset tbl_Jogo
      call ESC_STRING
      xor bp, bp
         
      mov dh, 2  
         
      ESC_BORDA:
                   
        mov al, 179
        mov bl, 80h                   ;cores
        mov dl, 9                     ;coluna
        mov cx, 1
        mov bp, offset tbl_Jogo
        call ESC_STRING
        xor bp, bp
         
        mov bl, 80h                   ;cores
        mov dl, 18                    ;coluna
        mov cx, 1
        mov bp, offset tbl_Jogo
        call ESC_STRING
         
        inc dh
     
        cmp dh, 23                    ;jump enquanto for < 23
    jb ESC_BORDA
   
      mov bl, 80h                   ;cores
      mov dl, 9                     ;coluna
      mov dh, 22                    ;linha
      mov cx, 10
      mov bp, offset tbl_Jogo
      call ESC_STRING
      xor bp, bp
     
      mov bl, 80h                   ;cores
      mov dl, 24                    ;coluna
      mov dh, 1                     ;linha
      mov cx, 7
      mov bp, offset tbl_Jogo
      call ESC_STRING
      xor bp, bp
     
      mov dh, 2
       
      ESC_BORDA_PECA:
     
        mov bl, 80h                   ;cores
        mov dl, 24                    ;coluna
        mov cx, 1
        mov bp, offset tbl_Jogo
        call ESC_STRING
        xor bp, bp
         
        mov bl, 80h                   ;cores
        mov dl, 30                    ;coluna
        mov cx, 1
        mov bp, offset tbl_Jogo
        call ESC_STRING
         
        inc dh
     
        cmp dh, 6                    ;jump enquanto for < 6
    jb ESC_BORDA_PECA
     
      mov bl, 80h                   ;cores
      mov dl, 24                    ;coluna
      mov dh, 6                     ;linha
      mov cx, 7
      mov bp, offset tbl_Jogo
      call ESC_STRING
      xor bp, bp
     
      pop dx
      pop cx
      pop bx
      pop ax
      ret  
   endp
 
       
   START_JOGO proc
     
      mov ax, @data                 ;escreve string
      mov es, ax
      mov bl, 2                     ;define cor branca nas bordas
      mov cx, 40                    ;tamanho
     
      call LIMPAR_TELA    
     
      call IMPRIME_AREA_JOGO
     
      ;jmp START_JOGO
      ret
   endp
   
   
   ;Retorna numero em DL de 0 a 7
   RANDOM proc
      push ax
      push bx
      push cx
     
      mov ah,00h
      int 1Ah        ;Dx parte  baixa do contador do Clock  
     
      mov al, 7                                                
      mul dx         ;realiza o produto entre AL e DX, resultado em AX
      mov cx, 10
      div cx         ;O quociente eh retornado em AX e o resto da divisao, se houver, em DX.
     
      pop cx
      pop bx
      pop ax
     ret
   endp
   
   ;Tela de configuracao inicial do jogo  
   IMPRIME_TELA_CONFIG proc
      push ax
      push bx
      push cx
      push dx
     
      mov cx, 40        ;tamanho
     
      mov dl, 26        ;coluna base
      mov dh, 1         ;linha
      call IMPRIME_AREA_JOGO    
     
      pop dx
      pop cx
      pop bx
      pop ax
      ret  
   endp
   
   TETRA_VERMELHO proc
      mov bl, 44h                   ;cores
      mov dl, 27                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 1                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino vermelho        
      call ESC_STRING
       
      mov bl, 44h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 4                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino vermelho
      call ESC_STRING
      ret
   endp
   
   TETRA_ROXO proc
      mov bl, 55h                   ;cores
      mov dl, 27                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 2                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino roxo
      call ESC_STRING
 
      mov bl, 55h                   ;cores
      mov dl, 26                     ;coluna                    
      mov dh, 4                     ;linha
      mov cx, 2                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino roxo
      call ESC_STRING
      ret
   endp
   
   TETRA_AMARELO proc
      mov bl, 65h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 2                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino amarelo
      call ESC_STRING
     
      mov bl, 65h                   ;cores
      mov dl, 27                    ;coluna                    
      mov dh, 4                     ;linha
      mov cx, 2                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino amarelo
      call ESC_STRING
      ret
   endp
   
   TETRA_VERDE proc
      mov bl, 22h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 4                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino verde
      call ESC_STRING
      ret
   endp
   
   TETRA_CIANO proc
      mov bl, 33h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o quadrado ciano
      call ESC_STRING
     
      mov bl, 33h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 4                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o quadrado ciano
      call ESC_STRING
      ret
   endp
   
   TETRA_AZULCLARO proc
      mov bl, 99h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 1                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino azul claro
      call ESC_STRING
     
      mov bl, 99h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 4                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino azul claro
      call ESC_STRING
      ret
   endp
   
   TETRA_AZULESCURO proc
      mov bl, 11h                   ;cores
      mov dl, 28                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 1                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino azul escuro
      call ESC_STRING
     
      mov bl, 11h                   ;cores
      mov dl, 26                    ;coluna                    
      mov dh, 4                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprime o tetramino azul escuro
      call ESC_STRING
      ret
   endp
   
   PRINTA_PECA proc
      push dx
      push ax
      mov cx, 4
           
      cmp dl, 0  ;Barra_hor
        mov var_aux, dl
       
        laco:    
            mov bp, offset tbl_Barra_hor  ;imprime a barra horizontal
            cmp tbl_Barra_hor[bp], 3
               call ESC_STRING
            mov ax, bp      
         
             
      ;cmp dl, 1  ;Barra_vert
;          call PRINTA_PECA
;          
;      cmp dl, 2  ;Quadrado
;          call PRINTA_PECA
;          
;      cmp dl, 3  ;Vermelha_cima
;          call PRINTA_PECA
;          
;      cmp dl, 4  ;Vermelha_dir
;          call PRINTA_PECA
;          
;      cmp dl, 5  ;Vermelha_baixo
;          call PRINTA_PECA
;          
;      cmp dl, 6  ;Vermelha_esq
;          call PRINTA_PECA
;          
;      cmp dl, 7  ;Roxa_hor
;          call PRINTA_PECA
;          
;      cmp dl, 8  ;Roxa_vert
;          call PRINTA_PECA
;          
;      cmp dl, 9  ;Amarela_hor
;          call PRINTA_PECA
;          
;      cmp dl, 10 ;Amarela_vert
;          call PRINTA_PECA
;          
;      cmp dl, 11 ;Azul_cima
;          call PRINTA_PECA
;          
;      cmp dl, 12 ;Azul_dir
;          call PRINTA_PECA
;          
;      cmp dl, 13 ;Azul_baixo
;          call PRINTA_PECA
;          
;      cmp dl, 14 ;Azul_esq
;          call PRINTA_PECA
;          
;      cmp dl, 15 ;Ciano_cima
;          call PRINTA_PECA
;          
;      cmp dl, 16 ;Ciano_esq
;          call PRINTA_PECA
;          
;      cmp dl, 17 ;Ciano_baixo
;          call PRINTA_PECA
;          
;      cmp dl, 18 ;Ciano_dir
;          call PRINTA_PECA
           
      pop dx
      pop ax  
      ret
   endp
       
   ;a partir de um numero randomico, escolhe a proxima peca do jogo
   ESCOLHE_PECA proc
   
    call RANDOM
   
    push dx
    mov dl, 26 ;coluna
    mov dh, 4  ;linha
   
    call PRINTA_PECA
           
    pop dx
    ret
   endp
   
   ;DELAY 500000 (7A120h).
    DELAY proc  
      mov cx, 0ah    ;HIGH WORD.
      mov dx, 0A120h ;LOW WORD.
      mov ah, 86h    ;WAIT.
      int 15h
      ret
    endp
   
   ;Inicializar o jogo
   INI_JOGO proc  
      push ax
      push bx
      push cx
      push dx
     
      mov bl, 7                     ;define cor branca nas bordas
      mov cx, 40                    ;tamanho      
     
      call IMPRIME_TELA_CONFIG
     
      call ESCOLHE_PECA
     
      ;aqui ele ira testar em dl qual foi a peca escolhida e printar ela no meio da tela
      LACO_JOGO:
        ;aqui printa a peca do movimento
     
      mov bl, 44h                   ;cores
      mov dl, 14                    ;coluna                    
      mov dh, 2                     ;linha
      mov cx, 1                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino vermelho        
      call ESC_STRING
       
      mov bl, 44h                   ;cores
      mov dl, 13                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino vermelho
      call ESC_STRING
     
      call MOV_CURSOR
      call LER_CHAR
     
      call DELAY
     
      ;limpar a tel somente no local onde a peca eh printada para nao precisar reescrever tudo
     
      mov bl, 44h                   ;cores
      mov dl, 14                    ;coluna                    
      mov dh, 3                     ;linha
      mov cx, 1                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino vermelho        
      call ESC_STRING
       
      mov bl, 44h                   ;cores
      mov dl, 13                    ;coluna                    
      mov dh, 4                     ;linha
      mov cx, 3                     ;cx possui o tamanho em caracteres da string
      mov bp, offset tbl_Desenhos1  ;imprimi o tetramino vermelho
      call ESC_STRING
     
      pop dx
      pop cx
      pop bx
      pop ax
      ret
   endp
   
   ;Jogar Tetris
   JOGAR proc
      push ax
      push bx
      push cx
      push dx
     
      ;Inicializar
      xor AX, AX          
      xor BX, BX          
      xor CX, CX
      xor DX, DX  
     
      call LIMPAR_TELA
      call INI_JOGO
      call LIMPAR_TELA
      call START_JOGO
     
      pop dx
      pop cx
      pop bx
      pop ax
      ret
   endp
   
   FINALIZAR proc
      push ax
      push bx
      push cx
      push dx
     
      mov bl, 4                     ;cor vermelha
      mov cx, 40                    ;tamanho  
     
      mov dl, 1                     ;coluna                    
      mov dh, 14                    ;linha
      mov bp, offset tbl_Telaini7
      call ESC_STRING
     
      pop dx
      pop cx
      pop bx
      pop ax
      ret
   endp

inicio:
   ;Inicializar segmento de dados
   mov AX, @DATA        
   mov DS, AX          
                           
   ;Inicializar
   xor AX, AX          
   xor BX, BX          
   xor CX, CX
   xor DX, DX
     
   ;Iniciar as pre configuracoes
   call CONFIG_TELA
   call CONFIG_PAG
   call TELA_INICIAL  
     
   NEXT:
      call LER_CHAR
      mov DL, AL
      cmp AL, 'J'
      je JGR
      cmp AL, 'j'
      je JGR
      cmp AL, 'S'
      je SAIR           ;je Se for igual chama SAIR
      cmp AL, 's'
      je SAIR          
      call NEXT
     JGR:
      call JOGAR
      call LIMPAR_TELA
      call TELA_INICIAL
      call NEXT
     SAIR:
      call LIMPAR_TELA
      call FINALIZAR
      ;Finalizar programa
      mov ah, 4CH          
      int 21h
end inicio
