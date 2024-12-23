; section .bss ; Секция переменных

section .data ; Секция данных
    first dd '0'; Первое число длиной 5 символов в формате строки
    second dd '0'; Второе число длиной 5 символов в формате строки
    len dd 22; Длина введенной строки для преобразования строки в число
    input dd 0; Временное значеие для перевода числа в строку

    converted dd 0; Результат вычислений УЖЕ в формате числа
    result dd 0; Итоговый результат вычислений выводящийся в терминале

    hello dd "This is a basic calculator. It can '+', '-', '*' and '/' numbers", 0xA   ; Строка с символом новой строки
    hello_len equ $ - hello        ; Вычисляем длину строки
    prompt1 dd "Enter first number: ", 0 ; Сообщение о первом числе
    prompt1_len equ $ - prompt1 ; Вычисляем длину первого запроса
    prompt2 dd "Enter second number ", 0 ; Сообщение о втором числе
    prompt2_len equ $ - prompt2 ; Вычисляем длину второго запроса
    condition_invalid dd 'Неверно указано условие', 0xA
    condition dd '0'; Флаг-условие для выбора действия над числами
    condition_mul dd '*', 0xA
    condition_add dd '+', 0xA
    condition_sub dd '-', 0xA
    condition_div dd '/', 0Xa

section .text           ; Секция кода
    global _start       ; Точка входа в программу

_start:                 ; Начало программы

; Приветствие с пользователем
mov eax, 4 ; Номер системного вызова: sys_write
mov ebx, 1 ; Дескриптор файла: 1 (stdout)
mov ecx, hello ; Сохраняем в регистре сообщение для вывода в терминал
mov edx, hello_len ; сохраняем в регистре ДЛИНУ сообщения для вывода в терминал
call call_kernel ; вызов ядра

; Запрос двух чисел
call get_first_number
call get_second_number
call condition_select
; Переделать по следующему алгоритму
; 1. Ввод первого числа
; 2. Перевод первого числа из ASCI в числовой формат
; 3. Ввод второго числа
; 4. Перевод второго числа из ASCI в числовой формат
; 5. Ввод действия над ними
; 6. В зависимости от действия над ними выполнять операции
; 7. Результат операции перевести из числового формата в ASCI
; 8. Вывод результата

; Завершаем программу
mov eax, 1 ; Номер системного вызова: sys_exit
xor ebx, ebx ; Код возврата: 0
call call_kernel ; Вызов ядра

greetings:
    ; Пишем строку в stdout
    ; call output
    mov ecx, hello ; Адрес строки
    mov edx, hello_len ; Длина строки
    call call_kernel ; Вызов ядра
    ret

get_first_number:
    ; выводим сообщение с просьбой ввода первого числа из переменной
    call stdout_prep
    mov ecx, prompt1 ; сохраняем в регистре сообщение для вывода в терминал
    mov edx, prompt1_len ; сохраняем в регистре ДЛИНУ сообщения для вывода в терминал
    call call_kernel ; вызов ядра

    mov dword [input], first ; назначаем временной переменной input значение поля ввода для функции чтения из stdin

    call read_from_stdin
    call first_ascii_to_number
    ret

get_second_number:
    ; выводим сообщение с просьбой ввода первого числа из переменной
    call stdout_prep
    mov ecx, prompt2 ; сохраняем в регистре сообщение для вывода в терминал
    mov edx, prompt2_len ; сохраняем в регистре ДЛИНУ сообщения для вывода в терминал
    call call_kernel ; вызов ядра

    mov dword [input], second ; назначаем временной переменной input значение поля ввода для функции чтения из stdin

    call read_from_stdin
    call second_ascii_to_number
    call condition_select
    ret

stdout_prep:
    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    ret

call_kernel:
    int 0x80 ; вызов ядра
    ret

read_from_stdin:
    ; считать строку из stdin
    mov eax, 3 ; запрос sys_read
    mov ebx, 0 ; stdin
    mov ecx, input ; буфер, назначается из функций get... для чисел
    mov edx, 7 ; максимальная длина
    call call_kernel ; вызов ядра
    mov [len], eax ; выгрузить из регистра длину ввода
    ret

condition_select:
    mov esi, condition
    mov edi, condition_mul

    call compare_strings
    je case_mul
    ret

case_mul:
    call multiplication
    ret

case_add:
    call addition
    ret

case_sub:
    call substraction
    ret

case_div:
    call division
    ret

compare_strings:
    mov ecx, 1 ; максимальная длина строки
    repe cmpsb ; сравниваем байты строк
    mov eax, 0 ; сброс результата
    jne not_equal ; если не совпадает то выходим с ZF = 0
    cmp byte [esi-1], 0 ; Проверяем конец строки
    je equal ; если строки равны, устанавливаем ZF = 1

not_equal:
    ret

equal:
    mov dword [condition], 1
    ret

multiplication:
    ; Умножение
    call calc_prep
    mul dword [second] ; умножаем EAX на EBX с результатом в EAX
    call result_saving
    ret

addition:
    ; Сложение
    call calc_prep
    add eax, [second] ; складвыаем EAX с EBX с результатом в EAX
    call result_saving
    ret

substraction:
    ; Вычитание
    call calc_prep
    sub eax, [second] ; вычитаем EAX из EBX с результатом в EAX
    call result_saving
    ret

division:
    ; Деление
    call calc_prep
    div dword [second] ; делим EAX на EBX с результатом в EAX
    call result_saving
    ret

calc_prep:
    ; Подготовка к вычислениям
    mov eax, [first] ; Загружаем первое число в регистр из конвертированной переменной;
    ret

result_saving:
    mov [result], eax ; сохраняем в переменной результат чтобы использовать его для вывода
    ret

first_ascii_to_number:
    mov esi, first ; указатель на начало строки
    xor eax, eax ; очищаем регистр EAX для числа

    call convert_loop

    mov dword [first], converted ; после конвертации переназначаем переменную
    ret

second_ascii_to_number:
    mov esi, second ; указатель на начало строки
    xor eax, eax ; очищаем регистр EAX для числа

    call convert_loop

    mov dword [second], converted ; после конвертации переназначаем переменную
    ret

; convert_loop и done_conversion - две части функции по переводу строки в число

convert_loop:
    movzx ebx, byte [esi] ; загрузить символ
    cmp bl, 0x0A ; проверить на конец строки (\n)

    je done_conversion ; если конец, то выйти из цикла

    sub bl, '0' ; преобразовать символ в число
    imul eax, eax, 10 ; умножить текущее число на 10
    add eax, ebx ; добавить текущую цифру
    inc esi ; перейти к следующему символу в строке

    jmp convert_loop ; если не конец, то возобновить цикл, пройти по нему заново
    ret

; done_conversion вызывается из convert_loop для выхода из лупа
done_conversion:
    mov [converted], eax ; сохранить результат
    ret

; Проверить:
; division: что на что делит
; substraction: что из чего вычитает

; To Do:
; Сделать развилку по выбору действия над числами
; Типа 1 - mul, 2 - add, 3 - sub, 4 - div
; Вывести на экран результат, предварительно преобразовав число обратно в ASCII
; Сделать проверку деления на ноль
; Сделать проверку развилки на недопустимое значение
