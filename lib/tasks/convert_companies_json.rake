require 'json'

namespace :companies do
  desc "Convert companies.json to list of hashes and save as formatted_companies.json"
  task convert: :environment do
    input_path = Rails.root.join("lib/assets/data/raw_companies.json")
    output_path = Rails.root.join("lib/assets/data/companies.json")

    unless File.exist?(input_path)
      puts "❌ Input file not found: #{input_path}"
      next
    end

    file = File.read(input_path)
    json = JSON.parse(file)

    formatted = json["data"].map do |row|
      json["fields"].zip(row).to_h
    end

    # ✅ Sort alphabetically by company name
    sorted = formatted.sort_by { |company| company["company_name"].downcase }

    File.write(output_path, JSON.pretty_generate(sorted))
    puts "✅ Sorted and saved to: #{output_path}"
  end
end
