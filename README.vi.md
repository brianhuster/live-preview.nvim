# live-preview.nvim 🚀

Một plugin Neovim cho phép bạn xem kết quả tệp [Markdown](https://vi.wikipedia.org/wiki/Markdown), [HTML](https://vi.wikipedia.org/wiki/HTML) (nhúng kèm CSS, JS) và [AsciiDoc](https://asciidoc.org/) trong trình duyệt web với cập nhật trực tiếp, cho phép bạn không cần tải lại trình duyệt mỗi khi có thay đổi trong file. Không như một số plugin tương tự yêu cầu runtime ngoài như Node hoặc Python, plugin này không yêu cầu bất kỳ runtime ngoài nào, ngoại trừ chính Lua được tích hợp sẵn trong Neovim.

## Tính năng ✨
- Hỗ trợ các tệp Markdown, HTML (kèm CSS, JS) và AsciiDoc 📄
- Hỗ trợ Katex để hiển thị các phương trình toán học trong tệp Markdown và AsciiDoc 🧮
- Hỗ trợ mermaid để hiển thị các biểu đồ trong tệp Markdown 🖼️
- Tô sáng cú pháp code trong tệp Markdown và AsciiDoc 🖍️
- Hỗ trợ cuộn trang web khi bạn cuộn trong tệp Markdown trong Neovim. (Bạn cần kích hoạt `sync_scroll` trong [Tùy chỉnh](#tùy-chỉnh). Tính năng này nên được sử dụng cùng với [brianhuster/autosave.nvim](https://github.com/brianhuster/autosave.nvim)) 🔄
- Tích hợp với [Telescope](https://github.com/nvim-telescope/telescope.nvim) 🔭

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
require('livepreview').setup()
require('autosave').setup() -- Not required, but recomended for autosaving
```

</details>

<details>
<summary>vim-plug 🔌</summary>

```vim
Plug 'brianhuster/live-preview.nvim'
let g:livepreview_config = {} " Cấu hình tùy chọn
lua require('livepreview').setup(vim.g.livepreview_config) " Bắt buộc để kích hoạt plugin

Plug 'nvim-telescope/telescope.nvim' " Not required, but recommended for integrating with Telescope
Plug 'brianhuster/autosave.nvim' " Not required, but recomended for autosaving
lua require('autosave').setup() " Not required, but recomended for autosaving
```

</details>

<details>
<summary>Cài đặt thủ công (không dùng trình quản lý plugin)</summary>

- **Linux, MacOS, dựa trên Unix**

```sh
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim ~/.config/nvim/pack/brianhuster/start/live-preview.nvim
```

- **Windows (Powershell)**

```powershell
git clone --depth 1 https://github.com/brianhuster/live-preview.nvim "$HOME/AppData/Local/nvim/pack/brianhuster/start/live-preview.nvim"
```

Bạn phải thêm dòng `require('livepreview').setup()` (Lua) hoặc `lua require('livepreview').setup()` (Vimscript) vào tệp cấu hình Neovim của bạn để kích hoạt plugin.
</details>

## Tùy chỉnh

Bạn có thể tùy chỉnh plugin bằng cách đưa 1 bảng vào biến `opts` (với lazy.nvim) hoặc hàm `require('livepreview`).setup()`. Dưới đây là cấu hình mặc định

### Trong Lua

```lua
{
    commands = {
        start = 'LivePreview', -- Lệnh khởi động máy chủ live-preview.
        stop = 'StopPreview', -- Lệnh để dừng máy chủ live-preview.
    },
    autokill = false, -- Nếu true, plugin sẽ tự động đóng các tiến trình đang dùng trên cổng (trừ Neovim) khi khởi động máy chủ live-preview.
    port = 5500, -- Cổng để chạy máy chủ live-preview 
    browser = 'default', -- Lệnh để mở trình duyệt (ví dụ 'firefox', 'flatpak run com.vivaldi.Vivaldi'. Giá trị 'default' là trình duyệt mặc định của hệ điều hành. 
    dynamic_root = false, -- Nếu true, thư mục gốc của server sẽ là thư mục mẹ của file được preview. Nếu false, plugin sẽ chạy máy chủ live-preview từ thư mục làm việc hiện tại (Bạn có thể xem thư mục làm việc hiện tại bằng lệnh `:pwd`).
    sync_scroll = false, -- Nếu true, plugin sẽ cuộn trang web khi bạn cuộn trong tệp Markdown trong Neovim.
    telescope = false -- Nếu true, plugin sẽ tự động load extension `Telescope livepreview`
}
```

### Trong Vimscript

```vim
let g:livepreview_config = {
    \ 'commands': {
    \     'start': 'LivePreview', " Lệnh khởi động máy chủ live-preview.
    \     'stop': 'StopPreview', " Lệnh để dừng máy chủ live-preview.
    \ },
    \ 'autokill': v:false, " Nếu v:true, plugin sẽ tự động đóng các tiến trình đang dùng trên cổng (trừ Neovim) khi khởi động máy chủ live-preview.
    \ 'port': 5500, " Cổng để chạy máy chủ live-preview
    \ 'browser': 'default', " Lệnh để mở trình duyệt (ví dụ 'firefox', 'flatpak run com.vivaldi.Vivaldi'. Giá trị 'default' là trình duyệt mặc định của hệ điều hành.
    \ 'dynamic_root': v:false, " Nếu v:true, thư mục gốc của server sẽ là thư mục mẹ của file được preview. Nếu v:false, plugin sẽ chạy máy chủ live-preview từ thư mục làm việc hiện tại (Bạn có thể xem thư mục làm việc hiện tại bằng lệnh `:pwd`).
    \ 'sync_scroll': v:false, " Nếu v:true, plugin sẽ cuộn trang web khi bạn cuộn trong tệp Markdown trong Neovim.
    \ 'telescope': v:false " Nếu v:true, plugin sẽ tự động load extension `Telescope livepreview`
\ }
```

**⚠️ Chú ý:** Đảm bảo rằng bạn cấu hình `g:livepreview_config` trước khi gọi `lua require('livepreview').setup()`.

## Cách dùng

> Hướng dẫn dưới đây sử dụng cấu hình mặc định

Để khởi động máy chủ live-preview, dùng lệnh:

`:LivePreview`

Lệnh này sẽ mở tệp Markdown hoặc HTML hiện tại trong trình duyệt web tại địa chỉ "http://localhost:5500/tên-file" và cập nhật trực tiếp mỗi khi bạn chỉnh sửa file.

Bạn có thể thêm 1 đường dẫn file làm tham số cho lệnh `:LivePreview` (ví dụ `:LivePreview Documents/file.md`)

Để tắt máy chủ live-preview, dùng lệnh:

`:StopPreview`

Gõ lệnh `:help livepreview` để xem bằng tiếng Anh.

### Sử dụng với Telescope

Để dùng tính năng này, bạn cần cài đặt [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

Sau đó, đặt `telescope.autoload` thành `true` trong [bảng cấu hình](#tùy-chỉnh) của live-preview.nvim

Cách khác, bạn có thể thêm đoạn mã sau vào tệp cấu hình Neovim của mình:

```lua
require('telescope').load_extension('livepreview')
```

Đến đây, bạn có thể dùng lệnh `:Telescope livepreview` để mở giao diện Telescope của live-preview.nvim

## Đóng góp

Vì đây là một dự án khá mới, hẳn sẽ có nhiều điều cần cải thiện. Nếu bạn muốn đóng góp cho dự án này, hãy mở một issue hoặc pull request. 

## Mục tiêu

- [x] Hỗ trợ công thức toán bằng Katex
- [x] Hỗ trợ biểu đồ Mermaid trong Markdown và AsciiDoc
- [x] Tô sáng cú pháp code trong tệp Markdown và AsciiDoc
- [x] Tự động cuộn trang web khi bạn cuộn trong tệp Markdown trong Neovim
- [ ] Tự động cuộn trang web khi bạn cuộn trong tệp AsciiDoc trong Neovim

## Không phải mục tiêu

Dưới đây là một số tính năng không nằm trong kế hoạch của live-preview.nvim, tuy nhiên chúng tôi luôn hoan nghênh pull request

- Thêm file css và js vào config

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


