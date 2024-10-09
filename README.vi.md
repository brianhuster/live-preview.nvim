# live-preview.nvim

Một plugin Neovim cho phép bạn xem kết quả tệp [Markdown](https://vi.wikipedia.org/wiki/Markdown), [HTML](https://vi.wikipedia.org/wiki/HTML) (nhúng kèm CSS, JS) và [AsciiDoc](https://asciidoc.org/) trong trình duyệt web với cập nhật trực tiếp, cho phép bạn không cần tải lại trình duyệt mỗi khi có thay đổi trong file. Không như một số plugin tương tự yêu cầu runtime ngoài như Node hoặc Python, plugin này không yêu cầu bất kỳ runtime ngoài nào, ngoại trừ chính LuaJIT được tích hợp sẵn trong Neovim.

## Tính năng
Hỗ trợ các tệp Markdown, HTML (kèm CSS, JS) và AsciiDoc

Hỗ trợ Katex để hiển thị các phương trình toán học trong tệp Markdown và AsciiDoc

Hỗ trợ mermaid để hiển thị các biểu đồ trong tệp Markdown

### Cập nhật

Xem [RELEASE.md](RELEASE.md)

**⚠️ Quan trọng:** Bạn cần xóa bộ nhớ đệm của trình duyệt sau khi cập nhật để plugin hoạt động đúng.

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
        dependencies = {'brianhuster/autosave.nvim'}, -- Không bắt buộc, nhưng nên có để tự động lưu tệp khi bạn chỉnh sửa file
        opts = {},
    }
})
```

### mini.deps
```lua
add({
    source = 'brianhuster/live-preview.nvim',
    depends = { 'brianhuster/autosave.nvim' }, -- Not required, but recomended for autosaving
})
require('livepreview').setup()
```

### vim-plug
```vim
Plug 'brianhuster/live-preview.nvim'
Plug 'brianhuster/autosave.nvim' " Not required, but recomended for autosaving
lua EOF
require('livepreview').setup()
EOF
```

## Thiết lập

Bạn có thể tùy chỉnh plugin bằng cách đưa 1 bảng vào biến `opts` hoặc hàm `require('livepreview`).setup()`. Dưới đây là cấu hình mặc định

```lua
{
    commands = {
        start = 'LivePreview', -- Lệnh khởi động máy chủ live-preview.
        stop = 'StopPreview', -- Lệnh để dừng máy chủ live-preview.
    },
    port = 5500, -- Cổng để chạy máy chủ live-preview 
    browser = "default", -- Trình duyệt để xem kết quả live-preview. Mặc định "default" sẽ mở trình duyệt mặc định của hệ điều hành
}
```

## Cách dùng

> Hướng dẫn dưới đây sử dụng cấu hình mặc định

Để khởi động máy chủ live-preview, dùng lệnh:

`:LivePreview`

Lệnh này sẽ mở tệp Markdown hoặc HTML hiện tại trong trình duyệt web tại địa chỉ "http://localhost:5500/tên-file" và cập nhật trực tiếp mỗi khi bạn chỉnh sửa file.

Để tắt máy chủ live-preview, dùng lệnh:

`:StopPreview`

Gõ lệnh `:help livepreview` để xem bằng tiếng Anh.

## Đóng góp

Vì đây là một dự án khá mới, hẳn sẽ có nhiều điều cần cải thiện. Nếu bạn muốn đóng góp cho dự án này, hãy mở một issue hoặc pull request. 

## TODO

- [x] Hỗ trợ công thức toán bằng Katex
- [x] Hỗ trợ biểu đồ Mermaid trong Markdown
- [ ] Tự động cuộn trang web khi bạn cuộn trong tệp Markdown và AsciiDoc trong Neovim
- [ ] Hỗ trợ biểu đồ trong AsciiDoc

## Cảm ơn
* [glacambre/firenvim](https://github.com/glacambre/firenvim) vì hàm sha1
* [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) và [Live Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-máy chủ) vì ý tưởng
* [sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css) CSS cho tệp Markdown
* [markedjs/marked](https://github.com/markedjs/marked) cho việc chuyển đổi tệp Markdown thành HTML
* [asciidoctor/asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js) cho việc chuyển đổi tệp AsciiDoc thành HTML
* [KaTeX](https://github.com/KaTeX/KaTeX) cho hiển thị phương trình toán học
* [mermaid-js/mermaid](https://github.com/mermaid-js/mermaid) cho hiển thị biểu đồ


### Ủng hộ
#### Momo (Việt Nam)
[https://me.momo.vn/brianphambinhan](https://me.momo.vn/brianphambinhan)

#### Paypal
[https://www.paypal.com/paypalme/brianphambinhan](https://www.paypal.com/paypalme/brianphambinhan)

