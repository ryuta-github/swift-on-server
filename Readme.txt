# 概要
swiftを用いてapi serverを構築するサンプルアプリ
TODOリストを作成するAPI

# 開発環境
前提として、appleが推奨しているもの。もしくは、appleで実績があるものを最優先とする。

## 提案
ローカル環境は、docker compose を用いて開発を行う
DB : postgresを用いる
フレームワーク：現段階で利用率の高いもの or appleで実績のあるものを提案してください

# 開発内容

## 初回としては、簡単なrestAPIを作成する

```
[get]/hello-swift
```
## 簡易的なCRUDができるAPI

Vapor 4 + Fluent + PostgreSQLを採用しています。VaporはSwiftNIOを基盤とする代表的な
サーバーサイドSwiftフレームワークであり、Fluentの推奨DBドライバーとしてPostgreSQLを
利用します。API契約は `openapi/openapi.yaml` にあります。

### 起動

Docker Desktopを起動して、次を実行します。

```sh
docker compose up --build
```

APIは `http://localhost:8080`、PostgreSQLは `localhost:5432` で起動します。
初回起動時にはFluentのマイグレーションが自動実行されます。

### エンドポイント

| Method | Path | 内容 |
| --- | --- | --- |
| GET | `/hello-swift` | 疎通確認 |
| GET | `/todos` | TODO一覧 |
| POST | `/todos` | TODO作成 |
| GET | `/todos/{todoID}` | TODO詳細 |
| PUT | `/todos/{todoID}` | TODO更新（指定フィールドのみ） |
| DELETE | `/todos/{todoID}` | TODO削除 |

### 動作例

```sh
curl http://localhost:8080/hello-swift

curl -X POST http://localhost:8080/todos \
  -H 'Content-Type: application/json' \
  -d '{"title":"Vaporを試す"}'

curl http://localhost:8080/todos
```

TODOの `title` は1〜200文字です。存在しないIDは `404`、不正な入力は `400` を
返します。

### テスト

テストは外部DBを必要としないインメモリSQLiteを利用します。

```sh
swift test
```
