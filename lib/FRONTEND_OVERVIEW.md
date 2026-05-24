# Frontend Overview — military_e_commerce (Dành cho người mới)

Mục đích: tài liệu này giải thích cấu trúc thư mục `lib/` và luồng hoạt động chính của từng chức năng (Auth, Home, Product, Cart, Order, Profile, Wallet). Mục tiêu là giúp người không chuyên về frontend hiểu nhanh cách dữ liệu chảy qua app và nơi thay đổi / mở rộng.

**Tổng quan cấu trúc**
- **Entry:** [lib/main.dart](lib/main.dart)
- **Core:** [lib/core/api](lib/core/api/api_client.dart) (Http + token), [lib/core/constants](lib/core/constants), [lib/core/widgets](lib/core/widgets/common_widgets.dart), [lib/core/router](lib/core/router/app_router.dart)
- **Features:** mỗi tính năng có 2 phần chính: `data/` (providers, logic gọi API) và `presentation/` (screens, UI). Ví dụ: `lib/features/auth/data`, `lib/features/auth/presentation`.
- **Models:** [lib/models](lib/models) chứa các lớp dữ liệu (Product, User, Order, v.v.).

**State management**
- App dùng `provider` (ChangeNotifier). Các provider được khởi tạo trong [lib/main.dart](lib/main.dart) bằng `MultiProvider`:
  - `AuthProvider`
  - `ProductProvider`
  - `CartProvider`
  - `OrderProvider`
  - `WalletProvider`

Kết quả: UI lắng nghe trạng thái provider bằng `Consumer` / `context.read` / `context.watch`.

**Core - API and utilities**
- `ApiClient` ([lib/core/api/api_client.dart](lib/core/api/api_client.dart)):
  - Quản lý access token trong `SharedPreferences` (set/load/clear).
  - Cung cấp `post()` và `get()` trả về `ApiResponse` có: `isSuccess`, `message`, `code`, `data`, `isTokenExpired`.
  - Khi token expired, provider (ví dụ `AuthProvider`) sẽ gọi `clearTokens()` và cập nhật trạng thái.
- `ApiConstants` ([lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart)) chứa endpoint strings và response codes.
- `common_widgets.dart` chứa các widget tái sử dụng: `CustomNetworkImage`, `LoadingIndicator`, `EmptyState`, `PriceDisplay`, `RatingStars`.

**Models (tóm tắt)**
- `Product`: thông tin sản phẩm (id, title, price, images, stock, seller, createdAt...).
- `User`: thông tin user (id, username, email, avatar, balance...).
- `CartItem`: chứa `Product` + quantity + selectedSize.
- `Order`, `OrderItem`, `OrderAddress`, `OrderTimeline` cho luồng đặt hàng.
- `WalletBalance`, `BalanceTransaction` cho phần ví.

Luồng chính theo feature

1) Auth (đăng nhập / đăng ký)
- UI: [lib/features/auth/presentation/login_screen.dart](lib/features/auth/presentation/login_screen.dart), [lib/features/auth/presentation/signup_screen.dart](lib/features/auth/presentation/signup_screen.dart)
- Logic: `AuthProvider` ([lib/features/auth/data/auth_provider.dart](lib/features/auth/data/auth_provider.dart))
- Flow:
  1. Người dùng nhập phone/password (LoginScreen) → gọi `AuthProvider.login()`.
  2. `AuthProvider.login()` gọi `ApiClient.post(ApiConstants.login)`.
  3. Nếu API trả token: `ApiClient.setTokens(token, refresh)` lưu token, sau đó `AuthProvider` gọi endpoint lấy thông tin user (getUserInfo) hoặc dùng data trả về để khởi tạo `User`.
  4. Cập nhật `_status` sang `authenticated`, UI chuyển hướng đến `/home`.
  5. Logout gọi `AuthProvider.logout()` → post logout, `ApiClient.clearTokens()` và điều hướng về `/login`.

2) Home (trang chính)
- UI: [lib/features/home/presentation/home_screen.dart](lib/features/home/presentation/home_screen.dart)
- Logic: `ProductProvider` ([lib/features/home/data/product_provider.dart](lib/features/home/data/product_provider.dart))
- Flow:
  - Khi vào `HomeScreen`, `ProductProvider.loadCategories()` và `loadProducts()` được gọi.
  - `ApiClient.post()` lấy categories và products → parse thành `Category` / `Product`.
  - UI hiển thị: balance (từ `AuthProvider.user.balance`), danh mục (horiz list), sản phẩm nổi bật (featured) và lưới sản phẩm.
  - Chạm sản phẩm → mở `ProductDetailScreen`.

3) Product detail + Search
- UI: [product_detail_screen.dart], [search_screen.dart]
- Flow (detail):
  - `ProductDetailScreen` gọi API `getProduct` và `getCommentsProduct` qua `ApiClient` khi init.
  - Hiển thị images, thông tin, đánh giá. Người dùng có thể Like (gọi `likeProduct`), Thêm vào giỏ (gọi `CartProvider.addToCart`).
- Flow (search):
  - `SearchScreen` call `ApiClient.post(ApiConstants.search)` với `keyword` và optional `category_id` → kết quả list `Product`.

4) Cart
- Logic: `CartProvider` ([lib/features/cart/data/cart_provider.dart](lib/features/cart/data/cart_provider.dart))
  - Lưu cart tại runtime (in-memory list of `CartItem`).
  - Methods: `addToCart`, `updateQuantity`, `removeFromCart`, `clearCart`, `isInCart`, getters subtotal/total.
- UI: `CartScreen` hiển thị list, cho update qty, xóa từng item bằng swipe, xóa tất cả, đi tới `CheckoutScreen`.

5) Checkout → Orders
- Checkout UI: [lib/features/order/presentation/checkout_screen.dart](lib/features/order/presentation/checkout_screen.dart)
- Order logic: `OrderProvider` ([lib/features/order/data/order_provider.dart](lib/features/order/data/order_provider.dart))
- Flow:
  - `CheckoutScreen` tải addresses từ `OrderProvider.loadAddresses()`.
  - Khi xác nhận đặt hàng: `OrderProvider.createOrder()` gọi `ApiClient.post(ApiConstants.createOrder)` cho từng item (mỗi item 1 request trong implementation hiện tại).
  - Nếu tạo đơn thành công: `OrderProvider` cập nhật `_orders` và `_currentOrder`, `CartProvider.clearCart()` được gọi.
  - Người dùng được hiển thị dialog thành công và có thể quay về trang chính.

6) Orders management
- UI: `OrderListScreen`, `OrderDetailScreen`.
- `OrderProvider.loadOrders()` lấy danh sách đơn; `cancelOrder()` gọi API cancel và cập nhật trạng thái local.

7) Profile & Wallet
- Profile UI: `ProfileScreen`, `ProfileEditScreen`.
- Thông tin user lấy từ `AuthProvider.user`.
- `ProfileEditScreen` gọi `AuthProvider.updateProfile()` → post `ApiConstants.setUserInfo`.
- Wallet: `WalletProvider` có `loadBalance()` và `loadTransactions()` gọi các endpoint tương ứng; UI hiển thị số dư và history.

**Router**
- Một lớp router đơn giản đã được thêm vào `lib/core/router/app_router.dart` với `routes` và `onGenerateRoute`. Bạn có thể dùng `MaterialApp(onGenerateRoute: AppRouter.onGenerateRoute)` nếu muốn thay thế `routes` hiện tại.

**Những điểm cần chú ý (cho người mới)**
- Luồng dữ liệu chính: UI <-> Provider (ChangeNotifier) <-> ApiClient <-> Backend.
- Provider thông báo UI thông qua `notifyListeners()` → UI dùng `Consumer` / `context.watch` để re-render.
- `ApiClient` cố gắng parse response body thành `ApiResponse` và phân biệt `isTokenExpired` khi API trả mã tương ứng.
- Một số logic parse dữ liệu (ApiData, model factory constructors) cố gắng chấp nhận nhiều biến thể của API response (ví dụ: trường có thể tên khác nhau). Điều này giúp app chịu đựng API không đồng nhất.

**Lỗi/phát hiện nhanh**
- Khi đọc code, có vài chỗ code có thể gây lỗi biên dịch (ký tự `?` đứng trước biến trong body map, hoặc các chỗ dùng toán tử không hợp lệ). Trước khi chạy, nên build và sửa các lỗi cú pháp nếu Dart analyzer báo.

**Mở rộng / Thêm tính năng**
1. Tạo provider (ChangeNotifier) trong `lib/features/<feature>/data/`.
2. Tạo UI ở `lib/features/<feature>/presentation/`.
3. Đăng ký provider mới vào `MultiProvider` trong [lib/main.dart](lib/main.dart).
4. Dùng `ApiClient` để gọi endpoint (thêm vào `ApiConstants` nếu cần).

**Chạy app (nhanh)**
```bash
# Cài dependencies
flutter pub get

# Chạy debug trên thiết bị/emulator
flutter run
```

Nếu backend chưa sẵn sàng, bạn có thể mock `ApiClient` hoặc stub responses tạm thời để phát triển UI.

---
Tệp này được tạo tự động từ nội dung trong thư mục `lib/`. Nếu bạn muốn, tôi có thể:
- Thêm sơ đồ dòng chảy (sequence diagram) cho từng feature.
- Sửa các lỗi cú pháp nhỏ được phát hiện để code build được ngay.
