# live-preview.nvim

Neovimのプラグインで、[Markdown](https://ja.wikipedia.org/wiki/Markdown)、[HTML](https://ja.wikipedia.org/wiki/HTML)（CSS、JSを含む）、及び[AsciiDoc](https://asciidoc.org/)ファイルの結果をブラウザでライブプレビューでき、ファイルに変更を加える度にブラウザを再読み込みする必要がありません。バックエンドは完全にLuaとNeovimの組み込み関数で書かれている為ですので、外部の依存関係やNodeJS、Pythonのようなランタイムは必要ありません。

## 機能
Markdown、HTML（CSS、JSを含む）、及びAsciiDocファイルのサポート

Markdown及びAsciiDocファイル内の数式を表示するためのKatexサポート

Markdownファイル内の図表を表示するためのMermaidサポート

Markdown及びAsciiDocファイル内のコードシンタックスハイライト

Neovim内でMarkdownファイルをスクロールした際に、ウェブページも自動的にスクロール ([設定](#設定)で`sync_scroll`を有効にする必要があります)

### 更新

[RELEASE.md](RELEASE.md)を参照してください。

**⚠️ 注意:** 更新後、プラグインが正しく動作するためにブラウザのキャッシュをクリアすることをお勧めします。

## デモ動画

https://github.com/user-attachments/assets/e9a64709-8758-44d8-9e3c-9c15e0bf2a0e

## 必要条件

- Neovim >=0.10.0
  （推奨: >= 0.10.2）
- Webブラウザ

## インストール

プラグインマネージャーを使用してインストールできます。いくつかの例を以下に示します。

<details>
<summary>lazy.nvimを使用</summary>

```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        dependencies = {'brianhuster/autosave.nvim'}, -- 任意ですが、ファイルを自動保存するために推奨
        opts = {},
    }
})
```

</details>

<details>
<summary>mini.depsを使用</summary>

```lua
MiniDeps.add({
    source = 'brianhuster/live-preview.nvim',
    depends = { 'brianhuster/autosave.nvim' }, -- 任意ですが、自動保存を推奨
})
require('livepreview').setup()
```

</details>

<details>
<summary>vim-plugを使用</summary>

```vim
Plug 'brianhuster/live-preview.nvim'
Plug 'brianhuster/autosave.nvim' " 任意ですが、自動保存を推奨

let g:livepreview_config = {} " オプション設定
lua require('livepreview').setup(vim.g.livepreview_config) " プラグインを有効にするために必要
```

</details>

<details>
<summary>手動インストール（プラグインマネージャーを使用しない場合）</summary>

- **Linux、MacOS、Unix系**

```sh
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim ~/.config/nvim/pack/brianhuster/start/live-preview.nvim
```

- **Windows (Powershell)**

```powershell
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim "$HOME/AppData/Local/nvim/pack/brianhuster/start/live-preview.nvim"
```

Neovimの設定ファイルに`require('livepreview').setup()`（Lua）または`lua require('livepreview').setup()`（Vimscript）を追加して、プラグインを有効にする必要があります。
</details>

## 設定

このプラグインは、`opts`変数（lazy.nvimを使用している場合）や`require('livepreview').setup()`関数を使用してカスタマイズできます。以下はデフォルト設定です。

### Luaでの設定

```lua
{
    commands = {
        start = 'LivePreview', -- ライブプレビューサーバーを開始するコマンド。
        stop = 'StopPreview', -- ライブプレビューサーバーを停止するコマンド。
    },
    port = 5500, -- ライブプレビューサーバーのポート
    browser = 'default', -- ブラウザを開くためのコマンド（例：'firefox', 'flatpak run com.vivaldi.Vivaldi'。'default'はシステムのデフォルトブラウザ）。
    dynamic_root = false, -- trueにすると、プレビューされているファイルの親ディレクトリがサーバーのルートになります。falseの場合、現在の作業ディレクトリからサーバーを起動します（現在の作業ディレクトリは`:pwd`で確認できます）。
    sync_scroll = false, -- trueにすると、Markdownファイルをスクロールすると、ウェブページも自動的にスクロールします。
}
```

### Vimscriptでの設定

```vim
let g:livepreview_config = {
    \ 'commands': {
    \     'start': 'LivePreview', " ライブプレビューサーバーを開始するコマンド。
    \     'stop': 'StopPreview', " ライブプレビューサーバーを停止するコマンド。
    \ },
    \ 'port': 5500, " ライブプレビューサーバーのポート
    \ 'browser': 'default', " ブラウザを開くためのコマンド（例：'firefox', 'flatpak run com.vivaldi.Vivaldi'。'default'はシステムのデフォルトブラウザ）。
    \ 'dynamic_root': v:false, " v:trueにすると、プレビューされているファイルの親ディレクトリがサーバーのルートになります。v:falseの場合、現在の作業ディレクトリからサーバーを起動します（現在の作業ディレクトリは`:pwd`で確認できます）。
    \ 'sync_scroll': v:false " v:trueにすると、Markdownファイルをスクロールすると、ウェブページも自動的にスクロールします。
\ }
```

**⚠️ 注意:** `lua require('livepreview').setup()`を呼び出す前に、`g:livepreview_config`を設定してください。

## 使い方

> 以下の手順はデフォルト設定に基づいています。

ライブプレビューサーバーを起動するには、以下のコマンドを実行します。

`:LivePreview`

このコマンドは、現在のMarkdownまたはHTMLファイルをブラウザで`http://localhost:5500/ファイル名`のアドレスで開き、ファイルを編集するたびに自動的に更新します。

ライブプレビューサーバーを停止するには、以下のコマンドを実行します。

`:StopPreview`

英語での詳細は、`:help livepreview`を実行してください。

## コントリビュート

このプロジェクトはまだ新しいため、改善点が多くあります。このプロジェクトに貢献したい場合は、issueまたはpull requestを作成してください。

## 目標

- [x] Katexによる数式サポート
- [x] MermaidによるMarkdownファイル内の図表サポート
- [x] Markdown及びAsciiDocファイル内のコードシンタックスハイライト
- [x] MarkdownファイルをNeovim内でスクロールした際に、ウェブページも自動的にスクロール
- [ ] AsciiDocファイル内の図表サポート
- [ ] AsciiDocファイルをNeovim内でスクロールした際に、ウェブページも自動的にスクロール

## 非目標

以下は、live-preview.nvimで計画に含まれていない機能ですが、プルリクエストは大歓迎です。

- CSS及びJSファイルの設定への追加

## 感謝

* アイデアを提供してくれた [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) と [Live Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server)
* sha1関数を提供してくれた [glacambre/firenvim](https://github.com/glacambre/firenvim)
* Markdownファイル用のCSSを提供してくれた [sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css)
* MarkdownからHTMLへの変換を行う [markdown-it/markdown-it](https://github.com/markdown-it/markdown-it)
* AsciiDocからHTMLへの変換を行う [asciidoctor/asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js)
* 数式を表示するための [KaTeX](https://github.com/KaTeX/KaTeX)
* 図表を表示するための [mermaid-js/mermaid](https://github.com/mermaid-js/mermaid)
* [digitalmoksha/markdown-it-inject-linenumbers](https://github.com/digitalmoksha/markdown-it-inject-linenumbers) : HTML出力に行番号を挿入するためのmarkdown-itプラグイン

### サポート

<a href="https://me.momo.vn/brianphambinhan">
    <img src="https://github.com/user-attachments/assets/3907d317-b62f-43f5-a231-3ec7eb4eaa1b" alt="Momo (Vietnam)" style="height: 85px;">
</a>
<a href="https://img.vietqr.io/image/mb-9704229209586831984-print.png?addInfo=Donate%20for%20livepreview%20plugin%20nvim&accountName=PHAM%20BINH%20AN">
    <img src="https://github.com/user-attachments/assets/f28049dc-ce7c-4975-a85e-be36612fd061" alt="VietQR" style="height: 85px;">
</a>
<a href="https://paypal.me/brianphambinhan">
    <img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_111x69.jpg" alt="Paypal" style="height: 69px;">
</a>

