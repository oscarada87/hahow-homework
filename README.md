# README

線上網址: `https://tanjimeow.com/`

[API SPEC](https://docs.google.com/document/d/1ze1NZU20LHJMWOhXNxR4x4-iWJQuAypRqQx7wwP_CqQ/edit?usp=sharing)

## 執行方式

1. 確保已安裝 Ruby 3.2.2
2. 確保已安裝 PostgreSQL 並啟動服務
3. 執行以下命令以安裝所需的 gem：

```bash
bundle install
```

4. 修改 credential 檔

```bash
EDITOR=vim rails credentials:edit -e environment
```

5. 建立資料庫：

```bash
rails db:create
```

6. 執行資料庫 migrate：

```bash
rails db:migrate
```

7. 執行以下命令以啟動 Rails 伺服器：

```bash
rails server
```

## 專案架構

#### Model

- 負責與資料庫進行互動，定義資料結構

#### Controller

- 負責處理請求和回應，使用相應的 Service 和 form，並針對不同 error 狀況回傳統一的錯誤格式

#### Form

- 負責驗證和處理用戶輸入的資料

#### Service

- 負責處理複雜、有 side effect 的業務邏輯，通常會被 Controller 使用

## 第三方 gem

- faker
  用於生成假資料
- factory_bot_rails
  用於測試資料的建立
- annotaterb
  用於自動生成 model 註解
- brakeman
  用於檢查 Rails 的安全性
- rubocop
  linting 工具，用於確保程式碼風格一致
- debug
  debugging 工具，用於在開發過程中進行除錯
- kamal
  用於部署 Rails
- bootsnap
  用於減少 Rails 啟動時間
- simplecov
  用於測試覆蓋率報告

## 關於註解

- model 上的註解會透過 `annotaterb` gem 自動生成，對應資料庫裡的欄位
- controller 上的註解會對應 api route
- 其他地方盡量不寫註解，利用變數和函數名稱告知意圖，只有在碰到以下這些情況時才會寫註解：
  - 已知的 bug 或重構，無法在當下處理，可能會在未來某個時間點修復
  - 複雜邏輯，可能 1 個月後回來看需要花較多時間理解

## 專案決策

#### 統一回覆介面

所有的 API 回覆都會有 `code`, `message`, `data` 三個欄位

- `code` 是自訂的狀態碼，方便前端處理不同的情況(HTTP 狀態碼的延伸)
- `message` 是錯誤訊息，當錯誤發生時才會提供
- `data` 是回傳的資料，可能是物件或陣列

#### 排序

API 提供欄位 "idx" 讓前端可以控制排序。過往經驗這種類型的 API 通常資料不會太多(資料較多的情況會加上 paging)，不太會影響到前端的效能，又可以讓前端有更大的彈性去控制排序。

#### 單元測試

針對各個元件單一做測試，確保其功能正確性。在 controller 測試中，會 mock 掉 service 和 form 的實作，可以達到加速測試的目的，並且不需要依賴資料庫。

#### 部分更新

在更新資料時，會使用部分更新的方式，這樣可以減少不必要的資料傳輸和處理。資料的新增及刪除則是由不同的 API 處理。

## 當面臨多種實作方式時，我通常會依以下步驟進行決策

1. 預估成本
   我會先針對每種實作方式，評估所需的人力與時間成本，並簡單列表比較。

2. 與相關利害關係人（stakeholders）討論
   接下來，我會與 stakeholder 一同討論其他層面的考量，例如實際用途、專案時程壓力、未來擴充性與維護性等。

3. 整理建議與優缺點
   綜合上述資訊，我會將各方案依建議排序，並清楚列出每個方案的優缺點，協助團隊做出最適合當下情境的決策。

## 遇到的問題

#### 專案架構分層

本次專案的業務邏輯相對單純，大部分需求僅涉及參數驗證，因此目前有些 service 層的設計顯得有些大材小用。針對較為簡單的處理流程，我暫時將相關邏輯直接寫在 controller 內部。
不過，我也有特別留意維護性：如果未來功能逐漸複雜、業務邏輯持續增加，我會適時將這些邏輯從 controller 抽離，重構到 service 層或其他合適的物件，以維持程式碼的清晰與可維護性。

#### 在設定 CI/CD 部署流程時，遇到了一些問題

- Dockerfile 的更新問題
  若在建置時未有新的 git commit，CI/CD pipeline 會持續使用舊的 Dockerfile，導致無法套用 Dockerfile 內的最新修改。

- Rails credential 型別自動轉換問題
  當 credential 檔案中的資料為類似 0206 這樣的格式時，Rails 會自動將其解讀為八進位數字，導致實際讀取時變成 134，而非原本預期的字串 0206。

- Kamal deploy 預設 proxy 行為
  Kamal 部署時會自動啟用內建的 kamal-proxy 作為 reverse proxy。若有需求同時使用如 Nginx 等第三方 proxy 工具，需額外研究相關整合或替代方案，以避免 proxy 設定上的衝突或重疊。

- 移除 thruster 導致部署失敗
  在移除 thruster gem 後，Kamal 的 proxy 無法正確偵測到健康檢查的 route。原因為 kamal proxy 預設檢查 port 80，解決方法為在 Kamal 的設定中明確指定健康檢查的 port，並將 health check 的 route 設定為在沒有 SSL 的情況下也能被存取。
