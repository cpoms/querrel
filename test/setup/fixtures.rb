@adidas = Brand.create!(name: "Adidas")
@shoe = ProductCategory.create!(name: "Shoe")
@tee = ProductCategory.create!(name: "T-shirt")

Product.create!(
  brand_id: @adidas.id,
  category_id: @shoe.id,
  name: "Gazelle OG"
)
Product.create!(
  brand_id: @adidas.id,
  category_id: @shoe.id,
  name: "Hamburg"
)
Product.create!(
  brand_id: @adidas.id,
  category_id: @tee.id,
  name: "Hamburg"
)