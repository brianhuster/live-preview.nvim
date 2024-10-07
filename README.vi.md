# live-preview.nvim

Một plugin Neovim cho phép bạn xem kết quả file [Markdown](https://vi.wikipedia.org/wiki/Markdown), [HTML](https://vi.wikipedia.org/wiki/HTML) (nhúng kèm CSS, JS) và [AsciiDoc](https://asciidoc.org/) trong trình duyệt web với cập nhật trực tiếp, cho phép bạn không cần tải lại trình duyệt mỗi khi có thay đổi trong file. Không như một số plugin tương tự yêu cầu runtime ngoài như Node hoặc Python, plugin này không yêu cầu bất kỳ runtime ngoài nào, ngoại trừ chính LuaJIT được tích hợp sẵn trong Neovim.

## Tính năng
Hỗ trợ các file Markdown, HTML (kèm CSS, JS) và AsciiDoc

Hỗ trợ Katex để hiển thị các phương trình toán học trong file Markdown và AsciiDoc

Hỗ trợ mermaid để hiển thị các biểu đồ trong file Markdown

### [Cập nhật](RELEASE.md)

**⚠️ Quan trọng:** Bạn cần xóa cache của trình duyệt sau khi cập nhật để plugin hoạt động đúng.

## Video demo

https://github.com/user-attachments/assets/e9a64709-8758-44d8-9e3c-9c15e0bf2a0e

## Yêu cầu

- Neovim >=0.10.0
- Một trình duyệt web

## Cài đặt

Bạn có thể cài đặt plugin này bằng một trình quản lý plugin. Dưới đây là một số ví dụ 

### Với lazy.nvim
```lua
require("lazy").setup({
    {
        'brianhuster/live-preview.nvim',
        dependencies = {'brianhuster/autosave.nvim'}, -- Không bắt buộc, nhưng nên có để tự động lưu file khi bạn chỉnh sửa file
    }
})
```

### Với vim-plug
```vim
Plug 'brianhuster/live-preview.nvim'
Plug 'brianhuster/autosave.nvim' " Không bắt buộc, nhưng nên có để tự động lưu file khi bạn chỉnh sửa file
```

## Thiết lập

Thêm đoạn code sau vào `init.lua`:

```lua
require('live-preview').setup()
```

Nếu bạn dùng `init.vim`:

```vim
lua require('live-preview').setup()
```

Bạn cũng có thể tùy chỉnh plugin. Dưới đây là cấu hình mặc định

```lua
require('live-preview').setup({
    commands = {
        start = 'LivePreview', -- Lệnh khởi động server live-preview.
        stop = 'StopPreview', -- Lệnh để dừng server live-preview.
    },
    port = 5500, -- Cổng để chạy server live-preview 
    browser = "default", -- Trình duyệt để xem kết quả live-preview. Mặc định "default" sẽ mở trình duyệt mặc định của hệ điều hành
})
```

## Cách dùng

> Hướng dẫn dưới đây sử dụng cấu hình mặc định

Để khởi động server live-preview, dùng lệnh:

`:LivePreview`

Lệnh này sẽ mở file Markdown hoặc HTML hiện tại trong trình duyệt web tại địa chỉ "http://localhost:5500/tên-file" và cập nhật trực tiếp mỗi khi bạn chỉnh sửa file.

Để tắt server live-preview, dùng lệnh:

`:StopPreview`

Gõ lệnh `:help live-preview@vi` để xem tài liệu hướng dẫn đầy đủ bằng tiếng Việt hoặc `:help live-preview` để xem bằng tiếng Anh.

## Đóng góp

Vì đây là một dự án khá mới, hẳn sẽ có nhiều điều cần cải thiện. Nếu bạn muốn đóng góp cho dự án này, hãy mở một issue hoặc pull request. 

## Cảm ơn
* [glacambre/firenvim](https://github.com/glacambre/firenvim) vì hàm sha1
* [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) và [Live Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server) vì ý tưởng
* [sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css) CSS cho file Markdown
* [markedjs/marked](https://github.com/markedjs/marked) cho việc chuyển đổi file Markdown thành HTML
* [asciidoctor/asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js) cho việc chuyển đổi file AsciiDoc thành HTML
* [KaTeX](https://github.com/KaTeX/KaTeX) cho hiển thị phương trình toán học
* [mermaid-js/mermaid](https://github.com/mermaid-js/mermaid) cho hiển thị biểu đồ


### Ủng hộ
#### Paypal
[https://www.paypal.com/paypalme/brianphambinhan](https://www.paypal.com/paypalme/brianphambinhan)

#### Momo (Vietnam)
[https://me.momo.vn/brianphambinhan](https://me.momo.vn/brianphambinhan)
