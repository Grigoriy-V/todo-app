To-Do List App с авторизацией
Простой сервис для управления задачами с регистрацией и входом.

🚀 Технологии
Frontend: React, React Router, Axios

Backend: Node.js, Express, MongoDB (Mongoose), JWT

Утилиты: dotenv, cors, express-async-handler

Установка
Клонировать репозиторий и перейти в папку проекта:
git clone https://github.com/ВАШ_ЛОГИН/todo-app.git
cd todo-app

Настроить переменные окружения для бэкенда:
cp backend/.env.example backend/.env
Откройте файл backend/.env и заполните:
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
PORT=5000

Установить зависимости и запустить сервер:
cd backend
npm install
npm run dev

Установить зависимости и запустить клиент:
cd ../frontend
npm install
npm start

Приложение будет доступно по адресу http://localhost:3000.

📄 API
Auth
POST /api/auth/register
Регистрация пользователя.
Тело запроса (JSON):

json
Копировать
Редактировать
{
  "name": "Ваше имя",
  "email": "email@example.com",
  "password": "ваш_пароль"
}
POST /api/auth/login
Вход пользователя.
Тело запроса (JSON):

json
Копировать
Редактировать
{
  "email": "email@example.com",
  "password": "ваш_пароль"
}
Todos (требует авторизации)
Все запросы должны содержать заголовок
Authorization: Bearer <token>

GET /api/todos
Получить список всех задач пользователя.

POST /api/todos
Создать новую задачу.
Тело запроса (JSON):

json
Копировать
Редактировать
{ "text": "Текст задачи" }
PUT /api/todos/:id
Обновить задачу (текст или статус).
Тело запроса (JSON):

json
Копировать
Редактировать
{ "text": "Новый текст", "completed": true }
DELETE /api/todos/:id
Удалить задачу.

Лицензия
MIT © Ваше Имя
