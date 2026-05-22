# JustFeedMe

選擇困難解方 — Flutter 餐廳雷達 App，結合 Google Places 即時資料與 Gemini AI 毒舌推薦，幫你決定吃什麼。

## 功能
- **隨機拉霸**：拉霸動畫隨機推薦附近餐廳；超過 3 次不滿意，AI 進入毒舌模式強迫你去吃
- **列表搜尋**：顯示周圍餐廳清單（距離、評分、評論數、預算）+ 一鍵串接 Google Maps 導航
- **智能篩選**：依用餐時段（早 / 午 / 下午茶 / 晚 / 宵夜）自動過濾；支援預算、評分、距離篩選
- **永久黑名單**：踩過雷的餐廳加入黑名單，重啟 App 後永遠不再出現

## 技術棧
- Flutter（iOS 優先）
- Google Places API New（即時餐廳資料）
- Google Gemini 2.5 Flash Lite（AI 推薦語）
- shared_preferences（黑名單持久化）
