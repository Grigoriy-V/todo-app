# To-Do List App с авторизацией

> Простой сервис для управления задачами с регистрацией и входом.

---

## 🚀 Технологии

- **Frontend:** React, React Router, Axios  
- **Backend:** Node.js, Express, MongoDB (Mongoose), JWT  
- **Утилиты:** dotenv, cors, express-async-handler  

---

## 🛠 Установка

1. Клонировать репозиторий и перейти в папку проекта:  
   ```bash
   git clone https://github.com/ВАШ_ЛОГИН/todo-app.git
   cd todo-app
   ```
2. Настроить переменные окружения для бэкенда:  
   ```bash
   cp backend/.env.example backend/.env
   ```  
   Откройте файл `backend/.env` и заполните:
   ```ini
   MONGO_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret
   PORT=5000
   ```
3. Установить зависимости и запустить сервер:  
   ```bash
   cd backend
   npm install
   npm run dev
   ```
4. Установить зависимости и запустить клиент:  
   ```bash
   cd ../frontend
   npm install
   npm start
   ```

> Приложение будет доступно по адресу `http://localhost:3000`.

---

## 📄 API

### 🔑 Auth

**POST** `/api/auth/register`  
Регистрация пользователя.  
**Тело запроса (JSON):**
```json
{
  "name": "Ваше имя",
  "email": "email@example.com",
  "password": "ваш_пароль"
}
```

**POST** `/api/auth/login`  
Вход пользователя.  
**Тело запроса (JSON):**
```json
{
  "email": "email@example.com",
  "password": "ваш_пароль"
}
```

---

### 📝 Todos (требует авторизации)

Все запросы должны содержать заголовок:
```
Authorization: Bearer <token>
```

- **GET** `/api/todos`  
  Получить список всех задач пользователя.

- **POST** `/api/todos`  
  Создать новую задачу.  
  **Тело запроса (JSON):**
  ```json
  { "text": "Текст задачи" }
  ```

- **PUT** `/api/todos/:id`  
  Обновить задачу (текст или статус).  
  **Тело запроса (JSON):**
  ```json
  { "text": "Новый текст", "completed": true }
  ```

- **DELETE** `/api/todos/:id`  
  Удалить задачу.

---

