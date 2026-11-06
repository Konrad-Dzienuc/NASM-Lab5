global _start

section .data
    zle db "To nie jest liczba calkowita.", 0
    dobrze db "To jest liczba calkowita.", 0
    zle_dlugosc db 29
    dobrze_dlugosc db 25

section .bss
    bufor resb 64
    liczba_bajtow resq 1


section .text
print_text:
    mov rax, 1 ; wywołanie write
    mov rdx, rsi ; argument liczby bajtów jest potrzebny w rdx dla syscall.
    mov rsi, rdi ; argument adresu do wydruku jest potrzebny w rsi dla syscalla.
    mov rdi, 1 ; ustawiamy wyjście na stdout.
    syscall
    ret

is_integer:
    dec rsi
    mov bl, [rdi]
    cmp rbx, 45 ; ASCII znak minus (-)
    je  z_minusem
    jmp bez_minusa

    z_minusem:
        cmp rsi, 1
        jle nie_jest
        mov rcx, 1
        jmp petla

    bez_minusa:
        mov rcx, 0
        jmp petla

    petla:
        mov bl, [rdi + rcx]
        cmp bl, 48 ; ASCII cyfra 0
        jl nie_jest
        cmp bl, 57 ; ASCII cyfra 9
        jg nie_jest

        inc rcx ; add rcx, 1
        cmp rcx, rsi ; czy doszlismy do ostatniego znaku
        jne petla

    mov rax, 1
    ret
    nie_jest:
        mov rax, 0
    ret

_start:
    ; Wczytaj maksymalnie 64 bajty ze standardowego wejscia.
    mov rax, 0              ; Numer wywolania read.
    mov rdi, 0              ; Standardowe wejscie.
    mov rsi, bufor          ; Adres bufora.
    mov rdx, 64             ; Rozmiar bufora.
    syscall

    ; Sprawdz, czy odczytano dane.
    cmp rax, 0
    jle koniec

    ; Zachowaj liczbe odczytanych bajtow.
    mov [liczba_bajtow], rax

    mov rdi, bufor
    mov rsi, [liczba_bajtow]
    call is_integer

    cmp rax, 1
    je ok
        mov rdi, zle
        mov rsi, [zle_dlugosc]
        call print_text
        jmp koniec
    ok:
        mov rdi, dobrze
        mov rsi, [dobrze_dlugosc]
        call print_text
koniec:
    ; Ustaw tutaj breakpoint, aby obejrzec bufor.
    mov rax, 60
    mov rdi, 0
    syscall
