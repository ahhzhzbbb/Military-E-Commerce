class ApiConstants {
  static const String baseUrl =
      'https://adware-merely-andrews-home.trycloudflare.com';
  static const String apiVersion = '/api';

  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String createCodeResetPassword =
      '/auth/create_code_reset_password';
  static const String checkCodeResetPassword =
      '/auth/check_code_reset_password';
  static const String resetPassword = '/auth/reset_password';
  static const String changePassword = '/auth/change_password';
  static const String changeInfoAfterSignup = '/auth/change_info_after_signup';
  static const String setDevToken = '$apiVersion/set_devtoken/set_devtoken';

  static const String getUserInfo = '$apiVersion/get_user_info';
  static const String setUserInfo = '$apiVersion/set_user_info';

  static const String getCategories = '$apiVersion/get_categories';
  static const String getListProducts = '$apiVersion/get_list_products';
  static const String getProduct = '$apiVersion/get_products';
  static const String getListBrands = '$apiVersion/get_list_brands';

  static const String addProduct = '$apiVersion/add_product';
  static const String editProduct = '$apiVersion/edit_product';
  static const String delProduct = '$apiVersion/del_product';
  static const String getUserListings = '$apiVersion/get_user_listings';

  static const String getCommentsProduct = '$apiVersion/get_comments_product';
  static const String setCommentsProduct = '$apiVersion/set_comments_product';
  static const String likeProduct = '$apiVersion/like_product';
  static const String reportProduct = '$apiVersion/report_product';
  static const String getRates = '$apiVersion/get_rates';
  static const String setRates = '$apiVersion/set_rates';

  static const String search = '$apiVersion/search';
  static const String delSavedSearch = '$apiVersion/del_saved_search';
  static const String getListSavedSearch = '$apiVersion/get_list_saved_search';
  static const String getListNews = '$apiVersion/get_list_news';
  static const String getNews = '$apiVersion/get_news';

  static const String setUserFollow = '$apiVersion/set_user_follow';
  static const String getListFollowed = '$apiVersion/get_list_followed';
  static const String getListFollowing = '$apiVersion/get_list_following';
  static const String getListBlocks = '$apiVersion/get_list_blocks';
  static const String blocks = '$apiVersion/blocks';

  static const String sendMessage = '$apiVersion/send_message';
  static const String getListConversation = '$apiVersion/get_list_conversation';
  static const String getConversation = '$apiVersion/get_conversation';
  static const String getConversationDetail =
      '$apiVersion/get_conversation_detail';
  static const String getNotification = '$apiVersion/get_notification';
  static const String setReadNotification = '$apiVersion/set_read_notification';
  static const String setReadMessage = '$apiVersion/set_read_message';

  static const String getPushSetting = '$apiVersion/get_push_setting';
  static const String setPushSetting = '$apiVersion/set_push_setting';

  static const String createOrder = '$apiVersion/create_order';
  static const String getListPurchases = '$apiVersion/get_list_purchases';
  static const String getPurchase = '$apiVersion/get_purchase';
  static const String editPurchase = '$apiVersion/edit_purchase';
  static const String cancelOrder = '$apiVersion/cancel_order';
  static const String setAcceptBuyer = '$apiVersion/set_accept_buyer';
  static const String sellerMarkAsShipped =
      '$apiVersion/seller_mark_as_shipped';
  static const String buyerConfirmReceived =
      '$apiVersion/buyer_confirm_received';
  static const String getOrderTimeline = '$apiVersion/get_order_timeline';
  static const String refundOrder = '$apiVersion/refund_order';

  static const String getShipFrom = '$apiVersion/get_ship_from';
  static const String getShipFee = '$apiVersion/get_ship_fee';
  static const String getOrderStatus = '$apiVersion/get_order_status';
  static const String getListOrderAddress =
      '$apiVersion/get_list_order_address';
  static const String addOrderAddress = '$apiVersion/add_order_address';
  static const String editOrderAddress = '$apiVersion/edit_order_address';
  static const String deleteOrderAddress = '$apiVersion/delete_order_address';

  static const String getCurrentBalance = '$apiVersion/get_current_balance';
  static const String getBalanceHistory = '$apiVersion/get_balance_history';
  static const String createWithdrawRequest =
      '$apiVersion/create_withdraw_request';
  static const String setRequestWithdraw = '$apiVersion/set_request_withdraw';
  static const String getWithdrawHistory = '$apiVersion/get_withdraw_history';

  static const String uploadVideo = '$apiVersion/upload_video';
  static const String getRewardHistory = '$apiVersion/get_reward_history';
  static const String createRewardAppeal = '$apiVersion/create_reward_appeal';

  static const String getBankAccounts = '$apiVersion/get_bank_accounts';
  static const String addBankAccount = '$apiVersion/add_bank_account';
  static const String editBankAccount = '$apiVersion/edit_bank_account';
  static const String deleteBankAccount = '$apiVersion/delete_bank_account';
  static const String setDefaultBankAccount =
      '$apiVersion/set_default_bank_account';
}

class ResponseCodes {
  static const int ok = 1000;
  static const int parameterNotEnough = 1002;
  static const int parameterTypeInvalid = 1003;
  static const int parameterValueInvalid = 1004;
  static const int notAccess = 1009;
  static const int actionDonePreviously = 1010;
  static const int userNotExist = 1013;
  static const int codeVerifyIncorrect = 9993;
  static const int noData = 9994;
  static const int userNotValidated = 9995;
  static const int tokenInvalid = 9998;
}

class OrderStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String shipping = 'shipping';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
  static const String refunded = 'refunded';
}
