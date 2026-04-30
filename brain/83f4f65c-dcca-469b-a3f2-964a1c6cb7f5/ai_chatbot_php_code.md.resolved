# Crypto Shift AI アシスタント動作用 PHPコード

以下のプログラムを、前回のプッシュ通知の時と同じように、WordPressの「Code Snippets」プラグイン等で新規追加し、有効化してください。

> [!WARNING]
> **【必ず書き換えてください！】**
> プログラム内の12行目にある `sk-xxxxxxxxxxxxxxxxxxx` の部分を、先ほど取得した**ご自身の本当のOpenAI APIキー**に書き換えてから保存してください。

```php
<?php
// ==========================================
// Crypto Shift AIチャットボット用 APIエンドポイント
// ==========================================

// 1. APIキーの設定（ここに先ほど取得したAPIキーを貼り付けてください）
define('OPENAI_API_KEY_CRYPTOSHIFT', 'sk-xxxxxxxxxxxxxxxxxxx');

// 2. カスタムREST APIの登録
add_action('rest_api_init', function () {
    register_rest_route('cryptoshift/v1', '/chat', [
        'methods' => 'POST',
        'callback' => 'cryptoshift_ai_chat_handler',
        'permission_callback' => '__return_true', // 誰でもアクセス可能（アプリからの通信用）
    ]);
});

// 3. チャット要求を処理する関数
function cryptoshift_ai_chat_handler($request) {
    $params = $request->get_json_params();
    $messages = isset($params['messages']) ? $params['messages'] : [];

    if (empty($messages)) {
        return new WP_Error('no_message', 'メッセージがありません', ['status' => 400]);
    }

    // ユーザーの最新の質問を取り出す
    $latest_user_message = end($messages)['content'];

    // 4. キーワードを抽出して過去記事を検索（簡易RAGシステム）
    // （本来は高度な形態素解析を行いますが、ここでは簡易的にそのまま検索キーワードとして使います）
    $args = [
        'post_type' => 'post',
        'post_status' => 'publish',
        'posts_per_page' => 3, // 最新の関連3記事を取得
        's' => $latest_user_message // 質問文からキーワード検索
    ];
    
    $query = new WP_Query($args);
    $context_text = "";
    
    if ($query->have_posts()) {
        $context_text .= "\n\n【参考記事データベース】\n";
        while ($query->have_posts()) {
            $query->the_post();
            $title = get_the_title();
            $url = get_permalink();
            // 記事本文からHTMLタグを除去し、冒頭300文字だけを切り出す
            $content = wp_strip_all_tags(get_the_content());
            $content = mb_substr($content, 0, 300) . '...';
            
            $context_text .= "・タイトル: {$title}\n";
            $context_text .= "・URL: {$url}\n";
            $context_text .= "・内容: {$content}\n\n";
        }
        wp_reset_postdata();
    } else {
        $context_text .= "\n\n※この質問に直接関連する過去記事は見つかりませんでした。\n";
    }

    // 5. OpenAI APIへの送信データ（プロンプト）の作成
    $system_prompt = "あなたは「Crypto Shift」というメディア専属の優秀な金融アナリストです。
以下のルールを絶対厳守してユーザーの質問に回答してください。

【ルール】
1. トーン＆マナー: 淡々と事実を述べる客観的・論理的な口調。絵文字は極力使わない。
2. 投資助言の禁止: 「〇〇を買うべき」「〇〇は儲かる」という断定的な助言は絶対にしない。もし聞かれたら「私は投資助言を行うことはできません。ご自身の判断でお願いします」と返答する。
3. 出典の明記: 以下の【参考記事データベース】の情報を使って回答した場合は、必ず文末にその記事のURLを記載する。
4. 解説の補完: 参考記事に載っていない専門用語（ETFやブロックチェーンなど）を聞かれた場合は、あなたの持つ金融知識を使って分かりやすく解説する。

" . $context_text;

    // OpenAIに渡すメッセージ配列を構築
    $openai_messages = [
        ["role" => "system", "content" => $system_prompt]
    ];
    
    // アプリから送られてきたチャット履歴を追加（最大直近5件程度に絞る）
    $recent_messages = array_slice($messages, -5);
    foreach ($recent_messages as $msg) {
        $openai_messages[] = [
            "role" => $msg['role'],
            "content" => $msg['content']
        ];
    }

    // 6. OpenAI API (gpt-4o-mini) へのリクエスト
    $api_url = 'https://api.openai.com/v1/chat/completions';
    $api_key = OPENAI_API_KEY_CRYPTOSHIFT;
    
    $body = [
        'model' => 'gpt-4o-mini',
        'messages' => $openai_messages,
        'temperature' => 0.5, // 少し固めの回答にするため低めに設定
        'max_tokens' => 800
    ];

    $response = wp_remote_post($api_url, [
        'headers' => [
            'Content-Type'  => 'application/json',
            'Authorization' => 'Bearer ' . $api_key,
        ],
        'body'    => json_encode($body),
        'timeout' => 30 // APIの返答待ち時間を長めに設定
    ]);

    if (is_wp_error($response)) {
        return new WP_Error('openai_error', 'AIとの通信に失敗しました', ['status' => 500]);
    }

    $response_body = wp_remote_retrieve_body($response);
    $data = json_decode($response_body, true);

    if (isset($data['error'])) {
        return new WP_Error('openai_api_error', $data['error']['message'], ['status' => 500]);
    }

    $ai_reply = $data['choices'][0]['message']['content'];

    // 7. アプリへ返却
    return rest_ensure_response([
        'reply' => $ai_reply
    ]);
}
```
