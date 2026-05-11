# 資料庫快取優化方案 (Database Caching Strategy)

為了降低 Google Places API 的調用成本並提升 App 反應速度，計畫導入本地資料庫（SQL）緩存機制。

## 🎯 核心目標
- **排除重複搜尋成本**：同一個用戶在相近位置、相同時段搜尋時，直接讀取快取。
*   **提升反應速度**：消除 API 網路延遲，實現秒開餐廳列表。
*   **節省 API 額度**：將 $200 的免費額度留給「探索新區域」的請求。

---

## 🛠 快取機制設計

### 1. 資料庫結構 (Proposed Schema)
```sql
CREATE TABLE CachedPlaces (
    id TEXT PRIMARY KEY,        -- Google Place ID
    name TEXT NOT NULL,
    lat REAL,
    lng REAL,
    address TEXT,
    rating REAL,
    review_count INTEGER,
    budget_level TEXT,
    categories TEXT,            -- 存儲為 JSON 字串或逗號分隔
    photo_url TEXT,
    meal_time_tag TEXT,         -- 標籤：早餐/午餐/晚餐...
    expiry_date TIMESTAMP       -- 過期時間（例如 7 天後）
);

CREATE TABLE SearchHistory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_lat REAL,
    user_lng REAL,
    meal_time TEXT,
    search_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. 快取判定邏輯
當用戶發起「隨機推薦」或「列表搜尋」時：
1.  **計算距離**：檢查資料庫中是否有 `SearchHistory` 紀錄在用戶目前位置 **100 公尺** 以內。
2.  **時段匹配**：檢查該紀錄是否屬於當前的 **MealTime**（例如：目前是中午，則只找午餐紀錄）。
3.  **有效性檢查**：確認資料是否在有效期內（建議 1~3 天，因為營業狀態或評分可能變動）。
4.  **讀取/調用**：
    *   **命中 (Hit)**：從 `CachedPlaces` 抓取數據，不發送 API 請求。成本 = **$0**。
    *   **未命中 (Miss)**：發送 Google API 請求，並將結果存入資料庫。成本 = **$0.047**。

---

## 📈 預期效益
- **成本優化**：對於習慣在固定地點（辦公室、家裡）使用 App 的用戶，API 調用次數可減少 **70% 以上**。
- **離線支持**：用戶在網路不穩時，依然能查看之前的搜尋紀錄。
- **AI 穩定性**：可以將 Gemini 生成的評論也一併快取，避免重複生成相同的推薦語，節省 AI Token。

---

## 🚀 實作建議
1.  **套件選擇**：使用 Flutter 官方推薦的 `sqflite` 處理本地 SQL 資料庫。
2.  **異步處理**：快取讀寫應在後台線程進行，不影響 UI 流暢度。
3.  **自動清理**：App 啟動時自動刪除 7 天以上的過期紀錄，保持資料庫輕量。
