# 🤖開發規則

> **適用於所有項目的通用開發規則**
> 
> 這是我與 AI 助手（Rovo Dev/Antigravity）協作時遵循的核心規則。
> 無論開發什麼類型的項目，都應該遵循這些原則。

---
這是一個ios的app

#基本規則
    Mac下開發
    使用Flutter開發
    所有頁面的dart都獨立,每個dart獨立不會共用
    儘量每個功能或按鈕的dart也獨立
    我會自己在xcode裡面運行，不要自己執行run指令
    

#debug
    所有頁面都會加console log,方便debug


## 🎯 核心協作原則

### 1. 理解優先，代碼其次
- ✅ **永遠先理解問題本質**，再開始寫代碼
- ✅ 如果不確定需求，**必須先詢問**，不要猜測
- ✅ 複雜問題先**畫流程圖**或**寫偽代碼**
- ❌ 不要急於動手，避免返工

### 2. 通用解決方案
- ✅ 寫**可擴展**、**可維護**的代碼
- ✅ 考慮**邊界情況**和**錯誤處理**
- ✅ 遵循 **DRY 原則**（Don't Repeat Yourself）
- ❌ 不要硬編碼，不要寫一次性代碼

### 3. 增量開發
- ✅ 把大任務**拆分成小步驟**
- ✅ 每個步驟都要**可測試**
- ✅ 及時**反饋進度**和**遇到的問題**
- ❌ 不要一次性完成所有功能

### 4. 代碼質量
- ✅ 代碼要**清晰易讀**，勝過聰明技巧
- ✅ 保持函數簡短（**<50 行**）
- ✅ 使用**有意義的命名**
- ✅ 添加**必要的註釋**（解釋"為什麼"）

---

## 📝 溝通規範

### 提問格式
**問題描述**：我想實現什麼功能

**當前狀況**：現在的情況是什麼

**遇到的問題**：具體錯誤或困惑

**嘗試過的方法**：我已經試過什麼

**期望結果**：我希望達到什麼效果

### 回答格式（AI）
**問題分析**：問題的根本原因

**解決方案**：推薦的解決方法（可能有多個選項）

**實施步驟**：具體的操作步驟

**注意事項**：需要注意的地方

**預期結果**：修復後的效果

### 確認機制
- ✅ 在**執行重要操作前**（刪除、重構等），AI 必須詢問確認
- ✅ 在**多個解決方案**時，AI 應列出選項讓用戶選擇
- ✅ 完成任務後，AI 應**詢問下一步**

---

## 🔧 代碼規範

### 命名規範

**文件命名**：
- 使用項目慣例（snake_case 或 kebab-case）
- 測試文件：test_*.ext 或 *.test.ext

**變量命名**：
- JavaScript/TypeScript/Dart：camelCase
- Python：snake_case
- 常量：UPPER_SNAKE_CASE 或 camelCase（根據語言）

**類命名**：
- 所有語言統一：PascalCase

**函數命名**：
- 動詞開頭：getUserData(), calculateTotal(), isValid()
- 布爾值：is*, has*, should*


### 註釋規範

**必須註釋的地方**：
```javascript
// ✅ 解釋「為什麼」這樣做
// 延遲 500ms 確保動畫完成
await sleep(500);

// ✅ 複雜的業務邏輯
// 根據會員等級計算折扣：VIP 9折，普通會員 95折
const discount = user.isVIP ? 0.9 : 0.95;

// ✅ 臨時的變通方案
// TODO: 等 API v2 發布後改用新的端點
// FIXME: 這個方法在 IE11 中有問題
// HACK: 暫時用這個方法繞過 CORS 錯誤
```

**不需要註釋的地方**：
```javascript
// ❌ 說明顯而易見的事情
// 設置用戶名為 John
const userName = 'John';

// ❌ 復述代碼內容
// 循環遍歷數組
array.forEach(item => { ... });
```

### 錯誤處理

**必須處理錯誤的場景**：
```javascript
// ✅ 網絡請求
try {
  const data = await fetch(url);
  return data;
} catch (error) {
  console.error('❌ 請求失敗:', error);
  showError('無法載入數據，請稍後再試');
  return null;
}

// ✅ 文件操作
try {
  const content = await readFile(path);
  return content;
} catch (error) {
  if (error.code === 'ENOENT') {
    console.warn('⚠️ 文件不存在:', path);
    return createDefaultFile(path);
  }
  throw error;
}

// ✅ 用戶輸入
if (!email || !email.includes('@')) {
  throw new Error('請輸入有效的電子郵件地址');
}
```

---

## 🧪 測試原則

### 測試覆蓋
- ✅ 核心業務邏輯必須有測試
- ✅ 公開 API 必須有測試
- ✅ 修復 bug 時添加回歸測試
- ⚠️ UI 組件可選測試（手動測試為主）

### 測試命名
```javascript
// ✅ 清晰的測試描述
test('calculateDiscount 應該在用戶是 VIP 時返回 10% 折扣', () => {
  expect(calculateDiscount({ isVIP: true, total: 100 })).toBe(90);
});

// ✅ 測試邊界情況
test('calculateDiscount 應該處理 0 金額', () => {
  expect(calculateDiscount({ isVIP: true, total: 0 })).toBe(0);
});
```

---

## 📦 項目結構

### 通用目錄結構
```
project/
├── src/              # 源代碼
│   ├── core/         # 核心功能
│   ├── features/     # 功能模組
│   ├── shared/       # 共享組件
│   └── utils/        # 工具函數
├── tests/            # 測試文件
├── docs/             # 文檔
├── config/           # 配置文件
└── README.md         # 項目說明
```

### 文件組織原則
- ✅ **按功能分組**，不是按類型
- ✅ **相關文件放在一起**
- ✅ **避免深層嵌套**（<5 層）

---

## 🔒 安全規範

### 敏感信息
- ✅ 使用**環境變量**存儲 API Key、密碼
- ✅ 添加 .gitignore 忽略敏感文件
- ❌ 不要在代碼中硬編碼密碼、Token

### 用戶輸入
- ✅ **永遠驗證**用戶輸入
- ✅ 防止 **SQL 注入**、**XSS 攻擊**
- ✅ 使用參數化查詢或 ORM

### 權限控制
- ✅ 實施**最小權限原則**
- ✅ 驗證用戶**身份和權限**
- ✅ 記錄**敏感操作日誌**

---

## 🚀 性能優化

### 優化原則
1. **先測量，再優化**（不要過早優化）
2. **優化瓶頸**，不是所有代碼
3. **保持代碼可讀性**

### 常見優化
```javascript
// ✅ 緩存重複計算
const expensiveResult = useMemo(() => {
  return heavyCalculation(data);
}, [data]);

// ✅ 延遲加載
const HeavyComponent = lazy(() => import('./HeavyComponent'));

// ✅ 分頁加載大數據
const items = await fetchItems({ page: 1, limit: 20 });

// ✅ 防抖/節流高頻事件
const debouncedSearch = debounce(search, 300);
```

---

## 🐛 調試技巧

### 日誌規範
```javascript
// ✅ 使用表情符號前綴
console.log('🚀 應用啟動');
console.log('✅ 數據載入成功');
console.error('❌ 錯誤:', error);
console.warn('⚠️ 警告:', warning);
console.info('ℹ️ 信息:', info);
console.debug('🔧 調試:', data);
```

### 調試步驟
1. **重現問題**：確保能穩定重現
2. **隔離問題**：縮小問題範圍
3. **檢查日誌**：查看錯誤訊息和堆疊
4. **添加斷點**：逐步執行代碼
5. **驗證假設**：測試你的推測
6. **記錄解決方案**：避免重複遇到

---

## 📚 文檔規範

### README.md 必須包含
```markdown
# 項目名稱

簡短描述項目用途
要寫這個app在做什麼，
## 快速開始

安裝和運行步驟

## 功能特性

核心功能列表

## 技術棧

使用的主要技術

## 項目結構

目錄說明
哪一個代碼是做什麼用的
## 開發指南

如何參與開發

## 授權

開源協議（如果適用）
```

### 代碼文檔
```javascript
/**
 * 計算用戶折扣
 * 
 * @param {Object} user - 用戶對象
 * @param {boolean} user.isVIP - 是否為 VIP
 * @param {number} total - 總金額
 * @returns {number} 折扣後的金額
 * 
 * @example
 * const finalPrice = calculateDiscount({ isVIP: true }, 100);
 * // 返回 90
 */
function calculateDiscount(user, total) {
  return user.isVIP ? total * 0.9 : total * 0.95;
}
```

---

## 🔄 Git 工作流程

### Commit 規範
```bash
# 格式：<type>: <subject>

# Type 類型：
feat:     新功能
fix:      修復 bug
docs:     文檔更新
style:    格式調整（不影響代碼運行）
refactor: 重構（不是新功能也不是修復）
perf:     性能優化
test:     添加測試
chore:    構建工具或輔助工具的變動

# 範例：
git commit -m "feat: 添加用戶登入功能"
git commit -m "fix: 修復圖片上傳時的內存洩漏"
git commit -m "docs: 更新 API 文檔"
```

### 分支策略
```
main/master   # 生產環境，隨時可部署
develop       # 開發環境，功能整合
feature/*     # 功能分支
bugfix/*      # Bug 修復
hotfix/*      # 緊急修復
release/*     # 發布準備
```

---

## 🤝 AI 協作最佳實踐

### 有效利用 AI
```markdown
✅ 用 AI 生成樣板代碼
✅ 用 AI 解釋複雜代碼
✅ 用 AI 重構代碼
✅ 用 AI 寫測試用例
✅ 用 AI 寫文檔

⚠️ 核心業務邏輯需要人工審查
⚠️ 安全相關代碼需要仔細檢查
⚠️ 性能關鍵代碼需要測試驗證
```

### AI 輸出的檢查清單
- [ ] 代碼邏輯正確
- [ ] 沒有安全漏洞
- [ ] 錯誤處理完善
- [ ] 符合項目規範
- [ ] 性能可接受
- [ ] 可讀性良好

### 迭代協作
```markdown
1. 描述需求
2. AI 提供方案
3. 選擇方案並實施
4. 測試驗證
5. 反饋問題或優化
6. 重複 2-5 直到滿意
```

---

## ✅ 開發檢查清單

### 功能開發完成前
- [ ] 功能正常工作
- [ ] 錯誤處理完善
- [ ] 邊界情況已測試
- [ ] 代碼已審查
- [ ] 文檔已更新
- [ ] 性能可接受
- [ ] 無安全漏洞
- [ ] 符合設計規範

### 提交代碼前
- [ ] 本地測試通過
- [ ] 沒有 console.log（或已清理）
- [ ] 沒有註釋掉的代碼
- [ ] 代碼格式化完成
- [ ] Commit 訊息清晰
- [ ] 分支名稱正確

### 發布前
- [ ] 所有功能測試通過
- [ ] 性能測試通過
- [ ] 安全審查完成
- [ ] 文檔已更新
- [ ] 版本號已更新
- [ ] 變更日誌已更新

---

## 🎯 持續改進

### 學習與成長
- ✅ 每週回顧一次代碼
- ✅ 記錄遇到的問題和解決方案
- ✅ 學習新技術和最佳實踐
- ✅ 分享經驗和知識

### 項目優化
- ✅ 定期重構舊代碼
- ✅ 更新過時的依賴
- ✅ 移除未使用的代碼
- ✅ 改進文檔

---

## 💡 核心信念

> **代碼是寫給人看的，順便讓機器執行**

> **簡單的解決方案通常是最好的**

> **過早的優化是萬惡之源**

> **寫代碼容易，寫好代碼難，維護代碼更難**

> **今天的捷徑，是明天的技術債**

---

## 📞 問題處理

### 遇到困難時
1. 🔍 **搜索文檔**和錯誤訊息
2. 🤔 **理解問題本質**
3. 💬 **清楚描述問題**給 AI
4. 🧪 **嘗試建議的解決方案**
5. 📝 **記錄解決過程**

### 多個方案時
1. 列出所有可行方案
2. 比較優缺點
3. 選擇最適合的
4. 記錄選擇原因

---

**這些規則幫助我和 AI 更高效地協作，寫出更好的代碼！** 🚀
