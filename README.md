# NASM-Lab5

Piąte laboratorium z NASM przygotowane do pracy w środowisku GitHub Codespaces.

## Cel laboratorium

Celem zajęć jest zapoznanie studenta z:

- odczytywaniem danych ze standardowego wejścia,
- przechowywaniem tekstu w buforze,
- wypisywaniem danych na standardowe wyjście,
- sprawdzaniem poprawności zapisu liczb,
- zamianą tekstu na wartość liczbową,
- wykorzystaniem procedur i jednostki x87.

## Struktura projektu

- `src/main.asm` — program początkowy.
- `Makefile` — konfiguracja budowania programu.
- `.vscode/launch.json` — konfiguracja debugowania.
- `.vscode/tasks.json` — zadanie budowania programu.
- `.devcontainer/` — konfiguracja środowiska GitHub Codespaces.

## Budowanie i uruchamianie

Program działa w systemie Linux x86-64. Punktem wejścia jest `_start`, a wywołania systemowe wykonujemy przez `syscall`.

Program można zbudować poleceniem `make`, a następnie uruchomić poleceniem `./main` w terminalu Codespaces.

Dane wejściowe wpisujemy w terminalu programu i zatwierdzamy klawiszem Enter. Nie wpisujemy ich do Debug Console.

Debugowanie w VS Code uruchamiamy z panelu Run and Debug lub klawiszem `F5`. Panel można otworzyć skrótem `Ctrl+Shift+D`.

Jeżeli konfiguracja debugowania nie udostępnia terminala do wprowadzania danych, GDB można uruchomić bezpośrednio w terminalu:

```text
gdb ./main
```

Następnie:

```text
break koniec
run
```

## Program początkowy

Program odczytuje dane ze standardowego wejścia, zapisuje je w buforze i zachowuje liczbę odczytanych bajtów. Po uruchomieniu programu wpisz kilka znaków np. `abc` i naciśnij Enter.

Plik `src/main.asm`:

```nasm
global _start

section .bss
    bufor resb 64
    liczba_bajtow resq 1    ; 8 bajtów ułatwia kopiowanie z rejestrów do pamięci

section .text
_start:
    ; Wczytaj dane ze standardowego wejscia.
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

koniec:
    ; Ustaw tutaj breakpoint, aby obejrzec bufor.
    mov rax, 60
    mov rdi, 0
    syscall
```

## Standardowe wejście i wyjście

Program korzysta z deskryptorów:

| Deskryptor | Znaczenie |
|---|---|
| `0` | Standardowe wejście — stdin. |
| `1` | Standardowe wyjście — stdout. |
| `2` | Standardowy strumień błędów — stderr. |

### Odczyt danych — read

| Rejestr | Znaczenie |
|---|---|
| `rax = 0` | Numer wywołania read. |
| `rdi = 0` | Standardowe wejście. |
| `rsi` | Adres bufora. |
| `rdx` | Maksymalna liczba bajtów do odczytania, nie większa niż rozmiar bufora. |

Po wykonaniu `syscall` rejestr `rax` zawiera:

- wartość dodatnią — liczbę odczytanych bajtów,
- `0` — koniec wejścia,
- wartość ujemną — kod błędu.

`read` odczytuje bajty. Nie zamienia tekstu na liczbę i nie dopisuje automatycznie bajtu zerowego kończącego napis.

Przy typowych ustawieniach terminala naciśnięcie Enter powoduje umieszczenie w odczytanych danych znaku nowej linii o wartości `10`.

Jedno wywołanie `read` nie musi odczytać całego wiersza ani całego strumienia.


## Obserwowanie danych w WATCH

Podczas debugowania rozwiń sekcję WATCH, kliknij `+` i dodaj wyrażenie. Każde wyrażenie wpisz osobno.

### Bufor jako tablica bajtów

```text
*(unsigned char (*))&bufor[1]
```

Rozwiń wynik, aby obejrzeć poszczególne bajty.

### Liczba odczytanych bajtów

```text
*(long long*)&liczba_bajtow
```

### Zmienna typu float

Dla zmiennej o nazwie `liczba_a`:

```text
*(float*)&liczba_a
```

### Rejestry

```text
$rax
```

```text
$rsi
```

```text
$rcx
```

```text
$st0
```

```text
$st1
```

Wyrażenia WATCH wpisujemy do debuggera, a nie do pliku NASM.

Pełny stan jednostki x87 można sprawdzić w Debug Console:

```text
-exec info float
```

W GDB uruchomionym bezpośrednio w terminalu pomijamy prefiks `-exec`.

## Zadanie 1: wypisanie zawartości bufora

Rozbuduj program początkowy tak, aby wypisywał na stdout tekst odczytany do bufora.

Wymagania:

1. Wykorzystaj wywołanie systemowe `write`.
2. Wypisz dokładnie tyle bajtów, ile odczytał `read`.
3. Wypisywanie umieść w procedurze `print_text`.

Argumenty procedury:

- `rdi` — adres tekstu,
- `rsi` — liczba bajtów do wypisania.

Sprawdź działanie dla krótkiego tekstu, tekstu zawierającego spacje i pustego wiersza.

## Zadanie 2: sprawdzanie liczby całkowitej

Napisz program, który odczytuje tekst ze stdin i sprawdza, czy jest on poprawnym zapisem liczby całkowitej.

Przyjmij następujące zasady:

- dopuszczalny jest opcjonalny znak minus na początku,
- po znaku minus musi wystąpić przynajmniej jedna cyfra,
- pozostałe znaki muszą być cyframi od `'0'` do `'9'`,
- spacje, kropki i inne znaki są niedozwolone,
- pusty wiersz nie jest liczbą,
- końcowy znak nowej linii nie jest częścią zapisu liczby.

Sprawdzamy poprawność zapisu, bez konwersji i bez sprawdzania zakresu liczby.

Na stdout wypisz jeden z komunikatów:

```text
To jest liczba calkowita.
```

```text
To nie jest liczba calkowita.
```

Sprawdzanie umieść w procedurze `is_integer`.

Argumenty:

- `rdi` — adres tekstu,
- `rsi` — długość tekstu bez końcowego znaku nowej linii.

Wynik:

- `rax = 1` — poprawny zapis liczby całkowitej,
- `rax = 0` — niepoprawny zapis.

Do wypisania komunikatu wykorzystaj procedurę `print_text` z zadania 1.

Przykładowe testy:

| Wejście | Wynik sprawdzania |
|---|---|
| `123` | Poprawny. |
| `-45` | Poprawny. |
| `0` | Poprawny. |
| `12.5` | Niepoprawny. |
| `12a` | Niepoprawny. |
| `-` | Niepoprawny. |
| Pusty wiersz | Niepoprawny. |

## Zadanie 3: odczyt dwóch liczb rzeczywistych i wypisanie większej

Napisz program, który:

1. Wczytuje pierwszy wiersz ze stdin do pierwszego bufora.
2. Wczytuje drugi wiersz ze stdin do drugiego bufora.
3. Sprawdza poprawność zapisu obu liczb rzeczywistych.
4. Zamienia poprawne zapisy na wartości typu float.
5. Porównuje wartości za pomocą jednostki x87.
6. Wypisuje większą liczbę na stdout.

Dane:

```nasm
section .bss
    bufor_a resb 64
    bufor_b resb 64

    dlugosc_a resq 1
    dlugosc_b resq 1

    liczba_a resd 1
    liczba_b resd 1
```

Każdą liczbę wpisuj osobno i zatwierdzaj klawiszem Enter.

Dla uproszczenia przyjmij następujący format:

- opcjonalny znak minus na początku,
- od 1 do 3 cyfr przed kropką,
- dokładnie jedna kropka,
- dokładnie dwie cyfry po kropce,
- brak spacji i innych znaków.

Końcowy znak nowej linii nie jest częścią zapisu liczby.

Przykłady poprawnych zapisów:

```text
12.50
-3.25
0.00
```

Przykłady niepoprawnych zapisów:

```text
12,50
3.2
abc
```

Sprawdzanie i konwersję umieść w procedurze `parse_float`, wywoływanej osobno dla każdej liczby.

Argumenty:

- `rdi` — adres tekstu,
- `rsi` — długość tekstu bez końcowego znaku nowej linii,
- `rdx` — adres zmiennej typu float, do której należy zapisać wartość.

Wynik:

- `rax = 1` — poprawny zapis i wykonana konwersja,
- `rax = 0` — niepoprawny zapis.

Jeżeli przynajmniej jedna liczba jest niepoprawna, wypisz:

```text
Niepoprawne dane.
```

Jeżeli obie liczby są poprawne:

- porównaj ich wartości na x87,
- wypisz oryginalny zapis większej liczby z odpowiedniego bufora,
- dla równych wartości wypisz pierwszą liczbę,
- zakończ wynik znakiem nowej linii.

Nie trzeba implementować konwersji float na tekst. O wyborze wyniku ma decydować porównanie wartości liczbowych, a nie porównanie napisów.

### Podpowiedź do konwersji

Dla formatu z dwiema cyframi po kropce można:

1. Zapamiętać znak liczby.
2. Zebrać cyfry, pomijając kropkę.
3. Utworzyć liczbę całkowitą według zasady:

```text
wartosc = wartosc * 10 + cyfra
```

4. Uwzględnić znak.
5. Wczytać liczbę całkowitą przez `fild`.
6. Podzielić ją przez `100.0`.
7. Zapisać wynik przez `fstp dword [...]`.

Przykład:

```text
Tekst: -12.50
Liczba calkowita: -1250
Po podzieleniu przez 100: -12.5
```

### Przykładowe działanie

Pierwsze wejście:

```text
12.50
```

Drugie wejście:

```text
7.25
```

Wyjście:

```text
12.50
```

Sprawdź również pary:

- `-3.50` i `2.75`,
- `-10.00` i `-2.50`,
- `4.25` i `4.25`,
- poprawna liczba i niepoprawny tekst.

Wystarczy obsługa krótkich wierszy wpisywanych interaktywnie. Obsługa dowolnego podziału strumienia na odczyty nie jest wymagana.

## Uwagi

- Przetwarzaj wyłącznie bajty należące do odczytanych danych.
- Rozmiar bufora nie jest tym samym co długość odczytanego tekstu.
- Dokumentuj rejestry zmieniane przez procedury.
- Wywołanie `syscall` nadpisuje między innymi `rcx` i `r11`.
- Po zakończeniu konwersji i porównania stos FPU powinien być pusty.
- Pliki wynikowe kompilacji powinny być pomijane przez `.gitignore`.

*Last updated: 2026-11-03*
