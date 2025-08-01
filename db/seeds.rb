# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# User.destroy_all - use only to reset all users in the User Table

# db/seeds.rb
# Seed data for Stock Trading App testing

# db/seeds.rb
# Seed data for Stock Trading App testing

# Clear existing data ( INGAT DITO - COMMENT OUT IF DI GAGAMITIN)
puts "🧹 Cleaning existing data..."
Transaction.destroy_all
Portfolio.destroy_all
User.destroy_all

puts "🌱 Creating seed data..."

# Create 1 Admin
puts "👑 Creating admin user..."
admin = User.create!(
  first_name: "Boss",
  last_name: "Admin",
  email: "admin@stockapp.com",
  password: "password123",
  password_confirmation: "password123",
  balance: 100000.00,
  is_admin: true,
  is_approve: true,
  confirmed_at: Time.current,
  created_by_admin: false
)

puts "✅ Admin created: #{admin.email}"

# Create 5 Traders with different statuses
traders_data = [
  {
    first_name: "Bong",
    last_name: "Revilla",
    email: "budots@trader.com",
    balance: 50000.00,
    is_approve: true,
    confirmed_at: Time.current,
    status: "Active Trader"
  },
  {
    first_name: "Manny",
    last_name: "Pacquiao",
    email: "pakyaw@trader.com",
    balance: 25000.00,
    is_approve: true,
    confirmed_at: nil,  # Approved but email not confirmed
    status: "Approved but Unconfirmed"
  },
  {
    first_name: "Xian",
    last_name: "Gaza",
    email: "chismiso@trader.com",
    balance: 75000.00,
    is_approve: false,
    confirmed_at: Time.current,
    status: "Confirmed but Pending Approval"
  },
  {
    first_name: "Mocha",
    last_name: "Uson",
    email: "fakenews@trader.com",
    balance: 30000.00,
    is_approve: false,
    confirmed_at: nil,  # Neither confirmed nor approved
    status: "Completely New"
  },
  {
    first_name: "Lincoln",
    last_name: "Velasquez",
    email: "congTV@trader.com",
    balance: 60000.00,
    is_approve: true,
    confirmed_at: 2.days.ago,
    status: "Active Trader (Recent)"
  }
]

puts "👥 Creating traders..."
traders = []

traders_data.each do |trader_data|
  status = trader_data.delete(:status)

  trader = User.create!(
    **trader_data,
    password: "password123",
    password_confirmation: "password123",
    is_admin: false,
    created_by_admin: [ true, false ].sample  # Random admin creation
  )

  traders << trader
  puts "✅ Trader created: #{trader.email} (#{status})"
end

# Sample stocks for transactions
sample_stocks = [
  { symbol: "AAPL", name: "Apple Inc.", price: 175.50 },
  { symbol: "GOOGL", name: "Alphabet Inc.", price: 125.25 },
  { symbol: "MSFT", name: "Microsoft Corp.", price: 380.75 },
  { symbol: "TSLA", name: "Tesla Inc.", price: 215.00 },
  { symbol: "AMZN", name: "Amazon.com Inc.", price: 145.30 },
  { symbol: "NVDA", name: "NVIDIA Corp.", price: 485.20 },
  { symbol: "META", name: "Meta Platforms Inc.", price: 325.80 }
]

# Create transactions for approved and confirmed traders only
puts "💰 Creating transactions..."
active_traders = traders.select { |t| t.is_approve? && t.confirmed_at.present? }

transaction_count = 0

active_traders.each do |trader|
  # Each active trader gets 3-8 random transactions
  num_transactions = rand(3..8)

  # Keep track of what stocks they "own" for realistic selling
  owned_stocks = {}

  num_transactions.times do |i|
    stock = sample_stocks.sample

    # First few transactions are mostly buys to build up holdings
    if i < 2 || owned_stocks.empty?
      transaction_type = "buy"
    else
      # After initial buys, mix of buys and sells
      # Only sell stocks they actually "own"
      available_to_sell = owned_stocks.select { |_, qty| qty > 0 }

      if available_to_sell.any? && rand < 0.4  # 40% chance to sell
        transaction_type = "sell"
        stock_symbol = available_to_sell.keys.sample
        stock = sample_stocks.find { |s| s[:symbol] == stock_symbol }
      else
        transaction_type = "buy"
      end
    end

    quantity = rand(1..50)

    # For sells, don't sell more than they own
    if transaction_type == "sell" && owned_stocks[stock[:symbol]]
      max_sellable = owned_stocks[stock[:symbol]]
      quantity = rand(1..max_sellable) if max_sellable > 0
    end

    # Add some price variation (±5% from base price)
    price_variation = 1 + (rand(-5..5) / 100.0)
    price_at_time = (stock[:price] * price_variation).round(2)
    total_amount = (quantity * price_at_time).round(2)

    # Check if transaction is valid
    can_transact = false
    if transaction_type == "buy" && trader.balance >= total_amount
      can_transact = true
    elsif transaction_type == "sell" && owned_stocks[stock[:symbol]].to_i >= quantity
      can_transact = true
    end

    if can_transact
      transaction = Transaction.create!(
        user: trader,
        company_name: stock[:name],
        stock_symbol: stock[:symbol],
        transaction_type: transaction_type,
        quantity: quantity,
        price_at_time: price_at_time,
        total_amount: total_amount,
        created_at: rand(30.days.ago..Time.current)
      )

      # Update owned stocks tracking
      if transaction_type == "buy"
        owned_stocks[stock[:symbol]] = owned_stocks[stock[:symbol]].to_i + quantity
      else # sell
        owned_stocks[stock[:symbol]] = owned_stocks[stock[:symbol]].to_i - quantity
      end

      transaction_count += 1
    end
  end

  puts "✅ Created transactions for #{trader.first_name}: #{trader.transactions.buy_orders.count} buys, #{trader.transactions.sell_orders.count} sells"
end

puts "✅ Created #{transaction_count} total transactions"
puts "📊 Breakdown: #{Transaction.buy_orders.count} buys, #{Transaction.sell_orders.count} sells"

# Create some portfolios for traders with buy transactions
puts "📊 Creating portfolios..."
portfolio_count = 0

active_traders.each do |trader|
  buy_transactions = trader.transactions.where(transaction_type: 'buy')

  # Group by stock symbol and create portfolio entries
  buy_transactions.group_by(&:stock_symbol).each do |symbol, transactions|
    total_quantity = transactions.sum(&:quantity)
    total_amount = transactions.sum(&:total_amount)
    latest_price = transactions.last.price_at_time

    if total_quantity > 0
      Portfolio.create!(
        user: trader,
        company_name: transactions.first.company_name,
        stock_symbol: symbol,
        quantity: total_quantity,
        current_price: latest_price,
        total_amount: total_amount
      )

      portfolio_count += 1
    end
  end
end

puts "✅ Created #{portfolio_count} portfolio entries"

# Summary
puts "\n🎉 Seed data created successfully!"
puts "\n📊 Summary:"
puts "👑 Admins: #{User.admins.count}"
puts "👥 Total Traders: #{User.traders.count}"
puts "✅ Approved Traders: #{User.traders.approved.count}"
puts "⏳ Pending Traders: #{User.traders.pending.count}"
puts "📧 Confirmed Traders: #{User.traders.confirmed.count}"
puts "❌ Unconfirmed Traders: #{User.traders.unconfirmed.count}"
puts "💰 Total Transactions: #{Transaction.count}"
puts "📊 Total Portfolios: #{Portfolio.count}"

puts "\n🔑 Login credentials:"
puts "Admin: admin@stockapp.com / password123"
puts "Active Trader: budots@trader.com / password123"
puts "Active Trader: congTV@trader.com / password123"

puts "\n🧪 Test scenarios available:"
puts "• Pending approval: fakenews@trader.com, chismiso@trader.com"
puts "• Email confirmation needed: pakyaw@trader.com, fakenews@trader.com "
puts "• Active trading: john@trader.com, david@trader.com"
