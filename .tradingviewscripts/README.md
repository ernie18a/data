# tradingviewscripts

下載 Popular 與 Editors' picks 全部分頁的公開說明與 Pine source：

```bash
uv run crawler.py
```

程式沒有 CLI 參數；列表頁與每個 `/script/*` 間隔至少 11 秒。結果為 `OUTPUT/*.md`，完整舊檔會依 `PUB` ID 自動跳過。
