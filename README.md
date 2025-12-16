[English](#english) | [Русский](#русский) | [日本語](#日本語)

## English

# Kanjificator

## Project Description

Kanjificator is a web service for recognizing Japanese kanji characters based on handwritten input. The project consists of two main components:

1. **Server part** (`server.py`) - REST API based on Flask that accepts handwritten stroke data and returns a list of recognized character candidates with confidence scores.
2. **Client part** (`client.py`) - GUI application based on Tkinter for drawing kanji and interacting with the server.

The service uses the Zinnia library for recognition, which is a high-precision engine for Japanese kanji recognition. The recognition model is based on Tegaki project data.

## Architecture

The project is built using Docker containerization to ensure portability and simplify deployment. The server runs on port 5200 and provides a single endpoint `/recognize` for processing requests.

### Input Data Format

The server accepts JSON objects with the following structure:

```json
{
  "width": 300,
  "height": 300,
  "strokes": [
    [[x1, y1], [x2, y2], ...],
    [[x3, y3], [x4, y4], ...]
  ]
}
```

Where:
- `width` and `height` - canvas dimensions in pixels
- `strokes` - array of strokes, each stroke is an array of [x, y] points

### Output Data Format

The server returns an array of candidate objects:

```json
[
  {
    "value": "漢",
    "score": 0.987
  },
  {
    "value": "字",
    "score": 0.654
  }
]
```

Where:
- `value` - recognized kanji character
- `score` - recognition confidence score (0 to 1)

## Installation and Launch

### System Requirements

- Docker
- Docker Compose (optional)

### Launch with Docker

1. Clone the repository:
```bash
git clone https://github.com/3ShishkaN3/kanjificator.git
cd kanjificator
```

2. Build and run the container:
```bash
docker build -t kanjipad .
docker run -p 5200:5200 kanjipad
```

The server will be available at `http://localhost:5200`.

### Local Launch (for development)

Local launch requires installing the Zinnia library, which can be a complex process. Docker is recommended for deployment.

If local environment is necessary:

1. Install Python 3.9+
2. Install system dependencies for Zinnia (see Dockerfile)
3. Install Python dependencies:
```bash
pip install flask requests
```

4. Download the recognition model from Tegaki project
5. Launch the server:
```bash
python server.py
```

## Usage

### Web API

Send a POST request to `/recognize` with JSON stroke data:

```python
import requests

payload = {
    "width": 300,
    "height": 300,
    "strokes": [
        [[50, 50], [100, 100], [150, 50]],
        [[200, 100], [250, 150]]
    ]
}

response = requests.post("http://localhost:5200/recognize", json=payload)
candidates = response.json()
```

### GUI Client

Launch the client application:

```bash
python client.py
```

The interface consists of:
- Drawing canvas (300x300 pixels)
- "Clear" button to clear the canvas
- List of recognition results

Draw a kanji on the canvas, and results will appear in the list. Select a candidate to display an example of the character.

## Technical Details

### Recognition Model

Uses the `handwriting-ja.model` from Tegaki Zinnia Japanese project. The model is trained on a large set of handwritten Japanese kanji and provides high recognition accuracy.

### Working Algorithm

1. Client collects stroke point coordinates during drawing
2. Data is sent to server in JSON format
3. Server converts data to Zinnia Character object
4. Classification is performed returning top-10 candidates
5. Results are returned to client with confidence scores

### Limitations

- Maximum number of returned candidates: 10
- Support only for Japanese kanji characters
- Canvas size fixed in client (300x300)
- Server does not maintain state between requests

## Dependencies

### Python Dependencies
- Flask - web framework for API
- requests - HTTP client for API interaction

### System Dependencies
- Zinnia - kanji recognition library
- Tegaki Zinnia Japanese - recognition model

All dependencies are installed automatically in the Docker container.

## Development

### Project Structure
```
kanjipad/
├── server.py          # Flask server with API
├── client.py          # Tkinter client
├── Dockerfile         # Docker configuration
├── requirements.txt   # Python dependencies (empty, used in Dockerfile)
├── LICENSE            # Apache 2.0 License
└── NOTICE             # Copyright information
```

### Adding New Features

To extend functionality:
1. Modify `server.py` for new endpoints
2. Update `client.py` for new interface elements
3. Rebuild Docker image after changes

## License

The project is distributed under Apache License 2.0.

## Authors and Acknowledgments

**Author:** Reznik Danil Maksimovich (aka "Shishka")

**Repositories:**
- GitHub: https://github.com/3ShishkaN3/kanjificator
- GitVerse: https://gitverse.ru/shish/kanjificator

**Acknowledgments:**
- Taku Kudo - author of Zinnia library
- Tegaki project - for recognition model
- Mathieu Blondel and Ian Johnson - Tegaki Zinnia Japanese contributors

## Contacts

For questions and suggestions, contact the author through the project repositories.

## Русский

# Zinnia-Docker-API

## Описание проекта

Kanjificator представляет собой веб-сервис для распознавания японских иероглифов (канзи) на основе рукописного ввода. Проект состоит из двух основных компонентов:

1. **Серверная часть** (`server.py`) - REST API на базе Flask, который принимает данные о рукописных штрихах и возвращает список кандидатов распознанных символов с оценками уверенности.
2. **Клиентская часть** (`client.py`) - графическое приложение на базе Tkinter для рисования иероглифов и взаимодействия с сервером.

Сервис использует библиотеку Zinnia для распознавания, которая является высокоточным движком для распознавания японских иероглифов. Модель распознавания основана на данных проекта Tegaki.

## Архитектура

Проект построен с использованием контейнеризации Docker для обеспечения переносимости и упрощения развертывания. Сервер работает на порту 5200 и предоставляет единственный endpoint `/recognize` для обработки запросов.

### Формат входных данных

Сервер принимает JSON-объекты со следующей структурой:

```json
{
  "width": 300,
  "height": 300,
  "strokes": [
    [[x1, y1], [x2, y2], ...],
    [[x3, y3], [x4, y4], ...]
  ]
}
```

Где:
- `width` и `height` - размеры холста в пикселях
- `strokes` - массив штрихов, каждый штрих представляет собой массив точек [x, y]

### Формат выходных данных

Сервер возвращает массив объектов кандидатов:

```json
[
  {
    "value": "漢",
    "score": 0.987
  },
  {
    "value": "字",
    "score": 0.654
  }
]
```

Где:
- `value` - распознанный иероглиф
- `score` - оценка уверенности распознавания (от 0 до 1)

## Установка и запуск

### Требования к системе

- Docker
- Docker Compose (опционально)

### Запуск с помощью Docker

1. Клонируйте репозиторий:
```bash
git clone https://github.com/3ShishkaN3/kanjificator.git
cd kanjificator
```

2. Соберите и запустите контейнер:
```bash
docker build -t kanjipad .
docker run -p 5200:5200 kanjipad
```

Сервер будет доступен по адресу `http://localhost:5200`.

### Локальный запуск (для разработки)

Для локального запуска требуется установка библиотеки Zinnia, что может быть сложным процессом. Рекомендуется использовать Docker для развертывания.

Если необходимо локальное окружение:

1. Установите Python 3.9+
2. Установите системные зависимости для Zinnia (см. Dockerfile)
3. Установите Python зависимости:
```bash
pip install flask requests
```

4. Скачайте модель распознавания из проекта Tegaki
5. Запустите сервер:
```bash
python server.py
```

## Использование

### Веб-API

Отправьте POST-запрос на `/recognize` с JSON-данными о штрихах:

```python
import requests

payload = {
    "width": 300,
    "height": 300,
    "strokes": [
        [[50, 50], [100, 100], [150, 50]],
        [[200, 100], [250, 150]]
    ]
}

response = requests.post("http://localhost:5200/recognize", json=payload)
candidates = response.json()
```

### Графический клиент

Запустите клиентское приложение:

```bash
python client.py
```

Интерфейс состоит из:
- Холста для рисования (300x300 пикселей)
- Кнопки "Clear" для очистки холста
- Списка результатов распознавания

Рисуйте иероглиф на холсте, и результаты появятся в списке. Выберите кандидата для отображения примера символа.

## Технические детали

### Модель распознавания

Используется модель `handwriting-ja.model` из проекта Tegaki Zinnia Japanese. Модель обучена на большом наборе рукописных японских иероглифов и обеспечивает высокую точность распознавания.

### Алгоритм работы

1. Клиент собирает координаты точек штрихов во время рисования
2. Данные отправляются на сервер в формате JSON
3. Сервер преобразует данные в объект Zinnia Character
4. Выполняется классификация с возвратом топ-10 кандидатов
5. Результаты возвращаются клиенту с оценками уверенности

### Ограничения

- Максимальное количество возвращаемых кандидатов: 10
- Поддержка только японских иероглифов (канзи)
- Размер холста фиксирован в клиенте (300x300)
- Сервер не сохраняет состояние между запросами

## Зависимости

### Python зависимости
- Flask - веб-фреймворк для API
- requests - HTTP клиент для взаимодействия с API

### Системные зависимости
- Zinnia - библиотека распознавания иероглифов
- Tegaki Zinnia Japanese - модель распознавания

Все зависимости устанавливаются автоматически в Docker контейнере.

## Разработка

### Структура проекта
```
kanjipad/
├── server.py          # Flask сервер с API
├── client.py          # Tkinter клиент
├── Dockerfile         # Конфигурация Docker
├── requirements.txt   # Python зависимости (пустой, используются в Dockerfile)
├── LICENSE            # Лицензия Apache 2.0
└── NOTICE             # Информация об авторских правах
```

### Добавление новых функций

Для расширения функциональности:
1. Модифицируйте `server.py` для новых endpoints
2. Обновите `client.py` для новых элементов интерфейса
3. Пересоберите Docker образ после изменений

## Лицензия

Проект распространяется под лицензией Apache License 2.0.

## Авторы и благодарности

**Автор:** Reznik Danil Maksimovich (aka "Shishka")

**Репозитории:**
- GitHub: https://github.com/3ShishkaN3/kanjificator
- GitVerse: https://gitverse.ru/shish/kanjificator

**Благодарности:**
- Taku Kudo - автор библиотеки Zinnia
- Проект Tegaki - за модель распознавания
- Mathieu Blondel и Ian Johnson - контрибьюторы Tegaki Zinnia Japanese

## Контакты

Для вопросов и предложений обращайтесь к автору через репозитории проекта.

## 日本語

# Kanjificator

## プロジェクトの説明

Kanjificator は、手書き入力に基づく日本語の漢字認識のためのウェブサービスです。プロジェクトは2つの主要なコンポーネントで構成されています：

1. **サーバー部分** (`server.py`) - FlaskベースのREST APIで、手書きストロークデータを入力として受け取り、認識された文字候補のリストを信頼度スコアとともに返します。
2. **クライアント部分** (`client.py`) - 漢字を描画し、サーバーと対話するためのTkinterベースのGUIアプリケーション。

サービスはZinniaライブラリを使用しており、これは日本語漢字認識の高精度エンジンです。認識モデルはTegakiプロジェクトのデータに基づいています。

## アーキテクチャ

プロジェクトは移植性と展開の簡素化を確保するためにDockerコンテナ化を使用して構築されています。サーバーはポート5200で動作し、リクエスト処理のための単一のエンドポイント `/recognize` を提供します。

### 入力データ形式

サーバーは以下の構造のJSONオブジェクトを受け入れます：

```json
{
  "width": 300,
  "height": 300,
  "strokes": [
    [[x1, y1], [x2, y2], ...],
    [[x3, y3], [x4, y4], ...]
  ]
}
```

ここで：
- `width` と `height` - キャンバスのサイズ（ピクセル単位）
- `strokes` - ストロークの配列、各ストロークは [x, y] ポイントの配列

### 出力データ形式

サーバーは候補オブジェクトの配列を返します：

```json
[
  {
    "value": "漢",
    "score": 0.987
  },
  {
    "value": "字",
    "score": 0.654
  }
]
```

ここで：
- `value` - 認識された漢字文字
- `score` - 認識の信頼度スコア（0から1）

## インストールと起動

### システム要件

- Docker
- Docker Compose（オプション）

### Dockerでの起動

1. リポジトリをクローン：
```bash
git clone https://github.com/3ShishkaN3/kanjificator.git
cd kanjificator
```

2. コンテナをビルドして実行：
```bash
docker build -t kanjipad .
docker run -p 5200:5200 kanjipad
```

サーバーは `http://localhost:5200` で利用可能です。

### ローカル起動（開発用）

ローカル起動にはZinniaライブラリのインストールが必要で、これは複雑なプロセスになる可能性があります。展開にはDockerを推奨します。

ローカル環境が必要な場合：

1. Python 3.9+ をインストール
2. Zinniaのシステム依存関係をインストール（Dockerfile参照）
3. Python依存関係をインストール：
```bash
pip install flask requests
```

4. Tegakiプロジェクトから認識モデルをダウンロード
5. サーバーを起動：
```bash
python server.py
```

## 使用方法

### ウェブAPI

`/recognize` にJSONストロークデータでPOSTリクエストを送信：

```python
import requests

payload = {
    "width": 300,
    "height": 300,
    "strokes": [
        [[50, 50], [100, 100], [150, 50]],
        [[200, 100], [250, 150]]
    ]
}

response = requests.post("http://localhost:5200/recognize", json=payload)
candidates = response.json()
```

### GUIクライアント

クライアントアプリケーションを起動：

```bash
python client.py
```

インターフェースは以下の構成：
- 描画キャンバス（300x300ピクセル）
- キャンバスをクリアする "Clear" ボタン
- 認識結果のリスト

キャンバスに漢字を描画すると、結果がリストに表示されます。候補を選択して文字の例を表示します。

## 技術詳細

### 認識モデル

Tegaki Zinnia Japaneseプロジェクトの `handwriting-ja.model` を使用。モデルは多数の手書き日本語漢字でトレーニングされており、高い認識精度を提供します。

### 動作アルゴリズム

1. クライアントは描画中にストロークポイントの座標を収集
2. データはJSON形式でサーバーに送信
3. サーバーはデータをZinnia Characterオブジェクトに変換
4. トップ10候補を返す分類を実行
5. 結果は信頼度スコアとともにクライアントに返される

### 制限事項

- 返される候補の最大数：10
- 日本語漢字のみサポート
- クライアントでキャンバスサイズ固定（300x300）
- サーバーはリクエスト間で状態を維持しない

## 依存関係

### Python依存関係
- Flask - API用のウェブフレームワーク
- requests - API対話用のHTTPクライアント

### システム依存関係
- Zinnia - 漢字認識ライブラリ
- Tegaki Zinnia Japanese - 認識モデル

すべての依存関係はDockerコンテナで自動的にインストールされます。

## 開発

### プロジェクト構造
```
kanjipad/
├── server.py          # Flaskサーバー with API
├── client.py          # Tkinterクライアント
├── Dockerfile         # Docker設定
├── requirements.txt   # Python依存関係（空、Dockerfileで使用）
├── LICENSE            # Apache 2.0ライセンス
└── NOTICE             # 著作権情報
```

### 新機能の追加

機能を拡張するには：
1. 新しいエンドポイントのために `server.py` を変更
2. 新しいインターフェース要素のために `client.py` を更新
3. 変更後にDockerイメージを再ビルド

## ライセンス

プロジェクトはApache License 2.0の下で配布されます。

## 著者と謝辞

**著者：** Reznik Danil Maksimovich (aka "Shishka")

**リポジトリ：**
- GitHub: https://github.com/3ShishkaN3/kanjificator
- GitVerse: https://gitverse.ru/shish/kanjificator

**謝辞：**
- Taku Kudo - Zinniaライブラリの著者
- Tegakiプロジェクト - 認識モデル提供
- Mathieu Blondel と Ian Johnson - Tegaki Zinnia Japanese貢献者

## 連絡先

質問や提案については、プロジェクトリポジトリを通じて著者に連絡してください。