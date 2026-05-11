# JustFeedMe (Forkit Mobile) 應用程式概覽

**JustFeedMe** 是一款專為「解決選擇困難」設計的餐廳雷達 App。它結合了實時地理定位、Google 餐廳數據，以及 Gemini AI 的個性化評論。

---

## 🎯 核心功能
1.  **隨機推薦 (Random Picker)**:
    *   **拉霸動畫**: 點擊後會啟動餐廳名稱與照片的快速轉動效果。
    *   **AI 評論**: 使用 **Gemini 2.5 Flash Lite** 生成建議。
    *   **情緒機制**: 如果您覺得不滿意點擊「再轉一次」，超過 3 次後 AI 會進入「毒舌模式」，強烈命令你去吃。
2.  **列表搜尋 (List Search)**:
    *   獲取目前位置周圍的真實餐廳列表。
    *   顯示詳細資訊：距離、評分、評論數、預算。
    *   一鍵導航：直接串接 Google Maps 進行導航。
3.  **智能篩選**:
    *   **用餐時段**: 自動判斷目前是 早餐/午餐/下午茶/晚餐/宵夜，並智能過濾 Google 的搜尋類別。
    *   **條件過濾**: 支持預算 ($~$$$)、評分 (3.5+)、距離 (500m~10km) 及是否營業中。
4.  **持久化黑名單**:
    *   您可以將不喜歡或踩過雷的餐廳加入黑名單。
    *   **永久排除**: 透過 `shared_preferences` 存儲，重啟 App 後，該餐廳在任何搜尋結果中都將永久消失。

---

## 🛠 技術架構
*   **前端框架**: Flutter (iOS 優先)
*   **數據來源 (Google Places API New)**:
    *   `PlaceService`: 處理實時搜尋、距離計算與照片抓取。
*   **AI 引擎 (Google Gemini API)**:
    *   `AiService`: 負責 prompt 管理與生成的推薦語。
*   **本地存儲**:
    *   `StorageService`: 負責黑名單的讀取與存入。
*   **UI 庫**: `Lucide Icons` (圖標), `flutter_animate` (動畫).

---

## 📂 檔案結構概覽
*   `lib/`
    *   `main.dart`: 程式入口。
    *   `home_screen.dart`: 主畫面（雷達入口）。
    *   `random_picker.dart`: 隨機拉霸與 AI 顯示邏輯。
    *   `results_screen.dart`: 餐廳結果列表顯示。
    *   `restaurant_card.dart`: 統一的餐廳資訊組件。
    *   `services/`
        *   `place_service.dart`: Google Maps API 整合。
        *   `ai_service.dart`: Gemini API 整合。
        *   `storage_service.dart`: 本地黑名單管理。

---

## ✅ 目前狀態
App 已經從模擬數據完全轉換為**實時動態數據**，基礎功能均已開發完成並通過驗證。您可以直接開啟 Xcode 進行編譯與測試。
