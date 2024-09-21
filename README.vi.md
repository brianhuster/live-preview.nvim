# live-preview.nvim

Một plugin Neovim cho phép bạn xem kết quả file Markdown, HTML (nhúng kèm CSS, JS) và AsciiDocs trong trình duyệt web với cập nhật trực tiếp, cho phép bạn không cần tải lại trình duyệt mỗi khi có thay đổi trong file. Không như một số plugin tương tự yêu cầu runtime ngoài như Node hoặc Python, plugin này không yêu cầu bất kỳ runtime ngoài nào, ngoại trừ chính LuaJIT được tích hợp sẵn trong Neovim.

## Video demo

https://github.com/user-attachments/assets/e9a64709-8758-44d8-9e3c-9c15e0bf2a0e

## Yêu cầu

- Neovim 0.10 trở lên
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


