# Skill Map Tổng Hợp — Hệ Thống Sàn Thương Mại Điện Tử Quân Đội

## Bối cảnh dự án
Xây dựng nền tảng thương mại điện tử nơi quân nhân gửi hình ảnh/video chiến tích → AI quy đổi thành tiền ảo (xu) → mua sắm vũ khí/thiết bị từ các công ty tư nhân → vận chuyển khẩn cấp ra tiền tuyến. Thanh toán thực tế do Bộ Quốc Phòng đảm nhận.

---

## 1. Kỹ năng thiết kế & phát triển RESTful API

### 1.1 Authentication & Authorization (Tuần 1–2)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `signup` | POST | Đăng ký tài khoản bằng SĐT/email + password; sinh mã xác thực 6 ký tự |
| `login` | POST | Xác thực SĐT/email + password → access token + refresh token; kiểm tra devtoken |
| `logout` | POST | Vô hiệu hóa token phiên đăng nhập |
| `create_code_reset_password` | POST | Sinh & gửi OTP qua SMS/email cho luồng quên mật khẩu |
| `check_code_reset_password` | POST | Kiểm tra OTP (tồn tại, đúng user, còn hạn) |
| `reset_password` | POST | Đặt mật khẩu mới sau OTP hợp lệ → tự động đăng nhập |
| `change_password` | POST | Đổi mật khẩu khi đã đăng nhập (xác thực mật khẩu cũ) |
| `change_info_after_signup` | POST | Cập nhật username, avatar sau đăng ký lần đầu |
| `set_devtoken` | POST | Đăng ký device token (FCM/APNs) cho push notification |

### 1.2 User Profile Management (Tuần 3)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `get_user_info` | POST | Lấy thông tin hồ sơ: phân biệt dữ liệu công khai vs riêng tư dựa trên token/user_id |
| `set_user_info` | POST | Cập nhật hồ sơ cá nhân (email, tên, avatar, cover_image, địa chỉ) — partial update |

### 1.3 Catalog / Category / Product / Filter (Tuần 3)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `get_categories` | POST | Lấy danh mục phân cấp (cha/con) theo parent_id |
| `get_list_products` | POST | Tìm kiếm & lọc sản phẩm (keyword, category, brand, size, price_min/max, condition, last_id); phân trang index/count |
| `get_product` | POST | Lấy chi tiết một sản phẩm (product detail page) |
| `get_list_brands` | POST | Lọc thương hiệu theo category_id, phân trang |

### 1.4 Listing / Seller Management (Tuần 3)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `add_product` | POST | Tạo sản phẩm mới (title, giá, category, mô tả, ảnh/video, ship_from) |
| `edit_product` | POST | Cập nhật sản phẩm (giá, mô tả, trạng thái, media) |
| `del_product` | POST | Xóa cứng sản phẩm khỏi hệ thống |
| `get_user_listings` | POST | Danh sách listing của một seller, lọc theo trạng thái, keyword, category |

### 1.5 Social Interactions: Comment / Like / Report / Rating (Tuần 4)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `get_comments_product` | POST | Lấy danh sách comment của sản phẩm, phân trang |
| `set_comments_product` | POST | Tạo comment cho sản phẩm (kèm rating nếu thiết kế hỗ trợ) |
| `like_product` | POST | Toggle like/unlike sản phẩm → trả tổng like hiện tại |
| `report_product` | POST | Báo cáo sản phẩm vi phạm (hàng giả, spam, ảnh phản cảm…) |
| `get_rates` | POST | Lấy danh sách rating của user/product/purchase, lọc theo level, phân trang |
| `set_rates` | POST | Tạo rating (sao + nhận xét) cho sản phẩm/purchase/user sau giao dịch |

### 1.6 Search & News (Tuần 4)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `search` | POST | Tìm kiếm sản phẩm theo multi-filter, phân trang |
| `del_saved_search` | POST | Xóa lịch sử tìm kiếm (từng keyword hoặc toàn bộ) |
| `get_list_saved_search` | POST | Lấy danh sách tìm kiếm đã lưu, phân trang |
| `get_list_news` | POST | Danh sách tin tức/bài viết, phân trang |
| `get_news` | POST | Chi tiết một bài tin tức |

### 1.7 Social Graph: Follow / Block / Discovery (Tuần 5)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `set_user_follow` | POST | Follow/unfollow user → trả số lượng follower/following |
| `get_list_followed` | POST | Danh sách người đang theo dõi user_id, phân trang |
| `get_list_following` | POST | Danh sách user mình đang theo dõi, phân trang |
| `get_list_blocks` | POST | Danh sách user đã block, phân trang |
| `blocks` | POST | Block/unblock user → hạn chế tương tác (chat, follow, xem thông tin) |

### 1.8 Notification & Chatting (Tuần 5)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `send_message` | POST | Gửi tin nhắn → auto tạo conversation mới nếu chưa có |
| `get_list_conversation` | POST | Danh sách conversation, phân trang |
| `get_conversation` | POST | Chi tiết messages trong một conversation (theo partner_id + product_id hoặc conversation_id) |
| `get_conversation_detail` | POST | Thông tin sản phẩm đang trao đổi trong conversation |
| `get_notification` | POST | Danh sách thông báo hệ thống (đơn hàng, like, follow…), phân trang |
| `set_read_notification` | POST | Đánh dấu notification đã đọc |
| `set_read_message` | POST | Đánh dấu read receipt cho tin nhắn |

### 1.9 Push Notification Settings (Tuần 2)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `get_push_setting` | POST | Lấy trạng thái bật/tắt push theo loại (like, comment, transaction, announcement, sound) |
| `set_push_setting` | POST | Cập nhật cài đặt push (partial update trên các trường 0/1) |

### 1.10 Order / Purchase Management (Tuần 6)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `create_order` | POST | Tạo đơn hàng từ sản phẩm đã chọn |
| `get_list_purchases` | POST | Danh sách đơn (buyer xem đơn mình / seller xem đơn của shop), phân trang |
| `get_purchase` | POST | Chi tiết một đơn hàng |
| `edit_purchase` | POST | Sửa địa chỉ/ghi chú khi đơn ở trạng thái pending/confirmed |
| `cancel_order` | POST | Hủy đơn khi chưa ship → hoàn xu |
| `set_accept_buyer` | POST | Seller chấp nhận/từ chối đơn mua |
| `seller_mark_as_shipped` | POST | Seller cập nhật trạng thái đã gửi hàng (confirmed → shipping) |
| `buyer_confirm_received` | POST | Buyer xác nhận đã nhận hàng (shipping → delivered) |
| `get_order_timeline` | POST | Lịch sử thay đổi trạng thái đơn hàng |
| `refund_order` | POST | Gửi yêu cầu hoàn hàng/hoàn tiền (khi state = delivered) |

**Trạng thái đơn hàng:** `pending` → `confirmed` → `shipping` → `delivered` → `cancelled` / `refunded`

### 1.11 Shipping & Address (Tuần 7)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `get_ship_from` | POST | Danh sách địa điểm gửi hàng (tỉnh/thành/kho), phân trang, theo parent_id |
| `get_ship_fee` | POST | Tính phí ship theo ship_from → ship_to (+ kích thước/khối lượng) |
| `get_order_status` | POST | Danh sách trạng thái đơn (enum) |
| `get_list_order_address` | POST | Danh sách địa chỉ nhận hàng của user |
| `add_order_address` | POST | Thêm địa chỉ nhận hàng |
| `edit_order_address` | POST | Sửa địa chỉ nhận hàng |
| `delete_order_address` | POST | Xóa địa chỉ nhận hàng |

### 1.12 Wallet & Balance (Tuần 8)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `get_current_balance` | POST | Số dư hiện tại (available_balance + pending_balance) |
| `get_balance_history` | POST | Lịch sử biến động số dư (income/expense), phân trang |
| `create_withdraw_request` | POST | Seller yêu cầu rút xu về tài khoản ngân hàng |
| `set_request_withdraw` | POST | Admin duyệt/từ chối yêu cầu rút tiền |
| `get_withdraw_history` | POST | Lịch sử rút tiền |

### 1.13 Media Upload & Reward System (Tuần 8)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `upload_video` | POST | Upload video chiến tích phục vụ AI chấm điểm quy đổi xu |
| `get_reward_history` | POST | Lịch sử quy đổi điểm thưởng, phân trang |
| `create_reward_appeal` | POST | Tạo yêu cầu khiếu nại điểm thưởng |

### 1.14 Bank Account (Mở rộng — Tuần 8)
| API | Phương thức | Kỹ năng đạt được |
|---|---|---|
| `get_bank_accounts` | POST | Danh sách tài khoản ngân hàng của seller |
| `add_bank_account` | POST | Thêm tài khoản ngân hàng |
| `edit_bank_account` | POST | Sửa tài khoản ngân hàng |
| `delete_bank_account` | POST | Xóa tài khoản ngân hàng |
| `set_default_bank_account` | POST | Đặt tài khoản ngân hàng mặc định |

---

## 2. Quy trình phát triển & tổ chức dự án

### 2.1 Lộ trình phát triển 11 tuần
| Tuần | Nội dung | Nhóm API |
|---|---|---|
| 1 | Auth cơ bản | Account: signup, login, logout |
| 2 | Auth nâng cao + Cài đặt | Account: reset password, change password, change info, devtoken, push settings |
| 3 | Hồ sơ + Sản phẩm | User Profile, Catalog/Categories/Filter, Listing |
| 4 | Tương tác + Tìm kiếm + Tin tức | Comment/Like/Report/Rating, Search, News |
| 5 | Mạng xã hội + Thông báo | Follow/Block, Notification/Chatting |
| 6 | Đơn hàng | Purchase/Order |
| 7 | Vận chuyển | Shipping/Address/Fee |
| 8 | Ví + Upload | Wallet/Balance/Withdraw, Upload Media |
| 9 | Hoàn thiện thanh toán | Checkout, Upload media (bổ sung) |
| 10 | Hoàn thiện giao diện | UI/UX review + API testing |
| 11 | Bảo vệ | Final defense preparation |

### 2.2 Chuẩn phản hồi API (Response Codes)
| Mã | Ý nghĩa |
|---|---|
| `1000` | OK — Thành công |
| `1002` | Parameter is not enough — Thiếu tham số |
| `1003` | Parameter type is invalid — Sai kiểu dữ liệu |
| `1004` | Parameter value is invalid — Giá trị tham số không hợp lệ |
| `1009` | Not access — Không có quyền truy cập (bị block) |
| `1010` | Action has been done previously — Hành động đã thực hiện trước đó |
| `1013` | User does not exist — Người dùng không tồn tại |
| `9993` | Code verify is incorrect — Mã xác thực sai |
| `9995` | User is not validated — Người dùng chưa được xác thực |
| `9998` | Token is invalid — Token hết hạn/không hợp lệ |

### 2.3 Đặc tả test case — Chuẩn hóa kiểm thử API
Mỗi API đều được đặc tả test case theo cấu trúc:
- **Positive case:** Đầu vào hợp lệ → `1000 OK`
- **Token invalid:** Token sai/hết hạn → `9998` → redirect login
- **Missing params:** Thiếu tham số bắt buộc → `1002`
- **Invalid params:** Sai định dạng/giá trị → `1004`
- **Entity not found:** ID không tồn tại → `1004` hoặc `1013`
- **State machine violation:** Hành động không được phép ở trạng thái hiện tại → `1004` hoặc `1010`
- **Authorization:** Không có quyền truy cập tài nguyên (block) → `1009`

### 2.4 Phân trang chuẩn (Pagination Pattern)
- Tham số: `index` + `count`
- Cơ chế `last_id` để tránh trùng lặp bài viết mới khi phân trang trong real-time feed

### 2.5 Partial Update Pattern
- API `set_user_info`, `set_push_setting`, `edit_product`: chỉ cập nhật các trường được gửi lên, giữ nguyên các trường không truyền

---

## 3. Các kỹ năng lõi (Core Competencies)

### 3.1 Thiết kế API RESTful
- Thiết kế ~70 endpoint RESTful theo chuẩn POST-based API
- Phân biệt dữ liệu công khai vs riêng tư dựa trên context (token vs user_id)
- Xây dựng hệ thống phân quyền: buyer, seller, admin

### 3.2 Xác thực & Bảo mật
- Token-based authentication (access token + refresh token)
- Device token management (FCM/APNs)
- OTP-based password reset workflow (create → check → reset)
- Password policy enforcement (6–10 ký tự, không trùng username/SĐT, không ký tự đặc biệt)

### 3.3 Quản lý trạng thái (State Machine)
- Order lifecycle: `pending → confirmed → shipping → delivered → cancelled/refunded`
- Block/Follow state management (toggle pattern)
- Like toggle pattern (like ↔ unlike, trả về tổng count)

### 3.4 Phân trang & Tối ưu dữ liệu
- Index/count based pagination
- last_id mechanism for real-time feed consistency
- Phân cấp danh mục (category tree) với parent_id

### 3.5 Tương tác xã hội (Social Features)
- Follow/Unfollow với cập nhật số lượng real-time
- Block/Unblock với hạn chế tương tác (chat, follow, view)
- Comment, Rating, Report với workflow xử lý
- Chat/Conversation real-time messaging

### 3.6 Thương mại điện tử (E-commerce Core)
- Product listing CRUD với media management
- Search engine với multi-filter (keyword, category, brand, size, price range, condition)
- Shopping cart → Order creation
- Shipping address CRUD
- Shipping fee calculation (distance + weight/dimensions)
- Virtual wallet (available_balance + pending_balance)
- Withdraw request workflow (seller → admin)

### 3.7 Tích hợp AI
- AI-powered combat achievement scoring từ video
- Classification + Regression model cho reward calculation
- Reward appeal workflow (khiếu nại điểm thưởng)

### 3.8 Kiểm thử (Testing)
- Đặc tả test case chi tiết cho từng API
- Kiểm thử biên (boundary testing): định dạng SĐT, độ dài password
- Kiểm thử luồng (workflow testing): OTP flow, order lifecycle
- Kiểm thử phân quyền: token validation, block restriction

---

## 4. Ứng dụng thực tiễn (Practical Applications)

| Lĩnh vực | Ứng dụng |
|---|---|
| **E-commerce Backend** | Hệ thống đầy đủ các module: Auth, Product, Order, Payment, Shipping, Chat |
| **Social Marketplace** | Tích hợp social features (follow, block, chat) vào nền tảng mua bán |
| **AI-Powered Reward System** | Tự động chấm điểm và quy đổi giá trị từ media content |
| **Real-time Systems** | Push notification, real-time chat, live feed pagination |
| **Admin Dashboard** | Quản lý report, reward appeal, withdraw request approval |
| **Mobile Backend** | FCM/APNs device token, RESTful API với token-based auth |
| **Fintech / Wallet** | Virtual currency management, balance tracking, withdraw workflows |

---

## 5. Công nghệ & Mẫu kiến trúc

| Pattern / Tech | Mô tả |
|---|---|
| **RESTful POST-based API** | Tất cả API dùng phương thức POST |
| **Token-based Auth** | JWT access token + refresh token |
| **State Machine** | Quản lý vòng đời đơn hàng, trạng thái block/follow |
| **Partial Update** | Cập nhật một phần resource (không PUT toàn bộ) |
| **Cursor-based Pagination** | last_id cho real-time feed |
| **Toggle Pattern** | Like/Unlike, Follow/Unfollow, Block/Unblock |
| **Hierarchical Data** | Danh mục phân cấp (parent_id), địa chỉ phân cấp (tỉnh → phường) |
| **Role-based Access** | Buyer, Seller, Admin với các quyền riêng biệt |
| **Workflow-based Processing** | OTP flow, Order lifecycle, Reward appeal flow |