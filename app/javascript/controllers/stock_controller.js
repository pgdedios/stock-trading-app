import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["company", "companyName", "ticker", "stockPrice", "quantity", "totalAmount"]

  connect() {
    console.log("✅ Stock controller connected")
  }

  fetchPrice() {
    try {
      const companyData = JSON.parse(this.companyTarget.value)
      const company_name = companyData.company_name
      const stock_symbol = companyData.stock_symbol

      this.companyNameTarget.value = company_name
      this.tickerTarget.value = stock_symbol

      fetch(`/transactions/fetch_price?stock_symbol=${stock_symbol}`)
        .then(response => response.json())
        .then(data => {
          if (data.price_at_time) {
            this.stockPriceTarget.value = parseFloat(data.price_at_time).toFixed(2)
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
      console.error("JSON parse error:", error)
      alert("Invalid company data.")
    }
  }

  calculateTotal() {
    const price = parseFloat(this.stockPriceTarget.value || 0)
    const qty = parseInt(this.quantityTarget.value || 0)
    this.totalAmountTarget.value = (price * qty).toFixed(2)
  }
}
