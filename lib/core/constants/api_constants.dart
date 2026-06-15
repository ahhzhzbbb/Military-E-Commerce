class ApiConstants {
  static const String baseUrl = 'https://impacts-hardwood-interior-wanted.trycloudflare.com';

  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String createCodeResetPassword = '/auth/create_code_reset_password';
  static const String checkCodeResetPassword = '/auth/check_code_reset_password';
  static const String resetPassword = '/auth/reset_password';
  static const String changePassword = '/auth/change_password';
  static const String changeInfoAfterSignup = '/auth/change_info_after_signup';
  static const String setDevToken = '/dev_tokens/set_devtoken';

  static const String getUserInfo = '/users/get_user_info';
  static const String setUserInfo = '/users/set_user_info';

  static const String getCategories = '/api/get_categories';
  static const String getListProducts = '/api/get_list_products';
  static const String getProduct = '/api/get_products';
  static const String getListBrands = '/api/get_list_brands';

  static const String addProduct = '/api/add_product';
  static const String editProduct = '/api/update';
  static const String delProduct = '/api/delete';
  static const String getUserListings = '/api/get_user_listings';

  static const String getCommentsProduct = '/api/get_comments_product';
  static const String setCommentsProduct = '/api/set_comments_product';
  static const String likeProduct = '/api/like_product';
  static const String reportProduct = '/api/report_product';
  static const String getRates = '/api/get_rates';
  static const String setRates = '/api/set_rates';

  static const String search = '/api/search';
  static const String saveSearch = '/api/save_search';
  static const String getListSavedSearch = '/api/get_list_saved_search';
  static const String getListNews = '/News/list_news';
  static const String getNews = '/News';

  static const String setUserFollow = '/set_user_follow';
  static const String getListFollowed = '/get_list_followed';
  static const String getListFollowing = '/get_list_following';
  static const String setUserBlock = '/set_user_block';
  static const String getListBlocks = '/get_list_blocks';

  static const String sendMessage = '/conversation/send_message';
  static const String getListConversation = '/conversation/get_list_conversation';
  static const String getConversation = '/conversation/get_conversation';
  static const String setReadMessage = '/conversation/set_read_message';

  static const String getNotification = '/notification/get_notification';
  static const String setReadNotification = '/notification/set_read_notification';

  static const String getPushSetting = '/push_settings/get_push_setting';
  static const String setPushSetting = '/push_settings/set_push_setting';

  static const String createOrder = '/order/create_order';
  static const String getListPurchases = '/order/get_list_purchases';
  static const String getPurchase = '/order/get_purchase';
  static const String editPurchase = '/order/edit_purchase';
  static const String cancelOrder = '/order/cancel_order';
  static const String setAcceptBuyer = '/order/set_accept_buyer';
  static const String sellerMarkAsShipped = '/order/seller_mark_as_shipped';
  static const String buyerConfirmReceived = '/order/buyer_confirm_received';
  static const String getOrderTimeline = '/order/get_order_timeline';
  static const String refundOrder = '/order/refund_order';

  static const String getShipFrom = '/order/get_ship_from';
  static const String getShipFee = '/order/get_ship_fee';
  static const String getOrderStatus = '/order/get_order_status';
  static const String getListOrderAddress = '/order/get_list_order_address';
  static const String addOrderAddress = '/order/add_order_address';
  static const String editOrderAddress = '/order/update';
  static const String deleteOrderAddress = '/order/delete';

  static const String getCurrentBalance = '/wallets/get_current_balance';
  static const String getBalanceHistory = '/wallets/get_balance_history';

  static const String uploadFile = '/upload/file';
  static const String getRewardHistory = '/rewards/get_reward_history';
  static const String createRewardAppeal = '/rewards/create_reward_appeal';

  static const String addressesCreate = '/addresses/create';
  static const String addressesMe = '/addresses/me';
}

class ResponseCodes {
  static const int ok = 1000;
  static const int parameterNotEnough = 1002;
  static const int parameterTypeInvalid = 1003;
  static const int parameterValueInvalid = 1004;
  static const int unknownError = 1005;
  static const int fileSizeTooBig = 1006;
  static const int uploadFileFailed = 1007;
  static const int notAccess = 1009;
  static const int actionDonePreviously = 1010;
  static const int productSold = 1011;
  static const int addressNotSupportShipping = 1012;
  static const int userNotExist = 1013;
  static const int codeVerifyIncorrect = 9993;
  static const int noData = 9994;
  static const int userNotValidated = 9995;
  static const int userExisted = 9996;
  static const int tokenInvalid = 9998;
  static const int exceptionError = 9999;
}

class OrderStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String shipping = 'shipping';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
  static const String refunded = 'refunded';
}
