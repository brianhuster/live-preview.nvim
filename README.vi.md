# live-preview.nvim 🚀

[![LuaRocks](https://img.shields.io/luarocks/v/brianhuster/live-preview.nvim?logo=lua&color=purple)](https://luarocks.org/modules/brianhuster/live-preview.nvim)

Một plugin Neovim cho phép bạn xem kết quả tệp [Markdown](https://vi.wikipedia.org/wiki/Markdown), [HTML](https://vi.wikipedia.org/wiki/HTML) (nhúng kèm CSS, JS) và [AsciiDoc](https://asciidoc.org/) trong trình duyệt web với cập nhật trực tiếp, cho phép bạn không cần tải lại trình duyệt mỗi khi có thay đổi trong file. Không như một số plugin tương tự yêu cầu runtime ngoài như Node hoặc Python, plugin này không yêu cầu bất kỳ runtime ngoài nào, ngoại trừ chính Lua được tích hợp sẵn trong Neovim.

## Tính năng ✨
- Hỗ trợ các tệp Markdown, HTML (kèm CSS, JS) và AsciiDoc 📄
- Hỗ trợ Katex để hiển thị các phương trình toán học trong tệp Markdown và AsciiDoc 🧮
- Hỗ trợ mermaid để hiển thị các biểu đồ trong tệp Markdown 🖼️
- Tô sáng cú pháp code trong tệp Markdown và AsciiDoc 🖍️
- Hỗ trợ cuộn trang web khi bạn cuộn trong tệp Markdown trong Neovim. (Bạn cần kích hoạt `sync_scroll` trong [Tùy chỉnh](#tùy-chỉnh). Tính năng này nên được sử dụng cùng với [brianhuster/autosave.nvim](https://github.com/brianhuster/autosave.nvim)) 🔄
- Tích hợp với [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 🔭, [`fzf-lua`](https://github.com/ibhagwan/fzf-lua) and [`mini.pick`](https://github.com/echasnovski/mini.pick) for opening files to preview 📂


### Cập nhật 🆕
Xem [RELEASE.md](RELEASE.md)

**⚠️ Chú ý:** Bạn nên xóa bộ nhớ đệm của trình duyệt sau khi cập nhật để plugin hoạt động đúng.

## Video demo 🎥

https://github.com/user-attachments/assets/e9a64709-8758-44d8-9e3c-9c15e0bf2a0e

## Yêu cầu 📋

- Neovim >=0.10.0 (khuyến nghị: >=0.10.1)
- Một trình duyệt web 🌐
- PowerShell (chỉ nếu bạn sử dụng Windows) 🪟

## Cài đặt 🛠️

Bạn có thể cài đặt plugin này bằng một trình quản lý plugin. Dưới đây là một số ví dụ 

<details>
<summary>Với lazy.nvim 💤</summary>

```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        dependencies = {'brianhuster/autosave.nvim'}, -- Không bắt buộc, nhưng nên có để tự động lưu tệp khi bạn chỉnh sửa file
        opts = {},
    }
})
```

</details>

<details>
<summary>mini.deps 📦</summary>

```lua
MiniDeps.add({
    source = 'brianhuster/live-preview.nvim',
    depends = { 
        'brianhuster/autosave.nvim', -- Không bắt buộc, nhưng nên có để tự động lưu
        'nvim-telescope/telescope.nvim' -- Not required, but recommended for integrating with Telescope
    }, 
})
```

</details>
<details>
<summary>rocks.nvim 🪨</summary>

```vim
:Rocks install live-preview.nvim
```
</details>

<details>

<details>
<summary>vim-plug 🔌</summary>

```vim
Plug 'brianhuster/live-preview.nvim'

Plug 'nvim-telescope/telescope.nvim' " Not required, but recommended for integrating with Telescope
Plug 'brianhuster/autosave.nvim' " Not required, but recomended for autosaving
```

</details>

<details>
<summary>Cài đặt thủ công (không dùng trình quản lý plugin)</summary>

```sh
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim ~/.local/share/nvim/site/pack/brianhuster/start/live-preview.nvim
```

</details>

## Tùy chỉnh

Bạn có thể tùy chỉnh plugin bằng cách đưa 1 bảng vào biến `opts` (với lazy.nvim) hoặc hàm `require('livepreview`).setup()`. Dưới đây là cấu hình mặc định

### Trong Lua

```lua
{
    cmd = "LivePreview", -- Main command of live-preview.nvim
    port = 5500, -- Port to run the live preview server on.
    autokill = false, -- If true, the plugin will autokill other processes running on the same port (except for Neovim) when starting the server.
    browser = 'default', -- Terminal command to open the browser for live-previewing (eg. 'firefox', 'flatpak run com.vivaldi.Vivaldi'). By default, it will use the default browser.
    dynamic_root = false, -- If true, the plugin will set the root directory to the previewed file's directory. If false, the root directory will be the current working directory (`:lua print(vim.uv.cwd())`).
    sync_scroll = false, -- If true, the plugin will sync the scrolling in the browser as you scroll in the Markdown files in Neovim.
    picker = nil, -- Picker to use for opening files. 3 choices are available: 'telescope', 'fzf-lua', 'mini.pick'. If nil, the plugin look for the first available picker when you call the `pick` command.
}
```

## In Vimscript
 
```vim
call v:lua.require('livepreview').setup({
    \ 'cmd': 'LivePreview', 
    \ 'port': 5500, 
    \ 'autokill': v:false, 
    \ 'browser': 'default', 
    \ 'dynamic_root': v:false, 
    \ 'sync_scroll': v:false, 
    \ 'picker': v:false, 
\ })
```

## Cách dùng 

> Hướng dẫn dưới đây áp dụng cho cấu hình mặc định (opts.cmd = "LivePreview")

* Để mở server live-preview và xem file trong trình duyệt, sử dụng lệnh:

`:LivePreview start`

Lệnh này sẽ mở tệp Markdown, HTML hoặc AsciiDoc hiện tại trong trình duyệt web mặc định của bạn và cập nhật nó trực tiếp khi bạn thực hiện các thay đổi trong tệp.

Bạn cũng có thể truyền đường dẫn tệp làm tham số, ví dụ `:LivePreview start test/doc.md`

* Để dừng máy chủ xem trước trực tiếp, sử dụng lệnh:

`:LivePreview close`

* Để mở trình chọn (Telescope, fzf-lua hoặc mini.pick) và chọn một tệp để xem trước, sử dụng lệnh:

`:LivePreview pick`

> Bạn cũng cần cài đặt một trong 3 plugin (Telescope, fzf-lua hoặc mini.pick) để sử dụng lệnh này.

* Để xem tài liệu về từng lệnh phụ, sử dụng lệnh:

`:LivePreview help`

Điều này yêu cầu phải cài đặt một trình chọn (Telescope, fzf-lua hoặc mini.pick). Nếu bạn có nhiều trình chọn được cài đặt, bạn có thể chỉ định trình chọn để sử dụng bằng cách truyền tên trình chọn vào bảng cấu hình (xem phần [setup](#setup))
Gõ lệnh `:help livepreview` để xem bằng tiếng Anh.

## Đóng góp

Vì đây là một dự án khá mới, hẳn sẽ có nhiều điều cần cải thiện. Nếu bạn muốn đóng góp cho dự án này, hãy mở một issue hoặc pull request. 

## Mục tiêu

- [x] Hỗ trợ công thức toán bằng Katex
- [x] Hỗ trợ biểu đồ Mermaid trong Markdown và AsciiDoc
- [x] Tô sáng cú pháp code trong tệp Markdown và AsciiDoc
- [x] Tự động cuộn trang web khi bạn cuộn trong tệp Markdown trong Neovim
- [ ] Tự động cuộn trang web khi bạn cuộn trong tệp AsciiDoc trong Neovim
- [x] Tích hợp với [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 🔭, [`fzf-lua`](https://github.com/ibhagwan/fzf-lua) and [`mini.pick`](https://github.com/echasnovski/mini.pick) 


## Không phải mục tiêu

Dưới đây là một số tính năng không nằm trong kế hoạch của live-preview.nvim, tuy nhiên chúng tôi luôn hoan nghênh pull request

- Thêm file css và js vào config [issue #49](https://github.com/brianhuster/live-preview.nvim/issues/49), [issue #50](https://github.com/brianhuster/live-preview.nvim/issues/50)

## Cảm ơn
* [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) và [Live Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server) vì ý tưởng
* [glacambre/firenvim](https://github.com/glacambre/firenvim) vì hàm sha1
* [sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css) CSS cho tệp Markdown
* [markdown-it/markdown-it](https://github.com/markdown-it/markdown-it) cho việc chuyển đổi tệp Markdown thành HTML
* [asciidoctor/asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js) cho việc chuyển đổi tệp AsciiDoc thành HTML
* [KaTeX](https://github.com/KaTeX/KaTeX) cho hiển thị phương trình toán học
* [mermaid-js/mermaid](https://github.com/mermaid-js/mermaid) cho hiển thị biểu đồ
* [digitalmoksha/markdown-it-inject-linenumbers](https://github.com/digitalmoksha/markdown-it-inject-linenumbers) : một plugin markdown-it để chèn số dòng vào đầu ra HTML


### Ủng hộ

<a href="https://me.momo.vn/brianphambinhan">
    <img src="https://github.com/user-attachments/assets/3907d317-b62f-43f5-a231-3ec7eb4eaa1b" alt="Momo (Vietnam)" style="height: 85px;">
</a>
<a href="https://img.vietqr.io/image/mb-9704229209586831984-print.png?addInfo=Donate%20for%20livepreview%20plugin%20nvim&accountName=PHAM%20BINH%20AN">
    <img src="https://github.com/user-attachments/assets/f28049dc-ce7c-4975-a85e-be36612fd061" alt="VietQR" style="height: 85px;">
</a>
<a href="https://paypal.me/brianphambinhan">
    <img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_111x69.jpg" alt="Paypal" style="height: 69px;">
</a>


