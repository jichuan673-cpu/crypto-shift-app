# プッシュ通知設定機能の追加

アプリ内でプッシュ通知の受信設定（新着記事、特定カテゴリの選択、配信頻度）をカスタマイズできるようにします。

> [!IMPORTANT]
> **前提条件とバックエンドについて（要確認）**
> アプリ側で「仮想通貨カテゴリのみ通知を受け取る」や「1日1回だけ受け取る」という設定（Firebase Cloud Messagingのトピック購読）を行うことは可能ですが、実際にそのルールに従って通知を**送信**するには、記事が作成された側（WordPressや自動化ツールのMake）からFirebaseへ通知送信のリクエストを送る仕組みが必要です。現状、サーバー側でのプッシュ通知送信の仕組み（WordPressプラグイン等）は構築済みでしょうか？

## Proposed Changes

### 1. 状態管理の拡張 (`lib/providers/app_state.dart`)
- 通知設定のオン・オフ、購読しているカテゴリ、および配信頻度（リアルタイム、1日1回など）を保存する変数を追加します。
- ユーザーの設定変更に応じて `FirebaseMessaging.instance.subscribeToTopic('category_id')` などのトピック購読・解除を行うロジックを実装します。

#### [MODIFY] [app_state.dart](file:///c:/Users/kalus/.gemini/antigravity/lib/providers/app_state.dart)
- `bool _notificationsEnabled`
- `String _notificationFrequency` ('realtime' or 'daily')
- `List<int> _subscribedCategoryIds`
- これらを永続化する処理と、FCMトピックを更新するメソッドを追加。

### 2. 通知設定画面の作成 (`lib/screens/notification_settings_screen.dart`)
- マイページから遷移できる「通知設定」の専用画面を作成します。
- 以下のUIを実装します：
  - **全体通知スイッチ**: すべての通知をオン/オフする。
  - **配信頻度選択**: 「リアルタイム（記事追加時）」「1日1回（ダイジェスト）」の選択（ラジオボタン）。
  - **カテゴリ別設定**: 「すべて」「仮想通貨」「不動産」などのカテゴリ一覧を表示し、個別にオン/オフできるスイッチ。

#### [NEW] [notification_settings_screen.dart](file:///c:/Users/kalus/.gemini/antigravity/lib/screens/notification_settings_screen.dart)

### 3. マイページへのリンク追加 (`lib/screens/my_page_screen.dart`)
- 右上の設定メニュー（またはリスト）に「通知設定」の項目を追加し、上記画面へ遷移できるようにします。

#### [MODIFY] [my_page_screen.dart](file:///c:/Users/kalus/.gemini/antigravity/lib/screens/my_page_screen.dart)

## Open Questions

1. **プッシュ通知の送信元**: WordPress側で新着記事が公開された際、どのようにFirebaseに通知をプッシュする想定でしょうか？（例：WordPressのプラグインを使用する、Makeを使ってWebhookでFirebase Admin APIを叩くなど）。アプリ側は指定された「トピック」を購読する受け皿として作ります！
2. **配信頻度について**: 「1日1回」という設定にした場合、1日分の記事をまとめて夜に通知するような処理は、送信側（Makeなどの自動化ツール）で制御していただく形になりますが問題ないでしょうか？（アプリ側は `digest_daily` のようなトピックを購読する形になります）

上記の方針でよろしければ、アプリ側の通知設定UIとロジックの実装を進めます！
