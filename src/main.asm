global _start

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

    mov [liczba_bajtow], rax
    ; Zachowaj liczbe odczytanych bajtow.

    mov rdi, bufor
    mov rsi, [liczba_bajtow]
    call print_text

koniec:
    ; Ustaw tutaj breakpoint, aby obejrzec bufor.
    mov rax, 60
    mov rdi, 0
    syscall
