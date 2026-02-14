# Antigravity iOS Development Standards

このドキュメントは、AntigravityがiOSアプリケーションを開発する際に準拠すべき技術標準、アーキテクチャ、およびコーディング規約を定義します。

## 1. 原則 (Core Principles)

* **Modern & Swift Native:** 最新のSwift機能（Swift 6, Concurrency, Macros）を積極的に採用する。
* **Declarative UI:** 命令的記述（UIKit）ではなく、宣言的記述（SwiftUI）を第一選択とする。
* **Unidirectional Data Flow:** データは単一方向に流れ、Stateは「信頼できる唯一の情報源（Single Source of Truth）」として管理する。
* **Testability:** ロジックはViewから分離し、依存性を注入（DI）可能な設計にする。
* **KISS (Keep It Simple, Stupid):** 過剰な抽象化を避け、可読性を最優先する。

## 2. テックスタック (Tech Stack)

* **Language:** Swift 6.0+
* **Minimum Deployment Target:** iOS 17.0+ (プロジェクト要件により調整)
* **UI Framework:** SwiftUI
* **State Management:** Observation Framework (`@Observable`)
* **Asynchronous:** Swift Concurrency (`async/await`, `Actor`, `Task`)
* **Dependency Management:** Swift Package Manager (SPM)
* **Architecture pattern:** MVVM (Model-View-ViewModel) + Repository Pattern

## 3. アーキテクチャ構成 (Architecture)

機能（Feature）単位でのディレクトリ構成を推奨します。

```text
App/
├── App.swift
├── Resources/
│   └── Assets.xcassets
├── Core/               # アプリ全体で共有される基盤
│   ├── DesignSystem/   # 色、フォント、共通UIコンポーネント
│   ├── Network/        # APIクライアント、通信処理
│   ├── Storage/        # DB, UserDefaultsラッパー
│   └── Extensions/     # 標準ライブラリの拡張
├── Features/           # 機能ごとのモジュール
│   ├── Home/
│   │   ├── Views/      # SwiftUI Views
│   │   ├── ViewModels/ # @Observable classes
│   │   └── Models/     # Data structures
│   └── Settings/
└── Repositories/       # データ取得の抽象化レイヤー (Protocol + Implementation)