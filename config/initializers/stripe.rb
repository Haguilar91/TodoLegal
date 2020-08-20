Stripe.api_key = ENV['STRIPE_SECRET_KEY']

if Rails.env.development?
  STRIPE_PUBLIC_KEY = "pk_test_51H0sbTJDCreTdC1MiTmXgtca69vY4PqnUcbBLHTufp3dG2csCmxSOYq24Iw3ukIc64XllTaubTM4IrnCxNYMlBqZ00fMpYKMTR"
  STRIPE_SUBSCRIPTION_PRODUCT = "prod_HmWdVtbJ5fEFkU"
  STRIPE_MONTH_SUBSCRIPTION_PRICE = "price_1HCxa9JDCreTdC1MjLhqrSeW"
  STRIPE_YEAR_SUBSCRIPTION_PRICE = "price_1HCxa9JDCreTdC1M2wVLCYG0"
  STRIPE_LAUNCH_COUPON_ID = "sHqXgNsa"
elsif Rails.env.production?
  STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLIC_KEY']
  STRIPE_SUBSCRIPTION_PRODUCT = ENV['STRIPE_SUBSCRIPTION_PRODUCT']
  STRIPE_MONTH_SUBSCRIPTION_PRICE = ENV['STRIPE_MONTH_SUBSCRIPTION_PRICE']
  STRIPE_YEAR_SUBSCRIPTION_PRICE = ENV['STRIPE_YEAR_SUBSCRIPTION_PRICE']
  STRIPE_LAUNCH_COUPON_ID = ENV['STRIPE_LAUNCH_COUPON_ID']
end