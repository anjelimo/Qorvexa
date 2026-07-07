-- Qorvexa Row Level Security (RLS) Policies
-- Enforces data access control at the database level

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ========== USERS POLICIES ==========

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Users can read public seller profiles
CREATE POLICY "Anyone can read seller profiles"
  ON public.users
  FOR SELECT
  USING (user_type = 'seller' OR auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id);

-- ========== CATEGORIES POLICIES ==========

-- Anyone can read categories
CREATE POLICY "Anyone can read categories"
  ON public.categories
  FOR SELECT
  USING (true);

-- Only admins can insert categories
CREATE POLICY "Only admins can insert categories"
  ON public.categories
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND user_type = 'admin'
    )
  );

-- ========== PRODUCTS POLICIES ==========

-- Anyone can read active products
CREATE POLICY "Anyone can read active products"
  ON public.products
  FOR SELECT
  USING (status = 'active');

-- Sellers can read their own products
CREATE POLICY "Sellers can read own products"
  ON public.products
  FOR SELECT
  USING (seller_id = auth.uid());

-- Sellers can insert products
CREATE POLICY "Sellers can insert products"
  ON public.products
  FOR INSERT
  WITH CHECK (
    seller_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND user_type = 'seller'
    )
  );

-- Sellers can update their own products
CREATE POLICY "Sellers can update own products"
  ON public.products
  FOR UPDATE
  USING (seller_id = auth.uid());

-- ========== CART ITEMS POLICIES ==========

-- Users can read their own cart
CREATE POLICY "Users can read own cart"
  ON public.cart_items
  FOR SELECT
  USING (user_id = auth.uid());

-- Users can insert items to their cart
CREATE POLICY "Users can insert to own cart"
  ON public.cart_items
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Users can update their own cart
CREATE POLICY "Users can update own cart"
  ON public.cart_items
  FOR UPDATE
  USING (user_id = auth.uid());

-- Users can delete from their own cart
CREATE POLICY "Users can delete from own cart"
  ON public.cart_items
  FOR DELETE
  USING (user_id = auth.uid());

-- ========== ORDERS POLICIES ==========

-- Buyers can read their own orders
CREATE POLICY "Buyers can read own orders"
  ON public.orders
  FOR SELECT
  USING (buyer_id = auth.uid());

-- Sellers can read orders they fulfill
CREATE POLICY "Sellers can read their orders"
  ON public.orders
  FOR SELECT
  USING (seller_id = auth.uid());

-- Buyers can insert orders
CREATE POLICY "Buyers can create orders"
  ON public.orders
  FOR INSERT
  WITH CHECK (
    buyer_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND user_type = 'buyer'
    )
  );

-- Buyers can update their orders (for cancellation)
CREATE POLICY "Buyers can update own orders"
  ON public.orders
  FOR UPDATE
  USING (buyer_id = auth.uid());

-- Sellers can update order status
CREATE POLICY "Sellers can update order status"
  ON public.orders
  FOR UPDATE
  USING (seller_id = auth.uid());

-- ========== ORDER ITEMS POLICIES ==========

-- Users can read items from their orders
CREATE POLICY "Users can read order items"
  ON public.order_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND (orders.buyer_id = auth.uid() OR orders.seller_id = auth.uid())
    )
  );

-- ========== REVIEWS POLICIES ==========

-- Anyone can read reviews
CREATE POLICY "Anyone can read reviews"
  ON public.reviews
  FOR SELECT
  USING (true);

-- Users can insert reviews for orders they completed
CREATE POLICY "Users can insert reviews"
  ON public.reviews
  FOR INSERT
  WITH CHECK (
    reviewer_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND orders.buyer_id = auth.uid()
    )
  );

-- Users can update their own reviews
CREATE POLICY "Users can update own reviews"
  ON public.reviews
  FOR UPDATE
  USING (reviewer_id = auth.uid());

-- ========== MESSAGES POLICIES ==========

-- Users can read their messages
CREATE POLICY "Users can read own messages"
  ON public.messages
  FOR SELECT
  USING (sender_id = auth.uid() OR recipient_id = auth.uid());

-- Users can insert messages
CREATE POLICY "Users can insert messages"
  ON public.messages
  FOR INSERT
  WITH CHECK (sender_id = auth.uid());

-- Recipients can update message read status
CREATE POLICY "Recipients can update message status"
  ON public.messages
  FOR UPDATE
  USING (recipient_id = auth.uid());

-- ========== TRANSACTIONS POLICIES ==========

-- Users can read their transactions
CREATE POLICY "Users can read own transactions"
  ON public.transactions
  FOR SELECT
  USING (user_id = auth.uid());

-- System can insert transactions
CREATE POLICY "System can insert transactions"
  ON public.transactions
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- ========== NOTIFICATIONS POLICIES ==========

-- Users can read their own notifications
CREATE POLICY "Users can read own notifications"
  ON public.notifications
  FOR SELECT
  USING (user_id = auth.uid());

-- Users can update their own notifications
CREATE POLICY "Users can update own notifications"
  ON public.notifications
  FOR UPDATE
  USING (user_id = auth.uid());

-- ========== GRANT PERMISSIONS ==========

-- Grant necessary permissions to authenticated users
GRANT SELECT ON public.users TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated;
GRANT SELECT ON public.categories TO authenticated;
GRANT SELECT ON public.products TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cart_items TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.orders TO authenticated;
GRANT SELECT ON public.order_items TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.reviews TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.messages TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.transactions TO authenticated;
GRANT SELECT, UPDATE ON public.notifications TO authenticated;

-- Grant service role permissions for triggers and functions
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
