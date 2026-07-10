import { Controller } from "@hotwired/stimulus"

// Handles both Buy and Sell transaction forms. 
// Adapts dynamically based on which targets/values are present in the DOM.
export default class extends Controller {
  static targets = ["company", "companyName", "ticker", "stockPrice", "quantity", "totalAmount", "ownedQuantity"]
  
  // Passed from the Buy form via data-stock-balance-value="..."
  static values = { balance: Number }

  connect() {
    console.log("✅ Stock controller connected")
  }

  fetchPrice() {
    try {
      // Note: TransactionsController uses `.map(&:attributes)`, which returns string keys.
      // Bracket notation is required to access properties like "quantity".
      const companyData = JSON.parse(this.companyTarget.value)
      const company_name = companyData["company_name"]
      const stock_symbol = companyData["stock_symbol"]
      const owned_quantity = parseInt(companyData["quantity"]) || 0

      this.companyNameTarget.value = company_name
      this.tickerTarget.value = stock_symbol

      // --- SELL FORM LOGIC ---
      // If the ownedQuantity target exists, we are on the Sell form.
      // We can set the max limit immediately since we have the data.
      if (this.hasOwnedQuantityTarget) {
        const owned_quantity = parseInt(companyData["quantity"]) || 0
        this.ownedQuantityTarget.textContent = `You currently own ${owned_quantity} shares.`
        this.ownedQuantityTarget.className = "mt-1.5 text-sm text-green-600 font-medium"
        
        this.quantityTarget.max = owned_quantity
      }

      // Fetch live price from backend
      fetch(`/transactions/fetch_price?stock_symbol=${stock_symbol}`)
        .then(response => response.json())
        .then(data => {
          if (data.price_at_time) {
            const price = parseFloat(data.price_at_time)
            this.stockPriceTarget.value = price.toFixed(2)

            // --- BUY FORM LOGIC ---
            // If balanceValue exists, we are on the Buy form.
            // We must wait for the price to calculate the max affordable shares.
            if (this.hasBalanceValue && this.balanceValue > 0 && price > 0) {
              const maxAffordable = Math.floor(this.balanceValue / price)
              this.quantityTarget.max = maxAffordable
            }

            this.calculateTotal()
          } else {
            alert("Failed to fetch stock price.")
          }
        })
        .catch(error => {
          console.error("Fetch error:", error)
          alert("Error fetching stock price.")
        })
    } catch (error) {
      // Handles JSON parse errors (e.g., when the blank default option is selected)
      console.error("JSON parse error:", error)
      if (this.hasOwnedQuantityTarget) {
        this.ownedQuantityTarget.textContent = "Select a company to see your available shares."
        this.ownedQuantityTarget.className = "mt-1.5 text-sm text-gray-500"
      }
    }
  }

  calculateTotal() {
    const price = parseFloat(this.stockPriceTarget.value || 0)
    const qty = parseInt(this.quantityTarget.value || 0)
    const total = price * qty

    this.totalAmountTarget.value = total.toFixed(2)

    // Visual warning if the total exceeds the user's balance (Buy form only)
    if (this.hasBalanceValue && this.balanceValue > 0 && total > this.balanceValue) {
      this.totalAmountTarget.classList.add("text-red-600", "font-bold", "bg-red-50")
    } else {
      this.totalAmountTarget.classList.remove("text-red-600", "font-bold", "bg-red-50")
    }
  }
}
