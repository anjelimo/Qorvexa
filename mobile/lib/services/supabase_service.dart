import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  final _logger = Logger();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _logger.i('Supabase initialized successfully');
    } catch (e) {
      _logger.e('Supabase initialization error: $e');
      rethrow;
    }
  }

  SupabaseClient get client => _client;
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  /// Auth Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': userType, // 'buyer' or 'seller'
        },
      );

      if (response.user != null) {
        // Create user profile
        await _client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'user_type': userType,
          'avatar_url': null,
          'bio': '',
          'rating': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      _logger.i('User signed up: ${response.user?.email}');
      return response;
    } catch (e) {
      _logger.e('Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _logger.i('User signed in: ${response.user?.email}');
      return response;
    } catch (e) {
      _logger.e('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      _logger.i('Password reset email sent to $email');
    } catch (e) {
      _logger.e('Password reset error: $e');
      rethrow;
    }
  }

  /// User Methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      _logger.e('Get user profile error: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _client.from('users').update(updates).eq('id', userId);
      _logger.i('User profile updated');
    } catch (e) {
      _logger.e('Update user profile error: $e');
      rethrow;
    }
  }

  /// Products Methods
  Future<List<Map<String, dynamic>>> getProducts({
    int limit = 20,
    int offset = 0,
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      var query = _client
          .from('products')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Get products error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', productId)
          .single();
      return response;
    } catch (e) {
      _logger.e('Get product details error: $e');
      return null;
    }
  }

  Future<String> createProduct({
    required String sellerId,
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> imageUrls,
  }) async {
    try {
      final response = await _client.from('products').insert({
        'seller_id': sellerId,
        'name': name,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'image_urls': imageUrls,
        'stock': 0,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      _logger.i('Product created: ${response[0]['id']}');
      return response[0]['id'];
    } catch (e) {
      _logger.e('Create product error: $e');
      rethrow;
    }
  }

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _client.from('products').update(updates).eq('id', productId);
      _logger.i('Product updated: $productId');
    } catch (e) {
      _logger.e('Update product error: $e');
      rethrow;
    }
  }

  /// Cart Methods
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      final response = await _client
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Get cart items error: $e');
      return [];
    }
  }

  Future<void> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      await _client.from('cart_items').insert({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
        'created_at': DateTime.now().toIso8601String(),
      });
      _logger.i('Item added to cart');
    } catch (e) {
      _logger.e('Add to cart error: $e');
      rethrow;
    }
  }

  Future<void> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      await _client
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
      _logger.i('Cart item updated');
    } catch (e) {
      _logger.e('Update cart item error: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _client.from('cart_items').delete().eq('id', cartItemId);
      _logger.i('Item removed from cart');
    } catch (e) {
      _logger.e('Remove from cart error: $e');
      rethrow;
    }
  }

  /// Orders Methods
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('buyer_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Get user orders error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSellerOrders(String sellerId) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Get seller orders error: $e');
      return [];
    }
  }

  Future<String> createOrder({
    required String buyerId,
    required String sellerId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String deliveryAddress,
  }) async {
    try {
      final response = await _client.from('orders').insert({
        'buyer_id': buyerId,
        'seller_id': sellerId,
        'total_amount': totalAmount,
        'delivery_address': deliveryAddress,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      final orderId = response[0]['id'];

      // Add order items
      for (var item in items) {
        await _client.from('order_items').insert({
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
        });
      }

      _logger.i('Order created: $orderId');
      return orderId;
    } catch (e) {
      _logger.e('Create order error: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _client
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
      _logger.i('Order status updated: $orderId -> $status');
    } catch (e) {
      _logger.e('Update order status error: $e');
      rethrow;
    }
  }

  /// Reviews Methods
  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('*, users(full_name, avatar_url)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Get product reviews error: $e');
      return [];
    }
  }

  Future<void> createReview({
    required String productId,
    required String reviewerId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _client.from('reviews').insert({
        'product_id': productId,
        'reviewer_id': reviewerId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
      _logger.i('Review created for product: $productId');
    } catch (e) {
      _logger.e('Create review error: $e');
      rethrow;
    }
  }

  /// Messages Methods
  Future<List<Map<String, dynamic>>> getMessages({
    required String userId,
    required String otherUserId,
  }) async {
    try {
      final response = await _client
          .from('messages')
          .select('*, sender:sender_id(full_name, avatar_url)')
          .or('and(sender_id.eq.$userId,recipient_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,recipient_id.eq.$userId)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Get messages error: $e');
      return [];
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String recipientId,
    required String message,
  }) async {
    try {
      await _client.from('messages').insert({
        'sender_id': senderId,
        'recipient_id': recipientId,
        'message': message,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      _logger.i('Message sent from $senderId to $recipientId');
    } catch (e) {
      _logger.e('Send message error: $e');
      rethrow;
    }
  }

  /// Real-time Subscriptions
  RealtimeChannel subscribeToProducts({
    required Function(dynamic) onData,
    required Function(Object) onError,
  }) {
    return _client
        .channel('products')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            onData(payload.newRecord);
          },
        )
        .subscribe(
          onError: (error) {
            _logger.e('Subscription error: $error');
            onError(error);
          },
        );
  }

  RealtimeChannel subscribeToOrders({
    required String userId,
    required Function(dynamic) onData,
    required Function(Object) onError,
  }) {
    return _client
        .channel('orders:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'buyer_id',
            value: userId,
          ),
          callback: (payload) {
            onData(payload.newRecord);
          },
        )
        .subscribe(
          onError: (error) {
            _logger.e('Subscription error: $error');
            onError(error);
          },
        );
  }
}
