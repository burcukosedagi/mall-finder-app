# Mall Finder App 🛍️

A cross-platform Flutter application integrated with a Node.js RESTful API and PostgreSQL database.  
It allows users to search, filter, and explore shopping malls across Turkey, view mall details on an interactive map, and experience gamified features like “Surprise Me”.

---

## 🌟 Features

- 🗺️ Mall search on an interactive map with real-time location
- 🔎 Advanced filtering by brand, facility, and location
- 🎲 “Surprise Me” feature (Şansıma Ne Çıkarsa)
- 🏬 Mall detail pages with store lists, user comments, and events
- 🛍️ Shopping planner with weather integration
- 🔐 Admin-managed backend (pgAdmin + RESTful API)

---

## 🚀 Tech Stack

**Frontend:**  
- Flutter  
- Dart  

**Backend:**  
- Node.js (Express.js)  
- RESTful API  

**Database:**  
- PostgreSQL  
- pgAdmin  

---

## 📁 Project Structure

avmapp/
├── frontend/ # Flutter mobile app
├── backend/ # Node.js backend with Express API
├── .gitignore # Flutter + Node combined
├── README.md
└── LICENSE


---

## 🛠️ Getting Started

### 🔧 Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
2. Install dependencies:
    npm install
3. Create a .env file and set your variables:
    PORT=5000
DATABASE_URL=your_postgresql_connection_string
4. Run the server:
   npm run dev

### 📱 Frontend Setup

1. Negative to the frontend directory:
   cd frontend
2. Get dependencies:
   flutter pub get
3. Run the app:
   flutter run      

###   🧩 To-Do

 1. User authentication and login
 2. Admin panel for mall management
 3. Push notifications
 4. Multi-language support (EN/TR)

### 📄 License

This project is licensed under the MIT License.

---



1. Terminal:

```bash
git add README.md
git commit -m "Add final README"
git push
