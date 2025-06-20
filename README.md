# Trabajo Final Módulo 3: Implementación de SimpleSwap

## 🎯 Objetivo

Crear un contrato inteligente llamado **SimpleSwap** que permita:

- Agregar y remover liquidez.
- Intercambiar tokens.
- Obtener precios.
- Calcular cantidades a recibir.

Todo esto replicando la funcionalidad de Uniswap sin depender de su protocolo.

---

## 📢 Requerimientos

### 1️⃣ Agregar Liquidez (`addLiquidity`)

**Descripción:**  
Función para que los usuarios agreguen liquidez a un par de tokens en un pool ERC-20.

**Interfaz:**  
function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);

**Tareas:**
- Transferir tokens del usuario al contrato.
- Calcular y asignar liquidez según reservas.
- Emitir tokens de liquidez al usuario.

**Parámetros:**
- `tokenA`, `tokenB`: Direcciones de los tokens.
- `amountADesired`, `amountBDesired`: Cantidades deseadas de tokens.
- `amountAMin`, `amountBMin`: Mínimos aceptables para evitar fallos.
- `to`: Dirección del destinatario.
- `deadline`: Marca de tiempo para la transacción.

**Retornos:**
- `amountA`, `amountB`, `liquidity`: Cantidades efectivas y liquidez emitida.

### 2️⃣ Remover Liquidez (`removeLiquidity`)

**Descripción:**  
Función para que los usuarios retiren liquidez de un pool ERC-20.

**Interfaz:** 
function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);

**Tareas:**
- Quemar tokens de liquidez del usuario.
- Calcular y retornar tokens A y B.

**Parámetros:**
- `tokenA`, `tokenB`: Direcciones de los tokens.
- `liquidity`: Cantidad de tokens de liquidez a retirar.
- `amountAMin`, `amountBMin`: Mínimos aceptables para evitar fallos.
- `to`: Dirección del destinatario.
- `deadline`: Marca de tiempo para la transacción.

**Retornos:**
- `amountA`, `amountB`: Cantidades recibidas tras retirar liquidez.

### 3️⃣ Intercambiar Tokens (`swapExactTokensForTokens`)

**Descripción:**  
Función para intercambiar un token por otro en cantidad exacta.

**Interfaz:**
function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

**Tareas:**
- Transferir token de entrada del usuario al contrato.
- Calcular intercambio según reservas.
- Transferir token de salida al usuario.

**Parámetros:**
- `amountIn`: Cantidad de tokens de entrada.
- `amountOutMin`: Mínimo aceptable de tokens de salida.
- `path`: Array de direcciones de tokens (token entrada, token salida).
- `to`: Dirección del destinatario.
- `deadline`: Marca de tiempo para la transacción.

**Retornos:**
- `amounts`: Array con cantidades de entrada y salida.

---

### 4️⃣ Obtener el Precio (`getPrice`)

**Descripción:**  
Función para obtener el precio de un token en términos de otro.

**Interfaz:**
function getPrice(address tokenA, address tokenB) external view returns (uint price);

**Tareas:**
- Obtener reservas de ambos tokens.
- Calcular y retornar el precio.

**Parámetros:**
- `tokenA`, `tokenB`: Direcciones de los tokens.

**Retorno:**
- `price`: Precio de `tokenA` en términos de `tokenB`.

---

### 5️⃣ Calcular Cantidad a Recibir (`getAmountOut`)

**Descripción:**  
Función para calcular cuántos tokens se recibirán al intercambiar.

**Interfaz:**
Function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

**Tareas:**
- Calcular y retornar cantidad a recibir.

**Parámetros:**
- `amountIn`: Cantidad de tokens de entrada.
- `reserveIn`, `reserveOut`: Reservas actuales en el contrato.

**Retorno:**
- `amountOut`: Cantidad de tokens a recibir.
