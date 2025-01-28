.global vector_add
.global scalar_multiply
.global vector_subtract
.global dot_product
.global vector_norm
.global vector_distance
.global V_step
.global acum_step
.global escala_vect
.global vect_sobre_escalar

! ============================
! Definición de Vectores y Constantes
! ============================

u: .word 2, 3             ! Vector u = [2, 3]
v: .word 4, 1             ! Vector v = [4, 1]
result: .word 0, 0        ! Espacio para el vector resultado [0, 0]
scalar: .word 2           ! Valor escalar = 2
fuerza: .word 5, 3        ! Fuerza para el paso de velocidad [5, 3]
tiempo: .word 1           ! Escalar de tiempo (t = 1)
num_elementos: .word 2    ! Número de elementos (dimensión del vector)

.align 4
.global _start
_start:
    ! --------------------------
    ! Suma de Vectores: result = u + v
    ! --------------------------
    mov 8, %o0             ! Tamaño del vector (2 elementos * 4 bytes)
    set u, %o1             ! Dirección del vector u
    set v, %o2             ! Dirección del vector v
    set result, %o3        ! Dirección del vector resultado
    call vector_add       ! Llamada a la rutina suma_vector
    nop

    ! --------------------------
    ! Multiplicación por escalar: result = scalar * u
    ! --------------------------
    mov 8, %o0             ! Tamaño del vector
    set u, %o1             ! Dirección del vector u
    mov 5, %o2             ! Cargar valor escalar en %o2 (scalar = 5)
    set result, %o3        ! Dirección del vector resultado
    call escala_vect       ! Llamada a la rutina escala_vect
    nop

    ! --------------------------
    ! División de Vectores por escalar: result = u / escalar
    ! --------------------------
    set 8, %o0             ! Tamaño del vector
    set u, %o1             ! Dirección del vector u
    mov 5, %o2             ! Cargar valor escalar en %o2 (escalar divisor = 5)
    set result, %o3        ! Dirección del vector resultado
    call vect_sobre_escalar  ! Llamada a la rutina vect_sobre_escalar
    nop

    ! --------------------------
    ! Cálculo de desplazamiento y velocidad final: result = V_step
    ! --------------------------
    set fuerza, %o1        ! Dirección de la fuerza
    set tiempo, %o2        ! Dirección de t (escalar)
    set num_elementos, %o3 ! Número de elementos (dimensión)
    set u, %o0             ! Dirección de la velocidad
    call V_step            ! Llamada a la rutina V_step
    nop

    ! --------------------------
    ! Acumulación de pasos: acum_step
    ! --------------------------
    set 10, %o4            ! Número de pasos
    set tiempo, %o5        ! Tiempo t
    set u, %o1             ! Dirección de posición
    set result, %o2        ! Dirección de velocidad
    set fuerza, %o3        ! Dirección de fuerza
    set num_elementos, %o0 ! Número de elementos del vector
    call acum_step         ! Llamada a la rutina acum_step
    nop

    ! --------------------------
    ! Exit del programa
    ! --------------------------
    mov 1, %g1             ! syscall: exit
    nop !ta 0                   ! Invocar la syscall de salida

! ============================
! Macros
! ============================

! Define PUSH macro to save registers
.macro PUSH reg
    ! Save register on stack
    sub %sp, 4, %sp             ! Decrement stack pointer (reserve space)
    st reg, [%sp]               ! Store the register value on the stack
.endm

! Define POP macro to restore registers
.macro POP reg
    ld [%sp], reg               ! Load the register value from the stack
    add %sp, 4, %sp             ! Increment stack pointer (restore space)
.endm

! Clear a register (set to zero)
.macro clr reg
    mov 0, reg                 ! Set register to zero
.endm

.macro set value, reg
    sethi %hi(value), reg      ! Load high 22 bits of the value
    or reg, %lo(value), reg    ! Combine with low 10 bits
.endm

! ============================
! Rutinas de Cálculo de Vectores
! ============================

!-----------------------------------------------------------
! Subrutina: suma_vector
! Realiza la suma de dos vectores elemento a elemento
!-----------------------------------------------------------
vector_add:
    sub %sp, 32, %sp            ! Allocate space on the stack for %l0-%l3, %l4-%l7 (más espacio)
    st %l0, [%sp + 0]           ! Save %l0
    st %l1, [%sp + 4]           ! Save %l1
    st %l2, [%sp + 8]           ! Save %l2
    st %l3, [%sp + 12]          ! Save %l3
    st %l4, [%sp + 16]          ! Save %l4
    st %l5, [%sp + 20]          ! Save %l5
    st %l6, [%sp + 24]          ! Save %l6
    st %l7, [%sp + 28]          ! Save %l7

    clr %l0                     ! Clear index register (i = 0)

add_loop_vector_add:
    ld [%o1 + %l0], %l1         ! Load u[i] into %l1
    ld [%o2 + %l0], %l2         ! Load v[i] into %l2
    add %l1, %l2, %l3           ! result[i] = u[i] + v[i]
    st %l3, [%o3 + %l0]         ! Store result in result[i]

    add %l0, 4, %l0             ! Increment i by 4 (int = 4 bytes)
    cmp %l0, %o0                ! Check if i < size
    bl add_loop_vector_add      ! Continue loop
    nop

    ld [%sp + 0], %l0           ! Restore %l0
    ld [%sp + 4], %l1           ! Restore %l1
    ld [%sp + 8], %l2           ! Restore %l2
    ld [%sp + 12], %l3          ! Restore %l3
    ld [%sp + 16], %l4          ! Restore %l4
    ld [%sp + 20], %l5          ! Restore %l5
    ld [%sp + 24], %l6          ! Restore %l6
    ld [%sp + 28], %l7          ! Restore %l7
    add %sp, 32, %sp            ! Deallocate stack space

    retl
    nop


!-----------------------------------------------------------
! Subrutina: escala_vect
! Multiplica un vector por un escalar
!-----------------------------------------------------------
escala_vect:
    sub %sp, 32, %sp            ! Allocate space on the stack for %l0-%l3, %l4-%l7 (más espacio)
    st %l0, [%sp + 0]           ! Save %l0
    st %l1, [%sp + 4]           ! Save %l1
    st %l2, [%sp + 8]           ! Save %l2
    st %l3, [%sp + 12]          ! Save %l3
    st %l4, [%sp + 16]          ! Save %l4
    st %l5, [%sp + 20]          ! Save %l5
    st %l6, [%sp + 24]          ! Save %l6
    st %l7, [%sp + 28]          ! Save %l7

    clr %l0                     ! Clear index register (i = 0)

scalar_loop_escala_vect:
    ld [%o1 + %l0], %l1         ! Load u[i] into %l1
    mulscc %l1, %o2, %l2        ! result[i] = scalar * u[i] (using MULSCC)
    st %l2, [%o3 + %l0]         ! Store result in result[i]

    add %l0, 4, %l0             ! Increment i by 4
    cmp %l0, %o0                ! Check if i < size
    bl scalar_loop_escala_vect  ! Continue loop
    nop

    ld [%sp + 0], %l0           ! Restore %l0
    ld [%sp + 4], %l1           ! Restore %l1
    ld [%sp + 8], %l2           ! Restore %l2
    ld [%sp + 12], %l3          ! Restore %l3
    ld [%sp + 16], %l4          ! Restore %l4
    ld [%sp + 20], %l5          ! Restore %l5
    ld [%sp + 24], %l6          ! Restore %l6
    ld [%sp + 28], %l7          ! Restore %l7
    add %sp, 32, %sp            ! Deallocate stack space

    retl
    nop


!-----------------------------------------------------------
! Subrutina: vect_sobre_escalar
! Divide un vector por un escalar
!-----------------------------------------------------------
vect_sobre_escalar:
    sub %sp, 32, %sp            ! Allocate space on the stack for %l0-%l3, %l4-%l7 (más espacio)
    st %l0, [%sp + 0]           ! Save %l0
    st %l1, [%sp + 4]           ! Save %l1
    st %l2, [%sp + 8]           ! Save %l2
    st %l3, [%sp + 12]          ! Save %l3
    st %l4, [%sp + 16]          ! Save %l4
    st %l5, [%sp + 20]          ! Save %l5
    st %l6, [%sp + 24]          ! Save %l6
    st %l7, [%sp + 28]          ! Save %l7

    clr %l0                     ! Clear index register (i = 0)

scalar_loop_vect_sobre_escalar:
    ld [%o1 + %l0], %l1         ! Load u[i] into %l1
    sdivcc %l1, %o2, %l2        ! result[i] = scalar * u[i] (using MULSCC)
    st %l2, [%o3 + %l0]         ! Store result in result[i]

    add %l0, 4, %l0             ! Increment i by 4
    cmp %l0, %o0                ! Check if i < size
    bl scalar_loop_vect_sobre_escalar  ! Continue loop
    nop

    ld [%sp + 0], %l0           ! Restore %l0
    ld [%sp + 4], %l1           ! Restore %l1
    ld [%sp + 8], %l2           ! Restore %l2
    ld [%sp + 12], %l3          ! Restore %l3
    ld [%sp + 16], %l4          ! Restore %l4
    ld [%sp + 20], %l5          ! Restore %l5
    ld [%sp + 24], %l6          ! Restore %l6
    ld [%sp + 28], %l7          ! Restore %l7
    add %sp, 32, %sp            ! Deallocate stack space

    retl
    nop

!-----------------------------------------------------------
! Subrutina: V_step
! Calcula el desplazamiento y la velocidad final
!-----------------------------------------------------------
V_step:
    save %sp, -96, %sp            ! Reserva espacio en la pila para las variables locales
    ! Argumentos:
    ! %i0 -> Dirección base del vector V (velocidad)
    ! %i1 -> Dirección base del vector F (fuerza)
    ! %i2 -> t (escalar de tiempo)
    ! %i3 -> Número de elementos del vector (dimensión)

    clr %l0                     ! Limpiar el registro índice
    clr %l1                     ! Limpiar el registro temporal

loop_V_step:
    cmp %l0, %i3                ! Comparar índice con tamaño del vector
    bge end_V_step              ! Si i >= tamaño, salir del bucle
    nop

    sll %l0, 2, %l2             ! Calcular desplazamiento en bytes
    add %i0, %l2, %l3           ! Dirección de V[i]
    add %i1, %l2, %l4           ! Dirección de F[i]
    
    ld [%l3], %l5               ! Cargar valor de V[i] en %l5
    ld [%l4], %l6               ! Cargar valor de F[i] en %l6
    
    sdiv %l6, %l0, %l7          ! Realizar división F[i] / i
    mulx %l7, %i2, %l8          ! Multiplicar por t (tiempo)
    add %l5, %l8, %l9           ! Sumamos la velocidad final

    st %l9, [%l3]               ! Almacenar en V[i]

    add %l0, 1, %l0             ! Incrementar índice
    ba loop_V_step
    nop

end_V_step:
    retl
    restore

!-----------------------------------------------------------
! Subrutina: acum_step
! Acumula posiciones en un vector de memoria
!-----------------------------------------------------------
acum_step:
    save %sp, -96, %sp            ! Reserva espacio en la pila
    ! Argumentos:
    ! %i0 -> Dirección base del vector pos_i
    ! %i1 -> Dirección base del vector v_i
    ! %i2 -> Dirección base del vector kv
    ! %i3 -> Número de elementos del vector
    ! %i4 -> Número de pasos
    ! %i5 -> t

    clr %l0                     ! Limpiar índice

loop_acum:
    cmp %l0, %i4                ! Comparar número de pasos
    bge end_acum                ! Si se ha completado, salir del bucle
    nop

    mov %i1, %o0                ! Pasar parámetros a la subrutina V_step
    mov %i2, %o1
    mov %i5, %o2
    mov %i3, %o3
    call V_step
    nop

    add %l0, 1, %l0             ! Incrementar número de pasos
    ba loop_acum
    nop

end_acum:
    retl
    restore

    ! --------------------------
    ! Scalar Multiplication: result = scalar * u
    ! --------------------------
    mov 8, %o0            ! Size of vector
    set u, %o1            ! Address of vector u
    mov 5, %o2            ! Load scalar value into %o4
    set result, %o3       ! Address of result vector
 
    call scalar_multiply  ! Call scalar_multiply routine
    nop

    ! Print result of scalar multiplication
    !set result, %o0       ! Address of result vector
    !set 8, %o1            ! Size of vector
    !call print_vector     ! Print the vector
    nop

    ! --------------------------
    ! Vector Subtraction: result = u - v
    ! --------------------------
    set 8, %o0            ! Size of vector
    set u, %o1            ! Address of vector u
    set v, %o2            ! Address of vector v
    set result, %o3       ! Address of result vector

    !call vector_subtract  ! Call vector_subtract routine
    nop

    ! Print result of vector subtraction
    !!set result, %o0       ! Address of result vector
    !set 8, %o1            ! Size of vector
    !call print_vector     ! Print the vector
    nop

    ! Exit the program
    !mov 1, %g1            ! syscall: exit
    nop !ta 0

vector_add:
    sub %sp, 16, %sp            ! Allocate space on the stack for %l0-%l3
    st %l0, [%sp + 0]           ! Save %l0
    st %l1, [%sp + 4]           ! Save %l1
    st %l2, [%sp + 8]           ! Save %l2
    st %l3, [%sp + 12]          ! Save %l3

    clr %l0                     ! Clear index register (i = 0)

add_loop:
    ld [%o1 + %l0], %l1         ! Load u[i] into %l1
    ld [%o2 + %l0], %l2         ! Load v[i] into %l2
    add %l1, %l2, %l3           ! result[i] = u[i] + v[i]
    st %l3, [%o3 + %l0]         ! Store result in result[i]

    add %l0, 4, %l0             ! Increment i by 4 (int = 4 bytes)
    cmp %l0, %o0                ! Check if i < size
    bl add_loop                 ! Continue loop
    nop

    ld [%sp + 0], %l0           ! Restore %l0
    ld [%sp + 4], %l1           ! Restore %l1
    ld [%sp + 8], %l2           ! Restore %l2
    ld [%sp + 12], %l3          ! Restore %l3
    add %sp, 16, %sp            ! Deallocate stack space

    ret
    nop


! ============================
! Scalar Multiplication: scalar * u = result
! Parameters:
! o0 = size of vectors
! o1 = address of vector u
! o2 = scalar value (as an integer)
! o3 = address of result

scalar_multiply:
    sub %sp, 16, %sp            ! Allocate space on the stack for %l0-%l3
    st %l0, [%sp + 0]           ! Save %l0
    st %l1, [%sp + 4]           ! Save %l1
    st %l2, [%sp + 8]           ! Save %l2
    st %l3, [%sp + 12]          ! Save %l3

    clr %l0                     ! Clear index register (i = 0)

scalar_loop:
    ld [%o1 + %l0], %l1         ! Load u[i] into %l1
    mulscc %l1, %o2, %l2        ! result[i] = scalar * u[i] (using MULSCC)
    st %l2, [%o3 + %l0]         ! Store result in result[i]

    add %l0, 4, %l0             ! Increment i by 4
    cmp %l0, %o0                ! Check if i < size
    bl scalar_loop              ! Continue loop
    nop

    ld [%sp + 0], %l0           ! Restore %l0
    ld [%sp + 4], %l1           ! Restore %l1
    ld [%sp + 8], %l2           ! Restore %l2
    ld [%sp + 12], %l3          ! Restore %l3
    add %sp, 16, %sp            ! Deallocate stack space

    ret
    nop





! ============================
! Vector Subtraction: u - v = result
! Parameters:
! o0 = size of vectors
! o1 = address of vector u
! o2 = address of vector v
! o3 = address of result

vector_subtract:
    sub %sp, 8, %sp            ! Allocate space 
    st %o7, [%sp + 0]           ! Save %o7 (return address)
    st %o1, [%sp + 4]          

    ! Multiply vector v by -1 to get (-1 * v)
    mov %o2, %o1
    set -1, %o2                 ! Set scalar value to -1 
    call scalar_multiply        ! Call scalar_multiply(u = %o1, result = %o2, size = %o2, scalar = %o3)
    nop                         ! Delay slot (SPARC requirement)

    ld [%sp + 4], %o1          
    mov %o3, %o2    
    call vector_add             ! Call vector_add(u, v, result, size)
    nop                         ! Delay slot

    ld [%sp + 0], %o7           ! Restore %o7 (return address)
    add %sp, 8, %sp            ! Deallocate stack space
    ret
    nop
