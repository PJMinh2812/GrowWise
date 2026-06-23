-- ============================================================================
-- SePay — chỉ cho phép 'sepay' làm payment provider / payment method
-- Chạy 1 lần trên Supabase SQL editor (an toàn để chạy lại nhiều lần).
--
-- Thứ tự quan trọng: DROP ràng buộc cũ TRƯỚC, rồi mới UPDATE dữ liệu cũ sang
-- 'sepay' (nếu không sẽ vi phạm ràng buộc cũ vốn chưa cho phép 'sepay'),
-- cuối cùng mới ADD ràng buộc mới.
-- ============================================================================

-- 1) Gỡ ràng buộc cũ
ALTER TABLE payment_transactions DROP CONSTRAINT IF EXISTS payment_transactions_provider_check;
ALTER TABLE user_subscriptions   DROP CONSTRAINT IF EXISTS user_subscriptions_payment_method_check;

-- 2) Dọn dữ liệu cũ về 'sepay'
UPDATE payment_transactions SET provider = 'sepay' WHERE provider <> 'sepay';
UPDATE user_subscriptions   SET payment_method = 'sepay' WHERE payment_method IS NOT NULL AND payment_method <> 'sepay';

-- 3) Thêm ràng buộc mới (chỉ 'sepay') + đổi default
ALTER TABLE payment_transactions ALTER COLUMN provider SET DEFAULT 'sepay';
ALTER TABLE payment_transactions
  ADD CONSTRAINT payment_transactions_provider_check
  CHECK (provider = 'sepay');

-- user_subscriptions.payment_method vẫn cho phép NULL cho gói dùng thử
ALTER TABLE user_subscriptions
  ADD CONSTRAINT user_subscriptions_payment_method_check
  CHECK (payment_method = 'sepay');
