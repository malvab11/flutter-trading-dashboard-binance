# 📈 Flutter Trading Dashboard (Binance Real-Time)

Aplicación de prueba técnica Flutter que simula un dashboard de trading profesional utilizando la API pública de Binance. Muestra datos financieros en tiempo real como precios, ordenes de compra/venta y permite calcular operaciones con comisiones incluidas.

---

## 🚀 Funcionalidades

### 🏠 Dashboard Principal
- Precio en tiempo real de pares BTC/USDT y ETH/USDT
- Cambio porcentual en 24h
- Volumen de trading
- Indicadores visuales de subida/bajada (verde/rojo)

### 📊 Vista Detallada de Par
- Precio actual con animación
- Estadísticas: apertura, cierre, máximo, mínimo
- Gráfico de precios simple o candlestick

### 📘 Libro de Órdenes (Order Book)
- Bids (compras) y Asks (ventas) en tiempo real
- Visualización en tabla con colores diferenciados
- Spread actual calculado automáticamente

### 🧮 Calculadora de Trading
- Selección entre compra o venta
- Cálculo automático de monto a recibir
- Comisiones incluidas (0.1%)
- Validaciones y actualización dinámica

---

## ⚙️ Tecnologías Usadas

- **Flutter** (última versión estable)
- **Provider** para manejo de estado
- **WebSocketChannel** para comunicación en tiempo real
- **fl_chart** para gráficos
- **Intl** para formato de números
- **API WebSocket de Binance**

---

## 🔌 WebSockets Binance Utilizados

- Ticker:  
  `wss://stream.binance.com:9443/ws/btcusdt@ticker`  
  `wss://stream.binance.com:9443/ws/ethusdt@ticker`

- Order Book:  
  `wss://stream.binance.com:9443/ws/btcusdt@depth20@100ms`  
  `wss://stream.binance.com:9443/ws/ethusdt@depth20@100ms`

---

## 📷 Capturas

(Pendientes de Agregar hasta finalizar el desarrollo)

---

## 📥 Instalación y Ejecución

```bash
git clone https://github.com/tu-usuario/flutter-trading-dashboard-binance.git
cd flutter-trading-dashboard-binance
flutter pub get
flutter run
