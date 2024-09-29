# live-preview.nvim

Một plugin Neovim cho phép bạn xem kết quả file [Markdown](https://vi.wikipedia.org/wiki/Markdown), [HTML](https://vi.wikipedia.org/wiki/HTML) (nhúng kèm CSS, JS) và [AsciiDoc](https://asciidoc.org/) trong trình duyệt web với cập nhật trực tiếp, cho phép bạn không cần tải lại trình duyệt mỗi khi có thay đổi trong file. Không như một số plugin tương tự yêu cầu runtime ngoài như Node hoặc Python, plugin này không yêu cầu bất kỳ runtime ngoài nào, ngoại trừ chính LuaJIT được tích hợp sẵn trong Neovim.

### Cập nhật
Hỗ trợ công thức toán học [Katex](https://katex.org) trong file Markdown và AsciiDoc.
Hỗ trợ vẽ sơ đồ với [mermaid](https://mermaid.js.org/) trong file Markdown.

**⚠️ Quan trọng:** Bạn cần xóa cache của trình duyệt sau khi cập nhật để plugin hoạt động đúng.

## Video demo

https://github.com/user-attachments/assets/e9a64709-8758-44d8-9e3c-9c15e0bf2a0e

## Yêu cầu

- Neovim >=0.10.1
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

### Buy me a coffee
#### Paypal
[https://www.paypal.com/paypalme/brianphambinhan](https://www.paypal.com/paypalme/brianphambinhan)

#### Momo (Vietnam)
[https://me.momo.vn/brianphambinhan](https://me.momo.vn/brianphambinhan)
